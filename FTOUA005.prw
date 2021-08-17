#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "TBICONN.CH"

// #################################################################################################################
// Projeto: OUROLUX - PROJETO TRANSPOFRETE
// Modulo : Rotina responsavel pala integração das faturas na transpofrete - Integraçãoo API REST/JSON
// Fonte  : FTOUA005
// ---------+-------------------+-----------------------------------------------------------------------------------
// Data     | Autor             | Descricao                                       	
// ---------+-------------------+-----------------------------------------------------------------------------------
// 14/08/19 | Roberto Marques   | Classe para conexão a  API TranspoFrete.
// ---------+-------------------+-----------------------------------------------------------------------------------
 
User Function TESTE005()

	U_FTOUA005(.F.,.F.,"","","01","01")
	
Return(Nil)

User Function FTOUA005(lReprocess, lLote, cIdReg, cIdPZC, cEmpPrep, cFilPrep)
    
Local cFunName       := ProcName(0)
Local aHeader        := {"Content-Type: application/json"}
Local cToken         := ""
Local cJSon          := ""
Local cIdPZB         := ""
Local aCriaServ      := {}
Local aRequest       := {}
Local oRet           := Nil
Local cNumFat        := ""
Local cChave         := ""
LOCAL aArray         := {}
Local cIdFat         := ""
Local aFaturas       := {}
Local aRecnoSF1      := {}
Local aEmpSm0		 := {}
Local nPosEmp		 := 0
Local nValDesc		 := 0
Local nY
Local nX
Local cAprova		 := ""
Local cAprova1		 := "" // ras

Local lIntApr		 := ""

Private lMsErroAuto  := .F.

