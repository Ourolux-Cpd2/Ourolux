#include "rwmake.ch"        

User Function PAGcarT()        

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �PAGCART_AP6�Autor  �Microsiga           � Data �  12/27/02   ���
�������������������������������������������������������������������������͹��
���Desc.     �PROGRAMA P\ SELECIONAR A CARTEIRA NO CODIGO DE BARRAS QUANDO���
���          �NAO TIVER TEM QUE SER COLOCADO "00"                         ���
�������������������������������������������������������������������������͹��
���Uso       �  Eletromega                                                ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

//���������������������������������������������������������������������Ŀ
//� Declaracao de variaveis utilizadas no programa atraves da funcao    �
//� SetPrvt, que criara somente as variaveis definidas pelo usuario,    �
//� identificando as variaveis publicas do sistema utilizadas no codigo �
//� Incluido pelo assistente de conversao do AP6 IDE                    �
//�����������������������������������������������������������������������

SetPrvt("_RETCAR,")


If SubStr(SE2->E2_CODBAR,01,3) == "237"

    _RetCar := StrZero(Val(SubStr(SE2->E2_CODBAR,24,2)),3)

Else
	_RetCar := "000"


EndIf

Return(_Retcar)       