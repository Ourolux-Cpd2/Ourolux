/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³SX5NOTA   ºAutor  ³Microsiga           º Data ³  11/30/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Ponto de entrada para filtrar as series de nf              º±±
±±º          ³ Chamado para cada "serie" na tabela 01 no SX5              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP8                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function SX5Nota()

Local _lRet := .F.
Local cChaveX5 := Substr(SX5->X5_CHAVE, 1, 3)

If FunName() $ "MATA103.MATA140.MATA119"
	If SM0->M0_CODIGO == '01'  // Empresa also cNumEmp = 0200
		If cChaveX5     $ '5  ' .And. SM0->M0_CODFIL == '01'
			Return( .T. )
		ElseIf cChaveX5 $ 'ICP'  .And. SM0->M0_CODFIL == '01' // Serie NF entrada importacao - I1603-1459
			Return(.T.)
		ElseIf cChaveX5 $ '4  ' .And. SM0->M0_CODFIL == '02'
			Return(.T.)
		ElseIf cChaveX5 $ '6  ' .And. SM0->M0_CODFIL == '03'
			Return(.T.)
		ElseIf cChaveX5 $ '7  ' .And. SM0->M0_CODFIL == '04'
			Return(.T.)
		ElseIf cChaveX5 $ '8  ' .And. SM0->M0_CODFIL == '05'
			Return(.T.)
		ElseIf cChaveX5 $ '9  ' .And. SM0->M0_CODFIL == '06'
			Return(.T.)
		Else
			Return(.F.)
		EndIf
	ElseIf SM0->M0_CODIGO == '02'
		If cChaveX5     $ '1  ' .And. SM0->M0_CODFIL == '00'
			Return( .T. )
		Else
			Return( .F. )
		EndIf
	Else
		Return(.T.)
	EndIf
elseif FunName() $ "EICDI154"
	
	If SM0->M0_CODIGO == '01'  // Empresa also cNumEmp = 0200
		If cChaveX5     $ '555' .And. SM0->M0_CODFIL == '01'
			Return( .T. )
		ElseIf cChaveX5 $ '444' .And. SM0->M0_CODFIL == '02'
			Return(.T.)
		ElseIf cChaveX5 $ '666' .And. SM0->M0_CODFIL == '03'
			Return(.T.)
		ElseIf cChaveX5 $ '777' .And. SM0->M0_CODFIL == '04'
			Return(.T.)
		ElseIf cChaveX5 $ '888' .And. SM0->M0_CODFIL == '05'
			Return(.T.)
		ElseIf cChaveX5 $ '099' .And. SM0->M0_CODFIL == '06' // WAR - 06/12/2018
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
	If (cChaveX5 $ '5  .ETC.NFS') .And. (SM0->M0_CODFIL == '01')
		_lRet := .T.
	ElseIf (cChaveX5 $ '4  .ETP') .And. (SM0->M0_CODFIL == '02')
		_lRet := .T.
	ElseIf (cChaveX5 $ '6  ') .And. (SM0->M0_CODFIL == '03')
		_lRet := .T.
	ElseIf (cChaveX5 $ '7  ') .And. (SM0->M0_CODFIL == '04')
		_lRet := .T.
	ElseIf (cChaveX5 $ '8  ') .And. (SM0->M0_CODFIL == '05')
		_lRet := .T. 
	ElseIf (cChaveX5 $ '9  ') .And. (SM0->M0_CODFIL == '06')
		_lRet := .T.
	EndIf
ElseIf SM0->M0_CODIGO == '02'
	If (cChaveX5 $ '1  ') .And. (SM0->M0_CODFIL == '00')
		_lRet := .T.
	ElseIf (cChaveX5 $ '1  ') .AND. (SM0->M0_CODFIL == '00')
		_lRet := .T.
	ElseIf (cChaveX5 == 'ORC') .And. SM0->M0_CODFIL == '00'
		_lRet := .T.
	EndIf
Else
	_lRet := .T.
EndIf

Return ( _lRet )
