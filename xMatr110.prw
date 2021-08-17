#INCLUDE "MATR110.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "Colors.ch"
#INCLUDE "FWPrintSetup.ch"
#INCLUDE "ParmType.ch"

#DEFINE COMP_DATE "20191209"

#DEFINE IMP_SPOOL 2
#DEFINE IMP_PDF   6
#DEFINE PICT_001   "@E 9,999,999.99"
#DEFINE PICT_002   "@E 9,999,999.9999"


//-------------------------------------------------------------------------------------
/*/{Protheus.doc} xMatr110
Pedido de Compras e Autorizacao de Entrega

@type 		function
@author 	Roberto Souza
@since 		12/01/2017
@version 	P11 
 
@return nil
/*/    
//-------------------------------------------------------------------------------------
User Function xMatr110( cAlias, nReg, nOpcx )

	Local uRet := .T.
	Local nOpc := 1
    
	If IsInCallStack("MATA120")
		nOpc := Aviso( "Pedido de Compra ["+COMP_DATE+"]" , "Deseja imprimir o pedido Modo Grafico ou o pedido Padrão Protheus?",{"Grafico","Padrao"},2)
		        
		If nOpc == 1
			U_xMyM110( cAlias, nReg, nOpcx )
		Else
			uRet := MATR110( "SC7", SC7->(RECNO()), 2 )
		EndIf
	Else
		U_xMyM110( cAlias, nReg, nOpcx )
	EndIf
	
Return( uRet )


