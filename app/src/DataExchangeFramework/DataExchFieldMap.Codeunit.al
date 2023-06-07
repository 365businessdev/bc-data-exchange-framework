codeunit 50003 "bdev.DEF Data Exch. Field Map."
{
    procedure SetField(recRef: RecordRef; dataExchFldMapping: Record "Data Exch. Field Mapping"; var dataExchField: Record "Data Exch. Field"; var fieldIdsToNegate: List of [Integer])
    var
        dataExchColumnDef: Record "Data Exch. Column Def";
        transformationRule: Record "Transformation Rule";
        tempBlob: Codeunit "Temp Blob";
        fld: FieldRef;
        stream: OutStream;
        negativeSignIdentifier: Text;
        transformedValue: Text;
    begin
        if (dataExchField."Column No." = 0) then
            exit;

        dataExchColumnDef.Get(dataExchFldMapping."Data Exch. Def Code", dataExchFldMapping."Data Exch. Line Def Code", dataExchField."Column No.");
        fld := recRef.Field(dataExchFldMapping."Field ID");

        transformedValue := dataExchField.GetValue().Trim();
        if (dataExchFldMapping."Transformation Rule" <> '') then begin
            transformationRule.Get(dataExchFldMapping."Transformation Rule");
            transformedValue := transformationRule.TransformText(dataExchField.Value);
        end;

        case fld.Type of
            fld.Type::Text,
            fld.Type::Code:
                SetAndMergeTextCodeField(transformedValue, fld, dataExchFldMapping."Overwrite Value");
            fld.Type::Date:
                SetDateDecimalField(transformedValue, dataExchField, fld, dataExchColumnDef);
            fld.Type::Decimal:
                if (dataExchColumnDef."Negative-Sign Identifier" = '') then begin
                    SetDateDecimalField(transformedValue, dataExchField, fld, dataExchColumnDef);
                    AdjustDecimalWithMultiplier(fld, dataExchFldMapping.Multiplier, fld.Value);
                end else begin
                    negativeSignIdentifier := dataExchField.Value;
                    if (dataExchColumnDef."Negative-Sign Identifier".ToLower() = negativeSignIdentifier.ToLower()) then
                        SaveNegativeSignForField(dataExchFldMapping."Field ID", fieldIdsToNegate);
                end;
            fld.Type::Option:
                SetOptionField(transformedValue, fld);
            fld.Type::BLOB:
                begin
                    tempBlob.CreateOutStream(stream, TextEncoding::Windows);
                    stream.WriteText(transformedValue);
                    tempBlob.ToRecordRef(recRef, fld.Number);
                end;
            else
                Error(DataTypeNotSupportedErr, dataExchColumnDef.Description, dataExchFldMapping."Data Exch. Def Code", fld.Type);
        end;
        if (not dataExchFldMapping."Overwrite Value") then
            fld.Validate();
    end;

    procedure SetFieldValue(recRef: RecordRef; fldID: Integer; value: Variant)
    var
        fldRef: FieldRef;
    begin
        if (fldID = 0) then
            exit;
        fldRef := recRef.Field(fldID);
        fldRef.Validate(value);
    end;

    procedure GetLastIntegerKeyField(recRef: RecordRef): Integer
    var
        fldRef: FieldRef;
        keyRef: KeyRef;
    begin
        keyRef := recRef.KeyIndex(1);
        fldRef := keyRef.FieldIndex(keyRef.FieldCount);
        if (fldRef.Type <> FieldType::Integer) then
            exit(0);

        exit(fldRef.Number());
    end;

    procedure GetLastKeyValueInRange(recRefTemplate: RecordRef; fldId: Integer): Integer
    var
        recRef: RecordRef;
        fldRef: FieldRef;
    begin
        recRef := recRefTemplate.Duplicate();
        SetKeyAsFilter(recRef);
        fldRef := recRef.Field(fldId);
        fldRef.SetRange();
        if (recRef.FindLast()) then
            exit(recRef.Field(fldId).Value);

        exit(0);
    end;

    procedure GetType(dataExchDefCode: Code[20]): Text
    var
        dataExchDef: Record "Data Exch. Def";
    begin
        dataExchDef.Get(dataExchDefCode);
        exit(Format(dataExchDef.Type));
    end;

    local procedure SetOptionField(valueText: Text; fldRef: FieldRef)
    var
        optionValue: Integer;
    begin
        while true do begin
            optionValue += 1;
            if (valueText.ToLower() = SelectStr(optionValue, fldRef.OptionCaption()).ToLower()) then begin
                fldRef.Value(optionValue - 1);

                exit;
            end;
        end;
    end;

    local procedure SetAndMergeTextCodeField(value: Text; var fldRef: FieldRef; overwriteValue: Boolean)
    var
        currLength: Integer;
        mergeStructTxt: Label '%1 %2', Locked = true;
    begin
        currLength := StrLen(Format(fldRef.Value));
        if ((fldRef.Length = currLength) and (not overwriteValue)) then
            exit;
        if ((currLength = 0) or (overwriteValue)) then
            fldRef.Value(CopyStr(value, 1, fldRef.Length))
        else
            fldRef.Value(StrSubstNo(mergeStructTxt, Format(fldRef.Value), CopyStr(value, 1, fldRef.Length - currLength - 1)));
    end;

    local procedure SetDateDecimalField(valueText: Text; var dataExchField: Record "Data Exch. Field"; var fldRef: FieldRef; var dataExchColumnDef: Record "Data Exch. Column Def")
    var
        typeHelper: Codeunit "Type Helper";
        value: Variant;
    begin
        if (valueText = '') then begin
            fldRef.Value(0D);

            exit;
        end;
        value := fldRef.Value();

        if (not typeHelper.Evaluate(value, valueText, dataExchColumnDef."Data Format", dataExchColumnDef."Data Formatting Culture")) then
            Error(IncorrectFormatOrTypeErr,
              GetFileName(dataExchField."Data Exch. No."),
              GetType(dataExchColumnDef."Data Exch. Def Code"),
                dataExchColumnDef."Data Exch. Def Code",
                dataExchField."Line No.",
                dataExchField."Column No.", Format(fldRef.Type),
                dataExchColumnDef.FieldCaption("Data Format"),
                dataExchColumnDef.FieldCaption("Data Formatting Culture"),
                dataExchColumnDef.TableCaption, dataExchField.Value);

        fldRef.Value(value);
    end;

    local procedure AdjustDecimalWithMultiplier(var fldRef: FieldRef; multiplier: Decimal; decimalAsVariant: Variant)
    var
        decimalValue: Decimal;
    begin
        decimalValue := decimalAsVariant;
        fldRef.Value(multiplier * decimalValue);
    end;

    local procedure SetKeyAsFilter(var recRef: RecordRef)
    var
        fldRef: FieldRef;
        keyRef: KeyRef;
        i: Integer;
    begin
        keyRef := recRef.KeyIndex(1);
        for i := 1 to keyRef.FieldCount() do begin
            fldRef := recRef.Field(keyRef.FieldIndex(i).Number);
            fldRef.SetRange(fldRef.Value);
        end
    end;

    local procedure SaveNegativeSignForField(fldId: Integer; var fieldIdsToNegate: List of [Integer])
    begin
        if (fieldIdsToNegate.Contains(fldId)) then
            exit;

        fieldIdsToNegate.Add(fldId);
    end;

    procedure NegateAmounts(recRef: RecordRef; var fieldIdsToNegate: List of [Integer])
    var
        fldRef: FieldRef;
        fldId: Integer;
        amount: Decimal;
    begin
        foreach fldId in fieldIdsToNegate do begin
            fldRef := recRef.Field(fldId);
            amount := fldRef.Value();
            fldRef.Value(-amount);
            fldRef.Validate();
        end;

        Clear(fieldIdsToNegate);
    end;

    local procedure GetFileName(dataExchEntryNo: Integer): Text
    var
        dataExch: Record "Data Exch.";
    begin
        dataExch.Get(dataExchEntryNo);
        exit(dataExch."File Name");
    end;

    var
        DataTypeNotSupportedErr: Label 'The %1 column is mapped in the %2 format to a %3 field, which is not supported.', Comment = '%1=Field Value;%2=Field Value;%3=Filed Type';
        IncorrectFormatOrTypeErr: Label 'The file that you are trying to import, %1, is different from the specified %2, %3.\\The value in line %4, column %5 has incorrect format or type.\Expected format: %6, according to the %7 and %8 of the %9.\Actual value: "%10".', Comment = '%1=File Name;%2=Data Exch.Def Type;%3=Data Exch. Def Code;%4=Line No;%5=Column No;%6=Data Type;%7=Data Type Format;%8=Local;%9=Actual Value,%10=Value';

}