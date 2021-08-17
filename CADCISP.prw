#INCLUDE "rwmake.ch"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH" 
#include "protheus.ch"
#include "fileio.ch"      

#DEFINE ENTER Chr(13)+Chr(10)
#DEFINE lEmbed .T.
///////////////////////////////////////////////////////////////////////////////////
//+-----------------------------------------------------------------------------+//
//| PROGRAMA  | CADCISP.PRW         | AUTOR | Raul Capeleti | DATA | 01/12/2011 |//
//+-----------------------------------------------------------------------------+//
//| DESCRICAO | Gerar arquivo texto para envio de informações cadastrais        |//
//|           | para a CISP, conforme layout padrão fornecido pela entidade.    |//
//|           |                                                                 |//
//+-----------------------------------------------------------------------------+//
//| MANUTENCAO DESDE SUA CRIACAO                                                |//
//+-----------------------------------------------------------------------------+//
//| DATA     | AUTOR                | DESCRICAO                                 |//
//+-----------------------------------------------------------------------------+//
//|          |                      |                                           |//
//+-----------------------------------------------------------------------------+//
///////////////////////////////////////////////////////////////////////////////////

/*********************/
User Function CADCISP()
/*********************/

	Private cSubDir1 := "C:\CISP\Log\"
	Private cLogDir  := cSubDir1 //StrTran(cRootPath+ cSubDir1  ,"\\","\")            
	Private cFileLog := cLogDir  +"s_CADCISP"+Dtos(dDataBase)+".log"
	Private lGeraLog := .T.  
	
	MakeDir("C:\CISP\")
	MakeDir("C:\CISP\Log\")

	DbSelectArea("SZY")
	
	cCadastro := "Cadastro CISP - 01/09/2017"
	
	_dDATADE   := YEARSUB(DATAVALIDA(dDatabase-3,.F.),1)
	VlrLiCre := 0
	
	oFont1 := TFont():New("MS Sans Serif",,016,,.F.,,,,,.F.,.F.)
	
	
	aRotina   := { { "Pesquisar"       ,"AxPesqui"  , 0, 1},;
	{ "Visualizar"	   ,"U_VISUAL"  , 0, 2},;
	{ "Incluir"	       ,"AxInclui"  , 0, 3},;
	{ "Alterar"		   ,"U_ALTERA"  , 0, 4},;
	{ "Excluir"         ,"AxDeleta"  , 0, 5},;
	{ "Atualizar"       ,"U_ATUAL1"  , 0, 6},;
	{ "Grava TXT"       ,"U_GRVRTXT" , 0, 7},;
	{ "Limite Cred"     ,"U_LIMITE"  , 0, 8},;
	{ "Valida Inf."     ,"U_VALINF"  , 0, 9}}
	
	//{ "Sint./Receita/Sufr.","U_SINTEG"  , 0, 8}}
	//{ "Valida Inf."     ,"U_VALINF"  , 0, 9}}
	aArray := {}
	
	SZY->(mBrowse(06,01,22,75,"SZY",,,,,,))
	
	SZY->(DbCloseArea())
	
Return

/*------------------*/
User Function Limite()
/*------------------*/
MsgRun("Atualizando os dados - Aguarde...","Processando", {||LIMITES()}, "Atualizando"   )
Return
/*------------------*/
Static Function LimiteS()
/*------------------*/
SZY->(dbGoTop())
VlrLiCre := 0
While ! SZY->(Eof())
	VlrLiCre := VerCred(ALLTRIM(SZY->ZY_PCCCLI))
	Reclock("SZY",.F.)
	SZY->ZY_PCVLCR := VlrLiCre // Valor Limite de Credito
	SZY->ZY_PCVSIT := IIf(SZY->ZY_PCVLCR <= 10, "5","2") // Situação do Cálculo Limite de Crédito
	MsUnlock()
	VlrLiCre := 0
	SZY->(DbSkip())
End
Return

/*------------------*/
User Function Visual()
/*------------------*/
Local nOpca := 0
Private  aButtons := {}
Private cCadastro := "Cadastro Cisp" // título da tela
Private _aCamposVis := {"NOUSER", "ZY_FILIAL", "ZY_PCTIPO", "ZY_PCCASS" , "ZY_PCCCLI", "ZY_PCDDAT", "ZY_PCDCDD", "ZY_PCDUCM", "ZY_PCVULC" ,"ZY_PCDMAC","ZY_PCVMAC","ZY_PCVSAT","ZY_PCVLCR",;
"ZY_PCQPAG","ZY_PCQDAP","ZY_PCVDAV","ZY_PCMDAV","ZY_PCMPMV","ZY_PCDATV","ZY_PCMPTV","ZY_PCV15D","ZY_PCM15D","ZY_PCV30D","ZY_PCM30D","ZY_PCDTPC","ZY_PCVPCO","ZY_PCVSIT",;
"ZY_PCTIPG","ZY_PCGGA","ZY_PCDTG","ZY_PCVLG","ZY_PCVPA","ZY_PCSVV" }
//adiciona botoes na Enchoice
aAdd(aButtons, { "RECALC", {|| MsgRun("Selecionando Registros...","Aguarde",{||ContaCor()})}, "Conta Corrente", "C.Corrente" } )
AaDD(aButtons, { "POSCLI", {|| MsgRun("Selecionando Registros...","Aguarde",{||Cadastral()})}, "Cadastro do Cliente","Cadastro" } )
dbSelectArea("SZY")
nOpca := AxVisual("SZY",SZY->(Recno()),2,_aCamposVis, , , ,aButtons,,,,,,,,,)
Return nOpca

/*------------------*/
User Function Altera()
/*------------------*/
Local nOpca := 0
Local aParam := {}
Private aCpos := {"NOUSER", "ZY_FILIAL", "ZY_PCTIPO", "ZY_PCCASS" , "ZY_PCCCLI", "ZY_PCDDAT", "ZY_PCDCDD", "ZY_PCDUCM", "ZY_PCVULC" ,"ZY_PCDMAC","ZY_PCVMAC","ZY_PCVSAT","ZY_PCVLCR",;
"ZY_PCQPAG","ZY_PCQDAP","ZY_PCVDAV","ZY_PCMDAV","ZY_PCMPMV","ZY_PCDATV","ZY_PCMPTV","ZY_PCV15D","ZY_PCM15D","ZY_PCV30D","ZY_PCM30D","ZY_PCDTPC","ZY_PCVPCO","ZY_PCVSIT",;
"ZY_PCTIPG","ZY_PCGGA","ZY_PCDTG","ZY_PCVLG","ZY_PCVPA","ZY_PCSVV" }  // CAMPOS que permite edição
Private  aButtons := {}
Private cCadastro := "Cadastro Cisp" // título da tela
aAdd(aButtons, { "RECALC", {|| MsgRun("Selecionando Registros...","Aguarde",{||ContaCor()})}, "Conta Corrente", "C.Corrente" } )

dbSelectArea("SZY")
nOpca := AxAltera("SZY",SZY->(Recno()),4,,aCpos,,,,,, aButtons,aParam,,,.T.,,,,,)
Return nOpca


/*-----------------------*/
Static Function Cadastral()
/*-----------------------*/
Local _aArea := GetArea()
cMsg := ''
SA1->(DBSetOrder(3))
If SA1->(DbSeek(xFilial("SA1")+alltrim(SZY->ZY_PCCCLI)))
	cMsg += 'Código  - Lj - Nome '  +CHR(13)
	cMsg += '--------------------------------------------------------'+chr(13)
	While SUBSTR(SA1->A1_CGC,1,8) == alltrim(SZY->ZY_PCCCLI)
		cMsg += SA1->A1_COD+' - '+SA1->A1_LOJA+' - '+SA1->A1_NOME+" LC- "+Transform(SA1->A1_LC,"@E 999,999,999.99")+CHR(13)
		SA1->(DbSkip())
	End
Else
	MsgAlert("Cliente não encontrado","Atenção")
	RestArea(_aArea)
	Return
Endif
MsgAlert(cMsg,"Informações Cadastrais")
RestArea(_aArea)
Return
/*----------------------*/
Static Function ContaCor()
/*----------------------*/
Private oButton1
Private oButton2
Private oGet1
Private cGet1 := space(9)
Private oGet2
Private cGet2 := space(3)
Private oGet3
Private cGet3 := " "
Private oGet4
Private cGet4 := " "
Private oPanel1
Private oSay1
Private oSay2
Private oSay3
Private oSay4
Private oWBrowse1
Private aWBrowse1 := {}
Static oDlg

DEFINE MSDIALOG oDlg TITLE "Conta Corrente" FROM 000, 000  TO 500, 800 COLORS RGB(141,192,222), RGB(188,199,205) PIXEL

fWBrowse1()

Carga01(ALLTRIM(SZY->ZY_PCCCLI))

ACTIVATE MSDIALOG oDlg CENTER ON INIT MyEnchoBar(oDlg)
Return

/*----------------------------------*/
STATIC FUNCTION MyEnchoBar(oObj,bObj)
/*----------------------------------*/
LOCAL oBar, lOk, lVolta, lLoop, oBtnPsq, oBtnUsr, oBtnImp, oBtnOk, oBtnHlp
DEFINE BUTTONBAR oBar SIZE 25,25 3D TOP OF oObj
//DEFINE BUTTONBAR oBar SIZE 25,25 3D TOP OF oObj 2019 war 
//DEFINE BUTTONBAR oBarCadCalend SIZE 15,15 3D BOTTOM OF oWndDetalhe
DEFINE BUTTON oBtnNp  RESOURCE "MDIEXCEL"   OF oBar ACTION Processa({|lEnd| U_ExXls2() }, 'Processando arquivo...')  TOOLTIP "Exp.Excel"
DEFINE BUTTON oBtOk   RESOURCE "CANCEL"    OF oBar ACTION oDlg:End()  TOOLTIP "Sair"   //  (lLoop:=lVolta,lOk:=Eval(bObj))
oBar:bRClicked:={||AllwaysTrue()}
RETURN NIL


/*----------------------*/
User Function ExporXls1()
/*----------------------*/

cPatSRV :=ALLTRIM(GETMV("MV_RELT"))
cPatREM := "C:\SIGA\"

//+-------------------------------------------------------------------------------
//| Gera arquivo do tipo .DBF com extensao .XLS p/ usuario abrir no Excel.
//+-------------------------------------------------------------------------------
cArqExcel := cPatSRV+"CC"+alltrim(szy->zy_pcccli)+".XLS"
Copy To &cArqExcel VIA "DBFCDXADS"
CpyS2T(cArqExcel,cPatREM)//COPIA SERVER P/ REMOTE
msgalert("Arquivo "+cArqExcel+" copiado para C:\Siga !","Atenção")
Return

/*----------------------*/
User Function ExXls2()
/*----------------------*/
Local nHandle   := 0
Local cArqPesq 	:= "c:\siga\CC"+alltrim(szy->zy_pcccli)+".XLS"
Local cCabHtml  := ""
Local cLinFile  := ""
Local cFileCont := ""
Private nCt      := 0

ProcRegua( nCt )

//Cria um arquivo do tipo *.xls

nHandle := FCREATE(cArqPesq, 0)

//Verifica se o arquivo pode ser criado, caso contrario um alerta sera exibido

If FERROR() != 0
	Alert("Nao foi possivel abrir ou criar o arquivo: " + cArqPesq )
EndIf

//monta cabecalho de pagina HTML para posterior utilizao

cCabHtml := "<!-- Created with AEdiX by Kirys Tech 2000,http://www.kt2k.com --> " + CRLF
cCabHtml += "<!DOCTYPE html PUBLIC '-//W3C//DTD HTML 4.01 Transitional//EN'>" + CRLF
cCabHtml += "<html>" + CRLF
cCabHtml += "<head>" + CRLF
cCabHtml += "  <title>Centro de custo</title>" + CRLF
cCabHtml += "  <meta name='GENERATOR' content='AEdiX by Kirys Tech 2000,http://www.kt2k.com'>" + CRLF
cCabHtml += "</head>" + CRLF
cCabHtml += "<body bgcolor='#FFFFFF'>" + CRLF

cRodHtml := "</body>" + CRLF
cRodHtml += "</html>"

cFileCont := cCabHtml

// cLinFile := "<TABLE>" + CRLF
cLinFile := "<table border='1' cellpadding='3' cellspacing='0' bordercolor='#8B8B83' bgColor='#FFFFFF'>" + CRLF
cLinFile += "<TR>" + CRLF
cLinFile += "<TD align='center' style='Background: #9AC0CD; font-style: Bold;'><b>Documento</b></TD>"+ CRLF
cLinFile += "<TD align='center' style='Background: #9AC0CD; font-style: Bold;'><b>Parcela</b></TD>"+ CRLF
cLinFile += "<TD align='center' style='Background: #9AC0CD; font-style: Bold;'><b>Emissao</b></TD>"+ CRLF
cLinFile += "<TD align='center' style='Background: #9AC0CD; font-style: Bold;'><b>Cnpj</b></TD>"+ CRLF
cLinFile += "<TD align='center' style='Background: #9AC0CD; font-style: Bold;'><b>Fatura</b></TD>"+ CRLF
cLinFile += "<TD align='center' style='Background: #9AC0CD; font-style: Bold;'><b>Pagto.</b></TD>"+ CRLF
cLinFile += "<TD align='center' style='Background: #9AC0CD; font-style: Bold;'><b>Dt.Operacao</b></TD>"+ CRLF
cLinFile += "<TD bgcolor='#6E8B3D' align='center'><FONT face=' Arial ' size=1 color='#FFFFFF'><b>Saldo</b></FONT></TD>"+CRLF
cLinFile += "<TD bgcolor='#6E8B3D' align='center'><FONT face=' Arial ' size=1 color='#FFFFFF'><b>Maior Ac.</b></FONT></TD>"+CRLF
cLinFile += "<TD bgcolor='#6E8B3D' align='center'><FONT face=' Arial ' size=1 color='#FFFFFF'><b>Data M.A.</b></FONT></TD>"+CRLF
cLinFile += "<TD align='center' style='Background: #9AC0CD; font-style: Bold;'><b>Vcto Real</b></TD>"+ CRLF
cLinFile += "<TD align='center' style='Background: #9AC0CD; font-style: Bold;'><b>Dt.Baixa</b></TD>"+ CRLF
cLinFile += "<TD align='center' style='Background: #9AC0CD; font-style: Bold;'><b>Atraso</b></TD>"+ CRLF
cLinFile += "<TD align='center' style='Background: #9AC0CD; font-style: Bold;'><b>Vlr.Atraso</b></TD>"+ CRLF
cLinFile += "<TD align='center' style='Background: #9AC0CD; font-style: Bold;'><b>Dias AV</b></TD>"+ CRLF
cLinFile += "<TD align='center' style='Background: #9AC0CD; font-style: Bold;'><b>Vlr.AV</b></TD>"+ CRLF
cLinFile += "</TR>"+ CRLF


// anexa a linha montada ao corpo da tabela
cFileCont += cLinFile
cLinFile := ""
(FWRITE(nHandle, cFileCont) )

TRD1->(DbGotop())
FLag := .T.

While ! TRD1->(Eof())
	
	IncProc("Gerando")
	If Flag
		IF (SZY->ZY_PCVMAC == TRD1->SALDO .AND. SZY->ZY_PCDMAC == TRD1->DATACC) .or. ;
			(SZY->ZY_PCVPCO == TRD1->F2_VALFAT .AND. SZY->ZY_PCDTPC == TRD1->E1_EMISSAO ) .OR. ;
			(SZY->ZY_PCVULC == TRD1->F2_VALFAT .AND. SZY->ZY_PCDUCM == TRD1->E1_EMISSAO )
			If TRD1->DATACC > YEARSUB(dDatabase,1)
				cLinFile := "<TR>"
				cLinFile += "<TD bgcolor='#FFFFFF' align='center'><FONT face=' Arial ' size=1 color='#FF0000' ><b>"+TRD1->E1_NUM+"</b></FONT></TD>"+CRLF
				cLinFile += "<TD bgcolor='#FFFFFF' align='center'><FONT face=' Arial ' size=1 color='#FF0000' ><b>"+TRD1->E1_PARCELA+"</b></FONT></TD>"+CRLF
				cLinFile += "<TD bgcolor='#FFFFFF' align='center'><FONT face=' Arial ' size=1 color='#FF0000' ><b>"+DTOC(TRD1->E1_EMISSAO)+"</b></FONT></TD>"+CRLF
				cLinFile += "<TD bgcolor='#FFFFFF' align='center'><FONT face=' Arial ' size=1 color='#FF0000' ><b>"+TRD1->CNPJ+"</b></FONT></TD>"+CRLF
				If TRD1->E1_VALOR > 0
					cLinFile += "<TD bgcolor='#FFFFFF' align='right'><FONT face=' Arial ' size=1 color='#FF0000' ><b>"+TRANSFORM(TRD1->E1_VALOR,"@E 9,999,999.99")+"</b></FONT></TD>"+CRLF
					cLinFile += "<TD bgcolor='#FFFFFF' align='right'><FONT face=' Arial ' size=1 color='#FF0000' ><b> </b></FONT></TD>"+CRLF
				Else
					cLinFile += "<TD bgcolor='#FFFFFF' align='right'><FONT face=' Arial ' size=1 color='#FF0000' ><b> </b></FONT></TD>"+CRLF
					cLinFile += "<TD bgcolor='#FFFFFF' align='right'><FONT face=' Arial ' size=1 color='#FF0000' ><b>"+TRANSFORM(TRD1->E1_VALOR,"@E 9,999,999.99")+"</b></FONT></TD>"+CRLF
				Endif
				cLinFile += "<TD bgcolor='#FFFFFF' align='center'><FONT face=' Arial ' size=1 color='#FF0000' ><b>"+DTOC(TRD1->DATACC) +"</b></FONT></TD>"+CRLF
				cLinFile += "<TD bgcolor='#CAFF70' align='right'><FONT face=' Arial ' size=1 color='#FF0000' ><b>"+TRANSFORM(TRD1->SALDO,"@E 9,999,999.99") +"</b></FONT></TD>"+CRLF
				cLinFile += "<TD bgcolor='#CAFF70' align='right'><FONT face=' Arial ' size=1 color='#FF0000' ><b>"+TRANSFORM(TRD1->MAIORAC,"@E 9,999,999.99") +"</b></FONT></TD>"+CRLF
				cLinFile += "<TD bgcolor='#CAFF70' align='center'><FONT face=' Arial ' size=1 color='#FF0000' ><b>"+DTOC(TRD1->DATAMAC) +"</b></FONT></TD>"+CRLF
				cLinFile += "<TD bgcolor='#FFFFFF' align='center'><FONT face=' Arial ' size=1 color='#FF0000' ><b>"+DTOC(TRD1->E1_VENCREA) +"</b></FONT></TD>"+CRLF
				cLinFile += "<TD bgcolor='#FFFFFF' align='center'><FONT face=' Arial ' size=1 color='#FF0000' ><b>"+DTOC(TRD1->E1_BAIXA) +"</b></FONT></TD>"+CRLF
				cLinFile += "<TD bgcolor='#FFFFFF' align='right'><FONT face=' Arial ' size=1 color='#FF0000' ><b>"+TRANSFORM(TRD1->DIATRA,"@E 9,999") +"</b></FONT></TD>"+CRLF
				cLinFile += "<TD bgcolor='#FFFFFF' align='right'><FONT face=' Arial ' size=1 color='#FF0000' ><b>"+TRANSFORM(TRD1->VLRCALC,"@E 999,999,999.99") +"</b></FONT></TD>"+CRLF
				cLinFile += "<TD bgcolor='#FFFFFF' align='right'><FONT face=' Arial ' size=1 color='#FF0000' ><b>"+TRANSFORM(TRD1->DIASAV,"@E 999,999") +"</b></FONT></TD>"+CRLF
				cLinFile += "<TD bgcolor='#FFFFFF' align='right'><FONT face=' Arial ' size=1 color='#FF0000' ><b>"+TRANSFORM(TRD1->VLRAVC,"@E 999,999,999.99") +"</b></FONT></TD>"+CRLF
				cLinFile += "</TR>"
			ELSE
				IF (SZY->ZY_PCVMAC == TRD1->SALDO .AND. SZY->ZY_PCDMAC == TRD1->DATACC) .or. ;
					(SZY->ZY_PCVPCO == TRD1->F2_VALFAT .AND. SZY->ZY_PCDTPC == TRD1->E1_EMISSAO ) .OR. ;
					(SZY->ZY_PCVULC == TRD1->F2_VALFAT .AND. SZY->ZY_PCDUCM == TRD1->E1_EMISSAO )
					cLinFile := "<TR>"
					cLinFile += "<TD bgcolor='#FFFFFF' align='center'><FONT face=' Arial ' size=1 color='#FF0000' ><b>"+TRD1->E1_NUM+"</b></FONT></TD>"+CRLF
					cLinFile += "<TD bgcolor='#FFFFFF' align='center'><FONT face=' Arial ' size=1 color='#FF0000' ><b>"+TRD1->E1_PARCELA+"</b></FONT></TD>"+CRLF
					cLinFile += "<TD bgcolor='#FFFFFF' align='center'><FONT face=' Arial ' size=1 color='#FF0000' ><b>"+DTOC(TRD1->E1_EMISSAO)+"</b></FONT></TD>"+CRLF
					cLinFile += "<TD bgcolor='#FFFFFF' align='center'><FONT face=' Arial ' size=1 color='#FF0000' ><b>"+TRD1->CNPJ+"</b></FONT></TD>"+CRLF
					If TRD1->E1_VALOR > 0
						cLinFile += "<TD bgcolor='#FFFFFF' align='right'><FONT face=' Arial ' size=1 color='#FF0000' ><b>"+TRANSFORM(TRD1->E1_VALOR,"@E 9,999,999.99")+"</b></FONT></TD>"+CRLF
						cLinFile += "<TD bgcolor='#FFFFFF' align='right'><FONT face=' Arial ' size=1 color='#FF0000' ><b> </b></FONT></TD>"+CRLF
					Else
						cLinFile += "<TD bgcolor='#FFFFFF' align='right'><FONT face=' Arial ' size=1 color='#FF0000' ><b> </b></FONT></TD>"+CRLF
						cLinFile += "<TD bgcolor='#FFFFFF' align='right'><FONT face=' Arial ' size=1 color='#FF0000' ><b>"+TRANSFORM(TRD1->E1_VALOR,"@E 9,999,999.99")+"</b></FONT></TD>"+CRLF
					Endif
					cLinFile += "<TD bgcolor='#FFFFFF' align='center'><FONT face=' Arial ' size=1 color='#FF0000' ><b>"+DTOC(TRD1->DATACC) +"</b></FONT></TD>"+CRLF
					cLinFile += "<TD bgcolor='#CAFF70' align='right'><FONT face=' Arial ' size=1 color='#FF0000' ><b>"+TRANSFORM(TRD1->SALDO,"@E 9,999,999.99") +"</b></FONT></TD>"+CRLF
					cLinFile += "<TD bgcolor='#CAFF70' align='right'><FONT face=' Arial ' size=1 color='#FF0000' ><b>"+TRANSFORM(TRD1->MAIORAC,"@E 9,999,999.99") +"</b></FONT></TD>"+CRLF
					cLinFile += "<TD bgcolor='#CAFF70' align='center'><FONT face=' Arial ' size=1 color='#FF0000' ><b>"+DTOC(TRD1->DATAMAC) +"</b></FONT></TD>"+CRLF
					cLinFile += "<TD bgcolor='#FFFFFF' align='center'><FONT face='Arial ' size=1 color='#FF0000' ><b>"+DTOC(TRD1->E1_VENCREA)+"</b></FONT></TD>"+CRLF
					cLinFile += "<TD bgcolor='#FFFFFF' align='center'><FONT face='Arial ' size=1 color='#FF0000' ><b>"+DTOC(TRD1->E1_BAIXA) +"</b></FONT></TD>"+CRLF
					cLinFile += "<TD bgcolor='#FFFFFF' align='right'><FONT face=' Arial ' size=1 color='#FF0000' ><b>"+TRANSFORM(TRD1->DIATRA,"@E 9,999") +"</b></FONT></TD>"+CRLF
					cLinFile += "<TD bgcolor='#FFFFFF' align='right'><FONT face=' Arial ' size=1 color='#FF0000' ><b>"+TRANSFORM(TRD1->VLRCALC,"@E 999,999,999.99") +"</b></FONT></TD>"+CRLF
					cLinFile += "<TD bgcolor='#FFFFFF' align='right'><FONT face=' Arial ' size=1 color='#FF0000' ><b>"+TRANSFORM(TRD1->DIASAV,"@E 999,999") +"</b></FONT></TD>"+CRLF
					cLinFile += "<TD bgcolor='#FFFFFF' align='right'><FONT face=' Arial ' size=1 color='#FF0000' ><b>"+TRANSFORM(TRD1->VLRAVC,"@E 999,999,999.99") +"</b></FONT></TD>"+CRLF
					cLinFile += "</TR>"
				Else
					cLinFile := "<TR>"
					cLinFile += "<TD bgcolor='#FFFFFF' align='center'><FONT face=' Arial ' size=1 color='#8B8989' ><b>"+TRD1->E1_NUM+"</b></FONT></TD>"+CRLF
					cLinFile += "<TD bgcolor='#FFFFFF' align='center'><FONT face=' Arial ' size=1 color='#8B8989' ><b>"+TRD1->E1_PARCELA+"</b></FONT></TD>"+CRLF
					cLinFile += "<TD bgcolor='#FFFFFF' align='center'><FONT face=' Arial ' size=1 color='#8B8989' ><b>"+DTOC(TRD1->E1_EMISSAO)+"</b></FONT></TD>"+CRLF
					cLinFile += "<TD bgcolor='#FFFFFF' align='center'><FONT face=' Arial ' size=1 color='#8B8989' ><b>"+TRD1->CNPJ+"</b></FONT></TD>"+CRLF
					If TRD1->E1_VALOR > 0
						cLinFile += "<TD bgcolor='#FFFFFF' align='right'><FONT face=' Arial ' size=1 color='#8B8989' ><b>"+TRANSFORM(TRD1->E1_VALOR,"@E 9,999,999.99")+"</b></FONT></TD>"+CRLF
						cLinFile += "<TD bgcolor='#FFFFFF' align='right'><FONT face=' Arial ' size=1 color='#8B8989' ><b> </b></FONT></TD>"+CRLF
					Else
						cLinFile += "<TD bgcolor='#FFFFFF' align='right'><FONT face=' Arial ' size=1 color='#8B8989' ><b> </b></FONT></TD>"+CRLF
						cLinFile += "<TD bgcolor='#FFFFFF' align='right'><FONT face=' Arial ' size=1 color='#8B8989' ><b>"+TRANSFORM(TRD1->E1_VALOR,"@E 9,999,999.99")+"</b></FONT></TD>"+CRLF
					Endif
					cLinFile += "<TD bgcolor='#FFFFFF' align='center'><FONT face=' Arial ' size=1 color='#8B8989' ><b>"+DTOC(TRD1->DATACC) +"</b></FONT></TD>"+CRLF
					cLinFile += "<TD bgcolor='#CAFF70' align='right'><FONT face=' Arial ' size=1 color='#8B8989' ><b>"+TRANSFORM(TRD1->SALDO,"@E 9,999,999.99") +"</b></FONT></TD>"+CRLF
					cLinFile += "<TD bgcolor='#CAFF70' align='right'><FONT face=' Arial ' size=1 color='#8B8989' ><b>"+TRANSFORM(TRD1->MAIORAC,"@E 9,999,999.99") +"</b></FONT></TD>"+CRLF
					cLinFile += "<TD bgcolor='#CAFF70' align='center'><FONT face=' Arial ' size=1 color='#8B8989' ><b>"+DTOC(TRD1->DATAMAC) +"</b></FONT></TD>"+CRLF
					cLinFile += "<TD bgcolor='#FFFFFF' align='center'><FONT face='Arial ' size=1 color='#8B8989' ><b>"+DTOC(TRD1->E1_VENCREA)+"</b></FONT></TD>"+CRLF
					cLinFile += "<TD bgcolor='#FFFFFF' align='center'><FONT face='Arial ' size=1 color='#8B8989' ><b>"+DTOC(TRD1->E1_BAIXA) +"</b></FONT></TD>"+CRLF
					cLinFile += "<TD bgcolor='#FFFFFF' align='right'><FONT face=' Arial ' size=1 color='#8B8989' ><b>"+TRANSFORM(TRD1->DIATRA,"@E 9,999") +"</b></FONT></TD>"+CRLF
					cLinFile += "<TD bgcolor='#FFFFFF' align='right'><FONT face=' Arial ' size=1 color='#8B8989' ><b>"+TRANSFORM(TRD1->VLRCALC,"@E 999,999,999.99") +"</b></FONT></TD>"+CRLF
					cLinFile += "<TD bgcolor='#FFFFFF' align='right'><FONT face=' Arial ' size=1 color='#8B8989' ><b>"+TRANSFORM(TRD1->DIASAV,"@E 999,999") +"</b></FONT></TD>"+CRLF
					cLinFile += "<TD bgcolor='#FFFFFF' align='right'><FONT face=' Arial ' size=1 color='#8B8989' ><b>"+TRANSFORM(TRD1->VLRAVC,"@E 999,999,999.99") +"</b></FONT></TD>"+CRLF
					cLinFile += "</TR>"
				ENDIF
			ENDIF
		ELSE
			If TRD1->DATACC > YEARSUB(dDatabase,1)
				cLinFile := "<TR>"
				cLinFile += "<TD bgcolor='#FFFFFF' align='center'><FONT face=' Arial ' size=1 color='#27408B' ><b>"+TRD1->E1_NUM+"</b></FONT></TD>"+CRLF
				cLinFile += "<TD bgcolor='#FFFFFF' align='center'><FONT face=' Arial ' size=1 color='#27408B' ><b>"+TRD1->E1_PARCELA+"</b></FONT></TD>"+CRLF
				cLinFile += "<TD bgcolor='#FFFFFF' align='center'><FONT face=' Arial ' size=1 color='#27408B' ><b>"+DTOC(TRD1->E1_EMISSAO)+"</b></FONT></TD>"+CRLF
				cLinFile += "<TD bgcolor='#FFFFFF' align='center'><FONT face=' Arial ' size=1 color='#27408B' ><b>"+TRD1->CNPJ+"</b></FONT></TD>"+CRLF
				If TRD1->E1_VALOR > 0
					cLinFile += "<TD bgcolor='#FFFFFF' align='right'><FONT face=' Arial ' size=1 color='#27408B' ><b>"+TRANSFORM(TRD1->E1_VALOR,"@E 9,999,999.99")+"</b></FONT></TD>"+CRLF
					cLinFile += "<TD bgcolor='#FFFFFF' align='right'><FONT face=' Arial ' size=1 color='#27408B' ><b> </b></FONT></TD>"+CRLF
				Else
					cLinFile += "<TD bgcolor='#FFFFFF' align='right'><FONT face=' Arial ' size=1 color='#27408B' ><b> </b></FONT></TD>"+CRLF
					cLinFile += "<TD bgcolor='#FFFFFF' align='right'><FONT face=' Arial ' size=1 color='#27408B' ><b>"+TRANSFORM(TRD1->E1_VALOR,"@E 9,999,999.99")+"</b></FONT></TD>"+CRLF
				Endif
				cLinFile += "<TD bgcolor='#FFFFFF' align='center'><FONT face=' Arial ' size=1 color='#27408B' ><b>"+DTOC(TRD1->DATACC) +"</b></FONT></TD>"+CRLF
				cLinFile += "<TD bgcolor='#CAFF70' align='right'><FONT face=' Arial ' size=1 color='#27408B' ><b>"+TRANSFORM(TRD1->SALDO,"@E 9,999,999.99") +"</b></FONT></TD>"+CRLF
				cLinFile += "<TD bgcolor='#CAFF70' align='right'><FONT face=' Arial ' size=1 color='#27408B' ><b>"+TRANSFORM(TRD1->MAIORAC,"@E 9,999,999.99") +"</b></FONT></TD>"+CRLF
				cLinFile += "<TD bgcolor='#CAFF70' align='center'><FONT face=' Arial ' size=1 color='#27408B' ><b>"+DTOC(TRD1->DATAMAC) +"</b></FONT></TD>"+CRLF
				cLinFile += "<TD bgcolor='#FFFFFF' align='center'><FONT face='Arial ' size=1 color='#27408B' ><b>"+DTOC(TRD1->E1_VENCREA)+"</b></FONT></TD>"+CRLF
				cLinFile += "<TD bgcolor='#FFFFFF' align='center'><FONT face='Arial ' size=1 color='#27408B' ><b>"+DTOC(TRD1->E1_BAIXA) +"</b></FONT></TD>"+CRLF
				cLinFile += "<TD bgcolor='#FFFFFF' align='right'><FONT face=' Arial ' size=1 color='#27408B' ><b>"+TRANSFORM(TRD1->DIATRA,"@E 9,999") +"</b></FONT></TD>"+CRLF
				cLinFile += "<TD bgcolor='#FFFFFF' align='right'><FONT face=' Arial ' size=1 color='#27408B' ><b>"+TRANSFORM(TRD1->VLRCALC,"@E 999,999,999.99") +"</b></FONT></TD>"+CRLF
				cLinFile += "<TD bgcolor='#FFFFFF' align='right'><FONT face=' Arial ' size=1 color='#27408B' ><b>"+TRANSFORM(TRD1->DIASAV,"@E 999,999") +"</b></FONT></TD>"+CRLF
				cLinFile += "<TD bgcolor='#FFFFFF' align='right'><FONT face=' Arial ' size=1 color='#27408B' ><b>"+TRANSFORM(TRD1->VLRAVC,"@E 999,999,999.99") +"</b></FONT></TD>"+CRLF
				cLinFile += "</TR>"
			ELSE
				cLinFile := "<TR>"
				cLinFile += "<TD bgcolor='#FFFFFF' align='center'><FONT face=' Arial ' size=1 color='#8B8989' ><b>"+TRD1->E1_NUM+"</b></FONT></TD>"+CRLF
				cLinFile += "<TD bgcolor='#FFFFFF' align='center'><FONT face=' Arial ' size=1 color='#8B8989' ><b>"+TRD1->E1_PARCELA+"</b></FONT></TD>"+CRLF
				cLinFile += "<TD bgcolor='#FFFFFF' align='center'><FONT face=' Arial ' size=1 color='#8B8989' ><b>"+DTOC(TRD1->E1_EMISSAO)+"</b></FONT></TD>"+CRLF
				cLinFile += "<TD bgcolor='#FFFFFF' align='center'><FONT face=' Arial ' size=1 color='#8B8989' ><b>"+TRD1->CNPJ+"</b></FONT></TD>"+CRLF
				If TRD1->E1_VALOR > 0
					cLinFile += "<TD bgcolor='#FFFFFF' align='right'><FONT face=' Arial ' size=1 color='#8B8989' ><b>"+TRANSFORM(TRD1->E1_VALOR,"@E 9,999,999.99")+"</b></FONT></TD>"+CRLF
					cLinFile += "<TD bgcolor='#FFFFFF' align='right'><FONT face=' Arial ' size=1 color='#8B8989' ><b> </b></FONT></TD>"+CRLF
				Else
					cLinFile += "<TD bgcolor='#FFFFFF' align='right'><FONT face=' Arial ' size=1 color='#8B8989' ><b> </b></FONT></TD>"+CRLF
					cLinFile += "<TD bgcolor='#FFFFFF' align='right'><FONT face=' Arial ' size=1 color='#8B8989' ><b>"+TRANSFORM(TRD1->E1_VALOR,"@E 9,999,999.99")+"</b></FONT></TD>"+CRLF
				Endif
				cLinFile += "<TD bgcolor='#FFFFFF' align='center'><FONT face=' Arial ' size=1 color='#8B8989' ><b>"+DTOC(TRD1->DATACC) +"</b></FONT></TD>"+CRLF
				cLinFile += "<TD bgcolor='#CAFF70' align='right'><FONT face=' Arial ' size=1 color='#8B8989' ><b>"+TRANSFORM(TRD1->SALDO,"@E 9,999,999.99") +"</b></FONT></TD>"+CRLF
				cLinFile += "<TD bgcolor='#CAFF70' align='right'><FONT face=' Arial ' size=1 color='#8B8989' ><b>"+TRANSFORM(TRD1->MAIORAC,"@E 9,999,999.99") +"</b></FONT></TD>"+CRLF
				cLinFile += "<TD bgcolor='#CAFF70' align='center'><FONT face=' Arial ' size=1 color='#8B8989' ><b>"+DTOC(TRD1->DATAMAC) +"</b></FONT></TD>"+CRLF
				cLinFile += "<TD bgcolor='#FFFFFF' align='center'><FONT face='Arial ' size=1 color='#8B8989' ><b>"+DTOC(TRD1->E1_VENCREA)+"</b></FONT></TD>"+CRLF
				cLinFile += "<TD bgcolor='#FFFFFF' align='center'><FONT face='Arial ' size=1 color='#8B8989' ><b>"+DTOC(TRD1->E1_BAIXA) +"</b></FONT></TD>"+CRLF
				cLinFile += "<TD bgcolor='#FFFFFF' align='right'><FONT face=' Arial ' size=1 color='#8B8989' ><b>"+TRANSFORM(TRD1->DIATRA,"@E 9,999") +"</b></FONT></TD>"+CRLF
				cLinFile += "<TD bgcolor='#FFFFFF' align='right'><FONT face=' Arial ' size=1 color='#8B8989' ><b>"+TRANSFORM(TRD1->VLRCALC,"@E 999,999,999.99") +"</b></FONT></TD>"+CRLF
				cLinFile += "<TD bgcolor='#FFFFFF' align='right'><FONT face=' Arial ' size=1 color='#8B8989' ><b>"+TRANSFORM(TRD1->DIASAV,"@E 999,999") +"</b></FONT></TD>"+CRLF
				cLinFile += "<TD bgcolor='#FFFFFF' align='right'><FONT face=' Arial ' size=1 color='#8B8989' ><b>"+TRANSFORM(TRD1->VLRAVC,"@E 999,999,999.99") +"</b></FONT></TD>"+CRLF
				cLinFile += "</TR>"
			ENDIF
		Endif
		flag := .f.
	ELSE
		IF (SZY->ZY_PCVMAC == TRD1->SALDO .AND. SZY->ZY_PCDMAC == TRD1->DATACC) .or. ;
			(SZY->ZY_PCVPCO == TRD1->F2_VALFAT .AND. SZY->ZY_PCDTPC == TRD1->E1_EMISSAO ) .OR. ;
			(SZY->ZY_PCVULC == TRD1->F2_VALFAT .AND. SZY->ZY_PCDUCM == TRD1->E1_EMISSAO )
			
			If TRD1->DATACC > YEARSUB(dDatabase,1)
				cLinFile := "<TR>"
				cLinFile += "<TD bgcolor='#C6E2FF' align='center'><FONT face=' Arial ' size=1 color='#FF0000' ><b>"+TRD1->E1_NUM+"</b></FONT></TD>"+CRLF
				cLinFile += "<TD bgcolor='#C6E2FF' align='center'><FONT face=' Arial ' size=1 color='#FF0000' ><b>"+TRD1->E1_PARCELA+"</b></FONT></TD>"+CRLF
				cLinFile += "<TD bgcolor='#C6E2FF' align='center'><FONT face=' Arial ' size=1 color='#FF0000' ><b>"+DTOC(TRD1->E1_EMISSAO)+"</b></FONT></TD>"+CRLF
				cLinFile += "<TD bgcolor='#C6E2FF' align='center'><FONT face=' Arial ' size=1 color='#FF0000' ><b>"+TRD1->CNPJ+"</b></FONT></TD>"+CRLF
				If TRD1->E1_VALOR > 0
					cLinFile += "<TD bgcolor='#C6E2FF' align='right'><FONT face=' Arial ' size=1 color='#FF0000' ><b>"+TRANSFORM(TRD1->E1_VALOR,"@E 9,999,999.99")+"</b></FONT></TD>"+CRLF
					cLinFile += "<TD bgcolor='#C6E2FF' align='right'><FONT face=' Arial ' size=1 color='#FF0000' ><b> </b></FONT></TD>"+CRLF
				Else
					cLinFile += "<TD bgcolor='#C6E2FF' align='right'><FONT face=' Arial ' size=1 color='#FF0000' ><b> </b></FONT></TD>"+CRLF
					cLinFile += "<TD bgcolor='#C6E2FF' align='right'><FONT face=' Arial ' size=1 color='#FF0000' ><b>"+TRANSFORM(TRD1->E1_VALOR,"@E 9,999,999.99")+"</b></FONT></TD>"+CRLF
				Endif
				cLinFile += "<TD bgcolor='#C6E2FF' align='center'><FONT face=' Arial ' size=1 color='#FF0000' ><b>"+DTOC(TRD1->DATACC) +"</b></FONT></TD>"+CRLF
				cLinFile += "<TD bgcolor='#CAFF70' align='right'><FONT face=' Arial ' size=1 color='#FF0000' ><b>"+TRANSFORM(TRD1->SALDO,"@E 9,999,999.99") +"</b></FONT></TD>"+CRLF
				cLinFile += "<TD bgcolor='#CAFF70' align='right'><FONT face=' Arial ' size=1 color='#FF0000' ><b>"+TRANSFORM(TRD1->MAIORAC,"@E 9,999,999.99") +"</b></FONT></TD>"+CRLF
				cLinFile += "<TD bgcolor='#CAFF70' align='center'><FONT face=' Arial ' size=1 color='#FF0000' ><b>"+DTOC(TRD1->DATAMAC) +"</b></FONT></TD>"+CRLF
				cLinFile += "<TD bgcolor='#C6E2FF' align='center'><FONT face='Arial ' size=1 color='#FF0000' ><b>"+DTOC(TRD1->E1_VENCREA)+"</b></FONT></TD>"+CRLF
				cLinFile += "<TD bgcolor='#C6E2FF' align='center'><FONT face='Arial ' size=1 color='#FF0000' ><b>"+DTOC(TRD1->E1_BAIXA) +"</b></FONT></TD>"+CRLF
				cLinFile += "<TD bgcolor='#C6E2FF' align='right'><FONT face=' Arial ' size=1 color='#FF0000' ><b>"+TRANSFORM(TRD1->DIATRA,"@E 9,999") +"</b></FONT></TD>"+CRLF
				cLinFile += "<TD bgcolor='#C6E2FF' align='right'><FONT face=' Arial ' size=1 color='#FF0000' ><b>"+TRANSFORM(TRD1->VLRCALC,"@E 999,999,999.99") +"</b></FONT></TD>"+CRLF
				cLinFile += "<TD bgcolor='#C6E2FF' align='right'><FONT face=' Arial ' size=1 color='#FF0000' ><b>"+TRANSFORM(TRD1->DIASAV,"@E 999,999") +"</b></FONT></TD>"+CRLF
				cLinFile += "<TD bgcolor='#C6E2FF' align='right'><FONT face=' Arial ' size=1 color='#FF0000' ><b>"+TRANSFORM(TRD1->VLRAVC,"@E 999,999,999.99") +"</b></FONT></TD>"+CRLF
				cLinFile += "</TR>"
			ELSE
				cLinFile := "<TR>"
				cLinFile += "<TD bgcolor='#C6E2FF' align='center'><FONT face=' Arial ' size=1 color='#8B8989' ><b>"+TRD1->E1_NUM+"</b></FONT></TD>"+CRLF
				cLinFile += "<TD bgcolor='#C6E2FF' align='center'><FONT face=' Arial ' size=1 color='#8B8989' ><b>"+TRD1->E1_PARCELA+"</b></FONT></TD>"+CRLF
				cLinFile += "<TD bgcolor='#C6E2FF' align='center'><FONT face=' Arial ' size=1 color='#8B8989' ><b>"+DTOC(TRD1->E1_EMISSAO)+"</b></FONT></TD>"+CRLF
				cLinFile += "<TD bgcolor='#C6E2FF' align='center'><FONT face=' Arial ' size=1 color='#8B8989' ><b>"+TRD1->CNPJ+"</b></FONT></TD>"+CRLF
				If TRD1->E1_VALOR > 0
					cLinFile += "<TD bgcolor='#C6E2FF' align='right'><FONT face=' Arial ' size=1 color='#8B8989' ><b>"+TRANSFORM(TRD1->E1_VALOR,"@E 9,999,999.99")+"</b></FONT></TD>"+CRLF
					cLinFile += "<TD bgcolor='#C6E2FF' align='right'><FONT face=' Arial ' size=1 color='#8B8989' ><b> </b></FONT></TD>"+CRLF
				Else
					cLinFile += "<TD bgcolor='#C6E2FF' align='right'><FONT face=' Arial ' size=1 color='#8B8989' ><b> </b></FONT></TD>"+CRLF
					cLinFile += "<TD bgcolor='#C6E2FF' align='right'><FONT face=' Arial ' size=1 color='#8B8989' ><b>"+TRANSFORM(TRD1->E1_VALOR,"@E 9,999,999.99")+"</b></FONT></TD>"+CRLF
				Endif
				cLinFile += "<TD bgcolor='#C6E2FF' align='center'><FONT face=' Arial ' size=1 color='#8B8989' ><b>"+DTOC(TRD1->DATACC) +"</b></FONT></TD>"+CRLF
				cLinFile += "<TD bgcolor='#CAFF70' align='right'><FONT face=' Arial ' size=1 color='#8B8989' ><b>"+TRANSFORM(TRD1->SALDO,"@E 9,999,999.99") +"</b></FONT></TD>"+CRLF
				cLinFile += "<TD bgcolor='#CAFF70' align='right'><FONT face=' Arial ' size=1 color='#8B8989' ><b>"+TRANSFORM(TRD1->MAIORAC,"@E 9,999,999.99") +"</b></FONT></TD>"+CRLF
				cLinFile += "<TD bgcolor='#CAFF70' align='center'><FONT face=' Arial ' size=1 color='#8B8989' ><b>"+DTOC(TRD1->DATAMAC) +"</b></FONT></TD>"+CRLF
				cLinFile += "<TD bgcolor='#C6E2FF' align='center'><FONT face='Arial ' size=1 color='#8B8989' ><b>"+DTOC(TRD1->E1_VENCREA)+"</b></FONT></TD>"+CRLF
				cLinFile += "<TD bgcolor='#C6E2FF' align='center'><FONT face='Arial ' size=1 color='#8B8989' ><b>"+DTOC(TRD1->E1_BAIXA) +"</b></FONT></TD>"+CRLF
				cLinFile += "<TD bgcolor='#C6E2FF' align='right'><FONT face=' Arial ' size=1 color='#8B8989' ><b>"+TRANSFORM(TRD1->DIATRA,"@E 9,999") +"</b></FONT></TD>"+CRLF
				cLinFile += "<TD bgcolor='#C6E2FF' align='right'><FONT face=' Arial ' size=1 color='#8B8989' ><b>"+TRANSFORM(TRD1->VLRCALC,"@E 999,999,999.99") +"</b></FONT></TD>"+CRLF
				cLinFile += "<TD bgcolor='#C6E2FF' align='right'><FONT face=' Arial ' size=1 color='#8B8989' ><b>"+TRANSFORM(TRD1->DIASAV,"@E 999,999") +"</b></FONT></TD>"+CRLF
				cLinFile += "<TD bgcolor='#C6E2FF' align='right'><FONT face=' Arial ' size=1 color='#8B8989' ><b>"+TRANSFORM(TRD1->VLRAVC,"@E 999,999,999.99") +"</b></FONT></TD>"+CRLF
				cLinFile += "</TR>"
			ENDIF
		ELSE
			IF TRD1->DATACC > YEARSUB(dDatabase,1)
				cLinFile := "<TR>"
				cLinFile += "<TD bgcolor='#C6E2FF' align='center'><FONT face='Arial ' size=1 color='#27408B' ><b>"+TRD1->E1_NUM+"</b></FONT></TD>"+CRLF
				cLinFile += "<TD bgcolor='#C6E2FF' align='center'><FONT face='Arial ' size=1 color='#27408B' ><b>"+TRD1->E1_PARCELA+"</b></FONT></TD>"+CRLF
				cLinFile += "<TD bgcolor='#C6E2FF' align='center'><FONT face='Arial ' size=1 color='#27408B' ><b>"+DTOC(TRD1->E1_EMISSAO)+"</b></FONT></TD>"+CRLF
				cLinFile += "<TD bgcolor='#C6E2FF' align='center'><FONT face='Arial ' size=1 color='#27408B' ><b>"+TRD1->CNPJ+"</b></FONT></TD>"+CRLF
				If TRD1->E1_VALOR > 0
					cLinFile += "<TD bgcolor='#C6E2FF' align='right'><FONT face=' Arial ' size=1 color='#27408B' ><b>"+TRANSFORM(TRD1->E1_VALOR,"@E 9,999,999.99")+"</b></FONT></TD>"+CRLF
					cLinFile += "<TD bgcolor='#C6E2FF' align='right'><FONT face=' Arial ' size=1 color='#27408B' ><b>&nbsp</b></FONT></TD>"+CRLF
				Else
					cLinFile += "<TD bgcolor='#C6E2FF' align='right'><FONT face=' Arial ' size=1 color='#27408B' ><b>&nbsp</b></FONT></TD>"+CRLF
					cLinFile += "<TD bgcolor='#C6E2FF' align='right'><FONT face=' Arial ' size=1 color='#27408B' ><b>"+TRANSFORM(TRD1->E1_VALOR,"@E 9,999,999.99")+"</b></FONT></TD>"+CRLF
				Endif
				cLinFile += "<TD bgcolor='#C6E2FF' align='center'><FONT face='Arial ' size=1 color='#27408B' ><b>"+DTOC(TRD1->DATACC) +"</b></FONT></TD>"+CRLF
				cLinFile += "<TD bgcolor='#CAFF70' align='right'><FONT face='Arial ' size=1 color='#27408B' ><b>"+TRANSFORM(TRD1->SALDO,"@E 9,999,999.99") +"</b></FONT></TD>"+CRLF
				cLinFile += "<TD bgcolor='#CAFF70' align='right'><FONT face='Arial ' size=1 color='#27408B' ><b>"+TRANSFORM(TRD1->MAIORAC,"@E 9,999,999.99") +"</b></FONT></TD>"+CRLF
				cLinFile += "<TD bgcolor='#CAFF70' align='center'><FONT face='Arial ' size=1 color='#27408B' ><b>"+DTOC(TRD1->DATAMAC) +"</b></FONT></TD>"+CRLF
				cLinFile += "<TD bgcolor='#C6E2FF' align='center'><FONT face='Arial ' size=1 color='#27408B' ><b>"+DTOC(TRD1->E1_VENCREA)+"</b></FONT></TD>"+CRLF
				cLinFile += "<TD bgcolor='#C6E2FF' align='center'><FONT face='Arial ' size=1 color='#27408B' ><b>"+DTOC(TRD1->E1_BAIXA) +"</b></FONT></TD>"+CRLF
				cLinFile += "<TD bgcolor='#C6E2FF' align='right'><FONT face='Arial ' size=1 color='#27408B' ><b>"+TRANSFORM(TRD1->DIATRA,"@E 9,999") +"</b></FONT></TD>"+CRLF
				cLinFile += "<TD bgcolor='#C6E2FF' align='right'><FONT face='Arial ' size=1 color='#27408B' ><b>"+TRANSFORM(TRD1->VLRCALC,"@E 999,999,999.99") +"</b></FONT></TD>"+CRLF
				cLinFile += "<TD bgcolor='#C6E2FF' align='right'><FONT face='Arial ' size=1 color='#27408B' ><b>"+TRANSFORM(TRD1->DIASAV,"@E 999,999") +"</b></FONT></TD>"+CRLF
				cLinFile += "<TD bgcolor='#C6E2FF' align='right'><FONT face='Arial ' size=1 color='#27408B' ><b>"+TRANSFORM(TRD1->VLRAVC,"@E 999,999,999.99") +"</b></FONT></TD>"+CRLF
				cLinFile += "</TR>"
			ELSE
				cLinFile := "<TR>"
				cLinFile += "<TD bgcolor='#C6E2FF' align='center'><FONT face='Arial ' size=1 color='#8B8989' ><b>"+TRD1->E1_NUM+"</b></FONT></TD>"+CRLF
				cLinFile += "<TD bgcolor='#C6E2FF' align='center'><FONT face='Arial ' size=1 color='#8B8989' ><b>"+TRD1->E1_PARCELA+"</b></FONT></TD>"+CRLF
				cLinFile += "<TD bgcolor='#C6E2FF' align='center'><FONT face='Arial ' size=1 color='#8B8989' ><b>"+DTOC(TRD1->E1_EMISSAO)+"</b></FONT></TD>"+CRLF
				cLinFile += "<TD bgcolor='#C6E2FF' align='center'><FONT face='Arial ' size=1 color='#8B8989' ><b>"+TRD1->CNPJ+"</b></FONT></TD>"+CRLF
				If TRD1->E1_VALOR > 0
					cLinFile += "<TD bgcolor='#C6E2FF' align='right'><FONT face=' Arial ' size=1 color='#8B8989' ><b>"+TRANSFORM(TRD1->E1_VALOR,"@E 9,999,999.99")+"</b></FONT></TD>"+CRLF
					cLinFile += "<TD bgcolor='#C6E2FF' align='right'><FONT face=' Arial ' size=1 color='#8B8989' ><b> </b></FONT></TD>"+CRLF
				Else
					cLinFile += "<TD bgcolor='#C6E2FF' align='right'><FONT face=' Arial ' size=1 color='#8B8989' ><b> </b></FONT></TD>"+CRLF
					cLinFile += "<TD bgcolor='#C6E2FF' align='right'><FONT face=' Arial ' size=1 color='#8B8989' ><b>"+TRANSFORM(TRD1->E1_VALOR,"@E 9,999,999.99")+"</b></FONT></TD>"+CRLF
				Endif
				cLinFile += "<TD bgcolor='#C6E2FF' align='center'><FONT face='Arial ' size=1 color='#8B8989' ><b>"+DTOC(TRD1->DATACC) +"</b></FONT></TD>"+CRLF
				cLinFile += "<TD bgcolor='#CAFF70' align='right'><FONT face='Arial ' size=1 color='#8B8989' ><b>"+TRANSFORM(TRD1->SALDO,"@E 9,999,999.99") +"</b></FONT></TD>"+CRLF
				cLinFile += "<TD bgcolor='#CAFF70' align='right'><FONT face=' Arial ' size=1 color='#8B8989' ><b>"+TRANSFORM(TRD1->MAIORAC,"@E 9,999,999.99") +"</b></FONT></TD>"+CRLF
				cLinFile += "<TD bgcolor='#CAFF70' align='center'><FONT face=' Arial ' size=1 color='#8B8989' ><b>"+DTOC(TRD1->DATAMAC) +"</b></FONT></TD>"+CRLF
				cLinFile += "<TD bgcolor='#C6E2FF' align='center'><FONT face='Arial ' size=1 color='#8B8989' ><b>"+DTOC(TRD1->E1_VENCREA)+"</b></FONT></TD>"+CRLF
				cLinFile += "<TD bgcolor='#C6E2FF' align='center'><FONT face='Arial ' size=1 color='#8B8989' ><b>"+DTOC(TRD1->E1_BAIXA) +"</b></FONT></TD>"+CRLF
				cLinFile += "<TD bgcolor='#C6E2FF' align='right'><FONT face='Arial ' size=1 color='#8B8989' ><b>"+TRANSFORM(TRD1->DIATRA,"@E 9,999") +"</b></FONT></TD>"+CRLF
				cLinFile += "<TD bgcolor='#C6E2FF' align='right'><FONT face='Arial ' size=1 color='#8B8989' ><b>"+TRANSFORM(TRD1->VLRCALC,"@E 999,999,999.99") +"</b></FONT></TD>"+CRLF
				cLinFile += "<TD bgcolor='#C6E2FF' align='right'><FONT face='Arial ' size=1 color='#8B8989' ><b>"+TRANSFORM(TRD1->DIASAV,"@E 999,999") +"</b></FONT></TD>"+CRLF
				cLinFile += "<TD bgcolor='#C6E2FF' align='right'><FONT face='Arial ' size=1 color='#8B8989' ><b>"+TRANSFORM(TRD1->VLRAVC,"@E 999,999,999.99") +"</b></FONT></TD>"+CRLF
				cLinFile += "</TR>"
			ENDIF
		Endif
		Flag := .t.
	ENDIF
	
	(FWRITE(nHandle, cLinFile))
	cLinFile := ""
	TRD1->(DbSkip())
	
Enddo

cLinFile := "</Table>"+CRLF
(FWRITE(nHandle, cLinFile))

cLinFile := "<table border='1' cellpadding='3' cellspacing='0' bordercolor='#8B8B83' bgColor='#FFFFFF'>" + CRLF
cLinFile += "<TR>" + CRLF
cLinFile += "</TR>"+ CRLF
(FWRITE(nHandle, cLinFile))

cLinFile := "<TR>"
cLinFile += "<TD bgcolor='#6E8B3D' align='center'><FONT face=' Arial ' size=1 color='#FFFFFF'><b>Data Informação</b></FONT></TD>"+CRLF
cLinFile += "<TD bgcolor='#6E8B3D' align='center'><FONT face=' Arial ' size=1 color='#FFFFFF'><b>"+DTOC(SZY->ZY_PCDDAT)+"</b></FONT></TD>"+CRLF
cLinFile += "</TR>"+ CRLF
(FWRITE(nHandle, cLinFile))

cLinFile := "<TR>"
cLinFile += "<TD bgcolor='#C6E2FF' align='center'><FONT face='Arial ' size=1 color='#0000CD' ><b>Cnpj</b></FONT></TD>"+CRLF
cLinFile += "<TD bgcolor='#C6E2FF' align='center'><FONT face='Arial ' size=1 color='#000000' ><b>"+SZY->ZY_PCCCLI+"</b></FONT></TD>"+CRLF
cLinFile += "</TR>"+ CRLF
(FWRITE(nHandle, cLinFile))

cLinFile := "<TR>"
cLinFile += "<TD bgcolor='#C6E2FF' align='center'><FONT face='Arial ' size=1 color='#0000CD' ><b>Data Cad.</b></FONT></TD>"+CRLF
cLinFile += "<TD bgcolor='#C6E2FF' align='center'><FONT face='Arial ' size=1 color='#000000' ><b>"+DTOC(SZY->ZY_PCDCDD)+"</b></FONT></TD>"+CRLF
cLinFile += "</TR>"+ CRLF
(FWRITE(nHandle, cLinFile))

cLinFile := "<TR>"
cLinFile += "<TD bgcolor='#C6E2FF' align='center'><FONT face='Arial ' size=1 color='#0000CD' ><b>Vlr.Maior.Acum.</b></FONT></TD>"+CRLF
cLinFile += "<TD bgcolor='#C6E2FF' align='center'><FONT face='Arial ' size=1 color='#000000' ><b>"+Transform(SZY->ZY_PCVMAC,"@E 99,999,999.99")+"</b></FONT></TD>"+CRLF
cLinFile += "</TR>"+ CRLF
(FWRITE(nHandle, cLinFile))

cLinFile := "<TR>"
cLinFile += "<TD bgcolor='#C6E2FF' align='center'><FONT face='Arial ' size=1 color='#0000CD' ><b>Data M.Acum</b></FONT></TD>"+CRLF
cLinFile += "<TD bgcolor='#C6E2FF' align='center'><FONT face='Arial ' size=1 color='#000000' ><b>"+DTOC(SZY->ZY_PCDMAC)+"</b></FONT></TD>"+CRLF
cLinFile += "</TR>"+ CRLF
(FWRITE(nHandle, cLinFile))


cLinFile := "<TR>"
cLinFile += "<TD bgcolor='#C6E2FF' align='center'><FONT face='Arial ' size=1 color='#0000CD' ><b>Deb.Atual Total</b></FONT></TD>"+CRLF
cLinFile += "<TD bgcolor='#C6E2FF' align='center'><FONT face='Arial ' size=1 color='#000000' ><b>"+Transform(SZY->ZY_PCVSAT,"@E 9,999,999.99")+"</b></FONT></TD>"+CRLF
cLinFile += "</TR>"+ CRLF
(FWRITE(nHandle, cLinFile))

cLinFile := "<TR>"
cLinFile += "<TD bgcolor='#C6E2FF' align='center'><FONT face='Arial ' size=1 color='#0000CD' ><b>Penúlt.Compra</b></FONT></TD>"+CRLF
cLinFile += "<TD bgcolor='#C6E2FF' align='center'><FONT face='Arial ' size=1 color='#000000' ><b>"+Transform(SZY->ZY_PCVPCO,"@e 99,999,999.99")+"</b></FONT></TD>"+CRLF
cLinFile += "</TR>"+ CRLF
(FWRITE(nHandle, cLinFile))

cLinFile := "<TR>"
cLinFile += "<TD bgcolor='#C6E2FF' align='center'><FONT face='Arial ' size=1 color='#0000CD' ><b>Data Penúlt.Cp.</b></FONT></TD>"+CRLF
cLinFile += "<TD bgcolor='#C6E2FF' align='center'><FONT face='Arial ' size=1 color='#000000' ><b>"+DTOC(SZY->ZY_PCDTPC)+"</b></FONT></TD>"+CRLF
cLinFile += "</TR>"+ CRLF
(FWRITE(nHandle, cLinFile))

cLinFile := "<TR>"
cLinFile += "<TD bgcolor='#C6E2FF' align='center'><FONT face='Arial ' size=1 color='#0000CD' ><b>Ultima Compra.</b></FONT></TD>"+CRLF
cLinFile += "<TD bgcolor='#C6E2FF' align='center'><FONT face='Arial ' size=1 color='#000000' ><b>"+Transform(SZY->ZY_PCVULC,"@E 99,999,999.99")+"</b></FONT></TD>"+CRLF
cLinFile += "</TR>"+ CRLF
(FWRITE(nHandle, cLinFile))

cLinFile := "<TR>"
cLinFile += "<TD bgcolor='#C6E2FF' align='center'><FONT face='Arial ' size=1 color='#0000CD' ><b>Data Ult.Compra</b></FONT></TD>"+CRLF
cLinFile += "<TD bgcolor='#C6E2FF' align='center'><FONT face='Arial ' size=1 color='#000000' ><b>"+DTOC(SZY->ZY_PCDUCM)+"</b></FONT></TD>"+CRLF
cLinFile += "</TR>"+ CRLF
(FWRITE(nHandle, cLinFile))

cLinFile := "<TR>"
cLinFile += "<TD bgcolor='#C6E2FF' align='center'><FONT face='Arial ' size=1 color='#0000CD' ><b>Med.Pond.Atraso</b></FONT></TD>"+CRLF
cLinFile += "<TD bgcolor='#C6E2FF' align='center'><FONT face='Arial ' size=1 color='#000000' ><b>"+Transform(SZY->ZY_PCQPAG,"@E 999.99")+"</b></FONT></TD>"+CRLF
cLinFile += "</TR>"+ CRLF
(FWRITE(nHandle, cLinFile))

cLinFile := "<TR>"
cLinFile += "<TD bgcolor='#C6E2FF' align='center'><FONT face='Arial ' size=1 color='#0000CD' ><b>Med.Aritm.Atraso</b></FONT></TD>"+CRLF
cLinFile += "<TD bgcolor='#C6E2FF' align='center'><FONT face='Arial ' size=1 color='#000000' ><b>"+Transform(SZY->ZY_PCQDAP,"@E 999.99")+"</b></FONT></TD>"+CRLF
cLinFile += "</TR>"+ CRLF
(FWRITE(nHandle, cLinFile))

cLinFile := "<TR>"
cLinFile += "<TD bgcolor='#C6E2FF' align='center'><FONT face='Arial ' size=1 color='#0000CD' ><b>Vlr.Deb.a Venc.</b></FONT></TD>"+CRLF
cLinFile += "<TD bgcolor='#C6E2FF' align='center'><FONT face='Arial ' size=1 color='#000000' ><b>"+Transform(SZY->ZY_PCVDAV,"@E 9,999,999.99")+"</b></FONT></TD>"+CRLF
cLinFile += "</TR>"+ CRLF
(FWRITE(nHandle, cLinFile))

cLinFile := "<TR>"
cLinFile += "<TD bgcolor='#C6E2FF' align='center'><FONT face='Arial ' size=1 color='#0000CD' ><b>Med.Pond.A Vc.</b></FONT></TD>"+CRLF
cLinFile += "<TD bgcolor='#C6E2FF' align='center'><FONT face='Arial ' size=1 color='#000000' ><b>"+Transform(SZY->ZY_PCMDAV,"@E 999.99")+"</b></FONT></TD>"+CRLF
cLinFile += "</TR>"+ CRLF
(FWRITE(nHandle, cLinFile))

cLinFile := "<TR>"
cLinFile += "<TD bgcolor='#C6E2FF' align='center'><FONT face='Arial ' size=1 color='#0000CD' ><b>Prazo Med. Vd.</b></FONT></TD>"+CRLF
cLinFile += "<TD bgcolor='#C6E2FF' align='center'><FONT face='Arial ' size=1 color='#000000' ><b>"+Transform(SZY->ZY_PCMPMV,"@E 999.99")+"</b></FONT></TD>"+CRLF
cLinFile += "</TR>"+ CRLF
(FWRITE(nHandle, cLinFile))

cLinFile := "<TR>"
cLinFile += "<TD bgcolor='#C6E2FF' align='center'><FONT face='Arial ' size=1 color='#0000CD' ><b>Vencido +5 dias</b></FONT></TD>"+CRLF
cLinFile += "<TD bgcolor='#C6E2FF' align='center'><FONT face='Arial ' size=1 color='#000000' ><b>"+Transform(SZY->ZY_PCDATV,"@E 9,999,999.99")+"</b></FONT></TD>"+CRLF
cLinFile += "</TR>"+ CRLF
(FWRITE(nHandle, cLinFile))

cLinFile := "<TR>"
cLinFile += "<TD bgcolor='#C6E2FF' align='center'><FONT face='Arial ' size=1 color='#0000CD' ><b>Med.Pond.+5 dias</b></FONT></TD>"+CRLF
cLinFile += "<TD bgcolor='#C6E2FF' align='center'><FONT face='Arial ' size=1 color='#000000' ><b>"+Transform(SZY->ZY_PCMPTV,"@E 999.99")+"</b></FONT></TD>"+CRLF
cLinFile += "</TR>"+ CRLF
(FWRITE(nHandle, cLinFile))

cLinFile := "<TR>"
cLinFile += "<TD bgcolor='#C6E2FF' align='center'><FONT face='Arial ' size=1 color='#0000CD' ><b>Vencido +15 dias</b></FONT></TD>"+CRLF
cLinFile += "<TD bgcolor='#C6E2FF' align='center'><FONT face='Arial ' size=1 color='#000000' ><b>"+Transform(SZY->ZY_PCV15D,"@E 9,999,999.99")+"</b></FONT></TD>"+CRLF
cLinFile += "</TR>"+ CRLF
(FWRITE(nHandle, cLinFile))

cLinFile := "<TR>"
cLinFile += "<TD bgcolor='#C6E2FF' align='center'><FONT face='Arial ' size=1 color='#0000CD' ><b>Med.Pond.+15 dias</b></FONT></TD>"+CRLF
cLinFile += "<TD bgcolor='#C6E2FF' align='center'><FONT face='Arial ' size=1 color='#000000' ><b>"+Transform(SZY->ZY_PCM15D,"@E 999.99")+"</b></FONT></TD>"+CRLF
cLinFile += "</TR>"+ CRLF
(FWRITE(nHandle, cLinFile))

cLinFile := "<TR>"
cLinFile += "<TD bgcolor='#C6E2FF' align='center'><FONT face='Arial ' size=1 color='#0000CD' ><b>Vencido +30 dias</b></FONT></TD>"+CRLF
cLinFile += "<TD bgcolor='#C6E2FF' align='center'><FONT face='Arial ' size=1 color='#000000' ><b>"+Transform(SZY->ZY_PCV30D,"@E 9,999,999.99")+"</b></FONT></TD>"+CRLF
cLinFile += "</TR>"+ CRLF
(FWRITE(nHandle, cLinFile))

cLinFile := "<TR>"
cLinFile += "<TD bgcolor='#C6E2FF' align='center'><FONT face='Arial ' size=1 color='#0000CD' ><b>Med.Pond.+30 dias</b></FONT></TD>"+CRLF
cLinFile += "<TD bgcolor='#C6E2FF' align='center'><FONT face='Arial ' size=1 color='#000000' ><b>"+Transform(SZY->ZY_PCM30D,"@E 9,999.99")+"</b></FONT></TD>"+CRLF
cLinFile += "</TR>"+ CRLF
(FWRITE(nHandle, cLinFile))

//Acrescenta o rodap html
(FWRITE(nHandle, cRodHtml))

fCLose(nHandle)

if APMSGYESNO("Arquivo Gerado !!! Deseja abrir agora ???","Atenção" )
	SHELLEXECUTE("open",cArqPesq,"","",5)
Endif

Return


//-------------------------
Static Function fWBrowse1()
//-------------------------
Aadd(aWBrowse1,{" "," "," "," "," "," "," "," "," "," "," "," "," "," "," "," "," "," "})
@ 012, 001 LISTBOX oWBrowse1 ;
Fields HEADER "Docto","Parc.","Emissão","CNPJ","Valor Op.","Vlr Fat.",;
"Data Op.","Saldo C/C ","Maior Acum. ","Data M.A.","Vcto. ","Baixa","Atraso","Vlr Atr.",;
"Data","Valor","Dias AV","Vlr.AV" ;
SIZE 400, 220 FONT oFont1 OF oPanel1 PIXEL ColSizes 10,10,10,10,20,20,10,35,35,30,10,25,10,20,10,20,10,35
oWBrowse1:SetArray(aWBrowse1)
oWBrowse1:bLine := {|| {;
aWBrowse1[oWBrowse1:nAt,1],;
aWBrowse1[oWBrowse1:nAt,2],;
aWBrowse1[oWBrowse1:nAt,3],;
aWBrowse1[oWBrowse1:nAt,4],;
aWBrowse1[oWBrowse1:nAt,5],;
aWBrowse1[oWBrowse1:nAt,6],;
aWBrowse1[oWBrowse1:nAt,7],;
aWBrowse1[oWBrowse1:nAt,8],;
aWBrowse1[oWBrowse1:nAt,9],;
aWBrowse1[oWBrowse1:nAt,10],;
aWBrowse1[oWBrowse1:nAt,11],;
aWBrowse1[oWBrowse1:nAt,12],;
aWBrowse1[oWBrowse1:nAt,13],;
aWBrowse1[oWBrowse1:nAt,14],;
aWBrowse1[oWBrowse1:nAt,15],;
aWBrowse1[oWBrowse1:nAt,16],;
aWBrowse1[oWBrowse1:nAt,17],;
aWBrowse1[oWBrowse1:nAt,18];
}}
Return

/*--------------------------------*/
Static Function Carga01(cnpj)
/*--------------------------------*/

_dDATADE   := CTOD("01/01/2000")

cQuery1 := " SELECT  ANO = (SELECT MAX(YEAR(E1_EMISSAO)) FROM "+RetSqlName("SE1")+" E1 INNER JOIN "+RetSqlName("SA1")+" A1 ON E1.E1_CLIENTE = A1.A1_COD WHERE LEFT(A1.A1_CGC,8) BETWEEN   '"+CNPJ+"' AND '"+CNPJ+"'),"+ENTER
cQuery1 += " E1_NUM,E1_PARCELA,E1_EMISSAO,LEFT(A1_CGC,8) as CNPJ, E1_VALOR ,F2_VALFAT,DATACC = E1_EMISSAO, 0 AS SALDO,E1_VENCREA, " + ENTER
cQuery1 += " CASE WHEN E1_VENCREA >= "+VALTOSQL(_dDataDE)+" THEN ' ' ELSE E1_BAIXA END AS E1_BAIXA , "+ENTER
cQuery1 += " 0 AS DIATRA ,0 AS VLRCALC, "+ENTER
cQuery1 += "  '' AS DATAM, 0 AS VLRM, VLRDAV = (CASE WHEN E1_VENCREA >= "+VALTOSQL(dDataBase)+" THEN E1_VALOR ELSE 0 END ), "+ENTER
cQuery1 += " CASE WHEN E1_VENCREA > "+VALTOSQL(dDataBase)+" THEN DATEDIFF(DAY,E1_EMISSAO,E1_VENCREA) ELSE 0 END AS DIASAV, "+ENTER
cQuery1 += " CASE WHEN E1_VENCREA > "+VALTOSQL(dDataBase)+" THEN DATEDIFF(DAY,E1_EMISSAO,E1_VENCREA) * E1_VALOR ELSE 0 END AS VLRAVC, A1_LC , ORDEM = 1"+ENTER
cQuery1 += " FROM "+RetSqlName("SE1")+" E1 "+ENTER
cQuery1 += " INNER JOIN "+RetSqlName("SA1")+" A1 ON E1.E1_CLIENTE = A1.A1_COD AND E1.E1_LOJA = A1.A1_LOJA "+ENTER
cQuery1 += " INNER JOIN "+RetSqlName("SF2")+" F2 ON E1.E1_NUM = F2.F2_DOC AND E1.E1_PREFIXO = F2.F2_SERIE AND E1.E1_CLIENTE = F2.F2_CLIENTE AND E1.E1_LOJA = F2.F2_LOJA  "+ENTER
cQuery1 += " WHERE ( E1.E1_VENCREA >= "+VALTOSQL(_dDataDE) +" AND( E1.E1_EMISSAO <= "+VALTOSQL(dDataBase)+" AND E1.E1_EMISSAO >="+VALTOSQL(_dDataDE) +") AND ( E1.E1_BAIXA >= "+VALTOSQL(_dDataDE) +" OR E1.E1_BAIXA = ' ') ) AND  E1.E1_TIPO = 'NF' AND E1.D_E_L_E_T_ = ' ' AND F2.D_E_L_E_T_ = ' ' "+ENTER
cQuery1 += " AND LEFT(A1_CGC,8) BETWEEN  '"+CNPJ+"' AND '"+CNPJ+"'"+ENTER
cQuery1 += " UNION ALL "+ENTER
cQuery1 += " SELECT  ANO = (SELECT MAX(YEAR(E1_EMISSAO)) FROM "+RetSqlName("SE1")+" E1 INNER JOIN "+RetSqlName("SA1")+" A1 ON E1.E1_CLIENTE = A1.A1_COD WHERE LEFT(A1_CGC,8) BETWEEN '"+CNPJ+"' AND '"+CNPJ+"'),"+ENTER
cQuery1 += " E1_NUM,E1_PARCELA,E1_EMISSAO,LEFT(A1_CGC,8) as CNPJ, "+ENTER
cQuery1 += " E1_VALOR = (CASE WHEN  E1_BAIXA <> ' ' THEN ((E1_VALOR-E1_SALDO)*-1) END), F2_VALFAT = 0, "+ENTER
cQuery1 += " DATACC   = (CASE WHEN E1_BAIXA <> ' ' THEN E1_BAIXA END ), 0 AS SALDO,E1_VENCREA,E1_BAIXA, "+ENTER
cQuery1 += " CASE WHEN DATEDIFF(DAY,E1_VENCREA,E1_BAIXA) >= 0  THEN DATEDIFF(DAY,E1_VENCREA,E1_BAIXA) "+ENTER
cQuery1 += "      WHEN E1_BAIXA <> ' ' AND E1_BAIXA > E1_VENCREA THEN DATEDIFF(DAY,E1_VENCREA,"+VALTOSQL(dDataBase)+") "+ENTER
cQuery1 += "      WHEN E1_BAIXA = ' ' AND E1_VENCREA < "+VALTOSQL(dDataBase)+" THEN  DATEDIFF(DAY,E1_VENCREA,"+VALTOSQL(dDataBase)+") "+ENTER
cQuery1 += "      ELSE 0 END AS DIATRA ,"+ENTER
cQuery1 += "  CASE WHEN DATEDIFF(DAY,E1_VENCREA,E1_BAIXA) >= 0  THEN (E1_VALOR*DATEDIFF(DAY,E1_VENCREA,E1_BAIXA)) "+ENTER
cQuery1 += "       WHEN E1_BAIXA <> ' ' AND E1_BAIXA > E1_VENCREA THEN (E1_VALOR*DATEDIFF(DAY,E1_VENCREA,"+VALTOSQL(dDataBase)+")) "+ENTER
cQuery1 += "       WHEN E1_BAIXA = ' '  AND E1_VENCREA < "+VALTOSQL(dDataBase)+" THEN (E1_VALOR*DATEDIFF(DAY,E1_VENCREA,"+VALTOSQL(dDataBase)+"))"+ENTER
cQuery1 += "       ELSE 0 END AS VLRCALC,"+ENTER
cQuery1 += " '' AS DATAM, 0 AS VLRM,VLRDAV = 0 , DIASAV = 0, VLRAVC = 0 , A1_LC, ORDEM = 2"+ENTER
cQuery1 += " FROM "+RetSqlName("SE1")+" E1 "+ENTER
cQuery1 += " INNER JOIN "+RetSqlName("SA1")+" A1 ON E1.E1_CLIENTE = A1.A1_COD AND E1.E1_LOJA = A1.A1_LOJA "+ENTER
cQuery1 += " WHERE ( E1.E1_EMISSAO <= "+VALTOSQL(dDataBase)+" AND E1.E1_EMISSAO >="+VALTOSQL(_dDataDE) +") AND E1.E1_TIPO = 'NF' AND E1.D_E_L_E_T_ = ' ' AND E1.E1_BAIXA <> ' ' AND E1.E1_BAIXA >= "+VALTOSQL(_dDATADE)+" AND E1.E1_VENCREA < "+VALTOSQL(dDataBase)+ENTER
cQuery1 += " AND LEFT(A1_CGC,8) BETWEEN  '"+CNPJ+"' AND '"+CNPJ+"' "+ENTER
cQuery1 += " ORDER BY CNPJ,DATACC,ORDEM,E1_VALOR,E1_NUM,E1_PARCELA "+ENTER

MemoWrit("C:\SIGA\trb1.sql",cQuery1)

If !Empty(Select("TRB1"))
	dbSelectArea("TRB1")
	dbCloseArea()
Endif
dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery1), "TRB1", .T., .F. )
dbSelectArea("TRB1")


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fecha Alias se estiver em Uso ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Empty(Select("TRD1"))
	dbSelectArea("TRD1")
	dbCloseArea()
