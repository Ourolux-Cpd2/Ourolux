#include "rwmake.ch"     

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �PAGANO_AP6�Autor  �Microsiga           � Data �  12/27/02   ���
�������������������������������������������������������������������������͹��
���Desc.     � PROGRAMA P\ SELECIONAR O ANO DO NOSSO NUMERO DO NUMERO CNAB��� 
���          � QUANDO NAO NAO TIVER TEM QUE SER COLOCADO "00"             ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
��Uso       �  Eletromega                                                 ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function Pagano()        

//���������������������������������������������������������������������Ŀ
//� Declaracao de variaveis utilizadas no programa atraves da funcao    �
//� SetPrvt, que criara somente as variaveis definidas pelo usuario,    �
//� identificando as variaveis publicas do sistema utilizadas no codigo �
//� Incluido pelo assistente de conversao do AP5 IDE                    �
//�����������������������������������������������������������������������

SetPrvt("_RETANO,")

  _RETANO := Replicate("0",11)

If Substr(SE2->E2_CODBAR,1,3) == "237"

     _RETANO := StrZero(VAL(SUBS(SE2->E2_CODBAR,26,2)),3)

EndIf
 
Return(_RETANO)       