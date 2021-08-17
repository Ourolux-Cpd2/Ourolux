/*
������������������������������������������������������������������������������
�� FISFILNFE � Autor: Claudino Pereira Domingues           � Data 04/09/15  ��
������������������������������������������������������������������������������
�� Descricao � Este ponto de entrada foi disponibilizado a fim de permitir  ��
�� Padr�o    � altera��o no filtro do usu�rio administrador na rotina       ��
��           � SPEDNFE.                                                     ��
������������������������������������������������������������������������������
��� ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                     � ��
������������������������������������������������������������������������������
���                                                                       � ��
������������������������������������������������������������������������������
�� Descricao � Esse ponto de entrada � utilizado para filtrar os usuarios   ��
�� Ourolux   � que n�o podem visualizar as notas de importa��o.             ��
������������������������������������������������������������������������������
*/

#INCLUDE "PROTHEUS.CH"

User Function FISFILNFE()

Local _cNOTNFEX := Alltrim(GetMv("FS_NOTNFEX"))
	
If SubStr(MV_PAR01,1,1) == "2" // 2-Entrada
	If Upper(UsrRetName(__cUserID)) $ _cNOTNFEX 
		cCondicao += " .AND. F1_EST <> 'EX' "
    EndIf
EndIf

Return cCondicao

/*

Local cCondicao := ''	
	
If SubStr(MV_PAR01,1,1) == "1"  // 2-Entrada	
	
	cCondicao := "F2_FILIAL=='"+xFilial("SF2")+"'"	

	If !Empty(MV_PAR03)		
		cCondicao += ".AND.F2_SERIE=='"+MV_PAR03+"'"	
	EndIf	

	If SubStr(MV_PAR02,1,1) == "1" //"1-NF Autorizada"		
		cCondicao += ".AND. F2_FIMP$'S' "	
	ElseIf SubStr(MV_PAR02,1,1) == "3" //"3-N�o Autorizadas"		
		cCondicao += ".AND. F2_FIMP$'N' "	
	ElseIf SubStr(MV_PAR02,1,1) == "4" //"4-Transmitidas"		
		cCondicao += ".AND. F2_FIMP$'T' "	
	ElseIf SubStr(MV_PAR02,1,1) == "5" //"5-N�o Transmitidas"		
		cCondicao += ".AND. F2_FIMP$' ' "
	EndIf

ElseIf SubStr(MV_PAR01,1,1) == "2" // 2-Entrada

	cCondicao := "F1_FILIAL=='"+xFilial("SF1")+"' .And. "	
	cCondicao += "F1_FORMUL=='S' "
		
	If Upper(UsrRetName(__cUserID)) $ _cNOTNFEX		
		cCondicao += " .AND. F1_EST <> 'EX' "
	EndIf

	If !Empty(MV_PAR03)		
		cCondicao += ".AND. F1_SERIE=='"+MV_PAR03+"'"	
	EndIf	

	If SubStr(MV_PAR02,1,1) == "1" .And. SF1->(FieldPos("F1_FIMP"))>0 //"1-NF Autorizada"		
			cCondicao += ".AND. F1_FIMP$'S' "	
		ElseIf SubStr(MV_PAR02,1,1) == "3" .And. SF1->(FieldPos("F1_FIMP"))>0 //"3-N�o Autorizadas"		
			cCondicao += ".AND. F1_FIMP$'N' "	
		ElseIf SubStr(MV_PAR02,1,1) == "4" .And. SF1->(FieldPos("F1_FIMP"))>0 //"4-Transmitidas"		
			cCondicao += ".AND. F1_FIMP$'T' "	
		ElseIf SubStr(MV_PAR02,1,1) == "5" .And. SF1->(FieldPos("F1_FIMP"))>0 //"5-N�o Transmitidas"		
			cCondicao += ".AND. F1_FIMP$' ' "					
		EndIf

	EndIf
	
Return cCondicao
*/