Endif


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta a interface padrao com o usuario...                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
acampos := {}
AADD(aCampos,{ "E1_NUM"    ,"C",09,0 } )
AADD(aCampos,{ "E1_PARCELA","C",03,0 } )
AADD(aCampos,{ "E1_EMISSAO","D",08,0 } )
AADD(aCampos,{ "CNPJ"      ,"C",08,0 } )
AADD(aCampos,{ "E1_VALOR"  ,"N",12,2 } )
AADD(aCampos,{ "F2_VALFAT" ,"N",12,2 } )
AADD(aCampos,{ "DATACC"    ,"D",08,0 } )
AADD(aCampos,{ "SALDO"     ,"N",12,2 } )
AADD(aCampos,{ "MAIORAC"   ,"N",12,2 } )
AADD(aCampos,{ "DATAMAC"   ,"D",08,2 } )
AADD(aCampos,{ "E1_VENCREA","D",08,2 } )
AADD(aCampos,{ "E1_BAIXA"  ,"D",08,0 } )
AADD(aCampos,{ "DIATRA"    ,"N",09,0 } )
AADD(aCampos,{ "VLRCALC"   ,"N",12,2 } )
AADD(aCampos,{ "DATAM"     ,"D",08,0 } )
AADD(aCampos,{ "VLRM"      ,"N",12,2 } )
AADD(aCampos,{ "DIASAV"    ,"N",09,0 } )
AADD(aCampos,{ "VLRAVC"    ,"N",12,2 } )
cNomTrb  := CriaTrab(aCampos)
dbSelectArea(0)
dbUseArea( .T.,,cNomTrb,"TRD1",.F. )
dbSelectArea("TRD1")

