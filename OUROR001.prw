#INCLUDE "PROTHEUS.CH"
#INCLUDE "MATR282.CH"
#Include "Topconn.ch"
#Include "Tbiconn.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³MATR282	³ Autor ³ Microsiga S/A         ³ Data ³ 06/08/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Relatorio de conferencia de saldos em estoque para produtos³±±
±±³          ³ que controlam saldo por rastreabilidade/localizacao.       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
User Function OUROR001()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PREPARE ENVIRONMENT EMPRESA "01" FILIAL "01"

Private aReturn  := {STR0005,1,STR0006, 1, 2, 1, "",1 }	//"Zebrado"###"Administracao"
Private aLinha   := { }
Private nLastKey := 0
Private cPerg    :="MTR282"
Private aItens   := {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica as perguntas selecionadas                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros                         ³
//³ mv_par01  // Do  Produto ?                                   ³
//³ mv_par02  // Ate Produto ?                                   ³
//³ mv_par03  // Do Armazem ?                                    ³
//³ mv_par04  // Ate Armazem ?                                   ³
//³ mv_par05  // Saldo a Considerar ? 1 = Atual                  ³
//³                                   2 = Movimento              ³
//³                                   3 = Fechamento             ³
//³ mv_par06  // Data de Referencia ?                            ³
//³ mv_par07  // Lista Produtos ? 1 = Com Diferencas             |
//|                               2 = Sem Diferencas             |
//|                               3 = Ambos                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Pergunte("MTR282",.T.)

MV_PAR01 := "               "
MV_PAR02 := "ZZZZZZZZZZZZZZZ"
MV_PAR03 := "  "
MV_PAR04 := "ZZ"
MV_PAR05 := 1
MV_PAR06 := dDataBase
MV_PAR07 := 2

MTR282Imp()

Return NIL

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ MTR282Imp³ Autor ³ Microsiga S/A         ³ Data ³ 06/08/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Chamada do Relatorio                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ lEnd    - Controle de Execucao da rotina                   ³±±
±±³          ³ WnRel   - Nome arquivo a ser gerado na impressao           ³±±
±±³          ³ Tamanho - Tamanho do relatorio                             ³±±
±±³          ³ Titulo  - Titulo do relatorio                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATR282			                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function MTR282Imp()
Local cStatus    := ''
Local cQuery     := ''
Local nQtdSBK    := 0
Local nQtdSBJ    := 0
Local nQtdSDA    := 0
Local nQtdSB2    := 0
Local nX         := 0
Local lRastro    := .F.
Local lLocaliza  := .F.
Local aTamSB2    := {}
Local aNewSBK    := {}
Local aNewSBJ    := {}
Local aResult    := {}
Local cAliasSB2  := {}
Local cAliasSB8  := 'SB8'
Local cAliasSBF  := 'SBF'
Local cAliasSDA  := 'SDA'
Local aAreaAnt   := GetArea()
Local aTamSBJ    := TamSX3("BJ_QINI")
Local aTamSBK    := TamSX3("BK_QINI")
Local aTamSB8    := TamSX3('B8_SALDO')
Local aTamSBF    := TamSX3('BF_QUANT')
Local aTamSDA    := TamSX3('DA_SALDO')
Local dUlMes     := GetMV("MV_ULMES")
Local cRastro    := SuperGetMv("MV_RASTRO",.F.,'N')
Local l300SalNeg := SuperGetMV("MV_MT300NG",.F.,.F.) // Indica se permite saldo negativo
Local cNomeTab   := "0_SP"
Local _cMailAprv := SuperGetMv("ES_CONFEST",.F.,"")
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica a existencia de Stored Procedures                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local lExistProc := ExistProc(GetSPName("MAT038","17"),VerIDProc()) .And. TCCanOpen( "TRJ"+SM0->M0_CODIGO+cNomeTab ).And. TCCanOpen( "TRK"+SM0->M0_CODIGO+cNomeTab )
Local lExProc36  := ExistProc(GetSPName("MAT036","17"),VerIDProc())
Local lExProc37  := ExistProc(GetSPName("MAT037","17"),VerIDProc())

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para Impressao do Cabecalho e Rodape    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE cbtxt := Space(10)
PRIVATE cbcont:= 0
PRIVATE li    := 80
PRIVATE m_pag := 01

PRIVATE cabec1  := STR0010 	
PRIVATE cabec2  := STR0011 	
	
    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Tratamento para utilizacao de Stored Procedures              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lExistProc
		// Realiza a limpeza na tabela temporaria TRJ
		TcSqlExec( "DELETE FROM "+"TRJ"+cEmpAnt+cNomeTab+" WHERE BJ_FILIAL = '"+xFilial("SBJ")+"' AND D_E_L_E_T_  = ' '")
		// Realiza a limpeza na tabela temporaria TRK
		TcSqlExec( "DELETE FROM "+"TRK"+cEmpAnt+cNomeTab+" WHERE BK_FILIAL = '"+xFilial("SBK")+"' AND D_E_L_E_T_  = ' '")
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Processamento do Relatorio                                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("SB2")
	dbSetOrder(1)
	cAliasSB2 := GetNextAlias()
	cQuery := "SELECT SB2.*,SB2.R_E_C_N_O_ RECNOSB2 "
	cQuery +=   "FROM " + RetSqlName("SB2")	+ " SB2 "
	cQuery +=  "WHERE SB2.B2_FILIAL = '"	+ xFilial('SB2')	+ "' AND "
	cQuery +=       " SB2.B2_COD >= '"		+ mv_par01		 	+ "' AND "
	cQuery +=       " SB2.B2_COD <= '"		+ mv_par02		 	+ "' AND "
	cQuery +=       " SB2.B2_LOCAL >= '"	+ mv_par03			+ "' AND "
	cQuery +=       " SB2.B2_LOCAL <= '"	+ mv_par04			+ "' AND "
	cQuery +=       " SB2.D_E_L_E_T_ = ' ' "
	cQuery:=ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),cAliasSB2,.F.,.T.)
	aTamSB2 := TamSX3("B2_QATU")
	TcSetField( cAliasSB2, "B2_QATU","N", aTamSB2[1],aTamSB2[2] )
	aTamSB2 := TamSX3("B2_QFIM")
	TcSetField( cAliasSB2, "B2_QFIM","N", aTamSB2[1],aTamSB2[2] )

	_cCodProc := "CONFSLD"
	_cHtmlMod := "\workflow\CONFSLD.htm"
	_cAssunt  := "CONFERENCIA DE SALDO EM ESTOQUE - " + DTOC(dDataBase)
	
	oProcess := TWFProcess():New( _cCodProc , _cAssunt )
	oProcess:NewTask( _cAssunt , _cHtmlMod )

	Do While !Eof()
		SB2->(MSGoto((cAliasSB2)->RECNOSB2))
			// Verificar se utiliza Rastro ou Localizacao
		lRastro   := Rastro((cAliasSB2)->B2_COD)
		lLocaliza := Localiza((cAliasSB2)->B2_COD)

	    // Processa somente se o produto possuir controle de endereco ou lote
		If !lLocaliza .And. !lRastro
			(cAliasSB2)->(dbSkip())
			Loop
		EndIf

		// Nao processar produto Mao-de-Obra
		If IsProdMod((cAliasSB2)->B2_COD)
			(cAliasSB2)->(dbSkip())
			Loop
		EndIf

		// Inicializa variaveis de controle
		cStatus := ''
		nQtdSB2 := 0
		nQtdSBK := 0
		nQtdSBJ := 0
		nQtdSDA := 0
		aNewSBK := {}
		aNewSBJ := {}

		// Impressao baseada no saldo atual
		If mv_par05 == 1
			nQtdSB2 :=  (cAliasSB2)->B2_QATU
			If lRastro
				dbSelectArea('SB8')
				dbSetOrder(3)
				cAliasSB8 := GetNextAlias()
				cQuery := "SELECT B8_SALDO "
				cQuery +=   "FROM " + RetSqlName("SB8") + " SB8 "
				cQuery +=  "WHERE SB8.B8_FILIAL = '"      + xFilial('SB8') 			+ "' AND "
				cQuery +=       " SB8.B8_PRODUTO = '"     + (cAliasSB2)->B2_COD		+ "' AND "
				cQuery +=       " SB8.B8_LOCAL = '"       + (cAliasSB2)->B2_LOCAL	+ "' AND "
				cQuery +=       " SB8.D_E_L_E_T_ = ' ' "
				cQuery:=ChangeQuery(cQuery)
				dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),cAliasSB8,.F.,.T.)
				TcSetField( cAliasSB8, "B8_SALDO","N", aTamSB8[1],aTamSB8[2] )
				dbSelectArea(cAliasSB8)
				Do While !Eof()
					nQtdSBJ += (cAliasSB8)->B8_SALDO
					dbSkip()
				EndDo
				dbSelectArea(cAliasSB8)
				dbCloseArea()
			EndIf
			If lLocaliza
				dbSelectArea('SBF')
				dbSetOrder(2)
				cAliasSBF := GetNextAlias()
				cQuery := "SELECT BF_QUANT "
				cQuery +=   "FROM " + RetSqlName("SBF") + " SBF "
				cQuery +=  "WHERE SBF.BF_FILIAL = '"      + xFilial('SBF') 			+ "' AND "
				cQuery +=       " SBF.BF_PRODUTO = '"     + (cAliasSB2)->B2_COD    + "' AND "
				cQuery +=       " SBF.BF_LOCAL = '"       + (cAliasSB2)->B2_LOCAL  + "' AND "
				cQuery +=       " SBF.D_E_L_E_T_ = ' ' "
				cQuery:=ChangeQuery(cQuery)
				dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),cAliasSBF,.F.,.T.)
				TcSetField( cAliasSBF, "BF_QUANT","N", aTamSBF[1],aTamSBF[2] )
				dbSelectArea(cAliasSBF)
				Do While !Eof()
					nQtdSBK += (cAliasSBF)->BF_QUANT
					dbSkip()
				EndDo
				dbSelectArea(cAliasSBF)
				dbCloseArea()

				dbSelectArea('SDA')
				dbSetOrder(1)
				cAliasSDA := GetNextAlias()
				cQuery := "SELECT DA_SALDO "
				cQuery +=   "FROM " + RetSqlName("SDA") + " SDA "
				cQuery +=  "WHERE SDA.DA_FILIAL = '"      + xFilial('SDA')			+ "' AND "
				cQuery +=       " SDA.DA_PRODUTO = '"     + (cAliasSB2)->B2_COD		+ "' AND "
				cQuery +=       " SDA.DA_LOCAL = '"       + (cAliasSB2)->B2_LOCAL	+ "' AND "
				cQuery +=       " SDA.D_E_L_E_T_ = ' ' "
				cQuery:=ChangeQuery(cQuery)
				dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),cAliasSDA,.F.,.T.)
				TcSetField( cAliasSDA, "DA_SALDO","N", aTamSDA[1],aTamSDA[2] )
				dbSelectArea(cAliasSDA)
				Do While !Eof()
					If QtdComp((cAliasSDA)->DA_SALDO) > QtdComp(0)
						nQtdSDA += (cAliasSDA)->DA_SALDO
					EndIf
					dbSkip()
				EndDo
				dbSelectArea(cAliasSDA)
				dbCloseArea()
			EndIf

		// Impressao baseada no saldo por movimento ou pelo saldo de fechamento
		ElseIf mv_par05 == 2 .Or. mv_par05 == 3
			// Analisa o tipo de saldos
			If mv_par05 == 2
				nQtdSB2 :=  CalcEst((cAliasSB2)->B2_COD,(cAliasSB2)->B2_LOCAL,mv_par06+1)[1]
			Else
				nQtdSB2 :=  (cAliasSB2)->B2_QFIM
			EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Processa saldo por Endereco (Utiliza SB2 Posicionada)        |
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			dbSelectArea(cAliasSB2)
			If lLocaliza
				If lExistProc .And. lExProc37
					MR282SP2(cFilAnt,DTOS(mv_par06),(cAliasSB2)->B2_COD,(cAliasSB2)->B2_LOCAL,DTOS(dUlMes),If( l300SalNeg, '1', '0' ),'1',@aResult,lRastro)
					// Realiza a abertura da tabela temporaria TRK
					cQuery := "SELECT SUM(BK_QINI) BK_QINI FROM TRK"+cEmpAnt+cNomeTab
					cQuery += " WHERE BK_FILIAL = '" + xFilial("SBK")			+ "' AND "
					cQuery +=       " BK_COD    = '" + (cAliasSB2)->B2_COD		+ "' AND "
					cQuery +=       " BK_LOCAL  = '" + (cAliasSB2)->B2_LOCAL	+ "' AND "
					cQuery +=       " D_E_L_E_T_ = ' ' "
					cQuery := ChangeQuery(cQuery)
					dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), "TRK", .F., .T.)
					TcSetField( "TRK", "BK_QINI","N", aTamSBK[1],aTamSBK[2] )
					Do While !TRK->(Eof())
						nQtdSBK += TRK->BK_QINI
						dbSkip()
					EndDo
					TRK->(dbCloseArea())
				Else
					MsGoto((cAliasSB2)->RECNOSB2)
					nQtdSBK:=BKAtuComB2(mv_par06, .F., Nil, .T., @aNewSBK)
					If Len(aNewSBK)>0
						nQtdSBK:=0
						For nX := 1 to Len(aNewSBK)
							nQtdSBK += aNewSBK[nX,9]
						Next nX
					EndIf
				EndIf
				nQtdSDA := MR282SDA((cAliasSB2)->B2_COD,(cAliasSB2)->B2_LOCAL,mv_par06,dUlMes)
			EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Processa saldo por Lote/SubLote (Utiliza SB2 Posicionada)    |
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			dbSelectArea('SB2')
			If lRastro
				If lExistProc .And. lExProc36
					MR282SP1(cFilAnt,DTOS(mv_par06),(cAliasSB2)->B2_COD,(cAliasSB2)->B2_LOCAL,cRastro,DTOS(dUlMes),If( l300SalNeg, '1', '0' ),'1',@aResult)
					// Realiza a abertura da tabela temporaria TRJ
					cQuery := "SELECT SUM(BJ_QINI) BJ_QINI FROM TRJ"+cEmpAnt+cNomeTab
					cQuery += " WHERE BJ_FILIAL = '" + xFilial("SBJ")			+ "' AND "
					cQuery +=       " BJ_COD    = '" + (cAliasSB2)->B2_COD		+ "' AND "
					cQuery +=       " BJ_LOCAL  = '" + (cAliasSB2)->B2_LOCAL	+ "' AND "
					cQuery +=       " D_E_L_E_T_ = ' ' "
					cQuery := ChangeQuery(cQuery)
					dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), "TRJ", .F., .T.)
					TcSetField( "TRJ", "BJ_QINI","N", aTamSBJ[1],aTamSBJ[2] )
					Do While !TRJ->(Eof())
						nQtdSBJ += TRJ->BJ_QINI
						dbSkip()
					EndDo
					TRJ->(dbCloseArea())
				Else
					MsGoto((cAliasSB2)->RECNOSB2)
					nQtdSBJ:=BJAtuComB2(mv_par06, .F., Nil, .T., @aNewSBJ)
					If Len(aNewSBJ)>0
						nQtdSBJ:=0
						For nX := 1 to Len(aNewSBJ)
							nQtdSBJ += aNewSBJ[nX,7]
						Next nX
					EndIf
				EndIf
		    EndIf
		EndIf

		// Verifica o Status da Conferencia de Saldos
		If lLocaliza .And. lRastro
			If QtdComp(nQtdSB2)==QtdComp(nQtdSBK) .And. QtdComp(nQtdSB2)==QtdComp(nQtdSBJ) .And. QtdComp(nQtdSDA)==QtdComp(0)
				cStatus := 'OK'
			ElseIf QtdComp(nQtdSDA) > QtdComp(0)
				cStatus := STR0017 //'SDA=PENDENTE'
			ElseIf QtdComp(nQtdSB2)<>QtdComp(nQtdSBK) .And. QtdComp(nQtdSB2)<>QtdComp(nQtdSBJ)
				cStatus := 'SB2xSBFxSB8'
			ElseIf QtdComp(nQtdSB2)<>QtdComp(nQtdSBK)
				cStatus := 'SB2xSBF'
			ElseIf QtdComp(nQtdSB2)<>QtdComp(nQtdSBJ)
				cStatus := 'SB2xSB8'
			EndIf
		ElseIf lLocaliza
			If QtdComp(nQtdSB2)==QtdComp(nQtdSBK) .And. QtdComp(nQtdSDA)==QtdComp(0)
				cStatus := 'OK'
			ElseIf QtdComp(nQtdSDA) > 0
				cStatus := STR0017 //'SDA=PENDENTE'
			Else
				cStatus := 'SB2xSBF'
			EndIf
		ElseIf lRastro
			If nQtdSB2 == nQtdSBJ
				cStatus := 'OK'
			Else
				cStatus := 'SB2xSB8'
			EndIf
		EndIf

		If (mv_par07 == 1 .And. cStatus == 'OK') .Or.;
		   (mv_par07 == 2 .And. cStatus <> 'OK') .Or.;
		    mv_par07 == 3

			// Posiciona na tabela SB1
			dbSelectArea('SB1')
			dbSetOrder(1)
			dbSeek(xFilial('SB1')+(cAliasSB2)->B2_COD)
			
			AADD(oProcess:oHtml:ValByName("it.filial")   	, (cAliasSB2)->B2_FILIAL)                             	// Item Cotacao
			AADD(oProcess:oHtml:ValByName("it.produto") 	, (cAliasSB2)->B2_COD)                          	// Cod Produto
			AADD(oProcess:oHtml:ValByName("it.armazem")  	, (cAliasSB2)->B2_LOCAL)                           	// Descricao Produto
			AADD(oProcess:oHtml:ValByName("it.contend")     , IIf(RetFldProd(SB1->B1_COD,"B1_LOCALIZ")=='S',"SIM","NAO"))                               	// Unidade Medida
			AADD(oProcess:oHtml:ValByName("it.contlote")   	, IIf(SB1->B1_RASTRO=='L',"LOTE",IIf(SB1->B1_RASTRO=='S',"SUBLOTE","NAO"))) // Quantidade Solicitada
			AADD(oProcess:oHtml:ValByName("it.qtdfis")  	, nQtdSB2)                     	// Data da Necessidade
			AADD(oProcess:oHtml:ValByName("it.qtdend")  	, nQtdSBK)                     	// Data Limite
			AADD(oProcess:oHtml:ValByName("it.qtdreca")     , nQtdSDA)                              	// Observacao
			AADD(oProcess:oHtml:ValByName("it.qtdlote")     , nQtdSBJ)                               	// Centro de Custo
			AADD(oProcess:oHtml:ValByName("it.status")      , cStatus)                               	// Centro de Custo
			
			Li++
		EndIf
		dbSelectArea(cAliasSB2)
		dbSkip()
	EndDo

	oProcess:cSubject := _cAssunt
	oProcess:cTo := _cMailAprv
	oProcess:Start()

	(cAliasSB2)->(dbCloseArea())

