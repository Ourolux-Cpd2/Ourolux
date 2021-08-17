#INCLUDE "PROTHEUS.CH"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±º Programa ³ MT120FIM() ³ Autor ³ Claudino P Domingues ³ Data ³ 01/11/13 º±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±º Funcao Padrao ³ MATA120                                                º±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±º Desc.    ³ Ponto de entrada executado no final do Pedido de Compra.    º±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

User Function MT120FIM()

	Local _aArea    := GetArea()
	Local _aAreaSC7 := SC7->(GetArea())
	
	Local _cQryDEL  := ""
	Local _nOpcx    := PARAMIXB[1]
	Local _cNumPC   := PARAMIXB[2]   
	Local _nOpcC    := PARAMIXB[3] // Indica se a acao foi Cancelada = 0  ou Confirmada = 1
	Local x			:= 0
	Local y			:= 0
	Local cDeptoEIC	:= SuperGetMV("ES_DPTOEIC",.F.,"000000027")
	Local cDptoImp	:= SuperGetMV("ES_DPTOIMP",.F.,"") //000000035
	Local cDespImp	:= SuperGetMV("ES_DESPIMP",.F.,"") //201/202/203/204/205/405/415
	
	If (INCLUI .Or. ALTERA) .And. (_nOpcC == 1)  
    
		Dbselectarea("SC7")
		SC7->(dbGoTop())
		SC7->(dbSetOrder(1))
		If SC7->(dbSeek(xFilial("SC7")+_cNumPC))
			While !SC7->(EOF()) .And. xFilial("SC7") == SC7->C7_FILIAL .And. _cNumPC == SC7->C7_NUM
				If l120Auto .And. Alltrim(SC7->C7_PRODUTO) == "COMISSAO" // Execauto Pedido de Compra referente a Comissão.
					RecLock("SC7",.F.)
						SC7->C7_XDEPART := "000000008"
					MsUnlock("SC7")
				Else
					// Claudino Domingues - 30/08/2017
					If IsInCallStack("EICPO400")
						RecLock("SC7",.F.)
							SC7->C7_XDEPART := SC1->C1_XDEPART
						MsUnlock("SC7")
					ElseIf IsInCallStack("EICDI502")
						If Empty(SC7->C7_XDEPART)
							RecLock("SC7",.F.)
								If SubStr(SC7->C7_PRODUTO,1,3) == "EIC" .AND. (SubStr(SC7->C7_PRODUTO,4,3) $ cDespImp)
									SC7->C7_XDEPART := cDptoImp
								Else
									SC7->C7_XDEPART := cDeptoEIC
								EndIf
							MsUnlock("SC7")
						EndIf
					Else
						If !Empty(ALLTRIM(_cDepSC7))
							RecLock("SC7",.F.)
								SC7->C7_XDEPART := _cDepSC7
							MsUnlock("SC7")
						EndIf	
					EndIf
				EndIf
				SC7->(Dbskip())
			EndDo
			// MOA - 22/08/2019 - 17:55HS - Retirado o preenchimento de grupos de aprovação para substituir grupo "000001"!

			A120Trigger('C7_APROV') 
		Else
			_cQryDEL := " SELECT "
			_cQryDEL += "		SC7.C7_FILIAL, "
			_cQryDEL += "		SC7.C7_NUM, "
			_cQryDEL += "		SC7.C7_WFID "
			_cQryDEL += " FROM "
			_cQryDEL += 		RetSqlName("SC7") + " SC7 "
			_cQryDEL += " WHERE "
			_cQryDEL += " 		SC7.D_E_L_E_T_ = '*' AND "
			_cQryDEL += "		SC7.C7_FILIAL = '" + xFilial("SC7") + "' AND "
			_cQryDEL += " 		SC7.C7_NUM = '" + _cNumPC + "' "
			_cQryDEL += " GROUP BY "
			_cQryDEL += " 		SC7.C7_FILIAL, "
			_cQryDEL += "		SC7.C7_NUM, "
			_cQryDEL += "		SC7.C7_WFID "
			_cQryDEL += " ORDER BY "
			_cQryDEL += " 		SC7.C7_FILIAL, "
			_cQryDEL += "		SC7.C7_NUM "
			
			_cQryDEL := ChangeQuery(_cQryDEL)
			
			If Select("QRYDEL") > 0
				dbSelectArea("QRYDEL")
				QRYDEL->(dbCloseArea())
			EndIf
	
			DbUseArea(.T.,"TOPCONN",TCGenQry(,,_cQryDEL),"QRYDEL",.F.,.T.)
			
			While QRYDEL->(!Eof())
				If !Empty(Alltrim(QRYDEL->C7_WFID))
					_nAt := At("/",Alltrim(QRYDEL->C7_WFID))
					If _nAt == 0
						For x:= Val(SubStr(Alltrim(QRYDEL->C7_WFID),Len(Alltrim(QRYDEL->C7_WFID)),1)) To 0 Step -1					
							CONOUT("Exclusão - Finalizando Processo Nivel 01: " + SubStr(Alltrim(QRYDEL->C7_WFID),1,Len(Alltrim(QRYDEL->C7_WFID))-1) + cValToChar(x))		        	
		        			WFKillProcess(SubStr(Alltrim(QRYDEL->C7_WFID),1,Len(Alltrim(QRYDEL->C7_WFID))-1) + cValToChar(x))
		    			Next x
					Else
						For x:= Val(SubStr(Alltrim(QRYDEL->C7_WFID),Len(Alltrim(QRYDEL->C7_WFID)),1)) To 0 Step -1					
							CONOUT("Exclusão - Finalizando Processo Nivel 02: " + SubStr(Alltrim(QRYDEL->C7_WFID),_nAt+1,Len(Alltrim(QRYDEL->C7_WFID))-_nAt-1) + cValToChar(x))
							WFKillProcess(SubStr(Alltrim(QRYDEL->C7_WFID),_nAt+1,Len(Alltrim(QRYDEL->C7_WFID))-_nAt-1) + cValToChar(x))
						Next x
						
						For y:= Val(SubStr(SubStr(Alltrim(QRYDEL->C7_WFID),1,_nAt-1),Len(SubStr(Alltrim(QRYDEL->C7_WFID),1,_nAt-1)),1)) To 0 Step -1					
							CONOUT("Exclusão - Finalizando Processo Nivel 01: " + SubStr(Alltrim(QRYDEL->C7_WFID),1,_nAt-2) + cValToChar(y))		        	
				   			WFKillProcess(SubStr(Alltrim(QRYDEL->C7_WFID),1,_nAt-2) + cValToChar(y))
				   		Next y
					EndIf 
				EndIf
				QRYDEL->(dbSkip())
    		EndDo
			
			If Select("QRYDEL") > 0
				dbSelectArea("QRYDEL")
				QRYDEL->(dbCloseArea())
			EndIf		
		EndIf
    
	EndIf
    
	If _nOpcx == 5
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

	RestArea(_aAreaSC7)    
	RestArea(_aArea)

Return
