#INCLUDE "PROTHEUS.CH"

***********************
User Function OM200US()
***********************

Local aRotina := ParamIxb

Aadd(aRotina, {OemToAnsi("Informar N� Volume"), "U_XVOLPED", 0 , 2, 0, NIL})

Return(aRotina)