RestArea(aAreaAnt)

RESET ENVIRONMENT
Return NIL

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³MR282SP1    ³ Autor ³ Microsiga S/A         ³ Data ³14/09/09³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Processa a stored procedure MAT036 referente ao saldo por  ³±±
±±³          ³ lote/sublote a ser gerado no fechamento (SBJ)              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cCodFil    - Codigo da Filial                               ³±±
±±³          ³cDataFec   - Data do proximo Fechamento                     ³±±
±±³          ³cProduto   - Codigo do Produto                              ³±±
±±³          ³cLocal     - Codigo do Armazem                              ³±±
±±³          ³cRastro    - Conteudo do parametro MV_RASTRO                ³±±
±±³          ³cUlMes     - Data do parametro MV_ULMES                     ³±±
±±³          ³c300SalNeg - Considera saldo negativo                       ³±±
±±³          ³cConsulta  - Indica se executa a procedure de consulta      ³±±
±±³          ³aResult    - Array utilizado para o retorno da procedures   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATR282                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function MR282SP1(cCodFil,cDataFec,cProduto,cLocal,cRastro,cUlMes,c300SalNeg,cConsulta,aResult)
Local cSPMAT036 := GetSPName("MAT036","17")
Local lWmsNew   := SuperGetMV("MV_WMSNEW",.F.,.F.)
Local cMensagem
Local cMsgError

