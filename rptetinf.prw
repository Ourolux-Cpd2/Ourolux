#Include "rwmake.ch"
#IFNDEF WINDOWS
   #DEFINE PSAY SAY
#ENDIF

User Function RptEtiNF()
PRIVATE CbTxt    := ""
PRIVATE CbCont   := ""
PRIVATE nOrdem   := 0
PRIVATE Alfa     := 0
PRIVATE Z        := 0
PRIVATE M        := 0
PRIVATE tamanho  := "P"
PRIVATE limite   := 80
PRIVATE titulo   := PADC("RptEtiNF - Impressão de etiquetas para volumes            ",75)
PRIVATE cDesc1   := PADC("                                                          ",75)
PRIVATE cDesc2   := PADC("                                                          ",75)
PRIVATE cDesc3   := PADC("                                                          ",75)
PRIVATE aReturn  := { "Especial" , 1, "Etiquetas" , 2, 2, 1,"", 0 }
PRIVATE nomeprog := "ETIQNF"
PRIVATE cPerg    := PadR("ETIQNF",10)
PRIVATE nLastKey := 0
PRIVATE Li       := 0
PRIVATE wnrel    := "ETIQNF"
PRIVATE M_PAG    := 0
PRIVATE Cabec1   := ' '
PRIVATE _nIdx    := SC5->( IndexOrd() )

Pergunte( cPerg,.F. )

PRIVATE cstring :="SF2"

_fSF1 := xFilial( 'SF1' )
_fSF2 := xFilial( 'SF2' )
_fSA1 := xFilial( 'SA1' )
_fSA2 := xFilial( 'SA2' )
_fSC5 := xFilial( 'SC5' )

SC5->( dbSetOrder( 5 ) )
While .T.

   wnrel := SetPrint( cString, wnrel, cPerg, Titulo, cDesc1, cDesc2, cDesc3, .T. )

   If nLastKey == 27
      Exit
   End

   SetDefault(aReturn,cString)

   If nLastKey == 27

      Exit

   End

  RptStatus({ || RptDetail() })

End

SC5->( dbSetOrder( _nIdx ) )

Return( )

Static Function RptDetail()

SetRegua( MV_PAR02 )

cTitulo := Chr( 27 ) + '@' + Chr( 27 ) + "C" + Chr( 06 ) + Chr( 27 ) + 'M'
cNota   := StrZero( MV_PAR01, 6 )
_lRet   := .T.

SF2->( dbSeek( _fSF2 + cNota + '1  ', .T. ) )

If cNota <> SF2->F2_DOC

   _lRet := .F.

Else

   If SF2->F2_TIPO <> 'D'

      SA1->( dbSeek( _fSA1 + SF2->F2_CLIENTE + SF2->F2_LOJA, .F. ) )
      Cabec1 := SA1->A1_NOME

   Else

     SA2->( dbSeek( _fSA2 + SF1->F1_FORNECE + SF2->F2_LOJA, .F. ) )
     Cabec1 := SA2->A2_NOME

   End
   
End

If _lRet

   RecLock( 'SF2', .F. )
   SF2->F2_VOLUME1 := MV_PAR02
   SF2->F2_ESPECI1 := 'CAIXA(S)'
   SF2->( MSUnLock() )

   If ( SC5->( dbSeek( _fSC5 + cNota + '1  ', .F. ) ) )

      RecLock( 'SC5', .F. )
      SC5->C5_VOLUME1 := MV_PAR02
      SC5->C5_ESPECI1 := 'CAIXA(S)'
      SC5->( MSUnLock() )

   End

   cNota := Transform( cNota, "@R 999.999" )

   For n := 1 To MV_PAR02

       Cabec2 := 'NF n§ ' + Chr( 14 ) +  cNota + Chr( 20 )
       vTst   := 'VOLUME: ' + AllTRim( Str( n, 5, 0 ) )+ '/' + AllTRim( Str( MV_PAR02, 5, 0 ) )

       SetPrc( 0,0 )
       @ 0,0 PSAY cTitulo
       @ 0,0 PSAY Cabec1
       @ 2,0 PSAY Cabec2
       @ 4,0 PSAY vTst

       If LastKey() = 27
          Exit
       End

       __Eject()

   Next

End

Set Device To Screen
Set Printer To

If aReturn[5] == 1
   dbcommitAll()
   ourspool(wnrel)
End

MS_FLUSH()

Return
