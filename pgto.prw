#include "rwmake.ch"      
 
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �  PGTO  �Autor  � Symm Consultoria    � Data �   18/10/11   ���
�������������������������������������������������������������������������͹��
���Desc.     � Valor do Pagamento na gera�ao do arquivo de remessa do cnab���
���          � Valor pagamento = valor doc - dec + acre                   ���   
���          �                                                   		  ���
�������������������������������������������������������������������������͹��
��Uso       �  Eletromega/Ourolux                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function PGTO()        

SetPrvt("_VALOR")

IF SE2->E2_MOEDA == 1  // REAL

   _Valor := STRZERO(NOROUND(((SE2->E2_SALDO + SE2->E2_ACRESC - SE2->E2_DECRESC) * 100),2),15)
   
   //_Valor := STRZERO(NOROUND((SE2->E2_SALDO * 100),2),15)
   
ELSE

	IF !EMPTY(SE2->E2_TXMOEDA)           	// DOLAR OU ALGUMA OUTRA MOEDA DIFERENTE DE REAL
	    
	   //_Valor := STRZERO((SE2->E2_SALDO * SE2->E2_TXMOEDA)*100,15) // Claudino 22/09/15 
	   _Valor := STRZERO(NoRound(SE2->E2_SALDO * SE2->E2_TXMOEDA * 100,2),15)
	   
    ELSE
        
	    SM2->(dbSeek(SE2->E2_EMISSAO,.T.)) 
	    
	   //_Valor := STRZERO((SE2->E2_SALDO * SM2->M2_MOEDA2)*100,15) // Claudino 22/09/15
	   _Valor := STRZERO(NoRound( SE2->E2_SALDO * SM2->M2_MOEDA2 * 100,2),15)   
    
    ENDIF  
    
EndIf

Return(_Valor)    