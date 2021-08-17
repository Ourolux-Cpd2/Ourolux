#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "FONT.CH"
#INCLUDE "DBTREE.CH"  
#INCLUDE "TbiCode.ch"
#INCLUDE "Colors.ch"
#INCLUDE "FWPrintSetup.ch"
#INCLUDE "ParmType.ch"
#INCLUDE "RPTDEF.CH"

#DEFINE COMP_DATE       "20191209"

#DEFINE ODLG_HINI 0000
#DEFINE ODLG_WINI 0000
#DEFINE ODLG_HEND 0600
#DEFINE ODLG_WEND 1100

#DEFINE N_FONT01 "Tahoma"
#DEFINE N_FONT02 "Verdana"
#DEFINE N_FONT03 "Courier New"
	
#DEFINE oFont		TFont():New("Arial",08,14,,.T.,,,,.T.)

#DEFINE oOk 		LoadBitmap( nil, "ENABLE" )  
#DEFINE oNo 		LoadBitmap( nil, "DISABLE" )
#DEFINE oBlue 		LoadBitmap( nil, "BR_AZUL" )
#DEFINE oYellow		LoadBitmap( nil, "BR_AMARELO" )

#DEFINE GD_OK		"GD_OK.png"
#DEFINE GD_WARN		"GD_WARN.png"
#DEFINE GD_ERR		"GD_ERR.png"

#DEFINE A_FILIAIS   RetFil() 
#DEFINE A_CAMPOS	{"  "	,"Processo"	,"Data"		,"Detalhe"	,}
#DEFINE A_PROC		RetProc()

#DEFINE N_MAXFIL	10 // Maximo de filiais por linha
#DEFINE DT_P12		Ctod("01/08/2017") 

/*
{Protheus.doc} GDPAN01 
Tela informativa dos status relevantes para o processamento do extrator de informações do GooData

@author Roberto Souza
@since 04/10/2017
@version 1

@Retorno   Nil
*/
User Function GDPAN01()

	RpcSetType(3)
	RpcSetEnv("01","01")

	Private bLoadPan	:= {|| FWMsgRun(,{|| CursorWait(),GoPan(),CursorArrow()},,"Carregando definições..." )}
	Private dMainData 	:= dDataBase
	Private lLoopGD   	:= .T. 

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Chamada recursiva para refresh            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    While lLoopGD 
		Eval( bLoadPan )	
		DelClassIntF()
	EndDo
	
Return
 

/*
{Protheus.doc} GoPan 
Tela informativa dos status relevantes para o processamento do extrator de informações do GooData

@author Roberto Souza
@since 04/10/2017
@version 1

@Retorno   Nil
*/
Static Function GoPan( oProc )
	Local aLabel 			:= {} 
	Local oTsk   			:= Nil
	Local aPages 			:= {}
	Local nTamDataBar 	:= 95 // 85
	Local oFWLayer 		:= FWLayer():New()
	Local oPanelL  		:= Nil
	Local oPanelC  		:= Nil
	Local oPanelR  		:= Nil
	Local oPanelI  		:= Nil
	Local oTree
	Local bChange       := {|| MyPanChg(oTree:GetCargo() , oFWLayer , aPages )}
	Local Nx            := 0 
	Local lTScroll 		:= .F.    
	Local bSair			:= {|| Iif( MsgYesNo("Deseja Sair ?","Confirmação"),(lLoopGD := .F., oMainDlg:End()),.F.)}
	Local cDirDest 		:= "c:\temp\"    
	Local cFilePrt		:= "GD_PAN_"+dTos(dMainData)+"_"+StrTran(Time(),":","-")+".bmp"
	Local bPrint		:= {|| PrtScrn( oMainDlg, cDirDest, cFilePrt ) }  
   	Local lPrintKey		:= .T.
   		
	Local lProc 		:= oProc <> Nil
	Local STAT_TREE		:= "BR_VERMELHO"
	
	Private lFormSaved	:= .T.
	Private oFont01		:= TFont():New("Arial",07,14,,.T.,,,,.T.,.F.)
	Private oFont02		:= TFont():New("Lucida Console",07,14,,.T.,,,,.T.,.F.)
	Private oFont03		:= TFont():New("Courier",07,14,,.T.,,,,.T.,.F.)
	Private cEmpLog		:= IIf( Type("cEmpAnt") == "U", nil, cEmpAnt )
	Private lMsgRun		:= .T.
	Private oXmlCfg     := Nil
	Private aFilStat    := {}
 
	If Type("cEmpLog") == "U"

		RpcSetEnv("01","01")
		RpcSetType(3)
		aCoord			:= {000,000,500,1000}//FWGetDialogSize(oMainWnd)

	Else

		aCoord			:= {000,000,500,1100}//FWGetDialogSize(oMainWnd)
