#INCLUDE "PROTHEUS.CH"
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �FSEA020   �Autor  �Microsiga           � Data �  03/14/06   ���
�������������������������������������������������������������������������͹��
���Desc.     �Rotina de manutencao do cadastro de faixa de descontos X Co-���
���          �missao                                                      ���
�������������������������������������������������������������������������͹��
���Uso       �Eletromega                                                  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function FSEA020()
 
Private cCadastro	:= "Cadastro de faixa de descontos"
Private aRotina		:=	{{"Pesquisar","AxPesqui",0,1}	,;
						{"Visualizar","AxVisual",0,2}	,;
						{"Incluir","U_FSEA020C",0,3}	,;
						{"Alterar","U_FSEA020C",0,4}	,;
						{"Excluir","U_FSEA020C",0,5}}

dbSelectArea("UA1")
dbSetOrder(1)
mBrowse( 6,1,22,75,"UA1")

Return Nil

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �FSEA020C  �Autor  �Norbert Waage Junior� Data �  14/03/06   ���
�������������������������������������������������������������������������͹��
���Desc.     �Tela de edicao das faixas de desconto x comissao           -���
�������������������������������������������������������������������������͹��
���Uso       �Eletromega                                                  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function FSEA020C(cAlias,nReg,nOpc)

Local cGetTab	:= IIf(INCLUI,Space(TamSx3("DA0_CODTAB")[1]),UA1->UA1_CODTAB)
Local oGetTab	:= Nil
Local aRecnos	:=	{}

Private oDlg
Private oGetD
Private nOpcx	:= nOpc

//����������������Ŀ
//�Montagem da tela�
//������������������
DEFINE MSDIALOG oDlg TITLE "Faixas de desconto X Comiss�o" FROM C(374),C(369) TO C(641),C(905) PIXEL

// Box
@ C(004),C(005) TO C(026),C(080) LABEL "Tabela de pre�os:" PIXEL OF oDlg

// Gets
@ C(012),C(014) MsGet oGetTab Var cGetTab Valid (ExistCpo("DA0",cGetTab,1) .And. ExistChav("UA1",cGetTab,1));
 F3 "DA0" WHEN INCLUI Size C(035),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg

// Chamadas das GetDados do Sistema
foGetD(@aRecnos)

//Botoes
DEFINE SBUTTON FROM C(004),C(225) TYPE 1 Action(GrvUA1(cGetTab,aRecnos),oDlg:End()) ENABLE OF oDlg
DEFINE SBUTTON FROM C(004),C(190) TYPE 2 Action(oDlg:End())  ENABLE OF oDlg

ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �foGetD    �Autor  �Norbert Waage Junior� Data �  14/03/06   ���
�������������������������������������������������������������������������͹��
���Desc.     �Criacao da GetDados para digitacao dos valores              ���
�������������������������������������������������������������������������͹��
���Uso       �Eletromega                                                  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function foGetD(aRecnos)

Local nX			:= 0
Local aCpoGDa      	:= {"UA1_DESCDE","UA1_DESCAT","UA1_COMISS","UA1_CODINT","UA1_CODEXT"}
Local aAlter       	:= {"UA1_DESCAT","UA1_COMISS","UA1_CODINT","UA1_CODEXT"}
Local nSuperior    	:= C(032)
Local nEsquerda    	:= C(001)
Local nInferior    	:= C(133)
Local nDireita     	:= C(266)
Local nOpcA			:= IIF(!Inclui.And.!Altera,0,GD_INSERT+GD_UPDATE+GD_DELETE)
Local cLinOk       	:= "AllwaysTrue"    // Funcao executada para validar o contexto da linha atual do aCols
Local cTudoOk      	:= "AllwaysTrue"    // Funcao executada para validar o contexto geral da MsNewGetDados (todo aCols)
Local cIniCpos     	:= ""               // Nome dos campos do tipo caracter que utilizarao incremento automatico.
Local nFreeze      	:= 000              // Campos estaticos na GetDados.
Local nMax         	:= 999              // Numero maximo de linhas permitidas. Valor padrao 99
Local cFieldOk     	:= "AllwaysTrue"    // Funcao executada na validacao do campo
Local cSuperDel    	:= ""              // Funcao executada quando pressionada as teclas <Ctrl>+<Delete>
Local cDelOk       	:= "U_FSEA020D"   // Funcao executada para validar a exclusao de uma linha do aCols
Local oWnd         	:= oDlg
Local aHead       	:= {}               // Array a ser tratado internamente na MsNewGetDados como aHeader
Local aCol         	:= {}               // Array a ser tratado internamente na MsNewGetDados como aCols

