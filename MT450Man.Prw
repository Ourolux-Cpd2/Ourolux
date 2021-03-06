#INCLUDE "PROTHEUS.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �MT450MAN  �Autor  �Microsiga           � Data �  10/16/08   ���
�������������������������������������������������������������������������͹��
���Desc.     � MT450MAN ( < UPAR > ) --> URET                             ���
���          � Descri��o  : ANTES DA LIBERACAO MANUAL DE credito de PV    ��� 
���          � Executado ao ser acionado a opcao de liberacao manual      ��� 
���          � que podera ou nao ser realizada, conforme retorno do P.E.  ���                                                            
���          � Retorno: Variavel logica, sendo que .T. continua liberacao ���
���          � e .F. aborta.                                              ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP8                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function MT450Man()

Local lRet   	:= .T.
Local aArea  	:= GetArea()
Local cFSLIBPED := GETMV('FS_LIBPED')
Local cNomeUsr  := Upper(Rtrim(cUserName))
Local cRisco	:= GetAdvFVal("SA1","A1_RISCO",xFilial("SA1")+SC5->(C5_CLIENTE+C5_LOJACLI),1,"")

	If !(__cUserID $ cFSLIBPED ) .And. !U_IsAdm() .And. !("*" $ cFSLIBPED)
		lRet := .F.
		Aviso("MT450MAN","Op��o de libera��o n�o dispon�vel. Utilize a libera��o por Cliente.", {"Ok"},2 )	
	EndIf

	If lRet
		
		If U_getMae() == "S"  
			lRet := .F.
			ApMsgStop('Libera��o de credito e bloqueado durante a emissao do pedido mae!', 'MT450MAN')
		EndIf
	
		/* 27-01-2014
		If lRet .And. cNomeUsr $ 'COBRANCA3' .And. cRisco # 'D'
			lRet := .F.
			ApMsgStop('Usuario sem acesso para efetuar a libera�ao!', 'MT450MAN')
		EndIf
		*/
		/*
		If SC5->C5_TOTVEN > 100000  
			If ! __cUserID $ cFSLIBPED 
				lRet := .F.
				ApMsgStop('Libera�ao de pedido so pode ser feito pela diretoria!', 'MT450MAN' )	
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
			cErroAlt += "Limite de libera��o excedido para este usu�rio:" + CRLF
			cErroAlt += "Limite : R$"+Transform(uInfo,"@E 999,999,999.99") + CRLF	    
			cErroAlt += "Valor a liberar : R$ "+Transform(nValLib,"@E 999,999,999.99")+CRLF	    
		Else
			lRet := .T.
	    EndIf
	Else
		cErroAlt += "Usuario sem permiss�o para liberar cr�dito."+CRLF+"Solicite ao gestor da �rea o cadastro na tabela Al�adas de Libera��o de Cr�dito (U002) ."+CRLF			
	EndIf
	
	
	If !Empty(cErroAlt)
		lRet := .F.                                  
		Aviso('Libera��o de Cr�dito',cErroAlt,{"Ok"},2,"Aten��o")	
	EndIf 
		
Return( lRet )	