#Include "rwmake.ch"

#IFNDEF WINDOWS
   #DEFINE PSAY SAY
#ENDIF

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³  MEGA06A ³ Autor ³Airton Lira            ³ Data ³04/10/2000³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ RELATORIO GERENCIAL DE FATURAMENTO                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Utilidade ³ Devido a sua Simplicidade e Praticidade, Este Relat¢rio    ³±±
±±³          ³ Consegue Demonstrar Informa‡™es Gerenciais referente ao    ³±±
±±³          ³ Faturamento da Eletromega, onde o Mesmo pode ser Utilizado ³±±
±±³          ³ para Calcular o I.C.M.S. S/Faturamento, as Comiss™es dos   ³±±
±±³          ³ Vendedores, Analisar o Custo Ref. as Vendas, Analisar o    ³±±
±±³          ³ Faturamento e Principalmente pode ser Pr‚ Parametrizado    ³±±
±±³          ³ em Datas e tambem checa PEDIDO X NF ORC X DUPL             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Eletromega                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß

ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Variaveis utilizadas para parametros                         ³
³ mv_par01             // Da Emissao                           ³
//³ mv_par02             // Ate a Emissao                        ³
//³ mv_par03             // Do Vendedor                          ³
//³ mv_par04             // Ate o Vendedor                       ³
//³ mv_par05             // Do cliente                           ³
//³ mv_par06             // Ate o Clente                         ³
//³ mv_par07             // Do cliente 2                         ³
//³ mv_par08             // Ate o Clente                         ³
//³ mv_par09             // Da Serie                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/

USER FUNCTION MEGA06A()

	PRIVATE xPag      :=1
	PRIVATE CbTxt     :=""
	PRIVATE CbCont    :=""
	PRIVATE nOrdem    :=0
	PRIVATE Alfa      := 0
	PRIVATE Z         :=0
	PRIVATE M         :=0
	PRIVATE tamanho   :="M"
	PRIVATE limite    :=132
	PRIVATE titulo    :=PADC("MEGA06A - Relatorio Gerencial de Vendas, Uso Exclusivo da ELETROMEGA ",75)
	PRIVATE cDesc1    :=PADC("Este programa ira emitir o Relatorio Gerencial de Vendas Conforme   ",75)
	PRIVATE cDesc2    :=PADC("Lay-Out Pr‚ Definido Pela DIRETORIA da ELETROMEGA.                  ",75)
	PRIVATE cDesc3    :=PADC("                                                                    ",75)
	PRIVATE cNatureza :=""
	PRIVATE aReturn   := { "Especial" , 1, "Diretoria" , 2, 2, 1,"", 0 }
	PRIVATE nomeprog  :="MEGA06A"
	PRIVATE cPerg     := PadR("MEGA06A",10)
	PRIVATE nLastKey  := 0
	PRIVATE Li        := 0
	PRIVATE wnrel     := "MEGA06A"
	PRIVATE WW_PAR07  := Space(5)
	PRIVATE xCDPG     := Space(6) 
	PRIVATE XTES      := Space(3)
	PRIVATE XFPAGTO   := Space(15)
	PRIVATE xTotVen   := 0
	PRIVATE xTotCusto := 0
	PRIVATE xTotLiq   := 0
	PRIVATE xTotIcms  := 0
	PRIVATE xTotComis := 0
	PRIVATE xNumdNf   := 0 // Claudino - 21/12/15
	PRIVATE xNumBco   := Space(15)
	PRIVATE xParcela  := ""
	PRIVATE xParcelab := ""
	PRIVATE xParcelac := ""
	PRIVATE xVencrea  := ""
	PRIVATE xValLiq   := 0
	
	Pergunte(cPerg,.F.)

	PRIVATE cString:="SF2"

	wnrel:=SetPrint(cString,wnrel,cPerg,Titulo,cDesc1,cDesc2,cDesc3,.T.)

	If nLastKey == 27
		Return
	EndIf

	SetDefault(aReturn,cString)
	
	If nLastKey == 27
   		Return
	EndIf

	RptStatus({|| RptDetail()})

