#Include "Topconn.ch"
#Include "Protheus.ch"

///*
//ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
//±±ºPrograma  ³RFATLIQ   ºAutor  ³André Bagatini	   º Data ³ 22/07/11    º±±
//±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
//±±ºDesc.     ³Relatório de Faturamento Vendas - (Devoluções + Impostos)   º±±
//±±º          ³Por Valor / Quantidade / R$ Medio							º±±
//±±º          ³Perguntas: Do Cliente / Até Cliente                         º±±
//±±º          ³															º±±
//±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
//±±ºUso       ³ Eletromega					                                º±±
//±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
//*/

User Function RFATLIQ()

Local xAlias 	 := GetArea()
Private cCabec   := ""
Private cPerg    := "RFATLIQ" //criar pergunta

ValidPerg(cPerg)

If !Pergunte(cPerg,.T.)
	Return()
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Selecao da impressora.         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oObjPrint:= TMSPrinter():New(cCabec)
oObjPrint:SetSize( 210, 297 )
oObjPrint:SetLandscape()
oObjPrint:Setup()

LjMsgRun("Por Favor Aguarde, Impressao Faturamento por Categoria  ...",,{|| Imprime() })

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Mostra relatorio para imprimir. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oObjPrint:Preview()

RestArea(xAlias)

Return(Nil)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Imprime   ºAutor  ³ Andre Bagatini     º Data ³   22/07/11  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Chamada do Objeto de Impressão 					          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Imprime()

Private oFonte1		:= Nil
Private oFonte2		:= Nil
Private oFonte3		:= Nil
Private oFonte4		:= Nil
Private oFonte5		:= Nil
Private oFonte6		:= Nil
Private oFonte7		:= Nil
Private oFonte8    	:= Nil
Private oFonte9		:= Nil
Private oFonte10	:= Nil
Private oFonte11    := Nil
Private oFonte12    := Nil
Private nLinhaAtual := 0
Private nNumPagina	:= 0
Private nVias       := 1

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Inicializa objetos da classe TMSPrinter.			³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oBrushCinza	:= TBrush():New(,Rgb(214,214,214))                  //Objeto Cinza
oFont1      := TFont():New("Arial"     ,11,11,,.F.,,,,,.F.)   // Normal
oFont2      := TFont():New("Arial"     ,11,11,,.T.,,,,,.F.)   // Negrito
oFont3      := TFont():New("Arial"     ,11,11,,.T.,,,,,.T.)   // Negrito / Sublinhado
oFont4      := TFont():New("Arial"     ,13,13,,.F.,,,,,.F.)   // Normal
oFont5      := TFont():New("Arial"     ,13,13,,.T.,,,,,.F.)   // Negrito
oFont6      := TFont():New("Arial"     ,13,13,,.T.,,,,,.T.)   // Negrito / Sublinhado
oFont7      := TFont():New("Verdana"   ,14,14,,.T.,,,,,.F.)   // Normal
oFont8      := TFont():New("Verdana"   ,10,10,,.F.,,,,,.T.)   // Sublinhado
oFont9      := TFont():New("Arial"     ,08,08,,.F.,,,,,.F.)   // Normal
oFont10     := TFont():New("Arial"     ,08,08,,.T.,,,,,.F.)   // Negrito
oFont11     := TFont():New("Arial"     ,18,18,,.F.,,,,,.F.)   // Normal
oFont12     := TFont():New("Arial"     ,18,18,,.T.,,,,,.F.)   // Negrito
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Imprime cabecalho do relatorio. 		        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
lFirst   := .T.

ValidPerg(cPerg)

oObjPrint:StartPage()
Processa({|| ImpRel() },"Coletando dados, Aguarde...")
oObjPrint:EndPage()

Return(Nil)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ImpRel    ºAutor  ³Sergio Celestino    º Data ³  05/02/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Locar                                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ImpRel()

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
Local _lVerif 	 := .F.
Private cArqTrb  := CriaTrab(NIL,.F.)
Private cArqTrb2 := CriaTrab(NIL,.F.)
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

_dDatade := mv_par06 - 180

If (DateDiffMonth( DDATABASE , _dDatade ) == 6)
	_dDatade := LastDate(_dDatade) + 1
Else
	_dDatade := FirstDate(_dDatade)  
EndIf 	

/*           
_dDatade :=DaySub( mv_par06 , 180 )

_cMes1 := SUBSTR(DTOS(_dDatade),5,2)
_cMes2 := SUBSTR(DTOS(mv_par06),5,2)

If (Val(_cMes2) - Val(_cMes1)) = 6
	_dDatade := LastDate(DaySub(  mv_par06 , 180 ))
	_dDatade := DaySum( _dDatade , 1 )
Else
	_dDatade := FirstDate(DaySub(  mv_par06 , 180 ))
EndIf	
*/

If mv_par09 = 2// SAIDAS
	//
	If mv_par05 = 1
		cQuery := " SELECT F2_CLIENTE AS CLIENTE, F2_LOJA AS LOJA, D2_DOC AS NOTA, D2_SERIE AS SERIE, D2_TES AS TES, BM_GRUPO AS GRUPO , BM_TIPGRU AS FAMILIA, SUBSTRING(F2_EMISSAO,1,6) AS DT "
		cQuery += " , SUM(D2_TOTAL) AS TOTAL, SUM(D2_TOTAL) AS VALOR FROM " + RetSqlName("SF2") + " SF2 "
	ElseIf mv_par05 = 2
		cQuery := " SELECT F2_CLIENTE AS CLIENTE, F2_LOJA AS LOJA, D2_DOC AS NOTA, D2_SERIE AS SERIE, D2_TES AS TES, BM_GRUPO AS GRUPO , BM_TIPGRU AS FAMILIA, SUBSTRING(F2_EMISSAO,1,6) AS DT "
		cQuery += " , SUM(D2_QUANT) AS TOTAL, SUM(D2_TOTAL) AS VALOR FROM " + RetSqlName("SF2") + " SF2 "
