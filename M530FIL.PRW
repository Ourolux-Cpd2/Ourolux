#INCLUDE "rwmake.ch"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษอออออออออออหออออออออออออหอออออออหออออออออออออออออออออออหออออออหอออออออออออออปฑฑ
ฑฑบ Programa  บ M530FIL    บ Autor บ MARCOS GOMES (TAGGS) บ Data บ  18/07/2013 บฑฑ
ฑฑฬอออออออออออุออออออออออออสอออออออสออออออออออออออออออออออสออออออสอออออออออออออนฑฑ
ฑฑบ Descricao บ Filtra os titulos a pagar gerados pela comissao de vendas      บฑฑ
ฑฑบ           บ com objetivo de verificar se ha bloqueio do vendedor.          บฑฑ
ฑฑฬอออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ Uso       บ Clientes PROTHEUS. OURO LUX                                    บฑฑ
ฑฑฬอออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออหอออออออออออออนฑฑ
ฑฑบ   DATA    บ Alteracao                                        บ   Analista  บฑฑ
ฑฑฬอออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออุอออออออออออออนฑฑ
ฑฑบ   /  /    บ -                                                บ             บฑฑ
ฑฑศอออออออออออสออออออออออออออออออออออออออออออออออออออออออออออออออสอออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
USER FUNCTION M530FIL()

LOCAL cFiltro

		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณ Monta a STRING de Filtragem das comissoes                    ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		cFiltro	:= " "
		//cFiltro	+= " E3_X_BLOQ = 'N' .OR. EMPTY(E3_X_BLOQ) " // Comissao bloqueada por falta de entrega de documentos
		
		
		//Conforme reuniao (11/09/2020) Com Sumaia/Wadig/Fernando, informou para Processar o Pagamento da Comissใo 
		//			para vendedores BLOQUEADO, ou seja, serแ processado o Pedido de Compra 
		//Alterado por Andre em 11/09/2020
		//cFiltro	+= " E3_X_BLOQ = 'N' " 

RETURN( cFiltro )
