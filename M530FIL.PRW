#INCLUDE "rwmake.ch"
/*/
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
������������������������������������������������������������������������������ͻ��
��� Programa  � M530FIL    � Autor � MARCOS GOMES (TAGGS) � Data �  18/07/2013 ���
������������������������������������������������������������������������������͹��
��� Descricao � Filtra os titulos a pagar gerados pela comissao de vendas      ���
���           � com objetivo de verificar se ha bloqueio do vendedor.          ���
������������������������������������������������������������������������������͹��
��� Uso       � Clientes PROTHEUS. OURO LUX                                    ���
������������������������������������������������������������������������������͹��
���   DATA    � Alteracao                                        �   Analista  ���
������������������������������������������������������������������������������͹��
���   /  /    � -                                                �             ���
������������������������������������������������������������������������������ͼ��
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
/*/
USER FUNCTION M530FIL()

LOCAL cFiltro

		//��������������������������������������������������������������Ŀ
		//� Monta a STRING de Filtragem das comissoes                    �
		//����������������������������������������������������������������
		cFiltro	:= " "
		//cFiltro	+= " E3_X_BLOQ = 'N' .OR. EMPTY(E3_X_BLOQ) " // Comissao bloqueada por falta de entrega de documentos
		
		
		//Conforme reuniao (11/09/2020) Com Sumaia/Wadig/Fernando, informou para Processar o Pagamento da Comiss�o 
		//			para vendedores BLOQUEADO, ou seja, ser� processado o Pedido de Compra 
		//Alterado por Andre em 11/09/2020
		//cFiltro	+= " E3_X_BLOQ = 'N' " 

RETURN( cFiltro )
