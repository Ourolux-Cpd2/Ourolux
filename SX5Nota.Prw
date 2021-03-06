/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �SX5NOTA   �Autor  �Microsiga           � Data �  11/30/07   ���
�������������������������������������������������������������������������͹��
���Desc.     � Ponto de entrada para filtrar as series de nf              ���
���          � Chamado para cada "serie" na tabela 01 no SX5              ���
�������������������������������������������������������������������������͹��
���Uso       � AP8                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function SX5Nota()

Local _lRet := .F.
Local cChaveX5 := Substr(SX5->X5_CHAVE, 1, 3)

If FunName() $ "MATA103.MATA140.MATA119"
	If SM0->M0_CODIGO == '01'  // Empresa also cNumEmp = 0200
		If cChaveX5     $ '5  ' .And. Alltrim(SM0->M0_CODFIL) == '01'
			Return( .T. )
		ElseIf cChaveX5 $ 'ICP'  .And. Alltrim(SM0->M0_CODFIL) == '01' // Serie NF entrada importacao - I1603-1459
			Return(.T.)
		ElseIf cChaveX5 $ '4  ' .And. Alltrim(SM0->M0_CODFIL) == '02'
			Return(.T.)
		ElseIf cChaveX5 $ '6  ' .And. Alltrim(SM0->M0_CODFIL) == '03'
			Return(.T.)
		ElseIf cChaveX5 $ '7  ' .And. Alltrim(SM0->M0_CODFIL) == '04'
			Return(.T.)
		ElseIf cChaveX5 $ '8  ' .And. Alltrim(SM0->M0_CODFIL) == '05'
			Return(.T.)
		ElseIf cChaveX5 $ '9  ' .And. Alltrim(SM0->M0_CODFIL) == '06'
			Return(.T.)
		Else
			Return(.F.)
		EndIf
	ElseIf SM0->M0_CODIGO == '02'
		If cChaveX5     $ '1  ' .And. Alltrim(SM0->M0_CODFIL) == '00'
			Return( .T. )
		Else
			Return( .F. )
		EndIf
	Else
		Return(.T.)
	EndIf
elseif FunName() $ "EICDI154"
	
	If SM0->M0_CODIGO == '01'  // Empresa also cNumEmp = 0200
		If cChaveX5     $ '555' .And. Alltrim(SM0->M0_CODFIL) == '01'
			Return( .T. )
		ElseIf cChaveX5 $ '444' .And. Alltrim(SM0->M0_CODFIL) == '02'
			Return(.T.)
		ElseIf cChaveX5 $ '666' .And. Alltrim(SM0->M0_CODFIL) == '03'
			Return(.T.)
		ElseIf cChaveX5 $ '777' .And. Alltrim(SM0->M0_CODFIL) == '04'
			Return(.T.)
		ElseIf cChaveX5 $ '888' .And. Alltrim(SM0->M0_CODFIL) == '05'
			Return(.T.)
		ElseIf cChaveX5 $ '099' .And. Alltrim(SM0->M0_CODFIL) == '06' // WAR - 06/12/2018
			Return(.T.)
		Else
			Return(.F.)
		EndIf
		
	EndIf
EndIf

If SC5->C5_NUM <> SC9->C9_PEDIDO
	SC5->( dbSeek( xFilial("SC5") + SC9->C9_PEDIDO, .F. ) )
EndIf

If SM0->M0_CODIGO == '01'
	If (cChaveX5 $ '5  .NFS') .And. (Alltrim(SM0->M0_CODFIL) == '01')
		_lRet := .T.
	ElseIf (cChaveX5 $ '4  ') .And. (Alltrim(SM0->M0_CODFIL) == '02')
		_lRet := .T.
	ElseIf (cChaveX5 $ '6  ') .And. (Alltrim(SM0->M0_CODFIL) == '03')
		_lRet := .T.
	ElseIf (cChaveX5 $ '7  ') .And. (Alltrim(SM0->M0_CODFIL) == '04')
		_lRet := .T.
	ElseIf (cChaveX5 $ '8  ') .And. (Alltrim(SM0->M0_CODFIL) == '05')
		_lRet := .T. 
	ElseIf (cChaveX5 $ '9  ') .And. (Alltrim(SM0->M0_CODFIL) == '06')
		_lRet := .T.
	EndIf
ElseIf SM0->M0_CODIGO == '02'
	If (cChaveX5 $ '1  ') .And. (Alltrim(SM0->M0_CODFIL) == '00')
		_lRet := .T.
	ElseIf (cChaveX5 $ '1  ') .AND. (Alltrim(SM0->M0_CODFIL) == '00')
		_lRet := .T.
	ElseIf (cChaveX5 == 'ORC') .And. Alltrim(SM0->M0_CODFIL) == '00'
		_lRet := .T.
	EndIf
Else
	_lRet := .T.
EndIf

Return ( _lRet )
