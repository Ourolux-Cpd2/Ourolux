#INCLUDE "PROTHEUS.CH"
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �FSEA030   �Autor  �Norbert Waage Junior� Data �  13/03/06   ���
�������������������������������������������������������������������������͹��
���Desc.     �Tela para selecao dos vendedores cujo o vendedor atual pode ���
���          �auxiliar, assumindo a carteira destes.                      ���
�������������������������������������������������������������������������͹��
���Uso       �Eletromega                                                  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function FSEA030()

Local oOk		:= Nil										//Imagem "Marcado"
Local oNo		:= Nil										//Imagem "Desmarcado"
Local aTabs		:= {}										//Array com as tabelas de preco
Local cPreSel	:= ""										//Conteudo atual do campo A3_TABPREC
Local _oButMarc	:=	Nil										//Objeto Botao Marca
Local _oButDmrc	:=	Nil										//Objeto Botao Desmarca
Local _oButInve	:=	Nil										//Objeto Botao Inverte selecao

Private _oDlg	:=	Nil		//Objeto Dialog
Private _oLbx	:=	Nil		//Objeto ListBox
Private _oBmp	:=	NIL		//Objeto Bitmap
 
Public xFAUX01  := AllTrim(M->A3_AUXVEN) // Publica criada para retorno da pesquisa via SXB
	
If AllTrim(ReadVar()) != "M->A3_AUXVEN"
	Return .T.
EndIf

cPreSel	:=	AllTrim(M->A3_AUXVEN)
oOk		:=	LoadBitmap( GetResources(), "LBOK" )
oNo		:=	LoadBitmap( GetResources(), "LBNO" )

//Carrega vetores
LoadVet(@aTabs,cPreSel)

//�������������������������������Ŀ
//�Aborta a rotina se nao ha dados�
//���������������������������������
If Len( aTabs ) == 0
	Aviso( "Sem registros", "N�o h� vendedores cadastrados", {"Ok"} )
	Return .F.
Endif

//���������������Ŀ
//�Monta interface�
//�����������������
DEFINE MSDIALOG _oDlg FROM 0,0 TO 280,500 PIXEL TITLE "Vendedores" of oMainWnd STYLE DS_MODALFRAME STATUS

//Botoes graficos
DEFINE SBUTTON FROM 10,215 TYPE 1 OF _oDlg ENABLE ONSTOP "Confirma" ACTION (RetTabs(@aTabs),_oDlg:End())
DEFINE SBUTTON FROM 30,215 TYPE 2 OF _oDlg ENABLE ONSTOP "Sair" ACTION (_oDlg:End())

//Botoes texto
@ 123,005 Button _oButMarc Prompt "&Marcar Todos" 		Size 50,10 Pixel Action Marca(1,@aTabs,@_oLbx) Message "Selecionar todos os vendedores" Of _oDlg
@ 123,060 Button _oButDmrc Prompt "&Desmarcar Todos"	Size 50,10 Pixel Action Marca(2,@aTabs,@_oLbx) Message "Desmarcar todos os vendedores" Of _oDlg
@ 123,115 Button _oButInve Prompt "Inverter sele��o"	Size 50,10 Pixel Action Marca(3,@aTabs,@_oLbx) Message "Inverte a sele��o atual" Of _oDlg

//Labels
@ 004,003 TO 135,210 LABEL "Vendedores cadastrados:" OF _oDlg PIXEL

//ListBox
@ 10,06 LISTBOX _oLbx FIELDS HEADER " ","Vendedor","Nome" SIZE 200,110 OF _oDlg;
PIXEL ON dblClick(aTabs[_oLbx:nAt,1] := !aTabs[_oLbx:nAt,1],_oLbx:Refresh())

//Metodos da ListBox
_oLbx:SetArray(aTabs)
_oLbx:bLine 	:= {|| {Iif(aTabs[_oLbx:nAt,1],oOk,oNo),;
aTabs[_oLbx:nAt,2],;
aTabs[_oLbx:nAt,3]}}

ACTIVATE MSDIALOG _oDlg	CENTERED

Return .T.

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �LoadVet   �Autor  �Norbert Waage Junior� Data �  13/03/06   ���
�������������������������������������������������������������������������͹��
���Desc.     �Rotina responsavel pela carga dos arrays utilizados na get- ���
���          �dados e na listbox.                                         ���
�������������������������������������������������������������������������͹��
���Uso       �PBKids                                                      ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function LoadVet(aVet,cPreSel)

Local aArea		:= GetArea()
Local aAreaSA3	:= SA3->(GetArea())

SA3->(DbSetOrder(1))
SA3->(DbGoTop())

//������������������������������������������������������Ŀ
//�Carrega vetor considerando o que ja estava selecionado�
//��������������������������������������������������������
While !SA3->(EOF())
	
	If SA3->A3_COD != M->A3_COD
		aAdd(aVet,{(AllTrim(SA3->A3_COD)$cPreSel), SA3->A3_COD,SA3->A3_NOME})
	EndIf
	SA3->(DbSkip())
	
