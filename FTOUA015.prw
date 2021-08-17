#include 'protheus.ch'
#include 'parmtype.ch'

//--------------------------------------------------------------------
/*/{Protheus.doc} FTOUA015
Informar pagamento de fatura para Transpofrete
@author Caio
@since 07/02/2020
@version 1.0
/*/
//--------------------------------------------------------------------

User Function TESTE015()

	U_FTOUA015(.F.,.F.,"","","01","01")
	
Return(Nil)

User function FTOUA015(lReprocess, lLote, cIdReg, cIdPZC, cEmpPrep, cFilPrep)

Local aHeader		:= {}
Local cToken 		:= ""
Local cIdPZB    	:= ""
Local aCriaServ		:= {}
Local cQuery 		:= ""
Local aRequest		:= {}
Local cWa		    := ""
Local cCHAVE		:= ""
Local oRet			:= Nil  
Local nQtdReg		:= 0

Default lLote		:= .F.
Default lReprocess	:= .F.
Default cIdReg		:= ""
Default cIdPZC		:= ""	

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
		
		dbSelectArea("SA2")
		SA2->(dbSetOrder(1)) //A2_FILIAL+A2_COD+A2_LOJA
		
		dbSelectArea("PR1")
		PR1->(dbSetOrder(2)) //PR1_FILIAL + PR1_ALIAS + PR1_CHAVE 
        
        //Verifica se existe dados a processar

        cQuery := CRLF + RTrim(" SELECT PR1A.R_E_C_N_O_ AS RECNO_PR1                                 ")
        cQuery += CRLF + RTrim("      , PR1B.PR1_CHAVE  AS DADOS_TRANSPO                             ")
        cQuery += CRLF + RTrim("   FROM " + RetSqlName("PR1") + " PR1A                               ")
        cQuery += CRLF + RTrim("  INNER JOIN " + RetSqlName("PR1") + " PR1B ON PR1B.D_E_L_E_T_ = ' ' ")
        cQuery += CRLF + RTrim("                                           AND PR1B.PR1_FILIAL = '" + xFilial("PR1") + "' ")
        cQuery += CRLF + RTrim("                                           AND PR1B.PR1_ALIAS      = 'SE2'                ")
        cQuery += CRLF + RTrim("                                           AND PR1B.PR1_RECNO      = PR1A.PR1_RECNO       ")
        cQuery += CRLF + RTrim("                                           AND PR1B.PR1_TIPREQ     = '1'                  ")
        cQuery += CRLF + RTrim("                                           AND PR1B.PR1_STINT      = 'I'                  ")
        cQuery += CRLF + RTrim("  WHERE PR1A.D_E_L_E_T_     = ' '                                   ")
        cQuery += CRLF + RTrim("    AND PR1A.PR1_FILIAL     = '" + xFilial("PR1") + "'              ")
        cQuery += CRLF + RTrim("    AND PR1A.PR1_ALIAS      = 'SE2'                                 ")
        cQuery += CRLF + RTrim("    AND PR1A.PR1_TIPREQ     = '2'                                   ")
        cQuery += CRLF + RTrim("    AND PR1A.PR1_STINT      = 'P'                                   ")
                                            
        cQuery := ChangeQuery(cQuery)
          
        dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),(cWa := GetNextAlias()),.T.,.T.)
        
        Count to nQtdReg
        
        (cWa)->(DbGoTop())

        If (cWa)->(Eof())
        	
        	If GetMV("FT_CONOUTX",,.F.)
        		
        		Conout(ProcName(0) + " - " + DToC(Date()) + " - " + Time() + " - Não há dados para processamento.")
        		
        	Endif
        	
        Else
	        
	        aCriaServ := U_MonitRes("000015", 1, nQtdReg)
			cIdPZB 	  := aCriaServ[2] 
			
			While (cWa)->(!Eof())
				
				PR1->(dbGoTo((cWa)->RECNO_PR1))
				SE2->(dbGoTo(PR1->PR1_RECNO))
				
				cChave  := RTrim(PR1->PR1_CHAVE) + " " + (cWa)->DADOS_TRANSPO
				cJson   := ""
				cJsoRec := ""
				
				cSepara := (cWa)->DADOS_TRANSPO
				nHifen  := At("-",cSepara)
				nTamFil := Len(xFilial("SE2"))
				
				cIdFat  := Substr(cSepara,nTamFil+1,nHifen-1-nTamFil)
				cNumFat := Substr(cSepara,nHifen+1,Len(cSepara)-nHifen)
				
				cDtPgto := Alltrim(DToS(SE2->E2_BAIXA))
				If !Empty(cDtPgto)
					cDtPgto := Substr(cDtPgto,1,4) + "-" + Substr(cDtPgto,5,2) + "-" + Substr(cDtPgto,7,2)
				Endif
				
				If !SA2->(dbSeek(xFilial("SA2")+SE2->E2_FORNECE+SE2->E2_LOJA))
					
					cMensagem := "Fornecedor '" + SE2->E2_FORNECE + "' não encontrado"
					U_MonitRes("000015",2,,cIdPZB,PadR(cMensagem,TamSX3("PZD_DESC")[1]),.F.,cChave,cJson,cJsoRec,cChave,lReprocess,lLote,cIdPZC)
					
				Else
					
					cJson := CRLF + '{'
					cJson += CRLF + ' "oidFatura":'+cValToChar(Val(cIdFat))+','
					cJson += CRLF + ' "numeroFatura":'+cValToChar(Val(cNumFat))+','
					If !Empty(cDtPgto)
						cJson += CRLF + ' "dataPagamento":"'+cDtPgto+'",'
					Endif
					cJson += CRLF + ' "cnpjTransportadora":'+cValToChar(Val(SA2->A2_CGC))
					cJson += CRLF + '}
					
					aRequest := U_ResInteg("000015", cJson, aHeader, , .T.,cToken )
					 
					If !aRequest[1]
						 
						cMensagem := "Erro na integração (retorno indefinido)."
						U_MonitRes("000012",2,,cIdPZB,PadR(cMensagem,TamSX3("PZD_DESC")[1]),.F.,cChave,cJson,cJsoRec,cChave,lReprocess,lLote,cIdPZC)
						
					Else
						
						oRet    := aRequest[2]
						cJsoRec := aRequest[3]
						
						if Upper(Alltrim(oRet:STATUS)) == "CONFIRMADO"
						
							PR1->(RecLock("PR1",.F.))
								
								PR1->PR1_STINT  := "I"
								PR1->PR1_DATINT := Date()
								PR1->PR1_HRINT	:= Time()
								
							PR1->(MsUnlock())
							 
							cMensagem := "Status pagamento integrado com sucesso"
							U_MonitRes("000015",2,,cIdPZB,PadR(cMensagem,TamSX3("PZD_DESC")[1]),.T.,cChave,cJson,cJsoRec,cChave,lReprocess,lLote,cIdPZC)
							 
						Else
							 
							cMensagem := "Falha ao informar status de pagamento. " + oRet:mensagem
							U_MonitRes("000015",2,,cIdPZB,PadR(cMensagem,TamSX3("PZD_DESC")[1]),.F.,cChave,cJson,cJsoRec,cChave,lReprocess,lLote,cIdPZC)
						
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