#INCLUDE "rwmake.ch"
#INCLUDE "ap5mail.ch" 
#INCLUDE "tbiconn.ch"  
#INCLUDE "protheus.ch"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±º Programa  º GEmailAv1  º Autor º MARCOS GOMES (TAGGS) º Data º  18/07/2013 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Descricao º Gera o e-mail de cobranca ao(s) vendedor(es) que estao com     º±±
±±º           º acerto de NOTAS FISCAIS DE Comissao em atraso;                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Uso       º Clientes PROTHEUS.                                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º   DATA    º Alteracao                                        º   Analista  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º   /  /    º -                                                º             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
USER FUNCTION GEmailAvis(cControlE)

LOCAL cHTML		:= ""					// Variavel que cria o HTML do e-mail
LOCAL cEOL		:= Chr(13) + Chr(10)	// Marca o Final de linha	

LOCAL cQuery							// Cria a variavel da Query
LOCAL cAliasSE2	:= "SE2ALIAS"			// Alias da query SE2
LOCAL cAliasSA3	:= "SA3ALIAS"			// Alias da query SA3
LOCAL cAliasUPD	:= "SE2UPD"				// Alias do UPDATE
LOCAL cCodForn 	:= ""					// Variavel de Controle do Codigo do Fornecedor / Loja
LOCAL cLojForn	:= ""

LOCAL cNaturez	:= ""

LOCAL cAccount	:= ""		// workflow@ourolux.com.br
LOCAL cPassword	:= ""		// ouro-flow
LOCAL cServer	:= ""	  	// smtp.gmail.com:465
LOCAL cFrom		:= ""		// workflow@ourolux.com.br
LOCAL cEmail	:= ""		// workflow@ourolux.com.br
LOCAL cAssunto	:= ""		// assunto do e-mail
LOCAL cMensagem	:= ""		// corpo da mensagem
LOCAL cAttach	:= .f.
LOCAL cToCc		:= ""
LOCAL cToCco	:= ""

LOCAL cEmailEmp	:= ""
LOCAL cTelefone	:= ""

LOCAL lFlag		:= .t.

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//| Prepara o ambiente para ser usado no SCHEDULE                |
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		Conout("Iniciando o GEMAILAVIS")
	
		Conout("isBlind")
		conout(isBlind())

		If SELECT("SX2") == 0
				Conout("yes isBlind")
				PREPARE ENVIRONMENT EMPRESA "01" FILIAL "01" MODULO "FAT" TABLES "SA1", "SA2", "SA3", "SE2", "SE3", "SE4"
		Endif

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//| Alimentando as variaveis                                     |
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		conout("TESTANDO O SCHEDULE")
		Conout("cControle")
		Conout(cControle)
		Conout(valtype(		cControle ) )
		cAccount	:= GETMV( "MV_RELACNT" )		// workflow@ourolux.com.br
		cPassword	:= GETMV( "MV_RELAPSW" )		// ouro-flow
		cServer		:= GETMV( "MV_RELSERV" )	  	// smtp.gmail.com:465
		cFrom		:= GETMV( "MV_RELFROM" )		// workflow@ourolux.com.br
		cAssunto	:= SUPERGETMV( "FS_ASSUNTO",, "OUROLUX: Cobranca de envio de nota fiscal de comissão" )
		cMensagem	:= ""

		//cNaturez	:= PADR( SUPERGETMV( "FS_SEDNAT",, "COMISSAO" ), TAMSX3("E2_NATUREZ")[1] )		// Natureza do TITULO A PAGAR
		//cEmailEmp	:= SUPERGETMV( "FS_MAILSAC", , "sac@ourolux.com.br" )
		//cTelefone	:= SUPERGETMV( "FS_TELEMPR", , "+55 " + SM0->M0_TEL )


		CONOUT("Ambiente preparado")
		CONOUT( "iniciando a rotina")


		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//| Monta a query de SELECAO do(s) Registro(s)                   |
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cQuery	:= " "
		cQuery	+= " SELECT 	SE2.E2_ORIGEM, SE2.E2_PREFIXO, SE2.E2_NUM, SE2.E2_TIPO, SE2.E2_PARCELA, SE2.E2_VALOR, SE2.E2_SALDO, SE2.E2_VENCTO , "
		cQuery	+= " 			SE2.E2_VENCREA, SE2.E2_FORNECE, SE2.E2_LOJA, SE2.E2_IRRF, SE2.E2_ISS, SE2.E2_INSS, "		
		cQuery	+= " 			SA2.A2_NOME, SA3.A3_COD, A3_EMAIL "
		cQuery	+= " FROM 	" + RETSqlName("SE2") + " SE2 " 
		cQuery	+= " INNER JOIN " + RETSqlName("SA2") + " SA2 ON SE2.E2_FORNECE = SA2.A2_COD AND SE2.E2_LOJA = SA2.A2_LOJA "		
		cQuery	+= " INNER JOIN " + RETSqlName("SA3") + " SA3 ON SA2.A2_COD = SA3.A3_FORNECE AND SA2.A2_LOJA = SA3.A3_LOJA "		
		cQuery	+= " WHERE	SE2.E2_FILIAL = '" + xFilial("SE2") + "' "
		cQuery	+= " 		AND SA2.A2_FILIAL = '" + xFilial("SA2") + "' "
		cQuery	+= " 		AND SA3.A3_FILIAL = '" + xFilial("SA3") + "' "