Static lCtrlLine := .T.

//������������������
//�Carga do aheader�
//������������������
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

//��������������Ŀ
//�Carga do aCols�
//����������������
aAux := {}
For nX := 1 to Len(aCpoGDa)
	If DbSeek(aCpoGDa[nX])
		Aadd(aAux,CriaVar(SX3->X3_CAMPO))
	Endif
Next nX
Aadd(aAux,.F.)
Aadd(aCol,aAux)

If !INCLUI
	U_LoadGD("UA1",@aHead,@aCol,@aRecnos,1,xFilial("UA1")+UA1->UA1_CODTAB)
EndIF

//���������������������Ŀ
//�Cria objeto oGetDados�
//�����������������������
oGetD:= MsNewGetDados():New(nSuperior,nEsquerda,nInferior,nDireita,nOpcA,cLinOk,cTudoOk,cIniCpos,;
aAlter,nFreeze,nMax,cFieldOk,cSuperDel,cDelOk,oWnd,aHead,aCol)

//�������������������������������������������������������Ŀ
//�Altera o numero da coluna selecionada apos a mudanca de�
//�linha da GetDados                                      �
//���������������������������������������������������������
oGetD:oBrowse:bNoAltered	:= 	{|| lCtrlLine := .T.}
oGetD:oBrowse:bDrawselect	:=	{||Iif(lCtrlLine,(U_FSE020L(oGetD:oBrowse:nAt),;
								oGetD:oBrowse:Refresh(),lCtrlLine := .F.),.F.)}

Return Nil      

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �FSE020L   �Autor  �Norbert Waage Junior� Data �  14/03/06   ���
�������������������������������������������������������������������������͹��
���Desc.     �Rotina acionada no evento da criacao de uma nova linha na   ���
���          �getdados, utilizada para definir o % de desconto inicial    ���
�������������������������������������������������������������������������͹��
���Uso       �Eletromega                                                  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function FSE020L(nLin)

Local lRet 		:= .T.
Local lAltera	:= .F.
Local nLinRef	:= nLin
Local nPLimInf	:= aScan(oGetD:aHeader,{|x| AllTrim(x[2]) == "UA1_DESCDE"})
Local nPLimSup	:= aScan(oGetD:aHeader,{|x| AllTrim(x[2]) == "UA1_DESCAT"})

//�����������������������������Ŀ
//�Procura a ultima linha valida�
//�������������������������������
While nLin >=2
	If !aTail(oGetD:aCols[nLin-1])
		lAltera := .T.
		Exit
	Else
		nLin--
	EndIf
End

//��������������������������������������������������������Ŀ
//�Se encontrou, atualiza a nova linha e posiciona no campo�
//�correto                                                 �
//����������������������������������������������������������
If lAltera
	oGetD:aCols[nLinRef][nPLimInf]	:= oGetD:aCols[nLin-1][nPLimSup] + 0.01
	oGetD:oBrowse:nColPos			:= nPLimSup
EndIf

Return lRet

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �FSEA020V  �Autor  �Norbert Waage Junior� Data �  03/15/06   ���
�������������������������������������������������������������������������͹��
���Desc.     �Validacao do campo UA1_DESCAT. Nao permite valores na ordem ���
���          �inversa (decrescente) ou menores que o desconto minimo.     ���
�������������������������������������������������������������������������͹��
���Uso       �Eletromega                                                  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function FSEA020V()

Local nValor	:=	&(ReadVar())
Local nPLimInf	:= aScan(oGetD:aHeader,{|x| AllTrim(x[2]) == "UA1_DESCDE"})
Local nPLimSup	:= aScan(oGetD:aHeader,{|x| AllTrim(x[2]) == "UA1_DESCAT"})
Local lRet		:= .T.

If !(lRet := nValor >= oGetD:aCols[N][nPLimInf])
	ApMsgStop("O valor informado n�o pode ser menor que o conteudo do campo '%Desc. De' informado nesta linha","Valida��o")
EndIf

If lRet .And. (nValor == oGetD:aCols[N][nPLimInf])
	lRet := .F.
	ApMsgStop("O valor informado n�o pode ser igual ao conteudo do campo '%Desc. De' informado nesta linha","Valida��o")
