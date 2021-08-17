#INCLUDE "PROTHEUS.CH"
#INCLUDE "REPORT.CH"
#INCLUDE "TOPCONN.CH"

/*----------------------------------------------------------|
| Autor | Claudino Domingues              | Data 05/03/18 	| 
|-----------------------------------------------------------|
| Função: MEGA38											|
|-----------------------------------------------------------|
| Relatorio Lead Time Import.         	                    |
------------------------------------------------------------*/

User Function MEGA38()

Local oReport

Private nDiv01 := 0
Private nDiv02 := 0
Private nDiv03 := 0
Private nDiv04 := 0
Private nDiv05 := 0
Private nDiv06 := 0
Private nDiv07 := 0
Private nDiv08 := 0
Private nDiv09 := 0
Private nDiv10 := 0


Private nProd01 := 0
Private nProd02 := 0
Private nMar 	:= 0
Private nPorto	:= 0
Private nPrev	:= 0
Private nReal	:= 0

Private nScN2 	:= 0
Private nN2Nf 	:= 0
Private nDbNf 	:= 0
Private nScNf	:= 0

Private nDesemb :=""

oReport := ReportDef()
oReport:PrintDialog() // Imprime os dados na Tela(Preview).

Return

Static Function ReportDef()

Local oReport  // Objeto principal do Relatório TReport.
Local oSection // Objeto da Seção. 
Local oBreak   // Objeto da Quebra(Sub Total Num SC).
Local oTotal   // Objeto do Total Geral(Soma dos Sub Totais Num SC).
Local cPerg    := PADR("MEGA38",10) // Grupo de Perguntas.

Pergunte(cPerg,.T.) // Caso o parametro esteja como .T. o sistema ira apresentar a tela de perguntas antes que abrir a tela configuração do relatório.

// Apresenta a tela de impressão para o usuário configurar o relatório.
oReport:=TReport():New("MEGA38","MEGA38 - Lead Time Import ","MEGA38",{|oReport| PrintReport(oReport,oSection,cPerg)},"Lead Time Import")
oReport:SetLandscape(.T.) 
oSection:=TRSection():New(oReport,"MEGA38 - Lead Time Import ",{"SB1"})

If MV_PAR15 = 1 //1 = Analitico
		oSection:SetTotalInLine(.T.) // Define se os totalizadores da sessão serão impressos em linha ou coluna.

		TRCell():New(oSection ,"FILIAL"    ,/*Alias*/,"Fl"        ,/*Picture*/         ,02 /*Tamanho*/,/*lPixel*/,/*{|| code-black de impressão}*/,,,"LEFT")
		TRCell():New(oSection ,"NUMSC"     ,/*Alias*/,"Num.SC"     ,/*Picture*/        ,01 /*Tamanho*/,/*lPixel*/,/*{|| code-black de impressão}*/,,,"LEFT")
		TRCell():New(oSection ,"DTEMISC"   ,/*Alias*/,"Emis. SC"   ,/*Picture*/      ,01 /*Tamanho*/,/*lPixel*/,/*{|| code-black de impressão}*/,,,"LEFT") 
		TRCell():New(oSection ,"CODPROD"   ,/*Alias*/,"Codigo"   ,/*Picture*/         ,01 /*Tamanho*/,/*lPixel*/,/*{|| code-black de impressão}*/,,,"LEFT")
		TRCell():New(oSection ,"DESCPROD"  ,/*Alias*/,"Descricao do Produto"  ,/*Picture*/,28 /*Tamanho*/,/*lPixel*/,/*{|| code-black de impressão}*/,,,"LEFT")
		TRCell():New(oSection ,"QTDSC"     ,/*Alias*/,"Quantidade","@E 9,999,999.99" ,12 /*Tamanho*/,/*lPixel*/,/*{|| code-black de impressão}*/,,,"RIGHT")
		TRCell():New(oSection ,"ITEMSC"    ,/*Alias*/,"ItSC"   ,/*Picture*/           ,01 /*Tamanho*/,/*lPixel*/,/*{|| code-black de impressão}*/,,,"LEFT")
		TRCell():New(oSection ,"ITEMPC"    ,/*Alias*/,"ItPC"   ,/*Picture*/           ,01 /*Tamanho*/,/*lPixel*/,/*{|| code-black de impressão}*/,,,"LEFT")
		TRCell():New(oSection ,"NUMPC"     ,/*Alias*/,"Num.PC"     ,/*Picture*/        ,01 /*Tamanho*/,/*lPixel*/,/*{|| code-black de impressão}*/,,,"LEFT")
		TRCell():New(oSection ,"DTEMIPC"   ,/*Alias*/,"Emis. PC"   ,/*Picture*/      ,01 /*Tamanho*/,/*lPixel*/,/*{|| code-black de impressão}*/,,,"LEFT")
		TRCell():New(oSection ,"DTLIB01"   ,/*Alias*/,"Lib N1"    ,/*Picture*/         ,10 /*Tamanho*/,/*lPixel*/,/*{|| code-black de impressão}*/,,,"LEFT")
		TRCell():New(oSection ,"DTLIB02"   ,/*Alias*/,"Lib N2"    ,/*Picture*/         ,10 /*Tamanho*/,/*lPixel*/,/*{|| code-black de impressão}*/,,,"LEFT")
		TRCell():New(oSection ,"DTDESEMB"  ,/*Alias*/,"Desemb"    ,/*Picture*/         ,10 /*Tamanho*/,/*lPixel*/,/*{|| code-black de impressão}*/,,,"LEFT")
		TRCell():New(oSection ,"NUMNF"     ,/*Alias*/,"Numero NF" ,/*Picture*/         ,01 /*Tamanho*/,/*lPixel*/,/*{|| code-black de impressão}*/,,,"LEFT")
		TRCell():New(oSection ,"SERIENF"   ,/*Alias*/,"Ser"       ,/*Picture*/         ,01 /*Tamanho*/,/*lPixel*/,/*{|| code-black de impressão}*/,,,"LEFT")
		TRCell():New(oSection ,"DTEMINF"   ,/*Alias*/,"Emis. NF"  ,/*Picture*/         ,01 /*Tamanho*/,/*lPixel*/,/*{|| code-black de impressão}*/,,,"LEFT")
		TRCell():New(oSection ,"LEADTIME1" ,/*Alias*/,"SCxN2"   ,/*Picture*/         ,01 /*Tamanho*/,/*lPixel*/,/*{|| code-black de impressão}*/,,,"LEFT")
		TRCell():New(oSection ,"LEADTIME3" ,/*Alias*/,"N2xNF"   ,/*Picture*/         ,01 /*Tamanho*/,/*lPixel*/,/*{|| code-black de impressão}*/,,,"LEFT")
		TRCell():New(oSection ,"LEADTIME4" ,/*Alias*/,"DBxNF"   ,/*Picture*/         ,01 /*Tamanho*/,/*lPixel*/,/*{|| code-black de impressão}*/,,,"LEFT")
		TRCell():New(oSection ,"LEADTIME5" ,/*Alias*/,"SCxNF"   ,/*Picture*/         ,01 /*Tamanho*/,/*lPixel*/,/*{|| code-black de impressão}*/,,,"LEFT")
		
		oBreak:=TRBreak():New(oSection,oSection:Cell("NUMSC"),"Total SC",.F.) // Quebra por Produto.
		oTotal:=TRFunction():New(oSection:Cell("QTDSC"),NIL,"SUM",oBreak,/*Titulo*/,/*cPicture*/,/*uFormula*/,.F./*Total da Seção*/,.F./*Total Geral*/,.F./*Total da Pagina*/)

		oSection:SetNoFilter("SC1") // Retira o filtro interno do TREPORT na tabela.
