#Include "Protheus.ch"
#Include "Rwmake.ch"
#Include "TbiConn.ch"
#Include "Topconn.ch"

#Define STR_PULA    Chr(13)+Chr(10)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³SERASA    ºAutor  ³Microsiga           º Data ³  29/01/16   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³  Gerar arquivo Serasa Reciprocidade                        º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
             
User Function RetConcili()

//dDataFim := "13/06/2018"

//If (CtoD(dDataFim) > dDatabase)

	@ 96,42 TO 323,566 DIALOG oDlg1 TITLE "Geração do arquivo de Conciliação(Serasa)"
	@ 8,01 TO 90,261
	@ 23,28 SAY '               Este procedimento irá gerar o arquivo texto de conciliação '
	@ 33,28 SAY ' RetConcilia.txt de clientes que efetuaram pagamento de títulos com base  '
	@ 43,28 SAY ' no arquivo "CONCILIA" recebido Serasa.'
	@ 95,168 BMPBUTTON TYPE 1 ACTION Concili()
	@ 95,196 BMPBUTTON TYPE 2 ACTION Close(Odlg1)
	
	ACTIVATE DIALOG oDlg1 CENTER
//Else
//	MSGAlert("Favor entrar em contato com a Sensus. Este programa expirou!!!")
//EndIf

return

