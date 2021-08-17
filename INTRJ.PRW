#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "FWBROWSE.CH"

#DEFINE COMP_DATE  "20200206" 

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} INTRJ
Integracao de pedidos de vendas entre filiais Ourolux.

Tela Principal - Parametros - Visualizacao de Log
Visualizacao de Log (ProcLogView())
Botao OK - SetProc()
Botão Cancelar - FechaBatch()
Botao Parametros - Pergunte(cPerg,.T. )
                                  
@type 		function
@author 	Roberto Souza
@since 		01/02/2017
@version 	P11 
 
@return nil
/*/    
//-------------------------------------------------------------------------------------

User Function INTRJ()

	//Local lEnd      := .F.
	Local aSays 	:= {}
	Local aButtons	:= {}
	Local bProcView	:= {|| ProcLogView() 	}
	Local bOkProc	:= {|| SetProc() 		}
	Local bCancel   := {|| FechaBatch() 	}
	//Local nOpca 	:= 0  
	Local cPerg		:= "INTRJ"
	
	Private cLOG 	:= ""
	Private __BatchProc  := "U_INTRJ"
	Private cLogID       := __BatchProc
	Private cCadastro    := "Integracao de pedidos entre filiais"
	Private lPedTMK		 := SuperGetMV("FS_INTTMK",.F.,.T.)
	// Inicializa o log de processamento
	// CV8
	
	AADD(aSays, 'Este programa tem como objetivo integrar pedidos de vendas entre as filiais Ourolux.') 
	AADD(aSays, 'Empresa que sera copiado os pedidos:')
	If cFilAnt == "01"
		AADD(aSays, 'GUARULHOS - SP para RIO DE JANEIRO - RJ')
	ElseIf cFilAnt == "06"
		AADD(aSays, 'SANTA CATARINA - SC para RIO DE JANEIRO - RJ')
	EndIf
	AADD(aSays, '') 
	

	aadd(aButtons, { 15,.T.,bProcView 	} )
	AADD(aButtons, { 5,.T.,{|| Pergunte(cPerg,.T. ) } } ) 
	aadd(aButtons, {  1,.T.,bOkProc 	} ) 
	aadd(aButtons, {  2,.T.,bCancel 	} )  
	
	FormBatch( 'Processamento de Pedidos de Venda', aSays, aButtons,, 220, 560 )
	
Return

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} INTRJ
Barra de Status do Processamento

Execucao do PROCINT                                       
*/

Static Function SetProc()

    Local oProc 	
	Local lEnd := .F.
	
	oProc:= MsNewProcess():New({|| ProcInt( @oProc ) } , "Integracao de pedidos entre filiais...", "Aguarde, processando registros...", lEnd )
	oProc:Activate()

Return

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} INTRJ
Barra de Status - Filiais - Executa por Filial             

Execucao do GOPROC (Inicia o processamento)              
*/

Static Function ProcInt( oProc )

	Local aFilProc 	:= {}
	Local Nx 		:= 0
                           
	// Implementar aqui parametros de outras filiais
	AADD( aFilProc, {"01","04"} ) // Guarulhos Para RJ  
	AADD( aFilProc, {"06","04"} ) // Santa Catarina Para RJ  
	    
	oProc:SetRegua1( Len(aFilProc) )
	  
		For Nx := 1 To Len( aFilProc )
		oProc:IncRegua1("Processando : De filial: " + aFilProc[Nx][01] + " para filial: " + aFilProc[Nx][02] + ".")
		GoProc( oProc, aFilProc[Nx] )
	Next                       

Return()

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} GOPROC

Validacao da Transportadora, cliente, condicao de pagmto,  
Tabela de preco, TES, Tipo Frete, Local, vendedor, Pedidos 
Liberados, Consistencia dos pedidos, Pedido Destino, Pedi- 
do Transferencia, Estorno do Pedido (ProcAltPV), Exclusao  
do Pedido (ProcDelPV)                                      
do Transferencia.                                           
*/

Static Function GoProc( oProc, aFils )

	Local cFilDe    := aFils[01]	
	Local cFilPara  := aFils[02]
	Local cEstDest  := "RJ"
	Local lContinua := .T.
	
	Local cPerg		:= "INTRJ"
		
	Local cTMKRJCL	:= SubStr(AllTrim(GetMV("FS_TMKRJCL")),1,6)	//Cliente Padrao
	Local cTMKRJLJ	:= SubStr(AllTrim(GetMV("FS_TMKRJCL")),8,2)	//Loja Padrao
	Local cTMKRJCP	:= SubStr(AllTrim(GetMV("FS_TMKRJCP")),1,3)	//Condicao de Pagamento Padrao
	Local cTMKRJTB	:= SubStr(AllTrim(GetMV("FS_TMKRJTB")),1,3)	//Tabela de precos Padrao
	Local cTMKRJTS	:= SubStr(AllTrim(GetMV("FS_TMKRJTS")),1,3)	//Tes de Saida Padrao
	//Local cTMKRJTI	:= SubStr(AllTrim(GetMV("FS_TMKRJTI")),1,3)	//Tes de Sai�da Padrao
	Local cTMKRJFP	:= SubStr(AllTrim(GetMV("FS_TMKRJFP")),1,6)	//Forma de Pagamento Padrao
	Local cTMKRJTE	:= SubStr(AllTrim(GetMV("FS_TMKRJTE")),1,1)	//Tipo de entrada Padrao
	Local cTMKRJTR	:= SubStr(AllTrim(GetMV("FS_TMKRJTR")),1,6)	//Transportadora Padrao
	Local cTMKRJTF	:= SubStr(AllTrim(GetMV("FS_TMKRJTF")),1,1)	//Tipo de Frete Padrao
	Local cTMKRJLC	:= SubStr(AllTrim(GetMV("FS_TMKRJLC")),1,2)	//Local Padrao
	Local cVDTRANS	:= SubStr(AllTrim(GetMV("FS_VDTRANS")),1,6)	//Vendedor Padrao para Transferencia
	Local cTabDrto	:= "%"+FormatIn(AllTrim(GetMv("FS_TABDRTO")),"/")+"%"  // Tabelas faturamento direto
	//Local lSldIni   := .T. // Variavel para controle de inclusao de saldo zerado na SB9. Claudino 04/09/13.
	Local cTabtrrj  := ''
	//Local cDatAte   := ''
	//Local nPrcTab   := 0
	//LOCAL cFim		:= CRLF
	//Local aPedLog	:= {}
	Local cCODSYP   := ""
	//Local cObs     	:= ""
	//Local aSYP     	:= {}
	Local cMsgErro 	:= "" 
	Local cTPed     := GetNextAlias()
	Local aNewSC5   := {}
	Local aPVOk     := {}
	Local aSC5      := {}
	Local aSC6      := {}
	Local aToSC5    := {}
	Local aToSC6    := {} 
	Local Nx		:= 0
	Local aTabxProd := {}
	Local cPedRep	:= "INTPV"
	Local aNoPed    := {}
	//Local aOkPed    := {}
	Local cTrfSC5   := ""
	Local cTes		:= ""
	Local lTes		:= .T.  
	Local cLOG		:= ""
	Local cPedcli	:= ""
	//Local cCliPed	:= "TMK%"
	Local _aSYP		:= {}
	Local cNumObs
	Local nI		:= 0
	//Local cCODSYP
	Local _cObs		:= ""
	Local xFilAnt	:= ""
	Local xNumEmp	:= ""									

	Private cItem     := "00"

