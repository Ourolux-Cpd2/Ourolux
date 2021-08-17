#INCLUDE "PROTHEUS.CH"
#INCLUDE "REPORT.CH"
#INCLUDE "TOPCONN.CH"

/*----------------------------------------------------------|
| Autor | Ethosx                          | Data 27/05/19 	| 
|-----------------------------------------------------------|
| FunÁ„o: OUROR017									|
|-----------------------------------------------------------|
| Relatorio de Lote                   	                    |
------------------------------------------------------------*/

User Function OUROR017()

Local oReport

oReport := ReportDef()
oReport:PrintDialog() // Imprime os dados na Tela(Preview).

Return

Static Function ReportDef()

Local oReport  // Objeto principal do RelatÛrio TReport.
Local oSection // Objeto da SeÁ„o. 
//Local oBreak   // Objeto da Quebra(Sub Total Num SC).
Local cPerg    := PADR("OUROR017D",10) // Grupo de Perguntas.       

ValidP1(cPerg)

Pergunte(cPerg,.T.) // Caso o parametro esteja como .T. o sistema ira apresentar a tela de perguntas antes que abrir a tela configuraÁ„o do relatÛrio.

// Apresenta a tela de impress„o para o usu·rio configurar o relatÛrio.
oReport:=TReport():New("OUROR017","OUROR017 - Lote",cPerg,{|oReport| PrintReport(oReport,oSection,cPerg)},"Lote")
oReport:SetLandscape(.T.) 
oSection:=TRSection():New(oReport,"OUROR017 - Lote ",{"SD2"})

oSection:SetTotalInLine(.T.) // Define se os totalizadores da sess„o ser„o impressos em linha ou coluna.

TRCell():New(oSection ,"DTEMINF"   ,,"Data NF"	 			,,08,,,			,,"LEFT")
TRCell():New(oSection ,"NUMNF"     ,,"N.Fiscal-SÈrie"		,,13,,,			,,"LEFT") 
TRCell():New(oSection ,"CLIENTE"   ,,"Cliente"				,,27,,,			,,"LEFT") 
TRCell():New(oSection ,"PRODUTO"   ,,"Prod."	     		,,07,,,        ,,"LEFT")  
TRCell():New(oSection ,"DESCPRO" 	,,"DescriÁ„o" 			,,40,,,			,,"LEFT")
TRCell():New(oSection ,"QTDE" 		,,"Qtde"	 	   		,"@E 9,999.99"	,08,,,"RIGHT",,"RIGHT")
TRCell():New(oSection ,"UNITARIO" 	,,"Unit·rio" 			,"@E 99,999.99"	,09,,,"RIGHT",,"RIGHT")
TRCell():New(oSection ,"TOTAL" 		,,"Vlr.Total" 			,"@E 999,999.99",10,,,"RIGHT",,"RIGHT")
TRCell():New(oSection ,"CUSTO" 		,,"Custo" 				,"@E 999,999.99",10,,,"RIGHT",,"RIGHT")
TRCell():New(oSection ,"BASEICM"	,,"Base ICMS" 			,"@E 999,999.99",10,,,"RIGHT",,"RIGHT")
TRCell():New(oSection ,"PICMS" 		,,"ICMS %" 				,"99"			,02,,,"RIGHT",,"RIGHT")
TRCell():New(oSection ,"ICMS" 		,,"Vlr.ICMS" 			,"@E 999,999.99",10,,,"RIGHT",,"RIGHT")
TRCell():New(oSection ,"IPI" 		,,"Vlr.IPI" 			,"@E 999,999.99",10,,,"RIGHT",,"RIGHT")
TRCell():New(oSection ,"ICMSST"		,,"Vlr.ICMS-ST"			,"@E 999,999.99",10,,,"RIGHT",,"RIGHT")
TRCell():New(oSection ,"DTLOTE"    ,,"Dat.Lote"  			,,08,,,			,,"LEFT")
TRCell():New(oSection ,"NFENT"     ,,"NF Ent.-SÈrie"		,,13,,,			,,"LEFT") 
TRCell():New(oSection ,"LOTE"     	,,"Lote"				,,06,,,			,,"LEFT") 
TRCell():New(oSection ,"CF"     	,,"CF"					,,04,,,			,,"LEFT")


//oBreak:=TRBreak():New(oSection,oSection:Cell("FILIAL"),"",.F.) // Quebra por Nota Fiscal
		