/*	ElseIf mv_par05 = 3
		cQuery := " SELECT F2_CLIENTE AS CLIENTE, F2_LOJA AS LOJA, D2_DOC AS NOTA, D2_SERIE AS SERIE, D2_TES AS TES, BM_GRUPO AS GRUPO , BM_TIPGRU AS FAMILIA, SUBSTRING(F2_EMISSAO,1,6) AS DT "
		cQuery += " ,(SUM(D2_TOTAL)/SUM(D2_QUANT)) AS TOTAL, (SUM(D2_TOTAL)/SUM(D2_QUANT)) AS VALOR FROM " + RetSqlName("SF2") + " SF2 "*/
	ElseIf mv_par05 = 3
		cQuery := " SELECT F2_CLIENTE AS CLIENTE, F2_LOJA AS LOJA, D2_DOC AS NOTA, D2_SERIE AS SERIE, D2_TES AS TES, BM_GRUPO AS GRUPO , BM_TIPGRU AS FAMILIA, SUBSTRING(F2_EMISSAO,1,6) AS DT "
		cQuery += " , SUM(D2_VALBRUT) AS TOTAL, SUM(D2_TOTAL) AS VALOR FROM " + RetSqlName("SF2") + " SF2 "
	EndIf
	//
	cQuery += " INNER JOIN " + RetSqlName("SD2") + " SD2 ON D2_DOC = F2_DOC AND D2_SERIE = F2_SERIE AND D2_CLIENTE = F2_CLIENTE AND D2_LOJA = D2_LOJA "
	cQuery += " INNER JOIN " + RetSqlName("SB1") + " SB1 ON B1_COD = D2_COD "
	cQuery += " INNER JOIN " + RetSqlName("SF4") + " SF4 ON F4_CODIGO = D2_TES "
	cQuery += " INNER JOIN " + RetSqlName("SBM") + " SBM ON BM_GRUPO = B1_GRUPO  "
	cQuery += " WHERE SD2.D_E_L_E_T_ <> '*' AND "
	cQuery += " SF2.D_E_L_E_T_ <> '*' AND "
	cQuery += " SB1.D_E_L_E_T_ <> '*' AND "
	cQuery += " SF4.D_E_L_E_T_ <> '*' AND "
	cQuery += " SBM.D_E_L_E_T_ <> '*' AND "
	cQuery += " F4_URELFAT = '1' AND "
	cQuery += " D2_TIPO = 'N' AND D2_NFORI = '' AND "
	cQuery += " F2_DOC BETWEEN '"+ mv_par01 +"' AND '"+ mv_par02+"' AND "
	cQuery += " BM_GRUPO BETWEEN '"+ mv_par03 +"' AND '"+ mv_par04+"' AND "
	cQuery += " F2_EMISSAO BETWEEN '"+DTOS(_dDatade)+"' AND '"+ DTOS(mv_par06)+"' AND"
	cQuery += " D2_COD BETWEEN '"+ mv_par07 +"' AND '"+ mv_par08+"' AND "
	//	cQuery += " (D2_TES <> '731' AND D2_TES <> '526') AND "
	cQuery += " BM_TIPGRU <> '' AND "
	cQuery += " (F2_CLIENTE <> '008360' AND F2_CLIENTE <> '020793') "
	//	cQuery += " D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA NOT IN (SELECT  D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA FROM " + RetSqlName("SD1") + " SD1 WHERE SD1.D_E_L_E_T_ <> '*' )  "
	cQuery += " GROUP BY F2_CLIENTE, F2_LOJA, D2_DOC, D2_SERIE, BM_GRUPO, BM_TIPGRU, SUBSTRING(F2_EMISSAO,1,6), D2_TES "
	cQuery += " ORDER BY BM_TIPGRU, SUBSTRING(F2_EMISSAO,1,6) "
	//
	cQuery := ChangeQuery(cQuery)
	//
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"QRY",.F.,.T.)
	//
	DbSelectArea("QRY")
	DbGoTop()
	//
	While QRY->(!EOF())
		nRegs:= nRegs+1
		QRY->(DbSkip())
	End
	//
	DbGoTop()
	//
	DbSelectArea("QRY")
	ProcRegua(nRegs)
	While QRY->(!EOF())
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
		IncProc("Processando Empresa "+SM0->M0_CODIGO+" "+Str(Recno(),6)+"/"+Str(nRegs,6))
	End
EndIf
//
If mv_par09 = 1 // SAIDAS
	//
	If mv_par05 = 1
		cQuery := " SELECT F2_CLIENTE AS CLIENTE, F2_LOJA AS LOJA, D2_DOC AS NOTA, D2_SERIE AS SERIE, D2_TES AS TES, BM_GRUPO AS GRUPO , BM_TIPGRU AS FAMILIA, SUBSTRING(F2_EMISSAO,1,6) AS DT "
		cQuery += " , SUM(D2_TOTAL) AS TOTAL, SUM(D2_TOTAL) AS VALOR FROM SF2010 SF2 "
	ElseIf mv_par05 = 2
		cQuery := " SELECT F2_CLIENTE AS CLIENTE, F2_LOJA AS LOJA, D2_DOC AS NOTA, D2_SERIE AS SERIE, D2_TES AS TES, BM_GRUPO AS GRUPO , BM_TIPGRU AS FAMILIA, SUBSTRING(F2_EMISSAO,1,6) AS DT "
		cQuery += " , SUM(D2_QUANT) AS TOTAL, SUM(D2_TOTAL) AS VALOR FROM SF2010 SF2 "
