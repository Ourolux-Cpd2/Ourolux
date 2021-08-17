/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �FA040INC  �Autor  �Eletromega  � Data �  03/08/06           ���
�������������������������������������������������������������������������͹��
���Desc.     � VALIDA�AO INCLUSAO CONTAS A RECEBER                        ���
���          � PONTO DE ENTRADA                                           ���
�������������������������������������������������������������������������͹��
���Uso       � AP6                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function FA040INC()

Local lRet      := .T.
Local _nDayDif	:= 0
Local _nDayNot	:= 0
Local cFName    := Alltrim(Upper(FunName())) 

// Claudino 27/04/16 - Parametro que armazena o login dos diretores
If !(Upper(UsrRetName(__cUserId)) $ GetMv("FS_DIRETOR"))
	
	If cFName == "FINA280"  // Faturas a Receber
		
		If !(M->E1_TIPO $ 'AB-.NF ') //M->E1_TIPO != "AB-"
			lRet := .F.
			ApMsgStop( 'Usuario sem acesso!', 'FA040INC' )
		EndIf
	
	ElseIf cFName == "FINA040"  // Inclusao Manual de CR
	    
		// Claudino - 06/06/16 - I1605-2547
		If !((Upper(UsrRetName(__cUserId)) $ GetMv("FS_DEVNDC")))
			If !(M->E1_TIPO $ 'JR .RA .EC ')
				lRet := .F.
				ApMsgStop( 'Usuario sem acesso!', 'FA040INC' )
			Else
				// Claudino 26/04/16 - Valida se o usuario logado esta nos parametros
				If Upper(UsrRetName(__cUserId)) $ GetMv("FS_EXCFIN1") .OR. Upper(UsrRetName(__cUserId)) $ GetMv("FS_EXCFIN2")
					// Claudino 26/04/16 - Valida se a data informada, � final de semana ou feriado
					If DataValida(M->E1_EMISSAO) == M->E1_EMISSAO 
						// Claudino 26/04/16 - Numero de dias de diferen�a entre emiss�o e database
						_nDayDif := DateDiffDay(M->E1_EMISSAO,dDataBase) 
						// Claudino 26/04/16 - � o mesmo dia
						If _nDayDif > 0
							// Claudino 26/04/16 - Valida entre a emiss�o e a database, quantos dias n�o s�o uteis
							For n := 1 to _nDayDif
								If DataValida(M->E1_EMISSAO + n) <> M->E1_EMISSAO + n
									_nDayNot++
								EndIf 
							Next n
							
							// Claudino 26/04/16 - Valida se a quantidade de dias uteis � maior 2
							If (_nDayDif - _nDayNot) > 2
								ApMsgStop("Diferen�a entre Dt.Emiss�o e Dt.Digita��o maior que a permitida para o usu�rio! Favor verificar com o seu gestor.","FA040INC")
								lRet := .F.
							Else
								// Claudino 26/04/16 - Se for exatamente igual a 2 e valida se o usuario 
								// esta no parametro que pode digitar dois dias uteis
								If (_nDayDif - _nDayNot) == 2
							    	If !(Upper(UsrRetName(__cUserId)) $ GetMv("FS_EXCFIN2"))
							    		ApMsgStop("Diferen�a entre Dt.Emiss�o e Dt.Digita��o maior que um dia �til! Favor verificar com o seu gestor.","FA040INC")
										lRet := .F.
							    	EndIf
								EndIf
							EndIf
						EndIf	
					Else
						ApMsgStop("Dt.Emiss�o informada ou � final de semana ou feriado! Favor digitar uma data v�lida.","FA040INC")
						lRet := .F.
					EndIf
				Else
					ApMsgStop("Usuario sem permiss�o para executar essa opera��o! Favor verificar com o seu gestor.","FA040INC")
					lRet := .F.
				EndIf
			EndIf
		Else
			If M->E1_TIPO <> 'NDC' 
				lRet := .F.
				ApMsgStop( 'Usuario s� pode incluir tipo NDC!', 'FA040INC' )
			EndIf
		EndIf
	EndIf

EndIf

Return (lRet)