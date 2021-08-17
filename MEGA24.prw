#INCLUDE "PROTHEUS.CH"
#INCLUDE "MATR240.CH"
#INCLUDE "REPORT.CH"
#INCLUDE "TOPCONN.CH"

/*--------------------------------------------------------|
| Autor | Claudino Domingues              | Data 02/10/12 | 
|---------------------------------------------------------|
| Função: MEGA24	                                      |
|---------------------------------------------------------|
| Relatório que faz a Emissão da Quantidade Atual em      |
| Estoque e calcula a Cubagem.              	          |
----------------------------------------------------------*/

User Function MEGA24()

Local oReport

oReport := ReportDef()
oReport:PrintDialog() // Imprime os dados na Tela(Preview).

Return

Static Function ReportDef()

Local oReport  // Objeto principal do Relatório TReport.
Local oSection // Objeto da Seção. 
Local oBreak   // Objeto da Quebra(Sub Total Produto(Cubagem)).
Local oTotal   // Objeto do Total Geral(Soma dos Sub Totais Produto(Cubagem)).
Local cPerg  := PADR("MEGA24",10) // Grupo de Perguntas.

CriaSX1(cPerg) // Função que faz a criação do Pergunta na SX1 atraves do PUTSX1.
Pergunte(cPerg,.F.) // Caso o parametro esteja como .T. o sistema ira apresentar a tela de perguntas antes que abrir a tela configuração do relatório.

// Apresenta a tela de impressão para o usuário configurar o relatório.
oReport:=TReport():New("MEGA24","MEGA24 - Emissão de Saldo em Estoque com Cubagem","MEGA24",{|oReport| PrintReport(oReport,oSection,cPerg)},"Emissão de Saldo em Estoque com Cubagem")

oSection:=TRSection():New(oReport,"MEGA24 - Emissão de Saldo em Estoque com Cubagem",{"SB1"})
oSection:SetTotalInLine(.T.) // Define se os totalizadores da sessão serão impressos em linha ou coluna.

TRCell():New(oSection ,"CODPROD"  ,/*Alias*/,"Codigo.Prod" ,/*Picture*/         ,15 /*Tamanho*/,/*lPixel*/,/*{|| code-black de impressão}*/,,,"LEFT")
TRCell():New(oSection ,"DESCPROD" ,/*Alias*/,"Desc.Prod"   ,/*Picture*/         ,50 /*Tamanho*/,/*lPixel*/,/*{|| code-black de impressão}*/,,,"LEFT")
TRCell():New(oSection ,"FILIAL"   ,/*Alias*/,"Filial"      ,/*Picture*/         ,02 /*Tamanho*/,/*lPixel*/,/*{|| code-black de impressão}*/,,,"LEFT")
TRCell():New(oSection ,"LOCAL"    ,/*Alias*/,"Armazem"     ,/*Picture*/         ,02 /*Tamanho*/,/*lPixel*/,/*{|| code-black de impressão}*/,,,"LEFT")
TRCell():New(oSection ,"SALDATU"  ,/*Alias*/,"Saldo.Atu"   ,"@E 999,999,999.99" ,18 /*Tamanho*/,/*lPixel*/,/*{|| code-black de impressão}*/,,,"RIGHT")
TRCell():New(oSection ,"CUBAGEM"  ,/*Alias*/,"Cubagem"     ,/*Picture*/         ,18 /*Tamanho*/,/*lPixel*/,/*{|| code-black de impressão}*/,,,"RIGHT")

oBreak:=TRBreak():New(oSection,oSection:Cell("CODPROD"),"Sub Total Produto",.F.) // Quebra por Produto.
oTotal:=TRFunction():New(oSection:Cell("CUBAGEM"),NIL,"SUM",oBreak,/*Titulo*/,/*cPicture*/,/*uFormula*/,.F./*Total da Seção*/,.T./*Total Geral*/,.F./*Total da Pagina*/)

oSection:SetNoFilter("SB1") // Retira o filtro interno do TREPORT na tabela.

Return oReport

Static Function PrintReport(oReport,oSection,cPerg)

