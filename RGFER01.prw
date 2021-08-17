#INCLUDE "Topconn.ch"
#INCLUDE "Protheus.ch"
#INCLUDE "Report.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณRGFER01   บAutor  ณEduardo Biazuto     บ Data ณ 21/08/2014  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRelatorio Gerencial GFE                                     บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณNeftali x Eletromega                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function RGFER01()

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณDeclaracao de variaveis                   ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Private oReport  := Nil
Private oSecCab	 := Nil
Private cPerg 	 := PadR ("RGFER01", Len (SX1->X1_GRUPO))
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณCriacao e apresentacao das perguntas      ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
CriaSX1 ()
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณDefinicoes/preparacao para impressao      ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
ReportDef()
oReport	:PrintDialog()	

Return Nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณReportDef บAutor  ณEduardo Biazutto    บ Data ณ 21/08/2014  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณNeftali x Eletromega                                       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ReportDef()

oReport := TReport():New("RGFER01","Impressใo",cPerg,{|oReport| PrintReport(oReport)},"Impressใo")
oReport:SetLandscape(.T.)

oSecCab := TRSection():New( oReport , "Dados", {"QRY"} )
TRCell():New( oSecCab, "GU3_CDEMIT" , "QRY") //Codigo
TRCell():New( oSecCab, "GU3_NMEMIT" , "QRY") //Razao Social
TRCell():New( oSecCab, "GW1_NRDC"   , "QRY") //Nota Fiscal
TRCell():New( oSecCab, "GW1_SERDC"  , "QRY") //Serie
TRCell():New( oSecCab, "GU7_NMCID"  , "QRY") //Cidade
TRCell():New( oSecCab, "GU7_CDUF"   , "QRY") //Estado
TRCell():New( oSecCab, "GWU_CDTRP"  , "QRY") //Cod. Transp.
TRCell():New( oSecCab, "GWU_NMTRP " , "QRY") //Cod. Transp.
TRCell():New( oSecCab, "GW8_VALOR"  , "QRY") //Vlr. Merc.
TRCell():New( oSecCab, "GWI_VLFRET" , "QRY") //Frete Calc.
TRCell():New( oSecCab, "GW3_VLDF"   , "QRY") //Frete Pago
oSecCab:SetLeftMargin(2)

Return nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPrintReportบAutor ณEduardo Biazutto    บ Data ณ 21/08/2014  บฑฑ
ฑฑฬออออออออออุอออออออออออสออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณNeftali x Eletromega                                      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function PrintReport(oReport)

Local cQuery     := ""

Pergunte(cPerg, .F. )