//		cQuery	+= " 		AND SE2.E2_SALDO > 0	"
//		cQuery	+= " 		AND SE2.E2_NATUREZ = '" + cNaturez + "' "
		cQuery	+= " 		AND SE2.E2_X_DTANF = '' "
		cQuery	+= "	 	AND SE2.E2_X_NUMNF = '' "
		cQuery	+= " 		AND SE2.E2_X_SERIE = '' "
 		cQuery	+= " 		AND SE2.E2_X_TT = 'S' "
		cQuery	+= " 		AND SA2.D_E_L_E_T_ <> '*' "
		cQuery	+= " 		AND SA3.D_E_L_E_T_ <> '*' "
		cQuery	+= " 		AND SE2.D_E_L_E_T_ <> '*' " 
		cQuery	+= " 		AND SA3.A3_UDTSAID = ' ' " 
		cQuery	+= " 		AND SE2.E2_VENCTO >= '20131101' " 
		cQuery	+= " ORDER BY SE2.E2_FORNECE, SE2.E2_LOJA, SE2.E2_VENCREA, SE2.E2_PREFIXO, SE2.E2_NUM, SE2.E2_PARCELA "
	
		If SELECT( cAliasSE2 ) > 0 
					DBSelectArea(cAliasSE2)
					DBCloaseArea()
		EndIf
		Conout("Gerou QUERY")		
		cQuery := ChangeQuery( cQuery )
	
		dbUseArea( .T., 'TOPCONN', TCGenQry( ,, cQuery ), cAliasSE2, .F., .T. )

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//| Monta a o arquivo HTML - Parte Inicial                       |
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cHTML_P0  	:= ' '
		cHTML_P0  	+= ' <!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN"> '
		cHTML_P0  	+= ' <HTML>'
		cHTML_P0  	+= ' <HEAD>'
		cHTML_P0  	+= ' <TITLE>::  ' + AllTrim( SM0->M0_NOMECOM ) + '::</TITLE>'
		cHTML_P0  	+= ' <META NAME="Generator" CONTENT="EditPlus">'
		cHTML_P0 	+= ' <META NAME="Author" CONTENT="">'
		cHTML_P0 	+= ' <META NAME="Keywords" CONTENT="">'
		cHTML_P0 	+= ' <META NAME="Description" CONTENT="">'
		cHTML_P0 	+= ' </HEAD>'
		
		cHTML_P0 	+= ' <BODY BGCOLOR="#FFFFFF" style="margim: 0px" spellcheck="false">'
		cHTML_P0 	+= ' <IMG SRC="http://lpadistribuidora.com.br/wp-content/uploads/2011/04/LOGO-OUROLUX-V122.jpg" WIDTH="280" HEIGHT="120" BORDER="0" ALT="">'
		cHTML_P0 	+= ' <font face="Verdana, Arial, Helvetica, sans-serif" size="2">'
		cHTML_P0 	+= ' <TABLE cellpading="0" cellspacing="0" border="0" width="600" align="left" border="0">'

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//| Monta a o arquivo HTML - Segunda parte                       |
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cHTML_P2  	:= " "
		cHTML_P2	+= ' <TABLE border=1 WIDTH="660">'
		cHTML_P2	+= ' <TR>'
		cHTML_P2	+= ' 	<TD ALIGN="center"><font face="Verdana, Arial, Helvetica, sans-serif" size="2">Prefixo</font></TD>'
		cHTML_P2	+= ' 	<TD ALIGN="center"><font face="Verdana, Arial, Helvetica, sans-serif" size="2">Título</font></TD>'
		cHTML_P2	+= ' 	<TD ALIGN="center"><font face="Verdana, Arial, Helvetica, sans-serif" size="2">Tipo</font></TD>'		// MGOMES EM 08/08/2013
		cHTML_P2	+= ' 	<TD ALIGN="center"><font face="Verdana, Arial, Helvetica, sans-serif" size="2">Vencimento</font></TD>' 
		cHTML_P2	+= ' 	<TD ALIGN="center"><font face="Verdana, Arial, Helvetica, sans-serif" size="2">Valor Bruto R$</font></TD>'
		// MGOMES EM 08/08/2013 - INICIO
		cHTML_P2	+= ' 	<TD ALIGN="center"><font face="Verdana, Arial, Helvetica, sans-serif" size="2">IRRF R$</font></TD>'
		cHTML_P2	+= ' 	<TD ALIGN="center"><font face="Verdana, Arial, Helvetica, sans-serif" size="2">ISS R$</font></TD>'
		cHTML_P2	+= ' 	<TD ALIGN="center"><font face="Verdana, Arial, Helvetica, sans-serif" size="2">INSS R$</font></TD>'
		// MGOMES EM 08/08/2013 - FIM

		cHTML_P2	+= ' </TR>'
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//| Monta a o arquivo HTML - Terceira parte                      |
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cHTML_P3 	:=  " "

		If cControlE == "3"			// 3 Aviso
					cHTML_P3 	+= ' <P><font face="Verdana, Arial, Helvetica, sans-serif" size="2">Devido ao atraso e aos avisos anteriores não terem diso atendidos. Informamos que o seu cadastro está BLOQUEADO e que as comissões pendentes só serão liberadas após a regularização das pendências.</font> '
		Else							// 1 e 2 Aviso
					cHTML_P3 	+= ' <P><font face="Verdana, Arial, Helvetica, sans-serif" size="2">Solicitamos que regularize a situção o mais breve o possível para evitar que ocorra o bloqueio dos próximos pagamentos.</font>'
		EndIf

		//cHTML_P3 	+= ' <P><font face="Verdana, Arial, Helvetica, sans-serif" size="2">Em caso de dúvida favor entrar em contato pelo Telefone: ' + cTelefone 
		cHTML_P3 	+= ' <P><font face="Verdana, Arial, Helvetica, sans-serif" size="2">Em caso de dúvida favor entrar em contato com seu Assistente Comercial.</font>'
		//cHTML_P3 	+= ' ou e-mail: <A HREF="' + AllTrim( cEmailEmp ) + '">' 
		//cHTML_P3 	+= AllTrim( cEmailEmp ) + '</A></font>'

		cHTML_P3	+= ' </TABLE>'
	
		cHTML_P3 	+= ' </BODY>'
		cHTML_P3 	+= ' </HTML>'
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//| Monta FINAL DO HTML PARA ENVIO.                              |
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		WHILE (cAliasSE2)->(!EOF())

	
					If cCodForn + cLojForn <> (cAliasSE2)->( E2_FORNECE + E2_LOJA )
								cCodForn 	:= (cAliasSE2)->E2_FORNECE		// Codigo do Fornecedor
								cLojForn 	:= (cAliasSE2)->E2_LOJA			// Loja do Fornecedor
								cVendedor	:= (cAliasSE2)->A3_COD			// Codigo do Vendedor
								cEmail		:= (cAliasSE2)->A3_EMAIL		// E-mail do Vendedor

								//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
								//| Monta a o arquivo HTML - Primeira parte Identificacao do Fornecedor   |
								//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
								//cControlE	:= "3"
								cHTML_P1	:= ' '
								cHTML_P1	+= ' <P style="color:#C01111">OUROLUX - Mensagem automática, favor não responder este e-mail.</P>'								
								cHTML_P1	+= ' <P>Sr(a). ' + ALLTrim( (cAliasSE2)->A2_NOME )
								cHTML_P1	+= ' <P>Consta em nossa base de dados pendente a(s) seguinte(s) comissão(ões) cuja Nota Fiscal de Prestação de Serviço, não foi(ram) entregue(s).'
								cHTML_P1	+= ' </font>'

								// 1A PARTE DO E-MAIL - CABECALHO
								cHTML		:= ''							// Inicializa a estrutura final do HTML
								cHTML		+= cHTML_P0						// Adiciona a parte Inicial do HTML
								cHTML		+= cHTML_P1						// Adiciona o cabecalho do HTML Identifica o Fornecedor
								cHTML		+= cHTML_P2						// Adiciona a primeira parte do corpo do HTML Cabecalhos
					EndIf
			
					// 2A PARTE DO E-MAIL - CORPO
					cHTML+= ' <TR>'
					cHTML+= ' 	<TD ALIGN="center"><font face="Verdana, Arial, Helvetica, sans-serif" size="2">' + (cAliasSE2)->E2_PREFIXO + '</font></TD>'
					cHTML+= ' 	<TD ALIGN="center"><font face="Verdana, Arial, Helvetica, sans-serif" size="2">' + AllTrim( (cAliasSE2)->E2_NUM ) + IIF( !EMPTY( (cAliasSE2)->E2_PARCELA ), "-" + (cAliasSE2)->E2_PARCELA, "" )     + '</font></TD>'
					cHTML+= ' 	<TD ALIGN="center"><font face="Verdana, Arial, Helvetica, sans-serif" size="2">' + AllTrim( (cAliasSE2)->E2_TIPO )  + '</font></TD>'			// MGOMES EM 08/08/2013
					cHTML+= ' 	<TD ALIGN="center"><font face="Verdana, Arial, Helvetica, sans-serif" size="2">' + DTOC( STOD( (cAliasSE2)->E2_VENCREA  ) ) + '</font></TD>'
					cHTML+= ' 	<TD ALIGN="center"><font face="Verdana, Arial, Helvetica, sans-serif" size="2">' + TransForm( (cAliasSE2)->E2_VALOR + (cAliasSE2)->E2_IRRF + (cAliasSE2)->E2_ISS + (cAliasSE2)->E2_INSS , PesqPict( "SE2", "E2_VALOR" ) ) + '</font></TD>'
	
					// MGOMES EM 08/08/2013 - INICIO
					cHTML+= ' 	<TD ALIGN="center"><font face="Verdana, Arial, Helvetica, sans-serif" size="2">' + TransForm( (cAliasSE2)->E2_IRRF , PesqPict( "SE2", "E2_IRRF" ) ) + '</font></TD>'
					cHTML+= '	<TD ALIGN="center"><font face="Verdana, Arial, Helvetica, sans-serif" size="2">' + TransForm( (cAliasSE2)->E2_ISS , PesqPict( "SE2", "E2_ISS" ) ) + '</font></TD>'
					cHTML+= '	<TD ALIGN="center"><font face="Verdana, Arial, Helvetica, sans-serif" size="2">' + TransForm( (cAliasSE2)->E2_INSS , PesqPict( "SE2", "E2_INSS" ) ) + '</font></TD>'
					// MGOMES EM 08/08/2013 - FIM
	
					cHTML+= ' </TR>'
	
					(cAliasSE2)->(DBSkip())
	
					// 3A PARTE DO E-MAIL - CORPO
					If cCodForn + cLojForn <> (cAliasSE2)->( E2_FORNECE + E2_LOJA ) .OR. (cAliasSE2)->(EOF())
	
								cHTML		+= ' </TABLE><P>'
	
								cHTML		+= cHTML_P3			// Adiciona o RODAPE do HTML
	
								U_ACSendMail(cAccount,cPassword,cServer,cFrom,cEmail,cAssunto,cHTML,cAttach, cToCc, cToCco, cEmail )			// Envia o e-mail

								//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
								//| 3o AVISO - BLOQUEIA O VENDEDOR                                              |
								//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ											
								If cControlE == "3"
			
										Conout("Bloqueia")
								
										//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
										//| (SA3) - Posiciona o arquivo no registro do Vendedor                         |
										//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ											
										cCodVend	:= (cAliasSE2)->A3_COD				// Codigo do Vendedor
			
										DBSelectArea("SA3") 			
										DBSetOrder(1)
										If DBSeek( xFilial("SA3") + cVendedor, .f. )
												RECLock( "SA3", .f. )
															SA3->A3_X_BLOQ	:= "S"
												MSUNLOCK()
										EndIf															
			
										If SELECT( cAliasSA3 ) > 0 
													DBSelectArea(cAliasSA3)
													DBCloseArea()
										EndIf
			
										//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
										//| Query para bloquear as comissoes pendentes.                                 |
										//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ											
										cQryUPD	:= ""
										cQryUPD	+= " UPDATE " + RETSqlName("SE3") + " SET E3_X_BLOQ = 'S' " 
										cQryUPD	+= " WHERE 	E3_FILIAL = '" + xFilial("SE3") + "' "
										cQryUPD	+= "		AND E3_VEND = '" + cVendedor + "' "
										cQryUPD	+= " 		AND E3_DATA = '' "
										cQryUPD	+= " 		AND D_E_L_E_T_ <> '*' "																						
								
									   	TCSQLExec( cQryUPD )
									
								EndIf
	
	           		EndIf
				
		ENDDO
				
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//| Fecha a Area de trabalho.                                    |
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If SELECT( cAliasSE2 ) > 0 
					DBSelectArea(cAliasSE2)
					DBCloseArea()
		EndIf

Return()