#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"       
#INCLUDE "TOPCONN.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ _RGerGFE  ³ Autor ³Ivan Oliveira ³Data  	       ³ 15/04/15 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Relatório Gerencial GFE			                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ OUROLUX								                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Arquivos  ³ 												              ³±±
±±³Utilizados³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
user function _RGerGFE()   

//objeto que contem o relatorio
Local 	_oReport                   
Local 	_aArea := GetArea()  
local 	_cPerg  := 'OLRGFE01'
Private _cAlias
 
criaSx1(_cPerg)
Pergunte(_cPerg,.F.)  

CriaTabela()

If FindFunction("TRepInUse") .And. TRepInUse() 

	//-- Interface de impressao
	_oReport := ReportDef(_cPerg,_oReport)
	_oReport:PrintDialog()   
	
EndIf

GFEDelTab( _cAlias )
RestArea( _aArea )

Return  
         

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ CriaTabela ³ Autor ³Ivan Oliveira ³Data         ³ 15/04/15 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Relatório Gerencial GFE			                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ OUROLUX								                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Arquivos  ³ 												              ³±±
±±³Utilizados³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function CriaTabela()
 

// Criacao da tabela temporaria p/ imprimir o relat
_aCpos:= {{"A1_NOME" 	, "C", 	TamSX3("A1_NOME" )[1], 0},;//Código Tipo Docto,
         {"GW1_NRDC" 	, "C", 	TamSX3("GW1_NRDC"   )[1], 0},;//Numero DC, 
		 {"GW1_SERDC"	, "C", 	TamSX3("GW1_SERDC"  )[1], 0},;//Serie,
		 {"GU7_NMCID"	, "C", 	TamSX3("GU7_REGREL")[1], 0},;//Cidade,
		 {"GU7_CDUF" 	, "C", 	TamSX3("GU7_CDUF" )[1], 0},;// Uf 
		 {"A4_NOME" 	, "C", 	TamSX3("A4_NOME" )[1], 0},;//Nome Transportadora
		 {"VLRFRETE" 	, "N", 	TamSX3("GWI_VLFRET" )[1], TamSX3("GWI_VLFRET")[2]},;    //Frete Previsto Total,
		 {"PREV_NOR" 	, "N", 	TamSX3("GWI_VLFRET" )[1], TamSX3("GWI_VLFRET")[2]},;    //Frete Previsto Normal,
		 {"REAL_NOR" 	, "N", 	TamSX3("GWI_VLFRET" )[1], TamSX3("GWI_VLFRET")[2]},;    //Frete Real Normal,
		 {"FRETSCALC"  	, "N", 	TamSX3("GWI_VLFRET" )[1], TamSX3("GWI_VLFRET")[2]},; //% Vlr Frete SOBRE Calculado Vlr Merc.
		 {"FRETSPAGO"  	, "N", 	TamSX3("GWI_VLFRET" )[1], TamSX3("GWI_VLFRET")[2]}}  //% Vlr Frete SOBRE Pago 
		 
_cAlias := GFECriaTab({ _aCpos, { }})

Return 
         

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ ReportDef ³ Autor ³Ivan Oliveira ³Data          ³ 15/04/15 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Relatório Gerencial GFE			                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ OUROLUX								                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Arquivos  ³ 												              ³±±
±±³Utilizados³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ReportDef( _cPerg, _oReport ) 

 
Local _aOrdem := {}    

local _cTitle  := "Relatório Gerencial"
local _cHelp   := "Permite gerar relatório de documento de cargas."
//Local aOrdem  := {"Nr° Pedido", "Nome do Cliente", "Equipamento"}

_oReport	:= TReport():New('_RGERGFE', _cTitle, _cPerg,{ |_oReport| ReportPrint( _oReport,_cAlias )} , _cHelp )
_oReport:SetLandscape()