TRFunction():New(oSection:Cell("TOTAL")		,NIL,"SUM",,"Total da NF"			,, /*uFormula*/,.F./*Total da SeÁ„o*/,.T./*Total Geral*/,.F./*Total da Pagina*/)
TRFunction():New(oSection:Cell("ICMS") 		,NIL,"SUM",,"Total Valor ICMS"		,, /*uFormula*/,.F./*Total da SeÁ„o*/,.T./*Total Geral*/,.F./*Total da Pagina*/)
TRFunction():New(oSection:Cell("IPI") 		,NIL,"SUM",,"Total Valor IPI"		,, /*uFormula*/,.F./*Total da SeÁ„o*/,.T./*Total Geral*/,.F./*Total da Pagina*/)
TRFunction():New(oSection:Cell("ICMSST")	,NIL,"SUM",,"Total Valor ICMS-ST"	,, /*uFormula*/,.F./*Total da SeÁ„o*/,.T./*Total Geral*/,.F./*Total da Pagina*/)

	
Return oReport

/*-------------------------------------------------*/

Static Function PrintReport(oReport,oSection)

Local cQuery     := ""

Private cLoteD3	 := ""

If MV_PAR03 = 1// 1 = Saida

	cQuery := " SELECT SD2.D2_FILIAL, "
	cQuery += "        SD2.D2_DOC, "
	cQuery += "        SD2.D2_SERIE, "
	cQuery += "        SD2.D2_EMISSAO, "
	cQuery += "        SD2.D2_COD, "
	cQuery += "        SD2.D2_QUANT, "
	cQuery += "        SD2.D2_PRCVEN, "
	cQuery += "        SD2.D2_TOTAL, " 
	cQuery += "        SD2.D2_CUSTO1, " 
	cQuery += "        SD2.D2_BASEICM, "
	cQuery += "        SD2.D2_VALICM, "
	cQuery += "        SD2.D2_VALIPI, "
	cQuery += "        SD2.D2_ICMSRET, "
	cQuery += "        SD2.D2_PICM, "
	cQuery += "        SD2.D2_CLIENTE, "
	cQuery += "        SD2.D2_CF, "
	cQuery += "        SA1.A1_NREDUZ, "
	cQuery += "        SB1.B1_DESC, "
	cQuery += "        SD2.D2_LOJA, "  
	cQuery += "        SB8.B8_DATA, "  
	cQuery += "        SB8.B8_DOC, "  
	cQuery += "        SB8.B8_LOTECTL, "  
	cQuery += "        SB8.B8_SERIE "  
	
	cQuery += " FROM " + RetSqlName("SD2") + " SD2, " + RetSqlName("SB1") + " SB1, " + RetSqlName("SA1") + " SA1, " + RetSqlName("SB8") + " SB8 " 
	cQuery += " WHERE SD2.D_E_L_E_T_ <> '*' AND SB1.D_E_L_E_T_ <> '*' AND SA1.D_E_L_E_T_ <> '*' AND SB8.D_E_L_E_T_ <> '*' "
  
	cQuery += "        AND SD2.D2_FILIAL = '" + xFilial("SD2") + "' " 
	cQuery += "        AND SD2.D2_COD = SB1.B1_COD " 
	cQuery += "        AND SD2.D2_CLIENTE = SA1.A1_COD "
	cQuery += "        AND SD2.D2_LOJA = SA1.A1_LOJA "
	
	cQuery += "        AND SD2.D2_EMISSAO BETWEEN '" + DTOS(MV_PAR01) + "' AND '" + DTOS(MV_PAR02) + "' "
	
	//cQuery += "        AND SB8.B8_DATA <= '" + DTOS(MV_PAR03) + "' "
	
	cQuery += "        AND SD2.D2_LOTECTL = SB8.B8_LOTECTL "
	cQuery += "        AND SD2.D2_COD = SB8.B8_PRODUTO " 
	cQuery += "        AND SD2.D2_LOCAL = SB8.B8_LOCAL "
	cQuery += "        AND SD2.D2_FILIAL = SB8.B8_FILIAL "
	
	cQuery += " ORDER BY SD2.D2_FILIAL, SD2.D2_DOC, SD2.D2_SERIE "
	
	cQuery := ChangeQuery(cQuery)
	
	If Select("SD2NF") > 0
		SD2NF->(DbCloseArea())
	EndIf
	
	dbUseArea(.T.,"TOPCONN",TCGenqry(,,cQuery),"SD2NF",.F.,.T.)
	
	DbSelectArea("SD2NF")
	SD2NF->(DbGotop())

	oReport:SetMeter( SD2NF->( RecCount() ) )
	
	oSection:Init()

	While SD2NF->(!Eof())

		oSection:Cell("DTEMINF"	):SetValue(Substr(SD2NF->D2_EMISSAO,7,2) + "/" + Substr(SD2NF->D2_EMISSAO,5,2) + "/" + Substr(SD2NF->D2_EMISSAO,3,2))
		oSection:Cell("NUMNF"	):SetValue(SD2NF->D2_DOC + "-" + SD2NF->D2_SERIE)
		oSection:Cell("CLIENTE"	):SetValue(SD2NF->D2_CLIENTE + "-" + SD2NF->D2_LOJA + "-" + SD2NF->A1_NREDUZ)
		oSection:Cell("PRODUTO"	):SetValue(AllTrim(SD2NF->D2_COD))
		oSection:Cell("DESCPRO"	):SetValue(SD2NF->B1_DESC)
		oSection:Cell("QTDE"	):SetValue(SD2NF->D2_QUANT)
		oSection:Cell("UNITARIO"):SetValue(SD2NF->D2_PRCVEN)
		oSection:Cell("TOTAL"	):SetValue(SD2NF->D2_TOTAL)
		oSection:Cell("CUSTO"	):SetValue(SD2NF->D2_CUSTO1)
		oSection:Cell("BASEICM"	):SetValue(SD2NF->D2_BASEICM)
		oSection:Cell("PICMS"	):SetValue(SD2NF->D2_PICM)
		oSection:Cell("ICMS"	):SetValue(SD2NF->D2_VALICM)
		oSection:Cell("IPI"		):SetValue(SD2NF->D2_VALIPI)
		oSection:Cell("ICMSST"	):SetValue(SD2NF->D2_ICMSRET)
		oSection:Cell("DTLOTE"	):SetValue(Substr(SD2NF->B8_DATA,7,2) + "/" + Substr(SD2NF->B8_DATA,5,2) + "/" + Substr(SD2NF->B8_DATA,3,2)) 
		
		cLoteD3:= ""
		
		If Empty(SD2NF->B8_SERIE)
            
			cQuery := " SELECT SD3.D3_FILIAL, "
			cQuery += "        SD3.D3_DOC, "
			cQuery += "        SD3.D3_COD, "
			cQuery += "        SD3.D3_LOCAL, "
			cQuery += "        SD3.D3_LOTECTL "
			
			cQuery += " FROM " + RetSqlName("SD3") + " SD3, " + RetSqlName("SD1") + " SD1 "
			cQuery += " WHERE SD3.D_E_L_E_T_ <> '*' "
			cQuery += "        AND SD3.D3_FILIAL = '" + xFilial("SD3") + "' " 
			cQuery += "        AND SD3.D3_COD = '" + SD2NF->D2_COD + "' "
			cQuery += "        AND SD3.D3_DOC = '" + SD2NF->B8_DOC + "' "
			cQuery += "        AND SD3.D3_LOCALIZ = '' "
			cQuery += "        AND SD3.D3_TM = '999' "
		    
			cQuery += " ORDER BY SD3.D3_FILIAL, SD3.D3_DOC "
	
			cQuery := ChangeQuery(cQuery)
	
			If Select("SD3NF") > 0
				DbSelectArea("SD3NF")
				SD3NF->(DbCloseArea())
			EndIf
			
			dbUseArea(.T.,"TOPCONN",TCGenqry(,,cQuery),"SD3NF",.F.,.T.)
	
			DbSelectArea("SD3NF")
			SD3NF->(DbGotop())
			
			cLoteD3:= SD3NF->D3_LOTECTL
			
			While LoteD1() = .F. .And. !Empty(cLoteD3)
			
				cQuery := " SELECT SB8.B8_FILIAL, "
				cQuery += "        SB8.B8_DOC, "
				cQuery += "        SB8.B8_SERIE, "
				cQuery += "        SB8.B8_PRODUTO, "
				cQuery += "        SB8.B8_LOTECTL "
			
				cQuery += " FROM " + RetSqlName("SB8") + " SB8 "
				cQuery += " WHERE SB8.D_E_L_E_T_ <> '*' "
				cQuery += "        AND SB8.B8_FILIAL = '" + xFilial("SB8") + "' " 
				cQuery += "        AND SB8.B8_PRODUTO = '" + SD2NF->D2_COD + "' "
				cQuery += "        AND SB8.B8_LOTECTL = '" + cLoteD3 + "' "
		    
				cQuery += " ORDER BY SB8.B8_FILIAL, SB8.B8_DOC "
	
				cQuery := ChangeQuery(cQuery)
	
				If Select("SB8NF") > 0
					DbSelectArea("SB8NF")
					SB8NF->(DbCloseArea())
				EndIf
			
				dbUseArea(.T.,"TOPCONN",TCGenqry(,,cQuery),"SB8NF",.F.,.T.)
		
				DbSelectArea("SB8NF")
				SB8NF->(DbGotop())
				
				If Empty(SB8NF->B8_SERIE)
				
					cQuery := " SELECT SD3.D3_FILIAL, "
					cQuery += "        SD3.D3_DOC, "
					cQuery += "        SD3.D3_COD, "
					cQuery += "        SD3.D3_LOCAL, "
					cQuery += "        SD3.D3_LOTECTL "
					
					cQuery += " FROM " + RetSqlName("SD3") + " SD3, " + RetSqlName("SD1") + " SD1 "
					cQuery += " WHERE SD3.D_E_L_E_T_ <> '*' "
					cQuery += "        AND SD3.D3_FILIAL = '" + xFilial("SD3") + "' " 
					cQuery += "        AND SD3.D3_COD = '" + SB8NF->B8_PRODUTO + "' "
					cQuery += "        AND SD3.D3_DOC = '" + SB8NF->B8_DOC + "' "
					cQuery += "        AND SD3.D3_LOCALIZ = '' "
					cQuery += "        AND SD3.D3_TM = '999' "
				    
					cQuery += " ORDER BY SD3.D3_FILIAL, SD3.D3_DOC "
			
					cQuery := ChangeQuery(cQuery)
			
					If Select("SD3NF") > 0
						DbSelectArea("SD3NF")
						SD3NF->(DbCloseArea())
					EndIf
					
					dbUseArea(.T.,"TOPCONN",TCGenqry(,,cQuery),"SD3NF",.F.,.T.)
			
					DbSelectArea("SD3NF")
					SD3NF->(DbGotop())
					
					cLoteD3:= SD3NF->D3_LOTECTL
					                    
				Else
				
					oSection:Cell("NFENT"	):SetValue(SB8NF->B8_DOC + "-" + SB8NF->B8_SERIE)
					Exit
				
				EndIf                

			End
			
			If !Empty(cLoteD3)
				oSection:Cell("NFENT"	):SetValue(SD1NF->D1_DOC + "-" + SD1NF->D1_SERIE)
			Else
				oSection:Cell("NFENT"	):SetValue("-")
			EndIf			
				
		Else

			oSection:Cell("NFENT"	):SetValue(SD2NF->B8_DOC + "-" + SD2NF->B8_SERIE)
		
		EndIf
		
		oSection:Cell("LOTE"	):SetValue(IIF(!Empty(cLoteD3),AllTrim(cLoteD3), SD2NF->B8_LOTECTL )  )
		oSection:Cell("CF"		):SetValue(AllTrim(SD2NF->D2_CF))

		oSection:PrintLine()
	
		SD2NF->(DbSkip())

	EndDo
	
	SD2NF->(DbCloseArea())