Else //2 = Sintetico
		oSection:SetTotalInLine(.T.) // Define se os totalizadores da sessão serão impressos em linha ou coluna.

		TRCell():New(oSection ,"FILIAL"    ,,"Fil"	 	   			,,04,,,			,,"LEFT")
		TRCell():New(oSection ,"FORNE"     ,,"Fornecedor"			,,10,,,			,,"LEFT")
		TRCell():New(oSection ,"NUMPC"     ,,"Ped.Compra"	     	,,10,,,"CENTER",,"CENTER")
		TRCell():New(oSection ,"DTLIB02"   ,,"Dt.Lib.N2"    		,,11,,,			,,"LEFT")
		TRCell():New(oSection ,"NUMDESEMB" ,,"Desembaraco" 			,,18,,,"CENTER",,"CENTER")
		TRCell():New(oSection ,"DTDESEMB"  ,,"Dt.Desembaraco"  		,,14,,,"CENTER",,"CENTER")
		TRCell():New(oSection ,"NUMNF"     ,,"N.Fiscal"		  		,,11,,,			,,"LEFT")
		TRCell():New(oSection ,"DTEMINF"   ,,"Data NF"	 			,,19,,,"CENTER",,"CENTER")
		TRCell():New(oSection ,"LEADTIME1" ,,"SCxN2"	   	   		,"@E 9,999.99",08,,,"RIGHT",,"RIGHT")
	  	TRCell():New(oSection ,"LEADTIME3" ,,"N2xNF"   				,"@E 9,999.99",08,,,"RIGHT",,"RIGHT")
		TRCell():New(oSection ,"LEADTIME4" ,,"DBxNF"   				,"@E 9,999.99",08,,,"RIGHT",,"RIGHT")
		TRCell():New(oSection ,"LEADTIME5" ,,"SCxNF"   				,"@E 9,999.99",08,,,"RIGHT",,"RIGHT")
		TRCell():New(oSection ,"PRODUCAO"  ,,"Producao"  			,"@E 9,999.99",08,,,"RIGHT",,"RIGHT")

		TRCell():New(oSection ,"PROD2"  	,,"Producao 2"  		,"@E 9,999.99",08,,,"RIGHT",,"RIGHT")
		
		TRCell():New(oSection ,"MAR"   	   	,,"Mar"       			,"@E 9,999.99",08,,,"RIGHT",,"RIGHT")
		TRCell():New(oSection ,"DESEMB"    ,,"Porto"  				,"@E 9,999.99",08,,,"RIGHT",,"RIGHT")
		TRCell():New(oSection ,"DIPROG"    ,,"Dias Programação"		,,19,,,"CENTER",,"CENTER")
		TRCell():New(oSection ,"ETD"       ,,"ETD"					,,08,,,			,,"LEFT")
		TRCell():New(oSection ,"LT_PRE"    ,,"LT Previsto"			,"@E 9,999.99",08,,,"RIGHT",,"RIGHT")
		TRCell():New(oSection ,"LT_REA"    ,,"LT Realizado"			,"@E 99,999.99",09,,,"RIGHT",,"RIGHT")

		oBreak:=TRBreak():New(oSection,oSection:Cell("NUMDESEMB"),"",.F.) // Quebra por Desembaraço.
		oBreak02:=TRBreak():New(oSection,oSection:Cell("FILIAL"),"MEDIA POR FILIAL",.F.) // Quebra por Filial
		
		TRFunction():New(oSection:Cell("LEADTIME1")	,NIL,"ONPRINT",oBreak02,"Media SC x N2"			,,{|| nScN2/nDiv07 	} 	/*uFormula*/,.F./*Total da Seção*/,.T./*Total Geral*/,.F./*Total da Pagina*/)
		TRFunction():New(oSection:Cell("LEADTIME3")	,NIL,"ONPRINT",oBreak02,"Media N2 x NF"			,,{|| nN2Nf/nDiv08 	} 	/*uFormula*/,.F./*Total da Seção*/,.T./*Total Geral*/,.F./*Total da Pagina*/)
		TRFunction():New(oSection:Cell("LEADTIME4")	,NIL,"ONPRINT",oBreak02,"Media DB x NF"			,,{|| nDbNf/nDiv09 	} 	/*uFormula*/,.F./*Total da Seção*/,.T./*Total Geral*/,.F./*Total da Pagina*/)
		TRFunction():New(oSection:Cell("LEADTIME5")	,NIL,"ONPRINT",oBreak02,"Media SC x NF"			,,{|| nScNf/nDiv10 	} 	/*uFormula*/,.F./*Total da Seção*/,.T./*Total Geral*/,.F./*Total da Pagina*/)

		TRFunction():New(oSection:Cell("PRODUCAO")	,NIL,"ONPRINT",oBreak02,"Media Producao"		,,{|| nProd01/nDiv01 	} 	/*uFormula*/,.F./*Total da Seção*/,.T./*Total Geral*/,.F./*Total da Pagina*/)
		TRFunction():New(oSection:Cell("PROD2")		,NIL,"ONPRINT",oBreak02,"Media Producao 2"		,,{|| nProd02/nDiv02 	} 	/*uFormula*/,.F./*Total da Seção*/,.T./*Total Geral*/,.F./*Total da Pagina*/)
		TRFunction():New(oSection:Cell("MAR")		,NIL,"ONPRINT",oBreak02,"Media Mar"				,,{|| nMar/nDiv03 		}	/*uFormula*/,.F./*Total da Seção*/,.T./*Total Geral*/,.F./*Total da Pagina*/)
		TRFunction():New(oSection:Cell("DESEMB")	,NIL,"ONPRINT",oBreak02,"Media Porto"			,,{|| nPorto/nDiv04		}	/*uFormula*/,.F./*Total da Seção*/,.T./*Total Geral*/,.F./*Total da Pagina*/)
		TRFunction():New(oSection:Cell("LT_PRE")	,NIL,"ONPRINT",oBreak02,"Media LT Previsto"		,,{|| nPrev/nDiv05 		}	/*uFormula*/,.F./*Total da Seção*/,.T./*Total Geral*/,.F./*Total da Pagina*/)
		TRFunction():New(oSection:Cell("LT_REA")	,NIL,"ONPRINT",oBreak02,"Media LT Realizado"	,,{|| nReal/nDiv06 		}	/*uFormula*/,.F./*Total da Seção*/,.T./*Total Geral*/,.F./*Total da Pagina*/)

