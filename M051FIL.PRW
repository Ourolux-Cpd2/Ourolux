User Function M051FIL()
Public  _cCod
            
_cCod  := RetCodUsr()

If _cCod $ [000080.000105.000161.]
   _bSql := "@( B1_TIPO IN('IM','ME','ML','MM','GG','MC','MO') )"
   SB1->( dbSetFilter( { || &_bSql, &_bSql } ) )
End

MATA105() 
      
Return( NIL  )
