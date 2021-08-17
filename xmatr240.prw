#INCLUDE "XMATR240.CH"
#INCLUDE "PROTHEUS.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ XMATR240  ³ Autor ³ Ricardo Berti		³ Data ³10/07/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Saldos em Estoques                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function XMATR240()

Local oReport

If FindFunction("TRepInUse") .And. TRepInUse()
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Interface de impressao                                                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oReport:= ReportDef()
	oReport:PrintDialog()
Else
	U_MATR240R3()
EndIf                             

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ReportDef ³ Autor ³ Ricardo Berti		    ³ Data ³10/07/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³A funcao estatica ReportDef devera ser criada para todos os ³±±
±±³          ³relatorios que poderao ser agendados pelo usuario.          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Objeto Report do Relatorio                          		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ XMATR240			                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function ReportDef()

Local cAliasTOP	:= "SB1"
Local cAliasSB2	:= "SB2"
Local cAliasSB5	:= "SB5"
Local aOrdem    := {OemToAnsi(STR0004),OemToAnsi(STR0005),OemToAnsi(STR0006),OemToAnsi(STR0007)} // ' Por Codigo         '###' Por Tipo           '###' Por Descricao    '###' Por Grupo        '
Local aSB1Cod	:= TAMSX3("B1_COD")
Local aSB1Ite	:= TAMSX3("B1_CODITE")
Local lVEIC		:= UPPER(GETMV("MV_VEICULO"))=="S"
Local cPict		:= ''

Local oSection

Local aSizeQT	:= TamSX3("B2_QATU")
Local aSizeQTF  := TamSX3("B2_QFIM")
Local aSizeVL	:= TamSX3("B2_VATU1")
Local aSizeLZ   := TamSX3("B2_LOCALIZ")
Local cPictQT   := PesqPict("SB2","B2_QATU")
Local cPictVL   := PesqPict("SB2","B2_VATU1")
Local cPictLZ   := PesqPict("SB2","B2_LOCALIZ")
Local cPerg		:= "XMTR240"


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Criacao do componente de impressao                                      ³
//³                                                                        ³
//³TReport():New                                                           ³
//³ExpC1 : Nome do relatorio                                               ³
//³ExpC2 : Titulo                                                          ³
//³ExpC3 : Pergunte                                                        ³
//³ExpB4 : Bloco de codigo que sera executado na confirmacao da impressao  ³
//³ExpC5 : Descricao                                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oReport:= TReport():New("XMATR240",STR0001,cPerg, {|oReport| ReportPrint(oReport,@cAliasTOP,@cAliasSB2,lVeic,aOrdem,@cAliasSB5)},STR0002+" "+STR0003) //'Saldos em Estoque'##"Este programa ira' emitir um resumo dos saldos, em quantidade,"##'dos produtos em estoque.'
oReport:SetPortrait() //Define a orientacao default de pagina do relatorio como retrato.

AjustaSX1(cPerg)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica as perguntas selecionadas                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros                                  ³
//³ mv_par01     // Aglutina por: Almoxarifado / Filial / Empresa         ³
//³ mv_par02     // Filial de                                             ³
//³ mv_par03     // Filial ate                                            ³
//³ mv_par04     // Almoxarifado de                                       ³
//³ mv_par05     // Almoxarifado ate                                      ³
//³ mv_par06     // Produto de                                            ³
//³ mv_par07     // Produto ate                                           ³
//³ mv_par08     // tipo de                                               ³
//³ mv_par09     // tipo ate                                              ³
//³ mv_par10     // grupo de                                              ³
//³ mv_par11     // grupo ate                                             ³
//³ mv_par12     // descricao de                                          ³
//³ mv_par13     // descricao ate                                         ³
//³ mv_par14     // imprime qtde zeradas                                  ³
//³ mv_par15     // Saldo a considerar : Atual / Fechamento / Movimento   ³
//³ mv_par16     // Lista Somente Saldos Negativos                 		  ³
//³ mv_par17     // Descricao Produto : Cientifica / Generica      		  ³
//³ mv_par18   	 // QTDE. na 2a. U.M. ?     (Sim/Nao)                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Pergunte(oReport:uParam,.F.)

If ( cPaisLoc=="CHI" )
	cPict   := "@E 999,999,999.99"
Else
	cPict	:= PesqPictQt(If(mv_par15==1,'B2_QATU','B2_QFIM'),If(mv_par15==1, aSizeQT[1], aSizeQTF[1]))
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Criacao da Secao 1                                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oSection := TRSection():New(oReport,STR0001,{"SB1","SB2"},aOrdem) //'Saldos em Estoque'
oSection:SetHeaderPage()
oSection:SetTotalInLine(.F.)

// oSection:SetReadOnly() // Alterado por Claudino 11/05/2012, Desabilita a edicao das celulas permitindo filtro.

TRCell():New(oSection,'B1_CODITE'	,'SB1')
TRCell():New(oSection,'B2_COD'		,'SB2',/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection,'B1_TIPO'		,'SB1')
TRCell():New(oSection,'B1_GRUPO'	,'SB1')
#IFDEF TOP
	TRCell():New(oSection,'B1_DESC'		,'SB1',,,30,,{ || If(mv_par17 == 1 .And. !Empty((cAliasSB5)->B5_CEME),(cAliasSB5)->B5_CEME,(cAliasTOP)->B1_DESC) })
#ELSE
	TRCell():New(oSection,'B1_DESC'		,'SB1',,,30)
#ENDIF
TRCell():New(oSection,'B1_UM'		,'SB1')
TRCell():New(oSection,'B2_FILIAL'	,'SB2')
TRCell():New(oSection,'B2_LOCAL'	,'SB2')
TRCell():New(oSection,'QUANT'		,'SB2')
oSection:Cell("QUANT"):GetFieldInfo(If(mv_par15==1,'B2_QATU','B2_QFIM'))
oSection:Cell("QUANT"):SetTitle(STR0022) //"Qtde.1a.U.M."
oSection:Cell("QUANT"):SetPicture(cPict)
TRCell():New(oSection,'B1_SEGUM'	,'SB1')
TRCell():New(oSection,'QUANT2'		,'SB2')
oSection:Cell("QUANT2"):GetFieldInfo('B2_QTSEGUM')
oSection:Cell("QUANT2"):SetTitle(STR0023) //"Qtde.2a.U.M."
oSection:Cell("QUANT2"):SetPicture(cPict)
TRCell():New(oSection,'DISPON'		,'',Left(STR0018,1)+'/'+Left(STR0019,1),,,,{ || Left( If(SubStr((cAliasSB2)->B2_STATUS,1,1)$"2",STR0019,STR0018) ,1) }) //"Disponivel   "##"Indisponivel"
TRCell():New(oSection,'B2_LOCALIZ'	,"SB2")

Return(oReport)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ReportPrint ³ Autor ³ Ricardo Berti	    ³ Data ³10/07/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³A funcao estatica ReportPrint devera ser criada para todos  ³±±
±±³          ³os relatorios que poderao ser agendados pelo usuario.       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpO1: Objeto Report do Relatorio                           ³±±
±±³          ³ExpC1: Alias do arquivo principal							  ³±±
±±³          ³ExpC2: Alias do arquivo SB2								  ³±±
±±³          ³ExpL1: indica utilizacao de SIGAVEI, SIGAPEC e SIGAOFI	  ³±±
±±³          ³ExpA1: Array das ordens do relatorio						  ³±±
±±³          ³ExpC3: Alias do arquivo SB5								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ XMATR240			                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function ReportPrint(oReport,cAliasTOP,cAliasSB2,lVeic,aOrdem,cAliasSB5)

Local oSection   := oReport:Section(1)
Local nOrdem     := oSection:GetOrder()
Local aRegs      := {}
Local lRet       := .T.
Local oTotaliz
Local oBreak

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis locais exclusivas deste programa                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local nSoma      := nSoma2    := 0
Local nTotSoma   := nTotSoma2 := 0
Local nX         := 0
Local nRegM0     := 0
Local nIndB1     := 0
Local nIndB2     := 0
Local nQtdProd   := 0
Local aSalProd   := {}
Local cFilialDe  := ''
Local cQuebra1   := ''
Local cCampo     := ''
Local cMens      := ''
Local aProd      := {}
Local aProd1     := {}
Local aArea
Local cFilOld    := 'úú'
Local cCodAnt    := 'úú'
Local cDesc
Local lIsCient
Local nQtdBlq    := nQtdBlq2 := 0
Local nQuant     := 0.00
Local nQuant2    := 0.00
Local aFiliais   := {}
Local cNomArqB2  := ''
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis Locais utilizadas na montagem das Querys           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
#IFDEF TOP
	Local cWhere	:= ""
	Local cSelect	:= ""
	Local cOrderBy  := ""
	Local cGroupBy  := ""
	Local cJoin		:= ""
#ELSE
	Local cCondicao
	Local cIndB2     := ''
	Local cIndB1     := ''
	Local cCond2     := ''
	Local cFiltroB2  := ''
	Local cQuebra2   := ''
	Local lImpr      :=.F.
#ENDIF

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ajustar variaveis LOCAIS para SIGAVEI, SIGAPEC e SIGAOFI     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local cCodite    := ''

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ajustar variaveis PRIVATE para SIGAVEI, SIGAPEC e SIGAOFI    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE XSB1			:= XFILIAL('SB1')
PRIVATE XSB2			:= XFILIAL('SB2')
PRIVATE XSB5			:= XFILIAL('SB5')

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Adiciona a ordem escolhida ao Titulo do relatorio          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oReport:SetTitle(oReport:Title()+" - ("+AllTrim(aOrdem[nOrdem])+")")
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Definicao da linha de SubTotal                               |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOrdem == 1 		//-- SubTotal por Codigo
	oBreak := TRBreak():New(oSection,oSection:Cell("B2_COD"),/*STR0014*/,.f.)				//"Total do Produto"
ElseIf nOrdem == 2 		//-- SubTotal por Tipo
	oBreak := TRBreak():New(oSection,oSection:Cell("B1_TIPO"),STR0016+" "+STR0011,.F.)	//"Total do "##"Tipo.........."
ElseIf nOrdem == 3 		//-- SubTotal por Descricao
	oBreak := TRBreak():New(oSection,oSection:Cell("B1_DESC"),/*STR0014*/,.f.)				//"Total do Produto"
ElseIf nOrdem == 4		//-- SubTotal por Grupo
	oBreak := TRBreak():New(oSection,oSection:Cell("B1_GRUPO"),STR0016+" "+STR0012,.F.)	//"Total do "##"Grupo........."
EndIf

If nOrdem == 1 .Or. nOrdem == 3  //-- SubTotal por Codigo ou Descricao

	// Subtotais do produto impressos em colunas: alguns totalizadores imprimirao os titulos a esquerda (porque ha' 3 linhas de totais)
	oTotaliz := TRFunction():New(oSection:Cell('QUANT'),"DISP1"/*cID*/,"SUM",oBreak,"(" + Substr(STR0018,1,1)+ ") = " + STR0017 + STR0018/*Titulo*/,/*cPicture*/, /*uFormula*/,.F.,.F./*lEndPage*/,/*Obj*/) //"Qtde. "##"Disponivel   "
	oTotaliz:SetCondition({ || SubStr((cAliasSB2)->B2_STATUS,1,1)<>"2"})

	If mv_par18 == 1 // 2a.U.M.
		oTotaliz := TRFunction():New(oSection:Cell('QUANT2'),"DISP2","SUM",oBreak,"(" + Substr(STR0018,1,1)+ ") = " + STR0017 + STR0018 /* + ' 2a.U.M.'Titulo*/,,,.F.,.F.,/*Obj*/) //"Qtde. "##"Disponivel   "
		oTotaliz:SetCondition({ || SubStr((cAliasSB2)->B2_STATUS,1,1)<>"2"})
	EndIf
	oTotaliz := TRFunction():New(oSection:Cell('QUANT'),"INDISP1","SUM",oBreak,"(" + SubStr(STR0019,1,1)+ ") = " + STR0017 + STR0019,,,.F.,.F.,/*Obj*/)		 //"Qtde. "##"Indisponivel "
	oTotaliz:SetCondition({ || SubStr((cAliasSB2)->B2_STATUS,1,1)$"2"})

	If mv_par18 == 1 // 2a.U.M.
		oTotaliz := TRFunction():New(oSection:Cell('QUANT2'),"INDISP2","SUM",oBreak,"(" + SubStr(STR0019,1,1)+ ") = " + STR0017 + STR0019 /*+ ' 2a.U.M.'Titulo*/,,,.F.,.F.,/*Obj*/) //"Qtde. "##"Indisponivel "
		oTotaliz:SetCondition({ || SubStr((cAliasSB2)->B2_STATUS,1,1)$"2"})
	EndIf

EndIf

oTotaliz := TRFunction():New(oSection:Cell('QUANT'),"QT1","SUM",oBreak,If(Alltrim(Str(nOrdem)) $ "1|3",STR0014,),,,.F.,.F.,/*Obj*/) 	//"Total do Produto"
If mv_par18 == 1
	oTotaliz := TRFunction():New(oSection:Cell('QUANT2'),"QT2","SUM",oBreak,,,,.F.,.F.,/*Obj*/)
EndIf

//-- Alimenta Array com Filiais a serem Pesquisadas
aFiliais := {}
nRegM0   := SM0->(Recno())
SM0->(DBSeek(cEmpAnt, .T.))
Do While !SM0->(Eof()) .And. SM0->M0_CODIGO == cEmpAnt
	If SM0->M0_CODFIL >= mv_par02 .And. SM0->M0_CODFIL <= mv_par03
		aAdd(aFiliais, SM0->M0_CODFIL)
	EndIf
	SM0->(dbSkip())
EndDo
SM0->(dbGoto(nRegM0))

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³	Visualizacao de colunas conforme parametrizacao				  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If mv_par18 == 2
	oSection:Cell('B1_SEGUM'):Disable()
	oSection:Cell('QUANT2'):Disable()
EndIf	
If ! lVeic
	oSection:Cell('B1_CODITE'):Disable()
EndIf