// Primeira seção
oSection1:= TRSection():New(_oReport,"Relatório Gerencial",{"GW1"})
oSection1:SetLeftMargin(2)  
 
	TRCell():New(oSection1,"A1_NOME" 	, (_cAlias), "Cliente")   
 	TRCell():New(oSection1,"GW1_NRDC"	, (_cAlias), "Nota Fiscal")
	TRCell():New(oSection1,"GW1_SERDC"	, (_cAlias), "Série")   
	TRCell():New(oSection1,"GU7_NMCID"	, (_cAlias), "Cidade", "", 20 )
	TRCell():New(oSection1,"GU7_CDUF"	, (_cAlias), "Estado")
	TRCell():New(oSection1,"A4_NOME" 	, (_cAlias), "Transportadora")
	TRCell():New(oSection1,"VLRFRETE"	, (_cAlias), "Vlr.Fat") 
	TRCell():New(oSection1,"PREV_NOR"	, (_cAlias), "Frete Calc.","@E 99,999,999.99",30 ) 
	TRCell():New(oSection1,"REAL_NOR"	, (_cAlias), "Frete Pago", "",30 ) 
	TRCell():New(oSection1,"FRETSCALC"	, (_cAlias), "% Frt.Calc x Merc","@E 999.99")
	TRCell():New(oSection1,"FRETSPAGO"	, (_cAlias), "% Frt.Pago x Merc","@E 999.99") 
	TRCell():New(oSection1,"DIFFRET"	, (_cAlias), "%Dif.","@E 999.99  ")
 
	oBreak1 := TRBreak():New(oSection1,{||  },"Totais:",.F.)  
	
	//New(oCell,cName,cFunction,oBreak,cTitle,cPicture,uFormula,lEndSection,lEndReport,lEndPage,oParent,bCondition,lDisable,bCanPrint)                 

	TRFunction():New(oSection1:Cell("VLRFRETE" ) , "TOT1", "SUM", oBreak1,,"@E 99,999,999.99",, .F., .F.)
	TRFunction():New(oSection1:Cell("PREV_NOR" ) , "TOT2", "SUM", oBreak1,,"@E 99,999,999.99",, .F., .F.) 
	TRFunction():New(oSection1:Cell("REAL_NOR" ) , "TOT3", "SUM", oBreak1,,"@E 99,999,999.99",, .F., .F.)  
	TRFunction():New(oSection1:Cell("FRETSCALC" ), "TOT4", "ONPRINT", oBreak1,,"@E 99,999,999.99",, .F., .F.,,,,,, )  
	TRFunction():New(oSection1:Cell("FRETSPAGO" ), "TOT5", "ONPRINT", oBreak1,,"@E 99,999,999.99",, .F., .F.,,,,,, )   
	TRFunction():New(oSection1:Cell("DIFFRET" )  , "TOT6", "ONPRINT", oBreak1,,"@E 99,999,999.99",, .F., .F.,,,,,, ) 
      
  	// Calculando % do total
 	_oReport:GetFunction("TOT4"):SetFormula( {|| (_oReport:GetFunction("TOT2"):uLastValue / _oReport:GetFunction("TOT1"):uLastValue) * 100  } )  
 	_oReport:GetFunction("TOT5"):SetFormula( {|| (_oReport:GetFunction("TOT3"):uLastValue / _oReport:GetFunction("TOT1"):uLastValue) * 100  } )  
 	_oReport:GetFunction("TOT6"):SetFormula( {||  _oReport:GetFunction("TOT4"):uLastValue - _oReport:GetFunction("TOT5"):uLastValue  } ) 
 
 
Return(_oReport) 

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ ReportPrint ³ Autor ³Ivan Oliveira ³Data        ³ 15/04/15 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Relatório Gerencial GFE			                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ OUROLUX								                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Arquivos  ³ 												              ³±±
±±³Utilizados³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
 
Static Function ReportPrint(_oReport,_cAlias)

local oSection1b := _oReport:Section(1)
//local oSection2b := _oReport:Section(1):Section(1)  
local cOrdem  
Local nPorc1 := 0
Local nPorc2 := 0     
Local nPorc3 := 0
Local cSQLLog := '' 

oSection1b:Init()
oSection1b:SetHeaderSection(.T.)
                                 
// Carregando dados
CarrregaDados(_oReport)

_oReport:SetMeter((_cAlias)->(RecCount()))  
(_cAlias)->(DbGoTop())  

