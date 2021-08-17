#include "TBICONN.CH"
#include "TBICODE.CH"
#include "rwmake.ch"        
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ RdMake   ³ B4BROT02 ³ Autor ³ Anderson Lima        ³ Data ³ 24/09/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Impressao de Etiqueta de Volume para Expedicao            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Faturamento                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Alteracoes³                                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function B4BROT02()
 
PRIVATE cPerg     := "B4BROT02"  
PRIVATE cCadastro := "Emissao de Etiqueta de Volume - Expedicao"
PRIVATE aSays     := {}
PRIVATE aButtons  := {}
PRIVATE nOpc      := 0


aRegs := {}
Aadd( aRegs,{ cPerg, "01","Nota Fiscal       ?","Nota Fiscal      ?","Nota Fiscal       ?","mv_ch1","C", 9,0,0,"G",;
      "                                                            ",;
      "mv_par01       ","               ","               ","               ","                              ",;
      "               ","               ","               ","               ","                              ",;
      "               ","               ","               ","               ","                              ",;
      "               ","               ","               ","               ","                              ",;
      "               ","               ","               ","               ","                              ",;
      "   ", "   " } )
Aadd( aRegs,{ cPerg, "02","Serie             ?","Serie            ?","Serie             ?","mv_ch2","C", 3,0,0,"G",;
      "                                                            ",;
      "mv_par02       ","               ","               ","               ","                              ",;
      "               ","               ","               ","               ","                              ",;
      "               ","               ","               ","               ","                              ",;
      "               ","               ","               ","               ","                              ",;
      "               ","               ","               ","               ","                              ",;
      "   ", "   " } )
Aadd( aRegs,{ cPerg, "03","Etiqueta Modelo   ?","Etiqueta Modelo  ?","Etiqueta Modelo   ?","mv_ch5","N", 1,0,0,"C",;
      "                                                            ",;
      "mv_par03       ","6181 - PIMACO  ","6181 - PIMACO  ","6181 - PIMACO  ","                              ",;
      "               ","6183 - PIMACO  ","6183 - PIMACO  ","6183 - PIMACO  ","                              ",;
      "               ","ZEBRA - LPT1   ","ZEBRA - LPT1   ","ZEBRA - LPT1   ","                              ",;
      "               ","ZEBRA - COM1   ","ZEBRA - COM1   ","ZEBRA - COM1   ","                              ",;
      "               ","               ","               ","               ","                              ",;
      "   ", "   " } )

ValidPerg( aRegs, cPerg )
Pergunte(cPerg,.F.)


   AADD(aSays,"Este programa tem o objetivo de emitir as etiquetas de volumes")
   AADD(aSays,"das NFs para Expedicao.                                       ")
   AADD(aSays,"                                                              ")
   AADD(aButtons,{5,.T.,{|| Pergunte(cPerg,.T.)       }})
   AADD(aButtons,{1,.T.,{|| (nOpc := 0, FechaBatch()) }})
   AADD(aButtons,{2,.T.,{|| (nOpc := 1, FechaBatch()) }})
   FormBatch(cCadastro, aSays, aButtons)


If nOpc == 0
   
   Processa({|| FProcessa()},cCadastro)

Return .T.

Else

Return .T.

EndIf

// ========================================================================= \\
Static Function FProcessa()
// ========================================================================= \\

Local oPr, oDlg, oBtn1, oBtn2, oBtn3, nLin, nCol, nEtqde:=0, nEtqate:=0								
Local lContImp := .T.																				
Local cCodACD																						

