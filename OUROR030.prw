#Include "rwmake.ch"
#Include "protheus.ch"
#Include "totvs.ch"

#IFNDEF WINDOWS
	#DEFINE PSAY SAY
#ENDIF

#DEFINE COMP_DATE "20211011"
#DEFINE PICT_CUB  "@E 99,999,999.99"

/*
Rotina: OUROR030
Descricao: Relatorio de venda mensal por produto e por Estado
Autor: Rodrigo Nunes
Utilidade: Imprime a Totalizacao das Vendas de um Determinado Produto Durante um Periodo pré Estabelecido
Data: 11/10/2021
Variaveis utilizadas para parametros                         
	mv_par01             // Produto de?                          
	mv_par02             // Produto ate?                         
	mv_par03             // Data de?                             
	mv_par04             // Data ate?                            
	mv_par05             // Almoxarifado?                        
	mv_par06             // Da Filial?							 
	mv_par07             // Ate Filial?                          
	mv_par08             // Exporta p/ Excel?		             
	mv_par09             // Consolida Filial?                    
	mv_par10             // Imprime Saldo x Previsao?            
	mv_par11             // Fornecedor?                
    mv_par12             // Estados?         
*/

User Function OUROR030()

	Private CbTxt	 := ""
	Private CbCont	 := ""
	Private nOrdem 	 := 0
	Private Alfa 	 := 0
	Private Z		 := 0
	Private M		 := 0
	Private tamanho	 := "G"
	Private limite   := 254
	Private titulo 	 := PADC("Consumo Mensal x Previsao da Entrega : "+COMP_DATE,75)
	Private cDesc1 	 := PADC("Este programa emiti o Relatorio de Totais de Venda por Produto",75)
	Private cDesc2 	 := PADC("e a data prevista para a entrega do material solicitado.      ",75)
	Private cDesc3 	 := PADC("                                                              ",75)
	Private aReturn  := { "Especial" , 1, "Diretoria" , 2, 2, 1,"", 0 }
	Private nomeprog := "OUROR030"
	Private cPerg    := "OUROR030"
	Private nLastKey := 0
	Private Li       := 0
	Private xPag     := 1
	Private wnrel    := "OUROR030"
	Private _EmpAtu  := "01"
	Private aMovtos  := {}
	Private aSlds    := {}
	Private _lPas2   := .T.
	Private cSQLLog  := ""

	Private cSubDir1 := "\OUROR030\"
	Private cLogDir  := cSubDir1 
	Private cFileLog := cLogDir  +"S_OUROR030.log"
	Private lGeraLog := .T. 
	
	MemoWrite(cFileLog,"LOG - "+titulo )
	PutLog( "Inicio "+Time() )
	
	cPerg := PADR(cPerg,10)
	ValidP1(cPerg)

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
	PutLog( "Fim "+Time() )
Return

