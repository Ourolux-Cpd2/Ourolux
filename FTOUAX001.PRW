#include 'protheus.ch'
#include 'parmtype.ch'

#DEFINE cEnt Chr(10)+ Chr(13)

//--------------------------------------------------------------------
/*/{Protheus.doc} ChkToken
Verifica validade do token
@author Ghidini Consulting
@since 07/02/2020
@version 1.0
/*/
//--------------------------------------------------------------------

User Function ChkToken(cCodSist)

Local cToken    := ""
Local cTempo    := ""
Local cVldMag   := GetMV("FT_TIMEMAG",,"00:30:00")
Local cVldTrp   := GetMV("FT_TIMETRP",,"00:30:00")
Local cLogMag   := GetMV("FT_LOGMAG",,"erp_ouro")
Local cPasMag   := GetMV("FT_PASMAG",,"c#9ZX&k=L8P44-By")
Local lReturn   := .F.
Local oRest
Local aHeader   := {"Content-Type: application/json"}

    DbSelectArea("PR6")
    PR6->(DbSetOrder(1))

    //Busca PR6 pelo codigo do sistmea
    If PR6->(DbSeek(xFilial("PR6") + cCodSist))
    
        //Transpofrete
        If cCodSist == "1"

            cTempo := ElapTime(PR6->PR6_HORA, Time())
            
            // Requisita um novo token
            If cTempo > cVldTrp
                
                //Requisicao do acesso
                oRest := FTOUA003():New()
                oRest:RestConn() 
                
                lReturn := oRest:lRetorno
                
                If lReturn
                    
                    cToken  := oRest:cToken

                    //Grava novo temop PR6
                    PR6->(RecLock("PR6", .F.))
                        
                        PR6->PR6_DATA   := dDataBase
                        PR6->PR6_HORA   := Time()
                        PR6->PR6_TOKEN  := cToken

                    PR6->(MsUnlock())

                EndIf
            
            //Reaproveita token
            Else
                cToken := Alltrim(PR6->PR6_TOKEN)
            EndIf

        //Magento
        ElseIf cCodSist == "2"

            cTempo := ElapTime(PR6->PR6_HORA, Time())
            
            // Requisita um novo token
            If cTempo > cVldMag

                cJson := '{'
                cJson += '"username":"' + cLogMag + '",' 
                cJson += '"password":"' + cPasMag + '"' 
                cJson += '}'
                
                aRequest := U_ResInteg("000022", cJson , aHeader, , .T.,cToken)

                If aRequest[1]
                    
                    cToken := aRequest[2]

                    //Grava novo temop PR6
                    PR6->(RecLock("PR6", .F.))
                        
                        PR6->PR6_DATA   := dDataBase
                        PR6->PR6_HORA   := Time()
                        PR6->PR6_TOKEN  := cToken

                    PR6->(MsUnlock())

                EndIf
            
            //Reaproveita token
            Else
                cToken := Alltrim(PR6->PR6_TOKEN)
            EndIf
        
        EndIf

    //Se não existir a PR6 ainda faz a primeira requisição para popular
    Else

        If cCodSist == "1"

            //Requisicao do acesso
            oRest := FTOUA003():New()
            oRest:RestConn() 
            lReturn := oRest:lRetorno
                
            If lReturn

                cToken  := oREST:cToken
                
                PR6->(RecLock("PR6", .T.))
                    
                    PR6->PR6_SISTEM := cCodSist
                    PR6->PR6_DATA   := dDataBase
                    PR6->PR6_HORA   := Time()
                    PR6->PR6_TOKEN  := cToken
                
                PR6->(MsUnlock())

            EndIf

        ElseIf cCodSist == "2" 

            cJson := '{'
            cJson += '"username":"' + cLogMag + '",' 
            cJson += '"password":"' + cPasMag + '"' 
            cJson += '}'

            aRequest := U_ResInteg("000022", cJson , aHeader, , .T.,cToken)	

            If aRequest[1]

                cToken := aRequest[3]
                
                PR6->(RecLock("PR6", .T.))
                    
                    PR6->PR6_SISTEM := cCodSist
                    PR6->PR6_DATA   := dDataBase
                    PR6->PR6_HORA   := Time()
                    PR6->PR6_TOKEN  := cToken
                
                PR6->(MsUnlock())

            EndIf

        EndIf

    EndIf

Return(cToken)

//--------------------------------------------------------------------
/*/{Protheus.doc} LmpMonit
Limpa as tabelas de log do monitor de integrações.
@author Ghidini Consulting
@since 04/01/2022
@version 1.0
/*/
//--------------------------------------------------------------------

User Function LmpMonit()

Local cQuery := ""
Local cData  := ""

    RpcSetEnv("01","01")

    cAlsQry := CriaTrab(Nil,.F.)
    cData   := MonthSub(dDataBase, 1)
    cData   := DTOS(cData)
    nRecIni := 1

    
    cQuery := " SELECT MAX(PZD.R_E_C_N_O_) TOTAL FROM " + RetSqlName("PZD") + " PZD "
    cQuery += " INNER JOIN " + RetSqlName("PZB") 
    cQuery += " ON PZB_FILIAL = PZD_FILIAL AND PZB_IDURL = PZD_IDURL AND PZB_ID = PZD_IDPROC "
    cquery += " WHERE PZB_FILIAL = ' ' AND PZB_DATA <= '" + cData + "' "

    If Select(cAlsQry) > 0; (cAlsQry)->(dbCloseArea()); Endif
    dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlsQry,.T.,.T.)

    If (cAlsQry)->TOTAL > 0
        nTotalRpt   := (cAlsQry)->TOTAL / 1000000
    EndIf


    cQuery := " DELETE P FROM " + RetSqlName("PZD") + " P "
    cQuery += " INNER JOIN " + RetSqlName("PZB") 
    cQuery += " ON PZB_ID = PZD_IDPROC AND PZB_IDURL = PZD_IDURL "
    cquery += " WHERE PZB_DATA <= '" + cData + "' "

    If TcSqlExec(cQuery) < 0
        cTeste := ""
    EndIf

    cQuery := " DELETE P FROM " + RetSqlName("PZC") + " P "
    cQuery += " INNER JOIN " + RetSqlName("PZB") 
    cQuery += " ON PZB_ID = PZC_IDPROC AND PZB_IDURL = PZC_IDURL "
    cquery += " WHERE PZB_DATA <= '" + cData + "' "

    If TcSqlExec(cQuery) < 0
        cTeste := ""
    EndIf

    cQuery := " DELETE FROM " + RetSqlName("PZB")
    cquery += " WHERE PZB_DATA <= '" + cData + "' "

    If TcSqlExec(cQuery) < 0
        cTeste := ""
    EndIf

Return()
