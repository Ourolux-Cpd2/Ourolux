#INCLUDE "PROTHEUS.CH"

/*
Rotina: F3OURO01
Descricao: Tela para selecao dos Estados
Autor: Rodrigo Nunes
Data: 11/10/2021
*/
User Function F3OURO01()

	Local oOk		:= Nil		// Imagem "Marcado"
	Local oNo		:= Nil		// Imagem "Desmarcado"
	Local aDepart	:= {}		// Array com os departamentos selecionados
	Local _oButMarc	:=	Nil		// Objeto Botao Marca
	Local _oButDmrc	:=	Nil		// Objeto Botao Desmarca
	Local _oButInve	:=	Nil		// Objeto Botao Inverte selecao
	
	Private _oDlg	:=	Nil		// Objeto Dialog
	Private _oLbx	:=	Nil		// Objeto ListBox
	Private _oBmp	:=	NIL		// Objeto Bitmap

	Public xF3OU01  := ""       // Publica criada para retorno da pesquisa via SXB
	
	If AllTrim(ReadVar()) != "MV_PAR12"
		Return .T.
	EndIf
	
	oOk		:=	LoadBitmap( GetResources(), "LBOK" )
	oNo		:=	LoadBitmap( GetResources(), "LBNO" )
	
	// Carrega vetores
	LoadVet(@aDepart)
	
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
	DEFINE MSDIALOG _oDlg FROM 0,0 TO 330,500 PIXEL TITLE "Estados" of oMainWnd STYLE DS_MODALFRAME STATUS
	
		// Botoes graficos
		DEFINE SBUTTON FROM 10,215 TYPE 1 OF _oDlg ENABLE ONSTOP "Confirma" ACTION (RetSQB(@aDepart),_oDlg:End())
		DEFINE SBUTTON FROM 30,215 TYPE 2 OF _oDlg ENABLE ONSTOP "Sair" ACTION (_oDlg:End())
	
		// Botoes texto
		@ 123,005 Button _oButMarc Prompt "&Marcar Todos" 		Size 50,10 Pixel Action Marca(1,@aDepart,@_oLbx) Message "Selecionar todos os Departamentos" Of _oDlg
		@ 123,060 Button _oButDmrc Prompt "&Desmarcar Todos"	Size 50,10 Pixel Action Marca(2,@aDepart,@_oLbx) Message "Desmarcar todos os Departamentos" Of _oDlg
		@ 123,115 Button _oButInve Prompt "Inverter seleção"	Size 50,10 Pixel Action Marca(3,@aDepart,@_oLbx) Message "Inverte a seleção atual" Of _oDlg
		@ 138,005 Button _oButInve Prompt "Tudo menos SP" 		Size 50,10 Pixel Action Marca(4,@aDepart,@_oLbx) Message "Marcar todos os Estados menos São Paulo" Of _oDlg
		@ 138,060 Button _oButInve Prompt "Marcar somente SP"	Size 50,10 Pixel Action Marca(5,@aDepart,@_oLbx) Message "Marcar somente São Paulo" Of _oDlg
	
		// Labels
		@ 004,003 TO 150,210 LABEL "Estados Disponíveis:" OF _oDlg PIXEL
	
		// ListBox
		@ 10,06 LISTBOX _oLbx FIELDS HEADER " ","UF","Nome" SIZE 200,110 OF _oDlg;
		PIXEL ON dblClick(aDepart[_oLbx:nAt,1] := !aDepart[_oLbx:nAt,1],_oLbx:Refresh())
	
		// Metodos da ListBox
		_oLbx:SetArray(aDepart)
		_oLbx:bLine 	:= {|| {Iif(aDepart[_oLbx:nAt,1],oOk,oNo),;
		aDepart[_oLbx:nAt,2],;
		aDepart[_oLbx:nAt,3]}}
	
	ACTIVATE MSDIALOG _oDlg	CENTERED

Return .T.

/*
Rotina: LoadVet
Descricao: Rotina responsavel pela carga dos arrays utilizados na getdados e na listbox
Autor: Rodrigo Nunes
Data: 11/10/2021
*/
Static Function LoadVet(aVet)

	Local aArea		:= GetArea()
	
    SX5->(DbSetOrder(1))
    SX5->(MsSeek(xFilial("SX5")+"12"))
    While SX5->(!Eof()) .And. SX5->X5_TABELA == "12"
        aAdd(aVet,{Iif(Alltrim(SX5->X5_CHAVE) $ MV_PAR12,.T.,.F.),Alltrim(SX5->X5_CHAVE),Alltrim(SX5->X5_DESCRI)})
        SX5->(DbSkip())
    End	
      
	RestArea(aArea)
	
Return Nil     
                       
/*
Rotina: Marca
Descricao: Rotina para marcar, desmarcar ou inverter a selecao dos Estados
Autor: Rodrigo Nunes
Data: 11/10/2021
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

	If nOp == 4	
		For i := 1 To Len(aVet)
			If Alltrim(aVet[i][2]) == "SP"
				aVet[i][1] := .F.
			Else
				aVet[i][1] := .T.
			EndIf
		Next i
	EndIf
	
	If nOp == 5
		For i := 1 To Len(aVet)
			If Alltrim(aVet[i][2]) == "SP"
				aVet[i][1] := .T.
			Else
				aVet[i][1] := .F.
			EndIf
		Next i
	EndIf
	
	oObj:Refresh()	// Atualiza Listbox
	
Return Nil

/*
Rotina: RetSQB
Descricao:  Grava os Estados selecionados
Autor: Rodrigo Nunes
Data: 11/10/2021
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
	MV_PAR12  := cRet 
Return .T.

/*
Rotina: F3OURO01R
Descricao: Função para retorno da consulta 
Autor: Rodrigo Nunes
Data: 11/10/2021
*/
User Function F3OU01R() 
	conout('retorno F3OU01R')
Return( xF3OU01 )
