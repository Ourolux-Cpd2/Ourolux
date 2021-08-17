#INCLUDE "PROTHEUS.CH"
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �FSEV040   �Autor  �Microsiga           � Data �  04/20/06   ���
�������������������������������������������������������������������������͹��
���Desc.     � Valida�ao do campo UB_PRODUTO SE O PRODUTO ESTA NA TABELA  ���
���          � DO PRE�O DO ATENDIMENTO                                    ���
�������������������������������������������������������������������������͹��
���Uso       � AP8                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function FSEV040()

Local aArea		:= GetArea()
Local aAreaDA1  := DA1->(GetArea())
Local lRet		:= .T.
Local cTabela   := IIF(IsInCallStack("MATA410"),"C5_TABELA","UA_TABELA")
Local cProduto	:= IIF(IsInCallStack("MATA410"),"C6_PRODUTO","UB_PRODUTO")

If !Empty(M->&(cTabela))

	DA1->(DbSetOrder(1)) //DA1_FILIAL+DA1_CODTAB+DA1_CODPRO+DA1_INDLOT+DA1_ITEM
 
 	If !(lRet := DA1->(DbSeek(xFilial("DA1")+M->&(cTabela)+M->&(cProduto))))
		ApMsgStop("O produto selecionado n�o existe na tabela de pre�os selecionada","Aten��o")
	EndIf

EndIf
     
Restarea(aAreaDA1)                   
Restarea(aArea)

Return lRet