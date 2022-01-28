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

User Function OURO010(nTpTit,cFilSC,cNumSC,aPrdSld)
	Local   aArea 	:= GetArea()
    Private cConPGN := SuperGetMV("ES_CONDSCN",.F.,"028")
	Private cConPGI := SuperGetMV("ES_CONDSCI",.F.,"00001")
	Private nDiaSin := SuperGetMV("ES_DIASSIN",.F.,10)
	Private nDiaBal := SuperGetMV("ES_DIASBAL",.F.,23)
	Default nTpTit  := ""
    Default cFilSC  := ""
    Default cNumSC  := ""
    Default aPrdSld := {}

    If nTpTit == "INCLUI PR"
        IPRSCT(cFilSC,cNumSC)
    ElseIf nTpTit == "INCLUI PR PARCIAL"
        EPRSCP(cFilSC,cNumSC,aPrdSld)
	ElseIf nTpTit == "EXCLUI PR"
        EPRSCT(cFilSC,cNumSC)
    EndIf

	RestArea(aArea)
Return .T.

//--------------------------------------------------------------------
/*/{Protheus.doc} IPRSCT
Rotina para geração dos titulos PR para Solicitação de Compras.
@author Rodrigo Nunes
@since 08/12/2021
@version 1.0 
@type function
/*/
//--------------------------------------------------------------------

