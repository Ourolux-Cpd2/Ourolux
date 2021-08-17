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

User Function TESTE007()

	U_FTOUA007(.F.,.F.,"","","01","01")
	
Return(Nil)

User Function FTOUA007(lReprocess, lLote, cIdReg, cIdPZC, cEmpPrep, cFilPrep)
    
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
Local cDescFat      := "A situação FATURADA da pré-nota fiscal não permite esta operação"
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
	
		DBSelectArea("PR1")
		
	   	cAlsPR1 := CriaTrab(Nil,.F.)
	
		//Verifica se existe dados a processar
		//cQuery := " SELECT COUNT(*) CONTADOR "                                                                     	
		//cQuery += " FROM " + RetSqlName("PR1") + " PR1  "
		//cQuery += " WHERE PR1_ALIAS IN ('SC5','SF1')    " 
		//cQuery += "   AND PR1_STINT = 'P'               "
		//cQuery += "   AND PR1_TIPREQ = '5'              "
		//cQuery += "   AND D_E_L_E_T_= ' '               " 
	    //
		//If Select(cAlsPR1) > 0; (cAlsPR1)->(dbCloseArea()); Endif  
		//dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlsPR1,.T.,.T.)   
	    //
		//nQtdReg := (cAlsPR1)->CONTADOR
	
		//Verifica se existe dados a processar
		cQuery := " SELECT PR1_FILIAL,PR1_ALIAS,PR1_RECNO,PR1_CHAVE,PR1_TIPREQ, PR1.R_E_C_N_O_ RECPR1, C5_NOTA "                                                                     	
		cQuery += " FROM " + RetSqlName("PR1") + " PR1 "
		cQuery += " LEFT OUTER JOIN " + RetSqlName("SC5") + " SC5 ON SC5.R_E_C_N_O_ = PR1.PR1_RECNO "
		cQuery += "                                              AND SC5.C5_FILIAL  = SUBSTRING(PR1_CHAVE,1,2) "
		cQuery += "                                              AND SC5.C5_NUM     = SUBSTRING(PR1_CHAVE,3,6) "
		cQuery += " WHERE PR1.PR1_ALIAS IN ('SC5','SF1')   " //exclusão de pedido de venda ou nota fiscal de devolução
		cQuery += "   AND PR1.PR1_STINT   = 'P'            "  
		cQuery += "   AND PR1.PR1_TIPREQ  = '5'            "
		cQuery += "   AND PR1.D_E_L_E_T_  = ' '            "
	    
		If Select(cAlsPR1) > 0; (cAlsPR1)->(dbCloseArea()); Endif  
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlsPR1,.T.,.T.) 
	    
	    Count To nQtdReg
	    
	    (cAlsPR1)->(DBGOTOP())
	    
	    If (cAlsPR1)->(Eof())
	    	
	    	If GetMV("FT_CONOUTX",,.T.)
	    		
	    		Conout(ProcName(0) + " - " + DToC(Date()) + " - " + Time() + " - Não há dados para processamento.")
	    		
	    	Endif
	    	
	    Else     
		
			aCriaServ := U_MonitRes("000004", 1, nQtdReg)
			cIdPZB 	  := aCriaServ[2]
			    	    
			While !(cAlsPR1)->(EOF()) 
		
		        // inicia o processo
		        cCHAVE	  := Substr((cAlsPR1)->PR1_CHAVE,1,8) //8 primeiras posições
		
		        cJson := ""
		        cJsoRec := ""
		         
		        If .F. //"XXXXXX" $ (cAlsPR1)->C5_NOTA
		        	
		        	cMsg := "Não é possível cancelar pré nota FATURADA no Transpofrete"
		        	U_MonitRes("000004", 2, , cIdPZB,cMsg, .T., cChave, cJson, cJsoRec,cChave, lReprocess, lLote, cIdPZC)
		        	
		            PR1->(DbGoTo((cAlsPR1)->RECPR1))
		                
		            RecLock("PR1",.F.)
		            
		                PR1->PR1_DATINT := Date()
		                PR1->PR1_HRINT	:= Time()		
		                PR1->PR1_STINT  := "I"
		                PR1->PR1_OBSERV := cMsg
		
		            PR1->(MsUnlock())
		            
		        Else
		        
			        // MONTAGEM DO ESTRUTURA JSON
			        cJSon	:= fuPedJSon( cCHAVE )
			        
			       // ENVIO PARA TRANSPOFRETE	
			        aRequest := U_ResInteg("000004", cJson, aHeader, , .T.,cToken )
			
			        // RETORNO DA TRANSPOFRETE
		
			        lFaturada := .F.
			        
			        If (aRequest[1] .And. aRequest[2]:Status <> "ERRO") .Or. ;
			           (aRequest[1] .And. aRequest[2]:Status == "ERRO" .And. (lFaturada := Upper(cDescFat) $ Upper(aRequest[2]:mensagem))) 
			           
			           	If lFaturada
			           		cMenssagem  := aRequest[2]:mensagem
			           	Else
			           		cMenssagem  := "Pedido Cancelado no Transpofrete"
			           	Endif
			           	
			            //Retorno em forma de objeto
			            oRet     := aRequest[2]
			            //Retorno em forma de string
			            cJsoRec := aRequest[3]
			            //GRAVANDO O LOG DA CONFIRMAÇÃO	
			            U_MonitRes("000004", 2, , cIdPZB, cMenssagem, .T., cChave, cJson, cJsoRec,cChave, lReprocess, lLote, cIdPZC)
			            
			            PR1->(DbGoTo((cAlsPR1)->RECPR1))
			                
			            RecLock("PR1",.F.)
			            
			                PR1->PR1_DATINT := Date()
			                PR1->PR1_HRINT	:= Time()		
			                PR1->PR1_STINT  := "I"
			                PR1->PR1_OBSERV := cMenssagem
			
			            PR1->(MsUnlock())
			        	
			        Else	
			        	
			                
			            cMenssagem  := "Falha no cancelamento do pedido - " + aRequest[2]:mensagem
			            cJsoRec     := aRequest[3]
			            // GRAVANDO LOG DA FALHA NO MONITOR
			            U_MonitRes("000004", 2, , cIdPZB, cMenssagem, .F., cChave, cJson, cJsoRec, cChave, lReprocess, lLote, cIdPZC)
			            
			        Endif
			        
		        Endif
		
		        (cAlsPR1)->(DBSkip())
		
			EndDo
			    
			//Finaliza o processo na PZB
			U_MonitRes("000004", 3, , cIdPZB, , .T.) 
		
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
Local nIniPed       := TamSX3("C5_FILIAL")[1]+1
Local nTamPed       := TamSX3("C5_NUM")[1]
	
	DBSelectArea("SC5")
	SC5->(DBSetOrder(1))

	SC5->(DBSeek(cPedido ))

	IF !SC5->(EOF()) .And. SC5->C5_FILIAL+SC5->C5_NUM == cPedido
	
        cJson	:= '{'
        cJson	+= '"cnpjEmissorPreNotaFiscal":"'+Alltrim(SM0->M0_CGC)+'",'
        cJson	+= '"numeroPreNotaFiscal":'+Alltrim(SC5->C5_NUM)+','
        cJson	+= '"seriePreNotaFiscal":"2"'
		cJson	+= '}'
    
    //*********************************************************************
    //** CASO ABAIO QUANDO O PEDIDO DE VENDA FOR EXCLUÍDO APÓS LIBERAÇÃO
    //*********************************************************************
        
	Elseif SC5->(EOF())
        
        cJson	:= '{'
        cJson	+= '"cnpjEmissorPreNotaFiscal":"'+Alltrim(SM0->M0_CGC)+'",'
        cJson	+= '"numeroPreNotaFiscal":'+Substr(cPedido,nIniPed,nTamPed)+','
        cJson	+= '"seriePreNotaFiscal":"2"'
		cJson	+= '}'
		
	EndIf

Return(cJson)
