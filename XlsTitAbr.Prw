#Include "rwmake.ch"  
User Function XlsTitAbr()
Private cPerg := PadR('XLSTIT',10) 

Pergunte( cPerg , .T. )

Processa( {|lEnd| Grava() }, 'Aguarde, gerando planilha...' )

_cRun := 'C:\Arquivos de Programas\Microsoft Office\Office11\Excel.Exe "Z:\Excel.Csv"'
WinExec( _cRun )

Return( NIL )

Static Function Grava()

_nHnd := fCreate( 'Z:\Excel.Csv', 0 )
_fSBM := xFilial( "SE1" )

_cCRLF := Chr( 13 ) 
_cCRLF += Chr( 10 )

_cQry := 'SELECT  Count( * ) As _nCount '
_cQry += 'FROM    SE1010 '
_cQry += "WHERE  (E1_SALDO <> 0) AND (E1_VENCREA BETWEEN '" + DtoS( MV_PAR01 ) + "' AND '" + DtoS( MV_PAR02 ) + "') AND "
_cQry += "       (E1_TIPO NOT IN ('NCC')) AND (E1_PREFIXO BETWEEN '" + MV_PAR03 + "' AND '" + MV_PAR04 + "') AND "
_cQry += "       (E1_PORTADO BETWEEN '" + MV_PAR05 + "' AND '" + MV_PAR06 + "') AND (D_E_L_E_T_ <> '*') "
_cQry += "AND E1_FILIAL = '" + xFilial("SE1") + "' "  // CURITIBA

dbUseArea( .T., "TOPCONN", TCGENQRY(,,_cQRY), 'QRY' )

_nRegua := QRY->_nCount

QRY->( dbCloseArea() )

_cQry := 'SELECT  E1_PREFIXO As Prefixo , E1_NUM     As Titulo , E1_PARCELA As Parcela, E1_TIPO  As Tipo ,  E1_PORTADO As Portador,'
_cQry += '        E1_NUMBCO  As NroBco  , E1_EMISSAO As Emissao, E1_VENCREA As VencReal, E1_VALOR As Valor , E1_SALDO As Saldo     '
_cQry += 'FROM    SE1010 '
_cQry += "WHERE  (E1_SALDO <> 0) AND (E1_VENCREA BETWEEN '" + DtoS( MV_PAR01 ) + "' AND '" + DtoS( MV_PAR02 ) + "') AND "
_cQry += "       (E1_TIPO NOT IN ('NCC')) AND (E1_PREFIXO BETWEEN '" + MV_PAR03 + "' AND '" + MV_PAR04 + "') AND "
_cQry += "       (E1_PORTADO BETWEEN '" + MV_PAR05 + "' AND '" + MV_PAR06 + "') AND (D_E_L_E_T_ <> '*') "
_cQry += "AND E1_FILIAL = '" + xFilial("SE1") + "' "  // CURITIBA
_cQry += "ORDER BY E1_NUM, E1_PARCELA, E1_PREFIXO"

dbUseArea( .T., "TOPCONN", TCGENQRY(,,_cQRY), 'QRY' )

_cHtml := 'Prefixo;'
_cHtml += 'Nro Titulo;'
_cHtml += 'Parcela;'
_cHtml += 'Tipo;'
_cHtml += 'Portador;'
_cHtml += 'Nro Banco;'
_cHtml += 'Emissão;'
_cHtml += 'Vencto Real;'
_cHtml += 'Valor;'
_cHtml += 'Saldo;'
_cHtml += _cCRLF

_nLen := Len( _cHtml )
fWrite( _nHnd, _cHtml, _nLen )

ProcRegua( _nRegua )

While ! ( Qry->( Eof() ) )

   _cHtml := Qry->Prefixo
   _cHtml += ';'
   _cHtml += Qry->Titulo 
   _cHtml += ';'
   _cHtml += Qry->Parcela
   _cHtml += ';'
   _cHtml += Qry->Tipo
   _cHtml += ';'
   _cHtml += Qry->Portador
   _cHtml += ';'
   _cHtml += Qry->NroBco
   _cHtml += ';'

   _cDta := Substr( Emissao, 7, 2 )
   _cDta += '/'
   _cDta += Substr( Emissao, 5, 2 )
   _cDta += '/'
   _cDta += Substr( Emissao, 1, 4 )

   _cHtml += _cDta
   _cHtml += ';'

   _cDta := Substr( VencReal, 7, 2 )
   _cDta += '/'
   _cDta += Substr( VencReal, 5, 2 )
   _cDta += '/'
   _cDta += Substr( VencReal, 1, 4 )

   _cHtml += _cDta
   _cHtml += ';'

   _cHtml += lTrim( Transform( Qry->Valor, "@E 999999999.99" ) )
   _cHtml += ';'

   _cHtml += lTrim( Transform( Qry->Saldo, "@E 999999999.99" ) )
   _cHtml += ';'

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