Static Function IPRSCT(cFilSC,cNumSC)
	Local aArray		:= {}
	Local cQryMoe		:= ""
	Local cQuery  		:= ""
	Local cQryPrd 		:= ""
	Local aProd   		:= {}
	Local nMoeda		:= 0
	Local nValTit		:= 0
	Local nlx			:= 0
	Local lImp			:= .F.
	Local aDtVenc		:= {}
	Local aDiasCond		:= {}
	Local cDias			:= ""
	Local dDtTemp		:= CTOD("")
	Local nTxMoeda      := 0
	Private lMsErroAuto := .F.

	nModulo := 6

	dbSelectArea("SB1")
	dbSelectArea("SE4")	
	dbSelectArea("SM2")	
	
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
		
		XPRD->(dbSkip())
	EndDo

	If !Empty(aProd)
		nMoeda 	:= aProd[1][4] //posicao da moeda
		lImp 	:= Iif(Empty(aProd[1][5]),.F.,.T.)

		For nlx := 1 to Len(aProd)
			nValTit += (aProd[nlx][2] * aProd[nlx][3])
		Next

		cQryDtV := " SELECT TOP(1) C1_XDTPROG, C1_DATPRF FROM " + RetSqlName("SC1")
		cQryDtV += " WHERE C1_FILIAL = '"+cFilSC+"' "
		cQryDtV += " AND C1_NUM = '"+cNumSC+"' "
		cQryDtV += " AND C1_APROV = 'L' "
		cQryDtV += " AND D_E_L_E_T_ = '' "
		
		If Select("XDTV") > 0
			XDTV->(dbCloseArea())
		EndIf

		DbUseArea(.T., "TOPCONN", TCGenQry(,,cQryDtV) , 'XDTV', .T., .F.)

		If XDTV->(!EOF())
			If lImp 
				AADD(aDtVenc,STOD(XDTV->C1_XDTPROG) + nDiaSin)
				AADD(aDtVenc,STOD(XDTV->C1_DATPRF)  - nDiaBal)
			Else
				cDias := Alltrim(Posicione("SE4",1,xFilial("SE4")+cConPGN,"E4_COND"))
				aDiasCond := StrTokArr(cDias,",")
				
				For nlx := 1 to Len(aDiasCond)
					If Empty(dDtTemp)
						dDtTemp := (dDataBase + 5) + Val(aDiasCond[nlx])
					else
						dDtTemp += Val(aDiasCond[nlx])
					EndIF

					AADD(aDtVenc,dDtTemp)
				Next
			EndIf
		EndIf

		If nMoeda <> 1
			cQryMoe := " SELECT TOP(1) M2_MOEDA2, M2_MOEDA3, M2_MOEDA4, M2_MOEDA5 FROM " + RetSqlName("SM2")
			cQryMoe += " WHERE D_E_L_E_T_ = '' "
			cQryMoe += " AND M2_DATA <= '"+DTOS(dDataBase)+"' "
			If nMoeda == 2
				cQryMoe += " AND M2_MOEDA2 > 0 "
			ElseIf nMoeda == 3
				cQryMoe += " AND M2_MOEDA3 > 0 "
			ElseIf nMoeda == 4
				cQryMoe += " AND M2_MOEDA4 > 0 "
			ElseIf nMoeda == 5
				cQryMoe += " AND M2_MOEDA5 > 0 "
			EndIf
			cQryMoe += " ORDER BY M2_DATA DESC "

			If Select("XMOE") > 0
				XMOE->(dbCloseArea())
			EndIf

			DbUseArea(.T., "TOPCONN", TCGenQry(,,cQryMoe) , 'XMOE', .T., .F.)

			If XMOE->(!EOF())
				If nMoeda == 2
					nTxMoeda := XMOE->M2_MOEDA2
				ElseIf nMoeda == 3
					nTxMoeda := XMOE->M2_MOEDA3  
				ElseIf nMoeda == 4
					nTxMoeda := XMOE->M2_MOEDA4 
				ElseIf nMoeda == 5
					nTxMoeda := XMOE->M2_MOEDA5
				EndIf
			EndIf
		Else
			nTxMoeda := 1
		EndIf
	EndIf
		
	For nlx := 1 to Len(aDtVenc)
		If Len(aDtVenc) == 1
			aArray := { { "E2_FILIAL"   , xFilial("SE2")   			 			, NIL },;
						{ "E2_PREFIXO"  , "SC"             			 			, NIL },;
						{ "E2_NUM"      , cFilSc+cNumSC                 		, NIL },;
						{ "E2_TIPO"     , "PR"            			 			, NIL },;
						{ "E2_FORNECE"  , "208534"	         	 	 			, NIL },;
						{ "E2_LOJA"     , "01"       		   		 			, NIL },;
						{ "E2_NOMFOR"   , "RUCKHABER COMISSARIA DE DESPAC"   	, NIL },;
						{ "E2_NATUREZ"  , "6110001"    		   		 			, NIL },;
						{ "E2_EMISSAO"  , dDataBase	                    		, NIL },;
						{ "E2_VENCTO"   , aDtVenc[nlx]                  		, NIL },;
						{ "E2_VENCREA"  , aDtVenc[nlx]                  		, NIL },;
						{ "E2_VALOR"    , nValTit                       		, NIL },;
						{ "E2_ORIGEM"   , "SOLICITA"                 			, NIL },;
						{ "E2_MOEDA"    , nMoeda                 				, NIL },;
						{ "E2_TXMOEDA"  , Iif(nTxMoeda == 1, 0,nTxMoeda)		, NIL },;
						{ "E2_VLCRUZ"   , (nTxMoeda * nValTit)     				, NIL },;
						{ "E2_HIST"     , "Filial:"+cFilSC+"-Numero SC:"+cNumSC , NIL }}
									 
			SetFunName("FINA050")
			MsExecAuto({ |x,y,z| FINA050(x,y,z)}, aArray,, 3)  // 3 - Inclusao, 4 - Alteracao, 5 - Exclusao.
			
			If lMsErroAuto
				MostraErro()
			Else
				//Alert("Título incluído com sucesso!")
			Endif
		Else
			If nlx == 1 
				aArray := { { "E2_FILIAL"   , xFilial("SE2")   			 			, NIL },;
							{ "E2_PREFIXO"  , "SC"             			 			, NIL },;
							{ "E2_NUM"      , cFilSc+cNumSC                 		, NIL },;
							{ "E2_PARCELA"  , "A"            			 			, NIL },;
							{ "E2_TIPO"     , "PR"            			 			, NIL },;
							{ "E2_FORNECE"  , "208534"	         	 	 			, NIL },;
							{ "E2_LOJA"     , "01"       		   		 			, NIL },;
							{ "E2_NOMFOR"   , "RUCKHABER COMISSARIA DE DESPAC"   	, NIL },;
							{ "E2_NATUREZ"  , "6110001"    		   		 			, NIL },;
							{ "E2_EMISSAO"  , dDataBase	                    		, NIL },;
							{ "E2_VENCTO"   , aDtVenc[nlx]                  		, NIL },;
							{ "E2_VENCREA"  , aDtVenc[nlx]                  		, NIL },;
							{ "E2_VALOR"    , ((nValTit * 20) / 100)        		, NIL },;
							{ "E2_ORIGEM"   , "SOLICITA"                 			, NIL },;
							{ "E2_MOEDA"    , nMoeda                 				, NIL },;
							{ "E2_TXMOEDA"  , Iif(nTxMoeda == 1, 0,nTxMoeda)		, NIL },;
							{ "E2_VLCRUZ"   , (nTxMoeda * nValTit)     				, NIL },;
							{ "E2_HIST"     , "Filial:"+cFilSC+"-Numero SC:"+cNumSC , NIL }}

				SetFunName("FINA050")
				MsExecAuto({ |x,y,z| FINA050(x,y,z)}, aArray,, 3)  // 3 - Inclusao, 4 - Alteracao, 5 - Exclusao.
				
				If lMsErroAuto
					MostraErro()
				Else
					//Alert("Título incluído com sucesso!")
				Endif

			ElseIf nlx == 2
				aArray := { { "E2_FILIAL"   , xFilial("SE2")   			 			, NIL },;
							{ "E2_PREFIXO"  , "SC"             			 			, NIL },;
							{ "E2_NUM"      , cFilSc+cNumSC                 		, NIL },;
							{ "E2_PARCELA"  , "B"            			 			, NIL },;
							{ "E2_TIPO"     , "PR"            			 			, NIL },;
							{ "E2_FORNECE"  , "208534"	         	 	 			, NIL },;
							{ "E2_LOJA"     , "01"       		   		 			, NIL },;
							{ "E2_NOMFOR"   , "RUCKHABER COMISSARIA DE DESPAC"   	, NIL },;
							{ "E2_NATUREZ"  , "6110001"    		   		 			, NIL },;
							{ "E2_EMISSAO"  , dDataBase	                    		, NIL },;
							{ "E2_VENCTO"   , aDtVenc[nlx]                  		, NIL },;
							{ "E2_VENCREA"  , aDtVenc[nlx]                  		, NIL },;
							{ "E2_VALOR"    , ((nValTit * 80) / 100)        		, NIL },;
							{ "E2_ORIGEM"   , "SOLICITA"                 			, NIL },;
							{ "E2_MOEDA"    , nMoeda                 				, NIL },;
							{ "E2_TXMOEDA"  , Iif(nTxMoeda == 1, 0,nTxMoeda)		, NIL },;
							{ "E2_VLCRUZ"   , (nTxMoeda * nValTit)     				, NIL },;
							{ "E2_HIST"     , "Filial:"+cFilSC+"-Numero SC:"+cNumSC , NIL }}

				SetFunName("FINA050")
				MsExecAuto({ |x,y,z| FINA050(x,y,z)}, aArray,, 3)  // 3 - Inclusao, 4 - Alteracao, 5 - Exclusao.

				If lMsErroAuto
					MostraErro()
				Else
					//Alert("Título incluído com sucesso!")
				Endif

			EndIf
		EndIf
	Next
	
