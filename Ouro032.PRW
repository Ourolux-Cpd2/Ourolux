#Include "Topconn.ch"
#Include "Protheus.ch"
#Include "Tbiconn.ch"

/*/
�����������������������������������������������������������������������������
���Fun��o    � OURO032	� Autor � Rodrigo Franco      � Data � 21/10/2016 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Verifica Centros de Custos por usuarios                    ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � OURO032                                                    ���
�����������������������������������������������������������������������������
/*/
USER Function OURO032(_lRet)

Local i		   := 0
Local _aUser   := PswRet()
Local _cCodUsu := substr(_aUser[1][22],5,6)
Local _cDepLib := Alltrim(GetMV("MV_DEPLACC"))
Local cDepUsu  := Alltrim(_aUser[1][12])
Local nPosCC   := 0
   
// Exce��o de Usuarios
If __cUserId <> "000000" .And. __cUserId <> "000159"

	If FunName() == "MATA121"      //Pedido de Compra
		nPosCC   := aScan(aHeader,{ |x| Upper(AllTrim(x[2])) == "C7_CC" }) // Centro de Custo
	ElseIf FunName() == "MATA110"  //Solicita��o de Compra
		nPosCC   := aScan(aHeader,{ |x| Upper(AllTrim(x[2])) == "C1_CC" }) // Centro de Custo
	Endif
	
	IF !Empty(_cCodUsu)
		_cCC := SRA->RA_CC
		If !(alltrim(_cCC) $ _cDepLib)
			For i := 1 To Len(aCols) 
				If !aCols[i][Len(aHeader)+1]
					If !((aCols[i,nPosCC]) == _cCC)
						_lRet := .F.
						ApMsgStop( "Opera�ao proibida. Centro de Custo nao permitido pelo seu departamento!", "OURO032" )
						Exit
					EndIf
				Endif	
			Next
		EndIf
	ELSE
	    If "TERCEIRO" $ Upper(cDepUsu)	   
			_lRet := .T.
		Else
			ApMsgStop("Usuario do sistema sem vinculo funcional cadastrado, solicite ao TI cadastrar", "OURO032")	   
			_lRet := .F.
		EndIf
	ENDIF
EndIf          

Return(_lRet)