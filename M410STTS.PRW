#include 'protheus.ch'
#include 'parmtype.ch'

//--------------------------------------------------------------------
/*/{Protheus.doc} M410STTS
Este ponto de entrada pertence à rotina de pedidos de venda, MATA410().
Está em todas as rotinas de inclusão, alteração, exclusão, cópia e devolução de compras.
Executado após todas as alterações no arquivo de pedidos terem sido feitas.
Parâmetros:
nOper --> Tipo: Numérico - Descrição: Operação que está sendo executada, sendo:
3 - Inclusão
4 - Alteração
5 - Exclusão
6 - Cópia
7 - Devolução de Compras
@author Caio Menezes
@since 06/02/2020
@version 1.0
@type function
Retorno
3 - Inclus�o
4 - Altera��o
5 - Exclus�o
6 - C�pia
7 - Devolu��o de Compras
/*/
//--------------------------------------------------------------------

User Function M410STTS()

Local nOpc   := PARAMIXB[1] 
Local lRet   :=.T.
Local cFilSC5	:= xFilial("SC5")
Local lRet		:= .T.
Local cNumPed	:= SC5->C5_NUM
Local nQtdLib	:= 0
Local cFilNLib	:= SuperGetMV("FS_FILNLIB",.F.,"04")
//teste	
	
If SA1->(FieldPos("A1_XAVALOT")) > 0
	U_B4BAVLOT(xFilial("SC5"),SC5->C5_NUM)
EndIf

If nOpc == 6
	Reclock("SC5",.F.)
	SC5->C5_XUSRLIB := ""
	SC5->C5_XDTLIB  := CTOD("  /  /    ")
	SC5->C5_XTIPOL  := ""
	SC5->C5_XMOTLIB := ""
	SC5->C5_XDTBLQ  := CTOD("  /  /    ")
	SC5->(MsUnlock())
EndIf

/*
If !(SC5->C5_FILIAL $ cFilNLib) .AND. !IsInCallStack("U_INTRJ")
	
	If nOpc == 3 .Or. nOpc == 4 .Or. nOpc == 6
	
		dbSelectArea("SC6")

		If SC6->(DBSeek(SC5->C5_FILIAL + SC5->C5_NUM))
			While SC6->(!EOF()) .And. SC6->C6_NUM == cNumPed
				nQtdLib := MaLibDoFat(SC6->(RecNo()),SC6->C6_QTDVEN,,,.T.,.T.,.F.,.F.)
				SC6->(dBSkip())
			EndDo
			RecLock("SC5",.F.)
			SC5->C5_LIBEROK := "S"
			SC5->(MsUnlock())
		EndIf

	EndIf

EndIF
*/

If nOpc == 3 .Or. nOpc == 4 
	
	EspVol()

EndIf

If nOpc == 5  //exclusao

	GeraPR1()

Endif

Return(lRet)

//--------------------------------------------------------------------
/*/{Protheus.doc} GeraPR1
Grava registro na tabela de integração para cancelar 
pré nota no Transpofrete
@author Caio Menezes
@since 07/03/2020
@version 1.0 
@type function
/*/
//--------------------------------------------------------------------

Static Function GeraPR1()

Local aArea    := GetArea()
Local lReclock := .T.

	If Select("PR1") == 0
		dBSelectArea("PR1")
	Endif
	
	PR1->(dbSetOrder(2)) //PR1_FILIAL + PR1_ALIAS + PR1_CHAVE
	
	If ChkObs()
		
		lReclock := !PR1->(dbSeek(xFilial("PR1")+"SC5"+SC5->(C5_FILIAL+C5_NUM)))
		
		If RecLock("PR1",lReclock)
		
			PR1->PR1_FILIAL := xFilial("PR1")
			PR1->PR1_ALIAS  := "SC5"
			PR1->PR1_RECNO  := SC5->(Recno())
			PR1->PR1_TIPREQ := "5"
			PR1->PR1_DATINT := Date()
			PR1->PR1_HRINT	:= Time()		
			PR1->PR1_STINT  := "P"
			PR1->PR1_CHAVE  := SC5->(C5_FILIAL+C5_NUM)
			
			PR1->(MsUnlock())
			
		Endif
		
	Endif 

	RestArea(aArea)

Return(Nil)

