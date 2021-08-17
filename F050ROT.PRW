#include 'protheus.ch'
#include 'parmtype.ch'

//--------------------------------------------------------------------
/*/{Protheus.doc} F050ROT
Adicionar item no menu ações relacionadas da rotina Contas a Pagar
@author Caio
@since 10/02/2020
@version 1.0
@type function
/*/
//--------------------------------------------------------------------

User Function F050ROT()
  
Local aMenu	:= ParamIxb

	AADD(aMenu,{"Faturas x CTE","U_FTOUT006",0,2})
	
Return(aMenu)