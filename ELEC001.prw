#INCLUDE "PROTHEUS.CH"
/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �ELEC001   � Autor � Wilson Jorge Tedokon  � Data �15/03/2006���
�������������������������������������������������������������������������Ĵ��
���Locacao   � Fab. Express     �Contato � wilson.tedokon@microsiga.com.br���
�������������������������������������������������������������������������Ĵ��
���Descricao � Rotina de consulta de faixa de valores x comissoes         ���
�������������������������������������������������������������������������Ĵ��
���Parametros�cVend    - Vendedor Atual                                   ���
���          �cTabela  - Tabela de Preco Atual                            ���
���          �cProduto - Produto da linha Atual                           ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �(.F.) se a consulta foi cancelada ou nao encontrou itens;   ���
���          �(.T.) se confirmada                                         ���
�������������������������������������������������������������������������Ĵ��
���Aplicacao �Consulta de faixa de valores no item do orcamento do        ���
���          �televendas                                                  ���
�������������������������������������������������������������������������Ĵ��
���Uso       �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Analista Resp.�  Data  � Bops � Manutencao Efetuada                    ���
�������������������������������������������������������������������������Ĵ��
���              �  /  /  �      �                                        ���
���              �  /  /  �      �                                        ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
User Function ELEC001(cVend, cTabela, cProduto)

Local lRet	    := .T.
Local aRecnos	:= {}
Local aHead     := {}               // Array a ser tratado internamente na MsNewGetDados como aHeader
Local aCol      := {}               // Array a ser tratado internamente na MsNewGetDados como aCols
Local aVend		:= "" 
Local nPosVrUn	
Local cProduto 
Local oBtnExit
Local cVend    
Local cTabela  
Local i
Local lCheck	:= .F.
Local cCliente  := ""
Local cLoja     := ""  
Private _oGetD  // Private das NewGetDados
Private _oDlg

If IsInCallStack("TMKA271") .And. !IsInCallStack("A410VISUAL")   
	nPosVrUn	:= aScan(aHeader,{|x| AllTrim(x[2]) == "UB_VRUNIT"})
	cProduto 	:= aCols[n,aScan(aHeader,{|x|AllTrim(x[2])=="UB_PRODUTO"})]
	cVend    	:= M->UA_VEND
	cTabela  	:= M->UA_TABELA
	lCheck		:= (AllTrim(ReadVar()) == "M->UB_VRUNIT") .Or. (oGetTlv:oBrowse:nColPos == nPosVrUn) 
	cCliente    := M->UA_CLIENTE
	cloja       := M->UA_LOJA 		
ElseIf IsInCallStack("MATA410")  
	nPosVrUn	:= aScan(aHeader,{|x| AllTrim(x[2]) == "C6_PRCVEN"})
	cProduto 	:= aCols[n,aScan(aHeader,{|x|AllTrim(x[2])=="C6_PRODUTO"})]
	cVend    	:= M->C5_VEND1
	cTabela  	:= M->C5_TABELA
	lCheck 		:= (AllTrim(ReadVar()) == "M->C6_PRCVEN") .Or. (oGetdad:oBrowse:nColPos == nPosVrUn)  
	cCliente    := M->C5_CLIENTE
	cloja       := M->C5_LOJACLI 		
Else
	lRet := .F.
EndIf 

If (Empty(cVend) .OR. Empty(cTabela) .OR. Empty(cProduto)) .And. !lRet 
	
	ApMsgAlert("Consulta invalida!","ELEC001")
    
    Return .F.

EndIf
                                                                                            //cMod $ "MATA410.#M410FIL"
aVend := GetAdvFVal("SA3",{"A3_TIPO","A3_COMIS"},xFilial("SA3")+IIF(IsInCallStack("MATA410"),M->C5_VEND1,M->UA_VEND),1,{"",0})

