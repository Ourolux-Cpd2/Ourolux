#INCLUDE "rwmake.ch"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �EFR002    � Autor � AP6 IDE            � Data �  12/08/04   ���
�������������������������������������������������������������������������͹��
���Descricao � Codigo gerado pelo AP6 IDE.                                ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP6 IDE                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
User Function EFR002
Local cDesc1       := "Este programa tem como objetivo imprimir relatorio "
Local cDesc2       := "de acordo com os parametros informados pelo usuario."
Local cDesc3       := ""
Local cPict        := ""
Local nLin         := 220
Local Cabec1       := "Prefixo  Numero  Parcela  Tipo     Vencimento        Valor Titulo           Acrescimo          Decrescimo        Valor Baixa"
Local Cabec2       := "Banco    Agencia Conta             Cheque                                                                        Valor Cheque"
Local Titulo       := "Relatorio de Cheques Repassados"
Local imprime      := .T.
Local aOrd         := {}
Local aPergs       := {}  
Private cPerg      := ""
Private lEnd       := .F.
Private lAbortPrint:= .F.
Private CbTxt      := ""
Private limite     := 132
Private tamanho    := "G"
Private nomeprog   := "EFR002" // Coloque aqui o nome do programa para impressao no cabecalho
Private nTipo      := 18
Private aReturn    := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
Private nLastKey   := 0
Private cbtxt      := Space(10)
Private cbcont     := 00
Private CONTFL     := 01
Private m_pag      := 01
Private wnrel      := "EFR002" // Coloque aqui o nome do arquivo usado para impressao em disco
Private cString    := "SZ2"

