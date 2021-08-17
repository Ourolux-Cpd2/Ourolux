#INCLUDE "PROTHEUS.CH"
#INCLUDE "topconn.ch"
#INCLUDE "TBICONN.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "RPTDEF.CH"
#include "Rwmake.ch"
#Define ENTER Chr(10) + Chr (13)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄaÄÄÄÄÄÄÄ´±±
±±³ Funcao   ³ COMROT01 ³ Autor ³ Andre Salgado  	  Data ³27/08/2018    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Tela Aprovacao de Pedidos								  ³±±
±±³          ³ 															  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ 				                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±

±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ 						ULTIMAS ATUALIZAÇÕES      			  		   ±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ DATA     ³ 	NOME             ³ 	HORA                               	  ³±±
±±³ 																	  ³±±
±±³ 																	  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
*/

User Function COMROT01()

Local cQuery 		:= ""

Private lFlag		:= .T.
Private cAlias		:= GetNextAlias()
Private oFont 		:= TFont():New('Courier new',,-14,.F.,.T.)
Private oFont1		:= TFont():New('Courier new',,-20,.F.,.T.)
Private oFont2		:= TFont():New('Courier new',,-18,.F.,.T.)
Private oFont3		:= TFont():New('Courier new',,-15,.F.,.T.)
Private oFont4		:= TFont():New('Courier new',,-24,.F.,.T.)
Private cNumPV		:= Space(6)
Private cClie		:= Space(6)
Private cVend		:= Space(6)
Private aRetDados 	:= {}
Private aBrwSA3		:= {}
Private cNRonda 	:= ""
Private oGet1

Private oGet
Private oFiltro
Private oTelSA3
Private aOrdem		:= {"PRIORIDADE","PEDIDO","VALOR"}
Private cVip
Private cOrdem    
Private cCliDe		:= space(6)
Private cCliAte		:= "ZZZZZZ"
Private dDtDE		:= ctod("  /  /  ")	
Private dDtATE		:= ddatabase		
Private cCliGerDe	:= space(6)
Private cCliGerAt	:= "ZZZZZZ"
Private nValorOnda	:= 3000000
Private dProgram	:= ctod("  /  /  ")	
Private nQtdSku		:= 0
Private nValor		:= 0
Private nPedSel		:= 0
Private nQtdSel		:= 0
Private nTotal		:= 0
Private nTotalB		:= 0
Private nCont		:= 0
Private nVlrComI	:= 0
Private cPerg   	:= "COMROT01"
Private cBloqClick	:= "xBLOQUEADO"
Private cTextoV		:= ""

If !pergunte(cPerg,.T.)
    Return()
EndIf

cMarc	    := MV_PAR01		//Trazer Pedidos Marcados
cMarcComI   := MV_PAR02		//Considerar Comissao Vendedor INTERNO ou seja nao gera Pedido de Compra
dDtComI		:= MV_PAR03		//Data de Pagamento Comissao Vendedor INTERNO

If cMarc = 1		//Marcado SIM
	lFlag		:= .T.
Else
	lFlag		:= .F.
Endif


//Busca Valor da Comissão dos Vendedores - INTERNOS
IF cMarcComI = 1

	cQuery0 :=	" SELECT E3_VEND+' '+A3_NOME VENDEDOR, SUM(E3_COMIS) VLR_COMIS  FROM SE3010 E3"
	cQuery0 +=	" INNER JOIN SA3010 A3 ON E3_VEND=A3_COD AND A3.D_E_L_E_T_=' ' "
	cQuery0 +=	" WHERE E3.D_E_L_E_T_=' ' "
	cQuery0 +=	" AND E3_DATA = '"+DTOS(dDtComI)+"' AND LEFT(E3_PROCCOM,3)=' '  "
	//cQuery0 +=	" AND LEFT(E3_PROCCOM,3)=' '  "
	cQuery0 +=	" GROUP BY E3_VEND, A3_NOME"
	cQuery0 +=	" ORDER BY 1"

	If Select("TRBSA2") <> 0
		DbSelectArea("TRBSA2")
		DbCloseArea()
	Endif
	TCQUERY cQuery0 NEW ALIAS "TRBSA2"

	While TRBSA2->(!EOF())

		cTextoV += padr("R$ "+transform(TRBSA2->VLR_COMIS,"@E 999,999.99"),18)+" "+TRIM(TRBSA2->VENDEDOR)+ENTER

		nVlrComI += TRBSA2->VLR_COMIS
		TRBSA2->(dbSkip())
	Enddo

