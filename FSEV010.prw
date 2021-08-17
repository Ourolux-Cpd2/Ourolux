#INCLUDE "PROTHEUS.CH"
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �FSEV010   �Autor  �Norbert Waage Junior� Data �  17/03/06   ���
�������������������������������������������������������������������������͹��
���Desc.     �Validacao da inclusao de registros na consulta padrao       ���
�������������������������������������������������������������������������͹��
���Uso       �Eletromega                                                  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function FSEV010(cAlias,nTipo)

Local aArea		:= GetArea()

Default nTipo	:= 2 //Visualizacao

//����������������������������������������������������������Ŀ
//�Verifica se o usuario pertence ao grupo de administradores�
//������������������������������������������������������������
If U_IsAdm()
	If nTipo == 3
		AxInclui(cAlias,0,3)
	Else
		AxVisual(cAlias,(cAlias)->(RECNO()),2)
	EndIf
Else
	ApMsgInfo(IIf(nTipo == 3,"Inclus�o","Visualiza��o")+" restrita aos administradores","Atencao")
EndIf

RestArea(aArea)

Return Nil