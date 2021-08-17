#INCLUDE "PROTHEUS.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ FSQB010  º Autor ³                    º Data ³              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Tela para selecao dos departamentos associados ao aprovador.º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function FSQB010()

	Local oOk		:= Nil		// Imagem "Marcado"
	Local oNo		:= Nil		// Imagem "Desmarcado"
	Local aDepart	:= {}		// Array com os departamentos selecionados
	Local cPreSel	:= ""		// Conteudo atual do campo M->AK_XDEPART
	Local _oButMarc	:=	Nil		// Objeto Botao Marca
	Local _oButDmrc	:=	Nil		// Objeto Botao Desmarca
	Local _oButInve	:=	Nil		// Objeto Botao Inverte selecao
	
	Private _oDlg	:=	Nil		// Objeto Dialog
	Private _oLbx	:=	Nil		// Objeto ListBox
	Private _oBmp	:=	NIL		// Objeto Bitmap

	Public xFSAK01  := AllTrim(M->AK_XDEPART) // Publica criada para retorno da pesquisa via SXB
	
	If AllTrim(ReadVar()) != "M->AK_XDEPART"
		Return .T.
	EndIf
	
	cPreSel	:=	AllTrim(M->AK_XDEPART)
	oOk		:=	LoadBitmap( GetResources(), "LBOK" )
	oNo		:=	LoadBitmap( GetResources(), "LBNO" )
	
	// Carrega vetores
	LoadVet(@aDepart,cPreSel)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Aborta a rotina se nao ha dados³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Len( aDepart ) == 0
		Aviso( "Sem registros", "Não há departamentos cadastrados", {"Ok"} )
		Return .F.
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Monta interface³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DEFINE MSDIALOG _oDlg FROM 0,0 TO 280,500 PIXEL TITLE "Departamentos" of oMainWnd STYLE DS_MODALFRAME STATUS
	
		// Botoes graficos
		DEFINE SBUTTON FROM 10,215 TYPE 1 OF _oDlg ENABLE ONSTOP "Confirma" ACTION (RetSQB(@aDepart),_oDlg:End())
		DEFINE SBUTTON FROM 30,215 TYPE 2 OF _oDlg ENABLE ONSTOP "Sair" ACTION (_oDlg:End())
	
		// Botoes texto
		@ 123,005 Button _oButMarc Prompt "&Marcar Todos" 		Size 50,10 Pixel Action Marca(1,@aDepart,@_oLbx) Message "Selecionar todos os Departamentos" Of _oDlg
		@ 123,060 Button _oButDmrc Prompt "&Desmarcar Todos"	Size 50,10 Pixel Action Marca(2,@aDepart,@_oLbx) Message "Desmarcar todos os Departamentos" Of _oDlg
		@ 123,115 Button _oButInve Prompt "Inverter seleção"	Size 50,10 Pixel Action Marca(3,@aDepart,@_oLbx) Message "Inverte a seleção atual" Of _oDlg
	
		// Labels
		@ 004,003 TO 135,210 LABEL "Departamentos Disponíveis:" OF _oDlg PIXEL
	
		// ListBox
		@ 10,06 LISTBOX _oLbx FIELDS HEADER " ","Cod Departamento","Descricao Departamento" SIZE 200,110 OF _oDlg;
		PIXEL ON dblClick(aDepart[_oLbx:nAt,1] := !aDepart[_oLbx:nAt,1],_oLbx:Refresh())
	
		// Metodos da ListBox
		_oLbx:SetArray(aDepart)
		_oLbx:bLine 	:= {|| {Iif(aDepart[_oLbx:nAt,1],oOk,oNo),;
		aDepart[_oLbx:nAt,2],;
		aDepart[_oLbx:nAt,3]}}
	
	ACTIVATE MSDIALOG _oDlg	CENTERED

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ LoadVet  º Autor ³                    º Data ³              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Rotina responsavel pela carga dos arrays utilizados na get- º±±
±±º          ³ dados e na listbox.                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function LoadVet(aVet,cPreSel)

	Local aArea		:= GetArea()
	Local aAreaSQB	:= SQB->(GetArea())
	
	DbSelectArea("SQB")
	SQB->(DbSetOrder(1))
	SQB->(DbGoTop())
	
	If Empty(cPreSel)
		cPreSel := padl(alltrim(cPresel),9,"0")
	EndIf
	                                            
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Carrega vetor considerando o que ja estava selecionado³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	While !SQB->(EOF())
		aAdd(aVet,{(padl(AllTrim(SQB->QB_DEPTO),9,"0")$cPreSel),SQB->QB_DEPTO,SQB->QB_DESCRIC})
		SQB->(DbSkip())
	EndDo
	          
	RestArea(aAreaSQB)
	RestArea(aArea)
	
