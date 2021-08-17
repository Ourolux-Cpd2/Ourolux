#Include "Protheus.ch"

//Tela de consulta CCB
User Function SEFINA03()

	Local _oDlg
	Local oGetDados
	Local oTFolder 
	Local oPanelTop
	Local oPanelBot
	Local bWhile
	Local cTitulo   := ""
	Local cSeek 	:= ""
	Local aNoFields := {"ZA1_CLIENT", "ZA1_LOJA", "ZA1_STRXML"}
	Local aButtons 	:= {}
	Local aSize 	:= MsAdvSize()
	Local aCols 	:= {}
	Local aHeader 	:= {}
	                 
	Private cUFTST
	Private nLinIni := 010
	Private nColIni := 010
	Private nBreak 	:= 035
	Private nCBrea 	:= 100
	Private nCount 	:= 000
	Private nLimit 	:= 002
	Private nAltura	:= 011
	Private nLargura:= 059
	Private nLin 	:= nLinIni
	Private nCol	:= nColIni

	MsgRun("Carregando", "Aguarde, atualizado dados do cliente", {|| U_SEFINA02(SA1->A1_COD, SA1->A1_LOJA)})
		
	AADD(aButtons,{"S", {|| SEXML(oGetDados)}, "Visualizar Arquivo XML"})
		
	cSeek := xFilial("ZA1")+SA1->(A1_COD+A1_LOJA)
	bWhile:= {|| ZA1_FILIAL+ZA1_CLIENT+ZA1_LOJA }
	
	FillGetDados(2, "ZA1", 2, cSeek, bWhile,,aNoFields,,,,,,aHeader, aCols)
	                                                           
	//Ordena por data e hora
	aSort(aCols,,, {|x, y| dToS(x[2])+x[3] > dToS(y[2])+y[3] })
	
	If Empty(aCols) .Or. (Len(aCols) == 1 .And. Empty(aCols[1][1]))
		MsgInfo("Não foram encontrados registros de consultas ao CCB", "Atenção")
		Return
	EndIf
	
	DbSelectArea("ZA1")
	DbSetOrder(1)
	DbSeek(xFilial("ZA1")+aCols[1][1])
	
	cTitulo += "Consulta CCB: ["
	cTitulo += AllTrim(SA1->A1_COD) + "/"
	cTitulo += AllTrim(SA1->A1_LOJA) + "] "
	cTitulo += AllTrim(SA1->A1_NOME)

	DEFINE MSDIALOG _oDlg TITLE  cTitulo FROM 170,180 TO 700,1100 PIXEL
	
		//Panel separador de cima
		oPanelTop := tPanel():Create(_oDlg,,,,,,,,,100,75)
		oPanelTop:Align := CONTROL_ALIGN_TOP
		//Panel separador de baixo
		oPanelBot := tPanel():Create(_oDlg,,,,,,,,,100,75)
		oPanelBot:Align := CONTROL_ALIGN_ALLCLIENT
	                              
		//ZA1
		oGetDados:= MsNewGetDados():New(0,0,0,0,GD_DELETE,,,,,,,,,,oPanelTop, aHeader, aCols)
		oGetDados:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
		oGetDados:oBrowse:bLDblClick := {|| MsgRun("Aguarde, atualizando os dados de cada pasta de informações", "Atualizando dados", {|| SEPosiciona(oGetDados:aCols[oGetDados:nAt][1], @oTFolder)}) }
				
		//ZA2-ZAA
		oTFolder:= TFolder():New(0,0,,,oPanelBot,,,,.T.)
		oTFolder:Align := CONTROL_ALIGN_ALLCLIENT
		
		SEFolders(@oTFolder)
	
	ACTIVATE MSDIALOG _oDlg CENTERED ON INIT EnchoiceBar(_oDlg, {|| _oDlg:End()},{|| _oDlg:End()},,aButtons)

Return

