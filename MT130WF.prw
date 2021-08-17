#include "rwmake.ch"        
#include "protheus.ch"        
#include "TbiConn.ch"
#include "TbiCode.ch"
#Include "Topconn.ch"   
#INCLUDE "ParmType.ch"


//-------------------------------------------------------------------------------------
/*/{Protheus.doc} MT130WF
Ponto de entrada na geração de cotacoes para gerar Workflow

@type 		function
@author 	Roberto Souza
@since 		15/03/2017
@version 	P11 
 
@return nil
/*/    
//-------------------------------------------------------------------------------------
User Function MT130WF( oProcess )

 	Local aCond			:= {}
	Local aFrete		:= {}
	Local aSubst		:= {}
	Local nTotal 		:= 0
	Local cNumSC8 		:= ""
	Local cFornece 		:= ""
	Local cLojFor 		:= ""
	Local cEmlFor 		:= ""
	Local iFornec 		:= 0
	Local cNumSC8       := ParamIXB[1]
	Local aProcs        := {}
	Local aImg			:= {"logo1.png","fundo2.png"}
	Local cAssunt 		:= "Solicitacao de cotacao de Compras nº " + cNumSC8
	Local cCodSts 		:= "100100"
	Local cDesc   		:= "Iniciando processo..."
	Local cHostWF   	:= GetMv("FS_WFURL01", .F.,"http://187.94.60.130:12137/wf")	//URL configurado no ini para WF Link.
	Local cArqHtm 		:= "\workflow\e_cotacao.htm"
	Local lWF           := ( GetMv("FS_WFSC8", .F.,"N") == "S" )
    Local cMsgEnvio     := ""
