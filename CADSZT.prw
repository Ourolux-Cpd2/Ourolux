#INCLUDE "rwmake.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CADSZT    º Autor ³ EDUARDO LOBATO     º Data ³  09/05/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ CADASTRO DE TIPOS DE OPERAÇÕES PARA CALCULO DA             º±±
±±º          ³ TES INTELIGENTE                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ OUROLUX                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function CADSZT()


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Local cVldAlt := ".T." // Validacao para permitir a alteracao. Pode-se utilizar ExecBlock.
Local cVldExc := ".T." // Validacao para permitir a exclusao. Pode-se utilizar ExecBlock.

Private cString := "SZT"

dbSelectArea("SZT")
dbSetOrder(1)

AxCadastro(cString,"Cadastro de Tipos de Operação",cVldExc,cVldAlt)

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ CALCSZT º Autor ³ EDUARDO LOBATO     º Data ³  09/05/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ CALCULO DA TES INTELIGENTE BBASEADA NA OPERAÇÃO            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ OUROLUX                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/


USER FUNCTION CALCSZT(cMOD,cProduto,cCliente,cLoja,cOperSZT)
LOCAL cTES
Local aArea:= GetArea()

IF cMOD == "SC5" 
	nPOSTES	:= ASCAN(aHEADER,{ |X| UPPER(ALLTRIM(X[2])) == "C6_TES" })
	nPOSCF	:= ASCAN(aHEADER,{ |X| UPPER(ALLTRIM(X[2])) == "C6_CF" })
	nPOSOP	:= ASCAN(aHEADER,{ |X| UPPER(ALLTRIM(X[2])) == "C6_OPER" })
	cTES	:= aCOLS[N][nPOSTES]
	
	IF EMPTY(M->C5_TESINT) .OR. M->C5_TIPO <> "N"
		RestArea(aArea) // por Icaro Queiroz em 11 Fev 2015
		RETURN(cTES)
	ENDIF
	
	DBSELECTAREA("SZT")
	DBSETORDER(1)
	DBGOTOP()
	IF !DBSEEK(XFILIAL("SZT")+M->C5_TESINT)
		RestArea(aArea) // por Icaro Queiroz em 11 Fev 2015
		RETURN(cTES)
	ENDIF
	lACHOU := .F.
	WHILE !EOF() .AND. SZT->ZT_OPERA == M->C5_TESINT
		IF SA1->A1_TIPO == SZT->ZT_TIPOCLI
			cOPER	:= SZT->ZT_TESINT
			lACHOU	:= .T.
			EXIT
		ENDIF
		DBSKIP()
	END
	IF !lACHOU
		RestArea(aArea) // por Icaro Queiroz em 11 Fev 2015
		RETURN(cTES)
	ENDIF
	
	cTES	:= MaTesInt(2,cOPER,M->C5_CLIENT,M->C5_LOJAENT,If(M->C5_TIPO$'DB',"F","C"),M->C6_PRODUTO,"C6_TES")
	aCOLS[N][nPOSOP] := cOPER
	aCOLS[N][nPOSCF] := U_GeraCF(M->C5_CLIENTE,M->C5_LOJACLI,cTES)
	
ELSEIF cMOD == "SUA"
	
	nPOSTES	:= ASCAN(aHEADER,{ |X| UPPER(ALLTRIM(X[2])) == "UB_TES" })
	nPOSCF	:= ASCAN(aHEADER,{ |X| UPPER(ALLTRIM(X[2])) == "UB_CF" })
	nPOSOP	:= ASCAN(aHEADER,{ |X| UPPER(ALLTRIM(X[2])) == "UB_OPER" })
	cTES	:= aCOLS[N][nPOSTES]
	
	IF EMPTY(M->UA_TESINT)
		RestArea(aArea) // por Icaro Queiroz em 11 Fev 2015
		RETURN(cTES)
	ENDIF                                  
	
	If !SUA->UA_PROSPEC
		cTIPO	:= SA1->A1_TIPO
	ELSE
		cTIPO	:= SUS->US_TIPO
	ENDIF
	
	DBSELECTAREA("SZT")
	DBSETORDER(1)
	DBGOTOP()
	IF !DBSEEK(XFILIAL("SZT")+M->UA_TESINT)
		RestArea(aArea) // por Icaro Queiroz em 11 Fev 2015
		RETURN(cTES)
	ENDIF
	lACHOU := .F.
	WHILE !EOF() .AND. SZT->ZT_OPERA == M->UA_TESINT
		IF cTIPO == SZT->ZT_TIPOCLI
			cOPER	:= SZT->ZT_TESINT
			lACHOU	:= .T.
			EXIT
		ENDIF
		DBSKIP()
	END
	IF !lACHOU
		RestArea(aArea) // por Icaro Queiroz em 11 Fev 2015
		RETURN(cTES)
	ENDIF
	
	cTES	:= MaTesInt(2,cOPER,M->UA_CLIENTE,M->UA_LOJA,"C",M->UB_PRODUTO,"UB_TES")
	aCOLS[N][nPOSOP] := cOPER
	aCOLS[N][nPOSCF] := TK273CFO(M->UA_CLIENTE,M->UA_LOJA,cTES)
	
ElseIf cMOD == "AUT" 
	//nPOSTES	:= ASCAN(aHEADER,{ |X| UPPER(ALLTRIM(X[2])) == "C6_TES" })
	//nPOSCF	:= ASCAN(aHEADER,{ |X| UPPER(ALLTRIM(X[2])) == "C6_CF" })
	//nPOSOP	:= ASCAN(aHEADER,{ |X| UPPER(ALLTRIM(X[2])) == "C6_OPER" })
	//cTES	:= aCOLS[N][nPOSTES]
	
	//IF EMPTY(M->C5_TESINT) .OR. M->C5_TIPO <> "N"
	//	RETURN(cTES)
	//ENDIF
	
	cTipo	:= GetAdvFVal("SA1","A1_TIPO",xFilial("SA1")+(cCliente+cLoja),1,"")
	
	DBSELECTAREA("SZT")
	DBSETORDER(1)
	DBGOTOP()
	IF !DBSEEK(XFILIAL("SZT")+cOperSZT)
		RestArea(aArea) // por Icaro Queiroz em 11 Fev 2015
		RETURN(cTES)
	ENDIF
	lACHOU := .F.
	WHILE !EOF() .AND. SZT->ZT_OPERA == cOperSZT
		IF cTipo == SZT->ZT_TIPOCLI
			cOPER	:= SZT->ZT_TESINT
			lACHOU	:= .T.
			EXIT
		ENDIF
		DBSKIP()
	END
	IF !lACHOU
		RestArea(aArea) // por Icaro Queiroz em 11 Fev 2015
		RETURN(cTES)
	ENDIF
	
//	cTES	:= MaTesInt(2,cOPER,cCLiente,cLoja,"C",cProduto,"C6_TES")
	cTES	:= MaTesInt(2,cOPER,cCLiente,cLoja,"C",cProduto)
//	aCOLS[N][nPOSCF] := U_GeraCF(M->C5_CLIENTE,M->C5_LOJACLI,cTES)



ENDIF

RestArea(aArea)
RETURN(cTES)

