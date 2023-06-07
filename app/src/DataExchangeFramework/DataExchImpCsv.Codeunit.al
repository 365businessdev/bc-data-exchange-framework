codeunit 50001 "bdev.DEF Data Exch. Imp. - CSV"
{
    Permissions = TableData "Data Exch. Field" = rimd;
    TableNo = "Data Exch.";

    var
        DataExchDef: Record "Data Exch. Def";
        //CsvRegExTok: Label '(?:^|%1)(?=[^"]|(")?)"?((?(1)[^"]*|[^%1"]*))"?(?=%1|$)', Locked = true;
        CsvRegExTok: Label '(?<=^|%1)(?:"((?:[^"]|"")*)"|([^%1]*))(?=%1|$)', Locked = true;

    trigger OnRun()
    var
        stream: InStream;
        lineNo: Integer;
        len: Integer;
        skippedLineNo: Integer;
        readText: Text;
    begin
        DataExchDef.Reset();
        DataExchDef.Get(Rec."Data Exch. Def Code");
        case DataExchDef."File Encoding" of
            DataExchDef."File Encoding"::"MS-DOS":
                Rec."File Content".CreateInStream(stream, TextEncoding::MSDos);
            DataExchDef."File Encoding"::"UTF-8":
                Rec."File Content".CreateInStream(stream, TextEncoding::UTF8);
            DataExchDef."File Encoding"::"UTF-16":
                Rec."File Content".CreateInStream(stream, TextEncoding::UTF16);
            DataExchDef."File Encoding"::WINDOWS:
                Rec."File Content".CreateInStream(stream, TextEncoding::Windows);
        end;

        lineNo := 1;
        repeat
            len := stream.ReadText(readText);
            if len > 0 then
                ParseLine(readText, Rec, lineNo, skippedLineNo);
        until len = 0;
    end;

    local procedure ParseLine(line: Text; dataExch: Record "Data Exch."; var lineNo: Integer; var skippedLineNo: Integer)
    var
        dataExchColumnDef: Record "Data Exch. Column Def";
        dataExchLineDef: Record "Data Exch. Line Def";
    begin
        dataExchLineDef.Reset();
        dataExchLineDef.SetRange("Data Exch. Def Code", dataExch."Data Exch. Def Code");
        dataExchLineDef.FindFirst();

        if ((lineNo + skippedLineNo) <= DataExchDef."Header Lines") or
           ((dataExchLineDef."Data Line Tag" <> '') and (StrPos(line, dataExchLineDef."Data Line Tag") <> 1))
        then begin
            skippedLineNo += 1;

            exit;
        end;

        dataExchColumnDef.Reset();
        dataExchColumnDef.SetRange("Data Exch. Def Code", dataExch."Data Exch. Def Code");
        dataExchColumnDef.SetRange("Data Exch. Line Def Code", dataExchLineDef.Code);
        dataExchColumnDef.FindSet();

        InsertRec(dataExch."Entry No.", lineNo, 0, Format(lineNo), dataExchLineDef.Code);
        repeat
            InsertRec(dataExch."Entry No.", lineNo, dataExchColumnDef."Column No.", line, dataExchLineDef.Code);
        until dataExchColumnDef.Next() = 0;

        lineNo += 1;
    end;

    procedure InsertRec(dataExchEntryNo: Integer; lineNo: Integer; columnNo: Integer; newValue: Text; dataExchLineDefCode: Code[20])
    var
        dataExchField: Record "Data Exch. Field";
        tempGroups: Record Groups temporary;
        tempMatches: Record Matches temporary;
        regEx: Codeunit Regex;
        useRegExValue: Text;
        fieldValue: Text;
    begin
        if (columnNo <> 0) then begin
            useRegExValue := StrSubstNo(CsvRegExTok, DataExchDef.ColumnSeparatorChar());
            regEx.Match(newValue, useRegExValue, tempMatches);

            if (tempMatches.Get(columnNo - 1)) then begin
                regEx.Groups(tempMatches, tempGroups);
                tempGroups.Get(2);
                fieldValue := tempGroups.ReadValue();
                if (fieldValue.Trim() = '') then
                    if (tempGroups.Get(1)) then
                        fieldValue := tempGroups.ReadValue();
            end else
                if (not TryGetFieldValueUsingSplit(fieldValue, newValue, DataExchDef.ColumnSeparatorChar(), columnNo)) then
                    exit; // silently quit
        end else
            fieldValue := newValue;

        fieldValue := fieldValue.Replace('""', '"'); // remove double quotation

        dataExchField.Init();
        dataExchField.Validate("Data Exch. No.", dataExchEntryNo);
        dataExchField.Validate("Line No.", lineNo);
        dataExchField.Validate("Column No.", columnNo);
        dataExchField.SetValueWithoutModifying(fieldValue);
        dataExchField.Validate("Data Exch. Line Def Code", dataExchLineDefCode);
        dataExchField.Insert();
    end;

    [TryFunction]
    local procedure TryGetFieldValueUsingSplit(var fieldValue: Text; newValue: Text; columnSeparatorChar: Text; columnNo: Integer)
    begin
        // try use split function
        fieldValue := newValue.Split(columnSeparatorChar).Get(columnNo).TrimStart('"').TrimEnd('"').Trim();
    end;
}