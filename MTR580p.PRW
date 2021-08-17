#Include "rwmake.ch"  
User Function Mtr580p()
Private oFont07,oFont09, oFont10, oFont10n, oFont11,oFont15, oFont16,oFont18
Private oPrint
Private lFirst := .F.
Private cPerg := PadR("RPTVND",10)

_nLin := 580

SA3->( dbSetOrder( 1 ) )
oFont07  := TFont():New("Courier New",08,08,,.T.,,,,,,.T.,.T.)
oFont08  := TFont():New("Courier New",08,08,,.F.,,,,.T.,.F.)
oFont10  := TFont():New("Tahoma",09,09,,.F.,,,,.T.,.F.)
oFont10n := TFont():New("Tahoma",10,10,,.T.,,,,.T.,.F.)
oFont10i := TFont():New("Tahoma",10,10,.T.,.F.,,,,.F.,.T.)		//Normal s/negrito
oFont12  := TFont():New("Tahoma",,12,,.T.,,,,,,)
oFont15  := TFont():New("Tahoma",09,09,,.T.,,,,.T.,.F.)
oFont16  := TFont():New("Tahoma",16,16,,.F.,,,,.T.,.F.)
oFont18  := TFont():New("Tahoma",18,18,,.F.,,,,.T.,.T.)

_aSql := ''
_cVnd := ''
_cCod := ''
_nRed := ''
U_FiltroVend( @_cCod, @_aSql, @_cVnd )
_cCod += ",'      '"

Pergunte( cPerg , .T. )

If MV_PAR09 = 1
   _qSql    := SintVend()
   _cTitulo := 'Vendedor por Ranking'
ElseIf MV_PAR09 = 2
   _qSql := AnaVend()
   _cTitulo := 'Analitico Vendedor'
ElseIf MV_PAR09 = 3
   _qSql := TotEst()
   _cTitulo := 'Sintetico por Estado'
Else
   _qSql := CliVend()
   _cTitulo := 'Cliente por Periodo'
End

oPrint	:= TMSPrinter():New("Vendas")
oPrint:SetPortrait()    //Define que a impressao deve ser RETRATO//
oPrint:Setup()
oPrint:StartPage() 	   // Inicia uma nova pagina

RptStatus({|lEnd| ResuImp(@lEnd,"Relatório de Vendas","SF2")},_cTitulo)

oPrint:Preview()        // Visualiza impressao grafica antes de imprimir
Return( NIL )

Static Function ResuImp()

SetRegua( 3 )

dbUseArea( .T., "TOPCONN", TCGENQRY(,,_qSQL), 'Qry' )

IncRegua()

cFileLogo := "ELETROMEGA.bmp"

oPrint:say(050,230,Chr(255)+"Eletromega Ltda. - EPP",oFont12)
oPrint:Say(100,230,"Av. Bernardino de Campos, 98 5º AND - Paraiso",oFont08 ) 	
oPrint:Say(130,230,"CEP: 04004-040 - São Paulo - SP",oFont08 ) 	
oPrint:Say(160,230,"Telefone: +55 11 2172-1000",oFont08 ) 	
oPrint:Say(190,230,"Fax: +55 11 2172-1031",oFont08 ) 	

If File( cFileLogo )

   oPrint:SayBitmap(050,040, cFileLogo,155,212	) // Tem que estar abaixo do RootPath

End

oPrint:Line(245,030,245,2300)
oPrint:say(250,900,_cTitulo,oFont12)
_nLin := 3701
_nDet := 310
_nVnd := 0
_nTot := 0
_nCst := 0
_nSbt := 0
_vRot := 0
_vTot := QRY->ValMerc
_vSbt := QRY->IcmsRet
_vCst := QRY->VlrCust

If MV_PAR09 <> 3

   _cVnd := QRY->F2_VEND1
   _lVnd := .T.
   SA3->( dbSeek( '01' + QRY->F2_VEND1, .F. ) )
   _nRed := SA3->A3_NREDUZ

End

Set Cent On 

