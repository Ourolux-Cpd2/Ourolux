#INCLUDE 	"PROTHEUS.CH"
#INCLUDE	"TOTVS.CH"
#INCLUDE 	"RWMAKE.CH"
#INCLUDE 	"TBICONN.CH"

// #################################################################################################################
// Projeto: OUROLUX - PROJETO TRANSPOFRETE
// Modulo : Rotina p/ verificar se contem CTE disponivel para integração com Protheus - Integraçãoo API REST/JSON
// Fonte  : FTOUA004
// ---------+-------------------+-----------------------------------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+-----------------------------------------------------------------------------------
// 14/08/19 | Roberto Marques   | Classe para conexÃ£o Ã  API TranspoFrete
// ---------+-------------------+-----------------------------------------------------------------------------------

User Function TESTE004()

	U_FTOUA004(.F.,.F.,"","","01","01")
	
Return(Nil)


User Function FTOUA004(lReprocess, lLote, cIdReg, cIdPZC, cEmpPrep, cFilPrep)

Local aHeader		:= {}
Local cToken 		:= ""
Local cIdPZB    	:= ""
Local aCriaServ		:= {}
Local aRequest		:= {}
Local cCHAVE		:= ""
Local oRet			:= Nil
Local cCTE			:= ""
Local cSerie		:= ""
Local cCNPJEmi		:= ""
Local cPastaXML		:= "\TRANSPO\XML\"
Local nRet 			:= 0
Local cArqRet    	:= ""
Local nHdl       	    
Local cError   		:= ""
Local cWarning 		:= ""
Local oXml 			:= NIL		
Local nX			:= 0
Local nQtdReg		:= 0