aResult:= TCSPEXEC( xProcedures( cSPMAT036 ),cCodFil,cDataFec,cProduto,cLocal,cRastro,cUlMes,c300SalNeg,0,0,cConsulta,A330FilNum(cCodFil),If(lWmsNew,'1','0') )

If Empty(aResult)
	cMsgError := TCSqlError()
	cMensagem := I18N(STR0028,{"MAT036","17"}) // "Procedure #1[MAT036]# Processo #2[17]#"
EndIf
Return aResult

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³MR282SP2    ³ Autor ³ Microsiga S/A         ³ Data ³14/09/09³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Processa a stored procedure MAT037 referente ao saldo por  ³±±
±±³          ³ endereco a ser gerado no fechamento (SBK)                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cCodFil    - Codigo da Filial                               ³±±
±±³          ³cDataFec   - Data do proximo Fechamento                     ³±±
±±³          ³cProduto   - Codigo do Produto                              ³±±
±±³          ³cLocal     - Codigo do Armazem                              ³±±
±±³          ³cUlMes     - Data do parametro MV_ULMES                     ³±±
±±³          ³c300SalNeg - Considera saldo negativo                       ³±±
±±³          ³cConsulta  - Indica se executa a procedure de consulta      ³±±
±±³          ³aResult    - Array utilizado para o retorno da procedures   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATR282                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function MR282SP2(cCodFil,cDataFec,cProduto,cLocal,cUlMes,c300SalNeg,cConsulta,aResult,lRastro)
Local cSPMAT037 := GetSPName("MAT037","17")
Local lWmsNew   := SuperGetMV("MV_WMSNEW",.F.,.F.)
Local cArqProd   := SuperGetMv("MV_ARQPROD",.F.,.F.)
Local cMsgError
Local cMensagem