MakeDir("\log\")

If cFilAnt == cFilDe
	
	If Pergunte(cPerg,.T.)
		
		// Verificações iniciais
		ProcLogAtu('INICIO',"De filial: " + cFilDe + " para filial: " + cFilPara,,cLogID)
		cTRANSP	:= MV_PAR03
		
		If Empty(cTRANSP)
			cMsgErro += "Favor informar a Transportadora!" + CRLF
		Else
			If !ExistCpo("SA4",cTRANSP)
				cMsgErro += "Transportadora informada nao esta cadastrada!" + CRLF
			Else
				DbSelectArea("SA4")
				SA4->(dbSetOrder(1))
				If DbSeek(xFilial("SA4") + cTRANSP) .And. SA4->A4_MSBLQL == "1"
					cMsgErro += "Transportadora Bloqueada!" + CRLF
				EndIf
			EndIf
		EndIf
		// Claudino - 04/01/16 - Fim
		
		If Select("TRC") > 0
			//dbSelectArea("TRC")
			TRC->(dbCloseArea())
		EndIf
		
		If Empty(cTMKRJCL)
			cMsgErro += ("Cliente padrao para transferencia nao informado. Verifique o parâmetro FS_TMKRJCL. Integracao nao realizada. Informe ao TI.") + CRLF
		EndIf
		
		If Empty(cTMKRJLJ)
			cMsgErro += ("Loja do Cliente padrao para transferencia nao informada. Verifique o parametro FS_TMKRJCL. Integracao nao realizada. Informe ao TI.") + CRLF
		EndIf
		
		If Empty(cTMKRJCP)
			cMsgErro += ("Condicao de Pagamento padrao para transferencia nao informada. Verifique o parametro FS_TMKRJCP. Integracao nao realizada. Informe ao TI.") + CRLF
		EndIf
	
		If Empty(cTMKRJTB)
			cMsgErro += ("Tabela de Precos padrao para transferencia nao informada. Verifique o parametro FS_TMKRJTB. Integracao nao realizada. Informe ao TI.") + CRLF
		EndIf

		If Empty(cTMKRJTS)
			cMsgErro += ("TES padrao para transferencia nao informado. Verifique o parametro FS_TMKRJTS. Integracao nao realizada. Informe ao TI.") + CRLF
		EndIf

		If Empty(cTMKRJFP)
			cMsgErro += ("Forma de Pagamento padrao para transferencia nao informada. Verifique o parametro FS_TMKRJFP. Integracao nao realizada. Informe ao TI.") + CRLF
		EndIf
		
		If Empty(cTMKRJTE)
			cMsgErro += ("Tipo de Entrada padrao para transferencia nao informado. Verifique o parametro FS_TMKRJTE. Integracao nao realizada. Informe ao TI.") + CRLF
		EndIf
		
		If Empty(cTMKRJTR)
			cMsgErro += ("Transportadora padrao para transferencia nao informada. Verifique o parametro FS_TMKRJTR. Integracao nao realizada. Informe ao TI.") + CRLF
		EndIf
		
		If Empty(cTMKRJTF)
			cMsgErro += ("Tipo de Frete padrao para transferencia nao informado. Verifique o parametro FS_TMKRJTF. Integracao nao realizada. Informe ao TI.") + CRLF
		EndIf

		If Empty(cTMKRJLC)
			cMsgErro += ("Local padrao para transferencia nao informado. Verifique o parametro FS_TMKRJLC. Integracao nao realizada. Informe ao TI.") + CRLF
		EndIf
		
		If Empty(cVDTRANS)
			cMsgErro += ("Vendedor Padrao nao cadastrado, por favor informar. Integracao nao realizada. Informe ao TI.") + CRLF
		EndIf
		
		// TABELA DE TRANSFER
		
		cTabtrrj := GetAdvFVal("SA1","A1_TABELA",xFilial("SA1") + cTMKRJCL + cTMKRJLJ,1,"")
		
		If !Empty(cTabtrrj)

			cTabtrrj := GetAdvFVal("DA0","DA0_CODTAB",xFilial("DA0") + AllTrim(cTabtrrj),1,"")

			If Empty(cTabtrrj) .Or. cTabtrrj <> cTMKRJTB
				 cMsgErro += ("Favor cadastrar a tabela" + cTMKRJTB + "na filial RJ.") + CRLF
			EndIf
			
		EndIf

        If !Empty(cMsgErro)

			ProcLogAtu('ERRO','Erro no processamento',cMsgErro,cLogID)
			ProcLogAtu('FIM',,,cLogID)             
        	lContinua := .F. 
        	MsgAlert("Processo encerrado com erros!")
        	Return()

        EndIf
		If lPedTMK
			BeginSql ALIAS cTPed
			
				SELECT
					C5_NUM,C5_TIPO,C5_CLIENTE,C5_LOJACLI,C5_CONDPAG,C5_TABELA,
					C6_ITEM,C6_PRODUTO,C6_QTDVEN,C6_PRCVEN,C6_PRUNIT,C6_TES,C6_LOCAL,C6_PEDCLI,C6_LOTECTL,C6_DTVALID, 
					C9_QTDLIB,
					SC5.R_E_C_N_O_ SC5RECNO,
					SC6.R_E_C_N_O_ SC6RECNO,
					SC9.R_E_C_N_O_ SC9RECNO				
				FROM %table:SC5% SC5
					INNER JOIN %table:SC6% SC6 ON C6_FILIAL = C5_FILIAL AND C6_NUM = C5_NUM  AND C6_CLI = C5_CLIENTE AND C6_LOJA = C5_LOJACLI AND SC6.%NotDel%
					INNER JOIN %table:SC9% SC9 ON C9_FILIAL = C5_FILIAL AND C9_PEDIDO = C5_NUM AND C9_CLIENTE = C5_CLIENTE AND C9_LOJA = C5_LOJACLI AND C9_PRODUTO = C6_PRODUTO AND SC9.%NotDel%
					INNER JOIN %table:SA1% SA1 ON A1_FILIAL = A1_FILIAL AND A1_COD = C5_CLIENTE  AND A1_LOJA = C5_LOJACLI AND SA1.%NotDel%
				WHERE C5_FILIAL = %exp:cFilDe% 
					AND C5_EMISSAO BETWEEN %exp:MV_PAR01% AND %exp:MV_PAR02%
					AND C5_NUM     BETWEEN %exp:MV_PAR04% AND %exp:MV_PAR05%
					AND A1_EST     = %exp:cEstDest%	
					AND C5_PEDREP  <> %exp:cPedRep%
					AND C5_XNUMTRF = %exp:Space(1)%	
					AND C5_XNUMINT = %exp:Space(1)%
					AND C9_BLEST   = %exp:Space(1)%
					AND C9_BLCRED  = %exp:Space(1)%
					AND C6_PEDCLI  <> %exp:Space(1)%
					AND C5_TABELA  NOT IN %exp:cTabDrto%
					AND SC5.%NotDel%													
					ORDER BY C6_NUM, C6_ITEM 										
			EndSql
		Else
			BeginSql ALIAS cTPed
			
				SELECT
					C5_NUM,C5_TIPO,C5_CLIENTE,C5_LOJACLI,C5_CONDPAG,C5_TABELA,
					C6_ITEM,C6_PRODUTO,C6_QTDVEN,C6_PRCVEN,C6_PRUNIT,C6_TES,C6_LOCAL,C6_PEDCLI,C6_LOTECTL,C6_DTVALID, 
					C9_QTDLIB,
					SC5.R_E_C_N_O_ SC5RECNO,
					SC6.R_E_C_N_O_ SC6RECNO,
					SC9.R_E_C_N_O_ SC9RECNO				
				FROM %table:SC5% SC5
					INNER JOIN %table:SC6% SC6 ON C6_FILIAL = C5_FILIAL AND C6_NUM = C5_NUM  AND C6_CLI = C5_CLIENTE AND C6_LOJA = C5_LOJACLI AND SC6.%NotDel%
					INNER JOIN %table:SC9% SC9 ON C9_FILIAL = C5_FILIAL AND C9_PEDIDO = C5_NUM AND C9_CLIENTE = C5_CLIENTE AND C9_LOJA = C5_LOJACLI AND C9_PRODUTO = C6_PRODUTO AND SC9.%NotDel%
					INNER JOIN %table:SA1% SA1 ON A1_FILIAL = A1_FILIAL AND A1_COD = C5_CLIENTE  AND A1_LOJA = C5_LOJACLI AND SA1.%NotDel%
				WHERE C5_FILIAL = %exp:cFilDe% 
					AND C5_EMISSAO BETWEEN %exp:MV_PAR01% AND %exp:MV_PAR02%
					AND C5_NUM     BETWEEN %exp:MV_PAR04% AND %exp:MV_PAR05%
					AND A1_EST     = %exp:cEstDest%	
					AND C5_PEDREP  <> %exp:cPedRep%
					AND C5_XNUMTRF = %exp:Space(1)%	
					AND C5_XNUMINT = %exp:Space(1)%
					AND C9_BLEST   = %exp:Space(1)%
					AND C9_BLCRED  = %exp:Space(1)%
					AND C5_TABELA  NOT IN %exp:cTabDrto%
					AND SC5.%NotDel%													
					ORDER BY C6_NUM, C6_ITEM 										
			EndSql
		EndIf
		COUNT to nCountC6
		
		cQuery := GetLastQuery()[02]
		ProcLogAtu("MENSAGEM","Query", cQuery,cLogID)
		
		cPed	:=""
		
		(cTPED)->(DbGoTop())

		If (cTPED)->(!Eof())
	   		cLOG += "Lista de Pedidos Liberados no Processamento:" + CRLF
		Else
	   		cLOG += "Nenhum Pedidos Liberado nos Parametros selecionados." + CRLF
		EndIf
		
		// Fazer as consistencias dos dados selecionados
		DbSelectArea(cTPED)
		(cTPED)->(DbGoTop())

		While (cTPED)->(!Eof())
			
			cPEDCLI	:= (cTPED)->C6_PEDCLI
			cNUM	:= (cTPED)->C5_NUM
			cLOG +=  "Item " + ALLTRIM((cTPED)->C6_PRODUTO) + " - Quant: " + TRANSFORM((cTPED)->C9_QTDLIB,"@E 999,999.99") + " do Pedido: " + cNUM + " do Atendimento: " + cPEDCLI
			cLOG += CRLF
			
			AADD( aTabxProd, { "Destino"	, cFilPara	, (cTPED)->C5_NUM, (cTPED)->C5_TABELA, (cTPED)->C6_PRODUTO } )
			AADD( aTabxProd, { "Transfer"  	, cFilde	, (cTPED)->C5_NUM, cTMKRJTB			 , (cTPED)->C6_PRODUTO } )			
			
			(cTPED)->(Dbskip())
			
		EndDo

		oProc:SetRegua2(10)

		aOcorr := {}
		
		
		oProc:SetRegua1( 5 )		 
		oProc:IncRegua1("Verificando a consistencia dos cadastros etapa: " + StrZero(1,2))

		// Tabela de precos
		oProc:SetRegua2( Len( aTabxProd ) )
		oProc:IncRegua2("Tabelas de precos.")
        
        lTabPreco := CHKTabPreco( oProc, aTabxProd , @aOcorr )

		If !lTabPreco
			aCabOcorr := {"Local","Filial","Pedido", "Tabela","Produto"}		
			lContinua := VisErro( aCabOcorr , aOcorr )
			If lContinua         
				cInfoLog := "Os seguintes pedidos foram ignorados no processo."+CRLF
				cInfoLog += "Local  Filial Pedido Tabela Produto  Detalhe"+CRLF
				For Nx := 1 To Len( aOcorr )
					cInfoLog += Padr(aOcorr[Nx][01],08)+;
								Padr(aOcorr[Nx][02],08)+;
								Padr(aOcorr[Nx][03],08)+;
								Padr(aOcorr[Nx][04],08)+;
								Padr(aOcorr[Nx][05],15)+;
								aOcorr[Nx][06]+CRLF				
					AADD( aNoPed ,aOcorr[Nx][03])
				Next
				
				ProcLogAtu("ALERTA","Aviso de Inconsistencias",	cInfoLog, cLogID )
			Else
				Return()
			EndIf
		EndIf
	
		DbSelectArea(cTPED)
		DbGoTop()

		oProc:SetRegua2(nCountC6)

		DbSelectArea("SC5")
		DbSetOrder(1)

 		DbSelectArea("SC6")
		DbSetOrder(1)

		DbSelectArea("SC9")
		DbSetOrder(1)
			
		While (cTPED)->(!Eof()) 
			nRecSC5 := (cTPED)->SC5RECNO
			DbSelectArea("SC5")
			DbGoTo( nRecSC5 )
        	
        	cNumPed := SC5->C5_NUM
            aSC5    := {}
            aSC6    := {}
            
            oProc:IncRegua2("Pedido: " + cNumPed) 

            lNoPed := aScan( aNoPed , {|x| x == cNumPed } ) > 0

            If lNoPed
                // Se está na lista de ignorados não processa
	            While (cTPED)->(!Eof()) .And. SC5->C5_NUM == (cTPED)->C5_NUM
    				(cTPED)->(DbSkip())
    			EndDo
            Else
				
				lTES := .T.  
				
				DBSELECTAREA("SUA")
				SUA->(dbsetorder(8))
				SUA->(dbgotop())
				
				// Busca códido de mensagem virtual, para exibição no pedido de vendas - Bia Ferreira - 18/01/2020
				If SUA->(dbseek(xFilial("SUA")+(cTPED)->C5_NUM))
					cNumObs := SUA->UA_CODOBS
				Endif
				
				_aSYP := IntRjMe(cNumObs,1000)
				If Len(_aSYP) > 0
					For nI := 1 To Len(_aSYP)
						_cObs += _aSYP[nI]
					Next nI
				Endif
									
				If !Empty(_cObs)
					cCODSYP	:= GetSxeNum("SYP","YP_CHAVE")
				Endif				
				// Fim // 				
	
				aadd(aSC5,{"C5_FILIAL" 	,cFilPara			,Nil})
				aadd(aSC5,{"C5_TIPO" 	,SC5->C5_TIPO		,Nil})
				aadd(aSC5,{"C5_CLIENTE"	,SC5->C5_CLIENTE	,Nil})
				aadd(aSC5,{"C5_LOJACLI"	,SC5->C5_LOJACLI	,Nil})
				aadd(aSC5,{"C5_LOJAENT"	,SC5->C5_LOJACLI	,Nil})
				aadd(aSC5,{"C5_TRANSP"	,AllTrim(cTRANSP)	,Nil}) // WAR 04/02/2020
				aadd(aSC5,{"C5_TABELA"	,SC5->C5_TABELA		,Nil})
				aadd(aSC5,{"C5_CONDPAG"	,SC5->C5_CONDPAG	,Nil})
				aadd(aSC5,{"C5_TPFRETE"	,"C"	  			,Nil})
				aadd(aSC5,{"C5_TIPOENT"	,cTMKRJTE			,Nil})
				aadd(aSC5,{"C5_TPCARGA"	,"1"				,Nil})
				aadd(aSC5,{"C5_GERAWMS"	,"2"				,Nil})
				aadd(aSC5,{"C5_XNUMINT"	,cNumPed			,Nil})
	  			aadd(aSC5,{"C5_TESINT" 	,SC5->C5_TESINT		,Nil})
	  			//aadd(aSC5,{"C5_XCODMNF"	,cNumObs			,Nil})  // war 05/03/2020
	  			aadd(aSC5,{"C5_XMSGNF"	,_cObs				,Nil})
	  			aadd(aSC5,{"C5_XCODMNF"	,cCODSYP			,Nil})	  			
	  			
	  			cCODSYP := ""
				_cObs 	:= ""
				_aSYP 	:= {}
				
	            While (cTPED)->(!Eof()) .And. SC5->C5_NUM == (cTPED)->C5_NUM
					DbSelectArea("SC6")
					DbGoTo((cTPED)->SC6RECNO)
// war 07/02/2020	  				
					xFilAnt	:= cFilAnt
					xNumEmp	:= cNumEmp
					cFilAnt	:= "04"
					cNumEmp	:= cEmpAnt+cFilAnt
										
					dbSelectArea("SM0")
					If Select( "SM0" ) > 0
						SM0->( dbCloseArea() )
					EndIf
					OpenSM0(cEmpAnt+cFilAnt)
// war 07/02/2020					
					
					cTES:= u_CALCSZT("AUT",SC6->C6_PRODUTO,SC5->C5_CLIENTE,SC5->C5_LOJACLI,SC5->C5_TESINT)	// por Icaro Queiroz em 11/Fev/2015
					
// war 07/02/2020					
					cFilAnt	:= xFilAnt
					cNumEmp	:= cEmpAnt+cFilAnt
										
					dbSelectArea("SM0")

					If Select( "SM0" ) > 0
						SM0->( dbCloseArea() )
					EndIf

					OpenSM0(cEmpAnt+cFilAnt)
// war 07/02/2020
										
					IF EMPTY(cTES)
						cLOG:= ""
						cLOG += "Pedido: " + cNumPed + " tem produto (" + AllTrim(SC6->C6_PRODUTO) + ") sem a TES localizada. Pedido nao processado"
						cLOG += CRLF
						ProcLogAtu("ALERTA","Aviso de Inconsistencias",	cLog, cLogID )
						lTES := .F.
						EXIT
					ENDIF
					
					aAdd(aSC6,{	{"C6_ITEM"		,SC6->C6_ITEM		,NIL},;
								{"C6_PRODUTO"	,SC6->C6_PRODUTO	,NIL},;
								{"C6_QTDVEN"	,SC6->C6_QTDVEN		,NIL},;
								{"C6_PRCVEN"	,SC6->C6_PRCVEN		,NIL},;
								{"C6_PRUNIT"	,SC6->C6_PRUNIT		,NIL},;
								{"C6_TES"		,cTES				,NIL},;
								{"C6_LOCAL"		,SC6->C6_LOCAL		,NIL},;
								{"C6_ITEMPC"	,SC6->C6_ITEMPC		,NIL},;
								{"C6_NUMPCOM"	,SC6->C6_NUMPCOM	,NIL},;
								{"C6_PEDCLI"	,SC6->C6_PEDCLI		,Nil}})
// war 4/2/2020	Pedido de compras				
					/*
					aAdd(aSC6,{	{"C6_ITEM"		,SC6->C6_ITEM		,NIL},;
								{"C6_PRODUTO"	,SC6->C6_PRODUTO	,NIL},;
								{"C6_QTDVEN"	,SC6->C6_QTDVEN		,NIL},;
								{"C6_PRCVEN"	,SC6->C6_PRCVEN		,NIL},;
								{"C6_PRUNIT"	,SC6->C6_PRUNIT		,NIL},;
								{"C6_TES"		,cTES				,NIL},;
								{"C6_LOCAL"		,SC6->C6_LOCAL		,NIL},;
								{"C6_PEDCLI"	,SC6->C6_PEDCLI		,Nil}})
					
					*/
// war 4/2/2020
								
					(cTPED)->(DbSkip())				                                                    
				EndDo	
	           
	            MostraErro("\log\","err.log")
	                   
	  			lMsErroAuto:=.F.
				
				If lTES  			
					
					If LoadCols( @aToSC6, aSC6, cTMKRJCL, cTMKRJLJ, "05" )

			  			cFilPRE := cFilAnt
		  				cFilAnt := cFilPara  
					
						MATA410( aSC5, aSC6, 3 )//Gera Pedido na Filial 04 - Destino
	                
						If lMsErroAuto
							cFilAnt := cFilPRE
							MostraErro("\log\","intpv.log")
							cErroPV := Memoread("\log\intpv.log")
							ProcLogAtu("ERRO","Pedido: " + cFilDe + "-" + cNumPed ,cErroPV,cLogID)
						Else
							
							ConfirmSX8()
							cNewSC5 := SC5->C5_NUM
							cFilAnt := cFilPRE
	
							AADD( aNewSC5, { nRecSC5, cFilDe  ,cNumPed, cFilPara, cNewSC5 } )
							AADD( aPVOk, { aClone(aSC5), aClone(aSC6) } )
					
							cLOG += "Pedido gerado: Origem: " + cFilDe + "-" + cNumPed + "/ Destino: " + cFilPara + "-" + cNewSC5 + "." + CRLF
							//LoadCols( @aToSC6, aSC6, SC5->C5_CLIENTE, SC5->C5_LOJACLI, "05" )
						EndIf
				    EndIf
				Else
					(cTPED)->(DbSkip())			
				EndIf  
			EndIf									
        EndDo
		
		If !Empty(aToSC6)
	   		lMsErroAuto := .F.               
	   		cFilAnt := cFilDe
			aToSC5 	:=	{	{"C5_TIPO"     	,"N"   				,Nil},;
							{"C5_CLIENTE"  	,cTMKRJCL			,Nil},;
							{"C5_LOJACLI"  	,cTMKRJLJ			,Nil},;
							{"C5_CLIENT"  	,cTMKRJCL		 	,Nil},;
							{"C5_LOJAENT"  	,cTMKRJLJ			,Nil},;
							{"C5_TRANSP"	,AllTrim(cTRANSP)	,Nil},;
							{"C5_TIPOCLI"	,"S"				,Nil},;
							{"C5_CONDPAG"	,cTMKRJCP			,Nil},;
							{"C5_TIPOENT"	,cTMKRJTE			,Nil},;
							{"C5_FORMPAG"	,cTMKRJFP			,NIL},;
							{"C5_VEND1"		,cVDTRANS			,NIL},;
							{"C5_TABELA"	,cTMKRJTB			,Nil},;
							{"C5_EMISSAO"  	,dDataBase			,Nil},;
							{"C5_TPFRETE"  	,cTMKRJTF			,Nil},;
							{"C5_MOEDA"  	,1					,Nil},;
							{"C5_TXMOEDA"  	,1.000				,Nil},;
							{"C5_CDPG"		,"BOLETO"			,Nil},;
							{"C5_PEDREP"	,cPedRep			,Nil},;
							{"C5_ORCAM"		,"P"				,Nil},;
							{"C5_MENPAD"  	,""					,Nil},;
							{"C5_TESINT"  	,"05"				,Nil},;  
							{"C5_TPCARGA"	,"1"				,Nil},;
							{"C5_GERAWMS"  	,"2"				,Nil}}
    
			MATA410( aToSC5, aToSC6 ,3 )//Gera Pedido de Transferencia na Filial 01
			
			If lMsErroAuto

				MostraErro("\log\","intpv.log")
				cErroPV := Memoread("\log\intpv.log")
				ProcLogAtu("ERRO","Pedido Transferencia: "+cFilDe +"-"+cNumPed ,cErroPV,cLogID)
				cTrfSC5 := ""

			Else 
				ConfirmSX8()
				cTrfSC5 := SC5->C5_NUM
				cLOG += "Pedido de transferencia gerado: " + cFilDe  + "-" + cTrfSC5 + "." + CRLF

				cInfoAlt := ProcAltPV( cFilDe, cTrfSC5, @aPVOk, aNewSC5 )
				ProcLogAtu( "MENSAGEM", "Estorno", cInfoAlt, cLogID )

				/*cInfoDel := ProcDelPV( cFilDe, cTrfSC5, aPVOk, aNewSC5 )
				ProcLogAtu( "MENSAGEM", "Exclusão", cInfoDel, cLogID )*/

			EndIf		

		EndIf
		
		ProcLogAtu("MENSAGEM","Log", cLOG,cLogID)
		ProcLogAtu("FIM",cTrfSC5,"Pedido de transferencia: "+cTrfSC5,cLogID)                            
		Aviso("INTRJ","Processo finalizado." + CRLF + "Visualize o log para detalhes.",{"OK"},2)
	
	EndIf
		

EndIf

Return


//-------------------------------------------------------------------------------------
/*/{Protheus.doc} LOADCOLS  

Carrega SC6 para Pedido de Transferencia                   
*/

Static Function LoadCols( aToSC6, aSC6, cCliente, cLoja, cTesint )

	Local nI := 0
	Local cTes05:= ""
	Local lTes:= .T.
	Local lPrc:= .T.
	Local cLOG:= ""
	Local cTabTrf:= SubStr(AllTrim(GetMV("FS_TMKRJTB")),1,3)	//Tabela de Preco Padrao
	
	For nI := 1 to Len(aSC6)
		nScan := aScan(aToSC6,{|x| x[02][02] == aSC6[nI][02][02]} )
		If nScan > 0
			aToSC6[nScan][03][02] += aSC6[nI][03][02]
		Else   
			cTES05	:= u_CALCSZT("AUT",aSC6[nI][02][02],cCliente,cLoja,cTesint)
			
			IF EMPTY(cTES05)
				cLOG:= ""
				cLOG += "Pedido: " + cNumPed + " tem produto (" + AllTrim(aSC6[nI][02][02]) + ") sem a TES localizada. Pedido nao processado. Transferencia."
				cLOG += CRLF
				lTES := .F.
				ProcLogAtu("ALERTA","Aviso de Inconsistencias",	cLog, cLogID )
				EXIT
			ENDIF
			
			cItem   := Soma1(cItem)
			
			//////// war 4/2/2020
			nPrcTab := GetAdvFVal("DA1","DA1_PRCVEN",xFilial("DA1")+aSC6[nI][02][02]+cTabTrf,2,0) 
			
			IF EMPTY(nPrcTab)
				cLOG:= ""
				cLOG += "Pedido: " + cNumPed + " tem produto (" + AllTrim(aSC6[nI][02][02]) + ") sem preco. Pedido não processado. Transferencia."
				cLOG += CRLF
				lPrc := .F.
				ProcLogAtu("ERRO","Aviso de Inconsistencia", cLog, cLogID )
				EXIT
			ENDIF
			//////// war 4/2/2020
			
			aAdd(aToSC6,{	{"C6_ITEM"		,cItem				,NIL},;
							{"C6_PRODUTO"	,aSC6[nI][02][02]	,NIL},;
							{"C6_QTDVEN"	,aSC6[nI][03][02]	,NIL},;
							{"C6_PRCVEN"	,nPrcTab			,NIL},;
							{"C6_PRUNIT"	,nPrcTab			,NIL},;
							{"C6_TES"		,cTes05				,NIL},;
							{"C6_LOCAL"		,"01"		   		,NIL},;
							{"C6_SERVIC"	,"001"				,NIL},;
							{"C6_ENDPAD"	,"DOCA"				,NIL}})
						
			/*
			aAdd(aToSC6,{	{"C6_ITEM"		,cItem				,NIL},;
							{"C6_PRODUTO"	,aSC6[nI][02][02]	,NIL},;
							{"C6_QTDVEN"	,aSC6[nI][03][02]	,NIL},;
							{"C6_PRCVEN"	,aSC6[nI][04][02]	,NIL},;
							{"C6_PRUNIT"	,aSC6[nI][05][02]	,NIL},;
							{"C6_TES"		,cTes05				,NIL},;
							{"C6_LOCAL"		,"01"		   		,NIL},;
							{"C6_SERVIC"	,"001"				,NIL},;
							{"C6_ENDPAD"	,"DOCA"				,NIL}})
			*/
		EndIf
	Next
	
Return(lTES .And. lPrc)
 
//-------------------------------------------------------------------------------------
/*/{Protheus.doc} PROALTPV

Estorno do Pedido de Venda Origem                          
*/

Static Function ProcAltPV( cFilDe, cTrfSC5, aPVOk, aNewSC5 )
	Local lRet		:= .T.
	Local cLogAlt 	:= ""
	Local Nx        := 0
	Local nPos 		:= 2

	For Nx := 1 To Len(aPVOk)   
		DbSelectArea("SC5")
		DbGoTo( aNewSC5[Nx][01] )

		cNumPed := SC5->C5_NUM 

		AIns( aPVOk[Nx][1], nPos )
		aPVOk[Nx][1][nPos] := {"C5_NUM",cNumPed,Nil}
		AADD(aPVOk[Nx][01],{"C5_XNUMTRF",cTrfSC5,nil})
		AADD(aPVOk[Nx][01],{"C5_XNUMINT",aNewSC5[Nx][05],nil})

		lMsErroAuto := .F. 		

		MATA410( aPVOk[Nx][01], aPVOk[Nx][02], 4 )

		If lMsErroAuto  
			MostraErro("\log\","intRJ.log")
			cErroPV := Memoread("\log\intRJ.log")
			ProcLogAtu("ERRO","Estorno de Pedido: "+cFilDe +"-"+cNumPed, cErroPV, cLogID )
			cLogAlt += "Pedido nao estornado: "+cFilDe +"-"+cNumPed + "."+CRLF
			lRet  := .F.		   

		Else
		
			//grava informações dos pedidos de transferencia e pedido gerado na filial do rio no pedido originário do TMK
			//Alteração por Bia Ferreira - EthosX - 17/01/2020
			
			DbSelectArea("SUA")
            SUA->(DbSetOrder(8))
			If SUA->(DbSeek(xFilial("SUA") + aPVOk[Nx][01][02][02] ) )
				SUA->(RecLock( "SUA", .F. ))
				SUA->UA_XNUMINT := aNewSC5[Nx][05]
				SUA->(MsUnLock())
			EndIf
			
			// Fim //
			
            SC5->(DbSetOrder(1))
			If SC5->(DbSeek(aNewSC5[Nx][04] + aNewSC5[Nx][05]) ) //Gravacao do pedido de transferencia no pedido destino
				SC5->(RecLock( "SC5", .F. ))
				SC5->C5_XNUMTRF	:= cTrfSC5
				SC5->(MsUnLock())
			EndIf

			cLogAlt += "Pedido estornado: " + cFilDe + "-" + cNumPed + "." + CRLF
			
		EndIf	

	Next   

	If lRet 	
		LibPV( cTrfSC5 )
	EndIf

	MsUnlockAll()
Return( cLogAlt )

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} LIBPED    

Libera o Pedido de Vendas                                  
*/

Static Function LibPV(cPv)

	Local _cNumPed   := cPv
	
	DbSelectArea("SC5")
	SC5->(dbSetOrder(1)) // C5_FILIAL + C5_NUM
	If MsSeek(xFilial("SC5")+_cNumPed)
	
		DbSelectArea("SC6")
		SC6->(dbSetOrder(1)) // C6_FILIAL + C6_NUM + C6_ITEM + C6_PRODUTO
		If MsSeek(xFilial("SC6")+_cNumPed+"01") // Posiciono no primeiro item do pedido
		
			While !SC6->(EOF()) .And. SC6->C6_NUM == _cNumPed
				
				If RecLock("SC5")
					nQtdLib := SC6->C6_QTDVEN
					
					//-----------------------------------
					//--Recalcula a Quantidade Liberada--
					//-----------------------------------
					RecLock("SC6") // Forca a atualizacao do Buffer no Top
					
					//-------------------------------------------------------------------------------------------------------
					// Libera por Item de Pedido       																	 ----	
					//-------------------------------------------------------------------------------------------------------
					// Este comando define que as operações seguintes, delimitadas pelo comando END TRANSACTION,       ----
					// devem ser processadas como uma transação, ou seja, como um bloco único e indivisível. Durante  ----
					// uma recuperação de falha, todas as operações de manipulação de dados realizadas serão      ----
					// integralmente desfeitas, além de prover isolamento entre acessos concorrentes na mesma massa de  ----
					// dados.                                                                                            ----
					//-------------------------------------------------------------------------------------------------------
					Begin Transaction
					
						/*
						------------------------------------------------------------------------------------
						---- Descricao : Liberacao dos Itens de Pedido de Venda                      ------
						------------------------------------------------------------------------------------
						----  Retorno  : ExpN1: Quantidade Liberada                                  ------
						------------------------------------------------------------------------------------
						---- Transacao : Nao possui controle de Transacao a rotina chamadora deve    ------
						----             controlar a Transacao e os Locks                            ------
						------------------------------------------------------------------------------------
						---- Parametros ExpN1: Registro do SC6                                      ------
						----            ExpN2: Quantidade a Liberar                                 ------
						----            ExpL3: Bloqueio de Credito                                  ------
						----            ExpL4: Bloqueio de Estoque                                  ------
						----            ExpL5: Avaliacao de Credito                                 ------
						----            ExpL6: Avaliacao de Estoque                                 ------
						----            ExpL7: Permite Liberacao Parcial                            ------
						----            ExpL8: Tranfere Locais automaticamente                      ------
						----            ExpA9: Empenhos ( Caso seja informado nao efetua a gravacao ------
						----                   apenas avalia ).                                     ------
						----            ExpbA: CodBlock a ser avaliado na gravacao do SC9           ------
						----            ExpAB: Array com Empenhos previamente escolhidos            ------
						----                   (impede selecao dos empenhos pelas rotinas)          ------
						----            ExpLC: Indica se apenas esta trocando lotes do SC9          ------
						----            ExpND: Valor a ser adicionado ao limite de credito          ------
						----            ExpNE: Quantidade a Liberar - segunda UM                    ------
						------------------------------------------------------------------------------------
						*/
						MaLibDoFat(SC6->(RecNo()),@nQtdLib)
					End Transaction
				
				EndIf
				
				SC6->(MsUnLock())
				
				//*************************************
				// Atualiza o Flag do Pedido de Venda |
				//*************************************
				Begin Transaction
					SC6->(MaLiberOk({_cNumPed},.F.))
				End Transaction
				
				dbSelectArea("SC6")
				SC6->(dbSkip())
			EndDo
			
			SC5->(MsUnLock())
		EndIf        
	EndIf
		
Return

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} ProcLogView

Visualizacao do Log de Processamento da Rotina          
*/

Static Function ProcLogView()

	Local aAreaAnt  := GetArea()
	Private aRotina := ProcLogDet()

	DbSelectArea("CV8")
	DbSetOrder(1)  
	
	MaWndBrowse(0,0,500,880,"Log de Processamento" + " - " + cCadastro,"CV8",,aRotina,"CV8->CV8_INFO=='4'",;
		'xFilial("CV8")+"' + __BatchProc + '"',;
		'xFilial("CV8")+"' + __BatchProc + 'zzzzzzzzzzz"',;
		.T.,{{"OK","Avisos"},{"CANCEL","Erros de Processamento"}},2,{{"Data+Hora",1},{"Usuario+Data+Hora",2}},xFilial("CV8") + __BatchProc)

	RestArea(aAreaAnt)

Return          

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} ProLogDet 

Detalhe do Log de Processamento da Integracao dos Pedidos Entre as Filiais                                          
*/

Static Function ProcLogDet()

	Local aAreaAnt  := GetArea()
	Local aRotina   := {}
	
	DbSelectArea( "CV8" )
	nRecno := CV8->( Recno() )
	DbSetOrder(1)

	If DbSeek( xFilial( 'CV8' ) + ALLTRIM( __BatchProc ) )
		aRotina := {{ "Log","U_XVisCV8", Recno() , 3}}
	EndIf
	
	CV8->( DBGOTO( nRecno ) )
	
	RestArea(aAreaAnt)
Return( aRotina )

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} XVisCV8

Tela de Visualizacao do Log                       
*/

User Function XVisCV8()

	Local oArea		   		:= FWLayer():New()
	Local aCoord			:= {0,0,550,1000}//FWGetDialogSize(oMainWnd)
	//Local lMDI				:= oAPP:lMDI
	//Local aTamObj			:= Array(4)
	//Local oOk 				:= LoadBitmap(GetResources(),"LBOK")
	//Local oNo 				:= LoadBitmap(GetResources(),"LBNO")
	
	//Local nOpcA		  		:= 0
	Local bOk				:= {|| oMainDlg:End() }
	//Local aButtons			:= {}
	//Local aTamCpo			:= {}
	//Local nA				:= 0
	//Local nI				:= 0
	//Local cNomDep			:= ""
	//Local oFont		  		:= TFont():New("Arial",08,10,,.T.,,,,.T.)
	
	//Local oButt1,oButt2
	Local aSize     	:= {}
	Local aArea     	:= GetArea()
	Local aInfo     	:= {}
	Local aObjects  	:= {}
	Local aPosObj 		:= {}
	//Local bChange   	:= {|| }
	//Local aCols1    	:= {}
	//Local aFields   	:= {}
	//Local aField    	:= {}
	//Local aFieldEdit	:= {}
	//Local aCpoEnch  	:= {}
	//Local aPos 	    	:= {012,005,200,600}
	//Local aCpoH     	:= {}
	//Local cDescView 	:= ""
	//Local aCombo    	:= {}
	//Local aPerg     	:= {}
	//Local aParam    	:= Array(1)
	//Local aView     	:= {}
	//Local nLimit    	:= 9999
	//Local oEnt1,oEnt2
	
	cCadastro := ""

	//resoluçao 1280 x 768
	aSize:= {0,0,608.5,270,1217,563,0}

	aInfo := {aSize[1],aSize[2],aSize[3],aSize[4],3,3}

	AADD(aObjects,{100,30,.T.,.F.})
	AADD(aObjects,{100,100,.T.,.T.})
	aPosObj := MsObjSize(aInfo, aObjects)

	aScreen   := GetScreenRes()
	aScreen[1]:= aScreen[1]-20
	aScreen[2]:= aScreen[2]-20

	aCoord[3] *= 0.95
	aCoord[4] *= 0.9

	oMainDlg := tDialog():New(aCoord[1],aCoord[2],aCoord[3],aCoord[4],OemToAnsi(cCadastro),,,,,CLR_BLACK,CLR_WHITE,,,.T.)
	oArea:Init(oMainDlg,.F.)
	//Mapeamento da area
	oArea:AddLine("L01",100,.T.)

	//-----------
	//--Colunas--
	//-----------
	oArea:AddCollumn("L01C01",90,.F.,"L01") //dados
	oArea:AddCollumn("L01C02",10,.F.,"L01") //botoes

	//-----------
	//--Paineis--
	//-----------
	oArea:AddWindow("L01C01","LIST","Detalhes",100,.F.,.F.,/*bAction*/,"L01",/*bGotFocus*/)
	oList	:= oArea:GetWinPanel("L01C01","LIST","L01")

	aInfo:= {}            
	
	aCol := { 002, 067, 200 }    

	AADD(aInfo,"INICIO") // Inicio do Processamento
	AADD(aInfo,"FIM") // Final do Processamento
	AADD(aInfo,"ALERTA") // Alerta
	AADD(aInfo,"ERRO") // Erro 
	AADD(aInfo,"CANCEL") // Cancelado pelo usuario
	AADD(aInfo,"MENSAGEM") // Mensagem
	
	cInfo := aInfo[Val(CV8->CV8_INFO)]     
	         
	@ 002,aCol[01] SAY "Data" Pixel Of oList
	@ 002,aCol[02] SAY "Hora" Pixel Of oList
	@ 032,aCol[01] SAY "Usuario" Pixel Of oList
	@ 032,aCol[02] SAY "Mensagem" Pixel Of oList
	@ 062,aCol[01] SAY "Processo" Pixel Of oList
	@ 062,aCol[02] SAY "Tipo" Pixel Of oList
	
	@ 010,aCol[01] MSGET oData VAR CV8->CV8_DATA SIZE 060,08 Pixel Of oList READONLY
	@ 010,aCol[02] MSGET oHora VAR CV8->CV8_HORA SIZE 060,08 Pixel Of oList READONLY
	@ 040,aCol[01] MSGET oUser VAR CV8->CV8_USER SIZE 060,08 Pixel Of oList READONLY
	@ 040,aCol[02] MSGET oMsg  VAR CV8->CV8_MSG  SIZE 120,08 Pixel Of oList READONLY
	@ 070,aCol[01] MSGET oProc VAR CV8->CV8_PROC SIZE 060,08 Pixel Of oList READONLY
	@ 070,aCol[02] MSGET oInfo VAR cInfo         SIZE 080,08 Pixel Of oList READONLY

	@ 002,aCol[03] SAY "Detalhe" Pixel Of oList
	@ 010,aCol[03] GET oInfo VAR CV8->CV8_DET MEMO SIZE 190,220 Pixel Of oList READONLY

	oArea:AddWindow("L01C02","L01C02P01","Funcoes",100,.F.,.F.,/*bAction*/,"L01",/*bGotFocus*/)
	oAreaBut := oArea:GetWinPanel("L01C02","L01C02P01","L01")

	//--------------------
	//--Painel 03-Botoes--
	//--------------------
	oButt1 := tButton():New(000,000,"&Ok"	,oAreaBut,bOk		,oAreaBut:nClientWidth/2,15,,/*oFont*/,,.T.,,,,/*bWhen*/)

	oMainDlg:Activate(,,,.T.,/*valid*/,,/*On Init*/)
		
	RestArea(aArea)
Return

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} CHKTABPRECO

