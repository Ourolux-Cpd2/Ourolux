#INCLUDE "PROTHEUS.CH"
#INCLUDE "REPORT.CH"
#INCLUDE "TOPCONN.CH"

/*----------------------------------------------------------|
| Autor | Rodrigo Dias Nunes              | Data 19/01/2021	| 
|-----------------------------------------------------------|
| Funcao: OUROR020											|
|-----------------------------------------------------------|
| Relatorio Lead Time Import.         	                    |
------------------------------------------------------------*/

User Function OUROR020()

    Local oReport

	Private nDesemb  :=""
    Private nDiaSSZ  := SuperGetMv("FS_DIASSZ",.F.,130)
    Private nDiaITJ  := SuperGetMv("FS_DIAITJ",.F.,135)
    Private nDiaNAV  := SuperGetMv("FS_DIANAV",.F.,135)
    Private nTotProc := 0
    Private nDenMet  := 0
    Private nForMet  := 0

    dbSelectArea("SC1")

    oReport := ReportDef()
    oReport:PrintDialog() // Imprime os dados na Tela(Preview).

Return

/*----------------------------------------------------------|
| Autor | Rodrigo Dias Nunes              | Data 19/01/2021	| 
|-----------------------------------------------------------|
| Funcao: ReportDef											|
|-----------------------------------------------------------|
| Relatorio Lead Time Import.         	                    |
------------------------------------------------------------*/

Static Function ReportDef()

    Local oReport  // Objeto principal do Relatorio TReport
    Local oSection // Objeto da Secao. 
    //Local oBreak   // Objeto da Quebra(Sub Total Num SC).
    Local cPerg      := PADR("MEGA38",10) // Grupo de Perguntas.

    Pergunte(cPerg,.T.) // Caso o parametro esteja como .T. o sistema ira apresentar a tela de perguntas antes que abrir a tela configuracao do relatorio.

    // Apresenta a tela de impressao para o usuario configurar o relatorio.
    oReport:=TReport():New("OUROR020","OUROR020 - Lead Time Import ","OUROR020",{|oReport| PrintReport(oReport,oSection,cPerg)},"Lead Time Import")
    
    oReport:SetLandscape(.T.) 
    oSection:=TRSection():New(oReport,"OUROR020 - Lead Time Import ",{"SB1"})

    //Sintetico Fixado

    oSection:SetTotalInLine(.T.) // Define se os totalizadores da sessao serao impressos em linha ou coluna.

    //Grupo Dados Fornecedor
    TRCell():New(oSection ,"FILIAL"    	,,"Fil"	 	   		    ,		  ,04,,,"CENTER",,"CENTER")
    TRCell():New(oSection ,"FORNE"     	,,"Fornecedor"		    ,		  ,10,,,"LEFT",,"CENTER")
    
    //Grupo Numero de Documentos
    TRCell():New(oSection ,"NUMSC"     	,,"Sol.Compra"	        ,		  ,10,,,"CENTER",,"CENTER")
    TRCell():New(oSection ,"NUMPC"     	,,"Ped.Compra"	        ,		  ,10,,,"CENTER",,"CENTER")
    TRCell():New(oSection ,"NUMDESEMB" 	,,"Desembaraco" 	    ,		  ,18,,,"CENTER",,"CENTER")
    TRCell():New(oSection ,"NUMNF"     	,,"N.Fiscal"		    ,		  ,11,,,"CENTER",,"CENTER")

    //Grupo Datas de Registros
    TRCell():New(oSection ,"DTEMSC"   	,,"Dt. Emis.SC"    	    ,		  ,11,,,"CENTER",,"CENTER")
    TRCell():New(oSection ,"DTLIB02"   	,,"Dt. Lib.N2"    	    ,		  ,11,,,"CENTER",,"CENTER")
    TRCell():New(oSection ,"DTDESEMB"  	,,"Dt. Desembaraco"	    ,		  ,14,,,"CENTER",,"CENTER")
    TRCell():New(oSection ,"DTSINAL"   	,,"Dt. Pgto.Sinal"  	,		  ,11,,,"CENTER",,"CENTER")
    TRCell():New(oSection ,"PSIREAL"   	,,"Dt. PSI. Realizado"  ,		  ,11,,,"CENTER",,"CENTER")
    TRCell():New(oSection ,"PSIAPR"   	,,"Dt. PSI. Aprovado"  	,		  ,11,,,"CENTER",,"CENTER")
    TRCell():New(oSection ,"DTEMBAR"   	,,"Dt. Embarque"  	    ,		  ,11,,,"CENTER",,"CENTER")
    TRCell():New(oSection ,"DTPORTO"   	,,"Dt. AtracaÁ„o"       ,		  ,11,,,"CENTER",,"CENTER")
    TRCell():New(oSection ,"DTEMINF"   	,,"Dt. Nota Fiscal"	 	,		  ,19,,,"CENTER",,"CENTER")
    
    //Grupo Resultado das Fases (Dias)
    TRCell():New(oSection ,"PCN2" 	    ,,"PC x N2"	   	   	            ,"@E 9999",04,,,"CENTER",,"CENTER")
    TRCell():New(oSection ,"N2SINAL" 	,,"N2 x Sinal"	   	   	        ,"@E 9999",04,,,"CENTER",,"CENTER")
    TRCell():New(oSection ,"SINPSIR" 	,,"Sinal x PSI R (PRODU«√O)"    ,"@E 9999",04,,,"CENTER",,"CENTER")
    TRCell():New(oSection ,"PSIRPSIA" 	,,"PSI R x PSI A (QUALIDADE)"   ,"@E 9999",04,,,"CENTER",,"CENTER")
    TRCell():New(oSection ,"PSIAEMB" 	,,"PSI A x Embarque"	   	   	,"@E 9999",04,,,"CENTER",,"CENTER")
    TRCell():New(oSection ,"MAR"   	   	,,"Embarque x AtracaÁ„o(Mar)"   ,"@E 9999",04,,,"CENTER",,"CENTER")
    TRCell():New(oSection ,"DESEMB"    	,,"AtracaÁ„o x NF(Porto)"       ,"@E 9999",04,,,"CENTER",,"CENTER")

    //Grupo Resultado Final (Dias)
    TRCell():New(oSection ,"1COMPRA" 	,,"1™ Compra"   	        ,"@E 9999",04,,,"CENTER",,"CENTER")
    TRCell():New(oSection ,"CDENT"  	,,"CD"				        ,""		  ,04,,,"CENTER",,"CENTER")
	TRCell():New(oSection ,"PREVISTO"  	,,"Previsto"		        ,"@E 9999",04,,,"CENTER",,"CENTER")
    TRCell():New(oSection ,"DIAPROG"  	,,"Programacao"	  	        ,"@E 9999",04,,,"CENTER",,"CENTER")
    TRCell():New(oSection ,"REALIZADO" 	,,"Realizado (N2xNF) OTD"	,"@E 9999",04,,,"CENTER",,"CENTER")
    TRCell():New(oSection ,"DIFERENCA"  ,,"Diferenca"		        ,"@E 9999",04,,,"CENTER",,"CENTER")
    TRCell():New(oSection ,"SCNF" 	    ,,"SCxNF"   		        ,"@E 9999",04,,,"CENTER",,"CENTER")

    //oBreak:=TRBreak():New(oSection,oSection:Cell("FILIAL"),"MEDIA POR FILIAL",.F.) // Quebra por Filial
    
    
    TRFunction():New(oSection:Cell("DIFERENCA")	    ,NIL,"ONPRINT",/*oBreak*/,"PROCESSOS ELEGIVEIS:"  ,,{|| nTotProc 	} 	/*uFormula*/,.F./*Total da Seùùo*/,.T./*Total Geral*/,.F./*Total da Pagina*/)
    TRFunction():New(oSection:Cell("DIFERENCA")	    ,NIL,"ONPRINT",/*oBreak*/,"DENTRO DA META:"		  ,,{|| nDenMet 	} 	/*uFormula*/,.F./*Total da Seùùo*/,.T./*Total Geral*/,.F./*Total da Pagina*/)
    TRFunction():New(oSection:Cell("DIFERENCA")	    ,NIL,"ONPRINT",/*oBreak*/,"FORA DA META:"		  ,,{|| nForMet 	} 	/*uFormula*/,.F./*Total da Seùùo*/,.T./*Total Geral*/,.F./*Total da Pagina*/)

