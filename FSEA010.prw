#INCLUDE "PROTHEUS.CH"
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �FSEA010   �Autor  �Norbert Waage Junior� Data �  13/03/06   ���
�������������������������������������������������������������������������͹��
���Desc.     �Tela para selecao das tabelas de preco associadas ao vende- ���
���          �dor atual.                                                  ���
�������������������������������������������������������������������������͹��
���Uso       �Eletromega                                                  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function FSEA010()

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

Public xFTAB01  := AllTrim(M->A3_TABPREC) // Publica criada para retorno da pesquisa via SXB

If AllTrim(ReadVar()) != "M->A3_TABPREC"
	Return .T.
EndIf

cPreSel	:=	AllTrim(M->A3_TABPREC)
oOk		:=	LoadBitmap( GetResources(), "LBOK" )
oNo		:=	LoadBitmap( GetResources(), "LBNO" )

//Carrega vetores
LoadVet(@aTabs,cPreSel)

//�������������������������������Ŀ
//�Aborta a rotina se nao ha dados�
//���������������������������������
If Len( aTabs ) == 0
	Aviso( "Sem registros", "N�o h� tabela de pre�os cadastrada", {"Ok"} )
	Return .F.
Endif

//���������������Ŀ
//�Monta interface�
//�����������������
DEFINE MSDIALOG _oDlg FROM 0,0 TO 280,500 PIXEL TITLE "Tabela de pre�os" of oMainWnd STYLE DS_MODALFRAME STATUS

//Botoes graficos
DEFINE SBUTTON FROM 10,215 TYPE 1 OF _oDlg ENABLE ONSTOP "Confirma" ACTION (RetTabs(@aTabs),_oDlg:End())
DEFINE SBUTTON FROM 30,215 TYPE 2 OF _oDlg ENABLE ONSTOP "Sair" ACTION (_oDlg:End())

//Botoes texto
@ 123,005 Button _oButMarc Prompt "&Marcar Todos" 		Size 50,10 Pixel Action Marca(1,@aTabs,@_oLbx) Message "Selecionar todos os produtos" Of _oDlg
@ 123,060 Button _oButDmrc Prompt "&Desmarcar Todos"	Size 50,10 Pixel Action Marca(2,@aTabs,@_oLbx) Message "Desmarcar todos os produtos" Of _oDlg
@ 123,115 Button _oButInve Prompt "Inverter sele��o"	Size 50,10 Pixel Action Marca(3,@aTabs,@_oLbx) Message "Inverte a sele��o atual" Of _oDlg

//Labels
@ 004,003 TO 135,210 LABEL "Tabelas de pre�o dispon�veis:" OF _oDlg PIXEL

//ListBox
@ 10,06 LISTBOX _oLbx FIELDS HEADER " ","Tabela","Descricao" SIZE 200,110 OF _oDlg;
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
Local aAreaDA0	:= DA0->(GetArea())
Local nScan     := 0

DA0->(DbSetOrder(1))
DA0->(DbGoTop())

If Empty(cPreSel)
	cPreSel := padl(alltrim(cPresel),3,"0")                                            
EndIf
//������������������������������������������������������Ŀ
//�Carrega vetor considerando o que ja estava selecionado�
//��������������������������������������������������������
While !DA0->(EOF())
	
	nScan := aScan( aVet, {|x| x[2] == Padl(AllTrim(DA0->DA0_CODTAB),3,"0") } )
	If  nScan < 1 
		aAdd(aVet,{(padl(AllTrim(DA0->DA0_CODTAB),3,"0")$cPreSel), DA0->DA0_CODTAB,DA0->DA0_DESCRI})
	EndIf	
	DA0->(DbSkip())
	
EndDo
          
RestArea(aAreaDA0)
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
���Desc.     �Grava os codigos da tabelas selecionadas no campo A3_TABPREC���
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
M->A3_TABPREC := cRet + Space(TamSx3("A3_TABPREC")[1] - Len(cRet))
xFTAB01  := cRet + Space(TamSx3("A3_TABPREC")[1] - Len(cRet))

Return .T.

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �FSEA010B  �Autor  �Norbert Waage Junior� Data �  14/03/06   ���
�������������������������������������������������������������������������͹��
���Desc.     �Validacao dos codigos das tabelas informadas pelo operador  ���
�������������������������������������������������������������������������͹��
���Uso       �Eletromega                                                  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function FSEA010b()

Local aArea		:=	GetArea()
Local aAreaDA0	:=	DA0->(GetArea())
Local aValores	:=	LeTabs(AllTrim(M->A3_TABPREC))
Local nX		:=	1
Local lRet		:=	.T.

DbSelectArea("DA0")
DbSetOrder(1) //DA0_FILIAL+DA0_CODTAB

//��������������������������Ŀ
//�Testa os valores digitados�
//����������������������������
While (nX <= Len(aValores)) .And. lRet
	lRet := DbSeek(xFilial("DA0")+aValores[nX++])
End

If !lRet
	ApMsgStop("Tabela de pre�os " + aValores[--nX] + " n�o encontrada.","Aten��o")
EndIf

RestArea(aAreaDA0)
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
                        

	
/*/{Protheus.doc} FSEA010R
Fun��o para retorno da consulta 
@author Roberto Souza
@since 09/08/2017
@version 1.0
/*/
                 
// PROJETO_P12
// Roberto Souza
User Function FSEA010R()

Return( xFTAB01 )