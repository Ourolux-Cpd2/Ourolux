#Include "rwmake.ch"  
#include "ap5mail.ch"
/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    � ACSendMail� Autor � Consultoria          � Data � 03/03/10   ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Rotina para o envio de emails                                ���
���������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 : Conta para conexao com servidor SMTP                 ���
���          | ExpC2 : Password da conta para conexao com o servidor SMTP   ���
���          � ExpC3 : Servidor de SMTP                                     ���
���          � ExpC4 : Conta de origem do e-mail. O padrao eh a mesma conta ���
���          �         de conexao com o servidor SMTP.                      ���
���          � ExpC5 : Conta de destino do e-mail.                          ���
���          � ExpC6 : Assunto do e-mail.                                   ���
���          � ExpC7 : Corpo da mensagem a ser enviada.               	    |��
���          | ExpC8 : Patch com o arquivo que serah enviado                |��
���          | ExpC9 : Envia o e-mail de Copia                              |��
���������������������������������������������������������������������������Ĵ��
��� Uso      � SIGAGAC                                                      ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/

User Function ACSendMail(cAccount,cPassword,cServer,cFrom,cEmail,cAssunto,cMensagem,cAttach, cToCc, cToCco, cEmailTo )

Local cEmailBcc:= ""
Local lResult  := .T.
Local cError   := ""
Local i        := 0
Local cArq     := "" 

LOCAL cAccount	:= NIL
LOCAL cServer	:= NIL
LOCAL cPassword	:= NIL

LOCAL cMailConta	:= NIL
LOCAL cMailServer	:= NIL
LOCAL cMailSenha	:= NIL
LOCAL lAuth    		:= NIL

	//Local cEmailTo := ""
	CONOUT("PARAMETRIZANDO A ROTINA")		
	// Verifica se serao utilizados os valores padrao.                                               
	// MGOMES - TAGGS - 15/08/2013 - INICIO
	cMailConta	:= Iif( cAccount  == NIL, GetMV( "MV_RELACNT" ), cAccount  )//If(cMailConta 	== NIL,GETMV("MV_EMCONTA"),cMailConta)          // MV_WFMAIL 
	cMailServer	:= Iif( cServer   == NIL, GetMV( "MV_RELSERV" ), cServer   ) //If(cMailServer 	== NIL,GETMV("MV_RELSERV"),cMailServer)
	cMailSenha	:= Iif( cPassword == NIL, GetMV( "MV_RELPSW"  ), cPassword ) //If(cMailSenha 	== NIL,GETMV("MV_EMSENHA"),cMailSenha)			// MV_WFPASSW
	lAuth  		:= GetMv("MV_RELAUTH")
	// MGOMES - TAGGS - 15/08/2013 - FIM
	/*
	cMailConta	:= Iif( cAccount  == NIL, GetMV( "MV_WFMAIL" ), cAccount  )//If(cMailConta 	== NIL,GETMV("MV_EMCONTA"),cMailConta)          // MV_WFMAIL 
	cMailServer	:= Iif( cServer   == NIL, GetMV( "MV_WFSMTP" ), cServer   ) //If(cMailServer 	== NIL,GETMV("MV_RELSERV"),cMailServer)
	cMailSenha	:= Iif( cPassword == NIL, GetMV( "MV_WFPASSW"  ), cPassword ) //If(cMailSenha 	== NIL,GETMV("MV_EMSENHA"),cMailSenha)			// MV_WFPASSW
	lAuth  		:= GetMv("MV_RELAUTH")
    */

	//cFrom		:= Iif( cFrom == NIL, cAccount + "@" +;
	//					 SubStr( cServer, At(".",cServer)+1, Len(cServer) ),;
	//                     cFrom )
	
	//�������������������������������������������������������������������������������Ŀ
	//�Envia o e-mail para a lista selecionada. Envia como BCC para que a pessoa pense�
	//�que somente ela recebeu aquele email, tornando o email mais personalizado.     �
	//���������������������������������������������������������������������������������
	//cEmailTo := SubStr(cEmail,1,At(";",cEmail)-1)
	
	cEmailBcc:= cToCc + IIF( !EMPTY(cToCco), ";" + cToCco, "" )
	CONOUT("cEmailTo " + cEmailTo )
	//��������������������������������Ŀ
	//�Verifica se existe o SMTP Server�
	//����������������������������������
	If Empty(cMailServer)
		Help(" ",1,"O Servidor de SMTP nao foi configurado !!!" ,"Atencao")
		Return(.F.) 
	EndIf
	
	CONNECT SMTP SERVER cMailServer ACCOUNT cMailConta PASSWORD cMailSenha RESULT lResult
	CONOUT("Conexao com o servidor " )	
	CONOUT(lResult)
CONOUT("Autenticado" )
CONOUT( lAuth )

	If lAuth
		lResult := MailAuth(cMailConta,cMailSenha)
 		If !lResult
			lResult := QADGetMail() // Funcao que abre uma janela perguntando o usuario e senha para fazer autenticacao
		EndIf
	EndIf

	CONOUT("Autenticado" )
	CONOUT( lAuth )
	If lResult
	//   cFrom	:= UsrRetMail(RetCodUsr())
	
		SEND MAIL 	FROM 		cFrom ;
					TO 			cEmailTo;
					BCC     	cEmailBcc;
					SUBJECT 	cAssunto;
					BODY    	cMensagem;
					RESULT lResult
	
		If !lResult
			//Erro no envio do email
			GET MAIL ERROR cError
			Help(" ",1,"ATENCAO",,cError,4,5)
		EndIf
		 
		DISCONNECT SMTP SERVER
		conout("enviou")	
	Else
		conout("falhou")
		//Erro na conexao com o SMTP Server
		GET MAIL ERROR cError
		Help(" ",1,"ATENCAO",,cError,4,5)

	EndIf

Return(lResult)


