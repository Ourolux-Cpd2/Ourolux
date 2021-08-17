#include 'protheus.ch'
#include 'parmtype.ch'

/*
+===========================================================================+
|Consultoria:                Q S   d o   B R A S I L                        |
+---------------------------------------------------------------------------+
|Programa   | DLGGATV	|Autor  | Vitor Lopes        | Data |  09/05/17     |
+---------------------------------------------------------------------------+
|Descricao  | Ponto de entrada para nao gravar na SDB atividade corrente.	|
|           | 																|
|           |															    |
+---------------------------------------------------------------------------+
|Uso        | MP11 - Cliente: OuroLux									    |
+---------------------------------------------------------------------------+
|Solicitante| 												       			|
+---------------------------------------------------------------------------+
|Alteracoes | Descrição....:    											|
|           | Solicitante..:    	      									|
|           | Data.........: 			   							        |
|           | Consultor....:											    |
+===========================================================================+
*/ 

************************
User function DLGGATV()
************************


Local lRet   := .T.
Local cAtiv  := PARAMIXB [21]
Local cTaf   := PARAMIXB [20]
Local cEnd   := Substr(PARAMIXB [4],1,2)

If cFilAnt == "01" 

	//Do corredor 01 até 21 nao cria o segundo movimento do reabastecimento.
	If cEnd < "22" .And. cTaf == "001" .And. cAtiv == "008" 
	
		lRet := .F.
	
	
	EndIf
EndIf
	
return(lRet)