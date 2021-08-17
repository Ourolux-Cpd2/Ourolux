#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"       
#INCLUDE "TOPCONN.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³OLRGFE01  ³ Autor ³Elias dos Santos Silva ³Data  ³ 16/02/15 ³±±
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


user function OLRGFE01()

local oReport
local cPerg  := 'OLRGFE01'
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
//Local aOrdem  := {"Nr° Pedido", "Nome do Cliente", "Equipamento"}

local oReport
local oSection1
local oSection2
local oBreak1

oReport	:= TReport():New('OLRGFE01',cTitle,cPerg,{|oReport|ReportPrint(oReport,cAlias)},cHelp)
oReport:SetLandscape()

// Primeira seção
oSection1:= TRSection():New(oReport,"Relatório Gerencial",{"GW1"})
        
oSection1:SetLeftMargin(2)  

TRCell():New(oSection1,"A1_NOME", "GU3", "Nome do Cliente")
TRCell():New(oSection1,"GW1_NRDC", "GW1", "Nota Fiscal")
TRCell():New(oSection1,"GW1_SERDC", "GW1", "Série")   
TRCell():New(oSection1,"GU7_NMCID", "GWU", "Cidade")
TRCell():New(oSection1,"GU7_CDUF", "GWU", "Estado")
TRCell():New(oSection1,"A4_NOME", "SA4",  "Transportadora")
TRCell():New(oSection1,"GW8_VALOR", "GW8", "Vlr. Merc")
TRCell():New(oSection1,"GWF_VALFRT", "", "Vlr. Frete Calculado","@E 99,999,999.99 ")
TRCell():New(oSection1,"GW3_VLDF", "GW1", "Vlr. Frete Pago")
TRCell():New(oSection1,"PORC1", "", "% Vlr. Frete Calc X Vlr. Merc","@E 999.99  ")
TRCell():New(oSection1,"PORC2", "", "% Vlr. Frete Pago X Vlr. Merc","@E 999.99  ")
TRCell():New(oSection1,"PORC3", "", "% Frete Calc X Merc - % Frete Pago X Merc","@E 999.99  ")


oBreak1 := TRBreak():New(oSection1,{||  },"Total:",.F.)                   

TRFunction():New(oSection1:Cell("GW8_VALOR" ), "TOT1", "SUM", oBreak1,,,, .F., .F.)
TRFunction():New(oSection1:Cell("GWF_VALFRT" ), "TOT2", "SUM", oBreak1,,,, .F., .F.)
TRFunction():New(oSection1:Cell("PORC1" ), "TOT3", "AVERAGE", oBreak1,,,, .F., .F.)
TRFunction():New(oSection1:Cell("PORC2" ), "TOT4", "AVERAGE", oBreak1,,,, .F., .F.)
TRFunction():New(oSection1:Cell("PORC3" ), "TOT5", "AVERAGE", oBreak1,,,, .F., .F.)

//Section1:Cell("PORC3"):SetValue(oSection1:Cell("PORC2"):GetValue() - oSection1:Cell("PORC1"):GetValue())


Return(oReport)

//+-----------------------------------------------------------------------------------------------+
//! Rotina para montagem dos dados do relatório.                                  !
//+-----------------------------------------------------------------------------------------------+
Static Function ReportPrint(oReport,cAlias)

local oSection1b := oReport:Section(1)
//local oSection2b := oReport:Section(1):Section(1)  
local cOrdem  
Local nPorc1 := 0
Local nPorc2 := 0     
Local nPorc3 := 0
Local cSQLLog := '' 

