#INCLUDE "rwmake.ch"

User Function SaldoEst()

@ 050,01 To 200,500 Dialog Odlg Title "Saldo em Estoque"
@ 003,09 to 100,400

SB2->( dbSeek( xFilial( "SB2" )+DA1->DA1_CODPRO+"01") )

_nQatu := SB2->B2_QATU
_nQatu -= SB2->B2_RESERVA

If _nQatu > 3000
   _nQatu := 3000
End

@ 011,11 Say "Saldo: " + AllTrim( Str( _nQAtu, 10, 0 ) )

@ 60,25 BMPBUTTON TYPE 01 ACTION Close( oDlg )
@ 60,65 BMPBUTTON TYPE 02 ACTION Cancela()
Activate Dialog oDlg Centered

Static Function Cancela
Close(oDlg)

Return (.T.)
