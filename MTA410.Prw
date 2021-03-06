#INCLUDE "PROTHEUS.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �MTA410    �Autor  �Eletromega          � Data �  04/27/07   ���
�������������������������������������������������������������������������͹��
���Desc.     � PONTO DE ENTRADA : Validacao da tela toda no Ped  de Venda ���
��Retorno:   � Variavel logica que valida (.T.) ou nao (.F.) as altera��es���
���          � Somente usuarios do grupo gravado no FS_ELE008 podem       ���
���          � estornar a libera�ao de pedido na op�ao alterar            ���
�������������������������������������������������������������������������͹��
���Parametros� SC5/SC6 POSOCIONADOS                                       ���
���          �                            								  ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
�������������������������������������������������������������������������͹��
���Uso       � AP8                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function MTA410()

	Local lRet 		:= .T.
	Local nPPedCli	:= aScan(aHeader,{ |x| Upper(AllTrim(x[2])) == "C6_PEDCLI" }) 
	Local cCodGrupo := GetMV("FS_ELE008")
	Local cNomeUsr  := Upper (Substr(cUsuario,7,15))
	Local i  
	Local cMsgErro  := ""
	Local cSegmento := GetAdvFVal("SA1","A1_SATIV1"	,xFilial("SA1")+M->(C5_CLIENTE+C5_LOJACLI),1,"")
	Local cRisco    := GetAdvFVal("SA1","A1_RISCO"	,xFilial("SA1")+M->(C5_CLIENTE+C5_LOJACLI),1,"") 
	Local cEstado   := GetAdvFVal("SA1","A1_EST"	,xFilial("SA1")+M->(C5_CLIENTE+C5_LOJACLI),1,"")
	Local cTabPrc   := GetAdvFVal("SA1","A1_TABELA"	,xFilial("SA1")+M->(C5_CLIENTE+C5_LOJACLI),1,"")
	Local cCond     := GetAdvFVal("SA1","A1_COND"	,xFilial("SA1")+M->(C5_CLIENTE+C5_LOJACLI),1,"")
	Local lVenda    := ( M->C5_TIPO == "N" )
	Local lDev	    := ( M->C5_TIPO == "D" )

	lPvInt := IsPvInt()
	// Implementacao para tratar as importacoes de Pedidos via SFA
	If Type("L410Auto")!="U" .And. L410Auto
		If !lPvInt
			If !U_xAuto410()
				Return (.T.)
			EndIf
		EndIf
	EndIf

	If ! ( U_VldUsGrp (cCodGrupo) )
	//�������������������������������������������������������������������������//
	//� Se o pedido foi digitado no Call Center nao deixa o usuasrio alterar   //
	//� o pedido no SIGAFAT                                                    //
	//�������������������������������������������������������������������������//
		If lRet .And. ALTERA 	
		
			For i := 1 to Len(aCols) 
		    	
		    	If Substr(aCols[n][nPPedCli],1,3) == "TMK" .And. !UPPER(cUserName) $ "ADV|COORDVENDAS" .And. !IsInCallStack("U_INTRJ")
		    		LRet := .F.
		    		Exit
		    	EndIf
					
			Next
			
			If !lRet 
				ApMsgStop( 'Nao pode alterar os pedidos digitados no Call Center.' , 'MTA410' )
			EndIf 
		
		EndIf
	
	EndIf   
	     

	//������������������������������������������������������������������������Ŀ
	//� Valida��es para pedido gerados para opera��es do SAC                   �
	//��������������������������������������������������������������������������
	If lRet                                                      
		/* Parametro de validacao - FS_SACSC5
		01 - Usuarios 
        02 - TES Inteligente = C5_TESINT
		*/
		aInfo     := U_RetParAR( "FS_SACSC5","Sac;07;" )
		cMsgErro  := ""
	
		If !Empty(aInfo) .And. Upper(UsrRetName(__cUserId)) $ Upper(aInfo[01])
			If M->C5_TESINT <> aInfo[02] // "07"
				cMsgErro  += "O Tipo de operacao para este pedido deve ser "+aInfo[02]+"=SAC."+CRLF			    				
			Endif

		EndIf 

	EndIf

	If (INCLUI .Or. ALTERA) .And. lRet .And. lDev    
		M->C5_VEND1 := '000126'
		M->C5_BANCO := '000'		
	EndIf

	//������������������������������������������������������������������������Ŀ
	//� Valida��es Herdadas do Callcenter                                      �
	//��������������������������������������������������������������������������

	If (INCLUI .Or. ALTERA) .And. lRet .And. lVenda 
		If !Empty(M->C5_TRANSP)
			If cNivel < 3
				cMsgErro += "Favor n�o digitar a transportadora!"+CRLF
			Else
				If Upper(UsrRetName(__cUserId)) $ GetMv("FS_RETIRA") .AND. M->C5_TRANSP <> "99    "
					cMsgErro += "O Depto Comercial s� pode digitar a transportadora RETIRA!"+CRLF
				EndIf
			EndIf
		EndIf           

		//�����������������������������������Ŀ
		//�Cliente com risco E e bloqueado    �
		//�������������������������������������
		If cRisco == "E"
			cMsgErro += "Cliente com risco E"+CRLF
		EndIf
		//����������������������������������������������������������������Ŀ
		//� Nao deixa tirar pedido para o cliente padrao para or�amento    �
		//������������������������������������������������������������������
		If M->C5_CLIENTE == '000000'
			cMsgErro += "N�o pode cadastrar pedidos para o cliente"+CRLF
		EndIf 
		
		If Empty(cSegmento)
			cMsgErro += "Cliente sem Segmento."+CRLF
		EndIf
		
		/* comentado por solicita��o do wadih no dia 28/10/2021
		nVendNac := GetAdvFVal("SA3","A3_XVNDNAC",xFilial("SA3")+AllTrim(M->C5_VEND1),1,'N')
		
		If nVendNac == "N" .And. !U_IsAdm() 
			
			If cNumEmp <> '0101' .And. cEstado == 'MA' // Empresa = 01 e Filial = 01
				cMsgErro += "Venda para " + cEstado + " e proibida!"+CRLF
			EndIf
			
			If cNumEmp == '0102' .And. cEstado == 'PI'  // Empresa = 01 e Filial = 02
				cMsgErro += "Venda para " + cEstado + " e proibida!"+CRLF
			EndIf
		EndIf
		*/
		cNumtrf := M->C5_XNUMTRF
		
		If !Empty(cNumtrf) .And. cFilAnt == "04"
			If !(Upper(Rtrim(cUserName)) $ 'ADV.ADMINISTRADOR.ASSISTENTE6.COORDVENDAS')
				cMsgErro += "Atendimento nao pode ser alterado. Integra�ao filial GRU."+CRLF
			
			// Faz tratamento caso tem faturamento parcial
			
			//Else
			//	cMsgErro += "Favor solicitar a altera�ao de pedido de transferencia para a logistica GRU no caso de altera�ao de QTD!"+CRLF
		    EndIf
		EndIf

		If IsBonif() .And. M->C5_CONDPAG <> 'BON'   
			cMsgErro += "Favor utilizar a condicao BON para pedidos de bonifica�oes."+CRLF
		EndIf 

		If M->C5_TABELA <> cTabPrc .And. !lPvInt	
			cMsgErro += "Tabela de pre�o do pedido � diferente da informado no cliente."+CRLF
		EndIf 

    	If !Empty( cCond )
			If Alltrim(M->C5_CONDPAG) <> Alltrim(cCond) .And. !lPvInt .And. !IsBonif()	
				cMsgErro += "Condi��o de pagamento � diferente da informado no cliente."+CRLF
			EndIf 
    	Else
			cNivCP    := GetAdvFVal("SE4","E4_NIVEL"	,xFilial("SE4")+M->C5_CONDPAG,1,"")
			If Val(cNivCP) > 7 .And. !lPvInt
				cMsgErro += "Condi��o de pagamento n�o permitida : N�vel "+cNivCP+"."+CRLF							
			EndIf
    	EndIf
	
	EndIf

	If !Empty( cMsgErro )
		lRet := .F.	
		Aviso("MTA410",cMsgErro,{"Ok"},3,"Aten��o")
	EndIf