Private oFont08     := TFont():New("Arial",10,10,,.F.,,,,.T.,.F.) 
Private oFont10     := TFont():New("Arial",10,10,,.F.,,,,.T.,.F.) 
Private oArial08	:= TFont():New("Arial",08,08,,.F.,,,,.T.,.F.)
Private oArial10	:= TFont():New("Arial",10,10,,.F.,,,,.T.,.F.)
Private oArial14	:= TFont():New("Arial",14,14,,.F.,,,,.T.,.F.)
Private oArial10N	:= TFont():New("Arial",10,10,,.T.,,,,.T.,.F.)
Private oArial14N	:= TFont():New("Arial",14,14,,.T.,,,,.T.,.F.)
Private oArial15N	:= TFont():New("Arial",15,15,,.T.,,,,.T.,.F.)
Private oArial20N	:= TFont():New("Arial",20,20,,.T.,,,,.T.,.F.)
Private oArial24N	:= TFont():New("Arial",24,24,,.T.,,,,.T.,.F.)
Private oArial28N	:= TFont():New("Arial",28,28,,.T.,,,,.T.,.F.)
Private oArial30N	:= TFont():New("Arial",30,30,,.T.,,,,.T.,.F.)
Private oArial36N	:= TFont():New("Arial",36,36,,.T.,,,,.T.,.F.)

dbSelectArea("SA1")
dbSetOrder(1)

dbSelectArea("SA2")
dbSetOrder(1)

dbSelectArea("SA4")
dbSetOrder(1)

dbSelectArea("SB1")
dbSetOrder(1)

dbSelectArea("SD2")
dbSetOrder(3)

dbSelectArea("SF2")
dbSetOrder(1)
dbSeek(xFilial("SF2")+MV_PAR01+MV_PAR02)

ProcRegua(RecCount())