/*	ElseIf mv_par05 = 3
		cQuery := " SELECT F2_CLIENTE AS CLIENTE, F2_LOJA AS LOJA, D2_DOC AS NOTA, D2_SERIE AS SERIE, D2_TES AS TES, BM_GRUPO AS GRUPO , BM_TIPGRU AS FAMILIA, SUBSTRING(F2_EMISSAO,1,6) AS DT "
		cQuery += " ,(SUM(D2_TOTAL)/SUM(D2_QUANT)) AS TOTAL, (SUM(D2_TOTAL)/SUM(D2_QUANT)) AS VALOR FROM SF2010 SF2 "*/
	ElseIf mv_par05 = 3
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
	cQuery += " F2_DOC BETWEEN '"+ mv_par01 +"' AND '"+ mv_par02+"' AND "
	cQuery += " BM_GRUPO BETWEEN '"+ mv_par03 +"' AND '"+ mv_par04+"' AND "
	cQuery += " F2_EMISSAO BETWEEN '"+DTOS(_dDatade)+"' AND '"+ DTOS(mv_par06)+"' AND"
	cQuery += " D2_COD BETWEEN '"+ mv_par07 +"' AND '"+ mv_par08+"' AND "
	//	cQuery += " (D2_TES <> '731' AND D2_TES <> '526') AND "
	cQuery += " BM_TIPGRU <> '' AND "
	cQuery += " (F2_CLIENTE <> '008360' AND F2_CLIENTE <> '020793') "
	//	cQuery += " D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA NOT IN (SELECT  D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA FROM  SD1010 SD1 WHERE SD1.D_E_L_E_T_ <> '*' )  "
	cQuery += " GROUP BY F2_CLIENTE, F2_LOJA, D2_DOC, D2_SERIE, BM_GRUPO, BM_TIPGRU, SUBSTRING(F2_EMISSAO,1,6), D2_TES "
	cQuery += " ORDER BY BM_TIPGRU, SUBSTRING(F2_EMISSAO,1,6) "
	//
	cQuery := ChangeQuery(cQuery)
	//
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"QRY",.F.,.T.)
	//
	DbSelectArea("QRY")
	DbGoTop()
	//
	While QRY->(!EOF())
		nRegs:= nRegs+1
		QRY->(DbSkip())
	End
	DbGoTop()
	//
	ProcRegua(nRegs)
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
			If AllTrim(QRY->DT) = ""
				ApMsgStop(QRYE2->CLIENTE + '  ' + QRYE2->LOJA + '  ' + QRYE2->NOTA + '  ' + QRYE2->SERIE + '  ' + QRYE2->DT )
			EndIf
			QRY->(DbSkip())
		Else
			DbSelectArea("QRY")
			QRY->(DbSkip())
		EndIf
		IncProc("Processando Empresa 1 "+Str(Recno(),6)+"/"+Str(nRegs,6))		//
	End
	//
	// EMPRESA 2
	//
	If mv_par05 = 1
		cQuery2 := " SELECT F2_CLIENTE AS CLIENTE, F2_LOJA AS LOJA, D2_DOC AS NOTA, D2_SERIE AS SERIE, D2_TES AS TES, BM_GRUPO AS GRUPO , BM_TIPGRU AS FAMILIA, SUBSTRING(F2_EMISSAO,1,6) AS DT "
		cQuery2 += " , SUM(D2_TOTAL) AS TOTAL, SUM(D2_TOTAL) AS VALOR FROM SF2020 SF2 "
	ElseIf mv_par05 = 2
		cQuery2 := " SELECT F2_CLIENTE AS CLIENTE, F2_LOJA AS LOJA, D2_DOC AS NOTA, D2_SERIE AS SERIE, D2_TES AS TES, BM_GRUPO AS GRUPO , BM_TIPGRU AS FAMILIA, SUBSTRING(F2_EMISSAO,1,6) AS DT "
		cQuery2 += " , SUM(D2_QUANT) AS TOTAL, SUM(D2_TOTAL) AS VALOR FROM SF2020 SF2 "
/*	ElseIf mv_par05 = 3
		cQuery2 := " SELECT F2_CLIENTE AS CLIENTE, F2_LOJA AS LOJA, D2_DOC AS NOTA, D2_SERIE AS SERIE, D2_TES AS TES, BM_GRUPO AS GRUPO , BM_TIPGRU AS FAMILIA, SUBSTRING(F2_EMISSAO,1,6) AS DT "
		cQuery2 += " ,(SUM(D2_TOTAL)/SUM(D2_QUANT)) AS TOTAL, (SUM(D2_TOTAL)/SUM(D2_QUANT)) AS VALOR FROM SF2020 SF2 "*/
	ElseIf mv_par05 = 3
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
	cQuery2 += " F2_DOC BETWEEN '"+ mv_par01 +"' AND '"+ mv_par02+"' AND "
	cQuery2 += " BM_GRUPO BETWEEN '"+ mv_par03 +"' AND '"+ mv_par04+"' AND "
	cQuery2 += " F2_EMISSAO BETWEEN '"+DTOS(_dDatade)+"' AND '"+ DTOS(mv_par06)+"' AND"
	cQuery2 += " D2_COD BETWEEN '"+ mv_par07 +"' AND '"+ mv_par08+"' AND "
	//	cQuery2 += " (D2_TES <> '731' AND D2_TES <> '526') AND "
	cQuery2 += " BM_TIPGRU <> '' AND "
	cQuery2 += " (F2_CLIENTE <> '008360' AND F2_CLIENTE <> '020793') "
	//	cQuery2 += " D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA NOT IN (SELECT  D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA FROM SD1020 SD1 WHERE SD1.D_E_L_E_T_ <> '*' )  "
	cQuery2 += " GROUP BY F2_CLIENTE, F2_LOJA, D2_DOC, D2_SERIE, BM_GRUPO, BM_TIPGRU, SUBSTRING(F2_EMISSAO,1,6),D2_TES "
	cQuery2 += " ORDER BY BM_TIPGRU, SUBSTRING(F2_EMISSAO,1,6) "
	//
	cQuery2 := ChangeQuery(cQuery2)
	//
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery2),"QRYE2",.F.,.T.)
	//
	DbSelectArea("QRYE2")
	DbGoTop()
	//
	nRegs := 0
	//
	While QRYE2->(!EOF())
		nRegs:= nRegs+1
		QRYE2->(DbSkip())
	End
	//
	DbGoTop()
	//
	ProcRegua(nRegs)
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
			If AllTrim(QRYE2->DT) = ""
				ApMsgStop(QRYE2->CLIENTE + '  ' + QRYE2->LOJA + '  ' + QRYE2->NOTA + '  ' + QRYE2->SERIE + '  ' + QRYE2->DT )
			EndIf
			QRYE2->(DbSkip())
		Else
			DbSelectArea("QRYE2")
			QRYE2->(DbSkip())
		EndIf
		//
		IncProc("Processando Empresa 2 "+Str(Recno(),6)+"/"+Str(nRegs,6))
		//
	End
	//
EndIf

// FIM DAS SAIDAS
// DEVOLUCOES
//
If mv_par09 = 2// DEVOLUCOES
	//
	If mv_par05 = 1
		cQRD := " SELECT F1_FORNECE AS FORNEC, F1_LOJA AS LOJA, D1_DOC AS NOTA, D1_SERIE AS SERIE, D1_TES AS TES, BM_GRUPO AS GRUPO , BM_TIPGRU AS FAMILIA, SUBSTRING(F1_DTDIGIT,1,6) AS DT "
		cQRD += " , SUM(D1_TOTAL) AS TOTAL, SUM(D1_TOTAL) AS VALOR FROM " + RetSqlName("SF1") + " SF1 "
	ElseIf mv_par05 = 2
		cQRD := " SELECT F1_FORNECE AS FORNEC, F1_LOJA AS LOJA, D1_DOC AS NOTA, D1_SERIE AS SERIE, D1_TES AS TES, BM_GRUPO AS GRUPO , BM_TIPGRU AS FAMILIA, SUBSTRING(F1_DTDIGIT,1,6) AS DT "
		cQRD += " , SUM(D1_QUANT) AS TOTAL, SUM(D1_TOTAL) AS VALOR FROM " + RetSqlName("SF1") + " SF1 "