oSection1b:Init()
oSection1b:SetHeaderSection(.T.)

          
oSection1b:BeginQuery()
/*
BeginSQL Alias cAlias
	
SELECT DISTINCT A1_NOME,
       GW1_NRDC,
       GW1_SERDC,
       GWF_NRCALC,
       GU7_NMCID,
       GU7_CDUF,
       A4_NOME,

  (SELECT SUM(GW8_VALOR)
   FROM %Table:GW8% GW8
   WHERE GW8_FILIAL = GW1.GW1_FILIAL
     AND GW8_NRDC = GW1.GW1_NRDC
     AND GW8_SERDC = GW1.GW1_SERDC
     AND GW8.D_E_L_E_T_ = ' ') AS GW8_VALOR,

  (SELECT SUM(GWI_VLFRET)
   FROM %Table:GWI% GWI
   WHERE GWI_FILIAL = GWF.GWF_FILIAL
     AND GWI_NRCALC = GWF.GWF_NRCALC
     AND GWI_TOTFRE = '1'
     AND GWI.D_E_L_E_T_ = ' ') AS GWF_VALFRT,
       GW3_VLDF,
       (
          (SELECT SUM(GWI_VLFRET)
           FROM %Table:GWI% GWI
           WHERE GWI_FILIAL = GWF.GWF_FILIAL
             AND GWI_NRCALC = GWF.GWF_NRCALC
             AND GWI_TOTFRE = '1'
             AND GWI.D_E_L_E_T_ = ' ') /
          (SELECT SUM(GW8_VALOR)
           FROM %Table:GW8% GW8
           WHERE GW8_FILIAL = GW1.GW1_FILIAL
             AND GW8_NRDC = GW1.GW1_NRDC
             AND GW8_SERDC = GW1.GW1_SERDC
             AND GW8.D_E_L_E_T_ = ' ')) *100 AS PORC1,
       (GW3_VLDF /
          (SELECT SUM(GW8_VALOR)
           FROM %Table:GW8% GW8
           WHERE GW8_FILIAL = GW1.GW1_FILIAL
             AND GW8_NRDC = GW1.GW1_NRDC
             AND GW8_SERDC = GW1.GW1_SERDC
             AND GW8.D_E_L_E_T_ = ' '))* 100 AS PORC2,
       (GW3_VLDF /
          (SELECT SUM(GW8_VALOR)
           FROM %Table:GW8% GW8
           WHERE GW8_FILIAL = GW1.GW1_FILIAL
             AND GW8_NRDC = GW1.GW1_NRDC
             AND GW8_SERDC = GW1.GW1_SERDC
             AND GW8.D_E_L_E_T_ = ' ')) * 100 AS PORC3
             
FROM %Table:GW1% GW1
INNER JOIN SA1010 SA1 ON A1_CGC = GW1_CDDEST
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
AND GW4_EMISDF = GWU_CDTRP
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

EndSql
*/

