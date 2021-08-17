#INCLUDE "PROTHEUS.CH"

User Function F420SOMA()

Local nValorTit := 0          

If SE2->E2_MOEDA == 1
   nValorTit := SE2->E2_SALDO+SE2->E2_SDACRES-SE2->E2_SDDECRE
Else
	If !EMPTY(SE2->E2_TXMOEDA)           
		nValorTit := Round((SE2->E2_SALDO+SE2->E2_SDACRES-SE2->E2_SDDECRE) * SE2->E2_TXMOEDA,2)
	Else
		SM2->(dbSeek(SE2->E2_EMISSAO, .T.)) 
		nValorTit := Round((SE2->E2_SALDO+SE2->E2_SDACRES-SE2->E2_SDDECRE) * SM2->M2_MOEDA2,2)
	EndIf
EndIf   

Return(nValorTit)