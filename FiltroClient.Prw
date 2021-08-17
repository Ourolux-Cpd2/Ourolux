User Function FiltroClient()

If cNivel < 9

   If _aSql <>  ' '

      SA1->( dbSetFilter( { || &_aSql }, _aSql ) )

   End

End

Return()