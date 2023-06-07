tableextension 50000 "bdev.DEF Data Exch. Mapping" extends "Data Exch. Mapping"
{
    fields
    {
        field(50000; "bdev.DEF Data Exch. Entry No."; Integer)
        {
            Caption = 'Data Exchange Entry No.';
            DataClassification = SystemMetadata;
            TableRelation = "Data Exch."."Entry No.";
        }
    }
}