//		aCoord			:= FWGetDialogSize(oMainWnd)
//		aCoord[03]		:= oMainWnd:NHEIGHT * 0.95
//		aCoord[04]		:= oMainWnd:NWIDTH  * 0.98
	
	EndIf	
 
	For Nx := 01 To Len( A_FILIAIS )
	    cCod	:= Substr(A_FILIAIS[Nx],1,2)	 
        cNom    := Substr(A_FILIAIS[Nx],4)
			
		AADD(aPages,{StrZero(Nx,2),A_FILIAIS[Nx]		,cNom,"BR_VERDE"		, "FilView"	})
	Next    

    
	oMainDlg := tDialog():New(aCoord[1],aCoord[2],aCoord[3],aCoord[4],OemToAnsi("Status Integração GoodData")+" - "+COMP_DATE,,,,,CLR_BLUE,CLR_WHITE,,,.T.)
	
	oFWLayer:Init( oMainDlg, .F., .F. )
	oFWLayer:AddLine( 'UP'	, nTamDataBar, .F. )
	
	oFWLayer:AddCollumn( 'LEFT' 		, 20, .F., 'UP' )
	oFWLayer:AddCollumn( 'CENTER'  		, 70, .F., 'UP' )
	oFWLayer:AddCollumn( 'RIGHT'		, 10, .F., 'UP' )


 	oFWLayer:AddWindow("LEFT"	,"LUP00","Data Base"							,020,.F.,.F.,/*bAction*/,"UP",/*bGotFocus*/)
	oFWLayer:AddWindow("LEFT"	,"LUP01","Índice - Database: "+	dToc(dMainData)	,080,.F.,.F.,/*bAction*/,'UP',/*bGotFocus*/)
	oFWLayer:AddWindow("CENTER"	,"CUP01","Status"				,100,.F.,.F.,/*bAction*/,'UP',/*bGotFocus*/)
	oFWLayer:AddWindow("RIGHT"	,"RUP01","Ações"				,100,.F.,.F.,/*bAction*/,'UP',/*bGotFocus*/)

	oPanelX  := oFWLayer:GetWinPanel("LEFT" 	,"LUP00","UP")                                                    
	oPanelL  := oFWLayer:GetWinPanel("LEFT" 	,"LUP01","UP")
	oPanelC  := oFWLayer:GetWinPanel("CENTER"	,"CUP01","UP")
	oPanelR  := oFWLayer:GetWinPanel("RIGHT"	,"RUP01","UP")



	@ 008, 015 MSGET oMainData VAR dMainData 	SIZE 050,008 	OF oPanelX PIXEL		
	oMainData:Align	:= CONTROL_ALIGN_ALLCLIENT
	
	oButRef := tButton():New(008,055,"&Atualizar" ,oPanelX,{|| oMainDlg:End() }	,40,11,,/*oFont*/,,.T.,,,,/*bWhen*/)
	oButRef:Align	:= CONTROL_ALIGN_BOTTOM	

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Desenho da Tree                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oTree := DbTree():New(oPanelL:nLeft,oPanelL:nTop,oPanelL:nRight,oPanelL:nWidth, oPanelL,bChange,,.T.)
	oTree:Align := CONTROL_ALIGN_ALLCLIENT
	oTree:lShowHint := .F.
	
	cTexto := "Filial"
	oTree:AddItem(cTexto, "00", "ENGRENAGEM" ,"ENGRENAGEM",,,2,.T.)
	oTree:ChangePrompt(cTexto, "00")

	cFolderP := "00" 
	cPanelOk := "oPanel"+cFolderP

	&(cPanelOk)  := tPanel():New(000,000,"",oPanelC,,,,/*CLR_YELLOW*/,/*CLR_BLUE*/,500,500)		                                 
	&(cPanelOk):Align := CONTROL_ALIGN_ALLCLIENT
			 

	//#################################

    For Nx := 1 To Len(aPages)

		cFolderP := aPages[Nx][01]  
		cPanelOk := "oPanel"+cFolderP

		cPan := "oPan"+cFolderP
		&(cPan) := ""		             
		
		&(cPanelOk)  := tPanel():New(000,000,"",oPanelC,,,,/*CLR_YELLOW*/,/*CLR_BLUE*/,500,500)		                                 

		&(cPanelOk):Align := CONTROL_ALIGN_ALLCLIENT

		oLbx := "oLbx"+StrZero(Nx,2)
		aFprc:= "aFprc"+StrZero(Nx,2)                                             
        &(aFprc) := {}
		&(oLbx)	 := 0
			 
		bFunc := "{|| CursorWait(), STAT_TREE := "+ aPages[Nx][05]+"( "+cPanelOk+",'"+Substr(aPages[Nx][2],1,2)+"',@"+oLbx+",@"+aFprc+" ), CursorArrow(),  }" 

		LjMsgRun(OemToAnsi("Carregando "+aPages[Nx][02]+"..."),,&(bFunc) )
        
		AADD(aFilStat,{ aPages[Nx][01] , STAT_TREE } )
		
		oTree:AddItem(aPages[Nx][02] , aPages[Nx][01], STAT_TREE ,STAT_TREE,,,2,.T.) 
		oTree:ChangePrompt(aPages[Nx][02], aPages[Nx][01])
		
		&(cPanelOk):Hide()		                       

    Next

	bFunc := "{|| CursorWait(), "+ "MainView"+"( oPanel00 ), CursorArrow(),  }" 
	LjMsgRun(OemToAnsi("Carregando Painel Principal..."),,&(bFunc) )

	oTree:TreeSeek(StrZero(Len(aPages),2))
	oTree:TreeSeek("00")
	oPanelC:SetFocus(oPanelC)

	oTree:EndTree()


	oButt1 := TButton():New(000,000,"Sair"			, oPanelR,bSair		,oPanelR:nClientWidth/2,15,,/*oFont*/,,.T.,,,,/*bWhen*/)
	If lPrintKey
		oButt2 := TButton():New(016,000,"PrintScreen"	, oPanelR,bPrint	,oPanelR:nClientWidth/2,15,,/*oFont*/,,.T.,,,,/*bWhen*/)      
    EndIf
    
	oMainDlg:Activate(,,,.T.,/*valid*/,,/*On Init*/)

