#INCLUDE "RWMAKE.CH "
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

//+-----------------------------------------------------------------------------------//
//|Funcao....: RelDrilMag
//|Autor.....: Luiz Fernando - luiz@dqzafra.com.br
//|Data......: 09 de Dezembro de 2010, 20:31
//|Uso.......: SIGACOM
//|Versao....: Protheus - 10
//|Descricao.: Analise de S.I. e Pedidos
//|Observação:
//+-----------------------------------------------------------------------------------//

*------------------------------------------------*
User Function RelDrilMag()
*------------------------------------------------*

Local oEnt    := Nil
Local oDlgRE  := Nil
Local oGrp    := Nil
Local nOpcao  := 0
Local nLi1    := 15
Local nLi2    := 23
Local nCo1    := 10
Local nCo2    := 40
Local aEnt    := {"1=SI Em Aberto","2=PO Não Embarcado","3=PO Embarcado","4=PO Entregue","5=Todos"}

Private cxSi1 := Space(6)
Private cxSi2 := "ZZZZZZ" //Space(6)
Private cxPO1 := Space(17)
Private cxPO2 := "ZZZZZZZZZZZZZZZZZ" //Space(17)
Private cxFo1 := Space(6)
Private cxFo2 := "ZZZZZZ" //Space(6)
Private cxEnt := "5"
Private axSIs := {}
Private axPOs := {}
Private bLineSI := &("{ || {axSIs[oLbxSI:nAt,1],axSIs[oLbxSI:nAt,2],axSIs[oLbxSI:nAt,3] }}")
Private bLinePO := &("{ || {axPOs[oLbxPO:nAt,1],axPOs[oLbxPO:nAt,2],axPOs[oLbxPO:nAt,3] }}")
Private oLbxSI := Nil
Private oLbxPO := Nil
Private aHeader1:= {}
Private aCols1  := {}
Private aHeader2:= {}
Private aCols2  := {}

While .T.
	
	nLi1 := 15
	nLi2 := 23
	nCo1 := 10
	nCo2 := 40
	
	DEFINE MSDIALOG oDlgRE TITLE "View de Processos" From 1,1 to 215,280 of oMainWnd PIXEL
	
	oGrp  := TGroup():New( 5,5,105,100,"Dados",oDlgRE,CLR_BLACK,CLR_WHITE,.T.,.F. )
	
	@ nLi1,nCo1 SAY "S.I. De:" SIZE 30,7 PIXEL OF oDlgRE
	@ nLi1,nCo2 MSGET cxSi1 F3 "SW0" SIZE 50,7 PIXEL OF oDlgRE
	
	@ nLi1+=12,nCo1 SAY "S.I. Até:" SIZE 30,7 PIXEL OF oDlgRE
	@ nLi1,nCo2 MSGET cxSi2 F3 "SW0" SIZE 50,7 PIXEL OF oDlgRE
	
	@ nLi1+=12,nCo1 SAY "P.O. De:" SIZE 30,7 PIXEL OF oDlgRE
	@ nLi1,nCo2 MSGET cxPO1 F3 "SW2" SIZE 50,7 PIXEL OF oDlgRE
	
	@ nLi1+=12,nCo1 SAY "P.O. Até:" SIZE 30,7 PIXEL OF oDlgRE
	@ nLi1,nCo2 MSGET cxPO2 F3 "SW2" SIZE 50,7 PIXEL OF oDlgRE
	
	@ nLi1+=12,nCo1 SAY "Forn. De:" SIZE 30,7 PIXEL OF oDlgRE
	@ nLi1,nCo2 MSGET cxFO1 F3 "SA2" SIZE 50,7 PIXEL OF oDlgRE
	
	@ nLi1+=12,nCo1 SAY "Forn. Até:" SIZE 30,7 PIXEL OF oDlgRE
	@ nLi1,nCo2 MSGET cxFO2 F3 "SA2" SIZE 50,7 PIXEL OF oDlgRE
	
	@ nLi1+=12,nCo1 SAY "Selecione :" SIZE 30,7 PIXEL OF oDlgRE
	@ nLi1,nCo2 COMBOBOX oEnt VAR cxEnt ITEMS aEnt SIZE 50,7 PIXEL OF oDlgRE
	
	DEFINE SBUTTON FROM 09,105 TYPE 19 OF oDlgRE ACTION (nOpcao:=1, oDlgRE:End()) ENABLE
	DEFINE SBUTTON FROM 25,105 TYPE 2  OF oDlgRE ACTION (nOpcao:=0, oDlgRE:End()) ENABLE
	
	ACTIVATE MSDIALOG oDlgRE CENTER
	
	If nOpcao == 1
		Processa({ || GerRelMag() })
		Exit
	Else
		Exit
	EndIf
	
EndDo

Return

//+-----------------------------------------------------------------------------------//
//|Funcao....: GerRelMag()
//|Descricao.: Gera dados
//|Observação:
//+-----------------------------------------------------------------------------------//
*------------------------------------------------*
Static Function GerRelMag()
*------------------------------------------------*

Local cSql  := ""
Local aDePO := {"P.O.","Data","Cod. Fornecedor"}
Local aDeSI := {"C.C.","S.I.","Data S.I."}
Local aPos  := {}
Local oDlg001 := Nil
Local bOk     := {|| nOpcao := 1, oDlg001:End() }
Local bCancel := {|| nOpcao := 2, oDlg001:End() }
Local aButtons:= {}

Private oLbxSI := Nil
Private oLbxPO := Nil
Private aStru     := {}
private cArqTrb2  := CriaTrab(NIL,.F.)

