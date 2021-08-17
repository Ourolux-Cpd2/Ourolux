#INCLUDE "PROTHEUS.CH"

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �FSEC001   � Autor � Norbert Waage Junior  � Data �28/08/2005���
�������������������������������������������������������������������������Ĵ��
���Descricao � Rotina de consulta de clientes, respeitando o filtro de    ���
���          � clientes vinculados ao vendedor atual                      ���
�������������������������������������������������������������������������Ĵ��
���Parametros�Nao se aplica                                               ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �(.F.) se a consulta foi cancelada ou nao encontrou itens;   ���
���          �(.T.) se confirmada                                         ���
�������������������������������������������������������������������������Ĵ��
���Aplicacao �F3 da pesquisa de sinistros na Venda Assistida              ���
�������������������������������������������������������������������������Ĵ��
���Analista Resp.�  Data  � Bops � Manutencao Efetuada                    ���
�������������������������������������������������������������������������Ĵ��
���              �  /  /  �      �                                        ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
User Function FSEC001()

Local aCli 		:= {}
Local lRet 		:= .F.
Local cPesq		:= Space(40)
Local cVar		:= ReadVar()
Local cPreSel	:= If(Left(cVar,3) == "M->",&(cVar),"")
Local oCombo	:= Nil
Local aChave	:= {"C�digo+Loja","Nome do cliente","Cnpj"} // Claudino adicionei Cnpj 10/11/15
Local cChave	:= ""

Private _oDlg
Private _oLbx

//���������������������������������������Ŀ
//�Faz pesquisa dos clientes com query SQL�
//�����������������������������������������
ProcCli(@aCli)	

//������������������������������������������������Ŀ
//�Aborta rotina se n�o foram encontrados registros�
//��������������������������������������������������
If Len(aCli) == 0
	ApMsgAlert("Sem clientes para visualizar","Aten��o")
	Return .F.
EndIf

//���������������Ŀ
//�Exibe interface�
//�����������������
DEFINE MSDIALOG _oDlg TITLE "Sele��o de Clientes" FROM C(0),C(0) TO C(355),C(390) PIXEL
	
	//�����������������������������������Ŀ
	//�Cria Componentes Padroes do Sistema�
	//�������������������������������������
	@ C(004),C(155) Button "Pesquisa" Size C(037),C(010) PIXEL OF _oDlg Action(Pesq(cPesq,@aCli,cChave))
	@ C(166),C(004) Button "Confirma" Size C(037),C(010) PIXEL OF _oDlg Action(SetSA1(@aCli,@lRet))
	@ C(166),C(044) Button "Cancela"  Size C(037),C(010) PIXEL OF _oDlg Action(_oDlg:End())

	//��������������������������������������������������������
	//�Bot�o prospect liberado apenas para os administradores�
	//��������������������������������������������������������
	If U_IsAdm() .And. IsInCallStack("TMKA271")
		@ C(166),C(084) Button "Prospect" Size C(037),C(010) PIXEL OF _oDlg Action(_oDlg:End(),lRet:=TMKPO())
	EndIf
	
	//�����Ŀ
	//�Combo�
	//�������
	@ C(004),C(004) COMBOBOX oCombo VAR cChave ITEMS aChave SIZE C(149),C(021) PIXEL OF _oDlg 

	//����������������Ŀ
	//�Metodos do combo�
	//������������������
	oCombo:bChange := {|| U_FC001B(cChave,@aCli)}
	
	//�����Ŀ
	//�MsGet�
	//�������
	@ C(016),C(004) MSGET cPesq SIZE C(149), C(09) OF _oDlg PIXEL
	
	//�������Ŀ
	//�Listbox�
	//���������
	@ C(32),C(4) LISTBOX _oLbx FIELDS HEADER "Codigo","Loja","Nome","Cnpj"; // Claudino adicionei Cnpj 10/11/15
	SIZE C(190),C(130) OF _oDlg PIXEL ON dblClick(SetSA1(@aCli,@lRet))  
		
	//������������������Ŀ
	//�Metodos da ListBox�
	//��������������������
	_oLbx:SetArray(aCli)

	If !Empty(cPreSel)
		//���������������������������Ŀ
		//�Pesquisa cliente na listbox�
		//�����������������������������
		If (_oLbx:nAt := aScan(aCli,{|x| x[1] == cPreSel})) == 0
			//���������������������������������������������������������������Ŀ
			//�Previne array out of bounds, caso o cliente digitado nao exista�
			//�����������������������������������������������������������������
			_oLbx:nAt := 1
		EndIf
	EndIf

	_oLbx:bLine := {||{	aCli[_oLbx:nAt,1]	,;	//Codigo
						aCli[_oLbx:nAt,2]	,;	//Loja
						aCli[_oLbx:nAt,3]	,;	//Nome
						aCli[_oLbx:nAt,4]	}}	//Cnpj // Claudino adicionei Cnpj 10/11/15