Static Function RptDetail()

	Local aStrS 	:= {} 
	Local aStrQ 	:= {} 
	Local QryPrv	:= ""
	Local nAno 		:= nMes := 0
	Local cIni		:= cFim := ""
	Local cCod 		:= ""
	Local aMesPrv   := {}
	Local aQtdPrv   := {}
	Local nMesPrv   :=  0 
	Local _cQry     := ""
	Local aFornece 	:= {}
	Local aCliente 	:= {}
	Local cQAdd    	:= ""
	Local nSldAtu  	:= 0
	Local cQrySld  	:= ""
	Local _CabExc  	:= {}
	Local aDados1 	:= {}
	Local _nReg     := 0  
	Local _QtdPrev  := 0  
	Local _nQtdPrv  := 0  
	Local lNewQry	:= .T.
	Local Nw        := 0
	Local nX
	Local i
	Local n
	Local x
	Local y
	Local cCodiW7 	:= ""
	Local cProds	:= ""
	Local cFornec	:= ""

	Private cArqTrb1 := CriaTrab(NIL,.F.)
	Private cArqTrb2 := CriaTrab(NIL,.F.)

	Private _aTotCom := {} 
	Private _aTotVen := {} 
	Private _nSldTot := 0  
	Private _qMedTot := 0  
	
	Private _nTotPrv := 0  
	Private _nTotSF  := 0  
	Private _nTotSM  := 0  

	Private nAllCub  := 0
	Private nMedCub  := 0
	Private nAtuCub  := 0
         
	Private aCub 	 := {}
	Private aCubTot	 := {}
	Private aNoCub   := {}
	Private lCubagem := .T.
	Private nTotCubPrev := 0
	
	Private _nTotCub	:= 0  
	Private _nPerCub	:= 0  
	Private _nIndCub	:= 0  
	
	

	cTitulo := "Consumo Mensal x Previsao Entrega do Produto  [" + Alltrim(Mv_Par01) + "]  Ate  [" + Alltrim(Mv_Par02) + "] -"

	If !Empty(MV_par11)
		cFornec := AllTrim(ConsFor())
		cTitulo += " Fornecedor: "+ cFornec
	EndIf

	cPar := "Parametros : "+Time() + CRLF
	cPar += "-mv_par01 : " + mv_par01 + CRLF
	cPar += "-mv_par02 : " + mv_par02 + CRLF
	cPar += "-mv_par03 : " + dToc(mv_par03) + CRLF
	cPar += "-mv_par04 : " + dToc(mv_par04) + CRLF
	cPar += "-mv_par05 : " + mv_par05 + CRLF
	cPar += "-mv_par06 : " + mv_par06 + CRLF
	cPar += "-mv_par07 : " + mv_par07 + CRLF
	cPar += "-mv_par08 : " + cValToChar(mv_par08) + CRLF
	cPar += "-mv_par09 : " + cValToChar(mv_par09) + CRLF
	cPar += "-mv_par10 : " + cValToChar(mv_par10) + CRLF
	cPar += "-mv_par11 : " + mv_par11 + CRLF
	cPar += "-mv_par12 : " + mv_par12 + CRLF

	PutLog( cPar )

	DbSelectArea("SB5")
	SB5->(DbSetOrder(1))
	
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
	
	If _nMeses > 11 
	
		MsgInfo( 'Periodo nao pode ser superior a 11 meses!' )
		Return()
	
	ElseIf mv_par04 < mv_par03
	
		MsgInfo( 'Data final nao pode ser menor que a data inicial!' )
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

	PutLog( "QPRVTRB - Inicio da criacao: " +Time())
	
	dbcreate(cArqTrb2,aStrQ)
	dbUseArea(.T.,,cArqTrb2,"QPRVTRB",.F.,.F.)
	
	PutLog( "QPRVTRB - Fim da criacao: " +Time() )

	SM0->(dbSetOrder(1))

	/*
	Procura o CNPJ da Filial para localizar o Fornecedor e/ou Cliente cadastrado
	*/

	SM0->(MsSeek(Subs(cNumEmp,1,2)+" ",.T.))

	While SM0->(!Eof())
		SA1->(dbSetOrder(3))

		If SA1->(DbSeek(xFilial("SA1") + SM0->M0_CGC))
			aAdd(aCliente, {SA1->A1_COD,SA1->A1_LOJA,SA1->A1_NOME})
		EndIf

		SA2->(dbSetOrder(3))
		If SA2->(DbSeek(xFilial("SA2") + SM0->M0_CGC))
			aAdd(aFornece, {SA2->A2_COD,SA2->A2_LOJA,SA2->A2_NOME})
		EndIf 
		
		SM0->(DbSkip())
		
	EndDo
	

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

	PutLog( "Montando Query SM0: " +Time() )
	
	cDtIni := Dtos(FIRSTDAY(mv_par03))
	cDtFim := Dtos(LASTDAY(mv_par04))

	If MV_par10 == 1 //Imprime Saldo x Previsao? (1 = Nao)
		nMesPrv := 12 - _nMeses 
	Else
		nMesPrv := 11 - _nMeses 
	EndIf
	nAno 	:= IIf (Month(mv_par03) - 1 == 0, Year(mv_par03) - 1,Year(mv_par03))
	nMes 	:= IIf (Month(mv_par03) - 1 == 0, 12,Month(mv_par03))
	cIni 	:= strzero(nAno,4) + strzero(nMes,2)

	nAno := IIf (Month(mv_par04)  + nMesPrv  > 12, Year(mv_par04) + 1,Year(mv_par04))
	nMes := IIf (Month(mv_par04)  + nMesPrv  > 12,Month(mv_par04) + nMesPrv - 12,Month(mv_par04) + nMesPrv - 1)
	cFim := strzero(nAno,4) + strzero(nMes,2)

	If !Empty(MV_par11) //Fornecedor ?
		QryPrv := " SELECT "
		QryPrv += " W7_PO_NUM As NumPO, W7_HAWB As Processo, W7_COD_I As Codigo, W7_QTDE As QtdEmb, SUBSTRING(W6_PRVENTR, 1, 6) As Periodo "
		QryPrv += " FROM " + RetSqlName("SW7") + " SW7 "
		QryPrv += " INNER JOIN  " + RetSqlName("SW6") + " SW6 "
		QryPrv += " ON W7_HAWB = W6_HAWB "
		If MV_par09 == 1
			QryPrv += " INNER JOIN  " + RetSqlName("SYT") + " SYT "
			QryPrv += " ON W6_IMPORT = YT_COD_IMP "
		ENDIF
		QryPrv += " INNER JOIN  " + RetSqlName("SW3") + " SW3 "
		QryPrv += " ON W7_PO_NUM = W3_PO_NUM AND W7_COD_I = W3_COD_I  AND W7_PGI_NUM = W3_PGI_NUM "
		QryPrv += " WHERE "
		QryPrv += " SW7.D_E_L_E_T_ = ' ' "
		QryPrv += " AND SW6.D_E_L_E_T_ = ' ' "
		QryPrv += " AND SW3.D_E_L_E_T_ = ' ' "
		QryPrv += " AND SW7.W7_COD_I BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"'
		QryPrv += " AND SUBSTRING(W6_PRVENTR,1,6) "
		QryPrv += " BETWEEN '" + cIni + "' AND '" + cFim + "' "
		QryPrv += " AND W7_FORN = '" + MV_par11 + "' "
	
		If MV_par09 == 1
			QryPrv += " AND (YT_X_FILIA >= '" + MV_PAR06 + "' AND YT_X_FILIA <='" + MV_PAR07 + "') "
		ENDIF

		QryPrv += " GROUP  BY W7_PO_NUM, W7_HAWB, W7_COD_I, W7_QTDE, SUBSTRING(W6_PRVENTR, 1, 6) "
		QryPrv += " ORDER BY W7_COD_I , SUBSTRING(W6_PRVENTR, 1, 6) "
	
	Else
		QryPrv := " SELECT "
		QryPrv += " W7_PO_NUM As NumPO, W7_HAWB As Processo, W7_COD_I As Codigo, W7_QTDE As QtdEmb, SUBSTRING(W6_PRVENTR, 1, 6) As Periodo "
		QryPrv += " FROM " + RetSqlName("SW7") + " SW7 "
		QryPrv += " INNER JOIN  " + RetSqlName("SW6") + " SW6 "
		QryPrv += " ON W7_HAWB = W6_HAWB "
	
		If MV_par09 == 1
			QryPrv += " INNER JOIN  " + RetSqlName("SYT") + " SYT "
			QryPrv += " ON W6_IMPORT = YT_COD_IMP "
		ENDIF
	
		QryPrv += " INNER JOIN  " + RetSqlName("SW3") + " SW3 "
		QryPrv += " ON W7_PO_NUM = W3_PO_NUM AND W7_COD_I = W3_COD_I  AND W7_PGI_NUM = W3_PGI_NUM "
		QryPrv += " INNER JOIN  " + RetSqlName("SB1") + " SB1 "
		QryPrv += " ON W7_COD_I = B1_COD "
		QryPrv += " WHERE "
		QryPrv += " SW7.D_E_L_E_T_ = ' ' "
		QryPrv += " AND SW6.D_E_L_E_T_ = ' ' "
		QryPrv += " AND SW3.D_E_L_E_T_ = ' ' "
		QryPrv += " AND SB1.D_E_L_E_T_ = ' ' "
		QryPrv += " AND SW7.W7_COD_I BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"'
		QryPrv += " AND SUBSTRING(W6_PRVENTR,1,6) "
		QryPrv += " BETWEEN '" + cIni + "' AND '" + cFim + "' "
	
		If MV_par09 == 1
			QryPrv += " AND (YT_X_FILIA >= '" + MV_PAR06 + "' AND YT_X_FILIA <='" + MV_PAR07 + "') "
		ENDIF

		QryPrv += " AND (W7_COD_I >= '" + MV_PAR01 + "' AND W7_COD_I <= '" + MV_PAR02 + "') "
		QryPrv += " AND B1_MSBLQL <> '1' "
		QryPrv += " GROUP  BY W7_PO_NUM, W7_HAWB, W7_COD_I, W7_QTDE, SUBSTRING(W6_PRVENTR, 1, 6) "
		QryPrv += " ORDER BY W7_COD_I , SUBSTRING(W6_PRVENTR, 1, 6) "
	EndIf

	cSQLLog := MEMOWRITE("\INTRJ\OUROR030.SQL",QryPrv)
	cSQLLog := MemoWrite(Criatrab(,.f.)+".sql",QryPrv)

	PutLog( "Montando Query - Prv - Inicio :" +Time() +CRLF+QryPrv)

	dbUseArea( .T., "TOPCONN", TCGENQRY(,,QryPrv), 'Prv')
	
	PutLog( "Montando Query - Prv - Fim :" +Time() )

	dbSelectArea("SWN")
	dbSetOrder(3)

	PutLog( "Gravando SWNTRB - Inicio :" +Time() )
    
	If !Empty(MV_par11) //Fornecedor?

		Prv->(DbGoTop())
	
		While Prv->(!EOF())

	        IF !AllTrim(Prv->Codigo) $ cCodiW7
				cCodiW7 += "'"+AllTrim(Prv->Codigo)+"',"
			EndIf

			Prv->(DbSkip())

		EndDo

		cCodiW7 += "'"+AllTrim(Prv->Codigo)+"'"
	
	EndIf
	
	Prv->(DbGoTop())

	While Prv->(!Eof())
		If SWN->(dbSeek(xFilial("SWN")+Prv->Processo))
			If lNewQry
				cSWN  := GetNextAlias()
				cProc := AllTrim(Prv->Processo)
				cNumPO:= AllTrim(Prv->NumPO)
				cProd := AllTrim(Prv->Codigo)
							                     
				BeginSql ALIAS cSWN
					SELECT WN_PO_NUM, WN_PRODUTO, SUM(WN_QUANT) WN_QUANT FROM %Table:SWN%
					WHERE WN_HAWB = %Exp:cProc%
					AND WN_PO_NUM = %Exp:cNumPO%
					AND WN_PRODUTO = %Exp:cProd%
					AND WN_TIPO_NF = '1'
					AND %NotDel%
					GROUP BY WN_PO_NUM, WN_PRODUTO
				EndSql
			       
				IF (cSWN)->(!EoF())
			                         
					DbSelectArea("SWNTRB")
					SWNTRB->(RecLock("SWNTRB",.T.))
					SWNTRB->CODPROD := Prv->Codigo
					SWNTRB->QTDPREV := Prv->QtdEmb - (cSWN)->WN_QUANT
					SWNTRB->PERIODO := Prv->Periodo
					SWNTRB->(MsUnlock("SWNTRB"))

				EndIf
				
				(cSWN)->(DbCloseArea())
			Else
		
				If ALLTRIM(SWN->WN_PO_NUM) == ALLTRIM(Prv->NumPO) .AND. ALLTRIM(SWN->WN_PRODUTO) == ALLTRIM(Prv->Codigo) .AND. SWN->WN_TIPO_NF == "1"
					DbSelectArea("SWNTRB")
					SWNTRB->(RecLock("SWNTRB",.T.))
					SWNTRB->CODPROD := Prv->Codigo
					SWNTRB->QTDPREV := Prv->QtdEmb - SWN->WN_QUANT
					SWNTRB->PERIODO := Prv->Periodo
					SWNTRB->(MsUnlock("SWNTRB"))
				EndIf
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

	PutLog( "Gravando SWNTRB - Fim :" +Time() )
	
			//Seleciona as movimentacoes
			_cQry := " SELECT	SD2.D2_COD AS Codigo, "
			_cQry += " 		  	SUBSTRING(SD2.D2_EMISSAO, 1, 6) AS Periodo, "
			_cQry += " 		  	SUM(SD2.D2_QUANT) AS Qde, "
			_cQry += " 		  	SD2.D2_LOCAL AS Loc "
			_cQry += " FROM " + RetSqlName("SD2") +" SD2 "
			_cQry += " 		INNER JOIN SB1010 SB1 "
			_cQry += " 			ON SB1.B1_FILIAL = '' "
			_cQry += " 			AND SB1.B1_COD = SD2.D2_COD "
			_cQry += " 		INNER JOIN " + RetSqlName("SF2") +" SF2 "
			_cQry += " 			ON SF2.F2_FILIAL = SD2.D2_FILIAL "
			_cQry += " 			AND SF2.F2_SERIE = SD2.D2_SERIE "
			_cQry += " 			AND SF2.F2_DOC = SD2.D2_DOC "
			_cQry += " 			AND SF2.F2_CLIENTE = SD2.D2_CLIENTE "
			_cQry += " 			AND SF2.F2_LOJA = SD2.D2_LOJA "
			_cQry += " 		INNER JOIN " + RetSqlName("SF4") +" SF4 "
			_cQry += " 			ON SF4.F4_CODIGO = SD2.D2_TES "
			_cQry += " 		INNER JOIN " + RetSqlName("SA1") + " SA1 "
			_cQry += "   		ON SA1.A1_COD = SF2.F2_CLIENTE "
			_cQry += "			AND SA1.A1_LOJA = SF2.F2_LOJA "
			_cQry += " WHERE SD2.D2_EMISSAO BETWEEN '"+cDtIni+"' AND '"+cDtFim+"' "
			_cQry += " AND SD2.D2_LOCAL = '" + MV_PAR05 + "' "
			_cQry += " AND SD2.D_E_L_E_T_ <> '*' "
			_cQry += " AND SD2.D2_TIPO = 'N' "

			If !Empty(MV_par11)
				_cQry += " AND SD2.D2_COD IN (" + cCodiW7 + ") "
			EndIf
	
			//_cQry += " AND SF2.F2_FILIAL BETWEEN '" + MV_PAR06 + "' AND '" + MV_PAR07 + "' "
			_cQry += " AND SD2.D2_TIPO = SF2.F2_TIPO "
			_cQry += " AND SB1.D_E_L_E_T_ <> '*' "
			_cQry += " AND SF2.D_E_L_E_T_ <> '*' "
			_cQry += " AND SA1.D_E_L_E_T_ <> '*'
			If !Empty(MV_PAR12)
				_cQry += " AND SA1.A1_EST IN " + formatIn(Mv_PAR12,",")
			EndIf
			_cQry += " AND B1_MSBLQL <> '1' "
		
			If Len(cQAdd) > 2
				_cQry += " AND SF2.F2_CLIENTE NOT IN ('008360','020793') "
			EndIf
		
			_cQry += " AND SF4.D_E_L_E_T_ <> '*' "
			_cQry += " AND F4_ESTOQUE = 'S' "
			_cQry += " GROUP  BY SD2.D2_COD, SUBSTRING(SD2.D2_EMISSAO, 1, 6), SD2.D2_LOCAL "
			_cQry += " ORDER BY SD2.D2_COD, SD2.D2_LOCAL "


			PutLog( "Montando Query SM0 - Qry - Inicio :" +Time() +CRLF+_cQry)

			If Select("QRY") > 0
				QRY->(DbCloseArea())
			EndIf

			dbUseArea( .T., "TOPCONN", TCGENQRY(,,_cQry), 'QRY' )
			
 			PutLog( "Montando Query SM0 - Fim :" +Time() )
					
			_EmpAtu:=  "02"
			
	If Select("Prv") > 0
		DbSelectArea("Prv")
		Prv->(DbCloseArea())
	EndIf

	_nRegua := 0
	DbSelectArea("QRY")
	While QRY->(!Eof())
		AADD(aMovtos,{QRY->CODIGO,QRY->PERIODO,QRY->QDE,QRY->LOC})
		QRY->(dbSkip())
		_nRegua ++
	EndDo
	SetRegua( _nRegua )

	_EmpAtu := "01"
	_lPas2 := .T.

	// Previsao de Entrega
	
	PutLog( "Gravando QPRVTRB - Inicio :" +Time() )
	
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

	PutLog( "Gravando QPRVTRB - Fim :" +Time() )
	
	QPRVTRB->(DbGoTop())

	If Select("SWNTRB") > 0
		DbSelectArea("SWNTRB")
		SWNTRB->(DbCloseArea())
	EndIf

	//Acumula os Saldos dos produtos de acordo com as empresas selecionadas.
		
	cQrySld := "SELECT B1_COD As Cod,SUM(B2_QATU)As Sld "
	cQrySld += "FROM "+RetSqlName("SB1")+" SB1 INNER JOIN " + RetSqlName("SB2") +" SB2 ON B1_COD = B2_COD "

	cQrySld += "WHERE B2_LOCAL = '01' "
			
	If !Empty(MV_par11)
		cQrySld += "AND (B1_COD IN (" + cCodiW7 + "))"
	EndIf
			
   	cQrySld += "AND (B2_FILIAL >= '" + MV_PAR06 + "' AND B2_FILIAL <='" + MV_PAR07 + "') "
	cQrySld += "AND SB1.D_E_L_E_T_ <> '*' AND SB2.D_E_L_E_T_ <> '*' AND B1_MSBLQL <> '1' "
	cQrySld += "GROUP  BY B1_COD "
	cQrySld += "ORDER BY B1_COD "


	PutLog( "Montando Query - Sld - Inicio :" +Time() +CRLF+cQrySld)
		
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQrySld), 'Sld' )
			
	PutLog( "Montando Query - Sld - Fim :" +Time() )
		
	_EmpAtu:=  "02"
   

	DbSelectArea("Sld")
	While ! Eof()
		AADD(aSlds,{Sld->Cod,Sld->Sld})
		Sld->( dbSkip() )
	End
   

	_EmpAtu := ""

	dbSelectArea("SB1")
	dbSetOrder(1)
	SB1->( dbSeek( xFilial( 'SB1' ) + MV_PAR01, .T. ) )

	_aMesExt := {'JAN', 'FEV', 'MAR','ABR', 'MAI', 'JUN','JUL', 'AGO', 'SET','OUT', 'NOV', 'DEZ'}

	_aMeses := {}
	_aQuinz := {}
	_cAno   := Year( mv_par03 )
	_cAno   := Str( _cAno, 4 )

	Cabec2  := 'CODIGO  DESCRICAO                                    '
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
	
	Cabec2 += '     MEDIA  SLD. ATUAL  Sld/Mes'

	AADD(_CabExc,{"MEDIA"})
	AADD(_CabExc,{"SLD. ATUAL"})
	AADD(_CabExc,{"SLD/MES"})

	AT('ATUAL',Cabec2)
	Cabec1 += Replicate (" ", AT('ATUAL',Cabec2) - len(Cabec1) + 16 ) 
	Cabec1 += IIF (nMesPrv < 3,"QTD PEDI","QTD PEDIDA X ENTREGA PREVISTA")

	aMesPrv := {}

	For i = 1 To nMesPrv
	
		nAno := IIf (Month(mv_par04)  + i - 1  > 12, Year(mv_par04) + 1,Year(mv_par04))
		nMes := IIf (Month(mv_par04)  + i - 1 > 12,Month(mv_par04) + (i - 1) - 12,Month(mv_par04)+ (i - 1) )
		
		aAdd( aMesPrv, '   ' + _aMesExt[ nMes ] + '/' + StrZero(nAno,4) )

		aAdd( aCub     , {nMes, 0} )

		Cabec2 += aMesPrv[i]
		AADD(_CabExc,{aMesPrv[ i ]})
	
	Next
	
	_fSB2 := xFilial( "SB2" )
	_fSB1 := xFilial( "SB1" )

	M_Pag := 1

	If MV_par10 == 2 //Imprime Saldo x Previsao? (2 = Sim)
		Cabec2 += "   Sld/Futuro"       
		AADD(_CabExc,{"SLD. FUTURO"})   
	EndIf
	
	@ 0,0 PSAY Chr( 27 ) + '@' + Chr( 27 ) + 'M' + Chr( 15 )

	// map
	//                   CODIGO  DESCRICAO                                 UM    MES/YEAR   MES/YEAR   MES/YEAR   MES/YEAR   MES/YEAR      MEDIA SLD. ATUAL     MES/YEAR   MES/YEAR   MES/YEAR   MES/YEAR   MES/YEAR   MES/YEAR   MES/YEAR   MES/YEAR
	//					  12345  1234567890123456789012345678901234567890  12  1234567890 1234567890 1234567890 1234567890 1234567890   12345678 1234567890   1234567890 1234567890 1234567890 1234567890 1234567890 1234567890 1234567890 1234567890
	//					  1      8                                         49  51         61        5         6         7         8         9        10        11        12        13        14        15        16        17        18        19
	//					 01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890

	_nLin := Cabec( ctitulo, cabec1, cabec2, nomeprog, tamanho, 1 )
	++_nLin

	PutLog( "Imprimindo - Inicio :" +Time())
    
	If !Empty(MV_par11)
		cProds	:= cCodiW7
		cCodiW7 := AllTrim(STRTRAN(cCodiW7,",","|"))
		cCodiW7 := AllTrim(STRTRAN(cCodiW7,"'",""))
	EndIf

	While !SB1->( Eof() ) .And. SB1->B1_COD <= MV_PAR02 .And. SB1->B1_FILIAL == xFilial("SB1")

		If !Empty(MV_par11) .And. !AllTrim(SB1->B1_COD) $ cCodiW7
			SB1->( DbSkip() )
			Loop
		Else
			If _nLin > 60
				_nLin := Cabec( ctitulo, cabec1, cabec2, nomeprog, tamanho, 1 )
				_nLin += 2
			EndIf
		
			If SB1->B1_MSBLQL == '1'
				SB1->(dbSkip())
			Else  
				@ _nLin,001 PSAY Substr( SB1->B1_Cod , 1, 7 )
				@ _nLin,008 PSAY Substr( SB1->B1_Desc, 1, 50 )
				
			
				AADD(aDados1,Alltrim(SB1->B1_Cod))
				AADD(aDados1,Substr( SB1->B1_Desc, 1, 50))
				AADD(aDados1,SB1->B1_UM)
			
				_nMes 	:= Month( mv_par03 )
				_qMes 	:= {}
				_qMed 	:= 0
				aQtdPrv := {}
				nMes 	:= 0
	
				For i = 1 To _nMeses
				
					aAdd( _qMes  , { _nMes, 0, 0 } )
					If Len(_aTotCom) < _nMeses                    
						aAdd( _aTotCom , { _nMes , 0 , 0 , 0 } )  
					EndIf                                         
					_nMes ++
				
					If _nMes > 12
						
						_nMes := 1
					
					EndIf
				
				Next
			
				For i = 1 To nMesPrv
					nMes := IIf (Month(mv_par04)  + (i-1) > 12,Month(mv_par04) + (i-1)- 12,Month(mv_par04)+(i-1))
					aAdd( aQtdPrv  , {nMes, 0} )
					If Len(_aTotVen) < nMesPrv                  
						aAdd( _aTotVen , { nMes , 0 , 0 } )		
					EndIf                                       
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
					
				_nCol := 51
				_nMes := Month( mv_par03 )
			
				For i = 1 To _nMeses
				
					_nCol += 1
					@ _nLin, _nCol PSAY _qMes[  i ][ 2 ] Picture '@E 99,999,999'
					_aTotCom[ i ][ 2 ] += _qMes[  i ][ 2 ] 
					_aTotCom[ i ][ 4 ] := _nCol            
					AADD(aDados1,_qMes[  i ][ 2 ] )
					_nCol += 10
				
					// CUBAGEM
					nAllCub += RetCub( ,_qMes[i][ 2])


					_nMes ++
				
					If _nMes > 12
					
						_nMes := 1
					
					End
				
				Next
			
				_qMed /= _nMeses
				_nCol += 3
								
				// CUBAGEM
				nMedCub += RetCub( ,_qMed)
			
			
				@ _nLin, _nCol PSAY _qMed        Picture '@E 99,999,999'
				_qMedTot += _qMed    
				AADD(aDados1,_qMed)
				_nCol += 12
			
				For n:= 1 To Len(aSlds)
					
					_cCod := aSlds[ n ] [ 1 ]
			
					If _cCod == SB1->B1_COD
						If _cCod == SB1->B1_COD
							nSldAtu += aSlds[ n ] [ 2 ]
						EndIf
						_vCod := _cCod
					EndIf
				
				Next
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
				
				// CUBAGEM
				nAtuCub += RetCub( ,nSldAtu)
				
				@ _nLin, _nCol PSAY nSldAtu Picture '@E 99,999,999'
				AADD(aDados1,nSldAtu)
				_nSldTot += nSldAtu 
				_nCol += 10
			
				_nCol += 2
				
				@ _nLin, _nCol PSAY NOROUND(nSldAtu / _qMed, 1) Picture '@E 99999.9'
				
				AADD(aDados1,NOROUND(nSldAtu / _qMed,1))
					
				_nCol   += 5
				
				If QPRVTRB->CODPROD == SB1->B1_COD
					
					cCod := QPRVTRB->CODPROD
					
					While cCod == QPRVTRB->CODPROD
						nPos := aScan( aQtdPrv, { |x| x[1] == Val(Substr(QPRVTRB->PERIODO,5,2)) })
						If nPos != 0
							aQtdPrv[nPos][2] := QPRVTRB->QTDPREV 
						EndIf
						QPRVTRB->( dbSkip() )
						IncRegua()
					EndDo
				
				EndIf
			
				_nCol += 2
				For i = 1 To nMesPrv
					_nCol += 1
					@ _nLin, _nCol PSAY aQtdPrv[i][2] Picture '@E 99,999,999'
					_aTotVen[ i ][ 2 ] += aQtdPrv[  i ][ 2 ]  
					_aTotVen[ i ][ 3 ] := _nCol               
					AADD(aDados1,aQtdPrv[i][2])
					_nCol += 10
					aCub[i][02]+= IIf( aQtdPrv[i][2] > 0, RetCub(,aQtdPrv[i][2]), 0 )
					nTotCubPrev += IIf( aQtdPrv[i][2] > 0, RetCub(,aQtdPrv[i][2]), 0 )
				Next
				
				If MV_par10 == 2 //Imprime Saldo x Previsao? (2 = Sim)
					_nCol += 6
				
					@ _nLin, _nCol PSAY NOROUND(( nSldAtu + _nQtdPrv )/_qMed, 1) Picture '@E 99999.9'
					AADD(aDados1,NOROUND(( nSldAtu + _nQtdPrv )/_qMed, 1))
				EndIf
				
				_nLin ++
				
				nSldAtu := 0
				_nQtdPrv := 0 
				
				SB1->(dbSkip())
			EndIf  // 
		EndIf
	EndDo

	If MV_par08 == 2//Exporta Excel (2 = Sim)
		
		
		If MV_par10 == 2 //Imprime Saldo x Previsao? (2 = Sim)
			ASIZE(aDados1,Len(aDados1)+3)          	
			
			For x:= 1 to Len(_aTotCom)             	
				AADD(aDados1,_aTotCom[x][2])   		
			Next x                                 	
			
			AADD(aDados1,_qMedTot)                 	
			AADD(aDados1,_nSldTot)			        
			
			_nTotSM := _nSldTot/_qMedTot            
			AADD(aDados1,_nTotSM)			        
			
			For y:= 1 to Len(_aTotVen)		        
				AADD(aDados1,_aTotVen[y][2])	    
				_nTotPrv += _aTotVen[ y ][ 2 ]
			Next y					                
			
			_nTotSF := (_nSldTot + _nTotPrv) / _qMedTot  
			AADD(aDados1,_nTotSF)                        
			
			_nTotSM  := 0 
			_nTotPrv := 0 
			_nTotSF  := 0 
		Else
			ASIZE(aDados1,Len(aDados1)+3)          
			For x:= 1 to Len(_aTotCom)             
				AADD(aDados1,_aTotCom[x][2])       
			Next x                                 
			AADD(aDados1,_qMedTot)                 
			AADD(aDados1,_nSldTot)                 
			ASIZE(aDados1,Len(aDados1)+1)          
			For y:= 1 to Len(_aTotVen)             
				AADD(aDados1,_aTotVen[y][2])       
			Next y                                 
		EndIf

		If lCubagem
		
			AADD(aDados1,"")
			AADD(aDados1,"CUBAGEM")
			AADD(aDados1,"")
			
			For Nw := 1 To _nMeses
				AADD(aDados1,"")
			Next
						
			//AADD(aDados1,nAllCub)
			AADD(aDados1,nMedCub)
			AADD(aDados1,nAtuCub)
	  		AADD(aDados1,"")

			For Nw := 1 To Len( aCub )
				AADD(aDados1,aCub[Nw][2])
			Next
			AADD(aDados1,"")
   			
			For Nw := 1 To Len( _CabExc )
				AADD(aDados1,"")
			Next
			
			AADD(aDados1,"")
			AADD(aDados1,"CUBAGEM VENDIDA")
			AADD(aDados1,"")
			AADD(aDados1,nAllCub )
			AADD(aDados1,"")
			AADD(aDados1,"")

			For Nw := 1 To (Len( _CabExc ) - 6)
				AADD(aDados1,"")
			Next

			For Nw := 1 To Len( _CabExc )
				AADD(aDados1,"")
			Next

			AADD(aDados1,"")
			AADD(aDados1,"CUBAGEM PREVISTA")
			AADD(aDados1,"")
			AADD(aDados1,nTotCubPrev )
			AADD(aDados1,"")
			AADD(aDados1,"")
			For Nw := 1 To (Len( _CabExc ) - 6)
				AADD(aDados1,"")
			Next
   			
		EndIf
		
		U_Excmg30n(titulo,_CabExc,aDados1)
	EndIf

	PutLog( "Imprimindo - Fim :" +Time())

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

	If Select("QPRVTRB") > 0
		DbSelectArea("QPRVTRB")
		QPRVTRB->(DbCloseArea())
	EndIf
	

	ImpRodape(cProds) 
		
	Eject

	MS_FLUSH()

	Set Device To Screen
	Set Printer To

	If aReturn[5] == 1
	
		dbcommitAll()
		ourspool(wnrel)
	
	EndIf

