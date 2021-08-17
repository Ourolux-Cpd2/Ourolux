/*

                            Filtro para Classificação de Romaneios

*/
User Function M103ROM()

dbSelectArea( 'SF1' )   

_cFil := 'F1_FILIAL== "'+xFilial("SF1")+'"          
_cFil += ' .And. F1_ESPECIE == "NFST "'

SF1->( dbSetFilter( { || &_cFil }, _cFil ))

MATA103()

SF1->( dbClearFilter( NIL ) )

Return( NIL )
