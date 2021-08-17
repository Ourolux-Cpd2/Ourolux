#IFNDEF WINDOWS
   #DEFINE PSAY SAY
#ENDIF
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ ELET014  ³ Autor ³ELETROMEGA  ³ Data ³19/07/2005           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Saldos em Estoque com Custos                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Utilidade ³ Emite uma Listagem dos Saldos em Estoque POR GRUPO         ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Eletromega                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros                         ³
//³ mv_par01             // Do Grupo                             ³
//³ mv_par02             // Ate Grupo                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
User Function ELET014
#Include "rwmake.ch"
PRIVATE CbTxt:=""
PRIVATE CbCont:=""
PRIVATE nOrdem :=0
PRIVATE Alfa := 0
PRIVATE Z:=0
PRIVATE M:=0
PRIVATE tamanho:="P"
PRIVATE limite:=080
PRIVATE titulo :=PADC("Elet014  - Valor do saldo                                  ",75)
PRIVATE cDesc1 :=PADC(" Emite uma rela‡Æo do valor do saldo                       ",75)
PRIVATE cDesc2 :=PADC("                                                           ",75)
PRIVATE cDesc3 :=PADC("                                                           ",75)
PRIVATE aReturn := { "Especial" , 1, "Diretoria" , 1, 2, 1,"", 0 }
PRIVATE nomeprog:="ELET010"
//PRIVATE cPerg:="MTR025" 
PRIVATE cPerg:=PadR("RSBM",10)
PRIVATE nLastKey:= 0
PRIVATE Li:=0
PRIVATE wnrel    := "ELET14"
PRIVATE M_PAG := 1
PRIVATE nTot:=0

cTitulo := "VALOR DO ESTOQUE POR GRUPO DE PRODUTOS "
Cabec1  := "GRUPO DESCRICAO                                              VALOR"
Cabec2  := " "

Pergunte(cPerg,.F.)

PRIVATE cstring:="SB2"

SetPrint(cString,wnrel,cPerg,Titulo,cDesc1,cDesc2,cDesc3,.T.)

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

Li := Cabec(ctitulo,cabec1,cabec2,nomeprog,tamanho,1)
Li += 1

_cSql := 'SELECT B1_GRUPO AS GRUPO ,BM_DESC AS DESCR,SUM(B2_QATU * B1_CUSTD) AS VALOR '
_cSql += 'FROM ' + RetSqlName("SB1") + ' SB1 ' 
_cSql += "INNER JOIN " + RetSqlName("SB2") + " SB2 ON B2_COD = B1_COD "
_cSql += "INNER JOIN " + RetSqlName("SBM") + " SBM ON B1_GRUPO = BM_GRUPO "
_cSql += "WHERE B1_GRUPO BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "'   "
_cSql += "AND B2_LOCAL = '01' "
_cSql += "AND SB2.D_E_L_E_T_ <> '*' AND SB1.D_E_L_E_T_ <> '*' "
_cSql += "AND SBM.D_E_L_E_T_ <> '*' "
_cSql += "AND  B2_FILIAL = '" + xFilial("SB2") + "' " 
_cSql += "AND  B1_FILIAL = '" + xFilial("SB1") + "' " 
_cSql += "AND  BM_FILIAL = '" + xFilial("SBM") + "' " 
_cSql += "GROUP BY B1_GRUPO,BM_DESC "
_cSql += "ORDER BY B1_GRUPO "

dbUseArea( .T., "TOPCONN", TCGENQRY(,,_cSQL), 'Qry' ) 
SetRegua( Val( MV_PAR02 ) - Val( MV_PAR01 ) )
While ! ( QRY->( Eof() ) )

	@ Li,000 PSAY QRY->GRUPO 
    @ Li,006 PSAY QRY->DESCR
    @ Li,054 PSAY QRY->VALOR  Picture "@E 999,999,999.99" 
	
	nTot += QRY->VALOR
	
	Li ++
 
    If Li > 60
    	Li := Cabec(ctitulo,cabec1,cabec2,nomeprog,tamanho,1)
      	Li += 2

    ENd

	QRY->( dbSkip() )

	IncRegua()

End // while

QRY->( dbCloseArea() )
@ Li,000 PSAY Replicate("-",80)
Li := Li + 1
@ Li,045 PSAY "TOTAL: "
@ Li,054 PSAY nTot Picture "@E 999,999,999.99"

Li := Li + 1
@ Li,000 Say Replicate("*",80)
__Eject()

Set Printer To
MS_FLUSH()
Set Device To Screen

If aReturn[5] == 1
   dbcommitAll()
   ourspool(wnrel)
End

Return
