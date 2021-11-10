#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "RPTDEF.CH"
#INCLUDE "FWPrintSetup.ch"

#DEFINE POS_SEQ				1	
#DEFINE POS_CODE			2
#DEFINE POS_QTY_PIECES		3
#DEFINE POS_DESCRIPTION		4
#DEFINE POS_NCM				5
#DEFINE POS_CBM				6
#DEFINE POS_QTY_BOXES		7
#DEFINE POS_NET_WEIGHT		8
#DEFINE POS_GROSS_WEIGHT	9
#DEFINE POS_PRICE_UNIT		10
#DEFINE POS_TOTAL_PRICE		11

/*
Rotina: OUROR032
Descricao: Rotina para geração da Proforma Invoice por PO
Autor: Rodrigo Nunes
Data: 05/11/2021
*/
User Function OUROR032()
	Local lPreview     := .F.
	Local cHora		   := Time()
	Private aInfNf     := {}
	Private nPrivate   := 0
	Private nPrivate2  := 0
	Private nXAux	   := 0
	Private lArt488MG  := .F.
	Private lArt274SP  := .F.
	Private oProforma  := Nil
	Private nHPage     := 2300
	Private nVPage     := 2950
	Private nPaginas   := 1		
	Private cPerg	   := "EI252B"
	Private oImposto
	Private cDia 	   := ""
	Private cMes 	   := ""
	Private cAno 	   := ""
	Private cMesExt    := ""
	Private cOrigPort  := ""
	Private cDestPort  := ""
	Private cIncoter   := ""
	Private cMoedaPO   := ""
	Private dETDpo     := CTOD("")
	Private dETApo     := CTOD("")
	Private cLOTENR	   := ""
	Private cProduOBS  := ""
	Private cPackOBS   := ""
	Private cProgrPO   := ""
	Private cMenCondPG := ""
	Private cPaisFor   := ""
	Private cPaisForD  := ""
	Private nPerConPG1 := 0
	Private nPerConPG2 := 0
	Private nPerConPG3 := 0
	Private nPerConPG4 := 0
	Private nPerConPG5 := 0
	Private nPerConPG6 := 0
	Private nPerConPG7 := 0
	Private nPerConPG8 := 0
	Private nPerConPG9 := 0
	Private nPerConPG0 := 0
	Private cNomImp    := ""
	Private cEndImp    := ""
	Private cMunImp    := ""
	Private cCEPImp    := ""
	Private cTELImp    := ""
	Private cCNPJImp   := ""
	Private cNomBuy    := "" 
	Private cEndBuy    := "" 
	Private cMunBuy    := "" 
	Private cCEPBuy    := "" 
	Private cTELBuy    := "" 
	Private cCNPJBuy   := "" 
	Private dataHora   := CTOD("")
	Private cNomExp    := ""
	Private cEndExp    := ""
	Private cBaiExp    := ""
	Private cNomMan	   := ""
	Private cEndMan	   := ""
	Private cBaiMan	   := ""
	Private cMsgBan    := ""
	Private cNomBan    := ""
	Private cSwiBan    := ""
	Private cEndBan    := ""
	Private cBenBan    := ""
	Private cCusBan    := ""
	Private cAccBan    := ""
	Private nTotal     := 0
	Private nCbm 	   := 0
	Private nBoxes 	   := 0
	Private nWeight    := 0
	Private nCross     := 0
	Private nQtdTOT	   := 0
	Private cDescLI	   := ""
	Private dDtLPrd    := CTOD("")
	Private cMenVLR	   := ""
	Private aItemPO	   := {}
	Private cDtImp	   := ""
	Private nIni	   := 0
	Private lFim	   := .F.
	Private oFont07    := TFont():New("Arial",07,07,,.F.,,,,.T.,.F.)
	Private oFont08    := TFont():New("Arial",08,08,,.F.,,,,.T.,.F.)
	Private oFont08n   := TFont():New("Arial",08,08,,.T.,,,,.T.,.F.)
	Private oFont30N   := TFont():New("Arial",30,30,,.T.,,,,.T.,.F.)
	Private oFont12    := TFont():New("Arial",12,12,,.F.,,,,.T.,.F.)
	Private oFont09    := TFont():New("Arial",09,09,,.F.,,,,.T.,.F.)
	Private oFont09n   := TFont():New("Arial",09,09,,.T.,,,,.T.,.F.)
	Private oFont15n   := TFont():New("Arial",15,15,,.T.,,,,.T.,.F.)
	Private oFont10n   := TFont():New("Arial",10,10,,.T.,,,,.T.,.F.)
	Private oFont10    := TFont():New("Arial",10,10,,.F.,,,,.T.,.F.)

	Default cDtHrRecCab := ""
	Default dDtReceb    := CToD("")

	lPreview := .T.
	oProforma := FWMSPrinter():New("PROFORMA"+ DtoS(dDataBase)+ "_" + SubStr(cHora,1,2) + SubStr(cHora,4,2), IMP_PDF)
	oProforma:SetPortrait()
	oProforma:SetPaperSize(DMPAPER_A4)

	BuscaDados()

	If Empty(aItemPO)
		Return
	ElseIf Len(aItemPO) > 212
		Alert("Proforma não será impressa, limite de intes permitidos são 212")
		Return
	ElseIf Len(aItemPO) <= 31
		//pagina unica
		oProforma:StartPage()
			nPaginas := 1
			MontaCabec() //Monta Cabeçalho
			MontaEmit()  //Monta Emitente
			MontaItPU()  //Monta Proforma com unica pagina
			MontaTot()   //Monta Totalizadores
			MontaRod()	 //Monta Rodapé
		oProforma:EndPage()
	ElseIf Len(aItemPO) <= 121
		//duas paginas 
		oProforma:StartPage()
			nPaginas := 1
			MontaCabec() //Monta Cabeçalho
			MontaEmit()  //Monta Emitente
			MontaItP1()	 //Monta Pagina 1  
		oProforma:EndPage()
		oProforma:StartPage()
			nPaginas := 2
			MontaCabec() //Monta Cabeçalho
			MontaItP2()  //Monta Pagina 2
			MontaTot()   //Monta Totalizadores
			MontaRod()   //Monta Rodapé
		oProforma:EndPage()
	ElseIf Len(aItemPO) <= 212
		//tres paginas ou mais
		oProforma:StartPage()
			nPaginas := 1
			MontaCabec() 	//Monta Cabeçalho
			MontaEmit() 	//Monta Emitente
			MontaItP1() 	//Monta Pagina 1  
		oProforma:EndPage()
		oProforma:StartPage()
			nPaginas := 2
			MontaCabec() //Monta Cabeçalho
			MontaItUN()  //Monta Pagina so para itens para demais paginas 
		oProforma:EndPage()
		oProforma:StartPage()
			nPaginas := 3
			MontaCabec() //Monta Cabeçalho
			MontaItP2()  //Monta Pagina 2
			MontaTot()   //Monta Totalizadores
			MontaRod()   //Monta Rodapé
		oProforma:EndPage()
	EndIf

	oProforma:Print()