xSaldo := 0
xSaldo1 := 0
xSalAc := 0
xData  := Ctod("  /  /  ")

TRB1->(dbGoTop())
_dDataDE2  :=  YEARSUB(DDataBase,3)

If TRB1->ano == 2014
	_dDataDE2  :=  YEARSUB(DDataBase,3)
ElseIf TRB1->ano == 2015
	_dDataDE2  :=  YEARSUB(DDataBase,2)
ElseIf TRB1->ano == 2016
	_dDataDE2  :=  YEARSUB(DDataBase,1)
Else
	_dDataDE2  :=  YEARSUB(DDataBase,1)
Endif

While ! TRB1->(eOF())
	xSaldo1 += TRB1->E1_VALOR
	xSaldo  += TRB1->E1_VALOR
	If xSaldo1 < 0
		xSaldo1 := 0
		xSaldo  := 0
	Endif
	Reclock("TRD1",.T.)
	TRD1->E1_NUM     := TRB1->E1_NUM
	TRD1->E1_PARCELA := TRB1->E1_PARCELA
	TRD1->E1_EMISSAO := CTOD(SUBSTR(TRB1->E1_EMISSAO,7,2)+"/"+SUBSTR(TRB1->E1_EMISSAO,5,2)+"/"+SUBSTR(TRB1->E1_EMISSAO,1,4))
	TRD1->CNPJ       := TRB1->CNPJ
	TRD1->E1_VALOR   := TRB1->E1_VALOR
	TRD1->F2_VALFAT  := TRB1->F2_VALFAT
	TRD1->DATACC     := CTOD(SUBSTR(TRB1->DATACC,7,2)+"/"+SUBSTR(TRB1->DATACC,5,2)+"/"+SUBSTR(TRB1->DATACC,1,4))
	If xSaldo1 >= xSalac .and. CTOD(SUBSTR(TRB1->DATACC,7,2)+"/"+SUBSTR(TRB1->DATACC,5,2)+"/"+SUBSTR(TRB1->DATACC,1,4)) >= _dDataDE2
		xSalac := xSaldo
		xData  := CTOD(SUBSTR(TRB1->DATACC,7,2)+"/"+SUBSTR(TRB1->DATACC,5,2)+"/"+SUBSTR(TRB1->DATACC,1,4))
	Endif
	TRD1->E1_VENCREA := CTOD(SUBSTR(TRB1->E1_VENCREA,7,2)+"/"+SUBSTR(TRB1->E1_VENCREA,5,2)+"/"+SUBSTR(TRB1->E1_VENCREA,1,4))
	TRD1->E1_BAIXA   := CTOD(SUBSTR(TRB1->E1_BAIXA,7,2)+"/"+SUBSTR(TRB1->E1_BAIXA,5,2)+"/"+SUBSTR(TRB1->E1_BAIXA,1,4))
	TRD1->DIATRA     := TRB1->DIATRA
	TRD1->VLRCALC    := TRB1->VLRCALC
	TRD1->DATAM      := CTOD(SUBSTR(TRB1->DATAM,7,2)+"/"+SUBSTR(TRB1->DATAM,5,2)+"/"+SUBSTR(TRB1->DATAM,1,4))
	TRD1->VLRM       := TRB1->VLRM
	TRD1->DIASAV     := TRB1->DIASAV
	TRD1->VLRAVC     := TRB1->VLRAVC
	TRD1->MAIORAC    := xSalac
	TRD1->DATAMAC    := xData
	TRD1->SALDO      := XSALDO
	Msunlock()
	TRB1->(DbSkip())