Return()                        

/*
{Protheus.doc} FilView 
Mosta a tela de visualização de filial e seus status

@author Roberto Souza
@since 04/10/2017
@version 1
@Parametros  	oFather 
				cFilP 
				oLbx 
				aProc
				
@Retorno   		MAIN_STAT	- Status Geral
*/
Static Function FilView( oFather, cFilP, oLbx, aProc )
	Local MAIN_STAT		:= "BR_VERDE"  
	Local lDock     	:= oFather <> nil
	Local oDlgList
	Local oDlgDb
	Local oList1
	Local oList2 
	Local oArea		   	:= FWLayer():New()
	Local aCoord		:= {ODLG_HINI,ODLG_WINI,ODLG_HEND,ODLG_WEND}//FWGetDialogSize(oMainWnd)
	Local aTamObj		:= Array(4)
	Local lProc         := .F.
	Local oLbx 
	Local bOk			:= {|| lRet := .T.,oDlgDb:End() }
	Local oButt1,oButt2
	Local aSize     	:= {}
	Local aArea     	:= GetArea()
	Local aInfo     	:= {}
	Local aObjects  	:= {}
	Local aPosObj 		:= {}
	Local aPos 	    	:= {012,005,200,600}
	Local aCpoH     	:= {}
	Local cDescView 	:= ""
	Local aCombo    	:= {}
	Local aPerg     	:= {}
	Local cInfo			:= Space(60)
	Local aItems		:= {}
	Local aWindow		:= {}
	Local aColumn		:= {} 
	Local aItens		:= {}
	Local lAtuStat      := .F.
	Local cAtuStat      := "1"

    Private cObs		:= ""
	Private dDtStat	  	:= Stod(Space(8)) 	
    Private cDataRef	:= dMainData

	For Nx := 1 To Len( A_PROC )
		lAtuStat := RetStat( cFilP, A_PROC[Nx][01],@dDtStat, @cObs ,cDataRef)
		If lAtuStat
			cAtuStat := "1"
		Else
			If A_PROC[Nx][03] == "N"
				cAtuStat := "2"           
				If MAIN_STAT <> "BR_VERMELHO"
					MAIN_STAT := "BR_AMARELO"
				EndIf
			Else
				cAtuStat := "3"
				MAIN_STAT := "BR_VERMELHO"
			EndIf			
		EndIf		
		   
		AADD( aItens , { cAtuStat, A_PROC[Nx][02], dDtStat , Padr(cObs,60) } )

	Next		

	//resoluçao 1280 x 768
	aSize:= {0,0,608.5,270,1217,563,0}

	aInfo := {aSize[1],aSize[2],aSize[3],aSize[4],3,3}

	AADD(aObjects,{100,30,.T.,.F.})
	AADD(aObjects,{100,100,.T.,.T.})
	aPosObj := MsObjSize(aInfo, aObjects)

	aScreen   := GetScreenRes()
	aScreen[1]:= aScreen[1]-20
	aScreen[2]:= aScreen[2]-20

	oDlgDb := oFather
	aWindow := {100,000}
	aColumn := {100,000}
	
	
	oArea:Init(oDlgDb,.F., .F. )
	//Mapeamento da area
	oArea:AddLine("L01",100,.T.)

	//ÚÄÄÄÄÄÄÄÄÄ¿
	//³Colunas  ³
	//ÀÄÄÄÄÄÄÄÄÄÙ
	oArea:AddCollumn("L01C01",aColumn[01],.F.,"L01") //dados

	//ÚÄÄÄÄÄÄÄÄÄ¿
	//³Paineis  ³
	//ÀÄÄÄÄÄÄÄÄÄÙ
	oArea:AddWindow("L01C01","LIST","Detalhamento dos processos",aWindow[01],.F.,.F.,/*bAction*/,"L01",/*bGotFocus*/)
	oList	:= oArea:GetWinPanel("L01C01","LIST","L01")

	oLbx := TWBrowse():New( 000, 000, 400, 600,,A_CAMPOS,,oList,,,,,,,,,,,,.F.,,.T.,,.F.,,,)

	oLbx:SetArray( aItens )

	oLbx:bLine 	:= {|| {RetLeg(aItens[oLbx:nAt][01]),;
					   		aItens[oLbx:nAt][02],;
						   	aItens[oLbx:nAt][03],;
						    aItens[oLbx:nAt][04]}}

	oLbx:Align	:= CONTROL_ALIGN_ALLCLIENT
 
	RestArea(aArea)

