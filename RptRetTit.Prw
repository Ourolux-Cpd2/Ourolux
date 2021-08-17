#INCLUDE 'rwmake.ch'

User Function RptRetTit()
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³RPTRETTIT ³ Autor ³ S‚rgio Santana        ³ Data ³ 04.08.04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Recepção de arquivo titulos em aberto extrato bancario      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SigaFin                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
	_cArq:= space(30)
	
	@ 56,42 TO 323,505 DIALOG oDlg6 TITLE "Digite o nome de arquivo a importar:"
	@ 8,10 TO 84,222
	@ 33,24 Say 'Arquivo'
	@ 43,24 Get _cArq  Size 35,8
	@ 91,160 BMPBUTTON TYPE 1 ACTION Processa( {|lEnd| Grava() }, 'Aguarde, processando....' )
	@ 91,190 BMPBUTTON TYPE 2 ACTION Close(oDlg6)
	@ 110,44 Say 'Importando o arquivo,'
	@ 120,44 Say 'Aguarde'

	ACTIVATE DIALOG oDlg6 CENTERED
	return(NIL)

static function Grava()
_nHndl := fOpen( _cArq, 0 )

If _nHndl < 1

   MsgInfo( "Digite o nome correto do arquivo bancário, o nome deste arquivo não foi encontrado" )
   Return( NIL )

End

_cCR     := Chr( 13 )
_cLF     := Chr( 10 )
_cTAB    := Chr(  9 )
_nLin    := 3900
_fSE1    := xFilial( "SE1" )
_dPer    := ''         
cString  := "SE1"
_cTitulo := "Referência Cruzada Microsiga x Banco"
cTitulo  := "Referência Cruzada Microsiga x Banco"
wnRel	 := "Arquivo Bancário Titulos em Aberto"
__SetCentury( "On" )

_nQdeR := 0                      // Quantidade de registros
_cChr  := Space( 1 )
_cReg  := ' '

oFont07   := TFont():New("Courier New",06,06,,.T.,,,,.T.,.F.)
oFont08   := TFont():New("Courier New",08,08,,.T.,,,,.T.,.F.)
oFont10   := TFont():New("Courier New",08,08,,.F.,,,,.T.,.F.)
oFont10n  := TFont():New("Courier New",09,09,,.T.,,,,.T.,.F.)
oFont10   := TFont():New("Courier New",10,10,,.F.,,,,.T.,.F.)
oFont12   := TFont():New("Courier New",,12,,.T.,,,,,,)
oFont15   := TFont():New("Courier New",09,09,,.T.,,,,.T.,.F.)
oFont16   := TFont():New("Courier New",16,16,,.F.,,,,.T.,.F.)
oFont18   := TFont():New("Courier New",18,18,,.F.,,,,.T.,.T.)
cFileLogo := "ELETROMEGA.bmp" 			// Empresa+Filial

oPrint	:= TMSPrinter():New(cTitulo)
oPrint:SetPortrait()    //Define que a impressao deve ser RETRATO//
oPrint:Setup()
oPrint:StartPage() 	   // Inicia uma nova pagina

RptStatus({|lEnd| ImpRel(@lEnd,wnRel,cString)},"Referência Cruzada Microsiga x Banco")


Return( NIL )


Static Function ImpRel()

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

_nDet := 280

While  .T.

   _nRead := fRead( _nHndl, @_cChr, 1 )

   If _nRead <> 1

      fClose( _nHndl )
      Exit

   End

   If _cChr <> _cCR .And.;
      _cChr <> _cLF

      _cReg += _cChr

   Else

      If _cChr <> _cCR
         
         VldTitAbr()
         _cReg := ' '

      End

   End

   _nQdeR := _nQdeR + 1

End

Set Cent Off
oPrint:Preview()   

Return( NIL )

Static Function  VldTitAbr()

_oPos := 1
_nPos := At( _cTAB, _cReg )

_dDta := Substr( _cReg, _oPos, _nPos - 1 )
_dDta := AllTrim( _dDta )
_dDta := CtoD( _dDta )