Default lRastro := .F.

aResult:= TCSPEXEC( xProcedures(cSPMAT037),cCodFil,cDataFec,cProduto,cLocal,cUlMes,c300SalNeg,0,cConsulta,A330FilNum(cCodFil),If(lWmsNew,'1','0'),cArqProd,If(lRastro,'1','0'))

If Empty(aResult)
	cMsgError := TCSqlError()
	cMensagem := I18N(STR0028,{"MAT037","17"}) // "Procedure #1[MAT036]# Processo #2[17]#"
EndIf

Return aResult

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³VerIDProc ³ Autor ³ Microsiga S/A         ³ Data ³19/09/2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Identifica a sequencia de controle do fonte ADVPL com a     ³±±
±±³          ³stored procedure, qualquer alteracao que envolva diretamente³±±
±±³          ³a stored procedure a variavel sera incrementada.            ³±±
±±³          ³Procedure MAT038                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function VerIDProc()
Return STATICCALL(MATA280,VERIDPROC)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³MR282SDA  ³ Autor ³ Microsiga S/A         ³ Data ³15/09/2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Identifica a sequencia de controle do fonte ADVPL com a     ³±±
±±³          ³stored procedure, qualquer alteracao que envolva diretamente³±±
±±³          ³a stored procedure a variavel sera incrementada.            ³±±
±±³          ³Procedure MAT038                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cProduto - Codigo do Produto                                ³±±
±±³          ³cLocal   - Codigo do Armazem                                ³±±
±±³          ³cDtFech  - Data do proximo fechamento de estoque            ³±±
±±³          ³cUlMes   - Data do parametro MV_ULMES                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MR282SDA(cProduto,cLocal,cDtFech,dUlMes)
Local aAreaAnt  := GetArea()
Local nQuantSDA := 0
Local cAliasSDA := ''
Local cAliasSDB := ''
Local cQuery    := ''
Local aTamSDA   := TamSX3("DA_SALDO")
Local aTamSDB   := TamSX3("DB_QUANT")