Return
/*
Rotina: BuscaDados
Descricao: Rotina responsavel por buscar todos os dados que seram impressos na Proforma
Autor: Rodrigo Nunes
Data: 05/11/2021
*/
Static Function BuscaDados()
	If !Pergunte(cPerg,.T.)  
		Return
	Endif       

	dbSelectArea("SW3")
	dbSetOrder(01)

	if ! dbSeek(xFilial("SW3")+mv_par01)
		alert('PEDIDO NAO LOCALIZADO !')
	endif

	dbSelectArea("SW2")
	dbSetOrder(01)
	dbSeek(xFilial("SW2")+mv_par01)
	
	dbSelectArea("SWB")
	dbSetOrder(01)
	dbSeek(xFilial("SWB")+mv_par01)

	cDia 	:= SubStr(DtoS(SW2->W2_PO_DT),7,2)
	cMes 	:= SubStr(DtoS(SW2->W2_PO_DT),5,2)
	cAno 	:= SubStr(DtoS(SW2->W2_PO_DT),1,4)
	cMesExt := MesExtenso(Month(SW2->W2_PO_DT))
	cDtImp  := cAno+"/"+cMes+"/"+cDia //cDia+" de "+cMesExt+" de "+cAno

	cOrigPort := TRIM(Posicione("SY9",2,xFilial("SY9")+SW2->W2_ORIGEM,"Y9_DESCR"))	//Porto Origem
	cDestPort := TRIM(Posicione("SY9",2,xFilial("SY9")+SW2->W2_DEST	 ,"Y9_DESCR"))	//Porto Destino
	cIncoter  := SW2->W2_INCOTER		//Incoterme
	cMoedaPO  := TRIM(SW2->W2_MOEDA)	//Moeda utilizada no Pedido
	dETDpo    := SW2->W2_XDT_ETD		//ETD
	dETApo    := SW2->W2_XDT_ETA		//ETA

	cLOTENR	  := if(Empty(SW2->W2_XLOTENR),mv_par01,SW2->W2_XLOTENR)//Numero do Lote
	cProduOBS := trim(SW2->W2_XMSGPRO)								//Observacao Product
	cPackOBS  := trim(SW2->W2_XMSGPAC)								//Observacao Packging
	cProgrPO  := trim(SW2->W2_XPROGPO)								//Programacao da PO


	cMenCondPG:= TRIM(MSMM(POSICIONE("SY6",1,xFilial("SY6")+SW2->W2_COND_PA,"Y6_DESC_I"),40,1))
	cMenCondPG+= "  "+TRIM(MSMM(POSICIONE("SY6",1,xFilial("SY6")+SW2->W2_COND_PA,"Y6_DESC_I"),40,2))
	cPaisFor  := POSICIONE("SA2",1,xFilial("SA2")+SW2->W2_FORN	 	 ,"A2_PAIS")
	cPaisForD := TRIM(POSICIONE("SYA",1,xFilial("SYA")+cPaisFor		 ,"YA_PAIS_I"))

	nPerConPG1:= POSICIONE("SY6",1,xFilial("SY6")+SW2->W2_COND_PA,"Y6_PERC_01")
	nPerConPG2:= POSICIONE("SY6",1,xFilial("SY6")+SW2->W2_COND_PA,"Y6_PERC_02")
	nPerConPG3:= POSICIONE("SY6",1,xFilial("SY6")+SW2->W2_COND_PA,"Y6_PERC_03")
	nPerConPG4:= POSICIONE("SY6",1,xFilial("SY6")+SW2->W2_COND_PA,"Y6_PERC_04")
	nPerConPG5:= POSICIONE("SY6",1,xFilial("SY6")+SW2->W2_COND_PA,"Y6_PERC_05")
	nPerConPG6:= POSICIONE("SY6",1,xFilial("SY6")+SW2->W2_COND_PA,"Y6_PERC_06")
	nPerConPG7:= POSICIONE("SY6",1,xFilial("SY6")+SW2->W2_COND_PA,"Y6_PERC_07")
	nPerConPG8:= POSICIONE("SY6",1,xFilial("SY6")+SW2->W2_COND_PA,"Y6_PERC_08")
	nPerConPG9:= POSICIONE("SY6",1,xFilial("SY6")+SW2->W2_COND_PA,"Y6_PERC_09")
	nPerConPG0:= POSICIONE("SY6",1,xFilial("SY6")+SW2->W2_COND_PA,"Y6_PERC_10")
	
	dataHora:=Time() 

	//Dados do Importador
	dbSelectArea("SYT")
	dbSetOrder(01)
	dbSeek(xFilial("SYT")+SW2->W2_IMPORT)

	cNomImp := SUBSTR(SYT->YT_NOME,1,23)
	cEndImp := TRIM(SYT->YT_ENDE)+", "+Transform(SYT->YT_NR_END,"@E 999999") 
	cMunImp := TRIM(SYT->YT_BAIRRO)+" - "+TRIM(SYT->YT_CIDADE)+" - "+SYT->YT_ESTADO
	cCEPImp := "Zip Code: "+Transform(SYT->YT_CEP,"@R 99999-999") 
	cTELImp := "PHONE: "+TRIM(SYT->YT_TEL_IMP)
	cCNPJImp:= "CNPJ: "+Transform(SYT->YT_CGC,"@R 99.999.999/9999-99") 

	If SW2->W2_IMPENC == "1"
		dbSeek(xFilial("SYT")+SW2->W2_CONSIG)

		cNomBuy := SUBSTR(SYT->YT_NOME,1,23)
		cEndBuy := TRIM(SYT->YT_ENDE)+", "+Transform(SYT->YT_NR_END,"@E 999999") 
		cMunBuy := TRIM(SYT->YT_BAIRRO)+" - "+TRIM(SYT->YT_CIDADE)+" - "+SYT->YT_ESTADO
		cCEPBuy := "Zip Code: "+Transform(SYT->YT_CEP,"@R 99999-999") 
		cTELBuy := "PHONE: "+TRIM(SYT->YT_TEL_IMP)
		cCNPJBuy:= "CNPJ: "+Transform(SYT->YT_CGC,"@R 99.999.999/9999-99") 
	else
		cNomBuy := SUBSTR(SYT->YT_NOME,1,23)
		cEndBuy := TRIM(SYT->YT_ENDE)+", "+Transform(SYT->YT_NR_END,"@E 999999") 
		cMunBuy := TRIM(SYT->YT_BAIRRO)+" - "+TRIM(SYT->YT_CIDADE)+" - "+SYT->YT_ESTADO
		cCEPBuy := "Zip Code: "+Transform(SYT->YT_CEP,"@R 99999-999") 
		cTELBuy := "PHONE: "+TRIM(SYT->YT_TEL_IMP)
		cCNPJBuy:= "CNPJ: "+Transform(SYT->YT_CGC,"@R 99.999.999/9999-99") 
	EndIF

	DBSELECTAREA('SA2')
	if dbseek(XFILIAL('SA2')+SW3->W3_FORN)
		cNomExp := Alltrim(SA2->A2_NOME)
		cEndExp := Alltrim(SA2->A2_END)
		cBaiExp := Alltrim(SA2->A2_BAIRRO)
	ENDIF
	
	if dbseek(XFILIAL('SA2')+SW3->W3_FABR)
		cNomMan := Alltrim(SA2->A2_NOME)
		cEndMan := Alltrim(SA2->A2_END)
		cBaiMan := Alltrim(SA2->A2_BAIRRO)
	ENDIF

	if dbseek(XFILIAL('SA2')+SW3->W3_FORN)
		cMsgBan := "BENEFICIARY BANK:"
		cNomBan := Alltrim(SA2->A2_XBANCO)
		cSwiBan := "SWIFT CODE: "+Alltrim(SA2->A2_SWIFT)
		cEndBan := Alltrim(SA2->A2_XENDBAN)			
		cBenBan := "BENEFICIARY CUSTOMER:"		
		cCusBan := Alltrim(SA2->A2_NOME)
		cAccBan := "ACCOUNT NO: "+Alltrim(SA2->A2_XCTABAN)	
	ENDIF

	MV_PAR01:= SW3->W3_PO_NUM 
	nTotal  := 0
	nCbm 	:= 0
	nBoxes 	:= 0
	nWeight := 0
	nCross  := 0
	nQtdTOT := 0

	DbSelectArea("SW0")
	cNumSI  := POSICIONE("SW0",1,xFilial("SW0")+SW3->W3_CC+SW3->W3_SI_NUM,"W0_C1_NUM")
	dDtLPrd := POSICIONE("SC1",1,SYT->YT_X_FILIA+SW0->W0_C1_NUM,"C1_XDTLPRD")

	While SW3->(!Eof()) .And. SW3->W3_PO_NUM == MV_PAR01
		SB1->(DBSEEK(XFILIAL('SB1')+(SW3->W3_COD_I)))

		if empty(SW3->W3_TEC)
			SW3->(DbSkip())
			Loop
		Endif

		if SW3->W3_SEQ=1
			SW3->(DbSkip())
			Loop
		Endif

		cDescLI := MSMM(SB1->B1_DESC_I,40)
		cDescLI := IF( EMPTY(cDescLI), SB1->B1_DESC, cDescLI)
		cDescLI := SubStr(cDescLI,1,50)

		AADD(aItemPO,{StrZero(SW3->W3_NR_CONT,3),SW3->W3_COD_I,SW3->W3_QTDE,cDescLI,SW3->W3_TEC,SW3->W3_XCUBAGE,SW3->W3_XQTDEM1,(SW3->W3_QTDE * SW3->W3_PESOL),(SW3->W3_QTDE * SW3->W3_PESO_BR),SW3->W3_PRECO,(SW3->W3_QTDE * SW3->W3_PRECO)})
		
		nTotal	+= (SW3->W3_QTDE * SW3->W3_PRECO)	//Valor Total
		nCbm	+= SW3->W3_XCUBAGE					//cubagem
		nBoxes	+= SW3->W3_XQTDEM1					//Caixas
		nWeight	+= (SW3->W3_QTDE * SW3->W3_PESOL)	//Peso Liquido
		nCross	+= (SW3->W3_QTDE * SW3->W3_PESO_BR) //Peso Bruto
		nQtdTOT += SW3->W3_QTDE						//Quantidade Total

		SW3->(dbSkip())
	
	EndDo

	IF nPerConPG1>0
		cMenVLR += " | "+cMoedaPO+" "+Transform((ntotal*nPerConPG1)/100,"@E 9,999,999.99")
	Endif
	IF nPerConPG2>0
		cMenVLR += " | "+cMoedaPO+" "+Transform((ntotal*nPerConPG2)/100,"@E 9,999,999.99")
	Endif
	IF nPerConPG3>0
		cMenVLR += " | "+cMoedaPO+" "+Transform((ntotal*nPerConPG3)/100,"@E 9,999,999.99")
	Endif
	IF nPerConPG4>0
		cMenVLR += "|"+cMoedaPO+" "+Transform((ntotal*nPerConPG4)/100,"@E 9,999,999.99")
	Endif
	IF nPerConPG5>0
		cMenVLR += "|"+cMoedaPO+" "+Transform((ntotal*nPerConPG5)/100,"@E 9,999,999.99")
	Endif
	IF nPerConPG6>0
		cMenVLR += "|"+cMoedaPO+" "+Transform((ntotal*nPerConPG6)/100,"@E 9,999,999.99")
	Endif
	IF nPerConPG7>0
		cMenVLR += "|"+cMoedaPO+" "+Transform((ntotal*nPerConPG7)/100,"@E 9,999,999.99")
	Endif
	IF nPerConPG8>0
		cMenVLR += "|"+cMoedaPO+" "+Transform((ntotal*nPerConPG8)/100,"@E 9,999,999.99")
	Endif
	IF nPerConPG9>0
		cMenVLR += "|"+cMoedaPO+" "+Transform((ntotal*nPerConPG9)/100,"@E 9,999,999.99")
	Endif
	IF nPerConPG0>0
		cMenVLR += "|"+cMoedaPO+" "+Transform((ntotal*nPerConPG0)/100,"@E 9,999,999.99")
	Endif

