#include "rwmake.ch"      

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �CODMOE    �Autor  �Microsiga           � Data �  12/27/02   ���
�������������������������������������������������������������������������͹��
���Desc.     �Este programa tem como objetivo pegar o digito do codigo de ���
���          �barras referente a moeda                                    ���
�������������������������������������������������������������������������͹��
��Uso       �  Eletromega                                                 ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function CODMOE()        

IF !EMPTY (SE2->E2_CODBAR)
     
    _CODMOE := SUBS(SE2->E2_CODBAR,4,1)    

ELSE

	_CODMOE := " "

ENDIF

Return(_CODMOE)