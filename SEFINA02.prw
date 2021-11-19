#Include "Protheus.ch"
#Include "Rwmake.ch"

#Define MSG_ERRO "STOP"
#Define MSG_INFO "INFO"

//Funcao de retorno de dados do CCB
User Function SEFINA02(cCliente, cLoja, lRotina, _cEmp, _cFil)

	Local aAreaSA1
	Local aArea    := GetArea()
		
	Private lAuto  := lRotina
	
	Default _cEmp := "01"
	Default _cFil := "01"
	
	If lAuto
		RpcSetEnv(_cEmp, _cFil)
		aAreaSA1 := SA1->(GetArea())
		SEIni(cCliente, cLoja)
		RpcClearEnv()
	Else
		aAreaSA1 := SA1->(GetArea())
		Processa({|| SEIni(cCliente, cLoja)}, "Efetuando consulta...")
	EndIf
			
	RestArea(aAreaSA1)
	RestArea(aArea)
	
Return           

Static Function SEIni(cCliente, cLoja)

	Local cStatus:= "" 
	Local cAviso := ""
	Local cCabec := ""
	Local cErro  := ""
	Local cXml   := ""
	Local cCNPJ  := ""
	Local oXml
	
	SEProc(15)
	
	SEProc("Iniciando consulta ao CCB...")

	//Garante o posicionamento na SA1
	If Alias() != "SA1"
		DbSelectArea("SA1")
		DbSetOrder(1)
		DbGoTop()
		DbSeek(xFilial("SA1")+cCliente+cLoja)
	EndIf
			
	If SA1->(EoF())
		SEMsg("Não foi possível posicionar no cliente: " + cCliente + "/" + cLoja, "ERRO!", MSG_ERRO)
		Return
	EndIf
	
	SEProc("[" + AllTrim(SA1->A1_COD) + "/" + AllTrim(SA1->A1_LOJA) + "] " + AllTrim(SA1->A1_NOME))
	
	If SA1->A1_PESSOA != "J"
		SEMsg("Consulta disponível apenas para pessoa Jurí­dica.", "Atenção", MSG_INFO)
		Return
	EndIf
	
	//Se existe o campo, verifica se estÃ¡ como S=Sim para consulta ao CCB
	If SA1->(FieldPos("A1_CCCB")) > 0 .And. SA1->A1_CCCB == "N"
		SEMsg("Este cliente não considera consulta CCB.", "Atenção", MSG_INFO)
		Return
	EndIf     
	          
	//Verifica se jÃ¡ foi feita a consulta na data de hoje, nÃ£o hÃ¡ necessidade de efetuar a atualizaÃ§Ã£o no CCB
	If SA1->(FieldPos("A1_DTCCB")) > 0 .And. SA1->A1_DTCCB >= DATE()
		SEMsg(">>> Arquivo já carregado para a data de hoje, não será necessário realizar a consulta novamente.", "Atenção!", MSG_INFO)
		Return
	EndIf
	
	cCNPJ := SuperGetMv("SE_CNPJCLI", .F., "'00145602000137','08466448000107','11907140000164'")
	
	If AllTrim(SA1->A1_CGC) $ cCNPJ
		SEMsg(">>> CNPJ interno, não é necessário efetuar a consulta.", "Atenção!", MSG_INFO)
		Return
	EndIf
	
	SEProc("Carregando XML")
	
	cXml := SEXml(AllTrim(SA1->A1_CGC))
	oXml := XmlParser(cXml, "_", @cErro, @cAviso)
	
	If Empty(cXml)
		Return
	EndIf
	
	If oXml == Nil
		SEMsg("Erro ao carregar o xml: " + cErro,"ERRO!", MSG_ERRO)
		Return
	EndIf 
	
	cStatus := oXml:_CONSULTA:_CONS_STATUS:TEXT
	
	SEProc("Verificando logs anteriores...")
			
	cCabec := SECabec(cXml, cStatus)
	
	If Val(cStatus) > 0 
		SEMsg("Erro no retorno do CCB: " + CRLF + SEStatus(cStatus), "ERRO #" + cStatus, MSG_ERRO)
		Return
	EndIf                     
	
	If !SEVer(oXml:_CONSULTA,  "_CLIENTE")
		SECliente(oXml:_CONSULTA:_CLIENTE, cCabec)
	EndIf
	                                        
	If !SEVer(oXml:_CONSULTA,  "_RECEITA")
		SEReceita(oXml:_CONSULTA:_RECEITA, cCabec)
	EndIf

	If !SEVer(oXml:_CONSULTA,  "_SOCIOS")
		SESocios(oXml:_CONSULTA:_SOCIOS, cCabec)
	EndIf

	If !SEVer(oXml:_CONSULTA,  "_DOCUMENTO")
		SEDocumento(oXml:_CONSULTA:_DOCUMENTO, cCabec)
	EndIf

	If !SEVer(oXml:_CONSULTA,  "_COLIGADAS")
		SEColigadas(oXml:_CONSULTA:_COLIGADAS, cCabec)
	EndIf
	                                        
	If !SEVer(oXml:_CONSULTA,  "_RISCO")
		SERisco(oXml:_CONSULTA:_RISCO, cCabec)
	EndIf
	                                        
	If !SEVer(oXml:_CONSULTA,  "_EXPERIENCIA")
		SEExperiencia(oXml:_CONSULTA:_EXPERIENCIA, cCabec)
	EndIf
	                                        
	If !SEVer(oXml:_CONSULTA,  "_INFORMACAO")
		SEInformacao(oXml:_CONSULTA:_INFORMACAO, cCabec)
	EndIf
	
	If !SEVer(oXml:_CONSULTA,  "_ALERTA")
		SEAlerta(oXml:_CONSULTA:_ALERTA, cCabec)
	EndIf
	
	If !SEVer(oXml:_CONSULTA,  "_RESUMO")
		SEResumo(oXml:_CONSULTA:_RESUMO, cCabec) 
	EndIf
	
	If !SEVer(oXml:_CONSULTA,  "_ATUALIZACAO")
		SEAtualizacao(oXml:_CONSULTA:_ATUALIZACAO, cCabec)
	EndIf
	
	If !SEVer(oXml:_CONSULTA,  "_NOTA")
		SENota(oXml:_CONSULTA:_NOTA, cCabec)
	EndIf
	
	//Atualiza a data de consulta do CCB
	If SA1->(FieldPos("A1_DTCCB")) > 0
		RecLock("SA1", .F.)
			SA1->A1_DTCCB := DATE()
		MsUnlock()
	EndIf

