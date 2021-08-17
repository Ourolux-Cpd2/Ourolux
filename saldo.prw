#INCLUDE "rwmake.ch"

User Function Saldo()

nQde := 0
nStok := 0
nPedCom := 0
nQPedVen := 0
nQEmp := 0
nReserva := 0
cProduto := DA1->DA1_CODPRO
cLocal := "01"
cArea:= Alias()
cInd := Indexord()

dbSelectArea("SB1")
dbSetOrder( 1 )

If  (SB1->( dbSeek( xFilial("SB1") + DA1->DA1_CODPRO ) ))

   dbSelectArea( "SB2" )
   dbSetOrder( 1 )

   If ( dbSeek( xFilial("SB2") + DA1->DA1_CODPRO+cLocal) )

      if (SB2->B2_RESERVA >= 0 .AND. SB2->B2_QPEDVEN >= 0)
      	
      	nStok := (SB2->B2_QATU - SB2->B2_RESERVA - SB2->B2_QPEDVEN)
      	nQde  	:= SB2->B2_QATU
      	nPedCom := SB2->B2_SALPEDI
      	nQPedVen := SB2->B2_QPEDVEN
		nQEmp := SB2->B2_QEMP
		nReserva := SB2->B2_RESERVA


      	If cNivel < 7

        	 If nStok > 3000

            	nStok := 3000
 
         	 End

         	If nQde > 3000

            	nQde := 3000
 
         	End
         	
         	If nPedCom > 3000
            	nPedCom := 3000
         	End

      	End
      
      ELSE
      	
      	MSGINFO("SALDO ERRADO! FAVOR ENTRE EM CONTATO COM O CPD.")
        DbselectArea(cArea)
        Dbsetorder(cInd)
        Return( .T. )
      
      END	

   End  // DBSEEK
   
   @ 62,1 TO 293,365 DIALOG oDlg TITLE 'Posição de Estoque'
   @ 0, 2 TO 28, 181 
   @ 31, 2 TO 91, 181 
   @ 8, 4 SAY 'Produto:' SIZE 31, 7
   @ 7, 39 SAY AllTrim( cProduto ) + " - " + Alltrim( SB1->B1_DESC ) SIZE 140, 7
   @ 16, 5 SAY 'Local:' SIZE 31, 7 
   @ 16, 39 SAY cLocal SIZE 13, 7
   @ 37, 9 SAY 'Pedido de Vendas em Aberto:' SIZE 92, 7
   @ 37, 118 SAY nQPedVen  SIZE 53, 7
   @ 45, 9 SAY 'Quantidade Empenhada:' SIZE 88, 7
   @ 45, 118 SAY nQEmp SIZE 53, 7
   @ 53, 9 SAY 'Qdt. Prevista p/Entrar:' SIZE 88, 7
   @ 53, 118 SAY nPedCom SIZE 53, 7
   @ 61, 9 SAY "Quantidade Reservada :" SIZE 88, 7 
   @ 61, 118 SAY nReserva SIZE 53, 7
   @ 69, 9 SAY "Saldo Atual :" SIZE 53, 7
   @ 69, 118 SAY nQde SIZE 53, 7
   @ 78, 9 SAY "Saldo Disponivel " SIZE 53, 7
   @ 78, 118 SAY nStok SIZE 53, 7
   @ 98, 149 BMPBUTTON TYPE 1 ACTION Close( oDlg )
   ACTIVATE DIALOG oDlg
End

DbselectArea(cArea)
Dbsetorder(cInd)

Return( .T. )
