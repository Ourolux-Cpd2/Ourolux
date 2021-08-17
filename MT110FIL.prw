#INCLUDE "PROTHEUS.CH"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±º Programa ³ MT110FIL() ³ Autor ³ Claudino P Domingues ³ Data ³ 23/04/14 º±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±º Funcao Padrao ³ MATA110                                                º±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±º Desc.    ³ Filtra a tela de Solicitação de Compras.                    º±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

User Function MT110FIL()
    
	Local _aArea	 := GetArea()
	Local _aAreaSAK	 := SAK->(GetArea())
	Local _aAreaSRA	 := SRA->(GetArea())
	Local _aUser     := {}
	Local _cRet      := ""
	
	// Função UsrRetName esta retornando o nome completo na P12, foi substituida pela variavel cUserName - Claudino 26/07/2017
	// If Upper(UsrRetName(__cUserId)) $ 'ADMINISTRADOR.ROBERTO.CARLOS.SUMAIA.ADMINISTRATIVO.ADMINISTRATIVO2.COMPRAS.COMPRAS2.COMPRAS3.COORDADM.GERENCIAADM' 
	// If Upper(Alltrim(cUserName)) $ 'ADMINISTRADOR.ROBERTO.CARLOS.SUMAIA.ADMINISTRATIVO.ADMINISTRATIVO2.COMPRAS.COMPRAS2.COMPRAS3.COORDADM.GERENCIAADM.GERENCIASUPRI'

	
	If Upper(Alltrim(cUserName)) $ GetMv("FS_FILPC") // Maurício Aureliano - 24/07/2018
		_cRet := " "
	ElseIf Upper(Alltrim(cUserName)) == 'GNEW'
		_cRet := " C1_XDEPART == '000000034' "
	Else
	    
		DbSelectArea("SAK")
		SAK->(DbSetOrder(2))
	    
		If SAK->(DbSeek(xFilial("SAK")+__cUserId))
			If !Empty(ALLTRIM(SAK->AK_XDEPART))
				_cRet := " C1_XDEPART $ '"+StrTran(ALLTRIM(SAK->AK_XDEPART),",",".")+"' "
			Else
				ApMsgStop("No cadastro de aprovadores deverá ser cadastrado o departamento que você é responsável!", "MT110FIL" )
	        	/* war 10-02-2020
				PswSeek(__cUserId)
				_aUser := PswRet()
	        	
				If Empty(_aUser[1][22])
	        		// Função UsrRetName esta retornando o nome completo na P12, foi substituida pela variavel cUserName - Claudino 26/07/2017
	        		//_cRet := " Upper(Alltrim(C1_SOLICIT)) = '"+Upper(UsrRetName(__cUserId))+"' "
					_cRet := " Upper(Alltrim(C1_SOLICIT)) = '"+Upper(Alltrim(cUserName))+"' "
					ApMsgStop("Por favor solicitar ao TI que cadastre a sua matrícula no seu login!", "MT110FIL" )
				Else
					If !Empty(ALLTRIM(SRA->RA_DEPTO))
						_cRet := " C1_XDEPART $ '"+StrTran(ALLTRIM(SRA->RA_DEPTO),",",".")+"' "
					Else
	        			// Função UsrRetName esta retornando o nome completo na P12, foi substituida pela variavel cUserName - Claudino 26/07/2017
	        			//_cRet := " Upper(Alltrim(C1_SOLICIT)) = '"+Upper(UsrRetName(__cUserId))+"' "
						_cRet := " Upper(Alltrim(C1_SOLICIT)) = '"+Upper(Alltrim(cUserName))+"' "
						ApMsgStop("Por favor solicitar ao RH que cadastre o seu departamento no cadastro de funcionários!", "MT110FIL" )
					EndIf
				EndIf
	    		war 10-02-2020 */
			EndIf
		Else
	    	/* war 10-02-2020
			PswSeek(__cUserId)
			_aUser := PswRet()
	        	
			If Empty(_aUser[1][22])
	    		// Função UsrRetName esta retornando o nome completo na P12, foi substituida pela variavel cUserName - Claudino 26/07/2017
	    		//_cRet := " Upper(Alltrim(C1_SOLICIT)) = '"+Upper(UsrRetName(__cUserId))+"' "
				_cRet := " Upper(Alltrim(C1_SOLICIT)) = '"+Upper(Alltrim(cUserName))+"' "
				ApMsgStop("Por favor solicitar ao TI que cadastre a sua matrícula no seu login!", "MT110FIL" )
			Else
				If !Empty(ALLTRIM(SRA->RA_DEPTO))
					_cRet := " C1_XDEPART $ '"+StrTran(ALLTRIM(SRA->RA_DEPTO),",",".")+"' "
				Else
	      			// Função UsrRetName esta retornando o nome completo na P12, foi substituida pela variavel cUserName - Claudino 26/07/2017
	      			//_cRet := " Upper(Alltrim(C1_SOLICIT)) = '"+Upper(UsrRetName(__cUserId))+"' "
					_cRet := " Upper(Alltrim(C1_SOLICIT)) = '"+Upper(Alltrim(cUserName))+"' "
					ApMsgStop("Por favor solicitar ao RH que cadastre o seu departamento no cadastro de funcionários!", "MT110FIL" )
				EndIf
			EndIf
	 war 10-02-2020 */   
		EndIf
	
	EndIf
	
	// Função UsrRetName esta retornando o nome completo na P12, foi substituida pela variavel cUserName - Claudino 26/07/2017
	//If Upper(UsrRetName(__cUserId)) $ 'RH3.RH.RH2.DPESSOAL2' 
	If Upper(Alltrim(cUserName)) $ 'RH.RH1.RH2.RH3.DP1.DP2'
		_cRet := " C1_XDEPART $ '000000023.000000008' "
	EndIf
	
	// Função UsrRetName esta retornando o nome completo na P12, foi substituida pela variavel cUserName - Claudino 26/07/2017
	//If Upper(UsrRetName(__cUserId)) $ 'IMPORT.COORDIMPORT1.COMEX.COMEX2.COMEX3.COMEX4.COMEX5' 
	If Upper(Alltrim(cUserName)) $ 'IMPORT.COORDIMPORT1.COMEX.COMEX2.COMEX3.COMEX4.COMEX5.COMEX7'
		_cRet := " C1_XDEPART $ '000000016.000000025.000000027' "
	EndIf
	
	// Função UsrRetName esta retornando o nome completo na P12, foi substituida pela variavel cUserName - Claudino 26/07/2017
	//Equipe Produtos
	If Upper(Alltrim(cUserName)) $ 'PRODUTOS.PRODUTOS2.PRODUTOS3.PRODUTOS4.PRODUTOS5.PRODUTOS6.SUPORTE'
		_cRet := " C1_XDEPART $ '000000017.000000031.000000029' "
	EndIf
	
	RestArea(_aAreaSRA)
	RestArea(_aAreaSAK)
	RestArea(_aArea)
			
