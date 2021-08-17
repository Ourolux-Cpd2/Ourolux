#INCLUDE "PROTHEUS.CH"

//--------------------------------------------------------------------
/*/{Protheus.doc} MT410INC 
Ponto de entrada no fim da gravação do Pedido de Venda, compatibilizado das funções do TMKVFIM

@author TOTVS Protheus
@since  09/10/15
@obs    Gerado por EXPORDIC - V.5.0.0.0 EFS / Upd. V.4.20.15 EFS
@version 1.0
/*/
//--------------------------------------------------------------------

User Function MT410INC()
	
	Local cBco       	:= ""
	Local nMargem     	:= 0
	Local nTotVen     	:= 0 
	Local nTotCus     	:= 0 
	Local nTotComis   	:= 0
	Local nValBall    	:= 0
	Local lBonif		:= .F. 
	Local cQuery        := ""
	Local nCPed        	:= 0
	Local nPesoL       	:= 0
	Local nPBruto      	:= 0
	Local nMarLiq     	:= 0
	Local cFilSC5		:= xFilial("SC5")//B4B.AL07092016
	Local cAviso        := ""	
	// Claudino - 08/12/15
	Local aTotImp       := {}
	Local lVenda        := ( M->C5_TIPO == "N" )      
	Local lDev	    	:= ( M->C5_TIPO == "D" )

	//Rotina Triyo pra gravação do total do pedido
	fTotPed()
	
	If IsInCallStack("U_TMKVFIM")
		Return( .T. )	
	EndIf
	
	// Rotina Automatica SFA
	If Type("L410Auto")!="U" .And. L410Auto
		If !U_xAuto410()
			Return (.T.)
		EndIf
	EndIf
	
	/* Rgras de negocios */

	//TRATAMENTO PARA LOTES UNICOS - B4B.AL07092016 
//	If SA1->(FieldPos("A1_XAVALOT")) > 0
//		U_B4BAVLOT(M->C5_FILIAL,M->C5_NUM)
//	EndIf
	//--FIM
	
	dbSelectArea("SA1")
	dbSetOrder(1)
	
	IF DbSeek(xFilial("SA1")+M->C5_CLIENTE+M->C5_LOJACLI) .And. lVenda	
		cBco := SA1->A1_BCO1
	EndIf


	DbSelectArea("SC5")
	DbSetOrder(1)
	
	MsSeek(xFilial("SC5")+M->C5_NUM)

	
	DbSelectArea("SC6")
	DbSetOrder(1)
	
	IF DbSeek(xFilial("SC6")+SC5->C5_NUM)
		
		While !EOF() .AND. SC6->C6_NUM == SC5->C5_NUM .AND. SC6->C6_FILIAL == xFilial("SC6") // CURITIBA
			
			DbSelectArea("SB1")
			DbSetOrder(1)
			
			If DbSeek(xFilial("SB1")+SC6->C6_PRODUTO)
				
				RecLock( "SC6", .F. )
				SC6->C6_CUSTD := SB1->B1_CUSTD
				If !SC5->C5_TIPO $ [ICP] .And. !SC6->C6_TES $ [502.503.510.523]
					nMargem := SC6->C6_PRCVEN
		 			nMargem /= SC6->C6_CUSTD
					nMargem -= 1
					nMargem *= 100
					nMargem := Round( nMargem / 3, 2 )		
			    Else
	      			nMargem := 0
			    End
	   	
			    nMargem := IIF( nMargem > 999.99,999.99, nMargem ) 
	   			
	   			SC6->C6_MARGEM := nMargem
	   			
				   
//	   			If SC5->C5_FILIAL == "01"
				//Sol.Fernando - 26/11/2020 - Andre Salgado - Validar se a TES Utiliza Estoque = "S"
				dbSelectarea("SF4")
				SF4->(dbSetOrder(1))
				If DbSeek(xFilial("SF4")+SC6->C6_TES)
					IF SF4->F4_ESTOQUE="S"

						If Localiza(SC6->C6_PRODUTO) //Se o Produto controla endereço
							//	RecLock('SC6',.F.) //Alterar o registro na tabela de itens.
							// Claudino - 04/04/16 - I1603-1514
							If Empty(SC6->C6_LOCALIZ) 
								SC6->C6_SERVIC := "001"
								SC6->C6_ENDPAD := PADR("DOCA",15)
							Endif
							//SC6->C6_TPESTR := "000001"
							//	MsUnlock() 
						EndIf
					Endif
				Endif

