#include "rwmake.ch"     

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �PAGNOSS   �Autor  �Microsiga           � Data �  12/27/02   ���
�������������������������������������������������������������������������͹��
���Desc.     �PROGRAMA P\ SELECIONAR O ANO DO NOSSO NUMERO DO NUMERO CNAB ���
���          �QUANDO NAO NAO TIVER TEM QUE SER COLOCADO "00"              ���
�������������������������������������������������������������������������͹��
��Uso       �  Eletromega                                                 ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function PAGNOSS()        

//���������������������������������������������������������������������Ŀ
//� Declaracao de variaveis utilizadas no programa atraves da funcao    �
//� SetPrvt, que criara somente as variaveis definidas pelo usuario,    �
//� identificando as variaveis publicas do sistema utilizadas no codigo �
//� Incluido pelo assistente de conversao do AP5 IDE                    �
//�����������������������������������������������������������������������

SetPrvt("_RETNOSS,")


IF SUBSTR(SE2->E2_CODBAR,1,3) == "237"
    
     _RETNOSS :=STRZERO(VAL(SUBSTR(SE2->E2_CODBAR,28,9)),9)

ELSE
	_RETNOSS := "000000000"

ENDIF 
 
Return(_RETNOSS)        