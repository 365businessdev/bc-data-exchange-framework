page 50003 "bdev.DEF Data Exch. List"
{
    Caption = 'Data Exchange List';
    PageType = List;
    UsageCategory = None;
    SourceTable = "Data Exch.";
    InsertAllowed = false;
    ModifyAllowed = false;

    layout
    {
        area(Content)
        {
            repeater(DataExchEntries)
            {
                field("Entry No."; Rec."Entry No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Entry No. of the Data Exchange.';
                }
                field("File Name"; Rec."File Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the File Name of the Data Exchange.';
                }
                field(SystemCreatedAt; Rec.SystemCreatedAt)
                {
                    ApplicationArea = All;
                    Caption = 'Created at';
                    ToolTip = 'Specifies the Entry No. of the Data Exchange.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(ShowData)
            {
                ApplicationArea = All;
                Caption = 'Show Data';
                Ellipsis = true;
                Image = Table;
                ToolTip = 'Opens the data view for the currently selected Data Exchange Line Definition.';
                Enabled = ShowDataEnabled;

                trigger OnAction()
                var
                    dataExchLineDef: Record "Data Exch. Line Def";
                    dataExchDataView: Page "bdev.DEF Data Exch. Data View";
                begin
                    dataExchLineDef.Get(Rec."Data Exch. Def Code", Rec."Data Exch. Line Def Code");

                    Clear(dataExchDataView);
                    dataExchDataView.SetDataExchangeLineDefinition(dataExchLineDef);
                    dataExchDataView.SetDataExchangeEntryNo(Rec."Entry No.");
                    dataExchDataView.RunModal();
                end;
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        ToogleShowDataActionEnabled();
    end;

    local procedure ToogleShowDataActionEnabled()
    var
        dataExchField: Record "Data Exch. Field";
    begin
        dataExchField.Reset();
        dataExchField.SetRange("Data Exch. Def Code", Rec."Data Exch. Def Code");
        dataExchField.SetRange("Data Exch. Line Def Code", Rec."Data Exch. Line Def Code");
        dataExchField.SetRange("Data Exch. No.", Rec."Entry No.");
        ShowDataEnabled := (not dataExchField.IsEmpty());
    end;

    var
        [InDataSet]
        ShowDataEnabled: Boolean;
}