Enddo

TRD1->(DbGotop())

xSaldo := 0
If ! TRD1->(Eof())
	aWBrowse1 := {}
	While ! TRD1->(Eof())
		xSaldo += TRD1->E1_VALOR
		Aadd(aWBrowse1,{ALLTRIM(TRD1->E1_NUM),;
		ALLTRIM(TRD1->E1_PARCELA),;
		DTOC(TRD1->E1_EMISSAO),;
		ALLTRIM(TRD1->CNPJ),;
		TRANSFORM(TRD1->F2_VALFAT,"@e 9,999,999.99"),;
		TRANSFORM(0,"@e 9,999,999.99"),;
		DTOC(TRD1->DATACC),;
		TRANSFORM(TRD1->SALDO,"@e 9,999,999.99"),;
		TRANSFORM(TRD1->MAIORAC,"@e 9,999,999.99"),;
		DTOC(TRD1->DATAMAC),;
		DTOC(TRD1->E1_VENCREA),;
		DTOC(TRD1->E1_BAIXA),;
		TRANSFORM(TRD1->DIATRA,"@e 999,999"),;
		TRANSFORM(TRD1->VLRCALC,"@e 9,999,999.99"),;
		DTOC(TRD1->DATAM),;
		TRANSFORM(TRD1->VLRM,"@e 9,999,999.99"),;
		TRANSFORM(TRD1->DIASAV,"@e 999,999"),;
		TRANSFORM(TRD1->VLRAVC,"@e 9,999,999.99") } )
		TRD1->(DbSkip())
	Enddo
Else
	cGet3  := " "
	cGet4  := " "
	aWBrowse1 := {}
	Aadd(aWBrowse1,{" "," "," "," "," "," "," "," "," "," "," "," "," "," "," "," "," "," "})
	MsgAlert("Cnpj Sem Movimento !","Atenção")
Endif
oWBrowse1:SetArray(aWBrowse1)
oWBrowse1:bLine := {|| {;
aWBrowse1[oWBrowse1:nAt,1],;
aWBrowse1[oWBrowse1:nAt,2],;
aWBrowse1[oWBrowse1:nAt,3],;
aWBrowse1[oWBrowse1:nAt,4],;
aWBrowse1[oWBrowse1:nAt,5],;
aWBrowse1[oWBrowse1:nAt,6],;
aWBrowse1[oWBrowse1:nAt,7],;
aWBrowse1[oWBrowse1:nAt,8],;
aWBrowse1[oWBrowse1:nAt,9],;
aWBrowse1[oWBrowse1:nAt,10],;
aWBrowse1[oWBrowse1:nAt,11],;
aWBrowse1[oWBrowse1:nAt,12],;
aWBrowse1[oWBrowse1:nAt,13],;
aWBrowse1[oWBrowse1:nAt,14],;
aWBrowse1[oWBrowse1:nAt,15],;
aWBrowse1[oWBrowse1:nAt,16],;
aWBrowse1[oWBrowse1:nAt,17],;
aWBrowse1[oWBrowse1:nAt,18];
}}
oWBrowse1:nAt := 1

Return

/*------------------------*/
User Function Atual1()
/*------------------------*/

If ! Pergunte("INFORCISP ")
	Return
Else
	PutLog( Time()+" Inicio." )
	MsgRun("Atualizando os dados - Aguarde...","Processando", {||Atual2()}, "Atualizar"   )
	PutLog( Time()+" Fim." )
Endif
Return

/*---------------------*/
Static Function Atual2()
/*---------------------*/

_dDATADE   := CTOD("01/01/2000")
_dDataDE2  := YEARSUB(MV_PAR05,1) // YEARSUB(dDatabase,1)

If !Empty(Select("TRB2"))
	dbSelectArea("TRB2")
	dbCloseArea()
Endif

If lEmbed

	BeginSql Alias "TRB2"


		SELECT PCTIPO = '1' ,
			PCCASS = '0000',
			PCCCLI = LEFT(A1_CGC,8),
			PCDDAT = '00000000',
			PCDCDD = MIN(E1_EMISSAO) ,
			PCDUCM = MAX(E1_EMISSAO) ,
			PCVULC = '000000000000000',
			PCDMAC = '00000000',
			PCVMAC = '000000000000000',
			PCVSAT = '000000000000000',
			PCVLCR = '000000000000000',
			PCQPAG = '000000',
			PCQDAP = '000000',
			PCVDAV = '000000000000000',
			PCMDAV = '000000',
			PCMPMV = '000000',
			PCDATV = '000000000000000',
			PCMTV  = '0000',
			PCV15D = '000000000000000',
			PCM15D = '0000',
			PCV30D = '000000000000000',
			PCM30D = '0000',
			PCDTPC = '00000000',
			PCVPCO = '000000000000000',
			CASE WHEN A1_LC <= 10 THEN '5' ELSE '2' END AS PCVSIT,
			PCTIPG = '0',
			PCGGA  = '00',
			PCDTG  = '00000000',
			PCVLG  = '000000000000000',
			PCVPA  = '000000000000000',
			PCSVV  = '  '
		FROM %Table:SA1% A1 
			INNER JOIN %Table:SE1% E1 ON A1.A1_COD = E1.E1_CLIENTE
		WHERE  A1.%NotDel%  AND E1.%NotDel%
			AND A1.A1_PESSOA = 'J' AND LEFT(A1_CGC,8) NOT IN (' ','00000000','99999999') 
			AND E1.E1_TIPO = 'NF' AND E1.E1_EMISSAO <="VALTOSQL(dDataBase)"
			AND LEFT(A1_CGC,8) NOT IN ( SELECT SUBSTRING(ZY_PCCCLI,1,8) FROM %Table:SZY% ZY )
			GROUP BY LEFT(A1_CGC,8), A1_LC
		ORDER BY LEFT(A1_CGC,8), A1_LC
			
	EndSql	
    
	aQry01 := GetLastQuery()

	PutLog( Time()+" [QUERY][001][I][EMBED]")
	PutLog( Time()+" [QUERY][001][T] " + cValToChar(aQry01[05]) )
	PutLog( Time()+" [QUERY][001][Q] " + aQry01[02] )
	PutLog( Time()+" [QUERY][001][F][EMBED]")

	                                                                  '
	DbSelectArea("TRB2")
//	Count to _nQtdReg2
	dbGoTop()