/*---------------------------------------------------------|
| Variaveis Locais utilizadas na montagem das Querys       |
-----------------------------------------------------------*/
Local cQuery     := ""
Local cSelect	 := ""
Local cJoin		 := ""
Local cWhere	 := ""
Local cOrderBy   := ""
Local cGroupBy   := "" 
Local cOrder     := ""

Local nValCub    := 0               
Local nRegM0     := 0               
Local nQuant     := 0.00
Local cAlias     := GetNextAlias()
Local aFiliais   := {}

Private XSB1 := xFilial("SB1") // Retorna a Filial da tabela.
Private XSB2 := xFilial("SB2") // Retorna a Filial da tabela.
Private XSB5 := xFilial("SB5") // Retorna a Filial da tabela.

//-- Alimenta Array com Filiais a serem Pesquisadas.
nRegM0   := SM0->(Recno())
SM0->(DBSeek(cEmpAnt, .T.))
Do While !SM0->(Eof()) .And. SM0->M0_CODIGO == cEmpAnt
	If SM0->M0_CODFIL >= MV_PAR02 .And. SM0->M0_CODFIL <= MV_PAR03
		aAdd(aFiliais, SM0->M0_CODFIL)
	EndIf
	SM0->(dbSkip())
EndDo
SM0->(dbGoto(nRegM0))

/*---------------------------------------------------------|
| Transforma parametros Range em expressao SQL             |
-----------------------------------------------------------*/
MakeSqlExpr(oReport:uParam)

/*---------------------------------------------------------|
| JOIN                                                     |
-----------------------------------------------------------*/
If xSB1 # Space(2) .AND. xSB2 # Space(2)
	cJoin += "  SB1.B1_FILIAL =  SB2.B2_FILIAL AND "
EndIf
If !Empty(xSB1)
	cJoin += " SB1.B1_FILIAL >= '" + MV_PAR02 + "' AND "
	cJoin += " SB1.B1_FILIAL <= '" + MV_PAR03 + "' AND "
EndIf
cJoin += " SB1.B1_COD    = SB2.B2_COD "

/*---------------------------------------------------------|
| SELECT E ORDER BY                                        |
-----------------------------------------------------------*/
If MV_PAR01 == 1 // Aglutina por Armazem.
	cSelect += ", SB2.B2_FILIAL FILIAL, SB2.B2_LOCAL LOC"
	cOrder += ", FILIAL, LOC"
Else  // Aglutina por Filial ou por Empresa.
	cSelect += ", '**' LOC" 
	cOrder += ", LOC"
EndIf

If  MV_PAR01 == 2 // Aglutina por Filial.
	cSelect += ", SB2.B2_FILIAL FILIAL"
	cOrder += ", FILIAL"
EndIf

If MV_PAR01 == 3 // Aglutina por Empresa.
	cSelect += ", '**' FILIAL"
	cOrder += ", FILIAL"
EndIf

/*---------------------------------------------------------|
| GROUP BY                                                 |
-----------------------------------------------------------*/
If MV_PAR01 == 1 // Aglutina por Armazem.
	cGroupBy += ", SB2.B2_LOCAL, SB2.B2_FILIAL"
EndIf
If MV_PAR01 == 2 // Aglutina por Filial.
	cGroupBy += ", SB2.B2_FILIAL"
EndIf
If MV_PAR01 == 3 // Aglutina por Empresa.
	cGroupBy += " "
EndIf

