User Function TMKVLDSA4()

Local lRet := .T.
Local cCodTransp := PARAMIXB[1]

If (SA4->(dbSeek( xFilial("SA4") + cCodTransp)))
	
	If (cCodTransp $ '900000')
		M->UA_TIPOENT := '2'
	ElseIf (cCodTransp $ '99    ')
		M->UA_TIPOENT := '1'
	EndIf
	
Else

	lRet := .F.
	ApMsgInfo("Transportadora invalida!")

EndIf

Return(lRet)

