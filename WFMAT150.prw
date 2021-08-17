#Include "Rwmake.ch"
#Include "Protheus.ch"
#Include "TbiConn.ch"
#Include "TbiCode.ch"
#Include "Topconn.ch"
#Include "ParmType.ch"

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} WFMAT150
Reenvio de Workflow - Tela de atualização das cotações 

@type 		Function
@author 	Maurício Aureliano
@since 		28/03/2018
@version 	P12 

@obs		Baseado no fonte original "MT130WF" - Roberto Souza - 15/03/2017
@obs		Chamado: I1711-447
 
@return nil
/*/    
//-------------------------------------------------------------------------------------
User Function WFMAT150( oProcess )

	Local aCond			:= {}
	Local aFrete		:= {}
	Local aSubst		:= {}
	Local nTotal 		:= 0
	Local cNumSC8 		:= ""
	Local cFornece 		:= SC8->C8_FORNECE
	Local cLojFor 		:= SC8->C8_LOJA
	Local cEmlFor 		:= ""
	Local iFornec 		:= 0
	Local cNumSC8       := SC8->C8_NUM
	Local aProcs        := {}
	Local aImg			:= {"logo1.png","fundo2.png"}
	Local cAssunt 		:= "Solicitacao de cotacao de Compras nº " + cNumSC8
	Local cCodSts 		:= "100100"
	Local cDesc   		:= "Iniciando processo..."
	Local cHostWF   	:= GetMv("FS_WFURL01", .F.,"http://187.94.60.130:12137/wf")	//URL configurado no ini para WF Link.
	Local cArqHtm 		:= "\workflow\e_cotacao.htm"
	//Local lWF           := ( GetMv("FS_WFSC8", .F.,"N") == "S" )
	Local cMsgEnvio     := ""
		
	If (Aviso("Cotação de Compras","Deseja enviar o Workflow de cotação para os fornecedores selecionados?",{"Sim","Não"},2) <> 2	)
	
				
		DbSelectArea("SC8")
		DbSetOrder(1)
		DbSeek( xFilial("SC8")+cNumSC8+cFornece+cLojFor )
	            
		PswOrder(1)
		If PswSeek(cUsuario,.t.)
			aInfo    := PswRet(1)
			_cUser   := aInfo[1,2]
		EndIf
	    
		cMailCom := Alltrim(UsrRetMail(__cUserId)) // cpd3@ourolux.com.br //
	
		While (!Eof() .And. xFilial("SC8")+cNumSC8+cFornece+cLojFor == SC8->C8_FILIAL+SC8->C8_NUM+SC8->C8_FORNECE+SC8->C8_LOJA)
	
		//If !Empty(SC8->C8_XWFID)
		//	SC8->(DbSkip())
		//Else
				
			cNumSC8		:= SC8->C8_NUM
			cFornece 	:= SC8->C8_FORNECE
			cLojFor    	:= SC8->C8_LOJA
		
			DbSelectArea("SA2")
			DbSetOrder(1)
			DbSeek( xFilial("SA2") + cFornece + cLojFor )
		
			cEmlFor := cMailCom // "cpd3@ourolux.com.br;badmaum@gmail.com" // AllTrim(SA2->A2_EMAIL)

			If Alltrim(cEmlFor) <> ""
		
				oProcess := TWFProcess():New( "000002", "Cotação de Preços" )
				oProcess:NewTask( "Fluxo de Compras", cArqHtm )
				oProcess:cSubject 	:= cAssunt + " - Fornecedor: "+cFornece+"/"+cLojFor
				oProcess:cTo      	:= "WFAPROV"
				oProcess:bReturn    := "U_MT130WFR(1)"
		
				oHtml    := oProcess:oHTML
		            
				oHtml:ValByName( "A2_NOME"   , SA2->A2_NOME  +"[ "+cFornece +"-"+ cLojFor+" ]" )
				oHtml:ValByName( "A2_END"    , SA2->A2_END    )
				oHtml:ValByName( "A2_MUN"    , SA2->A2_MUN    )
				oHtml:ValByName( "A2_BAIRRO" , SA2->A2_BAIRRO )
				oHtml:ValByName( "A2_TEL"    , SA2->A2_TEL    )
				oHtml:ValByName( "A2_FAX"    , SA2->A2_FAX    )
		
				/*** Preenche os dados do cabecalho ***/
				oHtml:ValByName( "C8_FORNECE", SC8->C8_FORNECE )
				oHtml:ValByName( "C8_LOJA" 	 , SC8->C8_LOJA    )
				oHtml:ValByName( "C8_CONTATO", SC8->C8_CONTATO )
				oHtml:ValByName( "C8_NUM"    , SC8->C8_NUM     )
				oHtml:ValByName( "C8_VALIDA" , SC8->C8_VALIDA  )
		             
				oHtml:ValByName( "EndEnt",GetEndFil(SC8->C8_FILENT) )
		          
					// Carrega condições de pagamento
				aCond := GetCondPag( SA2->A2_COND )
		
				While SC8->(!Eof()) .And. xFilial("SC8")+cNumSC8 == SC8->C8_FILIAL+SC8->C8_NUM ;
						.And. cFornece == SC8->C8_FORNECE .And. cLojFor == SC8->C8_LOJA
		
					DbSelectArea("SB1")
					DbSetOrder(1)
					DbSeek(xFilial("SB1") + SC8->C8_PRODUTO )
							
					aAdd( (oHtml:ValByName( "it.item"    )), SC8->C8_ITEM    )
					aAdd( (oHtml:ValByName( "it.produto" )), SC8->C8_PRODUTO )
					aAdd( (oHtml:ValByName( "it.descri"  )), NoAcento(AnsiToOem(AllTrim(SB1->B1_DESC)))     )  //SB1->B1_DESC
					aAdd( (oHtml:ValByName( "it.quant"   )), AllTrim(Transform( SC8->C8_QUANT,"@E 9999999.99" )) )
					aAdd( (oHtml:ValByName( "it.um"      )), SC8->C8_UM      )
					aAdd( (oHtml:ValByName( "it.dtmax"   )), SC8->C8_VALIDA  )
					aAdd( (oHtml:ValByName( "it.preco"   )), Alltrim(Transform( 0.00,'@E 999,999.99' ) ) )
					aAdd( (oHtml:ValByName( "it.valor"   )), Alltrim(Transform( 0.00,'@E 999,999.99' ) ) )
					aAdd( (oHtml:ValByName( "it.prazo"   )), "00")
					aAdd( (oHtml:ValByName( "it.ipi"     )), "00" )
					aAdd( (oHtml:ValByName( "it.icms"    )), "00" )
					aAdd( (oHtml:ValByName( "it.icmsst"  )), Alltrim(Transform( 0.00,'@E 9,999,999.99' ) ) )
					aAdd( (oHtml:ValByName( "it.obs"     )), " ")
						
					SC8->(DbSkip())
				EndDo
					
				oHtml:ValByName( "Pagamento", aCond    )
				oHtml:ValByName( "Frete"    , {"CIF","FOB"}   )
				oHtml:ValByName( "valfre"   , AllTrim(Transform( 0 ,'@E 999,999.99' ) )	)
		
				cMailID := oProcess:Start()
				cMainId := oProcess:fProcessID

				RastreiaWF(oProcess:fProcessID+'.'+oProcess:fTaskID,"000002",'10001',"Email Enviado Para o Fornecedor:"+SA2->A2_NOME,RetCodUsr())
	            
				cCodSts := "10001"
				cDesc   := "Enviando solicitacao para: "
				CONOUT( cCodSts + "-" + cDesc )
					
				cHtmlMod := "\workflow\wflink_out.htm"
				cMainTxt := "Solicitamos de V. Sas, cota&ccedil;&atilde;o de pre&ccedil;os para os produtos discriminados no processo a seguir:"
					
				oProcess:NewTask(cAssunt,cHtmlMod)
