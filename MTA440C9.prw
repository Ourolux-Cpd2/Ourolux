#include 'protheus.ch'
#include 'parmtype.ch'

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �MTA440C9  �Autor  �Microsiga           � Data �  03/05/06   ���
�������������������������������������������������������������������������͹��
���Desc.     � Pontos de entrada para atualiza��o do Televendas           ���
���          � Atrav�s do Pedido de Vendas / Faturamento                  ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

// Para atualizar o status do atendimento na libera��o do pedido no SIGAFAT: 
// Pelo ponto de entrada MTA440C9.PRW � possivel fazer uma busca no SUA atrav�s
// do n�mero do pedido liberado (SC9) e atualizar o campo UA_STATUS com 'LIB' (Liberado)

// LIBERACAO DO PEDIDO DE VENDA
// Chamado na gravacao e liberacao do pedido de Venda, apos a atualizacao do acumulados
// do SA1. P.E. para todos os itens do pedido.

User Function MTA440C9()  // 07/07/08

Local aArea  := GETAREA()
	
	XTA440C9()

Return



//-------------------------------------------------------------------- 
/*/{Protheus.doc} XTA440C9
Ponto de entrada executado na grava��o e libera��o do pedido de venda,
ap�s a atualiza��o do acumulados do SA1. Utilizado para libera��o
do pedido de venda cr�dito ou estoque e grava��o da tabela 
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