Return(.T.)

//Grava o cabeÃ§alho de informaÃ§Ãµes do retorno do CCB
Static Function SECabec(cXml, cStatus)

	Local cRet := GetSxeNum("ZA1", "ZA1_CODIGO")
	
	SEProc("Salvando dados do cabeçalho...")
	
	dbSelectArea("ZA1")
	RecLock("ZA1", .T.)
		ZA1->ZA1_FILIAL := xFilial("ZA1")
		ZA1->ZA1_CODIGO := cRet
		ZA1->ZA1_CLIENT := SA1->A1_COD
		ZA1->ZA1_LOJA   := SA1->A1_LOJA
		ZA1->ZA1_DATA   := DATE()
		ZA1->ZA1_HORA   := TIME()
		ZA1->ZA1_USERID := __cUserId
		ZA1->ZA1_USERNA := LogUserName()
		ZA1->ZA1_STATUS := cStatus
		ZA1->ZA1_STSDES := SEStatus(cStatus)
		ZA1->ZA1_STRXML := cXml
	MsUnlock()  
	
	ConfirmSX8()
	
Return cRet

Static Function SECliente(oXmlCli, cCabec)

	SEProc("Salvando dados do cliente...")
	
	If SEVer(@oXmlCli, "_CLI_CNPJ")
		Return
	EndIf

	dbSelectArea("ZA2")	
	Reclock("ZA2", .T.)
		ZA2->ZA2_FILIAL := xFilial("ZA2")
		ZA2->ZA2_CODIGO := cCabec
		ZA2->ZA2_CNPJ   := oXmlCli:_CLI_CNPJ:TEXT
		ZA2->ZA2_RAZAO  := oXmlCli:_CLI_RAZAO:TEXT
		ZA2->ZA2_CIDADE := oXmlCli:_CLI_CIDADE:TEXT
		ZA2->ZA2_UF     := oXmlCli:_CLI_UF:TEXT
		ZA2->ZA2_DTFUND := cToD(oXmlCli:_CLI_DTFUND:TEXT)
		ZA2->ZA2_PEXP   := cToD(oXmlCli:_CLI_PEXP:TEXT)
		ZA2->ZA2_ATU    := cToD(oXmlCli:_CLI_ATU:TEXT)
		ZA2->ZA2_DDD1	:= oXmlCli:_CLI_DDD1:TEXT
		ZA2->ZA2_FONE1	:= oXmlCli:_CLI_FONE1:TEXT
		ZA2->ZA2_DDD2	:= oXmlCli:_CLI_DDD2:TEXT
		ZA2->ZA2_FONE2	:= oXmlCli:_CLI_FONE2:TEXT
		ZA2->ZA2_EMAIL	:= oXmlCli:_CLI_EMAIL:TEXT
		ZA2->ZA2_CSOCIA	:= Val(oXmlCli:_CLI_CAPSOCIAL:TEXT)
	MsUnlock()
	
