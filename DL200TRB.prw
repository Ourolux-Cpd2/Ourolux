#Include "Protheus.ch"
/*

+===========================================================================+
|Consultoria:                Q S   d o   B R A S I L                        |
+---------------------------------------------------------------------------+
|Programa   | DL200TRB	|Autor  | Vitor Lopes        | Data |  04/07/14     |
+---------------------------------------------------------------------------+
|Descricao  | 														 		|
|           | 															    |
|           |															    |
+---------------------------------------------------------------------------+
|Uso        | MP11 - Cliente: OuroLux									    |
+---------------------------------------------------------------------------+
|Solicitante| 							       						        |
+---------------------------------------------------------------------------+
|Alteracoes | Descri��o....:    											|
|           | Solicitante..:    	      									|
|           | Data.........: 			   							        |
|           | Consultor....:											    |
+===========================================================================+

*/ 
User Function DL200TRB()
//�����������������������������������������������������������������������������������������Ŀ
//� Define as vari�veis da rotina                                                           �
//�������������������������������������������������������������������������������������������
Local aAreaAtu	:= GetArea()
Local aTamSX3	:= {}       
Local aTamSXS	:= {}  
Local aTamSXT   := {} 
Local aTamSXC	:= {}
Local aCpoTrb	:= PARAMIXB
//�����������������������������������������������������������������������������������������Ŀ
//� Alimenta array com os novos campos a serem exibidos                                     �
//�������������������������������������������������������������������������������������������
aTamSX3	:= TAMSX3( "A1_MUN" )
aAdd( aCpoTrb, { "PED_CIDADE",	aTamSX3[3],	aTamSX3[1],	aTamSX3[2] } ) 
                   
aTamSXS := TAMSX3( "A1_EST" )
aAdd( aCpoTrb, { "PED_ESTA", aTamSXS[3],aTamSXS[1], aTamSXS[2] } ) 

//aTamSXC := TAMSX3( "A4_COD" )
//aAdd( aCpoTrb, { "PED_CODTRP", aTamSXC[3],aTamSXC[1], aTamSXC[2] } )    

aTamSXT := TAMSX3( "A1_SATIV1" )  
aAdd( aCpoTrb, { "PED_SEG", aTamSXT[3],aTamSXT[1], aTamSXt[2] } )


aTamSXT := TAMSX3( "A4_NOME" )  
aAdd( aCpoTrb, { "PED_TRANSP", aTamSXT[3],aTamSXT[1], aTamSXt[2] } )


aTamSXT := TAMSX3( "A4_NOME" )  
aAdd( aCpoTrb, { "PED_DSEG", aTamSXT[3],aTamSXT[1], aTamSXt[2] } )




//�����������������������������������������������������������������������������������������Ŀ
//� Restaura as �reas originais                                                             �
//�������������������������������������������������������������������������������������������
RestArea( aAreaAtu )

Return( aCpoTrb )
