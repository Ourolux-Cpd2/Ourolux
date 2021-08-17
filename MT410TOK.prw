
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MT410TOK     ºAutor  ³Eletromega       º Data ³  10/08/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Este ponto de entrada é executado ao clicar no botão 'OK'	  º±±
±±ºe pode ser usado para validar a confirmação da operação 				  º±±
±±º(incluir, alterar, copiar e excluir).                                  º±±
±±ºSe o ponto de entrada retorna .T., o sistema continua a operação, caso º±± 
±±ºcontrário, retorna a tela do pedido.                                   º±±
±±ºParamIXB[1] == 1 // exclusão                                           º±± 
±±ºParamIXB[1] == 4 // Altera                                             º±±
±±ºSe o ponto de entrada retorna .T., o sistema continua a operação,      º±±
±±ºcaso contrário, retorna a tela do pedido.                              º±±                     
±±º SC5 POSICIONADO                                                       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP8                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function MT410TOK()

Local lRet 		:= .T.
Local cSegmento	:= GetAdvFVal("SA1","A1_SATIV1",xFilial("SA1")+M->(C5_CLIENTE+C5_LOJACLI),1,"")
Local cCodGrupo := GetMV("FS_ELE004") // FS_ELE004 contains o codigo do grupo alttes
Local nPProd    := aScan(aHeader,{ |x| Upper(AllTrim(x[2])) == "C6_PRODUTO" }) 
Local nPosPrc   := aScan(aHeader,{ |x| Upper(AllTrim(x[2])) == "C6_PRCVEN" })
Local nPPrUnit  := aScan(aHeader,{ |x| Upper(AllTrim(x[2])) == "C6_PRUNIT" })
Local aArea	   	:= GetArea()
Local aAreaSF1  := SF1->( GetArea() )
Local nLimite	:= 0
Local nRet		:= 0
Local nVlrPed   := 0
Local cAviso    := ""
Local cXAviso   := ""
Local i
Local nOpc         	:= PARAMIXB[1]	// Opcao de manutencao



// Rotina Automatica SFA
If Type("L410Auto")!="U" .And. L410Auto
	If !U_xAuto410()
		Return (.T.)
	EndIf
EndIf

//Triyo 11/12/2019

DBSelectArea("PR1")
PR1->(dbSetOrder(2))
If PR1->(dbSeek(xFilial("SC5")+"SC5"+xFilial("SC5")+SC5->C5_NUM ))
		    
	If nOpc == 5
		RecLock("PR1",.F.)
		PR1->PR1_TIPREQ := "3"
		PR1->PR1_DATINT := Date()
		PR1->PR1_HRINT	:= Time()		
		PR1->PR1_STINT  := "P"
		PR1->(MsUnlock())
    Endif
EndIf

//Fim Triyo 11/12/2019

// Claudino - 10/12/15
**********************************************************
If cFilAnt == '01' // Claudino - I1611-915 - 11/11/16
	If !Empty(M->C5_TRANSP)
		If cNivel < 3
			lRet := .F.
			//Amedeo Fabritech (Ajuste para mensagem Portal de 4Sales)
			//ApMsgInfo("Favor não digitar a transportadora!","MT410TOK")
			Aviso( "MT410TOK", "Favor não digitar a transportadora!", {"Ok"} )
		Else
			If Upper(UsrRetName(__cUserId)) $ GetMv("FS_RETIRA") .AND. M->C5_TRANSP <> "99    "
				lRet := .F. 
				//Amedeo Fabritech (Ajuste para mensagem Portal de 4Sales)
				//ApMsgStop("O Depto Comercial só pode digitar a transportadora RETIRA!","MT410TOK")
				Aviso( "MT410TOK", "O Depto Comercial só pode digitar a transportadora RETIRA!", {"Ok"} )
			EndIf
		EndIf
	EndIf
EndIf
**********************************************************
// Claudino - 10/12/15