Return

Static Function SEReceita(oXmlRec, cCabec)

	SEProc("Salvando dados da receita...")      
	
	If SEVer(@oXmlRec, '_REC_CAD')
		Return
	EndIf

	dbSelectArea("ZA3")
	Reclock("ZA3", .T.)
		ZA3->ZA3_FILIAL := xFilial("ZA3")
		ZA3->ZA3_CODIGO := cCabec
		ZA3->ZA3_CAD    := oXmlRec:_REC_CAD:TEXT
		ZA3->ZA3_DTCONS := cToD(oXmlRec:_REC_DTCONS:TEXT)
		ZA3->ZA3_ATIV   := oXmlRec:_REC_ATIV:TEXT
		ZA3->ZA3_NATJUR := oXmlRec:_REC_NATJUR:TEXT
		ZA3->ZA3_SIT    := oXmlRec:_REC_SIT:TEXT
		ZA3->ZA3_MOTSIT := oXmlRec:_REC_MOTSIT:TEXT
		ZA3->ZA3_DTSIT	:= cToD(oXmlRec:_REC_DTSIT:TEXT)
		ZA3->ZA3_CNAE	:= oXmlRec:_REC_CNAE:TEXT
	MsUnlock()
	
Return

Static Function SEColigadas(oXmlCol, cCabec) 

	Local cSequen 	:= "0" 
	Local nX 		:= 0
	Local aCNPJ		:= {}
	Local aRAZAO	:= {}
	Local aCID		:= {}
	Local aUF		:= {}
	
	SEProc("Salvando dados das coligadas...")  
	
	If SEVer(@oXmlCol, '_COLIG_RAZAO')
		Return
	EndIf
	
	aRAZAO := SEArray(oXmlCol:_COLIG_RAZAO)
	aCNPJ := SEArray(oXmlCol:_COLIG_CNPJ)
	aCID := SEArray(oXmlCol:_COLIG_CID)
	aUF := SEArray(oXmlCol:_COLIG_UF)
	
	For nX := 1 To Len(aCNPJ)
	
		cSequen := Val(cSequen)+1
		cSequen := StrZero(cSequen, TamSX3("ZA4_SEQUEN")[1])
		
		dbSelectArea("ZA4")
		Reclock("ZA4", .T.)
			ZA4->ZA4_FILIAL := xFilial("ZA4")
			ZA4->ZA4_CODIGO := cCabec
			ZA4->ZA4_SEQUEN := cSequen
			ZA4->ZA4_CNPJ   := aCNPJ[nX]:TEXT
			ZA4->ZA4_RAZAO  := aRAZAO[nX]:TEXT
			ZA4->ZA4_CID    := aCID[nX]:TEXT
			ZA4->ZA4_UF     := aUF[nX]:TEXT
		MsUnlock()
			
	Next nX

Return

Static Function SERisco(oXmlRis, cCabec)

	SEProc("Salvando dados de risco...") 
	
	If SEVer(@oXmlRis, '_DT_RISCO')
		Return
	EndIf

	dbSelectArea("ZA5")
	Reclock("ZA5", .T.)
		ZA5->ZA5_FILIAL := xFilial("ZA5")
		ZA5->ZA5_CODIGO := cCabec
		ZA5->ZA5_DTRISC := cToD(oXmlRis:_DT_RISCO:TEXT)
	MsUnlock()
		
