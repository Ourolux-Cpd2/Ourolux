#INCLUDE "rwmake.ch"
#INCLUDE "Topconn.ch"
#INCLUDE "Protheus.ch"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±º Programa ³ MT120TEL() ³ Autor ³ Claudino P Domingues ³ Data ³ 04/11/13 º±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±º Funcao Padrao ³ MATA120                                                º±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±º Desc.    ³ Ponto de entrada que adiciona campos no cabecalho da PC.    º±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

User Function MT120TEL()

	Local _aArea    := GetArea()
	Local _aAreaSC7 := SC7->(GetArea())

	Local _oGet1
	Local _oNewDialog := PARAMIXB[1]
	Local _aPosGet    := PARAMIXB[2]
	Local _aObjFol    := PARAMIXB[3]
	Local _nOpcx      := PARAMIXB[4] 
	Local _nReg       := PARAMIXB[5]
	Local aPosOBJPE   := {{33,3,93,677},{96,3,244.5,677},{247.5,3,299.5,677}}

	Public _cDepSC7 := Space(9)

	//******************************************************************
	// Alteracao para trazer departamento do usuario - igual SC.
	// MOA - 09/08/2019 - 12:36HS
	//******************************************************************

	If _nOpcx == 3 .or. _nOpcx == 4 .or. _nOpcx == 6 // 3 - Inclusao 4 - Alteracao, 6 - Copia 

		/*  war 10-02-2020
		If __cUserId == "001958" // Gerente de novos negocios terceirizado - sem cadastro no GPE!
			_cDepSC7 := "000000034"
		ElseIf  __cUserId <> "001958"

			PswSeek(__cUserId)
			_aUser := PswRet()

			If Empty(_aUser[1][22])
				_cDepSC7 := Space(9)
				ApMsgStop("Por favor solicitar ao TI que cadastre a sua matr"+chr(38856)+"ula no seu login!", "MT110TEL" )
			Else
				If !Empty(ALLTRIM(SRA->RA_DEPTO))
					_cDepSC7 := SRA->RA_DEPTO
				Else
					_cDepSC7 := Space(9)
					ApMsgStop("Por favor solicitar ao RH que cadastre o seu departamento no cadastro de funcion"+chr(37288)+"ios!", "MT110TEL" )
				EndIf
			EndIf

		EndIf  war 10-02-2020 */	

		// PROJETO_P12
		// Roberto Souza

		If cVersao == "12"

			@ aPosOBJPE[1][1]+29, _aPosGet[1,5]-12 SAY "Departamento" PIXEL SIZE 35,9 Of _oNewDialog
			@ aPosOBJPE[1][1]+28, _aPosGet[1,6]-25 MSGET _oGet1 VAR _cDepSC7 SIZE 040,006 F3 CpoRetF3("QB_DEPTO","SQB") ;
			Picture PesqPict("SQB","QB_DEPTO") VALID EXISTCPO("SQB",_cDepSC7) OF _oNewDialog PIXEL HASBUTTON

		Else

			@ 45, _aPosGet[1,1] SAY "Departamento" PIXEL SIZE 35,9 Of _oNewDialog
			@ 44, _aPosGet[1,2] MSGET _oGet1 VAR _cDepSC7 SIZE 040,010 F3 CpoRetF3("QB_DEPTO","SQB") ;
			Picture PesqPict("SQB","QB_DEPTO") VALID EXISTCPO("SQB",_cDepSC7) OF _oNewDialog PIXEL HASBUTTON

		EndIf

	Else

		If !Empty(Trim(SC7->C7_XDEPART))
			_cDepSC7 := SC7->C7_XDEPART
		Endif

		If cVersao == "12"

			@ aPosOBJPE[1][1]+29, _aPosGet[1,5]-12 SAY "Departamento" PIXEL SIZE 35,9 Of _oNewDialog
			@ aPosOBJPE[1][1]+28, _aPosGet[1,6]-25 MSGET _cDepSC7  ;
			PICTURE PesqPict('SC7','C7_XDEPART') F3 CpoRetF3('C7_XDEPART');
			WHEN .F. OF _oNewDialog PIXEL SIZE 074,006					

		Else

			@ 45, _aPosGet[1,1] SAY "Departamento" PIXEL SIZE 35,9 Of _oNewDialog
			@ 44, _aPosGet[1,2] MSGET _cDepSC7  ;
			PICTURE PesqPict('SC7','C7_XDEPART') F3 CpoRetF3('C7_XDEPART');
			WHEN .F. OF _oNewDialog PIXEL SIZE 074,006

		EndIf

	EndIf

	RestArea(_aAreaSC7)
	RestArea(_aArea)

Return

/*

#INCLUDE "PROTHEUS.CH"



/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±º Programa ³ MT120TEL() ³ Autor ³ Claudino P Domingues ³ Data ³ 04/11/13 º±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±º Funcao Padrao ³ MATA120                                                º±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±º Desc.    ³ Ponto de entrada que adiciona campos no cabecalho da PC.    º±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß

User Function MT120TEL()

Local _aArea    := GetArea()
Local _aAreaSC7 := SC7->(GetArea())

Local _oGet1
Local _oNewDialog := PARAMIXB[1]
Local _aPosGet    := PARAMIXB[2]
Local _aObjFol    := PARAMIXB[3]
Local _nOpcx      := PARAMIXB[4]
Local _nReg       := PARAMIXB[5]
Local aPosOBJPE   := {{33,3,93,677},{96,3,244.5,677},{247.5,3,299.5,677}}

Public _cDepSC7 := Space(9)

alert('MT120TEL')

If _nOpcx == 3
_cDepSC7 := Space(9)
Else
_cDepSC7 := SC7->C7_XDEPART
EndIf

// PROJETO_P12
// Roberto Souza
If cVersao == "12"

@ aPosOBJPE[1][1]+29, _aPosGet[1,5]-12 SAY "Departamento" PIXEL SIZE 35,9 Of _oNewDialog

@ aPosOBJPE[1][1]+28, _aPosGet[1,6]-25 MSGET _oGet1 VAR _cDepSC7 SIZE 040,006 F3 CpoRetF3("QB_DEPTO","SQB") ;
Picture PesqPict("SQB","QB_DEPTO") VALID EXISTCPO("SQB",_cDepSC7) OF _oNewDialog PIXEL HASBUTTON   

Else

@ 45, _aPosGet[1,1] SAY "Departamento" PIXEL SIZE 35,9 Of _oNewDialog

@ 44, _aPosGet[1,2] MSGET _oGet1 VAR _cDepSC7 SIZE 040,010 F3 CpoRetF3("QB_DEPTO","SQB") ;
Picture PesqPict("SQB","QB_DEPTO") VALID EXISTCPO("SQB",_cDepSC7) OF _oNewDialog PIXEL HASBUTTON   

EndIf

RestArea(_aAreaSC7)    
RestArea(_aArea)

Return                     
*/