//					oProcess:cSubject := cAssunt + " - " + oProcess:fProcessID + "." + oProcess:fTaskID
				oProcess:cSubject := cAssunt + " - Ourolux"
				oProcess:cTo := cEmlFor
				oProcess:bReturn := "U_MT130WFR(1)"
					
				oProcess:ohtml:ValByName("main_txt",cMainTxt )
				oProcess:ohtml:ValByName("proc_link",cHostWF + cMailID + ".htm")
				
				oProcess:Start()
	
				lSend := WFSendMail()
		
				SetSC8WF( cNumSC8, cFornece, cLojFor, cMailCom, cMainId, cMailID, '10001' )
					
				DbSelectArea("SC8")

				AADD(aProcs,cMailID)
				cMsgEnvio += cFornece+"-"+cLojFor+" - "+SA2->A2_NOME+" - "+cEmlFor+chr(13)+chr(10)
			Else
				SetSC8WF( cNumSC8, cFornece, cLojFor, cMailCom, "WF9999", "nolink", '10005' )
			Endif
		//EndIf
		Enddo
		If !Empty(cMsgEnvio)
			Aviso("Envio Workflow","Workflow enviado:"+chr(13)+chr(10)+cMsgEnvio,{"Ok"},3)
		EndIf
		
	Else
		Conout("[WFMAT150] Off")
	EndIf
	        
Return


//-------------------------------------------------------------------------------------
/*/{Protheus.doc} GetCondPag
Lista as condicoes para enviar ao 

@type 		function
@author 	Roberto Souza
@since 		15/03/2017
@version 	P11 
 
@return nil
/*/    
//-------------------------------------------------------------------------------------
Static Function GetCondPag( cCondPad )
	Local aRet := {}
	Local aArea:= GetArea()

	DbSelectArea("SE4")
	DbSetOrder(1)
			
	If !Empty( cCondPad )
		If DbSeek(xFilial("SE4") + cCondPad )
			aAdd( aRet, SE4->E4_CODIGO + " - " + SE4->E4_DESCRI )
		Endif
	EndIf
		                
	SE4->(DbGoTop())
	
	While !Eof() .And. SE4->E4_FILIAL == xFilial("SE4")
		If SE4->E4_UTILIZA $ "P/A/ "
			aAdd( aRet, SE4->E4_CODIGO + " - " + SE4->E4_DESCRI )
		EndIf
		SE4->(DbSkip())
	Enddo
                    
	RestArea( aArea )

