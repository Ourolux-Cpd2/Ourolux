#INCLUDE "PROTHEUS.CH"

/*������������������������������������������������������������������������������
����������������������������������������������������������������������������Ŀ��
���Descricao  � Funcao responsavel por montar a consulta F3 customizada do   ���
���           | cadastro de condicoes de pagamento.                          ���
�����������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������*/

User Function FSEC002()

/*��������������������������������������������������������������Ŀ
�DECLARACAO DE VARIAVEIS ESCOPO LOCAL                            �
�aCond: Array que ira armazenar as cond.pagto disponiveis.       �
�lRet: Ira retornar no return da funcao um conteudo logico.      �
�cPesq: Ira armazenar o conteudo digitado no campo de pesquisa   �
�       na tela de consulta F3.                                  �
�cVar: Identifica se esta pegando o conteudo da memoria.         � 
�cPresel: Retorna se pega da memoria ou nao.                     �
�oCombo: Objeto utilizado no combo da tela de consulta F3.       �
�aChave: Chave utilizada para pesquisa na tela de consulta F3.   �
�cChave: Ira armazenar o conteudo escolhido no combo da consulta �
�        F3.                                                     �
����������������������������������������������������������������*/
Local aCond   := {}                                     
Local lRet 	  := .F.
Local cPesq	  := Space(40)
Local cVar	  := ReadVar()
Local cPreSel := If(Left(cVar,3) == "M->",&(cVar),"")
Local oCombo  := Nil
Local aChave  := {"C�digo","Cond.Pagto","Descri��o"}
Local cChave  := ""

/*���������������������������������������������������������Ŀ
�DECLARACAO DE VARIAVEIS ESCOPO PRIVATE                     �
�oBje1: Objeto principal da tela de consulta F3.            �
�oBje2: Objeto utilizado no listbox da tela de consulta F3. �
�����������������������������������������������������������*/
Private oBje1
Private oBje2

/*�������������������������������������������������������������������Ŀ
�Pesquisa as cond.pagto disponiveis e carrega na consulta customizada.�
���������������������������������������������������������������������*/
ProcCond(@aCond)

/*�����������������������������������������������Ŀ
�Aborta rotina se nao foram encontrados registros.�
�������������������������������������������������*/
If Len(aCond) == 0
	ApMsgAlert("Sem condi��es de pagamento para visualizar","Aten��o")
	Return .F.
EndIf

/*��������������������������������������Ŀ
�Tela customizada consulta F3 cond.pagto.�
����������������������������������������*/
DEFINE MSDIALOG oBje1 TITLE "Condi��es de Pagamento" FROM C(0),C(0) TO C(355),C(390) PIXEL

	/*����������������������������������Ŀ
	�Cria componentes padroes do sistema.�
	������������������������������������*/
	@ C(004),C(155) Button "Pesquisa" Size C(037),C(010) PIXEL OF oBje1 Action(SE4Pesq(cPesq,@aCond,cChave))
	@ C(166),C(004) Button "Confirma" Size C(037),C(010) PIXEL OF oBje1 Action(FilSE4(@aCond,@lRet))
	@ C(166),C(044) Button "Cancela"  Size C(037),C(010) PIXEL OF oBje1 Action(oBje1:End())
	
	/*�������������������������������������������������������
	�Botao prospect liberado apenas para os administradores.�
	�������������������������������������������������������*/
	If U_IsAdm() .And. IsInCallStack("TMKA271")
		@ C(166),C(084) Button "Prospect" Size C(037),C(010) PIXEL OF oBje1 Action(oBje1:End(),lRet:=TMKPO())
	EndIf
	
	/*����Ŀ
	�Combo.�
	������*/
	@ C(004),C(004) COMBOBOX oCombo VAR cChave ITEMS aChave SIZE C(149),C(021) PIXEL OF oBje1
	
	/*���������������Ŀ
	�Metodos do combo.�
	�����������������*/
	oCombo:bChange := {|| U_FC002B(cChave,@aCond)}
	
	/*����Ŀ
	�MsGet.�
	������*/
	@ C(016),C(004) MSGET cPesq SIZE C(149), C(09) OF oBje1 PIXEL
	
	/*������Ŀ
	�Listbox.�
	��������*/
	@ C(32),C(4) LISTBOX oBje2 FIELDS HEADER "C�digo","Cond.Pagto","Descri��o";
	SIZE C(190),C(130) OF oBje1 PIXEL ON dblClick(FilSE4(@aCond,@lRet))
	
	/*�����������������Ŀ
	�Metodos da listbox.�
	�������������������*/
	oBje2:SetArray(aCond)
	
	If !Empty(cPreSel)
		
		/*�����������������������������Ŀ
		�Pesquisa cond.pagto na listbox.�
		�������������������������������*/
		If (oBje2:nAt := aScan(aCond,{|x| x[1] == cPreSel})) == 0
			
			/*���������������������������������������������������������������Ŀ
			�Previne array out of bounds, caso a condicao digitado nao exista.�
			�����������������������������������������������������������������*/
			oBje2:nAt := 1
		EndIf
	EndIf
	
	oBje2:bLine := {||{	aCond[oBje2:nAt,1]	,;	// Codigo
						aCond[oBje2:nAt,2]	,;	// Cond.Pagto
						aCond[oBje2:nAt,3]	}}	// Descricao
	
