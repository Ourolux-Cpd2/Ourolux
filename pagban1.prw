#include "rwmake.ch"        

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �PAGBAN_AP6�Autor  �Microsiga           � Data �  12/27/02   ���
�������������������������������������������������������������������������͹��
���Desc.     �PROGRAMA PARA SEPARAR O BANCO DO FORNECEDOR                 ���
���          �PAGFOR - POSICOES ( 96 - 98 )                               ���
�������������������������������������������������������������������������͹��
��Uso       �  Eletromega                                                 ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function Pagban()       

//���������������������������������������������������������������������Ŀ
//� Declaracao de variaveis utilizadas no programa atraves da funcao    �
//� SetPrvt, que criara somente as variaveis definidas pelo usuario,    �
//� identificando as variaveis publicas do sistema utilizadas no codigo �
//� Incluido pelo assistente de conversao do AP5 IDE                    �
//�����������������������������������������������������������������������

SetPrvt("CALIAS,_BANCO,")


cALIAS  :=  Alias()

IF !EMPTY (SUBSTR(SE2->E2_CODBAR,1,3))
     _BANCO  :=  SUBSTR(SE2->E2_CODBAR,1,3)

else 
     _BANCO := SUBSTR(SA2->A2_BANCO,1,3)

Endif

Return(_BANCO)       