Return( aRet )


//-------------------------------------------------------------------------------------
/*/{Protheus.doc} RECEBIDO
Ponto de entrada na geração de cotacoes para gerar Workflow

@type 		function
@author 	Roberto Souza
@since 		15/03/2017
@version 	P11 
 
@return nil
/*/    
//-------------------------------------------------------------------------------------
Static Function Recebido( oProcess, cEmailComp )
	Local cArqHtm 		:= "\workflow\respondido.htm"
	                                       
	cNumSC8     := oProcess:oHtml:RetByName("C8_NUM"     )
	cFornece 	:= oProcess:oHtml:RetByName("C8_FORNECE" )
	cLojFor    	:= oProcess:oHtml:RetByName("C8_LOJA"    )
	cNomFor     := oProcess:oHtml:RetByName("A2_NOME"    )

	oProcess:Finish()

	oResp := TWFProcess():New( "000002", "Cotação de Preços" )
	oResp:NewTask( "Resposta de cotacao", cArqHtm )
	oResp:cSubject 	:= "Resposta da cotacao "+cNumSC8+" do Fornecedor: "+cFornece+"-"+cLojFor
	oResp:cTo      	:= "WFAPROV"
	oResp:bReturn   := ""

	oHtml    := oResp:oHTML


	cUser := Subs(cUsuario,7,15)
	oResp:ClientName(cUser)
	oResp:cTo      := cEmailComp
	oResp:cCC      := ""
	oResp:cBCC     := ""
	oResp:cSubject := "Resposta da cotacao "+cNumSC8+" do Fornecedor: "+cFornece+"-"+cLojFor
	
	oResp:cBody    := ""
	oResp:bReturn  := ""
	oResp:bTimeOut := ""

	oResp:oHtml:ValByName( "cmsg"   , "A cotação   "+cNumSC8+" do Fornecedor : "+AllTrim(cNomFor)+" foi respondida." )
	
	oResp:Start()
	oResp:Finish()
	
	WFSendMail()

return

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} SetSC8WF
Atualiza os Status das Cotacoes

@type 		function
@author 	Roberto Souza
@since 		15/03/2017
@version 	P11 
 
@return nRet
/*/    
//-------------------------------------------------------------------------------------
Static Function SetSC8WF( cNumSC8, cFornece, cLojFor, cMailCom, cMainId , cWfProc, cWFstat )
	Local cQry := ""
	Local nRet := 0
	
	cQry += "UPDATE "+RetSqlName("SC8")
	cQry += " SET C8_XWFMAIL='"+AllTrim(cMailCom)+"', "
	cQry += " C8_XWFID='"+Alltrim(cMainId)+"',"
	cQry += " C8_XWFPROC='"+Alltrim(cWfProc)+"',"
	cQry += " C8_XWFCO='"+Alltrim(cWFstat)+"' "
	cQry += " WHERE C8_FILIAL='"+xFilial("SC8")+"'"
	cQry += " AND C8_NUM ='"+AllTrim(cNumSC8)+"'"
	cQry += " AND C8_FORNECE ='"+AllTrim(cFornece)+"'"
	cQry += " AND C8_LOJA ='"+AllTrim(cLojFor)+"'"
	cQry += " AND D_E_L_E_T_ = ' '"

	nRet := TcSqlExec( cQry )

Return( nRet )
	
	
//-------------------------------------------------------------------------------------
/*/{Protheus.doc} RetHtmVal
Trata retornos numericos dos formularios

@type 		function
@author 	Roberto Souza
@since 		15/03/2017
@version 	P11 
 
@return 	nRet
/*/    
//-------------------------------------------------------------------------------------
Static Function RetHtmVal( cValHtm )
	Local nRet := 0
	
	cValHtm := StrTran(cValHtm,",",".")
	nRet := Val( cValHtm )

Return( nRet )

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} GetEndFil
Retorna endereço da filial utilizada.

@type 		function
@author 	Roberto Souza
@since 		15/03/2017
@version 	P11 
 
@return 	cRet
/*/    
//-------------------------------------------------------------------------------------
Static Function GetEndFil( cCodFil )
	Local aArea := SM0->(GetArea())
	Local cRet 	:= ""

	DbSelectArea("SM0")
	If DbSeek(cEmpAnt+cCodFil)
		cRet := AllTrim(SM0->M0_ENDENT)+" - "+ AllTrim(SM0->M0_BAIRENT) + " - "+AllTrim(SM0->M0_CIDENT)+"/"+AllTrim(SM0->M0_ESTENT)
	EndIf

	DbSeek(cEmpAnt+cFilAnt)
	RestArea(aArea)

Return( cRet )