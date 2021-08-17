#INCLUDE "RWMAKE.CH"    
/*
+===========================================================================+
|Consultoria:                Q S   d o   B R A S I L                        |
+---------------------------------------------------------------------------+
|Programa   | SUSEREN	|Autor  | Vitor Lopes        | Data |  25/06/14     |
+---------------------------------------------------------------------------+
|Descricao  | Programa para sugerir o codigo de servico de WMS.  	   		|
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

User Function SUSEREN()  

Local aArea    	:= GetArea()      
Local _Return  	:= &(READVAR())  
Local cProdu  	:= ""  
Local cTes		:= "" 
Local cLocal    := ""  

If cTipo == "N" .Or. cTipo == "D"  //Se o documento de entrada for do tipo normal ou devolução

	IF Empty(_Return) //.AND. xOpcao = NIL
	   _Return  := Space(SX3->X3_TAMANHO)
	   Return (_Return)
	Endif
	
	IF !IntDL()
		Return(_Return)
	Endif
	                                                                               
	cProdu	 := aCols[n, aScan(aHeader, {|x| Upper(AllTrim(x[2])) == "D1_COD"})]  
	cTes     := aCols[n, aScan(aHeader, {|x| Upper(Alltrim(x[2])) == "D1_TES"})]
	cLocal   := aCols[n, aScan(aHeader, {|x| Upper(AllTrim(x[2])) == "D1_LOCAL"})]
	
	DBSelectArea("SF4")  
	DBSetOrder(1)
	DBSeek(xFilial("SF4")+cTes)   
	
	DBSelectArea("SB1")  
	DBSetOrder(1)
	If DBSeek(xFilial("SB1")+cProdu)  

		If (SB1->B1_LOCALIZ == "S") .AND. cFilAnt $ ("01/06") .AND. (SF4->F4_ESTOQUE == "S") 
			   	    
			If cLocal == "01" // ALMOXARIFADO 01 - RECEBIMENTO
					

	   			aCols[n,aScan(aHeader, {|x| Upper(AllTrim(x[2])) == "D1_SERVIC"})] 	:= "005" 			 		//Servico 	  
	 			aCols[n,aScan(aHeader, {|x| Upper(AllTrim(x[2])) == "D1_ENDER"})] 	:= PADR("RECEBIMENTO",15)	//Endereço
	 		
	 		Else
	 				//Limpa o campo de serviço e endereço para armazem diferente de 01.
	 				//O sistema irá endereçar automaticamente.
	 		
	 			aCols[n,aScan(aHeader, {|x| Upper(AllTrim(x[2])) == "D1_SERVIC"})] 	:= "" 	//Servico 	  
	 			aCols[n,aScan(aHeader, {|x| Upper(AllTrim(x[2])) == "D1_ENDER"})] 	:= "" 	//Endereço
	 			
	 			
	 		EndIf

	 		/*
		   		
			ElseIf cLocal == "09" // ALMOXARIFADO 09 - DESCARTE - CLAUDINO 05/06/15
		   			
		 		aCols[n,aScan(aHeader, {|x| Upper(AllTrim(x[2])) == "D1_SERVIC"})] 	:= "005" 			 		 	  
	 			aCols[n,aScan(aHeader, {|x| Upper(AllTrim(x[2])) == "D1_ENDER"})] 	:= PADR("DESCARTE",15)				   		   		
				
			ElseIf cLocal == "15" // ALMOXARIFADO 15 - AJUSTES - CLAUDINO 05/06/15
					
				aCols[n,aScan(aHeader, {|x| Upper(AllTrim(x[2])) == "D1_SERVIC"})] 	:= "005" 			 		 	  
	 			aCols[n,aScan(aHeader, {|x| Upper(AllTrim(x[2])) == "D1_ENDER"})] 	:= PADR("AJUSTES",15)	
				
			ElseIf cLocal == "30" // ALMOXARIFADO 30 - RETRABALHO - CLAUDINO 05/06/15
					
				aCols[n,aScan(aHeader, {|x| Upper(AllTrim(x[2])) == "D1_SERVIC"})] 	:= "005" 			 		 	  
	 			aCols[n,aScan(aHeader, {|x| Upper(AllTrim(x[2])) == "D1_ENDER"})] 	:= PADR("RETRABALHO",15)	
				
			ElseIf cLocal == "40" // ALMOXARIFADO 40 - DEVOLUÇÃO - CLAUDINO 05/06/15
					
				aCols[n,aScan(aHeader, {|x| Upper(AllTrim(x[2])) == "D1_SERVIC"})] 	:= "005" 			 		 	  
	 			aCols[n,aScan(aHeader, {|x| Upper(AllTrim(x[2])) == "D1_ENDER"})] 	:= PADR("DEVOLUCAO",15)	
				
			ElseIf cLocal == "50" // ALMOXARIFADO 50 - LABORATORIO - CLAUDINO 05/06/15
					
				aCols[n,aScan(aHeader, {|x| Upper(AllTrim(x[2])) == "D1_SERVIC"})] 	:= "005" 			 		 	  
	 			aCols[n,aScan(aHeader, {|x| Upper(AllTrim(x[2])) == "D1_ENDER"})] 	:= PADR("LABORATORIO",15)	
				
			ElseIf cLocal == "70" // ALMOXARIFADO 70 - QUEBRA - CLAUDINO 05/06/15
					
				aCols[n,aScan(aHeader, {|x| Upper(AllTrim(x[2])) == "D1_SERVIC"})] 	:= "005" 			 		 	  
	 			aCols[n,aScan(aHeader, {|x| Upper(AllTrim(x[2])) == "D1_ENDER"})] 	:= PADR("QUEBRA",15)
	 			
	 		ElseIf cLocal == "98" // ALMOXARIFADO 98 - QUALIDADE - CLAUDINO 05/06/15
					
				aCols[n,aScan(aHeader, {|x| Upper(AllTrim(x[2])) == "D1_SERVIC"})] 	:= "005" 			 		 	  
	 			aCols[n,aScan(aHeader, {|x| Upper(AllTrim(x[2])) == "D1_ENDER"})] 	:= PADR("QUALIDADE",15)	
				
			EndIf            
			*/
		EndIf   
	
	EndIf                                                                         

EndIf		 	        
	
RestArea(aArea)   
	
EVALTRIGGER()

Return(_Return)
