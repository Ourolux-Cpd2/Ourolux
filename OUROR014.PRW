#INCLUDE "Topconn.ch"
#INCLUDE "Protheus.ch"

/*------------------------------------------------------------------------------------------------------------------------------------------------*\
| Fonte:	 |	OUROR014.PRW                                                                                                                       |
| Autor:	 |	Ewerton F Brasiliano
| Data:		 |	03/08/2016                                                                                                                         |
| Descrição: |	Fonte responsável pela impressão do relatório Relatório de
\*------------------------------------------------------------------------------------------------------------------------------------------------*/

User Function OUROR014()

Private oReport  := Nil
Private oSection1:= Nil
Private oSection2:= Nil
Private oSection3:= Nil
Private CbTxt	 := ""
Private CbCont	 := ""
Private nOrdem 	 := 0
Private Alfa 	 := 0
Private Z		 := 0
Private M		 := 0
Private tamanho	 := "G"
Private limite   := 254
Private titulo 	 := PADC("OUROR014 - Consumo Mensal X Previsao da Entrega ",75)
Private cDesc1 	 := PADC("Este Programa ira emitir o Relatorio de Totais de Venda por Produto",75)
Private cDesc2 	 := PADC("e a data prevista para a entrega do material solicitado              ",75)
Private cDesc3 	 := PADC("                                                                   ",75)
Private aReturn  := { "Especial" , 1, "Diretoria" , 2, 2, 1,"", 0 }
Private nomeprog := "OUROR014"
Private cPerg    := "OUROR014"
Private nLastKey := 0
Private Li       := 0
Private xPag     := 1
Private wnrel    := "OUROR014"
Private _EmpAtu  := "01"
Private aMovtos  := {}
Private aSlds    := {}
Private _lPas2   := .T.
Private cSQLLog  := ""

Private cString:="SB1"

Private cPerg := PadR("OUROR014", Len (SX1->X1_GRUPO))

//DEFINE FONT oArial10B NAME "Arial" SIZE 0,10 OF oReport


PutSx1(cPerg,"01","Produto de"   ,'','',"mv_ch1","C",TamSx3("D2_COD")[1]     ,0,,"G","","SB1","","","mv_par01",""			,"","",""	 ,""		 ,"","","","","","","","","","","")
PutSx1(cPerg,"02","Produto até"  ,'','',"mv_ch2","C",TamSx3("D2_COD")[1]     ,0,,"G","","SB1","","","mv_par02",""			,"","","ZZZZZZ" ,""		 ,"","","","","","","","","","","")
PutSx1(cPerg,"03","Data de"		 ,'','',"mv_ch3","D",TamSx3("D2_EMISSAO")[1],0,,"G","","","","","mv_par03",""			,"","",""	 ,""		 ,"","","","","","","","","","","")
PutSx1(cPerg,"04","Data até"	 ,'','',"mv_ch4","D",TamSx3("D2_EMISSAO")[1],0,,"G","","","","","mv_par04",""			,"","",""	 ,""		 ,"","","","","","","","","","","")
PutSx1(cPerg,"05","Almoxarifado" ,'','',"mv_ch5","C",TamSx3("D2_LOCAL")[1]  ,0,,"G","","1","","","mv_par05",""			,"","",""	 ,""		 ,"","","","","","","","","","","")
PutSx1(cPerg,"06","Empresa de"   ,'','',"mv_ch6","C",TamSx3("D2_FILIAL")[1] ,0,,"G","","SM0","","","mv_par06",""			,"","",""	 ,""		 ,"","","","","","","","","","","")
PutSx1(cPerg,"07","Empresa até"  ,'','',"mv_ch7","C",TamSx3("D2_FILIAL")[1] ,0,,"G","","SM0","","","mv_par07",""			,"","","ZZZZZZ" ,""		 ,"","","","","","","","","","","")
PutSx1(cPerg,"08","Filial de"	 ,'','',"mv_ch8","C",TamSx3("D2_FILIAL")[1] ,0,,"G","","SM0"   ,"","","mv_par08",""			,"","",""	 ,""		 ,"","","","","","","","","","","")
PutSx1(cPerg,"09","Filial até"   ,'','',"mv_ch9","C",TamSx3("D2_FILIAL")[1] ,0,,"G","","SM0"   ,"","","mv_par09",""			,"","","ZZZZZZ"	 ,""		 ,"","","","","","","","","","","")


Pergunte(cPerg,.T.)
ReportDef()
oReport:PrintDialog()

Return

Static Function ReportDef()

////////////////////////////////////////////////
oReport := TReport():New("OUROR014","Relatório Consumo Mensal X Previsao da Entrega",cPerg,{|oReport| PrintReport(oReport)},"Consumo Mensal X Previsao da Entrega",.T.,'TOTAIS-->',.T.)
oReport:SetLandscape(.T.)
oReport:oPage:setPaperSize(10)
oReport:cFontBody := 'Courier New'
oReport:lBold := .F.
oReport:nFontBody := 08


//////////////////////////////////////////////

oSection1 := TRSection():New(oReport, "SEÇÃO 1")
TRCell():New(oSection1, "D2_COD" ,"","" , , 6)
TRCell():New(oSection1, "B1_DESC","","" , , 28)
TRCell():New(oSection1, "D2_UM","", "", , 2)

_nMeses := Month( mv_par04 )
_nMes   := Month( mv_par03 )


If Year( mv_par04 ) = Year( mv_par03 )
	
	_nMeses := Month( mv_par04 )
	_nMes   := Month( mv_par03 )
	_nMeses -= _nMes
	
Else
	
	_nYear := Year( mv_par04 )
	_nYear -= Year( mv_par03 )
	_nYear -= 1
	_nYear *= 12
	
	_nMeses := Month( mv_par03 )
	_nMeses :=  12 - _nMeses
	_nMeses += Month( mv_par04 )
	
End

_nMeses ++

If _nMeses > 11   // 12 05-07-2011
	
	MsgInfo( 'Periodo nao pode ser superior a 11 meses!' )
	Return()
	
ElseIf mv_par04 < mv_par03
	
	MsgInfo( 'Data final nao pode ser menor da data inicial!' )
	Return()
	
End

//////////////////////////////////////////////
fk=Month(mv_par03)
h=1
xp=4
FOR h=1 to _nMeses
	TRCell():New(oSection1, "MES"+cvaltochar(fk),"","" , , 8)
	if fk =12
		fk=0
	endif
	fk++
	xp++
	iF h >= 11
		exit
	eNDIF
	
NEXT
nMesPrv := 11 - _nMeses // We can display a maximum of 13 fields (consumo + previsao) // Alterado por Ewerton, 08/04/16 - I1603-1376

TRCell():New(oSection1, "MEDIA","","", , 8)
TRCell():New(oSection1, "SALDO","","", , 8)
TRCell():New(oSection1, "SALDOM","","", , 8)

hx=0
FOR hx=1 to nMesPrv
	TRCell():New(oSection1, "ENTR"+cvaltochar(hx),"","" , , 8)
NEXT

TRCell():New(oSection1, "FUTURO","","", , 8)


oSection2 := TRSection():New(oReport, "SEÇÃO 2")
TRCell():New(oSection2, "D2_COD" ,"","" , , 6)
TRCell():New(oSection2, "B1_DESC","","" , , 28)
TRCell():New(oSection2, "D2_UM","", ""         , , 2)

fk=Month(mv_par03)
h=1
xp=4
FOR h=1 to _nMeses
	TRCell():New(oSection2, "MES"+cvaltochar(fk),"", ""        , , 8,,,,,,,,,,,.T.)
	if fk =12
		fk=0
	endif
	fk++
	xp++
	iF h >= 11
		exit
	eNDIF
	