Return oReport

/*----------------------------------------------------------|
| Autor | Rodrigo Dias Nunes              | Data 19/01/2021	| 
|-----------------------------------------------------------|
| Funcao: PrintReport									    |
|-----------------------------------------------------------|
| Relatorio Lead Time Import.         	                    |
------------------------------------------------------------*/
Static Function PrintReport(oReport,oSection)

    Local cQryFin    := ""
    Local cQryAbe    := ""
    Local cQuery     := ""
    Local nLeadPre   := 0   
	Local aRetW2	 := {}
    Local NN2XSIN    := 0
    Local NSINXPSR   := 0
    Local NPSRXPSA   := 0
    Local nPORxNF    := 0
    Local nPSAxEMB   := 0
    Local dDtLib2    := CTOD("  /  /  ")
    Local dDtDesemb  := CTOD("  /  /  ")
    Local nwDesemb	 := 0
    Local nEMBxPOR   := 0
    Local dEtd		 := CTOD("  /  /  ")
    Local detd2		 := CTOD("  /  /  ")
    Local WnMar		 := 0
    Local WDt_Nf	 := CTOD("  /  /  ")
    Local WDt_xEnt	 := CTOD("  /  /  ")
    Local Wdt_Prev   := CTOD("  /  /  ")
    Local cDIPROG	 := ""
    Local n1Compra   := 0
    Local aResDatas  := {}
    Local nPCxN2     := 0
    Local NN2XNF     := 0
    Local nSCxNF     := 0



    //Finalizados
    cQryFin := " SELECT SD1.D1_FILIAL, "
    cQryFin += "        SD1.D1_DTDIGIT, "
    cQryFin += "        SD1.D1_EMISSAO, "
    cQryFin += "        SWN.WN_PO_NUM, "
    cQryFin += "        SWN.WN_HAWB, "
    cQryFin += "        SWN.WN_DOC, "
    cQryFin += "        SWN.WN_SERIE, "
    cQryFin += "        SUM(SWN.WN_QUANT) WN_QUANT, "
    cQryFin += "        SWN.WN_FORNECE, "
    cQryFin += "        SWN.WN_LOJA, "
    cQryFin += " 	    SC7.C7_EMISSAO,"
    cQryFin += " 	    SC7.C7_NUMSC,"
    cQryFin += " 	    SC1.C1_NUM,"
    cQryFin += "        SC1.C1_FILIAL, "
    cQryFin += "        SC7.C7_PO_EIC, "
    cQryFin += "        SC7.C7_FORNECE "
    cQryFin += " FROM " + RetSqlName("SWN") + " SWN "
    cQryFin += " LEFT JOIN " +RetSqlName("SD1")+ " SD1 ON" 
    cQryFin += "        SWN.WN_PO_NUM = SD1.D1_PEDIDO AND "
    cQryFin += "        SWN.WN_ITEM = SD1.D1_ITEMPC AND "
    cQryFin += "        SWN.WN_FORNECE = SD1.D1_FORNECE AND "
    cQryFin += "        SWN.WN_LOJA = SD1.D1_LOJA AND"
    cQryFin += "        SWN.WN_SERIE = SD1.D1_SERIE AND "
    cQryFin += "        SWN.WN_DOC = SD1.D1_DOC AND "
    cQryFin += "		SWN.WN_TIPO_NF = SD1.D1_TIPO_NF"
    cQryFin += " LEFT JOIN " +RetSqlName("SC7")+ " SC7 ON" 
    cQryFin += "        SWN.WN_PRODUTO = SC7.C7_PRODUTO AND "
    cQryFin += "        SWN.WN_ITEM = SC7.C7_ITEM AND "
    cQryFin += "        SWN.WN_FORNECE = SC7.C7_FORNECE AND "
    cQryFin += "        SWN.WN_LOJA = SC7.C7_LOJA AND "
    cQryFin += "        SWN.WN_PO_NUM = SC7.C7_NUM "
    cQryFin += " LEFT JOIN " +RetSqlName("SC1")+ " SC1 ON" 
    cQryFin += "        SC1.C1_NUM = SC7.C7_NUMSC
    cQryFin += "        AND SC1.C1_FILIAL = SC7.C7_FILIAL"
    cQryFin += "        AND SC1.C1_EMISSAO BETWEEN '" + DTOS(MV_PAR05) + "' AND '" + DTOS(MV_PAR06) + "'"
    cQryFin += " WHERE SWN.D_E_L_E_T_ <> '*' AND SD1.D_E_L_E_T_ <> '*' AND SC7.D_E_L_E_T_ <> '*' "
    cQryFin += "        AND SWN.WN_TIPO_NF IN ('1','3','5') " 
    cQryFin += "        AND SD1.D1_FILIAL BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "'"
    cQryFin += "        AND SC7.C7_NUMSC BETWEEN '" + MV_PAR03 + "' AND '" + MV_PAR04 + "'"
    cQryFin += "        AND SWN.WN_PO_NUM BETWEEN '" + MV_PAR07 + "' AND '" + MV_PAR08 + "'"
    cQryFin += "        AND SWN.WN_DOC BETWEEN '" + MV_PAR09 + "' AND '" + MV_PAR10 + "'"
    cQryFin += "        AND SWN.WN_SERIE BETWEEN '" + MV_PAR11 + "' AND '" + MV_PAR12 + "'"
    cQryFin += "        AND SD1.D1_EMISSAO BETWEEN '" + DTOS(MV_PAR13) + "' AND '" + DTOS(MV_PAR14) + "'"

    If !Empty(MV_PAR15) .And. !Empty(MV_PAR17) .And. !Empty(MV_PAR16) .And. !Empty(MV_PAR18)
        cQryFin += "        AND SWN.WN_FORNECE BETWEEN '" + MV_PAR15 + "' AND '" + MV_PAR17 + "'"
        cQryFin += "        AND SWN.WN_LOJA  BETWEEN '" + MV_PAR16 + "' AND '" + MV_PAR18 + "'
    EndIf 

    cQryFin += " GROUP BY SD1.D1_FILIAL, SD1.D1_DTDIGIT, SWN.WN_PO_NUM, SWN.WN_HAWB, SWN.WN_SERIE, SWN.WN_FORNECE, SWN.WN_LOJA, "
    cQryFin += " SD1.D1_EMISSAO, SC7.C7_EMISSAO, SWN.WN_DOC, SC7.C7_NUMSC,SC1.C1_NUM,SC1.C1_FILIAL, SC7.C7_PO_EIC, SC7.C7_FORNECE "


    //Em abertos
    cQryAbe := " SELECT SD1.D1_FILIAL, "
    cQryAbe += "        SD1.D1_DTDIGIT, "
    cQryAbe += "        SD1.D1_EMISSAO, "
    cQryAbe += "        SWN.WN_PO_NUM, "
    cQryAbe += "        SWN.WN_HAWB, "
    cQryAbe += "        SWN.WN_DOC, "
    cQryAbe += "        SWN.WN_SERIE, "
    cQryAbe += "        Sum(SWN.WN_QUANT) WN_QUANT, "
    cQryAbe += "        SWN.WN_FORNECE, "
    cQryAbe += "        SWN.WN_LOJA, "
    cQryAbe += "        SC7.C7_EMISSAO, "
    cQryAbe += "        SC7.C7_NUMSC, "
    cQryAbe += "        SC1.C1_NUM, "
    cQryAbe += "        SC1.C1_FILIAL, "
    cQryAbe += "        SC7.C7_PO_EIC, "
    cQryAbe += "        SC7.C7_FORNECE "
    cQryAbe += " FROM ( "
    cQryAbe += " 	SELECT * FROM " + RetSqlName("SC1")
    cQryAbe += " 	WHERE C1_NUM BETWEEN '" + MV_PAR03 + "' AND '" + MV_PAR04 + "' "
    cQryAbe += " 	AND C1_IMPORT = 'S' "
    cQryAbe += "    AND C1_EMISSAO BETWEEN '" + DTOS(MV_PAR05) + "' AND '" + DTOS(MV_PAR06) + "'"
    cQryAbe += " 	AND D_E_L_E_T_ = ''	"
    cQryAbe += " 	) SC1 "
    cQryAbe += " LEFT JOIN " + RetSqlName("SC7") + " SC7 "
    cQryAbe += " 	ON SC7.C7_NUMSC = SC1.C1_NUM "
    cQryAbe += "    AND SC7.C7_FILIAL = SC1.C1_FILIAL "
    cQryAbe += " 	AND SC7.D_E_L_E_T_ = '' "
    cQryAbe += " LEFT JOIN " + RetSqlName("SWN") + " SWN "
    cQryAbe += " 	ON SWN.WN_PRODUTO = SC7.C7_PRODUTO "
    cQryAbe += " 	AND SWN.WN_ITEM = SC7.C7_ITEM "
    cQryAbe += " 	AND SWN.WN_FORNECE = SC7.C7_FORNECE "
    cQryAbe += " 	AND SWN.WN_LOJA = SC7.C7_LOJA "
    cQryAbe += " 	AND SWN.WN_PO_NUM = SC7.C7_NUM "
    cQryAbe += " 	AND SWN.WN_TIPO_NF IN ( '1', '3', '5' ) "
    cQryAbe += " 	AND SWN.WN_PO_NUM BETWEEN '" + MV_PAR07 + "' AND '" + MV_PAR08 + "' "
    cQryAbe += " 	AND SWN.WN_DOC BETWEEN '" + MV_PAR09 + "' AND '" + MV_PAR10 + "' "
    cQryAbe += " 	AND SWN.WN_SERIE BETWEEN '" + MV_PAR11 + "' AND '" + MV_PAR12 + "' " 
    
    If !Empty(MV_PAR15) .And. !Empty(MV_PAR17) .And. !Empty(MV_PAR16) .And. !Empty(MV_PAR18)
        cQryAbe += "        AND SWN.WN_FORNECE BETWEEN '" + MV_PAR15 + "' AND '" + MV_PAR17 + "'"
        cQryAbe += "        AND SWN.WN_LOJA  BETWEEN '" + MV_PAR16 + "' AND '" + MV_PAR18 + "'
    EndIf 
    
    cQryAbe += " LEFT JOIN " + RetSqlName("SD1") + " SD1 "
    cQryAbe += " 	ON SWN.WN_PO_NUM = SD1.D1_PEDIDO "
    cQryAbe += " 	AND SWN.WN_ITEM = SD1.D1_ITEMPC "
    cQryAbe += " 	AND SWN.WN_FORNECE = SD1.D1_FORNECE "
    cQryAbe += " 	AND SWN.WN_LOJA = SD1.D1_LOJA "
    cQryAbe += " 	AND SWN.WN_SERIE = SD1.D1_SERIE "
    cQryAbe += " 	AND SWN.WN_DOC = SD1.D1_DOC "
    cQryAbe += " 	AND SWN.WN_TIPO_NF = SD1.D1_TIPO_NF "
    cQryAbe += " 	AND SD1.D1_FILIAL BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "' "
    cQryAbe += " 	AND SD1.D1_EMISSAO BETWEEN '" + DTOS(MV_PAR13) + "' AND '" + DTOS(MV_PAR14) + "' "
    cQryAbe += " GROUP  BY SD1.D1_FILIAL, "
    cQryAbe += "           SD1.D1_DTDIGIT, "
    cQryAbe += "           SWN.WN_PO_NUM, "
    cQryAbe += "           SWN.WN_HAWB, "
    cQryAbe += "           SWN.WN_SERIE, "
    cQryAbe += "           SWN.WN_FORNECE, "
    cQryAbe += "           SWN.WN_LOJA, "
    cQryAbe += "           SD1.D1_EMISSAO, "
    cQryAbe += "           SC7.C7_EMISSAO, "
    cQryAbe += "           SWN.WN_DOC, "
    cQryAbe += "           SC7.C7_NUMSC, "
    cQryAbe += "           SC1.C1_NUM, "
    cQryAbe += "           SC1.C1_FILIAL, "
    cQryAbe += "           SC7.C7_PO_EIC, "
    cQryAbe += "           SC7.C7_FORNECE "

      
    If MV_PAR21 == 1
        cQuery := cQryFin
        cQuery += " ORDER BY SD1.D1_FILIAL, SWN.WN_HAWB DESC "
    ElseIf MV_PAR21 == 2
        cQuery := cQryAbe
        cQuery += " ORDER BY SD1.D1_FILIAL, SWN.WN_HAWB DESC "
    ElseIf MV_PAR21 == 3
        cQuery := cQryFin
        cQuery += "UNION ALL"
        cQuery += cQryAbe
        cQuery += " ORDER BY SD1.D1_FILIAL, SWN.WN_HAWB DESC "
    EndIf

    cQuery := ChangeQuery(cQuery)

    If Select("SCPCNF") > 0
        DbSelectArea("SCPCNF")
        SCPCNF->(DbCloseArea())
    EndIf

    dbUseArea(.T.,"TOPCONN",TCGenqry(,,cQuery),"SCPCNF",.F.,.T.)

    DbSelectArea("SCPCNF")
    SCPCNF->(DbGotop())

    oSection:Init()

    While SCPCNF->(!Eof())
        //Grupo Numero de Documentos
        If MV_PAR21 == 1
            oSection:Cell("FILIAL"):SetValue(SCPCNF->D1_FILIAL)
            oSection:Cell("NUMSC"):SetValue(SCPCNF->C7_NUMSC)
            oSection:Cell("NUMPC"):SetValue(SCPCNF->WN_PO_NUM)
            oSection:Cell("FORNE"):SetValue(ConsFor(SCPCNF->WN_FORNECE))
        Else
            oSection:Cell("FILIAL"):SetValue(SCPCNF->C1_FILIAL)
            oSection:Cell("NUMSC"):SetValue(SCPCNF->C1_NUM)
            oSection:Cell("NUMPC"):SetValue(SCPCNF->C7_PO_EIC)
            oSection:Cell("FORNE"):SetValue(ConsFor(SCPCNF->C7_FORNECE))
        EndIf    

        oSection:Cell("NUMDESEMB"):SetValue(SCPCNF->WN_HAWB)
        oSection:Cell("NUMNF"):SetValue(SCPCNF->WN_DOC)
        
        //Grupo Datas de Registros
        aResDatas:= ConsEtdEta(SCPCNF->WN_HAWB)
        
        SCR->(DbSetOrder(1))
        
        If MV_PAR21 == 1
            SCR->(DbSeek(SCPCNF->D1_FILIAL + "PC" + PADR(SCPCNF->WN_PO_NUM,TAMSX3("CR_NUM")[1])+"02") )
        Else
            SCR->(DbSeek(SCPCNF->C1_FILIAL + "PC" + PADR(SCPCNF->C7_PO_EIC,TAMSX3("CR_NUM")[1])+"02") )
        EndIf

        If MV_PAR21 == 1
            While SCR->CR_FILIAL == SCPCNF->D1_FILIAL .And. AllTrim(SCR->CR_NUM) == AllTrim(SCPCNF->WN_PO_NUM) .And. SCR->CR_TIPO == "PC" .And. SCR->CR_NIVEL == "02"
                If Empty(SCR->CR_DATALIB)
                    SCR->(DbSkip())
                Else
                    dDtLib2	  := SCR->CR_DATALIB
                    Exit
                EndIf
            End
        Else
            While SCR->CR_FILIAL == SCPCNF->C1_FILIAL .And. AllTrim(SCR->CR_NUM) == AllTrim(SCPCNF->C7_PO_EIC) .And. SCR->CR_TIPO == "PC" .And. SCR->CR_NIVEL == "02"
                If Empty(SCR->CR_DATALIB)
                    SCR->(DbSkip())
                Else
                    dDtLib2	  := SCR->CR_DATALIB
                    Exit
                EndIf
            End
        EndIf

        If AllTrim(nDesemb) <> AllTrim(SCPCNF->WN_HAWB) .or. len(Alltrim(nDesemb)) <> len(AllTrim(SCPCNF->WN_HAWB))
            dDtDesemb 	:= SToD(W6DATE(SCPCNF->WN_HAWB))
            nwDesemb	:= W6DATE(SCPCNF->WN_HAWB,SCPCNF->D1_EMISSAO)
            dEtd		:= Substr(aResDatas[1][2],7,2) + "/" + Substr(aResDatas[1][2],5,2) + "/" + Substr(aResDatas[1][2],3,2)
            dEtd2		:= aResDatas[1][2]
            WnMar		:= Val(aResDatas[1][1])
            WDt_Nf		:= Stod(aResDatas[1][3])
            WDt_xEnt	:= Stod(aResDatas[1][4])
            Wdt_Prev	:= Stod(aResDatas[1][5])
            Wdt_Emb  	:= Stod(aResDatas[1][6])
            Wdt_Porto	:= Stod(aResDatas[1][7])
            Wdt_PSIR	:= Stod(aResDatas[1][8])
            Wdt_PSIA	:= Stod(aResDatas[1][9])
            cDIPROG		:= AllTrim(cValToChar(CalcProg(SCPCNF->WN_PO_NUM,dDtLib2)))
        EndIf

        dt_Sin  := ConsSin(AllTrim(SCPCNF->WN_HAWB))
        If MV_PAR21 == 2 .OR. MV_PAR21 == 3
            dt_EmSC := GetAdvFVal("SC1","C1_EMISSAO",SCPCNF->C1_FILIAL+SCPCNF->C1_NUM,1)
        Else
            dt_EmSC := GetAdvFVal("SC1","C1_EMISSAO",SCPCNF->D1_FILIAL+SCPCNF->C7_NUMSC,1)
        EndIf
        oSection:Cell("DTEMSC"):SetValue(SubStr(Dtos(dt_EmSC),7,2) + "/" + SubStr(Dtos(dt_EmSC),5,2) + "/" + SubStr(Dtos(dt_EmSC),3,2) )
        oSection:Cell("DTLIB02"):SetValue(SubStr(Dtos(dDtLib2),7,2) + "/" + SubStr(Dtos(dDtLib2),5,2) + "/" + SubStr(Dtos(dDtLib2),3,2) )
        oSection:Cell("DTSINAL"):SetValue(SubStr(Dtos(dt_Sin),7,2) + "/" + SubStr(Dtos(dt_Sin),5,2) + "/" + SubStr(Dtos(dt_Sin),3,2) )
        oSection:Cell("DTDESEMB"):SetValue(SubStr(Dtos(dDtDesemb),7,2) + "/" + SubStr(Dtos(dDtDesemb),5,2) + "/" + SubStr(Dtos(dDtDesemb),3,2) )
        oSection:Cell("PSIREAL"):SetValue(SubStr(Dtos(Wdt_PSIR),7,2) + "/" + SubStr(Dtos(Wdt_PSIR),5,2) + "/" + SubStr(Dtos(Wdt_PSIR),3,2) )   
        oSection:Cell("PSIAPR"):SetValue(SubStr(Dtos(Wdt_PSIA),7,2) + "/" + SubStr(Dtos(Wdt_PSIA),5,2) + "/" + SubStr(Dtos(Wdt_PSIA),3,2) )
        oSection:Cell("DTEMBAR"):SetValue(SubStr(Dtos(Wdt_Emb),7,2) + "/" + SubStr(Dtos(Wdt_Emb),5,2) + "/" + SubStr(Dtos(Wdt_Emb),3,2) )
        oSection:Cell("DTPORTO"):SetValue(SubStr(Dtos(Wdt_Porto),7,2) + "/" + SubStr(Dtos(Wdt_Porto),5,2) + "/" + SubStr(Dtos(Wdt_Porto),3,2) )
        oSection:Cell("DTEMINF"):SetValue(Substr(SCPCNF->D1_EMISSAO,7,2) + "/" + Substr(SCPCNF->D1_EMISSAO,5,2) + "/" + Substr(SCPCNF->D1_EMISSAO,3,2)) 

        //Grupo resultado das fases
        If !Empty(SCPCNF->D1_EMISSAO)
            If !Empty(dDtLib2)
                nN2xNF := DateDiffDay(dDtLib2,STOD(SCPCNF->D1_EMISSAO))
            EndIf
            If !Empty(Wdt_Porto)
                nPORxNF := DateDiffDay(Wdt_Porto,STOD(SCPCNF->D1_EMISSAO))
                If STOD(SCPCNF->D1_EMISSAO) < Wdt_Porto
                    nPORxNF := nPORxNF * -1
                EndIf
            EndIf
        EndIf 
        
        IF !Empty(dDtLib2)
            nPCxN2 := DateDiffDay(STOD(SCPCNF->C7_EMISSAO),dDtLib2)
        EndIf

        IF !Empty(dDtLib2) .AND. !Empty(dt_Sin)
            nN2xSIN := DateDiffDay(dDtLib2,dt_Sin)
        EndIf

        IF !Empty(dt_Sin) .AND. !Empty(Wdt_PSIR)
            nSINxPSR := DateDiffDay(dt_Sin,Wdt_PSIR)
        EndIf

        IF !Empty(Wdt_PSIR) .AND. !Empty(Wdt_PSIA)
            nPSRxPSA := DateDiffDay(Wdt_PSIR,Wdt_PSIA)
        EndIf

        IF !Empty(Wdt_PSIA) .AND. !Empty(Wdt_Emb)
            nPSAxEMB := DateDiffDay(Wdt_PSIA,Wdt_Emb)
        EndIf

        IF !Empty(Wdt_Emb) .AND. !Empty(Wdt_Porto)
            nEMBxPOR := DateDiffDay(Wdt_Emb,Wdt_Porto)
        EndIf


        oSection:Cell("PCN2"):SetValue(nPCxN2)
        oSection:Cell("N2SINAL"):SetValue(nN2xSIN)
        oSection:Cell("SINPSIR"):SetValue(nSINxPSR)
        oSection:Cell("PSIRPSIA"):SetValue(nPSRxPSA)
        oSection:Cell("PSIAEMB"):SetValue(nPSAxEMB)
        oSection:Cell("MAR"):SetValue(nEMBxPOR)
        oSection:Cell("DESEMB"):SetValue(nPORxNF)

        //Grupo resultado Final
        
        IF !Empty(dt_EmSC)
            If !Empty(SCPCNF->D1_EMISSAO)
                nSCxNF := DateDiffDay(dt_EmSC,STOD(SCPCNF->D1_EMISSAO))
            Else
                nSCxNF := 0
            EndIf
        EndIf

        aRetW2	:= W2LEAD(SCPCNF->WN_PO_NUM,cDIPROG,dDtLib2)
        
		nLeadPre := aRetW2[1]
		cPorto	 := Alltrim(aRetW2[2])

        If MV_PAR21 == 1
            n1Compra := Busca1C(SCPCNF->WN_PO_NUM)
        Else
            n1Compra := Busca1C(SCPCNF->C7_PO_EIC)
        EndIf

        oSection:Cell("1COMPRA"):SetValue(n1Compra)
		oSection:Cell("CDENT"):SetValue(Iif(cPorto == "SSZ","GRU","NAV"))
        oSection:Cell("PREVISTO"):SetValue(nLeadPre - Val(cDiprog))
        oSection:Cell("DIAPROG"):SetValue(cDiprog)
        oSection:Cell("REALIZADO"):SetValue(nN2xNF - Val(cDiprog))
        oSection:Cell("DIFERENCA"):SetValue((nN2xNF - Val(cDiprog)) - n1Compra - nLeadPre)
        oSection:Cell("SCNF"):SetValue(nSCxNF)

        nTotProc++

        If ((nN2xNF - Val(cDiprog)) - n1Compra - nLeadPre) > 0
            nForMet++
        Else
            nDenMet++
        EndIf
        
        nN2xNF      := 0        
        nPCxN2      := 0
        nN2xSIN     := 0
        nSINxPSR    := 0
        nPSRxPSA    := 0
        nPSAxEMB    := 0
        nSCxNF      := 0
        n1Compra    := 0
        nEMBxPOR    := 0
        nPORxNF     := 0
        dDtLib2     := CTOD("  /  /  ")

        nDesemb:= SCPCNF->WN_HAWB //Identificar se numero de desembaraco e o mesmo

        oSection:PrintLine()
            
        SCPCNF->(dbSkip())
    EndDo

    oSection:Finish()

    SCPCNF->(DbCloseArea())