ElseIf MV_PAR03 = 2 //Entrada

	cQuery := " SELECT SD1.D1_FILIAL, "
	cQuery += "        SD1.D1_DOC, "
	cQuery += "        SD1.D1_SERIE, "
	cQuery += "        SD1.D1_EMISSAO, "
	cQuery += "        SD1.D1_COD, "
	cQuery += "        SD1.D1_QUANT, "
	cQuery += "        SD1.D1_VUNIT, "
	cQuery += "        SD1.D1_TOTAL, "
	cQuery += "        SD1.D1_CUSTO, "
	cQuery += "        SD1.D1_BASEICM, "
	cQuery += "        SD1.D1_VALICM, "
	cQuery += "        SD1.D1_VALIPI, "
	cQuery += "        SD1.D1_ICMSRET, "
	cQuery += "        SD1.D1_PICM, "
	cQuery += "        SD1.D1_FORNECE, "
	cQuery += "        SD1.D1_LOJA, "  
	cQuery += "        SD1.D1_CF, "	
	cQuery += "        SD1.D1_TIPO, "  

	cQuery += "        SA2.A2_NREDUZ, "

	cQuery += "        SB1.B1_DESC, "

	cQuery += "        SB8.B8_DATA, "  
	cQuery += "        SB8.B8_DOC, "  
	cQuery += "        SB8.B8_LOTECTL, "
	cQuery += "        SB8.B8_SERIE "  
	
	cQuery += " FROM " + RetSqlName("SD1") + " SD1, " + RetSqlName("SB1") + " SB1, " + RetSqlName("SA2") + " SA2, " + RetSqlName("SB8") + " SB8 " 
	cQuery += " WHERE SD1.D_E_L_E_T_ <> '*' AND SB1.D_E_L_E_T_ <> '*' AND SA2.D_E_L_E_T_ <> '*' AND SB8.D_E_L_E_T_ <> '*' "
	cQuery += "        AND SD1.D1_FILIAL = '" + xFilial("SD1") + "' " 
	
	cQuery += "        AND SD1.D1_COD = SB1.B1_COD " 
	cQuery += "        AND SD1.D1_FORNECE = SA2.A2_COD "
	cQuery += "        AND SD1.D1_LOJA = SA2.A2_LOJA "
	
	cQuery += "        AND SD1.D1_EMISSAO BETWEEN '" + DTOS(MV_PAR01) + "' AND '" + DTOS(MV_PAR02) + "' "
	
	//cQuery += "        AND SB8.B8_DATA <= '" + DTOS(MV_PAR03) + "' "
	
	cQuery += "        AND SD1.D1_LOTECTL = SB8.B8_LOTECTL "
	cQuery += "        AND SD1.D1_COD = SB8.B8_PRODUTO " 
	cQuery += "        AND SD1.D1_LOCAL = SB8.B8_LOCAL "
	cQuery += "        AND SD1.D1_FILIAL = SB8.B8_FILIAL "
	//cQuery += "        AND SB8.B8_SERIE = '003' "
	
	
	cQuery += " ORDER BY SD1.D1_FILIAL, SD1.D1_DOC, SD1.D1_SERIE "
	
	cQuery := ChangeQuery(cQuery)
	
	If Select("SD1NF") > 0                                               '
		DbSelectArea("SD1NF")
		SD1NF->(DbCloseArea())
	EndIf
	
	dbUseArea(.T.,"TOPCONN",TCGenqry(,,cQuery),"SD1NF",.F.,.T.)
	
	DbSelectArea("SD1NF")
	SD1NF->(DbGotop())
	oSection:Init()
    
	oReport:SetMeter( SD1NF->( RecCount() ) )

	While SD1NF->(!Eof())
	
		//oSection:Cell("FILIAL"	):SetValue(SD1NF->D1_FILIAL)
		oSection:Cell("DTEMINF"	):SetValue(Substr(SD1NF->D1_EMISSAO,7,2) + "/" + Substr(SD1NF->D1_EMISSAO,5,2) + "/" + Substr(SD1NF->D1_EMISSAO,3,2))
		oSection:Cell("NUMNF"	):SetValue(SD1NF->D1_DOC + "-" + SD1NF->D1_SERIE)
		oSection:Cell("CLIENTE"	):SetValue(SD1NF->D1_FORNECE + "-" + SD1NF->D1_LOJA + "-" + SD1NF->A2_NREDUZ)
		oSection:Cell("PRODUTO"	):SetValue(AllTrim(SD1NF->D1_COD))
		oSection:Cell("DESCPRO"	):SetValue(SD1NF->B1_DESC)
		oSection:Cell("QTDE"	):SetValue(SD1NF->D1_QUANT)
		oSection:Cell("UNITARIO"):SetValue(SD1NF->D1_VUNIT)
		oSection:Cell("TOTAL"	):SetValue(SD1NF->D1_TOTAL)
		oSection:Cell("CUSTO"	):SetValue(SD1NF->D1_CUSTO)
		oSection:Cell("BASEICM"	):SetValue(SD1NF->D1_BASEICM)
		oSection:Cell("PICMS"	):SetValue(SD1NF->D1_PICM)
		oSection:Cell("ICMS"	):SetValue(SD1NF->D1_VALICM)
		oSection:Cell("IPI"		):SetValue(SD1NF->D1_VALIPI)
		oSection:Cell("ICMSST"	):SetValue(SD1NF->D1_ICMSRET)
		oSection:Cell("DTLOTE"	):SetValue(Substr(SD1NF->B8_DATA,7,2) + "/" + Substr(SD1NF->B8_DATA,5,2) + "/" + Substr(SD1NF->B8_DATA,3,2))
		oSection:Cell("NFENT"	):SetValue(SD1NF->B8_DOC + "-" + SD1NF->B8_SERIE)
		oSection:Cell("LOTE"	):SetValue(AllTrim(SD1NF->B8_LOTECTL))
		oSection:Cell("CF"		):SetValue(AllTrim(SD1NF->D1_CF))		
		oSection:PrintLine()
	
		SD1NF->(DbSkip())

	EndDo
	SD1NF->(DbCloseArea())

