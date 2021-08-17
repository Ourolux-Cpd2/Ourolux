#IFNDEF WINDOWS
   #DEFINE PSAY SAY
#ENDIF
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ MEGA20   ³ Autor ³Sérgio Santana         ³ Data ³18/10/2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ RELA€ŽO DE VENDA MENSAL POR PRODUTO                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Utilidade ³ Imprime a Totalizacao das Vendas de um Determinado Produto ³±±
±±³          ³ Durante um Periodo Pr‚ Estabelecido.                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Eletromega                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros                         ³
//³ mv_par01             // Do Produto                           ³
//³ mv_par02             // Ate o Produto                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
User Function MEGA20
#Include "rwmake.ch"
Private CbTxt:=""
Private CbCont:=""
Private nOrdem :=0
Private Alfa := 0
Private Z:=0
Private M:=0
Private tamanho:="G"
Private limite:=254
Private titulo :=PADC("MEGA20 - Venda Mensal por Produto, Uso exclusivo da ELETROMEGA     ",75)
Private cDesc1 :=PADC("Este Programa ira emitir o Relatorio de Totais de Venda por Produto",75)
Private cDesc2 :=PADC("com media dos ultimos 03 meses e produtos similares.               ",75)
Private cDesc3 :=PADC("                                                                   ",75)
Private aReturn := { "Especial" , 1, "Diretoria" , 2, 2, 1,"", 0 }
Private nomeprog:="MEGA20"
Private cPerg:=PadR("MEGA20",10)
Private nLastKey:= 0
Private Li:=0
Private xPag:=1
Private wnrel := "MEGA20"

Pergunte(cPerg,.F.)

Private cString:="SB1"

wnrel:=SetPrint(cString,wnrel,cPerg,Titulo,cDesc1,cDesc2,cDesc3,.T.)
If nLastKey == 27
   Return
Endif

SetDefault(aReturn,cString)
If nLastKey == 27
   Return
Endif

RptStatus({|| RptDetail() })

Return

Static Function RptDetail

cTitulo := "Mapa Anual de Produtos Vendidos do Codigo "+Alltrim(Mv_Par01)+" ate "+Alltrim(Mv_Par02)

_pIni := DtoS( MV_PAR04 )
_pFim := DtoS( MV_PAR05 )

_pIni := Substr( _pIni, 1, 6 )
_pFim := Substr( _pFim, 1, 6 )

_nMeses := Month( MV_PAR05 )
_nMes   := Month( MV_PAR04 )

If Year( MV_PAR05 ) = Year( MV_PAR04 )

   _nMeses := Month( MV_PAR05 )
   _nMes   := Month( MV_PAR04 )
   _nMeses -= _nMes

Else

  _nYear := Year( MV_PAR05 )
  _nYear -= Year( MV_PAR04 )
  _nYear -= 1
  _nYear *= 12
  
  _nMeses := Month( MV_PAR04 )
  _nMeses :=  12 - _nMeses
  _nMeses += Month( MV_PAR05 )

End

_nMeses ++

If _nMeses > 12 

   MsgInfo( 'Periodo superior a 12 meses, por gentileza reveja o periodo a ser impresso..' )
   Return()

ElseIf MV_PAR05 < MV_PAR04

   MsgInfo( 'Data do periodo final superior ao periodo inicial...' )
   Return()

End

If MV_PAR07 <> 1

   _cQry := "SELECT D2_COD AS Codigo, SUBSTRING(D2_EMISSAO, 1, 6) AS Periodo, "
   _cQry += '       SUM(D2_QUANT) AS Qde, D2_LOCAL AS Local '
   _cQry += 'FROM   SD2010 '
   _cQry += "WHERE (SUBSTRING(D2_EMISSAO, 1, 6) BETWEEN '" + _pIni + "' AND '" + _pFim + "') AND (D2_LOCAL = '" + MV_PAR06 + "') AND "
   _cQry += "      (D_E_L_E_T_ <> '*') AND (D2_TIPO = 'N') AND (D2_COD BETWEEN '" + Substr( MV_PAR01, 1, 5 ) + "' AND '" + Substr( MV_PAR02, 1, 5 ) + "') "
   _cQry += "AND D2_FILIAL = '" + xFilial("SD2") + "' "  // CURITIBA
   _cQry += "GROUP  BY D2_COD, SUBSTRING(D2_EMISSAO, 1, 6), D2_LOCAL "
   _cQry += "ORDER BY D2_COD, SUBSTRING(D2_EMISSAO, 1, 6) "

