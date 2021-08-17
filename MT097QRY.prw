#INCLUDE "PROTHEUS.CH"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±º Programa ³ MT097QRY() ³ Autor ³ Claudino P Domingues ³ Data ³ 10/09/13 º±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±º Funcao Padrao ³ MATA097                                                º±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±º Desc.    ³ Filtra a tela de Liberacao de Pedidos de Compra.            º±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

User Function MT097QRY() 
    
	Local _aArea	 := GetArea()
	Local _aAreaSAK	 := SAK->(GetArea())
	Local _aAreaSRA	 := SRA->(GetArea())
	Local _cFil      := ""
	Local _cRet      := "" 
	Local _cQuery	 := ""
	Local _cPedCom   := ""
	
	// Função UsrRetName esta retornando o nome completo na P12, foi substituida pela variavel cUserName - Claudino 26/07/2017
	//If Upper(UsrRetName(__cUserId)) $ 'ADMINISTRADOR.ROBERTO.CARLOS.SUMAIA'
	If Upper(Alltrim(cUserName)) $ 'ADMINISTRADOR.ROBERTO.CARLOS.SUMAIA' 
		_cRet := " AND CR_FILIAL = '"+cFilAnt+"' "
	Else
	
		DbSelectArea("SAK")
		SAK->(DbSetOrder(2))
	    
	    If SAK->(DbSeek(xFilial("SAK")+__cUserId))
		    
			_cQuery := " SELECT  
			_cQuery += " 		C7_NUM NUMERO, "
			_cQuery += " 		C7_XDEPART DEPART "
			_cQuery += " FROM " 
			_cQuery +=			RetSqlName("SC7") + " SC7 "
			_cQuery += " WHERE "
			_cQuery += "		C7_FILIAL = '" + xFilial("SC7") + "' "
			_cQuery += " 		AND SC7.D_E_L_E_T_ = ' ' "
		    
		    If !Empty(ALLTRIM(SAK->AK_XDEPART))
				_cQuery += " 		AND (SC7.C7_XDEPART IN('"+StrTran(ALLTRIM(SAK->AK_XDEPART),",","','")+"')) "
	        Else
	        	ApMsgStop("No cadastro de aprovadores deverá ser cadastrado o departamento que você é responsável!", "MT097QRY" )
	        	/* war 10-02-2020
	        	PswSeek(__cUserId)
				_aUser := PswRet()
	        	
	        	If Empty(_aUser[1][22])
	        		_cQuery += " 		AND (SC7.C7_XDEPART IN('000000000')) "
	        		ApMsgStop("Por favor solicitar ao TI que cadastre a sua matrícula no seu login!", "MT097QRY" )
	        	Else
	        		If !Empty(ALLTRIM(SRA->RA_DEPTO))
						_cQuery += " 		AND (SC7.C7_XDEPART IN('"+StrTran(ALLTRIM(SRA->RA_DEPTO),",","','")+"')) "
	        		Else
	        			_cQuery += " 		AND (SC7.C7_XDEPART IN('000000000')) "
	        			ApMsgStop("Por favor solicitar ao RH que cadastre o seu departamento no cadastro de funcionários!", "MT097QRY" )
	        		EndIf
	    		EndIf war 10-02-2020 */	
	    	EndIf
		    
			_cQuery += " GROUP BY "
			_cQuery += " 		C7_NUM, "
			_cQuery += " 		C7_XDEPART "
			_cQuery += " ORDER BY "
			_cQuery += " 		C7_NUM, "
			_cQuery += " 		C7_XDEPART "
			
			_cQuery := ChangeQuery(_cQuery)
			
			If Select("PEDCOM") > 0
				DbSelectArea("PEDCOM")
				PEDCOM->(DbCloseArea())
			EndIf
			
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQuery),"PEDCOM",.T.,.T.)
		    
			While PEDCOM->(!Eof())
				_cPedCom += "'" + ALLTRIM(PEDCOM->NUMERO) + "' "
				PEDCOM->(dBSkip())
			EndDo

			If !Empty(_cPedCom)
				_cFil := StrTran(ALLTRIM(_cPedCom)," ",",")
			EndIf
				
			If !Empty(_cFil)
				_cRet := " AND (CR_NUM IN("+_cFil+")) AND CR_USER = '"+__cUserId+"' "
		    Else
		    	_cFil := " "
		    	_cRet := " AND (CR_NUM IN('"+_cFil+"')) AND CR_USER = '"+__cUserId+"' "
		    EndIf
		
		Else
			_cFil := " "
			_cRet := " AND CR_NUM = '"+_cFil+"' "
		EndIf
	
	EndIf	
	
	If Select("PEDCOM") > 0
		DbSelectArea("PEDCOM")
		PEDCOM->(DbCloseArea())
	EndIf
	
	RestArea(_aAreaSRA)
	RestArea(_aAreaSAK)
	RestArea(_aArea)
	
Return _cRet