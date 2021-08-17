#IFNDEF WINDOWS
   #DEFINE PSAY SAY
#ENDIF

/*
  
Este modulo tem como finalidade gerar uma previsão do conta a pagar e receber de um dado periodo
       bem como trazer valor do estoque atualizado sobre o custo do produto 

Author: Sérgio Santana
Criado em: 7/10/2002

*/

User Function rptFinPr()
#Include "rwmake.ch"

SetPrvt( '_aPedido', '_lRet', '_aItens' )

PRIVATE CbTxt    := ""
PRIVATE CbCont   := ""
PRIVATE nOrdem   := 0
PRIVATE Alfa     := 0
PRIVATE Z        := 0
PRIVATE M        := 0
PRIVATE tamanho  := "P"
PRIVATE limite   := 80
PRIVATE titulo   := PADC("rptFinPr -Posição Financeira ",74)
PRIVATE cDesc1   := PADC("Este Programa tem a Finalidade de Emitir um relatório com a posi   ",74)
PRIVATE cDesc2   := PADC("ção financeira. Para Uso Exclusivo da Empresa EletroMega           ",74)
PRIVATE cDesc3   := PADC("                                                                    ",74)
PRIVATE aReturn  := { "Especial", 1,"Administracao", 1, 2, 1,"",1 }
PRIVATE nomeprog := "rptTrcMd"
PRIVATE cPerg    := PadR("RPTFIN",10)
PRIVATE nLastKey := 0
PRIVATE lContinua:= .T.
PRIVATE nLin     := 0
PRIVATE wnrel    := "rptFinPr"

Pergunte(cPerg,.F.)               // Pergunta no SX1

PRIVATE cString:="SF2"

Wnrel:=SetPrint(cString,wnrel,cPerg,Titulo,cDesc1,cDesc2,cDesc3,.T.)

If nLastKey == 27
   Return
Endif

SetDefault(aReturn,cString)
If nLastKey == 27
   Return
Endif

RptStatus({|| RptDetail() })

Return

Static Function RptDetail()


_iPer := Str( Year( MV_PAR01 ), 4 )
_iPer += StrZero( Month( MV_PAR01 ), 2 )

_fPer := Str( Year( MV_PAR02 ), 4 )
_fPer += StrZero( Month( MV_PAR02 ), 2 )

SetRegua( ( Val(_fPer) - Val(_iPer) ) + 1 )

_nHndl := fCreate( "C:\Windows\Temp\AP5Finan.Txt", 0 )

/*
                                          Contas a Receber
*/


If MV_PAR03 = 2

   _cPag := 'SELECT  E1_TIPO AS TIPO, E1_PREFIXO AS PREFIXO, SUM(E1_VALOR) AS VALOR, SUM(E1_SALDO) AS SALDO, SUBSTRING(E1_EMISSAO, 1, 6) AS PERIODO '
   _cPag += 'FROM    SE1010 '
   _cPag += "WHERE   SUBSTRING(E1_EMISSAO, 1, 6) BETWEEN '" + _iPer + "' "
   _cPag += " AND '" + _fPer + "'  AND D_E_L_E_T_ <> '*' "
   _cPag += 'GROUP BY E1_TIPO, SUBSTRING(E1_EMISSAO, 1, 6), E1_PREFIXO '
   _cPag += 'ORDER BY SUBSTRING( E1_EMISSAO, 1, 6 ), E1_TIPO, E1_PREFIXO'

ElseIf MV_PAR03 <> 1

   _cPag := 'SELECT  E1_TIPO AS TIPO, E1_PREFIXO AS PREFIXO, SUM(E1_VALOR) AS VALOR, SUM(E1_SALDO) AS SALDO, SUBSTRING(E1_VENCREA, 1, 6) AS PERIODO '
   _cPag += 'FROM    SE1010 '
   _cPag += "WHERE   SUBSTRING(E1_VENCREA, 1, 6) BETWEEN '" + _iPer + "' "
   _cPag += " AND '" + _fPer + "'  AND D_E_L_E_T_ <> '*' "
   _cPag += 'GROUP BY E1_TIPO, SUBSTRING(E1_VENCREA, 1, 6), E1_PREFIXO '
   _cPag += 'ORDER BY SUBSTRING(E1_VENCREA, 1, 6), E1_TIPO, E1_PREFIXO'

Else   

   _cPag := 'SELECT  E1_TIPO AS TIPO, E1_PREFIXO AS PREFIXO, SUM(E1_VALOR) AS VALOR, SUM(E1_SALDO) AS SALDO, SUBSTRING(E1_BAIXA, 1, 6) AS PERIODO '
   _cPag += 'FROM    SE1010 '
   _cPag += "WHERE   SUBSTRING(E1_BAIXA, 1, 6) BETWEEN '" + _iPer + "' "
   _cPag += " AND '" + _fPer + "'  AND D_E_L_E_T_ <> '*' "
   _cPag += 'GROUP BY E1_TIPO, SUBSTRING(E1_BAIXA, 1, 6), E1_PREFIXO '
   _cPag += 'ORDER BY SUBSTRING(E1_BAIXA, 1, 6), E1_TIPO, E1_PREFIXO'

