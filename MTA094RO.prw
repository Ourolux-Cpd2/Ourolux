#include "Protheus.Ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³MTA094RO ³ Autor ³ Rodrigo Nunes        ³ Data ³ 18/12/14 ³ ±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Inserção de Botão com consulta de Histórico de Pedidos de   ³±±
±±³          ³Compra na tela de Liberação de Pedidos de Compras           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGACOM                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ PROGRAMADOR  ³ DATA   ³ BOPS ³  MOTIVO DA ALTERACAO.                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³                                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/  

User function MTA094RO()
Local aRotina := PARAMIXB[1]

aAdd(aRotina,{ "Hist. de Pedidos", "U_HISTPCOM()", 0 , 4, 0, nil})

Return aRotina

User Function HISTPCOM()

Local aArea  	 := GETAREA()

private oDlg
private oLbx1
private cCond     := ""

Private oAberto   := LoadBitmap(GetResources(),"BR_VERDE")
Private oEncerr   := LoadBitmap(GetResources(),"BR_VERMELHO")
Private oLibera   := LoadBitmap(GetResources(),"BR_AMARELO") 
Private oBloq     := LoadBitmap(GetResources(),"BR_AZUL")
Private cTitulo   := "Pedido de Vendas"
Private aVetCAB   := {}
Private aVetITE   := {}

Private oGETMERC
Private oGETFRET
Private oGETDESP
Private oGETDESC
Private oGETTOT


Private nTOTMERC	:= 0
Private nTOTFRET	:= 0
Private nTOTDESP	:= 0
Private nTOTDESC	:= 0
Private nTOTAL		:= 0

cPERG := "HISTPEDCOM"
   
If !Pergunte(cPERG,.T.)
	Return()
EndIf

dbSelectArea("SC7")
dbSetOrder(1)

If MsSeek(xFilial("SC7")+Substr(SCR->CR_NUM,1,len(SC7->C7_NUM)))
			
	cFORNECE 	:= SC7->C7_FORNECE 
	cLOJA		:= SC7->C7_LOJA    

EndIf

/// query do sc7

IF SELECT("TMP") > 0
	DBSELECTAREA("TMP")
	DBCLOSEAREA()
ENDIF

cQUERY	:= " SELECT C7_NUM "
cQUERY	+= " FROM "+RetSqlName("SC7") +" SC7 "     
cQUERY	+= " WHERE SC7.C7_FILIAL = '"+XFILIAL("SC7")+"' "
cQUERY	+= " AND SC7.C7_EMISSAO BETWEEN '"+DTOS(MV_PAR01)+"' AND '"+DTOS(MV_PAR02)+"' "
cQUERY	+= " AND SC7.C7_FORNECE = '"+cFORNECE+"' "
cQUERY	+= " AND SC7.C7_LOJA = '"+cLOJA+"' "
cQUERY 	+= " AND SC7.D_E_L_E_T_ <> '*'	 "                     
cQUERY 	+= " GROUP BY C7_NUM "
cQUERY 	+= " ORDER BY C7_NUM "

DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery) , 'TMP', .T., .F.)

DBSELECTAREA("TMP")
DBGOTOP()
WHILE !EOF()

	dbSelectArea("SC7")
	dbSetOrder(1)
	dbSeek(xFilial("SC7")+TMP->C7_NUM)
	X := 1
	While !Eof() .And. C7_FILIAL == xFilial("SC7") .AND. C7_NUM == TMP->C7_NUM	   
	   If C7_QUJE==0 .AND. C7_QTDACLA==0 .and. C7_CONAPRO <> "B"                                                          
	   
	      cCond := "A"
	   Elseif C7_QUJE >= C7_QUANT
	      cCond := "E"
	   Elseif C7_QUJE <> 0 .AND. C7_QUJE < C7_QUANT
	      cCond := "L"
	   Elseif C7_CONAPRO == "B"
	      cCond := "B"
	   Endif
	   aAdd(aVetCAB,{cCond,C7_NUM,C7_EMISSAO,C7_FORNECE,C7_LOJA,C7_COND,C7_CONTATO,C7_FILENT,C7_MOEDA,C7_TXMOEDA,C7_XDEPART})
	   IF X == 1   
		   nTOTMERC	:= 0
		   nTOTFRET	:= 0
		   nTOTDESP	:= 0
		   nTOTDESC	:= 0
		   nTOTAL	:= 0
		   WHILE !EOF() .And. C7_FILIAL == xFilial("SC7") .AND. C7_NUM == TMP->C7_NUM
			 aAdd(aVetITE,{C7_ITEM,C7_PRODUTO,C7_DESCRI,C7_UM,C7_QUANT,C7_PRECO,C7_TOTAL,C7_OBS,C7_DATPRF,C7_LOCAL,C7_CC})     
		 
				nTOTMERC	+= C7_TOTAL
				nTOTFRET	+= C7_FRETE
				nTOTDESP	+= C7_DESPESA
				nTOTDESC	+= C7_VLDESC
				nTOTAL		+= C7_TOTAL+C7_FRETE+C7_DESPESA-C7_VLDESC
		   	 dbSkip()  
		   END
	   
	   ENDIF   
	   ++x
	End
	
	DBSELECTAREA("TMP")
	DBSKIP()
END

If Len(aVetCAB)==0
   Aviso(cTitulo,"Nao existe dados a consultar", {"Ok"} )
   Return
Endif

DEFINE MSDIALOG oDlg TITLE cTitulo FROM 0,0 TO 500,800 PIXEL

@ 14,3 TO  80,398 LABEL " Cabecalho do Pedido de Compra " OF oDlg PIXEL
@ 79,3 TO 155,398 LABEL " Item(ns) do Pedido de Compra "  OF oDlg PIXEL

