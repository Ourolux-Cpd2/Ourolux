#Include "Protheus.ch"
/*

+===========================================================================+
|Consultoria:                Q S   d o   B R A S I L                        |
+---------------------------------------------------------------------------+
|Programa   | OM200GRV	|Autor  | Vitor Lopes        | Data |  04/07/14     |
+---------------------------------------------------------------------------+
|Descricao  | 														 		|
|           | 															    |
|           |															    |
+---------------------------------------------------------------------------+
|Uso        | MP11 - Cliente: OuroLux									    |
+---------------------------------------------------------------------------+
|Solicitante| 							       						        |
+---------------------------------------------------------------------------+
|Alteracoes | DescriГЦo....:    											|
|           | Solicitante..:    	      									|
|           | Data.........: 			   							        |
|           | Consultor....:											    |
+===========================================================================+

*/ 

User Function OM200GRV()
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Define as variАveis da rotina                                                           Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды 
Local cTransp
Local aAreaAtu	:= GetArea()
Local aAreaSC9	:= SC9->( GetArea() )
Local aAreaSC5	:= SC5->( GetArea() )
Local aAreaSA1	:= SA1->( GetArea() ) 
Local aAreaSA4 	:= SA4->( GetArea() )
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Grava no arquivo temporАrio so dados do pedido                                          Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
//dbSelectArea( "SC9" )
//dbGoTo( TRBSC9->RECNO )

DbSelectArea("SA4")
DbSetORder(1)
If DbSeek(xFilial("SA4")+SC5->C5_TRANSP)
	cTransp := SA4->A4_NREDUZ
EndIf 
SA4->(DbCloseArea())


RecLock( "TRBPED" )
	TRBPED->PED_CIDADE	:= SA1->A1_MUN  
	TRBPED->PED_ESTA	:= SA1->A1_EST
   //	TRBPED->PED_CODTRP  := SA4->A4_COD 
	TRBPED->PED_TRANSP  := cTransp
	TRBPED->PED_SEG  	:= SA1->A1_SATIV1
	TRBPED->PED_DSEG	:= Posicione("SX5",1,xFilial("SX5")+ "T3" + SA1->A1_SATIV1,"X5_DESCRI") 
	
MsUnLock()
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Restaura as Аreas originais                                                             Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
RestArea( aAreaSC5 )
RestArea( aAreaSC9 ) 
RestArea( aAreaSA1 ) 
//RestArea( aAreaSA4 )
RestArea( aAreaAtu )

Return( Nil )