//-------------------------------------------------------------------------------------
/*/{Protheus.doc} xMyM110
Pedido de Compras e Autorizacao de Entrega

@type 		function
@author 	Roberto Souza
@since 		12/01/2017
@version 	P11 
 
@return nil
/*/    
//-------------------------------------------------------------------------------------
User Function xMyM110( cAlias, nReg, nOpcx )

	Local aArea         := GetArea()
	Local oLabel
	Local cFilePrint	:= ""
	Local oSetup
	Local aDevice  		:= {}
	Local cSession     	:= GetPrinterSession()
	Local cPrinter	  	:= GetProfString( cSession,"DEFAULT","",.T. )
	Local nRet 			:= 0
	Local Nx 			:= 0
	Local aTipos 		:= {}
	Local nTipo  		:= 1
	Local lGoPrint 		:= .F.
	Local lTela 		:= .T.
	Local lContinua     := .F.
	Local bParam        := {|| SetPergs() }

	Default cAlias      := IIf(Type("PARAMIXB") <> "U" .And. Len(PARAMIXB) > 1, PARAMIXB[01],"")
	Default nReg      	:= IIf(Type("PARAMIXB") <> "U" .And. Len(PARAMIXB) > 1, PARAMIXB[02],0)
	Default nOpcx      	:= IIf(Type("PARAMIXB") <> "U" .And. Len(PARAMIXB) > 1, PARAMIXB[03],0)

	Private l2Line      := .T.
	Private lAuto 		:= ( nReg <> Nil .And. nReg > 0)
	
	If lAuto
		lContinua := .T.
	Else
		lContinua := SetPergs()
	EndIf

	If lContinua
	
		cFilePrint := "pedcom_"+StrZero(nTipo,3)+"_"+Dtos(MSDate())+StrTran(Time(),":","")
		
		AADD(aDevice,"DISCO") // 1
		AADD(aDevice,"SPOOL") // 2
		AADD(aDevice,"EMAIL") // 3
		AADD(aDevice,"EXCEL") // 4
		AADD(aDevice,"HTML" ) // 5
		AADD(aDevice,"PDF"  ) // 6
		
		nLocal       	:= If(GetProfString(cSession,"Local","SERVER",.T.)=="SERVER",1,2 )
		nOrientation 	:= If(GetProfString(cSession,"ORIENTATION","PORTRAIT",.T.)=="PORTRAIT",1,2)
		cDevice     	:= GetProfString(cSession,"PRINTTYPE","SPOOL",.T.)
		nPrintType      := aScan(aDevice,{|x| x == cDevice })
		nPrintType      := IIf( lTela, IMP_PDF, IMP_SPOOL )
		cPathDest       := GetProfString(cSession,"PATHDEST","C:\",.T.)
	
		lAdjustToLegacy := .F. // Inibe legado de resolução com a TMSPrinter
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Cria e exibe tela de Setup Customizavel                      ³
		//³ OBS: Utilizar include "FWPrintSetup.ch"                      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
		nFlags := PD_ISTOTVSPRINTER+ PD_DISABLEORIENTATION + PD_DISABLEPREVIEW + PD_DISABLEMARGIN+ PD_DISABLEPAPERSIZE
	
		oSetup := FWPrintSetup():New(nFlags, "PedCom")

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Caso não seja chamada automatica, define o botão de parametros ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !lAuto
			oSetup:SetUserParms( bParam )
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Define saida                                                 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oSetup:SetPropert(PD_PRINTTYPE   , nPrintType)
		oSetup:SetPropert(PD_ORIENTATION , nOrientation)
		oSetup:SetPropert(PD_DESTINATION , nLocal)
		oSetup:SetPropert(PD_MARGIN      , {0,0,0,0})
		oSetup:SetPropert(PD_PAPERSIZE   , DMPAPER_A4 /*2*/)
		oSetup:aOptions[6] := cPathDest
		
		If lTela // Chamada da impressão com tela
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Pressionado botão OK na tela de Setup                        ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			lGoPrint := oSetup:Activate() == PD_OK // PD_OK =1
		Else
			lGoPrint := .T.
		EndIf
	
		If lGoPrint
			oLabel := FWMSPrinter():New(cFilePrint, IMP_PDF, lAdjustToLegacy, /*cPathInServer*/, .T.,,@oSetup)
		
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Define saida de impressão                                    ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If oSetup:GetProperty(PD_PRINTTYPE) == IMP_SPOOL
				oLabel:nDevice := IMP_SPOOL
				oLabel:cPrinter := oSetup:aOptions[PD_VALUETYPE]
				If Len(oSetup:APRINTER) > 0
					oLabel:cPrinter := oSetup:APRINTER[01]
				EndIf
			ElseIf oSetup:GetProperty(PD_PRINTTYPE) == IMP_PDF
				oLabel:nDevice := IMP_PDF
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Define para salvar o PDF                                     ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				oLabel:cPathPDF := oSetup:aOptions[PD_VALUETYPE]
			Endif
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Salva os Parametros no Profile             ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			WriteProfString( cSession, "Local"      , If(oSetup:GetProperty(PD_DESTINATION)==1 ,"SERVER"    ,"CLIENT"    ), .T. )
			WriteProfString( cSession, "PRINTTYPE"  , If(oSetup:GetProperty(PD_PRINTTYPE)==1   ,"SPOOL"     ,"PDF"       ), .T. )
			WriteProfString( cSession, "ORIENTATION", If(oSetup:GetProperty(PD_ORIENTATION)==1 ,"PORTRAIT"  ,"LANDSCAPE" ), .T. )
			WriteProfString( cSession, "DEFAULT"    , oSetup:aOptions[PD_VALUETYPE], .T.)
			WriteProfString( cSession, "PATHDEST"   , oSetup:aOptions[6], .T.)
	
			If lTela
//				MsAguarde({|| U_xMtr110P( oLabel, oSetup, cAlias, nReg, nOpcx )},"Gerando impressão...","Pedido de Compra",.T.)	        
//				MsgRun( "Gerando impressão...", "Pedido de Compra", {|| CursorWait(),U_xMtr110P( oLabel, oSetup, cAlias, nReg, nOpcx  ),CursorArrow(), } )
				FWMsgRun(,{|| CursorWait(),U_xMtr110P( oLabel, oSetup, cAlias, nReg, nOpcx  ),CursorArrow()},,"Gerando impressão..." )

			EndIf
		Else
			MsgInfo("Relatório cancelado pelo usuário.")
		Endif
	
		If !lTela
			oLabel := Nil
			oSetup := Nil

		EndIf
	EndIf
	
	RestArea( aArea )
Return
 
 
Static Function SetPergs( lSilent )
	Local lRet 		:= .F.
	Local aParam 	:= Array(16)
	Local aPerg     := {}
	Local cParId    := "PEDCOM" //IIf( Empty(__cUserId),"000000",__cUserId)+ "-PEDCOM"

	Local aCombo05  := {"Sim","Não"}
	Local aCombo07  := {"Primária","Secundária","Todas"}
	Local aCombo08  := {"Pedido Compra","Aut. de Entrega"}
	Local aCombo10  := {"Liberados","Bloqueados","Ambos"}
	Local aCombo11  := {"Firmes", "Previstas", "Ambas"}
	Local aCombo12  := {"Moeda 1","Moeda 2","Moeda 3","Moeda 4","Moeda 5"}
	Local aCombo14  := {"Todos","Em Aberto","Atendidos"}
	Local aCombo15  := {"Modelo 1","Modelo 2","Modelo 3","Modelo 4"}
	Local aCombo16  := {"Código","Descrição"}

 
	Default lSilent := .F.
	
	aParam[01]	:= Space(06)
	aParam[02]	:= Space(06)
	aParam[03]	:= Stod(Space(08))
	aParam[04]	:= Stod(Space(08))
	aParam[05]	:= Space(03)
	aParam[06]	:= Space(10)
	aParam[07]	:= Space(10)
	aParam[08]	:= Space(20)
	aParam[09]	:= Space(02)
	aParam[10]	:= Space(02)
	aParam[11]	:= Space(06)
	aParam[12]	:= Space(02)
	aParam[13]	:= Space(50)
	aParam[14]	:= Space(01)
	aParam[15]	:= PadR("",Len("Modelo 1"))
	aParam[16]	:= PadR("",Len("Descrição"))

	/*01*/Aadd(aPerg,{1,"Do Pedido"				,aParam[01]	,"",".T.",,".T.",020,.F.})
	/*02*/Aadd(aPerg,{1,"Ate Pedido"			,aParam[02]	,"",".T.",,".T.",020,.T.})
	/*03*/Aadd(aPerg,{1,"A partir da Data"		,aParam[03]	,"",".T.",,".T.",040,.F.})
	/*04*/Aadd(aPerg,{1,"Ate a Data"			,aParam[04]	,"",".T.",,".T.",040,.T.})
	/*05*/Aadd(aPerg,{2,"Somente novos"			,aParam[05]	,aCombo05,040,".T.",.T.,".T."})
	/*06*/Aadd(aPerg,{1,"Descricao Produto"		,aParam[06]	,"",".T.",,".T.",040,.T.})
	/*07*/Aadd(aPerg,{2,"Qual Unid. de Med."	,aParam[07]	,aCombo07,040,".T.",.T.,".T."})
	/*08*/Aadd(aPerg,{2,"Imprime"				,aParam[08]	,aCombo08,060,".T.",.T.,".T."})
	/*09*/Aadd(aPerg,{1,"Numero de vias"		,aParam[09]	,"",".T.",,".T.",020,.F.})//"","","","",""})
	/*10*/Aadd(aPerg,{2,"Imprime Pedidos"		,aParam[10]	,aCombo10,040,".T.",.T.,".T."})
	/*11*/Aadd(aPerg,{2,"Considera SCs"			,aParam[11]	,aCombo11,040,".T.",.T.,".T."})
	/*12*/Aadd(aPerg,{2,"Qual a Moeda"			,aParam[12]	,aCombo12,040,".T.",.T.,".T."})
	/*13*/Aadd(aPerg,{1,"Endereco de Entrega"	,aParam[13]	,"",".T.",,".T.",100,.F.})
	/*14*/Aadd(aPerg,{2,"Lista quais"			,aParam[14]	,aCombo14,040,".T.",.T.,".T."})
	/*15*/Aadd(aPerg,{2,"Layout Impressão"		,aParam[15] ,aCombo15,040,".T.",.T.,".T."})
	/*16*/Aadd(aPerg,{2,"Coluna CCusto"			,aParam[16] ,aCombo16,040,".T.",.T.,".T."})


	If lSilent // Apenas Carrega
		For Nx := 1 To Len(aParam)
			aParam[Nx] := ParamLoad(__cUserId+"_"+cParId,aPerg,Nx,aParam[Nx])
		Next    

    	For Nx := 1 To Len(aPerg)
    		If aPerg[Nx][1] == 2 // Combo
    			cVar := ("MV_PAR"+StrZero(Nx,2))    			
				nScan := aScan(aPerg[Nx][4],{|x| AllTrim(x)== AllTrim(aParam[Nx])})
    			&(cVar) := IIf( nScan > 0, nScan, 1 )
    		Else
				cVar := ("MV_PAR"+StrZero(Nx,2))    			
    			&(cVar) := aParam[Nx]
    		EndIf
    	Next
    			
		lRet := .T.
	Else
	
		If ParamBox(aPerg,"Parâmetros",,,,,,,,cParId,.T.,.T.)
	    	lRet := .T.
			// Trata os retornos de combo como numericos
	    	For Nx := 1 To Len(aPerg)
	    		If aPerg[Nx][1] == 2 // Combo
	    			cVar := ("MV_PAR"+StrZero(Nx,2))    			
	    			&(cVar) := aScan(aPerg[Nx][4],{|x| AllTrim(x)== AllTrim(&(cVar))})
	    		EndIf
	    	Next
		EndIf
	EndIf
	
Return( lRet ) 
 
 
 
 
 


 
 
 
 
  
User Function xMtr110P( oLabel, oSetup, cAlias, nReg, nOpcx  )
	
	Local Nx			:= 0
	Local Nw			:= 0
	Local aForm         := {}
	Local cNoImp    	:= ""
	Local aRecImp   	:= {}
	Local nPagina 		:= 1 
	Local nNumPag       := 1
	Local nPed			:= 1
	Local cLogoD 		:= ""
	Local cLogoRel      := ""
	Local nLogo         := 2 // 1=Danfe; 2=Simplificado(lgrl01)
	Local aLogo         := {{095,096},{120,033}}  //{{095,096},{090,023}} 
	Local nRecnoSM0 	:= SM0->(Recno())
	Local cFiltro       := ""
	Local cUserId     	:= RetCodUsr()
	Local cMailFin 		:= GetMv("FS_MAILFIN",,"pagamentos@ourolux.com.br")

	Local nObs			:= 0
	Local nLeg          := 0
	
	Local aObs01 		:= {}
	Local aObs02 		:= {}
	Local aObs03 		:= {}
	Local aObs01A 		:= {}
	Local aObs01B 		:= {}	
	Local cComprador 	:= ""
	Local cAlter 		:= ""
	Local cAprov 		:= ""
                     
	Local cDesc0 		:= ""
	Local cDesc1 		:= ""
	Local cDesc2 		:= ""
	Local cDesc3 		:= ""
	Local cVDesc 		:= ""

	Local cEndEnt       := ""
	Local cEndCob       := ""	
	Local cCondPag      := ""	

	Local cTotIpi 		:= ""
	Local cTotIcms		:= ""
	Local cTotSeguro	:= ""
	Local cTotFrete		:= ""
	Local cTotDesp		:= ""
	Local cTotCImp		:= ""
	Local cTotMerc		:= ""
	Local cTotNF 		:= ""
	Local lNewObs		:= .T.

	Private nHori		:= 3.5 //3.9 //096774
	Private nVert		:= 3.60// 3.85
	Private oPrint      := oLabel
	Private nMaxItens   := 34  
	Private nMaxObs     := 18
	Private nLinObs    	:= 0   
	Private nModObs     := 2

	Private nModGrid 	:= 1 
	
	Private aPedidos    := {}
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Define as fontes usadas na impressao                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//oFather, cNameFont, nWidth, nHeight, lBold, lItalic, lUnderline
	oFont07    := TFontEx():New(oPrint,"Arial"      , 9,  7,.F.,.F.,.F.)
	oFont08    := TFontEx():New(oPrint,"Arial"      , 9,  8,.T.,.F.,.F.)
	oFont08n   := TFontEx():New(oPrint,"Arial"      , 9,  8,.T.,.T.,.F.)
	oFont08C   := TFontEx():New(oPrint,"Courier New", 8, 09,.T.,.T.,.F.)
	oFont08V   := TFontEx():New(oPrint,"Verdana"	, 8, 09,.T.,.T.,.F.)
	oFont10    := TFontEx():New(oPrint,"Arial"      , 8, 10,.T.,.F.,.F.)

	oFont09    := TFontEx():New(oPrint,"Courier New", 8, 09,.F.,.F.,.F.)
	oFont09n   := TFontEx():New(oPrint,"Courier New", 9, 11,.T.,.T.,.F.)

	oFont10n   := TFontEx():New(oPrint,"Arial"      , 9, 10,.T.,.T.,.F.)
	oFont10V   := TFontEx():New(oPrint,"Verdana"    , 9, 10,.T.,.T.,.F.)
	oFont11n   := TFontEx():New(oPrint,"Arial"		,10, 10,.T.,.T.,.F.)
	oFont11b   := TFontEx():New(oPrint,"Courier New",10, 10,.T.,.T.,.F.)
	oFont11    := TFontEx():New(oPrint,"Arial"      , 9, 11,.T.,.F.,.F.)
	oFont14    := TFontEx():New(oPrint,"Arial"      , 9, 14,.T.,.F.,.F.)
	oFont14n   := TFontEx():New(oPrint,"Arial"      , 9, 14,.T.,.T.,.F.)
	oFont16n   := TFontEx():New(oPrint,"Arial"      , 9, 16,.T.,.T.,.F.)
	oFont18    := TFontEx():New(oPrint,"Arial"      , 9, 18,.T.,.T.,.F.)
	oFont20    := TFontEx():New(oPrint,"Arial"      , 9, 20,.T.,.T.,.F.)
	oFont22    := TFontEx():New(oPrint,"Arial"      , 9, 24,.T.,.T.,.F.)

	oFont14V   := TFontEx():New(oPrint,"Verdana"    , 9, 12,.T.,.T.,.F.)
	oFont14W   := TFontEx():New(oPrint,"Verdana"    , 10, 18,.T.,.T.,.F.)
	oFont14X   := TFontEx():New(oPrint,"Verdana"    , 12, 20,.T.,.T.,.F.)
	    
	// Objeto box cinza        
	oBrush              := TBrush():New( , CLR_HGRAY )

	If Type("lPedido") != "L"
		lPedido := .F.
	Endif
	

	If lAuto
		SetPergs( .T. )
		
		DbSelectArea("SC7")
		DbGoto(nReg)
		MV_PAR01 := SC7->C7_NUM
		MV_PAR02 := SC7->C7_NUM
		MV_PAR03 := SC7->C7_EMISSAO
		MV_PAR04 := SC7->C7_EMISSAO
		MV_PAR05 := 2
		MV_PAR06 := IIf( Empty(MV_PAR06),"B1_DESC",MV_PAR06 )
	   	MV_PAR08 := SC7->C7_TIPO
		MV_PAR09 := 1
	  	MV_PAR10 := 3
		MV_PAR11 := 3
	  	MV_PAR14 := 1
	  	MV_PAR15 := IIf( Empty(MV_PAR15),1,MV_PAR15 )
	  	MV_PAR16 := IIf( Empty(MV_PAR16),2,MV_PAR16 )
	Else
		cCondicao := 'C7_FILIAL=="'       + xFilial("SC7") + '".And.'
		cCondicao += 'C7_NUM>="'          + MV_PAR01       + '".And.C7_NUM<="'          + MV_PAR02 + '".And.'
		cCondicao += 'Dtos(C7_EMISSAO)>="'+ Dtos(MV_PAR03) +'".And.Dtos(C7_EMISSAO)<="' + Dtos(MV_PAR04) + '"'
	EndIf 

	nModGrid := MV_PAR15     
	nDescCC  := MV_PAR16     
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Inicio do desenho do Pedido                                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	cTamGrid := "-4"
	nSalto0  := 08
    nSalto1  := 12
    nSalto2  := 20
    nTamLin	 := 20

	aForm		:= {015,010,825,585}	

    
    // Aplica a margem Configurada
    aForm[01] += oSetup:AOPTIONS[07][02] // oPrint:NMARGTOP
    aForm[02] += oSetup:AOPTIONS[07][01] // oPrint:NMARGLEFT
	aForm[03] -= oSetup:AOPTIONS[07][04] // oPrint:NMARGBOT	    
    aForm[04] -= oSetup:AOPTIONS[07][03] // oPrint:NMARGRIGHT
       
    nLine 		:= aForm[01]
    nCol  		:= aForm[02]
    nColA 		:= 270
    nColB 		:= aForm[04] * 0.45 //370
    nCOlC 		:= 410
	nColD 		:= 455
	nColE 		:= 500
	nColF 		:= aForm[04]

	nSpacT		:= 4
	nSpacT2		:= 2
	nLinT 		:= 6
	nLinT1 		:= 2
	nLinT2 		:= 8
	nLinT3 		:= 10
	nLinT4 		:= 16
	nLinC 		:= 16
	nLinW 		:= 20
	nLinAlign 	:= 6
    nSubl 		:= 0.5
	nPadL 		:= 17
	nMaxLin     := aForm[03] 
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Define o logo a ser usado na impressão                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nLogo == 1
		cGrpCompany	:= AllTrim(FWGrpCompany())
		cCodEmpGrp	:= AllTrim(FWCodEmp())
		cUnitGrp	:= AllTrim(FWUnitBusiness())
		cFilGrp		:= AllTrim(FWFilial())
	
		If !Empty(cUnitGrp)
			cDescLogo	:= cGrpCompany + cCodEmpGrp + cUnitGrp + cFilGrp
		Else
			cDescLogo	:= cEmpAnt + cFilAnt
		EndIf
		cLogoD 		:= GetSrvProfString("Startpath","") + "DANFE" + cDescLogo + ".BMP"
	Else
		cLogoD 		:= GetSrvProfString("Startpath","") + "pedcom" + cEmpAnt + ".BMP"	
	EndIf	

	cLogoRel	:= IIf( File(cLogoD) ,cLogoD , "lgrl01.bmp")	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
      
	aPedidos := GetPedidos( lAuto )                                                           
    
    nPedidos := Len(aPedidos)
    
    For nPed := 1 To nPedidos

		cFilOrig := cFilAnt
		cFilAnt  := aPedidos[nPed][01]
			
		cObs01    := ""
		cObs02    := ""
		cObs03    := ""
		cObs04    := ""
		cObs05    := ""
		cObs06    := ""
		cObs07    := ""
		cObs08    := ""
		cObs09    := ""
		cObs10    := ""
		cObs11    := ""
		cObs12    := ""
		cObs13    := ""
		cObs14    := ""
		cObs15    := ""
		cObs16    := ""
		cObs17    := ""
		cObs18    := ""
				    	 
    	nDescProd := 0
    	
    	DbSelectArea("SC7")
    	DbSetOrder(1)
    	DbSeek( aPedidos[nPed][01] + aPedidos[nPed][02] )
	                             
		DbSelectArea("SA2")
		DbSetOrder(1)
		DbSeek(xFilial("SA2")+SC7->C7_FORNECE + SC7->C7_LOJA)
         

		//MemoLine ( < cText>, [ nLineLength], [ nLineNumber] ) --> cText
		cComprador := UsrFullName(SC7->C7_USER)

		GetAlt( @cAlter, @cAprov )    
		
		nQuebra1 := 105
		nQuebra2 := 115

		If nModObs == 1		
			AADD( aObs01, "Comprador Responsavel : "+Substr(cComprador,1,60) ) 	//"Comprador Responsavel :" //"BLQ:Bloqueado"
			AADD( aObs01, "Compradores Alternativos : "+If( Len(cAlter) > 0 , Substr(cAlter,001,nQuebra1) , " " ) )
			AADD( aObs01, "                           "+If( Len(cAlter) > 0 , Substr(cAlter,(nQuebra1*1)+1,nQuebra1) , " " ))
			AADD( aObs01, "                           "+If( Len(cAlter) > 0 , Substr(cAlter,(nQuebra1*2)+1,nQuebra1) , " " ))
	
			AADD( aObs01, "Aprovador(es) : "+If( Len(cAprov) > 0 , Substr(cAprov,001,nQuebra2) , " " ))
			AADD( aObs01, "                "+If( Len(cAprov) > 0 , Substr(cAprov,(nQuebra2*1)+1,nQuebra2) , " " ))
			AADD( aObs01, "                "+If( Len(cAprov) > 0 , Substr(cAprov,(nQuebra2*2)+1,nQuebra2) , " " ))
			AADD( aObs01, "                "+If( Len(cAprov) > 0 , Substr(cAprov,(nQuebra2*3)+1,nQuebra2) , " " ))
			AADD( aObs01, "                "+If( Len(cAprov) > 0 , Substr(cAprov,(nQuebra2*4)+1,nQuebra2) , " " ))
			AADD( aObs01, "                "+If( Len(cAprov) > 0 , Substr(cAprov,(nQuebra2*5)+1,nQuebra2) , " " ))
	
	
			AADD( aObs02, "BLQ:Bloqueado")
			AADD( aObs02, "Ok:Liberado")
			AADD( aObs02, "??:Aguar.Lib")
			AADD( aObs02, "##:Nivel Lib")
		Else
			AADD( aObs01A, "Comprador Responsavel : "+Substr(cComprador,1,60) ) 	//"Comprador Responsavel :" //"BLQ:Bloqueado"			                          
//			AADD( aObs01A, "" )

			AADD( aObs01A, "" )
//			AADD( aObs01A, "Detalhes :          1         2         3         4         5         6         7         8         9         0         1         2" )
//			AADD( aObs01A, "         : 123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890" )

			
//			AADD( aObs01B, "ATENÇÃO FORNECEDOR:")  
//			AADD( aObs01B, "" )
			AADD( aObs01B, "1) Mencionar na Nota Fiscal o NÚMERO DESTE PEDIDO DE COMPRA e TIPO DE COBRANÇA. Depósito bancário somente em nome do EMITENTE ")
			AADD( aObs01B, "   da Nota Fiscal, informando o nome do banco, agência e número da conta corrente. ")
			AADD( aObs01B, "   Dúvidas sobre pagamento, somente pelo e-mail: "+cMailFin )
			AADD( aObs01B, "2) Os documentos de cobrança deverão ser entregues até 10 dias úteis, antes do vencimento, no endereço de cobrança indicado no ")
			AADD( aObs01B, "   Pedido. ")
			AADD( aObs01B, "3) Este pedido de compra será cancelado, automaticamente, sem prévio aviso, caso o prazo de entrega ultrapassar 30 dias do ")
			AADD( aObs01B, "   recebimento do pedido pelo fornecedor, a não ser que exista justificativa, por escrito, acordada entre as partes.") 
			AADD( aObs01B, "4) O não cumprimento de quaisquer condições mencionadas em nosso Pedido, acarretará em DEVOLUÇÃO DA MERCADORIA, NÃO ACEITE DA ") 		 
			AADD( aObs01B, "   MERCADORIA ou PRORROGAÇÃO DO VENCIMENTO DA N.F. ")
			AADD( aObs01B, "5) É vedado a CONTRATADA negociar ou transferir, sob qualquer forma, os créditos decorrentes deste fornecimento, os títulos que venham ")
			AADD( aObs01B, "   a ser emitidos em decorrência do mesmo, sob pena de responder por multa sobre valor dos títulos negociados e rescisão imediata ")
			AADD( aObs01B, "   do pedido de compra.")
			
			If lNewObs
				AADD( aObs01B, "6) Os produtos listados neste PC são comercializados observando o art 689, inciso XXII, do regulamento aduaneiro, não caracterizando")
				AADD( aObs01B, "   operações por conta e ordem e/ou por encomenda.")
			EndIf	
		EndIf		
		If SC7->C7_TIPO == 1 .OR. SC7->C7_TIPO == 3
			AADD( aObs03, "NOTA: So aceitaremos a mercadoria se na sua Nota Fiscal constar o numero do nosso Pedido de Compras.")
		Else
			AADD( aObs03, "NOTA: So aceitaremos a mercadoria se na sua Nota Fiscal constar o numero da Autorizacao de Entrega.")
		EndIf
	         
		MV_PAR12 := MAX(SC7->C7_MOEDA,1) 
		
		//-- Alterado por Bia Ferreira - Ethosx 14/01/2020
		
		cMoeda	   := "MV_MOEDA"+cvaltoChar(MV_PAR12) 
		cDescMoeda := cValToChar(SC7->C7_MOEDA) + " - " + GetMV(cMoeda)
		
		//--- Fim da Alteração -- //
		
		nTxMoeda   := IIF(SC7->C7_TXMOEDA > 0,SC7->C7_TXMOEDA,Nil)

		R110FIniPC(SC7->C7_NUM,,,cFiltro)
		
		nTotIpi	  := MaFisRet(,'NF_VALIPI')
		nTotIcms  := MaFisRet(,'NF_VALICM')
		nTotDesp  := MaFisRet(,'NF_DESPESA')
		nTotFrete := MaFisRet(,'NF_FRETE')
		nTotSeguro:= MaFisRet(,'NF_SEGURO')
		nTotalNF  := MaFisRet(,'NF_TOTAL')
		nTotMerc  := MaFisRet(,"NF_TOTAL") 	   
		nTotal	  := nTotalNF	  
		
		//Alterado por Rodrigo Nunes para verificar valor de Frete e IPI
		If nTotFrete == 0 .AND. SC7->C7_FRETE <> 0
			nTotFrete := SC7->C7_FRETE
		EndIf

		If nTotIpi == 0 
			nTotIpi := BuscaIPI()
		EndIf


		If cPaisLoc<>"BRA"
			aValIVA := MaFisRet(,"NF_VALIMP")
			nValIVA :=0
			If !Empty(aValIVA)
				For nY:=1 to Len(aValIVA)
					nValIVA+=aValIVA[nY]
				Next nY
			EndIf
			cTotcImp := Transform(xMoeda(nValIVA,SC7->C7_MOEDA,MV_PAR12,SC7->C7_DATPRF,MsDecimais(SC7->C7_MOEDA),nTxMoeda) , tm(nValIVA,14,MsDecimais(MV_PAR12)) )
		Else
			cTotcImp := Transform(xMoeda(nTotMerc,SC7->C7_MOEDA,MV_PAR12,SC7->C7_DATPRF,MsDecimais(SC7->C7_MOEDA),nTxMoeda) , tm(nTotMerc,14,MsDecimais(MV_PAR12)) )
		Endif
		
		cTotMerc 	:= Transform(xMoeda(nTotal,SC7->C7_MOEDA,MV_PAR12,SC7->C7_DATPRF,MsDecimais(SC7->C7_MOEDA),nTxMoeda) , tm(nTotal,14,MsDecimais(MV_PAR12)) ) 		//"Total das Mercadorias : "
		cTotIpi 	:= Transform(xMoeda(nTotIPI ,SC7->C7_MOEDA,MV_PAR12,SC7->C7_DATPRF,MsDecimais(SC7->C7_MOEDA),nTxMoeda) , tm(nTotIpi ,14,MsDecimais(MV_PAR12)))  	//"IPI   :"
		cTotIcms	:= Transform(xMoeda(nTotIcms,SC7->C7_MOEDA,MV_PAR12,SC7->C7_DATPRF,MsDecimais(SC7->C7_MOEDA),nTxMoeda) , tm(nTotIcms,14,MsDecimais(MV_PAR12))) 		//"ICMS   :"
		cTotSeguro	:= Transform(xMoeda(nTotSeguro,SC7->C7_MOEDA,MV_PAR12,SC7->C7_DATPRF,MsDecimais(SC7->C7_MOEDA),nTxMoeda) , tm(nTotSeguro,14,MsDecimais(MV_PAR12))) 	// "SEGURO   :"
		cTotFrete	:= Transform(xMoeda(nTotFrete,SC7->C7_MOEDA,MV_PAR12,SC7->C7_DATPRF,MsDecimais(SC7->C7_MOEDA),nTxMoeda) , tm(nTotFrete,14,MsDecimais(MV_PAR12)))	//"Frete    :"
		cTotDesp	:= Transform(xMoeda(nTotDesp ,SC7->C7_MOEDA,MV_PAR12,SC7->C7_DATPRF,MsDecimais(SC7->C7_MOEDA),nTxMoeda) , tm(nTotDesp ,14,MsDecimais(MV_PAR12))) 	//"Despesas :"
		nTotal 	:= nTotal   + nTotIPI
		nTotalNf:= nTotalNf + nTotIPI + nTotFrete
		cTotCImp	:= Transform(xMoeda(nTotal,SC7->C7_MOEDA,MV_PAR12,SC7->C7_DATPRF,MsDecimais(SC7->C7_MOEDA),nTxMoeda) , tm(nTotal,14,MsDecimais(MV_PAR12)) ) 		//"Total das Mercadorias : "
		cTotNF	    := Transform(xMoeda(nTotalNF,SC7->C7_MOEDA,MV_PAR12,SC7->C7_DATPRF,MsDecimais(SC7->C7_MOEDA),nTxMoeda) , tm(nTotalNF,14,MsDecimais(MV_PAR12))) 		//"Total Geral :"

		cDesc0 := "D E S C O N T O S -->"
		cDesc1 := TransForm(SC7->C7_DESC1,"999.99" ) + " %    "
		cDesc2 := TransForm(SC7->C7_DESC2,"999.99" ) + " %    "
		cDesc3 := TransForm(SC7->C7_DESC3,"999.99" ) + " %    "
                             
		cCondPag := SC7->C7_COND + " - "+Posicione("SE4",1,xFilial("SE4")+SC7->C7_COND,"E4_COND")                      
		
		If Empty(MV_PAR13) //"Local de Entrega  : "
			cEndEnt := Alltrim(SM0->M0_ENDENT)+" - "+AllTrim(SM0->M0_CIDENT)+"/"+SM0->M0_ESTENT+" - CEP "+Trans(Alltrim(SM0->M0_CEPENT),PesqPict("SA2","A2_CEP"))
		Else
			cEndEnt := MV_PAR13
		Endif
		SM0->(dbGoto(nRecnoSM0))
		cEndCob := Alltrim(SM0->M0_ENDCOB)+" - "+AllTrim(SM0->M0_CIDCOB)+"/"+SM0->M0_ESTCOB+" - CEP "+Trans(Alltrim(SM0->M0_CEPCOB),PesqPict("SA2","A2_CEP"))

		GetResPed(aPedidos[nPed],@nNumPag,@nDescProd)
		
		cVDesc := TransForm(xMoeda(nDescProd,SC7->C7_MOEDA,MV_PAR12,SC7->C7_DATPRF,MsDecimais(SC7->C7_MOEDA),nTxMoeda) , PesqPict("SC7","C7_VLDESC",14, MV_PAR12) )

		For nPagina := 1 To nNumPag                
	
			cNumPed := aPedidos[nPed][02]
			
			oPrint:StartPage()   // Inicia uma nova página
		
			// oPrint:SayBitmap(nLine+52, nCol + nColD + 18, "iso9001.png",65,20)
	
			// Contorno da pagina
	//		oPrint:Box( aForm[01], aForm[02], aForm[03], aForm[04], cTamGrid )
	//		oPrint:Box( nLine, nCol, nLine + nSalto2 , aForm[04] , cTamGrid )
	
			oPrint:SayBitmap(nLine-12, nCol+2, cLogoRel,aLogo[nLogo][01],aLogo[nLogo][02])
//			oPrint:Say( nLine + 10 ,nCol + 150	 	   , "P E D I D O   D E   C O M P R A"  , oFont14X:oFont)		
			
			oPrint:Say( nLine + 10 ,nCol + 210	 	   , "PEDIDO DE COMPRA"  , oFont14X:oFont)		
			oPrint:Say( nLine + 10 ,nCol + 495	 	   , "Nº " + cNumPed  , oFont14W:oFont)		
	
	        If nLogo == 1
				nLine += ( nSalto2 * 5 )
			Else
				nLine += (nSalto2 * 1 )
	        EndIf

/*
			oPrint:Box( nLine, nCol, nLine + (nSalto2 * 1 ), aForm[04], cTamGrid )
			oPrint:Box( nLine+1, nCol+1, nLine + (nSalto2 * 1 )-1, aForm[04]-1, cTamGrid )
			oPrint:Say( nLine + 10 ,nCol + nSpacT 	   , "Moeda: "  , oFont14V:oFont)					
			oPrint:Say( nLine + 10 ,nCol + 490	 	   , "Data: "+Dtoc(SC7->C7_EMISSAO)  , oFont14V:oFont)					
			nLine += (nSalto2 * 1 )+1
*/

			// Cabecalho
	oPrint:Box( nLine, nCol, nLine + (nSalto2 * 4 ), nColB, cTamGrid )
	If l2Line
		oPrint:Box( nLine+1, nCol+1, nLine + (nSalto2 * 4 )-1, nColB-1, cTamGrid )
	EndIf
    		
	oPrint:Box( nLine, nColB + 2, nLine + (nSalto2 * 4 ), aForm[04], cTamGrid )
	If l2Line
		oPrint:Box( nLine+1, nColB + 2 + 1, nLine + (nSalto2 * 4 ) - 1 , aForm[04] - 1, cTamGrid )
	EndIf
	
	nLine += nSalto0
	oPrint:Say(nLine + nLinT ,nCol  + nSpacT	   , "Empresa : "+SM0->M0_NOMECOM  , oFont09N:oFont)
			
	cNomFor := AllTrim(SA2->A2_NOME)

	If Len(cNomFor) > 45
		oPrint:Say(nLine + nLinT ,nColB + nSpacT 	   , "Nome    : "+Substr(cNomFor,1,50) , oFont08N:oFont)
	Else
		oPrint:Say(nLine + nLinT ,nColB + nSpacT 	   , "Nome    : "+Substr(cNomFor,1,45) , oFont09N:oFont)
	EndIf
			
	oPrint:Say(nLine + nLinT ,nColE+5 + nSpacT 	   , "Cod: "+SA2->A2_COD+"-"+SA2->A2_LOJA		, oFont09N:oFont)
	
	                                
	
	nLine += nSalto1
	oPrint:Say(nLine + nLinT ,nCol + nSpacT	 	   , "Endereço: " + SubStr(SM0->M0_ENDENT,1,35)		  , oFont09N:oFont)
	oPrint:Say(nLine + nLinT ,nColB+ nSpacT	 	   , "Endereço: "+Substr(SA2->A2_END,1,49)  , oFont09N:oFont)
	        
	
	nLine += nSalto1
	cTextLoc := Trans(SM0->M0_CEPENT,PesqPict("SA2","A2_CEP"))+" Cidade: " + AllTrim(SM0->M0_CIDENT) + "/" +SM0->M0_ESTENT
	oPrint:Say(nLine + nLinT ,nCol + nSpacT	 	   , "Cep     : "+cTextLoc	 		 , oFont09N:oFont)

	cTextEnd := Trans(SA2->A2_CEP,PesqPict("SA2","A2_CEP"))+"  Bairro: "+ Substr(SA2->A2_BAIRRO,1,25)
	oPrint:Say(nLine + nLinT ,nColB + nSpacT	   , "Cep     : "+cTextEnd	 		 , oFont09N:oFont)
	                                                    
	
	nLine += nSalto1
	cTextTel:= SM0->M0_TEL + Space(2) + " Fax : " + SM0->M0_FAX
	oPrint:Say(nLine + nLinT ,nCol + nSpacT	 	   , "Telefone: "+cTextTel	  , oFont09N:oFont)
	                                                
	cTextMun := AllTrim(SA2->A2_MUN)+"/"+SA2->A2_EST
	oPrint:Say(nLine + nLinT ,nColB + nSpacT	   , "Cidade  : "+cTextMun	 		 , oFont09N:oFont)
	oPrint:Say(nLine + nLinT ,nColE-45 + nSpacT	   , "CNPJ: "+Transform(SA2->A2_CGC,PesqPict("SA2","A2_CGC"))	 		 , oFont09N:oFont)
	
 	
	
	nLine += nSalto1
	cTextCNPJ := Transform(SM0->M0_CGC,PesqPict("SA2","A2_CGC")) + "  IE: "+InscrEst()
	oPrint:Say(nLine + nLinT ,nCol + nSpacT	 	   , "CNPJ    : "+	cTextCNPJ  , oFont09N:oFont)

	cTextFone := "("+Substr(SA2->A2_DDD,1,3)+") "+Substr(SA2->A2_TEL,1,15) + " Fax : ("+Substr(SA2->A2_DDD,1,3)+") "+SubStr(SA2->A2_FAX,1,15)
	oPrint:Say(nLine + nLinT ,nColB + nSpacT	 	   , "Fone    : "+	cTextFone  , oFont09N:oFont)
	                                                                           
	
	nLine += nSalto1
	oPrint:Say(nLine + nLinT ,nCol + nSpacT	 	   , "Insc Mun: "+	AllTrim(SM0->M0_INSCM)   , oFont09N:oFont)
	oPrint:Say(nLine + nLinT ,nColB + nSpacT	   , "IE: "		 +	AllTrim(SA2->A2_INSCR)   , oFont09N:oFont)
	                             
	
	nLine += nSalto1  + 2
				
	oPrint:Box( nLine, nCol, nLine + (nSalto2 * 1 ), aForm[04], cTamGrid )
	If l2Line
		oPrint:Box( nLine+1, nCol+1, nLine + (nSalto2 * 1 )-1, aForm[04]-1, cTamGrid )
	EndIf
	oPrint:Say( nLine + 12 ,nCol + nSpacT 	   , "Moeda: "+cDescMoeda  , oFont14V:oFont)
	oPrint:Say( nLine + 12 ,nCol + 288	 	   , "Data: "+Dtoc(SC7->C7_EMISSAO)  , oFont14V:oFont)
	oPrint:Say( nLine + 12 ,nCol + 494	 	   , "Pag: "+StrZero(nPagina,3)+"/"+StrZero(nNumPag,3)   , oFont14V:oFont)
	nLine += (nSalto2 * 1 )+2

	
	
//			nLine += nSalto1  + 2
			
	PrtItens( oPrint, nLogo )
//			oPrint:Box( nLine, nCol, nLine + nSalto2 , aForm[04] , cTamGrid )
                        



	nLine := 560


	nAltbox  := nSalto2
	oPrint:Box( nLine, nCol, nLine + nAltbox , aForm[04], cTamGrid )
	If l2Line
		oPrint:Box( nLine + 1, nCol + 1, nLine + nAltbox - 1, aForm[04] - 1, cTamGrid )
	EndIf
	oPrint:Say( nLine + nLinT2 ,nCol + nSpacT	 	   	, "Descontos: " , oFont09N:oFont)
	oPrint:Say( nLine + nLinT4 ,nCol + ( nSpacT	* 001 )	, "Desconto 1: " +cDesc1, oFont09:oFont)
	oPrint:Say( nLine + nLinT4 ,nCol + ( nSpacT	* 035 )	, "Desconto 2: " +cDesc2 , oFont09:oFont)
	oPrint:Say( nLine + nLinT4 ,nCol + ( nSpacT	* 070 )	, "Desconto 3: " +cDesc3 , oFont09:oFont)
	oPrint:Say( nLine + nLinT4 ,nCol + ( nSpacT	* 105 )	, "Vlr Desconto: " +cVDesc , oFont09:oFont)

	nLine += nAltbox  + 2


			// Entrega/Cobranca                               
	nColDiv := 300
	nAltbox  := nSalto2
	oPrint:Box( nLine, nCol, nLine + nAltbox , nColDiv - 1, cTamGrid )
	If l2Line
		oPrint:Box( nLine + 1, nCol + 1, nLine + nAltbox - 1, nColDiv - 1 - 1, cTamGrid )
	EndIf
	oPrint:Say( nLine + nLinT2 ,nCol + nSpacT	 	   	, "Local de Entrega: " , oFont09N:oFont)
	oPrint:Say( nLine + nLinT4 ,nCol + nSpacT	 	   	, cEndEnt , oFont09:oFont)

	oPrint:Box( nLine, nColDiv + 1, nLine + nAltbox , aForm[04] , cTamGrid )
	If l2Line
		oPrint:Box( nLine + 1, nColDiv + 1 + 1, nLine + nAltbox - 1, aForm[04] - 1, cTamGrid )
	EndIf
	oPrint:Say( nLine + nLinT2 ,nColDiv + nSpacT		, "Local de Cobrança: " , oFont09N:oFont)
	oPrint:Say( nLine + nLinT4 ,nColDiv + nSpacT	   	, cEndCob , oFont09:oFont)

	nLine += nAltbox  + 2


			// Valores                               
	aColsDiv := {170,300,420}
	nAltbox  := (nSalto2 * 2)
	oPrint:Box( nLine, nCol, nLine + nAltbox , aColsDiv[01]- 1, cTamGrid )
	If l2Line
		oPrint:Box( nLine + 1, nCol + 1, nLine + nAltbox - 1, aColsDiv[01]- 1 - 1, cTamGrid )
	EndIf
	oPrint:Say( nLine + nLinT2 ,nCol + nSpacT	 	   	, "Condição de Pagamento:"  , oFont09N:oFont)
	oPrint:Say( nLine + nLinT4 ,nCol + nSpacT	 	   	, cCondPag , oFont09:oFont)

	oPrint:Box( nLine, aColsDiv[01] + 1, nLine + nAltbox , aColsDiv[02]- 1 , cTamGrid )
	If l2Line
		oPrint:Box( nLine + 1, aColsDiv[01] + 1 + 1, nLine + nAltbox - 1, aColsDiv[02]- 1 -1, cTamGrid )
	EndIf
	oPrint:Say( nLine + nLinT2 ,aColsDiv[01] + nSpacT	, "Impostos: " , oFont09N:oFont)
	oPrint:Say( nLine + nLinT4 ,aColsDiv[01] + nSpacT	 	   	, "ICMS: " + cTotIcms , oFont09:oFont)
	oPrint:Say( nLine + (nLinT4 + nLinT2) ,aColsDiv[01] + nSpacT, "IPI : " + cTotIPI , oFont09:oFont)


	oPrint:Box( nLine, aColsDiv[02] + 1, nLine + nAltbox , aColsDiv[03] , cTamGrid )
	If l2Line
		oPrint:Box( nLine + 1, aColsDiv[02] + 1 + 1, nLine + nAltbox - 1, aColsDiv[03] - 1, cTamGrid )
	EndIf
	oPrint:Say( nLine + nLinT2 ,aColsDiv[02] + nSpacT		, "Outros: " , oFont09N:oFont)
	oPrint:Say( nLine + nLinT4 ,aColsDiv[02] + nSpacT	 	   	, "Despesas:" + cTotDesp, oFont09:oFont)
	oPrint:Say( nLine + (nLinT4 + nLinT2) ,aColsDiv[02] + nSpacT, "Seguro  :" + cTotSeguro	, oFont09:oFont)
	oPrint:Say( nLine + (nLinT4 + nLinT4) ,aColsDiv[02] + nSpacT, "Frete   :" + cTotFrete, oFont09:oFont)
                                                                        


	oPrint:Box( nLine, aColsDiv[03] + 1, nLine + nAltbox , aForm[04] , cTamGrid )
	If l2Line
		oPrint:Box( nLine + 1, aColsDiv[03] + 1 + 1, nLine + nAltbox - 1, aForm[04] - 1, cTamGrid )
	EndIf
	oPrint:Say( nLine + nLinT2 ,aColsDiv[03] + nSpacT			, "Totais: " , oFont09N:oFont)
	oPrint:Say( nLine + nLinT4 ,aColsDiv[03] + nSpacT	 	   	, "Total das Mercadorias:" + cTotMerc, oFont09:oFont)
	oPrint:Say( nLine + (nLinT4 + nLinT2) ,aColsDiv[03] + nSpacT, "Total com impostos   :" + cTotCImp, oFont09:oFont)
	oPrint:Say( nLine + (nLinT4 + nLinT4) ,aColsDiv[03] + nSpacT, "Total Geral          :" + cTotNF, oFont09:oFont)

	If nModObs == 1
	
	            // Observações
		nLine += nAltbox  + 2
		aColsDiv := {500}
		nAltbox := nSalto2 * 3
		oPrint:Box( nLine, nCol, nLine + nAltbox, aColsDiv[01] - 1 , cTamGrid )
		If l2Line
			oPrint:Box( nLine+1, nCol+1, nLine + nAltbox-1, aColsDiv[01] - 1 - 1, cTamGrid )
		EndIf
		oPrint:Say( nLine + nLinT2 ,nCol + nSpacT	 	   , "Observações: " , oFont09N:oFont)
		nPosObs := 0
		nLinObs := 1
		For nObs := 1 To nMaxObs // Len()
					
			cPrtObs := &("cObs"+StrZero(nObs,2))
			If !Empty(cPrtObs)
				oPrint:Say( nLine + (nLinT2 + (nLinT2*nLinObs)) ,nCol + nSpacT+nPosObs	   	, cPrtObs , oFont09:oFont)
	
				If nObs == 6 .Or. nObs == 12
					nPosObs += 155
					nLinObs := 1
				Else
					nLinObs++
				EndIf
			EndIf
		Next
		nLinObs := 0
				 
		oPrint:Box( nLine, aColsDiv[01] + 1, nLine + nAltbox , aForm[04] , cTamGrid )
		If l2Line
			oPrint:Box( nLine + 1, aColsDiv[01] + 1 + 1, nLine + nAltbox -1 , aForm[04] - 1, cTamGrid )
		EndIf
	
		oPrint:Say( nLine + nLinT2 ,aColsDiv[01] + nSpacT	, "Legendas: " , oFont09N:oFont)
				
		For nLeg := 1 To Len(aObs02)
			If !Empty(aObs02[nLeg])
				oPrint:Say( nLine + (nLinT2 + (nLinT2*nLeg)) ,aColsDiv[01] + nSpacT	 	   	, aObs02[nLeg] , oFont09:oFont)
			EndIf
		Next
	
	    		
				// Informações do Pedido
		nLine += nAltbox  + 2
		aColsDiv := {480}
	            
		nAltbox := nSalto2 * 5
				
		oPrint:Box( nLine, nCol, nLine + nAltbox , aForm[04], cTamGrid )
		If l2Line
			oPrint:Box( nLine + 1, nCol + 1, nLine + nAltbox - 1, aForm[04] - 1, cTamGrid )
		EndIf
	
		oPrint:Say( nLine + nLinT2 ,nCol + nSpacT	 	   	, "Informações: " , oFont09N:oFont)
	
		For nLeg := 1 To Len(aObs01)
			If !Empty(aObs01[nLeg])
				oPrint:Say( nLine + (nLinT2 + (nLinT2*nLeg)) ,nCol + nSpacT	 	   	, aObs01[nLeg] , oFont09:oFont)
			EndIf
		Next
	    	
	Else
	    	
	
	            // Observações
		nLine += nAltbox  + 2
		aColsDiv := {aForm[04]}
		nAltbox := nSalto2 * 8
		oPrint:Box( nLine, nCol, nLine + nAltbox, aColsDiv[01] - 1 , cTamGrid )
		If l2Line
			oPrint:Box( nLine+1, nCol+1, nLine + nAltbox-1, aColsDiv[01] - 1 - 1, cTamGrid )
		EndIf


		oPrint:Say( nLine + nLinT2 ,nCol + nSpacT	 	   , "Observações: " , oFont09N:oFont)
		nPosObs := 0
		nLinObs := 1
				
		For nObs := 1 To Len(aObs01A)
			If !Empty(aObs01A[nObs])
				oPrint:Say( nLine + (nLinT2 + (nLinT2*nObs)) ,nCol + nSpacT	 	   	, aObs01A[nObs] , oFont09:oFont)
			EndIf
		Next

		nLine += (nLinT2 + (nLinT2*nObs))
				
		oPrint:Say( nLine + nLinT2 ,nCol + nSpacT	 	   , "Atenção Fornecedor: " , oFont09N:oFont)
		nPosObs := 0
                                            

		For nLeg := 1 To Len(aObs01B)
			If !Empty(aObs01B[nLeg])
				oPrint:Say( nLine + (nLinT2 + (nLinT2*nLeg)) ,nCol + nSpacT	 	   	, aObs01B[nLeg] , oFont09:oFont)
			EndIf
		Next
				

				/*
				For nObs := 1 To nMaxObs // Len()
					
					cPrtObs := &("cObs"+StrZero(nObs,2)) 
					If !Empty(cPrtObs)
						oPrint:Say( nLine + (nLinT2 + (nLinT2*nLinObs)) ,nCol + nSpacT+nPosObs	   	, cPrtObs , oFont09:oFont)			

		                If nObs == 6 .Or. nObs == 12
			                nPosObs += 155
			                nLinObs := 1
						Else
							nLinObs++
		                EndIf         

						nLinObs++
									                
		                
	    			EndIf
	    		Next
*/
		nLinObs := 0

		nLine := 650
	EndIf
	
	nLine += nAltbox  + 2
	aColsDiv := {480}
            
	nAltbox := nSalto2 * 1

	oPrint:Box( nLine, nCol, nLine + nAltbox , aForm[04] , cTamGrid )
	If l2Line
		oPrint:Box( nLine +1, nCol +1, nLine + nAltbox - 1, aForm[04] - 1, cTamGrid )
	EndIf

	oPrint:Say( nLine + nLinT2 ,nCol + nSpacT	 	   	, aObs03[01] , oFont09N:oFont)

	oPrint:Say( nLine + nLinT2 + 20 ,nCol + nSpacT	 	   	, "Fonte: XMATR110.PRW"  , oFont08V:oFont)


		
	oPrint:EndPage() // Finaliza

	nLine 		:= aForm[01]
	ClearObs()
Next nPagina
    
cFilAnt := 	cFilOrig
Next nPed

If nPedidos > 0
	oPrint:Preview()
Else
	Aviso("XMATR110","Nenhum pedido a ser impresso nos parametros selecionados!",{"Ok"},2)
EndIf
Return()
   


Static Function GetPedidos( lAuto )
	Local aRet 		:= {}
	Local cAliasP   := GetNextAlias()
	Local cWhere 	:= ""

	If lAuto
//		aRet := {{"03","006788"}}//{{"03","008089"}}//,{"01","026949"}	
		aRet := { {SC7->C7_FILIAL,SC7->C7_NUM }}
	Else
	
		cWhere	+= 	"%"

		cWhere += " D_E_L_E_T_ = ' ' "
				
		If MV_PAR05 == 1
			cWhere += "AND C7_EMITIDO <> 'S' "
		EndIf
		
		If MV_PAR08 == 1
			cWhere += "AND C7_TIPO = 1 "
		ElSe
			cWhere += "AND C7_TIPO = 3 "
		EndIf

		If MV_PAR14 == 2
			cWhere += "AND ( (C7_QUANT-C7_QUJE) <= 0 OR C7_RESIDUO = '' ) "
		Elseif MV_PAR14 == 3
			cWhere += "AND C7_QUANT > C7_QUJE "
		EndIf
		
		cWhere	+= 	"%"
				
		BeginSql ALIAS cAliasP
			SELECT DISTINCT C7_FILIAL, C7_NUM FROM %table:SC7%
			WHERE C7_FILIAL = %Exp:xFilial("SC7")%
			AND C7_NUM >= %Exp:MV_PAR01% AND C7_NUM <= %Exp:MV_PAR02%
			AND C7_EMISSAO >= %Exp:dTos(MV_PAR03)% AND C7_EMISSAO <= %Exp:dTos(MV_PAR04)%
				
			AND %Exp:cWhere%

		EndSql
		While (cAliasP)->(!Eof())
			AADD( aRet , {(cAliasP)->C7_FILIAL,(cAliasP)->C7_NUM })
			(cAliasP)->(DbSkip())
		EndDo

/*	
		!MtrAValOP(MV_PAR11, "SC7")    
	
	If (SC7->C7_CONAPRO == "B" .And. MV_PAR10 == 1) .Or.;
		(SC7->C7_CONAPRO <> "B" .And. MV_PAR10 == 2) .Or.;
		(SC7->C7_EMITIDO == "S" .And. MV_PAR05 == 1) .Or.;
		((SC7->C7_EMISSAO < MV_PAR03) .Or. (SC7->C7_EMISSAO > MV_PAR04)) .Or.;
		(SC7->C7_QUANT > SC7->C7_QUJE .And. MV_PAR14 == 3) .Or.;
		((SC7->C7_QUANT - SC7->C7_QUJE <= 0 .Or. !Empty(SC7->C7_RESIDUO)) .And. MV_PAR14 == 2 )
*/

/*	
	If lPedido
		MV_PAR12 := MAX(SC7->C7_MOEDA,1)
	Endif
	
	If SC7->C7_TIPO == 1 .OR. SC7->C7_TIPO == 3
		If ( cPaisLoc$"ARG|POR|EUA" )
			cCondBus := "1"+StrZero(Val(MV_PAR01),6)
			nOrder	 := 10
		Else
			cCondBus := MV_PAR01
			nOrder	 := 1
		EndIf
	Else
		cCondBus := "2"+StrZero(Val(MV_PAR01),6)
		nOrder	 := 10
	EndIf
	
*/

/*

	Local aCombo07  := {"Primária","Secundária","Todas"}   
	Local aCombo08  := {"Pedido Compra","Aut. de Entrega"}     
	Local aCombo10  := {"Liberados","Bloqueados","Ambos"}
	Local aCombo11  := {"Firmes", "Previstas", "Ambas"}	
	Local aCombo12  := {"Moeda 1","Moeda 2","Moeda 3","Moeda 4","Moeda 5"}
	Local aCombo14  := {"Todos","Em Aberto","Atendidos"}
	Local aCombo15  := {"Modelo 1","Modelo 2","Modelo 3","Modelo 4"}
*/
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros                         ³
//³ mv_par01               Do Pedido                             ³
//³ mv_par02               Ate o Pedido                          ³
//³ mv_par03               A partir da data de emissao           ³
//³ mv_par04               Ate a data de emissao                 ³
//³ mv_par05               Somente os Novos                      ³
//³ mv_par06               Campo Descricao do Produto    	     ³
//³ mv_par07               Unidade de Medida:Primaria ou Secund. ³
//³ mv_par08               Imprime ? Pedido Compra ou Aut. Entreg³
//³ mv_par09               Numero de vias                        ³
//³ mv_par10               Pedidos ? Liberados Bloqueados Ambos  ³
//³ mv_par11               Impr. SC's Firmes, Previstas ou Ambas ³
//³ mv_par12               Qual a Moeda ?                        ³
//³ mv_par13               Endereco de Entrega                   ³
//³ mv_par14               todas ou em aberto ou atendidos       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ






	EndIf

Return( aRet )
                  


Static Function ClearObs()
	Local Nx := 0
	
	For Nx := 1 To nMaxObs
		cVar:= "cObs"+StrZero(Nx,2)
		&(cVar) := ""
	Next
			
Return


Static Function GetPagPed( aPed )
	Local nRet 		:= 1
	Local cAliasP   := GetNextAlias()
	Local cFilPed   := aPed[01]
	Local cNumPed   := aPed[02]
	Local nTotIt	:= 0
          
	
	BeginSql ALIAS cAliasP
		SELECT COUNT(*) AS TOTAL FROM %TABLE:SC7%
		WHERE C7_FILIAL = %exp:cFilPed%
		AND C7_NUM = %exp:cNumPed%
		AND %notdel%
	EndSql
	nTotIt := (cAliasP)->TOTAL
	nTmp := nTotIt / nMaxItens
	
	If (nTmp - Int(nTmp)) <> 0
		nRet := Int(nTmp) + 1
	Else
		nRet := nTmp
	EndIf

Return( nRet )
                     



Static Function GetResPed( aPed, nNumPag, nDescProd )
	Local lRet 		:= .T.
	Local nRet 		:= 1
	Local cAliasP   := GetNextAlias()
	Local cFilPed   := aPed[01]
	Local cNumPed   := aPed[02]
	Local nTotIt	:= 0
          
	
	BeginSql ALIAS cAliasP
		SELECT * FROM %TABLE:SC7%
		WHERE C7_FILIAL = %exp:cFilPed%
		AND C7_NUM = %exp:cNumPed%
		AND %notdel%
	EndSql

	While (cAliasP)->(!Eof())

		If (cAliasP)->C7_DESC1 <> 0 .Or. (cAliasP)->C7_DESC2 <> 0 .Or. (cAliasP)->C7_DESC3 <> 0
			nDescProd+= CalcDesc((cAliasP)->C7_TOTAL,(cAliasP)->C7_DESC1,(cAliasP)->C7_DESC2,(cAliasP)->C7_DESC3)
		Else
			nDescProd+=(cAliasP)->C7_VLDESC
		Endif
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Inicializacao da Observacao do Pedido.                       ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !Empty((cAliasP)->C7_OBS) .And. nLinObs < (nMaxObs+1)
			nLinObs++
			cVar:="cObs"+StrZero(nLinObs,2)
			Eval(MemVarBlock(cVar),(cAliasP)->C7_ITEM+"-"+(cAliasP)->C7_OBS)
		Endif
			
		nTotIt++
		(cAliasP)->(DbSkip())
	EndDo

	// Paginas
	nTmp := nTotIt / nMaxItens
	
	If (nTmp - Int(nTmp)) <> 0
		nNumPag := Int(nTmp) + 1
	Else
		nNumPag := nTmp
	EndIf

Return( lRet )
               


Static Function PrtItens( oPrint, nLogo )

	Local aCab 		:= {}
	Local aItem		:= {}
	Local Nx   		:= 1
	Local Ny   		:= 1
	Local nItens    := 0
	Local nCab      := 0
	Local nQtIt     := 1
	Local cNumSC7 	:= SC7->C7_NUM
	Local cCodSubs	:= "" // Maurício Aureliano - 26/04/2018 - Chamado: I1804-2666
	Local cObsSc7	:= "" // Maurício Aureliano - 26/04/2018 - Chamado: I1804-2666
	Local aFonts 	:= {}
	Local bC7_DESCRI:= {|| }
	Local bC7_CC    := {|| }


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ O cabecalho de impressao.                                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	AADD( aCab, {"Item"			, 022 , "S"})
	AADD( aCab, {"Produto"		, 035 , "S" })
	AADD( aCab, {"Descrição"	, 162 , "S" })
	AADD( aCab, {"UM"			, 018 , "S" })
	AADD( aCab, {"Qtde"			, 048 , "A" })
	AADD( aCab, {"2UM"			, 020 , "S" })
	AADD( aCab, {"Qtd 2ª UM"	, 045 , "A" })
	AADD( aCab, {"Vlr Unitario"	, 050 , "A" })
	AADD( aCab, {"IPI"			, 020 , "S" })
	AADD( aCab, {"Vlr Total"	, 050 , "A" })
	AADD( aCab, {"Entrega"		, 033 , "S" })
	AADD( aCab, {"CCusto"		, 040 , "S" })
	AADD( aCab, {"Nro SC"		, 030 , "S" })

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Define a descrição do produto.                               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Empty(MV_PAR06)
		MV_PAR06 := "B1_DESC"
	Else
		MV_PAR06 := AllTrim(Upper( MV_PAR06 ))
	EndIf
	
	// Validar existencia do campo - Evitar ErrorLog
	
	If AllTrim(MV_PAR06) == "B1_DESC"
		bC7_DESCRI:= {|| Posicione("SB1",1,xFilial("SB1")+SC7->C7_PRODUTO,"B1_DESC") }
	ElseIf AllTrim(MV_PAR06) == "B5_CEME"
		bC7_DESCRI:= {|| Posicione("SB5",1,xFilial("SB5")+SC7->C7_PRODUTO,"B5_CEME") }
	ElseIf AllTrim(MV_PAR06) == "C7_DESCRI"
		bC7_DESCRI:= {|| SC7->C7_DESCRI }
	ElseIf AllTrim(MV_PAR06) == "C7_OBS"
		bC7_DESCRI:= {|| SC7->C7_OBS }
	Else
		bC7_DESCRI:= {|| Posicione("SB1",1,xFilial("SB1")+SC7->C7_PRODUTO,"B1_DESC") }
	EndIf
	
	If nDescCC == 1
		bC7_CC    := {|| SC7->C7_CC }
	Else
		bC7_CC    := {|| Substr(Posicione("CTT",1,xFilial("CTT")+SC7->C7_CC ,"CTT_DESC01"),1,8)}
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	While SC7->(!Eof()) .And. cNumSC7 == SC7->C7_NUM .And. nQtIt <= nMaxItens
	
		// Maurício Aureliano - 26/04/2018
		// Chamado: I1804-2666 - Descrição do Produto (Ajuste tamanho do código do produto)
		cCodSubs:= Trim(SC7->C7_PRODUTO)
		cObsSc7	:= Trim(SC7->C7_OBS)
		
		If Len(cCodSubs) > 8
			cObsSc7		:= cCodSubs + ' - ' + cObsSc7
			cCodSubs 	:= Substr(SC7->C7_PRODUTO,1,8)
		EndIf	
					
		AADD( aItem, {	SC7->C7_ITEM		,;
			cCodSubs		,;
			eVal(bC7_DESCRI) 	,;
			SC7->C7_UM			,;
			AllTrim(Transform(SC7->C7_QUANT,PesqPict("SC7","C7_QUANT")))	,;
			SC7->C7_SEGUM		,;
			Transform(SC7->C7_QTSEGUM,PesqPict("SC7","C7_QTSEGUM"))	,;
			Transform(SC7->C7_PRECO,"@E 9,999,999.9999") 		,;
			Transform(SC7->C7_IPI,PesqPict("SC7","C7_IPI"))		,;
			AllTrim(Transform(SC7->C7_TOTAL,PesqPict("SC7","C7_TOTAL")))	,;
			Dtoc(SC7->C7_DATPRF),;
			eVal( bC7_CC )		,;
			SC7->C7_NUMSC })

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Inicializacao da Observacao do Pedido.                       ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
			// Maurício Aureliano - 20/04/2018
			// Chamado: I1804-2013 - Observação
			//////////////////////////////////////////////////////////////////
			/*
			If !Empty(SC7->C7_OBS) .And. nLinObs < (nMaxObs+1)
				nLinObs++
				cVar:="cObs"+StrZero(nLinObs,2)                     
				Eval(MemVarBlock(cVar),"")				
				Eval(MemVarBlock(cVar),SC7->C7_ITEM+"-"+SC7->C7_OBS)
			Endif
			*/
		// Maurício Aureliano - 20/04/2018
		// Chamado: I1804-2013 - Campo Observação no Pedido de Compra
		If !Empty(cObsSc7)
			AADD( aItem, {	"Obs:"	,; // AADD( aItem, {	SC7->C7_ITEM	,;
				Trim(Capital(cObsSc7))	,; //"Obs: "	,;
				"" ,;
				""	,;
				""	,;
				""	,;
				""	,;
				"" 	,;
				""	,;
				""	,;
				""	,;
				""	,;
				""	})
				nQtIt++
		Endif
						
		SC7->(DbSkip())
		nQtIt++
	EndDo
		
//	oPrint:Box( nLine, nCol, nLine + nSalto1 , aForm[04] , cTamGrid )

	nItens  := Len(aItem)
	nCab    := Len(aCab)
                                                                        
	AADD( aFonts, 	oFont10n:oFont )
	AADD( aFonts, 	oFont10V:oFont )
	AADD( aFonts, 	oFont07:oFont  )
	AADD( aFonts, 	oFont08:oFont  )
	AADD( aFonts, 	oFont08n:oFont )
	AADD( aFonts, 	oFont08C:oFont )
	AADD( aFonts, 	oFont08V:oFont )
	AADD( aFonts, 	oFont10:oFont  )
	AADD( aFonts, 	oFont11n:oFont )

	nColAtu := nCol

	For Nx := 1 To nCab
		xTamReal :=  aCab[Nx][02]
        
		oPrint:Box( nLine			, nColAtu, nLine + nSalto1 , nColAtu + xTamReal , cTamGrid )
		If l2Line
			oPrint:Box( nLine+1			, nColAtu+1, nLine + nSalto1-1 , nColAtu + xTamReal-1 , cTamGrid )
		EndIf
//		oPrint:FillRect({nLine		, nColAtu ,nLine + nSalto1 , nColAtu + xTamReal},oBrush)
		oPrint:Say( nLine + nLinT2 	, nColAtu + nSpacT2	 	   , aCab[Nx][01]  , aFonts[01] )
		nColAtu += xTamReal
	Next Nx

	nLine 	+= nSalto1
	nColAtu := nCol

	For Ny := 1 To Min(nItens,nMaxItens)

		For Nx := 1 To nCab
			xTamReal :=  aCab[Nx][02]
			
			If nModGrid == 1  // Linhas Pintadas Alternadas
				If Mod(ny,2) == 0

					If aItem[Ny][1] == "Obs:" .And. Nx = 1
						oPrint:FillRect({nLine		, nColAtu ,nLine + nSalto1 , 585},oBrush)					
					EndIf
					
				EndIf
			ElseIf nModGrid == 2 .And. nItens <> Ny // Linhas de divisão
				oPrint:Box( nLine + nSalto1		, nColAtu, nLine + nSalto1 , nColAtu + xTamReal , cTamGrid )
			ElseIf nModGrid == 3  // Grid Normal
				oPrint:Box( nLine			, nColAtu, nLine + nSalto1 , nColAtu + xTamReal , cTamGrid )
			ElseIf nModGrid == 4 // Colunas pintadas alternadas
				If Mod(nx,2) == 0
					oPrint:FillRect({nLine		, nColAtu ,nLine + nSalto1 , nColAtu + xTamReal},oBrush)
				Endif
			EndIf
			
			If aCab[Nx][03] == "S"
				If aItem[Ny][1] <> "Obs:"
					oPrint:Say( nLine + nLinT2 	, nColAtu + nSpacT2	 	   , aItem[Ny][Nx]  , aFonts[03] )
				ElseIf !Empty(AllTrim(aItem[Ny][Nx]))
					oPrint:Say( nLine + nLinT2 	, nColAtu + nSpacT2	 	   , aItem[Ny][Nx]  , aFonts[03] )
				EndIf
			ElseIf aCab[Nx][03] == "A" .And. !Empty(aItem[Ny][Nx])
				oPrint:SayAlign(nLine + nLinT1, nColAtu + nSpacT2	, aItem[Ny][Nx]       , aFonts[03], (xTamReal - 4) ,0,2,1 )
			EndIf
	
			nColAtu += xTamReal
		Next Nx
		
		nLine += nSalto1
		nColAtu := nCol
	Next Ny

	nLine += nSalto1
	nColAtu := nCol

Return


Static Function GetAlt( cAlter, cAprov )
	Local aArea := GetArea()

	If !Empty(SC7->C7_APROV)
		
		cTipoSC7:= IIF((SC7->C7_TIPO == 1 .OR. SC7->C7_TIPO == 3),"PC","AE")
		lNewAlc := .T.
		cComprador := UsrFullName(SC7->C7_USER)

		If SC7->C7_CONAPRO != "B"
			lLiber := .T.
		EndIf

		DbSelectArea("SCR")
		DbSetOrder(1)
		DbSeek(xFilial("SCR")+cTipoSC7+SC7->C7_NUM)
		While !Eof() .And. SCR->CR_FILIAL+Alltrim(SCR->CR_NUM) == xFilial("SCR")+Alltrim(SC7->C7_NUM) .And. SCR->CR_TIPO == cTipoSC7
			cAprov += AllTrim(UsrFullName(SCR->CR_USER))+" ["
			Do Case
			Case SCR->CR_STATUS=="03" //Liberado
				cAprov += "Ok"
			Case SCR->CR_STATUS=="04" //Bloqueado
				cAprov += "BLQ"
			Case SCR->CR_STATUS=="05" //Nivel Liberado
				cAprov += "##"
			OtherWise                 //Aguar.Lib
				cAprov += "??"
			EndCase
			cAprov += "] - "
			DbSelectArea("SCR")
			dbSkip()
		Enddo
		If !Empty(SC7->C7_GRUPCOM)
			DbSelectArea("SAJ")
			DbSetOrder(1)
			DbSeek(xFilial("SAJ")+SC7->C7_GRUPCOM)
			While !Eof() .And. SAJ->AJ_FILIAL+SAJ->AJ_GRCOM == xFilial("SAJ")+SC7->C7_GRUPCOM
				If SAJ->AJ_USER != SC7->C7_USER
					cAlter += AllTrim(UsrFullName(SAJ->AJ_USER))+"/"
				EndIf
				DbSelectArea("SAJ")
				dbSkip()
			EndDo
		EndIf
	EndIf
	
	RestArea( aArea )
Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ ReportDef³Autor  ³Alexandre Inacio Lemes ³Data  ³06/09/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Pedido de Compras / Autorizacao de Entrega                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ nExp01: nReg = Registro posicionado do SC7 apartir Browse  ³±±
±±³          ³ nExp02: nOpcx= 1 - PC / 2 - AE                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ oExpO1: Objeto do relatorio                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ReportDef(nReg,nOpcx)

	Local cTitle   := "Emissao dos Pedidos de Compras ou Autorizacoes de Entrega"
	Local oReport
	Local oSection1
	Local oSection2
	Local nTamCdProd:= TamSX3("C7_PRODUTO")[1]


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros                         ³
//³ mv_par01               Do Pedido                             ³
//³ mv_par02               Ate o Pedido                          ³
//³ mv_par03               A partir da data de emissao           ³
//³ mv_par04               Ate a data de emissao                 ³
//³ mv_par05               Somente os Novos                      ³
//³ mv_par06               Campo Descricao do Produto    	     ³
//³ mv_par07               Unidade de Medida:Primaria ou Secund. ³
//³ mv_par08               Imprime ? Pedido Compra ou Aut. Entreg³
//³ mv_par09               Numero de vias                        ³
//³ mv_par10               Pedidos ? Liberados Bloqueados Ambos  ³
//³ mv_par11               Impr. SC's Firmes, Previstas ou Ambas ³
//³ mv_par12               Qual a Moeda ?                        ³
//³ mv_par13               Endereco de Entrega                   ³
//³ mv_par14               todas ou em aberto ou atendidos       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	AjustaSX1()
	Pergunte("MTR110",.F.)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Criacao do componente de impressao                                      ³
//³                                                                        ³
//³TReport():New                                                           ³
//³ExpC1 : Nome do relatorio                                               ³
//³ExpC2 : Titulo                                                          ³
//³ExpC3 : Pergunte                                                        ³
//³ExpB4 : Bloco de codigo que sera executado na confirmacao da impressao  ³
//³ExpC5 : Descricao                                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oReport:= TReport():New("MATR110",cTitle,"MTR110", {|oReport| ReportPrint(oReport,nReg,nOpcx)},STR0001+" "+STR0002)
	oReport:SetPortrait()
	oReport:HideParamPage()
	oReport:HideHeader()
	oReport:HideFooter()
	oReport:SetTotalInLine(.F.)
	oReport:DisableOrientation()
	oReport:ParamReadOnly(lAuto)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Criacao da secao utilizada pelo relatorio                               ³
//³                                                                        ³
//³TRSection():New                                                         ³
//³ExpO1 : Objeto TReport que a secao pertence                             ³
//³ExpC2 : Descricao da seçao                                              ³
//³ExpA3 : Array com as tabelas utilizadas pela secao. A primeira tabela   ³
//³        sera considerada como principal para a seção.                   ³
//³ExpA4 : Array com as Ordens do relatório                                ³
//³ExpL5 : Carrega campos do SX3 como celulas                              ³
//³        Default : False                                                 ³
//³ExpL6 : Carrega ordens do Sindex                                        ³
//³        Default : False                                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Criacao da celulas da secao do relatorio                                ³
//³                                                                        ³
//³TRCell():New                                                            ³
//³ExpO1 : Objeto TSection que a secao pertence                            ³
//³ExpC2 : Nome da celula do relatório. O SX3 será consultado              ³
//³ExpC3 : Nome da tabela de referencia da celula                          ³
//³ExpC4 : Titulo da celula                                                ³
//³        Default : X3Titulo()                                            ³
//³ExpC5 : Picture                                                         ³
//³        Default : X3_PICTURE                                            ³
//³ExpC6 : Tamanho                                                         ³
//³        Default : X3_TAMANHO                                            ³
//³ExpL7 : Informe se o tamanho esta em pixel                              ³
//³        Default : False                                                 ³
//³ExpB8 : Bloco de código para impressao.                                 ³
//³        Default : ExpC2                                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oSection1:= TRSection():New(oReport,"| P E D I D O  D E  C O M P R A S",{"SC7","SM0","SA2"},/*aOrdem*/) //"| P E D I D O  D E  C O M P R A S"
	oSection1:SetLineStyle()
	oSection1:SetReadOnly()
	oSection1:SetNoFilter("SA2")

	TRCell():New(oSection1,"M0_NOMECOM","SM0",STR0087      ,/*Picture*/,49,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection1,"M0_ENDENT" ,"SM0",STR0088      ,/*Picture*/,48,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection1,"M0_CEPENT" ,"SM0",STR0089      ,/*Picture*/,10,/*lPixel*/,{|| Trans(SM0->M0_CEPENT,PesqPict("SA2","A2_CEP")) })
	TRCell():New(oSection1,"M0_CIDENT" ,"SM0",STR0090      ,/*Picture*/,20,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection1,"M0_ESTENT" ,"SM0",STR0091      ,/*Picture*/,11,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection1,"M0_CGC"    ,"SM0",STR0124      ,/*Picture*/,18,/*lPixel*/,{|| Transform(SM0->M0_CGC,PesqPict("SA2","A2_CGC")) })
	If cPaisLoc == "BRA"
		TRCell():New(oSection1,"M0IE"  ,"   ",STR0041      ,/*Picture*/,18,/*lPixel*/,{|| InscrEst()})
	EndIf
	TRCell():New(oSection1,"M0_TEL"    ,"SM0",STR0092      ,/*Picture*/,14,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection1,"M0_FAX"    ,"SM0",STR0093      ,/*Picture*/,34,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection1,"A2_NOME"   ,"SA2",/*Titulo*/   ,/*Picture*/,40,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection1,"A2_COD"    ,"SA2",/*Titulo*/   ,/*Picture*/,20,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection1,"A2_LOJA"   ,"SA2",/*Titulo*/   ,/*Picture*/,04,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection1,"A2_END"    ,"SA2",/*Titulo*/   ,/*Picture*/,40,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection1,"A2_BAIRRO" ,"SA2",/*Titulo*/   ,/*Picture*/,20,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection1,"A2_CEP"    ,"SA2",/*Titulo*/   ,/*Picture*/,08,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection1,"A2_MUN"    ,"SA2",/*Titulo*/   ,/*Picture*/,15,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection1,"A2_EST"    ,"SA2",/*Titulo*/   ,/*Picture*/,02,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection1,"A2_CGC"    ,"SA2",/*Titulo*/   ,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection1,"INSCR"     ,"   ",If( cPaisLoc$"ARG|POR|EUA",space(11) , STR0095 ),/*Picture*/,18,/*lPixel*/,{|| If( cPaisLoc$"ARG|POR|EUA",space(18), SA2->A2_INSCR ) })
	TRCell():New(oSection1,"FONE"      ,"   ",STR0094      ,/*Picture*/,25,/*lPixel*/,{|| "("+Substr(SA2->A2_DDD,1,3)+") "+Substr(SA2->A2_TEL,1,15)})
	TRCell():New(oSection1,"FAX"       ,"   ",STR0093      ,/*Picture*/,25,/*lPixel*/,{|| "("+Substr(SA2->A2_DDD,1,3)+") "+SubStr(SA2->A2_FAX,1,15)})

	oSection1:Cell("A2_BAIRRO"):SetCellBreak()
	oSection1:Cell("A2_CGC"   ):SetCellBreak()
	oSection1:Cell("INSCR"    ):SetCellBreak()

	oSection2:= TRSection():New(oSection1,STR0103,{"SC7","SB1"},/*aOrdem*/)

	oSection2:SetCellBorder("ALL",,,.T.)
	oSection2:SetCellBorder("RIGHT")
	oSection2:SetCellBorder("LEFT")

	TRCell():New(oSection2,"C7_NUM"		,"SC7",STR0129   ,/*Picture*/,15,/*lPixel*/,,,,,,,.F.)
	TRCell():New(oSection2,"C7_ITEM"    ,"SC7",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/,,,,,,.F.)
	TRCell():New(oSection2,"C7_PRODUTO" ,"SC7",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/,,,,,,.F.)
	TRCell():New(oSection2,"DESCPROD"   ,"   ",STR0097   ,/*Picture*/,30,/*lPixel*/, {|| cDescPro},,,,,,.F.)
	TRCell():New(oSection2,"C7_UM"      ,"SC7",STR0115   ,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/,,,,,,.F.)
	TRCell():New(oSection2,"C7_QUANT"   ,"SC7",/*Titulo*/,PesqPict("SC7","C7_QUANT"),/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/,,,,,,.F.)
	TRCell():New(oSection2,"C7_SEGUM"   ,"SC7",STR0118,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/,,,,,,.F.)
	TRCell():New(oSection2,"C7_QTSEGUM" ,"SC7",/*Titulo*/,PesqPict("SC7","C7_QUANT"),/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/,,,,,,.F.)
	TRCell():New(oSection2,"PRECO"      ,"   ",STR0098,/*Picture*/,16/*Tamanho*/,/*lPixel*/,{|| nVlUnitSC7 },"RIGHT",,"RIGHT")
	TRCell():New(oSection2,"C7_IPI"     ,"SC7",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/,,,,,,.F.)
	TRCell():New(oSection2,"TOTAL"     ,"   ",STR0099,/*Picture*/,14/*Tamanho*/,/*lPixel*/,{|| nValTotSC7 },"RIGHT",,"RIGHT",,,.F.)
	TRCell():New(oSection2,"C7_DATPRF"  ,"SC7",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/,,,,,,.F.)
	TRCell():New(oSection2,"C7_CC"      ,"SC7",STR0066,PesqPict("SC7","C7_CC",20),/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/,,,,,,.F.)
	TRCell():New(oSection2,"C7_NUMSC"   ,"SC7",STR0123,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/,,,,,,.F.)
	TRCell():New(oSection2,"OPCC"       ,"   ",STR0100   ,/*Picture*/,30.5,/*lPixel*/,{|| cOPCC },,,,,,.F.)

	oSection2:Cell("C7_PRODUTO"):SetLineBreak()
	oSection2:Cell("DESCPROD"):SetLineBreak()
	oSection2:Cell("C7_CC"):SetLineBreak()
	oSection2:Cell("OPCC"):SetLineBreak()

	If nTamCdProd > 15
		oSection2:Cell("C7_IPI"):SetTitle(STR0119)
	EndIf

Return(oReport)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ReportPrin³ Autor ³Alexandre Inacio Lemes ³Data  ³06/09/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Emissao do Pedido de Compras / Autorizacao de Entrega      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ReportPrint(ExpO1,ExpN1,ExpN2)                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpO1 = Objeto oReport                      	              ³±±
±±³          ³ ExpN1 = Numero do Recno posicionado do SC7 impressao Menu  ³±±
±±³          ³ ExpN2 = Numero da opcao para impressao via menu do PC      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpO1: Objeto Report do Relatório                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ReportPrint(oReport,nReg,nOpcX)

	Local oSection1   := oReport:Section(1)
	Local oSection2   := oReport:Section(1):Section(1)

	Local aRecnoSave  := {}
	Local aPedido     := {}
	Local aPedMail    := {}
	Local aValIVA     := {}

	Local cNumSC7     := Len(SC7->C7_NUM)
	Local cCondicao   := ""
	Local cFiltro     := ""
	Local cComprador  := ""
	LOcal cAlter	  := ""
	Local cAprov	  := ""
	Local cTipoSC7    := ""
	Local cCondBus    := ""
	Local cMensagem   := ""
	Local cVar        := ""
	Local cPictVUnit := PesqPict("SC7","C7_PRECO",16)
	Local cPictVTot  := PesqPict("SC7","C7_TOTAL",, mv_par12)
	Local lNewAlc	  := .F.
	Local lLiber      := .F.
	Local lRet			:= .T.

	Local nRecnoSC7   := 0
	Local nTotalsX3   := 0
	Local nRecnoSM0   := 0
	Local nX          := 0
	Local nY          := 0
	Local nVias       := 0
	Local nTxMoeda    := 0
	Local nTpImp	  := IIF(ValType(oReport:nDevice)!=Nil,oReport:nDevice,0) // Tipo de Impressao
	Local nPageWidth  := IIF(nTpImp==1.Or.nTpImp==6,2314,2290) // oReport:PageWidth()
	Local nPrinted    := 0
	Local nValIVA     := 0
	Local nTotIpi	  := 0
	Local nTotIcms	  := 0
	Local nTotDesp	  := 0
	Local nTotFrete	  := 0
	Local nTotalNF	  := 0
	Local nTotSeguro  := 0
	Local nLinPC	  := 0
	Local nLinObs     := 0
	Local nDescProd   := 0
	Local nTotal      := 0
	Local nTotMerc    := 0
	Local nPagina     := 0
	Local nOrder      := 1
	Local cUserId     := RetCodUsr()
	Local cCont       := Nil
	Local lImpri      := .F.
	Local cCident	  := ""
	Local cCidcob	  := ""
	Local nLinPC2	  := 0
	Local nLinPC3	  := 0

	Local nTamCdProd:= TamSX3("C7_PRODUTO")[1]
	Local nTamQtd   := TamSX3("C7_QUANT")[1]
	Local nTamanCorr:=148 // tamanho correto do final da linha
	Local nTotalCpos:= 0//tamanho atual do final da linha
	Local lArrumou	:= .F.
//Arrays abaixo := {Campo		,oSection2,Tamanho Minimo	,  Tamanho Maximo}
	Local aTamItem	:= {"C7_ITEM"	,0,TamSX3("C7_ITEM")[1]		,TamSX3("C7_ITEM")[1]+5}
	Local aTamProd 	:= {"C7_PRODUTO",0,IIf(nTamCdProd<30,nTamCdProd+(30-nTamCdProd),30),50}
	Local aTamCdDesc:= {"DESCPROD"	,0,TamSX3("B1_DESC")[1]		,TamSX3("B1_DESC")[1]+30}
	Local aTamUm	:= {"C7_UM"		,0,TamSX3("C7_UM")[1]		,TamSX3("C7_UM")[1]+5}
	Local aTamQuant := {"C7_QUANT"	,0,IIf(nTamQtd<12,nTamQtd+(12-nTamQtd),12),12}
	Local aTamSeg	:= {"C7_SEGUM"	,0,TamSX3("C7_SEGUM")[1]	,TamSX3("C7_SEGUM")[1]+5}
	Local aTamqtseg	:= {"C7_QTSEGUM",0,TamSX3("C7_QTSEGUM")[1]	,TamSX3("C7_QTSEGUM")[1]}
	Local aTamprec 	:= {"PRECO"		,0,16						,30}
	Local aTamIpi   := {"C7_IPI"	,0,TamSX3("C7_IPI")[1]		,TamSX3("C7_IPI")[1]}
	Local aTamTot 	:= {"TOTAL"		,0,14						,25}
	Local aTamDaTp	:= {"C7_DATPRF"	,0,TamSX3("C7_DATPRF")[1]	,IIf(TamSX3("C7_DATPRF")[1]+5 < 11,11,TamSX3("C7_DATPRF")[1]+5)}
	Local aTamCC 	:= {"C7_CC"		,0,9						,15}
	Local aTamNum	:= {"C7_NUMSC"	,0,TamSX3("C7_NUMSC")[1]	,TamSX3("C7_NUMSC")[1]+10}
//                     1*       2*        3*       4*       5*       6*      7*        8*      9*      10*      11*    12*     13*
	Local aTamCamp 	:= {aTamItem,aTamProd,aTamCdDesc,aTamUm,aTamQuant,aTamSeg,aTamqtseg,aTamprec,aTamIpi,aTamTot,aTamDaTp,aTamCC,aTamNum}
	For nX:= 1 To Len(aTamCamp)
		aTamCamp[nX][2] :=oSection2:Cell(aTamCamp[nX][1]):GetCellSize()
	Next

	Private cDescPro  := ""
	Private cOPCC     := ""
	Private	nVlUnitSC7:= 0
	Private nValTotSC7:= 0

	Private cObs01    := ""
	Private cObs02    := ""
	Private cObs03    := ""
	Private cObs04    := ""
	Private cObs05    := ""
	Private cObs06    := ""
	Private cObs07    := ""
	Private cObs08    := ""
	Private cObs09    := ""
	Private cObs10    := ""
	Private cObs11    := ""
	Private cObs12    := ""
	Private cObs13    := ""
	Private cObs14    := ""
	Private cObs15    := ""
	Private cObs16    := ""
	If Type("lPedido") != "L"
		lPedido := .F.
	Endif

	If nTpImp==1 .Or. nTpImp==6
		oSection2:ACELL[2]:NSIZE:=20
		oSection2:ACELL[3]:NSIZE:=20
		oSection2:ACELL[14]:NSIZE:=25
	EndIf

	DbSelectArea("SC7")

	If lAuto
		DbSelectArea("SC7")
		dbGoto(nReg)
		mv_par01 := SC7->C7_NUM
		mv_par02 := SC7->C7_NUM
		mv_par03 := SC7->C7_EMISSAO
		mv_par04 := SC7->C7_EMISSAO
		mv_par05 := Eval({|| cCont:=ChkPergUs(cUserId,"MTR110","05"),If(cCont == Nil,2,cCont) })
		mv_par08 := Eval({|| cCont:=ChkPergUs(cUserId,"MTR110","08"),If(cCont == Nil,C7_TIPO,cCont) })
		mv_par09 := Eval({|| cCont:=ChkPergUs(cUserId,"MTR110","09"),If(cCont == Nil,1,cCont) })
		mv_par10 := Eval({|| cCont:=ChkPergUs(cUserId,"MTR110","10"),If(cCont == Nil,3,cCont) })
		mv_par11 := Eval({|| cCont:=ChkPergUs(cUserId,"MTR110","11"),If(cCont == Nil,3,cCont) })
		mv_par14 := Eval({|| cCont:=ChkPergUs(cUserId,"MTR110","14"),If(cCont == Nil,1,cCont) })
	Else
		MakeAdvplExpr(oReport:uParam)
	
		cCondicao := 'C7_FILIAL=="'       + xFilial("SC7") + '".And.'
		cCondicao += 'C7_NUM>="'          + mv_par01       + '".And.C7_NUM<="'          + mv_par02 + '".And.'
		cCondicao += 'Dtos(C7_EMISSAO)>="'+ Dtos(mv_par03) +'".And.Dtos(C7_EMISSAO)<="' + Dtos(mv_par04) + '"'
	
		oReport:Section(1):SetFilter(cCondicao,IndexKey())
	EndIf

	If lPedido
		mv_par12 := MAX(SC7->C7_MOEDA,1)
	Endif

	If SC7->C7_TIPO == 1 .OR. SC7->C7_TIPO == 3
		If ( cPaisLoc$"ARG|POR|EUA" )
			cCondBus := "1"+StrZero(Val(mv_par01),6)
			nOrder	 := 10
		Else
			cCondBus := mv_par01
			nOrder	 := 1
		EndIf
	Else
		cCondBus := "2"+StrZero(Val(mv_par01),6)
		nOrder	 := 10
	EndIf

	If mv_par14 == 2
		cFiltro := "SC7->C7_QUANT-SC7->C7_QUJE <= 0 .Or. !EMPTY(SC7->C7_RESIDUO)"
	Elseif mv_par14 == 3
		cFiltro := "SC7->C7_QUANT > SC7->C7_QUJE"
	EndIf

	oSection2:Cell("PRECO"):SetPicture(cPictVUnit)
	oSection2:Cell("TOTAL"):SetPicture(cPictVTot)

	TRPosition():New(oSection2,"SB1",1,{ || xFilial("SB1") + SC7->C7_PRODUTO })
	TRPosition():New(oSection2,"SB5",1,{ || xFilial("SB5") + SC7->C7_PRODUTO })

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Executa o CodeBlock com o PrintLine da Sessao 1 toda vez que rodar o oSection1:Init()   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oReport:onPageBreak( { || nPagina++ , nPrinted := 0 , CabecPCxAE(oReport,oSection1,nVias,nPagina) })

	oReport:SetMeter(SC7->(LastRec()))
	DbSelectArea("SC7")
	DbSetOrder(nOrder)
	DbSeek(xFilial("SC7")+cCondBus,.T.)

	oSection2:Init()

	cNumSC7 := SC7->C7_NUM

	While !oReport:Cancel() .And. !SC7->(Eof()) .And. SC7->C7_FILIAL == xFilial("SC7") .And. SC7->C7_NUM >= mv_par01 .And. SC7->C7_NUM <= mv_par02
	
		If (SC7->C7_CONAPRO == "B" .And. mv_par10 == 1) .Or.;
				(SC7->C7_CONAPRO <> "B" .And. mv_par10 == 2) .Or.;
				(SC7->C7_EMITIDO == "S" .And. mv_par05 == 1) .Or.;
				((SC7->C7_EMISSAO < mv_par03) .Or. (SC7->C7_EMISSAO > mv_par04)) .Or.;
				((SC7->C7_TIPO == 1 .OR. SC7->C7_TIPO == 3) .And. mv_par08 == 2) .Or.;
				(SC7->C7_TIPO == 2 .And. (mv_par08 == 1 .OR. mv_par08 == 3)) .Or. !MtrAValOP(mv_par11, "SC7") .Or.;
				(SC7->C7_QUANT > SC7->C7_QUJE .And. mv_par14 == 3) .Or.;
				((SC7->C7_QUANT - SC7->C7_QUJE <= 0 .Or. !Empty(SC7->C7_RESIDUO)) .And. mv_par14 == 2 )
		
			DbSelectArea("SC7")
			dbSkip()
			Loop
		Endif
	
		If oReport:Cancel()
			Exit
		EndIf
	
		MaFisEnd()
		R110FIniPC(SC7->C7_NUM,,,cFiltro)
	
		cObs01    := " "
		cObs02    := " "
		cObs03    := " "
		cObs04    := " "
		cObs05    := " "
		cObs06    := " "
		cObs07    := " "
		cObs08    := " "
		cObs09    := " "
		cObs10    := " "
		cObs11    := " "
		cObs12    := " "
		cObs13    := " "
		cObs14    := " "
		cObs15    := " "
		cObs16    := " "
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Roda a impressao conforme o numero de vias informado no mv_par09 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		For nVias := 1 to mv_par09
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Dispara a cabec especifica do relatorio.                     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			oReport:EndPage()
		
			nPagina  := 0
			nPrinted := 0
			nTotal   := 0
			nTotMerc := 0
			nDescProd:= 0
			nLinObs  := 0
			nRecnoSC7:= SC7->(Recno())
			cNumSC7  := SC7->C7_NUM
			aPedido  := {SC7->C7_FILIAL,SC7->C7_NUM,SC7->C7_EMISSAO,SC7->C7_FORNECE,SC7->C7_LOJA,SC7->C7_TIPO}
		
			While !oReport:Cancel() .And. !SC7->(Eof()) .And. SC7->C7_FILIAL == xFilial("SC7") .And. SC7->C7_NUM == cNumSC7
			
				If (SC7->C7_CONAPRO == "B" .And. mv_par10 == 1) .Or.;
						(SC7->C7_CONAPRO <> "B" .And. mv_par10 == 2) .Or.;
						(SC7->C7_EMITIDO == "S" .And. mv_par05 == 1) .Or.;
						((SC7->C7_EMISSAO < mv_par03) .Or. (SC7->C7_EMISSAO > mv_par04)) .Or.;
						((SC7->C7_TIPO == 1 .OR. SC7->C7_TIPO == 3) .And. mv_par08 == 2) .Or.;
						(SC7->C7_TIPO == 2 .And. (mv_par08 == 1 .OR. mv_par08 == 3)) .Or. !MtrAValOP(mv_par11, "SC7") .Or.;
						(SC7->C7_QUANT > SC7->C7_QUJE .And. mv_par14 == 3) .Or.;
						((SC7->C7_QUANT - SC7->C7_QUJE <= 0 .Or. !Empty(SC7->C7_RESIDUO)) .And. mv_par14 == 2 )
					DbSelectArea("SC7")
					dbSkip()
					Loop
				Endif
			
				If oReport:Cancel()
					Exit
				EndIf
			
				oReport:IncMeter()
			
				If oReport:Row() > oReport:LineHeight() * 100
					oReport:Box( oReport:Row(),010,oReport:Row() + oReport:LineHeight() * 3, nPageWidth )
					oReport:SkipLine()
					oReport:PrintText(STR0101,, 050 ) // Continua na Proxima pagina ....
					oReport:EndPage()
				EndIf
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Salva os Recnos do SC7 no aRecnoSave para marcar reimpressao.³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If Ascan(aRecnoSave,SC7->(Recno())) == 0
					AADD(aRecnoSave,SC7->(Recno()))
				Endif
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Inicializa o descricao do Produto conf. parametro digitado.³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				cDescPro :=  ""
				If Empty(mv_par06)
					mv_par06 := "B1_DESC"
				EndIf
			
				If AllTrim(mv_par06) == "B1_DESC"
					SB1->(DbSetOrder(1))
					SB1->(DbSeek( xFilial("SB1") + SC7->C7_PRODUTO ))
					cDescPro := SB1->B1_DESC
				ElseIf AllTrim(mv_par06) == "B5_CEME"
					SB5->(DbSetOrder(1))
					If SB5->(DbSeek( xFilial("SB5") + SC7->C7_PRODUTO ))
						cDescPro := SB5->B5_CEME
					EndIf
				ElseIf AllTrim(mv_par06) == "C7_DESCRI"
					cDescPro := SC7->C7_DESCRI
				EndIf
			
				If Empty(cDescPro)
					SB1->(DbSetOrder(1))
					SB1->(DbSeek( xFilial("SB1") + SC7->C7_PRODUTO ))
					cDescPro := SB1->B1_DESC
				EndIf
			
				SA5->(DbSetOrder(1))
				If SA5->(DbSeek(xFilial("SA5")+SC7->C7_FORNECE+SC7->C7_LOJA+SC7->C7_PRODUTO)) .And. !Empty(SA5->A5_CODPRF)
					cDescPro := cDescPro + " ("+Alltrim(SA5->A5_CODPRF)+")"
				EndIf
			
				If SC7->C7_DESC1 != 0 .Or. SC7->C7_DESC2 != 0 .Or. SC7->C7_DESC3 != 0
					nDescProd+= CalcDesc(SC7->C7_TOTAL,SC7->C7_DESC1,SC7->C7_DESC2,SC7->C7_DESC3)
				Else
					nDescProd+=SC7->C7_VLDESC
				Endif
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Inicializacao da Observacao do Pedido.                       ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If !Empty(SC7->C7_OBS) .And. nLinObs < 17
					nLinObs++
					cVar:="cObs"+StrZero(nLinObs,2)
					Eval(MemVarBlock(cVar),SC7->C7_OBS)
				Endif
			
				nTxMoeda   := IIF(SC7->C7_TXMOEDA > 0,SC7->C7_TXMOEDA,Nil)
				nValTotSC7 := xMoeda(SC7->C7_TOTAL,SC7->C7_MOEDA,MV_PAR12,SC7->C7_DATPRF,MsDecimais(SC7->C7_MOEDA),nTxMoeda)
			
				nTotal     := nTotal + SC7->C7_TOTAL
				nTotMerc   := MaFisRet(,"NF_TOTAL")
			
				If oReport:nDevice != 4 .Or. (oReport:nDevice == 4 .And. !oReport:lXlsTable .And. oReport:lXlsHeader)  //impressao em planilha tipo tabela
					oSection2:Cell("C7_NUM"):Disable()
				EndIf
			
				If MV_PAR07 == 2 .And. !Empty(SC7->C7_QTSEGUM) .And. !Empty(SC7->C7_SEGUM)
				//oSection2:Cell("C7_DATPRF"):SetSize(9)
					oSection2:Cell("C7_SEGUM"  ):Enable()
					oSection2:Cell("C7_QTSEGUM"):Enable()
					oSection2:Cell("C7_UM"     ):Disable()
					oSection2:Cell("C7_QUANT"  ):Disable()
					nVlUnitSC7 := xMoeda((SC7->C7_TOTAL/SC7->C7_QTSEGUM),SC7->C7_MOEDA,MV_PAR12,SC7->C7_DATPRF,MsDecimais(SC7->C7_MOEDA),nTxMoeda)
				ElseIf MV_PAR07 == 1 .And. !Empty(SC7->C7_QUANT) .And. !Empty(SC7->C7_UM)
				//oSection2:Cell("C7_DATPRF"):SetSize(11)
					oSection2:Cell("C7_SEGUM"  ):Disable()
					oSection2:Cell("C7_QTSEGUM"):Disable()
					oSection2:Cell("C7_UM"     ):Enable()
					oSection2:Cell("C7_QUANT"  ):Enable()
					nVlUnitSC7 := xMoeda(SC7->C7_PRECO,SC7->C7_MOEDA,MV_PAR12,SC7->C7_DATPRF,MsDecimais(SC7->C7_MOEDA),nTxMoeda)
				Else
					nTamanCorr  :=143
				//oSection2:Cell("C7_DATPRF"):SetSize(11)
					oSection2:Cell("C7_SEGUM"  ):Enable()
					oSection2:Cell("C7_QTSEGUM"):Enable()
					oSection2:Cell("C7_UM"     ):Enable()
					oSection2:Cell("C7_QUANT"  ):Enable()
					nVlUnitSC7 := xMoeda(SC7->C7_PRECO,SC7->C7_MOEDA,MV_PAR12,SC7->C7_DATPRF,MsDecimais(SC7->C7_MOEDA),nTxMoeda)
				EndIf
			
				If cPaisLoc <> "BRA" .Or. mv_par08 == 2
					oSection2:Cell("C7_IPI" ):Disable()
				EndIf
			
				If mv_par08 == 1 .OR. mv_par08 == 3
					oSection2:Cell("OPCC"):Disable()
				Else
					oSection2:Cell("C7_DATPRF"):SetSize(9)
					oSection2:Cell("C7_CC"):Disable()
					oSection2:Cell("C7_NUMSC"):Disable()
					If !Empty(SC7->C7_OP)
						cOPCC := STR0065 + " " + SC7->C7_OP
					ElseIf !Empty(SC7->C7_CC)
						cOPCC := STR0066 + " " + SC7->C7_CC
					EndIf
				EndIf
				nTamanCorr := IIF(oReport:nDevice == 2,nTamanCorr-2,nTamanCorr)  // se for impressão por spool diminuir o tamanho da linha
				//Ajusta o tamanho dos campos de acordo com o tamanho do relatorio
				If !lArrumou .And. !oSection2:UseFilter()
					lArrumou := .T.
					For nX:= 1 To Len(aTamCamp)
						If oSection2:Cell(aTamCamp[nX][1]):Enabled()
							nTotalCpos +=aTamCamp[nX][2]
							nTotalsX3 +=aTamCamp[nX][3]
						EndIf
					Next
					nX:=0
					
					//Verifica se é possível realizar ajuste no tamanho dos campos considerando o tamanho físico dos campos no dicionário.
					If nTotalsX3 > nTamanCorr
						lRet := .F.
					EndIf
					
					If lRet
						While nTotalCpos <> nTamanCorr
							IIf(nX >= Len(aTamCamp),nX:=1,nX++)
							If oSection2:Cell(aTamCamp[nX][1]):Enabled() //se o campo estiver  Enable
								If nTotalCpos > nTamanCorr //se os campos passarem da linha
									If aTamCamp[nX][2] >  aTamCamp[nX][3] //Se o campo[nX] estiver maior que o tamanho minimo
										aTamCamp[nX][2] -= 1      //diminui o tamanho do campo
										nTotalCpos -= 1
									EndIf
								ElseIf aTamCamp[nX][2] <  aTamCamp[nX][4] //Se o campo[nX] estiver menor que o tamanho maximo
									aTamCamp[nX][2] += 1 //aumenta o tamanho do campo
									nTotalCpos +=1
								Endif
							Endif
						EndDo
					EndIf
					For nX:= 1 To Len(aTamCamp)
						If oSection2:Cell(aTamCamp[nX][1]):Enabled()
							oSection2:Cell(aTamCamp[nX][1]):SetSize(aTamCamp[nX][2])//atualiza o tamanho certo dos campos
						EndIf
					Next
				EndIf
				If oReport:nDevice == 4 .And. oReport:lXlsTable .And. !oReport:lXlsHeader  //impressao em planilha tipo tabela
					oSection1:Init()
					TRPosition():New(oSection1,"SA2",1,{ || xFilial("SA2") + SC7->C7_FORNECE + SC7->C7_LOJA })
					oSection1:PrintLine()
					oSection2:PrintLine()
					oSection1:Finish()
				Else
					oSection2:PrintLine()
				EndIf
			
				nPrinted ++
				lImpri  := .T.
				DbSelectArea("SC7")
				dbSkip()
			
			EndDo
		
			SC7->(dbGoto(nRecnoSC7))
		
			If oReport:Row() > oReport:LineHeight() * 68
			
				oReport:Box( oReport:Row(),010,oReport:Row() + oReport:LineHeight() * 3, nPageWidth )
				oReport:SkipLine()
				oReport:PrintText(STR0101,, 050 ) // Continua na Proxima pagina ....
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Dispara a cabec especifica do relatorio.                     ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				oReport:EndPage()
				oReport:PrintText(" ",1992 , 010 ) // Necessario para posicionar Row() para a impressao do Rodape
			
				oReport:Box( 280,010,oReport:Row() + oReport:LineHeight() * ( 93 - nPrinted ) , nPageWidth )
			
			Else
				oReport:Box( oReport:Row(),oReport:Col(),oReport:Row() + oReport:LineHeight() * ( 93 - nPrinted ) , nPageWidth )
			EndIf
		
			oReport:Box( 1990 ,010,oReport:Row() + oReport:LineHeight() * ( 93 - nPrinted ) , nPageWidth )
			oReport:Box( 2080 ,010,oReport:Row() + oReport:LineHeight() * ( 93 - nPrinted ) , nPageWidth )
			oReport:Box( 2200 ,010,oReport:Row() + oReport:LineHeight() * ( 93 - nPrinted ) , nPageWidth )
			oReport:Box( 2320 ,010,oReport:Row() + oReport:LineHeight() * ( 93 - nPrinted ) , nPageWidth )
		
			oReport:Box( 2200 , 1080 , 2320 , 1400 ) // Box da Data de Emissao
			oReport:Box( 2320 ,  010 , 2406 , 1220 ) // Box do Reajuste
			oReport:Box( 2320 , 1220 , 2460 , 1750 ) // Box do IPI e do Frete
			oReport:Box( 2320 , 1750 , 2460 , nPageWidth ) // Box do ICMS Despesas e Seguro
			oReport:Box( 2406 ,  010 , 2700 , 1220 ) // Box das Observacoes

			cMensagem:= Formula(C7_MSG)
			If !Empty(cMensagem)
				oReport:SkipLine()
				oReport:PrintText(PadR(cMensagem,129), , oSection2:Cell("DESCPROD"):ColPos() )
			Endif
		
			oReport:PrintText( STR0007 /*"D E S C O N T O S -->"*/ + " " + ;
				TransForm(SC7->C7_DESC1,"999.99" ) + " %    " + ;
				TransForm(SC7->C7_DESC2,"999.99" ) + " %    " + ;
				TransForm(SC7->C7_DESC3,"999.99" ) + " %    " + ;
				TransForm(xMoeda(nDescProd,SC7->C7_MOEDA,MV_PAR12,SC7->C7_DATPRF,MsDecimais(SC7->C7_MOEDA),nTxMoeda) , PesqPict("SC7","C7_VLDESC",14, MV_PAR12) ),;
				2022 , 050 )
		
			oReport:SkipLine()
			oReport:SkipLine()
			oReport:SkipLine()
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Posiciona o Arquivo de Empresa SM0.                          ³
		//³ Imprime endereco de entrega do SM0 somente se o MV_PAR13 =" "³
		//³ e o Local de Cobranca :                                      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			SM0->(DbSetOrder(1))
			nRecnoSM0 := SM0->(Recno())
			SM0->(DbSeek(SUBS(cNumEmp,1,2)+SC7->C7_FILENT))

			cCident := IIF(len(SM0->M0_CIDENT)>20,Substr(SM0->M0_CIDENT,1,15),SM0->M0_CIDENT)
			cCidcob := IIF(len(SM0->M0_CIDCOB)>20,Substr(SM0->M0_CIDCOB,1,15),SM0->M0_CIDCOB)

			If Empty(MV_PAR13) //"Local de Entrega  : "
				oReport:PrintText(STR0008 + SM0->M0_ENDENT+"  "+Rtrim(SM0->M0_CIDENT)+"  - "+SM0->M0_ESTENT+" - "+STR0009+" "+Trans(Alltrim(SM0->M0_CEPENT),PesqPict("SA2","A2_CEP")),, 050 )
			Else
				oReport:PrintText(STR0008 + mv_par13,, 050 ) //"Local de Entrega  : " imprime o endereco digitado na pergunte
			Endif
			SM0->(dbGoto(nRecnoSM0))
			oReport:PrintText(STR0010 + SM0->M0_ENDCOB+"  "+Rtrim(SM0->M0_CIDCOB)+"  - "+SM0->M0_ESTCOB+" - "+STR0009+" "+Trans(Alltrim(SM0->M0_CEPCOB),PesqPict("SA2","A2_CEP")),, 050 )
		
			oReport:SkipLine()
			oReport:SkipLine()
		
			SE4->(DbSetOrder(1))
			SE4->(DbSeek(xFilial("SE4")+SC7->C7_COND))
		
			nLinPC := oReport:Row()
			oReport:PrintText( STR0011+SubStr(SE4->E4_COND,1,40),nLinPC,050 )
			oReport:PrintText( STR0070,nLinPC,1120 ) //"Data de Emissao"
			oReport:PrintText( STR0013 +" "+ Transform(xMoeda(nTotal,SC7->C7_MOEDA,MV_PAR12,SC7->C7_DATPRF,MsDecimais(SC7->C7_MOEDA),nTxMoeda) , tm(nTotal,14,MsDecimais(MV_PAR12)) ),nLinPC,1612 ) //"Total das Mercadorias : "
			oReport:SkipLine()
			nLinPC := oReport:Row()
		
			If cPaisLoc<>"BRA"
				aValIVA := MaFisRet(,"NF_VALIMP")
				nValIVA :=0
				If !Empty(aValIVA)
					For nY:=1 to Len(aValIVA)
						nValIVA+=aValIVA[nY]
					Next nY
				EndIf
				oReport:PrintText(SubStr(SE4->E4_DESCRI,1,34),nLinPC, 050 )
				oReport:PrintText( dtoc(SC7->C7_EMISSAO),nLinPC,1120 )
				oReport:PrintText( STR0063+ "   " + ; //"Total dos Impostos:    "
				Transform(xMoeda(nValIVA,SC7->C7_MOEDA,MV_PAR12,SC7->C7_DATPRF,MsDecimais(SC7->C7_MOEDA),nTxMoeda) , tm(nValIVA,14,MsDecimais(MV_PAR12)) ),nLinPC,1612 )
			Else
				oReport:PrintText( SubStr(SE4->E4_DESCRI,1,34),nLinPC, 050 )
				oReport:PrintText( dtoc(SC7->C7_EMISSAO),nLinPC,1120 )
				oReport:PrintText( STR0064+ "  " + ; //"Total com Impostos:    "
				Transform(xMoeda(nTotMerc,SC7->C7_MOEDA,MV_PAR12,SC7->C7_DATPRF,MsDecimais(SC7->C7_MOEDA),nTxMoeda) , tm(nTotMerc,14,MsDecimais(MV_PAR12)) ),nLinPC,1612 )
			Endif
			oReport:SkipLine()
		
			nTotIpi	  := MaFisRet(,'NF_VALIPI')
			nTotIcms  := MaFisRet(,'NF_VALICM')
			nTotDesp  := MaFisRet(,'NF_DESPESA')
			nTotFrete := MaFisRet(,'NF_FRETE')
			nTotSeguro:= MaFisRet(,'NF_SEGURO')
			nTotalNF  := MaFisRet(,'NF_TOTAL')
		
			oReport:SkipLine()
			oReport:SkipLine()
			nLinPC := oReport:Row()
		
			SM4->(DbSetOrder(1))
			If SM4->(DbSeek(xFilial("SM4")+SC7->C7_REAJUST))
				oReport:PrintText(  STR0014 + " " + SC7->C7_REAJUST + " " + SM4->M4_DESCR ,nLinPC, 050 )  //"Reajuste :"
			EndIf

			If cPaisLoc == "BRA"
				oReport:PrintText( STR0071 + Transform(xMoeda(nTotIPI ,SC7->C7_MOEDA,MV_PAR12,SC7->C7_DATPRF,MsDecimais(SC7->C7_MOEDA),nTxMoeda) , tm(nTotIpi ,14,MsDecimais(MV_PAR12))) ,nLinPC,1320 ) //"IPI      :"
				oReport:PrintText( STR0072 + Transform(xMoeda(nTotIcms,SC7->C7_MOEDA,MV_PAR12,SC7->C7_DATPRF,MsDecimais(SC7->C7_MOEDA),nTxMoeda) , tm(nTotIcms,14,MsDecimais(MV_PAR12))) ,nLinPC,1815 ) //"ICMS     :"
			EndIf
			oReport:SkipLine()

			nLinPC := oReport:Row()
			oReport:PrintText( STR0073 + Transform(xMoeda(nTotFrete,SC7->C7_MOEDA,MV_PAR12,SC7->C7_DATPRF,MsDecimais(SC7->C7_MOEDA),nTxMoeda) , tm(nTotFrete,14,MsDecimais(MV_PAR12))) ,nLinPC,1320 ) //"Frete    :"
			oReport:PrintText( STR0074 + Transform(xMoeda(nTotDesp ,SC7->C7_MOEDA,MV_PAR12,SC7->C7_DATPRF,MsDecimais(SC7->C7_MOEDA),nTxMoeda) , tm(nTotDesp ,14,MsDecimais(MV_PAR12))) ,nLinPC,1815 ) //"Despesas :"
			oReport:SkipLine()
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Inicializar campos de Observacoes.                           ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If Empty(cObs02)
				If Len(cObs01) > 30
					cObs := cObs01
					cObs01 := Substr(cObs,1,30)
					For nX := 2 To 16
						cVar  := "cObs"+StrZero(nX,2)
						&cVar := Substr(cObs,(30*(nX-1))+1,30)
					Next nX
				EndIf
			Else
				cObs01:= Substr(cObs01,1,IIf(Len(cObs01)<30,Len(cObs01),30))
				cObs02:= Substr(cObs02,1,IIf(Len(cObs02)<30,Len(cObs01),30))
				cObs03:= Substr(cObs03,1,IIf(Len(cObs03)<30,Len(cObs01),30))
				cObs04:= Substr(cObs04,1,IIf(Len(cObs04)<30,Len(cObs01),30))
				cObs05:= Substr(cObs05,1,IIf(Len(cObs05)<30,Len(cObs01),30))
				cObs06:= Substr(cObs06,1,IIf(Len(cObs06)<30,Len(cObs01),30))
				cObs07:= Substr(cObs07,1,IIf(Len(cObs07)<30,Len(cObs01),30))
				cObs08:= Substr(cObs08,1,IIf(Len(cObs08)<30,Len(cObs01),30))
				cObs09:= Substr(cObs09,1,IIf(Len(cObs09)<30,Len(cObs01),30))
				cObs10:= Substr(cObs10,1,IIf(Len(cObs10)<30,Len(cObs01),30))
				cObs11:= Substr(cObs11,1,IIf(Len(cObs11)<30,Len(cObs01),30))
				cObs12:= Substr(cObs12,1,IIf(Len(cObs12)<30,Len(cObs01),30))
				cObs13:= Substr(cObs13,1,IIf(Len(cObs13)<30,Len(cObs01),30))
				cObs14:= Substr(cObs14,1,IIf(Len(cObs14)<30,Len(cObs01),30))
				cObs15:= Substr(cObs15,1,IIf(Len(cObs15)<30,Len(cObs01),30))
				cObs16:= Substr(cObs16,1,IIf(Len(cObs16)<30,Len(cObs01),30))
			EndIf
		
			cComprador:= ""
			cAlter	  := ""
			cAprov	  := ""
			lNewAlc	  := .F.
			lLiber 	  := .F.
		
			DbSelectArea("SC7")
			If !Empty(SC7->C7_APROV)
			
				cTipoSC7:= IIF((SC7->C7_TIPO == 1 .OR. SC7->C7_TIPO == 3),"PC","AE")
				lNewAlc := .T.
				cComprador := UsrFullName(SC7->C7_USER)
				If SC7->C7_CONAPRO != "B"
					lLiber := .T.
				EndIf
				DbSelectArea("SCR")
				DbSetOrder(1)
				DbSeek(xFilial("SCR")+cTipoSC7+SC7->C7_NUM)
				While !Eof() .And. SCR->CR_FILIAL+Alltrim(SCR->CR_NUM) == xFilial("SCR")+Alltrim(SC7->C7_NUM) .And. SCR->CR_TIPO == cTipoSC7
					cAprov += AllTrim(UsrFullName(SCR->CR_USER))+" ["
					Do Case
					Case SCR->CR_STATUS=="03" //Liberado
						cAprov += "Ok"
					Case SCR->CR_STATUS=="04" //Bloqueado
						cAprov += "BLQ"
					Case SCR->CR_STATUS=="05" //Nivel Liberado
						cAprov += "##"
					OtherWise                 //Aguar.Lib
						cAprov += "??"
					EndCase
					cAprov += "] - "
					DbSelectArea("SCR")
					dbSkip()
				Enddo
				If !Empty(SC7->C7_GRUPCOM)
					DbSelectArea("SAJ")
					DbSetOrder(1)
					DbSeek(xFilial("SAJ")+SC7->C7_GRUPCOM)
					While !Eof() .And. SAJ->AJ_FILIAL+SAJ->AJ_GRCOM == xFilial("SAJ")+SC7->C7_GRUPCOM
						If SAJ->AJ_USER != SC7->C7_USER
							cAlter += AllTrim(UsrFullName(SAJ->AJ_USER))+"/"
						EndIf
						DbSelectArea("SAJ")
						dbSkip()
					EndDo
				EndIf
			EndIf

			nLinPC := oReport:Row()
			oReport:PrintText( STR0077 ,nLinPC, 050 ) // "Observacoes "
			oReport:PrintText( STR0076 + Transform(xMoeda(nTotSeguro,SC7->C7_MOEDA,MV_PAR12,SC7->C7_DATPRF,MsDecimais(SC7->C7_MOEDA),nTxMoeda) , tm(nTotSeguro,14,MsDecimais(MV_PAR12))) ,nLinPC, 1815 ) // "SEGURO   :"
			oReport:SkipLine()

			nLinPC2 := oReport:Row()
			oReport:PrintText(cObs01,,050 )
			oReport:PrintText(cObs02,,050 )

			nLinPC := oReport:Row()
			oReport:PrintText(cObs03,nLinPC,050 )

			If !lNewAlc
				oReport:PrintText( STR0078 + Transform(xMoeda(nTotalNF,SC7->C7_MOEDA,MV_PAR12,SC7->C7_DATPRF,MsDecimais(SC7->C7_MOEDA),nTxMoeda) , tm(nTotalNF,14,MsDecimais(MV_PAR12))) ,nLinPC,1774 ) //"Total Geral :"
			Else
				If lLiber
					oReport:PrintText( STR0078 + Transform(xMoeda(nTotalNF,SC7->C7_MOEDA,MV_PAR12,SC7->C7_DATPRF,MsDecimais(SC7->C7_MOEDA),nTxMoeda) , tm(nTotalNF,14,MsDecimais(MV_PAR12))) ,nLinPC,1774 )
				Else
					oReport:PrintText( STR0078 + If((SC7->C7_TIPO == 1 .OR. SC7->C7_TIPO == 3),STR0051,STR0086) ,nLinPC,1390 )
				EndIf
			EndIf
			oReport:SkipLine()
		
			oReport:PrintText(cObs04,,050 )
			oReport:PrintText(cObs05,,050 )
			oReport:PrintText(cObs06,,050 )
			nLinPC3 := oReport:Row()
			oReport:PrintText(cObs07,,050 )
			oReport:PrintText(cObs08,,050 )
			oReport:PrintText(cObs09,nLinPC2,650 )
			oReport:SkipLine()
			oReport:PrintText(cObs10,,650 )
			oReport:PrintText(cObs11,,650 )
			oReport:PrintText(cObs12,,650 )
			oReport:PrintText(cObs13,,650 )
			oReport:PrintText(cObs14,,650 )
			oReport:PrintText(cObs15,,650 )
			oReport:PrintText(cObs16,,650 )

			If !lNewAlc
			
				oReport:Box( 2700 , 0010 , 3020 , 0400 )
				oReport:Box( 2700 , 0400 , 3020 , 0800 )
				oReport:Box( 2700 , 0800 , 3020 , 1220 )
				oReport:Box( 2600 , 1220 , 3020 , 1770 )
				oReport:Box( 2600 , 1770 , 3020 , nPageWidth )
			
				oReport:SkipLine()
				oReport:SkipLine()
				oReport:SkipLine()

				nLinPC := oReport:Row()
				oReport:PrintText( If((SC7->C7_TIPO == 1 .OR. SC7->C7_TIPO == 3),STR0079,STR0084),nLinPC,1310) //"Liberacao do Pedido"##"Liber. Autorizacao "
				oReport:PrintText( STR0080 + IF( SC7->C7_TPFRETE $ "F","FOB",IF(SC7->C7_TPFRETE $ "C","CIF",IF(SC7->C7_TPFRETE $ "T","Por Conta Terceiros"," " ) )) ,nLinPC,1820 )
				oReport:SkipLine()

				oReport:SkipLine()
				oReport:SkipLine()

				nLinPC := oReport:Row()
				oReport:PrintText( STR0021 ,nLinPC, 050 ) //"Comprador"
				oReport:PrintText( STR0022 ,nLinPC, 430 ) //"Gerencia"
				oReport:PrintText( STR0023 ,nLinPC, 850 ) //"Diretoria"
				oReport:SkipLine()

				oReport:SkipLine()
				oReport:SkipLine()
				oReport:SkipLine()

				nLinPC := oReport:Row()
				oReport:PrintText( Replic("_",23) ,nLinPC,  050 )
				oReport:PrintText( Replic("_",23) ,nLinPC,  430 )
				oReport:PrintText( Replic("_",23) ,nLinPC,  850 )
				oReport:PrintText( Replic("_",31) ,nLinPC, 1310 )
				oReport:SkipLine()

				oReport:SkipLine()
				oReport:SkipLine()
				oReport:SkipLine()
				oReport:SkipLine()
				oReport:SkipLine()
				If SC7->C7_TIPO == 1 .OR. SC7->C7_TIPO == 3
					oReport:PrintText(STR0081,,050 ) //"NOTA: So aceitaremos a mercadoria se na sua Nota Fiscal constar o numero do nosso Pedido de Compras."
				Else
					oReport:PrintText(STR0083,,050 ) //"NOTA: So aceitaremos a mercadoria se na sua Nota Fiscal constar o numero da Autorizacao de Entrega."
				EndIf
			
			Else
			
				oReport:Box( 2570 , 1220 , 2700 , 1820 )
				oReport:Box( 2570 , 1820 , 2700 , nPageWidth )
				oReport:Box( 2700 , 0010 , 3020 , nPageWidth )
				oReport:Box( 2970 , 0010 , 3020 , 1340 )
			
				nLinPC := nLinPC3
			
				oReport:PrintText( If((SC7->C7_TIPO == 1 .OR. SC7->C7_TIPO == 3), If( lLiber , STR0050 , STR0051 ) , If( lLiber , STR0085 , STR0086 ) ),nLinPC,1290 ) //"     P E D I D O   L I B E R A D O"#"|     P E D I D O   B L O Q U E A D O !!!"
				oReport:PrintText( STR0080 + Substr(RetTipoFrete(SC7->C7_TPFRETE),3),nLinPC,1830 ) //"Obs. do Frete: "
				oReport:SkipLine()

				oReport:SkipLine()
				oReport:SkipLine()
				oReport:SkipLine()
				oReport:PrintText(STR0052+" "+Substr(cComprador,1,60),,050 ) 	//"Comprador Responsavel :" //"BLQ:Bloqueado"
				oReport:SkipLine()
				oReport:PrintText(STR0053+" "+If( Len(cAlter) > 0 , Substr(cAlter,001,130) , " " ),,050 ) //"Compradores Alternativos :"
				oReport:PrintText(            If( Len(cAlter) > 0 , Substr(cAlter,131,130) , " " ),,440 ) //"Compradores Alternativos :"
				oReport:SkipLine()
				oReport:PrintText(STR0054+" "+If( Len(cAprov) > 0 , Substr(cAprov,001,140) , " " ),,050 ) //"Aprovador(es) :"
				oReport:PrintText(            If( Len(cAprov) > 0 , Substr(cAprov,141,140) , " " ),,310 ) //"Aprovador(es) :"
				oReport:SkipLine()

				nLinPC := oReport:Row()
				oReport:PrintText( STR0082+" "+STR0060 ,nLinPC, 050 ) 	//"Legendas da Aprovacao : //"BLQ:Bloqueado"
				oReport:PrintText(       "|  "+STR0061 ,nLinPC, 610 ) 	//"Ok:Liberado"
				oReport:PrintText(       "|  "+STR0062 ,nLinPC, 830 ) 	//"??:Aguar.Lib"
				oReport:PrintText(       "|  "+STR0067 ,nLinPC,1070 )	//"##:Nivel Lib"
				oReport:SkipLine()

				oReport:SkipLine()
				If SC7->C7_TIPO == 1 .OR. SC7->C7_TIPO == 3
					oReport:PrintText(STR0081,,050 ) //"NOTA: So aceitaremos a mercadoria se na sua Nota Fiscal constar o numero do nosso Pedido de Compras."
				Else
					oReport:PrintText(STR0083,,050 ) //"NOTA: So aceitaremos a mercadoria se na sua Nota Fiscal constar o numero da Autorizacao de Entrega."
				EndIf
			EndIf
		
		Next nVias
	
		MaFisEnd()
	
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Grava no SC7 as Reemissoes e atualiza o Flag de impressao.   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
		
		DbSelectArea("SC7")
		If Len(aRecnoSave) > 0
			For nX :=1 to Len(aRecnoSave)
				dbGoto(aRecnoSave[nX])
				If(SC7->C7_QTDREEM >= 99)
					If nRet == 1
						RecLock("SC7",.F.)
						SC7->C7_EMITIDO := "S"
						MsUnLock()
					Elseif nRet == 2
						RecLock("SC7",.F.)
						SC7->C7_QTDREEM := 1
						SC7->C7_EMITIDO := "S"
						MsUnLock()
					Elseif nRet == 3
					//cancelar
					Endif
				Else
					RecLock("SC7",.F.)
					SC7->C7_QTDREEM := (SC7->C7_QTDREEM + 1)
					SC7->C7_EMITIDO := "S"
					MsUnLock()
				Endif
			Next nX
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Reposiciona o SC7 com base no ultimo elemento do aRecnoSave. ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			dbGoto(aRecnoSave[Len(aRecnoSave)])
		Endif
	
		Aadd(aPedMail,aPedido)
	
		aRecnoSave := {}
	
		DbSelectArea("SC7")
		dbSkip()
	
	EndDo

	oSection2:Finish()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Executa o ponto de entrada M110MAIL quando a impressao for   ³
//³ enviada por email, fornecendo um Array para o usuario conten ³
//³ do os pedidos enviados para possivel manipulacao.            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ExistBlock("M110MAIL")
		lEnvMail := (oReport:nDevice == 3)
		If lEnvMail
			Execblock("M110MAIL",.F.,.F.,{aPedMail})
		EndIf
	EndIf

	If lAuto .And. !lImpri
		Aviso(STR0104,STR0105,{"OK"})
	Endif

	DbSelectArea("SC7")
	dbClearFilter()
	DbSetOrder(1)

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³CabecPCxAE³ Autor ³Alexandre Inacio Lemes ³Data  ³06/09/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Emissao do Pedido de Compras / Autorizacao de Entrega      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CabecPCxAE(ExpO1,ExpO2,ExpN1,ExpN2)                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpO1 = Objeto oReport                      	              ³±±
±±³          ³ ExpO2 = Objeto da sessao1 com o cabec                      ³±±
±±³          ³ ExpN1 = Numero de Vias                                     ³±±
±±³          ³ ExpN2 = Numero de Pagina                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function CabecPCxAE(oReport,oSection1,nVias,nPagina)
	Local cMoeda	:= IIf( mv_par12 < 10 , Str(mv_par12,1) , Str(mv_par12,2) )
	Local nLinPC	:= 0
	Local nTpImp	  := IIF(ValType(oReport:nDevice)!=Nil,oReport:nDevice,0) // Tipo de Impressao
	Local nPageWidth  := IIF(nTpImp==1.Or.nTpImp==6,2314,2290)
	Local cCident	:= IIF(len(SM0->M0_CIDENT)>20,Substr(SM0->M0_CIDENT,1,15),SM0->M0_CIDENT)
	Local cCGC		:= ""
	PRIVATE cBitmap := ""
	Public nRet:= 0
	TRPosition():New(oSection1,"SA2",1,{ || xFilial("SA2") + SC7->C7_FORNECE + SC7->C7_LOJA })

	cBitmap := R110Logo()

	SA2->(DbSetOrder(1))
	SA2->(DbSeek(xFilial("SA2") + SC7->C7_FORNECE + SC7->C7_LOJA))

	oSection1:Init()

	oReport:Box( 010 , 010 ,  260 , 1000 )
	oReport:Box( 010 , 1010,  260 , nPageWidth-2 ) // 2288

	oReport:PrintText( If(nPagina > 1,(STR0033)," "),,oSection1:Cell("M0_NOMECOM"):ColPos())

	nLinPC := oReport:Row()
	oReport:PrintText( If( mv_par08 == 1 , (STR0068), (STR0069) ) + " - " + GetMV("MV_MOEDA"+cMoeda) ,nLinPC,1030 )
	oReport:PrintText( If( mv_par08 == 1 , SC7->C7_NUM, SC7->C7_NUMSC + "/" + SC7->C7_NUM ) + " /" + Ltrim(Str(nPagina,2)) ,nLinPC,1910 )
	oReport:SkipLine()


	nLinPC := oReport:Row()
	If(SC7->C7_QTDREEM >= 99)
		nRet := Aviso("TOTVS", STR0125 +chr(13)+chr(10)+ "1- " + STR0126 +chr(13)+chr(10)+ "2- " + STR0127 +chr(13)+chr(10)+ "3- " + STR0128,{"1", "2", "3"},2)
		If(nRet == 1)
			oReport:PrintText( Str(SC7->C7_QTDREEM,2) + STR0034 + Str(nVias,2) + STR0035 ,nLinPC,1910 )
		Elseif(nRet == 2)
			oReport:PrintText( "1" + STR0034 + Str(nVias,2) + STR0035 ,nLinPC,1910 )
		Elseif(nRet == 3)
			oReport:CancelPrint()
		Endif
	Else
		oReport:PrintText( If( SC7->C7_QTDREEM > 0, Str(SC7->C7_QTDREEM+1,2) , "1" ) + STR0034 + Str(nVias,2) + STR0035 ,nLinPC,1910 )
	Endif


	oReport:SkipLine()

	_cFileLogo	:= GetSrvProfString('Startpath','') + cBitmap
	oReport:SayBitmap(25,25,_cFileLogo,150,60) // insere o logo no relatorio

	nLinPC := oReport:Row()
	oReport:PrintText(STR0087 + SM0->M0_NOMECOM,nLinPC,15)  // "Empresa:"
	oReport:PrintText(STR0106 + Substr(SA2->A2_NOME,1,50)+" "+STR0107+SA2->A2_COD+" "+STR0108+SA2->A2_LOJA,nLinPC,1025)
	oReport:SkipLine()

	nLinPC := oReport:Row()
	oReport:PrintText(STR0088 + SM0->M0_ENDENT,nLinPC,15)
	oReport:PrintText(STR0088 + Substr(SA2->A2_END,1,49)+" "+STR0109+ Substr(SA2->A2_BAIRRO,1,25),nLinPC,1025)
	oReport:SkipLine()
                            
	If cPaisLoc == "BRA"
		cCGC	:= Transform(SA2->A2_CGC,Iif(SA2->A2_TIPO == 'F',Substr(PICPES(SA2->A2_TIPO),1,17),Substr(PICPES(SA2->A2_TIPO),1,21)))
	Else
		cCGC	:= SA2->A2_CGC
	EndIf
            
	nLinPC := oReport:Row()
	oReport:PrintText(STR0089 + Trans(SM0->M0_CEPENT,PesqPict("SA2","A2_CEP"))+Space(2)+STR0090 + "  " + RTRIM(SM0->M0_CIDENT) + " " + STR0091 + SM0->M0_ESTENT ,nLinPC,15)
	oReport:PrintText(STR0110+Left(SA2->A2_MUN, 30)+" "+STR0111+SA2->A2_EST+" "+STR0112+SA2->A2_CEP+" "+STR0124+":"+cCGC,nLinPC,1025)
	oReport:SkipLine()

	nLinPC := oReport:Row()
	oReport:PrintText(STR0092 + SM0->M0_TEL + Space(2) + STR0093 + SM0->M0_FAX ,nLinPC,15)
	oReport:PrintText(STR0094 + "("+Substr(SA2->A2_DDD,1,3)+") "+Substr(SA2->A2_TEL,1,15) + " "+STR0114+"("+Substr(SA2->A2_DDD,1,3)+") "+SubStr(SA2->A2_FAX,1,15)+" "+If( cPaisLoc$"ARG|POR|EUA",space(11) , STR0095 )+If( cPaisLoc$"ARG|POR|EUA",space(18), SA2->A2_INSCR ),nLinPC,1025)
	oReport:SkipLine()

	nLinPC := oReport:Row()
	oReport:PrintText(STR0124 + Transform(SM0->M0_CGC,PesqPict("SA2","A2_CGC")) ,nLinPC,15)
	If cPaisLoc == "BRA"
		oReport:PrintText(Space(2) + STR0041 + InscrEst() ,nLinPC,415)
	Endif
	oReport:SkipLine()
	oReport:SkipLine()

	oSection1:Finish()

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ MATR110R3³ Autor ³ Wagner Xavier         ³ Data ³ 05.09.91 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Emissao do Pedido de Compras                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ PROGRAMADOR  ³ DATA   ³ BOPS ³  MOTIVO DA ALTERACAO                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³              ³        ³      ³                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Descri‡ao ³ PLANO DE MELHORIA CONTINUA        ³Programa: MATR110R3.PRX ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ITEM PMC  ³ Responsavel              ³ Data          |BOPS             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³      01  ³                          ³               ³                 ³±±
±±³      02  ³ Marcos V. Ferreira       ³ 01/02/2006    ³                 ³±±
±±³      03  ³                          ³               ³                 ³±±
±±³      04  ³ Ricardo Berti            ³ 03/05/2006    ³00000097026      ³±±
±±³      05  ³                          ³               ³                 ³±±
±±³      06  ³ Marcos V. Ferreira       ³ 01/02/2006    ³                 ³±±
±±³      07  ³ Ricardo Berti            ³ 03/05/2006    ³00000097026      ³±±
±±³      08  ³ Flavio Luiz Vicco        ³ 07/04/2006    ³00000094742      ³±±
±±³      09  ³                          ³               ³                 ³±±
±±³      10  ³ Flavio Luiz Vicco        ³ 07/04/2006    ³00000094742      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function MATR110R3(cAlias,nReg,nOpcx)

	LOCAL wnrel		:= "MATR110"
	LOCAL cDesc1	:= STR0001	//"Emissao dos pedidos de compras ou autorizacoes de entrega"
	LOCAL cDesc2	:= STR0002	//"cadastradados e que ainda nao foram impressos"
	LOCAL cDesc3	:= " "
	LOCAL cString	:= "SC7"
	Local lComp		:= .T.	// Ativado habilita escolher modo RETRATO / PAISAGEM
	Local cUserId   := RetCodUsr()
	Local cCont     := Nil

	PRIVATE lAuto		:= (nReg!=Nil)
	PRIVATE Tamanho		:= "G"
	PRIVATE titulo	 	:=STR0003										//"Emissao dos Pedidos de Compras ou Autorizacoes de Entrega"
	PRIVATE aReturn 	:= {STR0004, 1,STR0005, 1, 2, 1, "",0 }		//"Zebrado"###"Administracao"
	PRIVATE nomeprog	:="MATR110"
	PRIVATE nLastKey	:= 0
	PRIVATE nBegin		:= 0
	PRIVATE nDifColCC   := 0
	PRIVATE aLinha		:= {}
	PRIVATE aSenhas		:= {}
	PRIVATE aUsuarios	:= {}
	PRIVATE M_PAG		:= 1
	If Type("lPedido") != "L"
		lPedido := .F.
	Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros                         ³
//³ mv_par01               Do Pedido                             ³
//³ mv_par02               Ate o Pedido                          ³
//³ mv_par03               A partir da data de emissao           ³
//³ mv_par04               Ate a data de emissao                 ³
//³ mv_par05               Somente os Novos                      ³
//³ mv_par06               Campo Descricao do Produto    	     ³
//³ mv_par07               Unidade de Medida:Primaria ou Secund. ³
//³ mv_par08               Imprime ? Pedido Compra ou Aut. Entreg³
//³ mv_par09               Numero de vias                        ³
//³ mv_par10               Pedidos ? Liberados Bloqueados Ambos  ³
//³ mv_par11               Impr. SC's Firmes, Previstas ou Ambas ³
//³ mv_par12               Qual a Moeda ?                        ³
//³ mv_par13               Endereco de Entrega                   ³
//³ mv_par14               todas ou em aberto ou atendidos       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	AjustaSX1()
	Pergunte("MTR110",.F.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se no SX3 o C7_CC esta com tamanho 9 (Default) se igual a 9 muda o tamanho do relatorio           ³
//³ para Medio possibilitando a impressao em modo Paisagem ou retrato atraves da reducao na variavel nDifColCC ³
//³ se o tamanho do C7_CC no SX3 estiver > que 9 o relatorio sera impresso comprrimido com espaco para o campo ³
//³ C7_CC centro de custo para ate 20 posicoes,Obs.desabilitando a selecao do modo de impresso retrato/paisagem³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectArea("SX3")
	DbSetOrder(2)
	If DbSeek("C7_CC")
		If SX3->X3_TAMANHO == 9
			nDifColCC := 11
			Tamanho   := "M"
		Else
			lComp	  := .F.   // C.Custo c/ tamanho maior que 9, sempre PAISAGEM
		Endif
	Endif

	wnrel:=SetPrint(cString,wnrel,If(lAuto,Nil,"MTR110"),@Titulo,cDesc1,cDesc2,cDesc3,.F.,,lComp,Tamanho,,!lAuto)

	If nLastKey <> 27

		SetDefault(aReturn,cString)

		If lAuto
			mv_par08 := Eval({|| cCont:=ChkPergUs(cUserId,"MTR110","08"),If(cCont == Nil,SC7->C7_TIPO,cCont) })
		EndIf

		If lPedido
			mv_par12 := MAX(SC7->C7_MOEDA,1)
		Endif

		If mv_par08 == 1 .OR. mv_par08 == 3
			RptStatus({|lEnd| C110PC(@lEnd,wnRel,cString,nReg)},titulo)
		Else
			RptStatus({|lEnd| C110AE(@lEnd,wnRel,cString,nReg)},titulo)
		EndIf

		lPedido := .F.
	
	Else
		dbClearFilter()
	EndIf

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ C110PC   ³ Autor ³ Cristina M. Ogura     ³ Data ³ 09.11.95 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Chamada do Relatorio                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATR110			                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function C110PC(lEnd,WnRel,cString,nReg)
	Local nReem
	Local nOrder
	Local cCondBus
	Local nSavRec
	Local aPedido := {}
	Local aPedMail:= {}
	Local aSavRec := {}
	Local nLinObs := 0
	Local i       := 0
	Local ncw     := 0
	Local cFiltro := ""
	Local cUserId := RetCodUsr()
	Local cCont   := Nil
	Local lImpri  := .F.

	Private cCGCPict, cCepPict
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Definir as pictures                                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cCepPict:=PesqPict("SA2","A2_CEP")
	cCGCPict:=PesqPict("SA2","A2_CGC")
	If nDifColCC < 11
		limite   := 139
	Else
		limite   := 129
	Endif

	li       := 80
	nDescProd:= 0
	nTotal   := 0
	nTotMerc := 0
	NumPed   := Space(6)

	If lAuto
		DbSelectArea("SC7")
		dbGoto(nReg)
		SetRegua(1)
		mv_par01 := C7_NUM
		mv_par02 := C7_NUM
		mv_par03 := C7_EMISSAO
		mv_par04 := C7_EMISSAO
		mv_par05 := Eval({|| cCont:=ChkPergUs(cUserId,"MTR110","05"),If(cCont == Nil,2,cCont) })
		mv_par08 := Eval({|| cCont:=ChkPergUs(cUserId,"MTR110","08"),If(cCont == Nil,C7_TIPO,cCont) })
		mv_par09 := Eval({|| cCont:=ChkPergUs(cUserId,"MTR110","09"),If(cCont == Nil,1,cCont) })
		mv_par10 := Eval({|| cCont:=ChkPergUs(cUserId,"MTR110","10"),If(cCont == Nil,3,cCont) })
		mv_par11 := Eval({|| cCont:=ChkPergUs(cUserId,"MTR110","11"),If(cCont == Nil,3,cCont) })
		mv_par14 := Eval({|| cCont:=ChkPergUs(cUserId,"MTR110","14"),If(cCont == Nil,1,cCont) })
	EndIf

	If ( cPaisLoc$"ARG|POR|EUA" )
		cCondBus	:=	"1"+strzero(val(mv_par01),6)
		nOrder	:=	10
		nTipo		:= 1
	Else
		cCondBus	:=mv_par01
		nOrder	:=	1
	EndIf

	If mv_par14 == 2
		cFiltro := "SC7->C7_QUANT-SC7->C7_QUJE <= 0 .Or. !EMPTY(SC7->C7_RESIDUO)"
	Elseif mv_par14 == 3
		cFiltro := "SC7->C7_QUANT > SC7->C7_QUJE"
	EndIf

	DbSelectArea("SC7")
	DbSetOrder(nOrder)
	SetRegua(RecCount())
	DbSeek(xFilial("SC7")+cCondBus,.T.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Faz manualmente porque nao chama a funcao Cabec()                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	@ 0,0 PSay AvalImp(Iif(nDifColCC < 11,220,132))

	While !Eof() .And. C7_FILIAL = xFilial("SC7") .And. C7_NUM >= mv_par01 .And. ;
			C7_NUM <= mv_par02

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Cria as variaveis para armazenar os valores do pedido        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nOrdem   := 1
		nReem    := 0
		cObs01   := " "
		cObs02   := " "
		cObs03   := " "
		cObs04   := " "

		If	C7_EMITIDO == "S" .And. mv_par05 == 1
			dbSkip()
			Loop
		Endif
		If	(C7_CONAPRO == "B" .And. mv_par10 == 1) .Or.;
				(C7_CONAPRO != "B" .And. mv_par10 == 2)
			dbSkip()
			Loop
		Endif
		If	(C7_EMISSAO < mv_par03) .Or. (C7_EMISSAO > mv_par04)
			dbSkip()
			Loop
		Endif
		If	C7_TIPO == 2
			dbSkip()
			Loop
		EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Consiste este item. EM ABERTO                                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If mv_par14 == 2
			If SC7->C7_QUANT-SC7->C7_QUJE <= 0 .Or. !EMPTY(SC7->C7_RESIDUO)
				DbSelectArea("SC7")
				dbSkip()
				Loop
			Endif
		Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Consiste este item. ATENDIDOS                                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If mv_par14 == 3
			If SC7->C7_QUANT > SC7->C7_QUJE
				DbSelectArea("SC7")
				dbSkip()
				Loop
			Endif
		Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Filtra Tipo de SCs Firmes ou Previstas                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !MtrAValOP(mv_par11, 'SC7')
			dbSkip()
			Loop
		EndIf

		MaFisEnd()
		R110FIniPC(SC7->C7_NUM,,,cFiltro)

		For ncw := 1 To mv_par09		// Imprime o numero de vias informadas

			ImpCabec(ncw)

			nTotal   := 0
			nTotMerc	:= 0
			nDescProd:= 0
			nReem    := SC7->C7_QTDREEM + 1
			nSavRec  := SC7->(Recno())
			NumPed   := SC7->C7_NUM
			nLinObs  := 0
			aPedido  := {SC7->C7_FILIAL,SC7->C7_NUM,SC7->C7_EMISSAO,SC7->C7_FORNECE,SC7->C7_LOJA,SC7->C7_TIPO}

			While !Eof() .And. C7_FILIAL = xFilial("SC7") .And. C7_NUM == NumPed

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Consiste este item. EM ABERTO                                ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If mv_par14 == 2
					If SC7->C7_QUANT-SC7->C7_QUJE <= 0 .Or. !EMPTY(SC7->C7_RESIDUO)
						DbSelectArea("SC7")
						dbSkip()
						Loop
					Endif
				Endif

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Consiste este item. ATENDIDOS                                ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If mv_par14 == 3
					If SC7->C7_QUANT > SC7->C7_QUJE
						DbSelectArea("SC7")
						dbSkip()
						Loop
					Endif
				Endif

				If Ascan(aSavRec,Recno()) == 0		// Guardo recno p/gravacao
					AADD(aSavRec,Recno())
				Endif
				If lEnd
					@PROW()+1,001 PSAY STR0006	//"CANCELADO PELO OPERADOR"
					Goto Bottom
					Exit
				Endif

				IncRegua()

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica se havera salto de formulario                       ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If li > 56
					nOrdem++
					ImpRodape()			// Imprime rodape do formulario e salta para a proxima folha
					ImpCabec(ncw)
				Endif

				li++

				@ li,001 PSAY "|"
				@ li,002 PSAY C7_ITEM  		Picture PesqPict("SC7","c7_item")
				@ li,006 PSAY "|"
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Pesquisa Descricao do Produto                                ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				ImpProd()

				If SC7->C7_DESC1 != 0 .or. SC7->C7_DESC2 != 0 .or. SC7->C7_DESC3 != 0
					nDescProd+= CalcDesc(SC7->C7_TOTAL,SC7->C7_DESC1,SC7->C7_DESC2,SC7->C7_DESC3)
				Else
					nDescProd+=SC7->C7_VLDESC
				Endif
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Inicializacao da Observacao do Pedido.                       ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If !EMPTY(SC7->C7_OBS) .And. nLinObs < 5
					nLinObs++
					cVar:="cObs"+StrZero(nLinObs,2)
					Eval(MemVarBlock(cVar),SC7->C7_OBS)
				Endif
				lImpri  := .T.
				dbSkip()
			EndDo

			dbGoto(nSavRec)

			If li>38
				nOrdem++
				ImpRodape()		// Imprime rodape do formulario e salta para a proxima folha
				ImpCabec(ncw)
			Endif

			FinalPed(nDescProd)		// Imprime os dados complementares do PC

		Next

		MaFisEnd()

		If Len(aSavRec)>0
			For i:=1 to Len(aSavRec)
				dbGoto(aSavRec[i])
				RecLock("SC7",.F.)  //Atualizacao do flag de Impressao
				Replace C7_QTDREEM With (C7_QTDREEM+1)
				Replace C7_EMITIDO With "S"
				MsUnLock()
			Next
			dbGoto(aSavRec[Len(aSavRec)])		// Posiciona no ultimo elemento e limpa array
		Endif

		Aadd(aPedMail,aPedido)

		aSavRec := {}

		dbSkip()
	EndDo

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Executa o ponto de entrada M110MAIL quando a impressao for   ³
//³ enviada por email, fornecendo um Array para o usuario conten ³
//³ do os pedidos enviados para possivel manipulacao.            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ExistBlock("M110MAIL")
		lEnvMail := HasEmail(,,,,.F.)
		If lEnvMail
			Execblock("M110MAIL",.F.,.F.,{aPedMail})
		EndIf
	EndIf

	If lAuto .And. !lImpri
		Aviso(STR0104,STR0105,{"OK"})
	Endif

	DbSelectArea("SC7")
	dbClearFilter()
	DbSetOrder(1)

	DbSelectArea("SX3")
	DbSetOrder(1)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se em disco, desvia para Spool                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If aReturn[5] == 1    // Se Saida para disco, ativa SPOOL
		Set Printer TO
		dbCommitAll()
		ourspool(wnrel)
	Endif

	MS_FLUSH()

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ C110AE   ³ Autor ³ Cristina M. Ogura     ³ Data ³ 09.11.95 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Chamada do Relatorio                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATR110			                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function C110AE(lEnd,WnRel,cString,nReg)
	Local nReem
	Local nSavRec,aSavRec := {}
	Local aPedido := {}
	Local aPedMail:= {}
	Local nLinObs := 0
	Local ncw     := 0
	Local i       := 0
	Local cFiltro := ""
	Local cUserId := RetCodUsr()
	Local lImpri  := .F.

	Private cCGCPict, cCepPict
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Definir as pictures                                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cCepPict:=PesqPict("SA2","A2_CEP")
	cCGCPict:=PesqPict("SA2","A2_CGC")

	If nDifColCC < 11
		limite   := 139
	Else
		limite   := 129
	Endif

	li       := 80
	nDescProd:= 0
	nTotal   := 0
	nTotMerc := 0
	NumPed   := Space(6)

	If !lAuto
		DbSelectArea("SC7")
		DbSetOrder(10)
		DbSeek(xFilial("SC7")+"2"+mv_par01,.T.)
	Else
		DbSelectArea("SC7")
		dbGoto(nReg)
		mv_par01 := C7_NUM
		mv_par02 := C7_NUM
		mv_par03 := C7_EMISSAO
		mv_par04 := C7_EMISSAO
		mv_par05 := Eval({|| cCont:=ChkPergUs(cUserId,"MTR110","05"),If(cCont == Nil,2,cCont) })
		mv_par08 := Eval({|| cCont:=ChkPergUs(cUserId,"MTR110","08"),If(cCont == Nil,C7_TIPO,cCont) })
		mv_par09 := Eval({|| cCont:=ChkPergUs(cUserId,"MTR110","09"),If(cCont == Nil,1,cCont) })
		mv_par10 := Eval({|| cCont:=ChkPergUs(cUserId,"MTR110","10"),If(cCont == Nil,3,cCont) })
		mv_par11 := Eval({|| cCont:=ChkPergUs(cUserId,"MTR110","11"),If(cCont == Nil,3,cCont) })
		mv_par14 := Eval({|| cCont:=ChkPergUs(cUserId,"MTR110","14"),If(cCont == Nil,1,cCont) })

		DbSelectArea("SC7")
		DbSetOrder(10)
		DbSeek(xFilial("SC7")+"2"+mv_par01,.T.)
	EndIf

	If mv_par14 == 2
		cFiltro := "SC7->C7_QUANT-SC7->C7_QUJE <= 0 .Or. !EMPTY(SC7->C7_RESIDUO)"
	Elseif mv_par14 == 3
		cFiltro := "SC7->C7_QUANT > SC7->C7_QUJE"
	EndIf

	SetRegua(Reccount())
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Faz manualmente porque nao chama a funcao Cabec()                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	@ 0,0 PSay AvalImp(Iif(nDifColCC < 11,220,132))
	While !Eof().And.C7_FILIAL = xFilial("SC7") .And. C7_NUM >= mv_par01 .And. C7_NUM <= mv_par02
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Cria as variaveis para armazenar os valores do pedido        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nOrdem   := 1
		nReem    := 0
		cObs01   := " "
		cObs02   := " "
		cObs03   := " "
		cObs04   := " "

		If	C7_EMITIDO == "S" .And. mv_par05 == 1
			DbSelectArea("SC7")
			dbSkip()
			Loop
		Endif
		If	(C7_CONAPRO == "B" .And. mv_par10 == 1) .Or.;
				(C7_CONAPRO != "B" .And. mv_par10 == 2)
			DbSelectArea("SC7")
			dbSkip()
			Loop
		Endif
		If	(SC7->C7_EMISSAO < mv_par03) .Or. (SC7->C7_EMISSAO > mv_par04)
			DbSelectArea("SC7")
			dbSkip()
			Loop
		Endif
		If	SC7->C7_TIPO != 2
			DbSelectArea("SC7")
			dbSkip()
			Loop
		EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Consiste este item. EM ABERTO                                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If mv_par14 == 2
			If SC7->C7_QUANT-SC7->C7_QUJE <= 0 .Or. !EMPTY(SC7->C7_RESIDUO)
				DbSelectArea("SC7")
				dbSkip()
				Loop
			Endif
		Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Consiste este item. ATENDIDOS                                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If mv_par14 == 3
			If SC7->C7_QUANT > SC7->C7_QUJE
				DbSelectArea("SC7")
				dbSkip()
				Loop
			Endif
		Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Filtra Tipo de SCs Firmes ou Previstas                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !MtrAValOP(mv_par11, 'SC7')
			DbSelectArea("SC7")
			dbSkip()
			Loop
		EndIf

		MaFisEnd()
		R110FIniPC(SC7->C7_NUM,,,cFiltro)

		For ncw := 1 To mv_par09		// Imprime o numero de vias informadas

			ImpCabec(ncw)

			nTotal   := 0
			nTotMerc := 0

			nDescProd:= 0
			nReem    := SC7->C7_QTDREEM + 1
			nSavRec  := SC7->(Recno())
			NumPed   := SC7->C7_NUM
			nLinObs := 0
			aPedido  := {SC7->C7_FILIAL,SC7->C7_NUM,SC7->C7_EMISSAO,SC7->C7_FORNECE,SC7->C7_LOJA,SC7->C7_TIPO}

			While !Eof() .And. C7_FILIAL = xFilial("SC7") .And. C7_NUM == NumPed

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Consiste este item. EM ABERTO                                ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If mv_par14 == 2
					If SC7->C7_QUANT-SC7->C7_QUJE <= 0 .Or. !EMPTY(SC7->C7_RESIDUO)
						DbSelectArea("SC7")
						dbSkip()
						Loop
					Endif
				Endif

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Consiste este item. ATENDIDOS                                ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If mv_par14 == 3
					If SC7->C7_QUANT > SC7->C7_QUJE
						DbSelectArea("SC7")
						dbSkip()
						Loop
					Endif
				Endif

				If Ascan(aSavRec,Recno()) == 0		// Guardo recno p/gravacao
					AADD(aSavRec,Recno())
				Endif

				If lEnd
					@PROW()+1,001 PSAY STR0006		//"CANCELADO PELO OPERADOR"
					Goto Bottom
					Exit
				Endif

				IncRegua()

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica se havera salto de formulario                       ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If li > 56
					nOrdem++
					ImpRodape()		// Imprime rodape do formulario e salta para a proxima folha
					ImpCabec(ncw)
				Endif
				li++
				@ li,001 PSAY "|"
				@ li,002 PSAY SC7->C7_ITEM  	Picture PesqPict("SC7","C7_ITEM")
				@ li,006 PSAY "|"
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Pesquisa Descricao do Produto                                ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				ImpProd()		// Imprime dados do Produto

				If SC7->C7_DESC1 != 0 .or. SC7->C7_DESC2 != 0 .or. SC7->C7_DESC3 != 0
					nDescProd+= CalcDesc(SC7->C7_TOTAL,SC7->C7_DESC1,SC7->C7_DESC2,SC7->C7_DESC3)
				Else
					nDescProd+=SC7->C7_VLDESC
				Endif
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Inicializacao da Observacao do Pedido.                       ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If !EMPTY(SC7->C7_OBS) .And. nLinObs < 5
					nLinObs++
					cVar:="cObs"+StrZero(nLinObs,2)
					Eval(MemVarBlock(cVar),SC7->C7_OBS)
				Endif
				lImpri  := .T.
				DbSelectArea("SC7")
				dbSkip()
			EndDo

			dbGoto(nSavRec)
			If li>38
				nOrdem++
				ImpRodape()		// Imprime rodape do formulario e salta para a proxima folha
				ImpCabec(ncw)
			Endif

			FinalAE(nDescProd)		// dados complementares da Autorizacao de Entrega
		Next

		MaFisEnd()

		If Len(aSavRec)>0
			dbGoto(aSavRec[Len(aSavRec)])
			For i:=1 to Len(aSavRec)
				dbGoto(aSavRec[i])
				RecLock("SC7",.F.)  //Atualizacao do flag de Impressao
				Replace C7_EMITIDO With "S"
				Replace C7_QTDREEM With (C7_QTDREEM+1)
				MsUnLock()
			Next
		Endif

		Aadd(aPedMail,aPedido)

		aSavRec := {}

		DbSelectArea("SC7")
		dbSkip()
	End

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Executa o ponto de entrada M110MAIL quando a impressao for   ³
//³ enviada por email, fornecendo um Array para o usuario conten ³
//³ do os pedidos enviados para possivel manipulacao.            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ExistBlock("M110MAIL")
		lEnvMail := HasEmail(,,,,.F.)
		If lEnvMail
			Execblock("M110MAIL",.F.,.F.,{aPedMail})
		EndIf
	EndIf

	If lAuto .And. !lImpri
		Aviso(STR0104,STR0105,{"OK"})
	Endif

	DbSelectArea("SC7")
	dbClearFilter()
	DbSetOrder(1)

	DbSelectArea("SX3")
	DbSetOrder(1)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se em disco, desvia para Spool                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If aReturn[5] == 1    // Se Saida para disco, ativa SPOOL
		Set Printer TO
		Commit
		ourspool(wnrel)
	Endif

	MS_FLUSH()

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ ImpProd  ³ Autor ³ Wagner Xavier         ³ Data ³          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Pesquisar e imprimir  dados Cadastrais do Produto.         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ImpProd(Void)                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MatR110                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ImpProd()
	LOCAL nBegin   := 0, cDescri := "", nLinha:=0
	Local nTamDesc := 26
	Local aColuna  := Array(8)
	Local nTamProd := 15

	If Empty(mv_par06)
		mv_par06 := "B1_DESC"
	EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Impressao da descricao generica do Produto.                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If AllTrim(mv_par06) == "B1_DESC"
		DbSelectArea("SB1")
		DbSetOrder(1)
		DbSeek( xFilial("SB1")+SC7->C7_PRODUTO )
		cDescri := Alltrim(SB1->B1_DESC)
		DbSelectArea("SC7")
	EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Impressao da descricao cientifica do Produto.                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If AllTrim(mv_par06) == "B5_CEME"
		DbSelectArea("SB5")
		DbSetOrder(1)
		If DbSeek( xFilial("SB5")+SC7->C7_PRODUTO )
			cDescri := Alltrim(B5_CEME)
		EndIf
		DbSelectArea("SC7")
	EndIf

	DbSelectArea("SC7")
	If AllTrim(mv_par06) == "C7_DESCRI"
		cDescri := Alltrim(SC7->C7_DESCRI)
	EndIf

	If Empty(cDescri)
		DbSelectArea("SB1")
		DbSetOrder(1)
		MsSeek( xFilial("SB1")+SC7->C7_PRODUTO )
		cDescri := Alltrim(SB1->B1_DESC)
		DbSelectArea("SC7")
	EndIf

	DbSelectArea("SA5")
	DbSetOrder(1)
	If DbSeek(xFilial("SA5")+SC7->C7_FORNECE+SC7->C7_LOJA+SC7->C7_PRODUTO).And. !Empty(SA5->A5_CODPRF)
		cDescri := cDescri + " ("+Alltrim(A5_CODPRF)+")"
	EndIf
	DbSelectArea("SC7")
	aColuna[1] :=  49
	aColuna[2] :=  52
	aColuna[3] :=  65
	aColuna[4] :=  80
	aColuna[5] :=  86
	aColuna[6] := 103
	aColuna[7] := 114
	acoluna[8] := 142 - nDifColCC

	If Len(cDescri) > Len(SC7->C7_PRODUTO)
		nLinha:= MLCount(cDescri,nTamDesc)
	Else
		nLinha:= MLCount(SC7->C7_PRODUTO,nTamProd)
	EndIf

	@ li,007 PSAY MemoLine(SC7->C7_PRODUTO,nTamProd,1)
	@ li,022 PSAY "|"
	@ li,023 PSAY MemoLine(cDescri,nTamDesc,1)

	ImpCampos()
	For nBegin := 2 To nLinha
		li++
		@ li,001 PSAY "|"
		@ li,006 PSAY "|"
		@ li,007 PSAY MemoLine(SC7->C7_PRODUTO,nTamProd,nBegin)
		@ li,022 PSAY "|"
		@ li,023 PSAY Memoline(cDescri,nTamDesc,nBegin)
		@ li,aColuna[1] PSAY "|"
		@ li,acoluna[2] PSAY "|"
		@ li,acoluna[3] PSAY "|"
		@ li,aColuna[4] PSAY "|"

		If mv_par08 == 1 .OR. mv_par08 == 3
			If cPaisLoc == "BRA"
				@ li,aColuna[5] PSAY "|"
			Else
				@ li,aColuna[5] PSAY " "
			EndIf
			@ li,aColuna[6] PSAY "|"
			@ li,114 PSAY "|"
			@ li,135 - nDIfColCC PSAY "|"
			@ li,aColuna[8] PSAY "|"
		Else
			@ li,097 PSAY "|"
			@ li,108 PSAY "|"
			@ li,142 - nDifColCC PSAY "|"
		EndIf
	Next nBegin

Return NIL
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ ImpCampos³ Autor ³ Wagner Xavier         ³ Data ³          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Imprimir dados Complementares do Produto no Pedido.        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ImpCampos(Void)                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MatR110                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ImpCampos()

	LOCAL aColuna[6]
	Local nTxMoeda := IIF(SC7->C7_TXMOEDA > 0,SC7->C7_TXMOEDA,Nil)
	DbSelectArea("SC7")

	aColuna[1] :=  49
	aColuna[2] :=  52
	aColuna[3] :=  65
	aColuna[4] :=  80
	aColuna[5] :=  86
	aColuna[6] := 103

	@ li,aColuna[1] PSAY "|"
	If MV_PAR07 == 2 .And. !Empty(SC7->C7_SEGUM)
		@ li,PCOL() PSAY SC7->C7_SEGUM Picture PesqPict("SC7","C7_UM")
	Else
		@ li,PCOL() PSAY SC7->C7_UM    Picture PesqPict("SC7","C7_UM")
	EndIf
	@ li,aColuna[2] PSAY "|"
	If MV_PAR07 == 2 .And. !Empty(SC7->C7_QTSEGUM)
		@ li,PCOL() PSAY SC7->C7_QTSEGUM Picture PesqPict("SC7","C7_QUANT")
	Else
		@ li,PCOL() PSAY SC7->C7_QUANT  Picture PesqPict("SC7","C7_QUANT")
	EndIf
	@ li,aColuna[3] PSAY "|"
	If MV_PAR07 == 2 .And. !Empty(SC7->C7_QTSEGUM)
		@ li,PCOL()	PSAY xMoeda((SC7->C7_TOTAL/SC7->C7_QTSEGUM),SC7->C7_MOEDA,MV_PAR12,SC7->C7_DATPRF,MsDecimais(SC7->C7_MOEDA),nTxMoeda) Picture PesqPict("SC7","C7_PRECO",14)
	Else
		@ li,PCOL() PSAY xMoeda(SC7->C7_PRECO,SC7->C7_MOEDA,MV_PAR12,SC7->C7_DATPRF,MsDecimais(SC7->C7_MOEDA),nTxMoeda) Picture PesqPict("SC7","C7_PRECO",14)
	EndIf
	@ li,aColuna[4] PSAY "|"

	If mv_par08 == 1 .OR. mv_par08 == 3
		If cPaisLoc == "BRA"
			@ li,    PCOL() PSAY SC7->C7_IPI Picture PesqPictQt("C7_IPI",5)
			@ li,    aColuna[5] PSAY "|"
		Else
			@ li,    PCOL() 	PSAY "  "
			@ li,aColuna[5]-2 	PSAY " "
			@ li,    PCOL() 	PSAY " "
		EndIf
		@ li,    PCOL() PSAY xMoeda(SC7->C7_TOTAL,SC7->C7_MOEDA,MV_PAR12,SC7->C7_DATPRF,MsDecimais(SC7->C7_MOEDA),nTxMoeda) Picture PesqPict("SC7","C7_TOTAL",16,MV_PAR12)
		@ li,aColuna[6] PSAY "|"
		@ li,    PCOL() PSAY SC7->C7_DATPRF Picture PesqPict("SC7","C7_DATPRF")
		@ li,114 PSAY "|"
		@ li,PCOL() PSAY SC7->C7_CC         Picture PesqPict("SC7","C7_CC",20)
		@ li,135 - nDifColCC PSAY "|"
		@ li,  PCOL() PSAY SC7->C7_NUMSC
		@ li,142 - nDifColCC PSAY "|"
	Else
		@ li,  PCOL() PSAY xMoeda(SC7->C7_TOTAL,SC7->C7_MOEDA,MV_PAR12,SC7->C7_DATPRF,MsDecimais(SC7->C7_MOEDA),nTxMoeda) Picture PesqPict("SC7","C7_TOTAL",16,MV_PAR12)
		@ li,     097 PSAY "|"
		@ li,  PCOL() PSAY SC7->C7_DATPRF   Picture PesqPict("SC7","C7_DATPRF")
		@ li,     108 PSAY "|"
	// Tenta imprimir OP
		If !Empty(SC7->C7_OP)
			@ li,  PCOL() PSAY STR0065
			@ li,  PCOL() PSAY SC7->C7_OP
	// Caso Op esteja vazia imprime Centro de Custos
		ElseIf !Empty(SC7->C7_CC)
			@ li,  PCOL() PSAY STR0066
			@ li,PCOL() PSAY SC7->C7_CC     Picture PesqPict("SC7","C7_CC",20)
		EndIf
		@ li,142 - nDifColCC PSAY "|"
	EndIf

	nTotal  :=nTotal+SC7->C7_TOTAL
	nTotMerc:=MaFisRet(,"NF_TOTAL")
Return .T.
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ FinalPed ³ Autor ³ Wagner Xavier         ³ Data ³          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Imprime os dados complementares do Pedido de Compra        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ FinalPed(Void)                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MatR110                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function FinalPed(nDescProd)

	Local nk		:= 1,nG
	Local nX		:= 0
	Local nQuebra	:= 0
	Local nTotDesc	:= nDescProd
	Local lNewAlc	:= .F.
	Local lLiber 	:= .F.
	Local lImpLeg	:= .T.
	Local lImpLeg2	:= .F.
	Local cComprador:=""
	LOcal cAlter	:=""
	Local cAprov	:=""
	Local nTotIpi	:= MaFisRet(,'NF_VALIPI')
	Local nTotIcms	:= MaFisRet(,'NF_VALICM')
	Local nTotDesp	:= MaFisRet(,'NF_DESPESA')
	Local nTotFrete	:= MaFisRet(,'NF_FRETE')
	Local nTotalNF	:= MaFisRet(,'NF_TOTAL')
	Local nTotSeguro:= MaFisRet(,'NF_SEGURO')
	Local aValIVA   := MaFisRet(,"NF_VALIMP")
	Local nValIVA   :=0
	Local aColuna   := Array(8), nTotLinhas
	Local nTxMoeda  := IIF(SC7->C7_TXMOEDA > 0,SC7->C7_TXMOEDA,Nil)

	If cPaisLoc <> "BRA" .And. !Empty(aValIVA)
		For nG:=1 to Len(aValIVA)
			nValIVA+=aValIVA[nG]
		Next
	Endif

	cMensagem:= Formula(C7_MSG)

	If !Empty(cMensagem)
		li++
		@ li,001 PSAY "|"
		@ li,002 PSAY Padc(cMensagem,129)
		@ li,142 - nDifColCC PSAY "|"
	Endif
	li++
	@ li,001 PSAY "|"
	@ li,002 PSAY Replicate("-",limite)
	@ li,142 - nDifColCC PSAY "|"
	li++

	aColuna[1] :=  49
	aColuna[2] :=  52
	aColuna[3] :=  65
	aColuna[4] :=  80
	aColuna[5] :=  86
	aColuna[6] := 103
	acoluna[7] := 114
	aColuna[8] := 142 - nDifColCC
	nTotLinhas :=  39

	While li<nTotLinhas
		@ li,001 PSAY "|"
		@ li,006 PSAY "|"
		@ li,022 PSAY "|"
		@ li,022 + nk PSAY "*"
		nk := IIf( nk == 42 , 1 , nk + 1 )
		@ li,aColuna[1] PSAY "|"
		@ li,aColuna[2] PSAY "|"
		@ li,aColuna[3] PSAY "|"
		@ li,aColuna[4] PSAY "|"
		If cPaisLoc == "BRA"
			@ li,aColuna[5] PSAY "|"
		EndIf
		@ li,aColuna[6] PSAY "|"
		@ li,114 PSAY "|"
		@ li,135 - nDifColCC PSAY "|"
		@ li,aColuna[8] PSAY "|"
		li++
	EndDo
	@ li,001 PSAY "|"
	@ li,002 PSAY Replicate("-",limite)
	@ li,142 - nDifColCC PSAY "|"
	li++
	@ li,001 PSAY "|"
	@ li,015 PSAY STR0007		//"D E S C O N T O S -->"
	@ li,037 PSAY C7_DESC1 Picture "999.99"
	@ li,046 PSAY C7_DESC2 Picture "999.99"
	@ li,055 PSAY C7_DESC3 Picture "999.99"

	@ li,068 PSAY xMoeda(nTotDesc,SC7->C7_MOEDA,MV_PAR12,SC7->C7_DATPRF,MsDecimais(SC7->C7_MOEDA),nTxMoeda) Picture PesqPict("SC7","C7_VLDESC",14, MV_PAR12)

	@ li,142 - nDifColCC PSAY "|"
	li++
	@ li,001 PSAY "|"
	@ li,002 PSAY Replicate("-",limite)
	@ li,142 - nDifColCC PSAY "|"
	li++
	@ li,001 PSAY "|"
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Posiciona o Arquivo de Empresa SM0.                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cAlias := Alias()
	DbSelectArea("SM0")
	DbSetOrder(1)   // forca o indice na ordem certa
	nRegistro := Recno()
	DbSeek(SUBS(cNumEmp,1,2)+SC7->C7_FILENT)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Imprime endereco de entrega do SM0 somente se o MV_PAR13 =" "³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Empty(MV_PAR13)
	//"Local de Entrega  : " -- //"CEP :"
		@ li,003 PSAY STR0008 + AllTrim(SM0->M0_ENDENT) + " - " + AllTrim(SM0->M0_CIDENT) + " - " + Alltrim(SM0->M0_ESTENT) + " - " + STR0009 + Trans(Alltrim(SM0->M0_CEPENT),cCepPict)
	Else
		@ li,003 PSAY STR0008 + MV_PAR13		//"Local de Entrega  : " imprime o endereco digitado na pergunte
	Endif

	@ li,142 - nDifColCC PSAY "|"
	dbGoto(nRegistro)
	DbSelectArea( cAlias )

	li++
	@ li,001 PSAY "|"
//"Local de Cobranca : "
	@ li,003 PSAY STR0010 + Alltrim(SM0->M0_ENDCOB) + " - " + Alltrim(SM0->M0_CIDCOB) + " - " + Alltrim(SM0->M0_ESTCOB) + " - " +	STR0009 + Trans(Alltrim(SM0->M0_CEPCOB),cCepPict)
	@ li,142 - nDifColCC PSAY " |"
	li++
	@ li,001 PSAY "|"
	@ li,002 PSAY Replicate("-",limite)
	@ li,142 - nDifColCC PSAY " |"

	DbSelectArea("SE4")
	DbSetOrder(1)
	DbSeek(xFilial("SE4")+SC7->C7_COND)
	DbSelectArea("SC7")
	li++
	@ li,001 PSAY "|"
	@ li,003 PSAY STR0011+SubStr(SE4->E4_COND,1,40)		//"Condicao de Pagto "
	@ li,061 PSAY STR0012		//"|Data de Emissao|"
	@ li,079 PSAY STR0013		//"Total das Mercadorias : "
	@ li,108 PSAY xMoeda(nTotal,SC7->C7_MOEDA,MV_PAR12,SC7->C7_DATPRF,MsDecimais(SC7->C7_MOEDA),nTxMoeda) Picture tm(nTotal,14,MsDecimais(MV_PAR12))
	@ li,142 - nDifColCC PSAY "|"
	li++
	@ li,001 PSAY "|"
	@ li,003 PSAY SubStr(SE4->E4_DESCRI,1,34)
	@ li,061 PSAY "|"
	@ li,066 PSAY SC7->C7_EMISSAO
	@ li,077 PSAY "|"
	If cPaisLoc<>"BRA"
		@ li,079 PSAY OemtoAnsi(STR0063)	//"Total de los Impuestos : "
		@ li,108 PSAY xMoeda(nValIVA,SC7->C7_MOEDA,MV_PAR12,SC7->C7_DATPRF,MsDecimais(SC7->C7_MOEDA),nTxMoeda) Picture tm(nValIVA,14,MsDecimais(MV_PAR12))
	Else
		@ li,079 PSAY STR0064		//"Total com Impostos : "
		@ li,108 PSAY xMoeda(nTotMerc,SC7->C7_MOEDA,MV_PAR12,SC7->C7_DATPRF,MsDecimais(SC7->C7_MOEDA),nTxMoeda) Picture tm(nTotMerc,14,MsDecimais(MV_PAR12))
	Endif
	@ li,142 - nDifColCC PSAY "|"
	li++
	@ li,001 PSAY "|"
	@ li,002 PSAY Replicate("-",53)
	@ li,055 PSAY Replicate("-",86 - nDifColCC)
	@ li,142 - nDifColCC PSAY "|"
	li++
	DbSelectArea("SM4")
	DbSetOrder(1)
	DbSeek(xFilial("SM4")+SC7->C7_REAJUST)
	DbSelectArea("SC7")

	@ li,001 PSAY "|"
	@ li,003 PSAY STR0014		//"Reajuste :"
	@ li,014 PSAY SC7->C7_REAJUST Picture PesqPict("SC7","c7_reajust",,MV_PAR12)
	@ li,018 PSAY SM4->M4_DESCR

	If cPaisLoc == "BRA"
		@ li,054 PSAY STR0015		//"| IPI   :"
		@ li,064 PSAY xMoeda(nTotIPI,SC7->C7_MOEDA,MV_PAR12,SC7->C7_DATPRF,MsDecimais(SC7->C7_MOEDA),nTxMoeda) Picture tm(nTotIpi,14,MsDecimais(MV_PAR12))
		@ li,088 PSAY "| ICMS   : "
		@ li,100 PSAY xMoeda(nTotIcms,SC7->C7_MOEDA,MV_PAR12,SC7->C7_DATPRF,MsDecimais(SC7->C7_MOEDA),nTxMoeda) Picture tm(nTotIcms,14,MsDecimais(MV_PAR12))
		@ li,142 - nDifColCC PSAY "|"
	Else
		@ li,054 PSAY "|"
		@ li,142 - nDifColCC PSAY "|"
	EndIf

	li++
	@ li,001 PSAY "|"
	@ li,002 PSAY Replicate("-",52)
	@ li,054 PSAY (STR0049) //"| Frete :"
	@ li,064 PSAY xMoeda(nTotFrete,SC7->C7_MOEDA,MV_PAR12,SC7->C7_DATPRF,MsDecimais(SC7->C7_MOEDA),nTxMoeda) Picture tm(nTotFrete,14,MsDecimais(MV_PAR12))
	@ li,088 PSAY (STR0058) //"| Despesas :"
	@ li,100 PSAY xMoeda(nTotDesp,SC7->C7_MOEDA,MV_PAR12,SC7->C7_DATPRF,MsDecimais(SC7->C7_MOEDA),nTxMoeda) Picture tm(nTotDesp,14,MsDecimais(MV_PAR12))

	@ li,142 - nDifColCC PSAY "|"
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializar campos de Observacoes.                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Empty(cObs02)
		If Len(cObs01) > 50
			cObs := cObs01
			cObs01 := Substr(cObs,1,50)
			For nX := 2 To 4
				cVar  := "cObs"+StrZero(nX,2)
				&cVar := Substr(cObs,(50*(nX-1))+1,50)
			Next
		EndIf
	Else
		cObs01:= Substr(cObs01,1,IIf(Len(cObs01)<50,Len(cObs01),50))
		cObs02:= Substr(cObs02,1,IIf(Len(cObs02)<50,Len(cObs01),50))
		cObs03:= Substr(cObs03,1,IIf(Len(cObs03)<50,Len(cObs01),50))
		cObs04:= Substr(cObs04,1,IIf(Len(cObs04)<50,Len(cObs01),50))
	EndIf

	DbSelectArea("SC7")
	If !Empty(C7_APROV)
		lNewAlc := .T.
		cComprador := UsrFullName(SC7->C7_USER)
		If C7_CONAPRO != "B"
			lLiber := .T.
		EndIf
		DbSelectArea("SCR")
		DbSetOrder(1)
		DbSeek(xFilial("SCR")+"PC"+SC7->C7_NUM)
		While !Eof() .And. SCR->CR_FILIAL+Alltrim(SCR->CR_NUM)==xFilial("SCR")+Alltrim(SC7->C7_NUM) .And. SCR->CR_TIPO == "PC"
			cAprov += AllTrim(UsrFullName(SCR->CR_USER))+" ["
			Do Case
			Case SCR->CR_STATUS=="03" //Liberado
				cAprov += "Ok"
			Case SCR->CR_STATUS=="04" //Bloqueado
				cAprov += "BLQ"
			Case SCR->CR_STATUS=="05" //Nivel Liberado
				cAprov += "##"
			OtherWise                 //Aguar.Lib
				cAprov += "??"
			EndCase
			cAprov += "] - "
			DbSelectArea("SCR")
			dbSkip()
		Enddo
		If !Empty(SC7->C7_GRUPCOM)
			DbSelectArea("SAJ")
			DbSetOrder(1)
			DbSeek(xFilial("SAJ")+SC7->C7_GRUPCOM)
			While !Eof() .And. SAJ->AJ_FILIAL+SAJ->AJ_GRCOM == xFilial("SAJ")+SC7->C7_GRUPCOM
				If SAJ->AJ_USER != SC7->C7_USER
					cAlter += AllTrim(UsrFullName(SAJ->AJ_USER))+"/"
				EndIf
				DbSelectArea("SAJ")
				dbSkip()
			EndDo
		EndIf
	EndIf

	li++
	@ li,001 PSAY STR0016		//"| Observacoes"
	@ li,054 PSAY STR0017		//"| Grupo :"
	@ li,088 PSAY STR0059      //"| SEGURO :"
	@ li,100 PSAY xMoeda(nTotSeguro,SC7->C7_MOEDA,MV_PAR12,SC7->C7_DATPRF,MsDecimais(SC7->C7_MOEDA),nTxMoeda) Picture tm(nTotSeguro,14,MsDecimais(MV_PAR12))
	@ li,142 - nDifColCC PSAY "|"
	li++
	@ li,001 PSAY "|"
	@ li,003 PSAY cObs01
	@ li,054 PSAY "|"+Replicate("-",86 - nDifColCC)
	@ li,142 - nDifColCC PSAY "|"
	li++
	@ li,001 PSAY "|"
	@ li,003 PSAY cObs02
	@ li,054 PSAY STR0018		//"| Total Geral : "

	If !lNewAlc
		@ li,094 PSAY xMoeda(nTotalNF,SC7->C7_MOEDA,MV_PAR12,SC7->C7_DATPRF,MsDecimais(SC7->C7_MOEDA),nTxMoeda) Picture tm(nTotalNF,14,MsDecimais(MV_PAR12))
	Else
		If lLiber
			@ li,094 PSAY xMoeda(nTotalNF,SC7->C7_MOEDA,MV_PAR12,SC7->C7_DATPRF,MsDecimais(SC7->C7_MOEDA),nTxMoeda) Picture tm(nTotalNF,14,MsDecimais(MV_PAR12))
		Else
			@ li,080 PSAY (STR0051)
		EndIf
	EndIf

	@ li,142 - nDifColCC PSAY "|"
	li++
	@ li,001 PSAY "|"
	@ li,003 PSAY cObs03
	@ li,054 PSAY "|"+Replicate("-",86 - nDifColCC)
	@ li,142 - nDifColCC PSAY "|"
	li++

	If !lNewAlc
		@ li,001 PSAY "|"
		@ li,003 PSAY cObs04
		@ li,054 PSAY "|"
		@ li,061 PSAY STR0019		//"|           Liberacao do Pedido"
		@ li,102 PSAY STR0020		//"| Obs. do Frete: "
		@ li,119 PSAY IF( SC7->C7_TPFRETE $ "F","FOB",IF(SC7->C7_TPFRETE $ "C","CIF"," " ))
		@ li,142 - nDifColCC PSAY "|"
		li++
		@ li,001 PSAY "|"+Replicate("-",59)
		@ li,061 PSAY "|"
		@ li,102 PSAY "|"
		@ li,142 - nDifColCC PSAY "|"

		li++
		cLiberador := ""
		nPosicao := 0
		@ li,001 PSAY "|"
		@ li,007 PSAY STR0021		//"Comprador"
		@ li,021 PSAY "|"
		@ li,028 PSAY STR0022		//"Gerencia"
		@ li,041 PSAY "|"
		@ li,046 PSAY STR0023		//"Diretoria"
		@ li,061 PSAY "|     ------------------------------"
		@ li,102 PSAY "|"
		@ li,142 - nDifColCC PSAY "|"
		li++
		@ li,001 PSAY "|"
		@ li,021 PSAY "|"
		@ li,041 PSAY "|"
		@ li,061 PSAY "|     " + R110Center(cLiberador) // 30 posicoes
		@ li,102 PSAY "|"
		@ li,142 - nDifColCC PSAY "|"
		li++
		@ li,001 PSAY "|"
		@ li,002 PSAY Replicate("-",limite)
		@ li,142 - nDifColCC PSAY "|"
		li++
		@ li,001 PSAY STR0024		//"|   NOTA: So aceitaremos a mercadoria se na sua Nota Fiscal constar o numero do nosso Pedido de Compras."
		@ li,142 - nDifColCC PSAY "|"
		li++
		@ li,001 PSAY "|"
		@ li,002 PSAY Replicate("-",limite)
		@ li,142 - nDifColCC PSAY "|"
	Else
		@ li,001 PSAY "|"
		@ li,003 PSAY cObs04
		@ li,054 PSAY "|"
		@ li,059 PSAY IF(lLiber,STR0050,STR0051)		//"     P E D I D O   L I B E R A D O"#"|     P E D I D O   B L O Q U E A D O !!!"
		@ li,102 PSAY STR0020		//"| Obs. do Frete: "
		@ li,119 PSAY Substr(RetTipoFrete(SC7->C7_TPFRETE),3,10)
		@ li,142 - nDifColCC PSAY "|"
		li++
		@ li,001 PSAY "|"+Replicate("-",99)
		@ li,102 PSAY "|"
		@ li,104 PSAY Substr(RetTipoFrete(SC7->C7_TPFRETE),13)
		@ li,142 - nDifColCC PSAY "|"
		li++
		@ li,001 PSAY "|"
		@ li,003 PSAY STR0052		//"Comprador Responsavel :"
		@ li,027 PSAY Substr(cComprador,1,60)
		@ li,088 PSAY "|"
		@ li,089 PSAY STR0060      //"BLQ:Bloqueado"
		@ li,102 PSAY "|"
		@ li,142 - nDifColCC PSAY "|"
		li++
		nAuxLin := Len(cAlter)
		@ li,001 PSAY "|"
		@ li,003 PSAY STR0053		//"Compradores Alternativos :"
		While nAuxLin > 0 .Or. lImpLeg
			@ li,029 PSAY Substr(cAlter,Len(cAlter)-nAuxLin+1,60)
			@ li,088 PSAY "|"
			If lImpLeg
				@ li,089 PSAY STR0061   //"Ok:Liberado"
				lImpLeg := .F.
			EndIf
			@ li,102 PSAY "|"
			@ li,142 - nDifColCC PSAY "|"
			nAuxLin -= 60
			li++
		EndDo
		nAuxLin := Len(cAprov)
		lImpLeg := .T.
		While nAuxLin > 0	.Or. lImpLeg
			@ li,001 PSAY "|"
			If lImpLeg  // Imprimir soh a 1a vez
				@ li,003 PSAY STR0054		//"Aprovador(es) :"
			EndIf
			@ li,018 PSAY Substr(cAprov,Len(cAprov)-nAuxLin+1,70)
			@ li,088 PSAY "|"
			If lImpLeg2  // Imprimir soh a 2a vez
				@ li,089 PSAY STR0067 //"##:Nivel.Lib"
				lImpLeg2 := .F.
			EndIf
			If lImpLeg   // Imprimir soh a 1a vez
				@ li,089 PSAY STR0062  //"??:Aguar.Lib"
				lImpLeg  := .F.
				lImpLeg2 := .T.
			EndIf
			@ li,102 PSAY "|"
			@ li,142 - nDifColCC PSAY "|"
			nAuxLin -=70
			li++
		EndDo
		If lImpLeg2
			lImpLeg2 := .F.
			@ li,001 PSAY "|"
			@ li,088 PSAY "|"
			@ li,089 PSAY STR0067 //"##:Nivel Lib"
			@ li,102 PSAY "|"
			@ li,142 - nDifColCC PSAY "|"
			li++
		EndIf
		If nAuxLin == 0
			li++
		EndIf
		@ li,001 PSAY "|"
		@ li,002 PSAY Replicate("-",limite)
		@ li,142 - nDifColCC PSAY "|"
		li++
		@ li,001 PSAY STR0024		//"|   NOTA: So aceitaremos a mercadoria se na sua Nota Fiscal constar o numero do nosso Pedido de Compras."
		@ li,142 - nDifColCC PSAY "|"
		li++
		@ li,001 PSAY "|"
		@ li,002 PSAY Replicate("-",limite)
		@ li,142 - nDifColCC PSAY "|"
	EndIf

Return .T.
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ FinalAE  ³ Autor ³ Cristina Ogura        ³ Data ³ 05.04.96 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Imprime os dados complementares da Autorizacao de Entrega  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ FinalAE(Void)                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MatR110                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function FinalAE(nDescProd)
	Local nk := 1
	Local nX := 0
	Local nTotDesc:= nDescProd
	Local nTotNF	:= MaFisRet(,'NF_TOTAL')
	Local nTxMoeda := IIF(SC7->C7_TXMOEDA > 0,SC7->C7_TXMOEDA,Nil)
	Local cComprador:=""
	LOcal cAlter	:=""
	Local cAprov	:=""
	Local lImpLeg	:= .T.
	Local lImpLeg2	:= .F.

	cMensagem:= Formula(C7_MSG)

	If !Empty(cMensagem)
		li++
		@ li,001 PSAY "|"
		@ li,002 PSAY Padc(cMensagem,129)
		@ li,142 - nDifColCC PSAY "|"
	Endif
	li++
	@ li,001 PSAY "|"
	@ li,002 PSAY Replicate("-",limite)
	@ li,142 - nDifColCC PSAY "|"
	li++
	While li<39
		@ li,001 PSAY "|"
		@ li,006 PSAY "|"
		@ li,022 PSAY "|"
		@ li,022 + nk PSAY "*"
		nk := IIf( nk == 32 , 1 , nk + 1 )
		@ li,049 PSAY "|"
		@ li,052 PSAY "|"
		@ li,065 PSAY "|"
		@ li,080 PSAY "|"
		@ li,097 PSAY "|"
		@ li,108 PSAY "|"
		@ li,142 - nDifColCC PSAY "|"
		li++
	EndDo
	@ li,001 PSAY "|"
	@ li,002 PSAY Replicate("-",limite)
	@ li,142 - nDifColCC PSAY "|"
	li++
	@ li,001 PSAY "|"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Posiciona o Arquivo de Empresa SM0.                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cAlias := Alias()
	DbSelectArea("SM0")
	DbSetOrder(1)   // forca o indice na ordem certa
	nRegistro := Recno()
	DbSeek(SUBS(cNumEmp,1,2)+SC7->C7_FILENT)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Imprime endereco de entrega do SM0 somente se o MV_PAR13 =" "³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Empty(MV_PAR13)
		@ li,003 PSAY STR0008 + SM0->M0_ENDENT		//"Local de Entrega  : "
		@ li,057 PSAY "-"
		@ li,061 PSAY SM0->M0_CIDENT
		@ li,083 PSAY "-"
		@ li,085 PSAY SM0->M0_ESTENT
		@ li,088 PSAY "-"
		@ li,090 PSAY STR0009	//"CEP :"
		@ li,096 PSAY Trans(Alltrim(SM0->M0_CEPENT),cCepPict)
	Else
		@ li,003 PSAY STR0008 + MV_PAR13		//"Local de Entrega  : " imprime o endereco digitado na pergunte
	Endif

	@ li,142 - nDifColCC PSAY " |"
	dbGoto(nRegistro)
	DbSelectArea(cAlias)

	li++
	@ li,001 PSAY "|"
	@ li,003 PSAY STR0010 + SM0->M0_ENDCOB		//"Local de Cobranca : "
	@ li,057 PSAY "-"
	@ li,061 PSAY SM0->M0_CIDCOB
	@ li,083 PSAY "-"
	@ li,085 PSAY SM0->M0_ESTCOB
	@ li,088 PSAY "-"
	@ li,090 PSAY STR0009	//"CEP :"
	@ li,096 PSAY Trans(Alltrim(SM0->M0_CEPCOB),cCepPict)
	@ li,142 - nDifColCC PSAY " |"
	li++
	@ li,001 PSAY "|"
	@ li,002 PSAY Replicate("-",limite)
	@ li,142 - nDifColCC PSAY "|"

	DbSelectArea("SE4")
	DbSetOrder(1)
	DbSeek(xFilial("SE4")+SC7->C7_COND)
	DbSelectArea("SC7")
	li++
	@ li,001 PSAY "|"
	@ li,003 PSAY STR0011+SubStr(SE4->E4_COND,1,15)		//"Condicao de Pagto "
	@ li,038 PSAY STR0012		// "|Data de Emissao|"
	@ li,056 PSAY STR0013		// "Total das Mercadorias : "
	@ li,094 PSAY xMoeda(nTotal,SC7->C7_MOEDA,MV_PAR12,SC7->C7_DATPRF,MsDecimais(SC7->C7_MOEDA),nTxMoeda) Picture tm(nTotal,14,MsDecimais(MV_PAR12))

	@ li,142 - nDifColCC PSAY "|"
	li++
	@ li,001 PSAY "|"
	@ li,003 PSAY SubStr(SE4->E4_DESCRI,1,34)
	@ li,038 PSAY "|"
	@ li,043 PSAY SC7->C7_EMISSAO
	@ li,054 PSAY "|"
	@ li,056 PSAY STR0064		// "Total com Impostos : "
	@ li,094 PSAY xMoeda(nTotMerc,SC7->C7_MOEDA,MV_PAR12,SC7->C7_DATPRF,MsDecimais(SC7->C7_MOEDA),nTxMoeda) Picture tm(nTotMerc,14,MsDecimais(MV_PAR12))
	@ li,142 - nDifColCC PSAY "|"
	li++
	@ li,001 PSAY "|"
	@ li,002 PSAY Replicate("-",52)
	@ li,054 PSAY "|"
	@ li,055 PSAY Replicate("-",86 - nDifColCC)
	@ li,142 - nDifColCC PSAY "|"
	li++
	DbSelectArea("SM4")
	DbSeek(xFilial("SM4")+SC7->C7_REAJUST)
	DbSelectArea("SC7")
	@ li,001 PSAY "|"
	@ li,003 PSAY STR0014		//"Reajuste :"
	@ li,014 PSAY SC7->C7_REAJUST Picture PesqPict("SC7","c7_reajust",,MV_PAR12)
	@ li,018 PSAY SM4->M4_DESCR
	@ li,054 PSAY STR0018		//"| Total Geral : "

	@ li,094 PSAY xMoeda(nTotNF,SC7->C7_MOEDA,MV_PAR12,SC7->C7_DATPRF,MsDecimais(SC7->C7_MOEDA),nTxMoeda)      Picture tm(nTotNF,14,MsDecimais(MV_PAR12))
	@ li,142 - nDifColCC PSAY "|"
	li++
	@ li,001 PSAY "|"
	@ li,002 PSAY Replicate("-",limite)
	@ li,142 - nDifColCC PSAY "|"
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializar campos de Observacoes.                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Empty(cObs02)
		If Len(cObs01) > 50
			cObs 	:= cObs01
			cObs01:= Substr(cObs,1,50)
			For nX := 2 To 4
				cVar  := "cObs"+StrZero(nX,2)
				&cVar := Substr(cObs,(50*(nX-1))+1,50)
			Next
		EndIf
	Else
		cObs01:= Substr(cObs01,1,IIf(Len(cObs01)<50,Len(cObs01),50))
		cObs02:= Substr(cObs02,1,IIf(Len(cObs02)<50,Len(cObs01),50))
		cObs03:= Substr(cObs03,1,IIf(Len(cObs03)<50,Len(cObs01),50))
		cObs04:= Substr(cObs04,1,IIf(Len(cObs04)<50,Len(cObs01),50))
	EndIf

	li++
	@ li,001 PSAY STR0025	//"| Observacoes"
	@ li,054 PSAY STR0026	//"| Comprador    "
	@ li,070 PSAY STR0027	//"| Gerencia     "
	@ li,085 PSAY STR0028	//"| Diretoria    "
	@ li,142 - nDifColCC PSAY "|"

	li++
	@ li,001 PSAY "|"
	@ li,003 PSAY cObs01
	@ li,054 PSAY "|"
	@ li,070 PSAY "|"
	@ li,085 PSAY "|"
	@ li,142 - nDifColCC PSAY "|"

	li++
	@ li,001 PSAY "|"
	@ li,003 PSAY cObs02
	@ li,054 PSAY "|"
	@ li,070 PSAY "|"
	@ li,085 PSAY "|"
	@ li,142 - nDifColCC PSAY "|"

	li++
	@ li,001 PSAY "|"
	@ li,003 PSAY cObs03
	@ li,054 PSAY "|"
	@ li,070 PSAY "|"
	@ li,085 PSAY "|"
	@ li,142 - nDifColCC PSAY "|"

	li++
	@ li,001 PSAY "|"
	@ li,003 PSAY cObs04
	@ li,054 PSAY "|"
	@ li,070 PSAY "|"
	@ li,085 PSAY "|"
	@ li,142 - nDifColCC PSAY "|"
	li++
	@ li,001 PSAY "|"
	@ li,002 PSAY Replicate("-",limite)
	@ li,142 - nDifColCC PSAY "|"
	li++

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Lista de Aprovadores   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectArea("SC7")
	lNewAlc := .F.
	If !Empty(C7_APROV)
		lNewAlc := .T.
		cComprador := UsrFullName(SC7->C7_USER)
		If C7_CONAPRO != "B"
			lLiber := .T.
		EndIf
		DbSelectArea("SCR")
		DbSetOrder(1)
		DbSeek(xFilial("SCR")+"AE"+SC7->C7_NUM)
		While !Eof() .And. SCR->CR_FILIAL+Alltrim(SCR->CR_NUM)==xFilial("SCR")+Alltrim(SC7->C7_NUM) .And. SCR->CR_TIPO == "AE"
			cAprov += AllTrim(UsrFullName(SCR->CR_USER))+" ["
			Do Case
			Case SCR->CR_STATUS=="03" //Liberado
				cAprov += "Ok"
			Case SCR->CR_STATUS=="04" //Bloqueado
				cAprov += "BLQ"
			Case SCR->CR_STATUS=="05" //Nivel Liberado
				cAprov += "##"
			OtherWise                 //Aguar.Lib
				cAprov += "??"
			EndCase
			cAprov += "] - "
			DbSelectArea("SCR")
			dbSkip()
		Enddo
		If !Empty(SC7->C7_GRUPCOM)
			DbSelectArea("SAJ")
			DbSetOrder(1)
			DbSeek(xFilial("SAJ")+SC7->C7_GRUPCOM)
			While !Eof() .And. SAJ->AJ_FILIAL+SAJ->AJ_GRCOM == xFilial("SAJ")+SC7->C7_GRUPCOM
				If SAJ->AJ_USER != SC7->C7_USER
					cAlter += AllTrim(UsrFullName(SAJ->AJ_USER))+"/"
				EndIf
				DbSelectArea("SAJ")
				dbSkip()
			EndDo
		EndIf
	EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Imprime Aprovadores  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lNewAlc
		@ li,001 PSAY "|"
		@ li,003 PSAY STR0052		//"Comprador Responsavel :"
		@ li,027 PSAY Substr(cComprador,1,60)
		@ li,088 PSAY "|"
		@ li,089 PSAY STR0060      //"BLQ:Bloqueado"
		@ li,102 PSAY "|"
		@ li,142 - nDifColCC PSAY "|"
		li++
		nAuxLin := Len(cAlter)
		@ li,001 PSAY "|"
		@ li,003 PSAY STR0053		//"Compradores Alternativos :"
		While nAuxLin > 0 .Or. lImpLeg
			@ li,029 PSAY Substr(cAlter,Len(cAlter)-nAuxLin+1,60)
			@ li,088 PSAY "|"
			If lImpLeg
				@ li,089 PSAY STR0061   //"Ok:Liberado"
				lImpLeg := .F.
			EndIf
			@ li,102 PSAY "|"
			@ li,142 - nDifColCC PSAY "|"
			nAuxLin -= 60
			li++
		EndDo
	
		nAuxLin := Len(cAprov)
		lImpLeg := .T.
	
		While nAuxLin > 0	.Or. lImpLeg
			@ li,001 PSAY "|"
			If lImpLeg  // Imprimir soh a 1a vez
				@ li,003 PSAY STR0054		//"Aprovador(es) :"
			EndIf
			@ li,018 PSAY Substr(cAprov,Len(cAprov)-nAuxLin+1,70)
			@ li,088 PSAY "|"
		
			If lImpLeg2  // Imprimir soh a 2a vez
				@ li,089 PSAY STR0067 //"##:Nivel.Lib"
				lImpLeg2 := .F.
			EndIf
			If lImpLeg   // Imprimir soh a 1a vez
				@ li,089 PSAY STR0062  //"??:Aguar.Lib"
				lImpLeg  := .F.
				lImpLeg2 := .T.
			EndIf
		
			@ li,102 PSAY "|"
			@ li,142 - nDifColCC PSAY "|"
	
			nAuxLin -=70
			li++
		EndDo
	
		If lImpLeg2
			lImpLeg2 := .F.
			@ li,001 PSAY "|"
			@ li,088 PSAY "|"
			@ li,089 PSAY STR0067 //"##:Nivel Lib"
			@ li,102 PSAY "|"
			@ li,142 - nDifColCC PSAY "|"
			li++
		EndIf
	
		If nAuxLin == 0
			li++
		EndIf

		@ li,001 PSAY "|"
		@ li,002 PSAY Replicate("-",limite)
		@ li,142 - nDifColCC PSAY "|"
		li++
	
	EndIf

	@ li,001 PSAY STR0029	//"|   NOTA: So aceitaremos a mercadoria se na sua Nota Fiscal constar o numero da Autorizacao de Entrega."
	@ li,142 - nDifColCC PSAY "|"

	li++
	@ li,001 PSAY "|"
	@ li,002 PSAY Replicate("-",limite)
	@ li,142 - nDifColCC PSAY "|"

Return .T.
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ ImpRodape³ Autor ³ Wagner Xavier         ³ Data ³          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Imprime o rodape do formulario e salta para a proxima folha³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ImpRodape(Void)   			         					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ 					                     				      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MatR110                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ImpRodape()
	li++
	@ li,001 PSAY "|"
	@ li,002 PSAY Replicate("-",limite)
	@ li,142 - nDifColCC PSAY "|"
	li++
	@ li,001 PSAY "|"
	@ li,070 PSAY STR0030		//"Continua ..."
	@ li,142 - nDifColCC PSAY "|"
	li++
	@ li,001 PSAY "|"
	@ li,002 PSAY Replicate("-",limite)
	@ li,142 - nDifColCC PSAY "|"
	li:=0
Return .T.
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ ImpCabec ³ Autor ³ Wagner Xavier         ³ Data ³          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Imprime o Cabecalho do Pedido de Compra                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ImpCabec(Void)                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MatR110                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ImpCabec(ncw)
	Local nOrden, cCGC
	LOCAL cMoeda

	cMoeda := Iif(mv_par12<10,Str(mv_par12,1),Str(mv_par12,2))

	@ 01,001 PSAY "|"
	@ 01,002 PSAY Replicate("-",limite)
	@ 01,142 - nDifColCC PSAY "|"
	@ 02,001 PSAY "|"
	@ 02,029 PSAY IIf(nOrdem>1,(STR0033)," ")		//" - continuacao"

	If mv_par08 == 1 .OR. mv_par08 == 3
		@ 02,045 PSAY (STR0031)+" - "+GetMV("MV_MOEDA"+cMoeda) 	//"| P E D I D O  D E  C O M P R A S"
	Else
		@ 02,045 PSAY (STR0032)+" - "+GetMV("MV_MOEDA"+cMoeda)  //"| A U T. D E  E N T R E G A     "
	EndIf

	If ( Mv_PAR08==2 )
		@ 02,090 PSAY "|"
		@ 02,093 PSAY SC7->C7_NUMSC + "/" + SC7->C7_NUM  //    Picture PesqPict("SC7","c7_num")
	Else
		@ 02,096 PSAY "|"
		@ 02,101 PSAY SC7->C7_NUM      Picture PesqPict("SC7","c7_num")
	EndIf

	@ 02,107 PSAY "/"+Str(nOrdem,1)
	@ 02,112 PSAY IIf(SC7->C7_QTDREEM>0,Str(SC7->C7_QTDREEM+1,2)+STR0034+Str(ncw,2)+STR0035," ")		//"a.Emissao "###"a.VIA"
	@ 02,142 - nDifColCC PSAY "|"
	@ 03,001 PSAY "|"
	@ 03,003 PSAY Substr(SM0->M0_NOMECOM,1,42)
	@ 03,045 PSAY "|"+Replicate("-",95 - nDifColCC)
	@ 03,142 - nDifColCC PSAY "|"
	@ 04,001 PSAY "|"
	@ 04,003 PSAY Substr(SM0->M0_ENDENT,1,42)
	DbSelectArea("SA2")
	DbSetOrder(1)
	DbSeek(xFilial("SA2")+SC7->C7_FORNECE+SC7->C7_LOJA)
	@ 04,045 PSAY "|"
	If ( cPaisLoc$"ARG|POR|EUA" )
		@ 04,047 PSAY Substr(SA2->A2_NOME,1,35)+"-"+SA2->A2_COD+"-"+SA2->A2_LOJA
	Else
		@ 04,047 PSAY Substr(SA2->A2_NOME,1,35)+"-"+SA2->A2_COD+"-"+SA2->A2_LOJA+(STR0036)+" " + SA2->A2_INSCR		//" I.E.: "
	EndIf
	@ 04,142 - nDifColCC PSAY "|"
	@ 05,001 PSAY "|"
	@ 05,003 PSAY (STR0009)+Trans(SM0->M0_CEPENT,cCepPict)+" - "+Trim(SM0->M0_CIDENT)+" - "+SM0->M0_ESTENT		//"CEP :"
	@ 05,045 PSAY "|"
	@ 05,047 PSAY SubStr(SA2->A2_END,1,42)   Picture PesqPict("SA2","A2_END")
	@ 05,089 PSAY "-  "+SubStr(Trim(SA2->A2_BAIRRO),1,(53-nDifColCC))	Picture "@!"
	@ 05,142 - nDifColCC PSAY "|"
	@ 06,001 PSAY "|"
	@ 06,003 PSAY STR0037+SM0->M0_TEL		//"TEL: "
	@ 06,023 PSAY STR0038+SM0->M0_FAX		//"FAX: "
	@ 06,045 PSAY "|"
	@ 06,047 PSAY Trim(SA2->A2_MUN)  Picture "@!"
	@ 06,069 PSAY SA2->A2_EST    		Picture PesqPict("SA2","A2_EST")
	@ 06,074 PSAY STR0009	//"CEP :"
	@ 06,081 PSAY SA2->A2_CEP    		Picture PesqPict("SA2","A2_CEP")

	DbSelectArea("SX3")
	nOrden = IndexOrd()
	DbSetOrder(2)
	DbSeek("A2_CGC")
	cCGC := Alltrim(X3TITULO())
	@ 06,093 PSAY cCGC+":" //"CGC: "
	DbSetOrder(nOrden)

	DbSelectArea("SA2")
	@ 06,103 PSAY SA2->A2_CGC  Picture If(SA2->A2_TIPO=="J",PesqPict("SA2","A2_CGC"),Iif(SA2->A2_TIPO == 'F',Substr(PICPES(SA2->A2_TIPO),1,17),Substr(PICPES(SA2->A2_TIPO),1,21)))
	@ 06,142 - nDifColCC PSAY "|"
	@ 07,001 PSAY "|"
	@ 07,002 PSAY (cCGC) + " "+ Transform(SM0->M0_CGC,cCgcPict)		//"CGC: "
	If cPaisLoc == "BRA"
		@ 07,029 PSAY (STR0041)+ InscrEst()		//"IE:"
	EndIf
	@ 07,045 PSAY "|"
	@ 07,047 PSAY SC7->C7_CONTATO Picture PesqPict("SC7","C7_CONTATO")
	@ 07,069 PSAY STR0042	//"FONE: "
	@ 07,075 PSAY "("+Substr(SA2->A2_DDD,1,3)+") "+Substr(SA2->A2_TEL,1,15)
	@ 07,100 PSAY (STR0038)	//"FAX: "
	@ 07,106 PSAY "("+Substr(SA2->A2_DDD,1,3)+") "+SubStr(SA2->A2_FAX,1,15)
	@ 07,142 - nDifColCC PSAY "|"
	@ 08,001 PSAY "|"
	@ 08,002 PSAY Replicate("-",limite)
	@ 08,142 - nDifColCC PSAY "|"

	If mv_par08 == 1 .OR. mv_par08 == 3
		@ 09,001 PSAY "|"
		@ 09,002 PSAY STR0043	//"Itm|"
		@ 09,009 PSAY STR0044	//"Codigo      "
		@ 09,022 PSAY STR0045	//"|Descricao do Material"
		@ 09,049 PSAY STR0046	//"|UM|  Quant."
		If cPaisLoc <> "BRA"
			@ 09,065 PSAY IIF(nDifColcc == 0,STR0056,STR0057)	//"|Valor Unitario|      Valor Total   |Entrega   |  C.C.   | S.C. |"
		Else
			@ 09,065 PSAY IIF(nDifColcc == 0,STR0047,STR0055)	//"|Valor Unitario|IPI% |  Valor Total   | Entrega  |  C.C.   | S.C. |"
		EndIf
		@ 10,001 PSAY "|"
		@ 10,002 PSAY Replicate("-",limite)
		@ 10,142 - nDifColCC PSAY "|"
	Else
		@ 09,001 PSAY "|"
		@ 09,002 PSAY STR0043	//"Itm|"
		@ 09,009 PSAY STR0044	//"Codigo      "
		@ 09,022 PSAY STR0045	//"|Descricao do Material"
		@ 09,049 PSAY STR0046	//"|UM|  Quant."
		@ 09,065 PSAY STR0048	//"|Valor Unitario|  Valor Total   |Entrega | Numero da OP  "
		@ 09,142 - nDifColCC PSAY "|"
		@ 10,001 PSAY "|"
		@ 10,002 PSAY Replicate("-",limite)
		@ 10,142 - nDifColCC PSAY "|"
	EndIf
	DbSelectArea("SC7")
	li := 10
Return .T.
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³R110Center³ Autor ³ Jose Lucas            ³ Data ³          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Centralizar o Nome do Liberador do Pedido.                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ExpC1 := R110CenteR(ExpC2)                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 := Nome do Liberador                                 ³±±
±±³Parametros³ ExpC2 := Nome do Liberador Centralizado                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MatR110                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function R110Center(cLiberador)
Return( Space((30-Len(AllTrim(cLiberador)))/2)+AllTrim(cLiberador) )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AjustaSX1 ºAutor  ³Alexandre Lemes     º Data ³ 17/12/2002  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MATR110                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function AjustaSX1()

	Local aHelpPor	:= {}
	Local aHelpEng	:= {}
	Local aHelpSpa	:= {}
	Local nTamSX1   := Len(SX1->X1_GRUPO)

	Aadd( aHelpPor, "Filtra os itens do PC a serem impressos " )
	Aadd( aHelpPor, "Todos,somente os abertos ou Atendidos.  " )

	Aadd( aHelpEng, "                                        " )
	Aadd( aHelpEng, "                                        " )

	Aadd( aHelpSpa, "                                        " )
	Aadd( aHelpSpa, "                                        " )

	PutSx1("MTR110","07","Lista quais ?       ","Cuales Lista ?      ","List which ?        ","mv_che","N",1,0,1,"C","","","","","mv_par14",;
		"Todos ","Todos ","All ","","Em Aberto ","En abierto ","Open ","Atendidos ","Atendidos ","Serviced ","","","","","","","","","","")
	PutSX1Help("P.MTR11014.",aHelpPor,aHelpEng,aHelpSpa)

	DbSelectArea("SX1")
	DbSetOrder(1)

	If DbSeek(PADR("MTR110",nTamSX1)+"07")
		RecLock("SX1",.F.)
		X1_DEF03   := "Todos"
		X1_DEFSPA3 := "Todos"
		X1_DEFENG3 := "All"
		MsUnLock()
	EndIf

Return
                                                          
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ChkPergUs ³ Autor ³ Nereu Humberto Junior ³ Data ³21/09/07  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao para buscar as perguntas que o usuario nao pode     ³±±
±±³          ³ alterar para impressao de relatorios direto do browse      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ChkPergUs(ExpC1,ExpC2,ExpC3)                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 := Id do usuario                                     ³±±
±±³          ³ ExpC2 := Grupo de perguntas                                ³±±
±±³          ³ ExpC2 := Numero da sequencia da pergunta                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MatR110                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ChkPergUs(cUserId,cGrupo,cSeq)

	Local aArea  := GetArea()
	Local cRet   := Nil
	Local cParam := "MV_PAR"+cSeq

	DbSelectArea("SXK")
	DbSetOrder(2)
	If DbSeek("U"+cUserId+cGrupo+cSeq)
		If ValType(&cParam) == "C"
			cRet := AllTrim(SXK->XK_CONTEUD)
		ElseIf 	ValType(&cParam) == "N"
			cRet := Val(AllTrim(SXK->XK_CONTEUD))
		ElseIf 	ValType(&cParam) == "D"
			cRet := CTOD((AllTrim(SXK->XK_CONTEUD)))
		Endif
	Endif

	RestArea(aArea)
Return(cRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³R110FIniPC³ Autor ³ Edson Maricate        ³ Data ³20/05/2000³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Inicializa as funcoes Fiscais com o Pedido de Compras      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ R110FIniPC(ExpC1,ExpC2)                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 := Numero do Pedido                                  ³±±
±±³          ³ ExpC2 := Item do Pedido                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATR110,MATR120,Fluxo de Caixa                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function R110FIniPC(cPedido,cItem,cSequen,cFiltro)

	Local aArea		:= GetArea()
	Local aAreaSC7	:= SC7->(GetArea())
	Local cValid		:= ""
	Local nPosRef		:= 0
	Local nItem		:= 0
	Local cItemDe		:= IIf(cItem==Nil,'',cItem)
	Local cItemAte	:= IIf(cItem==Nil,Repl('Z',Len(SC7->C7_ITEM)),cItem)
	Local cRefCols	:= ''
	DEFAULT cSequen	:= ""
	DEFAULT cFiltro	:= ""

	DbSelectArea("SC7")
	DbSetOrder(1)
	If DbSeek(xFilial("SC7")+cPedido+cItemDe+Alltrim(cSequen))
		MaFisEnd()
		MaFisIni(SC7->C7_FORNECE,SC7->C7_LOJA,"F","N","R",{})
		While !Eof() .AND. SC7->C7_FILIAL+SC7->C7_NUM == xFilial("SC7")+cPedido .AND. ;
				SC7->C7_ITEM <= cItemAte .AND. (Empty(cSequen) .OR. cSequen == SC7->C7_SEQUEN)

		// Nao processar os Impostos se o item possuir residuo eliminado  
			If &cFiltro
				DbSelectArea('SC7')
				dbSkip()
				Loop
			EndIf
            
		// Inicia a Carga do item nas funcoes MATXFIS  
			nItem++
			MaFisIniLoad(nItem)
			DbSelectArea("SX3")
			DbSetOrder(1)
			DbSeek('SC7')
			While !EOF() .AND. (X3_ARQUIVO == 'SC7') .AND. (X3_CONTEXT != 'V') //-->Alterado por Bia Ferreira - Ethosx 14/01/2020
				cValid	:= StrTran(UPPER(SX3->X3_VALID)," ","")
				cValid	:= StrTran(cValid,"'",'"')
				If "MAFISREF" $ cValid
					nPosRef  := AT('MAFISREF("',cValid) + 10
					cRefCols := Substr(cValid,nPosRef,AT('","MT120",',cValid)-nPosRef )
				// Carrega os valores direto do SC7.           
					MaFisLoad(cRefCols,&("SC7->"+ SX3->X3_CAMPO),nItem)
				EndIf
				dbSkip()
			End
			MaFisEndLoad(nItem,2)
			DbSelectArea('SC7')
			dbSkip()
		End
	EndIf

	RestArea(aAreaSC7)
	RestArea(aArea)

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³R110Logo  ³ Autor ³ Materiais             ³ Data ³07/01/2015³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Retorna string com o nome do arquivo bitmap de logotipo    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATR110                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function R110Logo()

	Local cBitmap := "LGRL"+SM0->M0_CODIGO+SM0->M0_CODFIL+".BMP" // Empresa+Filial

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se nao encontrar o arquivo com o codigo do grupo de empresas ³
//³ completo, retira os espacos em branco do codigo da empresa   ³
//³ para nova tentativa.                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !File( cBitmap )
		cBitmap := "LGRL" + AllTrim(SM0->M0_CODIGO) + SM0->M0_CODFIL+".BMP" // Empresa+Filial
	EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se nao encontrar o arquivo com o codigo da filial completo,  ³
//³ retira os espacos em branco do codigo da filial para nova    ³
//³ tentativa.                                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !File( cBitmap )
		cBitmap := "LGRL"+SM0->M0_CODIGO + AllTrim(SM0->M0_CODFIL)+".BMP" // Empresa+Filial
	EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se ainda nao encontrar, retira os espacos em branco do codigo³
//³ da empresa e da filial simultaneamente para nova tentativa.  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !File( cBitmap )
		cBitmap := "LGRL" + AllTrim(SM0->M0_CODIGO) + AllTrim(SM0->M0_CODFIL)+".BMP" // Empresa+Filial
	EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se nao encontrar o arquivo por filial, usa o logo padrao     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !File( cBitmap )
		cBitmap := "LGRL"+SM0->M0_CODIGO+".BMP" // Empresa
	EndIf

Return( cBitmap )

//--------------------------------------------------------------------
/*/{Protheus.doc} BuscaIPI
Busca valor total do IPI	

@author Rodrigo Nunes
@since 04/02/2021
/*/
//--------------------------------------------------------------------
Static Function BuscaIPI()
	Local cQuery  := ""
	Local nVlrIPI := 0

	cQuery := " SELECT SUM(C7_VALIPI) AS VLR_IPI FROM " + RetSqlName("SC7")
	cQuery += " WHERE C7_FILIAL = '"+xFilial("SC7")+"'
	cQuery += " AND C7_NUM = '"+SC7->C7_NUM+"'
	cQuery += " AND D_E_L_E_T_ = '' "

	If Select("C7IPI") > 0
		C7IPI->(dbCloseArea())
	EndIf

	dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), "C7IPI", .T., .F. )

	If C7IPI->(!EOF())
		nVlrIPI := C7IPI->VLR_IPI
	EndIf	

Return nVlrIPI
