#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TT_.CH"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡…o      ³ TT_           ³ Autor ³ Marcos Gomes (TAGGS)     ³ Data ³  05/07/2013  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡…o   ³ Busca as comissoes que foram geradas ou pagas que ainda nao foram      ³±±
±±³             ³ recebidas a nota fiscal de acerto da comissao.                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso         ³ Generico                                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
USER FUNCTION TT__( cDOCSF1, cSERSF1, cFORSF1, cLOJSF1, nValorBruto )


LOCAL aAREA_ATU		:= GETArea()					// Salva a area atual do Sistema
LOCAL aAREA_SA2		:= SA2->( GetArea() )			// Salva a area do SA2 - Fornecedores
LOCAL aAREA_SE2		:= SE2->( GetArea() )			// Salva a area do SE2 - Contas a Pagar
LOCAL aAREA_SF1		:= SF1->( GetArea() )			// Salva a area do SF1 - Cabecalho da Nota Fiscal de Entrada

LOCAL oOk        	:= LoadBitMap(GetResources(), "LBOK")			// Botao Ok
LOCAL oNo        	:= LoadBitMap(GetResources(), "LBNO")			// Botao Cancelar
LOCAL nOPc		 	:= 0
Local nLin			:= 0

LOCAL aTitCampos 	:= {}
LOCAL nF4For     	:= 0
LOCAL aRecSD2    	:= {}
LOCAL aTitCampos 	:= {}
LOCAL aConteudos 	:= {}
LOCAL cNomeFor   	:= ""

LOCAL lF060Mark 	:= .f.

//LOCAL cNaturez		:= PADR( SUPERGETMV( "FS_SEDNAT",, "COMISSAO" ), TAMSX3("E2_NATUREZ")[1] )		// Natureza dos titulos de comissao
LOCAL lConsistVal	:= SUPERGETMV( "FS_VALIDAV",, .t. )												// Indica se deve ou nao consistir o valor marcado

LOCAL cIndexSE2 	:= CriaTrab(nil,.f.)
LOCAL dIndexSE2 	:= "E2_FILIAL+E2_FORNECE+E2_LOJA+E2_PREFIXO+E2_NUM+E2_PARCELA"

LOCAL aCamposBrw	:= {}
LOCAL cStartPath	:= GetSrvProfString("Startpath","")													// Path inicial do Protheus \SYSTEM

LOCAL lFechou 		:= .f.
//LOCAL lPendente		:= .f.

PRIVATE cCadastro	:= OemToAnsi( STR0001 ) //"Documento de Entrada"
PRIVATE aBackSD1    := {}
PRIVATE aBackSDE    := {}

PRIVATE cMarca   	:= GetMark( )
PRIVATE lInverte 	:= .F.
PRIVATE oValor, oPrazoMed, oQtda, oVlBruto

