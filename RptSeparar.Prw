#Include "rwmake.ch"
#IFNDEF WINDOWS
   #DEFINE PSAY SAY
#ENDIF

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณRPTSEPARARบAutor  ณEletromega          บ Data ณ  11/17/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Pedido Mae - Separacao de pedidos                          บฑฑ
ฑฑบ          ณ 1- separar                                                 บฑฑ
ฑฑบ          ณ 2- visualizar                                              บฑฑ
ฑฑบ          ณ 3- cancelar                                                บฑฑ
ฑฑบ          ณ 4- Finalizar Mae                                           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP8                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function RptSepara()

PRIVATE CbTxt    := ""
PRIVATE CbCont   := ""
PRIVATE nOrdem   := 0
PRIVATE Alfa     := 0
PRIVATE Z        := 0
PRIVATE M        := 0
PRIVATE tamanho  := "P"
PRIVATE limite   := 80
PRIVATE titulo   := PADC("RptSeparar - Relat๓rio de Separa็ใo dos Produtos Vendidos ",74)
PRIVATE cDesc1   := PADC("Este Programa tem a Finalidade de Emitir um relat๓rio totalizando ",74)
PRIVATE cDesc2   := PADC("todos os pedidos liberados para faturamento, serarando-os para en-",74)
PRIVATE cDesc3   := PADC("trega uma unica vez por regiใo, nenhum para ้ solicitado.         ",74)
PRIVATE aReturn  := { "Especial", 1,"Administracao", 1, 2, 1,"",1 }
PRIVATE nomeprog := "RptSeparar"
PRIVATE cPerg    := "RPTSEP"
PRIVATE nLastKey := 0
PRIVATE lContinua:= .T.
PRIVATE nLin     := 0
PRIVATE wnrel    := "RptSeparar"

PRIVATE cString:="SF2"

Wnrel:=SetPrint(cString,wnrel,cPerg,Titulo,cDesc1,cDesc2,cDesc3,.F.)

If nLastKey == 27

   Return

End

SetDefault(aReturn,cString)

If nLastKey == 27

   Return

End

RptStatus({|| RptDetail() })
                                            
Return

Static Function RptDetail()

_fSC5 := xFilial( 'SC5' )
SetRegua( 2 )

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤI
//ณSeparar/Visualizar ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤI

If MV_PAR03 == 1 .Or.;  
   MV_PAR03 == 2        
  
   // IMPRESSAO DOS ITENS NO RELATO
   _cQry := 'SELECT SC9.C9_PRODUTO As Produto, SB1.B1_DESC As ProdDesc, SUM(SC9.C9_QTDLIB) As QtdLib, SA1.A1_REGIAO As Regiao '
   _cQry += 'FROM ' +  RetSqlName("SC5") + ' SC5 '
   _cQry += 'INNER JOIN ' + RetSqlName("SC9") + ' SC9 ON SC5.C5_NUM = SC9.C9_PEDIDO INNER JOIN ' + RetSqlName("SB1") + ' SB1 ON '
   _cQry += 'SB1.B1_COD = SC9.C9_PRODUTO INNER JOIN ' + RetSqlName("SA1") + ' SA1 ON ' 
   _cQry += 'SA1.A1_COD = SC5.C5_CLIENTE AND SA1.A1_LOJA = SC5.C5_LOJACLI '
   _cQry += "WHERE SC5.C5_TIPENT <> '1' AND SC5.C5_NOTA = '  ' AND SC5.C5_REIMP < 1 AND "
   _cQry += "      SC9.C9_BLCRED = ' ' AND SC9.C9_BLEST = ' ' AND SC9.D_E_L_E_T_ <> '*' AND "
   _cQry += "      SC5.D_E_L_E_T_ <> '*' AND SC5.C5_OK = ' ' AND SB1.D_E_L_E_T_ <> '*' "
   _cQry += "      AND C5_FILIAL = '" + xFilial("SC5") + "' AND C9_FILIAL = '" + xFilial("SC9") + "' "  
   _cQry += 'GROUP BY SC9.C9_PRODUTO, SB1.B1_DESC, SA1.A1_REGIAO '
   _cQry += 'ORDER BY SA1.A1_REGIAO, SC9.C9_PRODUTO'
 
   dbUseArea( .T., "TOPCONN", TCGENQRY(,,_cQry), 'Qry' )

	// Os pedidos que estao inclusos no pedido mae
   _cImp := 'SELECT DISTINCT SC5.C5_NUM As Pedido, SC5.C5_TABELA As TES, SA1.A1_REGIAO As Regiao '
   _cImp += 'FROM  '+ RetSqlName("SC5") + ' SC5 INNER JOIN ' + RetSqlName("SC9") + ' SC9 ON '
   _cImp += 'SC5.C5_NUM = SC9.C9_PEDIDO INNER JOIN ' + RetSqlName("SA1") + ' SA1 ON '
   _cImp += 'SA1.A1_COD = SC5.C5_CLIENTE AND SA1.A1_LOJA = SC5.C5_LOJACLI '
   _cImp += "WHERE (SC5.C5_TIPENT <> '1') AND (SC5.C5_NOTA = '  ') AND (SC5.C5_REIMP < 1)  AND "
   _cImp += "(SC9.C9_BLCRED = ' ') AND (SC9.C9_BLEST = ' ') AND (SC5.C5_OK = ' ') AND "
   _cImp += "(SC9.D_E_L_E_T_ <> '*') AND (SC5.D_E_L_E_T_ <> '*') AND (SA1.D_E_L_E_T_ <> '*') "
   _cImp += "AND C5_FILIAL = '" + xFilial("SC5") + "' AND C9_FILIAL = '" + xFilial("SC9") + "' "  
   _cImp += 'ORDER BY SC5.C5_NUM '

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤI
//ณCancelar          ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤI
ElseIf MV_PAR03 == 3   
   	
   _cImp := 'SELECT SC5.C5_NUM As Pedido '
   _cImp += 'FROM ' + RetSqlName("SC5") + ' SC5 '
   _cImp += "WHERE (SC5.C5_NOTA = '  ') AND (SC5.C5_OK = 'S') AND "
   _cImp += "(SC5.D_E_L_E_T_ <> '*') AND (SC5.C5_NUM BETWEEN '" + MV_PAR01 +"' AND '" + MV_PAR02 + "') "
   _cImp += "AND SC5.C5_FILIAL = '" + xFilial("SC5") + "' "  // CURITIBA 

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤI
//ณFinalizar         ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤI
ElseIf MV_PAR03 == 4  
	//U_MegaSetMV("FS_MAE","N",cFilAnt)
	  U_setMae("N")
	Return()