/*
BeginSQL Alias cAlias

SELECT DISTINCT  A1_NOME,

       GW1_NRDC,
       GW1_SERDC,
       GU7_NMCID,
       GU7_CDUF,
       A4_NOME,

  (SELECT SUM(GW8_VALOR)
   FROM  %Table:GW8% GW8
   WHERE GW8_FILIAL = GW1.GW1_FILIAL
     AND GW8_NRDC = GW1.GW1_NRDC
     AND GW8_SERDC = GW1.GW1_SERDC
     AND GW8.D_E_L_E_T_ = ' ') AS GW8_VALOR,
  
   GW3_VLDF,

  (SELECT SUM(GWI_VLFRET)
   FROM  %Table:GWI% GWI
   WHERE GWI_FILIAL = GWF.GWF_FILIAL
     AND GWI_NRCALC = GWF.GWF_NRCALC
     AND GWI_TOTFRE = '1'
     AND GWI.D_E_L_E_T_ = ' ') AS GWF_VALFRT,

       (
          (SELECT SUM(GWI_VLFRET)
           FROM  %Table:GWI% GWI
           WHERE GWI_FILIAL = GWF.GWF_FILIAL
             AND GWI_NRCALC = GWF.GWF_NRCALC
             AND GWI_TOTFRE = '1'
             AND GWI.D_E_L_E_T_ = ' ') /
          (SELECT SUM(GW8_VALOR)
           FROM  %Table:GW8% GW8
           WHERE GW8_FILIAL = GW1.GW1_FILIAL
             AND GW8_NRDC = GW1.GW1_NRDC
             AND GW8_SERDC = GW1.GW1_SERDC
             AND GW8.D_E_L_E_T_ = ' ')) *100 AS PORC1,

       (GW3_VLDF /
          (SELECT SUM(GW8_VALOR)
           FROM  %Table:GW8% GW8
           WHERE GW8_FILIAL = GW1.GW1_FILIAL
             AND GW8_NRDC = GW1.GW1_NRDC
             AND GW8_SERDC = GW1.GW1_SERDC
             AND GW8.D_E_L_E_T_ = ' '))* 100 AS PORC2,

       (GW3_VLDF /
          (SELECT SUM(GW8_VALOR)
           FROM  %Table:GW8% GW8
           WHERE GW8_FILIAL = GW1.GW1_FILIAL
             AND GW8_NRDC = GW1.GW1_NRDC
             AND GW8_SERDC = GW1.GW1_SERDC
             AND GW8.D_E_L_E_T_ = ' ')) * 100 AS PORC3
             
FROM  %Table:GW1% GW1
INNER JOIN  %Table:SA1% SA1 ON A1_CGC = GW1_CDDEST
AND SA1.D_E_L_E_T_ = ' '

INNER JOIN  %Table:GWU% GWU ON GWU_FILIAL = GW1_FILIAL
AND GWU_CDTPDC = GW1_CDTPDC
AND GWU_EMISDC = GW1_EMISDC
AND GWU_SERDC = GW1_SERDC
AND GWU_NRDC = GW1_NRDC
AND GWU.D_E_L_E_T_ = ' '

LEFT JOIN  %Table:GWN% GWN ON GWN_FILIAL = GW1_FILIAL
AND GWN_NRROM = GW1_NRROM 
AND GWN.D_E_L_E_T_ = ' '
INNER JOIN  %Table:SA4% SA4 ON A4_CGC = GWU_CDTRP
AND SA4.D_E_L_E_T_ = ' '                 
INNER JOIN  %Table:GU7% GU7 ON GU7_NRCID = GWU_NRCIDD
AND GWU.D_E_L_E_T_ = ' '
INNER JOIN  %Table:GWH% GWH ON GWH_FILIAL = GW1_FILIAL
AND GWH_EMISDC = GW1_EMISDC
AND GWH_SERDC = GW1_SERDC
AND GWH_NRDC = GW1_NRDC
AND GWH.D_E_L_E_T_ = ' '
INNER JOIN  %Table:GWF% GWF ON GWF_FILIAL = GWH_FILIAL
AND GWF_NRCALC = GWH_NRCALC AND GWF_TRANSP = GWU_CDTRP AND GWF_CIDDES = GWU_NRCIDD
AND GWF.D_E_L_E_T_ = ' '
INNER JOIN  %Table:GW4% GW4 ON GW4_FILIAL = GW1_FILIAL
AND GW4_EMISDC = GW1_EMISDC
AND GW4_SERDC = GW1_SERDC
AND GW4_NRDC = GW1_NRDC
AND GW4_TPDC = GW1_CDTPDC
AND GW4_EMISDF = GWU_CDTRP
AND GW4.D_E_L_E_T_ = ' '
INNER JOIN  %Table:GW3% GW3 ON GW3_FILIAL = GW4_FILIAL
AND GW3_CDESP = GW4_CDESP
AND GW3_EMISDF = GW4_EMISDF
AND GW3_SERDF = GW4_SERDF
AND GW3_NRDF = GW4_NRDF
AND GW3_DTEMIS = GW4_DTEMIS
AND GW3.D_E_L_E_T_ = ' '
LEFT JOIN  %Table:GW6% GW6 ON GW6_FILIAL = GW1_FILIAL
AND GW6_EMIFAT = GW1_EMISDC
AND GW6_SERFAT = GW1_SERDC
AND GW6_NRFAT = GW1_NRDC
AND GW6.D_E_L_E_T_ = ' '
WHERE GW1_DTEMIS BETWEEN %Exp:MV_PAR01% AND %Exp:MV_PAR02%
  AND GW1_FILIAL BETWEEN %Exp:MV_PAR03% AND %Exp:MV_PAR04%
  AND A4_COD BETWEEN %Exp:MV_PAR05% AND %Exp:MV_PAR06%
  AND A1_EST BETWEEN %Exp:MV_PAR07% AND %Exp:MV_PAR08%
  AND GW1_EMISDC BETWEEN %Exp:MV_PAR09% AND %Exp:MV_PAR10%

  AND GW1.D_E_L_E_T_ = ' ';


ORDER BY GW1_NRDC, GW1_SERDC

EndSql
*/
BeginSQL Alias cAlias