//PRIVATE aF4For		:= {}					// Array com os dados dos titulos
PRIVATE nVar 		:= 0.00					// Valor total do(s) titulo(s) marcado(s)
PRIVATE nQtde		:= 0					// Quantidade de Titulo(s) marcado(s)

		// Claudino 09/06/15 Comentei o RecLock
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ (SED) - Cria a Natureza financeira padrao                ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		//DBSelectArea("SED")
		//DBSetOrder(1)
		//If !DBSeek( xFilial("SED") + cNaturez )
		//		RECLOCK( "SED", .t. )
		//					SED->ED_FILIAL 		:= xFilial("SED")
		//					SED->ED_CODIGO		:= PADR( cNaturez, TAMSX3("ED_CODIGO")[1] )
		//					SED->ED_DESCRIC		:= "Natureza Financeira para Comissao"
		//		MSUNLOCK()
		//EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Monta o Array com os Campos do Browse                    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		//                            Check ListBox // 1
		AADD( aCamposBrw, "E2_PREFIXO" 	)			// 2
		AADD( aCamposBrw, "E2_NUM"		)			// 3
		AADD( aCamposBrw, "E2_PARCELA" 	)			// 4
		AADD( aCamposBrw, "E2_TIPO"		)			// 5
		AADD( aCamposBrw, "E2_EMISSAO"	)			// 6
		AADD( aCamposBrw, "E2_VENCTO"	)			// 7
		AADD( aCamposBrw, "E2_VENCREA"	)			// 8
		AADD( aCamposBrw, "E2_VALOR"	)			// 9
		AADD( aCamposBrw, "E2_VALLIQ"	)			// 10 - Claudino - 22/09/2017 - Ajuste para titulos compensados ( TIPO DP X NDF )
		AADD( aCamposBrw, "E2_IRRF"		)			// 11													
		AADD( aCamposBrw, "E2_ISS"		)			// 12
		AADD( aCamposBrw, "E2_INSS"		)			// 13

		//cCampo := "A1_COD"
		//cDESCRIC    := GetSx3Cache( cCampo , "X3_TITULO" 	)
		//cTEXTE 	  	:= GetSx3Cache( cCampo , "X3_CAMPO" 	)
		//cTipo     	:= GetSx3Cache( cCampo , "X3_TIPO"	)
		//nTamanho  	:= GetSx3Cache( cCampo , "X3_TAMANHO"	)

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Seleciona a Descricao do Campo de cordo com a LINGUAGEM  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		DO CASE 
				CASE __Language == "ENGLISH"
						cDescriSX3	:= "X3_TITENG"
				CASE __Language == 'SPANISH'
						cDescriSX3	:= "X3_TITSPA"
				OTHERWISE 
						cDescriSX3	:= "X3_TITULO"
		ENDCASE 

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ (SX3) Alimenta a(s) Descricao(oes) do(s) Campo(s) do Browse                  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		AADD( aTitCampos, " " )											// Array que Controla o(s) titulo(s) do(s) campo(s) do MBrowse
		cLine 		:= "{If(aF4For[oListBox:nAt][1],oOk,oNo), "			// Code block que monta a MBRowse

		FOR Yu := 1 To Len( aCamposBrw ) + 1
				If Yu > 1
						If !EMPTY( aCamposBrw[Yu-1] )
							DBSelectArea("SX3")
							DBSetOrder(2)
							If DBSeek( PADR( aCamposBrw[Yu-1], 10 ) , .f. )
									AADD( aTitCampos , AllTrim( OemToAnsi( SX3->(&cDescriSX3) ) )	)
							EndIf
			
							If Yu > 1
									If SX3->X3_TIPO == "N"
											cPictSE2	:= PesqPict( "SE2", aCamposBrw[Yu-1] )
											cLine += "TransForm( aF4For[oListBox:nAT][" + AllTrim( STR(Yu) ) + "], cPictSE2 ) "
									Else
											cLine += "aF4For[oListBox:nAT][" + AllTrim( STR(Yu) ) + "]"
									EndIf
										
									cLine += IIF( Yu - 1 = Len( aCamposBrw ), "", ", " )
							EndIf
						EndIf
				EndIf
		Next Yu

		cLine += " } "

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Monta dinamicamente o bline do CodeBlock                 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		bLine := &( "{ || " + cLine + " }" )

/*
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Copia a tabela (SE2) para pesquisar os Titulos de Impostos para SE1XXX.DBF                              ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		DBSelectArea("SE2")
		DBSetOrder(1)

		cFilSXX		:= " E2_FILIAL = '" + xFilial("SE2") + "' "
		cFilSXX		+= " .AND. !EMPTY( E2_TITPAI ) "
		
		cIndexSXX 	:= "E2_FILIAL + E2_TITPAI + E2_PREFIXO + E2_NUM + E2_PARCELA + E2_FORNECE + E2_LOJA "			// Chave de pesquisa do arquivo de trabalho
		cIndexSE2 	:= CriaTrab( Nil, .F. )

		IndRegua( "SE2", cIndexSE2, cIndexSXX,, cFilSXX, OemToAnsi( STR0002 ) )		// "Selecionando titulos a pagar ... "

		If SELECT("E2_XXX") > 0
					DBSelectArea("E2_XXX")
					DBCloseArea()
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ (E2_XXX) Cria o arquivo de trabalho com o original do SE2 - Contas a Pagar                      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cARQDBF	:= "SE2XXX.DBF"					// Nome do arquivo

		Copy to &cArqDBF VIA "DBFCDX"			// Copia o SE2 para SE2XXX.DBF

		DBUseArea( .t., __LocalDriver, cARQDBF, "E2_XXX", .f., .f. )

		DBSelectArea("SE2")
		RETIndex()
*/
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Gera o FILTRO dos dados da tabela SE2 - Contas a Pagar                                          ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cFiltro		:= " E2_FILIAL = '" + xFilial("SE2") + "' "
		cFiltro 	+= " .and. E2_FORNECE = '" + cFORSF1 + "' "
		cFiltro		+= " .and. E2_LOJA = '" + cLOJSF1 + "' "
