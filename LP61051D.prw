#include "Protheus.ch"

/*/{Protheus.doc} LP61051D
Relatório específico para departamento comercial.

@author Maurício O. Aureliano
@since 17/07/2018

@obs	Chamado: I1807-1051 - FILIAL 06 INCLUSÃO LP'S

@return	Nil		Sem Retorno.
/*/

User Function LP61051D()

	Local aArea    := GetArea()
	Local cRet	   := ""

	IF !SUBS(SD2->D2_CF,2,3)$"102|106|108|110|403|405|"
		IF SD2->D2_FILIAL="01"
			cRet := "3102020006"
		ElseIF SD2->D2_FILIAL="02"
			cRet := "3102020013"
		ElseIF SD2->D2_FILIAL="04"
			cRet := "3102020022"
		ElseIF SD2->D2_FILIAL="05"
			cRet := "3102020032"
		ElseIF SD2->D2_FILIAL="06"
			cRet := "3102020040"                     
		EndIf
	EndIf

	RestArea(aArea)

Return(cRet)
