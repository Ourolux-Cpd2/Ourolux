#INCLUDE 	"PROTHEUS.CH"
#INCLUDE	"TOTVS.CH"
#INCLUDE 	"RWMAKE.CH"
#INCLUDE 	"TBICONN.CH"

// #########################################################################################
// Projeto: OUROLUX - PROJETO TRANSPOFRETE
// Modulo : Rotina para enviar os pedidos de venda -  IntegraÃ§Ã£o API REST/JSON
// Fonte  : FTOUA001
// ---------+-------------------+-----------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+-----------------------------------------------------------
// 14/08/19 | TRIYO   | Classe para conexÃ£o Ã  API TranspoFrete
// ---------+-------------------+-----------------------------------------------------------

User Function TESTE001()

	U_FTOUA001(.F.,.F.,"","","01","01")
	
Return(Nil)

User Function FTOUA001(lReprocess, lLote, cIdReg, cIdPZC, cEmpPrep, cFilPrep)
    
Local aHeader		:= {}
Local cToken 		:= ""
Local cJSon			:= ""
Local cIdPZB    	:= ""
Local aCriaServ		:= {}
Local cQuery 		:= ""
Local aRequest		:= {}
Local cAlsPR1		:= ""
Local cCHAVE		:= ""
Local oRet			:= Nil
Local nQtdReg		:= 0

Default lLote		:= .F.
Default lReprocess	:= .F.
Default cIdReg		:= ""
Default cIdPZC		:= ""

RpcSetEnv(cEmpPrep, cFilPrep)

AADD(aHeader, "Content-Type: application/json")
    
	//Requisição do acesso
	cToken := U_ChkToken("1")

	If Empty(cToken)
        
        Conout("Falha na autenticação Transpofrete")
        
    Else
		
		DBSelectArea("PR1")
		
	   	cAlsPR1 := CriaTrab(Nil,.F.)
	
		//Verifica se existe dados a processar
		//cQuery := " SELECT COUNT(*) CONTADOR "                                                                     	
		//cQuery += " FROM " + RetSqlName("PR1") + " PR1 "
		//cQuery += " WHERE PR1_ALIAS = 'SC5' AND PR1_STINT = 'P' AND PR1_TIPREQ = '1' AND D_E_L_E_T_= ' '  " 
	    //
		//If Select(cAlsPR1) > 0; (cAlsPR1)->(dbCloseArea()); Endif  
		//dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlsPR1,.T.,.T.)   
	    //
		//nQtdReg := (cAlsPR1)->CONTADOR
	    //
		//Verifica se existe dados a processar
		cQuery := " SELECT PR1_FILIAL,PR1_ALIAS,PR1_RECNO,PR1_CHAVE,PR1_TIPREQ, R_E_C_N_O_ RECPR1 "                                                                     	
		cQuery += " FROM " + RetSqlName("PR1") + " PR1 "
		cQuery += " WHERE PR1_ALIAS = 'SC5' AND PR1_STINT = 'P' AND PR1_TIPREQ = '1' AND D_E_L_E_T_= ' '  " 
	    
		If Select(cAlsPR1) > 0; (cAlsPR1)->(dbCloseArea()); Endif  
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlsPR1,.T.,.T.)
	    
	    Count To nQtdReg
	    
	    (cAlsPR1)->(DBGOTOP())
	    
	    If (cAlsPR1)->(Eof())
	    	
	    	If GetMV("FT_CONOUTX",,.T.)
	    		
	    		Conout(ProcName(0) + " - " + DToC(Date()) + " - " + Time() + " - Não há dados para processamento.")
	    		
	    	Endif
	    	
	    Else     
		
		
			aCriaServ := U_MonitRes("000002", 1, nQtdReg)
			cIdPZB 	  := aCriaServ[2] 
			    	    
			While !(cAlsPR1)->(EOF()) 
				
				// inicia o processo
				cCHAVE	  := Alltrim((cAlsPR1)->PR1_CHAVE)
		
				// MONTAGEM DO ESTRUTURA JSON
				cJSon	:= fuPedJSon( cCHAVE )
					
				// ENVIO PARA TRANSPOFRETE	
				aRequest := U_ResInteg("000002", cJson, aHeader, , .T.,cToken )
					
				// RETORNO DA TRANSPOFRETE
				If aRequest[1] .And. aRequest[2]:Status <> "ERRO"
						
					cMenssagem := "Integrado Protocolo: " + cValToChar(aRequest[2]:protocolo)
					
					//Retorno em forma de objeto
					oRet := aRequest[2]
					
					//Retorno em forma de string
					cJsoRec := aRequest[3]
					
					//GRAVANDO O LOG DA CONFIRMAÇÃO	
					U_MonitRes("000002", 2, nQtdReg, cIdPZB, cMenssagem, .T., cChave, cJson, cJsoRec,cChave, lReprocess, lLote, cIdPZC)
						
					PR1->(DbGoTo((cAlsPR1)->RECPR1))
					
					RecLock("PR1",.F.)
						
						PR1->PR1_DATINT := Date()
						PR1->PR1_HRINT	:= Time()		
						PR1->PR1_STINT  := "I"
						PR1->PR1_OBSERV := cMenssagem
		
					PR1->(MsUnlock())
					
				Else
						
					cMenssagem  := "Falha na integracao - " + aRequest[2]:mensagem
					cJsoRec     := aRequest[3]
					
					// GRAVANDO LOG DA FALHA NO MONITOR
					U_MonitRes("000002", 2, nQtdReg, cIdPZB, cMenssagem, .F., cChave, cJson, cJsoRec, cChave, lReprocess, lLote, cIdPZC)
					
				Endif     
				
				(cAlsPR1)->(DBSkip())
		
			EndDo   
			    
			//Finaliza o processo na PZB
			U_MonitRes("000002", 3, , cIdPZB, , .T.) 
		
		Endif
	
		If !Empty(cAlsPR1)
			If Select(cAlsPR1) > 0
				dbSelectArea(cAlsPR1)
				dbCloseArea()
			Endif
		Endif
		
	Endif