Else

   _cQry := "SELECT D2_COD AS Codigo, CASE WHEN SUBSTRING(D2_EMISSAO, 7, 2) < 16 THEN '1' ELSE '2' END AS Quinzena, SUBSTRING(D2_EMISSAO, 1, 6) AS Periodo, "
   _cQry += "       SUM(D2_QUANT) AS Qde, D2_LOCAL AS Local "
   _cQry += "FROM   SD2010 "
   _cQry += "WHERE (SUBSTRING(D2_EMISSAO, 1, 6) BETWEEN '" + _pIni + "' AND '" + _pFim + "') AND (D2_LOCAL = '" + MV_PAR06 + "') AND "
   _cQry += "      (D_E_L_E_T_ <> '*') AND (D2_TIPO = 'N') AND (D2_COD BETWEEN '" + Substr( MV_PAR01, 1, 5 ) + "' AND '" + Substr( MV_PAR02, 1, 5 ) + "') "
   _cQry += "AND D2_FILIAL = '" + xFilial("SD2") + "' "  // CURITIBA
   _cQry += "GROUP  BY D2_COD, SUBSTRING(D2_EMISSAO, 1, 6), CASE WHEN SUBSTRING(D2_EMISSAO, 7, 2) < 16 THEN '1' ELSE '2' END, D2_LOCAL "
   _cQry += "ORDER BY D2_COD, SUBSTRING(D2_EMISSAO, 1, 6), CASE WHEN SUBSTRING(D2_EMISSAO, 7, 2) < 16 THEN '1' ELSE '2' END "

End

dbUseArea( .T., "TOPCONN", TCGENQRY(,,_cQry), 'Qry' )

_nRegua := 0
While ! Eof()

   Qry->( dbSkip() )
   _nRegua ++

End

Qry->( dbGoTop() )

SetRegua( _nRegua )

_cCmp := "SELECT C7_PRODUTO, SUM( C7_QUANT - C7_QUJE ) As Pedido "
_cCmp += "FROM   SC7010 "
_cCmp += "WHERE (C7_PRODUTO BETWEEN '" + Substr( MV_PAR01, 1, 5 ) + "' AND '" + Substr( MV_PAR02, 1, 5 ) + "') AND (D_E_L_E_T_ <> '*') AND (C7_RESIDUO <> 'S') "
_cCmp += "AND C7_FILIAL = '" + xFilial("SC7") + "' "  // CURITIBA
_cCmp += "GROUP  BY C7_PRODUTO "
_cCmp += "ORDER BY C7_PRODUTO "

dbUseArea( .T., "TOPCONN", TCGENQRY(,,_cCmp), 'Cmp' )

dbSelectArea("SB1")
dbSetOrder(1)
SB1->( dbSeek( xFilial( 'SB1' ) + MV_PAR01, .T. ) )

If Substr( MV_PAR01, 1, 2 ) <> Substr( B1_COD, 1, 2 )

   Return()

End

_aMesExt := { 'Jan', 'Fev', 'Mar',;
              'Abr', 'Mai', 'Jun',;
              'Jul', 'Ago', 'Set',;
              'Out', 'Nov', 'Dez' ;
            }

_aMeses := {}
_aQuinz := {}
_cAno   := Year( MV_PAR04 )
_cAno   := Str( _cAno, 4 )
Cabec1 := '                                         '
Cabec2 := 'Codigo Descricao                      UM '

For i = 1 To _nMeses

    aAdd( _aMeses, '    ' + _aMesExt[ _nMes ] + '/' + _cAno + '    ')
    aAdd( _aQuinz, '   1¦Q     2¦Q  ' )

    Cabec1 += _aMeses[ i ]

    If MV_PAR07 <> 1
       Cabec2 += '                '
    Else
       Cabec2 += _aQuinz[ i ]
    End
   
    _nMes ++

    If _nMes > 12

       _cAno := Val( _cAno )
       _cAno ++
       _cAno := Str( _cAno, 4 )
       _nMes := 1

    End

Next

