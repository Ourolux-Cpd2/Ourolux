#INCLUDE "PROTHEUS.CH"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±º Programa ³ MT120OK() ³ Autor ³ Claudino P Domingues  ³ Data ³ 04/07/14 º±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±º Funcao Padrao ³ MATA120                                                º±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±º Desc.    ³ Ponto de entrada que valida se foi digitado o departamento  º±±
±±º          ³ no PC.                                                      º±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

User Function MT120OK()

Local _lRet    	:= .T.
Local aAreaATU	:= GetArea()
// Rodrigo Franco 01/11/2016
Local _cFORNECE := CA120FORN
Local _cLOJA    := CA120LOJ
Local _nAviPc1  := GetMV("MV_AVISPC1")  // Valor
Local _nAviPc2  := GetMV("MV_AVISPC2")  // Dias
Local _nPOS_TOT	:= Ascan( aHeader,{|x| AllTrim( x[2] ) == "C7_TOTAL" })
Local _nValTela := 0
Local _nValTe01 := 0
Local _nValTe02 := 0
Local _cMsgGer  := ""
Local Ur		:= 0
Local nlx		:= 0
Local cDespImp	:= SuperGetMV("ES_DESPIMP",.F.,"") //201/202/203/204/205/405/415
Local cGrpImp   := SuperGetMV("ES_GRPIMP",.F.,"")  //000510
Local cPrdFrt   := SuperGetMV("ES_FRT102",.F.,"") 
Local cPrdGA	:= SuperGetMV("ES_PRDNFRT",.F.,"") 
Local cGrpSup  	:= SuperGetMV("ES_APRFRTG",.F.,"") 
Local nPosApr   := aScan(aHeader,{|x| AllTrim(x[2])=="C7_APROV"})
Local nPosPrd   := aScan(aHeader,{|x| AllTrim(x[2])=="C7_PRODUTO"})
Local nPosPro   := aScan(aHeader,{|x| AllTrim(x[2])=="C7_XHAWB"})
Local nPosGA    := aScan(aHeader,{|x| AllTrim(x[2])=="C7_APROV"})
Local lSupri 	:= .T.

_cHoje := dDataBase
_cDias := dDataBase - _nAviPc2
//