Return(Nil)

* ------------------------------------------------------ *
* Claudino Domingues | 12/01/16                          *
* Funcao Rodape      | Destinada para Imprimir o Rodape  *
* ------------------------------------------------------ * 

Static Function ImpRodape(cProds)
    
	Local x, y := 0
	Local a,b
	Local nDiv	 := 0
    
  	If Empty(_aTotCom) .or. Empty(_aTotVen)
  		Return
  	EndIf
  
	_nLin := _nLin + 1
	
	@ _nLin,000 PSAY Replicate("_",220)
	
	_nLin := _nLin + 2
	
	@ _nLin,000 PSAY "Q T D   T O T A L   --->"
	
	For x := 1 To Len(_aTotCom)
		@ _nLin,_aTotCom[ x ][ 4 ]-1 PSAY _aTotCom[ x ][ 2 ] Picture '@E 99,999,999'
	Next x
    
	@ _nLin,_aTotCom[ Len(_aTotCom) ][ 4 ]+12 PSAY _qMedTot Picture '@E 99,999,999'
	@ _nLin,_aTotCom[ Len(_aTotCom) ][ 4 ]+24 PSAY _nSldTot Picture '@E 99,999,999'
	
	If MV_par10 == 2 //Imprime Saldo x Previsao? (2 = Sim)
	
		_nTotSM := _nSldTot / _qMedTot                                              
		@ _nLin,_aTotCom[ Len(_aTotCom) ][ 4 ]+36 PSAY _nTotSM Picture '@E 99999.9' 
	
		For y := 1 To Len(_aTotVen)
			@ _nLin,_aTotVen[ y ][ 3 ]-1 PSAY _aTotVen[ y ][ 2 ] Picture '@E 99,999,999'
			_nTotPrv += _aTotVen[ y ][ 2 ]                                          
		Next y
	
		_nTotSF := (_nSldTot + _nTotPrv) / _qMedTot                                 
		@ _nLin,211 PSAY _nTotSF Picture '@E 99999.9'                               
	
		_nLin := _nLin + 1
	
		@ _nLin,000 PSAY Replicate("_",220)
	
	
		_nLin := _nLin + 1
	
		@ _nLin,000 PSAY Replicate("_",220)
		_nLin := _nLin + 2
	Else
		For y := 1 To Len(_aTotVen)
			@ _nLin,_aTotVen[ y ][ 3 ] PSAY _aTotVen[ y ][ 2 ] Picture '@E 99,999,999'
		Next y
	
		_nLin := _nLin + 1
	
		@ _nLin,000 PSAY Replicate("_",220)
		_nLin := _nLin + 2
	EndIf
	
    @ _nLin,000 PSAY "C U B A G E M  (M" + Trim(Chr(179)) + ") U N I T  R I A ---> "

    For a := 1 To Len(_aTotCom)
        _nTotCub += _aTotCom[ a ][ 2 ]
    Next a

    For b := 1 To Len(_aTotCom)
        _nPerCub := (_aTotCom[ b ][ 2 ] / _nTotCub) * 100
        _nIndCub := (nAllCub * _nPerCub) / 100
        @ _nLin,_aTotCom[ b ][ 4 ]-2 PSAY _nIndCub Picture PICT_CUB
    Next b

    @ _nLin,_aTotCom[ Len(_aTotCom) ][ 4 ]+10 PSAY nMedCub Picture PICT_CUB

    @ _nLin,_aTotCom[ Len(_aTotCom) ][ 4 ]+22 PSAY nAtuCub Picture PICT_CUB

    For y := 1 To Min(Len(aCub),Len(_aTotVen))
        @ _nLin,_aTotVen[ y ][ 3 ]-2 PSAY aCub[ y ][2] Picture PICT_CUB
    Next y

    _nLin := _nLin + 1

    @ _nLin,000 PSAY Replicate("_",220)
    @ _nLin+0.5,000 PSAY Replicate("_",220)

	  
	 _nLin := _nLin + 2 

	 @ _nLin,000 PSAY "Q T D E.   P A L L E T S   T O T A L:  --->    "

	nDiv := TotNorm(cProds)

	 For x := 1 To Len(_aTotCom)
		@ _nLin,_aTotCom[ x ][ 4 ] PSAY _aTotCom[ x ][ 2 ]/nDiv Picture '@E 99,999,999'
	Next x
    
	@ _nLin,_aTotCom[ Len(_aTotCom) ][ 4 ]+13 PSAY _qMedTot/nDiv Picture '@E 99,999,999'
	@ _nLin,_aTotCom[ Len(_aTotCom) ][ 4 ]+25 PSAY _nSldTot/nDiv Picture '@E 99,999,999'
	
	If MV_par10 == 2 //Imprime Saldo x Previsao? (2 = Sim)
	
		_nTotSM := _nSldTot / _qMedTot                                              
		@ _nLin,_aTotCom[ Len(_aTotCom) ][ 4 ]+37 PSAY _nTotSM/nDiv Picture '@E 99999.9' 
	
		For y := 1 To Len(_aTotVen)
			@ _nLin,_aTotVen[ y ][ 3 ] PSAY _aTotVen[ y ][ 2 ]/nDiv Picture '@E 99,999,999'
			_nTotPrv += _aTotVen[ y ][ 2 ]                                          
		Next y
	
		_nTotSF := (_nSldTot + _nTotPrv) / _qMedTot                                 
		@ _nLin,211 PSAY _nTotSF/nDiv Picture '@E 99999.9'                               
	
		_nLin := _nLin + 1
	
		@ _nLin,000 PSAY Replicate("_",220)
	
	
		_nLin := _nLin + 1
	
		@ _nLin,000 PSAY Replicate("_",220)
		_nLin := _nLin + 2
	Else
		For y := 1 To Len(_aTotVen)
			@ _nLin,_aTotVen[ y ][ 3 ] PSAY _aTotVen[ y ][ 2 ]/nDiv Picture '@E 99,999,999'
		Next y
	
		_nLin := _nLin + 1
	
		@ _nLin,000 PSAY Replicate("_",220)
		_nLin := _nLin + 2
	EndIf

