#include "rwmake.ch"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �BolBan�Autor  �Ronaldo Bicudo         � Data �  02/03/10   ���
�������������������������������������������������������������������������͹��
���Desc.     �Programa para valida��o do codigo de barras para pagamentos ���
���          � de boletos Bradesco ou Outros Bancos. posi��es(096-098)    ���
�������������������������������������������������������������������������͹��
���Uso       �  Eletromega                                                ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function BolBan()
Local   _cDigito := SUBSTR(SE2->E2_CODBAR,1,3)      
Local   _cBanco1 := ""        
Local   _cBanco   := "" 

//dbSelectArea("SE2")
//dbSetOrder(1)
//DbSeek(xFilial("SE2")+SE2->E2_NUMBOR+SE2->E2_PREFIXO+SE2->E2_NUM)

If _cDigito = "237" 
	_cBanco1  := SUBSTR(SE2->E2_CODBAR,1,3)    
	_cBanco    := STRZERO(VAL(	_cBanco1),3) 
Else 	                         
    _cBanco  := '000'
Endif

Return(_cBanco)