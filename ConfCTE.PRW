#INCLUDE 	"PROTHEUS.CH"
#INCLUDE	"TOTVS.CH"
#INCLUDE 	"RWMAKE.CH"
#INCLUDE 	"TBICONN.CH"

User Function ConfCte()

Local aHeader := {}
Local nX
Local dDtCort   := ""
Local lWhile    := .T.

    RpcSetEnv("01","01")

    dDtCort   := CTOD("08/05/2020")

    AADD(aHeader, "Content-Type: application/json")     

    While lWhile

        //Requisicao do acesso
        oREST := FTOUA003():New()
        oREST:RESTConn() 
        lReturn := oRest:lRetorno
        cToken  := oREST:cToken

        If !lReturn
            Exit
        EndIf

        //Requisição das ctes
        aRequest := U_ResInteg( "000009", , aHeader, , .T., cToken )		

        If !aRequest[1]
            Exit
        EndIf
        
        // RETORNO DA TRANSPOFRETE
        If aRequest[1]

            aCtes := aRequest[2]:CTES

            For nX := 1 to len(aCtes)

                cJson := '{'
                cJson += '"cte":' + cValToChar(aCtes[nX])
                cJson += '}'

                oRest := FWREST():New(GetMV("FT_OUA004B",,"http://ws.transpofrete.com.br/api"))
                oRest:SetPath("/cte/recuperarDados?token="+cToken)
                If (cEncode := EncodeUtf8(cJson)) <> Nil
                    cJson := cEncode
                EndIf
                oRest:SetPostParams(cJson)
                lRet := oRest:Post(aHeader)
                
                cJsoRec := oRest:GetResult()

                oJson := JsonObject():New()
                oJson:FromJson(cJsoRec)

                If cJsoRec == Nil 
			    	
                    Loop
                    
                    If Empty(cJsoRec) 
                        Loop
                    EndIf

                EndIf
                
                cNumero	:= cValToChar(oJson:GetJSonObject('ctes')[1]:GetJSonObject('numero'))
                cChave	:= oJson:GetJSonObject('ctes')[1]:GetJSonObject('chave')
                cSerie	:= oJson:GetJSonObject('ctes')[1]:GetJSonObject('serie')
                cCNPJCf := oJson:GetJSonObject('ctes')[1]:GetJSonObject('cnpjEmissor')
                cEmissao := StrTran(Left(oJson:GetJSonObject('ctes')[1]:GetJSonObject('dataEmissao'),10),"-","")
                cEmissao := STOD(cEmissao)

                If dDtCort > cEmissao

                    cJson := '{'
                    cJson += '"numero": "' + cNumero + '",'
                    cJson += '"serie": "' + cSerie + '",'
                    cJson += '"cnpjEmissor": "' + cCNPJCf + '",'
                    cJson += '"statusIntegracao": 2,'
                    cJson += '"codigoMensagem": 2,'
                    cJson += '"mensagem": "data de emissão é anterior ao Go-Live."'
                    cJson += '}'

                    // INFORMAR A TRANSPOFRETE INTEGRACAO XML 
                    aRequest := U_ResInteg("000011", cJson , aHeader, , .T.,cToken)

                Else
                    lWhile := .F.
                    Exit

                EndIf

            Next nX

        EndIf

    End

Return()