Return (Nil)
/*----------------------------------------------------------|
| Autor | Rodrigo Dias Nunes              | Data 19/01/2021	| 
|-----------------------------------------------------------|
| Funcao: ConsEtdEta										|
|-----------------------------------------------------------|
| Relatorio Lead Time Import.         	                    |
------------------------------------------------------------*/

Static Function ConsEtdEta(cDesemb)

    Local cResult 	:= "0"
    Local aResult	:= {}
    Local cQuery  	:= ""
    Local cAliasQry := GetNextAlias()
                                                                
	cQuery := " SELECT SW6.W6_DT_ETD ETD, SW6.W6_DT_ETA ETA, SW6.W6_DT_NF,  SW6.W6_XENTINI, SW6.W6_PRVENTR, " 
    cQuery += " SW6.W6_DT_EMB, SW6.W6_CHEG, SW6.W6_XPSIR, SW6.W6_XPSIA "
	cQuery += " FROM " + RetSqlName("SW6") + " SW6"
	cQuery += " WHERE SW6.W6_HAWB = '" + cDesemb + "'"
	cQuery += " AND D_E_L_E_T_ <> '*'"

	cQuery := ChangeQuery(cQuery)
	DbUseArea( .T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasQry,.F.,.T. )

	If !Empty((cAliasQry)->ETD) .And. !Empty((cAliasQry)->ETA)
		cResult := cValToChar(SToD((cAliasQry)->ETA) - SToD((cAliasQry)->ETD))
	Else 
		cResult := "0"
	EndIf

	cResult := AllTrim(cValToChar(cResult))
	
	aAdd(aResult,{ AllTrim(cValToChar(cResult)), (cAliasQry)->ETD, (cAliasQry)->W6_DT_NF, (cAliasQry)->W6_XENTINI, (cAliasQry)->W6_PRVENTR, (cAliasQry)->W6_DT_EMB, (cAliasQry)->W6_CHEG, (cAliasQry)->W6_XPSIR, (cAliasQry)->W6_XPSIA})

	(cAliasQry)->(DbCloseArea())

