#INCLUDE "PROTHEUS.CH"

/*
������������������������������������������������������������������������������
��  A010TOK  � Autor: Claudino Pereira Domingues           � Data 07/08/15  ��
������������������������������������������������������������������������������
�� Descricao � LOCALIZA��O: Function A010TudoOK - Fun��o de Valida��o para  ��
�� Padr�o    � inclus�o ou altera��o do Produto.                            ��
��           � EM QUE PONTO: No in�cio das valida��es ap�s a confirma��o    ��
��           � da inclus�o ou altera��o, antes da grava��o do Produto;      ��
��           � deve ser utilizado para valida��es adicionais para a         ��
��           � INCLUS�O ou ALTERA��O do Produto.                            ��
������������������������������������������������������������������������������
�� Descricao � Esse ponto de entrada � utilizado para validar a libera��o   ��
�� Ourolux   � do cadastro de produtos, sempre que � feita a inclus�o de    ��
��           � um novo produto, ou a altera��o, o cadastro precisa ser      ��
��           � liberado.                                                    ��
������������������������������������������������������������������������������
*/

User Function A010TOK()

	Local _lRet    	:= .T.
	Local _cSemVB1 	:= Alltrim(GetMv("FS_SEMVB1"))  // Usuarios que quando incluem / alteram, n�o bloqueia o produto
	Local _cB1Aprv 	:= Alltrim(GetMv("FS_APRVSB1")) // Usuarios que tem acesso para desbloquear produtos N�O REVENDA
	Local _cB1AprR 	:= Alltrim(GetMv("FS_APRVSBR")) // Usuarios que tem acesso para desbloquear produtos REVENDA
	Local _cSB1IA0 	:= Alltrim(GetMv("FS_SB1IA0"))  // Usuarios que podem incluir / alterar produtos Nacionais
	Local _cSB1IA1 	:= Alltrim(GetMv("FS_SB1IA1"))  // Usuarios que podem incluir / alterar produtos Importados
	Local _cSB1IA2 	:= Alltrim(GetMv("FS_SB1IA2"))  // Usuarios que podem incluir / alterar produtos Importados e nacionais
	Local _cSubFam	:= ""                           // Valida��o da utiliza��o de Sub-familia (El�trico / Eletronico)
	
	If !(Upper(Alltrim(cUserName)) $ _cSemVB1)
		If !(Upper(Alltrim(cUserName)) $ _cSB1IA2)  //14/01/2021 WAR
			If Upper(Alltrim(cUserName)) $ _cSB1IA0 .AND. !M->B1_ORIGEM $ '0|3|4|5'
				lRet := .F.
				ApMsgStop('O seu usuario s� tem permiss�o incluir / alterar produtos Nacionais!','A010TOK')
				// Produtos Importados
			ElseIf Upper(Alltrim(cUserName)) $ _cSB1IA1 .AND. !M->B1_ORIGEM $ '1|2|6|7|8'
				_lRet := .F.
				ApMsgStop('O seu usuario s� tem permiss�o incluir / alterar produtos Importados!','A010TOK')
				// Usuarios sem acessos 
			ElseIf !(Upper(Alltrim(cUserName)) $ _cSB1IA0 .OR. Upper(Alltrim(cUserName)) $ _cSB1IA1)
				_lRet := .F.
				ApMsgStop('O seu usuario n�o tem permiss�o para executar tal opera��o!','A010TOK')
			EndIf
		EndIf //14/01/2021 WAR		
	EndIf
		
	If _lRet
		If 	M->B1_XREVEND == "S"
			If !(Upper(Alltrim(cUserName)) $ _cB1AprR)
				Alert("O seu usuario n�o tem permiss�o para alterar produto de Revenda!")
				_lRet := .F.
			EndIf	
		Else		
			If !(Upper(Alltrim(cUserName)) $ _cB1Aprv)
				Alert("O seu usuario n�o tem permiss�o para alterar produto que n�o seja de Revenda!")
				_lRet := .F.
			EndIf
		EndIf
	EndIf
	
	
	If _lRet

		_cSubFam := Posicione("SBM",1,xFilial("SBM") + M->B1_GRUPO,"BM_XSUBFAM") 

		If Trim(_cSubFam) == 'S' .and. Empty(Trim(M->B1_BASE3))
			ApMsgStop('O Grupo ao qual esse produto est� associado necessita que o campo "Sub-Fam�lia" na pasta Cadastrais seja Informado!' +;
				chr (13) + chr (10) +;
				chr (13) + chr (10) +;
				'(A010TOK)' ,'ATEN��O!')
			_lRet := .F. // Bloqueia altera��o
		EndIf
	EndIf	
	
	// I1712-1755 - Customiza��o campos SB1
	// Maur�cio Aureliano - 23/03/2018
	// * * Parte 03 * *
	// Trava para obrigar preenchimento do campo "B1_XREVEND" para produtos do tipo "PA".
	If _lRet
		If Trim(M->B1_TIPO) == 'PA' .and. Empty(Trim(M->B1_XREVEND))
			ApMsgStop('Para produtos do tipo "PA" torna-se obrigat�rio informar o campo "Revenda (SN)" na pasta Cadastrais!' +;
				chr (13) + chr (10) +;
				chr (13) + chr (10) +;
				'(A010TOK)' ,'ATEN��O!')
			_lRet := .F. // Bloqueia altera��o
		EndIf
	EndIf
		
	If _lRet
		If ( Trim(M->B1_RASTRO) == 'S') 
			_lRet := .F.
			ApMsgStop('Opera�ao nao permitida!','A010TOK')
		EndIf
	EndIf
		
Return (_lRet)


User Function _SldPrd(cProduto)

Local _cQuery    := ''
Local _nSaldo    := 0
Local _aArea1   := GetArea()

If Select("_Saldo") > 0
	DbSelectArea("_Saldo")
	Saldo->(DbCloseArea())
EndIf

_cQuery := " SELECT SUM(B2_QATU) As Qtd  "
_cQuery += " FROM " + RetSqlName("SB2") + " SB2 "
_cQuery += " WHERE SB2.D_E_L_E_T_ <> '*' AND " 
_cQuery += " SB2.B2_COD  = '" + cProduto + "'"

dbUseArea( .T., "TOPCONN", TCGENQRY(,,_cQuery), '_Saldo' )

If Saldo->(!Eof())
	
	_nSaldo := _Saldo->Qtd

EndIf

RestArea(_aArea1)
Saldo->(DbCloseArea())

Return(_nSaldo)