Return

/*
Rotina: MontaCabec
Descricao: Rotina responsavel por montar o cabecalho da Proforma
Autor: Rodrigo Nunes
Data: 05/11/2021
*/
Static Function MontaCabec()	
	Local cBitMap := "Lgrl01.Bmp"
	//linha,coluna,fim linha,fim coluna
	oProforma:Box(025,025,nVPage,nHPage) 				// BOX TOTAL DA TELA
	oProforma:Box(025,025,150,600) 						// BOX LOGO
	oProforma:Box(025,600,150,1700) 					// BOX TITULO
	oProforma:SayBitmap(035,075,cBitMap,450,100)		
	oProforma:Box(025,1700,150,nHPage) 					// BOX PAGINAÇÃO
	oProforma:Say(115, 700, "PROFORMA INVOICE", oFont30N)
	oProforma:Say(080, 1800, "ISSUE DATE: " + cDtImp, oFont12)
	oProforma:Say(120, 1800, "PAGE: " + cValtoChar(nPaginas), oFont12)

Return

/*
Rotina: MontaEmit
Descricao: Rotina responsavel por montar o emitente da Proforma
Autor: Rodrigo Nunes
Data: 05/11/2021
*/
Static Function MontaEmit()	
	//linha,coluna,fim linha,fim coluna
	oProforma:Box(151,025,500,783) 			//BOX EXPORTER
	oProforma:Say(191,050, "EXPORTER", oFont15n)
	oProforma:Say(220,050,UPPER(cNomExp),oFont08)
	oProforma:Say(250,050,UPPER(cEndExp),oFont08)
	oProforma:Say(280,050,UPPER(cBaiExp),oFont08)

	oProforma:Box(151,783,500,1541) 		//BOX MANUFACTER
	oProforma:Say(191,808, "MANUFACTURER", oFont15n)
	oProforma:Say(220,808,UPPER(cNomMan),oFont08)
	oProforma:Say(250,808,UPPER(cEndMan),oFont08)
	oProforma:Say(280,808,UPPER(cBaiMan),oFont08)

	oProforma:Box(151,1538,500,nHPage)		//BOX BANKING INFORMATION
	oProforma:Say(191,1563, "BANKING INFORMATION", oFont15n)
	oProforma:Say(220,1563,UPPER(cMsgBan),oFont08n)
	oProforma:Say(250,1563,UPPER(cNomBan),oFont08)
	oProforma:Say(280,1563,UPPER(cSwiBan),oFont08)
	oProforma:Say(310,1563,UPPER(cEndBan),oFont08)
	oProforma:Say(340,1563,UPPER(cBenBan),oFont08n)
	oProforma:Say(370,1563,UPPER(cCusBan),oFont08)
	oProforma:Say(400,1563,UPPER(cAccBan),oFont08)

	oProforma:Box(501,025,850,783) 			//BOX ...
	oProforma:Say(541,050, "", oFont15n)
	
	oProforma:Box(501,783,850,1541)			//BOX CONSIGNEE/IMPORTER
	oProforma:Say(541,808, "CONSIGNEE/IMPORTER", oFont15n)
	oProforma:Say(570,808,UPPER(cNomImp),oFont08)
	oProforma:Say(600,808,UPPER(cEndImp),oFont08)
	oProforma:Say(630,808,UPPER(cMunImp),oFont08)
	oProforma:Say(660,808,UPPER(cCEPImp),oFont08)
	oProforma:Say(690,808,UPPER(cTELImp),oFont08)
	oProforma:Say(720,808,UPPER(cCNPJImp),oFont08)
	
	oProforma:Box(501,1538,850,nHPage)		//BOX NOTIFY/BUYER
	oProforma:Say(541,1563, "NOTIFY/BUYER", oFont15n)
	oProforma:Say(570,1563,UPPER(cNomBuy),oFont08)
	oProforma:Say(600,1563,UPPER(cEndBuy),oFont08)
	oProforma:Say(630,1563,UPPER(cMunBuy+' - BRASIL'),oFont08)
	oProforma:Say(660,1563,UPPER(cCEPBuy),oFont08)
	oProforma:Say(690,1563,UPPER(cTELBuy),oFont08)
	oProforma:Say(720,1563,UPPER(cCNPJBuy),oFont08)