ACTIVATE MSDIALOG oBje1 CENTERED

Return lRet

/*������������������������������������������������������������������������������
����������������������������������������������������������������������������Ŀ��
���Descricao  � Funcao que ira chamar o filtro da consulta customizada ou a  ���
���           | consulta padrao para os administradores.                     ���
�����������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������*/

User Function FSEC002B()

Local lRet := .F.

If U_IsAdm() .Or. U_IsFreeCondPgt() .Or. lTK271Auto
	lRet := Conpad1(,,,"SE4",,.F.,.F.) // Consulta Padrao do Sistema.
Else
	lRet := U_FSEC002() // Consulta SE4 filtrada.
EndIf

Return lRet

*******************************************************

Static Function FilSE4(aCond,lRet)

/*�������������Ŀ
�Posiciona Area.�
���������������*/
DbSelectArea("SE4")
DbGoTo(aCond[oBje2:nAt,4])

/*��������������������������������������������Ŀ
�Finaliza interface e atribui valor de retorno.�
����������������������������������������������*/
oBje1:End()
lRet := .T.

Return Nil

/*������������������������������������������������������������������������������
����������������������������������������������������������������������������Ŀ��
���Descricao  � Funcao principal que retorna as cond.pagto disponiveis.      ���
�����������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������*/

Static Function ProcCond(aCond)

/*��������������������������������������������������������������Ŀ
�DECLARACAO DE VARIAVEIS ESCOPO LOCAL                            �
�cCond1: Caso tenha cond.pagto amarrada no cadastro de clientes  �
�        ou na tabela que esta amarrada no cliente o sistema     �
�        atribui a cond.pagto nessa variavel.                    �
�cQuery: Ira armazenar a query montada.                          �
|lTem: Caso tenha cond.pagto amarrada no cliente ou na tabela    �
|      sera atribuido nessa variavel o conteudo .T. caso nao     �
�      tenha .F.                                                 �
�aCondA1: Array que ira armazenar a cond.pagto e a tabela de     �
�         preco cadastrada no cliente.                           �
����������������������������������������������������������������*/
Local aArea   := GetArea()
Local cCond1  := ""
Local cQuery  := ""
Local lTem    := .F.
Local aCondA1 := {}

/*�������������������������������������������������������������Ŀ
�Validacao caso o usuario nao tenha digitado o cliente e a loja.�
���������������������������������������������������������������*/
If Empty(M->UA_CLIENTE) .OR. Empty(M->UA_LOJA)
	ApMsgAlert("O Codigo do Cliente ou a Loja n�o foram digitados, Por favor digitar.")
