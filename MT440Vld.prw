/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �MT440VLD  �Autor  �Microsiga           � Data �  10/16/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Ponto de entrada para valida��o da execu��o da rotina       ���
���          �de processamento da libera��o automatica de pedido de venda ���
���          �O ponto de entrada inibe a execu��o da rotina.              ��� 
���          �SC5 POSICIONADO									          ���
�������������������������������������������������������������������������͹��
���Uso       � AP8                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function MT440Vld()

Local lRet      := .T.
Local aArea     := GetArea()
Local lMae    	:= U_getMae() == "S"//SuperGetMv("FS_MAE") == "S"
Local aAreaSC6 	:= SC6->(GetArea())
Local nTSitTrb	:= TamSX3("C6_CLASFIS")[1] 

// Implementacao para tratar as importacoes de Pedidos via SFA
If Type("L410Auto")!="U" .And. L410Auto
	Return .T.
EndIf

If lMae  
	lRet := .F.
	ApMsgStop('Libera��o de pedidos e bloqueado durante a emissao do pedido mae!', 'MT440VLD' )
EndIf
/* Rgras de negocios
If lRet .And. SC5->C5_TIPO == "N"
	//�����������������������������������������������������������
	//� Validate de Pre�o Minimo                                �
	//� Administrador pode liberar pedidos com pre�o Minimo     �
	//�����������������������������������������������������������
 	lRet := U_ValidPrc(3) // Administrador pode liberar pedidos com pre�o < Prc Min
EndIf
*/
If lRet
	DbSelectArea("SC6")
	DbSetOrder(1)
	
	If MsSeek(xFilial("SC6") + SC5->C5_NUM)
  		While (SC6->C6_NUM == SC5->C5_NUM) .And. (xFilial("SC6") == SC6->C6_FILIAL)
        	If Empty(SC6->C6_CLASFIS) .Or. Len(Alltrim(SC6->C6_CLASFIS)) < nTSitTrb 
				ApMsgStop( 'A Situa�ao fiscal do produto ' + Alltrim(SC6->C6_PRODUTO)+ 'esta errada!', 'MT440VLD' )
				lRet := .F.
				Exit
			EndIf
      	   	DbSkip()
        EndDo		
	EndIf
EndIf

RestArea(aArea)
RestArea(aAreaSC6)
Return(lRet)