EndIf



//Busca os Pedidos de Compra Em Aberto, que estão aguardando Aprovação
cQuery :=	" SELECT C7_NUM, C7_FORNECE +' '+A2_NOME A2_NOME, A2_EST, ROUND(C7_TOTAL,2) C7_TOTAL "
//cQuery +=	" , CASE A3_X_BLOQ WHEN 'S' THEN 'BLOQUEADO' ELSE ' ' END STATUS1"
cQuery +=	" , ' ' STATUS1"
cQuery +=	" FROM SC7010 C7"
cQuery +=	" INNER JOIN SA2010 A2 ON A2_COD=C7_FORNECE AND A2_LOJA=C7_LOJA AND A2.D_E_L_E_T_=' '"
//cQuery +=	" LEFT  JOIN SA3010 A3 ON C7_FORNECE=A3_FORNECE AND A3.D_E_L_E_T_=' ' ""
cQuery +=	" WHERE C7.D_E_L_E_T_=' ' AND C7_RESIDUO=' '"
//cQuery +=	" AND C7_QUJE=0 AND C7_CONAPRO='B'"
cQuery +=	" AND C7_PRODUTO='COMISSAO' and C7_DINICOM = '"+DTOS(dDtComI)+"' "
cQuery +=	" ORDER BY 1"


If Select("TRBSA3") <> 0
	DbSelectArea("TRBSA3")
	DbCloseArea()
Endif

TCQUERY cQuery NEW ALIAS "TRBSA3"

//Processa o Resultado
dbSelectArea("TRBSA3")
TRBSA3->(dbGoTop())

While TRBSA3->(!EOF())

	If cMarc = 1
			lFlag	:= .T.
			nTotal += TRBSA3->C7_TOTAL
			nCont++
		//Endif
	Endif

	aAdd(aBrwSA3,{lFlag,;
	TRBSA3->C7_NUM,;
	TRBSA3->A2_NOME,;
	TRBSA3->C7_TOTAL,;
	TRBSA3->A2_EST,;
	TRBSA3->STATUS1 })

	//nTotal += TRBSA3->C7_TOTAL
	TRBSA3->(dbSkip())
	
Enddo

If Len(aBrwSA3) == 0
	aAdd(aBrwSA3,{.T., SPACE(10), SPACE(100), 0.00, SPACE(10), SPACE(10) })
Endif


If cMarc = 1 	//If lFlag
	nQtdSel	:= nCont
Else
	nQtdSel := 0
	nTotal	:= 0
Endif


IF cMarcComI = 1
	nTotal += nVlrComI
Endif


DEFINE MSDIALOG oTelSA3 FROM 38,16 TO 640,1090 TITLE Alltrim(OemToAnsi("..PEDIDOS DE COMPRA - COMISSAO")) Pixel

@ 002, 005 To 060, 535 Label Of oTelSA3 Pixel

oSay5  	:= TSay():New(007,140,{|| "PEDIDOS DE COMPRA - COMISSAO" },oTelSA3,,oFont4,,,,.T.,CLR_GREEN)

IF cMarcComI = 1
	oSay  	:= TSay():New(030,010,{|| "Valor Comissao Interna - R$ "+transform(nVlrComI,"@E 9,999,999.99") },oTelSA3,,oFont3,,,,.T.,)
Endif