EndIf

Return oReport

/*-------------------------------------------------*/

Static Function PrintReport(oReport,oSection)

Local cQuery     := ""
Local nLeadTi1   := 0
Local nLeadTi2   := 0
Local nLeadTi3   := 0
Local nLeadTi4   := 0
Local nLeadTi5   := 0
Local nLeadTi6	 := 0
Local nLeadTi7	 := 0
Local nLeadTi8	 := 0
Local nLeadTi9	 := 0

Local dDtLib1    := CTOD("  /  /  ") 
Local dDtLib2    := CTOD("  /  /  ")
Local dDtDesemb  := CTOD("  /  /  ")
Local nwDesemb	 := 0
Local dEtd		 := CTOD("  /  /  ")
Local detd2		 := CTOD("  /  /  ")
Local WnMar		 := 0
Local WDt_Nf	 := CTOD("  /  /  ")
Local WDt_xEnt	 := CTOD("  /  /  ")
Local Wdt_Prev   := CTOD("  /  /  ")
Local cDIPROG	 := ""
Local aResDatas

If MV_PAR15 = 1// 1 = Analitico
	cQuery := " SELECT SC1.C1_FILIAL, "
	cQuery += "        SC1.C1_NUM, "
	cQuery += "        SC1.C1_ITEM, "
	cQuery += "        SC1.C1_PRODUTO, "
	cQuery += "        SC1.C1_EMISSAO, "
	cQuery += "        SC1.C1_DESCRI, "
	cQuery += "        SC1.C1_QUANT, "
	cQuery += "        SC7.C7_NUM, "
	cQuery += "        SC7.C7_ITEM, "
	cQuery += "        SC7.C7_EMISSAO, "
	cQuery += "        SC7.C7_FORNECE, "
	cQuery += "        SC7.C7_LOJA, "
	cQuery += "        SD1.D1_DOC, "
	cQuery += "        SD1.D1_SERIE, "
	cQuery += "        SD1.D1_EMISSAO "

	cQuery += " FROM " + RetSqlName("SC1") + " SC1 "
	cQuery += " LEFT JOIN " +RetSqlName("SC7")+ " SC7 "
	cQuery += "        ON SC7.C7_FILIAL = SC1.C1_FILIAL AND "
	cQuery += "        SC7.C7_NUMSC = SC1.C1_NUM AND "
	cQuery += "        SC7.C7_ITEMSC = SC1.C1_ITEM "
	cQuery += " LEFT JOIN " +RetSqlName("SD1")+ " SD1 " 
	cQuery += "        ON SC7.C7_FILIAL = SD1.D1_FILIAL AND "
	cQuery += "        SC7.C7_NUM = SD1.D1_PEDIDO AND "
	cQuery += "        SC7.C7_ITEM = SD1.D1_ITEMPC AND "
	cQuery += "        SC7.C7_FORNECE = SD1.D1_FORNECE AND "
	cQuery += "        SC7.C7_LOJA = SD1.D1_LOJA "
	cQuery += " WHERE SC1.D_E_L_E_T_ <> '*' AND SC7.D_E_L_E_T_ <> '*' AND SD1.D_E_L_E_T_ <> '*' "
	cQuery += "        AND SD1.D1_TIPO_NF = '1' " 
	cQuery += "        AND SC1.C1_FILIAL BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "'"
	cQuery += "        AND SC1.C1_NUM BETWEEN '" + MV_PAR03 + "' AND '" + MV_PAR04 + "'"
	cQuery += "        AND SC1.C1_EMISSAO BETWEEN '" + DTOS(MV_PAR05) + "' AND '" + DTOS(MV_PAR06) + "'"
	cQuery += "        AND SC1.C1_PEDIDO BETWEEN '" + MV_PAR07 + "' AND '" + MV_PAR08 + "'"
	cQuery += "        AND SD1.D1_DOC BETWEEN '" + MV_PAR09 + "' AND '" + MV_PAR10 + "'"
	cQuery += "        AND SD1.D1_SERIE BETWEEN '" + MV_PAR11 + "' AND '" + MV_PAR12 + "'"
	cQuery += "        AND SD1.D1_EMISSAO BETWEEN '" + DTOS(MV_PAR13) + "' AND '" + DTOS(MV_PAR14) + "'"

	If !Empty(MV_PAR16) .And. !Empty(MV_PAR18) .And. !Empty(MV_PAR17) .And. !Empty(MV_PAR19)
		cQuery += "        AND SC7.C7_FORNECE BETWEEN '" + MV_PAR16 + "' AND '" + MV_PAR18 + "'"
		cQuery += "        AND SC7.C7_LOJA BETWEEN '" + MV_PAR17 + "' AND '" + MV_PAR19 + "'
	EndIf 

	cQuery += " ORDER BY SC1.C1_FILIAL, SC1.C1_NUM "