//	   			EndIF
	   			If Substr( SC6->C6_CF, 2, 3 ) $ '910' // Caso bonificaçao --> zerar a comissao 
	   				SC6->C6_COMIS1 := 0  	  
	    			SC6->C6_VLCOM1 := 0
	    			lBonif := .T. 
	   			Else
	   				lBonif := .F.
	   			EndIf
	   			
	   			MsUnlock()
			EndIf
			
			nTotVen   += SC6->C6_VALOR
		   	nTotCus   += ( SC6->C6_CUSTD * SC6->C6_QTDVEN )
		   	nTotComis += SC6->C6_VLCOM1
	
			DbSelectArea("SC6")
			DbSkip()
		EndDo
	EndIf
	

	// *****
	// Roberto Souza 24/02/2017
	// Executa a Inicialização das funlçoes fiscais para PV
	lFisIni := U_xMFisIni( SC5->C5_NUM )
	// *****

	/*
	Claudino - 08/12/15
	MaFisNFCab - Retorna um array contendo todos os impostos calculados na MATXFIS no 
	             momento da chamada da função com quebra por impostos + alíquotas
	*/
	aTotImp := MaFisNFCab()
	
	nTotVen  := nTotVen - IIF(ASCAN(aTotImp,{|x|x[1] == "ICM" }) == 0, 0,aTotImp[ASCAN(aTotImp,{|x|x[1] == "ICM" })][5]) - ;
	                      IIF(ASCAN(aTotImp,{|x|x[1] == "PS2" }) == 0, 0,aTotImp[ASCAN(aTotImp,{|x|x[1] == "PS2" })][5]) - ;
	                      IIF(ASCAN(aTotImp,{|x|x[1] == "CF2" }) == 0, 0,aTotImp[ASCAN(aTotImp,{|x|x[1] == "CF2" })][5])
	
	//_Margem := Round( ( ( _TotVen  / ( _TotCus + nValBall ) ) -1 ) * 100, 0 )
	nMargem := Round( ( ( nTotCus  / nTotVen ) -1 ) * 100, 2)
	nMargem *= -1
	nMargem /= 4
	nMarLiq := Round (( nTotCus / nTotVen ) * 100, 2)
	
	dbSelectArea("SC5")
	dbSetOrder(1)
	
	If DbSeek(xFilial("SC5")+SC5->C5_NUM)
	
	/*BEGINDOC
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Gera Cubagem do pedido                ³
	//³Campo especifico C5_XCUBPED           ³
	//³ WAR 23/05/2013                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	ENDDOC*/
	    
		If Select("CUB") > 0
			DbSelectArea("CUB")
			CUB->(DbCloseArea())
		EndIf
	
		cQuery := " SELECT SUM((SB5.B5_COMPR * SB5.B5_ALTURA * SB5.B5_LARG)* (C6_QTDVEN)) As CubPed "
		cQuery += " FROM " + RetSqlName("SC6") + " SC6 "
		cQuery += " INNER JOIN " + RetSqlName("SB1") + " SB1 ON SC6.C6_PRODUTO = SB1.B1_COD "
		cQuery += " INNER JOIN " + RetSqlName("SB5") + " SB5 ON SC6.C6_PRODUTO = SB5.B5_COD "
		cQuery += " WHERE SC6.D_E_L_E_T_ <> '*' AND " 
		cQuery += " SB5.D_E_L_E_T_ <> '*' AND "
		cQuery += " SB1.D_E_L_E_T_ <> '*' AND " 
		cQuery += " SC6.C6_FILIAL  = '" + SC5->C5_FILIAL  + "' AND "
		cQuery += " SC6.C6_CLI     = '" + SC5->C5_CLIENTE + "' AND "
		cQuery += " SC6.C6_LOJA    = '" + SC5->C5_LOJACLI + "' AND " 
		cQuery += " SC6.C6_NUM     = '" + SC5->C5_NUM     + "' AND " 
		cQuery += " SC6.C6_FILIAL  = '" + xFilial("SC6")  + "' AND "
		cQuery += " SB5.B5_FILIAL  = '" + xFilial("SB5")  + "' AND "
		cQuery += " SB1.B1_FILIAL  = '" + xFilial("SB1")  + "' AND "
		cQuery += " SB5.B5_FILIAL  = '" + xFilial("SB5")  + "' AND "
		cQuery += " SB1.B1_FILIAL  = '" + xFilial("SB1") + "' "
		
		//MEMOWRITE("E:\TESTESQL3.SQL",cQuery)
	      
		dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery), 'CUB' )
	    
	    nCPed := CUB->CubPed
	    
	    CUB->(DbCloseArea())
	    
	/*BEGINDOC
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Gera Peso Liquido e Bruto             ³
	//³Campos C5_PBRUTO/C5_PESOL             ³
	//³WAR 16/07/2013                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	ENDDOC*/
	
		If Select("PESO") > 0
			DbSelectArea("PESO")
			PESO->(DbCloseArea())
		EndIf
	
		cQuery := " SELECT SUM(SB1.B1_PESBRU * C6_QTDVEN) As PBRUTO "
		cQuery += " FROM " + RetSqlName("SC6") + " SC6 "
		cQuery += " INNER JOIN " + RetSqlName("SB1") + " SB1 ON SC6.C6_PRODUTO = SB1.B1_COD "
		cQuery += " WHERE SC6.D_E_L_E_T_ <> '*' AND SB1.D_E_L_E_T_ <> '*' AND " 

		cQuery += " SC6.C6_FILIAL  = '" + SC5->C5_FILIAL  + "' AND "
		cQuery += " SC6.C6_CLI     = '" + SC5->C5_CLIENTE + "' AND "
		cQuery += " SC6.C6_LOJA    = '" + SC5->C5_LOJACLI + "' AND " 
		cQuery += " SC6.C6_NUM     = '" + SC5->C5_NUM     + "' AND " 

		cQuery += " SB1.B1_FILIAL  = '" + xFilial("SB1")  + "' "
		cQuery += " GROUP BY SC6.C6_NUM "
	
		//MEMOWRITE("E:\TESTESQL3.SQL",cQuery)
	      
		dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery), 'PESO' )
	    
	    nPBruto := PESO->PBRUTO
	    
	    PESO->(DbCloseArea())   
		  
		cQuery := " SELECT SUM(SB1.B1_PESO * C6_QTDVEN) As PESOL "
		cQuery += " FROM " + RetSqlName("SC6") + " SC6 "
		cQuery += " INNER JOIN " + RetSqlName("SB1") + " SB1 ON SC6.C6_PRODUTO = SB1.B1_COD "
		cQuery += " WHERE SC6.D_E_L_E_T_ <> '*' AND SB1.D_E_L_E_T_ <> '*' AND " 

		cQuery += " SC6.C6_FILIAL  = '" + SC5->C5_FILIAL  + "' AND "
		cQuery += " SC6.C6_CLI     = '" + SC5->C5_CLIENTE + "' AND "
		cQuery += " SC6.C6_LOJA    = '" + SC5->C5_LOJACLI + "' AND " 
		cQuery += " SC6.C6_NUM     = '" + SC5->C5_NUM     + "' AND " 

		cQuery += " SB1.B1_FILIAL  = '" + xFilial("SB1")  + "' "
		cQuery += " GROUP BY SC6.C6_NUM "
	
		//MEMOWRITE("E:\TESTESQL3.SQL",cQuery)
	      
		dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery), 'PESO' )
	    
	    nPesoL := PESO->PESOL
		
		PESO->(DbCloseArea())

	    
	    U_VldCli(M->C5_CLIENTE,M->C5_LOJACLI,@cAviso) 
                           
		cUserInc := USRRETNAME( RETCODUSR() )
		
		If Empty(cUserInc)
			cUserInc := Posicione("SA3",1,xFilial("SA3")+SC5->C5_VEND1,"A3_NREDUZ")
		EndIf
	    
	    RecLock( "SC5", .F. )
		
		SC5->C5_XCUBAGM := nCPed
		SC5->C5_PESOL   := nPesoL 
		SC5->C5_PBRUTO  := nPBruto

		SC5->C5_TOTVEN  := nTotVen
		SC5->C5_TOTCUS  := IIF(nTotCus > 999999.99999,999999.99999,nTotCus) // Claudino 16/05/16 - I1604-2102
		SC5->C5_VALBALL := nValBall
		SC5->C5_TOTMAR  := nMargem 
		SC5->C5_MARLIQ  := nMarLiq
		SC5->C5_TOTCOM  := nTotComis
		SC5->C5_PEDREP  := cUserInc
		SC5->C5_TIPLIB  := "2" 

		If lDev
			SC5->C5_BANCO	:= cBco		
			SC5->C5_AVISO   := cAviso
		End
		
		// Reset C5_REIMP caso Nosso Carro (C5_TIPOENT = 2) 
		SC5->C5_REIMP := IIF (SC5->C5_TIPENT == "2",0,SC5->C5_REIMP) 	
		