Return aResult

/*----------------------------------------------------------|
| Autor | Rodrigo Dias Nunes              | Data 19/01/2021	| 
|-----------------------------------------------------------|
| Funcao: ConsSin									    	|
|-----------------------------------------------------------|
| Relatorio Lead Time Import.         	                    |
------------------------------------------------------------*/

Static Function ConsSin(cDesemb)

    Local aArea		:= GetArea()
    Local cQuery    := ""
    Local cAliasQry := GetNextAlias()
    Local cDtSinal	:= ""

	cQuery := " SELECT TOP(1) WB_DT_DESE AS DT_SINAL FROM " + RetSqlName("SWB")
	cQuery += " WHERE WB_HAWB = '"+cDesemb+"' "
	cQuery += " AND WB_DT_DESE <> ''"
	cQuery += " AND D_E_L_E_T_ = '' "
	cQuery += " ORDER BY WB_DT_DESE "

	cQuery := ChangeQuery(cQuery)
	
    DbUseArea( .T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasQry,.F.,.T. )

	cDtSinal := STOD((cAliasQry)->DT_SINAL)

	(cAliasQry)->(DbCloseArea())

	RestArea(aArea)

Return cDtSinal

/*----------------------------------------------------------|
| Autor | Rodrigo Dias Nunes              | Data 19/01/2021	| 
|-----------------------------------------------------------|
| Funcao: ConsFor									    	|
|-----------------------------------------------------------|
| Relatorio Lead Time Import.         	                    |
------------------------------------------------------------*/

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

