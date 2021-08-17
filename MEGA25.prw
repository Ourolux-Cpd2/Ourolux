#INCLUDE "PROTHEUS.CH"
#INCLUDE "MATR240.CH"
#INCLUDE "REPORT.CH"
#INCLUDE "TOPCONN.CH"

/*--------------------------------------------------------|
| Autor | Claudino Domingues              | Data 03/10/12 | 
|---------------------------------------------------------|
| Função: MEGA25	                                      |
|---------------------------------------------------------|
| Relatório que faz a Emissão do Saldo Atual em Estoque   |
| para o representante.                      	          |
----------------------------------------------------------*/

User Function MEGA25()

Local oReport

oReport := ReportDef()
oReport:PrintDialog() // Imprime os dados na Tela(Preview).

Return

Static Function ReportDef()

Local oReport  // Objeto principal do Relatório TReport.
Local oSection // Objeto da Seção. 
Local cPerg  := PADR("MEGA25",10) // Grupo de Perguntas.

CriaSX1(cPerg) // Função que faz a criação do Pergunta na SX1 atraves do PUTSX1.
Pergunte(cPerg,.F.) // Caso o parametro esteja como .T. o sistema ira apresentar a tela de perguntas antes que abrir a tela configuração do relatório.

// Apresenta a tela de impressão para o usuário configurar o relatório.
oReport:=TReport():New("MEGA25","MEGA25 - Emissão de Saldo em Estoque","MEGA25",{|oReport| PrintReport(oReport,oSection)},"Emissão de Saldo em Estoque")

oReport:SetLineHeight(50)      // Define a altura da linha na impressão.
oReport:nFontBody := 10        // Tamanho da fonte definida para impressão do relatório.
oReport:lBold := .F.           // Aponta que as Informações serão impressas em negrito

oSection:=TRSection():New(oReport,"MEGA25 - Emissão de Saldo em Estoque",{"SB1"})
oSection:SetHeaderPage()       

//TRCell():New(oParent,cName,cAlias,cTitle,cPicture,nSize,lPixel,bBlock,cAlign,lLineBreak,cHeaderAlign,lCellBreak,nColSpace,lAutoSize,nClrBack,nClrFore,lBold)

TRCell():New(oSection ,"CODPROD"  ,/*Alias*/,"Codigo.Prod" ,/*Picture*/         ,15 /*Tamanho*/,/*lPixel*/,/*{|| code-black de impressão}*/,,,"LEFT")
TRCell():New(oSection ,"DESCPROD" ,/*Alias*/,"Desc.Prod"   ,/*Picture*/         ,50 /*Tamanho*/,/*lPixel*/,/*{|| code-black de impressão}*/,,,"LEFT")
TRCell():New(oSection ,"SALDATU"  ,/*Alias*/,"Saldo.Atu"   ,"@E 999,999,999.99" ,18 /*Tamanho*/,/*lPixel*/,/*{|| code-black de impressão}*/,,,"RIGHT")//,,,.T.)

oSection:SetNoFilter("SB1") // Retira o filtro interno do TREPORT na tabela.

Return oReport

//----------------------------------------------//

Static Function PrintReport(oReport,oSection)

Local nSaldAtu := 0
Local nSaldFim := 0
Local cAlias   := GetNextAlias()
Local cQuery   := ""

cQuery := " SELECT SB2.B2_COD COD , SB1.B1_DESC DESCRI, "
cQuery += " 	   SB2.B2_QATU QATU , SB2.B2_RESERVA RESERVA , "
cQuery += "		   SB2.B2_QPEDVEN QPEDVEN , SB2.B2_QEMP QEMP, "
cQuery += "		   SB2.B2_QEMPN QEMPNF , SB2.B2_QNPT PODER3 "  
cQuery += " FROM " +RetSqlName("SB2")+ " SB2 " 
cQuery += " INNER JOIN " +RetSqlName("SB1")+ " SB1"
cQuery += " ON SB1.B1_COD = SB2.B2_COD "    
cQuery += " WHERE SB2.B2_LOCAL = '01' "
cQuery += "		AND SB2.B2_FILIAL =  '" +cFilAnt+ "' "
cQuery += "		AND SB2.D_E_L_E_T_= ' ' AND SB2.B2_COD >= '" +MV_PAR01+ "' AND SB1.B1_COD <= '" +MV_PAR02+ "' "   
cQuery += "	GROUP BY SB2.B2_COD , SB1.B1_DESC , SB2.B2_QATU , SB2.B2_RESERVA , SB2.B2_QPEDVEN , SB2.B2_QEMP , SB2.B2_QEMPN , SB2.B2_QNPT "
cQuery += " ORDER BY COD "
                                         
//MEMOWRITE("E:\QUERYTESTE.SQL",cQuery)

dbUseArea(.T.,"TOPCONN",TCGenqry(,,cQuery),cAlias,.F.,.T.)

oSection:Init()

dbSelectArea(cAlias)
dbGotop()

While !Eof()

	oSection:Cell("CODPROD" ):SetValue((cAlias)->COD)
	oSection:Cell("DESCPROD"):SetValue((cAlias)->DESCRI)
	
	//nSaldAtu := (cAlias)->QATU-(cAlias)->QEMP-(cAlias)->QEMPNF-(cAlias)->PODER3
	nSaldAtu := (cAlias)->QATU-(cAlias)->RESERVA-(cAlias)->QPEDVEN-(cAlias)->QEMP-(cAlias)->QEMPNF-(cAlias)->PODER3
		
	nSaldFim := If(nSaldAtu > 5000,5000,nSaldAtu)
	
	oSection:Cell("SALDATU" ):SetValue(nSaldFim) 
	
	oSection:PrintLine()
	
	oReport:FatLine()
		
	nSaldAtu := 0
	nSaldFim := 0
	
	dbSkip()
EndDo

oSection:Finish()

Return (Nil)   
           
//----------------------------------------------//

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

// Texto do help em    portugues            , ingles, espanhol
AADD(aHelp,{{ "Informe um produto inicial" },  {""} ,  {""}  })
AADD(aHelp,{{ "Informe um produto final"   },  {""} ,  {""}  })

//      1Grup   2Ordem   3TituloPergPortugu   4TituloPergEspanho   5TituloPergIngles     6NomeVaria     7     8Tam   9dec  10    11    12   13F3    14   15        16       17   18   19   20   21   22   23   24   25   26   27   28   29   30   31   32   33HelpPort   34HelpIngl   35HelpEsp    36
PutSX1( cPerg ,  "01"  ,  "Do Produto ?  "  ,  "De Producto ? "  ,  "From Product ? "  ,  "MV_CH1"  ,  "C"  ,  15  ,  0  ,  0  , "G" , "" , "SB1" , "" , "S" , "MV_PAR01" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , aHelp[1,1] , aHelp[1,2] , aHelp[1,3] , "" )
PutSX1( cPerg ,  "02"  ,  "Ate Produto ? "  ,  "A Producto ?  "  ,  "To Product ?   "  ,  "MV_CH2"  ,  "C"  ,  15  ,  0  ,  0  , "G" , "" , "SB1" , "" , "S" , "MV_PAR02" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , aHelp[2,1] , aHelp[2,2] , aHelp[2,3] , "" )

Return