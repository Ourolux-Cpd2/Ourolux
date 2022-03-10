#INCLUDE "Protheus.ch"
#INCLUDE "Rwmake.ch"
#INCLUDE "TopConn.ch"

/*
----------------------------------------------------------
* Programa  ouroclean   Autor JFranca Data 07/01/2022
----------------------------------------------------------
* Desc.  Limpa o MOnitor do Transpofrete                                 
*                             
*---------------------------------------------------------
* Uso   Ourolux                                               
----------------------------------------------------------
*/

User Function OUROCLEAN()

Private cPerg := PadR("OUROPER",Len(SX1->X1_GRUPO))

ValidSX1()

If pergunte(cPerg,.T.)
	
	IF Aviso("Aviso","Esta rotina ira Excluir o log de Monitoramento TransporFrete",{"&Sim","&Não"}) == 1

		Processa( {|| SelecPZD() },"Aguarde...","Selecionando movimentos PZD" )
		Processa( {|| SelecPZC() },"Aguarde...","Selecionando movimentos PZC" )
		Processa( {|| SelecPZB() },"Aguarde...","Selecionando movimentos PZB" )

	Else
		MsgStop("Não foi Localizado nenhum movimento ...")
	Endif

Endif

Return

/*
---------------------------------------------------------------
* Programa  SelectMov | Autor  JFranca   |    Data 07/01/2022 *
---------------------------------------------------------------
* Desc.  Seleciona os movimentos do log                       *
---------------------------------------------------------------
*/

Static Function SelecPZD()

Local cQry := ""
ProcRegua(3)

cQry := " DELETE PZD FROM " + RetSqlName("PZD") + " PZD "
cQry += " INNER JOIN " + RetSqlName("PZB") 
cQry += " ON PZB_ID = PZD_IDPROC AND PZB_IDURL = PZD_IDURL "
cQry += " WHERE PZB_DATA >= '" + dtos(mv_par01) + "' "
cQry += " AND PZB_DATA   <= '" + dtos(mv_par02) + "' "

IncProc("Deletando Movimentos PZD")

TcSqlExec(cQry)


//MsgStop("Os movimentos PZD foram excluidas...!!!")

Return()


/*
---------------------------------------------------------------
* Programa  SelecPZC | Autor  JFranca   |    Data 07/01/2022 *
---------------------------------------------------------------
* Desc.  Seleciona os movimentos do log                       *
---------------------------------------------------------------
*/
Static Function SelecPZC()

Local cQry := ""
ProcRegua(3)

cQry += " DELETE PZC FROM " + RetSqlName("PZC") + " PZC " + CRLF
cQry += " INNER JOIN " + RetSqlName("PZB") +  CRLF
cQry += " ON PZB_ID = PZC_IDPROC AND PZB_IDURL = PZC_IDURL " + CRLF
cQry += " WHERE PZB_DATA >= '" + dtos(mv_par01) + "' " + CRLF
cQry += " AND PZB_DATA   <= '" + dtos(mv_par02) + "' " + CRLF

IncProc("Deletando Movimentos PZC")

TcSqlExec(cQry)


//MsgStop("Os Movimentos da tabela PZC foram excluidos...!!!")


Return()

/*
---------------------------------------------------------------
* Programa  SelecPZB | Autor  JFranca   |    Data 07/01/2022 *
---------------------------------------------------------------
* Desc.  Seleciona os movimentos do log                       *
---------------------------------------------------------------
*/
Static Function SelecPZB()

Local cQry := ""
ProcRegua(3)

cQry += " DELETE PZB FROM " + RetSqlName("PZB") + " PZB " + CRLF
cQry += " WHERE PZB_DATA >= '" + dtos(mv_par01) + "' "
cQry += " AND PZB_DATA   <= '" + dtos(mv_par02) + "' "

IncProc("Selecionando Movimentos PZB")

TcSqlExec(cQry)


//MsgStop("Os Movimentos da tabela PZB foram excluidos...!!!")

Return()


/*
---------------------------------------------------------------------------
* Funcao    | ValidSX1 | Autor - Jfranca             | Data |  07/01/2022 *
---------------------------------------------------------------------------
* Descricao | Valida as perguntas no SX1                                  *
---------------------------------------------------------------------------
*/

Static Function ValidSX1(cNomeArq)
Local i
Local xAlias 	:= GetArea()
Local aPergunta	:= {}

/*
----------------------------
* Parametros do Relatorio *
---------------------------
*/              
//              01     02     03                      04    05  06 07  08     09     10 11 12 13 14 15 16
Aadd(aPergunta,{cPerg,"01","Data de     ?"        ,"mv_ch1","D",08,00,"G","MV_PAR01","","","","","","",""})
Aadd(aPergunta,{cPerg,"02","Data ate    ?"        ,"mv_ch2","D",08,00,"G","MV_PAR02","","","","","","",""})

DbSelectArea("SX1")
SX1->(dbSetOrder(1))
For i := 1 To Len(aPergunta)
	SX1->(RecLock("SX1",!dbSeek(aPergunta[i,1]+aPergunta[i,2])))
	SX1->X1_GRUPO 		:= aPergunta[i,1]
	SX1->X1_ORDEM		:= aPergunta[i,2]
	SX1->X1_PERGUNT		:= aPergunta[i,3]
	SX1->X1_VARIAVL		:= aPergunta[i,4]
	SX1->X1_TIPO		:= aPergunta[i,5]
	SX1->X1_TAMANHO		:= aPergunta[i,6]
	SX1->X1_DECIMAL		:= aPergunta[i,7]
	SX1->X1_GSC			:= aPergunta[i,8]
	SX1->X1_VAR01		:= aPergunta[i,9]
	SX1->X1_DEF01		:= aPergunta[i,10]
	SX1->X1_DEF02		:= aPergunta[i,11]
	SX1->X1_DEF03		:= aPergunta[i,12]
	SX1->X1_DEF04		:= aPergunta[i,13]
	SX1->X1_DEF05		:= aPergunta[i,14]
	SX1->X1_F3			:= aPergunta[i,15]
	SX1->X1_VALID		:= aPergunta[i,16]
	If !Empty(cNomeArq) .And. i = 2
		SX1->X1_CNT01 := cNomeArq
	Endif
	SX1->(MsUnlock())
Next i

dbSkip()
While AllTrim(SX1->X1_GRUPO) == AllTrim(cPerg)
	RecLock("SX1",.f.)
	dbDelete()
	MsUnlock()
	dbSkip()
EndDo

RestArea(xAlias)

Return(Nil)
