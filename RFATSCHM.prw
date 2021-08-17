#Include "Topconn.ch"
#Include "Protheus.ch"
#Include "Tbiconn.ch"

///*
//ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
//±±ºPrograma  ³RFATSCHM  ºAutor  ³André Bagatini	   º Data ³ 22/07/11    º±±
//±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
//±±ºDesc.     ³Relatório de Faturamento Vendas - (Devoluções + Impostos)   º±±
//±±º          ³Por Valor / Quantidade / R$ Medio							º±±
//±±º          ³Usado para emitir relatorios via schedule					º±±
//±±º          ³															º±±
//±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
//±±ºUso       ³ Eletromega					                                º±±
//±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
//*/

User Function RFATSCHM()

Local aStru		 := {}
Local aStrD		 := {}
Local aPos		 := {}
Local _aMesExt 	 := {}
Local aDados	 := {}
Local aCabec1    := {}
Local nLin   	 := 010
Local nLBox		 := 190
Local _nPos		 := 520
Local nCol 		 := 0
Local _nTotal	 := 0
Local _Total 	 := 0
Local nAux   	 := 0
Local _nControl  := 0
Local nRegs		 := 0
Local _nTotalGer := 0
Local Cabec 	 := ""
Local _cVerFamDt := ""
Local cQuery 	 := ""
Local xDescrg	 := ""

Private cArqTrb  := CriaTrab(NIL,.F.)
Private cArqTrb2 := CriaTrab(NIL,.F.)

PREPARE ENVIRONMENT EMPRESA "01" FILIAL "01"

