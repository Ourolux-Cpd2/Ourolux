#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³  MEGA37  ³ Autor ³ Eduardo Lobato        ³ Data ³ 09/10/14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ ACERTO DE LANCAMENTOS DE VALORES NO SE5					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAFIN                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ PROGRAMADOR  ³ DATA   ³ BOPS ³  MOTIVO DA ALTERACAO                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³                                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function MEGA37()

LOCAL lLOG		:= .F.
LOCAL aCampos 	:= {}
LOCAL bCampos 	:= {}
LOCAL cFim		:= chr (13) + chr (10)
LOCAL aFILIAL	:= {}
Private cLOG 	:= ""


lLOG		:= .F.
aCampos 	:= {}
bCampos 	:= {}
cLOG 		:= ""

IF !PERGUNTE("MEGA37")
	RETURN
ENDIF


// mv_par01 = DATA DE INICIO
// mv_par02 = DATA FINAL
// mv_par03 = SIMULA


IF SELECT("TBR") >0
	DBSELECTAREA("TBR")
	DBCLOSEAREA()
ENDIF

AADD(aCampos,{ "BR_PREFIXO","C",03,0 } )
AADD(aCampos,{ "BR_NUMERO" ,"C",09,0 } )
AADD(aCampos,{ "BR_PARCELA","C",01,0 } )
AADD(aCampos,{ "BR_SEQ"    ,"C",02,0 } )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria arquivo de trabalho                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cNomArq 	:=  CriaTrab(aCampos)
dbUseArea( .T.,, cNomArq,"TBR", .F. , .F. )

cNomArq1 := Subs(cNomArq,1,7)+"A"
IndRegua("TBR",cNomArq1,"BR_PREFIXO+BR_NUMERO+BR_PARCELA+BR_SEQ",,,)		//"Selecionando Registros..."
dbClearIndex()


dbSetIndex(cNomArq1+OrdBagExt())

dbselectarea("TBR")
DBSETORDER(1)


IF SELECT("TMP") >0
	DBSELECTAREA("TMP")
	DBCLOSEAREA()
ENDIF


cQUERY := "SELECT * "
cQUERY += "FROM "+RetSqlName("SE5") + " AS SE5 "
cQUERY += "WHERE SE5.D_E_L_E_T_ <> '*' AND "
cQUERY += "SE5.E5_SITUACA <> 'C' AND "
cQUERY += "SE5.E5_TIPODOC = 'DC' AND "
cQUERY += "SE5.E5_DATA BETWEEN '" + DtoS(MV_PAR01) +  "' AND '" + DtoS(MV_PAR02) + "' "

cQUERY := ChangeQuery(cQUERY)
dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQUERY),"TMP",.T.,.F.)

///////////////////// PROCESSAMENTO

DBSELECTAREA("TMP")
DBGOTOP()
WHILE !EOF()
	
	DBSELECTAREA("SE5")
	DBSETORDER(7)
	DBGOTOP()
	lVL	:= .F.
	IF DBSEEK(XFILIAL("SE5")+TMP->E5_PREFIXO+TMP->E5_NUMERO+TMP->E5_PARCELA+TMP->E5_TIPO+TMP->E5_CLIFOR+TMP->E5_LOJA+TMP->E5_SEQ)
		WHILE !EOF() .AND. (TMP->E5_PREFIXO+TMP->E5_NUMERO+TMP->E5_PARCELA+TMP->E5_TIPO+TMP->E5_CLIFOR+TMP->E5_LOJA+TMP->E5_SEQ) ==;
			(SE5->E5_PREFIXO+SE5->E5_NUMERO+SE5->E5_PARCELA+SE5->E5_TIPO+SE5->E5_CLIFOR+SE5->E5_LOJA+SE5->E5_SEQ)
			IF SE5->E5_TIPODOC <> "DC"
				lVL := .T.
			ENDIF
			DBSKIP()
		END
	ENDIF
	IF !lVL
		
		DBSELECTAREA("TBR")
		RECLOCK("TBR",.T.)
		FIELD->BR_PREFIXO 	:= TMP->E5_PREFIXO
		FIELD->BR_NUMERO	:= TMP->E5_NUMERO
		FIELD->BR_PARCELA	:= TMP->E5_PARCELA
		FIELD->BR_SEQ		:= TMP->E5_SEQ
		MSUNLOCK()
	ENDIF
	
	
	DBSELECTAREA("TMP")
	DBSKIP()
END


