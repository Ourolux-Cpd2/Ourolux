#INCLUDE "PROTHEUS.CH"

/*
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
北 MTA010OK  ? Autor: Claudino Pereira Domingues           ? Data 03/05/16  北
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
北 Descricao ? LOCALIZA敲O: Function A010Deleta - Fun玢o de Exclus鉶 do     北
北 Padr鉶    ? Produto, antes da dele玢o.                                   北
北           ? EM QUE PONTO: Na valida玢o ap髎 a confirma玢o da exclus鉶,   北
北           ? antes de excluir o produto, ap髎 verificar os saldos em      北
北           ? estoque no arquivo referente (SB2). Deve ser utilizado para  北
北           ? valida珲es adicionais para a EXCLUS肙 do Produto, para       北
北           ? verificar algum arquivo/campo criado pelo usu醨io, para      北
北           ? validar se o movimento ser? efetuado ou n鉶.                 北
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
北 Descricao ? Esse ponto de entrada ? utilizado para validar a exclus鉶    北
北 Ourolux   ? do cadastro de produtos.                                     北
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
*/

User Function MTA010OK()

	Local _lRet    := .T.
	Local _cSemVB1 := Alltrim(GetMv("FS_SEMVB1"))  // Claudino 03/05/16 - Usuarios que quando incluem / alteram, n鉶 bloqueia o produto
	Local _cB1Aprv := Alltrim(GetMv("FS_APRVSB1")) // Claudino 03/05/16 - Usuarios que tem acesso para desbloquear produtos
	Local _cSB1IA0 := Alltrim(GetMv("FS_SB1IA0"))  // Claudino 03/05/16 - Usuarios que podem incluir / alterar produtos Nacionais
	Local _cSB1IA1 := Alltrim(GetMv("FS_SB1IA1"))  // Claudino 03/05/16 - Usuarios que podem incluir / alterar produtos Importados
	
	//If !(Upper(UsrRetName(__cUserId)) $ _cSemVB1)
	If !(Upper(Alltrim(cUserName)) $ _cSemVB1)
		// Claudino 03/05/16 - Usuarios que podem excluir produtos Nacionais
		//If Upper(UsrRetName(__cUserID)) $ _cSB1IA0 .AND. SB1->B1_ORIGEM <> '0'
		If Upper(Alltrim(cUserName)) $ _cSB1IA0 .AND. SB1->B1_ORIGEM <> '0'
	    	_lRet := .F.	
	    	ApMsgStop('O seu usuario s? tem permiss鉶 para excluir produtos Nacionais!','MTA010OK')
	    // Claudino 03/05/16 - Usuarios que podem excluir produtos Importados
	    //ElseIf Upper(UsrRetName(__cUserID)) $ _cSB1IA1 .AND. SB1->B1_ORIGEM <> '1'
	    ElseIf Upper(Alltrim(cUserName)) $ _cSB1IA1 .AND. SB1->B1_ORIGEM <> '1'
	    	_lRet := .F.
	    	ApMsgStop('O seu usuario s? tem permiss鉶 para excluir produtos Importados!','MTA010OK')
	    // Claudino 03/05/16 - Usuarios que tem acesso liberado no menu, s? que n鉶 devem ter acesso
	    //ElseIf !(Upper(UsrRetName(__cUserID)) $ _cSB1IA0 .OR. Upper(UsrRetName(__cUserID)) $ _cSB1IA1)
	    ElseIf !(Upper(Alltrim(cUserName)) $ _cSB1IA0 .OR. Upper(Alltrim(cUserName)) $ _cSB1IA1)
	    	_lRet := .F.
	    	ApMsgStop('O seu usuario n鉶 tem permiss鉶 para executar tal opera玢o!','MTA010OK')		
	    EndIf
	EndIf
	
Return (_lRet)