If (lCheck) .And.;
	(AllTrim(aVend[1]) != "C") .And. (aVend[2] > 0)

  //����������������������������������������Ŀ
  //�Faz pesquisa das comissoes com query SQL�
  //������������������������������������������

  ProcComis(cVend, cTabela, cProduto, @aHead, @aCol, cCliente, cLoja)

  //������������������������������������������������Ŀ
  //�Aborta rotina se n�o foram encontrados registros�
  //��������������������������������������������������
  If Len(aCol) == 0
    ApMsgAlert("N�o foram encontradas valores x comiss�es para o produto " + cProduto,"Aten��o")
    Return .F.
  EndIf

  //���������������Ŀ
  //�Exibe interface�
  //�����������������
	
  DEFINE MSDIALOG _oDlg TITLE "Consulta Valores x Comiss�o do Produto "  FROM C(224),C(241) TO C(521),C(591) PIXEL STYLE DS_MODALFRAME STATUS

    // Chamadas das GetDados do Sistema
    foGetD(@aRecnos, @aHead, @aCol)

  	//�����������������������������������Ŀ
	//�Cria Componentes Padroes do Sistema�
	//�������������������������������������
   	@ C(007),C(007) Say "Faixas de valores x comiss�es do Produto" Size C(098),C(008) COLOR CLR_BLACK PIXEL OF _oDlg
	DEFINE SBUTTON oBtnExit FROM C(131),C(135) TYPE 1 ENABLE OF _oDlg Action (lAbort:=.f., _oDlg:End())
    
    oBtnExit:Setfocus()
   
  ACTIVATE MSDIALOG _oDlg CENTERED 

EndIf

Return lRet

/*����������������������������������������������������������������������������������
������������������������������������������������������������������������������������
��������������������������������������������������������������������������������Ŀ��
���Programa   �foGetD()    � Autor � Ricardo Mansano           � Data �14/03/2006���
��������������������������������������������������������������������������������Ĵ��
���Descricao  � Montagem da GetDados                                             ���
��������������������������������������������������������������������������������Ĵ��
���Observacao � O Objeto _oGetD      foi criado como Private no inicio do Fonte  ���
���           � desta forma voce podera trata-lo em qualquer parte do            ���
���           � seu programa:                                                    ���
���           �                                                                  ���
���           � Para acessar o aCols desta MsNewGetDados:  _oGetD:aCols[nX,nY]   ���
���           � Para acessar o aHeader:  _oGetD:aHeader[nX,nY]                   ���
���           � Para acessar o "n"    :  _oGetD:nAT                              ���
���������������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������������
����������������������������������������������������������������������������������*/
Static Function foGetD(aRecnos, aHead, aCol)

Local aAlter       	:= {}
Local nSuperior    	:= C(016)
Local nEsquerda    	:= C(004)
Local nInferior    	:= C(125)
Local nDireita     	:= C(175)
Local nOpc         	:= GD_DELETE
Local cLinOk       	:= "AllwaysTrue"    // Funcao executada para validar o contexto da linha atual do aCols
Local cTudoOk      	:= "AllwaysTrue"    // Funcao executada para validar o contexto geral da MsNewGetDados (todo aCols)
Local cIniCpos     	:= ""               // Nome dos campos do tipo caracter que utilizarao incremento automatico.
Local nFreeze      	:= 000              // Campos estaticos na GetDados.
Local nMax         	:= 999              // Numero maximo de linhas permitidas. Valor padrao 99
Local cFieldOk     	:= "AllwaysTrue"    // Funcao executada na validacao do campo
Local cSuperDel    	:= ""              // Funcao executada quando pressionada as teclas <Ctrl>+<Delete>
Local cDelOk       	:= ""             // Funcao executada para validar a exclusao de uma linha do aCols
Local oWnd         	:= _oDlg

_oGetD:= MsNewGetDados():New(nSuperior,nEsquerda,nInferior,nDireita,nOpc,cLinOk,cTudoOk,cIniCpos,;
aAlter,nFreeze,nMax,cFieldOk,cSuperDel,cDelOk,oWnd,aHead,aCol)
 
