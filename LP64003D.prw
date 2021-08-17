#include "Protheus.ch"

/*/{Protheus.doc} LP64003D
Relatório específico para departamento comercial.

@author Maurício O. Aureliano
@since 17/07/2018

@obs	Chamado: I1807-1051 - FILIAL 06 INCLUSÃO LP'S

@return	Nil		Sem Retorno.
/*/

User Function LP64003D()

	Local aArea    := GetArea()
	Local cRet	   := ""

	IF SUBS(SD1->D1_CF,2,3)$"202|204|410|411"
		IF SD1->D1_FILIAL="01"
			cRet := "1104050001"
		ElseIF SD1->D1_FILIAL="02"
			cRet := "1104050004"
		ElseIF SD1->D1_FILIAL="04"
			cRet := "1104050006"
		ElseIF SD1->D1_FILIAL="05"
			cRet := "1104050008"            
		ElseIF SD1->D1_FILIAL="06"
			cRet := "1104050010"                            
		EndIf
	EndIf

	RestArea(aArea)

Return(cRet)
