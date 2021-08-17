#INCLUDE "PROTHEUS.CH"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±º Programa ³ F330EXCOMP() ³ Autor ³ Claudino Domingues ³ Data ³ 30/01/13 º±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±º Funcao Padrao ³ FINA330                                                º±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±º Desc.    ³ Sera executado apos confirmacao do estorno/exclusao da      º±±
±±º          ³ compensação do contas a receber. 			               º±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±º Desc.    ³ Alterado por MrConsulting - Gilson Belini em 28/11/2014.    º±±
±±º          ³ Posiciona o campo E5_DTDIGIT, antes posicionava-se o        º±±
±±º          ³ E1_BAIXA para efetuar o bloqueio do cancelamento.           º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

User Function F330EXCOMP()

Local _lRet     := .T.
Local aTitulos	:= aClone(ParamIxb[1]) // Array contendo informações do títulos a ser estornado
Local aReg		:= aClone(ParamIxb[2]) // Numero R_E_C_N_O_ posicionado
Local nOpcao	:= ParamIxb[3] // 4=Exclusao/5=Estorno 
Local _nDayDif	:= 0
Local _nDayNot	:= 0

// Função UsrRetName esta retornando o nome completo na P12, foi substituida pela variavel cUserName - Claudino 26/07/2017
//If !(Upper(UsrRetName(__cUserId)) $ GetMv("FS_DIRETOR"))
If !(Upper(Alltrim(cUserName)) $ GetMv("FS_DIRETOR"))
	If Len(aTitulos) > 0 .and. Len(aReg) > 0
		For I := 1 to Len(aReg)
			DbSelectArea("SE5")
			DbGoTo(aReg[I])
			If aReg[I] == SE5->(Recno()) // Garantia de titulo posicionado corretamente.
				// Claudino 27/04/16 - Valida se o usuario logado esta nos parametros
				// Função UsrRetName esta retornando o nome completo na P12, foi substituida pela variavel cUserName - Claudino 26/07/2017
				//If Upper(UsrRetName(__cUserId)) $ GetMv("FS_EXCFIN1") .OR. Upper(UsrRetName(__cUserId)) $ GetMv("FS_EXCFIN2")
				If Upper(Alltrim(cUserName)) $ GetMv("FS_EXCFIN1") .OR. Upper(Alltrim(cUserName)) $ GetMv("FS_EXCFIN2")
					// Claudino 27/04/16 - Numero de dias de diferença entre emissão e database
					_nDayDif := DateDiffDay(SE5->E5_DTDIGIT,dDataBase) 
					// Claudino 27/04/16 - É o mesmo dia
					If _nDayDif > 0
						// Claudino 27/04/16 - Valida entre a emissão e a database, quantos dias não são uteis
						For n := 1 to _nDayDif
							If DataValida(SE5->E5_DTDIGIT + n) <> SE5->E5_DTDIGIT + n
								_nDayNot++
							EndIf 
						Next n
									
						// Claudino 27/04/16 - Valida se a quantidade de dias uteis é maior 2
						If (_nDayDif - _nDayNot) > 2
							ApMsgStop("Usuário sem acesso, só pode ser cancelado dentro de dois dias uteis. Favor verificar com o seu gestor.","F330EXCOMP")
							_lRet := .F.
						Else
							// Claudino 27/04/16 - Se for exatamente igual a 2 e valida se o usuario 
							// esta no parametro que pode digitar dois dias uteis
							If (_nDayDif - _nDayNot) == 2
								// Função UsrRetName esta retornando o nome completo na P12, foi substituida pela variavel cUserName - Claudino 26/07/2017
								//If !(Upper(UsrRetName(__cUserId)) $ GetMv("FS_EXCFIN2"))
								If !(Upper(Alltrim(cUserName)) $ GetMv("FS_EXCFIN2"))
									ApMsgStop("Usuário sem acesso, só pode ser cancelado dentro de um dia útil. Favor verificar com o seu gestor","F330EXCOMP")
									_lRet := .F.
								EndIf
							EndIf
						EndIf
					EndIf	
				Else
					ApMsgStop("Usuario sem permissão para executar essa operação! Favor verificar com o seu gestor.","F330EXCOMP")
					_lRet := .F.
				EndIf
			Endif
		Next I
	Endif
EndIf

Return (_lRet)