NEXT

TRCell():New(oSection2, "MEDIA","", "", , 8)
TRCell():New(oSection2, "SALDO","", "", , 8)
TRCell():New(oSection2, "SALDOM","", "", ,8)

hx=0
FOR hx=1 to nMesPrv
	TRCell():New(oSection2, "ENTR"+cvaltochar(hx),"","" , , 8)
NEXT
TRCell():New(oSection2, "FUTURO","","", , 8)

oSection3 := TRSection():New(oReport, "SEÇÃO 3")


h=1
TRCell():New(oSection3, "TOTAL","", ""        , , 33,,,,,,,,,,,.T.)

FOR h=1 to _nMeses
	TRCell():New(oSection3, "TOTAL"+cvaltochar(h),"", ""        , "@E 999,999,999", 8,,,,,,,,,,,,.T.)
	iF h >= 11
		exit
	eNDIF
NEXT
h=1
h+=_nMeses
TRCell():New(oSection3, "TOTAL"+cvaltochar(h),"", ""        ,"@E 999,999,999", 8,,,,,,,,,,,,.T.)
h++
TRCell():New(oSection3, "TOTAL"+cvaltochar(h),"", ""        ,"@E 999,999,999", 9,,,,,,,,,,,,.T.)
h++
TRCell():New(oSection3, "TOTAL"+cvaltochar(h),"", ""        ,"@E 999,999,999", 10,,,,,,,,,,,,.T.)

hx=0
h++
FOR hx=1 to nMesPrv
	TRCell():New(oSection3, "TOTAL"+cvaltochar(h),"", ""        ,"@E 999,999,999", 9,,,,,,,,,,,,.T.)
	h++
NEXT

TRCell():New(oSection3, "TOTAL"+cvaltochar(h),"", ""        ,"@E 999,999,999", 10,,,,,,,,,,,,.T.)



Return Nil

Static Function PrintReport(oReport)

Local aStrS 	:= {} // Alterado por Ewerton, 30/08/12.
Local aStrQ 	:= {} // Alterado por Ewerton, 30/08/12.
Local QryPrv	:= ""
Local nAno 		:= nMes := 0
Local cIni		:= cFim := ""
Local cCod 		:= ""
Local aMesPrv   := {}
Local aQtdPrv   := {}
Local nMesPrv   :=  0 // Previsao da entrega e de 7 meses
Local _cQry     := ""
Local aFornece 	:= {}
Local aCliente 	:= {}
Local cQAdd    	:= ""
Local nSldAtu  	:= 0
Local cQrySld  	:= ""
Local _CabExc  	:= {}
Local aDados1 	:= {}
Local _nReg     := 0 // Alterado por Ewerton, 30/08/12.
Local _QtdPrev  := 0 // Alterado por Ewerton, 30/08/12.
Local _nQtdPrv  := 0 // Alterado por Ewerton, 14/01/16.

Private _EmpAtu  := "01"
Private aMovtos  := {}
Private aSlds    := {}
Private _lPas2   := .T.
Private cArqTrb1 := CriaTrab(NIL,.F.) // Alterado por Ewerton, 30/08/12.
Private cArqTrb2 := CriaTrab(NIL,.F.) // Alterado por Ewerton, 30/08/12.

Private _aTotCom := {} // Alterado por Ewerton, 12/01/16.
Private _aTotVen := {} // Alterado por Ewerton, 12/01/16.
Private _nSldTot := 0  // Alterado por Ewerton, 12/01/16.
Private _qMedTot := 0  // Alterado por Ewerton, 12/01/16.

Private _nTotPrv := 0  // Alterado por Ewerton - Fit Gestão, 25/08/16 - I1603-1376
Private _nTotSF  := 0  // Alterado por Ewerton - Fit Gestão, 25/08/16 - I1603-1376
Private _nTotSM  := 0  // Alterado por Ewerton - Fit Gestão, 25/08/16 - I1603-1376
Public _nMeses
Public xacab:= {}

Pergunte(cPerg,.F.)

_EmpAtu:=  "01"
_lPas2 := .T.

cTitulo := "Consumo Mensal X Previsao da Entrega do Produto " + Alltrim(Mv_Par01) + " Ate " + Alltrim(Mv_Par02)

_pIni := DtoS( mv_par03 )
_pFim := DtoS( mv_par04 )

_pIni := Substr( _pIni, 1, 6 )
_pFim := Substr( _pFim, 1, 6 )

_nMeses := Month( mv_par04 )
_nMes   := Month( mv_par03 )

If Year( mv_par04 ) = Year( mv_par03 )
	
	_nMeses := Month( mv_par04 )
	_nMes   := Month( mv_par03 )
	_nMeses -= _nMes
	
Else
	
	_nYear := Year( mv_par04 )
	_nYear -= Year( mv_par03 )
	_nYear -= 1
	_nYear *= 12
	
	_nMeses := Month( mv_par03 )
	_nMeses :=  12 - _nMeses
	_nMeses += Month( mv_par04 )
	
End

_nMeses ++

If _nMeses > 11   // 12 05-07-2011
	
	MsgInfo( 'Periodo nao pode ser superior a 11 meses!' )
	Return()
	
ElseIf mv_par04 < mv_par03
	
	MsgInfo( 'Data final nao pode ser menor da data inicial!' )
	Return()
	
End

If Select("QRY") > 0
	DbSelectArea("QRY")
	QRY->(DbCloseArea())
EndIf

If Select("Prv") > 0
	DbSelectArea("Prv")
	Prv->(DbCloseArea())
EndIf

If Select("Sld") > 0
	DbSelectArea("Sld")
	Sld->(DbCloseArea())
EndIf

If Select("QRY2") > 0
	DbSelectArea("QRY2")
	QRY2->(DbCloseArea())
EndIf

If Select("Sld2") > 0
	DbSelectArea("Sld2")
	Sld2->(DbCloseArea())
EndIf

//>-- Alterado por Ewerton, 30/08/12.
If Select("SWNTRB") > 0
	DbSelectArea("SWNTRB")
	SWNTRB->(DbCloseArea())
EndIf

If Select("QPRVTRB") > 0
	DbSelectArea("QPRVTRB")
	QPRVTRB->(DbCloseArea())
EndIf

aAdd(aStrS,{"CODPROD" ,"C",15,0}) // CODIGO PRODUTO
aAdd(aStrS,{"QTDPREV" ,"N",20,0}) // QUANTIDADE PREVISTA POR PROCESSO
aAdd(aStrS,{"PERIODO" ,"C",06,0}) // PERIODO

dbcreate(cArqTrb1,aStrS)
dbUseArea(.T.,,cArqTrb1,"SWNTRB",.F.,.F.)

aAdd(aStrQ,{"CODPROD" ,"C",15,0}) // CODIGO PRODUTO
aAdd(aStrQ,{"QTDPREV" ,"N",20,0}) // QUANTIDADE PREVISTA POR PROCESSO
aAdd(aStrQ,{"PERIODO" ,"C",06,0}) // PERIODO

dbcreate(cArqTrb2,aStrQ)
dbUseArea(.T.,,cArqTrb2,"QPRVTRB",.F.,.F.)
//>--

