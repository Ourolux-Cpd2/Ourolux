#Include "rwmake.ch"
#IFNDEF WINDOWS
   #DEFINE PSAY SAY
#ENDIF
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ ELET010  ³ Autor ³Airton Lira            ³ Data ³08/11/2000³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Relacao de Acompanhamento das Notas Fiscais                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Eletromega                                                 ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Alteracao ³                                                            ³±±
±±³Autor     ³ D A T A  | Descricao                                       ³±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±³          ³          |                                                 ³±±
±±³          ³          |                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros                         ³
//³ mv_par01             // Data de Emissao de                   ³
//³ mv_par02             // Data de Emissao ate                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
User Function RptNota()

PRIVATE CbTxt  :=""
PRIVATE CbCont :=""
PRIVATE nOrdem :=0
PRIVATE Alfa   := 0
PRIVATE Z      :=0
PRIVATE M      :=0
PRIVATE tamanho:="M"
PRIVATE limite:=132
PRIVATE titulo :=PADC("Elet010 - Acompanhamento do Faturamento por Nota          ",75)
PRIVATE cDesc1 :=PADC("Emitir  listagem com dados de todas as Notas Fiscais,     ",75)
PRIVATE cDesc2 :=PADC("Emitidas, Conforme os parametros Solicitados.             ",75)
PRIVATE cDesc3 :=PADC("                                                          ",75)
PRIVATE aReturn := { "Especial" , 1, "Diretoria" , 2, 2, 1,"", 0 }
PRIVATE nomeprog:="ELET010"
PRIVATE cPerg:=PadR("ELET10",10)
PRIVATE nLastKey:= 0
PRIVATE Li:=0
PRIVATE wnrel    := "ELET10"
PRIVATE xPAG := 1
Private xTotIcms:=0
Private xTotNota:=0
Private xNumNf  :=""
Private xCancel :=""
Private xDuplic :=""

Pergunte( cPerg,.F. )

PRIVATE cstring:="SF2"

wnrel :=SetPrint(cString,wnrel,cPerg,Titulo,cDesc1,cDesc2,cDesc3,.T.)

If nLastKey == 27
   Return
Endif

SetDefault(aReturn,cString)

If nLastKey == 27

   Return

Endif

__SetCentury( "On" )

cTitulo := 'RELACAO DAS NOTAS EMITIDAS'
Cabec1  := 'PERIODO DE : ' + DtoC( MV_PAR01 ) + ' a ' + DtoC( MV_PAR02 )
Cabec2  := ' NOTA  PARC CLIENTE                 VALOR    EMISSAO    VENCTO   PORT    ICMS    BAIXAS     OBESERVACAO            NATUREZA'

_dIni := DtoS( MV_PAR01 )
_dFim := DtoS( MV_PAR02 )
_nEsc := MV_PAR04

