#INCLUDE "PROTHEUS.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³M410LIOK  ºAutor  ³Eletromega          º Data ³  12/21/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Ponto de entrada: VALIDACAO DE LINHA DO PEDIDO VENDA       º±±
±±º          ³                                                            º±± 
±±º          ³ Retorno : validando (.T.) ou nao (.F.) a linha             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP8                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function M410LiOk()

Local nPProd     	:= aScan(aHeader,{ |x| Upper(AllTrim(x[2])) == "C6_PRODUTO" })
Local nPosItem   	:= aScan(aHeader,{ |x| Upper(AllTrim(x[2])) == "C6_ITEM" }) 
Local nPosTes    	:= aScan(aHeader,{ |x| Upper(AllTrim(x[2])) == "C6_TES" })
Local nPosLocal  	:= aScan(aHeader,{ |x| Upper(AllTrim(x[2])) == "C6_LOCAL" })
Local nPQtd      	:= aScan(aHeader,{ |x| Upper(AllTrim(x[2])) == "C6_QTDVEN" })
Local nPosPedCli 	:= aScan(aHeader,{ |x| Upper(AllTrim(x[2])) == "C6_PEDCLI" }) 
Local nPosPrcVen 	:= aScan(aHeader,{ |x| Upper(AllTrim(x[2])) == "C6_PRCVEN" })
Local nPosComis1 	:= aScan(aHeader,{ |x| Upper(AllTrim(x[2])) == "C6_COMIS1" })
Local nPosVlCom1 	:= aScan(aHeader,{ |x| Upper(AllTrim(x[2])) == "C6_VLCOM1" })
Local nPosValor 	:= aScan(aHeader,{ |x| Upper(AllTrim(x[2])) == "C6_VALOR" })
Local nPosEnd 		:= aScan(aHeader,{ |x| Upper(AllTrim(x[2])) == "C6_LOCALIZ" })
Local nPosTip 		:= aScan(aHeader,{ |x| Upper(AllTrim(x[2])) == "C6_TIPO" }) // Maurício Aureliano - 29/06/2018 - Chamado I1806-3231
Local nDecs		 	:= TamSx3("C6_VLCOM1")[2]
Local cTes      	:= SuperGetMv("FS_ELE009") 

Local nSaldoSB2		:= 0 
Local nQtdVen   	:= 0
Local nComis		:= 0
Local lRet 			:= .T.
Local cMsgErro  	:= ""
Private cProdSG1	:= ""

// Rotina Automatica SFA
If Type("L410Auto")!="U" .And. L410Auto
	If !U_xAuto410()
		Return (.T.)
	EndIf
EndIf
 
IsSFA := IsBlind() .And. !Empty(M->C5_YCDPALM)

If Type( '_nPosVlr' ) = 'U' 
   
   U_M410Get()

EndIf

