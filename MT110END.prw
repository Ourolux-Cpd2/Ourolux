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
        WFMAIL("APROVADO",Alltrim(SM0->M0_FILIAL),nNumSC,cUsuario,cMailCom,cNomeCom)
	ElseIf nOpca == 2
        WFMAIL("REJEITADO",Alltrim(SM0->M0_FILIAL),nNumSC,cUsuario,cMailCom,cNomeCom)
    ElseIf nOpca == 3
        WFMAIL("BLOQUEADO",Alltrim(SM0->M0_FILIAL),nNumSC,cUsuario,cMailCom,cNomeCom)
    EndIf

Return

//////////////////////////////////////////////////////////////////////

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
