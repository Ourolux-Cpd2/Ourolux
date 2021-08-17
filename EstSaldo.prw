#INCLUDE "rwmake.ch"

User Function EstSaldo()

_cProduto := aCol[ n ][ _nPosPrd ]
_cLocal   := '01'
_nQde	  := 0 
_nStoK    := 0

dbSelectArea("SB1")
dbSetOrder( 1 )

If ( dbSeek( xFilial() + _cProduto, .F. ) )

   dbSelectArea( "SB2" )
   dbSetOrder( 1 )

   If ( dbSeek( xFilial() + _cProduto + _cLocal, .F. ) )

      if (SB2->B2_RESERVA >= 0 .AND. SB2->B2_QPEDVEN >= 0)
      	_nStok := (SB2->B2_QATU - SB2->B2_RESERVA - SB2->B2_QPEDVEN)
      	_nQde  := SB2->B2_QATU

      	If cNivel < 7

        	 If _nStok > 3000

            	_nStok := 3000
 
         	End

         	If _nQde > 3000

            	_nQde := 3000
 
         	End

      	End
   	
   	ELSE   
		
		MSGINFO("SALDO ERRADO! FAVOR ENTERE EN CONTATO COM O CPD.")
        Return( .T. )
    
    END
   
   End // dbseek
		
   @ 62,1 TO 293,365 DIALOG oDlg TITLE 'Posição de Estoque'
   @ 0, 2 TO 28, 181 
   @ 31, 2 TO 91, 181 
   @ 8, 4 SAY 'Produto:' SIZE 31, 7
   @ 7, 39 SAY AllTrim( _cProduto ) + " - " + Alltrim( SB1->B1_DESC ) SIZE 140, 7
   @ 16, 5 SAY 'Local:' SIZE 31, 7 
   @ 16, 39 SAY _cLocal SIZE 13, 7
   @ 37, 9 SAY 'Pedido de Vendas em Aberto:' SIZE 92, 7
   @ 37, 118 SAY B2_QPEDVEN  SIZE 53, 7
   @ 45, 9 SAY 'Quantidade Empenhada: ' SIZE 88, 7
   @ 45, 118 SAY B2_QEMP SIZE 53, 7
   @ 53, 9 SAY 'Qdt. Prevista p/Entrar: ' SIZE 88, 7
   @ 53, 118 SAY B2_SALPEDI SIZE 53, 7
   @ 61, 9 SAY "Quantidade Reservada: " SIZE 88, 7 
   @ 61, 118 SAY B2_RESERVA SIZE 53, 7
   @ 69, 9 SAY "Saldo Atual :" SIZE 53, 7
   @ 69, 118 SAY _nQde SIZE 53, 7
   @ 78, 9 SAY "Quantidade Disponivel: " SIZE 53, 7
   @ 78, 118 SAY _nStoK SIZE 53, 7
   @ 98, 149 BMPBUTTON TYPE 1 ACTION Close( oDlg )
   ACTIVATE DIALOG oDlg

End
                  
Return( NIL )