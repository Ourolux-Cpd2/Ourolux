#INCLUDE "PROTHEUS.CH"
#INCLUDE "RPTDEF.CH"  
#INCLUDE "apwebex.ch"
#INCLUDE "ap5mail.ch"
#include "TOTVS.CH"   


//-------------------------------------------------------------------------------------
/*/{Protheus.doc} OPONRBH
Envio de Extrato de Banco de Horas  - Chamada Principal

@type 		function
@author 	Roberto Souza
@since 		19/07/2017
@version 	P11 
 
@return nil
/*/    
//-------------------------------------------------------------------------------------
User Function OPONRBH( lTerminal , lPortal )

	Private cPerg     := 'EXTRBH'
	If Pergunte( cPerg , .T. )
		    
		FWMsgRun(,{|| CursorWait(),U_XPONRBH( lTerminal , lPortal ),Sleep(1000),CursorArrow()},,"Processando Extratos..." )
    EndIf
Return                           


//-------------------------------------------------------------------------------------
/*/{Protheus.doc} XPONRBH
Envio de Extrato de Banco de Horas  - Chamada do Processo

@type 		function
@author 	Roberto Souza
@since 		19/07/2017
@version 	P11 
 
@return nil
/*/    
//-------------------------------------------------------------------------------------

User Function XPONRBH( lTerminal , lPortal )
	Local cLogE := ""
	Local cLogM := ""
	Local Nx    := 0