cQuery += "  SELECT " + CRLF
cQuery += "     GU3.GU3_CDEMIT " + CRLF 
cQuery += "    ,GU3.GU3_NMEMIT " + CRLF 
cQuery += "    ,GW1.GW1_NRDC " + CRLF  
cQuery += "    ,GW1.GW1_SERDC " + CRLF 
cQuery += "    ,GU7.GU7_NMCID " + CRLF 
cQuery += "    ,GU7.GU7_CDUF " + CRLF 
cQuery += "    ,GWU.GWU_CDTRP" + CRLF 
cQuery += "    ,TRA.GU3_NMEMIT NOME_TRANSP " + CRLF 
cQuery += "    ,SUM(GW8.GW8_VALOR)  VLR_MERC" + CRLF 
cQuery += "    ,SUM(GWI.GWI_VLFRET) VLR_FRETE" + CRLF 
cQuery += "    ,GW3.GW3_VLDF" + CRLF 
cQuery += "    FROM " + RetSqlName("GW1") + " GW1 " + CRLF
cQuery += "  LEFT OUTER JOIN " + RetSqlName("GU3") + " GU3 ON " + CRLF
cQuery += "         GU3.GU3_FILIAL = '" + xFilial("GU3") + "' " + CRLF
cQuery += "     AND GU3.GU3_CDEMIT = GW1.GW1_CDDEST " + CRLF
cQuery += "     AND GU3.D_E_L_E_T_ = ' ' " + CRLF
cQuery += "  INNER JOIN " + RetSqlName("GU7") + " GU7 ON " + CRLF
cQuery += "         GU7.GU7_FILIAL = '" + xFilial("GU7") + "' " + CRLF
cQuery += "     AND GU7.GU7_NRCID  = GW1.GW1_ENTNRC " + CRLF
cQuery += "     AND GU7.D_E_L_E_T_ = ' ' " + CRLF
cQuery += "  INNER JOIN " + RetSqlName("GWU") + " GWU ON " + CRLF
cQuery += "         GWU.GWU_FILIAL  = '" + xFilial("GWU") + "' " + CRLF
cQuery += "     AND GWU.GWU_CDTPDC  = GW1.GW1_CDTPDC  " + CRLF
cQuery += "     AND GWU.GWU_NRDC    = GW1.GW1_NRDC  " + CRLF
cQuery += "     AND GWU.GWU_SERDC   = GW1.GW1_SERDC " + CRLF
cQuery += "     AND GWU.D_E_L_E_T_  = ' ' " + CRLF
cQuery += "  INNER JOIN " + RetSqlName("GU3") + " TRA ON " + CRLF
cQuery += "         TRA.GU3_FILIAL = '" + xFilial("GU3") + "' " + CRLF
cQuery += "     AND TRA.GU3_CDEMIT = GWU.GWU_CDTRP " + CRLF
cQuery += "     AND TRA.D_E_L_E_T_ = ' ' " + CRLF
cQuery += "  INNER JOIN " + RetSqlName("GW8") + " GW8 ON " + CRLF
cQuery += "         GW8.GW8_FILIAL  = '" + xFilial("GW8") + "' " + CRLF
cQuery += "     AND GW8.GW8_CDTPDC  = GW1.GW1_CDTPDC  " + CRLF
cQuery += "     AND GW8.GW8_NRDC    = GW1.GW1_NRDC  " + CRLF
cQuery += "     AND GW8.GW8_SERDC   = GW1.GW1_SERDC " + CRLF
cQuery += "     AND GW8.D_E_L_E_T_  = ' ' " + CRLF
cQuery += "  INNER JOIN " + RetSqlName("GW3") + " GW3 ON " + CRLF
cQuery += "         GW3.GW3_FILIAL  = '" + xFilial("GW3") + "' " + CRLF
cQuery += "     AND GW3.GW3_NRDF    = GW1.GW1_NRDC  " + CRLF
cQuery += "     AND GW3.GW3_SERDF   = GW1.GW1_SERDC " + CRLF
cQuery += "     AND GW3.D_E_L_E_T_  = ' ' " + CRLF
cQuery += "  INNER JOIN " + RetSqlName("GWM") + " GWM ON " + CRLF
cQuery += "         GWM.GWM_FILIAL = GW1.GW1_FILIAL" + CRLF
cQuery += "     AND GWM.GWM_CDTPDC = GW1.GW1_CDTPDC" + CRLF
cQuery += "     AND GWM.GWM_EMISDC = GW1.GW1_EMISDC" + CRLF
cQuery += "     AND GWM.GWM_SERDC  = GW1.GW1_SERDC" + CRLF
cQuery += "     AND GWM.GWM_NRDC   = GW1.GW1_NRDC" + CRLF
cQuery += "     AND GWM.D_E_L_E_T_ = ' '" + CRLF
cQuery += "  INNER JOIN " + RetSqlName("GWF") + " GWF ON " + CRLF
cQuery += "         GWF.GWF_FILIAL = GWM.GWM_FILIAL" + CRLF
cQuery += "     AND GWF.GWF_NRCALC = GWM.GWM_NRDOC"
cQuery += "     AND GWF.GWF_DTCRIA = GWM.GWM_DTEMIS"
cQuery += "     AND GWF.D_E_L_E_T_ = ''"            
cQuery += "  INNER JOIN " + RetSqlName("GWI") + " GWI ON " + CRLF
cQuery += "         GWI.GWI_FILIAL = GWF.GWF_FILIAL "
cQuery += "     AND GWI.GWI_NRCALC = GWF.GWF_NRCALC "
cQuery += "     AND GWI.D_E_L_E_T_ = ''"            
cQuery += "   WHERE GW1.GW1_FILIAL BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "' " + CRLF
cQuery += "     AND GW1.GW1_DTEMIS BETWEEN '" + dToS(MV_PAR03) + "' AND '" + dToS(MV_PAR04) + "' " + CRLF
cQuery += "     AND GW1.GW1_CDDEST BETWEEN '" + MV_PAR05 + "' AND '" + MV_PAR06 + "' " + CRLF
cQuery += "     AND GW1.D_E_L_E_T_ = ' ' " + CRLF
cQuery += "  GROUP BY " + CRLF
cQuery += "     GU3.GU3_CDEMIT " + CRLF 
cQuery += "    ,GU3.GU3_NMEMIT " + CRLF 
cQuery += "    ,GW1.GW1_NRDC " + CRLF  
cQuery += "    ,GW1.GW1_SERDC " + CRLF 
cQuery += "    ,GU7.GU7_NMCID " + CRLF 
cQuery += "    ,GU7.GU7_CDUF " + CRLF 
cQuery += "    ,GWU.GWU_CDTRP" + CRLF 
cQuery += "    ,TRA.GU3_NMEMIT " + CRLF 
cQuery += "    ,GW3.GW3_VLDF" + CRLF 
cQuery += "    ,GW1.GW1_DTEMIS " + CRLF
cQuery += "  ORDER BY " + CRLF
cQuery += "     GW1.GW1_DTEMIS " + CRLF

