#include 'protheus.ch'
#include 'parmtype.ch'

//--------------------------------------------------------------------
/*/{Protheus.doc} MAAVSC5
Ponto de entrada executado após execução da rotina de avaliação dos
eventos do cabeçalho do Pedido de Vendas. Parâmetros: array PARAMIXB,
onde item 01 é o código do evento.
[1] Implantação do Pedido de Venda
[2] Estorno do Pedido de Venda
[3] Liberação do Pedido de Venda
[4] Estorno da Liberação do Pedido de Venda
[5] Preparação da Nota Fiscal de Saída
[6] Exclusão da Nota Fiscal de Saída
[7] Reavaliação de Credito (Por Pedido)
[8] Estorno da Reavalização de Crédito (Por Pedido)
[9] Liberação de regras ou verbas
@author Caio Menezes
@since 04/02/2020
@version 1.0
@type function
/*/
//--------------------------------------------------------------------

User Function MAAVSC5()

Local aArea   := GetArea()
Local nEvento := PARAMIXB[1]
Local aAcao   := {""          ; //1
                 ,"ESTORNO"   ; //2 - estorno PED-VENDA
                 ,"LIBERACAO" ; //3 - liberação PED-VENDA
                 ,""          ; //4
                 ,""          ; //5
                 ,"CANCELA"   } //6 - exclusão DOC-SAIDA

	
	 
	If nEvento == 2 .Or. ; //estorno PED-VENDA
	   nEvento == 3 .Or. ; //liberação PED-VENDA
	   nEvento == 6        //exclusão DOC-SAIDA    
	   	
	   	//MSGALERT("ENTROU MAAVSC5 - nEvento = " + CVALTOCHAR(nEvento) - " - ação = " + aAcao[nEvento])
	   	
	    If FindFunction("U_GeraPR1")
	    	
	    	U_GeraPR1(aAcao[nEvento])
	    	
	    Endif
	    
	Endif
	
	RestArea(aArea)
	
Return(Nil)