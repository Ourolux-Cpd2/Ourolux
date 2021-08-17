#INCLUDE "PROTHEUS.CH"

/*
|-------------------------------------------------------------------------------------------|
| Autor | Claudino Domingues                                              | Data 21/03/2012 |
|-------------------------------------------------------------------------------------------|
| Este ponto de entrada � executado antes da visualiza��o da libera��o do pedido de venda e |
| permite ao desenvolvedor impedir a utiliza��o da rotina.                                  |
|-------------------------------------------------------------------------------------------|
| Ponto de Entrada - Caso a condi��o de pagamento seja 999, o pedido n�o pode ser liberado. |
|-------------------------------------------------------------------------------------------|
*/

User Function MT440AT()

	Local lRet := .T.
	
	If (SC5->C5_CONDPAG == "999")
	   ApMsgStop('O pedido n�o pode ser liberado, pois a condi��o de pagamento � 999!', 'MT440AT')
	   lRet := .F.
	Endif
	
Return(lRet)