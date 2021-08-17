User Function RptTblPrc()

Processa( {|lEnd| Grava() }, 'Aguarde, gerando tabela...' )

Return( NIL )

Static Function Grava()

_nHnd := fCreate( 'Z:\TabPreco.csv', 0 )

_fSBM := xFilial( "SBM" )

_cCod := "22','10','07','08','11','55','38','29','40','06','09"
_cCRLF := Chr( 13 ) + Chr( 10 )
_cQry  := 'SELECT  B1_COD As ProdCodigo, B1_DESC As ProdDesc, B1_QE As ProdQde, B1_UM As ProdUnid, B1_PRSUP As ProdPreco '
_cQry  += 'FROM    SB1010 '
_cQry  += "WHERE     (D_E_L_E_T_ <> '*') AND ( SUBSTRING( B1_COD, 1, 2 ) IN ('" + _cCod + "') ) AND ( B1_IMPLIST = 'S' )" 
_cQry  += "ORDER BY SUBSTRING( B1_COD, 1, 2 ), ProdDesc "

dbUseArea( .T., "TOPCONN", TCGENQRY(,,_cQry), 'Qry' )

ProcRegua( 11 )

_cForn := ''
_dForn := ''
_cComp := ' '
_nComp := 0
_nForn := 0
_lForm := .F.
_aCols := {{}}
_nCols := 0
_nLin  := 1
CabecForn()

While ! Eof()

   _cDesc := ProdDesc
   _cDesc := Stuff( _cDesc, At( _dForn, _cDesc), _nForn, '' )
   _cDesc := Alltrim( _cDesc )

   _nPos  := At( _cComp, _cDesc)

   If _nPos <> 0 .Or. _lForm

      _cDesc := Stuff( _cDesc, _nPos, _nComp, '' )
      _cDesc := Alltrim( _cDesc )

   Else

      RemovProd()
      CabecForn()

   End

   If _cForn <> Substr( ProdCodigo, 1, 2 )

      RemovProd()

      If _nCols < 58

         aAdd( _aCols[ _nLin ], { '', '', '','','' } )
         _nCols ++

      Else

         If _nLin = 2

            GrvLnhTab()
            _nLin  := 0
            _aCols := {{}}

         Else

            aAdd( _aCols, {} )

         End

         _nCols := 0
         _nLin  ++

      End   

      CabecForn()

   End
   
   If _nCols <> 60

      aAdd( _aCols[ _nLin ], { ProdCodigo, _cDesc, Transform( ProdQde, "999" ), ProdUnid, Transform( ProdPreco, If( ProdUnid <> 'MT', "@E 9,999.99", "@E 9,999.9999" ) ) } )
      _nCols ++

   Else

      If _nLin = 2

         GrvLnhTab()
         _nLin  := 0
         _aCols := {{}}

      Else

         aAdd( _aCols   , {} )      

      End

      _nCols := 0
      _nLin ++

   End

   dbSkip()                                               

End
fClose( _nHnd )
QRY->( dbCloseArea() )

_cRun := 'C:\Arquivos de Programas\Microsoft Office\Office11\Excel.Exe "Z:\TabPreco.csv"'
WinExec( _cRun )

Return(NIL)

Static Function CabecForn()

IncProc()
_cForn := Substr( ProdCodigo, 1, 2 )
SBM->( dbSeek( _fSBM + _cForn + '  ', .F. ) )
_dForn := Alltrim( SBM->BM_DESC )
_nForn := Len( _dForn )
_nLen  := Len( _aCols )

RemovProd()

aAdd( _aCols[ _nLen ], { '', _dForn + ' ' + _cComp, '','','' } )
_nCols ++

If _nCols <> 60

   aAdd( _aCols[ _nLen ], { '', '', '','','' } )
   _nCols ++

End   

Return()

Static Function GrvLnhTab()

_nPriCol := Len( _aCols[1] )
_nSegCol := Len( _aCols[2] )

_cHtml := 'Código'
_cHtml += ';'
_cHtml += 'Descrição'
_cHtml += ';'
_cHtml += 'Qde p/Emb.'
_cHtml += ';'
_cHtml += 'Unid.'
_cHtml += ';'
_cHtml += 'Preço'
_cHtml += ';'
_cHtml += ';'

If _nSegCol <> 0

   _cHtml += 'Código'
   _cHtml += ';'
   _cHtml += 'Descrição'
   _cHtml += ';'
   _cHtml += 'Qde p/Emb.'
   _cHtml += ';'
   _cHtml += 'Unid.'
   _cHtml += ';'
   _cHtml += 'Preço'

End   

_cHtml += _cCRLF
_cHtml += _cCRLF
_nLen  := Len( _cHtml )
fWrite( _nHnd, _cHtml, _nLen )

For i := 1 To _nPriCol

    _cHtml := _aCols[ 1 ][ i ][ 1 ]
    _cHtml += ';'
    _cHtml += _aCols[ 1 ][ i ][ 2 ]
    _cHtml += ';'
    _cHtml += _aCols[ 1 ][ i ][ 3 ]
    _cHtml += ';'
    _cHtml += _aCols[ 1 ][ i ][ 4 ]
    _cHtml += ';'
    _cHtml += _aCols[ 1 ][ i ][ 5 ]
    _cHtml += ';'
    _cHtml += ';'    

    If i <= _nSegCol

       _cHtml += _aCols[ 2 ][ i ][ 1 ]
       _cHtml += ';'
       _cHtml += _aCols[ 2 ][ i ][ 2 ]
       _cHtml += ';'
       _cHtml += _aCols[ 2 ][ i ][ 3 ]
       _cHtml += ';'
       _cHtml += _aCols[ 2 ][ i ][ 4 ]
       _cHtml += ';'
       _cHtml += _aCols[ 2 ][ i ][ 5 ]
    
    End       

    _cHtml += ';'
    _cHtml += _cCRLF
    _nLen := Len( _cHtml )
    fWrite( _nHnd, _cHtml, _nLen )

Next    

Return( NIL )

Static Function RemovProd()

If Substr( ProdCod, 1, 2 ) <> '06'

//   Alltrim( Substr( ProdDesc, 1, At( ' ', ProdDesc ) ) )


Else


End


If _cComp <> Alltrim( Substr( ProdDesc, 1, At( ' ', ProdDesc ) ) )

   If ! _lForm

      _cComp := Substr( ProdDesc, 1, At( ' ', ProdDesc ) )
      _cComp := AllTrim( _cComp )
      _nComp := Len( _cComp )

   Else

      _cComp += ' '
      _cComp += Substr( ProdDesc, 1, At( ' ', ProdDesc ) )
      _cComp += AllTrim( _cComp )
      _nComp += Len( _cComp )
      _lFrom := .F.

   End

End

Return( NIL )