@ 21,5 LISTBOX oLbx1 FIELDS HEADER "","Numero","Emissao","Fornecedor","Loja","C.Pagto","Contato","Fil Entrega","Moeda","Taxa","Departamento";
       SIZE 390,55 OF oDlg PIXEL ON CHANGE MudaLin(oLbx1:nAt)
       
oLbx1:SetArray(aVetcab)
oLbx1:bLine:={|| {Iif(aVetcab[oLbx1:nAt,1]=="A",oAberto,Iif(aVetcab[oLbx1:nAt,1]=="E",oEncerr,Iif(aVetcab[oLbx1:nAt,1]=="B",oBloq,oLibera))),;
					  aVetcab[oLbx1:nAt,2],aVetcab[oLbx1:nAt,3],aVetcab[oLbx1:nAt,4],;
					  aVetcab[oLbx1:nAt,5],aVetcab[oLbx1:nAt,6],aVetcab[oLbx1:nAt,7],;
					  aVetcab[oLbx1:nAt,8],aVetcab[oLbx1:nAt,9],aVetcab[oLbx1:nAt,10],;
                      aVetcab[oLbx1:nAt,11]}}

@ 86,5 LISTBOX oLbx2 FIELDS HEADER "Item","Produto","Descrição","Un","Quantidade","Unitario","Total     ","Observação","DT Entrega","Almox","C.Custo" SIZE 390,62 OF oDlg PIXEL
oLbx2:SetArray(aVetite)
oLbx2:bLine:={|| {aVetite[oLbx2:nAt,1],aVetite[oLbx2:nAt,2],aVetite[oLbx2:nAt,3],aVetite[oLbx2:nAt,4],; 
                  aVetite[oLbx2:nAt,5],aVetite[oLbx2:nAt,6],aVetite[oLbx2:nAt,7],aVetite[oLbx2:nAt,8],; 
				  aVetite[oLbx2:nAt,9],aVetite[oLbx2:nAt,10],aVetite[oLbx2:nAt,11]}} 
				  
				  
				  
@ 170,5 SAY  "Valor da Mercadoria: " SIZE 390,62 OF oDlg PIXEL				  
@ 185,5 SAY  "Valor do Frete: " SIZE 390,62 OF oDlg PIXEL				  
@ 200,5 SAY  "Valor da Despesas: " SIZE 390,62 OF oDlg PIXEL				  

@ 170,220 SAY  "Valor do Desconto: " SIZE 390,62 OF oDlg PIXEL				  
@ 200,220 SAY  "Valor Total: " SIZE 390,62 OF oDlg PIXEL				  


@ 170,65 msget oGETMERC VAR nTOTMERC picture "@e 999,999,999.99" WHEN .F. SIZE 080,10 OF oDlg PIXEL				  
@ 185,65 msget oGETFRET VAR nTOTFRET picture "@e 999,999,999.99" WHEN .F. SIZE 080,10 OF oDlg PIXEL				  
@ 200,65 msget oGETDESP VAR nTOTDESP picture "@e 999,999,999.99" WHEN .F. SIZE 080,10 OF oDlg PIXEL				  

@ 170,280 msget oGETDESC VAR nTOTDESC picture "@e 999,999,999.99" WHEN .F. SIZE 080,10 OF oDlg PIXEL				  
@ 200,280 msget oGETTOT VAR nTOTAL picture "@e 999,999,999.99" WHEN .F. SIZE 080,10 OF oDlg PIXEL				  

ACTIVATE MSDIALOG oDlg CENTER ON INIT EnchoiceBar(oDlg,{||oDlg:End()},{||oDlg:End()})

RestArea(aArea)

Return

Static Function MudaLin(nPos)

aVetite := {}

nTOTMERC	:= 0
nTOTFRET	:= 0
nTOTDESP	:= 0
nTOTDESC	:= 0
nTOTAL		:= 0

dbselectarea("sc7") 	 	
dbSetOrder(1)
dbSeek(xFilial("SC7")+aVetcab[nPos,2])

While !Eof() .And. C7_FILIAL+C7_NUM == xFilial("SC7")+aVetcab[nPos,2]
   aAdd(aVetITE,{C7_ITEM,C7_PRODUTO,C7_DESCRI,C7_UM,C7_QUANT,C7_PRECO,C7_TOTAL,C7_OBS,C7_DATPRF,C7_LOCAL,C7_CC})     
   
		nTOTMERC	+= C7_TOTAL
		nTOTFRET	+= C7_FRETE
		nTOTDESP	+= C7_DESPESA
		nTOTDESC	+= C7_VLDESC
		nTOTAL		+= C7_TOTAL+C7_FRETE+C7_DESPESA-C7_VLDESC
   
   
   dbSkip()
End
oLbx2:SetArray(aVetite)
oLbx2:bLine:={|| {aVetite[oLbx2:nAt,1],aVetite[oLbx2:nAt,2],aVetite[oLbx2:nAt,3],aVetite[oLbx2:nAt,4],; 
                  aVetite[oLbx2:nAt,5],aVetite[oLbx2:nAt,6],aVetite[oLbx2:nAt,7],aVetite[oLbx2:nAt,8],; 
				  aVetite[oLbx2:nAt,9],aVetite[oLbx2:nAt,10],aVetite[oLbx2:nAt,11]}} 

oLbx2:Refresh()

oGETMERC:REFRESH()
oGETFRET:REFRESH()
oGETDESP:REFRESH()
oGETDESC:REFRESH()
oGETTOT:REFRESH()


oDlg:Refresh()

Return