Return

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} RetCub
Retorna a cubagem de um item

@type 		function
@author 	Roberto Souza
@since 		23/06/2017
@version 	P11 
 
@return nil
/*/    
//-------------------------------------------------------------------------------------
Static Function RetCub( cProd, nQuant)
	Local nCub 		:= 0
	Local nQtEmb    := 0
	Local aArea 	:= GetArea()
    
	Default cProd 	:= SB1->B1_COD
    
	DbSelectArea("SB5")
	If SB5->(DbSeek( xFilial("SB5")+cProd))
		If !Empty(SB5->B5_EMB1)
			DbSelectArea("EE5")
			If EE5->(DbSeek(xFilial("EE5")+SB5->B5_EMB1))
				nQtEmb	:= nQuant/SB1->B1_QE
				nCub	:= nQtEmb * (EE5->EE5_CCOM * EE5->EE5_LLARG * EE5->EE5_HALT)
			Else
				nQtEmb	:= nQuant
				nCub	:= nQtEmb * (SB5->B5_COMPR * SB5->B5_LARG * SB5->B5_ALTURA)
			EndIf
		EndIf
	Else
		AADD( aNoCub , SB1->B1_COD )
	EndIf
	
	RestArea( aArea )

Return( nCub )
      


//-------------------------------------------------------------------------------------
/*/{Protheus.doc} PutLog
Geracao de log

