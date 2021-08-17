#include 'Ap5Mail.ch'
#include 'rwmake.ch'

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÝÝÝÝÝÝÝÝÝÝÑÝÝÝÝÝÝÝÝÝÝËÝÝÝÝÝÝÝÑÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝËÝÝÝÝÝÝÑÝÝÝÝÝÝÝÝÝÝÝÝÝ»±±
±±ºPrograma  ³MTA450CL  ºAutor  ³Fabricio Romera FIT º Data ³  02/20/15   º±±
±±ÌÝÝÝÝÝÝÝÝÝÝØÝÝÝÝÝÝÝÝÝÝÊÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÊÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝ¹±±
±±ºDesc.     ³ PE na analise de credito por cliente - 
±±º          ³                                                            º±±
±±ÌÝÝÝÝÝÝÝÝÝÝØÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function MTA450CL()
Local aArea  	 := GETAREA()
Local cLista     := ''
Local cMotivo    := Space(109)
Local oHTML
Local cEmailSup  := ""
Local aNomegrupo := {'Rejeitado'}  
Local cNUM       := SC9->C9_PEDIDO
Local cFilC9	 := SC9->C9_FILIAL
Local cCodVend   := ''
Local cNomVCPDSup:= ''
Local cNomSup    := ''
Local cCodGer    := ''
Local cNomGer    := ''

If PARAMIXB[01] == 1

	If IsInCallStack("MATA450A") // Chamada da liberação por cliente
		//Força	Posicionar ?	
		cNum := SC5->C5_NUM		

		DbSelectArea("SC5")
		DbSetOrder(1)
	
		If DbSeek(SC5->C5_FILIAL + SC5->C5_NUM)
			RecLock("SC5",.F.)
			SC5->C5_XUSRLIB		:= cUsername
			SC5->C5_XDTLIB    	:= dDATAbASE
			SC5->C5_XMOTLIB   	:= "Pedido Liberado"
			SC5->C5_XTIPOL    	:= "L"
			MsUnlock()
		EndIf
	Else
		DBSELECTAREA("SC5")
		DBSETORDER(1)
		DBGOTOP()
		IF DBSEEK(cFilC9+cNUM)
			RECLOCK("SC5",.F.)
			FIELD->C5_XUSRLIB	:= cUsername
			FIELD->C5_XDTLIB    := dDATAbASE
			FIELD->C5_XMOTLIB   := "Pedido Liberado"
			FIELD->C5_XTIPOL    := "L"
			MSUNLOCK()
		ENDIF
	EndIf	                         
Else

	If !IsInCallStack("MATA450A")
	
		IF MSGYESNO("Bloqueia todos os itens do Pedido "+SC9->C9_PEDIDO,"Atenção")
		
			cNUM := SC9->C9_PEDIDO
		
			DBSELECTAREA("SC9")
			DBSETORDER(1)
			DBGOTOP()
			IF DBSEEK(cFilC9+cNUM)
				WHILE !EOF() .AND. cNUM == SC9->C9_PEDIDO
					RECLOCK("SC9",.F.)
					SC9->C9_BLCRED := "09"
					MSUNLOCK()
					DBSKIP()
				END
			ENDIF
			
		ENDIF
		
		DbSelectArea( "SZB" )
		
		If MsSeek(xFilial("SZB"))
		
			If SZB->ZB_STATUS <> 'N'
				MsgInfo( 'Aguarde, durante a emissão do pedido de separação a liberação de crédito estará bloqueada, tente mais tarde...' )
		    	RestArea(aArea)
		    	Return( .F. )
			EndIf
		
			@ 96,42 TO 323,505 DIALOG oDlg TITLE "Motivo da Rejeição do Pedido"
			@ 8,10 TO 84,222
			@ 91,139 BUTTON "_Envia" Size 70,20  ACTION Close(oDlg)
			@ 33,14 SAY "Motivo "
			@ 43,14 GET cMotivo
			ACTIVATE DIALOG oDlg CENTERED
		
			fSA3 := xFilial( 'SA3' )
			fSC6 := xFilial( 'SC6' )
			fSB2 := xFilial( 'SB2' )
		
			DBSELECTAREA("SC5")
			DBSETORDER(1)
			DBGOTOP()
			IF DBSEEK(cFilC9+cNUM)
				
				RECLOCK("SC5",.F.)
				FIELD->C5_XUSRLIB	:= cUsername
				FIELD->C5_XDTLIB    := dDATAbASE
				FIELD->C5_XMOTLIB   := cMotivo
				FIELD->C5_XTIPOL    := "R"
				MSUNLOCK()
			
				oProcess:= TWFProcess():New("Recusado","CreditoRecusado")
				oProcess:NewTask("Inicio","\WORKFLOW\rejeitado.htm")
				oProcess:cSubject := "Credito Recusado!" + Alltrim(SM0->M0_NOME) + '/' +Alltrim(SM0->M0_FILIAL) 
				oHtml := oProcess:oHTML
				
				oHTML:ValByName('DATA',dDataBase)
				oHTML:ValByName('PEDIDO',SC5->C5_NUM)
				oHTML:ValByName('CLIENTE',SC5->C5_CLIENTE +'/'+ SC5->C5_LOJACLI + ' ' + SA1->A1_NOME)
				oHTML:ValByName('MOTIVO', cMotivo)
			                
			    cCodVend := RTrim(GetAdvFVal("SA3","A3_COD",xFilial("SA3")+SC5->C5_VEND1,1,""))
				cNomVend := RTrim(GetAdvFVal("SA3","A3_NOME",xFilial("SA3")+SC5->C5_VEND1,1,""))
				oHTML:ValByName('VEND',cCodVend +" / "+ cNomVend) 
				
				cCodSup := RTrim(GetAdvFVal("SA3","A3_SUPER",xFilial("SA3")+SC5->C5_VEND1,1,""))
				If !Empty(cCodSup)
					cNomSup := RTrim(GetAdvFVal("SA3","A3_NOME",xFilial("SA3")+cCodSup,1,""))
					oHTML:ValByName('SUPERV',cCodSup +" / "+ cNomSup)
				EndIf
				
				cCodGer := RTrim(GetAdvFVal("SA3","A3_GEREN",xFilial("SA3")+SC5->C5_VEND1,1,""))
				If !Empty(cCodGer)
					cNomGer := RTrim(GetAdvFVal("SA3","A3_NOME",xFilial("SA3")+cCodGer,1,""))
					oHTML:ValByName('GEREN',cCodGer +" / "+ cNomGer)
				EndIf
					    
				cLista := U_getEmls(SC5->C5_VEND1)
				cLista += IIf(Empty(cLista),U_GrpEmail('Rejeitado'),';'+U_GrpEmail('Rejeitado'))
			
				If !Empty(cLista) 
					oProcess:cBCc := cLista 
					oProcess:Start()
					oProcess:Finish() 
				End
			    
			EndIf    
		
		EndIf
	EndIf	

EndIf
	
RestArea(aArea)	

Return( NIL )