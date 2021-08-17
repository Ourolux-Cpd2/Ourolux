#include "Protheus.ch"

/*/{Protheus.doc} LP61056C
Relatório específico para departamento comercial.

@author Maurício O. Aureliano
@since 17/07/2018

@obs	Chamado: I1807-1051 - FILIAL 06 INCLUSÃO LP'S

@return	Nil		Sem Retorno.
/*/

User Function LP61056C()

	Local aArea    := GetArea()
	Local cRet	   := ""
	
	IF !SUBS(SD2->D2_CF,2,3)$"102|106|108|110|403|405|"
		IF SD2->D2_FILIAL="01"
			cRet := "2103030009"
		ElseIF SD2->D2_FILIAL="02"
			cRet := "2103030010"
		ElseIF SD2->D2_FILIAL="04"
			cRet := "2103030011"
		ElseIF SD2->D2_FILIAL="05"
			cRet := "2103030012"
		ElseIF SD2->D2_FILIAL="06"
			cRet := "2103030016"
		EndIf
	EndIf

	RestArea(aArea)

Return(cRet)
