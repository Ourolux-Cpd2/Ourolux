#INCLUDE "PROTHEUS.CH"
#INCLUDE "AP5MAIL.CH"

#DEFINE POS_PO			1
#DEFINE POS_FORNECEDOR	2
#DEFINE POS_PRODUTO		3
#DEFINE POS_SI			4
/*
Rotina: MAILSOP
E-mail aviso de primeira compra
Autor: Rodrigo Dias Nunes	
Data: 16/09/2021
*/
User Function MAILSOP(aItemPO)   

	Local cData     := dtoc(ddatabase)
	Local cHora     := TIME()
	Local lSmtpSSL  := GetMV("MV_RELSSL")
	Local lSmtpTLS  := GetMV("MV_RELTLS")
	Local lAuteSMTP := GetNewPar("MV_RELAUTH",.F.)
	Local cServSMTP := GetMV("MV_RELSERV")
	Local cUserSMTP := GetMV("MV_RELACNT")
	Local cPassSMTP := GetMV("MV_RELPSW")
	Local cUserFrom := GetMV("MV_RELFROM")  
	Local cEmailTo  := SuperGetMV("ES_MAILSOP",.F.,"gerenciasop@ourolux.com.br")
    Local cAssunto  := "Alerta da Primeira Produção - SC "
    Local lResult   := .f. 
	Local cQuery 	:= ""
	Local nlx		:= 0
	Local aMsgPrd	:= {}
	Local cNumSC	:= ""
	
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
	
 	For nlx := 1 to Len(aItemPO)
		cQuery := " SELECT C1_NUM, C1_PRODUTO, C1_DESCRI, C1_QUANT, C1_XDTPROG, C1_DATPRF FROM " + RetSqlName("SC1")
		cQuery += " WHERE C1_FILIAL = '"+GetAdvFVal("SYT","YT_X_FILIA",XFILIAL("SYT")+SW2->W2_IMPORT,1)+"' "
		cQuery += " AND C1_NUM = ( SELECT W0_C1_NUM FROM " + RetSqlName("SW0")
		cQuery += " 	   		   WHERE W0__NUM = '"+aItemPO[nlx][POS_SI]+"' "
		cQuery += " 			   AND D_E_L_E_T_ = '' ) "
		cQuery += " AND C1_PRODUTO = '"+aItemPO[nlx][POS_PRODUTO]+"' "
		cQuery += " AND D_E_L_E_T_ = '' "

		If Select("X1CP") > 0
			X1CP->(dbCloseArea())
		EndIf				
		
		DbUseArea( .T.,"TOPCONN",TCGENQRY(,,cQuery),"X1CP",.F.,.T. )
		
		If X1CP->(!EOF())
			If Empty(cNumSC)
				cNumSC := Alltrim(X1CP->C1_NUM) + ", "
			else
				If !Alltrim(X1CP->C1_NUM) $ cNumSC
					cNumSC += Alltrim(X1CP->C1_NUM) + ", "
				EndIf
			EndIf
			AADD(aMsgPrd,"<strong>PRODUTO:</strong> " + PadR(X1CP->C1_PRODUTO,TAMSX3("C1_PRODUTO")[1]) +" - "+ PadR(X1CP->C1_DESCRI,TAMSX3("C1_DESCRI")[1]) +" - <strong>QTD:</strong> "+ TRANSFORM(X1CP->C1_QUANT,PesqPict('SC1','C1_QUANT')) +" - <strong>DT. lIMITE COMPRA:</strong> "+ DTOC(STOD(X1CP->C1_XDTPROG))+" - <strong>DT. ENTREGA CD:</strong> "+ DTOC(STOD(X1CP->C1_DATPRF)))
		EndIf
	Next

	cMensagem := ' <p align="left">Prezados(as),</p>
	cMensagem += ' <p align="left">O processo número <strong>'+aItemPO[1][POS_PO]+'</strong> referente à(s) SC(s) <strong>'+cNumSC+'</strong>foi colocado para o fornecedor <strong>'+aItemPO[1][POS_FORNECEDOR]+ ' - ' + GetAdvFVal("SA2","A2_NREDUZ",XFILIAL("SA2") + aItemPO[1][POS_FORNECEDOR],1)+ '</strong> e será a primeira produção dos produtos abaixo: </p>

	For nlx := 1 to len(aMsgPrd)	
		cMensagem += ' <p align="left"><font color="#ff0000">'+aMsgPrd[nlx]+'</font></p>
	Next

	cMensagem += ' <p align="left">Se necessário, favor revisar a data da entrega no CD considerando um prazo maior para a realização da produção.</p>
	cMensagem += ' <br> '
    cMensagem += ' <p align="left">Data do Envio: <strong>' + cData + '.</strong></p> '
	cMensagem += ' <p align="left">Hora: <strong>' + cHora + '.</strong></p> ' 
    cMensagem += ' </body> '
	
	cAssunto += SubStr(Alltrim(cNumSC),1,Len(Alltrim(cNumSC))-1)
	
	SEND MAIL FROM cUserFrom TO cEmailTo CC "" SUBJECT cAssunto BODY cMensagem RESULT lResult  // ATTACHMENT cAnexo1 

	If !lResult
	    GET MAIL ERROR cError
   	    conout('Erro de Envio de e-mail: '+cError)
	else

		conout('eMail enviado!')
	
	EndIf

	DISCONNECT SMTP SERVER

Return .T.
