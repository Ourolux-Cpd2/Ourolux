#include "Protheus.ch"

/*/{Protheus.doc} LP65006D
Relatório específico para departamento comercial.

@author Maurício O. Aureliano
@since 17/07/2018

@obs	Chamado: I1807-1051 - FILIAL 06 INCLUSÃO LP'S

@return	Nil		Sem Retorno.
/*/

User Function LP65006D()

	Local aArea    := GetArea()
	Local cRet	   := ""

	IF SD1->D1_FILIAL="01"
		cRet := "1104030001"
	ElseIF SD1->D1_FILIAL="02"
		cRet := "1104030002"
	ElseIF SD1->D1_FILIAL="03"
		cRet := "1104030001"
	ElseIF SD1->D1_FILIAL="04"
		cRet := "1104030003"
	ElseIF SD1->D1_FILIAL="05"
		cRet := "1104030004"                       
	ElseIF SD1->D1_FILIAL="06"
		cRet := "1104030005"                       
	EndIf
	
	RestArea(aArea)

Return(cRet)