Return Nil      


/*
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
����������������������������������������������������������������������������ͻ��
���Programa  � ProcComis       �Autor �Wilson Jorge Tedokon �Data � 15/03/05 ���
����������������������������������������������������������������������������͹��
���Descricao � Execucao de query para ambiente TopConnect                    ���
����������������������������������������������������������������������������͹��
���Parametros�cVend    - Vendedor Atual                                      ���
���          �cTabela  - Tabela de Preco Atual                               ���
���          �cProduto - Produto da linha Atual                              ���
����������������������������������������������������������������������������͹��
���Retorno   � Nao se apliaca                                                ���
����������������������������������������������������������������������������͹��
���Aplicacao � Geracao da lista de valores x comissoes                       ���
����������������������������������������������������������������������������͹��
���Analista  � Data   �Bops  �Manutencao Efetuada                            ���
����������������������������������������������������������������������������͹��
���          �        �      �                                               ���
����������������������������������������������������������������������������͹��
���Uso       �Eletromega                                                     ���
����������������������������������������������������������������������������ͼ��
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
*/

Static Function ProcComis(cVend, cTabela, cProduto, aHead, aCol, cCliente, cLoja)

Local cFatext   := "0"
Local cAlias    := "TMP"  
Local cCodComiss:= ""  
Local nLin      := 0
Local nDecs		:= TamSx3("UA2_VALMAX")[2]  // parte decimal do UA2_VALMAX
Local aArea		:= GetArea()
Local aAreaDA0	:= DA0->(GetArea())
Local aAreaSB1	:= SB1->(GetArea())
Local aAreaSA3	:= SA3->(GetArea())
Local cQuery
Local nComiss   := 0

/* Local nCasas

// Get number of casas // 

//nCasas := GetAdvFVal("DA1","DA1_PRCVEN",xFilial("DA1")+cProduto+cTabela ,2,0)

//nDecs  := len (substr(alltrim(str(nCasas)),1 + at('.',alltrim(str(nCasas)))))

*/

GetArray(@aHead, @aCol)

//�����������������Ŀ
//�Posiciona tabelas�
//�������������������
DA0->(DbSetOrder(1))
DA0->(DbSeek(xFilial("DA0")+cTabela))

SB1->(DbSetOrder(1))
SB1->(DbSeek(xFilial("SB1")+cProduto))

SA3->(DbSetOrder(1))
SA3->(DbSeek(xFilial("SA3")+IIF(IsInCallStack("MATA410"),M->C5_VEND1 ,M->UA_VEND)))

DbSelectArea("SA3")                          
DbSetOrder(1)

If DbSeek(xFilial("SA3")+cVend)
  cFatext := SA3->A3_FATEXT
EndIf                      

