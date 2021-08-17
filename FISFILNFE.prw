/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±± FISFILNFE ³ Autor: Claudino Pereira Domingues           ³ Data 04/09/15  ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±± Descricao ³ Este ponto de entrada foi disponibilizado a fim de permitir  ±±
±± Padrão    ³ alteração no filtro do usuário administrador na rotina       ±±
±±           ³ SPEDNFE.                                                     ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±³ ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                     ³ ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±³                                                                       ³ ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±± Descricao ³ Esse ponto de entrada é utilizado para filtrar os usuarios   ±±
±± Ourolux   ³ que não podem visualizar as notas de importação.             ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
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
	ElseIf SubStr(MV_PAR02,1,1) == "3" //"3-Não Autorizadas"		
		cCondicao += ".AND. F2_FIMP$'N' "	
	ElseIf SubStr(MV_PAR02,1,1) == "4" //"4-Transmitidas"		
		cCondicao += ".AND. F2_FIMP$'T' "	
	ElseIf SubStr(MV_PAR02,1,1) == "5" //"5-Não Transmitidas"		
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
		ElseIf SubStr(MV_PAR02,1,1) == "3" .And. SF1->(FieldPos("F1_FIMP"))>0 //"3-Não Autorizadas"		
			cCondicao += ".AND. F1_FIMP$'N' "	
		ElseIf SubStr(MV_PAR02,1,1) == "4" .And. SF1->(FieldPos("F1_FIMP"))>0 //"4-Transmitidas"		
			cCondicao += ".AND. F1_FIMP$'T' "	
		ElseIf SubStr(MV_PAR02,1,1) == "5" .And. SF1->(FieldPos("F1_FIMP"))>0 //"5-Não Transmitidas"		
			cCondicao += ".AND. F1_FIMP$' ' "					
		EndIf

	EndIf
	
Return cCondicao
*/