#include 'protheus.ch'
#include 'parmtype.ch'

//--------------------------------------------------------------------
/*/{Protheus.doc} FTOUA016
Cancelar nota fiscal na Transpofrete
@author Caio
@since 07/02/2020
@version 1.0
/*/
//--------------------------------------------------------------------

User Function TESTE016()

	U_FTOUA016(.F.,.F.,"","","01","01")
	
Return(Nil)

User function FTOUA016(lReprocess, lLote, cIdReg, cIdPZC, cEmpPrep, cFilPrep)

Local aHeader       := {"Content-Type: application/json"}
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

		dbSelectArea("SF3")
		SF3->(dbSetOrder(1)) //F3_FILIAL+DTOS(F3_ENTRADA)+F3_NFISCAL+F3_SERIE+F3_CLIEFOR+F3_LOJA+F3_CFO+STR(F3_ALIQICM,5,2)
				
		dbSelectArea("PR1")
		PR1->(dbSetOrder(2)) //PR1_FILIAL + PR1_ALIAS + PR1_CHAVE
        
        //Verifica se existe dados a processar

        cQuery := CRLF + RTrim(" SELECT PR1.R_E_C_N_O_ AS RECNO_PR1                   ")
        cQuery += CRLF + RTrim("   FROM " + RetSqlName("PR1") + " PR1                 ")
        cQuery += CRLF + RTrim("  WHERE PR1.D_E_L_E_T_     = ' '                      ")
        cQuery += CRLF + RTrim("    AND PR1.PR1_FILIAL     = '" + xFilial("PR1") + "' ")
        cQuery += CRLF + RTrim("    AND PR1.PR1_ALIAS      = 'SF2'                    ")
        cQuery += CRLF + RTrim("    AND PR1.PR1_TIPREQ     = '5'                      ")
        cQuery += CRLF + RTrim("    AND PR1.PR1_STINT      = 'P'                      ")
                                            
        cQuery := ChangeQuery(cQuery)
          
        dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),(cWa := GetNextAlias()),.T.,.T.)
        
        Count to nQtdReg
        
        (cWa)->(DbGoTop())

        If (cWa)->(Eof())
        	
        	If GetMV("FT_CONOUTX",,.F.)
        		
        		Conout(ProcName(0) + " - " + DToC(Date()) + " - " + Time() + " - Não há dados para processamento.")
        		
        	Endif
        	
        Else
	        
	        aCriaServ := U_MonitRes("000016", 1, nQtdReg)
			cIdPZB 	  := aCriaServ[2] 
	        
			While (cWa)->(!Eof())
				
				PR1->(DbGoTo((cWa)->RECNO_PR1))
				
				cChave  := Alltrim(PR1->PR1_CHAVE)
				cJson   := ""
				cJsoRec := "" 
				
				If !SF3->(dbSeek(cChave))
					
					cMensagem := "Nota Fiscal não '" + cChave + "' encontrada na tabela SF3 - Livros Fiscais."
					U_MonitRes("000016",2,,cIdPZB,PadR(cMensagem,TamSX3("PZD_DESC")[1]),.F.,cChave,cJson,cJsoRec,cChave,lReprocess,lLote,cIdPZC)
					
				Elseif !SA1->(dbSeek(xFilial("SA1")+SF3->F3_CLIEFOR+SF3->F3_LOJA))
					
					cMensagem := "Cliente " + cCliente + " não encontrado."
					U_MonitRes("000016",2,,cIdPZB,PadR(cMensagem,TamSX3("PZD_DESC")[1]),.F.,cChave,cJson,cJsoRec,cChave,lReprocess,lLote,cIdPZC)
				
				Elseif Empty(SF3->F3_DTCANC)
					
					cMensagem := "Não consta cancelamento para a nota fiscal '" + cChave + "'."
					U_MonitRes("000016",2,,cIdPZB,PadR(cMensagem,TamSX3("PZD_DESC")[1]),.F.,cChave,cJson,cJsoRec,cChave,lReprocess,lLote,cIdPZC)
					
				//Elseif Empty(SF3->F3_CHVNFE)
				//	
				//	cMensagem := "CHVNFE da nota fiscal '" + cChave + "' não preenchido."
				//	U_MonitRes("000016",2,,cIdPZB,PadR(cMensagem,TamSX3("PZD_DESC")[1]),.F.,cChave,cJson,cJsoRec,cChave,lReprocess,lLote,cIdPZC)
					
				Elseif !Empty(SF3->F3_CHVNFE) .And. Alltrim(SF3->F3_CHVNFE) != Alltrim(PR1->PR1_OBSERV)
					
					cMensagem := "CHVNFE da nota fiscal '" + cChave + "' não preenchido."
					U_MonitRes("000016",2,,cIdPZB,PadR(cMensagem,TamSX3("PZD_DESC")[1]),.F.,cChave,cJson,cJsoRec,cChave,lReprocess,lLote,cIdPZC)
					
				Elseif .Not. Alltrim(SF3->F3_CODRET) $ "TM" .Or. Empty(SF3->F3_DESCRET)
					
					cMensagem := "Retorno do cancelamento da nota fiscal '" + cChave + "' não obtido junto a Sefaz."
					U_MonitRes("000016",2,,cIdPZB,PadR(cMensagem,TamSX3("PZD_DESC")[1]),.F.,cChave,cJson,cJsoRec,cChave,lReprocess,lLote,cIdPZC)
				
				Elseif Upper(Alltrim(SF3->F3_DESCRET)) != "CANCELAMENTO DE NF-E HOMOLOGADO" 
					
					cMensagem := "Cancelamento da nota fiscal '" + cChave + "' não homologado pela Sefaz."
					U_MonitRes("000016",2,,cIdPZB,PadR(cMensagem,TamSX3("PZD_DESC")[1]),.F.,cChave,cJson,cJsoRec,cChave,lReprocess,lLote,cIdPZC)
				
				Else
					
					If !Empty(SF3->F3_CHVNFE)
						
						cChvNF := SF3->F3_CHVNFE
						
					Endif
					
					cJson := ' {'
					
					If Empty(SF3->F3_CHVNFE) 
				
						cJson += '  "numeroNota":'+cValToChar(Val(SF3->F3_NFISCAL))+','
						cJson += '  "serieNota":"'+Alltrim(SF3->F3_SERIE)+'",'
					
					Else
						
						cJson += '  "chave":"'+Alltrim(SF3->F3_CHVNFE)+'",'
						
					Endif
					
					cJson += '  "cnpjEmissor":"'+Alltrim(SM0->M0_CGC)+'"'
									
					cJson += ' }'
					
					aRequest := U_ResInteg("000016",cJson,aHeader,,.T.,cToken)
					
					If Len(aRequest) < 3 .Or. !aRequest[1] .Or. ValType(aRequest[2]) != "O" .Or. Empty(aRequest[3])
						
						cMensagem := "Erro indeterminado na integração"
						U_MonitRes("000016",2,,cIdPZB,PadR(cMensagem,TamSX3("PZD_DESC")[1]),.F.,cChave,cJson,cJsoRec,cChave,lReprocess,lLote,cIdPZC)
						
					Else
						
						oRet    := aRequest[2]
						cJsoRec := aRequest[3]
						
						If (cStatus := oRet:Status) == "CANCELADO"
						 
							PR1->(RecLock("PR1",.F.))
								
								PR1->PR1_STINT  := "I"
								PR1->PR1_DATINT := Date()
								PR1->PR1_HRINT	:= Time()
								
							PR1->(MsUnlock())
							
							cMensagem := "Cancelamento realizado" 
							U_MonitRes("000016",2,,cIdPZB,PadR(cMensagem,TamSX3("PZD_DESC")[1]),.T.,cChave,cJson,cJsoRec,cChave,lReprocess,lLote,cIdPZC)
								
						Elseif (cStatus := oRet:Status) == "ERRO"
							
							cMensagem := "Retorno transpofrete: " +  Alltrim(oRet:Status) + " - " + Alltrim(oRet:Mensagem)
							U_MonitRes("000016",2,,cIdPZB,PadR(cMensagem,TamSX3("PZD_DESC")[1]),.F.,cChave,cJson,cJsoRec,cChave,lReprocess,lLote,cIdPZC)
							
						Endif 
						
					Endif
				        
				Endif
			
				(cWa)->(dbSkip())
				
			EndDo
			
			//Finaliza o processo na PZB
			U_MonitRes("000016",3,,cIdPZB,,.T.)
		
		Endif
		
		dbSelectArea(cWa)
		dbCloseArea()
		
	Endif 
	
	RpcClearEnv()
	
Return(Nil)