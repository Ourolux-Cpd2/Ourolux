#INCLUDE "PROTHEUS.CH"
#include "TOPCONN.CH"
#include "TBICONN.CH"
#Include "RESTFUL.CH"
#Include "AP5MAIL.CH"
#Include "RwMake.ch"

 
#DEFINE COMP_DATE  "20200204" 

/*/
___________________________________________________________________________
|  Programa:            | Autor: ETHOSX              | Data :  22/12/20     |
|                       | MARCOS FONTANELLI          |                      |
|_______________________|____________________________|______________________|
|  Descricao | Programa roda pelo WebService para aprovar ped de compra     |
|____________|_____________________________________________________________ |
|  Uso       | OUROLUX.                                                     |
|____________|_____________________________________________________________ |
/*/

/*
{ 'CR_STATUS== "01"', 'BR_AZUL' },;   //Bloqueado p/ sistema (aguardando outros niveis)
{ 'CR_STATUS== "02"', 'DISABLE' },;   //Aguardando Liberacao do usuario
{ 'CR_STATUS== "03"', 'ENABLE'  },;   //Pedido Liberado pelo usuario
{ 'CR_STATUS== "04"', 'BR_PRETO'},;   //Pedido Bloqueado pelo usuario
{ 'CR_STATUS== "05"', 'BR_CINZA'} }   //Pedido Bloqueado por outro usuario.

// http://187.94.63.180:10611/rest/WSAPRPC/SIM/01/000001/000001/MOTIVO
*/                    

WSRESTFUL WSAPRPC DESCRIPTION "Aprova?o de Pedido Compra V2"

WSMETHOD GET  DESCRIPTION "WSAPRPC" WSSYNTAX "Parametro || /aprovado/filial/pedido/aprovador/motivo"

END WSRESTFUL
                                                 
