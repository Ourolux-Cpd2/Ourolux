/*

              GATILHO D1_TES -- ROMANEIOS
   
*/

#Include 'rwmake.ch'

User Function Vld163()

If cEspecie = 'NFST'

   _nPosTES := aScan( aHeader, { |x| Trim( x[ 2 ] ) == 'D1_TES' } )

   If n = 1

      _nPosCF  := aScan( aHeader, { |x| Trim( x[ 2 ] ) == 'D1_CF'  } )
      aCols[ n ][ _nPosTES ] := '163'
      aCols[ n ][ _nPosCF  ] := '1303'
      RecalcNot()
      n := 1

   End

End
                                                 
Return( '163' )

Static Function RecalcNot()

nTotNot := 0

@ 56,42 TO 323,505 DIALOG oDlg6 TITLE "Romaneio"
@ 18,10 TO 74,222
@ 33,24 Say 'Valor'
@ 43,24 Get nTotNot Picture '@RE 999,999.99' Size 35,8

@ 81,190 BMPBUTTON TYPE 1 ACTION Close(oDlg6)
@ 100,44 Say 'Esta rotina tem como finalidade realizar o  rateio do roma-'
@ 110,44 Say 'neio para as Notas Fiscais de Saida e gravação do seu valor'
@ 120,44 Say 'final'

ACTIVATE DIALOG oDlg6 CENTERED

_nPosCod := aScan( aHeader, { |x| Trim( x[ 2 ] ) == "D1_COD"     } )
_nPosNot := aScan( aHeader, { |x| Trim( x[ 2 ] ) == "D1_NFORI"   } )
_nPosSer := aScan( aHeader, { |x| Trim( x[ 2 ] ) == "D1_SERIORI" } )
_nPosQde := aScan( aHeader, { |x| Trim( x[ 2 ] ) == "D1_QUANT"   } )
_nPosVlr := aScan( aHeader, { |x| Trim( x[ 2 ] ) == "D1_VUNIT"   } )
_nPosCst := aScan( aHeader, { |x| Trim( x[ 2 ] ) == "D1_CUSTO"   } )
_nPosTot := aScan( aHeader, { |x| Trim( x[ 2 ] ) == "D1_TOTAL"   } )   
_nLen    := Len( aCols )
_nTot    := 0
_aReg    := {}
_fSF2    := xFilial( 'SF2' )
_fSF1    := xFilial( 'SF1' )
   
For _n := 1 To _nLen

    SF2->( dbSeek( _fSF2                   + ;
                   aCols[ _n ][ _nPosNot ] + ;
                   aCols[ _n ][ _nPosSer ] , ;
                   .T.                       ;
                 )                           ;
         )

    If SF2->F2_DOC = aCols[ _n ][ _nPosNot ]

       aAdd( _aReg, { 'S', SF2->F2_VALMERC, _n } )
       _nTot += SF2->F2_VALMERC

    Else

       SF1->( dbSeek( _fSF1                   + ;
                      aCols[ _n ][ _nPosNot ] + ;
                      aCols[ _n ][ _nPosSer ] + ;
                      Space( 8 )              , ;
                      .T.                       ;
                    );
             )


       If SF1->F1_DOC = aCols[ _n ][ _nPosNot ]

          aAdd( _aReg, {'E', SF1->F1_VALMERC, _n } )
          _nTot += SF1->F1_VALMERC

       Else

          aAdd( _aReg, {'S', 1, _n } )
          _nTot += 1

       End
          
    End

Next

_nSoma := 0
_nLen  := Len( _aReg )

For _n := 1 To _nLen

    aCols[ _n ][ _nPosTES ] := '163'
    aCols[ _n ][ _nPosCF  ] := '1303'  
    n    := _n
    vTst := a103Trigger( "D1_TES" )
    _aReg[ _n ][ 2 ] /= _nTot
    _aReg[ _n ][ 2 ] := Round( _aReg[ _n ][ 2 ], 4 )
    _aReg[ _n ][ 2 ] *= nTotNot
    _aReg[ _n ][ 2 ] := Round( _aReg[ _n ][ 2 ], 2 )
    _nSoma  += _aReg[ _n ][ 2 ]
    aCols[ _n ][ _nPosVlr ] := _aReg[ _n ][ 2 ]
    aCols[ _n ][ _nPosVlr ] /= aCols[ _n ][ _nPosQde ]
    aCols[ _n ][ _nPosCst ] := aCols[ _n ][ _nPosVlr ]
    vTst := a103Trigger( "D1_VUNIT" )
    aCols[ _n ][ _nPosTot ] := _aReg[ _n ][ 2 ]
    vTst := a103Trigger( "D1_TOTAL" )
    
Next

_n      := _nLen
_nSoma  := nTotNot - _nSoma
aCols[ _n ][ _nPosTot ] += _nSoma
vTst := a103Trigger( "D1_TOTAL" )
aCols[ _n ][ _nPosVlr ] := aCols[ _n ][ _nPosTot ]
aCols[ _n ][ _nPosVlr ] /= aCols[ _n ][ _nPosQde ]
vTst := a103Trigger( "D1_VUNIT" )
aCols[ _n ][ _nPosCst ] := aCols[ _n ][ _nPosVlr ]

Return()