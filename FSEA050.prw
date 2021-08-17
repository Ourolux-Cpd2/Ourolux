#INCLUDE "PROTHEUS.CH"
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �FSEA050   �Autor  �Norbert Waage Junior� Data �  06/04/06   ���
�������������������������������������������������������������������������͹��
���Desc.     �Encapsulamento da rotina TMKA150, para a utilizacao de      ���
���          �filtro. Exclusao de pedidos                                 ���
�������������������������������������������������������������������������͹��
���Uso       �Eletromega                                                  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function FSEA050

Local aArea		:= GetArea()
Local cVends	:= ""

If lTK271Auto 
	RestArea(aArea)
	Return .T.
EndIf
                
SUA->(DbClearFilter())

//��������������������Ŀ
//�Seleciona vendedores�
//����������������������  
If !(U_IsAdm() .OR. U_IsFree() .Or. lTK271Auto)

	U_ListaVnd(@cVends)
	
	cFiltro		:= "SUA->UA_VEND $ '"+cVends+"'"
	SUA->(DbSetFilter({||&cFiltro},cFiltro))
	
EndIf

TMKA150()
SUA->(DbClearFilter())
RestArea(aArea)

Return Nil