ProcRegua(0)

aAdd(aStru,{"AVG_SEQREL" ,"C",08,0})  // Sequencia do Relatorio
aAdd(aStru,{"AVG_CHAVE"  ,"C",06,0})  // Numero da SI
aAdd(aStru,{"AVG_C01_10" ,"C",10,0})  // Numero da SI
aAdd(aStru,{"AVG_C10_10" ,"C",10,0})  // Cores 0,1,2,3
aAdd(aStru,{"AVG_C05_10" ,"C",10,0})  // Data Embarque
aAdd(aStru,{"AVG_C06_10" ,"C",10,0})  // ETD
aAdd(aStru,{"AVG_C07_10" ,"C",10,0})  // ETA
aAdd(aStru,{"AVG_C08_10" ,"C",10,0})  // Data Chegada / Atracacao
aAdd(aStru,{"AVG_C09_10" ,"C",10,0})  // Data Desembaraco
aAdd(aStru,{"AVG_C01_20" ,"C",20,0})  // Numero do PO
aAdd(aStru,{"AVG_C01_30" ,"C",30,0})  // Razao Fornecedor
aAdd(aStru,{"AVG_C04_10" ,"C",10,0})  // Data Embarque
aAdd(aStru,{"AVG_C02_10" ,"C",10,0})  // Data Pagamento do PA
aAdd(aStru,{"AVG_C03_10" ,"C",10,0})  // Dta Fechamento Cambio
aAdd(aStru,{"AVG_C04_20" ,"C",20,0})  // Data Desembolso Invoice

dbcreate(cArqTrb2,aStru)
dbUseArea(.T.,,cArqTrb2,"TRB2",.F.,.F.)

//index on FILIAL+DtoS(DTPO)+PROCESS to &(cArqTrb2+"1")

//set index to &(cArqTrb2+"1")

cSql := " SELECT W0__NUM, W0__CC, W0__DT FROM "+RetSqlName("SW0")
cSql += " INNER JOIN "+RetSqlName("SW3") + " ON W0__NUM = W3_SI_NUM "  
cSql += " WHERE "+RetSqlName("SW0")+".D_E_L_E_T_ <> '*' AND W0_FILIAL = '"+xFilial("SW0")+"' "
cSql += Iif(!Empty(Alltrim(cxSi1))," AND W0__NUM >= '"+Alltrim(cxSi1)+"' ","")
cSql += Iif(!Empty(Alltrim(cxSi2))," AND W0__NUM <= '"+Alltrim(cxSi2)+"' ","") 
cSql += Iif(!Empty(Alltrim(cxPO1))," AND W3_PO_NUM >= '"+Alltrim(cxPO1)+"' ","")
cSql += Iif(!Empty(Alltrim(cxPO2))," AND W3_PO_NUM <= '"+Alltrim(cxPO2)+"' ","") 
cSql += Iif(!Empty(Alltrim(cxFO1))," AND W3_FORN >= '"+Alltrim(cxFO1)+"' ","")
cSql += Iif(!Empty(Alltrim(cxFO2))," AND W3_FORN <= '"+Alltrim(cxFO2)+"' ","") 
cSql += " GROUP BY W0__CC,W0__NUM,W0__DT "
cSql += " ORDER BY W0__CC,W0__NUM "

