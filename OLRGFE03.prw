#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH" 
#INCLUDE "TOPCONN.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³OLRGFE03  ³ Autor ³Elias dos Santos Silva ³Data  ³ 16/10/13 ³±±
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


user function OLRGFE03()

local oReport
local cPerg  := 'OLRGFE03'
local cAlias := getNextAlias()

criaSx1(cPerg)
Pergunte(cPerg, .F.)

oReport := reportDef(cAlias, cPerg)

oReport:printDialog()

return

//+-----------------------------------------------------------------------------------------------+
//! Função para criação da estrutura do relatório.                                                !
//+-----------------------------------------------------------------------------------------------+
Static Function ReportDef(cAlias,cPerg)

local cTitle  := "Relatório Gerencial"
local cHelp   := "Permite gerar relatório de documento de cargas."

local oReport
local oSection1
local oSection2
local oBreak1

oReport	:= TReport():New('OLRGFE03',cTitle,cPerg,{|oReport|ReportPrint(oReport,cAlias)},cHelp)
oReport:SetLandscape()

// Primeira seção
oSection1:= TRSection():New(oReport,"Relatório Gerencial",{"GW1"})
        
oSection1:SetLeftMargin(2)  

TRCell():New(oSection1,"A1_NOME", "SA1", "Nome do Cliente")
TRCell():New(oSection1,"GW1_NRDC", "GW1", "Nota Fiscal")
TRCell():New(oSection1,"GW1_SERDC", "GW1", "Série")   
TRCell():New(oSection1,"GU7_NMCID", "GU7", "Cidade")
TRCell():New(oSection1,"GU7_CDUF", "GU7", "Estado")
TRCell():New(oSection1,"A4_NOME", "SA4",  "Transportadora")
TRCell():New(oSection1,"GW1_DTEMIS", "GW3", "Faturament")
TRCell():New(oSection1,"GW1_NRROM", "GW1", "Romaneio")
TRCell():New(oSection1,"GWN_DTSAI", "GWN", "Saida.Rom")
TRCell():New(oSection1,"GWU_DTPENT", "GW1", "Prv.Entreg")
TRCell():New(oSection1,"GWU_DTENT", "GWU", "Entrega")
TRCell():New(oSection1,"DIAS", "", "Dias", "@E 9999")

oSection1:Cell("DIAS"):SetAlign("LEFT")

//Totalizador
oBreak1 := TRBreak():New(oSection1,{||  },"Total:",.F.)                   
TRFunction():New(oSection1:Cell("GW1_NRDC" ), "TOT1", "COUNT", oBreak1,,,, .F., .F.)
TRFunction():New(oSection1:Cell("DIAS" ), "TOT2", "AVERAGE", oBreak1,,,, .F., .F.)

Return(oReport)

//+-----------------------------------------------------------------------------------------------+
//! Rotina para montagem dos dados do relatório.                                  !
//+-----------------------------------------------------------------------------------------------+
Static Function ReportPrint(oReport,cAlias)

local oSection1b := oReport:Section(1)
local cOrdem  
Local nRow     
Local aResumo := {}

          
oSection1b:BeginQuery()

BeginSQL Alias cAlias
	
SELECT DISTINCT A1_NOME,
       GW1_NRDC,
       GW1_SERDC,
       GU7_NMCID,
       GU7_CDUF,
       A4_NOME,
       GW1_DTEMIS,
       GW1_NRROM, 
       GWN_DTSAI,
       GWU_DTPENT,
       GWU_DTENT,
