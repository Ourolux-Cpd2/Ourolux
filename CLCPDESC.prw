#INCLUDE "RWMAKE.CH"
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �CLCPDESC  � Autor � Andr� Bagatini        � Data �10/06/2011���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Calcula o desconto aplicado de acordo com o que est� digita ���
���          �do no campo valor do item no Call Center					  ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �Nenhum                                                      ���
�������������������������������������������������������������������������Ĵ��
���Parametros�Nenhum                                                      ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���          �               �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

User Function CLCPDESC()

Local aArea	   	 	:=	GetArea()
Local nDesc 	 	:= 0
Local aCFOP      	:= {}
Local nPosPrc    	:= aScan(aHeader,{ |x| Upper(AllTrim(x[2])) == "UB_VRUNIT" })
Local nPPrcTab    	:= aScan(aHeader,{ |x| Upper(AllTrim(x[2])) == "UB_PRCTAB" })
Local nPDesc    	:= aScan(aHeader,{ |x| Upper(AllTrim(x[2])) == "UB_UDESC" })
Local nPItem    	:= aScan(aHeader,{ |x| Upper(AllTrim(x[2])) == "UB_ITEM" })
Local nRetorno		:= 0


If aCols[n][nPosPrc] <> aCols[n][nPPrcTab] .And. aCols[n][nPosPrc] < aCols[n][nPPrcTab]
	nDesc := 100 - (( aCols[n][nPosPrc] / aCols[n][nPPrcTab] ) * 100)
	nRetorno :=  Round(nDesc,2)
	aCols [n][nPDesc] := Round(nDesc,2)
Endif
	
RestArea(aArea)

Return(nRetorno)