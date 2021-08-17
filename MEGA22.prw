#IFNDEF WINDOWS
	#DEFINE PSAY SAY
#ENDIF

#Include "rwmake.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ MEGA22   ³ Autor ³Eletromega             ³ Data ³18/10/2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ RELA€ŽO DE VENDA MENSAL POR PRODUTO                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Utilidade ³ Imprime a Totalizacao das Vendas de um Determinado Produto ³±±
±±³          ³ Durante um Periodo Pr‚ Estabelecido.                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Eletromega                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros                         ³
//³ mv_par01             // Do Produto                           ³
//³ mv_par02             // Ate o Produto                        ³
//³ mv_par03             // Data Inicial                         ³
//³ mv_par04             // Data final                           ³
//³ mv_par04             // almoxarifado                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
User Function MEGA22

Private CbTxt	 := ""
Private CbCont	 := ""
Private nOrdem 	 := 0
Private Alfa 	 := 0
Private Z		 := 0
Private M		 := 0
Private tamanho	 := "G"
Private limite   := 254
Private titulo 	 := PADC("MEGA22 - Consumo Mensal X Previsao da Entrega ",75)
Private cDesc1 	 := PADC("Este Programa ira emitir o Relatorio de Totais de Venda por Produto",75)
Private cDesc2 	 := PADC("e a data prevista para a entrega do material solicitado            ",75)
Private cDesc3 	 := PADC("                                                                   ",75)
Private aReturn  := { "Especial" , 1, "Diretoria" , 2, 2, 1,"", 0 }
Private nomeprog := "MEGA22"
Private cPerg    := "MEGA21"
Private nLastKey := 0
Private Li       := 0
Private xPag     := 1
Private wnrel    := "MEGA22"
Private _EmpAtu  := "01"
Private aMovtos  := {}
Private aSlds    := {}
Private _lPas2   := .T.

Pergunte(cPerg,.F.)

Private cString:="SB1"

wnrel:=SetPrint(cString,wnrel,cPerg,Titulo,cDesc1,cDesc2,cDesc3,.T.)
If nLastKey == 27
	Return
Endif

SetDefault(aReturn,cString)
If nLastKey == 27
	Return
Endif

RptStatus({|| RptDetail() })

Return

Static Function RptDetail

Local aStrS 	:= {} // Alterado por Claudino, 30/08/12. 
Local aStrQ 	:= {} // Alterado por Claudino, 30/08/12.
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
Local _nReg     := 0 // Alterado por Claudino, 30/08/12.
Local _QtdPrev  := 0 // Alterado por Claudino, 30/08/12.

Private cArqTrb1 := CriaTrab(NIL,.F.) // Alterado por Claudino, 30/08/12.
Private cArqTrb2 := CriaTrab(NIL,.F.) // Alterado por Claudino, 30/08/12.

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

