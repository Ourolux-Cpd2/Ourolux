#include "Protheus.ch"

/*/{Protheus.doc} LP65040D
Relat�rio espec�fico para departamento comercial.

@author Maur�cio O. Aureliano
@since 17/07/2018

@obs	Chamado: I1807-1051 - FILIAL 06 INCLUS�O LP'S

@return	Nil		Sem Retorno.
/*/

User Function LP65040D()

	Local aArea    := GetArea()
	Local cRet	   := ""

	IF SUBS(SD1->D1_CF,2,3)$"152"
		IF SD1->D1_FILIAL="01"
			cRet := "1104040001"
		ElseIF SD1->D1_FILIAL="02"
			cRet := "1104040002"
		ElseIF SD1->D1_FILIAL="04"
			cRet := "1104040003"
		ElseIF SD1->D1_FILIAL="05"
			cRet := "1104040004"                       
		ElseIF SD1->D1_FILIAL="05"
			cRet := "1104040005"                       
		EndIf
	EndIf
	
	RestArea(aArea)

Return(cRet)
