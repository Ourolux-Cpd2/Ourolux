#INCLUDE "PROTHEUS.CH"
#INCLUDE "REPORT.CH"
#INCLUDE "TOPCONN.CH"

/*----------------------------------------------------------|
| Autor | Rodrigo Dias Nunes              | Data 19/01/2021	| 
|-----------------------------------------------------------|
| Funcao: OUROR029											|
|-----------------------------------------------------------|
| Relatorio Lead Time Import.         	                    |
------------------------------------------------------------*/

User Function OUROR029()

    Local oReport

	Private nDesemb  :=""
    Private nDiaSSZ  := SuperGetMv("FS_DIASSZ",.F.,130)
    Private nDiaITJ  := SuperGetMv("FS_DIAITJ",.F.,135)
    Private nDiaNAV  := SuperGetMv("FS_DIANAV",.F.,135)
    Private nTotProc := 0
    Private nDenMet  := 0
    Private nForMet  := 0

    dbSelectArea("SC1")
    dbSelectArea("SYP")

    oReport := ReportDef()
    oReport:PrintDialog() 

Return

/*----------------------------------------------------------|
| Autor | Rodrigo Dias Nunes              | Data 19/01/2021	|
|-----------------------------------------------------------|
| Funcao: ReportDef											|
|-----------------------------------------------------------|
| Relatorio Lead Time Import.         	                    |
------------------------------------------------------------*/

