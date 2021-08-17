#Include "Protheus.ch"
          
//Rotina de atualização de dados CCB
User Function SEFINA01()
	
	//CCB                                                                
	//contatos da empresa
	//E-mail: genival@ccb.inf.br
	//Fones :11 3787-9220 / 11 98195-9280
	
	Local cPerg    := FunName()
	Local aSays    := {}
	Local aButtons := {}
	Local _cQuery  := ""
	
	Private cConvenio := "20"
		
	SECriaPer(cPerg)
	
	aadd(aSays,"Esta rotina tem o objetivo de gerar o arquivo de atualização")
	aadd(aSays,"para o CCB conforme layout e parâmetros informados.")
	
	aadd(aButtons, { 5,.T.,{|| Pergunte(cPerg,.T. ) } } )
	aadd(aButtons, { 1,.T.,{|| (FechaBatch(), Processa({|lEnd| SEProc() })) }} )
	aadd(aButtons, { 2,.T.,{|| FechaBatch() }} )
	
	If Pergunte(cPerg,.T.)
		FormBatch( "Atualização CCB", aSays, aButtons)
	Endif

Return

Static Function SEProc()

	Local nX	   := 0
	Local nTotReg  := 0
	Local nHandle  := 0
	Local nSALDUP  := 0
	Local nDIAVEN  := 0
	Local nTotMed  := 0
	Local nQtdMed  := 0
	Local nNTOTVEN := 0
	Local nQTDTVEN := 0
	Local nVLMFAT  := 0
	Local nMEDTVEN := 0
	Local nMEDATRA := 0
	Local nTOTATRA := 0
	Local nDIAATRA := 0
	Local nMEDPVED := 0  
	Local nValAux  := 0
	Local aCliente := Array(6)
	Local aCond    := {}
	Local cMsg     := ""
	Local cCond	   := ""
	Local cLinha   := ""
	Local cQuery   := ""
	Local cCliAnt  := ""
	Local cFiltro  := ""
	Local dULTDAT  := cTod("")
	Local dDTMFAT  := cTod("")
	Local dPVENCT  := cTod("")
	Local dUVENCT  := cTod("")
	Local cFilCond1:= AllTrim(StrTran(MV_PAR09,";","','"))
	Local aCondFil1:= Separa(cFilCond1, ",")
	Local cArqPath := AllTrim(MV_PAR05) + "\Atual"+cConvenio+".txt" //Diretorio selecionado por parâmetro + nome do arquivo conforme padrão do layout
	Local cArqPath2:= AllTrim(MV_PAR05) + "\Atual"+cConvenio+"_" + dToS(DATE()) + "_" + StrTran(TIME(), ":","") + ".txt" //Caso encontre o arquivo original, renomeia e cria de novo
	Local cCNPJIntern := SuperGetMv("SE_CNPJCLI", .F., "'00145602000137','08466448000107','11907140000164'")
	
	ProcRegua(1)
	IncProc("Carregando informações")
	
	If Empty(cArqPath)
		MsgInfo(">>> Favor informar o diretório de saida!","ATENCAO")
		Return
	Endif 
	
	//Renomeia o arquivo
	If File(cArqPath)
		cMsg := "O arquivo antigo (" + cArqPath + ") foi renomeado para " + cArqPath2
		fRename(cArqPath, cArqPath2)		
	EndIf
	
	nHandle := fCreate(cArqPath)

	If nHandle == -1
		MsgStop(">>> Não foi possível gerar o arquivo de saida!","[Erro #" + cValToChar(fError()) + "]")
		Return
	Endif
		
	For nX := 1 To Len(aCondFil1)
		cFiltro += "'" + aCondFil1[nX] + "',"
	Next nX
	
	cFiltro := SubStr(cFiltro,1,Len(cFiltro)-1)//Remove ultima virgula
  
	cQuery := "  select "
 	cQuery += "        SA1.A1_COD,      "
 	cQuery += "        SA1.A1_LOJA,     "
 	cQuery += "        SA1.A1_NOME,     "
 	cQuery += "        SA1.A1_PRICOM,   "
 	cQuery += "        SA1.A1_CGC,      "
 	cQuery += "        SA1.A1_MUN,      "
    cQuery += "        SA1.A1_EST,      "
    cQuery += "        SA1.A1_CEP,      "
    cQuery += "        SA1.A1_MCOMPRA,  "
    cQuery += "        SA1.A1_SALDUP,   "
    cQuery += "        SE1.E1_EMISSAO,  "
    cQuery += "        SE1.E1_VENCREA,  "
    cQuery += "        SE1.E1_BAIXA,    "
    cQuery += "        SE1.E1_VLCRUZ,   "
    cQuery += "        SE1.E1_SALDO,    "
    cQuery += "        SE1.E1_PREFIXO,  "    
    cQuery += "        SE1.E1_NUM,      "
    cQuery += "        SE1.E1_FILORIG   "
    cQuery += "   from " + RetSqlName("SE1") + " SE1, "
    cQuery += "   " + RetSqlName("SA1") + " SA1"  

    cQuery += "  where SA1.D_E_L_E_T_ = ' '  "
    cQuery += "    and SE1.D_E_L_E_T_ = ' '  "
    cQuery += "    and SA1.A1_COD = SE1.E1_CLIENTE "
    cQuery += "    and SA1.A1_LOJA = SE1.E1_LOJA "
    cQuery += "    and SE1.E1_FILIAL   = '"+xFilial('SE1')+"' "           
    cQuery += "    and SA1.A1_FILIAL   = '"+xFilial('SA1')+"' "
    cQuery += "    and SA1.A1_PESSOA = 'J' " //APENAS PESSOAS JURIDICAS
    
    If !Empty(cCNPJIntern)
	    cQuery += "    and SA1.A1_CGC Not In (" + cCNPJIntern + ") " //Cliente não pode ser Direto Interno
    
    EndIf
    cQuery += "    and SA1.A1_COD BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"' "
     
    cQuery += "    and SE1.E1_TIPO NOT IN ('NCC', 'RA ','AB-','TX ','IR-','NDC','CF-','PI-')  "
    cQuery += "    and SE1.E1_PREFIXO  IN ("+cFiltro+") "
    
	If (MV_PAR08 == 1) //Tipo de Cliente a ser considerado
		cQuery += " AND SA1.A1_CLASSE NOT IN ('A') "
	ElseIf(MV_PAR08 == 2)
		cQuery += " AND SA1.A1_CLASSE IN ('A') "
  	ElseIf(MV_PAR08 == 3)
  		cQuery += " AND SA1.A1_CLASSE IN ('B') "
 	ElseIf(MV_PAR08 == 4)
  		cQuery += " AND SA1.A1_CLASSE IN ('C') "		                       
  	Endif
  	
  	If FieldPos("A1_CCCB") > 0
  		cQuery += " and SA1.A1_CCCB <> 'N' " //Apenas clientes que consideram CCB
  	EndIf

	//Titulos que estão vencidos ou em aberto ou pagos em atraso no período
    cQuery += "    and (DATEDIFF(DAY, SYSDATETIME(), CONVERT(DATETIME, SE1.E1_VENCREA)) > " + cValToChar(MV_PAR07) + " AND E1_SALDO > " + cValToChar(MV_PAR06) 
  	cQuery += "    or SE1.E1_SALDO > " + cValToChar(MV_PAR06) 
  	cQuery += "    or E1_BAIXA Between '" + dToS(MV_PAR01) + "' AND '" + dToS(MV_PAR02) + "' And E1_BAIXA > E1_VENCREA ) "

	cQuery += " order by E1_CLIENTE,E1_LOJA,E1_VLCRUZ,E1_VENCREA DESC "
		
	SESql("TALE", @cQuery)
	
	If TALE->(EoF())
		IncProc("Encerrando dados, fechando arquivos e conexões...")
		MsgInfo(">>> Não foram encontrados dados com os parâmetros informados...","ATENCAO")
		fClose(nHandle)
		fErase(cArqPath)
		SEClose("TALE")
		Return
	EndIf

	TCSetField("TALE","E1_EMISSAO","D",08,0)
	TCSetField("TALE","E1_VENCREA","D",08,0)
	TCSetField("TALE","E1_BAIXA"  ,"D",08,0)
	TCSetField("TALE","A1_PRICOM" ,"D",08,0)
	TCSetField("TALE","E1_VLCRUZ" ,"N",16,2)
	TCSetField("TALE","E1_SALDO"  ,"N",16,2)
	TCSetField("TALE","A1_SALDUP" ,"N",16,2)
	TCSetField("TALE","A1_MCOMPRA","N",16,2)
	
	nTotReg := SECalc("TALE")
	
	ProcRegua(nTotReg)
	
	While TALE->(!Eof())
	
		IncProc("[" + AllTrim(TALE->A1_COD) + "] " + AllTrim(TALE->A1_NOME))
	
		If Empty(cCliAnt)
			cCliAnt := TALE->A1_COD
			aCliente[1] := TALE->A1_CGC
			aCliente[2] := TALE->A1_NOME
			aCliente[3] := TALE->A1_PRICOM
			aCliente[4] := TALE->A1_MUN
			aCliente[5] := TALE->A1_EST
			aCliente[6] := TALE->A1_CEP
		EndIf
	
		If cCliAnt == TALE->A1_COD
		
			//Verificando titulos vencidos
			If TALE->E1_SALDO > 0 .And. TALE->E1_VENCREA < DATE()
			
				//Guarda o primeiro titulo vencido
				If Empty(dPVENCT) .Or. dPVENCT > TALE->E1_VENCREA
					dPVENCT := TALE->E1_VENCREA
				EndIf   
								
				//Guarda o último titulo vencido
				If dUVENCT < TALE->E1_VENCREA
					dUVENCT := TALE->E1_VENCREA
				EndIf
				
				//Soma os valores e contabiliza os titulos vencidos e não pagos
				nNTOTVEN += TALE->E1_SALDO  
				nQTDTVEN ++         
								
				//Contabiliza os dias da data vencida
				nDIAVEN += DATE() - TALE->E1_VENCREA
				
				//Recalculo de média
				If nDIAVEN > 0 .And. nQTDTVEN > 0
					nMEDTVEN := nDIAVEN/nQTDTVEN
				EndIf
			
			ElseIf TALE->E1_SALDO > 0 //Verificando titulos a vencer
				
				//Soma o valor que está em aberto a vencer
				nSALDUP  += TALE->E1_SALDO
				
			ElseIf TALE->E1_BAIXA > TALE->E1_VENCREA //Verificando titulos pagos em atraso no período
			
				nTOTATRA++//Contabiliza o número de titulos em atraso para fazer a média posteriormente
				nDIAATRA += TALE->E1_BAIXA - TALE->E1_VENCREA //Dias de atraso que foi feito o pagamento
				nMEDATRA := nDIAATRA/nTOTATRA //Média em dias de pagamentos em atraso
				
			EndIf    
			                            
			//Calculos para media de vendas no período selecionado
			
				//Para não contabilizar a primeira vez
				//If Empty(dULTDAT)
				//	dULTDAT := TALE->E1_EMISSAO
				//EndIf
				
				//If dULTDAT != TALE->E1_EMISSAO
				//	nTotMed += dULTDAT - TALE->E1_EMISSAO
				//EndIf
				
				//dULTDAT := TALE->E1_EMISSAO
				//nQtdMed++
				
				// wadih 16-10-2016
				//cCond := Posicione("SF2",1,xFilial("SF2")+TALE->(E1_NUM+E1_PREFIXO), "F2_COND")
				
				If Select("COND") > 0
					DbSelectArea("COND")
					COND->(DbCloseArea())
				EndIf
				
				_cQuery := " SELECT F2_COND "
				_cQuery += " FROM " + RetSqlName("SF2") + " SF2 "
				_cQuery += " WHERE SF2.D_E_L_E_T_ <> '*' AND "
				_cQuery += " SF2.F2_CLIENTE = '" + TALE->A1_COD + "' AND "
				_cQuery += " SF2.F2_LOJA    = '" + TALE->A1_LOJA    + "' AND "
				//_cQuery += " SF2.F2_SERIE   = '" + TALE->E1_PREFIXO   + "' AND "
				//_cQuery += " SF2.F2_DOC     = '" + TALE->E1_NUM     + "' "
				_cQuery += " SF2.F2_DUPL     = '" + TALE->E1_NUM     + "' AND "
				_cQuery += " SF2.F2_PREFIXO   = '" + TALE->E1_PREFIXO   + "' AND "
				_cQuery += " SF2.F2_FILIAL = '" + TALE->E1_FILORIG + "' "

   				dbUseArea( .T., "TOPCONN", TCGENQRY(,,_cQuery), 'COND' ) 
   				
   				If COND->(!Eof())
	
	          		cCond  := COND->F2_COND
	
				EndIf

   				
				COND->(DbCloseArea())
				
				// wadih 16-10-2016
				
				SE4->(DbSetOrder(1))
				SE4->(DbSeek(xFilial("SE4")+cCond))
				
				aCond := Separa(SE4->E4_COND, ",", .F.)
				
				For nX := 1 To Len(aCond)
					nTotMed += Val(aCond[nX])
				Next nX
				
				nQtdMed += Len(aCond)
				
				//Sempre atualiza a média
				If nTotMed > 0 .And. nQtdMed > 0
					nMEDPVED := nTotMed/nQtdMed
				EndIf
			
			//Fim calculo de média de vendas

			//Guarda a maior fatura e a maior data dessa fatura
			nValAux := SENf(TALE->E1_PREFIXO, TALE->E1_NUM)
			
			If nVLMFAT < nValAux                                          
			    
				//Desde que esteja dentro do período
				If TALE->E1_EMISSAO >= MV_PAR01 .And. TALE->E1_EMISSAO <= MV_PAR02
				
					nVLMFAT := nValAux
					dDTMFAT := TALE->E1_EMISSAO	
					
				EndIf
				
			EndIf   
			
			nVLMFAT := Round(nVLMFAT, 0)
			nSALDUP := Round(nSALDUP, 0)
			nQTDTVEN:= Round(nQTDTVEN, 0)
														
		Else

			//A maior fatura, valor a vencer ou o valor de vencidos deve ter algum valor para ser enviado
			If nVLMFAT > 0 .Or. nSALDUP > 0 .Or. nQTDTVEN > 0
				//Caso tenha registros vencido e não pago, deve verificar se tem pelo menos valor 1
				If .Not.Empty(dUVENCT) .And. .Not.Empty(dPVENCT) .And. nNTOTVEN < 1
					nNTOTVEN := 1
				EndIf
						
				cLinha := SELin(dDataBase		, 11	)//MES REFERENCIA
				cLinha += SELin(cConvenio		, 02	)//NR CONVENIO
				cLinha += SELin(aCliente[1]		, 08	)//CNPJ
				cLinha += SELin(aCliente[2]		, 50	)//RAZAO SOCIAL
				cLinha += SELin(aCliente[3]		, 11	)//PRIMEIRA VENDA DO CLIENTE
				cLinha += SELin(aCliente[4]		, 30	)//CIDADE
				cLinha += SELin(aCliente[5]		, 02	)//UF
				cLinha += SELin(aCliente[6]		, 02	)//CEP
				cLinha += SELin(dDTMFAT			, 11	)//DATA DA MAIOR FATURA
				cLinha += SELin(nVLMFAT			, 11	)//VALOR DA MAIOR FATURA DO MES
				cLinha += SELin(nSALDUP		 	, 11	)//VALOR A VENCER
				cLinha += SELin(nMEDPVED		, 06, 00)//MEDIA ARITIMETICA DO PRAZO DE VENDAS
				cLinha += SELin(nNTOTVEN		, 11	)//TOTAL DOS TITULOS VENCIDOS E NAO PAGOS
				cLinha += SELin(nQTDTVEN		, 06	)//QUANTIDADE DE TITULOS VENCIDOS
				cLinha += SELin(dPVENCT			, 11	)//PRIMEIRO TITULO VENCIDO
				cLinha += SELin(dUVENCT			, 11	)//ULTIMO TITULO VENCIDO
				cLinha += SELin(nMEDTVEN		, 06, 00)//MEDIA ARITIMETICA DOS TITULOS VENCIDOS EM DIAS
				cLinha += SELin(''				, 02	)//SITUACAO - TABELA DE NEGATIVOS
				cLinha += SELin(nMEDATRA		, 06, 00)//Média pagamento dos título pagos em atraso (em dias)
							
				cLinha += Chr(13)+Chr(10)//Quebra linha
				
				fWrite(nHandle,cLinha,Len(cLinha))

			EndIf
			
			//Inicializa as variaveis
			cCliAnt  := TALE->A1_COD //Guarda o próximo cliente
			aCliente[1] := TALE->A1_CGC
			aCliente[2] := TALE->A1_NOME
			aCliente[3] := TALE->A1_PRICOM
			aCliente[4] := TALE->A1_MUN
			aCliente[5] := TALE->A1_EST
			aCliente[6] := TALE->A1_CEP
			
			dULTDAT  := cTod("")
			dDTMFAT  := cTod("")
			dPVENCT  := cTod("")
			dUVENCT  := cTod("")
			nValAux  := 0
			nSALDUP  := 0
			nDIAVEN  := 0
			nTotMed  := 0
			nQtdMed  := 0
			nNTOTVEN := 0
			nQTDTVEN := 0
			nVLMFAT  := 0
			nMEDTVEN := 0
			nMEDATRA := 0
			nTOTATRA := 0
			nDIAATRA := 0
			nMEDPVED := 0
						
			Loop //Não continua o loop atual para não pular o registro
			
		EndIf
			
		TALE->(DbSkip())
	
	EndDo

	//A maior fatura, valor a vencer ou o valor de vencidos deve ter algum valor para ser enviado
	If nVLMFAT > 0 .Or. nSALDUP > 0 .Or. nQTDTVEN > 0
		//Caso tenha registros vencido e não pago, deve verificar se tem pelo menos valor 1
		If .Not.Empty(dUVENCT) .And. .Not.Empty(dPVENCT) .And. nNTOTVEN < 1
			nNTOTVEN := 1
		EndIf

		cLinha := SELin(dDataBase		, 11	)//MES REFERENCIA
		cLinha += SELin(cConvenio		, 02	)//NR CONVENIO
		cLinha += SELin(aCliente[1]		, 08	)//CNPJ
		cLinha += SELin(aCliente[2]		, 50	)//RAZAO SOCIAL
		cLinha += SELin(aCliente[3]		, 11	)//PRIMEIRA VENDA DO CLIENTE
		cLinha += SELin(aCliente[4]		, 30	)//CIDADE
		cLinha += SELin(aCliente[5]		, 02	)//UF
		cLinha += SELin(aCliente[6]		, 02	)//CEP
		cLinha += SELin(dDTMFAT			, 11	)//DATA DA MAIOR FATURA
		cLinha += SELin(nVLMFAT			, 11	)//VALOR DA MAIOR FATURA DO MES
		cLinha += SELin(nSALDUP		 	, 11	)//VALOR A VENCER
		cLinha += SELin(nMEDPVED		, 06, 00)//MEDIA ARITIMETICA DO PRAZO DE VENDAS
		cLinha += SELin(nNTOTVEN		, 11	)//TOTAL DOS TITULOS VENCIDOS E NAO PAGOS
		cLinha += SELin(nQTDTVEN		, 06	)//QUANTIDADE DE TITULOS VENCIDOS
		cLinha += SELin(dPVENCT			, 11	)//PRIMEIRO TITULO VENCIDO
		cLinha += SELin(dUVENCT			, 11	)//ULTIMO TITULO VENCIDO
		cLinha += SELin(nMEDTVEN		, 06, 00)//MEDIA ARITIMETICA DOS TITULOS VENCIDOS EM DIAS
		cLinha += SELin(''				, 02	)//SITUACAO - TABELA DE NEGATIVOS
		cLinha += SELin(nMEDATRA		, 06, 00)//Média pagamento dos título pagos em atraso (em dias)
					
		cLinha += Chr(13)+Chr(10)//Quebra linha
		
		fWrite(nHandle,cLinha,Len(cLinha))

	EndIf
		
	fClose(nHandle)
	
	SELog()
		
	MsgInfo(">>> Processo finalizado!", "ATENÇÃO")
	
	If !Empty(cMsg)
		MsgInfo(">>> " + cMsg, "ARQUIVO JÁ EXISTENTE")
	EndIf
	
	SEClose("TALE")
	