/*
	RpcSetEnv("01","03")
	RpcSetType(3)
	
	Private cPerg     := 'EXTRBH'
	Pergunte( cPerg , .T. )
*/
	Terminal := IF( lTerminal == NIL , .F. , lTerminal )
	lPortal 	:= IF( lPortal == NIL , .F. , lPortal )

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica as perguntas selecionadas                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Private FilialDe  := IF( !lTerminal , MV_PAR01 , cFilTerminal	)	//Filial  De
	Private FilialAte := IF( !lTerminal , MV_PAR02 , cFilTerminal	)	//Filial  Ate
	Private CcDe      := IF( !lTerminal , MV_PAR03 , SRA->RA_CC		)	//Centro de Custo De
	Private CcAte     := IF( !lTerminal , MV_PAR04 , SRA->RA_CC		)	//Centro de Custo Ate
	Private TurDe     := IF( !lTerminal , MV_PAR05 , SRA->RA_TNOTRAB)	//Turno De
	Private TurAte    := IF( !lTerminal , MV_PAR06 , SRA->RA_TNOTRAB)	//Turno Ate
	Private MatDe     := IF( !lTerminal , MV_PAR07 , cMatTerminal	)	//Matricula De
	Private MatAte    := IF( !lTerminal , MV_PAR08 , cMatTerminal	)	//Matricula Ate
	Private NomDe     := IF( !lTerminal , MV_PAR09 , SRA->RA_NOME	)	//Nome De
	Private NomAte    := IF( !lTerminal , MV_PAR10 , SRA->RA_NOME	)	//Nome Ate
	Private RegDe     := IF( !lTerminal , MV_PAR11 , SRA->RA_REGRA	)	//Regra De
	Private RegAte    := IF( !lTerminal , MV_PAR12 , SRA->RA_REGRA	)	//Regra Ate
	Private dDtIni    := IF( !lTerminal , MV_PAR13 , YearSub(dDataBase, 1))	//Data Inicial
	Private dDtFim    := IF( !lTerminal , MV_PAR14 , dDataBase		)	//Data Final
	Private cSit      := IF( !lTerminal , MV_PAR15 , fSituacao(,.F.))	//Situacao
	Private cCat      := IF( !lTerminal , MV_PAR16 , fCategoria(,.F.))	//Categoria
	Private nHoras    := IF( !lTerminal , MV_PAR17 , 1				)	//Horas Normais/Valorizadas
	Private nCopias   := IF( !lTerminal , MV_PAR18 , 1				)	//Numero de Copias
	Private nSalBH	  := IF( !lTerminal , MV_PAR19 , 1				)	//Imprimir com Saldo(Result/Credor/Devedor)
	Private nTpEvento := IF( !lTerminal , MV_PAR20 , 3				)	//Imprimir Eventos(Autoriz/N.Autoriz/Ambos)
	                  
	Private cSRA      := GetNextAlias()
	Private cWhereSRA := ""	 	 
	Private cOrdSRA   := "%(RA_FILIAL + RA_MAT)%"
	Private nTotE	  := 0
	Private nTotF	  := 0
	Private nTotSM	  := 0
	Private lCustom	  := .T.
	
	DbSelectArea("SRA")
	DbSetOrder(1)
    
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta o Fultro de Acordo com as perguntas                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cWhereSRA += "%"
	cWhereSRA += "RA_TNOTRAB >= '"+	Turde 	+"' AND " 
	cWhereSRA += "RA_TNOTRAB <= '"+	TurAte 	+"' AND " 
	cWhereSRA += "RA_NOME >= '"	+	NomDe 	+"' AND "  
	cWhereSRA += "RA_NOME <= '"	+	NomAte 	+"' AND "  
	cWhereSRA += "RA_MAT >= '"	+	MatDe 	+"' AND "  
	cWhereSRA += "RA_MAT <= '"	+	MatAte 	+"' AND "  
	cWhereSRA += "RA_CC >= '"	+	CCDe 	+"' AND "  
	cWhereSRA += "RA_CC <= '"	+	CCAte 	+"' AND "  
	cWhereSRA += "RA_REGRA >= '"+	RegDe 	+"' AND " 
	cWhereSRA += "RA_REGRA <= '"+	RegAte 	+"' AND "    

	//-- Consiste Preenchimento de Cracha e data de Demiss„o
	cWhereSRA += " (RA_DEMISSA = '' OR RA_DEMISSA >= '" + Dtos(dDtIni) + "') AND "  
   //-- Consiste Situacao e Categoria
	cSit_In := ""	
	For Nx := 1 To Len(cSit)
		cSit_In += Substr(cSit,Nx,1)+";"
	Next

	cCat_In := ""	
	For Nx := 1 To Len(cCat)
		cCat_In += Substr(cCat,Nx,1)+";"
	Next

	cWhereSRA += " RA_SITFOLH IN "+	FormatIn(cSit_In,";") 	+" AND "  
	cWhereSRA += " RA_CATFUNC IN "+	FormatIn(cCat_In,";") 	+" "  

	cWhereSRA += "%"


	BeginSql ALIAS cSRA
   
 		SELECT R_E_C_N_O_ RECNO 
 			FROM %table:SRA% SRA
 			WHERE %Exp:cWhereSRA%
			AND SRA.%NotDel%
			ORDER BY %Order:SRA%
    EndSql

	If (cSRA)->(!EOF())
	
		While (cSRA)->(!EOF())	

			nRecSRA := (cSRA)->RECNO  
			DbSelectArea("SRA")
			DbGoTo( nRecSRA )			

			cFilMat 	:= SRA->RA_FILIAL
			cNumMat		:= SRA->RA_MAT
			cAnoMes 	:= IIf(Empty(MV_PAR13),"20170101", Dtos(MV_PAR13)) +"-"+Dtos(MV_PAR14) //Substr(Dtos(MV_PAR13),1,6) //"201706"
			cMailPara   := SRA->RA_EMAIL2
			cCab 		:= GetCab()
			cRet 		:= U_Extrabh( .T. , cFilMat , cNumMat, .F. , lCustom )   
	        
			If !Empty(cRet)
				cRet := StrTran(cRet,'Extrato Banco de Horas','<Center><b>Extrato Banco de Horas</b></Center><br>'+cCab)   
		
				cRet := StrTran(cRet,'<td background="imagens/tabela_conteudo_1.gif" width="10">&nbsp;</td>','')
				cRet := StrTran(cRet,'<img src="imagens/icone_titulo.gif" width="7" height="9">','')
				cRet := StrTran(cRet,'<p><img src="imagens/tabela_conteudo.gif" width="515" height="12" align="center"></p>','')
				cRet := StrTran(cRet,'<td class="titulo" width="498">','<td class="titulo" width="600">')   
				cRet := StrTran(cRet,'<table width="498" border="0" cellspacing="0" cellpadding="0">','<table width="900" border="1" cellspacing="1" cellpadding="1">')   
				cRet := StrTran(cRet,'<td background="imagens/tabela_conteudo_2.gif" width="7">&nbsp;</td>','')
				cRet := StrTran(cRet,'<img src="imagens/tabela_conteudo_3.gif" "515" height="14" align="center">','')
				cRet := StrTran(cRet,'<td colspan="06" class="etiquetas" bgcolor="#FAFBFC"><hr size="1"></td>','')
				cRet := StrTran(cRet,'<br><br>','<br>')
				cRet := StrTran(cRet,'<p align="right"><a href="javascript:self.print()"><img src="imagens/imprimir.gif" width="90" height="28" hspace="20" border="0">','')
		
			    MemoWrite("\workflow\rh\"+cNumMat+"_"+cAnoMes+".htm",cRet) 
			    
			    lOk := U_oSendBH(cMailPara,cNumMat,cAnoMes,cRet)

				Iif(lOk,nTotE++,nTotF++)
				
				cLogE += cFilMat+" - "+cNumMat+" - "+cAnoMes+" - "+Lower(AllTrim(cMailPara))+" - " +Iif(lOk,"Enviado","Falhou")+CRLF
				cLogM += cFilMat+" - "+cNumMat+" - "+cAnoMes+" - "+Lower(AllTrim(cMailPara))+" - " +Iif(lOk,"Enviado","Falhou")+"<br>"			
			Else
				cLogE += cFilMat+" - "+cNumMat+" - "+cAnoMes+" - "+Lower(AllTrim(cMailPara))+" - " +"Sem Movimento"+CRLF
				cLogM += cFilMat+" - "+cNumMat+" - "+cAnoMes+" - "+Lower(AllTrim(cMailPara))+" - " +"Sem Movimento"+"<br>"			
				nTotSM++
			EndIf
	
			(cSRA)->(DbSkip())	    
		EndDo

		cLogE := "Extrato de Banco de Horas"+CRLF+CRLF+cLogE +CRLF
		cLogE += "Total Enviado.........: " +StrZero(nTotE,6) +CRLF
		cLogE += "Total Com Falha.......: " +StrZero(nTotF,6) +CRLF    
		cLogE += "Total Sem Movimento...: " +StrZero(nTotSM,6) +CRLF    

		cLogM := '<font size="2" face="courier new"><b>Extrato de Banco de Horas</b><br>'+cLogM
		cLogM += "Total Enviado.........: " +StrZero(nTotE,6) +"<br>"
		cLogM += "Total Com Falha.......: " +StrZero(nTotF,6) +"<br>"
		cLogM += "Total Sem Movimento...: " +StrZero(nTotSM,6) +"<br>"
		cLogM += "</font>"
		
		SendNotif( cLogM )
		Aviso("Extrato de Banco de Horas",cLogE,{"Ok"},3)			

	Else
		Aviso("Extrato de Banco de Horas","Não existem dados nos parametros informados!",{"Ok"},2)	
	EndIf
	
Return                     


//-------------------------------------------------------------------------------------
/*/{Protheus.doc} GetCab
Monta o cabecalho padrao para complemento do html do extrato do BH

@type 		function
@author 	Roberto Souza
@since 		19/07/2017
@version 	P11 
 
@return nil
/*/    
//-------------------------------------------------------------------------------------
Static Function GetCab()
	Local cRet := ''
	Local cSpc := '-'
	Local nTmr := 60
	Local nTml := 60
	           
	Local cFil := xFilial('SR6', SRA->RA_FILIAL)
	
	DbSelectArea("SR6")
	If SR6->(DbSeek(cFil+SRA->RA_TNOTRAB,.F.))
	   cDescTno := Left(AllTrim(SR6->R6_DESC),50)
	EndIf

	cRet +=	'<b>'
	cRet +=	'<font size="2" face="courier new">'
	cRet +=	'Emp...: '+Padr(AllTrim(SM0->M0_NOMECOM)+" -"+Replicate(cSpc,nTmr),nTml)              +' Matr..: '+SRA->RA_FILIAL+'-'+SRA->RA_MAT +IIf(!Empty(SRA->RA_CHAPA), '  Chapa :' +SRA->RA_CHAPA ,'')    
	cRet +=	'<br>'
	cRet +=	'End...: '+Padr(AllTrim(SM0->M0_ENDCOB) +" -"+Replicate(cSpc,nTmr),nTml)              +' Nome..: '+SRA->RA_NOME        
	cRet +=	'<br>'
	cRet +=	'CGC...: '+Padr(AllTrim(Transform( SM0->M0_CGC,'@R 99.999.999/9999-99')) +" -"+Replicate(cSpc,nTmr),nTml)                                +' Funcao: '+AllTrim(SRA->RA_CODFUNC) + '-' + AllTrim(DescFun(SRA->RA_CODFUNC , SRA->RA_FILIAL))
	cRet +=	'<br>'
	cRet +=	'C.C...: '+Padr( AllTrim(SRA->RA_CC + '-' + DescCc(SRA->RA_CC, SRA->RA_FILIAL,30)) +" -"+Replicate(cSpc,nTmr),nTml)                      +' Categ.: '+DescCateg(SRA->RA_CATFUNC,15)//'MENSALISTA'     
	cRet +=	'<br>'
	cRet +=	'Turno.: '+Padr(AllTrim(SRA->RA_TNOTRAB) + '-' + cDescTno ,nTml)
	cRet +=	'</font>'
	cRet +=	'</b>'

Return( cRet )
                       
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³SENDEPO   ºAutor  ³Isaias Chipoch      º Data ³  05/04/16   º±±
±±ºPrograma  ³oSendBH   ºAutor  ³Roberto Souza       º Data ³  18/07/16   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Envio do espelho de ponto via e-mail                       º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/


//-------------------------------------------------------------------------------------
/*/{Protheus.doc} oSendBH
Processa o envio do e-mail
Baseada na rotina 
±±ºPrograma  ³SENDEPO   ºAutor  ³Isaias Chipoch      º Data ³  05/04/16   º±±

@type 		function
@author 	Roberto Souza
@since 		19/07/2017
@version 	P11 
 
@return nil
/*/    
//-------------------------------------------------------------------------------------
User function oSendBH( cMailPara, cNumMat, cAnoMes, cHtml )

	Local lRet := .T.
	Local oServer
	Local oMessage
	Local nNumMsg := 0
	Local nTam := 0
	Local nI := 0           
	Local cFullSrv	:= Getmv("MV_RELSERV")
	Local aSrv		:= Separa(cFullSrv,":")
	Local cServer	:= aSrv[01] //Substr(getmv("MV_RELSERV"),1,13)
	Local nPortCon	:= Val(aSrv[02]) 
	Local cAccount	:= Getmv("MV_RELACNT")
	Local cPasswd	:= Getmv("MV_RELPSW")
	Local lTls		:= Getmv("MV_RELTLS") 
	Local lSSL		:= Getmv("MV_RELSSL") 
	Local cFileName := "\workflow\rh\"+cNumMat+"_"+cAnoMes+".htm"
	Local lAttach   := !Empty( cHtml ) 
	
	//Cria a conexão com o server STMP ( Envio de e-mail )
	oServer := TMailManager():New()
	//Seta usar TLS
	oServer:SetUseTLS(lTls)
	oServer:SetUseSSL(lSsl)
	
	oServer:Init( "", cServer, cAccount, cPasswd, , nPortCon )
	//seta um tempo de time out com servidor de 1min	I
	
	//seta um tempo de time out com servidor de 1min	I
	If oServer:SetSmtpTimeOut( 60 ) != 0
		sMsg := "Falha ao setar o time out"
		Conout(sMsg)
		//Alert(sMsg)
		Return .F.
	EndIf
	
	//realiza a conexão SMTP
	// Conecta ao servidor
	nErr := oServer:smtpConnect()
	If nErr <> 0
		sMsg := "[ERROR]Falha ao conectar: " + oServer:getErrorString(nErr)
		oServer:smtpDisconnect()
		Conout(sMsg)
		//Alert(sMsg)
		return .F.
	Endif
	
	// Realiza autenticacao no servidor
	nErr := oServer:smtpAuth(cAccount, cPasswd)
	If nErr <> 0
		sMsg := "[ERROR]Falha ao autenticar: " + oServer:getErrorString(nErr)
		oServer:smtpDisconnect()
		Conout(sMsg)
		//Alert(sMsg)
		Return(.F.)
	Endif
	
	
	//Apos a conexão, cria o objeto da mensagem
	oMessage := TMailMessage():New()	//Limpa o objeto
	oMessage:Clear()
	//Popula com os dados de envio
	oMessage:cFrom := "workflow2@ourolux.com.br"	// emeio de envio
	oMessage:cTo := cMailPara // emails que vai receber
	oMessage:cCc := ""
	oMessage:cBcc := ""
	oMessage:cSubject := "Extrato de Banco de Horas - Ourolux"
	msg:= "Segue seu extrato de banco de horas."
	msg+= "<BR>"
	msg+= "<BR>"                                                                                                                       
	
	
	oMessage:cBody := msg
	
	If lAttach 
		//Adiciona um attach anexa arquivo ele pega o anexo dentro da pasta Workflow fica no mesmo nivel que a pasta apo
		If oMessage:AttachFile( cFileName ) < 0 //"\workflow\rh\"+cNumMat+".pdf" ) < 0
			Conout( "Erro ao atachar o arquivo" )
			Return(.F.)
		Else
			//adiciona uma tag informando que é um attach e o nome do arq
			oMessage:AddAtthTag( 'Content-Disposition: attachment; filename='+cNumMat+"_"+cAnoMes+".htm")
		EndIf 
		//Envia o e-mail
	Else
		oMessage:cBody := cHtml
	EndIf
		
	nErr := oMessage:Send( oServer )
	if nErr <> 0
		sMsg := "[ERROR]Nao conseguiu enviar o e-mail: " + oServer:GetErrorString( nErr )
		conout( sMsg )
		Return(.F.)
	endif
	
	//Desconecta do servidor
	
	If oServer:SmtpDisconnect() != 0
		sMsg := "Erro ao desconectar do servidor SMTP"
		Conout(sMsg)
		Return(.F.)
	EndIf
	
Return(.T.)
      
       
//-------------------------------------------------------------------------------------
/*/{Protheus.doc} SendNotif
Processa o envio do resumo do processo no e-mail do operador
Baseada na rotina 
±±ºPrograma  ³SENDEPO   ºAutor  ³Isaias Chipoch      º Data ³  05/04/16   º±±

@type 		function
@author 	Roberto Souza
@since 		19/07/2017
@version 	P11 
 
@return nil
/*/    
//-------------------------------------------------------------------------------------
Static Function SendNotif( cLogE )
	Local cMailPara := ""
	Local aArray 	:= {}



	Local lRet := .T.
	Local oServer
	Local oMessage
	Local nNumMsg := 0
	Local nTam := 0
	Local nI := 0           
	Local cFullSrv	:= Getmv("MV_RELSERV")
	Local aSrv		:= Separa(cFullSrv,":")
	Local cServer	:= aSrv[01] //Substr(getmv("MV_RELSERV"),1,13)
	Local nPortCon	:= Val(aSrv[02]) 
	Local cAccount	:= Getmv("MV_RELACNT")
	Local cPasswd	:= Getmv("MV_RELPSW")
	Local lTls		:= Getmv("MV_RELTLS") 
	Local lSSL		:= Getmv("MV_RELSSL") 
	Local cFileName := ""
	Local lAttach   := .F. 
	
	PswOrder(1)
	If PswSeek( RetCodUsr() , .T. )  
	   aArray := PswRet() // Retorna vetor com informações do usuário
	   cMailPara  := aArray[1][14]
	EndIf     
	
	oServer := TMailManager():New()
	oServer:SetUseTLS(lTls)
	oServer:SetUseSSL(lSsl)
	
	oServer:Init( "", cServer, cAccount, cPasswd, , nPortCon )
	If oServer:SetSmtpTimeOut( 60 ) <> 0
		sMsg := "Falha ao setar o time out"
		return .F.
	EndIf
	
	nErr := oServer:smtpConnect()
	If nErr <> 0
		sMsg := "[ERROR]Falha ao conectar: " + oServer:getErrorString(nErr)
		oServer:smtpDisconnect()
		return .F.
	Endif
	
	nErr := oServer:smtpAuth(cAccount, cPasswd)
	If nErr <> 0
		sMsg := "[ERROR]Falha ao autenticar: " + oServer:getErrorString(nErr)
		oServer:smtpDisconnect()
		Return(.F.)
	Endif
	
	oMessage := TMailMessage():New()	//Limpa o objeto
	oMessage:Clear()
	//Popula com os dados de envio
	oMessage:cFrom := "workflow2@ourolux.com.br"	// emeio de envio
	oMessage:cTo := cMailPara // emails que vai receber
	oMessage:cCc := ""
	oMessage:cBcc := ""
	oMessage:cSubject := "Log de Extrato de Banco de Horas - Ourolux"
	msg := '<font size="2" face="courier new">Log de Envio de Extrato de Banco de Horas.</font>'
	msg += "<BR>"
	msg += "<BR>"
	msg += cLogE                                                                                                                       

	oMessage:cBody := msg
		
	nErr := oMessage:Send( oServer )
	if nErr <> 0
		sMsg := "[ERROR]Nao conseguiu enviar o e-mail: " + oServer:GetErrorString( nErr )

		Return(.F.)
	endif
	
	//Desconecta do servidor
	If oServer:SmtpDisconnect() != 0
		sMsg := "Erro ao desconectar do servidor SMTP"
		Return(.F.)	
	EndIf	
	
Return(.T.)