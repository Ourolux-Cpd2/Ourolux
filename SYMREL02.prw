#Include "PROTHEUS.CH"
#Include "TOPCONN.Ch"
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ SYMREL02 ³ Autor ³ Desenvolvimento B4B   ³ Data ³ 28/01/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ RELATÓRIO DE FATURAMENTO X VENDEDOR			              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ B4B - R4 	                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
User Function SYMREL02()

Local oReport

If TRepInUse()
	//-- Interface de impressao
	oReport := ReportDef()
	oReport:PrintDialog()
EndIf

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ MATR580  ³ Autor ³ Desenvolvimento B4B   ³ Data ³ 28/01/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ RELATÓRIO DE FATURAMENTO X VENDEDOR			              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ B4B - R4 	                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function ReportDef()

Private cPerg    := PADR("SYMREL02",10)
Private cGerente := ""
Private cSupervi := ""
Private cFilVen  := ""
Private cVend    := ""
Private cNoVend  := ""
Private cPerio1  := 0
Private cPerio2  := 0
Private cPerio3  := 0
Private cPerio4  := 0
Private cPerio5  := 0
Private cPerio6  := 0
Private cMedia   := 0
Private aFiltro  := {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Criacao do componente de impressao                                      ³
//³                                                                        ³
//³TReport():New                                                           ³
//³ExpC1 : Nome do relatorio                                               ³
//³ExpC2 : Titulo                                                          ³
//³ExpC3 : Pergunte                                                        ³
//³ExpB4 : Bloco de codigo que sera executado na confirmacao da impressao  ³
//³ExpC5 : Descricao                                                       ³
//³                                                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oReport := TReport():New(cPerg,"RELATÓRIO DE FATURAMENTO X VENDEDOR",cPerg, {|oReport| ReportPrint(oReport)},"RELATÓRIO DE FATURAMENTO X VENDEDOR")
oReport:SetLandscape(.T.)
oSection1 := TRSection():New(oReport,OemToAnsi("FATURAMENTO X VENDEDOR"),)

//ÚÄÄÄÄÄÄÄÄÄ¿
//³Perguntas³
//ÀÄÄÄÄÄÄÄÄÄÙ
AjustaSx1()
Pergunte(oReport:uParam,.T.)

aFiltro := CALCDATA()

TRCell():New(oSection1,"Gerente" 		,/*Tabela*/,"Gerente"					,"@!"								,15	,/*lPixel*/,{|| cGerente })
TRCell():New(oSection1,"Supervisor" 	,/*Tabela*/,"Supervisor"  				,"@!"								,15	,/*lPixel*/,{|| cSupervi })
//TRCell():New(oSection1,"FilVend"    	,/*Tabela*/,"Filial de Vendas"			,"@!"								,TamSX3("A3_COD")[1]	,/*lPixel*/,{|| cFilVen })
TRCell():New(oSection1,"Vendedor" 		,/*Tabela*/,"Vendedor"					,"@!"								,TamSX3("A3_COD")[1]	,/*lPixel*/,{|| cVend })
TRCell():New(oSection1,"NomVend" 		,/*Tabela*/,"Nome Vend"		 			,"@!"								,20	,/*lPixel*/,{|| cNoVend })

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Meses de faturamento³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
TRCell():New(oSection1, aFiltro[6][3]	        ,/*Tabela*/,aFiltro[6][3]	,PesqPict("SD2","D2_TOTAL")		,TamSX3("D2_TOTAL")[1]	,/*lPixel*/,{|| cPerio6 })
TRCell():New(oSection1, aFiltro[5][3]	        ,/*Tabela*/,aFiltro[5][3]	,PesqPict("SD2","D2_TOTAL")		,TamSX3("D2_TOTAL")[1]	,/*lPixel*/,{|| cPerio5 })
TRCell():New(oSection1, aFiltro[4][3]	        ,/*Tabela*/,aFiltro[4][3]	,PesqPict("SD2","D2_TOTAL")		,TamSX3("D2_TOTAL")[1]	,/*lPixel*/,{|| cPerio4 })
TRCell():New(oSection1, aFiltro[3][3]	        ,/*Tabela*/,aFiltro[3][3]	,PesqPict("SD2","D2_TOTAL")		,TamSX3("D2_TOTAL")[1]	,/*lPixel*/,{|| cPerio3 })
TRCell():New(oSection1, aFiltro[2][3]	        ,/*Tabela*/,aFiltro[2][3]	,PesqPict("SD2","D2_TOTAL")		,TamSX3("D2_TOTAL")[1]	,/*lPixel*/,{|| cPerio2 })
TRCell():New(oSection1, aFiltro[1][3]	        ,/*Tabela*/,aFiltro[1][3]	,PesqPict("SD2","D2_TOTAL")		,TamSX3("D2_TOTAL")[1]	,/*lPixel*/,{|| cPerio1 })
TRCell():New(oSection1, "Media"			        ,/*Tabela*/,"Media"			,PesqPict("SD2","D2_TOTAL")		,TamSX3("D2_TOTAL")[1]	,/*lPixel*/,{|| cMedia  })
                                                                               
oBreak2 := TRBreak():New( oSection1,oSection1:Cell("Supervisor"),"TOTAL SUPERVISOR")
TRFunction():New(oSection1:Cell(aFiltro[6][3]), ,"SUM", oBreak2,,,,.F.,.T.)               
TRFunction():New(oSection1:Cell(aFiltro[5][3]), ,"SUM", oBreak2,,,,.F.,.T.)               
TRFunction():New(oSection1:Cell(aFiltro[4][3]), ,"SUM", oBreak2,,,,.F.,.T.)               
TRFunction():New(oSection1:Cell(aFiltro[3][3]), ,"SUM", oBreak2,,,,.F.,.T.)               
TRFunction():New(oSection1:Cell(aFiltro[2][3]), ,"SUM", oBreak2,,,,.F.,.T.)               
TRFunction():New(oSection1:Cell(aFiltro[1][3]), ,"SUM", oBreak2,,,,.F.,.T.)         

oBreak2 := TRBreak():New( oSection1,oSection1:Cell("Gerente"),"TOTAL GERENTE")
TRFunction():New(oSection1:Cell(aFiltro[6][3]), ,"SUM", oBreak2,,,,.F.,.F.)               
TRFunction():New(oSection1:Cell(aFiltro[5][3]), ,"SUM", oBreak2,,,,.F.,.F.)               
TRFunction():New(oSection1:Cell(aFiltro[4][3]), ,"SUM", oBreak2,,,,.F.,.F.)               
TRFunction():New(oSection1:Cell(aFiltro[3][3]), ,"SUM", oBreak2,,,,.F.,.F.)               
TRFunction():New(oSection1:Cell(aFiltro[2][3]), ,"SUM", oBreak2,,,,.F.,.F.)               
TRFunction():New(oSection1:Cell(aFiltro[1][3]), ,"SUM", oBreak2,,,,.F.,.F.)

Return oReport
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ReportPrin³ Autor ³B4B 		            ³ Data ³28/01/2012³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Acerta o arquivo de perguntas                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ReportPrint(oReport)

Local oSection1 := oReport:Section(1)

Private aDados  := {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Filtra dados    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Processa({|| AbrirQuery("TSQL"), "Filtrando Registros, aguarde..." })

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicia SECAO 1  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oSection1:Init()
oReport:IncMeter()  

                               
cVend   := ""          
cGerente:= "" 
cSupervi:= ""

dbSelectArea("SA3")
dbSetOrder(1)

For nElem := 1 To Len(aDados)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³trata nome do vendedor³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Alltrim(cVend) == Alltrim(aDados[nElem][7])
		oSection1:Cell("Vendedor"):lVisible := .F.
		oSection1:Cell("NomVend"):lVisible := .F.
		oSection1:Cell("Gerente"):lVisible := .F.
		oSection1:Cell("Supervisor"):lVisible := .F.
	Else		
		oSection1:Cell("Vendedor"):lVisible := .T.
		oSection1:Cell("NomVend"):lVisible := .T.
		oSection1:Cell("Gerente"):lVisible := .T.
		oSection1:Cell("Supervisor"):lVisible := .T.
	EndIf 		
	            		       
	cGerente := Alltrim(aDados[nElem][9]) +"-"+ GetAdvFval('SA3','A3_NREDUZ',xFilial("SA3")+aDados[nElem][9],1)
	cSupervi := Alltrim(aDados[nElem][10]) +"-"+ GetAdvFval('SA3','A3_NREDUZ',xFilial("SA3")+aDados[nElem][10],1)
	cFilVen  := "" // ??? Verificar campo do vendedor
	cNoVend  := aDados[nElem][8]
	cVend    := aDados[nElem][7]
	nAux	 := 0 
	nFator   := 0
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Periodo de faturamento ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cPerio1 := aDados[nElem][1][2]
	cPerio2 := aDados[nElem][2][2]
	cPerio3 := aDados[nElem][3][2]
	cPerio4 := aDados[nElem][4][2]
	cPerio5 := aDados[nElem][5][2]
	cPerio6 := aDados[nElem][6][2]
	
	For nMedia := 1 To 6
		If aDados[nElem][nMedia][2] > 0			
			nAux += aDados[nElem][nMedia][2]
			nFator++
		EndIf	
	next nMedia     
	
	cMedia := Round(nAux/nFator,2)
	
	If oReport:Cancel()
		Exit
	EndIf
	oSection1:PrintLine()
	
Next nElem

oSection1:Finish()

Return
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³AjustaSX1 ³ Autor ³B4B 		            ³ Data ³28/01/2012³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Acerta o arquivo de perguntas                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function AjustaSx1()

Local aArea := GetArea()
Local aHelp	:= {}

Aadd( aHelp, "Data de Referência: O usuário deve informar a data de referência" )
Aadd( aHelp, "e o sistema deve exibir o relatório através da data de referência" )
Aadd( aHelp, "retroagindo 6 meses." )
PutSx1(cPerg,"01","Data Referencia       ?","","","mv_ch1","D",8,0,0,"G","","","","","mv_par01","","","","","","","","","","","","","","","","",aHelp,aHelp,aHelp)

aHelp	:= {}
Aadd( aHelp, "possibilitar extrair relatório separando a empresa 01 Eletromega (Filiais SP e PR)" )
Aadd( aHelp, "OuroLux (Matriz) ou agrupando as empresas e filiais. (Por default o relatório será agrupado)." )
PutSx1(cPerg,"02","Agrupar Empresas?"  ,"Agrupar Empresas?    ","Agrupar Empresas?","mv_ch2","N",1,0,2,"C","","","","","mv_par02","Sim"     ,"Si"     ,"Yes"   ,"","Nao"            ,"No"                  ,"No"                         ,"","","","","","","","","",aHelp,aHelp,aHelp)

aHelp	:= {}
Aadd( aHelp, "Gera duplicata (TES): Sim, Não e Ambos." )
PutSx1(cPerg,"03","Gera duplicata?" ,"Gera duplicata?    ","Gera duplicata?","mv_ch3","N",1,0,2,"C","","","","","mv_par03","Sim","Si","Yes","","Nao","No","No","","Ambos","Ambos","Ambos","","","","","",aHelp,aHelp,aHelp)

aHelp	:= {}
Aadd( aHelp, "escolher faixa de gerentes Ex: XXXX - YYYY ou" )
Aadd( aHelp, "escolher gerentes específicos como por Ex:" )
Aadd( aHelp, " Ex: XXX;YYY;AAA" )
PutSx1(cPerg,"04","Gerente      ?","","","mv_ch4","C",99,00,0,"G","","SA3","","","mv_par04","","","","","", "","","","","","","","","","","",aHelp,aHelp,aHelp)

aHelp	:= {}
Aadd( aHelp, "escolher faixa de Supervisor Ex: XXXX - YYYY ou" )
Aadd( aHelp, "escolher Supervisor específicos como por" )
Aadd( aHelp, " Ex: XXX;YYY;AAA" )
PutSx1(cPerg,"05","Supervisor      ?","","","mv_ch5","C",99,00,0,"G","","SA3","","","mv_par05","","","","","", "","","","","","","","","","","",aHelp,aHelp,aHelp)

aHelp	:= {}
Aadd( aHelp, "escolher faixa de Vendedor Ex: XXXX - YYYY ou" )
Aadd( aHelp, "escolher Vendedor específicos como por Ex:" )
Aadd( aHelp, " Ex: XXX;YYY;AAA" )
PutSx1(cPerg,"06","Vendedor      ?","","","mv_ch6","C",99,00,0,"G","","SA3","","","mv_par06","","","","","", "","","","","","","","","","","",aHelp,aHelp,aHelp)

RestArea(aArea)

Return
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³AbrirQuery³ Autor ³ Desenvolvimento B4B   ³ Data ³ 28/01/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ RELATÓRIO DE FATURAMENTO X VENDEDOR 			              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ B4B - R4 	                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function AbrirQuery(cAlias)

Local cQuery   	  := ""
Local cDescMes 	  := ""
Local dIniMes  	  := ""
Local dFimMes  	  := ""
Local nPos     	  := 0
Local nLinha   	  := 0
Local nPosPeriodo := 0
Local cFiltro     := ""
Local aEmpresa    := {}
Local nQuant      := 0
Local cUserFil    := GetNewPar("MV_XFILUSR","")
Local cFilFilial  := ""
Local oOK	      := LoadBitmap( GetResources(), "LBOK" )
Local oNO	      := LoadBitmap( GetResources(), "LBNO" ) 
Local aBotoes     := {}
Local NOPCX       := 0

aFiltro  := CALCDATA()
dDataIni := aFiltro[Len(aFiltro)][1]
dDataFim := aFiltro[1][2] 

If MV_PAR02 == 1 //Sim
	
	aAreaSM0 := SM0->(GetArea())
	
	dbSelectArea("SM0")
	SM0->(DbGotop())
	
	While SM0->(!Eof())
		
		If aScan(aEmpresa, SM0->M0_CODIGO ) == 0
			AADD( aEmpresa, SM0->M0_CODIGO )
		EndIf
		
		SM0->(DbSkip())
	EndDo
	
	RestArea(aAreaSM0)
Else
	
	CCADASTRO  := "Selecao de filiais"
	oDLG1Marc  := Nil
	oLbx	   := Nil
	aDados     := {}
	
	dbSelectArea("SM0")
	SM0->(DbGotop())
	While !SM0->(Eof())
		
		AADD(aDados, {.T., SM0->M0_CODIGO, SM0->M0_CODFIL, SM0->M0_FILIAL, SM0->M0_NOME, SM0->M0_NOMECOM })
		SM0->(DbSkip())
		
	EndDo
	
	DbSelectArea("SM0")
	SM0->(DbSeek(cEmpAnt + cFilAnt))
	
	Define FONT oFnt  NAME "Arial" Size 08,10
	Define FONT oFnt2 NAME "Arial" Size 10,16 BOLD
	
	Define MsDialog oDLG1Marc Title cCadastro Of oMainWnd Pixel From 0,0 To 550,950
	
	@ 12,01 To 090,475 Of oDLG1Marc Pixel
	
	@ 20,  5  Say   "Selecione as empresas/filiais:"         	Size  150,09 	Of oDLG1Marc Pixel
	
	@ 035,01 ListBox oLbx Fields ;
	Colsizes 0,25,60,25,60 Size 475,235 Of oDLG1Marc Pixel On DBlClick ( aDados[oLbx:nAt,1] := !aDados[oLbx:nAt,1] , oLbx:Refresh(.F.) )
	
	oLbx:aHeaders := { " "     ,;
	"Cod Empresa" ,;
	"Cod Filial",;
	"Nome Filial",;
	"Nome Empresa",;
	"Razao Social"}
	
	oLbx:SetArray(aDados)
	
	oLbx:bLine  := { || {If(aDados[oLbx:nAt,1],oOK,oNO)	,;
	aDados[oLbx:nAt,2]   					    ,;
	aDados[oLbx:nAt,3]							,;
	aDados[oLbx:nAt,4]							,;
	aDados[oLbx:nAt,5]							,;
	aDados[oLbx:nAt,6]							}}
	
	Activate MsDialog oDLG1Marc Center On Init EnchoiceBar(oDLG1Marc,{|| oDLG1Marc:End(), nOpcx := 1 },{|| oDLG1Marc:End() },,aBotoes)
	
	If nOpcx <> 1
		Return()
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Montar array com as empresas / filiais selecionadas³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cFilFilial := ""
	For i:= 1 to len(aDados)
		If aDados[i][1]
			cFilFilial += aDados[i][3] + ";"
			If aScan(aEmpresa, aDados[i][2] ) == 0
				AADD( aEmpresa, aDados[i][2] )
			EndIf
		EndIF
	Next i
	
EndIf


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica o nivel de usuario³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cFiltro := NivelUsr()
aDados:={}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Cria filtro no relatório    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cQuery := " SELECT PERIOD,  "
cQuery += "         SUM( VAL_LIQ ) AS VAL_LIQ,  "
cQuery += "         VEND1, "
cQuery += " 		NOM_VEND, "
cQuery += " 		GERENTE, "
cQuery += " 		SUPERVI "
cQuery += " FROM   ( "

For nEmp := 1 To Len(aEmpresa)  
	
	cQuery += " 		SELECT Substring(F2_EMISSAO, 1, 6)             AS PERIOD, "
	cQuery += "                D2_TOTAL                                AS VAL_LIQ, "
	cQuery += "                F2_VEND1                                AS VEND1, "
	cQuery += "  			   ISNULL(A3_NREDUZ,'')  					   AS NOM_VEND,  "
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Gerente 					   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cQuery += "  			   ISNULL( (SELECT A3_COD  "
	cQuery += "  			   			 FROM "+RetSqlName("SA3")+" GER "
	cQuery += "  			   			 WHERE GER.A3_COD = SA3.A3_GEREN ),'')     AS GERENTE, "
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Supervidor 				   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cQuery += "  			   ISNULL( (SELECT A3_COD
	cQuery += "  			   FROM "+RetSqlName("SA3")+" SUP
	cQuery += "  			   WHERE SUP.A3_COD = SA3.A3_SUPER ),'')     AS SUPERVI
	
	/*cQuery += "                Isnull((SELECT SUM(D1_CUSTO) "
	cQuery += "                        FROM   SD1"+aEmpresa[nEmp]+"0 SD1 "
	cQuery += "                               LEFT JOIN "+RetSqlName("SF4")+" DEV "
	cQuery += "                                 ON ( F4_CODIGO = D1_TES " 
	cQuery += "                                      AND SF4.D_E_L_E_T_ <> '*' ) "
	
	cQuery += "                        WHERE  SD1.D_E_L_E_T_ <> '*' "
	cQuery += "                               AND D1_DTDIGIT BETWEEN '"+DTOS(dDataIni)+"' AND '"+DTOS(dDataFim)+"' "
	cQuery += "                               AND D1_NFORI = D2_DOC "
	cQuery += "                               AND D1_SERIORI = D2_SERIE "
	cQuery += "                               AND D1_ITEMORI = D2_ITEM  "
	cQuery += "                               AND D1_FILIAL  = D2_FILIAL "	
	cQuery += "                               AND D1_TIPO = 'D' "
	cQuery += "                               AND F4_DUPLIC = 'S'), 0) AS DEVOL "*/
	cQuery += "         FROM   SF2"+aEmpresa[nEmp]+"0 SF2 "
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Link com as tabelas 		   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cQuery += "                LEFT JOIN SD2"+aEmpresa[nEmp]+"0 SD2 "
	cQuery += "                  ON ( D2_DOC = F2_DOC "
	cQuery += "                       AND D2_SERIE = F2_SERIE "
	cQuery += "                       AND D2_FILIAL = F2_FILIAL "
	cQuery += "                       AND SD2.D_E_L_E_T_ <> '*' ) "
	cQuery += "                LEFT JOIN SF4"+aEmpresa[nEmp]+"0 SF4 "
	cQuery += "                  ON ( F4_CODIGO = D2_TES "
	cQuery += "                       AND SF4.D_E_L_E_T_ <> '*' ) "
	cQuery += "             	LEFT JOIN "+RetSqlName("SA3")+" SA3  "
	cQuery += "                  ON ( A3_COD = F2_VEND1 "
	cQuery += "                       AND SA3.D_E_L_E_T_ <> '*' )  "
	
	cQuery += "         WHERE  "
	cQuery += "                SF2.F2_EMISSAO BETWEEN '"+DTOS(dDataIni)+"' AND '"+DTOS(dDataFim)+"' "
	cQuery += "                AND SF2.F2_TIPO = 'N' "
	cQuery += "                AND SF2.D_E_L_E_T_ <> '*' "

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Filtra filial				³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	If MV_PAR02 == 2 
		cQuery += " AND F2_FILIAL IN " + FormatIn(cFilFilial,";")			
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Se for administrador tudo					   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !__cUserId $ cUserFil //.And. !UPPER(cUserName) $ UPPER(cUserFil)
		cQuery += " 		   	   AND F2_VEND1 IN " + FormatIn(Alltrim(cFiltro),";")
	EndIf	
	
	If MV_PAR03 == 1 //Sim
		cQuery += "                AND F4_DUPLIC = 'S' "
	ElseIf MV_PAR03 == 2//Nao
		cQuery += "                AND F4_DUPLIC = 'N'  "
	EndIf
	
	If nEmp < Len(aEmpresa)
		cQuery += " UNION ALL "
	EndIf
	
Next nEmp

cQuery += "                ) AS TRB "
cQuery += " GROUP  BY PERIOD, "
cQuery += "  		  VEND1, "
cQuery += " 		  NOM_VEND, "
cQuery += "           GERENTE, "
cQuery += " 		  SUPERVI "
cQuery += "ORDER BY PERIOD, GERENTE, SUPERVI, VEND1 "

//Aviso("cQryMesAnt",cQuery,{"Ok"},3)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Executa a query para obter os dados                                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Select("TSQL") <> 0
	dbSelectArea("TSQL")
	TSQL->(DbCloseArea())
Endif

DbUseArea( .T., "TOPCONN", TCGenQry( ,,cQuery ), "TSQL", .F., .T. )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria arquivo de trabalho                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aCampos := {}
AADD(aCampos,{ "PERIOD"   ,"C",6,0 } )

aTam:=TamSX3("A3_COD")
AADD(aCampos,{ "VEND1"    ,"C",aTam[1],aTam[2] } )
AADD(aCampos,{ "GERENTE"  ,"C",aTam[1],aTam[2] } )
AADD(aCampos,{ "SUPERVI"  ,"C",aTam[1],aTam[2] } )

aTam:=TamSX3("A3_NOME")
AADD(aCampos,{ "NOM_VEND"    ,"C",aTam[1],aTam[2] } )

aTam:=TamSX3("F2_VALFAT")
AADD(aCampos,{ "VAL_LIQ" ,"N",aTam[1],aTam[2] } )

cNomArq 	:= CriaTrab(aCampos,.T.)
dbUseArea( .T.,, cNomArq,"TRB", .T. , .F. )
cNomArq1 := Subs(cNomArq,1,7)+"A"                                                                                            
cNomArq2 := Subs(cNomArq,1,7)+"B"

IndRegua("TRB",cNomArq2,"PERIOD+VEND1",,,"Selecionando Registros...")

dbClearIndex()
dbSetIndex(cNomArq2+OrdBagExt())

dbSelectArea("TSQL")
TSQL->(dbGotop())
         
nRegs := 0
Count to nRegs 
ProcRegua(nRegs)

TSQL->(dbGotop())

While TSQL->(!Eof())

	IncProc("Criando tabela temporaria, aguarde..." )
	
	dbSelectArea("TRB")
	dbSetOrder(1)
	
	TRB->(RecLock("TRB",.T.))
	TRB->PERIOD   := TSQL->PERIOD
	TRB->VEND1    := TSQL->VEND1
	TRB->NOM_VEND := TSQL->NOM_VEND
	TRB->GERENTE  := TSQL->GERENTE
	TRB->SUPERVI  := TSQL->SUPERVI
	TRB->VAL_LIQ  := TSQL->VAL_LIQ
	
	TRB->(MsUnLock())

	TSQL->(dbSkip())
EndDo
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ considera devolução				                                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cQuery := " SELECT PERIOD,  "
cQuery += "        FORNECE, "
cQuery += "        LOJA, "
cQuery += "        FILIAL, "
cQuery += "        NFORI, "
cQuery += "        SERIORI, "
cQuery += "        VEND1, "
cQuery += "        SUM( VAL_LIQ ) AS VAL_LIQ  "
cQuery += " FROM   ( "

For nEmp := 1 To Len(aEmpresa)  
	
	cQuery += " 		SELECT Substring(D1_DTDIGIT, 1, 6)         AS PERIOD, "
	cQuery += "                D1_FORNECE		   		           AS FORNECE, "
	cQuery += "                D1_LOJA			   		           AS LOJA, "
	cQuery += "                ( D1_TOTAL - D1_VALDESC)            AS VAL_LIQ, "		
	cQuery += "                D1_FILIAL		   		           AS FILIAL, "
	cQuery += "                D1_NFORI			   		           AS NFORI, "
	cQuery += "                D1_SERIORI			   		       AS SERIORI, "
	cQuery += "                ISNULL(F2_VEND1,'')	   		       AS VEND1 "	
	cQuery += "         FROM   SD1"+aEmpresa[nEmp]+"0 SD1 "
	cQuery += "                LEFT JOIN SF4"+aEmpresa[nEmp]+"0 SF4 "
	cQuery += "                  ON ( F4_CODIGO = D1_TES "
	cQuery += "                       AND SF4.D_E_L_E_T_ <> '*' ) "	
	cQuery += "                LEFT JOIN SF2"+aEmpresa[nEmp]+"0 SF2 "
	cQuery += "                  ON ( F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA = D1_FILIAL+D1_NFORI+D1_SERIORI+D1_FORNECE+D1_LOJA "
	cQuery += "                       AND SF2.D_E_L_E_T_ <> '*' ) "		
	cQuery += "         WHERE  "
	cQuery += "                SD1.D1_DTDIGIT BETWEEN '"+DTOS(dDataIni)+"' AND '"+DTOS(dDataFim)+"' "
	//cQuery += "                SD1.D1_DTDIGIT BETWEEN '20111201' AND '20111231' "	
	cQuery += "                AND SD1.D1_TIPO = 'D' "
	cQuery += "                AND SD1.D_E_L_E_T_ <> '*' "	                                            	
	cQuery += "                AND F4_DUPLIC = 'S' "
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Filtra filial				³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	If MV_PAR02 == 2 
		cQuery += " AND D1_FILIAL IN " + FormatIn(cFilFilial,";")			
	EndIf
	                          	
	If nEmp < Len(aEmpresa)
		cQuery += " UNION ALL "
	EndIf
	
Next nEmp

cQuery += "                ) AS TRB "  
cQuery += " GROUP  BY FILIAL, "
cQuery += "			  PERIOD, "        
cQuery += "  		  FORNECE, "
cQuery += "  		  LOJA, "
cQuery += "  		  NFORI, "
cQuery += "  		  SERIORI, "
cQuery += "  		  VEND1 "
cQuery += "ORDER BY PERIOD, FORNECE "

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Executa a query para obter os dados                                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Select("TDEV") <> 0
	dbSelectArea("TDEV")
	TDEV->(DbCloseArea())
Endif

DbUseArea( .T., "TOPCONN", TCGenQry( ,,cQuery ), "TDEV", .F., .T. )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Faz o abatimneto das devoluções		                                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("TDEV")
TDEV->(dbGotop())                                                                           

nDev := 0
Count to nDev
ProcRegua(nDev)

TDEV->(dbGotop())

While TDEV->(!Eof())
	
	IncProc("Calculando devolucoes, aguarde..." )
	
	dbSelectArea("SA1")
	dbSetorder(1)
	MsSeek(xFilial("SA1")+TDEV->(FORNECE+LOJA))
	
	dbSelectArea("SA3")
	dbSetorder(1)
	If MsSeek(xFilial("SA3")+TDEV->VEND1)	
			
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Se for administrador tudo					   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !__cUserId $ cUserFil //.And. !UPPER(cUserName) $ UPPER(cUserFil)
			If TDEV->VEND1 $  FormatIn(Alltrim(cFiltro),"/")
				TRB->(RecLock("TRB",.T.))
				TRB->PERIOD   := TDEV->PERIOD
				TRB->VEND1    := SA3->A3_COD 
				TRB->NOM_VEND := SA3->A3_NOME
				TRB->GERENTE  := SA3->A3_GEREN
				TRB->SUPERVI  := SA3->A3_SUPER
				TRB->VAL_LIQ  := ( TDEV->VAL_LIQ *-1 )
				TRB->(MsUnLock())		
			EndIf
		Else
			TRB->(RecLock("TRB",.T.))
			TRB->PERIOD   := TDEV->PERIOD
			TRB->VEND1    := SA3->A3_COD 
			TRB->NOM_VEND := SA3->A3_NOME
			TRB->GERENTE  := SA3->A3_GEREN
			TRB->SUPERVI  := SA3->A3_SUPER
			TRB->VAL_LIQ  := ( TDEV->VAL_LIQ *-1 )
			TRB->(MsUnLock())					
		EndIf			

	EndIf 
		
	TDEV->(dbSkip())
EndDo 

dbSelectArea("TRB")
TRB->(dbGotop())
dbSetOrder(1)

ProcRegua(nRegs)


While TRB->(!Eof())     
	
    nQuant++
	IncProc("Filtrando Registros, aguarde... "  + StrZero(nQuant,6) )
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Se for administrador tudo					   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//If __cUserId $ cUserFil //.Or. UPPER(cUserName) $ UPPER(cUserFil)
	
		dbSelectArea("SA3")
		dbSetorder(1)
		MsSeek(xFilial("SA3")+TRB->VEND1)
	              
		If !Empty(MV_PAR04) //Filtro por gerente
			If "-" $ Alltrim(MV_PAR04)
				If !(SA3->A3_GEREN  >= Substr(MV_PAR04,1,6) .And.  SA3->A3_GEREN <= Substr(MV_PAR04,8,6))
					TRB->(dbSkip())
					Loop
				EndIf
			Else
				If !Alltrim(SA3->A3_GEREN) $ Alltrim(MV_PAR04)
					TRB->(dbSkip())
					Loop
				EndIf
				
			EndIf
		EndIf	
		
		If !Empty(MV_PAR05) //Filtro por supervidor
			If "-" $ Alltrim(MV_PAR05)
				If !(SA3->A3_SUPER >= Substr(MV_PAR05,1,6) .And.  SA3->A3_SUPER <= Substr(MV_PAR05,8,6))
					TRB->(dbSkip())
					Loop
				EndIf
			Else
				If !Alltrim(SA3->A3_SUPER) $ Alltrim(MV_PAR05)
					TRB->(dbSkip())
					Loop
				EndIf
				
			EndIf
		EndIf	 
		
		If !Empty(MV_PAR06) //Filtro por gerente
			If "-" $ Alltrim(MV_PAR06)
				If !(TRB->VEND1 >= Substr(MV_PAR06,1,6) .And.  TRB->VEND1 <= Substr(MV_PAR06,8,6))
					TRB->(dbSkip())
					Loop
				EndIf
			Else
				If !Alltrim(TRB->VEND1) $ Alltrim(MV_PAR06)
					TRB->(dbSkip())
					Loop
				EndIf
				
			EndIf
		EndIf	
	
	//EndIf 
		
	nPos := aScan(aDados, { |x| x[7] == TRB->(VEND1) } )
	
	If nPos == 0
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Inicia saldo dos peridos zerados 									 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		AADD( aDados, {	{SUBSTR(DTOS(aFiltro[1][1]),1,6), 0 } ,;
		{ SUBSTR(DTOS(aFiltro[2][1]),1,6), 0 },;
		{ SUBSTR(DTOS(aFiltro[3][1]),1,6), 0 },;
		{ SUBSTR(DTOS(aFiltro[4][1]),1,6), 0 },;
		{ SUBSTR(DTOS(aFiltro[5][1]),1,6), 0 },;
		{ SUBSTR(DTOS(aFiltro[6][1]),1,6), 0 },;
		TRB->VEND1,;
		TRB->NOM_VEND,;
		TRB->GERENTE,;
		TRB->SUPERVI } )
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica qual periodo da temporaria, para encontrar a posição do array³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nPosPeriodo := 0
		For nElem := 1 To 6
			If SUBSTR(DTOS(aFiltro[nElem][1]),1,6) == TRB->PERIOD
				nPosPeriodo := nElem
				Exit
			EndIf
		Next nElem
		
		If nPosPeriodo > 0
			aDados[Len(aDados)][nPosPeriodo][2] += TRB->VAL_LIQ
		EndIf
		
	Else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica qual periodo da temporaria, para encontrar a posição do array³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nPosPeriodo := 0
		For nElem := 1 To 6
			If SUBSTR(DTOS(aFiltro[nElem][1]),1,6) == TRB->PERIOD
				nPosPeriodo := nElem
				Exit
			EndIf
		Next nElem
		
		If nPosPeriodo > 0
			aDados[nPos][nPosPeriodo][2] += TRB->VAL_LIQ
		EndIf
		
	EndIf
	
	TRB->(dbSkip())
EndDo

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Ordena Matriz    		   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ASort(aDados,,,{|x,y| x[9]+x[10]+x[7] < y[9]+y[10]+y[7] })

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Exclui tabela temporaria	   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea( "TRB" )
dbCloseArea()
fErase(cNomArq+GetDBExtension())
fErase(cNomArq1+OrdBagExt())
fErase(cNomArq2+OrdBagExt())

Return
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³CALCDATA  ³ Autor ³ Desenvolvimento B4B   ³ Data ³ 28/01/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ RELATÓRIO DE FATURAMENTO X VENDEDOR 			              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ B4B - R4 	                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function CALCDATA()

Local aFiltro  := {}
Local aMeses   := {"JAN","FEV","MAR","ABR","MAI","JUN","JUL","AGO","SET","OUT","NOV","DEZ"}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Calcula dos meses anteriores³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dIniMes := FirstDay(FirstDay(MV_PAR01) )
dFimMes := LastDay(dIniMes)
nCodMes   := Val(Substr(Dtos(dIniMes),5,2))
cDescMes   := aMeses[nCodMes] +"/"+Alltrim(Str(Year(dIniMes)))

AADD( aFiltro, {dIniMes, dFimMes, cDescMes} )

For nElem := 1 To 5
	
	dIniMes   := FirstDay(FirstDay(dIniMes) - nElem )
	dFimMes   := LastDay(dIniMes)
	nCodMes   := Val(Substr(Dtos(dIniMes),5,2))
	cDescMes  := aMeses[nCodMes] +"/"+ Alltrim(Str(Year(dIniMes)))
	
	AADD( aFiltro, {dIniMes, dFimMes, cDescMes} )
	
Next nElem

Return aFiltro
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³NivelUsr  ³ Autor ³ Desenvolvimento B4B   ³ Data ³ 28/01/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Atualiza variaveis private com nivel de usuario            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ B4B - R4 	                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function NivelUsr()

Local cUsrRel := ""
Local cFiltro := ""
Local cReturn := ""

dbSelectArea("SA3")
dbSetOrder(7)
If MsSeek(xFilial("SA3")+__cUserId)
	cUsrRel := SA3->A3_COD
EndIf

cFiltro := " SELECT A3_COD, A3_SUPER FROM "+RetSqlName("SA3")+" WHERE A3_GEREN = '"+cUsrRel+"' AND D_E_L_E_T_ <> '*' "

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Executa a query para obter os dados                                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Select("TFIL") > 0
	TFIL->(dbCloseArea())
EndIf

DbUseArea( .T., "TOPCONN", TCGenQry( ,,cFiltro ), "TFIL", .F., .T. )

//If TFIL->(!Eof())

	While TFIL->(!Eof())
		
		If !Empty(MV_PAR05) //Filtro por supervidor
			If "-" $ Alltrim(MV_PAR05)
				If !(TFIL->A3_SUPER >= Substr(MV_PAR05,1,6) .And.  TFIL->A3_SUPER <= Substr(MV_PAR05,8,6))
					TFIL->(dbSkip())
					Loop
				EndIf
			Else
				If !Alltrim(TFIL->A3_SUPER) $ Alltrim(MV_PAR05)
					TFIL->(dbSkip())
					Loop
				EndIf
				
			EndIf
		EndIf
		
		If !Empty(MV_PAR06) //Filtro por vendedor
			If "-" $ Alltrim(MV_PAR06)
				If !(TFIL->A3_COD >= Substr(MV_PAR06,1,6) .And.  TFIL->A3_COD <= Substr(MV_PAR06,8,6))
					TFIL->(dbSkip())
					Loop
				EndIf
			Else
				If !Alltrim(TFIL->A3_COD) $ Alltrim(MV_PAR06)
					TFIL->(dbSkip())
					Loop
				EndIf
				
			EndIf
		EndIf
		
		If Empty(cReturn)
			cReturn := TFIL->A3_COD + ";"
		Else
			cReturn += TFIL->A3_COD + ";"
		EndIf
		
		TFIL->(dbSkip())
	EndDo
//Else
	
	cFiltro := " SELECT A3_COD FROM "+RetSqlName("SA3")+" WHERE A3_SUPER = '"+cUsrRel+"' AND D_E_L_E_T_ <> '*' "
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Executa a query para obter os dados                                                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Select("TFIL") > 0
		TFIL->(dbCloseArea())
	EndIf
	
	DbUseArea( .T., "TOPCONN", TCGenQry( ,,cFiltro ), "TFIL", .F., .T. )
	
	If TFIL->(!Eof())

		While TFIL->(!Eof())
			
			If !Empty(MV_PAR06) //Filtro por vendedor
				If "-" $ Alltrim(MV_PAR06)
					If !(TFIL->A3_COD >= Substr(MV_PAR06,1,6) .And.  TFIL->A3_COD <= Substr(MV_PAR06,8,6))
						TFIL->(dbSkip())
						Loop
					EndIf
				Else
					If !Alltrim(TFIL->A3_COD) $ Alltrim(MV_PAR06)
						TFIL->(dbSkip())
						Loop
					EndIf
					
				EndIf
			EndIf
			
			If Empty(cReturn)
				cReturn := TFIL->A3_COD + ";"
			Else
				cReturn += TFIL->A3_COD + ";"
			EndIf
			
			TFIL->(dbSkip())
		EndDo

	EndIf
	
//EndIf

If Empty(cReturn)
	lVendedor := .T.
	cReturn   := SA3->A3_COD //Classificado como vendedor
EndIf		

Return cReturn