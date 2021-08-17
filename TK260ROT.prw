#INCLUDE "PROTHEUS.CH"
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �Tk260Rot  �Autor  �Norbert Waage Junior� Data �  04/04/06   ���
�������������������������������������������������������������������������͹��
���Desc.     �Ponto de entrada utilizado para o filtro do mBrowse de Pros-���
���          �pects, de acordo com o vendedor                             ���
�������������������������������������������������������������������������͹��
���Uso       �Eletromega                                                  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function TK260ROT()

Local aArea	:= GetArea()
Local aRet	:= {}
Local aIndexSUS := {}
Local cVends:=	""

//��������������������Ŀ
//�Seleciona vendedores�
//����������������������  
If !(U_IsAdm()) 
    If !U_IsFree()  // membros deste grupo nao tem filtro
	
		U_ListaVnd(@cVends)
	
		cFiltro		:= "SUS->US_VEND $ '"+cVends+"'"  
		cFiltro     += " .AND. (SUS->US_STATUS == '4')" // 4 = Stand By 
	Else
		cFiltro     =  " SUS->US_STATUS == '4' "
	EndIf
	
	bFiltraBrw	:= {|| FilBrowse("SUS",@aIndexSUS,@cFiltro)}
	Eval(bFiltraBrw)

EndIf

RestArea(aArea)

Return aRet