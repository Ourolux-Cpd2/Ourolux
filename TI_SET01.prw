#Include "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "TOPCONN.CH"

#DEFINE COMP_DATE "20191209"

#DEFINE ODLG_HINI 0000
#DEFINE ODLG_WINI 0000
#DEFINE ODLG_HEND 0400
#DEFINE ODLG_WEND 0600

#DEFINE POS_TAB		02
#DEFINE POS_IND		03
#DEFINE POS_CPO		04

#DEFINE POS_PROD	01
#DEFINE POS_UM		02

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} TI_SET01
Biblioteca de Ajustes pontuais no Sistema 

@type 		function
@author 	Roberto Souza
@since 		09/02/2017
@version 	P12 
 
@return nil
/*/    
//-------------------------------------------------------------------------------------

User Function TI_SET01()
	MsgAlert("TI_SET01 "+COMP_DATE)
Return


//-------------------------------------------------------------------------------------
/*/{Protheus.doc} SetGrp31
Biblioteca de Ajustes pontuais no Sistema 

@type 		function
@author 	Roberto Souza
@since 		09/02/2017
@version 	P12 
 
@return nil
/*/    
//-------------------------------------------------------------------------------------
User Function SetGrp31()

    RpcSetType(3)
	RpcSetEnv( "01","01",, " ", "FIN",, {"SE1","SE2","SE5"}, , , ,  )		
	
	U_xGrp2Fld( "031" )

Return()



User Function xGrp2Fld( cGrupo )

	Local aCampos	:= {}
	
	DbSelectArea("SXG")
	DbSetOrder(1)
	If DbSeek( cGrupo )
		cDescGrp := SXG->XG_DESCRI
		/*
		SXG->XG_SIZEMAX
		SXG->XG_SIZEMIN
		SXG->XG_SIZE
		*/
		DbSelectArea("SX3")
		SET FILTER TO X3_GRPSXG == cGrupo
		SX3->(DbGoTop())
		
		While SX3->(!Eof())
			If Alltrim(SX3->X3_ARQUIVO) == "SE5"
				nInd := 7 
			Else
				nInd := 1 			
			EndIf		
			AADD( aCampos,{	.F.	,	;
					SX3->X3_ARQUIVO,;
					nInd,;
					SX3->X3_CAMPO,	; 
					SX3->X3_TIPO,	;
					SX3->X3_TAMANHO })
					
			SX3->(DbSkip())
		EndDo
		SET FILTER TO
	EndIf

	ShowArray( "Campos Grupo ["+cGrupo+"]="+cDescGrp, {" ","Alias","Indice","Campo","Tipo","Tamanho"}, {10,25,25,40,25,15}, aCampos, 5 )

Return()



Static Function ShowArray( cTitBrw, aCab, aColSizes, aDados, nSize )
	                                          
	Local lRet 		:= .F.
	Local oOK 		:= LoadBitmap(GetResources(),'br_verde')
	Local oNO 		:= LoadBitmap(GetResources(),'br_vermelho')  
	Local oDlg
	Local oArea		:= FWLayer():New()
	Local aCoord	:= {ODLG_HINI,ODLG_WINI,ODLG_HEND,ODLG_WEND}//FWGetDialogSize(oMainWnd)  
	Local bOk		:= {|| lRet := .T.,oDlg:End() }
	Local bSair		:= {|| lRet := .F.,oDlg:End() }
	Local lNewProc  := .T.
	 
	oDlg := tDialog():New(aCoord[1],aCoord[2],aCoord[3],aCoord[4],cTitBrw,,,,,CLR_BLACK,CLR_WHITE,,,.T.)
	aWindow := {100,000}
	aColumn := {080,020}

	oArea:Init(oDlg,.F., .F. )
	//Mapeamento da area
	oArea:AddLine("L01",100,.T.)

	//ÚÄÄÄÄÄÄÄÄÄ¿
	//³Colunas  ³
	//ÀÄÄÄÄÄÄÄÄÄÙ
	oArea:AddCollumn("L01C01",aColumn[01],.F.,"L01") //dados
	oArea:AddCollumn("L01C02",aColumn[02],.F.,"L01") //botoes

	//ÚÄÄÄÄÄÄÄÄÄ¿
	//³Paineis  ³
	//ÀÄÄÄÄÄÄÄÄÄÙ
 	oArea:AddWindow("L01C01","TEXT","Informações",aWindow[01],.F.,.F.,/*bAction*/,"L01",/*bGotFocus*/)
	oText	:= oArea:GetWinPanel("L01C01","TEXT","L01")
   
 	oArea:AddWindow("L01C02","L01C02P01","Funções",100,.F.,.F.,/*bAction*/,"L01",/*bGotFocus*/)
	oAreaBut := oArea:GetWinPanel("L01C02","L01C02P01","L01")

			
