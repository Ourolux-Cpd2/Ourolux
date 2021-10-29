#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "RPTDEF.CH"
#INCLUDE "FWPrintSetup.ch"

#DEFINE IMP_SPOOL 2

#DEFINE VBOX       080
#DEFINE VSPACE     008
#DEFINE HSPACE     010
#DEFINE SAYVSPACE  008
#DEFINE SAYHSPACE  008
#DEFINE HMARGEM    030
#DEFINE VMARGEM    030
#DEFINE MAXITEM    022                                                // Máximo de produtos para a primeira página
#DEFINE MAXITEMP2  049                                                // Máximo de produtos para a pagina 2 em diante
#DEFINE MAXITEMP2F 069                                                // Máximo de produtos para a página 2 em diante quando a página não possui informações complementares
#DEFINE MAXITEMP3  025                                                // Máximo de produtos para a pagina 2 em diante (caso utilize a opção de impressao em verso) - Tratamento implementado para atender a legislacao que determina que a segunda pagina de ocupar 50%.
#DEFINE MAXITEMC   038                                                // Máxima de caracteres por linha de produtos/serviços
#DEFINE MAXMENLIN  090                                                // Máximo de caracteres por linha de dados adicionais
#DEFINE MAXMSG     013                                                // Máximo de dados adicionais por página
#DEFINE MAXVALORC  009
#DEFINE COMP_DATE  "20211027"                                         

///////////////////////////////////////////////////////////
User Function OUROR032()
Local lPreview      := .F.
Local cHora		    := Time()
Default cDtHrRecCab := ""
Default dDtReceb    := CToD("")
Private aInfNf    := {}
Private oImposto
Private nPrivate  := 0
Private nPrivate2 := 0
Private nXAux	  := 0
Private lArt488MG := .F.
Private lArt274SP := .F.
Private oProforma := Nil
Private nHPage    := 0
Private nVPage    := 0
Private nPaginas  := 1		

PRIVATE oFont06    := TFont():New("Arial",06,06,,.F.,,,,.T.,.F.)
PRIVATE oFont08    := TFont():New("Arial",08,08,,.F.,,,,.T.,.F.)
PRIVATE oFont08n   := TFont():New("Arial",08,08,,.T.,,,,.T.,.F.)
PRIVATE oFont30N   := TFont():New("Arial",30,30,,.T.,,,,.T.,.F.)
PRIVATE oFont12    := TFont():New("Arial",12,12,,.F.,,,,.T.,.F.)
PRIVATE oFont09    := TFont():New("Arial",09,09,,.F.,,,,.T.,.F.)
PRIVATE oFont09n   := TFont():New("Arial",09,09,,.T.,,,,.T.,.F.)
PRIVATE oFont15n   := TFont():New("Arial",15,15,,.T.,,,,.T.,.F.)
PRIVATE oFont10n   := TFont():New("Arial",10,10,,.T.,,,,.T.,.F.)


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Inicializacao do objeto grafico                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
lPreview := .T.
oProforma := FWMSPrinter():New("PROFORMA"+ DtoS(dDataBase)+ "_" + SubStr(cHora,1,2) + SubStr(cHora,4,2), IMP_PDF)
oProforma:SetPortrait()
oProforma:SetPaperSize(DMPAPER_A4)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Inicializacao da pagina do objeto grafico                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oProforma:StartPage()

nVPage := 2950 //fixado
nHPage := 2300 //fixado

MontaCabec()

MontaEmit()

MontaItem()

MontaTot()

MontaRod()	

oProforma:EndPage()
oProforma:Print()

Return

Static Function MontaCabec()	
	Local cBitMap := "Lgrl01.Bmp"
	//linha,coluna,fim linha,fim coluna
	oProforma:Box(025,025,nVPage,nHPage) 				// BOX TOTAL DA TELA
	oProforma:Box(025,025,150,600) 						// BOX LOGO
	oProforma:Box(025,600,150,1700) 					// BOX TITULO
	oProforma:SayBitmap(035,075,cBitMap,450,100)		
	oProforma:Box(025,1700,150,nHPage) 					// BOX PAGINAÇÃO
	oProforma:Say(115, 700, "PROFORMA INVOICE", oFont30N)
	oProforma:Say(080, 1800, "ISSUE DATE:" + "28/10/2021", oFont12)
	oProforma:Say(120, 1800, "PAGE: " + cValtoChar(nPaginas), oFont12)

