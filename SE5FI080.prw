#include 'protheus.ch'
#include 'parmtype.ch'

//--------------------------------------------------------------------
/*/{Protheus.doc} SE5FI080
O ponto de entrada SE5FI080 sera executado para gravar dados complementares da tabela SE5. 
A chamada ocorre apos gravar cada uma das seguintes movimentacoes bancarias.
	-> 	1) Desconto
	-> 	2) Juros
	-> 	3) Multa
	-> 	4) Correção monetária
	->	5) Imposto substituição
	->	6) Valor Pagamento
@author Caio
@since 20/02/2020
@version 1.0 
@type function
/*/
//--------------------------------------------------------------------

User Function SE5FI080()
	
Local cCamposE5 := PARAMIXB[1]
Local oSubFK2   := PARAMIXB[2]

	//****************************************
	//** integração Transpofrete
	//****************************************
	
	If Select("SE2") > 0
		
		GeraPR1()
		
	Endif  

Return(cCamposE5)

//--------------------------------------------------------------------
/*/{Protheus.doc} GeraPR1
Gera PR1 (tabela integração) para informar a Transpofrete do pagamento da fatura
@author Caio
@since 20/02/2020
@version 1.0 
@type function
/*/
//--------------------------------------------------------------------

Static Function GeraPR1()

Local aArea	   := GetArea()
Local lReclock := .F. 
Local cChave   := SE2->(E2_FILIAL+E2_PREFIXO+E2_NUM+E2_FORNECE+E2_LOJA)
	
	If Select("PR1")
		DbSelectArea("PR1")
	Endif
	
	PR1->(dbSetOrder(2))
	
	//MSGALERT("ENTROU GERAPR1")
	
	lReclock := !PR1->(dbSeek(xFilial("PR1")+"SE2"+cChave))
	 
	If PR1->(RecLock("PR1",lReclock))
		
			PR1->PR1_FILIAL := xFilial("PR1")
			PR1->PR1_ALIAS  := "SE2"
			PR1->PR1_RECNO  := SE2->(Recno())
			PR1->PR1_TIPREQ := "2"
			PR1->PR1_DATINT := Date()
			PR1->PR1_HRINT	:= Time()		
			PR1->PR1_STINT  := "P"
			PR1->PR1_CHAVE  := cChave
			
		PR1->(MsUnlock())
		
	Endif 

	RestArea(aArea)
	
Return(Nil)