/*	ElseIf mv_par05 = 3
		cQRD := " SELECT F1_FORNECE AS FORNEC, F1_LOJA AS LOJA, D1_DOC AS NOTA, D1_SERIE AS SERIE, D1_TES AS TES, BM_GRUPO AS GRUPO , BM_TIPGRU AS FAMILIA, SUBSTRING(F1_DTDIGIT,1,6) AS DT "
		cQRD += " ,(SUM(D1_TOTAL)/SUM(D1_QUANT)) AS TOTAL, (SUM(D1_TOTAL)/SUM(D1_QUANT)) AS VALOR FROM " + RetSqlName("SF1") + " SF1 "*/
	ElseIf mv_par05 = 3
		cQRD := " SELECT F1_FORNECE AS FORNEC, F1_LOJA AS LOJA, D1_DOC AS NOTA, D1_SERIE AS SERIE, D1_TES AS TES, BM_GRUPO AS GRUPO , BM_TIPGRU AS FAMILIA, SUBSTRING(F1_DTDIGIT,1,6) AS DT "
		cQRD += " , SUM(D1_TOTAL) AS TOTAL, SUM(D1_TOTAL) AS VALOR FROM " + RetSqlName("SF1") + " SF1 "
	EndIf
	//
	cQRD += " INNER JOIN " + RetSqlName("SD1") + " SD1 ON D1_DOC = F1_DOC AND D1_SERIE = F1_SERIE AND D1_FORNECE = F1_FORNECE AND D1_LOJA = F1_LOJA "
	cQRD += " INNER JOIN " + RetSqlName("SB1") + " SB1 ON B1_COD = D1_COD "
	cQRD += " INNER JOIN " + RetSqlName("SF4") + " SF4 ON F4_CODIGO = D1_TES "
	cQRD += " INNER JOIN " + RetSqlName("SBM") + " SBM ON BM_GRUPO = B1_GRUPO  "
	cQRD += " WHERE SD1.D_E_L_E_T_ <> '*' AND "
	cQRD += " SF1.D_E_L_E_T_ <> '*' AND "
	cQRD += " SB1.D_E_L_E_T_ <> '*' AND "
	cQRD += " SF4.D_E_L_E_T_ <> '*' AND "
	cQRD += " SBM.D_E_L_E_T_ <> '*' AND "
	cQRD += " F4_URELFAT = '1' AND "
	//	cQuery += " D1_TIPO = 'N' AND D2_NFORI = '' AND "
	//	cQuery += " F2_DOC BETWEEN '"+ mv_par01 +"' AND '"+ mv_par02+"' AND "
	cQRD += " BM_GRUPO BETWEEN '"+ mv_par03 +"' AND '"+ mv_par04+"' AND "
	cQRD += " F1_DTDIGIT BETWEEN '"+DTOS(_dDatade)+"' AND '"+ DTOS(mv_par06)+"' AND"
	cQRD += " D1_COD BETWEEN '"+ mv_par07 +"' AND '"+ mv_par08+"' AND "
	//	cQuery += " (D2_TES <> '731' AND D2_TES <> '526') AND "
	cQRD += " BM_TIPGRU <> '' AND "
	cQRD += " (F1_FORNECE <> '008360' AND F1_FORNECE <> '020793') "
	//	cQuery += " D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA NOT IN (SELECT  D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA FROM " + RetSqlName("SD1") + " SD1 WHERE SD1.D_E_L_E_T_ <> '*' )  "
	cQRD += " GROUP BY F1_FORNECE, F1_LOJA, D1_DOC, D1_SERIE, BM_GRUPO, BM_TIPGRU, SUBSTRING(F1_DTDIGIT,1,6),D1_TES "
	cQRD += " ORDER BY BM_TIPGRU, SUBSTRING(F1_DTDIGIT,1,6) "
	//
	cQRD := ChangeQuery(cQRD)
	//
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQRD),"QRD",.F.,.T.)
	//
	DbSelectArea("QRD")
	DbGoTop()
	//
	nRegs := 0
	//
	While QRD->(!EOF())
		nRegs:= nRegs+1
		QRD->(DbSkip())
	End
	//
	DbGoTop()
	//
	DbSelectArea("QRD")
	ProcRegua(nRegs)
	While QRD->(!EOF())
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
		IncProc("Entradas Empresa "+SM0->M0_CODIGO+" "+Str(Recno(),6)+"/"+Str(nRegs,6))
	End
EndIf
//
If mv_par09 = 1
	//
	If mv_par05 = 1
		cQRD := " SELECT F1_FORNECE AS FORNEC, F1_LOJA AS LOJA, D1_DOC AS NOTA, D1_SERIE AS SERIE, D1_TES AS TES, BM_GRUPO AS GRUPO , BM_TIPGRU AS FAMILIA, SUBSTRING(F1_DTDIGIT,1,6) AS DT "
		cQRD += " , SUM(D1_TOTAL) AS TOTAL, SUM(D1_TOTAL) AS VALOR FROM SF1010 SF1 "
	ElseIf mv_par05 = 2
		cQRD := " SELECT F1_FORNECE AS FORNEC, F1_LOJA AS LOJA, D1_DOC AS NOTA, D1_SERIE AS SERIE, D1_TES AS TES, BM_GRUPO AS GRUPO , BM_TIPGRU AS FAMILIA, SUBSTRING(F1_DTDIGIT,1,6) AS DT "
		cQRD += " , SUM(D1_QUANT) AS TOTAL, SUM(D1_TOTAL) AS VALOR FROM SF1010 SF1 "