Static Function ReportDef()

    Local oReport  
    Local oSection 
    Local cPerg      := PADR("OUROR029",10)

    Pergunte(cPerg,.T.) 

    oReport:=TReport():New("OUROR029","OUROR029 - Lead Time Import ","OUROR029",{|oReport| PrintReport(oReport,oSection)},"Lead Time Import")
    
    oReport:SetLandscape(.T.) 
    oSection:=TRSection():New(oReport,"OUROR029 - Lead Time Import ",{"SB1"})
    oSection:SetTotalInLine(.T.) 

    TRCell():New(oSection     ,"ORIGEM"    	,,"Nacional/Import."                        ,		  ,10,,,"CENTER",,"CENTER")//INFORMACOES PRINCIPAIS
    TRCell():New(oSection     ,"NUMSC"     	,,"Sol.Compra"	                            ,		  ,10,,,"CENTER",,"CENTER")//INFORMACOES PRINCIPAIS
    TRCell():New(oSection     ,"FAMILIA"   	,,"Família"  	                            ,		  ,10,,,"CENTER",,"CENTER")//INFORMACOES PRINCIPAIS
    TRCell():New(oSection     ,"NUMPC"     	,,"Ped.Compra"	                            ,		  ,10,,,"CENTER",,"CENTER")//INFORMACOES PRINCIPAIS
    TRCell():New(oSection     ,"FORNE"     	,,"Fornecedor"		                        ,		  ,10,,,"LEFT"  ,,"CENTER")//INFORMACOES PRINCIPAIS
    TRCell():New(oSection     ,"CONDPG"    	,,"Condicao de Pagamento"                   ,		  ,10,,,"CENTER",,"CENTER")//INFORMACOES PRINCIPAIS
    TRCell():New(oSection     ,"NUMDESEMB" 	,,"Desembaraco" 	                        ,		  ,18,,,"CENTER",,"CENTER")//INFORMACOES PRINCIPAIS
    TRCell():New(oSection     ,"NUMNF"     	,,"N.Fiscal"		                        ,		  ,11,,,"CENTER",,"CENTER")//INFORMACOES PRINCIPAIS
    TRCell():New(oSection     ,"PORDEST"  	,,"Porto Destino"                           ,		  ,11,,,"CENTER",,"CENTER")//INFORMACOES PRINCIPAIS
    TRCell():New(oSection     ,"FILCD"  	,,"Filial/CD"                               ,		  ,11,,,"CENTER",,"CENTER")//INFORMACOES PRINCIPAIS
    If MV_PAR20 == 2    
        TRCell():New(oSection ,"DTEMSC"   	,,"Emissao SC"    	                        ,		  ,11,,,"CENTER",,"CENTER")//DATAS
        TRCell():New(oSection ,"DTAPRSC"   	,,"Aprova SC"                               ,		  ,11,,,"CENTER",,"CENTER")//DATAS
        TRCell():New(oSection ,"DTENVAR"   	,,"Envio Arte"                              ,		  ,11,,,"CENTER",,"CENTER")//DATAS
        TRCell():New(oSection ,"DTAPRAR"   	,,"Aprova Arte"                             ,		  ,11,,,"CENTER",,"CENTER")//DATAS
        TRCell():New(oSection ,"DTEMIPO"   	,,"Emissao PO"                              ,		  ,11,,,"CENTER",,"CENTER")//DATAS
        TRCell():New(oSection ,"DTLIMSC"   	,,"Limite Compra SC"                        ,		  ,11,,,"CENTER",,"CENTER")//DATAS
        TRCell():New(oSection ,"DTLIB01"   	,,"Lib.N1"   	                            ,		  ,11,,,"CENTER",,"CENTER")//DATAS
        TRCell():New(oSection ,"DTLIB02"   	,,"Lib.N2"    	                            ,		  ,11,,,"CENTER",,"CENTER")//DATAS
        TRCell():New(oSection ,"DTSINAL"   	,,"Pgto.Sinal"  	                        ,		  ,11,,,"CENTER",,"CENTER")//DATAS
        TRCell():New(oSection ,"DTFIMPRD"  	,,"Fim Produção"  	                        ,		  ,11,,,"CENTER",,"CENTER")//DATAS
        TRCell():New(oSection ,"DTLIMPRD"  	,,"Lim. Produçao"  	                        ,		  ,11,,,"CENTER",,"CENTER")//DATAS
        TRCell():New(oSection ,"PSIINI"   	,,"PSI. Inicio"                             ,		  ,11,,,"CENTER",,"CENTER")//DATAS
        TRCell():New(oSection ,"PSIREAL"   	,,"PSI. Finalizado"                         ,		  ,11,,,"CENTER",,"CENTER")//DATAS
        TRCell():New(oSection ,"PSIAPR"   	,,"PSI. Aprovado"  	                        ,		  ,11,,,"CENTER",,"CENTER")//DATAS
        TRCell():New(oSection ,"DTEMBAR"   	,,"Embarque"  	                            ,		  ,11,,,"CENTER",,"CENTER")//DATAS
        TRCell():New(oSection ,"DTPORTO"   	,,"Atracação"                               ,		  ,11,,,"CENTER",,"CENTER")//DATAS
        TRCell():New(oSection ,"DTDESEMB"  	,,"Desembaraco"	                            ,		  ,14,,,"CENTER",,"CENTER")//DATAS
        TRCell():New(oSection ,"DTEMINF"   	,,"Nota Fiscal"	 	                        ,		  ,19,,,"CENTER",,"CENTER")//DATAS
        TRCell():New(oSection ,"DTENTSC"   	,,"Entrega (META)"                          ,		  ,11,,,"CENTER",,"CENTER")//DATAS
    EndIf   
    TRCell():New(oSection     ,"EMSCAPSC"  	,,"Emissao SC x Aprova SC"                  ,"@E 9999",11,,,"CENTER",,"CENTER")//ANALISES
    TRCell():New(oSection     ,"ENVXAPR"  	,,"Envio Arte x Aprova Arte"                ,"@E 9999",11,,,"CENTER",,"CENTER")//ANALISES
    TRCell():New(oSection     ,"EMPCAPSC"  	,,"Aprova SC x Emissao PO"                  ,"@E 9999",11,,,"CENTER",,"CENTER")//ANALISES
    TRCell():New(oSection     ,"ARTEMPC"  	,,"Aprova Arte x Emissao PO"                ,"@E 9999",11,,,"CENTER",,"CENTER")//ANALISES
    TRCell():New(oSection     ,"PCXLIM" 	,,"Emissao PO x Limite Compra"              ,"@E 9999",04,,,"CENTER",,"CENTER")//ANALISES
    TRCell():New(oSection     ,"PCN1" 	    ,,"PO x N1"     	                        ,"@E 9999",04,,,"CENTER",,"CENTER")//ANALISES
    TRCell():New(oSection     ,"N1N2" 	    ,,"N1 x N2"     	                        ,"@E 9999",04,,,"CENTER",,"CENTER")//ANALISES
    TRCell():New(oSection     ,"N2SINAL" 	,,"N2 x Sinal"	   	   	                    ,"@E 9999",04,,,"CENTER",,"CENTER")//ANALISES
    TRCell():New(oSection     ,"SINXPSIF" 	,,"Sinal x Fim Produção"                    ,"@E 9999",04,,,"CENTER",,"CENTER")//ANALISES
    TRCell():New(oSection     ,"LIPXFIMP" 	,,"Limit.Produção(SC) x Fim Produção"       ,"@E 9999",04,,,"CENTER",,"CENTER")//ANALISES
    TRCell():New(oSection     ,"FIMPPSII" 	,,"Fim Produção x PSI Início"               ,"@E 9999",04,,,"CENTER",,"CENTER")//ANALISES
    TRCell():New(oSection     ,"PSIXPSF" 	,,"PSI Início x PSI Finalizado"             ,"@E 9999",04,,,"CENTER",,"CENTER")//ANALISES
    TRCell():New(oSection     ,"SINPSIR" 	,,"Sinal x PSI Finalizado(PRODUÇÃO)"        ,"@E 9999",04,,,"CENTER",,"CENTER")//ANALISES
    TRCell():New(oSection     ,"PSIRPSIA" 	,,"PSI Finalizado x PSI A (QUALIDADE)"      ,"@E 9999",04,,,"CENTER",,"CENTER")//ANALISES
    TRCell():New(oSection     ,"PSIAEMB" 	,,"PSI A x Embarque"	   	   	            ,"@E 9999",04,,,"CENTER",,"CENTER")//ANALISES
    TRCell():New(oSection     ,"MAR"   	   	,,"Embarque x Atracação(Mar)"               ,"@E 9999",04,,,"CENTER",,"CENTER")//ANALISES
    TRCell():New(oSection     ,"DESEMB"    	,,"Atracação x NF(Porto)"                   ,"@E 9999",04,,,"CENTER",,"CENTER")//ANALISES
    TRCell():New(oSection     ,"1COMPRA" 	,,"1ª Compra"   	                        ,"@N"     ,01,,,"CENTER",,"CENTER")//ANALISES
    TRCell():New(oSection     ,"PREVISTO"  	,,"Previsto OTD"	                        ,"@E 9999",04,,,"CENTER",,"CENTER")//ANALISES
    TRCell():New(oSection     ,"REALIZADO" 	,,"Realizado OTD (N2 x NF)"	                ,"@E 9999",04,,,"CENTER",,"CENTER")//ANALISES
    TRCell():New(oSection     ,"DIFERENCA"  ,,"Diferenca OTD"		                    ,"@E 9999",04,,,"CENTER",,"CENTER")//ANALISES
    TRCell():New(oSection     ,"SCNF" 	    ,,"Realizado (SC x NF)"                     ,"@E 9999",04,,,"CENTER",,"CENTER")//ANALISES
    TRCell():New(oSection     ,"METAXNF" 	,,"Diferenca (META x NF)"	                ,"@E 9999",04,,,"CENTER",,"CENTER")//ANALISES

    TRFunction():New(oSection:Cell("DIFERENCA")	    ,NIL,"ONPRINT",,"PROCESSOS ELEGIVEIS:"  ,,{|| nTotProc 	},.F.,.T.,.F.)
    TRFunction():New(oSection:Cell("DIFERENCA")	    ,NIL,"ONPRINT",,"DENTRO DA META:"		,,{|| nDenMet 	},.F.,.T.,.F.)
    TRFunction():New(oSection:Cell("DIFERENCA")	    ,NIL,"ONPRINT",,"FORA DA META:"		    ,,{|| nForMet 	},.F.,.T.,.F.)

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
    Local dDtLib1    := CTOD("  /  /  ")
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
    Local Wdt_PSIR   := CTOD("  /  /  ")
    Local Wdt_PSIA   := CTOD("  /  /  ")
    Local Wdt_FIMP   := CTOD("  /  /  ")
    Local Wdt_Emb    := CTOD("  /  /  ")
    Local Wdt_Porto  := CTOD("  /  /  ")
    Local dt_LimPrd  := CTOD("  /  /  ")
    Local Wdt_PSII   := CTOD("  /  /  ")
    Local n1Compra   := 0
    Local aResDatas  := {}
    Local NN2XNF     := 0
    Local nSCxNF     := 0
    Local aDataNew   := {}
    Local cTexFil    := ""
    Local cDesembVez := ""
    Local cTpLinha   := ""
    Local cTabUso    := ""

    //Finalizados
    cQryFin := " SELECT 'IMP' AS ORIGEM, "
    cQryFin += "        SD1.D1_FILIAL, "
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
    cQryFin += "        SC7.C7_FORNECE, "
    cQryFin += "        SC7.C7_XHAWB, "
    cQryFin += "        SW6.W6_HAWB, "
    cQryFin += "        SC7.C7_NUM, "
    cQryFin += "        SC7.C7_FILIAL "
    cQryFin += " FROM " + RetSqlName("SWN") + " SWN "
    cQryFin += " LEFT JOIN " +RetSqlName("SD1")+ " SD1 ON " 
    cQryFin += "        SWN.WN_PO_NUM = SD1.D1_PEDIDO AND "
    cQryFin += "        SWN.WN_ITEM = SD1.D1_ITEMPC AND "
    cQryFin += "        SWN.WN_FORNECE = SD1.D1_FORNECE AND "
    cQryFin += "        SWN.WN_LOJA = SD1.D1_LOJA AND "
    cQryFin += "        SWN.WN_SERIE = SD1.D1_SERIE AND "
    cQryFin += "        SWN.WN_DOC = SD1.D1_DOC AND "
    cQryFin += "		SWN.WN_TIPO_NF = SD1.D1_TIPO_NF "
    cQryFin += " LEFT JOIN " +RetSqlName("SC7")+ " SC7 ON " 
    cQryFin += "        SWN.WN_PRODUTO = SC7.C7_PRODUTO AND "
    cQryFin += "        SWN.WN_ITEM = SC7.C7_ITEM AND "
    cQryFin += "        SWN.WN_FORNECE = SC7.C7_FORNECE AND "
    cQryFin += "        SWN.WN_LOJA = SC7.C7_LOJA AND "
    cQryFin += "        SWN.WN_PO_NUM = SC7.C7_NUM "
    cQryFin += " LEFT JOIN " + RetSqlName("SW6") + " SW6 "
	cQryFin += "        ON SW6.W6_PO_NUM = SC7.C7_NUM "
    cQryFin += "        AND SW6.W6_HAWB = SWN.WN_HAWB "
	cQryFin += "        AND SW6.D_E_L_E_T_ = ''	"
    cQryFin += " LEFT JOIN " +RetSqlName("SC1")+ " SC1 ON " 
    cQryFin += "        SC1.C1_NUM = SC7.C7_NUMSC "
    cQryFin += "        AND SC1.C1_FILIAL = SC7.C7_FILIAL "
    cQryFin += "        AND SC1.C1_EMISSAO BETWEEN '" + DTOS(MV_PAR05) + "' AND '" + DTOS(MV_PAR06) + "' "
    cQryFin += " WHERE SWN.D_E_L_E_T_ <> '*' AND SD1.D_E_L_E_T_ <> '*' AND SC7.D_E_L_E_T_ <> '*' "
    cQryFin += "        AND SWN.WN_TIPO_NF IN ('1','3','5') " 
    cQryFin += "        AND SD1.D1_FILIAL BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "' "
    cQryFin += "        AND SC7.C7_NUMSC BETWEEN '" + MV_PAR03 + "' AND '" + MV_PAR04 + "' "
    cQryFin += "        AND SC7.C7_NUM BETWEEN '" + MV_PAR07 + "' AND '" + MV_PAR08 + "' " 
    cQryFin += "        AND SWN.WN_PO_NUM BETWEEN '" + MV_PAR07 + "' AND '" + MV_PAR08 + "' "
    cQryFin += "        AND SWN.WN_DOC BETWEEN '" + MV_PAR09 + "' AND '" + MV_PAR10 + "' "
    cQryFin += "        AND SWN.WN_SERIE BETWEEN '" + MV_PAR11 + "' AND '" + MV_PAR12 + "' "
    cQryFin += "        AND SD1.D1_EMISSAO BETWEEN '" + DTOS(MV_PAR13) + "' AND '" + DTOS(MV_PAR14) + "' "

    If !Empty(MV_PAR15) .And. !Empty(MV_PAR17) .And. !Empty(MV_PAR16) .And. !Empty(MV_PAR18)
        cQryFin += "        AND SWN.WN_FORNECE BETWEEN '" + MV_PAR15 + "' AND '" + MV_PAR17 + "' "
        cQryFin += "        AND SWN.WN_LOJA  BETWEEN '" + MV_PAR16 + "' AND '" + MV_PAR18 + "' "
    EndIf 

    cQryFin += " GROUP BY SD1.D1_FILIAL, SD1.D1_DTDIGIT, SWN.WN_PO_NUM, SWN.WN_HAWB, SWN.WN_SERIE, SWN.WN_FORNECE, SWN.WN_LOJA, "
    cQryFin += " SD1.D1_EMISSAO, SC7.C7_EMISSAO, SWN.WN_DOC, SC7.C7_NUMSC,SC1.C1_NUM,SC1.C1_FILIAL, SC7.C7_PO_EIC, SC7.C7_FORNECE, SC7.C7_XHAWB, SW6.W6_HAWB, SC7.C7_NUM, SC7.C7_FILIAL "

    //Em abertos
    cQryAbe := " SELECT 'IMP' AS ORIGEM, "
    cQryAbe += "        SD1.D1_FILIAL, "
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
    cQryAbe += "        SC7.C7_FORNECE, "
    cQryAbe += "        SC7.C7_XHAWB, "
    cQryAbe += "        SW6.W6_HAWB, "
    cQryAbe += "        SC7.C7_NUM, "
    cQryAbe += "        SC7.C7_FILIAL "
    cQryAbe += " FROM   (SELECT * "
    cQryAbe += "         FROM  " + RetSqlName("SC1")
    cQryAbe += " 	WHERE C1_NUM BETWEEN '" + MV_PAR03 + "' AND '" + MV_PAR04 + "' "
    cQryAbe += " 	AND C1_IMPORT = 'S' "
    cQryAbe += "    AND C1_EMISSAO BETWEEN '" + DTOS(MV_PAR05) + "' AND '" + DTOS(MV_PAR06) + "'"
    cQryAbe += "    AND C1_APROV = 'L' "
    cQryAbe += " 	AND D_E_L_E_T_ = ''	"
    cQryAbe += " 	) SC1 "
    cQryAbe += " LEFT JOIN " + RetSqlName("SC7") + " SC7 "
    cQryAbe += " 	ON SC7.C7_NUMSC = SC1.C1_NUM "
    cQryAbe += "    AND SC7.C7_FILIAL = SC1.C1_FILIAL "
    cQryAbe += "    AND SC7.C7_NUM BETWEEN '" + MV_PAR07 + "' AND '" + MV_PAR08 + "' "
    cQryAbe += " 	AND SC7.D_E_L_E_T_ = '' "
    cQryAbe += " LEFT JOIN " + RetSqlName("SW6") + " SW6 "
    cQryAbe += "    ON SW6.W6_PO_NUM = SC7.C7_NUM "
    cQryAbe += " 	AND SW6.D_E_L_E_T_ = ''	"
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
    cQryAbe += " 	AND SWN.WN_DOC = '' "
    cQryAbe += "    AND SWN.D_E_L_E_T_ = '' "

    If !Empty(MV_PAR15) .And. !Empty(MV_PAR17) .And. !Empty(MV_PAR16) .And. !Empty(MV_PAR18)
        cQryAbe += "        AND SC7.C7_FORNECE BETWEEN '" + MV_PAR15 + "' AND '" + MV_PAR17 + "' "
        cQryAbe += "        AND SC7.C7_LOJA  BETWEEN '" + MV_PAR16 + "' AND '" + MV_PAR18 + "' "
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
    cQryAbe += "           SC7.C7_FORNECE, "
    cQryAbe += "           SC7.C7_XHAWB, "
    cQryAbe += "           SW6.W6_HAWB, "
    cQryAbe += "           SC7.C7_NUM, "
    cQryAbe += "           SC7.C7_FILIAL "
    
    //Nacionais
    cQryNac := " SELECT 'NAC' AS ORIGEM,
    cQryNac += "        SC7.C7_FILIAL, " 					
    cQryNac += " 		SD1.D1_DTDIGIT, "				
    cQryNac += " 		SD1.D1_EMISSAO, "				
    cQryNac += " 		'' as WN_PO_NUM, "
    cQryNac += " 		SC7.C7_XHAWB, "   				
    cQryNac += " 		SD1.D1_DOC, " 				
    cQryNac += " 		SD1.D1_SERIE, "					
    cQryNac += " 		Sum(SD1.D1_QUANT) AS D1_QUANT, "
    cQryNac += " 		SD1.D1_FORNECE, "					
    cQryNac += " 		SD1.D1_LOJA, "					
    cQryNac += " 		SC7.C7_EMISSAO, "
    cQryNac += "        SC7.C7_NUMSC, "				
    cQryNac += "        SC1.C1_NUM, "						
    cQryNac += "        SC1.C1_FILIAL, "					
    cQryNac += "        SC7.C7_PO_EIC, "					
    cQryNac += "        SC7.C7_FORNECE, "					
    cQryNac += "        SC7.C7_XHAWB, "					
    cQryNac += " 		'' as W6_HAWB, "
    cQryNac += " 		SC7.C7_NUM, "
    cQryNac += " 		SC7.C7_FILIAL "
    cQryNac += " FROM   (SELECT * "
    cQryNac += "         FROM  " + RetSqlName("SC1")
    cQryNac += "         WHERE  C1_NUM BETWEEN '" + MV_PAR03 + "' AND '" + MV_PAR04 + "' "
    cQryNac += "                AND C1_IMPORT = 'N' "
    cQryNac += "                AND C1_EMISSAO BETWEEN '" + DTOS(MV_PAR05) + "' AND '" + DTOS(MV_PAR06) + "' "
    cQryNac += "                AND C1_APROV = 'L' "
    cQryNac += "                AND D_E_L_E_T_ = ' ') SC1 "
    cQryNac += "        LEFT JOIN " + RetSqlName("SC7") + " SC7 "
    cQryNac += "               ON SC7.C7_NUMSC = SC1.C1_NUM "
    cQryNac += "                  AND SC7.C7_FILIAL = SC1.C1_FILIAL "
    cQryNac += "                  AND SC7.C7_NUM BETWEEN '" + MV_PAR07 + "' AND '" + MV_PAR08 + "' "
    cQryNac += " 				 AND SC7.C7_PO_EIC = '' "
    cQryNac += "                  AND SC7.D_E_L_E_T_ = ' ' "
    cQryNac += "        LEFT JOIN " + RetSqlName("SD1") + " SD1 "
    cQryNac += "               ON SD1.D1_PEDIDO = SC7.C7_NUM "
    cQryNac += "                  AND SD1.D1_ITEMPC = SC7.C7_ITEM "
    cQryNac += "                  AND SD1.D1_FORNECE = SC7.C7_FORNECE "
    cQryNac += "                  AND SD1.D1_LOJA = SC7.C7_LOJA "
    cQryNac += "                  AND SD1.D1_FILIAL BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "' "
    cQryNac += "                  AND SD1.D1_EMISSAO BETWEEN '" + DTOS(MV_PAR13) + "' AND '" + DTOS(MV_PAR14) + "' "
    cQryNac += " 	   INNER JOIN " + RetSqlName("SB1") + " SB1 "
    cQryNac += " 			  ON SB1.B1_COD = SC7.C7_PRODUTO "
    cQryNac += " 				 AND SB1.B1_XREVEND = 'S' "
    cQryNac += " 				 AND SB1.D_E_L_E_T_ = '' "
    cQryNac += " GROUP  BY SC7.C7_FILIAL, " 				 	
    cQryNac += " 		SD1.D1_DTDIGIT, "			
    cQryNac += " 		SD1.D1_EMISSAO, " 				
    cQryNac += " 		SC7.C7_NUM, "	    				
    cQryNac += " 		SC7.C7_XHAWB, "   				
    cQryNac += " 		SD1.D1_DOC, "	    				
    cQryNac += " 		SD1.D1_SERIE, "					
    cQryNac += " 		SD1.D1_FORNECE, "					
    cQryNac += " 		SD1.D1_LOJA, "					
    cQryNac += " 		SC7.C7_EMISSAO, "					
    cQryNac += "        SC7.C7_NUMSC, "					
    cQryNac += "        SC1.C1_NUM, "						
    cQryNac += "        SC1.C1_FILIAL, "					
    cQryNac += "        SC7.C7_PO_EIC, "					
    cQryNac += "        SC7.C7_FORNECE, "					
    cQryNac += "        SC7.C7_XHAWB, "
    cQryNac += "        SC7.C7_NUM, "
    cQryNac += "        SC7.C7_FILIAL "
    
    If MV_PAR19 == 1
        cQuery := cQryFin
        cQuery += "UNION ALL "
        cQuery += cQryNac
        cQuery += " ORDER BY SD1.D1_FILIAL, SWN.WN_HAWB DESC "
    ElseIf MV_PAR19 == 2
        cQuery := cQryAbe
        cQuery += "UNION ALL "
        cQuery += cQryNac
        cQuery += " ORDER BY SC1.C1_NUM DESC "
    ElseIf MV_PAR19 == 3
        cQuery := cQryFin
        cQuery += "UNION ALL "
        cQuery += cQryAbe
        cQuery += "UNION ALL "
        cQuery += cQryNac
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
        cQryFam := " SELECT BM_DESC FROM " + RetSqlName("SBM")
		cQryFam += " WHERE BM_GRUPO IN (SELECT B1_GRUPO FROM " + RetSqlName("SB1")
		cQryFam += " 				   WHERE B1_COD IN ( "
        
        If !Empty(SCPCNF->C7_PO_EIC) 
            cTabUso := "SC7"
            cQryFam += " SELECT C7_PRODUTO FROM " + RetSqlName("SC7") + " SC7 "
            If SCPCNF->ORIGEM == "NAC"
                cQryFam += " INNER JOIN " + RetSqlName("SB1") + " SB1 "
                cQryFam += "    ON SB1.D_E_L_E_T_ = '' "
                cQryFam += "    AND SB1.B1_XREVEND = 'S' "
                If cTabUso == "SC7"
                    cQryFam += " AND SB1.B1_COD = SC7.C7_PRODUTO "
                ElseIf cTabUso == "SC1"
                    cQryFam += " AND SB1.B1_COD = SC1.C1_PRODUTO "
                EndIf
            EndIf
            cQryFam += " WHERE SC7.C7_FILIAL = '"+SCPCNF->C7_FILIAL +"' "
            cQryFam += " AND SC7.C7_NUM = '"+SCPCNF->C7_PO_EIC+"' "
            cQryFam += " AND SC7.D_E_L_E_T_ = '') "
        ElseIf !Empty(SCPCNF->C7_NUM)
            cTabUso := "SC7"
            cQryFam += " SELECT C7_PRODUTO FROM " + RetSqlName("SC7") + " SC7 "
            If SCPCNF->ORIGEM == "NAC"
                cQryFam += " INNER JOIN " + RetSqlName("SB1") + " SB1 "
                cQryFam += "    ON SB1.D_E_L_E_T_ = '' "
                cQryFam += "    AND SB1.B1_XREVEND = 'S' "
                If cTabUso == "SC7"
                    cQryFam += " AND SB1.B1_COD = SC7.C7_PRODUTO "
                ElseIf cTabUso == "SC1"
                    cQryFam += " AND SB1.B1_COD = SC1.C1_PRODUTO "
                EndIf
            EndIf
            cQryFam += " WHERE SC7.C7_FILIAL = '"+SCPCNF->C7_FILIAL+"' "
            cQryFam += " AND SC7.C7_NUM = '"+SCPCNF->C7_NUM+"' "
            cQryFam += " AND SC7.D_E_L_E_T_ = '') "
        Else
            cTabUso := "SC1"
            cQryFam += " SELECT C1_PRODUTO FROM " + RetSqlName("SC1") + " SC1 "
            If SCPCNF->ORIGEM == "NAC"
                cQryFam += " INNER JOIN " + RetSqlName("SB1") + " SB1 "
                cQryFam += "    ON SB1.D_E_L_E_T_ = '' "
                cQryFam += "    AND SB1.B1_XREVEND = 'S' "
                If cTabUso == "SC7"
                    cQryFam += " AND SB1.B1_COD = SC7.C7_PRODUTO "
                ElseIf cTabUso == "SC1"
                    cQryFam += " AND SB1.B1_COD = SC1.C1_PRODUTO "
                EndIf
            EndIf
            cQryFam += " WHERE SC1.C1_FILIAL = '"+SCPCNF->C1_FILIAL+"' "
            cQryFam += " AND SC1.C1_NUM = '"+SCPCNF->C1_NUM+"' "
            cQryFam += " AND SC1.D_E_L_E_T_ = '') "
        EndIf
		cQryFam += " 					AND D_E_L_E_T_ = '') "
		cQryFam += " AND D_E_L_E_T_ = '' " 

		If Select("XLIN") > 0
			XLIN->(dbCloseArea())
		EndIf   

		DbUseArea(.T., "TOPCONN", TCGenQry(,,cQryFam) , 'XLIN', .T., .F.)

        cTpLinha := ""

		While XLIN->(!EOF())
			cTpLinha += Alltrim(XLIN->BM_DESC) + ", "
			XLIN->(dbSkip())
		EndDo

        cTpLinha := SubStr(Alltrim(cTpLinha), 1, Len(Alltrim(cTpLinha))-1)

        If MV_PAR19 == 1
            If SCPCNF->D1_FILIAL == "01"
                cTexFil := "GRU"
            ElseIF SCPCNF->D1_FILIAL == "02"
                cTexFil := "PARANA"
            ElseIF SCPCNF->D1_FILIAL == "03"
                cTexFil := "PARAISO"
            ElseIF SCPCNF->D1_FILIAL == "04"
                cTexFil := "RIO"
            ElseIF SCPCNF->D1_FILIAL == "05"
                cTexFil := "PERNANBUCO"
            ElseIF SCPCNF->D1_FILIAL == "06"
                cTexFil := "NAV"
            EndIF
            
            oSection:Cell("FILCD"):SetValue(cTexFil)
            oSection:Cell("NUMSC"):SetValue(SCPCNF->C7_NUMSC)
            oSection:Cell("NUMPC"):SetValue(SCPCNF->WN_PO_NUM)
            oSection:Cell("FORNE"):SetValue(ConsFor(SCPCNF->WN_FORNECE))
        Else
            If SCPCNF->C1_FILIAL == "01" .OR. SCPCNF->C7_FILIAL == "01"
                cTexFil := "GRU"
            ElseIF SCPCNF->C1_FILIAL == "02" .OR. SCPCNF->C7_FILIAL == "02"
                cTexFil := "PARANA"
            ElseIF SCPCNF->C1_FILIAL == "03" .OR. SCPCNF->C7_FILIAL == "03"
                cTexFil := "PARAISO"
            ElseIF SCPCNF->C1_FILIAL == "04" .OR. SCPCNF->C7_FILIAL == "04"
                cTexFil := "RIO"
            ElseIF SCPCNF->C1_FILIAL == "05" .OR. SCPCNF->C7_FILIAL == "05"
                cTexFil := "PERNANBUCO"
            ElseIF SCPCNF->C1_FILIAL == "06" .OR. SCPCNF->C7_FILIAL == "06"
                cTexFil := "NAV"
            EndIF
            oSection:Cell("FILCD"):SetValue(cTexFil)
            oSection:Cell("NUMSC"):SetValue(SCPCNF->C1_NUM)
            oSection:Cell("NUMPC"):SetValue(Iif(!Empty(SCPCNF->C7_PO_EIC),SCPCNF->C7_PO_EIC,SCPCNF->C7_NUM))
            oSection:Cell("FORNE"):SetValue(ConsFor(SCPCNF->C7_FORNECE))
        EndIf    
        
        oSection:Cell("ORIGEM"):SetValue(SCPCNF->ORIGEM)
        oSection:Cell("FAMILIA"):SetValue(cTpLinha)

        If !Empty(SCPCNF->C7_PO_EIC)
            cCondPG := GetAdvFVal("SW2","W2_COND_PA",xFilial("SW2")+SCPCNF->C7_PO_EIC,1)
            If !Empty(cCondPG)
                cCondPG := GetAdvFVal("SY6","Y6_DESC_P",xFilial("SY6")+cCondPG,1)
                cCondPG := GetAdvFVal("SYP","YP_TEXTO",xFilial("SYP")+cCondPG,1)
            Else
                cCondPG := "Nao localizado"
            EndIf
        ElseIf !Empty(SCPCNF->C7_NUM)
            cCondPG := GetAdvFVal("SC7","C7_COND",SCPCNF->C7_FILIAL+SCPCNF->C7_NUM,1)
            If !Empty(cCondPG)
                cCondPG := GetAdvFVal("SE4","E4_DESCRI",xFilial("SE4")+cCondPG,1)
            Else
                cCondPG := "Nao localizado"
            EndIf
        Else
            cCondPG := ""
        EndIf

        oSection:Cell("CONDPG"):SetValue(cCondPG)

        If !Empty(SCPCNF->W6_HAWB)
            oSection:Cell("NUMDESEMB"):SetValue(SCPCNF->W6_HAWB)
            cDesembVez := SCPCNF->W6_HAWB
        ElseIf !Empty(SCPCNF->C7_XHAWB)
            oSection:Cell("NUMDESEMB"):SetValue(SCPCNF->C7_XHAWB)
            cDesembVez := SCPCNF->C7_XHAWB
        Else
            oSection:Cell("NUMDESEMB"):SetValue(SCPCNF->WN_HAWB)
            cDesembVez := SCPCNF->WN_HAWB
        EndIf

        oSection:Cell("NUMNF"):SetValue(SCPCNF->WN_DOC)
        
        aResDatas:= ConsEtdEta(cDesembVez)
        
        SCR->(DbSetOrder(1))

        //NIVEL 1        
        If MV_PAR19 == 1
            SCR->(DbSeek(SCPCNF->D1_FILIAL + "PC" + PADR(SCPCNF->WN_PO_NUM,TAMSX3("CR_NUM")[1])+"01") )
        Else
            If !Empty(SCPCNF->C7_NUM)
                SCR->(DbSeek(SCPCNF->C7_FILIAL + "PC" + PADR(SCPCNF->C7_NUM,TAMSX3("CR_NUM")[1])+"01") )
            Else
                SCR->(DbSeek(SCPCNF->C1_FILIAL + "PC" + PADR(SCPCNF->C7_PO_EIC,TAMSX3("CR_NUM")[1])+"01") )
            EndIf
        EndIf

        If MV_PAR19 == 1
            While SCR->CR_FILIAL == SCPCNF->D1_FILIAL .And. AllTrim(SCR->CR_NUM) == AllTrim(SCPCNF->WN_PO_NUM) .And. SCR->CR_TIPO == "PC" .And. SCR->CR_NIVEL == "01"
                If Empty(SCR->CR_DATALIB)
                    SCR->(DbSkip())
                Else
                    dDtLib1	  := SCR->CR_DATALIB
                    Exit
                EndIf
            End
        Else
            If !Empty(SCPCNF->C7_NUM)
                While SCR->CR_FILIAL == SCPCNF->C7_FILIAL .And. AllTrim(SCR->CR_NUM) == AllTrim(SCPCNF->C7_NUM) .And. SCR->CR_TIPO == "PC" .And. SCR->CR_NIVEL == "01"
                    If Empty(SCR->CR_DATALIB)
                        SCR->(DbSkip())
                    Else
                        dDtLib1	  := SCR->CR_DATALIB
                        Exit
                    EndIf
                End
            Else
                While SCR->CR_FILIAL == SCPCNF->C1_FILIAL .And. AllTrim(SCR->CR_NUM) == AllTrim(SCPCNF->C7_PO_EIC) .And. SCR->CR_TIPO == "PC" .And. SCR->CR_NIVEL == "01"
                    If Empty(SCR->CR_DATALIB)
                        SCR->(DbSkip())
                    Else
                        dDtLib1	  := SCR->CR_DATALIB
                        Exit
                    EndIf
                End
            EndIf
        EndIf

        //NIVEL 2
        If MV_PAR19 == 1
            SCR->(DbSeek(SCPCNF->D1_FILIAL + "PC" + PADR(SCPCNF->WN_PO_NUM,TAMSX3("CR_NUM")[1])+"02") )
        Else
             If !Empty(SCPCNF->C7_NUM)
                SCR->(DbSeek(SCPCNF->C7_FILIAL + "PC" + PADR(SCPCNF->C7_NUM,TAMSX3("CR_NUM")[1])+"02") )
            Else
                SCR->(DbSeek(SCPCNF->C1_FILIAL + "PC" + PADR(SCPCNF->C7_PO_EIC,TAMSX3("CR_NUM")[1])+"02") )
            EndIf
        EndIf

        If MV_PAR19 == 1
            While SCR->CR_FILIAL == SCPCNF->D1_FILIAL .And. AllTrim(SCR->CR_NUM) == AllTrim(SCPCNF->WN_PO_NUM) .And. SCR->CR_TIPO == "PC" .And. SCR->CR_NIVEL == "02"
                If Empty(SCR->CR_DATALIB)
                    SCR->(DbSkip())
                Else
                    dDtLib2	  := SCR->CR_DATALIB
                    Exit
                EndIf
            End
        Else
            If !Empty(SCPCNF->C7_NUM)
                While SCR->CR_FILIAL == SCPCNF->C7_FILIAL .And. AllTrim(SCR->CR_NUM) == AllTrim(SCPCNF->C7_NUM) .And. SCR->CR_TIPO == "PC" .And. SCR->CR_NIVEL == "02"
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
        EndIf

        If AllTrim(nDesemb) <> AllTrim(cDesembVez) .or. len(Alltrim(nDesemb)) <> len(AllTrim(cDesembVez))
            dDtDesemb 	:= SToD(W6DATE(cDesembVez))
            nwDesemb	:= W6DATE(cDesembVez,SCPCNF->D1_EMISSAO)
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
            Wdt_FIMP	:= Stod(aResDatas[1][10])
            Wdt_PSII	:= Stod(aResDatas[1][11])
        EndIf

        dt_Sin  := ConsSin(AllTrim(cDesembVez))
        If MV_PAR19 == 2 .OR. MV_PAR19 == 3
            dt_EmSC   := GetAdvFVal("SC1","C1_EMISSAO",SCPCNF->C1_FILIAL+SCPCNF->C1_NUM,1)
            dt_LimPrd := GetAdvFVal("SC1","C1_XDTLPRD",SCPCNF->C1_FILIAL+SCPCNF->C1_NUM,1)
        Else
            dt_EmSC   := GetAdvFVal("SC1","C1_EMISSAO",SCPCNF->C7_FILIAL+SCPCNF->C7_NUMSC,1)
            dt_LimPrd := GetAdvFVal("SC1","C1_XDTLPRD",SCPCNF->C7_FILIAL+SCPCNF->C7_NUMSC,1)
        EndIf

        aDataNew := BusNewDt()
        
        If MV_PAR20 == 2
            oSection:Cell("DTEMSC"):SetValue(SubStr(Dtos(dt_EmSC),7,2) + "/" + SubStr(Dtos(dt_EmSC),5,2) + "/" + SubStr(Dtos(dt_EmSC),3,2) )
            oSection:Cell("DTAPRSC"):SetValue(STOD(aDataNew[1][2]))
            oSection:Cell("DTENVAR"):SetValue(STOD(aDataNew[1][5]))
            oSection:Cell("DTAPRAR"):SetValue(STOD(aDataNew[1][6]))
            oSection:Cell("DTEMIPO"):SetValue(STOD(aDataNew[1][1]))
            oSection:Cell("DTLIMSC"):SetValue(STOD(aDataNew[1][4]))
            oSection:Cell("DTLIB01"):SetValue(SubStr(Dtos(dDtLib1),7,2) + "/" + SubStr(Dtos(dDtLib1),5,2) + "/" + SubStr(Dtos(dDtLib1),3,2) )
            oSection:Cell("DTLIB02"):SetValue(SubStr(Dtos(dDtLib2),7,2) + "/" + SubStr(Dtos(dDtLib2),5,2) + "/" + SubStr(Dtos(dDtLib2),3,2) )
            oSection:Cell("DTSINAL"):SetValue(SubStr(Dtos(dt_Sin),7,2) + "/" + SubStr(Dtos(dt_Sin),5,2) + "/" + SubStr(Dtos(dt_Sin),3,2) )
            oSection:Cell("PSIINI"):SetValue(SubStr(Dtos(Wdt_PSII),7,2) + "/" + SubStr(Dtos(Wdt_PSII),5,2) + "/" + SubStr(Dtos(Wdt_PSII),3,2) )   
            oSection:Cell("PSIREAL"):SetValue(SubStr(Dtos(Wdt_PSIR),7,2) + "/" + SubStr(Dtos(Wdt_PSIR),5,2) + "/" + SubStr(Dtos(Wdt_PSIR),3,2) )   
            oSection:Cell("DTFIMPRD"):SetValue(SubStr(Dtos(Wdt_FIMP),7,2) + "/" + SubStr(Dtos(Wdt_FIMP),5,2) + "/" + SubStr(Dtos(Wdt_FIMP),3,2) )   
            oSection:Cell("DTLIMPRD"):SetValue(SubStr(Dtos(dt_LimPrd),7,2) + "/" + SubStr(Dtos(dt_LimPrd),5,2) + "/" + SubStr(Dtos(dt_LimPrd),3,2) )   
            oSection:Cell("PSIAPR"):SetValue(SubStr(Dtos(Wdt_PSIA),7,2) + "/" + SubStr(Dtos(Wdt_PSIA),5,2) + "/" + SubStr(Dtos(Wdt_PSIA),3,2) )
            oSection:Cell("DTEMBAR"):SetValue(SubStr(Dtos(Wdt_Emb),7,2) + "/" + SubStr(Dtos(Wdt_Emb),5,2) + "/" + SubStr(Dtos(Wdt_Emb),3,2) )
            oSection:Cell("DTPORTO"):SetValue(SubStr(Dtos(Wdt_Porto),7,2) + "/" + SubStr(Dtos(Wdt_Porto),5,2) + "/" + SubStr(Dtos(Wdt_Porto),3,2) )
            oSection:Cell("DTDESEMB"):SetValue(SubStr(Dtos(dDtDesemb),7,2) + "/" + SubStr(Dtos(dDtDesemb),5,2) + "/" + SubStr(Dtos(dDtDesemb),3,2) )
            oSection:Cell("DTEMINF"):SetValue(Substr(SCPCNF->D1_EMISSAO,7,2) + "/" + Substr(SCPCNF->D1_EMISSAO,5,2) + "/" + Substr(SCPCNF->D1_EMISSAO,3,2)) 
            oSection:Cell("DTENTSC"):SetValue(STOD(aDataNew[1][3]))
        EndIf

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
    
        IF !Empty(dDtLib2) .AND. !Empty(dt_Sin)
            If dt_Sin < dDtLib2
                nN2xSIN := (DateDiffDay(dDtLib2,dt_Sin) * -1)
            else
                nN2xSIN := DateDiffDay(dDtLib2,dt_Sin)
            EndIf
        EndIf

        IF !Empty(dt_Sin) .AND. !Empty(Wdt_PSIR)
            If dt_Sin > Wdt_PSIR
                nSINxPSR := (DateDiffDay(dt_Sin,Wdt_PSIR) * -1)
            else
                nSINxPSR := DateDiffDay(dt_Sin,Wdt_PSIR)
            EndIf
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


        oSection:Cell("N2SINAL"):SetValue(nN2xSIN)
        oSection:Cell("SINPSIR"):SetValue(nSINxPSR)
        oSection:Cell("PSIRPSIA"):SetValue(nPSRxPSA)
        oSection:Cell("PSIAEMB"):SetValue(nPSAxEMB)
        oSection:Cell("MAR"):SetValue(nEMBxPOR)
        oSection:Cell("DESEMB"):SetValue(nPORxNF)

        IF !Empty(dt_EmSC)
            If !Empty(SCPCNF->D1_EMISSAO)
                nSCxNF := DateDiffDay(dt_EmSC,STOD(SCPCNF->D1_EMISSAO))
            Else
                nSCxNF := 0
            EndIf
        EndIf'

        aRetW2	:= W2LEAD(SCPCNF->WN_PO_NUM,dDtLib2)
        
		nLeadPre := aRetW2[1]
		cPorto	 := Alltrim(aRetW2[2])

        If MV_PAR19 == 1
            n1Compra := Busca1C(SCPCNF->WN_PO_NUM) 
        Else
            n1Compra := Busca1C(SCPCNF->C7_PO_EIC)
        EndIf

        If !Empty(aDataNew[1][3]) .AND. !Empty(aDataNew[1][4])
            nLeadPre := (STOD(aDataNew[1][3]) - (STOD(aDataNew[1][4]) - 5))
        else
            nLeadPre := 0
        EndIf

        oSection:Cell("1COMPRA"):SetValue(Iif(n1Compra == 0,"N","S"))
		oSection:Cell("PORDEST"):SetValue(cPorto)
        oSection:Cell("PREVISTO"):SetValue(nLeadPre)
        oSection:Cell("REALIZADO"):SetValue(nN2xNF)
        oSection:Cell("DIFERENCA"):SetValue(nN2xNF - nLeadPre)
        oSection:Cell("SCNF"):SetValue(nSCxNF)
        
        IF !Empty(dt_EmSC) .and. !Empty(aDataNew[1][2])
            If dt_EmSC > STOD(aDataNew[1][2])
                oSection:Cell("EMSCAPSC"):SetValue(DateDiffDay(dt_EmSC,STOD(aDataNew[1][2])) * -1)
            Else
                oSection:Cell("EMSCAPSC"):SetValue(DateDiffDay(dt_EmSC,STOD(aDataNew[1][2])))
            EndIf
        Else
            oSection:Cell("EMSCAPSC"):SetValue(0)
        EndIf

        IF !Empty(aDataNew[1][1]) .and. !Empty(aDataNew[1][2])
            If STOD(aDataNew[1][2]) > STOD(aDataNew[1][1])
                oSection:Cell("EMPCAPSC"):SetValue(DateDiffDay(STOD(aDataNew[1][2]),STOD(aDataNew[1][1])) * -1)
            Else
                oSection:Cell("EMPCAPSC"):SetValue(DateDiffDay(STOD(aDataNew[1][2]),STOD(aDataNew[1][1])))
            EndIF
        Else
            oSection:Cell("EMPCAPSC"):SetValue(0)
        EndIf
        
        If !Empty(aDataNew[1][3]) .AND. !Empty(wdt_NF)
            If wdt_NF > STOD(aDataNew[1][3])
                oSection:Cell("METAXNF"):SetValue(DateDiffDay(STOD(aDatanew[1][3]),wdt_NF) * -1)
            else
                oSection:Cell("METAXNF"):SetValue(DateDiffDay(STOD(aDatanew[1][3]),wdt_NF))
            EndIf
        else
            oSection:Cell("METAXNF"):SetValue(0)
        EndIf

        If !Empty(aDataNew[1][6]) .AND. !Empty(aDataNew[1][1])
            If STOD(aDatanew[1][6]) > STOD(aDatanew[1][1])
                oSection:Cell("ARTEMPC"):SetValue(DateDiffDay(STOD(aDatanew[1][1]),STOD(aDatanew[1][6])) * -1)
            Else
                oSection:Cell("ARTEMPC"):SetValue(DateDiffDay(STOD(aDatanew[1][1]),STOD(aDatanew[1][6])))
            EndIf
        else
             oSection:Cell("ARTEMPC"):SetValue(0)
        EndIf

        If !Empty(aDataNew[1][5]) .AND. !Empty(aDataNew[1][6])
            If STOD(aDatanew[1][5]) > STOD(aDatanew[1][6])
                oSection:Cell("ENVXAPR"):SetValue(DateDiffDay(STOD(aDatanew[1][5]),STOD(aDatanew[1][6])) * -1)
            Else
                oSection:Cell("ENVXAPR"):SetValue(DateDiffDay(STOD(aDatanew[1][5]),STOD(aDatanew[1][6])))
            EndIf
        else
             oSection:Cell("ENVXAPR"):SetValue(0)
        EndIf


        If !Empty(aDataNew[1][1]) .AND. !Empty(aDataNew[1][4])
            If STOD(aDatanew[1][4]) > STOD(aDatanew[1][1])
                oSection:Cell("PCXLIM"):SetValue(DateDiffDay(STOD(aDatanew[1][1]),STOD(aDatanew[1][4])) * -1)
            Else
                oSection:Cell("PCXLIM"):SetValue(DateDiffDay(STOD(aDatanew[1][1]),STOD(aDatanew[1][4])))
            EndIf
        else
            oSection:Cell("PCXLIM"):SetValue(0)
        EndIf
	
        If !Empty(aDataNew[1][1]) .AND. !Empty(dDtLib1)
            If dDtLib1 > STOD(aDataNew[1][1])
                oSection:Cell("PCN1"):SetValue(DateDiffDay(STOD(aDatanew[1][1]),dDtLib1) *-1)
            else
                oSection:Cell("PCN1"):SetValue(DateDiffDay(STOD(aDatanew[1][1]),dDtLib1))
            EndIf
        else
            oSection:Cell("PCN1"):SetValue(0)
        EndIf
        
        If !Empty(dDtLib1) .AND. !Empty(dDtLib2)
            If dDtLib1 > dDtLib2
                oSection:Cell("N1N2"):SetValue(DateDiffDay(dDtLib1,dDtLib2) * -1)
            Else
                oSection:Cell("N1N2"):SetValue(DateDiffDay(dDtLib1,dDtLib2))
            EndIF
        else
            oSection:Cell("N1N2"):SetValue(0)
        EndIf

 	    If !Empty(dt_Sin) .AND. !Empty(Wdt_FIMP)
            If dt_Sin > Wdt_FIMP
                oSection:Cell("SINXPSIF"):SetValue(DateDiffDay(dt_Sin,Wdt_FIMP) * -1)
            Else
                oSection:Cell("SINXPSIF"):SetValue(DateDiffDay(dt_Sin,Wdt_FIMP))
            EndIf
        else
            oSection:Cell("SINXPSIF"):SetValue(0)
        EndIf

        If !Empty(dt_LimPrd) .AND. !Empty(Wdt_FIMP)
            If dt_LimPrd > Wdt_FIMP
                oSection:Cell("LIPXFIMP"):SetValue(DateDiffDay(Wdt_FIMP,dt_LimPrd) * -1)
            Else
                oSection:Cell("LIPXFIMP"):SetValue(DateDiffDay(Wdt_FIMP,dt_LimPrd))
            EndIf
        else
            oSection:Cell("LIPXFIMP"):SetValue(0)
        EndIf

        If !Empty(Wdt_PSII) .AND. !Empty(Wdt_FIMP)
            If Wdt_FIMP > Wdt_PSII
                oSection:Cell("FIMPPSII"):SetValue(DateDiffDay(Wdt_PSII,Wdt_FIMP) * -1)
            Else
                oSection:Cell("FIMPPSII"):SetValue(DateDiffDay(Wdt_PSII,Wdt_FIMP))
            EndIf
        else
            oSection:Cell("FIMPPSII"):SetValue(0)
        EndIf

        If !Empty(Wdt_PSII) .AND. !Empty(Wdt_PSIR)
            If Wdt_PSII > Wdt_PSIR
                oSection:Cell("PSIXPSF"):SetValue(DateDiffDay(Wdt_PSII,Wdt_PSIR) * -1)
            Else
                oSection:Cell("PSIXPSF"):SetValue(DateDiffDay(Wdt_PSII,Wdt_PSIR))
            EndIf
        else
            oSection:Cell("PSIXPSF"):SetValue(0)
        EndIf

        nTotProc++

        If (nN2xNF - nLeadPre) > 0
            nForMet++
        Else
            nDenMet++
        EndIf
        
        nN2xNF      := 0            
        nN2xSIN     := 0
        nSINxPSR    := 0
        nPSRxPSA    := 0
        nPSAxEMB    := 0
        nSCxNF      := 0
        n1Compra    := 0
        nEMBxPOR    := 0
        nPORxNF     := 0
        dDtLib1     := CTOD("  /  /  ")
        dDtLib2     := CTOD("  /  /  ")

        nDesemb:= cDesembVez

        oSection:PrintLine()
            
        SCPCNF->(dbSkip())
    EndDo

    oSection:Finish()

    SCPCNF->(DbCloseArea())

