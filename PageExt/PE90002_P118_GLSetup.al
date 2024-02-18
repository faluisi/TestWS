pageextension 90002 FBM_GLSetupExt_WS extends "General Ledger Setup"
{
    actions
    {
        addlast(processing)
        {
            action(CallWS)
            {
                ApplicationArea = all;
                Promoted = true;
                PromotedIsBig = true;
                PromotedCategory = Process;
                trigger
                OnAction()
                var
                    cu: codeunit HttpClientExample;
                begin
                    Codeunit.Run(90002);
                    //cu.GetData();
                end;

            }

        }

    }
}