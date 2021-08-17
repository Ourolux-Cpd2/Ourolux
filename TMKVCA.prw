#INCLUDE "PROTHEUS.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TMKVCA    ºAutor  ³Norbert Waage Juniorº Data ³  17/03/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Ponto de entrada utilizado para substituir a tela de deta-  º±±
±±º          ³lhes do produto no televendas.                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Eletromega                                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function TMKVCA(cAtend,cCliente,cLoja,cCodCont,cCodOper)

Local aArea	:=	GetArea()

If !U_NaPilha("A410VISUAL",2) //PROCNAME(4)$ 'TK271CALLCENTER' 
	TkProdutoB()
EndIf
RestArea(aArea)

Return Nil   

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³TkProdutoB  ³ Autor ³Norbert Waage Junior   ³ Data ³ 17/03/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Carrega Caracteristicas do produto para todas as telas        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso   	 ³ CALL CENTER    			 					  	     	    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function TkProdutoB()

Local lRet		:= .F.							// Retorno da funcao	
Local aArea		:= GetArea()					// Salva a area atual
Local cProduto 	:= ""							// Codigo do Produto
Local cObs 		:= ""							// Observacao do Produto
Local oObs
Local oDlg            							// Tela 
Local nPProd 	:= 0							// Posicao do Produto no ACOLS

Local cBitPro 	:= ""							// Bitmap do produto
Local oBitPro							
Local cLocal 	:= ""                   		// Local do produto
Local cPictSB2  := SPACE(12)					// Picture do SB2
Local cNomeAlter:= ""							// Produto Alternativo
Local cGrupo    := ""							// Grupo
Local nPLocal   := 0							// Local
Local cAtend    := ""							// Codigo do Atendimento
Local cCliente  := ""							// Codigo do Cliente
Local cLoja     := ""                           // Loja do Cliente
Local cCodCont  := ""                           // Codigo do Contato
Local cCodOper  := ""                           // Codigo do Operador
Local cEnt      := ""							// Alias da Entidade
Local cChave    := ""                           // Chave da Entidade

Local nAtu   	:= 0
Local nPedVen 	:= 0
Local nEmp    	:= 0
Local nSalPedi	:= 0
Local nReserva	:= 0
Local nSaldo  	:= 0

Local nPosAnt   := 0 
Local nNAux		:= n
Local aColsAux	:= aClone(aCols)
Local aHeadAux	:= aClone(aHeader)

Local lUsaTab	:= U_IsAdm()
Local lEstLim	:= U_IsELE002()

Local nQtdLim	:= GetMv("MV_QTDLIM")


DEFAULT nFolder := IIf(nFolder == NIL,1,nFolder)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Funcao utilizada para verificar a ultima versao dos fontes      ³
//³ SIGACUS.PRW, SIGACUSA.PRX e SIGACUSB.PRX, aplicados no rpo do   |
//| cliente, assim verificando a necessidade de uma atualizacao     |
//| nestes fontes. NAO REMOVER !!!							        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
IF !(FindFunction("SIGACUS_V") .and. SIGACUS_V() >= 20050512)
    Final("Atualizar SIGACUS.PRW !!!")
Endif
IF !(FindFunction("SIGACUSA_V") .and. SIGACUSA_V() >= 20050512)
    Final("Atualizar SIGACUSA.PRX !!!")
Endif
IF !(FindFunction("SIGACUSB_V") .and. SIGACUSB_V() >= 20050512)
    Final("Atualizar SIGACUSB.PRX !!!")
Endif

nPProd    := aPosicoes[1][2]
nPLocal   := aPosicoes[7][2]
cAtend    := M->UA_NUM
cCliente  := M->UA_CLIENTE
cLoja     := M->UA_LOJA
cCodCont  := M->UA_CODCONT
cCodOper  := M->UA_OPERADO

cProduto := aCols[n][nPProd]
If nPLocal > 0
	cLocal := aCols[n][nPLocal]
Endif