ACTIVATE MSDIALOG _oDlg CENTERED 

Return lRet

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �FSEC001   �Autor  �Microsiga           � Data �  04/05/06   ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function FSEC001B()

Local lRet     := .F.
Local cConsult := ""

cConsult := IIf(IsInCallStack("TMKA271"),"FSE03","CLI")

If lTK271Auto 
	Return .T.
EndIf
	
If U_IsAdm() .Or. U_IsFree() 
	lRet := Conpad1(,,,cConsult,,.F.,.F.)
Else
	lRet := U_FSEC001()  // Consulta SA1 filtrada
EndIf

Return lRet

/*
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
����������������������������������������������������������������������������ͻ��
���Programa  � SetSA1          �Autor �Norbert Waage Junior �Data � 28/08/05 ���
����������������������������������������������������������������������������͹��
���Descricao � Posiciona a tabela de clientes                                ���
����������������������������������������������������������������������������͹��
���Parametros� aCli   - Array que contem registros de clientes               ���
���          � lRet    - Retorno da funcao a ser tratado                     ���
����������������������������������������������������������������������������͹��
���Retorno   � Nao se aplica                                                 ���
����������������������������������������������������������������������������͹��
���Aplicacao � Funcao generica                                               ���
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
Static Function SetSA1(aCli,lRet)

//��������������Ŀ
//�Posiciona Area�
//����������������
DbSelectArea("SA1")
DbGoTo(aCli[_oLbx:nAt,5]) // Claudino 10/11/15 alterei a posi��o no listbox, de 4 para 5 isso pq adicionei o CNPJ antes do RECNO

//���������������������������������������������Ŀ
//�Finaliza interface e atribui valor de retorno�
//�����������������������������������������������
_oDlg:End()
lRet:= .T.

M->UA_LOJA := aCli[_oLbx:nAt,2]    // WAR 06-11-06

Return Nil
                
/*
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
����������������������������������������������������������������������������ͻ��
���Programa  � ProcCli         �Autor �Norbert Waage Junior �Data � 28/08/05 ���
����������������������������������������������������������������������������͹��
���Descricao � Execucao de query para ambiente TopConnect                    ���
����������������������������������������������������������������������������͹��
���Parametros�aCli    - Array contendo registros de clientes                 ��� 
����������������������������������������������������������������������������͹��
���Retorno   � Nao se aplica                                                 ���
����������������������������������������������������������������������������͹��
���Aplicacao � Geracao da lista de clientes                                  ���
����������������������������������������������������������������������������͹��
���Analista  � Data   �Bops  �Manutencao Efetuada                            ���
����������������������������������������������������������������������������͹��
���          �        �      �                                               ���
����������������������������������������������������������������������������͹��
���Uso       �13797 - Della Via Pneus                                        ���
����������������������������������������������������������������������������ͼ��
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
*/
Static Function ProcCli(aCli)

Local aArea		:=	GetArea()
Local cVends	:=	""
Local lAdm		:=	U_IsAdm()
Local cQuery