Return

Static Function SEExperiencia(oXmlExp, cCabec)

	Local cSequen := "0"
	Local nX      := 0       
	Local aREF    := {}
	Local aMPMV   := {}
	Local aMPAG   := {}
	Local aTINF   := {}
	//Local aTCONS  := {}
	Local aMMFAT  := {}
	Local aATRASO := {}
	Local aTAVEMC := {}
	Local aTVENCD := {}
	//Local aCONCOV := {}
	
	SEProc("Salvando dados de resumo de informações dos últimos 12 meses...")
	
	If SEVer(@oXmlExp, '_EXP_REF')
		Return
	EndIf
	
	aREF    := SEArray(oXmlExp:_EXP_REF)
	aMPMV   := SEArray(oXmlExp:_EXP_M_PMV)
	aMPAG   := SEArray(oXmlExp:_EXP_M_PAG)
	aTINF   := SEArray(oXmlExp:_EXP_T_INF)
	//aTCONS  := SEArray(oXmlExp:_EXP_T_CONS)
	aMMFAT  := SEArray(oXmlExp:_EXP_M_MFAT)
	aATRASO := SEArray(oXmlExp:_EXP_M_ATRASO)
	aTAVEMC := SEArray(oXmlExp:_EXP_T_AVENCER)
	aTVENCD := SEArray(oXmlExp:_EXP_T_VENCIDOS)
	//aCONCOV := SEArray(oXmlExp:_EXP_CONS_CONVS)

	For nX := 1 To Len(aREF)
		
		cSequen := Val(cSequen)+1
		cSequen := StrZero(cSequen, TamSX3("ZA6_SEQUEN")[1])
	
		dbSelectArea("ZA6")
		Reclock("ZA6", .T.)
			ZA6->ZA6_FILIAL := xFilial("ZA6")
			ZA6->ZA6_CODIGO := cCabec
			ZA6->ZA6_SEQUEN := cSequen
			ZA6->ZA6_REF    := cToD(aREF[nX]:TEXT)
			ZA6->ZA6_MMFAT  := Val(aMMFAT[nX]:TEXT)
			ZA6->ZA6_TAVEMC := Val(aTAVEMC[nX]:TEXT)
			ZA6->ZA6_TVENCD := Val(aTVENCD[nX]:TEXT)
			ZA6->ZA6_MPMV   := Val(aMPMV[nX]:TEXT)
			ZA6->ZA6_ATRASO := Val(aATRASO[nX]:TEXT)
			ZA6->ZA6_MPAG   := Val(aMPAG[nX]:TEXT)
			ZA6->ZA6_TINF   := Val(aTINF[nX]:TEXT)
			//ZA6->ZA6_TCONS  := Val(aTCONS[nX]:TEXT)
			//ZA6->ZA6_CONCOV := aCONCOV[nX]:TEXT
		MsUnlock()
		
	Next nX
	
Return

