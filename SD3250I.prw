#INCLUDE 'RWMAKE.CH'
/*

+===========================================================================+
|Consultoria:                Q S   d o   B R A S I L                        |
+---------------------------------------------------------------------------+
|Programa   | SD3250I	|Autor  | Vitor Lopes        | Data |  26/06/14     |
+---------------------------------------------------------------------------+
|Descricao  | Ponto de entrada apos a inclusao do apontamento de producao	|
|           | modelo producao normal. 									    |
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

User Function SD3250I()              
                                                            
Local aArea    := GetArea()
Local aAreaSDA := GetArea()
Local aAreaSB1 := GetArea()
Local cEndereco:= "PRODUCAO" //  endereco onde sera enderecado o produto

If cFilant == "01"
	//Verifica se o endereco existe no armazem.
	DBSelectArea("SBE")
	DBSetOrder(1)         //BE_FILIAL+BE_LOCAL+BE_LOCALIZ
	IF !DBSeek(xFilial("SBE")+'01'+cEndereco)
		MsgAlert("Armazem + Endereço não encontrado. Avise o Administrador do sistema! Processo de enderecamento automatico nao sera feito.")
		Return Nil
	EndIf
	
	DBSelectArea("SDA")
	DBSetOrder(1) //DA_FILIAL+DA_PRODUTO+DA_LOCAL+DA_NUMSEQ+DA_DOC+DA_SERIE+DA_CLIFOR+DA_LOJA
	IF DBSeek(xFilial("SDA")+SD3->D3_COD+SD3->D3_LOCAL+SD3->D3_NUMSEQ+SD3->D3_DOC) .AND. SDA->DA_SALDO > 0
		MsgInfo("O produto será endereçado automaticamente no endereço: "+cEndereco)
		DBSelectArea("SB1")
		DBSetOrder(1) //B1_FILIAL+B1_COD
		IF DBSeek(xFilial("SB1")+SD3->D3_COD) .And. !Empty(cEndereco)
			A100Distri(SD3->D3_COD,SD3->D3_LOCAL,SD3->D3_NUMSEQ,SD3->D3_DOC,Space(03),Space(6),Space(2),cEndereco,Nil,SD3->D3_QUANT,SD3->D3_LOTECTL,SD3->D3_NUMLOTE)
		Endif
	Endif   
	 
EndIf

RestArea(aAreaSB1)
RestArea(aAreaSDA)
RestArea(aArea)

Return