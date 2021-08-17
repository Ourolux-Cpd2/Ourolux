#Include "Topconn.ch"
#Include "Protheus.ch"
#Include "Tbiconn.ch"


Static lFWCodFil := FindFunction("FWCodFil")

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ MEGA31	³ Autor ³Eduardo Lobato	        ³ Data ³ 01/11/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Posicao de Titulos a Receber por Vendedor por email (HTML) ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ MEGA31                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
USER Function Ouro031()

Local nValor
Local cString	:="SE1"
Local nSaldo 	:= 0
Private nJuros  := 0
Private aTam	:= {}

//  CRIADO O PARAMETRO MV_MEGA31 QUE CONTEM A QUANDIDADE DE DIAS
//  QUE O RELATORIO RETROAGIRA A PARTIR DA DATA BASE DO SISTEMA
//	PARA CALCULAR A DATA INICIAL DO RELATORIO
///  DATAS PARA TESTE
//Private dDataIni := CTOD("01/08/13")
//Private dDataFim := CTOD("31/08/13")

// ABERTURA DE TABELAS EM MODO SCHEDULE - PARA TESTES E NECESSARIO COMENTAR
PREPARE ENVIRONMENT EMPRESA "01" FILIAL "01"

Private dDataIni := CTOD("01/01/13") 
Private dDataFim := dDataBase - Getmv("FS_MEGA31")
Private cRelOk	:= .F. // VARIAVEL QUE CONTROLA SOMENTE OS VENDEDORES COM TITULOS A IMPRIMIR

