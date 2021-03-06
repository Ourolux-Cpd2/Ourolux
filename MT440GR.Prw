/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �MT440GR   �Autor  �Microsiga           � Data �  10/16/08   ���
�������������������������������������������������������������������������͹��
���Desc.     � APOS A CONFIRMACAO DA LIBERACAO MANUAL PV.                 ���
���          � Retorno .T. ou .F.                                         ��� 
���          � SC5 POSICIONADO                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP8                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function MT440GR()

Local lRet := .T.
Local aArea := GetArea()
Local lMae  := U_getMae() == "S"//SuperGetMv("FS_MAE") == "S"

// Implementacao para tratar as importacoes de Pedidos via SFA
If Type("L410Auto")!="U" .And. L410Auto
	If !U_xAuto410()
		Return (.T.)
	EndIf
EndIf

If lMae  
	lRet := .F.
	ApMsgStop('Libera��o de pedidos e bloqueado durante a emissao do pedido mae!', 'MT440GR' )
EndIf
/* Rgras de negocios
If lRet .And. SC5->C5_TIPO == "N"
	//�����������������������������������������������������������
	//� Validate de Pre�o Minimo                                �
	//� Administrador pode liberar pedidos com pre�o Minimo     �
	//�����������������������������������������������������������
 	lRet := U_ValidPrc(2) 
EndIf
*/
//�����������������������������������������������������������
//� Validate Clas Fiscal esta com 3 digitos                 �
//�                                                         �
//�����������������������������������������������������������

If lRet
	lRet := U_VldClas()
EndIf


//�����������������������������������������������������������
//� Validacao NFE                                           �
//�����������������������������������������������������������

If lRet
	lRet := U_vldNFE()
EndIf

RestArea(aArea)
Return(lRet)