Else// Analitico
	cQuery := " SELECT SD1.D1_FILIAL, "
	cQuery += "        SD1.D1_DTDIGIT, "
	cQuery += "        SD1.D1_EMISSAO, "
	cQuery += "        SWN.WN_PO_NUM, "
	cQuery += "        SWN.WN_HAWB, "
	cQuery += "        SWN.WN_DOC, "
	cQuery += "        SWN.WN_SERIE, "
	cQuery += "        SUM(SWN.WN_QUANT) WN_QUANT, "
	cQuery += "        SWN.WN_FORNECE, "
	cQuery += "        SWN.WN_LOJA, "
	cQuery += " 	   SC7.C7_EMISSAO,"
	cQuery += " 	   SC7.C7_NUMSC"

	cQuery += " FROM " + RetSqlName("SWN") + " SWN "
	cQuery += " LEFT JOIN " +RetSqlName("SD1")+ " SD1 ON" 
	cQuery += "        SWN.WN_PO_NUM = SD1.D1_PEDIDO AND "
	cQuery += "        SWN.WN_ITEM = SD1.D1_ITEMPC AND "
	cQuery += "        SWN.WN_FORNECE = SD1.D1_FORNECE AND "
	cQuery += "        SWN.WN_LOJA = SD1.D1_LOJA AND"
	cQuery += "        SWN.WN_SERIE = SD1.D1_SERIE AND "
	cQuery += "        SWN.WN_DOC = SD1.D1_DOC AND "
	cQuery += "		   SWN.WN_TIPO_NF = SD1.D1_TIPO_NF"
	cQuery += " LEFT JOIN " +RetSqlName("SC7")+ " SC7 ON" 
	cQuery += "        SWN.WN_PRODUTO = SC7.C7_PRODUTO AND "
	cQuery += "        SWN.WN_ITEM = SC7.C7_ITEM AND "
	cQuery += "        SWN.WN_FORNECE = SC7.C7_FORNECE AND "
	cQuery += "        SWN.WN_LOJA = SC7.C7_LOJA AND "
	cQuery += "        SWN.WN_PO_NUM = SC7.C7_NUM "
	cQuery += " WHERE SWN.D_E_L_E_T_ <> '*' AND SD1.D_E_L_E_T_ <> '*' AND SC7.D_E_L_E_T_ <> '*' "
	cQuery += "        AND SWN.WN_TIPO_NF = '1' " 
	cQuery += "        AND SD1.D1_FILIAL BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "'"
	cQuery += "        AND SC7.C7_NUMSC BETWEEN '" + MV_PAR03 + "' AND '" + MV_PAR04 + "'"
	cQuery += "        AND SC7.C7_EMISSAO BETWEEN '" + DTOS(MV_PAR05) + "' AND '" + DTOS(MV_PAR06) + "'"
	cQuery += "        AND SWN.WN_PO_NUM BETWEEN '" + MV_PAR07 + "' AND '" + MV_PAR08 + "'"
	cQuery += "        AND SWN.WN_DOC BETWEEN '" + MV_PAR09 + "' AND '" + MV_PAR10 + "'"
	cQuery += "        AND SWN.WN_SERIE BETWEEN '" + MV_PAR11 + "' AND '" + MV_PAR12 + "'"
	cQuery += "        AND SD1.D1_EMISSAO BETWEEN '" + DTOS(MV_PAR13) + "' AND '" + DTOS(MV_PAR14) + "'"

	If !Empty(MV_PAR16) .And. !Empty(MV_PAR18) .And. !Empty(MV_PAR17) .And. !Empty(MV_PAR19)
		cQuery += "        AND SWN.WN_FORNECE BETWEEN '" + MV_PAR16 + "' AND '" + MV_PAR18 + "'"
		cQuery += "        AND SWN.WN_LOJA  BETWEEN '" + MV_PAR17 + "' AND '" + MV_PAR19 + "'
	EndIf 
	
	cQuery += " GROUP BY SD1.D1_FILIAL, SD1.D1_DTDIGIT, SWN.WN_PO_NUM, SWN.WN_HAWB, SWN.WN_SERIE, SWN.WN_FORNECE, SWN.WN_LOJA, "
	cQuery += " SD1.D1_EMISSAO, SC7.C7_EMISSAO, SWN.WN_DOC, SC7.C7_NUMSC"
		
	cQuery += " ORDER BY SD1.D1_FILIAL, SWN.WN_HAWB DESC"