//������������������������������������������������������Ŀ
//�A rotina foi desenvolvida exclusivamente para ambiente�
//�TOPCONNECT                                            �
//��������������������������������������������������������
#IFDEF TOP
    
	//������������������������������������������������Ŀ
	//�Encerra area temporaria caso ja estivesse em uso�
	//��������������������������������������������������
	If Select(cAlias) != 0
		TMP->(DbCloseArea())
	EndIf
	
	//����������������������������������Ŀ
	//�Se produto e tabela utilizam faixa�
	//������������������������������������
	If (DA0->DA0_VERFAI == "S") .And. (SB1->B1_VERFAI == "S")

		//�������������Ŀ
		//�Monta a query�
		//���������������
		cQuery	:= "SELECT ISNULL((DA1.DA1_PRCVEN - ((DA1.DA1_PRCVEN * UA1.UA1_DESCDE)/100)),0) VALMAX, "
		cQuery	+= "       ISNULL((DA1.DA1_PRCVEN - ((DA1.DA1_PRCVEN * UA1.UA1_DESCAT)/100)),0) VALMIN, "
		cQuery	+= "       UA1.UA1_CODINT CODINT, "
		cQuery	+= "       UA1.UA1_CODEXT CODEXT, "
		cQuery	+= "       UA1.UA1_COMISS COMISS "
		cQuery	+= "FROM " + RetSqlName("DA1") + " DA1, " + RetSqlName("UA1") +" UA1, "
		cQuery	+= "       " + RetSqlName("DA0") + " DA0, " + RetSqlName("SB1") +" SB1 "
		cQuery	+= "WHERE "
		cQuery	+= "       DA0_VERFAI='S' AND B1_VERFAI='S' AND "
		cQuery	+= "       DA1.DA1_CODTAB = '" + cTabela  + "' AND "
		cQuery	+= "       DA1.DA1_CODPRO = '" + cProduto + "' AND "
		cQuery	+= "       DA1.DA1_CODPRO = SB1.B1_COD AND "
		cQuery	+= "       DA1.DA1_CODTAB = UA1.UA1_CODTAB AND "
		cQuery	+= "       DA0.DA0_CODTAB = DA1.DA1_CODTAB AND "
		cQuery	+= "       DA0.D_E_L_E_T_ <> '*' AND "
		cQuery	+= "       DA1.D_E_L_E_T_ <> '*' AND "
		cQuery	+= "       SB1.D_E_L_E_T_ <> '*' AND "
		cQuery	+= "       UA1.D_E_L_E_T_ <> '*'  "
		cQuery  += "       AND  DA0_FILIAL = '"+xFilial("DA0")+"' "  // 18-06-08
		cQuery  += "       AND  DA1_FILIAL = '"+xFilial("DA1")+"' "  // 18-06-08
		cQuery  += "       AND  UA1_FILIAL = '"+xFilial("UA1")+"' "  // 18-06-08
		cQuery	+= "ORDER BY UA1.UA1_COMISS DESC "
	
		//�����������������������������������������Ŀ
		//�Prepara e executa query no banco de dados�
		//�������������������������������������������
		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.F.,.T.)
	
		//�������������������������������������������������������������Ŀ
		//�Percorre retorno, alimentando o array aComiss com os dados de�
		//�Valores x Comissoes                                          �
		//���������������������������������������������������������������
		DbSelectArea("TMP")
		DbGoTop()
	
		aCol := {}
	
		While !TMP->(Eof())
	        Do Case
	       	  Case cFatext == "0"
	       	    cCodComiss := ""
	       	  Case cFatext == "1"
	       	    cCodComiss := TMP->CODINT
	       	  Case cFatext == "2"
	       	    cCodComiss := TMP->CODEXT
	        EndCase
	
			//����������������Ŀ
			//�Incrementa aCols�
			//������������������
	
			Aadd(aCol,Array(4))
			nLin++
			
			//�����������������Ŀ
			//�Inicializa campos�
			//�������������������
			aCol[nLin][1] := NoRound(TMP->VALMAX,nDecs)
			aCol[nLin][2] := NoRound(TMP->VALMIN,nDecs)
			aCol[nLin][3] := cCodComiss
			aCol[nLin][4] := .F.
			
			TMP->(DbSkip())
	
		End
		
		//����������������������������Ŀ
		//�Finaliza ambiente temporario�
		//������������������������������
		TMP->(DbCloseArea())
	Else

		//�����������������������Ŀ
		//�Informa comissao padrao�
		//�������������������������
		If (IsInCallStack("MATA410"))
			aCol[1][1] := aCols[N][aScan(aHeader,{|x| AllTrim(x[2]) == "C6_PRCVEN"})]
			aCol[1][2] := aCols[N][aScan(aHeader,{|x| AllTrim(x[2]) == "C6_PRCVEN"})]
		Else
			aCol[1][1] := aCols[N][aScan(aHeader,{|x| AllTrim(x[2]) == "UB_VRUNIT"})]
			aCol[1][2] := aCols[N][aScan(aHeader,{|x| AllTrim(x[2]) == "UB_VRUNIT"})]
		EndIf
		
		nComiss := GetAdvFVal("SA1","A1_COMIS",xFilial("SA1")+cCliente+cLoja,1,0)

		If nComiss == 0 
			nComiss := GetAdvFVal("SB1","B1_COMIS",xFilial("SB1")+cProduto,1,0)	
		EndIf
		
		If nComiss == 0
			nComiss := SA3->A3_COMIS
		EndIf
		
		aCol[1][3] := nComiss
		aCol[1][4] := .F.
	
	EndIf

