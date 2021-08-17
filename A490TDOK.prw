/*
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
����������������������������������������������������������������������������ͻ��
���Programa  � �Autor  �Eletromega             � Data �  17/05/12            ���
����������������������������������������������������������������������������͹��
���Desc.     �Esse ponto de entrada � executado na valida��o 'TudoOk'        ���
��� 		  da interface. Ele permite inibir a inclus�o e altera��o        ���
���           da manuten��o de comiss�es.   								 ���
���           Retorno: .T./.F.                  	                         ���
���          �  			                                    	         ���
����������������������������������������������������������������������������͹��
���Uso       �Faturamento                                                    ���
����������������������������������������������������������������������������ͼ��
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
*/
#Include "rwmake.ch"

User Function A490TDOK()
Local lRet     := .T.
Local __cUsr   := Upper(Rtrim(cUserName))
Local cMVUsrCo := SuperGetMv("FS_USRCOMI")

//If !U_IsAdm()

If !(__cUsr $ cMVUsrCo) // Claudino 14/04/15

	If INCLUI
	
		If  M->E3_COMIS > 0 .Or. M->E3_BASE > 0 
	
			lRet := .F.
			ApMsgStop('Operacao nao e permitida! So pode incluir valores negativos.', 'A490TDOK')
	    
	    EndIf
	
	ElseIf ALTERA
	
		If  !(Substr(M->E3_TIPO, 1, 2) == 'VL')  
	
			lRet := .F.
			ApMsgStop('Operacao nao e permitida! So pode alterar titulos tipo VL.', 'A490TDOK')
	    
	    EndIf

	EndIf

EndIf

Return(lRet)