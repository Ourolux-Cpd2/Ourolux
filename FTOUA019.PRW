#include 'protheus.ch'
#include 'parmtype.ch'

#DEFINE cEnt Chr(10)+ Chr(13)

//--------------------------------------------------------------------
/*/{Protheus.doc} FTOUA018
Integração de carga combinada
@author Ghidini Consulting
@since 07/02/2020
@version 1.0
/*/
//--------------------------------------------------------------------

User Function TESTE019()

	U_FTOUA019(.F.,.F.,"","","01","01")
	
Return(Nil)

User function FTOUA019(lReprocess, lLote, cIdReg, cIdPZC, cEmpPrep, cFilPrep)

Local aHeader       := {"Content-Type: application/json"}
Local cToken 		:= ""
Local aRegs         := {}
Local nX
Local oNota     	:= Nil
Local aEmpSm0     	:= {}
Local aCabec		:= {}
Local aItens		:= {}
Local aLinha		:= {}
Local cRetTip		:= ""
Local cRetOper		:= ""
Local cCPag_CT		:= ""
Local cPrdFrete		:= ""
Local _nErro		
Local nY

Default lLote		:= .F.
Default lReprocess	:= .F.
Default cIdReg		:= ""
Default cIdPZC		:= ""	

Private cIdEnt      	:= ""
Private cError      	:= ""
Private lMsHelpAuto		:= .T.
Private lAutoErrNoFile 	:= .T.
Private lMsErroAuto 	:= .F.


	RpcSetEnv(cEmpPrep, cFilPrep)

	//Data de corte
	dDtCort := GetMV("FT_OUA004C",,CTOD("09/05/2020"))
       
	//Requisicao do acesso
	oREST := FTOUA003():New()
	oREST:RESTConn() 
	lReturn := oRest:lRetorno
	cToken  := oREST:cToken	
	
	If !lReturn
        
        Conout("Falha na autenticação Transpofrete")

		aCriaServ := U_MonitRes("000009", 1, len(aRegs))
		cIdPZB 	  := aCriaServ[2]

		//Finaliza o processo na PZB
		U_MonitRes("000009", 3, , cIdPZB, , .F.)

        
    Else
		
		aEmpSm0	:= FwLoadSM0()
		
		aRequest := U_ResInteg("000009", "", aHeader, , .T.,cToken )

		aRegs := aRequest[2]:ctes

		aCriaServ := U_MonitRes("000009", 1, len(aRegs))
		cIdPZB 	  := aCriaServ[2]

		For nX := 1 to len(aRegs)

			aProdutos := {}

			cJson := '{'
			cJson += '"cte":' + cValToChar(aRegs[nX])
			cJson += '}'

			aRequest := U_ResInteg("000005", cJson, aHeader, , .T.,cToken )

			oNota := aRequest[2]:ctes[1]

			//Emissao
			dDtEmiss := Left(oNota:DATAEMISSAO,10)
			dDtEmiss := STOD(StrTran(dDtEmiss, "-", ""))

			If dDtCort > dDtEmiss

				cJson := '{'
				cJson += '"numero": "' + StrZero(oNota:NUMERO,9)	 + '",'
				cJson += '"serie": "' + oNota:Serie	 + '",'
				cJson += '"cnpjEmissor": "' + oNota:CNPJEMISSOR + '",'
				cJson += '"statusIntegracao": 2,'
				cJson += '"codigoMensagem": 2,'
				cJson += '"mensagem": "data de emissão é anterior ao Go-Live."'
				cJson += '}'

				// INFORMAR A TRANSPOFRETE INTEGRACAO XML 
				aRequest := U_ResInteg("000009", cJson , aHeader, , .T.,cToken)

				Loop

			EndIf

			//Busca código correto da filial
			_cFil  := fuFilial(oNota:CNPJUNIDADE) 

			//Trata código da filial logada
			If _cFil <> cFilAnt
				cFilGuard := cFilAnt
				cFilAnt := _cFil
			EndIf

			//Verifica se é transferencia entre filiais
			If Left(oNota:CNPJUNIDADE,8) == Left(oNota:CNPJEMISSOR,8)
				lTrfFil := .T.
			Else
				lTrfFil := .F.
			EndIf

			//Posiciona fornecedor
			SA2->(DbSetOrder(3))
			If !SA2->(DbSeek(xFilial("SA2") + oNota:CNPJEMISSOR ))
				U_MonitRes("000009",2,,cIdPZB,"Fornecedor não cadastrado: " + oNota:CNPJEMISSOR,.F., StrZero(oNota:NUMERO,9), "", "",StrZero(oNota:NUMERO,9), lReprocess, lLote, cIdPZC)
				Loop
			EndIf


			//Defini tipo da nota
			If AttIsMemberOf(oNota, "VALORISS")
				cEspecie := "NFS"
				cCst := 0
			Else
				cEspecie := "CTE"
				cCst := oNota:CST
			EndIf

			cProdPad	:= ""
			lIsExec		:= .F.

			cTipo := fRetAtrb(cCst, @cRetTip, @cRetOper, oNota:TIPOCTE, SA2->A2_SIMPNAC, lTrfFil, oNota:tipoConhecimento, @cProdPad, cEspecie, @lIsExec)
			
			If cEspecie <> "NFS"
				
				If "conemb" $ oNota:linkrepositorio

					U_MonitRes("000009",2,,cIdPZB,"Conemb descartado.",.F., cDoc,cJson, aRequest[3],cDoc, lReprocess, lLote, cIdPZC)
					Loop

				EndIf

			Else
				cRetTip := "N"
			EndIf
			/*
			dbSelectArea("SFM")
			SFM->(dbSetOrder(1))
			
			If SFM->(dbSeek(xFilial("SFM")+cRetOper))
				If !Empty(SFM->FM_TE)
					cTes := SFM->FM_TE
				Else
					cTes := GetMv("FT_OUA008Z",,"")
				Endif
			Else
				cTes := GetMv("FT_OUA008Z",,"")
			Endif 

			DBSELECTAREA("SFM")
			DBCLOSEAREA()
			*/
			dDtEmiss := Left(oNota:DATAEMISSAO,10)
			dDtEmiss := STOD(StrTran(dDtEmiss, "-", ""))

			cDoc	:= _cFil + StrZero(oNota:NUMERO,9) + Padr(oNota:Serie,3) + SA2->(A2_COD+A2_LOJA)
			aCabec	:= {}
			
			aadd(aCabec,{"F1_FILIAL"  ,	_cFil												, Nil})
			aadd(aCabec,{"F1_TIPO"    , cRetTip  	            							, Nil})
			aadd(aCabec,{"F1_FORMUL"  , "N"													, Nil})
			aadd(aCabec,{"F1_DOC"     , StrZero(oNota:NUMERO,9)								, Nil})
			aadd(aCabec,{"F1_SERIE"   , oNota:Serie											, Nil})
			aadd(aCabec,{"F1_EMISSAO" , dDtEmiss											, Nil})
			aadd(aCabec,{"F1_DTDIGIT" , dDataBase											, Nil})
			aadd(aCabec,{"F1_FORNECE" , SA2->A2_COD											, Nil})
			aadd(aCabec,{"F1_LOJA"    , SA2->A2_LOJA										, Nil})
			aadd(aCabec,{"F1_ESPECIE" , cEspecie											, Nil}) 
			
			If cEspecie <> "NFS"
				
				cChave := oNota:Chave
				
				aadd(aCabec,{"F1_CHVNFE"  , cChave, Nil})

			EndIf
			
			aadd(aCabec,{"F1_HORA"    , TIME()       										, Nil})
			aadd(aCabec,{"F1_COND" 	  , cCPag_CT 											, Nil})
			aadd(aCabec,{"F1_MOEDA"	  , 1 													, Nil})
			aadd(aCabec,{"F1_TXMOEDA" , 1 													, Nil})
			aadd(aCabec,{"F1_STATUS"  , "A" 												, Nil})
			
			If cEspecie <> "NFS"
				If AttIsMemberOf(oNota, "ValorBaseIcms")
					aAdd(aCabec,{"F1_BASERET" , oNota:ValorBaseIcms			, Nil})
					aAdd(aCabec,{"F1_ICMRET"  , oNota:ValorIcms				, Nil})
				EndIf
			EndIf
			
			//aAdd(aCabec,{"F1_UFORITR" , "RJ"					,Nil})										
			//aAdd(aCabec,{"F1_UFDESTR" , "RJ"					,Nil})
			
			aAdd(aCabec,{"F1_MUORITR" , SUBSTR(cValToChar(oNota:CodIbgeOrigem) ,3,5)	, Nil}) 
			aAdd(aCabec,{"F1_MUDESTR" , SUBSTR(cValToChar(oNota:CodIbgeDestino) ,3,5)	, Nil}) 
			aAdd(aCabec,{"F1_TPCTE"   , TIPOCTE116(cValToChar(oNota:TIPOCTE))			, Nil})
			aAdd(aCabec,{"F1_ORIGEM"  , "FTOUA019"										, Nil})
	                        
			//ITENS DA NF
									
			dbSelectArea("SB1")
			dbSetOrder(1)
			dbSeek( xFilial("SB1")+cPrdFrete )

			If !lIsExec

				If ValType(oNota:centrosCustos) == "A"

					If len(oNota:centrosCustos) > 0

						For nY := 1 to len(oNota:centrosCustos)
						
							DbSelectArea("SBM")
							SBM->(DbSetOrder(1))

							If SBM->(DbSeek(xFilial("SBM") + oNota:centrosCustos[nY]:codigo))

								cPrdFrete := SBM->BM_XPRDFRT
								
								nPosPrd := aScan(aProdutos, {|x| Alltrim(x[1]) == Alltrim(SBM->BM_XPRDFRT)})

								If nPosPrd == 0
									AADD(aProdutos, {Alltrim(SBM->BM_XPRDFRT), oNota:centrosCustos[nY]:VALORFRETEREALIZADO})
								Else
									aProdutos[nPosPrd][2] += oNota:centrosCustos[nY]:VALORFRETEREALIZADO
 								EndIf

							EndIf

						Next nY

					EndIf

				EndIf

				If Len(aProdutos) == 0 
					cPrdFrete := SuperGetMV("MV_XMLPFCT",.F.,"")
				EndIf

			Else
				cPrdFrete := cProdPad
			EndIf

			aItens	:= {}
			aLinha	:= {}
			
			If cRetTip $ "I/C"

				aGrvPR3 := Array(0)
	                        
	            RetArrPR3(oCte,@aGrvPR3,oNota:Chave)   
	                        	
				If Len(aGrvPR3) > 0
					
					DBSelectArea("SF1")
					SF1->(DBSetOrder(8)) 
					
					If SF1->(dbSeek(xfilial("SF1")+aGrvPR3[1,3]))

						If cRetTip == "C"

							aadd(aCabec,{"F1_TPCOMPL"	,"3"	,Nil})
							aadd(aCabec,{"F1_MODAL"		,"01"	,NIL})
							aadd(aCabec,{"F1_TPFRETE"	,"C" 	,NIL})
							aadd(aCabec,{"F1_TPCTE"		,"C" 	,NIL})

						EndIf
						
						aadd( aLinha, { "D1_FILORI" ,SF1->F1_FILIAL	,NIL}) 
						aadd( aLinha, { "D1_NFORI"  ,SF1->F1_DOC   	,NIL})
						aadd( aLinha, { "D1_SERIORI",SF1->F1_SERIE 	,NIL})
						
					Endif	
					
				Endif
				
			Endif

			If Len(aProdutos) > 0
			
				For nY := 1 to len(aProdutos)

					aadd( aLinha, { "D1_QUANT"	,1					, Nil})
					aadd( aLinha, { "D1_COD" 	,aProdutos[nY][1] 	, Nil})
					aadd( aLinha, { "D1_UM" 	,"UN" 				, NIL})
					aadd( aLinha, { "D1_LOCAL"  ,"01" 				, NIL})					
					aadd( aLinha, { "D1_VUNIT"	,aProdutos[nY][2]	, Nil})
					aadd( aLinha, { "D1_TOTAL"	,aProdutos[nY][2]	, Nil}) 
					aadd( aLinha, { "D1_OPER"	,cRetOper			, Nil}) 
					//aadd( aLinha, { "D1_TES"	,cTes				, Nil})
					
					If cEspecie <> "NFS"
						
						If AttIsMemberOf(oNota, "ValorBaseIcms")
							aadd( aLinha, { "D1_BASEICM", oNota:ValorBaseIcms		, Nil})
							aadd( aLinha, { "D1_PICM"	, oNota:VALORALIQUOTAICMS	, Nil})
						EndIf
						
					EndIf
					
					aadd( aLinha, { "AUTDELETA" ,"N" , Nil})

					AADD(aItens,aLinha) 

					aLinha := {}

				Next nY

			Else

				nTotal := oNota:VALORDOCUMENTO
				
				aadd( aLinha, { "D1_QUANT"	,1			, Nil})
				aadd( aLinha, { "D1_COD" 	,cPrdFrete 	, Nil})
				aadd( aLinha, { "D1_UM" 	,"UN" 		, NIL})
				aadd( aLinha, { "D1_LOCAL"  ,"01" 		, NIL})					
				aadd( aLinha, { "D1_VUNIT"	,nTotal		, Nil})
				aadd( aLinha, { "D1_TOTAL"	,nTotal		, Nil}) 
				aadd( aLinha, { "D1_OPER"	,cRetOper	, Nil}) 
				//aadd( aLinha, { "D1_TES"	,cTes		, Nil})
				
				If cEspecie <> "NFS"
					
					If AttIsMemberOf(oNota, "ValorBaseIcms")
						aadd( aLinha, { "D1_BASEICM", oNota:ValorBaseIcms		, Nil})
						aadd( aLinha, { "D1_PICM"	, oNota:VALORALIQUOTAICMS	, Nil})
					EndIf
					
				EndIf
				
				aadd( aLinha, { "AUTDELETA" ,"N" , Nil})

				AADD(aItens,aLinha) 

			EndIf
	                        
			lMsErroAuto := .F.

			DBSelectArea("SF1")
			SF1->(DBSetOrder(1)) 
				
			If !SF1->(dbSeek(cDoc))
					
				MSExecAuto({|x,y,z| mata103(x,y,z)},aCabec,aItens,3) 
					
				If lMsErroAuto
					
					_cStrErro	:= ""
					_aErros 	:= GetAutoGRLog() // retorna o erro encontrado no execauto.
					_nErro   	:= Ascan(_aErros, {|x| "INVALIDO" $ AllTrim(Upper(x))  } )

					If _nErro > 0
						_cStrErro += _aErros[ _nErro ]
					Else
						For _nErro := 1 To Len( _aErros )
							_cStrErro += ( _aErros[ _nErro ] + cEnt )
						Next _nErro

					EndIf

					U_MonitRes("000009",2,,cIdPZB,_cStrErro,.F., cDoc,cJson, aRequest[3],cDoc, lReprocess, lLote, cIdPZC)
														
				Else
					
					cHora := Substr(Time(),1,5) 
					
					For nX := 1 to len(oNota:Notas)
						
						If PR3->(Reclock("PR3",.T.))
							
							PR3->PR3_FILIAL := SF1->F1_FILIAL
							PR3->PR3_DOC    := SF1->F1_DOC
							PR3->PR3_SERIE  := SF1->F1_SERIE
							PR3->PR3_FORNEC := SF1->F1_FORNECE
							PR3->PR3_LOJA   := SF1->F1_LOJA
							PR3->PR3_CHVCTE := SF1->F1_CHVNFE
							PR3->PR3_TIPO   := SF1->F1_TIPO
							PR3->PR3_CHVPAR := oNota:Notas[nX]:chave
							PR3->PR3_HORA   := cHora
							PR3->PR3_DATA   := DDATABASE 
							PR3->PR3_RECNOO := SF1->(Recno())
							
							PR3->(MsUnlock())
								
						Endif

					Next nX
					
					cMenssagem := "Importação de CTE realizado com sucesso."
					U_MonitRes("000009",2,,cIdPZB,cMenssagem,.T., cDoc,cJson, aRequest[3],cDoc, lReprocess, lLote, cIdPZC)
					
					//Confirma no transpo
					cJson := '{'
					cJson += '"numero": "' + StrZero(oNota:NUMERO,9)	 + '",'
					cJson += '"serie": "' + oNota:Serie	 + '",'
					cJson += '"cnpjEmissor": "' + oNota:CNPJEMISSOR + '",'
					cJson += '"statusIntegracao": 0,'
					cJson += '"codigoMensagem": 0,'
					cJson += '"mensagem": "Integracao CTE XML com sucesso"'
					cJson += '}'
				
					// INFORMAR A TRANSPOFRETE INTEGRACAO XML 
					aRequest := U_ResInteg("000011", cJson , aHeader, , .T.,cToken)	
						
				EndIf
				
			Else

				
				U_MonitRes("000009",2,,cIdPZB,"Documento ja incluso.",.F., cDoc,cJson, aRequest[3],cDoc, lReprocess, lLote, cIdPZC)

				//Confirma no transpo
				cJson := '{'
				cJson += '"numero": "' + StrZero(oNota:NUMERO,9)	 + '",'
				cJson += '"serie": "' + oNota:Serie	 + '",'
				cJson += '"cnpjEmissor": "' + oNota:CNPJEMISSOR + '",'
				cJson += '"statusIntegracao": 0,'
				cJson += '"codigoMensagem": 0,'
				cJson += '"mensagem": "CTE ja importada anteriormente"'
				cJson += '}'
			
				// INFORMAR A TRANSPOFRETE INTEGRACAO XML 
				aRequest := U_ResInteg("000011", cJson , aHeader, , .T.,cToken)
			
			EndIf

		Next nX		

		//Finaliza o processo na PZB
		U_MonitRes("000009", 3, , cIdPZB, , .T.)

    EndIf
    