EndIf


cQuery := ChangeQuery(cQuery)

//MEMOWRITE("E:\QUERYTESTE.SQL",cQuery)

If Select("SCPCNF") > 0
	DbSelectArea("SCPCNF")
	SCPCNF->(DbCloseArea())
EndIf

dbUseArea(.T.,"TOPCONN",TCGenqry(,,cQuery),"SCPCNF",.F.,.T.)

DbSelectArea("SCPCNF")
SCPCNF->(DbGotop())

If MV_PAR15 = 1// 1 = Analitico
	
	oSection:Init()

	While SCPCNF->(!Eof())
			
		oSection:Cell("FILIAL"):SetValue(SCPCNF->C1_FILIAL)
		oSection:Cell("NUMSC"):SetValue(SCPCNF->C1_NUM)
		oSection:Cell("ITEMSC"):SetValue(SCPCNF->C1_ITEM)
		oSection:Cell("QTDSC"):SetValue(SCPCNF->C1_QUANT)
		oSection:Cell("CODPROD"):SetValue(SCPCNF->C1_PRODUTO)
		oSection:Cell("DESCPROD"):SetValue(SCPCNF->C1_DESCRI)
		oSection:Cell("DTEMISC"):SetValue(Substr(SCPCNF->C1_EMISSAO,7,2) + "/" + Substr(SCPCNF->C1_EMISSAO,5,2) + "/" + Substr(SCPCNF->C1_EMISSAO,3,2))
		oSection:Cell("NUMPC"):SetValue(SCPCNF->C7_NUM)
		oSection:Cell("ITEMPC"):SetValue(SCPCNF->C7_ITEM)
		oSection:Cell("DTEMIPC"):SetValue(SubStr(SCPCNF->C7_EMISSAO,7,2) + "/" + SubStr(SCPCNF->C7_EMISSAO,5,2) + "/" + SubStr(SCPCNF->C7_EMISSAO,3,2))
		
		dDtLib1   := Posicione("SCR",1,SCPCNF->C1_FILIAL+"PC"+PADR(SCPCNF->C7_NUM,TAMSX3("CR_NUM")[1])+"01","CR_DATALIB")
		dDtLib2	  := Posicione("SCR",1,SCPCNF->C1_FILIAL+"PC"+PADR(SCPCNF->C7_NUM,TAMSX3("CR_NUM")[1])+"02","CR_DATALIB")
		dDtDesemb := Posicione("SW6",1,"  "+"IMP"+PADR(SCPCNF->C7_NUM,TAMSX3("W6_HAWB")[1]),"W6_DT_HAWB")
		
		oSection:Cell("DTLIB01"):SetValue(SubStr(Dtos(dDtLib1),7,2) + "/" +SubStr(Dtos(dDtLib1),5,2) + "/" + SubStr(Dtos(dDtLib1),3,2)  )
		oSection:Cell("DTLIB02"):SetValue(SubStr(Dtos(dDtLib2),7,2) + "/" +SubStr(Dtos(dDtLib2),5,2) + "/" + SubStr(Dtos(dDtLib2),3,2)  ) 
		oSection:Cell("DTDESEMB"):SetValue(SubStr(Dtos(dDtDesemb),7,2) + "/" +SubStr(Dtos(dDtDesemb),5,2) + "/" + SubStr(Dtos(dDtDesemb),3,2)  )     
		
		If !Empty(dDtLib2)
			nLeadTi1 := DateDiffDay(STOD(SCPCNF->C1_EMISSAO),dDtLib2)
		EndIf
		
		If !Empty(dDtDesemb)
			nLeadTi2 := DateDiffDay(STOD(SCPCNF->C1_EMISSAO),dDtDesemb)
		EndIf    
		
		If !Empty(SCPCNF->D1_EMISSAO)
			If !Empty(dDtLib2)
				nLeadTi3 := DateDiffDay(dDtLib2,STOD(SCPCNF->D1_EMISSAO))
			EndIf
			
			If !Empty(dDtDesemb)
				nLeadTi4 := DateDiffDay(dDtDesemb,STOD(SCPCNF->D1_EMISSAO))
			EndIf
			
			nLeadTi5 := DateDiffDay(STOD(SCPCNF->C1_EMISSAO),STOD(SCPCNF->D1_EMISSAO))
		EndIf
		
		oSection:Cell("NUMNF"):SetValue(SCPCNF->D1_DOC)
		oSection:Cell("SERIENF"):SetValue(SCPCNF->D1_SERIE)
		oSection:Cell("DTEMINF"):SetValue(SubStr(SCPCNF->D1_EMISSAO,7,2) + "/" + SubStr(SCPCNF->D1_EMISSAO,5,2) + "/" + SubStr(SCPCNF->D1_EMISSAO,3,2) )
		
		oSection:Cell("LEADTIME1"):SetValue(cValtoChar(nLeadTi1))
		oSection:Cell("LEADTIME3"):SetValue(cValtoChar(nLeadTi3))
		oSection:Cell("LEADTIME4"):SetValue(cValtoChar(nLeadTi4))
		oSection:Cell("LEADTIME5"):SetValue(cValtoChar(nLeadTi5))
			
		nLeadTi1   := 0
		nLeadTi2   := 0
		nLeadTi3   := 0
		nLeadTi4   := 0
		nLeadTi5   := 0
		dDtLib1    := CTOD("  /  /  ") 
		dDtLib2    := CTOD("  /  /  ")
		dDtDesemb  := CTOD("  /  /  ")
		
		oSection:PrintLine()
	
		SCPCNF->(dbSkip())

	EndDo

