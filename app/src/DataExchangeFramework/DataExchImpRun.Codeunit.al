/// <summary>
/// Run data import function based on given Data Exchange Defintion.
/// </summary>
Codeunit 50000 "bdev.DEF Data Exch. Imp. - Run"
{
    TableNo = "Data Exch. Def";

    trigger OnRun()
    begin
        ImportFile(Rec);
    end;

    procedure ImportFile(dataExchDef: Record "Data Exch. Def"): Boolean
    var
        dataExch: Record "Data Exch.";
        dataExchLineDef: Record "Data Exch. Line Def";
        dataExchMapping: Record "Data Exch. Mapping";
        startDateTime: DateTime;
        window: Dialog;
        numberOfLinesImported: Integer;
        progressWindowMsg: Label 'Please wait while the operation is being completed . . .';
    begin
        startDateTime := CurrentDateTime();
        dataExch."Data Exch. Def Code" := dataExchDef.Code;
        if (not dataExch.ImportToDataExch(dataExchDef)) then
            exit(false);

        if (dataExchDef."Validation Codeunit" <> 0) then
            Codeunit.Run(dataExchDef."Validation Codeunit", dataExch);

        if (dataExchDef."Data Handling Codeunit" <> 0) then
            Codeunit.Run(dataExchDef."Data Handling Codeunit", dataExch);

        if (GuiAllowed()) then
            window.Open(progressWindowMsg);

        dataExchLineDef.Reset();
        dataExchLineDef.SetRange("Data Exch. Def Code", dataExchDef.Code);
        dataExchLineDef.FindSet(false);
        repeat
            dataExchMapping.Reset();
            dataExchMapping.SetRange("Data Exch. Def Code", dataExchDef.Code);
            dataExchMapping.SetRange("Data Exch. Line Def Code", dataExchLineDef.Code);
            if (dataExchMapping.FindSet(false)) then
                repeat
                    dataExchMapping."bdev.DEF Data Exch. Entry No." := dataExch."Entry No.";
                    if (dataExchMapping."Pre-Mapping Codeunit" <> 0) then
                        Codeunit.Run(dataExchMapping."Pre-Mapping Codeunit", dataExchMapping);

                    if (dataExchMapping."Mapping Codeunit" <> 0) then
                        Codeunit.Run(dataExchMapping."Mapping Codeunit", dataExchMapping);

                    if (dataExchMapping."Post-Mapping Codeunit" <> 0) then
                        Codeunit.Run(dataExchMapping."Post-Mapping Codeunit", dataExchMapping);
                until dataExchMapping.Next() = 0;
        until dataExchLineDef.Next() = 0;

        if (dataExchDef."User Feedback Codeunit" <> 0) then
            Codeunit.Run(dataExchDef."User Feedback Codeunit", dataExch);

        if (GuiAllowed()) then begin
            window.Close();

            numberOfLinesImported := CountImportedLines(dataExch);
            SendNotificationAfterImport(dataExchDef, numberOfLinesImported, startDateTime, CurrentDateTime());
        end;
        exit(true);
    end;

    procedure SetBatchJnl(newGenJnlBatchName: Code[10])
    begin
        GenJnlBatchName := newGenJnlBatchName; // use this variable to assign Gen. Journal Batch in further processing.
    end;

    local procedure CountImportedLines(var dataExch: Record "Data Exch."): Integer
    var
        DataExchField: Record "Data Exch. Field";
    begin
        DataExchField.SetRange("Data Exch. No.", dataExch."Entry No.");
        DataExchField.SetRange("Data Exch. Line Def Code", dataExch."Data Exch. Line Def Code");
        DataExchField.SetRange("Data Exch. Def Code", dataExch."Data Exch. Def Code");
        if DataExchField.FindLast() then
            exit(DataExchField."Line No.");

        exit(0);
    end;

    local procedure SendNotificationAfterImport(dataExchDef: Record "Data Exch. Def"; numberOfLinesImported: Integer; startDateTime: DateTime; finishDateTime: DateTime)
    var
        notificationLifecycleMgt: Codeunit "Notification Lifecycle Mgt.";
        notificationToSend: Notification;
        importValues: Dictionary of [Text, Text];
        importDuration: Duration;
        importValue: Text;
        sb: TextBuilder;
        importStartTimeLbl: Label 'Started at: %1', Comment = '%1 = Value';
        importFinishTimeLbl: Label 'Finished at: %1', Comment = '%1 = Value';
        importDurationLbl: Label 'Duration: %1', Comment = '%1 = Value';
        numberOfLinesLbl: Label 'No. of imported Lines: %1', Comment = '%1 = Value';
    begin
        notificationToSend.Id(CreateGuid());
        importDuration := finishDateTime - startDateTime;
        importValues.Add('ImportStartTime', StrSubStNo(importStartTimeLbl, startDateTime));
        importValues.Add('ImportFinishTime', StrSubstNo(importFinishTimeLbl, finishDateTime));
        importValues.Add('ImportDuration', StrSubstNo(importDurationLbl, importDuration));
        importValues.Add('NumberOfLines', StrSubstNo(numberOfLinesLbl, numberOfLinesImported));

        foreach importValue in importValues.Values() do begin
            sb.Append(importValue);
            sb.Append(', ');
        end;

        notificationToSend.Message(sb.ToText().Trim().TrimEnd(','));
        notificationToSend.Scope(NotificationScope::LocalScope);
        notificationLifecycleMgt.SendNotification(notificationToSend, dataExchDef.RecordId());
    end;

    var
        GenJnlBatchName: Code[10];
}