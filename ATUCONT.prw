#include "rwmake.ch"

/*
Funcao		: ATUCONT()
Autor		: Gilson Belini
Data Desenv.: 24/04/2017
Descricao	: Chama a rotina de inclusão de Clientes na AC8
: Chama a rotina de inclusão de Contatos na SU5 com base na pesquisa da SA1 x AC8
Uso			: Específico Ourolux
*/

User Function ATUCONT()

If MsgBox("Processa criação das Entidades com base no Cadastro de Clientes?","Atualiza AC8","YESNO")
	Processa({|| AtuaEnt() }, "Criando SA1 na AC8")
Endif

If MsgBox("Processa criação dos Contatos com base no Cadastro de Clientes x Entidades?","Atualiza SU5","YESNO")
	Processa({|| AtuaCont() }, "Criando SU5 na AC8xSA1")
Endif

Return()

//************************************************************************
/*
Funcao		: ATUAENT()
Autor		: Gilson Belini
Data Desenv.: 24/04/2017
Descricao	: Incluir Clientes na AC8 quando não houver o mesmo com base na data da última compra limitando em 01/01/2015.
Uso			: Específico Ourolux
*/

Static Function AtuaEnt()

Local aAreaSA1		:= SA1->(GetArea())
Local aAreaAC8		:= AC8->(GetArea())
Local aAreaSU5		:= SU5->(GetArea())
Local aArea     	:= GetArea()
Local _lAchou		:= .F.
Local _nQtdAC8  	:= 0
Local _nQtdSA1  	:= 0
//Local _dDtUCom		:= '01/01/2016'

Private _aLogSA1	:= {}
Private _cQuery		:= ""
Private _cPerg		:= ""

_cPerg := "ATUCONT01"

ValidPerg(_cPerg)
If !Pergunte(_cPerg,.T.)
	Return
Endif

_cQuery := ""
_cQuery += " SELECT * FROM "+RetSqlName("SA1")+" SA1"
_cQuery += " WHERE NOT EXISTS"
_cQuery += " (SELECT * FROM "+RetSqlName("AC8")+" AC8"
_cQuery += " WHERE SA1.A1_COD+SA1.A1_LOJA = SUBSTRING(AC8.AC8_CODENT,1,8))"
_cQuery += " AND SA1.A1_ULTCOM >= '"+DtoS(MV_PAR01)+"'"
_cQuery += " ORDER BY SA1.A1_COD+SA1.A1_LOJA
_cQuery := ChangeQuery(_cQuery)

If !Empty(Select("TRB"))
	dbSelectArea("TRB")
	dbCloseArea()
Endif

DbUseArea(.T., "TOPCONN", TCGENQRY(,,_cQuery), 'TRB', .F., .T.)
//TcSetField("TRB","D2_QUANT" ,"N",12,5)
//TcSetField("TRB","D2_QTSEGUM" ,"N",12,5)

If Empty(Select("TRB"))
	MsgStop('Não há registros de Clientes para o parâmetro selecionado')
Endif

DbSelectArea("TRB")
DbGoTop()

ProcRegua(RecCount())

While !eof()
	
	IncProc("Criando Clientes Filtrados...")
	
	DbSelectArea("AC8")
	DbSetOrder(2)
	DbSeek(xFilial("AC8")+"SA1"+SPACE(02)+TRB->A1_COD+TRB->A1_LOJA+SPACE(17), .T.)
	While TRB->A1_COD+TRB->A1_LOJA == AllTrim(AC8->AC8_CODENT)
		_nQtdAC8 += 1
		_lAchou := .T.
		DbselectArea("AC8")
		DbSkip()
	End
	If !_lAchou
		_nQtdSA1 += 1
		RecLock("AC8",.T.)
		//		AC8->AC8_FILENT	:= "  "
		AC8->AC8_ENTIDA	:= "SA1"
		AC8->AC8_CODENT	:= TRB->A1_COD+TRB->A1_LOJA+SPACE(17)
		//		AC8->AC8_CODCON	:= ""
		AC8->(MsUnlock())
		aAdd(_aLogSA1,{TRB->A1_COD,;
		TRB->A1_LOJA,;
		TRB->A1_CGC,;
		TRB->A1_NOME})
	Endif
	_lAchou := .F.
	DbSelectArea("TRB")
	DbSkip()