Return

/*
Rotina: MontaItPU
Descricao: Rotina responsavel por montar a Proforma em pagina unica
Autor: Rodrigo Nunes
Data: 05/11/2021
*/
Static Function MontaItPU()	
	Local nRow	:= 940
	Local nlx	:= 0
	//linha,coluna,fim linha,fim coluna

	oProforma:Box(852,025,1851,100) 				
	oProforma:Say(892,035, "SEQ", oFont09)
	
	oProforma:Box(852,100,1851,300) 				
	oProforma:Say(892,110, "CODE", oFont09)
	
	oProforma:Box(852,300,1851,460) 					
	oProforma:Say(892,310, "QTY PIECES",oFont09)

	oProforma:Box(852,460,1851,1030) 				
	oProforma:Say(892,470, "DESCRIPTION",oFont09)

	oProforma:Box(852,1030,1851,1150) 				
	oProforma:Say(892,1040, "NCM",oFont09)

	oProforma:Box(852,1150,1851,1300) 				
	oProforma:Say(892,1160, "CBM(M3)",oFont09)
	
	oProforma:Box(852,1300,1851,1450) 				
	oProforma:Say(892,1310, "QTY BOXES",oFont09)
	
	oProforma:Box(852,1450,1851,1610) 				
	oProforma:Say(892,1460, "NET WEIGHT",oFont09)
	
	oProforma:Box(852,1610,1851,1820) 				
	oProforma:Say(892,1620, "GROSS WEIGHT",oFont09)
	
	oProforma:Box(852,1820,1851,2060) 				
	oProforma:Say(892,1830, "PRICE UNIT",oFont09)
	
	oProforma:Box(852,2060,1851,nHPage) 			
	oProforma:Say(892,2070, "TOTAL PRICE",oFont09)
	
	oProforma:Line(920,025,920, nHPage)

	For nlx := 1 to Len(aItemPO)
		oProforma:Say(nRow,040,aItemPO[nlx][POS_SEQ],oFont08)													//SEQ													
		oProforma:Say(nRow,110,aItemPO[nlx][POS_CODE],oFont08)													//CODE
		oProforma:Say(nRow,315,Transform(aItemPO[nlx][POS_QTY_PIECES],"@E 999,999,999.999"),oFont08)			//QTY PIECES									
		oProforma:Say(nRow,470,aItemPO[nlx][POS_DESCRIPTION],oFont08)											//DESCRIPTION									
		oProforma:Say(nRow,1040,aItemPO[nlx][POS_NCM],oFont08)													//NCM
		oProforma:Say(nRow,1175,Transform(aItemPO[nlx][POS_CBM],"@E 999,999.9999"),oFont08,,,,1)				//CBM(M3)								
		oProforma:Say(nRow,1325,Transform(aItemPO[nlx][POS_QTY_BOXES],"@E 999,999.9999"),oFont08,,,,1)			//QTY BOXES								
		oProforma:Say(nRow,1470,Transform(aItemPO[nlx][POS_NET_WEIGHT],"@E 999,999.999999"),oFont08,,,,1)		//NET WEIGHT									
		oProforma:Say(nRow,1675,Transform(aItemPO[nlx][POS_GROSS_WEIGHT],"@E 999,999.999999"),oFont08,,,,1)		//GROSS WEIGHT									
		oProforma:Say(nRow,1885,Transform(aItemPO[nlx][POS_PRICE_UNIT],"@E 999,999,999.99999"),oFont08,,,,1)	//PRICE UNIT											
		oProforma:Say(nRow,2125,Transform(aItemPO[nlx][POS_TOTAL_PRICE],"@E 999,999,999.99999"),oFont08,,,,1)	//TOTAL PRICE											
		nRow += 030
	Next
	