While ! ( QRY->( Eof() ) )

   If MV_PAR09 = 1
      RptSintVend()
   ElseIf MV_PAR09 = 2
      RptAnaVend()
   ElseIf MV_PAR09 = 3
      RptTotEst()
   Else
      RptCliVend()
   End

   QRY->( dbSkip() )

   If MV_PAR09 = 2

      If QRY->F2_VEND1 = _cVnd

         _vTot += QRY->ValMerc
         _vSbt += QRY->IcmsRet
         _vCst += QRY->VlrCust

      Else

         _cDet := Space( 37 )
         _cDet += 'TOTAL VENDEDOR '
         _cDet += _nRed
         _cDet += Space( 6 ) 

         _cDet += Transform( _vTot, "@E 999,999,999.99" )
         _cDet += ' '
         _cDet += Transform( _vSbt, "@E 999,999,999.99" )

         If cNivel > 7

            _vRot := _vTot
            _vRot /= _vCst
            _vRot -= 1
            _vRot *= 100
            _vRot := Round( _vRot, 2 )

            _cDet += ' '
            _cDet += Transform( _vCst, "@E 999,999,999.99" )
            _cDet += ' '
            _cDet += Transform( _vRot , "@E 999.99" )

         End   

         _nLin += 30
         oPrint:Say(_nLin,040,_cDet,oFont07 )
         _nLin += 60

         _nTot += _vTot
         _nSbt += _vSbt
         _nCst += _vCst

         _vTot := QRY->ValMerc
         _vSbt := QRY->IcmsRet
         _vCst := QRY->VlrCust
         _cVnd := QRY->F2_VEND1
         SA3->( dbSeek( '01' + QRY->F2_VEND1, .F. ) )
         _nRed := SA3->A3_NREDUZ
         _lVnd := .T.

      End

   ElseIf MV_PAR09 = 4

      If QRY->F2_VEND1 = _cVnd

         _vTot += QRY->ValMerc
         _vSbt += QRY->IcmsRet
         _vCst += QRY->VlrCust

      Else

         _cDet := Space( 37 )
         _cDet += 'TOTAL VENDEDOR '
         _cDet += _nRed 
         _cDet += Space( 8 ) 

         _cDet += Transform( _vTot, "@E 999,999,999.99" )
         _cDet += '  '
         _cDet += Transform( _vSbt, "@E 999,999,999.99" )

         If cNivel > 7

            _vRot := _vTot
            _vRot /= _vCst
            _vRot -= 1
            _vRot *= 100
            _vRot := Round( _vRot, 2 )

            _cDet += '  '
            _cDet += Transform( _vCst, "@E 999,999,999.99" )
            _cDet += ' '
            _cDet += Transform( _vRot , "@E 999.99" )

         End   

         _nLin += 30
         oPrint:Say(_nLin,040,_cDet,oFont07 )
         _nLin += 60

         _nTot += _vTot
         _nSbt += _vSbt
         _nCst += _vCst

         _vTot := QRY->ValMerc
         _vSbt := QRY->IcmsRet
         _vCst := QRY->VlrCust
         _cVnd := QRY->F2_VEND1
         SA3->( dbSeek( '01' + QRY->F2_VEND1, .F. ) )
         _nRed := SA3->A3_NREDUZ
         _lVnd := .T.

      End

   End   

End

If MV_PAR09 = 1

   _vRot := _nTot
   _vRot /= _nCst
   _vRot -= 1
   _vRot *= 100
   _vRot := Round( _vRot, 2 )
   _nLin += 30

   _cDet := '        T O T A L     '
   _cDet += Space( 15 ) 
   _cDet += Transform( _nTot, "@E 999,999,999.99" )
   _cDet += Space( 5 ) 
   _cDet += Transform( _nSbt, "@E 999,999,999.99" )

   If cNivel > 7

      _cDet += Space( 5 )
      _cDet += Transform( _nCst, "@E 999,999,999.99" )
      _cDet += Space( 5 )
      _cDet += Transform( _vRot, "@E 999.99" )

   End

   oPrint:Say(_nLin,040,_cDet,oFont08 )

ElseIf MV_PAR09 = 2

   _cDet := Space( 37 )
   _cDet += 'TOTAL GERAL DAS VENDAS'
   _cDet += Space( 14 ) 
   _cDet += Transform( _nTot, "@E 999,999,999.99" )
   _cDet += ' '
   _cDet += Transform( _nSbt, "@E 999,999,999.99" )

   If cNivel > 7

      _vRot := _nTot
      _vRot /= _nCst
      _vRot -= 1
      _vRot *= 100
      _vRot := Round( _vRot, 2 )

      _cDet += ' '
      _cDet += Transform( _nCst, "@E 999,999,999.99" )
      _cDet += ' '
      _cDet += Transform( _vRot , "@E 999.99" )

   End   

   _nLin += 30
   oPrint:Say(_nLin,040,_cDet,oFont07 )