Iif(Select("XXSI") # 0,XXSI->(dbCloseArea()),.T.)
TcQuery cSql New Alias "XXSI"
XXSI->(dbSelectArea("XXSI"))
XXSI->(dbGoTop())

If XXSI->(EOF()) .AND. XXSI->(BOF())
	aAdd(axSIs,{"","",CtoD("")})
	XXSI->(dbCloseArea())
Else
	XXSI->(dbGoTop())
	While XXSI->(!EOF())
		IncProc("Analisando S.I.'s...")
		aAdd(axSIs,{XXSI->W0__CC,XXSI->W0__NUM,StoD(XXSI->W0__DT)})
		XXSI->(dbSkip())
	EndDo
	XXSI->(dbCloseArea())
EndIf

cSql := " SELECT W2_PO_NUM, W2_PO_DT, W2_FORN FROM "+RetSqlName("SW2")
cSql += " WHERE D_E_L_E_T_ <> '*' AND W2_FILIAL = '"+xFilial("SW2")+"' "
cSql += Iif(!Empty(Alltrim(cxPO1))," AND W2_PO_NUM >= '"+Alltrim(cxPO1)+"' ","")
cSql += Iif(!Empty(Alltrim(cxPO2))," AND W2_PO_NUM <= '"+Alltrim(cxPO2)+"' ","")
cSql += Iif(!Empty(Alltrim(cxFO1))," AND W2_FORN >= '"+Alltrim(cxFO1)+"' ","")
cSql += Iif(!Empty(Alltrim(cxFO2))," AND W2_FORN <= '"+Alltrim(cxFO2)+"' ","")
cSql += " ORDER BY W2_PO_NUM, W2_PO_DT "
Iif(Select("XXPO") # 0,XXPO->(dbCloseArea()),.T.)
TcQuery cSql New Alias "XXPO"
XXPO->(dbSelectArea("XXPO"))
XXPO->(dbGoTop())

If XXPO->(EOF()) .AND. XXPO->(BOF())
	aAdd(axPOs,{"","",CtoD("")})
	XXPO->(dbCloseArea())
Else
	XXPO->(dbGoTop())
	While XXPO->(!EOF())
		IncProc("Analisando P.O.'s...")
		aAdd(axPOs,{Alltrim(XXPO->W2_PO_NUM),StoD(XXPO->W2_PO_DT),Alltrim(XXPO->W2_FORN)})
		XXPO->(dbSkip())
	EndDo
	XXPO->(dbCloseArea())
EndIf

//*********************************************
//******* Imprime Direto sem o Dril Draw
//*********************************************
U_LFImpres1(axSIs)
Return
//*********************************************

//aAdd(aButtons,{"S4WB010N" ,{ || Processa({ || U_LFImpres1(axSIs) }) }, "Impressão"})

Define MsDialog oDlg001 Title "View de Importação" From 0,0 TO 300,600 OF oDlg001 PIXEL STYLE DS_MODALFRAME

aPos  := PosDlg(oDlg001)
nLin1 := 15
nLin2 := aPos[3]-2
nCol1 := 05
nCol2 := (aPos[4])/2

oGrp1 := TGroup():New( nLin1,nCol1,nLin2,nCol2,"Solicitações de Importação",oDlg001,CLR_BLACK,CLR_WHITE,.T.,.F. )
oLbxSI:= TWBrowse():New( nLin1+=8,nCol1+=5,(nCol2-nCol1)-5,(nLin2-nLin1)-5,,aDeSI,,oDlg001,,,,,,,,,,,,.F.,,.T.,,.F.,,,)
oLbxSI:SetArray(axSIs)
oLbxSI:bLDblClick := { || LFView(oLbxSI:nAt,"SI") }
oLbxSI:bLine := bLineSI

nLin1 := 15
nCol1 := nCol2+3
nCol2 := aPos[4]-3

oGrp2 := TGroup():New( nLin1,nCol1,nLin2,nCol2,"Purchase Orders",oDlg001,CLR_BLACK,CLR_WHITE,.T.,.F. )
oLbxPO:= TWBrowse():New( nLin1+=8,nCol1+=5,(nCol2-nCol1)-5,(nLin2-nLin1)-5,,aDePO,,oDlg001,,,,,,,,,,,,.F.,,.T.,,.F.,,,)
oLbxPO:SetArray(axPOs)
oLbxPO:bLDblClick := { || LFView(oLbxPO:nAt,"PO") }
oLbxPO:bLine := bLinePO

ACTIVATE MSDIALOG oDlg001 ON INIT EnchoiceBar(oDlg001,bOk,bCancel,,aButtons) Centered

Return

//+-----------------------------------------------------------------------------------//
//|Funcao....: LFView()
//|Descricao.: Gera dados
//|Observação:
//+-----------------------------------------------------------------------------------//
*------------------------------------------------*
Static Function LFView(xFoc,xTp)
*------------------------------------------------*

Local cAlis := ""
Local cSeek := ""

If xTp == "SI"
	cAlis := "SW0"
	cSeek := xFilial("SW0")+axSIs[xFoc,1]+axSIs[xFoc,2]
Else
	cAlis := "SW2"
	cSeek := xFilial("SW2")+axPOs[xFoc,1]
EndIf

Processa({ || GeraView(xTp,cAlis,cSeek)  })

Return

//+-----------------------------------------------------------------------------------//
//|Funcao....: GeraView(xTp,xAlias,xSeek)
//|Descricao.: Analise e mostra tela de visualizações da SI e do PO
//|Observação:
//+-----------------------------------------------------------------------------------//
*------------------------------------------------*
Static Function GeraView(xTp,xAlias,xSeek)
*------------------------------------------------*

Local cTitu   := Iif(xTp == "SI","Visualização da SI","Visualização do PO")
Local oDlg    := Nil
Local oTela   := Nil
Local oGet1   := Nil
Local oGet2   := Nil
Local bOk     := {|| oDlg:End() }
Local bCancel := {|| oDlg:End() }
Local aPos2   := {}

dbSelectArea(xAlias)
&(xAlias)->(dbSetOrder(1))

If !&(xAlias)->(dbSeek(xSeek))
	MsgInfo(xTp+" não encontrado(a).")
	Return
EndIf

dbSelectArea(xAlias)
For nInd := 1 TO &(xAlias)->(FCount())
	M->&(FieldName(nInd)) := FieldGet(nInd)
Next

nRec := &(xAlias)->(RecNo())
nOpc := 2
MontHead(xTp,xSeek)
MontCols(xTp,xSeek)

DEFINE MSDIALOG oDlg TITLE cTitu From 1,1 to 400,800 of oMainWnd PIXEL STYLE DS_MODALFRAME

aPos2 := PosDlgDown(oDlg)

oTela := MsMget():New(xAlias,nRec,nOpc,,,,,PosDlgUp(oDlg),,3,,,,,,,,,.F.)
oTela:Refresh()
oGet1 := MsNewGetDados():New(aPos2[1],aPos2[2],aPos2[3],(aPos2[4]/2)-2,0,,,,,0,1000,,,,oDlg,aHeader1,aCols1 )
oGet2 := MsNewGetDados():New(aPos2[1],(aPos2[4]/2)+2,aPos2[3],aPos2[4],0,,,,,0,1000,,,,oDlg,aHeader2,aCols2 )

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,bOk,bCancel) Centered

Return

//+-----------------------------------------------------------------------------------//
//|Funcao....: MontaHead(xTp,xAlias,xSeek)
//|Descricao.: Monta aHeader1
//|Observação:
//+-----------------------------------------------------------------------------------//
*------------------------------------------------*
Static Function MontHead(xTp,xSeek)
*------------------------------------------------*

Local cAlis  := Iif(xTp == "SI","SW1","SW3")
Local aCamp1 := {}
Local aCamp2 := {}

aHeader1 := {}
aHeader2 := {}
If xTp == "SI"
	aCamp1 := {"W1_COD_I","W1_COD_DES","W1_FABR","W1_FORN","W1_CLASS","W1_QTDE","W1_SALDO_Q","W1_PRECO","W1_DT_EMB","W1_DTENTR_"}
	aCamp2 := {"W3_PO_NUM","W3_COD_I","W3_FABR","W3_FLUXO","W3_QTDE","W3_SALDO_Q","W3_PRECO","W3_DT_EMB","W3_DT_ENTR","W3_TEC","W3_EX_NCM"}
Else
	aCamp1 := {"W3_CC","W3_SI_NUM","W3_COD_I","W3_FABR","W3_FLUXO","W3_QTDE","W3_SALDO_Q","W3_PRECO","W3_DT_EMB","W3_DT_ENTR","W3_TEC","W3_EX_NCM"}
	aCamp2 := {"WB_HAWB","WB_INVOICE","WB_BANCO","WB_AGENCIA","WB_DT_VEN","WB_DT_CONT","WB_CA_NUM","WB_DT_DESE","WB_PGTANT","WB_CA_DT",;
	"WB_MOEDA","WB_FOBMOE","WB_CA_TX","WB_LIM_BAC","WB_ENV_BAC","WB_DT_PAG","WB_NUMDUP","WB_PARCELA","WB_TIPOTIT","WB_PREFIXO"}
EndIf

dbSelectArea("SX3")
SX3->(dbSetOrder(2))
For tu := 1 To Len(aCamp1)
	If SX3->(dbSeek(aCamp1[tu]))
		Aadd(aHeader1,{AllTrim(X3Titulo()),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,;
		SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_F3,SX3->X3_CONTEXT,,SX3->X3_CBOX,SX3->X3_RELACAO})
	EndIf
Next

For tu := 1 To Len(aCamp2)
	If SX3->(dbSeek(aCamp2[tu]))
		Aadd(aHeader2,{AllTrim(X3Titulo()),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,;
		SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_F3,SX3->X3_CONTEXT,,SX3->X3_CBOX,SX3->X3_RELACAO})
	EndIf
Next

Return

//+-----------------------------------------------------------------------------------//
//|Funcao....: MontCols
//|Descricao.: Monta aCols1
//|Observação:
//+-----------------------------------------------------------------------------------//
*------------------------------------------------*
Static Function MontCols(xTp,xSeek)
*------------------------------------------------*

Local cAlis := Iif(xTp == "SI","SW1","SW3")
Local cCopa := Iif(xTp == "SI","SW1->(W1_FILIAL+W1_CC+W1_SI_NUM)","SW3->(W3_FILIAL+W3_PO_NUM)")
Local cCopa2:= Iif(xTp == "SI","SW3->(W3_FILIAL+W3_CC+W3_SI_NUM)","SWB->(WB_FILIAL+WB_HAWB)+'A'")
//Local cCopa2:= Iif(xTp == "SI","SW3->(W3_FILIAL+W3_CC+W3_SI_NUM)","SWB->(WB_FILIAL+WB_HAWB)")
Local cSequ := Iif(xTp == "SI","SW1->W1_SEQ","SW3->W3_SEQ")
Local nUsado1 := Len(aHeader1)
Local nUsado2 := Len(aHeader2)

aCols1 := {}
aCols2 := {}
dbSelectArea(cAlis)
&(cAlis)->(dbSetOrder(1))
If &(cAlis)->(dbSeek(xSeek))
	cPo := Iif(xTp <> "SI",xFilial("SW3")+SW3->W3_PO_NUM+Space(2)+"A","")
	While &(cAlis)->(!EOF()) .AND. Alltrim(&cCopa) == Alltrim(xSeek)
		If Empty(&cSequ)
			aAdd(aCols1,Array(nUsado1+1))
			For nI := 1 to nUsado1
				If Upper(AllTrim(aHeader1[nI,10])) != "V" 	// Campo Real
					aCols1[Len(aCols1),nI] := FieldGet(FieldPos(aHeader1[nI,2]))
				ElseIf xTp == "SI" .AND. Upper(AllTrim(aHeader1[nI,10])) == "V" 	// Campo Virtual
					aCols1[Len(aCols1),nI] := Alltrim(Posicione("SB1",1,xFilial("SB1")+SW1->W1_COD_I,"B1_DESC"))
				Endif
			Next nI
			aCols1[Len(aCols1),nUsado1+1] := .F.
		EndIf
		&(cAlis)->(dbSkip())
	EndDo
EndIf

If xTp == "SI"
	dbSelectArea("SW3")
	SW3->(dbSetOrder(4))
	If SW3->(dbSeek(xSeek))
		While SW3->(!EOF()) .AND. Alltrim(&cCopa2) == Alltrim(xSeek)
			If Empty(SW3->W3_SEQ)
				aAdd(aCols2,Array(nUsado2+1))
				For nI := 1 to nUsado2
					If Upper(AllTrim(aHeader2[nI,10])) != "V" 	// Campo Real
						aCols2[Len(aCols2),nI] := FieldGet(FieldPos(aHeader2[nI,2]))
					EndIf
				Next nI
				aCols2[Len(aCols2),nUsado2+1] := .F.
			EndIf
			SW3->(dbSkip())
		EndDo
	EndIf
Else
	dbSelectArea("SWB")
	SWB->(dbSetOrder(1))
	If SWB->(dbSeek(cPo))
		While SWB->(!EOF()) .AND. &cCopa2 == cPo
			aAdd(aCols2,Array(nUsado2+1))
			For nI := 1 to nUsado2
				If Upper(AllTrim(aHeader2[nI,10])) != "V" 	// Campo Real
					aCols2[Len(aCols2),nI] := FieldGet(FieldPos(aHeader2[nI,2]))
				EndIf
			Next nI
			aCols2[Len(aCols2),nUsado2+1] := .F.
			SWB->(dbSkip())
		EndDo
	EndIf
EndIf

If Len(aCols2) == 0
	aCols2 := Array(1,nUsado2+1)
	For nI = 1 To Len(aHeader2)
		If aHeader2[nI,8] == "C"
			aCols2[1,nI] := Space(aHeader2[nI,4])
		ElseIf aHeader2[nI,8] == "N"
			aCols2[1,nI] := 0
		ElseIf aHeader2[nI,8] == "D"
			aCols2[1,nI] := CtoD("")
		ElseIf aHeader2[nI,8] == "M"
			aCols2[1,nI] := ""
		Else
			aCols2[1,nI] := .F.
		EndIf
	Next nI
	aCols2[1,nUsado2+1] := .F.
EndIf

Return

//+-----------------------------------------------------------------------------------//
//|Funcao....: LFImpres1(xSIs)
//|Descricao.: Realiza a Impressão
//|Observação:
//|Campos usados
//|AVG_C01_10 = Numero SI
//|AVG_C01_30 = Nome fornecedor
//|AVG_C01_20 = Numero PO
//|AVG_C02_10 = Data do pagamento do PA
//|AVG_C03_10 = Data do saldo (financeiro)
//|AVG_C04_10 = Prev. Embarque
//|AVG_C05_10 = Data de embarque efetiva
//|AVG_C06_10 = ETD //Previsão da entrega
//|AVG_C07_10 = ETA
//|AVG_C08_10 = Data Atracação
//|AVG_C09_10 = Data desembaraço
//+-----------------------------------------------------------------------------------//
*------------------------------------------------*
User Function LFImpres1(xSIs)
*------------------------------------------------*

If Len(xSIs) == 0
	MsgInfo("Não há dados para Impresão")
	Return
EndIf

cSeqRela := GetSXENum("SY0","Y0_SEQREL")
ConfirmSX8()

E_ARQCRW(.T.,.T.,.T.)

SW0->(dbSetOrder(1))
SW1->(dbSetOrder(1))
SW3->(dbSetOrder(7))
SW6->(dbSetOrder(1))
SW7->(dbSetOrder(2))
SWB->(dbSetOrder(5))

For gt := 1 To Len(xSIs)
	
	SW1->(dbSeek(xFilial("SW1")+xSIs[gt,1]+xSIs[gt,2])) //Posiciona itens da S.I.
	
	_nRec := SW1->(Recno())
	
	_cGdaPO := ""
	
	While SW1->W1_CC == xSIs[gt,1] .and. SW1->W1_SI_NUM == xSIs[gt,2] .AND. !Eof()
		
		If SW1->W1_PO_NUM $_cGdaPO
			SW1->(DbSkip())
			If SW1->W1_CC != xSIs[gt,1] .and. SW1->W1_SI_NUM != xSIs[gt,2]
				Exit
			Else
				_nRec := SW1->(Recno())
			Endif
			Loop
		EndIf
		
		If SW1->W1_SALDO_Q == 0 .AND. SW1->W1_SEQ == 0 // Saldo > 0 ?
			SW1->(DbSkip())
			If SW1->W1_CC != xSIs[gt,1] .and. SW1->W1_SI_NUM != xSIs[gt,2]
				Exit
			Else
				_nRec := SW1->(Recno())
			Endif
			Loop
		ENDIF
		
//Cabeçalho Crystal
		HEADER_P->(dbAppend())
		HEADER_P->AVG_SEQREL:= cSeqRela
		HEADER_P->AVG_CHAVE := xSIs[gt,2]
		HEADER_P->AVG_C10_10 := "0"
		
		HEADER_P->AVG_C01_10 := xSIs[gt,2]
//Fim do Cabeçalho		 
//Gravando os itens Da SI
		TRB2->(RecLock("TRB2",.T.))
		TRB2->AVG_SEQREL:= cSeqRela
		TRB2->AVG_CHAVE := xSIs[gt,2]
		TRB2->AVG_C10_10:= "0"
		TRB2->AVG_C01_10:= xSIs[gt,2]
		TRB2->(MsUnlock("TRB2"))
//Fim Da Gravação
//Procura no P.O.
		If SW3->(dbSeek(xFilial("SW3")+SW1->W1_PO_NUM)) // Posiciona nos Itens Do P.O.
			
			_cPONum := SW3->W3_PO_NUM
			
			While SW3->W3_PO_NUM == _cPONum
//Cabeçalho Crystal
				HEADER_P->AVG_C01_20 := SW3->W3_PO_NUM
				HEADER_P->AVG_C01_30 := Alltrim(Posicione("SA2",1,xFilial("SA2")+SW3->W3_FORN,"A2_NREDUZ"))
				HEADER_P->AVG_C04_10 := DtoC(SW3->W3_DT_EMB)
//Fim Cabeçalho				
//Grava Informações do P.O.
				TRB2->(RecLock("TRB2",.F.))
				TRB2->AVG_C01_20 := SW3->W3_PO_NUM
				TRB2->AVG_C01_30 := Alltrim(Posicione("SA2",1,xFilial("SA2")+SW3->W3_FORN,"A2_NREDUZ"))
				TRB2->AVG_C04_10 := DtoC(SW3->W3_DT_EMB)
				TRB2->(MsUnlock("TRB2"))
//Fim Da Gravação				
//Procura nos Itens Da D.I.
				If SW7->(dbSeek(xFilial("SW7")+SW3->W3_PO_NUM))
//Se encontra, procura na capa da D.I.
					If SW6->(dbSeek(xFilial("SW6")+SW7->W7_HAWB ))
//Cabeçalho Crystal
						HEADER_P->AVG_C05_10 := DtoC(SW6->W6_DT_EMB)
						HEADER_P->AVG_C06_10 := DtoC(SW6->W6_DT_ETD)
						HEADER_P->AVG_C07_10 := DtoC(SW6->W6_DT_ETA)
						HEADER_P->AVG_C08_10 := DtoC(SW6->W6_CHEG)
						HEADER_P->AVG_C09_10 := DtoC(SW6->W6_DT_DESE)
//Fim Cabeçalho	
//Grava informações Da D.I.  
						TRB2->(RecLock("TRB2",.F.))
						TRB2->AVG_C05_10 := DtoC(SW6->W6_DT_EMB)
						TRB2->AVG_C06_10 := DtoC(SW6->W6_DT_ETD)
						TRB2->AVG_C07_10 := DtoC(SW6->W6_DT_ETA)
						TRB2->AVG_C08_10 := DtoC(SW6->W6_CHEG)
						TRB2->AVG_C09_10 := DtoC(SW6->W6_DT_DESE)
						TRB2->(MsUnlock("TRB2"))
//fim da Gravação									
						If SW6->W6_PRVENTR <= dDataBase .AND. Empty(SW6->W6_CHEG)
							HEADER_P->AVG_C10_10 := "2"
							
							TRB2->(RecLock("TRB2",.F.))
							TRB2->AVG_C10_10 := "2"
							TRB2->(MsUnlock("TRB2"))
							
						Endif
						
						***********************************************************************************************
						*** Seleção permite que Imprima quando for Todos e PO Embarcado e PO Embarcad c/Dta Entrega atraso
						***********************************************************************************************
						If cxEnt != "5" .and. cxEnt $ "2|1|4"
							HEADER_P->AVG_SEQREL:= " "
							TRB2->(RecLock("TRB2",.F.))
							TRB2->AVG_SEQREL:= " "
							TRB2->(MsUnlock("TRB2"))
						Else
							HEADER_P->AVG_SEQREL:= cSeqRela
							TRB2->(RecLock("TRB2",.F.))
							TRB2->AVG_SEQREL:= cSeqRela
							TRB2->(MsUnlock("TRB2"))
						Endif
						***********************************************************************************************
						
						***********************************************************************************************
						*** Seleção permite que Imprima quando for Todos e PO Entregues
						***********************************************************************************************
						If cxEnt != "5" .and. cxEnt == "4Xl"
							If !Empty(SW6->W6_CHEG)
								HEADER_P->AVG_SEQREL:= cSeqRela
								TRB2->(RecLock("TRB2",.F.))
								TRB2->AVG_SEQREL:= cSeqRela
								TRB2->(MsUnlock("TRB2"))
							Endif
						Endif
						***********************************************************************************************
						
					EndIf
					
					** Wb_tiporeg = (1 e P)
					*** Se Ha Embarque Busca informacoes da Invoice e do PA no SWB
					SWB->(dbSetOrder(1))
					If SWB->(dbSeek(xFilial("SWB")+SW7->W7_HAWB))
						While SWB->WB_HAWB == SW6->W6_HAWB 
							HEADER_P->AVG_C01_10 := xSIs[gt,2]
							HEADER_P->AVG_C01_20 := SW3->W3_PO_NUM
							HEADER_P->AVG_C01_30 := Alltrim(Posicione("SA2",1,xFilial("SA2")+SW3->W3_FORN,"A2_NREDUZ"))
							HEADER_P->AVG_C02_10 := DtoC(GetAdvFVal("SWB","WB_DT_DIG",xFilial("SWB")+SW6->W6_PO_NUM,1,""))
                            If SWB->WB_TIPOREG == "P"
								HEADER_P->AVG_C03_10 := DtoC(SWB->WB_DT_DESE) 
							Endif
							If SWB->WB_TIPOREG == "P"
							  HEADER_P->AVG_C03_10 := DtoC(SWB->WB_DT_DESE) // DtoC(SWB->WB_CA_DT)
							Endif
												
							TRB2->(RecLock("TRB2",.F.))
							TRB2->AVG_C01_10 := xSIs[gt,2]
							TRB2->AVG_C01_20 := SW3->W3_PO_NUM
							TRB2->AVG_C01_30 := Alltrim(Posicione("SA2",1,xFilial("SA2")+SW3->W3_FORN,"A2_NREDUZ"))
							TRB2->AVG_C02_10 := DtoC(GetAdvFVal("SWB","WB_DT_DIG",xFilial("SWB")+SW6->W6_PO_NUM,1,""))
							If SWB->WB_TIPOREG == "P"
							   TRB2->AVG_C03_10 := DtoC(SWB->WB_DT_DESE) 
							Endif
							TRB2->(MsUnlock("TRB2"))
							
							If SWB->WB_FOBMOE != 0
								HEADER_P->AVG_C04_20 := DtoC(SWB->WB_DT_DESE)
								TRB2->(RecLock("TRB2",.F.))
								TRB2->AVG_C04_20 := DtoC(SWB->WB_DT_DESE)
								TRB2->(MsUnlock("TRB2"))
							Endif
							
							HEADER_P->AVG_C05_10 := DtoC(SW6->W6_DT_EMB)
							HEADER_P->AVG_C06_10 := DtoC(SW6->W6_DT_ETD)
							HEADER_P->AVG_C07_10 := DtoC(SW6->W6_DT_ETA)
							HEADER_P->AVG_C08_10 := DtoC(SW6->W6_CHEG)
							HEADER_P->AVG_C09_10 := DtoC(SW6->W6_DT_DESE)
							
							HEADER_P->AVG_C04_10 := DtoC(SW3->W3_DT_EMB)
							
							TRB2->(RecLock("TRB2",.F.))
							TRB2->AVG_C05_10 := DtoC(SW6->W6_DT_EMB)
							TRB2->AVG_C06_10 := DtoC(SW6->W6_DT_ETD)
							TRB2->AVG_C07_10 := DtoC(SW6->W6_DT_ETA)
							TRB2->AVG_C08_10 := DtoC(SW6->W6_CHEG)
							TRB2->AVG_C09_10 := DtoC(SW6->W6_DT_DESE)
							TRB2->AVG_C04_10 := DtoC(SW3->W3_DT_EMB)
							TRB2->(MsUnlock("TRB2"))
							
							
							SWB->(DbSkip())
							
						ENDDO
						
					//EndIf
					
					Else
					
						*** Se nao tem Embarque Busca informacoes do PA no SWB
						SWB->(dbSetOrder(1))
						If SWB->(dbSeek(xFilial("SWB")+SW3->W3_PO_NUM+Space(2)+"A")) .And. SWB->WB_TIPOTIT = "PA"
							HEADER_P->AVG_C01_10 := xSIs[gt,2]
							HEADER_P->AVG_C01_20 := SW3->W3_PO_NUM
							HEADER_P->AVG_C01_30 := Alltrim(Posicione("SA2",1,xFilial("SA2")+SW3->W3_FORN,"A2_NREDUZ"))
							HEADER_P->AVG_C02_10 := DtoC(GetAdvFVal("SWB","WB_DT_DIG",xFilial("SWB")+SW6->W6_PO_NUM,1,""))
                            If SWB->WB_TIPOREG == "P"
								HEADER_P->AVG_C03_10 := DtoC(SWB->WB_DT_DESE) 
							Endif
							If SWB->WB_TIPOREG == "P"
							  HEADER_P->AVG_C03_10 := DtoC(SWB->WB_DT_DESE) // DtoC(SWB->WB_CA_DT)
							Endif
							
							TRB2->(RecLock("TRB2",.F.))
							TRB2->AVG_C01_10 := xSIs[gt,2]
							TRB2->AVG_C01_20 := SW3->W3_PO_NUM
							TRB2->AVG_C01_30 := Alltrim(Posicione("SA2",1,xFilial("SA2")+SW3->W3_FORN,"A2_NREDUZ"))
								TRB2->AVG_C02_10 := DtoC(GetAdvFVal("SWB","WB_DT_DIG",xFilial("SWB")+SW6->W6_PO_NUM,1,""))
							If SWB->WB_TIPOREG == "P"
							   TRB2->AVG_C03_10 := DtoC(SWB->WB_DT_DESE) 
							Endif
							TRB2->(MsUnlock("TRB2"))
							
							If SWB->WB_FOBMOE != 0
								HEADER_P->AVG_C04_20 := DtoC(SWB->WB_DT_DESE)
								TRB2->(RecLock("TRB2",.F.))
								TRB2->AVG_C04_20 := DtoC(SWB->WB_DT_DESE)
								TRB2->(MsUnlock("TRB2"))
							Endif
							
							HEADER_P->AVG_C05_10 := DtoC(SW6->W6_DT_EMB)
							HEADER_P->AVG_C06_10 := DtoC(SW6->W6_DT_ETD)
							HEADER_P->AVG_C07_10 := DtoC(SW6->W6_DT_ETA)
							HEADER_P->AVG_C08_10 := DtoC(SW6->W6_CHEG)
							HEADER_P->AVG_C09_10 := DtoC(SW6->W6_DT_DESE)
							
							HEADER_P->AVG_C04_10 := DtoC(SW3->W3_DT_EMB)
							
							TRB2->(RecLock("TRB2",.F.))
							TRB2->AVG_C05_10 := DtoC(SW6->W6_DT_EMB)
							TRB2->AVG_C06_10 := DtoC(SW6->W6_DT_ETD)
							TRB2->AVG_C07_10 := DtoC(SW6->W6_DT_ETA)
							TRB2->AVG_C08_10 := DtoC(SW6->W6_CHEG)
							TRB2->AVG_C09_10 := DtoC(SW6->W6_DT_DESE)
							TRB2->AVG_C04_10 := DtoC(SW3->W3_DT_EMB)
							TRB2->AVG_C10_10 := "3"	
							TRB2->(MsUnlock("TRB2"))  	
					EndIf
					
					*********************************************************************************************************
					*** Seleção permite que Imprima quando for Todos e PO com Cambio s/embarque embarcado ou Nao embarcado
					*********************************************************************************************************
					If cxEnt != "5" .and. cxEnt $ "1|3|4" //.and. cxEnt != "2"
						HEADER_P->AVG_SEQREL:= " "
						TRB2->(RecLock("TRB2",.F.))
						TRB2->AVG_SEQREL:= " "
						TRB2->(MsUnlock("TRB2"))
					Else
						HEADER_P->AVG_SEQREL:= cSeqRela
						TRB2->(RecLock("TRB2",.F.))
						TRB2->AVG_SEQREL:= cSeqRela
						TRB2->(MsUnlock("TRB2"))
					Endif
					***********************************************************************************************
					
				EndIf
				EndIf
				
				SW3->(DbSkip())
				
			Enddo
			
		Else
			
			*************************************************************************************************************
			If SW1->(dbSeek(xFilial("SW1")+xSIs[gt,1]+xSIs[gt,2]))
				HEADER_P->AVG_C01_30 := Alltrim(Posicione("SA2",1,xFilial("SA2")+SW1->W1_FORN,"A2_NREDUZ"))
				HEADER_P->AVG_C04_10 := DtoC(SW1->W1_DT_EMB)
				
				TRB2->(RecLock("TRB2",.F.))
				TRB2->AVG_C01_30 := Alltrim(Posicione("SA2",1,xFilial("SA2")+SW1->W1_FORN,"A2_NREDUZ"))
				TRB2->AVG_C04_10 := DtoC(SW1->W1_DT_EMB)
				TRB2->(MsUnlock("TRB2"))
				
			EndIf
			
			HEADER_P->AVG_C10_10 := "1"
			
			TRB2->(RecLock("TRB2",.F.))
			TRB2->AVG_C10_10 := "1"
			TRB2->(MsUnlock("TRB2"))
			
			***********************************************************************************************
			*** Seleção permite que Imprima quando for Todos e SI Em Aberto
			***********************************************************************************************
			If cxEnt != "5" .and. cxEnt $ "2|3|4"
				HEADER_P->AVG_SEQREL:= " "
				
				TRB2->(RecLock("TRB2",.F.))
				TRB2->AVG_SEQREL:= " "
				TRB2->(MsUnlock("TRB2"))
				
			Else
				HEADER_P->AVG_SEQREL:= cSeqRela
				TRB2->(RecLock("TRB2",.F.))
				TRB2->AVG_SEQREL:= cSeqRela
				TRB2->(MsUnlock("TRB2"))
				
			Endif
			***********************************************************************************************
			
		EndIf
		
		SW1->(DbGoto(_nRec))
		
		_cGdaPO += SW1->W1_PO_NUM
		
		SW1->(DbSkip())
		
		_cGdaPO += "|"
		
		If SW1->W1_CC != xSIs[gt,1] .and. SW1->W1_SI_NUM != xSIs[gt,2]
			Exit
		Endif
		
		_nRec := SW1->(Recno())
		
	EndDo
	
Next

cSeqRela := GetSXENum("SY0","Y0_SEQREL")
ConfirmSX8()

E_ARQCRW(.T.,.T.,.T.)

DbSelectArea("TRB2")

If cxEnt $ "1|5"
	// Ordena pela SI
	index on TRB2->AVG_C10_10+TRB2->AVG_C01_20 to &(cArqTrb2+"1")
//	index on TRB2->AVG_C10_10+TRB2->AVG_C01_10+TRB2->AVG_C01_20 to &(cArqTrb2+"1")
	set index to &(cArqTrb2+"1")
Else
	// Ordena pelo PO
	index on TRB2->AVG_C10_10+TRB2->AVG_C01_20 to &(cArqTrb2+"1")
	set index to &(cArqTrb2+"1")
Endif

TRB2->(DbGoTop())

While !TRB2->((Eof()))
	If Empty(TRB2->AVG_SEQREL)
		TRB2->(DbSkip())
		Loop
	Else
		HEADER_P->(dbAppend())
		HEADER_P->AVG_SEQREL := cSeqRela 			// Sequencia do Relatorio
		HEADER_P->AVG_CHAVE  := TRB2->AVG_CHAVE		// Numero da SI
		HEADER_P->AVG_C01_10 := TRB2->AVG_C01_10	// Numero da SI
		HEADER_P->AVG_C10_10 := TRB2->AVG_C10_10 	// Cores 0,1,2,3
		HEADER_P->AVG_C05_10 := TRB2->AVG_C05_10	// Data Embarque
		HEADER_P->AVG_C06_10 := TRB2->AVG_C06_10 	// ETD
		HEADER_P->AVG_C07_10 := TRB2->AVG_C07_10	// ETA
		HEADER_P->AVG_C08_10 := TRB2->AVG_C08_10  	// Data Chegada / Atracacao
		HEADER_P->AVG_C09_10 := TRB2->AVG_C09_10	// Data Desembaraco
		HEADER_P->AVG_C01_20 := TRB2->AVG_C01_20	// Numero do PO
		HEADER_P->AVG_C01_30 := TRB2->AVG_C01_30	// Razao Fornecedor
		HEADER_P->AVG_C04_10 := TRB2->AVG_C04_10 	// Data Embarque
		HEADER_P->AVG_C02_10 := TRB2->AVG_C02_10	// Data Pagamento do PA
		HEADER_P->AVG_C03_10 := TRB2->AVG_C03_10	// Dta Fechamento Cambio
		HEADER_P->AVG_C04_20 := TRB2->AVG_C04_20	// Data Desembolso Invoice
	Endif
	TRB2->(DbSkip())
Enddo

AvgCrw32("RelMag.RPT","View de Importação",cSeqRela)

TRB2->(dbclosearea())

Return