#IFNDEF WINDOWS
   #DEFINE PSAY SAY
#ENDIF
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ ELET013  ³ Autor ³Airton Lira            ³ Data ³27/11/2000³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Saldos em Estoque com Custos                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Utilidade ³ Emite uma Listagem dos Saldos em Estoque                   ³±±
±±³          ³                                                            ³±±
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
User Function ELET013
#Include "rwmake.ch"
PRIVATE CbTxt:=""
PRIVATE CbCont:=""
PRIVATE nOrdem :=0
PRIVATE Alfa := 0
PRIVATE Z:=0
PRIVATE M:=0
PRIVATE tamanho:="P"
PRIVATE limite:=080
PRIVATE titulo :=PADC("Elet013  - Saldos em Estoque com Valor de Custos           ",75)
PRIVATE cDesc1 :=PADC(" Emite uma rela‡Æo dos saldos em estoque com os,           ",75)
PRIVATE cDesc2 :=PADC(" Valores dos Custos                                        ",75)
PRIVATE cDesc3 :=PADC("                                                           ",75)
PRIVATE aReturn := { "Especial" , 1, "Diretoria" , 1, 2, 1,"", 0 }
PRIVATE nomeprog:="ELET010"
PRIVATE cPerg:=PadR("MTR025",10)
PRIVATE nLastKey:= 0
PRIVATE Li:=0
PRIVATE wnrel    := "ELET13"
PRIVATE M_PAG := 1
PRIVATE nTot:=0

cTitulo := "SALDOS EM ESTOQUE (C/ CUSTOS)"
Cabec1  := "CODIGO LOCAL  DESCRICAO                                  SALDO     VALOR (STD)"
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

dbSelectArea("SB1")
dbSetOrder(1)

dbSelectArea("SB2")
dbSetOrder(1)

_fSB1 := xFilial( 'SB1' )
_fSB2 := xFilial( 'SB2' )

SB1->( dbSeek( _fSB1 + Mv_Par01, .T. ) )
SetRegua( Val( MV_PAR02 ) - Val( MV_PAR01 ) )

Li := Cabec(ctitulo,cabec1,cabec2,nomeprog,tamanho,1)
Li += 2

While ! SB1->( Eof() ) .And.;
      SB1->B1_COD <= MV_PAR02

   @ Li,000 PSAY Subs(SB1->B1_COD,1,8)
   @ Li,010 PSAY MV_PAR03
   @ Li,014 PSAY Substr( SB1->B1_DESC, 1, 40 )

   If ( SB2->( dbSeek( _fSB2 + SB1->B1_COD + '01', .F. ) ) )

      @ Li,056 PSAY SB2->B2_QATU Picture "@E 999999"
      @ Li,066 PSAY (SB2->B2_QATU * SB1->B1_CUSTD) Picture "@E 999,999.99"
      nTot += (SB2->B2_QATU * SB1->B1_CUSTD)

   End

   Li ++

   If Li > 60

      Li := Cabec(ctitulo,cabec1,cabec2,nomeprog,tamanho,1)
      Li += 2

   End

   SB1->( dbSkip() )
   IncRegua()

End

Li := Li + 1
@ Li,000 PSAY Replicate("-",80)
Li := Li + 1
@ Li,045 PSAY "-> TOTAL: "
@ Li,060 PSAY nTot Picture "@E 9,999,999.99"

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