For t:=1 to 3
//
aStru		:= {}
aStrD		:= {}
aPos		:= {}
_aMesExt 	:= {}
aDados	 	:= {}
aCabec1    	:= {}
nLin   	 	:= 010
nLBox		:= 190
_nPos		:= 520
nCol 		:= 0
_nTotal	 	:= 0
_Total 	 	:= 0
nAux   	 	:= 0
_nControl  	:= 0
nRegs		:= 0
_nTotalGer 	:= 0
Cabec 	 	:= ""
_cVerFamDt 	:= ""	
//
	If Select("QRY") > 0
		DbSelectArea("QRY")
		QRY->(DbCloseArea())
	EndIf
	//
	If Select("QRYE2") > 0
		DbSelectArea("QRYE2")
		QRYE2->(DbCloseArea())
	EndIf
	//
	If Select("QRD") > 0
		DbSelectArea("QRD")
		QRD->(DbCloseArea())
	EndIf
	//
	If Select("QRD2") > 0
		DbSelectArea("QRD2")
		QRD2->(DbCloseArea())
	EndIf
	//
	If Select("TRB") > 0
		DbSelectArea("TRB")
		TRB->(DbCloseArea())
	EndIf
	//
	If Select("TRD") > 0
		DbSelectArea("TRD")
		TRD->(DbCloseArea())
	EndIf
	//
	aAdd(aStru,{"CLIENTE"	,"C",06,0})  // NOTA
	aAdd(aStru,{"LOJA"		,"C",02,0})  // SERIE
	aAdd(aStru,{"NOTA"	    ,"C",09,0})  // NOTA
	aAdd(aStru,{"SERIE"		,"C",03,0})  // SERIE
	aAdd(aStru,{"TES"		,"C",03,0})  // TES
	aAdd(aStru,{"GRUPO"  	,"C",04,0})  // GRUPO
	aAdd(aStru,{"FAMILIA"  	,"C",02,0})  // FAMILIA
	aAdd(aStru,{"DT"    	,"C",06,0})  // ANOMES
	aAdd(aStru,{"TOTAL" 	,"N",20,2})  // TOTAL
	aAdd(aStru,{"VALOR" 	,"N",20,2})  // VALOR
	dbcreate(cArqTrb,aStru)
	dbUseArea(.T.,,cArqTrb,"TRB",.F.,.F.)
	
	aAdd(aStrD,{"FORNECE"	,"C",06,0})  // NOTA
	aAdd(aStrD,{"LOJA"		,"C",02,0})  // SERIE
	aAdd(aStrD,{"NOTA"	    ,"C",09,0})  // NOTA
	aAdd(aStrD,{"SERIE"		,"C",03,0})  // SERIE
	aAdd(aStrD,{"TES"		,"C",03,0})  // TES
	aAdd(aStrD,{"GRUPO"  	,"C",04,0})  // GRUPO
	aAdd(aStrD,{"FAMILIA"  	,"C",02,0})  // FAMILIA
	aAdd(aStrD,{"DT"    	,"C",06,0})  // ANOMES
	aAdd(aStrD,{"TOTAL" 	,"N",20,2})  // TOTAL
	aAdd(aStrD,{"VALOR" 	,"N",20,2})  // VALOR
	dbcreate(cArqTrb2,aStrD)
	dbUseArea(.T.,,cArqTrb2,"TRD",.F.,.F.)
	
	_dDatade := DDATABASE - 180 // 6 Meses
	
	/* Retirado war 09/01/2012
	_cMes1 := SUBSTR(DTOS(_dDatade),5,2)
	_cMes2 := SUBSTR(DTOS( DDATABASE ),5,2)
	
	If (Val(_cMes2) - Val(_cMes1)) = 6
		_dDatade := LastDate(DaySub( DDATABASE , 180 ))
		_dDatade := DaySum( _dDatade , 1 )
	Else
		_dDatade := FirstDate(DaySub( DDATABASE , 180 ))
	EndIf
	*/
	// war 09/01/2012
	If (DateDiffMonth( DDATABASE , _dDatade ) == 6)
		_dDatade := LastDate(_dDatade) + 1
	Else
		_dDatade := FirstDate(_dDatade)  
	EndIf
	
	Conout("DDATABASE: " + DTOS(DDATABASE) + " _dDatade: " + DTOS(_dDatade) )
	 	
	// war 09/01/2012	
	If  t = 1
		cQuery := " SELECT F2_CLIENTE AS CLIENTE, F2_LOJA AS LOJA, D2_DOC AS NOTA, D2_SERIE AS SERIE, D2_TES AS TES, BM_GRUPO AS GRUPO , BM_TIPGRU AS FAMILIA, SUBSTRING(F2_EMISSAO,1,6) AS DT "
		cQuery += " , SUM(D2_TOTAL) AS TOTAL, SUM(D2_TOTAL) AS VALOR FROM SF2010 SF2 "
	ElseIf t = 2
		cQuery := " SELECT F2_CLIENTE AS CLIENTE, F2_LOJA AS LOJA, D2_DOC AS NOTA, D2_SERIE AS SERIE, D2_TES AS TES, BM_GRUPO AS GRUPO , BM_TIPGRU AS FAMILIA, SUBSTRING(F2_EMISSAO,1,6) AS DT "
		cQuery += " , SUM(D2_QUANT) AS TOTAL, SUM(D2_TOTAL) AS VALOR FROM SF2010 SF2 "
	ElseIf t = 3
		cQuery := " SELECT F2_CLIENTE AS CLIENTE, F2_LOJA AS LOJA, D2_DOC AS NOTA, D2_SERIE AS SERIE, D2_TES AS TES, BM_GRUPO AS GRUPO , BM_TIPGRU AS FAMILIA, SUBSTRING(F2_EMISSAO,1,6) AS DT "
		cQuery += " , SUM(D2_VALBRUT) AS TOTAL, SUM(D2_TOTAL) AS VALOR FROM SF2010 SF2 "
	EndIf
	//
	cQuery += " INNER JOIN SD2010 SD2 ON D2_DOC = F2_DOC AND D2_SERIE = F2_SERIE AND D2_CLIENTE = F2_CLIENTE AND F2_LOJA = D2_LOJA "
	cQuery += " INNER JOIN SB1010 SB1 ON B1_COD = D2_COD "
	cQuery += " INNER JOIN SF4010 SF4 ON F4_CODIGO = D2_TES "
	cQuery += " INNER JOIN SBM010 SBM ON BM_GRUPO = B1_GRUPO  "
	cQuery += " WHERE SD2.D_E_L_E_T_ <> '*' AND "
	cQuery += " SF2.D_E_L_E_T_ <> '*' AND "
	cQuery += " SB1.D_E_L_E_T_ <> '*' AND "
	cQuery += " SF4.D_E_L_E_T_ <> '*' AND "
	cQuery += " SBM.D_E_L_E_T_ <> '*' AND "
	cQuery += " F4_URELFAT = '1' AND "
	cQuery += " D2_TIPO = 'N' AND D2_NFORI = '' AND "
	cQuery += " F2_DOC BETWEEN '         ' AND 'ZZZZZZZZZ' AND "
	cQuery += " BM_GRUPO BETWEEN '    ' AND '9999' AND "
	cQuery += " BM_XWKFLOW = 'S' AND "
	cQuery += " F2_EMISSAO BETWEEN '"+DTOS(_dDatade)+"' AND '"+ DTOS(DDATABASE)+"' AND "
	cQuery += " D2_COD BETWEEN '               ' AND 'ZZZZZZZZZZZZZZZ' AND "
	cQuery += " (F2_CLIENTE <> '008360' AND F2_CLIENTE <> '020793') "
	cQuery += " GROUP BY F2_CLIENTE, F2_LOJA, D2_DOC, D2_SERIE, BM_GRUPO, BM_TIPGRU, SUBSTRING(F2_EMISSAO,1,6), D2_TES "
	cQuery += " ORDER BY BM_GRUPO, SUBSTRING(F2_EMISSAO,1,6) "
	//
	cQuery := ChangeQuery(cQuery)
	//
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"QRY",.F.,.T.)
	//
	DbSelectArea("QRY")
	DbGoTop()
	//
	While QRY->(!EOF())
		//
		If QRY->TOTAL > 0
			DbSelectArea("TRB")
			TRB->(RecLock("TRB",.T.))
			TRB->CLIENTE := QRY->CLIENTE
			TRB->LOJA 	 := QRY->LOJA
			TRB->NOTA	 := QRY->NOTA
			TRB->SERIE	 := QRY->SERIE
			TRB->TES	 := QRY->TES
			TRB->GRUPO	 := QRY->GRUPO
			TRB->FAMILIA := QRY->FAMILIA
			TRB->DT		 := QRY->DT
			TRB->TOTAL	 := QRY->TOTAL
			TRB->VALOR	 := QRY->VALOR
			TRB->(MsUnlock("TRB"))
			//
			DbSelectArea("QRY")
			QRY->(DbSkip())
		Else
			DbSelectArea("QRY")
			QRY->(DbSkip())
		EndIf
	End
	///
	///						Empresa 2
	///
	If t = 1
		cQuery2 := " SELECT F2_CLIENTE AS CLIENTE, F2_LOJA AS LOJA, D2_DOC AS NOTA, D2_SERIE AS SERIE, D2_TES AS TES, BM_GRUPO AS GRUPO , BM_TIPGRU AS FAMILIA, SUBSTRING(F2_EMISSAO,1,6) AS DT "
		cQuery2 += " , SUM(D2_TOTAL) AS TOTAL, SUM(D2_TOTAL) AS VALOR FROM SF2020 SF2 "
	ElseIf t = 2
		cQuery2 := " SELECT F2_CLIENTE AS CLIENTE, F2_LOJA AS LOJA, D2_DOC AS NOTA, D2_SERIE AS SERIE, D2_TES AS TES, BM_GRUPO AS GRUPO , BM_TIPGRU AS FAMILIA, SUBSTRING(F2_EMISSAO,1,6) AS DT "
		cQuery2 += " , SUM(D2_QUANT) AS TOTAL, SUM(D2_TOTAL) AS VALOR FROM SF2020 SF2 "
	ElseIf t = 3
		cQuery2 := " SELECT F2_CLIENTE AS CLIENTE, F2_LOJA AS LOJA, D2_DOC AS NOTA, D2_SERIE AS SERIE, D2_TES AS TES, BM_GRUPO AS GRUPO , BM_TIPGRU AS FAMILIA, SUBSTRING(F2_EMISSAO,1,6) AS DT "
		cQuery2 += " , SUM(D2_VALBRUT) AS TOTAL, SUM(D2_TOTAL) AS VALOR FROM SF2020 SF2 "
	EndIf
	//
	cQuery2 += " INNER JOIN SD2020 SD2 ON D2_DOC = F2_DOC AND D2_SERIE = F2_SERIE AND D2_CLIENTE = F2_CLIENTE AND F2_LOJA = D2_LOJA "
	cQuery2 += " INNER JOIN SB1010 SB1 ON B1_COD = D2_COD "
	cQuery2 += " INNER JOIN SF4020 SF4 ON F4_CODIGO = D2_TES "
	cQuery2 += " INNER JOIN SBM010 SBM ON BM_GRUPO = B1_GRUPO  "
	cQuery2 += " WHERE SD2.D_E_L_E_T_ <> '*' AND "
	cQuery2 += " SF2.D_E_L_E_T_ <> '*' AND "
	cQuery2 += " SB1.D_E_L_E_T_ <> '*' AND "
	cQuery2 += " SF4.D_E_L_E_T_ <> '*' AND "
	cQuery2 += " SBM.D_E_L_E_T_ <> '*' AND "
	cQuery2 += " F4_URELFAT = '1' AND "
	cQuery2 += " D2_TIPO = 'N' AND D2_NFORI = '' AND "
	cQuery2 += " F2_DOC BETWEEN '         ' AND 'ZZZZZZZZZ' AND "
	cQuery2 += " BM_GRUPO BETWEEN '    ' AND '9999' AND "
	cQuery2 += " BM_XWKFLOW = 'S' AND "
	cQuery2 += " F2_EMISSAO BETWEEN '"+DTOS(_dDatade)+"' AND '"+ DTOS(DDATABASE)+"' AND "
	cQuery2 += " D2_COD BETWEEN '               ' AND 'ZZZZZZZZZZZZZZZ' AND "
	cQuery2 += " (F2_CLIENTE <> '008360' AND F2_CLIENTE <> '020793') "
	cQuery2 += " GROUP BY F2_CLIENTE, F2_LOJA, D2_DOC, D2_SERIE, BM_GRUPO, BM_TIPGRU, SUBSTRING(F2_EMISSAO,1,6),D2_TES "
	cQuery2 += " ORDER BY BM_GRUPO, SUBSTRING(F2_EMISSAO,1,6) "
	//
	cQuery2 := ChangeQuery(cQuery2)
	//
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery2),"QRYE2",.F.,.T.)
	//
	DbSelectArea("QRYE2")
	DbGoTop()
	//
	While QRYE2->(!EOF())
		If QRYE2->TOTAL > 0
			DbSelectArea("TRB")
			dbGoTop()
			//
			TRB->(RecLock("TRB",.T.))
			TRB->CLIENTE := QRYE2->CLIENTE
			TRB->LOJA 	 := QRYE2->LOJA
			TRB->NOTA	 := QRYE2->NOTA
			TRB->SERIE	 := QRYE2->SERIE
			TRB->TES	 := QRYE2->TES
			TRB->GRUPO	 := QRYE2->GRUPO
			TRB->FAMILIA := QRYE2->FAMILIA
			TRB->DT		 := QRYE2->DT
			TRB->TOTAL	 := QRYE2->TOTAL
			TRB->VALOR	 := QRYE2->VALOR
			TRB->(MsUnlock("TRB"))
			DbSelectArea("QRYE2")
			QRYE2->(DbSkip())
		Else
			DbSelectArea("QRYE2")
			QRYE2->(DbSkip())
		EndIf
		//
	End
	//
	
	If t <> 3 // Quando for Categoria X Valor Bruto não vai considerar as devoluções no calculo - I1604-019 
	
		// DEVOLUCOES
		//
		//
		If t = 1
			cQRD := " SELECT F1_FORNECE AS FORNEC, F1_LOJA AS LOJA, D1_DOC AS NOTA, D1_SERIE AS SERIE, D1_TES AS TES, BM_GRUPO AS GRUPO , BM_TIPGRU AS FAMILIA, SUBSTRING(F1_DTDIGIT,1,6) AS DT "
			cQRD += " , SUM(D1_TOTAL) AS TOTAL, SUM(D1_TOTAL) AS VALOR FROM SF1010 SF1 "
		ElseIf t = 2
			cQRD := " SELECT F1_FORNECE AS FORNEC, F1_LOJA AS LOJA, D1_DOC AS NOTA, D1_SERIE AS SERIE, D1_TES AS TES, BM_GRUPO AS GRUPO , BM_TIPGRU AS FAMILIA, SUBSTRING(F1_DTDIGIT,1,6) AS DT "
			cQRD += " , SUM(D1_QUANT) AS TOTAL, SUM(D1_TOTAL) AS VALOR FROM SF1010 SF1 "
		ElseIf t = 3
			cQRD := " SELECT F1_FORNECE AS FORNEC, F1_LOJA AS LOJA, D1_DOC AS NOTA, D1_SERIE AS SERIE, D1_TES AS TES, BM_GRUPO AS GRUPO , BM_TIPGRU AS FAMILIA, SUBSTRING(F1_DTDIGIT,1,6) AS DT "
			cQRD += " , SUM(D1_TOTAL) AS TOTAL, SUM(D1_TOTAL) AS VALOR FROM SF1010 SF1 "
		EndIf
		//
		cQRD += " INNER JOIN SD1010 SD1 ON D1_DOC = F1_DOC AND D1_SERIE = F1_SERIE AND D1_FORNECE = F1_FORNECE AND D1_LOJA = F1_LOJA "
		cQRD += " INNER JOIN SB1010 SB1 ON B1_COD = D1_COD "
		cQRD += " INNER JOIN SF4010 SF4 ON F4_CODIGO = D1_TES "
		cQRD += " INNER JOIN SBM010 SBM ON BM_GRUPO = B1_GRUPO  "
		cQRD += " WHERE SD1.D_E_L_E_T_ <> '*' AND "
		cQRD += " SF1.D_E_L_E_T_ <> '*' AND "
		cQRD += " SB1.D_E_L_E_T_ <> '*' AND "
		cQRD += " SF4.D_E_L_E_T_ <> '*' AND "
		cQRD += " SBM.D_E_L_E_T_ <> '*' AND "
		cQRD += " F4_URELFAT = '1' AND "
		cQRD += " BM_GRUPO BETWEEN '    ' AND '9999' AND "
		cQRD += " F1_DTDIGIT BETWEEN '"+DTOS(_dDatade)+"' AND '"+ DTOS(DDATABASE)+"' AND "
		cQRD += " D1_COD BETWEEN '               ' AND 'ZZZZZZZZZZZZZZZ' AND "
		cQRD += " BM_GRUPO <> '' AND "
		cQRD += " BM_XWKFLOW = 'S' AND "
		cQRD += " (F1_FORNECE <> '008360' AND F1_FORNECE <> '020793') "
		cQRD += " GROUP BY F1_FORNECE, F1_LOJA, D1_DOC, D1_SERIE, BM_GRUPO, BM_TIPGRU, SUBSTRING(F1_DTDIGIT,1,6), D1_TES "
	
		cQRD += " ORDER BY BM_GRUPO, SUBSTRING(F1_DTDIGIT,1,6) "
		//
		cQRD := ChangeQuery(cQRD)
		//
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQRD),"QRD",.F.,.T.)
		//
		DbSelectArea("QRD")
		DbGoTop()
		//
		While QRD->(!EOF())
			//
			If QRD->TOTAL > 0
				DbSelectArea("TRD")
				TRD->(RecLock("TRD",.T.))
				TRD->FORNECE := QRD->FORNEC
				TRD->LOJA 	 := QRD->LOJA
				TRD->NOTA	 := QRD->NOTA
				TRD->SERIE	 := QRD->SERIE
				TRD->TES	 := QRD->TES
				TRD->GRUPO	 := QRD->GRUPO
				TRD->FAMILIA := QRD->FAMILIA
				TRD->DT		 := QRD->DT
				TRD->TOTAL	 := QRD->TOTAL
				TRD->VALOR	 := QRD->VALOR
				TRD->(MsUnlock("TRD"))
				//
				DbSelectArea("QRD")
				QRD->(DbSkip())
			Else
				DbSelectArea("QRD")
				QRD->(DbSkip())
			EndIf
		End
		//
		// EMPRESA 2
		//
		If t = 1
			cQRD2 := " SELECT F1_FORNECE AS FORNEC, F1_LOJA AS LOJA, D1_DOC AS NOTA, D1_SERIE AS SERIE, D1_TES AS TES, BM_GRUPO AS GRUPO , BM_TIPGRU AS FAMILIA, SUBSTRING(F1_DTDIGIT,1,6) AS DT "
			cQRD2 += " , SUM(D1_TOTAL) AS TOTAL, SUM(D1_TOTAL) AS VALOR FROM SF1020 SF1 "
		ElseIf t = 2
			cQRD2 := " SELECT F1_FORNECE AS FORNEC, F1_LOJA AS LOJA, D1_DOC AS NOTA, D1_SERIE AS SERIE, D1_TES AS TES, BM_GRUPO AS GRUPO , BM_TIPGRU AS FAMILIA, SUBSTRING(F1_DTDIGIT,1,6) AS DT "
			cQRD2 += " , SUM(D1_QUANT) AS TOTAL, SUM(D1_TOTAL) AS VALOR FROM SF1020 SF1 "
		ElseIf t = 3
			cQRD2 := " SELECT F1_FORNECE AS FORNEC, F1_LOJA AS LOJA, D1_DOC AS NOTA, D1_SERIE AS SERIE, D1_TES AS TES, BM_GRUPO AS GRUPO , BM_TIPGRU AS FAMILIA, SUBSTRING(F1_DTDIGIT,1,6) AS DT "
			cQRD2 += " , SUM(D1_TOTAL) AS TOTAL, SUM(D1_TOTAL) AS VALOR FROM SF1020 SF1 "
		EndIf
		//
		cQRD2 += " INNER JOIN SD1020 SD1 ON D1_DOC = F1_DOC AND D1_SERIE = F1_SERIE AND D1_FORNECE = F1_FORNECE AND D1_LOJA = F1_LOJA "
		cQRD2 += " INNER JOIN SB1010 SB1 ON B1_COD = D1_COD "
		cQRD2 += " INNER JOIN SF4020 SF4 ON F4_CODIGO = D1_TES "
		cQRD2 += " INNER JOIN SBM010 SBM ON BM_GRUPO = B1_GRUPO  "
		cQRD2 += " WHERE SD1.D_E_L_E_T_ <> '*' AND "
		cQRD2 += " SF1.D_E_L_E_T_ <> '*' AND "
		cQRD2 += " SB1.D_E_L_E_T_ <> '*' AND "
		cQRD2 += " SF4.D_E_L_E_T_ <> '*' AND "
		cQRD2 += " SBM.D_E_L_E_T_ <> '*' AND "
		cQRD2 += " F4_URELFAT = '1' AND "
		cQRD2 += " BM_GRUPO BETWEEN '    ' AND '9999' AND "
		cQRD2 += " F1_DTDIGIT BETWEEN '"+DTOS(_dDatade)+"' AND '"+ DTOS(DDATABASE)+"' AND "
		cQRD2 += " D1_COD BETWEEN '               ' AND 'ZZZZZZZZZZZZZZZ' AND "
		cQRD2 += " BM_GRUPO <> '' AND "
		cQRD2 += " BM_XWKFLOW = 'S' AND "
		cQRD2 += " (F1_FORNECE <> '008360' AND F1_FORNECE <> '020793') "
		cQRD2 += " GROUP BY F1_FORNECE, F1_LOJA, D1_DOC, D1_SERIE, BM_GRUPO, BM_TIPGRU, SUBSTRING(F1_DTDIGIT,1,6),D1_TES "
		cQRD2 += " ORDER BY BM_GRUPO, SUBSTRING(F1_DTDIGIT,1,6) "	
		//
		cQRD2 := ChangeQuery(cQRD2)
		//
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQRD2),"QRD2",.F.,.T.)
		//
		DbSelectArea("QRD2")
		DbGoTop()
		//
		While QRD2->(!EOF())
			If QRD2->TOTAL > 0
				DbSelectArea("TRD")
				dbGoTop()
				//
				TRD->(RecLock("TRD",.T.))
				TRD->FORNECE := QRD2->FORNEC
				TRD->LOJA 	 := QRD2->LOJA
				TRD->NOTA	 := QRD2->NOTA
				TRD->SERIE	 := QRD2->SERIE
				TRD->TES	 := QRD2->TES
				TRD->GRUPO	 := QRD2->GRUPO
				TRD->FAMILIA := QRD2->FAMILIA
				TRD->DT	 	 := QRD2->DT
				TRD->TOTAL	 := QRD2->TOTAL
				TRD->VALOR	 := QRD2->VALOR
				TRD->(MsUnlock("TRD"))
				DbSelectArea("QRD2")
				QRD2->(DbSkip())
			Else
				DbSelectArea("QRD2")
				QRD2->(DbSkip())
			EndIf
			//
		End
		//
			
		// FIM DAS DEVOLUCOES
		
		DbSelectArea("TRD")
		DbGoTop()
		
		While TRD->(!EOF())
			If TRD->TOTAL > 0
				DbSelectArea("TRB")
				//
				TRB->(RecLock("TRB",.T.))
				TRB->CLIENTE := TRD->FORNECE
				TRB->LOJA 	 := TRD->LOJA
				TRB->NOTA	 := TRD->NOTA
				TRB->SERIE	 := TRD->SERIE
				TRB->TES	 := TRD->TES
				TRB->GRUPO	 := TRD->GRUPO
				TRB->FAMILIA := TRD->FAMILIA
				TRB->DT	 	 := TRD->DT
				TRB->TOTAL	 := (TRD->TOTAL*(-1))
				TRB->VALOR	 := (TRD->VALOR*(-1))
				TRB->(MsUnlock("TRB"))
				
				DbSelectArea("TRD")
				TRD->(DbSkip())
			EndIf
		End
	
	EndIf // Quando for Categoria X Valor Bruto não vai considerar as devoluções no calculo - I1604-019 
		
	_aMesExt := {'JAN', 'FEV', 'MAR','ABR', 'MAI', 'JUN','JUL', 'AGO', 'SET','OUT', 'NOV', 'DEZ'}
	_nControl:= Month(_dDatade)
	
	For x:= _nControl to _nControl + 5
		//
		If x <= 0
			Cabec += _aMesExt[x+12] + Space(20)
			AADD(aCabec1,{_aMesExt[x+12]})
		ElseIf x > 12           
			Cabec += _aMesExt[x-12] +Space(20)
			AADD(aCabec1,{_aMesExt[x-12]})
		Else
			Cabec += _aMesExt[x] +Space(20)
			AADD(aCabec1,{_aMesExt[x]})
		EndIf
		//
	Next x
	
	For y:= 1 to Len(Cabec)
		If Len(AllTrim(Substr(Cabec,y,3))) = 3
			AADD(aPos,{Substr(Cabec,y,3),_nPos})
			_nPos  += 0300
		EndIf
	Next y
	DbSelectArea("TRB")
	