SELECT DISTINCT A1_NOME,
                GW1_NRDC,
                GW1_SERDC,
                GU7_NMCID,
                GU7_CDUF,
                A4_NOME,

  (SELECT SUM(GW8_VALOR)
   FROM %Table:GW8% GW8
   WHERE GW8_FILIAL = GW1.GW1_FILIAL
     AND GW8_NRDC = GW1.GW1_NRDC
     AND GW8_SERDC = GW1.GW1_SERDC
     AND GW8.D_E_L_E_T_ = ' ') AS GW8_VALOR,

  (SELECT SUM(GWI_VLFRET)
   FROM %Table:GWI% GWI
   WHERE GWI_FILIAL = GWF.GWF_FILIAL
     AND GWI_NRCALC = GWF.GWF_NRCALC
     AND GWI_TOTFRE = '1'
     AND GWI.D_E_L_E_T_ = ' ') /
  (SELECT SUM(GW8_VALOR)
   FROM %Table:GW8% GW8
   WHERE GW8_NRDC + GW8_SERDC IN
       (SELECT DISTINCT GWH_NRDC+ GWH_SERDC AS GWH_NRDC
        FROM %Table:GWH% GWH
        WHERE GWH_NRCALC IN
            (SELECT GWF_NRCALC
             FROM %Table:GWF% GWF
             WHERE GWF_NRROM = GW1.GW1_NRROM
               AND GWF_EMIDES = GW1.GW1_CDDEST
               AND GWF.D_E_L_E_T_ = ' ')
          AND GWH.D_E_L_E_T_ = ' ')) *
  (SELECT SUM(GW8_VALOR)
   FROM %Table:GW8% GW8
   WHERE GW8_FILIAL = GW1.GW1_FILIAL
     AND GW8_NRDC = GW1.GW1_NRDC
     AND GW8_SERDC = GW1.GW1_SERDC
     AND GW8.D_E_L_E_T_ = ' ') AS GWF_VALFRT,
                                       GW3_VLDF/
  (SELECT SUM(GW8_VALOR)
   FROM %Table:GW8% GW8
   WHERE GW8_NRDC + GW8_SERDC IN
       (SELECT DISTINCT GWH_NRDC+ GWH_SERDC AS GWH_NRDC
        FROM %Table:GWH% GWH
        WHERE GWH_NRCALC IN
            (SELECT GWF_NRCALC
             FROM %Table:GWF% GWF
             WHERE GWF_NRROM = GW1.GW1_NRROM
               AND GWF_EMIDES = GW1.GW1_CDDEST
               AND GWF.D_E_L_E_T_ = ' ')
          AND GWH.D_E_L_E_T_ = ' ')) *
  (SELECT SUM(GW8_VALOR)
   FROM %Table:GW8% GW8
   WHERE GW8_FILIAL = GW1.GW1_FILIAL
     AND GW8_NRDC = GW1.GW1_NRDC
     AND GW8_SERDC = GW1.GW1_SERDC
     AND GW8.D_E_L_E_T_ = ' ') AS GW3_VLDF,
                                       (
                                          (SELECT SUM(GWI_VLFRET)
                                           FROM %Table:GWI% GWI
                                           WHERE GWI_FILIAL = GWF.GWF_FILIAL
                                             AND GWI_NRCALC = GWF.GWF_NRCALC
                                             AND GWI_TOTFRE = '1'
                                             AND GWI.D_E_L_E_T_ = ' ') /
                                          (SELECT SUM(GW8_VALOR)
                                           FROM %Table:GW8% GW8
                                           WHERE GW8_NRDC + GW8_SERDC IN
                                               (SELECT DISTINCT GWH_NRDC+ GWH_SERDC AS GWH_NRDC
                                                FROM %Table:GWH% GWH
                                                WHERE GWH_NRCALC IN
                                                    (SELECT GWF_NRCALC
                                                     FROM %Table:GWF% GWF
                                                     WHERE GWF_NRROM = GW1.GW1_NRROM
                                                       AND GWF_EMIDES = GW1.GW1_CDDEST
                                                       AND GWF.D_E_L_E_T_ = ' ')
                                                  AND GWH.D_E_L_E_T_ = ' ')) *
                                          (SELECT SUM(GW8_VALOR)
                                           FROM %Table:GW8% GW8
                                           WHERE GW8_FILIAL = GW1.GW1_FILIAL
                                             AND GW8_NRDC = GW1.GW1_NRDC
                                             AND GW8_SERDC = GW1.GW1_SERDC
                                             AND GW8.D_E_L_E_T_ = ' ') /
                                          (SELECT SUM(GW8_VALOR)
                                           FROM %Table:GW8% GW8
                                           WHERE GW8_FILIAL = GW1.GW1_FILIAL
                                             AND GW8_NRDC = GW1.GW1_NRDC
                                             AND GW8_SERDC = GW1.GW1_SERDC
                                             AND GW8.D_E_L_E_T_ = ' ')) *100 AS PORC1,
                                       (GW3_VLDF/
                                          (SELECT SUM(GW8_VALOR)
                                           FROM %Table:GW8% GW8
                                           WHERE GW8_NRDC + GW8_SERDC IN
                                               (SELECT DISTINCT GWH_NRDC+ GWH_SERDC AS GWH_NRDC
                                                FROM %Table:GWH% GWH
                                                WHERE GWH_NRCALC IN
                                                    (SELECT GWF_NRCALC
                                                     FROM %Table:GWF% GWF
                                                     WHERE GWF_NRROM = GW1.GW1_NRROM
                                                       AND GWF_EMIDES = GW1.GW1_CDDEST
                                                       AND GWF.D_E_L_E_T_ = ' ')
                                                  AND GWH.D_E_L_E_T_ = ' ')) *
                                          (SELECT SUM(GW8_VALOR)
                                           FROM %Table:GW8% GW8
                                           WHERE GW8_FILIAL = GW1.GW1_FILIAL
                                             AND GW8_NRDC = GW1.GW1_NRDC
                                             AND GW8_SERDC = GW1.GW1_SERDC
                                             AND GW8.D_E_L_E_T_ = ' ') /
                                          (SELECT SUM(GWI_VLFRET)
                                           FROM %Table:GWI% GWI
                                           WHERE GWI_FILIAL = GWF.GWF_FILIAL
                                             AND GWI_NRCALC = GWF.GWF_NRCALC
                                             AND GWI_TOTFRE = '1'
                                             AND GWI.D_E_L_E_T_ = ' ') /
                                          (SELECT SUM(GW8_VALOR)
                                           FROM %Table:GW8% GW8
                                           WHERE GW8_NRDC + GW8_SERDC IN
                                               (SELECT DISTINCT GWH_NRDC+ GWH_SERDC AS GWH_NRDC
                                                FROM %Table:GWH% GWH
                                                WHERE GWH_NRCALC IN
                                                    (SELECT GWF_NRCALC
                                                     FROM %Table:GWF% GWF
                                                     WHERE GWF_NRROM = GW1.GW1_NRROM
                                                       AND GWF_EMIDES = GW1.GW1_CDDEST
                                                       AND GWF.D_E_L_E_T_ = ' ')
                                                  AND GWH.D_E_L_E_T_ = ' ')) *
                                          (SELECT SUM(GW8_VALOR)
                                           FROM %Table:GW8% GW8
                                           WHERE GW8_FILIAL = GW1.GW1_FILIAL
                                             AND GW8_NRDC = GW1.GW1_NRDC
                                             AND GW8_SERDC = GW1.GW1_SERDC
                                             AND GW8.D_E_L_E_T_ = ' '))* 100 AS PORC2

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
INNER JOIN %Table:GWH% GWH ON GWH_FILIAL = GW1_FILIAL
AND GWH_EMISDC = GW1_EMISDC
AND GWH_SERDC = GW1_SERDC
AND GWH_NRDC = GW1_NRDC
AND GWH.D_E_L_E_T_ = ' '
INNER JOIN %Table:GWF% GWF ON GWF_FILIAL = GWH_FILIAL
AND GWF_NRCALC = GWH_NRCALC
AND GWF_TRANSP = GWU_CDTRP
AND GWF_CIDDES = GWU_NRCIDD
AND GWF.D_E_L_E_T_ = ' '
INNER JOIN %Table:GW4% GW4 ON GW4_FILIAL = GW1_FILIAL
AND GW4_EMISDC = GW1_EMISDC
AND GW4_SERDC = GW1_SERDC
AND GW4_NRDC = GW1_NRDC
AND GW4_TPDC = GW1_CDTPDC
AND GW4_EMISDF = GWU_CDTRP
AND GW4.D_E_L_E_T_ = ' '
INNER JOIN %Table:GW3% GW3 ON GW3_FILIAL = GW4_FILIAL
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
  

