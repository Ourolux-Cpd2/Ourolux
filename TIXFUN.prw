#INCLUDE "PROTHEUS.CH" 

#DEFINE COMP_DATE "20/09/2017"


//-------------------------------------------------------------------------------------
/*/{Protheus.doc} TIXFUN
Biblioteca de validacoes genericas

@type 		function
@author 	Roberto Souza
@since 		15/03/2017
@version 	P11 
 
@return nil
/*/    
//-------------------------------------------------------------------------------------
User Function TIXFUN()
	Local cInfo := 	"TIXFUN-"+COMP_DATE
Return( cInfo )  


User Function xMovFile( cOrig, cDest , cErro, cWarning )
	Local lRet 		:= .F.
	Local cBuffer   := ""                     
	
    Default cErro   := "" 
    Default cWarning:= "" 
    
    If File(cOrig)
		cBuffer	:= MemoRead( cOrig )
		MemoWtite( cDest,cBuffer )
		
	    nOk := FErase( cOrig )
	    
	    If nOk <> 0
	    	cWarning := FError() 
	    EndIf	
    Else
		cErro := "Arquivo de origem ["+AllTrim(cOrig)+"] não existe."
    EndIf
Return( lRet )          


//-------------------------------------------------------------------------------------
/*/{Protheus.doc} xListEml
Retorna lista de distribuição de e-mail.

@type 		function
@author 	Roberto Souza
@since 		24/04/2017
@version 	P11 
 
@return nil
/*/    
//-------------------------------------------------------------------------------------
User Function xListEml( cFuncW, nModo )
	Local cRet := ""          
	Local cTab := "U101"
		
	Default nModo := 1

	DbSelectArea("TP0")
	DbSetOrder(3)    
	
	If DbSeek( xFilial("TP0") + cFuncW )
		
		While TP0->(!Eof()) .And. Alltrim(cFuncW) == AllTrim(TP0->TP0_CODPRO)
			aInfo := {}	                   
			aStru := {}
			U_xRByTab( @aInfo , cTab , , @aStru )
			nPosI := 8
			For Nx := 1 To Len( aInfo )
				cRet += Lower(AllTrim(aInfo[Nx][nPosI]))+";" 				
			Next
			TP0->(DbSkip())			                                                                    
		EndDo
	EndIf
	cRet := "cpd3@ourolux.com.br"
Return( cRet )     

    


