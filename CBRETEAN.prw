#INCLUDE 'RWMAKE.CH'
#INCLUDE 'APVT100.CH'
#INCLUDE "TOPCONN.CH"
#include "Fileio.ch"
/*

+===========================================================================+
|Consultoria:                Q S   d o   B R A S I L                        |
+---------------------------------------------------------------------------+
|Programa   | CBRETEAN	|Autor  | Vitor Lopes        | Data |  25/06/14     |
+---------------------------------------------------------------------------+
|Descricao  | Ponto de entrada no momento da separacao/enderecamento 		|
|           | para validar o  codigo de barra  								|
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
User Function CBRETEAN()
Local lRet     := .F.
Local aRet     := {}
Local aArea    := GetArea()
Local aAreaSB1 := SB1->(GetArea())
Local aAreaSLK := SLK->(GetArea())
Local aAreaSDA := SDA->(GetArea())
Local cCodBar  := Alltrim(PARAMIXB[1]) 
Local cDun	   := Alltrim(PARAMIXB[1])	   
Local cPdrbar  := Alltrim(PARAMIXB[1])
Local cPdrbar2 := Alltrim(PARAMIXB[1])
Local cProduto := Space(15)
Local cLote    := Space(10)
Local dDtValid := CTOD("  /  /  ")
Local nQtde    := 1      
Local lCodMaio := .F.
Local cEan
Local cDig            



IF Empty(cCodBar)        

	Return (aRet)
Endif             


If len(cCodBar) > 15     	
	lCodMaio := .T.
EndIf               


             
If  !lCodMaio 
	// Pesquisa pelo B1_CODBAR  etiqueta   7897752778379   
	cEan    := Substr(cCodBar,1,12)
	cDig    := Substr(cCodBar,13,1)
	cCodBar := cEan + '-' + cDig
	DBSelectArea("SB1")
	DBSetOrder(5) //B1_FILIAL+B1_CODBAR
	DBSeek(xFilial("SB1")+PADR(cCodBar,15)) 
		While !EOF() .And. (cCodBar) == ALLTRIM(SB1->B1_CODBAR) 
   			If SB1->B1_MSBLQL = '2'	
   				cProduto:= SB1->B1_COD
   				lRet := .T.
   			EndIf  
   	    dbSkip()
   	    End  
    
		// Pesquisa pelo B1_CODBAR etiqueta 7897752778379   
   	IF !lRet   	
	                                                       
   	   	DBSelectArea("SB1")
   		DBSetOrder(5) //B1_FILIAL+B1_CODBAR
		IF DBSeek(xFilial("SB1")+PADR(cPdrbar2,15)) 
	      lRet     := .T.
	      cProduto := SB1->B1_COD
	    EndIf
	Endif 
	 
	        
	// Pesquisa pelo B1_DUN14
	IF !lRet
	   DBSelectArea("SB1")
	   DBSetOrder(11) //B1_FILIAL+B1_XCODBAR
	   IF DBSeek(xFilial("SB1")+PADR(cDun,15))
	      lRet     := .T.
	      cProduto := SB1->B1_COD
	   Endif
	Endif    
	
	// Pesquisa pelo B1_COD
	IF !lRet
	   DBSelectArea("SB1")
	   DBSetOrder(1) //B1_FILIAL+B1_COD
	   IF DBSeek(xFilial("SB1")+PADR(cPdrbar,15))
	      lRet     := .T.
	      cProduto := SB1->B1_COD
	   Endif
	Endif      

	// Pesquisa pela Tabela de Codigos de Barra
	IF !lRet
	   DBSelectArea("SLK")
	   DBSetOrder(1) //1 LK_FILIAL+LK_CODBAR                            
	   IF DBSeek(xFilial("SLK")+PADR(cCodBar,15))
	      lRet     := .T.
	      cProduto := SLK->LK_CODIGO
	   Endif
	Endif
EndIf
                                                                   
If lCodMaio     
	If FunName() = "DLGV001" //Separacao utilizando pedido ou carga Wms	                                                  
		cProduto 	:= Substr(cCodBar,1,15)
		cLote 		:= Substr(cCodBar,16,10)//Space(10)		//
		nQtde 		:= 0  					//Substr(cCodBar,26,6)
		lRet		:= .T.        
  	Elseif FunName() = "ACDV060" //Enderecamento pelo acd retorna 1 para informar a qtde a enderecar via coletor   
		cProduto 	:= Substr(cCodBar,1,15)
		cLote 		:= Substr(cCodBar,16,10) //Space(10)		//
		nQtde 		:= 1 		                            
		lRet		:= .T.                                   
		
	Elseif FunName() = "ACDV035"// Inventario pelo ACD
		cProduto 	:= Substr(cCodBar,1,15)
		cLote 		:= Substr(cCodBar,16,10) //Space(10)		//
		nQtde 		:= 1 		                            
		lRet		:= .T.   
		
	Elseif FunName() = "ACDV038"// Inventario pelo ACD
		cProduto 	:= Substr(cCodBar,1,15)
		cLote 		:= Substr(cCodBar,16,10) //Space(10)		//
		nQtde 		:= 1 		                            
		lRet		:= .T.    
	
	Elseif FunName() = "ACDV166" //Separacao utilizando pelo acd
		cProduto 	:= Substr(cCodBar,1,15)
		cLote 		:= Substr(cCodBar,16,10) //Space(10)		//
		nQtde 		:= 1 		                            
		lRet		:= .T.  
	Elseif FunName() = "ACDV150" //transferencia de endereco pelo acd	
		cProduto 	:= Substr(cCodBar,1,15)
		cLote 		:= Substr(cCodBar,16,10)//Space(10)		//
		nQtde 		:= 1  					
		lRet		:= .T.   
	Else		  
		cProduto 	:= Substr(cCodBar,1,15)
		cLote 		:= Substr(cCodBar,16,10)  //Space(10)		//
		nQtde 		:= 1  					//Substr(cCodBar,26,6)
		lRet		:= .T.
	EndIf                         	
	
Else  //Tratamento para qdo informar o produto separado do lote, considerendo wms e acd
                                                                                                              
  	If FunName() = "ACDV060" //Enderecamento pelo acd retorna 1 para informar a qtde a enderecar via coletor   
		nQtde 	:= 1                                                                                             
	Elseif 	FunName() = "ACDV035"//Inventario ACD
		nQtde	:= 1	   
	ElseIf  FunName() = "ACDV038" //Invetario por endereço.
		nQtde   := 1
	Elseif FunName() = "ACDV166" //Separacao utilizando pelo acd
		nQtde 	:= 1  			                                  	
	Elseif FunName() = "ACDV150" //Separacao transferencia de endereco pelo acd
		nQtde 	:= 1  					
	Elseif FunName() = "DLGV001" //Separacao utilizando wms		
		nQtde 	:= 0  			
	Else
		nQtde	:= 0   //Retorna 0
	EndIf    

Endif   
       
IF lRet
   //codigo do produto,quantidade,lote,data de validade, numero de serie
   AAdd(aRet,PADR(cProduto,15))    	 //Codigo do produto
   AAdd(aRet,nQtde)					 //Quantidade
   AAdd(aRet,PADR(cLote,10))       	 //Lote
   AAdd(aRet,dDtValid)        		 //Data de validade
   AAdd(aRet,Space(20))       		 //Numero de Serie
Endif             
                  
RestArea(aAreaSDA)
RestArea(aAreaSB1)
RestArea(aAreaSLK)
RestArea(aArea)

Return (aRet)