#IFDEF TOP

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Transforma parametros Range em expressao SQL                            ³	
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	MakeSqlExpr(oReport:uParam)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Clausula LEFT JOIN p/ Descr.Cientifica (SB5)                           |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cJoin := "%"
	cJoin += "   JOIN " + RetSqlName("SB1") + " SB1 ON "
	If xSB1 # Space(2) .AND. xSB2 # Space(2)
		cJoin += "  SB1.B1_FILIAL =  SB2.B2_FILIAL AND "
	EndIf
	If !Empty(xSB1)
		cJoin += " SB1.B1_FILIAL >= '" + mv_par02 + "' AND "
		cJoin += " SB1.B1_FILIAL <= '" + mv_par03 + "' AND "
	EndIf	
	cJoin += " SB1.B1_COD    = SB2.B2_COD AND "
	cJoin += " SB1.B1_TIPO  >= '" + mv_par08 + "' AND "
	cJoin += " SB1.B1_TIPO  <= '" + mv_par09 + "' AND "
	cJoin += " SB1.B1_GRUPO >= '" + mv_par10 + "' AND "
	cJoin += " SB1.B1_GRUPO <= '" + mv_par11 + "' AND "
	cJoin += " SB1.B1_DESC  >= '" + mv_par12 + "' AND "
	cJoin += " SB1.B1_DESC  <= '" + mv_par13 + "' AND "
	cJoin += " SB1.D_E_L_E_T_ = ' ' "
	If mv_par17 == 1
		cJoin += " LEFT JOIN " + RetSqlName("SB5") + " SB5 "
		cJoin += "     ON  SB5.B5_FILIAL = '" + xFilial("SB5") + "' "
		cJoin += "     AND SB5.B5_COD    = SB1.B1_COD "
		cJoin += "     AND SB5.D_E_L_E_T_ = ' ' "
	EndIf	
	cJoin += "%"
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Filtro adicional no clausula Where                                     |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	cSelect := "%"
	If mv_par18 == 1	//-- 2a.U.M.
		cSelect += ", SB1.B1_SEGUM SEGUM"
	EndIf
	If lVeic
		cSelect += ", SB1.B1_CODITE CODITE"
	EndIf
	If mv_par01 == 1 //-- Aglutina por Armazem
		cSelect += ", SB2.B2_LOCAL LOC, SB2.B2_FILIAL FILIAL"
	Else  //-- Aglutina por Filial ou por Empresa
		cSelect += ", '**' LOC"
	EndIf	
	If  mv_par01 == 2 //-- Aglutina por Filial
		cSelect += ", SB2.B2_FILIAL FILIAL"
	EndIf 	
	If mv_par01 == 3  //-- Aglutina por Empresa
		cSelect += ", '**' FILIAL"
	EndIf
	If mv_par17 == 1 // Desc. Cientifica
		cSelect += ", SB5.B5_CEME"
	EndIf
	cSelect += "%"

	cWhere += "%"
	If lVeic
		cWhere += " AND SB1.B1_CODITE >= '" + mv_par06 + "' AND SB1.B1_CODITE <='" + mv_par07 + "' "
	Else
		cWhere += " AND SB1.B1_COD >= '" + mv_par06 + "' AND SB1.B1_COD <='" + mv_par07 + "' "
	EndIf
	If mv_par16 == 1 .And. mv_par01 == 1//-- Somente Negativos
		If mv_par14 == 2 //-- Imprime Zerados
			If mv_par15 == 1 //-- Saldo Atual
				cWhere += " AND (SB2.B2_QATU < 0)"
			ElseIf mv_par15 == 2 //-- Saldo Final
				cWhere += " AND (SB2.B2_QFIM < 0)"
			EndIf
		Else //-- Nao Imprime Zerados
			If mv_par15== 1 //-- Saldo Atual
				cWhere += " AND (SB2.B2_QATU <= 0)"
			ElseIf mv_par15 == 2 //-- Saldo Final
				cWhere += " AND (SB2.B2_QFIM <= 0)"
			EndIf
		EndIf	
	ElseIf mv_par14 == 2 .And. mv_par01 == 1//-- Nao Imprime Zerados
		If mv_par15 == 1 //-- Saldo Atual
			cWhere += " AND (SB2.B2_QATU <> 0)"
		ElseIf mv_par15 == 2 //-- Saldo Final
			cWhere += " AND (SB2.B2_QFIM <> 0)"
		EndIf
	EndIf
	cWhere += "%"

	cGroupBy := "%"
	If ! lVEIC
		cGroupBy += " SB2.B2_COD, SB1.B1_TIPO, SB1.B1_GRUPO"
	Else	
		cGroupBy += " SB1.B1_CODITE, SB2.B2_COD, SB1.B1_TIPO, SB1.B1_GRUPO"
	EndIf
	cGroupBy += ", SB1.B1_DESC"
	cGroupBy += ", SB1.B1_UM"
	If mv_par18 == 1
		cGroupBy += ", SB1.B1_SEGUM"
	EndIf
	If mv_par01 == 1 //-- Aglutina por Armazem
		cGroupBy += ", SB2.B2_LOCAL, SB2.B2_FILIAL"
	EndIf
	If mv_par01 == 2 //-- Aglutina por Filial
		cGroupBy += ", SB2.B2_FILIAL"
	EndIf	
	If mv_par01 == 3 //-- Aglutina por Empresa
		cGroupBy += " "
	EndIf	
	cGroupBy += ", SB2.B2_STATUS"
	cGroupBy += ", SB2.R_E_C_N_O_, SB1.R_E_C_N_O_ "
	If mv_par17 == 1
		cGroupBy += ", SB5.B5_CEME "  // SQL requer
	EndIf
	cGroupBy += "%"

	cOrderBy := "%"
	If ! lVEIC
		If nOrdem == 4
			cOrderBy += " GRUPO, COD"   // Por Grupo, Codigo
			cCampo := 'B1_GRUPO'
			cMens  := OemToAnsi(STR0012) // 'Grupo.........'
		ElseIf nOrdem == 3
			cOrderBy += " B1_DESC, COD"   // Por Descricao, Codigo
			cCampo := .T.
		ElseIf nOrdem == 2
			cOrderBy += " TIPO, COD"   // Por Tipo, Codigo
			cCampo := 'B1_TIPO'
			cMens  := OemToAnsi(STR0011) // 'Tipo..........'
		Else
			cOrderBy += " COD"      // Por Codigo
			cCampo := .T.
		EndIf
	Else
		If nOrdem == 4
			cOrderBy += " GRUPO, CODITE"   // Por Grupo, Codite
			cCampo := 'B1_GRUPO'
			cMens  := OemToAnsi(STR0012) // 'Grupo.........'
		ElseIf nOrdem == 3
			cOrderBy += " B1_DESC, CODITE"   // Por Descricao, Codite
			cCampo := .T.
		ElseIf nOrdem == 2
			cOrderBy += " TIPO, CODITE"   // Por Tipo, Codite
			cCampo := 'B1_TIPO'
			cMens  := OemToAnsi(STR0011) // 'Tipo..........'
		Else
			cOrderBy += " CODITE"      // Por Codite
			cCampo := .T.
		Endif
	EndIf
	cOrderBy += "%"

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Query do relatorio da secao 1                                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	// oReport:Section(1):BeginQuery() // Alteração Claudino 11/05/12, retirei pois esta dando mensagem de campos de usuarios serão desconsiderados.

	cAliasTOP := GetNextAlias()
	cAliasSB2 := cAliasTOP
	cAliasSB5 := cAliasTOP

	BeginSql Alias cAliasTOP

		SELECT SB2.B2_COD COD
		,SB1.B1_TIPO TIPO, SB1.B1_GRUPO GRUPO, SB1.B1_DESC, SB1.B1_UM UM
		,SUM(SB2.B2_QATU) QATU, SUM(SB2.B2_QFIM) QFIM, SB2.B2_STATUS
		,SUM(SB2.B2_QTSEGUM) QTSEGUM, SUM(SB2.B2_QFIM2) QFIM2
		%Exp:cSelect%

		FROM %table:SB2% SB2
		%Exp:cJoin%

		WHERE
		SB2.B2_LOCAL >= %Exp:mv_par04%
		AND	SB2.B2_LOCAL <= %Exp:mv_par05%
		AND SB2.B2_FILIAL  >= %Exp:mv_par02%
		AND SB2.B2_FILIAL  <= %Exp:mv_par03%
		AND SB2.%NotDel%
		%Exp:cWhere%

		GROUP BY %Exp:cGroupBy%

		ORDER BY %Exp:cOrderBy%

		EndSql
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Metodo EndQuery ( Classe TRSection )                                    ³
		//³                                                                        ³
		//³Prepara o relatorio para executar o Embedded SQL.                       ³
		//³                                                                        ³
		//³ExpA1 : Array com os parametros do tipo Range                           ³
		//³                                                                        ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		// oReport:Section(1):EndQuery(/*Array com os parametros do tipo Range*/) // Alteração Claudino 11/05/12, retirei pois esta dando 
		                                                                          // mensagem de campos de usuarios serão desconsiderados.

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Inicio do Fluxo do Relatorio					                           ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		//-- Inicializa Variaveis e Contadores
		cFilOld		:= (cAliasTOP)->FILIAL
		cCodAnt		:= (cAliasTOP)->COD
		cTipoAnt	:= (cAliasTOP)->TIPO
		cGrupoAnt	:= (cAliasTOP)->GRUPO

		If lVEIC
			cCodite    := (cAliasTOP)->CODITE
		EndIf		
		nQtdProd   := 0
		nTotProd   := 0
		nTotProd2  := 0	
		nTotProdBl := 0
		nTotProdB2 := 0
		nTotQuebra := 0
		nTotQuebr2 := 0 // 2a.UM

		dbSelectArea(cAliasTOP)
		oReport:SetMeter(SB2->(LastRec()))

		oSection:Init()
		While !oReport:Cancel() .And. !(cAliasTOP)->(Eof())
			If oReport:Cancel()
				Exit
			EndIf

			nQuant := 0.00
			nQuant2:= 0.00
			If mv_par15 == 3 // MOVIMENTACAO
				If AllTrim((cAliasTOP)->FILIAL) == '**'
					For nX := 1 to Len(aFiliais)
						cFilAnt := aFiliais[nX]
						If Alltrim((cAliasTOP)->LOC) == '**'
							aArea:=GetArea()
							dbSelectArea("SB2")
							dbSetOrder(1)
							dbSeek(cFilAnt + (cAliasTOP)->COD)
							While !Eof() .And. B2_FILIAL == cFilAnt .And. B2_COD == (cAliasTOP)->COD
								If SB2->B2_LOCAL >= mv_par04  .And. SB2->B2_LOCAL <= mv_par05
									nQuant += CalcEst((cAliasTOP)->COD,SB2->B2_LOCAL,dDataBase + 1, B2_FILIAL)[1]
									If mv_par18==1
										nQuant2+= CalcEst((cAliasTOP)->COD,SB2->B2_LOCAL,dDataBase + 1, B2_FILIAL)[7]
									EndIf	
								EndIf
								dbSkip()
							EndDo
							RestArea(aArea)
						Else
							nQuant += CalcEst((cAliasTOP)->COD, (cAliasTOP)->LOC, dDataBase+1)[1]
							If mv_par18==1
								nQuant2+= CalcEst((cAliasTOP)->COD, (cAliasTOP)->LOC, dDataBase+1)[7]
							EndIf	
						EndIf
					Next nX
				Else
					If Alltrim((cAliasTOP)->LOC) == '**'
						aArea:=GetArea()
						dbSelectArea("SB2")
						dbSetOrder(1)
						dbSeek(cSeek:=(cAliasTOP)->FILIAL + (cAliasTOP)->COD)
						While !Eof() .And. B2_FILIAL + B2_COD == cSeek
							If SB2->B2_LOCAL >= mv_par04  .And. SB2->B2_LOCAL <= mv_par05
								nQuant += CalcEst((cAliasTOP)->COD,SB2->B2_LOCAL,dDataBase + 1, B2_FILIAL)[1]
								If mv_par18==1
									nQuant2+= CalcEst((cAliasTOP)->COD,SB2->B2_LOCAL,dDataBase + 1, B2_FILIAL)[7]
								EndIf	
							EndIf
							dbSkip()
						EndDo
						RestArea(aArea)
					Else
						nQuant := CalcEst((cAliasTOP)->COD, (cAliasTOP)->LOC, dDataBase+1,(cAliasTOP)->FILIAL)[1]
						If mv_par18==1
							nQuant2:= CalcEst((cAliasTOP)->COD, (cAliasTOP)->LOC, dDataBase+1,(cAliasTOP)->FILIAL)[7]
						EndIf	
					EndIf
				EndIf
			Else
				nQuant := If(mv_par15==1,(cAliasTOP)->QATU, (cAliasTOP)->QFIM)
				If mv_par18==1
					nQuant2:= If(mv_par15==1,(cAliasTOP)->QTSEGUM, (cAliasTOP)->QFIM2)
				EndIf	
			EndIf	

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica se deverao ser impressos itens zerados  (mv_par14 - 1=SIM/2=NAO)  ³
			//³ / somente negativos 							 (mv_par16 - 1=SIM/2=NAO)  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If (mv_par14 == 1 .Or. ( mv_par14 <> 1 .and. QtdComp(nQuant) <> QtdComp(0))) .And. ;
					(mv_par16 <> 1 .Or. ( mv_par16 == 1 .and. If(mv_par14 <> 1, QtdComp(nQuant) < QtdComp(0),QtdComp(nQuant) <= QtdComp(0) )))

				If  lVEIC
					oSection:Cell("B1_CODITE"):SetValue((cAliasTOP)->CODITE)
				EndIf	
				oSection:Cell("B2_COD"):SetValue((cAliasTOP)->COD)
				oSection:Cell("B1_TIPO"):SetValue((cAliasTOP)->TIPO)
				oSection:Cell("B1_GRUPO"):SetValue((cAliasTOP)->GRUPO)
				oSection:Cell("B1_UM"):SetValue((cAliasTOP)->UM)
				oSection:Cell("B2_FILIAL"):SetValue((cAliasTOP)->FILIAL)
				oSection:Cell("B2_LOCAL"):SetValue((cAliasTOP)->LOC)
				oSection:Cell("QUANT"):SetValue(nQuant)
				If mv_par18==1
					oSection:Cell("B1_SEGUM"):SetValue((cAliasTop)->SEGUM)
					oSection:Cell("QUANT2"):SetValue(nQuant2)
				EndIf

				oSection:PrintLine()

				nQtdProd   ++
				nTotProd   += nQuant	//1a. UM
				nTotProd2  += nQuant2	//2a. UM
				nTotProdBl += If(SubStr((cAliasTOP)->B2_STATUS,1,1) $'2', nQuant,  0)	//1a. UM
				nTotProdB2 += If(SubStr((cAliasTOP)->B2_STATUS,1,1) $'2', nQuant2, 0)	//2a. UM
				nTotQuebra += nQuant	//1a.UM
				nTotQuebr2 += nQuant2	//2a.UM

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Atualiza Variaveis e Contadores ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				cFilOld	   := (cAliasTOP)->FILIAL
				cCodAnt    := (cAliasTOP)->COD
				cTipoAnt   := (cAliasTOP)->TIPO
				cGrupoAnt  := (cAliasTOP)->GRUPO

				If lVEIC
					cCodite    := (cAliasTop)->CODITE
				EndIf		

			EndIf

			(cAliasTop)->(dbSkip())
			oReport:IncMeter()

			If  ( (!lVEIC) .and. (!(cCodAnt == (cAliasTop)->COD)  )) .Or. ( ( lVEIC) .and. (!((cCodite + cCodAnt) == (cAliasTop)->(CODITE + cod))))
				If Alltrim(Str(nOrdem)) $ "1|3" //-- So' totaliza Produto se houver mais de 1
					If nQtdProd > 1 .And. (!(nTotProd==0).Or.!(nTotProdBl==0))
						oSection:GetFunction("DISP1"):Enable()
						oSection:GetFunction("DISP1"):ShowHeader()

						If mv_par18 == 1 // 2a.U.M.
							oSection:GetFunction("DISP2"):Enable()
							oSection:GetFunction("INDISP2"):Enable()
							oSection:GetFunction("QT2"):Enable()
                        EndIf
                        
						oSection:GetFunction("INDISP1"):Enable()
						oSection:GetFunction("INDISP1"):ShowHeader()
						oSection:GetFunction("QT1"):Enable()
						oSection:GetFunction("QT1"):ShowHeader()
						oBreak:ShowHeader()
					Else
						oSection:GetFunction("DISP1"):Disable()
						oSection:GetFunction("DISP1"):HideHeader()

						If mv_par18 == 1 // 2a.U.M.
							oSection:GetFunction("DISP2"):Disable()
							oSection:GetFunction("INDISP2"):Disable()
							oSection:GetFunction("QT2"):Disable()
	                    EndIf
	                    
						oSection:GetFunction("INDISP1"):Disable()
						oSection:GetFunction("INDISP1"):HideHeader()
						oSection:GetFunction("QT1"):Disable()
						oSection:GetFunction("QT1"):HideHeader()
						oBreak:HideHeader()
					EndIf								
				EndIf

				nQtdProd   := 0
				nTotProd   := 0 //1a.UM
				nTotProd2  := 0 //2a.UM
				nTotProdBl := 0 //1a.UM
				nTotProdB2 := 0 //2a.UM
			EndIf

		EndDo
		oSection:Finish()

