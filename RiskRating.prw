#INCLUDE "rwmake.ch"
#INCLUDE "TOPCONN.CH"
#include "protheus.ch"
#include "fileio.ch"
#DEFINE ENTER Chr(13)+Chr(10)

#DEFINE COMP_DATE	"20170904"

///////////////////////////////////////////////////////////////////////////////////
//+-----------------------------------------------------------------------------+//
//| PROGRAMA  | RISKRATING.PRW      | AUTOR | Raul Capeleti | DATA | 27/10/2014 |//
//+-----------------------------------------------------------------------------+//
//| DESCRICAO | leitura de aqruivo texto gerado no portal da CISP para ser      |//
//|           | integrado ao cadastro de clientes                               |//
//|           |                                                                 |//
//+-----------------------------------------------------------------------------+//
//| MANUTENCAO DESDE SUA CRIACAO                                                |//
//+-----------------------------------------------------------------------------+//
//| DATA     | AUTOR                | DESCRICAO                                 |//
//+-----------------------------------------------------------------------------+//
//|          |                      |                                           |//
//+-----------------------------------------------------------------------------+//
///////////////////////////////////////////////////////////////////////////////////
/*-----------------------*/
User Function RiskRating()
/*-----------------------*/
//Local _nI		:= 0
//Local nIdx		:= 0
DbSelectArea("SZU")

cCadastro := "Risk Rating Cisp - Clientes ["+COMP_DATE+"]"

aRotina   := { { "Pesquisar"       ,"AxPesqui"   , 0, 1},;
{ "Visualizar"	   ,"Axvisual"     , 0, 2},;
{ "Incluir"	       ,"AxInclui"     , 0, 3},;
{ "Alterar"		   ,"AxAltera"     , 0, 4},;
{ "Excluir"        ,"AxDeleta"     , 0, 5},;
{ "Legenda"        ,"U_SZULeg"     , 0, 6},;
{ "Atual.Master"   ,"U_ZU_ATUAM"   , 0, 7},;
{ "Atual.Plus"     ,"U_ZU_ATUAP"   , 0, 8}}

_aCores  := {{"(SZU->ZU_ARQATUL=='1')" , 'BR_VERDE' },;
{"(SZU->ZU_ARQATUL=='2')" , 'BR_AZUL '}}

aArray := {}

SZU->(mBrowse(06,01,22,75, "SZU",,,,,,_aCores))

SZU->(DbCloseArea())
Return

/*--------------------*/
User Function ZU_ATUAP()
/*--------------------*/
Private _cNomeArq := space(70)

@ 000,000 TO 230,470 DIALOG _oDlg TITLE "Leitura do arquivo txt - Plus ["+COMP_DATE+"]"
@ 000,000 TO 010,230
@ 001,001 Say "Esta rotina fará a Atualização do Cadastro Risk Rating - Plus"

@ 003,001 Say "Informe Abaixo"
@ 004,001 SAY "Arquivo"
@ 004,005 GET _cNomeArq Picture '@!' Size 160,9 When .T.
@ 080,050 BMPBUTTON TYPE 5 ACTION F_Atu1()
@ 080,110 BMPBUTTON TYPE 1 ACTION Processa({|lEnd| IMPORT_RRP()}, 'Processando...')
@ 080,170 BMPBUTTON TYPE 2 ACTION Close(_oDlg)
ACTIVATE DIALOG _oDlg CENTERED

Return

/*---------------------*/
Static Function F_Atu1()
/*--------------------*/
Local nStyle := GETF_LOCALHARD + GETF_NETWORKDRIVE 
Local cDirIni   := GetMV("FS_C_DIR01",,"O:\Financeiro\FC\Crédito\Rating Plus")              

_cNomeArq := cGetFile("*.txt|*.txt",OemToAnsi("Selecione o Arquivo..."),0,cDirIni,.T.,nStyle)
_oDlg:Refresh()
Return

/*------------------------*/
Static Function IMPORT_RRP()
/*------------------------*/
Local _cBuffer		:= ''
Local _nLinh
Local _dVencLCAt	:= "  /  /  "
Local _cAcaoRF	:= GetMV("MV_XSTATRF")
Local _cAcaoSI	:= GetMV("MV_XSTATSI")
Local _cNewCRF	:= ""
Local _cNewCSI	:= ""
Local aAreaSA1	:= SA1->(GetArea())
Local aAreaSZR	:= SZR->(GetArea())
Local aAreaSZS	:= SZS->(GetArea())
Local aAreaSZV	:= SZV->(GetArea())
Private _aLogP := {}

close(_oDlg)

DBSELECTAREA("SZU")

_nLinh := '000000'
//Abre o arquivo
FT_FUSE(_cNomeArq)

//Posiciona no inicio
FT_FGOTOP()

ProcRegua(FT_FLASTREC())

