#INCLUDE "PROTHEUS.CH"

User Function EICPO400

	Local cParam   := ""  
	Local _cNumPC  := ""
	Local _cRet    := .T.
	Local _lRegEst := .F.
	Local _lRegAlt := .F.
	Local _cQryEST := ""    
	Local cQuery   := ""
	Local x, y 	   := 0
	Local aItemPO  := {}
	Local lPriCom  := .F.
	Local cDeptoSC := SuperGetMV("ES_DEPTOSC",.F.,"000000025")
	Local cNumSI   := ""
	Local aSldSI   := {}
	Local lParcial := .F.

	Begin Sequence    
   		
   		If Type("ParamIXB") == "C"
			cParam := ParamIXB
   		Endif                
	
			Do Case 
				Case cParam == "AROTINA"
      			aAdd(aRotina,{"Ctas a Pagar"  ,"u_SV_EICCP('PO')",0,2})
				aAdd(aRotina,{"Inc. Historico","u_INCHIST()"     ,0,4})
            
      		// Inicio - Projeto Jonato - 23/06/2017
      		Case cParam == "ANTES_GET_SI"
        		@06,400  BUTTON "Volume Total" SIZE 36,11 ACTION (u_SvCalCub("SW2")) 

   			Case cParam == "WORK_DESPESAS"
        		U_SvValQtd(Work->WKQTDE,"WK3")
      		// Fim - Projeto Jonato - 23/06/2017
      		
      		Case cParam == "PO400ESTOR_VERIFICA_PAG_ANT"   
      			lTrataPGAntecipado:= .F.
            
            // Valida digitação departamento na Solicitação de Compras - Claudino 16/01/14.
        	Case cParam == "VAL_GRAVA_PO"
				
				If Empty(ALLTRIM(SC1->C1_XDEPART))
					
					ApMsgStop("Por favor informar o departamento no cabeçalho da SC", "EICPO400_RDM" )        
					
				EndIf
        		       	
        	// Gravar departamento no Pedido de Importação - Claudino 17/12/13.
      		Case cParam == "ANTES_GRAVAR"

				If !Empty(ALLTRIM(cDeptoSC)) 
					
					_cNumPC := SC1->C1_PEDIDO
					Dbselectarea("SC7")
					SC7->(dbGoTop())
					SC7->(dbSetOrder(1))
					If SC7->(dbSeek(xFilial("SC7")+_cNumPC))
						While !SC7->(Eof()) .And. _cNumPC == SC7->C7_NUM
							RecLock("SC7",.F.)
								SC7->C7_XDEPART := cDeptoSC
							MsUnlock("SC7")
							
							If SC7->C7_CONAPRO == "B"
								_lRegAlt := .T.
							EndIf
							SC7->(DbSkip())
						EndDo
					EndIf	
			        
					Dbselectarea("SC7")
					SC7->(dbGoTop())
					SC7->(dbSetOrder(1))
					If SC7->(dbSeek(xFilial("SC7")+_cNumPC))
						If _lRegAlt
							U_APCIniciar("01")
						EndIf
					EndIf    
				
				Else
			
					ApMsgStop("Por favor na proxima SC que lançar, informar o departamento no cabeçalho da SC", "EICPO400_RDM" )        
					Dbselectarea("SC7")
					SC7->(dbGoTop())
					SC7->(dbSetOrder(1))
					If SC7->(dbSeek(xFilial("SC7")+_cNumPC))
						If _lRegAlt
							U_APCIniciar("01")
						EndIf
					EndIf
									
				EndIf
   			Case cParam == "DEPOIS_ESTORNO_PO"
   		    	_cQryEST := " SELECT "
				_cQryEST += "		SC7.C7_FILIAL, "
				_cQryEST += "		SC7.C7_NUM, "
				_cQryEST += "		SC7.C7_WFID "
				_cQryEST += " FROM "
				_cQryEST += 		RetSqlName("SC7") + " SC7 "
				_cQryEST += " WHERE "
				_cQryEST += " 		SC7.D_E_L_E_T_ = ' ' AND "
				_cQryEST += "		SC7.C7_FILIAL = '" + xFilial("SC7") + "' AND "
				_cQryEST += " 		SC7.C7_NUM = '" + SC7->C7_NUM + "' "
				_cQryEST += " GROUP BY "
				_cQryEST += " 		SC7.C7_FILIAL, "
				_cQryEST += "		SC7.C7_NUM, "
				_cQryEST += "		SC7.C7_WFID "
				_cQryEST += " ORDER BY "
				_cQryEST += " 		SC7.C7_FILIAL, "
				_cQryEST += "		SC7.C7_NUM "
				
				_cQryEST := ChangeQuery(_cQryEST)
				
				If Select("QRYEST") > 0
					dbSelectArea("QRYEST")
					QRYEST->(dbCloseArea())
				EndIf
		
				DbUseArea(.T.,"TOPCONN",TCGenQry(,,_cQryEST),"QRYEST",.F.,.T.)
				
				While QRYEST->(!Eof())
					_lRegEst := .T.
					QRYEST->(dbSkip())
				EndDo
	   		    
	   		    If Select("QRYEST") > 0
					dbSelectArea("QRYEST")
					QRYEST->(dbCloseArea())
				EndIf
	   		    
	   		    If _lRegEst	
	   		    	U_APCIniciar("01")
	   		    Else
	   		    	If !Empty(Alltrim(SC7->C7_WFID))
						_nAt := At("/",Alltrim(SC7->C7_WFID))
						If _nAt == 0
							For x:= Val(SubStr(Alltrim(SC7->C7_WFID),Len(Alltrim(SC7->C7_WFID)),1)) To 0 Step -1					
								CONOUT("Exclusão - Finalizando Processo Nivel 01: " + SubStr(Alltrim(SC7->C7_WFID),1,Len(Alltrim(SC7->C7_WFID))-1) + cValToChar(x))		        	
			        			WFKillProcess(SubStr(Alltrim(SC7->C7_WFID),1,Len(Alltrim(SC7->C7_WFID))-1) + cValToChar(x))
			    			Next x
						Else
							For x:= Val(SubStr(Alltrim(SC7->C7_WFID),Len(Alltrim(SC7->C7_WFID)),1)) To 0 Step -1					
								CONOUT("Exclusão - Finalizando Processo Nivel 02: " + SubStr(Alltrim(SC7->C7_WFID),_nAt+1,Len(Alltrim(SC7->C7_WFID))-_nAt-1) + cValToChar(x))
								WFKillProcess(SubStr(Alltrim(SC7->C7_WFID),_nAt+1,Len(Alltrim(SC7->C7_WFID))-_nAt-1) + cValToChar(x))
							Next x
					
							For y:= Val(SubStr(SubStr(Alltrim(SC7->C7_WFID),1,_nAt-1),Len(SubStr(Alltrim(SC7->C7_WFID),1,_nAt-1)),1)) To 0 Step -1					
								CONOUT("Exclusão - Finalizando Processo Nivel 01: " + SubStr(Alltrim(SC7->C7_WFID),1,_nAt-2) + cValToChar(y))		        	
			   					WFKillProcess(SubStr(Alltrim(SC7->C7_WFID),1,_nAt-2) + cValToChar(y))
			   				Next y
						EndIf
					EndIf
   				EndIf

				cQuery := " SELECT W0_C1_NUM FROM " + RetSqlName("SW0")
				cQuery += " WHERE D_E_L_E_T_ = '' "
				cQuery += " AND W0__NUM = '"+SW1->W1_SI_NUM+"'"
				
				If Select("W0SC") > 0
					W0SC->(dbCloseArea())
				EndIf				
				
				DbUseArea( .T.,"TOPCONN",TCGENQRY(,,cQuery),"W0SC",.F.,.T. )

				U_OURO010("EXCLUI PR",SW1->W1_XFILORI,W0SC->W0_C1_NUM)//Excluir titulos de PR para Solicitação aprovada

				cQuery := " SELECT W1_COD_I, W1_SALDO_Q, W1_QTDE, W1_SI_NUM FROM " + RetSqlName("SW1")
				cQuery += " WHERE W1_SI_NUM = (SELECT DISTINCT(W3_SI_NUM) FROM " + RetSqlName("SW3")
				cQuery += " 					WHERE D_E_L_E_T_ = '' "
				cQuery += " 					AND W3_PO_NUM  = '"+Iif(Empty(TPO_NUM),SC7->C7_PO_EIC,TPO_NUM)+"') "
				cQuery += " AND D_E_L_E_T_ = '' "
				cQuery += " AND W1_FABR = '' "
				cQuery += " AND W1_FORN = '' "
				
				If Select("SLDSI") > 0
					SLDSI->(dbCloseArea())
				EndIf				
				
				DbUseArea( .T.,"TOPCONN",TCGENQRY(,,cQuery),"SLDSI",.F.,.T. )

				While SLDSI->(!EOF())
					If SLDSI->W1_SALDO_Q > 0
						AADD(aSldSI,{SLDSI->W1_COD_I,SLDSI->W1_SALDO_Q,SLDSI->W1_SI_NUM})
						If (SLDSI->W1_QTDE - SLDSI->W1_SALDO_Q) > 0
							lParcial := .T.
						EndIf
					EndIf

					cNumSI := SLDSI->W1_SI_NUM
					SLDSI->(dbSkip())
				EndDo

				If lParcial
					U_OURO010("INCLUI PR PARCIAL",SW1->W1_XFILORI,W0SC->W0_C1_NUM,aSldSI)//Geração de PR para Solicitação aprovada
				Else
					U_OURO010("INCLUI PR",SW1->W1_XFILORI,W0SC->W0_C1_NUM)//Geração de PR para Solicitação aprovada
				EndIf

			Case cParam == "APOS_CONFERENCIAFINAL"
				cQuery := " SELECT W3_COD_I, W3_SI_NUM FROM " + RetSqlName("SW3")
				cQuery += " WHERE D_E_L_E_T_ = '' "
				cQuery += " AND W3_PO_NUM = '"+SW2->W2_PO_NUM+"' "

				If Select("W3TMP") > 0
					W3TMP->(dbCloseArea())
				EndIf

				DbUseArea( .T.,"TOPCONN",TCGENQRY(,,cQuery),"W3TMP",.F.,.T. )

				While W3TMP->(!EOF())
					cQuery := " SELECT COUNT(*) AS QUANTIDADE FROM " + RetSqlName("SD1")
					cQuery += " WHERE D_E_L_E_T_ = '' "
					cQuery += " AND D1_FORNECE = '"+SW2->W2_FORN+"'
					cQuery += " AND D1_LOJA = '"+SW2->W2_FORLOJ+"'
					cQuery += " AND D1_COD = '"+W3TMP->W3_COD_I+"' "

					If Select("D1TMP") > 0
						D1TMP->(dbCloseArea())
					EndIf				
					
					DbUseArea( .T.,"TOPCONN",TCGENQRY(,,cQuery),"D1TMP",.F.,.T. )

					If D1TMP->QUANTIDADE == 0
						lPriCom := .T.
						AADD(aItemPO,{SW2->W2_PO_NUM,SW2->W2_FORN,W3TMP->W3_COD_I,W3TMP->W3_SI_NUM})
					EndIf 

					W3TMP->(dbSkip())
				EndDo

				If lPriCom
					RecLock("SW2",.F.)
					SW2->W2_X1COMP := "S"
					SW2->(MsUnlock())
					U_MAILSOP(aItemPO)
					MsgInfo("ALERTA DE PRIMEIRA COMPRA: Favor confirmar o prazo de entrega no CD com o departamento de S&OP")
				EndIF

				cQuery := " SELECT SUM(W3_XCUBAGE) AS CUBAGEM FROM " + RetSqlName("SW3") 
				cQuery += " WHERE D_E_L_E_T_ = '' "
				cQuery += " AND W3_PO_NUM = '"+SW2->W2_PO_NUM+"' "
				cQuery += " AND W3_SEQ = '0' "

				If Select("XMT3") > 0
					XMT3->(dbCloseArea())
				EndIf				
				
				DbUseArea( .T.,"TOPCONN",TCGENQRY(,,cQuery),"XMT3",.F.,.T. )

				If XMT3->CUBAGEM == 0
					Alert("Atencao cubagem do PO esta zerada!!!")
				EndIf

				RecLock("SW2",.F.)
				SW2->W2_MT3 := XMT3->CUBAGEM
				SW2->(MsUnlock())

				cQuery := " SELECT W1_COD_I, W1_SALDO_Q, W1_QTDE, W1_SI_NUM FROM " + RetSqlName("SW1")
				cQuery += " WHERE W1_SI_NUM = (SELECT DISTINCT(W3_SI_NUM) FROM " + RetSqlName("SW3")
				cQuery += " 					WHERE D_E_L_E_T_ = '' "
				cQuery += " 					AND W3_PO_NUM  = '"+SW2->W2_PO_NUM+"') "
				cQuery += " AND D_E_L_E_T_ = '' "
				cQuery += " AND W1_FABR = '' "
				cQuery += " AND W1_FORN = '' "
				
				If Select("SLDSI") > 0
					SLDSI->(dbCloseArea())
				EndIf				
				
				DbUseArea( .T.,"TOPCONN",TCGENQRY(,,cQuery),"SLDSI",.F.,.T. )

				While SLDSI->(!EOF())
					If SLDSI->W1_SALDO_Q > 0
						AADD(aSldSI,{SLDSI->W1_COD_I,SLDSI->W1_SALDO_Q,SLDSI->W1_SI_NUM})
						If (SLDSI->W1_QTDE - SLDSI->W1_SALDO_Q) > 0
							lParcial := .T.
						EndIf
					EndIf

					cNumSI := SLDSI->W1_SI_NUM
					SLDSI->(dbSkip())
				EndDo

				cQuery := " SELECT W0_C1_NUM FROM " + RetSqlName("SW0")
				cQuery += " WHERE D_E_L_E_T_ = '' "
				cQuery += " AND W0__NUM = '"+cNumSI+"'"
				
				If Select("W0SC") > 0
					W0SC->(dbCloseArea())
				EndIf				
				
				DbUseArea( .T.,"TOPCONN",TCGENQRY(,,cQuery),"W0SC",.F.,.T. )

				U_OURO010("EXCLUI PR",SW1->W1_XFILORI,W0SC->W0_C1_NUM)//Excluir titulos de PR para Solicitação aprovada
				
				If !Empty(aSldSI)
					If lParcial
						U_OURO010("INCLUI PR PARCIAL",SW1->W1_XFILORI,W0SC->W0_C1_NUM,aSldSI)//Geração de PR para Solicitação aprovada
					Else
						U_OURO010("INCLUI PR",SW1->W1_XFILORI,W0SC->W0_C1_NUM)//Geração de PR para Solicitação aprovada
					EndIf
				EndIf


				 
		End Case

	End Sequence

Return _cRet