//		cFiltro		+= " .and. E2_NATUREZ = '" + cNaturez + "' "
		cFiltro		+= " .and. EMPTY( SE2->E2_X_DTANF ) "
		cFiltro		+= " .and. EMPTY( SE2->E2_X_NUMNF ) "
		cFiltro		+= " .and. EMPTY( SE2->E2_X_SERIE ) "
		cFiltro		+= " .and. SE2->E2_X_TT = 'S' "
//		cFiltro		+= " .and. E2_SALDO > 0 "

		IndRegua( "SE2", cIndexSE2, dIndexSE2,, cFiltro, OemToAnsi( STR0003 ) )				// "Selecionando titulos a pagar ..."
		DBGoTOP()

		WHILE SE2->(!EOF())
						DBSelectArea("SE2")
						nF4For := aScan( aF4For, { |x|x[2] == SE2->( E2_PREFIXO + E2_NUM + E2_PARCELA ) } )
						If ( nF4For == 0 )
								cConteudo	:= "{ .f., "							
								FOR W := 1 To Len( aCamposBrw )
											cConteudo	+= aCamposBrw[w] + IIF( W = LEN( aCamposBrw ), "" , ", " )
								Next W
								cConteudo	+= " }"

								aadd( aF4For , &cConteudo )
								aAdd( aRecSD2, RecNo() )
						EndIf

						cChave_	:= PADR( SE2->( E2_PREFIXO + E2_NUM + E2_PARCELA + E2_TIPO + E2_FORNECE + E2_LOJA ), TAMSX3("E2_TITPAI")[1] )			// Chave de pesquisa para titulos de TAXAS e IMPOSTOS
		
  /*
  						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ (E2_XXX) - Busca no arquivo original os titulos de Impostos e Taxas                             ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						DBSelectArea("E2_XXX")
						If DBSeek( xFilial("SE2") + cChave_ )
								While !Eof() .AND. E2_FILIAL == xFilial("SE2") .AND. E2_TITPAI == cChave_
											DBSelectArea("E2_XXX")
											If ( nF4For == 0 )
													cConteudo	:= "{ .f., "							
													FOR W := 1 To Len( aCamposBrw )
																cConteudo	+= aCamposBrw[w] + IIF( W = LEN( aCamposBrw ), "" , ", " )
													Next W
													cConteudo	+= " }"
					
													aadd( aF4For , &cConteudo )
													aAdd( aRecSD2, RecNo() )
											EndIf

											E2_XXX->(DBSkip())
								EndDo
						EndIf
*/						
						SE2->(DBSkip())
		EndDo


		If !EMPTY( aF4For )

				lFechou 	:= .f.
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ (SA2) - Posiciona o Cadastro de Fornecedores             ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				DBSelectArea("SA2")
				DBSetOrder(1)
				DBSeek( xFilial("SA2") + cFORSF1 + cLOJSF1 , .f. )

				cNomeFor 	:= "(" + SA2->A2_COD + "-" + SA2->A2_LOJA + ") - " + SA2->A2_NOME 
				cDocumento	:= cSERSF1 + "/" + cDOCSF1 

				while !lFechou
								DEFINE MSDIALOG oDlg FROM 50,10  TO 385,941 TITLE OemToAnsi( STR0003 ) Of oMainWnd PIXEL // "Selecionar Titulos Pendentes do Fornecedor"
				

								If cVersao <> "12"
									oListBox := TWBrowse():New( 30     , 4      ,   443  ,  80   ,, aTitCampos,,oDlg,,,,,,,,,,,,.F.,,.T.,,.F.,,,)
					
									oListBox:SetArray(aF4For)
									oListBox:bLDblClick := { || MMARCA() }
									
									oListBox:bLine := bLine
	

									@ 15  ,4   SAY OemToAnsi( GetSx3Cache( "F1_FORNECE" , "X3_TITULO" ) ) Of oDlg PIXEL SIZE 47 ,9 //"Fornecedor"
									@ 14  ,40  MSGET cNomeFor PICTURE PesqPict( "SA2", "A2_NOME" ) When .F. Of oDlg PIXEL SIZE 200,9
	
									@ 15  ,258   SAY OemToAnsi( STR0004 ) Of oDlg PIXEL SIZE 30 ,9 			// "Documento"
									@ 14  ,328  MSGET cDOCUMENTO PICTURE "@!" When .F. Of oDlg PIXEL SIZE 120,9
	
									@ 120  ,4   SAY OemToAnsi( STR0005 ) Of oDlg PIXEL SIZE 47 ,9 		// "Vl da Nota"
									@ 119  ,30  MSGET oVlBruto VAR nValorBruto PICTURE PesqPict( "SC7", "C7_TOTAL" ) When .F. Of oDlg PIXEL SIZE 80,9
	
									@ 120  ,140  SAY OemToAnsi( STR0006 ) Of oDlg PIXEL SIZE 47 ,9 		// "Total"
									@ 119  ,186  MSGET oValor VAR nVar PICTURE PesqPict( "SC7", "C7_TOTAL" ) When .F. Of oDlg PIXEL SIZE 80,9
					  
									@ 120  ,276  SAY OemToAnsi( STR0007 ) Of oDlg PIXEL SIZE 17 ,9 // "Qtde Titulos"
									@ 119  ,340  MSGET oQtde VAR nQtde PICTURE "@e 999,999" When .F. Of oDlg PIXEL SIZE 80,9
	
								Else

									aLin := {}    
									nTamL := 15
									nIniL := 25
									
									For nLin :=1  To 10
										AADD( aLin , (nTamL * nLin) + nIniL )		
									Next
							       
									oListBox := TWBrowse():New( aLin[02]      , 4      ,   443  ,  80   ,, aTitCampos,,oDlg,,,,,,,,,,,,.F.,,.T.,,.F.,,,)
					
									oListBox:SetArray(aF4For)
									oListBox:bLDblClick := { || MMARCA() }
									
									oListBox:bLine := bLine
	
									@ aLin[01]+1  	,004  SAY OemToAnsi( GetSx3Cache( "F1_FORNECE" , "X3_TITULO" ) ) Of oDlg PIXEL SIZE 47 ,9 //"Fornecedor"
									@ aLin[01]  	,040  MSGET cNomeFor PICTURE PesqPict( "SA2", "A2_NOME" ) When .F. Of oDlg PIXEL SIZE 200,9
							
									@ aLin[01]+1  	,280  SAY OemToAnsi( "Documento" ) Of oDlg PIXEL SIZE 30 ,9 			// "Documento"
									@ aLin[01]  	,330  MSGET cDOCUMENTO PICTURE "@!" When .F. Of oDlg PIXEL SIZE 80,9
							
									@ aLin[08]+1	,004  SAY OemToAnsi( "Vl da Nota" ) Of oDlg PIXEL SIZE 47 ,9 		// "Vl da Nota"
									@ aLin[08]  	,040  MSGET oVlBruto VAR nValorBruto PICTURE PesqPict( "SC7", "C7_TOTAL" ) When .F. Of oDlg PIXEL SIZE 80,9
							
									@ aLin[08]+1  	,150  SAY OemToAnsi( "Total" ) Of oDlg PIXEL SIZE 47 ,9 		// "Total"
									@ aLin[08]  	,170  MSGET oValor VAR nVar PICTURE PesqPict( "SC7", "C7_TOTAL" ) When .F. Of oDlg PIXEL SIZE 80,9
							  
									@ aLin[08]+1  	,280  SAY OemToAnsi( "Qtde Titulos" ) Of oDlg PIXEL  // "Qtde Titulos"
									@ aLin[08]  	,330  MSGET oQtde VAR nQtde PICTURE "@e 999,999" When .F. Of oDlg PIXEL SIZE 80,9
							
								EndIf							
	
	
				
								ACTIVATE MSDIALOG oDlg  CENTERED ON INIT EnchoiceBar( oDlg, {||(nOpc := 1,nF4For := oListBox:nAt,oDlg:End())}, {||(nOpc := 0,nF4For := oListBox:nAt,oDlg:End())},, )
				
								If nOpc == 1
									
										If nValorBruto <> nVar .AND. lConsistVal		// VERIFICA SE DEVE CONSISTIR O VALOR MARCADO
												ALERT( OemToAnsi( STR0008 ) ) 			// "VALOR SELECIONADO É MENOR DO QUE O VALOR DA NOTA "
												lFechou	:= .f.
										Else
												lFechou	:= .f.
												lPendente	:= .t.
												//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
												//³ Atualiza os dados do(s) titulo(s) a Pagar gerado(s) pela Comissao            ³
												//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
												For Xhy := 1 to Len( aF4For )
														If aF4FOR[Xhy][1]										// Se estiver marcado, registra o recebimento 
																lFechou	:= .t.
																lPendente	:= .F.
														EndIf
												Next Xhy
										EndIf
								Else
										lFechou		:= .t.
										lPendente	:= .t.
								EndIf
				enddo
        EndIf
