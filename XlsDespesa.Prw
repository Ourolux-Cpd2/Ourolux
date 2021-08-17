#Include "rwmake.ch"  
User Function Despesa()
Private cPerg := PadR('XLSTIT',10)

Pergunte( cPerg , .T. )

Processa( {|lEnd| Grava() }, 'Aguarde, gerando planilha...' )

_cRun := 'C:\Arquivos de Programas\Microsoft Office\Office11\Excel.Exe "Z:\Excel.Csv"'
WinExec( _cRun )

Return( NIL )

Static Function Grava()

_nHnd := fCreate( 'Z:\Excel.Csv', 0 )
_fSBM := xFilial( "SE2" )

_cCRLF := Chr( 13 ) 
_cCRLF += Chr( 10 )

_cQry := 'SELECT  Count( * ) As _nCount '
_cQry += 'FROM    SE2010 '
_cQry += "WHERE  (E2_SALDO <> 0) AND (E2_VENCREA BETWEEN '" + DtoS( MV_PAR01 ) + "' AND '" + DtoS( MV_PAR02 ) + "') AND "
_cQry += "       (E2_PREFIXO BETWEEN '" + MV_PAR03 + "' AND '" + MV_PAR04 + "') AND "
_cQry += "       (E2_PORTADO BETWEEN '" + MV_PAR05 + "' AND '" + MV_PAR06 + "') AND (D_E_L_E_T_ <> '*') "  
_cQry += "AND E2_FILIAL = '" + xFilial("SE2") + "' "  // CURITIBA

dbUseArea( .T., "TOPCONN", TCGENQRY(,,_cQRY), 'QRY' )

_nRegua := QRY->_nCount

QRY->( dbCloseArea() )

_cQry := 'SELECT  E2_TIPO  As Tipo , E2_NATUREZ As Natureza,'
_cQry += '        SUBSTRING( E2_VENCREA, 1, 6 ) As VencReal, SUM( E2_VALOR ) As Valor , Sum( E2_SALDO ) As Saldo     '
_cQry += 'FROM    SE2010 '
_cQry += "WHERE  (E2_VENCREA BETWEEN '" + DtoS( MV_PAR01 ) + "' AND '" + DtoS( MV_PAR02 ) + "') AND "
_cQry += "       (E2_PREFIXO BETWEEN '" + MV_PAR03 + "' AND '" + MV_PAR04 + "') AND "
_cQry += "       (E2_PORTADO BETWEEN '" + MV_PAR05 + "' AND '" + MV_PAR06 + "') AND (D_E_L_E_T_ <> '*') "
_cQry += "AND E2_FILIAL = '" + xFilial("SE2") + "' "  // CURITIBA
_cQry += "GROUP BY E2_TIPO, E2_NATUREZ, SUBSTRING( E2_VENCREA, 1, 6 ) "
_cQry += "ORDER BY E2_TIPO"

dbUseArea( .T., "TOPCONN", TCGENQRY(,,_cQRY), 'QRY' )

_cHtml := 'Natureza;'
_cHtml += 'Tipo;'
_cHtml += 'Vencto Real;'
_cHtml += 'Valor;'
_cHtml += 'Saldo;'
_cHtml += _cCRLF

_nLen := Len( _cHtml )
fWrite( _nHnd, _cHtml, _nLen )

ProcRegua( _nRegua )

While ! ( Qry->( Eof() ) )

   _cHtml := Qry->Natureza
   _cHtml += ';'
   _cHtml += Qry->Tipo 
   _cHtml += ';'
   _cHtml += Substr(Qry->VencReal,5,2)+'/'+Substr(Qry->VencReal,1,4) 
   _cHtml += ';'
   _cHtml += str(Qry->Valor,12,2)
   _cHtml += ';'
   _cHtml += str(Qry->Saldo,12,2)
   _cHtml += ';'
   
      
   //_cHtml += lTrim( Transform( Qry->Valor, "@E 999999999.99" ) )
   //_cHtml += ';'

   //_cHtml += lTrim( Transform( Qry->Saldo, "@E 999999999.99" ) )
   //_cHtml += ';'

   _cHtml += _cCRLF

   _nLen := Len( _cHtml )
   fWrite( _nHnd, _cHtml, _nLen )
   IncProc()

   Qry->( dbSkip() )

End

_cHtml := _cCRLF

_nLen := Len( _cHtml )
fWrite( _nHnd, _cHtml, _nLen )
fClose( _nHnd )
Qry->( dbCloseArea() )

Return( NIL )