Default lLote		:= .F.
Default lReprocess	:= .F.
Default cIdReg		:= ""
Default cIdPZC		:= ""	
Default cEmpPrep    := ""
Default cFilPrep    := ""
 	 
	RpcSetEnv(cEmpPrep, cFilPrep)

	lIntApr := SuperGetMv("FT_OUA005D",.F.,.F.)

	//Requisicao do acesso
	oREST := FTOUA003():New()
	oREST:RESTConn() 
	lReturn := oRest:lRetorno
	cToken  := oREST:cToken
	
	If !lReturn
        
        Conout("Falha na autenticacao Transpofrete")
        
    Else
	 
		DbSelectArea("SA2")
		SA2->(DbSetOrder(3)) //A2_FILIAL+A2_CGC
	 
		DbSelectArea("SF1")
		SF1->(DbSetOrder(8)) //F1_FILIAL+F1_CHVNFE
	 
		DbSelectArea("PR1")
		PR1->(DbSetOrder(2)) //PR1_FILIAL+PR1_ALIAS+PR1_CHAVE
		
		aRequest := U_ResInteg("000013",,aHeader,,.T.,cToken)		
		
		// RETORNO DA TRANSPOFRETE
		If aRequest[1] 
		
			aFaturas := aRequest[2]:faturas

			nQtdReg := Len(aFaturas)

			//********************************************************
			//** TRECHO ABAIXO USADO PARA TESTE
			//*****************	***************************************
			
			If !Empty(cIds := GetMV("FT_OUA005B",,"")) 
				
				aFaturas := Strtokarr2(cIds,";")
				
				For nX := 1 To Len(aFaturas)
					
					aFaturas[nX] := Val(aFaturas[nX])
					
				Next
				
			Endif
			
			If Len(aFaturas) > 0
		    			
				//Inicia o processo
				aCriaServ := U_MonitRes("000006", 1, nQtdReg)
				cIdPZB 	  := aCriaServ[2]
				
			Else
				
		    	If GetMV("FT_CONOUTX",,.T.)
		    		
		    		Conout(ProcName(0) + " - " + DToC(Date()) + " - " + Time() + " - Nao ha dados para processamento.")
		    		
		    	Endif
		    	
			Endif

			//Retorna empresas
			aEmpSm0 := FWLoadSM0()
			
			For nX := 1 to len(aFaturas) 
				
				cChave    := cIdFat := cValToChar(aFaturas[nX])
				cJsoRec   := ""
				cJson     := ""
				lSeekSF1  := .T.
				aRecnoSF1 := {}
				
				If PR1->(dbSeek(xFilial("PR1")+"SE2"+xFilial("SE2")+cIdFat))
	    	  	
	    	  		cMenssagem := "ID " + cIdFat + " ja integrado anteriormente."
	    	  		U_MonitRes("000006",2,,cIdPZB,PadR(cMenssagem,TamSX3("PZD_DESC")[1]),.F., cChave,cJson, cJsoRec,cChave, lReprocess, lLote, cIdPZC)
	    	  		
	    	  	Else
	    	  		 
					cMenssagem  := "Capturando FATURA: " + cIdFat
					
					//Retorno em forma de objeto
					oRet     := aRequest[2]
					
					//Retorno em forma de string
					cJsoRec := aRequest[3]
	
					cJson := '{'
					cJson += '"fatura":' + cIdFat
		   			cJson += '}'
				  	
				  	//********************************************************************
					//** Exceção Ocorrida :  argument #0 error, expected C->A,  function EncodeUtf8 (141)
					//** Pilha de Chamadas : 
					//** 	TFINX200.PRW (141)
					//** 	FTOUA005.PRW (100)
					//** 	FTOUA005.PRW (18)
					//********************************************************************
		    	  	//aRequest := U_ResInteg("000006",,aHeader,,.T.,cToken)
		    	  	//
		    	  	//If Len(aRequest) < 3 .Or. !aRequest[1] .Or. ValType(aRequest[2]) != "O" .Or. Empty(aRequest[3])
		    	  	//
		    	  	//	cMenssagem := "Falha no método \fatura\recuperarDados."
		    	  	//	U_MonitRes("000006",2,,cIdPZB,PadR(cMenssagem,TamSX3("PZD_DESC")[1]),.T., cChave,cJson, cJsoRec,cChave, lReprocess, lLote, cIdPZC)
		    	  	// 
		    	  	//Else
		    	  	
					lRestOK := .F.
					oRest := FWREST():New(GetMV("FT_OUA005C",,"http://ws.transpofrete.com.br/api"))
				    oRest:SetPath("/fatura/recuperarDados?token="+cToken)
					If (cEncode := EncodeUtf8(cJson)) <> Nil
				        cJson := cEncode
				    EndIf
				    oRest:SetPostParams(cJson)
				    lRet := oRest:Post(aHeader)
				    
				    If (cJsoRec := oRest:GetResult()) != Nil
				    	If !Empty(cJsoRec) 
							oJson := JsonObject():New()
							ret := oJson:FromJson(cJsoRec)
						    if ValType(ret) == "C"
						    	U_MonitRes := "Falha na conversao do JSON - Metodo recuperarDados"
						    	U_MonitRes("000006", 2, , cIdPZB,cMenssagem,.F.,cChave,cJson,cJsoRec, cChave, lReprocess, lLote, cIdPZC)
						    Else 
						    	lRestOK := .T.
					    	endif
				    	Else
				    		cMenssagem := "Retorno JSON vazio - Metodo recuperarDados"
				    		U_MonitRes("000006", 2, , cIdPZB,cMenssagem,.F.,cChave,cJson,cJsoRec, cChave, lReprocess, lLote, cIdPZC)
				    	Endif
				    Else
				    	cMenssagem := "Falha ao obter JSON - GetResult() - Metodo recuperarDados"
				    	U_MonitRes("000006", 2, , cIdPZB,cMenssagem,.F.,cChave,cJson,cJsoRec, cChave, lReprocess, lLote, cIdPZC)
				    Endif
					
					If lRestOK
						
						If lIntApr //bloco para buscar aprovador - Rodrigo Nunes 17-07-2020
							If ValType(oJson:GetJSonObject('fatura'):GetJSonObject('aprovacoes')) == "A"
								If Len(oJson:GetJSonObject('fatura'):GetJSonObject('aprovacoes')) > 0
									cAprova  := oJson:GetJSonObject('fatura'):GetJSonObject('aprovacoes')[1]:GetJSonObject("usuario")
									cAprova1 := oJson:GetJSonObject('fatura'):GetJSonObject('aprovacoes')[2]:GetJSonObject("usuario")
								EndIf
							EndIf
						EndIf

						cNumFat	:= PadL(cValToChar(oJson:GetJSonObject('fatura'):GetJSonObject('numero')),TamSX3("E2_NUM")[1],"0")              								

		    	  		cChave  += "-" + cNumFat
						
						dEmissao := SToD(replace(oJson:GetJSonObject('fatura'):GetJSonObject('dataEmissao')    ,'-',''))		
						dVencto  := SToD(replace(oJson:GetJSonObject('fatura'):GetJSonObject('dataVencimento') ,'-',''))	
						dVencrea := SToD(replace(oJson:GetJSonObject('fatura'):GetJSonObject('dataLimite')     ,'-',''))
						
						//If Empty(dVencrea)
						//
						//	If "UN08F1_DES_COMP" $ Upper(Alltrim(GetEnvServer()))
						//		
						//		dVencrea := Date() + 30
						//		
						//	Endif
						////fatura 4983353
						//
						//Endif 
						
						nValor   	:= oJson:GetJSonObject('fatura'):GetJSonObject('valor')
						nValDesc	:= oJson:GetJSonObject('fatura'):GetJSonObject('valorDesconto')

						If Type("nValor") == "U"
							nValor := 0
						EndIf

						If Type("nValDesc") == "U"
							nValDesc := 0
						EndIf
			    	  	
			    	  	cCgcFor := oJson:GetJSonObject('fatura'):GetJSonObject('cnpjEmissor') 
			    	  	oCtes := oJson:GetJSonObject('fatura'):GetJSonObject('ctes')
			    	  	   
						//Retorno em forma de objeto
						//oRet := aRequest[2]
						//Retorno em forma de string
						//cJsoRec := aRequest[3]

						SA2->(DbSetOrder(3))
						
	             		If !SA2->(MsSeek(xFilial("SA2") + cCgcFor))
 			    	  		cMenssagem := "CNPJ " + cCgcFor + " nao encontrado no cadastro de fornecedores (alias SA2)."
		    	  			U_MonitRes("000006",2,,cIdPZB,PadR(cMenssagem,TamSX3("PZD_DESC")[1]),.F., cChave,cJson, cJsoRec,cChave, lReprocess, lLote, cIdPZC)
		    	  			
		    	  		Elseif SA2->A2_MSBLQL == "1"
		    	  			
		    	  			cMenssagem := "Fornecedor " + SA2->A2_COD + " bloqueado."
		    	  			U_MonitRes("000006",2,,cIdPZB,PadR(cMenssagem,TamSX3("PZD_DESC")[1]),.F., cChave,cJson, cJsoRec,cChave, lReprocess, lLote, cIdPZC)
		    	  			
		    	  		Elseif ValType(oCtes) != "A"
		    	  			
		    	  			cMenssagem := "Propriedade 'ctes' invalida."
		    	  			U_MonitRes("000006",2,,cIdPZB,PadR(cMenssagem,TamSX3("PZD_DESC")[1]),.F., cChave,cJson, cJsoRec,cChave, lReprocess, lLote, cIdPZC)
		    	  			
		    	  		Elseif Len(oCtes) == 0
		    	  			
		    	  			cMenssagem := "Nenhuma CTE iformada."
		    	  			U_MonitRes("000006",2,,cIdPZB,PadR(cMenssagem,TamSX3("PZD_DESC")[1]),.F., cChave,cJson, cJsoRec,cChave, lReprocess, lLote, cIdPZC)
		    	  		
		    	  		Else
		    	  			
		    	  			aRecnoCTE := {}
		    	  			
		    	  			For nY := 1 To Len(oCtes)
		    	  				
		    	  				cChvCte := Alltrim(oCtes[nY]:GetJSonObject('chave'))
		    	  				cCgcOur := Alltrim(oCtes[nY]:GetJSonObject('cnpjUnidade'))

								nPosEmp := aScan(aEmpSm0, {|x| Alltrim(x[18]) == cCgcOur })

								//Seta novamente os indices porque o execauto bagunça
								SA2->(DbSetOrder(3))
								SF1->(DbSetOrder(8))

								If nPosEmp == 0
									cMenssagem := "Empresa: " + cCgcOur + " nao encontrada no SIGAMAT."
				    	  			U_MonitRes("000006",2,,cIdPZB,PadR(cMenssagem,TamSX3("PZD_DESC")[1]),.F., cChave,cJson, cJsoRec,cChave, lReprocess, lLote, cIdPZC)
		    	  				
		    	  				ElseIf !SF1->(dbSeek(aEmpSm0[nPosEmp][2] + cChvCte))
		    	  					
		    	  					cMenssagem := "Chave CTE " + cChvCte + " nao encontrada na tabela SF1 - NF de Entrada."
				    	  			U_MonitRes("000006",2,,cIdPZB,PadR(cMenssagem,TamSX3("PZD_DESC")[1]),.F., cChave,cJson, cJsoRec,cChave, lReprocess, lLote, cIdPZC)
				    	  			
		    	  				Elseif SF1->F1_ESPECIE != "CTE"
		    	  					
		    	  					cMenssagem := "Chave CTE " + cChvCte + " - SF1 nao e CTE."
				    	  			U_MonitRes("000006",2,,cIdPZB,PadR(cMenssagem,TamSX3("PZD_DESC")[1]),.F., cChave,cJson, cJsoRec,cChave, lReprocess, lLote, cIdPZC)
		    	  				
		    	  				Elseif Empty(SF1->F1_STATUS)
		    	  					
		    	  					cMenssagem := "CTE " + cChvCte + " nao classificada."
				    	  			U_MonitRes("000006",2,,cIdPZB,PadR(cMenssagem,TamSX3("PZD_DESC")[1]),.F., cChave,cJson, cJsoRec,cChave, lReprocess, lLote, cIdPZC)
				    	  			
		    	  				Else
		    	  				
		    	  					//Guarda fornecedor da fatura
									nRecAux := SA2->(Recno())
									
									//Guarda CNPJ do fornecedor da fatura
									cCnpjAux := SA2->A2_CGC

									//Posiciona Fornecedor da NF
									SA2->(DbSetOrder(1))
									SA2->(MsSeek(xFilial("SA2") + SF1->(F1_FORNECE+F1_LOJA)))

									If Left(SA2->A2_CGC, 8) <> Left(cCnpjAux,8)

										cMenssagem := "Fornecedor da CTE " + cChvCte + " divergente - SF1:" + SF1->F1_FORNECE + "/SA2:"+ SA2->A2_COD + "."
										U_MonitRes("000006",2,,cIdPZB,PadR(cMenssagem,TamSX3("PZD_DESC")[1]),.F., cChave,cJson, cJsoRec,cChave, lReprocess, lLote, cIdPZC)
									
									Else
										SA2->(DbGoTo(nRecAux))
										aAdd(aRecnoSF1,{SF1->(Recno()),cChvCte})
									EndIf

		    	  				
		    	  				Endif
		    	  			
		    	  			Next 
		    	  			
		    	  			If Len(aRecnoSF1) == Len(oCtes)
			    	  			
								aArray := {{ "E2_FILIAL"   , xFilial("SE2")    			 	, NIL },;
								           { "E2_PREFIXO"  , "FAT"             			 	, NIL },;
			            		           { "E2_NUM"      , cNumFat                        , NIL },;
			            		           { "E2_TIPO"     , "NF"              			 	, NIL },;
			            		           { "E2_NATUREZ"  , GetMV("FT_OUA005A",,"6212003") , NIL },;
			            		           { "E2_FORNECE"  , SA2->A2_COD         	 	 	, NIL },;
			            		           { "E2_LOJA"     , SA2->A2_LOJA          		 	, NIL },;
			            		           { "E2_NOMFOR"   , SA2->A2_NREDUZ				 	, NIL },;
			            		           { "E2_EMISSAO"  , dEmissao                       , NIL },;
			            		           { "E2_VENCTO"   , dVencto                        , NIL },;
			            		           { "E2_VENCREA"  , dVencrea                       , NIL },;
			            		           { "E2_VALOR"    , nValor                         , NIL },;
							   { "E2_DECRESC"  , nValDesc                       , NIL },;
			            		           { "E2_ORIGEM"   , "TRANSPO"                 	, NIL },;
								{ "E2_XAPROV1"  , cAprova1			, NIL },;							   
								{ "E2_XAPROV2"  , cAprova			, NIL }} // rogerio - invertido por solicitacao do Cristiano, este processovai ser aprovado pelo gerente e diretor

								cAprova := ""
								cAprova1 := ""
								
			            		            
			    	  			Begin Transaction
	            						
				 					_OldFun := FunName()
									SetFunName("FINA050")
									MsExecAuto({ |x,y,z| FINA050(x,y,z)}, aArray,, 3)  // 3 - Inclusao, 4 - Alteracao, 5 - Exclusao.
									//SetFunName(_OldFun)
				 
									If !lMsErroAuto
									    
										_cJSon := '{'
										_cJSon += '"numeroFatura": "'+cNumFat+'",'
										_cJSon += '"cnpjEmissor": "'+cCgcFor+'",'
										_cJSon += '"statusIntegracao": 0'
										_cJSon += '}' 
										
										//********************************************************
										//** TRECHO ABAIXO USADO PARA TESTE
										//********************************************************
										//If Date() == STOD("20200210")
										//	If alltrim(upper(GetComputername())) == "DESKTOP-Q3SPF7T"
										//		_cJSon := ""
										//	Endif
										//Endif
										 
										//********************************************************
										//** CONDIÇÃO EMPTY ABAIXO USADO PARA TESTE
										//********************************************************
										If !EMPTY(_cJSon)
											aRequest := U_ResInteg("000014",_cJSon , aHeader, , .T.,cToken)
										Endif
										
									    // RETORNO DA TRANSPOFRETE
										//********************************************************
										//** CONDIÇÃO EMPTY ABAIXO USADO PARA TESTE
										//********************************************************
										If !Empty(_cJSon) .And. !aRequest[2]:status == "CONFIRMADO"
								    		 
								    		cJson   := _cJSon
								    		cJsoRec := aRequest[3] 
											
											DisarmTransaction()
											
											cMenssagem := "ExecAuto FINA050 OK, mas ocorreu falha ao informar status de sucesso ao transpofrete. Commit cancelado."
											U_MonitRes("000006",1,,cIdPZB,PadR(cMenssagem,TamSX3("PZD_DESC")[1]),.F., cChave,cJson, cJsoRec,cChave, lReprocess, lLote, cIdPZC)
								    	
								    	Else
									    	
											RecLock("PR1",.T.)
											
												PR1->PR1_FILIAL := xFilial("PR1")
												PR1->PR1_ALIAS  := "SE2"
												PR1->PR1_RECNO  := SE2->(Recno())
												PR1->PR1_TIPREQ := "1"
												PR1->PR1_DATINT := Date()
												PR1->PR1_HRINT	:= Time()		
												PR1->PR1_STINT  := "I"
												PR1->PR1_CHAVE  := xFilial("SE2") + cChave
													
											PR1->(MsUnlock())
										
											For nY := 1 To Len(aRecnoSF1)
										    	
												SF1->(dbGoTo(aRecnoSF1[nY,1]))
											    
											    RecLock("SF1",.F.)
											    
											    	SF1->F1_CTEFAT  := cNumFat
											    	
												SF1->(MsUnlock())
												
										    Next   

											//Força a origem do título
											SE2->(RecLock("SE2", .F.))

												SE2->E2_ORIGEM := "TRANSPO"
											
											SE2->(MsUnlock())
						    	  				 
						    	  			cMenssagem := "Integrado com sucesso."
						    	  			U_MonitRes("000006",2,,cIdPZB,PadR(cMenssagem,TamSX3("PZD_DESC")[1]),.T., cChave,cJson, cJsoRec,cChave, lReprocess, lLote, cIdPZC)
						    	  			
						    	  			dbCommitAll()
						    	  			
							    		Endif
									       
									Else
										
										DisarmTransaction()
										
										cDirArq := "\"
										cNomArq := "\"+cFunName+"-"+DToS(Date())+"-"+StrTran(Time(),":","")+".log"
										
										cErro := VerErro(MostraErro(cDirArq,cNomArq),cDirArq,cNomArq)
										
										FErase(cDirArq+cNomArq) 
			                            
			                            cMenssagem := cErro 
									    
										_cJSon := '{'
										_cJSon += '"numeroFatura": "'+cNumFat+'",'
										_cJSon += '"cnpjEmissor": "'+cCgcFor+'",'
										_cJSon += '"statusIntegracao": 2,'
										_cJSon += '"mensagem": "'+cErro+'"'
										_cJSon += '}'
									    
									    aRequest := U_ResInteg("000014",_cJSon, aHeader, , .T.,cToken)
									     
									    // RETORNO DA TRANSPOFRETE
										If !aRequest[2]:status == "CONFIRMADO"
																	
											//oRet    := aRequest[2]
											//cJsoRec := aRequest[3]
											
											cMenssagem := "Falha ao informar status de erro ao transpofrete. " + cErro
								    		 
								    		cJson   := _cJSon
								    		cJsoRec := aRequest[3]
								    		 
							    		Endif
							    		
							    		U_MonitRes("000006",2,,cIdPZB,PadR(cMenssagem,TamSX3("PZD_DESC")[1]),.F., cChave,cJson, cJsoRec,cChave, lReprocess, lLote, cIdPZC) 
									     
						    		Endif
						    		
						    	End Transaction
					           
				           Endif
				           
			           Endif
			  
                    Endif
                    
				Endif
			
	   		Next
			
			If Len(aFaturas) > 0
		    					
				//Finaliza o processo na PZB
				U_MonitRes("000006", 3, , cIdPZB, , .T.)
				
			Endif
	   			
		Endif	  
    	  			
   ENDIF			
	
	RPCCLEARENV()
	