If MV_PAR03 = 3 .Or. MV_PAR03 = 4 		// Modelo TERMICA - ZEBRA TLP 2844 --> MV_PAR03-->3=LPT1;4=COM1
	
	nMemoria := Nil
	If MV_PAR03 = 3
		cPorta  := "LPT1"
	ElseIf MV_PAR03 = 4
		cPorta  := "COM1:9600,n,8,1"	//"COM1:9600,n,8,2"
		nMemoria := 512		 			// 512Kb
	EndIf
	cModelo := "ELTRON"					// PADRAO EPL
	cLogo   := "SIGA.GRF"
	
  //	MSCBPRINTER( cModelo, cPorta,,,.F.,,,,nMemoria)
	    MSCBPRINTER("S400","LPT1",,)                     //Seta tipo de impressora no padrao ZPL
		MSCBCHKStatus(.F.)
	//	MSCBLOADGRF(cLogo)
	
	While !EOF() .And. F2_FILIAL+F2_DOC+F2_SERIE <= xFilial("SF2")+MV_PAR01+MV_PAR02
		
		IncProc("Imprimindo NF No."+SF2->F2_DOC+" "+SF2->F2_SERIE)
		
		If !SF2->F2_TIPO $ "D;B"
			cLabel  := "Cod.Cliente:"
			
			SA1->(dbSeek(xFilial("SA1")+SF2->(F2_CLIENTE+F2_LOJA)))
			SD2->(dbSeek(xFilial("SD2")+SF2->F2_DOC+SF2->F2_SERIE))
			cNumped :=SD2->D2_PEDIDO
		/*			  	
			If SF2->F2_TIPO $ 'NCPISTO' .And. ( ( SF2->F2_CLIENTE+SF2->F2_LOJA = "02025701" .And. SM0->M0_CODIGO+SM0->M0_CODFIL = "0101" ) .Or.;
				( SF2->F2_CLIENTE+SF2->F2_LOJA = "04876001" .And. SM0->M0_CODIGO+SM0->M0_CODFIL = "0106" ) .Or.;
				( SF2->F2_CLIENTE+SF2->F2_LOJA = "02025709" .And. SM0->M0_CODIGO+SM0->M0_CODFIL = "0109" ) .Or.;
				( SF2->F2_CLIENTE+SF2->F2_LOJA = "00187101" .And. SM0->M0_CODIGO+SM0->M0_CODFIL = "0301" ) )						
				cNome   := SA1->A1_NOME
				cReduz  := SA1->A1_NREDUZ
				cEnd    := ALLTRIM(SA1->A1_ENDENT)+ " " +ALLTRIM(SA1->A1_COMPLEM) 
				cBairro := SA1->A1_BAIENT
				cMun    := SA1->A1_MUNENT
				cEst    := SA1->A1_ESTENT
				cCEP    := SA1->A1_CEPENT 
		*/		
			If SF2->F2_TIPO $ 'NCPISTO' .And. !EMPTY(SA1->A1_ENDENT)
				cNome   := SA1->A1_NOME
				cReduz  := SA1->A1_NREDUZ
				cEnd    := ALLTRIM(SA1->A1_ENDENT)+ " " +ALLTRIM(SA1->A1_COMPLEM)
				cBairro := SA1->A1_BAIRROE
				cMun    := SA1->A1_MUNE
				cEst    := SA1->A1_ESTE
				cCEP    := SA1->A1_CEPE
			Else
				cNome   := SA1->A1_NOME
				cReduz  := SA1->A1_NREDUZ
				cEnd    := ALLTRIM(SA1->A1_END)+ " " +ALLTRIM(SA1->A1_COMPLEM)
				cBairro := SA1->A1_BAIRRO
				cMun    := SA1->A1_MUN
				cEst    := SA1->A1_EST
				cCEP    := SA1->A1_CEP
			EndIf
		Else
			SA2->(dbSeek(xFilial("SA2")+SF2->(F2_CLIENTE+F2_LOJA)))
			cNome   := SA2->A2_NOME
			cReduz  := SA2->A2_NREDUZ
			cEnd    := ALLTRIM(SA2->A2_END)+ " " +ALLTRIM(SA2->A2_COMPLEM)
			cBairro := SA2->A2_BAIRRO
			cMun    := SA2->A2_MUN
			cEst    := SA2->A2_EST        
			cCEP    := SA2->A2_CEP            
			cLabel:= "Cod.Fornecedor:"
		EndIf
		
		cCompl := ALLTRIM(SUBSTR(cEnd,41))
		//cCompl += IIF(!EMPTY(cCompl),"-","")
		cEnd   := SUBSTR(cEnd,1,40)
		
		SA4->(dbSeek(xFilial("SA4")+SF2->F2_TRANSP))
		cCodTransp := PADR(SF2->F2_TRANSP,06)
		cTransp    := ALLTRIM(SA4->A4_NREDUZ)	
		
		nVolumes := SF2->F2_VOLUME1
		cCodACD  := PADR(SF2->F2_DOC,09)+PADR(SF2->F2_SERIE,03)
         
		nEtqde   := 1		  																	
		nEtqate  := nVolumes 																	
		
		// --> DIALOG para impressao de Etiqueta De/Ate 							  			
		DEFINE MSDIALOG oDlg FROM 0,0 TO 100,180 PIXEL TITLE "Impressao Etiquetas"
		@ 05,05 Say OemToAnsi("Etiqueta De")  Size 35,10
		@ 05,45 Get nEtqde  PICTURE "@E 9999"  Size 20,15 VALID (nEtqDe  <= nVolumes) 
		@ 20,05 Say OemToAnsi("Etiqueta Ate") Size 35,10
		@ 20,45 Get nEtqate PICTURE "@E 9999"  Size 20,15 VALID (nEtqAte <= nVolumes .And. nEtqAte >= nEtqDe) 
		@ 35,20 BMPBUTTON TYPE 1 Action  Close(oDlg)
		@ 35,55 BMPBUTTON TYPE 2 Action (Close(oDlg) , lContImp:=.F.)
		ACTIVATE MSDIALOG oDlg CENTERED

		If !lContImp																			
			Return(.T.)
		EndIf

		For nVolume := nEtqde To nEtqate  														
			
			MSCBBEGIN(1,6) // Inicio Formacao da imagem da etiqueta
			MSCBSAYBAR(10,03,cCodACD 													  , "N","MB08",5.0,.F.,.F.,.F.,,3,4,.T.,.F.,"1",.F.) 				            	                
          //MSCBSAY(063,03, OEMTOANSI("Volumes" )             							  , "N", "0", "052,055") 
			MSCBSAY(066,03, OEMTOANSI("Volumes" )             							  , "N", "0", "052,055")		
		  //MSCBSAY(005,10, OEMTOANSI("NF No"+SF2->F2_DOC+"/"+SF2->F2_SERIE)             , "N", "0", "052,055")
			MSCBSAY(005,12, OEMTOANSI("NF "+SF2->F2_DOC)             , "N", "0", "078,081")
		  //MSCBSAY(063,10, OEMTOANSI("  "+STRZERO(nVolume,6)+"/"+STRZERO(nVolumes,6))    , "N", "0", "042,045")  
			MSCBSAY(066,10, OEMTOANSI("  "+STRZERO(nVolume,6)+"/"+STRZERO(nVolumes,6))    , "N", "0", "042,045")
		  //MSCBSAY(005,20 /*20*/, OEMTOANSI(PADR(cNome,30))                              , "N", "0", "030,025") 
			MSCBSAY(005,25 /*20*/, OEMTOANSI(PADR(cNome,30))                              , "N", "0", "030,025")
		  //MSCBSAY(005,25 /*25*/, OEMTOANSI(PADR(cEnd,45))                               , "N", "0", "030,025") 
		    MSCBSAY(005,30 /*25*/, OEMTOANSI(Alltrim(cEnd)+" "+Alltrim(Substring(cCompl,1,20)))                               , "N", "0", "030,025") 
		  //MSCBSAY(005,30 /*30*/, OEMTOANSI(PADR(cCompl+cBairro,45))                     , "N", "0", "030,025")
		  //MSCBSAY(005,35 /*35*/, OEMTOANSI(PADR(cMun,30)+"-"+cEst)                      , "N", "0", "030,025")  
		  //MSCBSAY(005,35 /*35*/, OEMTOANSI(Alltrim(Substring(cCompl,21,50))+" "+Alltrim(Substring(cMun,1,30))+"-"+cEst)                      , "N", "0", "030,025")
		    MSCBSAY(005,35 /*35*/, OEMTOANSI(Alltrim(Substring(cBairro,1,30))+"-"+Alltrim(Substring(cMun,1,30))+"-"+cEst)                      , "N", "0", "030,025")
		  //MSCBSAY(055,35 /*40*/, OEMTOANSI(" -"+TRANSFORM(cCEP,"@R #####-###"))         , "N", "0", "030,025")
			MSCBSAY(005,45 /*45*/, OEMTOANSI("TRANSPORTADORA:")                           , "N", "0", "030,025")
			MSCBSAY(032,43 /*45*/, OEMTOANSI(PADR(cTRANSP,20))                            , "N", "0", "052,055") 
		  //MSCBSAY(095,15 /*45*/, OEMTOANSI("**Pedido: "+PADR(cNumped,06)+"**" )         , "B", "0", "030,025") 
   	      //MSCBSAYBAR(05,49,cCodTransp  											      , "N","MB08",5.0,.F.,.F.,.F.,,3,4,.T.,.F.,"1",.F.) 				            	                 
			
			MSCBEND() // Finaliza a formacao da imagem da etiqueta
			
		Next 
		
		dbSelectArea("SF2")
		dbSkip()
	EndDo
	
	MSCBCLOSEPRINTER()
	
