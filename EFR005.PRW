#INCLUDE "rwmake.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³EFR005    º Autor ³ AP6 IDE            º Data ³  12/08/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Codigo gerado pelo AP6 IDE.                                º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP6 IDE                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function EFR005
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Local cDesc1       := "Este programa tem como objetivo imprimir relatorio "
Local cDesc2       := "de acordo com os parametros informados pelo usuario."
Local cDesc3       := ""
Local cPict        := ""
Local nLin         := 80
Local Cabec1       := "Banco  Agencia  Conta      Cheque          Vencto     Valor Cheque  Status"
Local Cabec2       := ""
Local imprime      := .T.
Local aOrd         := {}
Local aPergs       := {}  
Private Titulo     := "Relatorio de Cheques Devolvidos"
Private cPerg      := ""
Private lEnd       := .F.
Private lAbortPrint:= .F.
Private CbTxt      := ""
Private limite     := 80
Private tamanho    := "P"
Private nomeprog   := "EFR005" // Coloque aqui o nome do programa para impressao no cabecalho
Private nTipo      := 18
Private aReturn    := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
Private nLastKey   := 0
Private cbtxt      := Space(10)
Private cbcont     := 00
Private CONTFL     := 01
Private m_pag      := 01
Private wnrel      := "EFR005" // Coloque aqui o nome do arquivo usado para impressao em disco
Private cString    := "SZ2"

aPergs:= {}
cPerg:= "EFR005"
aAdd(aPergs,{'Data De  ?'  ,'Data De  ?'    , 'Data De  ?'    , 'mv_ch1','D', 8 , 0,	0,	'G',	'',	'mv_par01',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	''})
aAdd(aPergs,{'Data Ate ?'  ,'Data Ate ?'    , 'Data Ate ?'    , 'mv_ch2','D', 8 , 0,	0,	'G',	'',	'mv_par02',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	''})

A001SX1(cPerg,aPergs)
Pergunte(cPerg,.F.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta a interface padrao com o usuario...                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

wnrel := SetPrint(cString,NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,.F.,Tamanho,,.F.)

If nLastKey == 27
	Return
Endif

SetDefault(aReturn,cString)

If nLastKey == 27
	Return
Endif

nTipo := If(aReturn[4]==1,15,18)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Processamento. RPTSTATUS monta janela com a regua de processamento. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

RptStatus({|| RunReport(Cabec1,Cabec2,Titulo,nLin) },Titulo)
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFun‡„o    ³RUNREPORT º Autor ³ AP6 IDE            º Data ³  12/08/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescri‡„o ³ Funcao auxiliar chamada pela RPTSTATUS. A funcao RPTSTATUS º±±
±±º          ³ monta a janela com a regua de processamento.               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Programa principal                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function RunReport(Cabec1,Cabec2,Titulo,nLin,cTipo)
Local lPrint   := .F.      
Local cQuery   := ""
Local cAliasQry:= ""
Local cStatus  := "F"
Local cTitulo  := ""
Local cCheque  := ""
Local nOrdem
Local dData
Local nSubChq  := 0
Local nTotalChq:= 0                
Local nI       := 0 
Local nPos     := 0
Local aCheques := {}
Local aStruct  := {} 
Local aStatus  := {{"A","Recebido Paraiso"},;
			       {"B","Recebido Guarulhos"},;
				   {"C","Armazenado"},;
				   {"D","Baixado"},;
				   {"E","Repassado"},;
				   {"F","Devolvido"},;
				   {"G","Quitado"}}
				

cQuery := "	SELECT DISTINCT SZ2.Z2_BANCO,SZ2.Z2_AGENCIA,SZ2.Z2_CONTA,SZ2.Z2_CHEQUE,SZ2.Z2_DATA "
cQuery += " FROM " + RetSqlName("SZ2") + " SZ2 "
cQuery += " WHERE SZ2.D_E_L_E_T_ <> '*' "
cQuery += " AND SZ2.Z2_STATUS IN ('" + cStatus + "') "
cQuery += " AND SZ2.Z2_OBSERVA = '' "
cQuery += " AND SZ2.Z2_DATA BETWEEN '" + Dtos(Mv_Par01) + "' AND '" + Dtos(Mv_Par02) + "' "
cQuery += " AND SZ2.Z2_FILIAL = '" + xFilial("SZ2") + "' "
cQuery += " ORDER BY SZ2.Z2_DATA,SZ2.Z2_BANCO,SZ2.Z2_AGENCIA,SZ2.Z2_CONTA,SZ2.Z2_CHEQUE"

cQuery := ChangeQuery( cQuery )

cAliasQry := CriaTrab(,.F.)
DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAliasQry, .F., .T.)