/*	ElseIf mv_par05 = 3
		cQRD := " SELECT F1_FORNECE AS FORNEC, F1_LOJA AS LOJA, D1_DOC AS NOTA, D1_SERIE AS SERIE, D1_TES AS TES, BM_GRUPO AS GRUPO , BM_TIPGRU AS FAMILIA, SUBSTRING(F1_DTDIGIT,1,6) AS DT "
		cQRD += " ,(SUM(D1_TOTAL)/SUM(D1_QUANT)) AS TOTAL, (SUM(D1_TOTAL)/SUM(D1_QUANT)) AS VALOR FROM SF1010 SF1 "*/
	ElseIf mv_par05 = 3
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
	//	cQuery += " D1_TIPO = 'N' AND D2_NFORI = '' AND "
	//	cQuery += " F2_DOC BETWEEN '"+ mv_par01 +"' AND '"+ mv_par02+"' AND "
	cQRD += " BM_GRUPO BETWEEN '"+ mv_par03 +"' AND '"+ mv_par04+"' AND "
	cQRD += " F1_DTDIGIT BETWEEN '"+DTOS(_dDatade)+"' AND '"+ DTOS(mv_par06)+"' AND"
	cQRD += " D1_COD BETWEEN '"+ mv_par07 +"' AND '"+ mv_par08+"' AND "
	//	cQuery += " (D2_TES <> '731' AND D2_TES <> '526') AND "
	cQRD += " BM_TIPGRU <> '' AND "
	cQRD += " (F1_FORNECE <> '008360' AND F1_FORNECE <> '020793') "
	//	cQuery += " D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA NOT IN (SELECT  D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA FROM " + RetSqlName("SD1") + " SD1 WHERE SD1.D_E_L_E_T_ <> '*' )  "
	cQRD += " GROUP BY F1_FORNECE, F1_LOJA, D1_DOC, D1_SERIE, BM_GRUPO, BM_TIPGRU, SUBSTRING(F1_DTDIGIT,1,6), D1_TES "
	cQRD += " ORDER BY BM_TIPGRU, SUBSTRING(F1_DTDIGIT,1,6) "
	//
	cQRD := ChangeQuery(cQRD)
	//
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQRD),"QRD",.F.,.T.)
	//
	DbSelectArea("QRD")
	DbGoTop()
	//
	nRegs := 0
	//
	While QRD->(!EOF())
		nRegs:= nRegs+1
		QRD->(DbSkip())
	End
	DbGoTop()
	//
	ProcRegua(nRegs)
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
		IncProc("Entradas Empresa 1 "+Str(Recno(),6)+"/"+Str(nRegs,6))		//
	End
	//
	// EMPRESA 2
	//
	If mv_par05 = 1
		cQRD2 := " SELECT F1_FORNECE AS FORNEC, F1_LOJA AS LOJA, D1_DOC AS NOTA, D1_SERIE AS SERIE, D1_TES AS TES, BM_GRUPO AS GRUPO , BM_TIPGRU AS FAMILIA, SUBSTRING(F1_DTDIGIT,1,6) AS DT "
		cQRD2 += " , SUM(D1_TOTAL) AS TOTAL, SUM(D1_TOTAL) AS VALOR FROM SF1020 SF1 "
	ElseIf mv_par05 = 2
		cQRD2 := " SELECT F1_FORNECE AS FORNEC, F1_LOJA AS LOJA, D1_DOC AS NOTA, D1_SERIE AS SERIE, D1_TES AS TES, BM_GRUPO AS GRUPO , BM_TIPGRU AS FAMILIA, SUBSTRING(F1_DTDIGIT,1,6) AS DT "
		cQRD2 += " , SUM(D1_QUANT) AS TOTAL, SUM(D1_TOTAL) AS VALOR FROM SF1020 SF1 "
/*	ElseIf mv_par05 = 3
		cQRD2 := " SELECT F1_FORNECE AS FORNEC, F1_LOJA AS LOJA, D1_DOC AS NOTA, D1_SERIE AS SERIE, D1_TES AS TES, BM_GRUPO AS GRUPO , BM_TIPGRU AS FAMILIA, SUBSTRING(F1_DTDIGIT,1,6) AS DT "
		cQRD2 += " ,(SUM(D1_TOTAL)/SUM(D1_QUANT)) AS TOTAL, (SUM(D1_TOTAL)/SUM(D1_QUANT)) AS VALOR FROM SF1020 SF1 "*/
	ElseIf mv_par05 = 3
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
	//	cQuery += " D1_TIPO = 'N' AND D2_NFORI = '' AND "
	//	cQuery += " F2_DOC BETWEEN '"+ mv_par01 +"' AND '"+ mv_par02+"' AND "
	cQRD2 += " BM_GRUPO BETWEEN '"+ mv_par03 +"' AND '"+ mv_par04+"' AND "
	cQRD2 += " F1_DTDIGIT BETWEEN '"+DTOS(_dDatade)+"' AND '"+ DTOS(mv_par06)+"' AND"
	cQRD2 += " D1_COD BETWEEN '"+ mv_par07 +"' AND '"+ mv_par08+"' AND "
	//	cQuery += " (D2_TES <> '731' AND D2_TES <> '526') AND "
	cQRD2 += " BM_TIPGRU <> '' AND "
	cQRD2 += " (F1_FORNECE <> '008360' AND F1_FORNECE <> '020793') "
	//	cQuery += " D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA NOT IN (SELECT  D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA FROM " + RetSqlName("SD1") + " SD1 WHERE SD1.D_E_L_E_T_ <> '*' )  "
	cQRD2 += " GROUP BY F1_FORNECE, F1_LOJA, D1_DOC, D1_SERIE, BM_GRUPO, BM_TIPGRU, SUBSTRING(F1_DTDIGIT,1,6),D1_TES "
	cQRD2 += " ORDER BY BM_TIPGRU, SUBSTRING(F1_DTDIGIT,1,6) "
	//
	cQRD2 := ChangeQuery(cQRD2)
	//
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQRD2),"QRD2",.F.,.T.)
	//
	DbSelectArea("QRD2")
	DbGoTop()
	//
	nRegs := 0
	//
	While QRD2->(!EOF())
		nRegs:= nRegs+1
		QRD2->(DbSkip())
	End
	//
	DbGoTop()
	//
	ProcRegua(nRegs)
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
			If AllTrim(QRD2->DT) = ""
				ApMsgStop(QRD2->FORNECE + '  ' + QRD2->LOJA + '  ' + QRD2->NOTA + '  ' + QRD2->SERIE + '  ' + QRD2->DT )
			EndIf
			QRD2->(DbSkip())
		Else
			DbSelectArea("QRD2")
			QRD2->(DbSkip())
		EndIf
		//
		IncProc("Entradas Empresa 2 "+Str(Recno(),6)+"/"+Str(nRegs,6))
		//
	End
	//
EndIf

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

_aMesExt := {'JAN', 'FEV', 'MAR','ABR', 'MAI', 'JUN','JUL', 'AGO', 'SET','OUT', 'NOV', 'DEZ'}
_nControl:= Month(mv_par06) - 5

For x:= _nControl to _nControl + 5
	//
	If x <= 0
		Cabec += _aMesExt[x+12] + Space(20)
		AADD(aCabec1,{_aMesExt[x+12]})
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

Cabec := "Família"+Space(45)+Cabec+"Total"

oObjPrint:SayBitmap( nLin, 020,"ourolux.bmp"   , 387, 157 ) //553 x 224
nLin += 190 //nLin = 250
oObjPrint:Box( nLBox ,0010, nLBox + 0070 , 0500 )//  Monta o Box Externo
oObjPrint:Box( nLBox ,0500, nLBox + 0070 , 0800 ) //  Monta o Box Externo
oObjPrint:Box( nLBox ,0800, nLBox + 0070 , 1100 ) //  Monta o Box Externo
oObjPrint:Box( nLBox ,1100, nLBox + 0070 , 1400 ) //  Monta o Box Externo
oObjPrint:Box( nLBox ,1400, nLBox + 0070 , 1700 ) //  Monta o Box Externo
oObjPrint:Box( nLBox ,1700, nLBox + 0070 , 2000 ) //  Monta o Box Externo
oObjPrint:Box( nLBox ,2000, nLBox + 0070 , 2300 ) //  Monta o Box Externo
oObjPrint:Box( nLBox ,2300, nLBox + 0070 , 2600 ) //  Monta o Box Externo
If mv_par05 = 1
	oObjPrint:Say(  nLin-0120 , 0900 ,  "Impressao Faturamento por Categoria X Valor Líquido"  , oFont7  , 100 )
