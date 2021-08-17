#INCLUDE "rwmake.ch" 
#INCLUDE "Protheus.ch"  

/*

+===========================================================================+
|Consultoria:                Q S   d o   B R A S I L                        |
+---------------------------------------------------------------------------+
|Programa   | DLLASTRO	|Autor  | Vitor Lopes        | Data |  26/06/14     |
+---------------------------------------------------------------------------+
|Descricao  | Ajuste no Lastro do palete para produtos que sofrem variações	|
|           | no tamanho da caixa.										    |
|           |															    |
+---------------------------------------------------------------------------+
|Uso        | MP11 - Cliente: OuroLux									    |
+---------------------------------------------------------------------------+
|Solicitante| 							       						        |
+---------------------------------------------------------------------------+
|Alteracoes | Descrição....:    											|
|           | Solicitante..:    	      									|
|           | Data.........: 			   							        |
|           | Consultor....:											    |
+===========================================================================+

*/ 

User Function DLLASTRO() 

Local nLastroPE 

If DCF->DCF_SERVIC == "001" .Or. DCF->DCF_SERVIC == "003"

                                      
	nLastroPE := 1    
	
EndIf

Return(nLastroPE)