Else
	cQuery := " SELECT PCTIPO = '1' , "+ENTER
	cQuery += "  PCCASS = '0000', "+ENTER
	cQuery += "  PCCCLI = LEFT(A1_CGC,8),"+ENTER
	cQuery += "  PCDDAT = '00000000',"+ENTER
	cQuery += "  PCDCDD = MIN(E1_EMISSAO) , "+ENTER // Data do Cadastramento = Data primeira compra (analisada pelo primeiro título gerado)
	cQuery += "  PCDUCM = MAX(E1_EMISSAO) , "+ENTER
	cQuery += "  PCVULC = '000000000000000',  "+ENTER
	cQuery += "  PCDMAC = '00000000', "+ENTER // Data do Maior Acumulo
	cQuery += "  PCVMAC = '000000000000000', "+ENTER
	cQuery += "  PCVSAT = '000000000000000', "+ENTER
	cQuery += "  PCVLCR = '000000000000000', "+ENTER
	cQuery += "  PCQPAG = '000000', "+ENTER
	cQuery += "  PCQDAP = '000000', "+ENTER
	cQuery += "  PCVDAV = '000000000000000', "+ENTER
	cQuery += "  PCMDAV = '000000', "+ENTER
	cQuery += "  PCMPMV = '000000', "+ENTER
	cQuery += "  PCDATV = '000000000000000', "+ENTER
	cQuery += "  PCMTV  = '0000',"+ENTER
	cQuery += "  PCV15D = '000000000000000', "+ENTER
	cQuery += "  PCM15D = '0000',"+ENTER
	cQuery += "  PCV30D = '000000000000000', "+ENTER
	cQuery += "  PCM30D = '0000', "+ENTER
	cQuery += "  PCDTPC = '00000000', "+ENTER
	cQuery += "  PCVPCO = '000000000000000',   "+ENTER
	cQuery += "  CASE WHEN A1_LC <= 10 THEN '5' ELSE '2' END AS PCVSIT,  "+ENTER
	cQuery += "  PCTIPG = '0', "+ENTER
	cQuery += "  PCGGA  = '00',"+ENTER
	cQuery += "  PCDTG  = '00000000', "+ENTER
	cQuery += "  PCVLG  = '000000000000000', "+ENTER
	cQuery += "  PCVPA  = '000000000000000', "+ENTER
	cQuery += "  PCSVV  = '  ' "+ENTER
	cQuery += "  FROM "+RetSqlName("SA1")+" A1 "+ENTER
	cQuery += "  INNER JOIN "+RetSqlName("SE1")+" E1 ON A1.A1_COD = E1.E1_CLIENTE "+ENTER
	cQuery += "  WHERE  A1.D_E_L_E_T_ = ' ' AND E1.D_E_L_E_T_ = ' ' AND A1.A1_PESSOA = 'J' AND LEFT(A1_CGC,8) <> ' ' AND LEFT(A1_CGC,8) <> '00000000' AND LEFT(A1_CGC,8) <> '99999999' AND E1.E1_TIPO = 'NF' AND E1.E1_EMISSAO <="+VALTOSQL(dDataBase)+""+ENTER
	cQuery += "  AND LEFT(A1_CGC,8) NOT IN ( SELECT SUBSTRING(ZY_PCCCLI,1,8) FROM "+RetSqlName("SZY")+" ZY)"+ENTER
	cQuery += "  GROUP BY LEFT(A1_CGC,8), A1_LC "+ENTER
	cQuery += "  ORDER BY LEFT(A1_CGC,8) "+ENTER
	
	MemoWrit("C:\Cisp\Log\Query1.sql",cQuery)
	
	PutLog( Time()+" [QUERY][001][I]")
	PutLog( Time()+" [QUERY][001] "+ ENTER + cQuery )
	dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), "TRB2", .T., .F. )
	PutLog( Time()+" [QUERY][001][F]")
	
	dbSelectArea("TRB2")
	Count to _nQtdReg2
	dbGoTop()
	
EndIf

PutLog( Time()+" [QUERY][001][P] Inicio Processamento.")

While ! TRB2->(Eof())
	If ! SZY->(DbSeek(xFilial("SZY")+TRB2->PCCCLI))
		RecLock("SZY",.T.)
		SZY->ZY_FILIAL := xFilial("SZY")
		SZY->ZY_PCTIPO := TRB2->PCTIPO // Tipo: Identif. (1-CNPJ / 2-CPF / 3-RG / 4-Export. / 5-Insc.Prod./ 9-Outros)
		SZY->ZY_PCCASS := val(MV_PAR02) // Codigo Associado
		SZY->ZY_PCCCLI := TRB2->PCCCLI // Identificação. (CNPJ / CPF / RG / Export. / Insc.Prod. / Outros)
		SZY->ZY_PCDCDD := CTOD(SUBSTR(TRB2->PCDCDD,7,2)+'/'+SUBSTR(TRB2->PCDCDD,5,2)+'/'+SUBSTR(TRB2->PCDCDD,1,4)) // Data  Cadastramento do Cliente
		SZY->ZY_PCDDAT := DDATABASE // Data da Informação
		SZY->ZY_PCVULC := val(TRB2->PCVULC) // Valor da Ultima Compra
		SZY->ZY_PCVMAC := val(TRB2->PCVMAC) // Valor do Maior Acumulo
		SZY->ZY_PCVSAT := val(TRB2->PCVSAT) // Valor Debito Atual Total
		SZY->ZY_PCVLCR := val(TRB2->PCVLCR) // Valor Limite de Credito
		SZY->ZY_PCQPAG := val(TRB2->PCQPAG) // Media Ponderada de Atraso no Pagamentos (Titulos Pagos)
		SZY->ZY_PCQDAP := val(TRB2->PCQDAP) // Media Aritimetica Dias de Atraso Pagamento
		SZY->ZY_PCVDAV := val(TRB2->PCVDAV) // Valor Debito Atual a Vencer
		SZY->ZY_PCMDAV := val(TRB2->PCMDAV) // Media Ponderada de Titulos a Vencer
		SZY->ZY_PCMPMV := val(TRB2->PCMPMV) // Prazo Medio de Vendas
		SZY->ZY_PCDATV := val(TRB2->PCDATV) // Valor Debito Atual Vencido + 5 dias
		SZY->ZY_PCMPTV := Round(val(TRB2->PCMTV),4) // Média Ponderada de Atraso Títulos Vencidos e não Pagos + 5 Dias
		SZY->ZY_PCV15D := val(TRB2->PCV15D) // Valor Débito Atual Vencido + 15 Dias
		SZY->ZY_PCM15D := Round(val(TRB2->PCM15D),4) // Média Ponderada de Atraso Títulos Vencidos e não Pagos + 15 Dias
		SZY->ZY_PCV30D := val(TRB2->PCV30D) // Valor Débito Atual Vencido + 30 Dias
		SZY->ZY_PCM30D := Round(val(TRB2->PCM30D),4) // Média Ponderada de Atraso Títulos Vencidos e não Pagos + 30 Dias
		SZY->ZY_PCVPCO := val(TRB2->PCVPCO) // Valor da Penúltima Compra
		SZY->ZY_PCVSIT := TRB2->PCVSIT // Situação do Cálculo Limite de Crédito
		SZY->ZY_PCTIPG := TRB2->PCTIPG // Tipo de Garantia
		SZY->ZY_PCGGA  := TRB2->PCGGA // Grau de Garantia - Hipoteca
		SZY->ZY_PCDTG  := CTOD(SUBSTR(TRB2->PCDTG,7,2)+'/'+SUBSTR(TRB2->PCDTG,5,2)+'/'+SUBSTR(TRB2->PCDTG,1,4))  // Data Validade da Garantia
		SZY->ZY_PCVLG  := val(TRB2->PCVLG) // Valor da Garantia
		SZY->ZY_PCVPA  := val(TRB2->PCVPA ) // Valor da Venda Pagamento Antecipado
		SZY->ZY_PCSVV  := TRB2->PCSVV // Venda sem Credito (ANTECIPADO)
		SZY->(MsUnlock())
	Endif
	
	TRB2->(DBSKIP())
ENDDO

PutLog( Time()+" [QUERY][001][P] Fim Processamento.")




PutLog( " ["+Replicate("-",100)+ "]")
PutLog( " ["+Replicate("+=",50)+ "]")
PutLog( " ["+Replicate("-",100)+ "]")


_dDATADE   := CTOD("01/01/2000")

lAtiva1 := .T.
lAtiva2 := .T.
lAtiva3 := .T.

If !Empty(Select("TRB33"))
	dbSelectArea("TRB33")
	dbCloseArea()
Endif


If lEmbed .And. .F.


	BeginSql Alias "TRB33"


	// Query de razão de clientes
		SELECT  ANO = (SELECT MAX(YEAR(E1_EMISSAO)) FROM %Table:SE1% E1 
			INNER JOIN %Table:SA1% A1 ON E1.E1_CLIENTE = A1.A1_COD WHERE LEFT(A1_CGC,8) BETWEEN %Exp:MV_PAR03% AND %Exp:MV_PAR04%)
		,E1_NUM,E1_PARCELA,E1_EMISSAO,LEFT(A1_CGC,8) as CNPJ, E1_VALOR ,DATACC = E1_EMISSAO, 0 AS SALDO,E1_VENCREA,
		CASE WHEN E1_VENCREA >= "+VALTOSQL(_dDataDE)+" THEN ' ' ELSE E1_BAIXA END AS E1_BAIXA ,  
		0 AS DIATRA ,0 AS VLRCALC,  
		 '' AS DATAM, 0 AS VLRM, VLRDAV = (CASE WHEN E1_VENCREA > "+VALTOSQL(dDataBase)+" THEN E1_VALOR ELSE 0 END ),  
		CASE WHEN E1_VENCREA > "+VALTOSQL(dDataBase)+" THEN DATEDIFF(DAY,E1_EMISSAO,E1_VENCREA) ELSE 0 END AS DIASAV,  
		CASE WHEN E1_VENCREA > "+VALTOSQL(dDataBase)+" THEN DATEDIFF(DAY,E1_EMISSAO,E1_VENCREA) * E1_VALOR ELSE 0 END AS VLRAVC, A1_LC , ORDEM = 1 
		FROM "+RetSqlName("SE1")+" E1 
		INNER JOIN "+RetSqlName("SA1")+" A1 ON E1.E1_CLIENTE = A1.A1_COD AND E1.E1_LOJA = A1.A1_LOJA  
		WHERE ( E1.E1_VENCREA >= "+VALTOSQL(_dDataDE) +" AND ( E1.E1_EMISSAO <= "+VALTOSQL(dDataBase)+" AND E1.E1_EMISSAO >="+VALTOSQL(_dDataDE) +") AND ( E1.E1_BAIXA >= "+VALTOSQL(_dDataDE) +" OR E1.E1_BAIXA = ' ') ) AND  E1.E1_TIPO = 'NF' AND A1.D_E_L_E_T_ = ' ' AND E1.D_E_L_E_T_ = ' '  
		AND LEFT(A1_CGC,8) BETWEEN  '"+MV_PAR03+"' AND '"+MV_PAR04 +"' 
		UNION ALL  
		SELECT  ANO = (SELECT MAX(YEAR(E1_EMISSAO)) FROM "+RetSqlName("SE1")+" E1 INNER JOIN "+RetSqlName("SA1")+" A1 ON E1.E1_CLIENTE = A1.A1_COD WHERE LEFT(A1_CGC,8) BETWEEN  '"+MV_PAR03+"' AND '"+MV_PAR04 +"') 
		,E1_NUM,E1_PARCELA,E1_EMISSAO,LEFT(A1_CGC,8) as CNPJ,  
		E1_VALOR = (CASE WHEN  E1_BAIXA <> ' ' THEN ((E1_VALOR-E1_SALDO)*-1) END),   
		 	DATACC   = (CASE WHEN E1_BAIXA <> ' ' THEN E1_BAIXA END ), 0 AS SALDO,E1_VENCREA,E1_BAIXA,  
		 	CASE WHEN DATEDIFF(DAY,E1_VENCREA,E1_BAIXA) >= 0  THEN DATEDIFF(DAY,E1_VENCREA,E1_BAIXA)  
		      	WHEN E1_BAIXA <> ' ' AND E1_BAIXA > E1_VENCREA THEN DATEDIFF(DAY,E1_VENCREA,"+VALTOSQL(dDataBase)+")  
		      	WHEN E1_BAIXA = ' ' AND E1_VENCREA < "+VALTOSQL(dDataBase)+" THEN  DATEDIFF(DAY,E1_VENCREA,"+VALTOSQL(dDataBase)+")  
		    	ELSE 0 END AS DIATRA , 
		  	CASE WHEN DATEDIFF(DAY,E1_VENCREA,E1_BAIXA) >= 0  THEN (E1_VALOR*DATEDIFF(DAY,E1_VENCREA,E1_BAIXA))  
		       WHEN E1_BAIXA <> ' ' AND E1_BAIXA > E1_VENCREA THEN (E1_VALOR*DATEDIFF(DAY,E1_VENCREA,"+VALTOSQL(dDataBase)+"))  
		       WHEN E1_BAIXA = ' '  AND E1_VENCREA < "+VALTOSQL(dDataBase)+" THEN (E1_VALOR*DATEDIFF(DAY,E1_VENCREA,"+VALTOSQL(dDataBase)+")) 
			ELSE 0 END AS VLRCALC, 
			'' AS DATAM, 0 AS VLRM,VLRDAV = 0 , DIASAV = 0, VLRAVC = 0 , A1_LC, ORDEM = 2 
		FROM "+RetSqlName("SE1")+" E1 
		INNER JOIN "+RetSqlName("SA1")+" A1 ON E1.E1_CLIENTE = A1.A1_COD AND E1.E1_LOJA = A1.A1_LOJA  
		// WHERE ( E1.E1_EMISSAO <= "+VALTOSQL(dDataBase)+" AND E1.E1_EMISSAO >="+VALTOSQL(_dDataDE) +") AND E1.E1_TIPO = 'NF' AND A1.D_E_L_E_T_ = ' ' AND E1.D_E_L_E_T_ = ' ' AND E1.E1_VENCREA < "+VALTOSQL(dDataBase)+ENTER
		WHERE ( E1.E1_EMISSAO <= "+VALTOSQL(dDataBase)+" AND E1.E1_EMISSAO >="+VALTOSQL(_dDataDE) +") AND E1.E1_TIPO = 'NF' AND A1.D_E_L_E_T_ = ' ' AND E1.D_E_L_E_T_ = ' ' 
		AND LEFT(A1.A1_CGC,8) BETWEEN  '"+MV_PAR03+"' AND '"+MV_PAR04 +"'  
		ORDER BY CNPJ,DATACC,ORDEM,E1_VALOR,E1_NUM,E1_PARCELA  
	
	EndSql
	


	aQry01 := GetLastQuery()

	PutLog( Time()+" [QUERY][002][I][EMBED]")
	PutLog( Time()+" [QUERY][002][T] " + cValToChar(aQry01[05]) )
	PutLog( Time()+" [QUERY][002][Q] " + aQry01[02] )
	PutLog( Time()+" [QUERY][002][F][EMBED]")

Else

	
	// Query de razão de clientes
	cQuery1 := " SELECT  ANO = (SELECT MAX(YEAR(E1_EMISSAO)) FROM "+RetSqlName("SE1")+" E1 INNER JOIN "+RetSqlName("SA1")+" A1 ON E1.E1_CLIENTE = A1.A1_COD WHERE LEFT(A1_CGC,8) BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04 +"')"+ENTER
	cQuery1 += " ,E1_NUM,E1_PARCELA,E1_EMISSAO,LEFT(A1_CGC,8) as CNPJ, E1_VALOR ,DATACC = E1_EMISSAO, 0 AS SALDO,E1_VENCREA, " + ENTER
	cQuery1 += " CASE WHEN E1_VENCREA >= "+VALTOSQL(_dDataDE)+" THEN ' ' ELSE E1_BAIXA END AS E1_BAIXA , "+ENTER
	cQuery1 += " 0 AS DIATRA ,0 AS VLRCALC, "+ENTER
	cQuery1 += "  '' AS DATAM, 0 AS VLRM, VLRDAV = (CASE WHEN E1_VENCREA > "+VALTOSQL(dDataBase)+" THEN E1_VALOR ELSE 0 END ), "+ENTER
	cQuery1 += " CASE WHEN E1_VENCREA > "+VALTOSQL(dDataBase)+" THEN DATEDIFF(DAY,E1_EMISSAO,E1_VENCREA) ELSE 0 END AS DIASAV, "+ENTER
	cQuery1 += " CASE WHEN E1_VENCREA > "+VALTOSQL(dDataBase)+" THEN DATEDIFF(DAY,E1_EMISSAO,E1_VENCREA) * E1_VALOR ELSE 0 END AS VLRAVC, A1_LC , ORDEM = 1"+ENTER
	cQuery1 += " FROM "+RetSqlName("SE1")+" E1"+ENTER
	cQuery1 += " INNER JOIN "+RetSqlName("SA1")+" A1 ON E1.E1_CLIENTE = A1.A1_COD AND E1.E1_LOJA = A1.A1_LOJA "+ENTER
	cQuery1 += " WHERE ( E1.E1_VENCREA >= "+VALTOSQL(_dDataDE) +" AND ( E1.E1_EMISSAO <= "+VALTOSQL(dDataBase)+" AND E1.E1_EMISSAO >="+VALTOSQL(_dDataDE) +") AND ( E1.E1_BAIXA >= "+VALTOSQL(_dDataDE) +" OR E1.E1_BAIXA = ' ') ) AND  E1.E1_TIPO = 'NF' AND A1.D_E_L_E_T_ = ' ' AND E1.D_E_L_E_T_ = ' ' "+ENTER
	cQuery1 += " AND LEFT(A1_CGC,8) BETWEEN  '"+MV_PAR03+"' AND '"+MV_PAR04 +"'"+ENTER
	cQuery1 += " UNION ALL "+ENTER
	cQuery1 += " SELECT  ANO = (SELECT MAX(YEAR(E1_EMISSAO)) FROM "+RetSqlName("SE1")+" E1 INNER JOIN "+RetSqlName("SA1")+" A1 ON E1.E1_CLIENTE = A1.A1_COD WHERE LEFT(A1_CGC,8) BETWEEN  '"+MV_PAR03+"' AND '"+MV_PAR04 +"')"+ENTER
	cQuery1 += " ,E1_NUM,E1_PARCELA,E1_EMISSAO,LEFT(A1_CGC,8) as CNPJ, "+ENTER
	cQuery1 += " E1_VALOR = (CASE WHEN  E1_BAIXA <> ' ' THEN ((E1_VALOR-E1_SALDO)*-1) END),  "+ENTER
	cQuery1 += " DATACC   = (CASE WHEN E1_BAIXA <> ' ' THEN E1_BAIXA END ), 0 AS SALDO,E1_VENCREA,E1_BAIXA, "+ENTER
	cQuery1 += " CASE WHEN DATEDIFF(DAY,E1_VENCREA,E1_BAIXA) >= 0  THEN DATEDIFF(DAY,E1_VENCREA,E1_BAIXA) "+ENTER
	cQuery1 += "      WHEN E1_BAIXA <> ' ' AND E1_BAIXA > E1_VENCREA THEN DATEDIFF(DAY,E1_VENCREA,"+VALTOSQL(dDataBase)+") "+ENTER
	cQuery1 += "      WHEN E1_BAIXA = ' ' AND E1_VENCREA < "+VALTOSQL(dDataBase)+" THEN  DATEDIFF(DAY,E1_VENCREA,"+VALTOSQL(dDataBase)+") "+ENTER
	cQuery1 += "      ELSE 0 END AS DIATRA ,"+ENTER
	cQuery1 += "  CASE WHEN DATEDIFF(DAY,E1_VENCREA,E1_BAIXA) >= 0  THEN (E1_VALOR*DATEDIFF(DAY,E1_VENCREA,E1_BAIXA)) "+ENTER
	cQuery1 += "       WHEN E1_BAIXA <> ' ' AND E1_BAIXA > E1_VENCREA THEN (E1_VALOR*DATEDIFF(DAY,E1_VENCREA,"+VALTOSQL(dDataBase)+")) "+ENTER
	cQuery1 += "       WHEN E1_BAIXA = ' '  AND E1_VENCREA < "+VALTOSQL(dDataBase)+" THEN (E1_VALOR*DATEDIFF(DAY,E1_VENCREA,"+VALTOSQL(dDataBase)+"))"+ENTER
	cQuery1 += "       ELSE 0 END AS VLRCALC,"+ENTER
	cQuery1 += " '' AS DATAM, 0 AS VLRM,VLRDAV = 0 , DIASAV = 0, VLRAVC = 0 , A1_LC, ORDEM = 2"+ENTER
	cQuery1 += " FROM "+RetSqlName("SE1")+" E1"+ENTER
	cQuery1 += " INNER JOIN "+RetSqlName("SA1")+" A1 ON E1.E1_CLIENTE = A1.A1_COD AND E1.E1_LOJA = A1.A1_LOJA "+ENTER
	//cQuery1 += " WHERE ( E1.E1_EMISSAO <= "+VALTOSQL(dDataBase)+" AND E1.E1_EMISSAO >="+VALTOSQL(_dDataDE) +") AND E1.E1_TIPO = 'NF' AND A1.D_E_L_E_T_ = ' ' AND E1.D_E_L_E_T_ = ' ' AND E1.E1_VENCREA < "+VALTOSQL(dDataBase)+ENTER
	cQuery1 += " WHERE ( E1.E1_EMISSAO <= "+VALTOSQL(dDataBase)+" AND E1.E1_EMISSAO >="+VALTOSQL(_dDataDE) +") AND E1.E1_TIPO = 'NF' AND A1.D_E_L_E_T_ = ' ' AND E1.D_E_L_E_T_ = ' '"+ENTER
	cQuery1 += " AND LEFT(A1.A1_CGC,8) BETWEEN  '"+MV_PAR03+"' AND '"+MV_PAR04 +"' "+ENTER
	cQuery1 += " ORDER BY CNPJ,DATACC,ORDEM,E1_VALOR,E1_NUM,E1_PARCELA "+ENTER

	PutLog( Time()+" [QUERY][002][I]" )
	PutLog( Time()+" [QUERY][002] "+ ENTER + cQuery1 )
	dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery1), "TRB33", .T., .F. )
	PutLog( Time()+" [QUERY][002][F]" )
	
EndIf
	
MemoWrit("C:\Cisp\Log\Query2.sql",cQuery1)
                                                 

dbSelectArea("TRB33")
dbGoTop()

_CNPJ := TRB33->CNPJ
DATMACU := ' '
VALRMACU := 0
NDATAM   := TRB33->DATACC

MSALDO   := 0
DATAMC   := ' '

DATAMACU2 := ' '
VALRMACU2 := 0
MSALDO2  := 0
DATAMC2  := ' '

DATAPC   := ' '
VLRPUC   := 0
DATAUC   := ' '
VLRUC    := 0
_Z       := 0
_X       := 0
_Y       := 0
_NT      := 0
VLDAVC   := 0
_Z1      := 0
_X1      := 0
_Y1      := 0
_NT1     := 0
_VLRVC   := 0
xChave   := TRB33->E1_EMISSAO+TRB33->E1_BAIXA

VLRMACU := 0
VLRmAC  := 0

xSaldo		:= 0
xSaldo1		:= 0
xSalAc		:= 0
xData1 := ctod("  /  /  ")

