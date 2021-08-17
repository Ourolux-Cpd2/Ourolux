#Include "rwmake.ch"  
User Function RptPsoCli()

PRIVATE CbTxt     := ""
PRIVATE CbCont    := ""
PRIVATE nOrdem    := 0
PRIVATE Alfa      := 0
PRIVATE Z         := 0
PRIVATE M         := 0
PRIVATE tamanho   := "G"
PRIVATE limite    := 232
PRIVATE ctitulo   := PADC("rptPsoCli - Relação dos Titulos a Receber",74)
PRIVATE cDesc1    := PADC("Este Programa tem  a  Finalidade de Emitir a(s) Relação(ões) de Ti- ",74)
PRIVATE cDesc2    := PADC("tulos a receber. Desenvolvido para Uso Exclusivo da Empresa Eletro- ",74)
PRIVATE cDesc3    := PADC("mega                                                                ",74)
PRIVATE aReturn   := { "Especial", 1,"Administracao", 2, 2, 1,"",1 }
PRIVATE nomeprog  := "rptPsoCli"
PRIVATE cPerg     := PadR("RPTPSO",10)
PRIVATE nLastKey  := 0
PRIVATE lContinua := .T.
PRIVATE _nLin     := 0
PRIVATE Li        := 0
PRIVATE wnrel     := "rptPsoCli"

Pergunte(cPerg,.F.)               // Pergunta no SX1

PRIVATE cString:="SE1"

Wnrel := SetPrint(cString,wnRel,cPerg,cTitulo,cDesc1,cDesc2,cDesc3,.T.,,.T.,Tamanho)

If nLastKey == 27
   Return(.T.)
Endif

SetDefault(aReturn,cString)

If nLastKey == 27
   Return(.T.)
Endif

_cQry := 'SELECT  Count( * ) As _nCount '
_cQry += 'FROM ' + RetSqlName("SE1") + ' SE1 '
_cQry += "WHERE  (E1_SALDO <> 0) AND (E1_VENCREA BETWEEN '" + DtoS( MV_PAR01 ) + "' AND '" + DtoS( MV_PAR02 ) + "') AND "
_cQry += "(E1_TIPO NOT IN ('JR ', 'NCC')) AND (E1_PREFIXO NOT IN ('TRC')) AND ( E1_CLIENTE BETWEEN '" + MV_PAR03 + "' AND '" + MV_PAR04 + "') AND "
_cQry += "(E1_SUPERVI BETWEEN '" + MV_PAR05 + "' AND '" + MV_PAR06 + "') AND "
_cQry += "(E1_VEND1   BETWEEN '" + MV_PAR07 + "' AND '" + MV_PAR08 + "') AND (D_E_L_E_T_ <> '*') "

dbUseArea( .T., "TOPCONN", TCGENQRY(,,_cQRY), 'QRY' )

_nRegua := QRY->_nCount

QRY->( dbCloseArea() )

_cQry := 'SELECT  E1_CLIENTE As Cliente, E1_LOJA    As Loja   , E1_NOMCLI   As Nome   , E1_PREFIXO As Prefixo , E1_NUM   As Titulo, E1_PARCELA As Parcela, '
_cQry += '        E1_TIPO    As Tipo   , E1_EMISSAO As Emissao, E1_VENCREA As VencReal, E1_PORTADO As Portador, E1_VALOR As Valor , E1_VALJUR As Juros, '
_cQry += '        E1_SALDO   As Saldo  ,( E1_VALOR - E1_SALDO ) As ValorNominal       , E1_HIST    As Hist    , E1_SUPERVI As Supervisor, E1_VEND1 As Vendedor '
_cQry += 'FROM ' + RetSqlName("SE1") + ' SE1 '
_cQry += "WHERE  (E1_SALDO <> 0) AND (E1_VENCREA BETWEEN '" + DtoS( MV_PAR01 ) + "' AND '" + DtoS( MV_PAR02 ) + "') AND "
_cQry += "(E1_TIPO NOT IN ('JR ', 'NCC')) AND (E1_PREFIXO NOT IN ('TRC')) AND ( E1_CLIENTE BETWEEN '" + MV_PAR03 + "' AND '" + MV_PAR04 + "') AND "
_cQry += "(E1_SUPERVI BETWEEN '" + MV_PAR05 + "' AND '" + MV_PAR06 + "') AND "
_cQry += "(E1_VEND1   BETWEEN '" + MV_PAR07 + "' AND '" + MV_PAR08 + "') AND (D_E_L_E_T_ <> '*') "
_cQry += "ORDER BY E1_CLIENTE, E1_LOJA, E1_VENCREA"

dbUseArea( .T., "TOPCONN", TCGENQRY(,,_cQRY), 'QRY' )

RptStatus({|| RptDetail() })

Return

Static Function RptDetail

SetRegua( _nRegua )
Set Century On