@type 		function
@author 	Roberto Souza
@since 		23/06/2017
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

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} ConsFor
Consultar Nome Fantasia do Fornecedor 

@type 		Static function
@author 	Roberto Santiago
@since 		11/02/2019
@version 	P12 
 
@return nil
/*/    
//-------------------------------------------------------------------------------------
Static Function ConsFor()

Local cQuery    := ""
Local cAliasQry := GetNextAlias()

 cQuery := "Select SA2.A2_NREDUZ NOME "
 cQuery += "From "+RetSqlName("SA2")+ " SA2 "
 cQuery += "Where SA2.A2_COD = '"+MV_par11+ "' AND D_E_L_E_T_ <> '*'"

 cQuery := ChangeQuery(cQuery)
 DbUseArea( .T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasQry,.F.,.T. )

 cForn := (cAliasQry)->NOME
 
 (cAliasQry)->(DbCloseArea())

Return cForn

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} TotNorm
Consultar total de normas por produto

@type 		Static function
@author 	Roberto Santiago
@since 		14/02/2019
@version 	P12 
 
@return nil
/*/    
//-------------------------------------------------------------------------------------
Static Function TotNorm(cProds)

Local cQuery    := ""
Local cAliasQry := GetNextAlias()
Local cQuery2	:= ""
Local cAliasQry2:= GetNextAlias()
Local nDiv		:= 0
Local cNorm		:= ""
Local aResult	:= {}
Local nX
Local nY		:= 1

	cQuery := "Select DC3.DC3_CODNOR NORMA "
	cQuery += "From "+RetSqlName("DC3")+ " DC3 "
	
	If !Empty(MV_par11)
		cQuery += "Where DC3.DC3_CODPRO IN ("+cProds+") AND D_E_L_E_T_ <> '*'"
	Else
		cQuery += "Where DC3.DC3_CODPRO >= '" + MV_PAR01 + "' AND DC3.DC3_CODPRO <= '" + MV_PAR02 + "' AND  D_E_L_E_T_ <> '*'"	
	EndIf

	cQuery := ChangeQuery(cQuery)
	DbUseArea( .T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasQry,.F.,.T. )

	(cAliasQry)->(DbGoTop())

	While (cAliasQry)->(!EOF())
		cNorm += "'"+(cAliasQry)->NORMA+"', "
		(cAliasQry)->(DbSkip())
	EndDo

	cNorm += "'"+(cAliasQry)->NORMA+"'"
 
 	(cAliasQry)->(DbCloseArea())

	cQuery2 := "Select DC2.DC2_CODNOR NORM, DC2.DC2_LASTRO LAST, DC2.DC2_CAMADA CAMAD "
	cQuery2 += "From "+RetSqlName("DC2")+ " DC2 "
	cQuery2 += "Where DC2.DC2_CODNOR IN ("+cNorm+ ") AND D_E_L_E_T_ <> '*'"

	cQuery2 := ChangeQuery(cQuery2)
	DbUseArea( .T.,"TOPCONN",TCGENQRY(,,cQuery2),cAliasQry2,.F.,.T. )

 	(cAliasQry2)->(DbGoTop())	

	While (cAliasQry2)->(!EOF())
		aAdd(aResult, {(cAliasQry2)->LAST,(cAliasQry2)->CAMAD})
		(cAliasQry2)->(DbSkip())
	EndDo

	For nX := 1 to Len(aResult)
		nDiv += aResult[nX][nY] * aResult[nX][nY+1]
	Next 
	
	(cAliasQry2)->(DbCloseArea())

