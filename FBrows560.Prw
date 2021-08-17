/*

                          Filtro para caixa

*/

User Function FBrows560()

_cCod := RetCodUsr()

If  _cCod = '000054'

    dbSelectArea( 'SEU' )
    _cSql := "@ (EU_CAIXA = '002')"
    SEU->( dbSetilter( { || &_cSql }, _cSql ))

End

FINA560()

Return( NIL )