Return

Static Function MontaEmit()	
	//linha,coluna,fim linha,fim coluna
	oProforma:Box(151,025,500,783) 			//BOX EXPORTER
	oProforma:Say(191,050, "EXPORTER", oFont15n)
	
	oProforma:Box(151,783,500,1541) 		//BOX MANUFACTER
	oProforma:Say(191,808, "MANUFACTURER", oFont15n)

	oProforma:Box(151,1538,500,nHPage)		//BOX BANKING INFORMATION
	oProforma:Say(191,1563, "BANKING INFORMATION", oFont15n)
	

	oProforma:Box(501,025,850,783) 			//BOX ...
	oProforma:Say(541,050, "PROVISORIO", oFont15n)
	
	oProforma:Box(501,783,850,1541)			//BOX CONSIGNEE/IMPORTER
	oProforma:Say(541,808, "CONSIGNEE/IMPORTER", oFont15n)
	
	oProforma:Box(501,1538,850,nHPage)		//BOX NOTIFY/BUYER
	oProforma:Say(541,1563, "NOTIFY/BUYER", oFont15n)
Return

Static Function MontaItem()	
	//linha,coluna,fim linha,fim coluna

	oProforma:Box(852,025,1851,100) 				// BOX TOTAL DA TELA
	oProforma:Say(892,035, "SEQ", oFont09)
	oProforma:Say(940,040,"123",oFont08)

	oProforma:Box(852,100,1851,300) 				// BOX TOTAL DA TELA
	oProforma:Say(892,110, "CODE", oFont09)
	oProforma:Say(940,110,"SF447F55",oFont08)

	oProforma:Box(852,300,1851,460) 				// BOX TOTAL DA TELA	
	oProforma:Say(892,310, "QTY PIECES",oFont09)
	oProforma:Say(940,310,Transform(999999999.999,"@E 999,999,999.999"),oFont08)

	oProforma:Box(852,460,1851,1030) 				// BOX TOTAL DA TELA
	oProforma:Say(892,470, "DESCRIPTION",oFont09)
	oProforma:Say(940,470,"RODRIGO DIAS NUNES DE NUNES DE NUNES DE NUNES DEN",oFont08)

	oProforma:Box(852,1030,1851,1150) 				// BOX TOTAL DA TELA
	oProforma:Say(892,1040, "NCM",oFont09)
	oProforma:Say(940,1040,"458752589",oFont08)

	oProforma:Box(852,1150,1851,1300) 				// BOX TOTAL DA TELA
	oProforma:Say(892,1160, "CBM(M3)",oFont09)
	oProforma:Say(940,1160,Transform(999999.9999	,"@E 999,999.9999"),oFont08)

	oProforma:Box(852,1300,1851,1450) 				// BOX TOTAL DA TELA
	oProforma:Say(892,1310, "QTY BOXES",oFont09)
	oProforma:Say(940,1310,Transform(999999.9999,"@E 999,999.9999"),oFont08)

	oProforma:Box(852,1450,1851,1610) 				// BOX TOTAL DA TELA
	oProforma:Say(892,1460, "NET WEIGHT",oFont09)
	oProforma:Say(940,1460,Transform(999999.999999,"@E 999,999.999999"),oFont08)

	oProforma:Box(852,1610,1851,1820) 				// BOX TOTAL DA TELA
	oProforma:Say(892,1620, "GROSS WEIGHT",oFont09)
	oProforma:Say(940,1620,Transform(999999.999999,"@E 999,999.999999"),oFont08)

	oProforma:Box(852,1820,1851,2060) 				// BOX TOTAL DA TELA
	oProforma:Say(892,1830, "PRICE UNIT",oFont09)
	oProforma:Say(940,1830,Transform(999999999.99999	,"@E 999,999,999.99999"),oFont08)

	oProforma:Box(852,2060,1851,nHPage) 			// BOX TOTAL DA TELA
	oProforma:Say(892,2070, "TOTAL PRICE",oFont09)
	oProforma:Say(940,2070,Transform(999999999.99999	,"@E 999,999,999.99999"),oFont08)

	oProforma:Line(920,025,920, nHPage)
	