If !aCols[n][Len(aHeader)+1]
	
	If lRet .And. SubString(aCols[n][nPosPedCli],1,3)=="TMK" .And. !U_IsAdm() .And. !UPPER(cUserName) $ "ADV|COORDVENDAS" .And. !IsInCallStack("U_INTRJ")
    	
    	lRet := .F.
    	//ApMsgStop( 'Pedidos digitados pelo Call Center nao podem ser alterados!', 'M410LIOK' )
    	//Amedeo Fabritech (Ajuste para mensagem Portal de 4Sales)
		Aviso( "Aviso", 'Pedidos digitados pelo Call Center nao podem ser alterados!', {"Ok"} )
    	
    EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Nao permite a digitacao de produtos duplicados no aCols ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lRet .And. !U_IsAdm() .And. !IsInCallStack("U_INTPV")
		For nI := 1 to Len( aCols )		
			If !aCols[nI][Len(aHeader)+1] .AND. n <> nI
				If aCols[n][nPProd] == aCols[nI][nPProd]
					//ApMsgStop( 'Produto já selecionado.', 'M410LIOK' )
					//Amedeo Fabritech (Ajuste para mensagem Portal de 4Sales)
					Aviso( "Aviso", 'Produto já selecionado.', {"Ok"} )
					lRet := .F.
					Exit
				EndIf
			EndIf                  
		Next
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se tem saldo suficiente para faturamento       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	// Alert(SC5->C5_TIPO)
	
	//*** Data 06/11/2020 - Sol. Fernando Medeiros/Roberto - Incluir Regra para PERMITIR digitar Pedido de Venda sem validar o Saldo de Estoque p/TES Intelig = "03"
	//*** Autor Andre Salgado - 06/11/2020
	//If lRet .And. !U_IsAdm() .And. !M->C5_TIPO $ "IPC" //versao anterior

	

	If lRet .And. !U_IsAdm() .And. !M->C5_TIPO $ "IPC" .AND. !M->C5_TESINT $ "03,13"	//nova versao
	//If lRet .And. !M->C5_TIPO $ "IPC" .AND. !M->C5_TESINT $ "03,U "	//nova versao


	//Valida Estoque para Produtos que NAO SAO DO SEGMENTO SOLAR e TEM ESTRUTURA !!!
	//Validação do Processo Solar - Sol.Fernando - 30/11/2020 - Venda com Ordem De Produto Posterior a Venda
	//Autor - Andre Salgado / Introde
	if LEFT(aCols[n][nPProd],1)="7"	//Segmento SOLAR Começa com Codigo "7"
		cProdSG1 := POSICIONE("SG1",1,xFilial("SG1")+LEFT(aCols[n][nPProd],15),"G1_COD")
	Endif
	
	IF Empty(cProdSG1) //Valida se Tem Estoque para Todos os Produtos que não são Solar e Sem Estrutura !

		SB2->( dbSetOrder( 1 ) )
		If SB2->( dbSeek( xFilial( 'SB2' ) + aCols[n][nPProd] + aCols[n][nPosLocal] )) 
			nSaldoSB2 := SaldoSB2(.F.,.T.,,.F.,.F.,,,,.T.) - SB2->B2_QPEDVEN
			
			If ABS(SB2->B2_QPEDVEN) + ABS(SB2->B2_RESERVA) > SB2->B2_QATU 
			    
			    If !IsInCallStack("U_INTRJ")
					lRet := .F.
				EndIf
				
				cMsgErr := '[M410LIOK] Produto c/ divergencia de saldo. Favor entrar em contato com o seu assistante comercial! ' + Alltrim( aCols[n][nPProd] )+ ' ( ' +  Alltrim( Transform(nSaldoSB2,'@E 999,999,999.99') ) + ' )'
				//ApMsgStop( cMsgErr, 'M410LIOK' )
				//Amedeo Fabritech (Ajuste para mensagem Portal de 4Sales)
				Aviso( "Aviso", cMsgErr, {"Ok"} )
                If IsSFA
	                AutoGrLog("###### Erro Pedido de Venda #########")
	                AutoGrLog(cMsgErr)
	                AutoGrLog("#####################################")
//					ProcGrvErro({cMsgErr}, M->C5_YCDPALM, M->C5_VEND1, M->C5_CLIENTE+M->C5_LOJACLI)                
                EndIf
                
			Else
			
				If (ALTERA)
					nQtdVen := GetAdvFVal("SC6","C6_QTDVEN",xFilial("SC6")+aCols[n][nPProd]+M->C5_NUM+aCols[n][nPosItem],2,0)
					nSaldoSB2 += nQtdVen  
				EndIf
			
				If aCols[n][nPQtd] > nSaldoSB2
					If AvalTes(aCols[ n ][ nPosTES ],"S","SN") // If TES movimento o estoque "S"	
						If !IsInCallStack("U_INTRJ")
							lRet := .F.
						EndIf
						
						//aCols[n][Len(aHeader)+1] := .T.
						cMsgErr := '[M410LIOK] Não existe saldo suficiente para este produto ' + Alltrim( aCols[n][nPProd] )+ ' ( ' +  Alltrim( Transform(nSaldoSB2,'@E 999,999,999.99') ) + ' )'
						//ApMsgStop( cMsgErr, 'M410LIOK' )
						//Amedeo Fabritech (Ajuste para mensagem Portal de 4Sales)
						Aviso( "Aviso", cMsgErr, {"Ok"} )
		                If IsSFA
			                AutoGrLog("###### Erro Pedido de Venda #########")
			                AutoGrLog(cMsgErr)
			                AutoGrLog("#####################################")