/*
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ (E2_XXX) Fecha o arquivo de trabalho gerado durante o processamento.         ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If SELECT("E2_XXX") > 0
					DBSelectArea("E2_XXX")
					DBCloseArea()
		EndIf
*/
		DBSelectArea("SE2")
		RETIndex()


// Restaura a(s) area(s) salva(s)
RESTArea( aAREA_SF1 )
RESTArea( aAREA_SE2 )
RESTArea( aAREA_SA2 )
RESTArea( aAREA_ATU )

RETURN(lPendente)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡…o      ³ NMARCA        ³ Autor ³ Marcos Gomes (TAGGS)     ³ Data ³  05/07/2013  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡…o   ³ Funcao que faz o controle da marcacao do registro e quantidade e valor ³±±
±±³             ³ do(s) titulo(s) marcado(s).                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso         ³ Generico                                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
STATIC FUNCTION MMARCA()

LOCAL lConsImp	:= SUPERGETMV( "FS_CONSIMP",, .T. ) 
            
            /* - Claudino - 22/09/2017 - Ajuste para titulos compensados ( TIPO DP X NDF )
			If aF4For[oListBox:nAt,1]								// Subtrai o valor e a quantidade marcado		// PORRA
						nVar	-= aF4For[oListBox:nAt,9]    
						If lConsImp	
								nVar	-= aF4For[oListBox:nAt][10]    		// IRRF
								nVar	-= aF4For[oListBox:nAt][11]    		// ISS
								nVar	-= aF4For[oListBox:nAt][12]    		// INSS
						EndIf
						nQtde	--
			Else													// Soma o valor e a quantidade marcada
						nVar	+= aF4For[oListBox:nAt,9]
						If lConsImp	
								nVar	+= aF4For[oListBox:nAt][10]    		// IRRF
								nVar	+= aF4For[oListBox:nAt][11]    		// ISS
								nVar	+= aF4For[oListBox:nAt][12]    		// INSS
						EndIf
						nQtde	++
			EndIf
			*/

			If aF4For[oListBox:nAt,1]								// Subtrai o valor e a quantidade marcado
						nVar	-= aF4For[oListBox:nAt,10]    
						If lConsImp	
								nVar	-= aF4For[oListBox:nAt][11]    		// IRRF
								nVar	-= aF4For[oListBox:nAt][12]    		// ISS
								nVar	-= aF4For[oListBox:nAt][13]    		// INSS
						EndIf
						nQtde	--
			Else													// Soma o valor e a quantidade marcada
						nVar	+= aF4For[oListBox:nAt,10]
						If lConsImp	
								nVar	+= aF4For[oListBox:nAt][11]    		// IRRF
								nVar	+= aF4For[oListBox:nAt][12]    		// ISS
								nVar	+= aF4For[oListBox:nAt][13]    		// INSS
						EndIf
						nQtde	++
			EndIf
			
			aF4For[oListBox:nAt,1] := !aF4For[oListBox:nAt,1]		// Inverte a marcacao feita
			oValor:Refresh()										// Refresh no campo valor
			oQtde:Refresh()											// Refresh no campo Quantidade
