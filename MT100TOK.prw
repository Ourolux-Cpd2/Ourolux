#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±?Programa     ?MT100TOk     ?Autor ?Marcos Gomes - TAGGS  ?Data ? 09/09/2013 º±?
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±?Descricao    ?Rotina de Importacao de TABELA DE PRECO                           º±?
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±?Uso          ?Clientes Microsiga-Protheus                                       º±?
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±?Autor        ?Marcos Gomes - NEWBRIDGE                                          º±?
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±?  DATA       ?Alteracao                                                         º±?
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function MT100TOK()

	Local lRet	:= .T.
	Local nItem := 0
	Local aArea	:= GetArea()
	
	// Variaveis Customizacao Marcos TAGGS.
	LOCAL nValBrut	:= 0.00		// MGOMES 23/07/2013 - Valor Bruto
	LOCAL nValMark	:= 0.00		// Valor marcado
	LOCAL nPOS_TOT	:= Ascan( aHeader,{|x| AllTrim( x[2] ) == "D1_TOTAL" })
	LOCAL nPOS_PC	:= Ascan( aHeader,{|x| AllTrim( x[2] ) == "D1_PEDIDO" })
	
	// Variavel Rodrigo Franco 26/10/2016
	Local cTpCte    :=  " "
	// 
	
	// Variavel Rodrigo Franco 03/11/2016
	Local cChvNfe   :=  " "
	LOCAL aFILIAL	:= {}
	Local nRecEmp 	:= SM0->(Recno())
	//
	
	PRIVATE nF4For    := 0
	PRIVATE lPendente := .T.
	PRIVATE lPEDCOMIS := .T.
	
	PUBLIC aF4For	  := {}		// Array com os dados dos titulos
	
	If cmodulo <> 'FIS' .And. funname() != 'SPEDNFE' .And. !l103Auto
		
		aArea	:= GetArea()
		
		If Inclui .Or. Altera  // Inclusao ou classification
			
			// Mauricio Aureliano - 20/03/2018 
			// Chamado: I1711-545 - Gatilho UF Origem 
			If (Alltrim(CTIPO) $ ("NIPC"))
				cEst := Posicione("SA2",1,xFilial("SA2") + CA100FOR + CLOJA,"A2_EST")
				If Trim(CUFORIG) <> Trim(cEst)
					CUFORIG := Trim(cEst)
					ApMsgStop('O Estado do Fornecedor foi atualizado, favor verificar os dados digitados!','MT100TOK 1')
					lRet	:= .F.
				EndIf
			Else
				cEst := Posicione("SA1",1,xFilial("SA1") + CA100FOR + CLOJA,"A1_EST")
				If Trim(CUFORIG) <> Trim(cEst)
					CUFORIG := Trim(cEst)
					ApMsgStop('O Estado do Cliente foi atualizado, favor verificar os dados digitados!','MT100TOK 2')
					lRet	:= .F.
				EndIf
			EndIf
			
			If (cFormul == 'S' .And. Alltrim(cEspecie) <> 'SPED') .And. lRet
				ApMsgStop('Especie do Documento de Entrada deve ser SPED!', 'MT100TOK 3' )
				lRet := .F.
			EndIf
			
			/*
			If aNfeDanfe[5] <= 0 .And. lRet .And. Alltrim(cEspecie) $ 'SPED.CTE'
			ApMsgStop('Informar a Quantidade de Volumes.( Inf. Danfe )!', 'MT100TOK 4' )
			lRet := .F.
			EndIf
			*/
			// Maurício Aureliano - 11/06/2018
			/*
			
			If Empty (aNfeDanfe[13]) .And. lRet .And. Alltrim(cEspecie) $ 'SPED.CTE' .And. cFormul == 'N'
				ApMsgStop('Favor alimentar o campo Chave NFE.( Inf. Danfe )!', 'MT100TOK 5' )
				lRet := .F.
			EndIf
			*/
			If Empty (aNfeDanfe[1]) .And. lRet .And. cFormul == 'S' .And. Alltrim(cEspecie) = 'SPED'
				ApMsgStop('Transportadora do Doc. de Entrada, Favor preencher.( Inf. Danfe )!', 'MT100TOK 6' )
				lRet := .F.
			EndIf
			
			If Empty (aNfeDanfe[4]) .And. lRet .And. cFormul == 'S' .And. Alltrim(cEspecie) = 'SPED'
				ApMsgStop('Espécie do Doc. Entrada, Favor preencher.( Inf. Danfe ) !', 'MT100TOK 7' )
				lRet := .F.
			EndIf
			
			If aNfeDanfe[5] <= 0 .And. lRet .And. cFormul == 'S' .And. Alltrim(cEspecie) = 'SPED'
				ApMsgStop('Informar a Quantidade de Volumes.( Inf. Danfe )!', 'MT100TOK 8' )
				lRet := .F.
			EndIf
			
			
			// Rodrigo Franco 26/10/2016
			cTpCte := Alltrim(aNFeDANFE[18]) //Campo SF1->F1_TPCTE
			If Alltrim(cEspecie) == 'CTE' .and. cTpCTE == ''
				ApMsgStop('A Espécie de Documento = "CTE" e o campo "Tipo CT-e" na pasta "Informações da DANFE" está em branco. Favor preencher!', 'MT100TOK')
				lRet := .F.
			EndIf
			
			// Rodrigo Franco 03/11/2016
			cChvNfe := Alltrim(aNFeDANFE[13]) //Campo SF1->F1_CHVNFE
			If !Empty(cChvNfe) .And. lRet .And. Alltrim(cEspecie) $ 'SPED.CTE' .And. cFormul == 'N'
				
				DBSELECTAREA("SM0")
				DBSETORDER(1)
				DBGOTOP()
				WHILE !EOF()
					IF SM0->M0_CODIGO == "01"
						AADD(aFILIAL,SM0->M0_CODFIL)
						//  AADD(aFILIAL,"01")    //  AADD(aFILIAL,"02")    //  AADD(aFILIAL,"03")    //  AADD(aFILIAL,"04")    //  AADD(aFILIAL,"05")
					ENDIF
					DBSKIP()
				END
				SM0->(dbgoto(nRecEmp))
				FOR X:=1 TO LEN(aFILIAL)
					DbSelectArea("SF1")
					DbSetOrder(8)
					If DbSeek(aFILIAL[X]+cChvNfe)
						If(!Empty(SF1->F1_STATUS))
							_cFiliF := F1_FILIAL
							_cNotaF := F1_DOC
							_cSeriF := F1_SERIE
							_cFornF := F1_FORNECE
							_cLojaF := F1_LOJA
							ApMsgStop('Esta Chave da NF já foi digitada na nota '+ _cNotaF +' Serie '+ _cSeriF + ' Filial '+ _cFiliF + chr (13) + chr (10) +'Fornecedor '+ _cFornF +' Loja '+ _cLojaF +'. Favor preencher com uma Chave Correta!', 'MT100TOK')
							lRet := .F.
							Exit
						EndIf
					EndIf
				Next
			EndIf
			DbSelectArea("SF1")
			DbSetOrder(1)
			//
			
			// Motivo de Devolução - 30/05/12 referente ao Botão Mais Inf na ABA Danfe(MT103DCF)
			If (Alltrim(CTIPO) == "D")
				nItem := ASCAN(aDanfeComp, {|aX| aX[1] == "F1_MOTCANC"})
				If (nItem > 0)
					If (Empty(aDanfeComp[nItem][2]))
						ApMsgStop('Favor informar o Motivo da Devolução!', 'MT100TOK 11' )
						lRet := .F.
					Else
						dbSelectArea("SAG")
						dbSetOrder(1)
						If !MsSeek(xFilial("SAG") + Alltrim(aDanfeComp[nItem][2]))
							ApMsgStop('Motivo de Devolução informado invalido!', 'MT100TOK 12' )
							lRet := .F.
						Else
														
							// Roberto Souza - 25/09/2017
							// I1709-1438 - Motivo devolução
							//
							cMotDev := AllTrim( GetMv("FS_M100DEV",,"6003/6005/6006") )
						// /*	// WAR 14/04/2021
							For z := 1 To Len( aCols )
								If !aCols[z][Len( aHeader ) + 1]
									// Claudino - 08/02/17 - I1701-1374
									//If aCols[z][3] <> "30" //desabilitado - 17/11/20 - Sol. Gilmar/Sumaia/Fernando
									If !(aCols[z][3] $ "20,21,30,31,32") //Criado Andre Salgado, para atender novos locais
										If Alltrim(aDanfeComp[nItem][2]) $ cMotDev //Alltrim(aDanfeComp[nItem][2]) == "6003"
											ApMsgStop('O(s) Motivo(s) de Devolução '+cMotDev+' só deve(m) ser usado(s) quando for armazem 30!', 'MT100TOK' )
											lRet := .F.
											Exit
										EndIf
									Else
										If !(Alltrim(aDanfeComp[nItem][2]) $ cMotDev) //Alltrim(aDanfeComp[nItem][2]) <> "6003"
											ApMsgStop('Só é permitido informar o armazem 30 quando o(s) Motivo(s) de Devolução for(em) '+cMotDev+'!', 'MT100TOK' )
											lRet := .F.
											Exit
										EndIf
									EndIf
								EndIf
							Next z
					  //	*/ // WAR 14/04/2021
						EndIf
					
					EndIf
					
					
				Else
					ApMsgStop('Favor informar o Motivo da Devolução!', 'MT100TOK 15' )
					lRet := .F.
				EndIf
			EndIf
			
		EndIf
		
		If ALLTRIM(SED->ED_CODIGO) $ GETMV("FS_SEDNAT")
			If cTipo <> 'N'
				ApMsgStop('Essa Natureza ?especifica para Notas de Comissão, favor informar a Natureza correta!', 'MT100TOK 16' )
				lRet := .F.
			EndIf
			
			cPED := aCols[N][nPOS_PC]
			IF EMPTY(cPED)
				/*
				WHILE EMPTY(cPED)
					ApMsgStop('Essa Nota ?especifica de Comissão, favor informar Pedido de Compra correspondente!', 'MT100TOK 17' )
					A103FORF4(.T.,{},.F.,.F.,{},{},{},{})
					cPED := aCols[N][nPOS_PC]
					IF !lPEDCOMIS
						EXIT
					ENDIF
				END
				*/
				ApMsgStop('Para Notas de Comissão, ?necessário informar Pedido de Compra correspondente!', 'MT100TOK 18' )
				lRet := .F.
			ENDIF
			
			dbSelectArea("SA3")
			dbOrderNickname("VENDFORN")
			If !(SA3->(dbSeek(xFilial("SA3")+ca100for+cLoja)))
				ApMsgStop('Essa Natureza ?especifica para Notas de Comissão, favor informar um Fornecedor que seja Representante!', 'MT100TOK 19' )
				lRet := .F.
			EndIf
						
			// Customizacao Marcos TAGGS.
			If lRet
				
				nValBrut	:= 0.00
				FOR Ur := 1 TO Len( aCols )
					If !aCols[Ur][LEN( aHeader ) + 1]
						nValBrut	+= aCols[Ur][nPOS_TOT]
					EndIf
				NEXT Ur
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
				//?Chama a Funcao de selecao de Titulo(s) Gerado(s) pela rotina MATA530 - Atualizacao de Pagamento de Comissao		  ?
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
				lRet := U_TT__( cNFiscal, cSerie, cA100For, cLoja, nValBrut )
				//³ Chama a Funcao de selecao de Titulo(s) Gerado(s) pela rotina MATA530 - Atualizacao de Pagamento de Comissao		  ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				lRet := U_TT__( cNFiscal, cSerie, cA100For, cLoja, nValBrut )
				
				If !EMPTY( aF4For )
					FOR Ff := 1 To Len( aF4For )
						If aF4For[Ff][1] .and. !lPendente
							nValMark	+= aF4For[Ff][9]
						EndIf
					NEXT Ff
				EndIf
				
				If lPendente .and. EMPTY( nValMark )
					ALERT( "Essa Nota de Comissão deve ser amarrada com o Contas a Pagar da mesma! " )
					lRet := .F.
				Else
					lRet := .T.
				EndIf
				
			EndIf
			
		EndIf
		
		RestArea(aArea)
	EndIf
	
Return (lRet)


//*******************//
//  Rotina MA103F4L  //
//*******************//
User Function MA103F4L()

	Local lRet := .T.
	
	If Len(AF4FOR) > 0
		lPEDCOMIS := .T.
	Else
		lPEDCOMIS := .F.
	EndIf

Return lRet