//	If lWF .And. MsgYesNo("Deseja enviar o Workflow de cotação para os fornecedores selecionados?")	
	If lWF .And. (Aviso("Cotação de Compras","Deseja enviar o Workflow de cotação para os fornecedores selecionados?",{"Sim","Não"},2) <> 2	)
			
		DbSelectArea("SC8")
		DbSetOrder(1)
		DbSeek( xFilial("SC8")+cNumSC8 )
	            
	    PswOrder(1)
		If PswSeek(cUsuario,.t.)
	    	aInfo    := PswRet(1)   
	        _cUser   := aInfo[1,2]
	 	EndIf
	    
		cMailCom := Alltrim(UsrRetMail(__cUserId)) //"cpd3@ourolux.com.br" // 
	
		While (!Eof() .And. xFilial("SC8")+cNumSC8 == SC8->C8_FILIAL+SC8->C8_NUM)
	
			If !Empty(SC8->C8_XWFID)
				SC8->(DbSkip())
			Else
				
				cNumSC8		:= SC8->C8_NUM       
		        cFornece 	:= SC8->C8_FORNECE
		        cLojFor    	:= SC8->C8_LOJA
		
				DbSelectArea("SA2")
				DbSetOrder(1)
				DbSeek( xFilial("SA2") + cFornece + cLojFor )
		
		        cEmlFor :=  AllTrim(SA2->A2_EMAIL) //"cpd3@ourolux.com.br" //

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
			EndIf			    
		Enddo
		If !Empty(cMsgEnvio)
			Aviso("Envio Workflow","Workflow enviado:"+chr(13)+chr(10)+cMsgEnvio,{"Ok"},3)		
		EndIf
		
	Else
		Conout("[MT130WF] Off")	
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
/*/{Protheus.doc} MT130WFR
Faz a gravacao no retorno do workflow

@type 		function
@author 	Roberto Souza
@since 		15/03/2017
@version 	P11 
 
@return nil
/*/    
//-------------------------------------------------------------------------------------
User Function MT130WFR( AOpcao, oProcess )
	Local aCab   :={}
	Local aItem  := {}
	Local nUsado := 0
	Local aRelImp := MaFisRelImp("MT150",{"SC8"})
	Local cDirWF  := StrTran(oProcess:OWF:CMESSENGERDIR+"\wfaprov\","\\","\")
	Local cDirHist:= StrTran(cDirWF+"\hist\","\\","\")
	If ValType(aOpcao) == "A"
		aOpcao := aOpcao[1]
	Endif
	If aOpcao == NIL
		aOpcao := 0
	EndIf
	
	If aOpcao == 1
		cNumSC8     := oProcess:oHtml:RetByName("C8_NUM"     )
		cFornece 	:= oProcess:oHtml:RetByName("C8_FORNECE" )
		cLojFor    	:= oProcess:oHtml:RetByName("C8_LOJA"    )
	Endif
	
	DbSelectArea("SC8")
	DbSetOrder(1)
	DbSeek( xFilial("SC8") + Padr(cNumSC8,6) + Padr(cFornece,6) + cLojFor )
	
	RastreiaWF(oProcess:fProcessID+'.'+oProcess:fTaskID,"000002",'10002',"Email respondido pelo Fornecedor:"+cFornece,RetCodUsr())
	cC8_VLDESC := oProcess:oHtml:RetByName("VLDESC" )
	cC8_ALIIPI := oProcess:oHtml:RetByName("ALIIPI" )
	cC8_VALFRE := oProcess:oHtml:RetByName("VALFRE" )
	
	//verifica o frete
	If oProcess:oHtml:RetByName("Frete") = "FOB"
		cC8_RATFRE := 0
	Endif
	
	//grava no SC8
	For nInd := 1 To Len(oProcess:oHtml:RetByName("it.preco"))
		//BASE DO ICMS
		MaFisIni(Padr(cFornece,6),cLojFor,"F","N","R",aRelImp)
		MaFisIniLoad(1) 
		
		For nY := 1 To Len(aRelImp)
			MaFisLoad(aRelImp[nY][3],SC8->(FieldGet(FieldPos(aRelImp[nY][2]))),1)
		Next nY
		
		MaFisEndLoad(1)
		
		DbSelectArea("SB1")
		DbSetOrder(1)
		DbSeek( xFilial() + oProcess:oHtml:RetByName("it.produto")[nInd] )
		
		cIcm := SC8->C8_PICM
		
		cC8_ITEM := oProcess:oHtml:RetByName("it.item")[nInd]
		
		DbSelectArea("SC8")
		DbSetOrder(1)
		DbSeek( xFilial("SC8") + Padr(cNumSC8,6) + Padr(cFornece,6) + cLojFor + cC8_ITEM )
		//caso o prazo tenha vencido não permite gravacao
		If SC8->C8_XWFID == "WF9999"
			Return
		EndIf                 

		cEmailComp := SC8->C8_XWFMAIL
		
		RecLock("SC8",.F.)
		SC8->C8_XWFCO   := "10004"
		SC8->C8_PRECO  := RetHtmVal(oProcess:oHtml:RetByName("it.preco")[nInd])
		SC8->C8_TOTAL  := SC8->C8_QUANT * SC8->C8_PRECO
		SC8->C8_ALIIPI := RetHtmVal(oProcess:oHtml:RetByName("it.ipi"  )[nInd])

		//caso o IPI não seja zero
		If SC8->C8_ALIIPI > 0
			SC8->C8_VALIPI  := ( SC8->C8_ALIIPI * SC8->C8_TOTAL )/100
			SC8->C8_BASEIPI := SC8->C8_TOTAL
		EndIf 
		
		SC8->C8_PRAZO  := RetHtmVal(oProcess:oHtml:RetByName("it.prazo")[nInd])

		//caso o icm nao seja zero 
		If RetHtmVal(oProcess:oHtml:RetByName("it.icms" )[nInd])>0
			SC8->C8_PICM        := RetHtmVal(oProcess:oHtml:RetByName("it.icms"  )[nInd])
		Else
			MaFisAlt("IT_ALIQICM", cIcm,1)
			SC8->C8_PICM        := MaFisRet(1,"IT_ALIQICM")
		EndIf

		If SC8->C8_PICM > 0
			SC8->C8_BASEICM     := SC8->C8_TOTAL
			MaFisAlt("IT_VALICM",SC8->C8_PICM,1)
			SC8->C8_VALICM      := MaFisRet(1,"IT_VALICM")
		EndIf


		If Val(oProcess:oHtml:RetByName("it.icmsst"  )[nInd])>0
			SC8->C8_BASESOL     := SC8->C8_TOTAL
			SC8->C8_VALSOL      := RetHtmVal(oProcess:oHtml:RetByName("it.icmsst"  )[nInd])
		EndIf

		SC8->C8_MOTIVO := AllTrim(oProcess:oHtml:RetByName("it.obs"  )[nInd])

		SC8->C8_COND   := Substr(oProcess:oHtml:RetByName("Pagamento"),1,3)
		SC8->C8_TPFRETE:= Substr(oProcess:oHtml:RetByName("Frete"),1,1)
		
		/*
		Iif( oProcess:oHtml:RetByName("Frete") == "FOB", ;
			SC8->C8_VALFRE := 0, ;
			SC8->C8_VALFRE := Val(oProcess:oHtml:RetByName("it.quant")[nInd]) * ;
			Val(oProcess:oHtml:RetByName("it.preco")[nInd]) / ;
			Val(oProcess:oHtml:RetByName("totped") ) *         ;
			Val(oProcess:oHtml:RetByName("valfre") ) )
		
		Iif( Val(oProcess:oHtml:RetByName("vldesc")) == 0 ,;
			SC8->C8_VLDESC := 0, ;
			SC8->C8_VLDESC := Val(oProcess:oHtml:RetByName("it.quant")[nInd]) * ;
			Val(oProcess:oHtml:RetByName("it.preco")[nInd]) / ;
			Val(oProcess:oHtml:RetByName("totped") ) * ;
			Val(oProcess:oHtml:RetByName("vldesc") ) )
		  
		*/
		MsUnlock()
		MaFisEnd()
	next 
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Substitui o html ja processado   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	cArqOrig := cDirWF+AllTrim(WF6->WF6_IDENT1)+".htm"	
	cArqDest := cDirHist+AllTrim(WF6->WF6_IDENT1)+".htm"	
	
	If (FRename( cArqOrig , cArqDest ) == 0 )	
		cBuffer := Memoread("\workflow\proc_prev.htm")                                                 
  		MemoWrite(cArqOrig,cBuffer)
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Informa o comprador da resposta  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	Recebido( oProcess, cEmailComp )
	
Return


//-------------------------------------------------------------------------------------
/*/{Protheus.doc} MT130WF
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
 
@return nil
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
 
@return nil
/*/    
//-------------------------------------------------------------------------------------
Static Function RetHtmVal( cValHtm )	
	Local nRet := 0  
	
	cValHtm := StrTran(cValHtm,",",".")
	nRet := Val( cValHtm )        

Return( nRet )



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