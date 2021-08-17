#include 'protheus.ch'
#include 'parmtype.ch'

//--------------------------------------------------------------------
/*/{Protheus.doc} MAAVSC5
Ponto de entrada executado ap�s execu��o da rotina de avalia��o dos
eventos do cabe�alho do Pedido de Vendas. Par�metros: array PARAMIXB,
onde item 01 � o c�digo do evento.
[1] Implanta��o do Pedido de Venda
[2] Estorno do Pedido de Venda
[3] Libera��o do Pedido de Venda
[4] Estorno da Libera��o do Pedido de Venda
[5] Prepara��o da Nota Fiscal de Sa�da
[6] Exclus�o da Nota Fiscal de Sa�da
[7] Reavalia��o de Credito (Por Pedido)
[8] Estorno da Reavaliza��o de Cr�dito (Por Pedido)
[9] Libera��o de regras ou verbas
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
                 ,"LIBERACAO" ; //3 - libera��o PED-VENDA
                 ,""          ; //4
                 ,""          ; //5
                 ,"CANCELA"   } //6 - exclus�o DOC-SAIDA

	
	 
	If nEvento == 2 .Or. ; //estorno PED-VENDA
	   nEvento == 3 .Or. ; //libera��o PED-VENDA
	   nEvento == 6        //exclus�o DOC-SAIDA    
	   	
	   	//MSGALERT("ENTROU MAAVSC5 - nEvento = " + CVALTOCHAR(nEvento) - " - a��o = " + aAcao[nEvento])
	   	
	    If FindFunction("U_GeraPR1")
	    	
	    	U_GeraPR1(aAcao[nEvento])
	    	
	    Endif
	    
	Endif
	
	RestArea(aArea)
	
Return(Nil)