ElseIf MV_PAR09 = 4

   _cDet := Space( 37 )
   _cDet += 'TOTAL GERAL    '
   _cDet += Space( 23 ) 
   _cDet += Transform( _nTot, "@E 999,999,999.99" )
   _cDet += '  '
   _cDet += Transform( _nSbt, "@E 999,999,999.99" )

   If cNivel > 7

      _vRot := _nTot
      _vRot /= _nCst
      _vRot -= 1
      _vRot *= 100
      _vRot := Round( _vRot, 2 )

      _cDet += ' '
      _cDet += Transform( _nCst, "@E 999,999,999.99" )
      _cDet += '  '
      _cDet += Transform( _vRot , "@E 999.99" )

   End   

   _nLin += 30
   oPrint:Say(_nLin,040,_cDet,oFont07 )
   _nLin += 60

Else

   If cNivel > 7

      _vRot := _nTot
      _vRot /= _nCst
      _vRot -= 1
      _vRot *= 100
      _vRot := Round( _vRot, 2 )

   End   

   _cDet := 'TOTAL'
   _cDet += Transform( _nTot, "@E 999,999,999.99" )
   _cDet += Space( 5 ) 
   _cDet += Transform( _nSbt, "@E 999,999,999.99" )

   If cNivel > 7

      _cDet += '  '
      _cDet += Transform( _nCst, "@E 999,999,999.99" )
      _cDet += '  '
      _cDet += Transform( _vRot      , "@E 999.99" )

    End

    _nLin += 30
    oPrint:Say(_nLin,040,_cDet,oFont07 )

End

Set Cent Off
QRY->( dbCloseArea() )

Return( Nil )

Static Function RptSintVend()

If _nLin > 3500

   If  _nDet = 50
 
       oPrint:EndPage()

   End

   If cNivel > 7

      _cDet := 'VENDEDOR                              VALOR DA NOTA       ICMS SUBST.        CUSTO MERC.       ROTA  RANKING'

   Else

      _cDet := 'VENDEDOR                              VALOR DA NOTA       ICMS SUBST.                                RANKING'

   End

   oPrint:Say( _nDet,040,_cDet,oFont07 )
   _nDet += 35
   oPrint:Line( _nDet,030,_nDet,2300)
   _nDet += 30
   _nLin := _nDet
   _nDet := 50

End

SA3->( dbSeek( '01' + QRY->F2_VEND1, .F. ) )
_nVnd ++

If cNivel > 7

   _vRot := QRY->ValMerc
   _vRot /= QRY->VlrCust
   _vRot -= 1
   _vRot *= 100
   _vRot := Round( _vRot, 2 )

End   

_cDet := QRY->F2_VEND1
_cDet += ' '
_cDet += SA3->A3_NREDUZ
_cDet += Space( 15 ) 
_cDet += Transform( QRY->ValMerc, "@E 999,999,999.99" )
_cDet += Space( 5 )
_cDet += Transform( QRY->IcmsRet, "@E 999,999,999.99" )
_cDet += Space( 5 )

If cNivel > 7

   _cDet += Transform( QRY->VlrCust, "@E 999,999,999.99" )
   _cDet += Space( 5 )
   _cDet += Transform( _vRot, "@E 999.99" )

Else

   _cDet += Space( 25 )

End

_cDet += Space( 8 )

_cDet += Transform( _nVnd, "@Z  999" )

oPrint:Say(_nLin,040,_cDet,oFont08 )
_nLin += 30
_nTot += QRY->ValMerc
_nSbt += QRY->IcmsRet
_nCst += QRY->VlrCust

Return( NIL )

Static Function RptAnaVend()

If _nLin > 3500

   If  _nDet = 50
 
       oPrint:EndPage()

   End

   If cNivel > 7

      _cDet := 'VENDEDOR NUMERO PREFIXO CLIENTE LOJA NOME                  EMISSAO    UF      VALOR       ICMS SUBST.      CUSTO       ROTA'

   Else

      _cDet := 'VENDEDOR NUMERO PREFIXO CLIENTE LOJA NOME                  EMISSAO    UF      VALOR       ICMS SUBST.'

   End

   oPrint:Say( _nDet,040,_cDet,oFont07 )
   _nDet += 30
   oPrint:Line( _nDet,030,_nDet,2300)
   _nDet += 30
   _nLin := _nDet
   _nDet := 50
   _lVnd := .T.

