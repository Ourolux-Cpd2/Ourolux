#INCLUDE "PROTHEUS.CH"

/*苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
北?Programa ?MT120QRY() ?Autor ?Claudino P Domingues ?Data ?10/09/13 罕?
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
北?Funcao Padrao ?MATA120                                                罕?
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
北?Desc.    ?Filtra a tela de Pedidos de Compra.                         罕?
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌*/

User Function MT120QRY() 

	Local _aArea	 := GetArea()
	Local _aAreaSAK	 := SAK->(GetArea())
	Local _aAreaSY1	 := SY1->(GetArea())
	Local _aAreaSRA	 := SRA->(GetArea())
	Local _aUser     := {}
	Local _cRet      := "" 

	// Fun玢o UsrRetName esta retornando o nome completo na P12, foi substituida pela variavel cUserName - Claudino 26/07/2017
	// If Upper(UsrRetName(__cUserId)) $ 'ADMINISTRADOR.ROBERTO.CARLOS.SUMAIA.ADMINISTRATIVO.ADMINISTRATIVO2.COMPRAS.COMPRAS2.COMPRAS3.COORDADM.GERENCIAADM' 
	// If Upper(Alltrim(cUserName)) $ 'ADMINISTRADOR.ROBERTO.CARLOS.SUMAIA.ADMINISTRATIVO.ADMINISTRATIVO2.COMPRAS.COMPRAS2.COMPRAS3.COORDADM.GERENCIAADM.GERENCIASUPRI'
	If Upper(Alltrim(cUserName)) $ GetMv("FS_FILPC") // MOA - 22/08/2019 - 09:15HS 
		_cRet := " "
	Else

		// Aprovadores
		DbSelectArea("SAK")
		SAK->(DbSetOrder(2))
		SAK->(DbGoTop())

		If SAK->(DbSeek(xFilial("SAK")+__cUserId))
			If !Empty(ALLTRIM(SAK->AK_XDEPART))
				_cRet := " C7_XDEPART IN('"+StrTran(ALLTRIM(SAK->AK_XDEPART),",","','")+"') "
			Else
				ApMsgStop("No cadastro de aprovadores deve ser cadastrado o departamento que vocrespons醰el!", "MT120QRY_1" )
				// war 10-02-2020
				
				_cRet := " C7_USER = '"+__cUserId+"' "
				
				// war 10-02-2020