EndIf

Return lRet
                          
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �FSEA020D  �Autor  �Norbert Waage Junior� Data �  15/03/06   ���
�������������������������������������������������������������������������͹��
���Desc.     �Valida a delecao da linha                                   ���
�������������������������������������������������������������������������͹��
���Uso       �Eletromega                                                  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function FSEA020D()

Local lRet		:= .T.
Local nPLimInf	:= aScan(oGetD:aHeader,{|x| AllTrim(x[2]) == "UA1_DESCDE"})
Local nPLimSup	:= aScan(oGetD:aHeader,{|x| AllTrim(x[2]) == "UA1_DESCAT"})
Local nTamGet	:=	Len(oGetD:aCols)
Local nX

//��������������������������������������������������������Ŀ
//�Pesquisa proxima linha valida e altera seu percentual de�
//�desconto inicial baseando-se na ultima linha valida     �
//����������������������������������������������������������
If !aTail(oGetD:aCols[oGetD:nAt])
 
	If nTamGet > oGetD:nAt
	
		For nX := (oGetD:nAt + 1) to nTamGet
	
			If !aTail(oGetD:aCols[nX])
	
				oGetD:aCols[nX][nPLimInf] := oGetD:aCols[oGetD:nAt][nPLimInf]
				nX	:= nTamGet + 1
				
			EndIf
	
		Next
	
	EndIf

Else

	//����������������������������������������������������������Ŀ
	//�Impede a recuperacao da linha para nao causar conflito de �
	//�valores                                                   �
	//������������������������������������������������������������
	If (nTamGet > oGetD:nAt)

		ApMsgStop("Esta linha n�o pode ser recuperada","Aten��o")
		lRet := .F.

	EndIf

EndIf

Return lRet


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �GrvUA1    �Autor  �Norbert Waage Junior� Data �  15/03/06   ���
�������������������������������������������������������������������������͹��
���Desc.     �Grava os registros da tabela de descontos x comissao        ���
�������������������������������������������������������������������������͹��
���Uso       �Eletromega                                                  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function GrvUA1(cCodTab,aRecnos)

//����������������������Ŀ
//�Gravacao dos registros�
//������������������������
Local aCpoFixo	:= {}

If ALTERA .Or. INCLUI

	//���������������������Ŀ
	//�Inclusao ou alteracao�
	//�����������������������
	AAdd(aCpoFixo,{"UA1_CODTAB",cCodTab})
	U_GetToFile("UA1",1,oGetD:aHeader,oGetD:aCols,aRecnos,aCpoFixo)

ElseIf nOpcX == 5

	//��������Ŀ
	//�Exclusao�
	//����������
	UA1->(DbSetOrder(1))
	UA1->(DbSeek(xFilial("UA1")+cCodTab))
	
	While	!UA1->(Eof()) .And.;
			(UA1->(UA1_FILIAL+UA1_CODTAB) == xFilial("UA1")+cCodTab)
		
		RecLock("UA1",.F.)
		DbDelete()
		MsUnLock()
		
		UA1->(DbSkip())
		
	End

EndIf

Return Nil

/*������������������������������������������������������������������������������
��������������������������������������������������������������������������������
����������������������������������������������������������������������������Ŀ��
���Programa   �   C()   � Autores � Norbert/Ernani/Mansano � Data �10/05/2005���
����������������������������������������������������������������������������Ĵ��
���Descricao  � Funcao responsavel por manter o Layout independente da       ���
���           � resolucao horizontal do Monitor do Usuario.                  ���
�����������������������������������������������������������������������������ٱ�
��������������������������������������������������������������������������������
������������������������������������������������������������������������������*/
Static Function C(nTam)
Local nHRes	:=	oMainWnd:nClientWidth	// Resolucao horizontal do monitor
If nHRes == 640	// Resolucao 640x480 (soh o Ocean e o Classic aceitam 640)
	nTam *= 0.8
ElseIf (nHRes == 798).Or.(nHRes == 800)	// Resolucao 800x600
	nTam *= 1
Else	// Resolucao 1024x768 e acima
	nTam *= 1.28
EndIf

//���������������������������Ŀ
//�Tratamento para tema "Flat"�
//�����������������������������
If "MP8" $ oApp:cVersion
	If (Alltrim(GetTheme()) == "FLAT") .Or. SetMdiChild()
		nTam *= 0.90
	EndIf
EndIf
Return Int(nTam)