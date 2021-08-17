#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"

/*����������������������������������������������������������������������������
������������������������������������������������������������������������������
��� Programa � F340ACAN() � Autor � Claudino P Domingues � Data � 13/02/14 ���
������������������������������������������������������������������������������
��� Funcao Padrao � FINA340                                                ���
������������������������������������������������������������������������������
��� Desc.    � Sera executado antes da abertura da tela de cancelamento de ���
���          � compensa��o a pagar.                         			   ���
������������������������������������������������������������������������������
��� Desc.    � Alterado por MrConsulting - Gilson Belini em 28/11/2014.    ���
���          � Posiciona o campo E5_DTDIGIT, antes posicionava-se o        ���
���          � E2_BAIXA para efetuar o bloqueio do cancelamento.           ���
����������������������������������������������������������������������������*/

User Function F340ACAN()

Local _aAreaSE5 := SE5->(GetArea())
Local _lRet     := .T.
Local _nDayDif	:= 0
Local _nDayNot	:= 0

// Claudino 27/04/16 - Parametro que armazena o login dos diretores
//If !(Upper(UsrRetName(__cUserId)) $ GetMv("FS_DIRETOR"))
If !(Upper(Alltrim(cUserName)) $ GetMv("FS_DIRETOR"))
	// Claudino 27/04/16 - Valida se o usuario logado esta nos parametros
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
				ApMsgStop("Usu�rio sem acesso, s� pode ser cancelado dentro de dois dias uteis. Favor verificar com o seu gestor.","F340ACAN")
				_lRet := .F.
			Else
				// Claudino 27/04/16 - Se for exatamente igual a 2 e valida se o usuario 
				// esta no parametro que pode digitar dois dias uteis
				If (_nDayDif - _nDayNot) == 2
					//If !(Upper(UsrRetName(__cUserId)) $ GetMv("FS_EXCFIN2"))
					If !(Upper(Alltrim(cUserName)) $ GetMv("FS_EXCFIN2"))
						ApMsgStop("Usu�rio sem acesso, s� pode ser cancelado dentro de um dia �til. Favor verificar com o seu gestor","F340ACAN")
						_lRet := .F.
					EndIf
				EndIf
			EndIf
		EndIf	
	Else
		ApMsgStop("Usuario sem permiss�o para executar essa opera��o! Favor verificar com o seu gestor.","F340ACAN")
		_lRet := .F.
	EndIf
EndIf	

RestArea(_aAreaSE5)

Return(_lRet)