If Empty(cProduto)
	Help(" ",1,"SEM PRODUT" )
	Return(lRet)
Endif

DbSelectarea("SB1")
DbSetOrder(1)
If DbSeek(xFilial("SB1") + cProduto)
	cObs   := MSMM(SB1->B1_CODOBS,TamSx3("B1_OBS")[1])
	cGrupo := SB1->B1_GRUPO
	If Empty(cLocal)
		cLocal := RetFldProd(SB1->B1_COD,"B1_LOCPAD")
	Endif
	nPosAnt:= Recno()
	
	If DbSeek(xFilial("SB1")+SB1->B1_ALTER)
		cNomeAlter := ALLTRIM(B1_COD + " - "+ ALLTRIM(B1_DESC))
	Endif
Endif

DbSelectarea("SB2")
DbSetorder(1)
If DbSeek(xFilial("SB2") + cProduto + cLocal)
	nAtu   	:= B2_QATU
	nPedVen := B2_QPEDVEN
	nEmp    := B2_QEMP
	nSalPedi:= B2_SALPEDI
	nReserva:= B2_RESERVA

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Aglutina SB2 Filial 01 ao SB2 Filial 04 - Específico p/ Rio de Janeiro³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If cFilAnt == "04"
		aAreaSB2 := SB2->(GetArea())
		DbSelectarea("SB2")
		DbSetorder(1)
		DbGoTop()
		If DbSeek("01" + cProduto + cLocal)
			nAtu		:= nAtu + B2_QATU
			nPedVen		:= nPedVen + B2_QPEDVEN
			nEmp		:= nEmp + B2_QEMP
			nSalPedi	:= nSalPedi + B2_SALPEDI
			nReserva	:= nReserva + B2_RESERVA
		Else
			ApMsgStop( 'Produto ' + SB2->B2_COD + ' sem saldo!', 'TMKVCA' )
		EndIf
		RestArea(aAreaSB2)
	EndIf

	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Compatibilizacao com o SIGAFAT - Tecla F4 Visualizacao do estoque³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//nSaldo  := SaldoSb2(,GetNewPar("MV_QEMPV",.T.)) // WAR 29-11-2006
	If cFilAnt == "04"
		nSaldo  := SaldoSb2(,GetNewPar("MV_QEMPV",.T.)) - ABS(nPedVen) - nEmp + SB2->B2_XINTEGR + SB2->B2_XINTEGR
		aAreaSB2 := SB2->(GetArea())
	 	cFilOrig	:= cFilAnt
		cFilAnt		:= "01"
		If (SB2->( dbSeek( xFilial( 'SB2' ) + aCols[n][nPProd] + GetMV('EX_ALXPDB',,'01') ))) 
			nSldSB201 := SaldoSB2(.F.,.T.,,.F.,.F.,,,,.T.) -  ABS(SB2->B2_QPEDVEN)
			nSaldo := nSaldo + nSldSB201
		EndIf
		cFilAnt	:= cFilOrig
		RestArea(aAreaSB2)
	Else
		  //nSaldo  := SaldoSb2(,GetNewPar("MV_QEMPV",.T.)) - ABS(nPedVen) - nEmp 
		  nSaldo  := SaldoSb2(,GetNewPar("MV_QEMPV",.T.)) - ABS(nPedVen)
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica se o saldo esta acima do valor permitido para³
	//³visualizacao do operador                              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lEstLim
		If nAtu > nQtdLim
			nAtu := nQtdLim
		EndIf       
		
		If nSaldo > nQtdLim
			nSaldo := nQtdLim
		EndIf
	EndIf
	
Endif

DbSelectarea("SB5")
DbSeek(xFilial("SB5") + cProduto)

DbSelectarea("SX3")
DbSetorder(2)
If DbSeek("B2_QATU")
	cPictSB2 := SX3->(X3_PICTURE)
Endif