Validacao da Tabela de Preco
*/

Static Function CHKTabPreco( oProc, aTabxProd , aOcorr )

	Local lRet 	:= .T.
	Local Nx 	:= 0
	Local nTabs := Len( aTabxProd ) 
	Local nScan := 0 
	
	DbSelectArea("DA0")
	DbSetOrder(1)
	
	For Nx := 1 To nTabs
		oProc:IncRegua2("Tabelas de precos : Filial : " + aTabxProd[Nx][02] + " - Tabela: " + aTabxProd[Nx][04] )
		If DbSeek( aTabxProd[Nx][02] + aTabxProd[Nx][04] )    	
        	If !Empty(DA0->DA0_DATATE) .And. dDataBase > DA0->DA0_DATATE
				nScan := aScan(aOcorr,{|x| x[01] == aTabxProd[nx][01] .And. x[02] == aTabxProd[nx][02] .And. x[03] == aTabxProd[nx][03] .And. x[04] == aTabxProd[nx][04]} )        		
	        	If nScan == 0
		        	AADD( aOcorr, { aTabxProd[Nx][01],; 
									aTabxProd[Nx][02],;
									aTabxProd[Nx][03],;
									aTabxProd[Nx][04],;
									"---------------",;
			       					"Fora da vigencia - " + Dtoc(DA0->DA0_DATATE) })
				EndIf
			EndIf
		EndIf	
	Next


	DbSelectArea("DA1")
	DbSetOrder(1)
	
	For Nx := 1 To nTabs
		oProc:IncRegua2("Tabelas de precos : Filial : "+aTabxProd[Nx][02] +" - Tabela: "+aTabxProd[Nx][04] )
		If !DbSeek( aTabxProd[Nx][02] + aTabxProd[Nx][04] + aTabxProd[Nx][05] )    	
        	AADD( aOcorr, { aTabxProd[Nx][01],; 
							aTabxProd[Nx][02],;
							aTabxProd[Nx][03],;
							aTabxProd[Nx][04],;
							aTabxProd[Nx][05],;
        					"Inexistente"    })
		EndIf	
	Next
	
	lRet := Empty( aOcorr )
	