Return( MAIN_STAT )     
                      

 
/*
{Protheus.doc} RetLeg 
Retorna a legenda de acordo com o Status

@author Roberto Souza
@since 04/10/2017
@version 1
@Parametros  	xInfo  
         
@Retorno   		uRet	- Objeto Semaforo
*/
Static Function RetLeg( xInfo )
    Local uRet := Nil 
    
    If xInfo == "1"
		uRet  := oOk  
    ElseIf xInfo == "2"
		uRet  := oYellow    
    ElseIf xInfo == "3"
		uRet  := oNo    
    EndIf    
    
Return( uRet ) 
     
 
 
/*
{Protheus.doc} MyPanChg 
Funcao que muda a visualizacao de acordo com o item selecionado na TREE

@author Roberto Souza
@since 04/10/2017
@version 1
@Parametros  	cId  
				oFWLayer  
				aPages
         
@Retorno   		Nil
*/                       
Static Function MyPanChg( cId , oFWLayer , aPages )     
	Local Nx  := 0
	Local nId := Val(cId)

    For Nx := 1 To Len(aPages)
    	If Nx == nId
	    	&("oPanel"+StrZero(Nx,2)):Show() 
	    	oFWLayer:ALINES[1]:ACOLLUMNS[2]:AWINDOWS[1]:OTITLEBAR:CCAPTION := aPages[Nx][02]

    	Else
	    	&("oPanel"+StrZero(Nx,2)):Hide()     	
    	EndIf
 		/*
	 	If cId == "00"
	    	&("oPan"+StrZero(Nx,2)):Show()     	
	    Else
	    	&("oPan"+StrZero(Nx,2)):Hide()     		    	
	 	EndIf         
		*/
 	Next
 	If cId == "00"
    	oFWLayer:ALINES[1]:ACOLLUMNS[2]:AWINDOWS[1]:OTITLEBAR:CCAPTION := "Status"
 	EndIf
Return()