//������������������������������������������������������Ŀ
//�A rotina foi desenvolvida exclusivamente para ambiente�
//�TOPCONNECT                                            �
//��������������������������������������������������������
#IFDEF TOP
    
	//������������������������������������������������Ŀ
	//�Encerra area temporaria caso ja estivesse em uso�
	//��������������������������������������������������
	If Select("TMP") != 0
		TMP->(DbCloseArea())
	EndIf
	
	If !(U_IsAdm() .OR. U_IsFree())
		U_ListaVnd(@cVends)
	EndIf
	
	//�������������Ŀ
	//�Monta a query�
	//���������������
	cQuery	:= "SELECT A1_COD,A1_LOJA,A1_NOME,A1_CGC,R_E_C_N_O_" // Claudino adicionei Cnpj 10/11/15
	cQuery	+= " FROM " + RetSqlName("SA1")
	cQuery	+= " WHERE D_E_L_E_T_ = '' AND A1_FILIAL = '" + xFilial("SA1") + "'"

	//�������Ŀ
	//�Filtros�
	//���������

	If Substr(cNumEmp,1,2) == '02'  //Ourolux
		cQuery += " AND A1_EST = 'SP' "
	EndIf
	
	If !(U_IsAdm() .OR. U_IsFree())
		cQuery	+= " AND (A1_VEND IN " + FormatIn(cVends,"/")
		If U_IsDireto()
			
			cQuery +=" OR A1_COD BETWEEN '500000' AND '599999' " //Vendedor Direto
		
		EndIf
		
		cQuery += " )"
		
		
		If !U_IsCliente()
			cQuery += " OR (A1_VEND = '888888')"      // Vendedor para Or�amento war 23-06-06
	    EndIf
	EndIf
	
	If  ( U_IsFree() )
		cQuery += " AND A1_VEND <> '000000' " 		
	EndIf
	
	//������Ŀ
	//�Orderm�
	//��������
	cQuery	+= " ORDER BY A1_COD,A1_LOJA"
	
	//�����������������������������������������Ŀ
	//�Prepara e executa query no banco de dados�
	//�������������������������������������������
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TMP",.F.,.T.)

	//�����������������������������������������������������������Ŀ
	//�Percorre retorno, alimentando o array aCli com os dados dos�
	//�clientes                                                   �
	//�������������������������������������������������������������
	DbSelectArea("TMP")
	DbGoTop()

	While !TMP->(Eof())

		AAdd(aCli,;
			{TMP->A1_COD		,;	//Codigo do cliente
			TMP->A1_LOJA		,;	//Loja do cliente
			TMP->A1_NOME		,;	//Nome do cliente
			TMP->A1_CGC			,;	//Cnpj Cliente // Claudino adicionei Cnpj 10/11/15
			TMP->R_E_C_N_O_		})	//Numero do registro
			
		TMP->(DbSkip())

	End
	
	//����������������������������Ŀ
	//�Finaliza ambiente temporario�
	//������������������������������
	TMP->(DbCloseArea())

#ELSE

	ApMsgAlert("Func�o n�o permitida em ambiente sem suporte a banco de dados")

#ENDIF

RestArea(aArea)

Return Nil


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


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �FSEC001   �Autor  �Microsiga           � Data �  04/05/06   ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function Pesq(cPesq,aCli,cChave)
                       
Local nTam	:= Len(cPesq := AllTrim(cPesq))
Local bPesq	:= NIL
Local nPos	:= 0

//�����������������������������Ŀ
//�Considera a chave de pesquisa�
//�������������������������������
If cChave == "C�digo+Loja"
	bPesq := {|x| Left((x[1]+x[2]),nTam) == cPesq }
ElseIf cChave == "Nome do cliente"
	bPesq := {|x| Left((x[3]),nTam) == cPesq }
Else // Cnpj // Claudino adicionei Cnpj 10/11/15
	bPesq := {|x| Left((x[4]),nTam) == cPesq }
EndIf

//���������������Ŀ
//�Realiza a busca�
//�����������������
nPos := aScan(aCli,bPesq)

//����������������Ŀ
//�Atualiza listbox�
//������������������
If nPos != 0
	_oLbx:nAt := nPos
	_oLbx:Refresh()
EndIf

Return Nil


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �FSEC001   �Autor  �Microsiga           � Data �  04/05/06   ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function FC001B(cChave,aCli)

If cChave == "Nome do cliente"
	aSort(aCli,,,{|x,y| x[3] < y[3]})
ElseIf cChave == "Cnpj" // Claudino adicionei Cnpj 10/11/15
	aSort(aCli,,,{|x,y| x[4] < y[4]})
Else
	aSort(aCli,,,{|x,y| x[1]+x[2] < y[1]+y[2]})
EndIf
                                                 
_oLbx:SetArray(aCli)
_oLbx:bLine := {||{	aCli[_oLbx:nAt,1]	,;	//Codigo
					aCli[_oLbx:nAt,2]	,;	//Loja
					aCli[_oLbx:nAt,3]	,;	//Nome
					aCli[_oLbx:nAt,4]	}}	//Cnpj // Claudino adicionei Cnpj 10/11/15
_oLbx:Refresh()

Return Nil