aStruct := SZ2->(dbStruct())
For nI:= 1 to Len(aStruct)
	If aStruct[nI,2] <> "C"
		If (cAliasQry)->(FieldPos(aStruct[nI,1])) > 0
			TCSetField(cAliasQry, aStruct[nI,1], aStruct[nI,2], aStruct[nI,3], aStruct[nI,4])
		EndIf
	EndIf
Next nI
	
dbSelectArea(cAliasQry)
dbGotop()
SetRegua(RecCount())
dData:= (cAliasQry)->Z2_DATA
While !(cAliasQry)->(Eof())

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Valida o filtro do status.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("SZ1")
	dbSetOrder(1)
	dbSeek(xFilial("SZ1")+(cAliasQry)->(Z2_BANCO+Z2_AGENCIA+Z2_CONTA+Z2_CHEQUE),.T.)

	aAdd(aCheques,{(cAliasQry)->Z2_BANCO,(cAliasQry)->Z2_AGENCIA,(cAliasQry)->Z2_CONTA,(cAliasQry)->Z2_CHEQUE,(cAliasQry)->Z2_DATA,SZ1->Z1_VENCTO,SZ1->Z1_VALOR})

	dbSelectArea(cAliasQry)
	dbSkip()
End

If (Len(aCheques) > 0)
	dData:= aCheques[1,5]
EndIf

For nI:= 1 To Len(aCheques)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica o cancelamento pelo usuario...                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lAbortPrint
		@nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
		Exit
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Impressao do cabecalho do relatorio. . .                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	If nLin > 65 // Salto de Página. Neste caso o formulario tem 55 linhas...
		Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
		nLin := 8

		@nLin,00 PSAY __PrtThinLine()
		nLin++
		
		@nLin,00 PSAY "Data: "+Dtoc(dData)
		nLin++
		
		@nLin,00 PSAY __PrtThinLine()
		nLin++
	Endif
	
	If dData <> aCheques[nI,5]
		If nLin > 65 // Salto de Página. Neste caso o formulario tem 55 linhas...
			Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
			nLin := 8
	
			@nLin,00 PSAY __PrtThinLine()
			nLin++
			
			@nLin,00 PSAY "Data: "+Dtoc(dData)
			nLin++
			
			@nLin,00 PSAY __PrtThinLine()
			nLin++
		Endif
	
		nLin++
		@nLin,00  PSAY "Total do Dia "+Dtoc(dData)
		@nLin,50  PSAY GetMv("MV_SIMB1")+Transform(nSubChq,PesqPict("SZ1","Z1_VALOR"))
		nTotalChq+= nSubChq
		nSubChq  := 0        

		dData:= aCheques[nI,5]
		nLin++

		@nLin,00 PSAY __PrtThinLine()
		nLin++
		
		@nLin,00 PSAY "Data: "+Dtoc(dData)
		nLin++
		
		@nLin,00 PSAY __PrtThinLine()
		nLin++
	EndIf
	
	@nLin,00  PSAY aCheques[nI,1] //Banco
	@nLin,07  PSAY aCheques[nI,2] //Agencia
	@nLin,16  PSAY aCheques[nI,3] //Conta
	@nLin,27  PSAY aCheques[nI,4] //Cheque 
	@nLin,43  PSAY Dtoc(aCheques[nI,6]) //Data
	@nLin,52  PSAY Transform(aCheques[nI,7],PesqPict("SZ1","Z1_VALOR"))
	@nLin,68  PSAY aStatus[aScan(aStatus,{|x| x[1] == SZ1->Z1_STATUS}),2]

	nSubChq+= aCheques[nI,7]
	
	nLin++// Avanca a linha de impressao

	lPrint:= .T.
Next nI