dbSelectArea("SM0")
dbSetOrder(1)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Procura o CNPJ da Filial para localizar o Fornecedor e/ou Cliente cadastrado ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Empty(mv_par07)
	//MsSeek(Subs(cNumEmp,1,2)+mv_par06,.T.)
	//
	//While SM0->M0_CODIGO+SM0->M0_CODFIL >= (Subs(cNumEmp,1,2)+mv_par06) .And. SM0->M0_CODIGO+SM0->M0_CODFIL <= (Subs(cNumEmp,1,2)+mv_par07)
	MsSeek(Subs(cNumEmp,1,2)+" ",.T.)
	While !Eof()
		dbSelectArea("SA1")
		dbSetOrder(3)
		If dbSeek(xFilial("SA1")+SM0->M0_CGC)
			aAdd(aCliente, {SA1->A1_COD,SA1->A1_LOJA,SA1->A1_NOME})
		EndIf
		dbSelectArea("SA2")
		dbSetOrder(3)
		If dbSeek(xFilial("SA2")+SM0->M0_CGC)
			aAdd(aFornece, {SA2->A2_COD,SA2->A2_LOJA,SA2->A2_NOME})
		EndIf
		dbSelectArea("SM0")
		dbSkip()
	EndDo
EndIf

If !(Len(aFornece)+Len(aCliente)) > 0
	Help(" ",1,"RECNO")
	lContinua := .F.
EndIf

cQAdd := if(len(aCliente)>0,"(","")
for nx:=1 to len(aCliente)
	if nx>1
		cQAdd += " OR "
	endif
	cQAdd += "(F2_CLIENTE='" +aCliente[nx][1] + "' AND F2_LOJA='"+aCliente[nx][2]+"')"
next

cQAdd += if(len(aCliente)>0,")","")

dbSelectArea("SM0")
DbGoTop()

While SM0->(!EOF())
	
	If SM0->M0_CODIGO >= MV_PAR06 .And. SM0->M0_CODIGO <= MV_PAR07 .And. SM0->M0_CODIGO == "01" .And. _EmpAtu = "01"
		
		//Seleciona as movimentações da empresa 01
		_cQry := "SELECT D2_COD AS Codigo, SUBSTRING(D2_EMISSAO, 1, 6) AS Periodo, "
		_cQry += "SUM(D2_QUANT) AS Qde, D2_LOCAL AS Loc "
		_cQry += "FROM  SD2" + SM0->M0_CODIGO +"0 SD2 INNER JOIN SB1010 SB1 ON D2_COD = B1_COD "
		_cQry += "INNER JOIN SF2" + SM0->M0_CODIGO +"0 SF2 ON F2_SERIE = D2_SERIE AND F2_DOC = D2_DOC "
		_cQry += "AND F2_CLIENTE = D2_CLIENTE AND F2_LOJA = D2_LOJA "
		_cQry += "INNER JOIN SF4" + SM0->M0_CODIGO +"0  SF4 ON F4_CODIGO = D2_TES "
		_cQry += "WHERE (SUBSTRING(D2_EMISSAO, 1, 6) BETWEEN '" + _pIni + "' AND '" + _pFim + "') "
		_cQry += "AND (D2_LOCAL = '" + MV_PAR05 + "') AND (SD2.D_E_L_E_T_ <> '*') AND (D2_TIPO = 'N') "
		_cQry += "AND (D2_COD BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "') "
		//_cQry += "AND (D2_COD BETWEEN '" + Substr( MV_PAR01, 1, 5 ) + "' AND '" + Substr( MV_PAR02, 1, 5 ) + "') "
		
		If MV_PAR06 == MV_PAR07
			_cQry += "AND (D2_FILIAL BETWEEN '" + MV_PAR08 + "' AND '" + MV_PAR09 + "') "
			_cQry += "AND (F2_FILIAL BETWEEN '" + MV_PAR08 + "' AND '" + MV_PAR09 + "') "
		EndIf
		
		_cQry += "AND D2_TIPO = F2_TIPO "
		_cQry += "AND SB1.D_E_L_E_T_ <> '*' AND SF2.D_E_L_E_T_ <> '*' AND B1_MSBLQL <> '1' "
		
		If Len(cQAdd) > 2
			_cQry += "AND NOT" + cQAdd + " "
		EndIf
		
		_cQry += "AND SF4.D_E_L_E_T_ <> '*' AND F4_ESTOQUE = 'S' "
		_cQry += "GROUP  BY D2_COD, SUBSTRING(D2_EMISSAO, 1, 6), D2_LOCAL "
		_cQry += "ORDER BY D2_COD, SUBSTRING(D2_EMISSAO, 1, 6), D2_LOCAL "
		
		dbUseArea( .T., "TOPCONN", TCGENQRY(,,_cQry), 'Qry' )
		
		_EmpAtu:=  "02"
		
	Else
		If MV_PAR06 = "02"
			_EmpAtu :=  "02"
		EndIf
		
		If SM0->M0_CODIGO >= MV_PAR06 .And. SM0->M0_CODIGO <= MV_PAR07 .And. SM0->M0_CODIGO == "02" .And. _EmpAtu == "02" .And. _lPas2
			
			//Seleciona as movimentações da empresa 02
			_cQRY2 := "SELECT D2_COD AS Codigo, SUBSTRING(D2_EMISSAO, 1, 6) AS Periodo, "
			_cQRY2 += "SUM(D2_QUANT) AS Qde, D2_LOCAL AS Loc "
			_cQRY2 += "FROM  SD2" + SM0->M0_CODIGO +"0 SD2 INNER JOIN SB1010 SB1 ON D2_COD = B1_COD "
			_cQRY2 += "INNER JOIN SF2" + SM0->M0_CODIGO +"0 SF2 ON F2_SERIE = D2_SERIE AND F2_DOC = D2_DOC "
			_cQRY2 += "AND F2_CLIENTE = D2_CLIENTE AND F2_LOJA = D2_LOJA "
			_cQRY2 += "INNER JOIN SF4" + SM0->M0_CODIGO +"0  SF4 ON F4_CODIGO = D2_TES "
			_cQRY2 += "WHERE (SUBSTRING(D2_EMISSAO, 1, 6) BETWEEN '" + _pIni + "' AND '" + _pFim + "') "
			_cQRY2 += "AND (D2_LOCAL = '" + MV_PAR05 + "') AND (SD2.D_E_L_E_T_ <> '*') AND (D2_TIPO = 'N') "
			//_cQRY2 += "AND (D2_COD BETWEEN '" + Substr( MV_PAR01, 1, 5 ) + "' AND '" + Substr( MV_PAR02, 1, 5 ) + "') "
			_cQRY2 += "AND (D2_COD BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "') "
			
			If MV_PAR06 == MV_PAR07
				_cQRY2 += "AND (D2_FILIAL BETWEEN '" + MV_PAR08 + "' AND '" + MV_PAR09 + "') "
				_cQRY2 += "AND (F2_FILIAL BETWEEN '" + MV_PAR08 + "' AND '" + MV_PAR09 + "') "
			EndIf
			
			_cQRY2 += "AND D2_TIPO = F2_TIPO "
			_cQRY2 += "AND SB1.D_E_L_E_T_ <> '*' AND SF2.D_E_L_E_T_ <> '*' AND B1_MSBLQL <> '1' "
			
			If Len(cQAdd) > 2
				_cQRY2 += "AND NOT" + cQAdd + " "
			EndIf
			
			_cQRY2 += "AND SF4.D_E_L_E_T_ <> '*' AND F4_ESTOQUE = 'S' "
			_cQRY2 += "GROUP  BY D2_COD, SUBSTRING(D2_EMISSAO, 1, 6), D2_LOCAL "
			dbUseArea( .T., "TOPCONN", TCGENQRY(,,_cQRY2), 'QRY2' )
			_EmpAtu := "03"
			_lPas2 := .F.
		EndIf
	EndIf
	
	SM0->(DbSkip())
	
End

//	_nRegua := 0