//>-- Alterado por Claudino, 30/08/12.
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
		_cQry += "AND (D2_COD BETWEEN '" + Substr( MV_PAR01, 1, 5 ) + "' AND '" + Substr( MV_PAR02, 1, 5 ) + "') "
		
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
			_cQry2 := "SELECT D2_COD AS Codigo, SUBSTRING(D2_EMISSAO, 1, 6) AS Periodo, "
			_cQry2 += "SUM(D2_QUANT) AS Qde, D2_LOCAL AS Loc "
			_cQry2 += "FROM  SD2" + SM0->M0_CODIGO +"0 SD2 INNER JOIN SB1010 SB1 ON D2_COD = B1_COD "
			_cQry2 += "INNER JOIN SF2" + SM0->M0_CODIGO +"0 SF2 ON F2_SERIE = D2_SERIE AND F2_DOC = D2_DOC "
			_cQry2 += "AND F2_CLIENTE = D2_CLIENTE AND F2_LOJA = D2_LOJA "
			_cQry2 += "INNER JOIN SF4" + SM0->M0_CODIGO +"0  SF4 ON F4_CODIGO = D2_TES "
			_cQry2 += "WHERE (SUBSTRING(D2_EMISSAO, 1, 6) BETWEEN '" + _pIni + "' AND '" + _pFim + "') "
			_cQry2 += "AND (D2_LOCAL = '" + MV_PAR05 + "') AND (SD2.D_E_L_E_T_ <> '*') AND (D2_TIPO = 'N') "
			_cQry2 += "AND (D2_COD BETWEEN '" + Substr( MV_PAR01, 1, 5 ) + "' AND '" + Substr( MV_PAR02, 1, 5 ) + "') "
			
			If MV_PAR06 == MV_PAR07
				_cQry2 += "AND (D2_FILIAL BETWEEN '" + MV_PAR08 + "' AND '" + MV_PAR09 + "') "
				_cQry2 += "AND (F2_FILIAL BETWEEN '" + MV_PAR08 + "' AND '" + MV_PAR09 + "') "
			EndIf
			
			_cQry2 += "AND D2_TIPO = F2_TIPO "
			_cQry2 += "AND SB1.D_E_L_E_T_ <> '*' AND SF2.D_E_L_E_T_ <> '*' AND B1_MSBLQL <> '1' "
			
			If Len(cQAdd) > 2
				_cQry2 += "AND NOT" + cQAdd + " "
			EndIf
			
			_cQry2 += "AND SF4.D_E_L_E_T_ <> '*' AND F4_ESTOQUE = 'S' "
			_cQry2 += "GROUP  BY D2_COD, SUBSTRING(D2_EMISSAO, 1, 6), D2_LOCAL "
			dbUseArea( .T., "TOPCONN", TCGENQRY(,,_cQry2), 'Qry2' )
			_EmpAtu := "03"
			_lPas2 := .F.
		EndIf
	EndIf
	
	SM0->(DbSkip())
	
End

_nRegua := 0

If AllTrim(MV_PAR06) = "" .Or.  MV_PAR06 = "01"
	
	DbSelectArea("QRY")
	While ! Eof()
		AADD(aMovtos,{QRY->CODIGO,QRY->PERIODO,QRY->QDE,QRY->LOC})
		Qry->( dbSkip() )
		_nRegua ++
	End
EndIf


If _EmpAtu =="03"
	
	DbSelectArea("QRY2")
	While ! Eof()
		
		AADD(aMovtos,{QRY2->CODIGO,QRY2->PERIODO,QRY2->QDE,QRY2->LOC})
		Qry2->( dbSkip() )
		_nRegua ++
	End
	
Endif

SetRegua( _nRegua )

_EmpAtu := "01"
_lPas2 := .T.

// Previsao de Entrega
//nMesPrv := 12 - _nMeses 05-07-2011
nMesPrv := 12 - _nMeses // We can display a maximum of 13 fields (consumo + previsao)
nAno 	:= IIf (Month(mv_par04) - 1 == 0, Year(mv_par04) - 1,Year(mv_par04))
nMes 	:= IIf (Month(mv_par04) - 1 == 0, 12,Month(mv_par04))
cIni 	:= strzero(nAno,4) + strzero(nMes,2)

nAno := IIf (Month(mv_par04)  + nMesPrv  > 12, Year(mv_par04) + 1,Year(mv_par04))
nMes := IIf (Month(mv_par04)  + nMesPrv  > 12,Month(mv_par04) + nMesPrv - 12,Month(mv_par04) + nMesPrv - 1)
cFim := strzero(nAno,4) + strzero(nMes,2)