//Cabec2 += '     Media   SDO ATUAL ULT. PRC. PED.PEND.' 
Cabec2 += '     Media   SDO ATUAL           PED.PEND.'

_fSB2 := xFilial( "SB2" )
_fSB1 := xFilial( "SB1" )

M_Pag := 1 

If MV_PAR07 <> 1
   @ 0,0 PSAY Chr( 27 ) + '@' + Chr( 27 ) + 'M' + Chr( 15 )
Else
   @ 0,0 PSAY Chr( 27 ) + '@' + Chr( 27 ) + 'P' + Chr( 15 )
End

_nLin := Cabec( ctitulo, cabec1, cabec2, nomeprog, tamanho, 1 )
_nLin += 2

While !SB1->( Eof() ) .And.;
		SB1->B1_COD <= MV_PAR02 .And.;
		SB1->B1_FILIAL == xFilial("SB1")   
      
   If _nLin > 58

      _nLin := Cabec( ctitulo, cabec1, cabec2, nomeprog, tamanho, 1 )
      _nLin += 2

   End

   SB2->( dbSeek( _fSB2 + SB1->B1_Cod + "01") )

   @ _nLin,000 PSAY Substr( SB1->B1_Cod , 1, 6 )
   @ _nLin,007 PSAY Substr( SB1->B1_Desc, 1, 30 )
   @ _nLin,038 PSAY SB1->B1_UM

   _nMes := Month( MV_PAR04 )
   _qMes := {}
   _qMed := 0

   For i = 1 To _nMeses

       aAdd( _qMes  , { _nMes, 0, 0 } )
       _nMes ++

       If _nMes > 12

          _nMes := 1

       End

   Next

   If QRY->Codigo = SB1->B1_COD

      _cCod := QRY->Codigo

      While _cCod == QRY->Codigo

         _nMes := Substr( QRY->Periodo, 5, 2 )
         _nMes := Val( _nMes )
         _nLen := aScan( _qMes, { |x| x[ 1 ] = _nMes } )

         If MV_PAR07 <> 1

            _qMes[ _nLen ][    2  ] := QRY->Qde

         Else

           _nQui := Val( QRY->Quinzena )
           _nQui ++
           _qMes[ _nLen ][ _nQui ] := QRY->Qde

         End

         _qMed += QRY->Qde
         QRY->( dbSkip() )
         IncRegua()

     End

  End 

  _nCol := 41
  _nMes := Month( MV_PAR04 )

  For i = 1 To _nMeses

      If MV_PAR07 <> 1

         _nCol += 8
         @ _nLin, _nCol PSAY _qMes[  i ][ 2 ] Picture '@EZ 999,999'
         _nCol += 8      

      Else

         @ _nLin, _nCol PSAY _qMes[  i ][ 2 ] Picture '@EZ 999,999'
         _nCol += 8                 
         @ _nLin, _nCol PSAY _qMes[  i ][ 3 ] Picture '@EZ 999,999'
         _nCol += 8      

      End

      _nMes ++

      If _nMes > 12

         _nMes := 1

      End

   Next

   _qMed /= _nMeses
   _nCol += 3

   @ _nLin, _nCol PSAY _qMed        Picture '@EZ 999,999'
   _nCol += 8
   @ _nLin, _nCol PSAY SB2->B2_QATU Picture '@EZ 999,999'
   _nCol += 8
   //@ _nLin, _nCol PSAY SB1->B1_UPRC Picture '@EZ 99,999.99'
   _nCol += 12

   CMP->( dbGoTop() )
   
   While !CMP->( Eof() )
   
      If SB1->B1_COD == CMP->C7_Produto
      	@ _nLin, _nCol PSAY IIF(CMP->Pedido > 0,CMP->Pedido,0) Picture '@EZ 9,999,999.99'
      	Exit
      ElseIf SB1->B1_COD > CMP->C7_Produto
      	CMP->( dbSkip() ) 
      Else
      	Exit
      EndIf	  	
   EndDo 
   
   _nLin ++
   SB1->( dbSkip() )

End

QRY->( dbCloseArea() )
CMP->( dbCloseArea() )

@ 0,0 PSAY Chr( 27 )+ '@'

MS_FLUSH()

Set Device To Screen
Set Printer To

If aReturn[5] == 1

   dbcommitAll()
   ourspool(wnrel)

Endif

Return