Return( lRet )        



/*
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
����������������������������������������������������������������������������ͻ��
���Programa  �             �Autor  �Eletromega          � Data �  17/05/12   ���
����������������������������������������������������������������������������͹��
���Desc.     �Verifique se o pedido e de bonifica�ao                         ���
���          �                                                               ���
����������������������������������������������������������������������������͹��
���Uso       �TELEVENDAS                                                     ���
����������������������������������������������������������������������������ͼ��
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
*/
Static Function IsBonif()

	Local aArea		:= GetArea()        		// Guarda a area anterior
	Local nPCfop	:= aScan(aHeader,{ |x| Upper(AllTrim(x[2])) == "C6_CF" })
	Local nItens    := 0 // total dos itens no pedido 
	Local nCF910    := 0 // total dos itens c/ CF 910
	Local nI        := 0
	
	For nI:=1 TO Len(aCols)
		If !aCols[nI][Len(aHeader)+1] 
			++nItens
			If (Substr(aCols[nI][nPCfop], 2, 3 ) $ '910')
	        	++nCF910	
	        EndIf
	    EndIf     
	Next nI
	
	RestArea(aArea)

Return(nItens == nCF910) 


Static Function IsPvInt()
	Local lRet := .F.
	Local cCliInt := SubStr(AllTrim(GetMV("FS_TMKRJCL")),1,6) 	
	lRet := ( !Empty(M->C5_XNUMINT) .Or. AllTrim(M->C5_PEDREP) $ "INTPV/INTRJ" .Or. AllTrim(M->C5_CLIENTE) == cCliInt )  
	If !lRet    
		lRet := IsInCallStack("U_INTRJ") .Or. IsInCallStack("U_INTPV")
	EndIf

Return( lRet )