End

/*
                                          Contas a Pagar
*/

If MV_PAR03 = 1

   _cRec := 'SELECT  E2_TIPO AS TIPO, E2_PREFIXO AS PREFIXO, SUM(E2_VALOR) AS VALOR, SUM(E2_SALDO) AS SALDO, SUBSTRING(E2_EMISSAO, 1, 6) AS PERIODO '
   _cRec += 'FROM    SE2010 '
   _cRec += "WHERE   SUBSTRING(E2_EMISSAO, 1, 6) BETWEEN '" + _iPer + "' "
   _cRec += " AND '" + _fPer + "'  AND D_E_L_E_T_ <> '*' "
   _cRec += 'GROUP BY E2_TIPO, SUBSTRING(E2_EMISSAO, 1, 6), E2_PREFIXO '
   _cRec += 'ORDER BY SUBSTRING(E2_EMISSAO, 1, 6), E2_TIPO, E2_PREFIXO '

ElseIf MV_PAR03 <> 1

   _cRec := 'SELECT  E2_TIPO AS TIPO, E2_PREFIXO AS PREFIXO, SUM(E2_VALOR) AS VALOR, SUM(E2_SALDO) AS SALDO, SUBSTRING(E2_VENCREA, 1, 6) AS PERIODO '
   _cRec += 'FROM    SE2010 '
   _cRec += "WHERE   SUBSTRING(E2_VENCREA, 1, 6) BETWEEN '" + _iPer + "' "
   _cRec += " AND '" + _fPer + "'  AND D_E_L_E_T_ <> '*' "
   _cRec += 'GROUP BY E2_TIPO, SUBSTRING(E2_VENCREA, 1, 6), E2_PREFIXO '
   _cRec += 'ORDER BY SUBSTRING(E2_VENCREA, 1, 6), E2_TIPO, E2_PREFIXO '

Else

   _cRec := 'SELECT  E2_TIPO AS TIPO, E2_PREFIXO AS PREFIXO, SUM(E2_VALOR) AS VALOR, SUM(E2_SALDO) AS SALDO, SUBSTRING(E2_BAIXA, 1, 6) AS PERIODO '
   _cRec += 'FROM    SE2010 '
   _cRec += "WHERE   SUBSTRING(E2_BAIXA, 1, 6) BETWEEN '" + _iPer + "' "
   _cRec += " AND '" + _fPer + "'  AND D_E_L_E_T_ <> '*' "
   _cRec += 'GROUP BY E2_TIPO, SUBSTRING(E2_BAIXA, 1, 6), E2_PREFIXO '
   _cRec += 'ORDER BY SUBSTRING(E2_BAIXA, 1, 6), E2_TIPO, E2_PREFIXO '


End
/*
                                          Estoque Atual
*/

_cEst := 'SELECT  SUM(B2_VATU1) AS SALDO, B2_LOCAL '
_cEst += 'FROM    SB2010 '
_cEst += "WHERE     (D_E_L_E_T_ <> '*') AND (B2_LOCAL IN ('01','09') "
_cEst += 'GROUP BY B2_LOCAL'

/*
                                         Despesas Bancarias
*/

_cBco := 'SELECT     SUM(E5_VALOR) AS SOMA, SUBSTRING(E5_DATA, 1, 6) AS DEBITADO, E5_HISTOR AS HST '
_cBco += 'FROM         SE5010 '
_cBco += "WHERE   SUBSTRING(E5_DATA, 1, 6) BETWEEN '" + _iPer + "' "
_cBco += " AND '" + _fPer + "'  AND D_E_L_E_T_ <> '*' AND E5_TIPODOC = 'DB' "
_cBco += 'GROUP BY SUBSTRING(E5_DATA, 1, 6), E5_HISTOR '
_cBco += 'ORDER BY SUBSTRING(E5_DATA, 1, 6)'

dbUseArea( .T., "TOPCONN", TCGENQRY(,,_cPag), 'qPag' )

dbUseArea( .T., "TOPCONN", TCGENQRY(,,_cRec), 'qRec' )

dbUseArea( .T., "TOPCONN", TCGENQRY(,,_cBco), 'qBco' )

dbUseArea( .T., "TOPCONN", TCGENQRY(,,_cEst), 'qEst' )

_aTipRel := { 'POR VENCIMENTO', 'POR EMISSÃO', 'POR BAIXA' }
cTitulo  := "POSIÇÃO FINANCEIRA" + _aTipRel[ MV_PAR03 ]

Cabec1  :="               TIPO   PREFIXO   VALOR                      SALDO"
cabec2  :=""   

