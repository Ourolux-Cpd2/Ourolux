// Primeira alteração Claudino.
//#include "rwmake.ch"      
 
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PAGVAL_AP6ºAutor  ³Microsiga           º Data ³  12/27/02   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³VALOR DO DOCUMENTO  DO CODIGO DE BARRA DA POSICAO 06 - 19,  º±±
±±º          ³ NO ARQUIVO E DA POSICAO 190 - 204, QUANDO NAO FOR CODIGO DEº±±
±±º          ³BARRA VAI O VALOR DO SE2									  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±Uso       ³  Eletromega                                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/       

/*
User Function PAGval()        

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de variaveis utilizadas no programa atraves da funcao    ³
//³ SetPrvt, que criara somente as variaveis definidas pelo usuario,    ³
//³ identificando as variaveis publicas do sistema utilizadas no codigo ³
//³ Incluido pelo assistente de conversao do AP6 IDE                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

SetPrvt("_VALOR,")


IF !Empty(SE2->E2_CODBAR)

   _Valor := StrZero(Val(SubStr(SE2->E2_CODBAR,6,14)),15)

ELSE
	
   //_Valor :="000000000000000" // Alterado Claudino
     _Valor :=STRZERO(NOROUND(((SE2->E2_SALDO) * 100),2),15)

Endif

Return(_Valor)        
*/

// Segunda alteração Claudino.

#include "rwmake.ch"      
 
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PAGVAL_AP6ºAutor  ³Microsiga           º Data ³  12/27/02   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³VALOR DO DOCUMENTO  DO CODIGO DE BARRA DA POSICAO 06 - 19,  º±±
±±º          ³ NO ARQUIVO E DA POSICAO 190 - 204, QUANDO NAO FOR CODIGO DEº±±
±±º          ³BARRA VAI O VALOR DO SE2									  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±Uso       ³  Eletromega                                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function PAGval()        

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ // Valor de documento                                               ³
//³ // Valor pagamento = valor doc - dec + acre                         ³
//³                                                                     ³
//³                                                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

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