/*----------------------------------------------------------|
| Autor | Rodrigo Dias Nunes              | Data 19/01/2021	| 
|-----------------------------------------------------------|
| Funcao: CalcProg									    	|
|-----------------------------------------------------------|
| Relatorio Lead Time Import.         	                    |
------------------------------------------------------------*/
Static Function CalcProg(cDtETD,dtLibN2)

    Local aArea 	:= GetArea()
    Local nDia		:= 0
    Local dTemp		
    Local cQuery    := ""
    Local cAliasQry := GetNextAlias()

	cQuery := " SELECT W2_XDT_ETD FROM " + RetSqlName("SW2") + " WHERE W2_PO_NUM = '"+Alltrim(cDtETD)+"' AND D_E_L_E_T_ <> '*' " 
	DbUseArea( .T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasQry,.F.,.T. )

	If (cAliasQry)->(!EOF())
		dTemp := STOD((cAliasQry)->W2_XDT_ETD) - (MV_PAR19 + MV_PAR20)
		nDia := dTemp - dtLibN2
	EndIf
	(cAliasQry)->(DbCloseArea())

	If nDia < 0 
		nDia := 0
	EndIf
	
    RestArea(aArea)

    If Empty(dtLibN2)
        nDia := 0
    EndIf

Return nDia