DbSelectarea("SBM")
//DbSetorder(1)
If DbSeek(xFilial("SBM")+cGrupo)
	cGrupo := SBM->BM_DESC
Endif

/* WAR 07-06-2006 usar sbm en ves do SX5
DbSelectarea("SX5")
DbSetorder(1)
If DbSeek(xFilial("SX5")+"03"+cGrupo)
	cGrupo := X5DESCRI()
Endif
*/

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Mostra dados do Produto.					                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DEFINE MSDIALOG oDlg FROM 23,181 TO 402,723 TITLE ("Caracteristicas do produto") PIXEL
	DbSelectarea("SB1")
	DbGoto(nPosAnt)              
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Dados das caracteristicas do produto                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
/*	WAR 07-06-2006 Alterar positions of the fields in the dialog box */
	@06,02 TO 43,270 LABEL ("Dados do Produto") OF oDlg PIXEL COLOR CLR_BLUE

	@13,04  SAY ("Codigo:" ) SIZE  21,7 OF oDlg PIXEL
	@13,29  SAY ALLTRIM(SB1->B1_COD) SIZE  47,8 OF oDlg PIXEL COLOR CLR_BLUE
	
	@13,60  SAY ("Unidade:") SIZE  20,7 OF oDlg PIXEL
	@13,85  SAY SB1->B1_UM SIZE  10,8 OF oDlg PIXEL COLOR CLR_BLUE

	@13,100 SAY ("Grupo:") SIZE  18,7 OF oDlg PIXEL
	@13,120 SAY cGrupo SIZE 40,8 OF oDlg PIXEL COLOR CLR_BLUE

	@13,190 SAY ("Qtd. Embalagem:") SIZE  70,7 OF oDlg PIXEL
	@13,225 SAY Transform(RetFldProd(SB1->B1_COD,"B1_QE"),PesqPict("SB1","B1_QE")) SIZE  35,7 OF oDlg PIXEL COLOR CLR_BLUE

	@23, 4  SAY ("Descriçao:") SIZE  32, 7 OF oDlg PIXEL
	@23,33  SAY SB1->B1_DESC SIZE 140, 8 OF oDlg PIXEL COLOR CLR_BLUE
	
	@23,190 SAY ("Peso Liquido:") SIZE  60,7 OF oDlg PIXEL
	@23,225 SAY Transform(SB1->B1_PESO,PesqPict("SB1","B1_PESO")) SIZE  35,7 OF oDlg PIXEL COLOR CLR_BLUE
	
	@33, 4  SAY ("Produto Alternativo:") SIZE  80,7 OF oDlg PIXEL
	@33,90  SAY cNomeAlter SIZE 138, 8 OF oDlg PIXEL COLOR CLR_BLUE
	
	cBitPro := SB1->B1_BITMAP
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Carrega a imagem do produto                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	@45,02 TO 152,105 LABEL ("Foto") OF oDlg PIXEL
	If Empty(SB1->B1_BITMAP)
		@ 80,30 SAY ("Foto não disponivel" ) SIZE 50,8 PIXEL COLOR CLR_BLUE OF oDlg
	Else
		@ 50,04 REPOSITORY oBitPro OF oDlg NOBORDER SIZE 100,100 PIXEL
		Showbitmap(oBitPro,SB1->B1_BITMAP,"")
		oBitPro:lStretch:=.F.
		oBitPro:Refresh()
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Carrega as observa‡ao sobre o produto B1_OBS         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	@45,110 TO 152,270 LABEL ("Observaçoes" ) OF oDlg PIXEL
	@51,115 GET oObs VAR cObs OF oDlg MEMO Size 150,99 PIXEL READONLY

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Saldo do estoque do produto                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	@153,02 TO 188,155 LABEL ("Estoque ") OF oDlg PIXEL 
	
	@158, 04 SAY ("Ped. Abertos:") SIZE  33, 7 OF oDlg PIXEL
	@158, 42 SAY Transform(nPedVen,cPictSB2) SIZE 40, 7 OF oDlg PIXEL COLOR CLR_BLUE
	
	@168, 04 SAY ("A Entrar:" ) SIZE  33, 7 OF oDlg PIXEL
	@168, 42 SAY Transform(nSalPedi,"@E 9,999,999.99") SIZE 40, 7 OF oDlg PIXEL COLOR CLR_BLUE
	
	@178, 04 SAY ("Atual:") SIZE  33, 7 OF oDlg PIXEL
	@178, 42 SAY Transform(nAtu,"@E 9,999,999.99") SIZE 40, 7 OF oDlg PIXEL COLOR CLR_BLUE
	
	@158, 83 SAY ("Empenho:" ) SIZE  33, 7 OF oDlg PIXEL
	@158,110 SAY Transform(nEmp,"@E 999,999,999.99") SIZE 40, 7 OF oDlg PIXEL COLOR CLR_BLUE
	
	@168, 83 SAY ("Reservado:") SIZE  33, 7 OF oDlg PIXEL
	@168,110 SAY Transform(nReserva,"@E 999,999,999.99") SIZE 40, 7 OF oDlg PIXEL COLOR CLR_BLUE
	
	@178, 83 SAY ("Disponivel:" ) SIZE  33, 7 OF oDlg PIXEL
	@178,110 SAY Transform(nSaldo,"@E 999,999,999.99") SIZE 40, 7 OF oDlg PIXEL COLOR CLR_BLUE

	@154,160 BUTTON "Complemento" SIZE 50,15 OF oDlg PIXEL ACTION TKDetalhes(nFolder) 

	@154,220 BUTTON "Produto" SIZE 50,15 OF oDlg PIXEL ACTION TKVisuProd(cProduto,cLocal) 

	If lUsaTab
		@175,160 BUTTON "Tabela" SIZE 50,15 OF oDlg PIXEL ACTION TKTabela(cProduto)
	EndIf

	@175,220 BUTTON "OK" SIZE 50,15 OF oDlg PIXEL ACTION (lRet := .T.,oDlg:End())