cQuery := " SELECT SB2.B2_COD COD, SB1.B1_DESC DESCRI, SB5.B5_COMPR COMPRI, SB5.B5_ALTURA ALTURA, SB5.B5_LARG LARG, SUM(SB2.B2_QATU) QATU, SB1.B1_QE QUANTEMB" + cSelect 
cQuery += " FROM " +RetSqlName("SB2")+ " SB2 "
cQuery += " JOIN " +RetSqlName("SB1")+ " SB1 ON "
cQuery += cJoin
cQuery += " JOIN " +RetSqlName("SB5")+ " SB5 ON SB5.B5_COD = SB2.B2_COD "
cQuery += " WHERE SB2.B2_LOCAL >=  '" +MV_PAR04+ "' AND SB2.B2_LOCAL <=  '" +MV_PAR05+ "' "
cQuery += " AND SB2.B2_FILIAL >= '" +MV_PAR02+ "' AND SB2.B2_FILIAL <=  '" +MV_PAR03+ "' "
cQuery += " AND SB2.D_E_L_E_T_= ' ' AND SB1.D_E_L_E_T_ = ' ' AND SB5.D_E_L_E_T_ = ' ' "
cQuery += " AND SB1.B1_COD >= '" +MV_PAR06+ "' AND SB1.B1_COD <= '" +MV_PAR07+ "' "
cQuery += " GROUP BY SB2.B2_COD, SB1.B1_DESC, SB5.B5_COMPR, SB5.B5_ALTURA, SB5.B5_LARG, SB1.B1_QE " + cGroupBy
cQuery += " ORDER BY COD " + cOrder

dbUseArea(.T.,"TOPCONN",TCGenqry(,,cQuery),cAlias,.F.,.T.)

oSection:Init() // Incializa impressão.

dbSelectArea(cAlias)
(cAlias)->(dbGotop())

While (cAlias)->(!Eof())
	If oReport:Cancel()
		Exit
	EndIf
	
	nQuant := 0.00
	
	// Aglutinado por Empresa. 	
	If AllTrim((cAlias)->FILIAL) == '**'
		For nX := 1 to Len(aFiliais)
			cFilAnt := aFiliais[nX]
			If Alltrim((cAlias)->LOC) == '**'
				aArea:=GetArea()
				dbSelectArea("SB2")
				dbSetOrder(1)
				dbSeek(cFilAnt + (cAlias)->COD)
				While !Eof() .And. B2_FILIAL == cFilAnt .And. B2_COD == (cAlias)->COD
					If SB2->B2_LOCAL >= MV_PAR04 .And. SB2->B2_LOCAL <= MV_PAR05
						nQuant += SB2->B2_QATU
					EndIf
					dbSkip()
				EndDo
				RestArea(aArea)
			Else
				aArea:=GetArea()
				dbSelectArea("SB2")
				dbSetOrder(2)
				dbSeek(cFilAnt + (cAlias)->LOC + (cAlias)->COD)
				nQuant := SB2->B2_QATU
				RestArea(aArea)
			EndIf
		Next nX
	// Aglutinado por Filial ou por Armazem.
	Else
		If Alltrim((cAlias)->LOC) == '**'
			aArea:=GetArea()
			dbSelectArea("SB2")
			dbSetOrder(1)
			dbSeek(cSeek:=(cAlias)->FILIAL + (cAlias)->COD)
			While !Eof() .And. B2_FILIAL + B2_COD == cSeek
				If SB2->B2_LOCAL >= MV_PAR04 .And. SB2->B2_LOCAL <= MV_PAR05
					nQuant += SB2->B2_QATU
				EndIf
				dbSkip()
			EndDo
			RestArea(aArea)
		Else
			aArea:=GetArea()
			dbSelectArea("SB2")
			dbSetOrder(2)
			dbSeek(cSeek:=(cAlias)->FILIAL + (cAlias)->LOC + (cAlias)->COD)
			nQuant := SB2->B2_QATU
			RestArea(aArea)
		EndIf
	EndIf
	
	// Impressão do conteudo nas colunas.
	oSection:Cell("CODPROD")  :SetValue((cAlias)->COD)
	oSection:Cell("DESCPROD") :SetValue((cAlias)->DESCRI)
	oSection:Cell("FILIAL")   :SetValue((cAlias)->FILIAL)
	oSection:Cell("LOCAL")    :SetValue((cAlias)->LOC)
	oSection:Cell("SALDATU")  :SetValue(nQuant)
	                                    
	// Calculo Cubagem.
	nValCub := (nQuant / (cAlias)->QUANTEMB) * ((cAlias)->COMPRI * (cAlias)->ALTURA * (cAlias)->LARG)
	
	oSection:Cell("CUBAGEM")  :SetValue(nValCub)
	
	oSection:PrintLine()
	
	(cAlias)->(dbSkip())
EndDo

oSection:Finish()