If lPrint
	nLin++  
	
	If nLin > 65 // Salto de Página. Neste caso o formulario tem 55 linhas...
		Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
		nLin := 8

		@nLin,00 PSAY __PrtThinLine()
		nLin++
		
		@nLin,00 PSAY "Data: "+Dtoc(dData)
		nLin++
		
		@nLin,00 PSAY __PrtThinLine()
		nLin++
	Endif	
	
	@nLin,00  PSAY "Total do Dia "+Dtoc(dData)
	@nLin,50  PSAY GetMv("MV_SIMB1")+Transform(nSubChq,PesqPict("SZ1","Z1_VALOR"))
	nTotalChq+= nSubChq
	nSubChq  := 0        

	nLin+= 2
	
	If nLin > 65 // Salto de Página. Neste caso o formulario tem 55 linhas...
		Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
		nLin := 8

		@nLin,00 PSAY __PrtThinLine()
		nLin++
		
		@nLin,00 PSAY "Data: "+Dtoc(dData)
		nLin++
		
		@nLin,00 PSAY __PrtThinLine()
		nLin++
	Endif
	
	@nLin,00  PSAY "Total Geral "
	@nLin,50  PSAY GetMv("MV_SIMB1")+Transform(nTotalChq,PesqPict("SZ1","Z1_VALOR"))
	
	nLin+= 5
	
	If nLin > 65 // Salto de Página. Neste caso o formulario tem 55 linhas...
		Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
		nLin := 8

		@nLin,00 PSAY __PrtThinLine()
		nLin++
		
		@nLin,00 PSAY "Data: "+Dtoc(dData)
		nLin++
		
		@nLin,00 PSAY __PrtThinLine()
		nLin++
	Endif
	
	@nLin,00 PSAY "Emitido Por : ______________________________________"
	
	nLin++
	
	If nLin > 65 // Salto de Página. Neste caso o formulario tem 55 linhas...
		Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
		nLin := 8

		@nLin,00 PSAY __PrtThinLine()
		nLin++
		
		@nLin,00 PSAY "Data: "+Dtoc(dData)
		nLin++
		
		@nLin,00 PSAY __PrtThinLine()
		nLin++
	Endif
	
	@nLin,00 PSAY "Data Emissao: "+Dtoc(dDatabase)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Finaliza a execucao do relatorio...                                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//Roda()
EndIf
	
dbCloseArea(cAliasQry)

SET DEVICE TO SCREEN

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se impressao em disco, chama o gerenciador de impressao...          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If aReturn[5]==1
	dbCommitAll()
	SET PRINTER TO
	OurSpool(wnrel)
Endif

MS_FLUSH()

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ A001SX1      ³ Autor ³ Fabio Rogerio Pereira ³ Data ³ 04/05/01 ³±±                                                     ±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Verifica as perguntas inclu¡ndo-as caso n„o existam            ³±±                                                            ±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function A001SX1(cPerg,aPergs)
Local aArea 	:= GetArea()
Local aCposSX1	:= {}
Local nX := 0

aCposSX1:={"X1_PERGUNT","X1_PERSPA","X1_PERENG","X1_VARIAVL","X1_TIPO","X1_TAMANHO","X1_DECIMAL",;
"X1_PRESEL","X1_GSC","X1_VALID","X1_VAR01","X1_DEF01","X1_DEFSPA1","X1_DEFENG1",;
"X1_CNT01","X1_VAR02","X1_DEF02","X1_DEFSPA2","X1_DEFENG2","X1_CNT02","X1_VAR03","X1_DEF03","X1_DEFSPA3","X1_DEFENG3","X1_CNT03","X1_F3" }

cPerg := PadR(cPerg,10)

dbSelectArea("SX1")
dbSetOrder(1)
For nX:=1 to Len(aPergs)
	If !(MsSeek(cPerg+StrZero(nx,2)))
		RecLock("SX1",.T.)
		Replace X1_GRUPO with cPerg
		Replace X1_ORDEM with StrZero(nx,2)
		For nj:=1 to Len(aCposSX1)
			FieldPut(FieldPos(ALLTRIM(aCposSX1[nJ])),aPergs[nx][nj])
		Next nj
		MsUnlock()
	Endif
Next

RestArea(aArea)

Return