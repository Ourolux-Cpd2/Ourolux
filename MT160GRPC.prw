#INCLUDE "PROTHEUS.CH"

/*����������������������������������������������������������������������������
������������������������������������������������������������������������������
��� Programa � MT160GRPC()� Autor � Claudino P Domingues � Data � 14/10/13 ���
������������������������������������������������������������������������������
��� Funcao Padrao � MATA160                                                ���
������������������������������������������������������������������������������
��� Desc.    � Ponto de entrada disponibilizado para gravacao de valores   ��� 
���          � e campos especificos do Pedido de Compra (SC7).             ���
���          � Executado durante a geracao do pedido de compra na analise  ���
���          � da cotacao.                                                 ���
������������������������������������������������������������������������������
����������������������������������������������������������������������������*/

User Function MT160GRPC()    
    
    Local _aAreaSC1 := SC1->(GetArea())
    Local _aAreaSC7 := SC7->(GetArea())
    
    If !Empty(ALLTRIM(SC1->C1_XDEPART))
   		RecLock("SC7",.F.)
			SC7->C7_XDEPART := SC1->C1_XDEPART
		SC7->(MSUnLock())
	EndIf  
    
	SC7->(RestArea(_aAreaSC7))
	SC1->(RestArea(_aAreaSC1))
   
Return Nil