EndDo
          
RestArea(aAreaSA3)
RestArea(aArea)

Return Nil     
                       
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �Marca     �Autor  �Norbert Waage Junior� Data �  13/03/06   ���
�������������������������������������������������������������������������͹��
���Desc.     �Rotina para marcar, desmarcar ou inverter a selecao dos     ���
���          �produtos listados no ListBox                                ���
�������������������������������������������������������������������������͹��
���Uso       �Eletromega                                                  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function Marca(nOp,aVet,oObj)

Local lMarca
Local i

If nOp == 1 		//Marca todos
	lMarca	:=	.T.
ElseIf nOp == 2		//Desmarca Todos
	lMarca	:=	.F.
Endif

If lMarca != NIL
	For i := 1 To Len(aVet)
		aVet[i][1] := lMarca
	Next i
Else	//Inverte Selecao
	For i := 1 To Len(aVet)
		aVet[i][1] := !aVet[i][1]
	Next i
EndIf

oObj:Refresh()	//Atualiza Listbox

Return Nil

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �RetTabs   �Autor  �Norbert Waage Junior� Data �  13/03/06   ���
�������������������������������������������������������������������������͹��
���Desc.     �Grava os codigos dos vendedores marcados no campo A3_AUXVEN ���
�������������������������������������������������������������������������͹��
���Uso       �Eletromega                                                  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function RetTabs(aVet)

Local cRet	:= ""
Local cSep	:= ""
Local nX

//������������Ŀ
//�Cria retorno�
//��������������
For nX := 1 to Len(aVet)
	If aVet[nX][1] == .T.
		cRet += cSep + AllTrim(aVet[nX][2])
		cSep := "/"
	EndIf
Next nX

//����������������������Ŀ
//�Grava retorno no campo�
//������������������������
M->A3_AUXVEN := cRet + Space(TamSx3("A3_AUXVEN")[1] - Len(cRet))
xFAUX01 := cRet + Space(TamSx3("A3_AUXVEN")[1] - Len(cRet))
Return .T.

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �FSEA030B  �Autor  �Norbert Waage Junior� Data �  14/03/06   ���
�������������������������������������������������������������������������͹��
���Desc.     �Validacao dos codigos das tabelas informadas pelo operador  ���
�������������������������������������������������������������������������͹��
���Uso       �Eletromega                                                  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function FSEA030b()

Local aArea		:=	GetArea()
Local aAreaSA3	:=	SA3->(GetArea())
Local aValores	:=	LeTabs(AllTrim(M->A3_AUXVEN))
Local nX		:=	1
Local lRet		:=	.T.

DbSelectArea("SA3")
DbSetOrder(1) //A3_FILIAL+A3_COD

//��������������������������Ŀ
//�Testa os valores digitados�
//����������������������������
While (nX <= Len(aValores)) .And. lRet
	If (lRet := (aValores[nX] != M->A3_COD)) // nX++
		If !(lRet := (DbSeek(xFilial("SA3")+aValores[nX]))) // nX++
			ApMsgStop("Vendedor " + aValores[nX] + " n�o encontrado.","Aten��o") // --nX
		EndIf
	Else
		ApMsgStop("A sele��o n�o pode conter redund�ncias","Aten��o")
	End
	nX++
End                       


RestArea(aAreaSA3)
RestArea(aArea)

Return lRet

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �LeTabs    �Autor  �Norbert Waage Junior� Data �  14/03/06   ���
�������������������������������������������������������������������������͹��
���Desc.     �Le os valores contidos em uma string com separadores        ���
�������������������������������������������������������������������������͹��
���Uso       �Eletromega                                                  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function LeTabs(cPar,cSep)

Local aRet	:= {}
Local nPos	:= 0
Local cTmp	:= ""

Default cSep := "/"

While Len(cPar) > 0
	
	//�������������������������������������������������������Ŀ
	//�Verifica se existem separadores ou se somente contem um�
	//�valor                                                  �
	//���������������������������������������������������������
	If (nPos := At(cSep,cPar)) == 0
		cTmp := SubStr(cPar,0,Len(cPar))
		cPar := ""
	Else
		cTmp := SubStr(cPar,0,nPos-1)
		cPar := SubStr(cPar,nPos+1,Len(cPar))
	EndIf
	
	//����������������Ŀ
	//�Alimenta retorno�
	//������������������
	If Len(cTmp) > 0
		AAdd(aRet,cTmp)
	EndIf
	
End

Return aRet

	
/*/{Protheus.doc} FSEA030R
Fun��o para retorno da consulta 
@author Roberto Souza
@since 09/08/2017
@version 1.0
/*/
                
// PROJETO_P12
// Roberto Souza
User Function FSEA030R()

Return( xFAUX01 )