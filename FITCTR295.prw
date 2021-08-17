#Include "Ctbr295.Ch"
#Include "PROTHEUS.Ch"

#DEFINE 	COL_SEPARA1			1
#DEFINE 	COL_CONTA 			2
#DEFINE 	COL_SEPARA2			3
#DEFINE 	COL_DESCRICAO		4
#DEFINE 	COL_SEPARA3			5
#DEFINE 	COL_COLUNA1       	6
#DEFINE 	COL_SEPARA4			7
#DEFINE 	COL_COLUNA2       	8
#DEFINE 	COL_SEPARA5			9
#DEFINE 	COL_COLUNA3       	10
#DEFINE 	COL_SEPARA6			11
#DEFINE 	COL_COLUNA4   		12
#DEFINE 	COL_SEPARA7			13
#DEFINE 	COL_COLUNA5   		14
#DEFINE 	COL_SEPARA8			15
#DEFINE 	COL_COLUNA6   		16
#DEFINE 	COL_SEPARA9			17
#DEFINE 	COL_COLUNA7			18
#DEFINE 	COL_SEPARA10		19
#DEFINE 	COL_COLUNA8			20
#DEFINE 	COL_SEPARA11		21
#DEFINE 	COL_COLUNA9			22
#DEFINE 	COL_SEPARA12		23
#DEFINE 	COL_COLUNA10		24
#DEFINE 	COL_SEPARA13		25
#DEFINE 	COL_COLUNA11		26
#DEFINE 	COL_SEPARA14		27
#DEFINE 	COL_COLUNA12		28
#DEFINE 	COL_SEPARA15		29

STATIC _oCTBR2951
STATIC _oCTBR2952
Static lIsRedStor := FindFunction("IsRedStor") .and. IsRedStor() //Used to check if the Red Storn Concept used in russia is active in the system | Usada para verificar se o Conceito Red Storn utilizado na Russia esta ativo no sistema | Se usa para verificar si el concepto de Red Storn utilizado en Rusia esta activo en el sistema

//_____________________________________________________________________________
/*/{Protheus.doc} FITCTR295
Conforme solicitacao e necessidade Ourolux, feito comparativo de Saldo Mes a 
Mes Cta+C.Custo+Item+Cl.Valor, com opcao de selecionar todas as filiais.

@author Icaro Queiroz
@since 16 de Setembro de 2015
@owner FIT Gestao for Ourolux
/*/
//_____________________________________________________________________________
User Function FITCTR295()

	Local aSetOfBook
	Local aCtbMoeda	:= {}
	Local cSayCC		:= ALLTRIM(CtbSayApro("CTT"))
	Local cSayIT		:= ALLTRIM(CtbSayApro("CTD"))
	Local cSayCL		:= ALLTRIM(CtbSayApro("CTH"))
	Local cDesc1 		:= STR0001			//"Este programa ira imprimir o Balancete Comparativo "
	Local cDesc2 		:= ""
	Local cDesc3 		:= STR0002  //"de acordo com os parametros solicitados pelo Usuario"
	Local cNomeArq
	LOCAL wnrel
	LOCAL cString		:= "CT1"
	Local lRet			:= .T.
	Local nDivide		:= 1
	Local cMensagem		:= ""
	Local lAtSlComp		:= Iif(GETMV("MV_SLDCOMP") == "S",.T.,.F.)

	Local lEntAnt     	:= .F.

	Local nQt			:= 0
	Local aRet			:= {}
	Local aEnts			:= {}
	Local lSair  		:= .F.
	Local aOrdem 		:= {}	/// ORDEM (CHAVE) DO ARQUIVO DE TRABALHO - ORDEM DE IMPRESSAO

	Local nPar 			:= 1
	Local aMvPars		:= {}

	Private Titulo 		:= STR0003+" " 	//"Comparativo de Saldo "
	PRIVATE nLastKey 	:= 0
	PRIVATE cPerg	 	:= "FCTR295"
	PRIVATE aReturn 	:= { STR0015, 1,STR0016, 2, 2, 1, "",1 }  //"Zebrado"###"Administracao"
	PRIVATE aLinha		:= {}
	PRIVATE nomeProg  	:= "CTBR295"
	PRIVATE Tamanho		:="G"
	Private aSelFil		:= {}
	Private nX			:= 0

	If ( !AMIIn(34) )		// Acesso somente pelo SIGACTB
		Return
	EndIf

	li 	:= 80
	m_pag	:= 1

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Mostra tela de aviso - Atualizacao de saldos				 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cMensagem := STR0021+chr(13)  		//"Caso nao atualize os saldos compostos na"
	cMensagem += STR0022+chr(13)  		//"emissao dos relatorios(MV_SLDCOMP ='N'),"
	cMensagem += STR0023+chr(13)  		//"rodar a rotina de atualizacao de saldos "

	IF !lAtSlComp
		IF !MsgYesNo(cMensagem,STR0009)	//"ATEN€ŽO"
			Return
		Endif
	EndIf

	If !Pergunte("FCTR295",.T.)
		Return
	EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros					       ³
//³ mv_par01				// Data Inicial              	       ³
//³ mv_par02				// Data Final                          ³
//³ mv_par03				// Conta Inicial                       ³
//³ mv_par04				// Conta Final   					   ³
//³ mv_par05				// C.C. Inicial         		       ³
//³ mv_par06				// C.C. Final   					   ³
//³ mv_par07				// Item Inicial                        ³
//³ mv_par08				// Item Final   					   ³
//³ mv_par09				// Classe de Valor Inicial             ³
//³ mv_par10				// Classe de Valor Final			   ³
//³ mv_par11				// Moeda?          			     	   ³
//³ mv_par12				// Saldos? Reais / Orcados/Gerenciais  ³
//³ mv_par13				// Saldos a Comp.? Reais /Orcados...   ³
//³ mv_par14				// Set Of Books				    	   ³
//³ mv_par15				// Saldos Zerados?			     	   ³
//³ mv_par16				// Compara? (Mov.Periodo/Saldo.Acum.)  ³
//³ mv_par17				// Pagina Inicial  		     		   ³
//³ mv_par18				// Imprime Cod. Conta? Normal/Reduzido ³
//³ mv_par19				// Imprime Cod. C.Custo? Normal/Red.   ³
//³ mv_par20				// Imprime Cod. Item ? Normal/Red.     ³
//³ mv_par21 				// Imprime Valor 0.00?                 ³
//³ mv_par22 				// Divide por?                         ³
//³ mv_par23				// Posicao Ant. L/P? Sim / Nao         ³
//³ mv_par24				// Data Lucros/Perdas?                 ³
//³ mv_par25			   	// Imprime Var. Percentual ?		   ³
//³ mv_par26			   	// Imprime Var. Valor ?				   ³
//³ mv_par27			   	// Imp.Descrições ?          		   ³
//³ mv_par28			   	// Usa Conta ?                  	   ³
//³ mv_par29			   	// Usa C.Custo ?                	   ³
//³ mv_par30			   	// Usa Item Contabil ?          	   ³
//³ mv_par31			   	// Usa Classe de Valor?          	   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

/// DETERMINA O CABEÇALHO DE ACORDO COM OS PARAMETROS
/// Se usar a Conta
	If mv_par28 == 1
		aAdd(aEnts,STR0011)
		cString := "CT1"
	EndIf
/// Se usar o C.Custo
	If mv_par29 == 1
		aAdd(aEnts,cSayCC)
		cString := "CTT"
	EndIf
/// Se usar o Item Contabil
	If mv_par30 == 1
		aAdd(aEnts,cSayIT)
		cString := "CTD"
	EndIf
/// Se usar a Cl. de Valor
	If mv_par31 == 1
		aAdd(aEnts,cSayCL)
		cString := "CTH"
	EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Monta ParamBox para indicar como será a ordem de impressao³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Len(aEnts) > 1	// APENAS SE USAR + DE 1 ENTIDADE
	/// GUARDA CONTEUDO DOS MV_PAR JÁ ABERTOS (SE HOUVER) - Chamada de ParamBox na função (muda os mv_pars)
		For nPar := 1 To 40
			aAdd(aMvPars,&("MV_PAR"+STRZERO(int(nPar),2)))
		Next

		aPars := {}
		For nQt := 1 to Len(aEnts)
			aAdd(aPars, {2,If(nQt==1,STR0033,STR0034), "mvbox" ,aEnts ,60, "" ,.F.} )
		Next
	
		While !lSair
			If !ParamBox( aPars ,STR0032 ,aRet)
				aRet := aClone(aEnts)
				lSair := .T.
				Exit
			Else	// SE CONFIRMOU
				lSair := VldOrdem(aRet)
			EndIf
		EndDo
	
	/// Restaura o conteudo do MV_PARs (existe um ParamBox).
		For nPar := 1 To Len(aMvPars)
			&("MV_PAR"+strzero(int(nPar),2)) := aMvPars[nPar]
		Next
	Else
		aRet := aClone(aEnts)
	EndIf
	
/// MONTA AS COLUNAS PARA ORDEM BASEADO NO RETORNO DA PARAMBOX
	For nQt := 1 to Len(aRet)
		If nQt > 1			/// A PARTIR DA 2ª COLUNA COLOCA VIRGULA
			cDesc2 += "/"
		EndIf
		If aRet[nQt] == STR0011	// CONTA
			AADD(aOrdem,"CONTA")
			cDesc2 += STR0011			///"CONTA"
		ElseIf aRet[nQt] == cSayCC // C.CUSTO
			AADD(aOrdem,"CUSTO")
			cDesc2 += Upper(cSayCC)
		ElseIf  aRet[nQt] == cSayIT // ITEM CONTABIL
			AADD(aOrdem,"ITEM")
			cDesc2 += Upper(cSayIT)
		Else // CL. VALOR
			AADD(aOrdem,"CLVL")
			cDesc2 += Upper(cSayCL)
		EndIf
	Next

