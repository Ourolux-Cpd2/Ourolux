#INCLUDE "PROTHEUS.CH"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±º Programa ³ M460FIL() ³ Autor ³ Claudino P Domingues ³ Data ³ 28/08/13  º±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±º Funcao Padrao ³ MATA461                                                º±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±º Desc.    ³ Ponto de entrada que adiciona filtro ADVPL antes de         º±±
±±º          ³ montar a tela para selecao dos pedidos de venda a faturar.  º±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

User Function M460FIL

	Local _aArea         := GetArea()
	Local _cAreaSC9      := SC9->(GetArea())
	Local _cFilQry 		 := ""
	Local _cPedRio 		 := "" 
	Local _cSC9Fil       := ""
	Local _cQueryM460FIL := ""
	
	If cFilAnt == "01" .Or. cFilAnt == "06"
	    If FUNNAME() == "MATA460A"
			If !IsInCallStack("MAPVLNFS")
				_cQueryM460FIL := " SELECT " 
				_cQueryM460FIL += "		SC9.C9_PEDIDO AS PEDIDO, "
				_cQueryM460FIL += "		SC9.C9_CLIENTE AS CLIENTE, "
				_cQueryM460FIL += "		SC9.C9_LOJA AS LOJACLI, "
				_cQueryM460FIL += " 	SA1.A1_EST AS ESTCLI, "     
				_cQueryM460FIL += " 	SC5.C5_XNUMINT AS PEDRIO " 
				_cQueryM460FIL += " FROM " 
				_cQueryM460FIL += 		RetSqlName("SC9") + " AS SC9 "
				_cQueryM460FIL += " INNER JOIN "
				_cQueryM460FIL +=		RetSqlName("SA1") + " AS SA1 " 
				_cQueryM460FIL += "	ON "
				_cQueryM460FIL += " 	SC9.C9_CLIENTE = SA1.A1_COD AND SC9.C9_LOJA = SA1.A1_LOJA "     
				_cQueryM460FIL += " INNER JOIN "
				_cQueryM460FIL +=		RetSqlName("SC5") + " AS SC5 " 
				_cQueryM460FIL += "	ON "
				_cQueryM460FIL += " 	SC9.C9_PEDIDO = SC5.C5_NUM "
				_cQueryM460FIL += " 	AND SC9.C9_FILIAL = SC5.C5_FILIAL "
				_cQueryM460FIL += "		AND SC5.C5_TABELA IN ('RIO','RSU')
				_cQueryM460FIL += " WHERE " 
				_cQueryM460FIL += "		SC9.D_E_L_E_T_ = '' AND "
				_cQueryM460FIL += "		SA1.D_E_L_E_T_ = '' AND "
				_cQueryM460FIL += "	 	SC9.C9_FILIAL = '" + xFilial("SC9") + "' AND " 
				_cQueryM460FIL += "	  ( SC9.C9_PEDIDO BETWEEN '" + MV_PAR05 + "' AND '" + MV_PAR06 + "' ) AND " 
				_cQueryM460FIL += "	  ( SC9.C9_CLIENTE BETWEEN '" + MV_PAR07 + "' AND '" + MV_PAR08 + "' ) AND " 
				_cQueryM460FIL += "	  ( SC9.C9_LOJA BETWEEN '" + MV_PAR09 + "' AND '" + MV_PAR10 + "' ) AND "
				_cQueryM460FIL += "	  ( SC9.C9_DATALIB BETWEEN '" + DTOS(MV_PAR11) + "' AND '" + DTOS(MV_PAR12) + "' ) AND "
				_cQueryM460FIL += " 	SC9.C9_BLEST <> '10' AND "
				_cQueryM460FIL += " 	SC9.C9_BLCRED <> '10' AND " 
				_cQueryM460FIL += " 	SC9.C9_NFISCAL = '' AND " 
				_cQueryM460FIL += "	  ( SC9.C9_CLIENTE+SC9.C9_LOJA NOT IN('00836004'))
				_cQueryM460FIL += " GROUP BY "
				_cQueryM460FIL += "		SC9.C9_PEDIDO, "
				_cQueryM460FIL += "		SC9.C9_CLIENTE, "
				_cQueryM460FIL += "		SC9.C9_LOJA, "
				_cQueryM460FIL += " 	SA1.A1_EST, "
				_cQueryM460FIL += " 	SC5.C5_XNUMINT "    
			
				_cQueryM460FIL := ChangeQuery(_cQueryM460FIL)
				
				If Select("TMP") > 0
					DbSelectArea("TMP")
					TMP->(DbCloseArea())
				EndIf
				
				dbUseArea(.T.,"TOPCONN",TCGenQry(,,_cQueryM460FIL),"TMP",.F.,.T.)
		
				
				While !TMP->(Eof())
					If Upper(ALLTRIM(TMP->ESTCLI)) == "RJ" //.AND. !EMPTY(ALLTRIM(TMP->PEDRIO))
						If Empty(_cFilQry)
							_cFilQry := ALLTRIM(TMP->PEDIDO)+" " 
						Else 
							_cFilQry += ALLTRIM(TMP->PEDIDO)+" "
						EndIf
					EndIf	
					TMP->( DbSkip() )
				Enddo
				
				If !Empty(_cFilQry)
					_cPedRio := StrTran(ALLTRIM(_cFilQry)," ",",")
				EndIf
				
				If !Empty(_cPedRio)
					_cSC9Fil := " !(C9_PEDIDO $ '"+_cPedRio+"') "
				Else
					_cSC9Fil := " C9_FILIAL = '"+cFilAnt+"' "
				EndIf
				
				
				DbSelectArea("TMP")
				TMP->(DbCloseArea())
			Else
				_cSC9Fil := " C9_FILIAL = '"+cFilAnt+"' "
			EndIf
		Else
			_cSC9Fil := " C9_FILIAL = '"+cFilAnt+"' "
		EndIf
	Else
		_cSC9Fil := " C9_FILIAL = '"+cFilAnt+"' "
	EndIf
	
	RestArea(_aArea)
	SC9->(RestArea(_cAreaSC9))
	
Return(_cSC9Fil)