ACTIVATE MSDIALOG oDlg CENTER

Restarea(aArea)
n		:= nNAux
aCols	:= aClone(aColsAux)
aHeader	:= aClone(aHeadAux)

Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³TkTabela         ³ Autor ³ Marcelo Kotaki     ³ Data ³ 04/08/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Carrega as Tabelas de Preco da consulta de produto              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso   	 ³CALL CENTER           									 	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Henry Fila³18/07/05³84231 ³Ajuste da confirmacao da funcao pergunte na exi ³±±
±±³          ³        ³      ³bicao da tabela de precos                       ³±±
±±³          ³        ³      ³                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/           
Static Function TKTabela(cProduto)
Local aArea 	:= GetArea()
Local aCores    := {}
Local aRotAnt	:= aClone(aRotina)
Local cCadAnt	:= cCadastro
Local lIncAnt   := INCLUI

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Array contendo as Rotinas a executar do programa      ³
//³ ----------- Elementos contidos por dimensao ------------     ³
//³ 1. Nome a aparecer no cabecalho                              ³
//³ 2. Nome da Rotina associada                                  ³
//³ 3. Usado pela rotina                                         ³
//³ 4. Tipo de Transa‡„o a ser efetuada                          ³
//³    1 - Pesquisa e Posiciona em um Banco de Dados             ³
//³    2 - Simplesmente Mostra os Campos                         ³
//³    3 - Inclui registros no Bancos de Dados                   ³
//³    4 - Altera o registro corrente                            ³
//³    5 - Remove o registro corrente do Banco de Dados          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private aRotina := {{ "Pesquisar"	,"AxPesqui",0,1},;	//
					{ "Visualizar"	,"Oms010Tab",0,2},;	//
					{ "Incluir"		,"Oms010Tab",0,3},;	//
					{ "Alterar"		,"Oms010Tab",0,4},;	//
					{ "Excluir"		,"Oms010Tab",0,5},;	//
					{ "Copiar" 		,"Oms010Tab",0,4},; //
					{ "Copiar" 		,"Oms010For",0,3},; //	
					{ "Reajuste"	,"Oms010Rej",0,5},; //
					{ "Legenda"		,"Oms010Leg",0,2} }	//

