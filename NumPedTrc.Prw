
/*
  Criado em: 14/08/2002
  Autor: Sérgio Santana
  Objetivo: Esta procedure tem por objetivo retornar o proximo numero da troca na inclusão

*/


User Function NumPedTrc()
Public cRetTip

cRetTip := ' '
_cProc  := ProcName( 12 )
_cProc  := AllTrim( _cProc )
_cNum   := GetSXENum( 'SC5', 'C5_NUM' )

//If _cProc = 'U_MTRCFIL'

   SC5->( dbSeek( xFilial( 'SC5' )+'010000', .T. ) )
   SC5->( dbSkip( -1 ) )

   If SC5->C5_ORCAM = 'T'

      _cNum   := SC5->C5_NUM
      _cNum   := Val( _cNum )
      _cNum   ++
      _cNum   := StrZero( _cNum, 6 )
      cRetTip := 'T'

      SD1->( dbSetOrder( 8 ) )
      SD1->( dbSeek( xFilial( 'SD1' ) + 'TRC' + _cNum, .T. ) )


   End

//End

Return( _cNum )