Else	
	
	/*��������������������������������������������������������������������������������������Ŀ
	�aCondA1: Array que ira armazenar a cond.pagto e a tabela de preco cadastrada no cliente.�
	����������������������������������������������������������������������������������������*/
	aCondA1 := GetAdvFVal("SA1",{"A1_COND","A1_TABELA"},xFilial("SA1")+ALLTRIM(M->(UA_CLIENTE+UA_LOJA)),1,{"",""})
	
	/*����������������������������������������������Ŀ
	�Caso nao tenha cond.pagto cadastrada no cliente.�
	������������������������������������������������*/
	If Empty(aCondA1[1])
		
		/*����������������������������������������������������Ŀ
		�Verifica se tem tabela de preco cadastrada no cliente.�
		������������������������������������������������������*/
		If !Empty(aCondA1[2])
			/*�����������������������������������������������������Ŀ
			�Retorna a condicao cadastrada na tabela de preco caso  �
			�nao tenha cond.pagto na tabela de preco retorna branco.|
			�������������������������������������������������������*/ 
			cCond1 := GetAdvFVal("DA0","DA0_CONDPG",xFilial("DA0")+ALLTRIM(aCondA1[2]),1,{"",""})
			If !Empty(cCond1)
				lTem := .T.
			Endif
		EndIf
	Else
		/*������������������������������������������Ŀ
		�Caso tenha cond.pagto cadastrada no cliente.�
		��������������������������������������������*/
		cCond1 := aCondA1[1]
		lTem := .T.	
	EndIf
	
	/*���������������������������������������������������Ŀ
	�Se tiver cond.pagto no cliente ou na tabela de preco.�
	�����������������������������������������������������*/
	If lTem
		dbSelectArea("SE4")                    
		dbSetOrder(1)
		dbSeek(xFilial("SE4")+cCond1)
		
		/*����������������������������������������������������������������������������Ŀ
		�Ira retornar somente a cond.pagto cadastrada no cliente ou na tabela de preco.�
		������������������������������������������������������������������������������*/
		AAdd(aCond,{SE4->E4_CODIGO,SE4->E4_COND,SE4->E4_DESCRI,SE4->(Recno())}) 
	Else
		/*����������������������������������������������Ŀ
		�Caso nao tenha cond.pagto no cliente ou na      �
		�tabela de preco sera filtrada as cond.pagto pelo�
		�nivel do usuario.                               �
		������������������������������������������������*/
		/*�����������������������������������������������Ŀ
		�Encerra area temporaria caso ja estivesse em uso.�
		�������������������������������������������������*/
		If Select("TMP") != 0
			TMP->(DbCloseArea())
		EndIf
		
		/*������������Ŀ
		�Monta a query.�
		��������������*/
		cQuery := " SELECT "
		cQuery += " 	SE4.E4_CODIGO, "
		cQuery += " 	SE4.E4_COND, "
		cQuery += "		SE4.E4_DESCRI, "
		cQuery += "		SE4.E4_NIVEL, "
		cQuery += "		SE4.R_E_C_N_O_ "
		cQuery += " FROM " + RetSqlName("SE4") + " SE4 "
		cQuery += " WHERE "
		cQuery += " 	SE4.D_E_L_E_T_ = '' AND "
		cQuery += "		SE4.E4_FILIAL = '" + xFilial("SE4") + "' AND "
		
		/*������Ŀ
		�Filtros.�
		��������*/
		cQuery += " SE4.E4_NIVEL <= '" + cValtoChar(cNivel) + "' "
		
		/*�����Ŀ
		�Orderm.�
		�������*/
		cQuery += " ORDER BY SE4.E4_CODIGO "
		
		/*����������������������������������������Ŀ
		�Prepara e executa query no banco de dados.�
		������������������������������������������*/
		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TMP",.F.,.T.)
		
		/*����������������������������������������������������������Ŀ
		�Percorre retorno, alimentando o array aCond com os dados das�
		�condicoes.                                                  �
		������������������������������������������������������������*/
		DbSelectArea("TMP")
		DbGoTop()
		
		While !TMP->(Eof())
			
			AAdd(aCond,;
			{TMP->E4_CODIGO		,;	// Codigo da Condicao
			TMP->E4_COND		,;	// Condicao
			TMP->E4_DESCRI		,;	// Descricao
			TMP->R_E_C_N_O_	})	    // Numero do registro
			
			TMP->(DbSkip())
			
		EndDo
		
		/*���������������������������Ŀ
		�Finaliza ambiente temporario.�
		�����������������������������*/
		TMP->(DbCloseArea())
	EndIf
EndIf

RestArea(aArea)

Return Nil

/*������������������������������������������������������������������������������
����������������������������������������������������������������������������Ŀ��
���Descricao  � Funcao responsavel por manter o Layout independente da       ���
���           � resolucao horizontal do Monitor do Usuario.                  ���
�����������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������*/

