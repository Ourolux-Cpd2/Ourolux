#INCLUDE "PROTHEUS.CH"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±º Programa ³ MT160GRPC()³ Autor ³ Claudino P Domingues ³ Data ³ 14/10/13 º±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±º Funcao Padrao ³ MATA160                                                º±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±º Desc.    ³ Ponto de entrada disponibilizado para gravacao de valores   º±± 
±±º          ³ e campos especificos do Pedido de Compra (SC7).             º±±
±±º          ³ Executado durante a geracao do pedido de compra na analise  º±±
±±º          ³ da cotacao.                                                 º±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

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