While !(_cAlias)->(Eof())

	oSection1b:Cell("A1_NOME"):SetValue((_cAlias)->A1_NOME)
	oSection1b:Cell("GW1_NRDC"):SetValue((_cAlias)->GW1_NRDC)
	oSection1b:Cell("GW1_SERDC"):SetValue((_cAlias)->GW1_SERDC)
	oSection1b:Cell("GU7_NMCID"):SetValue((_cAlias)->GU7_NMCID)
	oSection1b:Cell("GU7_CDUF"):SetValue((_cAlias)->GU7_CDUF)
	oSection1b:Cell("A4_NOME"):SetValue((_cAlias)->A4_NOME)
	oSection1b:Cell("VLRFRETE"):SetValue((_cAlias)->VLRFRETE)
	oSection1b:Cell("PREV_NOR"):SetValue((_cAlias)->PREV_NOR)
	oSection1b:Cell("REAL_NOR"):SetValue((_cAlias)->REAL_NOR)
	oSection1b:Cell("FRETSCALC"):SetValue((_cAlias)->FRETSCALC)  
	oSection1b:Cell("FRETSPAGO"):SetValue((_cAlias)->FRETSPAGO)  
	oSection1b:Cell("DIFFRET"):SetValue((_cAlias)->( FRETSCALC - FRETSPAGO) )
 	oSection1b:PrintLine()  
 	  
 	(_cAlias)->(DbSkip())
	_oReport:IncMeter(1)   
	 
	
EndDo

oSection1b:Finish()

Return 


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ CarrregaDados ³ Autor ³Ivan Oliveira ³Data      ³ 15/04/15 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Relatório Gerencial GFE			                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ OUROLUX								                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Arquivos  ³ 												              ³±±
±±³Utilizados³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function CarrregaDados( _oReport )

Local cAliasGW1
Local cTransp      

 
// Faz a busca dos documentos de carga de acordo com o filtro
cAliasGW1 := GetNextAlias()   
cQuery := "SELECT GW1_FILIAL, A1_NOME, GW1_NRDC, GW1_SERDC, GU7_NMCID, GU7_CDUF, A4_NOME,GW1_CDTPDC, GW1_CDTPDC, GW1_EMISDC, 
cQuery += "	     SUM(GW8_VALOR) VLRFRETE, GWU_CDTRP A4_CGC, GW1_EMISDC,GW1_CDTPDC,GWU_CDTRP, GW1_CDDEST, GW1_NRROM, GW1_DTLIB, "
cQuery += "	  	 CASE                                       "
cQuery += "	           WHEN GWF_BASICM = 0 THEN GWF_BASISS  "
cQuery += "	     ELSE                                       "
cQuery += "	  		 GWF_BASICM                             "
cQuery += "	  	 END GWF_BASICM                 		    "        //, GW3_VLDF" 

cQuery += " FROM " + RetSQLName("GW1") + ' GW1 ' 
   
// valor frete
cQuery +=  " INNER JOIN GW8010 GW8 ON GW8_FILIAL = GW8_FILIAL AND GW8_NRDC = GW1_NRDC AND GW8_SERDC = GW1_SERDC AND GW8.D_E_L_E_T_ = ' '  "
 
// CLiente
cQuery += " INNER JOIN " +  RetSQLName("SA1") + " SA1 ON A1_FILIAL = '" + xFilial ('SA1') + "' AND A1_CGC = GW1_CDDEST AND SA1.D_E_L_E_T_ = ' '"        

// Transportadora
cQuery += " INNER JOIN GWU010 GWU ON GWU_FILIAL = GW1_FILIAL     "
cQuery += "						  	 AND GWU_CDTPDC = GW1_CDTPDC "
cQuery += "						  	 AND GWU_EMISDC = GW1_EMISDC "
cQuery += "						  	 AND GWU_SERDC = GW1_SERDC   "
cQuery += "						  	 AND GWU_NRDC = GW1_NRDC     "
cQuery += "					     	 AND GWU.D_E_L_E_T_ = ' '    "

// Nome Transportadora
cQuery += " INNER JOIN  SA4010 SA4 ON A4_CGC = GWU_CDTRP  AND SA4.D_E_L_E_T_ = ' '"
 