_cQry := 'SELECT DISTINCT '
_cQry += 'SF2.F2_DOC As Nota, SE1.E1_PARCELA As Parcela, SF2.F2_SERIE As Serie, SF4.F4_TEXTO As Descr, SF2.F2_TIPO As Tipo, '
_cQry += 'SF2.F2_DUPL As Duplicata, SF2.F2_VALBRUT As Total, SE1.E1_SALDO As Saldo, SF2.F2_VALICM As Icms, SE1.E1_VALOR As VlrDup, '
_cQry += "SUBSTRING(SF2.F2_EMISSAO, 7, 2) + '/' + SUBSTRING(SF2.F2_EMISSAO, 5, 2) + '/' + SUBSTRING(SF2.F2_EMISSAO, 1, 4) AS Emissao,  "
_cQry += "SUBSTRING(SE1.E1_BAIXA, 7, 2) + '/' + SUBSTRING(SE1.E1_BAIXA, 5, 2) + '/' + SUBSTRING(SE1.E1_BAIXA, 1, 4) AS Baixa , SE1.E1_NOMCLI As Cliente, "
_cQry += "SUBSTRING(SE1.E1_VENCREA, 7, 2) + '/' + SUBSTRING(SE1.E1_VENCREA, 5, 2) + '/' + SUBSTRING(SE1.E1_VENCREA, 1, 4) AS Vencto, SE1.E1_PORTADO As Portador, "
_cQry += 'SF2.F2_CLIENTE As CodCli, SF2.F2_LOJA As CodLoj, CAST( CAST( SE1.E1_VENCTO AS DATETIME) - CAST( SE1.E1_VENCORI AS DATETIME) AS INT) AS DiaPro '
_cQry += 'FROM SF2010 SF2 INNER JOIN '
_cQry += '(SELECT DISTINCT D2_DOC, D2_TES '
_cQry += '        FROM          SD2010 '                                                                                                       // CURITIBA
_cQry += "        WHERE      (D2_EMISSAO BETWEEN '" + _dIni + "' AND '" + _dFim + "') AND (D2_SERIE = '" + MV_PAR03 + "') AND (D2_FILIAL = '" + xFilial("SD2")+ "' )) SD2 ON "
_cQry += "        SF2.F2_DOC = SD2.D2_DOC LEFT OUTER JOIN "
_cQry += "SE1010 SE1 ON SF2.F2_DOC = SE1.E1_NUM AND SF2.F2_SERIE = SE1.E1_PREFIXO AND (SE1.D_E_L_E_T_ <> '*') INNER JOIN "
_cQry += 'SF4010 SF4 ON SD2.D2_TES = SF4.F4_CODIGO  '
_cQry += "WHERE (SF2.F2_EMISSAO BETWEEN '" + _dIni + "' AND '" + _dFim + "') AND (SF2.F2_SERIE = '" + MV_PAR03 + "') AND SF2.F2_FILIAL = '" + xFilial( 'SF2' ) + "'"
_cQry += "   AND (SF2.D_E_L_E_T_ <> '*') "
_cQry += 'ORDER BY SF2.F2_DOC '

dbUseArea( .T., "TOPCONN", TCGENQRY(,,_cQry), 'QRY' )

_nNotas := MV_PAR02 - MV_PAR01

If _nNotas < 0
   
   dbCloseArea()
   Return

End

dbGoTop()

RptStatus({ || RptDetail() })

QRY->( dbCloseArea() )
__SetCentury( "Off" )
                                            
Return

Static Function RptDetail()

SetRegua( _nNotas )

SetPrc( 0, 0 )

_lImprime := .F.
nLin      := 61
M_Pag     := 1
_oData    := Emissao
_oNota    := Val( Nota )

_fSA1 := xFilial( "SA1" )
_fSA2 := xFilial( "SA2" )
_fSE1 := xFilial( "SE1" )
_fSF1 := xFilial( "SF1" )
_fSF2 := xFilial( "SF2" )

SF2->( dbSetOrder( 1 ) )
SF1->( dbSetOrder( 1 ) )

If ( SF2->( dbSeek( _fSF2 +	QRY->Nota + QRY->Serie + QRY->CodCli + QRY->CodLoj , .F. ) ) ) 

   SF2->( dbSkip( -1 ) )
   _oNota := Val( SF2->F2_DOC )
   _nNota := Val( Nota )
   _nNota -= _oNota

End   

_nTot := 0
_nIcm := 0