End

If cNivel > 7

   _vRot := QRY->ValMerc                                       
   _vRot /= QRY->VlrCust
   _vRot -= 1
   _vRot *= 100
   _vRot := Round( _vRot, 2 )

End

If _lVnd

   _cDet := QRY->F2_VEND1
   _lVnd := .F.

Else

   _cDet := Space( 6 )

End   

_cDet += Space( 3 )
_cDet += QRY->F2_DOC 
_cDet += ' '
_cDet += QRY->F2_SERIE
_cDet += Space( 5 )
_cDet += QRY->F2_CLIENTE
_cDet += '  '
_cDet += QRY->F2_LOJA
_cDet += '   '
_cDet += QRY->A1_NREDUZ
_cDet += ' '
_cDet += QRY->Emissao
_cDet += '  '
_cDet += QRY->F2_EST
_cDet += ' '
_cDet += Transform( QRY->ValMerc, "@E 999,999,999.99" )
_cDet += ' '
_cDet += Transform( QRY->IcmsRet, "@E 999,999,999.99" )

If cNivel > 7

   _cDet += ' '
   _cDet += Transform( QRY->VlrCust, "@E 999,999,999.99" )
   _cDet += ' '
   _cDet += Transform( _vRot , "@E 999.99" )

End   

oPrint:Say(_nLin,040,_cDet,oFont08 )
_nLin += 30

Return( NIL )

Static Function RptTotEst()

If _nLin > 3500

   If  _nDet = 50
 
       oPrint:EndPage()

   End

   If cNivel > 7

      _cDet := 'UF      VALOR VENDA         ICMS SUBST         CUSTO      ROTA'

   Else

      _cDet := 'UF      VALOR VENDA         ICMS SUBST '

   End

   oPrint:Say( _nDet,040,_cDet,oFont07 )
   _nDet += 35
   oPrint:Line( _nDet,030,_nDet,2300)
   _nDet += 30
   _nLin := _nDet
   _nDet := 50

End

If cNivel > 7

   _vRot := QRY->ValMerc
   _vRot /= QRY->VlrCust
   _vRot -= 1
   _vRot *= 100
   _vRot := Round( _vRot, 2 )

End   

_cDet := QRY->F2_EST
_cDet += '   '
_cDet += Transform( QRY->ValMerc, "@E 999,999,999.99" )
_cDet += Space( 5 ) 
_cDet += Transform( QRY->IcmsRet, "@E 999,999,999.99" )

If cNivel > 7

   _cDet += '  '
   _cDet += Transform( QRY->VlrCust, "@E 999,999,999.99" )
   _cDet += '  '
   _cDet += Transform( _vRot      , "@E 999.99" )

End

oPrint:Say(_nLin,040,_cDet,oFont08 )
_nLin += 30
_nTot += QRY->ValMerc
_nSbt += QRY->IcmsRet
_nCst += QRY->VlrCust

Return( NIL )

Static Function RptCliVend()

If _nLin > 3500

   If  _nDet = 50
 
       oPrint:EndPage()

   End

   If cNivel > 7

      _cDet := 'VENDEDOR                    CLIENTE LOJA NOME                 UF  PERIODO    VALOR FAT.     ICMS SUBST.         CUSTO       ROTA'

   Else

      _cDet := 'VENDEDOR                    CLIENTE LOJA NOME                 UF  PERIODO    VALOR FAT.     ICMS SUBST. '

   End

   oPrint:Say( _nDet,040,_cDet,oFont07 )
   _nDet += 35
   oPrint:Line( _nDet,030,_nDet,2300)
   _nDet += 30
   _nLin := _nDet
   _nDet := 50
   _lVnd := .T.

End

SA3->( dbSeek( '01' + QRY->F2_VEND1, .F. ) )
_nVnd ++

If cNivel > 7

   _vRot := QRY->ValMerc
   _vRot /= QRY->VlrCust
   _vRot -= 1
   _vRot *= 100
   _vRot := Round( _vRot, 2 )

End   

If _lVnd

   _cDet := QRY->F2_VEND1
   _cDet += ' '
   _cDet += SA3->A3_NREDUZ
   _lVnd := .F.