Static Function Concili()

	Local aCabec  := {}
	Local aItens  := {}
	Local aCliente:= {}
	Local nTimer
	Local nLines := 0
	Local oFile
	Local cFileOpen := ""
	Local cTitulo1 := "Selecione o arquivo"
	Local cExtens  := "Arquivo Serasa | *.*"
	Local nCont   := 0
	Local nX
	Local nTamFile, nTamLin, cBuffer, nBtLidos
	Local lExiste := .T.
	Local lPrim   := .T.
	Local lUlt    := .T.
	Local lHabil  := .F.
	Local DtFimPer
	Local cQuery := "" // Maurício Aureliano - Chamado: I1808-1318
	//Local cAliasQry := GetNextAlias()
	Local cNumTit, cParcela, dEmissao, cCliente, cLoja, dBaixa, cNumTitulo
	Local cLinhaNew := ""
	
	Private nHdl  := 0
	Private cEOL  := "CHR(8)"
	Private cArq,nHdlArq

	CLOSE(Odlg1)
	cFileOpen := cGetFile(cExtens,cTitulo1,,"C:\",.T.)

	If !File(cFileOpen)
		MsgAlert("Arquivo texto: "+cFileOpen+" não localizado",oLeArqTxt)
		Return
	Endif

	FT_FUSE(cFileOpen)
	FT_FGoTop()         //posiciona na primeira linha do arquivo
	//nTamLinha := AT(cEOL,cBuffer )
	nTamLinha := Len(FT_FREADLN() ) //Ve o tamanho da linha
	FT_FGOTOP()

	//+---------------------------------------------------------------------+
	//| Verifica quantas linhas tem o arquivo                               |
	//+---------------------------------------------------------------------+
	nLinhas := FT_FLastRec()

	ProcRegua(nLinhas)

	While !FT_FEOF()
 
		If nCont > nLinhas
			Exit
		EndIf
	
		IncProc("Lendo arquivo texto...Linha "+Alltrim(str(nCont)))
		cLinha := Alltrim(FT_FReadLn())
		nRecno := FT_FRecno() // Retorna a linha corrente
 
		If !empty(cLinha )
   		
	    	//Verificar se é um arquivo de conciliação    
			If lPrim
				If !(Substr(cLinha,1,2 )=="00" .And. Substr(cLinha,37,8) == "CONCILIA")
					ApMsgInfo("O Arquivo "+cFileOpen+" não é de conciliação!","[SERASA] - AVISO")
					Exit
				Else
					DtFimPer := Substr(cLinha,45,8 )
					cLinhaNew += cLinha + space(26) + CHR(13) + CHR(10)
				EndIf
				lPrim := .F.
			EndIf
		
			If Substr(cLinha,1,2 )=="01"
	
				dbSelectArea("SA1")
				dbSetOrder(3)
				SA1->(dbGoTop())
				
				If dbSeek(xFilial("SA1")+Substr(cLinha,3,14 ))				
								
					cCliente	:= SA1->A1_COD
					cLoja		:= SA1->A1_LOJA
					cNumTit  	:= Substr(cLinha,19,10)
					cNumTitulo	:= Substr(cNumTit,1,9)
												
					// Maurício Aureliano - Chamado: I1808-1318
					/*			  
				 	//se a decima posição for letra                            
					If IsAlpha(Substr(cNumTit,10,1))
						cNumTitulo	:= Substr(cNumTit,1,9)
						cParcela 	:= Substr(cNumTit,10,1)
					EndIf
					*/
					cParcela := Substr(cNumTit,10,1)
					If (cParcela == "Z")
						cParcela := ""
					EndIf
						
					dEmissao := Substr(cLinha,29,8)
					dBaixa   := space(08)
					//buscar data da baixa
	
					If (Select("cAliasQry") <> 0)
						dbSelectArea("cAliasQry")
						dbCloseArea()
					EndIf
			
					// Maurício Aureliano - Chamado: I1808-1318
					/*
					BeginSql Alias cAliasQry    
					
						SELECT 
						     SE1.E1_BAIXA
						FROM %table:SE1% SE1                                   
						WHERE SE1.%NotDel%  AND SE1.E1_FILIAL = %xFilial:SE1%
							 AND SE1.E1_NUM     = %exp:cNumTitulo%   
					   		 AND SE1.E1_PARCELA = %exp:cParcela%   
					   		 AND SE1.E1_EMISSAO = %exp:dEmissao%   
					   		 AND SE1.E1_CLIENTE = %exp:cCliente%
					EndSql 
					*/

					cQuery := " SELECT"		 + STR_PULA
					cQuery += " E1_BAIXA"	 + STR_PULA
					cQuery += " FROM " + RetSqlName("SE1") + " SE1" + STR_PULA
					cQuery += " WHERE E1_FILIAL = '" + xFilial("SE1") + "'" + STR_PULA
					cQuery += " AND E1_NUM = '" + cNumTitulo + "'" + STR_PULA
					cQuery += " AND	E1_PARCELA = '" + cParcela + "'" + STR_PULA
					cQuery += " AND	E1_EMISSAO = '" + dEmissao + "'" + STR_PULA
					cQuery += " AND	E1_CLIENTE = '" + cCliente + "'" + STR_PULA
					cQuery += " AND	E1_LOJA = '" + cLoja + "'" + STR_PULA
					cQuery += " AND	SE1.D_E_L_E_T_ = ''"

					MemoWrit("C:\SIGA\RETCONCILI.sql",cQuery)
					TCQuery cQuery New Alias "QryConci"
			
					While QryConci->(!Eof())
		
						dBaixa := QryConci->E1_BAIXA
						QryConci->(DbSkip())
	   		   
					EndDo
			
					QryConci->(dbCloseArea())
				
					//aCliente[1][1] = CNPJ  		//POSICAO: 03 A 16 //TAM: 14
					//aCliente[1][2] = TITULO		//POSICAO: 19 A 28 //TAM: 10
					//aCliente[1][3] = DTTITULO		//POSICAO: 29 A 36 //TAM:  8 
					//aCliente[1][4] = VALOR		//POSICAO: 37 A 49 //TAM: 13
					//aCliente[1][5] = DTVENC		//POSICAO: 50 A 57 //TAM:  8 
					//aCliente[1][6] = DTBAIXA			
						
					aadd(aCliente,{Substr(cLinha,3,14 ),Substr(cLinha,19,10),Substr(cLinha,29,8),Substr(cLinha,37,13 ), Substr(cLinha,50, 8), dBaixa})
					If !Empty(dBaixa)
						If ((dBaixa >= Substr(cLinha,29,8)) .And. (dBaixa <= DtFimPer))
							cLinhaNew += Substr(cLinha,1,57) + dBaixa + Substr(cLinha, 66, 57) + space(08) + CHR(13) + CHR(10)
						Else
							cLinhaNew += Substr(cLinha,1,57) + space(43) + Substr(cLinha, 101, 22) + space(08) + CHR(13) + CHR(10)
						EndIf
					Else
						cLinhaNew += Substr(cLinha,1,57) + space(43) + Substr(cLinha, 101, 22) + space(08) + CHR(13) + CHR(10)
					EndIf
				Else // Maurício Aureliano - Chamado: I1808-1318
					Alert("Cliente não encontrado!")
				EndIf
			Endif
		Else // Maurício Aureliano - Chamado: I1808-1318
			Alert("Arquivo NÃO contem linhas!")
		Endif
		FT_FSKIP()
		nCont++
	
		//última linha do arquivo
		If (Substr(cLinha,1,2 )=="99")
			cLinhaNew += cLinha + space(40) + CHR(13) + CHR(10)
		EndIf

	EndDo
 
	FT_FUSE()

	//gerar o arquivo
	cArq := '\Backup\RetConcilia.TXT'

	If File(cArq)
		fErase(cArq)
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Criacao do arquivo texto informado.                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nHdlArq  := MSFCREATE(cArq)
	fWrite(nHdlArq,cLinhaNew)

	FClose(nHdlArq)
	SET CENTURY OFF

	bOk := CpyS2T( "\Backup\RetConcilia.txt", "c:\temp\", .F. )
 
	MsgInfo("Arquivo c:\temp\RetConcilia.txt gerado com sucesso!","[SERASA] - SUCESSO")
 
Return