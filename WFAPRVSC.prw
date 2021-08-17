#INCLUDE "PROTHEUS.CH"
#INCLUDE "AP5MAIL.CH"

/*±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±  WFAPRVSC ³ Autor: Claudino Pereira Domingues           ³ Data 12/05/14 ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±± Descricao ³ Envia WorkFlow de Aprovacao de Solicitacao de Compras.      ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/

User Function WFAPRVSC()
    Local _nRec      := 0
	Local _cNumSc	 := ""
	Local _cCodProc  := ""
    Local _cHtmlMod  := ""
	Local _cAssunt   := ""
	Local _cQuery    := ""
	Local _cQryWFID  := ""
	Local _cMailID	 := ""
	Local _cAprovs	 := ""
	Local _cMailAprv := ""
	Local _cHostWF   := GetMv("FS_WFURL01", .F.,"http://aprovar.ourolux.com.br:8181/wf")//URL configurado no ini para WF Link.
		
	If Select("TRB") > 0
		DbSelectArea("TRB")
		TRB->(DbCloseArea())
	EndIf

	_cQuery := " SELECT SC1.C1_NUM, SC1.C1_EMISSAO, SC1.C1_SOLICIT, SC1.C1_ITEM, SC1.C1_PRODUTO, SC1.C1_DESCRI, "
	_cQuery += " SC1.C1_UM, SC1.C1_QUANT, SC1.C1_DATPRF, SC1.C1_OBS, SC1.C1_CC, SC1.C1_USER, SC1.C1_XDEPART, SC1.C1_WFID, SC1.C1_XDTPROG "
	_cQuery += " FROM " + RetSqlName("SC1") + " SC1 "
	_cQuery += " WHERE SC1.D_E_L_E_T_ = '' AND SC1.C1_FILIAL = '" + cFilAnt + "' AND " 
	_cQuery += " SC1.C1_NUM = '" + SC1->C1_NUM + "' "
		
	DbUseArea(.T.,"TOPCONN",TCGenQry(,,_cQuery),"TRB",.F.,.T.)
	
	TcSetField("TRB","C1_EMISSAO","D")
	TcSetField("TRB","C1_DATPRF","D")
	TcSetField("TRB","C1_XDTPROG","D")
	
	COUNT TO _nRec
	
	If _nRec > 0
		
		DbSelectArea("TRB")
		TRB->(DbGoTop())
		
		DbSelectArea("SAK")
		SAK->(DbGoTop())		
		
		While !SAK->(EOF()) 
					
			If (IIF(Empty(TRB->C1_XDEPART),_cDepSC1,TRB->C1_XDEPART)) $ SAK->AK_XDEPART .And. ! (SAK->AK_USER $ '000287.000079.000056') 
				_cAprovs += Alltrim(SAK->AK_NOME) + ";"
	 	 		_cMailAprv += Alltrim(UsrRetMail(SAK->AK_USER)) + ";"
	 		EndIf
			
			SAK->(DbSkip())
		
		EndDo
		
		_cCodProc := "WFAPROV"
		_cHtmlMod := "\workflow\wfsc01.htm"
		_cAssunt  := "Aprovação da Solicitação de Compras nº " + TRB->C1_NUM +;
		             " - Emp: " + Alltrim(SM0->M0_NOME) + " - Fil: " + Alltrim(SM0->M0_FILIAL) +;
		             " - Aprovadores: " + _cAprovs
		
		oProcess := TWFProcess():New( _cCodProc , _cAssunt )
		oProcess:NewTask( _cAssunt , _cHtmlMod )
		
		CONOUT("(INICIO|SCAPRO)Processo: " + oProcess:fProcessID + " - Task: " + oProcess:fTaskID )
		
		oProcess:oHtml:ValByName("cEMP"       , Alltrim(SM0->M0_NOME))
		oProcess:oHtml:ValByName("cFIL"       , Alltrim(SM0->M0_FILIAL))
		oProcess:oHtml:ValByName("cNUM"       , TRB->C1_NUM)
		oProcess:oHtml:ValByName("cEMISSAO"   , DTOC(TRB->C1_EMISSAO))
		oProcess:oHtml:ValByName("cSOLICIT"   , TRB->C1_SOLICIT)
		oProcess:oHtml:ValByName("cMAILSOL"   , UsrRetMail(TRB->C1_USER))
		oProcess:oHtml:ValByName("cAPROVAD"   , _cAprovs)
		oProcess:oHtml:ValByName("cMAILAPR"   , Replace(_cMailAprv,";",", "))
		oProcess:oHtml:ValByName("lbmotivo"   , "")
		oProcess:oHtml:ValByName("it.ITEM"    , {})
		oProcess:oHtml:ValByName("it.PRODUTO" , {})
		oProcess:oHtml:ValByName("it.DESCRI"  , {})
		oProcess:oHtml:ValByName("it.UM"      , {})
		oProcess:oHtml:ValByName("it.QUANT"   , {})
		oProcess:oHtml:ValByName("it.DATPRF"  , {})
		oProcess:oHtml:ValByName("it.DATLIM"  , {})
		oProcess:oHtml:ValByName("it.OBS"     , {})
		oProcess:oHtml:ValByName("it.CC"      , {})
		
		DbSelectArea("TRB")
		TRB->(DbGoTop())
		
		If Empty(TRB->C1_WFID)
			_cQryWFID := " UPDATE " + RetSqlName("SC1")
			_cQryWFID += " SET C1_WFID = '" + oProcess:fProcessID + "." + oProcess:fTaskID + "' "
			_cQryWFID += " WHERE D_E_L_E_T_ = '' AND C1_FILIAL = '" + cFilAnt + "' AND " 
			_cQryWFID += " C1_NUM = '" + TRB->C1_NUM + "' "
		
			TcSqlExec(_cQryWFID)
			TcRefresh(RetSqlName("SC1"))
		Else
		    
		    CONOUT("(WFINICIO-KILL|SCAPRO)Processo:" + oProcess:fProcessID + " - Task: " + oProcess:fTaskID + " - SC: " + _cNumSc + " - Encerrado!")
        
			WFKillProcess( Alltrim(TRB->C1_WFID) )	

			_cQryWFID := " UPDATE " + RetSqlName("SC1")
			_cQryWFID += " SET C1_WFID = '" + oProcess:fProcessID + "." + oProcess:fTaskID + "' "
			_cQryWFID += " WHERE D_E_L_E_T_ = '' AND C1_FILIAL = '" + cFilAnt + "' AND " 
			_cQryWFID += " C1_NUM = '" + TRB->C1_NUM + "' "
		
			TcSqlExec(_cQryWFID)
			TcRefresh(RetSqlName("SC1"))
		
		EndIf
		
		While !TRB->(EOF())
			AADD(oProcess:oHtml:ValByName("it.ITEM")    , TRB->C1_ITEM)                             	// Item Cotacao
			AADD(oProcess:oHtml:ValByName("it.PRODUTO") , TRB->C1_PRODUTO)                          	// Cod Produto
			AADD(oProcess:oHtml:ValByName("it.DESCRI")  , TRB->C1_DESCRI)                           	// Descricao Produto
			AADD(oProcess:oHtml:ValByName("it.UM")      , TRB->C1_UM)                               	// Unidade Medida
			AADD(oProcess:oHtml:ValByName("it.QUANT")   , TRANSFORM(TRB->C1_QUANT,'@E 999,999,999.99')) // Quantidade Solicitada
			AADD(oProcess:oHtml:ValByName("it.DATPRF")  , DTOC(TRB->C1_DATPRF))                     	// Data da Necessidade
			AADD(oProcess:oHtml:ValByName("it.DATLIM")  , DTOC(TRB->C1_XDTPROG))                     	// Data Limite
			AADD(oProcess:oHtml:ValByName("it.OBS")     , TRB->C1_OBS)                              	// Observacao
			AADD(oProcess:oHtml:ValByName("it.CC")      , TRB->C1_CC)                               	// Centro de Custo
			TRB->(DbSkip())
		EndDo
		
		oProcess:cSubject := _cAssunt
		oProcess:cTo := "wfaprov"
		
	    // Informe o nome da função de retorno a ser executada quando a mensagem de
		// respostas retornarem ao Workflow:
		oProcess:bReturn := "U_WFSCRET()"
		
		// Determino o tempo necessário para executar o TimeOut. 
		oProcess:bTimeOut := {{"U_WFSCTIME(1)", /*Dia*/ 1 , /*Horas*/ 0 , /*Minutos*/ 0 },{"U_WFSCTIME(2)", 2 , 0 , 0 },{"U_WFSCTIME(3)", 3 , 0 , 0 }}
		
		// Informo o codigo do usuario no Microsiga Protheus que recebera o e-mail. 
		// Isto e util para usar a consulta de Processos por usuario.
		oProcess:UserSiga := __cUserID  
		
		// Coloco aqui um ponto de Rastreabilidade. Os dois primeiros parametros sao sempre os 
		// abaixo passados e o terceiro indica o codigo do Status.
		RastreiaWF(oProcess:fProcessID+"."+oProcess:fTaskID,"000003","10001") 
		
		_cMailID := oProcess:Start()
				
		_cHtmlMod := "\workflow\wflink.htm"
		
		oProcess:NewTask( _cAssunt , _cHtmlMod )
		
		CONOUT("(INICIO|WFLINK)Processo: " + oProcess:fProcessID + " - Task: " + oProcess:fTaskID )          
        
		// Isto e util para usar a consulta de Processos por usuario.
		oProcess:UserSiga := Nil

		oProcess:cSubject := _cAssunt
		oProcess:cTo := _cMailAprv
		//oProcess:ohtml:ValByName("proc_link",_cHostWF + "/messenger/emp" + cEmpAnt + "/HTML/" + _cMailId + ".htm")
		//oProcess:oHtml:ValByName("A_LINK", cHostWF + "/messenger/emp" + cEmpAnt + "/HTML/" + cMailId + ".htm")
		//oProcess:ohtml:ValByName("proc_link","http://aprovar.ourolux.com.br:8181/wf/" + _cMailID + ".htm") 
		oProcess:ohtml:ValByName("proc_link",_cHostWF + _cMailID + ".htm")
