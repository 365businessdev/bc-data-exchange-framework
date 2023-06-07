pageextension 50001 "bdev.DEF DExch. Line Def. Part" extends "Data Exch Line Def Part"
{
    actions
    {
        addlast(processing)
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
                    dataExchDataView: Page "bdev.DEF Data Exch. Data View";
                begin
                    Clear(dataExchDataView);
                    dataExchDataView.SetDataExchangeLineDefinition(Rec);
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
        dataExchField.SetRange("Data Exch. Line Def Code", Rec.Code);
        ShowDataEnabled := (not dataExchField.IsEmpty());
    end;

    var
        [InDataSet]
        ShowDataEnabled: Boolean;
}