#INCLUDE "RWMAKE.CH"    

User Function MS520DEL()  

/*
+===========================================================================+
|Consultoria:                Q S   d o   B R A S I L                        |
+---------------------------------------------------------------------------+
|Programa   | MS520DEL	|Autor  | Vitor Lopes        | Data |  25/03/15     |
+---------------------------------------------------------------------------+
|Descricao  | Ponto de entrada no cancelamento da nota fiscal.				|
|           | O mesmo será responsavel por limpar os campos C6_SERVIC e		|
|           | C6_ENDPAD e preenche o campo C6_LOCALIZ para refaturamento.	|
+---------------------------------------------------------------------------+
|Uso        | MP11 - Cliente: OuroLux									    |
+---------------------------------------------------------------------------+
|Solicitante| Sr. Wadih					       						        |
+---------------------------------------------------------------------------+
|Alteracoes | Descrição....:    											|
|           | Solicitante..:    	      									|
|           | Data.........: 			   							        |
|           | Consultor....:											    |
+===========================================================================+
*/ 
                                             
Local aArea    	:= GetArea()

If cFilAnt == "01" .or. cFilAnt == "06"

cNota  := SF2->F2_DOC
cSerie := SF2->F2_SERIE 
cCli   := SF2->F2_CLIENTE
cLoja  := SF2->F2_LOJA    

cPedido := ""


		cQuery := "SELECT C9_PEDIDO FROM "+RETSQLNAME("SC9")+" SC9 " 
	    cQuery += "WHERE SC9.C9_FILIAL = '"+cFilAnt+"' AND SC9.C9_NFISCAL = '"+cNota+"' AND SC9.C9_SERIENF = '"+cSerie+"' AND SC9.C9_CLIENTE = '"+cCli+"' AND SC9.C9_LOJA = '"+cLoja+"'
		
		cQuery 	:= ChangeQuery(cQuery)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"Qrysc9",.T.,.T.) 

        cPedido := Qrysc9->C9_PEDIDO
        
        Qrysc9->(DbCloseArea())
        
        DbSelectArea("SC6")
        DbSetOrder(1)  //C6_FILIAL+C6_NUM+C6_ITEM+C6_PRODUTO                                                                                                                             
        If DbSeek(xFilial("SC6")+cPedido)
        	While cPedido = SC6->C6_NUM
        	  RecLock('SC6',.F.)
	  		 	SC6->C6_SERVIC := ""
	  		 	SC6->C6_ENDPAD := "" 
	  		 	SC6->C6_LOCALIZ := "DOCA"
	 		  MsUnlock()
        	
        	DbSkip()
        	EndDo
        
        
        EndIf 
        
        SC6->(DbCloseArea())
        
        DbSelectArea("SC5")
        DbSetORder(1)   //C5_FILIAL+C5_NUM                                                                                                                                                
        If DbSeek(xFilial("SC5")+cPedido)
        	RecLock('SC5',.F.)
        		SC5->C5_TPCARGA := "2"  
		 	
        	MsUnLock()
        
        
        EndIf
        
        SC5->(DbCloseArea())

EndIf

RestArea(aArea)  

Return