dbselectarea("SA3")
dbsetorder(1)
dbgotop()
while !eof()
	
	if !empty(SA3->A3_UDTSAID)  // DATA DE CONTROLE - SE ESTIVER VAZIO O VENDEDOR ESTA ATIVO
		dbskip()
		loop
	endif
	
	/*
	if SA3->A3_COD <> '200335'  // DATA DE CONTROLE - SE ESTIVER VAZIO O VENDEDOR ESTA ATIVO
		dbskip()
		loop
	endif
	*/
	
	/*
	// CODIGO DE VENDEDOR PARA TESTES - EM PRODUCAO COMENTAR AS 4 LINHAS
	if sa3->a3_cod <> "900809" .AND. sa3->a3_cod <> "200716"
		dbskip()
		loop
	endif
	*/
	
	//  LISTA DE PARÂMETROS UTILIZADOS NO PROCESSAMENTO DO RELATORIO
	
	mv_par01	:=	SPACE(6)			// Do Cliente
	mv_par02	:=	SPACE(2)	 		// Da Loja
	mv_par03	:=	"999999"			// Ate o Cliente
	mv_par04	:=	"99"		 		// Ate a Loja
	mv_par05	:=	CTOD("01/01/13")	// Da Emissao
	mv_par06	:=  CTOD("31/12/49")    // Ate Emissao
	mv_par07	:=	dDataIni	 		// Do vencimento
	mv_par08	:=	dDataFim	 		// Ate o vencimento
	mv_par09	:=	SA3->A3_COD	 		// Do vendedor
	mv_par10	:=	SA3->A3_COD	 		// Ate o vendedor
	mv_par11	:=	"NF          "		// Considera Tipos
	mv_par12	:=	""	 				// Nao considera tipos
	mv_par13	:=	1	 				// Qual moeda
	mv_par14	:=	2	 				// Outras Moedas : 1-converte 2=nao imprime
	mv_par15	:=	2	 				// Considera data base : 1-Sim, 2=Nao
	mv_par16	:=	dDataBase	 		// Database
	mv_par17	:=	1	 				// Considera Filiais abaixo (1=Sim/2=Nao)
	mv_par18	:=	SPACE(2)	 		// Filial De
	mv_par19	:=	"99"	 			// Filial Ate
	mv_par20	:=	1	 				// Salta Pag. Vendedor
	mv_par21	:=	1	 				// Converte Valor : 1=Taxa do Dia  2=Taxa do Movimento
	
	cRelOk	:= .F.
	
	PROCM31()  // FUNCAO DE PROCESSAMENTO E GERACAO DO HTML
	
	if !cRelOk  // CASO NAO HA TITULOS - NAO ENVIAR NADA POR EMAIL
		dbselectarea("SA3")
		dbskip()
		loop
	endif
	
	// HTML DE CORPO DE E-MAIL
	
	cHtml  := '<html>'
	cHtml  += '<form action="mailto:%WFMailTo%" method="POST"'
	cHtml  += 'name="FrontPage_Form1">'
	cHtml  += '    <table border="0" width="733">'
	cHtml  += '        <tr>'
	cHtml  += '            <td width="62">&nbsp;</td>'
	cHtml  += '            <td width="657"><table border="0" width="638"'
	cHtml  += '            height="84">'
	cHtml  += '                <tr>'
	cHtml  += '                    <td colspan="2" width="630" bgcolor="#DFEFFF"'
	cHtml  += '                    height="24"><p align="left"><font size="4"'
	cHtml  += '                    face="verdana"><b>Relatório de Títulos a Receber - Vencimento de</b>: '+dtoc(mv_par07)+' ate '+dtoc(mv_par08)+'</font></p>'
	cHtml  += '                    </td>'
	cHtml  += '                </tr>'
	cHtml  += '                <tr>'
	cHtml  += '                </tr>'
	cHtml  += '                <tr>'
	cHtml  += '                    <td colspan="2" width="630" bgcolor="#DFEFFF"'
	cHtml  += '                    height="24"><p align="left"><font size="4"'
	cHtml  += '                    face="verdana"><b>Representante</b>: '+SA3->A3_NOME+'</font></p>'
	cHtml  += '                    </td>'
	cHtml  += '                </tr>'
	cHtml  += '</form>'
	cHtml  += '</body>'
	cHtml  += '</html>'
		
	cEmail  := alltrim(SA3->A3_EMAIL) 		// EM TESTES COMENTAR A LINHA
	cAnex	:= "\spool\"+mv_par09+".htm"    // ANEXA HTML
	SyEnvMail(cHtml,cEmail,cAnex)           // FUNCAO DE ENVIO DE E-MAIL
	
	fErase("\spool\"+mv_par09+".htm")	   // APAGA ARQUIVO HTML GERADO NO DIRETORIO SPOOL
	
	dbselectare("SA3")
	dbskip()
end

RESET ENVIRONMENT

Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ PROCM31  ³ Autor ³ Eduardo Lobato   	    ³ Data ³ 01.11.13  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Processamento do Relatorio por HTML					   	   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ PROCM31()												   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
STATIC Function PROCM31()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para Impressao do Cabecalho e Rodape    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Local cChaveSE5
Local cIndexSE5
Local cVend
Local nAtraso
Local cVendedor
Local nTotal 		:= 0
Local nTotalGeral 	:= 0
Local lFirst 		:= .T.
Local aArea 		:= GetArea()
Local nTotJur 		:= 0
Local nAbatim 		:= 0
Local aLiquid   	:= {}
Local aVend 		:= {}
Local nVend			:= 0
Local nSaldo 		:= 0
Local nX, nY, nZ 	:= 0
Local nVendTit 		:= 0
Local lLiq			:= .F.
Local nContTit 		:= 0
Local cLiqProc 		:= ""
Local aVendedor 	:= {}
Local cQuery		:= ""
Local nI 			:= 0
Local aStru 		:= SE1->(dbStruct())
Private nIndexSE5
Private aCampos	:={}

// criação do indice temporario pra busca do numero da fatura
//***************************************
cChaveSE5  := "E5_FILIAL + E5_FATURA"
dbSelectArea("SE5")
cIndexSE5 := CriaTrab(nil,.f.)
IndRegua("SE5",cIndexSE5,cChaveSE5,,,OemToAnsi("Selecionando Registros..."))
nIndexSE5 := RetIndex("SE5")
dbSelectArea("SE5")
dbSetOrder(nIndexSE5+1)
dbGoTop()
//***************************************

cbtxt    := SPACE(10)
cbcont   := 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Geracao do arquivo de Trabalho	        			              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

aTam:=TamSX3("E1_VEND1")
AADD(aCampos,{"CODVEND"  ,"C",aTam[1],aTam[2]})
aTam:=TamSX3("E1_FILIAL")
AADD(aCampos,{"FILIAL"    ,"C",aTam[1],aTam[2]})
aTam:=TamSX3("E1_PREFIXO")
AADD(aCampos,{"PREFIXO"    ,"C",aTam[1],aTam[2]})
aTam:=TamSX3("E1_NUM")
AADD(aCampos,{"NUM"    ,"C",aTam[1],aTam[2]})
aTam:=TamSX3("E1_PARCELA")
AADD(aCampos,{"PARCELA"    ,"C",aTam[1],aTam[2]})
aTam:=TamSX3("E1_TIPO")
AADD(aCampos,{"TIPO"    ,"C",aTam[1],aTam[2]})
aTam:=TamSX3("E1_SALDO")
AADD(aCampos,{"SALDO"    ,"N",aTam[1],aTam[2]})
aTam:=TamSX3("E1_VALOR")
AADD(aCampos,{"VALOR"    ,"N",aTam[1],aTam[2]})
cArq:=CriaTrab(aCampos)
dbUseArea( .T.,, cArq, "TRB", if(.F. .OR. .F., !.F., NIL), .F. )
IndRegua("TRB",cArq,"CODVEND+FILIAL+PREFIXO+NUM+PARCELA+TIPO",,,"Selecionando Registros...")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Atribui valores as variaveis ref a filiais                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If mv_par17 == 2
	cFilDe  := cFilAnt
	cFilAte := cFilAnt
ELSE
	cFilDe := mv_par18	// Todas as filiais
	cFilAte:= mv_par19
Endif

dbSelectArea("SM0")
dbSeek(cEmpAnt+cFilDe,.T.)

nRegSM0 := SM0->(Recno())
nAtuSM0 := SM0->(Recno())


While !Eof() .and. M0_CODIGO == cEmpAnt .and. IIf( lFWCodFil, FWGETCODFILIAL, SM0->M0_CODFIL ) <= cFilAte
	
	dbSelectArea("SE1")
	cFilAnt := IIf( lFWCodFil, FWGETCODFILIAL, SM0->M0_CODFIL )
	
	cQuery := "SELECT * FROM" + RetSqlName("SE1") + " WHERE E1_FILIAL = '" + xFilial("SE1") + "' AND "
	cQuery += "E1_CLIENTE >= '" + MV_PAR01 + "' AND E1_CLIENTE <= '" + MV_PAR03 + "' AND "
	cQuery += "E1_LOJA >= '" + MV_PAR02 + "' AND E1_LOJA <= '" + MV_PAR04 + "' AND "
	cQuery += "E1_EMISSAO >= '" + DTOS(MV_PAR05) + "' AND E1_EMISSAO <= '" + DTOS(MV_PAR06) + "' AND "
	cQuery += "E1_VENCTO >= '" + DTOS(MV_PAR07) + "' AND E1_VENCTO <= '" + DTOS(MV_PAR08) + "'AND "
	cQuery += "D_E_L_E_T_=' ' "
	cQuery := ChangeQuery(cQuery)
	dbSelectArea("SE1")
	dbCloseArea()
	dbSelectArea("SA1")
	dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery),"SE1",.F., .T.)
	For nI := 1 TO LEN(aStru)
		If aStru[nI][2] != "C"
			TCSetField("SE1", aStru[nI][1], aStru[nI][2], aStru[nI][3], aStru[nI][4])
		EndIf
	Next
	dbSelectArea("SE1")
	dbGoTop()
	
	If Select("__SE1") == 0
		ChkFile("SE1",.F.,"__SE1")
	Endif
	
	dbSelectArea("SE1")
	
	While !Eof() .and. SE1->E1_FILIAL == xFilial("SE1")
		
		lLiq 		:= .F.
		aLiquid 	:= {}
		aVendedor	:= {{},{},{},{}}
		
		If !Empty(mv_par11)
			If !SE1->E1_TIPO $ mv_par11
				SE1->(dbSkip())
				Loop
			Endif
		Endif
		
		If !Empty(mv_par12)
			If SE1->E1_TIPO $ mv_par12
				SE1->(dbSkip())
				Loop
			Endif
		Endif
		
		If mv_par14 == 2 .And. SE1->E1_MOEDA != mv_par13
			SE1->(dbSkip())
			Loop
		EndIf
		
		If SE1->E1_EMISSAO > mv_par16
			SE1->(dbSkip())
			Loop
		Endif
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica se é título Liquidado.                              ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !Empty(SE1->E1_NUMLIQ) .And. SE1->E1_SALDO <> 0 .And. ! SE1->E1_TIPO $ MV_CRNEG
			aVendedor := VendM31("SE1",nIndexSE5)
			
			If mv_par15 == 2
				nSaldo:=xMoeda((SE1->E1_SALDO+SE1->E1_SDACRES-SE1->E1_SDDECRE),SE1->E1_MOEDA,MV_PAR13,,,Iif(MV_PAR21==2,Iif(!Empty(SE1->E1_TXMOEDA),SE1->E1_TXMOEDA,RecMoeda(SE1->E1_EMISSAO,SE1->E1_MOEDA)),0))
			Else
				nSaldo:=SaldoTit(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,SE1->E1_TIPO,SE1->E1_NATUREZ,"R",SE1->E1_CLIENTE,mv_par13,mv_par16,,SE1->E1_LOJA,,Iif(MV_PAR21==2,Iif(!Empty(SE1->E1_TXMOEDA),SE1->E1_TXMOEDA,RecMoeda(SE1->E1_EMISSAO,SE1->E1_MOEDA)),0))
			Endif
			
			If ! SE1->E1_TIPO $ MVABATIM
				If ! (SE1->E1_TIPO $ MVRECANT+"/"+MV_CRNEG) .And. ;
					!( MV_PAR15 == 2 .And. nSaldo == 0 )  	// deve olhar abatimento pois e zerado o saldo na liquidacao final do titulo
					nAbatim := SomaAbat(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,"R",mv_par15,,SE1->E1_CLIENTE,SE1->E1_LOJA)
					If STR(nSaldo,17,2) == STR(nAbatim,17,2)
						nSaldo := 0
					Else
						nSaldo-= nAbatim
					Endif
				Endif
			Else
				dbSelectArea("SE1")
				dbSkip()
				Loop
			Endif
			
			nSaldo := Round(NoRound(nSaldo,3),2)
			
			If nSaldo <= 0
				SE1->(dbSkip())
				Loop
			Endif
			
			Fa440LiqSe1(SE1->E1_NUMLIQ,@aLiquid)
			nVend := fa440CntVen()
			
			
			If !(SE1->E1_NUMLIQ $ cLiqProc)
				aVend := {}
				For nZ := 1 To Len(aLiquid)
					__SE1->(dbgoto(aLiquid[nZ]))
					
					For nVendTit := 1 to len(aVendedor[1])
						For nY := 1 To nVend
							cVendedor := aVendedor[1][nVendTit][nY]
							If cVendedor >= mv_par09 .AND. cVendedor <= mv_par10 .AND. !Empty(cVendedor)
								nPosVend := aScan(aVend,{|x| x[1] == cVendedor})
								If nPosVend = 0
									aAdd(aVend, {cVendedor,__SE1->E1_VALOR})
								Else
									aVend[nPosVend][2] += __SE1->E1_VALOR
								EndIf
							EndIf
						Next
						cLiqProc := SE1->E1_NUMLIQ
					Next
				Next
			EndIf
			
			For nZ := 1 to Len(aVend)
				M31TEMP(aVend[nZ][1],nSaldo)
			Next
			
			lLiq := .T.
			dbSelectArea("SE1")
			dbSkip()
			Loop
		EndIf
		
		If mv_par15 == 2 .and. SE1->E1_SALDO == 0
			SE1->(dbSkip())
			Loop
		Endif
		
		If Len(aVendedor[1]) <= 0
			aVendedor := VendM31("SE1",nIndexSE5)
		Endif
		
		If Len(aVendedor[1]) <= 0
			SE1->(dbSkip())
			Loop
		EndIf
		
		// Tratamento da correcao monetaria para a Argentina
		If  cPaisLoc=="ARG" .And. mv_par13 <> 1  .And.  SE1->E1_CONVERT=='N'
			SE1->(dbSkip())
			Loop
		Endif
		
		If !lLiq		//Se não for titulo liquidado
			If mv_par15 == 2
				nSaldo:=xMoeda((SE1->E1_SALDO+SE1->E1_SDACRES-SE1->E1_SDDECRE),SE1->E1_MOEDA,MV_PAR13,,,Iif(MV_PAR21==2,Iif(!Empty(SE1->E1_TXMOEDA),SE1->E1_TXMOEDA,RecMoeda(SE1->E1_EMISSAO,SE1->E1_MOEDA)),0))
			ELSE
				nSaldo:=SaldoTit(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,SE1->E1_TIPO,SE1->E1_NATUREZ,"R",SE1->E1_CLIENTE,mv_par13,mv_par16,,SE1->E1_LOJA,,Iif(MV_PAR21==2,Iif(!Empty(SE1->E1_TXMOEDA),SE1->E1_TXMOEDA,RecMoeda(SE1->E1_EMISSAO,SE1->E1_MOEDA)),0))
			Endif
			
			If ! SE1->E1_TIPO $ MVABATIM
				If ! (SE1->E1_TIPO $ MVRECANT+"/"+MV_CRNEG) .And. ;
					!( MV_PAR15 == 2 .And. nSaldo == 0 )  	// deve olhar abatimento pois e zerado o saldo na liquidacao final do titulo
					nAbatim := SomaAbat(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,"R",mv_par15,,SE1->E1_CLIENTE,SE1->E1_LOJA)
					If STR(nSaldo,17,2) == STR(nAbatim,17,2)
						nSaldo := 0
					Else
						nSaldo -= nAbatim
					Endif
				Endif
			Else
				dbSelectArea("SE1")
				dbSkip()
				Loop
			Endif
			nSaldo:=Round(NoRound(nSaldo,3),2)
			
			If nSaldo <= 0
				SE1->(dbSkip())
				Loop
			Endif
			
			nVend := fa440CntVen()
			For nVendTit := 1 to len(aVendedor[1])
				For nY := 1 To nVend
					cVendedor := aVendedor[1][nVendTit][nY]
					If cVendedor >= mv_par09 .And. cVendedor <= mv_par10 .AND. !Empty(cVendedor)
						M31TEMP(cVendedor,nSaldo)
					EndIf
				Next
			Next
			
			dbSelectArea("SE1")
			dbSkip()
		EndIf
	Enddo
	
	If Empty(xFilial("SE1"))
		Exit
	Endif
	
	dbSelectArea("SM0")
	dbSkip()
	Loop