#ELSE

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Processos de Inicia‡„o dos Arquivos Utilizados               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If mv_par17 == 1 // Desc. Cientifica
		dbSelectArea("SB5")
		dbSetOrder(1)
	EndIf
	//-- SB2 (Saldos em Estoque)
	dbSelectArea('SB2')
	dbSetOrder(1)

	If !lVEIC 	// Filtro para SIGAVEI, SIGAPEC e SIGAOFI

		cFiltroB2 := 'B2_COD>="'+mv_par06+'".And.B2_COD<="'+mv_par07+'".And.'
		cFiltroB2 += 'B2_LOCAL>="'+mv_par04+'".And.B2_LOCAL<="'+mv_par05+'"'
		If !Empty(xSB2)
			cFiltroB2 += '.And.B2_FILIAL>="'+mv_par02+'".And.B2_FILIAL<="'+mv_par03+'"'
		EndIf

	Else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Filtro para SIGAVEI, SIGAPEC e SIGAOFI                       ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		// Nao precisa do filtro para B2_COD nos SIGAVEI, SIGAPEC e SIGAOFI!
		cFiltroB2 := 'B2_LOCAL>="'+mv_par04+'".And.B2_LOCAL<="'+mv_par05+'"'
		If !Empty(xSB2)
			cFiltroB2 += '.And.B2_FILIAL>="'+mv_par02+'".And.B2_FILIAL<="'+mv_par03+'"'
		EndIf
	EndIf

	If mv_par01 == 3
		cIndB2 := 'B2_COD + B2_FILIAL + B2_LOCAL'
	ElseIf mv_par01 == 2
		cIndB2 := 'B2_FILIAL + B2_COD + B2_LOCAL'
	Else
		cIndB2 := 'B2_COD + B2_FILIAL + B2_LOCAL'
	EndIf	

	cNomArqB2 := Left(CriaTrab('',.F.),7) + 'a'

	IndRegua('SB2',cNomArqB2,cIndB2,,cFiltroB2,STR0015) //'Selecionando Registros...'
	nIndB2 := RetIndex('SB2')
	dbSetIndex(cNomArqB2 + OrdBagExt())
	dbSetOrder(nIndB2 + 1)
	dbGoTop()

	// ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	// ³Transforma parametros Range em expressao SQL                            ³
	// ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	MakeAdvplExpr(oReport:uParam)

	//-- SB1 (Produtos)
	dbSelectArea('SB1')
	dbSetOrder(nOrdem)

	If lVeic 	// Filtro para SIGAVEI, SIGAPEC e SIGAOFI
		cCondicao := 'B1_CODITE>="'+mv_par06+'".And.B1_CODITE<="'+mv_par07+'".And.'
	Else
		cCondicao := 'B1_COD>="'+mv_par06+'".And.B1_COD<="'+mv_par07+'".And.'
	EndIf
	cCondicao += 'B1_TIPO>="'+mv_par08+'".And.B1_TIPO<="'+mv_par09+'".And.'
	cCondicao += 'B1_GRUPO>="'+mv_par10+'".And.B1_GRUPO<="'+mv_par11+'".And.'
	cCondicao += 'B1_DESC>="'+mv_par12+'".And.B1_DESC<="'+mv_par13+'"'
	If !Empty(xSB1)
		cCondicao += '.And.B1_FILIAL>="'+mv_par02+'".And.B1_FILIAL<="'+mv_par03+'"'
	EndIf

	If nOrdem == 4
		If lVeic
			cIndB1 := 'B1_GRUPO+B1_CODITE+B1_FILIAL'
		Else
			cIndB1 := 'B1_GRUPO+B1_COD+B1_FILIAL'
		EndIf
		cCampo := 'B1_GRUPO'
		cMens  := STR0012 // 'Grupo.........'
	ElseIf nOrdem == 3
		If lVeic
			cIndB1 := 'B1_DESC+B1_CODITE+B1_FILIAL'
		Else
			cIndB1 := 'B1_DESC+B1_COD+B1_FILIAL'
		EndIf
		cCampo := .T.
	ElseIf nOrdem == 2
		If lVeic
			cIndB1 := 'B1_TIPO+B1_CODITE+B1_FILIAL'
		Else
			cIndB1 := 'B1_TIPO+B1_COD+B1_FILIAL'
		EndIf
		cCampo := 'B1_TIPO'
		cMens  := STR0011 // 'Tipo..........'
	Else
		If lVeic
			cIndB1 := 'B1_CODITE+B1_FILIAL'
		Else
			cIndB1 := 'B1_COD+B1_FILIAL'
		EndIf
		cCampo := .T.
	EndIf

	oSection:SetFilter(cCondicao,cIndB1)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Inicio do Fluxo do Relatorio					                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbGoTop()

	cFilialDe := If(Empty(xSB2),xSB2,mv_par02)

	If nOrdem == 4
		dbSeek(mv_par10, .T.)
	ElseIf nOrdem == 3
		//-- Pesquisa Somente se a Descricao for Generica.
		If mv_par17 == 2
			dbSeek(mv_par12, .T.)
		EndIf
	ElseIf nOrdem == 2
		dbSeek(mv_par08, .T.)
	Else
		dbSeek(mv_par06, .T.)
	EndIf

	oReport:SetMeter(SB1->(LastRec()))
	oSection:Init()

	//-- 1§ Looping no Arquivo Principal (SB1)
	While !oReport:Cancel() .And. !SB1->(Eof())
		If oReport:Cancel()
			Exit
		EndIf
		aProd  := {}
		aProd1 := {}

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica se imprime nome cientifico do produto. Se Sim    ³
		//³ verifica se existe registro no SB5 e se nao esta vazio    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cDesc := SB1->B1_DESC

		cQuebra1 := If(nOrdem==1.Or.nOrdem==3,.T.,&(cCampo))

		//-- 2§ Looping no Arquivo Principal (SB1)
		While !oReport:Cancel() .And. !SB1->(Eof()) .And. (cQuebra1 == If(nOrdem==1.Or.nOrdem==3,.T.,&(cCampo)))
			If oReport:Cancel()
				Exit
			EndIf

			oReport:IncMeter() //-- Incrementa R‚gua

			lImpr := .F.

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica se imprime nome cientifico do produto. Se Sim    ³
			//³ verifica se existe registro no SB5 e se nao esta vazio    ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cDesc := SB1->B1_DESC
			lIsCient := .F.
			If mv_par17 == 1
				dbSelectArea("SB5")
				dbSeek(xSB5 + SB1->B1_COD)
				If Found() .and. !Empty(B5_CEME)
					cDesc := B5_CEME
					lIsCient := .T.
				EndIf
				dbSelectArea('SB1')
			EndIf

			For nX := 1 to Len(aFiliais)

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Localiza produto no Cadastro de ACUMULADOS DO ESTOQUE        ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				dbSelectArea('SB2')
				If mv_par01 == 3
					DBSeek(SB1->B1_COD + If(Empty(xSB2),xSB2,aFiliais[nX]), .T.)
				ElseIf mv_par01 == 2
					DBSeek(If(Empty(xSB2),xSB2,aFiliais[nX]) + SB1->B1_COD, .T.)
				Else
					DBSeek(SB1->B1_COD + If(Empty(xSB2),xSB2,aFiliais[nX]) + mv_par04, .T.)
				EndIf

				//-- 1§ Looping no Arquivo Secund rio (SB2)
				While !oReport:Cancel() .And. !SB2->(Eof()) .And. B2_COD == SB1->B1_COD
					If oReport:Cancel()
						Exit
					EndIf

					If mv_par01 == 3
						If Empty(xSB1)
							cQuebra2  := B2_COD
							cCond2	 := 'B2_COD'
						Else
							cQuebra2  := B2_COD + B2_FILIAL
							cCond2	 := 'B2_COD + B2_FILIAL'
						EndIf	
					ElseIf mv_par01 == 2
						cQuebra2 := B2_FILIAL + B2_COD
						cCond2   := 'B2_FILIAL + B2_COD'
					Else
						cQuebra2 := B2_COD + B2_FILIAL + B2_LOCAL
						cCond2   := 'B2_COD + B2_FILIAL + B2_LOCAL'
					EndIf

					//-- NÆo deixa o mesmo Filial/Produto passar mais de 1 vez
					If Len(aProd) <= 4096
						If Len(aProd) == 0 .Or. Len(aProd[Len(aProd)]) == 4096
							aAdd(aProd, {})
						EndIf
						If aScan(aProd[Len(aProd)], cQuebra2) > 0
							SB2->(dbSkip())
							Loop
						Else
							aAdd(aProd[Len(aProd)], cQuebra2)
						EndIf
					Else
						If Len(aProd1) == 0 .Or. Len(aProd1[Len(aProd1)]) == 4096
							aAdd(aProd1, {})
						EndIf
						If aScan(aProd1[Len(aProd1)], cQuebra2) > 0
							SB2->(dbSkip())
							Loop
						Else
							aAdd(aProd1[Len(aProd1)], cQuebra2)
						EndIf					
					EndIf

					//-- 2§ Looping no Arquivo Secund rio (SB2)
					While !oReport:Cancel() .And. !SB2->(Eof())  .And. &(cCond2) == cQuebra2
						If oReport:Cancel()
							Exit
						EndIf

						If nOrdem == 2 //-- Tipo
							If SB1->B1_TIPO # fContSB1(SB2->B2_FILIAL, SB2->B2_COD, 'B1_TIPO')
								SB2->(dbSkip())
								Loop
							EndIf
						ElseIf nOrdem == 4 //-- Grupo
							If SB1->B1_GRUPO # fContSB1(SB2->B2_FILIAL, SB2->B2_COD, 'B1_GRUPO')
								SB2->(dbSkip())
								Loop
							EndIf
						EndIf

						If !Empty(SB2->B2_FILIAL)
							//-- Posiciona o SM0 na Filial Correta
							If SM0->(DBSeek(cEmpAnt+SB2->B2_FILIAL, .F.))
								//-- Atualiza a Variavel utilizada pela fun‡Æo xFilial()
								If !(cFilAnt==SM0->M0_CODFIL)
									cFilAnt := SM0->M0_CODFIL
								EndIf	
							EndIf
						EndIf

						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Carrega array com dados do produto na data base.             ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If mv_par15 > 2
							//-- Verifica se o SM0 esta posicionado na Filial Correta
							If !Empty(SB2->B2_FILIAL) .And. !(cFilAnt==SB2->B2_FILIAL)
								aSalProd := {0,0,0,0,0,0,0}
							Else
								aSalProd := CalcEst(SB2->B2_COD,SB2->B2_LOCAL,dDataBase+1)
							EndIf	
						Else
							aSalProd := {0,0,0,0,0,0,0}
						EndIf

						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Verifica se devera ser impressa o produto zerado             ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If If(mv_par15==1,B2_QATU,If(mv_par15==2,B2_QFIM,aSalProd[1])) == 0 .And. mv_par14 == 2 .Or. ;
								If(mv_par15==1,B2_QATU,If(mv_par15==2,B2_QFIM,aSalProd[1])) > 0 .And. mv_par16 == 1
							cCodAnt := SB2->B2_COD
							SB2->(dbSkip())
							If mv_par01 == 1 .And. SB2->B2_COD # cCodAnt .And. (If(mv_par15==1,B2_QATU,If(mv_par15==2,B2_QFIM,aSalProd[1])) <> 0 .And. mv_par14 == 2)
								If nQtdProd > 1
									lImpr := .T.
								Else
									nSoma    := 0
									nSoma2   := 0  // 2a.UM.
									nQtdProd := 0
								EndIf
							EndIf
							Loop
						EndIf

						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Adiciona 1 ao contador de registros impressos         ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If mv_par01 == 1 .Or. mv_par01 == 3

							If  lVEIC
								oSection:Cell("B1_CODITE"):SetValue(SB1->B1_CODITE)
							EndIf	
							oSection:Cell("B2_COD"):SetValue(SB2->B2_COD)
							oSection:Cell("B1_TIPO"):SetValue(fContSB1(SB2->B2_FILIAL, SB2->B2_COD, 'B1_TIPO'))
							oSection:Cell("B1_GRUPO"):SetValue(fContSB1(SB2->B2_FILIAL, SB2->B2_COD, 'B1_GRUPO'))
							oSection:Cell("B1_DESC"):SetValue(If(lIsCient, cDesc, fContSB1(SB2->B2_FILIAL, SB2->B2_COD, 'B1_DESC')))
							oSection:Cell("B1_UM"):SetValue(fContSB1(SB2->B2_FILIAL, SB2->B2_COD, 'B1_UM'))
							oSection:Cell("B2_FILIAL"):SetValue(SB2->B2_FILIAL)
							oSection:Cell("B2_LOCAL"):SetValue(SB2->B2_LOCAL)
							oSection:Cell("QUANT"):SetValue(If(mv_par15==1,B2_QATU,If(mv_par15==2,B2_QFIM,aSalProd[1])))
							If mv_par18==1
								oSection:Cell("B1_SEGUM"):SetValue(fContSB1(SB2->B2_FILIAL, SB2->B2_COD, 'B1_SEGUM'))
								oSection:Cell("QUANT2"):SetValue(If(mv_par15==1,B2_QTSEGUM,If(mv_par15==2,B2_QFIM2,aSalProd[7])))
							EndIf
		
							oSection:PrintLine()

							nQtdProd ++


						EndIf

						nSoma    += If(mv_par15==1,B2_QATU,If(mv_par15==2,B2_QFIM,aSalProd[1]))
						nTotSoma += If(mv_par15==1,B2_QATU,If(mv_par15==2,B2_QFIM,aSalProd[1]))
						If mv_par18 == 1 //2a.UM
							nSoma2    += If(mv_par15==1,B2_QTSEGUM,If(mv_par15==2,B2_QFIM2,aSalProd[7]))
							nTotSoma2 += If(mv_par15==1,B2_QTSEGUM,If(mv_par15==2,B2_QFIM2,aSalProd[7]))
						EndIf

						cFilOld := SB2->B2_FILIAL
						cCodAnt := SB2->B2_COD

						SB2->(dbSkip())

					EndDo

					If !(mv_par01 # 1 .And. (nSoma == 0 .And. mv_par14 == 2) .Or. (nSoma >= 0  .And. mv_par16 == 1))
						lImpr:=.T.
					EndIf

					If lImpr	

						If mv_par01 == 1 .Or. mv_par01 == 3
							If SB2->B2_COD # cCodAnt .And. (nOrdem # 2 .And. nOrdem # 4)
								If nQtdProd > 1
									oSection:GetFunction("DISP1"):Enable()
									oSection:GetFunction("DISP1"):ShowHeader()

									If mv_par18 == 1 // 2a.U.M.
										oSection:GetFunction("DISP2"):Enable()
										oSection:GetFunction("INDISP2"):Enable()
										oSection:GetFunction("QT2"):Enable()
									EndIf                                    

									oSection:GetFunction("INDISP1"):Enable()
									oSection:GetFunction("INDISP1"):ShowHeader()
									oSection:GetFunction("QT1"):Enable()
									oSection:GetFunction("QT1"):ShowHeader()
									oBreak:ShowHeader()
								Else
									oSection:GetFunction("DISP1"):Disable()
									oSection:GetFunction("DISP1"):HideHeader()

									If mv_par18 == 1 // 2a.U.M.
										oSection:GetFunction("DISP2"):Disable()
										oSection:GetFunction("INDISP2"):Disable()
										oSection:GetFunction("QT2"):Disable()
									EndIf

									oSection:GetFunction("INDISP1"):Disable()
									oSection:GetFunction("INDISP1"):HideHeader()
									oSection:GetFunction("QT1"):Disable()
									oSection:GetFunction("QT1"):HideHeader()
									oBreak:HideHeader()
								EndIf								
								nQtdBlq := 0
								nQtdBlq2:= 0								
								nSoma    := 0
								nSoma2   := 0 // 2a.UM
								nQtdProd := 0
							EndIf
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³ Verifica se devera ser impressa o produto zerado             ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						ElseIf !(nSoma == 0 .And. mv_par14 == 2) .Or. (nSoma >= 0  .And. mv_par16 == 1)
							If  lVEIC
								oSection:Cell("B1_CODITE"):SetValue(SB1->CODITE)
								oSection:Cell("B2_COD"):SetValue(SB1->B1_COD)
							Else
								oSection:Cell("B2_COD"):SetValue(cCodAnt)
							EndIf	
							oSection:Cell("B1_TIPO"):SetValue(fContSB1(cFilOld, cCodAnt, 'B1_TIPO'))
							oSection:Cell("B1_GRUPO"):SetValue(fContSB1(cFilOld, cCodAnt, 'B1_GRUPO'))
							oSection:Cell("B1_DESC"):SetValue(If(lIsCient, cDesc, fContSB1(cFilOld, cCodAnt, 'B1_DESC')))
							oSection:Cell("B1_UM"):SetValue(fContSB1(cFilOld, cCodAnt, 'B1_UM'))
							oSection:Cell("B2_FILIAL"):SetValue(If(mv_par01==2,cFilOld,'**'))
							oSection:Cell("B2_LOCAL"):SetValue('**')
							oSection:Cell("QUANT"):SetValue(nSoma)
							If mv_par18==1
								oSection:Cell("B1_SEGUM"):SetValue(fContSB1(cFilOld, cCodAnt, 'B1_SEGUM'))
								oSection:Cell("QUANT2"):SetValue(nSoma2)
							EndIf

							oSection:PrintLine()

							nSoma := 0
							nSoma2:= 0
						EndIf

						lImpr := .F.

					EndIf
				EndDo

			Next nX

			dbSelectArea('SB1')
			SB1->(dbSkip())

		EndDo

		If (nOrdem == 2 .Or. nOrdem == 4) .And. nTotSoma # 0
			nTotSoma := 0
			nTotsoma2:= 0
		EndIf

	EndDo
	oSection:Finish()
#ENDIF		

//-- Retorna a Posi‡Æo Correta do SM0
SM0->(dbGoto(nRegM0))
//-- Reinicializa o Conteudo da Variavel cFilAnt
If !(cFilAnt==SM0->M0_CODFIL)	
	cFilAnt := SM0->M0_CODFIL
EndIf	

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Devolve as ordens originais dos arquivos                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SB2")
dbClearFilter()
RetIndex('SB2')
dbSetOrder(1)

dbSelectArea("SB1")
dbClearFilter()
RetIndex('SB1')
dbSetOrder(1)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Apaga indices de trabalho                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If File(cNomArqB2 += OrdBagExt())
	fErase(cNomArqB2)
EndIf	

Return NIL

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ MATR240R3³ Autor ³ Eveli Morasco         ³ Data ³ 25/02/93 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Saldos em Estoques                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ PROGRAMADOR  ³ DATA   ³ BOPS ³  MOTIVO DA ALTERACAO                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Rodrigo Sart.³07/08/98³16964A³Acerto na filtragem dos almoxarifados   ³±±
±±³ Fernando Joly³23/10/98³15013A³Acerto na filtragem de Filiais          ³±±
±±³ Fernando Joly³03/12/98³XXXXXX³S¢ imprimir "Total do Produto" quando   ³±±
±±³              ³        ³      ³houver mais de 1 produto.               ³±±
±±³ Fernando Joly³21/12/98³18920A³Possibilitar filtragem pelo usuario.    ³±±
±±³ Cesar Valadao³30/03/99³XXXXXX³Manutencao na SetPrint()                ³±±
±±³ Aline        ³27/04/99³21147 ³Considerar o NewHead do Titulo          ³±±
±±³ Cesar Valadao³28/04/99³17188A³Inclusao da Pergunta - Descricao Produto³±±
±±³              ³        ³      ³Descricao Cientifica ou Generica.       ³±±
±±³ Cesar Valadao³08/12/99³25510A³Erro na Totalizacao de Produto Por      ³±±
±±³              ³        ³      ³Almoxarifado com Saldo Zerado.          ³±±
±±³ Patricia Sal.³11/07/00³005086³Acerto Salto de linha (P/ Almoxarifado) ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Marcos Hirakaw³21/05/04³XXXXXX³Imprimir B1_CODITE quando for gestao de ³±±
±±³              ³        ³      ³Concessionarias ( MV_VEICULO = "S")     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Descri‡ao ³ PLANO DE MELHORIA CONTINUA        ³Programa: MATR240.PRX   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ITEM PMC  ³ Responsavel              ³ Data              Bops          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³      01  ³Marcos V. Ferreira        ³31/03/2006 - Bops: 00000095737   ³±±
±±³      02  ³Marcos V. Ferreira        ³31/03/2006 - Bops: 00000095737   ³±±
±±³      03  ³                          ³                                 ³±±
±±³      04  ³                          ³                                 ³±±
±±³      05  ³Alexandre Inacio Lemes    ³10/03/2006 - Bops: 00000107040   ³±±
±±³      06  ³Alexandre Inacio Lemes    ³10/03/2006 - Bops: 00000107040   ³±±
±±³      07  ³                          ³                                 ³±±
±±³      08  ³Ricardo Berti 	        ³03/08/2006 -       00000104487   ³±±
±±³      09  ³                          ³                                 ³±±
±±³      10  ³Ricardo Berti 	        ³03/08/2006 -       00000104487   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function MATR240R3()

Local Tamanho    := 'M'
Local Titulo     := OemToAnsi(STR0001) // 'Saldos em Estoque'
Local cDesc1     := OemToAnsi(STR0002) // "Este programa ira' emitir um resumo dos saldos, em quantidade,"
Local cDesc2     := OemToAnsi(STR0003) // 'dos produtos em estoque.'
Local cDesc3     := ''
Local cString    := 'SB1'
Local aOrd       := {OemToAnsi(STR0004),OemToAnsi(STR0005),OemToAnsi(STR0006),OemToAnsi(STR0007)} // ' Por Codigo         '###' Por Tipo           '###' Por Descricao    '###' Por Grupo        '
Local WnRel      := 'XMATR240'
Local nTotQuebra := nTotQuebr2 := 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis tipo Local para SIGAVEI, SIGAPEC e SIGAOFI         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local aArea1	:= Getarea()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis tipo Private para SIGAVEI, SIGAPEC e SIGAOFI       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private lVEIC   := UPPER(GETMV("MV_VEICULO"))=="S"
Private aSB1Cod := {}
Private aSB1Ite := {}
Private nCOL1	 := 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis tipo Private padrao de todos os relatorios         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private aReturn  := {OemToAnsi(STR0008), 1,OemToAnsi(STR0009), 2, 2, 1, '',1 } // 'Zebrado'###'Administracao'
Private nLastKey := 0
Private cPerg    := 'XMTR240'

aSB1Cod	:= TAMSX3("B1_COD")
aSB1Ite	:= TAMSX3("B1_CODITE")

If lVEIC
	nCOL1		:= ABS(aSB1Cod[1] - aSB1Ite[1]) + 1 + aSB1Cod[1]
EndIf

AjustaSX1(cPerg)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica as perguntas selecionadas                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros                                  ³
//³ mv_par01     // Aglutina por: Almoxarifado / Filial / Empresa         ³
//³ mv_par02     // Filial de                                             ³
//³ mv_par03     // Filial ate                                            ³
//³ mv_par04     // Almoxarifado de                                       ³
//³ mv_par05     // Almoxarifado ate                                      ³
//³ mv_par06     // Produto de                                            ³
//³ mv_par07     // Produto ate                                           ³
//³ mv_par08     // tipo de                                               ³
//³ mv_par09     // tipo ate                                              ³
//³ mv_par10     // grupo de                                              ³
//³ mv_par11     // grupo ate                                             ³
//³ mv_par12     // descricao de                                          ³
//³ mv_par13     // descricao ate                                         ³
//³ mv_par14     // imprime qtde zeradas                                  ³
//³ mv_par15     // Saldo a considerar : Atual / Fechamento / Movimento   ³
//³ mv_par16     // Lista Somente Saldos Negativos                 		  ³
//³ mv_par17     // Descricao Produto : Cientifica / Generica      		  ³
//³ mv_par18   	 // QTDE. na 2a. U.M. ?     (Sim/Nao)                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Pergunte(cPerg,.F.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Envia controle para a funcao SETPRINT                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

WnRel := SetPrint(cString,WnRel,cPerg,@Titulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,,Tamanho)

If nLastKey == 27
	DBSELECTAREA(cString)
	dbClearFilter()
	Return Nil
EndIf

SetDefault(aReturn,cString)

If nLastKey == 27
	DBSELECTAREA(cString)
	dbClearFilter()
	Return Nil
EndIf

RptStatus({|lEnd| C240Imp(aOrd,@lEnd,WnRel,Titulo,Tamanho)},Titulo)

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ C240IMP  ³ Autor ³ Rodrigo de A. Sartorio³ Data ³ 11.12.95 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Chamada do Relatorio                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpA1: Array das ordens do relatorio						  ³±±
±±³          ³ExpL1: Controle de interrupcao pelo usuario 				  ³±±
±±³          ³ExpC1: Codigo do relatorio 								  ³±±
±±³          ³ExpC2: Titulo do relatorio                           		  ³±±
±±³          ³ExpC3: Tamanho do relatorio (P/M/G)						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATR240													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function C240Imp(aOrd,lEnd,WnRel,Titulo,Tamanho)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Local cRodaTxt   := STR0024	//"REG(S)"
Local nCntImpr   := 0
Local nTipo      := 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis locais exclusivas deste programa                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local lImpr      :=.F.
Local nSoma      := nSoma2    := 0
Local nTotSoma   := nTotSoma2 := 0
Local nX         := 0
Local nRegM0     := 0
Local nIndB1     := 0
Local nIndB2     := 0
Local nQtdProd   := 0
Local aSalProd   := {}
Local cFilialDe  := ''
Local cQuebra1   := ''
Local cCampo     := ''
Local cMens      := ''
Local aProd      := {}
Local aProd1     := {}
Local aArea
Local cFilOld    := 'úú'
Local cCodAnt    := 'úú'
Local cDesc
Local lIsCient
Local cPict
Local nQtdBlq    := nQtdBlq2 := 0
Local nQuant     := 0.00
Local nQuant2    := 0.00
Local nCubTot    := 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis Locais utilizadas na montagem das Querys           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local cQuery     := ''
Local _cQuery    := '' // Variavel que ira armazenar a query para tratamento a Cubagem. Alteração Claudino 03/05/12.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ajustar variaveis LOCAIS para SIGAVEI, SIGAPEC e SIGAOFI     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local cCodite    := ''

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ajustar variaveis PRIVATE para SIGAVEI, SIGAPEC e SIGAOFI    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE XSB1			:= XFILIAL('SB1')
PRIVATE XSB2			:= XFILIAL('SB2')
PRIVATE XSB5			:= XFILIAL('SB5')

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis Private utilizadas na montagem das Querys          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private cAliasTOP  := ''

If ( cPaisLoc=="CHI" )
	cPict   := "@E 999,999,999.99"
Else
	cPict	:= PesqPictQt(If(mv_par15==1,'B2_QATU','B2_QFIM'),If(mv_par15==1, TamSX3("B2_QATU")[1], TamSX3("B2_QFIM")[1]))
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis Private exclusivas deste programa                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private cQuebra2   := ''
Private cCond2     := ''
Private cFiltroB1  := ''
Private cIndB1     := ''
Private aFiliais   := {}
Private cFiltroB2  := ''
Private cIndB2     := ''
Private lContinua  := .T.
Private cNomArqB1  := ''
Private cNomArqB2  := ''

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Contadores de linha e pagina                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private Li         := 80
Private m_pag      := 1

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa os codigos de caracter Comprimido/Normal da impressora ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nTipo := If(aReturn[4]==1,15,18)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Adiciona a ordem escolhida ao Titulo do relatorio          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Type('NewHead') # 'U'
	NewHead := AllTrim(NewHead)
	NewHead += ' (' + AllTrim(SubStr(aOrd[aReturn[8]],6,20)) + ')'
Else
	Titulo := AllTrim(Titulo)
	Titulo += ' (' + AllTrim(SubStr(aOrd[aReturn[8]],6,20)) + ')'
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta os Cabecalhos                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cCabec1 := If(mv_par18<>1,OemToAnsi(STR0010),OemToAnsi(STR0020)) + SPACE(10) + "CUBAGEM" // 'CODIGO          TP GRUP DESCRICAO                      UM FL ALM   QUANTIDADE    CUBAGEM'. // Alteração Claudino 03/05/12.
cCabec2 := ''
//-- 123456789012345 12 1234 123456789012345678901234567890 12 12 12 999,999,999.99
//-- 0         1         2         3         4         5         6         7
//-- 012345678901234567890123456789012345678901234567890123456789012345678901234567890

If lVEIC
	cCabec1 := substr(cCabec1,1,aSB1Cod[1]) + SPACE(nCOL1) + substr(cCabec1,aSB1Cod[1]+1)
	If !Empty(cCabec2)
		cCabec2 := substr(cCabec2,1,aSB1Cod[1]) + SPACE(nCOL1) + substr(cCabec2,aSB1Cod[1]+1)
	EndIf
EndIf


//-- Alimenta Array com Filiais a serem Pesquisadas
aFiliais := {}
nRegM0   := SM0->(Recno())
SM0->(DBSeek(cEmpAnt, .T.))
Do While !SM0->(Eof()) .And. SM0->M0_CODIGO == cEmpAnt
	If SM0->M0_CODFIL >= mv_par02 .And. SM0->M0_CODFIL <= mv_par03
		aAdd(aFiliais, SM0->M0_CODFIL)
	EndIf
	SM0->(dbSkip())
EndDo
SM0->(dbGoto(nRegM0))

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Processos de Inicia‡„o dos Arquivos Utilizados               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
#IFDEF TOP

	cAliasTOP := CriaTrab(Nil, .F.)

	If mv_par17 == 1 // Desc. Cientifica
		dbSelectArea("SB5")
		dbSetOrder(1)
	EndIf

	//ÚÄÄÄÄÄÄÄÄ¿
	//³ SELECT ³
	//ÀÄÄÄÄÄÄÄÄÙ
	cQuery := "SELECT SB2.B2_COD COD"      // 01
	cQuery += ", SB1.B1_TIPO TIPO"         // 02
	cQuery += ", SB1.B1_GRUPO GRUPO"       // 03
	cQuery += ", SB1.B1_DESC DESCRI"       // 04
	cQuery += ", SB1.B1_UM UM"             // 05
	If mv_par18 == 1
		cQuery += ", SB1.B1_SEGUM SEGUM"    // 06
	EndIf

	If lVEIC
		cQuery += ", SB1.B1_CODITE CODITE" // 07
	EndIf

	If mv_par01 == 1 //-- Aglutina por Armazem
		cQuery += ", SB2.B2_LOCAL LOC, SB2.B2_FILIAL FILIAL"
	Else  //-- Aglutina por Filial ou por Empresa
		cQuery += ", '**' LOC"
	EndIf	
	If  mv_par01 == 2 //-- Aglutina por Filial
		cQuery += ", SB2.B2_FILIAL FILIAL"
	EndIf 	
	If mv_par01 == 3  //-- Aglutina por Empresa
		cQuery += ", '**' FILIAL"
	EndIf
	cQuery += ", SUM(SB2.B2_QATU) QATU, SUM(SB2.B2_QFIM) QFIM, SB2.B2_STATUS SITU"
	cQuery += ", SUM(SB2.B2_QTSEGUM) QTSEGUM, SUM(SB2.B2_QFIM2) QFIM2"
	//ÚÄÄÄÄÄÄ¿
	//³ FROM ³
	//ÀÄÄÄÄÄÄÙ
	cQuery += (" FROM "+RetSqlName('SB2')+" SB2, "+RetSqlName('SB1')+" SB1")

	//ÚÄÄÄÄÄÄÄ¿
	//³ WHERE ³
	//ÀÄÄÄÄÄÄÄÙ

	cQuery += " WHERE"

	If ! lVEIC
		cQuery += ("     SB1.B1_COD >= '" + mv_par06 + "'")
		cQuery += (" AND SB1.B1_COD <= '" + mv_par07 + "'")
	Else
		cQuery += ("     SB1.B1_CODITE >= '" + mv_par06 + "'")
		cQuery += (" AND SB1.B1_CODITE <= '" + mv_par07 + "'")
	EndIf

	If !Empty(xSB1)
		cQuery += (" AND SB1.B1_FILIAL >= '" + mv_par02 + "'")
		cQuery += (" AND SB1.B1_FILIAL <= '" + mv_par03 + "'")
	EndIf	

	cQuery += (" AND SB1.B1_TIPO  >='" + mv_par08 + "'")
	cQuery += (" AND SB1.B1_TIPO  <='" + mv_par09 + "'")
	cQuery += (" AND SB1.B1_GRUPO >='" + mv_par10 + "'")
	cQuery += (" AND SB1.B1_GRUPO <='" + mv_par11 + "'")
	cQuery += (" AND SB1.B1_DESC  >='" + mv_par12 + "'")
	cQuery += (" AND SB1.B1_DESC  <='" + mv_par13 + "'")
	cQuery += (" AND SB2.B2_LOCAL >='" + mv_par04 + "'")
	cQuery += (" AND SB2.B2_LOCAL <='" + mv_par05 + "'")

	If mv_par16 == 1 .And. mv_par01 == 1//-- Somente Negativos
		If mv_par14 == 2 //-- Imprime Zerados
			If mv_par15 == 1 //-- Saldo Atual
				cQuery += " AND (SB2.B2_QATU < 0)"
			ElseIf mv_par15 == 2 //-- Saldo Final
				cQuery += " AND (SB2.B2_QFIM < 0)"
			EndIf
		Else //-- Nao Imprime Zerados
			If mv_par15== 1 //-- Saldo Atual
				cQuery += " AND (SB2.B2_QATU <= 0)"
			ElseIf mv_par15 == 2 //-- Saldo Final
				cQuery += " AND (SB2.B2_QFIM <= 0)"
			EndIf
		EndIf	
	ElseIf mv_par14 == 2 .And. mv_par01 == 1//-- Nao Imprime Zerados
		If mv_par15 == 1 //-- Saldo Atual
			cQuery += " AND (SB2.B2_QATU <> 0)"
		ElseIf mv_par15 == 2 //-- Saldo Final
			cQuery += " AND (SB2.B2_QFIM <> 0)"
		EndIf
	EndIf
	cQuery +=  " AND    SB1.B1_COD  = SB2.B2_COD"
	cQuery +=  " AND SB2.D_E_L_E_T_ = ' '"
	cQuery +=  " AND SB1.D_E_L_E_T_ = ' '"
	cQuery += (" AND SB2.B2_FILIAL  >='" + mv_par02 + "'")
	cQuery += (" AND SB2.B2_FILIAL  <='" + mv_par03 + "'")

	If xSB1 # Space(2) .AND. xSB2 # Space(2)
		cQuery += " AND SB1.B1_FILIAL = SB2.B2_FILIAL"
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄ¿
	//³ GROUP BY ³
	//ÀÄÄÄÄÄÄÄÄÄÄÙ

	cQuery += " GROUP BY"
	If ! lVEIC
		cQuery += " SB2.B2_COD, SB1.B1_TIPO, SB1.B1_GRUPO"
	Else	
		cQuery += " SB1.B1_CODITE, SB2.B2_COD, SB1.B1_TIPO, SB1.B1_GRUPO"
	EndIf

	cQuery += ", SB1.B1_DESC"
	cQuery += ", SB1.B1_UM"
	If mv_par18 == 1
		cQuery += ", SB1.B1_SEGUM"
	EndIf
	If mv_par01 == 1 //-- Aglutina por Armazem
		cQuery += ", SB2.B2_LOCAL, SB2.B2_FILIAL"
	EndIf
	If mv_par01 == 2 //-- Aglutina por Filial
		cQuery += ", SB2.B2_FILIAL"
	EndIf	
	If mv_par01 == 3 //-- Aglutina por Empresa
		cQuery += " "
	EndIf	
	cQuery += ", SB2.B2_STATUS"
	//ÚÄÄÄÄÄÄÄÄÄÄ¿
	//³ ORDER BY ³
	//ÀÄÄÄÄÄÄÄÄÄÄÙ

	cQuery += " ORDER BY"

	If ! lVEIC
		If aReturn[8] == 4
			cQuery += " 3, 1"   // Por Grupo, Codigo
			cCampo := 'B1_GRUPO'
			cMens  := OemToAnsi(STR0012) // 'Grupo.........'
		ElseIf aReturn[8] == 3
			cQuery += " 4, 1"   // Por Descricao, Codigo
			cCampo := .T.
		ElseIf aReturn[8] == 2
			cQuery += " 2, 1"   // Por Tipo, Codigo
			cCampo := 'B1_TIPO'
			cMens  := OemToAnsi(STR0011) // 'Tipo..........'
		Else
			cQuery += " 1"      // Por Codigo
			cCampo := .T.
		EndIf

	Else

		If aReturn[8] == 4
			cQuery += " 3, 6"   // Por Grupo, Codite
			cCampo := 'B1_GRUPO'
			cMens  := OemToAnsi(STR0012) // 'Grupo.........'
		ElseIf aReturn[8] == 3
			cQuery += " 4, 6"   // Por Descricao, Codite
			cCampo := .T.
		ElseIf aReturn[8] == 2
			cQuery += " 2, 6"   // Por Tipo, Codite
			cCampo := 'B1_TIPO'
			cMens  := OemToAnsi(STR0011) // 'Tipo..........'
		Else
			cQuery += " 6"      // Por Codite
			cCampo := .T.
		Endif

	EndIf
	cQuery := ChangeQuery(cQuery)
	MsAguarde({|| dbUseArea(.T.,'TOPCONN', TCGenQry(,,cQuery), cAliasTOP,.F.,.T.)}, STR0015) //"Selecionando Registros ..."
    
	//-- Inicializa Variaveis e Contadores
	cFilOld		:= (cAliasTop)->FILIAL
	cCodAnt		:= (cAliasTop)->COD
	cTipoAnt	:= (cAliasTop)->TIPO
	cGrupoAnt	:= (cAliasTop)->GRUPO

	If lVEIC
		cCodite    := (cAliasTop)->CODITE
	EndIf		

	nQtdProd   := 0
	nTotProd   := 0
	nTotProd2  := 0	
	nTotProdBl := 0
	nTotProdB2 := 0
	nTotQuebra := 0
	nTotQuebr2 := 0 // 2a.UM
	dbSelectArea(cAliasTop)
	Do While !(cAliasTop)->(Eof())
         
        // Query Claudino, essa query é referente a Cubagem.
        _cQuery := 'SELECT DISTINCT(SB5.B5_COD) AS Prod, SB5.B5_COMPR * SB5.B5_ALTURA * SB5.B5_LARG AS Cubagem '
    	_cQuery += 'FROM ' + RetSqlName("SB5") + ' SB5 '
     	_cQuery += "WHERE SB5.D_E_L_E_T_ <> '*' AND (SB5.B5_COD = '" + (cAliasTop)->COD + "') "
      	_cQuery += "AND SB5.B5_FILIAL = '" + xFilial("SB5") + "' "
       	_cQuery += 'ORDER BY Prod'
        
        // Alteração Claudino 03/05/12, impressão da cubagem nos itens.
    	If Select("CUBA") > 0
			CUBA->(dbclosearea("CUBA"))
		EndIf
    
        dbUseArea( .T., "TOPCONN", TCGENQRY(,,_cQuery), 'CUBA' )
    
	    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Processa Flltro de Usuario ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea("SB1")
		dbsetorder(1)		
		If dbSeek(XSB1 + (cAliasTop)->COD)

			dbSelectArea(cAliasTop)

			If lEnd
				@ PROW()+1, 001 pSay OemToAnsi(STR0013) // 'CANCELADO PELO OPERADOR'
				Exit
			EndIf

			nQuant := 0.00
			nQuant2:= 0.00
			If mv_par15 == 3 // MOVIMENTACAO
				If AllTrim((cAliasTop)->FILIAL) == '**'
					For nX := 1 to Len(aFiliais)
						cFilAnt := aFiliais[nX]
						If Alltrim((cAliasTop)->LOC) == '**'
							aArea:=GetArea()
							dbSelectArea("SB2")
							dbSetOrder(1)
							dbSeek(cFilAnt + (cAliasTOP)->COD)
							While !Eof() .And. B2_FILIAL == cFilAnt .And. B2_COD == (cAliasTOP)->COD
								If SB2->B2_LOCAL >= mv_par04  .And. SB2->B2_LOCAL <= mv_par05
									nQuant += CalcEst((cAliasTOP)->COD,SB2->B2_LOCAL,dDataBase + 1, B2_FILIAL)[1]
									If mv_par18==1
										nQuant2+= CalcEst((cAliasTOP)->COD,SB2->B2_LOCAL,dDataBase + 1, B2_FILIAL)[7]
									EndIf	
								EndIf
								dbSkip()
							EndDo
							RestArea(aArea)
						Else
							nQuant += CalcEst((cAliasTop)->COD, (cAliasTop)->LOC, dDataBase+1)[1]
							If mv_par18==1
								nQuant2+= CalcEst((cAliasTop)->COD, (cAliasTop)->LOC, dDataBase+1)[7]
							EndIf	
						EndIf
					Next nX
				Else
					If Alltrim((cAliasTop)->LOC) == '**'
						aArea:=GetArea()
						dbSelectArea("SB2")
						dbSetOrder(1)
						dbSeek(cSeek:=(cAliasTop)->FILIAL + (cAliasTop)->COD)
						While !Eof() .And. B2_FILIAL + B2_COD == cSeek
							If SB2->B2_LOCAL >= mv_par04  .And. SB2->B2_LOCAL <= mv_par05
								nQuant += CalcEst((cAliasTOP)->COD,SB2->B2_LOCAL,dDataBase + 1, B2_FILIAL)[1]
								If mv_par18==1
									nQuant2+= CalcEst((cAliasTOP)->COD,SB2->B2_LOCAL,dDataBase + 1, B2_FILIAL)[7]
								EndIf	
							EndIf
							dbSkip()
						EndDo
						RestArea(aArea)
					Else
						nQuant := CalcEst((cAliasTop)->COD, (cAliasTop)->LOC, dDataBase+1,(cAliasTop)->FILIAL)[1]
						If mv_par18==1
							nQuant2:= CalcEst((cAliasTop)->COD, (cAliasTop)->LOC, dDataBase+1,(cAliasTop)->FILIAL)[7]
						EndIf	
					EndIf
				EndIf
			Else
				nQuant := If(mv_par15==1,(cAliasTop)->QATU, (cAliasTop)->QFIM)
				If mv_par18==1
					nQuant2:= If(mv_par15==1,(cAliasTop)->QTSEGUM, (cAliasTop)->QFIM2)
				EndIf	
			EndIf	
			//-- mv_par14  -   imprime qtde zeradas 1=SIM/2=NAO
			If (mv_par14 == 1 .OR. ( mv_par14 <> 1 .and. alltrim(str(nQuant,16,2)) <> "0.00")) .And. ;
					(mv_par16 <> 1 .Or. ( mv_par16 == 1 .and. If(mv_par14 <> 1,alltrim(str(nQuant,16,2)) < "0.00",alltrim(str(nQuant,16,2)) <= "0.00")))
				If Li > 55
					Cabec(Titulo,cCabec1,cCabec2,WnRel,Tamanho,nTipo)
				EndIf

				If ! lVEIC
					@ Li, 00 pSay SubStr((cAliasTop)->COD, 1, 15)
				Else
					@ Li, 00 pSay (cAliasTop)->CODITE + " " + (cAliasTop)->COD
				EndIf	

				@ Li, 16 + nCOL1 pSay (cAliasTop)->TIPO
				@ Li, 19 + nCOL1 pSay (cAliasTop)->GRUPO

				If mv_par17 == 1 // Desc. Cientifica
					SB5->(dbSeek(xSB5 + (cAliasTop)->COD))
					cDesc := Left(SB5->B5_CEME, 30)
				EndIf

				@ Li, 24 + nCOL1 pSay If(Empty(cDesc),Left((cAliasTop)->DESCRI, 30),cDesc)
				@ Li, 55 + nCOL1 pSay (cAliasTop)->UM
				@ Li, 58 + nCOL1 pSay AllTrim((cAliasTop)->FILIAL)
				@ Li, 61 + nCOL1 pSay AllTrim((cAliasTop)->LOC)
				@ Li, 63 + nCOL1 pSay Transform( nQuant, cPict)
				If mv_par18==1
					@ Li, 81 + nCOL1 pSay (cAliasTop)->SEGUM
					@ Li, 84 + nCOL1 pSay nQuant2 Picture cPict
				    @ Li,100 PSay ROUND(CUBA->CUBAGEM * nQuant,6) Picture "999,999.999999"
				    nCubTot += CUBA->CUBAGEM * nQuant
				Else
				 	@ Li, 80 PSay ROUND(CUBA->CUBAGEM * nQuant,6) Picture "999,999.999999"
			     	nCubTot += CUBA->CUBAGEM * nQuant
				EndIf
				
				// Alteração Claudino 03/05/12, impressão da cubagem nos itens.
	            If Select("CUBA") > 0
					CUBA->(dbclosearea("CUBA"))
				EndIf
  				
				Li++

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Atualiza Variaveis e Contadores ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				cFilOld	  := (cAliasTop)->FILIAL
				cCodAnt    := (cAliasTop)->COD
				cTipoAnt   := (cAliasTop)->TIPO
				cGrupoAnt  := (cAliasTop)->GRUPO

				If lVEIC
					cCodite    := (cAliasTop)->CODITE
				EndIf		

				nQtdProd   ++
				nTotProd   += nQuant	//1a. UM
				nTotProd2  += nQuant2	//2a. UM
				nTotProdBl += If(SubStr(SITU,1,1) $'2', nQuant, 0)		//1a. UM
				nTotProdB2 += If(SubStr(SITU,1,1) $'2', nQuant2, 0)	//2a. UM
				nTotQuebra += nQuant	//1a.UM
				nTotQuebr2 += nQuant2	//2a.UM

			EndIf

		EndIf		

		(cAliasTop)->(dbSkip())

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Totaliza Quebra ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !(nTotQuebra==0) .And. If(aReturn[8]==4, !(cGrupoAnt==GRUPO) .Or. ((cAliasTop)->(EOF()) .And.Empty(cGrupoAnt)),If(aReturn[8]==2,!(cTipoAnt==TIPO),.F.)) .Or. ;
				(mv_par01 <> 1 .And. !(nTotQuebra==0) .And. !(cFilOld == (cAliasTop)->FILIAL))
            
            If(MV_PAR01 == 3) 
            	@ Li, 40 + nCOL1 pSay "Total Cubagem"                      // 'Total Cubagem', Alteração Claudino 16/05/12
            	@ Li, 61 + nCOL1 pSay Transform(nCubTot,"999,999.999999")  // 'Total Cubagem', Alteração Claudino 16/05/12
			  	Li++
		    Endif
		    
			@ Li, 40 + nCOL1 pSay If(Empty(cMens),SubStr(STR0016,1,5),STR0016 + cMens) //'Total do '
			@ Li, 63 + nCOL1 pSay Transform(nTotQuebra, cPict)
			If mv_par18 == 1
				@ Li, 81 + nCOL1 pSay (cAliasTop)->SEGUM
				@ Li, 84 + nCOL1 pSay Transform(nTotQuebr2, cPict)
			EndIf
			Li += 2
			nTotQuebra := 0
			nTotQuebr2 := 0
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Totaliza Produto ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		// If !(cCodAnt==(cAliasTop)->COD)
		If   ( (!lVEIC) .and. (!(cCodAnt == (cAliasTop)->COD)  )) .Or. ( ( lVEIC) .and. (!((cCodite + cCodAnt) == (cAliasTop)->(CODITE + cod))))
			If nQtdProd > 1 .And. Alltrim(Str(aReturn[8])) $ "1|3" //-- So' totaliza Produto se houver mais de 1
				If (!(nTotProd==0).Or.!(nTotProdBl==0))
					@ Li, 24 + nCOL1 pSay "(" + SubStr(STR0018,1,1)+ ") = " + OemToAnsi(STR0017) + OemToAnsi(STR0018) + Replicate('.',14)   //"Qtde. "###"Disponivel   "
					@ Li, 63 + nCOL1 pSay Transform((nTotProd-nTotProdBl), cPict)
					If mv_par18 == 1
						@ Li, 84 + nCOL1 pSay Transform((nTotProd2-nTotProdB2), cPict)
					EndIf
					Li++
					@ Li, 24 + nCOL1 pSay "(" + SubStr(STR0019,1,1)+ ") = " + OemToAnsi(STR0017) + OemToAnsi(STR0019) + Replicate('.',14)   //"Qtde. "###"Indisponivel "
					@ Li, 63 + nCOL1 pSay Transform(nTotProdBl, cPict)
					If mv_par18 == 1
						@ Li, 84 + nCOL1 pSay Transform(nTotProdB2,cPict)
					EndIf
					Li++
				    @ Li, 24 + nCOL1 pSay "Total Cubagem "                    // 'Total Cubagem', Alteração Claudino 16/05/12
					@ Li, 61 + nCOL1 pSay Transform(nCubTot,"999,999.999999") // 'Total Cubagem', Alteração Claudino 16/05/12
					nCubTot := 0                                              // 'Total Cubagem', Alteração Claudino 16/05/12
					Li++
					If ! lVEIC
						@ Li, 24 + nCOL1 pSay OemToAnsi(STR0014) + Space(1) + AllTrim(Left(cCodAnt,15)) // 'Total do Produto'
					Else
						@ Li, 24 pSay OemToAnsi(STR0014) + Space(1) + (cCodite  + " " + cCodAnt) // 'Total do Produto'
					EndIf	
					@ Li, 63 + nCOL1 pSay Transform(nTotProd, cPict)
					If mv_par18 == 1
						@ Li, 84 + nCOL1 pSay Transform(nTotProd2,cPict)
					EndIf
					Li += 2
				EndIf
			EndIf	
			nQtdProd   := 0
			nTotProd   := 0 //1a.UM
			nTotProd2  := 0 //2a.UM
			nTotProdBl := 0 //1a.UM
			nTotProdB2 := 0 //2a.UM
		EndIf

	EndDo

#ELSE
	//-- SB2 (Saldos em Estoque)
	dbSelectArea('SB2')
	dbSetOrder(1)

	If !lVEIC 	// Filtro para SIGAVEI, SIGAPEC e SIGAOFI

		cFiltroB2 := 'B2_COD>="'+mv_par06+'".And.B2_COD<="'+mv_par07+'".And.'
		cFiltroB2 += 'B2_LOCAL>="'+mv_par04+'".And.B2_LOCAL<="'+mv_par05+'"'
		If !Empty(xSB2)
			cFiltroB2 += '.And.B2_FILIAL>="'+mv_par02+'".And.B2_FILIAL<="'+mv_par03+'"'
		EndIf

	Else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Filtro para SIGAVEI, SIGAPEC e SIGAOFI                       ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		// Nao precisa do filtro para B2_COD nos SIGAVEI, SIGAPEC e SIGAOFI!
		cFiltroB2 := 'B2_LOCAL>="'+mv_par04+'".And.B2_LOCAL<="'+mv_par05+'"'
		If !Empty(xSB2)
			cFiltroB2 += '.And.B2_FILIAL>="'+mv_par02+'".And.B2_FILIAL<="'+mv_par03+'"'
		EndIf
	EndIf

	If mv_par01 == 3
		cIndB2 := 'B2_COD + B2_FILIAL + B2_LOCAL'
	ElseIf mv_par01 == 2
		cIndB2 := 'B2_FILIAL + B2_COD + B2_LOCAL'
	Else
		cIndB2 := 'B2_COD + B2_FILIAL + B2_LOCAL'
	EndIf	

	cNomArqB2 := Left(CriaTrab('',.F.),7) + 'a'

	IndRegua('SB2',cNomArqB2,cIndB2,,cFiltroB2,STR0015) //'Selecionando Registros...'
	nIndB2 := RetIndex('SB2')
	dbSetIndex(cNomArqB2 + OrdBagExt())
	dbSetOrder(nIndB2 + 1)
	dbGoTop()

	//-- SB1 (Produtos)
	dbSelectArea('SB1')
	dbSetOrder(aReturn[8])

	If lVEIC 	// Filtro para SIGAVEI, SIGAPEC e SIGAOFI

		cFiltroB1 := 'B1_CODITE>="'+mv_par06+'".And.B1_CODITE<="'+mv_par07+'".And.'
		cFiltroB1 += 'B1_TIPO>="'+mv_par08+'".And.B1_TIPO<="'+mv_par09+'".And.'
		cFiltroB1 += 'B1_GRUPO>="'+mv_par10+'".And.B1_GRUPO<="'+mv_par11+'"'
		If !Empty(xSB1)
			cFiltroB1 += '.And.B1_FILIAL>="'+mv_par02+'".And.B1_FILIAL<="'+mv_par03+'"'
		EndIf

		If aReturn[8] == 4
			cIndB1 := 'B1_GRUPO+B1_CODITE+B1_FILIAL'
			cCampo := 'B1_GRUPO'
			cMens  := OemToAnsi(STR0012) // 'Grupo.........'
		ElseIf aReturn[8] == 3
			cIndB1 := 'B1_DESC+B1_CODITE+B1_FILIAL'
			cCampo := .T.
		ElseIf aReturn[8] == 2
			cIndB1 := 'B1_TIPO+B1_CODITE+B1_FILIAL'
			cCampo := 'B1_TIPO'
			cMens  := OemToAnsi(STR0011) // 'Tipo..........'
		Else
			cIndB1 := 'B1_CODITE+B1_FILIAL'
			cCampo := .T.
		EndIf

	Else

		cFiltroB1 := 'B1_COD>="'+mv_par06+'".And.B1_COD<="'+mv_par07+'".And.'
		cFiltroB1 += 'B1_TIPO>="'+mv_par08+'".And.B1_TIPO<="'+mv_par09+'".And.'
		cFiltroB1 += 'B1_GRUPO>="'+mv_par10+'".And.B1_GRUPO<="'+mv_par11+'"'
		If !Empty(xSB1)
			cFiltroB1 += '.And.B1_FILIAL>="'+mv_par02+'".And.B1_FILIAL<="'+mv_par03+'"'
		EndIf

		If aReturn[8] == 4
			cIndB1 := 'B1_GRUPO+B1_COD+B1_FILIAL'
			cCampo := 'B1_GRUPO'
			cMens  := OemToAnsi(STR0012) // 'Grupo.........'
		ElseIf aReturn[8] == 3
			cIndB1 := 'B1_DESC+B1_COD+B1_FILIAL'
			cCampo := .T.
		ElseIf aReturn[8] == 2
			cIndB1 := 'B1_TIPO+B1_COD+B1_FILIAL'
			cCampo := 'B1_TIPO'
			cMens  := OemToAnsi(STR0011) // 'Tipo..........'
		Else
			cIndB1 := 'B1_COD+B1_FILIAL'
			cCampo := .T.
		EndIf

	EndIf
	cNomArqB1 := Left(CriaTrab('',.F.),7) + 'b'
	IndRegua('SB1',cNomArqB1,cIndB1,,cFiltroB1,STR0015) //'Selecionando Registros...'
	nIndB1 := RetIndex('SB1')
	dbSetIndex(cNomArqB1 + OrdBagExt())
	dbSetOrder(nIndB1 + 1)
	dbGoTop()
	SetRegua(LastRec())

	cFilialDe := If(Empty(xSB2),xSB2,mv_par02)

	If aReturn[8] == 4
		DBSeek(mv_par10, .T.)
	ElseIf aReturn[8] == 3
		//-- Pesquisa Somente se a Descricao For Generica.
		If mv_par17 == 2
			DBSeek(mv_par12, .T.)
		EndIf
	ElseIf aReturn[8] == 2
		DBSeek(mv_par08, .T.)
	Else
		DBSeek(mv_par06, .T.)
	EndIf

	//-- 1§ Looping no Arquivo Principal (SB1)
	Do While !SB1->(Eof()) .and. lContinua

		aProd  := {}
		aProd1 := {}

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica se imprime nome cientifico do produto. Se Sim    ³
		//³ verifica se existe registro no SB5 e se nao esta vazio    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cDesc := SB1->B1_DESC

		//-- Consiste Descri‡Æo De/At‚
		If cDesc < mv_par12 .Or. cDesc > mv_par13
			SB1->(dbSkip())
			Loop
		EndIf

		//-- Filtro do usuario
		If !Empty(aReturn[7]) .And. !&(aReturn[7])
			SB1->(dbSkip())
			Loop
		EndIf

		If lEnd
			@ PROW()+1, 001 pSay OemToAnsi(STR0013) // 'CANCELADO PELO OPERADOR'
			Exit
		EndIf

		cQuebra1 := If(aReturn[8]==1.Or.aReturn[8]==3,.T.,&(cCampo))

		//-- 2§ Looping no Arquivo Principal (SB1)
		Do While !SB1->(Eof()) .And. (cQuebra1 == If(aReturn[8]==1.Or.aReturn[8]==3,.T.,&(cCampo))) .And. lContinua

			//-- Incrementa R‚gua
			IncRegua()

			lImpr := .F.

			cDesc := SB1->B1_DESC
			//-- Consiste Descri‡Æo De/At‚
			If cDesc < mv_par12 .Or. cDesc > mv_par13
				SB1->(dbSkip())
				Loop
			EndIf

			//-- Filtro do usuario
			If !Empty(aReturn[7]) .And. !&(aReturn[7])
				SB1->(dbSkip())
				Loop
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica se imprime nome cientifico do produto. Se Sim    ³
			//³ verifica se existe registro no SB5 e se nao esta vazio    ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			lIsCient := .F.
			If mv_par17 == 1
				dbSelectArea("SB5")
				dbSeek(xSB5 + SB1->B1_COD)
				If Found() .and. !Empty(B5_CEME)
					cDesc := B5_CEME
					lIsCient := .T.
				EndIf
				dbSelectArea('SB1')
			EndIf

			For nX := 1 to Len(aFiliais)

				If !lContinua
					Exit
				EndIf

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Localiza produto no Cadastro de ACUMULADOS DO ESTOQUE        ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				dbSelectArea('SB2')
				If mv_par01 == 3
					DBSeek(SB1->B1_COD + If(Empty(xSB2),xSB2,aFiliais[nX]), .T.)
				ElseIf mv_par01 == 2
					DBSeek(If(Empty(xSB2),xSB2,aFiliais[nX]) + SB1->B1_COD, .T.)
				Else
					DBSeek(SB1->B1_COD + If(Empty(xSB2),xSB2,aFiliais[nX]) + mv_par04, .T.)
				EndIf

				//-- 1§ Looping no Arquivo Secund rio (SB2)
				Do While lContinua .And. !SB2->(Eof()) .And. B2_COD == SB1->B1_COD

					If mv_par01 == 3
						If Empty(xSB1)
							cQuebra2  := B2_COD
							cCond2	 := 'B2_COD == cQuebra2'
						Else
							cQuebra2  := B2_COD + B2_FILIAL
							cCond2	 := 'B2_COD + B2_FILIAL == cQuebra2'
						EndIf	
					ElseIf mv_par01 == 2
						cQuebra2 := B2_FILIAL + B2_COD
						cCond2   := 'B2_FILIAL + B2_COD == cQuebra2'					
					Else
						cQuebra2 := B2_COD + B2_FILIAL + B2_LOCAL
						cCond2   := 'B2_COD + B2_FILIAL + B2_LOCAL == cQuebra2'
					EndIf

					//-- NÆo deixa o mesmo Filial/Produto passar mais de 1 vez
					If Len(aProd) <= 4096
						If Len(aProd) == 0 .Or. Len(aProd[Len(aProd)]) == 4096
							aAdd(aProd, {})
						EndIf
						If aScan(aProd[Len(aProd)], cQuebra2) > 0
							SB2->(dbSkip())
							Loop
						Else
							aAdd(aProd[Len(aProd)], cQuebra2)
						EndIf
					Else
						If Len(aProd1) == 0 .Or. Len(aProd1[Len(aProd1)]) == 4096
							aAdd(aProd1, {})
						EndIf
						If aScan(aProd1[Len(aProd1)], cQuebra2) > 0
							SB2->(dbSkip())
							Loop
						Else
							aAdd(aProd1[Len(aProd1)], cQuebra2)
						EndIf					
					EndIf

					//-- 2§ Looping no Arquivo Secund rio (SB2)
					Do While lContinua .And. !SB2->(Eof()) .And. &(cCond2)

						If aReturn[8] == 2 //-- Tipo
							If SB1->B1_TIPO # fContSB1(SB2->B2_FILIAL, SB2->B2_COD, 'B1_TIPO')
								SB2->(dbSkip())
								Loop
							EndIf
						ElseIf aReturn[8] == 4 //-- Grupo
							If SB1->B1_GRUPO # fContSB1(SB2->B2_FILIAL, SB2->B2_COD, 'B1_GRUPO')
								SB2->(dbSkip())
								Loop
							EndIf
						EndIf

						If !Empty(SB2->B2_FILIAL)
							//-- Posiciona o SM0 na Filial Correta
							If SM0->(DBSeek(cEmpAnt+SB2->B2_FILIAL, .F.))
								//-- Atualiza a Variavel utilizada pela fun‡Æo xFilial()
								If !(cFilAnt==SM0->M0_CODFIL)
									cFilAnt := SM0->M0_CODFIL
								EndIf	
							EndIf
						EndIf

						If lEnd
							@ PROW()+1, 001 pSay OemToAnsi(STR0013) // 'CANCELADO PELO OPERADOR'
							lContinua := .F.
							Exit
						EndIf

						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Carrega array com dados do produto na data base.             ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If mv_par15 > 2
							//-- Verifica se o SM0 esta posicionado na Filial Correta
							If !Empty(SB2->B2_FILIAL) .And. !(cFilAnt==SB2->B2_FILIAL)
								aSalProd := {0,0,0,0,0,0,0}
							Else
								aSalProd := CalcEst(SB2->B2_COD,SB2->B2_LOCAL,dDataBase+1)
							EndIf	
						Else
							aSalProd := {0,0,0,0,0,0,0}
						EndIf

						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Verifica se devera ser impressa o produto zerado             ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If If(mv_par15==1,B2_QATU,If(mv_par15==2,B2_QFIM,aSalProd[1])) == 0 .And. mv_par14 == 2 .Or. ;
								If(mv_par15==1,B2_QATU,If(mv_par15==2,B2_QFIM,aSalProd[1])) > 0 .And. mv_par16 == 1
							cCodAnt := SB2->B2_COD
							SB2->(dbSkip())
							If mv_par01 == 1 .And. SB2->B2_COD # cCodAnt .And. (If(mv_par15==1,B2_QATU,If(mv_par15==2,B2_QFIM,aSalProd[1])) <> 0 .And. mv_par14 == 2)
								If nQtdProd > 1
									lImpr := .T.
								Else
									nSoma    := 0
									nSoma2   := 0  // 2a.UM.
									nQtdProd := 0
								EndIf
							EndIf
							Loop
						EndIf

						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Adiciona 1 ao contador de registros impressos         ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If mv_par01 == 1

							If Li > 55
								Cabec(Titulo,cCabec1,cCabec2,WnRel,Tamanho,nTipo)
							EndIf

							If lVEIC
								@ Li, 00 pSay SB1->B1_CODITE + " " + SB1->B1_COD
							Else
								@ Li, 00 pSay SubStr(B2_COD, 1, 15)
							EndIf

							@ Li, 16 + nCOL1 pSay fContSB1(SB2->B2_FILIAL, SB2->B2_COD, 'B1_TIPO')
							@ Li, 19 + nCOL1 pSay fContSB1(SB2->B2_FILIAL, SB2->B2_COD, 'B1_GRUPO')
							@ Li, 24 + nCOL1 pSay Left(If(lIsCient, cDesc,	fContSB1(SB2->B2_FILIAL, SB2->B2_COD, 'B1_DESC')),30)
							@ Li, 55 + nCOL1 pSay fContSB1(SB2->B2_FILIAL, SB2->B2_COD, 'B1_UM')
							@ Li, 58 + nCOL1 pSay B2_FILIAL
							@ Li, 61 + nCOL1 pSay B2_LOCAL
							@ Li, 63 + nCOL1 pSay Transform( If(mv_par15==1,B2_QATU,If(mv_par15==2,B2_QFIM,aSalProd[1])), cPict)
							If mv_par18 == 1
								@ Li, 81 + nCOL1 pSay fContSB1(SB2->B2_FILIAL, SB2->B2_COD, 'B1_SEGUM')
								@ Li, 84 + nCOL1 pSay Transform( If(mv_par15==1,B2_QTSEGUM,If(mv_par15==2,B2_QFIM2,aSalProd[7])), cPict)
								@ Li, 102 + nCOL1 pSay SubStr(If(SubStr(B2_STATUS,1,1)$"2",STR0019,STR0018),1,1)
							Else
								@ Li, 82 + nCOL1 pSay SubStr(If(SubStr(B2_STATUS,1,1)$"2",STR0019,STR0018),1,1)
							EndIf
							Li++
							nQtdProd ++
							If SubStr(B2_STATUS,1,1) $ "2"
								nQtdBlq += If(mv_par15==1,B2_QATU,If(mv_par15==2,B2_QFIM,aSalProd[1]))
								If mv_par18 == 1 //2a.UM
									nQtdBlq2+= If(mv_par15==1,B2_QTSEGUM,If(mv_par15==2,B2_QFIM2,aSalProd[7]))
								EndIf	
							EndIf
						EndIf

						nSoma    += If(mv_par15==1,B2_QATU,If(mv_par15==2,B2_QFIM,aSalProd[1]))
						nTotSoma += If(mv_par15==1,B2_QATU,If(mv_par15==2,B2_QFIM,aSalProd[1]))
						If mv_par18 == 1 //2a.UM
							nSoma2    += If(mv_par15==1,B2_QTSEGUM,If(mv_par15==2,B2_QFIM2,aSalProd[7]))
							nTotSoma2 += If(mv_par15==1,B2_QTSEGUM,If(mv_par15==2,B2_QFIM2,aSalProd[7]))
						EndIf

						cFilOld := SB2->B2_FILIAL
						cCodAnt := SB2->B2_COD

						SB2->(dbSkip())

					EndDo

					If !(mv_par01 # 1 .And. (nSoma == 0 .And. mv_par14 == 2) .Or. (nSoma >= 0  .And. mv_par16 == 1))
						lImpr:=.T.
					EndIf

					If lImpr	
						If Li > 55
							Cabec(Titulo,cCabec1,cCabec2,WnRel,Tamanho,nTipo)
						EndIf

						If mv_par01 == 1
							If SB2->B2_COD # cCodAnt .And. ;
									(aReturn[8] # 2 .And. aReturn[8] # 4)
								If nQtdProd > 1
									@ Li, 24 + nCOL1 pSay "(" + SubStr(STR0018,1,1)+ ") = " + OemToAnsi(STR0017) + OemToAnsi(STR0018) + Replicate('.',14)   //"Qtde. "###"Disponivel   "
									@ Li, 63 + nCOL1 pSay Transform((nSoma-nQtdBlq), cPict)
									If mv_par18 == 1 //2a.UM
										@ Li, 84 + nCOL1 pSay Transform((nSoma2-nQtdBlq2), cPict)
									EndIf
									Li++
									@ Li, 24 + nCOL1 pSay "(" + SubStr(STR0019,1,1)+ ") = " + OemToAnsi(STR0017) + OemToAnsi(STR0019) + Replicate('.',14)   //"Qtde. "###"Indisponivel "
									@ Li, 63 + nCOL1 pSay Transform(nQtdBlq, cPict)
									If mv_par18 == 1
										@ Li, 84 + nCOL1 pSay Transform(nQtdBlq2, cPict)
									EndIf
									Li++
									If ! lVEIC
										@ Li, 24 pSay OemToAnsi(STR0014) + Space(1) + AllTrim(Left(cCodAnt,15)) // 'Total do Produto'
									Else
										@ Li, 24 pSay OemToAnsi(STR0014) + Space(1) + SB1->B1_CODITE  + " " + cCodAnt // 'Total do Produto'
									EndIf
									@ Li, 63 + nCOL1 pSay Transform(nSoma, cPict)
									If mv_par18 == 1 // 2a.UM
										@ Li, 84 + nCOL1 pSay Transform(nSoma2, cPict)
									EndIf
									Li += 2
									nQtdBlq := 0
									nQtdBlq2:= 0								
								EndIf	
								nSoma    := 0
								nSoma2   := 0 // 2a.UM
								nQtdProd := 0
							EndIf
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³ Verifica se devera ser impressa o produto zerado             ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						ElseIf !(nSoma == 0 .And. mv_par14 == 2) .Or. (nSoma >= 0  .And. mv_par16 == 1)
							If lVEIC
								@ Li, 00 pSay SB1->B1_CODITE  + " " + SB1->B1_COD
							Else
								@ Li, 00 pSay cCodAnt
							EndIf	
							@ Li, 16 + nCOL1 pSay fContSB1(cFilOld, cCodAnt, 'B1_TIPO')
							@ Li, 19 + nCOL1 pSay fContSB1(cFilOld, cCodAnt, 'B1_GRUPO')
							@ Li, 24 + nCOL1 pSay Left(If(lIsCient, cDesc,	fContSB1(cFilOld, cCodAnt, 'B1_DESC')),30)
							@ Li, 55 + nCOL1 pSay fContSB1(cFilOld, cCodAnt, 'B1_UM')
							@ Li, 58 + nCOL1 pSay If(mv_par01==2,cFilOld,'**')
							@ Li, 61 + nCOL1 pSay '**'
							@ Li, 63 + nCOL1 pSay Transform(nSoma, cPict)
							If mv_par18 == 1 //2a. UM
								@ Li, 81 + nCOL1 pSay fContSB1(cFilOld, cCodAnt, 'B1_SEGUM')
								@ Li, 84 + nCOL1 pSay Transform(nSoma2, cPict)
							EndIf
							Li++
							nSoma := 0
							nSoma2:= 0
						EndIf

						lImpr := .F.

					EndIf
				EndDo

			Next nX

			dbSelectArea('SB1')
			SB1->(dbSkip())

		EndDo

		If Li > 55
			Cabec(Titulo,cCabec1,cCabec2,WnRel,Tamanho,nTipo)
		EndIf

		If (aReturn[8] == 2 .Or. aReturn[8] == 4) .And. ;
				nTotSoma # 0
			@ Li, 40 + nCOL1 pSay STR0016 + cMens //'Total do '
			@ Li, 63 + nCOL1 pSay Transform(nTotSoma, cPict)
			If mv_par18 == 1 // 2a.UM
				@ Li, 84 + nCOL1 pSay Transform(nTotSoma2, cPict)
			EndIf
			Li += 2
			nTotSoma := 0
			nTotsoma2:= 0
		EndIf

	EndDo
#ENDIF


If Li # 80
	Roda(nCntImpr,cRodaTxt,Tamanho)
EndIf

//-- Retorna a Posi‡Æo Correta do SM0
SM0->(dbGoto(nRegM0))
//-- Reinicializa o Conteudo da Variavel cFilAnt
If !(cFilAnt==SM0->M0_CODFIL)	
	cFilAnt := SM0->M0_CODFIL
EndIf	

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Devolve as ordens originais dos arquivos                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SB2")
dbClearFilter()
RetIndex('SB2')
dbSetOrder(1)

dbSelectArea("SB1")
dbClearFilter()
RetIndex('SB1')
dbSetOrder(1)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Apaga indices de trabalho                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If File(cNomArqB2 += OrdBagExt())
	fErase(cNomArqB2)
EndIf	
If File(cNomArqB1 += OrdBagExt())
	fErase(cNomArqB1)
EndIf	

If aReturn[5] == 1
	Set Printer To
	dbCommitAll()
	OurSpool(WnRel)
EndIf

Ms_Flush()

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ fContSB1 ³ Autor ³ Fernando Joly Siquini ³ Data ³ 13.10.98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Procura produto em SB1 e retorna o conteudo do campo       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ExpC4 = fContSB1(ExpC1,ExpC2,ExpC3)                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Filial de procura                                  ³±±
±±³          ³ ExpC2 = Codido de procura                                  ³±±
±±³          ³ ExpC3 = Campo cujo conte£do se deseja retornar             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ ExpC4 = Conteudo do campo em ExpC3                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

#IFNDEF TOP
	Static Function fContSB1(cFil, cCod, cCampo)

	//-- Inicializa Variaveis
	Local cCont      := &('SB1->' + cCampo)
	Local cPesq      := ''
	Local nPos       := 0
	Local nOrdem     := SB1->(IndexOrd())
	Local nRecno     := SB1->(Recno())

	If Empty(xSB1) .And. !Empty(cFil)
		cFil := xSB1
	EndIf

	cPesq := cFil + cCod

	If cPesq == Nil .Or. cCampo == Nil
		Return cCont
	EndIf	

	SB1->(dbSetOrder(1))
	If SB1->(DBSeek(cPesq, .F.)) .And. (nPos := SB1->(FieldPos(Upper(cCampo)))) > 0
		cCont := SB1->(FieldGet(nPos))
	EndIf

	SB1->(dbSetOrder(nOrdem))
	SB1->(dbGoto(nRecno))

	Return cCont
#ENDIF

/*---------------------------------------------------------|
| Autor | Claudino Domingues               | Data 16/05/12 | 
|----------------------------------------------------------|
| A função AjustaSX1 é chamada para incluir as perguntas   |
| no dicionario SX1, caso já exista não será duplicada.    |
-----------------------------------------------------------*/

Static Function AjustaSX1(cPerg)

Local aArea 	:= GetArea()
Local aRegs 	:= {}
Local i	  		:= 0
Local j     	:= 0
Local lInclui	:= .F.
Local aHelpPor	:= {}
Local aHelpSpa	:= {}
Local aHelpEng	:= {}
Local cTexto    := ''

cPerg 			:= PADR("XMTR240", Len(SX1->X1_GRUPO))
aRegs 			:= {}

AADD(aRegs,{cPerg,"01","Aglutina por ?                ","¿Agrupa por ?                 ","Group by ?                    ","mv_ch1","N",01,00,01,"C","                                                            ","mv_par01       ","Armazem        ","Deposito       ","Warehouse      ","                                                            ","               ","Filial         ","Sucursal       ","Branch         ","                                                            ","               ","Empresa        ","Empresa        ","Company        ","                                                            ","               ","               ","               ","               ","                                                            ","               ","               ","               ","          ","                                                            ","      ","S","   ","              ","                                        ","      "})
AADD(aRegs,{cPerg,"02","Da Filial ?                   ","¿De Sucursal ?                ","From Branch ?                 ","mv_ch2","C",02,00,00,"G","                                                            ","mv_par02       ","               ","               ","               ","                                                            ","               ","               ","               ","               ","                                                            ","               ","               ","               ","               ","                                                            ","               ","               ","               ","               ","                                                            ","               ","               ","               ","          ","                                                            ","      ","S","   ","              ","                                        ","      "})
AADD(aRegs,{cPerg,"03","Ate a Filial ?                ","¿A Sucursal ?                 ","To Branch ?                   ","mv_ch3","C",02,00,00,"G","                                                            ","mv_par03       ","               ","               ","               ","99                                                          ","               ","               ","               ","               ","                                                            ","               ","               ","               ","               ","                                                            ","               ","               ","               ","               ","                                                            ","               ","               ","               ","          ","                                                            ","      ","S","   ","              ","                                        ","      "})
AADD(aRegs,{cPerg,"04","Do Armazem ?                  ","¿De Deposito ?                ","From Warehouse ?              ","mv_ch4","C",02,00,00,"G","                                                            ","mv_par04       ","               ","               ","               ","                                                            ","               ","               ","               ","               ","                                                            ","               ","               ","               ","               ","                                                            ","               ","               ","               ","               ","                                                            ","               ","               ","               ","          ","                                                            ","      ","S","024","              ","                                        ","      "})
AADD(aRegs,{cPerg,"05","Ate o Armazem ?               ","¿A Deposito ?                 ","To Warehouse ?                ","mv_ch5","C",02,00,00,"G","                                                            ","mv_par05       ","               ","               ","               ","99                                                          ","               ","               ","               ","               ","                                                            ","               ","               ","               ","               ","                                                            ","               ","               ","               ","               ","                                                            ","               ","               ","               ","          ","                                                            ","      ","S","024","              ","                                        ","      "})
AADD(aRegs,{cPerg,"06","Do Produto ?                  ","¿De Producto ?                ","From Product ?                ","mv_ch6","C",15,00,00,"G","                                                            ","mv_par06       ","               ","               ","               ","01388                                                       ","               ","               ","               ","               ","                                                            ","               ","               ","               ","               ","                                                            ","               ","               ","               ","               ","                                                            ","               ","               ","               ","          ","                                                            ","SB1   ","S","030","              ","                                        ","      "})
AADD(aRegs,{cPerg,"07","Ate o Produto ?               ","¿A Producto ?                 ","To Product ?                  ","mv_ch7","C",15,00,00,"G","                                                            ","mv_par07       ","               ","               ","               ","01390                                                       ","               ","               ","               ","               ","                                                            ","               ","               ","               ","               ","                                                            ","               ","               ","               ","               ","                                                            ","               ","               ","               ","          ","                                                            ","SB1   ","S","030","              ","                                        ","      "})
AADD(aRegs,{cPerg,"08","Do Tipo ?                     ","¿De Tipo ?                    ","From Type ?                   ","mv_ch8","C",02,00,00,"G","                                                            ","mv_par08       ","               ","               ","               ","                                                            ","               ","               ","               ","               ","                                                            ","               ","               ","               ","               ","                                                            ","               ","               ","               ","               ","                                                            ","               ","               ","               ","          ","                                                            ","02    ","S","   ","              ","                                        ","      "})
AADD(aRegs,{cPerg,"09","Ate o Tipo ?                  ","¿A Tipo ?                     ","To Type ?                     ","mv_ch9","C",02,00,00,"G","                                                            ","mv_par09       ","               ","               ","               ","ZZ                                                          ","               ","               ","               ","               ","                                                            ","               ","               ","               ","               ","                                                            ","               ","               ","               ","               ","                                                            ","               ","               ","               ","          ","                                                            ","02    ","S","   ","              ","                                        ","      "})
AADD(aRegs,{cPerg,"10","Do Grupo ?                    ","¿De Grupo ?                   ","From Group ?                  ","mv_cha","C",04,00,00,"G","                                                            ","mv_par10       ","               ","               ","               ","                                                            ","               ","               ","               ","               ","                                                            ","               ","               ","               ","               ","                                                            ","               ","               ","               ","               ","                                                            ","               ","               ","               ","          ","                                                            ","SBM   ","S","   ","              ","                                        ","      "})
AADD(aRegs,{cPerg,"11","Ate o Grupo ?                 ","¿A Grupo ?                    ","To Group ?                    ","mv_chb","C",04,00,00,"G","                                                            ","mv_par11       ","               ","               ","               ","ZZZZ                                                        ","               ","               ","               ","               ","                                                            ","               ","               ","               ","               ","                                                            ","               ","               ","               ","               ","                                                            ","               ","               ","               ","          ","                                                            ","SBM   ","S","   ","              ","                                        ","      "})
AADD(aRegs,{cPerg,"12","Da Descricao do Produto ?     ","¿De Descripcion ?             ","From Product Description ?    ","mv_chc","C",15,00,00,"G","                                                            ","mv_par12       ","               ","               ","               ","                                                            ","               ","               ","               ","               ","                                                            ","               ","               ","               ","               ","                                                            ","               ","               ","               ","               ","                                                            ","               ","               ","               ","          ","                                                            ","SB1   ","S","   ","              ","                                        ","      "})
AADD(aRegs,{cPerg,"13","Ate a Descricao do Produto ?  ","¿A  Descripcion ?             ","To Product  Description ?     ","mv_chd","C",15,00,00,"G","                                                            ","mv_par13       ","               ","               ","               ","ZZZZZZZZZZZZZZZ                                             ","               ","               ","               ","               ","                                                            ","               ","               ","               ","               ","                                                            ","               ","               ","               ","               ","                                                            ","               ","               ","               ","          ","                                                            ","SB1   ","S","   ","              ","                                        ","      "})
AADD(aRegs,{cPerg,"14","Listar Prods C/ Saldo Zerado ?","¿Listar Prod.c/Saldo Nulo ?   ","List Prod W/Balc.Zeroed ?     ","mv_che","N",01,00,02,"C","                                                            ","mv_par14       ","Sim            ","Si             ","Yes            ","                                                            ","               ","Nao            ","No             ","No             ","                                                            ","               ","               ","               ","               ","                                                            ","               ","               ","               ","               ","                                                            ","               ","               ","               ","          ","                                                            ","      ","S","   ","              ","                                        ","      "})
AADD(aRegs,{cPerg,"15","Saldo do Prod. a Considerar ? ","¿Saldo del Prod. a Considerar ","Balance to be considered ?    ","mv_chf","N",01,00,02,"C","                                                            ","mv_par15       ","Atual          ","Actual         ","Current        ","                                                            ","               ","Fechamento     ","Cierre         ","Closing        ","                                                            ","               ","Movimento      ","Movimiento     ","Movement       ","                                                            ","               ","               ","               ","               ","                                                            ","               ","               ","               ","          ","                                                            ","      ","S","   ","              ","                                        ","      "})
AADD(aRegs,{cPerg,"16","Listar Apenas Prod Sld Negat ?","¿Listar Solo Prod. Neg. ?     ","Only List Prod. w/ Neg. Bal. ?","mv_chg","N",01,00,02,"C","                                                            ","mv_par16       ","Sim            ","Si             ","Yes            ","                                                            ","               ","Nao            ","No             ","No             ","                                                            ","               ","               ","               ","               ","                                                            ","               ","               ","               ","               ","                                                            ","               ","               ","               ","          ","                                                            ","      ","S","   ","              ","                                        ","      "})
AADD(aRegs,{cPerg,"17","Tipo da Descricao Produto ?   ","¿Tipo de Descripcion Producto ","Product Description ?         ","mv_chh","N",01,00,02,"C","                                                            ","mv_par17       ","Descr.Cient.   ","Descr. Cient.  ","Scient.Descr.  ","                                                            ","               ","Descr.Generica ","Descr.Generica ","General Descr. ","                                                            ","               ","               ","               ","               ","                                                            ","               ","               ","               ","               ","                                                            ","               ","               ","               ","          ","                                                            ","      ","S","   ","              ","                                        ","      "})
AADD(aRegs,{cPerg,"18","Quantidade na 2a. U.M. ?      ","¿CTD. en 2a. U.M. ?           ","Qtty. in 2nd UM ?             ","MV_CHI","N",01,00,01,"C","                                                            ","mv_par18       ","Sim            ","Si             ","Yes            ","                                                            ","               ","Nao            ","No             ","No             ","                                                            ","               ","               ","               ","               ","                                                            ","               ","               ","               ","               ","                                                            ","               ","               ","               ","          ","                                                            ","      ","S","   ","              ","                                        ","      "})

dbSelectArea("SX1")
dbSetOrder(1)
For i := 1 To Len(aRegs)
 lInclui := !dbSeek(cPerg + aRegs[i,2])
 If!(dbSeek(cPerg + aRegs[i,2]))
	 RecLock("SX1", lInclui)
	  For j := 1 to FCount()
	   If j <= Len(aRegs[i])
	    FieldPut(j,aRegs[i,j])
	   Endif
	  Next
	 MsUnlock()
 Endif
 cTexto += IIf( aRegs[i,1] + aRegs[i,2] $ cTexto, "", aRegs[i,1] + aRegs[i,2] + "\")
Next

RestArea(aArea)

Return(Nil)