ORDER BY GW1_NRDC, GW1_SERDC

EndSql

cSQLLog := MemoWrite(Criatrab(,.f.)+".sql",GetLastQuery()[2])

oSection1b:EndQuery()    
//oSection2b:SetParentQuery()

//Rateia(cAlias)

//RetiraDup(cAlias)

oReport:SetMeter((cAlias)->(RecCount()))  

//oSection2b:SetParentFilter({|cParam| (cAlias)->A1_COD == cParam}, {|| (cAlias)->A1_COD})

//oSection1b:Cell("PORC3"):SetValue(Val(oSection1b:Cell("PORC2"):GetValue()) - Val(oSection1b:Cell("PORC1"):GetValue()))    // Porcentagem 3.

//oSection1b:Print()	   

(cAlias)->(DbGoTop())

While !(cAlias)->(Eof())

	oSection1b:Cell("A1_NOME"):SetValue((cAlias)->A1_NOME)
	oSection1b:Cell("GW1_NRDC"):SetValue((cAlias)->GW1_NRDC)
	oSection1b:Cell("GW1_SERDC"):SetValue((cAlias)->GW1_SERDC)
	oSection1b:Cell("GU7_NMCID"):SetValue((cAlias)->GU7_NMCID)
	oSection1b:Cell("GU7_CDUF"):SetValue((cAlias)->GU7_CDUF)
	oSection1b:Cell("A4_NOME"):SetValue((cAlias)->A4_NOME)
	oSection1b:Cell("GW8_VALOR"):SetValue((cAlias)->GW8_VALOR)
	oSection1b:Cell("GWF_VALFRT"):SetValue((cAlias)->GWF_VALFRT)
	oSection1b:Cell("GW3_VLDF"):SetValue((cAlias)->GW3_VLDF)
	oSection1b:Cell("PORC1"):SetValue((cAlias)->PORC1)
	oSection1b:Cell("PORC2"):SetValue((cAlias)->PORC2)
	nPorc1 := (cAlias)->PORC1
	nPorc2 := (cAlias)->PORC2
	nPorc3 := nPorc2 - nPorc1
	oSection1b:Cell("PORC3"):SetValue(nPorc3)	
	oSection1b:PrintLine()
	(cAlias)->(DbSkip())
	oReport:IncMeter(1)