Return (Nil)
/*----------------------------------------------------------|
| Autor | Rodrigo Dias Nunes              | Data 19/01/2021	| 
|-----------------------------------------------------------|
| Funcao: BusNewDt									     	|
|-----------------------------------------------------------|
| Relatorio Lead Time Import.         	                    |
------------------------------------------------------------*/

Static Function BusNewDt()
    Local nOpQry    := 0
    Local aResult	:= {}
    Local cQuery  	:= ""
    Local cQry  	:= ""
    
    If Empty(SCPCNF->C7_PO_EIC)
        nOpQry := 1
	    cQuery := " SELECT TOP(1) C1_XDTLIB, C1_DATPRF, C1_XDTPROG "
	    cQuery += " FROM " + RetSqlName("SC1")
	    cQuery += " WHERE C1_FILIAL = '"+SCPCNF->C1_FILIAL+"' "
	    cQuery += " AND C1_NUM = '"+SCPCNF->C1_NUM+"' "
	    cQuery += " AND D_E_L_E_T_ = '' "
    Else
        nOpQry := 2
	    cQry := " SELECT TOP(1) C1_XDTLIB, C1_DATPRF, C1_XDTPROG "
	    cQry += " FROM " + RetSqlName("SC1")
	    cQry += " WHERE C1_FILIAL = '"+SCPCNF->C1_FILIAL+"' "
	    cQry += " AND C1_NUM = '"+SCPCNF->C1_NUM+"' "
	    cQry += " AND D_E_L_E_T_ = '' "

        cQuery := " SELECT W2_PO_DT, W2_XENVART, W2_XAPRART FROM " + RetSqlName("SW2")
        cQuery += " WHERE W2_PO_NUM = '"+Alltrim(SCPCNF->C7_PO_EIC)+"' "
        cQuery += " AND W2_FORN = '"+SCPCNF->C7_FORNECE+"' "
        cQuery += " AND D_E_L_E_T_ = '' "
    EndIf

    If nOpQry == 1
        If Select("C1DT") > 0
            C1DT->(dbCloseArea())
        EndIF
        
        DbUseArea( .T.,"TOPCONN",TCGENQRY(,,cQuery),"C1DT",.F.,.T. )
    ElseIf nOpQry == 2
        If Select("C1DT") > 0
            C1DT->(dbCloseArea())
        EndIF
        
        DbUseArea( .T.,"TOPCONN",TCGENQRY(,,cQry),"C1DT",.F.,.T. )

        If Select("W2DT") > 0
            W2DT->(dbCloseArea())
        EndIF
        
        DbUseArea( .T.,"TOPCONN",TCGENQRY(,,cQuery),"W2DT",.F.,.T. )
    EndIF
    
    If nOpQry == 1
        aAdd(aResult,{"", C1DT->C1_XDTLIB, C1DT->C1_DATPRF, C1DT->C1_XDTPROG, "", ""})
    ElseIf nOpQry == 2
        aAdd(aResult,{W2DT->W2_PO_DT, C1DT->C1_XDTLIB, C1DT->C1_DATPRF, C1DT->C1_XDTPROG, W2DT->W2_XENVART, W2DT->W2_XAPRART})
    EndIf