/*
{Protheus.doc} MainView 
Painel inicial da visualização contendo o resumo geral dos status por filial

@author Roberto Souza
@since 04/10/2017
@version 1
@Parametros  	nil
         
@Retorno   		lRet     : Status
*/
Static Function MainView( oFather, oProc )
	Local lRet 			:= .F.  
	Local lDock     	:= oFather <> nil
	Local oDlgList
	Local oDlgMV
	Local oList1
	Local oList2 
	Local oArea		   	:= FWLayer():New()
	Local aCoord		:= {ODLG_HINI,ODLG_WINI,ODLG_HEND,ODLG_WEND}//FWGetDialogSize(oMainWnd)
	Local aTamObj		:= Array(4)
	Local lProc         := oProc <> Nil
	Local oLbx
	Local nOpcA		  	:= 0
	Local bOk			:= {|| lRet := .T.,oDlgMV:End() }
	Local oFont1		:= TFont():New(N_FONT01,08,12,,.T.,,,,.T.)
	Local oFont2		:= TFont():New(N_FONT02,08,12,,.T.,,,,.T.)
	Local oFont3		:= TFont():New(N_FONT03,09,12,,.T.,,,,.T.)
	Local oButt1,oButt2
	Local aSize     	:= {}
	Local aArea     	:= GetArea()
	Local aInfo     	:= {}
	Local aObjects  	:= {}
	Local aPosObj 		:= {}
	Local aPos 	    	:= {012,005,200,600}
	Local aCpoH     	:= {}
	Local cDescView 	:= ""
	Local aCombo    	:= {}
	Local aPerg     	:= {}
	Local aParam    	:= Array(1)
	Local aServerI		:= {}
	Local cInfo	   		:= ""
	Local aUsrInfo		:= {}
	Local aItems		:= {}
	Local aWindow		:= {}
	Local aColumn		:= {}
    
	aLin  := {}    
	nTamL := 15
	nIniL := 2
	nDif  := 4
	nCpo  := 8	
	
	aColB := {000,008,045}
	
	AADD( aLin , 000 )

	For nLin := 1  To 10
		AADD( aLin , (nTamL * nLin) + nIniL )		
	Next  

	//resoluçao 1280 x 768
	aSize:= {0,0,608.5,270,1217,563,0}

	aInfo := {aSize[1],aSize[2],aSize[3],aSize[4],3,3}

	AADD(aObjects,{100,30,.T.,.F.})
	AADD(aObjects,{100,100,.T.,.T.})
	aPosObj := MsObjSize(aInfo, aObjects)

	aScreen   := GetScreenRes()
	aScreen[1]:= aScreen[1]-20
	aScreen[2]:= aScreen[2]-20

	If lDock
		oDlgMV := oFather
		aWindow := {100,010}
		aColumn := {100,010}
	Else
		oDlgMV := tDialog():New(aCoord[1],aCoord[2],aCoord[3],aCoord[4],"Informações gerais",,,,,CLR_BLACK,CLR_WHITE,,,.T.)
		aWindow := {100,010}
		aColumn := {090,010}
	EndIf
	
	oArea:Init(oDlgMV,.T., .F. )

	oArea:AddLine("L01",073,.T.)
	oArea:AddLine("L02",027,.T.)

	cFolderP := "00" 
	cPanXOk := "oPan"+cFolderP
    

	aJan := {100,20}
	                  
	nFils := Len( A_FILIAIS )        
	
    nMedFil := Min( nFils, N_MAXFIL )
    
	nTamLay := 100 / nMedFil

	For Nx := 1 To Min( nFils, N_MAXFIL )  

        cCod	:= Substr(A_FILIAIS[Nx],1,2)	 
        cNom    := Substr(A_FILIAIS[Nx],3)
		cPanXOk 	:= "oPan" + cCod
		cPanXOk2	:= "oPan2" + cCod
        
		If aFilStat[Nx][02] == "BR_VERDE"
			cIconStat := GD_OK
		ElseIf aFilStat[Nx][02] == "BR_AMARELO"
			cIconStat := GD_WARN
		ElseIf aFilStat[Nx][02] == "BR_VERMELHO"
			cIconStat := GD_ERR
		Else
			cIconStat := GD_ERR
		EndIf

		oArea:AddCollumn("L01CX"+cCod ,nTamLay,.F.,"L01") //dados  

		oArea:AddWindow("L01CX"+cCod,"LIST"+cCod,A_FILIAIS[Nx],aJan[01],.F.,.F.,/*bAction*/,"L01",/*bGotFocus*/)
		&(cPanXOk)	:= oArea:GetWinPanel("L01CX"+cCod,"LIST"+cCod,"L01")

		cT := "cT"+StrZero(Nx,3)
		oT := "oT"+StrZero(Nx,3)
		oB := "oB"+StrZero(Nx,3)
		
		aColB[01] := &(cPanXOk):nClientWidth/6 - nDif
			
   		&(oB) := TBitmap():New(aLin[01]+nDif+30 ,aColB[01],025,025,cIconStat,cIconStat,.T.,&(cPanXOk),{||},,.F.,.T.,,,.F.,,.T.,,.F.)
    	&(oB):lAutoSize := .F.     
	
	Next Nx   

	oArea:AddCollumn("L01CW" ,100,.F.,"L02")  

	oArea:AddWindow("L01CW","LEG","Legenda",aJan[01],.F.,.F.,/*bAction*/,"L02",/*bGotFocus*/)
	oPanelLeg	:= oArea:GetWinPanel("L01CW","LEG","L02")

	Legenda( oPanelLeg )

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Painel 03-Botoes            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !lDock
		oButt1 := tButton():New(000,000,"&Sair"				,oAreaBut,bOk	,oAreaBut:nClientWidth/2,15,,/*oFont*/,,.T.,,,,/*bWhen*/)
		oDlgMV:Activate(,,,.T.,/*valid*/,,/*On Init*/)
	EndIf
		
	RestArea(aArea)

