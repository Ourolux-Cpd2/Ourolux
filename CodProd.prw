#INCLUDE "TOPCONN.CH"

User Function CodProd()

_aTrc := {;
           {'SD1010','D1_COD'    },;
           {'SD2010','D2_COD'    },;
           {'SD3010','D3_COD'    },;
           {'SC6010','C6_PRODUTO'},;
           {'SC7010','C7_PRODUTO'},;
           {'SC1010','C1_PRODUTO'},;
           {'SC9010','C9_PRODUTO'},;
           {'SCK010','CK_PRODUTO'} ;
         }
/*           {'SB2010','B2_COD'    } ;*/
dbUseArea(.T., "DBFCDX", "TROCA", 'TRC', .F., .T.)


Processa( {|| RunProc()} )

TRC->( dbCloseArea() )

Return

Static Function RunProc()

_nLen := Len ( _aTrc )
ProcRegua( _nLen * TRC->( RecCount() ) )

For n := 1 To _nLen

    TRC->( dbGoTop() )

    While ! trc->( Eof() )

       IncProc()

         _cQuery := 'UPDATE dbo.' + _aTrc[ n ][ 1 ] + ' SET ' + _aTrc[ n ][ 2 ]
         _cQuery += ' = ' + "'" + TRC->ATUAL + "'"
         _cQuery += ' WHERE ' + _aTrc[ n ][ 2 ] + " = '" + TRC->ANTIGO + "'"
         _nRet := TCSQLEXEC( _cQuery )

       TRC->( dbSkip() )

    End

Next

Return