/* Alterado por Claudino, 30/08/12.				
QryPrv := " SELECT "
QryPrv += " Codigo, Periodo, SUM(QtdPrev)  AS QtdPrev " 
QryPrv += " FROM (SELECT  W7_COD_I As Codigo, (W7_QTDE - ISNULL(WN_QUANT,0)) As QtdPrev,  SUBSTRING(W6_PRVENTR, 1, 6) As Periodo "
QryPrv += " FROM " +RetSqlName("SW7") + " SW7 "
QryPrv += " INNER JOIN  " +RetSqlName("SW6") + " SW6 "
QryPrv += " ON W7_HAWB = W6_HAWB " 
QryPrv += " INNER JOIN  " +RetSqlName("SW3") + " SW3 "
QryPrv += " ON W7_PO_NUM = W3_PO_NUM AND W7_COD_I = W3_COD_I  AND W7_PGI_NUM = W3_PGI_NUM "
QryPrv += " INNER JOIN  SB1010 SB1 "
QryPrv += " ON W7_COD_I = B1_COD " 
QryPrv += " LEFT OUTER JOIN " +RetSqlName("SWN") + " SWN "
QryPrv += " ON W7_HAWB = WN_HAWB AND W7_PO_NUM = WN_PO_NUM AND W7_COD_I = WN_PRODUTO "
QryPrv += " AND W7_PGI_NUM = WN_PGI_NUM " 
QryPrv += " AND WN_TIPO_NF = '1' "
QryPrv += " AND SWN.D_E_L_E_T_ = ' '"
QryPrv += " WHERE"
QryPrv += " SW7.D_E_L_E_T_ = ' ' "
QryPrv += " AND SW6.D_E_L_E_T_ = ' ' "
QryPrv += " AND SW3.D_E_L_E_T_ = ' ' "
QryPrv += " AND SB1.D_E_L_E_T_ = ' ' "
QryPrv += " AND SUBSTRING(W6_PRVENTR,1,6) BETWEEN '" + cIni + "' AND '" + cFim + "' "
QryPrv += " AND (W7_COD_I BETWEEN '" + Substr( MV_PAR01, 1, 5 ) + "' AND '" + Substr( MV_PAR02, 1, 5 ) + "') "
QryPrv += " AND B1_MSBLQL <> '1' "
QryPrv += " GROUP  BY W7_COD_I, W7_QTDE, WN_QUANT, SUBSTRING(W6_PRVENTR, 1, 6))a GROUP BY Codigo, Periodo ORDER BY Codigo"
*/      

QryPrv := " SELECT "
QryPrv += " W7_PO_NUM As NumPO, W7_HAWB As Processo, W7_COD_I As Codigo, W7_QTDE As QtdEmb, SUBSTRING(W6_PRVENTR, 1, 6) As Periodo "
QryPrv += " FROM " + RetSqlName("SW7") + " SW7 "
QryPrv += " INNER JOIN  " + RetSqlName("SW6") + " SW6 "  
QryPrv += " ON W7_HAWB = W6_HAWB "
QryPrv += " INNER JOIN  " + RetSqlName("SW3") + " SW3 "  
QryPrv += " ON W7_PO_NUM = W3_PO_NUM AND W7_COD_I = W3_COD_I  AND W7_PGI_NUM = W3_PGI_NUM "
QryPrv += " INNER JOIN  " + RetSqlName("SB1") + " SB1 " 
QryPrv += " ON W7_COD_I = B1_COD "
QryPrv += " WHERE "
QryPrv += " SW7.D_E_L_E_T_ = ' ' " 
QryPrv += " AND SW6.D_E_L_E_T_ = ' ' "
QryPrv += " AND SW3.D_E_L_E_T_ = ' ' "
QryPrv += " AND SB1.D_E_L_E_T_ = ' ' "
QryPrv += " AND SUBSTRING(W6_PRVENTR,1,6) "
QryPrv += " BETWEEN '" + cIni + "' AND '" + cFim + "' "
QryPrv += " AND (W7_COD_I BETWEEN '" + Substr( MV_PAR01, 1, 5 ) + "' AND '" + Substr( MV_PAR02, 1, 5 ) + "') "
QryPrv += " AND B1_MSBLQL <> '1' "  
QryPrv += " GROUP  BY W7_PO_NUM, W7_HAWB, W7_COD_I, W7_QTDE, SUBSTRING(W6_PRVENTR, 1, 6) "
QryPrv += " ORDER BY W7_COD_I , SUBSTRING(W6_PRVENTR, 1, 6) "

MEMOWRITE("E:\TESTESQL.SQL",QryPrv)