Else// Sintetico

	oSection:Init()

	While SCPCNF->(!Eof())
			
		oSection:Cell("FILIAL"):SetValue(SCPCNF->D1_FILIAL)
		oSection:Cell("NUMDESEMB"):SetValue(SCPCNF->WN_HAWB)
		oSection:Cell("FORNE"):SetValue(ConsFor(SCPCNF->WN_FORNECE))
		oSection:Cell("NUMPC"):SetValue(SCPCNF->WN_PO_NUM)
		aResDatas:= ConsEtdEta(SCPCNF->WN_PO_NUM)
		
		SCR->(DbSetOrder(1))
		SCR->(DbSeek(SCPCNF->D1_FILIAL + "PC" + PADR(SCPCNF->WN_PO_NUM,TAMSX3("CR_NUM")[1])+"02") )

		While SCR->CR_FILIAL == SCPCNF->D1_FILIAL .And. AllTrim(SCR->CR_NUM) == AllTrim(SCPCNF->WN_PO_NUM) .And. SCR->CR_TIPO == "PC" .And. SCR->CR_NIVEL == "02"
		
			If Empty(SCR->CR_DATALIB)
				SCR->(DbSkip())
			Else
				dDtLib2	  := SCR->CR_DATALIB
				Exit
			EndIf
		
		End

		If AllTrim(nDesemb) <> AllTrim(SCPCNF->WN_HAWB)
			dDtDesemb 	:= SToD(W6DATE(SCPCNF->WN_PO_NUM))
			nwDesemb	:= W6DATE(SCPCNF->WN_PO_NUM,SCPCNF->D1_EMISSAO)
			dEtd		:= Substr(aResDatas[1][2],7,2) + "/" + Substr(aResDatas[1][2],5,2) + "/" + Substr(aResDatas[1][2],3,2)
			dEtd2		:= aResDatas[1][2]
			WnMar		:= Val(aResDatas[1][1])
			WDt_Nf		:= Stod(aResDatas[1][3])
			WDt_xEnt	:= Stod(aResDatas[1][4])
			Wdt_Prev	:= Stod(aResDatas[1][5])
			cDIPROG		:= AllTrim(cValToChar(CalcProg(0,SCPCNF->WN_HAWB)))
		EndIf

		oSection:Cell("MAR"):SetValue(WnMar)
		oSection:Cell("DESEMB"):SetValue(nwDesemb)

		oSection:Cell("DTLIB02"):SetValue(SubStr(Dtos(dDtLib2),7,2) + "/" + SubStr(Dtos(dDtLib2),5,2) + "/" + SubStr(Dtos(dDtLib2),3,2) )
		oSection:Cell("DTDESEMB"):SetValue(SubStr(Dtos(dDtDesemb),7,2) + "/" + SubStr(Dtos(dDtDesemb),5,2) + "/" + SubStr(Dtos(dDtDesemb),3,2) )
		
		IF !Empty(dDtLib2)
			nLeadTi1 := DateDiffDay(STOD(SCPCNF->C7_EMISSAO),dDtLib2)
		EndIf
		
		If !Empty(dDtDesemb)
			nLeadTi2 := DateDiffDay(STOD(SCPCNF->C7_EMISSAO),dDtDesemb)
		EndIf    
		
		If !Empty(SCPCNF->D1_EMISSAO)
			If !Empty(dDtLib2)
				nLeadTi3 := DateDiffDay(dDtLib2,STOD(SCPCNF->D1_EMISSAO))
			EndIf
		
			If !Empty(dDtDesemb)
				nLeadTi4 := DateDiffDay(dDtDesemb,STOD(SCPCNF->D1_EMISSAO))
			EndIf
			
			nLeadTi5 := DateDiffDay(STOD(SCPCNF->C7_EMISSAO),STOD(SCPCNF->D1_EMISSAO))
		EndIf 
		
		If !Empty(dEtd2) .And. !Empty(dDtLib2)
			nLeadTi6:= DateDiffDay(Stod(dEtd2), dDtLib2 )
		EndIF
		
		nLeadTi7	:= W6LEAD(SCPCNF->WN_PO_NUM)

		//If !Empty(WDt_Nf) .And. !Empty(WDt_xEnt)
			//nLeadTi7:= DateDiffDay(WDt_Nf, WDt_xEnt )
		//EndIF

		//If !Empty(WDt_Nf) .And. !Empty(Wdt_Prev)
		If !Empty(WDt_Nf) .And. !Empty(dDtLib2)
			nLeadTi8:= DateDiffDay(WDt_Nf, dDtLib2 ) - Val(cDIPROG)
		EndIF
		
		If !Empty(dEtd2) .And. !Empty(dDtDesemb)
			nLeadTi9:= DateDiffDay(Stod(dEtd2), dDtDesemb )
		EndIF
		
		oSection:Cell("NUMNF"):SetValue(SCPCNF->WN_DOC)
		oSection:Cell("DTEMINF"):SetValue(Substr(SCPCNF->D1_EMISSAO,7,2) + "/" + Substr(SCPCNF->D1_EMISSAO,5,2) + "/" + Substr(SCPCNF->D1_EMISSAO,3,2)) 
		
		oSection:Cell("LEADTIME1"):SetValue(nLeadTi1)
		//oSection:Cell("LEADTIME3"):SetValue(cValtoChar(nLeadTi3))
		oSection:Cell("LEADTIME3"):SetValue(nLeadTi3)
		oSection:Cell("LEADTIME4"):SetValue(nLeadTi4)
		oSection:Cell("LEADTIME5"):SetValue(nLeadTi5)
		oSection:Cell("DIPROG"):SetValue(cDiprog)
		oSection:Cell("PRODUCAO"):SetValue(nLeadTi6)
		oSection:Cell("PROD2"):SetValue(nLeadTi9)
		oSection:Cell("ETD"):SetValue(dEtd)
		oSection:Cell("LT_PRE"):SetValue(nLeadTi7)
		oSection:Cell("LT_REA"):SetValue(nLeadTi8)

		If !Empty(nLeadTi1) .And. nLeadTi1 > 0//SC X N2
			nDiv07++
			nScN2+= nLeadTi1
		EndIf
		
		If !Empty(nLeadTi3) .And. nLeadTi3 > 0//SC X N2
			nDiv08++
			nN2Nf+= nLeadTi3
		EndIf
		
		If !Empty(nLeadTi4) .And. nLeadTi4 > 0//SC X N2
			nDiv09++
			nDbNf+= nLeadTi4
		EndIf

		If !Empty(nLeadTi5) .And. nLeadTi5 > 0//SC X N2
			nDiv10++
			nScNf+= nLeadTi5
		EndIf

		If !Empty(nLeadTi6) .And. nLeadTi6 > 0//Producao
			nDiv01++
			nProd01+= nLeadTi6
		EndIf
		
		If !Empty(nLeadTi9) .And. nLeadTi9 > 0//Producao 2
			nDiv02++
			nProd02+= nLeadTi9
		EndIf

		If !Empty(WnMar) .And. WnMar > 0// Mar
			nDiv03++
			nMar+= 	WnMar
		EndIf

		If !Empty(nWdesemb)// Porto //Desemb
			nDiv04++
			nPorto+= nWdesemb
		EndIf
			
		If !Empty(nLeadTi7) .And. nLeadTi7 > 0 //LT Previsto
			nDiv05++
			nPrev+= nLeadTi7
		EndIf

		If !Empty(nLeadTi8)  .And. nLeadTi8 > 0//Lt Realizado
			nDiv06++
			nReal+= nLeadTi8
		EndIf

		nLeadTi1   := 0
		nLeadTi2   := 0
		nLeadTi3   := 0
		nLeadTi4   := 0
		nLeadTi5   := 0
		nLeadTi6   := 0		
		nLeadTi7   := 0		
		nLeadTi8   := 0		
		dDtLib1    := CTOD("  /  /  ") 
		dDtLib2    := CTOD("  /  /  ")

		nDesemb:= SCPCNF->WN_HAWB //Identificar se numero de desembaraco e o mesmo

		oSection:PrintLine()
		
		//oReport:FatLine()
			
		SCPCNF->(dbSkip())
	EndDo
