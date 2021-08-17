 /*/
+---------------------------------------------------------------------------+
| Programa  | VldCliEnt | Autor | Sérgio Santana         | Data |23/01/2003³|
+---------------------------------------------------------------------------+
| Descrição | GATILHO Chamado no campo D1_COD                               |
+---------------------------------------------------------------------------+
/*/
/* Validate cliente na entrada de troca */ 

User Function VldCliEnt()

_cCliente := Space( 6 )

_cRisco   := ' '

SA1->( dbSeek( xFilial( 'SA1' ) + CA100FOR + '00', .T. ) )

If CA100FOR = SA1->A1_COD

   While CA100FOR = SA1->A1_COD .And.;
   		SA1->A1_FILIAL == xFilial("SA1")

      If _cRisco < SA1->A1_RISCO
         _cRisco := SA1->A1_RISCO
      End

      SA1->( dbSkip() )      

   End

   SA1->( dbSeek( xFilial( 'SA1' ) + CA100FOR + CLOJA, .F. ) )

   If cNivel > 7
      _cCliente := M->CA100For
   ElseIf SA1->A1_TITPROT > 0
      MsgInfo("Existem titulos protestados para o cliente informado")
   ElseIf SA1->A1_CHQDEVO > 0
      MsgInfo("Existem cheques devolvidos para o cliente informado")
   ElseIf _cRisco == "E"
       MsgInfo("Cliente com risco E")
   ElseIf (dDatabase - 360) > SA1->A1_ULTCOM
       MsgInfo("Ultima compra foi a mais de 1 ano")
   //ElseIf _cRisco == "B" .And. SA1->A1_MATR > 4
   //    MsgInfo("Maior atraso mais de 4 dias")
   Elseif SA1->A1_Cod == "999999" .And. cNivel < 4
       MsgInfo("Cliente consumidor final bloqueado")
   Else
       _cCliente := M->CA100For
   End

End

M->CA100For := _cCliente
If _cCliente = Space( 6 ) 
   aCols[ n ][ 1 ] := Space( 15 )
End

Return ( _cCliente )