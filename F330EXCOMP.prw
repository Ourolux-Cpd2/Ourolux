#INCLUDE "PROTHEUS.CH"

/*����������������������������������������������������������������������������
������������������������������������������������������������������������������
��� Programa � F330EXCOMP() � Autor � Claudino Domingues � Data � 30/01/13 ���
������������������������������������������������������������������������������
��� Funcao Padrao � FINA330                                                ���
������������������������������������������������������������������������������
��� Desc.    � Sera executado apos confirmacao do estorno/exclusao da      ���
���          � compensa��o do contas a receber. 			               ���
������������������������������������������������������������������������������
��� Desc.    � Alterado por MrConsulting - Gilson Belini em 28/11/2014.    ���
���          � Posiciona o campo E5_DTDIGIT, antes posicionava-se o        ���
���          � E1_BAIXA para efetuar o bloqueio do cancelamento.           ���
����������������������������������������������������������������������������*/

User Function F330EXCOMP()

Local _lRet     := .T.
Local aTitulos	:= aClone(ParamIxb[1]) // Array contendo informa��es do t�tulos a ser estornado
Local aReg		:= aClone(ParamIxb[2]) // Numero R_E_C_N_O_ posicionado
Local nOpcao	:= ParamIxb[3] // 4=Exclusao/5=Estorno 
Local _nDayDif	:= 0
Local _nDayNot	:= 0

// Fun��o UsrRetName esta retornando o nome completo na P12, foi substituida pela variavel cUserName - Claudino 26/07/2017
//If !(Upper(UsrRetName(__cUserId)) $ GetMv("FS_DIRETOR"))
If !(Upper(Alltrim(cUserName)) $ GetMv("FS_DIRETOR"))
	If Len(aTitulos) > 0 .and. Len(aReg) > 0
		For I := 1 to Len(aReg)
			DbSelectArea("SE5")
			DbGoTo(aReg[I])
			If aReg[I] == SE5->(Recno()) // Garantia de titulo posicionado corretamente.
				// Claudino 27/04/16 - Valida se o usuario logado esta nos parametros
				// Fun��o UsrRetName esta retornando o nome completo na P12, foi substituida pela variavel cUserName - Claudino 26/07/2017
				//If Upper(UsrRetName(__cUserId)) $ GetMv("FS_EXCFIN1") .OR. Upper(UsrRetName(__cUserId)) $ GetMv("FS_EXCFIN2")
				If Upper(Alltrim(cUserName)) $ GetMv("FS_EXCFIN1") .OR. Upper(Alltrim(cUserName)) $ GetMv("FS_EXCFIN2")
					// Claudino 27/04/16 - Numero de dias de diferen�a entre emiss�o e database
					_nDayDif := DateDiffDay(SE5->E5_DTDIGIT,dDataBase) 
					// Claudino 27/04/16 - � o mesmo dia
					If _nDayDif > 0
						// Claudino 27/04/16 - Valida entre a emiss�o e a database, quantos dias n�o s�o uteis
						For n := 1 to _nDayDif
							If DataValida(SE5->E5_DTDIGIT + n) <> SE5->E5_DTDIGIT + n
								_nDayNot++
							EndIf 
						Next n
									
						// Claudino 27/04/16 - Valida se a quantidade de dias uteis � maior 2
						If (_nDayDif - _nDayNot) > 2
							ApMsgStop("Usu�rio sem acesso, s� pode ser cancelado dentro de dois dias uteis. Favor verificar com o seu gestor.","F330EXCOMP")
							_lRet := .F.
						Else
							// Claudino 27/04/16 - Se for exatamente igual a 2 e valida se o usuario 
							// esta no parametro que pode digitar dois dias uteis
							If (_nDayDif - _nDayNot) == 2
								// Fun��o UsrRetName esta retornando o nome completo na P12, foi substituida pela variavel cUserName - Claudino 26/07/2017
								//If !(Upper(UsrRetName(__cUserId)) $ GetMv("FS_EXCFIN2"))
								If !(Upper(Alltrim(cUserName)) $ GetMv("FS_EXCFIN2"))
									ApMsgStop("Usu�rio sem acesso, s� pode ser cancelado dentro de um dia �til. Favor verificar com o seu gestor","F330EXCOMP")
									_lRet := .F.
								EndIf
							EndIf
						EndIf
					EndIf	
				Else
					ApMsgStop("Usuario sem permiss�o para executar essa opera��o! Favor verificar com o seu gestor.","F330EXCOMP")
					_lRet := .F.
				EndIf
			Endif
		Next I
	Endif
EndIf

Return (_lRet)