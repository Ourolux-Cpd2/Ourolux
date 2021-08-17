#Include "Colors.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE 'Ap5Mail.ch'

//_____________________________________________________________________________
/*/{Protheus.doc} INV12
Rotina de espelho da NF | Relatorio

@author Juscelino Santos | Icaro Queiroz
@since 20 de Novembro de 2015
@owner FIT Gestao for Ourolux
/*/
//_____________________________________________________________________________
User Function INV12(oGDAProd,oGet1,oGet2,nGet1,nGet6)

	Local cDesc1			:= "Este programa tem como objetivo imprimir Relatorio "
	Local cDesc2			:= "Ficha da OF"
	Local cDesc3			:= "Ficha da OF"
	Local Cabec1			:= "  CODIGO  RAZAO SOCIAL                             LIM.CREDITO   M.COMPRA  ULT.COMPRA  VENDEDOR                       CONTATO"
	Local cPict				:= ""
	Local titulo			:= "Ficha da OF"
	Local nLin				:= 0
	Local Cabec2            := ""
	Local imprime			:= .T.

	Private aOrd			:= {"Descricao","Codigo"}
	Private lEnd			:= .F.
	Private lAbortPrint		:= .F.
	Private CbTxt			:= ""
	Private limite			:= 220
	Private tamanho			:= "G"
	Private nomeprog		:= "FICOF" // Coloque aqui o nome do programa para impressao no cabecalho
	Private nTipo			:= 18
	Private aReturn			:= { "Zebrado", 1, "Administracao", 2, 1, 1, "", 1}
	Private nLastKey		:= 0
	Private cbtxt			:= Space(10)
	Private cbcont			:= 00
	Private CONTFL			:= 01
	Private m_pag			:= 01
	Private wnrel			:= "FICOF" // Coloque aqui o nome do arquivo usado para impressao em disco
	Private cPerg			:= "MTR280C"
	Private cAliasTRB		:="TRB"
	Private cString			:= "SC7"
	Private _pag			:=0
	Private _lpriv			:=.T.
	Private  nLinIniI		:=0
	Private  nLinFimF		:=0
	Private _Flagimp		:=.F.
	Private CR				:= chr(13) + chr(10)

	PRIVATE cDirDocs		:= MsDocPath()
	PRIVATE cPath	   		:= AllTrim(GetTempPath())
	Private _ccont      	:="1o"
	Private cpasta      	:= ""

	Private _cNomeArq      	:= cEmpAnt + cFilAnt + '_'


	Cabec99                  := "CODIGO;RAZAO SOCIAL;LIM.CREDITO;M.COMPRA;ULT.COMPRA;VENDEDOR;CONTATO;EMAIL;"

	_LINHAP:=Space(2)

