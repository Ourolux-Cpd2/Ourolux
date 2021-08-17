/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �M440ACOL  �Autor  �Microsiga           � Data �  04/27/11   ���
�������������������������������������������������������������������������͹��
���Desc.     � Alterar dados no aCols na libera��o de um pedido de vendas ���
���          � Eliminar o desconto no Pedido de vendas                    ���
�������������������������������������������������������������������������͹��
���Uso       � MP 10                                                      ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

#INCLUDE "PROTHEUS.CH"

User Function M440ACOL()

Local nPosPrcVen := GDFieldPos("C6_PRCVEN") //11-12-2017
Local nPosPrUnit := GDFieldPos("C6_PRUNIT") //11-12-2017
Local nPosDesc   := GDFieldPos("C6_DESCONT")
Local nPosValD   := GDFieldPos("C6_VALDESC")

Local nI         := 0

For nI:=1 TO Len(aCols)
	If !aCols[nI][Len(aHeader)+1] 
		aCols[nI][nPosPrUnit] := aCols[nI][nPosPrcVen] //11-12-2017
		aCols[nI][nPosDesc]   := 0
		aCols[nI][nPosValD]   := 0		
	EndIf
Next nI

Return