End

If MsgBox("Gera Log dos Clientes Atualizados na AC8?","Geração de Log de Atualização de Clientes","YESNO")
	Processa({|| GerLogSA1()})
Endif

// Função que gera o Log dos clientes criados em TXT.
Static Function GerLogSA1()

Local cDir      := cGetFile('Arquivo TXT|*.txt','Todos os Drives',0,'C:\Dir\',.F.,GETF_LOCALFLOPPY+GETF_LOCALHARD+GETF_NETWORKDRIVE+GETF_RETDIRECTORY,.T.)
Local nHandle 	:= 0
Local _cBuffers	:= ""
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³FCreate - É o comando responsavel pela criação do arquivo.                                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
if File(AllTrim(cDir+".txt"))
	fErase(AllTrim(cDir+".txt"))
endif
nHandle := FCreate(cDir+".txt")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³nHandle - A função FCreate retorna o handle, que indica se foi possível ou não criar o arquivo. Se o valor for     ³
//³menor que zero, não foi possível criar o arquivo.                                                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nHandle < 0
	MsgAlert("Erro durante criação do arquivo.")
Else
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³FWrite - Comando reponsavel pela gravação do texto.                                                                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	_cBuffers := "CODIGO"+chr(124)+"LJ"+chr(124)+"CNPJ"+Space(10)+chr(124)+"RAZAO_SOCIAL"+Space(28)+chr(124)+CHR(13)+CHR(10)
	For _nI := 1 to Len(_aLogSA1)
		_cBuffers += _aLogSA1[_nI][1]+chr(124)+_aLogSA1[_nI][2]+chr(124)+_aLogSA1[_nI][3]+chr(124)+_aLogSA1[_nI][4]+chr(124)+CHR(13)+CHR(10)
	Next _nI
	FWrite(nHandle,_cBuffers)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³FClose - Comando que fecha o arquivo, liberando o uso para outros programas.                                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	FClose(nHandle)
EndIf

ApMsgInfo("Log Gravado com Sucesso !!!")

Return

DbCloseArea("SA1")
DbCloseArea("AC8")

RestArea(aAreaSA1)
RestArea(aAreaAC8)
RestArea(aAreaSU5)
RestArea(aArea)

Return()

//************************************************************************
/*
Funcao		: ATUACONT()
Autor		: Gilson Belini
Data Desenv.: 24/04/2017
Descricao	: Incluir Contatos na SU5 quando não houver o mesmo com base na amarração Clientes x Entidade.
Uso			: Específico Ourolux
*/

Static Function AtuaCont()

Local aAreaSA1	:= SA1->(GetArea())
Local aAreaAC8	:= AC8->(GetArea())
Local aAreaSU5	:= SU5->(GetArea())
Local aArea     := GetArea()
Local _nQtdSU5  := 0
//Local _dDtUCom	:= '01/01/2016'
Local _lExit	:= .F.
Local nIdx		:= 0

Private _aLogSU5	:= {}
Private _aArea	:= Getarea()
Private _cPerg		:= ""

/*
_cPerg := "ATUCONT01"

ValidPerg(_cPerg)
If !Pergunte(_cPerg,.T.)
Return
Endif
*/

_cQuery := ""
_cQuery += " SELECT * FROM "+RetSqlName("SA1")+" SA1"
_cQuery += " WHERE EXISTS"
_cQuery += " (SELECT * FROM "+RetSqlName("AC8")+" AC8"
//_cQuery += " WHERE SA1.A1_COD+SA1.A1_LOJA = SUBSTRING(AC8.AC8_CODENT,1,8) AND AC8.AC8_ENTIDA = 'SA1' AND AC8.AC8_CODCON = ' ')"
_cQuery += " WHERE SA1.A1_COD+SA1.A1_LOJA = SUBSTRING(AC8.AC8_CODENT,1,8) AND AC8.AC8_ENTIDA = 'SA1')"
_cQuery += " ORDER BY SA1.A1_COD+SA1.A1_LOJA
_cQuery := ChangeQuery(_cQuery)

If !Empty(Select("TRC"))
	dbSelectArea("TRC")
	dbCloseArea()
Endif

DbUseArea(.T., "TOPCONN", TCGENQRY(,,_cQuery), 'TRC', .F., .T.)

If Empty(Select("TRC"))
	MsgStop('Não há registros de Clientes para o parâmetro selecionado')
Endif

DbSelectArea("TRC")
DbGoTop()

ProcRegua(RecCount())

While !eof()
	
	IncProc("Criando Contatos para SA1 x SU5...")
	
	DbSelectArea("AC8")
	DbSetOrder(2)
	DbSeek(xFilial("AC8")+"SA1"+SPACE(02)+TRC->A1_COD+TRC->A1_LOJA+SPACE(17), .T.)
	While TRC->A1_COD+TRC->A1_LOJA == AllTrim(AC8->AC8_CODENT)
		If !Empty(AC8->AC8_CODCON)
			DbSelectArea("SU5")
			DbsetOrder(1)
			//			DbSeek(xFilial("SU5")+AC8->AC8_CODCON+SPACE(220))
			DbSeek(xFilial("SU5")+AC8->AC8_CODCON,.T.)
			While !Eof() .and. SU5->U5_CODCONT == AC8->AC8_CODCON
				If SU5->U5_TIPO == "3" // Atendimento = Cobrança
					If Empty(SU5->U5_DDD)
						RecLock("SU5",.F.)
						SU5->U5_DDD	:= U_AjusDDD(Iif(Len(AllTrim(TRC->A1_TEL))>=11,SUBSTR(TRC->A1_TEL,1,3),TRC->A1_DDD))
						SU5->(MsUnlock())
					Endif
					If Empty(SU5->U5_FCOM1)
						RecLock("SU5",.F.)
						SU5->U5_FCOM1	:= U_AjusTel(TRC->A1_TEL)
						SU5->(MsUnlock())
					Endif
					_lExit := .T.
				Endif
				DbSelectArea("SU5")
				DbSkip()
			End
			If !_lExit // Atendimento = Cobrança
				_nQtdSU5 += 1
				// Atualiza SU5
				RecLock("SU5",.T.)
				SU5->U5_CODCONT	:= GETSX8NUM("SU5","U5_CODCONT")
				ConfirmSX8()
				//RollBackSX8()
				SU5->U5_CONTAT	:= SubStr(TRC->A1_NOME,1,30)
				SU5->U5_DDD		:= U_AjusDDD(Iif(Len(AllTrim(TRC->A1_TEL))>=11,SUBSTR(TRC->A1_TEL,1,3),TRC->A1_DDD))
				SU5->U5_FCOM1	:= U_AjusTel(TRC->A1_TEL)
				SU5->U5_ATIVO	:= "1"
				SU5->U5_STATUS	:= "2"
				SU5->U5_TIPO	:= "3"
				SU5->U5_CLIENTE	:= TRC->A1_COD
				SU5->U5_LOJA	:= TRC->A1_LOJA
				SU5->U5_URL		:= "Rotina ATUCONT"
				SU5->(MsUnlock())
				
				// Atualiza AC8
				If Empty(AC8->AC8_CODCON)
					RecLock("AC8",.F.)
					AC8->AC8_CODCON	:= SU5->U5_CODCONT
					AC8->(MsUnlock())
				Else
					RecLock("AC8",.T.)
					AC8->AC8_ENTIDA	:= "SA1"
					AC8->AC8_CODENT	:= TRC->A1_COD+TRC->A1_LOJA+SPACE(17)
					AC8->AC8_CODCON	:= SU5->U5_CODCONT
					AC8->(MsUnlock())
				Endif
				
				// Preencho Array do Log
				aAdd(_aLogSU5,{SU5->U5_CODCONT,;
				SU5->U5_CONTAT,;
				AllTrim(SU5->U5_DDD),;
				AllTrim(SU5->U5_FCOM1),;
				SU5->U5_CLIENTE,;
				SU5->U5_LOJA,;
				SU5->U5_ATIVO,;
				SU5->U5_STATUS,;
				SU5->U5_TIPO})
				_lExit := .F.
			Endif
		ElseIf Empty(AC8->AC8_CODCON)
			_nQtdSU5 += 1
			// Atualiza SU5
			//			DbSelectArea("SU5")
			RecLock("SU5",.T.)
			SU5->U5_CODCONT	:= GETSX8NUM("SU5","U5_CODCONT")
			ConfirmSX8()
			//RollBackSX8()
			SU5->U5_CONTAT	:= SubStr(TRC->A1_NOME,1,30)
			SU5->U5_DDD		:= U_AjusDDD(Iif(Len(AllTrim(TRC->A1_TEL))>=11,SUBSTR(TRC->A1_TEL,1,3),TRC->A1_DDD))
			SU5->U5_FCOM1	:= U_AjusTel(TRC->A1_TEL)
			SU5->U5_ATIVO	:= "1"
			SU5->U5_STATUS	:= "2"
			SU5->U5_TIPO	:= "3"
			SU5->U5_CLIENTE	:= TRC->A1_COD
			SU5->U5_LOJA	:= TRC->A1_LOJA
			SU5->U5_URL		:= "Rotina ATUCONT"
			SU5->(MsUnlock())
			
			// Atualiza AC8
			RecLock("AC8",.F.)
			AC8->AC8_CODCON	:= SU5->U5_CODCONT
			AC8->(MsUnlock())
			
			// Preencho Array do Log
			aAdd(_aLogSU5,{SU5->U5_CODCONT,;
			SU5->U5_CONTAT,;
			AllTrim(SU5->U5_DDD),;
			AllTrim(SU5->U5_FCOM1),;
			SU5->U5_CLIENTE,;
			SU5->U5_LOJA,;
			SU5->U5_ATIVO,;
			SU5->U5_STATUS,;
			SU5->U5_TIPO})
		Endif
		_lExit := .F.
		DbselectArea("AC8")
		DbSkip()
	End
	DbSelectArea("TRC")
	DbSkip()
End

If MsgBox("Gera Log dos Contatos Atualizados na SU5?","Geração de Log de Atualização de Contatos","YESNO")
	Processa({|| GerLogSU5()})
Endif

// Função que gera o Log dos Contatos criados em TXT.
Static Function GerLogSU5()

Local cDir      := cGetFile('Arquivo TXT|*.txt','Todos os Drives',0,'C:\Dir\',.F.,GETF_LOCALFLOPPY+GETF_LOCALHARD+GETF_NETWORKDRIVE+GETF_RETDIRECTORY,.T.)
Local nHandle 	:= 0
Local _cBuffers	:= ""
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³FCreate - É o comando responsavel pela criação do arquivo.                                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
if File(AllTrim(cDir+".txt"))
	fErase(AllTrim(cDir+".txt"))
endif
nHandle := FCreate(cDir+".txt")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³nHandle - A função FCreate retorna o handle, que indica se foi possível ou não criar o arquivo. Se o valor for     ³
//³menor que zero, não foi possível criar o arquivo.                                                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nHandle < 0
	MsgAlert("Erro durante criação do arquivo.")
Else
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³FWrite - Comando reponsavel pela gravação do texto.                                                                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	_cBuffers := "CODIGO"+chr(124)+"CONTATO"+Space(23)+chr(124)+"DDD"+chr(124)+"TELEFONE"+Space(01)+chr(124)+"CODCLI"+chr(124)+"LJ"+chr(124)+"ATIVO"+chr(124)+"STATUS"+chr(124)+"ATENDIMENTO"+chr(124)+CHR(13)+CHR(10)
	For _nI := 1 to Len(_aLogSU5)
		_cBuffers += _aLogSU5[_nI][1]+chr(124)+_aLogSU5[_nI][2]+chr(124)+_aLogSU5[_nI][3]+Space(01)+chr(124)+_aLogSU5[_nI][4]+chr(124)+_aLogSU5[_nI][5]+chr(124)+_aLogSU5[_nI][6]+chr(124)+_aLogSU5[_nI][7]+Space(04)+chr(124)+_aLogSU5[_nI][8]+Space(5)+chr(124)+_aLogSU5[_nI][09]+Space(10)+chr(124)+CHR(13)+CHR(10)
	Next _nI
	FWrite(nHandle,_cBuffers)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³FClose - Comando que fecha o arquivo, liberando o uso para outros programas.                                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	FClose(nHandle)
EndIf

ApMsgInfo("Log Gravado com Sucesso !!!")

Return

DbCloseArea("SA1")
DbCloseArea("AC8")
DbCloseArea("SU5")
DbCloseArea("TRC")

RestArea(aAreaSA1)
RestArea(aAreaAC8)
RestArea(aAreaSU5)
RestArea(aArea)

Return()

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ValidPerg º Autor ³ Gilson Belini      º Data ³  06/05/2017 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Cria as perguntas                                          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Ourolux - Atualiza Clientes x Contatos - Tab.: AC8         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function ValidPerg(_cPerg)

Local aRegs := {}
Local i,j

dbSelectArea("SX1")
dbSetOrder(1)
_cPerg := PADR(_cPerg,len(SX1->X1_GRUPO))

// Grupo/Ordem/Pergunta/Perg.Spa/Perg.Eng/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/DefSpa01/DefEng01/Cnt01/Var02/Def02/DefSpa02/DefEng02/Cnt02/Var03/Def03/DefSpa03/DefEng03/Cnt03/Var04/Def04/DefSpa04/DefEng04/Cnt04/Var05/Def05/DefSpa05/DefEng05/Cnt05/F3/PYME/GRPSXG/HELP/PICTURE/IDFIL
AADD(aRegs,{_cPerg,"01","Dt.Ultima Compra" ,"","","mv_ch1","D",08,0,0,"G","","MV_PAR01","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})

For i:=1 to Len(aRegs)
	If !dbSeek(_cPerg+aRegs[i,2])
		RecLock("SX1",.T.)
		For j:=1 to FCount()
			If j <= Len(aRegs[i])
				FieldPut(j,aRegs[i,j])
			Endif
		Next
		MsUnlock()
	Endif
Next

Return

/*
Programa	: AjusTel()
Autor		: Gilson Belini
Data		: 06/05/2017
Descricao	: Utilizada para Eliminar Caracteres Especiais
Uso			: Ourolux - Atualiza informacoes do campo telefone da SA1
*/

User Function AjusTel()

Local cString := TRC->A1_TEL
Local cNewTel := ""

cNewTel := StrTran( cString, "-", "" )

If Len(Alltrim(cNewTel)) == 10
	cNewTel := Substr(cNewTel,3,8)
Elseif Len(AllTrim(cNewTel)) == 11
	cNewTel := Substr(cNewTel,4,8)
Endif

return (cNewTel)

/*
Programa	: AjusDDD()
Autor		: Gilson Belini
Data		: 06/05/2017
Descricao	: Utilizada para Eliminar Caracteres Especiais
Uso			: Ourolux - Atualiza informacoes do campo DDD da SA1
*/

User Function AjusDDD()

Local cString := Iif(Len(AllTrim(TRC->A1_TEL))>=11,SUBSTR(TRC->A1_TEL,1,3),TRC->A1_DDD)
Local cNewDDD := ""

cNewDDD := StrTran( cString, "-", "" )

return (cNewDDD)
