/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณM410GET   บAutor  ณMicrosiga           บ Data ณ  10/17/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ M410GET ( < UPAR > ) --> URET                              บฑฑ
ฑฑบ          ณ Retorno Nenhum                                             บฑฑ 
ฑฑบ          ณ Antes de montar tela de alteracao de pedidos               บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP8                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
#INCLUDE "PROTHEUS.CH"
 
User Function M410Get()

// Implementacao para tratar as importacoes de Pedidos via SFA
If Type("L410Auto")!="U" .And. L410Auto
	If !U_xAuto410()
		Return (.T.)
	EndIf
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤI
//ณEnable a consulta de pre็o p altera็ao de ped   ณ
//ณWAR 04-11-2008                                  ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤI
SetKey(VK_F2,{|| U_PrcXCom()})

Public _nPosCfo, _nPosCla, _nPosCst, _nPosDct, _nPosLoc, _nPosMrg, _nPosBxo,;
       _nPosPrc, _nPosDIR, _nPosPrd, _nPosUni, _nPos501, _nPos900, _nPosLib,;
       _nPosQTD, _nPosTES, _nPosDcV, _nPosVlr, _nPosCom, _nPosNFD, _nPosSer,;
       _nPosIte, _nPosQdL, _nPosRet, _nPosInd, _cBxo   , _aTabela, _nPosTab,;
       _aCodTab, _nPosUM , _nPosSeg, _nPosMed, _cLibPed

_cEnd := ''
_nPosCfo := aScan( aHeader, { |nVal| Trim( nVal[ 2 ] ) == "C6_CF"      } )
_nPosCla := aScan( aHeader, { |nVal| Trim( nVal[ 2 ] ) == "C6_CLASFIS" } )
_nPosCst := aScan( aHeader, { |nVal| Trim( nVal[ 2 ] ) == "C6_CUSTD"   } )
_nPosDct := aScan( aHeader, { |nVal| Trim( nVal[ 2 ] ) == "C6_DESCONT" } )
_nPosLoc := aScan( aHeader, { |nVal| Trim( nVal[ 2 ] ) == "C6_LOCAL"   } )
_nPosMrg := aScan( aHeader, { |nVal| Trim( nVal[ 2 ] ) == "C6_MARGEM"  } )
_nPosBxo := aScan( aHeader, { |nVal| Trim( nVal[ 2 ] ) == "C6_PRCBX"   } )
_nPosPrc := aScan( aHeader, { |nVal| Trim( nVal[ 2 ] ) == "C6_PRCVEN"  } )
_nPosDIR := aScan( aHeader, { |nVal| Trim( nVal[ 2 ] ) == "C6_PRDIRE"  } )
_nPosPrd := aScan( aHeader, { |nVal| Trim( nVal[ 2 ] ) == "C6_PRODUTO" } )
_nPosUni := aScan( aHeader, { |nVal| Trim( nVal[ 2 ] ) == "C6_PRUNIT"  } )
_nPos501 := aScan( aHeader, { |nVal| Trim( nVal[ 2 ] ) == "C6_PRVD501" } )
_nPos900 := aScan( aHeader, { |nVal| Trim( nVal[ 2 ] ) == "C6_PRVD900" } )
_nPosLib := aScan( aHeader, { |nVal| Trim( nVal[ 2 ] ) == "C6_LIBPBX"  } )
_nPosQdL := aScan( aHeader, { |nVal| Trim( nVal[ 2 ] ) == "C6_QTDLIB"  } )
_nPosQTD := aScan( aHeader, { |nVal| Trim( nVal[ 2 ] ) == "C6_QTDVEN"  } )
_nPosTES := aScan( aHeader, { |nVal| Trim( nVal[ 2 ] ) == "C6_TES"     } )
_nPosDcV := aScan( aHeader, { |nVal| Trim( nVal[ 2 ] ) == "C6_VALDESC" } )
_nPosVlr := aScan( aHeader, { |nVal| Trim( nVal[ 2 ] ) == "C6_VALOR"   } )
_nPosInd := aScan( aHeader, { |nVal| Trim( nVal[ 2 ] ) == "C6_COMIS1"  } )
_nPosCom := aScan( aHeader, { |nVal| Trim( nVal[ 2 ] ) == "C6_VLCOM1"  } )
_nPosNFD := aScan( aHeader, { |nVal| Trim( nVal[ 2 ] ) == "C6_NFORI"   } )
_nPosSer := aScan( aHeader, { |nVal| Trim( nVal[ 2 ] ) == "C6_SERIORI" } )
_nPosIte := aScan( aHeader, { |nVal| Trim( nVal[ 2 ] ) == "C6_ITEMORI" } )
_nPosRet := aScan( aHeader, { |nVal| Trim( nVal[ 2 ] ) == "C6_PICMRET" } )
_nPosUM  := aScan( aHeader, { |nVal| Trim( nVal[ 2 ] ) == "C6_UM"      } )
_nPosSeg := aScan( aHeader, { |nVal| Trim( nVal[ 2 ] ) == "C6_SEGUM"   } )
_nPosMed := aScan( aHeader, { |nVal| Trim( nVal[ 2 ] ) == "C6_UNSVEN"  } )

_aCodTab := { {'1  ', 0.015 },; //  Revenda    PRMN501
              {'2  ', 0.015 },; //  900        PRMN900
              {'3  ', 0     },; //  Direto     PRDIRE
              {'6  ', 0.03  } ; //  Supermercado PRSUP
            }

_aTabela := {}
_nLen    := Len( aCols )
_nOld    := n

n        := _nOld
_cLibPed := 'N'

If __cUserId = '000021'

   _cQuery := 'SELECT  COUNT( * ) AS vLiber '
   _cQuery += 'FROM ' + RetSqlName("SC9") + ' SC9 '
   _cQuery += "WHERE  ( C9_PEDIDO = '" + SC5->C5_NUM +"' ) AND ( D_E_L_E_T_ <> '*') "
   _cQuery += " AND ( C9_BLCRED = '  ' )"
   _cQuery += " AND C9_FILIAL = '" + xFilial("SC9") + "' "  
   dbUseArea( .T., "TOPCONN", TCGENQRY(,,_cQuery), 'Query' )

   If SC5->C5_LIBEROK = 'S' .And.;
      Query->vLiber   <> 0

      _cLibPed := 'S'

   End

   Query->( dbCloseArea() )

End

Return( NIL )