Return( lRet )
              
//-------------------------------------------------------------------------------------
/*/{Protheus.doc} VisErro
Visualização de erros em tabelas de preco.

@type 		function
@author 	Roberto Souza
@since 		01/02/2017
@version 	P11 
 
@return nil
/*/    
//-------------------------------------------------------------------------------------
Static Function VisErro( aCab , aOcorr )

	Local lRet 		:= .F.
	//Local oDlgList
	//Local oList1
	//Local oList2 
	Local aItems   			:= aClone( aOcorr )
	Local oArea		   		:= FWLayer():New()
	Local aCoord			:= {0,0,550,1000}//FWGetDialogSize(oMainWnd)
	//Local lMDI				:= oAPP:lMDI
	//Local aTamObj			:= Array(4)
	
	//Local nOpcA		  		:= 0
	Local bOk				:= {|| lRet := .T.,oMainDlg:End() }
	Local bCancel			:= {|| lRet := .F.,oMainDlg:End() }

	Local oFont		  		:= TFont():New("Arial",08,12,,.T.,,,,.T.)
	
	Local oButt1,oButt2
	Local aSize     	:= {}
	Local aArea     	:= GetArea()
	Local aInfo     	:= {}
	Local aObjects  	:= {}
	Local aPosObj 		:= {}
	//Local aPos 	    	:= {012,005,200,600}
	//Local aCpoH     	:= {}
	//Local cDescView 	:= ""
	//Local aCombo    	:= {}
	//Local aPerg     	:= {}
	//Local aParam    	:= Array(1)

	//resoluçao 1280 x 768
	aSize:= {0,0,608.5,270,1217,563,0}

	aInfo := {aSize[1],aSize[2],aSize[3],aSize[4],3,3}

	AADD(aObjects,{100,30,.T.,.F.})
	AADD(aObjects,{100,100,.T.,.T.})
	aPosObj := MsObjSize(aInfo, aObjects)

	aScreen   := GetScreenRes()
	aScreen[1]:= aScreen[1]-20
	aScreen[2]:= aScreen[2]-20

	aCoord[3] *= 0.95
	aCoord[4] *= 0.9

	oMainDlg := tDialog():New(aCoord[1],aCoord[2],aCoord[3],aCoord[4],"Divergencias",,,,,CLR_BLACK,CLR_WHITE,,,.T.)
	oArea:Init(oMainDlg,.F.)
	//Mapeamento da area
	oArea:AddLine("L01",100,.T.)

	//-----------
	//--Colunas--
	//-----------
	oArea:AddCollumn("L01C01",90,.F.,"L01") //dados
	oArea:AddCollumn("L01C02",10,.F.,"L01") //botoes

	//-----------
	//--Paineis--
	//-----------
 	oArea:AddWindow("L01C01","TEXT","Informacoes",020,.F.,.F.,/*bAction*/,"L01",/*bGotFocus*/)
	oText	:= oArea:GetWinPanel("L01C01","TEXT","L01")
 
	oArea:AddWindow("L01C01","LIST","Detalhes",080,.F.,.F.,/*bAction*/,"L01",/*bGotFocus*/)
	oList	:= oArea:GetWinPanel("L01C01","LIST","L01")
                                        
	@ 002,005 SAY "Existem divergencias entre as listas de precos dos pedidos origem e pedido destino." FONT oFont COLOR CLR_BLUE Pixel Of oText
	@ 010,005 SAY "Abaixo estao listadas as tabelas e produtos que nao foram encontradas para gerar os pedidos." FONT oFont COLOR CLR_BLUE Pixel Of oText
	@ 018,005 SAY "Deseja continuar e ignorar os pedidos que possuem itens com divergencias?" FONT oFont COLOR CLR_BLUE Pixel Of oText

	@ 000,000 LISTBOX oLbx FIELDS HEADER "Local","Filial","Pedido", "Tabela","Produto", "Detalhe";
		COLSIZES 30,20,30,30,40 ;
	   	SIZE 230,095 OF oList PIXEL
	
	oLbx:SetArray( aItems )
	oLbx:bLine := {|| { aItems[oLbx:nAt,1] ,;
						aItems[oLbx:nAt,2] ,;
						aItems[oLbx:nAt,3] ,;
						aItems[oLbx:nAt,4] ,;
						aItems[oLbx:nAt,5] ,;
						aItems[oLbx:nAt,6] }}	

	oLbx:Align    := CONTROL_ALIGN_ALLCLIENT

	oArea:AddWindow("L01C02","L01C02P01","Funcoes",100,.F.,.F.,/*bAction*/,"L01",/*bGotFocus*/)
	oAreaBut := oArea:GetWinPanel("L01C02","L01C02P01","L01")

	//--------------------
	//--Painel 03-Botoes--
	//--------------------
	oButt1 := tButton():New(000,000,"&Continuar"	,oAreaBut,bOk		,oAreaBut:nClientWidth/2,15,,/*oFont*/,,.T.,,,,/*bWhen*/)
	oButt2 := tButton():New(016,000,"&Cancelar"		,oAreaBut,bCancel	,oAreaBut:nClientWidth/2,15,,/*oFont*/,,.T.,,,,/*bWhen*/)

	oMainDlg:Activate(,,,.T.,/*valid*/,,/*On Init*/)
		
	RestArea(aArea)

