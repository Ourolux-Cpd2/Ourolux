// Primeira altera��o Claudino.
//#include "rwmake.ch"      
 
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �PAGVAL_AP6�Autor  �Microsiga           � Data �  12/27/02   ���
�������������������������������������������������������������������������͹��
���Desc.     �VALOR DO DOCUMENTO  DO CODIGO DE BARRA DA POSICAO 06 - 19,  ���
���          � NO ARQUIVO E DA POSICAO 190 - 204, QUANDO NAO FOR CODIGO DE���
���          �BARRA VAI O VALOR DO SE2									  ���
�������������������������������������������������������������������������͹��
��Uso       �  Eletromega                                                 ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/       

/*
User Function PAGval()        

//���������������������������������������������������������������������Ŀ
//� Declaracao de variaveis utilizadas no programa atraves da funcao    �
//� SetPrvt, que criara somente as variaveis definidas pelo usuario,    �
//� identificando as variaveis publicas do sistema utilizadas no codigo �
//� Incluido pelo assistente de conversao do AP6 IDE                    �
//�����������������������������������������������������������������������

SetPrvt("_VALOR,")


IF !Empty(SE2->E2_CODBAR)

   _Valor := StrZero(Val(SubStr(SE2->E2_CODBAR,6,14)),15)

ELSE
	
   //_Valor :="000000000000000" // Alterado Claudino
     _Valor :=STRZERO(NOROUND(((SE2->E2_SALDO) * 100),2),15)

Endif

Return(_Valor)        
*/

// Segunda altera��o Claudino.

#include "rwmake.ch"      
 
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �PAGVAL_AP6�Autor  �Microsiga           � Data �  12/27/02   ���
�������������������������������������������������������������������������͹��
���Desc.     �VALOR DO DOCUMENTO  DO CODIGO DE BARRA DA POSICAO 06 - 19,  ���
���          � NO ARQUIVO E DA POSICAO 190 - 204, QUANDO NAO FOR CODIGO DE���
���          �BARRA VAI O VALOR DO SE2									  ���
�������������������������������������������������������������������������͹��
��Uso       �  Eletromega                                                 ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function PAGval()        

//���������������������������������������������������������������������Ŀ
//� // Valor de documento                                               �
//� // Valor pagamento = valor doc - dec + acre                         �
//�                                                                     �
//�                                                                     �
//�����������������������������������������������������������������������

SetPrvt("_VALOR")

IF !Empty(SE2->E2_CODBAR)

   	If (SE2->E2_DECRESC > 0)
		
		_Valor := StrZero(Val(SubStr(SE2->E2_CODBAR,6,14)),15)
	
 	Else
		
		If ( Val(SubStr(SE2->E2_CODBAR,10,10)) == 0 )     
	    
	    	_Valor :="000000000000000"
	    
	    Else
	
			_Valor := '0' + SubStr(SE2->E2_CODBAR,6,4) + STRZERO(NOROUND(((SE2->E2_SALDO) * 100),2),10)
		
		EndIf	
      
    EndIf 
	
   //	_Valor := StrZero(Val(SubStr(SE2->E2_CODBAR,6,14)),15)  
   
   //_Valor := '0' + SubStr(SE2->E2_CODBAR,6,4) + STRZERO(NOROUND(((SE2->E2_SALDO) * 100),2),10)  // 02-05-2013
   
   //_Valor := STRZERO( NOROUND( SE2->E2_SALDO * 100,2 ) ,15)
   
      
Else
	
	If SE2->E2_MOEDA == 1
	   
	   _Valor := STRZERO( NOROUND( SE2->E2_SALDO * 100,2 ) ,15)  
	
	Else  
		
	    If !EMPTY(SE2->E2_TXMOEDA)           
		    
			_Valor := STRZERO( NoRound(SE2->E2_SALDO * SE2->E2_TXMOEDA * 100,2) ,15 )
		   
	   	Else
	        
			SM2->(dbSeek(SE2->E2_EMISSAO, .T.)) 
		    
		   	_Valor := STRZERO( NoRound( SE2->E2_SALDO * SM2->M2_MOEDA2 * 100,2) ,15 )    
	    
	    EndIf  
	
	EndIf
	 
EndIf

Return(_Valor)        