// Cidade + UF         
cQuery += " INNER JOIN  GU7010 GU7 ON GU7_NRCID = GWU_NRCIDD AND GU7.D_E_L_E_T_ = ' ' "   

// Valor calculado 
cQuery += " INNER JOIN GWF010 GWF ON GWF_FILIAL = GW1_FILIAL AND GWF_NRROM = GW1.GW1_NRROM AND GWF_EMIDES = GW1.GW1_CDDEST AND GWF_TRANSP = A4_CGC "
cQuery += "     AND GWF.D_E_L_E_T_ = ' ' "
 
// Valor Frete --> REALIZAR VIA DBSEEK, POIS TEM VALORES ADICIONIS DE FRETE		
//cQuery += " INNER JOIN	GW4010  GW4 ON GW4_FILIAL = GW1_FILIAL  AND GW4_EMISDC = GW1_EMISDC AND GW4_SERDC = GW1_SERDC "
//cQuery += "   	AND GW4_NRDC = GW1_NRDC AND GW4_TPDC = GW1_CDTPDC AND GW4_EMISDF = A4_CGC AND GW4.D_E_L_E_T_ = ' '  "
	
//cQuery += "  INNER JOIN GW3010 GW3 ON GW3_FILIAL = GW1_FILIAL AND GW3_CDESP = GW4_CDESP AND GW3_EMISDF =  GW4_EMISDF AND GW3_SERDF = GW4_SERDF "
//cQuery += " 	AND GW3_NRDF= GW4_NRDF AND GW3_EMISDF = A4_CGC AND GW3_DTEMIS = GW4_DTEMIS  AND GW3.D_E_L_E_T_ = ' '  "

cQuery += "  WHERE "      

cQuery += " 	GW1.GW1_FILIAL  	BETWEEN '" + MV_PAR03      		+ "' AND '" + MV_PAR04       + "'"
cQuery += " 	AND GW1.GW1_DTEMIS  BETWEEN '" + DTOS(MV_PAR01)     + "' AND '" + DTOS(MV_PAR02) + "'"   
cQuery += "  	AND A4_COD			BETWEEN '" + MV_PAR05      		+ "' AND '" + MV_PAR06 + "'"
cQuery += "  	AND A1_EST 			BETWEEN '" + MV_PAR07	  		+ "' AND '" + MV_PAR08 + "'"
cQuery += "  	AND A1_COD 			BETWEEN '" + MV_PAR09  	  		+ "' AND '" + MV_PAR10 + "'"   

// ---------------->>  fILTRO CONFERÊNCIA  ---> Somente para teste
// 				cQuery += " AND GW1_NRDC  IN(  '000063678', '000063679' )  "
	
cQuery += "  	AND GW1.D_E_L_E_T_ = ' ' 
 
// Agrupamento
cQuery += " GROUP BY GW1_FILIAL, A1_NOME, GW1_NRDC, GW1_SERDC, GU7_NMCID, GU7_CDUF, A4_NOME,GW1_CDTPDC, GW1_CDTPDC, GW1_EMISDC, GWU_CDTRP,   "
cQuery += " 		 GW1_EMISDC,GW1_CDTPDC,GWU_CDTRP, GW1_CDDEST, GW1_NRROM, GW1_DTLIB, GWF_BASICM,GWF_BASISS" // , GW3_VLDF"  


cQuery += " ORDER BY GW1_FILIAL, GW1_NRDC, GW1_SERDC   "

// Execução Query	
//cQuery := ChangeQuery(cQuery)
dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasGW1, .F., .T.)

dbSelectArea((cAliasGW1))
(cAliasGW1)->( dbGoTop() )