/*---------------------------------------------------------|
| Devolve as ordens originais dos arquivos                 |
-----------------------------------------------------------*/
dbSelectArea("SB2")
dbClearFilter()
RetIndex("SB2")
dbSetOrder(1)

dbSelectArea("SB1")
dbClearFilter()
RetIndex("SB1")
dbSetOrder(1)

Return Nil

Static Function CriaSX1(cPerg)

//----------------------------------------------------------------------------------------------------------------------//
// Parametros que devem ser passados para a função de criação das perguntas no arquivo SX1.                             //
//----------------------------------------------------------------------------------------------------------------------//
//  7º Parametro -> Tipo do dado C=caractere, D=Data, N=Numerico                                                        //
// 10º Parametro -> Numero da pre-selecao                                                                               //
// 11º Parametro -> O tipo do dado sera G=Get, S=Scroll, C=Choice, R=Range                                              //
// 12º Parametro -> Sintaxe em advpl, ou funcao para validacao                                                          //
// 14º Parametro -> Nome do grupo ára SXG                                                                               //
// 15º Parametro -> Pyme                                                                                                //
// 16º Parametro -> Nome da variavel que sera utilizada no programa                                                     //
// 17º Parametro -> Primeira definicao do texto em portugues se caso o tipo do dado for choice, exemplo: SIM ou NAO     //
// 18º Parametro -> Primeira definicao do texto em espanhol se caso o tipo do dado for choice, exemplo: SI ou NO        //
// 19º Parametro -> Primeira definicao do texto em ingles se caso o tipo do dado for choice, exemplo: YES ou NO         //
// 20º Parametro -> Conteudo da ultima resposta informada no parametro se caso o tipo do dados for get                  //
// 21º Parametro -> Segunda definicao do texto em portugues se caso o tipo do dado for choice, exemplo: SIM ou NAO      //
// 22º Parametro -> Segunda definicao do texto em espanhol se caso o tipo do dado for choice, exemplo: SI ou NO         //
// 23º Parametro -> Segunda definicao do texto em ingles se caso o tipo do dado for choice, exemplo: YES ou NO          //
// 24º Parametro -> Terceira definicao do texto em portugues se caso o tipo do dado for choice, exemplo: SIM ou NAO     //
// 25º Parametro -> Terceira definicao do texto em espanhol se caso o tipo do dado for choice, exemplo: SI ou NO        //
// 26º Parametro -> Terceira definicao do texto em ingles se caso o tipo do dado for choice, exemplo: YES ou NO         //
// 27º Parametro -> Quarta definicao do texto em portugues se caso o tipo do dado for choice, exemplo: SIM ou NAO       //
// 28º Parametro -> Quarta definicao do texto em espanhol se caso o tipo do dado for choice, exemplo: SI ou NO          //
// 29º Parametro -> Quarta definicao do texto em ingles se caso o tipo do dado for choice, exemplo: YES ou NO           //
// 30º Parametro -> Quinta definicao do texto em portugues se caso o tipo do dado for choice, exemplo: SIM ou NAO       //
// 31º Parametro -> Quinta definicao do texto em espanhol se caso o tipo do dado for choice, exemplo: SI ou NO          //
// 32º Parametro -> Quinta definicao do texto em ingles se caso o tipo do dado for choice, exemplo: YES ou NO           //
// 36º Parametro -> Nome do grupo do help                                                                               //
//----------------------------------------------------------------------------------------------------------------------//

Local aHelp := {}

// Texto do help em    portugues         , ingles, espanhol
AADD(aHelp,{{ "Aglutina por "           },  {""} ,  {""}  })
AADD(aHelp,{{ "Informe Filial Inicial"  },  {""} ,  {""}  })
AADD(aHelp,{{ "Informe Filial Final"    },  {""} ,  {""}  })
AADD(aHelp,{{ "Informe Armazem Inicial" },  {""} ,  {""}  })
AADD(aHelp,{{ "Informe Armazem Final"   },  {""} ,  {""}  })
AADD(aHelp,{{ "Informe Produto Inicial" },  {""} ,  {""}  })
AADD(aHelp,{{ "Informe Produto Final"   },  {""} ,  {""}  })