Static Function SEAtualizacao(oTFolder)

	oTFolder:AddItem("Atualização do cliente", .T.) 
	
	@ nLin+00, @nCol SAY RetTitle("ZAA_MENSAL") OF oTFolder:aDialogs[Len(oTFolder:aDialogs)] PIXEL
	@ nLin+10, @nCol MSGET ZAA->ZAA_MENSAL SIZE nLargura, nAltura OF oTFolder:aDialogs[Len(oTFolder:aDialogs)] PIXEL When .F. HasButton
	
	nCol+= nCBrea
	
	@ nLin+00, @nCol SAY RetTitle("ZAA_QUINZE") OF oTFolder:aDialogs[Len(oTFolder:aDialogs)] PIXEL
	@ nLin+10, @nCol MSGET ZAA->ZAA_QUINZE SIZE nLargura, nAltura OF oTFolder:aDialogs[Len(oTFolder:aDialogs)] PIXEL When .F. HasButton
	
	nCol:=nColIni
	nLin:=nLinIni
	
Return

Static Function SEResumo(oTFolder)

	Local oScroll
	Local oPanel

	oTFolder:AddItem("Resumo do cliente", .T.)
	
	oScroll:= TSCrollArea():New(oTFolder:aDialogs[Len(oTFolder:aDialogs)],01,01,100,100,.T.,.T.,.T.)
	oScroll:Align := CONTROL_ALIGN_ALLCLIENT
	
	oPanel:= TPanel():Create(oScroll,01,100,"",,,,,,100,100)
	oPanel:Align := CONTROL_ALIGN_ALLCLIENT
	
	oScroll:SetFrame(oPanel)
								    
	@ nLin+00, @nCol SAY RetTitle("ZA9_CONS") OF oPanel PIXEL
	@ nLin+10, @nCol MSGET ZA9->ZA9_CONS SIZE nLargura, nAltura OF oPanel PIXEL When .F. HasButton
	
	nCol+= nCBrea
	
	@ nLin+00, @nCol SAY RetTitle("ZA9_CONP") OF oPanel PIXEL
	@ nLin+10, @nCol MSGET ZA9->ZA9_CONP SIZE nLargura, nAltura OF oPanel PIXEL When .F. HasButton
	
	nCol+= nCBrea   
							    
	@ nLin+00, @nCol SAY RetTitle("ZA9_ATU") OF oPanel PIXEL
	@ nLin+10, @nCol MSGET ZA9->ZA9_ATU SIZE nLargura, nAltura OF oPanel PIXEL When .F. HasButton
	
	nCol+= nCBrea   
	
	@ nLin+00, @nCol SAY RetTitle("ZA9_MFAT") OF oPanel PIXEL
	@ nLin+10, @nCol MSGET ZA9->ZA9_MFAT SIZE nLargura, nAltura OF oPanel PIXEL When .F. HasButton
	
	nCol:=nColIni
	nLin+=nBreak  
								    
	@ nLin+00, @nCol SAY RetTitle("ZA9_DTMFAT") OF oPanel PIXEL
	@ nLin+10, @nCol MSGET ZA9->ZA9_DTMFAT SIZE nLargura, nAltura OF oPanel PIXEL When .F. HasButton
	
	nCol+= nCBrea     
		
	@ nLin+00, @nCol SAY RetTitle("ZA9_MFCONV") OF oPanel PIXEL
	@ nLin+10, @nCol MSGET ZA9->ZA9_MFCONV SIZE nLargura, nAltura OF oPanel PIXEL When .F. HasButton
	
	nCol+= nCBrea      
	
	@ nLin+00, @nCol SAY RetTitle("ZA9_MACU") OF oPanel PIXEL
	@ nLin+10, @nCol MSGET ZA9->ZA9_MACU SIZE nLargura, nAltura OF oPanel PIXEL When .F. HasButton  

	nCol+= nCBrea     
		
	@ nLin+00, @nCol SAY RetTitle("ZA9_DTMACU") OF oPanel PIXEL
	@ nLin+10, @nCol MSGET ZA9->ZA9_DTMACU SIZE nLargura, nAltura OF oPanel PIXEL When .F. HasButton
	
	nCol:=nColIni
	nLin+=nBreak       
	
	@ nLin+00, @nCol SAY RetTitle("ZA9_MCCONV") OF oPanel PIXEL
	@ nLin+10, @nCol MSGET ZA9->ZA9_MCCONV SIZE nLargura, nAltura OF oPanel PIXEL When .F. HasButton  
	
	nCol+= nCBrea     
		
	@ nLin+00, @nCol SAY RetTitle("ZA9_MACU12") OF oPanel PIXEL
	@ nLin+10, @nCol MSGET ZA9->ZA9_MACU12 SIZE nLargura, nAltura OF oPanel PIXEL When .F. HasButton  
	
	nCol+= nCBrea      
	
	@ nLin+00, @nCol SAY RetTitle("ZA9_DTMC12") OF oPanel PIXEL
	@ nLin+10, @nCol MSGET ZA9->ZA9_DTMC12 SIZE nLargura, nAltura OF oPanel PIXEL When .F. HasButton  
	
	nCol+= nCBrea     
		
	@ nLin+00, @nCol SAY RetTitle("ZA9_MCNV12") OF oPanel PIXEL
	@ nLin+10, @nCol MSGET ZA9->ZA9_MCNV12 SIZE nLargura, nAltura OF oPanel PIXEL When .F. HasButton  
	
	nCol:=nColIni
	nLin+=nBreak       
	
	@ nLin+00, @nCol SAY RetTitle("ZA9_VENCER") OF oPanel PIXEL
	@ nLin+10, @nCol MSGET ZA9->ZA9_VENCER SIZE nLargura, nAltura OF oPanel PIXEL When .F. HasButton  
	
	nCol+= nCBrea     
		
	@ nLin+00, @nCol SAY RetTitle("ZA9_VENCDS") OF oPanel PIXEL
	@ nLin+10, @nCol MSGET ZA9->ZA9_VENCDS SIZE nLargura, nAltura OF oPanel PIXEL When .F. HasButton  
	
	nCol+= nCBrea      
	
	@ nLin+00, @nCol SAY RetTitle("ZA9_QDETIT") OF oPanel PIXEL
	@ nLin+10, @nCol MSGET ZA9->ZA9_QDETIT SIZE nLargura, nAltura OF oPanel PIXEL When .F. HasButton  
	
	nCol+= nCBrea     
		
	@ nLin+00, @nCol SAY RetTitle("ZA9_ATRASO") OF oPanel PIXEL
	@ nLin+10, @nCol MSGET ZA9->ZA9_ATRASO SIZE nLargura, nAltura OF oPanel PIXEL When .F. HasButton  
	
	nCol:=nColIni
	nLin+=nBreak       
	
	@ nLin+00, @nCol SAY RetTitle("ZA9_ATCONV") OF oPanel PIXEL
	@ nLin+10, @nCol MSGET ZA9->ZA9_ATCONV SIZE nLargura, nAltura OF oPanel PIXEL When .F. HasButton 
	
	nCol:=nColIni
	nLin:=nLinIni
	
