#Include "Totvs.Ch"
#Include "topconn.Ch"
#Include "Restful.Ch"
#INCLUDE "FILEIO.CH"

Static aHdlLock  := {}
//Static bFileLock := {|| MakeDir(GetMv("TI_VGMLOCK",,"\lockTRANSPOFRETE\")), Alltrim(GetMv("TI_VGMLOCK",,"\lockTRANSPOFRETE\")) + "SRV" + Alltrim(cIdServ) + ".LCK" }
Static bFileLock := {|| MakeDir("\lockTRANSPOFRETE\"), Alltrim("TI_VGMLOCK") + "SRV" + Alltrim(cIdServ) + ".LCK" }

//-------------------------------------------------------------------
/*/{Protheus.doc} ResInteg
Processa a requisição via rest.

@author By Wise

@since 29/09/2018
/*/
//-------------------------------------------------------------------

User function ResInteg(cIdServ, cJson, aHeader, aParGet, lObjJson, cParamUrl, nOpcMet)

Local aRet          := {"","",""} //Posição 1 indica o sucesso da requisição, Posição 2 traz o retorno da requisição em objeto, 3 json de retorno em string
Local cUrl          := ""
Local cMetodo       := ""
Local oRest
Local cResult       := ""    
Local nRetParser    := 0
Local aJSonField    := {}
Local oJson
Local cParam        := ""
Local cTipMet       := ""
Local cHeaderRet    := ""
Local nTimeOut      := GetMv("TI_VGMTOUT",,8) //Seta o tempo de timeout

Default aHeader     := {}
Default aParGet     := {}
Default cJson       := {}
Default lObjJson    := .F.
Default cParamUrl   := ""
Default nOpcMet     := 1

    DbSelectArea("PZA")
    PZA->(DbSetOrder(1))

    If PZA->(MsSeek(xFilial("PZA") + cIdServ))

        cUrl    := Alltrim(PZA->PZA_URL)
        
        //Case para selecionar o metodo passado por parametro
        Do Case

            Case nOpcMet == 1
        		cMetodo := Alltrim(PZA->PZA_ENDPOI)
                cTipMet := PZA->PZA_TIPMET

            Case nOpcMet == 2
                cMetodo := Alltrim(PZA->PZA_SEGEND)
                cTipMet := PZA->PZA_SEGTIP
            
            Case nOpcMet == 3
                cMetodo := Alltrim(PZA->PZA_TEREND)
                cTipMet := PZA->PZA_TERTIP
            
            Case nOpcMet == 4
                cMetodo := Alltrim(PZA->PZA_QUAEND)
                cTipMet := PZA->PZA_QUATIP
            
            Case nOpcMet == 5
                cMetodo := Alltrim(PZA->PZA_QUIEND)
                cTipMet := PZA->PZA_QUITIP

        EndCase

        //Case para realizar o tipo de requisição preenchido.
        Do case

            Case cTipMet == "1" //Get

                If Len(aParGet) > 0
                    cParam := fStrGet(aParGet)
                Else
                    cParam := cParamUrl
                EndIf
                
                //Monta objeto para consumo
                oRest := FWREST():New(cUrl + cMetodo)
                
                //Seta parametros
                oRest:SetPath(cParam)
                
                lRet := oRest:Get(aHeader)

                //Verifico se existe conteudo de retorno
                If oRest:GetResult() == Nil
                    aRet[1] := .F.
                    aRet[2] := "Falha na conexão com a URL."
                Else
                    cResult := oRest:GetResult()

					If DecodeUtf8(cResult) <> Nil
                    	cResult := DecodeUtf8(cResult)
	                EndIf
					
				EndIf

                //Caso tenha sucesso
                If lRet
                    If lObjJson
                        aJsonfields := {}
                        lRet := FWJsonDeserialize(cResult,@oJson)
                        If ! lRet
                            aRet[1] := .F.
                        Else
                            aRet[2] := oJson
                            aRet[1] := .T.
							aRet[3] := cResult
                        Endif 
                    Else
                        oJSon := TJSonParser():New()
                        oJSon:Json_Parser( cResult /*strJson*/,Len( cResult ) /*lenStrJson*/, @aJSonField /*@jsonfields*/, @nRetParser /*@nRetParser*/ )
                        aRet[2] := aJSonField
                        aRet[1] := .T.
						aRet[3] := cResult
                    EndIf 
               
                Else
                    aRet[1] := .F.
                    aRet[2] := oRest:GetLastError()
					aRet[3] := cResult
                EndIf

            Case cTipMet == "2" //Post

                //Monta objeto rest
                oRest := FWREST():New(cUrl)
                
                //Seta endpoint
                oRest:SetPath(cMetodo+cParamUrl)

                //Seta o JSON como parametro
				If EncodeUtf8(cJson) <> Nil
                    cJson := EncodeUtf8(cJson)
                EndIf

                oRest:SetPostParams(cJson)
                
                //Controla o tempo de timeout do processamento do post
                //oRest:nTimeOut := nTimeOut
                        
                //Realizo o Post do JSON
                lRet := oRest:Post(aHeader)
 
                //Verifico se existe conteudo de retorno
                If oRest:GetResult() == Nil
                    aRet[1] := .F.
                    aRet[2] := "Falha na conexão com a URL."
                    cResult := oRest:GetLAstError()
                    cResult := DecodeUtf8(cResult)
                    FWJsonDeserialize( cResult ,@oJSon)
                Else
                    cResult := oRest:GetResult()
                    If Empty(cResult) 
                    	If Upper(oRest:getlasterror()) == "204 NOCONTENT" .Or. Upper(oRest:getlasterror()) == "200 OK"
                    		lRet := .T.
                    		cResult := '{"resultado": "OK"}'
                    	EndIf
                    Else
	                    If DecodeUtf8(cResult) <> Nil
	                        cResult := DecodeUtf8(cResult)
	                    EndIf
						FWJsonDeserialize( cResult ,@oJSon)
					EndIf
                EndIf

                //Caso tenha sucesso
                If lRet
                    aRet[1] := .T.
                    aRet[2] := oJSon
					aRet[3] := cResult	
                Else
                    aRet[1] := .F.
                    aRet[2] := oJSon
					aRet[3] := cResult
                EndIf

            Case cTipMet == "3" //Put
            
            	//Monta objeto rest
                oRest := FWREST():New(cUrl)
                
                //Seta endpoint
                oRest:SetPath(cMetodo+cParamUrl)

                //Seta o JSON como parametro
				If EncodeUtf8(cJson) <> Nil
                    cJson := EncodeUtf8(cJson)
                EndIf

                lRet := oRest:Put(aHeader,cJson)
 
                //Verifico se existe conteudo de retorno
                If oRest:GetResult() == Nil
                    aRet[1] := .F.
                    aRet[2] := "Falha na conexão com a URL."
                    cResult := oRest:GetLAstError()
                    cResult := DecodeUtf8(cResult)
                    FWJsonDeserialize( cResult ,@oJSon)
                Else
                    cResult := oRest:GetResult()
                    If Empty(cResult) 
                    	If Upper(oRest:getlasterror()) == "204 NOCONTENT" .Or. Upper(oRest:getlasterror()) == "200 OK"
                    		lRet := .T.
                    		cResult := '{"resultado": "OK"}'
                        ElseIf Upper(oRest:getlasterror()) 
                            lRet := .F.
                    		cResult := '{"resultado": "Falha na autorização do token."}'
                    	EndIf
                    Else
	                    If DecodeUtf8(cResult) <> Nil
	                        cResult := DecodeUtf8(cResult)
	                    EndIf
						FWJsonDeserialize( cResult ,@oJSon)
					EndIf
                EndIf

                //Caso tenha sucesso
                If lRet
                    aRet[1] := .T.
                    aRet[2] := oJSon
					aRet[3] := cResult	
                Else
                    aRet[1] := .F.
                    aRet[2] := oJSon
					aRet[3] := cResult
                EndIf

            Case cTipMet == "4" //Path
                                // JULIO VIEIRA
                cRet := HTTPQuote ( cUrl+cMetodo+cParamUrl, "PATCH", ,cJson, 120, aHeader, @cHeaderRet ) 

                if !empty(cHeaderRet)
                    aResponse := strtokarr(cHeaderRet,CRLF)
                    if !( '204 No Content' $ aResponse[1] ) .and. !( '200 OK' $ aResponse[1] )
                        aRet[1] := .F.
                        aRet[2] := 'Error: ' + aResponse[1]
                        aRet[3] := cRet
                    else
                        cResult := DecodeUtf8(cRet)
                        FWJsonDeserialize( cResult ,@oJSon)
                         aRet[1] := .T.
                         aRet[2] := oJSon
					     aRet[3] := cHeaderRet
                    endif
                else
                    cRet := 'Error: Falha na requisicao, nao foi possivel obter o retorno.'
                      aRet[1] := .F.
                      aRet[2] := cRet
                      aRet[3] := cHeaderRet
                endif 
 
            Case cTipMet == "5" //Delete

                If Len(aParGet) > 0
                    cParam := fStrGet(aParGet)
                Else
                    cParam := cParamUrl
                EndIf

                //Monta objeto para consumo
                oRest := FWREST():New(cUrl + cMetodo)
                
                //Seta parametros
                oRest:SetPath(cParam)

                //Seta o JSON como parametro
                oRest:SetPostParams(cJson)
                
                lRet := oRest:Delete(aHeader)

                //Verifico se existe conteudo de retorno
                If oRest:GetResult() == Nil
                    aRet[1] := .F.
                    aRet[2] := "Falha na conexão com a URL."
                Else
                    if oRest:getlasterror() == "204 NoContent" .Or. oRest:getlasterror() == "200 OK"
                       lRet := .T.
                       cResult := '{"resultado": "OK"}'
                    else
                        cResult := oRest:GetResult()
						                    
                    If DecodeUtf8(cResult) <> Nil
                        cResult := DecodeUtf8(cResult)
                    EndIf
                    
                    endif
                EndIf

                //Caso tenha sucesso
                If lRet
                    If lObjJson
                        aJsonfields := {}
                        lRet := FWJsonDeserialize(cResult,@oJson)
                        If ! lRet
                            aRet[1] := .F.
                        Else
                            aRet[2] := oJson
                            aRet[1] := .T.
							aRet[3] := cResult
                        Endif 
                    Else
                        oJSon := TJSonParser():New()
                        oJSon:Json_Parser( cResult /*strJson*/,Len( cResult ) /*lenStrJson*/, @aJSonField /*@jsonfields*/, @nRetParser /*@nRetParser*/ )
                        aRet[2] := aJSonField
                        aRet[1] := .T.
						aRet[3] := cResult
                    EndIf 
               
                Else
                    
                    //O metodo em caso de falha retorna erros genericos, então pego o JSON do resultado mesmo para tratar o erro.
                    oJSon := TJSonParser():New()
                    oJSon:Json_Parser( cResult /*strJson*/,Len( cResult ) /*lenStrJson*/, @aJSonField /*@jsonfields*/, @nRetParser /*@nRetParser*/ )

                    aRet[1] := .F.
                    aRet[2] := aJSonField
					aRet[3] := cResult
                    
                EndIf


        EndCase
    
    Else

        cMenssagem := "Id do serviço enviado não foi encontrado no cadastro de serviços."
        aRet[1] := .F.

        If lObjJson
            If FWJsonDeserialize('{"message":"' + cMenssagem + '"}',@oJson)
                aRet[2] := oJson
            EndIf
        Else
            aRet[2] := {{"message",cMenssagem}}
        EndIf

        aRet[3] := cMenssagem
        
    EndIf

Return(aRet)

//------------------------------------------------------------------------------
/*/{Protheus.doc} MonitRes
Função de atualização do monitor de integração.

@param  cIdServ, string, recebe id de cadastro na tabela PZA
        nOpc, boolean, 1 = inclusão, 2 = alteração / atualização
        aDados, array, contem os dados para os registros
        nQtdReg, boolean, contem a quantidade total de registros a processar.

@author By Wise

@since 29/09/2018
/*/
//------------------------------------------------------------------------------

User function MonitRes(cIdServ, nOpc, nQtdReg, cPZBId, cObserv, lSucess, cChave, cJsoEnv, cJsoRec, cDesChave, lReprocess, lLote, cPZCId, lExcec, lAutentic, lAjusCont)

Local aRet          := {"",""}
Local cFileLock     := Eval(bFileLock)
Local cIdPZB        := ""
Local cIdPZC        := ""
Local cIdPZD        := ""
Local cStatusPZC    := ""
Local cStatusPZD    := ""
Local cHoraFim      := ""
Local cTime         := ""
Local nSecIni       := 0
Local nSecFim       := 0
Local nHrIni        := 0
Local nHrFim        := 0
Local nMinIni       := 0
Local nMinFim       := 0
Local nPosLock      := 0
Local nTotHor       := 0
Local nTotMin       := 0
Local nTotSec       := 0

Default cIdServ     := ""
Default nOpc        := 0
Default nQtdReg     := 0
Default cPZBId      := ""
Default cObserv     := ""
Default lSucess     := .T.
Default cChave      := ""
Default cJsoEnv     := ""
Default cJsoRec     := ""
Default cDesChave   := ""
Default cPZCId      := ""
Default lLote       := .F.
Default lReprocess  := .F.
Default lExcec      := .F.
Default lAutentic   := .F.
Default lAjusCont   := .T.

nPosLock := aScan(aHdlLock,{|a| a[1] == cIdServ})

If cIdServ == "000020"
    Conout("===============================")
    Conout("Job........: 000020")
    ConOut("Função.....: U_MonitRes")
    ConOut("Called from: " + ProcName(1))
    ConOut("Line.......: " + Alltrim(Alltochar(Procline(1))))
    Conout("===============================")
EndIf

If nPosLock == 0
    aAdd(aHdlLock,{cIdServ,-1})
    nPosLock := Len(aHdlLock)
EndIf

    DbSelectArea("PZA")
    PZA->(DbSetOrder(1))

    If PZA->(MsSeek(xFilial("PZA") + cIdServ))

        //Inclusão
        If nOpc == 1

            If !File(cFileLock)
                aHdlLock[nPosLock][2] := FCreate(cFileLock)
            Else
                aHdlLock[nPosLock][2] := FOpen(cFileLock, FO_READWRITE + FO_EXCLUSIVE)
            Endif

            //Adquiri o próximo id de processamento para o serviço.
            cId := fGerIdPZB(cIdServ)

            RecLock("PZB",.T.)

                PZB->PZB_FILIAL := xFilial("PZB")
                PZB->PZB_IDURL  := cIdServ
                PZB->PZB_ID     := cId
                PZB->PZB_HORA   := Time()
                PZB->PZB_DATA   := dDataBase
                PZB->PZB_REGTOT := nQtdReg
                PZB->PZB_STATUS := "E" //Em andamento

            MsUnlock()

            aRet[1] := .T.
            aRet[2] := cId

        //Alimenta monitor
        ElseIf nOpc == 2

            DbSelectArea("PZB")
            PZB->(DbSetOrder(1))

            If PZB->(MsSeek(xFilial("PZB") + cIdServ + cPZBId ))

                PZB->(RecLock("PZB",.F.))

                    If !lReprocess .Or. (lReprocess .And. lLote)
                    	PZB->PZB_REGPRO := PZB->PZB_REGPRO + 1
                    EndIf
                    
                    If lExcec
                        PZB->PZB_REGEXC := PZB->PZB_REGEXC + 1
                    ElseIf !lSucess
                        PZB->PZB_REGERR := PZB->PZB_REGERR + 1
                    EndIf

                PZB->(MsUnlock())
                
            EndIf

            //Geração da PZC
            If !lReprocess .Or. (lReprocess .And. lLote)

                //Gera próximo ID da PZC
                cIdPZC      := fPZCId(cPZBId, cIdServ)
                
                If lExcec
                    cStatusPZC  := "E"
                Else    
                    cStatusPZC  := IIf(lSucess,"S","F")
                EndIf

                //Efetua a gravação da PZC
                RecLock("PZC", .T.)

                    PZC->PZC_FILIAL := xFilial("PZC")
                    PZC->PZC_IDPROC := cPZBId
                    PZC->PZC_ID     := cIdPZC
                    PZC->PZC_CHAVE  := cChave
                    PZC->PZC_STATUS := cStatusPZC
                    PZC->PZC_DESCHV := cDesChave
                    PZC->PZC_IDURL  := cIdServ

                MsUnlock()

            //Se for reprocessamento atualiza o status da PZC.
            Else

                cStatusPZC  := IIf(lExcec,"E", IIf(lSucess,"S","F"))
                cIdPZC := cPZCId
            
                DbSelectArea("PZC")
                PZC->(DbSetOrder(1))

                If PZC->(MsSeek(xFilial("PZC") + cPZBId + cIdPZC))

                    PZC->(RecLock("PZC",.F.))

                        PZC->PZC_STATUS := cStatusPZC

                    PZC->(MsUnlock())

                EndIf
            
            EndIf

            //Gera sequencial para a PZD
            cIdPZD      := fPZDId(cPZBId, cIdPZC, cIdServ)
            cStatusPZD  := IIf(lExcec,"E", IIf(lSucess,"S","F"))

            cObserv := U_fNoAcento(cObserv)

            //Efetua a gravação da PZD
            RecLock("PZD", .T.)

                PZD->PZD_FILIAL := xFilial("PZD")
                PZD->PZD_IDPROC := cPZBId
                PZD->PZD_IDREG  := cIdPZC
                PZD->PZD_ID     := cIdPZD
                PZD->PZD_HORA   := Time()
                PZD->PZD_DESC   := cObserv
                PZD->PZD_JSOENV := cJsoEnv
                PZD->PZD_JSOREC := cJsoRec
                PZD->PZD_STATUS := cStatusPZD
                PZD->PZD_IDURL  := cIdServ

            MsUnlock()

        ElseIf nOpc == 3 //Conclusão

            DbSelectArea("PZB")
            PZB->(DbSetOrder(1))

            If PZB->(MsSeek(xFilial("PZB") + cIdServ + cPZBId ))

                cHoraFim := Time()

                PZB->(RecLock("PZB",.F.))

                    //Se chegou a processar registros
                    If lSucess
                        PZB->PZB_STATUS := IIf(PZB->PZB_REGERR > 0, "F", "S")
                        PZB->PZB_MENSAG := "Processamento concluido."
                    Else
                        PZB->PZB_STATUS := "F"
                        PZB->PZB_MENSAG := IIf(lAutentic, "Falha no login com o TRANSPOFRETE.", "Processamento falhou.")
                    EndIf
                
                    //nHrFim  := Val(Left(cHoraFim,2))
                    //nHrIni  := Val(Left(PZB->PZB_HORA,2))

                    //nMinFim := Val(Substr(cHoraFim,4,2))
                    //nMinIni := Val(Substr(PZB->PZB_HORA,4,2))

                    //    nSecFim := Val(Right(cHoraFim,2))
                    //    nSecIni := Val(Right(PZB->PZB_HORA,2))
                        
                    //Monta totalizadores
                    //nTotHor := nHrFim - nHrIni
                    //nTotMin := nMinFim - nMinIni
                    //nTotSec := nSecFim - nSecIni

                    //Variavel da hora
                    //cTime := StrZero(nTotHor,2) + ":" + StrZero(nTotMin,2) + ":" + StrZero(nTotSec,2)

                    PZB->PZB_TEMPO := ElapTime(PZB->PZB_HORA,cHoraFim )// cTime
                	
                	// Realiza ajuste dos contadores de processamento
                	If lAjusCont
                		PZB->PZB_REGTOT := PZB->PZB_REGPRO
                	Endif	
                
                PZB->(MsUnlock())

            EndIf

            If File(cFileLock)
                If FClose(aHdlLock[nPosLock][2])
                    aHdlLock[nPosLock][2] := -1
                    FErase(cFileLock)
                EndIf
            Endif

        EndIf

    Else
        aRet[1] := .F.
        aRet[2] := "Id de serviço informado não foi encontrado na tabela PZA."
    EndIf
    
Return(aRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} fGerIdPZB
Função para gerar próximo Id para a PZB para o serviço informado.

@author By Wise
@since  30/09/201
@version 1.0
/*/
//-------------------------------------------------------------------

Static function fGerIdPZB(cIdServ)

Local cSeque    := ""
Local cQuery    := ""
Local cAlsQry   := CriaTrab(Nil,.F.)

    cQuery := " SELECT MAX(PZB_ID) SEQUEN "
    cQuery += " FROM " + RetSqlName("PZB") + " PZB "
    cQuery += " WHERE PZB_FILIAL = '" + xFilial("PZB") + "' AND "
    cQuery += " PZB_IDURL = '" + cIdServ + "' AND PZB.D_E_L_E_T_ = ' ' "

    If Select(cAlsQry) > 0; (cAlsQry)->(dbCloseArea()); Endif  
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlsQry,.T.,.T.)

    If (cAlsQry)->(Eof())
        cSeque := "000001"
    Else
        cSeque := Soma1( (cAlsQry)->SEQUEN )
    EndIf

    (cAlsQry)->(dbCloseArea())

Return(cSeque)

//-------------------------------------------------------------------
/*/{Protheus.doc} fPZCId
Função para gerar próximo Id para a PZC para o processo informado.

@author By Wise
@since 30/09/201
@version 1.0
/*/
//-------------------------------------------------------------------

Static function fPZCId(cIdPzb, cIdUrl)

Local cSeque    := ""
Local cQuery    := ""
Local cAlsQry   := CriaTrab(Nil,.F.)

    cQuery := " SELECT MAX(PZC_ID) SEQUEN "
    cQuery += " FROM " + RetSqlName("PZC") + " PZC "
    cQuery += " WHERE PZC_FILIAL = '" + xFilial("PZC") + "' AND "
    cQuery += " PZC_IDURL = '" + cIdUrl + "' AND PZC_IDPROC = '" + cIdPzb + "' AND PZC.D_E_L_E_T_ = ' ' "

    If Select(cAlsQry) > 0; (cAlsQry)->(dbCloseArea()); Endif  
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlsQry,.T.,.T.)

    If (cAlsQry)->(Eof())
        cSeque := "000001"
    Else
        cSeque := Soma1( (cAlsQry)->SEQUEN )
    EndIf

    (cAlsQry)->(dbCloseArea())

Return(cSeque)

//-------------------------------------------------------------------
/*/{Protheus.doc} fPZDId
Função para gerar próximo Id para a PZD de acordo com o codigo de log
informado + codigo do registro.

@author By Wise
@since 30/09/2018
@version 1.0
/*/
//-------------------------------------------------------------------

Static function fPZDId(cIdPZB, cIdPZC, cIdUrl)

Local cSeque    := ""
Local cQuery    := ""
Local cAlsQry   := CriaTrab(Nil,.F.)

    cQuery := " SELECT MAX(PZD_ID) SEQUEN "
    cQuery += " FROM " + RetSqlName("PZD") + " PZD "
    cQuery += " WHERE PZD_FILIAL = '" + xFilial("PZD") + "' AND "
    cQuery += " PZD_IDURL = '" + cIdUrl + "' AND PZD_IDPROC = '" + cIdPZB + "' AND PZD_IDREG = '" + cIdPZC + "' "
    cQuery += " AND PZD.D_E_L_E_T_ = ' ' "

    If Select(cAlsQry) > 0; (cAlsQry)->(dbCloseArea()); Endif  
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlsQry,.T.,.T.)

    If (cAlsQry)->(Eof())
        cSeque := "000001"
    Else
        cSeque := Soma1( (cAlsQry)->SEQUEN )
    EndIf

    (cAlsQry)->(dbCloseArea())

Return(cSeque)

//-------------------------------------------------------------------
/*/{Protheus.doc} fNoAcento
Função para tratar mensagem de observação.

@author By Wise
@since 30/09/2018
@version 1.0
/*/
//-------------------------------------------------------------------

User function fNoAcento(cRetorno)

Local nX        := 0
Local aSubst    := {    {"á","a"},;
                        {"â","a"},;
                        {"ã","a"},;
                        {"à","a"},;
                        {"Á","a"},;
                        {"Â","a"},;
                        {"Ã","a"},;
                        {"À","a"},;
                        {"é","e"},;
                        {"ê","e"},;
                        {"è","e"},;
                        {"í","i"},;
                        {"î","i"},;
                        {"ì","i"},;
                        {"ó","o"},;
                        {"ô","o"},;
                        {"õ","o"},;
                        {"ò","o"},;
                        {"ú","u"},;
                        {"ù","u"},;
                        {"û","u"},;
                        {"ç","c"},;
                        {"{","" },;
                        {"}","" },;
                        {'"','' } }

    //Trata mensagem de retorno
    For nX := 1 to len(aSubst)

        cRetorno := StrTran(cRetorno, aSubst[nX][1], aSubst[nX][2])

    Next nX

    cRetorno := Alltrim(cRetorno)
           
Return(cRetorno)

//-------------------------------------------------------------------
/*/{Protheus.doc} MaxIdRes
Busca o ID maximo da tabela informada.

@author By Wise

@since 29/09/2018
/*/
//-------------------------------------------------------------------

User Function MaxIdRes(cTabela, cCampo)

Local cQuery    := ""
Local cAlsId    := CriaTrab(Nil,.F.)
Local cMaxId    := ""

    cQuery := " SELECT MAX(" + cCampo + ") MAXID "
    cQuery += " FROM " + RetSqlname(cTabela) + " " + cTabela
    cQuery += " WHERE " + cTabela + ".D_E_L_E_T_ = ' ' "

    If Select(cAlsId) > 0; (cAlsId)->(dbCloseArea()); Endif  
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlsId,.T.,.T.)

    If (cAlsId)->(Eof())
        cMaxId := "000001"
    Else
        cMaxId := Soma1( (cAlsId)->MAXID )
    EndIf

    (cAlsId)->(dbCloseArea())

Return(cMaxId)

//-------------------------------------------------------------------
/*/{Protheus.doc} IsSrvLck
Verifica se o servico esta em processamento
@author  By Wise
@since   16/01/2019
@version V12
/*/
//-------------------------------------------------------------------
User Function IsSrvLck(cIdServ)
Local cFileLock := Eval(bFileLock)
Local nHdlLock  := 0
Local lLocked   := .T.

If File(cFileLock)
    nHdlLock := FOpen(cFileLock, FO_READWRITE + FO_EXCLUSIVE)
    If nHdlLock > 0
        lLocked := .F.
        FClose(nHdlLock)
    EndIf
Else
    lLocked := .F.
EndIf

Return lLocked
