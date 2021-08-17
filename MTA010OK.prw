#INCLUDE "PROTHEUS.CH"

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±± MTA010OK  ³ Autor: Claudino Pereira Domingues           ³ Data 03/05/16  ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±± Descricao ³ LOCALIZAÇÃO: Function A010Deleta - Função de Exclusão do     ±±
±± Padrão    ³ Produto, antes da deleção.                                   ±±
±±           ³ EM QUE PONTO: Na validação após a confirmação da exclusão,   ±±
±±           ³ antes de excluir o produto, após verificar os saldos em      ±±
±±           ³ estoque no arquivo referente (SB2). Deve ser utilizado para  ±±
±±           ³ validações adicionais para a EXCLUSÃO do Produto, para       ±±
±±           ³ verificar algum arquivo/campo criado pelo usuário, para      ±±
±±           ³ validar se o movimento será efetuado ou não.                 ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±± Descricao ³ Esse ponto de entrada é utilizado para validar a exclusão    ±±
±± Ourolux   ³ do cadastro de produtos.                                     ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/

User Function MTA010OK()

	Local _lRet    := .T.
	Local _cSemVB1 := Alltrim(GetMv("FS_SEMVB1"))  // Claudino 03/05/16 - Usuarios que quando incluem / alteram, não bloqueia o produto
	Local _cB1Aprv := Alltrim(GetMv("FS_APRVSB1")) // Claudino 03/05/16 - Usuarios que tem acesso para desbloquear produtos
	Local _cSB1IA0 := Alltrim(GetMv("FS_SB1IA0"))  // Claudino 03/05/16 - Usuarios que podem incluir / alterar produtos Nacionais
	Local _cSB1IA1 := Alltrim(GetMv("FS_SB1IA1"))  // Claudino 03/05/16 - Usuarios que podem incluir / alterar produtos Importados
	
	//If !(Upper(UsrRetName(__cUserId)) $ _cSemVB1)
	If !(Upper(Alltrim(cUserName)) $ _cSemVB1)
		// Claudino 03/05/16 - Usuarios que podem excluir produtos Nacionais
		//If Upper(UsrRetName(__cUserID)) $ _cSB1IA0 .AND. SB1->B1_ORIGEM <> '0'
		If Upper(Alltrim(cUserName)) $ _cSB1IA0 .AND. SB1->B1_ORIGEM <> '0'
	    	_lRet := .F.	
	    	ApMsgStop('O seu usuario só tem permissão para excluir produtos Nacionais!','MTA010OK')
	    // Claudino 03/05/16 - Usuarios que podem excluir produtos Importados
	    //ElseIf Upper(UsrRetName(__cUserID)) $ _cSB1IA1 .AND. SB1->B1_ORIGEM <> '1'
	    ElseIf Upper(Alltrim(cUserName)) $ _cSB1IA1 .AND. SB1->B1_ORIGEM <> '1'
	    	_lRet := .F.
	    	ApMsgStop('O seu usuario só tem permissão para excluir produtos Importados!','MTA010OK')
	    // Claudino 03/05/16 - Usuarios que tem acesso liberado no menu, só que não devem ter acesso
	    //ElseIf !(Upper(UsrRetName(__cUserID)) $ _cSB1IA0 .OR. Upper(UsrRetName(__cUserID)) $ _cSB1IA1)
	    ElseIf !(Upper(Alltrim(cUserName)) $ _cSB1IA0 .OR. Upper(Alltrim(cUserName)) $ _cSB1IA1)
	    	_lRet := .F.
	    	ApMsgStop('O seu usuario não tem permissão para executar tal operação!','MTA010OK')		
	    EndIf
	EndIf
	
Return (_lRet)