If AllTrim(MV_PAR06) = "" .Or.  MV_PAR06 = "01"
	
	DbSelectArea("QRY")
	While ! Eof()
		AADD(aMovtos,{QRY->CODIGO,QRY->PERIODO,QRY->QDE,QRY->LOC})
		QRY->( dbSkip() )
		//			_nRegua ++
	End
EndIf

If _EmpAtu =="03"
	
	DbSelectArea("QRY2")
	While ! Eof()
		
		AADD(aMovtos,{QRY2->CODIGO,QRY2->PERIODO,QRY2->QDE,QRY2->LOC})
		QRY2->( dbSkip() )
		//			_nRegua ++
	End
	
Endif

//	SetRegua( _nRegua )

_EmpAtu := "01"
_lPas2 := .T.

// Previsao de Entrega
//nMesPrv := 12 - _nMeses 05-07-2011
nMesPrv := 11 - _nMeses // We can display a maximum of 13 fields (consumo + previsao) // Alterado por Ewerton, 08/04/16 - I1603-1376
nAno 	:= IIf (Month(mv_par04) - 1 == 0, Year(mv_par04) - 1,Year(mv_par04))
nMes 	:= IIf (Month(mv_par04) - 1 == 0, 12,Month(mv_par04))
cIni 	:= strzero(nAno,4) + strzero(nMes,2)

nAno := IIf (Month(mv_par04)  + nMesPrv  > 12, Year(mv_par04) + 1,Year(mv_par04))
nMes := IIf (Month(mv_par04)  + nMesPrv  > 12,Month(mv_par04) + nMesPrv - 12,Month(mv_par04) + nMesPrv - 1)
cFim := strzero(nAno,4) + strzero(nMes,2)

/* Alterado por Ewerton, 30/08/12.
QRYPrv := " SELECT "
QRYPrv += " Codigo, Periodo, SUM(QtdPrev)  AS QtdPrev "
QRYPrv += " FROM (SELECT  W7_COD_I As Codigo, (W7_QTDE - ISNULL(WN_QUANT,0)) As QtdPrev,  SUBSTRING(W6_PRVENTR, 1, 6) As Periodo "
QRYPrv += " FROM " +RetSqlName("SW7") + " SW7 "
QRYPrv += " INNER JOIN  " +RetSqlName("SW6") + " SW6 "
QRYPrv += " ON W7_HAWB = W6_HAWB "
QRYPrv += " INNER JOIN  " +RetSqlName("SW3") + " SW3 "
QRYPrv += " ON W7_PO_NUM = W3_PO_NUM AND W7_COD_I = W3_COD_I  AND W7_PGI_NUM = W3_PGI_NUM "
QRYPrv += " INNER JOIN  SB1010 SB1 "
QRYPrv += " ON W7_COD_I = B1_COD "
QRYPrv += " LEFT OUTER JOIN " +RetSqlName("SWN") + " SWN "
QRYPrv += " ON W7_HAWB = WN_HAWB AND W7_PO_NUM = WN_PO_NUM AND W7_COD_I = WN_PRODUTO "
QRYPrv += " AND W7_PGI_NUM = WN_PGI_NUM "
QRYPrv += " AND WN_TIPO_NF = '1' "
QRYPrv += " AND SWN.D_E_L_E_T_ = ' '"
QRYPrv += " WHERE"
QRYPrv += " SW7.D_E_L_E_T_ = ' ' "
QRYPrv += " AND SW6.D_E_L_E_T_ = ' ' "
QRYPrv += " AND SW3.D_E_L_E_T_ = ' ' "
QRYPrv += " AND SB1.D_E_L_E_T_ = ' ' "
QRYPrv += " AND SUBSTRING(W6_PRVENTR,1,6) BETWEEN '" + cIni + "' AND '" + cFim + "' "
QRYPrv += " AND (W7_COD_I BETWEEN '" + Substr( MV_PAR01, 1, 5 ) + "' AND '" + Substr( MV_PAR02, 1, 5 ) + "') "
QRYPrv += " AND B1_MSBLQL <> '1' "
QRYPrv += " GROUP  BY W7_COD_I, W7_QTDE, WN_QUANT, SUBSTRING(W6_PRVENTR, 1, 6))a GROUP BY Codigo, Periodo ORDER BY Codigo"
*/

QRYPrv := " SELECT "
QRYPrv += " W7_PO_NUM As NumPO, W7_HAWB As Processo, W7_COD_I As Codigo, W7_QTDE As QtdEmb, SUBSTRING(W6_PRVENTR, 1, 6) As Periodo "
QRYPrv += " FROM " + RetSqlName("SW7") + " SW7 "
QRYPrv += " INNER JOIN  " + RetSqlName("SW6") + " SW6 "
QRYPrv += " ON W7_HAWB = W6_HAWB "
QRYPrv += " INNER JOIN  " + RetSqlName("SW3") + " SW3 "
QRYPrv += " ON W7_PO_NUM = W3_PO_NUM AND W7_COD_I = W3_COD_I  AND W7_PGI_NUM = W3_PGI_NUM "
QRYPrv += " INNER JOIN  " + RetSqlName("SB1") + " SB1 "
QRYPrv += " ON W7_COD_I = B1_COD "
QRYPrv += " WHERE "
QRYPrv += " SW7.D_E_L_E_T_ = ' ' "
QRYPrv += " AND SW6.D_E_L_E_T_ = ' ' "
QRYPrv += " AND SW3.D_E_L_E_T_ = ' ' "
QRYPrv += " AND SB1.D_E_L_E_T_ = ' ' "
QRYPrv += " AND SUBSTRING(W6_PRVENTR,1,6) "
QRYPrv += " BETWEEN '" + cIni + "' AND '" + cFim + "' "
QRYPrv += " AND (W7_COD_I BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "') "
//QRYPrv += " AND (W7_COD_I BETWEEN '" + Substr( MV_PAR01, 1, 5 ) + "' AND '" + Substr( MV_PAR02, 1, 5 ) + "') "
QRYPrv += " AND B1_MSBLQL <> '1' "
QRYPrv += " GROUP  BY W7_PO_NUM, W7_HAWB, W7_COD_I, W7_QTDE, SUBSTRING(W6_PRVENTR, 1, 6) "
QRYPrv += " ORDER BY W7_COD_I , SUBSTRING(W6_PRVENTR, 1, 6) "

cSQLLog := MEMOWRITE("E:\TESTESQL.SQL",QRYPrv)
cSQLLog := MemoWrite(Criatrab(,.f.)+".sql",QRYPrv)

dbUseArea( .T., "TOPCONN", TCGENQRY(,,QRYPrv), 'Prv')

//>---- Alteração feita por Ewerton, 30/08/12.
While Prv->(!Eof())
	dbSelectArea("SWN")
	dbSetOrder(3)
	If dbSeek(xFilial("SWN")+Prv->Processo)
		If ALLTRIM(SWN->WN_PO_NUM) == ALLTRIM(Prv->NumPO) .AND. ALLTRIM(SWN->WN_PRODUTO) == ALLTRIM(Prv->Codigo) .AND. SWN->WN_TIPO_NF == "1"
			DbSelectArea("SWNTRB")
			SWNTRB->(RecLock("SWNTRB",.T.))
			SWNTRB->CODPROD := Prv->Codigo
			SWNTRB->QTDPREV := Prv->QtdEmb - SWN->WN_QUANT
			SWNTRB->PERIODO := Prv->Periodo
			SWNTRB->(MsUnlock("SWNTRB"))
		EndIf
	Else
		DbSelectArea("SWNTRB")
		SWNTRB->(RecLock("SWNTRB",.T.))
		SWNTRB->CODPROD := Prv->Codigo
		SWNTRB->QTDPREV := Prv->QtdEmb
		SWNTRB->PERIODO := Prv->Periodo
		SWNTRB->(MsUnlock("SWNTRB"))
	EndIf
	Prv->(dbSkip())