If !l120Auto
	//U_OURO032 (@_lRet)    // war 17/02/2020
	
	If Empty(_cDepSC7)
		ApMsgStop("Por favor informar o departamento no cabeçalho do Pedido" , "MT120OK" )
		_lRet := .F.
	EndIf
	
	// Claudino 27/07/15
	If ALTERA
		dbSelectArea("FIE")
		FIE->(dbSetOrder(1))
		If FIE->(dbSeek("  P"+SC7->C7_NUM)) .And. SC7->C7_CONAPRO == "L" // FIE_FILIAL+FIE_CART+FIE_PEDIDO
			ApMsgStop("Pedido Liberado e com PA vinculado, caso precise alterar algum valor no Pedido, é necessario desvincular o PA, caso tenha só vinculado o PA com Pedido, por favor clicar em Fechar" , "MT120OK" )
			_lRet := .F.
		Endif
	EndIf
	
	// Rodrigo Franco 01/11/2016
	IF SELECT("TM3") > 0
		DBSELECTAREA("TM3")
		DBCLOSEAREA()
	ENDIF
	
	FOR Ur := 1 TO Len( aCols )
		If !aCols[Ur][LEN( aHeader ) + 1]
			_nValTela += aCols[Ur][_nPOS_TOT]
		EndIf
	NEXT Ur
	
	_nValTe01 := _nValTela - _nAviPc1
	_nValTe02 := _nValTela + _nAviPc1
	_sHoje := DTOS(_cHoje)
	_sDias := DTOS(_cDias)
	
	cQUERY	:= " SELECT C7_NUM, C7_TOTAL, C7_COND, C7_EMISSAO, C7_USER"
	cQUERY	+= " FROM "+RetSqlName("SC7") +" SC7 "
	cQUERY	+= " WHERE SC7.C7_FILIAL = '"+XFILIAL("SC7")+"' "
	cQUERY	+= " AND SC7.C7_FORNECE = '"+_cFORNECE+"' "
	cQUERY	+= " AND SC7.C7_LOJA = '"+_cLOJA+"' "
	cQUERY	+= " AND (C7_EMISSAO BETWEEN '" + _sDias + "' AND '" + _sHoje + "') "
	cQUERY 	+= " AND SC7.D_E_L_E_T_ <> '*'	 "
	// Roberto Souza - 13/01/2017
	// Não inclui o pedido corrente na verificação de alteração ou copia de pedido
	cQUERY 	+= " AND SC7.C7_NUM <> '"+SC7->C7_NUM+"' "
	//
	cQUERY 	+= " ORDER BY C7_NUM DESC"
	
	DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery) , 'TM3', .T., .F.)
	_nY := 1
	DBSELECTAREA("TM3")
	WHILE TM3->(!EOF()) //.AND. _nY < 20
		_nZ := 1
		_cUltNum := TM3->C7_NUM
		dbSelectArea("SC7")
		dbSetOrder(1)
		IF dbSeek(xFilial("SC7")+TM3->C7_NUM)
			_cHTNume	:= C7_NUM
			_nHTTMer    := 0
			_nHTTota	:= 0
			_cHTEmis	:= C7_EMISSAO
			While C7_FILIAL == xFilial("SC7") .AND. C7_NUM == _cUltNum
				_nHTTMer += C7_TOTAL
				dbSkip(1)
				_nZ += 1
			END
			dbSkip(-1)
			_nZ -= 1
			_nY += 1
			IF _nHTTMer >= _nValTe01 .AND. _nHTTMer <= _nValTe02
				_cMsgGer += "O pedido " + _cHTNume + " emitido em " +  dtoc(_cHTEmis) + " é similar a este." + CRLF
			ENDIF
			DBSELECTAREA("TM3")
			DBSKIP(_nZ)
		Else
			DBSELECTAREA("TM3")
			DBSKIP(_nZ)
		ENDIF
	END
	
	IF !Empty(_cMsgGer)
        
		// Roberto Souza - 16/01/2017 
		// Substituida a mensagem de aviso 
		cSubTit := "Deseja continuar com a "+IIf(ALTERA,"alteração","inclusão")+" deste pedido?"
		If Aviso("Atenção",_cMsgGer,{"Continuar","Cancelar"},3,cSubTit) <> 1
			_lRet := .F.
		EndIf
//		If !MsgYesNo(_cMsgGer +  "Deseja continuar?")
//			_lRet := .F.
//		EndIf

	Endif
EndIf
//

If _lRet
	If Len(aCols) == 1
		If SubStr(aCols[1][nPosPrd],1,3) == "EIC" .AND. (SubStr(aCols[1][nPosPrd],4,3) $ cDespImp)
			aCols[1][nPosApr] := cGrpImp
		EndIf
	EndIf
EndIf

If _lRet .AND. (INCLUI .or. ALTERA)
	FOR nlx := 1 TO Len(aCols)
		If !aCols[nlx][LEN(aHeader) + 1]
			If Alltrim(aCols[nlx][nPosPrd]) $ cPrdFrt .And. Empty(aCols[nlx][nPosPro])
				ApMsgStop("Por favor informar o processo do produto " +Alltrim(aCols[nlx][nPosPrd])+ " na linha do item" , "MT120OK" )
				_lRet 	:= .F.
				lSupri  := .F.
				Exit	
			EndIf
		EndIf
	NEXT nlx

	FOR nlx := 1 TO Len(aCols)
		If !aCols[nlx][LEN(aHeader) + 1]
			If Alltrim(aCols[nlx][nPosPrd]) $ cPrdGA .Or. SubStr(Alltrim(aCols[nlx][nPosPrd]),1,3) <> "EIC"
				lSupri := .F.
				Exit
			EndIf
		EndIf
	NEXT nlx

	If lSupri
		FOR nlx := 1 TO Len(aCols)
			If !aCols[nlx][LEN(aHeader) + 1]
				aCols[nlx][nPosGA] := cGrpSup
			EndIf
		NEXT nlx
	EndIf
EndIf

RestArea(aAreaATU)

Return(_lRet)