cQuery := ChangeQuery(cQuery)

If Select("QRY") > 0
	Dbselectarea("QRY")
	QRY->(DbClosearea())
EndIf

TcQuery cQuery New Alias "QRY"
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณAdicionar campos que sejam do tipo data.                          ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
TcSetField("QRY","GW1_DTEMIS","D",TamSx3("GW1_DTEMIS")[1],TamSx3("GW1_DTEMIS")[2])

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณDispara a impressใo.                                              ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
oSecCab:BeginQuery()
oSecCab:EndQuery({{"QRY"},cQuery})    
oSecCab:Print()//Impressao Simples

Return nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCriaSX1   บAutor  ณ Vinํcius Moreira   บ Data ณ 14/06/2012  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Cria perguntas.                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function CriaSX1 ()

PutSx1(cPerg,"01","Filial de?"        ,'','',"mv_ch1","C",TamSx3 ("GW1_FILIAL")[1] ,0,,"G",""             ,"SM0","","","mv_par01","","","","","","","","","","","","","","","","")
PutSx1(cPerg,"02","Filial ate?"       ,'','',"mv_ch2","C",TamSx3 ("GW1_FILIAL")[1] ,0,,"G",""             ,"SM0","","","mv_par02","","","","","","","","","","","","","","","","")
PutSx1(cPerg,"03","Emissao de?"       ,'','',"mv_ch3","D",TamSx3 ("GW1_DTEMIS")[1] ,0,,"G",""             ,""   ,"","","mv_par03","","","","","","","","","","","","","","","","")
PutSx1(cPerg,"04","Emissao ate?"      ,'','',"mv_ch4","D",TamSx3 ("GW1_DTEMIS")[1] ,0,,"G",""             ,""   ,"","","mv_par04","","","","","","","","","","","","","","","","")
PutSx1(cPerg,"05","Cliente de?"       ,'','',"mv_ch5","C",TamSx3 ("GW1_CDDEST")[1] ,0,,"G",""             ,"GU3","","","mv_par05","","","","","","","","","","","","","","","","")
PutSx1(cPerg,"06","Cliente ate?"      ,'','',"mv_ch6","C",TamSx3 ("GW1_CDDEST")[1] ,0,,"G",""             ,"GU3","","","mv_par06","","","","","","","","","","","","","","","","")

Return nil