EndDo

If Select("Prv") > 0
	DbSelectArea("Prv")
	Prv->(DbCloseArea())
EndIf

DbSelectArea("SWNTRB")
SWNTRB->(DbGoTop())
While SWNTRB->(!Eof())
	If _nReg == 0
		DbSelectArea("QPRVTRB")
		QPRVTRB->(RecLock("QPRVTRB",.T.))
		QPRVTRB->CODPROD := SWNTRB->CODPROD
		QPRVTRB->QTDPREV := SWNTRB->QTDPREV
		QPRVTRB->PERIODO := SWNTRB->PERIODO
		QPRVTRB->(MsUnlock("QPRVTRB"))
	Else
		If QPRVTRB->CODPROD == SWNTRB->CODPROD .AND. QPRVTRB->PERIODO == SWNTRB->PERIODO
			_QtdPrev := QPRVTRB->QTDPREV
			QPRVTRB->(RecLock("QPRVTRB",.F.))
			QPRVTRB->CODPROD := SWNTRB->CODPROD
			QPRVTRB->QTDPREV := _QtdPrev + SWNTRB->QTDPREV
			QPRVTRB->PERIODO := SWNTRB->PERIODO
			QPRVTRB->(MsUnlock("QPRVTRB"))
		Else
			QPRVTRB->(RecLock("QPRVTRB",.T.))
			QPRVTRB->CODPROD := SWNTRB->CODPROD
			QPRVTRB->QTDPREV := SWNTRB->QTDPREV
			QPRVTRB->PERIODO := SWNTRB->PERIODO
			QPRVTRB->(MsUnlock("QPRVTRB"))
		EndIf
	EndIf
	_nReg++
	DbSelectArea("SWNTRB")
	SWNTRB->(dbSkip())
EndDo

QPRVTRB->(DbGoTop())

If Select("SWNTRB") > 0
	DbSelectArea("SWNTRB")
	SWNTRB->(DbCloseArea())
EndIf
//>----

//Acumula os Saldos dos produtos de acordo com as empresas selecionadas.

dbSelectArea("SM0")
DbGoTop()

While SM0->(!EOF()) .And. AllTrim(SM0->M0_CODIGO) <> ""
	
	//Seleciona os saldos da empresa 01
	If SM0->M0_CODIGO >= MV_PAR06 .And. SM0->M0_CODIGO <= MV_PAR07 .And. SM0->M0_CODIGO == "01" .And. _EmpAtu = "01"
		
		cQRYSld := "SELECT B1_COD As Cod,SUM(B2_QATU)As Sld "
		cQRYSld += "FROM SB1010 SB1 INNER JOIN SB2" + SM0->M0_CODIGO +"0 SB2 ON B1_COD = B2_COD "
		cQRYSld += "WHERE (B1_COD BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "') "
		//cQRYSld += "WHERE (B1_COD BETWEEN '" + Substr( MV_PAR01, 1, 5 ) + "' AND '" + Substr( MV_PAR02, 1, 5 ) + "') "
		
		// Ewerton - 28/07/16 - I1607-2222
		//cQRYSld += "AND B2_LOCAL IN ('01','98','40','25') "
		cQRYSld += "AND B2_LOCAL = '01' "
		
		If MV_PAR06 == MV_PAR07
			cQRYSld += "AND (B2_FILIAL BETWEEN '" + MV_PAR08 + "' AND '" + MV_PAR09 + "')
		EndIf
		cQRYSld += "AND SB1.D_E_L_E_T_ <> '*' AND SB2.D_E_L_E_T_ <> '*' AND B1_MSBLQL <> '1' "
		cQRYSld += "GROUP  BY B1_COD "
		cQRYSld += "ORDER BY B1_COD "
		
		dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQRYSld), 'Sld' )
		_EmpAtu:=  "02"
		
	Else
		
		If MV_PAR06 = "02"
			_EmpAtu :=  "02"
		EndIf
		
		If SM0->M0_CODIGO >= MV_PAR06 .And. SM0->M0_CODIGO <= MV_PAR07 .And. SM0->M0_CODIGO == "02" .And. _EmpAtu == "02" .And. _lPas2
			
			//Seleciona os saldos da empresa 02
			cQRYSld2 := "SELECT B1_COD As Cod,SUM(B2_QATU)As Sld "
			cQRYSld2 += "FROM SB1010 SB1 INNER JOIN SB2" + SM0->M0_CODIGO +"0 SB2 ON B1_COD = B2_COD "
			cQRYSld2 += "WHERE (B1_COD BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "') "
			//cQRYSld2 += "WHERE (B1_COD BETWEEN '" + Substr( MV_PAR01, 1, 5 ) + "' AND '" + Substr( MV_PAR02, 1, 5 ) + "') "
			
			// Ewerton - 28/07/16 - I1607-2222
			//cQRYSld2 += "AND B2_LOCAL IN ('01','98','40','25') "
			cQRYSld2 += "AND B2_LOCAL = '01' "
			
			If MV_PAR06 == MV_PAR07
				cQRYSld2 += "AND (B2_FILIAL BETWEEN '" + MV_PAR08 + "' AND '" + MV_PAR09 + "')
			EndIf
			cQRYSld2 += "AND SB1.D_E_L_E_T_ <> '*' AND SB2.D_E_L_E_T_ <> '*' AND B1_MSBLQL <> '1' "
			cQRYSld2 += "GROUP  BY B1_COD "
			cQRYSld2 += "ORDER BY B1_COD "
			
			dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQRYSld2), 'Sld2' )
			
			_EmpAtu:=  "03"
			_lPas2 := .F.
		EndIf
	EndIf
	
	SM0->(DbSkip())
End

If AllTrim(MV_PAR06) = "" .Or.  MV_PAR06 = "01"
	
	DbSelectArea("Sld")
	While ! Eof()
		AADD(aSlds,{Sld->Cod,Sld->Sld})
		Sld->( dbSkip() )
	End
	
EndIf

If _EmpAtu =="03"
	
	DbSelectArea("Sld2")
	While ! Eof()
		AADD(aSlds,{Sld2->Cod,Sld2->Sld})
		Sld2->( dbSkip() )
	End
	
Endif

_EmpAtu := ""

dbSelectArea("SB1")
dbSetOrder(1)
SB1->( dbSeek( xFilial( 'SB1' ) + MV_PAR01, .T. ) )

If Substr( MV_PAR01, 1, 2 ) <> Substr( B1_COD, 1, 2 )
	Return()
End

_aMesExt := {'JAN', 'FEV', 'MAR','ABR', 'MAI', 'JUN','JUL', 'AGO', 'SET','OUT', 'NOV', 'DEZ'}

_aMeses := {}
_aQuinz := {}
_cAno   := Year( mv_par03 )
_cAno   := Str( _cAno, 4 )

Cabec2  := 'CODIGO  DESCRICAO                                UM  '
AADD(_CabExc,{"CODIGO"})
AADD(_CabExc,{"DESCRICAO"})
AADD(_CabExc,{"UM"})
Cabec1  :=  Replicate (" ",len(Cabec2))
Cabec1  += "CONSUMO MENSAL"