ElseIf mv_par05 = 2
	oObjPrint:Say(  nLin-0120 , 0900 ,  "Impressao Faturamento por Categoria X Quantidade "    , oFont7  , 100 )
/*ElseIf mv_par05 = 3
	oObjPrint:Say(  nLin-0120 , 0900 ,  "Impressao Faturamento por Categoria X Média Vlr. Unitario "  , oFont7  , 100 )*/
ElseIf mv_par05 = 3
	oObjPrint:Say(  nLin-0120 , 0900 ,  "Impressao Faturamento por Categoria X Valor Bruto"  , oFont7  , 100 )
EndIf
oObjPrint:Say(  nLin , 0010 ,  Cabec  , oFont2  , 100 )
nLin += 0050
nLbox+= 0040

DbSelectArea("TRB")

index on TRB->FAMILIA+TRB->DT+TRB->NOTA+TRB->SERIE to &(cArqTrb+"1")
set index to &(cArqTrb+"1")
//
dbGoTop()
//
_cVerFamDt  := TRB->FAMILIA+TRB->DT
_Total 		:= 0
_vFamilia 	:= TRB->FAMILIA 		//ARMAZENA A FAMILIA
_Dt			:= TRB->DT
//
nLin+=0070
nLbox+= 0070
//
oObjPrint:Box( nLBox ,0010, nLBox + 0070 , 0500 ) //  Monta o Box Externo
oObjPrint:Box( nLBox ,0500, nLBox + 0070 , 0800 ) //  Monta o Box Externo
oObjPrint:Box( nLBox ,0800, nLBox + 0070 , 1100 ) //  Monta o Box Externo
oObjPrint:Box( nLBox ,1100, nLBox + 0070 , 1400 ) //  Monta o Box Externo
oObjPrint:Box( nLBox ,1400, nLBox + 0070 , 1700 ) //  Monta o Box Externo
oObjPrint:Box( nLBox ,1700, nLBox + 0070 , 2000 ) //  Monta o Box Externo
oObjPrint:Box( nLBox ,2000, nLBox + 0070 , 2300 ) //  Monta o Box Externo
oObjPrint:Box( nLBox ,2300, nLBox + 0070 , 2600 ) //  Monta o Box Externo

dbSelectArea("SX5")
dbSetOrder(1)
dbSeek(xFilial("SX5")+"V0"+TRB->FAMILIA)// PROCURA DESCRICAO DE ACORDO COM O TIPO DE GRUPO
//
If Found()
	xDescrg:=Alltrim(SX5->X5_DESCRI)
Else
	xDescrg:=""
Endif
//
If !EOF()
	oObjPrint:Say(  nLin , 0020 ,  Substr(xDescrg,1,23)   					 , oFont2  , 100 )
EndIf

DbSelectArea("TRB")