While ! Eof()

    If nLin > 60

       nLin := Cabec( ctitulo, cabec1, cabec2, nomeprog, tamanho, 15 )
       nLin ++

       If _nNota > 1

          CancDevol()

       End

    End

    If _oData <> Emissao

       _oData := Emissao
       IncRegua()

    End

    If _nEsc <> 2

       If Tipo <> 'D'

          SA1->( dbSeek( _fSA1 + QRY->CodCli + QRY->CodLoj, .T. ) )

       Else

          SA2->( dbSeek( _fSA2 + QRY->CodCli + QRY->CodLoj, .T. ) )

       End

       If Parcela $[ A]

          @ nLin,000 PSAY Nota
          @ nLin,008 PSAY Parcela

          If Tipo <> 'D'

             If Duplicata <> ' '

                @ nLin,012 PSAY Cliente

             Else

                @ nLin,012 PSAY SA1->A1_NREDUZ

             End

          Else

             @ nLin,012 PSAY SA2->A2_NREDUZ

          End

          If Duplicata <>  ' '

             @ nLin,033 PSAY VlrDup   Picture "@E 99,999.99"

          Else
    
             @ nLin,033 PSAY Valor    Picture "@E 99,999.99"

          End

          @ nLin,044 PSAY Emissao
          @ nLin,055 PSAY Vencto
          @ nLin,066 PSAY Portador
          @ nLin,070 PSAY Icms     Picture "@ZE 9,999.99"
          @ nLin,080 PSAY Baixa

          If DiaPro <> 0

             @ nLin,091 PSAY 'PRORROGACAO ' + Alltrim( Str( DiaPro ) ) + ' DIA(S)'

          End

          @ nLin,115 PSAY Descr

       Else

          @ nLin,008 PSAY Parcela
          @ nLin,033 PSAY VlrDup    Picture "@E 99,999.99"
          @ nLin,055 PSAY Vencto
          @ nLin,080 PSAY Baixa

       End

      _nTot += VlrDup
      _nIcm += Icms

      nLin ++

    End
    
    dbSkip()

    If Eof()

       Exit

    End

    _nNota := Val( Nota )
    _nNota -= _oNota

    If _nNota > 1 .And.;
       _nNota < 20

       CancDevol()

    End

    _oNota := Val( Nota )

End

If _nTot > 0

   @ nLin,030 PSAY _nTot Picture "------------"
   @ nLin,068 PSAY _nIcm Picture "----------"
   nLin ++
   @ nLin,000 PSAY "T O T A I S ->"
   @ nLin,030 PSAY _nTot Picture "@E 9,999,999.99"
   @ nLin,068 PSAY _nIcm Picture "@E 999,999.99"
   nLin ++

End

Set Device To Screen
Set Printer To

If aReturn[5] == 1
   dbcommitAll()
   ourspool(wnrel)
End

MS_FLUSH()

Return()

Static Function CancDevol()

_nNota --
_oNota ++
_lDev := .F.

For i := 1 To _nNota

    _cNota := StrZero( _oNota, 6 )

    
    If (SF1->( dbSeek( _fSF1 + _cNota + MV_PAR03 + Space( 9 ), .T. ) ))
           
    	While SF1->F1_DOC = _cNota .And. SF1->F1_FILIAL == xFilial("SF1") 
             
          		If SF1->F1_TIPO = 'D'

             	If SF1->F1_SERIE $ '1  .2  .3'

                	_lDev := .T.
                	Exit

            	 End

          	End

        	  SF1->( dbSkip() )

    	End
    
    EndIf

    If _lDev

       If _nEsc <> 2

          @ nLin,000 PSAY SF1->F1_DOC
          SA1->( dbSeek( _fSA1 + SF1->F1_FORNECE + SF1->F1_LOJA, .F. ) )

          @ nLin,012 PSAY SA1->A1_NREDUZ
          @ nLin,033 PSAY SF1->F1_VALMERC   Picture "@E 99,999.99"
          @ nLin,044 PSAY SF1->F1_EMISSAO

          SE1->( dbSeek( _fSE1 + MV_PAR03 + _cNota + 'ANCC', .F. ) )

          If SF1->F1_DUPL <> ' '

             @ nLin,054 PSAY SE1->E1_EMISSAO

          End

          @ nLin,070 PSAY SF1->F1_VALICM  Picture "@ZE 9,999.99"
          @ nLin,080 PSAY SE1->E1_BAIXA
          @ nLin,115 PSAY '* DEVOLUCAO CLIENTE *'
          nLin  ++

       End

    Else

       @ nLin,00 PSAY _cNota Picture '999999'
       @ nLin,12 PSAY '* C A N C E L A D A *'
       nLin  ++ 

    End

     _oNota ++
     _lDev := .F.

Next

Return()

// NOTA  PARC CLIENTE                 VALOR    EMISSAO   VENCTO PORT    ICMS    BAIXAS      OBESERVACAO            NATUREZA
//999999  X   XXXXXXXXXXXXXXXXXXXX 999,999.99 99/99/99 99/99/99  999 99.999,99   99/99/99 XXXXXXXXXXXXXXXXXXXXXX XXXXXXXXXXXXXXXXXXXXXXX
