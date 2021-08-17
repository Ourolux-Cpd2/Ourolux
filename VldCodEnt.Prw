/*
  Criado em: 19/09/2002
  Autor: Sérgio Santana
  Objetivo: Esta procedure tem por objetivo retornar o proximo numero da troca na inclusão

*/

User Function VldCodEnt()
_cSql := "@ (F1_SERIE = 'TRC') AND (D_E_L_E_T_ <> '*')"
SF1->( dbSetFilter( { || &_cSql }, _cSql ) )
SF1->( dbGoBottom() )
SF1->( dbSkip( -1 ) )

_cNum := SF1->F1_DOC

SF1->( dbClearFilter( NIL ) )

If SC5->C5_ORCAM = 'T'

   _cNum   := SF1->F1_DOC
   _cNum   := Val( _cNum )
   _cNum   ++
   _cNum   := StrZero( _cNum, 6 )
   cRetTip := 'T'

End

__Return( _cNum )

Return( _cNum )