Static Function SEInformacao(oXmlInf, cCabec) 

	Local cSequen := "0"
	Local nX      := 0
	Local aREF    := {}
	Local aNCONV  := {}
	Local aDESDE  := {}
	Local aULTCMP := {}
	Local aDTULTC := {}
	Local aMACU   := {}
	Local aDTMACU := {}
	Local aMACU12 := {}
	Local aDTMC12 := {}
	Local aVENCER := {}
	Local aPMV    := {}
	Local aVENCDS := {}
	Local aVQDETI := {}
	Local aDTVNCD := {}
	Local aDTVNCA := {}
	Local aATRASO := {}
	Local aPAG    := {}
	Local aDTPAG  := {}
	Local aSIT    := {}

	SEProc("Salvando dados de informações relevantes...")      
	
	If SEVer(@oXmlInf, '_INF_REF')
		Return
	EndIf       
	
	aREF    := SEArray(oXmlInf:_INF_REF)
	aNCONV  := SEArray(oXmlInf:_INF_NCONV)
	aDESDE  := SEArray(oXmlInf:_INF_CLIDESDE)
	aULTCMP := SEArray(oXmlInf:_INF_ULTCOMPRA)
	aDTULTC := SEArray(oXmlInf:_INF_ULTCOMPRA_DT)
	aMACU   := SEArray(oXmlInf:_INF_MACU)
	aDTMACU := SEArray(oXmlInf:_INF_MACU_DT)
	aMACU12 := SEArray(oXmlInf:_INF_MACU12)
	aDTMC12 := SEArray(oXmlInf:_INF_MACU12_DT)
	aVENCER := SEArray(oXmlInf:_INF_AVENCER)
	aPMV    := SEArray(oXmlInf:_INF_PMV)
	aVENCDS := SEArray(oXmlInf:_INF_VENCIDOS)
	aVQDETI := SEArray(oXmlInf:_INF_VENC_QDETIT)
	aDTVNCD := SEArray(oXmlInf:_INF_VENC_DE_DT)
	aDTVNCA := SEArray(oXmlInf:_INF_VENC_ATE_DT)
	aATRASO := SEArray(oXmlInf:_INF_ATRASO)
	aPAG    := SEArray(oXmlInf:_INF_PAG)
	aDTPAG  := SEArray(oXmlInf:_INF_PAG_DT)
	aSIT    := SEArray(oXmlInf:_INF_SIT)

	For nX := 1 To Len(aREF)
	
		cSequen := Val(cSequen)+1
		cSequen := StrZero(cSequen, TamSX3("ZA7_SEQUEN")[1])
			
		dbSelectArea("ZA7")			
		Reclock("ZA7", .T.)
			ZA7->ZA7_FILIAL := xFilial("ZA7")
			ZA7->ZA7_CODIGO := cCabec
			ZA7->ZA7_SEQUEN := cSequen
			ZA7->ZA7_REF    := cToD(aREF[nX]:TEXT)
			ZA7->ZA7_NCONV  := Val(aNCONV[nX]:TEXT)
			ZA7->ZA7_DESDE  := cToD(aDESDE[nX]:TEXT)
			ZA7->ZA7_ULTCMP := Val(aULTCMP[nX]:TEXT)
			ZA7->ZA7_DTULTC := cToD(aDTULTC[nX]:TEXT)
			ZA7->ZA7_MACU   := Val(aMACU[nX]:TEXT)
			ZA7->ZA7_DTMACU := cToD(aDTMACU[nX]:TEXT)
			ZA7->ZA7_MACU12 := Val(aMACU12[nX]:TEXT)
			ZA7->ZA7_DTMC12 := cToD(aDTMC12[nX]:TEXT)
			ZA7->ZA7_VENCER := Val(aVENCER[nX]:TEXT)
			ZA7->ZA7_PMV    := Val(aPMV[nX]:TEXT)
			ZA7->ZA7_VENCDS := Val(aVENCDS[nX]:TEXT)
			ZA7->ZA7_VQDETI := Val(aVQDETI[nX]:TEXT)
			ZA7->ZA7_DTVNCD := cToD(aDTVNCD[nX]:TEXT)
			ZA7->ZA7_DTVNCA := cToD(aDTVNCA[nX]:TEXT)
			ZA7->ZA7_ATRASO := Val(aATRASO[nX]:TEXT)
			ZA7->ZA7_PAG    := Val(aPAG[nX]:TEXT)
			ZA7->ZA7_DTPAG  := cToD(aDTPAG[nX]:TEXT)
			ZA7->ZA7_SIT    := aSIT[nX]:TEXT
		MsUnlock()
		
	Next nX
	
Return