WSMETHOD GET WSRECEIVE cCodigo WSSERVICE WSAPRPC

	::SetContentType("application/cJson")

	lEnviar := .F.

	If Len(::aURLParms) > 1

		cModulo	     := "COM"
		nModulo		 := 2
		ws_status    := ::aURLParms[1]
		ws_filial    := ::aURLParms[2]
		ws_pedido    := ::aURLParms[3]
		ws_aprovador := ::aURLParms[4]
		ws_motivo    := ::aURLParms[5]
		
		cQuery    := ""
		cDespNFa  := SuperGetMV("ES_DESNFA",.F.,"")
		lAtvEic   := SuperGetMV("ES_ATVEICD",.F.,.F.)
		cDespNNF  := SuperGetMV("ES_DESNNF",.F.,"402")
		lGerPrDI  := IF(GetNewPar("MV_EASYFDI","S")="S",.T.,.F.)//ASR - 28/09/2005 - Integração EIC x FIN
		cData 	  := dtoc(ddatabase)
		cHora 	  := TIME()
		cQryUPD	  := ""
		cSemaforo := ""
		cMENSAGEM := ""
		lSemaf	  := .F.

		conout("")
		conout("")
		conout("---------------------------------------------------------------------------")
		conout("Data: "+cData)
		conout("Hora: "+cHora)
		conout("---------------------------------------------------------------------------")
		conout("Aprovado: "+ws_status)
		conout("Filial: "+ws_filial)
		conout("Pedido: "+ws_pedido)
		conout("Aprovador: "+ws_aprovador)
		conout("Motivo: "+ws_motivo)
		conout("---------------------------------------------------------------------------")
	    
		conout("WSAPRPC - BUSCA DE PRODUTO PARA VERIFICAR SE EXECUTA SEMAFORO")
		
		cQuery := " SELECT C7_PRODUTO, C7_XHAWB FROM " + RetSqlName("SC7")
		cQuery += " WHERE C7_FILIAL = '" +ws_filial+ "' "
		cQuery += " AND C7_NUM = '" +ws_pedido+ "' "
		cQuery += " AND D_E_L_E_T_ = '' "
		
		If Select("C7XX") > 0 
			C7XX->(dbCloseArea())
		EndIf
		
		conout("WSAPRPC - Query SEMAFORO")
		conout(cQuery)

		DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery) , 'C7XX', .T., .F.)

		If C7XX->(!EOF())
			conout("WSAPRPC SEMAFORO- Produto: " + C7XX->C7_PRODUTO)
			conout("WSAPRPC SEMAFORO- Despesa: " + SubStr(Alltrim(C7XX->C7_PRODUTO),4,3))
			conout("WSAPRPC SEMAFORO- Origem: " + SubStr(Alltrim(C7XX->C7_PRODUTO),1,3))
			conout("WSAPRPC SEMAFORO- ES_DESNFA: " + cDespNFa)
			conout("WSAPRPC SEMAFORO- ES_DESNNF: " + cDespNNF)

			If SubStr(Alltrim(C7XX->C7_PRODUTO),4,3) $ cDespNFa .AND. SubStr(Alltrim(C7XX->C7_PRODUTO),1,3) == "EIC"
				If !(SubStr(Alltrim(C7XX->C7_PRODUTO),4,3) $ cDespNNF)
					cSemaforo := "U_WSAPRPC"
					If  !LockByName(cSemaforo) 
						ConOut( "U_WSAPRPC - Rotina já está em execução, aguarde finalização.")
						ProcLogAtu("ERRO","WSAPRPC - U_WSAPRPC - Rotina ja esta em execucao, aguarde finalizacao.", "" , "EICDESPESA" )
						cMENSAGEM := "Processo anterior em execucao, aguarde finalizacao"
						ws_status := "SAIR"
					else
						lSemaf := .T.
					EndIf
				EndIf
			EndIf
		EndIf

		CpoFil  := cFilAnt
		cFilAnt := ws_filial

		cQuery	:= " SELECT CR_STATUS FROM "+RetSqlName("SCR")+" "
		cQuery  += "  WHERE CR_FILIAL = '"+alltrim(ws_filial)+"' "
		cQuery  += "    AND CR_NUM = '"+alltrim(ws_pedido)+"' "
		cQuery  += "    AND CR_USER = '"+alltrim(ws_aprovador)+"' "
		cQuery  += "    AND D_E_L_E_T_ = '' "
		TcQuery cQuery New Alias "TMP"
		TMP->(dbGoTop())
		cCR_STATUS := TMP->CR_STATUS
		TMP->(DbCloseArea())
	
		if alltrim(ws_status) == 'SIM'
	
			conout("retornou 'SIM'")
			conout("---------------------------------------------------------------------------")
	
			if cCR_STATUS == '02'
				/*
				???????????????????????????????????????
				???????????????????????????????????????
				??un?o    ?MaAlcDoc ?Autor ?Aline Correa do Vale  ?Data ?7.08.2001??
				???????????????????????????????????????
				??escri?o ?Controla a alcada dos documentos (SCS-Saldos/SCR-Bloqueios)??
				???????????????????????????????????????
				??intaxe   ?MaAlcDoc(ExpA1,ExpD1,ExpN1,ExpC1,ExpL1)               	  ??
				???????????????????????????????????????
				??arametros?ExpA1 = Array com informacoes do documento                 ??
				??         ?      [1] Numero do documento                              ??
				??         ?      [2] Tipo de Documento                                ??
				??         ?      [3] Valor do Documento                               ??
				??         ?      [4] Codigo do Aprovador                              ??
				??         ?      [5] Codigo do Usuario                                ??
				??         ?      [6] Grupo do Aprovador                               ??
				??         ?      [7] Aprovador Superior                               ??
				??         ?      [8] Moeda do Documento                               ??
				??         ?      [9] Taxa da Moeda                                    ??
				??         ?     [10] Data de Emissao do Documento                     ??
				??         ?     [11] Grupo de Compras                                 ??
				??         ?     [12] Aprovador Original                               ??
				??         ?ExpD1 = Data de referencia para o saldo                    ??
				??         ?ExpN1 = Operacao a ser executada                           ??
				??         ?      1 = Inclusao do documento                            ??
				??         ?      2 = Transferencia para Superior                      ??
				??         ?      3 = Exclusao do documento                            ??
				??         ?      4 = Aprovacao do documento                           ??
				??         ?      5 = Estorno da Aprovacao                             ??
				??         ?      6 = Bloqueio Manual da Aprovacao                     ??
				??         ?ExpC1 = Chave(Alternativa) do SF1 para exclusao SCR        ??
				??         ?ExpL1 = Eliminacao de Residuos                             ??
				???????????????????????????????????????
				??Uso      ?Generico                                                   ??
				???????????????????????????????????????
				???????????????????????????????????????
				*/
				SCR->(dbSetOrder(2)) // CR_FILIAL+CR_TIPO+CR_NUM+CR_USER
				if SCR->(dbSeek(alltrim(ws_filial)+"PC"+alltrim(ws_pedido)+Space(TamSx3("CR_NUM")[1]-Len(alltrim(ws_pedido)))+alltrim(ws_aprovador)))
			   
					lLiberou := MaAlcDoc({SCR->CR_NUM,SCR->CR_TIPO,SCR->CR_TOTAL,SCR->CR_APROV,,,,,,,},dDataBase,4)
					// Precisa verificar porque esta retornando .F.
			    
					conout("Status")
					conout(SCR->CR_NUM + " - Status: " + SCR->CR_STATUS)
					conout("lLiberou:")
					conout(lLiberou)
					conout("---------------------------------------------------------------------------")
			    	
			    	// MOA - 19/07/2019 - 17:26hs
			    	// Verificar se existe mais de uma aprovador n?el "02" e preencher todos caso um deles j?tenha aprovado!
					If SCR->CR_STATUS == "03"
					
						cQryUPD	+= " UPDATE " + RETSqlName("SCR") + " SET CR_STATUS = '03' "
						cQryUPD	+= " ,CR_DATALIB =  " + DTOS(SCR->CR_DATALIB)
						cQryUPD	+= " ,CR_USERLIB =  '" + alltrim(SCR->CR_USERLIB)  + "' "
						cQryUPD	+= " ,CR_LIBAPRO =  '" + alltrim(ws_aprovador)     + "' "
						cQryUPD	+= " WHERE 	CR_FILIAL    = '" + alltrim(ws_filial) + "' "
						cQryUPD	+= "		AND CR_NUM 	 = '" + alltrim(ws_pedido) + "' "
						cQryUPD	+= "		AND CR_NIVEL = '02' "
						cQryUPD	+= " 		AND CR_STATUS = '02' "
						cQryUPD	+= " 		AND D_E_L_E_T_ <> '*' "
										
						conout("cQryUPD")
						conout(cQryUPD)
						conout("---------------------------------------------------------------------------")
					
						TCSQLExec( cQryUPD )
					
						lLiberou := .T.
						conout("lLiberou:")
						conout(lLiberou)
					
					EndIf
					//Fim MOA - 19/07/2019
					
					if lLiberou
						
						dbSelectArea("SC7")
						SC7->(dbSetOrder(1))
						SC7->(dbSeek(alltrim(ws_filial)+alltrim(ws_pedido)))
						conout("alltrim(ws_filial)+alltrim(ws_pedido):" + alltrim(ws_filial)+alltrim(ws_pedido))
						If SuperGetMv("MV_EASY")=="S" .And. SC7->(FieldPos("C7_PO_EIC")) <> 0 .And. !Empty(SC7->C7_PO_EIC)
							conout("MV_EASY")
							dbSelectArea("SW2")
							SW2->(dbSetOrder(1))
							If SW2->(MsSeek(xFilial("SW2")+SC7->C7_PO_EIC)) .And. !Empty(SW2->W2_CONAPRO) 
							//If SW2->(MsSeek(xFilial("SW2")+SC7->C7_PO_EIC)) .And. SW2->(FieldPos("W2_CONAPRO")) > 0 .And. !Empty(SW2->W2_CONAPRO)
							//SW2->(FieldPos("W2_CONAPRO")) esta retornando 0
								Reclock("SW2",.F.)
								SW2->W2_CONAPRO := "L"
								SW2->(MsUnlock("SW2"))
								conout("SW2->W2_CONAPRO := L")
							EndIf
							
							//conout("SW2->(MsSeek(xFilial(SW2)+SC7->C7_PO_EIC))")
							//conout(SW2->(MsSeek(xFilial("SW2")+SC7->C7_PO_EIC)))
							//conout("xFilial(SW2)") 
							//conout(xFilial("SW2"))
							//conout("SC7->C7_PO_EIC") 
							//conout(SC7->C7_PO_EIC)
							//conout("SW2->(FieldPos(W2_CONAPRO))") 
							//conout(SW2->(FieldPos(W2_CONAPRO)))
							//conout("!Empty(SW2->W2_CONAPRO)") 
							//conout(!Empty(SW2->W2_CONAPRO))
							//conout("SW2->W2_CONAPRO") 
							//conout(SW2->W2_CONAPRO) 
							//conout("SW2->W2_po_num") 
							//conout(SW2->W2_PO_NUM)
						EndIf
								    
						dbSelectArea("SC7")
						SC7->(dbSetOrder(1))
						SC7->(dbSeek(alltrim(ws_filial)+alltrim(ws_pedido)))
						While !Eof() .And. SC7->C7_FILIAL+SC7->C7_NUM == alltrim(ws_filial)+alltrim(ws_pedido)
							Reclock("SC7",.F.)
							SC7->C7_CONAPRO := "L"
							MsUnlock()
							dbSkip()
						EndDo

						cMENSAGEM := "Liberado"
						lEnviar := .T.

						If lAtvEic
							aFonte := GetSrcArray("NFDESAUT.PRW")
							If Empty(aFonte)
								conout("WSAPRPC - Rotina NFDESAUT nao compilada")	
								ProcLogAtu("ERRO","WSAPRPC - Rotina NFDESAUT nao compilada", "" , "EICDESPESA" )
								If lSemaf
									UnlockByName(cSemaforo)
								EndIf
							Else
								conout("WSAPRPC - Rotina EIC - Ativada")
								conout("WSAPRPC - Inicio do desenvolvimento para geracao de despesa automatica")
								cQuery := " SELECT C7_PRODUTO, C7_XHAWB FROM " + RetSqlName("SC7")
								cQuery += " WHERE C7_FILIAL = '" +ws_filial+ "' "
								cQuery += " AND C7_NUM = '" +ws_pedido+ "' "
								cQuery += " AND D_E_L_E_T_ = '' "
								
								If Select("C7XX") > 0 
									C7XX->(dbCloseArea())
								EndIf
								
								conout("WSAPRPC - Query busca pedido")
								conout(cQuery)

								DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery) , 'C7XX', .T., .F.)

								If C7XX->(!EOF())
									conout("WSAPRPC - Produto: " + C7XX->C7_PRODUTO)
									conout("WSAPRPC - Despesa: " + SubStr(Alltrim(C7XX->C7_PRODUTO),4,3))
									conout("WSAPRPC - Origem: " + SubStr(Alltrim(C7XX->C7_PRODUTO),1,3))
									conout("WSAPRPC - ES_DESNFA: " + cDespNFa)
									If SubStr(Alltrim(C7XX->C7_PRODUTO),4,3) $ cDespNFa .AND. SubStr(Alltrim(C7XX->C7_PRODUTO),1,3) == "EIC"
										If !(SubStr(Alltrim(C7XX->C7_PRODUTO),4,3) $ cDespNNF)
											conout("WSAPRPC - Chamando rotina NFDESAUT")
											U_NFDESAUT(ws_filial,ws_pedido,.T.)

											EICFI400("POS_GRV_DESP")
											axFl2DelWork:={}
											
											conout("WSAPRPC - Inclusão dos PRE")
											cControle := "Inclusao"
											Processa({|| AVPOS_DI(C7XX->C7_XHAWB,lGerPrDI,,.T.) })

											U_xdelPRE(C7XX->C7_XHAWB)
										Else
											conout("WSAPRPC - Despesa esta no parametro para nao gerar NF automaticamente")
											conout("WSAPRPC - ES_DESNNF: " + cDespNNF)
											If lSemaf
												UnlockByName(cSemaforo)
											EndIf
										EndIf
									Else
										conout("WSAPRPC - IF para chamada do NFDESAUT retornou .F.")
										ProcLogAtu("ERRO","WSAPRPC - Produto não esta na regra para gerar NF", "Filial: " +ws_filial+ " Pedido: " +ws_pedido , "EICDESPESA" )
										If lSemaf
											UnlockByName(cSemaforo)
										EndIf
									EndIf
								Else
									conout("WSAPRPC - Nao ha dados no resultado da query")
									ProcLogAtu("ERRO","WSAPRPC - Pedido nao encontrado", "Filial: " +ws_filial+ " Pedido: " +ws_pedido , "EICDESPESA" )
									If lSemaf
										UnlockByName(cSemaforo)
									EndIf
								EndIf
								If lSemaf
									UnlockByName(cSemaforo)
								EndIf
							EndIf
							If lSemaf
								UnlockByName(cSemaforo)
							EndIf
						EndIf
					else
						cMENSAGEM := "Pedido não Liberado"
					endif
	
	        
				else

					cMENSAGEM := "Pedido Excluido pelo comprador!!!"

				endif
			

			else

				if (cCR_STATUS=='01')
					cMENSAGEM := "Bloqueado pelo sistema (aguardando outros niveis)"
				endif
				if (cCR_STATUS=='02')
					cMENSAGEM := "Aguardando Liberacao do usuario"
				endif
				if (cCR_STATUS=='03')
					cMENSAGEM := "Pedido ja Liberado anteriormente pelo usuario"
				endif
				if (cCR_STATUS=='05')
					cMENSAGEM := "Pedido Bloqueado por outro usuario"
				endif
				if (cCR_STATUS=='04')
					cMENSAGEM := "Pedido Bloqueado pelo usuario"
				endif
				if Empty(cCR_STATUS)
					cMENSAGEM := "Pedido Excluido pelo comprador"
				endif
		
			endif
			
		endif
	
		if alltrim(ws_status) == 'NAO'
	
			conout("retornou 'NAO'")
			conout("---------------------------------------------------------------------------")
	
	
			if cCR_STATUS == '02'
	
				/*
				???????????????????????????????????????
				???????????????????????????????????????
				??un?o    ?MaAlcDoc ?Autor ?Aline Correa do Vale  ?Data ?7.08.2001??
				???????????????????????????????????????
				??escri?o ?Controla a alcada dos documentos (SCS-Saldos/SCR-Bloqueios)??
				???????????????????????????????????????
				??intaxe   ?MaAlcDoc(ExpA1,ExpD1,ExpN1,ExpC1,ExpL1)               	  ??
				???????????????????????????????????????
				??arametros?ExpA1 = Array com informacoes do documento                 ??
				??         ?      [1] Numero do documento                              ??
				??         ?      [2] Tipo de Documento                                ??
				??         ?      [3] Valor do Documento                               ??
				??         ?      [4] Codigo do Aprovador                              ??
				??         ?      [5] Codigo do Usuario                                ??
				??         ?      [6] Grupo do Aprovador                               ??
				??         ?      [7] Aprovador Superior                               ??
				??         ?      [8] Moeda do Documento                               ??
				??         ?      [9] Taxa da Moeda                                    ??
				??         ?     [10] Data de Emissao do Documento                     ??
				??         ?     [11] Grupo de Compras                                 ??
				??         ?     [12] Aprovador Original                               ??
				??         ?ExpD1 = Data de referencia para o saldo                    ??
				??         ?ExpN1 = Operacao a ser executada                           ??
				??         ?      1 = Inclusao do documento                            ??
				??         ?      2 = Transferencia para Superior                      ??
				??         ?      3 = Exclusao do documento                            ??
				??         ?      4 = Aprovacao do documento                           ??
				??         ?      5 = Estorno da Aprovacao                             ??
				??         ?      6 = Bloqueio Manual da Aprovacao                     ??
				??         ?ExpC1 = Chave(Alternativa) do SF1 para exclusao SCR        ??
				??         ?ExpL1 = Eliminacao de Residuos                             ??
				???????????????????????????????????????
				??Uso      ?Generico                                                   ??
				???????????????????????????????????????
				???????????????????????????????????????
				*/
				SCR->(dbSetOrder(2)) // CR_FILIAL+CR_TIPO+CR_NUM+CR_USER
				if SCR->(dbSeek(alltrim(ws_filial)+"PC"+alltrim(ws_pedido)+Space(TamSx3("CR_NUM")[1]-Len(alltrim(ws_pedido)))+alltrim(ws_aprovador)))
					MaAlcDoc({SCR->CR_NUM,SCR->CR_TIPO,SCR->CR_TOTAL,SCR->CR_APROV,,,,,,,Alltrim(ws_motivo)},dDataBase,6)
				endif

				If SCR->CR_STATUS == "04"
					
					cQryUPD	+= " UPDATE " + RETSqlName("SCR") + " SET CR_STATUS = '05' "
					cQryUPD	+= " ,CR_DATALIB =  " + DTOS(SCR->CR_DATALIB)
					cQryUPD	+= " ,CR_USERLIB =  '" + alltrim(SCR->CR_USERLIB)  + "' "
					cQryUPD	+= " ,CR_LIBAPRO =  '" + alltrim(ws_aprovador)     + "' "
					cQryUPD	+= " WHERE 	CR_FILIAL    = '" + alltrim(ws_filial) + "' "
					cQryUPD	+= "		AND CR_NUM 	 = '" + alltrim(ws_pedido) + "' "
					cQryUPD	+= "		AND CR_NIVEL = '02' "
					cQryUPD	+= " 		AND CR_STATUS = '02' "
					cQryUPD	+= " 		AND D_E_L_E_T_ <> '*' "
									
					conout("cQryUPD")
					conout(cQryUPD)
					conout("---------------------------------------------------------------------------")
				
					TCSQLExec( cQryUPD )
				
					lLiberou := .T.
					conout("Bloqueado:")
					conout(lLiberou)
				
				EndIf

				cMENSAGEM := "Bloqueado"
				lEnviar := .T.

			else
	                        
				if (cCR_STATUS=='01')
					cMENSAGEM := "Bloqueado pelo sistema (aguardando outros niveis)"
				endif
				if (cCR_STATUS=='02')
					cMENSAGEM := "Aguardando Liberacao do usuario"
				endif
				if (cCR_STATUS=='03')
					cMENSAGEM := "Pedido ja Liberado anteriormente pelo usuario"
				endif
				if (cCR_STATUS=='05')
					cMENSAGEM := "Pedido Bloqueado por outro usuario"
				endif
				if (cCR_STATUS=='04')
					cMENSAGEM := "Pedido Bloqueado pelo usuario"
				endif
				if Empty(cCR_STATUS)
					cMENSAGEM := "Pedido Excluido pelo comprador"
				endif
	
			endif
		
		endif

		If lSemaf
			UnlockByName(cSemaforo)
		EndIf

		conout("Mensagem: "+cMENSAGEM)
		conout("---------------------------------------------------------------------------")
	
		cRETORNO := '{"status":"ok","msg":"'+cMENSAGEM+'","pedido":"'+ws_pedido+'"}'
		::SetResponse( cRETORNO )

		if lEnviar
		   U_WFMAIL(ws_status, ws_filial, ws_pedido, ws_aprovador, ws_motivo)
		endif

	else

		conout("Mensagem: Chamada sem parametros para processamento")
		conout("---------------------------------------------------------------------------")

		cRETORNO := '{"status":"sem parametros","msg":"","pedido":""}'
		::SetResponse( cRETORNO )
                        
	endif
 
	cFilAnt := CpoFil

