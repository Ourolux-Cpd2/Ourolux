/*                     
Validação da Quantidade Vendida
Pesquisa automaticamente notas fiscal de entrada quando se referir a devolução
DEVOLUÇAO
Gatilho DO campo C6_QTDVEN 
*/

User Function VldQtdVd()

If M->C5_TIPO = 'D'
   /*
   If M->C5_TIPO <> '900'

      _cCond := '<>'

   Else

      _cCond := '='

   End

   _dDta := dDataBase
   _dDta -= 365
   _cQry := 'SELECT     D1_DOC, D1_SERIE, D1_ITEM, D1_VUNIT, D1_QUANT - D1_QTDEDEV AS QTDE '
   _cQry += 'FROM         SD1010 '
   _cQry += "WHERE     (D1_QUANT - D1_QTDEDEV >= " + StrZero( aCols[ n ][ _nPosQtd ], 6 ) + ") AND "
   _cQry += "(D1_TIPO = 'N') AND "
   _cQry += "(D1_EMISSAO BETWEEN '" + DtoS( _dDta ) + "' AND '" + DtoS( dDataBase ) + "') AND (D_E_L_E_T_ <> '*') AND "
   _cQry += "(D1_FORNECE = '" + M->C5_CLIENTE + "') AND (D1_LOJA = '" + M->C5_LOJACLI + "' ) AND "
   _cQry += "(D1_COD = '" + rTrim( aCols[ n ][ _nPosPrd ] ) + "') AND (D1_SERIE " + _cCond + " 'ORC') "
   _cQry += " AND D1_FILIAL = '" + xFilial("SD1") + "' "  // CURITIBA
   _cQry += 'ORDER BY D1_VUNIT DESC'

   dbUseArea( .T., "TOPCONN", TCGENQRY(,,_cQry), 'NFD' )

   aCols[ n ][ _nPosUni ] := D1_VUNIT

   If D1_DOC <> ' '

      aCols[ n ][ _nPosNFD ] := D1_DOC
      aCols[ n ][ _nPosSer ] := D1_SERIE
      aCols[ n ][ _nPosIte ] := D1_ITEM

   Else

      If M->C5_CLIENTE <> '000992'

         MsgInfo( 'Nota Fiscal de Origem inexistente para este produto, verifique ... ' )
         aCols[ n ][ _nPosNFD ] := ' '

      Else

         aCols[ n ][ _nPosUni ] := Round( SB1->B1_CUSTD, 2 )
         aCols[ n ][ _nPosSer ] := '000'
         aCols[ n ][ _nPosIte ] := ' '
         aCols[ n ][ _nPosNFD ] := '000000'

      End

   End
   */
   aCols[ n ][ _nPosLoc ] := '09'

   // NFD->( dbCloseArea() )

EndIf

If M->C5_TIPO $ 'T'    // 'TD'

	aCols[ n ][ _nPosVlr ] := aCols[ n ][ _nPosPrc ]
	aCols[ n ][ _nPosVlr ] *= aCols[ n ][ _nPosQtd ]
	aCols[ n ][ _nPosVlr ] := Round( aCols[ n ][ _nPosVlr ], 2 )

   	aCols[ n ][ _nPosQdL ] := aCols[ n ][ _nPosQtd ]

End

Return( aCols[ n ][ _nPosVlr ] )