//      1Grup   2Ordem   3TituloPergPortugu   4TituloPergEspanho   5TituloPergIngles     6NomeVaria     7     8Tam   9dec   10    11    12   13F3    14   15        16            17          18            19      20     21          22          23          24          25          26      27   28   29   30   31   32   33HelpPort   34HelpIngl   35HelpEsp    36

PutSX1( cPerg ,  "01"  ,  "Aglutina por ? "  ,  "Agrupa por ?  "  ,  "Group by ?     "  ,  "MV_CH1"  ,  "N"  ,  01  ,  0  ,  0  , "C" , "" , ""    , "" , "S" , "MV_PAR01" , "Armazem" , "Deposito" , "Warehouse" , "" ,"Filial" , "Sucursal" , "Branch" , "Empresa" , "Empresa" , "Company" , "" , "" , "" , "" , "" , "" , aHelp[1,1] , aHelp[1,2] , aHelp[1,3] , "" )
PutSX1( cPerg ,  "02"  ,  "Da Filial ?    "  ,  "De Producto ? "  ,  "From Product ? "  ,  "MV_CH2"  ,  "C"  ,  02  ,  0  ,  0  , "G" , "" , ""    , "" , "S" , "MV_PAR02" , ""        , ""         , ""          , "" ,""       , ""         , ""       , ""        , ""        , ""        , "" , "" , "" , "" , "" , "" , aHelp[2,1] , aHelp[2,2] , aHelp[2,3] , "" )
PutSX1( cPerg ,  "03"  ,  "Ate a Filial ? "  ,  "A Producto ?  "  ,  "To Product ?   "  ,  "MV_CH3"  ,  "C"  ,  02  ,  0  ,  0  , "G" , "" , ""    , "" , "S" , "MV_PAR03" , ""        , ""         , ""          , "" ,""       , ""         , ""       , ""        , ""        , ""        , "" , "" , "" , "" , "" , "" , aHelp[3,1] , aHelp[3,2] , aHelp[3,3] , "" )
PutSX1( cPerg ,  "04"  ,  "Do Armazem ?   "  ,  "De Producto ? "  ,  "From Product ? "  ,  "MV_CH4"  ,  "C"  ,  02  ,  0  ,  0  , "G" , "" , ""    , "" , "S" , "MV_PAR04" , ""        , ""         , ""          , "" ,""       , ""         , ""       , ""        , ""        , ""        , "" , "" , "" , "" , "" , "" , aHelp[4,1] , aHelp[4,2] , aHelp[4,3] , "" )
PutSX1( cPerg ,  "05"  ,  "Ate o Armazem ?"  ,  "A Producto ?  "  ,  "To Product ?   "  ,  "MV_CH5"  ,  "C"  ,  02  ,  0  ,  0  , "G" , "" , ""    , "" , "S" , "MV_PAR05" , ""        , ""         , ""          , "" ,""       , ""         , ""       , ""        , ""        , ""        , "" , "" , "" , "" , "" , "" , aHelp[5,1] , aHelp[5,2] , aHelp[5,3] , "" )
PutSX1( cPerg ,  "06"  ,  "Do Produto ?   "  ,  "De Producto ? "  ,  "From Product ? "  ,  "MV_CH6"  ,  "C"  ,  15  ,  0  ,  0  , "G" , "" , "SB1" , "" , "S" , "MV_PAR06" , ""        , ""         , ""          , "" ,""       , ""         , ""       , ""        , ""        , ""        , "" , "" , "" , "" , "" , "" , aHelp[6,1] , aHelp[6,2] , aHelp[6,3] , "" )
PutSX1( cPerg ,  "07"  ,  "Ate Produto ?  "  ,  "A Producto ?  "  ,  "To Product ?   "  ,  "MV_CH7"  ,  "C"  ,  15  ,  0  ,  0  , "G" , "" , "SB1" , "" , "S" , "MV_PAR07" , ""        , ""         , ""          , "" ,""       , ""         , ""       , ""        , ""        , ""        , "" , "" , "" , "" , "" , "" , aHelp[7,1] , aHelp[7,2] , aHelp[7,3] , "" )

Return(Nil)