Return

Static Function SEAlerta(oTFolder)  

	Local oAlertas         
	Local aColsA := {}
	Local aHeaderA := {}
                                                     
	oTFolder:AddItem("Alertas do cliente", .T.)
	
	SEZATAB("ZA8", @aHeaderA, @aColsA, @oAlertas)
		
	oAlertas:= MsNewGetDados():New(0,0,0,0,GD_DELETE,,{},,,,,,,,oTFolder:aDialogs[Len(oTFolder:aDialogs)], aHeaderA, aColsA)
	oAlertas:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
	
Return

Static Function SEInformacao(oTFolder)
	
    Local oInformacoes
    Local aColsI := {}
    Local aHeaderI := {}
                                                     
	oTFolder:AddItem("Informações do cliente", .T.)
	
	SEZATAB("ZA7", @aHeaderI, @aColsI, @oInformacoes)
		
	oInformacoes:= MsNewGetDados():New(0,0,0,0,GD_DELETE,,{},,,,,,,,oTFolder:aDialogs[Len(oTFolder:aDialogs)], aHeaderI, aColsI)
	oInformacoes:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
	
Return

Static Function SEExperiencia(oTFolder)   

	Local oExperiencias
	Local aColsE := {}    
	Local aHeaderE := {}
                                                     
	oTFolder:AddItem("Experiências do cliente", .T.)
	
	SEZATAB("ZA6", @aHeaderE, @aColsE, @oExperiencias)
		
	oExperiencias:= MsNewGetDados():New(0,0,0,0,GD_DELETE,,{},,,,,,,,oTFolder:aDialogs[Len(oTFolder:aDialogs)], aHeaderE, aColsE)
	oExperiencias:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
	