Return (.T.)

//--------------------------------------------------------------------
/*/{Protheus.doc} EPRSCP
Rotina para geração dos titulos PR para Solicitação de Compras PARCIAL
@author Rodrigo Nunes
@since 08/12/2021
@version 1.0 
@type function
/*/
//--------------------------------------------------------------------

Static Function EPRSCP(cFilSC,cNumSC,aPrdSld)
	Local aArray		:= {}
	Local cQryPrd 		:= ""
	Local cQryMoe		:= ""
	Local aProd   		:= {}
	Local nMoeda		:= 0
	Local nValTit		:= 0
	Local nlx			:= 0
	Local lImp			:= .F.
	Local aDtVenc		:= {}
	Local aDiasCond		:= {}
	Local cDias			:= ""
	Local dDtTemp		:= CTOD("")
	Local nTxMoeda      := 0
	Private lMsErroAuto := .F.

	nModulo := 6

	dbSelectArea("SB1")
	dbSelectArea("SE4")	
	
	For nlx := 1 to Len(aPrdSld)
		cQryPrd := " SELECT TOP(1) C7_PRODUTO, C7_PRECO, C7_MOEDA, C7_PO_EIC FROM " + RetSqlName("SC7")
		cQryPrd += " WHERE C7_PRODUTO = '"+aPrdSld[nlx][1]+"' "
		cQryPrd += " AND C7_CONAPRO = 'L' "
		cQryPrd += " AND D_E_L_E_T_ = '' "
		cQryPrd += " ORDER BY C7_EMISSAO DESC "

		If Select("XUPC") > 0
			XUPC->(dbCloseArea())
		EndIf

		DbUseArea(.T., "TOPCONN", TCGenQry(,,cQryPrd) , 'XUPC', .T., .F.)
		
		If XUPC->(!EOF())
			AADD(aProd,{aPrdSld[nlx][1], aPrdSld[nlx][2], XUPC->C7_PRECO, XUPC->C7_MOEDA, XUPC->C7_PO_EIC})
		EndIf
	Next

	If !Empty(aProd)
		nMoeda 	:= aProd[1][4] //posicao da moeda
		lImp 	:= Iif(Empty(aProd[1][5]),.F.,.T.)

		For nlx := 1 to Len(aProd)
			nValTit += (aProd[nlx][2] * aProd[nlx][3])
		Next

		cQryDtV := " SELECT TOP(1) C1_XDTPROG, C1_DATPRF FROM " + RetSqlName("SC1")
		cQryDtV += " WHERE C1_FILIAL = '"+cFilSC+"' "
		cQryDtV += " AND C1_NUM = '"+cNumSC+"' "
		cQryDtV += " AND C1_APROV = 'L' "
		cQryDtV += " AND D_E_L_E_T_ = '' "
		
		If Select("XDTV") > 0
			XDTV->(dbCloseArea())
		EndIf

		DbUseArea(.T., "TOPCONN", TCGenQry(,,cQryDtV) , 'XDTV', .T., .F.)

		If XDTV->(!EOF())
			If lImp 
				AADD(aDtVenc,STOD(XDTV->C1_XDTPROG) + nDiaSin)
				AADD(aDtVenc,STOD(XDTV->C1_DATPRF)  - nDiaBal)
			Else
				cDias := Alltrim(Posicione("SE4",1,xFilial("SE4")+cConPGN,"E4_COND"))
				aDiasCond := StrTokArr(cDias,",")
				
				For nlx := 1 to Len(aDiasCond)
					If Empty(dDtTemp)
						dDtTemp := (dDatabase + 5) + Val(aDiasCond[nlx])
					else
						dDtTemp += Val(aDiasCond[nlx])
					EndIF

					AADD(aDtVenc,dDtTemp)
				Next
			EndIf
		EndIf

		If nMoeda <> 1
			cQryMoe := " SELECT TOP(1) M2_MOEDA2, M2_MOEDA3, M2_MOEDA4, M2_MOEDA5 FROM " + RetSqlName("SM2")
			cQryMoe += " WHERE D_E_L_E_T_ = '' "
			cQryMoe += " AND M2_DATA <= '"+DTOS(dDataBase)+"' "
			If nMoeda == 2
				cQryMoe += " AND M2_MOEDA2 > 0 "
			ElseIf nMoeda == 3
				cQryMoe += " AND M2_MOEDA3 > 0 "
			ElseIf nMoeda == 4
				cQryMoe += " AND M2_MOEDA4 > 0 "
			ElseIf nMoeda == 5
				cQryMoe += " AND M2_MOEDA5 > 0 "
			EndIf
			cQryMoe += " ORDER BY M2_DATA DESC "

			If Select("XMOE") > 0
				XMOE->(dbCloseArea())
			EndIf

			DbUseArea(.T., "TOPCONN", TCGenQry(,,cQryMoe) , 'XMOE', .T., .F.)

			If XMOE->(!EOF())
				If nMoeda == 2
					nTxMoeda := XMOE->M2_MOEDA2
				ElseIf nMoeda == 3
					nTxMoeda := XMOE->M2_MOEDA3  
				ElseIf nMoeda == 4
					nTxMoeda := XMOE->M2_MOEDA4 
				ElseIf nMoeda == 5
					nTxMoeda := XMOE->M2_MOEDA5
				EndIf
			EndIf
		Else
			nTxMoeda := 1
		EndIf
	EndIf

	For nlx := 1 to Len(aDtVenc)
		If Len(aDtVenc) == 1
			aArray := { { "E2_FILIAL"   , xFilial("SE2")   			 			, NIL },;
						{ "E2_PREFIXO"  , "SC"             			 			, NIL },;
						{ "E2_NUM"      , cFilSc+cNumSC                 		, NIL },;
						{ "E2_TIPO"     , "PR"            			 			, NIL },;
						{ "E2_FORNECE"  , "208534"	         	 	 			, NIL },;
						{ "E2_LOJA"     , "01"       		   		 			, NIL },;
						{ "E2_NOMFOR"   , "RUCKHABER COMISSARIA DE DESPAC"   	, NIL },;
						{ "E2_NATUREZ"  , "6110001"    		   		 			, NIL },;
						{ "E2_EMISSAO"  , dDataBase	                    		, NIL },;
						{ "E2_VENCTO"   , aDtVenc[nlx]                  		, NIL },;
						{ "E2_VENCREA"  , aDtVenc[nlx]                  		, NIL },;
						{ "E2_VALOR"    , nValTit                       		, NIL },;
						{ "E2_ORIGEM"   , "SOLICITA"                 			, NIL },;
						{ "E2_MOEDA"    , nMoeda                 				, NIL },;
						{ "E2_TXMOEDA"  , Iif(nTxMoeda == 1, 0,nTxMoeda)		, NIL },;
						{ "E2_VLCRUZ"   , (nTxMoeda * nValTit)     				, NIL },;
						{ "E2_HIST"     , "Filial:"+cFilSC+"-Numero SC:"+cNumSC , NIL }}
									 
			SetFunName("FINA050")
			MsExecAuto({ |x,y,z| FINA050(x,y,z)}, aArray,, 3)  // 3 - Inclusao, 4 - Alteracao, 5 - Exclusao.
			
			If lMsErroAuto
				MostraErro()
			Else
				//Alert("Título incluído com sucesso!")
			Endif
		Else
			If nlx == 1 
				aArray := { { "E2_FILIAL"   , xFilial("SE2")   			 			, NIL },;
							{ "E2_PREFIXO"  , "SC"             			 			, NIL },;
							{ "E2_NUM"      , cFilSc+cNumSC                 		, NIL },;
							{ "E2_PARCELA"  , "A"            			 			, NIL },;
							{ "E2_TIPO"     , "PR"            			 			, NIL },;
							{ "E2_FORNECE"  , "208534"	         	 	 			, NIL },;
							{ "E2_LOJA"     , "01"       		   		 			, NIL },;
							{ "E2_NOMFOR"   , "RUCKHABER COMISSARIA DE DESPAC"   	, NIL },;
							{ "E2_NATUREZ"  , "6110001"    		   		 			, NIL },;
							{ "E2_EMISSAO"  , dDataBase	                    		, NIL },;
							{ "E2_VENCTO"   , aDtVenc[nlx]                  		, NIL },;
							{ "E2_VENCREA"  , aDtVenc[nlx]                  		, NIL },;
							{ "E2_VALOR"    , ((nValTit * 20) / 100)        		, NIL },;
							{ "E2_ORIGEM"   , "SOLICITA"                 			, NIL },;
							{ "E2_MOEDA"    , nMoeda                 				, NIL },;
							{ "E2_TXMOEDA"  , Iif(nTxMoeda == 1, 0,nTxMoeda)		, NIL },;
							{ "E2_VLCRUZ"   , (nTxMoeda * nValTit)     				, NIL },;
							{ "E2_HIST"     , "Filial:"+cFilSC+"-Numero SC:"+cNumSC , NIL }}

				SetFunName("FINA050")
				MsExecAuto({ |x,y,z| FINA050(x,y,z)}, aArray,, 3)  // 3 - Inclusao, 4 - Alteracao, 5 - Exclusao.
				
				If lMsErroAuto
					MostraErro()
				Else
					//Alert("Título incluído com sucesso!")
				Endif

			ElseIf nlx == 2
				aArray := { { "E2_FILIAL"   , xFilial("SE2")   			 			, NIL },;
							{ "E2_PREFIXO"  , "SC"             			 			, NIL },;
							{ "E2_NUM"      , cFilSc+cNumSC                 		, NIL },;
							{ "E2_PARCELA"  , "B"            			 			, NIL },;
							{ "E2_TIPO"     , "PR"            			 			, NIL },;
							{ "E2_FORNECE"  , "208534"	         	 	 			, NIL },;
							{ "E2_LOJA"     , "01"       		   		 			, NIL },;
							{ "E2_NOMFOR"   , "RUCKHABER COMISSARIA DE DESPAC"   	, NIL },;
							{ "E2_NATUREZ"  , "6110001"    		   		 			, NIL },;
							{ "E2_EMISSAO"  , dDataBase	                    		, NIL },;
							{ "E2_VENCTO"   , aDtVenc[nlx]                  		, NIL },;
							{ "E2_VENCREA"  , aDtVenc[nlx]                  		, NIL },;
							{ "E2_VALOR"    , ((nValTit * 80) / 100)        		, NIL },;
							{ "E2_ORIGEM"   , "SOLICITA"                 			, NIL },;
							{ "E2_MOEDA"    , nMoeda                 				, NIL },;
							{ "E2_TXMOEDA"  , Iif(nTxMoeda == 1, 0,nTxMoeda)		, NIL },;
							{ "E2_VLCRUZ"   , (nTxMoeda * nValTit)     				, NIL },;
							{ "E2_HIST"     , "Filial:"+cFilSC+"-Numero SC:"+cNumSC , NIL }}

				SetFunName("FINA050")
				MsExecAuto({ |x,y,z| FINA050(x,y,z)}, aArray,, 3)  // 3 - Inclusao, 4 - Alteracao, 5 - Exclusao.

				If lMsErroAuto
					MostraErro()
				Else
					//Alert("Título incluído com sucesso!")
				Endif

			EndIf
		EndIf
	Next
	