// Efetua o calculo do acumulo.
DbSelectArea("TRB33")
DbGoTop()
While ! TRB33->(Eof())
	// DEFINE QUAL PERIODO INICIAL
	If trb33->ano == 2014
		xData  :=  YEARSUB(dDatabase,3)
	ElseIf trb33->ano == 2015
		xData  :=  YEARSUB(dDatabase,2)
	ElseIf trb33->ano == 2016
		xData  :=  YEARSUB(dDatabase,1)
	Else
		xData  :=  YEARSUB(dDatabase,1)
	Endif
	While TRB33->CNPJ == _CNPJ
		xSaldo1 += TRB33->E1_VALOR
		xSaldo  += TRB33->E1_VALOR
		// Se o Maior Acumulo estiver dentro dos 12 meses.
		If xSaldo1 >= xSalac .and. CTOD(SUBSTR(TRB33->DATACC,7,2)+"/"+SUBSTR(TRB33->DATACC,5,2)+"/"+SUBSTR(TRB33->DATACC,1,4)) >= xData .and. CTOD(SUBSTR(TRB33->DATACC,7,2)+"/"+SUBSTR(TRB33->DATACC,5,2)+"/"+SUBSTR(TRB33->DATACC,1,4)) <= dDataBase
			xSalac := xSaldo
			xData1 := CTOD(SUBSTR(TRB33->DATACC,7,2)+"/"+SUBSTR(TRB33->DATACC,5,2)+"/"+SUBSTR(TRB33->DATACC,1,4))
		Endif
		_CNPJ1 := TRB33->CNPJ
		TRB33->(DbSkip())
		If TRB33->(Eof())
			Exit
		Endif
	Enddo
	_CNPJ := TRB33->CNPJ
	VLRMACU := 0
	If SZY->(DbSeek(xFilial("SZY")+_CNPJ1))
		RecLock("SZY",.F.)
		// Data e Valor do Maior Acumulo
		SZY->ZY_PCVMAC := xSalac // Valor do MAior Acumulo
		SZY->ZY_PCDMAC := xData1 // CTOD(SUBSTR(DATMACU,7,2)+'/'+SUBSTR(DATMACU,5,2)+'/'+SUBSTR(DATMACU,1,4)) // Data do Maior Acumulo
		SZY->ZY_PCDDAT := DDATABASE // Data da Informação
		MsUnlock()
	Endif
	VLRmAC := 0
	xSaldo := 0
	xSaldo1 := 0
	xSalAc := 0
	xData1 := ctod("  /  /  ")
Enddo

/* Monta novo Select para analisar as médias aritiméticas*/

_dDATADE   := CTOD("01/01/2000")
_dDataDE2  := YEARSUB(MV_PAR05,1) // YEARSUB(dDatabase,1)

// Query de razão de clientes
cQuery99 := " SELECT  ANO = (SELECT MAX(YEAR(E1_EMISSAO)) FROM "+RetSqlName("SE1")+" E1 INNER JOIN "+RetSqlName("SA1")+" A1 ON E1.E1_CLIENTE = A1.A1_COD WHERE LEFT(A1_CGC,8) BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04 +"')"+ENTER
cQuery99 += " ,E1_NUM,E1_PARCELA,E1_EMISSAO,LEFT(A1_CGC,8) as CNPJ, E1_VALOR ,DATACC = E1_EMISSAO, 0 AS SALDO,E1_VENCREA, " + ENTER
cQuery99 += " CASE WHEN E1_VENCREA >= "+VALTOSQL(_dDataDE)+" THEN ' ' ELSE E1_BAIXA END AS E1_BAIXA , "+ENTER
cQuery99 += " 0 AS DIATRA ,0 AS VLRCALC, "+ENTER
cQuery99 += "  '' AS DATAM, 0 AS VLRM, VLRDAV = (CASE WHEN E1_VENCREA > "+VALTOSQL(dDataBase)+" THEN E1_VALOR ELSE 0 END ), "+ENTER
cQuery99 += " CASE WHEN E1_VENCREA > "+VALTOSQL(dDataBase)+" THEN DATEDIFF(DAY,E1_EMISSAO,E1_VENCREA) ELSE 0 END AS DIASAV, "+ENTER
cQuery99 += " CASE WHEN E1_VENCREA > "+VALTOSQL(dDataBase)+" THEN DATEDIFF(DAY,E1_EMISSAO,E1_VENCREA) * E1_VALOR ELSE 0 END AS VLRAVC, A1_LC , ORDEM = 1"+ENTER
cQuery99 += " FROM "+RetSqlName("SE1")+" E1"+ENTER
cQuery99 += " INNER JOIN "+RetSqlName("SA1")+" A1 ON E1.E1_CLIENTE = A1.A1_COD AND E1.E1_LOJA = A1.A1_LOJA "+ENTER
cQuery99 += " WHERE ( E1.E1_VENCREA >= "+VALTOSQL(_dDataDE) +" AND ( E1.E1_EMISSAO <= "+VALTOSQL(dDataBase)+" AND E1.E1_EMISSAO >="+VALTOSQL(_dDataDE) +") AND ( E1.E1_BAIXA >= "+VALTOSQL(_dDataDE) +" OR E1.E1_BAIXA = ' ') ) AND  E1.E1_TIPO = 'NF' AND A1.D_E_L_E_T_ = ' ' AND E1.D_E_L_E_T_ = ' ' "+ENTER
cQuery99 += " AND LEFT(A1_CGC,8) BETWEEN  '"+MV_PAR03+"' AND '"+MV_PAR04 +"'"+ENTER
cQuery99 += " UNION ALL "+ENTER
cQuery99 += " SELECT  ANO = (SELECT MAX(YEAR(E1_EMISSAO)) FROM "+RetSqlName("SE1")+" E1 INNER JOIN "+RetSqlName("SA1")+" A1 ON E1.E1_CLIENTE = A1.A1_COD WHERE LEFT(A1_CGC,8) BETWEEN  '"+MV_PAR03+"' AND '"+MV_PAR04 +"')"+ENTER
cQuery99 += " ,E1_NUM,E1_PARCELA,E1_EMISSAO,LEFT(A1_CGC,8) as CNPJ, "+ENTER
cQuery99 += " E1_VALOR = (CASE WHEN  E1_BAIXA <> ' ' THEN ((E1_VALOR-E1_SALDO)*-1) END), "+ENTER
cQuery99 += " DATACC   = (CASE WHEN E1_BAIXA <> ' ' THEN E1_BAIXA END ), 0 AS SALDO,E1_VENCREA,E1_BAIXA, "+ENTER
cQuery99 += " CASE WHEN DATEDIFF(DAY,E1_VENCREA,E1_BAIXA) >= 0  THEN DATEDIFF(DAY,E1_VENCREA,E1_BAIXA) "+ENTER
cQuery99 += "      WHEN E1_BAIXA <> ' ' AND E1_BAIXA > E1_VENCREA THEN DATEDIFF(DAY,E1_VENCREA,"+VALTOSQL(dDataBase)+") "+ENTER
cQuery99 += "      WHEN E1_BAIXA = ' ' AND E1_VENCREA < "+VALTOSQL(dDataBase)+" THEN  DATEDIFF(DAY,E1_VENCREA,"+VALTOSQL(dDataBase)+") "+ENTER
cQuery99 += "      ELSE 0 END AS DIATRA ,"+ENTER
cQuery99 += "  CASE WHEN DATEDIFF(DAY,E1_VENCREA,E1_BAIXA) >= 0  THEN (E1_VALOR*DATEDIFF(DAY,E1_VENCREA,E1_BAIXA)) "+ENTER
cQuery99 += "       WHEN E1_BAIXA <> ' ' AND E1_BAIXA > E1_VENCREA THEN (E1_VALOR*DATEDIFF(DAY,E1_VENCREA,"+VALTOSQL(dDataBase)+")) "+ENTER
cQuery99 += "       WHEN E1_BAIXA = ' '  AND E1_VENCREA < "+VALTOSQL(dDataBase)+" THEN (E1_VALOR*DATEDIFF(DAY,E1_VENCREA,"+VALTOSQL(dDataBase)+"))"+ENTER
cQuery99 += "       ELSE 0 END AS VLRCALC,"+ENTER
cQuery99 += " '' AS DATAM, 0 AS VLRM,VLRDAV = 0 , DIASAV = 0, VLRAVC = 0 , A1_LC, ORDEM = 2"+ENTER
cQuery99 += " FROM "+RetSqlName("SE1")+" E1"+ENTER
cQuery99 += " INNER JOIN "+RetSqlName("SA1")+" A1 ON E1.E1_CLIENTE = A1.A1_COD AND E1.E1_LOJA = A1.A1_LOJA "+ENTER
cQuery99 += " WHERE ( E1.E1_EMISSAO <= "+VALTOSQL(dDataBase)+" AND E1.E1_EMISSAO >="+VALTOSQL(_dDataDE) +") AND E1.E1_TIPO = 'NF' AND A1.D_E_L_E_T_ = ' ' AND E1.D_E_L_E_T_ = ' ' AND E1.E1_VENCREA < "+VALTOSQL(dDataBase)+ENTER
cQuery99 += " AND LEFT(A1.A1_CGC,8) BETWEEN  '"+MV_PAR03+"' AND '"+MV_PAR04 +"' "+ENTER
cQuery99 += " ORDER BY CNPJ,DATACC,ORDEM,E1_VALOR,E1_NUM,E1_PARCELA "+ENTER
If !Empty(Select("TRB99"))
	dbSelectArea("TRB99")
	dbCloseArea()
Endif

//MemoWrit("C:\SIGA\Query99.sql",cQuery1)
                                         
MemoWrit("C:\Cisp\Log\Query2.sql",cQuery1)
                                                
PutLog( Time()+" [QUERY][003][I]" )
PutLog( Time()+" [QUERY][003] "+ ENTER + cQuery1 )
dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery1), "TRB99", .T., .F. )
PutLog( Time()+" [QUERY][003][F]" )


DbSelectArea("TRB99")
DbGoTop()
_CNPJ := TRB99->CNPJ
_ENUM := ' '

While ! TRB99->(Eof())
	WHILE TRB99->CNPJ == _CNPJ .AND. ! TRB99->(Eof())
		If TRB99->DIATRA > 0
			_Z     += TRB99->VLRCALC
			_Y     += TRB99->DIATRA
		Endif
		_X  += iif(TRB99->E1_VALOR > 0, TRB99->E1_VALOR,0)
		If _ENUM <> TRB99->E1_NUM+TRB99->E1_PARCELA .AND. TRB99->ORDEM = 1
			_NT++
		Endif
		IF TRB99->DIASAV > 0
			_Z1     += TRB99->VLRAVC
			_X1     += TRB99->E1_VALOR
			_Y1     += TRB99->DIASAV
			_NT1++
		ENDIF
		VLDAVC += TRB99->VLRDAV
		_ENUM := TRB99->E1_NUM+TRB99->E1_PARCELA
		TRB99->(DbSkip())
	End
	
	If SZY->(DbSeek(xFilial("SZY")+_CNPJ))
		RecLock("SZY",.F.)
		SZY->ZY_PCVLCR := VlrLiCre // Valor Limite de Credito
		SZY->ZY_PCQPAG := IIf( (_Z/_X ) < 0.01 .and. (_Z/_X ) > 0, 0.01,If((_Z/_X)>999.99,999.99,(_Z/_X)) ) // Media Ponderada de Atraso no Pagamentos (Titulos Pagos)
		SZY->ZY_PCQDAP := Iif( (_Y/_NT) < 0.01 .and. (_Y/_NT) > 0, 0.01,If((_Y/_NT)>999.99,999.99,(_Y/_NT)) ) // Media Aritimetica Dias de Atraso Pagamento
		SZY->ZY_PCVDAV := VLDAVC  // Valor Debito Atual a Vencer
		SZY->ZY_PCMDAV := IIf( (_Z1/_X1) < 0.01 .and. (_Z1/_X1 ) > 0, 0.01,If((_Z1/_X1)>999.99,999.99,(_Z1/_X1)) ) // Media Ponderada de Titulos a Vencer
		SZY->ZY_PCMPMV := Iif( (_Y1/_NT1)< 0.01 .and. (_Y1/_NT1) > 0, 0.01,If((_Y1/_NT1)>999.99,999.99,(_Y1/_NT1)) ) // Prazo Medio de Vendas
		// Zera campos para o proximo calculo
		SZY->ZY_PCVSAT := 0 // Valor Debito Atual Total
		SZY->ZY_PCDATV := 0 // Valor Debito Atual Vencido + 5 dias
		SZY->ZY_PCMPTV := 0 // Média Ponderada de Atraso Títulos Vencidos e não Pagos + 5 Dias
		SZY->ZY_PCV15D := 0 // Valor Débito Atual Vencido + 15 Dias
		SZY->ZY_PCM15D := 0 // Média Ponderada de Atraso Títulos Vencidos e não Pagos + 15 Dias
		SZY->ZY_PCV30D := 0 // Valor Débito Atual Vencido + 30 Dias
		SZY->ZY_PCM30D := 0 // Média Ponderada de Atraso Títulos Vencidos e não Pagos + 30 Dias
		SZY->ZY_PCDDAT := DDATABASE // Data da Informação
		MsUnlock()
	Endif
	_CNPJ := TRB99->CNPJ
	_Z       := 0
	_X       := 0
	_Y       := 0
	_NT      := 0
	VLDAVC   := 0
	_Z1      := 0
	_X1      := 0
	_Y1      := 0
	_NT1     := 0
	_VLRVC   := 0
End

_dDataDe := CTOD("01/01/2000") // Altera a data inicial para acumular os débitos em aberto.

cQuery2 := "   SELECT LEFT(A1_CGC,8) CNPJ,E1_EMISSAO,E1_NUM,E1_CLIENTE,E1_VENCREA,E1_VALOR , "+ENTER
cQuery2 += "   CASE WHEN E1_BAIXA >= "+VALTOSQL(dDataBase)+" OR ( E1_BAIXA <> ' ' AND E1_VENCREA >= "+VALTOSQL(dDataBase)+" ) THEN ' ' ELSE E1_BAIXA END AS E1_BAIXA,E1_VALOR , "+ENTER
cQuery2 += "    CASE WHEN ( E1_VENCREA < "+VALTOSQL(dDataBase)+" AND E1_BAIXA = ' ') THEN DATEDIFF(DAY,E1_VENCREA,"+VALTOSQL(dDataBase)+") "+ENTER
cQuery2 += "         ELSE 0 END AS DIFER, "+ENTER
cQuery2 += "    CASE WHEN ( E1_VENCREA < "+VALTOSQL(dDataBase)+" AND E1_BAIXA = ' ' ) THEN ( DATEDIFF(DAY,E1_VENCREA,"+VALTOSQL(dDataBase)+") * E1_VALOR )  "+ENTER
cQuery2 += "         ELSE 0 END AS VLRAC  "+ENTER
cQuery2 += "   FROM "+RetSqlName("SE1")+" E1  "+ENTER
cQuery2 += "   INNER JOIN "+RetSqlName("SA1")+" A1 ON E1.E1_CLIENTE = A1.A1_COD AND E1.E1_LOJA = A1.A1_LOJA "+ENTER
cQuery2 += "   WHERE A1.D_E_L_E_T_ = ' ' AND E1.E1_TIPO = 'NF' AND E1.E1_EMISSAO >= "+VALTOSQL(_dDATADE)+ENTER
cQuery2 += "   AND E1.D_E_L_E_T_ = ' ' AND LEFT(A1_CGC,8) BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"'"+ENTER
cQuery2 += "   ORDER BY LEFT(A1_CGC,8),E1_EMISSAO "+ENTER

If !Empty(Select("TRB34"))
	dbSelectArea("TRB34")
	dbCloseArea()
Endif

MemoWrit("C:\Cisp\Log\Query3.sql",cQuery2)
//MemoWrit("C:\SIGA\Query2.sql",cQuery2)

PutLog( Time()+" [QUERY][004][I]" )
PutLog( Time()+" [QUERY][004] "+ ENTER + cQuery2 )
dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery2), "TRB34", .T., .F. )
PutLog( Time()+" [QUERY][004][F]" )
                                                 

dbSelectArea("TRB34")
dbGoTop()
_CNPJ := TRB34->CNPJ

_VLR5   := 0
_DIA5   := 0
_VLRAC5 := 0

_VLR15   := 0
_DIA15   := 0
_VLRAC15 := 0

_VLR30   := 0
_DIA30   := 0
_VLRAC30 := 0
_VlrDebT := 0
_xSalac1 := 0

While ! TRB34->(Eof())
	While TRB34->CNPJ == _CNPJ
		If TRB34->E1_EMISSAO <= DtoS(dDataBase)
			_VlrDebt += IIF(EMPTY(TRB34->E1_BAIXA) ,TRB34->E1_VALOR,0)
		Else
			_VlrDebt += 0
		Endif
		IF TRB34->DIFER > 5
			_VLR5 += TRB34->E1_VALOR
			_DIA5 += TRB34->DIFER
			_VLRAC5 += TRB34->VLRAC
		ENDIF
		IF TRB34->DIFER > 15
			_VLR15 += TRB34->E1_VALOR
			_DIA15 += TRB34->DIFER
			_VLRAC15 += TRB34->VLRAC
		ENDIF
		IF TRB34->DIFER > 30
			_VLR30 += TRB34->E1_VALOR
			_DIA30 += TRB34->DIFER
			_VLRAC30 += TRB34->VLRAC
		ENDIF
		TRB34->(dbSkip())
	End
	// Atualiza o valor acumulado quando o mesmo for menor que debito.
	If SZY->ZY_PCVMAC < _VlrDebt
		_xSalac1 := _VlrDebt
	Endif
	If SZY->(DbSeek(xFilial("SZY")+_CNPJ))
		RecLock("SZY",.F.)
		SZY->ZY_PCVLCR := VlrLiCre // Valor Limite de Credito
		SZY->ZY_PCVSAT := _VLRDEBT // Valor Debito Atual Total
		SZY->ZY_PCDATV := _VLR5 // Valor Debito Atual Vencido + 5 dias
		SZY->ZY_PCMPTV := Round(INT(_VLRAC5 / _VLR5),4) // Média Ponderada de Atraso Títulos Vencidos e não Pagos + 5 Dias
		SZY->ZY_PCV15D := _VLR15 // Valor Débito Atual Vencido + 15 Dias
		SZY->ZY_PCM15D := Round(INT(_VLRAC15 / _VLR15),4) // Média Ponderada de Atraso Títulos Vencidos e não Pagos + 15 Dias
		SZY->ZY_PCV30D := _VLR30 // Valor Débito Atual Vencido + 30 Dias
		SZY->ZY_PCM30D := Round(INT(_VLRAC30 / _VLR30),4) // Média Ponderada de Atraso Títulos Vencidos e não Pagos + 30 Dias
		SZY->ZY_PCDDAT := DDATABASE // Data da Informação
		// Ajusta o valor acumulado quando o mesmo e menor que debito.
		If SZY->ZY_PCVMAC < SZY->ZY_PCVSAT // Compara com o novo acumulo
			SZY->ZY_PCVMAC := SZY->ZY_PCVSAT // Valor do MAior Acumulo
		Endif
		// Ajusta o valor acumulado quando o mesmo e menor que ultima compra e menor que debito atual.
		If SZY->ZY_PCVULC > SZY->ZY_PCVMAC // Compara com o novo acumulo
			SZY->ZY_PCVMAC := SZY->ZY_PCVULC + SZY->ZY_PCVMAC // Novo valor do Maior Acumulo
		Endif
		// Ajusta a data do maior acumulo se for maior que data da última compra.
		If SZY->ZY_PCDUCM < SZY->ZY_PCDMAC // Compara com a data da última compra
			SZY->ZY_PCDMAC := SZY->ZY_PCDUCM // Nova data do Maior Acumulo
		Endif
		MsUnlock()
	Endif
	_VLR5   := 0
	_DIA5   := 0
	_VLRAC5 := 0
	_VLR15   := 0
	_DIA15   := 0
	_VLRAC15 := 0
	_VLR30   := 0
	_DIA30   := 0
	_VLRAC30 := 0
	_VlrDebT := 0
	_xSalac1 := 0
	_CNPJ    := TRB34->CNPJ
	
End

// Gerando a data e o valor da penultima compra

SZY->(DbGotop())

cQuery3 := " SELECT LEFT(A1_CGC,8) CNPJ,E1_CLIENTE, E1_EMISSAO , F2_VALFAT AS E1_VALOR , E1_NUM"+ENTER
cQuery3 += " FROM "+RetSqlName("SE1")+" E1 "+ENTER
cQuery3 += " INNER JOIN "+RetSqlName("SA1")+" A1 ON A1.A1_COD = E1.E1_CLIENTE AND A1.A1_LOJA = E1.E1_LOJA "+ENTER
cQuery3 += " INNER JOIN "+RetSqlName("SF2")+" F2 ON E1.E1_NUM = F2.F2_DOC AND E1.E1_PREFIXO = F2.F2_SERIE AND E1.E1_CLIENTE = F2.F2_CLIENTE AND E1.E1_LOJA = F2.F2_LOJA "+ENTER
cQuery3 += " WHERE E1_TIPO = 'NF' AND E1_EMISSAO >= "+VALTOSQL(_dDATADE)+" AND E1.D_E_L_E_T_ = ' ' AND( E1_EMISSAO <= "+VALTOSQL(dDataBase)+" AND E1_EMISSAO >="+VALTOSQL(_dDataDE) +") AND LEFT(A1_CGC,8) BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"'"+ENTER
cQuery3 += " GROUP BY LEFT(A1_CGC,8),E1_CLIENTE,E1_EMISSAO , F2_VALFAT , E1_NUM "+ENTER
cQuery3 += " ORDER  BY LEFT(A1_CGC,8),E1_EMISSAO DESC, E1_NUM DESC "+ENTER


If !Empty(Select("TRB35"))
	dbSelectArea("TRB35")
	dbCloseArea()
Endif   

MemoWrit("C:\Cisp\Log\Query4.sql",cQuery3)
                                                
PutLog( Time()+" [QUERY][005][I]" )
PutLog( Time()+" [QUERY][005] "+ ENTER + cQuery3 )
dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery3), "TRB35", .T., .F. )
PutLog( Time()+" [QUERY][005][F]" )


dbSelectArea("TRB35")
dbGoTop()