dbUseArea( .T., "TOPCONN", TCGENQRY(,,QryPrv), 'Prv')

//>---- Alteração feita por Claudino, 30/08/12. 
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
		
		cQrySld := "SELECT B1_COD As Cod,SUM(B2_QATU)As Sld "
		cQrySld += "FROM SB1010 SB1 INNER JOIN SB2" + SM0->M0_CODIGO +"0 SB2 ON B1_COD = B2_COD "
		cQrySld += "WHERE (B1_COD BETWEEN '" + Substr( MV_PAR01, 1, 5 ) + "' AND '" + Substr( MV_PAR02, 1, 5 ) + "') "
		cQrySld += "AND B2_LOCAL IN ('01','98') "
		If MV_PAR06 == MV_PAR07
			cQrySld += "AND (B2_FILIAL BETWEEN '" + MV_PAR08 + "' AND '" + MV_PAR09 + "')
		EndIf
		cQrySld += "AND SB1.D_E_L_E_T_ <> '*' AND SB2.D_E_L_E_T_ <> '*' AND B1_MSBLQL <> '1' "
		cQrySld += "GROUP  BY B1_COD "
		cQrySld += "ORDER BY B1_COD "
		
		dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQrySld), 'Sld' )
		_EmpAtu:=  "02"
   
	Else		

		If MV_PAR06 = "02"
			_EmpAtu :=  "02"
		EndIf	   
		
		If SM0->M0_CODIGO >= MV_PAR06 .And. SM0->M0_CODIGO <= MV_PAR07 .And. SM0->M0_CODIGO == "02" .And. _EmpAtu == "02" .And. _lPas2

				//Seleciona os saldos da empresa 02
			cQrySld2 := "SELECT B1_COD As Cod,SUM(B2_QATU)As Sld "
			cQrySld2 += "FROM SB1010 SB1 INNER JOIN SB2" + SM0->M0_CODIGO +"0 SB2 ON B1_COD = B2_COD "
			cQrySld2 += "WHERE (B1_COD BETWEEN '" + Substr( MV_PAR01, 1, 5 ) + "' AND '" + Substr( MV_PAR02, 1, 5 ) + "') "
			cQrySld2 += "AND B2_LOCAL IN ('01','98') "
			If MV_PAR06 == MV_PAR07
				cQrySld2 += "AND (B2_FILIAL BETWEEN '" + MV_PAR08 + "' AND '" + MV_PAR09 + "')
			EndIf
			cQrySld2 += "AND SB1.D_E_L_E_T_ <> '*' AND SB2.D_E_L_E_T_ <> '*' AND B1_MSBLQL <> '1' "
			cQrySld2 += "GROUP  BY B1_COD "
			cQrySld2 += "ORDER BY B1_COD "
			
			dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQrySld2), 'Sld2' )
			
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


@ 0,0 PSAY Chr( 27 ) + '@' + Chr( 27 ) + 'M' + Chr( 15 )

// map
//                   CODIGO  DESCRICAO                                 UM    MES/YEAR   MES/YEAR   MES/YEAR   MES/YEAR   MES/YEAR      MEDIA SLD. ATUAL     MES/YEAR   MES/YEAR   MES/YEAR   MES/YEAR   MES/YEAR   MES/YEAR   MES/YEAR   MES/YEAR
//					  12345  1234567890123456789012345678901234567890  12  1234567890 1234567890 1234567890 1234567890 1234567890   12345678 1234567890   1234567890 1234567890 1234567890 1234567890 1234567890 1234567890 1234567890 1234567890
//					  1      8                                         49  51         61        5         6         7         8         9        10        11        12        13        14        15        16        17        18        19
//					 01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890

_nLin := Cabec( ctitulo, cabec1, cabec2, nomeprog, tamanho, 1 )
++_nLin