If ( lRet .And. (ALTERA .Or. INCLUI).AND. (M->C5_CONDPAG == 'XXX') )
	lRet := .F.
	//Amedeo Fabritech (Ajuste para mensagem Portal de 4Sales)
	//ApMsgInfo("Cond. de Pagamento Invalida","MT410TOK")
	Aviso( "MT410TOK", "Cond. de Pagamento Invalida", {"Ok"} )
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄI
//³Tratamento para Trocas                          ³
//³WAR 07-11-2008                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄI
If lRet .And. (ALTERA .Or. INCLUI) .And. M->C5_TIPO == "T"
	
	DbSelectArea("SF1")                
   	DbSetOrder(1) // F1_FILIAL, F1_DOC, F1_SERIE, F1_FORNECE, F1_LOJA, F1_TIPO
	
	If MsSeek(xFilial("SF1")+ M->C5_NUM + 'TRC')
		If !(SF1->F1_FORNECE == M->C5_CLIENTE .And.;
		     SF1->F1_LOJA == M->C5_LOJACLI)
			lRet := .F.
			//Amedeo Fabritech (Ajuste para mensagem Portal de 4Sales)
			//ApMsgStop("Verifique o Cliente da Troca!","MT410TOK")
			Aviso( "MT410TOK", "Verifique o Cliente da Troca!", {"Ok"} )
		EndIf
    EndIf
    RestArea(aAreaSF1)
    
    If lRet .And. (M->C5_ORCAM <> 'T')
	
		lRet := .F.
		//Amedeo Fabritech (Ajuste para mensagem Portal de 4Sales)
		//ApMsgStop("Situacao Ped deve ser Troca!","MT410TOK")
		Aviso( "MT410TOK", "Situacao Ped deve ser Troca!", {"Ok"} )
    
    EndIf

EndIf 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄI
//³Gerar o Campo C5_AVISO                          ³
//³WAR 07-11-2008                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄI
If lRet .And. (ALTERA .Or. INCLUI) .And. !M->C5_TIPO $[DB]
	U_VldCli(M->C5_CLIENTE,M->C5_LOJACLI,@cAviso)
	M->C5_AVISO := cAviso 
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Cliente com risco E e bloqueado    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If SA1->A1_RISCO == 'E' .And. INCLUI
		lRet := .F.
		//Amedeo Fabritech (Ajuste para mensagem Portal de 4Sales)
		//ApMsgStop("Cliente com risco E","MT410TOK")
		Aviso( "MT410TOK", "Cliente com risco E", {"Ok"} )
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄI
//³Gerar o Campo C5_XAVISO - Analise Risk Rating   ³
//³Gilson Belini - 08/04/2017                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄI
If lRet .And. (ALTERA .Or. INCLUI) .And. !M->C5_TIPO $[DB]
	U_VldRR(M->C5_CLIENTE,M->C5_LOJACLI,@cXAviso)
	M->C5_XAVISO := cXAviso 
EndIf

If lRet .And. (ALTERA .Or. INCLUI) .And. M->C5_TIPO == "N"

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄI
	//³Gera TES e CFOP PARA TODOS OS ITESN DO PEDIDO   ³
	//³ WAR 10-11-2006                                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄI
	/*
	If lRet .AND.  ! U_VLDUSGRP(cCodGrupo)      
		U_GeraTESCF()
	EndIf

	// Verificacao de CFO se existe mais de 2 diferente
	If lRet
		lRet := U_VerQtdCFO()
	EndIf
	*/
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Nao deixa tirar pedido para o cliente padrao para orçamento    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If (lRet	.AND. M->C5_CLIENTE == '000000')
		lRet := .F.
		//Amedeo Fabritech (Ajuste para mensagem Portal de 4Sales)
		//ApMsgStop( 'Não pode cadastrar pedidos para o cliente ' + Alltrim( M->C5_CLIENTE ), 'ATENÇÃO' )
		Aviso( "MT410TOK", 'Não pode cadastrar pedidos para o cliente ' + Alltrim( M->C5_CLIENTE ), 'ATENÇÃO', {"Ok"} )
	EndIf 

	If lRet .AND. Empty(cSegmento)
		lRet := .F.
		//Amedeo Fabritech (Ajuste para mensagem Portal de 4Sales)
		//ApMsgInfo("Cliente sem Segmento.","Segmento Vazio")
		Aviso( "MT410TOK", "Cliente sem Segmento.", {"Ok"} )
	EndIf
	/* Rgras de negocios
	If lRet .And. M->C5_TIPO == "N" 
		lRet := U_ValidPrc(2)
	EndIf
	*/
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Validate se produto pode ser vendido fora da embalagem  ³
	//³ WAR                                                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lRet .And. (M->C5_TIPO == 'N')
    	For i := 1 to Len(aCols)
    		If !(lRet := U_VerEmb(i))
    			Exit
    		EndIf
    	Next
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Validate a condiçao de pagamento                        ³
	//³ WAR                                                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