For i = 1 To _nMeses
	aAdd( _aMeses, _aMesExt[ _nMes ] + '/' + _cAno + '   ')
	Cabec2 += _aMeses[ i ]
	AADD(_CabExc,{_aMeses[ i ]})
	_nMes ++
	
	If _nMes > 12
		
		_cAno := Val( _cAno )
		_cAno ++
		_cAno := Str( _cAno, 4 )
		_nMes := 1
		
	End
Next
////////////////////////////////////////////////
Cabec2 += '     MEDIA  SLD. ATUAL  Sld/Mes'

AADD(_CabExc,{"MEDIA"})
AADD(_CabExc,{"SLD. ATUAL"})
AADD(_CabExc,{"SLD/MES"})

AT('ATUAL',Cabec2)
Cabec1 += Replicate (" ", AT('ATUAL',Cabec2) - len(Cabec1) + 9 )
Cabec1 += IIF (nMesPrv < 3,"QTD PEDI","QTD PEDIDA X ENTREGA PREVISTA")

aMesPrv := {}

For i = 1 To nMesPrv
	
	nAno := IIf (Month(mv_par04)  + i - 1  > 12, Year(mv_par04) + 1,Year(mv_par04))
	nMes := IIf (Month(mv_par04)  + i - 1 > 12,Month(mv_par04) + (i - 1) - 12,Month(mv_par04)+ (i - 1) )
	
	
	aAdd( aMesPrv, '   ' + _aMesExt[ nMes ] + '/' + StrZero(nAno,4) )
	
	Cabec2 += aMesPrv[i]
	AADD(_CabExc,{aMesPrv[ i ]})
	
Next
////////////////////////////////////////////////
_fSB2 := xFilial( "SB2" )
_fSB1 := xFilial( "SB1" )

M_Pag := 1

Cabec2 += "   Sld/Futuro"       // Alterado por Ewerton, 08/04/16 - I1603-1376
AADD(_CabExc,{"SLD. FUTURO"})   // Alterado por Ewerton, 08/04/16 - I1603-1376

//	@ 0,0 PSAY Chr( 27 ) + '@' + Chr( 27 ) + 'M' + Chr( 15 )

// map
//                   CODIGO  DESCRICAO                                 UM    MES/YEAR   MES/YEAR   MES/YEAR   MES/YEAR   MES/YEAR      MEDIA SLD. ATUAL     MES/YEAR   MES/YEAR   MES/YEAR   MES/YEAR   MES/YEAR   MES/YEAR   MES/YEAR   MES/YEAR
//					  12345  1234567890123456789012345678901234567890  12  1234567890 1234567890 1234567890 1234567890 1234567890   12345678 1234567890   1234567890 1234567890 1234567890 1234567890 1234567890 1234567890 1234567890 1234567890
//					  1      8                                         49  51         61        5         6         7         8         9        10        11        12        13        14        15        16        17        18        19
//					 01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890

_nLin := Cabec( ctitulo, cabec1, cabec2, nomeprog, tamanho, 1 )
//	 oReport:SetCustomText( {|| xaca })
++_nLin
//>--
////////////////////
/// SESSAO 1////////
////////////////////


oSection1:Init()

oSection1:Cell("D2_COD"):SetValue(ALLTRIM(_CabExc[1][1]))
AADD(xacab,{_CabExc[1][1]})
oSection1:Cell("B1_DESC"):SetValue(ALLTRIM(_CabExc[2][1]))
AADD(xacab,{_CabExc[2][1]})
oSection1:Cell("D2_UM"):SetValue(ALLTRIM(_CabExc[3][1]))
AADD(xacab,{_CabExc[3][1]})
fk=Month(mv_par03)
h=1
xp=4
FOR h=1 to _nMeses
	oSection1:Cell("MES"+cvaltochar(fk)):SetValue(ALLTRIM(_CabExc[xp][1]))
	AADD(xacab,{_CabExc[xp][1]})
	if fk =12
		fk=0
	endif
	fk++
	xp++
	iF h >= 11
		exit
	eNDIF
	
NEXT
h=0
h=xp
oSection1:Cell("MEDIA"):SetValue(ALLTRIM(_CabExc[h][1]))
oSection1:Cell("MEDIA"):SetAlign("CENTER")
AADD(xacab,{_CabExc[h][1]})
h++
oSection1:Cell("SALDO"):SetValue(ALLTRIM(_CabExc[h][1]))
oSection1:Cell("SALDO"):SetAlign("CENTER")
AADD(xacab,{_CabExc[h][1]})
h++
oSection1:Cell("SALDOM"):SetValue(ALLTRIM(_CabExc[h][1]))
oSection1:Cell("SALDOM"):SetAlign("CENTER")
AADD(xacab,{_CabExc[h][1]})
hx=0
fkx=1
h++
FOR hx=1 to nMesPrv
	oSection1:Cell("ENTR"+cvaltochar(fkx)):SetValue(ALLTRIM(_CabExc[h][1]))
	oSection1:Cell("ENTR"+cvaltochar(fkx)):SetAlign("CENTER")
	AADD(xacab,{_CabExc[h][1]})
	fkx++
	h++
NEXT
oSection1:Cell("FUTURO"):SetValue(ALLTRIM(_CabExc[h][1]))
oSection1:Cell("FUTURO"):SetAlign("CENTER")
AADD(xacab,{_CabExc[h][1]})
oSection1:Printline()
oSection1:SetPageBreak(.T.)
oSection1:HeaderBreak(.T.)

////////////////////////////////////////////////////////////////////
/////////////////////   S E Ç A O  2 ///////////////////////////////
////////////////////////////////////////////////////////////////////