/*----------------------------------------------------------|
| Autor | Rodrigo Dias Nunes              | Data 19/01/2021	| 
|-----------------------------------------------------------|
| Funcao: W6DATE									    	|
|-----------------------------------------------------------|
| Relatorio Lead Time Import.         	                    |
------------------------------------------------------------*/
Static Function W6DATE(nPonum,dDtemiss)

    Local aArea 	 := GetArea()
    Local dData

    Local cQuery     := ""

    Default nPonum	 := NIL
    Default dDtemiss := NIL

	cQuery := "Select SW6.W6_DT_HAWB, SW6.W6_DT_ETA "
	cQuery += "From "+RetSqlName("SW6")+" SW6 "
	cQuery += "Where SW6.D_E_L_E_T_ = '' AND SW6.W6_HAWB = '"+nPonum+"'"

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

/*----------------------------------------------------------|
| Autor | Rodrigo Dias Nunes              | Data 19/01/2021	| 
|-----------------------------------------------------------|
| Funcao: W2LEAD									    	|
|-----------------------------------------------------------|
| Relatorio Lead Time Import.         	                    |
------------------------------------------------------------*/
Static Function W2LEAD(nPonum,cDiaPrg,dtLibN2)
    Local aArea 	:= GetArea()
    Local nDias		:= 0
    Local dTemp		
    Local cQuery    := ""
	Local cPorto	:= ""
    Default nPonum	:= NIL

	cQuery := "SELECT W2_DEST FROM " + RetSqlName("SW2") + " WHERE W2_PO_NUM = '"+nPonum+"' AND D_E_L_E_T_ <> '*'"

	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TCGenqry(,,cQuery),"SW2LEAD",.F.,.T.)

	If SW2LEAD->(!EOF())
		If SW2LEAD->W2_DEST == "SSZ"
			dTemp := dtLibN2 + nDiaSSZ + Val(cDiaPrg)
			nDias := dTemp - dtLibN2
			cPorto := Alltrim(SW2LEAD->W2_DEST)
		ElseIf SW2LEAD->W2_DEST == "ITJ"
			dTemp := dtLibN2 + nDiaITJ + Val(cDiaPrg)
			nDias := dTemp - dtLibN2
			cPorto := Alltrim(SW2LEAD->W2_DEST)
		ElseIf SW2LEAD->W2_DEST == "NAV"
			dTemp := dtLibN2 + nDiaNAV + Val(cDiaPrg)
			nDias := dTemp - dtLibN2
			cPorto := Alltrim(SW2LEAD->W2_DEST)
		EndIf
	EndIf
	
	SW2LEAD->(DbCloseArea())

    RestArea(aArea)

Return {nDias,cPorto}

/*----------------------------------------------------------|
| Autor | Rodrigo Dias Nunes              | Data 29/01/2021	| 
|-----------------------------------------------------------|
| Funcao: Busca1C									    	|
|-----------------------------------------------------------|
| Relatorio Lead Time Import.         	                    |
------------------------------------------------------------*/
Static Function Busca1C(nPoNum)
    Local cQuery    := ""
    Local nDias     := 0 
	Default nPonum	:= ""

	cQuery := " SELECT W2_X1COMP FROM " + RetSqlName("SW2")
	cQuery += " WHERE W2_PO_NUM = '"+nPoNum+"'
	cQuery += " AND D_E_L_E_T_ = '' "

    If Select("W21C") > 0
        W21C->(dbCloseArea())
    EndIf

	dbUseArea(.T.,"TOPCONN",TCGenqry(,,cQuery),"W21C",.F.,.T.)

	If W21C->(!EOF())
		If Alltrim(W21C->W2_X1COMP) == "S"
            nDias := SuperGetMv("MV_X1COMP",.F.,20)
        EndIf
	EndIf
	
	W21C->(dbCloseArea())

Return nDias