While !_oReport:Cancel() .AND. !(cAliasGW1)->( Eof() )
       _oReport:IncMeter() 
       
	_nVlFtPgo := 0    
	VALFRETE  := GetNextAlias()
	
	 BEGINSQL ALIAS VALFRETE
 
 		%noParser%
		SELECT 
	 	   		ISNULL(SUM(GW3_VLDF),0) VALFRET FROM %Table:GW4% GW4
		
			INNER JOIN %Table:GW3%  GW3
			ON 
				GW3_FILIAL 		= GW4_FILIAL
				AND GW3_CDESP 	= GW4_CDESP
		   		AND GW3_EMISDF 	= GW4_EMISDF  
				AND GW3_SERDF	= GW4_SERDF
		   		AND GW3_NRDF	= GW4_NRDF
		   		AND GW3_EMISDF  = GW4_EMISDF
		   		AND GW3.%notDel%    

		WHERE 
	   		GW4_FILIAL 	   = %Exp:(cAliasGW1)->GW1_FILIAL% 
			AND GW4_EMISDC = %Exp:(cAliasGW1)->GW1_EMISDC% 
			AND GW4_SERDC  = %Exp:(cAliasGW1)->GW1_SERDC%     
			AND GW4_NRDC   = %Exp:(cAliasGW1)->GW1_NRDC%             
		 	AND GW4_TPDC   = %Exp:(cAliasGW1)->GW1_CDTPDC%    
		    AND GW4_EMISDF = %Exp:(cAliasGW1)->A4_CGC% 
		    AND GW4.%notDel%  
		                       
	EndSql   
	
	if !(VALFRETE)->( Eof() )

		_nVlFtPgo := (VALFRETE)->(VALFRET)
		
	Endif  
	
	// Fechamaneto frete
  	(VALFRETE)->(dbCloseArea())
		      
	// Calculo de Rateio 
	cAliasRat := GetNextAlias()    
	 
	cQuery := " SELECT 
 	cQuery += " 	   ( SELECT COUNT(1) FROM " +  RetSQLName("GW1") + ' GW1A '  + "  WHERE GW1A.GW1_FILIAL     = '" + (cAliasGW1)->GW1_FILIAL + "'"  
 	cQuery += " 																			AND GW1A.GW1_NRROM  = '" + (cAliasGW1)->GW1_NRROM  + "'"  
 	cQuery += " 	 																        AND GW1A.GW1_CDDEST = '" + (cAliasGW1)->GW1_CDDEST + "'"  
  	cQuery += " 	  	 																    AND GW1A.GW1_DTLIB  = '" + (cAliasGW1)->GW1_DTLIB  + "'"  
  	cQuery += " 	  	 																    AND GW1A.GW1_NRDC   = '" + (cAliasGW1)->GW1_NRDC   + "'"   
  	cQuery += " 																			AND GW1A.D_E_L_E_T_ = ' ' ) QT, "
 	
	cQuery += " 	   SUM(GW8_VALOR)  TOTALNF " 
	
  	cQuery += " FROM " + RetSQLName("GW8") + ' GW8 ' 
 
 	cQuery += " WHERE  GW8.GW8_FILIAL = '" + (cAliasGW1)->GW1_FILIAL + "'"     
 	cQuery += "        AND GW8_NRDC  IN
 	cQuery += " 	   				( SELECT GW1_NRDC FROM " +  RetSQLName("GW1") + ' GW1B ' + "  WHERE GW1B.GW1_FILIAL = '" + (cAliasGW1)->GW1_FILIAL + "'"  
 	cQuery += " 																			AND GW1B.GW1_NRROM  = '" + (cAliasGW1)->GW1_NRROM  + "'"  
 	cQuery += " 	 																        AND GW1B.GW1_CDDEST = '" + (cAliasGW1)->GW1_CDDEST + "'"  
  	cQuery += " 	  	 																    AND GW1B.GW1_DTLIB  = '" + (cAliasGW1)->GW1_DTLIB  + "'" 
  	cQuery += " 	  	 																    AND GW1B.GW1_NRDC   = '" + (cAliasGW1)->GW1_NRDC   + "'" 
  	cQuery += " 																			AND GW1B.D_E_L_E_T_ = ' ' )  "
 	cQuery += 		  " AND GW8.D_E_L_E_T_ = ' '  "
  	
  	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasRat, .F., .T.)  
  	
  	_VlrFrete := (cAliasGW1)->VLRFRETE 
  	_nVlFtCal := (cAliasGW1)->GWF_BASICM 
  
  	// Se existir mais de 1 rateio, dividir o frete em porcentual da carga  
 	if !(cAliasRat)->( Eof() ) 
 	                          
 		if (cAliasRat)->QT > 1 
 		      
 			// Rateio Frete Calculado
 			_nVlrTot := (cAliasRat)->TOTALNF 
 			_nVlFtCal:= (_nVlFtCal / _nVlrTot)*_VlrFrete  
 			
 			// Rateio Frete Pago
 			_nVlFtPgo:= (_nVlFtPgo / _nVlrTot)*_VlrFrete
 			
 		Endif
  	
  	Endif
  	      
  	// Fechamaneto rateio
  	(cAliasRat)->(dbCloseArea())
		
	// Gravando tabela de Impressão do relatório 
	RecLock((_cAlias), .T.)
		  
		(_cAlias)->A1_NOME  	:= (cAliasGW1)->A1_NOME 
		(_cAlias)->GW1_NRDC  	:= (cAliasGW1)->GW1_NRDC 
		(_cAlias)->GW1_SERDC  	:= (cAliasGW1)->GW1_SERDC 
		(_cAlias)->GU7_NMCID 	:= (cAliasGW1)->GU7_NMCID
		(_cAlias)->GU7_CDUF 	:= (cAliasGW1)->GU7_CDUF
		(_cAlias)->A4_NOME 		:= (cAliasGW1)->A4_NOME 
		(_cAlias)->VLRFRETE  	:= (cAliasGW1)->VLRFRETE 
		(_cAlias)->PREV_NOR  	:= _nVlFtCal
		(_cAlias)->REAL_NOR 	:= _nVlFtPgo
	  	(_cAlias)->FRETSCALC 	:= ( (_cAlias)->PREV_NOR / (_cAlias)->VLRFRETE  ) * 100
		(_cAlias)->FRETSPAGO 	:= ( (_cAlias)->REAL_NOR / (_cAlias)->VLRFRETE  ) * 100
	 
	MsUnlock()
	
	(cAliasGW1)->(dbSkip())
	