/*
  		AADD( aCamposBrw, "E2_VALOR"	)			// 8
		AADD( aCamposBrw, "E2_IRRF"		)			// 9													
		AADD( aCamposBrw, "E2_ISS"		)			// 10
		AADD( aCamposBrw, "E2_INSS"		)			// 11
*/

RETURN()

   



USER FUNCTION MyTT__( cDOCSF1, cSERSF1, cFORSF1, cLOJSF1, nValorBruto )

LOCAL aAREA_ATU		:= GETArea()					// Salva a area atual do Sistema
LOCAL aAREA_SA2		:= SA2->( GetArea() )			// Salva a area do SA2 - Fornecedores
LOCAL aAREA_SE2		:= SE2->( GetArea() )			// Salva a area do SE2 - Contas a Pagar
LOCAL aAREA_SF1		:= SF1->( GetArea() )			// Salva a area do SF1 - Cabecalho da Nota Fiscal de Entrada

LOCAL oOk        	:= LoadBitMap(GetResources(), "LBOK")			// Botao Ok
LOCAL oNo        	:= LoadBitMap(GetResources(), "LBNO")			// Botao Cancelar
LOCAL nOPc		 	:= 0
Local oDlg

LOCAL aTitCampos 	:= {}
LOCAL nF4For     	:= 0
LOCAL aRecSD2    	:= {}
LOCAL aTitCampos 	:= {}
LOCAL aConteudos 	:= {}
LOCAL cNomeFor   	:= ""

