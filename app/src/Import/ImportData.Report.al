report 50000 "bdev.DEF Import Data"
{
    Caption = 'Import Data';
    UsageCategory = Tasks;
    ApplicationArea = All;
    ProcessingOnly = true;

    requestpage
    {
        layout
        {
            area(Content)
            {
                group(DataExchangeDefinition)
                {
                    Caption = 'Data Exchange Definition';
                    field(DataExchDefCodeCtrl; DataExchDefCode)
                    {
                        Caption = 'Data Exchange Definition';
                        ToolTip = 'Specifies the data exchange definition of the file you want to import into Microsoft Dynamics 365 Business Central.';
                        ApplicationArea = All;
                        TableRelation = "Data Exch. Def".Code;
                        ShowMandatory = true;
                        NotBlank = true;

                        trigger OnValidate()
                        begin
                            DataExchDef.Get(DataExchDefCode);
                        end;
                    }
                }
                group(GenJnlBatchSelection)
                {
                    Caption = 'Gen. Journal Selection';
                    Visible = GenJnlBatchSelectionVisible;

                    field(GenJnlBatchNameCtrl; GenJnlBatchName)
                    {
                        Caption = 'Gen. Journal Batch';
                        ToolTip = 'Specifies the general journal batch name to import the data into.';
                        ApplicationArea = All;
                        TableRelation = "Gen. Journal Batch".Name;
                        Editable = false;
                    }
                }
            }
        }

        trigger OnOpenPage()
        begin
            GenJnlBatchSelectionVisible := (GenJnlBatchName <> '');
        end;
    }

    trigger OnPreReport()
    var
        dataExchImportRun: Codeunit "bdev.DEF Data Exch. Imp. - Run";
    begin
        DataExchDef.Get(DataExchDefCode);
        if (GenJnlBatchName <> '') then
            dataExchImportRun.SetBatchJnl(GenJnlBatchName);
        dataExchImportRun.Run(DataExchDef);
    end;

    procedure SetGenJnlBatchName(newGenJnlBatchName: Code[10])
    begin
        GenJnlBatchName := newGenJnlBatchName;
    end;

    procedure SetDataExchDefCode(newDataExchDefCode: Code[20])
    begin
        DataExchDefCode := newDataExchDefCode;
    end;

    var
        DataExchDef: Record "Data Exch. Def";
        GenJnlBatchSelectionVisible: Boolean;
        GenJnlBatchName: Code[10];
        DataExchDefCode: Code[20];
}