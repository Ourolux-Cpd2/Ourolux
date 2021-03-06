#INCLUDE "PROTHEUS.CH"

/*
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
北 FA080TIT  ? Autor: Claudino Pereira Domingues           ? Data 10/05/16  北
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
北 Descricao ? O PE FA080TIT sera utilizado na confirmacao da tela de baixa 北
北           ? do contas a pagar, antes da gravacao dos dados.              北
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
*/

User Function FA080TIT()

Local lRet     := .F.
//Local cUser    := Upper(Rtrim(cUserName))

/*
Claudino 10/05/16 - Chamado I1604-2235
Regra:
- A lideran鏰 (Denise, Margareth, F醔io e Paulo) tem acesso para baixar em todas as contas, inclusive NDF e PA;
- E as analistas do contas a pagar tem acesso a baixas em todos os bancos e n鉶 tem acesso para baixar NDF e PA. 
*/

// Fun玢o UsrRetName esta retornando o nome completo na P12, foi substituida pela variavel cUserName - Claudino 26/07/2017
//If !(Upper(UsrRetName(__cUserId)) $ GetMv("FS_DIRETOR"))
If !(Upper(Alltrim(cUserName)) $ GetMv("FS_DIRETOR"))
	// Fun玢o UsrRetName esta retornando o nome completo na P12, foi substituida pela variavel cUserName - Claudino 26/07/2017	
	//If (Upper(UsrRetName(__cUserId)) $ GetMv("FS_NOVLDBX"))
	If (Upper(Alltrim(cUserName)) $ GetMv("FS_NOVLDBX"))
		lRet := .T.
	Else
		// Fun玢o UsrRetName esta retornando o nome completo na P12, foi substituida pela variavel cUserName - Claudino 26/07/2017	
		//If (Upper(UsrRetName(__cUserId)) $ GetMv("FS_ANALICP"))
		If (Upper(Alltrim(cUserName)) $ GetMv("FS_ANALICP"))
			If !(SE2->E2_TIPO $ "NDF|PA") 
				lRet := .T.	
			Else
				ApMsgStop("Usuario sem permiss鉶 para baixar NDF/PA! Favor verificar com o seu gestor.","FA080TIT")
			EndIf
		Else
			ApMsgStop("Usuario sem permiss鉶 para executar essa opera玢o! Favor verificar com o seu gestor.","FA080TIT")
		EndIf		
	EndIf		

Else
	lRet := .T.
EndIf

Return (lRet)