LOCAL lF060Mark 	:= .f.

//LOCAL cNaturez		:= PADR( SUPERGETMV( "FS_SEDNAT",, "COMISSAO" ), TAMSX3("E2_NATUREZ")[1] )		// Natureza dos titulos de comissao
LOCAL lConsistVal	:= SUPERGETMV( "FS_VALIDAV",, .t. )												// Indica se deve ou nao consistir o valor marcado

LOCAL cIndexSE2 	:= CriaTrab(nil,.f.)
LOCAL dIndexSE2 	:= "E2_FILIAL+E2_FORNECE+E2_LOJA+E2_PREFIXO+E2_NUM+E2_PARCELA"

LOCAL aCamposBrw	:= {}
LOCAL cStartPath	:= GetSrvProfString("Startpath","")													// Path inicial do Protheus \SYSTEM

LOCAL lFechou 		:= .f.
//LOCAL lPendente		:= .f.

PRIVATE cCadastro	:= OemToAnsi( "Documento de Entrada" ) //"Documento de Entrada"
PRIVATE aBackSD1    := {}
PRIVATE aBackSDE    := {}

PRIVATE cMarca   	:= GetMark( )
PRIVATE lInverte 	:= .F.
PRIVATE oValor, oPrazoMed, oQtda, oVlBruto

