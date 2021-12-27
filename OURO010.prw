#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "TBICONN.CH"
    
//--------------------------------------------------------------------
/*/{Protheus.doc} OURO010
Rotina para geração dos titulos PRE para Solicitação de Compras
@author Rodrigo Nunes
@since 08/12/2021
@version 1.0 
@type function
/*/
//--------------------------------------------------------------------

User Function OURO010(nTpTit,cFilSC,cNumSC,cFilPO,cNumPO,cNumSI)
    Default nTpTit := ""
    Default cFilSC := ""
    Default cNumSC := ""
    Default cFilPO := ""
    Default cNumPO := ""
    Default cNumSI := ""

    If nTpTit == "GER.TOTAL"
        GPRETOT(cFilSC,cNumSC,cFilPO,cNumPO,cNumSI)
    ElseIf nTpTit == "GER.PARCIAL"
        GPREPAR(cFilSC,cNumSC,cFilPO,cNumPO,cNumSI)
    ElseIf nTpTit == "EXC.TOTAL"
        EPRETOT(cFilSC,cNumSC,cFilPO,cNumPO,cNumSI)
    ElseIf nTpTit == "EXC.PARCIAL"
        EPREPAR(cFilSC,cNumSC,cFilPO,cNumPO,cNumSI)
    EndIf
Return .T.

//--------------------------------------------------------------------
/*/{Protheus.doc} GPRETOT
Rotina para geração dos titulos PRE para Solicitação de Compras TOTAL
@author Rodrigo Nunes
@since 08/12/2021
@version 1.0 
@type function
/*/
//--------------------------------------------------------------------

Static Function GPRETOT(cFilSC,cNumSC,cFilPO,cNumPO,cNumSI)
	Local cQuery  := ""
	Local cQryPrd := ""
	Local aProd   := {}
	Local aCondPg := {}
	Local cOriPrd := ""

	dbSelectArea("SB1")
	dbSelectArea("SE4")

	cQuery := " SELECT C1_PRODUTO, SUM(C1_QUANT) AS QUANTIDADE FROM " + RetSqlName("SC1")
	cQuery += " WHERE C1_FILIAL = '"+cFilSC+"' "
	cQuery += " AND C1_NUM = '"+cNumSC+"' "
	cQuery += " AND C1_APROV = 'L' "
	cQuery += " AND D_E_L_E_T_ = '' "
	cQuery += " GROUP BY C1_PRODUTO "

	If Select("XPRD") > 0
		XPRD->(dbCloseArea())
	EndIf

	DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery) , 'XPRD', .T., .F.)

	While XPRD->(!EOF())
		cQryPrd := " SELECT TOP(1) C7_PRODUTO, C7_PRECO, C7_MOEDA, C7_PO_EIC FROM " + RetSqlName("SC7")
		cQryPrd += " WHERE C7_PRODUTO = '"+XPRD->C1_PRODUTO+"' "
		cQryPrd += " AND C7_CONAPRO = 'L' "
		cQryPrd += " AND D_E_L_E_T_ = '' "
		cQryPrd += " ORDER BY C7_EMISSAO DESC "

		If Select("XUPC") > 0
			XUPC->(dbCloseArea())
		EndIf

		DbUseArea(.T., "TOPCONN", TCGenQry(,,cQryPrd) , 'XUPC', .T., .F.)
		
		If XUPC->(!EOF())
			AADD(aProd,{XPRD->C1_PRODUTO, XPRD->QUANTIDADE, XUPC->C7_PRECO, XUPC->C7_MOEDA, XUPC->C7_PO_EIC})
		EndIf

		cOriPrd := Posicione("SB1",1,xFilial("SB1")+XPRD->C1_PRODUTO,"B1_ORIGEM")
		
		If cOriPrd $ '0|3|4|5' //Nacionais
			cQryNac := " SELECT TOP(1) D1_FILIAL, D1_DOC, D1_SERIE, D1_FORNECE, D1_LOJA, D1_TIPO, F1_COND "
			cQryNac += " FROM "
			cQryNac += " 	(SELECT D1_FILIAL, D1_DOC, D1_SERIE, D1_FORNECE, D1_LOJA, D1_TIPO, D1_EMISSAO FROM " + RetSqlName("SD1")
			cQryNac += " 	 WHERE D1_COD = '"+XPRD->C1_PRODUTO+"' "
			cQryNac += " 	 AND D1_TIPO = 'N' "
			cQryNac += " 	 AND SUBSTRING(D1_CF,2,3) <> '949' "
			cQryNac += " 	 AND D1_FORNECE <> '001049' "
			cQryNac += " 	 AND D_E_L_E_T_ = '' "
			cQryNac += " 	)SD1 "
			cQryNac += " INNER JOIN " + RetSqlName("SF1") + " SF1 "
			cQryNac += " ON SF1.F1_FILIAL = SD1.D1_FILIAL "
			cQryNac += " AND SF1.F1_DOC = SD1.D1_DOC "
			cQryNac += " AND SF1.F1_SERIE = SD1.D1_SERIE "
			cQryNac += " AND SF1.F1_FORNECE = SD1.D1_FORNECE "
			cQryNac += " AND SF1.F1_LOJA = SD1.D1_LOJA "
			cQryNac += " AND SF1.F1_TIPO = SD1.D1_TIPO "
			cQryNac += " ORDER BY SD1.D1_EMISSAO DESC "
									
			If Select("XCDPG") > 0
				XCDPG->(dbCloseArea())
			EndIf

			DbUseArea(.T., "TOPCONN", TCGenQry(,,cQryNac) , 'XCDPG', .T., .F.)
			
			If XCDPG->(!EOF())
				AADD(aCondPg,{XPRD->C1_PRODUTO,XCDPG->F1_COND,"NAC"})
			EndIf

		ElseIf cOriPrd $ '1|2|6|7|8' //Importados
			cQryImp := " SELECT TOP(1) W2_PO_DT, W2_PO_NUM, W2_COND_PA, W3_COD_I "
			cQryImp += " FROM "
			cQryImp += " 	(SELECT * FROM " + RetSqlName("SW3")
			cQryImp += " 	 WHERE W3_COD_I = '"+XPRD->C1_PRODUTO+"' "
			cQryImp += " 	 AND D_E_L_E_T_ = '' "
			cQryImp += " 	 )SW3 "
			cQryImp += " INNER JOIN " + RetSqlName("SW2") + " SW2 "
			cQryImp += " ON SW2.W2_PO_NUM = SW3.W3_PO_NUM "
			cQryImp += " AND SW2.D_E_L_E_T_ = '' "
			cQryImp += " ORDER BY W2_PO_DT DESC "

			If Select("XCDPG") > 0
				XCDPG->(dbCloseArea())
			EndIf

			DbUseArea(.T., "TOPCONN", TCGenQry(,,cQryImp) , 'XCDPG', .T., .F.)
			
			If XCDPG->(!EOF())
				AADD(aCondPg,{XPRD->C1_PRODUTO,XCDPG->W2_COND_PA,"IMP"})
			EndIf
		EndIf
		XPRD->(dbSkip())
	EndDo

	If !Empty(aProd) .And. !Empty(aCondPg)
		CONOUT('OK')
	EndIf

	