//	DEFINE DIALOG oDlg TITLE cTitBrw FROM 180,180 TO 550,700 PIXEL	    

	
	oBrowse := TWBrowse():New( 01 , 01, 260,184,,aCab,aColSizes,;                              
		oText,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )    
	
	    
	oBrowse:SetArray(aDados)   
	 
	oBrowse:bLine:= {||{If(aDados[oBrowse:nAt,01],oOK,oNo),;
						aDados[oBrowse:nAt,02],;                      
						aDados[oBrowse:nAt,03],;
						aDados[oBrowse:nAt,04],;
						aDados[oBrowse:nAt,05],;
						aDados[oBrowse:nAt,06] } }    
	
	// Troca a imagem no duplo click do mouse    
	oBrowse:bLDblClick := {|| aDados[oBrowse:nAt][1] := !aDados[oBrowse:nAt][1],;                               
	oBrowse:DrawSelect()}  

	oBrowse:Align    	:= CONTROL_ALIGN_ALLCLIENT


	oButt1 := tButton():New(000,000,"&Ok"				,oAreaBut,bOk	,oAreaBut:nClientWidth/2,15,,/*oFont*/,,.T.,,,,/*bWhen*/)
	oButt2 := tButton():New(016,000,"&Sair"				,oAreaBut,bSair	,oAreaBut:nClientWidth/2,15,,/*oFont*/,,.T.,,,,/*bWhen*/)

	oDlg:Activate(,,,.T.,/*valid*/,,/*On Init*/)	
//	ACTIVATE DIALOG oDlg CENTERED 	

	If lRet 
		
        If lNewProc

			oProcess := Nil
			oProcess := MsNewProcess():New({|lEnd| PreProc( @oProcess, aDados) },"Processando","Executando ajustes...",.T.) 
			oProcess:Activate()	
		Else
			PreProc( aDados )
		EndIf	
    EndIf
Return()         



Static Function PreProc( oProcess, aDados )
	Local Nx := 0          
	Default oProcess := Nil

	lProcess := ( oProcess <> Nil )

	If lProcess
   		oProcess:SetRegua1( Len(aDados) )
	EndIf		

	For Nx := 1 To Len( aDados )    
		If aDados[Nx][01]
			If lProcess                       
				oProcess:IncRegua1( "Processando "+aDados[Nx][02]+" ..." )
				GoProc( oProcess, aDados[Nx] )
    		Else
				FWMsgRun(,{|| CursorWait(),	GoProc( Nil ,aDados[Nx] ),CursorArrow()},,"Processando "+aDados[Nx][02]+" ..." )    		
    		EndIf
		EndIf    
	Next
Return
 


