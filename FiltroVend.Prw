/*

  Esta função tem por finalidade filtrar os pedidos pelos seus respectivos vendedores/supervisores

*/
User Function FiltroVend( _cCod, _aSql, _cVnd )

cTpVnd :=''
_lExt := .F. 
_cCod := RetCodUsr()
_fSA3 := xFilial( 'SA3' )

If _cCod $ [000027.000052.]

    _cCod := '000065'

ElseIf _cCod = '000065'

   _cCod := '000037'

End

dbSelectArea( "SA3" )
_cSup := Space( 6 )
SA3->( dbSetOrder( 7 ) )

If ! ( SA3->( dbSeek( xFilial( 'SA3' ) + _cCod, .F. ) ) )

   _cCod := "'000000"

Else                          

   _cCod := "'" 
   _cCod += SA3->A3_COD
   _aSup := {}
   SA3->( dbSetOrder( 5 ) )

   cTpVnd := SA3->A3_TIPO 
   
   If SA3->A3_TIPO <> 'I'
      _lExt := .T.
   End

   If SA3->A3_GEREN <> Space( 6 )

      _cGer := SA3->A3_COD
      _aSup := { SA3->A3_COD }

      If ( SA3->( dbSeek( xFilial( 'SA3' ) + _cGer, .F. ) ) )

         While _cGer = SA3->A3_SUPER

               _nPos := aScan( _aSup, { |x| x = SA3->A3_COD } )
  
               If _nPos = 0

                  aAdd( _aSup, SA3->A3_COD )
        
               End

               _cCod += "','"
               _cCod += SA3->A3_COD
               SA3->( dbSkip() )
            
         End

      End

  ElseIf SA3->A3_SUPER <> '      '

         _aSup := { SA3->A3_COD }
         _cCod += "','"
         _cCod += SA3->A3_COD
 
  End
                                                                                                             
End

_cCod += "'"
_cUsr := RetCodUsr()
_cVnd := Substr( _cCod, 2, 6 )

_nLen := Len( _cCod )
_sCod:= ','

For i := 1 To _nLen

    If Substr( _cCod, i, 1 ) <> "'"
       
       _sCod += Substr( _cCod, i, 1 )

    End
   
Next

If (cTpVnd == 'E') // vendedor externo
	_aSql := "( SA1->A1_ATIVIDA <> 'DIRET') .AND. "
   _aSql += "( (A1_VEND $ '" + _sCod + ",000000,      ') .OR. (A1_SUPER $'" + _sCod + "') ) "
ElseIf (cTpVnd == 'C') // cliente
	_aSql := "(A1_VEND $ '" + _sCod + "') .OR. (A1_SUPER $'" + _sCod + "' ) " 
ElseIf (_cUsr <> '000080') // intrnos
	_aSql := "( SA1->A1_ATIVIDA <> 'DIRET') .AND. "
   _aSql += "( (A1_VEND $ '" + _sCod + ",000000,      ') .OR. (A1_SUPER $'" + _sCod + "') ) "
Else  // compras
	_aSql := "(A1_ATIVIDA = 'DIRET') .OR. "
   _aSql += "(A1_SUPER $ '" + _sCod + ",000000,      ') .OR. "
   _aSql += "( A1_VEND = '" + _cVnd + "')"
   _cCod += ",'000000'"
End

SA3->( dbSetOrder( 1 ) )                                                    

Return( _cCod, _aSql, _cVnd )