While !FT_FEOF()
	_nLinh := soma1(_nLinh)
	IncProc(_cNomeArq + " - Linha "+_nLinh)
	_cBuffer := FT_FREADLN()
	
	If Substr(_cBuffer,1,3) = '100'
		_seq01 := Substr(_cBuffer,1,3) // Código-Associado
		_seq02 := Substr(_cBuffer,4,1) // Tipo Pessoa
		_seq03 := Substr(_cBuffer,5,20) // CNPJ/CPF
		_seq04 := Substr(_cBuffer,25,40) // Razao Social / Nome
		_seq05 := Substr(_cBuffer,65,1) // Risco Atual
		_seq06 := Substr(_cBuffer,66,1) // Risco Pontualidade
		_seq07 := Substr(_cBuffer,67,1) // Risco Relação Mercado
		_seq08 := Substr(_cBuffer,68,1) // Risco Ocorrencias
		_seq09 := Substr(_cBuffer,69,1) // Risco Credito na Praça
		_seq10 := Substr(_cBuffer,70,1) // Risco Densidade Comercial
		_seq11 := Substr(_cBuffer,71,50) // Situação Cadastral Receita Federal
		_seq12 := Substr(_cBuffer,121,8) // Data Situação Cadastral Receita Federal
		_seq13 := Substr(_cBuffer,129,50) // Situação Cadastral Sintegra
		_seq14 := Substr(_cBuffer,179,20) // I.E. Sintegra
		_seq15 := Substr(_cBuffer,199,8) // Data Situação Cadastral Sintegra
		_seq16 := Substr(_cBuffer,207,15) // Débito Atual Total
		_seq17 := Substr(_cBuffer,222,4) // Qtd. Associados com Débito
		_seq18 := Substr(_cBuffer,226,4) // Qtd. Associados no Grupo
		_seq19 := Substr(_cBuffer,230,15) // Total Débito Vc + 05 dias
		_seq20 := Substr(_cBuffer,245,4)  // Qtd. Associados Vc + 05 dias
		_seq21 := Substr(_cBuffer,249,15) // Total Débito Vc + 15 dias
		_seq22 := Substr(_cBuffer,264,4) // Qtd. Associados Vc + 15 dias
		_seq23 := Substr(_cBuffer,268,15) // Total de débito com + 30 dias
		_seq24 := Substr(_cBuffer,283,4) // Qtd. Associados Vc + 30 dias
		_seq25 := Substr(_cBuffer,287,4) // Qtd. associados com vendas Últimos 02 meses
		_seq26 := Substr(_cBuffer,291,5) // Qtd. Cheques sem fundos
		_seq27 := Substr(_cBuffer,296,8) // Dt. atualização movimento de cheques
		_seq28 := Substr(_cBuffer,304,8) // Data geração do arquivo
		_seq29 := Substr(_cBuffer,312,6) // Hora da geração do arquivo
		
		// Verifica se existe Status Receita Federal -> Se não houver, cria
		nIdx := SZR->( IndexOrd() )
		SZR->( dbSetOrder( 3 ) )
		If ! SZR->( dbSeek( AllTrim(_seq11), .T. ) )
			_cNewCRF := GETSX8NUM("SZR","ZR_CODIGO")
			ConfirmSX8()
			RollBackSX8()
			Reclock("SZR",.T.)
			SZR->ZR_FILIAL	:= "  "
			SZR->ZR_CODIGO	:= _cNewCRF
			SZR->ZR_DESC	:= AllTrim(_seq11)
			SZR->ZR_ACAO	:= _cAcaoRF
			SZR->(MsUnlock())
		Endif
		// Verifica se existe Status Sintegra -> Se não houver, cria
		nIdx := SZS->( IndexOrd() )
		SZS->( dbSetOrder( 3 ) )
		If ! SZS->( dbSeek( AllTrim(_seq13), .T. ) )
			_cNewCSI := GETSX8NUM("SZS","ZS_CODIGO")
			ConfirmSX8()
			RollBackSX8()
			Reclock("SZS",.T.)
			SZS->ZS_FILIAL	:= "  "
			SZS->ZS_CODIGO	:= _cNewCSI
			SZS->ZS_DESC	:= AllTrim(_seq13)
			SZS->ZS_ACAO	:= _cAcaoSI
			SZS->(MsUnlock())
		Endif
		If ! SZU->(DbSeek(SUBSTR(_SEQ03,7,8)))
			RECLOCK("SZU",.T.)
		Else
			RECLOCK("SZU",.F.)
		Endif
		SZU->ZU_FILIAL := "  "
		SZU->ZU_CODIGO := _seq01
		SZU->ZU_TIPO   := _seq02
		SZU->ZU_CNPJ   := SUBSTR(_SEQ03,7,8)
		SZU->ZU_RAZAO  := _seq04
		SZU->ZU_RISCO  := _seq05
		SZU->ZU_RISPON := _seq06
		SZU->ZU_RISRMER:= _seq07
		SZU->ZU_RISCOC := _seq08
		SZU->ZU_RISCPR := _seq09
		SZU->ZU_RISDEN := _seq10
		SZU->ZU_RECFED := _seq11
		SZU->ZU_DTSITU := ctod(substr(_seq12,7,2)+'/'+substr(_seq12,5,2)+'/'+substr(_seq12,1,4))
		SZU->ZU_CADSINT:= _seq13
		SZU->ZU_IE     := aLLTRIM(str(val(_seq14)))
		SZU->ZU_DTSINT := ctod(substr(_seq15,7,2)+'/'+substr(_seq15,5,2)+'/'+substr(_seq15,1,4))
		SZU->ZU_DEBITO := VAl(_seq16)/100
		SZU->ZU_QTDDEB := val(_seq17)
		SZU->ZU_QTDASSO:= val(_seq18)
		SZU->ZU_TOTDV  := val(_seq19)/100
		SZU->ZU_QTVENC := val(_seq20)
		SZU->ZU_TOTDEB := val(_seq21)/100
		SZU->ZU_QTDEBIT:= Val(_seq22)
		SZU->ZU_TODEBTR:= val(_seq23)/100
		SZU->ZU_QADEBV  := val(_seq24)
		SZU->ZU_ULTMES  := val(_seq25)
		SZU->ZU_CHEQUE  := val(_seq26 )
		SZU->ZU_DATACH  := ctod(substr(_seq27,7,2)+'/'+substr(_seq27,5,2)+'/'+substr(_seq27,1,4))
		SZU->ZU_DATAGER := ctod(substr(_seq28,7,2)+'/'+substr(_seq28,5,2)+'/'+substr(_seq28,1,4))
		SZU->ZU_HORA    := Transform(_seq29 ,"@R 99:99")
		SZU->ZU_ARQATUL:= '1' // Atualizado pelo arquivo Plus
		// Analisa Status Receita Federal
		nIdx := SZR->( IndexOrd() )
		SZR->( dbSetOrder( 3 ) )
		If SZR->( dbSeek( AllTrim(_seq11), .T. ) )
			SZU->ZU_CSTATRF := SZR->ZR_CODIGO
		Else
			SZU->ZU_CSTATRF := ""
		Endif
		// Analisa Status Sintegra
		nIdx := SZS->( IndexOrd() )
		SZS->( dbSetOrder( 3 ) )
		If SZS->( dbSeek( AllTrim(_seq13), .T. ) )
			SZU->ZU_CSTATSI := SZS->ZS_CODIGO
		Else
			SZU->ZU_CSTATSI := ""
		Endif
		SZU->(MsUnlock())
		// Cadastro de Regras Risk Rating
		nIdx := SZV->( IndexOrd() )
		SZV->( dbSetOrder( 2 ) )
		SZV->( dbSeek( SZU->ZU_RISCO+SZU->ZU_RISDEN, .T. ) )
		While SZV->ZV_RISCO == SZU->ZU_RISCO .and. SZV->ZV_DENSCOM == SZU->ZU_RISDEN
			// Cadastro de Clientes
			DbSelectArea("SA1")
			DbSetOrder(3)
			If DbSeek(xFilial("SA1")+SUBSTR(SZU->ZU_CNPJ,1,8))
				While SUBSTR(SA1->A1_CGC,1,8) == SUBSTR(SZU->ZU_CNPJ,1,8)
					_dVencLCAt		:= SA1->A1_VENCLC
					// Status Receita Federal
					nIdx := SZR->( IndexOrd() )
					SZR->( dbSetOrder( 2 ) )
					SZR->( dbSeek( SZU->ZU_CSTATRF, .T. ) )
					If SZR->ZR_ACAO == "L"
						If SZV->ZV_CALCDIA == "A"
							If RecLock("SA1",.F.)
								SA1->A1_VENCLC	:= dDataBase + SZV->ZV_DIASATU
								SA1->A1_XMSGCIS	:= AllTrim(SZV->ZV_MSGRET)
								SA1->(MsUnlock())
							else
								Loop
							EndIf
						ElseIf SZV->ZV_CALCDIA == "S"
							If RecLock("SA1",.F.)
								SA1->A1_VENCLC	:= dDataBase - SZV->ZV_DIASATU
								SA1->A1_XMSGCIS	:= AllTrim(SZV->ZV_MSGRET)
								SA1->(MsUnlock())
							else
								Loop
							EndIf
						ElseIf SZV->ZV_CALCDIA == "N"
							If RecLock("SA1",.F.)
								SA1->A1_XMSGCIS	:= AllTrim(SZV->ZV_MSGRET)
								SA1->(MsUnlock())
							else
								Loop
							EndIf
						Endif
					Elseif SZR->ZR_ACAO == "B"
						If SZV->ZV_CALCDIA == "N"
							If RecLock("SA1",.F.)
								SA1->A1_XMSGCIS	:= AllTrim(SZV->ZV_MSGRET)
								SA1->(MsUnlock())
							else
								Loop
							EndIf
						Elseif SZV->ZV_CALCDIA <> "N"
							If RecLock("SA1",.F.)
								SA1->A1_VENCLC	:= dDataBase - SZV->ZV_DIASATU
								SA1->A1_XMSGCIS	:= AllTrim(SZR->ZR_DESC)
								SA1->(MsUnlock())
							else
								Loop
							EndIf
						Endif
					Endif
					// Status Sintegra
					nIdx := SZS->( IndexOrd() )
					SZS->( dbSetOrder( 2 ) )
					SZS->( dbSeek( SZU->ZU_CSTATSI, .T. ) )
					If SZS->ZS_ACAO == "L"
						If SZV->ZV_CALCDIA == "A"
							If RecLock("SA1",.F.)
								SA1->A1_VENCLC	:= dDataBase + SZV->ZV_DIASATU
								SA1->A1_XMSGCIS	:= AllTrim(SZV->ZV_MSGRET)
								SA1->(MsUnlock())
							else
								Loop
							EndIf
						ElseIf SZV->ZV_CALCDIA == "S"
							If RecLock("SA1",.F.)
								SA1->A1_VENCLC	:= dDataBase - SZV->ZV_DIASATU
								SA1->A1_XMSGCIS	:= AllTrim(SZV->ZV_MSGRET)
								SA1->(MsUnlock())
							else
								Loop
							EndIf
						ElseIf SZV->ZV_CALCDIA == "N"
							If RecLock("SA1",.F.)
								SA1->A1_XMSGCIS	:= AllTrim(SZV->ZV_MSGRET)
								SA1->(MsUnlock())
							else
								Loop
							EndIf
						Endif
					Elseif SZS->ZS_ACAO == "B"
						If SZV->ZV_CALCDIA == "N"
							If RecLock("SA1",.F.)
								SA1->A1_XMSGCIS	:= AllTrim(SZV->ZV_MSGRET)
								SA1->(MsUnlock())
							else
								Loop
							EndIf
						Elseif SZV->ZV_CALCDIA <> "N"
							If RecLock("SA1",.F.)
								SA1->A1_VENCLC	:= dDataBase - SZV->ZV_DIASATU
								SA1->A1_XMSGCIS	:= AllTrim(SZS->ZS_DESC)
								SA1->(MsUnlock())
							else
								Loop
							EndIf
						Endif
					Endif
					aAdd(_aLogP,{SA1->A1_COD,;
					SA1->A1_LOJA,;
					AllTrim(SZU->ZU_CNPJ),;
					SZU->ZU_RAZAO,;
					SZU->ZU_RISCO,;
					SZU->ZU_RISDEN,;
					SZU->ZU_CSTATRF,;
					SZU->ZU_CSTATSI,;
					SZR->ZR_ACAO,;
					_dVencLCAt,;
					SA1->A1_VENCLC,;
					SA1->A1_XMSGCIS})
					DbSkip()
				End
				SA1->(DbSkip())
			Endif
			SA1->(DbCloseArea())
			SZV->( dbSkip() )
		End
	Endif
	
	FT_FSKIP()
	