Enddo

SM0->(dbGoTo(nRegSM0))
cFilAnt := IIf( lFWCodFil, FWGETCODFILIAL, SM0->M0_CODFIL )

dbSelectArea("SE1")
dbCloseArea()
ChKFile("SE1")
dbSelectArea("SE1")
dbSetOrder(1)

TRB->(dbgotop())

While !TRB->(EOF())
	
	
	cVar:= TRB->CODVEND
	nTotal := 0
	nTotJur := 0
	cVend:=Space(06)
	While !TRB->(EOF()) .AND. cVar==TRB->CODVEND
		
		cVend:=TRB->CODVEND
		
		If lFirst
			dbSelectArea("SA3")
			dbSetOrder(1)
			Dbseek(xFilial("SA3") + cVend)
			
			// INICIO DE MONTAGEM DO HTML DO RELATORIO PARA ANEXAR A E-MAIL
			
			// CABECALHO
			
			cHtml  := '<html>'
			cHtml  += '<form action="mailto:%WFMailTo%" method="POST"'
			cHtml  += 'name="FrontPage_Form1">'
			cHtml  += '    <table border="0" width="800">'
			cHtml  += '        <tr>'
			cHtml  += '            <td width="62">&nbsp;</td>'
			cHtml  += '            <td width="657"><table border="0" width="800"'
			cHtml  += '            height="84">'
			cHtml  += '                <tr>'
			cHtml  += '                    <td colspan="2" width="800" bgcolor="#DFEFFF"'
			cHtml  += '                    height="24"><p align="left"><font size="4"'
			cHtml  += '                    face="verdana"><b>Relatório de Títulos a Receber com Vencimento de</b>: '+dtoc(mv_par07)+' ate '+dtoc(mv_par08)+'</font></p>'
			cHtml  += '                    </td>'
			cHtml  += '                </tr>'
			cHtml  += '                <tr>'
			cHtml  += '                </tr>'
			cHtml  += '                <tr>'
			cHtml  += '                    <td colspan="2" width="800" bgcolor="#DFEFFF"'
			cHtml  += '                    height="24"><p align="left"><font size="4"'
			cHtml  += '                    face="verdana"><b>Representante</b>: '+SA3->A3_NOME+'</font></p>'
			cHtml  += '                    </td>'
			cHtml  += '                </tr>'
			
			// CABECALHO DOS ITENS - TITULOS
			
			//			cHtml  += '            <p><font color="#0000FF" face="verdana"><b>TITULOS</b></font></p>'
			cHtml  += '            <table border="1" width="800" height="85">'
			cHtml  += '                <tr>'
			cHtml  += '                    <td align="center" width="40"  bgcolor="#DFEFFF" height="18"><font face="verdana">Prf</font></td>'
			cHtml  += '                    <td align="center" width="66"  bgcolor="#DFEFFF" height="18"><font face="verdana">Titulo</font></td>'
			cHtml  += '                    <td align="center" width="66"  bgcolor="#DFEFFF" height="18"><font face="verdana">Tipo</font></td>'
			cHtml  += '                    <td align="center" width="40"  bgcolor="#DFEFFF" height="18"><font face="verdana">Cod.Cliente</font></td>'
			cHtml  += '                    <td align="center" width="40"  bgcolor="#DFEFFF" height="18"><font face="verdana">Loja</font></td>'
			cHtml  += '                    <td align="left" width="190" bgcolor="#DFEFFF" height="18"><font face="verdana">Razao Social</font></td>'
			cHtml  += '                    <td align="center" width="40"  bgcolor="#DFEFFF" height="18"><font face="verdana">Emissão</font></td>'
			cHtml  += '                    <td align="center" width="40"  bgcolor="#DFEFFF" height="18"><font face="verdana">Vencto</font></td>'
			cHtml  += '                    <td align="center" width="40"  bgcolor="#DFEFFF" height="18"><font face="verdana">Valor</font></td>'
			cHtml  += '                    <td align="center" width="40"  bgcolor="#DFEFFF" height="18"><font face="verdana">Saldo</font></td>'
			cHtml  += '                    <td align="center" width="86"  bgcolor="#DFEFFF" height="18"><font face="verdana">Juros</font></td>'
			cHtml  += '                    <td align="center" width="86"  bgcolor="#DFEFFF" height="18"><font face="verdana">Saldo Corrig.</font></td>'
			cHtml  += '                    <td align="center" width="40"  bgcolor="#DFEFFF" height="18"><font face="verdana">Natureza</font></td>'
			cHtml  += '                    <td align="left" width="190" bgcolor="#DFEFFF" height="18"><font face="verdana">Descrição</font></td>'
			cHtml  += '                    <td align="center" width="40"  bgcolor="#DFEFFF" height="18"><font face="verdana">Atraso</font></td>'
			cHtml  += '                </tr>'
			
			cRelOk	:= .T.
			
			lFirst := .F.
		Endif
		
		
		SE1->(dbSeek(TRB->(FILIAL+PREFIXO+NUM+PARCELA+TIPO)))
		nValor:=xMoeda(SE1->E1_VALOR,SE1->E1_MOEDA,MV_PAR13,,,Iif(MV_PAR21==2,Iif(!Empty(SE1->E1_TXMOEDA),SE1->E1_TXMOEDA,RecMoeda(SE1->E1_EMISSAO,SE1->E1_MOEDA)),0))
		nAtraso:=(mv_par16-SE1->E1_VENCTO)
		nAtraso:= If(nAtraso < 0, 0, nAtraso)
		
		cNum := IIF(!EMPTY(TRB->PARCELA),TRB->NUM+"/"+TRB->PARCELA,TRB->NUM)
		
		dbSelectArea("SE1")
		nJuros := 0
		fa070juros(mv_par13)
		
		dbSelectArea("SED")
		dbSetOrder(1)
		MsSeek(xFilial("SED") + SE1->E1_NATUREZ)
		
		// LISTAGEM DE TITULOS
		
		cHtml   += '                <tr>'
		cHtml   += '                    <td align="center"><font size="1" face="verdana">'+TRB->PREFIXO+'</font></td>'
		cHtml   += '                    <td align="center"><font size="1" face="verdana">'+cNUM+'</font></td>'
		cHtml   += '                    <td align="center"><font size="1" face="verdana">'+TRB->TIPO+'</font></td>'
		cHtml   += '                    <td align="center"><font size="1" face="verdana">'+SE1->E1_CLIENTE+'</font></td>'
		cHtml   += '                    <td align="center"><font size="1" face="verdana">'+SE1->E1_LOJA+'</font></td>'
		cHtml   += '                    <td align="left"><font size="1" face="verdana">'+SE1->E1_NOMCLI+'</font></td>'
		cHtml   += '                    <td align="center"><font size="1" face="verdana">'+DTOC(SE1->E1_EMISSAO) +'</font></td>'
		cHtml   += '                    <td align="center"><font size="1" face="verdana">'+DTOC(SE1->E1_VENCTO)+'</font></td>'
		cHtml   += '                    <td align="center"><font size="1" face="verdana">'+TRANSFORM(nVALOR,"@E 999,999,999.99")+'</font></td>'
		cHtml   += '                    <td align="center"><font size="1" face="verdana">'+TRANSFORM(TRB->SALDO,"@E 999,999,999.99")+'</font></td>'
		cHtml   += '                    <td align="center"><font size="1" face="verdana">'+TRANSFORM(nJuros,"@E 999,999,999.99")+'</font></td>'
		cHtml   += '                    <td align="center"><font size="1" face="verdana">'+TRANSFORM(TRB->SALDO+nJuros,"@E 999,999,999.99")+'</font></td>'
		cHtml   += '                    <td align="center"><font size="1" face="verdana">'+SE1->E1_NATUREZ+'</font></td>'
		cHtml   += '                    <td align="left"><font size="1" face="verdana">'+Left(SED->ED_DESCRIC,25)+'</font></td>'
		cHtml   += '                    <td align="center"><font size="1" face="verdana">'+TRANSFORM(nAtraso,"@E 9999")+'</font></td>'
		cHtml   += '                </tr>'
		
		
		nTotJur += nJuros
		If SE1->E1_TIPO $ MV_CRNEG+"/"+MVRECANT
			nTotal -=  TRB->SALDO
		Else
			nTotal +=  TRB->SALDO
		Endif
		
		TRB->(dBskip())
	Enddo
	lFirst := .T.
	dbSelectArea("SA3")
	dbSetOrder(1)
	Dbseek(xFilial("SA3") + cVend)
	
	nTotalGeral += nTotal+nTotJur
	
	// TOTALIZACOES DO VENDEDOR
	
	cHtml  += '            </table>'
	cHtml  += '                <tr>'
	cHtml  += '                <tr>'
	cHtml  += '                    <td colspan="2" width="630" bgcolor="#DFEFFF"'
	cHtml  += '                    height="24"><p align="left"><font size="4"'
	cHtml  += '                    face="verdana"><b>Total dos Títulos</b>: R$ '+TRANSFORM(nTotal,"@E 999,999,999.99")+'</font></p>'
	cHtml  += '                    </td>'
	cHtml  += '                <tr>'
	cHtml  += '                    <td colspan="2" width="630" bgcolor="#DFEFFF"'
	cHtml  += '                    height="24"><p align="left"><font size="4"'
	cHtml  += '                    face="verdana"><b>Total de Juros</b>:    R$ '+TRANSFORM(nTotJur,"@E 999,999,999.99")+'</font></p>'
	cHtml  += '                    </td>'
	cHtml  += '                <tr>'
	cHtml  += '                    <td colspan="2" width="630" bgcolor="#DFEFFF"'
	cHtml  += '                    height="24"><p align="left"><font size="4"'
	cHtml  += '                    face="verdana"><b>Total Corrigido</b>:   R$ '+TRANSFORM(nTotal+nTotJur,"@E 999,999,999.99")+'</font></p>'
	cHtml  += '                    </td>'
	cHtml  += '                </tr>'
	cHtml  += '</form>'
	cHtml  += '</body>'
	cHtml  += '</html>'
	
	
	
	cARQ := cVEND+".htm"
	nHdl := FCreate("\spool\"+cArq)
	
	FWRITE(nHDL,cHTML,LEN(cHTML))  // GRAVA HTML
	
	
	
	FCLOSE(nHdl) // FECHA ARQUIVO HTML PARA PODER ANEXAR A E-MAIL
	
	
Enddo


If Select("TRB") > 0
	TRB->(dbCloseArea())
	Ferase(cArq+GetDBExtension())      // Elimina arquivos de Trabalho
	Ferase(cArq+OrdBagExt())			  // Elimina arquivos de Trabalho
Endif

RestArea(aArea)

////////////////

RETURN


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³M31TEMP   ºAutor  ³Eduardo Lobato      º Data ³  01/11/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Gravacao do arquivo de trabalho                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Generico                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

STATIC Function M31TEMP(cCampo,nSaldo)

Local aArea       := GetArea()
dbSelectArea("TRB")
dbSetOrder(1)
If !dbSeek(cCampo+SE1->E1_FILIAL+SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA+SE1->E1_TIPO)
	Reclock("TRB", .T.)
	TRB->CODVEND	:=	cCampo
	TRB->FILIAL 	:=	SE1->E1_FILIAL
	TRB->PREFIXO	:=	SE1->E1_PREFIXO
	TRB->NUM		:=	SE1->E1_NUM
	TRB->PARCELA	:=	SE1->E1_PARCELA
	TRB->TIPO		:=	SE1->E1_TIPO
	TRB->SALDO		:=	nSaldo
	Msunlock()
Endif
RestArea( aArea )

Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ M31Princ ³ Autor ³ Eduardo Lobato        ³ Data ³ 01/11/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna um array com as comissões, vendedores e tit princ  ³±±
±±³          ³ dos títulos que foram liquidados/faturados                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ MEGA31.prw                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
// Observação importante: para usar a função abaixo, deve-se criar um indice
// Temporario na tabela SE5: "E5_FILIAL + E5_FATURA com o IndRegua()"
//
STATIC Function M31Princ(FILIAL,PREFIXO,NUMERO,PARCELA,TIPO,AliasSE1,aVendedor,nIndexSE5)
Local cQuery, cIndTmp, cFiltro, cChave, cLiquida, cFatura, nRecSe5, cCampo
Local aVends := {}, aComis := {}, aBase := {}
Local nVends := fa440CntVen(), nX

dbSelectArea(AliasSE1)
dbSetOrder(1)
If dbSeek(FILIAL+PREFIXO+NUMERO+PARCELA+TIPO)
	If !Empty((AliasSE1)->(E1_VEND1+E1_VEND2+E1_VEND3+E1_VEND4+E1_VEND5))
		If (AliasSE1)->E1_SALDO > 0
			aVends := {}
			aComis := {}
			aBase  := {}
			For nX := 1 to nVends
				cCampo := "E1_VEND" + Soma1(alltrim(str(nX-1)),1,.t.)
				aAdd(aVends,(AliasSE1)->&(cCampo))
				
				cCampo := "E1_COMIS" + Soma1(alltrim(str(nX-1)),1,.t.)
				aAdd(aComis,(AliasSE1)->&(cCampo))
				
				cCampo := "E1_BASCOM" + Soma1(alltrim(str(nX-1)),1,.t.)
				aAdd(aBase,(AliasSE1)->&(cCampo))
			Next
			aAdd(aVendedor[1],aVends)
			aAdd(aVendedor[2],aComis)
			aAdd(aVendedor[3],aBase)
			aAdd(aVendedor[4],(AliasSE1)->E1_FILIAL+(AliasSE1)->E1_PREFIXO+(AliasSE1)->E1_NUM+(AliasSE1)->E1_PARCELA+(AliasSE1)->E1_TIPO)
		Endif
		Return
	Endif
	If "NOTFAT" $ (AliasSE1)->E1_FATURA
		dbSelectArea("SE5")
		SE5->(dbSetOrder(nIndexSE5+1))
		dbSeek(xFilial("SE5")+(AliasSE1)->E1_NUM)
	ElseIf !Empty((AliasSE1)->E1_NUMLIQ)
		dbSelectArea("SE5")
		dbSetOrder(10)
		dbSeek(xFilial("SE5")+(AliasSE1)->E1_NUMLIQ)
	Else
		Return
	Endif
	
	If "NOTFAT" $ (AliasSE1)->E1_FATURA
		cFatura := SE5->E5_FILIAL+SE5->E5_FATURA
		dbSelectArea("SE5")
		Do While cFatura == SE5->E5_FILIAL+SE5->E5_FATURA .And. !Eof()
			nRecSe5 := SE5->(Recno())
			M31Princ(SE5->E5_FILIAL,SE5->E5_PREFIXO,SE5->E5_NUMERO,SE5->E5_PARCELA,SE5->E5_TIPO,AliasSE1,@aVendedor,nIndexSE5)
			SE5->(dbGoto(nRecSe5))
			aVends := {}
			aComis := {}
			aBase  := {}
			For nX := 1 to nVends
				cCampo := "E1_VEND" + Soma1(alltrim(str(nX-1)),1,.t.)
				aAdd(aVends,(AliasSE1)->&(cCampo))
				
				cCampo := "E1_COMIS" + Soma1(alltrim(str(nX-1)),1,.t.)
				aAdd(aComis,(AliasSE1)->&(cCampo))
				
				cCampo := "E1_BASCOM" + Soma1(alltrim(str(nX-1)),1,.t.)
				aAdd(aBase,(AliasSE1)->&(cCampo))
			Next
			aAdd(aVendedor[1],aVends)
			aAdd(aVendedor[2],aComis)
			aAdd(aVendedor[3],aBase)
			aAdd(aVendedor[4],(AliasSE1)->E1_FILIAL+(AliasSE1)->E1_PREFIXO+(AliasSE1)->E1_NUM+(AliasSE1)->E1_PARCELA+(AliasSE1)->E1_TIPO)
			dbSelectArea("SE5")
			dbSkip()
		Enddo
	ElseIf !Empty((AliasSE1)->E1_NUMLIQ)
		cLiquida := SE5->E5_FILIAL+SE5->E5_DOCUMEN
		dbSelectArea("SE5")
		Do While cLiquida == SE5->E5_FILIAL+SE5->E5_DOCUMEN .And. !Eof()
			nRecSe5 := SE5->(Recno())
			M31Princ(SE5->E5_FILIAL,SE5->E5_PREFIXO,SE5->E5_NUMERO,SE5->E5_PARCELA,SE5->E5_TIPO,AliasSE1,@aVendedor,nIndexSE5)
			SE5->(dbGoto(nRecSe5))
			aVends := {}
			aComis := {}
			aBase  := {}
			For nX := 1 to nVends
				cCampo := "E1_VEND" + Soma1(alltrim(str(nX-1)),1,.t.)
				aAdd(aVends,(AliasSE1)->&(cCampo))
				
				cCampo := "E1_COMIS" + Soma1(alltrim(str(nX-1)),1,.t.)
				aAdd(aComis,(AliasSE1)->&(cCampo))
				
				cCampo := "E1_BASCOM" + Soma1(alltrim(str(nX-1)),1,.t.)
				aAdd(aBase,(AliasSE1)->&(cCampo))
			Next
			aAdd(aVendedor[1],aVends)
			aAdd(aVendedor[2],aComis)
			aAdd(aVendedor[3],aBase)
			aAdd(aVendedor[4],(AliasSE1)->E1_FILIAL+(AliasSE1)->E1_PREFIXO+(AliasSE1)->E1_NUM+(AliasSE1)->E1_PARCELA+(AliasSE1)->E1_TIPO)
			dbSelectArea("SE5")
			dbSkip()
		Enddo
	Endif
	
Endif
Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ VendM31  ³ Autor ³ Eduardi Lobato		³Data  ³ 01/11/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Complemento a função M31Princ para retorno da array de     ³±±
±±³          ³ vendedores com dados de comissão de titulos principais     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ MEGA31.PRW                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function VendM31(cAliasSe1,nIndexSE5)
Local aAreaSe1 := GetArea()
Local aVendedor	:= {{},{},{},{}}
M31Princ(xFilial(cAliasSe1),(cAliasSe1)->e1_PREFIXO,(cAliasSe1)->e1_NUM,(cAliasSe1)->e1_PARCELA,(cAliasSe1)->e1_TIPO,"__SE1",@aVendedor,nIndexSE5)
RestArea(aAreaSe1)
Return aVendedor



/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³SyEnvMail ³ Autor ³  Eduardo Lobato		³ Data ³ 01/11/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Envia por e-mail o relatorio                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Especifico                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function SyEnvMail(cHtml,cEmail,cAnex)

Local lResult    := .T.
Local cError     := ""
Local cTo        := "" 
Local cCC        := ""
Local lAuth      := GetMv("MV_RELAUTH",,.T.)
Local cMailConta := GetMv("MV_RELACNT",,"")
Local cMailServer:= GetMv("MV_RELSERV",,"")
Local cMailSenha := GetMv("MV_RELPSW",,"")
Local cRelFrom   := GetMv('MV_RELFROM')	             	//-- Email utilizado no campo from (utilizar um email valido)
Local cMailAut   := Left(cMailConta, At("@", cMailConta)-1)
Local cAnexo     := cAnex
Local cSubject	 := "Relatório de Títulos a Receber - Ourolux"

cTo:= RTrim(cEmail)
cCC:= 'wrahal@ourolux.com.br'


If !Empty(cMailServer) .And. !Empty(cMailConta) .And. !Empty(cMailSenha)
	// Envia e-mail com os dados necessarios
	CONNECT SMTP SERVER cMailServer ACCOUNT cMailConta PASSWORD cMailSenha RESULT lResult
	
	
	// Autenticacao da conta de e-mail
	If lResult
		If lAuth
			lResult := MailAuth(cMailConta,cMailSenha)
		EndIf
		
		If !lResult
			lResult := MailAuth(cMailAut,cMailSenha)
		EndIf
		
		If lResult
			SEND MAIL  				;
			FROM       cRelFrom     ;	//FROM       cMailConta	;
			TO		   cTo			;
			CC         cCC          ;
			SUBJECT	   cSubject		;
			BODY	   cHtml		;
			ATTACHMENT cAnexo       ;
			RESULT	   lResult
			
			
			If !lResult
				//Erro no Envio do E-Mail.
				GET MAIL ERROR cError
				ConOut(cError)
			EndIf
		Else
			//Erro na autenticacao da conta
			GET MAIL ERROR cError
			ConOut(cError)
		Endif
	Else
		//Erro na conexao com o SMTP Server
		GET MAIL ERROR cError
		ConOut(cError)
	Endif
Endif

Return