//******************************************************************
//  PARAMETROS  DE CONFIGURAÇÃO DO AMBIENTE GRAFICO
//******************************************************************

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Seleciona o arquivo                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
/*
cGetFile(<ExpC1>,<ExpC2>,<ExpN1>,<ExpC3>,<ExpL1>,<ExpN2>)
* ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
* <ExpC1> - Expressao de filtro
* <ExpC2> - Titulo da janela
* <ExpN1> - Numero de mascara default 1 para *.Exe
* <ExpC3> - Diretório inicial se necessário
* <ExpL1> - .F. botão salvar - .T. botão abrir
* <ExpN2> - Mascara de bits para escolher as opções de visualização do objeto (prconst.ch)
*/

	cpasta := cGetFile("*.*", "Selecione diretório",,"H:\devolução - pós venda\espelhos de devolução [sistema]\", .T., GETF_NETWORKDRIVE + GETF_LOCALFLOPPY + GETF_LOCALHARD + GETF_RETDIRECTORY )
	cpasta := ALLTRIM( cpasta )

	If AllTrim(cpasta) == '\' .Or. Empty(cpasta) .Or. cpasta = Nil
		Return
	Endif

	MsAguarde({||U_proc12(oGDAProd,oGet1,oGet2,nGet1,nGet6)},"Por favor aguarde...","Pesquisando Dados da Nota...")  //"Por favor aguarde...","Grabando Facturas..."

User Function proc12(oGDAProd,oGet1,oGet2,nGet1,nGet6)
	Local __lSegPg := .F.
//If MsgYesNo("Imprime em PDF ?")
	cStartPath := GetPvProfString(GetEnvServer(),"StartPath","ERROR",GetADV97())
	cStartPath += If(Right(cStartPath,1) <> "\","\","")

	_EMAILTMP := " "

//Objetos para tamanho e tipo das fontes
	oFont1      := TFont():New( "Times New Roman",,12,,.T.,,,,,.F.)
	oFont2      := TFont():New( "Tahoma",,14,,.T.,,,,,.F.)
	oFont3      := TFont():New( "Arial",14,14,,.F.,,,,,.F.)
	oFont3N     := TFont():New( "Arial",11,11,,.T.,,,,,.F.)
	oFont3N1    := TFont():New( "Arial",14,14,,.f.,,,,,.F.)
	oFont3N12   := TFont():New( "Arial",12,12,,.T.,,,,,.F.)
	oFont3N21   := TFont():New( "Arial",12,12,,.F.,,,,,.F.)
	oFont3N12S:= TFont():New( "Arial",09,09,,.T.,,,,,.T.)

	oFont3N2    := TFont():New( "Arial",15,15,,.F.,,,,,.F.)
	oFont3N22   := TFont():New( "Arial",15,15,,.T.,,,,,.F.)

	oFont3N3    := TFont():New( "Arial",25,25,,.F.,,,,,.F.)

	oFont3NT    := TFont():New( "Arial",18,18,.T.,,,,,,.F.)

	oFont4      := TFont():New("Courier New",14,14,,.T.,,,,.T.,.F.)
	oFont41     := TFont():New("Courier New",20,20,.T.,,,,,.T.,.T.)
	oFont41m  := TFont():New("Courier New",18,18,.T.,,,,,.T.,.T.)
	oFont42     := TFont():New("Courier New",25,25,,.T.,,,,.T.,.F.)
	oFont43     := TFont():New("Courier New",12,12,,.T.,,,,.T.,.F.)
	oFont45     := TFont():New("Courier New",12,12,,.T.,,,,.T.,.F.)
	oFont46     := TFont():New( "Courier New",09,09,,.F.,,,,,.F.)
	oFont461    := TFont():New( "Courier New",10,10,,.F.,,,,,.F.)
	oFont462    := TFont():New( "Courier New",08,08,,.F.,,,,,.F.)

// Zera Variveis
	_pag             :=0
	_lpriv           :=.T.
	nLinIniI        :=0
	nLinFimF        :=0
	_Flagimp         :=.F.
	_nitemx:=1
	_nitem  :=0

	oPrn      := FWMSPrinter():New( _cNomeArq + oGDAProd:aCols[1][3] + '.pdf',6,.T.,,.T.,,,,,,,.T.)  // ultimo parametro visualiza o PDF .T.
	oPrn:SetLandscape(.T.)  //oPrn:SetPortrait()
//oPrn:SetPortrait()
	oPrn:SetPaperSize(9)
	oPrn:cPathPDF := cpasta
//oPrn:Setup()
///oPrn:PrintDialog()

	If File("\SYSTEM\" + _cNomeArq + oGDAProd:aCols[1][3] + ".pdf")
		CONOUT("APAGOU O ARQUIVO PDF")
		Ferase("\SYSTEM\" + _cNomeArq + oGDAProd:aCols[1][3] + ".pdf")
	EndIf

	npag        := 0

	_NINV :=1

//Inicia uma nova página
	oPrn:StartPage()

// startando a impressora
//jas oPrn:Say(0, 0, " ",oFont1,100)

	_inclin(@nLinIniI,@nLinFimF,@_nitem)  // Incrementa Linha


//_CABGRAF2x(0)

	_ntotvicm :=0
	_ntotvbicm:=0
	_ntotvipim:=0
	_ntotvstm :=0
	_ntotvtotm:=0

	For ny1 := 1 to Len(oGDAProd:aCols)
		If !oGDAProd:aCols[ny1][Len(oGDAProd:aCols[ny1])]
			_ntotvicm+=oGDAProd:aCols[ny1][13]
			_ntotvbicm+=oGDAProd:aCols[ny1][12]
			_ntotvipim+=oGDAProd:aCols[ny1][18]
			_ntotvstm+=oGDAProd:aCols[ny1][16]
			_ntotvtotm+=oGDAProd:aCols[ny1][08]
		EndIf
	Next ny

	_CABGRAF(1,oGDAProd,oGet1,oGet2,nGet1,nGet6)

	_cab:=.T.
	_nitemx:=1


	For ny := 1 to Len(oGDAProd:aCols)

		If !oGDAProd:aCols[ny][Len(oGDAProd:aCols[ny])]
		// Divisorias JASDIV
			If ( _nitemx < 17 .And. !__lSegPg ) .Or. ( _nitemx < 27 .And. __lSegPg ) //22 // 18
				oPrn:Line(nLinFimF-Iif(_cab,35,70),040,nLinFimF+Iif(_cab,68,68),040) // Barra do Inicio da Linha
				oPrn:Line(nLinFimF-Iif(_cab,35,70),250,nLinFimF+Iif(_cab,68,68),250) // Divisoria do Item
				oPrn:Line(nLinFimF-Iif(_cab,35,70),790,nLinFimF+Iif(_cab,68,68),790) // Divisoria do Item
				oPrn:Line(nLinFimF-Iif(_cab,35,70),860,nLinFimF+Iif(_cab,68,68),860) // Divisoria do Item
				oPrn:Line(nLinFimF-Iif(_cab,35,70),995,nLinFimF+Iif(_cab,68,68),995) // Divisoria do Item
				oPrn:Line(nLinFimF-Iif(_cab,35,70),1120,nLinFimF+Iif(_cab,68,68),1120) // Divisoria do Item
				oPrn:Line(nLinFimF-Iif(_cab,35,70),1310,nLinFimF+Iif(_cab,68,68),1310) // Divisoria do Item
				oPrn:Line(nLinFimF-Iif(_cab,35,70),1500,nLinFimF+Iif(_cab,68,68),1500) // Divisoria do Item
				oPrn:Line(nLinFimF-Iif(_cab,35,70),1570,nLinFimF+Iif(_cab,68,68),1570) // Divisoria do Item
				oPrn:Line(nLinFimF-Iif(_cab,35,70),1685,nLinFimF+Iif(_cab,68,68),1685) // Divisoria do Item        ======  oPrn:Line(nLinFimF-Iif(_cab,35,70),1640,nLinFimF+Iif(_cab,68,68),1640)
				oPrn:Line(nLinFimF-Iif(_cab,35,70),1875,nLinFimF+Iif(_cab,68,68),1875) // Divisoria do Item
				oPrn:Line(nLinFimF-Iif(_cab,35,70),2065,nLinFimF+Iif(_cab,68,68),2065) // Divisoria do Item
				oPrn:Line(nLinFimF-Iif(_cab,35,70),2255,nLinFimF+Iif(_cab,68,68),2255) // Divisoria do Item        == 2255 ==> 2145
				oPrn:Line(nLinFimF-Iif(_cab,35,70),2445,nLinFimF+Iif(_cab,68,68),2445) // Divisoria do Item
				oPrn:Line(nLinFimF-Iif(_cab,35,70),2635,nLinFimF+Iif(_cab,68,68),2635) // Divisoria do Item
				oPrn:Line(nLinFimF-Iif(_cab,35,70),2825,nLinFimF+Iif(_cab,68,68),2825) // Divisoria do Item
				oPrn:Line(nLinFimF-Iif(_cab,35,70),3015,nLinFimF+Iif(_cab,68,68),3015) // Divisoria do Item
			
			EndIf
		
			If _cab
				_som:=00
				_som1:=40
				_cab:=.F.
			Else
				_som:=35
				_som1:=80
			EndIf
		
		//// Verfificando o Codigo do CFOP
			_cfoptmp:=" "
			//If ( SA1->A1_EST <> "SP" .And. ( AllTrim( cFilAnt ) == '01' .Or. AllTrim( cFilAnt ) == '03' ) ) .Or. ( SA1->A1_EST <> "PR" .And. AllTrim( cFilAnt ) == '02' ) .Or. ( SA1->A1_EST <> "RJ" .And. AllTrim( cFilAnt ) == '04' ) .Or. ( SA1->A1_EST <> "PE" .And. AllTrim( cFilAnt ) == '05' )
			If ( SA1->A1_EST <> "SP" .And. ( AllTrim( cFilAnt ) == '01' .Or. AllTrim( cFilAnt ) == '03' ) ) .Or. ( SA1->A1_EST <> "PR" .And. AllTrim( cFilAnt ) == '02' ) .Or. ( SA1->A1_EST <> "RJ" .And. AllTrim( cFilAnt ) == '04' ) .Or. ( SA1->A1_EST <> "PE" .And. AllTrim( cFilAnt ) == '05' )  .Or. ( SA1->A1_EST <> "SC" .And. AllTrim( cFilAnt ) == '06' )
				If oGDAProd:aCols[ny][16] <> 0
					_cfoptmp:="6411"
				Else
					_cfoptmp:="6202"
				EndIf
			Else
				If oGDAProd:aCols[ny][16] <> 0
					_cfoptmp:="5411"
				Else
					_cfoptmp:="5202"
				EndIf
			EndIf
			
			oPrn:say(nLinIniI+_som,040,oGDAProd:aCols[ny][01],oFont3N21)//oPrn:say(nLinIniI+_som,080,SZ7->Z7_ITEM,oFont3N21) // Item
			oPrn:say(nLinIniI+_som,250,SubStr(oGDAProd:aCols[ny][02],1,30),oFont3N21)//oPrn:say(nLinIniI+_som,080,SZ7->Z7_ITEM,oFont3N21) // Item
			oPrn:say(nLinIniI+_som,790,Posicione( 'SB1', 1, xFilial( 'SB1' ) + RTrim( oGDAProd:aCols[ny][01] ), 'B1_UM' ),oFont3N21)//oPrn:say(nLinIniI+_som,080,SZ7->Z7_ITEM,oFont3N21) // Item
			oPrn:say(nLinIniI+_som,895,Transform(oGDAProd:aCols[ny][06],"@E 999,999.99"),oFont3N21)//oPrn:say(nLinIniI+_som,080,SZ7->Z7_ITEM,oFont3N21) // Item
			oPrn:say(nLinIniI+_som,995,oGDAProd:aCols[ny][03],oFont3N21)//oPrn:say(nLinIniI+_som,080,SZ7->Z7_ITEM,oFont3N21) // Item
			oPrn:say(nLinIniI+_som,1160,Transform(oGDAProd:aCols[ny][07],"@E 999,999,999.99"),oFont3N21)//oPrn:say(nLinIniI+_som,080,SZ7->Z7_ITEM,oFont3N21) // Item
			oPrn:say(nLinIniI+_som,1350,Transform(oGDAProd:aCols[ny][08],"@E 999,999,999.99"),oFont3N21)//oPrn:say(nLinIniI+_som,080,SZ7->Z7_ITEM,oFont3N21) // Item
		//oPrn:say(nLinIniI+_som,1500,oGDAProd:aCols[ny][09],oFont3N21)//oPrn:say(nLinIniI+_som,080,SZ7->Z7_ITEM,oFont3N21) // Item
			oPrn:say(nLinIniI+_som,1500,_cfoptmp,oFont3N21)//oPrn:say(nLinIniI+_som,080,SZ7->Z7_ITEM,oFont3N21) // Item
			oPrn:say(nLinIniI+_som,1570,oGDAProd:aCols[ny][11],oFont3N21)//oPrn:say(nLinIniI+_som,080,SZ7->Z7_ITEM,oFont3N21) // Item
			oPrn:say(nLinIniI+_som,1725,Transform(oGDAProd:aCols[ny][12],"@E 999,999,999.99"),oFont3N21)//oPrn:say(nLinIniI+_som,080,SZ7->Z7_ITEM,oFont3N21) // Item
			oPrn:say(nLinIniI+_som,1915,Transform(oGDAProd:aCols[ny][13],"@E 999,999,999.99"),oFont3N21)//oPrn:say(nLinIniI+_som,080,SZ7->Z7_ITEM,oFont3N21) // Item
			oPrn:say(nLinIniI+_som,2080,Transform(oGDAProd:aCols[ny][14],"@E 999,999,999.99"),oFont3N21)//oPrn:say(nLinIniI+_som,080,SZ7->Z7_ITEM,oFont3N21) // Item
			oPrn:say(nLinIniI+_som,2292,Transform(oGDAProd:aCols[ny][15],"@E 999,999,999.99"),oFont3N21)//oPrn:say(nLinIniI+_som,080,SZ7->Z7_ITEM,oFont3N21) // Item
			oPrn:say(nLinIniI+_som,2482,Transform(oGDAProd:aCols[ny][16],"@E 999,999,999.99"),oFont3N21)//oPrn:say(nLinIniI+_som,080,SZ7->Z7_ITEM,oFont3N21) // Item
			oPrn:say(nLinIniI+_som,2650,Transform(oGDAProd:aCols[ny][17],"@E 999,999,999.99"),oFont3N21)//oPrn:say(nLinIniI+_som,080,SZ7->Z7_ITEM,oFont3N21) // Item
			oPrn:say(nLinIniI+_som,2862,Transform(oGDAProd:aCols[ny][18],"@E 999,999,999.99"),oFont3N21)//oPrn:say(nLinIniI+_som,080,SZ7->Z7_ITEM,oFont3N21) // Item
			_flagx:=.F.
			oPrn:Box(nLinFimF+Iif(_cab,38,38),040,nLinFimF+Iif(_cab,38,38),3015) // 2970 coluna
			oPrn:Box(nLinFimF+Iif(_cab,38,38),040,nLinFimF+Iif(_cab,38,38),3015) // 2970 coluna
			nLinFimF:=nLinFimF+Iif(_cab,38,38)
		
		//SZ7->(DbSkip())
			_nitemx++
			If ( _nitemx > 17 .And. !__lSegPg ) .Or. ( _nitemx > 27 .And. __lSegPg ) //20 // 18
			//_CABGRAF2x(0)
				_CABGRAF(0,oGDAProd,oGet1,oGet2,nGet1,nGet6, .F.) // por Icaro Queiroz em 09 de Agosto de 2016 - inibir cabecalho na segunda pagina
				_nitemx		:= 1
				__lSegPg	:= .T.
			Else
				_inclin(@nLinIniI,@nLinFimF,@_nitem)  // Incrementa Linha
			EndIf
		EndIf
	Next ny  //Next _yy

	_nadBST:=0
	_nVST  :=0
	_nVIPI :=0
	_cdocori:=""

	If ( _nitemx > 17 .And. !__lSegPg ) .Or. ( _nitemx > 27 .And. __lSegPg )//22 // 18
		_CABGRAF(0,oGDAProd,oGet1,oGet2,nGet1,nGet6, .F. )// por Icaro Queiroz em 09 de Agosto de 2016 - inibir cabecalho na segunda pagina
		_nitemx:=1
		__lSegPg	:= .T.
	Else
		_inclin(@nLinIniI,@nLinFimF,@_nitem)  // Incrementa Linha
	EndIf

	For nz := 1 to Len(oGDAProd:aCols)

		If !oGDAProd:aCols[nz][Len(oGDAProd:aCols[nz])]
			_nadBST+=oGDAProd:aCols[nz][15]
			_nVST+=oGDAProd:aCols[nz][16]
			_nVIPI+=oGDAProd:aCols[nz][18]
			If !Empty(oGDAProd:aCols[nz][03])
				If At(oGDAProd:aCols[nz][03],_cdocori)<=0
					_cdocori+=oGDAProd:aCols[nz][03]+" / "
				EndIf
			EndIf
		EndIf
	Next nz
////////////////////////////////////////////////////////////////////////////////////////////////////////////
	nColIni		:= 040 //065  //00
	nColFim		:= 3015 //1425 //1690//3410/2970

	oPrn:say(nLinFimF,040,"D A D O S   A D I C I O N A I S : ",oFont3N1) // linha,coluna

	_inclin(@nLinIniI,@nLinFimF,@_nitem)  // Incrementa Linha
	
	oPrn:Box(nLinIniI,nColIni,nLinFimF+140,nColFim)
	
	oPrn:say(nLinFimF+20,040,"Base De ST R$ :",oFont3N) // linha,coluna
	oPrn:say(nLinFimF+20,255,Transform(_nadBST,"@E 999,999,999.99"),oFont3N)
	_inclin(@nLinIniI,@nLinFimF,@_nitem)  // Incrementa Linha

	oPrn:say(nLinFimF+20,040,"Valor De ST R$ :",oFont3N) // linha,coluna
	oPrn:say(nLinFimF+20,255,Transform(_nVST,"@E 999,999,999.99"),oFont3N)
	_inclin(@nLinIniI,@nLinFimF,@_nitem)  // Incrementa Linha

	oPrn:say(nLinFimF+20,040,"Valor Do IPI R$ :",oFont3N) // linha,coluna
	oPrn:say(nLinFimF+20,255,Transform(_nVIPI,"@E 999,999,999.99"),oFont3N)
	_inclin(@nLinIniI,@nLinFimF,@_nitem)  // Incrementa Linha

	oPrn:say(nLinFimF+20,040,"Notas de Origem :",oFont3N) // linha,coluna
	oPrn:say(nLinFimF+20,270,_cdocori,oFont3N)


//_NOF:='Rel001.pdf'

	oPrn:EndPage()

	If MsgYesNo("Deseja Visualizar o PDF ?")
		oPrn:Preview()
	EndIf
	conout("fim do relatorio-02-01")

	FreeObj(oPrn)
	oPrn := Nil

	_xxx:="ok"
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

Static Function _CABGRAF2(_param)
	If _param = 0
	//Encerra a página
		oPrn:EndPage()
	//Inicia uma nova página
		oPrn:StartPage()
	EndIf
	_pag:=_pag+1
// Boxe do Quadro Geral  //
	nLinIni		:= 040
	nColIni		:= 065  //00
	nColFim		:= 3410
	nLinFim		:= 2500
	oPrn:Box(nLinIni,nColIni,nLinFim,nColFim)
	oPrn:SayBitmap(050,0200,cStartPath+"Caraiba01.PNG",500,300)
	oPrn:say(050,1600,"PEDIDO DE COMPRA - PC",oFont42)
	oPrn:say(165,1350,"Número : ",oFont3N) // linha,coluna
	oPrn:say(165,1600,"000001",oFont42)
	oPrn:say(165,3030,"Folha: "+StrZero(_pag,3),oFont3N) // linha,coluna
	oPrn:Box(370,066,370,3409)
Return


Static Function _inclin(nLinIniI,nLinFimF,_nitem)
	nLinIniI       := nLinFimF+02
	nLinFimF	   := nLinIniI+35
	_nitem+=1
Return

Static Function _CABGRAF(_param,oGDAProd,oGet1,oGet2,nGet1,nGet6, lNewPag) // jascab

	Default lNewPag	:= .T.

	If _param = 0
	//Encerra a página
		oPrn:EndPage()
	//Inicia uma nova página
		oPrn:StartPage()
	EndIf
	_pag:=_pag+1
	_REV:="1"
	_TIPO:=""

	_TIPO:="Reforma"

	If !lNewPag
	// Boxe do Quadro Geral  //
		nLinIniI  	:= 2
		nLinFimF	:= 2
		nColFim		:= 1425 //1690//3410
		nLinFim		:= 450
		_inclin(@nLinIniI,@nLinFimF,@_nitem)
		_inclin(@nLinIniI,@nLinFimF,@_nitem)
	Else
	// Boxe do Quadro Geral  //
		nLinIni		:= 040
		nColIni		:= 040 //065  //00
		nColFim		:= 1425 //1690//3410
		nLinFim		:= 450

	//oPrn:Box(nLinIni,nColIni,nLinFim,nColFim,oFont41)
	///oPrn:SayBitmap(070,1115,cStartPath+"CARAIBA03.png",270,070)
		oPrn:say(080,0890,"Espelho para Emissão de NF de Devolução",oFont41)

		oPrn:say(080,040,"E M I T E N T E",oFont3N1) // linha,coluna
		oPrn:say(120,040,"CNPJ",oFont3N1) // linha,coluna
		oPrn:say(120,350,":  "+Transform(Alltrim(SA1->A1_CGC),"@R 99.999.999/9999-99" ),oFont3N12) // linha,coluna
		oPrn:say(160,040,"Código do Cliente",oFont3N1) // linha,coluna
		oPrn:say(160,350,":  "+SA1->A1_COD+" - Loja : "+SA1->A1_LOJA,oFont3N12) // linha,coluna
		oPrn:say(200,040,"Razão Social",oFont3N1) // linha,coluna
		oPrn:say(200,350,":  "+Alltrim(SA1->A1_NOME),oFont3N12) // linha,coluna
		oPrn:say(240,040,"Endereço do Cliente",oFont3N1) // linha,coluna
		oPrn:say(240,350,":  "+Capital(Alltrim(SA1->A1_END))+"  -  Bairro: "+Capital(Alltrim(SA1->A1_BAIRRO))+"  -  Cidade: "+Capital(Alltrim(SA1->A1_MUN))+"  -  UF: "+Alltrim(SA1->A1_EST)+"  -  CEP: "+Transform(Alltrim(SA1->A1_CEP),"@R 99999-999" ),oFont3N12) // linha,coluna
		oPrn:say(280,040,"E-Mail",oFont3N1) // linha,coluna
		oPrn:say(280,350,":  "+Lower(Alltrim(SA1->A1_EMAIL)),oFont3N12) // linha,coluna
		oPrn:say(340,040,"Natureza da Operação: Devolução de Compra",oFont3N1) // linha,coluna jas??

		oPrn:say(400,040,"D E S T I N A T A R I O",oFont3N1) // linha,coluna
		oPrn:say(440,040,"CNPJ",oFont3N1) // linha,coluna
		oPrn:say(440,260,":  "+Transform(Alltrim(SM0->M0_CGC),"@R 99.999.999/9999-99" ),oFont3N12) // linha,coluna
		oPrn:say(480,040,"Razão Social",oFont3N1) // linha,coluna
		oPrn:say(480,260,":  "+Alltrim(SM0->M0_NOMECOM),oFont3N12) // linha,coluna
		oPrn:say(520,040,"Endereço",oFont3N1) // linha,coluna
		oPrn:say(520,260,":  "+Capital(Alltrim(SM0->M0_ENDCOB))+"  -  Bairro: "+Capital(Alltrim(SM0->M0_BAIRENT))+"  -  Cidade: "+Capital(Alltrim(SM0->M0_CIDCOB))+"  -  UF: "+Alltrim(SM0->M0_ESTCOB)+"  -  CEP: "+Transform(Alltrim(SM0->M0_CEPCOB),"@R 99999-999" ),oFont3N12) // linha,coluna
		oPrn:say(560,040,"E-Mail",oFont3N1) // linha,coluna
		oPrn:say(560,260,":  nfe@ourolux.com.br",oFont3N12) // linha,coluna
	
		nLinIniI        :=0
		nLinFimF        :=0
		_inclin(@nLinIniI,@nLinFimF,@_nitem)  // Incrementa Linha
		oPrn:say(610,040,"C A L C U L O S  D E  I M P O S T O S : ",oFont3N1) // linha,coluna
	
		nLinIniI:=620 //440
		nLinFimF:=620 //440
	
		oPrn:Box(nLinIniI,nColIni,nLinFimF+90,nColFim)
		oPrn:say(nLinFimF+40,040,"Base de Calculo do ICMS",oFont3N) // linha,coluna
		oPrn:say(nLinFimF+80,230,Transform(_ntotvbicm,"@E 999,999,999.99"),oFont3N)
		oPrn:Line(nLinFimF-5,400,nLinFimF+98,400) // Divisoria do Item        lin : 98
		oPrn:say(nLinFimF+40,405,"Valor do ICMS",oFont3N) // linha,coluna
		oPrn:say(nLinFimF+80,445,Transform(_ntotvicm,"@E 999,999,999.99"),oFont3N)
		oPrn:Line(nLinFimF-5,615,nLinFimF+98,615) // Divisoria do Item
		oPrn:say(nLinFimF+40,620,"Outras Despesas",oFont3N) // linha,coluna

		If SA1->A1_EST $ "MG/RS/BA"//Para MG nao somar ICMS-ST em outras despesas
			oPrn:say(nLinFimF+80,700,Transform(_ntotvipim,"@E 999,999,999.99"),oFont3N)
		Else
			oPrn:say(nLinFimF+80,700,Transform(_ntotvipim+_ntotvstm,"@E 999,999,999.99"),oFont3N)
		Endif

		oPrn:Line(nLinFimF-5,870,nLinFimF+98,870) // Divisoria do Item
		oPrn:say(nLinFimF+40,875,"Valor Tot.Produtos",oFont3N) // linha,coluna
		oPrn:say(nLinFimF+80,990,Transform(nGet1,"@E 999,999,999.99"),oFont3N)
		oPrn:Line(nLinFimF-5,1160,nLinFimF+98,1160) // Divisoria do Item

		oPrn:say(nLinFimF+40,1165,"Valor Total NF",oFont3N) // linha,coluna

		/*If SA1->A1_EST == "MG"//Para MG nao somar ICMS-ST No Valor Total da NF
			oPrn:say(nLinFimF+80,1255,Transform(nGet6-_ntotvstm,"@E 999,999,999.99"),oFont3N)
		Else*/
			oPrn:say(nLinFimF+80,1255,Transform(nGet6,"@E 999,999,999.99"),oFont3N)
		//EndIf
			
		//oPrn:Line(nLinFimF-5,1425,nLinFimF+98,1425) // Divisoria do Item
		//oPrn:Line(nLinFimF-5,1690,nLinFimF+98,1690) // Divisoria do Item
	
		nLinFimF+=130
		nLinIniI:=nLinFimF
		nColIni		:= 040 //065  //00
		nColFim		:= 3015 //1690//3410/2970
	
	//////////////////////////////////
	
	//nLinIniI:=180 //440
	//LinFimF:=180  //440
	
		oPrn:Box(nLinIniI,nColIni,nLinFimF+115,nColFim)
		oPrn:say(nLinFimF+40,080,"CODIGO",oFont3N) // linha,coluna
		oPrn:Line(nLinFimF-5,250,nLinFimF+115,250) // Divisoria do Item        lin : 98
		oPrn:say(nLinFimF+40,290,"DESCRIÇÃO",oFont3N) // linha,coluna
		oPrn:Line(nLinFimF-5,790,nLinFimF+115,790) // Divisoria do Item
		oPrn:say(nLinFimF+40,795,"UM",oFont3N) // linha,coluna
		oPrn:Line(nLinFimF-5,860,nLinFimF+115,860) // Divisoria do Item
		oPrn:say(nLinFimF+40,865,"QUANT.",oFont3N) // linha,coluna
		oPrn:Line(nLinFimF-5,995,nLinFimF+115,995) // Divisoria do Item
		oPrn:say(nLinFimF+40,1000,"NF Origem",oFont3N) // linha,coluna
		oPrn:Line(nLinFimF-5,1120,nLinFimF+115,1120) // Divisoria do Item
		oPrn:say(nLinFimF+40,1125,"Vlr.Unitario",oFont3N) // linha,coluna
		oPrn:Line(nLinFimF-5,1310,nLinFimF+115,1310) // Divisoria do Item
		oPrn:say(nLinFimF+40,1315,"Vlr.Total",oFont3N) // linha,coluna
		oPrn:Line(nLinFimF-5,1500,nLinFimF+115,1500) // Divisoria do Item
		oPrn:say(nLinFimF+40,1505,"CFOP",oFont3N) // linha,coluna
		oPrn:Line(nLinFimF-5,1570,nLinFimF+115,1570) // Divisoria do Item
		oPrn:say(nLinFimF+40,1575,"NCM",oFont3N) // linha,coluna
		oPrn:Line(nLinFimF-5,1685,nLinFimF+115,1685) // Divisoria do Item   1685 - 1640   = 45
		oPrn:say(nLinFimF+40,1690,"Base ICMS",oFont3N) // linha,coluna
		oPrn:Line(nLinFimF-5,1875,nLinFimF+115,1875) // Divisoria do Item
		oPrn:say(nLinFimF+40,1880,"Valor ICMS",oFont3N) // linha,coluna
		oPrn:Line(nLinFimF-5,2065,nLinFimF+115,2065) // Divisoria do Item
		oPrn:say(nLinFimF+40,2070,"Aliq. ICMS",oFont3N) // linha,coluna
		oPrn:Line(nLinFimF-5,2255,nLinFimF+115,2255) // Divisoria do Item
		oPrn:say(nLinFimF+40,2260,"Base ST",oFont3N) // linha,coluna
		oPrn:Line(nLinFimF-5,2445,nLinFimF+115,2445) // Divisoria do Item
		oPrn:say(nLinFimF+40,2450,"Valor ST",oFont3N) // linha,coluna
		oPrn:Line(nLinFimF-5,2635,nLinFimF+115,2635) // Divisoria do Item
		oPrn:say(nLinFimF+40,2640,"Aliquota IPI",oFont3N) // linha,coluna
		oPrn:Line(nLinFimF-5,2825,nLinFimF+115,2825) // Divisoria do ItSem
		oPrn:say(nLinFimF+40,2830,"Valor IPI",oFont3N) // linha,coluna
		nLinFimF+=150
		nLinIniI:=nLinFimF
	EndIf

Return( Nil )

Static Function _CABGRAF2x(_param)
	If _param = 0
	//Encerra a página
		oPrn:EndPage()
	//Inicia uma nova página
		oPrn:StartPage()
	EndIf


	_pag:=_pag+1
	_REV:="1"
// Boxe do Quadro Geral  //
	nLinIni		:= 040
	nColIni		:= 065  //00
	nColFim		:= 1690 //2450//3410
	nLinFim		:= 450
	oPrn:Box(nLinIni,nColIni,nLinFim,nColFim)
	oPrn:SayBitmap(050,0100,cStartPath+"Caraiba01.PNG",500,300)
	oPrn:say(100,0840,"DADOS GERAIS DO PEDIDO",oFont41)
	oPrn:say(200,0940,"OF - Rev. "+_REV,oFont41)
	oPrn:say(300,0990,"---",oFont41)
	oPrn:say(160,1975,"Pagina  :"+StrZero(_pag,3),oFont3N1) // linha,coluna
	oPrn:say(290,1975,"Emissão :"+Dtoc(Ddatabase),oFont3N1) // linha,coluna

