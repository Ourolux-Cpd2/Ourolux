#include "rwmake.ch"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �VALCODB�Autor  �WELLINGTON MENDES         � Data �  31/03/11���
�������������������������������������������������������������������������͹��
���Desc.     �Programa para separar as informa��es complementares
tipo da conta
REFERENTE A DOC\TED\ CREDITO EM CONTA                                    ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       �   Eletromega                                               ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/


User Function Tipoctdt()

Private _cRet1    := SEA->EA_MODELO
Private _Retorno  := ""

If _cRet1 == "01" // DOC
	_Retorno  := SPACE(2)
	
Elseif _cRet1 == "05" // TED OUTRO TITULAR
	_Retorno  := SPACE(2)
	
Else
	
	_Retorno :=  STRZERO(VAL(SA2->A2_XTIPCON),2)
	
	
Endif


Return(_Retorno)