EndIf

dbUseArea( .T., "TOPCONN", TCGENQRY(,,_cImp), 'IMP' )

//SEPARAR
If MV_PAR03 == 1  
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤI
	//ณSet Status do mae para executando   ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤI
	//U_MegaSetMV("FS_MAE","S",cFilAnt)
	U_setMae("S")  
		
	// Set C5_OK = 'S' e C5_REIMP += 1 para os pedidos da mae
   _cUpd := "UPDATE " + RetSqlName("SC5") + " SET C5_OK = 'S', C5_REIMP = ( C5_REIMP + 1 ) FROM "
   _cUpd += "( SELECT DISTINCT SC9.C9_PEDIDO AS Pedido "
   _cUpd += "  FROM " + RetSqlName("SC9") + " SC9 INNER JOIN " + RetSqlName("SC5") + " SC5 ON "
   _cUpd += "  SC5.C5_NUM = SC9.C9_PEDIDO AND SC5.C5_TIPENT <> '1' AND SC5.C5_NOTA = '  ' " 
   _cUpd += "  AND SC5.D_E_L_E_T_ <> '*' AND SC5.C5_OK = ' ' "
   _cUpd += "WHERE     SC9.C9_BLCRED = ' ' " 
   _cUpd += "AND SC5.C5_FILIAL = '" + xFilial("SC5") + "'  AND SC9.C9_FILIAL = '" + xFilial("SC9") + "' "  
   _cUpd += "AND SC9.C9_BLEST = ' ' AND SC9.D_E_L_E_T_ <> '*' ) As ABloquear "
   _cUpd += "WHERE  C5_NUM = ABloquear.Pedido "
   _cUpd += "AND C5_FILIAL = '" + xFilial("SC5") + "' " 
   TCSQLExec( _cUpd )

   // SET C9_VENDA PARA OS ITEMS DA MAE
   _cUpd := "UPDATE " + RetSqlName("SC9") + " SET C9_VENDA = ATU.C5_ORCAM + ' ' FROM "
   _cUpd += "(SELECT DISTINCT SC5.C5_NUM AS Pedido, C5_ORCAM "
   _cUpd += "FROM " + RetSqlName("SC5") + " SC5 INNER JOIN " + RetSqlName("SC9") + " SC9 ON "
   _cUpd += "SC9.C9_PEDIDO = SC5.C5_NUM AND SC9.C9_BLCRED = ' ' AND SC9.C9_BLEST = ' ' AND "
   _cUpd += "SC9.D_E_L_E_T_ <> '*' "
   _cUpd += "WHERE SC5.C5_TIPENT <> '1' AND SC5.C5_NOTA = '  ' "
   _cUpd += "AND SC5.C5_FILIAL = '" + xFilial("SC5") + "'  AND SC9.C9_FILIAL = '" + xFilial("SC9") + "' "   
   _cUpd += "AND SC5.D_E_L_E_T_ <> '*' AND SC5.C5_OK = 'S') AS ATU "
   _cUpd += "WHERE  C9_PEDIDO = ATU.Pedido AND D_E_L_E_T_ <> '*' "
   _cUpd += "AND C9_FILIAL = '" + xFilial("SC9") + "' "  
   TCSQLExec( _cUpd )