Static Function GoProc( oProcess, aInfo , lGrava )
	Local cTab 		:= aInfo[POS_TAB]
    Local nIndProc	:= aInfo[POS_IND]
	Local cFile0    := AllTrim( cTab ) + "xlote.dtc"  
	Local cDir0		:= "\Backup\lote\" 
	Local cDirLog	:= "\Backup\lote\log\" 
	Local cTabNew   := GetNextAlias() //cTab +"XXX"    
	Local nSeek		:= 0
	Local nNoSeek	:= 0   
	Local nLoteOk   := 0 
	Local nLoteAtu	:= 0 
	Local nFldMin	:= 0 
	Local nAll		:= 0
	Local cField	:= AllTrim(aInfo[POS_CPO]) 
	Local lBreak	:= .F. 
    Local nHdl      := fCreate(cDirLog+cFile0+"-"+StrTran(Time(),":","_")+".log")

	Default oProcess := Nil
    Default lGrava  := .T. // Definine se atualiza ou se apenas simula


	lProcess := ( oProcess <> Nil )
		
	fWrite(nHdl, "INICIO : "+dToc(Date())+"-"+Time() +CRLF )

	If File( cDir0 + cFile0 )
	
		// Posiciona a tabela destino
		DbSelectArea(cTab) 
		
		If Select( cTab ) > 0
		
			DbSetOrder(nIndProc)  		
		
			cIndKey := IndexKey()
	
			fWrite(nHdl, "Indice : "+cValToChar(nIndProc)+"-"+cIndKey +CRLF )
			
			lTab := DBUseArea( .T. , "CTREECDX", cDir0 + cFile0, cTabNew, .F., .F. )
	
			DbSelectArea(cTabNew)      
			
			If lProcess  
	
				nContNew := (cTabNew)->(RecCount()) 
	   			oProcess:SetRegua2( nContNew )
	   			cContNew := StrZero(nContNew,7)

			EndIf
			
			While (cTabNew)->(!Eof()) .And. !lBreak
				cKey 		:= (cTabNew)->&(cIndKey)
				cNewInfo 	:= (cTabNew)->&(cField)   
				nAll++
				
				If lProcess 
					cRegua2 := "Registros "+StrZero(nAll,7)+" de "+cContNew+"." 
		   			oProcess:IncRegua2( cRegua2 )
				EndIf
			
				If Len(AllTrim(cNewInfo)) > 4 
	
					DbSelectArea(cTab) 			
		
					If DbSeek(cKey)
				    	nSeek++ 
						cLoteAtu := AllTrim((cTab)->&(cField))
						
						If Len(cLoteAtu) > 4
							nLoteOk++
						Else 
							If lGrava
	
						    	RecLock(cTab,.F.)
								(cTab)->&(cField) := cNewInfo
						    	MsUnlock()
	
								cStat := "Atualizado"
							Else
								cStat := "Simulado"						
							EndIf
							
							cKeySet :=  cTab+";"+;
										cKey+";"+;
										cLoteAtu+";"+;
										cNewInfo+";"+;
										cValToChar((cTab)->(Recno()))+";"+;
										cStat
										
						    fWrite(nHdl, cKeySet + CRLF)
	
							nLoteAtu++
						EndIf
		
				    Else
				    	nNoSeek++	
					EndIf
				Else
					nFldMin++
				EndIf
				(cTabNew)->(DbSkip())		
			EndDo
			DbSelectArea(cTabNew)
			(cTabNew)->(DbCloseArea())
		Else
			fWrite(nHdl, "Não foi possível a abertura do arquivo: "+cTab +CRLF)				
		EndIf
	Else
//		U_MyAviso("Atenção","Arquivo não encontrado: "+cDir0 + cFile0,{"ok"},3)
		fWrite(nHdl, "Arquivo não encontrado: "+cDir0 + cFile0 +CRLF)		
	EndIf    


	cInfoRes := CRLF+Replicate("#",40)+CRLF
	cInfoRes += "Encontrados: "+StrZero(nSeek,10)+CRLF
	cInfoRes += "Nao Encontrados: "+StrZero(nNoSeek,10)+CRLF
	cInfoRes += "Lotes OK: "+StrZero(nLoteOk,10)+CRLF
	cInfoRes += "Lotes Atualizados: "+StrZero(nLoteAtu,10)+CRLF
	cInfoRes += "Lotes Nao Atualizados: "+StrZero(nFldMin,10)+CRLF
	cInfoRes += Replicate("#",40)+CRLF	
	
	fWrite(nHdl, cInfoRes )
	fWrite(nHdl, "FIM : "+dToc(Date())+"-"+Time() +CRLF)
    fClose(nHdl)