Return

Static Function SERisco(oTFolder)

	oTFolder:AddItem("Riscos apresentados", .T.)
							    
	@ nLin+00, @nCol SAY RetTitle("ZA5_DTRISC") OF oTFolder:aDialogs[Len(oTFolder:aDialogs)] PIXEL
	@ nLin+10, @nCol MSGET ZA5->ZA5_DTRISC SIZE nLargura, nAltura OF oTFolder:aDialogs[Len(oTFolder:aDialogs)] PIXEL When .F. HasButton

Return

Static Function SEPosiciona(cCodigo, oTFolder)

	Local nX
	Local nJ
	Local nLen
	Local nLen2
	Local _cAlias := ""
	
	Private _uVer
			
	ZA1->(DbSeek(xFilial("ZA1")+cCodigo))
	ZA2->(DbSeek(xFilial("ZA2")+ZA1->ZA1_CODIGO))
	ZA3->(DbSeek(xFilial("ZA3")+ZA1->ZA1_CODIGO))
	ZA4->(DbSeek(xFilial("ZA4")+ZA1->ZA1_CODIGO))
	ZA5->(DbSeek(xFilial("ZA5")+ZA1->ZA1_CODIGO))
	ZA6->(DbSeek(xFilial("ZA6")+ZA1->ZA1_CODIGO))
	ZA7->(DbSeek(xFilial("ZA7")+ZA1->ZA1_CODIGO))
	ZA8->(DbSeek(xFilial("ZA8")+ZA1->ZA1_CODIGO))
	ZA9->(DbSeek(xFilial("ZA9")+ZA1->ZA1_CODIGO))
	ZAA->(DbSeek(xFilial("ZAA")+ZA1->ZA1_CODIGO))
	
	If ValType(oTFolder) == "O"       
	
		nLen := Len(oTFolder:aDialogs)
		
		For nX := 1 To nLen
		
			nLen2 := Len(oTFolder:aDialogs[nX]:oWnd:aControls)
			
			For nJ := 1 To nLen2
							
				//Veriavel deve ser aberta para o Type funcionar
				_uVer := oTFolder:aDialogs[nX]:oWnd:aControls[nJ]
				
				If ValType(_uVer) == "O"
				
					//Caso seja um MsNewGetDados, precisa atualizar os dados do aCols e do aHeader
					If Type("_uVer:oMother") != "U"    
					
						_cAlias := _uVer:oMother:aCols[1][Len(_uVer:oMother:aCols[1])-2]
					
						If _cAlias != "ZA1"
							SEZATAB(_cAlias, @_uVer:oMother:aHeader, @_uVer:oMother:aCols, @_uVer:oMother)
						EndIf
					EndIf
					
					_uVer:Refresh()
				
				EndIf
				
			Next nJ
			
		Next nX
		
	EndIf
	
Return

Static Function SEFolders(oTFolder, nPasta)

	Default nPasta := 1
	
	SEPosiciona(ZA1->ZA1_CODIGO)

	SECliente(@oTFolder)
	SEReceita(@oTFolder)
	SEColigadas(@oTFolder)
	SERisco(@oTFolder)
	SEExperiencia(@oTFolder)
	SEInformacao(@oTFolder)
	SEAlerta(@oTFolder)
	SEResumo(@oTFolder)
	SEAtualizacao(@oTFolder)
	
	oTFolder:ShowPage(nPasta)
	
Return

