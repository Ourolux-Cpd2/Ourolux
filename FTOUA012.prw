#include 'protheus.ch'
#include 'parmtype.ch'

//--------------------------------------------------------------------
/*/{Protheus.doc} FTOUA012
Alterar a transportadora de uma pré nota
@author Caio
@since 07/02/2020
@version 1.0
/*/
//--------------------------------------------------------------------

User Function TESTE012()

	U_FTOUA012(.F.,.F.,"","","01","01",Date())
	
Return(Nil)

User function FTOUA012(lReprocess, lLote, cIdReg, cIdPZC, cEmpPrep, cFilPrep,cPedidos,dHoje,cPedidos)

Local aHeader		:= {}
Local cToken 		:= ""
Local cIdPZB    	:= ""
Local aCriaServ		:= {}
Local cQuery 		:= ""
Local aRequest		:= {}
Local cWa		    := ""
Local cChave		:= ""
Local oRet			:= Nil  
Local nQtdReg		:= 0

Default lLote		:= .F.
Default lReprocess	:= .F.
Default cIdReg		:= ""
Default cIdPZC		:= ""
Default dHoje       := Date()	
Default cPedidos    := ""

	RpcSetEnv(cEmpPrep, cFilPrep)
  
	AADD(aHeader, "Content-Type: application/json")                        
	    
	//Requisicao do acesso
	oREST := FTOUA003():New()
	oREST:RESTConn() 
	lReturn := oRest:lRetorno
	cToken  := oREST:cToken	
	
	If !lReturn
        
        Conout("Falha na autenticação Transpofrete")
        
    Else
		
		dbSelectArea("SA1")
		SA1->(dbSetOrder(1)) //A1_FILIAL+A1_COD+A1_LOJA
		
		dbSelectArea("PR1")
		PR1->(dbSetOrder(2)) //PR1_FILIAL + PR1_ALIAS + PR1_CHAVE
		
		dbSelectArea("SC5")
		SC5->(dbSetOrder(1)) //C5_FILIAL+C5_NUM
		
		dbSelectArea("SA4")
		SC5->(dbSetOrder(1)) //A4_FILIAL+A4_COD
        
        //Verifica se existe dados a processar

        cQuery := CRLF + RTrim(" SELECT PR1A.PR1_CHAVE         AS CHAVE                                                        ")
        cQuery += CRLF + RTrim("      , NVL(PR1A.R_E_C_N_O_,0) AS SA4_PR1_RECNO                                                ")
        cQuery += CRLF + RTrim("      , NVL(PR1B.R_E_C_N_O_,0) AS SC5_PR1_RECNO                                                ")
        cQuery += CRLF + RTrim("      , PR1A.PR1_OBSERV        AS TRANSP                                                       ")
        cQuery += CRLF + RTrim("   FROM " + RetSqlName("PR1") + " PR1A                                                         ")
        cQuery += CRLF + RTrim(" LEFT OUTER JOIN " + RetSqlName("PR1") + " PR1B ON PR1B.D_E_L_E_T_  = ' '                      ")
        cQuery += CRLF + RTrim("                                               AND PR1B.PR1_FILIAL  = '" + xFilial("PR1") + "' ")
        cQuery += CRLF + RTrim("                                               AND PR1B.PR1_ALIAS   = 'SC5'                    ")
        cQuery += CRLF + RTrim("                                               AND PR1B.PR1_CHAVE   = PR1A.PR1_CHAVE           ")
        cQuery += CRLF + RTrim("  WHERE PR1A.D_E_L_E_T_     = ' '                                                              ")
        cQuery += CRLF + RTrim("    AND PR1A.PR1_FILIAL     = '" + xFilial("PR1") + "'                                         ")
        cQuery += CRLF + RTrim("    AND PR1A.PR1_ALIAS      = 'SA4'                                                            ")
        cQuery += CRLF + RTrim("    AND PR1A.PR1_TIPREQ     = '1'                                                              ")
        cQuery += CRLF + RTrim("    AND PR1A.PR1_STINT      = 'P'                                                              ")
        
        If !Empty(cPedidos) 
        	
        	cPedidos := FormatIn(Alltrim(cPedidos),";")
        	
        	cQuery += CRLF + RTrim("    AND RTRIM(LTRIM(PR1A.PR1_CHAVE))   IN " + cPedidos)
        	
        Endif 
                                            
        cQuery := ChangeQuery(cQuery)
          
        dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),(cWa := GetNextAlias()),.T.,.T.)
        
        Count to nQtdReg
        
        (cWa)->(DbGoTop())

        If (cWa)->(Eof())
        	
        	If GetMV("FT_CONOUTX",,.F.)
        		
        		Conout(ProcName(0) + " - " + DToC(Date()) + " - " + Time() + " - Não há dados para processamento.")
        		
        	Endif
        	
        Else
	        
	        aCriaServ := U_MonitRes("000012", 1, nQtdReg)
			cIdPZB 	  := aCriaServ[2] 
			
			While (cWa)->(!Eof())
				
				PR1->(DbGoTo((cWa)->SC5_PR1_RECNO))
				 
				cChave  := Alltrim((cWa)->CHAVE)
				cJson   := ""
				cJsoRec := ""
				
				If PR1->PR1_TIPREQ == "1" .And. PR1->PR1_STINT == "P"
					
					cMensagem := "Pedido de venda " + cChave + " ainda está pendente de integração."
					U_MonitRes("000012",2,,cIdPZB,cMensagem,.F.,cChave,cJson,cJsoRec,cChave,lReprocess,lLote,cIdPZC)
					
				Elseif !SC5->(dbSeek(cChave))
					
					cMensagem := "Pedido de venda " + cChave + " não encontrado"
					U_MonitRes("000012",2,,cIdPZB,cMensagem,.F.,cChave,cJson,cJsoRec,cChave,lReprocess,lLote,cIdPZC)
					
				Elseif !SA1->(dbSeek(xFilial("SA1")+(cCliente := SC5->C5_CLIENTE+SC5->C5_LOJACLI)))
					
					cMensagem := "Cliente " + cCliente + " não encontrado"
					U_MonitRes("000012",2,,cIdPZB,cMensagem,.F.,cChave,cJson,cJsoRec,cChave,lReprocess,lLote,cIdPZC)
					
				Elseif !Empty(SC5->C5_NOTA)
					
					cMensagem := "Pedido " + cChave + " já faturado"
					U_MonitRes("000012",2,,cIdPZB,cMensagem,.F.,cChave,cJson,cJsoRec,cChave,lReprocess,lLote,cIdPZC)
					 
				Else
					
					cTransp := Alltrim((cWa)->TRANSP)
					
					If !SA4->(dbSeek(xFilial("SA4")+cTransp))
	
						cMensagem := "Transportadora " + cTransp + " não encontrada"
						U_MonitRes("000012",2,,cIdPZB,cMensagem,.F.,cChave,cJson,cJsoRec,cChave,lReprocess,lLote,cIdPZC)
										
					Else
						 
						aHeadStr := {}
						AAdd(aHeadStr, "Content-Type: application/json")    
						
						cJson	+= ' {"cnpjEmissorPreNotaFiscal":"'+Alltrim(SM0->M0_CGC)+'",'
						cJson	+= '  "numeroPreNotaFiscal":"'+Alltrim(SC5->C5_NUM)+'",'
						cJson	+= '  "seriePreNotaFiscal":"2",'
						cJson	+= '  "trechos":[{ "enderecoColeta":{"cep":"'+Alltrim(SM0->M0_CEPENT)+'"},'
						cJson	+= '             "enderecoEntrega":{"cep":"'+Alltrim(SA1->A1_CEP)+'"},'
						cJson	+= '             "transportadora" :{"cnpj":"'+Alltrim(SA4->A4_CGC)+'","cep":"'+Alltrim(SA4->A4_CEP)+'"}}]}'
						
						aRequest := U_ResInteg("000012", cJson, aHeader, , .T.,cToken )
						
						If !aRequest[1]
							
							cMensagem := "Erro na integração"
							U_MonitRes("000012",2,,cIdPZB,cMensagem,.F.,cChave,cJson,cJsoRec,cChave,lReprocess,lLote,cIdPZC)
							
						Else
							
							oRet    := aRequest[2]
							cJsoRec := aRequest[3]
							
							If (cStatus := oRet:Status) == "GRAVADO"
							
								PR1->(dbGoTo((cWa)->SA4_PR1_RECNO))
								
								PR1->(RecLock("PR1",.F.))
									
									PR1->PR1_STINT  := "I"
									PR1->PR1_OBSERV := Alltrim(PR1->PR1_OBSERV) // + " - Nro. Documento " + Alltrim(oRet:nroDocumento)
									PR1->PR1_DATINT := Date()
									PR1->PR1_HRINT	:= Time()
									
								PR1->(MsUnlock())
								
								PR1->(dbGoTo((cWa)->SC5_PR1_RECNO))
								
								PR1->(RecLock("PR1",.F.))
									 
									PR1->PR1_OBSERV := "Transp alterada para " + SA4->A4_COD + " - " + Alltrim(PR1->PR1_OBSERV) + " (OLD)" //- Nro. Documento " + Alltrim(oRet:nroDocumento)
									PR1->PR1_DATINT := Date()
									PR1->PR1_HRINT	:= Time()
									
								PR1->(MsUnlock())
								
								PR1->(RecLock("SC5",.F.))
									 
									SC5->C5_TRANSP := SA4->A4_COD
									
								PR1->(MsUnlock())
								
								cMensagem := "Integração OK"
								U_MonitRes("000012",2,,cIdPZB,cMensagem,.T.,cChave,cJson,cJsoRec,cChave,lReprocess,lLote,cIdPZC)
								
							Else 
								
								cMensagem := "Status obtido no retorno " + cStatus 
								U_MonitRes("000012",2,,cIdPZB,cMensagem,.F.,cChave,cJson,cJsoRec,cChave,lReprocess,lLote,cIdPZC)
								
							Endif 
							
						Endif
						
					Endif 
		  
				Endif
			
				(cWa)->(dbSkip())
				
			EndDo
			
			//Finaliza o processo na PZB
			U_MonitRes("000012",3,,cIdPZB,,.T.)
			
		Endif
		
		dbSelectArea(cWa)
		dbCloseArea()
		
	Endif 
	
	RpcClearEnv()
	
Return(Nil)