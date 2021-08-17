#INCLUDE "rwmake.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³EFR001    º Autor ³ AP6 IDE            º Data ³  12/08/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Codigo gerado pelo AP6 IDE.                                º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP6 IDE                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function EFR001
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Local cDesc1       := "Este programa tem como objetivo imprimir relatorio "
Local cDesc2       := "de acordo com os parametros informados pelo usuario."
Local cDesc3       := ""
Local cPict        := ""
Local nLin         := 80
Local Cabec1       := "Prefixo Titulo  Parcela Tipo  Banco  Agencia  Conta        Cheque          Vencimento    Valor do Cheque         Valor Baixa      Status Atual"
Local Cabec2       := ""
Local imprime      := .T.
Local aOrd         := {}
Local aPergs       := {}  
Private Titulo     := "Relatorio de Cheques Recebidos"
Private cPerg      := ""
Private lEnd       := .F.
Private lAbortPrint:= .F.
Private CbTxt      := ""
Private limite     := 220
Private tamanho    := "G"
Private nomeprog   := "EFR001" // Coloque aqui o nome do programa para impressao no cabecalho
Private nTipo      := 18
Private aReturn    := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
Private nLastKey   := 0
Private cbtxt      := Space(10)
Private cbcont     := 00
Private CONTFL     := 01
Private m_pag      := 01
Private wnrel      := "EFR001" // Coloque aqui o nome do arquivo usado para impressao em disco
Private cString    := "SZ2"

aPergs:= {}
cPerg:= "EFR01A"