Else

   _cDet := Space( 6 )
   _cDet += ' '
   _cDet += Space( 15 )

End   

_cDet += '       '
_cDet += QRY->F2_CLIENTE
_cDet += '  '
_cDet += QRY->F2_LOJA
_cDet += '  '
_cDet += QRY->A1_NREDUZ
_cDet += ' '
_cDet += QRY->F2_EST
_cDet += '  '
_cDet += Substr( QRY->Periodo, 5, 2 )
_cDet += '/'
_cDet += Substr( QRY->Periodo, 1, 4 )
_cDet += '  '
_cDet += Transform( QRY->ValMerc, "@E 999,999,999.99" )
_cDet += '  '
_cDet += Transform( QRY->IcmsRet, "@E 999,999,999.99" )

If cNivel > 7

   _cDet += '  '
   _cDet += Transform( QRY->VlrCust, "@E 999,999,999.99" )
   _cDet += ' '
   _cDet += Transform( _vRot, "@E 999.99" )

End

oPrint:Say(_nLin,040,_cDet,oFont08 )
_nLin += 30

Return( NIL )

Static Function SintVend()

_cSql := 'SELECT SF2010.F2_VEND1, SUM(SF2010.F2_VALMERC) AS ValMerc, SUM(SF2010.F2_ICMSRET) AS IcmsRet, SUM( SC5010.C5_TOTCUS ) AS VlrCust '
_cSql += 'FROM   SF2010 INNER JOIN '
_cSql += '       SC5010 ON SF2010.F2_DOC = SC5010.C5_NOTA AND SF2010.F2_SERIE = SC5010.C5_SERIE '
_cSql += "WHERE (SF2010.F2_EMISSAO BETWEEN '" + DtoS( MV_PAR01 ) + "' AND '" + DtoS( MV_PAR02 ) + "') AND (SF2010.F2_VEND1 BETWEEN '" + MV_PAR03 +"' AND '" + MV_PAR04 + "') AND "
_cSql += "      (SF2010.F2_VEND6 IN (" + _cCod + ")) AND (SF2010.F2_CLIENTE BETWEEN '" + MV_PAR06 + "' AND '" + MV_PAR07 + "') AND (SF2010.F2_SERIE <> 'TRC') "

If MV_PAR05 <> '  '
   _cSql := " AND (SF2010.F2_EST = '" + MV_PAR05 + "') "
End

If MV_PAR08 <> ' '
                         
   _cSql += " AND (SF2010.F2_SERIE = '" + MV_PAR08 + "')"

End

_cSql += " GROUP BY F2_VEND1 ORDER BY ValMerc DESC"

Return( _cSql )

Static Function AnaVend()

_cSql := 'SELECT SF2010.F2_DOC, SF2010.F2_SERIE, SF2010.F2_CLIENTE, SF2010.F2_LOJA, SA1010.A1_NREDUZ, SUBSTRING(SF2010.F2_EMISSAO, 7, 2) '
_cSql += "       + '/' + SUBSTRING(SF2010.F2_EMISSAO, 5, 2) + '/' + SUBSTRING(SF2010.F2_EMISSAO, 1, 4) AS Emissao, SF2010.F2_EST, SF2010.F2_VALMERC AS ValMerc, "
_cSql += '       SF2010.F2_VEND1, SF2010.F2_ICMSRET As IcmsRet, SC5010.C5_TOTMAR, SC5010.C5_TOTCUS As VlrCust '
_cSql += 'FROM         SF2010 INNER JOIN '
_cSql += '       SA1010 ON SF2010.F2_CLIENTE = SA1010.A1_COD AND SF2010.F2_LOJA = SA1010.A1_LOJA INNER JOIN '
_cSql += '       SC5010 ON SF2010.F2_DOC = SC5010.C5_NOTA AND SF2010.F2_SERIE = SC5010.C5_SERIE '
_cSql += "WHERE (SF2010.F2_EMISSAO BETWEEN '" + DtoS( MV_PAR01 ) + "' AND '" + DtoS( MV_PAR02 ) + "') AND (SF2010.F2_VEND1 BETWEEN '" + MV_PAR03 +"' AND '" + MV_PAR04 + "') AND "
_cSql += "      (SF2010.F2_VEND6 IN (" + _cCod + "))  AND (SF2010.F2_CLIENTE BETWEEN '" + MV_PAR06 + "' AND '" + MV_PAR07 + "') AND (SF2010.F2_SERIE <> 'TRC') "

