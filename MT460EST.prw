
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �MT460EST  �Autor  �Eletromega          � Data �  09/26/08   ���
�������������������������������������������������������������������������͹��
���Desc.     � O ponto de Entrada e  chamado antes do estorno do SC9      ���
���          � O unico arquivo posicionado no momento e o SC9.            ���
���          � Se retornar .T., indica que continua com                   ���
���          � o estorno da liberacao dos itens do Pedido de Vendas.      ���
���          � Se retornar .F., indica que nao continua com o estorno.    ���
���          �                                                            ���                                                       
�������������������������������������������������������������������������͹��
���Uso       � AP8                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function MT460EST()

Local lRet 	   := .T.
Local aArea	   := GetArea()
Local aAreaSC5 := SC5->(GetArea())
Local lMae     := U_getMae() == "S"//SuperGetMv("FS_MAE") == "S"

DbSelectArea("SC5")
DbSetOrder(1)             // C5_FILIAL, C5_NUM, R_E_C_N_O_ 

If DbSeek(xFilial("SC5") + SC9->C9_PEDIDO ) // Procure no SC5, o n�mero do Pedido
	
	If AllTrim(C5_OK) == "S" .And. lMae 
		lRet := .F.
		ApMsgStop("Estorno proibido. Pedido aguardando faturamento!","MT460EST")
	EndIf
	
EndIf

RestArea(aAreaSC5)
RestArea(aArea)	

Return (lRet)