aAdd(aPergs,{'Data De  ?'     ,'Data De  ?'    , 'Data De  ?'    , 'mv_ch1','D', 8 , 0,	0,	'G',	'',	'mv_par01',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	''})
aAdd(aPergs,{'Data Ate ?'     ,'Data Ate ?'    , 'Data Ate ?'    , 'mv_ch2','D', 8 , 0,	0,	'G',	'',	'mv_par02',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	''})
aAdd(aPergs,{'Armazenados?'   ,'Armazenados'   , 'Armazenados'   , 'mv_ch3','N', 1 , 0,	1,	'C',	'',	'mv_par03',	'Sim',	'Si','Yes',	'',		'',	'Nao',	'No',	'No',	'',	'',	'Ambos','Ambos','Ambos',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',''})
aAdd(aPergs,{'Recebido Em?'   ,'Recebido Em?'  , 'Recebido Em?'  , 'mv_ch4','N', 1 , 0,	1,	'C',	'',	'mv_par04',	'Paraiso',	'Paraiso',	'Paraiso',	'',		'',	'Guarulhos',	'Guarulhos',	'Guarulhos',	'',	'',	'Ambos',	'Ambos',	'Ambos',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',''})
aAdd(aPergs,{'Prefixo De?'    ,'Prefixo De?'   , 'Prefixo De?'   , 'mv_ch5','C', 3 , 0,	0,	'G',	'',	'mv_par05',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',''})
aAdd(aPergs,{'Prefixo Ate?'   ,'Prefixo Ate?'  , 'Prefixo Ate?'  , 'mv_ch6','C', 3 , 0,	0,	'G',	'',	'mv_par06',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',''})
aAdd(aPergs,{'Titulo De?'     ,'Titulo De?'    , 'Titulo De?'    , 'mv_ch7','C', 9 , 0,	0,	'G',	'',	'mv_par07',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',''})
aAdd(aPergs,{'Titulo Ate?'    ,'Titulo Ate?'   , 'Titulo Ate?'   , 'mv_ch8','C', 9 , 0,	0,	'G',	'',	'mv_par08',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',''})
aAdd(aPergs,{'Parcela De?'    ,'Parcela De?'   , 'Parcela De?'   , 'mv_ch9','C', 1 , 0,	0,	'G',	'',	'mv_par09',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',''})
aAdd(aPergs,{'Parcela Ate?'   ,'Parcela Ate?'  , 'Parcela Ate?'  , 'mv_cha','C', 1 , 0,	0,	'G',	'',	'mv_par10',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',''})
aAdd(aPergs,{'Tipo De?'       ,'Tipo De?'      , 'Tipo De?'      , 'mv_chb','C', 3 , 0,	0,	'G',	'',	'mv_par11',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',''})
aAdd(aPergs,{'Tipo Ate?'      ,'Tipo Ate?'     , 'Tipo Ate?'     , 'mv_chc','C', 3 , 0,	0,	'G',	'',	'mv_par12',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',''})

A001SX1(cPerg,aPergs)
Pergunte(cPerg,.F.)

Titulo     := "Relatorio de Cheques Recebidos"
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
Local cStatus  := ""
Local cTitulo  := ""
Local cCheque  := ""
Local nOrdem
Local dData
Local nSubChq  := 0
Local nSubBx   := 0
Local nTotalChq:= 0                
Local nTotalBx := 0                
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
				

Do Case
	Case (Mv_Par04 == 1)
		cStatus:= "A"
		
	Case (Mv_Par04 == 2)
		cStatus:= "B"

	Case (Mv_Par04 == 3)
		cStatus:= "A','B"
EndCase


cQuery := "	SELECT DISTINCT SZ2.Z2_BANCO,SZ2.Z2_AGENCIA,SZ2.Z2_CONTA,SZ2.Z2_CHEQUE,SZ2.Z2_DATA,SZ2.R_E_C_N_O_ "
cQuery += " FROM " + RetSqlName("SZ2") + " SZ2 "
cQuery += " WHERE SZ2.D_E_L_E_T_ <> '*' "
cQuery += " AND SZ2.Z2_STATUS IN ('" + cStatus + "') "
cQuery += " AND SZ2.Z2_OBSERVA = '' "
cQuery += " AND SZ2.Z2_DATA BETWEEN '" + Dtos(Mv_Par01) + "' AND '" + Dtos(Mv_Par02) + "' "
cQuery += " AND SZ2.Z2_FILIAL = '" + xFilial("SZ2") + "' "

If !Empty(Mv_Par05+Mv_Par07+Mv_Par09+Mv_Par11)
	cQuery += " AND SZ2.Z2_BANCO+SZ2.Z2_AGENCIA+SZ2.Z2_CONTA+SZ2.Z2_CHEQUE IN "
	cQuery += " 		( SELECT DISTINCT SZ3.Z3_BANCO+SZ3.Z3_AGENCIA+SZ3.Z3_CONTA+SZ3.Z3_CHEQUE FROM " + RetSqlName("SZ3") + " SZ3 "
	cQuery += " 		  WHERE SZ3.D_E_L_E_T_ <> '*' "
	cQuery += " 		  AND SZ3.Z3_PREFIXO BETWEEN '" + Mv_Par05 + "' AND '" + Mv_Par06 + "'"
	cQuery += " 		  AND SZ3.Z3_NUM     BETWEEN '" + Mv_Par07 + "' AND '" + Mv_Par08 + "'"
	cQuery += " 		  AND SZ3.Z3_PARCELA BETWEEN '" + Mv_Par09 + "' AND '" + Mv_Par10 + "'"
	cQuery += " 		  AND SZ3.Z3_TIPO    BETWEEN '" + Mv_Par11 + "' AND '" + Mv_Par12 + "')"
EndIf

cQuery += " ORDER BY SZ2.R_E_C_N_O_"
//cQuery += " ORDER BY SZ2.Z2_DATA,SZ2.Z2_BANCO,SZ2.Z2_AGENCIA,SZ2.Z2_CONTA,SZ2.Z2_CHEQUE"

/*
cQuery := "	SELECT * FROM " + RetSqlName("SZ3") + " SZ3 INNER JOIN " + RetSqlName("SZ2") + " SZ2 "
cQuery += " ON SZ3.Z3_FILIAL+SZ3.Z3_BANCO+SZ3.Z3_AGENCIA+SZ3.Z3_CONTA+SZ3.Z3_CHEQUE = SZ2.Z2_FILIAL+SZ2.Z2_BANCO+SZ2.Z2_AGENCIA+SZ2.Z2_CONTA+SZ2.Z2_CHEQUE "
cQuery += " WHERE SZ3.D_E_L_E_T_ <> '*' "
cQuery += " AND SZ2.D_E_L_E_T_ <> '*' "
cQuery += " AND SZ3.Z3_FILIAL = '" + xFilial("SZ3") + "' "
cQuery += " AND SZ2.Z2_FILIAL = '" + xFilial("SZ2") + "' "
cQuery += " AND SZ3.Z3_PREFIXO BETWEEN '" + Mv_Par05 + "' AND '" + Mv_Par06 + "' "
cQuery += " AND SZ3.Z3_NUM     BETWEEN '" + Mv_Par07 + "' AND '" + Mv_Par08 + "' "
cQuery += " AND SZ3.Z3_PARCELA BETWEEN '" + Mv_Par09 + "' AND '" + Mv_Par10 + "' "
cQuery += " AND SZ3.Z3_TIPO    BETWEEN '" + Mv_Par11 + "' AND '" + Mv_Par12 + "' "
cQuery += " AND SZ2.Z2_STATUS IN ('" + cStatus + "') "
cQuery += " AND SZ2.Z2_OBSERVA = '' "
cQuery += " AND SZ2.Z2_DATA BETWEEN '" + Dtos(Mv_Par01) + "' AND '" + Dtos(Mv_Par02) + "' "
cQuery += " ORDER BY SZ2.Z2_DATA,SZ3.Z3_PREFIXO,SZ3.Z3_NUM,SZ3.Z3_PARCELA,SZ3.Z3_TIPO,SZ2.Z2_BANCO,SZ2.Z2_AGENCIA,SZ2.Z2_CONTA,SZ2.Z2_CHEQUE "
*/
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
	If ((Mv_Par03 == 1) .And. (SZ1->Z1_STATUS < "C")) .Or.;
	   ((Mv_Par03 == 2) .And. (SZ1->Z1_STATUS >= "C")) 
		dbSelectArea(cAliasQry)
		dbSkip()
		Loop
	EndIf

	dbSelectArea("SZ3")
	dbSetOrder(1)
	If dbSeek(xFilial("SZ3")+(cAliasQry)->(Z2_BANCO+Z2_AGENCIA+Z2_CONTA+Z2_CHEQUE),.T.)
		While !Eof() .And. (xFilial("SZ3")+(cAliasQry)->(Z2_BANCO+Z2_AGENCIA+Z2_CONTA+Z2_CHEQUE) == SZ3->(Z3_FILIAL+Z3_BANCO+Z3_AGENCIA+Z3_CONTA+Z3_CHEQUE))
	
			nPos:= aScan(aCheques,{|x| x[1]+x[2]+x[3]+x[4] == (cAliasQry)->(Z2_BANCO+Z2_AGENCIA+Z2_CONTA+Z2_CHEQUE)})
			If (nPos == 0)
				aAdd(aCheques,{(cAliasQry)->Z2_BANCO,(cAliasQry)->Z2_AGENCIA,(cAliasQry)->Z2_CONTA,(cAliasQry)->Z2_CHEQUE,(cAliasQry)->Z2_DATA,SZ3->Z3_PREFIXO,SZ3->Z3_NUM,SZ3->Z3_PARCELA,SZ3->Z3_TIPO,SZ3->Z3_VALOR,SZ1->Z1_VENCTO,SZ1->Z1_VALOR})
			Else
				aAdd(aCheques,{(cAliasQry)->Z2_BANCO,(cAliasQry)->Z2_AGENCIA,(cAliasQry)->Z2_CONTA,(cAliasQry)->Z2_CHEQUE,(cAliasQry)->Z2_DATA,SZ3->Z3_PREFIXO,SZ3->Z3_NUM,SZ3->Z3_PARCELA,SZ3->Z3_TIPO,SZ3->Z3_VALOR,SZ1->Z1_VENCTO,0})
			EndIf
			
			dbSelectArea("SZ3")
			dbSkip()
		End	

	Else	
		nPos:= aScan(aCheques,{|x| x[1]+x[2]+x[3]+x[4] == (cAliasQry)->(Z2_BANCO+Z2_AGENCIA+Z2_CONTA+Z2_CHEQUE)})
		If (nPos == 0)
			aAdd(aCheques,{(cAliasQry)->Z2_BANCO,(cAliasQry)->Z2_AGENCIA,(cAliasQry)->Z2_CONTA,(cAliasQry)->Z2_CHEQUE,(cAliasQry)->Z2_DATA," "," "," "," ",0,SZ1->Z1_VENCTO,SZ1->Z1_VALOR})
		Else
			aAdd(aCheques,{(cAliasQry)->Z2_BANCO,(cAliasQry)->Z2_AGENCIA,(cAliasQry)->Z2_CONTA,(cAliasQry)->Z2_CHEQUE,(cAliasQry)->Z2_DATA," "," "," "," ",0,SZ1->Z1_VENCTO,0})
		EndIf
	EndIf		

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
		@nLin,88  PSAY GetMv("MV_SIMB1")+Transform(nSubChq,PesqPict("SZ1","Z1_VALOR"))
		@nLin,108 PSAY GetMv("MV_SIMB1")+Transform(nSubBx,PesqPict("SZ3","Z3_VALOR"))
		nTotalChq+= nSubChq
		nTotalBx += nSubBx
		nSubChq  := 0        
		nSubBx   := 0        

		dData:= aCheques[nI,5]
		nLin++

		@nLin,00 PSAY __PrtThinLine()
		nLin++
		
		@nLin,00 PSAY "Data: "+Dtoc(dData)
		nLin++
		
		@nLin,00 PSAY __PrtThinLine()
		nLin++
	EndIf
	
//	1         2          3       4        5        6        7       8          9      10         11       12
//Z2_BANCO,Z2_AGENCIA,Z2_CONTA,Z2_CHEQUE,Z2_DATA,Z3_PREFIXO,Z3_NUM,Z3_PARCELA,Z3_TIPO,Z3_VALOR,Z1_VENCTO,Z1_VALOR})

	@nLin,00  PSAY aCheques[nI,6] //Prefixo
	@nLin,08  PSAY aCheques[nI,7] //Numero
	@nLin,19  PSAY aCheques[nI,8] //Parcela - @nLin,16
	@nLin,24  PSAY aCheques[nI,9] //Tipo
	@nLin,30  PSAY aCheques[nI,1] //Banco
	@nLin,37  PSAY aCheques[nI,2] //Agencia
	@nLin,46  PSAY aCheques[nI,3] //Conta
	@nLin,60  PSAY aCheques[nI,4] //Cheque 
	@nLin,76  PSAY Dtoc(aCheques[nI,11]) //Data
	@nLin,90  PSAY Transform(aCheques[nI,12],PesqPict("SZ1","Z1_VALOR"))
	@nLin,110 PSAY Transform(aCheques[nI,10],PesqPict("SZ3","Z3_VALOR"))
	@nLin,130 PSAY aStatus[aScan(aStatus,{|x| x[1] == SZ1->Z1_STATUS}),2]

	nSubChq+= aCheques[nI,12]
	nSubBx += aCheques[nI,10]
	
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
	@nLin,88  PSAY GetMv("MV_SIMB1")+Transform(nSubChq,PesqPict("SZ1","Z1_VALOR"))
	@nLin,108 PSAY GetMv("MV_SIMB1")+Transform(nSubBx,PesqPict("SZ3","Z3_VALOR"))
	nTotalChq+= nSubChq
	nTotalBx += nSubBx
	nSubChq  := 0        
	nSubBx   := 0        

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
	@nLin,88  PSAY GetMv("MV_SIMB1")+Transform(nTotalChq,PesqPict("SZ1","Z1_VALOR"))
	@nLin,108 PSAY GetMv("MV_SIMB1")+Transform(nTotalBx,PesqPict("SZ3","Z3_VALOR"))
	
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

cPerg:= PadR(cPerg,10)

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