PRIVATE aF4For		:= {}					// Array com os dados dos titulos
PRIVATE nVar 		:= 0.00					// Valor total do(s) titulo(s) marcado(s)
PRIVATE nQtde		:= 0					// Quantidade de Titulo(s) marcado(s)

		AADD( aTitCampos, " " )
		AADD( aTitCampos, "CAMPO 01" )
		AADD( aTitCampos, "CAMPO 02" )

		aadd( aF4For , {.T., "000001","DESCRICAO"} )				
		aadd( aF4For , {.T., "000002","DESCRICAO"} )				
		aadd( aF4For , {.T., "000003","DESCRICAO"} )						

		DBSelectArea("SA2")
		DBSetOrder(1)
		DBSeek( xFilial("SA2") + cFORSF1 + cLOJSF1 , .f. )

		cNomeFor 	:= "(" + SA2->A2_COD + "-" + SA2->A2_LOJA + ") - " + SA2->A2_NOME 
		cDocumento	:= cSERSF1 + "/" + cDOCSF1 

		aLin := {}    
		nTamL := 15
		nIniL := 25
		
		For nLin :=1  To 10
			AADD( aLin , (nTamL * nLin) + nIniL )		
		Next



		DEFINE MSDIALOG oDlg FROM 50,10  TO 385,941 TITLE OemToAnsi( "Selecionar Titulos Pendentes do Fornecedor" ) Of oDlg PIXEL // "Selecionar Titulos Pendentes do Fornecedor"
				
		oListBox := TWBrowse():New( aLin[02]     , 4      ,   443  ,  80   ,, aTitCampos,,oDlg,,,,,,,,,,,,.F.,,.T.,,.F.,,,)

		oListBox:SetArray(aF4For)
		oListBox:bLDblClick := { || MMARCA() }

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Monta dinamicamente o bline do CodeBlock                 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		bLine := { || 	aF4For[oListBox:nAT][01],;
					 	aF4For[oListBox:nAT][02],;
					 	aF4For[oListBox:nAT][03]	 }

		
		oListBox:bLine := bLine
				
		@ aLin[01]+1  	,004  SAY OemToAnsi( GetSx3Cache( "F1_FORNECE" , "X3_TITULO" ) ) Of oDlg PIXEL SIZE 47 ,9 //"Fornecedor"
		@ aLin[01]  	,040  MSGET cNomeFor PICTURE PesqPict( "SA2", "A2_NOME" ) When .F. Of oDlg PIXEL SIZE 200,9

		@ aLin[01]+1  	,280  SAY OemToAnsi( "Documento" ) Of oDlg PIXEL SIZE 30 ,9 			// "Documento"
		@ aLin[01]  	,330  MSGET cDOCUMENTO PICTURE "@!" When .F. Of oDlg PIXEL SIZE 80,9

		@ aLin[08]+1	,004  SAY OemToAnsi( "Vl da Nota" ) Of oDlg PIXEL SIZE 47 ,9 		// "Vl da Nota"
		@ aLin[08]  	,040  MSGET oVlBruto VAR nValorBruto PICTURE PesqPict( "SC7", "C7_TOTAL" ) When .F. Of oDlg PIXEL SIZE 80,9

		@ aLin[08]+1  	,150  SAY OemToAnsi( "Total" ) Of oDlg PIXEL SIZE 47 ,9 		// "Total"
		@ aLin[08]  	,170  MSGET oValor VAR nVar PICTURE PesqPict( "SC7", "C7_TOTAL" ) When .F. Of oDlg PIXEL SIZE 80,9
  
		@ aLin[08]+1  	,280  SAY OemToAnsi( "Qtde Titulos" ) Of oDlg PIXEL  // "Qtde Titulos"
		@ aLin[08]  	,330  MSGET oQtde VAR nQtde PICTURE "@e 999,999" When .F. Of oDlg PIXEL SIZE 80,9

//		ACTIVATE MSDIALOG oDlg  CENTERED ON INIT EnchoiceBar( oDlg, {||(nOpc := 1,nF4For := oListBox:nAt,oDlg:End())}, {||(nOpc := 0,nF4For := oListBox:nAt,oDlg:End())},, )
		ACTIVATE MSDIALOG oDlg  CENTERED ON INIT EnchoiceBar( oDlg, {||(nOpc := 1,oDlg:End())}, {||(nOpc := 0,oDlg:End())},, )
  

// Restaura a(s) area(s) salva(s)
RESTArea( aAREA_SF1 )
RESTArea( aAREA_SE2 )
RESTArea( aAREA_SA2 )
RESTArea( aAREA_ATU )

RETURN(.f.)

User Function xMYProc()
                              
	Local aCamposBrw :={}
	Local lEnd := .F.
	Private aF4For :={}

    RpcSetType(3)
	RpcSetEnv("01","01")             

/*
	While !lEnd
		WfReturn()
    EndDo 
*/
	U_MyTT__( "00000001", "5", "000011", "01", 3500 ) 
	
Return	