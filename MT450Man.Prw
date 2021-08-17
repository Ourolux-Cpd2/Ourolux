#INCLUDE "PROTHEUS.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณMT450MAN  บAutor  ณMicrosiga           บ Data ณ  10/16/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ MT450MAN ( < UPAR > ) --> URET                             บฑฑ
ฑฑบ          ณ Descri็ใo  : ANTES DA LIBERACAO MANUAL DE credito de PV    บฑฑ 
ฑฑบ          ณ Executado ao ser acionado a opcao de liberacao manual      บฑฑ 
ฑฑบ          ณ que podera ou nao ser realizada, conforme retorno do P.E.  บฑฑ                                                            
ฑฑบ          ณ Retorno: Variavel logica, sendo que .T. continua liberacao บฑฑ
ฑฑบ          ณ e .F. aborta.                                              บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP8                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function MT450Man()

Local lRet   	:= .T.
Local aArea  	:= GetArea()
Local cFSLIBPED := GETMV('FS_LIBPED')
Local cNomeUsr  := Upper(Rtrim(cUserName))
Local cRisco	:= GetAdvFVal("SA1","A1_RISCO",xFilial("SA1")+SC5->(C5_CLIENTE+C5_LOJACLI),1,"")

	If !(__cUserID $ cFSLIBPED ) .And. !U_IsAdm() .And. !("*" $ cFSLIBPED)
		lRet := .F.
		Aviso("MT450MAN","Op็ใo de libera็ใo nใo disponํvel. Utilize a libera็ใo por Cliente.", {"Ok"},2 )	
	EndIf

	If lRet
		
		If U_getMae() == "S"  
			lRet := .F.
			ApMsgStop('Libera็ใo de credito e bloqueado durante a emissao do pedido mae!', 'MT450MAN')
		EndIf
	
		/* 27-01-2014
		If lRet .And. cNomeUsr $ 'COBRANCA3' .And. cRisco # 'D'
			lRet := .F.
			ApMsgStop('Usuario sem acesso para efetuar a libera็ao!', 'MT450MAN')
		EndIf
		*/
		/*
		If SC5->C5_TOTVEN > 100000  
			If ! __cUserID $ cFSLIBPED 
				lRet := .F.
				ApMsgStop('Libera็ao de pedido so pode ser feito pela diretoria!', 'MT450MAN' )	
			EndIf
		EndIf
		*/      
		// Verifica a alcada com as permissoes
	
	    nValLib := SC9->C9_PRCVEN*SC9->C9_QTDLIB 
	
	    lRet := U_LCredPV( nValLib )
	EndIf	

RestArea(aArea)

Return(lRet)



User Function LCredPV( nValLib )
	Local lRet 		:= .F.
	Local cErroAlt  := ""
	Local nLinTab   := 0 
    Local cTab      := "U002"  

	nLinTab := U_XfPosTab(cTab, __cUserId, "==", 4)
	
	If nLinTab > 0
		uInfo := fTabela( "U002",nLinTab, 6 )

	    If nValLib > uInfo
			cErroAlt += "Limite de libera็ใo excedido para este usuแrio:" + CRLF
			cErroAlt += "Limite : R$"+Transform(uInfo,"@E 999,999,999.99") + CRLF	    
			cErroAlt += "Valor a liberar : R$ "+Transform(nValLib,"@E 999,999,999.99")+CRLF	    
		Else
			lRet := .T.
	    EndIf
	Else
		cErroAlt += "Usuario sem permissใo para liberar cr้dito."+CRLF+"Solicite ao gestor da เrea o cadastro na tabela Al็adas de Libera็ใo de Cr้dito (U002) ."+CRLF			
	EndIf
	
	
	If !Empty(cErroAlt)
		lRet := .F.                                  
		Aviso('Libera็ใo de Cr้dito',cErroAlt,{"Ok"},2,"Aten็ใo")	
	EndIf 
		
Return( lRet )	