cTitulo := 'RELACAO DE TITULOS A RECEBER PERIODO DE : ' + DtoC( MV_PAR01 ) + ' a ' + DtoC( MV_PAR02 )
Cabec1  := 'Cliente Loja Nome                 Prefixo   Titulo  Parc Tipo  Emissao   Vencto Real Portador    Valor NF       Valor Pago        Saldo           Valor     Historico                                    Dias Superv  Vend.'
Cabec2  := '                                                                                                                                do Titulo       Atualizado                                               Atr.'

M_Pag := 1 

SetPrc( 0,0 )

_tValor := 0
_tSaldo := 0
_tPagar := 0
_tCorr  := 0
_cValor := 0
_cSaldo := 0
_cPagar := 0
_cCorr  := 0

@ 0,0 PSAY Chr( 15 )

QRY->( dbGoTop() )

nLin      := 61
_cCliente := QRY->Cliente

While ! QRY->( Eof() )

    If nLin > 60

       nLin := Cabec(ctitulo,cabec1,cabec2,nomeprog,tamanho,15)
       nLin ++

    End

    @ nLin,  0 PSAY QRY->Cliente
    @ nLin,  9 PSAY QRY->Loja
    @ nLin, 12 PSAY QRY->Nome
    @ nLin, 36 PSAY QRY->Prefixo
    @ nLin, 44 PSAY QRY->Titulo
    @ nLin, 52 PSAY QRY->Parcela
    @ nLin, 57 PSAY QRY->Tipo

    _cDta := Substr( QRY->Emissao, 7, 2 )
    _cDta += '/'
    _cDta += Substr( QRY->Emissao, 5, 2 )
    _cDta += '/'
    _cDta += Substr( QRY->Emissao, 1, 4 )
    
    @ nLin, 62 PSAY _cDta

    _cDta := Substr( QRY->VencReal, 7, 2 )
    _cDta += '/'
    _cDta += Substr( QRY->VencReal, 5, 2 )
    _cDta += '/'
    _cDta += Substr( QRY->VencReal, 1, 4 )

    @ nLin, 73 PSAY _cDta
    @ nLin, 87 PSAY QRY->Portador
    @ nLin, 95 PSAY QRY->Valor Picture "@E 999,999,999.99"
    @ nLin,110 PSAY QRY->ValorNominal Picture "@E 999,999,999.99"
    @ nLin,125 PSAY QRY->Saldo Picture "@E 999,999,999.99"
    
    _nDias := dDataBase - CtoD( _cDta )

    _nVlr := QRY->Juros
    _nVlr *= _nDias
    _nVlr += QRY->Saldo

    _tValor += QRY->Valor
    _tSaldo += QRY->Saldo
    _tPagar += QRY->ValorNominal
    _tCorr  += _nVlr

    If MV_PAR09 <> 2

       _cValor += QRY->Valor
       _cSaldo += QRY->Saldo
       _cPagar += QRY->ValorNominal
       _cCorr  += _nVlr
    
    End

    @ nLin,140 PSAY _nVlr Picture "@E 999,999,999.99"
    @ nLin,156 PSAY QRY->Hist
    @ nLin,201 PSAY Str( _nDias, 4, 0 )
    @ nLin,207 PSAY QRY->Supervisor
    @ nLin,214 PSAY QRY->Vendedor
    nLin ++

    QRY->( dbSkip() )

    If MV_PAR09 <> 2

       If _cCliente <> QRY->Cliente

          SubTotCli()

       End    

    End

    IncRegua()

End

nLin ++

@ nLin, 95 PSAY "--------------"
@ nLin,110 PSAY "--------------"
@ nLin,125 PSAY "--------------"
@ nLin,140 PSAY "--------------"

nLin ++

@ nLin, 95 PSAY _tValor Picture "@E 999,999,999.99"
@ nLin,110 PSAY _tPagar Picture "@E 999,999,999.99"
@ nLin,125 PSAY _tSaldo Picture "@E 999,999,999.99"
@ nLin,140 PSAY _tCorr  Picture "@E 999,999,999.99"

__Eject()

Set Device To Screen

If aReturn[ 5 ] == 1
   dbCommitAll()
   OurSpool( wnrel )
End

MS_Flush()
Set Printer To

QRY->( dbCloseArea() )
Set Century Off
Return()           

Static Function SubTotCli()

@ nLin, 95 PSAY "--------------"
@ nLin,110 PSAY "--------------"
@ nLin,125 PSAY "--------------"
@ nLin,140 PSAY "--------------"

nLin ++

@ nLin, 95 PSAY _cValor Picture "@E 999,999,999.99"
@ nLin,110 PSAY _cPagar Picture "@E 999,999,999.99"
@ nLin,125 PSAY _cSaldo Picture "@E 999,999,999.99"
@ nLin,140 PSAY _cCorr  Picture "@E 999,999,999.99"

nLin += 2

_cValor   := 0
_cSaldo   := 0
_cPagar   := 0
_cCorr    := 0
_cCliente := QRY->Cliente

Return()