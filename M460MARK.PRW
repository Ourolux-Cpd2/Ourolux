User Function M460MARK()
/* Bloquear o faturamento caso tem bloqueio de estoque para contagem ou falta saldo */
Local _cPedido 	:= ''
Local _aArea 	:= GetArea()
SetPrvt( '_aPedido','_aItens' )

_aPedido := {}
_aItens  := 0
_cFilter := SC9->( dbFilter() )

If ! Empty( _cFilter )

   _cPedido := Substr(_cFilter,At('C9_PEDIDO',_cFilter,),19) + ' AND ' + Substr(_cFilter,Rat('C9_PEDIDO',_cFilter,),19)
   _cQuery  := 'SELECT SC9.C9_OK, SC9.C9_PRODUTO, SC9.C9_ITEM, SC9.C9_PEDIDO, SUM( SC9.C9_QTDLIB ) AS QTD, SC9.C9_LOCAL, SC6.C6_TES AS TES '
   _cQuery  += 'FROM ' + RetSqlName("SC9") + ' SC9 INNER JOIN ' + RetSqlName("SC6") + ' SC6 '
   _cQuery  += 'ON SC9.C9_PEDIDO = SC6.C6_NUM AND SC9.C9_PRODUTO = SC6.C6_PRODUTO '
   _cQuery  += "WHERE     (SC9.D_E_L_E_T_ <> '*') AND (SC6.D_E_L_E_T_ <> '*') AND "
   _cQuery  += '( ' + _cPedido + ' )'
   _cQuery  +=  " AND  (SC9.C9_NFISCAL = '      ' ) AND ( SC9.C9_FILIAL = '" + xFilial( 'SC9' ) + "' ) "
   _cQuery  +=  " AND  SC6.C6_FILIAL = '" + xFilial( 'SC6' ) + "' "
   _cQuery  += 'GROUP BY SC9.C9_OK, SC9.C9_PRODUTO, SC9.C9_ITEM, SC9.C9_PEDIDO, SC9.C9_LOCAL, SC6.C6_TES '
   _cQuery  += 'ORDER BY SC9.C9_PEDIDO'

Else

   _cQuery := 'SELECT SC9.C9_OK, SC9.C9_PRODUTO, SC9.C9_ITEM, SC9.C9_PEDIDO, SUM( SC9.C9_QTDLIB ) AS QTD, SC9.C9_LOCAL, SC6.C6_TES AS TES '
   _cQuery += 'FROM ' + RetSqlName("SC9") + ' SC9 INNER JOIN ' + RetSqlName("SC6") + ' SC6 '
   _cQuery += ' ON SC9.C9_PEDIDO = SC6.C6_NUM AND SC9.C9_PRODUTO = SC6.C6_PRODUTO '
   _cQuery += "WHERE  (SC9.D_E_L_E_T_ <> '*') AND (SC6.D_E_L_E_T_ <> '*') AND (SC9.C9_OK <> '  ') "
   _cQuery += "AND (SC9.C9_NFISCAL = '      ') AND (MONTH(SC9.C9_DATALIB) = '"
   _cQuery += Str( Month( dDataBase ), 2, 0 ) 
   _cQuery += "') AND (YEAR(SC9.C9_DATALIB) = '"
   _cQuery += Str( Year( dDataBase ), 4, 0 ) + "') AND ( SC9.C9_NFISCAL = '      ' ) AND ( SC9.C9_FILIAL = '" + xFilial( 'SC9' ) + "' ) "
   _cQuery += " AND  SC6.C6_FILIAL = '" + xFilial( 'SC6' ) + "' "
   _cQuery += 'GROUP BY SC9.C9_OK, SC9.C9_PRODUTO, SC9.C9_ITEM, SC9.C9_PEDIDO, SC9.C9_LOCAL ,SC6.C6_TES '
   _cQuery += 'ORDER BY SC9.C9_PEDIDO'

End

dbUseArea( .T., "TOPCONN", TCGENQRY(,,_cQuery), 'Query' )

Query->( dbGoTop() )

While ! ( Query->( Eof() ) )

   If ( SB2->( dbSeek( xFilial( 'SB2' ) + Query->C9_PRODUTO + Query->C9_LOCAL, .F. ) ) )

      If DtoS( SB2->B2_DTINV ) <> Space( 8 )

         _cMsg := 'Pedido nº ' + Query->C9_PEDIDO + '/' + Query->C9_ITEM
         _cMsg += ' não pode ser faturado, há um bloqueio para contagem,' + Chr( 13 )
         _cMsg += 'por  favor  informe-se  com  o responsavel pelo bloqueio de estoque  ' + Chr( 13 )
         MsgInfo( _cMsg )

         If aScan( _aPedido, Query->C9_Pedido ) = 0
            aAdd( _aPedido, Query->C9_Pedido )
            _aItens ++
         End

      ElseIf SB2->B2_QATU < Query->QTD
      		
		If (AvalTes(Query->TES,"S","SN"))		
      
			_cMsg := 'Pedido nº ' + Query->C9_PEDIDO + '/' + Query->C9_ITEM
         	_cMsg += ' não pode ser faturado, não há estoque disponível,' + Chr( 13 )
        	_cMsg += 'por  favor,  informe-se  com  o responsavel pelo estoque. ' + Chr( 13 )
			MsgInfo( _cMsg )

         	If aScan( _aPedido, Query->C9_Pedido ) = 0
            	aAdd( _aPedido, Query->C9_Pedido )
            	_aItens ++
         	End
        
        EndIf /* Check TES*/

      End

   End
   
   Query->( dbSkip() )

End  // END WHILE

Query->( dbCloseArea() )

RestArea(_aArea)

Return(_aItens == 0)
