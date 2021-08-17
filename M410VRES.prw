/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �A410EXC   �Autor  �Microsiga           � Data �  10/16/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Este ponto de entrada � executado ap�s a confirma��o        ���
���          �da elimina��o de residuos no pedido de venda e antes do     ���
���          �inicio da transa��o do mesmo.                               ���
���          �Indica se a transa��o deve ser efetivada ou cancelada.      ���
�������������������������������������������������������������������������͹��
���Uso       � AP8                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function A410VRES()

Local lRet  := .T.
Local lMae  := SuperGetMv("FS_MAE") == "S"
Local lTmk  := U_VerPedCli(SC5->C5_NUM,"TMK")

// Implementacao para tratar as importacoes de Pedidos via SFA
If Type("L410Auto")!="U" .And. L410Auto
	If !U_xAuto410()
		Return (.T.)
	EndIf
EndIf

If lTmk 
	lRet := .F.
   	MsgInfo('Pedido so pode ser alterado no modulo Call Center.') 
ElseIf SC5->C5_OK == "S" .And. !U_IsAdm()
	lRet := .F.
	MsgInfo('Pedido n�o pode ser alterado pois encontra-se aguardando faturamento.')
ElseIf lMae .And. !U_IsAdm()
	lRet := .F.
	MsgInfo('Pedido n�o pode ser alterado durante a emissao do pedido mae.')
EndIf

Return(lRet)