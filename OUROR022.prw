#INCLUDE "RWMAKE.CH"
#include "TbiConn.ch"
#include "TbiCode.ch"
#INCLUDE "AP5MAIL.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FONT.CH"
#include "topconn.ch"

//-------------------------------------------------------------------------------------
/*{Protheus.doc} PCLUXTMS
@Programa - Gera o Pedido de Compra Internacional - Proforma conforme Model Utilizado OUROLUX
            Sera gerado com base na Informagco da tabela SW2 x SW3 (PO Mod. EEI)

@Solicitante Carlos Saheli / Fernando Medeiros 
@author 	Rogerio Silva / Introde
@since 		16/09/2020
@version 	P12
Validado    Matheus / Supplly2 - Data 09/10/2020

DOCUMENTACAO:
01 - Criagco de Campos
- SW2->W2_XLOTENR - Tipo C - 10  - Numero do Lote
- SW2->W2_XMSGPRO - Tipo C - 240 - Obs Product
- SW2->W2_XMSGPAC - Tipo C - 240 - Obs Packging
- SW2->W2_XPROGPO - Tipo C - 10  - Programac PO

02 - Criar os Parametros:
GetMv("ES_MSGPO01")	//MENSAGEM LINHA 01 - PROFORMA
GetMv("ES_MSGPO02")	//MENSAGEM LINHA 02 - PROFORMA
GetMv("ES_MSGPO03")	//MENSAGEM LINHA 03 - PROFORMA
GetMv("ES_MSGPO04")	//MENSAGEM LINHA 04 - PROFORMA
GetMv("ES_MSGPO05")	//MENSAGEM LINHA 05 - PROFORMA
GetMv("ES_MSGPO06")	//MENSAGEM LINHA 06 - PROFORMA
GetMv("ES_MSGPO07")	//MENSAGEM LINHA 07 - PROFORMA
GetMv("ES_MSGPO08")	//MENSAGEM LINHA 08 - PROFORMA
GetMv("ES_MSGPO09")	//MENSAGEM LINHA 09 - PROFORMA
GetMv("ES_MSGPO10")	//MENSAGEM LINHA 10 - PROFORMA
GetMv("ES_MSGPO11")	//MENSAGEM LINHA 11 - PROFORMA
GetMv("ES_MSGPO12")	//MENSAGEM LINHA 12 - PROFORMA
GetMv("ES_MSGPO13")	//MENSAGEM LINHA 13 - PROFORMA
GetMv("ES_MSGPO14")	//MENSAGEM LINHA 14 - PROFORMA
GetMv("ES_LOGOASS")	//Logo da Assinatura PO
*/    
//-------------------------------------------------------------------------------------

User Function OUROR022()
 
//ZDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD?
//3 Declaracao de Variaveis                                             3
//@DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDY
LOCAL oDlg 		:= NIL
PRIVATE titulo 	:= ""
PRIVATE nLastKey:= 0
PRIVATE cPerg	:= "EI252B" 		//Pergunta Padrco do Sistema
PRIVATE nomeProg:= FunName()
Private nTotal	:= nQtdTOT := 0
Private nSubTot	:= 0

//ZDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD?
//3 Variaveis utilizadas para parametros					  		3
//3 mv_par01				// Numero da PO                   		3
//@DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDY
wnrel := FunName()            //Nome Default do relatorio em Disco
 
PRIVATE cTitulo := "Impressco da PO - Proforma....."
PRIVATE oPrn    := NIL
PRIVATE oFont1  := NIL
PRIVATE oFont2  := NIL
PRIVATE oFont3  := NIL
PRIVATE oFont4  := NIL
PRIVATE oFont5  := NIL
PRIVATE oFont6  := NIL
//Private nLastKey:= 0
Private nLin    := 1650 // Linha de inicio da impressao das clausulas contratuais
Private cColDir := 2330	// Ultima Coluna Grafica a Direta 2470	-2440
Private cLinEnd := 3390	// Ultima Linha do Modelo Grafico 3490

//FONTE DE Impressao do Relatorio
DEFINE FONT oFont1 NAME "Times New Roman" SIZE 0,20 BOLD  OF oPrn
DEFINE FONT oFont2 NAME "Times New Roman" SIZE 0,14 BOLD OF oPrn
DEFINE FONT oFont3 NAME "Times New Roman" SIZE 0,14 OF oPrn
DEFINE FONT oFont4 NAME "Times New Roman" SIZE 0,14 ITALIC OF oPrn
DEFINE FONT oFont5 NAME "Times New Roman" SIZE 0,14 OF oPrn
DEFINE FONT oFont6 NAME "Courier New" BOLD
 
oFont07N := TFont():New("Arial",07,07,,.T.,,,,.T.,.F.)
oFont08	 := TFont():New("Arial",06,06,,.F.,,,,.T.,.F.)
oFont08N := TFont():New("Arial",08,08,,.T.,,,,.T.,.F.)
oFont10	 := TFont():New("Arial",10,10,,.F.,,,,.T.,.F.)
oFont11  := TFont():New("Arial",11,11,,.F.,,,,.T.,.F.)
oFont14	 := TFont():New("Arial",14,14,,.F.,,,,.T.,.F.)
oFont16	 := TFont():New("Arial",16,16,,.F.,,,,.T.,.F.)
oFont10N := TFont():New("Arial",10,10,,.T.,,,,.T.,.F.)
oFont12  := TFont():New("Arial",10,10,,.F.,,,,.T.,.F.)
oFont12N := TFont():New("Arial",10,10,,.T.,,,,.T.,.F.)
oFont16N := TFont():New("Arial",16,16,,.T.,,,,.T.,.F.)
oFont14N := TFont():New("Arial",14,14,,.T.,,,,.T.,.F.)
oFont06	 := TFont():New("Arial",05,05,,.F.,,,,.T.,.F.)
oFont06N := TFont():New("Arial",05,05,,.T.,,,,.T.,.F.)


//ZDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD?
//3 Tela de Entrada de Dados - Parametros                        3
//@DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDY
nLastKey  := IIf(LastKey() == 27,27,nLastKey)
 

If nLastKey == 27
	Return
Endif
 
//ZDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD?
//3 Inicio do lay-out / impressao                                3
//@DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDY
oPrn:= TMSPrinter():New(cTitulo)
oPrn:SetPaperSize(DMPAPER_A4)
oPrn:Setup()
oPrn:SetPortrait() //SetLansCape()
oPrn:StartPage()
Imprimir()
oPrn:EndPage()
oPrn:End()


//TELA DE IMPRESSAO PARA USUARIO
DEFINE MSDIALOG oDlg FROM 264,182 TO 441,613 TITLE cTitulo OF oDlg PIXEL
@ 004,010 TO 082,157 LABEL "" OF oDlg PIXEL
 
@ 015,017 SAY "Esta rotina tem por objetivo imprimir."	OF oDlg PIXEL Size 150,010 FONT oFont6 COLOR CLR_HBLUE
@ 030,017 SAY "Modelo do impresso customizado:"			OF oDlg PIXEL Size 150,010 FONT oFont6 COLOR CLR_HBLUE
@ 045,017 SAY ">>  PROFORMA INVOICE " 				OF oDlg PIXEL Size 150,010 FONT oFont6 COLOR CLR_HBLUE
 
@ 06,167 BUTTON "&Imprime" 		SIZE 036,012 ACTION oPrn:Print()   	OF oDlg PIXEL
@ 28,167 BUTTON "Pre&view" 		SIZE 036,012 ACTION oPrn:Preview() 	OF oDlg PIXEL
@ 49,167 BUTTON "Sai&r"    		SIZE 036,012 ACTION oDlg:End()     	OF oDlg PIXEL
 
ACTIVATE MSDIALOG oDlg CENTERED
 
oPrn:End()

Return
 
/*/
_____________________________________________________________________________
&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
&&+-----------------------------------------------------------------------+&&
&&&Descrig`o & Impressao Pedido de Compras   					          &&&
&&+----------+------------------------------------------------------------&&&
&&+-----------------------------------------------------------------------+&&
&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
/////////////////////////////////////////////////////////////////////////////
/*/
STATIC FUNCTION Imprimir()
PO_EEI()
Ms_Flush()
Return
 
/*/
_____________________________________________________________________________
&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
&&+-----------------------------------------------------------------------+&&
&&&Descrig`o & Impressao 										          &&&
&&+----------+------------------------------------------------------------&&&
&&+-----------------------------------------------------------------------+&&
&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
/////////////////////////////////////////////////////////////////////////////
/*/                    
                
STATIC FUNCTION PO_EEI()

Private lSaltaPG := .F.		//Variavel Salto de Pagina
Private lSaltaP2 := .F.
Private nPage	 := "00"

//Criar os Parametros no CFG para Mensagem FIXA da PO
Private cMsgFx01 := GetMv("ES_MSGPO01")	//MENSAGEM LINHA 01 - PROFORMA                      
Private cMsgFx02 := GetMv("ES_MSGPO02")	//MENSAGEM LINHA 02 - PROFORMA                      
Private cMsgFx03 := GetMv("ES_MSGPO03")	//MENSAGEM LINHA 03 - PROFORMA                      
Private cMsgFx04 := GetMv("ES_MSGPO04")	//MENSAGEM LINHA 04 - PROFORMA                      
Private cMsgFx05 := GetMv("ES_MSGPO05")	//MENSAGEM LINHA 05 - PROFORMA                      
Private cMsgFx06 := GetMv("ES_MSGPO06")	//MENSAGEM LINHA 06 - PROFORMA                      
Private cMsgFx07 := GetMv("ES_MSGPO07")	//MENSAGEM LINHA 07 - PROFORMA                      
Private cMsgFx08 := GetMv("ES_MSGPO08")	//MENSAGEM LINHA 08 - PROFORMA                      
Private cMsgFx09 := GetMv("ES_MSGPO09")	//MENSAGEM LINHA 09 - PROFORMA                      
Private cMsgFx10 := GetMv("ES_MSGPO10")	//MENSAGEM LINHA 10 - PROFORMA                      
Private cMsgFx11 := GetMv("ES_MSGPO11")	//MENSAGEM LINHA 11 - PROFORMA                      
Private cMsgFx12 := GetMv("ES_MSGPO12")	//MENSAGEM LINHA 12 - PROFORMA                      
Private cMsgFx13 := GetMv("ES_MSGPO13")	//MENSAGEM LINHA 13 - PROFORMA                      
Private cMsgFx14 := GetMv("ES_MSGPO14")	//MENSAGEM LINHA 14 - PROFORMA  
Private cAssAprov:= GetMv("ES_LOGOASS")	//Logo da Assinatura - //Solicitação Carlos Saheli - Data 20/11/2020 - Autor Andre Salgado                  