Return(Nil)

/*********************************************/
/* TRIYO                           			 */
/* Função para montagem da Estrutura JSon    */
/*********************************************/

Static Function fuPedJSon( cPedido )
	
Local cJson	:= ""
Local nVolume		:= 0
Local nLargura		:= 0
Local nAltura		:= 0
Local nComprimento	:= 0
Local nPeso			:= 0
Local nLargEmb		:= 0
Local nAltEmb		:= 0
Local nCompEmb		:= 0
Local nPesoEmb		:= 0
Local nPesoCub		:= 0
Local nProd			:= 0
	
	DBSelectArea("SC5")
	SC5->(DBSetOrder(1))

	SC5->(DBSeek(cPedido ))
	
	aAreaSM0 := SM0->(GetArea())
	
	IF !SC5->(EOF()) .And. SC5->C5_FILIAL+SC5->C5_NUM == cPedido
		
		SM0->(DbSeek(PadR(cEmpAnt,Len(cEmpAnt))+SC5->C5_FILIAL))
	
		DBSelectArea("SA1")
		SA1->(DBSetOrder(1))
		SA1->(DBSeek(xFilial("SA1") + SC5->C5_CLIENTE + SC5->C5_LOJACLI))
		
		cJson	:= ' {'
		cJson	+= '"numero":"'+Alltrim(SC5->C5_NUM)+'",'
		cJson	+= '"cnpjUnidade":"'+Alltrim(SM0->M0_CGC)+'",'
		cJson	+= '"serie":"2",'
		cJson	+= '"emitente":{'
		cJson	+= '"cnpj":"'+Alltrim(SM0->M0_CGC)+'",'
		cJson	+= '"nome":"",'
		cJson	+= '"fantasia":"",'
		cJson	+= '"inscricaoEstadual":"",'
		cJson	+= '"email":"",'
		cJson	+= '"idEstrangeiro":"",'
		cJson	+= '"logradouro":"",'
		cJson	+= '"numero":"",'
		cJson	+= '"bairro":"",'
		cJson	+= '"codigoMunicipio":'+Alltrim(SM0->M0_CODMUN)+','
		cJson	+= '"cep":"'+Alltrim(SM0->M0_CEPENT)+'",'
		cJson	+= '"fone":"'+Alltrim(SM0->M0_TEL)+'"},'
		cJson	+= '"destinatario":{'
		cJson	+= '"cnpj":"'+Alltrim(SA1->A1_CGC)+'",'
		cJson	+= '"nome":"",'
		cJson	+= '"fantasia":"",'
		cJson	+= '"inscricaoEstadual":"",'
		cJson	+= '"email":"",'
		cJson	+= '"idEstrangeiro":"",'
		cJson	+= '"logradouro":"",'
		cJson	+= '"numero":"",'
		cJson	+= '"bairro":"",'
		cJson	+= '"codigoMunicipio":0,'
		cJson	+= '"cep":"'+Alltrim(SA1->A1_CEP)+'",'
		cJson	+= '"fone":""'
		cJson	+= '}, '
		
		cJson	+= '"itens":['
		 
		DBSelectArea("SC6")
		SC6->(DBSetOrder(1))
		
		SC6->(DBSeek(cPedido))

		While !SC6->(EOF()) .And. SC6->C6_FILIAL+SC6->C6_NUM == cPedido
			
			DBSelectArea("SB1")
			SB1->(DBSetOrder(1))
			
			SB1->(DBSeek(xFilial("SB1") + SC6->C6_PRODUTO))
	
			// Dimensoes
			DBSelectArea("SB5")
			SB5->(DBSetOrder(1))

			If SB5->(DBSeek(xFilial("SB5") + SB1->B1_COD))
				If nLargura == 0
					nLargura		:= SB5->B5_LARG
				EndIf
				If nAltura == 0
					nAltura			:= SB5->B5_ALTURA
				EndIf
				If nComprimento == 0
					nComprimento	:= SB5->B5_COMPR
				EndIf
				If nPeso == 0
					nPeso			:= SB5->B5_PESO
				EndIf
				If nLargEmb == 0
					nLargEmb		:= IIf(SB5->B5_LARGLC <> 0, SB5->B5_LARGLC, SB5->B5_LARG)
				EndIf
				If nAltEmb == 0
					nAltEmb			:= IIf(SB5->B5_ALTURLC <> 0, SB5->B5_ALTURLC, SB5->B5_ALTURA)
				EndIf
				If nCompEmb == 0
					nCompEmb		:= IIf(SB5->B5_COMPRLC <> 0, SB5->B5_COMPRLC, SB5->B5_COMPR)
				EndIf
				If nPesoEmb == 0
					nPesoEmb		:= IIf(SB5->(FieldPos("B5_ECPESOE")) <> 0 .And. SB5->B5_ECPESOE <> 0, SB5->B5_ECPESOE, SB5->B5_PESO) //Inclusao do Campo Padrao da TOTVS Campo E-commerce
				EndIf
				If nPesoCub == 0
					nPesoCub		:= IIf(SB5->(FieldPos("B5_ECPESOE")) <> 0 .And. SB5->B5_ECPESOE <> 0, SB5->B5_ECPESOE, SB5->B5_PESO) //Inclusao do Campo Padrao da TOTVS Campo E-commerce
				EndIf
			EndIf
	
			nVolume		:= iif (SC5->C5_VOLUME1==0,1,SC5->C5_VOLUME1)
							
			IF SC5->C5_TPFRETE =="C"
				cModFrete := "0"
			Elseif SC5->C5_TPFRETE =="F"
				cModFrete := "1"
			Elseif SC5->C5_TPFRETE =="T"
				cModFrete := "2"
			Elseif SC5->C5_TPFRETE =="R"
				cModFrete := "2"
			Elseif SC5->C5_TPFRETE =="D"
				cModFrete := "1"
			Elseif SC5->C5_TPFRETE =="S"
				cModFrete := "9"
			Endif			
			
			if nProd == 0 
				cJson += '        {'
			Else
				cJson += '        ,{'
			Endif
			
			cJson	+= '"produto":"'+AllTrim(SC6->C6_PRODUTO)+'",'
			cJson	+= '"nomeProduto":"'+AllTrim(SC6->C6_DESCRI)+'",'
			cJson	+= '"peso":'+CValToChar(nPeso)+','
			
			//CValToChar(nPesoCub) verificar depois com cliente
			cJson	+= '"pesoCubado":0.0,'    
			
			// pergutar da cubagem para cliente
			cJson	+= '"cubagem":0.0,'                         
			cJson	+= '"quantidade":'+CValToChar(SC6->C6_QTDVEN)+','
			cJson	+= '"volumes":'+CValToChar(SC6->C6_UNSVEN)/*CValToChar(nVolume)*/+','
			cJson	+= '"valor":'+CValToChar(SC6->C6_PRCVEN)+','
			cJson	+= '"DI":{'
			cJson	+= '"numero":"",'
			cJson	+= '"formaImportacao":"",'
			cJson	+= '"viaTransporte":"",'
			cJson	+= '"dataDesembaraco":"00-00-0000 00:00:00",'
			cJson	+= '"dataRegistro":"00-00-0000 00:00:00",'
			cJson	+= '"localDesembaraco":"",'
			cJson	+= '"ufDesembaraco":"",'
			cJson	+= '"cnpjEncomendante":"",'
			cJson	+= '"ufEncomendante":"",'
			cJson	+= '"codigoExportador":""'
			cJson	+= '	} '
			cJson	+= '} '
	
			nProd	++                                                
		
			SC6->(DBSkip())
			
		EndDo
	
		cJson	+= '],'
		cJson	+= '"projetoFrete":"XXXX",'   
		cJson	+= '"enderecoRetirada":{'            
		cJson	+= '"logradouro":"'+AllTRIM(SM0->M0_ENDENT)+'",'
		cJson	+= '"complemento":"'+AllTrim(SM0->M0_COMPENT)+'",'
		cJson	+= '"bairro":"'+Alltrim(SM0->M0_BAIRENT)+'",'
		cJson	+= '"uf":"'+Alltrim(SM0->M0_ESTENT)+'",'
		cJson	+= '"cep":"'+Alltrim(SM0->M0_CEPENT)+'",'
		cJson	+= '"ibge":"'+AllTrim(SM0->M0_CODMUN)+'"'
		cJson	+= '},'
		cJson	+= '"enderecoEntrega":{'              
		cJson	+= '"logradouro":"'+FisGetEnd(SA1->A1_END)[1]+'",'
		cJson	+= '"numero":"'+CValToChar(FisGetEnd(SA1->A1_END)[2])+'",'
		cJson	+= '"complemento":"'+AllTrim(SA1->A1_COMPLEM)+'",'
		cJson	+= '"bairro":"'+AllTrim(SA1->A1_BAIRRO)+'",'
		cJson	+= '"uf":"'+AllTrim(SA1->A1_EST)+'",'
		cJson	+= '"cep":"'+SA1->A1_CEP+'",'
		cJson	+= '"ibge":"'+AllTrim(SA1->A1_CODMUN)+'"'
		cJson	+= '},'                              
		cJson	+= '"observacao":"",'
		cJson	+= '"modalidadeFrete":'+cModFrete+','
		cJson	+= '"naturezaOperacao":"",'
		cJson	+= '"canalDistribuicao":"",'
		cJson	+= '"tipoOperacao":"01",'
		cJson	+= '"dataEmissao":"'+Left( DtoS(SC5->C5_EMISSAO), 4) + "-" + Substr( DtoS(SC5->C5_EMISSAO), 5, 2) + "-" + Right( DtoS(SC5->C5_EMISSAO), 2) +  " 00:00:00"+'",'
		cJson	+= '"peso":'+CValToChar(SC5->C5_PBRUTO)+','
		cJson	+= '"pesoLiquido":'+CValToChar(SC5->C5_PESOL)+','
		cJson	+= '"pesoCubado":'+CValToChar(SC5->C5_PESOL)+','   
		cJson	+= '"cubagem":'+CValToChar(SC5->C5_XCUBAGM)+','
		cJson	+= '"volumes":'+CValToChar(SC5->C5_VOLUME1)+','
		cJson	+= '"quantidadeItens":'+CValToChar(nProd)+','
		cJson	+= '"valor":'+CValToChar(SC5->C5_XTOTPV)+','
		cJson	+= '"valorProdutos":'+CValToChar(SC5->C5_XTOTPV)+','
		cJson	+= '"formatoTransporte":""'
		cJson	+= '}'

	EndIf
	
	RestArea(aAreaSM0)

Return( cJson ) 