//oSay  	:= TSay():New(030,010,{|| "Valor Comissao Interna - R$ "+transform(nTotalB		,"@E 9,999,999.99") },oTelSA3,,oFont3,,,,.T.,)
//oSay  	:= TSay():New(030,010,{|| "Valor Comissao Interna - R$ "+transform(nTotal-nVlrComI,"@E 9,999,999.99") },oTelSA3,,oFont3,,,,.T.,)


oSay  	:= TSay():New(285,010,{|| "SELECIONADOS" },oTelSA3,,oFont3,,,,.T.,)
oGet1	:= tGet():New(284,075,{|u| if(Pcount()>0,nQtdSel:=u,nQtdSel) },,60,8,"@E 9,999,999",,,,oFont3,,,.T.,,,,,,,.T.,,,"nQtdSel",,,,.F.,,,)

oSay  	:= TSay():New(285,350,{|| "TOTAL" },oTelSA3,,oFont3,,,,.T.,)
oGet2	:= tGet():New(284,380,{|u| if(Pcount()>0,nTotal:=u,nTotal) },,80,8,"@E 999,999,999.99",,,,oFont3,,,.T.,,,,,,,.T.,,,"nTotal",,,,.F.,,,)

@ 010,470 Button "PROCESSAR" size 55,12 action Processa( {|| ProcChek() }) OF oTelSA3 PIXEL

IF cMarcComI = 1
	@ 025,470 Button "Comis.Interna" size 55,12 action Processa( {|| ProcVI() })   OF oTelSA3 PIXEL
Endif

@ 040,470 Button "FECHAR"  	 size 55,12 action oTelSA3:End() OF oTelSA3 PIXEL
	
oListBo2	:= twBrowse():New(063,005,530,215,,{" ","PEDIDO","REPRESENTANTE","VALOR","ESTADO","SIT.REPRESENTANTE"},,oTelSA3,,,,,,,,,,,,.F.,,.T.,,.F.,,,)

oListBo2:SetArray(aBrwSA3)
oListBo2:bLine := {||{ IIf(aBrwSA3[oListBo2:nAt][1],LoadBitmap( GetResources(), "CHECKED" ),LoadBitmap( GetResources(), "UNCHECKED" )),; //flag
aBrwSA3[oListBo2:nAt,02],;
aBrwSA3[oListBo2:nAt,03],;
transform(aBrwSA3[oListBo2:nAt,04],"@E 999,999.99"),;
aBrwSA3[oListBo2:nAt,05],;
aBrwSA3[oListBo2:nAt,06]}}


oListBo2:bLDblClick := {||Iif(oListBo2:nColPos <> 5,(aBrwSA3[oListBo2:nAt,1] := !aBrwSA3[oListBo2:nAt,1]),(aBrwSA3[oListBo2:nAt,1] := .T.,)), oListBo2:Refresh(), AtuAcols()  } 
//oListBo2:bLDblClick := {|| Iif(aBrwSA3[oListBo2:nAt,06] $ cBloqClick,aBrwSA3[oListBo2:nAt,1] := .F., Iif(oListBo2:nColPos <> 5,(aBrwSA3[oListBo2:nAt,1] := !aBrwSA3[oListBo2:nAt,1]),(aBrwSA3[oListBo2:nAt,1] := .T.,))), oListBo2:Refresh(), AtuAcols()  } 

oGet1:Refresh()
oGet2:Refresh()
oTelSA3:Refresh()
oListBo2:Refresh() 

ACTIVATE MSDIALOG oTelSA3 centered

TRBSA3->(DbCloseArea())

Return()               



//Mostra em Tela Detalhe dos Valores dos Vendedores - INTERNOs
Static Function ProcVI()

	AVISO("COMISSAO INTERNA", cTextoV, {"OK"}, 1)

Return()


//*******************************************************
//
//*******************************************************
Static Function ProcChek()