EndIf

M_Pag  := 1 
SetPrc( 0,0 )
nLin   := 61
Cabec1 := 'PEDIDO     TES   REGIAO'
Cabec2 := ' ' 

While !IMP->(Eof())

   If MV_PAR03 == 1 .Or. MV_PAR03 == 2  
   
      ImpSepNota()

   ElseIf MV_PAR03 == 3 

      If ( SC5->( dbSeek( _fSC5 + IMP->Pedido, .F. ) ) )

         RecLock( 'SC5', .F. )
         SC5->C5_REIMP := 0
         SC5->C5_OK    := ' '
         SC5->( MSUnLock() )

      End

   End
   
   IMP->( dbSkip() )

End

IMP->( dbCloseArea() )
IncRegua()

If MV_PAR03 == 1 .Or. MV_PAR03 == 2 

   ImpSepProd()

   Ms_Flush()
   Set Device To Screen
   Set Printer To

   If aReturn[ 5 ] == 1

      Ourspool( wnrel )

   End

End

Return()

Static Function ImpSepNota()

If nLin > 60

   cTitulo := 'PEDIDOS A SEREM FATURADOS NA SEPARACAO'
   nLin := Cabec(ctitulo,cabec1,cabec2,nomeprog,tamanho,15)
   nLin ++

End

@ nLin,00 PSAY IMP->Pedido
if IMP->TES = "900"
@ nLin,11 PSAY "900"
ELSE
@ nLin,11 PSAY "501"
ENDIF
@ nLin,17 PSAY IMP->Regiao

nLin ++

Return( NIL )

Static Function ImpSepProd()

Cabec1 := 'CODIGO     PRODUTO                                           QUANTIDADE'
cabec2 := ""   
_cReg  := ''
_aProd := {}
_nLen  := 0

QRY->( dbGoTop() )

While ! QRY->( Eof() )

    If nLin > 60 .Or.;
       _cReg <> QRY->Regiao

       cTitulo := 'REGIAO : ' + QRY->Regiao
       _cReg := QRY->Regiao
       nLin := Cabec(ctitulo,cabec1,cabec2,nomeprog,tamanho,15)
       nLin ++

    End

    @ nLin,00 PSAY Substr( QRY->Produto, 1, 10 )
    @ nLin,11 PSAY QRY->ProdDesc
    @ nLin,59 PSAY Transform( QRY->QtdLib, "@E 9,999,999.99" )

    _nPos := aScan( _aProd, { |x| x[1] = QRY->Produto } )

    If _nPos <> 0

       _aProd[ _nPos ][ 3 ] += QRY->QtdLib

    Else

       aAdd( _aProd, { QRY->Produto, QRY->ProdDesc, QRY->QtdLib } )
       _nLen ++

    End

    nLin ++
    QRY->( dbSkip() )

End

_aProd := aSort( _aProd,,, { |x, y| x[ 1 ] < y[ 1 ] } )
nLin := 61

For i := 1 To _nLen

    If nLin > 60

       cTitulo := 'TOTAL DOS PRODUTOS A SEREM SEPARADOS'
       nLin := Cabec(ctitulo,cabec1,cabec2,nomeprog,tamanho,15)
       nLin ++

    End

    @ nLin,00 PSAY Substr( _aProd[ i ] [ 1 ], 1, 10 )
    @ nLin,11 PSAY _aProd[ i ][ 2 ]
    @ nLin,59 PSAY Transform( _aProd[ i ][ 3 ], "@E 9,999,999.99" )
    nLin ++

Next

IncRegua()
QRY->( dbCloseArea() ) 
__Eject()

Return(NIL)