DBSELECTAREA("TMP")
DBGOTOP()
WHILE !EOF()
	
	
	DBSELECTAREA("TBR")
	DBSETORDER(1)
	DBGOTOP()
	IF !DBSEEK(TMP->E5_PREFIXO+TMP->E5_NUMERO+TMP->E5_PARCELA+TMP->E5_SEQ)
		DBSELECTAREA("TMP")
		DBSKIP()
		LOOP
	ENDIF
	
	IF MV_PAR03 = 2
		
		DBSELECTAREA("SE5")
		RECLOCK("SE5",.T.)
		FIELD->E5_DATA		:= STOD(TMP->E5_DATA)
		FIELD->E5_TIPO		:= TMP->E5_TIPO
		FIELD->E5_MOEDA		:= TMP->E5_MOEDA
		FIELD->E5_VALOR  	:=  0
		FIELD->E5_NATUREZ	:= TMP->E5_NATUREZ
		FIELD->E5_BANCO		:= TMP->E5_BANCO
		FIELD->E5_AGENCIA	:= TMP->E5_AGENCIA
		FIELD->E5_CONTA		:= TMP->E5_CONTA
		FIELD->E5_RECPAG	:= TMP->E5_RECPAG
		FIELD->E5_BENEF		:= TMP->E5_BENEF
		FIELD->E5_HISTOR	:= "Valor recebido s/ Titulo"
		FIELD->E5_TIPODOC	:= "VL"
		FIELD->E5_VLMOED2 	:= 0
		FIELD->E5_LA		:= "N"
		FIELD->E5_PREFIXO	:= TMP->E5_PREFIXO
		FIELD->E5_NUMERO	:= TMP->E5_NUMERO
		FIELD->E5_PARCELA	:= TMP->E5_PARCELA
		FIELD->E5_CLIFOR	:= TMP->E5_CLIFOR
		FIELD->E5_LOJA		:= TMP->E5_LOJA
		FIELD->E5_DTDIGIT	:= STOD(TMP->E5_DTDIGIT)
		FIELD->E5_MOTBX		:= TMP->E5_MOTBX
		FIELD->E5_SEQ		:= TMP->E5_SEQ
		FIELD->E5_DTDISPO	:= STOD(TMP->E5_DTDISPO)
		FIELD->E5_FILORIG	:= TMP->E5_FILORIG
		FIELD->E5_VLDESCO 	:= TMP->E5_VALOR
		FIELD->E5_SITCOB	:= TMP->E5_SITCOB
		FIELD->E5_CLIENTE	:= TMP->E5_CLIENTE
		FIELD->E5_USERLGI	:= TMP->E5_USERLGI
		FIELD->E5_TPDESC    := TMP->E5_TPDESC
		FIELD->E5_ORIGEM	:= "MEGA37  "
		MSUNLOCK()
		
	ENDIF
	
	
	IF MV_PAR03 = 2
		cLOG += "PREFIXO: "+TBR->BR_PREFIXO+" NUMERO: "+TBR->BR_NUMERO+" PARCELA "+TBR->BR_PARCELA+" SEQ: "+TBR->BR_SEQ
	ELSE
		cLOG += "E5_PREFIXO == '"+TBR->BR_PREFIXO+"'.and. E5_NUMERO=='"+TBR->BR_NUMERO+"' .and. E5_PARCELA=='"+TBR->BR_PARCELA+"'"
	ENDIF
	cLOG += cFIM
	
	
	
	
	
	DBSELECTAREA("TMP")
	DBSKIP()
END

// TESTE
MErro()
//cStartPath := GetSrvProfString("Startpath","")
//cFileLog   := Criatrab(,.f.)+".LOG"
//cLogName   := "M"+aFILIAL[X]+STRZERO(DAY(dDATAbASE),2)+STRZERO(MONTH(DDATABASE),2)+SUBS(STRZERO(YEAR(dDATAbASE),4),3,2)+".LOG"
//Copy File (cStartPath + cFileLog) To ("\INTRJ\" + cLOGNAME)

dbSelectArea( "TBR" )
dbCloseArea()
fErase(cNomArq+GetDBExtension())
fErase(cNomArq1+OrdBagExt())


IF SELECT("TMP") > 0
	dbSelectArea( "TMP" )
	dbCloseArea()
ENDIF



RETURN .T.


/// FUNCAO PARA USO EM TESTE
STATIC Function MErro(cPath,cNome)
Local oDlg
Local cMemo
Local cFile    :=""
Local cMask    := "Arquivos Texto (*.TXT) |*.txt|"
Local oFont
Local cStartPath := GetSrvProfString("Startpath","")

cPath := If(cPath = Nil, "", cPath)
__cFileLog := Criatrab(,.f.)+".LOG"
cNome := __cFileLog
cMemo := cLog
MemoWrite(cNome,cMemo)
cLogName := "RIO"+STRZERO(DAY(dDATAbASE),2)+STRZERO(MONTH(DDATABASE),2)+STRZERO(YEAR(dDATAbASE),4)+".LOG"

If Empty(cPath)
	DEFINE FONT oFont NAME "Courier New" SIZE 5,0   //6,15
	
	DEFINE MSDIALOG oDlg TITLE __cFileLog From 3,0 to 340,617 PIXEL
	
	
	@ 5,5 GET oMemo  VAR cMemo MEMO SIZE 300,145 OF oDlg PIXEL
	oMemo:bRClicked := {||AllwaysTrue()}
	oMemo:oFont:=oFont
	
	DEFINE SBUTTON  FROM 153,175 TYPE 1 ACTION oDlg:End() ENABLE OF oDlg PIXEL //Apaga
	DEFINE SBUTTON  FROM 153,145 TYPE 13 ACTION (cFile:=cGetFile(cMask,OemToAnsi("Salvar Como...")),If(cFile="",.t.,MemoWrite(cFile,cMemo)),oDlg:End()) ENABLE OF oDlg PIXEL // //
	DEFINE SBUTTON  FROM 153,115 TYPE 6 ACTION (PrintAErr(__cFileLog,cMemo),oDlg:End()) ENABLE OF oDlg PIXEL //
	
	ACTIVATE MSDIALOG oDlg CENTER
Else
	ConOut("Processo nao concluido. Verificar arquivo " + cNome)
	//	Copy File (cStartPath + "\" + __cFileLog) To (cPath + "\" + cNome)
EndIf
Ferase(__cFileLog)
__cFileLog := Nil
Return(cMemo)
