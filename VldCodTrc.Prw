/*
  Criado em: 14/08/2002
  Autor: S�rgio Santana
  Objetivo: Esta procedure tem por objetivo retornar o proximo numero da troca na inclus�o

*/

User Function VldCodTrc()

Local cFil := ""
Public cRetTip 


SC5->( dbGoBottom() )

cRetTip := SC5->C5_TIPO

dbSelectArea( 'SF1' )

cFil := "F1_FILIAL == '" + xFilial( 'SF1' ) + "' .and. F1_SERIE == 'TRC'"

Set Filter To &cFil 

dbGoBottom()

_cNum := SF1->F1_DOC

If ( SC5->( dbSeek( xFilial( 'SC5' ) + _cNum, .F. ) ) )

   MsgInfo( 'N�o h� uma entrada para esta saida, por gentileza realize a entrada...' )
   _cNum := '      '
   KeyBoard Chr( 24 )

End

Set Filter To

cRetTip := 'T'

Return( _cNum )