Return

Static Function MontaTot()	
	oProforma:Box(1851,025,1931,nHPage) 				// BOX TOTAL DA TELA
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
Return

Static Function MontaRod()	
	oProforma:Box(1931,025,1991,nHPage)
	oProforma:Say(1971,1040, "CARGO DATA", oFont15n)

	oProforma:Box(1991,025,2091,nHPage)
	oProforma:Line(1991,325,2091,325)
	oProforma:Line(1991,650,2091,650)
	oProforma:Line(1991,975,2091,975)
	oProforma:Line(1991,1300,2091,1300)
	oProforma:Line(1991,1625,2091,1625)
	oProforma:Line(1991,1950,2091,1950)
	
	oProforma:Box(2091,025,2191,nHPage)
	oProforma:Line(2091,325,2191,325)
	oProforma:Line(2091,650,2191,650)
	oProforma:Line(2091,975,2191,975)
	oProforma:Line(2091,1300,2191,1300)
	oProforma:Line(2091,1625,2191,1625)
	oProforma:Line(2091,1950,2191,1950)

	oProforma:Box(2191,025,2251,nHPage)
	oProforma:Box(2251,025,2311,nHPage)

	oProforma:Box(2311,025,2611,nHPage)
	oProforma:Say(2461,050, "FINES", oFont10n)
	oProforma:Line(2311,200,2611,200)

	oProforma:Say(2351,210, "DELIVERY", oFont10n)
	oProforma:Say(2341,490, "1-IF THE SHIPMENT DOES NOT HAPPEN WITHIN THE DELIVERY TIME INFORMED ON THIS DOCUMENT, THE FACTORY/SUPPLIER SHOULD PAY A FINE OF 0,5% OF TOTAL FOB, FOR EVERY DAY DELAY.", oFont08n)
	oProforma:Say(2361,490, "2-THE FACTORY/SUPPLIER WILL BE CHARGED A FINE OF 0,5% OF TOTAL FOB, FOR EVERY DAY OF DELAY ON READINESS OF CARGO, PLUS A FINE OF 10% OF TOTAL FOB VALUE, IF THE ORDER", oFont08n)
	oProforma:Say(2381,490, "IS CANCELLED BY THEM (i.e., BY THE SUPPLIER/MANUFACTURER).",oFont08n)
	
	oProforma:Say(2451,210, "QUALITY", oFont10n)
	
	oProforma:Say(2411,490, "FACTORY/SUPPLIER SHOULD PAY TO OUROLUX FOR ANY QUALITY PROBLEM DETECTED. IF THE PROBLEM IS DETECTED IN OUR WAREHOUSE, EXTRA COSTS OBTAINED FROM BRAZILIAN CUSTOMS" ,oFont08n)
	oProforma:Say(2431,490, "(FREIGHT, REWORK) AND OTHERS WILL BE CHARGED AS WELL. IF FIRST PSI IS NOT APPROVED, FUTURE INSPECTIONS WILL BE SUPPORTED BY SUPPPLIER. (USD300.00 / MAN DAY) FROM",oFont08n)
	oProforma:Say(2451,490, "THE FACTORY / EXPORTER ON THE PO'S PAYMENT",oFont08n)

	oProforma:Say(2551,210, "COMPLIANCE", oFont10n)

	oProforma:Say(2481,490, "ATTENTION: THE FACTORY/SUPPLIER SHOULD FOLLOW OUROLUX TECHNICAL DOCUMENTS STRICTLY. IF NECESSARY ANY CHANGE, IT MUST BE APPROVED IN ADVANCED WITH QUALITY CONTROL" ,oFont08n)
	oProforma:Say(2501,490, "TEAM AND SUPPLY TEAM BEFORE ORDER ACCEPT. IF OUROLUX FIND ANY CHANGE ON THE INSPECTION OR AFTER INSPECTION, THE SUPPLIER’S PENALTY WILL BE 20% OF TOTAL AMOUNT." ,oFont08n)
	oProforma:Line(2311,480,2611,480)

	
	
	
	
	
	
	
	
	
	


	
//
//	
//	
//


Return
