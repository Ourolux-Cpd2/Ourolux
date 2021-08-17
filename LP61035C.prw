#include "Protheus.ch"

/*/{Protheus.doc} LP61035C
Relat�rio espec�fico para departamento comercial.

@author Maur�cio O. Aureliano
@since 17/07/2018

@obs	Chamado: I1807-1051 - FILIAL 06 INCLUS�O LP'S

@return	Nil		Sem Retorno.
/*/

User Function LP61035C()

	Local aArea    := GetArea()
	Local cRet	   := ""
	
	IF SUBS(SD2->D2_CF,2,3)$"152|"
		IF SD2->D2_FILIAL="01"
			cRet := "2103030004"
		ElseIF SD2->D2_FILIAL="02"
			cRet := "2103030005"
		ElseIF SD2->D2_FILIAL="04"
			cRet := "2103030007"
		ElseIF SD2->D2_FILIAL="05"
			cRet := "2103030013"
		ElseIF SD2->D2_FILIAL="05"
			cRet := "2103030015"
		EndIf
	EndIf

	RestArea(aArea)

Return(cRet)