Return( lRet )

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} IntRjMe
Monta o texto conforme foi digitado pelo operador e quebra 
as linhas no tamanho especificado sem cortar palavras e    
devolve um array com os textos a serem impressos.          

Parametros: cCodigo - Codigo de referencia da gravacao do memo 
			nTaM    - Tamanho maximo de colunas do texto       
*/

Static Function IntRjMe(cCodigo,nTam)

Local cString := MSMM(cCodigo,nTam)	// Carrega o memo da base de dados
Local nI	  := 0    				// Contador dos caracteres
Local nJ	  := 0    				// Contador dos caracteres
Local nL	  := 0					// Contador das linhas
Local cLinha  := ""					// Guarda a linha editada no campo memo
Local aLinhas := {}					// Array com o memo dividido em linhas

For nI := 1 TO Len(cString)
	If (MsAscii(SubStr(cString,nI,1)) <> 13) .AND. (nL < nTam) // MsAscii
		// Enquanto não houve enter na digitacao e a linha nao atingiu o tamanho maximo
		cLinha+=SubStr(cString,nI,1)
		nL++
	Else
		// Se a linha atingiu o tamanho maximo ela vai entrar no array
		If MsAscii(SubStr(cString,nI,1)) <> 13
			nI--
			For nJ := Len(cLinha) To 1 Step -1
				// Verifica se a ultima palavra da linha foi quebrada, entao retira e passa pra frente
				If SubStr(cLinha,nJ,1) <> " "
					nI--
					nL--
				Else
					Exit
				Endif
			Next nJ
			// Se a palavra for maior que o tamanho maximo entao ela vai ser quebrada
			If nL <=0
				nL := Len(cLinha)
			Endif
		Endif
		
		// Testa o valor de nL para proteger o fonte e insere a linha no array
		If nL >= 0
			cLinha := SubStr(cLinha,1,nL)
			AAdd(aLinhas, cLinha)
			cLinha := ""
			nL := 0
		Endif
	Endif
Next nI

// Se o nL > 0, eh porque o usuario nao deu enter no fim do memo e eu adiciono a linha no array.
If nL >= 0
	cLinha := SubStr(cLinha,1,nL)
	AAdd(aLinhas, cLinha)
	cLinha := ""
	nL := 0
Endif

Return(aLinhas)
