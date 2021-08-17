#Include "Protheus.ch"
#Include "TOTVS.CH"
#Include "TOPCONN.CH"
#INCLUDE "RWMAKE.CH"
#Include "TbiConn.ch"

//--------------------------------------------------------------------
/*/{Protheus.doc} CAPAEIC
Rotina de impressão do EIC
@author Rodrigo Nunes
@since 30/09/2020
@version 1.0 
@type function
/*/
//--------------------------------------------------------------------
User function CAPAEIC()
	Local nOpca	        := 0
    Local aSays         := {} 
    Local aButtons      := {}
    Private cCadastro   := OemToAnsi("Capa de Importação")
    Private aParam		:= {}
    Private cCaminho 	:= ""

    AADD (aSays, OemToAnsi(" Este programa tem como objetivo emitir a "))
    AADD (aSays, OemToAnsi(" Capa de Importação por processo"))
    AADD (aSays, OemToAnsi(" "))

    AADD(aButtons, { 1,.T.,{|o| nOpca:= 1,o:oWnd:End()}} )
    AADD(aButtons, { 2,.T.,{|o| o:oWnd:End() }} )
    FormBatch( cCadastro, aSays, aButtons )

    If nOpcA == 1
        PergPara()
        If !Empty(aParam)
            Processa({|lEnd| Gerar()},"Preparando Capa de Importação...")
        EndIf
    Endif

Return

