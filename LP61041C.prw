#include "Protheus.ch"

/*/{Protheus.doc} LP61041C
Relatório específico para departamento comercial.

@author Maurício O. Aureliano
@since 17/07/2018

@obs	Chamado: I1807-1051 - FILIAL 06 INCLUSÃO LP'S

@return	Nil		Sem Retorno.
/*/

User Function LP61041C()

	Local aArea    := GetArea()
	Local cRet	   := ""
	
	IF SUBS(SD2->D2_CF,2,3)$"910"
		IF SD2->D2_FILIAL="01"
			cRet := "2103030004"
		ElseIF SD2->D2_FILIAL="02"
			cRet := "2103030005"
		ElseIF SD2->D2_FILIAL="04"
			cRet := "2103030007"
		ElseIF SD2->D2_FILIAL="05"
			cRet := "2103030013"
		ElseIF SD2->D2_FILIAL="06"
			cRet := "2103030015"
		EndIf
	EndIf

	RestArea(aArea)

Return(cRet)                    