Return (.T.)


//--------------------------------------------------------------------
/*/{Protheus.doc} EPRSCT
Rotina para exclusao dos titulos PR para Solicitação de Compras
@author Rodrigo Nunes
@since 08/12/2021
@version 1.0 
@type function
/*/
//--------------------------------------------------------------------

Static Function EPRSCT(cFilSC,cNumSC)
	//Local aArray := {}
	Local cQuery := ""
 	Private lMsErroAuto := .F.
	
	nModulo := 6

	DbSelectArea("SE2") 
	DbSetOrder(1)

	cQuery := " SELECT E2_FILIAL, E2_PREFIXO, E2_NUM, E2_PARCELA, E2_TIPO, E2_FORNECE, E2_LOJA FROM " + RetSqlName("SE2")
	cQuery += " WHERE E2_FILIAL = '"+xFilial("SE2")+"' "
	cQuery += " AND E2_PREFIXO = 'SC' "
	cQuery += " AND E2_TIPO = 'PR' "
	cQuery += " AND E2_NUM = '"+cFilSC+cNumSC+"' "
	cQuery += " AND D_E_L_E_T_ = '' "

	If Select("PRSC") > 0
		PRSC->(dbCloseArea())
	EndIf

	DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery) , 'PRSC', .T., .F.)

	While PRSC->(!EOF())
		If SE2->(DbSeek(PRSC->E2_FILIAL+PRSC->E2_PREFIXO+PRSC->E2_NUM+PRSC->E2_PARCELA+PRSC->E2_TIPO+PRSC->E2_FORNECE+PRSC->E2_LOJA)) //Exclusão deve ter o registro SE2 posicionado
			Reclock("SE2",.f.)
			SE2->(DBDELETE())
			SE2->(MSUNLOCK())
			//aArray := { { "E2_PREFIXO" , SE2->E2_PREFIXO , NIL },;
			//			{ "E2_NUM"     , SE2->E2_NUM     , NIL } }
			//MsExecAuto( { |x,y,z| FINA050(x,y,z)}, aArray,, 5)  // 3 - Inclusao, 4 - Alteração, 5 - Exclusão
			//If lMsErroAuto
			//	MostraErro()
			//Else
			//	Alert("Exclusão do Título com sucesso!")
			//Endif
		EndIf
		PRSC->(dbSkip())
	EndDo	
Return
