#INCLUDE "PROTHEUS.CH"
#INCLUDE "AP5MAIL.CH"
#Include "TOPCONN.CH"

User Function M110STTS()
Local nOpt      := Paramixb[2]
 
If nOpt == 3     
    WFKillProcess( Alltrim(SC1->C1_WFID) )

    cQuery := " SELECT ZAE_FILIAL, ZAE_NUMSC, ZAE_DTENTR, ZAE_CT40HC, ZAE_CT40DR, ZAE_CT40RF, ZAE_CT20DR, ZAE_CT20RF, ZAE_DTCOTM, ZAE_DTCOTR, R_E_C_N_O_ "
    cQuery += " FROM " + RetSqlName("ZAE")
    cQuery += " WHERE ZAE_FILIAL = '"+SC1->C1_FILIAL+"' "
    cQuery += " AND ZAE_NUMSC = '"+SC1->C1_NUM+"' "
    cQuery += " AND D_E_L_E_T_ = '' "
    
    If Select("TCSX") > 0
        TCSX->(dbCloseArea())
    EndIf

    DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery) , 'TCSX', .T., .F.)
            
    While TCSX->(!EOF())
        ZAE->(dbGoTo(TCSX->R_E_C_N_O_))
        RecLock("ZAE", .F.)
        ZAE->(dbDelete())
        ZAE->(MsUnlock())
        TCSX->(dbSkip())
    EndDo

EndIf
     
Return Nil