Return

Static Function SELog()

	RecLock("ZA0", .T.)
		ZA0->ZA0_FILIAL := xFilial("ZA0")
		ZA0->ZA0_CODIGO := GetSxENum("ZA0", "ZA0_CODIGO")
		ZA0->ZA0_DATA   := DATE()
		ZA0->ZA0_HORA   := TIME()
		ZA0->ZA0_USERID := __cUserId
		ZA0->ZA0_USERNA := LogUserName()
		ZA0->ZA0_PARAMS := SEPar()
	MsUnlock()
	
	ConfirmSX8()

Return     

Static Function SENf(cPrefixo, cTitulo)

	Local nRet := 0
	Local _cQuery := ""
	Local _cAlias := GetNextAlias()
	
	_cQuery += " Select E1_NUM, E1_PREFIXO, SUM(E1_VLCRUZ) VALOR "
	_cQuery += " From " + RetSqlTab("SE1")
	_cQuery += " Where " + RetSqlCond("SE1")
	_cQuery += " And E1_NUM = '" + cTitulo + "' And E1_PREFIXO = '" + cPrefixo + "' "
	_cQuery += " And E1_TIPO NOT IN ('NCC', 'RA ','AB-','TX ','IR-','NDC','CF-','PI-')  "
	_cQuery += " Group By E1_NUM, E1_PREFIXO "
	
	SESql(_cAlias, _cQuery)
	
	While (_cAlias)->(!EoF())
	
		nRet := (_cAlias)->VALOR
	
		(_cAlias)->(DbSkip())
	
	EndDo
	
	SEClose(_cAlias)