Default lLote		:= .F.
Default lReprocess	:= .F.
Default cIdReg		:= ""
Default cIdPZC		:= ""	

	RpcSetEnv(cEmpPrep, cFilPrep)

	dDtCort := GetMV("FT_OUA004C",,CTOD("09/05/2020"))
 
 	 /// VERIFICAR SE EXISTEM AS PASTAS PARA INTEGRACAO DO CTE - TRANSPOFRETE
 	 if !ExistDir('\TRANSPO')
 	 
 	 	nRet := MakeDir( "\TRANSPO" )
  		If nRet != 0
    		conout( "Não foi possível criar o diretório. Erro: " + cValToChar( FError() ) )
  		Endif

 	 	nRet := MakeDir( "\TRANSPO\XML" )
  		If nRet != 0
    		conout( "Não foi possível criar o diretório. Erro: " + cValToChar( FError() ) )
  		Endif
  		
 	Endif	
 	 	
	AADD(aHeader, "Content-Type: application/json")     
	    
	//Requisição do acesso
	cToken := U_ChkToken("1")

	If Empty(cToken)
        
        Conout("Falha na autenticação Transpofrete")
        
    Else
				 
		DBSelectArea("PR1")
	       
		//Requisição das ctes
		//aRequest := U_ResInteg( "000005", , aHeader, , .T., cToken )		
		 
		//Requisição das ctes
		aRequest := U_ResInteg( "000009", , aHeader, , .T., cToken )		
		
		// RETORNO DA TRANSPOFRETE
		If aRequest[1]

			aCtes := aRequest[2]:CTES

			nQtdReg := Len(aCtes)
 			
			If !Empty(cIds := GetMV("FT_OUA004A",,""))
				
				aCtes := Strtokarr2(cIds,";")
				
				For nX := 1 To Len(aCtes)
					
					aCtes[nX] := Val(aCtes[nX])
					
				Next
				
			Endif
			
			If Len(aCtes) > 0
		    			
				//Inicia o processo
				aCriaServ := U_MonitRes("000005", 1, nQtdReg)
				cIdPZB 	  := aCriaServ[2]
				
			Else
				
		    	If GetMV("FT_CONOUTX",,.T.)
		    		
		    		Conout(ProcName(0) + " - " + DToC(Date()) + " - " + Time() + " - Não há dados para processamento.")
		    		
		    	Endif
		    	
			Endif
			
			For nX := 1 to len(aCtes)
				
				cCte := cValToChar(aCtes[nX])
				
				cMenssagem  := "Integrando CTE: " + cCte
				
				//Retorno em forma de objeto
				oRet     := aRequest[2]
				
				//Retorno em forma de string
				cJsoRec := aRequest[3]

				cJson := '{'
				cJson += '"cte":' + cCte
	   			cJson += '}'
				
	   			//**************************************************************
				//aRequest := U_ResInteg("000005",_cJSon, aHeader, , .T.,cToken)
				//**************************************************************
				// error log no FWJSONSERIALIZE - monitor de integrações	
				// Exceção Ocorrida :  invalid macro source (SSYacc0105e: Error token failed, no valid token):(__oObj:1) (1783)
				// Pilha de Chamadas : 
				// 	FWJSONSERIALIZE.PRW (1783)
				// 	FWJSONSERIALIZE.PRW (1801)
				// 	FWJSONSERIALIZE.PRW (1775)
				// 	FWJSONSERIALIZE.PRW (1801)
				// 	FWJSONSERIALIZE.PRW (1775)
				// 	FWJSONSERIALIZE.PRW (1801)
				// 	FWJSONSERIALIZE.PRW (1775)
				// 	FWJSONSERIALIZE.PRW (320)
				// 	TFINX200.PRW (171)
				// 	FTOUA004.PRW (83)
				//**************************************************************
				
				//If aRequest[1] == .T.
				
				lRestOK := .F.
				oRest := FWREST():New(GetMV("FT_OUA004B",,"http://ws.transpofrete.com.br/api"))
			    oRest:SetPath("/cte/recuperarDados?token="+cToken)
				If (cEncode := EncodeUtf8(cJson)) <> Nil
			        cJson := cEncode
			    EndIf
			    oRest:SetPostParams(cJson)
			    lRet := oRest:Post(aHeader)
			    
			    cJsoRec := oRest:GetResult()
			    
			    If cJsoRec != Nil
			    	If !Empty(cJsoRec) 
						oJson := JsonObject():New()
						ret := oJson:FromJson(cJsoRec)
					    if ValType(ret) == "C"
					    	U_MonitRes("000005", 2, , cIdPZB,"Falha na conversão do JSON - Método recuperarDados",.F.,cChave,cJson,cJsoRec, cChave, lReprocess, lLote, cIdPZC)
					    Else 
					    	lRestOK := .T.
				    	endif
			    	Else
			    		U_MonitRes("000005", 2, , cIdPZB,"Retorno JSON vazio - Método recuperarDados",.F.,cChave,cJson,cJsoRec, cChave, lReprocess, lLote, cIdPZC)
			    	Endif
			    Else
			    	U_MonitRes("000005", 2, , cIdPZB,"Falha ao obter JSON - GetResult() - Método recuperarDados",.F.,cChave,cJson,cJsoRec, cChave, lReprocess, lLote, cIdPZC)
			    Endif
				
				If lRestOK
					//Retorno em forma de objeto
					//oJson   := aRequest[2]
					////Retorno em forma de string
					//cJsoRec := aRequest[3]
					////GRAVANDO O LOG DA CONFIRMAÇÃO 
					
					// PEGAR A CHAVE DA CTE 
					//cNumero	:= cValToChar(aRequest[2]:CTES[1]:NUMERO)
					//cChave	:= aRequest[2]:CTES[1]:CHAVE
					//cSerie	:= aRequest[2]:CTES[1]:SERIE
					
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

						Loop

					EndIf

					//Se a chave não vier preenchida, pula o reigstro
					If cChave == Nil
						
						cMenssagem := "Chave na NFE não preenchida no Transpofrete"

						//GRAVANDO O LOG DA CONFIRMAÇÃO	
						U_MonitRes("000005", 2, , cIdPZB, cMenssagem, .F., cNumero, cJson, cJsoRec, cNumero, lReprocess, lLote, cIdPZC)

						cJson := '{'
						cJson += '"numero": "' + cNumero + '",'
						cJson += '"serie": "' + cSerie + '",'
						cJson += '"cnpjEmissor": "' + cCNPJCf + '",'
						cJson += '"statusIntegracao": 2,'
						cJson += '"codigoMensagem": 2,'
						cJson += '"mensagem": "CTE sem chave, por tanto não pode ser importada."'
						cJson += '}'
					
						// INFORMAR A TRANSPOFRETE INTEGRACAO XML 
						aRequest := U_ResInteg("000011", cJson , aHeader, , .T.,cToken)	
						
						Loop

					EndIf
					
					FreeObj(oJson)
					
					// PEGAR XML DA CTE
					aRequest := U_ResInteg("000010", , aHeader, , .F.,cChave+'?token='+cToken)	
			
					If aRequest[1] == .T.

						//Retorno em forma de objeto
						oRet     := aRequest[2]
						
						//Retorno em forma de string
						cJsoRec := aRequest[3]
						
						//GRAVANDO O LOG DA CONFIRMAÇÃO 
						oXml := XmlParser( cJsoRec, "_", @cError, @cWarning ) 
						
						if oXML <> Nil
							cCNPJEmi := oXml:_CTEPROC:_CTE:_INFCTE:_EMIT:_CNPJ:TEXT
						Else
							cMenssagem := "CTE não encontrada no TranspoFrete."

							//GRAVANDO O LOG DA CONFIRMAÇÃO	
							U_MonitRes("000005", 2, , cIdPZB, cMenssagem, .F., cChave, cJson, cJsoRec, cChave, lReprocess, lLote, cIdPZC)

							//Paliativo para cofirmar e pular.

							cJson := '{'
							cJson += '"numero": "' + cNumero + '",'
							cJson += '"serie": "' + cSerie + '",'
							cJson += '"cnpjEmissor": "' + cCNPJCf + '",'
							cJson += '"statusIntegracao": 2,'
							cJson += '"codigoMensagem": 2,'
							cJson += '"mensagem": "CTE sem xml no portal, sendo assim foi confirmado sem ser integrado."'
							cJson += '}'
						
							// INFORMAR A TRANSPOFRETE INTEGRACAO XML 
							aRequest := U_ResInteg("000011", cJson , aHeader, , .T.,cToken)	


							Loop
						Endif   
						
						cArqRet	:= cPastaXML+AllTRIM(cCHAVE)+".XML"
							
						nHdl := fCreate( cArqRet )

						fWrite( nHdl, cJsoRec)
						
						fClose( nHdl )
					
						cJson := '{'
						cJson += '"numero": "' + cNumero + '",'
						cJson += '"serie": "' + cSerie + '",'
						cJson += '"chave": "' + cChave + '",'
						cJson += '"cnpjEmissor": "' + cCNPJEmi + '",'
						cJson += '"statusIntegracao": 0,'
						cJson += '"codigoMensagem": 0,'
						cJson += '"mensagem": "Integracao CTE XML com sucesso"'
						cJson += '}'
					
						// INFORMAR A TRANSPOFRETE INTEGRACAO XML 
						aRequest := U_ResInteg("000011", cJson , aHeader, , .T.,cToken)	
					
						// RETORNO DA TRANSPOFRETE
						If aRequest[2]:status == "CONFIRMADO"

							cMenssagem := "CTE integrada com sucesso."

							U_MonitRes("000005", 2, , cIdPZB, cMenssagem, .T., cChave, cJson, cJsoRec, cChave, lReprocess, lLote, cIdPZC)
							
							//INICIO PROCESSO DE IMPORTACAO CTE
							PR1->(dbSetOrder(2))
							
							If !PR1->(dbSeek(xFilial("PR1")+"SF1"+xFilial("PR1")+cCTE))
							
								PR1->(RecLock("PR1",.T.))
							
									PR1->PR1_FILIAL := xFilial("PR1")
									PR1->PR1_ALIAS  := "SF1"
									PR1->PR1_TIPREQ := "1"
									PR1->PR1_DATINT := Date()
									PR1->PR1_HRINT	:= Time()		
									PR1->PR1_STINT  := "P"
									PR1->PR1_CHAVE  := xFilial("SF1") + cCTE
									PR1->PR1_OBSERV	:= cChave
							
								PR1->(MsUnlock())
							
							Endif
							
							PR1->(RecLock("PR1",.F.))
							
								PR1->PR1_RECNO  := SF1->(RECNO())
								
							PR1->(MsUnlock())
							
						Else
						
							//--------------------------------------------------------------
							// INFORMAR A TRANSPOFRETE OCORREU ERROR .
							//--------------------------------------------------------------
							
							cJson	:= '{'
							cJson	+= '"numero": "'+Alltrim(Str(cCTE))+'",'
							cJson	+= '"serie": "'+cSerie+'",'
							cJson	+= '"chave": "'+cChave+'",'
							cJson	+= '"cnpjEmissor": "'+cCNPJEmi+'",'
							cJson	+= '"statusIntegracao":2,'
							cJson	+= '"codigoMensagem":5,'
							cJson	+= '"mensagem": "CTE - Erro de integração"'
							cJson	+= '}'
								
							aRequest := U_ResInteg("000011",cJson , aHeader, , .T.,cToken)
								
							cMenssagem  := "CTE nao confirmada como integrada."
							
							//Retorno em forma de objeto
							oRet     := aRequest[2]
							
							//Retorno em forma de string
							cJsoRec := aRequest[3]
							
							//GRAVANDO O LOG DA CONFIRMAÇÃO	
							U_MonitRes("000005", 2, , cIdPZB, cMenssagem, .F., cChave, cJson, cJsoRec, cChave, lReprocess, lLote, cIdPZC)
							
						Endif

					Else

						cMenssagem := "Erro ao confirmar CTE junto a Transpofrete."

						//GRAVANDO O LOG DA CONFIRMAÇÃO	
						U_MonitRes("000005", 2, , cIdPZB, cMenssagem, .F., cChave, cJson, cJsoRec, cChave, lReprocess, lLote, cIdPZC)

					EndIf

				Else

					cMenssagem := "Falha ao solicitar XML do CTE junto a Transpofrete."

					//GRAVANDO O LOG DA CONFIRMAÇÃO	
					U_MonitRes("000005", 2, , cIdPZB, cMenssagem, .F., cChave, cJson, cJsoRec, cChave, lReprocess, lLote, cIdPZC)
				
				EndIf

			Next nX
			
			If Len(aCtes) > 0
			    		
				//Finaliza o processo.
				U_MonitRes("000005", 3, , cIdPZB, , .F.)
				
			Endif

		EndIf

	EndIf
		
Return(Nil)
