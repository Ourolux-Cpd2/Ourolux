#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±º Programa ³ F340CAN()  ³ Autor ³ Claudino P Domingues ³ Data ³ 13/02/14 º±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±º Funcao Padrao ³ FINA340                                                º±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±º Desc.    ³ Sera executado após a confirmação do cancelamento de        º±±
±±º          ³ compensação a pagar. Envia Workflow.            			   º±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

User Function F340CAN()
      
	Local _aAreaSE5 := SE5->(GetArea()) 
	Local _aRecnos 	:= aClone(ParamIxb) 
	Local _cMotCanc := ""
	Local _nX 		:= 0
	Local oHTML
		
	For _nX := 1 To Len(_aRecnos) 
        
		SE5->(dbGoTo(_aRecnos[_nX]))
            
		_cMotCanc := MotCanc()

		oProcess:= TWFProcess():New("CancelaCOMPCP","Exclusao/Estorno Compensacao CP") 
		oProcess:NewTask("Inicio","\WORKFLOW\canccompcp.html")        
		oProcess:cSubject:="Exclusao/Estorno Compensacao CP"     
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
		// Função UsrRetName esta retornando o nome completo na P12, foi substituida pela variavel cUserName - Claudino 26/07/2017
		//oHTML:ValByName('USER',"Login: "+UsrRetName(__cUserId)+" - "+Rtrim(Substr(cUsuario,7,15)))
		oHTML:ValByName('USER',"Login: "+Upper(Alltrim(cUserName))+" - "+Rtrim(Substr(cUsuario,7,15)))

		oProcess:cBCc := "sumaia@ourolux.com.br"
		oProcess:Start()
		oProcess:Finish() 
 	        	
	Next _nX
	
	RestArea(_aAreaSE5)
                
Return() 

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
	
	DEFINE MSDIALOG _oDlg TITLE "Motivo do Exclusao/Estorno" FROM 0,0 To 180,300 OF oMainWnd PIXEL
		               		                                  
		_oTMultiGet:=TMultiGet():New(003,003,{|U|If(Pcount()>0,_cTexto:=u,_cTexto)},_oDlg,145,070,,.T.,,,,.T.,,,{||.T.},,,,,,,.F.,.T.)	                
		_oTMultiGet:lWordWrap := .F.	// Variavel que faz a quebra de linha no Objeto TMultiGet.
		_oTMultiGet:EnableHScroll(.T.)	// Habilita/Desabilita a barra de rolagem horizontal.
		_oTMultiGet:EnableVScroll(.T.)	// Habilita/Desabilita a barra de rolagem vertical.
				                   
		DEFINE SBUTTON FROM 078,122 TYPE 1 ENABLE OF _oDlg ACTION (_oDlg:End()) 
		
	ACTIVATE MSDIALOG _oDlg CENTERED

Return(_cTexto)