While !SB1->( Eof() ) .And.;
	SB1->B1_COD <= MV_PAR02 .And.;
	SB1->B1_FILIAL == xFilial("SB1")
	
	If _nLin > 60 //58
		_nLin := Cabec( ctitulo, cabec1, cabec2, nomeprog, tamanho, 1 )
		_nLin += 2
	EndIf
	
	//SB2->( dbSeek( _fSB2 + SB1->B1_Cod + "01") )
	
	If SB1->B1_MSBLQL == '1'
		SB1->(dbSkip())
	Else  // new
		@ _nLin,001 PSAY Substr( SB1->B1_Cod , 1, 6 )
		@ _nLin,008 PSAY Substr( SB1->B1_Desc, 1, 40 )
		@ _nLin,049 PSAY SB1->B1_UM
		
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
			_nMes ++
			
			If _nMes > 12
				
				_nMes := 1
				
			EndIf
			
		Next
		
		For i = 1 To nMesPrv
			nMes := IIf (Month(mv_par04)  + (i-1) > 12,Month(mv_par04) + (i-1)- 12,Month(mv_par04)+(i-1))
			aAdd( aQtdPrv  , {nMes, 0} )
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
			
		IncRegua()
			
//		End
		
		_nCol := 50
		_nMes := Month( mv_par03 )
		
		For i = 1 To _nMeses
			
			_nCol += 1
			@ _nLin, _nCol PSAY _qMes[  i ][ 2 ] Picture '@E 99,999,999'
			AADD(aDados1,_qMes[  i ][ 2 ] )
			_nCol += 10
			
			
			_nMes ++
			
			If _nMes > 12
				
				_nMes := 1
				
			End
			
		Next
		
		_qMed /= _nMeses
		_nCol += 3
		
		@ _nLin, _nCol PSAY _qMed        Picture '@E 99,999,999'
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
/*		If Sld->Cod == SB1->B1_COD
			//
			While !EOF() .And. Sld->Cod == SB1->B1_COD
				nSldAtu += Sld->Sld
				Sld->(dbSkip())
			End
			//
		EndIf*/
		
		@ _nLin, _nCol PSAY nSldAtu Picture '@E 99,999,999'
		AADD(aDados1,nSldAtu)
		_nCol += 10
		
		_nCol += 2
		@ _nLin, _nCol PSAY NOROUND(nSldAtu/_qMed, 0) Picture '@E 999,999'

		AADD(aDados1,noRound(nSldAtu/_qMed,0))

		nSldAtu := 0
		_nCol   += 5
		/////////////////////////////////
		
		/* Alterado por Claudino, 30/08/12.
		If Prv->Codigo == SB1->B1_COD
			
			cCod := Prv->Codigo
			
			While cCod == Prv->Codigo
				//_nMes := Substr( Prv->Periodo, 5, 2 )
				//_nMes := Val( _nMes )
				nPos := aScan( aQtdPrv, { |x| x[1] == Val(Substr(Prv->Periodo,5,2)) })
				If nPos != 0
					aQtdPrv[nPos][2] := Prv->QtdPrev // new 02-10-09
				EndIf
				Prv->( dbSkip() )
				IncRegua()
			EndDo
			
		EndIf
		*/

		//-- Alterado por Claudino, 30/08/12
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
				IncRegua()
			EndDo
			
		EndIf
		//-- 
		
		_nCol += 2
		For i = 1 To nMesPrv
			_nCol += 1
			@ _nLin, _nCol PSAY aQtdPrv[i][2] Picture '@E 99,999,999'//tm(aQtdPrv[i][2],10,2)//
			AADD(aDados1,aQtdPrv[i][2])
			_nCol += 10
		Next
		/////////////////////////////////////
		_nLin ++
		
		SB1->(dbSkip())
	EndIf  // new
EndDo
If MV_PAR10 == 2
	U_Excmg21(titulo,_CabExc,aDados1)
EndIf

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

//>-- Alterado por Claudino, 30/08/12
If Select("QPRVTRB") > 0
	DbSelectArea("QPRVTRB")
	QPRVTRB->(DbCloseArea())
EndIf
//>--

MS_FLUSH()

Set Device To Screen
Set Printer To

If aReturn[5] == 1
	
	dbcommitAll()
	ourspool(wnrel)
	
EndIf

Return(Nil)