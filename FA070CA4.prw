#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"

/*苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
北? Programa ? FA070CA4() ? Autor ? Claudino P Domingues ? Data ? 02/10/13 罕?
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
北? Funcao Padrao ? FINA070                                                罕?
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
北? Desc.    ? Sera executado apos confirmacao do cancelamento/exclusao da 罕?
北?          ? baixa do contas a receber. Envia Workflow. 				   罕?
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
北? Desc.    ? Alterado por MrConsulting - Gilson Belini em 28/11/2014.    罕?
北?          ? Posiciona o campo E5_DTDIGIT, antes posicionava-se o        罕?
北?          ? E1_BAIXA para efetuar o bloqueio do cancelamento.           罕?
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌*/

User Function FA070CA4()

Local _aAreaSE5 := SE5->(GetArea())
Local _aAreaSE1 := SE1->(GetArea())
Local _lRet     := .T.
Local _cMotCanc := ""
Local _nDayDif	:= 0
Local _nDayNot	:= 0
Local oHTML

// Claudino 27/04/16 - Parametro que armazena o login dos diretores
// Fun玢o UsrRetName esta retornando o nome completo na P12, foi substituida pela variavel cUserName - Claudino 26/07/2017
//If !(Upper(UsrRetName(__cUserId)) $ GetMv("FS_DIRETOR"))
If !(Upper(Alltrim(cUserName)) $ GetMv("FS_DIRETOR"))
	// Claudino 27/04/16 - Valida se o usuario logado esta nos parametros
	// Fun玢o UsrRetName esta retornando o nome completo na P12, foi substituida pela variavel cUserName - Claudino 26/07/2017
	//If Upper(UsrRetName(__cUserId)) $ GetMv("FS_EXCFIN1") .OR. Upper(UsrRetName(__cUserId)) $ GetMv("FS_EXCFIN2")
	If Upper(Alltrim(cUserName)) $ GetMv("FS_EXCFIN1") .OR. Upper(Alltrim(cUserName)) $ GetMv("FS_EXCFIN2")
		// Claudino 27/04/16 - Numero de dias de diferen鏰 entre emiss鉶 e database
		_nDayDif := DateDiffDay(SE5->E5_DTDIGIT,dDataBase) 
		// Claudino 27/04/16 - ? o mesmo dia
		If _nDayDif > 0
			// Claudino 27/04/16 - Valida entre a emiss鉶 e a database, quantos dias n鉶 s鉶 uteis
			For n := 1 to _nDayDif
				If DataValida(SE5->E5_DTDIGIT + n) <> SE5->E5_DTDIGIT + n
					_nDayNot++
				EndIf 
			Next n
						
			// Claudino 27/04/16 - Valida se a quantidade de dias uteis ? maior 2
			If (_nDayDif - _nDayNot) > 2
				ApMsgStop("Usu醨io sem acesso, s? pode ser cancelado dentro de dois dias uteis. Favor verificar com o seu gestor.","FA070CA4")
				_lRet := .F.
			Else
				// Claudino 27/04/16 - Se for exatamente igual a 2 e valida se o usuario 
				// esta no parametro que pode digitar dois dias uteis
				If (_nDayDif - _nDayNot) == 2
					// Fun玢o UsrRetName esta retornando o nome completo na P12, foi substituida pela variavel cUserName - Claudino 26/07/2017
					//If !(Upper(UsrRetName(__cUserId)) $ GetMv("FS_EXCFIN2"))
					If !(Upper(Alltrim(cUserName)) $ GetMv("FS_EXCFIN2"))
						ApMsgStop("Usu醨io sem acesso, s? pode ser cancelado dentro de um dia 鷗il. Favor verificar com o seu gestor","FA070CA4")
						_lRet := .F.
					EndIf
				EndIf
			EndIf
		EndIf	
	Else
		ApMsgStop("Usuario sem permiss鉶 para executar essa opera玢o! Favor verificar com o seu gestor.","FA070CA4")
		_lRet := .F.
	EndIf
EndIf	

If _lRet
	_cMotCanc := MotCanc()
	
	If Empty(_cMotCanc)
		ApMsgStop("Por favor informar o motivo do cancelamento, sem o motivo n鉶 ? possivel cancelar a baixa.","FA070CA4")
		_lRet := .F.
	EndIf
	
	If _lRet
		oProcess:= TWFProcess():New("CancelaBXCR","Cancelamento/Exclusao Baixa CR")
		oProcess:NewTask("Inicio","\WORKFLOW\cancbxcr.html")
		oProcess:cSubject:="Cancelamento/Exclusao Baixa CR"
		oHtml := oProcess:oHTML
		
		oHTML:ValByName('PREFIXO',SE5->E5_PREFIXO)
		oHTML:ValByName('NUMERO',SE5->E5_NUMERO)
		oHTML:ValByName('PARCELA',SE5->E5_PARCELA)
		oHTML:ValByName('TIPO',SE5->E5_TIPO)
		oHTML:ValByName('CLIENTE',SE5->E5_CLIFOR +'/'+ SE5->E5_LOJA + ' ' + SE5->E5_BENEF)
		oHTML:ValByName('EMISSAO',SE1->E1_EMISSAO)
		oHTML:ValByName('VENCTO',SE1->E1_VENCTO)
		oHTML:ValByName('BAIXA',SE5->E5_DATA)
		oHTML:ValByName('VALOR',"R$ " + Transform(SE5->E5_VALOR,"@E 99,999,999.99"))
		oHTML:ValByName('MOTCANC',Alltrim(_cMotCanc))
		// Fun玢o UsrRetName esta retornando o nome completo na P12, foi substituida pela variavel cUserName - Claudino 26/07/2017
		//oHTML:ValByName('USER',"Login: "+UsrRetName(__cUserId)+" - "+Rtrim(Substr(cUsuario,7,15)))
		oHTML:ValByName('USER',"Login: "+Upper(Alltrim(cUserName))+" - "+Rtrim(Substr(cUsuario,7,15)))
		
		oProcess:cBCc := "sumaia@ourolux.com.br"
		oProcess:Start()
		oProcess:Finish()
	EndIf
	
EndIf

RestArea(_aAreaSE1)
RestArea(_aAreaSE5)

Return(_lRet)

/*苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
北? Programa ? MotCanc() ? Autor ? Claudino P Domingues ? Data ? 03/10/13  罕?
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
北? Desc.    ? Funcao que monta o get para que seja preenchido o motivo do 罕?
北?          ? cancelamento.     			   							   罕?
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌*/

Static Function MotCanc()

Local _oDlg
Local _oTMultiGet
Local _cTexto := SPACE(200)

DEFINE MSDIALOG _oDlg TITLE "Motivo do Cancelamento/Exclusao" FROM 0,0 To 180,300 OF oMainWnd PIXEL

_oTMultiGet:=TMultiGet():New(003,003,{|U|If(Pcount()>0,_cTexto:=u,_cTexto)},_oDlg,145,070,,.T.,,,,.T.,,,{||.T.},,,,,,,.F.,.T.)
_oTMultiGet:lWordWrap := .F.	// Variavel que faz a quebra de linha no Objeto TMultiGet.
_oTMultiGet:EnableHScroll(.T.)	// Habilita/Desabilita a barra de rolagem horizontal.
_oTMultiGet:EnableVScroll(.T.)	// Habilita/Desabilita a barra de rolagem vertical.

DEFINE SBUTTON FROM 078,122 TYPE 1 ENABLE OF _oDlg ACTION (_oDlg:End())

ACTIVATE MSDIALOG _oDlg CENTERED

Return(_cTexto)