Return nRet

Static Function SEPar()
                     
	Local uCampo
	Local nX   := 0
	Local cRet  := ""
	Local cCampo := ""
	
	For nX := 1 To 9
	
		cCampo := "MV_PAR" + StrZero(nX,2)
		
		uCampo := &(cCampo)
		uCampo := AllTrim(SELin(uCampo, 50))
		
		cRet += cCampo + ": " + uCampo + CRLF
		
	Next nX

Return cRet

Static Function SECalc(_cAlias)

	Local nRet := 0
	
	While (_cAlias)->(!EoF())
		nRet++
		(_cAlias)->(DbSkip())
	EndDo
	
	(_cAlias)->(DbGoTop())

Return nRet

Static Function SELin(uVar, nTam, nDec)

	Local cRet := ""
	
	Default nDec := 0 //Solicitado pelo Genival para efetuar o arredondamento de números
	
	If ValType(uVar) == "D"
		cRet := dToS(uVar)
		cRet := Right(cRet,2) + "/" + SubStr(cRet, 5, 2) + "/" + Left(cRet, 4)
	ElseIf ValType(uVar) == "N"
		cRet := Round(uVar, nDec)
		//cRet := IIF(Empty(cRet), 1, cRet)//Quando valor ficar menor que 0, deve ir 1
		cRet := cValToChar(cRet)
		cRet := StrTran(cRet, ",","")
		cRet := StrTran(cRet, ".","")
	Else
		cRet := uVar
	EndIf
	
	cRet := AllTrim(cRet) 	//Remove espaços em branco desnecessários
	cRet := Left(cRet, nTam)//Pega os caracteres da esquerda
	cRet := PadR(cRet, nTam)//Preenche com espaços, caso seja menor que o nTam

