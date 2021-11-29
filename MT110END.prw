#Include 'Protheus.ch'
#Include 'Topconn.ch'
#include 'ap5mail.ch'

User Function MT110END()
	Local nNumSC 	:= PARAMIXB[1]       // Numero da Solicitação de compras
	Local nOpca  	:= PARAMIXB[2]       // 1 = Aprovar; 2 = Rejeitar; 3 = Bloquear // Validações do Usuario
	Local cUsuario 	:= Alltrim(Upper(cUserName))
    Local cQuery 	:= ""
    Local cMailCom  := ""
    Local cNomeCom  := ""
	
	cQuery := " SELECT TOP(1) Y1_EMAIL, Y1_NOME FROM " + RetSqlName("SY1") + " SY1 "
	cQuery += " INNER JOIN " + RetSqlName("SC1") + " SC1 "
	cQuery += " ON SC1.C1_CODCOMP = SY1.Y1_COD "
	cQuery += " WHERE SC1.D_E_L_E_T_ = '' "
	cQuery += " AND SY1.D_E_L_E_T_ = '' "
	cQuery += " AND SC1.C1_FILIAL = '" + cFilAnt + "' "
	cQuery += " AND C1_NUM = '" + nNumSC + "' "
	
	If Select("SCRET") > 0
		SCRET->(dbCloseArea())
	EndIf

	DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery) , 'SCRET', .T., .F.)

	If SCRET->(!EOF())
		cMailCom := Alltrim(SCRET->Y1_EMAIL)
        cNomeCom := Alltrim(SCRET->Y1_NOME)
	EndIf

	cQuery := " UPDATE " + RetSqlName("SC1")
	
	If nOpca == 1 .OR. nOpca == 2 .OR. nOpca == 3
		cQuery += " SET C1_XDTLIB = '"+DTOS(ddatabase)+"' "
	EndIf
	
	cQuery += " WHERE D_E_L_E_T_ = '' AND C1_FILIAL = '" + cFilAnt + "' AND " 
	cQuery += " C1_NUM = '" + nNumSC + "' "
	
	TcSqlExec(cQuery)	

	If nOpca == 1

		cQuery := " SELECT TOP(1) C1_ITEM FROM " + RetSqlName("SC1")
		cQuery += " WHERE C1_FILIAL = '"+cFilAnt+"' "
		cQuery += " AND C1_NUM = '"+nNumSC+"' "
		cQuery += " AND D_E_L_E_T_ = '' "
		cQuery += " ORDER BY C1_ITEM DESC "

		If Select("VERUL") > 0
			VERUL->(dbCloseArea())
		EndIf

		DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery) , 'VERUL', .T., .F.)

		If VERUL->C1_ITEM == SC1->C1_ITEM
        	WFMAIL("APROVADO",Alltrim(SM0->M0_FILIAL),nNumSC,cUsuario,cMailCom,cNomeCom)
		EndIf
	//ElseIf nOpca == 2
    //    WFMAIL("REJEITADO",Alltrim(SM0->M0_FILIAL),nNumSC,cUsuario,cMailCom,cNomeCom)
    //ElseIf nOpca == 3
    //    WFMAIL("BLOQUEADO",Alltrim(SM0->M0_FILIAL),nNumSC,cUsuario,cMailCom,cNomeCom)
    EndIf

Return