//	U_MyAviso(cTabNew,cInfoRes,{"Ok"},3)    

Return 





//-------------------------------------------------------------------------------------
/*/{Protheus.doc} SetGrp31
Biblioteca de Ajustes pontuais no Sistema 

@type 		function
@author 	Roberto Souza
@since 		09/02/2017
@version 	P12 
 
@return nil
/*/    
//-------------------------------------------------------------------------------------

User Function SetSB1X()   
    
	RpcSetEnv("01","01")
	RpcSetType(3)
	Processa( {|| U_XSB1X() }, "Aguarde...", "Lendo arquivo CSV...",.F.)	

Return


User Function XSB1X()

	Local lRet 		:= .T.
	Local cFileCSV 	:= "C:\Totvs\sb1\sb1.csv"             
	Local cFileNF 	:= "C:\Totvs\Source\Projeto\XLS\titulos_260417.log"             
    Local nLinha    := 0
	Local nFound    := 0
   	Local nNoFound  := 0
   	Local nRegOk	:= 0
	Local cFilProc 	:= xFilial("SB1") 
	Local nMod      := 2//2  1-Primeiro formato 2-Segundo Formato                             
	Local cNotFound := ""    
	Local lSimula   := .T.


	DbSelectArea("SB1")
	DbSetOrder(1)

	If nMod == 1	    
		FT_FUse(cFileCSV)
		ProcRegua(FT_FLastRec())
		FT_FGoTop()
		// Pula o cabeçalho
		FT_FSkip()
		
		While !FT_FEof()
			IncProc("Lendo Arquivo...")
			nLinha++
			aLinha    := {}
			
			aLinha := Separa( FT_FReadLn(),";",.T.)
			cCod := Padr(Substr( aLinha[01],01,06),6)
			cLoja:= Padr(Substr( aLinha[01],08,02),2)
			cPref:= Padr(Substr( aLinha[02],01,03),3)
			cNum :=	Padr(Substr( aLinha[02],05,09),9)
			cParc:=	Padr(Substr( aLinha[02],15,01),1)
			cTipo:= Padr(Substr( aLinha[03],01,03),3)
	//		AAdd(aConteudo,AClone(aLinha))
	
			If SE1->(DbSeek(cFilProc+cCod+cLoja+cPref+cNum+cParc+cTipo))        
				nFound++ 
				RecLock("SE1",.F.)
				SE1->E1_XARQMOR := "001"
				MsUnlock()	                               
			Else
				nNoFound++			
			EndIf
			FT_FSkip()
		Enddo
	ElseIf	nMod == 2
		FT_FUse(cFileCSV)
//		ProcRegua(FT_FLastRec())
		FT_FGoTop()

		aCabec := Separa( FT_FReadLn(),";",.T.)

		FT_FSkip()
		
		While !FT_FEof()
			IncProc("Lendo Arquivo...")
			nLinha++
			aLinha    := {}
			
			aLinha 	:= Separa( FT_FReadLn(),";",.T.)
	        lFound := .F.

			If SB1->(DbSeek(cFilProc+cCod))        
				nFound++ 
		        lFound := .T.
			Else
				nNoFound++	 
				cNotFound += cFilProc+";"+cCod+CRLF
			EndIf 
			
			If lFound
			
				If lSimula 
					nRegOk++
				Else
					RecLock("SB1",.F.)
					SB1->B1_UM := aLinha[POS_UM]
					MsUnlock()	                               
				EndIf
			EndIf
			FT_FSkip()
		Enddo	
	
	EndIf	 
                   
	MsgAlert("Linhas: "+StrZero(nLinha,10) +CRLF+; 
			"Encontrados: "+StrZero(nFound,10) +CRLF+ ; 
			"Não Encontrados: "+StrZero(nNoFound,10) )
	
	Memowrite(cFileNF,cNotFound)
Return( lRet )