Enddo

FT_FUSE() // Fecha o arquivo texto.


If MsgBox("Gera Log dos Clientes Atualizados ?","Geração de Log Plus","YESNO")
	Processa({|| GeraLogP()})
Endif

RestArea(aAreaSA1)
RestArea(aAreaSZR)
RestArea(aAreaSZS)
RestArea(aAreaSZV)

Return

// Função que gera o Log dos clientes atualizados em TXT.
Static Function GeraLogP()
Local cDirIni   := GetMV("FS_C_DIR03",,"O:\Financeiro\FC\Crédito\Log Crédito")    
          
Local cDir      := cGetFile('Arquivo TXT|*.txt','Todos os Drives',0,cDirIni,.F.,GETF_LOCALFLOPPY+GETF_LOCALHARD+GETF_NETWORKDRIVE+GETF_RETDIRECTORY,.T.)
Local nHandle 	:= 0
Local _cBuffers	:= ""
Local cArqLog	:= "log_plus_"+Dtos(dDatabase)
Local lContinua := .T. 
Local nSeq		:= 1
Local _nI		:= 0
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³FCreate - É o comando responsavel pela criação do arquivo.                                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

cFileDest := Alltrim( StrTran(cDir+cArqLog, "\\","\" ))
                      
While lContinua
	cFileDest := cFileDest+"_"+StrZero(nSeq,3)
	If File(cArqLog)
		nSeq++	
	Else
		lContinua := .F.
	EndIf
EndDo

If File(AllTrim(cFileDest+".txt"))
	fErase(AllTrim(cFileDest+".txt"))
endif
nHandle := FCreate(cFileDest+".txt")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³nHandle - A função FCreate retorna o handle, que indica se foi possível ou não criar o arquivo. Se o valor for     ³
//³menor que zero, não foi possível criar o arquivo.                                                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nHandle < 0
	MsgAlert("Erro durante criação do arquivo.")
Else
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³FWrite - Comando reponsavel pela gravação do texto.                                                                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	_cBuffers := "CODIGO"+chr(124)+"LJ"+chr(124)+"CNPJ"+Space(04)+chr(124)+"RAZAO_SOCIAL"+Space(28)+chr(124)+"RISCO"+chr(124)+"DENS."+chr(124)+"C_RF"+chr(124)+"C_SI"+chr(124)+"ACAO"+chr(124)+"DT_LC_ANT."+Space(1)+chr(124)+"DT_LC_ATU."+Space(1)+chr(124)+"MSG_REGRA"+Space(26)+chr(124)+CHR(13)+CHR(10)
	For _nI := 1 to Len(_aLogP)
		_cBuffers += _aLogP[_nI][1]+chr(124)+_aLogP[_nI][2]+chr(124)+_aLogP[_nI][3]+chr(124)+_aLogP[_nI][4]+chr(124)+_aLogP[_nI][5]+Space(04)+chr(124)+_aLogP[_nI][6]+Space(04)+chr(124)+_aLogP[_nI][7]+Space(02)+chr(124)+_aLogP[_nI][8]+Space(02)+chr(124)+_aLogP[_nI][9]+Space(03)+chr(124)+DtoC(_aLogP[_nI][10])+Space(01)+chr(124)+DtoC(_aLogP[_nI][11])+Space(01)+chr(124)+_aLogP[_nI][12]+chr(124)+CHR(13)+CHR(10)
	Next _nI
	FWrite(nHandle,_cBuffers)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³FClose - Comando que fecha o arquivo, liberando o uso para outros programas.                                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	FClose(nHandle)
EndIf

ApMsgInfo("Log Gravado com Sucesso !!!"+CRLF+"Arquivo: "+cFileDest+".txt")

Return

ApMsgInfo("Rotina excutada com Sucesso !!!")

SZU->(dbCloseArea())

RETURN()

/*--------------------*/
User Function ZU_ATUAM()
/*--------------------*/

Private _cNomeArq := space(70)

@ 000,000 TO 230,470 DIALOG _oDlg TITLE "Leitura do arquivo txt - Master"
@ 000,000 TO 010,230
@ 001,001 Say "Esta rotina fará a Atualização do Cadastro Risk Rating - Master"

@ 003,001 Say "Informe Abaixo"
@ 004,001 SAY "Arquivo"
@ 004,005 GET _cNomeArq Picture '@!' Size 160,9 When .T.
@ 080,050 BMPBUTTON TYPE 5 ACTION F_Atu2()
@ 080,110 BMPBUTTON TYPE 1 ACTION Processa({|lEnd| IMPORT_RRM()}, 'Processando...')
@ 080,170 BMPBUTTON TYPE 2 ACTION Close(_oDlg)
ACTIVATE DIALOG _oDlg CENTERED

Return

/*---------------------*/
Static Function F_Atu2()
/*--------------------*/
Local nStyle 	:= GETF_LOCALHARD + GETF_NETWORKDRIVE 
Local cDirIni   := GetMV("FS_C_DIR02",,"O:\Financeiro\FC\Crédito\Rating Master") 

_cNomeArq := cGetFile("*.txt|*.txt",OemToAnsi("Selecione o Arquivo..."),0,cDirIni,.T.,nStyle)
_oDlg:Refresh()
Return

/*------------------------*/
Static Function IMPORT_RRM()
/*------------------------*/
Local _cBuffer := ''
Local _nLinh
Local _dVencLCAt	:= "  /  /  "
Local _cAcaoRF	:= GetMV("MV_XSTATRF")
Local _cAcaoSI	:= GetMV("MV_XSTATSI")
Local aAreaSA1	:= SA1->(GetArea())
Local aAreaSZR	:= SZR->(GetArea())
Local aAreaSZS	:= SZS->(GetArea())
Local aAreaSZV	:= SZV->(GetArea())
Private _aLogM := {}

close(_oDlg)

DBSELECTAREA("SZU")

_nLinh := '000000'
//Abre o arquivo
FT_FUSE(_cNomeArq)

//Posiciona no inicio
FT_FGOTOP()

ProcRegua(FT_FLASTREC())

While !FT_FEOF()
	_nLinh := soma1(_nLinh)
	IncProc(_cNomeArq + " - Linha "+_nLinh)
	_cBuffer := FT_FREADLN()
	
	If Substr(_cBuffer,1,3) = '500'
		_seq01 := Substr(_cBuffer,4,3) // Código Associado
		_seq02 := Substr(_cBuffer,7,1) // Tipo Cliente J = Jurídico
		_seq03 := Substr(_cBuffer,8,15) // CNPJ
		_seq04 := Substr(_cBuffer,23,40) // Razao Social
		_seq05 := Substr(_cBuffer,63,8) // Dt. Fundação Cliente **
		_seq06 := Substr(_cBuffer,71,1) // Risco Atual
		_seq07 := Substr(_cBuffer,72,1) // Pontualidade
		_seq08 := Substr(_cBuffer,73,1) // Rel. no Mercado
		_seq09 := Substr(_cBuffer,74,1) // Ocorr. Negativas
		_seq10 := Substr(_cBuffer,75,1) // Crédito na Praça
		_seq11 := Substr(_cBuffer,76,1) // Densidade Comercial
		_seq12 := Substr(_cBuffer,77,50) // STATUS - Sit. Cad. Receita Federal
		_seq13 := Substr(_cBuffer,127,8) // DATA - Sit. Cad. Receita Federal
		_seq14 := Substr(_cBuffer,135,8) // DATA - Consulta no site da Receita Federal **
		_seq15 := Substr(_cBuffer,143,50) // STATUS - Sit. Cad. Sintegra
		_seq16 := Substr(_cBuffer,193,20) // INSCRICAO ESTADUAL - Sintegra Selecionado
		_seq17 := Substr(_cBuffer,213,8) // DATA - Sit. Cad. SINTEGRA
		_seq18 := Substr(_cBuffer,221,8) // DATA - Consulta no site Sintegra (SEFAZ do ESTADO) **
		_seq19 := Substr(_cBuffer,229,8) // Dt. Geração do Arquivo
		_seq20 := Substr(_cBuffer,237,5) // Qtd. Cheques sem fundos (Bacen)
		_seq21 := Substr(_cBuffer,242,2) // Segmento do Associado Solicitante **
		_seq22 := Substr(_cBuffer,244,15) // Debito Atual Total do Cliente (NO GRUPO DE ASSOCIADOS)
		_seq23 := Substr(_cBuffer,259,4) // Qtd. Associados com debito atual (NO GRUPO DE ASSOCIADOS)
		_seq24 := Substr(_cBuffer,263,4) // Qtd. de Associados (NO GRUPO DE ASSOCIADOS)
		_seq25 := Substr(_cBuffer,267,15) // Total de debitos com + 05 dias (NO GRUPO DE ASSOCIADOS)
		_seq26 := Substr(_cBuffer,282,4) // Qtd. associado c/déb. vencidos + 05 dias (NO GRUPO DE ASSOCIADOS)
		_seq27 := Substr(_cBuffer,286,15) // Total de debitos com + 15 dias (NO GRUPO DE ASSOCIADOS)
		_seq28 := Substr(_cBuffer,301,4) // Qtd. associado c/déb. vencidos + 15 dias (NO GRUPO DE ASSOCIADOS)
		_seq29 := Substr(_cBuffer,305,15) // Total de debitos com + 30 dias (NO GRUPO DE ASSOCIADOS)
		_seq30 := Substr(_cBuffer,320,4) // Qtd. associado c/déb. vencidos + 30 dias (NO GRUPO DE ASSOCIADOS)
		_seq31 := Substr(_cBuffer,324,4) // Qtd. associado c/ vendas Últimos 02 meses (NO GRUPO DE ASSOCIADOS)
		_seq32 := Substr(_cBuffer,328,15) // Valor Limite de Crédito (NO GRUPO DE ASSOCIADOS)
		_seq33 := Substr(_cBuffer,343,4) // Qtd. associados com limite de crédito (NO GRUPO DE ASSOCIADOS)
		_seq34 := Substr(_cBuffer,347,5) // Qtd. cheques sem fundos de sócios do Cliente (SOCIOS: JURIDICOS E FISICOS)
		_seq35 := Substr(_cBuffer,352,15) // Total Valor Maior Acumulo (NO GRUPO DE ASSOCIADOS)
		_seq36 := Substr(_cBuffer,367,4) // Qtd. associados com Valor Maior Acumulo (NO GRUPO DE ASSOCIADOS)
		
		// Verifica se existe Status Receita Federal -> Se não houver, cria
		nIdx := SZR->( IndexOrd() )
		SZR->( dbSetOrder( 3 ) )
		If ! SZR->( dbSeek( AllTrim(_seq12), .T. ) )
			_cNewCRF := GETSX8NUM("SZR","ZR_CODIGO")
			ConfirmSX8()
			RollBackSX8()
			Reclock("SZR",.T.)
			SZR->ZR_FILIAL	:= "  "
			SZR->ZR_CODIGO	:= _cNewCRF
			SZR->ZR_DESC	:= AllTrim(_seq12)
			SZR->ZR_ACAO	:= _cAcaoRF
			SZR->(MsUnlock())
		Endif
		// Verifica se existe Status Sintegra -> Se não houver, cria
		nIdx := SZS->( IndexOrd() )
		SZS->( dbSetOrder( 3 ) )
		If ! SZS->( dbSeek( AllTrim(_seq15), .T. ) )
			_cNewCSI := GETSX8NUM("SZS","ZS_CODIGO")
			ConfirmSX8()
			RollBackSX8()
			Reclock("SZS",.T.)
			SZS->ZS_FILIAL	:= "  "
			SZS->ZS_CODIGO	:= _cNewCSI
			SZS->ZS_DESC	:= AllTrim(_seq15)
			SZS->ZS_ACAO	:= _cAcaoSI
			SZS->(MsUnlock())
		Endif
		
		If ! SZU->(DbSeek(SUBSTR(_SEQ03,2,8)))
			RECLOCK("SZU",.T.)
		Else
			RECLOCK("SZU",.F.)
		Endif
		SZU->ZU_FILIAL := "  "
		SZU->ZU_CODIGO := _seq01
		SZU->ZU_TIPO   := _seq02
		SZU->ZU_CNPJ   := SUBSTR(_SEQ03,2,8)
		SZU->ZU_RAZAO  := _seq04
		SZU->ZU_DTFUNCL:= ctod(substr(_seq05,7,2)+'/'+substr(_seq05,5,2)+'/'+substr(_seq05,1,4))
		SZU->ZU_RISCO  := _seq06
		SZU->ZU_RISPON := _seq07
		SZU->ZU_RISRMER:= _seq08
		SZU->ZU_RISCOC := _seq09
		SZU->ZU_RISCPR := _seq10
		SZU->ZU_RISDEN := _seq11
		SZU->ZU_RECFED := _seq12
		SZU->ZU_DTSITU := ctod(substr(_seq13,7,2)+'/'+substr(_seq13,5,2)+'/'+substr(_seq13,1,4))
		SZU->ZU_DTCONRF:= ctod(substr(_seq14,7,2)+'/'+substr(_seq14,5,2)+'/'+substr(_seq14,1,4))
		SZU->ZU_CADSINT:= _seq15
		SZU->ZU_IE     := aLLTRIM(str(val(_seq16)))
		SZU->ZU_DTSINT := ctod(substr(_seq17,7,2)+'/'+substr(_seq17,5,2)+'/'+substr(_seq17,1,4))
		SZU->ZU_DTCONSI:= ctod(substr(_seq18,7,2)+'/'+substr(_seq18,5,2)+'/'+substr(_seq18,1,4))
		SZU->ZU_DATAGER := ctod(substr(_seq19,7,2)+'/'+substr(_seq19,5,2)+'/'+substr(_seq19,1,4))
		SZU->ZU_CHEQUE  := val(_seq20 )
		SZU->ZU_SEGASS  := _seq21
		SZU->ZU_DEBITO := VAl(_seq22)/100
		SZU->ZU_QTDDEB := val(_seq23)
		SZU->ZU_QTDASSO:= val(_seq24)
		SZU->ZU_TOTDV  := val(_seq25)/100
		SZU->ZU_QTVENC := val(_seq26)
		SZU->ZU_TOTDEB := val(_seq27)/100
		SZU->ZU_QTDEBIT:= Val(_seq28)
		SZU->ZU_TODEBTR:= val(_seq29)/100
		SZU->ZU_QADEBV := val(_seq30)
		SZU->ZU_ULTMES := val(_seq31)
		SZU->ZU_VLLIMCR:= val(_seq32)/100
		SZU->ZU_QTDASLC:= val(_seq33)
		SZU->ZU_QCHSCLI:= val(_seq34)
		SZU->ZU_VLMACU := val(_seq35)/100
		SZU->ZU_QASVLAC:= val(_seq36)
		SZU->ZU_ARQATUL:= '2' // Atualizado pelo arquivo Master
		// Analisa Status Receita Federal
		nIdx := SZR->( IndexOrd() )
		SZR->( dbSetOrder( 3 ) )
		If SZR->( dbSeek( AllTrim(_seq12), .T. ) )
			SZU->ZU_CSTATRF := SZR->ZR_CODIGO
		Else
			SZU->ZU_CSTATRF := ""
		Endif
		// Analisa Status Sintegra
		nIdx := SZS->( IndexOrd() )
		SZS->( dbSetOrder( 3 ) )
		If SZS->( dbSeek( AllTrim(_seq15), .T. ) )
			SZU->ZU_CSTATSI := SZS->ZS_CODIGO
		Else
			SZU->ZU_CSTATSI := ""
		Endif
		SZU->(MsUnlock())
		
		// Cadastro de Regras Risk Rating
		nIdx := SZV->( IndexOrd() )
		SZV->( dbSetOrder( 2 ) )
		SZV->( dbSeek( SZU->ZU_RISCO+SZU->ZU_RISDEN, .T. ) )
		While SZV->ZV_RISCO == SZU->ZU_RISCO .and. SZV->ZV_DENSCOM == SZU->ZU_RISDEN
			// Cadastro de Clientes
			DbSelectArea("SA1")
			DbSetOrder(3)
			If DbSeek(xFilial("SA1")+SUBSTR(SZU->ZU_CNPJ,1,8))
				While SUBSTR(SA1->A1_CGC,1,8) == SUBSTR(SZU->ZU_CNPJ,1,8)
					_dVencLCAt		:= SA1->A1_VENCLC
					// Status Receita Federal
					nIdx := SZR->( IndexOrd() )
					SZR->( dbSetOrder( 2 ) )
					SZR->( dbSeek( SZU->ZU_CSTATRF, .T. ) )
					If SZR->ZR_ACAO == "L"
						If SZV->ZV_CALCDIA == "A"
							If RecLock("SA1",.F.)
								SA1->A1_VENCLC	:= dDataBase + SZV->ZV_DIASATU
								SA1->A1_XMSGCIS	:= AllTrim(SZV->ZV_MSGRET)
								SA1->(MsUnlock())
							else
								Loop
							EndIf
						ElseIf SZV->ZV_CALCDIA == "S"
							If RecLock("SA1",.F.)
								SA1->A1_VENCLC	:= dDataBase - SZV->ZV_DIASATU
								SA1->A1_XMSGCIS	:= AllTrim(SZV->ZV_MSGRET)
								SA1->(MsUnlock())
							else
								Loop
							EndIf
						ElseIf SZV->ZV_CALCDIA == "N"
							If RecLock("SA1",.F.)
								SA1->A1_XMSGCIS	:= AllTrim(SZV->ZV_MSGRET)
								SA1->(MsUnlock())
							else
								Loop
							EndIf
						Endif
					Elseif SZR->ZR_ACAO == "B"
						If SZV->ZV_CALCDIA == "N"
							If RecLock("SA1",.F.)
								SA1->A1_XMSGCIS	:= AllTrim(SZV->ZV_MSGRET)
								SA1->(MsUnlock())
							else
								Loop
							EndIf
						Elseif SZV->ZV_CALCDIA <> "N"
							If RecLock("SA1",.F.)
								SA1->A1_VENCLC	:= dDataBase - SZV->ZV_DIASATU
								SA1->A1_XMSGCIS	:= AllTrim(SZR->ZR_DESC)
								SA1->(MsUnlock())
							else
								Loop
							EndIf
						Endif
					Endif
					// Status Sintegra
					nIdx := SZS->( IndexOrd() )
					SZS->( dbSetOrder( 2 ) )
					SZS->( dbSeek( SZU->ZU_CSTATSI, .T. ) )
					If SZS->ZS_ACAO == "L"
						If SZV->ZV_CALCDIA == "A"
							If RecLock("SA1",.F.)
								SA1->A1_VENCLC	:= dDataBase + SZV->ZV_DIASATU
								SA1->A1_XMSGCIS	:= AllTrim(SZV->ZV_MSGRET)
								SA1->(MsUnlock())
							else
								Loop
							EndIf
						ElseIf SZV->ZV_CALCDIA == "S"
							If RecLock("SA1",.F.)
								SA1->A1_VENCLC	:= dDataBase - SZV->ZV_DIASATU
								SA1->A1_XMSGCIS	:= AllTrim(SZV->ZV_MSGRET)
								SA1->(MsUnlock())
							else
								Loop
							EndIf
						ElseIf SZV->ZV_CALCDIA == "N"
							If RecLock("SA1",.F.)
								SA1->A1_XMSGCIS	:= AllTrim(SZV->ZV_MSGRET)
								SA1->(MsUnlock())
							else
								Loop
							EndIf
						Endif
					Elseif SZS->ZS_ACAO == "B"
						If SZV->ZV_CALCDIA == "N"
							If RecLock("SA1",.F.)
								SA1->A1_XMSGCIS	:= AllTrim(SZV->ZV_MSGRET)
								SA1->(MsUnlock())
							else
								Loop
							EndIf
						Elseif SZV->ZV_CALCDIA <> "N"
							If RecLock("SA1",.F.)
								SA1->A1_VENCLC	:= dDataBase - SZV->ZV_DIASATU
								SA1->A1_XMSGCIS	:= AllTrim(SZS->ZS_DESC)
								SA1->(MsUnlock())
							else
								Loop
							EndIf
						Endif
					Endif
					aAdd(_aLogM,{SA1->A1_COD,;
					SA1->A1_LOJA,;
					AllTrim(SZU->ZU_CNPJ),;
					SZU->ZU_RAZAO,;
					SZU->ZU_RISCO,;
					SZU->ZU_RISDEN,;
					SZU->ZU_CSTATRF,;
					SZU->ZU_CSTATSI,;
					SZR->ZR_ACAO,;
					_dVencLCAt,;
					SA1->A1_VENCLC,;
					SA1->A1_XMSGCIS})
					DbSkip()
				End
				SA1->(DbSkip())
			Endif
			SA1->(DbCloseArea())
			SZV->( dbSkip() )
		End
	ElseIf Substr(_cBuffer,1,3) = '502'
		_seq01 := Substr(_cBuffer,04,15) // CNPJ
		_seq02 := Substr(_cBuffer,19,28) // Mensagem: Cliente não CADASTRA na CISP
		If ! SZU->(DbSeek(SUBSTR(_seq01,2,8)))
			RECLOCK("SZU",.T.)
		Else
			RECLOCK("SZU",.F.)
		Endif
		SZU->ZU_FILIAL	:= "  "
		SZU->ZU_CNPJ   := SUBSTR(_seq01,2,8)
		SZU->ZU_MSGRISK := _seq02
		SZU->ZU_ARQATUL:= '2' // Atualizado pelo arquivo Master
		SZU->(MsUnlock())
	Endif
	
	FT_FSKIP()
	
Enddo

FT_FUSE() // Fecha o arquivo texto.

If MsgBox("Gera Log dos Clientes Atualizados ?","Geração de Log Master","YESNO")
	Processa({|| GeraLogM()})
Endif

RestArea(aAreaSA1)
RestArea(aAreaSZR)
RestArea(aAreaSZS)
RestArea(aAreaSZV)

Return
// Função que gera o Log dos clientes atualizados em TXT.
Static Function GeraLogM()
Local cDirIni   := GetMV("FS_C_DIR04",,"O:\Financeiro\FC\Crédito\Log Crédito")              

Local cDir      := cGetFile('Arquivo TXT|*.txt','Todos os Drives',0,cDirIni,.F.,GETF_LOCALFLOPPY+GETF_LOCALHARD+GETF_NETWORKDRIVE+GETF_RETDIRECTORY,.T.)
Local nHandle 	:= 0
Local _cBuffers	:= ""
Local cArqLog	:= "log_master_"+Dtos(dDatabase)
Local lContinua := .T. 
Local nSeq		:= 1
Local _nI		:= 0
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³FCreate - É o comando responsavel pela criação do arquivo.                                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

cFileDest := Alltrim( StrTran(cDir+cArqLog, "\\","\" ))
                      
While lContinua
	cFileDest := cFileDest+"_"+StrZero(nSeq,3)
	If File(cArqLog)
		nSeq++	
	Else
		lContinua := .F.
	EndIf
EndDo

If File(AllTrim(cFileDest+".txt"))
	fErase(AllTrim(cFileDest+".txt"))
endif
nHandle := FCreate(cFileDest+".txt")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³nHandle - A função FCreate retorna o handle, que indica se foi possível ou não criar o arquivo. Se o valor for     ³
//³menor que zero, não foi possível criar o arquivo.                                                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nHandle < 0
	MsgAlert("Erro durante criação do arquivo.")
Else
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³FWrite - Comando reponsavel pela gravação do texto.                                                                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	_cBuffers := "CODIGO"+chr(124)+"LJ"+chr(124)+"CNPJ"+Space(04)+chr(124)+"RAZAO_SOCIAL"+Space(28)+chr(124)+"RISCO"+chr(124)+"DENS."+chr(124)+"C_RF"+chr(124)+"C_SI"+chr(124)+"ACAO"+chr(124)+"DT_LC_ANT."+chr(124)+"DT_LC_ATU."+Space(1)+chr(124)+"MSG_REGRA"+Space(26)+chr(124)+CHR(13)+CHR(10)
	For _nI := 1 to Len(_aLogM)
		_cBuffers += _aLogM[_nI][1]+chr(124)+_aLogM[_nI][2]+chr(124)+_aLogM[_nI][3]+chr(124)+_aLogM[_nI][4]+chr(124)+_aLogM[_nI][5]+Space(04)+chr(124)+_aLogM[_nI][6]+Space(04)+chr(124)+_aLogM[_nI][7]+Space(02)+chr(124)+_aLogM[_nI][8]+Space(02)+chr(124)+_aLogM[_nI][9]+Space(03)+chr(124)+DtoC(_aLogM[_nI][10])+Space(01)+Space(1)+DtoC(_aLogM[_nI][11])+Space(01)+chr(124)+_aLogM[_nI][12]+chr(124)+CHR(13)+CHR(10)
	Next _nI
	
	FWrite(nHandle,_cBuffers)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³FClose - Comando que fecha o arquivo, liberando o uso para outros programas.                                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	FClose(nHandle)
EndIf

ApMsgInfo("Log Gravado com Sucesso !!!")

Return


ApMsgInfo("Rotina excutada com Sucesso !!!")

SZU->(dbCloseArea()) // Alias correto a ser fechado

RETURN()

/*--------------------*/
User Function SZULeg()
/*--------------------*/

BrwLegenda(cCadastro,"Legenda",{	{"BR_VERDE"		, "Plus"	},;
{"BR_AZUL"		, "Master"	}})
Return()
