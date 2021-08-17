#INCLUDE "RWMAKE.CH"           

/*

+===========================================================================+
|Consultoria:                Q S   d o   B R A S I L                        |
+---------------------------------------------------------------------------+
|Programa   | SUGSERV	|Autor  | Vitor Lopes        | Data |  25/06/14     |
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

User Function SUGSERV()	  

Local aArea    	:= GetArea()
Local _Return  	:= &(READVAR())
Local cAlmox   	:= ""
Local cProdu 	:= ""
Local cTes      := ""

IF Empty(_Return) //.AND. xOpcao = NIL
   _Return  := Space(SX3->X3_TAMANHO)
   Return (_Return)
Endif

IF !IntDL()
	Return(_Return)
Endif
            
cTes	:= aCols[n, aScan(aHeader, {|x| Upper(AllTrim(x[2])) == "C6_TES"})]  
cProdu	:= aCols[n, aScan(aHeader, {|x| Upper(AllTrim(x[2])) == "C6_PRODUTO"})]  

DBSelectArea("SF4")  
DBSetOrder(1)
DBSeek(xFilial("SF4")+cTes)   
	   	
DBSelectArea("SB1")  
DBSetOrder(1)
DBSeek(xFilial("SB1")+cProdu)   

/*
// Claudino Domingues - 04/05/2018 - INICIO OLD

If (SB1->B1_LOCALIZ == "S") .AND. cFilAnt == "01" .AND. (SF4->F4_ESTOQUE == "S") 
		   	
	If Empty(aCols[n, aScan(aHeader, {|x| Upper(AllTrim(x[2])) == "C6_LOCALIZ"})])
		If M->C5_TPCARGA <> "1"  //Condição para entrar apenas uma vez no If.
			M->C5_TPCARGA := "1"  
			M->C5_GERAWMS := "2"  
			 
		EndIf
			 	
		aCols[n, aScan(aHeader, {|x| Upper(AllTrim(x[2])) == "C6_SERVIC"})] := "001" 			 		//Servico 	
		aCols[n, aScan(aHeader, {|x| Upper(AllTrim(x[2])) == "C6_ENDPAD"})] := PADR("DOCA",15) 		 	//Endereço
		//	aCols[n, aScan(aHeader, {|x| Upper(AllTrim(x[2])) == "C6_TPESTR"})]	:= "000001" 	   	 	//Estrutura
	EndIf   	 	 
	 	
EndIf

// Claudino Domingues - 04/05/2018 - FINAL OLD
*/

//*** Data 06/11/2020 - Sol. Fernando Medeiros/Roberto - Incluir Regra para PERMITIR digitar Pedido de Venda sem validar o Saldo de Estoque p/TES Intelig = "03"
//*** Autor Andre Salgado - 06/11/2020
//If M->C5_TESINT <> "09"		//antigo
If !(M->C5_TESINT $ "09,03,13")	//novo

	If (SB1->B1_LOCALIZ == "S") .AND. cFilAnt $ ("01/06") .AND. (SF4->F4_ESTOQUE == "S") 

		If Empty(aCols[n, aScan(aHeader, {|x| Upper(AllTrim(x[2])) == "C6_LOCALIZ"})])
   	
			If M->C5_TPCARGA <> "1"  //Condição para entrar apenas uma vez no If.
				M->C5_TPCARGA := "1"  
				M->C5_GERAWMS := "2"  
			EndIf
	
			aCols[n, aScan(aHeader, {|x| Upper(AllTrim(x[2])) == "C6_SERVIC"})] := "001" 			 	//Servico 	
			aCols[n, aScan(aHeader, {|x| Upper(AllTrim(x[2])) == "C6_ENDPAD"})] := PADR("DOCA",15) 		//Endereço
			//aCols[n, aScan(aHeader, {|x| Upper(AllTrim(x[2])) == "C6_TPESTR"})]	:= "000001" 	   	//Estrutura
		Else
			M->C5_TPCARGA := "2"  
			M->C5_GERAWMS := "2"
			aCols[n, aScan(aHeader, {|x| Upper(AllTrim(x[2])) == "C6_SERVIC"})] := " " 	//Servico 	
			aCols[n, aScan(aHeader, {|x| Upper(AllTrim(x[2])) == "C6_ENDPAD"})] := " " 	//Endereço  	
		EndIf   	 	 
		 	
	EndIf     	 	     
Else
	M->C5_TPCARGA := "2"  
	M->C5_GERAWMS := "2"
	aCols[n, aScan(aHeader, {|x| Upper(AllTrim(x[2])) == "C6_SERVIC"})] := " " 	//Servico 	
	aCols[n, aScan(aHeader, {|x| Upper(AllTrim(x[2])) == "C6_ENDPAD"})] := " " 	//Endereço  	
EndIf
	
RestArea(aArea)   
EVALTRIGGER()
Return (_Return)//_Return     

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////  
