#include "rwmake.ch"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �VALCODB�Autor  �WELLINGTON MENDES         � Data �  31/03/11���
�������������������������������������������������������������������������͹��
���Desc.     �Programa para separar as informa��es complementares
REFERENTE A DOC\TED\ CREDITO EM CONTA                                     ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       �  Eletromega                                                ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function Tipodt()

Private _cRet1    := SEA->EA_MODELO
Private _Retorno  := ""

If _cRet1 == "03" // DOC
	_Retorno  := "C"
	
Elseif _cRet1 == "41" // TED OUTRO TITULAR
	_Retorno  := "C"
	
Elseif _cRet1 == "43" // TED MESMO TITULAR
	_Retorno  := "D"
	
	
	
Else
	
	_Retorno :=  SPACE(1)
	
	
Endif


Return(_Retorno)