Return cRet

Static Function SESql(_cAlias, _cQuery)

	SEClose(_cAlias)

	_cQuery := ChangeQuery(_cQuery)
	
	DbUseArea(.T., "TOPCONN", TCGenQry(,,_cQuery),_cAlias, .T., .F.)

Return

Static Function SEClose(_cAlias)

	If (Select(_cAlias) <> 0)
		DbSelectArea(_cAlias)
		DbCloseArea()
	Endif

Return

Static Function SECriaPer(cGrupo)

	Local aReg := {}
	Local aPer := {}
	Local cSeq := Space(2)
		
	AADD(aPer,{cGrupo,"01","Dt. Emissao de     ?","mv_chA","D",08,0,0,"G","","MV_PAR01","","","","","","","","","","","","","","",""})
	AADD(aPer,{cGrupo,"02","Dt. Emissao ate    ?","mv_chB","D",08,0,0,"G","","MV_PAR02","","","","","","","","","","","","","","",""})
	AADD(aPer,{cGrupo,"03","Do Cliente         ?","mv_chC","C",06,0,0,"G","","MV_PAR03","","","","","","","","","","","","","","","CLI"})
	AADD(aPer,{cGrupo,"04","Ate o Cliente      ?","mv_chD","C",06,0,0,"G","","MV_PAR04","","","","","","","","","","","","","","","CLI"})
	AADD(aPer,{cGrupo,"05","Diretório de Saida ?","mv_chF","C",50,0,0,"G","","mv_par05","","","","","","","","","","","","","","",""})
	AADD(aPer,{cGrupo,"06","Valor minimo       ?","mv_chG","N",12,2,0,"G","","mv_par06","","","","","","","","","","","","","","",""})
	AADD(aPer,{cGrupo,"07","Nr Dias Atraso     ?","mv_chH","N",04,0,0,"G","","mv_par07","","","","","","","","","","","","","","",""})
	AADD(aPer,{cGrupo,"08","Tipo Cliente       ?","mv_chI","N",01,0,0,"C","","MV_PAR08","Exceto A","","","Somente A","","","Somente B","","","Somente C","","","Todos","",""})
	AADD(aPer,{cGrupo,"09","Prefixo            ?","mv_chJ","C",15,0,0,"G","","MV_PAR09","","","","","","","","","","","","","","",""})   
		
	DbSelectArea("SX1")
	
	cGrupo := Alltrim(cGrupo)+Space(Len(SX1->X1_grupo)-Len(Alltrim(cGrupo)))
	
	If (FCount() >= 40)
		For _l := 1 to Len(aPer)
			aadd(aReg,{cGrupo,aPer[_l,2],aPer[_l,3],"","",aPer[_l,4],aPer[_l,5],;
			aPer[_l,6],aPer[_l,7],aPer[_l,8],aPer[_l,9],aPer[_l,10],;
			aPer[_l,11],aPer[_l,12],"","",aPer[_l,13],aPer[_l,14],;
			aPer[_l,15],"","",aPer[_l,16],aPer[_l,17],aPer[_l,18],"","",;
			aPer[_l,19],aPer[_l,20],aPer[_l,21],"","",aPer[_l,22],;
			aPer[_l,23],aPer[_l,24],"","",aPer[_l,25],aPer[_l,26],"",""})
		Next _l
	Endif
	
	DbSelectArea("SX1")
	
	For _l := 1 to Len(aReg)
		cSeq := aReg[_l,2]
		If !dbSeek(cGrupo+cSeq)
			RecLock("SX1",.T.)
			For _m := 1 to Len(aReg[_l])
				FieldPut(_m,aReg[_l,_m])
			Next _m
			MsUnlock("SX1")
		Elseif (Alltrim(aReg[_l,3]) <> Alltrim(SX1->X1_pergunt))
			RecLock("SX1",.F.)
			For _k := 1 to Len(aReg[_l])
				FieldPut(_k,aReg[_l,_k])
			Next _k
			MsUnlock("SX1")
		Endif
	Next _l

Return

//REVISAO 000 - FABRICIO EDUARDO RECHE - 06/10/2014 - 'Criação'
//REVISAO 001 - FABRICIO EDUARDO RECHE - 06/10/2014 - 'Ajuste nos valores enviados ao arquivo, quando for 0, deverá ser enviado 1'
//REVISAO 002 - FABRICIO EDUARDO RECHE - 06/10/2014 - 'Correção no ajuste de valores, deve ser 1 apenas para valores vencidos e não pagos'