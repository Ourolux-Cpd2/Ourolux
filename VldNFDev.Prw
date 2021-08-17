/* Gatilho chamado no campo C6_NFORI
*/


User Function VldNFDev()

// Caso venha da Rotina Automatica
If Type("L410Auto") != "U" .And. L410Auto
	Return( '000000' )
EndIf

_dDta := dDataBase
_dDta -= 365

_cQry := 'SELECT     D1_DOC, D1_SERIE, D1_ITEM, D1_VUNIT, (D1_QUANT - D1_QTDEDEV) AS QTDE '
_cQry += 'FROM ' + RetSqlName("SD1") + ' SD1 '
_cQry += "WHERE     ( (D1_QUANT - D1_QTDEDEV) >= " + Str( aCols[ n ][ _nPosQtd ], 6, 0 ) + ") AND "
_cQry += "(D1_TIPO = 'N') AND "
_cQry += "(D1_EMISSAO BETWEEN '" + DtoS( _dDta ) + "' AND '" + DtoS( dDataBase ) + "') AND (D_E_L_E_T_ <> '*') AND "
_cQry += "(D1_FORNECE = '" + M->C5_CLIENTE + "') AND (D1_LOJA = '" + M->C5_LOJACLI + "' ) AND "
_cQry += "(D1_COD = '" + rTrim( aCols[ n ][ _nPosPrd ] ) + "') AND (D1_SERIE <> 'ORC') " 
_cQry += " AND D1_FILIAL = '" + xFilial("SD1") + "' "  // CURITIBA
_cQry += 'ORDER BY D1_VUNIT DESC'

dbUseArea( .T., "TOPCONN", TCGENQRY(,,_cQry), 'NFD' )

aCols[ n ][ _nPosVlr ] := D1_VUNIT
aCols[ n ][ _nPosVlr ] *= aCols[ n ][ _nPosQtd ]
aCols[ n ][ _nPosVlr ] := Round( aCols[ n ][ _nPosVlr ], 2 )
aCols[ n ][ _nPosPrc ] := D1_VUNIT
aCols[ n ][ _nPosSer ] := D1_SERIE
aCols[ n ][ _nPosIte ] := D1_ITEM

If M->C5_CLIENTE <> '000996'

   _cNota := D1_DOC

Else

  SB1->( dbSeek( xFilial( 'SB1' ) + aCols[ n ][ _nPosPrd ], .F. ) )
  aCols[ n ][ _nPosVlr ] := Round( SB1->B1_CUSTD, 2 )
  aCols[ n ][ _nPosPrc ] := aCols[ n ][ _nPosVlr ]
  aCols[ n ][ _nPosVlr ] *= aCols[ n ][ _nPosQtd ]
  aCols[ n ][ _nPosVlr ] := Round( aCols[ n ][ _nPosVlr ], 2 )
  aCols[ n ][ _nPosSer ] := 'SEM'
  aCols[ n ][ _nPosIte ] := '00'
  _cNota := '000000'

End

NFD->( dbCloseArea() )

Return( _cNota )