Return( lRet )    





/*
{Protheus.doc} RetStat 
Retorna os status dos processos atribuidos baseados na data de referencia

@author Roberto Souza
@since 04/10/2017
@version 1
@Parametros  	nil
         
@Retorno   		lRet     : Status
*/
Static Function RetStat( cFilP, cProcesso , dDtStat, cObs, dDtRef )
	Local lRet := .F.
	Local xInfo
	Local cInfo
    Local cFilSeek 	:= ""
	Local cKeyRCI  	:= ""
	Local cFilSeek 	:= ""
	Local cAnoP		:= ""
	Local cMesP     := ""
	Local aRetProc  := {}
	Local dDtIni    := Stod(Space(8))
	Local dDtFim	:= Stod(Space(8))
    
	dDtStat := Stod(Space(8))
	cObs    := Space(80) 
 
	cAnoP := Substr(dTos(dDtRef),1,4)
	cMesP := Substr(dTos(dDtRef),5,2)
 
	If cMesP == "01"
		cAnoP	:= StrZero( ( Val(cAnoP) - 1 ) , 2)	
		cMesP	:= "12"
	Else
		cMesP	:= StrZero( ( Val(cMesP) - 1 ) , 2)			
	EndIf                                                                  

    
    If cProcesso == "GPEM120"
		If dDtRef < DT_P12 

			cInfo := GetNewPar( "MV_FOLMES", Stod(""), cFilP )

			lRet := ( cInfo < Substr(dTos(dDtRef),1,6) )
            cObs    := "Parametro MV_FOLMES :"+ cInfo
            dDtStat := Stod(cInfo+"01")                                     
		Else	
			cAnoP := Substr(dTos(dDtRef),1,4)
			cMesP := Substr(dTos(dDtRef),5,2)
			
			If cMesP == "01"
				cAnoP	:= StrZero( ( Val(cAnoP) - 1 ) , 4)	     
				cMesP	:= "12"
			Else
				cMesP	:= StrZero( ( Val(cMesP) - 1 ) , 2)			
			EndIf
	
	//		cMesP := "07"
		
			DbSelectArea("RCI")
			DbSetOrder(1)
			cFilSeek := IIf( Empty(xFilial("RCI")) , xFilial("RCI"),cFilP )
			cKeyRCI  := cFilSeek + "00001" + cAnoP+ cMesP
	        If RCI->( DbSeek( cKeyRCI ))
	        	lRet 	:= .T.
	        	dDtStat := RCI->RCI_DTFEC 
	        	cObs    := "Hora do Fechamento: "+  RCI->RCI_HORFEC 
	        Else
	        	lRet := .F.
	        EndIf
		EndIf

	ElseIf cProcesso == "MATA280"
		
		xInfo 	:= GetNewPar( "MV_ULMES", Stod(""), cFilP )
        cRefEst := Substr(Dtos(xInfo),1,6)
		lRet 	:= (cRefEst >= cAnop+cMesp)
		   
		dDtStat := xInfo

	ElseIf cProcesso $ "CTBA190/CTBA211/CTBA360/CTBA190EXEC"
		lRet := .F.    
		dDtStat := Stod("")
                                                     
		dDtIni := FirstDay( dDtRef ) - 1// Stod("20170920")
		dDtFim := Stod("")
		
		aRetProc := ProcCV8( cFilP , cProcesso, dDtIni, dDtFim , "2" )

		If !Empty( aRetProc )        
         	lRet 	:= .T.
        	dDtStat := aRetProc[01] 
        	cObs    := "Detalhes: Usuário - "+AllTrim(aRetProc[03]) + " Hora - "+AllTrim(aRetProc[02])
        EndIf
