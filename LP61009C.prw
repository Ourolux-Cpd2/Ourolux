#include "Protheus.ch"

/*/{Protheus.doc} LP61009C
Relat�rio espec�fico para departamento comercial.

@author Maur�cio O. Aureliano
@since 17/07/2018

@obs	Chamado: I1807-1051 - FILIAL 06 INCLUS�O LP'S

@return	Nil		Sem Retorno.
/*/

User Function LP61009C()

	Local aArea    := GetArea()
	Local cRet	   := ""

	IF(SUBS(SD2->D2_CF,2,3)$"102|106|108|110|403|405|")
		IF SD2->D2_FILIAL="01"
			cRet := "3101010001"
		ElseIF SD2->D2_FILIAL="02"
			cRet := "3101010002"
		ElseIF SD2->D2_FILIAL="04"
			cRet := "3101010009"
		ElseIF SD2->D2_FILIAL="05"
			cRet := "3101010013"
		ElseIF SD2->D2_FILIAL="06"
			cRet := "3101010016"
		EndIf
	EndIf

	RestArea(aArea)

Return(cRet)