#INCLUDE "PROTHEUS.CH"

/*
������������������������������������������������������������������������������
�� MTA010OK  � Autor: Claudino Pereira Domingues           � Data 03/05/16  ��
������������������������������������������������������������������������������
�� Descricao � LOCALIZA��O: Function A010Deleta - Fun��o de Exclus�o do     ��
�� Padr�o    � Produto, antes da dele��o.                                   ��
��           � EM QUE PONTO: Na valida��o ap�s a confirma��o da exclus�o,   ��
��           � antes de excluir o produto, ap�s verificar os saldos em      ��
��           � estoque no arquivo referente (SB2). Deve ser utilizado para  ��
��           � valida��es adicionais para a EXCLUS�O do Produto, para       ��
��           � verificar algum arquivo/campo criado pelo usu�rio, para      ��
��           � validar se o movimento ser� efetuado ou n�o.                 ��
������������������������������������������������������������������������������
�� Descricao � Esse ponto de entrada � utilizado para validar a exclus�o    ��
�� Ourolux   � do cadastro de produtos.                                     ��
������������������������������������������������������������������������������
*/

User Function MTA010OK()

	Local _lRet    := .T.
	Local _cSemVB1 := Alltrim(GetMv("FS_SEMVB1"))  // Claudino 03/05/16 - Usuarios que quando incluem / alteram, n�o bloqueia o produto
	Local _cB1Aprv := Alltrim(GetMv("FS_APRVSB1")) // Claudino 03/05/16 - Usuarios que tem acesso para desbloquear produtos
	Local _cSB1IA0 := Alltrim(GetMv("FS_SB1IA0"))  // Claudino 03/05/16 - Usuarios que podem incluir / alterar produtos Nacionais
	Local _cSB1IA1 := Alltrim(GetMv("FS_SB1IA1"))  // Claudino 03/05/16 - Usuarios que podem incluir / alterar produtos Importados
	
	//If !(Upper(UsrRetName(__cUserId)) $ _cSemVB1)
	If !(Upper(Alltrim(cUserName)) $ _cSemVB1)
		// Claudino 03/05/16 - Usuarios que podem excluir produtos Nacionais
		//If Upper(UsrRetName(__cUserID)) $ _cSB1IA0 .AND. SB1->B1_ORIGEM <> '0'
		If Upper(Alltrim(cUserName)) $ _cSB1IA0 .AND. SB1->B1_ORIGEM <> '0'
	    	_lRet := .F.	
	    	ApMsgStop('O seu usuario s� tem permiss�o para excluir produtos Nacionais!','MTA010OK')
	    // Claudino 03/05/16 - Usuarios que podem excluir produtos Importados
	    //ElseIf Upper(UsrRetName(__cUserID)) $ _cSB1IA1 .AND. SB1->B1_ORIGEM <> '1'
	    ElseIf Upper(Alltrim(cUserName)) $ _cSB1IA1 .AND. SB1->B1_ORIGEM <> '1'
	    	_lRet := .F.
	    	ApMsgStop('O seu usuario s� tem permiss�o para excluir produtos Importados!','MTA010OK')
	    // Claudino 03/05/16 - Usuarios que tem acesso liberado no menu, s� que n�o devem ter acesso
	    //ElseIf !(Upper(UsrRetName(__cUserID)) $ _cSB1IA0 .OR. Upper(UsrRetName(__cUserID)) $ _cSB1IA1)
	    ElseIf !(Upper(Alltrim(cUserName)) $ _cSB1IA0 .OR. Upper(Alltrim(cUserName)) $ _cSB1IA1)
	    	_lRet := .F.
	    	ApMsgStop('O seu usuario n�o tem permiss�o para executar tal opera��o!','MTA010OK')		
	    EndIf
	EndIf
	
Return (_lRet)