page 50002 "bdev.DEF Data Exch. Data View"
{
    Caption = 'Data Exchange Data View';
    PageType = List;
    UsageCategory = None;
    SourceTable = Integer;
    InsertAllowed = false;
    DeleteAllowed = false;
    ModifyAllowed = false;
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field(ColumnHeader1; ColumnValue[1])
                {
                    CaptionClass = ColumnHeader[1];
                    ToolTip = 'Specifies the value of Column 1 from the Data Exch. Column Definition.';
                    ApplicationArea = All;
                    Visible = ColumnVisible1;
                }
                field(ColumnHeader2; ColumnValue[2])
                {
                    CaptionClass = ColumnHeader[2];
                    ToolTip = 'Specifies the value of Column 2 from the Data Exch. Column Definition.';
                    ApplicationArea = All;
                    Visible = ColumnVisible2;
                }
                field(ColumnHeader3; ColumnValue[3])
                {
                    CaptionClass = ColumnHeader[3];
                    ToolTip = 'Specifies the value of Column 3 from the Data Exch. Column Definition.';
                    ApplicationArea = All;
                    Visible = ColumnVisible3;
                }
                field(ColumnHeader4; ColumnValue[4])
                {
                    CaptionClass = ColumnHeader[4];
                    ToolTip = 'Specifies the value of Column 4 from the Data Exch. Column Definition.';
                    ApplicationArea = All;
                    Visible = ColumnVisible4;
                }
                field(ColumnHeader5; ColumnValue[5])
                {
                    CaptionClass = ColumnHeader[5];
                    ToolTip = 'Specifies the value of Column 5 from the Data Exch. Column Definition.';
                    ApplicationArea = All;
                    Visible = ColumnVisible5;
                }
                field(ColumnHeader6; ColumnValue[6])
                {
                    CaptionClass = ColumnHeader[6];
                    ToolTip = 'Specifies the value of Column 6 from the Data Exch. Column Definition.';
                    ApplicationArea = All;
                    Visible = ColumnVisible6;
                }
                field(ColumnHeader7; ColumnValue[7])
                {
                    CaptionClass = ColumnHeader[7];
                    ToolTip = 'Specifies the value of Column 7 from the Data Exch. Column Definition.';
                    ApplicationArea = All;
                    Visible = ColumnVisible7;
                }
                field(ColumnHeader8; ColumnValue[8])
                {
                    CaptionClass = ColumnHeader[8];
                    ToolTip = 'Specifies the value of Column 8 from the Data Exch. Column Definition.';
                    ApplicationArea = All;
                    Visible = ColumnVisible8;
                }
                field(ColumnHeader9; ColumnValue[9])
                {
                    CaptionClass = ColumnHeader[9];
                    ToolTip = 'Specifies the value of Column 9 from the Data Exch. Column Definition.';
                    ApplicationArea = All;
                    Visible = ColumnVisible9;
                }
                field(ColumnHeader10; ColumnValue[10])
                {
                    CaptionClass = ColumnHeader[10];
                    ToolTip = 'Specifies the value of Column 10 from the Data Exch. Column Definition.';
                    ApplicationArea = All;
                    Visible = ColumnVisible10;
                }
                field(ColumnHeader11; ColumnValue[11])
                {
                    CaptionClass = ColumnHeader[11];
                    ToolTip = 'Specifies the value of Column 11 from the Data Exch. Column Definition.';
                    ApplicationArea = All;
                    Visible = ColumnVisible11;
                }
                field(ColumnHeader12; ColumnValue[12])
                {
                    CaptionClass = ColumnHeader[12];
                    ToolTip = 'Specifies the value of Column 12 from the Data Exch. Column Definition.';
                    ApplicationArea = All;
                    Visible = ColumnVisible12;
                }
                field(ColumnHeader13; ColumnValue[13])
                {
                    CaptionClass = ColumnHeader[13];
                    ToolTip = 'Specifies the value of Column 13 from the Data Exch. Column Definition.';
                    ApplicationArea = All;
                    Visible = ColumnVisible13;
                }
                field(ColumnHeader14; ColumnValue[14])
                {
                    CaptionClass = ColumnHeader[14];
                    ToolTip = 'Specifies the value of Column 14 from the Data Exch. Column Definition.';
                    ApplicationArea = All;
                    Visible = ColumnVisible14;
                }
                field(ColumnHeader15; ColumnValue[15])
                {
                    CaptionClass = ColumnHeader[15];
                    ToolTip = 'Specifies the value of Column 15 from the Data Exch. Column Definition.';
                    ApplicationArea = All;
                    Visible = ColumnVisible5;
                }
                field(ColumnHeader16; ColumnValue[16])
                {
                    CaptionClass = ColumnHeader[16];
                    ToolTip = 'Specifies the value of Column 16 from the Data Exch. Column Definition.';
                    ApplicationArea = All;
                    Visible = ColumnVisible16;
                }
                field(ColumnHeader17; ColumnValue[17])
                {
                    CaptionClass = ColumnHeader[17];
                    ToolTip = 'Specifies the value of Column 17 from the Data Exch. Column Definition.';
                    ApplicationArea = All;
                    Visible = ColumnVisible17;
                }
                field(ColumnHeader18; ColumnValue[18])
                {
                    CaptionClass = ColumnHeader[18];
                    ToolTip = 'Specifies the value of Column 18 from the Data Exch. Column Definition.';
                    ApplicationArea = All;
                    Visible = ColumnVisible18;
                }
                field(ColumnHeader19; ColumnValue[19])
                {
                    CaptionClass = ColumnHeader[19];
                    ToolTip = 'Specifies the value of Column 19 from the Data Exch. Column Definition.';
                    ApplicationArea = All;
                    Visible = ColumnVisible19;
                }
                field(ColumnHeader20; ColumnValue[20])
                {
                    CaptionClass = ColumnHeader[20];
                    ToolTip = 'Specifies the value of Column 20 from the Data Exch. Column Definition.';
                    ApplicationArea = All;
                    Visible = ColumnVisible20;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(ProcessData)
            {
                Caption = 'Process Data';
                ToolTip = 'Run the specified Data Handling Codeunit to process the data.';
                Image = DataEntry;
                ApplicationArea = All;

                Enabled = ProcessDataEnabled;

                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;

                trigger OnAction()
                var
                    dataExchDef: Record "Data Exch. Def";
                    startDateTime: DateTime;
                begin
                    dataExchDef.Get(DataExchLineDef."Data Exch. Def Code");
                    if (dataExchDef."Data Handling Codeunit" = 0) then
                        exit;

                    startDateTime := CurrentDateTime();
                    Codeunit.Run(dataExchDef."Data Handling Codeunit", DataExch);
                    SendNotificationAfterProcessing(dataExchDef, startDateTime, CurrentDateTime());
                end;
            }
        }
    }


    local procedure SendNotificationAfterProcessing(dataExchDef: Record "Data Exch. Def"; startDateTime: DateTime; finishDateTime: DateTime)
    var
        notificationLifecycleMgt: Codeunit "Notification Lifecycle Mgt.";
        notificationToSend: Notification;
        processingValues: Dictionary of [Text, Text];
        processingDuration: Duration;
        processingValue: Text;
        sb: TextBuilder;
        processingStartTimeLbl: Label 'Started at: %1', Comment = '%1 = Value';
        processingFinishTimeLbl: Label 'Finished at: %1', Comment = '%1 = Value';
        processingDurationLbl: Label 'Duration: %1', Comment = '%1 = Value';
    begin
        notificationToSend.Id(CreateGuid());
        processingDuration := finishDateTime - startDateTime;
        processingValues.Add('ImportStartTime', StrSubStNo(processingStartTimeLbl, startDateTime));
        processingValues.Add('ImportFinishTime', StrSubstNo(processingFinishTimeLbl, finishDateTime));
        processingValues.Add('ImportDuration', StrSubstNo(processingDurationLbl, processingDuration));

        foreach processingValue in processingValues.Values() do begin
            sb.Append(processingValue);
            sb.Append(', ');
        end;

        notificationToSend.Message(sb.ToText().Trim().TrimEnd(','));
        notificationToSend.Scope(NotificationScope::LocalScope);
        notificationLifecycleMgt.SendNotification(notificationToSend, dataExchDef.RecordId());
    end;

    trigger OnOpenPage()
    begin
        if (not DataExchLineDefIsSet) then
            Error(PageMustBeInitializedWithDataExchDefRecordErr);

        PopulateDataView();
    end;

    trigger OnAfterGetRecord()
    begin
        GetDataExchFieldDataForLineNo(Rec.Number);
    end;

    local procedure PopulateDataView()
    var
        dataExchDef: Record "Data Exch. Def";
        dataExchColumnDef: Record "Data Exch. Column Def";
        dataExchField: Record "Data Exch. Field";
        columnNo: Integer;
    begin
        Rec.SetRange(Number, 0);
        ResetColumnVisiblity();
        if (not DataExchLineDefIsSet) then
            exit;

        if (DataExch."Entry No." = 0) then
            DataExch := SelectDataExch();

        dataExchDef.Get(DataExchLineDef."Data Exch. Def Code");
        ProcessDataEnabled := (dataExchDef."Data Handling Codeunit" <> 0);

        dataExchColumnDef.Reset();
        dataExchColumnDef.SetRange("Data Exch. Def Code", DataExchLineDef."Data Exch. Def Code");
        dataExchColumnDef.SetRange("Data Exch. Line Def Code", DataExchLineDef.Code);
        if (not dataExchColumnDef.FindSet(false)) then
            exit;

        columnNo := 1;
        repeat
            ColumnHeader[columnNo] := dataExchColumnDef.Name;
            case columnNo of
                1:
                    ColumnVisible1 := true;
                2:
                    ColumnVisible2 := true;
                3:
                    ColumnVisible3 := true;
                4:
                    ColumnVisible4 := true;
                5:
                    ColumnVisible5 := true;
                6:
                    ColumnVisible6 := true;
                7:
                    ColumnVisible7 := true;
                8:
                    ColumnVisible8 := true;
                9:
                    ColumnVisible9 := true;
                10:
                    ColumnVisible10 := true;
                11:
                    ColumnVisible11 := true;
                12:
                    ColumnVisible12 := true;
                13:
                    ColumnVisible13 := true;
                14:
                    ColumnVisible14 := true;
                15:
                    ColumnVisible15 := true;
                16:
                    ColumnVisible16 := true;
                17:
                    ColumnVisible17 := true;
                18:
                    ColumnVisible18 := true;
                19:
                    ColumnVisible19 := true;
                20:
                    ColumnVisible20 := true;
            end;

            columnNo += 1;
        until (dataExchColumnDef.Next() = 0) or ((columnNo >= 20));

        dataExchField.Reset();
        dataExchField.SetRange("Data Exch. No.", DataExch."Entry No.");
        dataExchField.SetRange("Data Exch. Def Code", DataExchLineDef."Data Exch. Def Code");
        dataExchField.SetRange("Data Exch. Line Def Code", DataExchLineDef.Code);
        if (not dataExchField.FindLast()) then
            exit;
        Rec.SetRange(Number, 1, dataExchField."Line No.");
    end;

    local procedure SelectDataExch() selectedDataExch: Record "Data Exch."
    var
        dataExchList: Page "bdev.DEF Data Exch. List";
    begin
        selectedDataExch.Reset();
        selectedDataExch.FilterGroup(2);
        selectedDataExch.SetRange("Data Exch. Def Code", DataExchLineDef."Data Exch. Def Code");
        selectedDataExch.SetRange("Data Exch. Line Def Code", DataExchLineDef.Code);
        selectedDataExch.FilterGroup(0);

        Clear(dataExchList);
        dataExchList.LookupMode(true);
        dataExchList.SetTableView(selectedDataExch);
        if (dataExchList.RunModal() <> Action::LookupOK) then
            Error('');

        dataExchList.GetRecord(selectedDataExch);
    end;

    local procedure GetDataExchFieldDataForLineNo(lineNo: Integer)
    var
        dataExchColumnDef: Record "Data Exch. Column Def";
        dataExchField: Record "Data Exch. Field";
        columnNo: Integer;
    begin
        if (not DataExchLineDefIsSet) then
            exit;

        dataExchColumnDef.Reset();
        dataExchColumnDef.SetRange("Data Exch. Def Code", DataExchLineDef."Data Exch. Def Code");
        dataExchColumnDef.SetRange("Data Exch. Line Def Code", DataExchLineDef.Code);
        if (not dataExchColumnDef.FindSet(false)) then
            exit;

        columnNo := 1;
        repeat
            // clear column value
            ColumnValue[columnNo] := '';
            dataExchField.Reset();
            dataExchField.SetRange("Data Exch. No.", DataExch."Entry No.");
            dataExchField.SetRange("Data Exch. Def Code", DataExchLineDef."Data Exch. Def Code");
            dataExchField.SetRange("Data Exch. Line Def Code", DataExchLineDef.Code);
            dataExchField.SetRange("Line No.", lineNo);
            dataExchField.SetRange("Column No.", dataExchColumnDef."Column No.");
            if (dataExchField.FindFirst()) then
                ColumnValue[columnNo] := dataExchField.GetValue();

            columnNo += 1;
        until dataExchColumnDef.Next() = 0;

    end;

    local procedure ResetColumnVisiblity()
    begin
        ColumnVisible1 := false;
        ColumnVisible2 := false;
        ColumnVisible3 := false;
        ColumnVisible4 := false;
        ColumnVisible5 := false;
        ColumnVisible6 := false;
        ColumnVisible7 := false;
        ColumnVisible8 := false;
        ColumnVisible9 := false;
        ColumnVisible10 := false;
        ColumnVisible11 := false;
        ColumnVisible12 := false;
        ColumnVisible13 := false;
        ColumnVisible14 := false;
        ColumnVisible15 := false;
        ColumnVisible16 := false;
        ColumnVisible17 := false;
        ColumnVisible18 := false;
        ColumnVisible19 := false;
        ColumnVisible20 := false;
    end;

    procedure SetDataExchangeLineDefinition(newDataExchDef: Record "Data Exch. Line Def")
    begin
        DataExchLineDef := newDataExchDef;
        DataExchLineDefIsSet := true;
    end;

    procedure SetDataExchangeEntryNo(entryNo: Integer)
    begin
        DataExch.Get(entryNo);
    end;

    var
        DataExch: Record "Data Exch.";
        DataExchLineDef: Record "Data Exch. Line Def";
        ColumnHeader: array[20] of Text;
        ColumnValue: array[20] of Text;
        [InDataSet]
        ColumnVisible1, ColumnVisible2, ColumnVisible3, ColumnVisible4, ColumnVisible5, ColumnVisible6, ColumnVisible7, ColumnVisible8, ColumnVisible9, ColumnVisible10, ColumnVisible11, ColumnVisible12, ColumnVisible13, ColumnVisible14, ColumnVisible15, ColumnVisible16, ColumnVisible17, ColumnVisible18, ColumnVisible19, ColumnVisible20 : Boolean;
        ProcessDataEnabled: Boolean;
        DataExchLineDefIsSet: Boolean;
        PageMustBeInitializedWithDataExchDefRecordErr: Label 'This page must be initialized by passing a valid Data Exch. Def. Record.';
}