EndDo
(cAliasGW1)->(dbCloseArea())

Return


//+-----------------------------------------------------------------------------------------------+
//! Função para criação das perguntas (se não existirem)                                          !
//+-----------------------------------------------------------------------------------------------+
static function criaSX1(cPerg)

putSx1(cPerg, '01', 'Emissao Nfe de?'          	, '', '', 'mv_ch1', 'D', 8   , 0, 0, 'G', '', '', '', '', 'mv_par01')
putSx1(cPerg, '02', 'Emissao Nfe Ate?'         	, '', '', 'mv_ch2', 'D', 8	  , 0, 0, 'G', '', '', '', '', 'mv_par02')
putSx1(cPerg, '03', 'Filial de?'         		, '', '', 'mv_ch3', 'C', 2   , 0, 0, 'G', '', '', '', '', 'mv_par03')
putSx1(cPerg, '04', 'Filial até?'        		, '', '', 'mv_ch4', 'C', 2   , 0, 0, 'G', '', '', '', '', 'mv_par04')
putSx1(cPerg, '05', 'Transportadora de?'       	, '', '', 'mv_ch5', 'C', 6   , 0, 0, 'G', '', 'SA4'   , '', '', 'mv_par05')
putSx1(cPerg, '06', 'Transportadora até?'      	, '', '', 'mv_ch6', 'C', 6   , 0, 0, 'G', '', 'SA4'   , '', '', 'mv_par06')
putSx1(cPerg, '07', 'Estado de?'            	, '', '', 'mv_ch7', 'C', 2   , 0, 0, 'G', '', ''   , '', '', 'mv_par07')
putSx1(cPerg, '08', 'Estado até?'           	, '', '', 'mv_ch8', 'C', 2   , 0, 0, 'G', '', ''   , '', '', 'mv_par08')
putSx1(cPerg, '09', 'Cliente de?'         		, '', '', 'mv_ch9', 'C', 6   , 0, 0, 'G', '', 'SA1', '', '', 'mv_par09')
putSx1(cPerg, '10', 'Cliente até?'        		, '', '', 'mv_ch10', 'C', 6   , 0, 0, 'G', '', 'SA1', '', '', 'mv_par10')


return    
