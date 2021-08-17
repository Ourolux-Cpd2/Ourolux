#INCLUDE "PROTHEUS.CH"
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �MA030BRW  �Autor  �Norbert Waage Junior� Data �  04/04/06   ���
�������������������������������������������������������������������������͹��
���Desc.     �Ponto de entrada utilizada para o filtro de clientes no     ���
���mBrowse, de acordo com o vendedor logado no sistema                    ���
�������������������������������������������������������������������������͹��
���Uso       �Eletromega                                                  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function MA030BRW

Local aArea		:= GetArea()
Local cVends	:= ""
Local cFiltro	:= ""

If !(U_IsAdm() .OR. U_IsFree())

	U_ListaVnd(@cVends)
	
	If !Empty(cVends)
		cFiltro := "SA1->A1_VEND $ '" + cVends + "'"
	EndIf

	If !Empty(cFiltro)
		cFiltro += " .Or. "
	EndIf

	If U_IsDireto()
		
		cFiltro += "(SA1->A1_VEND == '999999')"
		
	Else
		
		cFiltro += "(SA1->A1_VEND == '000000')"
	
	EndIf

EndIf

RestArea(aArea)

Return cFiltro