//		If SUA->UA_FILIAL == "01" 
			dbSelectarea("SC6")
			SC6->(dbSetOrder(1))
			// Claudino - 04/04/16 - I1603-1514
			If DbSeek(xFilial("SC6")+SC5->C5_NUM)
				If Empty(SC6->C6_LOCALIZ) .And. SC5->C5_TIPO <> "I" 

					//Sol.Fernando - 26/11/2020 - Andre Salgado - Validar se a TES Utiliza Estoque = "S"
					dbSelectarea("SF4")
					SF4->(dbSetOrder(1))
					If DbSeek(xFilial("SF4")+SC6->C6_TES)
						IF SF4->F4_ESTOQUE="S"
							SC5->C5_TPCARGA := "1"
							SC5->C5_GERAWMS := "2"
						else
							SC5->C5_TPCARGA := "2"
							SC5->C5_GERAWMS := "2"							
						Endif
					Endif
		        EndIf
		    EndIf
//		EndIf
		
		SC5->C5_XASSIST := GetAdvFVal("SA3","A3_XASSIST",xFilial("SA3")+SC5->C5_VEND1,1,"")  // Claudino - 29/02/16

		If lBonif
			SC5->C5_COMIS1 := 0 // Caso bonificaçao --> Zerar a comissao	
		EndIf

		If U_xSac()
			SC5->C5_TIPENT  := "1"		
			SC5->C5_GERAWMS := "2"		
			SC5->C5_TPCARGA := "2"
		EndIf  
	
		MsUnlock()
		
	EndIf

	// Log de rastreio
	cLogC5 := "Hora 	: " + Time() + CRLF+ CRLF              
	cLogC5 += "Venda	: " + cValToChar(nTotVen) + CRLF
	cLogC5 += "Custo	: " + cValToChar(nTotCus) + CRLF
	cLogC5 += "Margem	: " + cValToChar(nMargem) + CRLF
	cLogC5 += "MargeLiq	: " + cValToChar(nMarLiq) + CRLF
	cLogC5 += "aTotImp	: " + VARINFO ( "_" , aTotImp , 0 , .T. , )+CRLF 

	MemoWrite("\INTRJ\PEDIDO\"+SC5->C5_NUM+"-001.log",cLogC5)  

	MaFisEnd()
	
Return()

//----------------------------------------------------------------
/*/{Protheus.doc} fTotPed
Gravação do total do pedido de venda.

@author Henrique Ghidini
@since 12/05/2020
@version 1.0
/*/
//----------------------------------------------------------------

Static Function fTotPed()

Local nTotVen   := 0
Local nValIpi   := 0
Local nValST    := 0
Local nItem     := 1
Local nTotIpi   := 0
Local nTotSt    := 0

    DbSelectArea("SC5")
	SC5->(DbSetOrder(1))
	
	DbSelectArea("SC6")
    SC6->(DbSetOrder(1))

	If SC5->(DbSeek(xFilial("SC5") + M->C5_NUM))
    
		If SC6->(DbSeek(xFilial("SC6")+SC5->C5_NUM))
			
			While !SC6->(EOF()) .AND. SC6->(C6_FILIAL+C6_NUM) == SC5->(C5_FILIAL+C5_NUM)

				nTotVen += SC6->C6_VALOR

				MaFisIni(SC5->C5_CLIENTE,SC5->C5_LOJACLI,"C","N",SC5->C5_TIPOCLI,MaFisRelImp("MTR700",{"SC5","SC6"}),,,"SB1","MTR700")
				MaFisAdd(SC6->C6_PRODUTO,SC6->C6_TES,SC6->C6_QTDVEN,SC6->C6_PRCVEN,SC6->C6_VALDESC,"","",0,0,0,0,0,(SC6->C6_QTDVEN*SC6->C6_PRCVEN),0,0,0)
				
				nValIpi := MaFisRet(nItem,"IT_VALIPI")
				nValST  := MaFisRet(nItem,"IT_VALSOL")
				
				MaFisLoad("IT_VALIPI"	, nValIpi	, nItem)
				MaFisLoad("IT_VALSOL"	, nValST	, nItem)

				nTotIpi += nValIpi
				nTotSt  += nValST

				nItem++
				
				SC6->(DbSkip())

			End

			MaFisEnd()

			SC5->(RecLock("SC5",.F.))

				SC5->C5_XTOTPV := nTotVen + nTotIpi + nTotSt

			SC5->(MsUnlock())

		EndIf

	EndIf
    
Return()
