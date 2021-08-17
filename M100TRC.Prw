/*

                            Filtro para troca de mercadoria

*/
User Function M100TRC()

_sSF1 := 'F1_FILIAL== "'+xFilial("SF1")+'"          
_sSF1 += ' .And. F1_SERIE == "TRC"'
//_sSF1 := "@ (F1_SERIE = 'TRC') AND (D_E_L_E_T_ <> '*')"

_sSD1 := 'D1_FILIAL== "'+xFilial("SD1")+'"          
_sSD1 += ' .And. D1_SERIE == "TRC"'
//_sSD1 := "@ (D1_SERIE = 'TRC') AND (D_E_L_E_T_ <> '*')"

SF1->( dbSetFilter( { || &_sSF1 }, _sSF1 ))
SD1->( dbSetFilter( { || &_sSD1 }, _sSD1 ))

MATA103()

SD1->( dbClearFilter( NIL ) ) 
SF1->( dbClearFilter( NIL ) ) 

Return( NIL )
