#Include "Protheus.ch"
/*

+===========================================================================+
|Consultoria:                Q S   d o   B R A S I L                        |
+---------------------------------------------------------------------------+
|Programa   | DL200BRW	|Autor  | Vitor Lopes        | Data |  04/07/14     |
+---------------------------------------------------------------------------+
|Descricao  | 														 		|
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

User Function DL200BRW()

Local aAreaAtu	:= GetArea()
Local aCpoBrw	:= PARAMIXB     

aSize( aCpoBrw, Len( aCpoBrw ) + 5 )

aIns( aCpoBrw, 10 )
aCpoBrw[10] := { "PED_ESTA",, OemtoAnsi( "Estado" )} //Acrescenta na posição 10

aIns( aCpoBrw, 11 )  //acrescentando na 2 posicao            
aCpoBrw[11]	:= { "PED_CIDADE",,	OemtoAnsi( "Cidade" )}   //Acrescenta na posicao 11  

//aIns( aCpoBrw, 12)
//aCpoBrw[12] := { "PED_CODTRP",, OemtoAnsi( "Cod. Trnasp")}  

aIns( aCpoBrw, 12 )
aCpoBrw[12] := { "PED_SEG",, OemtoAnsi( "Segmento"	)}


aIns( aCpoBrw, 13 )
aCpoBrw[13] := { "PED_TRANSP",, OemtoAnsi( "Transportadora")}
                      
aIns( aCpoBrw, 14 )
aCpoBrw[14] := { "PED_DSEG",, OemtoAnsi( "Desc. Segmento"	)}


RestArea( aAreaAtu )

Return( aCpoBrw )