Static Function SESocios(oXmlInf, cCabec) 

	Local cSequen 	:= "0"
	Local nX      	:= 0
	Local aNome   	:= {}
	Local aTipo  	:= {}
	Local aQualif  	:= {}
	Local aDtEntr 	:= {}
	
	SEProc("Salvando dados de informações relevantes...")      
	
	If SEVer(@oXmlInf, '_SOCIO_NOME')
		Return
	EndIf
	
	aNome   := SEArray(oXmlInf:_SOCIO_NOME)
	aTipo  	:= SEArray(oXmlInf:_SOCIO_TIPO)
	aQualif := SEArray(oXmlInf:_SOCIO_QUALIF)
	aDtEntr := SEArray(oXmlInf:_SOCIO_DTENTR)
	
	For nX := 1 To Len(aNome)
	
		cSequen := Val(cSequen)+1
		cSequen := StrZero(cSequen, TamSX3("ZAG_SEQ")[1])
			
		dbSelectArea("ZAG")
		Reclock("ZAG", .T.)
			ZAG->ZAG_FILIAL := xFilial("ZAG")
			ZAG->ZAG_CODIGO := cCabec
			ZAG->ZAG_SEQ    := cSequen
			If !Empty(aNome)
				ZAG->ZAG_NOME   := aNome[nX]:TEXT
			EndIf
			If !Empty(aTipo)
				ZAG->ZAG_TIPO 	:= aTipo[nX]:TEXT
			EndIf
			If !Empty(aQualif)
				ZAG->ZAG_QUALIF := aQualif[nX]:TEXT
			EndIf
			If !Empty(aDtEntr)
				ZAG->ZAG_DTENTR := cToD(aDtEntr[nX]:TEXT)
			EndIf
		MsUnlock()
		
	Next nX
	
Return

Static Function SEDocumento(oXmlInf, cCabec) 

	Local cSequen 	:= "0"
	Local nX      	:= 0
	Local aDtCad   	:= {}
	Local aDtDoc  	:= {}
	Local aTpDoc  	:= {}
	Local aDesc 	:= {}
	
	SEProc("Salvando dados de informações relevantes...")      
	
	If SEVer(@oXmlInf, '_DOC_DTDCAD')
		Return
	EndIf
	
	aDtCad  := SEArray(oXmlInf:_DOC_DTDCAD)
	aDtDoc  := SEArray(oXmlInf:_DOC_DTDOC)
	aTpDoc 	:= SEArray(oXmlInf:_DOC_TIPO)
	aDesc	:= SEArray(oXmlInf:_DOC_DESC)
	
	For nX := 1 To Len(aDtCad)
	
		cSequen := Val(cSequen)+1
		cSequen := StrZero(cSequen, TamSX3("ZAF_SEQ")[1])
			
		dbSelectArea("ZAF")
		Reclock("ZAF", .T.)
			ZAF->ZAF_FILIAL := xFilial("ZAF")
			ZAF->ZAF_CODIGO := cCabec
			ZAF->ZAF_SEQ    := cSequen
			If !Empty(aDtCad)
				ZAF->ZAF_DTDCAD := cToD(aDtCad[nX]:TEXT)
			EndIf
			If !Empty(aDtDoc)
				ZAF->ZAF_DTDOC 	:= cToD(aDtDoc[nX]:TEXT)
			EndIf
			If !Empty(aTpDoc)
				ZAF->ZAF_TIPO 	:= aTpDoc[nX]:TEXT
			EndIf
			If !Empty(aDesc)
				ZAF->ZAF_DESC 	:= aDesc[nX]:TEXT
			EndIf
		MsUnlock()
		
	Next nX
	
Return

Static Function SEAlerta(oXmlAle, cCabec)

	Local cSequen := "0"
	Local nX 	  := 0
	Local aCOD    := {}
	Local aREF    := {}
	Local aCONV   := {}
	Local aOBS    := {}
	
	SEProc("Salvando dados de alertas...") 
	
	If SEVer(@oXmlAle, '_ALE_COD')
		Return
	EndIf     
	
	aCOD    := SEArray(oXmlAle:_ALE_COD)
	aREF    := SEArray(oXmlAle:_ALE_REF)
	aCONV   := SEArray(oXmlAle:_ALE_CONV)
	aOBS    := SEArray(oXmlAle:_ALE_OBS)  
                         
	For nX := 1 To Len(aREF)
	
		cSequen := Val(cSequen)+1
		cSequen := StrZero(cSequen, TamSX3("ZA8_SEQUEN")[1])
		
		dbSelectArea("ZA8")
		Reclock("ZA8", .T.)
			ZA8->ZA8_FILIAL := xFilial("ZA8")
			ZA8->ZA8_CODIGO := cCabec        
			ZA8->ZA8_SEQUEN := cSequen
			ZA8->ZA8_COD    := aCOD[nX]:TEXT
			ZA8->ZA8_REF    := cToD(aREF[nX]:TEXT)
			ZA8->ZA8_CONV   := Val(aCONV[nX]:TEXT)
			ZA8->ZA8_OBS    := aOBS[nX]:TEXT
		MsUnlock()
	
	Next nX
	
