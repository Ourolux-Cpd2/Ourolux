#include "rwmake.ch"

User Function rptTrcDr()

PRIVATE CbTxt     := ""
PRIVATE CbCont    := ""
PRIVATE nOrdem    := 0
PRIVATE Alfa      := 0
PRIVATE Z         := 0
PRIVATE M         := 0
PRIVATE tamanho   := "M"
PRIVATE limite    := 120
PRIVATE ctitulo   := PADC("rptTrcMd -Troca de Mercadoria",74)
PRIVATE cDesc1    := PADC("Este Programa tem  a  Finalidade de Emitir a(s) Troca(s) Gerada(s)  ",74)
PRIVATE cDesc2    := PADC("pelo Sistema.Desenvolvido para Uso Exclusivo da Empresa EletroMega  ",74)
PRIVATE cDesc3    := PADC("                                                                    ",74)
PRIVATE aReturn   := { "Especial", 1,"Administracao", 2, 2, 1,"",1 }
PRIVATE nomeprog  := "rptTrcDr"
PRIVATE cPerg     := PadR("RPTRST",10)
PRIVATE nLastKey  := 0
PRIVATE lContinua := .T.
PRIVATE _nLin     := 0
PRIVATE Li        := 0
PRIVATE wnrel     := "rptTrcDr"

Pergunte(cPerg,.F.)               // Pergunta no SX1

PRIVATE cString:="SF2"

Wnrel := SetPrint(cString,wnRel,cPerg,cTitulo,cDesc1,cDesc2,cDesc3,.F.,,.T.,Tamanho)

If nLastKey == 27
   Return(.T.)
Endif

SetDefault(aReturn,cString)

If nLastKey == 27
   Return(.T.)
Endif

aReturn[ 4 ] := 1

If MV_PAR03 <> 3

   _cQRY := 'SELECT COUNT( * ) AS REC_NO ' 
   _cQRY += 'FROM ' + RetSqlName("SF2") + ' SF2, ' + RetSqlName("SF1") + ' SF1 '
   _cQRY += "WHERE     (SF2.F2_SERIE = 'TRC') AND (SF2.D_E_L_E_T_ <> '*') AND (SF1.D_E_L_E_T_ <> '*') AND "
   _cQRY += "          (SF2.F2_EMISSAO >= '" + DtoS( MV_PAR01 )
   _cQRY += "') AND (SF2.F2_EMISSAO <= '" + DtoS( MV_PAR02 ) + "') AND "

   If MV_PAR03 = 2

      _cQRY += "          (SF2.F2_CLIENTE >= '" + MV_PAR04
      _cQRY += "') AND (SF2.F2_CLIENTE <= '" + MV_PAR05 + "') AND "

   End

   _cQRY += 'SF2.F2_DOC = SF1.F1_DOC '

End

   _cQRY += "AND SF2.F2_FILIAL = '" + xFilial("SF2") + "' AND SF1.F1_FILIAL = '" + xFilial("SF1") + "' "  // CURITIBA
	

dbUseArea( .T., "TOPCONN", TCGENQRY(,,_cQRY), 'QRY' )

_nRegua := QRY->REC_NO

QRY->( dbCloseArea() )

If MV_PAR03 <> 3

   _cQRY := 'SELECT SF2.F2_DOC, SF2.F2_EMISSAO, SF2.F2_CLIENTE, SF2.F2_LOJA, SA1.A1_NREDUZ, SF1.F1_VALBRUT, '
   _cQRY += 'SF2.D_E_L_E_T_ AS EXCLUIDA, SF2.F2_VALMERC, SF2.F2_VALMERC - SF1.F1_VALBRUT AS SALDO, SF2.F2_VEND1, SA3.A3_NREDUZ '
   _cQRY += 'FROM ' + RetSqlName("SF2") + ' SF2 INNER JOIN ' + RetSqlName("SF1") + ' SF1 '
   _cQRY += '     ON SF2.F2_DOC = SF1.F1_DOC AND SF2.F2_SERIE = SF1.F1_SERIE INNER JOIN ' + RetSqlName("SA1") + ' SA1 '
   _cQRY += '     ON SF2.F2_CLIENTE = SA1.A1_COD AND SF2.F2_LOJA = SA1.A1_LOJA INNER JOIN ' + RetSqlName("SA3") + ' SA3 '
   _cQRY += '     ON SF2.F2_VEND1 = SA3.A3_COD '
   _cQRY += "WHERE     (SF2.F2_SERIE = 'TRC') AND (SF1.D_E_L_E_T_ <> '*') AND "
   _cQRY += "          (SF2.F2_EMISSAO >= '" + DtoS( MV_PAR01 )
   _cQRY += "') AND (SF2.F2_EMISSAO <= '" + DtoS( MV_PAR02 ) + "') "

   If MV_PAR03 = 2

      _cQRY += "   AND (SF2.F2_CLIENTE >= '" + MV_PAR04
      _cQRY += "') AND (SF2.F2_CLIENTE <= '" + MV_PAR05 + "') "

   End   
   
   _cQRY += " AND SF2_FILIAL = '" + xFilial("SF2") + "' AND SF1_FILIAL = '" + xFilial("SF1") + "' "  // CURITIBA


   _cQRY += 'ORDER BY SF2.F2_EMISSAO, SF2.F2_DOC'
   