//Pagina 1
	oPrn:StartPage()
	cBitMap  := "Lgrl01.Bmp"		//Logo da Empresa na parte Superior da Folha
	oPrn:SayBitmap(0035,0105,cBitMap,0400,0150)			// Imprime logo da Empresa: comprimento X altura

	//FORGA PERGUNTA PARA USUARIO 
	If ! Pergunte(cPerg,.T.)  
		Return
	Endif       

	//SW3 - Item da PO
	dbSelectArea("SW3")
	dbSetOrder(01)

	if ! dbSeek(xFilial("SW3")+mv_par01)
		alert('PEDIDO NAO LOCALIZADO !')
	endif

	//SW2 - Cabegalho
	dbSelectArea("SW2")
	dbSetOrder(01)
	dbSeek(xFilial("SW2")+mv_par01)
	//SWB
	dbSelectArea("SWB")
	dbSetOrder(01)
	dbSeek(xFilial("SWB")+mv_par01)

	//Data da PO
	cDia 	:= SubStr(DtoS(SW2->W2_PO_DT),7,2)
	cMes 	:= SubStr(DtoS(SW2->W2_PO_DT),5,2)
	cAno 	:= SubStr(DtoS(SW2->W2_PO_DT),1,4)
	cMesExt := MesExtenso(Month(SW2->W2_PO_DT))
	cDataImpressao := cAno+" / "+cMes+" / "+cDia //cDia+" de "+cMesExt+" de "+cAno

	cOrigPort := TRIM(Posicione("SY9",2,xFilial("SY9")+SW2->W2_ORIGEM,"Y9_DESCR"))	//Porto Origem
	cDestPort := TRIM(Posicione("SY9",2,xFilial("SY9")+SW2->W2_DEST	 ,"Y9_DESCR"))	//Porto Destino
	cIncoter  := SW2->W2_INCOTER		//Incoterme
	cMoedaPO  := TRIM(SW2->W2_MOEDA)	//Moeda utilizada no Pedido
	dETDpo    := SW2->W2_XDT_ETD		//ETD
	dETApo    := SW2->W2_XDT_ETA		//ETA

	//Criar os campos - SW2
	cLOTENR	  := if(Empty(SW2->W2_XLOTENR),mv_par01,SW2->W2_XLOTENR)//Numero do Lote
	cProduOBS := trim(SW2->W2_XMSGPRO)								//Observacao Product
	cPackOBS  := trim(SW2->W2_XMSGPAC)								//Observacao Packging
	cProgrPO  := trim(SW2->W2_XPROGPO)								//Programacao da PO


	// Rogerio - adicionado o valor do ADI
	//cMenCondPG:= IIF(SWB->WB_PGTANT>0,'Payment: '+ Transform(SWB->WB_PGTANT,"@E 9,999,999.99")+' - ',' ') +MSMM(POSICIONE("SY6",1,xFilial("SY6")+SW2->W2_COND_PA,"Y6_DESC_I"),80)
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

	// Quadros verticais
	oPrn:Box(0030,0030,cLinEnd,cColDir) 	//Borda do Logo e Titulo "PROFORMA INVOICE"
	oPrn:Box(0030,0595,0186,0595) 			//Borda entre Logo e Titulo

	oPrn:Box(0186,0030,cLinEnd,cColDir) 	//Borda abaixo do Logo e Titulo
	oPrn:Box(0186,0800,0523,0800) 			//Borda entre "Exporter" e "Manufacter"
	oPrn:Box(0186,1600,0523,1600) 			//Borda entre "Manufacter" e "Banking Information"
	//..oPrn:Box(0523,0030,cLinEnd,cColDir)
	oPrn:Box(0523,0030,0523,cColDir) 		//Borda abaixo do "Exporter" e "Manufacter" e "Banking Information"
	oPrn:Box(0523,0595,0872,0595) 			//Borda da esquerda do "Consignee/Importer"
	oPrn:Box(0523,1600,0872,1600) 			//Borda entre "Consignee/Importer" e "Notify/Buyer"
	//..oPrn:Box(0872,0030,cLinEnd,cColDir) 
	oPrn:Box(0872,0030,0872,cColDir) 	  	//Borda abaixo de " " e "Consignee/Importer" e "Notify/Buyer"
	oPrn:Box(0872,0090,1781,0090) 			//Borda entre "Seq" e "Cod"
	oPrn:Box(0872,0270,1868,0270) 			//Borda entre "Cod" e "Qty Pieces"
	oPrn:Box(0872,0460,1868,0460) 			//Borda entre "Qty Pieces"e "Description"
	oPrn:Box(0872,1065,1868,1065) 			//Borda entre "Description" e "NCM"
	oPrn:Box(0872,1190,1868,1190) 			//Borda entre "NCM" e "CBM(M3)"
	oPrn:Box(0872,1355,1868,1355) 			//Borda entre "BCM(M3)" e "Qty Boxes"
	oPrn:Box(0872,1510,1868,1510) 			//Borda entre "Qty Boxes" e "Net Weight"
	oPrn:Box(0872,1700,1868,1700) 			//Borda entre "Net Weight" e "Gross Weight"
	oPrn:Box(0872,1895,1868,1895) 			//Borda entre "Gross Weight" e "Price Per Unit"
	oPrn:Box(0872,2115,1868,2115) 			//Borda entre "Price Per Unit" e "Total Price"
	//..oPrn:Box(0946,0030,cLinEnd,cColDir)
	oPrn:Box(1781,0030,cLinEnd,cColDir)		//Borda abaixo das colunas dos Itens e acima do Total
	oPrn:Box(1868,0030,cLinEnd,cColDir) 	//Borda abaixo do Total e acima do Cargo Data
	oPrn:Box(1930,0030,1930,1844) 			//Borda abaixo do Cargo Data
	oPrn:Box(1930,0298,2128,0298) 			//Borda da direta do "ETD" e "ETA"
	oPrn:Box(1930,0773,2377,0773)			//Borda da esquerda do "Country of Origin" e "Acquisition Procedence" e "Way of Transportation SEA" e "Purchase Order"
	oPrn:Box(1930,1130,2128,1130)			//Borda da direita do "Country of Origin" e "Acquisition Procedence"
	oPrn:Box(1930,1487,2253,1487)			//Borda da esqueda do "Total FOB" e "Insurance" e "Total"
	oPrn:Box(1868,1844,2253,1844)   		//Borda da direita do "Cargo Data" e "Total FOB" e "Insurance" e "Total"
	oPrn:Box(2029,0030,cLinEnd,cColDir)		//Borda abaixo do "ETD" e "Country of Origin" e "Total FOB"
	oPrn:Box(2128,0030,cLinEnd,cColDir)		//Borda abaixo do "ETA" e "Acquisition Procedence" e "Insurance" e " "
	oPrn:Box(2253,0030,cLinEnd,cColDir)		//Borda acima do "Port/Airport of Destination" e "Purchase Order" e "LOT NR" e "INCOTERM" e "FOB"
	oPrn:Box(2253,1250,2377,1250)			//Borda entre "Purchase Order" e "Lot NR"
	oPrn:Box(2253,1663,2377,1663)			//Borda entre "Lot NR" e "Incoterm"
	oPrn:Box(2253,2249,2377,2249)			//Borda entre "Incoterm" e "FOB"
	oPrn:Box(2377,0030,cLinEnd,cColDir)		//Borda acima do "Payment Condition"
	oPrn:Box(2432,0030,2422+10,cColDir) 	//Borda abaixo do "Payment Condition"
	oPrn:Box(2500,0030,cLinEnd,cColDir)		//Borda abaixo do "Delivery Time"
	oPrn:Box(2710,0030,2710,cColDir )		//Borda abaixo do "Fines" e "Quality"
	oPrn:Box(2825,0030,2825,cColDir)		//Borda abaixo do "Inspections
	oPrn:Box(2500,0230,2710,0230)			//Borda da direita "Fines"
	oPrn:Box(2500,0440,3300,0440) 			//Borda da direita do "Delivery" e "Quality" e "Inspections" e "Genaral Terms"
	oPrn:Box(2625,0230,2625,cColDir) 		//Borda abaixo do "Delivery" e "texto do Delivery"
	oPrn:Box(2925,0030,2925,cColDir)		//Borda abaixo do "General Terms" e "texto do General"
	oPrn:Box(3112,0440,3112,cColDir)		//Borda entre "Product Data Sheet" e "Packaging Data Sheet"
	oPrn:Box(3300,0030,cLinEnd,cColDir) 	//Borda da Assinatura
	oPrn:Box(3300,1200,cLinEnd,1200)		//Borda entre as Assinaturas 
	//..oPrn:Box(2625,0300,2625,cColDir) //meia
	//	..oPrn:Box(3410,0030,3700,2500)
	// fim verticais

	dataHora:=Time() 
	nlin 	:= 0035
	oPrn:Say(nLin,0035,OemToAnsi(''),oFont08)	
	oPrn:Say(0095-20,1200, "PROFORMA INVOICE",oFont14N) 
 
	oPrn:Say(0190,0045, "EXPORTER",oFont08N)
	DBSELECTAREA('SA2')
	if dbseek(XFILIAL('SA2')+SW3->W3_FORN)
		oPrn:Say(0250,0045,OemToAnsi(SA2->A2_NOME),oFont08)
		oPrn:Say(0300,0045,OemToAnsi(SA2->A2_END),oFont08)
		oPrn:Say(0350,0045,OemToAnsi(SA2->A2_BAIRRO),oFont08)
		//oPrn:Say(0350,0045,OemToAnsi(SA2->A2_MUN)+' '+SA2->A2_EST,oFont08)
		//oPrn:Say(0400,0045,OemToAnsi(SA2->A2_CEP),oFont08)
	ENDIF

	oPrn:Say(0190,1615, "BANKING INFORMATION ",oFont08N)
	DBSELECTAREA('SA2')
	if dbseek(XFILIAL('SA2')+SW3->W3_FORN)
		oPrn:Say(0300-60,1615,"BENEFICIARY BANK: "+TRIM(SA2->A2_XBANCO),oFont08)
		oPrn:Say(0340-60,1615,"SWIFT CODE: "+TRIM(SA2->A2_SWIFT)	,oFont08)
		oPrn:Say(0380-60,1615,TRIM(SA2->A2_XENDBAN)					,oFont08)
		oPrn:Say(0420-60,1615,"BENEFICIARY CUSTOMER: "				,oFont08)
		oPrn:Say(0460-60,1615,OemToAnsi(SA2->A2_NOME)				,oFont08)
		oPrn:Say(0500-60,1615,"ACCOUNT NO: "+TRIM(SA2->A2_XCTABAN)	,oFont08)
	ENDIF

	DBSELECTAREA('SW3')
	oPrn:Say(0190,0815, "MANUFACTURER",oFont08N)
	DBSELECTAREA('SA2')
	if dbseek(XFILIAL('SA2')+SW3->W3_FABR)
		oPrn:Say(0250,0815,OemToAnsi(SA2->A2_NOME),oFont08)
		oPrn:Say(0300,0815,OemToAnsi(SA2->A2_END),oFont08)
		oPrn:Say(0350,0815,OemToAnsi(SA2->A2_BAIRRO),oFont08)
		//oPrn:Say(0350,0815,OemToAnsi(SA2->A2_MUN)+' '+SA2->A2_EST,oFont08)
		//oPrn:Say(0400,0815,OemToAnsi(SA2->A2_CEP),oFont08)
	ENDIF

	DBSELECTAREA('SW3')
	oPrn:Say(0530,0035,OemToAnsi(''),oFont08)	
	oPrn:Say(0530,0610, "CONSIGNEE/IMPORTER"			,oFont08N)
	oPrn:Say(0580,0610,OemToAnsi(cNomImp)			,oFont08)
	oPrn:Say(0630,0610,OemToAnsi(cEndImp)			,oFont08)
	oPrn:Say(0680,0610,OemToAnsi(cMunImp+' - Brasil'),oFont08)
	oPrn:Say(0730,0610,OemToAnsi(cCEPImp)			,oFont08)
	oPrn:Say(0780,0610,OemToAnsi(cTELImp)			,oFont08)
	oPrn:Say(0830,0610,OemToAnsi(cCNPJImp)			,oFont08)

	oPrn:Say(0530,1615, "NOTIFY/BUYER",oFont08N)
	oPrn:Say(0580,1615,OemToAnsi(cNomImp)			,oFont08)
	oPrn:Say(0630,1615,OemToAnsi(cEndImp)			,oFont08)
	oPrn:Say(0680,1615,OemToAnsi(cMunImp+' - Brasil'),oFont08)
	oPrn:Say(0730,1615,OemToAnsi(cCEPImp)			,oFont08)
	oPrn:Say(0780,1615,OemToAnsi(cTELImp)			,oFont08)
	oPrn:Say(0830,1615,OemToAnsi(cCNPJImp)			,oFont08)
	oPrn:Say(0120,1800, "ISSUE DATE: "+cDataImpressao,oFont08)
	nPage := SOMA1(nPage)
	oPrn:Say(0150,1800, "PAGE : "+nPage				,oFont08)

	//Cabecalho dos Itens        
		nlin := 0886
		oPrn:Say(nLin,0040,OemToAnsi('SEQ')			,oFont08)
		oPrn:Say(nLin,0105,OemToAnsi('CODE')		,oFont08)
		oPrn:Say(nLin,0285,OemToAnsi('QTY PIECES')	,oFont08)
		oPrn:Say(nLin,0475,OemToAnsi('DESCRIPTION')	,oFont08)
		oPrn:Say(nLin,1080,OemToAnsi('NCM')			,oFont08)
		oPrn:Say(nLin,1205,OemToAnsi('CBM(M3)')		,oFont08)
		oPrn:Say(nLin,1370,OemToAnsi('QTY BOXES')	,oFont08)
		oPrn:Say(nLin,1525,OemToAnsi('NET WEIGHT')	,oFont08)
		oPrn:Say(nLin,1715,OemToAnsi('GROSS WEIGHT'),oFont08)
		oPrn:Say(nLin,1910,OemToAnsi('PRICE PER UNIT'),oFont08)
		oPrn:Say(nLin,2130,OemToAnsi('TOTAL PRICE')	,oFont08)  //1910
		
		mv_par01:= sw3->w3_po_num 
		nLin    :=0950 //0960  
		nTotal  := nCbm := nBoxes := nWeight := nCross := 0

		While !Eof() .And. w3_po_num == mv_par01
			SB1->(DBSEEK(XFILIAL('SB1')+(SW3->W3_COD_I)))

			//Busca os Itens com Dados NCM
			if empty(SW3->W3_TEC)
				SW3->(DbSkip())
				Loop
			Endif

			if SW3->W3_SEQ=1
				SW3->(DbSkip())
				Loop
			Endif

			//Limite de Itens por PO - Maximo "021" por pagina (teste validado na Impressa Microsfot PDF).
			IF strzero(SW3->W3_NR_CONT,3)>="022"
				lSaltaPG := .T.
				SW3->(DbSkip())
				Loop
			Endif

			cDescLI := MSMM(SB1->B1_DESC_I,40)			//Descricao em Ingles
			cDescLI := IF( EMPTY(cDescLI), SB1->B1_DESC, cDescLI)

			cDescLI := SubStr(cDescLI,1,50)

			oPrn:Say(nLin,0045,OemToAnsi(strzero(SW3->W3_NR_CONT,3))				,oFont08) 		//COLUNA SEQ
			oPrn:Say(nLin,0105,OemToAnsi(SW3->W3_COD_I)								,oFont08) 		//COLUNA CODE
			oPrn:Say(nLin,0445,OemToAnsi(Transform(SW3->W3_QTDE,"@E 999,999,999.999"))	,oFont08,,,,1) 	//COLUNA QTY PIECES
			oPrn:Say(nLin,0475,OemToAnsi(cDescLI)									,oFont08)		//COLUNA DESCRIPTION
			oPrn:Say(nLin,1080,OemToAnsi(SW3->W3_TEC)								,oFont08)		//COLUBA NCM
			
			IF SW3->W3_XCUBAGE > 0
				oPrn:Say(nLin,1340,OemToAnsi(Transform(SW3->W3_XCUBAGE,"@E 999,999.9999"))		,oFont08,,,,1)	//COLUNA CBM(M3).
			ENDIF
			IF SW3->W3_XQTDEM1 > 0
				oPrn:Say(nLin,1495,OemToAnsi(Transform(SW3->W3_XQTDEM1	,"@E 9999999999"))			,oFont08,,,,1) //COLUNA QTY BOXES
			ENDIF
			IF SW3->W3_PESOL > 0
				oPrn:Say(nLin,1685,OemToAnsi(Transform(SW3->W3_QTDE * SW3->W3_PESOL	,"@E 999,999.999999"))	,oFont08,,,,1) //COLUNA NET WEIGHT
			endif
			IF SW3->W3_PESO_BR > 0
				oPrn:Say(nLin,1880,OemToAnsi(Transform(SW3->W3_QTDE * SW3->W3_PESO_BR	,"@E 999,999.999999"))	,oFont08,,,,1) //COLUNA GROSS WEIGHT
			endif

			oPrn:Say(nLin,2100,OemToAnsi(Transform(SW3->W3_PRECO	,"@E 999,999,999.99999"))	,oFont08,,,,1)  //COLUNA PRICE PER UNIT
			oPrn:Say(nLin,2320,OemToAnsi(Transform(SW3->W3_QTDE * SW3->W3_PRECO,"@E 999,999,999.99999")),oFont08,,,,1) //COLUNA TOTAL PRICE
			
			
			nTotal	+= (SW3->W3_QTDE * SW3->W3_PRECO)	//Valor Total
			nCbm	+= SW3->W3_XCUBAGE					//cubagem
			nBoxes	+= SW3->W3_XQTDEM1					//Caixas
			nWeight	+= (SW3->W3_QTDE * SW3->W3_PESOL)	//Peso Liquido
			nCross	+= (SW3->W3_QTDE * SW3->W3_PESO_BR) //Peso Bruto
			nQtdTOT += SW3->W3_QTDE						//Quantidade Total

			nLin+=0040 			//Salto de Linha.
			dbSelectArea("SW3")
			dbSkip()
		
		EndDo

	    nlin := 1830
		oPrn:Say(nLin,0050,OemToAnsi('TOTAL')								,oFont08N)
		oPrn:Say(nLin,0445,OemToAnsi(/*STR(*/if(!lSaltaPG,Transform(nQtdTOT,"@E 999,999,999.999"),"0")/*,14)*/)		,oFont08,,,,1)
		oPrn:Say(nLin,0495,OemToAnsi('SCHEDULED ORDER (X  OF  Y)')		,oFont08N)
		oPrn:Say(nLin,1070,OemToAnsi(cProgrPO)									,oFont08N)
		
		//oPrn:Say(nLin,1340,OemToAnsi(STR(if(!lSaltaPG,nCbm,0),14,2))			,oFont08,,,,1)
		//oPrn:Say(nLin,1495,OemToAnsi(STR(if(!lSaltaPG,nboxes,0),14,2))		,oFont08,,,,1)
		oPrn:Say(nLin,1340,OemToAnsi(/*STR(*/if(!lSaltaPG,Transform(nCbm,"@E 9,999,999.99"),"0")/*,14,2)*/)			,oFont08,,,,1)
		oPrn:Say(nLin,1495,OemToAnsi(/*STR(*/if(!lSaltaPG,Transform(nboxes,"@E 9,999,999.99"),"0")/*,14,2)*/)		,oFont08,,,,1)
		oPrn:Say(nLin,1685,OemToAnsi(Transform(if(!lSaltaPG,nweight,0),"@E 9,999,999.99")),oFont08,,,,1)
		oPrn:Say(nLin,1880,OemToAnsi(Transform(if(!lSaltaPG,ncross,0),"@E 9,999,999.99")),oFont08,,,,1)
		
		oPrn:Say(nLin,1989-15,OemToAnsi('')							,oFont08)
		oPrn:Say(nLin,2130,OemToAnsi(cMoedaPO)			,oFont08)
		oPrn:Say(nLin,2320,OemToAnsi(Transform(if(!lSaltaPG,ntotal,0),"@E 9,999,999.99")),oFont08,,,,1)  //180-50-12-15-20
	
		oPrn:Say(1880,0538,OemToAnsi('CARGO DATA')					,oFont08N)  
		oPrn:Say(1930,1510,OemToAnsi('TOTAL FOB')					,oFont10N)
		oPrn:Say(1930,1910,OemToAnsi(cMoedaPO)						,oFont08N)
		oPrn:Say(1930,2320,OemToAnsi(Transform(if(!lSaltaPG,ntotal,0),"@E 9,999,999.99")),oFont10N,,,,1)  
		oPrn:Say(1980,1510,OemToAnsi('INTERNACIONAL FREIGHT')		,oFont08)
		oPrn:Say(2080,1510,OemToAnsi('INSURANCE')					,oFont08N)
		oPrn:Say(1955,0050,OemToAnsi('ETD')							,oFont08N)
		oPrn:Say(1955+40,0048,OemToAnsi('(ON BOARD)')				,oFont08)

		IF !Empty(dETDpo)
			oPrn:Say(1955,0400,Day2Str(dETDpo)+" - "+left(cMonth(dETDpo),3)+" - "+Year2Str(dETDpo),oFont08N)
		Endif

		oPrn:Say(1955,0800,OemToAnsi('COUNTRY OF ORIGIN')			,oFont08N) 
		oPrn:Say(1956,1159,OemToAnsi(cPaisForD)						,oFont08)	
	
		oPrn:Say(2055,0050,OemToAnsi('ETA')							,oFont08N)
		if !Empty(dETApo)
			oPrn:Say(2055,0400,Day2Str(dETApo)+" - "+left(cMonth(dETApo),3)+" - "+Year2Str(dETApo),oFont08N)
		Endif

		oPrn:Say(2030+15,0800,OemToAnsi('ACQUISITION')				,oFont08N) 
		oPrn:Say(2100-15,0800,OemToAnsi('PROCEDENCE')				,oFont08N)	
		oPrn:Say(2100-15,1159,OemToAnsi(cPaisForD)					,oFont08)	
		oPrn:Say(2135,0050,OemToAnsi('PORT/AIRPORT OF ORIGIN:')		,oFont08N) //0180
		oPrn:Say(2175,0050,OemToAnsi(cOrigPort)						,oFont08N) //0180
		oPrn:Say(2135,0800,OemToAnsi('WAY OF TRANSPORTATION:')		,oFont08N) //0872
		oPrn:Say(2175,0800,OemToAnsi('SEA')							,oFont08N) //0872
		oPrn:Say(2170,1510,OemToAnsi('TOTAL')						,oFont08N)
		oPrn:Say(2170,1910,OemToAnsi(cMoedaPO)						,oFont08N)
		oPrn:Say(2170,2320,OemToAnsi(Transform(if(!lSaltaPG,ntotal,0),"@E 9,999,999.99")),oFont10N,,,,1)  
		oPrn:Say(2260,0050,OemToAnsi('PORT/AIRPORT OF DESTINATION:')	,oFont08N)//0180
		oPrn:Say(2300,0050,OemToAnsi(cDestPort)						,oFont08N)//0180
		oPrn:Say(2260,0800,OemToAnsi('PURCHASE ORDER')				,oFont08N)   
		oPrn:Say(2300,0800,OemToAnsi(MV_PAR01)						,oFont14) //SW3->W3_PO_NUM
		oPrn:Say(2260,1280,OemToAnsi('LOT NR')						,oFont08N)   
		oPrn:Say(2300,1280,OemToAnsi(cLOTENR)						,oFont10N) //SW3->W3_PO_NUM
		oPrn:Say(2290,1680,OemToAnsi('INCOTERM')					,oFont08N)    
		oPrn:Say(2290,2260,OemToAnsi(cIncoter)						,oFont08N)    
	
		//Demonstra valores conforme ao Condigco de Pagamento
		//aParc  := Condicao(ntotal,SW2->W2_COND_PA,,dDataBase)
		cMenVLR:= ""
		//FOR nSE4 := 1 TO Len( aParc )
		//	cMenVLR += " | "+cMoedaPO+" "+Transform(aParc[nSE4,2],"@E 9,999,999.99")
		//NEXT

		IF !lSaltaPG
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
		Endif

		oPrn:Say(2387,0050, "PAYMENT CONDITION"					,oFont10N)  
		oPrn:Say(2387,0595-075, trim(cMenCondPG)+cMenVLR			,oFont10)  	//0595

		// INFORMACOES POLITICAS - FIXAS   
		//Criar PARAMETROS NO CFG destas Mensagem do Pedido ...
		oPrn:Say(2439,0050, "DELIVERY TIME",oFont08n)
		oPrn:Say(2462,0050, "(Approval of PSI)",oFont08n)
		oPrn:Say(2457,0300,cMsgFx01 ,oFont08)	
		oPrn:Say(2510,0455, cMsgFx02,oFont07N)
		oPrn:Say(2535,0455, cMsgFx03,oFont07N)
		oPrn:Say(2560,0455, cMsgFx04,oFont07N)
		oPrn:Say(2585,0455, cMsgFx05,oFont07N)
		oPrn:Say(2625,0455, cMsgFx06,oFont07N)//
		oPrn:Say(2650,0455, cMsgFx07,oFont07N)//
		oPrn:Say(2675,0455, cMsgFx08,oFont07N)//
		oPrn:Say(2720,0455, cMsgFx09,oFont07N)  
 		oPrn:Say(2745,0455, cMsgFx10,oFont07N)  
 		oPrn:Say(2770,0455, cMsgFx11,oFont07N)  
 		oPrn:Say(2795,0455, cMsgFx12,oFont07N)  
		oPrn:Say(2850,0455, cMsgFx13,oFont07N)  
 		oPrn:Say(2875,0455, cMsgFx14,oFont07N)  

		OPRN:SAY(2585,0050, " FINES"						,oFont08N)  
		OPRN:SAY(2520,0255, " DELIVERY "					,oFont08N)  
		OPRN:SAY(2650,0255, " QUALITY"						,oFont08N)  
		OPRN:SAY(2770,0050, " INSPECTIONS"					,oFont08N)  
		OPRN:SAY(2862,0050, " GENERAL TERMS"				,oFont08N)  

		OPRN:SAY(2950,0050, " TECHNICAL INFO:"				,OFONT08n)  
		OPRN:SAY(3000,0050, " (SUPPLIER MUST ATTEND ALL "	,OFONT08)  
		OPRN:SAY(3035,0050, " REQUIREMENTS ACCORDING"		,OFONT08)  
		OPRN:SAY(3070,0050, " TO THE PRODUCT DATA SHEET  "	,OFONT08)  
		OPRN:SAY(3105,0050, " AND PRODUCT PACKAGE/ARTWORK "	,OFONT08)  
		OPRN:SAY(3140,0050, " DATA SHEET,"					,OFONT08)  
		OPRN:SAY(3175,0050, " MENTIONED IN THIS DOCUMENT.)"	,OFONT08)  
		OPRN:SAY(2935,1000, " PRODUCT DATA SHEET"			,OFONT08)  
		
		If Len(cProduOBS) <= 170
			OPRN:SAY(2985,0455, cProduOBS						,OFONT08)  
		else
			OPRN:SAY(2985,0455, SubStr(cProduOBS,1,170)			,OFONT08)  
			OPRN:SAY(3015,0455, SubStr(cProduOBS,171,70)		,OFONT08)  
		EndIf
		
		OPRN:SAY(3122,1000, " PACKAGING DATA SHEET"			,OFONT08)  
		
		If Len(cPackOBS) <= 170
			OPRN:SAY(3172,0455, cPackOBS						,OFONT08)  
		else
			OPRN:SAY(3172,0455, SubStr(cPackOBS,1,170)			,OFONT08)  
			OPRN:SAY(3202,0455, SubStr(cPackOBS,171,70)		,OFONT08)  
		EndIf

		OPRN:SAY(3320,0080, " SHIPPER'S/FACTORY/SUPPLIER STAMP AND SIGNATURE",OFONT08)		
		OPRN:SAY(3320,1300, " OUROLUX'S SIGNATURE"			,OFONT08)

		if mv_par02 = 2		//Sim Imprimi Assinatura
			//oPrn:SayBitmap(03340,01550,cAssAprov,0300,0150)		// Imprime logo da Assinatura
			oPrn:SayBitmap(3320,01600,cAssAprov,0300,0050)		// Imprime logo da Assinatura
		Endif


	// final
	oPrn:EndPage()