Return

Static Function SEResumo(oXmlRes, cCabec)

	SEProc("Salvandao dados de resumo...")     
	
	If SEVer(@oXmlRes, '_RES_CONS')
		Return
	EndIf  

	dbSelectArea("ZA9")
	Reclock("ZA9", .T.)
		ZA9->ZA9_FILIAL := xFilial("ZA9")
		ZA9->ZA9_CODIGO := cCabec
		ZA9->ZA9_CONS   := Val(oXmlRes:_RES_CONS:TEXT)
		ZA9->ZA9_CONP   := Val(oXmlRes:_RES_COMP:TEXT)
		ZA9->ZA9_ATU    := Val(oXmlRes:_RES_ATU:TEXT)
		ZA9->ZA9_MFAT   := Val(oXmlRes:_RES_MFAT:TEXT)
		ZA9->ZA9_DTMFAT := cToD(oXmlRes:_RES_MFAT_DT:TEXT)
		ZA9->ZA9_MFCONV := Val(oXmlRes:_RES_MFAT_CONV:TEXT)
		ZA9->ZA9_MACU   := Val(oXmlRes:_RES_MACU:TEXT)
		ZA9->ZA9_DTMACU := cToD(oXmlRes:_RES_MACU_DT:TEXT)
		ZA9->ZA9_MCCONV := Val(oXmlRes:_RES_MACU_CONV:TEXT)
		ZA9->ZA9_MACU12 := Val(oXmlRes:_RES_MACU12:TEXT)
		ZA9->ZA9_DTMC12 := cToD(oXmlRes:_RES_MACU12_DT:TEXT)
		ZA9->ZA9_MCNV12 := Val(oXmlRes:_RES_MACU12_CONV:TEXT)
		ZA9->ZA9_VENCER := Val(oXmlRes:_RES_AVENCER:TEXT)
		ZA9->ZA9_VENCDS := Val(oXmlRes:_RES_VENCIDOS:TEXT)
		ZA9->ZA9_QDETIT := Val(oXmlRes:_RES_VENC_QDETIT:TEXT)
		ZA9->ZA9_ATRASO := Val(oXmlRes:_RES_ATRASO:TEXT)
		ZA9->ZA9_ATCONV := Val(oXmlRes:_RES_ATR_CONV:TEXT)
	MsUnlock()
	
Return

Static Function SEAtualizacao(oXmlAtu, cCabec)

	SEProc("Salvandao dados de atualizações...")
                              
	If SEVer(@oXmlAtu, '_ATU_MENSAL')
		Return
	EndIf  
	
	dbSelectArea("ZAA")
	Reclock("ZAA", .T.)
		ZAA->ZAA_FILIAL := xFilial("ZAA")
		ZAA->ZAA_CODIGO := cCabec
		ZAA->ZAA_MENSAL := Val(oXmlAtu:_ATU_MENSAL:TEXT)
		//ZAA->ZAA_QUINZE := Val(oXmlAtu:_ATU_QUINZENAL:TEXT)
		ZAA->ZAA_1DEZ   := Val(oXmlAtu:_ATU_1DEZ:TEXT)
		ZAA->ZAA_2DEZ   := Val(oXmlAtu:_ATU_2DEZ:TEXT)

	MsUnlock()
	
Return

Static Function SENota(oXmlNot, cCabec)

	SEProc("Salvando nota geral...")

	If oXmlNot == Nil
		Return
	EndIf
	
	ZA1->(DbSetOrder(1))
	ZA1->(DbGoTop())
	
	If ZA1->(DbSeek(xFilial("ZA1")+cCabec))
		RecLock("ZA1", .F.)
			ZA1->ZA1_NOTA := oXmlNot:TEXT
		MsUnlock()
	EndIf
	
Return