Return

Static Function RptDetail()

	SetPrc(0,0)

	PRIVATE xInicio := .T.

	dbSelectArea("SF2")
	cPar01 := Str(Year(mv_par01),4) + StrZero(Month(mv_par01),2)
	
	_cCnd := "@ (F2_EMISSAO BETWEEN '" + DtoS( MV_PAR01 ) + "' AND '" + DtoS( MV_PAR02 ) + "') AND "
	_cCnd += "(F2_VEND1 BETWEEN '" + MV_PAR03 + "' AND '" + MV_PAR04 + "') AND "
	//_cCnd += "(F2_VEND2 BETWEEN '" + MV_PAR05 + "' AND '" + MV_PAR06 + "') AND "
	_cCnd += "(F2_CLIENTE BETWEEN '" + MV_PAR05 + "' AND '" + MV_PAR06 + "') AND "
	_cCnd += "(F2_FILIAL = '" + xFilial( "SF2" ) + "') AND (D_E_L_E_T_ <> '*') AND " 
	_cCnd += " F2_CLIENTE <> '008360' "
	
	If MV_PAR08 == 1
		_cCnd += " AND F2_EST = 'SP' "
	ElseIf MV_PAR08 == 2
		_cCnd += " AND F2_EST <> 'SP' "
	EndIf
	
	If !Empty(mv_par07)
		_cCnd += "  AND (F2_SERIE = '" + mv_par07 + "')"
	EndIf
	
	SF2->( dbSetOrder( 4 ) )
	SF2->( dbSetFilter( { || &_cCnd }, _cCnd ) )
	
	SF2->( dbGoBottom() )
	_nReg := SF2->( RecNo() )
	
	SF2->( dbGoTop() )
	_nReg -= SF2->( RecNo() )
	
	SetRegua( _nReg )

	_cPed := Space( 6 )

	_fSC5 := xFilial( 'SC5' )
	_fSD2 := xFilial( 'SD2' )
	_fSE4 := xFilial( 'SE4' )
	_fSE1 := xFilial( 'SE1' )
	_fSA1 := xFilial( 'SA1' )
	_fSE3 := xFilial( 'SE3' )
	_fSF4 := xFilial( 'SF4' )

	SC5->( dbSetOrder( 1 ) )
	SD2->( dbSetOrder( 3 ) )
	SE4->( dbSetOrder( 1 ) )
	SE1->( dbSetOrder( 1 ) )
	SA1->( dbSetOrder( 1 ) )
	SE3->( dbSetOrder( 1 ) )
	SF4->( dbSetOrder( 1 ) )

	lEscape := .f.

	While .T.
		
		If xInicio .Or.;
      		Li >= 58

      		Cabec()
      		xInicio := .F.
		EndIf

   		While Li <= 60 .And. ! EOF()
      
			xCliente    := SF2->F2_CLIENTE
	      	xLoja       := SF2->F2_LOJA
	      	xNum_NF     := SF2->F2_Doc             // Numero
	      	xSerie      := SF2->F2_Serie           // Serie
	      	xEmissao    := SF2->F2_Emissao         // Data de Emissao
	      	xValIcms    := SF2->F2_ValIcm          // Valor do ICMS
	      	xValCusto   := 0                       // Custo dos Produtos,Calcular… abaixo
	      	xMargem     := 0                       // margem
	      	xValven     := SF2->F2_ValMerc         // Valor Bruto Faturado
	      	xTOTNF      := SF2->F2_VALMERC
	      	xTOTITEMNF  := 0                       // VALOR DOS ITENS DE NF ORC 
	      	xTOTITEMPED := 0                       // VALOR DOS ITENS DE PEDIDO
	      	xTOTPED     := 0                       // VALOR TOTAL DO PEDIDO
	      	xTOTDUPL    := 0
	        xValLiq     := xValven - SF2->F2_VALICM - SF2->F2_VALIMP5 - SF2->F2_VALIMP6  
	
      		SD2->(dbSeek(_fSD2 +;
        				xNum_NF +;
                     	xSerie +;
                     	xCliente +;
                     	xLoja ,;
                     	.T. ;
            	))
            
      		If !  ( SD2->( Eof() ) )       .And.;
        		SD2->D2_Doc     = xNum_NF  .And.;
         		SD2->D2_Serie   = xSerie   .And.;
         		SD2->D2_CLIENTE = xCliente .And.;
         		SD2->D2_LOJA    = xLoja    .And.;
         		SD2->D2_FILIAL  == xFilial("SD2") 

         		xTOTITEMNF += SD2->D2_TOTAL

         		SC5->( dbSeek( _fSC5 + SD2->D2_Pedido, .F. ) )
                               
				xMargem   := SC5->C5_TOTMAR
				xCDPG     := SC5->C5_CDPG
				xValCusto := SC5->C5_TOTCUS
		
         		If SC5->C5_TOTVEN > SF2->F2_VALMERC

            		_nPorc    := SF2->F2_VALMERC
            		_nPorc    /= SC5->C5_TOTVEN
            		_nPorc    := Round( _nPorc, 2 )
            		_nPorc    *= SC5->C5_TOTCUS
            		_nPorc    := _nPorc
            		xValCusto := _nPorc

         		EndIf

         		SE4->( dbSeek( _fSE4 + SF2->F2_COND ) )
         		xFpagto   := SE4->E4_Descri
         		//xTes := SD2->D2_TES Claudino - Comentei - 21/12/15

         		If SF2->F2_TIPO # "D" .And.;
            		! ( SD2->D2_TES $ [510 507 922 99 ] )
					// xValCusto := xValCusto + (SC6->C6_CUSTD*SD2->D2_QUANT)   // Soma os Custos Ref. a NF em Quest„o
             		xTOTITEMPED += SD2->D2_TOTAL
          		EndIf

          		If SF2->F2_TIPO $ "D"
            		xValcusto := 0
             		xValVen   := 0
          		EndIf
          		
          		// add 514 war 02-08-2005
          		If SD2->D2_TES $ [510 507 922 799 514 ]  // Retorno de Troca, Display
             		xValcusto := 0
             		xValVen   := 0 //xValven - SD2->D2_TOTAL
				EndIf

          		SE1->( dbSeek( _fSE1 +;
                         SD2->D2_SERIE +;
                         SD2->D2_Doc ,;
                         .T. ;
            		))

          		If ( SE1->( Found() ) )

             		xNumBco  := SE1->E1_NUMBCO

             		If xTOTDUPL == 0

                		While SE1->E1_PREFIXO = SD2->D2_SERIE .And.;
                      			SE1->E1_NUM = SD2->D2_DOC

                   			If SE1->E1_TIPO = "NF "
                   	
                    			xTOTDUPL += SE1->E1_VALOR
                                
                      			If ! Empty( SE1->E1_PARCELA )

                         			If SE1->E1_PARCELA = "A"

                            			xParcela  := SE1->E1_PARCELA
                            			xVencrea  := SE1->E1_VENCREA

                         			ElseIf SE1->E1_PARCELA = "B"

                            			xParcelab := SE1->E1_PARCELA
                            			xVencreab := SE1->E1_VENCREA

                         			ElseIf SE1->E1_PARCELA = "C"

                            			xParcelac := SE1->E1_PARCELA
                            			xVencreac := SE1->E1_VENCREA

                         			EndIf

                      			Else

                          			xVencrea := SE1->E1_VENCREA

                      			EndIf

                   			EndIf

                   			SE1->( dbSkip() )

                		EndDo

             		EndIf

         	 	Else           

              		xNumBco := "**FALTA DUPL.**"

          		EndIf

       		EndIf

       		SA1->( dbSeek( _fSA1 + SF2->F2_Cliente + SF2->F2_Loja ) )

       		xCodCliLj := SA1->A1_Cod
       		xCodCliLj += "/"
       		xCodCliLj += SA1->A1_Loja
       		xRazaoCli := SA1->A1_Nreduz
       		xTabCli	  := SA1->A1_Tabela  // MOA - 14/08/2019 - 08:41hs -> Solicitado verbalmente pelo Diretor Roberto
            
            /* Claudino - Comentei - 21/12/15
       		SF4->( dbSeek( _fSF4 + xTES, .F. ) )
       		xtexto := SF4->F4_Texto
            */
      
       		xMENSAGEM := Space( 20 )
       		xVALORDIF := 0

       		If Round(xTOTITEMPED,1) # Round(xTOTNF,1)
         		xMENSAGEM := "DIF.PEDxNFxDUPL"
         		XVALORDIF := Round(xTOTITEMPED,1) - Round(xTOTNF,1)
       		EndIf

       		If Round(xTOTNF,1) # Round(xTOTITEMNF,1) 
         		xMENSAGEM := "DIF.PEDxNFxDUPL"
         		XVALORDIF := Round(xTOTNF,1) - Round(xTOTITEMNF,1)
       		EndIf

       		If ROUND(xTOTITEMNF,1) # ROUND(xTOTDUPL,1)
         		xMENSAGEM := "DIF.PEDxNFxDUPL"
         		XVALORDIF := ROUND(xTOTITEMNF,1) - ROUND(xTOTDUPL,1)
       		EndIf

       		@ Li,000 PSAY xNum_NF
            
            /* Claudino - Comentei - 21/12/15
       		If ! Empty( xParcela )

          		@ Li,009 PSAY xParcela   // @ Li,006 PSAY xParcela
          		xParcela := ""

       		EndIf
			*/            
            
       		If xNumBco <> ' '
          		xNumBco := rTrim( xNumBco )
       		Else
          		xNumBco := Space( 10 )
       		EndIf

			@ Li,009+3 PSAY xSerie
			@ Li,013+3 PSAY xRazaoCli
			@ Li,035+3 PSAY xValVen Picture "@E 999,999.99"
			@ Li,050+3 PSAY xValLiq Picture "@E 999,999.99"
			@ Li,066+3 PSAY xValCusto Picture "@E 999,999.99"
			@ Li,085+3 PSAY SUBSTR(xFpagto,1,15)
			@ Li,102+3 PSAY xValCusto / xValLiq
			@ Li,116+3 PSAY xMargem Picture "999.99"
			@ Li,125+3 PSAY xTabCli // MOA - 14/08/2019 - 08:41hs -> Solicitado verbalmente pelo Diretor Roberto 
			Li ++

			// @ li,058+3 PSAY Left(xtexto,10) Claudino - Comentei - 21/12/15
			// @ li,085+3 PSAY SUBS(xCDPG,1,11) Claudino - Comentei - 21/12/15
	        // @ li,097+3 PSAY xNumBco Claudino - Comentei - 21/12/15
	        //@ li,124+3 PSAY xVencrea Claudino - Comentei - 21/12/15
	        
	        /* Claudino - Comentei - 21/12/15
     		If !Empty(xParcelab)
        		@ Li,000 PSAY xNum_NF
        		@ Li,009 PSAY xParcelab
        		@ Li,127 PSAY xVencreab
        		Li ++
     		EndIf

     		If !Empty(xParcelac)
        		@ Li,000 PSAY xNum_NF
        		@ Li,009 PSAY xParcelac
        		@ Li,127 PSAY xVencreac
        		Li ++
     		EndIf
            */
			
			If ! Empty(SF2->F2_Dupl) .And.;
        		! SF2->F2_Tipo $ "D"

				xTotVen   := xTotVen + xValVen

     		EndIf
            
			xNumdNf++ // Claudino - 21/12/15
			xTotCusto += xValCusto
			xTotLiq += xValLiq
			xTotIcms  += xValIcms
			//xtexto    := ""  Claudino - Comentei - 21/12/15
			//xtes      := ""
			//xParcelab := ""
			//xParcelac := ""
		
     		SF2->( dbSkip() )
     		IncRegua()

   		EndDo

   		If SF2->( Eof() ) .Or.;
      		lEscape
      		ImpRodape()
      		Exit
   		EndIf

	EndDo

	SF2->( dbClearFilter( NIL ) )

	Set Device To Screen
	Set Printer To
	MS_FLUSH()
	
	If aReturn[5] == 1
		dbcommitAll()
		OurSpool(wnrel)
	End
	
