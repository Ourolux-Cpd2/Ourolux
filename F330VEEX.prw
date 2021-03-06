#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"

/*苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
北? Programa ? F330VEEX() ? Autor ? Claudino P Domingues ? Data ? 30/01/13 罕?
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
北? Funcao Padrao ? FINA330                                                罕?
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
北? Desc.    ? Sera executado apos confirmacao do estorno/exclusao da      罕?
北?          ? compensa玢o do contas a receber. Envia Workflow.			   罕?
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌*/

User Function F330VEEX()

	Local _aAreaSE5 := SE5->(GetArea()) 
	Local _nOpcao   := ParamIxb[1]
	Local _cMotCanc := ""
	Local oHTML
	
	_cMotCanc := MotCanc()
        			
	oProcess:= TWFProcess():New("CancelaCOMPCR","Exclusao/Estorno Compensacao CR") 
	oProcess:NewTask("Inicio","\WORKFLOW\canccompcr.html")        
	oProcess:cSubject:="Exclusao/Estorno Compensacao CR"     
	oHtml := oProcess:oHTML

	oHTML:ValByName('PREFIXO1',SE5->E5_PREFIXO)
	oHTML:ValByName('NUMERO1',SE5->E5_NUMERO)
	oHTML:ValByName('PARCELA1',SE5->E5_PARCELA)
	oHTML:ValByName('TIPO1',SE5->E5_TIPO)
	oHTML:ValByName('PREFIXO2',Substring(SE5->E5_DOCUMEN,1,3))
	oHTML:ValByName('NUMERO2',Substring(SE5->E5_DOCUMEN,4,9))
	oHTML:ValByName('PARCELA2',Substring(SE5->E5_DOCUMEN,13,1))
	oHTML:ValByName('TIPO2',Substring(SE5->E5_DOCUMEN,14,3))
	oHTML:ValByName('FORNEC',SE5->E5_CLIFOR +'/'+ SE5->E5_LOJA + ' ' + SE5->E5_BENEF)
	oHTML:ValByName('DTCOMP',SE5->E5_DATA)
	oHTML:ValByName('VALOR',"R$ " + Transform(SE5->E5_VALOR,"@E 99,999,999.99"))
	oHTML:ValByName('MOTCANC',Alltrim(_cMotCanc))	
	oHTML:ValByName('USER',"Login: "+Upper(Alltrim(cUserName))+" - "+Rtrim(Substr(cUsuario,7,15)))

	oProcess:cBCc := "sumaia@ourolux.com.br"
	oProcess:Start()
	oProcess:Finish() 
	
	RestArea(_aAreaSE5)
	               
Return()

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
	
	DEFINE MSDIALOG _oDlg TITLE "Motivo do Exclusao/Estorno" FROM 0,0 To 180,300 OF oMainWnd PIXEL
		               		                                  
		_oTMultiGet:=TMultiGet():New(003,003,{|U|If(Pcount()>0,_cTexto:=u,_cTexto)},_oDlg,145,070,,.T.,,,,.T.,,,{||.T.},,,,,,,.F.,.T.)	                
		_oTMultiGet:lWordWrap := .F.	// Variavel que faz a quebra de linha no Objeto TMultiGet.
		_oTMultiGet:EnableHScroll(.T.)	// Habilita/Desabilita a barra de rolagem horizontal.
		_oTMultiGet:EnableVScroll(.T.)	// Habilita/Desabilita a barra de rolagem vertical.
				                   
		DEFINE SBUTTON FROM 078,122 TYPE 1 ENABLE OF _oDlg ACTION (_oDlg:End()) 
		
	ACTIVATE MSDIALOG _oDlg CENTERED

Return(_cTexto)