EndDo

oSection1b:Finish()

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

/*// Rateia os Fretes
Static Function Rateia(cAlias)
Local aDocs 	:= {}
Local aRats 	:= {}
Local aNrCal	:= {}
Local cNrCalc	:= ""
Local ix		:= 0


DbSelectArea(cAlias)
DbGoTop()
While !Eof()
    aAdd(aDocs,(cAlias)->GW1_NRDC,(cAlias)->GW1_SERDC,(cAlias)->GWF_NRCALC,(cAlias)->GW8_VALOR,;
    (cAlias)->GWF_VALFRT,(cAlias)->GW3_VLDF,(cAlias)->PORC3,(cAlias)->PORC1,(cAlias)->PORC2)   
	(cAlias)->(DbSkip())
EndDo

aSort(aDocs)
For Ix := 1 To Len(aDocs)	
	aAdd(aNrCalc,aDocs[ix][3]) 		
Next Ix
aSort(aNrCalc)

For ix := 1 To Len(aNrCalc)
	If (aNrCalc[ix] == cNrCalc)
		aAdd(aRats,"","",cNrCalc,0,0,0,0,0,0)
 	Endif
 	cNrCalc := aNrCalc[ix]
Next ix

For ix := 1 To Len(aDocs)
   
   If AchaNrCalc(aRats, aDocs[ix][3])
   	aDocs[ix] := RegraX(aDocs[ix], aDocs)
   Endif
   
Next ix

Return           


Static Function RegraX(aLinha,aDocs)
Local nValMerc 	:= 0
Local ix		:= 0
Local x			:= 0                          

// Valor Total da Mercadoria.
For ix := 1 To Len(aDocs)
	If aDocs[ix][3] == aLinha[1][3]
		nValMerc += aDocs[ix][4]	
	Endif
Next ix

/* nValMerc -- aLinha[1][5]
 X		  -- aLinha[1][4]
 
 nValMerc*aLinha[1][4] = X*aLinha[1][5] */
     //VAL.FRETE  /  VAL.MERC TOTAL*VAL.MERC.DOC

