#include "rwmake.ch"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �VALCODB�Autor  �WELLINGTON MENDES         � Data �  06/05/11���
�������������������������������������������������������������������������͹��
���Desc.     �Programa para separar as informa��es complementares
REFERENTE A DOC\TED\ CREDITO EM CONTA - PARA CONTEMPLAR PAGAMENTOS
DE CREDITO EM CONTA EM REAL TIME                                          ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       �  Eletromega                                                ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function MODRT()

Private _cRet1    := SEA->EA_MODELO
Private _Retorno  := ""

If _cRet1 $ "01/05" // CREDITO EM CONTA REAL TIME
	_Retorno  := "05"
Elseif _cRet1 $ "41/43" // TED MESMO E OUTRO TITULAR
	_Retorno  := "08"
Elseif _cRet1 $ "03" // DOC - Tratamento incluso em 08-10-2012
	_Retorno  := "03"
Else
	_Retorno :=  "00"
Endif

Return(_Retorno)