Return

/*
Rotina: MontaItP1
Descricao: Rotina responsavel por montar a Proforma pagina 1
Autor: Rodrigo Nunes
Data: 05/11/2021
*/
Static Function MontaItP1()	
	Local nRow	:= 940
	Local nlx	:= 0
	Local nTam  := 0
	//linha,coluna,fim linha,fim coluna

	oProforma:Box(852,025,nVPage,100) 				
	oProforma:Say(892,035, "SEQ", oFont09)
	
	oProforma:Box(852,100,nVPage,300) 				
	oProforma:Say(892,110, "CODE", oFont09)
	
	oProforma:Box(852,300,nVPage,460) 				
	oProforma:Say(892,310, "QTY PIECES",oFont09)

	oProforma:Box(852,460,nVPage,1030) 				
	oProforma:Say(892,470, "DESCRIPTION",oFont09)

	oProforma:Box(852,1030,nVPage,1150) 			
	oProforma:Say(892,1040, "NCM",oFont09)

	oProforma:Box(852,1150,nVPage,1300) 			
	oProforma:Say(892,1160, "CBM(M3)",oFont09)
	
	oProforma:Box(852,1300,nVPage,1450) 			
	oProforma:Say(892,1310, "QTY BOXES",oFont09)
	
	oProforma:Box(852,1450,nVPage,1610) 			
	oProforma:Say(892,1460, "NET WEIGHT",oFont09)
	
	oProforma:Box(852,1610,nVPage,1820) 			
	oProforma:Say(892,1620, "GROSS WEIGHT",oFont09)
	
	oProforma:Box(852,1820,nVPage,2060) 			
	oProforma:Say(892,1830, "PRICE UNIT",oFont09)
	
	oProforma:Box(852,2060,nVPage,nHPage) 			
	oProforma:Say(892,2070, "TOTAL PRICE",oFont09)
	
	oProforma:Line(920,025,920, nHPage)

	If Len(aItemPO) >= 67
		nTam := 67
	Else
		nTam := Len(aItemPO)
	EndIF

	For nlx := 1 to nTam
		oProforma:Say(nRow,040,aItemPO[nlx][POS_SEQ],oFont08)													//SEQ													
		oProforma:Say(nRow,110,aItemPO[nlx][POS_CODE],oFont08)													//CODE
		oProforma:Say(nRow,315,Transform(aItemPO[nlx][POS_QTY_PIECES],"@E 999,999,999.999"),oFont08)			//QTY PIECES									
		oProforma:Say(nRow,470,aItemPO[nlx][POS_DESCRIPTION],oFont08)											//DESCRIPTION									
		oProforma:Say(nRow,1040,aItemPO[nlx][POS_NCM],oFont08)													//NCM
		oProforma:Say(nRow,1175,Transform(aItemPO[nlx][POS_CBM],"@E 999,999.9999"),oFont08,,,,1)				//CBM(M3)								
		oProforma:Say(nRow,1325,Transform(aItemPO[nlx][POS_QTY_BOXES],"@E 999,999.9999"),oFont08,,,,1)			//QTY BOXES								
		oProforma:Say(nRow,1470,Transform(aItemPO[nlx][POS_NET_WEIGHT],"@E 999,999.999999"),oFont08,,,,1)		//NET WEIGHT									
		oProforma:Say(nRow,1675,Transform(aItemPO[nlx][POS_GROSS_WEIGHT],"@E 999,999.999999"),oFont08,,,,1)		//GROSS WEIGHT									
		oProforma:Say(nRow,1885,Transform(aItemPO[nlx][POS_PRICE_UNIT],"@E 999,999,999.99999"),oFont08,,,,1)	//PRICE UNIT											
		oProforma:Say(nRow,2125,Transform(aItemPO[nlx][POS_TOTAL_PRICE],"@E 999,999,999.99999"),oFont08,,,,1)	//TOTAL PRICE											
		nRow += 030
	Next
	nIni := (nTam + 1)
Return

/*
Rotina: MontaItP2
Descricao: Rotina responsavel por montar a Proforma pagina 2
Autor: Rodrigo Nunes
Data: 05/11/2021
*/
Static Function MontaItP2()	
	Local nRow	:= 240
	Local nlx	:= 0
	//linha,coluna,fim linha,fim coluna

	oProforma:Box(151,025,1851,100) 				
	oProforma:Say(191,035, "SEQ", oFont09)
	
	oProforma:Box(151,100,1851,300) 				
	oProforma:Say(191,110, "CODE", oFont09)
	
	oProforma:Box(151,300,1851,460) 					
	oProforma:Say(191,310, "QTY PIECES",oFont09)

	oProforma:Box(151,460,1851,1030) 				
	oProforma:Say(191,470, "DESCRIPTION",oFont09)

	oProforma:Box(151,1030,1851,1150) 				
	oProforma:Say(191,1040, "NCM",oFont09)

	oProforma:Box(151,1150,1851,1300) 				
	oProforma:Say(191,1160, "CBM(M3)",oFont09)
	
	oProforma:Box(151,1300,1851,1450) 				
	oProforma:Say(191,1310, "QTY BOXES",oFont09)
	
	oProforma:Box(151,1450,1851,1610) 				
	oProforma:Say(191,1460, "NET WEIGHT",oFont09)
	
	oProforma:Box(151,1610,1851,1820) 				
	oProforma:Say(191,1620, "GROSS WEIGHT",oFont09)
	
	oProforma:Box(151,1820,1851,2060) 				
	oProforma:Say(191,1830, "PRICE UNIT",oFont09)
	
	oProforma:Box(151,2060,1851,nHPage) 			
	oProforma:Say(191,2070, "TOTAL PRICE",oFont09)
	
	oProforma:Line(220,025,220, nHPage)

	If !lFim
		For nlx := nIni to Len(aItemPO)
			oProforma:Say(nRow,040,aItemPO[nlx][POS_SEQ],oFont08)													//SEQ													
			oProforma:Say(nRow,110,aItemPO[nlx][POS_CODE],oFont08)													//CODE
			oProforma:Say(nRow,315,Transform(aItemPO[nlx][POS_QTY_PIECES],"@E 999,999,999.999"),oFont08)			//QTY PIECES									
			oProforma:Say(nRow,470,aItemPO[nlx][POS_DESCRIPTION],oFont08)											//DESCRIPTION									
			oProforma:Say(nRow,1040,aItemPO[nlx][POS_NCM],oFont08)													//NCM
			oProforma:Say(nRow,1175,Transform(aItemPO[nlx][POS_CBM],"@E 999,999.9999"),oFont08,,,,1)				//CBM(M3)								
			oProforma:Say(nRow,1325,Transform(aItemPO[nlx][POS_QTY_BOXES],"@E 999,999.9999"),oFont08,,,,1)			//QTY BOXES								
			oProforma:Say(nRow,1470,Transform(aItemPO[nlx][POS_NET_WEIGHT],"@E 999,999.999999"),oFont08,,,,1)		//NET WEIGHT									
			oProforma:Say(nRow,1675,Transform(aItemPO[nlx][POS_GROSS_WEIGHT],"@E 999,999.999999"),oFont08,,,,1)		//GROSS WEIGHT									
			oProforma:Say(nRow,1885,Transform(aItemPO[nlx][POS_PRICE_UNIT],"@E 999,999,999.99999"),oFont08,,,,1)	//PRICE UNIT											
			oProforma:Say(nRow,2125,Transform(aItemPO[nlx][POS_TOTAL_PRICE],"@E 999,999,999.99999"),oFont08,,,,1)	//TOTAL PRICE											
			nRow += 030
		Next
	EndIf
