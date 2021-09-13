#INCLUDE "RWMAKE.CH"        
#INCLUDE 'APVT100.CH'            
#INCLUDE "TOPCONN.CH"
/*
+===========================================================================+
|Consultoria:                Q S   d o   B R A S I L                        |
+---------------------------------------------------------------------------+
|Programa   | DLGV001G	|Autor  | Vitor Lopes        | Data |  25/06/14     |
+---------------------------------------------------------------------------+
|Descricao  | Ponto de entrada antes e após a separação do serviço wms  	|
|           | mostra o número da carga que esta sendo separada.				|
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
************************                                
User Function DLGV001G()
************************    
Local aArea    := GetArea()
Local aSDBArea := SDB->(GetArea())
Local lOK      := .T.


//Servico Gru separacao carga apresentar numero da carga       
If SDB->DB_SERVIC == "001" .AND. SDB->DB_TAREFA == "002" .AND. cFilant == "01" 
	DLVTAviso('Carga Gru','Numero: '+ SDB->DB_CARGA)                     	

ElseIf SDB->DB_SERVIC == "001" .AND. SDB->DB_TAREFA == "002" .AND. cFilant == "06" 
	DLVTAviso('Carga SC','Numero: '+ SDB->DB_CARGA) 

Endif	
                                                                                                                          

RestArea(aSDBArea)
RestArea(aArea)

Return