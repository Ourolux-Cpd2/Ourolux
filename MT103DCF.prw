#INCLUDE "PROTHEUS.CH"

/*---------------------------------------------------------|
| Autor | Claudino Domingues               | Data 22/05/12 | 
|----------------------------------------------------------|
| Ponto de entrada utilizado para habilitar o botão Mais   |
| Informações e incluir campos na aba Informações DANFE da | 
| rotina documento de entrada.                             |
-----------------------------------------------------------*/

User Function MT103DCF()

	Local oDlg       := NIL
	Local oBtOk      := NIL
	Local oDesc      := NIL
	Local oCodigo    := NIL
	Local oCombo     := NIL
	Local cCombo     := SPACE(01)
	Local cCodigo    := SPACE(08)
	Local cDesc      := SPACE(40)
	Local lInclui    := PARAMIXB[1]
	Local lAltera    := PARAMIXB[2]
	Local lVisual    := PARAMIXB[3]
	Local aCamposPar := PARAMIXB[4]
	Local aItensComb := {"","S=Sim","N=Não"}
	
	If(CTIPO == "D")
		
		DEFINE MSDIALOG oDlg TITLE "Motivo de Devolução" FROM 0,0 TO 200,360 OF oMainWnd PIXEL
		
		//LinSup,ColEsq / LinInf,ColDir
		@ 25,06 TO 80,175 LABEL "Mot.Exclusão" OF oDlg PIXEL
		
		@ 10,10 SAY "Frete"                SIZE 45,09 		     OF oDlg PIXEL
		@ 08,25 COMBOBOX oCombo VAR cCombo ITEMS aItensComb SIZE 45,09 OF oDlg PIXEL 
		
		@ 40,10 SAY "Cod.Motivo"  SIZE 45,09		     OF oDlg PIXEL
		@ 38,50 MSGET oCodigo VAR cCodigo   SIZE 45,09 F3 "SAGOUR"  OF oDlg PIXEL
		
		@ 60,10 SAY "Desc.Motivo"           SIZE 45,09 		     OF oDlg PIXEL
		@ 58,50 MSGET oDesc VAR cDesc	    SIZE 120,09		     OF oDlg PIXEL WHEN .F.
		
		@ 85,150 BUTTON oBtOk PROMPT "OK"    SIZE 20,10 ACTION{||oDlg:End()} OF oDlg PIXEL 
			
		If(lVisual)
			cCombo := SF1->F1_XFRETE
			cCodigo := SF1->F1_MOTCANC
			cDesc := Posicione("SAG",1,xFilial("SAG")+SF1->F1_MOTCANC,"AG_DESCPO")
			ACTIVATE MSDIALOG oDlg CENTERED
		EndIf
	
		If(lInclui) .OR. (lAltera) .Or. isInCallStack("U_XMLMT103")
			ACTIVATE MSDIALOG oDlg CENTERED
			aCamposPar:= {{"F1_MOTCANC",cCodigo},{"F1_XFRETE",cCombo}}
		Endif
		
	Endif	
	
Return (aCamposPar)	