Return

* ------------------------------------------------------------------------- *
* Funcao Cabec | Destinada para Imprimir o Cabe‡alho !                      *
* ------------------------------------------------------------------------- *

Static Function Cabec

	If xInicio
		SetPrc(0,0) // Zera o Formulario
		xPag := 1
	Endif
	
	@ 000,000 PSAY Chr(15)
	Li := 0
	xTit1 := "Relatorio Gerencial de Vendas Realizadas no Periodo de "+Dtoc(Mv_Par01)+" ate "+Dtoc(Mv_Par02)
	
	IF MV_PAR07 == "   "
		WW_PAR07 := "Todas"
	ELSE
		WW_PAR07 := MV_PAR07
	ENDIF
	
	xTit2 := "do Vend. "+Mv_Par03+" ate "+Mv_Par04+" , do Cl. "+Mv_Par05+" ate "+Mv_Par06+" e da Serie Igual a "+WW_Par07

	@ Li,000 PSAY Replicate("*",135)
	Li := Li + 2
	@ Li,000 PSAY "* Emissao : "+Dtoc(Date())
	@ Li,122 PSAY "Pagina : "+Alltrim(Str(xPag,0))
	@ Li,134 PSAY "*"
	Li := Li + 1
	@ Li,000 PSAY "*"
	@ Li,66 -Int(Len(xTit1)/2) PSAY xTit1
	@ Li,134 PSAY "*"
	Li := Li + 1
	@ Li,000 PSAY "* MEGA06A.PRG"
	@ Li,66 -Int(Len(xTit2)/2) PSAY xTit2
	@ Li,118 PSAY "Hora : "+Alltrim(Subs(Time(),0))
	@ Li,134 PSAY "*" 
	Li := Li + 1
	@ Li,000 PSAY Replicate("*",135)
	Li := Li + 1
	@ Li,000 PSAY "Nota        Ser Cliente               Total Merc    Total Venda     Total Custo         F.Pagto          CMV            Nota   Tabela"
	Li := Li + 1                                                                                                                                       
	@ Li,000 PSAY Replicate("*",135)
	Li := Li + 1
	
	xPag := xPag + 1

