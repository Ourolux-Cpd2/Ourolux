/*

     Filtro contas a pagar somente romaneios (Bassit)


*/

User Function F050Fil()

dbSelectArea( 'SE2' )
Set Filter To SE2->E2_PREFIXO = 'OS '
FINA050()
Set Filter To

Return( NIL  )