//--------------------------------------------------------------------
/*/{Protheus.doc} CAPAEIC
Rotina de impressão do EIC
@author Rodrigo Nunes
@since 30/09/2020
@version 1.0 
@type function
/*/
//--------------------------------------------------------------------
Static function Gerar()
	local oProcess		:= Nil
	local cMailID		:= ""
	Local cQuery		:= ""
	Local aArea			:= GetArea()
	Local lTemLI        := .F.
    Local cContr        := ""
	Local nlX           := 0
    Local cNomeDes      := ""
    Local cNomeOrg      := ""
    Local cNomeFor      := ""
    Local nValMes       := 0
    Local cFamilia      := ""
    Local cNCM          := ""
    Local cNovoArq      := ""
    Local cTipo         := ""
    Local cPerc         := ""
    Local cDesLI        := "L"
    Local cDesDI        := "D"
    Local cDesPos       := "P"
    Local cDesRec       := "R"
    Local cDataVct      := ""
    Local lTemDI        := .F.
    Local lTemPos       := .F.
    Local dLIBaixa      := ""
    Local dDIBaixa      := ""
    Local dPosBaixa     := ""
    Local cDesCTE       := SuperGetMV("ES_DESCTE",.F.,"437")
    Local cDesNPed      := SuperGetMV("ES_NGERFRE",.F.,"")
    Local dVencCTE      := ""
    Local dBxCTE        := ""
    Local nValCTE       := 0
    Local nTotMoe       := 0
    Local nTotCon       := 0
    Local cAuxMoe       := ""
    Local nTaxaFr       := 0
    	
    cQuery := " SELECT * FROM " + RetSqlName("SW6")
    cQuery += " WHERE W6_FILIAL = '"+xFilial("SW6")+"' "
    cQuery += " AND W6_HAWB = '"+Alltrim(aParam[1])+"' "
    cQuery += " AND D_E_L_E_T_ = '' "

    If Select("W6X") > 0
        W6X->(dbCloseArea())
    EndIf

    DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery) , 'W6X', .T., .F.)

    If W6X->(!EOF())
        cQuery := " SELECT * FROM " + RetSqlName("SW2")
        cQuery += " WHERE W2_FILIAL = '"+xFilial("SW2")+"' "
        cQuery += " AND W2_PO_NUM = '"+W6X->W6_PO_NUM+"' "
        cQuery += " AND D_E_L_E_T_ = '' "

        If Select("W2X") > 0
            W2X->(dbCloseArea())
        EndIf

        DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery) , 'W2X', .T., .F.)

        If W2X->(!EOF())
            cQuery := " SELECT * FROM " + RetSqlName("SW3")
            cQuery += " WHERE W3_FILIAL = '"+xFilial("SW3")+"' "
            cQuery += " AND W3_PO_NUM = '"+W6X->W6_PO_NUM+"' "
            cQuery += " AND D_E_L_E_T_ = '' "

            If Select("W3X") > 0
                W3X->(dbCloseArea())
            EndIf

            DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery) , 'W3X', .T., .F.)

            If W3X->(!EOF())
                cQuery := " SELECT * FROM " + RetSqlName("SW0")
                cQuery += " WHERE W0_FILIAL = '"+xFilial("SW0")+"' "
                cQuery += " AND W0__NUM = '"+W3X->W3_SI_NUM+"' "
                cQuery += " AND D_E_L_E_T_ = '' "

                If Select("W0X") > 0
                    W0X->(dbCloseArea())
                EndIf

                DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery) , 'W0X', .T., .F.)

                If W0X->(!EOF())
                    cQuery := " SELECT * FROM " + RetSqlName("SWD")
                    cQuery += " WHERE WD_FILIAL = '"+xFilial("SWD")+"' "
                    cQuery += " AND WD_HAWB = '"+W6X->W6_HAWB+"' "
                    cQuery += " AND WD_DESPESA = '422' "
                    cQuery += " AND D_E_L_E_T_ = '' "

                    If Select("WDX") > 0
                        WDX->(dbCloseArea())
                    EndIf

                    DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery) , 'WDX', .T., .F.)

                    If WDX->(!EOF())
                        lTemLI := .T.
                    EndIf

                    cQuery := " SELECT DISTINCT(CR_NIVEL+'-'+AK_NOME) AS APROVADOR "
                    cQuery += " FROM "
                    cQuery += " ( "
                    cQuery += " 	SELECT * FROM " + RetSqlName("SC7")
                    cQuery += " 	WHERE C7_NUMSC = '"+W0X->W0_C1_NUM+"' "
                    cQuery += " 	AND C7_FILIAL = '"+GetAdvFVal("SYT","YT_X_FILIA",XFILIAL("SYT")+W6X->W6_IMPORT,1)+"' "
                    cQuery += " 	AND D_E_L_E_T_ = '' "
                    cQuery += " ) SC7 "
                    cQuery += " INNER JOIN " + RetSqlName("SCR") + " SCR "
                    cQuery += "     ON SCR.CR_NUM = SC7.C7_NUM "
                    cQuery += "     AND SCR.CR_FILIAL = SC7.C7_FILIAL "
                    cQuery += "     AND SCR.CR_LIBAPRO <> '' "
                    cQuery += "     AND SCR.D_E_L_E_T_ = '' "
                    cQuery += " INNER JOIN " + RetSqlName("SAK") + " SAK "
                    cQuery += "     ON SAK.AK_USER = SCR.CR_USER "
                    cQuery += "     AND SAK.D_E_L_E_T_ = '' "
                    
                    If Select("CRX") > 0
                        CRX->(dbCloseArea())
                    EndIf

                    DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery) , 'CRX', .T., .F.)

                    cQuery := " SELECT * FROM " + RetSqlName("SWD")
                    cQuery += " WHERE WD_FILIAL = '"+xFilial("SWD")+"' "
                    cQuery += " AND WD_HAWB = '"+W6X->W6_HAWB+"' "
                    cQuery += " AND D_E_L_E_T_ = '' "
                    cQuery += " ORDER BY WD_DESPESA "

                    If Select("WDX2") > 0
                        WDX2->(dbCloseArea())
                    EndIf

                    DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery) , 'WDX2', .T., .F.)

                    cQuery := " SELECT * FROM " + RetSqlName("SWB")
                    cQuery += " WHERE WB_FILIAL = '"+xFilial("SWB")+"' "
                    cQuery += " AND WB_HAWB = '"+W6X->W6_HAWB+"' "
                    cQuery += " AND WB_DT_CONT <> '' "
                    cQuery += " AND D_E_L_E_T_ = '' "
                    
                    If Select("WBX") > 0
                        WBX->(dbCloseArea())
                    EndIf
                    
                    DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery) , 'WBX', .T., .F.)

                    If WBX->(!EOF())
                        cQuery := " SELECT 	Y6_PERC_01, " 
                        cQuery += " 		Y6_PERC_02, "
                        cQuery += " 		Y6_PERC_03, "
                        cQuery += " 		Y6_PERC_04, "
                        cQuery += " 		Y6_PERC_05, "
                        cQuery += " 		Y6_PERC_06, "
                        cQuery += " 		Y6_PERC_07, "
                        cQuery += " 		Y6_PERC_08, "
                        cQuery += " 		Y6_PERC_09, "
                        cQuery += " 		Y6_PERC_10 "
                        cQuery += " FROM( "
                        cQuery += " 	SELECT * FROM " + RetSqlName("SW6")
                        cQuery += " 	WHERE W6_FILIAL = '"+xFilial("SW6")+"' "
                        cQuery += " 	AND W6_HAWB = '"+W6X->W6_HAWB+"' "
                        cQuery += " 	AND D_E_L_E_T_ = '' "
                        cQuery += " ) SW6 "
                        cQuery += " INNER JOIN " + RetSqlName("SW2") + " SW2 "
                        cQuery += " 	ON SW6.W6_PO_NUM = SW2.W2_PO_NUM "
                        cQuery += " 	AND SW6.W6_FILIAL = SW2.W2_FILIAL "
                        cQuery += " 	AND SW6.D_E_L_E_T_ = '' "
                        cQuery += " INNER JOIN " + RetSqlName("SY6") + " SY6 "
                        cQuery += " 	ON SY6.Y6_COD = SW2.W2_COND_PA "
                        cQuery += " 	AND SY6.D_E_L_E_T_ = '' " 

                        If Select("Y6X") > 0
                            Y6X->(dbCloseArea())
                        EndIf
                        
                        DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery) , 'Y6X', .T., .F.)
                    EndIf

                    cQuery := " SELECT B1_GRUPO, BM_DESC, B1_POSIPI "
                    cQuery += " FROM "
                    cQuery += " ( "
                    cQuery += " 	SELECT * FROM " + RetSqlName("SC7") 
                    cQuery += " 	WHERE C7_NUMSC = '"+W0X->W0_C1_NUM+"' "
                    cQuery += " 	AND C7_FILIAL = '"+GetAdvFVal("SYT","YT_X_FILIA",XFILIAL("SYT")+W6X->W6_IMPORT,1)+"' "
                    cQuery += " 	AND D_E_L_E_T_ = '' "
                    cQuery += " ) SC7 "
                    cQuery += " INNER JOIN " +RetSqlName("SB1")+ " SB1 "
                    cQuery += " 	ON SB1.B1_COD = SC7.C7_PRODUTO "
                    cQuery += " 	AND SB1.D_E_L_E_T_ = '' "
                    cQuery += " INNER JOIN " + RetSqlName("SBM") + " SBM "
                    cQuery += "     ON SBM.BM_GRUPO = SB1.B1_GRUPO "
                    cQuery += "     AND SBM.D_E_L_E_T_ = '' "

                    If Select("PRX") > 0
                        PRX->(dbCloseArea())
                    EndIf

                    DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery) , 'PRX', .T., .F.)

                    While PRX->(!EOF())
                        If !(Alltrim(PRX->BM_DESC) $ cFamilia)
                            cFamilia += Alltrim(PRX->BM_DESC) + "/"
                        EndIf
                        If !(Alltrim(PRX->B1_POSIPI) $ cNCM)
                            cNCM += Alltrim(PRX->B1_POSIPI) + "/"
                        EndIf
                        PRX->(dbSkip())
                    EndDo

                    If !Empty(cFamilia)
                        cFamilia := Alltrim(cFamilia) 
                        cFamilia := SubStr(cFamilia,1,len(cFamilia)-1)
                    EndIf
                    If !Empty(cNCM)
                        cNCM := Alltrim(cNCM) 
                        cNCM := SubStr(cNCM,1,len(cNCM)-1)
                    EndIf

                    If aParam[3] == 3
                        cQuery := " SELECT TOP("+cValToChar(aParam[5])+") * FROM " + RetSqlName("SWO")
                    Else
                        cQuery := " SELECT * FROM " + RetSqlName("SWO")
                    EndIf
                    cQuery += " WHERE WO_FILIAL = '"+xFilial("SWO")+"' "
                    cQuery += " AND WO_PO_NUM = '"+W6X->W6_PO_NUM+"' "
                    If aParam[3] == 1
                        cQuery += " AND WO_MANUAL  = 'S' "
                    EndIf
                    cQuery += " AND D_E_L_E_T_ = '' "

                    If Select("WOX") > 0
                        WOX->(dbCloseArea())
                    EndIf

                    DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery) , 'WOX', .T., .F.)
                Else
                    Alert("SI " + Alltrim(W3X->W3_SI_NUM) + " não encontrada." + CRLF+CRLF+ "Fonte: CAPAEIC" +CRLF+ "Query: W0X")
                    Return
                EndIf
            Else
                Alert("Itens do PO " + Alltrim(W6X->W6_PO_NUM) + " não encontrado." + CRLF+CRLF+ "Fonte: CAPAEIC" +CRLF+ "Query: W3X")
                Return
            EndIf
        Else
            Alert("PO " + Alltrim(W6X->W6_PO_NUM) + " não encontrado." + CRLF+CRLF+ "Fonte: CAPAEIC" +CRLF+ "Query: W2X")
            Return
        EndIf
    Else
        Alert("Processo " + Alltrim(aParam[1]) + " não encontrado." + CRLF+CRLF+ "Fonte: CAPAEIC" +CRLF+ "Query: W6X")
        Return
    EndIf

    If Select("W6X") <= 0
        Alert("Processo " + Alltrim(aParam[1]) + " não encontrado." + CRLF+CRLF+ "Fonte: CAPAEIC" +CRLF+ "Query: W6X")
        Return
    EndIf
    If Select("W0X") <= 0
        Alert("SI do processo " + Alltrim(aParam[1]) + " não encontrada." + CRLF+CRLF+ "Fonte: CAPAEIC" +CRLF+ "Query: W0X")
        Return
    EndIf
    If Select("W3X") <= 0
        Alert("Itens do PO do processo " + Alltrim(aParam[1]) + " não encontrado." + CRLF+CRLF+ "Fonte: CAPAEIC" +CRLF+ "Query: W3X")
        Return
    EndIf
    If Select("W2X") <= 0
        Alert("PO do processo " + Alltrim(aParam[1]) + " não encontrado." + CRLF+CRLF+ "Fonte: CAPAEIC" +CRLF+ "Query: W2X")
        Return
    EndIf

    If aParam[3] == 1
        cTipo := "Principal"
    ElseIf aParam[3] == 2
        cTipo := "Completo"
    ElseIf aParam[3] == 3
        cTipo := "Resumido"
    EndIf

    cTitulo  := "Capa_do_Processo_"+Alltrim(W6X->W6_HAWB)+"_"+DTOS(dDataBase)+"_"+Replace(Time(),":","-")+"_"+cTipo
    cNovoArq := cCaminho+"Capa_do_Processo_"+Alltrim(W6X->W6_HAWB)+"_"+DTOS(dDataBase)+"_"+Replace(Time(),":","-")+"_"+cTipo+".htm"
    
    oProcess := TWFProcess():New(W6X->W6_HAWB, "Capa de Importacao123")
	
    oProcess:NewTask("CAPA", "\workflow\capaEic.html")

    oProcess:cSubject := "Capa de Importação - " + W6X->W6_HAWB

    If WBX->(!EOF())
        cAuxMoe := WBX->WB_MOEDA
    EndIf

    oProcess:oHtml:ValByName("CAPADOPROCESSO"	, cTitulo)
    oProcess:oHtml:ValByName("cProcesso"		, W6X->W6_HAWB)
    oProcess:oHtml:ValByName("cFilial"		    , GetAdvFVal("SYT","YT_X_FILIA",XFILIAL("SYT")+W6X->W6_IMPORT,1))
    oProcess:oHtml:ValByName("cSC"	            , W0X->W0_C1_NUM)
    oProcess:oHtml:ValByName("cSI"	            , W3X->W3_SI_NUM)
    oProcess:oHtml:ValByName("PCompra"		    , Iif(Empty(W2X->W2_X1COMP),"NAO","SIM"))
    oProcess:oHtml:ValByName("cFabrica"		    , GetAdvFVal("SA2","A2_NREDUZ",xFilial("SA2")+GetAdvFVal("SW2","W2_FORN",xFilial("SW2")+W6X->W6_PO_NUM,1),1)) 
    oProcess:oHtml:ValByName("cTpMoeda"		    , Iif(!Empty(cAuxMoe),cAuxMoe,W6X->W6_FREMOED)) //rodrigo ajuste
    oProcess:oHtml:ValByName("cProduto"	        , cFamilia)
    oProcess:oHtml:ValByName("cNCM"		        , cNCM)
    oProcess:oHtml:ValByName("cLI"	            , Iif(lTemLI,"SIM","NAO"))
    oProcess:oHtml:ValByName("Comprador"        ,  W0X->W0_SOLIC)

    cNomeDes := GetAdvFVal("SY5","Y5_NOME",XFILIAL("SY5") + W2X->W2_DESP,1)

    For nlx := 1 to Len(cNomeDes)
        If SubStr(cNomeDes,nlx,1) == " "
            cNomeDes := SubStr(cNomeDes,1,nlx-1)
            Exit
        EndIf
    Next
    
    oProcess:oHtml:ValByName("cDespachante"	    , cNomeDes)
    oProcess:oHtml:ValByName("cResponsavel"		, W6X->W6_XNOMRES)
    oProcess:oHtml:ValByName("cTransporte"	    , GetAdvFVal("SYQ","YQ_DESCR",XFILIAL("SYQ") + W2X->W2_TIPO_EM,1 ))
    
    If W6X->W6_CONTA20 > 0
        cContr := cValToChar(W6X->W6_CONTA20) + "x 20"
    EndIf 

    If W6X->W6_CONTA40 > 0
        If Empty(cContr)
            cContr := cValToChar(W6X->W6_CONTA40) + "x 40"
        else
            cContr += "/" + cValToChar(W6X->W6_CONTA40) + "x 40"
        EndIf
    EndIf 
    
    If W6X->W6_CON40HC > 0
        If Empty(cContr)
            cContr := cValToChar(W6X->W6_CON40HC) + "x 40 HC"
        else
            cContr += "/" + cValToChar(W6X->W6_CON40HC) + "x 40 HC"
        EndIf
    EndIf 

    oProcess:oHtml:ValByName("cCTNR"		    , cContr)
    oProcess:oHtml:ValByName("cRota"		    , W2X->W2_DEST)
    oProcess:oHtml:ValByName("cETD"	            , DTOC(STOD(W6X->W6_DT_ETD)))
    oProcess:oHtml:ValByName("cETA"	            , DTOC(STOD(W6X->W6_DT_ETA)))
    oProcess:oHtml:ValByName("cTotal"	        , Alltrim(TRANSFORM(Round(W6X->W6_VLMLEMN / W6X->W6_TX_US_D,2),"@E 999,999,999.99"))) //rodrigo ajuste
    oProcess:oHtml:ValByName("cDtEnc"		    , DTOC(STOD(W6X->W6_DT_ENCE)))

    If CRX->(!EOF())
        While CRX->(!EOF())
            If SubStr(CRX->APROVADOR,1,2) == "01"
                cAprova1 := SubStr(CRX->APROVADOR,4,len(CRX->APROVADOR))
            ElseIf SubStr(CRX->APROVADOR,1,2) == "02"
                cAprova2 := SubStr(CRX->APROVADOR,4,len(CRX->APROVADOR))
            EndIf
            CRX->(dbSkip())
        EndDo        
    Else
        cAprova1 := ""
        cAprova2 := ""
    EndIF

    oProcess:oHtml:ValByName("Gestor"	  , cAprova1)
    oProcess:oHtml:ValByName("Diretoria"  , cAprova2)

    If WOX->(!EOF())
        While WOX->(!EOF())
            aadd(oProcess:oHtml:ValByName("m.cData")	, DTOC(STOD(WOX->WO_DT)))
            aadd(oProcess:oHtml:ValByName("m.cMotivo")	, FwCutOff(Alltrim(WOX->WO_DESC),.T.))
            WOX->(dbSkip())
    	EndDo
	Else
        aadd(oProcess:oHtml:ValByName("m.cData")	, "" )
        aadd(oProcess:oHtml:ValByName("m.cMotivo")	, "")
    EndIf	
    
    If WBX->(!EOF())
        While WBX->(!EOF())
            aadd(oProcess:oHtml:ValByName("r.cRemessa")	, Tabela("Y6",WBX->WB_TIPOREG) )
            If Select("Y6X") > 0
                If Alltrim(WBX->WB_PARCELA) == "A"
                    cPerc := Y6X->Y6_PERC_01
                ElseIf Alltrim(WBX->WB_PARCELA) == "B"
                    cPerc := Y6X->Y6_PERC_02
                ElseIf Alltrim(WBX->WB_PARCELA) == "C"
                    cPerc := Y6X->Y6_PERC_03
                ElseIf Alltrim(WBX->WB_PARCELA) == "D"
                    cPerc := Y6X->Y6_PERC_04
                ElseIf Alltrim(WBX->WB_PARCELA) == "E"
                    cPerc := Y6X->Y6_PERC_05
                ElseIf Alltrim(WBX->WB_PARCELA) == "F"
                    cPerc := Y6X->Y6_PERC_06
                ElseIf Alltrim(WBX->WB_PARCELA) == "G"
                    cPerc := Y6X->Y6_PERC_07
                ElseIf Alltrim(WBX->WB_PARCELA) == "H"
                    cPerc := Y6X->Y6_PERC_08
                ElseIf Alltrim(WBX->WB_PARCELA) == "I"
                    cPerc := Y6X->Y6_PERC_09
                ElseIf Alltrim(WBX->WB_PARCELA) == "J"
                    cPerc := Y6X->Y6_PERC_10
                EndIf
            Else
                cPerc := ""
            EndIf

            aadd(oProcess:oHtml:ValByName("r.cPorct")	, cPerc)
            aadd(oProcess:oHtml:ValByName("r.cMoeda")	, WBX->WB_MOEDA)
            aadd(oProcess:oHtml:ValByName("r.cVlrOrig")	, Alltrim(TRANSFORM(Round(Iif(WBX->WB_FOBMOE == 0,WBX->WB_PGTANT,WBX->WB_FOBMOE),2),"@E 999,999,999.99")))
            aadd(oProcess:oHtml:ValByName("r.cVlrConv")	, Alltrim(TRANSFORM(Round(Iif(WBX->WB_FOBMOE == 0,WBX->WB_PGTANT,WBX->WB_FOBMOE) * WBX->WB_CA_TX,2),"@E 999,999,999.99")))
            aadd(oProcess:oHtml:ValByName("r.cBco")	    , POSICIONE("SA6",1,XFILIAL("SA6")+WBX->WB_BANCO+WBX->WB_AGENCIA+WBX->WB_CONTA,"A6_NREDUZ"))
            aadd(oProcess:oHtml:ValByName("r.cTaxa")	, WBX->WB_CA_TX )
            aadd(oProcess:oHtml:ValByName("r.cData")	, DTOC(STOD(WBX->WB_DT_DESE)))
            nTotMoe += Iif(WBX->WB_FOBMOE == 0,WBX->WB_PGTANT,WBX->WB_FOBMOE)
            nTotCon += (Iif(WBX->WB_FOBMOE == 0,WBX->WB_PGTANT,WBX->WB_FOBMOE) * WBX->WB_CA_TX)
            WBX->(dbSkip())
        EndDo
        
        cQuery := " SELECT * FROM " + RetSqlName("SWB")
	    cQuery += " WHERE WB_FILIAL = '"+xFilial("SWB")+"' "
	    cQuery += " AND WB_HAWB = '"+W6X->W6_HAWB+"' "
        cQuery += " AND WB_TIPOTIT = 'INV' "
        cQuery += " AND WB_PGTANT = 0 "
        cQuery += " AND WB_DT_DESE = '' "
	    cQuery += " AND D_E_L_E_T_ = '' "

        If Select("WBB") > 0
            WBB->(dbCloseArea())
        EndIf

        DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery) , 'WBB', .T., .F.)

        While WBB->(!EOF())
            aadd(oProcess:oHtml:ValByName("r.cRemessa")	, Tabela("Y6",WBB->WB_TIPOREG) )
            If Select("Y6X") > 0
                If Alltrim(WBB->WB_PARCELA) == "A"
                    cPerc := Y6X->Y6_PERC_01
                ElseIf Alltrim(WBB->WB_PARCELA) == "B"
                    cPerc := Y6X->Y6_PERC_02
                ElseIf Alltrim(WBB->WB_PARCELA) == "C"
                    cPerc := Y6X->Y6_PERC_03
                ElseIf Alltrim(WBB->WB_PARCELA) == "D"
                    cPerc := Y6X->Y6_PERC_04
                ElseIf Alltrim(WBB->WB_PARCELA) == "E"
                    cPerc := Y6X->Y6_PERC_05
                ElseIf Alltrim(WBB->WB_PARCELA) == "F"
                    cPerc := Y6X->Y6_PERC_06
                ElseIf Alltrim(WBB->WB_PARCELA) == "G"
                    cPerc := Y6X->Y6_PERC_07
                ElseIf Alltrim(WBB->WB_PARCELA) == "H"
                    cPerc := Y6X->Y6_PERC_08
                ElseIf Alltrim(WBB->WB_PARCELA) == "I"
                    cPerc := Y6X->Y6_PERC_09
                ElseIf Alltrim(WBB->WB_PARCELA) == "J"
                    cPerc := Y6X->Y6_PERC_10
                EndIf
            Else
                cPerc := ""
            EndIf

            aadd(oProcess:oHtml:ValByName("r.cPorct")	, cPerc)
            aadd(oProcess:oHtml:ValByName("r.cMoeda")	, WBB->WB_MOEDA)
            aadd(oProcess:oHtml:ValByName("r.cVlrOrig")	, Alltrim(TRANSFORM(Round(Iif(WBB->WB_FOBMOE == 0,WBB->WB_PGTANT,WBB->WB_FOBMOE),2),"@E 999,999,999.99")))
            aadd(oProcess:oHtml:ValByName("r.cVlrConv")	, Alltrim(TRANSFORM(Round(Iif(WBB->WB_FOBMOE == 0,WBB->WB_PGTANT,WBB->WB_FOBMOE) * WBB->WB_CA_TX,2),"@E 999,999,999.99")))
            aadd(oProcess:oHtml:ValByName("r.cBco")	    , POSICIONE("SA6",1,XFILIAL("SA6")+WBB->WB_BANCO+WBB->WB_AGENCIA+WBB->WB_CONTA,"A6_NREDUZ"))
            aadd(oProcess:oHtml:ValByName("r.cTaxa")	, WBB->WB_CA_TX )
            aadd(oProcess:oHtml:ValByName("r.cData")	, DTOC(STOD(WBB->WB_DT_DESE)))
            nTotMoe += Iif(WBB->WB_FOBMOE == 0,WBB->WB_PGTANT,WBB->WB_FOBMOE)
            nTotCon += (Iif(WBX->WB_FOBMOE == 0,WBX->WB_PGTANT,WBX->WB_FOBMOE) * WBX->WB_CA_TX)
            WBB->(dbSkip())
        EndDo

        If Alltrim(cAuxMoe) == "CNY"
            oProcess:oHtml:ValByName("cTpMoeda"		    , cAuxMoe) //rodrigo ajuste
            oProcess:oHtml:ValByName("cTotal"	        , TRANSFORM(Round(nTotMoe,2),"@E 999,999,999.99")) //rodrigo ajuste

            cQuery := " SELECT M2_MOEDA3 FROM " + RetSqlName("SM2")
            cQuery += " WHERE M2_DATA = '"+W6X->W6_DT_DESE+"' "
            cQuery += " AND D_E_L_E_T_ = '' " 

            If Select("M2X") > 0
                M2X->(dbCloseArea())
            EndIf

            DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery) , 'M2X', .T., .F.)

            If M2X->(!EOF())
                nTaxaFr := M2X->M2_MOEDA3
            EndIf

            oProcess:oHtml:ValByName("cTxDI"	 , Alltrim(TRANSFORM(Round(nTaxaFr,4),"@E 999.9999")))
            oProcess:oHtml:ValByName("cVlConDI"  , TRANSFORM(Round(nTotMoe * nTaxaFr,2),"@E 999,999,999.99"))
            oProcess:oHtml:ValByName("cTotVaria" , TRANSFORM(Round(((nTotMoe * nTaxaFr) - nTotCon),2),"@E 999,999,999.99"))
        Else
            oProcess:oHtml:ValByName("cTxDI"	 , Alltrim(TRANSFORM(Round(W6X->W6_TX_US_D,4),"@E 999.9999")))
            oProcess:oHtml:ValByName("cVlConDI"  , TRANSFORM(Round(nTotMoe * W6X->W6_TX_US_D,2),"@E 999,999,999.99"))
            oProcess:oHtml:ValByName("cTotVaria" , TRANSFORM(Round(((nTotMoe * W6X->W6_TX_US_D) - nTotCon),2),"@E 999,999,999.99"))
        EndIf

        oProcess:oHtml:ValByName("cTotOrig"	 , TRANSFORM(Round(nTotMoe,2),"@E 999,999,999.99"))
        oProcess:oHtml:ValByName("cTotConv"  , TRANSFORM(Round(nTotCon,2),"@E 999,999,999.99"))


    Else
        cQuery := " SELECT * FROM " + RetSqlName("SWB")
	    cQuery += " WHERE WB_FILIAL = '"+xFilial("SWB")+"' "
	    cQuery += " AND WB_HAWB = '"+W6X->W6_HAWB+"' "
        cQuery += " AND  WB_TIPOTIT = 'INV' "
        cQuery += " AND WB_PGTANT = 0 "
	    cQuery += " AND D_E_L_E_T_ = '' "

        If Select("WBB") > 0
            WBB->(dbCloseArea())
        EndIf

        DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery) , 'WBB', .T., .F.)

        If WBB->(!EOF())
            cAuxMoe := WBB->WB_MOEDA
        EndIf

        If WBB->(!EOF())
            While WBB->(!EOF())
                aadd(oProcess:oHtml:ValByName("r.cRemessa")	, Tabela("Y6",WBB->WB_TIPOREG) )
                If Select("Y6X") > 0
                    If Alltrim(WBB->WB_PARCELA) == "A"
                        cPerc := Y6X->Y6_PERC_01
                    ElseIf Alltrim(WBB->WB_PARCELA) == "B"
                        cPerc := Y6X->Y6_PERC_02
                    ElseIf Alltrim(WBB->WB_PARCELA) == "C"
                        cPerc := Y6X->Y6_PERC_03
                    ElseIf Alltrim(WBB->WB_PARCELA) == "D"
                        cPerc := Y6X->Y6_PERC_04
                    ElseIf Alltrim(WBB->WB_PARCELA) == "E"
                        cPerc := Y6X->Y6_PERC_05
                    ElseIf Alltrim(WBB->WB_PARCELA) == "F"
                        cPerc := Y6X->Y6_PERC_06
                    ElseIf Alltrim(WBB->WB_PARCELA) == "G"
                        cPerc := Y6X->Y6_PERC_07
                    ElseIf Alltrim(WBB->WB_PARCELA) == "H"
                        cPerc := Y6X->Y6_PERC_08
                    ElseIf Alltrim(WBB->WB_PARCELA) == "I"
                        cPerc := Y6X->Y6_PERC_09
                    ElseIf Alltrim(WBB->WB_PARCELA) == "J"
                        cPerc := Y6X->Y6_PERC_10
                    EndIf
                Else
                    cPerc := ""
                EndIf

                aadd(oProcess:oHtml:ValByName("r.cPorct")	, cPerc)
                aadd(oProcess:oHtml:ValByName("r.cMoeda")	, WBB->WB_MOEDA)
                aadd(oProcess:oHtml:ValByName("r.cVlrOrig")	, Alltrim(TRANSFORM(Round(Iif(WBB->WB_FOBMOE == 0,WBB->WB_PGTANT,WBB->WB_FOBMOE),2),"@E 999,999,999.99")))
                aadd(oProcess:oHtml:ValByName("r.cVlrConv")	, Alltrim(TRANSFORM(Round(Iif(WBB->WB_FOBMOE == 0,WBB->WB_PGTANT,WBB->WB_FOBMOE) * WBB->WB_CA_TX,2),"@E 999,999,999.99")))
                aadd(oProcess:oHtml:ValByName("r.cBco")	    , POSICIONE("SA6",1,XFILIAL("SA6")+WBB->WB_BANCO+WBB->WB_AGENCIA+WBB->WB_CONTA,"A6_NREDUZ"))
                aadd(oProcess:oHtml:ValByName("r.cTaxa")	, WBB->WB_CA_TX )
                aadd(oProcess:oHtml:ValByName("r.cData")	, DTOC(STOD(WBB->WB_DT_DESE)))
                nTotMoe += Iif(WBB->WB_FOBMOE == 0,WBB->WB_PGTANT,WBB->WB_FOBMOE)
                nTotCon += (WBB->WB_FOBMOE * WBB->WB_CA_TX)
                WBB->(dbSkip())
            EndDo

            If Alltrim(cAuxMoe) == "CNY"
                oProcess:oHtml:ValByName("cTpMoeda"		    , cAuxMoe) //rodrigo ajuste
                oProcess:oHtml:ValByName("cTotal"	        , TRANSFORM(Round(nTotMoe,2),"@E 999,999,999.99")) //rodrigo ajuste

                cQuery := " SELECT M2_MOEDA3 FROM " + RetSqlName("SM2")
                cQuery += " WHERE M2_DATA = '"+W6X->W6_DT_DESE+"' "
                cQuery += " AND D_E_L_E_T_ = '' " 

                If Select("M2X") > 0
                    M2X->(dbCloseArea())
                EndIf

                DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery) , 'M2X', .T., .F.)

                If M2X->(!EOF())
                    nTaxaFr := M2X->M2_MOEDA3
                EndIf

                oProcess:oHtml:ValByName("cTxDI"	 , Alltrim(TRANSFORM(Round(nTaxaFr,4),"@E 999.9999")))
                oProcess:oHtml:ValByName("cVlConDI"  , TRANSFORM(Round(nTotMoe * nTaxaFr,2),"@E 999,999,999.99"))
                oProcess:oHtml:ValByName("cTotVaria" , TRANSFORM(Round(((nTotMoe * nTaxaFr) - nTotCon),2),"@E 999,999,999.99"))
            Else
                oProcess:oHtml:ValByName("cTxDI"	 , Alltrim(TRANSFORM(Round(W6X->W6_TX_US_D,4),"@E 999.9999")))
                oProcess:oHtml:ValByName("cVlConDI"  , TRANSFORM(Round(nTotMoe * W6X->W6_TX_US_D,2),"@E 999,999,999.99"))
                oProcess:oHtml:ValByName("cTotVaria" , TRANSFORM(Round(((nTotMoe * W6X->W6_TX_US_D) - nTotCon),2),"@E 999,999,999.99"))
            EndIf

            oProcess:oHtml:ValByName("cTotOrig"	 , TRANSFORM(Round(nTotMoe,2),"@E 999,999,999.99"))
            oProcess:oHtml:ValByName("cTotConv"  , TRANSFORM(Round(nTotCon,2),"@E 999,999,999.99"))

        Else
            aadd(oProcess:oHtml:ValByName("r.cRemessa")	, "")
            aadd(oProcess:oHtml:ValByName("r.cPorct")	, "")
            aadd(oProcess:oHtml:ValByName("r.cMoeda")   , "")
            aadd(oProcess:oHtml:ValByName("r.cVlrOrig") , "")
            aadd(oProcess:oHtml:ValByName("r.cVlrConv") , "")
            aadd(oProcess:oHtml:ValByName("r.cBco")	    , "")
            aadd(oProcess:oHtml:ValByName("r.cTaxa")	, "")
            aadd(oProcess:oHtml:ValByName("r.cData")	, "")
        EndIf   
    EndIf

    If !lTemLI
        aadd(oProcess:oHtml:ValByName("l.cOrgAnu")	    , "")
        aadd(oProcess:oHtml:ValByName("l.cValLI")	    , "")
        aadd(oProcess:oHtml:ValByName("l.cVencto")	    , "")
        aadd(oProcess:oHtml:ValByName("l.dtBaixa")	    , "")
        aadd(oProcess:oHtml:ValByName("l.cGestor")	    , "")
        aadd(oProcess:oHtml:ValByName("l.cDiretoria")	, "")
    EndIf

    While WDX2->(!EOF())
        If !Empty(WDX2->WD_XPEDCOM)
            cQuery := " SELECT E2_VENCREA "
            cQuery += " FROM ( "
            cQuery += " 	  SELECT * FROM " + RetSqlName("SD1")
            cQuery += " 	  WHERE D1_FILIAL = '"+GetAdvFVal("SYT","YT_X_FILIA",XFILIAL("SYT")+W6X->W6_IMPORT,1)+"' "
            cQuery += " 	  AND D1_PEDIDO = '"+WDX2->WD_XPEDCOM+"' "
            cQuery += " 	  AND D1_FORNECE = '"+WDX2->WD_FORN+"' "
            cQuery += " 	  AND D1_LOJA = '"+WDX2->WD_LOJA+"' "
            cQuery += " 	  AND D_E_L_E_T_ = '' "
            cQuery += " ) SD1 "
            cQuery += " LEFT JOIN " + RetSqlName("SE2") + " SE2 "
            cQuery += " 	ON SE2.E2_NUM = SD1.D1_DOC "
            cQuery += " 	AND SE2.E2_FORNECE = SD1.D1_FORNECE "
            cQuery += " 	AND SE2.E2_LOJA = SD1.D1_LOJA "
            cQuery += " 	AND SE2.E2_PREFIXO = SD1.D1_SERIE "
            cQuery += " 	AND SE2.D_E_L_E_T_ = '' "

            If Select("E2X") > 0
                E2X->(dbCloseArea())
            EndIf

            DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery) , 'E2X', .T., .F.)

            If E2X->(!EOF())
                cDataVct := DTOC(STOD(E2X->E2_VENCREA))
            EndIf

            cQuery := " SELECT DISTINCT(CR_NIVEL+'-'+AK_USER) AS APROVADOR "
            cQuery += " FROM "
            cQuery += " ( "
            cQuery += " 	SELECT * FROM " + RetSqlName("SC7")
            cQuery += " 	WHERE C7_NUM = '"+WDX2->WD_XPEDCOM+"' "
            cQuery += " 	AND C7_FILIAL = '"+GetAdvFVal("SYT","YT_X_FILIA",XFILIAL("SYT")+W6X->W6_IMPORT,1)+"' "
            cQuery += " 	AND D_E_L_E_T_ = '' "
            cQuery += " ) SC7 "
            cQuery += " INNER JOIN " + RetSqlName("SCR") + " SCR "
            cQuery += "     ON SCR.CR_NUM = SC7.C7_NUM "
            cQuery += "     AND SCR.CR_FILIAL = SC7.C7_FILIAL "
            cQuery += "     AND SCR.CR_LIBAPRO <> '' "
            cQuery += "     AND SCR.D_E_L_E_T_ = '' "
            cQuery += " INNER JOIN " + RetSqlName("SAK") + " SAK "
            cQuery += "     ON SAK.AK_USER = SCR.CR_USER "
            cQuery += "     AND SAK.D_E_L_E_T_ = '' "
            
            If Select("CRY") > 0
                CRY->(dbCloseArea())
            EndIf

            DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery) , 'CRY', .T., .F.)

        EndIf

        If WDX2->WD_DESPESA == "102"
            cDataVct := DTOC(STOD(W6X->W6_VENCFRE))
        EndIf
        
        If !Empty(WDX2->WD_XNFMAE)
            cQuery := " SELECT * FROM " + RetSqlName("SD1")
            cQuery += " WHERE D1_FILIAL = '"+GetAdvFVal("SYT","YT_X_FILIA",XFILIAL("SYT")+W6X->W6_IMPORT,1)+"' "
            cQuery += " AND D1_FORNECE = '"+WDX2->WD_FORN+"' "
            cQuery += " AND D1_LOJA = '"+WDX2->WD_LOJA+"' "
            cQuery += " AND D1_NFORI = '"+WDX2->WD_XNFMAE+"' "
            cQuery += " AND D_E_L_E_T_ = '' "

            If Select("CTEX") > 0
                CTEX->(dbCloseArea())
            EndIf

            DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery) , 'CTEX', .T., .F.)

            If CTEX->(!EOF())
                cQuery := " SELECT E2_VENCREA, E2_BAIXA FROM " + RetSqlName("SE2")
                cQuery += " WHERE E2_NUM = '"+CTEX->D1_DOC+"' "
                cQuery += " AND E2_FORNECE = '"+WDX2->WD_FORN+"' "
                cQuery += " AND E2_LOJA = '"+WDX2->WD_LOJA+"' "
                cQuery += " AND D_E_L_E_T_ = '' "

                If Select("E2Y") > 0
                    E2Y->(dbCloseArea())
                EndIf

                DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery) , 'E2Y', .T., .F.)

                If E2Y->(!EOF())
                    dVencCTE := DTOC(STOD(E2Y->E2_VENCREA))
                    dBxCTE   := DTOC(STOD(E2Y->E2_BAIXA))
                EndIf

                While CTEX->(!EOF())
                    nValCTE += CTEX->D1_TOTAL
                    CTEX->(dbSkip())
                EndDo
            EndIf
        EndIf
        //LICENCA DE IMPORTACAO
        If GetAdvFVal("SYB","YB_XGRCAPA",XFILIAL("SYB")+WDX2->WD_DESPESA,1) == cDesLI
            If !Empty(WDX2->WD_CTRFIN1)
                dbSelectArea("SE2")
                If SE2->(dbSeek(xFilial("SE2")+ WDX2->WD_PREFIXO + WDX2->WD_CTRFIN1 + WDX2->WD_PARCELA + WDX2->WD_TIPO + WDX2->WD_FORN + WDX2->WD_LOJA ))
                    cNomeOrg := GetAdvFVal("SA2","A2_NREDUZ",XFILIAL("SA2") + SE2->E2_FORNECE + SE2->E2_LOJA,1)
                    nValLI   := SE2->E2_VALOR
                    dLIBaixa := DTOC(SE2->E2_BAIXA)
                Else
                    cNomeOrg := GetAdvFVal("SA2","A2_NREDUZ",XFILIAL("SA2") + WDX2->WD_FORN,1)
                    nValLI   := WDX2->WD_VALOR_R
                EndIf
            ElseIf !Empty(WDX2->WD_XPEDCOM)
                dLIBaixa := "  /  /    "
                dbSelectArea("SC7")
                SC7->(dbSetOrder(2))
                If SC7->(dbSeek(WDX2->WD_XFILPC+"EIC"+WDX2->WD_DESPESA+WDX2->WD_FORN+WDX2->WD_LOJA+WDX2->WD_XPEDCOM))//SC7->(dbSeek(WDX2->WD_XFILPC+WDX2->WD_XPEDCOM))
                    cNomeOrg := GetAdvFVal("SA2","A2_NREDUZ",XFILIAL("SA2") + SC7->C7_FORNECE + SC7->C7_LOJA,1)
                    nValLI   := SC7->C7_TOTAL
                Else
                    cNomeOrg := GetAdvFVal("SA2","A2_NREDUZ",XFILIAL("SA2") + WDX2->WD_FORN,1)
                    nValLI   := WDX2->WD_VALOR_R
                EndIf
            Else
                cNomeOrg := GetAdvFVal("SA2","A2_NREDUZ",XFILIAL("SA2") + WDX2->WD_FORN,1)
                nValLI   := WDX2->WD_VALOR_R
            EndIf
            For nlx := 1 to Len(cNomeOrg)
                If SubStr(cNomeOrg,nlx,1) == " "
                    cNomeOrg := SubStr(cNomeOrg,1,nlx-1)
                    Exit
                EndIf
            Next
            If CRY->(!EOF())
                While CRY->(!EOF())
                    If SubStr(CRY->APROVADOR,1,2) == "01"
                        cAprova1 := SubStr(CRY->APROVADOR,4,len(CRY->APROVADOR))
                    ElseIf SubStr(CRY->APROVADOR,1,2) == "02"
                        cAprova2 := SubStr(CRY->APROVADOR,4,len(CRY->APROVADOR))
                    EndIf
                    CRY->(dbSkip())
                EndDo        
            Else
                cAprova1 := ""
                cAprova2 := ""
            EndIF

            aadd(oProcess:oHtml:ValByName("l.cOrgAnu")	    , cNomeOrg)
            aadd(oProcess:oHtml:ValByName("l.cValLI")	    , Alltrim(TRANSFORM(Round(nValLI,2),"@E 999,999,999.99")))
            aadd(oProcess:oHtml:ValByName("l.cVencto")	    , cDataVct)
            aadd(oProcess:oHtml:ValByName("l.dtBaixa")	    , dLIBaixa)
            aadd(oProcess:oHtml:ValByName("l.cGestor")	    , Alltrim(UsrRetName(cAprova1)))
            aadd(oProcess:oHtml:ValByName("l.cDiretoria")	, Alltrim(UsrRetName(cAprova2)))

            nValLI   := 0
            dLIBaixa := "  /  /    "
            cDataVct := "  /  /    "
            cAprova1 := ""
            cAprova2 := ""
            cNomeOrg := ""
        //REGISTRO DE DECLARAÇÃO DE IMPORTAÇÃO
        ElseIf GetAdvFVal("SYB","YB_XGRCAPA",XFILIAL("SYB")+WDX2->WD_DESPESA,1) == cDesDI 
            If !Empty(WDX2->WD_XPEDCOM) .OR. (WDX2->WD_DESPESA $ cDesNPed)
                dbSelectArea("SC7")
                If GetAdvFVal("SC7","C7_CONAPRO",WDX2->WD_XFILPC + Padr("EIC"+WDX2->WD_DESPESA,15) + WDX2->WD_FORN + WDX2->WD_LOJA + WDX2->WD_XPEDCOM,2) == "L" .OR. (WDX2->WD_DESPESA $ cDesNPed)
                    If !Empty(WDX2->WD_CTRFIN1)
                        dbSelectArea("SE2")
                        If SE2->(dbSeek(xFilial("SE2")+ WDX2->WD_PREFIXO + WDX2->WD_CTRFIN1 + WDX2->WD_PARCELA + WDX2->WD_TIPO + WDX2->WD_FORN + WDX2->WD_LOJA ))
                            nValDI   := SE2->E2_VALOR
                            dDIBaixa := DTOC(SE2->E2_BAIXA)
                        Else
                            nValDI   := WDX2->WD_VALOR_R
                        EndIf
                    ElseIf !Empty(WDX2->WD_XPEDCOM)
                        dDIBaixa := "  /  /    "
                        dbSelectArea("SC7")
                        SC7->(dbSetOrder(2))
                        If SC7->(dbSeek(WDX2->WD_XFILPC+"EIC"+WDX2->WD_DESPESA+WDX2->WD_FORN+WDX2->WD_LOJA+WDX2->WD_XPEDCOM)) //SC7->(dbSeek(WDX2->WD_XFILPC+WDX2->WD_XPEDCOM))
                            nValDI   := SC7->C7_TOTAL
                        Else
                            nValDI   := WDX2->WD_VALOR_R
                        EndIf
                    Else
                        nValDI   := WDX2->WD_VALOR_R
                    EndIf

                    If CRY->(!EOF())
                        While CRY->(!EOF())
                            If SubStr(CRY->APROVADOR,1,2) == "01"
                                cAprova1 := SubStr(CRY->APROVADOR,4,len(CRY->APROVADOR))
                            ElseIf SubStr(CRY->APROVADOR,1,2) == "02"
                                cAprova2 := SubStr(CRY->APROVADOR,4,len(CRY->APROVADOR))
                            EndIf
                            CRY->(dbSkip())
                        EndDo        
                    Else
                        cAprova1 := ""
                        cAprova2 := ""
                    EndIF

                    aadd(oProcess:oHtml:ValByName("imp.nome")	    , GetAdvFVal("SYB","YB_DESCR",XFILIAL("SYB")+WDX2->WD_DESPESA,1))
                    aadd(oProcess:oHtml:ValByName("imp.taxa")	    , Alltrim(TRANSFORM(Round(W6X->W6_TX_US_D,4),"@E 999.9999")))
                    aadd(oProcess:oHtml:ValByName("imp.valor")	    , Alltrim(TRANSFORM(Round(nValDI,2),"@E 999,999,999.99")))
                    aadd(oProcess:oHtml:ValByName("imp.data")	    , cDataVct)
                    aadd(oProcess:oHtml:ValByName("imp.dtBaixa")    , dDIBaixa)
                    aadd(oProcess:oHtml:ValByName("imp.cGestor")	, Alltrim(UsrRetName(cAprova1)))
                    aadd(oProcess:oHtml:ValByName("imp.cDiretoria") , Alltrim(UsrRetName(cAprova2)))
                    lTemDI := .T.
                EndIf
            EndIf

            nValDI   := 0
            cDataVct := "  /  /    "
            dDIBaixa := "  /  /    "
            cAprova1 := ""
            cAprova2 := ""
        //DESPESA POS DESEMBARACO 
        ElseIf GetAdvFVal("SYB","YB_XGRCAPA",XFILIAL("SYB")+WDX2->WD_DESPESA,1) == cDesPos
            If !Empty(WDX2->WD_XPEDCOM) .OR. (WDX2->WD_DESPESA $ cDesNPed)
                dbSelectArea("SC7")
                If GetAdvFVal("SC7","C7_CONAPRO",WDX2->WD_XFILPC + Padr("EIC"+WDX2->WD_DESPESA,15) + WDX2->WD_FORN + WDX2->WD_LOJA + WDX2->WD_XPEDCOM,2) == "L" .OR. (WDX2->WD_DESPESA $ cDesNPed)
                    If !Empty(WDX2->WD_CTRFIN1)
                        dbSelectArea("SE2")
                        If SE2->(dbSeek(xFilial("SE2")+ WDX2->WD_PREFIXO + WDX2->WD_CTRFIN1 + WDX2->WD_PARCELA + WDX2->WD_TIPO + WDX2->WD_FORN + WDX2->WD_LOJA ))
                            nValPos   := SE2->E2_VALOR
                            dPosBaixa := DTOC(SE2->E2_BAIXA)
                        Else
                            nValPos   := WDX2->WD_VALOR_R
                        EndIf
                    ElseIf !Empty(WDX2->WD_XPEDCOM)
                        dPosBaixa := "  /  /    "
                        dbSelectArea("SC7")
                        SC7->(dbSetOrder(2))
                        If SC7->(dbSeek(WDX2->WD_XFILPC+"EIC"+WDX2->WD_DESPESA+WDX2->WD_FORN+WDX2->WD_LOJA+WDX2->WD_XPEDCOM)) //SC7->(dbSeek(WDX2->WD_XFILPC+WDX2->WD_XPEDCOM))
                           nValPos   := SC7->C7_TOTAL
                        Else
                            nValPos   := WDX2->WD_VALOR_R
                        EndIf
                    Else
                        nValPos   := WDX2->WD_VALOR_R
                    EndIf


                    cNomeFor := GetAdvFVal("SA2","A2_NREDUZ",XFILIAL("SA2") + WDX2->WD_FORN,1)
                
                    For nlx := 1 to Len(cNomeFor)
                        If SubStr(cNomeFor,nlx,1) == " "
                            cNomeFor := SubStr(cNomeFor,1,nlx-1)
                            Exit
                        EndIf
                    Next

                    If CRY->(!EOF())
                        While CRY->(!EOF())
                            If SubStr(CRY->APROVADOR,1,2) == "01"
                                cAprova1 := SubStr(CRY->APROVADOR,4,len(CRY->APROVADOR))
                            ElseIf SubStr(CRY->APROVADOR,1,2) == "02"
                                cAprova2 := SubStr(CRY->APROVADOR,4,len(CRY->APROVADOR))
                            EndIf
                            CRY->(dbSkip())
                        EndDo        
                    Else
                        cAprova1 := ""
                        cAprova2 := ""
                    EndIF

                    aadd(oProcess:oHtml:ValByName("pos.cGestor")	, Alltrim(UsrRetName(cAprova1)))
                    aadd(oProcess:oHtml:ValByName("pos.cDiretoria")	, Alltrim(UsrRetName(cAprova2)))

                    aadd(oProcess:oHtml:ValByName("pos.descri")	, GetAdvFVal("SYB","YB_DESCR",XFILIAL("SYB")+WDX2->WD_DESPESA,1))
                    aadd(oProcess:oHtml:ValByName("pos.fornece"), cNomeFor)
                    
                    If !(WDX2->WD_DESPESA $ cDesCTE)
                        aadd(oProcess:oHtml:ValByName("pos.doc")	, WDX2->WD_DOCTO)
                        aadd(oProcess:oHtml:ValByName("pos.vencto")	, cDataVct)
                        aadd(oProcess:oHtml:ValByName("pos.valor")	, Alltrim(TRANSFORM(Round(nValPos,2),"@E 999,999,999.99")))
                        aadd(oProcess:oHtml:ValByName("pos.baixa")	, dPosBaixa)
                    Else
                        aadd(oProcess:oHtml:ValByName("pos.doc")	, "CTE")
                        aadd(oProcess:oHtml:ValByName("pos.vencto")	, dVencCTE)
                        aadd(oProcess:oHtml:ValByName("pos.valor")	, Alltrim(TRANSFORM(Round(nValCTE,2),"@E 999,999,999.99")))
                        aadd(oProcess:oHtml:ValByName("pos.baixa")	, dBxCTE)
                    EndIf
                    lTemPos := .T.
                EndIf
            EndIf
            cAprova1   := ""
            cAprova1   := ""
            cNomeFor   := ""
            cDataVct   := "  /  /    "
            dPosBaixa  := "  /  /    "     
            nValPos    := 0 
            nValCTE    := 0 
            dVencCTE   := "  /  /    "  
            dBxCTE     := "  /  /    "
        //RECICLUS
        ElseIf GetAdvFVal("SYB","YB_XGRCAPA",XFILIAL("SYB")+WDX2->WD_DESPESA,1) == cDesRec
            If !Empty(WDX2->WD_XPEDCOM) .OR. (WDX2->WD_DESPESA $ cDesNPed)
                dbSelectArea("SC7")
                If GetAdvFVal("SC7","C7_CONAPRO",WDX2->WD_XFILPC + Padr("EIC"+WDX2->WD_DESPESA,15) + WDX2->WD_FORN + WDX2->WD_LOJA + WDX2->WD_XPEDCOM,2) == "L" .OR. (WDX2->WD_DESPESA $ cDesNPed)
                    If !Empty(WDX2->WD_CTRFIN1)
                        dbSelectArea("SE2")
                        If SE2->(dbSeek(xFilial("SE2")+ WDX2->WD_PREFIXO + WDX2->WD_CTRFIN1 + WDX2->WD_PARCELA + WDX2->WD_TIPO + WDX2->WD_FORN + WDX2->WD_LOJA ))
                            nValRec   := SE2->E2_VALOR
                        Else
                            nValRec   := WDX2->WD_VALOR_R
                        EndIf
                    ElseIf !Empty(WDX2->WD_XPEDCOM)
                        dbSelectArea("SC7")
                        SC7->(dbSetOrder(2))
                        If SC7->(dbSeek(WDX2->WD_XFILPC+"EIC"+WDX2->WD_DESPESA+WDX2->WD_FORN+WDX2->WD_LOJA+WDX2->WD_XPEDCOM)) //SC7->(dbSeek(WDX2->WD_XFILPC+WDX2->WD_XPEDCOM))
                            nValRec   := SC7->C7_TOTAL
                        Else
                            nValRec   := WDX2->WD_VALOR_R
                        EndIf
                    Else
                        nValRec   := WDX2->WD_VALOR_R
                    EndIf

                    oProcess:oHtml:ValByName("cMes"	            , strzero(Month(STOD(WDX2->WD_DES_ADI)),2))
                    oProcess:oHtml:ValByName("cValTot"          , Alltrim(TRANSFORM(Round(nValRec,2),"@E 999,999,999.99")))
                    
                    nValMes := Round((nValRec / 6),2)
                    
                    oProcess:oHtml:ValByName("cVL1", Alltrim(TRANSFORM(nValMes,"@E 999,999,999.99")))
                    oProcess:oHtml:ValByName("cVL2", Alltrim(TRANSFORM(nValMes,"@E 999,999,999.99")))
                    oProcess:oHtml:ValByName("cVL3", Alltrim(TRANSFORM(nValMes,"@E 999,999,999.99")))
                    oProcess:oHtml:ValByName("cVL4", Alltrim(TRANSFORM(nValMes,"@E 999,999,999.99")))
                    oProcess:oHtml:ValByName("cVL5", Alltrim(TRANSFORM(nValMes,"@E 999,999,999.99")))        
                    oProcess:oHtml:ValByName("cVL6", Alltrim(TRANSFORM(nValMes,"@E 999,999,999.99")))        
                    nValRec := 0
                    nValMes := 0
                EndIf
            EndIf
        EndIf
        
        If Select("CRY") > 0 
            CRY->(dbCloseArea())
        EndIf
        
        If Select("E2X") > 0
            E2X->(dbCloseArea())
        EndIf

        cDataVct := ""
        WDX2->(dbSkip())
    EndDo

    If !lTemDI
        aadd(oProcess:oHtml:ValByName("imp.nome")	    , "")
        aadd(oProcess:oHtml:ValByName("imp.taxa")	    , "")
        aadd(oProcess:oHtml:ValByName("imp.valor")	    , "")
        aadd(oProcess:oHtml:ValByName("imp.data")	    , "")
        aadd(oProcess:oHtml:ValByName("imp.dtBaixa")    , "")
        aadd(oProcess:oHtml:ValByName("imp.cGestor")    , "")
        aadd(oProcess:oHtml:ValByName("imp.cDiretoria") , "")
    EndIf

    If !lTemPos
        aadd(oProcess:oHtml:ValByName("pos.descri")	    , "")
        aadd(oProcess:oHtml:ValByName("pos.fornece")    , "")
        aadd(oProcess:oHtml:ValByName("pos.doc")	    , "")
        aadd(oProcess:oHtml:ValByName("pos.vencto")	    , "")
        aadd(oProcess:oHtml:ValByName("pos.valor")	    , "")
        aadd(oProcess:oHtml:ValByName("pos.baixa")	    , "")
        aadd(oProcess:oHtml:ValByName("pos.cGestor")	, "")
        aadd(oProcess:oHtml:ValByName("pos.cDiretoria")	, "")
    EndIf

    oProcess:cTo := "CapaEIC"

    cMailID := oProcess:Start(cCaminho)
    
    oProcess:Finish()

    frename(cCaminho+cMailID+".htm",cNovoArq)
    shellExecute( "Open", cNovoArq, "", "C:\", 1 )
    
    RestArea(aArea)
Return(.T.)

//--------------------------------------------------------------------
/*/{Protheus.doc} CAPAEIC
Rotina de impressão do EIC
@author Rodrigo Nunes
@since 30/09/2020
@version 1.0 
@type function
/*/
//--------------------------------------------------------------------
Static Function PergPara()
Local aRet	 := {}
Local aPergs := {}
local tmp    := getTempPath()

aAdd(aPergs, {1, "Processo:"            ,Space(TamSX3("W6_HAWB")[1]) ,"@!", ".T.", "SW6", ".T.", 50, .T.})
aAdd(aPergs, {9, "Impressão dos Motivos",250,15,.T.})
aAdd(aPergs, {2, "Historico:"           ,1,{"Principal","Completo","Resumido"},50,"", .T.})
aAdd(aPergs, {9, "Campo valido apenas para historico resumido",250,15,.T.})
aAdd(aPergs, {1, "Qtd de registros:"    ,0 ,"@E 999", "POSITIVO()", , ".T.", 15, .F.})

If ParamBox(aPergs,"Impressão",@aRet)
	aParam   := AjRetParam(aRet,aPergs)
    cCaminho := cGetFile( , 'Selecione a pasta de destino', , tmp, .F., GETF_LOCALHARD+GETF_RETDIRECTORY,.F.)
EndIf

Return

//--------------------------------------------------------------------
/*/{Protheus.doc} AjRetParam
Funcão de ajuste do conteúdo da ParamBox.

@author Rodrigo Nunes
@since 17/02/2021
/*/
//--------------------------------------------------------------------
Static Function AjRetParam(aRet,aParamBox)
	Local nX		:= 0
	
	If ValType(aRet) == "A" .And. Len(aRet) == Len(aParamBox)
		For nX := 1 to Len(aParamBox)
			If aParamBox[nX][1] == 1
				aRet[nX] := aRet[nX]
			ElseIf aParamBox[nX][1] == 2 .And. ValType(aRet[nX]) == "C"
				aRet[nX] := aScan(aParamBox[nX][4],{|x| AllTrim(x) == aRet[nX]})
			ElseIf aParamBox[nX][1] == 2 .And. ValType(aRet[nX]) == "N"
				aRet[nX] := aRet[nX]
			EndIf
		Next nX
	EndIf
	
Return aRet