EndIf

oSection:Finish()

SCPCNF->(DbCloseArea())

Return (Nil)

Static Function ConsEtdEta(cPedido)

Local cResult 	:= "0"
Local aResult	:= {}
Local cQuery  	:= ""
Local cAliasQry := GetNextAlias()
                                                                
	cQuery := "Select SW6.W6_DT_ETD ETD, SW6.W6_DT_ETA ETA, SW6.W6_DT_NF,  SW6.W6_XENTINI, SW6.W6_PRVENTR "
	cQuery += " From " + RetSqlName("SW6") + " SW6"
	cQuery += " Where SW6.W6_PO_NUM = '" + cPedido + "'"
	cQuery += " AND D_E_L_E_T_ <> '*'"

	cQuery := ChangeQuery(cQuery)
	DbUseArea( .T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasQry,.F.,.T. )

	If !Empty((cAliasQry)->ETD) .And. !Empty((cAliasQry)->ETA)
		cResult := cValToChar(SToD((cAliasQry)->ETA) - SToD((cAliasQry)->ETD))
	Else 
		cResult := "0"
	EndIf

	cResult := AllTrim(cValToChar(cResult))
	
	aAdd(aResult,{ AllTrim(cValToChar(cResult)), (cAliasQry)->ETD, (cAliasQry)->W6_DT_NF, (cAliasQry)->W6_XENTINI, (cAliasQry)-> W6_PRVENTR})

	(cAliasQry)->(DbCloseArea())

Return aResult

