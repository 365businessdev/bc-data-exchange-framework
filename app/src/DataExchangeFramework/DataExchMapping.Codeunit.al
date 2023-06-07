codeunit 50002 "bdev.DEF Data Exch. Mapping"
{
    Permissions = TableData "Data Exch." = rimd;
    TableNo = "Data Exch. Mapping";

    trigger OnRun()
    begin
        ProcessLines(Rec);
    end;

    [TryFunction]
    procedure GetDataRowFiltered(var dataRow: Record Integer; dataExchEntryNo: Integer)
    var
        dataExchField: Record "Data Exch. Field";
    begin
        dataExchField.Reset();
        dataExchField.SetRange("Data Exch. No.", dataExchEntryNo);
        dataExchField.FindLast();

        dataRow.Reset();
        dataRow.SetRange(Number, 1, dataExchField."Line No.");
        dataRow.FindSet(false);
    end;

    local procedure ProcessLines(dataExchMapping: Record "Data Exch. Mapping")
    var
        dataExch: Record "Data Exch.";
        dataExchLineDef: Record "Data Exch. Line Def";
        dataRow: Record Integer;
    begin
        dataExch.Get(dataExchMapping."bdev.DEF Data Exch. Entry No.");
        dataExchLineDef.Get(dataExchMapping."Data Exch. Def Code", dataExchMapping."Data Exch. Line Def Code");

        if (not GetDataRowFiltered(dataRow, dataExchMapping."bdev.DEF Data Exch. Entry No.")) then
            exit;

        repeat
            ProcessLine(dataExch, dataExchLineDef, dataExchMapping, dataRow.Number);
        until dataRow.Next() = 0;
    end;

    local procedure ProcessLine(dataExch: Record "Data Exch."; dataExchLineDef: Record "Data Exch. Line Def"; dataExchMapping: Record "Data Exch. Mapping"; lineNo: Integer)
    var
        dataExchField: Record "Data Exch. Field";
        dataExchFieldMapping: Record "Data Exch. Field Mapping";
        dataExchFldMapping: Codeunit "bdev.DEF Data Exch. Field Map.";
        recRef: RecordRef;
        lastKeyFldId: Integer;
        lineNoOffset: Integer;
        fieldIdsToNegate: List of [Integer];
        isHandled: Boolean;
        missingValueErr: Label 'The file that you are trying to import, %1, is different from the specified %2, %3.\\The value in line %4, column %5 is missing.', Comment = '%1 = File Name, %2 = Data Exch.Def Type, %3 = Data Exch. Def Code, %4 = Line No, %5 = Column No';
        missingDataExchFieldMappingErr: Label 'The field mapping for Data Exchange Definition %1, Line Definition %2 and Table ID %3 is missing.\\Please verify set up and try again.', Comment = '%1 = Definition Code, %2 = Line Definition Code, %3 = Table ID';
    begin
        recRef.Open(dataExchMapping."Table ID");

        lastKeyFldId := dataExchFldMapping.GetLastIntegerKeyField(recRef);
        lineNoOffset := dataExchFldMapping.GetLastKeyValueInRange(recRef, lastKeyFldId);

        dataExchFieldMapping.Reset();
        dataExchFieldMapping.SetRange("Data Exch. Def Code", DataExch."Data Exch. Def Code");
        dataExchFieldMapping.SetRange("Data Exch. Line Def Code", DataExchLineDef.Code);
        dataExchFieldMapping.SetRange("Table ID", dataExchMapping."Table ID");
        dataExchFieldMapping.SetFilter(Priority, '<>%1', 0);
        if (not dataExchFieldMapping.IsEmpty()) then
            dataExchFieldMapping.SetCurrentKey("Data Exch. Def Code", "Data Exch. Line Def Code", "Table ID", Priority);

        dataExchFieldMapping.SetRange(Priority);
        if (not dataExchFieldMapping.FindSet(false)) then begin
            OnProcessLineDataExchFieldMapping(recRef, dataExch, dataExchLineDef, lineNo, isHandled);
            if (not isHandled) then
                Error(missingDataExchFieldMappingErr);
        end;

        if (dataExchMapping."Data Exch. No. Field ID" <> 0) and (dataExchMapping."Data Exch. Line Field ID" <> 0) then begin
            dataExchFldMapping.SetFieldValue(RecRef, dataExchMapping."Data Exch. No. Field ID", DataExch."Entry No.");
            dataExchFldMapping.SetFieldValue(RecRef, dataExchMapping."Data Exch. Line Field ID", lineNo);
        end;
        dataExchFldMapping.SetFieldValue(recRef, lastKeyFldId, lineNo * 10000 + lineNoOffset);
        repeat
            dataExchField.Reset();
            dataExchField.SetRange("Data Exch. No.", dataExch."Entry No.");
            dataExchField.SetRange("Data Exch. Line Def Code", dataExchLineDef.Code);
            dataExchField.SetRange("Line No.", lineNo);
            dataExchField.SetRange("Column No.", dataExchFieldMapping."Column No.");
            if (dataExchField.FindFirst()) then
                dataExchFldMapping.SetField(recRef, dataExchFieldMapping, dataExchField, fieldIdsToNegate)
            else
                if (not dataExchFieldMapping.Optional) then
                    Error(missingValueErr,
                      dataExch."File Name",
                      dataExchFldMapping.GetType(dataExch."Data Exch. Def Code"),
                      dataExch."Data Exch. Def Code",
                      lineNo,
                      dataExchFieldMapping."Column No.");
        until dataExchFieldMapping.Next() = 0;

        dataExchFldMapping.NegateAmounts(recRef, fieldIdsToNegate);

        // TODO: I know, it's bad... refactor in later version
        if (not recRef.Insert()) then
            recRef.Modify();

        recRef.Close();
    end;


    procedure GetDataExchFieldValueAsInteger(dataExchEntryNo: Integer; lineNo: Integer; columnNo: Integer) valueAsInt: Integer
    var
        value: Text;
    begin
        value := GetDataExchFieldValueAsText(dataExchEntryNo, lineNo, columnNo);
        if (value.Trim() = '') then
            exit(0);

        if (not Evaluate(valueAsInt, value)) then
            exit(0);

        exit(valueAsInt);
    end;

    procedure GetDataExchFieldValueAsDecimal(dataExchEntryNo: Integer; lineNo: Integer; columnNo: Integer) valueAsDec: Decimal
    var
        value: Text;
    begin
        value := GetDataExchFieldValueAsText(dataExchEntryNo, lineNo, columnNo);
        if (value.Trim() = '') then
            exit(0);

        if (not Evaluate(valueAsDec, value)) then
            exit(0);

        exit(valueAsDec);
    end;

    procedure GetDataExchFieldValueAsDate(dataExchEntryNo: Integer; lineNo: Integer; columnNo: Integer) valueAsDate: Date
    var
        value: Text;
    begin
        value := GetDataExchFieldValueAsText(dataExchEntryNo, lineNo, columnNo);
        if (value.Trim() = '') then
            exit(0D);

        if (not Evaluate(valueAsDate, value)) then
            exit(0D);

        exit(valueAsDate);
    end;

    procedure GetDataExchFieldValueAsText(dataExchEntryNo: Integer; lineNo: Integer; columnNo: Integer): Text
    var
        dataExchField: Record "Data Exch. Field";
    begin
        dataExchField.Reset();
        dataExchField.SetRange("Data Exch. No.", dataExchEntryNo);
        dataExchField.SetRange("Line No.", lineNo);
        dataExchField.SetRange("Column No.", columnNo);
        if (not dataExchField.FindFirst()) then
            exit('');

        exit(dataExchField.GetValue());
    end;

    [IntegrationEvent(false, false)]
    local procedure OnProcessLineDataExchFieldMapping(var recRef: RecordRef; dataExch: Record "Data Exch."; dataExchLineDef: Record "Data Exch. Line Def"; lineNo: Integer; var isHandled: Boolean)
    begin
    end;
}