Static Function C(nTam)

Local nHRes	:=	GetScreenRes()[1] // Resolucao horizontal do monitor

Do Case
	Case nHRes == 640 // Resolucao 640x480
		nTam *= 0.8
	Case nHRes == 800 // Resolucao 800x600
		nTam *= 1       
	OtherWise		  // Resolucao 1024x768 e acima
		nTam *= 1.28
End Case
	
/*��������������������������Ŀ
�Tratamento para tema "Flat".�
����������������������������*/
If (Alltrim(GetTheme()) == "FLAT").Or. SetMdiChild()
	nTam *= 0.90
EndIf
	
Return Int(nTam)
	
*******************************************************
	
Static Function SE4Pesq(cPesq,aCond,cChave)
	
Local nTam	:= Len(cPesq := AllTrim(cPesq))
Local bPesq	:= NIL
Local nPos	:= 0
	
/*����������������������������Ŀ
�Considera a chave de pesquisa.�
������������������������������*/
If cChave == "C�digo"
	bPesq := {|x| Left((x[1]+x[2]),nTam) == cPesq }
Else
	bPesq := {|x| Left((x[3]),nTam) == cPesq }
EndIf
	
/*��������������Ŀ
�Realiza a busca.�
����������������*/
nPos := aScan(aCond,bPesq)

/*���������������Ŀ
�Atualiza listbox.�
�����������������*/
If nPos != 0
	oBje2:nAt := nPos
	oBje2:Refresh()
EndIf

Return Nil

*******************************************************

User Function FC002B(cChave,aCond)

If cChave == "Descri��o"
	aSort(aCond,,,{|x,y| x[3] < y[3]})
Else
	aSort(aCond,,,{|x,y| x[1]+x[2] < y[1]+y[2]})
EndIf
	
oBje2:SetArray(aCond)
oBje2:bLine := {||{	aCond[oBje2:nAt,1]	,;	// Codigo
					aCond[oBje2:nAt,2]	,;	// Cond.Pagto
					aCond[oBje2:nAt,3]	}}	// Descricao
oBje2:Refresh()
	
Return Nil
	
/*������������������������������������������������������������������������������
����������������������������������������������������������������������������Ŀ��
���Descricao  � Funcao chamada na validacao de usuario do campo SUA_CONDPG.  ���
�����������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������*/
	
User Function FSEC002C()

/*��������������������������������������������������������������Ŀ
�DECLARACAO DE VARIAVEIS ESCOPO LOCAL                            �
�lRet: Ira retornar no return da funcao um conteudo logico, caso �
�      retorne .T. o sistema sai do campo cond.pagto e libera    �
�      a digitacao dos outros campos, caso retorne .F. o sistema � 
�      nao deixa sair do campo ate que seja digitado um valor    �
�      que force a alteracao o conteudo da variavel lRet de .F.  � 
�      para .T.                                                  �
�x: Utilizada no FOR.                                            �
�cCond2: Caso tenha cond.pagto amarrada no cadastro de clientes  �
�        ou na tabela que esta amarrada no cliente o sistema     �
�        atribui a cond.pagto nessa variavel.                    �
|aCond: Array que ira armazenar as cond.pagto disponiveis.       �
�aCondA1: Array que ira armazenar a cond.pagto e a tabela de     �
�         preco cadastrada no cliente.                           �
����������������������������������������������������������������*/
Local aArea	   := GetArea()
Local lRet	   := .F.
Local x        := 0
Local cCond2   := ""
Local aCond    := {}
Local aCondA1  := {}

If lTk271Auto
	Return (.T.)
EndIf