//     DATEDIFF(dd, CASE LTRIM(RTRIM(GWU_DTPENT)) WHEN '' THEN GETDATE() ELSE CONVERT(datetime,GWU_DTPENT,102) END, CASE LTRIM(RTRIM(GWU_DTENT)) WHEN '' THEN GETDATE() ELSE CONVERT(datetime, GWU_DTENT,102) END) AS DIAS
DATEDIFF(dd, CASE LTRIM(RTRIM(GW1_DTEMIS)) WHEN '' THEN GETDATE() ELSE CONVERT(datetime,GW1_DTEMIS,102) END, CASE LTRIM(RTRIM(GWU_DTENT)) WHEN '' THEN GETDATE() ELSE CONVERT(datetime, GWU_DTENT,102) END) AS DIAS
FROM %Table:GW1% GW1
INNER JOIN %Table:SA1% SA1 ON A1_CGC = GW1_CDDEST
AND SA1.D_E_L_E_T_ = ' '
INNER JOIN %Table:GWU% GWU ON GWU_FILIAL = GW1_FILIAL
AND GWU_CDTPDC = GW1_CDTPDC
AND GWU_EMISDC = GW1_EMISDC
AND GWU_SERDC = GW1_SERDC
AND GWU_NRDC = GW1_NRDC
AND GWU.D_E_L_E_T_ = ' '
LEFT JOIN %Table:GWN% GWN ON GWN_FILIAL = GW1_FILIAL
AND GWN_NRROM = GW1_NRROM
AND GWN.D_E_L_E_T_ = ' '
INNER JOIN %Table:SA4% SA4 ON A4_CGC = GWU_CDTRP
AND SA4.D_E_L_E_T_ = ' '
INNER JOIN %Table:GU7% GU7 ON GU7_NRCID = GWU_NRCIDD
AND GWU.D_E_L_E_T_ = ' '
LEFT JOIN %Table:GWH% GWH ON GWH_FILIAL = GW1_FILIAL
AND GWH_EMISDC = GW1_EMISDC
AND GWH_SERDC = GW1_SERDC
AND GWH_NRDC = GW1_NRDC
AND GWH.D_E_L_E_T_ = ' '
INNER JOIN %Table:GWF% GWF ON GWF_FILIAL = GWH_FILIAL
AND GWF_NRCALC = GWH_NRCALC AND GWF_TRANSP = GWU_CDTRP AND GWF_CIDDES = GWU_NRCIDD
AND GWF.D_E_L_E_T_ = ' '
LEFT JOIN %Table:GW4% GW4 ON GW4_FILIAL = GW1_FILIAL
AND GW4_EMISDC = GW1_EMISDC
AND GW4_SERDC = GW1_SERDC
AND GW4_NRDC = GW1_NRDC
AND GW4_TPDC = GW1_CDTPDC
AND GW4.D_E_L_E_T_ = ' '
LEFT JOIN %Table:GW3% GW3 ON GW3_FILIAL = GW4_FILIAL
AND GW3_CDESP = GW4_CDESP
AND GW3_EMISDF = GW4_EMISDF
AND GW3_SERDF = GW4_SERDF
AND GW3_NRDF = GW4_NRDF
AND GW3_DTEMIS = GW4_DTEMIS
AND GW3.D_E_L_E_T_ = ' '
LEFT JOIN %Table:GW6% GW6 ON GW6_FILIAL = GW1_FILIAL
AND GW6_EMIFAT = GW1_EMISDC
AND GW6_SERFAT = GW1_SERDC
AND GW6_NRFAT = GW1_NRDC
AND GW6.D_E_L_E_T_ = ' '
WHERE GW1_DTEMIS BETWEEN %Exp:MV_PAR01% AND %Exp:MV_PAR02%
  AND GW1_FILIAL BETWEEN %Exp:MV_PAR03% AND %Exp:MV_PAR04%
  AND A4_COD BETWEEN %Exp:MV_PAR05% AND %Exp:MV_PAR06%
  AND A1_EST BETWEEN %Exp:MV_PAR07% AND %Exp:MV_PAR08%
  AND GW1_EMISDC BETWEEN %Exp:MV_PAR09% AND %Exp:MV_PAR10%
  AND GW1.D_E_L_E_T_ = ' '


EndSQL 

oSection1b:EndQuery()    
oReport:SetMeter((cAlias)->(RecCount()))  

aResumo := Resumo()
oSection1b:Print()	   

oReport:IncRow(1)
oReport:PrintText ( " NOTAS NO PRAZO       : " + CVALTOCHAR(aResumo[1])) 
oReport:PrintText ( " NOTAS ANTES DO PRAZO : " + CVALTOCHAR(aResumo[2])) 
oReport:PrintText ( " NOTAS FORA DO PRAZO  : " + CVALTOCHAR(aResumo[3])) 
oReport:PrintText ( " NOTAS SEM ENTREGA    : " + CVALTOCHAR(aResumo[4]))


return

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

Static Function Resumo()
Local aRet := {0,0,0,0}
Local cSql := ""