Return nDiv

/*
Rotina: ValidP1
Descricao: Parametros da rotina.
Autor: Marcelo - Ethosx 
Data: 29/04/2019
*/

Static Function ValidP1(cPerg)
Local j, i := 0

dbSelectArea("SX1")
dbSetOrder(1)

aRegs:={}              
aAdd(aRegs,{cPerg,"01","Produto de ?                  "	,"","","mv_ch1" ,"C",15,0,0,"G",""														,"mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","SB1"	,"","","","","","","",""})
aAdd(aRegs,{cPerg,"02","Produto ate ?                 "	,"","","mv_ch2" ,"C",15,0,0,"G","NaoVazio().And.AllTrim(MV_PAR01)<=AllTrim(MV_PAR02)"	,"mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","SB1"	,"","","","","","","",""})
aAdd(aRegs,{cPerg,"03","Data de ?                     "	,"","","mv_ch3" ,"D", 8,0,0,"G",""														,"mv_par03","","","","","","","","","","","","","","","","","","","","","","","","",""		,"","","","","","","",""})
aAdd(aRegs,{cPerg,"04","Data ate ?                    "	,"","","mv_ch4" ,"D", 8,0,0,"G","NaoVazio()"											,"mv_par04","","","","","","","","","","","","","","","","","","","","","","","","",""		,"","","","","","","",""})
aAdd(aRegs,{cPerg,"05","Almoxarifado ?                "	,"","","mv_ch5" ,"C", 2,0,0,"G",""														,"mv_par05","","","","","","","","","","","","","","","","","","","","","","","","",""		,"","","","","","","",""})
aAdd(aRegs,{cPerg,"06","Da Filial ?                   "	,"","","mv_ch6" ,"C", 2,0,0,"G",""														,"mv_par06","","","","","","","","","","","","","","","","","","","","","","","","","SM0"	,"","","","","","","",""})
aAdd(aRegs,{cPerg,"07","Ate a Filial ?                "	,"","","mv_ch7" ,"C", 2,0,0,"G","NaoVazio().And.MV_PAR06<=MV_PAR07"					    ,"mv_par07","","","","","","","","","","","","","","","","","","","","","","","","","SM0"	,"","","","","","","",""})
aAdd(aRegs,{cPerg,"08","Exporta p/ Excell ?           "	,"","","mv_ch8" ,"C", 1,0,0,"C",""														,"mv_par08","Nao","Nao","Nao","","","Sim","Sim","Sim","","","","","","","","","","","","","","","","","","","","","","","","",""} )
aAdd(aRegs,{cPerg,"09","Consolida Filial ?            "	,"","","mv_ch9" ,"C", 1,0,0,"C",""														,"mv_par09","Nao","Nao","Nao","","","Sim","Sim","Sim","","","","","","","","","","","","","","","","","","","","","","","","",""} )
aAdd(aRegs,{cPerg,"10","Imprime Saldo x Previsao ?    "	,"","","mv_cha" ,"C", 1,0,0,"C",""														,"mv_par10","Nao","Nao","Nao","","","Sim","Sim","Sim","","","","","","","","","","","","","","","","","","","","","","","","",""} )
aAdd(aRegs,{cPerg,"11","Fornecedor ?                  "	,"","","mv_chb" ,"C", 6,0,0,"G",""														,"mv_par11","","","","","","","","","","","","","","","","","","","","","","","","","SA2"	,"","","","","","","",""})
aAdd(aRegs,{cPerg,"12","Estados ?                     "	,"","","mv_chc" ,"C", 83,0,0,"G","U_F3OURO01()"        									,"mv_par12","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})

For i:=1 to Len(aRegs)
	If !dbSeek(cPerg + aRegs[i,2])
		RecLock("SX1",.T.)
		For j:=1 to FCount()
			FieldPut(j,aRegs[i,j])
		Next
		MsUnlock()
		dbCommit()
	Endif
Next
                          
Return(.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Excell()  º Autor ³ Andre Bagatini     º Data ³  08/07/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³Função com o objetivo de receber um array com dados ,outro  º±±
±±º          ³com itens e exportar direto para o Excell sem salvar no C:/ º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Eletromega                                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function Excmg30n(cTexto,aCabec,aDados,mvpar)

	Local aCabec1:= {}
	Local aDados2:= {}
	Local aTemp	 := {}
	Local x

	If !ApOleClient("MSExcel") // testa a interação com o excel.
		MsgAlert("Microsoft Excel não instalado!")
		Return Nil
	EndIf

	For x:= 1 to Len(aCabec)

		AADD(aCabec1,aCabec[x][1])

	Next x

	y:= 1

	If mvpar = 2
		For x:= 1 to Len(aDados)

			While  x <= (18 * y)
				AADD(aTemp,aDados[x])
				x++
			End
			If x > (18 * y)
				AADD(aDados2,aTemp)
				aTemp := {}
				y++
			EndIf
    		// 
			x--
		Next x
	Else
		For x:= 1 to Len(aDados)-1

			While  x <= (18 * y) .And. x <= Len(aDados)
				AADD(aTemp,aDados[x])
				x++
			End
			If x > (18 * y)
				AADD(aDados2,aTemp)
				aTemp := {}
				y++
			EndIf
    		// 
			x--
		Next x
	Endif
                                     
	DlgToExcel({ {"ARRAY", cTexto, aCabec1,aDados2} }) // utiliza a função

Return Nil