Static Function SECliente(oTFolder)

	oTFolder:AddItem("Dados do cliente", .T.)
							    
	@ nLin+00, @nCol SAY RetTitle("ZA2_CNPJ") OF oTFolder:aDialogs[Len(oTFolder:aDialogs)] PIXEL
	@ nLin+10, @nCol MSGET ZA2->ZA2_CNPJ SIZE nLargura, nAltura OF oTFolder:aDialogs[Len(oTFolder:aDialogs)] PIXEL When .F. HasButton
	
	nCol+= nCBrea
	
	@ nLin+00, @nCol SAY RetTitle("ZA2_RAZAO") OF oTFolder:aDialogs[Len(oTFolder:aDialogs)] PIXEL
	@ nLin+10, @nCol MSGET ZA2->ZA2_RAZAO SIZE nLargura*3, nAltura OF oTFolder:aDialogs[Len(oTFolder:aDialogs)] PIXEL When .F. HasButton
	
	nCol:=nColIni
	nLin+=nBreak 
							    
	@ nLin+00, @nCol SAY RetTitle("ZA2_CIDADE") OF oTFolder:aDialogs[Len(oTFolder:aDialogs)] PIXEL
	@ nLin+10, @nCol MSGET ZA2->ZA2_CIDADE SIZE nLargura, nAltura OF oTFolder:aDialogs[Len(oTFolder:aDialogs)] PIXEL When .F. HasButton
	
	nCol+= nCBrea   
	
	@ nLin+00, @nCol SAY RetTitle("ZA2_UF") OF oTFolder:aDialogs[Len(oTFolder:aDialogs)] PIXEL
	@ nLin+10, @nCol MSGET cUFTST := ZA2->ZA2_UF SIZE nLargura, nAltura OF oTFolder:aDialogs[Len(oTFolder:aDialogs)] PIXEL When .F. HasButton
	
	nCol:=nColIni
	nLin+=nBreak  
								    
	@ nLin+00, @nCol SAY "Data de fundação da empresa" OF oTFolder:aDialogs[Len(oTFolder:aDialogs)] PIXEL
	@ nLin+10, @nCol MSGET ZA2->ZA2_DTFUND SIZE nLargura, nAltura OF oTFolder:aDialogs[Len(oTFolder:aDialogs)] PIXEL When .F. HasButton
	
	nCol+= nCBrea   
	
	@ nLin+00, @nCol SAY "Data da primeira compra" OF oTFolder:aDialogs[Len(oTFolder:aDialogs)] PIXEL
	@ nLin+10, @nCol MSGET ZA2->ZA2_PEXP SIZE nLargura, nAltura OF oTFolder:aDialogs[Len(oTFolder:aDialogs)] PIXEL When .F. HasButton
	
	nCol:=nColIni
	nLin+=nBreak       
	
	@ nLin+00, @nCol SAY "Data de atualização" OF oTFolder:aDialogs[Len(oTFolder:aDialogs)] PIXEL
	@ nLin+10, @nCol MSGET ZA2->ZA2_ATU SIZE nLargura, nAltura OF oTFolder:aDialogs[Len(oTFolder:aDialogs)] PIXEL When .F. HasButton
	
	nCol:=nColIni
	nLin:=nLinIni
	
Return

