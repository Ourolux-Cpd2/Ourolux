#INCLUDE "PROTHEUS.CH"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±º Programa ³ M460QRY() ³ Autor ³ Claudino P Domingues ³ Data ³ 06/09/13  º±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±º Funcao Padrao ³ MATA461                                                º±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±º Desc.    ³ Ponto de entrada que adiciona filtro SQL antes de           º±±
±±º          ³ montar a tela para selecao dos pedidos de venda a faturar.  º±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

User Function M460QRY()

	Local _aArea         := GetArea()
	Local _cAreaSC9      := SC9->(GetArea())
	Local _cFilPadrao    := PARAMIXB[1]
	Local _cFilQry 		 := ""
	Local _cPedRio 		 := "" 
	Local _cSC9Qry       := ""
	Local _cQueryM460QRY := ""
	
	If cFilAnt == "01" .Or. cFilAnt == "06"
		iF FUNNAME() == "MATA460A"
			If !IsInCallStack("MAPVLNFS") 
				_cQueryM460QRY := " SELECT " 
				_cQueryM460QRY += "		SC9.C9_PEDIDO AS PEDIDO, "
				_cQueryM460QRY += "		SC9.C9_CLIENTE AS CLIENTE, "
				_cQueryM460QRY += "		SC9.C9_LOJA AS LOJACLI, "
				_cQueryM460QRY += " 	SA1.A1_EST AS ESTCLI, "          
				_cQueryM460QRY += " 	SC5.C5_XNUMINT AS PEDRIO "          
				_cQueryM460QRY += " FROM " 
				_cQueryM460QRY += 		RetSqlName("SC9") + " AS SC9 "
				_cQueryM460QRY += " INNER JOIN "
				_cQueryM460QRY +=		RetSqlName("SA1") + " AS SA1 " 
				_cQueryM460QRY += "	ON "
				_cQueryM460QRY += " 	SC9.C9_CLIENTE = SA1.A1_COD AND SC9.C9_LOJA = SA1.A1_LOJA " 
				_cQueryM460QRY += " INNER JOIN "
				_cQueryM460QRY +=		RetSqlName("SC5") + " AS SC5 " 
				_cQueryM460QRY += "	ON "
				_cQueryM460QRY += " 	SC9.C9_PEDIDO = SC5.C5_NUM "
				_cQueryM460QRY += " 	AND SC9.C9_FILIAL = SC5.C5_FILIAL "
				_cQueryM460QRY += "		AND SC5.C5_TABELA IN ('RIO','RSU')
				_cQueryM460QRY += " WHERE " 
				_cQueryM460QRY += "		SC9.D_E_L_E_T_ = '' AND "
				_cQueryM460QRY += "		SA1.D_E_L_E_T_ = '' AND "
				_cQueryM460QRY += "	 	SC9.C9_FILIAL = '" + xFilial("SC9") + "' AND " 
				_cQueryM460QRY += "	  ( SC9.C9_PEDIDO BETWEEN '" + MV_PAR05 + "' AND '" + MV_PAR06 + "' ) AND " 
				_cQueryM460QRY += "	  ( SC9.C9_CLIENTE BETWEEN '" + MV_PAR07 + "' AND '" + MV_PAR08 + "' ) AND " 
				_cQueryM460QRY += "	  ( SC9.C9_LOJA BETWEEN '" + MV_PAR09 + "' AND '" + MV_PAR10 + "' ) AND "
				_cQueryM460QRY += "	  ( SC9.C9_DATALIB BETWEEN '" + DTOS(MV_PAR11) + "' AND '" + DTOS(MV_PAR12) + "' ) AND "
				_cQueryM460QRY += " 	SC9.C9_BLEST <> '10' AND "
				_cQueryM460QRY += " 	SC9.C9_BLCRED <> '10' AND " 
				_cQueryM460QRY += " 	SC9.C9_NFISCAL = '' AND " 
				_cQueryM460QRY += "	  ( SC9.C9_CLIENTE+SC9.C9_LOJA NOT IN('00836004'))
				_cQueryM460QRY += " GROUP BY "
				_cQueryM460QRY += "		SC9.C9_PEDIDO, "
				_cQueryM460QRY += "		SC9.C9_CLIENTE, "
				_cQueryM460QRY += "		SC9.C9_LOJA, "
				_cQueryM460QRY += " 	SA1.A1_EST, "
				_cQueryM460QRY += " 	SC5.C5_XNUMINT "    
			
				_cQueryM460QRY := ChangeQuery(_cQueryM460QRY)
				
				If Select("TMP") > 0
					DbSelectArea("TMP")
					TMP->(DbCloseArea())
				EndIf
				
				dbUseArea(.T.,"TOPCONN",TCGenQry(,,_cQueryM460QRY),"TMP",.F.,.T.)
				
				
				While !TMP->(Eof())
					If Upper(ALLTRIM(TMP->ESTCLI)) == "RJ" //.AND. !EMPTY(ALLTRIM(TMP->PEDRIO))
						If Empty(_cFilQry)
							_cFilQry := "'"+ALLTRIM(TMP->PEDIDO)+"' " 
						Else 
							_cFilQry += "'"+ALLTRIM(TMP->PEDIDO)+"' "
						EndIf
					EndIf	
					TMP->( DbSkip() )
				Enddo
				
				If !Empty(_cFilQry)
					_cPedRio := StrTran(ALLTRIM(_cFilQry)," ",",")
				EndIf
				
				If !Empty(_cPedRio)
					_cSC9Qry := _cFilPadrao + " AND (SC9.C9_PEDIDO NOT IN("+_cPedRio+")) "
				Else
					_cSC9Qry := _cFilPadrao
				EndIf
				
					
				DbSelectArea("TMP")
				TMP->(DbCloseArea())
			Else
				_cSC9Qry := _cFilPadrao
			EndIf
		Else
			_cSC9Qry := _cFilPadrao
		EndIf
	Else
		_cSC9Qry := _cFilPadrao
	EndIf
	
	RestArea(_aArea)
	SC9->(RestArea(_cAreaSC9))
	
Return(_cSC9Qry)
