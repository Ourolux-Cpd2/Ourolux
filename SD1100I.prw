#include "protheus.ch"
/*

+===========================================================================+
|Consultoria:                Q S   d o   B R A S I L                        |
+---------------------------------------------------------------------------+
|Programa   | SD1100I	|Autor  | Vitor Lopes        | Data |  27/06/14     |
+---------------------------------------------------------------------------+
|Descricao  | Ponto de entrada na gravacao do itens da nf entrada.  		|
|           | Para efetuar o processo de distribuicao automatica classif.   |
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
User Function SD1100I() 
Local aArea    := GetArea()  
Local aAreaSB1 := SB1->(GetArea())
Local aAreaSF4 := SF4->(GetArea()) 
Local aAreaSDA := SDA->(GetArea()) 
Local aAreaSBE := SBE->(GetArea()) 
Local cEndereco:= ""

Local cPed		:= SD1->D1_PEDIDO
Local cProd		:= SD1->D1_COD
Local cItm		:= ''
Local nTot		:= 0

 // Parametro criado para endereco onde sera enderecado o produto      

If FunName() <> 'MATA116'

	If SD1->D1_TIPO == "D" .And. SD1->D1_LOCAL == "40"

		cEndereco:= 'DEVOLUCAO'

        // Distribuicao de produtos automatico.
		DBSelectArea("SB1")
		DBSetOrder(1) //B1_FILIAL+B1_COD
		IF DBSeek(xFilial("SB1")+SD1->D1_COD) .AND. SB1->B1_LOCALIZ = 'S'  
	
			//Verifica se o endereco existe no armazem.
			DBSelectArea("SBE")
			DBSetOrder(1)         //BE_FILIAL+BE_LOCAL+BE_LOCALIZ
			IF !DBSeek(xFilial("SBE")+SD1->D1_LOCAL+cEndereco) 
				MsgAlert("Armazem + Endereço não encontrado. Avise o Administrador do sistema ! Processo de enderecamento automatico nao sera feito.")
				Return Nil		
			EndIf

			//Verifica se a TES controla estoque
	    	DBSelectArea("SF4")
	   		DBSetOrder(1)
	   		IF DBSeek(xFilial("SF4")+SD1->D1_TES) .AND. SF4->F4_ESTOQUE == "S" .AND. IntDL(SD1->D1_COD)     
	   			//Verifica amarracao com a distribuicao.
	   	   		DBSelectArea("SDA")
	   	   		DBSetOrder(1) //DA_FILIAL+DA_PRODUTO+DA_LOCAL+DA_NUMSEQ+DA_DOC+DA_SERIE+DA_CLIFOR+DA_LOJA
	    			IF DBSeek(xFilial("SDA")+SD1->D1_COD+SD1->D1_LOCAL+SD1->D1_NUMSEQ+SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE+SD1->D1_LOJA) .AND. SDA->DA_SALDO > 0
	      
	    		     	A100Distri(SD1->D1_COD,SD1->D1_LOCAL,SD1->D1_NUMSEQ,SD1->D1_DOC,SD1->D1_SERIE,SD1->D1_FORNECE,SD1->D1_LOJA,cEndereco,Nil,SD1->D1_QUANT,SD1->D1_LOTECTL,SD1->D1_NUMLOTE)
	         
	      			Endif   
	   		Endif    
	 
    	EndIf 
    
	EndIf

EndIf
/*
ElseIf FunName() == 'MATA116'

	dbSelectArea( "SC7" )
	SC7->( dbSetOrder(1) )	//C7_FILIAL+C7_NUM+C7_ITEM+C7_SEQUEN

	If SC7->( MsSeek( xFilial( "SC7" ) + cPed ) )
		While SC7->( !Eof()  .And. C7_NUM == cPed )
			cItm := SC7->C7_ITEM
			RecLock( "SC7", .F.)
			Replace C7_ENCER	With 'E'
			Replace C7_SEQUEN	With SC7->C7_ITEM
			Replace C7_QUJE		With SC7->C7_QUANT
			SC7->( MsUnLock() )
			SC7->( dbSkip() )
		Enddo
	EndIf

	If !Empty( SD1->D1_PEDIDO ) .And. !Empty( cItm )
		RecLock( "SD1", .F. )
			Replace D1_ITEMPC	With cItm
		SD1->( MsUnLock() )
	EndIf

EndIf	 
*/      
RestArea(aAreaSBE)
RestArea(aAreaSF4)
RestArea(aAreaSB1)
RestArea(aAreaSDA)
RestArea(aArea)

Return