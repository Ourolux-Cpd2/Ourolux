#include "Protheus.ch"

/*/{Protheus.doc} LP64006D
Relatório específico para departamento comercial.

@author Maurício O. Aureliano
@since 17/07/2018

@obs	Chamado: I1807-1051 - FILIAL 06 INCLUSÃO LP'S

@return	Nil		Sem Retorno.
/*/

User Function LP64006D()

	Local aArea    := GetArea()
	Local cRet	   := ""

	IF SUBS(SD1->D1_CF,2,3)$"202|204|410|411"
		IF SD1->D1_FILIAL="01"
			cRet := "1104050002"
		ElseIF SD1->D1_FILIAL="02"
			cRet := "1104050005"
		ElseIF SD1->D1_FILIAL="04"
			cRet := "1104050007"
		ElseIF SD1->D1_FILIAL="05"
			cRet := "1104050009"            
		ElseIF SD1->D1_FILIAL="06"
			cRet := "1104050011"            
		EndIf
	EndIf
	
	RestArea(aArea)

Return(cRet)