//--------------------------------------------------------------------
/*/{Protheus.doc} ChkObs
//TODO Descrição auto-gerada.
@author Caio
@since 06/02/2020
@version 1.0
@type function
/*/
//--------------------------------------------------------------------

Static Function ChkObs()

Local aArea    := GetArea()
Local lRet     := .F.
Local cQuery   := ""
Local cWa      := ""  

	cQuery += CRLF + RTrim(" SELECT COUNT(*) AS QTD                                     ")
    cQuery += CRLF + RTrim("   FROM " + RETSQLNAME("PR1") + " PR1                       ")
    cQuery += CRLF + RTrim("  WHERE PR1.PR1_FILIAL  = '" + xFilial("PR1")          + "' ")
    cQuery += CRLF + RTrim("    AND PR1.PR1_CHAVE   = '" + SC5->(C5_FILIAL+C5_NUM) + "' ")
    cQuery += CRLF + RTrim("    AND PR1.PR1_OBSERV <> ' '                               ")
    
    cQuery := ChangeQuery(cQuery)
    
    dbUseArea(.T.,"TOPCONN",TCGenQry(,,(cQuery := /*ChangeQuery(*/cQuery/*)*/)),(cWa := GetNextAlias()),.T.,.T.)
     
    lRet := (cWa)->QTD > 0
    
    dbCloseArea()
    
    RestArea(aArea)
    
Return(lRet)

//

//

Static Function EspVol()
	Local cQuery    := ''
	Local nQtdVol 	:= 0
	Local cAliasQry := "TMP"
	Local _aArea1   := GetArea()

	If Select(cAliasQry) != 0
		(cAliasQry)->(DbCloseArea())
	EndIf

	cQuery := "SELECT SC6.C6_PRODUTO AS Produto,SUM (SC6.C6_QTDVEN) as Quant,  "
	cQuery += "SB1.B1_QE As QE, SB1.B1_UM As UM "
	cQuery += "FROM " + RetSqlName("SC6") + " SC6 "
	cQuery += "INNER JOIN " + RetSqlName("SB1") + " SB1 ON "
	cQuery += "SC6.C6_PRODUTO = SB1.B1_COD "
	cQuery += "INNER JOIN " + RetSqlName("SF4") + " SF4 ON "
	cQuery += "SC6.C6_TES = SF4.F4_CODIGO "
	cQuery += "WHERE "
	cQuery += "SC6.D_E_L_E_T_ = ' ' AND SB1.D_E_L_E_T_ = ' ' AND "
	cQuery += "SF4.D_E_L_E_T_ = ' ' AND "
	cQuery += "SC6.C6_FILIAL  = '" + SC5->C5_FILIAL  + "' AND "
	cQuery += "SC6.C6_CLI     = '" + SC5->C5_CLIENTE + "' AND "
	cQuery += "SC6.C6_LOJA    = '" + SC5->C5_LOJACLI    + "' AND "
	//cQuery += "SC6.C6_SERIE   = '" + SF2->F2_SERIE   + "' AND "
	cQuery += "SC6.C6_NUM     = '" + SC5->C5_NUM     + "' AND "
	//cQuery += "SC6.D2_TIPO    = '" + SF2->F2_TIPO    + "' AND "
	cQuery += "SF4.F4_ESTOQUE = 'S' "
	cQuery += "GROUP BY SC6.C6_PRODUTO, SB1.B1_QE, SB1.B1_UM "
	cQuery += "ORDER BY SC6.C6_PRODUTO "

	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery), cAliasQry)

	While (cAliasQry)->(!Eof())
		If !Empty((cAliasQry)->QE)
			If Alltrim((cAliasQry)->UM) <> "CX"
				nQtdVol	+= Int((cAliasQry)->Quant / (cAliasQry)->QE)
				If Mod((cAliasQry)->Quant, (cAliasQry)->QE) > 0
					nQtdVol++
				EndIf
			Else
				nQtdVol += (cAliasQry)->Quant
			EndIf
		EndIf
		(cAliasQry)->(dbSkip())
	EndDo
	
	If nQtdVol > 0
		SC5->(RecLock('SC5', .F.))	
		Replace SC5->C5_ESPECI1 With 'Caixa(s)'
		Replace SC5->C5_VOLUME1 With nQtdVol
		SC5->(MSUnLock())
	EndIf

	(cAliasQry)->(DbCloseArea())
	RestArea(_aArea1)

Return()