//	index on TRB->FAMILIA+TRB->DT+TRB->NOTA+TRB->SERIE to &(cArqTrb+"1") 
	index on TRB->GRUPO+TRB->DT+TRB->NOTA+TRB->SERIE to &(cArqTrb+"1")
	set index to &(cArqTrb+"1")
	//          
	  
	aTOTMES := {}             
	
	FOR nX:= 1 TO LEN(aCABEC1)
		AADD(aTOTMES,{aCABEC1[nX][1],0})
	END
	
	_nTotalGer := 0
	DbSelectArea("TRB")
	dbGoTop()
	While TRB->(!EOF())
		
		_vFamilia 	:= TRB->GRUPO //TRB->FAMILIA 		//ARMAZENA A FAMILIA
	
		DBSELECTAREA("SBM")
		DBSETORDER(1)
		DBGOTOP()
		if DBSEEK(XFILIAL("SMB")+_vFamilia)
			xDescrg:=Alltrim(SBM->BM_DESC)
		Else
			xDescrg:=""
		Endif
		_nTotal	:= 0
		DbSelectArea("TRB")	
		WHILE !EOF() .AND. 	_vFamilia == TRB->GRUPO
			_cVerFamDt  := TRB->GRUPO+TRB->DT
			_Total := 0
		 	cDT := TRB->DT
			WHILE !EOF() .AND. _cVerFamDt == (TRB->GRUPO+TRB->DT)
			
				If TRB->TOTAL = 0 .Or. (TRB->CLIENTE == "008360" .Or.  TRB->CLIENTE == "020793") // Clientes Transferencia
					DbSkip()
					Loop
				EndIf                     
		
				IF	TRB->CLIENTE == "027455" .AND. 	TRB->LOJA == "01" .AND. TRB->NOTA == "000055000" .AND. TRB->TES	== "633" .AND. TRB->GRUPO == "0103" .AND. TRB->DT == "201403"
					lOK := .T.
				ENDIF
		
				_Total 		+= ROUND(TRB->TOTAL,2) //ACUMULA O TOTAL POR FAMILIA+DATA
				_nTotal 	+= ROUND(TRB->TOTAL,2) // ACUMULA O TOTAL POR FAMILIA
				_nTotalGer 	+= ROUND(TRB->TOTAL,2) // ACUMULA O TOTAL Geral
				DbSkip()
			END
			IF SUBS(cDT,5,2) == "01"
				cMES := "JAN"
			ELSEIF SUBS(cDT,5,2) == "02"
				cMES := "FEV"
			ELSEIF SUBS(cDT,5,2) == "03"
				cMES := "MAR"
			ELSEIF SUBS(cDT,5,2) == "04"
				cMES := "ABR"
			ELSEIF SUBS(cDT,5,2) == "05"
				cMES := "MAI"
			ELSEIF SUBS(cDT,5,2) == "06"
				cMES := "JUN"
			ELSEIF SUBS(cDT,5,2) == "07"
				cMES := "JUL"
			ELSEIF SUBS(cDT,5,2) == "08"
				cMES := "AGO"
			ELSEIF SUBS(cDT,5,2) == "09"
				cMES := "SET"
			ELSEIF SUBS(cDT,5,2) == "10"
				cMES := "OUT"
			ELSEIF SUBS(cDT,5,2) == "11"
				cMES := "NOV"
			ELSEIF SUBS(cDT,5,2) == "12"
				cMES := "DEZ"
			ENDIF
				
			AADD(aDados,{_vFamilia,cMES,_Total})
			
			FOR nX := 1 TO LEN(aTOTMES)
			   IF aTOTMES[nX][1] == cMES
			      aTOTMES[nX][2] += _Total
			   ENDIF
			END
		END
	    AADD(aDados,{_vFamilia,"Total",_nTotal})
	END
    FOR nX := 1 TO LEN(aTOTMES)
    	IF aTOTMES[nX][2] <> 0
//    		AADD(aDados,{"TotFam",aTOTMES[nX][1],aTOTMES[nX][2]})
    	ENDIF
	END
	
//	AADD(aDados,{"TotGer","Total",_nTotalGer})    
    cTESTE := ""
	//
	U_RFATSEM(t,aDados,aCabec1,_nTotalGer)
	//
Next t

Return(Nil)