EndIf

oSection:Finish()
Return (Nil)

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒø±±
±±≥FunáÖo    ≥ValidP1   ≥ Autor ≥ Marcelo - Ethosx      ≥ Data ≥ 29.04.19  ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÖo ≥ Parametros da rotina.                			      	   ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/

Static Function ValidP1(cPerg)

dbSelectArea("SX1")
dbSetOrder(1)

aRegs:={}              
aAdd(aRegs,{cPerg,"01","Data NF de ?                     "	,"","","mv_ch1" ,"D", 8,0,0,"G",""														,"mv_par01","","","","","","","","","","","","","","","","","","","","","","","","",""		,"","","","","","","",""})
aAdd(aRegs,{cPerg,"02","Data NF ate ?                    "	,"","","mv_ch2" ,"D", 8,0,0,"G","NaoVazio()"											,"mv_par02","","","","","","","","","","","","","","","","","","","","","","","","",""		,"","","","","","","",""})
aAdd(aRegs,{cPerg,"03","SaÌda/Entrada ?           		  "	,"","","mv_ch3" ,"C", 1,0,0,"C",""														,"mv_par03","SaÌda","SaÌda","SaÌda","","","Entrada","Entrada","Entrada","","","","","","","","","","","","","","","","","","","","","","","","",""} )