//-- Query responsável por retornar o saldo a endereçar em aberto
cAliasSDA := GetNextAlias()
cQuery := "SELECT SUM(DA_SALDO) DA_SALDO "
cQuery += "FROM " + RetSqlName("SDA") + " SDA "
cQuery += "WHERE SDA.DA_FILIAL = '"      + xFilial('SDA') + "' AND "
cQuery +=      " SDA.DA_PRODUTO = '"     + cProduto       + "' AND "
cQuery +=      " SDA.DA_LOCAL = '"       + cLocal         + "' AND "
cQuery +=      " SDA.DA_DATA <= '"       + DTOS(cDtFech)  + "' AND "
cQuery +=      " SDA.DA_SALDO > 0 AND "
cQuery +=      " SDA.D_E_L_E_T_ = ' ' "
cQuery:=ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),cAliasSDA,.F.,.T.)
TcSetField( cAliasSDA, "DA_SALDO","N", aTamSDA[1],aTamSDA[2] )

dbSelectArea(cAliasSDA)
If (cAliasSDA)->(!Eof())
	nQuantSDA := (cAliasSDA)->DA_SALDO
EndIf

(cAliasSDA)->(dbCloseArea())

//-- Query responsável por retornar o saldo endereçado após o período informado
cAliasSDB := GetNextAlias()
cQuery := "SELECT SUM(DB_QUANT) DB_QUANT "
cQuery += "FROM " + RetSqlName("SDB") + " SDB "
cQuery += "INNER JOIN " + RetSqlName("SDA") + " SDA ON "
cQuery += 		"SDA.DA_FILIAL = '" + xFilial('SDA') + "' AND "
cQuery += 		"SDA.DA_PRODUTO =   SDB.DB_PRODUTO AND "
cQuery += 		"SDA.DA_LOCAL =     SDB.DB_LOCAL AND "
cQuery += 		"SDA.DA_DATA <= '"  + DTOS(cDtFech) + "' AND "
cQuery += 		"SDA.DA_NUMSEQ =    SDB.DB_NUMSEQ AND "
cQuery += 		"SDA.D_E_L_E_T_ = ' '"
cQuery += "WHERE SDB.DB_FILIAL = '"  + xFilial('SDB') + "' AND "
cQuery +=       "SDB.DB_PRODUTO = '" + cProduto + "' AND "
cQuery +=       "SDB.DB_LOCAL = '"   + cLocal + "' AND "
cQuery +=       "SDB.DB_DATA > '"    + DTOS(cDtFech) + "' AND "
cQuery +=       "SDB.DB_ESTORNO = ' ' AND "
cQuery +=       "SDB.D_E_L_E_T_ = ' ' "
cQuery:=ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),cAliasSDB,.F.,.T.)
TcSetField( cAliasSDB, "DB_QUANT","N", aTamSDB[1],aTamSDB[2] )

dbSelectArea(cAliasSDB)
If (cAliasSDB)->(!Eof())
	nQuantSDA += (cAliasSDB)->DB_QUANT
EndIf

(cAliasSDB)->(dbCloseArea())
RestArea(aAreaAnt)
Return nQuantSDA