/*x := aLinha[1][5] / (nValMerc*aLinha[1][4])
aLinha[1][5] := X  // Valor Rateado do Frete.
aLinha[1]
Return


Static Function AchaNrCalc(aRats,cNrCalc)
Local ix := 0

For ix := 1 to Len(aRats)

	If cNrCalc == aRats[ix][3]
		Return .t.
	Endif

Next ix
	
Return .f.       

Static Function RetiraDup(cAlias)

DbSelectArea(cAlias)

While !Eof()
	 RecLock(cAlias,.F.)
	(cAlias)->(DbDelete())
	(cAlias)->(MsUnlock())
	(cAlias)->(DbSkip())
EndDo


Return */
         
 /*
(SELECT SUM(GWI_VLFRET)
   FROM  GWI010 GWI
   WHERE  GWI_NRCALC IN (SELECT GWF_NRCALC FROM GWF010 GWF
WHERE GWF_NRROM = GW1.GW1_NRROM
 AND GWF_EMIDES = GW1.GW1_CDDEST AND GWF.D_E_L_E_T_ = ' ' )
     AND GWI_TOTFRE = '1'
     AND GWI.D_E_L_E_T_ = ' ') / 
     
(SELECT SUM(GW8_VALOR)
FROM GW8010 GW8
WHERE GW8_NRDC + GW8_SERDC IN
    ( SELECT DISTINCT GWH_NRDC+ GWH_SERDC AS GWH_NRDC
     FROM GWH010 GWH
     WHERE GWH_NRCALC IN
         (SELECT GWF_NRCALC
          FROM GWF010 GWF
          WHERE GWF_NRROM =  GW1.GW1_NRROM
            AND GWF_EMIDES = GW1.GW1_CDDEST
            AND GWF.D_E_L_E_T_ = ' ')
       AND GWH.D_E_L_E_T_ = ' ' ) )

     
 *
 
(SELECT SUM(GW8_VALOR)
   FROM  GW8010 GW8
   WHERE GW8_FILIAL = GW1.GW1_FILIAL
     AND GW8_NRDC = GW1.GW1_NRDC
     AND GW8_SERDC = GW1.GW1_SERDC
     AND GW8.D_E_L_E_T_ = ' ' ) 
                                       

   */ 
   
   
/*

                                       (GW3_VLDF/
                                          (SELECT SUM(GW8_VALOR)
                                           FROM %Table:GW8% GW8
                                           WHERE GW8_NRDC + GW8_SERDC IN
                                               (SELECT DISTINCT GWH_NRDC+ GWH_SERDC AS GWH_NRDC
                                                FROM %Table:GWH% GWH
                                                WHERE GWH_NRCALC IN
                                                    (SELECT GWF_NRCALC
                                                     FROM %Table:GWF% GWF
                                                     WHERE GWF_NRROM = GW1.GW1_NRROM
                                                       AND GWF_EMIDES = GW1.GW1_CDDEST
                                                       AND GWF.D_E_L_E_T_ = ' ')
                                                  AND GWH.D_E_L_E_T_ = ' ')) *
                                          (SELECT SUM(GW8_VALOR)
                                           FROM %Table:GW8% GW8
                                           WHERE GW8_FILIAL = GW1.GW1_FILIAL
                                             AND GW8_NRDC = GW1.GW1_NRDC
                                             AND GW8_SERDC = GW1.GW1_SERDC
                                             AND GW8.D_E_L_E_T_ = ' ') /
                                          (SELECT SUM(GW8_VALOR)
                                           FROM %Table:GW8% GW8
                                           WHERE GW8_FILIAL = GW1.GW1_FILIAL
                                             AND GW8_NRDC = GW1.GW1_NRDC
                                             AND GW8_SERDC = GW1.GW1_SERDC
                                             AND GW8.D_E_L_E_T_ = ' '))* 100 AS PORC3


*/