_CNPJ  := TRB35->CNPJ
_nCont := 1
_nVal  := 0
_Data1 := CTOD(SUBSTR(TRB35->E1_EMISSAO,7,2)+'/'+SUBSTR(TRB35->E1_EMISSAO,5,2)+'/'+SUBSTR(TRB35->E1_EMISSAO,1,4))
_Valo1 := TRB35->E1_VALOR
_data2 := Ctod('  /  /  ')
_valo2 := 0
Flag := .T.
While ! TRB35->(Eof())
	While _CNPJ == TRB35->CNPJ .AND. ! TRB35->(Eof())
		If Flag
			If CTOD(SUBSTR(TRB35->E1_EMISSAO,7,2)+'/'+SUBSTR(TRB35->E1_EMISSAO,5,2)+'/'+SUBSTR(TRB35->E1_EMISSAO,1,4)) == _Data1
				TRB35->(DbSkip())
				If TRB35->(Eof())
					If SZY->(DbSeek(xFilial("SZY")+_CNPJ))
						RecLock("SZY",.F.)
						SZY->ZY_PCDUCM := _Data1 // Data da Ultima Compra
						SZY->ZY_PCVULC := _Valo1 // Valor da Ultima Compra
						SZY->ZY_PCDTPC := _Data2 // Data da Penúltima Compra
						SZY->ZY_PCVPCO := _Valo2 // Valor da Penúltima Compra
						If SZY->ZY_PCVPCO == 0
							SZY->ZY_PCDTPC := CtoD("  /  /  ")  // Data da Penúltima Compra
						Endif
						SZY->(MsUnlock())
						Flag := .F.
					Endif
				Else
					_Data2 := CTOD(SUBSTR(TRB35->E1_EMISSAO,7,2)+'/'+SUBSTR(TRB35->E1_EMISSAO,5,2)+'/'+SUBSTR(TRB35->E1_EMISSAO,1,4))
					_Valo2 := TRB35->E1_VALOR
					Loop
				Endif
			Else
				If SZY->(DbSeek(xFilial("SZY")+_CNPJ))
					RecLock("SZY",.F.)
					SZY->ZY_PCVLCR := VlrLiCre // Valor Limite de Credito
					SZY->ZY_PCDUCM := _Data1 // Data Ultima Compra
					SZY->ZY_PCVULC := _Valo1 // Valor da Ultima Compra
					SZY->ZY_PCDTPC := _Data2 // Data da Penúltima Compra
					SZY->ZY_PCVPCO := _Valo2 // Valor da Penúltima Compra
					If SZY->ZY_PCVPCO == 0
						SZY->ZY_PCDTPC := CtoD("  /  /  ") // Data da Penúltima Compra
					Endif
					SZY->(MsUnlock())
					Flag := .F.
				Endif
			Endif
		Endif
		TRB35->(DbSkip())
	End
	Flag := .T.
	_Data1 := CTOD(SUBSTR(TRB35->E1_EMISSAO,7,2)+'/'+SUBSTR(TRB35->E1_EMISSAO,5,2)+'/'+SUBSTR(TRB35->E1_EMISSAO,1,4))
	_Valo1 := TRB35->E1_VALOR
	_data2 := Ctod('  /  /  ')
	_valo2 := 0
	_CNPJ  := TRB35->CNPJ
	
End

Return

/*------------------------*/
User Function GrvrTxt()
/*------------------------*/

If !Pergunte("INFORCISP")
	Return
Else
	MsgRun("Gravando Arquivo TXT","Aguarde", {||GrvrTxt2()}, "Atualizar"   )
Endif
Return


/*------------------------*/
Static Function GrvrTxt2()
/*------------------------*/
_dDataDE2  := YEARSUB(dDatabase,1)

//_cNomeArq1 := 'C:\SIGA\PFJ_'+ALLTRIM(MV_PAR02)+'.TXT'
//_cNomeArq2 := 'PFJ_'+ALLTRIM(MV_PAR02)+'.TXT'
                           
If !Empty(MV_PAR01) .And. ExistDir(MV_PAR01)
	_cNomeArq1 := AllTrim(MV_PAR01)+"\PFJ_"+ALLTRIM(MV_PAR02)+'.TXT'
Else
	Makedir("C:\SIGA\")
	_cNomeArq1 := 'C:\SIGA\PFJ_'+ALLTRIM(MV_PAR02)+'.TXT'
EndIf
_cNomeArq2 := 'PFJ_'+ALLTRIM(MV_PAR02)+'.TXT'
_cNomeArq1 := StrTran(_cNomeArq1,"\\","\")

// Apaga o arquivo para um nova geração
If File( _cNomeArq1 )
	If FERASE(_cNomeArq1) == -1
		MsgStop('Falha na deleção do Arquivo')
	Endif
Endif     

//Cria um novo arquivo limpo.
/*
If !File( _cNomeArq1 )
	_AcLog := fCreate(_cNomeArq1, 0 )
	fClose( _AcLog )
Endif

_AcLog := fOpen(_cNomeArq1, 0 )
*/    
nHandle := FCreate( _cNomeArq1 )

dbSelectArea("SZY")
SZY->(DbGotop())

While ! SZY->(Eof())
	If AllTrim(SZY->ZY_PCCCLI) >= MV_PAR03 .and. AllTrim(SZY->ZY_PCCCLI) <= MV_PAR04
		If AllTrim(SZY->ZY_PCCCLI) <> "05393234"
			If !Empty(SZY->ZY_PCDCDD) // Data Cadastro Cliente
				If !Empty(SZY->ZY_PCDUCM) // Data da Ultima Compra
					If SZY->ZY_PCVULC > 0 // Valor Ultima Compra
						If !Empty(SZY->ZY_PCDMAC) // Data do Maior Acumulo
							If SZY->ZY_PCVMAC > 0 // Valor do Maior Acumulo
								cLinha := ''
								clinha := SZY->ZY_PCTIPO
								cLinha += STRZERO(SZY->ZY_PCCASS,4)
								cLinha += STRZERO(VAL(SZY->ZY_PCCCLI),20)
								cLinha += STRZERO(YEAR(DDATABASE),4)+STRZERO(MONTH(DDATABASE),2)+STRZERO(DAY(DDATABASE),2)
								cLinha += STRZERO(YEAR(SZY->ZY_PCDCDD),4)+STRZERO(MONTH(SZY->ZY_PCDCDD),2)+STRZERO(DAY(SZY->ZY_PCDCDD),2)
								cLinha += STRZERO(YEAR(SZY->ZY_PCDUCM),4)+STRZERO(MONTH(SZY->ZY_PCDUCM),2)+STRZERO(DAY(SZY->ZY_PCDUCM),2)
								cLinha += STRZERO(SZY->ZY_PCVULC*100,15)
								cLinha += STRZERO(YEAR(SZY->ZY_PCDMAC),4)+STRZERO(MONTH(SZY->ZY_PCDMAC),2)+STRZERO(DAY(SZY->ZY_PCDMAC),2)
								cLinha += STRZERO(SZY->ZY_PCVMAC*100,15)
								cLinha += STRZERO(SZY->ZY_PCVSAT*100,15)
								cLinha += STRZERO(INT(SZY->ZY_PCVLCR*100),15)
								cLinha += STRZERO(INT(SZY->ZY_PCQPAG*100),6)
								cLinha += STRZERO(INT(SZY->ZY_PCQDAP*100),6)
								cLinha += STRZERO(SZY->ZY_PCVDAV*100,15)
								cLinha += STRZERO(INT(SZY->ZY_PCMDAV*100),6)
								cLinha += STRZERO(INT(SZY->ZY_PCMPMV*100),6)
								cLinha += STRZERO(SZY->ZY_PCDATV*100,15)
								cLinha += STRZERO(INT(SZY->ZY_PCMPTV),4)
								cLinha += STRZERO(SZY->ZY_PCV15D*100,15)
								cLinha += STRZERO(INT(SZY->ZY_PCM15D),4)
								cLinha += STRZERO(SZY->ZY_PCV30D*100,15)
								cLinha += STRZERO(INT(SZY->ZY_PCM30D),4)
								cLinha += STRZERO(YEAR(SZY->ZY_PCDTPC),4)+STRZERO(MONTH(SZY->ZY_PCDTPC),2)+STRZERO(DAY(SZY->ZY_PCDTPC),2)
								cLinha += STRZERO(SZY->ZY_PCVPCO*100,15)
								cLinha += SZY->ZY_PCVSIT
								cLinha += "0"
								cLinha += "00"
								cLinha += "00000000"
								cLinha += "000000000000000"
								cLinha += "000000000000000"
								cLinha += "  "
								cLinha += chr(13)+chr(10)
								fWrite(nHandle,cLinha,Len(cLinha))
							Endif
						Endif
					Endif
				Endif
			Endif
		Endif
	Endif
	SZY->(DbSkip())
End

fClose( nHandle )

//CpyS2T( _cNomeArq1, "C:\SIGA", .T. )

ApMsgInfo("Arquivo Gravado com Sucesso !!!")

Return

/*----------------------*/
User Function ValInf()
/*----------------------*/

MsgRun("Analisando Inconsistências no Arquivo - Aguarde...","Processando...", {||ValInf2()}, "Atualizar"   )

Return

/*----------------------*/
Static Function ValInf2()
/*----------------------*/
_dDataDE2  := YEARSUB(dDatabase,1)
SZY->(DbGotop())

While ! SZY->(Eof())
	If ! EMPTY(SZY->ZY_PCDCDD)
		If ! EMPTY(SZY->ZY_PCDUCM) .and. SZY->ZY_PCDUCM >= _dDataDE2
			If ! EMPTY(SZY->ZY_PCVULC)
				If ! EMPTY(SZY->ZY_PCDMAC)
					If ! EMPTY(SZY->ZY_PCVMAC)
						If EMPTY(SZY->ZY_PCDMAC)
							If ! MsgYesNo("Dt Maior Acum. "+dtoc(SZY->ZY_PCDMAC)+chr(10)+chr(13)+"Cnpj "+SZY->ZY_PCCCLI,"Continuar ? ")
								Return
							Else
								If MsgYesNo("Refazer cálculos ?")
									U_Acerta()
								Endif
							Endif
						Endif
						
						If SZY->ZY_PCDMAC < _dDataDE2  .AND. SZY->ZY_PCDUCM > _dDataDE2
							If ! MsgYesNo("Dt Maior Acum. < 12 meses Ultima compra > "+dtoc(_dDataDE2)+chr(10)+chr(13)+"Cnpj "+SZY->ZY_PCCCLI,"Continuar ? ")
								Return
							Else
								If MsgYesNo("Refazer cálculos ?")
									U_Acerta()
								Endif
							Endif
						Endif
						If ! EMPTY(SZY->ZY_PCVSAT)
							IF SZY->ZY_PCDTPC == SZY->ZY_PCDUCM
								If ! MsgYesNo("Dt Penul Compra = Dt Ult Compra"+chr(10)+chr(13)+"Cnpj "+SZY->ZY_PCCCLI,"Continuar ? ")
									Return
								Else
									If MsgYesNo("Refazer cálculos ?")
										U_Acerta()
									Endif
								Endif
							Endif
							
							If SZY->ZY_PCDMAC > SZY->ZY_PCDUCM
								If ! MsgYesNo("Cod 10 - Dt Maior Acum. > Dt Ult Compra"+chr(10)+chr(13)+"Cnpj "+SZY->ZY_PCCCLI,"Continuar ? ")
									Return
								Endif
							Endif
							
							If SZY->ZY_PCVMAC < SZY->ZY_PCVSAT
								If ! MsgYesNo("Cod 11 - Vlr Maior Acum. < Deb Atual Total"+chr(10)+chr(13)+"Cnpj "+SZY->ZY_PCCCLI,"Continuar ? ")
									Return
								Else
									If MsgYesNo("Refazer cálculos ?")
										U_Acerta()
									Endif
								Endif
							Endif
							
							If SZY->ZY_PCVMAC  < SZY->ZY_PCVULC
								If ! MsgYesNo("Cod 12 - Vlr Maior Acum. < Vlr Ult Compra"+chr(10)+chr(13)+"Cnpj "+SZY->ZY_PCCCLI,"Continuar ? ")
									Return
								Else
									If MsgYesNo("Refazer cálculos ?")
										U_Acerta()
									Endif
								Endif
							Endif
							
							If SZY->ZY_PCDUCM < SZY->ZY_PCDTPC
								If ! MsgYesNo("Cod 18 - Dt Ult Compra <= Dt Penult Compra"+chr(10)+chr(13)+"Cnpj "+SZY->ZY_PCCCLI,"Continuar ? ")
									Return
								Endif
							Endif
							
							If SZY->ZY_PCDATV > SZY->ZY_PCVSAT
								If ! MsgYesNo("Cod 21 - Vlr Deb Vencido a + 5 dias > Deb Atual "+chr(10)+chr(13)+"Cnpj "+SZY->ZY_PCCCLI,"Continuar ? ")
									Return
								Endif
							Endif
							
							If SZY->ZY_PCVSAT < SZY->ZY_PCVDAV
								If ! MsgYesNo("Cod 25 - Deb Atual Total < Deb Atual a Vencer"+chr(10)+chr(13)+"Cnpj "+SZY->ZY_PCCCLI,"Continuar ? ")
									Return
								Endif
							Endif
							
							If SZY->ZY_PCVSAT < SZY->ZY_PCV15D
								If ! MsgYesNo("Cod 26 - Deb Atual Total < Deb Atual Venc. + 15 dias"+chr(10)+chr(13)+"Cnpj "+SZY->ZY_PCCCLI,"Continuar ? ")
									Return
								Endif
							Endif
							
							If SZY->ZY_PCVSAT < SZY->ZY_PCV30D
								If ! MsgYesNo("Cod 27 - Deb Atual Total < Deb Atual Venc. + 30 dias"+chr(10)+chr(13)+"Cnpj "+SZY->ZY_PCCCLI,"Continuar ? ")
									Return
								Endif
							Endif
							
							If SZY->ZY_PCQPAG > 0 .and. SZY->ZY_PCQDAP = 0
								If ! MsgYesNo("Cod 28 - Med Arit Dias Atraso SEM Med Pond Atr. Pagto"+chr(10)+chr(13)+"Cnpj "+SZY->ZY_PCCCLI,"Continuar ? ")
									Return
								Endif
							Endif
							
							If SZY->ZY_PCQDAP > 0 .and. SZY->ZY_PCQPAG = 0
								If ! MsgYesNo("Cod 29 - Med Pond Atr. Pagto SEM Med Arit Dias Atraso "+chr(10)+chr(13)+"Cnpj "+SZY->ZY_PCCCLI,"Continuar ? ")
									Return
								Endif
							Endif
							
							If SZY->ZY_PCVDAV >  SZY->ZY_PCVSAT
								If ! MsgYesNo("Cod 30 - Debto Atual a Venc > Debito Atual Total "+chr(10)+chr(13)+"Cnpj "+SZY->ZY_PCCCLI,"Continuar ? ")
									Return
								Endif
							Endif
							
							
							If SZY->ZY_PCMDAV > 0 .and. SZY->ZY_PCMPMV > 0 .and. SZY->ZY_PCVDAV = 0
								If ! MsgYesNo("Cod 31 - Med.Pon.Tit Venc E Prazo Med SEM Deb.At.Vencer "+chr(10)+chr(13)+"Cnpj "+SZY->ZY_PCCCLI,"Continuar ? ")
									Return
								Endif
							Endif
							
							If SZY->ZY_PCVDAV > 0 .and. SZY->ZY_PCMPMV > 0 .and. SZY->ZY_PCMDAV = 0
								If ! MsgYesNo("Cod 32 - Deb.At.Vencer E Prazo Med VD SEM Med.Pon.Tit Venc."+chr(10)+chr(13)+"Cnpj "+SZY->ZY_PCCCLI,"Continuar ? ")
									Return
								Endif
							Endif
							
							If SZY->ZY_PCVDAV > 0 .and. SZY->ZY_PCMPMV > 0 .and. SZY->ZY_PCMDAV = 0
								If ! MsgYesNo("Cod 33 - Deb.At.Vencer E Prazo Med VD SEM Med.Pon.Tit Venc."+chr(10)+chr(13)+"Cnpj "+SZY->ZY_PCCCLI,"Continuar ? ")
									Return
								Endif
							Endif
							
							If SZY->ZY_PCV15D >  SZY->ZY_PCDATV
								If ! MsgYesNo("Cod 34 - Deb.At.Vencido + 15 > Prazo Med VD SEM Med.Pon.Tit Venc."+chr(10)+chr(13)+"Cnpj "+SZY->ZY_PCCCLI,"Continuar ? ")
									Return
								Endif
							Endif
							
							If SZY->ZY_PCM15D > 0 .and.  SZY->ZY_PCV15D = 0
								If ! MsgYesNo("Cod 35 - Med Pond Tit Vencido + 15 SEM Deb Atual Venc + 15"+chr(10)+chr(13)+"Cnpj "+SZY->ZY_PCCCLI,"Continuar ? ")
									Return
								Endif
							Endif
							
							If SZY->ZY_PCM15D < 15 .and. SZY->ZY_PCM15D > 0
								If ! MsgYesNo("Cod 36 - Med Pond Tit Vencido + 15 < 15 dias"+chr(10)+chr(13)+"Cnpj "+SZY->ZY_PCCCLI,"Continuar ? ")
									Return
								Endif
							Endif
							
							If SZY->ZY_PCV15D > 0 .and. SZY->ZY_PCM15D = 0
								If ! MsgYesNo("Cod 37 - Deb Atual Vencido + 15 SEM Med Pond Vencido + 15 dias"+chr(10)+chr(13)+"Cnpj "+SZY->ZY_PCCCLI,"Continuar ? ")
									Return
								Endif
							Endif
							
							If SZY->ZY_PCV30D >  SZY->ZY_PCV15D
								If ! MsgYesNo("Cod 38 - Deb Atual Vencido + 30 > Debito Vencido + 15 dias"+chr(10)+chr(13)+"Cnpj "+SZY->ZY_PCCCLI,"Continuar ? ")
									Return
								Endif
							Endif
							
							If SZY->ZY_PCM30D > 0 .AND. SZY->ZY_PCV30D = 0
								If ! MsgYesNo("Cod 39 - Med Pond Vencido + 30 SEM Debito Atual Vencido + 30 "+chr(10)+chr(13)+"Cnpj "+SZY->ZY_PCCCLI,"Continuar ? ")
									Return
								Endif
							Endif
							
							If SZY->ZY_PCM30D < 30 .and. SZY->ZY_PCM30D > 0
								If ! MsgYesNo("Cod 40 - Med Pond Vencido + 30 < 30 dias "+chr(10)+chr(13)+"Cnpj "+SZY->ZY_PCCCLI,"Continuar ? ")
									Return
								Endif
							Endif
							
							If SZY->ZY_PCV30D > 0 .and. SZY->ZY_PCM30D = 0
								If ! MsgYesNo("Cod 41 - Med Pond Vencido + 30 SEM Med Pond Vencido + 30 dias "+chr(10)+chr(13)+"Cnpj "+SZY->ZY_PCCCLI,"Continuar ? ")
									Return
								Endif
							Endif
							
							If SZY->ZY_PCDTPC > SZY->ZY_PCDUCM
								If ! MsgYesNo("Cod 42 - Data Penult Compra > Data Ultima Compra "+chr(10)+chr(13)+"Cnpj "+SZY->ZY_PCCCLI,"Continuar ? ")
									Return
								Endif
							Endif
							
							If SZY->ZY_PCVPCO > 0 .and. Empty(SZY->ZY_PCDUCM )
								If ! MsgYesNo("Cod 44 - Vlr Penult Compra SEM Data Penultima Compra "+chr(10)+chr(13)+"Cnpj "+SZY->ZY_PCCCLI,"Continuar ? ")
									Return
								Endif
							Endif
							
							
							If SZY->ZY_PCDUCM < _dDATADE .AND. SZY->ZY_PCVSAT = 0
								If ! MsgYesNo("Cod 46 - Data Última Cp > 12 Meses SEM Debito Atual Total "+chr(10)+chr(13)+"Cnpj "+SZY->ZY_PCCCLI,"Continuar ? ")
									Return
								Endif
							Endif
							
							If SZY->ZY_PCDMAC < _dDATADE .AND. SZY->ZY_PCDUCM > _dDATADE
								If ! MsgYesNo("Cod 47 - Data Maior Acumulo > 12 Meses "+chr(10)+chr(13)+"Cnpj "+SZY->ZY_PCCCLI,"Continuar ? ")
									Return
								Else
									If MsgYesNo("Refazer cálculos ?")
										U_Acerta()
									Endif
								Endif
							Endif
							
							If Empty(SZY->ZY_PCDTPC) .and. ! Empty( SZY->ZY_PCDMAC ) .and. ! empty( SZY->ZY_PCDUCM ) .and. SZY->ZY_PCDMAC <> SZY->ZY_PCDUCM
								If ! MsgYesNo("Cod 49 - Sem Dt Penult Compra => Dt Maior Ac <> Dt Ult Compra"+chr(10)+chr(13)+"Cnpj "+SZY->ZY_PCCCLI,"Continuar ? ")
									Return
								Endif
							Endif
							
							If SZY->ZY_PCVDAV + SZY->ZY_PCDATV > SZY->ZY_PCVSAT
								If ! MsgYesNo("Cod 51 - Deb a Vencer + Deb 5 dias > Deb Atual Total"+chr(10)+chr(13)+"Cnpj "+SZY->ZY_PCCCLI,"Continuar ? ")
									Return
								Endif
							Endif
							
							If ( SZY->ZY_PCVMAC == SZY->ZY_PCVSAT ) .and. ( SZY->ZY_PCDMAC <> SZY->ZY_PCDUCM )
								If ! MsgYesNo("Cod 56 - Vlr Maior Acum = Debito Atual E Dat Maior Acum <> Dat Ult Cp"+chr(10)+chr(13)+"Cnpj "+SZY->ZY_PCCCLI,"Continuar ? ")
									Return
								Endif
							Endif
							
							If  SZY->ZY_PCVPCO > 0 .and. Empty( SZY->ZY_PCDTPC)
								If ! MsgYesNo("Cod 62 - Dt Penult Cp SEM Vlr Penult Cp"+chr(10)+chr(13)+"Cnpj "+SZY->ZY_PCCCLI,"Continuar ? ")
									Return
								Endif
							Endif
							
						Endif
					Endif
				Endif
			Endif
		Endif
	Endif
	SZY->(DbSkip())
End
MsgAlert("Validação OK","Atenção")
SZY->(DbGotop())
Return


/*------------------*/
User Function Acerta()
/*------------------*/
// Query de razão de clientes


_dDATADE   := CTOD("01/01/2000")
_dDataDE2  := YEARSUB(dDatabase,1)

cQuery1 := " SELECT E1_NUM,E1_PARCELA,E1_EMISSAO,LEFT(A1_CGC,8) as CNPJ, E1_VALOR ,DATACC = E1_EMISSAO, 0 AS SALDO,E1_VENCREA, " + ENTER
cQuery1 += " CASE WHEN E1_VENCREA >= "+VALTOSQL(_dDataDE)+" THEN ' ' ELSE E1_BAIXA END AS E1_BAIXA , "+ENTER
cQuery1 += " 0 AS DIATRA ,0 AS VLRCALC, "+ENTER
cQuery1 += "  '' AS DATAM, 0 AS VLRM, VLRDAV = (CASE WHEN E1_VENCREA > "+VALTOSQL(dDataBase)+" THEN E1_VALOR ELSE 0 END ), "+ENTER
cQuery1 += " CASE WHEN E1_VENCREA > "+VALTOSQL(dDataBase)+" THEN DATEDIFF(DAY,E1_EMISSAO,E1_VENCREA) ELSE 0 END AS DIASAV, "+ENTER
cQuery1 += " CASE WHEN E1_VENCREA > "+VALTOSQL(dDataBase)+" THEN DATEDIFF(DAY,E1_EMISSAO,E1_VENCREA) * E1_VALOR ELSE 0 END AS VLRAVC, A1_LC , ORDEM = 1"+ENTER
cQuery1 += " FROM "+RetSqlName("SE1")+" E1 "+ENTER
cQuery1 += " INNER JOIN "+RetSqlName("SA1")+" A1 ON E1.E1_CLIENTE = A1.A1_COD AND E1.E1_LOJA = A1.A1_LOJA "+ENTER
cQuery1 += " WHERE ( E1_VENCREA >= "+VALTOSQL(_dDataDE) +" AND ( E1_EMISSAO <= "+VALTOSQL(dDataBase)+" AND E1_EMISSAO >="+VALTOSQL(_dDataDE) +") AND ( E1_BAIXA >= "+VALTOSQL(_dDataDE) +" OR E1_BAIXA = ' ') ) AND  E1_TIPO = 'NF' AND A1.D_E_L_E_T_ = ' ' AND E1.D_E_L_E_T_ = ' ' "+ENTER
cQuery1 += " AND LEFT(A1_CGC,8) BETWEEN  '"+MV_PAR03+"' AND '"+MV_PAR04 +"'"+ENTER
cQuery1 += " UNION ALL "+ENTER
cQuery1 += " SELECT E1_NUM,E1_PARCELA,E1_EMISSAO,LEFT(A1_CGC,8) as CNPJ, "+ENTER
cQuery1 += " E1_VALOR = (CASE WHEN  E1_BAIXA <> ' ' THEN ((E1_VALOR-E1_SALDO)*-1) END), "+ENTER
cQuery1 += " DATACC   = (CASE WHEN E1_BAIXA <> ' ' THEN E1_BAIXA END ), 0 AS SALDO,E1_VENCREA,E1_BAIXA, "+ENTER
cQuery1 += " CASE WHEN DATEDIFF(DAY,E1_VENCREA,E1_BAIXA) >= 0  THEN DATEDIFF(DAY,E1_VENCREA,E1_BAIXA) "+ENTER
cQuery1 += "      WHEN E1_BAIXA <> ' ' AND E1_BAIXA > E1_VENCREA THEN DATEDIFF(DAY,E1_VENCREA,"+VALTOSQL(dDataBase)+") "+ENTER
cQuery1 += "      WHEN E1_BAIXA = ' ' AND E1_VENCREA < "+VALTOSQL(dDataBase)+" THEN  DATEDIFF(DAY,E1_VENCREA,"+VALTOSQL(dDataBase)+") "+ENTER
cQuery1 += "      ELSE 0 END AS DIATRA ,"+ENTER
cQuery1 += "  CASE WHEN DATEDIFF(DAY,E1_VENCREA,E1_BAIXA) >= 0  THEN (E1_VALOR*DATEDIFF(DAY,E1_VENCREA,E1_BAIXA)) "+ENTER
cQuery1 += "       WHEN E1_BAIXA <> ' ' AND E1_BAIXA > E1_VENCREA THEN (E1_VALOR*DATEDIFF(DAY,E1_VENCREA,"+VALTOSQL(dDataBase)+")) "+ENTER
cQuery1 += "       WHEN E1_BAIXA = ' '  AND E1_VENCREA < "+VALTOSQL(dDataBase)+" THEN (E1_VALOR*DATEDIFF(DAY,E1_VENCREA,"+VALTOSQL(dDataBase)+"))"+ENTER
cQuery1 += "       ELSE 0 END AS VLRCALC,"+ENTER
cQuery1 += " '' AS DATAM, 0 AS VLRM,VLRDAV = 0 , DIASAV = 0, VLRAVC = 0 , A1_LC, ORDEM = 2"+ENTER
cQuery1 += " FROM "+RetSqlName("SE1")+" E1 "+ENTER
cQuery1 += " INNER JOIN "+RetSqlName("SA1")+" A1 ON E1.E1_CLIENTE = A1.A1_COD AND E1.E1_LOJA = A1.A1_LOJA "+ENTER
cQuery1 += " WHERE ( E1.E1_EMISSAO <= "+VALTOSQL(dDataBase)+" AND E1.E1_EMISSAO >="+VALTOSQL(_dDataDE) +") AND E1.E1_TIPO = 'NF' AND A1.D_E_L_E_T_ = ' ' AND E1.D_E_L_E_T_ = ' ' AND E1.E1_VENCREA < "+VALTOSQL(dDataBase)+ENTER
cQuery1 += " AND LEFT(A1_CGC,8) BETWEEN  '"+MV_PAR03+"' AND '"+MV_PAR04 +"' "+ENTER
cQuery1 += " ORDER BY CNPJ,DATACC,ORDEM,E1_VALOR,E1_NUM,E1_PARCELA "+ENTER


If !Empty(Select("TRB33"))
	dbSelectArea("TRB33")
	dbCloseArea()
Endif

MemoWrit("C:\SIGA\Query1.sql",cQuery1)

dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery1), "TRB33", .T., .F. )
dbSelectArea("TRB33")
dbGoTop()