Static Function SEReceita(oTFolder) 

	Local oCombo

	oTFolder:AddItem("Dados da Receita Federal", .T.)    
	
	@ nLin+00, @nCol SAY "Data de referência" OF oTFolder:aDialogs[Len(oTFolder:aDialogs)] PIXEL
	@ nLin+10, @nCol MSGET dToC(ZA3->ZA3_DTCONS) SIZE nLargura, nAltura OF oTFolder:aDialogs[Len(oTFolder:aDialogs)] PIXEL When .F. HasButton
	
	nCol+= nCBrea                                                                                                                   
	
	@ nLin+00, @nCol SAY "Cadastrado na Receita Federal?" OF oTFolder:aDialogs[Len(oTFolder:aDialogs)] PIXEL
	@ nLin+10, @nCol ComboBox oCombo SIZE nLargura, nAltura ITEMS {IIF(ZA3->ZA3_CAD == "S","Sim", "Não")} OF oTFolder:aDialogs[Len(oTFolder:aDialogs)] PIXEL
	
	nCol:=nColIni
	nLin+=nBreak 
	
	@ nLin+00, @nCol SAY "Natureza Jurídica" OF oTFolder:aDialogs[Len(oTFolder:aDialogs)] PIXEL
	@ nLin+10, @nCol MSGET ZA3->ZA3_NATJUR SIZE nLargura, nAltura OF oTFolder:aDialogs[Len(oTFolder:aDialogs)] PIXEL When .F. HasButton
	
	nCol+= nCBrea   
							    
	@ nLin+00, @nCol SAY "Atividade Econômica" OF oTFolder:aDialogs[Len(oTFolder:aDialogs)] PIXEL
	@ nLin+10, @nCol MSGET ZA3->ZA3_ATIV SIZE nLargura*3, nAltura OF oTFolder:aDialogs[Len(oTFolder:aDialogs)] PIXEL When .F. HasButton
	
	nCol:=nColIni
	nLin+=nBreak  
								    
	@ nLin+00, @nCol SAY "Situação" OF oTFolder:aDialogs[Len(oTFolder:aDialogs)] PIXEL
	@ nLin+10, @nCol MSGET ZA3->ZA3_SIT SIZE nLargura, nAltura OF oTFolder:aDialogs[Len(oTFolder:aDialogs)] PIXEL When .F. HasButton
	
	nCol+= nCBrea   
	
	@ nLin+00, @nCol SAY "Detalhe da Situação" OF oTFolder:aDialogs[Len(oTFolder:aDialogs)] PIXEL
	@ nLin+10, @nCol MSGET ZA3->ZA3_MOTSIT SIZE nLargura*3, nAltura OF oTFolder:aDialogs[Len(oTFolder:aDialogs)] PIXEL When .F. HasButton
	
	nCol:=nColIni
	nLin:=nLinIni
	
Return

Static Function SEColigadas(oTFolder)  

	Local oColigadas
	Local aColsC := {}     
	Local aHeaderC := {}
                                  
	oTFolder:AddItem("Empresas coligadas ao cliente", .T.)
	
	SEZATAB("ZA4", @aHeaderC, @aColsC, @oColigadas)
		
	oColigadas:= MsNewGetDados():New(0,0,0,0,GD_DELETE,,{},,,,,,,,oTFolder:aDialogs[Len(oTFolder:aDialogs)], aHeaderC, aColsC)
	oColigadas:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
	
Return

Static Function SEXML(oGetDados)
                                   
	Local cCodigo := oGetDados:aCols[oGetDados:nAt][1]
	Local cXml := Posicione("ZA1", 1, xFilial("ZA1")+cCodigo, "ZA1_STRXML")
	Local cMask := "Arquivos XML" + "(*.XML)|*.xml|"
	Local cFile := ""
	Local _oFont
	Local _oDlg
	Local oMemo
	
	Define Font _oFont Name "Mono AS" Size 5,12
	
	Define MsDialog _oDlg Title "Arquivo Xml" From 3, 0 To 340, 417 Pixel
	
		@ 5, 5 Get oMemo Var cXml Memo Size 200, 145 Of _oDlg Pixel
		oMemo:bRClicked := {|| AllWaysTrue() }
		oMemo:oFont := _oFont
		
		Define SButton From 153,175 Type 01 Action _oDlg:End() Enable Of _oDlg Pixel
		Define SButton From 153,145 Type 13 Action (cFile := cGetFile(cMask, ""), IIF(Empty(cFile), .T., MemoWrite(cFile, cXml)) ) Enable Of _oDlg Pixel
	
	Activate MsDialog _oDlg Center

Return

Static Function SEZATAB(_cAlias, _aHeader, _aCols, oMsGet)

	Local aNoFields := {_cAlias + "_CODIGO"}

	_aHeader := {}
	_aCols := {}

	cSeek := xFilial(_cAlias)+ZA1->ZA1_CODIGO//Codigo da tabela original
	bWhile:= {|| &(_cAlias+"_FILIAL+"+_cAlias+"_CODIGO") }
	
	FillGetDados(2, _cAlias, 1, cSeek, bWhile,,aNoFields,,,,,,_aHeader, _aCols)
	
	If ValType(oMsGet) == "O"
		oMsGet:Refresh()
	EndIf

Return

//REVISAO 000 - FABRICIO EDUARDO RECHE - 06/10/2014 - Criacao
//REVISAO 001 - FABRICIO EDUARDO RECHE - 31/10/2014 - Criacao - Adicionada atualização automatica dos dados do cliente