// por Icaro Queiroz em 01 de setembro de 2015
	If mv_par32 == 1 .And. Len( aSelFil ) <= 0 .And. !IsBlind()
		aSelFil := AdmGetFil()
		If Len( aSelFil ) <= 0
			Return
		EndIf
	EndIf


	Titulo += cDesc2
	wnrel	:= "CTBR295"            //Nome Default do relatorio em Disco

	wnrel := SetPrint(cString,wnrel,"",@titulo,cDesc1,cDesc2,,.F.,"",,Tamanho)

	If nLastKey == 27
		Set Filter To
		Return
	Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se usa Set Of Books + Plano Gerencial (Se usar Plano³
//³ Gerencial -> montagem especifica para impressao)			 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !ct040Valid(mv_par14)
		lRet := .F.
	Else
		aSetOfBook := CTBSetOf(mv_par14)
	Endif

	If mv_par22 == 2			// Divide por cem
		nDivide := 100
	ElseIf mv_par22 == 3		// Divide por mil
		nDivide := 1000
	ElseIf mv_par22 == 4		// Divide por milhao
		nDivide := 1000000
	EndIf

	If lRet
		aCtbMoeda  	:= CtbMoeda(mv_par11,nDivide)
		If Empty(aCtbMoeda[1])
			Help(" ",1,"NOMOEDA")
			lRet := .F.
		Endif
	Endif

	If !Empty(aSetOfBook[5])				// Se houve Indicacao de Plano Gerencial Anexado
		cMensagem := OemToAnsi(STR0012)  // O plano gerencial ainda nao esta disponivel nesse relatorio.
		MsgInfo(cMensagem)
		lRet := .F.
	EndIf
                         
	If lRet
		If Empty(mv_par12) .And. Empty(mv_par13)
			MsgAlert(STR0031)	//"As perguntas 'Tipo de Saldo' e 'Saldo a Comparar' não podem ficar em branco"
			lRet := .F.
		EndIf
	EndIf

	If !lRet
		Set Filter To
		Return
	EndIf

	SetDefault(aReturn,cString)

	If nLastKey == 27
		Set Filter To
		Return
	Endif

	RptStatus({|lEnd| CTR295Imp(@lEnd,wnRel,cString,aSetOfBook,aCtbMoeda,cSayCC,cSayIT,cSayCL,nDivide,aOrdem)})

Return

/*/
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Imprime -> Comparativo de Saldo Mes a Mes - Cta+Custo+Item ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CTR295Imp(lEnd,wnRel,cString,aSetOfBook,aCtbMoeda,cSayCC,cS³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGACTB                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ lEnd 		= Acao do CodeBlock                           ³±±
±±³			 ³ WnRel 		= Titulo do Relatorio				          ³±±
±±³			 ³ cString		= Mensagem						              ³±±
±±³			 ³ aSetOfBook 	= Registro de Config. Livros   		          ³±±
±±³			 ³ aCtbMoeda	= Registro ref. a moeda escolhida             ³±±
±±³			 ³ cSayCC		= Descric.C.Custo utilizado pelo usuario. 	  ³±±
±±³			 ³ nDivide		= Fator de div.dos valores a serem impressos. ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function CTR295Imp(lEnd,WnRel,cString,aSetOfBook,aCtbMoeda,cSayCC,cSayIT,cSayCL,nDivide,aOrdem)

	Local aColunas		:= {}
	Local CbTxt			:= Space(10)
	Local CbCont		:= 0
	Local limite		:= 220
	Local cabec1  		:= ""
	Local cabec2		:= ""
	Local cPicture
	Local cDescMoeda
	Local cCodMasc		:= ""
	Local cMascara		:= ""
	Local cMascCC		:= ""
	Local cMascIT		:= ""
	Local cMascCL		:= ""
	Local cSepara1		:= ""
	Local cSepara2		:= ""
	Local cSepara3		:= ""
	Local cSepara4		:= ""
	Local cGrupo		:= ""
	Local lFirstPage	:= .T.
	Local nDecimais
	Local l132			:= .T.
	Local lImpConta		:= .F.
	Local lImpCusto		:= .T.
	Local nTamConta		:= Len(CriaVar("CT1_CONTA"))
	Local nTamCusto		:= Len(CriaVar("CTT_CUSTO"))
	Local nTamItem 		:= Len(CriaVar("CTD_ITEM"))
	Local nTamClVl		:= Len(CriaVar("CTH_CLVL"))
	Local nTamMasc1		:= 0
	Local nTamMasc2		:= 0
	Local nTamMasc3		:= 0
	Local nTamMasc4		:= 0
	Local cCtaIni		:= mv_par03
	Local cCtaFim		:= mv_par04
	Local nPosAte		:= 0
	Local cArqTmp   	:= ""
	Local cCCSup		:= ""//Centro de Custo Superior do centro de custo atual
	Local cAntCCSup		:= ""//Centro de Custo Superior do centro de custo anterior

	Local lPrintZero	:= Iif(mv_par21==1,.T.,.F.)
	Local lImpAntLP		:= Iif(mv_par23==1,.T.,.F.)
	Local lVlrZerado	:= Iif(mv_par15==1,.T.,.F.)
	Local dDataLP  		:= mv_par24
	Local aMeses		:= {}
	Local dDataFim 		:= mv_par02
	Local nMeses		:= 1
	Local aTotColA		:= {0,0,0,0,0,0,0,0,0,0,0,0}
	Local aTotColB		:= {0,0,0,0,0,0,0,0,0,0,0,0}
	Local aTotColC		:= {0,0,0,0,0,0,0,0,0,0,0,0}

	Local aSupCC		:= {}
	Local nTotLinhaA	:= 0
	Local nTotLinhaB	:= 0
	Local nTotLinhaC	:= 0

	Local nTotGeralA	:= 0
	Local nTotGeralB	:= 0
	Local nTotGeralC	:= 0
	Local nCont			:= 0

	Local lImpCCSint	:= .T.
	Local lNivel1		:= .F.

	Local nPos 			:= 0
	Local n				:= 0
	Local nVezes		:= 0
//Local nPosCC		:= 0 
	Local nTamaTotCC	:= 0
	Local nAtuTotCC		:= 0

	Local cSldB			:= Substr(mv_par13,1,1)
	Local cSldC			:= Substr(mv_par13,2,1)

	Local cDescSLA		:= ALLTRIM(Tabela("SL", mv_par12, .F.))
	Local cDescSLB		:= ALLTRIM(Tabela("SL", cSldB, .F.))
	Local cDescSLC		:= ALLTRIM(Tabela("SL", cSldC, .F.))

	Local lTemSLDA		:= !Empty(mv_par12)
	Local lTemSLDB		:= !Empty(cSldB)
	Local lTemSldC		:= !Empty(cSldC)
	Local lAcum         := mv_par16==2
                                    		
	Local nLenMeses		:= 0
	Local nFatRedSto	:= Iif(lIsRedStor,-1,1)

	cDescMoeda 			:= aCtbMoeda[2]
	nDecimais  			:= DecimalCTB(aSetOfBook,mv_par11)

	aPeriodos 			:= ctbPeriodos(mv_par11, mv_par01, mv_par02, .T., .F.)

	DEFAULT aOrdem := {}

	For nCont := 1 to len(aPeriodos)
	//Se a Data do periodo eh maior ou igual a data inicial solicitada no relatorio.
		If aPeriodos[nCont][1] >= mv_par01 .And. aPeriodos[nCont][2] <= mv_par02
			If nMeses <= 12
				AADD(aMeses,{StrZero(nMeses,2),aPeriodos[nCont][1],aPeriodos[nCont][2]})
			EndIf
			nMeses += 1
		EndIf
	Next

	If Len( aMeses ) == 0
		AADD(aMeses,{'01',mv_par01,mv_par02})
	EndIf

// Mascara da Conta ontabil
	If Empty(aSetOfBook[2])
		cMascara := GetMv("MV_MASCARA")
	Else
		cMascara := RetMasCtb(aSetOfBook[2],@cSepara1)
	EndIf
	nTamMasc1   := IF(Empty(cMascara),nTamConta,If(Empty(cSepara1),nTamConta+Len(cMascara),nTamConta+Len(cSepara1)))

//Mascara do Centro de Custo
	If Empty(aSetOfBook[6])
		cMascCC :=  GetMv("MV_MASCCUS")
	Else
		cMascCC := RetMasCtb(aSetOfBook[6],@cSepara2)
	EndIf
	nTamMasc2  := IF(Empty(cMascCC),nTamCusto,If(Empty(cSepara2),nTamCusto+Len(cMascCC),nTamCusto+Len(cSepara2)))

//Mascara do Item Contabil
	If Empty(aSetOfBook[7])
		cMascIT :=  ""
	Else
		cMascIT := RetMasCtb(aSetOfBook[7],@cSepara3)
	EndIf
	nTamMasc3  := IF(Empty(cMascIT),nTamItem,If(Empty(cSepara3),nTamItem+Len(cMascIT),nTamItem+Len(cSepara3)))

//Mascara da Classe de Valor
	If Empty(aSetOfBook[8])
		cMascCL :=  ""
	Else
		cMascCL := RetMasCtb(aSetOfBook[8],@cSepara4)
	EndIf
	nTamMasc4  := IF(Empty(cMascCL),nTamCLVL,If(Empty(cSepara4),nTamCLVL+Len(cMascCL),nTamCLVL+Len(cSepara4)))

	cPicture := aSetOfBook[4]
	cabec1   := STR0004  //"|CODIGO            |DESCRICAO          |  PERIODO 01  |  PERIODO 02  |  PERIODO 03  |  PERIODO 04  |  PERIODO 05  |  PERIODO 06  |  PERIODO 07  |  PERIODO 08  |  PERIODO 09  |  PERIODO 10  |  PERIODO 11  |  PERIODO 12  |
	tamanho  := "G"
	limite   := 220
	l132     := .F.

	Titulo += 	STR0008 + DTOC(mv_par01) + STR0009 + Dtoc(mv_par02) + STR0010 + cDescMoeda
	Titulo += " (" + cDescSLA + " x "+ cDescSLB + ")"

	aColunas := { 000, 001, 019, 020, 039, 040, 054, 055, 069, 070, 084, 085, 099, 100, 114,  115, 129, 130, 144, 145, 159, 160, 174, 175, 189, 190 , 204, 205, 219}

	cabec1 := STR0004  //"|CODIGO            |DESCRICAO          |  PERIODO 01  |  PERIODO 02  |  PERIODO 03  |  PERIODO 04  |  PERIODO 05  |  PERIODO 06  |  PERIODO 07  |  PERIODO 08  |  PERIODO 09  |  PERIODO 10  |  PERIODO 11  |  PERIODO 12  |
	Cabec1 += PADC(STR0028,18)+"|"	// TOTAL PERIODO*/

	For nCont := 5 to (Len(aColunas)-1)
		aColunas[nCont] -= 19
	Next
	
	cabec2 := "|                   |"

	nLenMeses	:= Len(aMeses)

	For nCont := 1 to nLenMeses
		cabec2 += " "+Strzero(Day(aMeses[nCont][2]),2)+"/"+Strzero(Month(aMeses[nCont][2]),2)+ " - "
		cabec2 += Strzero(Day(aMeses[nCont][3]),2)+"/"+Strzero(Month(aMeses[nCont][3]),2)+"|"
	Next

	If nLenMeses < 12
	/// Se selecionado periodo menor que 12 meses
		For nCont:= nCont to 12
			cabec2+=SPACE(14)+"|"
		Next
	EndIf
	Cabec2 += space(18)+"|"

	m_pag := mv_par17

	cTabSaldo := "CT7"
	cEntid    := ""

	DO CASE
   
	CASE mv_par28 == 1  //  Conta = "Sim"
	
	// Somente Conta
		If mv_par29 == 2 .and. mv_par30 == 2 .and. mv_par31 == 2
			cTabSaldo := "CT7"

	// Conta+CCusto
		ElseIf mv_par29 == 1 .and. mv_par30 == 2 .and. mv_par31 == 2
			cTabSaldo := "CT3"

	// Conta+CCusto+Item  ou  Conta+Item
		ElseIf mv_par30 == 1 .and. mv_par31 == 2
			cTabSaldo := "CT4"

	// Conta+CCusto+Item+Cl.Valor  ou  Conta+CCusto+Cl.Valor  ou  Conta+Item+Cl.Valor  ou  Conta+Cl.Valor
		ElseIf mv_par31 == 1
			cTabSaldo := "CTI"
		EndIf


	CASE mv_par28 == 2  //  Conta = "Nao"

	// Somente C.Custo
		If mv_par29 == 1 .and. mv_par30 == 2 .and. mv_par31 == 2
			cTabSaldo := "CTU"
			cEntid    := "CTT"
		
	// Somente Item
		ElseIf mv_par29 == 2 .and. mv_par30 == 1 .and. mv_par31 == 2
			cTabSaldo := "CTU"
			cEntid    := "CTD"

	// Somente Classe de Valor
		ElseIf mv_par29 == 2 .and. mv_par30 == 2 .and. mv_par31 == 1
			cTabSaldo := "CTU"
			cEntid    := "CTH"

	// C.Custo+Item
		ElseIf mv_par29 == 1 .and. mv_par30 == 1 .and. mv_par31 == 2
			cTabSaldo := "CTV"

	// C.Custo+Classe
		ElseIf mv_par29 == 1 .and. mv_par30 == 2 .and. mv_par31 == 1
			cTabSaldo := "CTW"

	// Item+Classe
		ElseIf mv_par29 == 2 .and. mv_par30 == 1 .and. mv_par31 == 1
			cTabSaldo := "CTX"

	// C.Custo+Item+Classe
		ElseIf mv_par29 == 1 .and. mv_par30 == 1 .and. mv_par31 == 1
			cTabSaldo := "CTY"

		Else
			MsgInfo(STR0038)
			Return
		EndIf
	
	ENDCASE

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta Arquivo Temporario para Impressao 					 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	MsgMeter({|	oMeter, oText, oDlg, lEnd | ;
		xCtCmpSldM(	oMeter, oText, oDlg, @lEnd,@cArqTmp,;
		mv_par01,mv_par02,cTabSaldo,cEntid,;
		mv_par03,mv_par04,mv_par05,mv_par06,mv_par07,mv_par08,mv_par09,mv_par10,;
		mv_par11,mv_par12,mv_par13,aSetOfBook,(mv_par16==2),lImpAntLP,dDataLP,;
		nDivide,"M",aMeses,lVlrZerado,cString,aReturn[7],aOrdem)};
		,STR0013,STR0003)     //"Criando Arquivo Temporario..."#"Balancete Verificacao C.CUSTO / CONTA

	If Select("cArqTmp") == 0
		Return
	EndIf

	dbSelectArea("cArqTmp")
	dbSetOrder(1)
	dbGoTop()

//Se tiver parametrizado com Plano Gerencial, exibe a mensagem que o Plano Gerencial
//nao esta disponivel e sai da rotina.
	If RecCount() == 0 .And. !Empty(aSetOfBook[5])
		dbCloseArea()
	
		If _oCTBR2951 <> Nil
			_oCTBR2951:Delete()
			_oCTBR2951 := Nil
		Endif

		If _oCTBR2952 <> Nil
			_oCTBR2952:Delete()
			_oCTBR2952 := Nil
		Endif
	
		Return
	Endif

	SetRegua(RecCount())

	While !Eof()
	
		If lEnd
			@Prow()+1,0 PSAY STR0016   //"***** CANCELADO PELO OPERADOR *****"
			Exit
		EndIF
	
		IncRegua()
			
	************************* ROTINA DE IMPRESSAO *************************
		If li > 58
			If !lFirstPage
				@ Prow()+1,00 PSAY	Replicate("-",limite)
			EndIf
			CtCGCCabec(,,,Cabec1,Cabec2,dDataFim,Titulo,,"2",Tamanho)
			lFirstPage := .F.
		Else
			li++
		Endif
		
	//Imprime titulo do centro de custo
		@ li,00 PSAY Replicate("-",limite)

		li++
		@ li,aColunas[COL_SEPARA1] PSAY "|"
		lEntAnt := .F.
	
		If mv_par28 == 1	/// Se usa a Conta Contabil
			@ li,PCol()+1 PSAY STR0011
			If mv_par18 == 2 /*.and. cArqTmp->TIPOCONTA == '2'*/ //Se Imprime Cod Reduzido da Conta e eh analitico
				EntidadeCTB(CTARES,li,PCol()+1,nTamMasc1,.F.,cMascara,cSepara1)
			Else //Codigo Reduzido
				EntidadeCTB(CONTA,li,PCol()+1,nTamMasc1,.F.,cMascara,cSepara1)
			Endif
			lEntAnt := .T.
		EndIf

		If mv_par29 == 1 .and. !Empty(CUSTO)	/// Se usa o Centro de Custo
			If lEntAnt
				@ li,PCol()+1 PSAY  "/"
			EndIf
			lEntAnt := .T.
			@ li,PCol()+1 PSAY Upper(cSayCC)
			If mv_par19 == 2 /*.And. cArqTmp->TIPOCC == '2'*/ //Se Imprime Cod Reduzido do C.Custo e eh analitico
				EntidadeCTB(CCRES,li,PCol()+1,nTamMasc2,.F.,cMascCC,cSepara2)
			Else //Se Imprime Cod. Normal do C.Custo
				EntidadeCTB(CUSTO,li,PCol()+1,nTamMasc2,.F.,cMascCC,cSepara2)
			Endif
		EndIf
	
		If mv_par30 == 1 .and. !Empty(ITEM)	/// Se usa o Item Contabil
			If lEntAnt
				@ li,PCol()+1 PSAY  "/"
			EndIf
			lEntAnt := .T.
			@ li,PCol()+1 PSAY Upper(cSayIT)
			If mv_par20 == 2 /*.And. cArqTmp->TIPOITEM == '2'*/ //Se Imprime Cod Reduzido do C.Custo e eh analitico
				EntidadeCTB(ITEMRES,li,PCol()+1,nTamMasc3,.F.,cMascIT,cSepara3)
			Else //Se Imprime Cod. Normal do C.Custo
				EntidadeCTB(ITEM,li,PCol()+1,nTamMasc3,.F.,cMascIT,cSepara3)
			Endif
		EndIf

		If mv_par31 == 1 .and. !Empty(CLVL)	/// Se usa a Classe de Valores
			If lEntAnt
				@ li,PCol()+1 PSAY "/"
			EndIf
			lEntAnt := .T.
			@ li,PCol()+1 PSAY Upper(cSayCL)
		//If mv_par21 == 2 /*.And. cArqTmp->TIPOITEM == '2'*/ //Se Imprime Cod Reduzido do C.Custo e eh analitico
		//	EntidadeCTB(CLVLRES,li,PCol()+1,nTamMasc4,.F.,cMascCL,cSepara4)
		//Else //Se Imprime Cod. Normal do C.Custo
			EntidadeCTB(CLVL,li,PCol()+1,nTamMasc4,.F.,cMascCL,cSepara4)
		//Endif
		EndIf

		If mv_par27 == 1
			lEntAnt := .F.
			@ li,PCol()+1 PSAY "("
			If mv_par28 == 1
				@ li,PCol()+1 PSAY STR0011
				CT1->(dbSetOrder(1))
				CT1->(MsSeek(xFilial("CT1")+cArqTmp->CONTA,.T.))
				@li,PCol()+1 PSAY ALLTRIM(&("CT1->CT1_DESC"+ALLTRIM(mv_par11)))
				lEntAnt := .T.
			EndIf

			If mv_par29 == 1 .and. !Empty(CUSTO)
				If lEntAnt
					@ li,PCol()+1 PSAY "/"
				EndIf
				lEntAnt := .T.
				@ li,PCol()+1 PSAY Upper(cSayCC)
				CTT->(dbSetOrder(1))
				CTT->(MsSeek(xFilial("CTT")+cArqTmp->CUSTO,.T.))
				@li,PCol()+1 PSAY ALLTRIM(&("CTT->CTT_DESC"+ALLTRIM(mv_par11)))
			EndIf

			If mv_par30 == 1 .and. !Empty(ITEM)
				If lEntAnt
					@ li,PCol()+1 PSAY "/"
				EndIf
				@ li,PCol()+1 PSAY Upper(cSayIT)
				lEntAnt := .T.
				CTD->(dbSetOrder(1))
				CTD->(MsSeek(xFilial("CTD")+cArqTmp->ITEM,.T.))
				@li,PCol()+1 PSAY ALLTRIM(&("CTD->CTD_DESC"+ALLTRIM(mv_par11)))
			EndIf

			If mv_par31 == 1  .and. !Empty(CLVL)
				If lEntAnt
					@ li,PCol()+1 PSAY "/"
				EndIf
				@ li,PCol()+1 PSAY Upper(cSayCL)
				lEntAnt := .T.
				CTH->(dbSetOrder(1))
				CTH->(MsSeek(xFilial("CTH")+cArqTmp->CLVL,.T.))
				@li,PCol()+1 PSAY ALLTRIM(&("CTH->CTH_DESC"+ALLTRIM(mv_par11)))
			EndIf
			@ li,PCol()+1 PSAY ")"
		EndIf

		If PCol() < aColunas[COL_SEPARA15]
			@ li,aColunas[COL_SEPARA15] PSAY "|"
		EndIf

	//Calcula o Total das Linhas
		If lTemSldA
			nTotLinhaA	:= IIf (lAcum,COLA12,COLA1+COLA2+COLA3+COLA4+COLA5+COLA6+COLA7+COLA8+COLA9+COLA10+COLA11+COLA12)
		EndiF
		If lTemSldB
			nTotLinhaB	:= IIf (lAcum,COLB12,COLB1+COLB2+COLB3+COLB4+COLB5+COLB6+COLB7+COLB8+COLB9+COLB10+COLB11+COLB12)
		EndIf
		If lTemSldC
			nTotLinhaC	:= IIf (lAcum,COLC12,COLC1+COLC2+COLC3+COLC4+COLC5+COLC6+COLC7+COLC8+COLC9+COLC10+COLC11+COLC12)
		EndIf
	                
		If mv_par16 == 2  // Acumulado
			If lTemSldA
				COLA2  += COLA1
				COLA3  += COLA2
				COLA4  += COLA3
				COLA5  += COLA4
				COLA6  += COLA5
				COLA7  += COLA6
				COLA8  += COLA7
				COLA9  += COLA8
				COLA10 += COLA9
				COLA11 += COLA10
				COLA12 += COLA11
			EndIf
	
			If lTemSldB
				COLB2  += COLB1
				COLB3  += COLB2
				COLB4  += COLB3
				COLB5  += COLB4
				COLB6  += COLB5
				COLB7  += COLB6
				COLB8  += COLB7
				COLB9  += COLB8
				COLB10 += COLB9
				COLB11 += COLB10
				COLB12 += COLB11
			EndIf
	   	
			If lTemSldC
				COLC2  += COLC1
				COLC3  += COLC2
				COLC4  += COLC3
				COLC5  += COLC4
				COLC6  += COLC5
				COLC7  += COLC6
				COLC8  += COLC7
				COLC9  += COLC8
				COLC10 += COLC9
				COLC11 += COLC10
				COLC12 += COLC11
			EndIF
		EndIf

		If lTemSldA			/// SE INDICOU O PRIMEIRO TIPO DE SALDO - LINHA (A)
			li++
		// Imprime os Valores da Linha A		
			@ li,aColunas[COL_SEPARA1] PSAY "|"
			@ li,aColunas[COL_CONTA] PSAY "(A) "+cDescSLA
			@ li,aColunas[COL_SEPARA3] PSAY "|"
			ValorCTB(COLA1,li,aColunas[COL_COLUNA1],12,nDecimais,CtbSinalMov(),cPicture, iif(lIsRedStor,"1",NORMAL), , , , , ,lPrintZero,,,.F.)
			@ li,aColunas[COL_SEPARA4]		PSAY "|"
			ValorCTB(COLA2,li,aColunas[COL_COLUNA2],12,nDecimais,CtbSinalMov(),cPicture, iif(lIsRedStor,"1",NORMAL), , , , , ,lPrintZero,,,.F.)
			@ li,aColunas[COL_SEPARA5]		PSAY "|"
			ValorCTB(COLA3,li,aColunas[COL_COLUNA3],12,nDecimais,CtbSinalMov(),cPicture, iif(lIsRedStor,"1",NORMAL), , , , , ,lPrintZero,,,.F.)
			@ li,aColunas[COL_SEPARA6]		PSAY "|"
			ValorCTB(COLA4,li,aColunas[COL_COLUNA4],12,nDecimais,CtbSinalMov(),cPicture, iif(lIsRedStor,"1",NORMAL), , , , , ,lPrintZero,,,.F.)
			@ li,aColunas[COL_SEPARA7] PSAY "|"
			ValorCTB(COLA5,li,aColunas[COL_COLUNA5],12,nDecimais,CtbSinalMov(),cPicture, iif(lIsRedStor,"1",NORMAL), , , , , ,lPrintZero,,,.F.)
			@ li,aColunas[COL_SEPARA8] PSAY "|"
			ValorCTB(COLA6,li,aColunas[COL_COLUNA6],12,nDecimais,CtbSinalMov(),cPicture, iif(lIsRedStor,"1",NORMAL), , , , , ,lPrintZero,,,.F.)
			@ li,aColunas[COL_SEPARA9] PSAY "|"
			ValorCTB(COLA7,li,aColunas[COL_COLUNA7],12,nDecimais,CtbSinalMov(),cPicture, iif(lIsRedStor,"1",NORMAL), , , , , ,lPrintZero,,,.F.)
			@ li,aColunas[COL_SEPARA10] PSAY "|"
			ValorCTB(COLA8,li,aColunas[COL_COLUNA8],12,nDecimais,CtbSinalMov(),cPicture, iif(lIsRedStor,"1",NORMAL), , , , , ,lPrintZero,,,.F.)
			@ li,aColunas[COL_SEPARA11] PSAY "|"
			ValorCTB(COLA9,li,aColunas[COL_COLUNA9],12,nDecimais,CtbSinalMov(),cPicture, iif(lIsRedStor,"1",NORMAL), , , , , ,lPrintZero,,,.F.)
			@ li,aColunas[COL_SEPARA12] PSAY "|"
			ValorCTB(COLA10,li,aColunas[COL_COLUNA10],12,nDecimais,CtbSinalMov(),cPicture, iif(lIsRedStor,"1",NORMAL), , , , , ,lPrintZero,,,.F.)
			@ li,aColunas[COL_SEPARA13] PSAY "|"
			ValorCTB(COLA11,li,aColunas[COL_COLUNA11],12,nDecimais,CtbSinalMov(),cPicture, iif(lIsRedStor,"1",NORMAL), , , , , ,lPrintZero,,,.F.)
			@ li,aColunas[COL_SEPARA14] PSAY "|"
			ValorCTB(COLA12,li,aColunas[COL_COLUNA12],12,nDecimais,CtbSinalMov(),cPicture, iif(lIsRedStor,"1",NORMAL), , , , , ,lPrintZero,,,.F.)
		// Imprime o Total da Linha A
			@ li,aColunas[COL_SEPARA15]-19 PSAY "|"
			ValorCTB(nTotLinhaA,li,aColunas[COL_SEPARA15]-18,12,nDecimais,CtbSinalMov(),cPicture, iif(lIsRedStor,"1",NORMAL), , , , , ,lPrintZero,,,.F.)
			@ li,aColunas[COL_SEPARA15] PSAY "|"
		EndIf
	
		If lTemSldB			/// SE INDICOU O SEGUNDO TIPO DE SALDO - LINHA (B)
			li++
		//Imprime os Valores da Linha B
			@ li,aColunas[COL_SEPARA1] PSAY "|"
			@ li,aColunas[COL_CONTA] PSAY "(B) "+cDescSLB
			@ li,aColunas[COL_SEPARA3] PSAY "|"
			ValorCTB(COLB1,li,aColunas[COL_COLUNA1],12,nDecimais,CtbSinalMov(),cPicture, iif(lIsRedStor,"1",NORMAL), , , , , ,lPrintZero,,,.F.)
			@ li,aColunas[COL_SEPARA4]		PSAY "|"
			ValorCTB(COLB2,li,aColunas[COL_COLUNA2],12,nDecimais,CtbSinalMov(),cPicture, iif(lIsRedStor,"1",NORMAL), , , , , ,lPrintZero,,,.F.)
			@ li,aColunas[COL_SEPARA5]		PSAY "|"
			ValorCTB(COLB3,li,aColunas[COL_COLUNA3],12,nDecimais,CtbSinalMov(),cPicture, iif(lIsRedStor,"1",NORMAL), , , , , ,lPrintZero,,,.F.)
			@ li,aColunas[COL_SEPARA6]		PSAY "|"
			ValorCTB(COLB4,li,aColunas[COL_COLUNA4],12,nDecimais,CtbSinalMov(),cPicture, iif(lIsRedStor,"1",NORMAL), , , , , ,lPrintZero,,,.F.)
			@ li,aColunas[COL_SEPARA7] PSAY "|"
			ValorCTB(COLB5,li,aColunas[COL_COLUNA5],12,nDecimais,CtbSinalMov(),cPicture, iif(lIsRedStor,"1",NORMAL), , , , , ,lPrintZero,,,.F.)
			@ li,aColunas[COL_SEPARA8] PSAY "|"
			ValorCTB(COLB6,li,aColunas[COL_COLUNA6],12,nDecimais,CtbSinalMov(),cPicture, iif(lIsRedStor,"1",NORMAL), , , , , ,lPrintZero,,,.F.)
			@ li,aColunas[COL_SEPARA9] PSAY "|"
			ValorCTB(COLB7,li,aColunas[COL_COLUNA7],12,nDecimais,CtbSinalMov(),cPicture, iif(lIsRedStor,"1",NORMAL), , , , , ,lPrintZero,,,.F.)
			@ li,aColunas[COL_SEPARA10] PSAY "|"
			ValorCTB(COLB8,li,aColunas[COL_COLUNA8],12,nDecimais,CtbSinalMov(),cPicture, iif(lIsRedStor,"1",NORMAL), , , , , ,lPrintZero,,,.F.)
			@ li,aColunas[COL_SEPARA11] PSAY "|"
			ValorCTB(COLB9,li,aColunas[COL_COLUNA9],12,nDecimais,CtbSinalMov(),cPicture, iif(lIsRedStor,"1",NORMAL), , , , , ,lPrintZero,,,.F.)
			@ li,aColunas[COL_SEPARA12] PSAY "|"
			ValorCTB(COLB10,li,aColunas[COL_COLUNA10],12,nDecimais,CtbSinalMov(),cPicture, iif(lIsRedStor,"1",NORMAL), , , , , ,lPrintZero,,,.F.)
			@ li,aColunas[COL_SEPARA13] PSAY "|"
			ValorCTB(COLB11,li,aColunas[COL_COLUNA11],12,nDecimais,CtbSinalMov(),cPicture, iif(lIsRedStor,"1",NORMAL), , , , , ,lPrintZero,,,.F.)
			@ li,aColunas[COL_SEPARA14] PSAY "|"
			ValorCTB(COLB12,li,aColunas[COL_COLUNA12],12,nDecimais,CtbSinalMov(),cPicture, iif(lIsRedStor,"1",NORMAL), , , , , ,lPrintZero,,,.F.)
		// Imprime o Total da Linha B	
			@ li,aColunas[COL_SEPARA15]-19 PSAY "|"
			ValorCTB(nTotLinhaB,li,aColunas[COL_SEPARA15]-18,12,nDecimais,CtbSinalMov(),cPicture, iif(lIsRedStor,"1",NORMAL), , , , , ,lPrintZero,,,.F.)
			@ li,aColunas[COL_SEPARA15] PSAY "|"
		EndIf
             
		If lTemSldC			/// SE INDICOU O TERCEIRO TIPO DE SALDO - LINHA (C)
			li++
		//Imprime os Valores da Linha C
			@ li,aColunas[COL_SEPARA1] PSAY "|"
			@ li,aColunas[COL_CONTA] PSAY "(C) "+cDescSLC
			@ li,aColunas[COL_SEPARA3] PSAY "|"
			ValorCTB(COLC1,li,aColunas[COL_COLUNA1],12,nDecimais,CtbSinalMov(),cPicture, iif(lIsRedStor,"1",NORMAL), , , , , ,lPrintZero,,,.F.)
			@ li,aColunas[COL_SEPARA4] PSAY "|"
			ValorCTB(COLC2,li,aColunas[COL_COLUNA2],12,nDecimais,CtbSinalMov(),cPicture, iif(lIsRedStor,"1",NORMAL), , , , , ,lPrintZero,,,.F.)
			@ li,aColunas[COL_SEPARA5] PSAY "|"
			ValorCTB(COLC3,li,aColunas[COL_COLUNA3],12,nDecimais,CtbSinalMov(),cPicture, iif(lIsRedStor,"1",NORMAL), , , , , ,lPrintZero,,,.F.)
			@ li,aColunas[COL_SEPARA6] PSAY "|"
			ValorCTB(COLC4,li,aColunas[COL_COLUNA4],12,nDecimais,CtbSinalMov(),cPicture, iif(lIsRedStor,"1",NORMAL), , , , , ,lPrintZero,,,.F.)
			@ li,aColunas[COL_SEPARA7] PSAY "|"
			ValorCTB(COLC5,li,aColunas[COL_COLUNA5],12,nDecimais,CtbSinalMov(),cPicture, iif(lIsRedStor,"1",NORMAL), , , , , ,lPrintZero,,,.F.)
			@ li,aColunas[COL_SEPARA8] PSAY "|"
			ValorCTB(COLC6,li,aColunas[COL_COLUNA6],12,nDecimais,CtbSinalMov(),cPicture, iif(lIsRedStor,"1",NORMAL), , , , , ,lPrintZero,,,.F.)
			@ li,aColunas[COL_SEPARA9] PSAY "|"
			ValorCTB(COLC7,li,aColunas[COL_COLUNA7],12,nDecimais,CtbSinalMov(),cPicture, iif(lIsRedStor,"1",NORMAL), , , , , ,lPrintZero,,,.F.)
			@ li,aColunas[COL_SEPARA10] PSAY "|"
			ValorCTB(COLC8,li,aColunas[COL_COLUNA8],12,nDecimais,CtbSinalMov(),cPicture, iif(lIsRedStor,"1",NORMAL), , , , , ,lPrintZero,,,.F.)
			@ li,aColunas[COL_SEPARA11] PSAY "|"
			ValorCTB(COLC9,li,aColunas[COL_COLUNA9],12,nDecimais,CtbSinalMov(),cPicture, iif(lIsRedStor,"1",NORMAL), , , , , ,lPrintZero,,,.F.)
			@ li,aColunas[COL_SEPARA12] PSAY "|"
			ValorCTB(COLC10,li,aColunas[COL_COLUNA10],12,nDecimais,CtbSinalMov(),cPicture, iif(lIsRedStor,"1",NORMAL), , , , , ,lPrintZero,,,.F.)
			@ li,aColunas[COL_SEPARA13] PSAY "|"
			ValorCTB(COLC11,li,aColunas[COL_COLUNA11],12,nDecimais,CtbSinalMov(),cPicture, iif(lIsRedStor,"1",NORMAL), , , , , ,lPrintZero,,,.F.)
			@ li,aColunas[COL_SEPARA14] PSAY "|"
			ValorCTB(COLC12,li,aColunas[COL_COLUNA12],12,nDecimais,CtbSinalMov(),cPicture, iif(lIsRedStor,"1",NORMAL), , , , , ,lPrintZero,,,.F.)
		// Imprime o Total da Linha C	
			@ li,aColunas[COL_SEPARA15]-19 PSAY "|"
			ValorCTB(nTotLinhaC,li,aColunas[COL_SEPARA15]-18,12,nDecimais,CtbSinalMov(),cPicture, iif(lIsRedStor,"1",NORMAL), , , , , ,lPrintZero,,,.F.)
			@ li,aColunas[COL_SEPARA15] PSAY "|"
		EndIf
	                                     
	///////////////////////////////////////////////////////////////////////////////////////////////
	// Se imprime a variação percentual entre as linhas A e B
	///////////////////////////////////////////////////////////////////////////////////////////////
		If mv_par25 <> 2
			If (mv_par25 == 1 .or. mv_par25 == 3) .and. (lTemSldA .and. lTemSldB)	/// SE INDICOU O 1º e 2º TIPOS DE SALDO - (AxB)
			// Caso linha A ou B estejam zerados a variação devem ser 100% (pelo cálculo daria zero)
				If lIsRedStor
					nVar1	:= ROUND(( (COLB1*nFatRedSto) / (COLA1*nFatRedSto) )*100,2)
					nVar2	:= ROUND(( (COLB2*nFatRedSto) / (COLA2*nFatRedSto) )*100,2)
					nVar3	:= ROUND(( (COLB3*nFatRedSto) / (COLA3*nFatRedSto) )*100,2)
					nVar4	:= ROUND(( (COLB4*nFatRedSto) / (COLA4*nFatRedSto) )*100,2)
					nVar5	:= ROUND(( (COLB5*nFatRedSto) / (COLA5*nFatRedSto) )*100,2)
					nVar6	:= ROUND(( (COLB6*nFatRedSto) / (COLA6*nFatRedSto) )*100,2)
					nVar7	:= ROUND(( (COLB7*nFatRedSto) / (COLA7*nFatRedSto) )*100,2)
					nVar8	:= ROUND(( (COLB8*nFatRedSto) / (COLA8*nFatRedSto) )*100,2)
					nVar9	:= ROUND(( (COLB9*nFatRedSto) / (COLA9*nFatRedSto) )*100,2)
					nVar10	:= ROUND(( (COLB10*nFatRedSto) / (COLA10*nFatRedSto) )*100,2)
					nVar11	:= ROUND(( (COLB11*nFatRedSto) / (COLA11*nFatRedSto) )*100,2)
					nVar12	:= ROUND(( (COLB12*nFatRedSto) / (COLA12*nFatRedSto) )*100,2)
				Else
					nVar1	:= ROUND((COLB1/COLA1)*100,2)
					nVar2	:= ROUND((COLB2/COLA2)*100,2)
					nVar3	:= ROUND((COLB3/COLA3)*100,2)
					nVar4	:= ROUND((COLB4/COLA4)*100,2)
					nVar5	:= ROUND((COLB5/COLA5)*100,2)
					nVar6	:= ROUND((COLB6/COLA6)*100,2)
					nVar7	:= ROUND((COLB7/COLA7)*100,2)
					nVar8	:= ROUND((COLB8/COLA8)*100,2)
					nVar9	:= ROUND((COLB9/COLA9)*100,2)
					nVar10	:= ROUND((COLB10/COLA10)*100,2)
					nVar11	:= ROUND((COLB11/COLA11)*100,2)
					nVar12	:= ROUND((COLB12/COLA12)*100,2)
				Endif
			//Imprime as Varia??es em Percentual
				li++
				@ li,aColunas[COL_SEPARA1]  PSAY "|"
				@ li,aColunas[COL_CONTA]    PSAY STR0029+" AxB (%)" ///"Variação"
				@ li,aColunas[COL_SEPARA3]  PSAY "|"
				@ li,aColunas[COL_COLUNA1]  PSAY Transform(nVar1,"9,999,999.99 %")
				@ li,aColunas[COL_SEPARA4]  PSAY "|"
				@ li,aColunas[COL_COLUNA2]  PSAY Transform(nVar2,"9,999,999.99 %")
				@ li,aColunas[COL_SEPARA5]  PSAY "|"
				@ li,aColunas[COL_COLUNA3]  PSAY Transform(nVar3,"9,999,999.99 %")
				@ li,aColunas[COL_SEPARA6]  PSAY "|"
				@ li,aColunas[COL_COLUNA4]  PSAY Transform(nVar4,"9,999,999.99 %")
				@ li,aColunas[COL_SEPARA7]  PSAY "|"
				@ li,aColunas[COL_COLUNA5]  PSAY Transform(nVar5,"9,999,999.99 %")
				@ li,aColunas[COL_SEPARA8]  PSAY "|"
				@ li,aColunas[COL_COLUNA6]  PSAY Transform(nVar6,"9,999,999.99 %")
				@ li,aColunas[COL_SEPARA9]  PSAY "|"
				@ li,aColunas[COL_COLUNA7]  PSAY Transform(nVar7,"9,999,999.99 %")
				@ li,aColunas[COL_SEPARA10] PSAY "|"
				@ li,aColunas[COL_COLUNA8]  PSAY Transform(nVar8,"9,999,999.99 %")
				@ li,aColunas[COL_SEPARA11] PSAY "|"
				@ li,aColunas[COL_COLUNA9]  PSAY Transform(nVar9,"9,999,999.99 %")
				@ li,aColunas[COL_SEPARA12] PSAY "|"
				@ li,aColunas[COL_COLUNA10] PSAY Transform(nVar10,"9,999,999.99 %")
				@ li,aColunas[COL_SEPARA13] PSAY "|"
				@ li,aColunas[COL_COLUNA11] PSAY Transform(nVar11,"9,999,999.99 %")
				@ li,aColunas[COL_SEPARA14] PSAY "|"
				@ li,aColunas[COL_COLUNA12] PSAY Transform(nVar12,"9,999,999.99 %")
				@ li,aColunas[COL_SEPARA15]-19 PSAY "|"
				@ li,aColunas[COL_SEPARA15] PSAY "|"
			EndIf
		
			If (mv_par25 == 1 .or. mv_par25 == 4) .and. (lTemSldA .and. lTemSldC)	/// SE INDICOU O 1º e 2º TIPOS DE SALDO - (AxB)
			// Caso linha A ou B estejam zerados a variação devem ser 100% (pelo cálculo daria zero)
				If lIsRedStor
					nVar1	:= ROUND(( (COLC1*nFatRedSto) / (COLA1*nFatRedSto) )*100,2)
					nVar2	:= ROUND(( (COLC2*nFatRedSto) / (COLA2*nFatRedSto) )*100,2)
					nVar3	:= ROUND(( (COLC3*nFatRedSto) / (COLA3*nFatRedSto) )*100,2)
					nVar4	:= ROUND(( (COLC4*nFatRedSto) / (COLA4*nFatRedSto) )*100,2)
					nVar5	:= ROUND(( (COLC5*nFatRedSto) / (COLA5*nFatRedSto) )*100,2)
					nVar6	:= ROUND(( (COLC6*nFatRedSto) / (COLA6*nFatRedSto) )*100,2)
					nVar7	:= ROUND(( (COLC7*nFatRedSto) / (COLA7*nFatRedSto) )*100,2)
					nVar8	:= ROUND(( (COLC8*nFatRedSto) / (COLA8*nFatRedSto) )*100,2)
					nVar9	:= ROUND(( (COLC9*nFatRedSto) / (COLA9*nFatRedSto) )*100,2)
					nVar10	:= ROUND(( (COLC10*nFatRedSto) / (COLA10*nFatRedSto) )*100,2)
					nVar11	:= ROUND(( (COLC11*nFatRedSto) / (COLA11*nFatRedSto) )*100,2)
					nVar12	:= ROUND(( (COLC12*nFatRedSto) / (COLA12*nFatRedSto) )*100,2)
				Else
					nVar1	:= ROUND((COLC1/COLA1)*100,2)
					nVar2	:= ROUND((COLC2/COLA2)*100,2)
					nVar3	:= ROUND((COLC3/COLA3)*100,2)
					nVar4	:= ROUND((COLC4/COLA4)*100,2)
					nVar5	:= ROUND((COLC5/COLA5)*100,2)
					nVar6	:= ROUND((COLC6/COLA6)*100,2)
					nVar7	:= ROUND((COLC7/COLA7)*100,2)
					nVar8	:= ROUND((COLC8/COLA8)*100,2)
					nVar9	:= ROUND((COLC9/COLA9)*100,2)
					nVar10	:= ROUND((COLC10/COLA10)*100,2)
					nVar11	:= ROUND((COLC11/COLA11)*100,2)
					nVar12	:= ROUND((COLC12/COLA12)*100,2)
				Endif
			//Imprime as Varia??es em Percentual
				li++
				@ li,aColunas[COL_SEPARA1]  PSAY "|"
				@ li,aColunas[COL_CONTA]    PSAY STR0029+" AxC (%)" //"Variação"
				@ li,aColunas[COL_SEPARA3]  PSAY "|"
				@ li,aColunas[COL_COLUNA1]  PSAY Transform(nVar1,"9,999,999.99 %")
				@ li,aColunas[COL_SEPARA4]  PSAY "|"
				@ li,aColunas[COL_COLUNA2]  PSAY Transform(nVar2,"9,999,999.99 %")
				@ li,aColunas[COL_SEPARA5]  PSAY "|"
				@ li,aColunas[COL_COLUNA3]  PSAY Transform(nVar3,"9,999,999.99 %")
				@ li,aColunas[COL_SEPARA6]  PSAY "|"
				@ li,aColunas[COL_COLUNA4]  PSAY Transform(nVar4,"9,999,999.99 %")
				@ li,aColunas[COL_SEPARA7]  PSAY "|"
				@ li,aColunas[COL_COLUNA5]  PSAY Transform(nVar5,"9,999,999.99 %")
				@ li,aColunas[COL_SEPARA8]  PSAY "|"
				@ li,aColunas[COL_COLUNA6]  PSAY Transform(nVar6,"9,999,999.99 %")
				@ li,aColunas[COL_SEPARA9]  PSAY "|"
				@ li,aColunas[COL_COLUNA7]  PSAY Transform(nVar7,"9,999,999.99 %")
				@ li,aColunas[COL_SEPARA10] PSAY "|"
				@ li,aColunas[COL_COLUNA8]  PSAY Transform(nVar8,"9,999,999.99 %")
				@ li,aColunas[COL_SEPARA11] PSAY "|"
				@ li,aColunas[COL_COLUNA9]  PSAY Transform(nVar9,"9,999,999.99 %")
				@ li,aColunas[COL_SEPARA12] PSAY "|"
				@ li,aColunas[COL_COLUNA10] PSAY Transform(nVar10,"9,999,999.99 %")
				@ li,aColunas[COL_SEPARA13] PSAY "|"
				@ li,aColunas[COL_COLUNA11] PSAY Transform(nVar11,"9,999,999.99 %")
				@ li,aColunas[COL_SEPARA14] PSAY "|"
				@ li,aColunas[COL_COLUNA12] PSAY Transform(nVar12,"9,999,999.99 %")
				@ li,aColunas[COL_SEPARA15]-19 PSAY "|"
				@ li,aColunas[COL_SEPARA15] PSAY "|"
			EndIf
		
			If (mv_par25 == 1 .or. mv_par25 == 5) .and. (lTemSldB .and. lTemSldC)	/// SE INDICOU O 1º e 2º TIPOS DE SALDO - (AxB)
			// Caso linha A ou B estejam zerados a variação devem ser 100% (pelo cálculo daria zero)
				If lIsRedStor
					nVar1	:= ROUND(( (COLC1*nFatRedSto) / (COLB1*nFatRedSto) )*100,2)
					nVar2	:= ROUND(( (COLC2*nFatRedSto) / (COLB2*nFatRedSto) )*100,2)
					nVar3	:= ROUND(( (COLC3*nFatRedSto) / (COLB3*nFatRedSto) )*100,2)
					nVar4	:= ROUND(( (COLC4*nFatRedSto) / (COLB4*nFatRedSto) )*100,2)
					nVar5	:= ROUND(( (COLC5*nFatRedSto) / (COLB5*nFatRedSto) )*100,2)
					nVar6	:= ROUND(( (COLC6*nFatRedSto) / (COLB6*nFatRedSto) )*100,2)
					nVar7	:= ROUND(( (COLC7*nFatRedSto) / (COLB7*nFatRedSto) )*100,2)
					nVar8	:= ROUND(( (COLC8*nFatRedSto) / (COLB8*nFatRedSto) )*100,2)
					nVar9	:= ROUND(( (COLC9*nFatRedSto) / (COLB9*nFatRedSto) )*100,2)
					nVar10	:= ROUND(( (COLC10*nFatRedSto) / (COLB10*nFatRedSto) )*100,2)
					nVar11	:= ROUND(( (COLC11*nFatRedSto) / (COLB11*nFatRedSto) )*100,2)
					nVar12	:= ROUND(( (COLC12*nFatRedSto) / (COLB12*nFatRedSto) )*100,2)
				Else
					nVar1	:= ROUND((COLC1/COLB1)*100,2)
					nVar2	:= ROUND((COLC2/COLB2)*100,2)
					nVar3	:= ROUND((COLC3/COLB3)*100,2)
					nVar4	:= ROUND((COLC4/COLB4)*100,2)
					nVar5	:= ROUND((COLC5/COLB5)*100,2)
					nVar6	:= ROUND((COLC6/COLB6)*100,2)
					nVar7	:= ROUND((COLC7/COLB7)*100,2)
					nVar8	:= ROUND((COLC8/COLB8)*100,2)
					nVar9	:= ROUND((COLC9/COLB9)*100,2)
					nVar10	:= ROUND((COLC10/COLB10)*100,2)
					nVar11	:= ROUND((COLC11/COLB11)*100,2)
					nVar12	:= ROUND((COLC12/COLB12)*100,2)
				Endif
			//Imprime as Varia??es em Percentual
				li++
				@ li,aColunas[COL_SEPARA1]  PSAY "|"
				@ li,aColunas[COL_CONTA]    PSAY STR0029+" BxC (%)" // "Variação"
				@ li,aColunas[COL_SEPARA3]  PSAY "|"
				@ li,aColunas[COL_COLUNA1]  PSAY Transform(nVar1,"9,999,999.99 %")
				@ li,aColunas[COL_SEPARA4]  PSAY "|"
				@ li,aColunas[COL_COLUNA2]  PSAY Transform(nVar2,"9,999,999.99 %")
				@ li,aColunas[COL_SEPARA5]  PSAY "|"
				@ li,aColunas[COL_COLUNA3]  PSAY Transform(nVar3,"9,999,999.99 %")
				@ li,aColunas[COL_SEPARA6]  PSAY "|"
				@ li,aColunas[COL_COLUNA4]  PSAY Transform(nVar4,"9,999,999.99 %")
				@ li,aColunas[COL_SEPARA7]  PSAY "|"
				@ li,aColunas[COL_COLUNA5]  PSAY Transform(nVar5,"9,999,999.99 %")
				@ li,aColunas[COL_SEPARA8]  PSAY "|"
				@ li,aColunas[COL_COLUNA6]  PSAY Transform(nVar6,"9,999,999.99 %")
				@ li,aColunas[COL_SEPARA9]  PSAY "|"
				@ li,aColunas[COL_COLUNA7]  PSAY Transform(nVar7,"9,999,999.99 %")
				@ li,aColunas[COL_SEPARA10] PSAY "|"
				@ li,aColunas[COL_COLUNA8]  PSAY Transform(nVar8,"9,999,999.99 %")
				@ li,aColunas[COL_SEPARA11] PSAY "|"
				@ li,aColunas[COL_COLUNA9]  PSAY Transform(nVar9,"9,999,999.99 %")
				@ li,aColunas[COL_SEPARA12] PSAY "|"
				@ li,aColunas[COL_COLUNA10] PSAY Transform(nVar10,"9,999,999.99 %")
				@ li,aColunas[COL_SEPARA13] PSAY "|"
				@ li,aColunas[COL_COLUNA11] PSAY Transform(nVar11,"9,999,999.99 %")
				@ li,aColunas[COL_SEPARA14] PSAY "|"
				@ li,aColunas[COL_COLUNA12] PSAY Transform(nVar12,"9,999,999.99 %")
				@ li,aColunas[COL_SEPARA15]-19 PSAY "|"
				@ li,aColunas[COL_SEPARA15] PSAY "|"
			EndIf
		EndIf
        
	////////////////////////////////////////////////////////////////////////////////////////////////////
	// Se imprime a variação em VALOR ($) entre as linhas A e B
	///////////////////////////////////////////////////////////////////////////////////////////////////
		If mv_par26 <> 2
			If (mv_par26 == 1 .or. mv_par26 == 3) .and. (lTemSldA .and. lTemSldB)	/// SE INDICOU O 1? e 2? TIPOS DE SALDO - (AxB)
				li++
				@ li,aColunas[COL_SEPARA1]  PSAY "|"
				@ li,aColunas[COL_CONTA]    PSAY STR0030+" AxB ($)" //"Diferen?a"
				@ li,aColunas[COL_SEPARA3]  PSAY "|"
				ValorCTB((COLB1*nFatRedSto)-(COLA1*nFatRedSto),li,aColunas[COL_COLUNA1],12,nDecimais,CtbSinalMov(),cPicture, iif(lIsRedStor,"1",NORMAL), , , , , ,lPrintZero,,,.F.)
				@ li,aColunas[COL_SEPARA4]	PSAY "|"
				ValorCTB((COLB2*nFatRedSto)-(COLA2*nFatRedSto),li,aColunas[COL_COLUNA2],12,nDecimais,CtbSinalMov(),cPicture, iif(lIsRedStor,"1",NORMAL), , , , , ,lPrintZero,,,.F.)
				@ li,aColunas[COL_SEPARA5]	PSAY "|"
				ValorCTB((COLB3*nFatRedSto)-(COLA3*nFatRedSto),li,aColunas[COL_COLUNA3],12,nDecimais,CtbSinalMov(),cPicture, iif(lIsRedStor,"1",NORMAL), , , , , ,lPrintZero,,,.F.)
				@ li,aColunas[COL_SEPARA6]	PSAY "|"
				ValorCTB((COLB4*nFatRedSto)-(COLA4*nFatRedSto),li,aColunas[COL_COLUNA4],12,nDecimais,CtbSinalMov(),cPicture, iif(lIsRedStor,"1",NORMAL), , , , , ,lPrintZero,,,.F.)
				@ li,aColunas[COL_SEPARA7] PSAY "|"
				ValorCTB((COLB5*nFatRedSto)-(COLA5*nFatRedSto),li,aColunas[COL_COLUNA5],12,nDecimais,CtbSinalMov(),cPicture, iif(lIsRedStor,"1",NORMAL), , , , , ,lPrintZero,,,.F.)
				@ li,aColunas[COL_SEPARA8] PSAY "|"
				ValorCTB((COLB6*nFatRedSto)-(COLA6*nFatRedSto),li,aColunas[COL_COLUNA6],12,nDecimais,CtbSinalMov(),cPicture, iif(lIsRedStor,"1",NORMAL), , , , , ,lPrintZero,,,.F.)
				@ li,aColunas[COL_SEPARA9] PSAY "|"
				ValorCTB((COLB7*nFatRedSto)-(COLA7*nFatRedSto),li,aColunas[COL_COLUNA7],12,nDecimais,CtbSinalMov(),cPicture, iif(lIsRedStor,"1",NORMAL), , , , , ,lPrintZero,,,.F.)
				@ li,aColunas[COL_SEPARA10] PSAY "|"
				ValorCTB((COLB8*nFatRedSto)-(COLA8*nFatRedSto),li,aColunas[COL_COLUNA8],12,nDecimais,CtbSinalMov(),cPicture, iif(lIsRedStor,"1",NORMAL), , , , , ,lPrintZero,,,.F.)
				@ li,aColunas[COL_SEPARA11] PSAY "|"
				ValorCTB((COLB9*nFatRedSto)-(COLA9*nFatRedSto),li,aColunas[COL_COLUNA9],12,nDecimais,CtbSinalMov(),cPicture, iif(lIsRedStor,"1",NORMAL), , , , , ,lPrintZero,,,.F.)
				@ li,aColunas[COL_SEPARA12] PSAY "|"
				ValorCTB((COLB10*nFatRedSto)-(COLA10*nFatRedSto),li,aColunas[COL_COLUNA10],12,nDecimais,CtbSinalMov(),cPicture, iif(lIsRedStor,"1",NORMAL), , , , , ,lPrintZero,,,.F.)
				@ li,aColunas[COL_SEPARA13] PSAY "|"
				ValorCTB((COLB11*nFatRedSto)-(COLA11*nFatRedSto),li,aColunas[COL_COLUNA11],12,nDecimais,CtbSinalMov(),cPicture, iif(lIsRedStor,"1",NORMAL), , , , , ,lPrintZero,,,.F.)
				@ li,aColunas[COL_SEPARA14] PSAY "|"
				ValorCTB((COLB12*nFatRedSto)-(COLA12*nFatRedSto),li,aColunas[COL_COLUNA12],12,nDecimais,CtbSinalMov(),cPicture, iif(lIsRedStor,"1",NORMAL), , , , , ,lPrintZero,,,.F.)
				@ li,aColunas[COL_SEPARA15]-19 PSAY "|"
				@ li,aColunas[COL_SEPARA15] PSAY "|"
			EndIf
		
			If (mv_par26 == 1 .or. mv_par26 == 4) .and. (lTemSldA .and. lTemSldC)	/// SE INDICOU O 1º e 3º TIPOS DE SALDO - (AxC)
				li++
				@ li,aColunas[COL_SEPARA1]  PSAY "|"
				@ li,aColunas[COL_CONTA]    PSAY STR0030+" AxC ($)" // "Diferen?a"
				@ li,aColunas[COL_SEPARA3]  PSAY "|"
				ValorCTB((COLC1*nFatRedSto)-(COLA1*nFatRedSto),li,aColunas[COL_COLUNA1],12,nDecimais,CtbSinalMov(),cPicture, iif(lIsRedStor,"1",NORMAL), , , , , ,lPrintZero,,,.F.)
				@ li,aColunas[COL_SEPARA4]	PSAY "|"
				ValorCTB((COLC2*nFatRedSto)-(COLA2*nFatRedSto),li,aColunas[COL_COLUNA2],12,nDecimais,CtbSinalMov(),cPicture, iif(lIsRedStor,"1",NORMAL), , , , , ,lPrintZero,,,.F.)
				@ li,aColunas[COL_SEPARA5]	PSAY "|"
				ValorCTB((COLC3*nFatRedSto)-(COLA3*nFatRedSto),li,aColunas[COL_COLUNA3],12,nDecimais,CtbSinalMov(),cPicture, iif(lIsRedStor,"1",NORMAL), , , , , ,lPrintZero,,,.F.)
				@ li,aColunas[COL_SEPARA6]	PSAY "|"
				ValorCTB((COLC4*nFatRedSto)-(COLA4*nFatRedSto),li,aColunas[COL_COLUNA4],12,nDecimais,CtbSinalMov(),cPicture, iif(lIsRedStor,"1",NORMAL), , , , , ,lPrintZero,,,.F.)
				@ li,aColunas[COL_SEPARA7] PSAY "|"
				ValorCTB((COLC5*nFatRedSto)-(COLA5*nFatRedSto),li,aColunas[COL_COLUNA5],12,nDecimais,CtbSinalMov(),cPicture, iif(lIsRedStor,"1",NORMAL), , , , , ,lPrintZero,,,.F.)
				@ li,aColunas[COL_SEPARA8] PSAY "|"
				ValorCTB((COLC6*nFatRedSto)-(COLA6*nFatRedSto),li,aColunas[COL_COLUNA6],12,nDecimais,CtbSinalMov(),cPicture, iif(lIsRedStor,"1",NORMAL), , , , , ,lPrintZero,,,.F.)
				@ li,aColunas[COL_SEPARA9] PSAY "|"
				ValorCTB((COLC7*nFatRedSto)-(COLA7*nFatRedSto),li,aColunas[COL_COLUNA7],12,nDecimais,CtbSinalMov(),cPicture, iif(lIsRedStor,"1",NORMAL), , , , , ,lPrintZero,,,.F.)
				@ li,aColunas[COL_SEPARA10] PSAY "|"
				ValorCTB((COLC8*nFatRedSto)-(COLA8*nFatRedSto),li,aColunas[COL_COLUNA8],12,nDecimais,CtbSinalMov(),cPicture, iif(lIsRedStor,"1",NORMAL), , , , , ,lPrintZero,,,.F.)
				@ li,aColunas[COL_SEPARA11] PSAY "|"
				ValorCTB((COLC9*nFatRedSto)-(COLA9*nFatRedSto),li,aColunas[COL_COLUNA9],12,nDecimais,CtbSinalMov(),cPicture, iif(lIsRedStor,"1",NORMAL), , , , , ,lPrintZero,,,.F.)
				@ li,aColunas[COL_SEPARA12] PSAY "|"
				ValorCTB((COLC10*nFatRedSto)-(COLA10*nFatRedSto),li,aColunas[COL_COLUNA10],12,nDecimais,CtbSinalMov(),cPicture, iif(lIsRedStor,"1",NORMAL), , , , , ,lPrintZero,,,.F.)
				@ li,aColunas[COL_SEPARA13] PSAY "|"
				ValorCTB((COLC11*nFatRedSto)-(COLA11*nFatRedSto),li,aColunas[COL_COLUNA11],12,nDecimais,CtbSinalMov(),cPicture, iif(lIsRedStor,"1",NORMAL), , , , , ,lPrintZero,,,.F.)
				@ li,aColunas[COL_SEPARA14] PSAY "|"
				ValorCTB((COLC12*nFatRedSto)-(COLA12*nFatRedSto),li,aColunas[COL_COLUNA12],12,nDecimais,CtbSinalMov(),cPicture, iif(lIsRedStor,"1",NORMAL), , , , , ,lPrintZero,,,.F.)
				@ li,aColunas[COL_SEPARA15]-19 PSAY "|"
				@ li,aColunas[COL_SEPARA15] PSAY "|"
			EndIf
		
			If (mv_par26 == 1 .or. mv_par26 == 5) .and. (lTemSldB .and. lTemSldC)	/// SE INDICOU O 2º e 3º TIPOS DE SALDO - (BxC)
				li++
				@ li,aColunas[COL_SEPARA1]  PSAY "|"
				@ li,aColunas[COL_CONTA]    PSAY STR0030+" BxC ($)" // "Diferen?a"
				@ li,aColunas[COL_SEPARA3]  PSAY "|"
				ValorCTB((COLC1*nFatRedSto)-(COLB1*nFatRedSto),li,aColunas[COL_COLUNA1],12,nDecimais,CtbSinalMov(),cPicture, iif(lIsRedStor,"1",NORMAL), , , , , ,lPrintZero,,,.F.)
				@ li,aColunas[COL_SEPARA4]	PSAY "|"
				ValorCTB((COLC2*nFatRedSto)-(COLB2*nFatRedSto),li,aColunas[COL_COLUNA2],12,nDecimais,CtbSinalMov(),cPicture, iif(lIsRedStor,"1",NORMAL), , , , , ,lPrintZero,,,.F.)
				@ li,aColunas[COL_SEPARA5]	PSAY "|"
				ValorCTB((COLC3*nFatRedSto)-(COLB3*nFatRedSto),li,aColunas[COL_COLUNA3],12,nDecimais,CtbSinalMov(),cPicture, iif(lIsRedStor,"1",NORMAL), , , , , ,lPrintZero,,,.F.)
				@ li,aColunas[COL_SEPARA6]	PSAY "|"
				ValorCTB((COLC4*nFatRedSto)-(COLB4*nFatRedSto),li,aColunas[COL_COLUNA4],12,nDecimais,CtbSinalMov(),cPicture, iif(lIsRedStor,"1",NORMAL), , , , , ,lPrintZero,,,.F.)
				@ li,aColunas[COL_SEPARA7] PSAY "|"
				ValorCTB((COLC5*nFatRedSto)-(COLB5*nFatRedSto),li,aColunas[COL_COLUNA5],12,nDecimais,CtbSinalMov(),cPicture, iif(lIsRedStor,"1",NORMAL), , , , , ,lPrintZero,,,.F.)
				@ li,aColunas[COL_SEPARA8] PSAY "|"
				ValorCTB((COLC6*nFatRedSto)-(COLB6*nFatRedSto),li,aColunas[COL_COLUNA6],12,nDecimais,CtbSinalMov(),cPicture, iif(lIsRedStor,"1",NORMAL), , , , , ,lPrintZero,,,.F.)
				@ li,aColunas[COL_SEPARA9] PSAY "|"
				ValorCTB((COLC7*nFatRedSto)-(COLB7*nFatRedSto),li,aColunas[COL_COLUNA7],12,nDecimais,CtbSinalMov(),cPicture, iif(lIsRedStor,"1",NORMAL), , , , , ,lPrintZero,,,.F.)
				@ li,aColunas[COL_SEPARA10] PSAY "|"
				ValorCTB((COLC8*nFatRedSto)-(COLB8*nFatRedSto),li,aColunas[COL_COLUNA8],12,nDecimais,CtbSinalMov(),cPicture, iif(lIsRedStor,"1",NORMAL), , , , , ,lPrintZero,,,.F.)
				@ li,aColunas[COL_SEPARA11] PSAY "|"
				ValorCTB((COLC9*nFatRedSto)-(COLB9*nFatRedSto),li,aColunas[COL_COLUNA9],12,nDecimais,CtbSinalMov(),cPicture, iif(lIsRedStor,"1",NORMAL), , , , , ,lPrintZero,,,.F.)
				@ li,aColunas[COL_SEPARA12] PSAY "|"
				ValorCTB((COLC10*nFatRedSto)-(COLB10*nFatRedSto),li,aColunas[COL_COLUNA10],12,nDecimais,CtbSinalMov(),cPicture, iif(lIsRedStor,"1",NORMAL), , , , , ,lPrintZero,,,.F.)
				@ li,aColunas[COL_SEPARA13] PSAY "|"
				ValorCTB((COLC11*nFatRedSto)-(COLB11*nFatRedSto),li,aColunas[COL_COLUNA11],12,nDecimais,CtbSinalMov(),cPicture, iif(lIsRedStor,"1",NORMAL), , , , , ,lPrintZero,,,.F.)
				@ li,aColunas[COL_SEPARA14] PSAY "|"
				ValorCTB((COLC12*nFatRedSto)-(COLB12*nFatRedSto),li,aColunas[COL_COLUNA12],12,nDecimais,CtbSinalMov(),cPicture, iif(lIsRedStor,"1",NORMAL), , , , , ,lPrintZero,,,.F.)
				@ li,aColunas[COL_SEPARA15]-19 PSAY "|"
				@ li,aColunas[COL_SEPARA15] PSAY "|"
			EndIf
		
		EndIf
	
		For nVezes := 1 to nLenMeses
			If lTemSldA
				aTotColA[nVezes] 	+= &("COLA"+Alltrim(Str(nVezes,2)))
			EndIf
			If lTemSldB
				aTotColB[nVezes] 	+= &("COLB"+Alltrim(Str(nVezes,2)))
			EndIf
			If lTemSldC
				aTotColC[nVezes] 	+= &("COLC"+Alltrim(Str(nVezes,2)))
			EndIf
		Next

		nTotLinhaA	:= 0
		nTotLinhaB	:= 0
		nTotLinhaC	:= 0
    
		dbSelectarea("cArqTmp")
		dbSkip()
	EndDo

	If !lEnd
		If li > 58
			If !lFirstPage
				@ Prow()+1,00 PSAY	Replicate("-",limite)
			EndIf
			CtCGCCabec(,,,Cabec1,Cabec2,dDataFim,Titulo,,"2",Tamanho)
		Else
			li++
		Endif

		@li,00 PSAY REPLICATE("-",limite)
		li++
		@li,00 PSAY REPLICATE("-",limite)
	
	//TOTAL GERAL
		For nCont := 1 to nLenMeses
			If mv_par16 == 1  // Mov. por Período
				If lTemSldA
					nTotGeralA	+= aTotColA[nCont]
				EndIf
				If lTemSldB
					nTotGeralB	+= aTotColB[nCont]
				EndIf
				If lTemSldC
					nTotGeralC	+= aTotColC[nCont]
				EndIf
			Else
				If lTemSldA .and. ABS(aTotColA[nCont]) > 0
					nTotGeralA := aTotColA[nCont]
				EndIf
				If lTemSldB .and.  ABS(aTotColB[nCont]) > 0
					nTotGeralB := aTotColB[nCont]
				EndIf
				If lTemSldC .and.  ABS(aTotColC[nCont]) > 0
					nTotGeralC	+= aTotColC[nCont]
				EndIf
			EndIf
		Next

		If lTemSldA
			li++
			@li,aColunas[COL_SEPARA1] PSAY "|"
			@li,aColunas[COL_CONTA]   PSAY STR0026+cDescSLA  		//"TOTAIS "
			@li,aColunas[COL_SEPARA2]		PSAY "|"
		
			ValorCTB(aTotColA[1],li,aColunas[COL_COLUNA1],12,nDecimais,CtbSinalMov(),cPicture,iif(lIsRedStor,"1",""), , , , , ,lPrintZero,,,.F.)
			@ li,aColunas[COL_SEPARA4]		PSAY "|"
			ValorCTB(aTotColA[2],li,aColunas[COL_COLUNA2],12,nDecimais,CtbSinalMov(),cPicture,iif(lIsRedStor,"1",""), , , , , ,lPrintZero,,,.F.)
			@ li,aColunas[COL_SEPARA5]		PSAY "|"
			ValorCTB(aTotColA[3],li,aColunas[COL_COLUNA3],12,nDecimais,CtbSinalMov(),cPicture,iif(lIsRedStor,"1",""), , , , , ,lPrintZero,,,.F.)
			@ li,aColunas[COL_SEPARA6]		PSAY "|"
			ValorCTB(aTotColA[4],li,aColunas[COL_COLUNA4],12,nDecimais,CtbSinalMov(),cPicture,iif(lIsRedStor,"1",""), , , , , ,lPrintZero,,,.F.)
			@ li,aColunas[COL_SEPARA7] PSAY "|"
			ValorCTB(aTotColA[5],li,aColunas[COL_COLUNA5],12,nDecimais,CtbSinalMov(),cPicture,iif(lIsRedStor,"1",""), , , , , ,lPrintZero,,,.F.)
			@ li,aColunas[COL_SEPARA8] PSAY "|"
			ValorCTB(aTotColA[6],li,aColunas[COL_COLUNA6],12,nDecimais,CtbSinalMov(),cPicture,iif(lIsRedStor,"1",""), , , , , ,lPrintZero,,,.F.)
			@ li,aColunas[COL_SEPARA9] PSAY "|"
			ValorCTB(aTotColA[7],li,aColunas[COL_COLUNA7],12,nDecimais,CtbSinalMov(),cPicture,iif(lIsRedStor,"1",""), , , , , ,lPrintZero,,,.F.)
			@ li,aColunas[COL_SEPARA10] PSAY "|"
			ValorCTB(aTotColA[8],li,aColunas[COL_COLUNA8],12,nDecimais,CtbSinalMov(),cPicture,iif(lIsRedStor,"1",""), , , , , ,lPrintZero,,,.F.)
			@ li,aColunas[COL_SEPARA11] PSAY "|"
			ValorCTB(aTotColA[9],li,aColunas[COL_COLUNA9],12,nDecimais,CtbSinalMov(),cPicture,iif(lIsRedStor,"1",""), , , , , ,lPrintZero,,,.F.)
			@ li,aColunas[COL_SEPARA12] PSAY "|"
			ValorCTB(aTotColA[10],li,aColunas[COL_COLUNA10],12,nDecimais,CtbSinalMov(),cPicture,iif(lIsRedStor,"1",""), , , , , ,lPrintZero,,,.F.)
			@ li,aColunas[COL_SEPARA13] PSAY "|"
			ValorCTB(aTotColA[11],li,aColunas[COL_COLUNA11],12,nDecimais,CtbSinalMov(),cPicture,iif(lIsRedStor,"1",""), , , , , ,lPrintZero,,,.F.)
			@ li,aColunas[COL_SEPARA14] PSAY "|"
			ValorCTB(aTotColA[12],li,aColunas[COL_COLUNA12],12,nDecimais,CtbSinalMov(),cPicture,iif(lIsRedStor,"1",""), , , , , ,lPrintZero,,,.F.)
		/// Total Geral da Coluna A
			@ li,aColunas[COL_SEPARA15]-19 PSAY "|"
			ValorCTB(nTotGeralA,li,aColunas[COL_SEPARA15]-18,12,nDecimais,CtbSinalMov(),cPicture, iif(lIsRedStor,"1",NORMAL), , , , , ,lPrintZero,,,.F.)
			@ li,aColunas[COL_SEPARA15] PSAY "|"
		EndIf

		If lTemSldB
			li++
			@li,aColunas[COL_SEPARA1] PSAY "|"
			@li,aColunas[COL_CONTA]   PSAY STR0026+cDescSLB  		//"TOTAIS DO SALDO B (COLUNAS B)"
			@li,aColunas[COL_SEPARA2]		PSAY "|"
		
			ValorCTB(aTotColB[1],li,aColunas[COL_COLUNA1],12,nDecimais,CtbSinalMov(),cPicture,iif(lIsRedStor,"1",""), , , , , ,lPrintZero,,,.F.)
			@ li,aColunas[COL_SEPARA4]		PSAY "|"
			ValorCTB(aTotColB[2],li,aColunas[COL_COLUNA2],12,nDecimais,CtbSinalMov(),cPicture,iif(lIsRedStor,"1",""), , , , , ,lPrintZero,,,.F.)
			@ li,aColunas[COL_SEPARA5]		PSAY "|"
			ValorCTB(aTotColB[3],li,aColunas[COL_COLUNA3],12,nDecimais,CtbSinalMov(),cPicture,iif(lIsRedStor,"1",""), , , , , ,lPrintZero,,,.F.)
			@ li,aColunas[COL_SEPARA6]		PSAY "|"
			ValorCTB(aTotColB[4],li,aColunas[COL_COLUNA4],12,nDecimais,CtbSinalMov(),cPicture,iif(lIsRedStor,"1",""), , , , , ,lPrintZero,,,.F.)
			@ li,aColunas[COL_SEPARA7] PSAY "|"
			ValorCTB(aTotColB[5],li,aColunas[COL_COLUNA5],12,nDecimais,CtbSinalMov(),cPicture,iif(lIsRedStor,"1",""), , , , , ,lPrintZero,,,.F.)
			@ li,aColunas[COL_SEPARA8] PSAY "|"
			ValorCTB(aTotColB[6],li,aColunas[COL_COLUNA6],12,nDecimais,CtbSinalMov(),cPicture,iif(lIsRedStor,"1",""), , , , , ,lPrintZero,,,.F.)
			@ li,aColunas[COL_SEPARA9] PSAY "|"
			ValorCTB(aTotColB[7],li,aColunas[COL_COLUNA7],12,nDecimais,CtbSinalMov(),cPicture,iif(lIsRedStor,"1",""), , , , , ,lPrintZero,,,.F.)
			@ li,aColunas[COL_SEPARA10] PSAY "|"
			ValorCTB(aTotColB[8],li,aColunas[COL_COLUNA8],12,nDecimais,CtbSinalMov(),cPicture,iif(lIsRedStor,"1",""), , , , , ,lPrintZero,,,.F.)
			@ li,aColunas[COL_SEPARA11] PSAY "|"
			ValorCTB(aTotColB[9],li,aColunas[COL_COLUNA9],12,nDecimais,CtbSinalMov(),cPicture,iif(lIsRedStor,"1",""), , , , , ,lPrintZero,,,.F.)
			@ li,aColunas[COL_SEPARA12] PSAY "|"
			ValorCTB(aTotColB[10],li,aColunas[COL_COLUNA10],12,nDecimais,CtbSinalMov(),cPicture,iif(lIsRedStor,"1",""), , , , , ,lPrintZero,,,.F.)
			@ li,aColunas[COL_SEPARA13] PSAY "|"
			ValorCTB(aTotColB[11],li,aColunas[COL_COLUNA11],12,nDecimais,CtbSinalMov(),cPicture,iif(lIsRedStor,"1",""), , , , , ,lPrintZero,,,.F.)
			@ li,aColunas[COL_SEPARA14] PSAY "|"
			ValorCTB(aTotColB[12],li,aColunas[COL_COLUNA12],12,nDecimais,CtbSinalMov(),cPicture,iif(lIsRedStor,"1",""), , , , , ,lPrintZero,,,.F.)
		/// Total Geral da Coluna B
			@ li,aColunas[COL_SEPARA15]-19 PSAY "|"
			ValorCTB(nTotGeralB,li,aColunas[COL_SEPARA15]-18,12,nDecimais,CtbSinalMov(),cPicture,iif(lIsRedStor,"1","") , , , , , ,lPrintZero,,,.F.)
			@ li,aColunas[COL_SEPARA15] PSAY "|"
		EndIf
	
		If lTemSldC
			li++
			@li,aColunas[COL_SEPARA1] PSAY "|"
			@li,aColunas[COL_CONTA]   PSAY STR0026+cDescSLC  		//"TOTAIS DO SALDO B (COLUNAS B)"
			@li,aColunas[COL_SEPARA2]		PSAY "|"
		
			ValorCTB(aTotColC[1],li,aColunas[COL_COLUNA1],12,nDecimais,CtbSinalMov(),cPicture,iif(lIsRedStor,"1",""), , , , , ,lPrintZero,,,.F.)
			@ li,aColunas[COL_SEPARA4]		PSAY "|"
			ValorCTB(aTotColC[2],li,aColunas[COL_COLUNA2],12,nDecimais,CtbSinalMov(),cPicture,iif(lIsRedStor,"1",""), , , , , ,lPrintZero,,,.F.)
			@ li,aColunas[COL_SEPARA5]		PSAY "|"
			ValorCTB(aTotColC[3],li,aColunas[COL_COLUNA3],12,nDecimais,CtbSinalMov(),cPicture,iif(lIsRedStor,"1",""), , , , , ,lPrintZero,,,.F.)
			@ li,aColunas[COL_SEPARA6]		PSAY "|"
			ValorCTB(aTotColC[4],li,aColunas[COL_COLUNA4],12,nDecimais,CtbSinalMov(),cPicture,iif(lIsRedStor,"1",""), , , , , ,lPrintZero,,,.F.)
			@ li,aColunas[COL_SEPARA7] PSAY "|"
			ValorCTB(aTotColC[5],li,aColunas[COL_COLUNA5],12,nDecimais,CtbSinalMov(),cPicture,iif(lIsRedStor,"1",""), , , , , ,lPrintZero,,,.F.)
			@ li,aColunas[COL_SEPARA8] PSAY "|"
			ValorCTB(aTotColC[6],li,aColunas[COL_COLUNA6],12,nDecimais,CtbSinalMov(),cPicture,iif(lIsRedStor,"1",""), , , , , ,lPrintZero,,,.F.)
			@ li,aColunas[COL_SEPARA9] PSAY "|"
			ValorCTB(aTotColC[7],li,aColunas[COL_COLUNA7],12,nDecimais,CtbSinalMov(),cPicture,iif(lIsRedStor,"1",""), , , , , ,lPrintZero,,,.F.)
			@ li,aColunas[COL_SEPARA10] PSAY "|"
			ValorCTB(aTotColC[8],li,aColunas[COL_COLUNA8],12,nDecimais,CtbSinalMov(),cPicture,iif(lIsRedStor,"1",""), , , , , ,lPrintZero,,,.F.)
			@ li,aColunas[COL_SEPARA11] PSAY "|"
			ValorCTB(aTotColC[9],li,aColunas[COL_COLUNA9],12,nDecimais,CtbSinalMov(),cPicture,iif(lIsRedStor,"1",""), , , , , ,lPrintZero,,,.F.)
			@ li,aColunas[COL_SEPARA12] PSAY "|"
			ValorCTB(aTotColC[10],li,aColunas[COL_COLUNA10],12,nDecimais,CtbSinalMov(),cPicture,iif(lIsRedStor,"1",""), , , , , ,lPrintZero,,,.F.)
			@ li,aColunas[COL_SEPARA13] PSAY "|"
			ValorCTB(aTotColC[11],li,aColunas[COL_COLUNA11],12,nDecimais,CtbSinalMov(),cPicture,iif(lIsRedStor,"1",""), , , , , ,lPrintZero,,,.F.)
			@ li,aColunas[COL_SEPARA14] PSAY "|"
			ValorCTB(aTotColC[12],li,aColunas[COL_COLUNA12],12,nDecimais,CtbSinalMov(),cPicture,iif(lIsRedStor,"1",""), , , , , ,lPrintZero,,,.F.)
		/// Total Geral da Coluna B
			@ li,aColunas[COL_SEPARA15]-19 PSAY "|"
			ValorCTB(nTotGeralC,li,aColunas[COL_SEPARA15]-18,12,nDecimais,.F.,cPicture,iif(lIsRedStor,"1","") , , , , , ,lPrintZero,,,.F.)
			@ li,aColunas[COL_SEPARA15] PSAY "|"
		EndIf
		
		li++
		@li,00 PSAY REPLICATE("-",limite)
	
		If li <= 60
			roda(cbcont,cbtxt,"M")
		EndIf
	EndIf

************************* FIM   DA  IMPRESSAO *************************

	Set Filter To

	If aReturn[5] = 1
		Set Printer To
		Commit
		Ourspool(wnrel)
	EndIf

	dbSelectArea("cArqTmp")
	Set Filter To
	dbCloseArea()
	Ferase(cArqTmp+GetDBExtension())
	If _oCTBR2951 <> Nil
		_oCTBR2951:Delete()
		_oCTBR2951 := Nil
	Endif

	If _oCTBR2952 <> Nil
		_oCTBR2952:Delete()
		_oCTBR2952 := Nil
	Endif

	dbselectArea("CT2")

	MS_FLUSH()

Return
/*/
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Gerar Arquivo TMP para Comparativos Saldo Mes a Mes (MAX 12)|±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T. / .F.                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpO1 = Objeto oMeter                                      ³±±
±±³          ³ ExpO2 = Objeto oText                                       ³±±
±±³          ³ ExpO3 = Objeto oDlg                                        ³±±
±±³          ³ ExpL1 = lEnd                                               ³±±
±±³          ³ ExpD1 = Data Inicial                                       ³±±
±±³          ³ ExpD2 = Data Final                                         ³±±
±±³          ³ ExpC1 = Alias do Arquivo                                   ³±±
±±³          ³ ExpC2 = Conta Inicial                                      ³±±
±±³          ³ ExpC3 = Conta Final                                        ³±±
±±³          ³ ExpC4 = Centro de Custo Inicial                            ³±±
±±³          ³ ExpC5 = Centro de Custo Final                              ³±±
±±³          ³ ExpC6 = Centro de Custo Inicial                            ³±±
±±³          ³ ExpC7 = Centro de Custo Final                              ³±±
±±³          ³ ExpC8 = Item Inicial                                       ³±±
±±³          ³ ExpC9 = Item Final                                         ³±±
±±³          ³ ExpC10= Classe de Valor Inicial                            ³±±
±±³          ³ ExpC11= Classe de Valor Final                              ³±±
±±³          ³ ExpC12= Moeda		                                      ³±±
±±³          ³ ExpC13= Saldo	                                          ³±±
±±³          ³ ExpA1 = Set Of Book	                                      ³±±
±±³          ³ ExpC13= Ate qual segmento sera impresso (nivel)			  ³±±
±±³          ³ ExpC8 = Filtra por Segmento		                          ³±±
±±³          ³ ExpC9 = Segmento Inicial		                              ³±±
±±³          ³ ExpC10= Segmento Final  		                              ³±±
±±³          ³ ExpC11= Segmento Contido em  	                          ³±±
±±³          ³ ExpL2 = Se Imprime Entidade sem movimento                  ³±±
±±³          ³ ExpL3 = Se Imprime Conta                                   ³±±
±±³          ³ ExpN1 = Grupo                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function xCtCmpSldM( oMeter,oText,oDlg,lEnd,cArqtmp,;
		dDataIni,dDataFim,cAlias,cEntid,;
		cContaIni,cContaFim,cCCIni,cCCFim,cItemIni,cItemFim,cClvlIni,cClVlFim,;
		cMoeda,cSaldoA,cSaldoB,aSetOfBook,lAcum,lImpAntLP,dDataLP,;
		nDivide,cTpVlr,aMeses,lVlrZerado,cString,cFilUSU,aOrdem)
						
	Local aTamConta		:= TAMSX3("CT1_CONTA")
	Local aTamCtaRes	:= TAMSX3("CT1_RES")
	Local aTamCC        := TAMSX3("CTT_CUSTO")
	Local aTamCCRes 	:= TAMSX3("CTT_RES")
	Local aTamItem  	:= TAMSX3("CTD_ITEM")
	Local aTamItRes 	:= TAMSX3("CTD_RES")
	Local aTamClVl  	:= TAMSX3("CTH_CLVL")
	Local aTamCvRes 	:= TAMSX3("CTH_RES")
	Local aCtbMoeda		:= {}
	Local aSaveArea 	:= GetArea()
	Local aCampos
	Local aSaldoAnt
	Local aSaldoAtu
	Local aChave        := {}
	Local nTamCta 		:= Len(CriaVar("CT1_DESC"+cMoeda))
	Local nTamItem		:= Len(CriaVar("CTD_DESC"+cMoeda))
	Local nTamCC  		:= Len(CriaVar("CTT_DESC"+cMoeda))
	Local nTamClVl		:= Len(CriaVar("CTH_DESC"+cMoeda))
	Local nTamGrupo		:= Len(CriaVar("CT1_GRUPO"))
	Local nDecimais		:= 0
	Local cEntidIni		:= ""
	Local cEntidFim		:= ""
	Local cEntidIni1	:= ""
	Local cEntidFim1	:= ""
	Local cEntidIni2	:= ""
	Local cEntidFim2	:= ""
	Local cArqTmp1		:= ""
	Local cMensagem		:= ""
	Local nMeter		:= 0
	Local lTemQry		:= .F.							/// SE UTILIZOU AS QUERYS PARA OBTER O SALDO DAS ANALITICAS
	Local nTRB			:= 1
	Local nCont			:= 0
	Local aStruTMP		:= {}
	Local cFilXAnt		:= ""
	Local nColunas	    := 0
	Local aTamVlr	 	:= TAMSX3("CT2_VALOR")
	Local aTamVal		:= TAMSX3("CT2_VALOR")
	Local nStr			:= 1
	Local cCampoQry     := ""
	Local cOrdQry     	:= ""
	Local lUsaCusto		:= (mv_par29 == 1)
	Local lUsaItem 		:= (mv_par30 == 1)
	Local lUsaClVl 		:= (mv_par31 == 1)
	Local cQuery
	Local lMeses      	:= .F.
	Local nMes
	Local lGravouTmp 	:= .F.
	Local cQuerySldA
	Local cQuerySldB
	Local cQuerySldC



	Local cSaldoC		:= Substr(cSaldoB,2,1)
	Local lSldC			:= !Empty(cSaldoC)
	Local lSldB			:= .F.
	Local lSldA			:= .F.

	Local nLenMeses		:= Len(aMeses)

	Private cPlanoRef	:= aSetOfBook[11]
	Private cVersao		:= aSetOfBook[12]

	cSaldoB				:= Substr(cSaldoB,1,1)
	lSldB				:= !Empty(cSaldoB)
	lSldA				:= !Empty(cSaldoA)
	cEntid		       	:= Iif(cEntid == Nil,'',cEntid)

	DEFAULT cMoeda		:= "01"		//// SE NAO FOR INFORMADA A MOEDA ASSUME O PADRAO 01
	DEFAULT lVlrZerado 	:= .F.
	DEFAULT lAcum		:= .F.
	DEFAULT cFILUSU	 	:= ".T."
	DEFAULT cString	 	:= ""
	DEFAULT aOrdem		:= {}

	If Empty(cFilUSU)
		cFilUSU := ".T."
	EndIf

// Retorna Decimais
	aCtbMoeda := CTbMoeda(cMoeda)
	nDecimais := aCtbMoeda[5]

	If !Empty(cPlanoRef) .And. !Empty(cVersao)
	//Se o relatório não possuir conta, o plano referencial e a versão serão desconsiderados.
	//Será considerado cód. config. livros em branco.
		Help("  ",1,"CTBNOPLREF",,STR0039,1,0) //"Plano referencial não disponível nesse relatório. O relatório será processado desconsiderando a configuração de livros."
		cPlanoRef		:= ""
		cVersao			:= ""
		aSetOfBook[1]	:= ""
	Endif


	aCampos := {	{ "CONTA"	   	, "C", aTamConta[1] 	, 0 },;  		// Codigo da Conta
	{ "CTASUP"		, "C", aTamConta[1] 	, 0 },;			// Codigo da Conta Superior
	{ "CTARES"		, "C", aTamCtaRes[1]	, 0 },;  		// Codigo Reduzido da Conta
	{ "DESCCTA"	   	, "C", nTamCta			, 0 },;  		// Descricao da Conta
	{ "NORMAL"		, "C", 01				, 0 },;			// Situacao da Conta
	{ "TIPOCONTA"	, "C", 01				, 0 },;			// Conta Analitica / Sintetica
	{ "CUSTO"		, "C", aTamCC[1]		, 0 },; 	 	// Codigo do Centro de Custo
	{ "CCSUP"		, "C", aTamCC[1]		, 0 },;			// Codigo do Centro de Custo Superior
	{ "CCRES"		, "C", aTamCCRes[1]		, 0 },;  		// Codigo Reduzido do Centro de Custo
	{ "DESCCC" 	   	, "C", nTamCC			, 0 },;  		// Descricao do Centro de Custo
	{ "TIPOCC"  	, "C", 01				, 0 },;			// Centro de Custo Analitico / Sintetico
	{ "ITEM"		, "C", aTamItem[1]		, 0 },; 	 	// Codigo do Item
	{ "ITSUP"		, "C", aTamItem[1]		, 0 },;			// Codigo do Item Superior
	{ "ITEMRES" 	, "C", aTamItRes[1]		, 0 },;  		// Codigo Reduzido do Item
	{ "DESCITEM" 	, "C", nTamItem			, 0 },;  		// Descricao do Item
	{ "TIPOITEM"	, "C", 01				, 0 },;			// Item Analitica / Sintetica
	{ "CLVL"		, "C", aTamClVl[1]		, 0 },; 	 	// Codigo da Classe de Valor
	{ "CLSUP"	   	, "C", aTamClVl[1] 		, 0 },;			// Codigo da Classe de Valor Superior
	{ "CLVLRES"	   	, "C", aTamCVRes[1]		, 0 },; 		// Cod. Red. Classe de Valor
	{ "DESCCLVL"   	, "C", nTamClVl			, 0 },;  		// Descricao da Classe de Valor
	{ "TIPOCLVL"	, "C", 01				, 0 },;			// Classe de Valor Analitica / Sintetica
	{ "ORDEM"		, "C", 10				, 0 },;			// Ordem
	{ "GRUPO"		, "C", nTamGrupo		, 0 },;			// Grupo Contabil
	{ "IDENTIFI"	, "C", 01				, 0 },;
		{ "ESTOUR"  	, "C", 01				, 0 },;			// Define se eh conta estourada
	{ "NIVEL1"		, "L", 01				, 0 }}			// Logico para identificar se eh de nivel 1 -> total do relatorio

	If lSldA
		aAdd(aCampos, { "COLA1"		, "N", aTamVal[1]+2, nDecimais} ) 	// Saldo A Periodo 1
		aAdd(aCampos, { "COLA2"   	, "N", aTamVal[1]+2, nDecimais} ) 	// Saldo A Periodo 2
		aAdd(aCampos, { "COLA3"   	, "N", aTamVal[1]+2, nDecimais} ) 	// Saldo A Periodo 3
		aAdd(aCampos, { "COLA4" 	, "N", aTamVal[1]+2, nDecimais} )  // Saldo A Periodo 4
		aAdd(aCampos, { "COLA5" 	, "N", aTamVal[1]+2, nDecimais} )  // Saldo A Periodo 5
		aAdd(aCampos, { "COLA6"  	, "N", aTamVal[1]+2, nDecimais} )  // Saldo A Periodo 6
		aAdd(aCampos, { "COLA7"		, "N", aTamVal[1]+2, nDecimais} ) 	// Saldo A Periodo 7
		aAdd(aCampos, { "COLA8"   	, "N", aTamVal[1]+2, nDecimais} ) 	// Saldo A Periodo 8
		aAdd(aCampos, { "COLA9"   	, "N", aTamVal[1]+2, nDecimais} ) 	// Saldo A Periodo 9
		aAdd(aCampos, { "COLA10" 	, "N", aTamVal[1]+2, nDecimais} )  // Saldo A Periodo 10
		aAdd(aCampos, { "COLA11" 	, "N", aTamVal[1]+2, nDecimais} )  // Saldo A Periodo 11
		aAdd(aCampos, { "COLA12"  	, "N", aTamVal[1]+2, nDecimais} )  // Saldo A Periodo 12
	EndIf
			   	
	If lSldB
		aAdd(aCampos, { "COLB1"		, "N", aTamVal[1]+2, nDecimais} )	// Saldo B Periodo 1
		aAdd(aCampos, { "COLB2"   	, "N", aTamVal[1]+2, nDecimais} ) 	// Saldo B Periodo 2
		aAdd(aCampos, { "COLB3"   	, "N", aTamVal[1]+2, nDecimais} ) 	// Saldo B Periodo 3
		aAdd(aCampos, { "COLB4" 	, "N", aTamVal[1]+2, nDecimais} )  // Saldo B Periodo 4
		aAdd(aCampos, { "COLB5" 	, "N", aTamVal[1]+2, nDecimais} )  // Saldo B Periodo 5
		aAdd(aCampos, { "COLB6"   	, "N", aTamVal[1]+2, nDecimais} )  // Saldo B Periodo 6
		aAdd(aCampos, { "COLB7"		, "N", aTamVal[1]+2, nDecimais} ) 	// Saldo B Periodo 7
		aAdd(aCampos, { "COLB8"   	, "N", aTamVal[1]+2, nDecimais} ) 	// Saldo B Periodo 8
		aAdd(aCampos, { "COLB9"   	, "N", aTamVal[1]+2, nDecimais} ) 	// Saldo B Periodo 9
		aAdd(aCampos, { "COLB10" 	, "N", aTamVal[1]+2, nDecimais} )  // Saldo B Periodo 10
		aAdd(aCampos, { "COLB11" 	, "N", aTamVal[1]+2, nDecimais} )  // Saldo B Periodo 11
		aAdd(aCampos, { "COLB12"  	, "N", aTamVal[1]+2, nDecimais} )  // Saldo B Periodo 12
	EndIf

	If lSldC
		aAdd(aCampos, { "COLC1"		, "N", aTamVal[1]+2, nDecimais} )	// Saldo C Periodo 1
		aAdd(aCampos, { "COLC2"   	, "N", aTamVal[1]+2, nDecimais} ) 	// Saldo C Periodo 2
		aAdd(aCampos, { "COLC3"   	, "N", aTamVal[1]+2, nDecimais} ) 	// Saldo C Periodo 3
		aAdd(aCampos, { "COLC4" 	, "N", aTamVal[1]+2, nDecimais} )  // Saldo C Periodo 4
		aAdd(aCampos, { "COLC5" 	, "N", aTamVal[1]+2, nDecimais} )  // Saldo C Periodo 5
		aAdd(aCampos, { "COLC6"   	, "N", aTamVal[1]+2, nDecimais} )  // Saldo C Periodo 6
		aAdd(aCampos, { "COLC7"		, "N", aTamVal[1]+2, nDecimais} ) 	// Saldo C Periodo 7
		aAdd(aCampos, { "COLC8"   	, "N", aTamVal[1]+2, nDecimais} ) 	// Saldo C Periodo 8
		aAdd(aCampos, { "COLC9"   	, "N", aTamVal[1]+2, nDecimais} ) 	// Saldo C Periodo 9
		aAdd(aCampos, { "COLC10" 	, "N", aTamVal[1]+2, nDecimais} )  // Saldo C Periodo 10
		aAdd(aCampos, { "COLC11" 	, "N", aTamVal[1]+2, nDecimais} )  // Saldo C Periodo 11
		aAdd(aCampos, { "COLC12"  	, "N", aTamVal[1]+2, nDecimais} )  // Saldo C Periodo 12
	EndIf
                                                        
///// TRATAMENTO PARA ATUALIZAÇÃO DE SALDO BASE
	If lSldA
		CTR295Sld(cMoeda,cSaldoA,cAlias,cEntid,dDataIni,dDataFim)
	EndIf
	If lSldB
		CTR295Sld(cMoeda,cSaldoB,cAlias,cEntid,dDataIni,dDataFim)
	EndIf
	If lSldC
		CTR295Sld(cMoeda,cSaldoC,cAlias,cEntid,dDataIni,dDataFim)
	EndIf

/// TRATAMENTO PARA OBTENÇÃO DO SALDO DAS CONTAS ANALITICAS
	Do Case
	Case cAlias == "CT7"
		aChave	:= {"CONTA"}
		#IFDEF TOP
			If TcSrvType() <> "AS/400"
				cCampUSU  := ""										//// DECLARA VARIAVEL COM OS CAMPOS DO FILTRO DE USUÁRIO
				If cFilUSU <> ".T." .and. !Empty(cString)		//// SE O FILTRO DE USUÁRIO NAO ESTIVER VAZIO
					aStrSTRU := (cString)->(dbStruct())			//// OBTEM A ESTRUTURA DA TABELA USADA NA FILTRAGEM
					nStruLen := Len(aStrSTRU)
					For nStr := 1 to nStruLen                 //// LE A ESTRUTURA DA TABELA
						cCampUSU += aStrSTRU[nStr][1]+","		//// ADICIONANDO OS CAMPOS PARA FILTRAGEM POSTERIOR
					Next
				Endif
			
				cQuery := "SELECT DISTINCT CT1_CONTA CONTA, CT1_RES CTARES, CT1_DESC"+cMoeda+" DESCCTA, CT1_CLASSE TIPOCONTA, CT1_CTASUP CTASUP, "
				cQuery += cCampUSU									//// ADICIONA OS CAMPOS NA QUERY

				If lSldA
					cQuery += CtQryComp("CT1",nLenMeses,cMoeda,cSaldoA,lAcum,aMeses,lImpAntLP,dDataLP,"COLA")
				EndIf
				If lSldB
					If lSldA
						cQuery += ", "
					EndIf
					cQuery += CtQryComp("CT1",nLenMeses,cMoeda,cSaldoB,lAcum,aMeses,lImpAntLP,dDataLP,"COLB")
				EndIf
				If lSldC
					If lSldA .or. lSldB
						cQuery += ", "
					EndIf
					cQuery += CtQryComp("CT1",nLenMeses,cMoeda,cSaldoC,lAcum,aMeses,lImpAntLP,dDataLP,"COLC")
				EndIf

				cQuery += " FROM "+RetSqlName("CT1")+" ARQ "

			// por Icaro Queiroz em 01 de setembro de 2015
				cQuery += " WHERE ARQ.CT1_FILIAL in(' ',"

				For nX := 1 To Len( aSelFil )
					If nX == Len( aSelFil )
						cQuery += "'" + aSelFil[nX] + "'"
					Else
						cQuery += "'" + aSelFil[nX] + "',"
					EndIf
				Next nX
	
				cQuery += " )"
				nX	:= 0

			//cQuery += " WHERE ARQ.CT1_FILIAL = '"+xFilial("CT1")+"'  	"
				cQuery += " AND ARQ.CT1_CONTA BETWEEN '"+cContaIni+"' AND '"+cContaFim+"' "
				cQuery += " AND ARQ.CT1_CLASSE = '2'  	"
	
				If !Empty(aSetOfBook[1])
					cQuery += " AND ARQ.CT1_BOOK LIKE '%"+aSetOfBook[1]+"%' 	"
				Endif
	
				cQuery += " AND ARQ.D_E_L_E_T_ = ''  	"
	
				If !lVlrZerado
					cQuery += " AND ( "
					If lSldA
						cQuery += CtQryComp("CT1",nLenMeses,cMoeda,cSaldoA,lAcum,aMeses,lImpAntLP,dDataLP," <> 0 ")
					EndIf
					If lSldB
						If lSldA
							cQuery += " OR "
						EndIf
						cQuery += CtQryComp("CT1",nLenMeses,cMoeda,cSaldoB,lAcum,aMeses,lImpAntLP,dDataLP," <> 0 ")
					EndIf
					If lSldC
						If lSldA .or. lSldB
							cQuery += " OR "
						EndIf
						cQuery += CtQryComp("CT1",nLenMeses,cMoeda,cSaldoC,lAcum,aMeses,lImpAntLP,dDataLP," <> 0 ")
					EndIf
					cQuery += " ) "
				EndIf
					                     
			Else
			#ENDIF
		//// MONTAGEM DO TMP EM CODEBASE   
			#IFDEF TOP
			EndIf
		#ENDIF
	
	Case cAlias == "CT3"
		aChave	:= {"CONTA","CUSTO"}
		#IFDEF TOP
			If TcSrvType() <> "AS/400"
				cCampUSU  := ""										//// DECLARA VARIAVEL COM OS CAMPOS DO FILTRO DE USUÁRIO
				If cFilUSU <> ".T." .and. !Empty(cString)		//// SE O FILTRO DE USUÁRIO NAO ESTIVER VAZIO
					aStrSTRU := (cString)->(dbStruct())			//// OBTEM A ESTRUTURA DA TABELA USADA NA FILTRAGEM
					nStruLen := Len(aStrSTRU)
					For nStr := 1 to nStruLen                 //// LE A ESTRUTURA DA TABELA
						cCampUSU += aStrSTRU[nStr][1]+","		//// ADICIONANDO OS CAMPOS PARA FILTRAGEM POSTERIOR
					Next
				Endif
			
				cQuery := "SELECT DISTINCT CT1_CONTA CONTA, CT1_RES CTARES, CT1_DESC"+cMoeda+" DESCCTA, CT1_CLASSE TIPOCONTA, CT1_CTASUP CTASUP, "
				cQuery += " 	  CTT_CUSTO CUSTO,  CTT_RES CCRES, "
			//cQuery += " 	  CTT_CUSTO CUSTO,  CTT_RES CCRES, CTT_DESC"+cMoeda+" DESCCC, CTT_CLASSE TIPOCC, CTT_CCSUP CCSUP, "
				cQuery += cCampUSU									//// ADICIONA OS CAMPOS NA QUERY
	
				If lSldA
					cQuery += CtQryComp("CTT",nLenMeses,cMoeda,cSaldoA,lAcum,aMeses,lImpAntLP,dDataLP,"COLA")
				EndIf
				If lSldB
					If lSldA
						cQuery += ", "
					EndIf
					cQuery += CtQryComp("CTT",nLenMeses,cMoeda,cSaldoB,lAcum,aMeses,lImpAntLP,dDataLP,"COLB")
				EndIf
				If lSldC
					If lSldA .or. lSldB
						cQuery += ", "
					EndIf
					cQuery += CtQryComp("CTT",nLenMeses,cMoeda,cSaldoC,lAcum,aMeses,lImpAntLP,dDataLP,"COLC")
				EndIf
	
				cQuery += " FROM "+RetSqlName("CT1")+" ARQ, "+RetSqlName("CTT")+" ARQ2 "

			// por Icaro Queiroz em 01 de setembro de 2015
				cQuery += " WHERE ARQ2.CTT_FILIAL IN(' ',"

				For nX := 1 To Len( aSelFil )
					If nX == Len( aSelFil )
						cQuery += "'" + aSelFil[nX] + "'"
					Else
						cQuery += "'" + aSelFil[nX] + "',"
					EndIf
				Next nX
	
				cQuery += " )"
				nX	:= 0
			
			//cQuery += " WHERE ARQ2.CTT_FILIAL = '"+xFilial("CTT")+"'  	"
				cQuery += " AND ARQ2.CTT_CUSTO BETWEEN '"+cCCIni+"' AND '"+cCCFim+"' "
				cQuery += " AND ARQ2.CTT_CLASSE = '2'  	"
	
				If !Empty(aSetOfBook[1])
					cQuery += " AND ARQ2.CTT_BOOK LIKE '%"+aSetOfBook[1]+"%' 	"
				Endif

			// por Icaro Queiroz em 01 de setembro de 2015
				cQuery += " AND ARQ.CT1_FILIAL in(' ',"

				For nX := 1 To Len( aSelFil )
					If nX == Len( aSelFil )
						cQuery += "'" + aSelFil[nX] + "'"
					Else
						cQuery += "'" + aSelFil[nX] + "',"
					EndIf
				Next nX
	
				cQuery += " )"
				nX	:= 0
	

			//cQuery += " AND ARQ.CT1_FILIAL = '"+xFilial("CT1")+"'  	"
				cQuery += " AND ARQ.CT1_CONTA BETWEEN '"+cContaIni+"' AND '"+cContaFim+"'  	"
				cQuery += " AND ARQ.CT1_CLASSE = '2'  	"
	
				If !Empty(aSetOfBook[1])
					cQuery += " AND ARQ.CT1_BOOK LIKE '%"+aSetOfBook[1]+"%' "
				Endif
			
				cQuery += " AND ARQ.D_E_L_E_T_ = ''  	"
				cQuery += " AND ARQ2.D_E_L_E_T_ = ''  	"
			
				If !lVlrZerado
					cQuery += " AND ( "
					If lSldA
						cQuery += CtQryComp("CTT",nLenMeses,cMoeda,cSaldoA,lAcum,aMeses,lImpAntLP,dDataLP," <> 0 ")
					EndIf
					If lSldB
						If lSldA
							cQuery += " OR "
						EndIf
						cQuery += CtQryComp("CTT",nLenMeses,cMoeda,cSaldoB,lAcum,aMeses,lImpAntLP,dDataLP," <> 0 ")
					EndIf
					If lSldC
						If lSldA .or. lSldB
							cQuery += " OR "
						EndIf
						cQuery += CtQryComp("CTT",nLenMeses,cMoeda,cSaldoC,lAcum,aMeses,lImpAntLP,dDataLP," <> 0 ")
					EndIf
					cQuery += " ) "
				EndIf
			
			Else
			#ENDIF
		//// MONTAGEM DO TMP EM CODEBASE   
			#IFDEF TOP
			EndIf
		#ENDIF
	
	Case cAlias == "CT4"

		If lUsaCusto
			aChave := {"CONTA","CUSTO","ITEM"}
		Else
			aChave := {"CONTA","ITEM"}
		EndIf
		#IFDEF TOP
			If TcSrvType() <> "AS/400"
				cCampUSU  := ""										//// DECLARA VARIAVEL COM OS CAMPOS DO FILTRO DE USUÁRIO
				If cFilUSU <> ".T." .and. !Empty(cString)		//// SE O FILTRO DE USUÁRIO NAO ESTIVER VAZIO
					aStrSTRU := (cString)->(dbStruct())			//// OBTEM A ESTRUTURA DA TABELA USADA NA FILTRAGEM
					nStruLen := Len(aStrSTRU)
					For nStr := 1 to nStruLen                 //// LE A ESTRUTURA DA TABELA
						cCampUSU += aStrSTRU[nStr][1]+","		//// ADICIONANDO OS CAMPOS PARA FILTRAGEM POSTERIOR
					Next
				Endif
			
				cQuery := "SELECT DISTINCT CT1_CONTA CONTA, CT1_RES CTARES, CT1_DESC"+cMoeda+" DESCCTA, CT1_CLASSE TIPOCONTA, CT1_CTASUP CTASUP, "
				If lUsaCusto
					cQuery += " 	  CTT_CUSTO CUSTO,  CTT_RES CCRES, "
				//cQuery += " 	  CTT_CUSTO CUSTO,  CTT_RES CCRES, CTT_DESC"+cMoeda+" DESCCC, CTT_CLASSE TIPOCC, CTT_CCSUP CCSUP, "
				EndIf
				cQuery += " 	  CTD_ITEM ITEM, CTD_RES ITEMRES, CTD_DESC"+cMoeda+" DESCITEM, CTD_CLASSE TIPOITEM, CTD_ITSUP ITSUP, "
				cQuery += cCampUSU									//// ADICIONA OS CAMPOS NA QUERY
	           
				If lSldA
					cQuery += CtQryComp("CTD",nLenMeses,cMoeda,cSaldoA,lAcum,aMeses,lImpAntLP,dDataLP,"COLA")
				EndIf
				If lSldB
					If lSldA
						cQuery += ", "
					EndIf
					cQuery += CtQryComp("CTD",nLenMeses,cMoeda,cSaldoB,lAcum,aMeses,lImpAntLP,dDataLP,"COLB")
				EndIf
				If lSldC
					If lSldA .or. lSldB
						cQuery += ", "
					EndIf
					cQuery += CtQryComp("CTD",nLenMeses,cMoeda,cSaldoC,lAcum,aMeses,lImpAntLP,dDataLP,"COLC")
				EndIf
            
				If lUsaCusto
					cQuery += " FROM "+RetSqlName("CT1")+" ARQ, "+RetSqlName("CTT")+" ARQ2, "+RetSqlName("CTD")+" ARQ3 "
				Else
					cQuery += " FROM "+RetSqlName("CT1")+" ARQ, "+RetSqlName("CTD")+" ARQ3 "
				EndIf
        
				cQuery += " WHERE "

				If lUsaCusto
				// por Icaro Queiroz em 01 de setembro de 2015
					cQuery += " ARQ2.CTT_FILIAL in(' ',"
	
					For nX := 1 To Len( aSelFil )
						If nX == Len( aSelFil )
							cQuery += "'" + aSelFil[nX] + "'"
						Else
							cQuery += "'" + aSelFil[nX] + "',"
						EndIf
					Next nX
		
					cQuery += " )"
					nX	:= 0
	

				//cQuery += "     ARQ2.CTT_FILIAL = '"+xFilial("CTT")+"'  	"
					cQuery += " AND ARQ2.CTT_CUSTO BETWEEN '"+cCCIni+"' AND '"+cCCFim+"' "
					cQuery += " AND ARQ2.CTT_CLASSE = '2' "
	
					If !Empty(aSetOfBook[1])
						cQuery += " AND ARQ2.CTT_BOOK LIKE '%"+aSetOfBook[1]+"%' 	"
					Endif
					cQuery += " AND "
				EndIf

			// por Icaro Queiroz em 01 de setembro de 2015
				cQuery += " ARQ.CT1_FILIAL in(' ',"

				For nX := 1 To Len( aSelFil )
					If nX == Len( aSelFil )
						cQuery += "'" + aSelFil[nX] + "'"
					Else
						cQuery += "'" + aSelFil[nX] + "',"
					EndIf
				Next nX
	
				cQuery += " )"
				nX	:= 0


			//cQuery += "     ARQ.CT1_FILIAL = '"+xFilial("CT1")+"'  	"
				cQuery += " AND ARQ.CT1_CONTA BETWEEN '"+cContaIni+"' AND '"+cContaFim+"'  	"
				cQuery += " AND ARQ.CT1_CLASSE = '2'  	"
	
				If !Empty(aSetOfBook[1])
					cQuery += " AND ARQ.CT1_BOOK LIKE '%"+aSetOfBook[1]+"%' "
				Endif
			

			// por Icaro Queiroz em 01 de setembro de 2015
				cQuery += " AND ARQ3.CTD_FILIAL in(' ',"

				For nX := 1 To Len( aSelFil )
					If nX == Len( aSelFil )
						cQuery += "'" + aSelFil[nX] + "'"
					Else
						cQuery += "'" + aSelFil[nX] + "',"
					EndIf
				Next nX
	
				cQuery += " )"
				nX	:= 0

			//cQuery += " AND ARQ3.CTD_FILIAL = '"+xFilial("CTD")+"'  	"
				cQuery += " AND ARQ3.CTD_ITEM BETWEEN '"+cItemIni+"' AND '"+cItemFim+"'  	"
				cQuery += " AND ARQ3.CTD_CLASSE = '2'  	"
	
				If !Empty(aSetOfBook[1])
					cQuery += " AND ARQ3.CTD_BOOK LIKE '%"+aSetOfBook[1]+"%' "
				Endif
	           
				If lUsaCusto
					cQuery += " AND ARQ2.D_E_L_E_T_ = ''  	"
				EndIf
				cQuery += " AND ARQ.D_E_L_E_T_ = ''  	"
				cQuery += " AND ARQ3.D_E_L_E_T_ = ''  	"
				
				If !lVlrZerado
					cQuery += " AND ( "
					If lSldA
						cQuery += CtQryComp("CTD",nLenMeses,cMoeda,cSaldoA,lAcum,aMeses,lImpAntLP,dDataLP," <> 0 ")
					EndIf
					If lSldB
						If lSldA
							cQuery += " OR "
						EndIf
						cQuery += CtQryComp("CTD",nLenMeses,cMoeda,cSaldoB,lAcum,aMeses,lImpAntLP,dDataLP," <> 0 ")
					EndIf
					If lSldC
						If lSldA .or. lSldB
							cQuery += " OR "
						EndIf
						cQuery += CtQryComp("CTD",nLenMeses,cMoeda,cSaldoC,lAcum,aMeses,lImpAntLP,dDataLP," <> 0 ")
					EndIf
					cQuery += " ) "
				EndIf
			
			Else
			#ENDIF
		//// MONTAGEM DO TMP EM CODEBASE   
			#IFDEF TOP
			EndIf
		#ENDIF

	Case cAlias == "CTI"
	
		aChave := {"CONTA"}
	
		If lUsaCusto ; AADD(aChave,"CUSTO") ; EndIf

			If lUsaItem  ; AADD(aChave,"ITEM")   ; EndIf
			
				AADD(aChave,"CLVL")
				#IFDEF TOP
					If TcSrvType() <> "AS/400"
						cCampUSU  := ""										//// DECLARA VARIAVEL COM OS CAMPOS DO FILTRO DE USUÁRIO
						If cFilUSU <> ".T." .and. !Empty(cString)		//// SE O FILTRO DE USUÁRIO NAO ESTIVER VAZIO
							aStrSTRU := (cString)->(dbStruct())			//// OBTEM A ESTRUTURA DA TABELA USADA NA FILTRAGEM
							nStruLen := Len(aStrSTRU)
							For nStr := 1 to nStruLen                 //// LE A ESTRUTURA DA TABELA
								cCampUSU += aStrSTRU[nStr][1]+","		//// ADICIONANDO OS CAMPOS PARA FILTRAGEM POSTERIOR
							Next
						Endif
			
						cQuery := "SELECT DISTINCT CT1_CONTA CONTA, CT1_RES CTARES, CT1_DESC"+cMoeda+" DESCCTA, CT1_CLASSE TIPOCONTA, CT1_CTASUP CTASUP, "
						If lUsaCusto
							cQuery += " 	  CTT_CUSTO CUSTO,  CTT_RES CCRES, "
				//cQuery += " 	  CTT_CUSTO CUSTO,  CTT_RES CCRES, CTT_DESC"+cMoeda+" DESCCC, CTT_CLASSE TIPOCC, CTT_CCSUP CCSUP, "
						EndIf
						If lUsaItem
							cQuery += " 	  CTD_ITEM ITEM, CTD_RES ITEMRES, CTD_DESC"+cMoeda+" DESCITEM, CTD_CLASSE TIPOITEM, CTD_ITSUP ITSUP, "
						EndIf
						cQuery += " 	  CTH_CLVL CLVL, CTH_RES CLVLRES, CTH_DESC"+cMoeda+" DESCCLVL, CTH_CLASSE TIPOCLVL, CTH_CLSUP CLSUP, "
						cQuery += cCampUSU									//// ADICIONA OS CAMPOS NA QUERY
	
						cQuerySldA :=""
						cQuerySldB :=""
						cQuerySldC :=""

						For nCont :=1 to nLenMeses
				
							If lSldA
								cQuerySldA += CtQryComp("CTH",nCont,cMoeda,cSaldoA,lAcum,aMeses,lImpAntLP,dDataLP,"COLA",nCont)
								If nCont !=	nLenMeses
									cQuerySldA +=", "
								End if
							EndIf
							If lSldB
								cQuerySldB += CtQryComp("CTH",nCont,cMoeda,cSaldoB,lAcum,aMeses,lImpAntLP,dDataLP,"COLB",nCont)
								If nCont !=	nLenMeses
									cQuerySldB +=", "
								End if
							EndIf
							If lSldC
								cQuerySldC += CtQryComp("CTH",nCont,cMoeda,cSaldoC,lAcum,aMeses,lImpAntLP,dDataLP,"COLC",nCont)
								If nCont !=	nLenMeses
									cQuerySldC +=", "
								End if
					
							EndIf
						Next
						cQuery +=cQuerySldA  + Iif(!Empty(cQuerySldB),", " + cQuerySldB,"")+ Iif(!Empty(cQuerySldC),", " + cQuerySldC,"")
            // ARQ  = Conta
		    // ARQ4 = Classe
						cQuery += " FROM "+RetSqlName("CT1")+" ARQ, "+RetSqlName("CTH")+" ARQ4 "
						If lUsaCusto
	    		// ARQ2 = C.Custo
							cQuery += ", "+RetSqlName("CTT")+" ARQ2 "
						EndIf
						If lUsaItem
				// ARQ3 = Item
							cQuery += ", "+RetSqlName("CTD")+" ARQ3 "
						EndIf
						cQuery += " WHERE "
						If lUsaCusto
				// por Icaro Queiroz em 01 de setembro de 2015
							cQuery += " ARQ2.CTT_FILIAL in(' ',"
	
							For nX := 1 To Len( aSelFil )
								If nX == Len( aSelFil )
									cQuery += "'" + aSelFil[nX] + "'"
								Else
									cQuery += "'" + aSelFil[nX] + "',"
								EndIf
							Next nX
		
							cQuery += " )"
							nX	:= 0

				//cQuery += "     ARQ2.CTT_FILIAL = '"+xFilial("CTT")+"'  	"
							cQuery += " AND ARQ2.CTT_CUSTO BETWEEN '"+cCCIni+"' AND '"+cCCFim+"' "
							cQuery += " AND ARQ2.CTT_CLASSE = '2'  	"
							If !Empty(aSetOfBook[1])
								cQuery += " AND ARQ2.CTT_BOOK LIKE '%"+aSetOfBook[1]+"%' 	"
							Endif
							cQuery += " AND "
						EndIf

			// por Icaro Queiroz em 01 de setembro de 2015
						cQuery += " ARQ.CT1_FILIAL in(' ',"

						For nX := 1 To Len( aSelFil )
							If nX == Len( aSelFil )
								cQuery += "'" + aSelFil[nX] + "'"
							Else
								cQuery += "'" + aSelFil[nX] + "',"
							EndIf
						Next nX
	
						cQuery += " )"
						nX	:= 0


			//cQuery += "     ARQ.CT1_FILIAL = '"+xFilial("CT1")+"'  	"
						cQuery += " AND ARQ.CT1_CONTA BETWEEN '"+cContaIni+"' AND '"+cContaFim+"'  	"
						cQuery += " AND ARQ.CT1_CLASSE = '2'  	"
						If !Empty(aSetOfBook[1])
							cQuery += " AND ARQ.CT1_BOOK LIKE '%"+aSetOfBook[1]+"%' "
						Endif
						If lUsaItem
				// por Icaro Queiroz em 01 de setembro de 2015
							cQuery += " AND ARQ3.CTD_FILIAL in(' ',"
	
							For nX := 1 To Len( aSelFil )
								If nX == Len( aSelFil )
									cQuery += "'" + aSelFil[nX] + "'"
								Else
									cQuery += "'" + aSelFil[nX] + "',"
								EndIf
							Next nX
		
							cQuery += " )"
							nX	:= 0
	

				//cQuery += " AND ARQ3.CTD_FILIAL = '"+xFilial("CTD")+"'  	"
							cQuery += " AND ARQ3.CTD_ITEM BETWEEN '"+cItemIni+"' AND '"+cItemFim+"'  	"
							cQuery += " AND ARQ3.CTD_CLASSE = '2'  	"
							If !Empty(aSetOfBook[1])
								cQuery += " AND ARQ3.CTD_BOOK LIKE '%"+aSetOfBook[1]+"%' "
							Endif
						EndIf

			// por Icaro Queiroz em 01 de setembro de 2015
						cQuery += " AND ARQ4.CTH_FILIAL in(' ',"

						For nX := 1 To Len( aSelFil )
							If nX == Len( aSelFil )
								cQuery += "'" + aSelFil[nX] + "'"
							Else
								cQuery += "'" + aSelFil[nX] + "',"
							EndIf
						Next nX
	
						cQuery += " )"
						nX	:= 0


			//cQuery += " AND ARQ4.CTH_FILIAL = '"+xFilial("CTH")+"'  	"
						cQuery += " AND ARQ4.CTH_CLVL BETWEEN '"+cClVlIni+"' AND '"+cClVlFim+"'  	"
						cQuery += " AND ARQ4.CTH_CLASSE = '2'  	"
						If !Empty(aSetOfBook[1])
							cQuery += " AND ARQ4.CTH_BOOK LIKE '%"+aSetOfBook[1]+"%' "
						Endif
						cQuery += " AND ARQ.D_E_L_E_T_ = ''  	"
						cQuery += " AND ARQ4.D_E_L_E_T_ = ''  	"
						If lUsaCusto
							cQuery += " AND ARQ2.D_E_L_E_T_ = ''  	"
						EndIf
						If lUsaItem
							cQuery += " AND ARQ3.D_E_L_E_T_ = ''  	"
						EndIf
						If !lVlrZerado
							cQuery += " AND ( "
							If lSldA
								cQuery += CtQryComp("CTH",nLenMeses,cMoeda,cSaldoA,lAcum,aMeses,lImpAntLP,dDataLP," <> 0 ",1,.T.)
							EndIf
							If lSldB
								If lSldA
									cQuery += " OR "
								EndIf
								cQuery += CtQryComp("CTH",nLenMeses,cMoeda,cSaldoB,lAcum,aMeses,lImpAntLP,dDataLP," <> 0 ",1,.T.)
							EndIf
							If lSldC
								If lSldA .or. lSldB
									cQuery += " OR "
								EndIf
								cQuery += CtQryComp("CTH",nLenMeses,cMoeda,cSaldoC,lAcum,aMeses,lImpAntLP,dDataLP," <> 0 ",1,.T.)
							EndIf
							cQuery += " ) "
						EndIf
						lPriVez := .T.
						GravaTmp(lPriVez,cAlias,cQuery,aMeses,aTamVlr,aChave,1,nLenMeses,aCampos,cArqTmp,nDivide,aSetOfBook,;
							oMeter,@nMeter,cFilUsu,aOrdem)
						lGravouTmp := .T.
					Else
					#ENDIF
		//// MONTAGEM DO TMP EM CODEBASE   
					#IFDEF TOP
					EndIf
				#ENDIF

			Case cAlias == "CTU"
         
	// Centro de Custo
				If cEntid == "CTT"
					cEntidIni	:= cCCIni
					cEntidFim	:= cCCFim
					cCampoQry   := "CTT_CUSTO CUSTO, CTT_RES CCRES, "
		//cCampoQry   := "CTT_CUSTO CUSTO, CTT_RES CCRES, CTT_DESC"+cMoeda+" DESCCC, CTT_CLASSE TIPOCC, CTT_CCSUP CCSUP, "
					cOrdQry		:= "CTT_CUSTO"
					aChave      := {"CUSTO"}
                     
	// Item Contabil
				ElseIf cEntid == "CTD"
					cEntidIni	:= cItemIni
					cEntidFim	:= cItemFim
					cCampoQry   := "CTD_ITEM ITEM, CTD_RES ITEMRES, CTD_DESC"+cMoeda+" DESCITEM, CTD_CLASSE TIPOITEM, CTD_ITSUP ITSUP, "
					cOrdQry		:= "CTD_ITEM"
					aChave      := {"ITEM"}
                   
	// Classe de Valor
				ElseIf cEntid == "CTH"
					cEntidIni	:= cClVlIni
					cEntidFim	:= cClVlFim
					cCampoQry   := "CTH_CLVL CLVL, CTH_RES CLVLRES, CTH_DESC"+cMoeda+" DESCCLVL, CTH_CLASSE TIPOCLVL, CTH_CLSUP CLSUP, "
					cOrdQry		:= "CTH_CLVL"
					aChave      := {"CLVL"}
				EndIf

				#IFDEF TOP
					If TcSrvType() <> "AS/400"
						cCampUSU  := ""										//// DECLARA VARIAVEL COM OS CAMPOS DO FILTRO DE USUÁRIO
						If cFilUSU <> ".T." .and. !Empty(cString)		//// SE O FILTRO DE USUÁRIO NAO ESTIVER VAZIO
							aStrSTRU := (cString)->(dbStruct())			//// OBTEM A ESTRUTURA DA TABELA USADA NA FILTRAGEM
							nStruLen := Len(aStrSTRU)
							For nStr := 1 to nStruLen                 //// LE A ESTRUTURA DA TABELA
								cCampUSU += aStrSTRU[nStr][1]+","		//// ADICIONANDO OS CAMPOS PARA FILTRAGEM POSTERIOR
							Next
						Endif
			
						cQuery := "SELECT DISTINCT " + cCampoQry
						cQuery += cCampUSU									//// ADICIONA OS CAMPOS NA QUERY
	
						If lSldA
							For nMes := 1 to nLenMeses
								cQuery += "  	(SELECT SUM(CTU_CREDIT) - SUM(CTU_DEBITO) "
								cQuery += " 		 	FROM "+RetSqlName("CTU")+" CTU "

					// por Icaro Queiroz em 01 de setembro de 2015
								cQuery += " WHERE CTU_FILIAL in(' ',"
		
								For nX := 1 To Len( aSelFil )
									If nX == Len( aSelFil )
										cQuery += "'" + aSelFil[nX] + "'"
									Else
										cQuery += "'" + aSelFil[nX] + "',"
									EndIf
								Next nX
			
								cQuery += " )"
								nX	:= 0
		

					//cQuery += "   			WHERE CTU_FILIAL = '"+xFilial("CTU")+"' "
								cQuery += "   			AND CTU_MOEDA = '"+cMoeda+"' "
								cQuery += "   			AND CTU_TPSALD = '"+cSaldoA+"' "
								cQuery += "   			AND CTU_IDENT = '"+cEntid+"' "
								cQuery += " 			AND CTU_CODIGO	= ARQ."+cOrdQry+" "
								If lAcum
									cQuery += "    			AND CTU_DATA <= '"+DTOS(aMeses[nMes,3])+"' "
								Else
									cQuery += "    			AND CTU_DATA BETWEEN '"+DTOS(aMeses[nMes,2])+"' AND '"+DTOS(aMeses[nMes,3])+"' "
								EndIf
								If lImpAntLP .and. dDataLP >= aMeses[nMes,2]
									cQuery += "	AND CTU_LP <> 'Z' "
								Endif
								cQuery += "   			AND CTU.D_E_L_E_T_ = '') COLA"+ALLTRIM(STR(nMes))
								If nMes < nLenMeses
									cQuery += ","
								Endif
							Next
						EndIf
						If lSldB
							If lSldA
								cQuery += ","
							EndIf
							For nMes := 1 to nLenMeses
								cQuery += "  	(SELECT SUM(CTU_CREDIT) - SUM(CTU_DEBITO) "
								cQuery += " 		 	FROM "+RetSqlName("CTU")+" CTU "

					// por Icaro Queiroz em 01 de setembro de 2015
								cQuery += " WHERE CTU_FILIAL in(' ',"
		
								For nX := 1 To Len( aSelFil )
									If nX == Len( aSelFil )
										cQuery += "'" + aSelFil[nX] + "'"
									Else
										cQuery += "'" + aSelFil[nX] + "',"
									EndIf
								Next nX
			
								cQuery += " )"
								nX	:= 0


					//cQuery += "   			WHERE CTU_FILIAL = '"+xFilial("CTU")+"' "
								cQuery += "   			AND CTU_MOEDA = '"+cMoeda+"' "
								cQuery += "   			AND CTU_TPSALD = '"+cSaldoB+"' "
								cQuery += "   			AND CTU_IDENT = '"+cEntid+"' "
								cQuery += " 			AND CTU_CODIGO	= ARQ."+cOrdQry+" "
								If lAcum
									cQuery += "    			AND CTU_DATA <= '"+DTOS(aMeses[nMes,3])+"' "
								Else
									cQuery += "    			AND CTU_DATA BETWEEN '"+DTOS(aMeses[nMes,2])+"' AND '"+DTOS(aMeses[nMes,3])+"' "
								EndIf
								If lImpAntLP .and. dDataLP >= aMeses[nMes,2]
									cQuery += "	AND CTU_LP <> 'Z' "
								Endif
								cQuery += "   			AND CTU.D_E_L_E_T_ = '') COLB"+ALLTRIM(STR(nMes))
								If nMes < nLenMeses
									cQuery += ","
								Endif
							Next
						EndIf
						If lSldC
							If lSldA .or. lSldB
								cQuery += ","
							EndIf
							For nMes := 1 to nLenMeses
								cQuery += "  	(SELECT SUM(CTU_CREDIT) - SUM(CTU_DEBITO) "
								cQuery += " 		 	FROM "+RetSqlName("CTU")+" CTU "

					// por Icaro Queiroz em 01 de setembro de 2015
								cQuery += " WHERE CTU_FILIAL in(' ',"
		
								For nX := 1 To Len( aSelFil )
									If nX == Len( aSelFil )
										cQuery += "'" + aSelFil[nX] + "'"
									Else
										cQuery += "'" + aSelFil[nX] + "',"
									EndIf
								Next nX
			
								cQuery += " )"
								nX	:= 0


					//cQuery += "   			WHERE CTU_FILIAL = '"+xFilial("CTU")+"' "
								cQuery += "   			AND CTU_MOEDA = '"+cMoeda+"' "
								cQuery += "   			AND CTU_TPSALD = '"+cSaldoC+"' "
								cQuery += "   			AND CTU_IDENT = '"+cEntid+"' "
								cQuery += " 			AND CTU_CODIGO	= ARQ."+cOrdQry+" "
								If lAcum
									cQuery += "    			AND CTU_DATA <= '"+DTOS(aMeses[nMes,3])+"' "
								Else
									cQuery += "    			AND CTU_DATA BETWEEN '"+DTOS(aMeses[nMes,2])+"' AND '"+DTOS(aMeses[nMes,3])+"' "
								EndIf
								If lImpAntLP .and. dDataLP >= aMeses[nMes,2]
									cQuery += "	AND CTU_LP <> 'Z' "
								Endif
								cQuery += "   			AND CTU.D_E_L_E_T_ = '') COLC"+ALLTRIM(STR(nMes))
								If nMes < nLenMeses
									cQuery += ","
								Endif
							Next
						EndIf
				
						cQuery += "	FROM "+RetSqlName(cEntid)+" ARQ "

			// por Icaro Queiroz em 01 de setembro de 2015
						cQuery += " WHERE ARQ."+cEntid+"_FILIAL in(' ',"

						For nX := 1 To Len( aSelFil )
							If nX == Len( aSelFil )
								cQuery += "'" + aSelFil[nX] + "'"
							Else
								cQuery += "'" + aSelFil[nX] + "',"
							EndIf
						Next nX
			
						cQuery += " )"
						nX	:= 0


			//cQuery += "	WHERE ARQ."+cEntid+"_FILIAL = '"+xFilial(cEntid)+"' "
						cQuery += "	AND ARQ."+cOrdQry+" BETWEEN '"+cEntidIni+"' AND '"+cEntidFim+"' "
						cQuery += "	AND ARQ."+cEntid+"_CLASSE = '2' "

						If !Empty(aSetOfBook[1])
							cQuery += " AND ARQ."+cEntid+"_BOOK LIKE '%"+aSetOfBook[1]+"%' 	"
						Endif

						cQuery += " AND ARQ.D_E_L_E_T_ = '' "
	
						If !lVlrZerado
							cQuery += " AND ( "
	        
							If lSldA
								For nMes := 1 to nLenMeses
									cQuery += "  	(SELECT ROUND(SUM(CTU_CREDIT),2) - ROUND(SUM(CTU_DEBITO),2) "
									cQuery += " 		 	FROM "+RetSqlName("CTU")+" CTU "

						// por Icaro Queiroz em 01 de setembro de 2015
									cQuery += " WHERE CTU_FILIAL in(' ',"
			
									For nX := 1 To Len( aSelFil )
										If nX == Len( aSelFil )
											cQuery += "'" + aSelFil[nX] + "'"
										Else
											cQuery += "'" + aSelFil[nX] + "',"
										EndIf
									Next nX
						
									cQuery += " )"
									nX	:= 0
			

						//cQuery += "   			WHERE CTU_FILIAL = '"+xFilial("CTU")+"' "
									cQuery += "   			AND CTU_MOEDA = '"+cMoeda+"' "
									cQuery += "   			AND CTU_TPSALD = '"+cSaldoA+"' "
									cQuery += "   			AND CTU_IDENT = '"+cEntid+"' "
									cQuery += " 			AND CTU_CODIGO	= ARQ."+cOrdQry+" "
									If lAcum
										cQuery += "    			AND CTU_DATA <= '"+DTOS(aMeses[nMes,3])+"' "
									Else
										cQuery += "    			AND CTU_DATA BETWEEN '"+DTOS(aMeses[nMes,2])+"' AND '"+DTOS(aMeses[nMes,3])+"' "
									EndIf
									If lImpAntLP .and. dDataLP >= aMeses[nMes,2]
										cQuery += "	AND CTU_LP <> 'Z' "
									Endif
									cQuery += "   			AND CTU.D_E_L_E_T_ = '') <> 0 "
									If nMes < nLenMeses
										cQuery += " OR "
									EndIf
								Next
							EndIf
							If lSldB
								If lSldA
									cQuery += " OR "
								EndIf
								For nMes := 1 to nLenMeses
									cQuery += "  	(SELECT ROUND(SUM(CTU_CREDIT),2) - ROUND(SUM(CTU_DEBITO),2) "
									cQuery += " 		 	FROM "+RetSqlName("CTU")+" CTU "

						// por Icaro Queiroz em 01 de setembro de 2015
									cQuery += " WHERE CTU_FILIAL in(' ',"
			
									For nX := 1 To Len( aSelFil )
										If nX == Len( aSelFil )
											cQuery += "'" + aSelFil[nX] + "'"
										Else
											cQuery += "'" + aSelFil[nX] + "',"
										EndIf
									Next nX
						
									cQuery += " )"
									nX	:= 0


						//cQuery += "   			WHERE CTU_FILIAL = '"+xFilial("CTU")+"' "
									cQuery += "   			AND CTU_MOEDA = '"+cMoeda+"' "
									cQuery += "   			AND CTU_TPSALD = '"+cSaldoB+"' "
									cQuery += "   			AND CTU_IDENT = '"+cEntid+"' "
									cQuery += " 			AND CTU_CODIGO	= ARQ."+cOrdQry+" "
									If lAcum
										cQuery += "    			AND CTU_DATA <= '"+DTOS(aMeses[nMes,3])+"' "
									Else
										cQuery += "    			AND CTU_DATA BETWEEN '"+DTOS(aMeses[nMes,2])+"' AND '"+DTOS(aMeses[nMes,3])+"' "
									EndIf
									If lImpAntLP .and. dDataLP >= aMeses[nMes,2]
										cQuery += "	AND CTU_LP <> 'Z' "
									Endif
									cQuery += "   			AND CTU.D_E_L_E_T_ = '') <> 0 "
									If nMes < nLenMeses
										cQuery += " OR "
									Endif
								Next
							EndIf
							If lSldC
								If lSldA .or. lSldB
									cQuery += " OR "
								EndIf
								For nMes := 1 to nLenMeses
									cQuery += "  	(SELECT ROUND(SUM(CTU_CREDIT),2) - ROUND(SUM(CTU_DEBITO),2) "
									cQuery += " 		 	FROM "+RetSqlName("CTU")+" CTU "

						// por Icaro Queiroz em 01 de setembro de 2015
									cQuery += " WHERE CTU_FILIAL in(' ',"
			
									For nX := 1 To Len( aSelFil )
										If nX == Len( aSelFil )
											cQuery += "'" + aSelFil[nX] + "'"
										Else
											cQuery += "'" + aSelFil[nX] + "',"
										EndIf
									Next nX
						
									cQuery += " )"
									nX	:= 0


						//cQuery += "   			WHERE CTU_FILIAL = '"+xFilial("CTU")+"' "
									cQuery += "   			AND CTU_MOEDA = '"+cMoeda+"' "
									cQuery += "   			AND CTU_TPSALD = '"+cSaldoC+"' "
									cQuery += "   			AND CTU_IDENT = '"+cEntid+"' "
									cQuery += " 			AND CTU_CODIGO	= ARQ."+cOrdQry+" "
									If lAcum
										cQuery += "    			AND CTU_DATA <= '"+DTOS(aMeses[nMes,3])+"' "
									Else
										cQuery += "    			AND CTU_DATA BETWEEN '"+DTOS(aMeses[nMes,2])+"' AND '"+DTOS(aMeses[nMes,3])+"' "
									EndIf
									If lImpAntLP .and. dDataLP >= aMeses[nMes,2]
										cQuery += "	AND CTU_LP <> 'Z' "
									Endif
									cQuery += "   			AND CTU.D_E_L_E_T_ = '') <> 0 "
									If nMes < nLenMeses
										cQuery += " OR "
									Endif
								Next
							EndIf
				
							cQuery += " ) "
						EndIf
			
					Else
					#ENDIF
		//// MONTAGEM DO TMP EM CODEBASE   
					#IFDEF TOP
					EndIf
				#ENDIF
	
			Case cAlias == "CTV"
	
				If !Empty(aSetOfBook[5])
					cMensagem	:= OemToAnsi(STR0002)// O plano gerencial ainda nao esta disponivel nesse relatorio.
					MsgInfo(cMensagem)
					RestArea(aSaveArea)
					Return
				Endif
              
				aChave      := {"CUSTO","ITEM"}
				cEntidIni1	:=	cCCIni
				cEntidFim1	:=	cCCFim
				cEntidIni2	:=	cItemIni
				cEntidFim2	:=	cItemFim

				#IFDEF TOP	//// MONTA A QUERY E O ARQUIVO TEMPORÁRIO TRBTMP JÁ COM OS SALDOS
					If TcSrvType() != "AS/400"
			
						cCampUSU  := ""										//// DECLARA VARIAVEL COM OS CAMPOS DO FILTRO DE USUÁRIO
						If cFilUSU <> ".T." .and. !Empty(cString)		//// SE O FILTRO DE USUÁRIO NAO ESTIVER VAZIO
							aStrSTRU := (cString)->(dbStruct())			//// OBTEM A ESTRUTURA DA TABELA USADA NA FILTRAGEM
							nStruLen := Len(aStrSTRU)
							For nStr := 1 to nStruLen                 //// LE A ESTRUTURA DA TABELA
								cCampUSU += aStrSTRU[nStr][1]+","		//// ADICIONANDO OS CAMPOS PARA FILTRAGEM POSTERIOR
							Next
						Endif

						cQuery := " SELECT CTT_CUSTO CUSTO, CTT_RES CCRES, "
			//cQuery := " SELECT CTT_CUSTO CUSTO, CTT_RES CCRES, CTT_DESC"+cMoeda+" DESCCC, CTT_CLASSE TIPOCC, CTT_CCSUP CCSUP, "	
						cQuery += " 	    CTD_ITEM ITEM, CTD_RES ITEMRES, CTD_DESC"+cMoeda+" DESCITEM, CTD_CLASSE TIPOITEM, CTD_ITSUP ITSUP, "
	        
						cQuery += cCampUSU									//// ADICIONA OS CAMPOS NA QUERY
	      
						If lSldA
							cQuery += CtQryComp("CTV",nLenMeses,cMoeda,cSaldoA,lAcum,aMeses,lImpAntLP,dDataLP,"COLA")
						EndIf
						If lSldB
							If lSldA
								cQuery += ", "
							EndIf
							cQuery += CtQryComp("CTV",nLenMeses,cMoeda,cSaldoB,lAcum,aMeses,lImpAntLP,dDataLP,"COLB")
						EndIf
						If lSldC
							If lSldA .or. lSldB
								cQuery += ", "
							EndIf
							cQuery += CtQryComp("CTV",nLenMeses,cMoeda,cSaldoC,lAcum,aMeses,lImpAntLP,dDataLP,"COLC")
						EndIf
	
						cQuery += " FROM "+RetSqlName("CTT")+" ARQ2, "+RetSqlName("CTD")+" ARQ3 "

			// por Icaro Queiroz em 01 de setembro de 2015
						cQuery += " WHERE ARQ2.CTT_FILIAL in(' ',"
			
						For nX := 1 To Len( aSelFil )
							If nX == Len( aSelFil )
								cQuery += "'" + aSelFil[nX] + "'"
							Else
								cQuery += "'" + aSelFil[nX] + "',"
							EndIf
						Next nX
						
						cQuery += " )"
						nX	:= 0

			//cQuery += " WHERE ARQ2.CTT_FILIAL = '"+xFilial("CTT")+"'  	"
						cQuery += " AND ARQ2.CTT_CUSTO BETWEEN '"+cCCIni+"' AND '"+cCCFim+"' "
						cQuery += " AND ARQ2.CTT_CLASSE = '2'  	"
	
						If !Empty(aSetOfBook[1])
							cQuery += " AND ARQ2.CTT_BOOK LIKE '%"+aSetOfBook[1]+"%' 	"
						Endif
	
			// por Icaro Queiroz em 01 de setembro de 2015
						cQuery += " AND ARQ3.CTD_FILIAL in(' ',"
			
						For nX := 1 To Len( aSelFil )
							If nX == Len( aSelFil )
								cQuery += "'" + aSelFil[nX] + "'"
							Else
								cQuery += "'" + aSelFil[nX] + "',"
							EndIf
						Next nX
						
						cQuery += " )"
						nX	:= 0


			//cQuery += " AND ARQ3.CTD_FILIAL = '"+xFilial("CTD")+"'  	"
						cQuery += " AND ARQ3.CTD_ITEM BETWEEN '"+cItemIni+"' AND '"+cItemFim+"'  	"
						cQuery += " AND ARQ3.CTD_CLASSE = '2'  	"
	
						If !Empty(aSetOfBook[1])
							cQuery += " AND ARQ3.CTD_BOOK LIKE '%"+aSetOfBook[1]+"%' "
						Endif
	
						cQuery += " AND ARQ2.D_E_L_E_T_ = ''  	"
						cQuery += " AND ARQ3.D_E_L_E_T_ = ''  	"
			
						If !lVlrZerado
							cQuery += " AND ( "
							If lSldA
								cQuery += CtQryComp("CTV",nLenMeses,cMoeda,cSaldoA,lAcum,aMeses,lImpAntLP,dDataLP," <> 0 ")
							EndIf
							If lSldB
								If lSldA
									cQuery += " OR "
								EndIf
								cQuery += CtQryComp("CTV",nLenMeses,cMoeda,cSaldoB,lAcum,aMeses,lImpAntLP,dDataLP," <> 0 ")
							EndIf
							If lSldC
								If lSldA .or. lSldB
									cQuery += " OR "
								EndIf
								cQuery += CtQryComp("CTV",nLenMeses,cMoeda,cSaldoC,lAcum,aMeses,lImpAntLP,dDataLP," <> 0 ")
							EndIf
							cQuery += " ) "
						EndIf
			
					Else
					#ENDIF
		//// MONTAGEM DO TMP EM CODEBASE   
					#IFDEF TOP
					EndIf
				#ENDIF

			Case cAlias == "CTW"
	
				If !Empty(aSetOfBook[5])
					cMensagem	:= OemToAnsi(STR0002)// O plano gerencial ainda nao esta disponivel nesse relatorio.
					MsgInfo(cMensagem)
					RestArea(aSaveArea)
					Return
				Endif

				aChave := {"CUSTO","CLVL"}

				#IFDEF TOP	//// MONTA A QUERY E O ARQUIVO TEMPORÁRIO TRBTMP JÁ COM OS SALDOS
					If TcSrvType() != "AS/400"
			
						cCampUSU  := ""										//// DECLARA VARIAVEL COM OS CAMPOS DO FILTRO DE USUÁRIO
						If cFilUSU <> ".T." .and. !Empty(cString)		//// SE O FILTRO DE USUÁRIO NAO ESTIVER VAZIO
							aStrSTRU := (cString)->(dbStruct())			//// OBTEM A ESTRUTURA DA TABELA USADA NA FILTRAGEM
							nStruLen := Len(aStrSTRU)
							For nStr := 1 to nStruLen                 //// LE A ESTRUTURA DA TABELA
								cCampUSU += aStrSTRU[nStr][1]+","		//// ADICIONANDO OS CAMPOS PARA FILTRAGEM POSTERIOR
							Next
						Endif

						cQuery := "SELECT DISTINCT CTT_CUSTO CUSTO, CTT_RES CCRES, "
			//cQuery := "SELECT DISTINCT CTT_CUSTO CUSTO, CTT_RES CCRES, CTT_DESC"+cMoeda+" DESCCC, CTT_CLASSE TIPOCC, CTT_CCSUP CCSUP, "	
						cQuery += "       CTH_CLVL CLVL, CTH_RES CLVLRES, CTH_DESC"+cMoeda+" DESCCLVL, CTH_CLASSE TIPOCLVL, CTH_CLSUP CLSUP, "
	        
						cQuery += cCampUSU									//// ADICIONA OS CAMPOS NA QUERY
				
						If lSldA
							cQuery += CtQryComp("CTW",nLenMeses,cMoeda,cSaldoA,lAcum,aMeses,lImpAntLP,dDataLP,"COLA")
						EndIf
						If lSldB
							If lSldA
								cQuery += ", "
							EndIf
							cQuery += CtQryComp("CTW",nLenMeses,cMoeda,cSaldoB,lAcum,aMeses,lImpAntLP,dDataLP,"COLB")
						EndIf
						If lSldC
							If lSldA .or. lSldB
								cQuery += ", "
							EndIf
							cQuery += CtQryComp("CTW",nLenMeses,cMoeda,cSaldoC,lAcum,aMeses,lImpAntLP,dDataLP,"COLC")
						EndIf
	
						cQuery += " FROM "+RetSqlName("CTT")+" ARQ2, "+RetSqlName("CTH")+" ARQ4 "

			// por Icaro Queiroz em 01 de setembro de 2015
						cQuery += " WHERE ARQ2.CTT_FILIAL in(' ',"
			
						For nX := 1 To Len( aSelFil )
							If nX == Len( aSelFil )
								cQuery += "'" + aSelFil[nX] + "'"
							Else
								cQuery += "'" + aSelFil[nX] + "',"
							EndIf
						Next nX
						
						cQuery += " )"
						nX	:= 0


			//cQuery += " WHERE ARQ2.CTT_FILIAL = '"+xFilial("CTT")+"'  	"
						cQuery += " AND ARQ2.CTT_CUSTO BETWEEN '"+cCCIni+"' AND '"+cCCFim+"' "
						cQuery += " AND ARQ2.CTT_CLASSE = '2'  	"
	
						If !Empty(aSetOfBook[1])
							cQuery += " AND ARQ2.CTT_BOOK LIKE '%"+aSetOfBook[1]+"%' 	"
						Endif
	
			// por Icaro Queiroz em 01 de setembro de 2015
						cQuery += " AND ARQ4.CTH_FILIAL in(' ',"
			
						For nX := 1 To Len( aSelFil )
							If nX == Len( aSelFil )
								cQuery += "'" + aSelFil[nX] + "'"
							Else
								cQuery += "'" + aSelFil[nX] + "',"
							EndIf
						Next nX
						
						cQuery += " )"
						nX	:= 0

			//cQuery += " AND ARQ4.CTH_FILIAL = '"+xFilial("CTH")+"'  	"
						cQuery += " AND ARQ4.CTH_CLVL BETWEEN '"+cClVlIni+"' AND '"+cClVlFim+"'  	"
						cQuery += " AND ARQ4.CTH_CLASSE = '2'  	"
	                          
						If !Empty(aSetOfBook[1])
							cQuery += " AND ARQ4.CTH_BOOK LIKE '%"+aSetOfBook[1]+"%' "
						Endif
	
						cQuery += " AND ARQ2.D_E_L_E_T_ = ''  	"
						cQuery += " AND ARQ4.D_E_L_E_T_ = ''  	"
		
						If !lVlrZerado
							cQuery += " AND ( "
							If lSldA
								cQuery += CtQryComp("CTW",nLenMeses,cMoeda,cSaldoA,lAcum,aMeses,lImpAntLP,dDataLP," <> 0 ")
							EndIf
							If lSldB
								If lSldA
									cQuery += " OR "
								EndIf
								cQuery += CtQryComp("CTW",nLenMeses,cMoeda,cSaldoB,lAcum,aMeses,lImpAntLP,dDataLP," <> 0 ")
							EndIf
							If lSldC
								If lSldA .or. lSldB
									cQuery += " OR "
								EndIf
								cQuery += CtQryComp("CTW",nLenMeses,cMoeda,cSaldoC,lAcum,aMeses,lImpAntLP,dDataLP," <> 0 ")
							EndIf
							cQuery += " ) "
						EndIf
			
					Else
					#ENDIF
		//// MONTAGEM DO TMP EM CODEBASE   
					#IFDEF TOP
					EndIf
				#ENDIF

			Case cAlias == "CTX"
	
				If !Empty(aSetOfBook[5])
					cMensagem	:= OemToAnsi(STR0002)// O plano gerencial ainda nao esta disponivel nesse relatorio.
					MsgInfo(cMensagem)
					RestArea(aSaveArea)
					Return
				Endif
              
				aChave := {"ITEM","CLVL"}

				#IFDEF TOP	//// MONTA A QUERY E O ARQUIVO TEMPORÁRIO TRBTMP JÁ COM OS SALDOS
					If TcSrvType() != "AS/400"
			
						cCampUSU  := ""										//// DECLARA VARIAVEL COM OS CAMPOS DO FILTRO DE USUÁRIO
						If cFilUSU <> ".T." .and. !Empty(cString)		//// SE O FILTRO DE USUÁRIO NAO ESTIVER VAZIO
							aStrSTRU := (cString)->(dbStruct())			//// OBTEM A ESTRUTURA DA TABELA USADA NA FILTRAGEM
							nStruLen := Len(aStrSTRU)
							For nStr := 1 to nStruLen                 //// LE A ESTRUTURA DA TABELA
								cCampUSU += aStrSTRU[nStr][1]+","		//// ADICIONANDO OS CAMPOS PARA FILTRAGEM POSTERIOR
							Next
						Endif

						cQuery := "SELECT DISTINCT CTD_ITEM ITEM, CTD_RES ITEMRES, CTD_DESC"+cMoeda+" DESCITEM, CTD_CLASSE TIPOITEM, CTD_ITSUP ITSUP, "
						cQuery += "       CTH_CLVL CLVL, CTH_RES CLVLRES, CTH_DESC"+cMoeda+" DESCCLVL, CTH_CLASSE TIPOCLVL, CTH_CLSUP CLSUP, "
	        
						cQuery += cCampUSU									//// ADICIONA OS CAMPOS NA QUERY
			
						If lSldA
							cQuery += CtQryComp("CTX",nLenMeses,cMoeda,cSaldoA,lAcum,aMeses,lImpAntLP,dDataLP,"COLA")
						EndIf
						If lSldB
							If lSldA
								cQuery += ", "
							EndIf
							cQuery += CtQryComp("CTX",nLenMeses,cMoeda,cSaldoB,lAcum,aMeses,lImpAntLP,dDataLP,"COLB")
						EndIf
						If lSldC
							If lSldA .or. lSldB
								cQuery += ", "
							EndIf
							cQuery += CtQryComp("CTX",nLenMeses,cMoeda,cSaldoC,lAcum,aMeses,lImpAntLP,dDataLP,"COLC")
						EndIf
	
						cQuery += " FROM "+RetSqlName("CTD")+" ARQ3, "+RetSqlName("CTH")+" ARQ4 "

			// por Icaro Queiroz em 01 de setembro de 2015
						cQuery += " WHERE ARQ3.CTD_FILIAL in(' ',"
			
						For nX := 1 To Len( aSelFil )
							If nX == Len( aSelFil )
								cQuery += "'" + aSelFil[nX] + "'"
							Else
								cQuery += "'" + aSelFil[nX] + "',"
							EndIf
						Next nX
						
						cQuery += " )"
						nX	:= 0

			//cQuery += " WHERE ARQ3.CTD_FILIAL = '"+xFilial("CTD")+"'  	"
						cQuery += " AND ARQ3.CTD_ITEM BETWEEN '"+cItemIni+"' AND '"+cItemFim+"'  	"
						cQuery += " AND ARQ3.CTD_CLASSE = '2'  	"
	
						If !Empty(aSetOfBook[1])
							cQuery += " AND ARQ3.CTD_BOOK LIKE '%"+aSetOfBook[1]+"%' "
						Endif
	
			// por Icaro Queiroz em 01 de setembro de 2015
						cQuery += " AND ARQ4.CTH_FILIAL in(' ',"
			
						For nX := 1 To Len( aSelFil )
							If nX == Len( aSelFil )
								cQuery += "'" + aSelFil[nX] + "'"
							Else
								cQuery += "'" + aSelFil[nX] + "',"
							EndIf
						Next nX
						
						cQuery += " )"
						nX	:= 0


			//cQuery += " AND ARQ4.CTH_FILIAL = '"+xFilial("CTH")+"'  	"
						cQuery += " AND ARQ4.CTH_CLVL BETWEEN '"+cClVlIni+"' AND '"+cClVlFim+"'  	"
						cQuery += " AND ARQ4.CTH_CLASSE = '2'  	"
	                          
						If !Empty(aSetOfBook[1])
							cQuery += " AND ARQ4.CTH_BOOK LIKE '%"+aSetOfBook[1]+"%' "
						Endif
	
						cQuery += " AND ARQ3.D_E_L_E_T_ = ''  	"
						cQuery += " AND ARQ4.D_E_L_E_T_ = ''  	"
		
						If !lVlrZerado
							cQuery += " AND ( "
							If lSldA
								cQuery += CtQryComp("CTX",nLenMeses,cMoeda,cSaldoA,lAcum,aMeses,lImpAntLP,dDataLP," <> 0 ")
							EndIf
							If lSldB
								If lSldA
									cQuery += " OR "
								EndIf
								cQuery += CtQryComp("CTX",nLenMeses,cMoeda,cSaldoB,lAcum,aMeses,lImpAntLP,dDataLP," <> 0 ")
							EndIf
							If lSldC
								If lSldA .or. lSldB
									cQuery += " OR "
								EndIf
								cQuery += CtQryComp("CTX",nLenMeses,cMoeda,cSaldoC,lAcum,aMeses,lImpAntLP,dDataLP," <> 0 ")
							EndIf
							cQuery += " ) "
						EndIf

					Else
					#ENDIF
		//// MONTAGEM DO TMP EM CODEBASE   
					#IFDEF TOP
					EndIf
				#ENDIF

			Case cAlias == "CTY"

				aChave := {"CUSTO","ITEM","CLVL"}

				#IFDEF TOP	//// MONTA A QUERY E O ARQUIVO TEMPORÁRIO TRBTMP JÁ COM OS SALDOS
					If TcSrvType() != "AS/400"
						cCampUSU  := ""										//// DECLARA VARIAVEL COM OS CAMPOS DO FILTRO DE USUÁRIO
						If cFilUSU <> ".T." .and. !Empty(cString)		//// SE O FILTRO DE USUÁRIO NAO ESTIVER VAZIO
							aStrSTRU := (cString)->(dbStruct())			//// OBTEM A ESTRUTURA DA TABELA USADA NA FILTRAGEM
							nStruLen := Len(aStrSTRU)
							For nStr := 1 to nStruLen                 //// LE A ESTRUTURA DA TABELA
								cCampUSU += aStrSTRU[nStr][1]+","		//// ADICIONANDO OS CAMPOS PARA FILTRAGEM POSTERIOR
							Next
						Endif
			
						cQuery := "SELECT DISTINCT CTH_CLVL CLVL, CTH_RES CLVLRES, CTH_DESC"+cMoeda+" DESCCLVL, CTH_CLASSE TIPOCLVL, CTH_CLSUP CLSUP, "
						cQuery += " 	  CTT_CUSTO CUSTO,  CTT_RES CCRES, "
			//cQuery += " 	  CTT_CUSTO CUSTO,  CTT_RES CCRES, CTT_DESC"+cMoeda+" DESCCC, CTT_CLASSE TIPOCC, CTT_CCSUP CCSUP, "
						cQuery += " 	  CTD_ITEM ITEM, CTD_RES ITEMRES, CTD_DESC"+cMoeda+" DESCITEM, CTD_CLASSE TIPOITEM, CTD_ITSUP ITSUP, "
						cQuery += cCampUSU									//// ADICIONA OS CAMPOS NA QUERY
				
						If lSldA
							cQuery += CtQryComp("CTY",nLenMeses,cMoeda,cSaldoA,lAcum,aMeses,lImpAntLP,dDataLP,"COLA")
						EndIf
						If lSldB
							If lSldA
								cQuery += ", "
							EndIf
							cQuery += CtQryComp("CTY",nLenMeses,cMoeda,cSaldoB,lAcum,aMeses,lImpAntLP,dDataLP,"COLB")
						EndIf
						If lSldC
							If lSldA .or. lSldB
								cQuery += ", "
							EndIf
							cQuery += CtQryComp("CTY",nLenMeses,cMoeda,cSaldoC,lAcum,aMeses,lImpAntLP,dDataLP,"COLC")
						EndIf
	
						cQuery += " FROM "+RetSqlName("CTH")+" ARQ4, "+RetSqlName("CTT")+" ARQ2, "+RetSqlName("CTD")+" ARQ3 "

			// por Icaro Queiroz em 01 de setembro de 2015
						cQuery += " WHERE ARQ2.CTT_FILIAL in(' ',"
			
						For nX := 1 To Len( aSelFil )
							If nX == Len( aSelFil )
								cQuery += "'" + aSelFil[nX] + "'"
							Else
								cQuery += "'" + aSelFil[nX] + "',"
							EndIf
						Next nX
						
						cQuery += " )"
						nX	:= 0


			//cQuery += " WHERE ARQ2.CTT_FILIAL = '"+xFilial("CTT")+"'  	"
						cQuery += " AND ARQ2.CTT_CUSTO BETWEEN '"+cCCIni+"' AND '"+cCCFim+"' "
						cQuery += " AND ARQ2.CTT_CLASSE = '2'  	"
	
						If !Empty(aSetOfBook[1])
							cQuery += " AND ARQ2.CTT_BOOK LIKE '%"+aSetOfBook[1]+"%' 	"
						Endif
	

			// por Icaro Queiroz em 01 de setembro de 2015
						cQuery += " AND ARQ3.CTD_FILIAL in(' ',"
			
						For nX := 1 To Len( aSelFil )
							If nX == Len( aSelFil )
								cQuery += "'" + aSelFil[nX] + "'"
							Else
								cQuery += "'" + aSelFil[nX] + "',"
							EndIf
						Next nX
						
						cQuery += " )"
						nX	:= 0

			//cQuery += " AND ARQ3.CTD_FILIAL = '"+xFilial("CTD")+"'  	"
						cQuery += " AND ARQ3.CTD_ITEM BETWEEN '"+cItemIni+"' AND '"+cItemFim+"'  	"
						cQuery += " AND ARQ3.CTD_CLASSE = '2'  	"
	
						If !Empty(aSetOfBook[1])
							cQuery += " AND ARQ3.CTD_BOOK LIKE '%"+aSetOfBook[1]+"%' "
						Endif
	
			// por Icaro Queiroz em 01 de setembro de 2015
						cQuery += " AND ARQ4.CTH_FILIAL in(' ',"
			
						For nX := 1 To Len( aSelFil )
							If nX == Len( aSelFil )
								cQuery += "'" + aSelFil[nX] + "'"
							Else
								cQuery += "'" + aSelFil[nX] + "',"
							EndIf
						Next nX
						
						cQuery += " )"
						nX	:= 0

			//cQuery += " AND ARQ4.CTH_FILIAL = '"+xFilial("CTH")+"'  	"
						cQuery += " AND ARQ4.CTH_CLVL BETWEEN '"+cClVlIni+"' AND '"+cClVlFim+"'  	"
						cQuery += " AND ARQ4.CTH_CLASSE = '2'  	"
	
						If !Empty(aSetOfBook[1])
							cQuery += " AND ARQ4.CTH_BOOK LIKE '%"+aSetOfBook[1]+"%' "
						Endif
	
						cQuery += " AND ARQ4.D_E_L_E_T_ = '' "
						cQuery += " AND ARQ2.D_E_L_E_T_ = '' "
						cQuery += " AND ARQ3.D_E_L_E_T_ = '' "
				
						If !lVlrZerado
							cQuery += " AND ( "
							If lSldA
								cQuery += CtQryComp("CTY",nLenMeses,cMoeda,cSaldoA,lAcum,aMeses,lImpAntLP,dDataLP," <> 0 ")
							EndIf
							If lSldB
								If lSldA
									cQuery += " OR "
								EndIf
								cQuery += CtQryComp("CTY",nLenMeses,cMoeda,cSaldoB,lAcum,aMeses,lImpAntLP,dDataLP," <> 0 ")
							EndIf
							If lSldC
								If lSldA .or. lSldB
									cQuery += " OR "
								EndIf
								cQuery += CtQryComp("CTY",nLenMeses,cMoeda,cSaldoC,lAcum,aMeses,lImpAntLP,dDataLP," <> 0 ")
							EndIf
							cQuery += " ) "
						EndIf

					Else
					#ENDIF

		//// MONTAGEM DO TMP EM CODEBASE   
					#IFDEF TOP
					EndIf
				#ENDIF

			EndCase

			If ! lGravouTmp
				If ! Empty( cQuery )
					cQuery := ChangeQuery(cQuery)
				
					If Select("TRBTMP") > 0
						dbSelectArea("TRBTMP")
						dbCloseArea()
					Endif
	
					dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TRBTMP",.T.,.F.)
	
					For nColunas := 1 to nLenMeses
						TcSetField("TRBTMP","COLA"+Str(nColunas,Iif(nColunas>9,2,1)),"N",aTamVlr[1],aTamVlr[2])
						TcSetField("TRBTMP","COLB"+Str(nColunas,Iif(nColunas>9,2,1)),"N",aTamVlr[1],aTamVlr[2])
						TcSetField("TRBTMP","COLC"+Str(nColunas,Iif(nColunas>9,2,1)),"N",aTamVlr[1],aTamVlr[2])
					Next
				EndIf
	
				If !Empty(aSetOfBook[5])				// Indica qual o Plano Gerencial Anexado
					aChave := {"CONTA"}
				Endif
			
				If !Empty(aOrdem)
					aChave := ACLONE(aOrdem)
				EndIf

				If ( Select ( "cArqTmp" ) <> 0 )
					dbSelectArea ( "cArqTmp" )
					dbCloseArea ()
				Endif

				If _oCTBR2951 <> Nil
					_oCTBR2951:Delete()
					_oCTBR2951 := Nil
				Endif
			
				_oCTBR2951 := FWTemporaryTable():New( "cArqTmp" )
				_oCTBR2951:SetFields(aCampos)
				_oCTBR2951:AddIndex("1", aChave)

				If !Empty(aSetOfBook[5])				// Indica qual o Plano Gerencial Anexado
					_oCTBR2951:AddIndex("2", {"ORDEM"})
				Endif
						
			//------------------
			//Criação da tabela temporaria
			//------------------
				_oCTBR2951:Create()
			
				dbSelectArea("cArqTmp")
			
				If  Empty(aSetOfBook[5])				/// SÓ HÁ QUERY SEM O PLANO GERENCIAL
				//// SE FOR DEFINIÇÃO TOP
					If Select("TRBTMP") > 0		/// E O ALIAS TRBTMP ESTIVER ABERTO (INDICANDO QUE A QUERY FOI EXECUTADA)
						dbSelectArea("TRBTMP")
						aStruTMP := dbStruct()			/// OBTEM A ESTRUTURA DO TMP
					
						dbSelectArea("TRBTMP")
						If ValType(oMeter) == "O"
							oMeter:SetTotal((cAlias)->(RecCount()))
							oMeter:Set(0)
						EndIf
						dbGoTop()						/// POSICIONA NO 1º REGISTRO DO TMP
					
						While TRBTMP->(!Eof())			/// REPLICA OS DADOS DA QUERY (TRBTMP) PARA P/ O TEMPORARIO EM DISCO
							If ValType(oMeter) == "O"
								nMeter++
								oMeter:Set(nMeter)
							EndIf
						
							If &("TRBTMP->("+cFILUSU+")")
								RecLock("cArqTMP",.T.)
								For nTRB := 1 to Len(aStruTMP)
									If Subs(aStruTmp[nTRB][1],1,4) $ "COLA/COLB/COLC" .And. nDivide > 1
										Field->&(aStruTMP[nTRB,1])	:= ((TRBTMP->&(aStruTMP[nTRB,1])))/ndivide
									Else
										Field->&(aStruTMP[nTRB,1]) := TRBTMP->&(aStruTMP[nTRB,1])
									EndIf
								Next
								cArqTMP->(MsUnlock())
							Endif
						
							TRBTMP->(dbSkip())
						Enddo
					
						dbSelectArea("TRBTMP")
						dbCloseArea()					/// FECHA O TRBTMP (RETORNADO DA QUERY)
						lTemQry := .T.
					Endif
				EndIf
	
				dbSelectArea("cArqTmp")
				dbSetOrder(1)
	
				If !Empty(aSetOfBook[5])				// Se houve Indicacao de Plano Gerencial Anexado
		// Monta Arquivo Lendo Plano Gerencial                                   
		// Neste caso a filtragem de entidades contabeis é desprezada!
		// Por enquanto a opcao de emitir o relatorio com Plano Gerencial ainda 
		// nao esta disponivel para esse relatorio. 
	   /*
		If cAlias $ "CT7"					// Se for Entidade x Conta
			CtbPlGerCm(oMeter,oText,oDlg,lEnd,dDataIni,dDataFim,cMoeda,aSetOfBook,;
						cAlias,cEntid,lImpAntLP,dDataLP,lVlrZerado,lFiliais,aFiliais,lMeses,aMeses,)
			dbSetOrder(2)
		Else
			cMensagem	:= OemToAnsi(STR0002)// O plano gerencial ainda nao esta disponivel nesse relatorio. 
			MsgInfo(cMensagem)	
		EndIf	
		*/
				Else
		/*
		If cAlias $ 'CT7/CTU'		//So Imprime Entidade                                
			#IFDEF TOP
				If TcSrvType() != "AS/400"
				Else		
			#ENDIF
				CtCmpSoEnt(oMeter,oText,oDlg,lEnd,dDataIni,dDataFim,cEntidIni,cEntidFim,cMoeda,;
				cSaldoA,aSetOfBook,cSegmento,cSegIni,cSegFim,cFiltSegm,lNImpMov,cAlias,cEntid,;
				lCusto,lItem,lClVl,lAtSldBase,lAtSldCmp,nInicio,nFinal,lImpAntLP,dDataLP,nDivide,;
				cTpVlr,lFiliais,aFiliais,lMeses,aMeses)
			#IFDEF TOP
				Endif
			#ENDIF		        
			
		ElseIf cAlias == "CT3"			
		
			If lMeses
				#IFNDEF TOP			
					/// SE FOR CODEBASE OU TOP SEM TER PASSADO PELAS QUERYS
					CtCmpComp(oMeter,oText,oDlg,lEnd,dDataIni,dDataFim,cEntidIni1,cEntidFim1,cEntidIni2,;
					cEntidFim2,,cMoeda,cSaldoA,aSetOfBook,cSegmento,cSegIni,cSegFim,cFiltSegm,;
					lNImpMov,cAlias,lCusto,lItem,lClVl,lAtSldBase,lAtSldCmp,nInicio,nFinal,;
					cFilDe,cFilAte,lImpAntLP,dDataLP,nDivide,cTpVlr,lFiliais,aFiliais,lMeses,aMeses,lVlrZerado)					
				#ELSE
					If TcSrvType() == "AS/400"
						CtCmpComp(oMeter,oText,oDlg,lEnd,dDataIni,dDataFim,cEntidIni1,cEntidFim1,cEntidIni2,;
						cEntidFim2,,cMoeda,cSaldoA,aSetOfBook,cSegmento,cSegIni,cSegFim,cFiltSegm,;
						lNImpMov,cAlias,lCusto,lItem,lClVl,lAtSldBase,lAtSldCmp,nInicio,nFinal,;
						cFilDe,cFilAte,lImpAntLP,dDataLP,nDivide,cTpVlr,lFiliais,aFiliais,lMeses,aMeses,lVlrZerado)					
					EndIf	
				#ENDIF        			
			EndIf	
					
		ElseIf cAlias $ "CTV/CTX"				//// SE FOR ENTIDADE x ITEM CONTABIL
				#IFNDEF TOP
					CtCmpEntid(oMeter,oText,oDlg,lEnd,dDataIni,dDataFim,cEntidIni1,cEntidFim1,;
					,cMoeda,cSaldoA,aSetOfBook,cSegmento,cSegIni,cSegFim,cFiltSegm,;
					cAlias,lCusto,lItem,lClVl,lAtSldBase,lAtSldCmp,nInicio,nFinal,;
					cFilDe,cFilAte,lImpAntLP,dDataLP,nDivide,cTpVlr,lVlrZerado,aEntid)							
				#ELSE
					If TcSrvType() == "AS/400"
						CtCmpEntid(oMeter,oText,oDlg,lEnd,dDataIni,dDataFim,cEntidIni1,cEntidFim1,;
						,cMoeda,cSaldoA,aSetOfBook,cSegmento,cSegIni,cSegFim,cFiltSegm,;
						cAlias,lCusto,lItem,lClVl,lAtSldBase,lAtSldCmp,nInicio,nFinal,;
						cFilDe,cFilAte,lImpAntLP,dDataLP,nDivide,cTpVlr,lVlrZerado,aEntid)				
					EndIf
				#ENDIF
				
				/// Relatórios Comparativo 2 Entidades s/ Conta
				#IFNDEF TOP 
					CtCmpComp(oMeter,oText,oDlg,lEnd,dDataIni,dDataFim,cEntidIni1,cEntidFim1,cEntidIni2,;
					cEntidFim2,,cMoeda,cSaldoA,aSetOfBook,cSegmento,cSegIni,cSegFim,cFiltSegm,;
					lNImpMov,cAlias,lCusto,lItem,lClVl,lAtSldBase,lAtSldCmp,nInicio,nFinal,;
					cFilDe,cFilAte,lImpAntLP,dDataLP,nDivide,cTpVlr,lFiliais,aFiliais,lMeses,aMeses,lVlrZerado)		
				#ELSE
					If TcSrvType() == "AS/400"
						CtCmpComp(oMeter,oText,oDlg,lEnd,dDataIni,dDataFim,cEntidIni1,cEntidFim1,cEntidIni2,;
						cEntidFim2,,cMoeda,cSaldoA,aSetOfBook,cSegmento,cSegIni,cSegFim,cFiltSegm,;
						lNImpMov,cAlias,lCusto,lItem,lClVl,lAtSldBase,lAtSldCmp,nInicio,nFinal,;
						cFilDe,cFilAte,lImpAntLP,dDataLP,nDivide,cTpVlr,lFiliais,aFiliais,lMeses,aMeses,lVlrZerado)						
					EndIf
				#ENDIF		
				
		Endif 
		*/
				EndIf
	
			EndIf
			RestArea(aSaveArea)

			Return cArqTmp


			/*/
			ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
			±±³Descri‡…o ³ Monta um trecho da query referente a tabela cAlias                |±±
			±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄ´±±
			±±³Retorno   ³ Caracter                                                          ³±±
			±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄ´±±
			±±³Parametros³                                                                   ³±±
			±±³          ³ cAlias     = Tabela sobre a qual a query sera montada             ³±±
			±±³          ³ nFim       = Qtd de meses do periodo                              ³±±
			±±³          ³ cMoeda     = Moeda                                                ³±±
			±±³          ³ cSaldo     = Saldo a considerar na montagem da query              ³±±
			±±³          ³ lAcum      = Se é movimento acumulado(.T.) ou por                 ³±±
			±±³          ³              periodo(.F.) (mv_par16)                              ³±±
			±±³          ³ aMeses     = Array com todos os meses do periodo                  ³±±
			±±³          ³ lImpAntLP  = Imprime movimento anterior a apuracao de LP          ³±±
			±±³          ³ dDataLP    = Data da apuracao de LP                               ³±±
			±±³          ³ cFinal     = Conteudo final da query                              ³±±
			±±³          ³ cRepet     = Conteudo a ser repetido a cada loop                  ³±±
			±±³          ³ nInicio    = Em qual periodo sera iniciada a contagem             ³±±
			±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
			±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
			ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
			/*/
		Static Function CtQryComp(cArqBase,nFim,cMoeda,cSaldo,lAcum,aMeses,lImpAntLP,dDataLP,cFinal,nInicio,lUnico)
                    
			Local nMes
			Local lUsaCusto
			Local lUsaItem
			Local cQuery   := ""
			Local cAlias := ""

			DEFAULT nInicio := 1
			DEFAULT lUnico := .F.

			If cArqBase == "CT1"
				dbSelectArea("CQ1")
				cAlias := "CQ1"
			ElseIf cArqBase == "CTT"
				dbSelectArea("CQ3")
				cAlias := "CQ3"
			ElseIf cArqBase == "CTD"
				dbSelectArea("CQ5")
				cAlias := "CQ5"
			ElseIf cArqBase == "CTH"
				dbSelectArea("CQ7")
				cAlias := "CQ7"
			ElseIf cArqBase == "CTU"
				dbSelectArea("CQ9")
				cAlias := "CQ9"
			ElseIf cArqBase == "CTV"// Custo+Item
				dbSelectArea("CQ5")
				cAlias := "CQ5"
			ElseIf cArqBase == "CTW"// Custo+Classe
				dbSelectArea("CQ7")
				cAlias := "CQ7"
			ElseIf cArqBase == "CTX"// Item+Classe
				dbSelectArea("CQ7")
				cAlias := "CQ7"
			ElseIf cArqBase == "CTY"  // Custo+Item+Classe
				dbSelectArea("CQ7")
				cAlias := "CQ7"
			EndIf

			If cAlias $ "CQ7/CQ5"  // CTD = Conta+Custo+Item  ou  Conta+Item
				lUsaCusto := (mv_par29 == 1)
				If cAlias == "CQ7"  // Conta+CCusto+Item+Cl.Valor  ou  Conta+CCusto+Cl.Valor  ou  Conta+Item+Cl.Valor  ou  Conta+Cl.Valor
					lUsaItem := (mv_par30 == 1)
				EndIf
			EndIf

// Tabelas:
// ARQ  -> CT1
// ARQ2 -> CTT
// ARQ3 -> CTD
// ARQ4 -> CTH       
			if (lUnico, nInicio:=nFim,)

				For nMes := nInicio to nFim
					cQuery += "  	(SELECT SUM("+cAlias+"_CREDIT) - SUM("+cAlias+"_DEBITO) "
					cQuery += " 		 	FROM "+RetSqlName(cAlias)+" "+cAlias

	// por Icaro Queiroz em 01 de setembro de 2015
					cQuery += " WHERE "+cAlias+"_FILIAL in(' ',"
			
					For nX := 1 To Len( aSelFil )
						If nX == Len( aSelFil )
							cQuery += "'" + aSelFil[nX] + "'"
						Else
							cQuery += "'" + aSelFil[nX] + "',"
						EndIf
					Next nX
				
					cQuery += " )"
					nX	:= 0


	//cQuery += "   			WHERE "+cAlias+"_FILIAL = '"+xFilial(cAlias)+"' "
					cQuery += "   			AND "+cAlias+"_MOEDA = '"+cMoeda+"' "
					cQuery += "   			AND "+cAlias+"_TPSALD = '"+cSaldo+"' "
   
					If cArqBase == "CT1"      // Conta
						cQuery += "  			AND CQ1_CONTA = ARQ.CT1_CONTA "

					ElseIf cArqBase == "CTT"   // Conta+Custo
						cQuery += "  			AND CQ3_CONTA = ARQ.CT1_CONTA "
						cQuery += "   			AND CQ3_CCUSTO = ARQ2.CTT_CUSTO "

					ElseIf cArqBase == "CTD"  // Conta+Custo+Item  ou  Conta+Item
						cQuery += "   			AND CQ5_ITEM = ARQ3.CTD_ITEM "
						If lUsaCusto
							cQuery += "   			AND CQ5_CCUSTO = ARQ2.CTT_CUSTO "
						EndIf
						cQuery += "  			AND CQ5_CONTA = ARQ.CT1_CONTA "

					ElseIf cArqBase == "CTH"  // Conta+CCusto+Item+Cl.Valor  ou  Conta+CCusto+Cl.Valor  ou  Conta+Item+Cl.Valor  ou  Conta+Cl.Valor
						cQuery += "   			AND CQ7_CLVL = ARQ4.CTH_CLVL "
						If lUsaItem
							cQuery += "   			AND CQ7_ITEM = ARQ3.CTD_ITEM "
						EndIf
						If lUsaCusto
							cQuery += "   			AND CQ7_CCUSTO = ARQ2.CTT_CUSTO "
						EndIf
						cQuery += "  			AND CQ7_CONTA = ARQ.CT1_CONTA "

					ElseIf cArqBase == "CTV"  // Custo+Item
						cQuery += "   			AND CQ5_CCUSTO = ARQ2.CTT_CUSTO "
						cQuery += "  			AND CQ5_ITEM = ARQ3.CTD_ITEM "

					ElseIf cArqBase == "CTW"  // Custo+Classe
						cQuery += "   			AND CQ7_CCUSTO = ARQ2.CTT_CUSTO "
						cQuery += "  			AND CQ7_CLVL = ARQ4.CTH_CLVL "

					ElseIf cArqBase == "CTX"  // Item+Classe
						cQuery += "  			AND CQ7_ITEM = ARQ3.CTD_ITEM "
						cQuery += "   			AND CQ7_CLVL = ARQ4.CTH_CLVL "

					ElseIf cArqBase == "CTY"  // Custo+Item+Classe
						cQuery += "   			AND CQ7_CCUSTO = ARQ2.CTT_CUSTO "
						cQuery += "   			AND CQ7_ITEM = ARQ3.CTD_ITEM "
						cQuery += "   			AND CQ7_CLVL = ARQ4.CTH_CLVL "
					EndIf
	
					If lAcum .and. (nMes == 1)
						cQuery += "   			AND "+cAlias+"_DATA <= '"+DTOS(aMeses[nMes,3])+"' "
					Else
						If lUnico
							cQuery += "   			AND "+cAlias+"_DATA BETWEEN '"+DTOS(aMeses[1,2])+"' AND '"+DTOS(aMeses[nMes,3])+"' "
						Else
							cQuery += "   			AND "+cAlias+"_DATA BETWEEN '"+DTOS(aMeses[nMes,2])+"' AND '"+DTOS(aMeses[nMes,3])+"' "
						EndIf
					EndIf
					If lImpAntLP .And. dDataLP >= aMeses[nMes,2]
						cQuery += "	AND "+cAlias+"_LP <> 'Z' "
					Endif

					cQuery += "   			AND "+cAlias+".D_E_L_E_T_ = ' ') "

					cQuery += cFinal			/// NOME DA COLUNA "COL" OU CLAUSULA WHERE "<> 0"

					If Left(cFinal,3) == "COL"
						cQuery += ALLTRIM(STR(nMes))
						If nMes < nFim
							cQuery += ", "
						EndIf
					Else
						If nMes < nFim
							cQuery += " OR "
						EndIf
					EndIf
				Next

				Return cQuery


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Descri‡…o ³ Grava arquivo temporario com dados da query. 					 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ FITCTR295      											  					 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ Nenhum       							  				  					 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso 		 ³ SIGACTB      							  				   				 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ lPriVez: Se for a primeira chamada (.T.), criar o temporario
±±           ³ cAlias : Alias da tabela que está sendo apurada
±±           ³ cQuery : Query a executar
±±           ³ aMeses : Array com os periodos
±±           ³ aTamVlr: Array com os dados de "CT7_DEBITO"  
±±           ³ aChave : Chave para o arquivo
±±           ³ nInicio: Periodo inicial
±±           ³ nFim	 : Periodo final
±±           ³ aCampos: Array com os campos do temporario
±±           ³ cArqTmp: Alias do arquivo temporario
±±           ³ nDivide: Fator de div.dos valores a serem impressos
±±           ³ aSetOfBook: Set Of Book
±±           ³ oMeter : Objeto oMeter
±±           ³ nMeter : Contador para alimentar a barra de progresso
±±           ³ cFilUsu: Filtro de Usuario
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
			Static Function GravaTmp(lPriVez,cAlias,cQuery,aMeses,aTamVlr,aChave,nInicio,nFim,aCampos,cArqTmp,nDivide,aSetOfBook,;
					oMeter,nMeter,cFilUsu,aOrdem)

				Local cArqTmp1		:= ""
				Local nTRB			:= 1
				Local aStruTMP		:= {}
				Local nColunas	   := 0

				If ! Empty( cQuery )
					cQuery := ChangeQuery(cQuery)
			
					If Select("TRBTMP") > 0
						dbSelectArea("TRBTMP")
						dbCloseArea()
					Endif

					dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TRBTMP",.T.,.F.)

					For nColunas := nInicio to nFim
						TcSetField("TRBTMP","COLA"+Str(nColunas,Iif(nColunas>9,2,1)),"N",aTamVlr[1],aTamVlr[2])
						TcSetField("TRBTMP","COLB"+Str(nColunas,Iif(nColunas>9,2,1)),"N",aTamVlr[1],aTamVlr[2])
					Next
				EndIf

				If !Empty(aSetOfBook[5])				// Indica qual o Plano Gerencial Anexado
					aChave := {"CONTA"}
				Endif
  
//
// Criar o temporario em Disco que recebera os dados da query, somente no primeiro periodo.
//
				If lPriVez

					If ( Select ("cArqTmp") <> 0 )
						dbSelectArea ("cArqTmp")
						dbCloseArea ()
					Endif
	
					If !Empty(aOrdem)
						aChave := ACLONE(aOrdem)
					EndIf

					If _oCTBR2952 <> Nil
						_oCTBR2952:Delete()
						_oCTBR2952 := Nil
					Endif
	
					_oCTBR2952 := FWTemporaryTable():New("cArqTmp")
					_oCTBR2952:SetFields(aCampos)
					_oCTBR2952:AddIndex("1", aChave)

					If !Empty(aSetOfBook[5])				// Indica qual o Plano Gerencial Anexado
						_oCTBR2952:AddIndex("2", {"ORDEM"})
					Endif
				
	//------------------
	//Criação da tabela temporaria
	//------------------
					_oCTBR2952:Create()

					dbSelectArea("cArqTmp")

				EndIf
  
				If Empty(aSetOfBook[5])				/// SÓ HÁ QUERY SEM O PLANO GERENCIAL
		//// SE FOR DEFINIÇÃO TOP 
					If Select("TRBTMP") > 0		/// E O ALIAS TRBTMP ESTIVER ABERTO (INDICANDO QUE A QUERY FOI EXECUTADA)
						dbSelectArea("TRBTMP")
						aStruTMP := dbStruct()			/// OBTEM A ESTRUTURA DO TMP
	
						dbSelectArea("TRBTMP")
						If ValType(oMeter) == "O"
							If lPriVez
								oMeter:SetTotal((cAlias)->(RecCount()))
								oMeter:Set(0)
							EndIf
						EndIf
						dbGoTop()						/// POSICIONA NO 1º REGISTRO DO TMP
	
						While TRBTMP->(!Eof())			/// REPLICA OS DADOS DA QUERY (TRBTMP) PARA P/ O TEMPORARIO EM DISCO
							If ValType(oMeter) == "O"
								nMeter++
								oMeter:Set(nMeter)
							EndIf

							If &("TRBTMP->("+cFILUSU+")")
								RecLock("cArqTMP",.T.)
								For nTRB := 1 to Len(aStruTMP)
									If Subs(aStruTmp[nTRB][1],1,4) $ "COLA/COLB" .And. nDivide > 1
										Field->&(aStruTMP[nTRB,1])	:= ((TRBTMP->&(aStruTMP[nTRB,1])))/ndivide
									Else
										Field->&(aStruTMP[nTRB,1]) := TRBTMP->&(aStruTMP[nTRB,1])
									EndIf
								Next
								cArqTMP->(MsUnlock())
							Endif

							TRBTMP->(dbSkip())
						Enddo

						dbSelectArea("TRBTMP")
						dbCloseArea()					/// FECHA O TRBTMP (RETORNADO DA QUERY)
					Endif
				EndIf

				dbSelectArea("cArqTmp")
				dbSetOrder(1)

				Return Nil



			Static Function VldOrdem(aRet)

				Local lOk	:= .T.
				Local nItATU:= 1
				LOcal nItV	:= 1

/// VERIFICA SE A MESMA ENTIDADE FOI INFORMADA EM MAIS DE UMA COLUNA DE ORDEM

				For nItATU := 1 to Len(aRet)
					cItATU := aRet[nItATU]
					For nItV := 1 to Len(aRet)
						If aRet[nITV] == cItATU .and. nITV <> nItATU
							MsgInfo(STR0036+alltrim(str(nITV))+" ("+aRet[nITV]+") " + STR0037 + " "+alltrim(str(nItATU))+" ("+aRet[nItATU]+"). ",STR0035)
							lOk := .F.
							Exit
						EndIf
					Next
					If !lOk
						Exit
					EndIf
				Next

				Return(lOk)


			Static Function CTR295Sld(cMoeda,cSaldo,cAlias,cEntid,dDataIni,dDataFim)

				Local nInicio		:= Val(cMoeda)
				Local nFinal		:= Val(cMoeda)
				Local cFilDe		:= xFilial(cAlias)
				Local cFilate		:= xFilial(cAlias)

				Local lCusto		:= CtbMovSaldo("CTT")//Define se utiliza C.Custo
				Local lItem 		:= CtbMovSaldo("CTD")//Define se utiliza Item
				Local lClVl			:= CtbMovSaldo("CTH")//Define se utiliza Cl.Valor

				Local nMin			:= 0
				Local nMax			:= 0

				Local lAtSldBase	:= Iif(GetMV("MV_ATUSAL") == "S",.T.,.F.)
				Local lAtSldCmp		:= Iif(GetMV("MV_SLDCOMP")== "S",.T.,.F.)

				Local cOrigem		:= ""
				Local dDataAnt		:= CTOD("  /  /  ")

				Local nCont			:= 0
				Local lFiliais	    := .F.

				dMinData := CTOD("")

///// TRATAMENTO PARA ATUALIZAÇÃO DE SALDO BASE
//Se os saldos basicos nao foram atualizados na dig. lancamentos
				If !lAtSldBase
					dIniRep := ctod("")
					If Need2Reproc(dDataFim,cMoeda,cSaldo,@dIniRep)
		//Chama Rotina de Atualizacao de Saldos Basicos.
						oProcess := MsNewProcess():New({|lEnd|	CTBA190(.T.,dIniRep,dDataFim,cFilAnt,cFilAnt,cSaldo,.T.,cMoeda) },"","",.F.)
						oProcess:Activate()
					EndIf
				Else
	//// TRATAMENTO PARA ATUALIZAÇÃO DE SALDOS COMPOSTOS ANTES DE EXECUTAR A QUERY DE FILTRAGEM
					Do Case
					Case cAlias == 'CTU'
	   //Verificar se tem algum saldo a ser atualizado
	   //Verificar se tem algum saldo a ser atualizado por entidade
						If cEntid == "CTT"
							cOrigem := 	'CT3'
						ElseIf cEntid == "CTD"
							cOrigem := 	'CT4'
						ElseIf cEntid == "CTH"
							cOrigem := 	'CTI'
						Else
							cOrigem := 	'CTI'
						Endif
						If lFiliais
							For nCont := 1 to Len(aFiliais)
								Ct360Data(cOrigem,'CTU',@dMinData,lCusto,lItem,cFilDe,cFilAte,cSaldo,cMoeda,cMoeda,,,,,,,,,,aFiliais[nCont],,aSelFil)
								If !Empty(dMinData)
									If nCont	== 1
										dDataAnt	:= dMinData
									Else
										If dMinData	< dDataAnt
											dDataAnt	:= dMinData
										EndIf
									EndIf
								EndIf
							Next
			//Menor data de todas as filiais		
							dMinData	:= dDataAnt
						Else
							Ct360Data(cOrigem,'CTU',@dMinData,lCusto,lItem,cFilDe,cFilAte,cSaldo,cMoeda,cMoeda,,,,,,,,,,cFilAnt,,aSelFil)
						EndIf
					Case cAlias == 'CTV'
						cOrigem := "CT4"
		//Verificar se tem algum saldo a ser atualizado
						Ct360Data(cOrigem,"CTV",@dMinData,lCusto,lItem,cFilDe,cFilAte,cSaldo,cMoeda,cMoeda,,,,,,,,,,cFilAnt,,aSelFil)
					Case cAlias == 'CTW'
						cOrigem := 'CTI'	/// HEADER POR CLASSE DE VALORES
		//Verificar se tem algum saldo a ser atualizado
						Ct360Data(cOrigem,"CTW",@dMinData,lCusto,lItem,cFilDe,cFilAte,cSaldo,cMoeda,cMoeda,,,,,,,,,,cFilAnt,,aSelFil)
					Case cAlias == 'CTX'
						cOrigem := 'CTI'
		//Verificar se tem algum saldo a ser atualizado
						Ct360Data(cOrigem,"CTX",@dMinData,lCusto,lItem,cFilDe,cFilAte,cSaldo,cMoeda,cMoeda,,,,,,,,,,cFilAnt,,aSelFil)
					EndCase
	
					DO CASE
					CASE cAlias$("CTU/CTV/CTW/CTX/CTY")
		//Se o parametro MV_SLDCOMP estiver com "S",isto e, se devera atualizar os saldos compost.
		//na emissao dos relatorios, verifica se tem algum registro desatualizado e atualiza as
		//tabelas de saldos compostos.
						If !Empty(dMinData)
							If lAtSldCmp	//Se atualiza saldos compostos
								If lFiliais
									cFilXAnt	:= cFilAnt
					
									For nCont := 1 to Len(aFiliais)
										cFilAnt	:= aFiliais[nCont]
										cFilDe	:= cFilAnt
										cFilAte	:= cFilAnt
										oProcess := MsNewProcess():New({|lEnd|	CtAtSldCmp(oProcess,cAlias,cSaldo,cMoeda,dDataIni,cOrigem,dMinData,cFilDe,cFilAte,lCusto,lItem,lClVl,lAtSldBase,,,,aSelFil)},"","",.F.)
										oProcess:Activate()
									Next
									cFilAnt		:= cFilXAnt
									cFilDe		:= cFilAnt
									cFilAte		:= cFilAnt
								Else
									oProcess := MsNewProcess():New({|lEnd|	CtAtSldCmp(oProcess,cAlias,cSaldo,cMoeda,dDataIni,cOrigem,dMinData,cFilDe,cFilAte,lCusto,lItem,lClVl,lAtSldBase,,,cFilAnt,aSelFil)},"","",.F.)
									oProcess:Activate()
								EndIf
							Else		//Se nao atualiza os saldos compostos, somente da mensagem
								cMensagem	:= STR0016
								cMensagem	+= STR0017
								MsgAlert(OemToAnsi(cMensagem))	//Os saldos compostos estao desatualizados...Favor atualiza-los
								Return							//atraves da rotina de saldos compostos
							EndIf
						EndIf
					ENDCASE
				EndIf
	
				Return