Else
	
	nMargTop := 100 		// 200
	nMargEsq := 020 		// 200
	nLin     := nMargTop 	// Linha inicial
	nCol     := nMargEsq 	// Coluna inicial
	nColAtu  := 1        	// Coluna atual
	nPagina  := 1
	lNewPage := .F.
	
	oPr:= tAvPrinter():New( "Protheus - Etiqueta de Volumes" )
	oPr:SetPortrait()
	oPr:StartPage()
	
	While !EOF() .And. F2_FILIAL+F2_DOC+F2_SERIE <= xFilial("SF2")+MV_PAR01+MV_PAR02
		
		IncProc("Imprimindo NF No."+SF2->F2_DOC+" "+SF2->F2_SERIE)
		
		If !SF2->F2_TIPO $ "D;B"
			SA1->(dbSeek(xFilial("SA1")+SF2->(F2_CLIENTE+F2_LOJA)))
			cNome := SA1->A1_NOME
			cReduz:= SA1->A1_NREDUZ
			cLabel:= "Cod.Cliente:"
		Else
			SA2->(dbSeek(xFilial("SA2")+SF2->(F2_CLIENTE+F2_LOJA)))
			cNome := SA2->A2_NOME
			cReduz:= SA2->A2_NREDUZ
			cLabel:= "Cod.Fornecedor:"
		EndIf
		
		nVolumes := SF2->F2_VOLUME1

		nEtqde   := 1		  																	
		nEtqate  := nVolumes 																	
		
		//--> DIALOG para impressao de Etiqueta De/Ate 							  				
		DEFINE MSDIALOG oDlg FROM 0,0 TO 100,180 PIXEL TITLE "Impressao Etiquetas"
		@ 05,05 Say OemToAnsi("Etiqueta De")  Size 35,10
		@ 05,45 Get nEtqde  PICTURE "@E 9999"  Size 20,10 VALID (nEtqDe  <= nVolumes) 
		@ 20,05 Say OemToAnsi("Etiqueta Ate") Size 35,10
		@ 20,45 Get nEtqate PICTURE "@E 9999"  Size 20,10 VALID (nEtqAte <= nVolumes .And. nEtqAte >= nEtqDe)
		@ 35,20 BMPBUTTON TYPE 1 Action  Close(oDlg)
		@ 35,55 BMPBUTTON TYPE 2 Action (Close(oDlg) , lContImp:=.F.)
		ACTIVATE MSDIALOG oDlg CENTERED

		If !lContImp																			
			Return(.T.)
		EndIf
		
		For nVolume := nEtqde To nEtqate  														
		
			If lNewpage
				lNewpage:= .F.
				oPr:EndPage()
				oPr:StartPage()
			EndIf
			
			If MV_PAR03 = 1 //6181 - PIMACO           - 25,4 X 101,6
				
				oPr:Say(nlin+000,nCol+050 ,OEMTOANSI("NF "+SF2->F2_DOC+"/"+SF2->F2_SERIE+" "+DTOC(SF2->F2_EMISSAO)) , oArial28N )
				oPr:Say(nlin+130,nCol+050 ,OEMTOANSI(PADR(cNome,30))                                                , oArial14N )
				oPr:Say(nlin+210,nCol+050 ,OEMTOANSI(STRZERO(nVolume,4)+" / "+STRZERO(nVolumes,4))                  , oArial10N ) 
				
				nLinhas := 300
				
			ElseIf MV_PAR03 = 2 //6183 - PIMACO          - 50,8 X 101,6
				
				oPr:Say(nlin+000,nCol+050 ,OEMTOANSI("NF "+SF2->F2_DOC+"/"+SF2->F2_SERIE+" "+DTOC(SF2->F2_EMISSAO)) , oArial30N )
				oPr:Say(nlin+150,nCol+050 ,OEMTOANSI(PADR(cNome,30))                                                , oArial15N )
				oPr:Say(nlin+300,nCol+050 ,OEMTOANSI("Endereco: ")                                                  , oArial20N )
				oPr:Say(nLin+450,nCol+050 ,OEMTOANSI(STRZERO(nVolume,4)+" / "+STRZERO(nVolumes,4))                  , oArial10  )
				
				nLinhas := 600
				
			EndIf
						
			nCol += 1250 //1050
			nColAtu++ // incrementa o contador de colunas
			
			If nColAtu > 2 // 2 COLUNAS
				nLin    += nLinhas // Pula uma linha
				nColAtu := 1  // Volta para a coluna inicial ( Contador )
				nCol    := nMargEsq // Volta para a coluna inicial
			EndIf
			
			If nLin > 3000
				nLin    := nMargTop
				nCol    := nMargEsq
				nColAtu := 1
				lNewpage:= .T.
			EndIf
		Next
		
		dbSelectArea("SF2")
		dbSkip()
	EndDo
	
	oPr:EndPage()
	oPr:Preview()
	oPr:End()
EndIf

Return(.T.)