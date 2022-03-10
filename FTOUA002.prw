#INCLUDE 	"PROTHEUS.CH"
#INCLUDE	"TOTVS.CH"
#INCLUDE 	"RWMAKE.CH"
#INCLUDE 	"TBICONN.CH"

// #########################################################################################
// Projeto: OUROLUX - PROJETO TRANSPOFRETE
// Modulo : Rotina p/ solicitar transpofrete contratar o frete - Integraçãoo API REST/JSON
// Fonte  : FTOUA002
// ---------+-------------------+-----------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+-----------------------------------------------------------
// 14/08/19 | Roberto Marques   | Classe para conexÃ£o Ã  API TranspoFrete
// ---------+-------------------+-----------------------------------------------------------

User Function TESTE002()

	U_FTOUA002(.F.,.F.,"","","01","01")
	
Return(Nil)


User Function FTOUA002(lReprocess, lLote, cIdReg, cIdPZC, cEmpPrep, cFilPrep)
    
Local aHeader		:= {}
Local cToken 		:= ""
Local cJSon			:= ""
Local cIdPZB    	:= ""
Local aCriaServ		:= {}
Local cQuery 		:= ""
Local aRequest		:= {}
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
		DBSelectArea("SC5")
		DBSelectArea("SA4")
		
		SC5->(dbSetOrder(1))
			
 		cAlsPR1 := CriaTrab(Nil,.F.)

		//Verifica se existe dados a processar
		//cQuery := " SELECT COUNT(*) CONTADOR "                                                                     	
		//cQuery += "   FROM " + RetSqlName("PR1") + " PR1 "
		//cQuery += "  WHERE ((PR1_ALIAS = 'SC5' AND PR1_STINT = 'I') OR (PR1_ALIAS = 'DAI' AND PR1_STINT = 'P')) "
		//cQuery += "    AND PR1_TIPREQ = '1' AND D_E_L_E_T_ = ' ' "  
	    //
		//If Select(cAlsPR1) > 0; (cAlsPR1)->(dbCloseArea()); Endif  
		//dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlsPR1,.T.,.T.)
        //
		//nQtdReg := (cAlsPR1)->CONTADOR

		//Verifica se existe dados a processar
		cQuery := " SELECT PR1_FILIAL, PR1_ALIAS,PR1_RECNO,PR1_CHAVE, R_E_C_N_O_ RECPR1 "                                                                     	
		cQuery += "   FROM " + RetSqlName("PR1") + " PR1 "
		cQuery += "  WHERE ((PR1_ALIAS = 'SC5' AND PR1_STINT = 'I') OR (PR1_ALIAS = 'DAI' AND PR1_STINT = 'P')) "
		cQuery += "    AND PR1_TIPREQ = '1' AND D_E_L_E_T_ = ' ' " 
	
		If Select(cAlsPR1) > 0; (cAlsPR1)->(dbCloseArea()); Endif  
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlsPR1,.T.,.T.)
	    
	    Count To nQtdReg
	    
	    (cAlsPR1)->(DBGOTOP())
	    
	    If (cAlsPR1)->(Eof())
	    	
	    	If GetMV("FT_CONOUTX",,.T.)
	    		
	    		Conout(ProcName(0) + " - " + DToC(Date()) + " - " + Time() + " - Não há dados para processamento.")
	    		
	    	Endif
	    	
	    Else      
		
			aCriaServ := U_MonitRes("000003", 1, nQtdReg)
			cIdPZB 	  := aCriaServ[2]
		    
			While !(cAlsPR1)->(EOF()) 
			
				cChave  := ""
				cJson   := ""
				cJsoRec := ""
				cChave  := ""
				
				// inicia o processo
				cChave	  := Alltrim((cAlsPR1)->PR1_CHAVE)
		
				// MONTAGEM DA ESTRUTURA JSON 
				cJSon	:= fuPedJSon( cCHAVE )

				//Grava tabela integradora
				PR1->(DbGoTo((cAlsPR1)->RECPR1))

				//Se não achar o pedido o pedido para montar o JSON
				If Empty(cJson)	
					
					PR1->(RecLock("PR1", .F.))

						PR1->PR1_IDEXT := "Deletado da PR1, pois não existe mais o pedido ativo na SC5."
					
					PR1->(MsUnlock())

					PR1->(RecLock("PR1", .F.))

						PR1->(DbDelete())
					
					PR1->(MsUnlock())
					
					(cAlsPR1)->(DbSkip()) 
					Loop

				EndIf
					
				// ENVIO PARA TRANSPOFRETE	
				aRequest := U_ResInteg("000003", cJson, aHeader, , .T.,cToken )
		
				If aRequest[1] .And. aRequest[2]:Status <> "ERRO"
	
					//Retorno em forma de objeto
					oRet     := aRequest[2]
	
					//Retorno em forma de string
					cJsoRec := aRequest[3]
	
					// GRAVAÇAO DO LOG DE CONFIRMAÇÃO DE ENVIO	
					If oRet:Trechos[1]:Status == "NAO CALCULADO"
	
						cMenssagem  := "Simulacao de frete do doc : " + cValToChar(aRequest[2]:nrodocumento) + " não realizada."
						U_MonitRes("000003", 2, , cIdPZB, cMenssagem, .F., cChave, cJson, cJsoRec, cChave, lReprocess, lLote, cIdPZC)
	
						(cAlsPR1)->(DBSkip())
						Loop
					
					EndIf
						
					//Grava transportadora no pedido de venda
					
					IF CCHAVE == "01654113"
						CCHAVE  := CCHAVE 
					Endif 
					
					If !SC5->(dbSeek(cChave))
					
						cMensagem := "Pedido " + cChave + " não encontrado."
						U_MonitRes("000003",2,,cIdPZB,PadR(cMensagem,TamSX3("PZD_DESC")[1]),.F.,cChave,cJson,cJsoRec,cChave,lReprocess,lLote,cIdPZC)
						
					Else
		
						SA4->(DBSetOrder(3))
						
						//Grava transportadora no pedido
						If SA4->(DBSeek(xFilial("SA4") + oRet:Trechos[1]:CNPJTRANSPORTADORA))
		
							cMenssagem  := "Simulacao de frete do doc : " + cValToChar(aRequest[2]:nrodocumento) + " realizada com sucesso."
							U_MonitRes("000003", 2, , cIdPZB, cMenssagem, .T., cChave, cJson, cJsoRec, cChave, lReprocess, lLote, cIdPZC)
							
							SC5->(RecLock("SC5",.F.))
		
								SC5->C5_TRANSP := SA4->A4_COD
		
							SC5->(MsUnlock())
		
							PR1->(RecLock("PR1",.F.))
							 
								If PR1->PR1_ALIAS == "SC5"
									PR1->PR1_TIPREQ := "3"
								Endif
								
								PR1->PR1_DATINT := Date()
								PR1->PR1_HRINT	:= Time()
								PR1->PR1_STINT := "I"
								PR1->PR1_OBSERV := cMenssagem
							
							PR1->(MsUnlock())
		
						Else
		
							cMenssagem := "Transportadora não cadastrada no Protheus."
		
							// GRAVAÇAO DO LOG DE CONFIRMAÇÃO DE ENVIO	
							U_MonitRes("000003", 2, , cIdPZB, cMenssagem, .F., cChave, cJson, cJsoRec, cChave, lReprocess, lLote, cIdPZC)
		
						EndIf 
					
					Endif
				Else
						
					cMenssagem  := "Falha na integracao - " + Iif(ValType(aRequest[2]:mensagem)=="C",aRequest[2]:mensagem,"Nulo") //Caio Menezes - 05/02/2020 - Tratativa retorno Nulo 
					cJsoRec     := aRequest[3]
	
					//GRAVAÇÃO DO PROCESSO DA FALHA 
					U_MonitRes("000003", 2, , cIdPZB, cMenssagem, .F., cChave, cJson, cJsoRec, cChave, lReprocess, lLote, cIdPZC)
			
				Endif     
				
				(cAlsPR1)->(DBSkip())
					
			EndDo
			    
			//Finaliza o processo na PZB
			U_MonitRes("000003", 3, , cIdPZB, , .T.) 
		
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
/* ROBERTO MARQUES                           */
/* Função para montagem da Estrutura JSon    */
/*********************************************/
Static Function fuPedJSon( cPedido )

Local cJson			:= ""
	
	DBSelectArea("SC5")
	SC5->(DBSetOrder(1))
	SC5->(DBSeek(cPedido ))

	IF !SC5->(EOF()) .And. SC5->C5_FILIAL+SC5->C5_NUM == cPedido

		aAreaSM0 := SM0->(GetArea())
	
		SM0->(DbSeek(PadR(cEmpAnt,Len(cEmpAnt))+SC5->C5_FILIAL))
	
		DBSelectArea("SA1")
		SA1->(DBSetOrder(1))
	
		SA1->(DBSeek(xFilial("SA1") + SC5->C5_CLIENTE + SC5->C5_LOJACLI))
		
		cJson	:= '{'
		cJson	+= '"cnpjEmissorPreNotaFiscal":"'+Alltrim(SM0->M0_CGC)+'",'
		cJson	+= '"numeroPreNotaFiscal":"'+Alltrim(SC5->C5_NUM)+'",'
		cJson	+= '"seriePreNotaFiscal":"2"'
		cJson	+= '}'
		
		RestArea(aAreaSM0)
				    
	Endif

Return( cJson ) 
