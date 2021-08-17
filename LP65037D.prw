#include "Protheus.ch"

/*/{Protheus.doc} LP65037D
Relat�rio espec�fico para departamento comercial.

@author Maur�cio O. Aureliano
@since 17/07/2018

@obs	Chamado: I1807-1051 - FILIAL 06 INCLUS�O LP'S

@return	Nil		Sem Retorno.
/*/

User Function LP65037D()

	Local aArea    := GetArea()
	Local cRet	   := ""

	IF SUBS(SD1->D1_CF,2,3)$"353"
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