Return .T.
                    

User Function WFMAIL(_aprovado, _filial, _pedido, _aprovador, _motivo)   

	cData := dtoc(ddatabase)
	cHora := TIME()

	lSmtpSSL  := GetMV("MV_RELSSL")
	lSmtpTLS  := GetMV("MV_RELTLS")
	lAuteSMTP := GetNewPar("MV_RELAUTH",.F.)
	cServSMTP := GetMV("MV_RELSERV")
	cUserSMTP := GetMV("MV_RELACNT")
	cPassSMTP := GetMV("MV_RELPSW")
	cUserFrom := GetMV("MV_RELFROM")                     
                                                                                                                                
    cAssunto := "Status do Pedido de Compra: "+_pedido
     
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

	dbSelectArea("SC7")
	SC7->(dbSetOrder(1))
	SC7->(dbSeek(alltrim(_filial)+alltrim(_pedido)))

	PswOrder(1)
	PswSeek(SC7->C7_USER,.T.)
	aUsuario := PswRet(1)

    cNome := UPPER(AllTrim(aUsuario[1,4]))
    cEmail := LOWER(AllTrim(aUsuario[1,14]))
    
    cPara:= cEmail

	conout("Nome Aprovadcor: " + cNome)
	conout("eMail Aprovadcor: " + cEmail)
    
    cMensagem := ' <p align="center"><font face="arial" color="#0000FF" size="4"><b>Mensagem Eletronica - WorkFlow</b></font></p> '
	cMensagem += ' <p align="left">Prezado, <strong>'+ cNome +'</strong></p> '

	if alltrim(_aprovado) == 'SIM' 
		cMensagem += ' <p align="left">Pedido: '+ _pedido +' Liberado!</p> '
	else
		cMensagem += ' <p align="left">Pedido: '+ _pedido +' Bloqueado!</p> '
		cMensagem += ' <p align="left">Motivo: '+ _motivo +'</p> '
	endif
	cMensagem += ' <p align="left">Data do Envio: <strong>' + cData + '.</strong></p> '
	cMensagem += ' <p align="left">Hora: <strong>' + cHora + '.</strong></p> ' 
    cMensagem += ' </body> '
	
	// cPara:= "marcosaureliofontanelli@gmail.com; wrahal@ourolux.com.br"

	SEND MAIL FROM cUserFrom TO cPara CC "" SUBJECT cAssunto BODY cMensagem RESULT lResult  // ATTACHMENT cAnexo1 

	If !lResult
	    GET MAIL ERROR cError
   	    conout('Erro de Envio de e-mail: '+cError)
	else

		conout('eMail enviado!')
	
	EndIf

	DISCONNECT SMTP SERVER

Return .T.