M_Pag := 1 
@ 0,0 PSAY Chr( 15 )
nLin  := 50

While _iPer <= _fPer

    _cPer := Substr( _iPer, 5, 2 )
    _cPer += '/'
    _cPer += Substr( _iPer, 1, 4 )

    If nLin > 45
       nLin  := Cabec(ctitulo,cabec1,cabec2,nomeprog,tamanho,1)
    End

    nLin  += 2
    @ nLin,00 PSAY 'Contas a Pagar ' + _cPer
    nLin += 2

    While _iPer = qRec->Periodo

       @ nLin,15 PSAY qRec->Tipo
       @ nLin,21 PSAY qRec->Prefixo
       @ nLin,25 PSAY qRec->Valor Picture '@E 999,999,999.99'
       @ nLin,46 PSAY qRec->Saldo Picture '@E 999,999,999.99'

       _cReg := 'Contas a Pagar;'
       _cReg += _cPer
       _cReg += ';'
       _cReg += qRec->Tipo
       _cReg += ';'
       _cReg += qRec->Prefixo
       _cReg += ';'
       _cReg += Transform( qRec->Valor, '@E 999999999.99' )
       _cReg += ';'
       _cReg += Transform( qRec->Saldo, '@E 999999999.99' )
       _cReg += Chr( 10 )
       fWrite( _nHndl, _cReg )

       nLin ++
       qRec->( dbSkip() )

    End

    If nLin > 45
       nLin  := Cabec(ctitulo,cabec1,cabec2,nomeprog,tamanho,1)
    End

    nLin += 2
    @ nLin,00 PSAY 'Despesas Bancarias ' + _cPer
    nLin += 2

    While _iPer = qBco->Debitado

       @ nLin,15 PSAY Substr( qBco->Hst, 1, 29 )
       @ nLin,46 PSAY qBco->Soma Picture '@E 999,999,999.99'

       _cReg := 'Despesas Bancarias;'
       _cReg += _cPer
       _cReg += ';'
       _cReg += qBco->Hst
       _cReg += '; ; ;'
       _cReg += Transform( qBco->Soma, '@E 999999999.99' )
       _cReg += Chr( 10 )
       fWrite( _nHndl, _cReg )

       nLin ++
       qBco->( dbSkip() )

    End

    If nLin > 45
       nLin  := Cabec(ctitulo,cabec1,cabec2,nomeprog,tamanho,1)
    End

    nLin += 2
    @ nLin,00 PSAY 'Contas a Receber ' + _cPer
    nLin += 2

    While _iPer = qPag->Periodo

       @ nLin,15 PSAY qPag->Tipo
       @ nLin,21 PSAY qPag->Prefixo
       @ nLin,25 PSAY qPag->Valor Picture '@E 999,999,999.99'
       @ nLin,46 PSAY qPag->Saldo Picture '@E 999,999,999.99'

       _cReg := 'Contas a Receber;'
       _cReg += _cPer
       _cReg += ';'
       _cReg += qPag->Tipo
       _cReg += ';'
       _cReg += qPag->Prefixo
       _cReg += ';'
       _cReg += Transform( qPag->Valor, '@E 999999999.99' )
       _cReg += ';'
       _cReg += Transform( qPag->Saldo, '@E 999999999.99' )
       _cReg += Chr( 10 )
       fWrite( _nHndl, _cReg )

       nLin ++
       qPag->( dbSkip() )

    End

    If Substr( _iPer, 5, 2 ) = '12'
       _iPer := Val( Substr( _iPer, 1, 4 ) )
       _iPer ++
       _iPer := Str( _iPer, 4, 0 )
       _iPer += '01'

    Else       

       _iPer := Val( _iPer )
       _iPer ++
       _iPer := Str( _iPer, 6 )
    End

    IncRegua()

End

nLin += 2
@ nLin,00 PSAY 'Saldo em estoque ' + _cPer
nLin += 2

While  ! qEst->( Eof() )

  @ nLin,15 PSAY qEst->B2_Local
  @ nLin,46 PSAY qEst->Saldo  Picture '@E 999,999,999.99'
  nLin ++

  _cReg := 'Saldo em Estoque;' 
  _cReg += _cPer
  _cReg += ';'
  _cReg += qEst->B2_Local
  _cReg += '; ;'
  _cReg += Transform( qEst->Saldo, '@E 999999999.99' )
  _cReg += Chr( 10 )
  fWrite( _nHndl, _cReg )
  
  qEst->( dbSkip() )

End  

fClose( _nHndl )

qPag->( dbCloseArea() )
qRec->( dbCloseArea() )
qBco->( dbCloseArea() )
qEst->( dbCloseArea() )

Ms_Flush()
Set Device To Screen
Set Printer To

If aReturn[5] == 1

   dbcommitAll()
   Ourspool(wnrel)

Endif

Return