/*
	ElseIf cProcesso == "CTBA360"

		lRet := .F.    
		dDtStat := Stod("")
                                                     
		dDtIni := Stod("20170920")
		dDtFim := Stod("")
		
		aRetProc := U_yProcCV8( cFilP , cProcesso, dDtIni, dDtFim , "2" )

		If !Empty( aRetProc )        
         	lRet 	:= .T.
        	dDtStat := aRetProc[01] 
        	cObs    := "Detalhes: Usuário - "+AllTrim(aRetProc[03]) + " Hora - "+AllTrim(aRetProc[02])
        EndIf
*/         
	ElseIf cProcesso == "CTBA010"
                    
		cAnoP := Substr(dTos(dDtRef),1,4)
		cMesP := Substr(dTos(dDtRef),5,2)
		
		If cMesP == "01"
			cAnoP	:= StrZero( ( Val(cAnoP) - 1 ) , 4)	 
			cMesP	:= "12"
		Else
			cMesP	:= StrZero( ( Val(cMesP) - 1 ) , 2)			
		EndIf

//		cMesP := "06"
			
		DbSelectArea("CTG")
		DbSetOrder(4)
		cFilSeek := IIf( Empty(xFilial("CTG")) , xFilial("CTG"),cFilP )
		cKeyCTG  := cFilSeek + cAnoP+ cMesP

		aPeriod  := Separa("1=Aberto;2=Fechado;3=Transportado;4=Bloqueado",";")

        If CTG->( DbSeek( cKeyCTG ))
            nStat := aScan( aPeriod ,{|x| Left(x,1)== CTG->CTG_STATUS })
            If nStat > 0
            	cObs    := "Status: "+aPeriod[nStat]
            EndIf
        	lRet 	:= !( CTG->CTG_STATUS $ "13" )// 1=Aberto;2=Fechado;3=Transportado;4=Bloqueado                                                                                   
        	dDtStat := LastDay(Stod((cAnoP+ cMesP+"01")))

        Else
        	lRet := .F.
        EndIf
	
	Else
			
		lRet := .F.
		dDtStat := Stod(Space(8))
		cObs    := "Verificação de status não definida."        
	EndIf
	
Return( lRet )        
            





/*
{Protheus.doc} ProcCV8 
Retorna um array com o ultimo log executado no periodo proposto

@author Roberto Souza
@since 04/10/2017
@version 1
@Parametros  	nil
         
@Retorno   		aRet     : Log
*/
Static Function ProcCV8( cFilP , cFun, dDtIni, dDtFim , cTipo )
    
    Local cQry 		:= ""             
    Local aRetQry 	:= {}
                                                
	Default cTipo := "*" 
	Default dDtFim:= Stod(Space(8))
                  
	DbSelectArea("CV8")
	DbSetOrder(1)
	cKeyCV8 := cFilP+Padr(cFun,50)+Substr(Dtos(dDtIni),1,6)
	If CV8->(DbSeek( cKeyCV8 ))
		While CV8->(!Eof()) .And. AllTrim(CV8->CV8_PROC) == Alltrim(cFun)
			aRetQry :={ CV8->CV8_DATA,;
						CV8->CV8_HORA,;
						CV8->CV8_USER,;
						CV8->CV8_MSG}
			CV8->(DbSkip())			
		EndDo	
	
	EndIf
	
Return( aRetQry )    





/*
{Protheus.doc} RetProc 
Retorna um array com os processos a serem avaliados
Necessário utilizar em conjunto com a funcao [RetStat]

@author Roberto Souza
@since 04/10/2017
@version 1
@Parametros  	nil
         
@Retorno   		aRet     : Processos
*/
Static Function RetProc()
	Local aRet := {}
  	                        
  	/*|         Funcao  ,   Descricao           , Critico Sim/Nao|*/
	AADD(aRet,{"GPEM120"	,	"Folha de Pagamento"	,"S"})                 
	AADD(aRet,{"MATA280"	,	"Estoque"				,"S"})                 
	AADD(aRet,{"CTBA190"	,	"Reprocessamento"		,"N"})
	//AADD(aRet,{"CTBA360"	,	"Saldos Compostos"		,"N"})
	AADD(aRet,{"CTBA010"	,	"Periodos Contabeis"	,"N"})
