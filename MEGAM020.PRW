#Include "Rwmake.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MEGM020   ºAutor  ³                    º Data ³  07/06/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Esta rotina tem por objetivo trazer de forma automática     º±±
±±º          ³o TES no orçamento do Televendas conforme amarração no      º±±
±±º          ³  cadastro de operações. O TES será sugerido no campo do    º±±
±±º          ³  item quando o codigo do produto for informado.            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP8                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function MEGAM020(cProduto,cTipoPed,cCodCli,cCodLoja,cTes)

Local aArea    := GetArea()
Local aAreaSB1 := SB1->(GetArea()) 
Local cTesInd  := ""
Local cVndInt  := ""
Local cQuery   := ""
Local cTipoCli := SA1->A1_TIPO
Local cEst     := SA1->A1_EST
Local cGrpFis  := ""
Local cProd    := ""

dbSelectArea("SB1")
dbsetorder(1) // B1_FILIAL, B1_COD

If SA1->A1_TIPO == "F"

	If SA1->A1_GRPTRIB == "001"
	
		cTipoCli := "A"		
	
	ElseIf SA1->A1_SATIV1 $ "INDUST|FABLUM"
	
		cTipoCli := "B"

	Else
	
		cTipoCli := "F"   /*            */
	//	cTipoCli := " "   

	EndIf

EndIf

If cEst == 'MT' .And. SA1->A1_GRPTRIB == "004" 
	cTipoCli := "M"
EndIf


If dbSeek(xFilial("SB1")+cProduto) 
	
	cGrpFis := SB1->B1_GRPFIS
	cProd   := SB1->B1_COD  
	
	If Select("TRB") > 0
		DbSelectArea("TRB")
		TRB->(DbCloseArea())
	EndIf    
	
	cQuery := " SELECT * FROM " + RetSqlName("UB1") + " UB1   "
	cQuery += "	WHERE UB1_FILIAL   = '" + xFilial("UB1") + "' "
	cQuery += "   AND ( UB1_GRPFIS = '" + cGrpFis        + "' " 
	cQuery += "   OR    UB1_GRPFIS = ' '  )                   "
	cQuery += "   AND   UB1_TIPO   = '" + cTipoCli       + "' "
	cQuery += "   AND ( UB1_EST    = '" + cEst           + "' " 
	cQuery += "   OR    UB1_EST    = '**' )                   "
	cQuery += "   AND D_E_L_E_T_ <> '*' "
        
	//MEMOWRITE("E:\TESTESQL.SQL",cQuery)

	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TRB",.F.,.T.)
	
	TRB->(DbGoTop())
		
	While TRB->(!Eof())
		If UB1_EST == cEst .And.;
			TRB->UB1_PROD == cProd     
			
			cTesInd := TRB->UB1_TES
			Exit	
			
		EndIf 
		TRB->(DbSkip()) 
	EndDo
		
	If Empty(cTesInd)
		TRB->(DbGoTop())
		While TRB->(!Eof())
			If TRB->UB1_EST == '**' .And.;
			   TRB->UB1_PROD == cProd
					
				cTesInd := TRB->UB1_TES
				Exit
				
			EndIf
			TRB->(DbSkip())
		EndDo
	EndIf

	If Empty(cTesInd)
		TRB->(DbGoTop())
		While TRB->(!Eof())
			If TRB->UB1_EST == cEst .And.;
				TRB->UB1_GRPFIS == cGrpFis 
					
				cTesInd := TRB->UB1_TES
				Exit	
				
			EndIf 
			TRB->(DbSkip()) 
		EndDo
	EndIf
		
	If Empty(cTesInd)
		TRB->(DbGoTop())
		While TRB->(!Eof())
			If TRB->UB1_EST == '**' .And.;
				TRB->UB1_GRPFIS == cGrpFis
				
				cTesInd := TRB->UB1_TES
				Exit
			
			EndIf
			TRB->(DbSkip())
		EndDo
	EndIf
		
	TRB->(DbCloseArea()) 
		
EndIf 

If Empty(AllTrim(cTesInd)) 
	
	If IsInCallStack("MATA410") .And. !L410Auto 
		MsgAlert("O Produto nao possui TES cadastrado, Por favor verificar !","Atencao")
	ElseIf IsInCallStack("TMKA271") .And. !lTk271Auto
		MsgAlert("O Produto nao possui TES cadastrado, Por favor verificar !","Atencao")
	EndIf
	
EndIf

RestArea(aArea)
RestArea(aAreaSB1) 

Return(cTesInd)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MEGAM020  ºAutor  ³Microsiga           º Data ³  07/26/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Avalia se tem icms solidario                               º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function AvalSolid(cProduto,cTipoPed,cCodCli,cCodLoja)

Local lRet	   		:= .F.
Local _cEstado		:= SuperGetMv("MV_ESTADO")	// Estado da Filial Eletromega
Local cGrpTrib     	:= ""	// Grupo Trib Produto
Local cIcmSol		:= 0    // Margem de lucro de produto
Local cGrpCli      	:= ""   // Grupo cliente
Local _cEstDest     := ""
Local _nPicment		:= 0
Local aAreaSF7		:= SF7->(GetArea())
Local aAreaSB1		:= SB1->(GetArea())
Local aAreaSA1		:= SA1->(GetArea())
Local aArea	   		:= GetArea()

