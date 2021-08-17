#include "rwmake.ch"       

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �PDTDES_AP6�Autor  �Microsiga           � Data �  12/27/02   ���
�������������������������������������������������������������������������͹��
���Desc.     �PROGRAMA PARA VERIFICAR SE  DESCONTO NO TITULO, CASO        ���
���          �AFIRMATIVO RETORNA A DATA DO DESCONTO, CASO CONTRARIO ZEROS ���
���          �CNAB - REMESSA PARA O BRADESCO                              ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       �  Eletromega                                                ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function Pdtdes()     

//���������������������������������������������������������������������Ŀ
//� Declaracao de variaveis utilizadas no programa atraves da funcao    �
//� SetPrvt, que criara somente as variaveis definidas pelo usuario,    �
//� identificando as variaveis publicas do sistema utilizadas no codigo �
//� Incluido pelo assistente de conversao do AP5 IDE                    �
//�����������������������������������������������������������������������

SetPrvt("_DTDES,")

_DTDES  := "00000000"

IF SUBSTR(SE2->E2_CODBAR,6,14) == "00000000000000" .AND. SUBSTR(SE2->E2_CODBAR,1,3) #"   "

    _DTDES := "00000000"

ELSE 

	_DTDES := IF(SE2->E2_DECRESC == 0,"00000000",DTOS(SE2->E2_VENCREA))

EndIf

Return(_DTDES)       