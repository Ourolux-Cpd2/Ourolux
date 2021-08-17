/*
//   Ponto de Entrada rejeicao do pedido de venda no credito
*/

#include 'Ap5Mail.ch'
#include 'rwmake.ch'

User Function MTA450R()

Local cLista     := ''
Local cMotivo    := Space(109)
Local oHTML
Local aArea  	 := GETAREA()
Local cEmailSup  := ""
Local cNUM       := SC9->C9_PEDIDO
Local cFilC9	 := SC9->C9_FILIAL
Local cCodVend   := ''
Local cNomVend   := ''
Local cCodSup    := ''
Local cNomSup    := ''
Local cCodGer    := ''
Local cNomGer    := ''

If FUNNAME() = "MATA450A"
	RestArea(aArea)
	Return( NIL )	
EndIf

IF MSGYESNO("Bloqueia todos os itens do Pedido "+SC9->C9_PEDIDO,"Atencao")

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
		MsgInfo( 'Aguarde, durante a emissao do pedido de separacao a liberacao de credito estara bloqueada, tente mais tarde...' )
    	RestArea(aArea)
    	Return( .F. )
	EndIf

	@ 96,42 TO 323,505 DIALOG oDlg TITLE "Motivo da Rejeicao do Pedido"
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

RestArea(aArea)	

Return( NIL )