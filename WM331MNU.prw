#include "rwmake.ch"
#include "topconn.ch"
#include 'protheus.ch'
#include 'parmtype.ch'
#include 'FWMBrowse.ch'
/*
+===========================================================================+
|Consultoria:                Q S   d o   B R A S I L                        |
+---------------------------------------------------------------------------+
|Programa   | WM331MNU	|Autor  | Vitor Lopes        | Data |  26/03/19     |
+---------------------------------------------------------------------------+
|Descricao  | Ponto de entrada para monitor de Recurso Humano.				|
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
User function WM331MNU()
************************

   ADD OPTION aRotina TITLE "Rec. Humano" 	ACTION "U_RECHUM()" OPERATION 2 ACCESS 0
   
Return(Nil)