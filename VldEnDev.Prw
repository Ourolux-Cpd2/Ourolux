/*

              Pesquisa nota fiscal de devolução cliente
   
*/

#INCLUDE 'rwmake.ch'
User Function VldEnDev()
Local _nPosQtd := aScan( aHeader, { |x| Trim( x[ 2 ] ) == 'D1_QUANT' } )
Local _nPosPrd := aScan( aHeader, { |x| Trim( x[ 2 ] ) == 'D1_COD'   } )
Local _nPosLoc := aScan( aHeader, { |x| Trim( x[ 2 ] ) == 'D1_LOCAL' } )

/*   
   
   _nPosPrc := aScan( aHeader, { |x| Trim( x[ 2 ] ) == 'D1_VUNIT'   } )
   _nPosQtd := aScan( aHeader, { |x| Trim( x[ 2 ] ) == 'D1_QUANT'   } )
   _nPosVlr := aScan( aHeader, { |x| Trim( x[ 2 ] ) == 'D1_TOTAL'   } )
   _nPosNFD := aScan( aHeader, { |x| Trim( x[ 2 ] ) == 'D1_NFORI'   } )
   _nPosSer := aScan( aHeader, { |x| Trim( x[ 2 ] ) == 'D1_SERIORI' } )
   _nPosIte := aScan( aHeader, { |x| Trim( x[ 2 ] ) == 'D1_ITEMORI' } )
   _nPosRet := aScan( aHeader, { |x| Trim( x[ 2 ] ) == 'D1_ICMSRET' } )
   _nPosBRI := aScan( aHeader, { |x| Trim( x[ 2 ] ) == 'D1_BRICMS'  } )


If cSerie = 'TRC'
	SB2->( dbSeek( xFilial( 'SB2' ) + aCols[ n ][ _nPosPrd ] + '01', .F. ) )
    If aCols[ n ][ _nPosQtd ] > SB2->B2_QATU
    	MsgInfo( 'Saldo em estoque insuficiente, ' + lTrim( Str( SB2->B2_QATU,  6 ) ) + ' estoque atual'  )
	End
End
*/
_cGet1 := '    '
@ 96,42 TO 323,505 DIALOG oDlg6 TITLE "Tipo de Material"
@ 8,10 TO 84,222
@ 33,24 Say 'Tipo de Marterial '
@ 43,60 Get _cGet1 Picture '!!!!' Size 30,9 Valid TipoProd()
@ 91,139 BMPBUTTON TYPE 1 ACTION Close(oDlg6)
ACTIVATE DIALOG oDlg6 CENTERED

If _cGet1 <> 'BOM'
	aCols[ n ][ _nPosLoc ] := '09'
Else
	aCols[ n ][ _nPosLoc ] := '01'
End

Return( aCols[ n ][ _nPosQtd ] )


Static Function TipoProd()

If ! _cGet1 $[BOM .RUIM]
   lRet := .F.
Else
   lRet := .T.
End

Return( lRet )