cCadastro := "Manutencao da Tabela de Precos"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica as cores da MBrowse                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Aadd(aCores,{"Dtos(DA0_DATATE) <= Dtos(dDataBase).AND. !Empty(Dtos(DA0_DATATE))","DISABLE"}) //inativa
Aadd(aCores,{"(Dtos(DA0_DATATE) > Dtos(dDataBase) .OR. Empty(Dtos(DA0_DATATE))).And.DA0_ATIVO =='1'","ENABLE"})    //Ativa simples
Aadd(aCores,{"(Dtos(DA0_DATATE) > Dtos(dDataBase) .OR. Empty(Dtos(DA0_DATATE))) .And.DA0_ATIVO =='2'","BR_LARANJA"}) //Ativa especial


INCLUI := .F.
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Endereca para a funcao MBrowse                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("DA0")
DbSetOrder(1)
MsSeek(xFilial("DA0"))

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Habilita as perguntas da Rotina                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Pergunte("OMS010",.T.)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Restaura a Integridade da Rotina                                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Oms010Tab("DA0",DA0->(Recno()),2,.T.)

Endif
	
DbSelectArea("DA0")
DbSetOrder(1)
DbClearFilter()

RestArea(aArea)
cCadastro 	:= cCadAnt
aRotina		:= aClone(aRotAnt)	 
INCLUI 		:= lIncAnt
	
Return(NIL)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³TkDetalhes³ Autor ³ Marcelo Kotaki   		³ Data ³09/03/00  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Executa a rotina de Visualizacao do complemento de produto  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³CALL CENTER                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function TkDetalhes(nFolder)
Local lRet		:= .F.					// Retorno da funcao
Local nPProd 	:= 0
Local aArea		:= GetArea()

//Private cCadastro := STR0063			 //"Visualiza‡„o de Complemento de Produtos"

If nFolder == 1
	If (TkGetTipoAte() == "1") .OR. (TkGetTipoAte() == "4") // Telemarketing ou Televendas
		nPProd := aPosicoes[3][2]
	ElseIf (TkGetTipoAte() == "2") // Televendas
		nPProd := aPosicoes[1][2]
	Endif	
ElseIf nFolder == 2 // Televendas
	nPProd := aPosicoes[1][2]
Elseif nFolder == 4  //Configuracao de TMK	
	nPProd  := Ascan(aHeader,{|x| AllTrim(x[2])=="UF_PRODUTO"})
Endif

If Empty(aCols[n][nPProd])
	Help(" ",1,"SEM PRODUT" )
	Return(lRet)
Endif

DbSelectarea("SB5")
DbSetorder(1)
If DbSeek( xFilial("SB5")+ aCols[n][nPProd] )
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Envia para processamento dos Gets          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nOpcA:=AxVisual("SB5",RECNO(),2)
	lRet := .T.
Else	
	Help(" ",1,"TMKSEMSB5" )
	Return(lRet)
Endif

RestArea(aArea)
Return(lRet)                                                                        

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³TkVisuPro ³ Autor ³ Marcelo Kotaki  	    ³ Data ³ 08/03/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Carrega o AXVISUAL do cadastro de produtos para o item sele.³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso   	 ³ CALL CENTER  			 					  	     	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Analista  ³ Data/Bops/Ver ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Marcelo K ³05/08/01³710   ³-Revisao do fonte                           ³±±
±±³          ³        ³      ³                                            ³±±
±±³          ³        ³      ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function TKVisuProd(cProduto,cLocal)
Private cCadastro := ("Visualizaçao de Produtos")

DbSelectarea("SB1")

AxVisual("SB1",SB1->(RECNO()), 2)

Return(.T.)