//Pagina 2
if lSaltaPG

	oPrn:StartPage()
	cBitMap := "Lgrl01.Bmp"
	//cBitMap := "lgrl0101.bmp"
	oPrn:SayBitmap(0035,0105,cBitMap,0400,0150)			// Imprime logo da Empresa: comprimento X altura

	//SW3 - Item da PO
	dbSelectArea("SW3")
	dbSetOrder(01)

	if ! dbSeek(xFilial("SW3")+mv_par01)
	endif

	//SW2 - Cabegalho
	dbSelectArea("SW2")
	dbSetOrder(01)
	dbSeek(xFilial("SW2")+mv_par01)
	//SWB
	dbSelectArea("SWB")
	dbSetOrder(01)
	dbSeek(xFilial("SWB")+mv_par01)

	//Dados do Importador
	dbSelectArea("SYT")
	dbSetOrder(01)
	dbSeek(xFilial("SYT")+SW2->W2_IMPORT)

	// Quadros verticais
	oPrn:Box(0030,0030,cLinEnd,cColDir) 	//Borda do Logo e Titulo "PROFORMA INVOICE"
	oPrn:Box(0030,0595,0186,0595) 			//Borda entre Logo e Titulo

	oPrn:Box(0186,0030,cLinEnd,cColDir) 	//Borda abaixo do Logo e Titulo
	oPrn:Box(0186,0800,0523,0800) 			//Borda entre "Exporter" e "Manufacter"
	oPrn:Box(0186,1600,0523,1600) 			//Borda entre "Manufacter" e "Banking Information"
	//..oPrn:Box(0523,0030,cLinEnd,cColDir)
	oPrn:Box(0523,0030,0523,cColDir) 		//Borda abaixo do "Exporter" e "Manufacter" e "Banking Information"
	oPrn:Box(0523,0595,0872,0595) 			//Borda da esquerda do "Consignee/Importer"
	oPrn:Box(0523,1600,0872,1600) 			//Borda entre "Consignee/Importer" e "Notify/Buyer"
	//..oPrn:Box(0872,0030,cLinEnd,cColDir) 
	oPrn:Box(0872,0030,0872,cColDir) 	  	//Borda abaixo de " " e "Consignee/Importer" e "Notify/Buyer"
	oPrn:Box(0872,0090,1781,0090) 			//Borda entre "Seq" e "Cod"
	oPrn:Box(0872,0270,1868,0270) 			//Borda entre "Cod" e "Qty Pieces"
	oPrn:Box(0872,0460,1868,0460) 			//Borda entre "Qty Pieces"e "Description"
	oPrn:Box(0872,1065,1868,1065) 			//Borda entre "Description" e "NCM"
	oPrn:Box(0872,1190,1868,1190) 			//Borda entre "NCM" e "CBM(M3)"
	oPrn:Box(0872,1355,1868,1355) 			//Borda entre "BCM(M3)" e "Qty Boxes"
	oPrn:Box(0872,1510,1868,1510) 			//Borda entre "Qty Boxes" e "Net Weight"
	oPrn:Box(0872,1700,1868,1700) 			//Borda entre "Net Weight" e "Gross Weight"
	oPrn:Box(0872,1895,1868,1895) 			//Borda entre "Gross Weight" e "Price Per Unit"
	oPrn:Box(0872,2115,1868,2115) 			//Borda entre "Price Per Unit" e "Total Price"
	//..oPrn:Box(0946,0030,cLinEnd,cColDir)
	oPrn:Box(1781,0030,cLinEnd,cColDir)		//Borda abaixo das colunas dos Itens e acima do Total
	oPrn:Box(1868,0030,cLinEnd,cColDir) 	//Borda abaixo do Total e acima do Cargo Data
	oPrn:Box(1930,0030,1930,1844) 			//Borda abaixo do Cargo Data
	oPrn:Box(1930,0298,2128,0298) 			//Borda da direta do "ETD" e "ETA"
	oPrn:Box(1930,0773,2377,0773)			//Borda da esquerda do "Country of Origin" e "Acquisition Procedence" e "Way of Transportation SEA" e "Purchase Order"
	oPrn:Box(1930,1130,2128,1130)			//Borda da direita do "Country of Origin" e "Acquisition Procedence"
	oPrn:Box(1930,1487,2253,1487)			//Borda da esqueda do "Total FOB" e "Insurance" e "Total"
	oPrn:Box(1868,1844,2253,1844)   		//Borda da direita do "Cargo Data" e "Total FOB" e "Insurance" e "Total"
	oPrn:Box(2029,0030,cLinEnd,cColDir)		//Borda abaixo do "ETD" e "Country of Origin" e "Total FOB"
	oPrn:Box(2128,0030,cLinEnd,cColDir)		//Borda abaixo do "ETA" e "Acquisition Procedence" e "Insurance" e " "
	oPrn:Box(2253,0030,cLinEnd,cColDir)		//Borda acima do "Port/Airport of Destination" e "Purchase Order" e "LOT NR" e "INCOTERM" e "FOB"
	oPrn:Box(2253,1250,2377,1250)			//Borda entre "Purchase Order" e "Lot NR"
	oPrn:Box(2253,1663,2377,1663)			//Borda entre "Lot NR" e "Incoterm"
	oPrn:Box(2253,2249,2377,2249)			//Borda entre "Incoterm" e "FOB"
	oPrn:Box(2377,0030,cLinEnd,cColDir)		//Borda acima do "Payment Condition"
	oPrn:Box(2432,0030,2422+10,cColDir) 	//Borda abaixo do "Payment Condition"
	oPrn:Box(2500,0030,cLinEnd,cColDir)		//Borda abaixo do "Delivery Time"
	oPrn:Box(2710,0030,2710,cColDir )		//Borda abaixo do "Fines" e "Quality"
	oPrn:Box(2825,0030,2825,cColDir)		//Borda abaixo do "Inspections
	oPrn:Box(2500,0230,2710,0230)			//Borda da direita "Fines"
	oPrn:Box(2500,0440,3300,0440) 			//Borda da direita do "Delivery" e "Quality" e "Inspections" e "Genaral Terms"
	oPrn:Box(2625,0230,2625,cColDir) 		//Borda abaixo do "Delivery" e "texto do Delivery"
	oPrn:Box(2925,0030,2925,cColDir)		//Borda abaixo do "General Terms" e "texto do General"
	oPrn:Box(3112,0440,3112,cColDir)		//Borda entre "Product Data Sheet" e "Packaging Data Sheet"
	oPrn:Box(3300,0030,cLinEnd,cColDir) 	//Borda da Assinatura
	oPrn:Box(3300,1200,cLinEnd,1200)		//Borda entre as Assinaturas 
	// fim verticais

		nlin 	:= 0035
		oPrn:Say(nLin,0035,OemToAnsi(''),oFont08)	
		oPrn:Say(0095-20,1200, "PROFORMA INVOICE",oFont14N) 
	
		oPrn:Say(0190,0045, "EXPORTER",oFont08N)
		DBSELECTAREA('SA2')
		if dbseek(XFILIAL('SA2')+SW3->W3_FORN)
			oPrn:Say(0250,0045,OemToAnsi(SA2->A2_NOME),oFont08)
			oPrn:Say(0300,0045,OemToAnsi(SA2->A2_END),oFont08)
			oPrn:Say(0350,0045,OemToAnsi(SA2->A2_BAIRRO),oFont08)
			//oPrn:Say(0350,0045,OemToAnsi(SA2->A2_MUN)+' '+SA2->A2_EST,oFont08)
			//oPrn:Say(0400,0045,OemToAnsi(SA2->A2_CEP),oFont08)
		ENDIF

		oPrn:Say(0190,1615, "BANKING INFORMATION ",oFont08N)
		DBSELECTAREA('SA2')
		if dbseek(XFILIAL('SA2')+SW3->W3_FORN)
			oPrn:Say(0300-60,1615,"BENEFICIARY BANK: "+TRIM(SA2->A2_XBANCO),oFont08)
			oPrn:Say(0340-60,1615,"SWIFT CODE: "+TRIM(SA2->A2_SWIFT)	,oFont08)
			oPrn:Say(0380-60,1615,TRIM(SA2->A2_XENDBAN)					,oFont08)
			oPrn:Say(0420-60,1615,"BENEFICIARY CUSTOMER: "				,oFont08)
			oPrn:Say(0460-60,1615,OemToAnsi(SA2->A2_NOME)				,oFont08)
			oPrn:Say(0500-60,1615,"ACCOUNT NO: "+TRIM(SA2->A2_XCTABAN)	,oFont08)
		ENDIF

		DBSELECTAREA('SW3')
		oPrn:Say(0190,0815, "MANUFACTURER",oFont08N)
		DBSELECTAREA('SA2')
		if dbseek(XFILIAL('SA2')+SW3->W3_FABR)
			oPrn:Say(0250,0815,OemToAnsi(SA2->A2_NOME),oFont08)
			oPrn:Say(0300,0815,OemToAnsi(SA2->A2_END),oFont08)
			oPrn:Say(0350,0045,OemToAnsi(SA2->A2_BAIRRO),oFont08)
			//oPrn:Say(0350,0815,OemToAnsi(SA2->A2_MUN)+' '+SA2->A2_EST,oFont08)
			//oPrn:Say(0400,0815,OemToAnsi(SA2->A2_CEP),oFont08)
		ENDIF

		DBSELECTAREA('SW3')
		oPrn:Say(0530,0035,OemToAnsi(''),oFont08)	
		oPrn:Say(0530,0610, "CONSIGNEE/IMPORTER"			,oFont08N)
		oPrn:Say(0580,0610,OemToAnsi(cNomImp)			,oFont08)
		oPrn:Say(0630,0610,OemToAnsi(cEndImp)			,oFont08)
		oPrn:Say(0680,0610,OemToAnsi(cMunImp+' - Brasil'),oFont08)
		oPrn:Say(0730,0610,OemToAnsi(cCEPImp)			,oFont08)
		oPrn:Say(0780,0610,OemToAnsi(cTELImp)			,oFont08)
		oPrn:Say(0830,0610,OemToAnsi(cCNPJImp)			,oFont08)

		oPrn:Say(0530,1615, "NOTIFY/BUYER",oFont08N)
		oPrn:Say(0580,1615,OemToAnsi(cNomImp)			,oFont08)
		oPrn:Say(0630,1615,OemToAnsi(cEndImp)			,oFont08)
		oPrn:Say(0680,1615,OemToAnsi(cMunImp+' - Brasil'),oFont08)
		oPrn:Say(0730,1615,OemToAnsi(cCEPImp)			,oFont08)
		oPrn:Say(0780,1615,OemToAnsi(cTELImp)			,oFont08)
		oPrn:Say(0830,1615,OemToAnsi(cCNPJImp)			,oFont08)

		oPrn:Say(0120,1800, "ISSUE DATE: "+cDataImpressao,oFont08)
		nPage := SOMA1(nPage)
		oPrn:Say(0150,1800, "PAGE : "+nPage				,oFont08)

		//Cabecalho dos Itens        
			nlin := 0886
			oPrn:Say(nLin,0040,OemToAnsi('SEQ')			,oFont08)
			oPrn:Say(nLin,0105,OemToAnsi('CODE')		,oFont08)
			oPrn:Say(nLin,0285,OemToAnsi('QTY PIECES')	,oFont08)
			oPrn:Say(nLin,0475,OemToAnsi('DESCRIPTION')	,oFont08)
			oPrn:Say(nLin,1080,OemToAnsi('NCM')			,oFont08) 
			oPrn:Say(nLin,1205,OemToAnsi('CBM(M3)')		,oFont08)
			oPrn:Say(nLin,1370,OemToAnsi('QTY BOXES')	,oFont08)
			oPrn:Say(nLin,1525,OemToAnsi('NET WEIGHT')	,oFont08)
			oPrn:Say(nLin,1715,OemToAnsi('GROSS WEIGHT'),oFont08)
			oPrn:Say(nLin,1910,OemToAnsi('PRICE PER UNIT'),oFont08)
			oPrn:Say(nLin,2130,OemToAnsi('TOTAL PRICE')	,oFont08)  
			
			nLin    :=0950  

			While !Eof() .And. w3_po_num == mv_par01
				SB1->(DBSEEK(XFILIAL('SB1')+(SW3->W3_COD_I)))

				//Busca os Itens com Dados NCM
				if empty(SW3->W3_TEC)
					SW3->(DbSkip())
					Loop
				Endif

				if SW3->W3_SEQ=1
					SW3->(DbSkip())
					Loop
				Endif

				IF strzero(SW3->W3_NR_CONT,3)<"022"
					SW3->(DbSkip())
					Loop
				Endif

				IF strzero(SW3->W3_NR_CONT,3)>"042"
					lSaltaP2 := .T.
					SW3->(DbSkip())
					Loop
				Endif

				cDescLI := MSMM(SB1->B1_DESC_I,40)			//Descricao em Ingles
				cDescLI := IF( EMPTY(cDescLI), SB1->B1_DESC, cDescLI)

				cDescLI := SubStr(cDescLI,1,50)
			
				oPrn:Say(nLin,0045,OemToAnsi(strzero(SW3->W3_NR_CONT,3))				,oFont08)
				oPrn:Say(nLin,0105,OemToAnsi(SW3->W3_COD_I)								,oFont08)
				oPrn:Say(nLin,0445,OemToAnsi(Transform(SW3->W3_QTDE,"@E 999,999,999.999"))	,oFont08,,,,1)
				oPrn:Say(nLin,0475,OemToAnsi(cDescLI)									,oFont08)
				oPrn:Say(nLin,1080,OemToAnsi(SW3->W3_TEC)								,oFont08)
				
				IF SW3->W3_XCUBAGE > 0
					oPrn:Say(nLin,1340,OemToAnsi(Transform(SW3->W3_XCUBAGE	,"@E 999,999.9999"))	,oFont08,,,,1)
				ENDIF
				IF SW3->W3_XQTDEM1 > 0
					oPrn:Say(nLin,1495,OemToAnsi(Transform(SW3->W3_XQTDEM1	,"@E 9999999999"))	,oFont08,,,,1)
				ENDIF
				IF SW3->W3_PESOL > 0
					oPrn:Say(nLin,1685,OemToAnsi(Transform(SW3->W3_QTDE * SW3->W3_PESOL	,"@E 999,999.999999")),oFont08,,,,1)
				endif
				IF SW3->W3_PESO_BR > 0
					oPrn:Say(nLin,1880,OemToAnsi(Transform(SW3->W3_QTDE * SW3->W3_PESO_BR	,"@E 999,999.999999"))	,oFont08,,,,1)
				endif

				oPrn:Say(nLin,2100,OemToAnsi(Transform(SW3->W3_PRECO,"@E 999,999,999.99999")),oFont08,,,,1)  
				oPrn:Say(nLin,2320,OemToAnsi(Transform(SW3->W3_QTDE * SW3->W3_PRECO,"@E 999,999,999.99999")),oFont08,,,,1)
				
				nTotal	+= (SW3->W3_QTDE * SW3->W3_PRECO)	//Valor Total
				nCbm	+= SW3->W3_XCUBAGE					//cubagem
				nBoxes	+= SW3->W3_XQTDEM1					//Caixas
				nWeight += (SW3->W3_QTDE * SW3->W3_PESOL)	//
				nCross 	+= (SW3->W3_QTDE * SW3->W3_PESO_BR) //
				nQtdTOT += SW3->W3_QTDE						//Quantidade Total

				nLin+=0040 			//Salto de Linha
				dbSelectArea("SW3")
				dbSkip()
			
			EndDo

			nlin := 1830
		oPrn:Say(nLin,0050,OemToAnsi('TOTAL')								,oFont08N)
		oPrn:Say(nLin,0445,OemToAnsi(/*STR(*/if(!lSaltaP2,Transform(nQtdTOT,"@E 999,999,999.999"),"0")/*,14)*/)		,oFont08,,,,1)
		oPrn:Say(nLin,0495,OemToAnsi('SCHEDULED ORDER (X  OF  Y)')		,oFont08N)
		oPrn:Say(nLin,1070,OemToAnsi(cProgrPO)									,oFont08N)
		
		oPrn:Say(nLin,1340,OemToAnsi(/*STR(*/if(!lSaltaP2,Transform(nCbm,"@E 9,999,999.99"),"0")/*,14,2)*/)			,oFont08,,,,1)
		oPrn:Say(nLin,1495,OemToAnsi(/*STR(*/if(!lSaltaP2,Transform(nboxes,"@E 9,999,999.99"),"0")/*,14,2)*/)		,oFont08,,,,1)
		oPrn:Say(nLin,1685,OemToAnsi(Transform(if(!lSaltaP2,nweight,0),"@E 9,999,999.99")),oFont08,,,,1)
		oPrn:Say(nLin,1880,OemToAnsi(Transform(if(!lSaltaP2,ncross,0),"@E 9,999,999.99")),oFont08,,,,1)
		
		oPrn:Say(nLin,1989-15,OemToAnsi('')							,oFont08)
		oPrn:Say(nLin,2130,OemToAnsi(cMoedaPO)			,oFont08)
		oPrn:Say(nLin,2320,OemToAnsi(Transform(if(!lSaltaP2,ntotal,0),"@E 9,999,999.99")),oFont08,,,,1)  //180-50-12-15-20
	
		oPrn:Say(1880,0538,OemToAnsi('CARGO DATA')					,oFont08N)  
		oPrn:Say(1930,1510,OemToAnsi('TOTAL FOB')					,oFont10N)
		oPrn:Say(1930,1910,OemToAnsi(cMoedaPO)						,oFont08N)
		oPrn:Say(1930,2320,OemToAnsi(Transform(if(!lSaltaP2,ntotal,0),"@E 9,999,999.99")),oFont10N,,,,1)  
		oPrn:Say(1980,1510,OemToAnsi('INTERNACIONAL FREIGHT')		,oFont08)
		oPrn:Say(2080,1510,OemToAnsi('INSURANCE')					,oFont08N)
		oPrn:Say(1955,0050,OemToAnsi('ETD')							,oFont08N)
		oPrn:Say(1955+40,0048,OemToAnsi('(ON BOARD)')				,oFont08)

		IF !Empty(dETDpo)
			oPrn:Say(1955,0400,Day2Str(dETDpo)+" - "+left(cMonth(dETDpo),3)+" - "+Year2Str(dETDpo),oFont08N)
		Endif

		oPrn:Say(1955,0800,OemToAnsi('COUNTRY OF ORIGIN')			,oFont08N) 
		oPrn:Say(1956,1159,OemToAnsi(cPaisForD)						,oFont08)	
	
		oPrn:Say(2055,0050,OemToAnsi('ETA')							,oFont08N)
		if !Empty(dETApo)
			oPrn:Say(2055,0400,Day2Str(dETApo)+" - "+left(cMonth(dETApo),3)+" - "+Year2Str(dETApo),oFont08N)
		Endif

		oPrn:Say(2030+15,0800,OemToAnsi('ACQUISITION')				,oFont08N) 
		oPrn:Say(2100-15,0800,OemToAnsi('PROCEDENCE')				,oFont08N)	
		oPrn:Say(2100-15,1159,OemToAnsi(cPaisForD)					,oFont08)	
		oPrn:Say(2135,0050,OemToAnsi('PORT/AIRPORT OF ORIGIN:')		,oFont08N) //0180
		oPrn:Say(2175,0050,OemToAnsi(cOrigPort)						,oFont08N) //0180
		oPrn:Say(2135,0800,OemToAnsi('WAY OF TRANSPORTATION:')		,oFont08N) //0872
		oPrn:Say(2175,0800,OemToAnsi('SEA')							,oFont08N) //0872
		oPrn:Say(2170,1510,OemToAnsi('TOTAL')						,oFont08N)
		oPrn:Say(2170,1910,OemToAnsi(cMoedaPO)						,oFont08N)
		oPrn:Say(2170,2320,OemToAnsi(Transform(if(!lSaltaP2,ntotal,0),"@E 9,999,999.99")),oFont10N,,,,1)  
		oPrn:Say(2260,0050,OemToAnsi('PORT/AIRPORT OF DESTINATION:')	,oFont08N)//0180
		oPrn:Say(2300,0050,OemToAnsi(cDestPort)						,oFont08N)//0180
		oPrn:Say(2260,0800,OemToAnsi('PURCHASE ORDER')				,oFont08N)   
		oPrn:Say(2300,0800,OemToAnsi(MV_PAR01)						,oFont14) //SW3->W3_PO_NUM
		oPrn:Say(2260,1280,OemToAnsi('LOT NR')						,oFont08N)   
		oPrn:Say(2300,1280,OemToAnsi(cLOTENR)						,oFont10N) //SW3->W3_PO_NUM
		oPrn:Say(2290,1680,OemToAnsi('INCOTERM')					,oFont08N)    
		oPrn:Say(2290,2260,OemToAnsi(cIncoter)						,oFont08N)    
	
		//Demonstra valores conforme ao Condigco de Pagamento
		//aParc  := Condicao(ntotal,SW2->W2_COND_PA,,dDataBase)
		cMenVLR:= ""
		//FOR nSE4 := 1 TO Len( aParc )
		//	cMenVLR += " | "+cMoedaPO+" "+Transform(aParc[nSE4,2],"@E 9,999,999.99")
		//NEXT

		IF !lSaltaP2
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
		Endif

		oPrn:Say(2387,0050, "PAYMENT CONDITION"					,oFont10N)  
		oPrn:Say(2387,0595-075, trim(cMenCondPG)+cMenVLR			,oFont10)  	//0595

		// INFORMACOES POLITICAS - FIXAS   
		//Criar PARAMETROS NO CFG destas Mensagem do Pedido ...
		oPrn:Say(2439,0050, "DELIVERY TIME",oFont08n)
		oPrn:Say(2462,0050, "(Approval of PSI)",oFont08n)
		oPrn:Say(2457,0300,cMsgFx01 ,oFont08)	
		oPrn:Say(2510,0455, cMsgFx02,oFont07N)
		oPrn:Say(2535,0455, cMsgFx03,oFont07N)
		oPrn:Say(2560,0455, cMsgFx04,oFont07N)
		oPrn:Say(2585,0455, cMsgFx05,oFont07N)
		oPrn:Say(2625,0455, cMsgFx06,oFont07N)
		oPrn:Say(2650,0455, cMsgFx07,oFont07N)
		oPrn:Say(2675,0455, cMsgFx08,oFont07N)
		oPrn:Say(2720,0455, cMsgFx09,oFont07N)  
 		oPrn:Say(2745,0455, cMsgFx10,oFont07N)  
 		oPrn:Say(2770,0455, cMsgFx11,oFont07N)  
 		oPrn:Say(2795,0455, cMsgFx12,oFont07N)  
		oPrn:Say(2850,0455, cMsgFx13,oFont07N)  
 		oPrn:Say(2875,0455, cMsgFx14,oFont07N)  

		OPRN:SAY(2585,0050, " FINES"						,oFont08N)  
		OPRN:SAY(2520,0255, " DELIVERY "					,oFont08N)  
		OPRN:SAY(2650,0255, " QUALITY"						,oFont08N)  
		OPRN:SAY(2770,0050, " INSPECTIONS"					,oFont08N)  
		OPRN:SAY(2862,0050, " GENERAL TERMS"				,oFont08N)  

		OPRN:SAY(2950,0050, " TECHNICAL INFO:"				,OFONT08n)  
		OPRN:SAY(3000,0050, " (SUPPLIER MUST ATTEND ALL "	,OFONT08)  
		OPRN:SAY(3035,0050, " REQUIREMENTS ACCORDING"		,OFONT08)  
		OPRN:SAY(3070,0050, " TO THE PRODUCT DATA SHEET  "	,OFONT08)  
		OPRN:SAY(3105,0050, " AND PRODUCT PACKAGE/ARTWORK "	,OFONT08)  
		OPRN:SAY(3140,0050, " DATA SHEET,"					,OFONT08)  
		OPRN:SAY(3175,0050, " MENTIONED IN THIS DOCUMENT.)"	,OFONT08)  
		OPRN:SAY(2935,1000, " PRODUCT DATA SHEET"			,OFONT08)  
		
		If Len(cProduOBS) <= 170
			OPRN:SAY(2985,0455, cProduOBS						,OFONT08)  
		else
			OPRN:SAY(2985,0455, SubStr(cProduOBS,1,170)			,OFONT08)  
			OPRN:SAY(3015,0455, SubStr(cProduOBS,171,70)		,OFONT08)  
		EndIf

		OPRN:SAY(3122,1000, " PACKAGING DATA SHEET"			,OFONT08)  
		
		If Len(cPackOBS) <= 170
			OPRN:SAY(3172,0455, cPackOBS						,OFONT08)  
		else
			OPRN:SAY(3172,0455, SubStr(cPackOBS,1,170)			,OFONT08)  
			OPRN:SAY(3202,0455, SubStr(cPackOBS,171,70)		,OFONT08)  
		EndIf

		OPRN:SAY(3320,0080, " SHIPPER'S/FACTORY/SUPPLIER STAMP AND SIGNATURE",OFONT08)		
		OPRN:SAY(3320,1300, " OUROLUX'S SIGNATURE"			,OFONT08)

		if mv_par02 = 2		//Sim Imprimi Assinatura
			oPrn:SayBitmap(3320,01600,cAssAprov,0300,0050)		// Imprime logo da Assinatura
		Endif


	// final
	oPrn:EndPage()

