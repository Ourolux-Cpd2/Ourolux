#Include "Protheus.ch"
/*

+===========================================================================+
|Consultoria:                Q S   d o   B R A S I L                        |
+---------------------------------------------------------------------------+
|Programa   | OM200QRY	|Autor  | Vitor Lopes        | Data |  03/07/14     |
+---------------------------------------------------------------------------+
|Descricao  | Acrescentar filtro por transportadora.				 		|
|           | 															    |
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
User Function OM200QRY()


Local aAreaAtu	:= GetArea()
Local aPergOld	:= {}
Local nQdePerg	:= If( AllTrim( cVersao ) == "P10", 60, 40 )
Local nLoop		:= 0
Local cQry		:= PARAMIXB[1]
Local nChamada	:= PARAMIXB[2]
Local cXcargaDe	:= ""
Local cXcargaAte:= ""
Local cXdocaDe	:= ""
Local cXdocaAte	:= ""

 
	cQry	+= " AND SC5.C5_TRANSP >= '"+mv_par19+"' AND SC5.C5_TRANSP <= '"+mv_par20+"'


RestArea( aAreaAtu )

Return( cQry )