Return Nil     
                       
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ Marca    º Autor ³                    º Data ³             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Rotina para marcar, desmarcar ou inverter a selecao dos    º±±
±±º          ³ departamentos listados no ListBox                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function Marca(nOp,aVet,oObj)

	Local lMarca
	Local i
	
	If nOp == 1 		// Marca todos
		lMarca	:=	.T.
	ElseIf nOp == 2		// Desmarca Todos
		lMarca	:=	.F.
	Endif
	
	If lMarca != NIL
		For i := 1 To Len(aVet)
			aVet[i][1] := lMarca
		Next i
	Else	// Inverte Selecao
		For i := 1 To Len(aVet)
			aVet[i][1] := !aVet[i][1]
		Next i
	EndIf
	
	oObj:Refresh()	// Atualiza Listbox
	
Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ RetSQB   º Autor ³                    º Data ³             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Grava os departamentos selecionados no campo AK_XDEPART.   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/ 

Static Function RetSQB(aVet)

	Local cRet	:= ""
	Local cSep	:= ""
	Local nX
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Cria retorno³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nX := 1 to Len(aVet)
		If aVet[nX][1] == .T.
			cRet += cSep + AllTrim(aVet[nX][2])
			cSep := ","
		EndIf
	Next nX
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Grava retorno no campo³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	M->AK_XDEPART := cRet + Space(TamSx3("AK_XDEPART")[1] - Len(cRet))
	xFSAK01  := cRet + Space(TamSx3("AK_XDEPART")[1] - Len(cRet))
Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ FSQB010b º Autor ³                    º Data ³             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Validacao dos departamentos informados pelo usuario.       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function FSQB010b()

	Local aArea		:=	GetArea()
	Local aAreaSQB	:=	SQB->(GetArea())
	Local aValores	:=	LeSQB(AllTrim(M->AK_XDEPART))
	Local nX		:=	1
	Local lRet		:=	.T.
	
	DbSelectArea("SQB")
	DbSetOrder(1) // QB_FILIAL+QB_DEPTO 
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Testa os valores digitados³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	While (nX <= Len(aValores)) .And. lRet
		lRet := DbSeek(xFilial("SQB")+aValores[nX++])
	End
	
	If !lRet
		ApMsgStop("Departamento " + aValores[--nX] + " não encontrado.","Atenção")
	EndIf
	
	RestArea(aAreaSQB)
	RestArea(aArea)
	
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ LeSQB    º Autor ³                    º Data ³             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Le os valores contidos em uma string com separadores.      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function LeSQB(cPar,cSep)

	Local aRet	:= {}
	Local nPos	:= 0
	Local cTmp	:= ""
	
	Default cSep := ","
	
	While Len(cPar) > 0
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica se existem separadores ou se somente contem um³
		//³valor                                                  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If (nPos := At(cSep,cPar)) == 0
			cTmp := SubStr(cPar,0,Len(cPar))
			cPar := ""
		Else
			cTmp := SubStr(cPar,0,nPos-1)
			cPar := SubStr(cPar,nPos+1,Len(cPar))
		EndIf
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Alimenta retorno³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If Len(cTmp) > 0
			AAdd(aRet,cTmp)
		EndIf
		
	EndDo
	
Return aRet              
           

	
/*/{Protheus.doc} FSQB010R
Função para retorno da consulta 
@author Roberto Souza
@since 09/08/2017
@version 1.0
/*/                 

// PROJETO_P12
// Roberto Souz
User Function FSQB010R() 
	
Return( xFSAK01 )