Return _cRet

/* Versão Antiga
User Function MT110FIL()

Local cFiltro 	:= ''
Local cUsrName  := Upper(Rtrim(cUserName))
	
If cUsrName $ 'ADMINISTRADOR.ROBERTO.CARLOS.COMPRAS.SUMAIA.ADMINISTRATIVO' 
	cFiltro := " "
ElseIf cUsrName $ 'GERENCIAFIN.CONTROLADORIA'
	cFiltro := " Upper(AllTrim(C1_SOLICIT)) $ 'CREDITO3.COBRANCA3.GERENCIAFIN.CONTROLADORIA.FINANCEIRO.CREDITO1' "
ElseIf cUsrName $ 'GGC'
	cFiltro := " Upper(AllTrim(C1_SOLICIT)) $ 'GGC.PLANOVENDAS.PADOVANI.MKT.SAC.MKT2.ADV.PLANOVENDAS.ASSISTENTE.ASSISTENTE2.ASSISTENTE3.ASSISTENTE4.ASSISTENTE5.ASSISTENTE6.ASSISTENTE7.ASSISTENTE8' "
ElseIf cUsrName $ 'ADV'
	cFiltro := " Upper(AllTrim(C1_SOLICIT)) $ 'ADV.PLANOVENDAS.ASSISTENTE.ASSISTENTE2.ASSISTENTE3.ASSISTENTE4.ASSISTENTE5.ASSISTENTE6.ASSISTENTE7.ASSISTENTE8' "
ElseIf cUsrName $ 'GERENCIARH.RH'
	cFiltro := " Upper(AllTrim(C1_SOLICIT)) $ 'DPESSOAL.RH.RH2.DPESSOAL2.RH3' "
ElseIf cUsrName $ 'GPRODUTOS.SUPORTE'
	cFiltro := " Upper(AllTrim(C1_SOLICIT)) $ 'GPRODUTOS.SUPORTE' "
ElseIf cUsrName $ 'IMPORTSUPER.IMPORT'
	cFiltro := " Upper(AllTrim(C1_SOLICIT)) $ 'IMPORT.COMEX.COMEX2.COMEX3.COMEX4.IMPORTSUPER' "
ElseIf cUsrName $ 'MKT.MKT2.SAC'
	cFiltro := " Upper(AllTrim(C1_SOLICIT)) $ 'MKT.MKT2.SAC' " 
ElseIf cUsrName $ 'PRODUTOS'
	cFiltro := " Upper(AllTrim(C1_SOLICIT)) $ 'PRODUTOS' "
ElseIf cUsrName $ 'FINANCEIRO.COBRANCA3'
	cFiltro := " Upper(AllTrim(C1_SOLICIT)) $ 'FINANCEIRO.COBRANCA3' "
ElseIf cUsrName $ 'ASSISTENTE.ASSISTENTE2.ASSISTENTE3.ASSISTENTE4.ASSISTENTE5.ASSISTENTE6.ASSISTENTE7.ASSISTENTE8'
	cFiltro := " Upper(AllTrim(C1_SOLICIT)) $ 'ASSISTENTE.ASSISTENTE2.ASSISTENTE3.ASSISTENTE4.ASSISTENTE5.ASSISTENTE6.ASSISTENTE7.ASSISTENTE8' "
ElseIf cUsrName $ 'JURIDICO.JURIDICO2'
	cFiltro := " Upper(AllTrim(C1_SOLICIT)) $ 'JURIDICO.JURIDICO2' "   
ElseIf cUsrName $ 'FISCAL.CONTABIL2.FISCALSUPER.FISCAL2.FISCAL3.CONTABIL'
	cFiltro := " Upper(AllTrim(C1_SOLICIT)) $ 'FISCAL.CONTABIL2.FISCALSUPER.FISCAL2.FISCAL3.CONTABIL' "
ElseIf cUsrName $ 'CONTAGEMSP'
	cFiltro := " Upper(AllTrim(C1_SOLICIT)) $ 'LOGISTICA.CONTAGEMSP.CONTAGEMPR' "
Else
	cFiltro := " C1_USER $ '"+RetCodUsr()+"' "
EndIf	 

Return (cFiltro)
*/ 