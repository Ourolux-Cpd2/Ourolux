#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#include "Fileio.ch"
#INCLUDE "FWPrintSetup.ch" 
#INCLUDE "rwmake.ch" 

**********************
User Function RECHUM()
********************** 
Local oDlg2 := {}     
Local cTitulo := "Recurso Humano"   
Local aSize   := MsAdvSize()  
Local aObjects := {}
Local aInfo	   := {}
Local aPosObj  := {} 
Local aItensRH := {}  
Local aHList   := {} 
Local aRecnoRh := {}
Local nOpca    := 0	
Local cRecHum  := Space(06)
Local cCarga2
Local cCarga   	:= SDB->DB_CARGA
Local cDoc      := SDB->DB_DOC
Local cSerie    := SDB->DB_SERIE
Local cOrigem   := SDB->DB_ORIGEM
Local cCliFor   := SDB->DB_CLIFOR 
Local cLoja     := SDB->DB_LOJA    
Local cDoc2   	
Local cServic  	:= SDB->DB_SERVIC
Local cAtiv    	:= SDB->DB_ATIVID
Local cDesSer     
Local oOk 		:= LoadBitmap( GetResources(), "LBOK")
Local oNo 		:= LoadBitmap( GetResources(), "LBNO") 
Local cSt 		:= "4"    
Local lMark      := .T.

