User Function MTRCFIL()
Public _lRes, _fSP3, _fSB1   , _fSB2, _fSC5   , _fSF4, _fDA1,;
       _fSA3, _cEnd, _cBairro, _cCep, _cCidade, _cUf , _cObs

_lRes := GetMV( 'MV_RESERVA' )
_fSP3 := xFilial( 'SP3' )
_fSB1 := xFilial( 'SB1' )
_fSB2 := xFilial( 'SB2' )
_fSC5 := xFilial( 'SC5' )
_fSF4 := xFilial( 'SF4' )
_fDA1 := xFilial( 'DA1' )
_fSA3 := xFilial( 'SA3' )

dbSelectArea( 'SC5' )

_cSql := 'C5_FILIAL== "'+xFilial("SC5")+'"          
_cSql += ' .And. C5_ORCAM == "T" .And. C5_TIPO == "T"'

SC5->( dbSetFilter( { || &_cSql }, _cSql )) 

MATA410()

SC5->( dbClearFilter( NIL ) )

Return( .T.  )