Return (.T.)

//--------------------------------------------------------------------
/*/{Protheus.doc} GPREPAR
Rotina para geração dos titulos PRE para Solicitação de Compras PARCIAL
@author Rodrigo Nunes
@since 08/12/2021
@version 1.0 
@type function
/*/
//--------------------------------------------------------------------

Static Function GPREPAR(cFilSC,cNumSC,cFilPO,cNumPO,cNumSI)


Return

//--------------------------------------------------------------------
/*/{Protheus.doc} EPRETOT
Rotina para exclusão dos titulos PRE para Solicitação de Compras TOTAL
@author Rodrigo Nunes
@since 08/12/2021
@version 1.0 
@type function
/*/
//--------------------------------------------------------------------

Static Function EPRETOT(cFilSC,cNumSC,cFilPO,cNumPO,cNumSI)


Return

//--------------------------------------------------------------------
/*/{Protheus.doc} EPREPAR
Rotina para exclusão dos titulos PRE para Solicitação de Compras PARCIAL
@author Rodrigo Nunes
@since 08/12/2021
@version 1.0 
@type function
/*/
//--------------------------------------------------------------------

Static Function EPREPAR(cFilSC,cNumSC,cFilPO,cNumPO,cNumSI)


Return

/*
    aArray := {{ "E2_FILIAL"   , xFilial("SE2")    			 	, NIL },;
								           { "E2_PREFIXO"  , "FAT"             			 	, NIL },;
			            		           { "E2_NUM"      , cNumFat                        , NIL },;
			            		           { "E2_TIPO"     , "NF"              			 	, NIL },;
			            		           { "E2_NATUREZ"  , GetMV("FT_OUA005A",,"6212003") , NIL },;
			            		           { "E2_FORNECE"  , SA2->A2_COD         	 	 	, NIL },;
			            		           { "E2_LOJA"     , SA2->A2_LOJA          		 	, NIL },;
			            		           { "E2_NOMFOR"   , SA2->A2_NREDUZ				 	, NIL },;
			            		           { "E2_EMISSAO"  , dEmissao                       , NIL },;
			            		           { "E2_VENCTO"   , dVencto                        , NIL },;
			            		           { "E2_VENCREA"  , dVencrea                       , NIL },;
			            		           { "E2_VALOR"    , nValor                         , NIL },;
							   { "E2_DECRESC"  , nValDesc                       , NIL },;
			            		           { "E2_ORIGEM"   , "TRANSPO"                 	, NIL },;
								{ "E2_XAPROV1"  , cAprova1			, NIL },;							   
								{ "E2_XAPROV2"  , cAprova			, NIL }} // rogerio - invertido por solicitacao do Cristiano, este processovai ser aprovado pelo gerente e diretor

								cAprova := ""
								cAprova1 := ""
								
			            		            
			    	  			Begin Transaction
	            						
				 					_OldFun := FunName()
									SetFunName("FINA050")
									MsExecAuto({ |x,y,z| FINA050(x,y,z)}, aArray,, 3)  // 3 - Inclusao, 4 - Alteracao, 5 - Exclusao.