Return

* ------------------------------------------------------------------------- *
* Funcao Rodape | Destinada para Imprimir o Rodape !                        *
* ------------------------------------------------------------------------- *

Static Function ImpRodape

	Li := Li + 1
	@ Li,000 PSAY Replicate("*",135)
	Li := Li + 1
	@ Li,000 PSAY "N U M  D E  N O T A S  --------->" // Claudino - 21/12/15
	@ Li,040+3 PSAY xNumdNf // Claudino - 21/12/15
	Li := Li + 1
	@ Li,000 PSAY "T O T A I S   --------->"
	@ Li,032+3 PSAY xTotVen   Picture "@E 999,999,999.99"
	@ Li,045+3 PSAY xTotLiq   Picture "@E 999,999,999.99"
	@ Li,061+3 PSAY xTotCusto Picture "@E 999,999,999.99"
	@ Li,101+3 PSAY xTotCusto / xTotLiq
	//total_margem := 0 // Claudino - 21/12/15
	//total_margem := ((xTotVen/xTotCusto)-1)*100 // Claudino - 21/12/15
	//@ Li,117+3 PSAY TOTAL_MARGEM Picture "@E 999.99" // Claudino - 21/12/15
	Li := Li + 1
	@ Li,000 PSAY Replicate("*",135)
	Eject
	
Return