oSection2:Init()
While !SB1->( Eof() ) .And.;
	SB1->B1_COD <= MV_PAR02 .And.;
	SB1->B1_FILIAL == xFilial("SB1")
	
	//SB2->( dbSeek( _fSB2 + SB1->B1_Cod + "01") )
	
	If SB1->B1_MSBLQL == '1'
		SB1->(dbSkip())
	Else
		
		oSection2:Cell("D2_COD"):SetValue(Substr( SB1->B1_Cod , 1, 6 ))
		oSection2:Cell("B1_DESC"):SetValue(Substr( SB1->B1_Desc, 1, 40 ))
		oSection2:Cell("D2_UM"):SetValue(SB1->B1_UM)
		AADD(aDados1,Substr( SB1->B1_Cod , 1, 6 ))
		AADD(aDados1,Substr( SB1->B1_Desc, 1, 40))
		AADD(aDados1,SB1->B1_UM)
		
		_nMes 	:= Month( mv_par03 )
		_qMes 	:= {}
		_qMed 	:= 0
		aQtdPrv := {}
		nMes 	:= 0
		
		For i = 1 To _nMeses
			
			aAdd( _qMes  , { _nMes, 0, 0 } )
			If Len(_aTotCom) < _nMeses                    // Alterado por Ewerton, 12/01/16.
				aAdd( _aTotCom , { _nMes , 0 , 0 , 0 } )  // Alterado por Ewerton, 12/01/16.
			EndIf                                         // Alterado por Ewerton, 12/01/16.
			_nMes ++
			
			If _nMes > 12
				
				_nMes := 1
				
			EndIf
			
		Next
		
		For i = 1 To nMesPrv
			nMes := IIf (Month(mv_par04)  + (i-1) > 12,Month(mv_par04) + (i-1)- 12,Month(mv_par04)+(i-1))
			aAdd( aQtdPrv  , {nMes, 0} )
			If Len(_aTotVen) < nMesPrv                  // Alterado por Ewerton, 12/01/16.
				aAdd( _aTotVen , { nMes , 0 , 0 } )		// Alterado por Ewerton, 12/01/16.
			EndIf                                       // Alterado por Ewerton, 12/01/16.
		Next
		
		aSort(aMovtos)
		
		For n:= 1 To Len(aMovtos)
			
			_cCod := aMovtos[n][1]
			
			If _cCod = SB1->B1_COD
				If _cCod == aMovtos[n][1]
					
					_nMes := Substr( aMovtos[n][2], 5, 2 )
					_nMes := Val( _nMes )
					_nLen := aScan( _qMes, { |x| x[ 1 ] = _nMes } )
					
					_qMes[_nLen][2] += aMovtos[n][3]
					_qMed += aMovtos[n][3]
					
				EndIf
				_vCod := _cCod
			EndIf
			
		Next
		
		//		End
		
		_nCol := 50
		_nMes := Month( mv_par03 )
		_qMed /= _nMeses
		//oReport:lBold := .F. --Thiago Rocco
		//oReport:lUnderLine := .F.
		fk=	_nMes
		For i = 1 To _nMeses
			
			_nCol += 1
			//	@ _nLin, _nCol PSAY _qMes[ i ][ 2 ] Font oFont1  Picture '@E 99,999,999'
			ind=_qMed/ _qMes[ i ][ 2 ]
			
			
		   //	if ind < 1
				
				oSection2:Cell("MES"+cvaltochar(_nMes)):SetValue(ALLTRIM(Transform( _qMes[ i ][ 2 ],"@E 99,999,999")))
				oSection2:Cell("MES"+cvaltochar(_nMes)):SetAlign("RIGHT")
				oSection2:Cell("MES"+cvaltochar(_nMes)):lBold:= .F.
				
			//endif
			
			
			
			_aTotCom[ i ][ 2 ] += _qMes[  i ][ 2 ] // Alterado por Ewerton, 12/01/16.
			
			_aTotCom[ i ][ 4 ] := _nCol            // Alterado por Ewerton, 12/01/16.
			AADD(aDados1,_qMes[  i ][ 2 ] )
			_nCol += 10
			
			
			_nMes ++
			
			If _nMes > 12
				
				_nMes := 1
				
			End
			
		Next
		
		//	_qMed /= _nMeses
		_nCol += 3
		
		//	@ _nLin, _nCol PSAY _qMed        Picture '@E 99,999,999'
		oSection2:Cell("MEDIA"):SetValue(ALLTRIM(Transform(_qMed ,"@E 99,999,999")))
		oSection2:Cell("MEDIA"):SetAlign("RIGHT")
		_qMedTot += _qMed    // Alterado por Ewerton, 12/01/16.
		AADD(aDados1,_qMed)
		_nCol += 12
		
		For n:= 1 To Len(aSlds)
			
			_cCod := aSlds[ n ] [ 1 ]
			
			If _cCod = SB1->B1_COD
				If _cCod == SB1->B1_COD
					nSldAtu += aSlds[ n ] [ 2 ]
				EndIf
				_vCod := _cCod
			EndIf
			
		Next
		
		
		//-- Alterado por Ewerton, 14/01/16 -- Inicio
		
		If QPRVTRB->CODPROD == SB1->B1_COD
			
			cCod := QPRVTRB->CODPROD
			
			While cCod == QPRVTRB->CODPROD
				nPos := aScan( aQtdPrv, { |x| x[1] == Val(Substr(QPRVTRB->PERIODO,5,2)) })
				If nPos != 0
					aQtdPrv[nPos][2] := QPRVTRB->QTDPREV
				EndIf
				QPRVTRB->( dbSkip() )
			EndDo
			
		EndIf
		
		For i := 1 To nMesPrv
			_nQtdPrv += aQtdPrv[i][2]
		Next i
		//-- Alterado por Ewerton, 14/01/16 -- Fim
		
		//	@ _nLin, _nCol PSAY nSldAtu Picture '@E 99,999,999'
		oSection2:Cell("SALDO"):SetValue(ALLTRIM(Transform(nSldAtu,'@E 99,999,999')))
		oSection2:Cell("SALDO"):SetAlign("RIGHT")
		AADD(aDados1,nSldAtu)
		_nSldTot += nSldAtu // Alterado por Ewerton, 12/01/16.
		_nCol += 10
		
		_nCol += 2
		//	@ _nLin, _nCol PSAY NOROUND(nSldAtu / _qMed, 1) Picture '@E 99999.9'
		//If NOROUND(nSldAtu / _qMed, 1)  > 0
   		If NOROUND(nSldAtu / _qMed, 1)  > 0
			oSection2:Cell("SALDOM"):SetValue(ALLTRIM(Transform(NOROUND(nSldAtu / _qMed, 1) ,'@E 99999.9')))
		Else
			oSection2:Cell("SALDOM"):SetValue(ALLTRIM(Transform(NOROUND(nSldAtu / _qMed, 1) ,'@E 9')))
		EndIf
		oSection2:Cell("SALDOM"):SetAlign("RIGHT")
		

		If (nSldAtu / _qMed) <= 1.5
			oSection2:Cell("SALDOM"):oFontBody:=TFont():New("Courier New",NIL,9,NIL,.T.,NIL,NIL,NIL,NIL,.F./*lUnderline*/,.F./*lItalic*/)
			oSection2:Cell("SALDO"):oFontBody:=TFont():New("Courier New",NIL,9,NIL,.T.,NIL,NIL,NIL,NIL,.F./*lUnderline*/,.F./*lItalic*/)
			oSection2:Cell("MEDIA"):oFontBody:=TFont():New("Courier New",NIL,9,NIL,.T.,NIL,NIL,NIL,NIL,.F./*lUnderline*/,.F./*lItalic*/)
		Else
			oSection2:Cell("SALDOM"):oFontBody:=TFont():New("Courier New",NIL,9,NIL,.F.,NIL,NIL,NIL,NIL,.F./*lUnderline*/,.F./*lItalic*/)
			oSection2:Cell("SALDO"):oFontBody:=TFont():New("Courier New",NIL,9,NIL,.F.,NIL,NIL,NIL,NIL,.F./*lUnderline*/,.F./*lItalic*/)
			oSection2:Cell("MEDIA"):oFontBody:=TFont():New("Courier New",NIL,9,NIL,.F.,NIL,NIL,NIL,NIL,.F./*lUnderline*/,.F./*lItalic*/)
			//oSection2:Cell("MES"+cvaltochar(_nMes-1)):SetClrFore(0)
		EndIf
		AADD(aDados1,NOROUND(nSldAtu / _qMed,1))
		
		
		_nCol   += 5
		/////////////////////////////////
		
		
		//-- Alterado por Ewerton, 30/08/12
		If QPRVTRB->CODPROD == SB1->B1_COD
			
			cCod := QPRVTRB->CODPROD
			
			While cCod == QPRVTRB->CODPROD
				//_nMes := Substr( Prv->Periodo, 5, 2 )
				//_nMes := Val( _nMes )
				nPos := aScan( aQtdPrv, { |x| x[1] == Val(Substr(QPRVTRB->PERIODO,5,2)) })
				If nPos != 0
					aQtdPrv[nPos][2] := QPRVTRB->QTDPREV // new 02-10-09
				EndIf
				QPRVTRB->( dbSkip() )
				
			EndDo
			
		EndIf
		//--
		
		_nCol += 2
		For i = 1 To nMesPrv
			_nCol += 1
			//	@ _nLin, _nCol PSAY aQtdPrv[i][2] Picture '@E 99,999,999'//tm(aQtdPrv[i][2],10,2)//
			
			oSection2:Cell("ENTR"+cvaltochar(i)):SetValue(ALLTRIM(Transform(aQtdPrv[i][2],"@E 99,999,999")))
			oSection2:Cell("ENTR"+cvaltochar(i)):SetAlign("RIGHT")
			_aTotVen[ i ][ 2 ] += aQtdPrv[  i ][ 2 ]  // Alterado por Ewerton, 12/01/16.
			_aTotVen[ i ][ 3 ] := _nCol               // Alterado por Ewerton, 12/01/16.
			AADD(aDados1,aQtdPrv[i][2])
			
		Next
		/////////////////////////////////////
		
		_nCol += 6
		
		//	@ _nLin, _nCol PSAY NOROUND(( nSldAtu + _nQtdPrv )/_qMed, 1) Picture '@E 99999.9'
		oSection2:Cell("FUTURO"):SetValue(ALLTRIM(Transform(NOROUND(( nSldAtu + _nQtdPrv )/_qMed, 1),'@E 99999.9')))
		oSection2:Cell("FUTURO"):SetAlign("RIGHT")
		
		AADD(aDados1,NOROUND(( nSldAtu + _nQtdPrv )/_qMed, 1))
		
		_nLin ++
		
		nSldAtu := 0
		_nQtdPrv := 0 // Alterado por Ewerton, 14/01/16.
		
		SB1->(dbSkip())
		oSection2:Printline()
		oReport:IncMeter()
	EndIf  // new
	