//		oProcess:ohtml:ValByName("proc_link1",_cHostWF + _cMailID + ".htm")
//		oProcess:ohtml:ValByName("proc_link1","http://192.168.0.5:8181/wf/" + _cMailID + ".htm") 
		oProcess:ohtml:ValByName("proc_link2","http://189.16.81.226:8181/wf/" + _cMailID + ".htm") 
		
		oProcess:Start()	    
		
		DbSelectArea("TRB")                   
		TRB->(DbCloseArea())
	Else
		DbSelectArea("TRB")
		TRB->(DbCloseArea())
		MsgStop("Problemas no Envio do E-Mail de Aprovação!","ATENÇÃO!")
	EndIf

Return

/*±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±  WFSCRET  ³ Autor: Claudino Pereira Domingues           ³ Data 12/05/14 ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±± Descricao ³ Retorno Workflow de Aprovacao de Solicitacao de Compras.    ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/

User Function WFSCRET(oProcess)
    
    Local _cQuery   := ""
	Local _cNumSc   := oProcess:oHtml:RetByName("cNUM")
	Local _cAprov   := Upper(oProcess:oHtml:RetByName("RBAPROVA"))
	//Local _cMotivo  := oProcess:oHtml:RetByName("LBMOTIVO")
	//Local _cMailSol := oProcess:oHtml:RetByName("cMAILSOL")
	Local _cMailCom := Alltrim(GetMV("FS_MAILCOM"))
	Local cNomeCom	:= ""
	Local cNomeApr	:= ""
	Private oHTML
	
	CONOUT("(RETORNO|SCAPRO)Processo:" + oProcess:fProcessID + " - Task: " + oProcess:fTaskID + " - SC: " + _cNumSc)
	
	_cQuery := " UPDATE " + RetSqlName("SC1")
	
	If _cAprov == "SIM" 
		_cQuery += " SET C1_APROV = 'L', C1_XDTLIB = '"+DTOS(ddatabase)+"' "
	ElseIf _cAprov == "NAO"
		_cQuery += " SET C1_APROV = 'R', C1_XDTLIB = '"+DTOS(ddatabase)+"' "
	EndIf
	
	_cQuery += " WHERE D_E_L_E_T_ = '' AND C1_FILIAL = '" + cFilAnt + "' AND " 
	_cQuery += " C1_NUM = '" + _cNumSc + "' "
	
	TcSqlExec(_cQuery)
	TcRefresh(RetSqlName("SC1"))
	
	_cQuery := " SELECT TOP(1) Y1_EMAIL, Y1_NOME, C1_NOMAPRO FROM " + RetSqlName("SY1") + " SY1 "
	_cQuery += " INNER JOIN " + RetSqlName("SC1") + " SC1 "
	_cQuery += " ON SC1.C1_CODCOMP = SY1.Y1_COD "
	_cQuery += " WHERE SC1.D_E_L_E_T_ = '' "
	_cQuery += " AND SY1.D_E_L_E_T_ = '' "
	_cQuery += " AND SC1.C1_FILIAL = '" + cFilAnt + "' "
	_cQuery += " AND C1_NUM = '" + _cNumSc + "' "
	

	If Select("SCRET") > 0
		SCRET->(dbCloseArea())
	EndIf

	DbUseArea(.T., "TOPCONN", TCGenQry(,,_cQuery) , 'SCRET', .T., .F.)

	If SCRET->(!EOF())
		If Empty(_cMailCom)
			_cMailCom := SCRET->Y1_EMAIL
		Else
			_cMailCom += ";" + SCRET->Y1_EMAIL
		EndIf
		cNomeCom := Alltrim(SCRET->Y1_NOME)
		cNomeApr := Alltrim(SCRET->C1_NOMAPRO)
	else
		oProcess:Finish()
		oProcess:Free()
		oProcess := Nil
		Return
	EndIf

	If _cAprov == "SIM" // Verifica se foi aprovado
	    
		// Coloco aqui um ponto de Rastreabilidade. Os dois primeiros parametros sao sempre os 
		// abaixo passados e o terceiro indica o codigo do Status.
		RastreiaWF(oProcess:fProcessID+"."+oProcess:fTaskID,"000003","10002")
              
		oProcess:Finish()
		oProcess:Free()
		oProcess := Nil

		WFMAIL("APROVADO", Alltrim(SM0->M0_FILIAL), _cNumSc, cNomeApr , _cMailCom, cNomeCom)   

	ElseIf _cAprov == "NAO" // Verifica se foi rejeitado
	    
		RastreiaWF(oProcess:fProcessID+"."+oProcess:fTaskID,"000003","10003")
	    
		oProcess:Finish()
		oProcess:Free()
		oProcess := Nil

		WFMAIL("REJEITADO", Alltrim(SM0->M0_FILIAL), _cNumSc, cNomeApr , _cMailCom, cNomeCom)   
	EndIf
	
Return

/*±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±  WFSCTIME ³ Autor: Claudino Pereira Domingues           ³ Data 20/05/14 ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±± Descricao ³ Aviso de TIMEOUT para Aprovador.                            ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/

User Function WFSCTIME(_nVezes,oProcess)
    	
	Local _cNumSc   := oProcess:oHtml:RetByName("cNUM")
	Local _cMailID  := SubString(oProcess:oHtml:RetByName("WFMAILID"),3,Len(oProcess:oHtml:RetByName("WFMAILID")))
	Local _cAprMail := oProcess:oHtml:RetByName("cMAILAPR")
	Local _cAssunt  := ""
	Local _cHtmlMod := ""
	Local _cQuery   := ""
	Local _cHostWF  := GetMv("FS_WFURL01", .F.,"http://aprovar.ourolux.com.br:8181/wf")	//URL configurado no ini para WF Link.
			
	If Select("APROV") > 0
		DbSelectArea("APROV")
		APROV->(DbCloseArea())
	EndIf
	
	_cQuery := " SELECT SC1.C1_NUM, SC1.C1_EMISSAO, SC1.C1_SOLICIT, SC1.C1_ITEM, SC1.C1_PRODUTO, SC1.C1_APROV, SC1.C1_WFID "
	_cQuery += " FROM " + RetSqlName("SC1") + " SC1 "
	_cQuery += " WHERE SC1.D_E_L_E_T_ = '' AND SC1.C1_FILIAL = '" + cFilAnt + "' AND " 
	_cQuery += " SC1.C1_NUM = '" + _cNumSc + "' "
	
	DbUseArea(.T.,"TOPCONN",TCGenQry(,,_cQuery),"APROV",.F.,.T.)
	
	DbSelectArea("APROV")
	APROV->(DbGoTop())
	
	// Caso seja aprovacao por item, devera ser feito tratamento.
	If APROV->C1_APROV == "B"  
	
		_cAssunt  := "Reenvio Aprovação da Solicitação de Compras nº " + _cNumSc
		_cHtmlMod := "\workflow\wflink.htm"
		
		oProcess:NewTask( _cAssunt , _cHtmlMod )
		//oProcess:ohtml:ValByName("proc_link","http://aprovar.ourolux.com.br:8181/wf/" + _cMailID + ".htm")
		//oProcess:ohtml:ValByName("proc_link", _cHostWF + _cMailID + ".htm")
		//rocess:ohtml:ValByName("proc_link",_cHostWF + "/messenger/emp" + cEmpAnt + "/HTML/" + _cMailId + ".htm")
		oProcess:ohtml:ValByName("proc_link",_cHostWF + "/messenger/emp" + cEmpAnt + "/HTML/" + _cMailId + ".htm")
//		oProcess:ohtml:ValByName("proc_link1",_cHostWF + "/messenger/emp" + cEmpAnt + "/HTML/" + _cMailId + ".htm")
//		oProcess:ohtml:ValByName("proc_link1","http://192.168.0.5:8181/wf/" + _cMailID + ".htm") 
		oProcess:ohtml:ValByName("proc_link2","http://189.16.81.226:8181/wf/" + _cMailID + ".htm")
		oProcess:cTo := _cAprMail
		oProcess:bReturn := "U_WFSCRET()"
		
		If (_nVezes == 1)
			
			// Coloco aqui um ponto de Rastreabilidade. Os dois primeiros parametros sao sempre os 
			// abaixo passados e o terceiro indica o codigo do Status.
			RastreiaWF(oProcess:fProcessID+"."+oProcess:fTaskID,"000003","10004")
			
			CONOUT("(TIMEOUT1|SCAPRO)Processo:" + oProcess:fProcessID + " - Task: " + oProcess:fTaskID + " - SC: " + _cNumSc)
			oProcess:cSubject := "(Timeout) 1 " + oProcess:cSubject	
		
		ElseIf (_nVezes == 2)
		
			RastreiaWF(oProcess:fProcessID+"."+oProcess:fTaskID,"000003","10005")
			
			CONOUT("(TIMEOUT2|SCAPRO)Processo:" + oProcess:fProcessID + " - Task: " + oProcess:fTaskID + " - SC: " + _cNumSc)
			oProcess:cSubject := "(Timeout) 2 " + oProcess:cSubject	
		
		ElseIf (_nVezes == 3)
			
			RastreiaWF(oProcess:fProcessID+"."+oProcess:fTaskID,"000003","10006")
			
			CONOUT("(TIMEOUT3|SCAPRO)Processo:" + oProcess:fProcessID + " - Task: " + oProcess:fTaskID + " - SC: " + _cNumSc)
			oProcess:cSubject := "(Timeout) 3 " + oProcess:cSubject	
		
		EndIf
		
		oProcess:Start()
	
	Else
        
        CONOUT("(TIMEOUT-KILL|SCAPRO)Processo:" + oProcess:fProcessID + " - Task: " + oProcess:fTaskID + " - SC: " + _cNumSc + " - Encerrado!")
        
		WFKillProcess( Alltrim(APROV->C1_WFID) )	
	
	EndIf
			
Return
    
///////////////////////////////////////////////////////////////////////////////
Static Function WFMAIL(_aprovado, _filial, _pedido, _aprovador,_email,_nomeCom)   

	cData := dtoc(ddatabase)
	cHora := TIME()

	lSmtpSSL  := GetMV("MV_RELSSL")
	lSmtpTLS  := GetMV("MV_RELTLS")
	lAuteSMTP := GetNewPar("MV_RELAUTH",.F.)
	cServSMTP := GetMV("MV_RELSERV")
	cUserSMTP := GetMV("MV_RELACNT")
	cPassSMTP := GetMV("MV_RELPSW")
	cUserFrom := GetMV("MV_RELFROM")                     
                                                                                                                                
    cAssunto := "Status da Solicitação de Compra: "+_pedido
     
	lResult := .f. 
	
	if lSmtpSSL .AND. lSmtpTLS
  		CONNECT SMTP SERVER cServSMTP ACCOUNT cUserSMTP PASSWORD cPassSMTP RESULT lResult SSL TLS
  	endif
  		
	if lSmtpSSL .AND. !lSmtpTLS
  		CONNECT SMTP SERVER cServSMTP ACCOUNT cUserSMTP PASSWORD cPassSMTP RESULT lResult SSL 
  	endif                                                                                     

	if !lSmtpSSL .AND. lSmtpTLS
  		CONNECT SMTP SERVER cServSMTP ACCOUNT cUserSMTP PASSWORD cPassSMTP RESULT lResult TLS
  	endif                                                                                     
                                     
	If lResult .And. lAuteSMTP
	    lResult := MailAuth( cUserSMTP, cPassSMTP )
	    If !lResult
	        lResult := QADGetMail() // funcao que abre uma janela perguntando o usuario e senha para fazer autenticacao
	    EndIf
	EndIf
	
	If !lResult
	    GET MAIL ERROR cError
	   	    conout('Erro de Autenticacao no Envio de e-mail antes do envio: '+cError)
	    Return
	EndIf                                  



	conout("Usuario Aprovador: " + _aprovador)
	    
    cMensagem := ' <p align="center"><font face="arial" color="#0000FF" size="4"><b>Mensagem Eletronica - WorkFlow</b></font></p> '
	cMensagem += ' <p align="left">Prezado, <strong>'+ _nomeCom +'</strong></p> '

	if alltrim(_aprovado) == 'APROVADO' 
		cMensagem += ' <p align="left">Solicitação: '+ _pedido +' Liberada!</p> '
	elseif alltrim(_aprovado) == 'REJEITADO' 
		cMensagem += ' <p align="left">Solicitação: '+ _pedido +' Rejeitada!</p> '
    else
        cMensagem += ' <p align="left">Solicitação: '+ _pedido +' Bloqueada!</p> '
	endif
	cMensagem += ' <p align="left">Data do Envio: <strong>' + cData + '.</strong></p> '
	cMensagem += ' <p align="left">Hora: <strong>' + cHora + '.</strong></p> ' 
    cMensagem += ' </body> '
	
	SEND MAIL FROM cUserFrom TO _email CC "" SUBJECT cAssunto BODY cMensagem RESULT lResult  // ATTACHMENT cAnexo1 

	If !lResult
	    GET MAIL ERROR cError
   	    conout('Erro de Envio de e-mail: '+cError)
	else

		conout('eMail enviado!')
	
	EndIf

	DISCONNECT SMTP SERVER

Return .T.