nContaPC := 0
If nTotal > 0
	
	If MsgYesNo("DESEJA PROCESSAR OS PEDIDOS SELECIONADOS?")
		
		For nx := 1 To Len(aBrwSA3)
						
			If aBrwSA3[nx][1]
				MyExec094(aBrwSA3[nx][2])
				nContaPC++
			Endif
			
		Next nx
		
		
		MSGINFO("PROCESSADO COM SUCESSO N° "+transform(nContaPC,"@E 9999") +" Pedido(s)")
		
	Else
		
		MSGINFO("PROCESSO CANCELADO PELO USUARIO")
		
	Endif
	
Else
	MSGINFO("NENHUM VALOR SELECIONADO, A ONDA NÃO SERÁ PROCESSADA")
Endif

oTelSA3:End()

Return()




//*******************************************************************
//Função - Atualiza ACOLS - Grid em Tela
//*******************************************************************

Static Function AtuAcols()

//Sempre Zera para Calcular novamente
nQtdSel			:= 0
nTotal 			:= 0
nTotal			:= nVlrComI	

For nx := 1 To Len(aBrwSA3)


	If aBrwSA3[nx][1]				
		
		nQtdSel++
		nTotal 	+= aBrwSA3[nx][4]

	Endif 

Next nx

//Refresh em Tela
oGet1:Refresh()
oGet2:Refresh()
oTelSA3:Refresh()
oListBo2:Refresh()

Return()




//Aprova Pedido de Compra
Static Function MyExec094(cPedC7)
 
Local oModel094 := Nil      //-- Objeto que receberá o modelo da MATA094
Local cNum      := cPedC7 //"PMSA02" //-- Recebe o número do documento a ser avaliado
Local cTipo     := "PC"     //-- Recebe o tipo do documento a ser avaliado
Local cAprov    := RetCodUsr()	//Codigo do Usuario TOTVS
Local cAprovSAK := ""		//Codigo do Usuario TOTVS
Local nLenSCR   := 0        //-- Controle de tamanho de campo do documento
    
    
	//Tabela de Aprovadores
	DbSelectArea("SAK")
    SAK->(DbSetOrder(2)) 
	DbSeek(xFilial("SAK") + cAprov)
	
	IF FOUND()
		cAprovSAK := SAK->AK_COD	//Codigo de Aprovador
	
		//Tabela de Alçadas
		nLenSCR := TamSX3("CR_NUM")[1] //-- Obtem tamanho do campo CR_NUM
		DbSelectArea("SCR")
		SCR->(DbSetOrder(3)) //-- CR_FILIAL+CR_TIPO+CR_NUM+CR_APROV

		//Aprovacao Denise
		If SCR->(DbSeek(xFilial("SCR") + cTipo + Padr(cNum, nLenSCR) + "000033"))
			RecLock("SCR",.F.)
			SCR->CR_STATUS  := "03"
			SCR->CR_DATALIB := DATE()	//DATA A APROVACAO
			SCR->CR_USERLIB := "001806"
			SCR->CR_TIPOLIM := "D"
			SCR->CR_LIBAPRO := "000033"
			SCR->(MsUnLock())
		EndIf

		//Aprovacao Segundo Aprovador	
		If SCR->(DbSeek(xFilial("SCR") + cTipo + Padr(cNum, nLenSCR) + cAprovSAK))
			RecLock("SCR",.F.)
			SCR->CR_STATUS  := "03"
			SCR->CR_DATALIB := DATE()	//DATA A APROVACAO
			SCR->CR_USERLIB := cAprov
			SCR->CR_TIPOLIM := "D"
			SCR->CR_LIBAPRO := cAprovSAK
			SCR->(MsUnLock())
		EndIf

		
		//Tabela de Pedido
		DbSelectArea("SC7")
		SC7->(DbSetOrder(1)) 
		DbSeek(xFilial("SC7") + cPedC7 )

		IF FOUND()
			RecLock("SC7",.F.)
			SC7->C7_CONAPRO := "L"
			SC7->C7_IDTSS   := SC7->C7_FILIAL + cPedC7
			SC7->C7_TPCOLAB := "PC"
			SC7->(MsUnLock())
		Endif
	Endif


Return Nil