While TRB->(!EOF())
	//
	If TRB->TOTAL = 0 .Or. (TRB->CLIENTE == "008360" .Or.  TRB->CLIENTE == "020793") // Clientes Transferencia
		DbSkip()
		Loop
	EndIf
	//
	If _cVerFamDt == TRB->FAMILIA+TRB->DT
		_Total 		:= TRB->TOTAL+_Total 	//ACUMULA O TOTAL POR FAMILIA+DATA
		_Dt			:= TRB->DT				//Armazena a Data
		_nTotal 	:= TRB->TOTAL + _nTotal // ACUMULA O TOTAL POR FAMILIA
		_nTotalGer 	:= TRB->TOTAL + _nTotalGer // ACUMULA O TOTAL Geral		
		DbSkip()
		Loop
	Else
		//
		If _cVerFamDt <> TRB->FAMILIA+TRB->DT
			//
			DbSelectArea("TRB")
			//
			For x:=1 to Len(aPos)
				//
				For z:=1 to Len(_aMesExt)
					//
					If _aMesExt[z] = aPos [x][1] .And. aPos[x][2] > nCol .And. z = VAL(SUBSTR(_Dt,5,2))
						//
						If mv_par05 <> 2
							oObjPrint:Say(  nLin , aPos [x][2] ,  Transform(_Total,"@E 99,999,999.99") , oFont2   , 100 )
                            //WKF
							AADD(aDados,{_vFamilia,_aMesExt[z],_Total})
							//Fim WKF
						Else
							oObjPrint:Say(  nLin , aPos [x][2] ,  Transform(_Total,"@E 99,999,999" ) , oFont2   , 100 ) 
							//WKF
							AADD(aDados,{_vFamilia,_aMesExt[z],_Total})
							//Fim WKF
						EndIf
						//ApMsgStop( 'Coluna : ' + Transform(nCol,"@E 9999") + ' Data: '+_Dt+' FAMILIA: '+TRB->FAMILIA+' Total: '+Transform(_Total,"@E 99,999,999")+' ','Atencao')
						_Total 		:= 0 	//ACUMULA O TOTAL POR FAMILIA+DATA
						_Dt			:= ""	//Armazena a Data
						nCol := aPos [x][2]
						//
					EndIf
					//
				Next z
				//
			Next x
			//
		EndIf
		//
		If _vFamilia <> TRB->FAMILIA  //Se forem de famílias diferentes
			//
			dbSelectArea("SX5")
			dbSetOrder(1)
			dbSeek(xFilial("SX5")+"V0"+TRB->FAMILIA)// PROCURA DESCRICAO DE ACORDO COM O TIPO DE GRUPO
			//
			If Found()
				xDescrg:=Alltrim(SX5->X5_DESCRI)
			Else
				xDescrg:=""
			Endif
			//
			nLin+=0070
			nLbox+= 0070
			//
			If _vFamilia <> TRB->FAMILIA
				//
				If mv_par05 <> 2
					oObjPrint:Say(  nLin-0070 , 2320 ,  Transform(_nTotal,"@E 99,999,999.99") , oFont2   , 100 )
                    //WKF
					AADD(aDados,{_vFamilia,"Total",_nTotal})
					//Fim WKF
				Else
					oObjPrint:Say(  nLin-0070 , 2320 ,  Transform(_nTotal,"@E 99,999,999 ") , oFont2   , 100 )
                    //WKF
					AADD(aDados,{_vFamilia,"Total",_nTotal})
					//Fim WKF
				EndIf
				_nTotal := 0
				//
			EndIf
			//
			oObjPrint:Box( nLBox ,0010, nLBox + 0070 , 0500 )//  Monta o Box Externo
			oObjPrint:Box( nLBox ,0500, nLBox + 0070 , 0800 ) //  Monta o Box Externo
			oObjPrint:Box( nLBox ,0800, nLBox + 0070 , 1100 ) //  Monta o Box Externo
			oObjPrint:Box( nLBox ,1100, nLBox + 0070 , 1400 ) //  Monta o Box Externo
			oObjPrint:Box( nLBox ,1400, nLBox + 0070 , 1700 ) //  Monta o Box Externo
			oObjPrint:Box( nLBox ,1700, nLBox + 0070 , 2000 ) //  Monta o Box Externo
			oObjPrint:Box( nLBox ,2000, nLBox + 0070 , 2300 ) //  Monta o Box Externo
			oObjPrint:Box( nLBox ,2300, nLBox + 0070 , 2600 ) //  Monta o Box Externo
			//
			If !EOF()
				oObjPrint:Say(  nLin , 0020 ,  Substr(xDescrg,1,23)   					 , oFont2  , 100 )
			EndIf
			//
			DbSelectArea("TRB")
			//
		EndIf
		//
		nCol := 0
		
		_nTotal 	:= TRB->TOTAL + _nTotal // ACUMULA O TOTAL POR FAMILIA
		_nTotalGer 	:= TRB->TOTAL + _nTotalGer // ACUMULA O TOTAL Geral		
		_Total 		:= TRB->TOTAL+_Total 	//ACUMULA O TOTAL POR FAMILIA+DATA
		_Dt			:= TRB->DT				//Armazena a Data
		_vFamilia 	:= TRB->FAMILIA
		
		TRB->(DbSkip())  // Próximmo Registro
		//
		_cVerFamDt 	:= TRB->FAMILIA+TRB->DT
		
		If _vFamilia <> TRB->Familia
			//
			dbSelectArea("SX5")
			dbSetOrder(1)
			dbSeek(xFilial("SX5")+"V0"+TRB->FAMILIA)// PROCURA DESCRICAO DE ACORDO COM O TIPO DE GRUPO
			//
			If Found()
				xDescrg:=Alltrim(SX5->X5_DESCRI)
			Else
				xDescrg:=""
			Endif
			//
			nLin += 0070
			nLbox+= 0070
			//
			oObjPrint:Box( nLBox ,0010, nLBox + 0070 , 0500 )//  Monta o Box Externo
			oObjPrint:Box( nLBox ,0500, nLBox + 0070 , 0800 ) //  Monta o Box Externo
			oObjPrint:Box( nLBox ,0800, nLBox + 0070 , 1100 ) //  Monta o Box Externo
			oObjPrint:Box( nLBox ,1100, nLBox + 0070 , 1400 ) //  Monta o Box Externo
			oObjPrint:Box( nLBox ,1400, nLBox + 0070 , 1700 ) //  Monta o Box Externo
			oObjPrint:Box( nLBox ,1700, nLBox + 0070 , 2000 ) //  Monta o Box Externo
			oObjPrint:Box( nLBox ,2000, nLBox + 0070 , 2300 ) //  Monta o Box Externo
			oObjPrint:Box( nLBox ,2300, nLBox + 0070 , 2600 ) //  Monta o Box Externo
			//
			If !EOF()
				oObjPrint:Say(  nLin , 0020 ,  Substr(xDescrg,1,23)   					 , oFont2  , 100 )
			EndIf
			//
			If mv_par05 <> 2
				oObjPrint:Say(  nLin-0070 , 2320 ,  Transform(_nTotal,"@E 99,999,999.99") , oFont2   , 100 )
                //WKF
				AADD(aDados,{_vFamilia,"Total",_nTotal})
				//Fim WKF
			Else
				oObjPrint:Say(  nLin-0070 , 2320 ,  Transform(_nTotal,"@E 99,999,999 ") , oFont2   , 100 )
                //WKF
				AADD(aDados,{_vFamilia,"Total",_nTotal})
				//Fim WKF
			EndIf
			_nTotal := 0
			//
			DbSelectArea("TRB")
			_lVerif := .T.
			//
		EndIf
 		_vFamilia := TRB->FAMILIA
		
	EndIf
	
Enddo

If EOF() 
	//
/*	If _lVerif 
		//
		nLin  := nLin+0070
		nLbox := nLbox+0070
		//
	EndIf */
		//
	For x:=1 to Len(aPos)
		//
		For z:=1 to Len(_aMesExt)
			//
			If _aMesExt[z] = aPos [x][1] .And. aPos[x][2] > nCol .And. z = VAL(SUBSTR(_Dt,5,2))
				//
				If mv_par05 <> 2
					oObjPrint:Say(  nLin , aPos [x][2] ,  Transform(_Total,"@E 99,999,999.99") , oFont2   , 100 )
                    //WKF
					AADD(aDados,{_vFamilia,_aMesExt[z],_Total})
					//Fim WKF
				Else
					oObjPrint:Say(  nLin , aPos [x][2] ,  Transform(_Total,"@E 99,999,999" ) , oFont2   , 100 )
                    //WKF
					AADD(aDados,{_vFamilia,_aMesExt[z],_Total})
					//Fim WKF
				EndIf
				_Total 		:= 0 	//ACUMULA O TOTAL POR FAMILIA+DATA
				_Dt			:= ""	//Armazena a Data
				nCol := aPos [x][2]
				//
			EndIf
			//
		Next z
		//
	Next x
	//
	If mv_par05 <> 2
		oObjPrint:Say(  nLin , 2320 ,  Transform(_nTotal,"@E 99,999,999.99") , oFont2   , 100 )
		AADD(aDados,{_vFamilia,"Total",_nTotal})
	Else
		oObjPrint:Say(  nLin , 2320 ,  Transform(_nTotal,"@E 99,999,999 ") , oFont2   , 100 )
		AADD(aDados,{_vFamilia,"Total",_nTotal})
	EndIf
	//
EndIf


