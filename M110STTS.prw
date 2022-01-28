#INCLUDE "PROTHEUS.CH"
#INCLUDE "AP5MAIL.CH"
#Include "TOPCONN.CH"

User Function M110STTS()
    Local nOpt          := Paramixb[2]
    //Local aArray        := {}
    Local cQuery        := ""
    Private lMsErroAuto := .F.
 
    If nOpt == 3     
        WFKillProcess( Alltrim(SC1->C1_WFID) )

        cQuery := " SELECT ZAE_FILIAL, ZAE_NUMSC, ZAE_DTENTR, ZAE_CT40HC, ZAE_CT40DR, ZAE_CT40RF, ZAE_CT20DR, ZAE_CT20RF, ZAE_DTCOTM, R_E_C_N_O_ "
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

    If nOpt == 3 .OR. nOpt == 2
        DbSelectArea("SE2") 
        DbSetOrder(1)

        cQuery := " SELECT E2_FILIAL, E2_PREFIXO, E2_NUM, E2_PARCELA, E2_TIPO, E2_FORNECE, E2_LOJA FROM " + RetSqlName("SE2")
        cQuery += " WHERE E2_FILIAL = '"+xFilial("SE2")+"' "
        cQuery += " AND E2_PREFIXO = 'SC' "
        cQuery += " AND E2_TIPO = 'PR' "
        cQuery += " AND E2_NUM = '"+SC1->C1_FILIAL+SC1->C1_NUM+"' "
        cQuery += " AND D_E_L_E_T_ = '' "

        If Select("PRSC") > 0
            PRSC->(dbCloseArea())
        EndIf

        DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery) , 'PRSC', .T., .F.)

        While PRSC->(!EOF())
            If SE2->(DbSeek(PRSC->E2_FILIAL+PRSC->E2_PREFIXO+PRSC->E2_NUM+PRSC->E2_PARCELA+PRSC->E2_TIPO+PRSC->E2_FORNECE+PRSC->E2_LOJA)) //Exclusão deve ter o registro SE2 posicionado
                Reclock("SE2",.f.)
                SE2->(DBDELETE())
                SE2->(MSUNLOCK())
                //aArray := { { "E2_PREFIXO" , SE2->E2_PREFIXO , NIL },;
                //            { "E2_NUM"     , SE2->E2_NUM     , NIL } }
            
                //MsExecAuto( { |x,y,z| FINA050(x,y,z)}, aArray,, 5)  // 3 - Inclusao, 4 - Alteração, 5 - Exclusão
            
                //If lMsErroAuto
                //    MostraErro()
                //Else
                //    Alert("Exclusão do Título com sucesso!")
                //Endif
            EndIf
            PRSC->(dbSkip())
        EndDo	
    EndIf
     
Return Nil
