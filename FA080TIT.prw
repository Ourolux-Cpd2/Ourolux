#INCLUDE "PROTHEUS.CH"

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±± FA080TIT  ³ Autor: Claudino Pereira Domingues           ³ Data 10/05/16  ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±± Descricao ³ O PE FA080TIT sera utilizado na confirmacao da tela de baixa ±±
±±           ³ do contas a pagar, antes da gravacao dos dados.              ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/

User Function FA080TIT()

Local lRet     := .F.
//Local cUser    := Upper(Rtrim(cUserName))

/*
Claudino 10/05/16 - Chamado I1604-2235
Regra:
- A liderança (Denise, Margareth, Fábio e Paulo) tem acesso para baixar em todas as contas, inclusive NDF e PA;
- E as analistas do contas a pagar tem acesso a baixas em todos os bancos e não tem acesso para baixar NDF e PA. 
*/

// Função UsrRetName esta retornando o nome completo na P12, foi substituida pela variavel cUserName - Claudino 26/07/2017
//If !(Upper(UsrRetName(__cUserId)) $ GetMv("FS_DIRETOR"))
If !(Upper(Alltrim(cUserName)) $ GetMv("FS_DIRETOR"))
	// Função UsrRetName esta retornando o nome completo na P12, foi substituida pela variavel cUserName - Claudino 26/07/2017	
	//If (Upper(UsrRetName(__cUserId)) $ GetMv("FS_NOVLDBX"))
	If (Upper(Alltrim(cUserName)) $ GetMv("FS_NOVLDBX"))
		lRet := .T.
	Else
		// Função UsrRetName esta retornando o nome completo na P12, foi substituida pela variavel cUserName - Claudino 26/07/2017	
		//If (Upper(UsrRetName(__cUserId)) $ GetMv("FS_ANALICP"))
		If (Upper(Alltrim(cUserName)) $ GetMv("FS_ANALICP"))
			If !(SE2->E2_TIPO $ "NDF|PA") 
				lRet := .T.	
			Else
				ApMsgStop("Usuario sem permissão para baixar NDF/PA! Favor verificar com o seu gestor.","FA080TIT")
			EndIf
		Else
			ApMsgStop("Usuario sem permissão para executar essa operação! Favor verificar com o seu gestor.","FA080TIT")
		EndIf		
	EndIf		

Else
	lRet := .T.
EndIf

Return (lRet)