/*����������������������������������������������������Ŀ
�Validacao caso o usuario apague o valor da cond.pagto.�
������������������������������������������������������*/
If Len(ALLTRIM(M->UA_CONDPG)) > 0

	/*�����������������������������������������������������������������������������������������������������������������������������������������������Ŀ
	�Validacao caso o usuario seja administrador ou caso o codigo do usuario esteja na rotina U_IsFreeCondPgt(rotina que libera todas as cond.pagtos).�
	�������������������������������������������������������������������������������������������������������������������������������������������������*/
	If !(U_IsAdm() .OR. U_IsFreeCondPgt())
	
		/*�������������������������������������������������������������Ŀ
		�Validacao caso o usuario nao tenha digitado o cliente e a loja.�
		���������������������������������������������������������������*/
		If Empty(M->UA_CLIENTE) .OR. Empty(M->UA_LOJA)
			ApMsgAlert("O Codigo do Cliente ou a Loja nao foram digitados, Por favor digitar.")
		Else
		
			/*��������������������������������������������������������������������������������������Ŀ
			�aCondA1: Array que ira armazenar a cond.pagto e a tabela de preco cadastrada no cliente.�
			����������������������������������������������������������������������������������������*/
			aCondA1 := GetAdvFVal("SA1",{"A1_COND","A1_TABELA"},xFilial("SA1")+ALLTRIM(M->(UA_CLIENTE+UA_LOJA)),1,{"",""})
			
			/*����������������������������������������������Ŀ
			�Caso nao tenha cond.pagto cadastrada no cliente.�
			������������������������������������������������*/
			If Empty(aCondA1[1])
   				
   				/*����������������������������������������������������Ŀ
				�Verifica se tem tabela de preco cadastrada no cliente.�
				������������������������������������������������������*/
				If !Empty(aCondA1[2])
					/*�����������������������������������������������������Ŀ
					�Retorna a condicao cadastrada na tabela de preco caso  �
					�nao tenha cond.pagto na tabela de preco retorna branco.|
					�������������������������������������������������������*/
					cCond2 := GetAdvFVal("DA0","DA0_CONDPG",xFilial("DA0")+ALLTRIM(aCondA1[2]),1,{"",""})
					lRet := .T.
				Endif
			Else
				/*������������������������������������������Ŀ
				�Caso tenha cond.pagto cadastrada no cliente.�
				��������������������������������������������*/
				cCond2 := aCondA1[1]
				lRet := .T.
			EndIf
		EndIf
		
		/*���������������������������������������������������������������������Ŀ
		�Caso nao tenha cond.pagto cadastrada no cliente nem na tabela de preco.�
		�����������������������������������������������������������������������*/
		If Empty(cCond2)
			lRet := .F.
			
			/*������������������������������������������������Ŀ
			�Chama funcao que retorna as condicoes disponiveis.�
			��������������������������������������������������*/
			ProcCond(@aCond)
			
			For x:= 1 To Len(aCond)
				If M->UA_CONDPG == aCond[x,1]
					lRet := .T.
				EndIf
			Next x
			
			/*�������������������������������������������������������Ŀ
			�Se tiver digitado uma cond.pagto que nao esta disponivel.�
			���������������������������������������������������������*/
			If !lRet
				M->UA_CONDPG := "   "
				ApMsgAlert("Condi��o de Pagamento n�o permitida, digite uma Condi��o de Pagamento v�lida.")
			EndIf
		Else
			
			/*�������������������������������������������������������������������������Ŀ
			�Validacao caso tenha cond.pagto cadastrada no cliente ou na tabela de preco�
			�e o usuario tente utilizar uma outra cond.pagto.                           � 
			���������������������������������������������������������������������������*/
			If ALLTRIM(M->UA_CONDPG) <> ALLTRIM(cCond2)
				M->UA_CONDPG := ALLTRIM(cCond2)
				ApMsgAlert("Como a condi��o de pagamento " + cValtoChar(cCond2) + " esta amarrada ao cliente, s� ser� possivel utilizar essa condi��o.")
			EndIf
		EndIf
	Else
	
		/*����������������������������������������������������������������������������Ŀ
		�Validacao caso o usuario nao tenha digitado o cliente e a loja. Essa condicao �
		�so sera valida para os administradores.                                       �
		������������������������������������������������������������������������������*/
		If Empty(M->UA_CLIENTE) .OR. Empty(M->UA_LOJA)
			M->UA_CONDPG := "   "
			ApMsgAlert("O Codigo do Cliente ou a Loja n�o foram digitados, Por favor digitar.")
		Else
			lRet := .T.
		EndIf
	EndIf
Else
	M->UA_CONDPG := "   "
	ApMsgAlert("Por favor digitar uma condi��o de pagamento.")
	lRet := .T.
EndIf
		
RestArea(aArea)
	
Return lRet