//							ProcGrvErro({cMsgErr}, M->C5_YCDPALM, M->C5_VEND1, M->C5_CLIENTE+M->C5_LOJACLI)                
		                EndIf
		
					EndIf
				
				EndIf
			
			EndIf
		
		Else
			lRet := .F.
			//ApMsgStop( 'Produto ' + Alltrim( aCols[n][nPProd] )+ ' sem saldo!', 'M410LIOK' )
			//Amedeo Fabritech (Ajuste para mensagem Portal de 4Sales)
			Aviso( "Aviso", 'Produto ' + Alltrim( aCols[n][nPProd] )+ ' sem saldo!', {"Ok"} )
		EndIf
	EndIf
    EndIf


    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se Gera Comissao por item                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lRet .And. (M->C5_TIPO == 'N') .And. (aCols[n][nPosTes] $ cTes) 	
	
		If U_GetComis(M->C5_VEND1, M->C5_TABELA, aCols[n][nPProd], aCols[n][nPosPrcVen], @nComis) 
    //    	
    		aCols[n][nPosComis1] := nComis  	  
    		aCols[n][nPosVlCom1] := Round( ((nComis/100) * aCols[n][nPosValor] ), nDecs)
    	        	
    	EndIf

	EndIf
    
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica Embalagem Fechado                              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lRet .And. (M->C5_TIPO == 'N')
		lRet := U_VerEmb(n)
	EndIf
	
	
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Validações para pedido gerados para operações do SAC                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lRet                                               
				
		aInfo     := U_RetParAR( "FS_SACSC6","Sac;10;SAC" )// USUARIOS;ARMAZEM;LOCALIZACAO
                                                         
		/* Parametro de validacao - FS_SACSA1
			01 - Usuarios 
	        02 - Armazem
	        03 - Localização

		*/
		If !Empty(aInfo) .And. Upper(UsrRetName(__cUserId)) $ Upper(aInfo[01])
        
			If aCols[n][nPosLocal] <> aInfo[02]
				cMsgErro  += "O Armazem para este pedido deve ser "+aInfo[02]+"."+CRLF			    				
            EndIf

			If AllTrim(aCols[n][nPosEnd]) <> AllTrim(aInfo[03])
				cMsgErro  += "O Endereço para este pedido deve ser "+aInfo[03]+"."+CRLF			    				
            EndIf
            
		EndIf 
		
	EndIf
	
	If !Empty( cMsgErro )
		lRet := .F.	
		Aviso("M410LIOK",cMsgErro,{"Ok"},3,"Atenção")
	EndIf
	  
EndIf

Return( lRet )



Static Function ProcGrvErro(aLog, cChave, cCodVend, cCodClient)

	cLog := ""
	
	For nX := 1 To Len(aLog)
		cLog += aLog[nX]+CRLF
	Next  

	DbSelectArea("I06")
	RecLock("I06",.T.)
	I06->I06_FILIAL 	:= XFILIAL("I06")
	I06->I06_SEQUEC 	:= DTOC(DATE()) + "  " + Left(Time(),8)
	I06->I06_CDPALM 	:= cChave
	I06->I06_VEND 		:= cCodVend
	I06->I06_CLIENTE 	:= cCodClient
	I06->I06_LOG 		:= cLog
	I06->I06_DTIMPR 	:= DATE()
		
	I06->(MsUnLock())
	I06->(DbCloseArea()) 

Return(.T.)
