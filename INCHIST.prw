#Include "Protheus.ch"

User Function INCHIST()
    Local cMotivo := Space(TAMSX3("WO_DESC")[1])
    
    DEFINE DIALOG oDlg TITLE "Historico PO" FROM 000,000 TO 150,500 PIXEL
    
    @ 25,10  say "Motivo:" of oDlg Pixel
    @ 24,30 MsGet oGet Var cMotivo  of oDlg Picture "@!" SIZE 200,10 Pixel //
    @ 50,30 BUTTON 'Salvar' SIZE 30,11 PIXEL OF oDlg ACTION (SALHIS(cMotivo), oDlg:End())
    @ 50,80 BUTTON 'Fechar' SIZE 30,11 PIXEL OF oDlg ACTION (oDlg:End())
    @ 50,130 BUTTON 'Historico' SIZE 30,11 PIXEL OF oDlg ACTION (VERHIS())

    ACTIVATE DIALOG oDlg CENTERED
Return 

Static Function SALHIS(cMotivo) 
    If !Empty(cMotivo)
        RecLock("SWO",.T.)
        SWO->WO_FILIAL  := xFilial("SWO")
        SWO->WO_PO_NUM  := SW2->W2_PO_NUM
        SWO->WO_DT      := dDataBase
        SWO->WO_DESC    := Alltrim(cMotivo)
        SWO->WO_USUARIO := UsrRetName(__cUserId)
        SWO->WO_MANUAL  := "S"
        SWO->(MsUnlock())
    EndIf
Return

Static Function VERHIS()
    Local oDlg2   := Nil
    Local oGet    := Nil
    Local aHeader := {}
    Local aCols   := {}
    Local cQuery  := ""

    cQuery := " SELECT * FROM " + RetSqlName("SWO")
    cQuery += " WHERE WO_FILIAL = '"+xFilial("SWO")+"' "
    cQuery += " AND WO_PO_NUM ='"+SW2->W2_PO_NUM+"' "
    cQuerY += " AND WO_MANUAL = 'S' "
    cQuery += " AND D_E_L_E_T_ = '' "
    cQuery += " ORDER BY WO_DT DESC"

    If Select("WOOX") > 0
        WOOX->(dbCloseArea())
    EndIf

    DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery) , 'WOOX', .T., .F.)

    While WOOX->(!EOF())
        AADD(aCols,{STOD(WOOX->WO_DT),WOOX->WO_DESC,WOOX->WO_USUARIO,.F.})
        WOOX->(dbSkip())
    EndDo

    AADD(aHeader,{"Data"	    ,"WOOX_DATA" ,""	,85,0,"","","D","","V"} )
    AADD(aHeader,{"Descricao"	,"WOOX_DESC" ,"@!"	,90,0,"","","C","","V"} )
    AADD(aHeader,{"Usuario"	    ,"WOOX_USER" ,"@!"	,15,0,"","","C","","V"} )

    If !Empty(aCols)
        DEFINE MSDIALOG oDlg2 TITLE "Historico" FROM 005,000 TO 040,150 

        oGet := MsNewGetDados():New(005,005,100,232,0,"","",,,,,,"","",oDlg2,aHeader,aCols)
        oGet:obrowse:align:= CONTROL_ALIGN_ALLCLIENT
        oGet:nAt := oGet:OBROWSE:NAT := 1

        EnchoiceBar(oDlg2, {|| oDlg2:End() },{|| oDlg2:End() },,{} )

        ACTIVATE MSDIALOG oDlg2 CENTERED
	Else
        Alert("Nao existe historico registrado para este PO " + SW2->W2_PO_NUM)
    EndIf	
Return