/* war 10-02-2020 
				PswSeek(__cUserId)
				_aUser := PswRet()

				If Empty(_aUser[1][22])
					_cRet := " C7_USER = '"+__cUserId+"' "
					ApMsgStop("Por favor solicitar ao TI que cadastre a sua matr韈ula no seu login!", "MT120QRY_2" )
				Else
					If !Empty(ALLTRIM(SRA->RA_DEPTO))
						_cRet := " C7_XDEPART IN('"+StrTran(ALLTRIM(SRA->RA_DEPTO),",","','")+"') "
					Else
						_cRet := " C7_USER = '"+__cUserId+"' "
						ApMsgStop("Por favor solicitar ao RH que cadastre o seu departamento no cadastro de funcion醨ios!", "MT120QRY_3" )
					EndIf
				
				EndIf war 10-02-2020 */
			EndIf
		Else

			// Compradores
			DbSelectArea("SY1")
			SY1->(DbSetOrder(3))

			If SY1->(DbSeek(xFilial("SY1")+__cUserId))
				If !Empty(ALLTRIM(SY1->Y1_XDEPART))
					_cRet := " C7_XDEPART IN('"+StrTran(ALLTRIM(SY1->Y1_XDEPART),",","','")+"') "
				Else
					PswSeek(__cUserId)
					_aUser := PswRet()

					If Empty(_aUser[1][22])
						_cRet := " C7_USER = '"+__cUserId+"' "
						ApMsgStop("Por favor solicitar ao TI que cadastre a sua matr韈ula no seu login!", "MT120QRY_4" )
					Else
						If !Empty(ALLTRIM(SRA->RA_DEPTO))
							_cRet := " C7_XDEPART IN('"+StrTran(ALLTRIM(SRA->RA_DEPTO),",","','")+"') "
						Else
							_cRet := " C7_USER = '"+__cUserId+"' "
							ApMsgStop("Por favor solicitar ao RH que cadastre o seu departamento no cadastro de funcion醨ios!", "MT120QRY_5" )
						EndIf
					EndIf

				Endif
			EndIf
		EndIf
	
		// Sem cadastro de Aprovador / Comprador

		If Empty(ALLTRIM(_cRet))
            /* war 10-02-2020 		
			PswSeek(__cUserId)
			_aUser := PswRet()

			If Empty(_aUser[1][22])
				_cRet := " C7_USER = '"+__cUserId+"' "
				ApMsgStop("Por favor solicitar ao TI que cadastre a sua matr韈ula no seu login!", "MT120QRY_6" )
			Else
				If !Empty(ALLTRIM(SRA->RA_DEPTO))
					_cRet := " C7_XDEPART IN('"+StrTran(ALLTRIM(SRA->RA_DEPTO),",","','")+"') "
				Else
					_cRet := " C7_USER = '"+__cUserId+"' "
				EndIf
			EndIf war 10-02-2020 */    
			
			// war 10-02-2020
			_cRet := " C7_USER = '"+__cUserId+"' "
			// war 10-02-2020
			
		EndIf

	EndIf
	/*	
	// Fun玢o UsrRetName esta retornando o nome completo na P12, foi substituida pela variavel cUserName - Claudino 26/07/2017
	//If Upper(UsrRetName(__cUserId)) $ 'RH3.RH.RH2.DPESSOAL2' 
	If Upper(Alltrim(cUserName)) $ 'RH.RH1.RH2.RH3.RH4.RH5.RH6.RH7.RH8.DP1.DP2' 
	_cRet := " C7_XDEPART IN('000000023','000000008') "
	EndIf                                                 

	// Fun玢o UsrRetName esta retornando o nome completo na P12, foi substituida pela variavel cUserName - Claudino 26/07/2017
	//If Upper(UsrRetName(__cUserId)) $ 'CONTABIL2'   // Chamado TI I1602-734
	If SUBSTR(Upper(Alltrim(cUserName)),1,8) == 'CONTABIL' // Chamado TI I1602-734
	_cRet := " C7_XDEPART IN('000000016','000000020','000000019') "
	EndIf

	// Fun玢o UsrRetName esta retornando o nome completo na P12, foi substituida pela variavel cUserName - Claudino 26/07/2017
	//If Upper(UsrRetName(__cUserId)) $ 'EDI2.LOGISTICASP'   // Claudino - 30/05/16 - I1605-2831
	If Upper(Alltrim(cUserName)) $ 'EDI.EDI1.EDI2.LOGISTICASP'   // Claudino - 30/05/16 - I1605-2831
	_cRet := " C7_XDEPART IN('000000011','000000014') "
	EndIf

	// Fun玢o UsrRetName esta retornando o nome completo na P12, foi substituida pela variavel cUserName - Claudino 26/07/2017
	//If Upper(UsrRetName(__cUserId)) $ 'FISCAL.FISCAL2.FISCAL3.CONTABIL'
	If SUBSTR(Upper(Alltrim(cUserName)),1,6) == 'FISCAL'
	_cRet := " C7_XDEPART IN('000000020','000000019') "
	EndIf

	// Fun玢o UsrRetName esta retornando o nome completo na P12, foi substituida pela variavel cUserName - Claudino 26/07/2017
	//If Upper(UsrRetName(__cUserId)) $ 'IMPORT.COORDIMPORT1.COMEX.COMEX2.COMEX3.COMEX4.COMEX5'
	If Upper(Alltrim(cUserName)) $ 'IMPORT.COORDIMPORT1.COMEX.COMEX2.COMEX3.COMEX4.COMEX5.COMEX7'
	_cRet := " C7_XDEPART IN('000000016','000000025','000000027') "
	EndIf 

	// Fun玢o UsrRetName esta retornando o nome completo na P12, foi substituida pela variavel cUserName - Claudino 26/07/2017
	//Equipe Produtos
	If Upper(Alltrim(cUserName)) $ 'PRODUTOS.PRODUTOS2.PRODUTOS3.PRODUTOS4.PRODUTOS5.SUPORTE'
	_cRet := " C7_XDEPART IN('000000017','000000031','000000029') "
	EndIf
	*/
	RestArea(_aAreaSRA)
	RestArea(_aAreaSY1)
	RestArea(_aAreaSAK)
	RestArea(_aArea)

Return _cRet
