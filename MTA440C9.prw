#include 'protheus.ch'
#include 'parmtype.ch'

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณMTA440C9  บAutor  ณMicrosiga           บ Data ณ  03/05/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Pontos de entrada para atualiza็ใo do Televendas           บฑฑ
ฑฑบ          ณ Atrav้s do Pedido de Vendas / Faturamento                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

// Para atualizar o status do atendimento na libera็ใo do pedido no SIGAFAT: 
// Pelo ponto de entrada MTA440C9.PRW ้ possivel fazer uma busca no SUA atrav้s
// do n๚mero do pedido liberado (SC9) e atualizar o campo UA_STATUS com 'LIB' (Liberado)

// LIBERACAO DO PEDIDO DE VENDA
// Chamado na gravacao e liberacao do pedido de Venda, apos a atualizacao do acumulados
// do SA1. P.E. para todos os itens do pedido.

User Function MTA440C9()  // 07/07/08

Local aArea  := GETAREA()
	
	XTA440C9()

Return



//-------------------------------------------------------------------- 
/*/{Protheus.doc} XTA440C9
Ponto de entrada executado na grava็ใo e libera็ใo do pedido de venda,
ap๓s a atualiza็ใo do acumulados do SA1. Utilizado para libera็ใo
do pedido de venda cr้dito ou estoque e grava็ใo da tabela 
integradora PR1 - Transpofrete
@author Caio Menezes
@since 05/02/2020
@version 1.0
@type function
/*/
//--------------------------------------------------------------------

Static Function XTA440C9()

Local aArea  := GetArea() 

    If FindFunction("U_GeraPR1")
    	
    	U_GeraPR1("LIBERACAO")
    	
    Endif
	
	RestArea(aArea)
    
Return(Nil)