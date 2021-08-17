#INCLUDE "PROTHEUS.CH"

/*
|---------------------------------------------------------|
| Rotina para tratamento no valor de pagamento do boleto, |
| arquivo 237BOL, posição 205 a 219                       |
|---------------------------------------------------------|
*/  

User Function PGTOBOL() 

	Private _nValPag
	// Valor pag = valor doc - dec + acre
	// Valor de pagamento = Valor Doc - Decresc + Acresc
	
	If (SE2->E2_DECRESC > 0)
    
    	_nValPag := STRZERO(NOROUND(((SE2->E2_SALDO - SE2->E2_DECRESC) * 100),2),15)
    	
    Else
    
    	IF ( Val(SubStr(SE2->E2_CODBAR,10,10)) == 0 ) 
    		
    		_nValPag := STRZERO(NOROUND(((SE2->E2_SALDO) * 100),2),15)
    	
    	Else
    		
    		_nValPag := StrZero(Val(SubStr(SE2->E2_CODBAR,10,10)),15)
    		
    	EndIf
    
    EndIf      
   
    //_nValPag := STRZERO(NOROUND(((SE2->E2_SALDO + SE2->E2_ACRESC - SE2->E2_DECRESC) * 100),2),15)  // 02-05-2013
   
   //_nValPag := STRZERO(NOROUND(((SE2->E2_SALDO) * 100),2),15)  
   
	
Return(_nValPag)