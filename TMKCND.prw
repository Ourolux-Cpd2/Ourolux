#INCLUDE "protheus.ch"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �TMKCND     �Autor  �Eletromega         � Data �  09/06/06   ���
�������������������������������������������������������������������������͹��
���Desc.     �Execu��o	Na abertura da tela de condi��o de pagamento      ���
���          � Par�metros	1- C�digo do Atendimento,2- C�digo do Cliente ��� 
���          � 3- C�digo da Loja,4- C�digo do Contato,					  ���
���			 �  5- C�digo do Operador									  ���
���          � 6- Array contendo 4 posi��es:							  ���
���			 �		1- Forma de Pagamento                                 ��� 	
���			 �		2- Data												  ���
���			 �		3- Valor da Parcela em Moeda 						  ���
���			 �		4- Valor da Parcela em % 							  ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP8                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function TMKCND (cCodAtend, cCodCli, cCodLoja, ;
					  cCodCont, cCodOper, aParcelas)
Local lRet := .T.
Local nlen  := 0
/*
nlen := len(aParcelas)

If ! Empty (aParcelas) .AND. INCLUI

	FOR i := 1 TO nlen
		aParcelas[i][3] := 'BOL'
	NEXT

EndIf
 */
Return(lRet)