Return

/*
Rotina: MontaItUN
Descricao: Rotina responsavel por montar a Proforma paginna de itens demais 
Autor: Rodrigo Nunes
Data: 05/11/2021
*/
Static Function MontaItUN()	
	Local nRow	:= 240
	Local nlx	:= 0
	//linha,coluna,fim linha,fim coluna

	oProforma:Box(151,025,nVPage,100) 				
	oProforma:Say(191,035, "SEQ", oFont09)
	
	oProforma:Box(151,100,nVPage,300) 				
	oProforma:Say(191,110, "CODE", oFont09)
	
	oProforma:Box(151,300,nVPage,460) 					
	oProforma:Say(191,310, "QTY PIECES",oFont09)

	oProforma:Box(151,460,nVPage,1030) 				
	oProforma:Say(191,470, "DESCRIPTION",oFont09)

	oProforma:Box(151,1030,nVPage,1150) 				
	oProforma:Say(191,1040, "NCM",oFont09)

	oProforma:Box(151,1150,nVPage,1300) 				
	oProforma:Say(191,1160, "CBM(M3)",oFont09)
	
	oProforma:Box(151,1300,nVPage,1450) 				
	oProforma:Say(191,1310, "QTY BOXES",oFont09)
	
	oProforma:Box(151,1450,nVPage,1610) 				
	oProforma:Say(191,1460, "NET WEIGHT",oFont09)
	
	oProforma:Box(151,1610,nVPage,1820) 				
	oProforma:Say(191,1620, "GROSS WEIGHT",oFont09)
	
	oProforma:Box(151,1820,nVPage,2060) 				
	oProforma:Say(191,1830, "PRICE UNIT",oFont09)
	
	oProforma:Box(151,2060,nVPage,nHPage) 			
	oProforma:Say(191,2070, "TOTAL PRICE",oFont09)
	
	oProforma:Line(220,025,220, nHPage)

	For nlx := nIni to Len(aItemPO)
		oProforma:Say(nRow,040,aItemPO[nlx][POS_SEQ],oFont08)													//SEQ													
		oProforma:Say(nRow,110,aItemPO[nlx][POS_CODE],oFont08)													//CODE
		oProforma:Say(nRow,315,Transform(aItemPO[nlx][POS_QTY_PIECES],"@E 999,999,999.999"),oFont08)			//QTY PIECES									
		oProforma:Say(nRow,470,aItemPO[nlx][POS_DESCRIPTION],oFont08)											//DESCRIPTION									
		oProforma:Say(nRow,1040,aItemPO[nlx][POS_NCM],oFont08)													//NCM
		oProforma:Say(nRow,1175,Transform(aItemPO[nlx][POS_CBM],"@E 999,999.9999"),oFont08,,,,1)				//CBM(M3)								
		oProforma:Say(nRow,1325,Transform(aItemPO[nlx][POS_QTY_BOXES],"@E 999,999.9999"),oFont08,,,,1)			//QTY BOXES								
		oProforma:Say(nRow,1470,Transform(aItemPO[nlx][POS_NET_WEIGHT],"@E 999,999.999999"),oFont08,,,,1)		//NET WEIGHT									
		oProforma:Say(nRow,1675,Transform(aItemPO[nlx][POS_GROSS_WEIGHT],"@E 999,999.999999"),oFont08,,,,1)		//GROSS WEIGHT									
		oProforma:Say(nRow,1885,Transform(aItemPO[nlx][POS_PRICE_UNIT],"@E 999,999,999.99999"),oFont08,,,,1)	//PRICE UNIT											
		oProforma:Say(nRow,2125,Transform(aItemPO[nlx][POS_TOTAL_PRICE],"@E 999,999,999.99999"),oFont08,,,,1)	//TOTAL PRICE											
		nRow += 030
		IF nlx == 158
			Exit
		EndIf
	Next
	nIni := 159
Return

/*
Rotina: MontaTot
Descricao: Rotina responsavel por montar o Totalizador da Proforma
Autor: Rodrigo Nunes
Data: 05/11/2021
*/
Static Function MontaTot()	
	oProforma:Box(1851,025,1931,nHPage) 				
	oProforma:Say(1910,100, "TOTAL", oFont15n)
	oProforma:Line(1851,300,1931,300)
	oProforma:Line(1851,460,1931,460)
	oProforma:Line(1851,1030,1931,1030)
	oProforma:Line(1851,1150,1931,1150)
	oProforma:Line(1851,1300,1931,1300)
	oProforma:Line(1851,1450,1931,1450)
	oProforma:Line(1851,1610,1931,1610)
	oProforma:Line(1851,1820,1931,1820)
	oProforma:Line(1851,2060,1931,2060)

	oProforma:Say(1910,315,Transform(nQtdTOT,"@E 999,999,999.999"),oFont08,,,,1)
	oProforma:Say(1910,1175,Transform(nCbm,"@E 999,999.9999"),oFont08,,,,1)
	oProforma:Say(1910,1325,Transform(nBoxes,"@E 999,999.9999"),oFont08,,,,1)
	oProforma:Say(1910,1470,Transform(nWeight,"@E 999,999.999999"),oFont08,,,,1)
	oProforma:Say(1910,1675,Transform(nCross,"@E 999,999.999999"),oFont08,,,,1)
	oProforma:Say(1910,2125,Transform(nTotal,"@E 999,999,999.99999"),oFont08,,,,1)