Return aResult

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
    cQuery += " SW6.W6_DT_EMB, SW6.W6_CHEG, SW6.W6_XPSIR, SW6.W6_XPSIA, SW6.W6_XFIMPRD, SW6.W6_XPSIINI "
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
	
	aAdd(aResult,{ AllTrim(cValToChar(cResult)),; 
                    (cAliasQry)->ETD, ;
                    (cAliasQry)->W6_DT_NF, ;
                    (cAliasQry)->W6_XENTINI,; 
                    (cAliasQry)->W6_PRVENTR, ;
                    (cAliasQry)->W6_DT_EMB, ;
                    (cAliasQry)->W6_CHEG, ;
                    (cAliasQry)->W6_XPSIR, ;
                    (cAliasQry)->W6_XPSIA, ;
                    (cAliasQry)->W6_XFIMPRD,; 
                    (cAliasQry)->W6_XPSIINI})

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
Static Function W2LEAD(nPonum,dtLibN2)
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
			dTemp := dtLibN2 + nDiaSSZ
			nDias := dTemp - dtLibN2
			cPorto := Alltrim(SW2LEAD->W2_DEST)
		ElseIf SW2LEAD->W2_DEST == "ITJ"
			dTemp := dtLibN2 + nDiaITJ
			nDias := dTemp - dtLibN2
			cPorto := Alltrim(SW2LEAD->W2_DEST)
		ElseIf SW2LEAD->W2_DEST == "NAV"
			dTemp := dtLibN2 + nDiaNAV
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