If _dDta <> CtoD( '  /  /    ' )

   _cVlr := ContCpo()
   _nLen := Len( _cVlr )
   _nVlr := '0'

   For i := 1 To _nLen

     _iChr := Substr( _cVlr, i, 1 )

     If _iChr <> '.'

        If _iChr <> ','
           _nVlr += _iChr
        Else
           _nVlr += '.'
        End

     End

   Next

   _nVlr := Val( _nVlr )
   _cTit := ContCpo()
   _cPre := Substr( _cTit, 1, 3 )
   _cPar := Substr( _cTit,10, 1 )
   _cTit := Substr( _cTit, 4, 6 )
   _cNro := ContCpo()
   _cSac := ContCpo()
   _cDep := ContCpo()
   _dDtP := ContCpo()
   _dDtP := CtoD( _dDtP )
   _cEsp := ContCpo()

   RptImp( _dDta,;
           _nVlr,;
           _cPre,;
           _cTit,;
           _cPar,;
           _cNro,;
           _cSac,;
           _cDep,;
           _dDtP,;
           _cEsp ;
         )

Else

   _nLen := At( 'Data/Hora', _cReg )

   If _nLen <> 0

      _dPer := Substr( _cReg, 41, 10 )
      _dPer := CtoD( _dPer )

   End

End

Return( NIL )

Static Function ContCpo()

_oPos += _nPos
_nPos := At( _cTAB, Substr( _cReg, _oPos ) )

If _nPos <> 0

   _cRtn := Substr( _cReg, _oPos, _nPos - 1 )

Else

   _cRtn := Substr( _cReg, _oPos )

End

_cRtn := AllTrim( _cRtn )

Return( _cRtn )

Static Function RptImp( _dDta,;
                        _nVlr,;
                        _cPre,;
                        _cTit,;
                        _cPar,;
                        _cNro,;
                        _cSac,;
                        _cDep,;
                        _dDtP,;
                        _cEsp ;
                      )

_aMsg := {}

SE1->( dbSeek( _fSE1 +;
               _cPre +;
               _cTit +;
               _cPar +;
               'NF ' ,;
               .T.    ;
     )       )    

If _cPre <> SE1->E1_PREFIXO .Or.;
   _cTit <> SE1->E1_NUM     .Or.;
   _cPar <> SE1->E1_PARCELA

   aAdd( _aMsg, 'Nota Fiscal cancelada, solicitar baixa no banco ' )
   SE1->( dbGoBottom() )
   _nSld := 0

End   

_nSld := _nVlr
_nSld -= SE1->E1_SALDO
_nSld -= SE1->E1_DECRESC

_cDet := DtoC( _dDta )
_cDet += '  '
_cDet += _cPre
_cDet += ' '
_cDet += _cTit
_cDet += ' '
_cDet += _cPar
_cDet += '  '

_nLen := Len( _cSac )

If _nLen < 35

   _cSac += Space( 35 - _nLen )

End

_cDet += _cSac
_cDet += '  '
_cDet += _cNro
_cDet += '  '
_cDet += Transform( _nVlr, '@E 999,999,999.99' )
_cDet += '  '
_dDtP := DtoC( _dDtP )
_cDet += _dDtP
_cDet += '  '

If _nLin > 3500

   If  _nDet = 50
 
       oPrint:EndPage()

   End

   _cDet := 'Vencimento   Prefixo Titulo Parcela    Sacado   Nro Banco    Valor  Data Pagto   Obeservação'

   oPrint:Say( _nDet,040,_cDet,oFont10 )
   _nDet += 30
   oPrint:Line( _nDet,030,_nDet,2300 )
   _nDet += 30
   _nLin := _nDet
   _nDet := 50
   _cDet := ' '

End

If _dDtP <> '  /  /    ' .And.;
    _nSld = 0

   aAdd( _aMsg, 'OK' )

ElseIf _nSld <> 0 .And.;
       _nSld <> SE1->E1_VALOR

   aAdd( _aMsg, 'Diferença Saldo Titulo R$ ' + Alltrim( Transform( _nSld, "@E 999,999,999.99" ) ) )

End

_dEnv := SE1->E1_VENCREA + 5
   
If _dPer < _dEnv

    aAdd( _aMsg, 'Titulo não enviado a cartório' )

End

_nLen := Len( _aMsg )

If _nLen <> 0

   For i := 1 To _nLen

      If i <> 1

         _cDet := Space( 84 )
         _cDet += _aMsg[ i ]

      Else

        _cDet += _aMsg[ i ]
  
      End

      oPrint:Say( _nLin,040,_cDet,oFont10 )
      _nLin += 30      

   Next

Else

   oPrint:Say( _nLin,040,_cDet,oFont10 )
   _nLin += 30      

End

Return( NIL )
