#include "rwmake.ch"      
 
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³  PGTO  ºAutor  ³ Symm Consultoria    º Data ³   18/10/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Valor do Pagamento na geraçao do arquivo de remessa do cnabº±±
±±º          ³ Valor pagamento = valor doc - dec + acre                   º±±   
±±º          ³                                                   		  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±Uso       ³  Eletromega/Ourolux                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
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