If (cTipoPed $ SuperGetMV("MV_TPSOLCF")) //If (cTipoPed $ "R#S#F")$SuperGetMV("MV_TPSOLCF")
	
	DbSelectArea("SA1")
	DbSetorder(1)
	
	If DbSeek(xFilial("SA1")+cCodCli+cCodLoja)
	
		cGrpCli    	:= SA1->A1_GRPTRIB
		_cEstDest	:= SA1->A1_EST
		
	EndIf
	
	DbSelectArea("SB1")
	Dbsetorder(1)

	If DbSeek(xFilial("SB1")+cProduto)

		cIcmSol  	:= SB1->B1_PICMRET	// ML saida 
		cGrpTrib 	:= SB1->B1_GRTRIB
		_nPicment	:= SB1->B1_PICMENT	// ML Entrada

	EndIf
		
	If (_cEstado == "SP" .And. _cEstDest == "SP" .And. _nPicment <> 0)
	    // Lampadas/reatores/pilhas/baterias Nao Ourolux cujo solidario foi pagou na entrada
		lRet := .T. 

	ElseIf (_cEstado == "PR" .And. _cEstDest == "PR" .And. _nPicment <> 0)
	    // Lampadas/reatores/pilhas/baterias Nao Ourolux cujo solidario foi pagou na entrada
		lRet := .T.
			
	ElseIf !Empty(cIcmSol)  // ML Produto > 0 ----> Tem solidario
		
		lRet := .T.
	
	Else                // ML Produto = 0, Verifique O grupo Tributario
	
		If !Empty(cGrpTrib)  
			
			DbSelectArea("SF7")
			DbSetOrder(1)
			DbSeek(xFilial("SF7")+ cGrpTrib + cGrpCli)
					
			While ( !Eof() .And. SF7->F7_FILIAL == xFilial("SF7") .And.;
		    		SF7->F7_GRTRIB == cGrpTrib .And. ;
					SF7->F7_GRPCLI == cGrpCli )
					
				If ( SF7->F7_EST == _cEstDest .Or. SF7->F7_EST == "**") .And.;
					( cTipoPed == SF7->F7_TIPOCLI .Or. SF7->F7_TIPOCLI == "*")		
              		
              		If ( !Empty(SF7->F7_MARGEM) )  // Tem margem de Lucro
              		
                       		lret := .T.
                       		
                   	EndIf	
                   	
                   	Exit
               	
               	EndIf
               	
				DbSkip()
				
			EndDo
			
		EndIf
		
	EndIf // Else
	
EndIf // MV_TPSOLCF

RestArea(aAreaSF7)
RestArea(aAreaSB1)
RestArea(aAreaSA1) 
RestArea(aArea)

Return(lRet)

// Function usado para gerar o Codigo Fiscal

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MEGAM020  ºAutor  ³Microsiga           º Data ³  05/19/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function GeraCFO(cCodCli,cCodLoja,cTes)

Local _aArea	 := GetArea()					// Salva a area atual
Local _cTipoCli  := ""							// variavel para identificar o TIPO do cliente / prospect
Local _cEstado   := SuperGetMv("MV_ESTADO")		// Estado atual da empresa usuaria
Local _cAlias    := "" //IIF(lProspect,"SUS","SA1")	// alias do SA1 ou SUS	
Local _cEstCli   := ""							// Estado do cliente
Local _aDadosCFO := {}							// Array para a funcao fiscal		
Local _cRet	     := ""
Local _lTesTit   := ""							// Retorno para o campo de CFO

If IsInCallStack("MATA410") //FunName() $ "MATA410.#M410FIL.MTRCFIL" 

	lProspect := .F.
	
EndIf

_cAlias    := IIF(lProspect,"SUS","SA1")

DbSelectArea( _cAlias )
DbSetOrder( 1 )
If MsSeek( xFilial( _cAlias ) + cCodCli + cCodLoja )

   _cTipoCli := IIF(lProspect,SUS->US_TIPO,	SA1->A1_TIPO)
   _cEstCli  := IIF(lProspect,SUS->US_EST,	SA1->A1_EST)
   
EndIf                                                 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Valida o bloqueio de registro da TES utilizada                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistCpo("SF4", cTes)
	
	DbSelectarea("SF4")
	DbSetorder(1)
	If MsSeek( xFilial( "SF4" ) + cTes )
	
		If SF4->F4_DUPLIC == "S"
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Se a TES nao estiver bloqueada valida se a quantidade pode ser igual a 0,00  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	        If MaTesSel(cTes)
	        
				_lTesTit := .F.				
				
			Else
			
				_lTesTit := .T.	
				
			EndIf
			
		Else
		
			_lTesTit := .F.
			
		EndIf
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Preenche o CFO                                        ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If cPaisLoc!="BRA"
		
			_cRet := Alltrim( SF4->F4_CF )
			
		Else
		
			If (_cTipoCli!="X")
			
				If (_cEstCli == _cEstado)
				
					_cRet := SF4->F4_CF
					
				Else
				
					_cRet := "6" + Subs( SF4->F4_CF,2,Len( SF4->F4_CF ) - 1 ) 
					
				EndIf
				
			Else
				
				_cRet := "7" + Subs( SF4->F4_CF,2,Len( SF4->F4_CF ) - 1 ) 	
				
			EndIf	

			Aadd(_aDadosCfo,{"OPERNF"	,"S" } )
			Aadd(_aDadosCfo,{"TPCLIFOR"	,_cTipoCli } ) //_cTipoCli
			Aadd(_aDadosCfo,{"UFDEST"	,_cEstCli } )
			_cRet :=  MaFisCfo(,SF4->F4_CF,_aDadosCfo)
            
		EndIf
		
	EndIf
	
EndIf
	
RestArea( _aArea )

Return( _cRet )