Return

/*
Rotina: MontaRod
Descricao: Rotina responsavel por montar o Rodape da Proforma
Autor: Rodrigo Nunes
Data: 05/11/2021
*/
Static Function MontaRod()	
	oProforma:Box(1931,025,1991,nHPage)
	oProforma:Say(1971,1040, "CARGO DATA", oFont15n)

	oProforma:Box(1991,025,2081,nHPage)
	oProforma:Say(2016,035,"PRODUCTION DELIVERY",oFont09n)
	IF !Empty(dDtLPrd)
		oProforma:Say(2056,035,Day2Str(dDtLPrd)+" - "+UPPER(Left(cMonth(dDtLPrd),3))+" - "+Year2Str(dDtLPrd),oFont10n,,CLR_HRED)
	EndIF
		
	oProforma:Line(1991,325,2081,325)
	oProforma:Say(2016,335,"ETD",oFont09n)
	oProforma:Say(2056,335,Day2Str(dETDpo)+" - "+UPPER(Left(cMonth(dETDpo),3))+" - "+Year2Str(dETDpo),oFont10)
	
	oProforma:Line(1991,650,2081,650)	
	oProforma:Say(2016,660,"ETA",oFont09n)
	oProforma:Say(2056,660,Day2Str(dETApo)+" - "+UPPER(Left(cMonth(dETApo),3))+" - "+Year2Str(dETApo),oFont10)
	
	oProforma:Line(1991,975,2081,975)
	oProforma:Say(2016,985,"ACQUISITION PRECEDENCE",oFont09n)
	oProforma:Say(2056,985,cPaisForD,oFont10)

	oProforma:Line(1991,1300,2081,1300)
	oProforma:Say(2016,1310,"PORT OF ORIGIN",oFont09n)
	oProforma:Say(2056,1310,cOrigPort,oFont10)

	oProforma:Line(1991,1625,2081,1625)
	oProforma:Say(2016,1635,"PORT OF DESTINATION",oFont09n)
	oProforma:Say(2056,1635,cDestPort,oFont10)

	oProforma:Line(1991,1950,2081,1950)
	oProforma:Say(2016,1960,"WAY OF TRANSPORTATION",oFont09n)
	oProforma:Say(2056,1960,"SEA",oFont10)

	oProforma:Box(2081,025,2171,nHPage)
	oProforma:Say(2106,035,"PURCHASE ORDER",oFont09n)
	oProforma:Say(2146,035,MV_PAR01,oFont10)

	oProforma:Line(2081,325,2171,325)
	oProforma:Say(2106,335,"LOT NR",oFont09n)
	oProforma:Say(2146,335,cLOTENR,oFont10)

	oProforma:Line(2081,650,2171,650)
	oProforma:Say(2106,660,"INCOTERM",oFont09n)
	oProforma:Say(2146,660,cIncoter,oFont10)

	oProforma:Line(2081,975,2171,975)
	oProforma:Say(2106,985,"COUNTRY OF ORIGIN",oFont09n)
	oProforma:Say(2146,985,cPaisForD,oFont10)

	oProforma:Line(2081,1300,2171,1300)
	oProforma:Say(2106,1310,"TOTAL FOB",oFont09n)
	oProforma:Say(2146,1310,cMoedaPO,oFont10)
	oProforma:Say(2146,1430,Transform(nTotal,"@E 999,999,999.99"),oFont10)
	
	oProforma:Line(2081,1625,2171,1625)
	oProforma:Say(2106,1630,"INSURANCE",oFont09n)
	//Campo não identificado e pedidos tipo CIF não são lançados para preenchimento do seguro

	oProforma:Line(2081,1950,2171,1950)
	oProforma:Say(2106,1960,"TOTAL",oFont09n)
	oProforma:Say(2146,1960,cMoedaPO,oFont10)
	oProforma:Say(2146,2080,Transform(nTotal,"@E 999,999,999.99"),oFont10)
	
	oProforma:Box(2171,025,2241,nHPage)
	oProforma:Say(2196,035,"PAYMENT CONDITION",oFont09n)
	oProforma:Say(2226,035,Alltrim(cMenCondPG)+cMenVLR,oFont10)

	oProforma:Box(2240,025,2311,nHPage)
	oProforma:Say(2265,035,"DELIVERY TIME (Approval of PSI)",oFont09n)
	oProforma:Say(2295,035,"PRODUCTION (INCLUDING ARTS APPROVAL) NEEDS TO BE STARTED IMMEDIATELY AFTER RECEIPT OF SIGNED PI/DOWN PAYMENT AND MUST BE FINISHED 10 DAYS BEFORE ETD",oFont10)

	oProforma:Box(2311,025,2511,nHPage)
	oProforma:Say(2411,050, "FINES", oFont10n)
	oProforma:Line(2311,150,2511,150)
	
	oProforma:Say(2361,160, "DELIVERY", oFont10n)
	oProforma:Say(2341,360, "1-IF THE SHIPMENT DOES NOT HAPPEN WITHIN THE DELIVERY TIME INFORMED ON THIS DOCUMENT, THE FACTORY/SUPPLIER SHOULD PAY A FINE OF 0,5% OF TOTAL FOB, FOR EVERY DAY DELAY.", oFont08n)
	oProforma:Say(2361,360, "2-THE FACTORY/SUPPLIER WILL BE CHARGED A FINE OF 0,5% OF TOTAL FOB, FOR EVERY DAY OF DELAY ON READINESS OF CARGO, PLUS A FINE OF 10% OF TOTAL FOB VALUE, IF THE ORDER", oFont08n)
	oProforma:Say(2381,360, "IS CANCELLED BY THEM (i.e., BY THE SUPPLIER/MANUFACTURER).",oFont08n)
	oProforma:Line(2391,150,2391,nHPage)

	oProforma:Say(2436,160, "QUALITY", oFont10n)
	oProforma:Say(2411,360, "FACTORY/SUPPLIER SHOULD PAY TO OUROLUX FOR ANY QUALITY PROBLEM DETECTED. IF THE PROBLEM IS DETECTED IN OUR WAREHOUSE, EXTRA COSTS OBTAINED FROM BRAZILIAN CUSTOMS" ,oFont08n)
	oProforma:Say(2431,360, "(FREIGHT, REWORK) AND OTHERS WILL BE CHARGED AS WELL. IF FIRST PSI IS NOT APPROVED, THE FACTORY/SUPPLIER SHOULD PAY A FINE OF 3% OF TOTAL FOB AND FUTURE INSPECTIONS ",oFont08n)
	oProforma:Say(2451,360, "WILL BE SUPPORTED BY SUPPPLIER. (USD300.00 / MAN DAY) FROM THE FACTORY / EXPORTER ON THE PO'S PAYMENT",oFont08n)
	oProforma:Line(2461,150,2461,nHPage)

	oProforma:Say(2496,160, "COMPLIANCE", oFont10n)
	oProforma:Say(2481,360, "ATTENTION: THE FACTORY/SUPPLIER SHOULD FOLLOW OUROLUX TECHNICAL DOCUMENTS STRICTLY. IF NECESSARY ANY CHANGE, IT MUST BE APPROVED IN ADVANCED WITH QUALITY CONTROL" ,oFont08n)
	oProforma:Say(2501,360, "TEAM AND SUPPLY TEAM BEFORE ORDER ACCEPT. IF OUROLUX FIND ANY CHANGE ON THE INSPECTION OR AFTER INSPECTION, THE SUPPLIER’S PENALTY WILL BE 20% OF TOTAL AMOUNT." ,oFont08n)
	oProforma:Line(2511,150,2511,nHPage)	
	
	oProforma:Say(2556,050, "INSPECTIONS", oFont10n)
	oProforma:Say(2531,360, "OUROLUX CAN MAKE 3 REGULAR INSPECTIONS:" ,oFont08n)
	oProforma:Say(2551,360, "1- BILL OF MATERIAL (BOM). (WHEN OUR QUALITY DEPARTMENT DEMANDS)" ,oFont08n)
	oProforma:Say(2571,360, "2- DURING PRODUCTION (DUPRO) UPON 50% OF PRODUCTION. (WHEN OUR QUALITY DEPARTMENT DEMAND)" ,oFont08n)
	oProforma:Say(2591,360, "3- PRE-SHIPMENT INSPECTION (PSI) WHEN 100% OF PO IS READY. (MANDATORY FOR ALL ORDERS" ,oFont08n)

	oProforma:Line(2601,025,2601,nHPage)	

	oProforma:Say(2636,050, "GENERAL TERMS", oFont10n)
	oProforma:Say(2621,360, "- SUPPLIER IS RESPONSIBLE FOR THE TRANSPORTATION FROM THE FACTORY TO THE SHIP (FOB)" ,oFont08n)
	oProforma:Say(2641,360, "- SUPPLIER MUST FOLLOW SHIPPING INSTRUCTIONS" ,oFont08n)

	oProforma:Box(2651,025,2851,nHPage)

	oProforma:Line(2311,350,2851,350)
	oProforma:Line(2751,350,2751,nHPage)

	oProforma:Say(2680,050, "TECHNICAL INFO:", oFont10n)
	oProforma:Say(2710,050, "(SUPPLIER MUST ATTEND ALL" ,oFont07)
	oProforma:Say(2730,050, "REQUIREMENTS ACCORDING" ,oFont07)
	oProforma:Say(2750,050, "TO THE PRODUCT DATA SHEET" ,oFont07)
	oProforma:Say(2770,050, "AND PRODUCT PACKAGE/ARTWORK" ,oFont07)
	oProforma:Say(2790,050, "DATA SHEET," ,oFont07)
	oProforma:Say(2810,050, "MENTIONED IN THIS DOCUMENT.)" ,oFont07)
	
	oProforma:Line(2851,1138,nVPage,1138)

	oProforma:Say(2670,1200, "PRODUCT DATA SHEET" ,oFont07)
	If Len(cProduOBS) <= 160
		oProforma:Say(2700,360,cProduOBS,oFont08)  
	else
		oProforma:Say(2700,360,SubStr(cProduOBS,1,160),oFont08)  
		oProforma:Say(2730,360,SubStr(cProduOBS,161,80),oFont08)  
	EndIf

	oProforma:Say(2770,1200, "PACKAGING DATA SHEET" ,oFont07)
	If Len(cPackOBS) <= 160
		oProforma:Say(2800,360,cPackOBS,oFont08)  
	else
		oProforma:Say(2800,360,SubStr(cPackOBS,1,160),oFont08)  
		oProforma:Say(2830,360,SubStr(cPackOBS,161,80),oFont08)  
	EndIf
	
	oProforma:Say(2871,050, "SHIPPER'S/FACTORY/SUPPLIER STAMP AND SIGNATURE" ,oFont08)
	oProforma:Say(2871,1163, "OUROLUX'S SIGNATURE" ,oFont08)

