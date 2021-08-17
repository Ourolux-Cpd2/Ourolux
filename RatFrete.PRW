/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³RATFRETE  ºAutor  ³Microsiga           º Data ³  09/26/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
#Include 'rwmake.ch'

User Function RatFrete()

If cEspecie = 'NFST' .And. Inclui
	RatNota()  
EndIf
                                                 
Return( Nil )

Static Function RatNota()

Local nTotConheci := 0
Local nPosCod := aScan( aHeader, { |x| Trim( x[ 2 ] ) == "D1_COD"     } )
Local nPosNot := aScan( aHeader, { |x| Trim( x[ 2 ] ) == "D1_NFORI"   } )
Local nPosSer := aScan( aHeader, { |x| Trim( x[ 2 ] ) == "D1_SERIORI" } )
//Local nPosQde := aScan( aHeader, { |x| Trim( x[ 2 ] ) == "D1_QUANT"   } )
Local nPosVlr := aScan( aHeader, { |x| Trim( x[ 2 ] ) == "D1_VUNIT"   } )
Local nPosCst := aScan( aHeader, { |x| Trim( x[ 2 ] ) == "D1_CUSTO"   } )
Local nPosTot := aScan( aHeader, { |x| Trim( x[ 2 ] ) == "D1_TOTAL"   } )   
Local nLen    := Len( aCols )
Local nTotValMerc    := 0
Local aReg    := {}
Local fSF2    := xFilial( 'SF2' )
Local fSF1    := xFilial( 'SF1' )
Local i       := 0
Local nSoma   := 0

@ 56,42 TO 323,505 DIALOG oDlg TITLE "Rateio de frete"
@ 18,10 TO 74,222
@ 33,24 Say 'Valor'
@ 43,24 Get nTotConheci Picture '@RE 999,999.99' Size 35,8

@ 81,190 BMPBUTTON TYPE 1 ACTION Close(oDlg)
@ 100,44 Say 'Digite o valor de conhecimento de frete a ser rateado:'

ACTIVATE DIALOG oDlg CENTERED
  
For i := 1 To nLen

    SF2->( dbSeek( fSF2 + aCols[ i ][ nPosNot ] + aCols[ i ][ nPosSer ],.T.))

    If SF2->F2_DOC == aCols[ i ][ nPosNot ]

       aAdd( aReg, { 'S', SF2->F2_VALMERC, i } )
       nTotValMerc += SF2->F2_VALMERC

    Else

       SF1->( dbSeek(fSF1 + aCols[ i ][ nPosNot ] + aCols[ i ][ nPosSer ] + Space( 8 ),.T.))

       If SF1->F1_DOC = aCols[ i ][ nPosNot ]

          aAdd( aReg, {'E', SF1->F1_VALMERC, i } )
          nTotValMerc += SF1->F1_VALMERC

       Else

          aAdd( aReg, {'S',1,i } )
          nTotValMerc += 1

       EndIf
          
    EndIf

Next

nSoma := 0
nLen  := Len( aReg )

For i := 1 To nLen  
    n := i
    aReg[ i ][ 2 ] /= nTotValMerc
    aReg[ i ][ 2 ] := Round( aReg[ i ][ 2 ], 4 )
    aReg[ i ][ 2 ] *= nTotConheci
    aReg[ i ][ 2 ] := Round( aReg[ i ][ 2 ], 2 )
    nSoma  += aReg[ i ][ 2 ]
    aCols[ i ][ nPosVlr ] := aReg[ i ][ 2 ]
    //aCols[ i ][ nPosVlr ] /= aCols[ i ][ nPosQde ]
    aCols[ i ][ nPosCst ] := aCols[ i ][ nPosVlr ]
    vTst := a103Trigger( "D1_VUNIT" )
    aCols[i][ nPosTot ] := aReg[ i ][ 2 ]
    vTst := a103Trigger( "D1_TOTAL" )
Next
/*
i := nLen
nSoma  := nTotConheci - nSoma
aCols[ i ][ nPosTot ] += nSoma
vTst := a103Trigger( "D1_TOTAL" )
aCols[ i ][ nPosVlr ] := aCols[ i ][ nPosTot ]
aCols[ i ][ nPosVlr ] /= aCols[ i ][ nPosQde ]
vTst := a103Trigger( "D1_VUNIT" )
aCols[ i ][ nPosCst ] := aCols[ i ][ nPosVlr ]
*/
Return()