End   

dbUseArea( .T., "TOPCONN", TCGENQRY(,,_cQRY), 'QRY' )

RptStatus({|| RptDetail() })

Return

Static Function RptDetail

SetRegua( _nRegua )

cTitulo :="RELATÓRIO DE TROCAS DE MERCADORIAS"
Cabec1  :="  DOC    EMISSAO    CLIENTE LOJA NOME                            ENTRADA      SAIDA      SALDO    VENDEDOR"
cabec2  :=""

M_Pag   := 1 
@ 0,0 PSAY Chr( 15 )
_nLin   := Cabec(ctitulo,cabec1,cabec2,nomeprog,tamanho,1)
_nLin   += 2
_nSaldo := 0
_nEntr  := 0
_nSaida := 0

_dSaldo := 0
_dEntr  := 0
_dSaida := 0

_dDia := QRY->F2_EMISSAO

While ! Eof()

   If _dDia != QRY->F2_EMISSAO

      @ _nLin, 62 PSAY "----------"
      @ _nLin, 73 PSAY "----------"
      @ _nLin, 84 PSAY "----------"
      _nLin ++

      @ _nLin, 62 PSAY _dEntr  Picture "@E 999,999.99"
      @ _nLin, 73 PSAY _dSaida Picture "@E 999,999.99"
      @ _nLin, 84 PSAY _dSaldo Picture "@E) 999,999.99"
      _nLin += 2
      
      _nEntr  += _dEntr
      _nSaida += _dSaida
      _nSaldo += _dSaldo

      _dEntr  := QRY->F1_VALBRUT
      _dSaida := QRY->F2_VALMERC
      _dSaldo := QRY->Saldo
      _dDia   := QRY->F2_EMISSAO

   Else

      _dEntr  += QRY->F1_VALBRUT
      _dSaida += QRY->F2_VALMERC
      _dSaldo += QRY->Saldo

   End
   
   If _nLin > 59

      _nLin := Cabec(ctitulo,cabec1,cabec2,nomeprog,tamanho,1)
      _nLin += 2

   End

   _cEmissao := Substr( QRY->F2_EMISSAO, 7, 2 )
   _cEmissao += '/'
   _cEmissao += Substr( QRY->F2_EMISSAO, 5, 2 )

   @ _nLin,  0 PSAY QRY->F2_DOC Picture "@R 999.999"
   @ _nLin, 10 PSAY _cEmissao
   @ _nLin, 20 PSAY QRY->F2_CLIENTE Picture "999999"
   @ _nLin, 29 PSAY QRY->F2_LOJA Picture "99"
   @ _nLin, 33 PSAY QRY->A1_NREDUZ
   @ _nLin, 62 PSAY QRY->F1_VALBRUT Picture "@E 999,999.99"
   @ _nLin, 73 PSAY QRY->F2_VALMERC Picture "@E 999,999.99"

   If QRY->EXCLUIDA != '*'
      @ _nLin, 84 PSAY QRY->SALDO Picture "@E) 999,999.99"
   Else
      @ _nLin, 84 PSAY ' CANCELADA *'
   End

   _cVend := rTrim( QRY->A3_NREDUZ )

   If QRY->EXCLUIDA != ' '

      _cVend += ' * CANCELADA'
      _dEntr  -= QRY->F1_VALBRUT
      _dSaida -= QRY->F2_VALMERC
      _dSaldo -= QRY->Saldo

   End

   @ _nLin, 98 PSAY _cVend

   _nLin ++
   
   QRY->( dbSkip() )
   IncRegua()

End

_nEntr  += _dEntr
_nSaida += _dSaida
_nSaldo += _dSaldo

@ _nLin, 62 PSAY "----------"
@ _nLin, 73 PSAY "----------"
@ _nLin, 84 PSAY "----------"
_nLin ++

@ _nLin, 62 PSAY _dEntr  Picture "@E 999,999.99"
@ _nLin, 73 PSAY _dSaida Picture "@E 999,999.99"
@ _nLin, 84 PSAY _dSaldo Picture "@E) 999,999.99"
_nLin ++

@ _nLin, 62 PSAY "----------"
@ _nLin, 73 PSAY "----------"
@ _nLin, 84 PSAY "----------"
_nLin ++

@ _nLin, 62 PSAY _nEntr  Picture "@E 999,999.99"
@ _nLin, 73 PSAY _nSaida Picture "@E 999,999.99"
@ _nLin, 84 PSAY _nSaldo Picture "@E) 999,999.99"

__Eject()
MS_Flush()

Set device to screen
Set Printer To

If aReturn[ 5 ] == 1
   dbCommitAll()
   OurSpool( wnrel )
Endif

QRY->( dbCloseArea() )

Return()           