Return(Nil)


//--------------------------------------------------------------------
/*/{Protheus.doc} fuFilial
Retorna código da filial
@author Ghidini Consulting
@since 05/03/2021
@version 1.0
/*/
//--------------------------------------------------------------------


Static Function fuFilial(cCNPJ)

Local _cFil		:= ""
Local aLoadSm0	:= {}
Local nPosEmp	:= 0

	aLoadSm0 := FWLoadSM0()

	nPosEmp := Ascan(aLoadSm0, {|x| Alltrim(x[18]) == Alltrim(cCNPJ) })	
	
	If nPosEmp > 0
		_cFil := aLoadSm0[nPosEmp][2]
	EndIf

Return _cFil

//--------------------------------------------------------------------
/*/{Protheus.doc} fuFilial
Retorna tipo da operação e tipo da nota.
@author Ghidini Consulting
@since 05/03/2021
@version 1.0
/*/
//--------------------------------------------------------------------

Static Function fRetAtrb(nCst, cRetTip, cRetOper, nTipo, cSimpNac, lTransf, nTpTransp, cProdPad, cTpNf, lIsExec)

	DbSelectArea("PR5")
	PR5->(DbSetOrder(1))

	//Se credita ICMS
	cCrdIcm := Iif(nCst == 90, "N", "S")

	//Alterçaão para buscar o tipo da operação e o produto da SX5.
	If PR5->(DbSeek(xFilial("PR5")+StrZero(nTpTransp,6)))

		If CtPnF == "CTE"
			cRetOper := PR5->PR5_OPECTE
		Else
			cRetOper := PR5->PR5_OPENFS
		EndIf 

		cProdPad := PR5->PR5_PRODUT
		lIsExec  := PR5->PR5_EXCEC == "S"

	EndIf	
	
	/*Do Case

		Case nTpTransp == 1
			cRetOper := "T1"

		Case nTpTransp == 3
			cRetOper := "T8"

		Case nTpTransp == 7
			cRetOper := "T4"

		Case nTpTransp == 9
			cRetOper := "60"

		Case nTpTransp == 13
			cRetOper := "T4"

		Case nTpTransp == 15
			cRetOper := "T4"

		Case nTpTransp == 16
			cRetOper := "T9"

		Case nTpTransp == 17
			cRetOper := "T4"

		Case nTpTransp == 20
			cRetOper := "T4"

		Case nTpTransp == 21
			cRetOper := "T6"

		Case nTpTransp == 22
			cRetOper := "T4"
			
	EndCase

	/*
	Do Case
				    
		Case (nCst == 0 .And. cCrdIcm == "S" .And. cSimpNac == "1") .Or. lTransf
			
			cRetOper := "T7"
						
		Case nCst == 0 .And. cCrdIcm == "N"
		
			cRetOper := "T8"
						
		Case nCst == 40 .And. cSimpNac == "1"
		
			cRetOper := "T6"
						
		Case nCst == 60 .And. cCrdIcm == "S"
		
			cRetOper := "T3"
						
		Case nCst == 60 .And. cCrdIcm == "N"
		
			cRetOper := "T5"
						
		Case nCst == 90 .And. cCrdIcm == "S"
		
			cRetOper := "T8"
						
		OtherWise
		
			cRetOper := "T1"
										
	EndCase */

	//Defini o tipo da nota
	Do Case
					    
		Case nTipo == 0
		
			cRetTip := "N"
			
		Case nTipo == 1
		
			cRetTip := "C" 
						
		OtherWise
		
			cRetTip := ""
											
	EndCase 

Return()