EndDo
oSection2:Finish()

ASIZE(aDados1,Len(aDados1)+3)          	// Alterado por Ewerton, 12/01/16.

For x:= 1 to Len(_aTotCom)             	// Alterado por Ewerton, 12/01/16.
	AADD(aDados1,_aTotCom[x][2])   		// Alterado por Ewerton, 12/01/16.
Next x                                 	// Alterado por Ewerton, 12/01/16.

AADD(aDados1,_qMedTot)                 	// Alterado por Ewerton, 12/01/16.
AADD(aDados1,_nSldTot)			        // Alterado por Ewerton, 08/04/16 - I1603-1376

_nTotSM := _nSldTot/_qMedTot            // Alterado por Ewerton, 12/01/16.
AADD(aDados1,_nTotSM)			        // Alterado por Ewerton, 08/04/16 - I1603-1376

For y:= 1 to nMesPrv	        // Alterado por Ewerton, 12/01/16.
	AADD(aDados1,_aTotVen[y][2])	    // Alterado por Ewerton, 12/01/16.
	_nTotPrv += _aTotVen[ y ][ 2 ]
Next y					                // Alterado por Ewerton, 12/01/16.

_nTotSF := (_nSldTot + _nTotPrv) / _qMedTot  // Alterado por Ewerton, 08/04/16 - I1603-1376
AADD(aDados1,_nTotSF)                        // Alterado por Ewerton, 08/04/16 - I1603-1376

_nTotSM  := 0 // Alterado por Ewerton, 08/04/16 - I1603-1376
_nTotPrv := 0 // Alterado por Ewerton, 08/04/16 - I1603-1376
_nTotSF  := 0 // Alterado por Ewerton, 08/04/16 - I1603-1376

If Select("QRY") > 0
	DbSelectArea("QRY")
	QRY->(DbCloseArea())
EndIf

If Select("Prv") > 0
	DbSelectArea("Prv")
	Prv->(DbCloseArea())
EndIf

If Select("Sld") > 0
	DbSelectArea("Sld")
	Sld->(DbCloseArea())
EndIf

If Select("QRY2") > 0
	DbSelectArea("QRY2")
	QRY2->(DbCloseArea())
EndIf

If Select("Sld2") > 0
	DbSelectArea("Sld2")
	Sld2->(DbCloseArea())
EndIf

//>-- Alterado por Ewerton, 30/08/12
If Select("QPRVTRB") > 0
	DbSelectArea("QPRVTRB")
	QPRVTRB->(DbCloseArea())
EndIf
//>--
oSection1:Finish()

oSection3:Init() 

nRow := oSection3:OREPORT:NROW +20
oFontRel := TFont():New("Courier New",NIL,8,NIL,.F.,NIL,NIL,NIL,NIL,.F./*lUnderline*/,.F./*lItalic*/) 
oReport:Say(nRow,3,"    TOTAIS  ------>",oFontRel,38)
//nCol := 718
nCol := 738 //CADA mudança de tamanho de fonte aumento 20 colunas.
//nCol := 692

For x := 1 To Len(_aTotCom)
	//@ _nLin,_aTotCom[ x ][ 4 ] PSAY _aTotCom[ x ][ 2 ] Picture '@E 99,999,999'
	/*
	
	oSection3:Cell("TOTAL"+cvaltochar(x)):SetValue(Transform(_aTotCom[ x ][ 2 ],'@E 999,999,999'))
	oSection3:Cell("TOTAL"+cvaltochar(x)):SetHeaderAlign("RIGHT")  */
	//Ajustes devido ao proprio TReport desposicionar a impressão quando numerico.
	If x < 3
		oReport:Say(nRow,nCol,Transform(_aTotCom[ x ][ 2 ],'@E 999,999,999'),oFontRel,38)
	EndIf
	If x >= 3 .And. x < 5
		nCol-= x
		oReport:Say(nRow,nCol,Transform(_aTotCom[ x ][ 2 ],'@E 999,999,999'),oFontRel,38)
	EndIf 
	If x >= 5 .And. x < 6
		nCol-= 0.5
		oReport:Say(nRow,nCol,Transform(_aTotCom[ x ][ 2 ],'@E 999,999,999'),oFontRel,38)
	EndIf
	
	If  x >= 6 .And. x < 8
		nCol-=2
		oReport:Say(nRow,nCol,Transform(_aTotCom[ x ][ 2 ],'@E 999,999,999'),oFontRel,38)
	EndIf
	If  x >= 8 .And. x < 10
		nCol-=1.5
		oReport:Say(nRow,nCol,Transform(_aTotCom[ x ][ 2 ],'@E 999,999,999'),oFontRel,38)
	EndIf
	If  x >= 10 .And. x < 11
		nCol-=1.7
		oReport:Say(nRow,nCol,Transform(_aTotCom[ x ][ 2 ],'@E 999,999,999'),oFontRel,38)
	EndIf  
	If  x >= 11
		nCol-=2.2
		oReport:Say(nRow,nCol,Transform(_aTotCom[ x ][ 2 ],'@E 999,999,999'),oFontRel,38)
	EndIf
	
	
	nCol += 173
Next x
nCol -= 16
oReport:Say(nRow,nCol,Transform(_qMedTot,'@E 999,999,999'),oFontRel,38)
nCol+=170
oReport:Say(nRow,nCol,Transform(_nSldTot,'@E 999,999,999'),oFontRel,38)


_nTotSM := _nSldTot / _qMedTot   
nCol+=226
oReport:Say(nRow,nCol,Transform(_nTotSM,"@E 99999.9"),oFontRel,38)

For y := 1 To Len(_aTotVen)
	//	@ _nLin,_aTotVen[ y ][ 3 ] PSAY _aTotVen[ y ][ 2 ] Picture '@E 99,999,999'
	nCol+=173
	oReport:Say(nRow,nCol,Transform(_aTotVen[ y ][ 2 ],'@E 999,999,999'),oFontRel,38)
	_nTotPrv += _aTotVen[ y ][ 2 ]                                          // Alterado por Ewerton, 08/04/16 - I1603-1376
Next y


_nTotSF := (_nSldTot + _nTotPrv) / _qMedTot                                 // Alterado por Ewerton, 08/04/16 - I1603-1376

oReport:ThinLine()

nRow := oSection3:OREPORT:NROW +30
oReport:Say(nRow,1,Replicate("-",3128),oFontRel,38)
oSection3:Finish()

Return