/*	If lRet
		nVlrPed := U_TotPed()
		
		If ((nRet := U_VldCPG(nVlrPed,M->C5_CONDPAG,@nLimite)) != 0) .And. lRet   
			lRet := U_AvisoCP(nLimite,nRet)
		EndIf  
	
	EndIf
*/	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Gera classificaçao fiscal (1 digit from SB1 + 2 digits from SF4)      ³
	//³ WAR                                                                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    If lRet
    	U_GeraClas()
    EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Grava campo C5_PEDREP        ³
	//³ WAR                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    If lRet
    	M->C5_PEDREP := USRRETNAME(RETCODUSR())
    EndIf

    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Tratamento para C6_PRUNIT    ³
	//³ WAR 08-07-2009               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	/*
    If lRet .And. (ALTERA .Or. INCLUI)
    
    	For nI:=1 TO Len(aCols)
			If !aCols[nI][Len(aHeader)+1] 
				aCols[nI][nPPrUnit] := aCols[nI][nPosPrc] 	
			EndIf
		Next nI

    EndIf
    */
    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄI
	//³Gerar o Campo C5_AVISO                          ³
	//³WAR 07-11-2008                                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄI
	If lRet .And. (ALTERA .Or. INCLUI) .And. !M->C5_TIPO $[DB]
		U_VldCli(M->C5_CLIENTE,M->C5_LOJACLI,@cAviso)
		M->C5_AVISO := cAviso
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄI
	//³Gerar o Campo C5_XAVISO - Analise Risk Rating   ³
	//³Gilson Belini - 08/04/2017                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄI
	If lRet .And. (ALTERA .Or. INCLUI) .And. !M->C5_TIPO $[DB]
		U_VldRR(M->C5_CLIENTE,M->C5_LOJACLI,@cXAviso)
		M->C5_XAVISO := cXAviso
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Pedidos Exportaçao                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If M->C5_TIPOCLI == 'X'
		If Empty(M->C5_XUFEMB) .Or. Empty(M->C5_XLOCEMB) 
			lRet := .F.
			//Amedeo Fabritech (Ajuste para mensagem Portal de 4Sales)
			//ApMsgStop("Favor informar UF e Local de embarque!","MT410TOK")
			Aviso( "MT410TOK", "Favor informar UF e Local de embarque!", {"Ok"} )
		EndIf
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Bonificaçao so pode utilizar con BON    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If U_IsPedBonif(M->C5_NUM) .And. M->C5_CONDPAG != 'BON' 

		lRet := .F.
		//Amedeo Fabritech (Ajuste para mensagem Portal de 4Sales)
		//ApMsgStop('Favor utilizar a condicao BON para pedidos de bonificaçoes', 'MT410TOK')
		Aviso( "MT410TOK", 'Favor utilizar a condicao BON para pedidos de bonificaçoes', {"Ok"} )

	EndIf

EndIf

RestArea(aArea)       
Return (lRet)