//Verifica se a tag xml existe
Static Function SEVer(oXml, xTag)

	Local lRet
	
	Private _oXml := oXml
	
	lRet := _oXml == Nil
	
	If !lRet
			
		lRet := Type("_oXml:"+xTag) == "U"
		
	EndIf

Return lRet

//Retorna mensagem do status do CCB (conforme tabela enviada pelos mesmos).
Static Function SEStatus(cStatus)

	Local cMsg    := ""
	Local nStatus := Val(cStatus)
	
	Do Case
	
		Case nStatus == 0
			cMsg := "Sem pendencias. Consulta realizada."
		Case nStatus == 1
			cMsg := "Email e/ou Senha inválido(s)."
		Case nStatus == 2
			cMsg := "Senha expirada. Favor entrar no site para atualizar. A senha expira a cada 3 meses."
		Case nStatus == 3
			cMsg := "Consultas bloqueadas devida a falta de envio de arquivo de atualizações."
		Case nStatus == 4
			cMsg := "Consultas bloqueadas devida as faltas em reuniões plenárias."
		Case nStatus == 5
			cMsg := "Número do CNPJ inválido. CNPJ deve conter apenas números e ter tamanho 8."
		Otherwise
			cMsg := "Status desconhecido, entre em contato com suporte da CCB."
	
	EndCase

Return cMsg
     
//Busca os dados do XML do CCB
Static Function SEXml(_cCNPJ)

	Local cUrl   := SuperGetMV("SE_CCBURL",.F.,"http://www.ccb.inf.br/Conveniado/Consulta/ConsXml.asp")
	Local cParams:= "Email=%Email%&Senha=%Senha%&CNPJ=%CNPJ%"
	Local cEmail := SuperGetMV("SE_CCBUSER",.F.,"",)
	Local cSenha := SuperGetMV("SE_CCBPASS",.F.,"",)
	Local cXml   := ""
	Local cCNPJ  := _cCNPJ
	
	If Empty(cEmail) .Or. Empty(cSenha)
		SEMsg("Parâmetros de acesso a consulta inválidos!" + CRLF + "Entrar em contato com suporte.", "ERRO!", MSG_ERRO)
		Return ""
	EndIf
	
	cCNPJ := StrTran(cCNPJ, " ", "")
	cCNPJ := StrTran(cCNPJ, "-", "")
	cCNPJ := StrTran(cCNPJ, ".", "")
	cCNPJ := Left(cCNPJ, 8)//Pega apenas o inicial do CNPJ
	
	cParams := StrTran(cParams, "%Email%", cEmail)
	cParams := StrTran(cParams, "%Senha%", cSenha)
	cParams := StrTran(cParams, "%CNPJ%" , cCNPJ)
	
	cXml := HttpGet(cUrl, cParams)
	cXml := AllTrim(cXml)
	cXml := StrTran(cXml, Chr(10), "")
	cXml := StrTran(cXml, Chr(13), "")

Return cXml
                                 

//Inicio funÃ§Ãµes auxiliares

//Caso venha um objeto, retorna um array, para garantir o loop
Static Function SEArray(oObj)

	If ValType(oObj) == "A"
		Return oObj
	Else
		Return {oObj}
	EndIf

Return

//Mensagem e regua de processamento
Static Function SEProc(cMsg)

	If ValType(cMsg) == "N"
		
		If lAuto
			Conout("ProcRegua("+cValToChar(cMsg)+")")
		Else
			ProcRegua(cMsg)
		EndIf
		
		Return    
		
	EndIf

	If lAuto
		Conout("Processando: " + cValToChar(cMsg))
	Else
		IncProc(cMsg)
	EndIf

Return

//Mensagens em geral, utilizada para interaÃ§Ã£o ou nÃ£o com usuÃ¡rio
Static Function SEMsg(cMsg, cTitulo, cTipo)
	
	If lAuto
		Conout("[" + cTipo + "] " + cTitulo + ": " + cMsg)
	Else
		MsgBox(cMsg, cTitulo, cTipo)
	EndIf

Return

//Fim funÃ§Ãµes auxiliares

//REVISAO 000 - FABRICIO EDUARDO RECHE - 06/10/2014 - Criacao
//REVISAO 001 - FABRICIO EDUARDO RECHE - 31/10/2014 - Adicionado novas tags do XML e removida antiga