Endif

//Pagina 3
if lSaltaP2

	oPrn:StartPage()
	cBitMap := "Lgrl01.Bmp"
	//cBitMap := "lgrl0101.bmp"
	oPrn:SayBitmap(0035,0105,cBitMap,0400,0150)			// Imprime logo da Empresa: comprimento X altura

	//SW3 - Item da PO
	dbSelectArea("SW3")
	dbSetOrder(01)

	if ! dbSeek(xFilial("SW3")+mv_par01)
	endif

	//SW2 - Cabegalho
	dbSelectArea("SW2")
	dbSetOrder(01)
	dbSeek(xFilial("SW2")+mv_par01)
	//SWB
	dbSelectArea("SWB")
	dbSetOrder(01)
	dbSeek(xFilial("SWB")+mv_par01)

	//Dados do Importador
	dbSelectArea("SYT")
	dbSetOrder(01)
	dbSeek(xFilial("SYT")+SW2->W2_IMPORT)

	// Quadros verticais
	oPrn:Box(0030,0030,cLinEnd,cColDir) 	//Borda do Logo e Titulo "PROFORMA INVOICE"
	oPrn:Box(0030,0595,0186,0595) 			//Borda entre Logo e Titulo

	oPrn:Box(0186,0030,cLinEnd,cColDir) 	//Borda abaixo do Logo e Titulo
	oPrn:Box(0186,0800,0523,0800) 			//Borda entre "Exporter" e "Manufacter"
	oPrn:Box(0186,1600,0523,1600) 			//Borda entre "Manufacter" e "Banking Information"
	//..oPrn:Box(0523,0030,cLinEnd,cColDir)
	oPrn:Box(0523,0030,0523,cColDir) 		//Borda abaixo do "Exporter" e "Manufacter" e "Banking Information"
	oPrn:Box(0523,0595,0872,0595) 			//Borda da esquerda do "Consignee/Importer"
	oPrn:Box(0523,1600,0872,1600) 			//Borda entre "Consignee/Importer" e "Notify/Buyer"
	//..oPrn:Box(0872,0030,cLinEnd,cColDir) 
	oPrn:Box(0872,0030,0872,cColDir) 	  	//Borda abaixo de " " e "Consignee/Importer" e "Notify/Buyer"
	oPrn:Box(0872,0090,1781,0090) 			//Borda entre "Seq" e "Cod"
	oPrn:Box(0872,0270,1868,0270) 			//Borda entre "Cod" e "Qty Pieces"
	oPrn:Box(0872,0460,1868,0460) 			//Borda entre "Qty Pieces"e "Description"
	oPrn:Box(0872,1065,1868,1065) 			//Borda entre "Description" e "NCM"
	oPrn:Box(0872,1190,1868,1190) 			//Borda entre "NCM" e "CBM(M3)"
	oPrn:Box(0872,1355,1868,1355) 			//Borda entre "BCM(M3)" e "Qty Boxes"
	oPrn:Box(0872,1510,1868,1510) 			//Borda entre "Qty Boxes" e "Net Weight"
	oPrn:Box(0872,1700,1868,1700) 			//Borda entre "Net Weight" e "Gross Weight"
	oPrn:Box(0872,1895,1868,1895) 			//Borda entre "Gross Weight" e "Price Per Unit"
	oPrn:Box(0872,2115,1868,2115) 			//Borda entre "Price Per Unit" e "Total Price"
	//..oPrn:Box(0946,0030,cLinEnd,cColDir)
	oPrn:Box(1781,0030,cLinEnd,cColDir)		//Borda abaixo das colunas dos Itens e acima do Total
	oPrn:Box(1868,0030,cLinEnd,cColDir) 	//Borda abaixo do Total e acima do Cargo Data
	oPrn:Box(1930,0030,1930,1844) 			//Borda abaixo do Cargo Data
	oPrn:Box(1930,0298,2128,0298) 			//Borda da direta do "ETD" e "ETA"
	oPrn:Box(1930,0773,2377,0773)			//Borda da esquerda do "Country of Origin" e "Acquisition Procedence" e "Way of Transportation SEA" e "Purchase Order"
	oPrn:Box(1930,1130,2128,1130)			//Borda da direita do "Country of Origin" e "Acquisition Procedence"
	oPrn:Box(1930,1487,2253,1487)			//Borda da esqueda do "Total FOB" e "Insurance" e "Total"
	oPrn:Box(1868,1844,2253,1844)   		//Borda da direita do "Cargo Data" e "Total FOB" e "Insurance" e "Total"
	oPrn:Box(2029,0030,cLinEnd,cColDir)		//Borda abaixo do "ETD" e "Country of Origin" e "Total FOB"
	oPrn:Box(2128,0030,cLinEnd,cColDir)		//Borda abaixo do "ETA" e "Acquisition Procedence" e "Insurance" e " "
	oPrn:Box(2253,0030,cLinEnd,cColDir)		//Borda acima do "Port/Airport of Destination" e "Purchase Order" e "LOT NR" e "INCOTERM" e "FOB"
	oPrn:Box(2253,1250,2377,1250)			//Borda entre "Purchase Order" e "Lot NR"
	oPrn:Box(2253,1663,2377,1663)			//Borda entre "Lot NR" e "Incoterm"
	oPrn:Box(2253,2249,2377,2249)			//Borda entre "Incoterm" e "FOB"
	oPrn:Box(2377,0030,cLinEnd,cColDir)		//Borda acima do "Payment Condition"
	oPrn:Box(2432,0030,2422+10,cColDir) 	//Borda abaixo do "Payment Condition"
	oPrn:Box(2500,0030,cLinEnd,cColDir)		//Borda abaixo do "Delivery Time"
	oPrn:Box(2710,0030,2710,cColDir )		//Borda abaixo do "Fines" e "Quality"
	oPrn:Box(2825,0030,2825,cColDir)		//Borda abaixo do "Inspections
	oPrn:Box(2500,0230,2710,0230)			//Borda da direita "Fines"
	oPrn:Box(2500,0440,3300,0440) 			//Borda da direita do "Delivery" e "Quality" e "Inspections" e "Genaral Terms"
	oPrn:Box(2625,0230,2625,cColDir) 		//Borda abaixo do "Delivery" e "texto do Delivery"
	oPrn:Box(2925,0030,2925,cColDir)		//Borda abaixo do "General Terms" e "texto do General"
	oPrn:Box(3112,0440,3112,cColDir)		//Borda entre "Product Data Sheet" e "Packaging Data Sheet"
	oPrn:Box(3300,0030,cLinEnd,cColDir) 	//Borda da Assinatura
	oPrn:Box(3300,1200,cLinEnd,1200)		//Borda entre as Assinaturas 
	// fim verticais

		nlin 	:= 0035
		oPrn:Say(nLin,0035,OemToAnsi(''),oFont08)	
		oPrn:Say(0095-20,1200, "PROFORMA INVOICE",oFont14N) 
	
		oPrn:Say(0190,0045, "EXPORTER",oFont08N)
		DBSELECTAREA('SA2')
		if dbseek(XFILIAL('SA2')+SW3->W3_FORN)
			oPrn:Say(0250,0045,OemToAnsi(SA2->A2_NOME),oFont08)
			oPrn:Say(0300,0045,OemToAnsi(SA2->A2_END),oFont08)
			oPrn:Say(0350,0045,OemToAnsi(SA2->A2_BAIRRO),oFont08)
			//oPrn:Say(0350,0045,OemToAnsi(SA2->A2_MUN)+' '+SA2->A2_EST,oFont08)
			//oPrn:Say(0400,0045,OemToAnsi(SA2->A2_CEP),oFont08)
		ENDIF

		oPrn:Say(0190,1615, "BANKING INFORMATION ",oFont08N)
		DBSELECTAREA('SA2')
		if dbseek(XFILIAL('SA2')+SW3->W3_FORN)
			oPrn:Say(0300-60,1615,"BENEFICIARY BANK: "+TRIM(SA2->A2_XBANCO),oFont08)
			oPrn:Say(0340-60,1615,"SWIFT CODE: "+TRIM(SA2->A2_SWIFT)	,oFont08)
			oPrn:Say(0380-60,1615,TRIM(SA2->A2_XENDBAN)					,oFont08)
			oPrn:Say(0420-60,1615,"BENEFICIARY CUSTOMER: "				,oFont08)
			oPrn:Say(0460-60,1615,OemToAnsi(SA2->A2_NOME)				,oFont08)
			oPrn:Say(0500-60,1615,"ACCOUNT NO: "+TRIM(SA2->A2_XCTABAN)	,oFont08)
		ENDIF

		DBSELECTAREA('SW3')
		oPrn:Say(0190,0815, "MANUFACTURER",oFont08N)
		DBSELECTAREA('SA2')
		if dbseek(XFILIAL('SA2')+SW3->W3_FABR)
			oPrn:Say(0250,0815,OemToAnsi(SA2->A2_NOME),oFont08)
			oPrn:Say(0300,0815,OemToAnsi(SA2->A2_END),oFont08)
			oPrn:Say(0350,0045,OemToAnsi(SA2->A2_BAIRRO),oFont08)
			//oPrn:Say(0350,0815,OemToAnsi(SA2->A2_MUN)+' '+SA2->A2_EST,oFont08)
			//oPrn:Say(0400,0815,OemToAnsi(SA2->A2_CEP),oFont08)
		ENDIF

		DBSELECTAREA('SW3')
		oPrn:Say(0530,0035,OemToAnsi(''),oFont08)	
		oPrn:Say(0530,0610, "CONSIGNEE/IMPORTER"			,oFont08N)
		oPrn:Say(0580,0610,OemToAnsi(cNomImp)			,oFont08)
		oPrn:Say(0630,0610,OemToAnsi(cEndImp)			,oFont08)
		oPrn:Say(0680,0610,OemToAnsi(cMunImp+' - Brasil'),oFont08)
		oPrn:Say(0730,0610,OemToAnsi(cCEPImp)			,oFont08)
		oPrn:Say(0780,0610,OemToAnsi(cTELImp)			,oFont08)
		oPrn:Say(0830,0610,OemToAnsi(cCNPJImp)			,oFont08)

		oPrn:Say(0530,1615, "NOTIFY/BUYER",oFont08N)
		oPrn:Say(0580,1615,OemToAnsi(cNomImp)			,oFont08)
		oPrn:Say(0630,1615,OemToAnsi(cEndImp)			,oFont08)
		oPrn:Say(0680,1615,OemToAnsi(cMunImp+' - Brasil'),oFont08)
		oPrn:Say(0730,1615,OemToAnsi(cCEPImp)			,oFont08)
		oPrn:Say(0780,1615,OemToAnsi(cTELImp)			,oFont08)
		oPrn:Say(0830,1615,OemToAnsi(cCNPJImp)			,oFont08)

		oPrn:Say(0120,1800, "ISSUE DATE: "+cDataImpressao,oFont08)
		nPage := SOMA1(nPage)
		oPrn:Say(0150,1800, "PAGE : "+nPage				,oFont08)

		//Cabecalho dos Itens        
			nlin := 0886
			oPrn:Say(nLin,0040,OemToAnsi('SEQ')			,oFont08)
			oPrn:Say(nLin,0105,OemToAnsi('CODE')		,oFont08)
			oPrn:Say(nLin,0285,OemToAnsi('QTY PIECES')	,oFont08)
			oPrn:Say(nLin,0475,OemToAnsi('DESCRIPTION')	,oFont08)
			oPrn:Say(nLin,1080,OemToAnsi('NCM')			,oFont08) 
			oPrn:Say(nLin,1205,OemToAnsi('CBM(M3)')		,oFont08)
			oPrn:Say(nLin,1370,OemToAnsi('QTY BOXES')	,oFont08)
			oPrn:Say(nLin,1525,OemToAnsi('NET WEIGHT')	,oFont08)
			oPrn:Say(nLin,1715,OemToAnsi('GROSS WEIGHT'),oFont08)
			oPrn:Say(nLin,1910,OemToAnsi('PRICE PER UNIT'),oFont08)
			oPrn:Say(nLin,2130,OemToAnsi('TOTAL PRICE')	,oFont08)  
			
			nLin    :=0950  

			While !Eof() .And. w3_po_num == mv_par01
				SB1->(DBSEEK(XFILIAL('SB1')+(SW3->W3_COD_I)))

				//Busca os Itens com Dados NCM
				if empty(SW3->W3_TEC)
					SW3->(DbSkip())
					Loop
				Endif

				if SW3->W3_SEQ=1
					SW3->(DbSkip())
					Loop
				Endif

				IF strzero(SW3->W3_NR_CONT,3)<="042"
					SW3->(DbSkip())
					Loop
				Endif

				//Ver com Rogerio
				IF strzero(SW3->W3_NR_CONT,3)>"063"
					SW3->(DbSkip())
					Loop
				Endif

				cDescLI := MSMM(SB1->B1_DESC_I,40)			//Descricao em Ingles
				cDescLI := IF( EMPTY(cDescLI), SB1->B1_DESC, cDescLI)

				cDescLI := SubStr(cDescLI,1,50)
			
				oPrn:Say(nLin,0045,OemToAnsi(strzero(SW3->W3_NR_CONT,3))				,oFont08)
				oPrn:Say(nLin,0105,OemToAnsi(SW3->W3_COD_I)								,oFont08)
				oPrn:Say(nLin,0445,OemToAnsi(Transform(SW3->W3_QTDE,"@E 999,999,999.999"))	,oFont08,,,,1)
				oPrn:Say(nLin,0475,OemToAnsi(cDescLI)									,oFont08)
				oPrn:Say(nLin,1080,OemToAnsi(SW3->W3_TEC)								,oFont08)
				
				IF SW3->W3_XCUBAGE > 0
					oPrn:Say(nLin,1340,OemToAnsi(Transform(SW3->W3_XCUBAGE	,"@E 999,999.9999"))	,oFont08,,,,1)
				ENDIF
				IF SW3->W3_XQTDEM1 > 0
					oPrn:Say(nLin,1495,OemToAnsi(Transform(SW3->W3_XQTDEM1	,"@E 9999999999"))	,oFont08,,,,1)
				ENDIF
				IF SW3->W3_PESOL > 0
					oPrn:Say(nLin,1685,OemToAnsi(Transform(SW3->W3_QTDE * SW3->W3_PESOL	,"@E 999,999.999999")),oFont08,,,,1)
				endif
				IF SW3->W3_PESO_BR > 0
					oPrn:Say(nLin,1880,OemToAnsi(Transform(SW3->W3_QTDE * SW3->W3_PESO_BR	,"@E 999,999.999999"))	,oFont08,,,,1)
				endif

				oPrn:Say(nLin,2100,OemToAnsi(Transform(SW3->W3_PRECO,"@E 999,999,999.99999")),oFont08,,,,1)  
				oPrn:Say(nLin,2320,OemToAnsi(Transform(SW3->W3_QTDE * SW3->W3_PRECO,"@E 999,999,999.99999")),oFont08,,,,1)
				
				nTotal	+= (SW3->W3_QTDE * SW3->W3_PRECO)	//Valor Total
				nCbm	+= SW3->W3_XCUBAGE					//cubagem
				nBoxes	+= SW3->W3_XQTDEM1					//Caixas
				nWeight += (SW3->W3_QTDE * SW3->W3_PESOL)	//
				nCross 	+= (SW3->W3_QTDE * SW3->W3_PESO_BR)	//
				nQtdTOT += SW3->W3_QTDE						//Quantidade Total.

				nLin+=0040 			//Salto de Linha
				dbSelectArea("SW3")
				dbSkip()
			
			EndDo

			nlin := 1830
			oPrn:Say(nLin,0050,OemToAnsi('TOTAL')							,oFont08N)
			oPrn:Say(nLin,0445,OemToAnsi(/*STR(*/Transform(nQtdTOT,"@E 999,999,999.999")/*,14)*/)					,oFont08,,,,1)
			oPrn:Say(nLin,0495,OemToAnsi('SCHEDULED ORDER (X  OF  Y)')		,oFont08N)
			oPrn:Say(nLin,1070,OemToAnsi(cProgrPO)							,oFont08N)
			oPrn:Say(nLin,1340,Transform(nCbm,"@E 9,999,999.99"),oFont08,,,,1)
			oPrn:Say(nLin,1495,Transform(nboxes,"@E 9,999,999.99")	,oFont08,,,,1)
			oPrn:Say(nLin,1685,OemToAnsi(Transform(nWeight,"@E 9,999,999.99")),oFont08,,,,1)
			oPrn:Say(nLin,1880,OemToAnsi(Transform(ncross,"@E 9,999,999.99")),oFont08,,,,1)

			oPrn:Say(nLin,1974,OemToAnsi('')								,oFont08)
			oPrn:Say(nLin,2130,OemToAnsi(cMoedaPO)				,oFont08)
			oPrn:Say(nLin,2320,OemToAnsi(Transform(ntotal,"@E 9,999,999.99")),oFont08,,,,1)  //180-50-12-15-20
		
			oPrn:Say(1880,0538,OemToAnsi('CARGO DATA')					,oFont08N)  
			oPrn:Say(1930,1510,OemToAnsi('TOTAL FOB')					,oFont10N)
			oPrn:Say(1930,1910,OemToAnsi(cMoedaPO)						,oFont08N)
			oPrn:Say(1930,2320,OemToAnsi(Transform(ntotal,"@E 9,999,999.99")),oFont10N,,,,1)  
			oPrn:Say(1980,1510,OemToAnsi('INTERNACIONAL FREIGHT')		,oFont08)
			oPrn:Say(2080,1510,OemToAnsi('INSURANCE')					,oFont08N)
			oPrn:Say(1955,0050,OemToAnsi('ETD')							,oFont08N)
			oPrn:Say(2005,0048,OemToAnsi('(ON BOARD)')				,oFont08)			
			IF !Empty(dETDpo)
				oPrn:Say(1955,0400,Day2Str(dETDpo)+" - "+left(cMonth(dETDpo),3)+" - "+Year2Str(dETDpo),oFont08N)
			Endif
			oPrn:Say(1955,0800,OemToAnsi('COUNTRY OF ORIGIN')			,oFont08N) 
			oPrn:Say(1956,1159,OemToAnsi(cPaisForD)						,oFont08)	
			
			oPrn:Say(2055,0050,OemToAnsi('ETA')							,oFont08N)
			If !EMpty(dETDpo)
				oPrn:Say(2055,0400,Day2Str(dETApo)+" - "+left(cMonth(dETApo),3)+" - "+Year2Str(dETApo),oFont08N)
			Endif
			oPrn:Say(2030+15,0800,OemToAnsi('ACQUISITION')				,oFont08N) 
			oPrn:Say(2100-15,0800,OemToAnsi('PROCEDENCE')				,oFont08N)	
			oPrn:Say(2100-15,1159,OemToAnsi(cPaisForD)					,oFont08)	
			oPrn:Say(2135,0050,OemToAnsi('PORT/AIRPORT OF ORIGIN:')		,oFont08N) //0180
			oPrn:Say(2175,0050,OemToAnsi(cOrigPort)						,oFont08N) //0180
			oPrn:Say(2135,0800,OemToAnsi('WAY OF TRANSPORTATION:')		,oFont08N) //0872
			oPrn:Say(2175,0800,OemToAnsi('SEA')							,oFont08N) //0872
			oPrn:Say(2170,1510,OemToAnsi('TOTAL')						,oFont08N)
			oPrn:Say(2170,1910,OemToAnsi(cMoedaPO)						,oFont08N)
			oPrn:Say(2170,2320,OemToAnsi(Transform(ntotal,"@E 9,999,999.99")),oFont10N,,,,1)  
			oPrn:Say(2260,0050,OemToAnsi('PORT/AIRPORT OF DESTINATION:'),oFont08N)//0180
			oPrn:Say(2300,0050,OemToAnsi(cDestPort)						,oFont08N)//0180
			oPrn:Say(2260,0800,OemToAnsi('PURCHASE ORDER')				,oFont08N)   
			oPrn:Say(2300,0800,OemToAnsi(MV_PAR01)						,oFont14) //SW3->W3_PO_NUM
			oPrn:Say(2260,1280,OemToAnsi('LOT NR')						,oFont08N)   
			oPrn:Say(2300,1280,OemToAnsi(cLOTENR)						,oFont10N) //SW3->W3_PO_NUM
			oPrn:Say(2290,1680,OemToAnsi('INCOTERM')					,oFont08N)    
			oPrn:Say(2290,2260,OemToAnsi(cIncoter)						,oFont08N)    
		
			//Demonstra valores conforme ao Condigco de Pagamento
			cMenVLR:= ""
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

			oPrn:Say(2387,0050, "PAYMENT CONDITION"					,oFont10N)  
			oPrn:Say(2387,0595-075, trim(cMenCondPG)+cMenVLR			,oFont10)  	//0595

			// INFORMACOES POLITICAS - FIXAS   
			oPrn:Say(2439,0050, "DELIVERY TIME",oFont08n)
			oPrn:Say(2462,0050, "(Approval of PSI)",oFont08n)
			oPrn:Say(2457,0300,cMsgFx01 ,oFont08)
			oPrn:Say(2510,0455, cMsgFx02,oFont07N)
			oPrn:Say(2535,0455, cMsgFx03,oFont07N)
			oPrn:Say(2560,0455, cMsgFx04,oFont07N)
			oPrn:Say(2585,0455, cMsgFx05,oFont07N)
			oPrn:Say(2625,0455, cMsgFx06,oFont07N)
			oPrn:Say(2650,0455, cMsgFx07,oFont07N)
			oPrn:Say(2675,0455, cMsgFx08,oFont07N)
			oPrn:Say(2720,0455, cMsgFx09,oFont07N)  
			oPrn:Say(2745,0455, cMsgFx10,oFont07N)  
			oPrn:Say(2770,0455, cMsgFx11,oFont07N)  
			oPrn:Say(2795,0455, cMsgFx12,oFont07N)  
			oPrn:Say(2850,0455, cMsgFx13,oFont07N)  
			oPrn:Say(2875,0455, cMsgFx14,oFont07N)  

			OPRN:SAY(2585,0050, " FINES"						,oFont08N)  
			OPRN:SAY(2520,0255, " DELIVERY "					,oFont08N)  
			OPRN:SAY(2650,0255, " QUALITY"						,oFont08N)  
			OPRN:SAY(2770,0050, " INSPECTIONS"					,oFont08N)  
			OPRN:SAY(2862,0050, " GENERAL TERMS"				,oFont08N)  
			
			OPRN:SAY(2950,0050, " TECHNICAL INFO:"				,OFONT08n)  
			OPRN:SAY(3000,0050, " (SUPPLIER MUST ATTEND ALL "	,OFONT08)  
			OPRN:SAY(3035,0050, " REQUIREMENTS ACCORDING"		,OFONT08)  
			OPRN:SAY(3070,0050, " TO THE PRODUCT DATA SHEET  "	,OFONT08)  
			OPRN:SAY(3105,0050, " AND PRODUCT PACKAGE/ARTWORK "	,OFONT08)  
			OPRN:SAY(3140,0050, " DATA SHEET,"					,OFONT08)  
			OPRN:SAY(3175,0050, " MENTIONED IN THIS DOCUMENT.)"	,OFONT08)  
			OPRN:SAY(2935,1000, " PRODUCT DATA SHEET"			,OFONT08)  
			
			If Len(cProduOBS) <= 170
				OPRN:SAY(2985,0455, cProduOBS						,OFONT08)  
			else
				OPRN:SAY(2985,0455, SubStr(cProduOBS,1,170)			,OFONT08)  
				OPRN:SAY(3015,0455, SubStr(cProduOBS,171,70)		,OFONT08)  
			EndIf
			
			OPRN:SAY(3122,1000, " PACKAGING DATA SHEET"			,OFONT08)  
			
			If Len(cPackOBS) <= 170
				OPRN:SAY(3172,0455, cPackOBS						,OFONT08)  
			else
				OPRN:SAY(3172,0455, SubStr(cPackOBS,1,170)			,OFONT08)  
				OPRN:SAY(3202,0455, SubStr(cPackOBS,171,70)		,OFONT08)  
			EndIf

			OPRN:SAY(3320,0080, " SHIPPER'S/FACTORY/SUPPLIER STAMP AND SIGNATURE",OFONT08)		
			OPRN:SAY(3320,1300, " OUROLUX'S SIGNATURE"			,OFONT08)

			if mv_par02 = 2		//Sim Imprimi Assinatura
				oPrn:SayBitmap(3320,01600,cAssAprov,0300,0050)		// Imprime logo da Assinatura
			Endif

			oPrn:EndPage()

		
Endif

Return
