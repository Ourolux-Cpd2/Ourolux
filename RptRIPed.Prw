#INCLUDE 'rwmake.ch'

User Function RptRIPed()

_fSC5  := xFilial( 'SC5' )
_cGet2 := Space( 6 )

@ 56,42 TO 280,505 DIALOG oDlg6 TITLE "Reimpressão dos Pedidos de Venda"
@ 8,10 TO 84,222
@ 33,24 Say 'Pedido nº'
@ 43,24 Get _cGet2 Picture '@R 999999' Size 30,9 Valid PsqPed() Object oGet2
@ 91,100 BMPBUTTON TYPE 1 ACTION Grava()
@ 91,139 BMPBUTTON TYPE 2 ACTION Close(oDlg6)

ACTIVATE DIALOG oDlg6 CENTERED

Return( NIL )

Static Function Grava()

If SC5->C5_LIBCP $ 'S ' .And.;
   SC5->C5_TIPENT <> '2'

   If SC5->C5_REIMP > 0 
   
      SC5->( RecLock( 'SC5', .F. ) )
      SC5->C5_REIMP -= 1
      SC5->( MSUnLock() )
      MsgInfo( 'Pedido de Venda enviado à impressora de pedido..' )       
   
   End

Else   

   MsgInfo( 'Pedido de Venda não pode ser impresso, com pendências...' )       

End

ObjectMethod( oGet2, "SetFocus()" )

Return( NIL )

Static Function PsqPed()

If ( SC5->( dbSeek( _fSC5 + _cGet2, .F. ) ) )

   _lRet := .T.

Else

   _lRet := .F.
   MsgInfo( 'Pedido de Venda não cadastrado...' ) 

End

Return( _lRet )