#INCLUDE "PROTHEUS.CH"
#INCLUDE "AP5MAIL.CH"

User Function M110STTS()
Local nOpt      := Paramixb[2]
 
If nOpt == 3     
    WFKillProcess( Alltrim(SC1->C1_WFID) )
EndIf
     
Return Nil