_CNPJ := TRB33->CNPJ
DATMACU := ' '
VALRMACU := 0
NDATAM   := TRB33->DATACC

MSALDO   := 0
DATAMC   := ' '

DATAMACU2 := ' '
VALRMACU2 := 0
MSALDO2  := 0
DATAMC2  := ' '

DATAPC   := ' '
VLRPUC   := 0
DATAUC   := ' '
VLRUC    := 0
_Z       := 0
_X       := 0
_Y       := 0
_NT      := 0
VLDAVC   := 0
_Z1      := 0
_X1      := 0
_Y1      := 0
_NT1     := 0
_VLRVC   := 0
xChave   := TRB33->E1_EMISSAO+TRB33->E1_BAIXA

VLRMACU := 0
VLRmAC  := 0
nReg := TRB33->(Recno())
While ! TRB33->(Eof())
	While TRB33->CNPJ == _CNPJ  .and. ! TRB33->(Eof())
		VLRMACU += TRB33->E1_VALOR
		If VLRMACU >= VLRmAC .and. CTOD(SUBSTR(TRB33->DATACC,7,2)+'/'+SUBSTR(TRB33->DATACC,5,2)+'/'+SUBSTR(TRB33->DATACC,1,4)) >=_dDATADE2
			VLRmAC := VLRMACU
			DATMACU := TRB33->DATACC
		Endif
		_CNPJ1 := TRB33->CNPJ
		TRB33->(DbSkip())
		_CNPJ := TRB33->CNPJ
	Enddo
	If SZY->(DbSeek(xFilial("SZY")+_CNPJ1))
		RecLock("SZY",.F.)
		// Data e Valor do Maior Acumulo
		SZY->ZY_PCVMAC := VLRmAC // Valor do Maior Acumulo
		SZY->ZY_PCDMAC := CTOD(SUBSTR(DATMACU,7,2)+'/'+SUBSTR(DATMACU,5,2)+'/'+SUBSTR(DATMACU,1,4))
		SZY->ZY_PCDDAT := DDATABASE // Data da Informação
		MsUnlock()
	Endif
Enddo


Return


/*------------------*/
USER Function sinteg()
/*-----------------*/

Private _cNomeArq := space(70)
Private nRadMenu1 := 3
Static oDlg

@ 000,000 TO 230,470 DIALOG _oDlg TITLE "Leitura do arquivo TXT Sintegra/R.Federal/Suframa"
@ 000,000 TO 010,230
@ 001,001 Say "Esta rotina fará a Verificação dos Cadastros pelo arq. TXT pré-configurado CISP."

@ 002,001 Say "Informe Abaixo :"
@ 003,001 SAY "Arquivo"
@ 003,005 GET _cNomeArq Picture '@!' Size 160,9 When .T.
@ 095,050 BMPBUTTON TYPE 5 ACTION F_ARQSIN()
@ 095,110 BMPBUTTON TYPE 1 ACTION Processa({|lEnd| VERI_SIN()}, 'Processando...')
@ 095,170 BMPBUTTON TYPE 2 ACTION Close(_oDlg)
ACTIVATE DIALOG _oDlg CENTERED

Return

/*---------------------*/
Static Function F_ARQSIN()
/*--------------------*/

_cNomeArq := cGetFile("*.txt|*.txt",OemToAnsi("Selecione o Arquivo..."),0,,.T.)
_oDlg:Refresh()
Return

/*------------------------*/
Static Function VERI_SIN()
/*------------------------*/
Local _cBuffer := ''
Local _nLinh
Local _nItem
Local cQuery
Local _cExerc
Local cPath
Local aDiret
Local cArq := {}
Local cMsg := ''
Local nHandle   := 0
Local cArqPesq 	:= "C:\Siga\SRS"+DTOS(DATE())+SUBSTR(TIME(),1,2)+SUBSTR(TIME(),4,2)+SUBSTR(TIME(),7,2)+".HTML"
nHandle := FCREATE(cArqPesq, 0)

_cMsg := ' '

_cMsg :='<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">'
_cMsg +='<html xmlns="http://www.w3.org/1999/xhtml">'
_cMsg +='<head>'
_cMsg +='<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />'
_cMsg +='<title>Alispec - Verificacao de Cadastros Sintegra/Receita/Sugrama CISP </title>'
_cMsg +='<style type="text/css">'
_cMsg +='<!--'
_cMsg +='.titulo {'
_cMsg +='	font-family: Verdana, Geneva, sans-serif;'
_cMsg +='	text-align: left;'
_cMsg +='	font-weight: bold;'
_cMsg +='	font-size: 16px;'
_cMsg +='}'
_cMsg +='.TitTab {'
_cMsg +='	font-weight: bold;'
_cMsg +='	font-family: Verdana, Geneva, sans-serif;'
_cMsg +='	text-align: left;'
_cMsg +='}'
_cMsg +='.TitTab td {'
_cMsg +='	font-size: 12px;'
_cMsg +='}'
_cMsg +='.itens {'
_cMsg +='	font-family: Verdana, Geneva, sans-serif;'
_cMsg +='	font-size: 10px;'
_cMsg +='}'
_cMsg +='-->'
_cMsg +='</style>'
_cMsg +='</head>'
_cMsg +='<body>'
_cMsg +='<img src="http://www.alispec.com.br/logo_assina.jpg" /><p class="titulo"> Verificacao de Cadastros Sintegra/Receita/Suframa - CISP </p>'
_cMsg +='<table  border="1">'
_cMsg +='<tr class="TitTab">'
_cMsg +='<td bgcolor="#99CCFF">Ident.</td>'
_cMsg +='<td bgcolor="#99CCFF">Situacao</td>'
_cMsg +='<td bgcolor="#99CCFF">Data Situacao</td>'
_cMsg +='<td bgcolor="#99CCFF">Efetivou Bloq. ?</td>'
_cMsg +='<td bgcolor="#99CCFF">CNPJ</td>'
_cMsg +='<td bgcolor="#99CCFF">IE</td>'
_cMsg +='<td bgcolor="#99CCFF">Razao Social</td>'
_cMsg +='<td bgcolor="#99CCFF">Endereco</td>'
_cMsg +='<td bgcolor="#99CCFF">Numero</td>'
_cMsg +='<td bgcolor="#99CCFF">Complemento</td>'
_cMsg +='<td bgcolor="#99CCFF">Bairro</td>'
_cMsg +='<td bgcolor="#99CCFF">Municipio</td>'
_cMsg +='<td bgcolor="#99CCFF">UF</td>'
_cMsg +='<td bgcolor="#99CCFF">CEP</td>'
_cMsg +='<td bgcolor="#99CCFF">DDD</td>'
_cMsg +='<td bgcolor="#99CCFF">Telefone</td>'
_cMsg +='<td bgcolor="#99CCFF">Email</td>'
_cMsg +='<td bgcolor="#99CCFF">Ativ. Econom</td>'
_cMsg +='<td bgcolor="#99CCFF">Reg. Apur.</td>'
_cMsg +='<td bgcolor="#99CCFF">Data Cisp</td>'
_cMsg +='<td bgcolor="#99CCFF">Data Consulta</td>'
_cMsg +='</tr>'
(FWRITE(nHandle, _cMsg) )
_cMsg := ' '

close(_oDlg)

_nLinh := '000000'
//Abre o arquivo
FT_FUSE(_cNomeArq)

//Posiciona no inicio
FT_FGOTOP()

ProcRegua(FT_FLASTREC())

_aArea := GetArea()
SA1->(DBSetOrder(3))

While !FT_FEOF()
	_nLinh := soma1(_nLinh)
	IncProc(_cNomeArq + " - Linha "+_nLinh)
	_cBuffer := FT_FREADLN()
	
	_SRF_IDE := Substr(_cBuffer,1,1)
	_SRF_ASC := Substr(_cBuffer,2,3)
	_SRF_CLI := Substr(_cBuffer,5,14)
	_SRF_INS := Substr(_cBuffer,19,20)
	_SRF_RZS := alltrim(Substr(_cBuffer,39,150))
	_SRF_LGD := alltrim(Substr(_cBuffer,189,100))
	_SRF_NMR := alltrim(Substr(_cBuffer,289,10))
	_SRF_CPT := alltrim(Substr(_cBuffer,299,70))
	_SRF_BRR := ALLTRIM(Substr(_cBuffer,369,50))
	_SRF_MNC := ALLTRIM(Substr(_cBuffer,419,80))
	_SRF_UF  := Substr(_cBuffer,499,2)
	_SRF_CEP := Substr(_cBuffer,501,8)
	_SRF_DDD := Substr(_cBuffer,509,6)
	_SRF_TEL := ALLTRIM(Substr(_cBuffer,515,40))
	_SRF_EML := ALLTRIM(Substr(_cBuffer,555,50))
	_SRF_ATV := Substr(_cBuffer,605,10)
	_SRF_ARG := ALLTRIM(Substr(_cBuffer,615,100))
	_SRF_SCL := ALLTRIM(Substr(_cBuffer,715,50))
	_SRF_GER := Substr(_cBuffer,765,8)
	_SRF_DTS := Substr(_cBuffer,773,8)
	_SRF_DTC := Substr(_cBuffer,781,8)
	_SRF_NCT := Substr(_cBuffer,789,10)
	_SRF_NMF := Substr(_cBuffer,799,70)
	_SRF_CNJ := Substr(_cBuffer,869,6)
	_SRF_DNJ := Substr(_cBuffer,875,70)
	_SRF_SSP := Substr(_cBuffer,945,50)
	_SRF_DTP := Substr(_cBuffer,995,8)
	_SRF_DTA := Substr(_cBuffer,1003,8)
	_SRF_IRE := Substr(_cBuffer,1011,8)
	_SRF_MI  := Substr(_cBuffer,1019,50)
	_SRF_BRE := Substr(_cBuffer,1069,8)
	_SRF_MB  := Substr(_cBuffer,1077,50)
	_SRF_PE  := Substr(_cBuffer,1127,40)
	_SRF_OBS := Substr(_cBuffer,1167,250)
	_SRF_ICMS:= Substr(_cBuffer,1417,5)
	_SRF_FAX := Substr(_cBuffer,1422,40)
	_SRF_ISF := Substr(_cBuffer,1462,10)
	_SRF_DTV := Substr(_cBuffer,1472,8)
	_SRF_TI  := Substr(_cBuffer,1480,20)
	_Bloq  := .f.
	_Color := .f.
	
	If ! Empty(_SRF_CLI)
		If SA1->(DbSeek(xFilial("SA1")+_SRF_CLI))
			_cMsg := " "
			_cSit := IIf(_SRF_IDE == '1','1-Sintegra',Iif(_SRF_IDE == '2','2-Rec.Federal','3-Suframa'))
			_cMsg +='  <tr class="itens">'
			_cMsg +='    <td nowrap bgcolor="#FFFFFF">'+_cSit+'</td>'
			If ! Upper(Alltrim(_SRF_SCL)) == 'ATIVO' .and.  ! Upper(Alltrim(_SRF_SCL)) == 'ATIVA' .and. ! Upper(Alltrim(_SRF_SCL)) == 'HABILITADO' .and. ! Upper(Alltrim(_SRF_SCL)) == 'HABILITADA'
				_cMsg +='    <td nowrap bgcolor="#FFA500">'+alltrim(_SRF_SCL)+'</td>'
				_cMsg +='    <td nowrap bgcolor="#FFFFFF">'+substr(_SRF_DTS,7,2)+'/'+substr(_SRF_DTS,5,2)+'/'+substr(_SRF_DTS,1,4)+'</td>'
				While ALLTRIM(SA1->A1_CGC) == ALLTRIM(_SRF_CLI)
					_IE := ALLTRIM(SA1->A1_INSCR)
					_IE := strTran(_IE,'.',"",1,Len(_IE))
					_IE := strTran(_IE,'-',"",1,Len(_IE))
					_IE := strTran(_IE,'/',"",1,Len(_IE))
					If Alltrim(_SRF_INS) == alltrim(_IE)
						If SA1->A1_MSBLQL == '2'
							If APMSGYESNO('Código : ' + SA1->A1_COD+' - '+ALLTRIM(SA1->A1_NOME)+chr(13)+chr(10)+chr(13)+chr(10)+;
								'Informação CISP : '+chr(13)+chr(10)+;
								'Situação :   '+ _cSit+'   -   '+alltrim(_SRF_SCL)+chr(13)+chr(10)+;
								'CNPJ : '+_SRF_CLI+' I.E. : '+Alltrim(_SRF_INS)+chr(13)+chr(10)+chr(13)+chr(10)+;
								'Informação Cadastro  : '+chr(13)+chr(10)+;
								'CNPJ : '+SA1->A1_CGC+' I.E. : '+_IE+CHR(13)+CHR(10)+' Situação do Cliente :  '+IIf(SA1->A1_MSBLQL == '2','ATIVO','INATIVO'),'Efetuar bloqueio ?')
								If RecLock("SA1",.F.)
									SA1->A1_MSBLQL := '1'
									MsUnlock()
									MsgAlert('Bloqueio ok ','Atenção')
									_bloq := .t.
								Else
									_bloq := .f.
									MsgAlert('Não foi possível efetuar o Bloqueio ','Atenção')
								Endif
							Endif
							_Color := .t.
						Endif
					Endif
					SA1->(DbSkip())
				Enddo
			Else
				_cMsg +='    <td nowrap bgcolor="#C1FFC1">'+alltrim(_SRF_SCL)+'</td>'
				_cMsg +='    <td nowrap bgcolor="#FFFFFF">'+substr(_SRF_DTS,7,2)+'/'+substr(_SRF_DTS,5,2)+'/'+substr(_SRF_DTS,1,4)+'</td>'
			Endif
			If _Color
				If _Bloq
					_cMsg +='    <td nowrap bgcolor="#00FF00">'+Iif(_Bloq,'Sim','Nao')+'</td>'
				Else
					_cMsg +='    <td nowrap bgcolor="#FF4040">'+Iif(_Bloq,'Sim','Nao')+'</td>'
				Endif
				_Color := .f.
			Else
				_cMsg +='    <td nowrap bgcolor="#FFFFFF">'+Iif(_Bloq,'Sim','Nao')+'</td>'
			Endif
			_cMsg +='    <td nowrap bgcolor="#FFFFFF">'+_SRF_CLI+'</td>'
			_cMsg +='    <td nowrap bgcolor="#FFFFFF">'+_SRF_INS+'</td>'
			_cMsg +='    <td nowrap bgcolor="#FFFFFF">'+alltrim(_SRF_RZS)+'</td>'
			_cMsg +='    <td nowrap bgcolor="#FFFFFF">'+alltrim(_SRF_LGD)+'</td>'
			_cMsg +='    <td nowrap bgcolor="#FFFFFF">'+alltrim(_SRF_NMR)+'</td>'
			_cMsg +='    <td nowrap bgcolor="#FFFFFF">'+alltrim(_SRF_CPT)+'</td>'
			_cMsg +='    <td nowrap bgcolor="#FFFFFF">'+alltrim(_SRF_BRR)+'</td>'
			_cMsg +='    <td nowrap bgcolor="#FFFFFF">'+alltrim(_SRF_MNC)+'</td>'
			_cMsg +='    <td nowrap bgcolor="#FFFFFF">'+alltrim(_SRF_UF)+'</td>'
			_cMsg +='    <td nowrap bgcolor="#FFFFFF">'+alltrim(_SRF_CEP)+'</td>'
			_cMsg +='    <td nowrap bgcolor="#FFFFFF">'+alltrim(_SRF_DDD)+'</td>'
			_cMsg +='    <td nowrap bgcolor="#FFFFFF">'+alltrim(_SRF_TEL)+'</td>'
			_cMsg +='    <td nowrap bgcolor="#FFFFFF">'+alltrim(_SRF_EML)+'</td>'
			_cMsg +='    <td nowrap bgcolor="#FFFFFF">'+alltrim(_SRF_ATV)+'</td>'
			_cMsg +='    <td nowrap bgcolor="#FFFFFF">'+alltrim(_SRF_ARG)+'</td>'
			_cMsg +='    <td nowrap bgcolor="#FFFFFF">'+substr(_SRF_GER,7,2)+'/'+substr(_SRF_GER,5,2)+'/'+substr(_SRF_GER,1,4)+'</td>'
			_cMsg +='    <td nowrap bgcolor="#FFFFFF">'+substr(_SRF_DTC,7,2)+'/'+substr(_SRF_DTC,5,2)+'/'+substr(_SRF_DTC,1,4)+'</td>'
			_cMsg +='  </tr>'
			(FWRITE(nHandle, _cMsg) )
			_cMsg := " "
			RestArea(_aArea)
		Endif
	Endif
	FT_FSKIP()
Enddo
RestArea(_aArea)
FT_FUSE() // Fecha o arquivo texto.
ApMsgInfo("Rotina excutada com Sucesso !!!")

fCLose(nHandle)

shellExecute( "Open", "C:\Program Files\Internet Explorer\iexplore.exe", cArqPesq, "C:\", 1 )

RETURN()

/*--------------------------*/
Static Function VerCred(CNPJ)
/*--------------------------*/
credval := 0
cQuerz2 := " SELECT SUM(SA1.A1_LC) AS A1_LC "+ENTER
cQuerz2 += " FROM   "+RetSqlName("SA1")+" SA1" +ENTER
cQuerz2 += " WHERE SUBSTRING(SA1.A1_CGC,1,8) = '"+CNPJ+"' AND ( SA1.A1_MSBLQL = '2'  OR SA1.A1_MSBLQL = ' ' ) AND SA1.D_E_L_E_T_ = ' '"+ENTER
cQuerz2 += " GROUP BY SUBSTRING(SA1.A1_CGC,1,8)"+ENTER
cQuerz2 += " ORDER BY SUBSTRING(SA1.A1_CGC,1,8)"+ENTER

If !Empty(Select("TRBCR"))
	dbSelectArea("TRBCR")
	dbCloseArea()
Endif

dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuerz2), "TRBCR", .T., .F. )
dbSelectArea("TRBCR")
dbGoTop()

credval := TRBCR->A1_LC

Return(credval)


//-------------------------------------------------------------------------------------
/*/{Protheus.doc} PutLog
Geracao de log

@type 		function
@author 	Roberto Souza
@since 		12/01/2017
@version 	P11 
 
@return nil
/*/    
//-------------------------------------------------------------------------------------
Static Function PutLog( cMsg )
	Local cLogx := ""
	If lGeraLog
		cLogx := Memoread(cFileLog)	
		MemoWrite(cFileLog,cLogx + CRLF + cMsg )
    EndIf
Return