//	AADD(aRet,{"PON003","Ponto Eletronico"	,"N"})
 
Return( aRet ) 	
              

           

/*
{Protheus.doc} RetFil 
Retorna um array com as filiais a serem consideradas

@author Roberto Souza
@since 04/10/2017
@version 1
@Parametros  	nil
         
@Retorno   		aRet     : Filiais
*/
Static Function RetFil()
	Local aRet := {} 

	AADD(aRet,"01=Guarulhos")
	//AADD(aRet,"02=Parana") // MOA - Chamado I1811-446 - Farol Protheus
	AADD(aRet,"03=Paraiso")
	AADD(aRet,"04=Rio de Janeiro")
	AADD(aRet,"05=Pernambuco")
	AADD(aRet,"06=Santa Catarina") // MOA - Chamado I1811-446 - Farol Protheus

Return( aRet )	         


/*
{Protheus.doc} Legenda 
Exibe a legenda dos status

@author Roberto Souza
@since 04/10/2017
@version 1
@Parametros  	oObj     : Objeto Pai                                        º
         
@Retorno   		lRet     : Sucesso da gravaçao
*/
Static Function Legenda( oFather )
	Local lRet  := .T.
	Local aColL := {}    
	Local aLinL := {}                                             
	Local aImg  := {008,008}

	Local oLeg01:= TBitmap():New((oFather:NCLIENTHEIGHT/2) - 30,010,aImg[01],aImg[02],GD_OK	,GD_OK	   		,.T.,oFather,{||},,.F.,.t.,,,.F.,,.T.,,.F.)
	Local oLeg02 := TBitmap():New((oFather:NCLIENTHEIGHT/2) - 20,010,aImg[01],aImg[02],GD_WARN,GD_WARN		,.T.,oFather,{||},,.F.,.t.,,,.F.,,.T.,,.F.)
	Local oLeg03 := TBitmap():New((oFather:NCLIENTHEIGHT/2) - 10,010,aImg[01],aImg[02],GD_ERR	,GD_ERR			,.T.,oFather,{||},,.F.,.t.,,,.F.,,.T.,,.F.)

	Local oSay01:= TSay():New((oFather:NCLIENTHEIGHT/2) - 28,022,{||'Finalizado'}				,oFather,,oFont,,,,.T.,CLR_BLUE,CLR_WHITE,,)
	Local oSay02:= TSay():New((oFather:NCLIENTHEIGHT/2) - 18,022,{||'Pendente - Não Critico'}	,oFather,,oFont,,,,.T.,CLR_BLUE,CLR_WHITE,,)				
	Local oSay03:= TSay():New((oFather:NCLIENTHEIGHT/2) - 08,022,{||'Pendente - Critico'}		,oFather,,oFont,,,,.T.,CLR_BLUE,CLR_WHITE,,)				

	oLeg01:lAutoSize := .F.                                                                                                               
 	oLeg02:lAutoSize := .F.                                                                                                               
  	oLeg03:lAutoSize := .F.                                                                                                                  

Return( lRet )



/*
{Protheus.doc} PrtScrn 
Tira Um print da tela

@author Roberto Souza
@since 04/10/2017
@version 1
@Parametros  ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»
			 ºoObj     : Objeto grafico a ser impresso(tWindow)            º
             ºcDirDest : Diretório de destino                              º
             ºcFile    : Arquivo de destino                                º
             ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼
@Retorno   lRet     - Sucesso da gravaçao
*/
Static Function PrtScrn( oObj, cDirDest, cFile )
	Local cFileDest := ""
	Local lRet     	:= .F.

	Default cDirDest:= GetTempPath()
	Default cFile   := "GD_PAN_"+dTos(dMainData)+"_"+StrTran(Time(),":","-")+".bmp"
	
	MakeDir(cDirDest)
	
	cFileDest := StrTran(AllTrim(cDirDest)+AllTrim(cFile),"\\","\")
	
	If oObj:SaveAsBMP( cFileDest )
        lRet := .T.    
	    If MsgNoYes( "Print gravado em : "+cFileDest+CRLF+"Deseja abrir?", "Print" )
			ShellExecute("Open", cFileDest, " /k dir", "C:\", 1 )
		EndIf
	Else
		cFileDest := ""
	EndIf              
	
Return( cFileDest )