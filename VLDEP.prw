#Include "Protheus.ch"

User Function VLDEP(cDesp)
    Local cQuery  := ""
    Local lRet    := .T.
    Default cDesp := ""

    If Alltrim(cDesp) == "R"
        cQuery := " SELECT COUNT(*) AS TOTAL FROM " + RetSqlName("SYB")
        cQuery += " WHERE YB_FILIAL = '"+xFilial("SYB")+"' "
        cQuery += " AND YB_XGRCAPA = '"+Alltrim(cDesp)+"' "
        cQuery += " AND D_E_L_E_T_ = '' "

        If Select("YBX") > 0
            YBX->(dbCloseArea())
        EndIf

        DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery) , 'YBX', .T., .F.)

        If YBX->TOTAL > 0
            Alert("Não é permitido mais do que uma despesa Reciclus")
            lRet := .F.
        EndIf
    EndIf
Return lRet