Private oFont  	:= TFont():New("Arial",,,,.T.,,,,,)    
Private cTitulo := "Recurso Humano"
Private oDlg := {}
Private cGet1     
Private cGet2
Private cGet3
Private cGet4
Private cGet5
Private oGet7 
Private oGet8
Private oGet9
Private oGet10 
Private oGet11   
Private oGet12
Private oListBox 

		cQuery := " SELECT R_E_C_N_O_,DB_TAREFA, DB_ATIVID, DB_RECHUM, DB_LOCAL, DB_LOCALIZ, DB_ENDDES, DB_DOC, "
		cQuery += " DB_PRODUTO, DB_RECHUM,DB_RHFUNC, DB_QUANT, DB_STATUS " 
		cQuery += " FROM "+RETSQLNAME("SDB")+" SDB " 
		cQuery += " WHERE DB_FILIAL = '"+xFilial("SDB")+"' AND DB_SERVIC = '"+cServic+"' AND DB_ESTORNO = '' "
		cQuery += " AND SDB.DB_ATUEST  = 'N'"
		cQuery += " AND SDB.D_E_L_E_T_ = '' "  
	    cQuery += "	AND DB_STATUS IN ('4','2') "
	    If	Empty(cCarga)
	    	cQuery += "	AND DB_DOC = '"+cDoc+"' "
	    	If cOrigem <> "SC9"
				cQuery += " AND DB_SERIE = '"+cSerie+"'"
			EndIf
			cQuery += " AND DB_CLIFOR  = '"+cCliFor+"'"
			cQuery += " AND DB_LOJA    = '"+cLoja+"'"
	    Else
	    	cQuery += "	AND DB_CARGA = '"+cCarga+"' "
	    EndIf
	    cQuery += " ORDER BY DB_LOCALIZ,DB_ENDDES,R_E_C_N_O_ "
		
		 TCQUERY cQuery ALIAS "cSDB" NEW   
		 
		 While !EOF("cSDB")
		    
	   		// --- Somente para Status: com problemas / a executar	   		
		   	AAdd(aRecnoRh,{cSDB->R_E_C_N_O_})
			//-- Array ListBox
			AAdd(aItensRh,{.F.,(cSDB->DB_TAREFA + " - " + Tabela("L2", cSDB->DB_TAREFA, .F.)),;
			                   (cSDB->DB_ATIVID + " - " + Tabela("L3", cSDB->DB_ATIVID, .F.)),;
			                   cSDB->DB_RECHUM,;
			                   cSDB->DB_LOCAL,;
			                   cSDB->DB_LOCALIZ,;
			                   cSDB->DB_ENDDES,;
			                   cSDB->DB_DOC,;
			                   cSDB->DB_PRODUTO,;
			                   Posicione("SB1",1,xFilial("SB1")+cSDB->DB_PRODUTO,"B1_DESC"),;
			                   (cSDB->DB_RHFUNC + " - " + Posicione("SRJ",1,xFilial("SRJ")+cSDB->DB_RHFUNC,"RJ_DESC")),;
			                   cSDB->DB_QUANT } )
			 
	 		
   		cSDB->(DbSkip())
   		EndDo     
   		
   		cSDB->(DbCloseArea())
   		       
   		IF Empty(aItensRH)
   			AAdd( aItensRH ,{ .F., "","","","","","","","","","",""})
   		Endif
   		
		AAdd(aObjects, {100, 085, .T., .F.})
		AAdd(aObjects, {100, 60, .T., .F.})
		aInfo   := {aSize[1], aSize[2], aSize[3], aSize[4], 0, 0}
		aPosObj := MsObjSize(aInfo, aObjects) 
		
		DEFINE MSDIALOG oDlg2 TITLE cTitulo From aSize[7],00 TO aSize[6],aSize[5] OF oMainWnd PIXEL
		@ aPosObj[1,1], aPosObj[1,2] TO aPosObj[1,3], aPosObj[1,4] LABEL cTitulo OF oDlg2 PIXEL
		
		If	Empty(cCarga)
			cDoc2 := cCarga
			@ 42,  12 SAY "Documento" PIXEL
			@ 42,  50 MSGET oGet8 VAR cDoc2 PIXEL WHEN .F.
		Else     
			cCarga2 := cCarga
			@ 42,  12 SAY "Carga" PIXEL
			@ 42,  50 MSGET oGet9 VAR cCarga2 PIXEL WHEN .F.
		EndIf 
		
		If Empty(cCarga)
			cDesSer := "Endereçamento" 
		Else
			cDesSer := "Separação"
		EndIf
		
		
		@ 57,  12 SAY "Serviço" PIXEL
		@ 57,  50 MSGET oGet10 VAR cServic PIXEL WHEN .F.
		@ 57,  75 MSGET oGet11 VAR cDesSer PIXEL WHEN .F.      
		
		@ 72,  12 SAY "Rec.Hum.novo:" PIXEL 
		@ 72,  50 MSGET oGet7 VAR cRecHum PIXEL F3 "DCD1"  
		
		AAdd( aHList, " ")
		AAdd( aHList, "Tarefa")
		AAdd( aHList, "Atividade")
		AAdd( aHList, "Rec. Hum.")
		AAdd( aHList, "Armazem" )
		AAdd( aHList, "Endereço Ori.")
		AAdd( aHList, "Endereço Des.")
		AAdd( aHList, "Documento")
		AAdd( aHList, "Produto")
		AAdd( aHList, "Descrição")
		AAdd( aHList, "Função")
		AAdd( aHList, "Quantidade")   	
	 
 
		
		oListBox := TWBrowse():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,4],aPosObj[2,3],,aHList,,oDlg2,,,,,,,,,,,,, "ARRAY", .T. )
		oListBox:SetArray(aItensRh)
		oListBox:bLine := { || {If(aItensRH[oListBox:nAT,1]==.T.,oOk,oNo), ;
			aItensRH[oListBox:nAT,2],;
			aItensRH[oListBox:nAT,3],;
			aItensRH[oListBox:nAT,4],;
			aItensRH[oListBox:nAT,5],;
			aItensRH[oListBox:nAT,6],;
			aItensRH[oListBox:nAT,7],;
			aItensRH[oListBox:nAT,8],;
			aItensRH[oListBox:nAT,9],;
			aItensRH[oListBox:nAT,10],;
			aItensRH[oListBox:nAT,11],;
			aItensRH[oListBox:nAT,12]}}
		oListBox:bLDblClick := { || (aItensRh[oListBox:nAt,1]:=!aItensRh[oListBox:nAt,1],oListBox:Refresh())}
		oListBox:bHeaderClick := { |oObj,nCol| IIF(nCol==1,WmsMrk(@oListBox,@aItensRH,@lMark),Nil) }
                                                      
		ACTIVATE MSDIALOG oDlg2 ON INIT EnchoiceBar(oDlg2,{|| nOpca := 2,oDlg2:End()},{|| nOpca := 1,oDlg2:End()}) CENTERED  
		
		If	nOpca == 2
			For nX := 1 To Len(aItensRh)
				If	aItensRh[nX,1]
					SDB->(dbGoto(aRecnoRh[nX][1]))
					If	SDB->(!EOF() .And. ;
						 DB_RECHUM <> cRecHum .And. ;
						 DB_ESTORNO== ' ' .And. ;
						 DB_ATUEST == 'N' .And. ;
						(DB_STATUS == '2' .Or. ;
						 DB_STATUS == '4' ))
						DCI->(DbSetOrder(2))
						If	Empty(cRecHum) .Or. DCI->(dbSeek( xFilial('DCI')+cRecHum+SDB->DB_RHFUNC,.T.))
							RecLock('SDB',.F.)
								SDB->DB_RECHUM := cRecHum 
							MsUnLock()
						EndIf
					EndIf
				EndIf
			Next
		EndIf
Return            
 
*************************************************
Static Function WmsMrk(oListBox, aItensRh, lMark)
*************************************************
Local nX
For nX := 1 To Len(aItensRh)
	aItensRh[nX, 1] := lMark
Next
lMark := !lMark
oListBox:Refresh()

Return( Nil ) 