#ELSE

	ApMsgAlert("Func�o n�o permitida em ambiente sem suporte a banco de dados")

#ENDIF

RestArea(aAreaSB1)
RestArea(aAreaSA3)
RestArea(aAreaDA0)
RestArea(aArea)

Return Nil


/*������������������������������������������������������������������������������
��������������������������������������������������������������������������������
����������������������������������������������������������������������������Ŀ��
���Programa   � GetArray   � Autor � Wilson Jorge Tedokon  � Data �20/03/2006���
����������������������������������������������������������������������������Ĵ��
���Descricao  � Monta o aHead e aCol da tabela temporaria UA2 para exibir    ���
���           � a tela de valores x comissoes.                               ���
���           � A tabela UA2 foi criada somente no SX3 para ser utilizada    ���
���           � na exibicao da tela utilizando o objetio GetDados            ���
���           �                                                              ���
�����������������������������������������������������������������������������ٱ�
��������������������������������������������������������������������������������
������������������������������������������������������������������������������*/
Static Function GetArray(aHead, aCol)

Local aCpoGDa   := {"UA2_VALMAX","UA2_VALMIN","UA2_COMISS"}
Local nX        := 0

DbSelectArea("SX3")

SX3->(DbSetOrder(2)) // Campo

For nX := 1 to Len(aCpoGDa)
	If SX3->(DbSeek(aCpoGDa[nX]))
		Aadd(aHead,{ AllTrim(X3Titulo()),;
		SX3->X3_CAMPO	,;
		SX3->X3_PICTURE,;
		SX3->X3_TAMANHO,;
		SX3->X3_DECIMAL,;
		SX3->X3_VALID	,;
		SX3->X3_USADO	,;
		SX3->X3_TIPO	,;
		SX3->X3_F3 		,;
		SX3->X3_CONTEXT,;
		SX3->X3_CBOX	,;
		SX3->X3_RELACAO})
	Endif
Next nX

aAux := {}
For nX := 1 to Len(aCpoGDa)
	If DbSeek(aCpoGDa[nX])
		Aadd(aAux,CriaVar(SX3->X3_CAMPO))
	Endif
Next nX
Aadd(aAux,.F.)
Aadd(aCol,aAux)                    

Return nil


/*������������������������������������������������������������������������������
��������������������������������������������������������������������������������
����������������������������������������������������������������������������Ŀ��
���Programa   �   C()      � Autor � Norbert Waage Junior  � Data �10/05/2005���
����������������������������������������������������������������������������Ĵ��
���Descricao  � Funcao responsavel por manter o Layout independente da       ���
���           � resolu��o horizontal do Monitor do Usuario.                  ���
�����������������������������������������������������������������������������ٱ�
��������������������������������������������������������������������������������
������������������������������������������������������������������������������*/
Static Function C(nTam)
Local nHRes	:=	GetScreenRes()[1]	//Resolucao horizontal do monitor
Do Case
	Case nHRes == 640	//Resolucao 640x480
		nTam *= 0.8
	Case nHRes == 800	//Resolucao 800x600
		nTam *= 1
	OtherWise			//Resolucao 1024x768 e acima
		nTam *= 1.28
End Case
//���������������������������Ŀ
//�Tratamento para tema "Flat"�
//�����������������������������
If (Alltrim(GetTheme()) == "FLAT").Or. SetMdiChild()
   	nTam *= 0.90
EndIf
Return Int(nTam)