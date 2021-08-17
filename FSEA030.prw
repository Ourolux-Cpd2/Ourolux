#INCLUDE "PROTHEUS.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFSEA030   บAutor  ณNorbert Waage Juniorบ Data ณ  13/03/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณTela para selecao dos vendedores cujo o vendedor atual pode บฑฑ
ฑฑบ          ณauxiliar, assumindo a carteira destes.                      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณEletromega                                                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
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

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณAborta a rotina se nao ha dadosณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If Len( aTabs ) == 0
	Aviso( "Sem registros", "Nใo hแ vendedores cadastrados", {"Ok"} )
	Return .F.
Endif

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณMonta interfaceณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
DEFINE MSDIALOG _oDlg FROM 0,0 TO 280,500 PIXEL TITLE "Vendedores" of oMainWnd STYLE DS_MODALFRAME STATUS

//Botoes graficos
DEFINE SBUTTON FROM 10,215 TYPE 1 OF _oDlg ENABLE ONSTOP "Confirma" ACTION (RetTabs(@aTabs),_oDlg:End())
DEFINE SBUTTON FROM 30,215 TYPE 2 OF _oDlg ENABLE ONSTOP "Sair" ACTION (_oDlg:End())

//Botoes texto
@ 123,005 Button _oButMarc Prompt "&Marcar Todos" 		Size 50,10 Pixel Action Marca(1,@aTabs,@_oLbx) Message "Selecionar todos os vendedores" Of _oDlg
@ 123,060 Button _oButDmrc Prompt "&Desmarcar Todos"	Size 50,10 Pixel Action Marca(2,@aTabs,@_oLbx) Message "Desmarcar todos os vendedores" Of _oDlg
@ 123,115 Button _oButInve Prompt "Inverter sele็ใo"	Size 50,10 Pixel Action Marca(3,@aTabs,@_oLbx) Message "Inverte a sele็ใo atual" Of _oDlg

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
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLoadVet   บAutor  ณNorbert Waage Juniorบ Data ณ  13/03/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRotina responsavel pela carga dos arrays utilizados na get- บฑฑ
ฑฑบ          ณdados e na listbox.                                         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณPBKids                                                      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function LoadVet(aVet,cPreSel)

Local aArea		:= GetArea()
Local aAreaSA3	:= SA3->(GetArea())

SA3->(DbSetOrder(1))
SA3->(DbGoTop())

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณCarrega vetor considerando o que ja estava selecionadoณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
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
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณMarca     บAutor  ณNorbert Waage Juniorบ Data ณ  13/03/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRotina para marcar, desmarcar ou inverter a selecao dos     บฑฑ
ฑฑบ          ณprodutos listados no ListBox                                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณEletromega                                                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
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
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณRetTabs   บAutor  ณNorbert Waage Juniorบ Data ณ  13/03/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณGrava os codigos dos vendedores marcados no campo A3_AUXVEN บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณEletromega                                                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function RetTabs(aVet)

Local cRet	:= ""
Local cSep	:= ""
Local nX

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณCria retornoณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤู
For nX := 1 to Len(aVet)
	If aVet[nX][1] == .T.
		cRet += cSep + AllTrim(aVet[nX][2])
		cSep := "/"
	EndIf
Next nX

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณGrava retorno no campoณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
M->A3_AUXVEN := cRet + Space(TamSx3("A3_AUXVEN")[1] - Len(cRet))
xFAUX01 := cRet + Space(TamSx3("A3_AUXVEN")[1] - Len(cRet))
Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFSEA030B  บAutor  ณNorbert Waage Juniorบ Data ณ  14/03/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณValidacao dos codigos das tabelas informadas pelo operador  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณEletromega                                                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function FSEA030b()

Local aArea		:=	GetArea()
Local aAreaSA3	:=	SA3->(GetArea())
Local aValores	:=	LeTabs(AllTrim(M->A3_AUXVEN))
Local nX		:=	1
Local lRet		:=	.T.

DbSelectArea("SA3")
DbSetOrder(1) //A3_FILIAL+A3_COD

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณTesta os valores digitadosณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
While (nX <= Len(aValores)) .And. lRet
	If (lRet := (aValores[nX] != M->A3_COD)) // nX++
		If !(lRet := (DbSeek(xFilial("SA3")+aValores[nX]))) // nX++
			ApMsgStop("Vendedor " + aValores[nX] + " nใo encontrado.","Aten็ใo") // --nX
		EndIf
	Else
		ApMsgStop("A sele็ใo nใo pode conter redundโncias","Aten็ใo")
	End
	nX++
End                       


RestArea(aAreaSA3)
RestArea(aArea)

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLeTabs    บAutor  ณNorbert Waage Juniorบ Data ณ  14/03/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณLe os valores contidos em uma string com separadores        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณEletromega                                                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function LeTabs(cPar,cSep)

Local aRet	:= {}
Local nPos	:= 0
Local cTmp	:= ""

Default cSep := "/"

While Len(cPar) > 0
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณVerifica se existem separadores ou se somente contem umณ
	//ณvalor                                                  ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If (nPos := At(cSep,cPar)) == 0
		cTmp := SubStr(cPar,0,Len(cPar))
		cPar := ""
	Else
		cTmp := SubStr(cPar,0,nPos-1)
		cPar := SubStr(cPar,nPos+1,Len(cPar))
	EndIf
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณAlimenta retornoณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If Len(cTmp) > 0
		AAdd(aRet,cTmp)
	EndIf
	
End

Return aRet

	
/*/{Protheus.doc} FSEA030R
Fun็ใo para retorno da consulta 
@author Roberto Souza
@since 09/08/2017
@version 1.0
/*/
                
// PROJETO_P12
// Roberto Souza
User Function FSEA030R()

Return( xFAUX01 )