//////////////////////////////////////////////////////////////////////
Static Function WFMAIL(_aprovado, _filial, _pedido, _aprovador,_email,_nomeCom)   
	Local cTpLinha := ""
	Local dDtLimte := CTOD("  /  /  ")
	Local cQuery   := ""
	Local lUrgente := .F.
	Local cPMailSC := SuperGetMv("ES_MAILSC",.F.,"")
	Local aMailSC  := StrTokArr(cPMailSC,"/")
	Local cMailSC  := ""
	Local nlx 	   := 0 

	For nlx := 1 to len(aMailSC)
		cMailSC += (aMailSC[nlx] + '@ourolux.com.br') + ";"
	Next

	cMailSC := SubStr(cMailSC,1,Len(Alltrim(cMailSC))-1)

	conout("WFAPRVSC - INICIO ")
	conout("WFAPRVSC - INICIO " + DTOC(dDataBase))
	conout("WFAPRVSC - E-MAILS " +cMailSC+" "+ DTOC(dDataBase))
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
	        
	if alltrim(_aprovado) == 'APROVADO'
		cQuery := " SELECT BM_DESC FROM " + RetSqlName("SBM")
		cQuery += " WHERE BM_GRUPO IN (SELECT B1_GRUPO FROM " + RetSqlName("SB1")
		cQuery += " 				   WHERE B1_COD IN (SELECT C1_PRODUTO FROM " + RetSqlName("SC1")
		cQuery += " 								    WHERE C1_FILIAL = '"+cFilAnt+"' "
		cQuery += " 								    AND C1_NUM = '"+_pedido+"' "
		cQuery += " 								    AND D_E_L_E_T_ = '') "
		cQuery += " 					AND D_E_L_E_T_ = '') "
		cQuery += " AND D_E_L_E_T_ = '' " 

		conout("WFAPRVSC - QUERY " +cQuery+" "+ DTOC(dDataBase))
	
		If Select("XLIN") > 0
			XLIN->(dbCloseArea())
		EndIf

		DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery) , 'XLIN', .T., .F.)

		While XLIN->(!EOF())
			cTpLinha += Alltrim(BM_DESC) + ", "
			XLIN->(dbSkip())
		EndDo

		conout("WFAPRVSC - LINHAS " +cTpLinha+" "+ DTOC(dDataBase))

		cQuery := " SELECT TOP(1) C1_XDTPROG FROM " + RetSqlName("SC1")
		cQuery += " WHERE C1_FILIAL = '"+cFilAnt+"' "
		cQuery += " AND C1_NUM = '"+_pedido+"' "
		cQuery += " AND D_E_L_E_T_ = '' "

		If Select("CDTX") > 0
			CDTX->(dbCloseArea())
		EndIf

		DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery) , 'CDTX', .T., .F.)

		If CDTX->(!EOF())
			If (STOD(CDTX->C1_XDTPROG) - 10) < dDatabase 
				lUrgente := .T.
				dDtLimte := dDatabase + 1
			Else
				lUrgente := .F.
				dDtLimte := (STOD(CDTX->C1_XDTPROG) - 10)
			EndIf
		EndIf

		conout("WFAPRVSC - DATA LIMITE " +DTOC(dDtLimte)+" "+ DTOC(dDataBase))

		cMensagem := '<p align="left"><font face="arial" color="#ff0000" size="4"><b>Mensagem Eletronica - WorkFlow</b></font></p>
		cMensagem += '<p align="left"><b>Prezados</b>,</p>
		cMensagem += '<p align="left">Foi liberada a <b>SC '+_pedido+'</b> das linhas <b>'+cTpLinha+'</b> para cotação e compra.</p><br/>
		cMensagem += '<p align="left"><b>Qualidade</b>,</p>
		If lUrgente
			cMensagem += '<p align="left">É obrigatório que a documentação seja atualizada, verificada e que fique disponível até a data limite: URGENTE (<b>'+DTOC(dDtLimte)+'</b>)</p><br/>
		else
			cMensagem += '<p align="left">É obrigatório que a documentação seja atualizada, verificada e que fique disponível até a data limite: <b>'+DTOC(dDtLimte)+'</b></p><br/>
		EndIF
		cMensagem += '<p align="left">A documentação inclui:</p>
		cMensagem += '<p align="left">- Artes;</p>
		cMensagem += '<p align="left">- Cadastro do produto (peso, cubagem, quantidade de peças por caixa, etc);</p>
		cMensagem += '<p align="left">- Certificação do produto (R.O.).</p><br/>
		cMensagem += '<p align="left">Obrigado</p>

		conout("WFAPRVSC - CORPO EMAIL "+ DTOC(dDataBase))

		CONOUT(cMensagem)

		SEND MAIL FROM cUserFrom TO cMailSC CC "" SUBJECT cAssunto BODY cMensagem RESULT lResult  // ATTACHMENT cAnexo1 

		If !lResult
			GET MAIL ERROR cError
			conout('WFAPRVSC -Erro de Envio de e-mail: '+cError)
		else

			conout('WFAPRVSC -eMail enviado!')
		
		EndIf

		DISCONNECT SMTP SERVER
	EndIf

Return .T.