/*
Static Function ConsFil(cFil)

Local cFil

	DbSelectArea("SM0")
	DbSetOrder(1)

	SM0->(MsSeek("01"+cFil))

	cFil := SM0->M0_FILIAL

Return cFil
*/
/*
Static Function Desemb(cDesemb)

Local aRes 		:= {}
Local cQuery 	:= ""
Local cAliasQry := GetNextAlias()
Local aArea		:= GetArea()

	cQuery := "Select SW6.W6_HAWB HAWB, SW6.W6_DT_HAWB DTHAWB "
	cQuery += "From "+RetSqlName("SW6")+" SW6 "
	cQuery += "Inner Join "+RetSqlName("SW7")+" SW7 "
	cQuery += "On SW6.W6_HAWB = SW7.W7_HAWB "
	cQuery += "Where SW6.D_E_L_E_T_ <> '*' "
	cQuery += "And SW7.D_E_L_E_T_ <> '*' "
	cQuery += "And SW7.W7_HAWB = '"+cDesemb+"' "
	cQuery += "And SW6.W6_DT_HAWB Between '" +DTOS(MV_PAR05)+ "' AND '"+DTOS(MV_PAR06)+"' "

	cQuery += "Group By SW6.W6_HAWB, SW6.W6_DT_HAWB "
	cQuery += "Order By SW6.W6_DT_HAWB DESC"

	cQuery := ChangeQuery(cQuery)
	DbUseArea( .T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasQry,.F.,.T. )

	(cAliasQry)->(DbGoTop())

	aAdd(aRes, AllTrim((cAliasQry)->HAWB))
	aAdd(aRes, (cAliasQry)->DTHAWB)

	(cAliasQry)->(DbCloseArea())
	RestArea(aArea)
Return aRes
*/
Static Function ConsFor(cFor)

Local aArea		:= GetArea()
Local cQuery    := ""
Local cAliasQry := GetNextAlias()
Local cForn		:= ""

	cQuery := "Select SA2.A2_NREDUZ NOME "
	cQuery += "From "+RetSqlName("SA2")+" SA2"
	cQuery += "Where SA2.A2_COD = '"+cFor+"' "
	cQuery += "And D_E_L_E_T_ <> '*'"

	cQuery := ChangeQuery(cQuery)
	DbUseArea( .T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasQry,.F.,.T. )

	cForn := AllTrim((cAliasQry)->NOME)

	(cAliasQry)->(DbCloseArea())

	RestArea(aArea)

Return cForn

Static Function CalcProg(nLeadTi5,cDesemb)

Local aArea 	:= GetArea()
Local nDia
Local cQuery    := ""
Local cAliasQry := GetNextAlias()

	cQuery := "Select SW6.W6_XDIAPRO DIAPRO, SW6.W6_PRVENTR PRVENTR, SW6.W6_DT_HAWB DTHAWB, SW6.W6_XENTINI XENTINI "
	cQuery += "From "+RetSqlName("SW6")+" SW6 "
	cQuery += "Where SW6.D_E_L_E_T_ <> '*' "
	cQuery += "And SW6.W6_HAWB = '"+cDesemb+"' "
	
	cQuery := ChangeQuery(cQuery)
	DbUseArea( .T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasQry,.F.,.T. )

	//If (DateDiffDay(STOD((cAliasQry)->DTHAWB),STOD((cAliasQry)->PRVENTR))) > (cAliasQry)->DIAPRO
	If ( DateDiffDay(STOD((cAliasQry)->XENTINI),STOD((cAliasQry)->DTHAWB)) - (cAliasQry)->DIAPRO) > 0 //(cAliasQry)->DIAPRO
		//nDia := DateDiffDay(STOD((cAliasQry)->DTHAWB),STOD((cAliasQry)->PRVENTR))
		nDia := DateDiffDay(STOD((cAliasQry)->XENTINI),STOD((cAliasQry)->DTHAWB)) - (cAliasQry)->DIAPRO
	Else	
		nDia := 0//(cAliasQry)->DIAPRO
	EndIf

	(cAliasQry)->(DbCloseArea())

RestArea(aArea)

Return nDia

Static Function W6DATE(nPonum,dDtemiss)

Local aArea 	 := GetArea()
Local dData

Local cQuery     := ""

Default nPonum	 := NIL
Default dDtemiss := NIL

	cQuery := "Select SW6.W6_DT_HAWB, SW6.W6_DT_ETA "
	cQuery += "From "+RetSqlName("SW6")+" SW6 "
	cQuery += "Where SW6.D_E_L_E_T_ = '' AND SW6.W6_PO_NUM = '"+nPonum+"'"

	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TCGenqry(,,cQuery),"SW6DT",.F.,.T.)

	If dDtemiss = NIL
		dData := SW6DT->W6_DT_HAWB
	Else
		If !Empty(SW6DT->W6_DT_ETA) .And. !Empty(dDtemiss)
			dData := DateDiffDay(SToD(SW6DT->W6_DT_ETA),SToD(dDtemiss))
		Else
		    dData := 0
		EndIf
	EndIf

	SW6DT->(DbCloseArea())

RestArea(aArea)

Return dData

Static Function W6LEAD(nPonum)

Local aArea 	 := GetArea()
Local dData

Local cQuery     := ""

Default nPonum	 := NIL

	cQuery := "Select SW6.W6_XDIAPRO "
	cQuery += "From "+RetSqlName("SW6")+" SW6 "
	cQuery += "Where SW6.D_E_L_E_T_ = '' AND SW6.W6_PO_NUM = '"+nPonum+"'"

	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TCGenqry(,,cQuery),"SW6LEAD",.F.,.T.)

	If SW6LEAD->(!EOF())
		dData := SW6LEAD->W6_XDIAPRO
	Else
		dData := 0
	EndIf
	
	SW6LEAD->(DbCloseArea())

RestArea(aArea)

Return dData