//Imprime Totais / Mês
nLin    +=0070
nLbox   += 0070
nCol	:= 0
//oObjPrint:Box( nLBox ,0010, nLBox + 0070 , 0500 )//  Monta o Box Externo
oObjPrint:Box( nLBox ,0500, nLBox + 0070 , 0800 ) //  Monta o Box Externo
oObjPrint:Box( nLBox ,0800, nLBox + 0070 , 1100 ) //  Monta o Box Externo
oObjPrint:Box( nLBox ,1100, nLBox + 0070 , 1400 ) //  Monta o Box Externo
oObjPrint:Box( nLBox ,1400, nLBox + 0070 , 1700 ) //  Monta o Box Externo
oObjPrint:Box( nLBox ,1700, nLBox + 0070 , 2000 ) //  Monta o Box Externo
oObjPrint:Box( nLBox ,2000, nLBox + 0070 , 2300 ) //  Monta o Box Externo
oObjPrint:Box( nLBox ,2300, nLBox + 0070 , 2600 ) //  Monta o Box Externo

DbSelectArea("TRB")

index on TRB->DT to &(cArqTrb+"2")
set index to &(cArqTrb+"2")

DbGoTop()

_cDtCont := TRB->DT

While TRB->(!EOF())
	//
	If _cDtCont = TRB->DT
		_Total 		:= TRB->TOTAL+_Total 	//ACUMULA O TOTAL POR DATA
		DbSkip()
		Loop
	Else
		//
		DbSelectArea("TRB")
		//
		For x:=1 to Len(aPos)
			//
			For z:=1 to Len(_aMesExt)
				//
				If _aMesExt[z] = aPos [x][1] .And. aPos[x][2] > nCol .And. z = VAL(SUBSTR(_cDtCont,5,2))
					//
					If mv_par05 <> 2
						oObjPrint:Say(  nLin , aPos [x][2] ,  Transform(_Total,"@E 99,999,999.99") , oFont2   , 100 )
    	                //WKF
						AADD(aDados,{"TotFam",_aMesExt[z],_Total})
						//Fim WKF
					Else
						oObjPrint:Say(  nLin , aPos [x][2] ,  Transform(_Total,"@E 99,999,999" ) , oFont2   , 100 )
           		        //WKF
						AADD(aDados,{"TotFam",_aMesExt[z],_Total})
						//Fim WKF
					EndIf
					_Total 		:= TRB->TOTAL	//ACUMULA O TOTAL POR FAMILIA+DATA
					_Dt			:= ""	//Armazena a Data
					nCol := aPos [x][2]
					//
				EndIf
				//
			Next z
			//
		Next x
		//
	EndIf
	//
	TRB->(DbSkip())
	_cDtCont := TRB->DT
End

If EOF()
	//
	For x:=1 to Len(aPos)
		//
		For z:=1 to Len(_aMesExt)
			//
			If _aMesExt[z] = aPos [x][1] .And. aPos[x][2] > nCol .And. z = VAL(SUBSTR(_cDtCont,5,2))
				//
				If mv_par05 <> 2
					oObjPrint:Say(  nLin , aPos [x][2] ,  Transform(_Total,"@E 99,999,999.99") , oFont2   , 100 )
                    //WKF
					AADD(aDados,{"TotFam",_aMesExt[z],_Total})
					//Fim WKF
				Else
					oObjPrint:Say(  nLin , aPos [x][2] ,  Transform(_Total,"@E 99,999,999" ) , oFont2   , 100 )
                    //WKF
					AADD(aDados,{"TotFam",_aMesExt[z],_Total})
					//Fim WKF
				EndIf
				nCol := aPos [x][2]
				//
			EndIf
			//
		Next z
		//
	Next x
	//
EndIf

If mv_par05 <> 2
	oObjPrint:Say(  nLin , 2320 ,  Transform(_nTotalGer,"@E 99,999,999.99") , oFont2   , 100 )       
	//WKF
	AADD(aDados,{"TotGer","Total",_nTotalGer})
	//Fim WKF	
Else
	oObjPrint:Say(  nLin , 2320 ,  Transform(_nTotalGer,"@E 99,999,999 ") , oFont2   , 100 )
	//WKF
	AADD(aDados,{"TotGer","Total",_nTotalGer})
	//Fim WKF	
EndIf

//U_RFATSEM(mv_par05,aDados,aCabec1,_nTotalGer)

Return

Static Function ValidPerg(cPerg)

Local _aPerguntas := {}

cPerg        := PADR(cPerg,len(sx1->x1_grupo))

AAdd(_aPerguntas,{cPerg,"01","Da Nota    	?","","","mv_ch1","C",09,0,0 ,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","SF2","","",""})
AAdd(_aPerguntas,{cPerg,"02","Até Nota   	?","","","mv_ch2","C",09,0,0 ,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","SF2","","",""})
AAdd(_aPerguntas,{cPerg,"03","Do Grupo   	?","","","mv_ch3","C",04,0,0 ,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","SBM","","",""})
AAdd(_aPerguntas,{cPerg,"04","Até Grupo  	?","","","mv_ch4","C",04,0,0 ,"G","","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","","SBM","","",""})
AAdd(_aPerguntas,{cPerg,"05","Agrupar por	?","","","mv_ch5","N",01,4,1 ,"N","","mv_par05","Valor Liquido","","","","","Quantidade","","","","","Valor Bruto","","","","","","","","","","","","","","","","",""})
AAdd(_aPerguntas,{cPerg,"06","Database   	?","","","mv_ch6","D",08,0,0 ,"G","","mv_par06","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
AAdd(_aPerguntas,{cPerg,"07","Do Produto 	?","","","mv_ch7","C",15,0,0 ,"G","","mv_par07","","","","","","","","","","","","","","","","","","","","","","","","","SB1","","",""})
AAdd(_aPerguntas,{cPerg,"08","Ate Produto	?","","","mv_ch8","C",15,0,0 ,"G","","mv_par08","","","","","","","","","","","","","","","","","","","","","","","","","SB1","","",""})
AAdd(_aPerguntas,{cPerg,"09","Cons.Empresas	?","","","mv_ch9","N",01,4,1 ,"N","","mv_par09","Sim","","","","","Não","","","","","","","","","","","","","","","","","","","","","",""})
//AAdd(_aPerguntas,{cPerg,"09","Nota Fiscal ?","","","mv_ch9","C",09,0,0 ,"G","","mv_par09","","","","","","","","","","","","","","","","","","","","","","","","","SF2","","",""})
//AAdd(_aPerguntas,{cPerg,"10","Nota Fiscal ?","","","mv_cha","C",09,0,0 ,"G","","mv_par10","","","","","","","","","","","","","","","","","","","","","","","","","SF2","","",""})

DbSelectArea("SX1")

For _i:=1 to Len(_aPerguntas)
	If !DbSeek( cPerg + StrZero(_i,2) )
		RecLock("SX1",.t.)
		For _j:=1 to Len(_aPerguntas[_i])
			FieldPut(_j,_aPerguntas[_i,_j])
		Next
		MsUnLock()
	EndIf
Next

Return