Return(Nil) 

//Static Function fuFilial(cCNPJ)
//
//Local cFil	:= ""
//	do case
//		case cCNPJ == "05393234000160"
//			cFil := "01"
//		case cCNPJ == "05393234000321"
//			cFil := "02"
//		case cCNPJ == "05393234000240"
//			cFil := "03"
//		case cCNPJ == "68931419000109"
//			cFil := "00"
//		case cCNPJ == "05393234000402"
//			cFil := "04"
//		case cCNPJ == "05393234000593"
//			cFil := "05"
//	endcase
//		
//Return(cFil)    

//-------------------------------------------------------------------
/*/{Protheus.doc} VerErro
Formata log obtido do retorno de ExecAuto
@author Caio
@since 08/01/2020
@version 1.0
@return cErrRet, characters, erro ExecAuto formatado
@param cErroAuto, characters, erro ExecAuto não formatado
@type function
/*/
//-------------------------------------------------------------------

Static Function VerErro(cErroAuto,cDirArq,cNomArq)

Local nLines      := MLCount(cErroAuto)
Local nErr        := 0
Local cErrRet     := ""
Local cConteudo   := "" 

Default cErroAuto := ""
Default cDirArq   := ""
Default cNomArq   := ""

	For nErr := 1 To nLines
	
		cConteudo := MemoLine(cErroAuto,,nErr)
		
		cErrRet += " " + cConteudo
		
		If Empty(cConteudo)
		
			Exit
			
		Endif
		
	Next 
	
	For nErr := 1 To nLines
		
		cConteudo := MemoLine(cErroAuto,,nErr)
		
		If At("< --",cConteudo) > 0
			
			cErrRet += " " + cConteudo
			
			Exit
			
		Endif
	
	Next
	
	While At("  ",cErrRet) > 0
	
		cErrRet := StrTran(cErrRet,"  "," ")
		
	EndDo
	
Return(AllTrim(cErrRet)) 
