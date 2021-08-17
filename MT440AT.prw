#INCLUDE "PROTHEUS.CH"

/*
|-------------------------------------------------------------------------------------------|
| Autor | Claudino Domingues                                              | Data 21/03/2012 |
|-------------------------------------------------------------------------------------------|
| Este ponto de entrada é executado antes da visualização da liberação do pedido de venda e |
| permite ao desenvolvedor impedir a utilização da rotina.                                  |
|-------------------------------------------------------------------------------------------|
| Ponto de Entrada - Caso a condição de pagamento seja 999, o pedido não pode ser liberado. |
|-------------------------------------------------------------------------------------------|
*/

User Function MT440AT()

	Local lRet := .T.
	
	If (SC5->C5_CONDPAG == "999")
	   ApMsgStop('O pedido não pode ser liberado, pois a condição de pagamento é 999!', 'MT440AT')
	   lRet := .F.
	Endif
	
Return(lRet)