pageextension 50000 "bdev.DEF Data Exch. Def. Card" extends "Data Exch Def Card"
{
    actions
    {
        addlast(Navigation)
        {
            action(ImportFile)
            {
                ApplicationArea = All;
                Caption = 'Import File';
                Ellipsis = true;
                Image = Import;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                ToolTip = 'Start the process of importing a txt or csv file, based on the current generic import definition.';
                Enabled = Rec.Type = Rec.Type::"Generic Import";

                trigger OnAction()
                begin
                    Codeunit.Run(Codeunit::"bdev.DEF Data Exch. Imp. - Run", Rec);
                end;
            }
        }
    }
}