/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �MA410RPV  �Autor  �Microsiga           � Data �  10/17/08   ���
�������������������������������������������������������������������������͹��
���Desc.     � MA410RPV ( < UPAR > ) --> URET                             ���
���          � Retorno Array                                              ��� 
���          � Ponto de entrada � executado em complemento ao calculo     ���
���          � da rentabilidade do pedido de venda. Pode ser utilizado    ���
���          � para altera��o dos valores ou para inibi��o da             ���
���          � demonstra��o dos valores.                                  ���
���          �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP8                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
#INCLUDE "PROTHEUS.CH"
User Function MA410RPV()
Local aRet := {}

If Upper(Rtrim(cUserName)) $ 'ADMINISTRADOR.ROBERTO.CARLOS'
	aRet := paramixb 
EndIf

Return(aRet)