//aAdd(aRegs,{cPerg,"03","Data Lote Limite?                "	,"","","mv_ch3" ,"D", 8,0,0,"G",""														,"mv_par03","","","","","","","","","","","","","","","","","","","","","","","","",""		,"","","","","","","",""})

For i:=1 to Len(aRegs)
	If !dbSeek(cPerg + aRegs[i,2])
		RecLock("SX1",.T.)
		For j:=1 to FCount()
			FieldPut(j,aRegs[i,j])
		Next
		MsUnlock()
		dbCommit()
	Endif
Next
                          
Return(.T.)

Static Function LoteD1()

Local lRet:= .F.
Local cQuery:= ""

cQuery := " SELECT SD1.D1_FILIAL, "
cQuery += "        SD1.D1_DOC, "
cQuery += "        SD1.D1_SERIE, "
cQuery += "        SD1.D1_QUANT "

			
	
cQuery += " FROM " + RetSqlName("SD1") + " SD1 "
cQuery += " WHERE SD1.D_E_L_E_T_ <> '*' "
cQuery += "        AND SD1.D1_FILIAL = '" + xFilial("SD1") + "' " 
cQuery += "        AND SD1.D1_COD = '" + SD2NF->D2_COD + "' "
cQuery += "        AND SD1.D1_LOTECTL = '" + cLoteD3 + "' "
cQuery += "        AND SD1.D1_QUANT >= " + AllTrim(STR(SD2NF->D2_QUANT))

cQuery += " ORDER BY SD1.D1_FILIAL, SD1.D1_DOC "
	
cQuery := ChangeQuery(cQuery)
	
If Select("SD1NF") > 0
	DbSelectArea("SD1NF")
	SD1NF->(DbCloseArea())
EndIf
			
dbUseArea(.T.,"TOPCONN",TCGenqry(,,cQuery),"SD1NF",.F.,.T.)
	
DbSelectArea("SD1NF")
SD1NF->(DbGotop())
			
If SD1NF->(!EOF())
			
	lRet:= .T.
		
EndIf
           
Return lRet