/*
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡„o    ³fCarTab(aTabelas)³Autor³Mauro Sergio       ³Data ³21/07/2002³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡„o ³Carregar Tabelas no array para calculo                      ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Sintaxe   ³fCarTab( aTabelas )		       								³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Uso      ³Calculo Gpexcal1 Gpexcalc                                   ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Retorno  ³       														³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³aTabelas -> Array com a carga da tabela       				³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
User Function xRByTab( aTab_Fol, cTab, dDataRef, aStru )

Local aCabTab 	:= {}
Local cFilRcc	:= "" //Determina Filial Pesquisa Rcc
Local nPosIni	:= 0
Local nColAte	:= 0
Local nTamCpo 	:= 0
Local nDecCpo 	:= 0
Local cConteudo	:= ""
Local nT 		:= 0

Default aStru := {}

//--Determina Filial de Busca da tabela RCB
dbSelectArea("RCB")
cFilRcb := If (Empty(cFilial), cFilial, xFilial("RCB"))

//--Determina Filial Pesquisa RCC
dbSelectArea("RCC")
cFilRcc := If (Empty(cFilial), cFilial, xFilial("RCC"))

//--Determina Data a ser Carregada
dDataRef := If (dDataRef == Nil, dDataBase,dDataRef)

//--Pocisiona no Primeiro Elemento do Cabecalho da Tabela
dbSelectArea("RCB")
dbSeek(cFilRcb+cTab,.T.)
While ! Eof() 

	If cTab # RCB->RCB_CODIGO
		Exit
	Endif

	//--Carrega o Cabecalho da Tabela 
	aCabTab := {}
	While ! Eof() .And. cTab == RCB->RCB_CODIGO 

		RCB->(Aadd(aCabTab,{RCB_CAMPOS,RCB_TIPO,RCB_TAMAN,RCB_DECIMA}))
		dbSelectArea("RCB") 
		dbSkip()
	Enddo				
 	aStru := aCabTab
	//--Carregar Dados das Tabelas 
	dbSelectArea("RCC")
	dbSeek(cFilRcc+cTab,.T.)
	While ! Eof() .And. RCC->RCC_FILIAL+RCC->RCC_CODIGO == cFilRcc+cTab
	
		If Empty(RCC->RCC_CHAVE) .Or. MesAno(dDataRef) == RCC->RCC_CHAVE

	 		Aadd(aTab_Fol,{cTab,RCC->RCC_FIL,RCC->RCC_CHAVE,RCC->RCC_SEQUEN})
	                                             
			nPosIni := 1
			nColAte := 1
			For nT:= 1 To Len(aCabTab) 
                                         
				//--Tamanho do Campo                                          	                
				nTamCpo := aCabTab[nT,3]
				nDecCpo := aCabTab[nT,4]
				
				//--Guarda conteudo do campo na Variavel 				
				If aCabTab[nT,2] == "C"
					cConteudo := Subs(RCC->RCC_CONTEU,nPosIni,nTamCpo)
				ElseIf aCabTab[nT,2] == "N"
					cConteudo := Val(Subs(RCC->RCC_CONTEU,nPosIni,nTamCpo+nDecCpo))
				ElseIf aCabTab[nT,2] == "D"
					cConteudo := Subs(RCC->RCC_CONTEU,nPosIni,nTamCpo)
					cConteudo := If("/" $ cConteudo , CtoD(cConteudo) , StoD(cConteudo))
				Endif             

		 		Aadd(aTab_Fol[Len(aTab_Fol)],cConteudo)
				       
				//--Posicao Proximo Campo
				nPosIni += nTamCpo
					
			Next nT		  
			
		Endif	
		dbSelectArea("RCC")
		dbSkip()
	Enddo	
    
	dbSelectArea("RCB")
	dbSkip()
Enddo	
Return                             




User Function xVerXml() 
	Local cDirOrig 	:= "C:\totvs\Colab\Xml\"  
	
//	FWMsgRun(,{|| CursorWait(),ProcVerXml( cDirOrig ),CursorArrow()},,"Processando Arquivos..." )    
	ProcVerXml( cDirOrig )
		
Return
     


Static Function ProcVerXml( cDirOrig )

	Local lRet 		:= .T.
      
	Local cDirSource:= cDirOrig+"\xmlsource\"  
	Local cDirErro	:= cDirOrig+"\erro\"  

	Local aFiles	:= ""
	Local Nx		:= ""
	Local nFiles	:= 0
	
	aFiles 	:= Directory(cDirSource+"*.xml","D",,,2)
	nFiles	:= Len( aFiles )
		                      
	Makedir( cDirErro )	
	Makedir( cDirOrig+"NF-e\" )		
	Makedir( cDirOrig+"NF-e\2.00" )		
	Makedir( cDirOrig+"NF-e\3.10" )		
	Makedir( cDirOrig+"NF-e\9.99" )	
	Makedir( cDirOrig+"CT-e\" )		
	Makedir( cDirOrig+"CT-e\2.00" )		
	Makedir( cDirOrig+"CT-e\3.00" )		
	Makedir( cDirOrig+"CT-e\9.99" )		
	Makedir( cDirOrig+"Proc\" )		
	Makedir( cDirOrig+"Outros" )
		
	For Nx := 1 To nFiles         
		cFileInfo := ""
		// Verifica se o arquivo é muito grande para usar MemoRead
		If aFiles[Nx][2] > 60000
			cFileInfo	:= MyReadF(cDirSource + aFiles[Nx][1])  		
		Else			
			cFileInfo	:= MemoRead(cDirSource + aFiles[Nx][1])  
		EndIf
		cBuffer 	:= Upper( cFileInfo )
		cVerXml		:= ""
		
		If Empty( cBuffer )
	  		If MemoWrite( cDirErro + aFiles[Nx][1], cBuffer ) .And. ;
	  			MemoWrite( cDirOrig+"Proc\" + aFiles[Nx][1], cFileInfo )
	  		     
	  			fErase( cDirSource + aFiles[Nx][1])
	  		EndIf	
		Else
			If AT( "<NFEPROC", cBuffer ) > 0

			    cTipoX  := "NF-e"
				nPosV1 	:= AT( "VERSAO=", cBuffer ) 
				If nPosV1 > 0
				    cVerXml 	:= Substr(cBuffer,nPosV1+8,4)
				Else
					cVerXml 	:= "9.99"
				EndIf	

				If cVerXml == "3.00"
					Conout("CTE=3.00") 	
				EndIf				
						    
		    ElseIf AT( "<CTEPROC", cBuffer ) > 0 

			    cTipoX  := "CT-e"
				nPosV1 	:= AT( "VERSAO=", cBuffer )
				If nPosV1 > 0
				    cVerXml 	:= Substr(cBuffer,nPosV1+8,4)
				Else
					cVerXml 	:= "9.99"
				EndIf  
				
				If cVerXml == "3.00"
					Conout("CTE=3.00") 	
				EndIf
							    
			Else

			    cTipoX  := "Outros"
				nPosV1 	:= 0
			    //cVer 	:= ""
		    
		    EndIf
		
		    cDirdest := cDirOrig+"\" +cTipoX+"\"+cVerXml+"\" 
		    Makedir( cDirdest )

	  		If MemoWrite( cDirDest + aFiles[Nx][1], cFileInfo ) .And. ;
	  			MemoWrite( cDirOrig+"Proc\" + aFiles[Nx][1], cFileInfo )
	  		     
	  			nRet := fErase( cDirSource + aFiles[Nx][1])
	  			If nRet < 0
	  				Alert(FError())    
	  			EndIf	
	  		
	  		EndIf		
						
		EndIf	
	

	Next                                
	
  	Alert(nFiles)

Return( lRet )

Static Function MyReadF( cFile )
	Local cRet 		:= ""             
	Local nHandle 	:= 0
	Local nBytes	:= 512000   
	Local cBuffer	:= Space(nBytes) 

	nHandle := fopen( cFile )  
	nBuffer := fRead( nHandle , @cBuffer, nBytes) 
	fclose(nHandle)

Return( cBuffer )     



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³O_Aviso   ºAutor  ³Roberto Souza       º Data ³  01/01/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Interface/Dialog de Aviso.                                 º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Geral                                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function MyAviso( cCaption, cMensagem, aBotoes, nSize, cCaption2, nRotAutDefault, cBitmap, lEdit, nTimer, nOpcPadrao, lAuto )
	Local ny        	:= 0
	Local nx        	:= 0
	Local nLinha    	:= 0
	Local cMsgButton	:= ""
	Local oGet 
	Local nPass 		:= 0
	Local nAltBt		:= 13
	Local cImgSide		:= "login_s.png"
	Local aSize  		:= {	{134,304,35,155,35,113,51},; // Tamanho 1
								{134,450,35,155,35,185,51},; // Tamanho 2
								{227,450,35,210,65,185,99} } // Tamanho 3
	Private oDlgAviso
	Private nOpcAviso := 0

	Default lEdit 		:= .F.
	
	If lEdit
		nSize 		:= 3
	EndIf

	If nSize == 3
		cImgSide	:= "login_m.png"
	EndIf
	
	lMsHelpAuto := .F.
	
	cCaption2 := Iif(cCaption2 == Nil, cCaption, cCaption2)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Quando for rotina automatica, envia o aviso ao Log.          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Type('lMsHelpAuto') == 'U'
		lMsHelpAuto := .F.
	EndIf
	
	If !lMsHelpAuto
		If nSize == Nil
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica o numero de botoes Max. 5 e o tamanho da Msg.       ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If  Len(aBotoes) > 3
				If Len(cMensagem) > 286
					nSize := 3
				Else
					nSize := 2
				EndIf
			Else
				Do Case
					Case Len(cMensagem) > 170 .And. Len(cMensagem) < 250
						nSize := 2
					Case Len(cMensagem) >= 250
						nSize := 3
					OtherWise
						nSize := 1
				EndCase
			EndIf
		EndIf
		If nSize <= 3
			nLinha := nSize
		Else
			nLinha := 3
		EndIf

		oDlgAviso := tDialog():New(0,0,aSize[nLinha][1],aSize[nLinha][2],cCaption,,,,,CLR_BLACK,CLR_WHITE,,,.T.)

		DEFINE FONT oBold NAME "Arial" SIZE 0, -13 BOLD

		oTBitmap := TBitmap():New(0, 0, aSize[nSize][3], aSize[nSize][4], cImgSide, cImgSide, .T., oDlgAviso,{|| }, NIL, .F., .F., NIL, NIL, .F., NIL, .T., NIL, .F.)

		@ 11 ,35  TO 13 ,300 LABEL '' OF oDlgAviso PIXEL

		
		If cBitmap <> Nil
			@ 002, 037 BITMAP RESNAME cBitmap oF oDlgAviso SIZE 18,18 NOBORDER WHEN .F. PIXEL
			@ 003, 050 SAY cCaption2 Of oDlgAviso PIXEL SIZE 130 ,9 FONT oBold
		Else
			@ 003, 037  SAY cCaption2 Of oDlgAviso PIXEL SIZE 130 ,9 FONT oBold
		EndIf
		If nSize < 3
			@ 016, 038  SAY cMensagem Of oDlgAviso PIXEL SIZE aSize[nLinha][6],aSize[nLinha][5]
		Else
			If !lEdit
				@ 016 ,038  GET oGet VAR cMensagem Of oDlgAviso PIXEL SIZE aSize[nLinha][6],aSize[nLinha][5] READONLY MEMO
			Else
				@ 016 ,038  GET oGet VAR cMensagem Of oDlgAviso PIXEL SIZE aSize[nLinha][6],aSize[nLinha][5] MEMO
			EndIf
			
		EndIf
		If Len(aBotoes) > 1 .Or. nTimer <> Nil
			TButton():New(1000,1000," ",oDlgAviso,{||Nil},32,nAltBt,,oDlgAviso:oFont,.F.,.T.,.F.,,.F.,,,.F.)
		EndIf
		ny := (aSize[nLinha][2]/2)-36
		For nx:=1 to Len(aBotoes)
			cAction:="{||nOpcAviso:="+Str(Len(aBotoes)-nx+1)+",oDlgAviso:End()}"
			bAction:=&(cAction)
			cMsgButton:= OemToAnsi(AllTrim(aBotoes[Len(aBotoes)-nx+1]))
			cMsgButton:= IF(  "&" $ Alltrim(cMsgButton), cMsgButton ,  "&"+cMsgButton )
			TButton():New(aSize[nLinha][7],ny,cMsgButton, oDlgAviso,bAction,32,nAltBt,,oDlgAviso:oFont,.F.,.T.,.F.,,.F.,,,.F.)
			ny -= 35
		Next nx
		If nTimer <> Nil
			oTimer := TTimer():New(nTimer,{|| nOpcAviso := nOpcPadrao,IIf(nPass==0,nPass++,oDlgAviso:End()) },oDlgAviso)
			oTimer:Activate()       
			bAction:= {|| oTimer:DeActivate() }
			TButton():New(aSize[nLinha][7],ny,"Timer off", oDlgAviso,bAction,32,nAltBt,,oDlgAviso:oFont,.F.,.T.,.F.,,.F.,,,.F.)
		Endif
		oDlgAviso:Activate(,,,.T.,/*valid*/,,/*On Init*/)		
	Else
		If ValType(nRotAutDefault) == "N" .And. nRotAutDefault <= Len(aBotoes)
			cMensagem += " " + aBotoes[nRotAutDefault]
			nOpcAviso := nRotAutDefault
		Endif
		ConOut(Repl("*",40))
		ConOut(cCaption)
		ConOut(cMensagem)
		ConOut(Repl("*",40))
		AutoGrLog(cCaption)
		AutoGrLog(cMensagem)
	EndIf

Return( nOpcAviso )