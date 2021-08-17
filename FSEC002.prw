#INCLUDE "PROTHEUS.CH"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Descricao  ³ Funcao responsavel por montar a consulta F3 customizada do   ³±±
±±³           | cadastro de condicoes de pagamento.                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

User Function FSEC002()

/*ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³DECLARACAO DE VARIAVEIS ESCOPO LOCAL                            ³
³aCond: Array que ira armazenar as cond.pagto disponiveis.       ³
³lRet: Ira retornar no return da funcao um conteudo logico.      ³
³cPesq: Ira armazenar o conteudo digitado no campo de pesquisa   ³
³       na tela de consulta F3.                                  ³
³cVar: Identifica se esta pegando o conteudo da memoria.         ³ 
³cPresel: Retorna se pega da memoria ou nao.                     ³
³oCombo: Objeto utilizado no combo da tela de consulta F3.       ³
³aChave: Chave utilizada para pesquisa na tela de consulta F3.   ³
³cChave: Ira armazenar o conteudo escolhido no combo da consulta ³
³        F3.                                                     ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
Local aCond   := {}                                     
Local lRet 	  := .F.
Local cPesq	  := Space(40)
Local cVar	  := ReadVar()
Local cPreSel := If(Left(cVar,3) == "M->",&(cVar),"")
Local oCombo  := Nil
Local aChave  := {"Código","Cond.Pagto","Descrição"}
Local cChave  := ""

/*ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³DECLARACAO DE VARIAVEIS ESCOPO PRIVATE                     ³
³oBje1: Objeto principal da tela de consulta F3.            ³
³oBje2: Objeto utilizado no listbox da tela de consulta F3. ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
Private oBje1
Private oBje2

/*ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³Pesquisa as cond.pagto disponiveis e carrega na consulta customizada.³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
ProcCond(@aCond)

/*ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³Aborta rotina se nao foram encontrados registros.³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
If Len(aCond) == 0
	ApMsgAlert("Sem condições de pagamento para visualizar","Atenção")
	Return .F.
EndIf

/*ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³Tela customizada consulta F3 cond.pagto.³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
DEFINE MSDIALOG oBje1 TITLE "Condições de Pagamento" FROM C(0),C(0) TO C(355),C(390) PIXEL

	/*ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³Cria componentes padroes do sistema.³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
	@ C(004),C(155) Button "Pesquisa" Size C(037),C(010) PIXEL OF oBje1 Action(SE4Pesq(cPesq,@aCond,cChave))
	@ C(166),C(004) Button "Confirma" Size C(037),C(010) PIXEL OF oBje1 Action(FilSE4(@aCond,@lRet))
	@ C(166),C(044) Button "Cancela"  Size C(037),C(010) PIXEL OF oBje1 Action(oBje1:End())
	
	/*ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³Botao prospect liberado apenas para os administradores.³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
	If U_IsAdm() .And. IsInCallStack("TMKA271")
		@ C(166),C(084) Button "Prospect" Size C(037),C(010) PIXEL OF oBje1 Action(oBje1:End(),lRet:=TMKPO())
	EndIf
	
	/*ÄÄÄÄÄ¿
	³Combo.³
	ÀÄÄÄÄÄ*/
	@ C(004),C(004) COMBOBOX oCombo VAR cChave ITEMS aChave SIZE C(149),C(021) PIXEL OF oBje1
	
	/*ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³Metodos do combo.³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
	oCombo:bChange := {|| U_FC002B(cChave,@aCond)}
	
	/*ÄÄÄÄÄ¿
	³MsGet.³
	ÀÄÄÄÄÄ*/
	@ C(016),C(004) MSGET cPesq SIZE C(149), C(09) OF oBje1 PIXEL
	
	/*ÄÄÄÄÄÄÄ¿
	³Listbox.³
	ÀÄÄÄÄÄÄÄ*/
	@ C(32),C(4) LISTBOX oBje2 FIELDS HEADER "Código","Cond.Pagto","Descrição";
	SIZE C(190),C(130) OF oBje1 PIXEL ON dblClick(FilSE4(@aCond,@lRet))
	
	/*ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³Metodos da listbox.³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
	oBje2:SetArray(aCond)
	
	If !Empty(cPreSel)
		
		/*ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		³Pesquisa cond.pagto na listbox.³
		ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
		If (oBje2:nAt := aScan(aCond,{|x| x[1] == cPreSel})) == 0
			
			/*ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			³Previne array out of bounds, caso a condicao digitado nao exista.³
			ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
			oBje2:nAt := 1
		EndIf
	EndIf
	
	oBje2:bLine := {||{	aCond[oBje2:nAt,1]	,;	// Codigo
						aCond[oBje2:nAt,2]	,;	// Cond.Pagto
						aCond[oBje2:nAt,3]	}}	// Descricao
	
ACTIVATE MSDIALOG oBje1 CENTERED

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Descricao  ³ Funcao que ira chamar o filtro da consulta customizada ou a  ³±±
±±³           | consulta padrao para os administradores.                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

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

/*ÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³Posiciona Area.³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
DbSelectArea("SE4")
DbGoTo(aCond[oBje2:nAt,4])

/*ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³Finaliza interface e atribui valor de retorno.³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
oBje1:End()
lRet := .T.

Return Nil

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Descricao  ³ Funcao principal que retorna as cond.pagto disponiveis.      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function ProcCond(aCond)

/*ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³DECLARACAO DE VARIAVEIS ESCOPO LOCAL                            ³
³cCond1: Caso tenha cond.pagto amarrada no cadastro de clientes  ³
³        ou na tabela que esta amarrada no cliente o sistema     ³
³        atribui a cond.pagto nessa variavel.                    ³
³cQuery: Ira armazenar a query montada.                          ³
|lTem: Caso tenha cond.pagto amarrada no cliente ou na tabela    ³
|      sera atribuido nessa variavel o conteudo .T. caso nao     ³
³      tenha .F.                                                 ³
³aCondA1: Array que ira armazenar a cond.pagto e a tabela de     ³
³         preco cadastrada no cliente.                           ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
Local aArea   := GetArea()
Local cCond1  := ""
Local cQuery  := ""
Local lTem    := .F.
Local aCondA1 := {}

/*ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³Validacao caso o usuario nao tenha digitado o cliente e a loja.³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
If Empty(M->UA_CLIENTE) .OR. Empty(M->UA_LOJA)
	ApMsgAlert("O Codigo do Cliente ou a Loja não foram digitados, Por favor digitar.")
Else	
	
	/*ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³aCondA1: Array que ira armazenar a cond.pagto e a tabela de preco cadastrada no cliente.³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
	aCondA1 := GetAdvFVal("SA1",{"A1_COND","A1_TABELA"},xFilial("SA1")+ALLTRIM(M->(UA_CLIENTE+UA_LOJA)),1,{"",""})
	
	/*ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³Caso nao tenha cond.pagto cadastrada no cliente.³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
	If Empty(aCondA1[1])
		
		/*ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		³Verifica se tem tabela de preco cadastrada no cliente.³
		ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
		If !Empty(aCondA1[2])
			/*ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			³Retorna a condicao cadastrada na tabela de preco caso  ³
			³nao tenha cond.pagto na tabela de preco retorna branco.|
			ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/ 
			cCond1 := GetAdvFVal("DA0","DA0_CONDPG",xFilial("DA0")+ALLTRIM(aCondA1[2]),1,{"",""})
			If !Empty(cCond1)
				lTem := .T.
			Endif
		EndIf
	Else
		/*ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		³Caso tenha cond.pagto cadastrada no cliente.³
		ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
		cCond1 := aCondA1[1]
		lTem := .T.	
	EndIf
	
	/*ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³Se tiver cond.pagto no cliente ou na tabela de preco.³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
	If lTem
		dbSelectArea("SE4")                    
		dbSetOrder(1)
		dbSeek(xFilial("SE4")+cCond1)
		
		/*ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		³Ira retornar somente a cond.pagto cadastrada no cliente ou na tabela de preco.³
		ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
		AAdd(aCond,{SE4->E4_CODIGO,SE4->E4_COND,SE4->E4_DESCRI,SE4->(Recno())}) 
	Else
		/*ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		³Caso nao tenha cond.pagto no cliente ou na      ³
		³tabela de preco sera filtrada as cond.pagto pelo³
		³nivel do usuario.                               ³
		ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
		/*ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		³Encerra area temporaria caso ja estivesse em uso.³
		ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
		If Select("TMP") != 0
			TMP->(DbCloseArea())
		EndIf
		
		/*ÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		³Monta a query.³
		ÀÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
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
		
		/*ÄÄÄÄÄÄÄ¿
		³Filtros.³
		ÀÄÄÄÄÄÄÄ*/
		cQuery += " SE4.E4_NIVEL <= '" + cValtoChar(cNivel) + "' "
		
		/*ÄÄÄÄÄÄ¿
		³Orderm.³
		ÀÄÄÄÄÄÄ*/
		cQuery += " ORDER BY SE4.E4_CODIGO "
		
		/*ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		³Prepara e executa query no banco de dados.³
		ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TMP",.F.,.T.)
		
		/*ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		³Percorre retorno, alimentando o array aCond com os dados das³
		³condicoes.                                                  ³
		ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
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
		
		/*ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		³Finaliza ambiente temporario.³
		ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
		TMP->(DbCloseArea())
	EndIf
EndIf

RestArea(aArea)

Return Nil

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Descricao  ³ Funcao responsavel por manter o Layout independente da       ³±±
±±³           ³ resolucao horizontal do Monitor do Usuario.                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

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
	
/*ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³Tratamento para tema "Flat".³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
If (Alltrim(GetTheme()) == "FLAT").Or. SetMdiChild()
	nTam *= 0.90
EndIf
	
Return Int(nTam)
	
*******************************************************
	
Static Function SE4Pesq(cPesq,aCond,cChave)
	
Local nTam	:= Len(cPesq := AllTrim(cPesq))
Local bPesq	:= NIL
Local nPos	:= 0
	
/*ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³Considera a chave de pesquisa.³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
If cChave == "Código"
	bPesq := {|x| Left((x[1]+x[2]),nTam) == cPesq }
Else
	bPesq := {|x| Left((x[3]),nTam) == cPesq }
EndIf
	
/*ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³Realiza a busca.³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
nPos := aScan(aCond,bPesq)

/*ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³Atualiza listbox.³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
If nPos != 0
	oBje2:nAt := nPos
	oBje2:Refresh()
EndIf

Return Nil

*******************************************************

User Function FC002B(cChave,aCond)

If cChave == "Descrição"
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
	
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Descricao  ³ Funcao chamada na validacao de usuario do campo SUA_CONDPG.  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
	
User Function FSEC002C()

/*ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³DECLARACAO DE VARIAVEIS ESCOPO LOCAL                            ³
³lRet: Ira retornar no return da funcao um conteudo logico, caso ³
³      retorne .T. o sistema sai do campo cond.pagto e libera    ³
³      a digitacao dos outros campos, caso retorne .F. o sistema ³ 
³      nao deixa sair do campo ate que seja digitado um valor    ³
³      que force a alteracao o conteudo da variavel lRet de .F.  ³ 
³      para .T.                                                  ³
³x: Utilizada no FOR.                                            ³
³cCond2: Caso tenha cond.pagto amarrada no cadastro de clientes  ³
³        ou na tabela que esta amarrada no cliente o sistema     ³
³        atribui a cond.pagto nessa variavel.                    ³
|aCond: Array que ira armazenar as cond.pagto disponiveis.       ³
³aCondA1: Array que ira armazenar a cond.pagto e a tabela de     ³
³         preco cadastrada no cliente.                           ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
Local aArea	   := GetArea()
Local lRet	   := .F.
Local x        := 0
Local cCond2   := ""
Local aCond    := {}
Local aCondA1  := {}

If lTk271Auto
	Return (.T.)
EndIf


/*ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³Validacao caso o usuario apague o valor da cond.pagto.³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
If Len(ALLTRIM(M->UA_CONDPG)) > 0

	/*ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³Validacao caso o usuario seja administrador ou caso o codigo do usuario esteja na rotina U_IsFreeCondPgt(rotina que libera todas as cond.pagtos).³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
	If !(U_IsAdm() .OR. U_IsFreeCondPgt())
	
		/*ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		³Validacao caso o usuario nao tenha digitado o cliente e a loja.³
		ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
		If Empty(M->UA_CLIENTE) .OR. Empty(M->UA_LOJA)
			ApMsgAlert("O Codigo do Cliente ou a Loja nao foram digitados, Por favor digitar.")
		Else
		
			/*ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			³aCondA1: Array que ira armazenar a cond.pagto e a tabela de preco cadastrada no cliente.³
			ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
			aCondA1 := GetAdvFVal("SA1",{"A1_COND","A1_TABELA"},xFilial("SA1")+ALLTRIM(M->(UA_CLIENTE+UA_LOJA)),1,{"",""})
			
			/*ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			³Caso nao tenha cond.pagto cadastrada no cliente.³
			ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
			If Empty(aCondA1[1])
   				
   				/*ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				³Verifica se tem tabela de preco cadastrada no cliente.³
				ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
				If !Empty(aCondA1[2])
					/*ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					³Retorna a condicao cadastrada na tabela de preco caso  ³
					³nao tenha cond.pagto na tabela de preco retorna branco.|
					ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
					cCond2 := GetAdvFVal("DA0","DA0_CONDPG",xFilial("DA0")+ALLTRIM(aCondA1[2]),1,{"",""})
					lRet := .T.
				Endif
			Else
				/*ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				³Caso tenha cond.pagto cadastrada no cliente.³
				ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
				cCond2 := aCondA1[1]
				lRet := .T.
			EndIf
		EndIf
		
		/*ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		³Caso nao tenha cond.pagto cadastrada no cliente nem na tabela de preco.³
		ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
		If Empty(cCond2)
			lRet := .F.
			
			/*ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			³Chama funcao que retorna as condicoes disponiveis.³
			ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
			ProcCond(@aCond)
			
			For x:= 1 To Len(aCond)
				If M->UA_CONDPG == aCond[x,1]
					lRet := .T.
				EndIf
			Next x
			
			/*ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			³Se tiver digitado uma cond.pagto que nao esta disponivel.³
			ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
			If !lRet
				M->UA_CONDPG := "   "
				ApMsgAlert("Condição de Pagamento não permitida, digite uma Condição de Pagamento válida.")
			EndIf
		Else
			
			/*ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			³Validacao caso tenha cond.pagto cadastrada no cliente ou na tabela de preco³
			³e o usuario tente utilizar uma outra cond.pagto.                           ³ 
			ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
			If ALLTRIM(M->UA_CONDPG) <> ALLTRIM(cCond2)
				M->UA_CONDPG := ALLTRIM(cCond2)
				ApMsgAlert("Como a condição de pagamento " + cValtoChar(cCond2) + " esta amarrada ao cliente, só será possivel utilizar essa condição.")
			EndIf
		EndIf
	Else
	
		/*ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		³Validacao caso o usuario nao tenha digitado o cliente e a loja. Essa condicao ³
		³so sera valida para os administradores.                                       ³
		ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
		If Empty(M->UA_CLIENTE) .OR. Empty(M->UA_LOJA)
			M->UA_CONDPG := "   "
			ApMsgAlert("O Codigo do Cliente ou a Loja não foram digitados, Por favor digitar.")
		Else
			lRet := .T.
		EndIf
	EndIf
Else
	M->UA_CONDPG := "   "
	ApMsgAlert("Por favor digitar uma condição de pagamento.")
	lRet := .T.
EndIf
		
RestArea(aArea)
	
Return lRet