Return

//TESTE DE ITENS 
//oProforma:Say(nRow,040,strzero(nlx,3),oFont08)											//SEQ													
//oProforma:Say(nRow,110,"SF447F55",oFont08)												//CODE
//oProforma:Say(nRow,315,Transform(999999999.999,"@E 999,999,999.999"),oFont08)				//QTY PIECES									
//oProforma:Say(nRow,470,"RODRIGO DIAS NUNES DE NUNES DE NUNES DE NUNES DEN",oFont08)		//DESCRIPTION									
//oProforma:Say(nRow,1040,"458752589",oFont08)												//NCM
//oProforma:Say(nRow,1175,Transform(999999.9999	,"@E 999,999.9999"),oFont08,,,,1)			//CBM(M3)								
//oProforma:Say(nRow,1325,Transform(999999.9999,"@E 999,999.9999"),oFont08,,,,1)			//QTY BOXES								
//oProforma:Say(nRow,1470,Transform(999999.999999,"@E 999,999.999999"),oFont08,,,,1)		//NET WEIGHT									
//oProforma:Say(nRow,1675,Transform(999999.999999,"@E 999,999.999999"),oFont08,,,,1)		//GROSS WEIGHT									
//oProforma:Say(nRow,1885,Transform(999999999.99999	,"@E 999,999,999.99999"),oFont08,,,,1)	//PRICE UNIT											
//oProforma:Say(nRow,2125,Transform(999999999.99999	,"@E 999,999,999.99999"),oFont08,,,,1)	//TOTAL PRICE	

//ROTINAS
//MontaCabec() //Monta Cabeçalho
//MontaEmit()  //Monta Emitente
//MontaItPU()  //Monta Proforma com unica pagina
//MontaItP1()  //Monta Proforma pagina 1
//MontaItP2()  //Monta Proforma pagina 2
//MontaItUN()  //Monta Pagina so para itens para demais paginas 
//MontaTot()   //Monta Totalizadores
//MontaRod()   //Monta Rodapé