If MV_PAR05 <> ' '

   _cSql += " AND (SF2010.F2_EST = '" + MV_PAR05 + "') "

End
   
If MV_PAR08 <> ' '

   _cSql += " AND (SF2010.F2_SERIE = '" + MV_PAR08 + "')"

End

_cSql += " ORDER BY SF2010.F2_VEND1, SF2010.F2_CLIENTE, SF2010.F2_LOJA "

Return( _cSql )

Static Function TotEst()

_cSql := 'SELECT F2_EST, SUM(F2_VALMERC) AS ValMerc, SUM( SF2010.F2_ICMSRET ) AS IcmsRet, SUM( SC5010.C5_TOTCUS ) AS VlrCust '
_cSql += 'FROM   SF2010 INNER JOIN '
_cSql += '       SC5010 ON SF2010.F2_DOC = SC5010.C5_NOTA AND SF2010.F2_SERIE = SC5010.C5_SERIE '
_cSql += "WHERE (F2_EMISSAO BETWEEN '" + DtoS( MV_PAR01 ) + "' AND '" + DtoS( MV_PAR02 ) + "') AND "
_cSql += "(F2_VEND1 BETWEEN '" + MV_PAR03 +"' AND '" + MV_PAR04 + "') AND (F2_VEND6 IN (" + _cCod + ")) AND (SF2010.F2_SERIE <> 'TRC') AND "

If MV_PAR05 <> '  '

   _cSql += "(F2_EST = '" + MV_PAR05 + "') AND "

End

_cSql += " (F2_CLIENTE BETWEEN '" + MV_PAR06 + "' AND '" + MV_PAR07 + "') "

If MV_PAR08 <> ' '

   _cSql += " AND (SF2010.F2_SERIE = '" + MV_PAR08 + "') "

End

_cSql += " GROUP BY F2_EST ORDER BY ValMerc DESC"

Return( _cSql )

Static Function CliVend()

_cSql := 'SELECT SF2010.F2_CLIENTE, SF2010.F2_LOJA, SA1010.A1_NREDUZ, SF2010.F2_VEND1, SUBSTRING(SF2010.F2_EMISSAO, 1, 6) AS Periodo, '
_cSql += '       SF2010.F2_EST, SUM( SF2010.F2_VALMERC ) AS ValMerc, '
_cSql += '       SUM( SF2010.F2_ICMSRET ) AS IcmsRet, SUM( SC5010.C5_TOTCUS ) As VlrCust '
_cSql += 'FROM   SF2010 INNER JOIN '
_cSql += '       SA1010 ON SF2010.F2_CLIENTE = SA1010.A1_COD AND SF2010.F2_LOJA = SA1010.A1_LOJA INNER JOIN '
_cSql += '       SC5010 ON SF2010.F2_DOC = SC5010.C5_NOTA AND SF2010.F2_SERIE = SC5010.C5_SERIE '
_cSql += "WHERE (SF2010.F2_EMISSAO BETWEEN '" + DtoS( MV_PAR01 ) + "' AND '" + DtoS( MV_PAR02 ) + "') AND (SF2010.F2_VEND1 BETWEEN '" + MV_PAR03 +"' AND '" + MV_PAR04 + "') AND "
_cSql += "      (SF2010.F2_VEND6 IN (" + _cCod + ")) AND (SF2010.F2_CLIENTE BETWEEN '" + MV_PAR06 + "' AND '" + MV_PAR07 + "')  AND (SF2010.F2_SERIE <> 'TRC') "

If MV_PAR05 <> '  '

   _cSql += " AND (F2_EST = '" + MV_PAR05 + "') "

End

If MV_PAR08 <> ' '

   _cSql += " AND (SF2010.F2_SERIE = '" + MV_PAR08 + "')"

End

_cSql += ' GROUP BY SF2010.F2_CLIENTE, SF2010.F2_LOJA, SA1010.A1_NREDUZ, SF2010.F2_VEND1, SUBSTRING(SF2010.F2_EMISSAO, 1, 6), SF2010.F2_EST '
_cSql += ' ORDER BY SF2010.F2_VEND1, SF2010.F2_CLIENTE, SF2010.F2_LOJA, Periodo '

Return( _cSql )