aPergs:= {}
cPerg := "EFR002"
aAdd(aPergs,{'Data De  ?'        ,'Data De  ?'        , 'Data De  ?'        , 'mv_ch1','D', 8 , 0,	0,	'G',	'',	'mv_par01',	'',	'',	'',	'',		'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	''})
aAdd(aPergs,{'Data Ate ?'        ,'Data Ate ?'        , 'Data Ate ?'        , 'mv_ch2','D', 8 , 0,	0,	'G',	'',	'mv_par02',	'',	'',	'',	'',		'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	''})
aAdd(aPergs,{'Fornecedor De ?'   ,'Fornecedor De  ?'  , 'Fornecedor De  ?'  , 'mv_ch3','C', 6 , 0,	0,	'G',	'',	'mv_par03','','','',	'',		'',	'',	'',	'',	'',	'SA2',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	''})
aAdd(aPergs,{'Fornecedor Ate ?'  ,'Fornecedor Ate  ?' , 'Fornecedor Ate  ?' , 'mv_ch4','C', 6 , 0,	0,	'G',	'',	'mv_par04','','','',	'',		'',	'',	'',	'',	'',	'SA2',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	''})
aAdd(aPergs,{'Loja De ?'         ,'Loja De  ?'        , 'Loja De  ?'        , 'mv_ch5','C', 2 , 0,	0,	'G',	'',	'mv_par05','','','',	'',		'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	''})
aAdd(aPergs,{'Loja Ate ?'        ,'Loja Ate  ?'       , 'Loja Ate  ?'       , 'mv_ch6','C', 2 , 0,	0,	'G',	'',	'mv_par06','','','',	'',		'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	''})
aAdd(aPergs,{'Documento De ?'    ,'Documento De ?'    , 'Documento De ?'    , 'mv_ch7','C', 12, 0,	0,	'G',	'',	'mv_par07','','','',	'',		'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	''})
aAdd(aPergs,{'Documento Ate?'    ,'Documento Ate?'    , 'Documento Ate?'    , 'mv_ch8','C', 12, 0,	0,	'G',	'',	'mv_par08','','','',	'',		'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	''})
aAdd(aPergs,{'Aglutina Repasses?','Aglutina Repasses?', 'Aglutina Repasses?', 'mv_ch9','N', 1 , 0,	1,	'C',	'',	'mv_par09',	'Sim',	'Si',	'Yes',	'',		'',	'Nao',	'No',	'No',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',	'',''})

A001SX1(cPerg,aPergs)
Pergunte(cPerg,.F.)

//���������������������������������������������������������������������Ŀ
//� Monta a interface padrao com o usuario...                           �
//�����������������������������������������������������������������������

wnrel := SetPrint(cString,NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,.T.,Tamanho,,.T.)

If nLastKey == 27
	Return
Endif

SetDefault(aReturn,cString)

If nLastKey == 27
	Return
Endif

nTipo := If(aReturn[4]==1,15,18)

//���������������������������������������������������������������������Ŀ
//� Processamento. RPTSTATUS monta janela com a regua de processamento. �
//�����������������������������������������������������������������������

RptStatus({|| RunReport(Cabec1,Cabec2,Titulo,nLin) },Titulo)
Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Fun��o    �RUNREPORT � Autor � AP6 IDE            � Data �  12/08/04   ���
�������������������������������������������������������������������������͹��
���Descri��o � Funcao auxiliar chamada pela RPTSTATUS. A funcao RPTSTATUS ���
���          � monta a janela com a regua de processamento.               ���
�������������������������������������������������������������������������͹��
���Uso       � Programa principal                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Static Function RunReport(Cabec1,Cabec2,Titulo,nLin)
Local dData      := 0
Local nTotTit    := 0
Local nTotChq    := 0
Local nI         := 0
Local nValBx     := 0
Local cTitulo    := ""
Local cFornece   := ""
Local cQuery     := ""
Local cRepasse   := "" 
Local aCheque    := {}                
Private cAliasQry:= ""

cQuery := "	SELECT * "
cQuery += " FROM " + RetSqlName("SZ4")
cQuery += " WHERE D_E_L_E_T_ <> '*' "
cQuery += " AND Z4_FILIAL = '" + xFilial("SZ4") + "'"
cQuery += " AND Z4_BAIXA BETWEEN '" + Dtos(Mv_Par01) + "' AND '" + Dtos(Mv_Par02) + "' "
cQuery += " AND Z4_FORNECE+Z4_LOJA BETWEEN '" + Mv_Par03 + Mv_Par05 + "' AND '" + Mv_Par04 + Mv_Par06 + "' "
cQuery += " AND Z4_REPASSE BETWEEN '" + Mv_Par07 + "' AND '" + Mv_Par08 + "' "
//cQuery += " AND Z4_BAIXA <> '' "
cQuery += " ORDER BY Z4_FORNECE,Z4_LOJA,Z4_BAIXA,Z4_REPASSE,Z4_ITEM,Z4_PREFIXO,Z4_NUM,Z4_PARCELA,Z4_TIPO"
cQuery := ChangeQuery( cQuery )

cAliasQry := CriaTrab(,.F.)
DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAliasQry, .F., .T.)

aStruct := SZ4->(dbStruct())
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

cTitulo := (cAliasQry)->(Z4_PREFIXO+Z4_NUM+Z4_PARCELA+Z4_TIPO)
cFornece:= (cAliasQry)->(Z4_FORNECE+Z4_LOJA)
dData   := (cAliasQry)->Z4_BAIXA
cRepasse:= (cAliasQry)->Z4_REPASSE

While !(cAliasQry)->(Eof())

	//���������������������������������������������������������������������Ŀ
	//� Verifica o cancelamento pelo usuario...                             �
	//�����������������������������������������������������������������������
	If lAbortPrint
		@nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
		Exit
	EndIf

	//���������������������������������������������������������������������Ŀ
	//� Impressao do cabecalho do relatorio. . .                            �
	//�����������������������������������������������������������������������
	
	If nLin > 60 // Salto de P�gina. Neste caso o formulario tem 55 linhas...
		R002Cabec(@nLin,Titulo,Cabec1,Cabec2,@cFornece,@dData,cRepasse)
	Endif

	If (dData <> (cAliasQry)->Z4_BAIXA) .Or.;
       (Left(cFornece,6) <> (cAliasQry)->Z4_FORNECE) .Or.;
	   (cRepasse <> (cAliasQry)->Z4_REPASSE .And. Mv_Par09 == 2)
		SE2->(dbSetOrder(1))
		SE2->(dbSeek(xFilial("SE2")+cTitulo+cFornece))
		

		@nLin,00 PSAY SE2->E2_PREFIXO
		@nLin,09 PSAY SE2->E2_NUM
		@nLin,20 PSAY SE2->E2_PARCELA
		@nLin,26 PSAY SE2->E2_TIPO
		@nLin,35 PSAY Dtoc(dData)
		@nLin,50 PSAY Transform(SE2->E2_VALOR  ,PesqPict("SE2","E2_VALOR"))
		@nLin,70 PSAY Transform(SE2->E2_ACRESC ,PesqPict("SE2","E2_ACRESC"))
		@nLin,90 PSAY Transform(SE2->E2_DECRESC,PesqPict("SE2","E2_DECRESC"))
		@nLin,110 PSAY Transform(nValBx+SE2->(E2_ACRESC-E2_DECRESC),PesqPict("SZ4","Z4_VALOR"))
		
		If (Mv_Par09 == 1) 
			@nLin,130 PSAY cRepasse
		EndIf
		
		nLin++// Avanca a linha de impressao

		cTitulo:= (cAliasQry)->(Z4_PREFIXO+Z4_NUM+Z4_PARCELA+Z4_TIPO)
		nTotTit+= nValBx
		nValBx := (cAliasQry)->Z4_VALOR	
	
		@nLin,00 PSAY "Total de Titulos Pagos: "
		@nLin,107 PSAY GetMv("MV_SIMB1") + " "+ Transform(nTotTit,PesqPict("SZ1","Z1_VALOR"))
		nLin+= 2

		@nLin,00 PSAY "Cheques Repassados"
		nLin++
		For nI:= 1 To Len(aCheque)

			If nLin > 60 // Salto de P�gina. Neste caso o formulario tem 55 linhas...
				R002Cabec(@nLin,Titulo,Cabec1,Cabec2,@cFornece,@dData,cRepasse)
			Endif

			@nLin,00 PSAY aCheque[nI,1]
			@nLin,09 PSAY aCheque[nI,2]
			@nLin,17 PSAY aCheque[nI,3]
			@nLin,35 PSAY aCheque[nI,4]
			@nLin,110 PSAY Transform(aCheque[nI,5],PesqPict("SZ1","Z1_VALOR"))
			nLin++
			nTotChq+= aCheque[nI,5]
			
		Next nI     

		nLin++

		@nLin,00 PSAY "Total de Cheques Repassados: "
		@nLin,107 PSAY GetMv("MV_SIMB1") + " "+ Transform(nTotChq,PesqPict("SZ1","Z1_VALOR"))

		nTotTit:= 0
        nTotChq:= 0
		nLin+= 5
		@nLin,00 PSAY "Data Emissao: "+Dtoc(dDatabase)

		nLin+= 2
		@nLin,00 PSAY "Emitido Por : ______________________________________"
		
		nLin+= 2
		@nLin,00 PSAY "Recebido Por: ______________________________________"

		aCheque := {}
		cFornece:= (cAliasQry)->(Z4_FORNECE+Z4_LOJA)
		dData   := (cAliasQry)->Z4_BAIXA
		cRepasse:= (cAliasQry)->Z4_REPASSE
		
		R002Cabec(@nLin,Titulo,Cabec1,Cabec2,@cFornece,@dData,cRepasse)
		
	Else
		If (cTitulo <> (cAliasQry)->(Z4_PREFIXO+Z4_NUM+Z4_PARCELA+Z4_TIPO))
			SE2->(dbSetOrder(1))
			SE2->(dbSeek(xFilial("SE2")+cTitulo+cFornece))
			
			@nLin,00 PSAY SE2->E2_PREFIXO
			@nLin,09 PSAY SE2->E2_NUM
			@nLin,17 PSAY SE2->E2_PARCELA
			@nLin,26 PSAY SE2->E2_TIPO
			@nLin,35 PSAY Dtoc(dData)
			@nLin,50 PSAY Transform(SE2->E2_VALOR  ,PesqPict("SE2","E2_VALOR"))
			@nLin,70 PSAY Transform(SE2->E2_ACRESC ,PesqPict("SE2","E2_ACRESC"))
			@nLin,90 PSAY Transform(SE2->E2_DECRESC,PesqPict("SE2","E2_DECRESC"))
			@nLin,110 PSAY Transform(nValBx+SE2->(E2_ACRESC-E2_DECRESC),PesqPict("SZ4","Z4_VALOR"))
	
			If (Mv_Par09 == 1) 
				@nLin,130 PSAY cRepasse
			EndIf
			nLin++// Avanca a linha de impressao

			nTotTit += nValBx

			cTitulo := (cAliasQry)->(Z4_PREFIXO+Z4_NUM+Z4_PARCELA+Z4_TIPO)
			cFornece:= (cAliasQry)->(Z4_FORNECE+Z4_LOJA)
			nValBx  := (cAliasQry)->Z4_VALOR	
			cRepasse:= (cAliasQry)->Z4_REPASSE
		Else
			nValBx  += (cAliasQry)->Z4_VALOR	
			cRepasse:= (cAliasQry)->Z4_REPASSE
		EndIf
	EndIf
		

	dbSelectArea("SZ1")
	dbSetOrder(1)
	dbSeek(xFilial("SZ1")+(cAliasQry)->(Z4_BANCO+Z4_AGENCIA+Z4_CONTA+Z4_CHEQUE),.T.)

	nI:= aScan(aCheque,{|x| x[1]+x[2]+x[3]+x[4] == (cAliasQry)->(Z4_BANCO+Z4_AGENCIA+Z4_CONTA+Z4_CHEQUE)})
	If (nI == 0)
		aAdd(aCheque,{SZ1->Z1_BANCO,SZ1->Z1_AGENCIA,SZ1->Z1_CONTA,SZ1->Z1_CHEQUE,SZ1->Z1_VALOR})
	EndIf

	dbSelectArea(cAliasQry)
	dbSkip() // Avanca o ponteiro do registro no arquivo
EndDo

//If (nValBx > 0)
	SE2->(dbSetOrder(1))
	SE2->(dbSeek(xFilial("SE2")+cTitulo+cFornece))
	
	@nLin,00 PSAY SE2->E2_PREFIXO
	@nLin,09 PSAY SE2->E2_NUM
	@nLin,17 PSAY SE2->E2_PARCELA
	@nLin,26 PSAY SE2->E2_TIPO
	@nLin,35 PSAY Dtoc(dData)
	@nLin,50 PSAY Transform(SE2->E2_VALOR  ,PesqPict("SE2","E2_VALOR"))
	@nLin,70 PSAY Transform(SE2->E2_ACRESC ,PesqPict("SE2","E2_ACRESC"))
	@nLin,90 PSAY Transform(SE2->E2_DECRESC,PesqPict("SE2","E2_DECRESC"))
	@nLin,110 PSAY Transform(nValBx+SE2->(E2_ACRESC-E2_DECRESC),PesqPict("SZ4","Z4_VALOR"))

	If (Mv_Par09 == 1) 
		@nLin,130 PSAY cRepasse
	EndIf
	nLin++// Avanca a linha de impressao

	cTitulo:= (cAliasQry)->(Z4_PREFIXO+Z4_NUM+Z4_PARCELA+Z4_TIPO)
	nTotTit+= nValBx+SE2->(E2_ACRESC-E2_DECRESC)

	@nLin,00 PSAY "Total de Titulos Pagos: "
	@nLin,107 PSAY GetMv("MV_SIMB1") + " "+ Transform(nTotTit,PesqPict("SZ1","Z1_VALOR"))
	nLin+= 2

	@nLin,00 PSAY "Cheques Repassados"
	nLin++
	For nI:= 1 To Len(aCheque)
		If nLin > 60 // Salto de P�gina. Neste caso o formulario tem 55 linhas...
			R002Cabec(@nLin,Titulo,Cabec1,Cabec2,@cFornece,@dData,cRepasse)
	
			lPrint:= .T.
		Endif

		@nLin,00 PSAY aCheque[nI,1]
		@nLin,09 PSAY aCheque[nI,2]
		@nLin,17 PSAY aCheque[nI,3]
		@nLin,35 PSAY aCheque[nI,4]
		@nLin,110 PSAY Transform(aCheque[nI,5],PesqPict("SZ1","Z1_VALOR"))
		nLin++

		nTotChq+= aCheque[nI,5]
				
	Next nI     
	
	nLin++

	@nLin,00 PSAY "Total de Cheques Repassados: "
	@nLin,107 PSAY GetMv("MV_SIMB1") + " "+ Transform(nTotChq,PesqPict("SZ1","Z1_VALOR"))

	nTotTit:= 0
    nTotChq:= 0

	nLin+= 5
	@nLin,00 PSAY "Data Emissao: "+Dtoc(dDatabase)

	nLin+= 2
	@nLin,00 PSAY "Emitido Por : ______________________________________"
	
	nLin+= 2
	@nLin,00 PSAY "Recebido Por: ______________________________________"

	//���������������������������������������������������������������������Ŀ
	//� Finaliza a execucao do relatorio...                                 �
	//�����������������������������������������������������������������������
	Roda()
//EndIf
	
dbCloseArea(cAliasQry)

SET DEVICE TO SCREEN

//���������������������������������������������������������������������Ŀ
//� Se impressao em disco, chama o gerenciador de impressao...          �
//�����������������������������������������������������������������������

If aReturn[5]==1
	dbCommitAll()
	SET PRINTER TO
	OurSpool(wnrel)
Endif

MS_FLUSH()

Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������Ŀ��
���Fun��o    � A001SX1      � Autor � Fabio Rogerio Pereira � Data � 04/05/01 ���                                                     ��
�����������������������������������������������������������������������������Ĵ��
���Descri��o � Verifica as perguntas inclu�ndo-as caso n�o existam            ���                                                            ��
������������������������������������������������������������������������������ٱ�
���������������������������������������������������������������������������������
����������������������������������������������������������������������������������
/*/
Static Function A001SX1(cPerg,aPergs)
Local aArea 	:= GetArea()
Local aCposSX1	:= {}
Local nX := 0

aCposSX1:={"X1_PERGUNT","X1_PERSPA","X1_PERENG","X1_VARIAVL","X1_TIPO","X1_TAMANHO","X1_DECIMAL",;
"X1_PRESEL","X1_GSC","X1_VALID","X1_VAR01","X1_DEF01","X1_DEFSPA1","X1_DEFENG1",;
"X1_CNT01","X1_VAR02","X1_DEF02","X1_DEFSPA2","X1_DEFENG2","X1_CNT02","X1_F3" }

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


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �R002Cabec �Autor  �Symm Consultoria    � Data �  12/03/04   ���
�������������������������������������������������������������������������͹��
���Desc.     �Cabecalho do Relatorio                                      ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function R002Cabec(nLin,Titulo,Cabec1,Cabec2,cFornece,dData,cRepasse)

Cabec(Titulo,Cabec1+IIf(Mv_Par09 == 1,Space(9)+"Documento",""),Cabec2,NomeProg,Tamanho,nTipo)
nLin := 8

@nLin,00 PSAY __PrtThinLine()
nLin++

//cFornece:= (cAliasQry)->(Z4_FORNECE+Z4_LOJA)
dData   := (cAliasQry)->Z4_BAIXA

If (Mv_Par09 == 2)
	@nLin,00 PSAY "Documento : "+cRepasse
	nLin++
EndIf                 

@nLin,00 PSAY "Fornecedor: "+cFornece+" - "+Posicione("SA2",1,xFilial("SA2")+cFornece,"A2_NOME")
nLin++

@nLin,00 PSAY "Data      : "+Dtoc(dData)
nLin++

@nLin,00 PSAY __PrtThinLine()
nLin++

@nLin,00 PSAY "Titulos Pagos"
nLin++

Return