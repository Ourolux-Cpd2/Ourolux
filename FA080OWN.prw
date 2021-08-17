#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±º Programa ³ FA080OWN() ³ Autor ³ Claudino P Domingues ³ Data ³ 12/02/14 º±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±º Funcao Padrao ³ FINA080                                                º±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±º Desc.    ³ Sera executado apos confirmacao do cancelamento/exclusao da º±±
±±º          ³ baixa do contas a pagar. Envia Workflow.		 			   º±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±º Desc.    ³ Alterado por MrConsulting - Gilson Belini em 28/11/2014.    º±±
±±º          ³ Posiciona o campo E5_DTDIGIT, antes posicionava-se o        º±±
±±º          ³ E2_BAIXA para efetuar o bloqueio do cancelamento.           º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

User Function FA080OWN()

Local _aAreaSE5 := SE5->(GetArea())
Local _aAreaSE2 := SE2->(GetArea())
Local _lRet     := .T.
Local _cMotCanc := ""
Local _nDayDif	:= 0
Local _nDayNot	:= 0
Local oHTML

// Claudino 27/04/16 - Parametro que armazena o login dos diretores
// Função UsrRetName esta retornando o nome completo na P12, foi substituida pela variavel cUserName - Claudino 26/07/2017
//If !(Upper(UsrRetName(__cUserId)) $ GetMv("FS_DIRETOR"))
If !(Upper(Alltrim(cUserName)) $ GetMv("FS_DIRETOR"))
	// Claudino 27/04/16 - Valida se o usuario logado esta nos parametros
	// Função UsrRetName esta retornando o nome completo na P12, foi substituida pela variavel cUserName - Claudino 26/07/2017
	//If Upper(UsrRetName(__cUserId)) $ GetMv("FS_EXCFIN1") .OR. Upper(UsrRetName(__cUserId)) $ GetMv("FS_EXCFIN2")
	If Upper(Alltrim(cUserName)) $ GetMv("FS_EXCFIN1") .OR. Upper(Alltrim(cUserName)) $ GetMv("FS_EXCFIN2")
		// Claudino 27/04/16 - Numero de dias de diferença entre emissão e database
		_nDayDif := DateDiffDay(SE5->E5_DTDIGIT,dDataBase) 
		// Claudino 27/04/16 - É o mesmo dia
		If _nDayDif > 0
			// Claudino 27/04/16 - Valida entre a emissão e a database, quantos dias não são uteis
			For n := 1 to _nDayDif
				If DataValida(SE5->E5_DTDIGIT + n) <> SE5->E5_DTDIGIT + n
					_nDayNot++
				EndIf 
			Next n
						
			// Claudino 27/04/16 - Valida se a quantidade de dias uteis é maior 2
			If (_nDayDif - _nDayNot) > 2
				ApMsgStop("Usuário sem acesso, só pode ser cancelado dentro de dois dias uteis. Favor verificar com o seu gestor.","FA080OWN")
				_lRet := .F.
			Else
				// Claudino 27/04/16 - Se for exatamente igual a 2 e valida se o usuario 
				// esta no parametro que pode digitar dois dias uteis
				If (_nDayDif - _nDayNot) == 2
					// Função UsrRetName esta retornando o nome completo na P12, foi substituida pela variavel cUserName - Claudino 26/07/2017
					//If !(Upper(UsrRetName(__cUserId)) $ GetMv("FS_EXCFIN2"))
					If !(Upper(Alltrim(cUserName)) $ GetMv("FS_EXCFIN2"))
						ApMsgStop("Usuário sem acesso, só pode ser cancelado dentro de um dia útil. Favor verificar com o seu gestor.","FA080OWN")
						_lRet := .F.
					EndIf
				EndIf
			EndIf
		EndIf	
	Else
		ApMsgStop("Usuario sem permissão para executar essa operação! Favor verificar com o seu gestor.","FA080OWN")
		_lRet := .F.
	EndIf
EndIf	

If _lRet
	_cMotCanc := MotCanc()
	
	If Empty(_cMotCanc)
		ApMsgStop("Por favor informar o motivo do cancelamento, sem o motivo não é possivel cancelar a baixa.","FA080OWN")
		_lRet := .F.
	EndIf
	
	If _lRet
		oProcess:= TWFProcess():New("CancelaBXCP","Cancelamento/Exclusao Baixa CP")
		oProcess:NewTask("Inicio","\WORKFLOW\cancbxcp.html")
		oProcess:cSubject:="Cancelamento/Exclusao Baixa CP"
		oHtml := oProcess:oHTML
		
		oHTML:ValByName('PREFIXO',SE5->E5_PREFIXO)
		oHTML:ValByName('NUMERO',SE5->E5_NUMERO)
		oHTML:ValByName('PARCELA',SE5->E5_PARCELA)
		oHTML:ValByName('TIPO',SE5->E5_TIPO)
		oHTML:ValByName('FORNEC',SE5->E5_CLIFOR +'/'+ SE5->E5_LOJA + ' ' + SE5->E5_BENEF)
		oHTML:ValByName('EMISSAO',SE2->E2_EMISSAO)
		oHTML:ValByName('VENCTO',SE2->E2_VENCTO)
		oHTML:ValByName('BAIXA',SE5->E5_DATA)
		oHTML:ValByName('VALOR',"R$ " + Transform(SE5->E5_VALOR,"@E 99,999,999.99"))
		oHTML:ValByName('MOTCANC',Alltrim(_cMotCanc))
		// Função UsrRetName esta retornando o nome completo na P12, foi substituida pela variavel cUserName - Claudino 26/07/2017
		//oHTML:ValByName('USER',"Login: "+UsrRetName(__cUserId)+" - "+Rtrim(Substr(cUsuario,7,15)))
		oHTML:ValByName('USER',"Login: "+Upper(Alltrim(cUserName))+" - "+Rtrim(Substr(cUsuario,7,15)))
		
		oProcess:cBCc := "sumaia@ourolux.com.br"
		oProcess:Start()
		oProcess:Finish()
	EndIf
	
EndIf

RestArea(_aAreaSE2)
RestArea(_aAreaSE5)

Return(_lRet)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±º Programa ³ MotCanc() ³ Autor ³ Claudino P Domingues ³ Data ³ 03/10/13  º±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±º Desc.    ³ Funcao que monta o get para que seja preenchido o motivo do º±±
±±º          ³ cancelamento.     			   							   º±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

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
