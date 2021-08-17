#include "protheus.ch"

User Function EICFI400

Local aArea  := SYB->(GetArea())
Local cParam := ""

Begin Sequence    
   IF Type("ParamIXB") == "C"
      cParam := ParamIXB
   Endif                
   
   Do Case 
      Case cParam == "FI400INCTIT"
         IF "SWD" $ cOrigem
            IF Type("cDespRdm") <> "C"
               cDespRdm := ""
            Endif
            IF Empty(cDespRdm) .And. Type("M->WD_DESPESA") == "C"
               cDespRdm := M->WD_DESPESA
            Endif
         
            SYB->(dbSetOrder(1))
            SYB->(dbSeek(xFilial()+cDespRdm))
            
            M->E2_HIST    := "Proc. "+Alltrim(SW6->W6_HAWB)+" -"+Alltrim(SYB->YB_DESCR)
            M->E2_HAWBEIC := SW6->W6_HAWB
         Endif
            
   End Case

End Sequence

SYB->(RestArea(aArea))

Return
