#include "Protheus.ch"

/*/{Protheus.doc} LP61060D
Relat?rio espec?fico para departamento comercial.

@author Maur?cio O. Aureliano
@since 17/07/2018

@obs	Chamado: I1807-1051 - FILIAL 06 INCLUS?O LP'S

@return	Nil		Sem Retorno.
/*/

User Function LP61060D()

	Local aArea    := GetArea()
	Local cRet	   := ""

	IF SUBS(SD2->D2_CF,2,3)$"102|106|108|110|403|405|"
		IF SD2->D2_FILIAL="01"
			cRet := "3102020001"
		ElseIF SD2->D2_FILIAL="02"
			cRet := "3102020009"
		ElseIF SD2->D2_FILIAL="04"
			cRet := "3102020017"
		ElseIF SD2->D2_FILIAL="05"
			cRet := "3102020027"  
		ElseIF SD2->D2_FILIAL="06"
			cRet := "3102020035"                     
		EndIf
	EndIf

	RestArea(aArea)

Return(cRet)