cSql += "SELECT DISTINCT A1_NOME,    "
cSql += "       GW1_NRDC,   "
cSql += "       GW1_SERDC,  "
cSql += "       GU7_NMCID,  "
cSql += "       GU7_CDUF,   "
cSql += "       A4_NOME,    "
cSql += "       GW1_DTEMIS, "
cSql += "       GW1_NRROM,  "
cSql += "       GWU_DTPENT, "
cSql += "       GWU_DTENT, "
//cSql += "       DATEDIFF(dd, CASE LTRIM(RTRIM(GWU_DTPENT)) WHEN '' THEN GETDATE() ELSE CONVERT(datetime,GWU_DTPENT,102) END, CASE LTRIM(RTRIM(GWU_DTENT)) WHEN '' THEN GETDATE() ELSE CONVERT(datetime, GWU_DTENT,102) END) AS DIAS "
cSql += "       DATEDIFF(dd, CASE LTRIM(RTRIM(GW1_DTEMIS)) WHEN '' THEN GETDATE() ELSE CONVERT(datetime,GW1_DTEMIS,102) END, CASE LTRIM(RTRIM(GWU_DTENT)) WHEN '' THEN GETDATE() ELSE CONVERT(datetime, GWU_DTENT,102) END) AS DIAS "
cSql += "FROM " + retsqlname("GW1") + " GW1 "
cSql += "INNER JOIN " + retsqlname("SA1") +  "  SA1 ON A1_CGC = GW1_CDDEST "
cSql += "AND SA1.D_E_L_E_T_ = ' ' "
cSql += "INNER JOIN " + retsqlname("GWU") +" GWU ON GWU_FILIAL = GW1_FILIAL "
cSql += "AND GWU_CDTPDC = GW1_CDTPDC "
cSql += "AND GWU_EMISDC = GW1_EMISDC "
cSql += "AND GWU_SERDC = GW1_SERDC "
cSql += "AND GWU_NRDC = GW1_NRDC "
cSql += "AND GWU.D_E_L_E_T_ = ' '  "
cSql += "LEFT JOIN " + retsqlname("GWN")  +" GWN ON GWN_FILIAL = GW1_FILIAL "
cSql += "AND GWN_NRROM = GW1_NRROM "
cSql += "AND GWN.D_E_L_E_T_ = ' ' "
cSql += "INNER JOIN " + retsqlname("SA4") +" SA4 ON A4_CGC = GWU_CDTRP "
cSql += "AND SA4.D_E_L_E_T_ = ' ' "
cSql += "INNER JOIN " + retsqlname("GU7") + " GU7 ON GU7_NRCID = GWU_NRCIDD "
cSql += "AND GWU.D_E_L_E_T_ = ' ' "
cSql += "LEFT JOIN " + retsqlname ("GWH") + " GWH ON GWH_FILIAL = GW1_FILIAL "
cSql += "AND GWH_EMISDC = GW1_EMISDC "
cSql += "AND GWH_SERDC = GW1_SERDC "
cSql += "AND GWH_NRDC = GW1_NRDC "
cSql += "AND GWH.D_E_L_E_T_ = ' ' "
cSql += "INNER JOIN " + retsqlname("GWF") + " GWF ON GWF_FILIAL = GWH_FILIAL "
cSql += "AND GWF_NRCALC = GWH_NRCALC AND GWF_TRANSP = GWU_CDTRP AND GWF_CIDDES = GWU_NRCIDD "
cSql += "AND GWF.D_E_L_E_T_ = ' ' "
cSql += "LEFT JOIN "+ retsqlname("GW4") +" GW4 ON GW4_FILIAL = GW1_FILIAL "
cSql += "AND GW4_EMISDC = GW1_EMISDC "
cSql += "AND GW4_SERDC = GW1_SERDC "
cSql += "AND GW4_NRDC = GW1_NRDC   "
cSql += "AND GW4_TPDC = GW1_CDTPDC "
cSql += "AND GW4.D_E_L_E_T_ = ' ' "
cSql += "LEFT JOIN " + retsqlname("GW3") +" GW3 ON GW3_FILIAL = GW4_FILIAL "
cSql += "AND GW3_CDESP = GW4_CDESP "
cSql += "AND GW3_EMISDF = GW4_EMISDF "
cSql += "AND GW3_SERDF = GW4_SERDF "
cSql += "AND GW3_NRDF = GW4_NRDF "
cSql += "AND GW3_DTEMIS = GW4_DTEMIS "
cSql += "AND GW3.D_E_L_E_T_ = ' ' "
cSql += "LEFT JOIN " + retsqlname("GW6") + " GW6 ON GW6_FILIAL = GW1_FILIAL "
cSql += "AND GW6_EMIFAT = GW1_EMISDC "
cSql += "AND GW6_SERFAT = GW1_SERDC "
cSql += "AND GW6_NRFAT = GW1_NRDC "
cSql += "AND GW6.D_E_L_E_T_ = ' ' "
cSql += "WHERE GW1_DTEMIS BETWEEN '"+ DTOS(MV_PAR01) +"' AND '"+ DTOS(MV_PAR02)+"' "
cSql += "  AND GW1_FILIAL BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"' "
cSql += "  AND A4_COD BETWEEN '"+MV_PAR05+"' AND '"+MV_PAR06+"' "
cSql += "  AND A1_EST BETWEEN '"+MV_PAR07+"' AND '"+MV_PAR08+"' "
cSql += "  AND GW1_EMISDC BETWEEN '"+MV_PAR09+"' AND '"+MV_PAR10+"' "
cSql += "  AND GW1.D_E_L_E_T_ = ' ' "
                                                                              
If Select("XTRB") > 0
	XTRB->(DbCloseArea())
Endif

TcQuery cSql new Alias "XTRB"

While !XTRB->(Eof())

If XTRB->DIAS == 0
	aRet[1] += 1
elseif XTRB->DIAS < 0 
	aRet[2] += 1
elseif XTRB->DIAS > 0
	aRet[3] += 1
Endif
If Empty(XTRB->GWU_DTENT)
	aRet[4] += 1	
Endif  

XTRB->(DbSkip())
Enddo     

XTRB->(DbCloseArea())

Return aRet               


Static Function RatFrete()

Return
