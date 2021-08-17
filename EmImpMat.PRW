#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "RPTDEF.CH"  
#INCLUDE "FWPrintSetup.ch"

#DEFINE MAXITEM   020                                                // Máximo de produtos para a primeira
#DEFINE MAXITEMC  046                                                // Máxima de caracteres por linha de produtos/serviços  
#DEFINE MAXMSGL   008												  // Máximo de Linhas de mensagens
#DEFINE MAXMENLIN 154                                                // Máximo de caracteres por linha de dados adicionais
#DEFINE MAXDUP    230                                                // Máximo de dados na duplicatas

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ EmImpMat	  ºAutor  ³Wilson A. Silva Jr. º Data ³ 05/26/10  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Impressao DANFE para impressoras matriciais.               º±±
±±º          ³                                							  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ ELETROMEGA                                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
User Function EmImpMat(cIdEnt)
    
	Local aArea		:= GetArea()
	Local lExistNfe := .F.
	 
	Local aOrd		:= {}
	Local cDesc1 	:= PADC("Este programa ira emitir a Nota Fiscal de Entrada/Saida",74)
	Local cDesc2 	:= PADC("da Nfiscal",74)
	Local cDesc3 	:= ""
	Local cPict     := ""
	Local cTitulo 	:= PADC("DANFE - DOCUMENTO AUXILIAR DA NOTA FISCAL ELETRÔNICA",74)
	Local Cabec1    := ""
	Local Cabec2    := ""
	Local Cabec3    := ""
	Local lImprime  := .T.
		
	Private nLin      	:= 0
	Private CbTxt       := ""
	Private Lend        := .F.
	Private lAbortPrint := .F.
	Private limite     	:= 80
	Private Tamanho    	:= "M"
	Private nomeprog	:="PrtNfeSef"
	Private nTipo      	:= 18
	Private aReturn 	:= {"Especial",1,"Administracao",1,1,1,"",1}
	Private nLastKey   	:= 0
	Private cPerg 		:= PadR("NFSIGW",10)
	Private cbcont     	:= 00
	Private CONTFL     	:= 01
	Private m_pag      	:= 01
	Private wnrel    	:= "NFDANFE"
	Private cString		:= "SF2"
	Private	aL			:= {}
	Private aClassFis	:= {}
	
	dbSelectArea(cString)
	dbSetOrder(1)
	
	//AjustaSx1()
	
	Pergunte(cPerg,.F.)
	
	wnrel := SetPrint(cString,NomeProg,cPerg,@cTitulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,.T.,Tamanho,,.F.)
	
	If nLastKey == 27
	   Return
	Endif
	
	SetDefault(aReturn,cString)
	
	If nLastKey == 27
	   Return
	Endif
	
	RptStatus({|lEnd| DanfeProc(@lEnd,cIdEnt,@lExistNfe)},"Imprimindo Danfe...")
	
	//Inicio customizado
	If (cFilAnt == '01' .AND. MV_PAR03 <> '5  ') .Or.;
	    (cFilAnt == '02' .AND. !(MV_PAR03 $ '4  .900')) //(cFilAnt == '02' .AND. MV_PAR03 <> '4  ')
	 		Set Device To Screen
	      	ApMsgStop( 'Serie da Nota Fiscal errada. Digite a serie correta!', 'ATENÇÃO' )
	      	Return
	EndIf
	//Fim customizado
	
	If lExistNfe
		//oDanfe:Preview()//Visualiza antes de imprimir
	Else
		Aviso("DANFE","Nenhuma NF-e a ser impressa nos parametros utilizados.",{"OK"},3)
	EndIf
	
	
	SetPrc(0,0)
	__Eject()      // war 15-05-2013
	
	Set Device To Screen 
	Set Printer To // war 15-05-2013
	
	If aReturn[5] == 1
		Set Printer To
		dbcommitAll()
		ourspool(wnrel)
	Endif
	
	MS_FLUSH()
	
	RestArea(aArea)

Return .T.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³DANFEProc ³ Autor ³ Eduardo Riera         ³ Data ³16.11.2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Rdmake de exemplo para impressão da DANFE. 				  ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                    										  ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function DanfeProc(lEnd,cIdEnt,lExistNfe)

	Local aArea      := GetArea()
	Local aNotas     := {}
	Local aXML       := {}
	Local aAutoriza  := {}
	Local cNaoAut    := ""
	
	Local cAliasSF3  := "SF3"
	Local cWhere     := ""
	Local cAviso     := ""
	Local cErro      := ""
	Local cAutoriza  := ""
	Local cModalidade:= "" 
	Local cChaveSFT  := ""
	Local cAliasSFT  := "SFT" 
	Local cCondicao	 := ""
	Local cIndex	 := ""
	Local cChave	 := ""
	
	Local lQuery     := .F.
	
	Local nX         := 0
	Local nI		 := 0
	
	Local oNfe 
	Local nLenNotas
	Local lImpDir	 :=GetNewPar("MV_IMPDIR",.F.)
	Local nLenarray	 := 0
	Local nCursor	 := 0
	Local lBreak	 := .F.
	Local aGrvSF3    := {}
	
	//Private cPerg := PadR("NFSIGW",10)
	
	//If Pergunte(cPerg,.T.)
		
		MV_PAR01 := AllTrim(MV_PAR01)
		
		If !lImpDir 		
			dbSelectArea("SF3")
			dbSetOrder(5)
			#IFDEF TOP
				If MV_PAR04==1
					cWhere := "%SubString(SF3.F3_CFO,1,1) < '5' AND SF3.F3_FORMUL='S'%"
				ElseIf MV_PAR04==2
					cWhere := "%SubString(SF3.F3_CFO,1,1) >= '5'%"
				EndIf	
				cAliasSF3 := GetNextAlias()
				lQuery    := .T.
				
				If Empty(cWhere)
			
					BeginSql Alias cAliasSF3
					
					COLUMN F3_ENTRADA AS DATE
					COLUMN F3_DTCANC AS DATE
							
					SELECT	F3_FILIAL,F3_ENTRADA,F3_NFELETR,F3_CFO,F3_FORMUL,F3_NFISCAL,F3_SERIE,F3_CLIEFOR,F3_LOJA,F3_ESPECIE,F3_DTCANC
					  		FROM %Table:SF3% SF3
							WHERE
							SF3.F3_FILIAL = %xFilial:SF3% AND
							SF3.F3_SERIE = %Exp:MV_PAR03% AND 
							SF3.F3_NFISCAL >= %Exp:MV_PAR01% AND 
							SF3.F3_NFISCAL <= %Exp:MV_PAR02% AND 
							SF3.F3_DTCANC = %Exp:Space(8)% AND   
							SF3.%notdel%
					EndSql	
			
				Else
					BeginSql Alias cAliasSF3
					
					COLUMN F3_ENTRADA AS DATE
					COLUMN F3_DTCANC AS DATE
							
					SELECT	F3_FILIAL,F3_ENTRADA,F3_NFELETR,F3_CFO,F3_FORMUL,F3_NFISCAL,F3_SERIE,F3_CLIEFOR,F3_LOJA,F3_ESPECIE,F3_DTCANC
							FROM %Table:SF3% SF3
							WHERE
							SF3.F3_FILIAL = %xFilial:SF3% AND
							SF3.F3_SERIE = %Exp:MV_PAR03% AND 
							SF3.F3_NFISCAL >= %Exp:MV_PAR01% AND 
							SF3.F3_NFISCAL <= %Exp:MV_PAR02% AND 
							%Exp:cWhere% AND 
							SF3.F3_DTCANC = %Exp:Space(8)% AND
							SF3.%notdel%
					EndSql	
				
				EndIf
			
			#ELSE
				MsSeek(xFilial("SF3")+MV_PAR03+MV_PAR01,.T.)
			    cIndex    		:= CriaTrab(NIL,.F.)
			    cChave			:= IndexKey(6)
			    cCondicao 		:= 'F3_FILIAL == "' 		+ xFilial("SF3") 	+ '" .And. '
			   	cCondicao 		+= 'SF3->F3_SERIE == "'		+ MV_PAR03			+ '" .And. '
			   	cCondicao 		+= 'SF3->F3_NFISCAL >= "'	+ MV_PAR01			+ '" .And. '
				cCondicao		+= 'SF3->F3_NFISCAL <= "' 	+ MV_PAR02			+ '" .And. '
				cCondicao		+= 'Empty(SF3->F3_DTCANC)'
				IndRegua("SF3",cIndex,cChave,,cCondicao)  
			#ENDIF
			If MV_PAR04 == 1
				cWhere := "SubStr(F3_CFO,1,1) < '5' .AND. F3_FORMUL=='S'"
			ElseIf MV_PAR04 == 2
				cWhere := "SubStr(F3_CFO,1,1) >= '5'"
			Else
				cWhere := ".T."
			EndIf	
				
			While !Eof() .And. xFilial("SF3") == (cAliasSF3)->F3_FILIAL .And.;
				(cAliasSF3)->F3_SERIE == MV_PAR03 .And.;
				(cAliasSF3)->F3_NFISCAL >= MV_PAR01 .And.;
				(cAliasSF3)->F3_NFISCAL <= MV_PAR02
				
				dbSelectArea(cAliasSF3)
				If  Empty((cAliasSF3)->F3_DTCANC) .And. &cWhere //.And. AModNot((cAliasSF3)->F3_ESPECIE)=="55"
				
					If (SubStr((cAliasSF3)->F3_CFO,1,1)>="5" .Or. (cAliasSF3)->F3_FORMUL=="S") .And. aScan(aNotas,{|x| x[4]+x[5]+x[6]+x[7]==(cAliasSF3)->F3_SERIE+(cAliasSF3)->F3_NFISCAL+(cAliasSF3)->F3_CLIEFOR+(cAliasSF3)->F3_LOJA})==0
						
						aadd(aNotas,{})
						aadd(Atail(aNotas),.F.)
						aadd(Atail(aNotas),IIF((cAliasSF3)->F3_CFO<"5","E","S"))
						aadd(Atail(aNotas),(cAliasSF3)->F3_ENTRADA)
						aadd(Atail(aNotas),(cAliasSF3)->F3_SERIE)
						aadd(Atail(aNotas),(cAliasSF3)->F3_NFISCAL)
						aadd(Atail(aNotas),(cAliasSF3)->F3_CLIEFOR)
						aadd(Atail(aNotas),(cAliasSF3)->F3_LOJA)
									
					EndIf
				EndIf
				
				dbSelectArea(cAliasSF3)
				dbSkip()
				
				If lEnd
					Exit
				EndIf
					
				If Len(aNotas) >= 50 .Or. 	(cAliasSF3)->(Eof())
					aXml := GetXML(cIdEnt,aNotas,@cModalidade)
					nLenNotas := Len(aNotas)
					For nX := 1 To nLenNotas
						If !Empty(aXML[nX][2])
							If !Empty(aXml[nX])
								cAutoriza   := aXML[nX][1]
								cCodAutDPEC := aXML[nX][5] 
							Else
								cAutoriza   := ""
								cCodAutDPEC := ""
							EndIf
							//If (!Empty(cAutoriza) .Or. !Empty(cCodAutDPEC) .Or. !cModalidade$"1,4,5,6") war 
							If (!Empty(cAutoriza) .Or. !Empty(cCodAutDPEC) .Or. Alltrim(aXML[nX][8]) $ "2,5,7")
								If aNotas[nX][02]=="E"
						    		dbSelectArea("SF1")
						    		dbSetOrder(1)			    			
								// WAR If MsSeek(xFilial("SF1")+aNotas[nX][05]+aNotas[nX][04]+aNotas[nX][06]+aNotas[nX][07]) .And. SF1->(FieldPos("F1_FIMP"))<>0 .And. cModalidade$"1,4,6"
									If MsSeek(xFilial("SF1")+aNotas[nX][05]+aNotas[nX][04]+aNotas[nX][06]+aNotas[nX][07]) .And. SF1->(FieldPos("F1_FIMP"))<>0 .And. Alltrim(aXML[nX][8])$"1,3,4,6"
										RecLock("SF1")
										If !SF1->F1_FIMP$"D"
											SF1->F1_FIMP := "S"
										EndIf
										If SF1->(FieldPos("F1_CHVNFE"))>0
											SF1->F1_CHVNFE := SubStr(NfeIdSPED(aXML[nX][2],"Id"),4)
										EndIf
										If SF1->(FieldPos("F1_HAUTNFE")) > 0 .and. SF1->(FieldPos("F1_DAUTNFE")) > 0 //grava a data e hota de autorização da NFe
											SF1->F1_HAUTNFE := IIF(!Empty(aXML[nX][6]),SUBSTR(aXML[nX][6],1,5),"")
				   							SF1->F1_DAUTNFE	:= IIF(!Empty(aXML[nX][7]),aXML[nX][7],SToD("  /  /    "))
										EndIf
			    			   			MsUnlock()
				    				EndIf				    			 
								Else
						    		dbSelectArea("SF2")
						    		dbSetOrder(1)
								// WAR If MsSeek(xFilial("SF2")+aNotas[nX][05]+aNotas[nX][04]+aNotas[nX][06]+aNotas[nX][07]) .And. cModalidade$"1,4,6"
									If MsSeek(xFilial("SF2")+aNotas[nX][05]+aNotas[nX][04]+aNotas[nX][06]+aNotas[nX][07]) .And. Alltrim(aXML[nX][8])$"1,3,4,6".Or. ( Alltrim(aXML[nX][8]) $ "2"  .And. !Empty(cAutoriza) )		
										RecLock("SF2")
										If !SF2->F2_FIMP$"D"
											SF2->F2_FIMP := "S"
										EndIf
										If SF2->(FieldPos("F2_CHVNFE"))>0
											SF2->F2_CHVNFE := SubStr(NfeIdSPED(aXML[nX][2],"Id"),4)       
										SF2->F2_CODNFE := cAutoriza
										EndIf
										If SF2->(FieldPos("F2_HAUTNFE")) > 0 .and. SF2->(FieldPos("F2_DAUTNFE")) > 0 //grava a data e hota de autorização da NFe
											SF2->F2_HAUTNFE := IIF(!Empty(aXML[nX][6]),SUBSTR(aXML[nX][6],1,5),"")
				   							SF2->F2_DAUTNFE	:= IIF(!Empty(aXML[nX][7]),aXML[nX][7],SToD("  /  /    "))
										EndIf
										MsUnlock()
									// Grava quando a nota for Transferencia entre filiais 
									IF SF2->(FieldPos("F2_FILDEST"))> 0 .And. SF2->(FieldPos("F2_FORDES"))> 0 .And.SF2->(FieldPos("F2_LOJADES"))> 0 .And.SF2->(FieldPos("F2_FORMDES"))> 0 .And. !EMPTY (SF2->F2_FORDES)  
							       		SF1->(dbSetOrder(1))
							    		If SF1->(MsSeek(SF2->F2_FILDEST+SF2->F2_DOC+SF2->f2_SERIE+SF2->F2_FORDES+SF2->F2_LOJADES+SF2->F2_FORMDES))
							    			If EMPTY(SF1->F1_CHVNFE)	
								    			RecLock("SF1",.F.)
								    			SF1->F1_CHVNFE := SF2->F2_CHVNFE
								    			MsUnlock()
								    		EndIf	
							    		Endif					    
							    	EndiF						
					    			EndIf
								EndIf
								dbSelectArea("SFT")
								dbSetOrder(1)
								If SFT->(FieldPos("FT_CHVNFE"))>0
									cChaveSFT	:=	(xFilial("SFT")+aNotas[nX][02]+aNotas[nX][04]+aNotas[nX][05]+aNotas[nX][06]+aNotas[nX][07])							
									If MsSeek(cChaveSFT)
										Do While !(cAliasSFT)->(Eof ()) .And.;
										   	cChaveSFT==(cAliasSFT)->FT_FILIAL+(cAliasSFT)->FT_TIPOMOV+(cAliasSFT)->FT_SERIE+(cAliasSFT)->FT_NFISCAL+(cAliasSFT)->FT_CLIEFOR+(cAliasSFT)->FT_LOJA
										   	RecLock("SFT")
										   	SFT->FT_CHVNFE := SubStr(NfeIdSPED(aXML[nX][2],"Id"),4)
											SFT->FT_CODNFE := cAutoriza
									   	   	MsUnLock()
											//Array criado para gravar o SF3 no final, pois a tabela SF3 pode estah em processamento quando se trata de DBF ou AS/400.
											If aScan(aGrvSF3,{|aX|aX[1]+aX[2]+aX[3]+aX[4]+aX[5]==(cAliasSFT)->(FT_SERIE+FT_NFISCAL+FT_CLIEFOR+FT_LOJA+FT_IDENTF3)})==0
												aAdd(aGrvSF3, {(cAliasSFT)->FT_SERIE,(cAliasSFT)->FT_NFISCAL,(cAliasSFT)->FT_CLIEFOR,(cAliasSFT)->FT_LOJA,(cAliasSFT)->FT_IDENTF3,(cAliasSFT)->FT_CHVNFE,cAutoriza})
											EndIf
									   	   	DbSkip()
										EndDo							
									EndIf
		                        EndIf
								// Grava quando a nota for Transferencia entre filiais  
								IF SF1->(!EOF()) .And. SF2->(FieldPos("F2_FILDEST"))> 0 .And. SF2->(FieldPos("F2_FORDES"))> 0 .And.SF2->(FieldPos("F2_LOJADES"))> 0 .And.SF2->(FieldPos("F2_FORMDES"))> 0 .And. !EMPTY (SF2->F2_FORDES)  
							  		SFT->(dbSetOrder(1))
									cChaveSFT := SF1->F1_FILIAL+"E"+SF1->F1_SERIE+SF1->F1_DOC+SF1->F1_FORNECE+SF1->F1_LOJA
									If SFT->(MsSeek(cChaveSFT))
										Do While cChaveSFT == SFT->FT_FILIAL+"E"+SFT->FT_SERIE+SFT->FT_NFISCAL+SFT->FT_CLIEFOR+SFT->FT_LOJA .And. !SFT->(Eof())
											RecLock("SFT")
											SFT->FT_CHVNFE := SubStr(NfeIdSPED(aXML[nX][2],"Id"),4)
											SFT->FT_CODNFE := cAutoriza
											MsUnLock()
											//Array criado para gravar o SF3 no final, pois a tabela SF3 pode estah em processamento quando se trata de DBF ou AS/400.
											If aScan(aGrvSF3,{|aX|aX[1]+aX[2]+aX[3]+aX[4]+aX[5]==(cAliasSFT)->(FT_SERIE+FT_NFISCAL+FT_CLIEFOR+FT_LOJA+FT_IDENTF3)})==0
												aAdd(aGrvSF3, {(cAliasSFT)->FT_SERIE,(cAliasSFT)->FT_NFISCAL,(cAliasSFT)->FT_CLIEFOR,(cAliasSFT)->FT_LOJA,(cAliasSFT)->FT_IDENTF3,(cAliasSFT)->FT_CHVNFE,cAutoriza})
											EndIf
											SFT->(dbSkip())
							    		EndDo
									EndIf
								EndIf
								cAviso := ""
								cErro  := ""
								oNfe := XmlParser(aXML[nX][2],"_",@cAviso,@cErro)					
								oNfeDPEC := XmlParser(aXML[nX][4],"_",@cAviso,@cErro)					
								If Empty(cAviso) .And. Empty(cErro)	
								    PrtDanfe(oNFe,cAutoriza,cModalidade,oNfeDPEC,cCodAutDPEC,aXml[nX][6])
								    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
									//³ Descompressao de Impressao 				     ³
									//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
								   	lExistNfe := .T. // WAR
								   	@ 68, 000 PSAY Chr(18)					    
								EndIf
							Else				
								cNaoAut += aNotas[nX][04]+aNotas[nX][05]+CRLF			
							EndIf
						EndIf
		
					Next nX
					aNotas := {}
				EndIf		
				dbSelectArea(cAliasSF3)
			EndDo
			If !lQuery 
				RetIndex("SF3")	
				dbClearFilter()	
				Ferase(cIndex+OrdBagExt())
			EndIf
			If !Empty(cNaoAut)
				Aviso("SPED","As seguintes notas não foram autorizadas: "+CRLF+CRLF+cNaoAut,{"Ok"},3)
			EndIf
		Else
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Tratamento para quando o parametro MV_IMPDIR esteja        ³
	//³Habilitado, neste caso não será feita a impressão conforme ³
	//³Registros no SF3, e sim buscando XML diretamente do        ³
	//³webService, e caso exista será impresso.                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nLenarray := Val(MV_PAR02) - Val(Alltrim(MV_PAR01))
			nCursor   := Val(MV_PAR01)
			While  !lBreak  .And. nLenarray >= 0         
		 	    aNotas := {}
				For nx:=1 To 20
					aadd(aNotas,{})                              
					aAdd(Atail(aNotas),.F.)            
					aadd(Atail(aNotas),IIF(MV_PAR04==1,"E","S"))
					aAdd(Atail(aNotas),"")
					aAdd(Atail(aNotas),MV_PAR03)
					aAdd(Atail(aNotas),Alltrim(Strzero(nCursor,9)))         
					aadd(Atail(aNotas),"")
					aadd(Atail(aNotas),"")                          		
					If nCursor==Val(MV_PAR02)
						lBreak :=.T.			
						nx:=20                          
					EndIF
					nCursor++
				Next nX		
				aXml:={}
				aXml := GetXML(cIdEnt,aNotas,@cModalidade)
				nLenNotas := Len(aNotas)             
				For nx :=1 To nLenNotas
					If !Empty(aXML[nX][2])
						If !Empty(aXml[nX])
							cAutoriza   := aXML[nX][1]
							cCodAutDPEC := aXML[nX][5] 
						Else
							cAutoriza   := ""
							cCodAutDPEC := ""
						EndIf            
						cAviso := ""
						cErro  := ""     	
						oNfe := XmlParser(aXML[nX][2],"_",@cAviso,@cErro)					
						oNfeDPEC := XmlParser(aXML[nX][4],"_",@cAviso,@cErro)
						If (!Empty(cAutoriza) .Or. !Empty(cCodAutDPEC) .Or. Alltrim(aXML[nX][8])$"2,5,7")
							If aNotas[nX][02]=="E" .And. MV_PAR04==1 .And. (oNfe:_NFE:_INFNFE:_IDE:_TPNF:TEXT=="0")
					    		dbSelectArea("SF1")
					    		dbSetOrder(1)
							If MsSeek(xFilial("SF1")+aNotas[nX][05]+aNotas[nX][04]) .And. SF1->(FieldPos("F1_FIMP"))<>0 .And. cModalidade$"1,4,6"
									Do While !Eof() .And. SF1->F1_DOC==aNotas[nX][05] .And. SF1->F1_SERIE==aNotas[nX][04]
								   		If SF1->F1_FORMUL=='S'
									   		RecLock("SF1")
											If !SF1->F1_FIMP$"D"
												SF1->F1_FIMP := "S"
											EndIf
											If SF1->(FieldPos("F1_CHVNFE"))>0
												SF1->F1_CHVNFE := SubStr(NfeIdSPED(aXML[nX][2],"Id"),4)
											EndIf
											// war
											If SF1->(FieldPos("F1_HAUTNFE")) > 0 .and. SF1->(FieldPos("F1_DAUTNFE")) > 0 //grava a data e hota de autorização da NFe
												SF1->F1_HAUTNFE := IIF(!Empty(aXML[nX][6]),SUBSTR(aXML[nX][6],1,5),"")
				   								SF1->F1_DAUTNFE	:= IIF(!Empty(aXML[nX][7]),aXML[nX][7],SToD("  /  /    "))
											EndIf 
											// war			    			   
											MsUnlock()
											DbSkip()
										EndIf	
									EndDo	
			    				EndIf
							ElseIf aNotas[nX][02]=="S" .And. MV_PAR04==2 .And. (oNfe:_NFE:_INFNFE:_IDE:_TPNF:TEXT=="1")
					    		dbSelectArea("SF2")
					    		dbSetOrder(1)
					    		If MsSeek(xFilial("SF2")+aNotas[nX][05]+aNotas[nX][04]) .And. cModalidade$"1,4,6"
									RecLock("SF2")
									If !SF2->F2_FIMP$"D"
										SF2->F2_FIMP := "S"
									EndIf
									If SF2->(FieldPos("F2_CHVNFE"))>0
										SF2->F2_CHVNFE := SubStr(NfeIdSPED(aXML[nX][2],"Id"),4)
										SF2->F2_CODNFE := cAutoriza // war        
									EndIf
									If SF2->(FieldPos("F2_HAUTNFE")) > 0 .and. SF2->(FieldPos("F2_DAUTNFE")) > 0 //grava a data e hota de autorização da NFe
										SF2->F2_HAUTNFE := IIF(!Empty(aXML[nX][6]),SUBSTR(aXML[nX][6],1,5),"")
				   						SF2->F2_DAUTNFE	:= IIF(!Empty(aXML[nX][7]),aXML[nX][7],SToD("  /  /    "))
									EndIf
									MsUnlock()
				    			EndIf
							EndIf
							dbSelectArea("SFT")
							dbSetOrder(1)
							If SFT->(FieldPos("FT_CHVNFE"))>0
								cChaveSFT	:=	(xFilial("SFT")+aNotas[nX][02]+aNotas[nX][04]+aNotas[nX][05])							
								MsSeek(cChaveSFT)
				  				Do While !(cAliasSFT)->(Eof ()) .And.;
									     cChaveSFT==(cAliasSFT)->FT_FILIAL+(cAliasSFT)->FT_TIPOMOV+(cAliasSFT)->FT_SERIE+(cAliasSFT)->FT_NFISCAL
									If (cAliasSFT)->FT_TIPOMOV $"S" .Or. ((cAliasSFT)->FT_TIPOMOV $"E" .And. (cAliasSFT)->FT_FORMUL=='S')
									//Array criado para gravar o SF3 no final, pois a tabela SF3 pode estah em processamento quando se trata de DBF ou AS/400.
									If aScan(aGrvSF3,{|aX|aX[1]+aX[2]+aX[3]+aX[4]+aX[5]==(cAliasSFT)->(FT_SERIE+FT_NFISCAL+FT_CLIEFOR+FT_LOJA+FT_IDENTF3)})==0
										aAdd(aGrvSF3, {(cAliasSFT)->FT_SERIE,(cAliasSFT)->FT_NFISCAL,(cAliasSFT)->FT_CLIEFOR,(cAliasSFT)->FT_LOJA,(cAliasSFT)->FT_IDENTF3,(cAliasSFT)->FT_CHVNFE,cAutoriza})
									EndIf
									   	RecLock("SFT")
									   	SFT->FT_CHVNFE := SubStr(NfeIdSPED(aXML[nX][2],"Id"),4)
								   	   	MsUnLock()
								   	   	DbSkip()
								   	EndIf
								   	DbSkip()	
								EndDo							
		      				EndIf																								
							If Empty(cAviso) .And. Empty(cErro) .And. MV_PAR04==1 .And. (oNfe:_NFE:_INFNFE:_IDE:_TPNF:TEXT=="0") 	
							    PrtDanfe(oNFe,cAutoriza,cModalidade,oNfeDPEC,cCodAutDPEC,aXml[nX][6])					    		
								lExistNfe := .T.  // WAR
								//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
								//³ Descompressao de Impressao 				     ³
								//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							   	@ 68, 000 PSAY Chr(18)
							ElseIf Empty(cAviso) .And. Empty(cErro) .And. MV_PAR04==2 .And. (oNfe:_NFE:_INFNFE:_IDE:_TPNF:TEXT=="1") 	
							    PrtDanfe(oNFe,cAutoriza,cModalidade,oNfeDPEC,cCodAutDPEC,aXml[nX][6])					
								lExistNfe := .T.  // WAR
								//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
								//³ Descompressao de Impressao 				     ³
								//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							   	@ 68, 000 PSAY Chr(18)
							EndIf				                       	                                                            
						Else				
							cNaoAut += aNotas[nX][04]+aNotas[nX][05]+CRLF		
						EndIf	
					EndIf
				Next nx
			EndDo
			If !Empty(cNaoAut)
				Aviso("SPED","As seguintes notas não foram autorizadas: "+CRLF+CRLF+cNaoAut,{"Ok"},3)
			EndIf			
		EndIf	
	//EndIf
If Len(aGrvSF3)>0 .And. SF3->(FieldPos("F3_CHVNFE"))>0
	For nI := 1 To Len(aGrvSF3)
		If SF3->(MsSeek(xFilial("SF3")+aGrvSF3[nI,1]+aGrvSF3[nI,2]+aGrvSF3[nI,3]+aGrvSF3[nI,4]+aGrvSF3[nI,5])) .And. Empty(SF3->F3_CHVNFE)
			RecLock("SF3")
			SF3->F3_CHVNFE := aGrvSF3[nI,6]
			SF3->F3_CODNFE := aGrvSF3[nI,7]
			MsUnLock()
		EndIf
	Next nI
EndIf
RestArea(aArea)
Return(.T.)


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ PrtDanfe	  ºAutor  ³Wilson A. Silva Jr. º Data ³ 05/26/10  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Impressao do formulario DANFE para Impressora Matricial.   º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ ELETROMEGA                                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function PrtDanfe(oNFE,cCodAutSef,cModalidade,oNfeDPEC,cCodAutDPEC,cDtHrRecCab)

	Local aSitTrib      := {}
	Local aTransp       := {}
	Local aDest         := {}
	Local aFaturas      := {} 
	Local aItens        := {}
	Local aISSQN        := {}
	Local aTotais       := {}
	Local aAux          := {}
	Local nX            := 0
	Local nY            := 0     
	Local nZ			:= 0
	Local nItem         := 0
	Local nMensagem     := 0
	Local nBaseICM      := 0
	Local nValICM       := 0
	Local nValIPI       := 0
	Local nPICM         := 0
	Local nPIPI         := 0
	Local nBCST         := 0
	Local nvICMSST      := 0
	Local nFaturas      := 0
	Local nVTotal       := 0
	Local nQtd          := 0
	Local nVUnit        := 0
	Local nVolume	    := 0
	Local cAux          := ""
	Local cSitTrib      := ""
	Local aMensagem     := {}
	Local nLenFatura        
	Local nLenVol  
	Local nLenDet 
	Local nLenSit     
	Local nLen          := 0
	
	Default cDtHrRecCab:= ""
	
	Private oNF        := oNFe:_NFe
	Private oEmitente  := oNF:_InfNfe:_Emit
	Private oIdent     := oNF:_InfNfe:_IDE
	Private oDestino   := oNF:_InfNfe:_Dest
	Private oTotal     := oNF:_InfNfe:_Total
	Private oTransp    := oNF:_InfNfe:_Transp
	Private oDet       := oNF:_InfNfe:_Det
	Private oFatura    := IIf(Type("oNF:_InfNfe:_Cobr")=="U",Nil,oNF:_InfNfe:_Cobr)
	Private oImposto  
	Private nPrivate   := 0
	Private nPrivate2  := 0
	Private nXAux	   := 0
	
	Private aDadImp := {}
	
	nFaturas := IIf(oFatura<>Nil,IIf(ValType(oNF:_InfNfe:_Cobr:_Dup)=="A",Len(oNF:_InfNfe:_Cobr:_Dup),1),0)
	oDet := IIf(ValType(oDet)=="O",{oDet},oDet)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Carrega as variaveis de impressao                                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aadd(aSitTrib,"00")
	aadd(aSitTrib,"10")
	aadd(aSitTrib,"20")
	aadd(aSitTrib,"30")
	aadd(aSitTrib,"40")
	aadd(aSitTrib,"41")
	aadd(aSitTrib,"50")
	aadd(aSitTrib,"51")
	aadd(aSitTrib,"60")
	aadd(aSitTrib,"70")
	aadd(aSitTrib,"90")
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Quadro Destinatario                                                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aDest := {oDestino:_EnderDest:_Xlgr:Text+IIF(", SN"$oDestino:_EnderDest:_Xlgr:Text,"",", "+oDestino:_EnderDest:_NRO:Text + IIf(Type("oDestino:_EnderDest:_xcpl")=="U","",", " + oDestino:_EnderDest:_xcpl:Text)),;
				IIF(Type("oDestino:_EnderDest:_XBairro"	)<>"U",oDestino:_EnderDest:_XBairro:Text						,""),;
				IIF(Type("oDestino:_EnderDest:_Cep"		)<>"U",oDestino:_EnderDest:_Cep:Text							,""),;
				IIF(Type("oIdent:_DSaiEnt"				)<>"U",oIdent:_DSaiEnt:Text										,""),;
				IIF(Type("oDestino:_EnderDest:_XMun"	)<>"U",oDestino:_EnderDest:_XMun:Text							,""),;
				IIF(Type("oDestino:_EnderDest:_fone"	)<>"U",oDestino:_EnderDest:_fone:Text							,""),;
				IIF(Type("oDestino:_EnderDest:_UF"		)<>"U",oDestino:_EnderDest:_UF:Text								,""),;
				IIF(Type("oDestino:_IE"					)<>"U",oDestino:_IE:Text										,""),;
				""}
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Calculo do Imposto                                                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aTotais := {"","","","","","","","","","",""}
	aTotais[01] := Transform(Val(oTotal:_ICMSTOT:_vBC:TEXT)		,"@ze 999,999,999.99"	)
	aTotais[02] := Transform(Val(oTotal:_ICMSTOT:_vICMS:TEXT)	,"@ze 999,999,999.99"	)
	aTotais[03] := Transform(Val(oTotal:_ICMSTOT:_vBCST:TEXT)	,"@ze 999,999,999.99"	)
	aTotais[04] := Transform(Val(oTotal:_ICMSTOT:_vST:TEXT)		,"@ze 999,999,999.99"	)
	aTotais[05] := Transform(Val(oTotal:_ICMSTOT:_vProd:TEXT)	,"@E 999,999,999.99"	)
	aTotais[06] := Transform(Val(oTotal:_ICMSTOT:_vFrete:TEXT)	,"@ze 999,999,999.99"	)
	aTotais[07] := Transform(Val(oTotal:_ICMSTOT:_vSeg:TEXT)	,"@ze 999,999,999.99"	)
	aTotais[08] := Transform(Val(oTotal:_ICMSTOT:_vDesc:TEXT)	,"@ze 999,999,999.99"	)
	aTotais[09] := Transform(Val(oTotal:_ICMSTOT:_vOutro:TEXT)	,"@ze 999,999,999.99"	)
	aTotais[10] := Transform(Val(oTotal:_ICMSTOT:_vIPI:TEXT)	,"@ze 999,999,999.99"	)
	aTotais[11] := Transform(Val(oTotal:_ICMSTOT:_vNF:TEXT)		,"@E 999,999,999.99"	)	
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Quadro Faturas                                                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nFaturas > 0
		For nY := 1 To nFaturas
			cAux := ""
			For nX := 1 To 3
				Do Case
					Case nX == 1
						If nFaturas > 1
							cAux := AllTrim(oFatura:_Dup[nY]:_nDup:TEXT) + " "
						Else
							cAux := AllTrim(oFatura:_Dup:_nDup:TEXT) + " "
						EndIf
					Case nX == 2
						If nFaturas > 1
							cAux += AllTrim(ConvDate(oFatura:_Dup[nY]:_dVenc:TEXT)) + " "
						Else
							cAux += AllTrim(ConvDate(oFatura:_Dup:_dVenc:TEXT)) + " "
						EndIf
					Case nX == 3
						If nFaturas > 1
							cAux += AllTrim(TransForm(Val(oFatura:_Dup[nY]:_vDup:TEXT), "@E 9,999,999.99"))
						Else
							cAux += AllTrim(TransForm(Val(oFatura:_Dup:_vDup:TEXT), "@E 9,999,999.99"))
						EndIf
				EndCase
			Next nX
			AAdd(aFaturas, cAux)
		Next nY
	EndIf
	
	//If MV_PAR06==1 // Boleto = "S"
	If MV_PAR07==1 // Boleto = "S"
		cDirBol := GetMV("FS_ELE007")
			If ! Empty( cDirBol ) .And. !U_IsBonif(SF2->F2_DOC,SF2->F2_SERIE) 
	   			If File ( cDirBol + '\' + cNumEmp + '\CB' + Substr(SF2->F2_DOC,4,6) + '.Rem' )
	   				_cRun := cDirBol + '\' + '\WSisLsr.Exe ' + cNumEmp + '\CB' + Substr(SF2->F2_DOC,4,6) + '.Rem 0' // CURITIBA  - Victor Abreu
	                WinExec( _cRun )
	   			EndIf  
	   		EndIf
	EndIf	 
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Quadro transportadora                                                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aTransp := {"","0","","","","","","","","","","","","","",""}
	
	If Type("oTransp:_ModFrete")<>"U"
		aTransp[02] := IIF(Type("oTransp:_ModFrete:TEXT")<>"U",oTransp:_ModFrete:TEXT,"0")
	EndIf                                   
	If Type("oTransp:_Transporta")<>"U"
		aTransp[01] := IIf(Type("oTransp:_Transporta:_xNome:TEXT"	)<>"U",oTransp:_Transporta:_xNome:TEXT	,"" )
		//aTransp[02] := IIF(Type("oTransp:_ModFrete:TEXT"			)<>"U",oTransp:_ModFrete:TEXT			,"0")
		aTransp[03] := IIf(Type("oTransp:_VeicTransp:_RNTC"			)<>"U",oTransp:_VeicTransp:_RNTC:TEXT	,"" )
		aTransp[04] := IIf(Type("oTransp:_VeicTransp:_Placa:TEXT"	)<>"U",oTransp:_VeicTransp:_Placa:TEXT	,"" )
		aTransp[05] := IIf(Type("oTransp:_VeicTransp:_UF:TEXT"		)<>"U",oTransp:_VeicTransp:_UF:TEXT		,"" )
		If Type("oTransp:_Transporta:_CNPJ:TEXT")<>"U"
			aTransp[06] := IIf (!Empty(oTransp:_Transporta:_CNPJ:TEXT), Transform(oTransp:_Transporta:_CNPJ:TEXT,"@r 99.999.999/9999-99"),"")
		ElseIf Type("oTransp:_Transporta:_CPF:TEXT")<>"U"
			aTransp[06] := IIf (!Empty(oTransp:_Transporta:_CPF:TEXT), Transform(oTransp:_Transporta:_CPF:TEXT,"@r 999.999.999-99"),"")
		EndIf
		aTransp[07] := IIf(Type("oTransp:_Transporta:_xEnder:TEXT"	)<>"U",oTransp:_Transporta:_xEnder:TEXT ,"")
		aTransp[08] := IIf(Type("oTransp:_Transporta:_xMun:TEXT"	)<>"U",oTransp:_Transporta:_xMun:TEXT	,"")
		aTransp[09] := IIf(Type("oTransp:_Transporta:_UF:TEXT"		)<>"U",oTransp:_Transporta:_UF:TEXT		,"")
		aTransp[10] := IIf(Type("oTransp:_Transporta:_IE:TEXT"		)<>"U",oTransp:_Transporta:_IE:TEXT		,"")
	EndIf
	If Type("oTransp:_Vol")<>"U"
	    If ValType(oTransp:_Vol) == "A"
		    nX := nPrivate
			    nLenVol := Len(oTransp:_Vol)
		    	For nX := 1 to nLenVol
	    		nXAux := nX
	    		nVolume += IIF(!Type("oTransp:_Vol[nXAux]:_QVOL:TEXT")=="U",Val(oTransp:_Vol[nXAux]:_QVOL:TEXT),0)
		    Next nX
		    aTransp[11]	:= AllTrim(str(nVolume))
			aTransp[12]	:= IIf(Type("oTransp:_Vol:_Esp"			)<>"U","Diversos"				,"")
			aTransp[13] := IIf(Type("oTransp:_Vol:_Marca"		)<>"U",oTransp:_Vol:_Marca:TEXT,"")
			aTransp[14] := IIf(Type("oTransp:_Vol:_nVol:TEXT"	)<>"U",oTransp:_Vol:_nVol:TEXT	,"")
			If  Type("oTransp:_Vol[1]:_PesoB") <>"U"
	            	nPesoB := Val(oTransp:_Vol[1]:_PesoB:TEXT)
	   				aTransp[15] := AllTrim(str(nPesoB))
	  			EndIf
	  		If Type("oTransp:_Vol[1]:_PesoL") <> "U"
	            nPesoL := Val(oTransp:_Vol[1]:_PesoL:TEXT)
				aTransp[16] := AllTrim(str(nPesoL))
			EndIf
	    Else
			aTransp[11] := IIf(Type("oTransp:_Vol:_qVol:TEXT"	)<>"U",oTransp:_Vol:_qVol:TEXT ,"")    
			aTransp[12] := IIf(Type("oTransp:_Vol:_Esp"			)<>"U",oTransp:_Vol:_Esp:TEXT  ,"")
			aTransp[13] := IIf(Type("oTransp:_Vol:_Marca"		)<>"U",oTransp:_Vol:_Marca:TEXT,"")
			aTransp[14] := IIf(Type("oTransp:_Vol:_nVol:TEXT"	)<>"U",oTransp:_Vol:_nVol:TEXT ,"")
			aTransp[15] := IIf(Type("oTransp:_Vol:_PesoB:TEXT"	)<>"U",oTransp:_Vol:_PesoB:TEXT,"")
			aTransp[16] := IIf(Type("oTransp:_Vol:_PesoL:TEXT"	)<>"U",oTransp:_Vol:_PesoL:TEXT,"")		
	    EndIf
	    aTransp[15] := strTRan(aTransp[15],".",",")
	    aTransp[16] := strTRan(aTransp[16],".",",")    
	EndIf
		
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Quadro Dados do Produto / Serviço                                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nLenDet := Len(oDet)
	For nX := 1 To nLenDet
		nPrivate := nX
		nVTotal  := Val(oDet[nX]:_Prod:_vProd:TEXT)//-Val(IIF(Type("oDet[nPrivate]:_Prod:_vDesc")=="U","",oDet[nX]:_Prod:_vDesc:TEXT))
		nQtd     := Val(oDet[nX]:_Prod:_qTrib:TEXT)
		nVUnit   := Val(oDet[nX]:_Prod:_vUnCom:TEXT)
		nBaseICM := 0
		nValICM  := 0
		nValIPI  := 0
		nPICM    := 0
		nPIPI    := 0
		nBCST	 := 0
		nvICMSST := 0
		oImposto := oDet[nX]
		cSitTrib := " "
		If Type("oImposto:_Imposto")<>"U"
			If Type("oImposto:_Imposto:_ICMS")<>"U"
				nLenSit := Len(aSitTrib)
				For nY := 1 To nLenSit
					nPrivate2 := nY
			 		If Type("oImposto:_Imposto:_ICMS:_ICMS"+aSitTrib[nPrivate2])<>"U"
			 			If Type("oImposto:_Imposto:_ICMS:_ICMS"+aSitTrib[nPrivate2]+":_VBC:TEXT")<>"U"
				 			nBaseICM := Val(&("oImposto:_Imposto:_ICMS:_ICMS"+aSitTrib[nY]+":_VBC:TEXT"))
				 			nValICM  := Val(&("oImposto:_Imposto:_ICMS:_ICMS"+aSitTrib[nY]+":_vICMS:TEXT"))
				 			nPICM    := Val(&("oImposto:_Imposto:_ICMS:_ICMS"+aSitTrib[nY]+":_PICMS:TEXT"))
			 			EndIf
			 			If Type("oImposto:_Imposto:_ICMS:_ICMS"+aSitTrib[nPrivate2]+":_vBCST:TEXT")<>"U"
			 				nBCST  	 := Val(&("oImposto:_Imposto:_ICMS:_ICMS"+aSitTrib[nY]+":_vBCST:TEXT"))
			 				nvICMSST := Val(&("oImposto:_Imposto:_ICMS:_ICMS"+aSitTrib[nY]+":_vICMSST:TEXT"))
				 		EndIf
				 		cSitTrib := &("oImposto:_Imposto:_ICMS:_ICMS"+aSitTrib[nY]+":_ORIG:TEXT")
				 		cSitTrib += &("oImposto:_Imposto:_ICMS:_ICMS"+aSitTrib[nY]+":_CST:TEXT")
			 		EndIf
				Next nY
			EndIf
			If Type("oImposto:_Imposto:_IPI")<>"U"
				If Type("oImposto:_Imposto:_IPI:_IPITrib:_vIPI:TEXT")<>"U"
					nValIPI := Val(oImposto:_Imposto:_IPI:_IPITrib:_vIPI:TEXT)
				EndIf
				If Type("oImposto:_Imposto:_IPI:_IPITrib:_pIPI:TEXT")<>"U"
					nPIPI   := Val(oImposto:_Imposto:_IPI:_IPITrib:_pIPI:TEXT)
				EndIf
			EndIf
		EndIf
		aadd(aItens,{oDet[nX]:_Prod:_cProd:TEXT,;
						SubStr(oDet[nX]:_Prod:_xProd:TEXT,1,MAXITEMC),;
						IIF(Type("oDet[nPrivate]:_Prod:_NCM")=="U","",oDet[nX]:_Prod:_NCM:TEXT),;
						cSitTrib,;
						oDet[nX]:_Prod:_CFOP:TEXT,;
						oDet[nX]:_Prod:_utrib:TEXT,;
						TransForm(nQtd,"@E 999,999,999"),;
						TransForm(nVUnit,"@E 9,999,999.9999"),; // TransForm(nVUnit,"@E 999,999,999.99"),;
						TransForm(nVTotal,"@E 99,999,999,999.99"),;
						TransForm(nBaseICM,"@E 99,999,999.99"),;
						TransForm(nValICM,"@E 999,999.99"),;
						TransForm(nValIPI,"@E 999,999.99"),;
						TransForm(nPICM,"@E 99"),;
						TransForm(nPIPI,"@E 99.99"),;
						TransForm(nBCST,"@E 999,999,999.99"),;
						TransForm(nvICMSST,"@E 99,999,999.99")})
	Next nX
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Quadro ISSQN                                                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aISSQN := {"","","",""}
	If Type("oEmitente:_IM:TEXT")<>"U"
		aISSQN[1] := oEmitente:_IM:TEXT
	EndIf  
	If Type("oTotal:_ISSQNtot")<>"U"
		aISSQN[2] := Transform(Val(oTotal:_ISSQNtot:_vServ:TEXT),"@ze 999,999,999.99")	
		aISSQN[3] := Transform(Val(oTotal:_ISSQNtot:_vBC:TEXT),"@ze 999,999,999.99")	
		aISSQN[4] := Transform(Val(oTotal:_ISSQNtot:_vISS:TEXT),"@ze 999,999,999.99")	
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Quadro de informacoes complementares                                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aMensagem := {}
	If Type("oNF:_InfNfe:_infAdic:_infAdFisco:TEXT")<>"U"
		cAux := oNF:_InfNfe:_infAdic:_infAdFisco:TEXT
		While !Empty(cAux)
			aadd(aMensagem,SubStr(cAux,1,IIf(EspacoAt(cAux, MAXMENLIN) > 1, EspacoAt(cAux, MAXMENLIN) - 1, MAXMENLIN)))
			cAux := SubStr(cAux,IIf(EspacoAt(cAux, MAXMENLIN) > 1, EspacoAt(cAux, MAXMENLIN), MAXMENLIN) + 1)
		EndDo
	EndIf
	
	If !Empty(cCodAutSef) .AND. oIdent:_tpEmis:TEXT<>"4"
		cAux := "Protocolo: "+cCodAutSef
		While !Empty(cAux)
			aadd(aMensagem,SubStr(cAux,1,IIf(EspacoAt(cAux, MAXMENLIN) > 1, EspacoAt(cAux, MAXMENLIN) - 1, MAXMENLIN)))
			cAux := SubStr(cAux,IIf(EspacoAt(cAux, MAXMENLIN) > 1, EspacoAt(cAux, MAXMENLIN), MAXMENLIN) + 1)
		EndDo
	ElseIf !Empty(cCodAutSef) .AND. oIdent:_tpEmis:TEXT=="4" .AND. cModalidade $ "1"
		cAux := "Protocolo: "+cCodAutSef
		While !Empty(cAux)
			aadd(aMensagem,SubStr(cAux,1,IIf(EspacoAt(cAux, MAXMENLIN) > 1, EspacoAt(cAux, MAXMENLIN) - 1, MAXMENLIN)))
			cAux := SubStr(cAux,IIf(EspacoAt(cAux, MAXMENLIN) > 1, EspacoAt(cAux, MAXMENLIN), MAXMENLIN) + 1)
		EndDo
		cAux := "DANFE emitida anteriormente em contingência DPEC"
		While !Empty(cAux)
			aadd(aMensagem,SubStr(cAux,1,IIf(EspacoAt(cAux, MAXMENLIN) > 1, EspacoAt(cAux, MAXMENLIN) - 1, MAXMENLIN)))
			cAux := SubStr(cAux,IIf(EspacoAt(cAux, MAXMENLIN) > 1, EspacoAt(cAux, MAXMENLIN), MAXMENLIN) + 1)
		EndDo
	EndIf
	
	If !Empty(cCodAutDPEC) .And. oIdent:_tpEmis:TEXT=="4"
		cAux := "Número de Registro DPEC: "+cCodAutDPEC
		While !Empty(cAux)
			aadd(aMensagem,SubStr(cAux,1,IIf(EspacoAt(cAux, MAXMENLIN) > 1, EspacoAt(cAux, MAXMENLIN) - 1, MAXMENLIN)))
			cAux := SubStr(cAux,IIf(EspacoAt(cAux, MAXMENLIN) > 1, EspacoAt(cAux, MAXMENLIN), MAXMENLIN) + 1)
		EndDo
	EndIf
	
	If (Type("oIdent:_tpEmis:TEXT")<>"U" .And. !oIdent:_tpEmis:TEXT$"1,4")
		cAux := "DANFE emitida em contingência"
		While !Empty(cAux)
			aadd(aMensagem,SubStr(cAux,1,IIf(EspacoAt(cAux, MAXMENLIN) > 1, EspacoAt(cAux, MAXMENLIN) - 1, MAXMENLIN)))
			cAux := SubStr(cAux,IIf(EspacoAt(cAux, MAXMENLIN) > 1, EspacoAt(cAux, MAXMENLIN), MAXMENLIN) + 1)
		EndDo
	ElseIf (!Empty(cModalidade) .And. !cModalidade $ "1,4,5") .And. Empty(cCodAutSef) 
		cAux := "DANFE emitida em contingência devido a problemas técnicos - será necessária a substituição."
		While !Empty(cAux)
			aadd(aMensagem,SubStr(cAux,1,IIf(EspacoAt(cAux, MAXMENLIN) > 1, EspacoAt(cAux, MAXMENLIN) - 1, MAXMENLIN)))
			cAux := SubStr(cAux,IIf(EspacoAt(cAux, MAXMENLIN) > 1, EspacoAt(cAux, MAXMENLIN), MAXMENLIN) + 1)
		EndDo
	ElseIf (!Empty(cModalidade) .And. cModalidade $ "5" .And. oIdent:_tpEmis:TEXT=="4") 
		cAux := "DANFE impresso em contingência"
		While !Empty(cAux)
			aadd(aMensagem,SubStr(cAux,1,IIf(EspacoAt(cAux, MAXMENLIN) > 1, EspacoAt(cAux, MAXMENLIN) - 1, MAXMENLIN)))
			cAux := SubStr(cAux,IIf(EspacoAt(cAux, MAXMENLIN) > 1, EspacoAt(cAux, MAXMENLIN), MAXMENLIN) + 1)
		EndDo
		cAux := "DPEC regularmento recebido pela Receita Federal do Brasil."
		While !Empty(cAux)
			aadd(aMensagem,SubStr(cAux,1,IIf(EspacoAt(cAux, MAXMENLIN) > 1, EspacoAt(cAux, MAXMENLIN) - 1, MAXMENLIN)))
			cAux := SubStr(cAux,IIf(EspacoAt(cAux, MAXMENLIN) > 1, EspacoAt(cAux, MAXMENLIN), MAXMENLIN) + 1)
		EndDo
	ElseIf (Type("oIdent:_tpEmis:TEXT")<>"U" .And. oIdent:_tpEmis:TEXT$"5")
		cAux := "DANFE emitida em contingência FS-DA"
		While !Empty(cAux)
			aadd(aMensagem,SubStr(cAux,1,IIf(EspacoAt(cAux, MAXMENLIN) > 1, EspacoAt(cAux, MAXMENLIN) - 1, MAXMENLIN)))
			cAux := SubStr(cAux,IIf(EspacoAt(cAux, MAXMENLIN) > 1, EspacoAt(cAux, MAXMENLIN), MAXMENLIN) + 1)
		EndDo	
	EndIf
	
	If Type("oIdent:_tpAmb:TEXT")<>"U" .And. oIdent:_tpAmb:TEXT=="2"
		cAux := "DANFE emitida no ambiente de homologação - SEM VALOR FISCAL"
		While !Empty(cAux)
			aadd(aMensagem,SubStr(cAux,1,IIf(EspacoAt(cAux, MAXMENLIN) > 1, EspacoAt(cAux, MAXMENLIN) - 1, MAXMENLIN)))
			cAux := SubStr(cAux,IIf(EspacoAt(cAux, MAXMENLIN) > 1, EspacoAt(cAux, MAXMENLIN), MAXMENLIN) + 1)
		EndDo
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Inicio Customizado Eletromega ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Type("oNF:_INFNFE:_IDE:_NFREF")=="A" 
		cAux := "Numero da nota original : "
		For nZ:=1 To Len(oNF:_INFNFE:_IDE:_NFREF)
			If Type("oNF:_INFNFE:_IDE:_NFREF["+Str(nZ)+"]:_REFNF")=="O"  // Notas que nao foram emitidas pelo SPED
				If Len(oNF:_INFNFE:_IDE:_NFREF[nZ]:_REFNF:_NNF:TEXT) > 6	
					cAux += Transform(StrZero(Val(oNF:_INFNFE:_IDE:_NFREF[nZ]:_REFNF:_NNF:TEXT),9),'@R 999.999.999')
			    Else
			    	cAux += Transform(StrZero(Val(oNF:_INFNFE:_IDE:_NFREF[nZ]:_REFNF:_NNF:TEXT),6),'@R 999.999')
			    EndIf
			Else  // Notas que Foram emitidas pelo SPED 
				cAux += Transform(SubStr(oNF:_INFNFE:_IDE:_NFREF[nZ]:_REFNFE:TEXT,26,9),'@R 999.999.999')
			EndIf
			If nZ <> Len(oNF:_INFNFE:_IDE:_NFREF)
				cAux += ", "
			EndIf
		Next nZ 
		While !Empty(cAux)
			aadd(aMensagem,SubStr(cAux,1,IIf(EspacoAt(cAux, MAXMENLIN) > 1, EspacoAt(cAux, MAXMENLIN) - 1, MAXMENLIN)))
			cAux := SubStr(cAux,IIf(EspacoAt(cAux, MAXMENLIN) > 1, EspacoAt(cAux, MAXMENLIN), MAXMENLIN) + 1)
		EndDo
	ElseIf Type("oNF:_INFNFE:_IDE:_NFREF:_REFNF:_NNF:TEXT")<>"U" 
		cAux := "Numero da nota original : "
		If Type("oNF:_INFNFE:_IDE:_NFREF:_REFNF")=="O"  // Notas que nao foram emitidas pelo SPED
			If Len(oNF:_INFNFE:_IDE:_NFREF:_REFNF:_NNF:TEXT) > 6
				cAux += Transform(StrZero(Val(oNF:_INFNFE:_IDE:_NFREF:_REFNF:_NNF:TEXT),9),'@R 999.999.999')
		    Else
				cAux += Transform(StrZero(Val(oNF:_INFNFE:_IDE:_NFREF:_REFNF:_NNF:TEXT),6),'@R 999.999')
			EndIf
		Else  // Notas que Foram emitidas pelo SPED
			cAux += Transform(SubStr(oNF:_INFNFE:_IDE:_NFREF:_REFNFE:_NNFE:TEXT,26,9),'@R 999.999.999')
		EndIf
		While !Empty(cAux)
			aadd(aMensagem,SubStr(cAux,1,IIf(EspacoAt(cAux, MAXMENLIN) > 1, EspacoAt(cAux, MAXMENLIN) - 1, MAXMENLIN)))
			cAux := SubStr(cAux,IIf(EspacoAt(cAux, MAXMENLIN) > 1, EspacoAt(cAux, MAXMENLIN), MAXMENLIN) + 1)
		EndDo
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Fim Customizado Eletromega ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	If Type("oNF:_InfNfe:_infAdic:_infCpl:TEXT")<>"U"
		cAux := oNF:_InfNfe:_infAdic:_InfCpl:TEXT
		
		cAux += "     NOVA RAZAO SOCIAL: OUROLUX COMERCIAL LTDA      "
		
		If cFilAnt == "01"
			cAux += " -     NOVO ENDERECO: AV.HUGO FUMAGALI, 770 / CEP 07222-121 / BAIRRO CID IND SATELITE / MUN GUARULHOS / EST SP"
		EndIf
		
		While !Empty(cAux)
			aadd(aMensagem,SubStr(cAux,1,IIf(EspacoAt(cAux, MAXMENLIN) > 1, EspacoAt(cAux, MAXMENLIN) - 1, MAXMENLIN)))
			cAux := SubStr(cAux,IIf(EspacoAt(cAux, MAXMENLIN) > 1, EspacoAt(cAux, MAXMENLIN), MAXMENLIN) + 1)
		EndDo
	EndIf	
	
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Apartir daqui comeca a impressao. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Dados da NF-e                                    					   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//aAdd( aDadImp, PadC("NF-e",20) )
	//aAdd( aDadImp, PadC("N. " + StrZero(Val(oIdent:_NNf:Text),9),20) )	// NUMERO
	//aAdd( aDadImp, PadC("SÉRIE " + oIdent:_Serie:Text,20) )           	// SERIE

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Cabecalho								                               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	DanfeCab(oNFe,oIdent,oEmitente,cCodAutSef,oNfeDPEC,cCodAutDPEC,cDtHrRecCab)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Quadro destinatário/remetente                                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Do Case
		Case Type("oDestino:_CNPJ")=="O"
			cAux := IIF (!Empty(oDestino:_CNPJ:TEXT), TransForm(oDestino:_CNPJ:TEXT,"@r 99.999.999/9999-99"),"")
		Case Type("oDestino:_CPF")=="O"
			cAux := IIF (!Empty(oDestino:_CPF:TEXT), TransForm(oDestino:_CPF:TEXT,"@r 999.999.999-99"),"")
		OtherWise
			cAux := Space(14)
	EndCase
	
	aAdd( aDadImp, oDestino:_XNome:TEXT 	) // NOME/RAZAO SOCIAL  // 13
	aAdd( aDadImp, cAux 					) // CNPJ/CPF           // 14
	aAdd( aDadImp, aDest[01]				) // ENDERECO           // 15
	aAdd( aDadImp, aDest[02]            	) // BAIRRO/DISTRITO    // 16
	aAdd( aDadImp, aDest[03]            	) // CEP                // 17
	aAdd( aDadImp, aDest[05]            	) // MUNICIPIO          // 18
	aAdd( aDadImp, aDest[06]            	) // FONE/FAX           // 19
	aAdd( aDadImp, aDest[07]            	) // UF                 // 20
	aAdd( aDadImp, aDest[08]            	) // INSCRICAO ESTADUAL // 21
		
	aAdd( aDadImp, ConvDate(oIdent:_DEmi:TEXT)) 					// DATA DE EMISSAO    // 22
	aAdd( aDadImp, Iif( Empty(aDest[4]),"",ConvDate(aDest[4])))  	// DATA ENTRADA/SAIDA // 23
	aAdd( aDadImp, aDest[09] ) 										// HORA ENTRADA/SAIDA // 24
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Calculo do imposto                                                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aAdd( aDadImp, aTotais[01] ) // BASE DE CALCULO DO ICMS                 // 25
	aAdd( aDadImp, aTotais[02] ) // VALOR DO ICMS                           // 26
	aAdd( aDadImp, aTotais[03] ) // BASE DE CALCULO DO ICMS SUBSTITUICAO    // 27
	aAdd( aDadImp, aTotais[04] ) // VALOR DO ICMS SUBSTITUICAO              // 28
	aAdd( aDadImp, aTotais[05] ) // VALOR TOTAL DOS PRODUTOS                // 29
	aAdd( aDadImp, aTotais[06] ) // VALOR DO FRETE                          // 30
	aAdd( aDadImp, aTotais[07] ) // VALOR DO SEGURO                         // 31
	aAdd( aDadImp, aTotais[08] ) // DESCONTO                                // 32
	aAdd( aDadImp, aTotais[09] ) // OUTRAS DESPESAS ACESSORIAS              // 33
	aAdd( aDadImp, aTotais[10] ) // VALOR DO IPI                            // 34
	aAdd( aDadImp, aTotais[11] ) // VALOR TOTAL DA NOTA                     // 35
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Transportador/Volumes transportados                                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aAdd( aDadImp, aTransp[01] ) // RAZAO SOCIAL                               // 36
	aAdd( aDadImp, aTransp[02] ) // FRETE POR CONTA 0-EMITENTE/1-DESTINATARIO" // 37
	aAdd( aDadImp, aTransp[03] ) // CODIGO ANTT                                // 38
	aAdd( aDadImp, aTransp[04] ) // PLACA DO VEICULO                           // 39
	aAdd( aDadImp, aTransp[05] ) // UF                                         // 40
	aAdd( aDadImp, aTransp[06] ) // CNPJ/CPF                                   // 41
	aAdd( aDadImp, aTransp[07] ) // ENDERECO                                   // 42
	aAdd( aDadImp, aTransp[08] ) // MUNICIPIO                                  // 43
	aAdd( aDadImp, aTransp[09] ) // UF                                         // 44
	aAdd( aDadImp, aTransp[10] ) // INSCRICAO ESTADUAL                         // 45
	aAdd( aDadImp, aTransp[11] ) // QUANTIDADE                                 // 46
	aAdd( aDadImp, aTransp[12] ) // ESPECIE                                    // 47
	aAdd( aDadImp, aTransp[13] ) // MARCA                                      // 48
	aAdd( aDadImp, aTransp[14] ) // NUMERACAO                                  // 49
	aAdd( aDadImp, aTransp[15] ) // PESO BRUTO                                 // 50
	aAdd( aDadImp, aTransp[16] ) // PESO LIQUIDO                               // 51
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Calculo do ISSQN                                                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aAdd( aDadImp, aISSQN[1] ) // INSCRICAO MUNICIPAL
	aAdd( aDadImp, aISSQN[2] ) // VALOR TOTAL DOS SERVICOS
	aAdd( aDadImp, aISSQN[3] ) // BASE DE CALCULO DO ISSQN
	aAdd( aDadImp, aISSQN[4] ) // VALOR DO ISSQN
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ FUNCAO DE IMPRESSAO ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	ImprimeNF(aDadImp, aItens, aMensagem, aFaturas)
	
Return .T.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ DanfeCab ºAutor  ³Microsiga           º Data ³  05/25/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Definicao do Cabecalho do documento.                       º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function DanfeCab(oNFe,oIdent,oEmitente,cCodAutSef,oNfeDPEC,cCodAutDPEC,cDtHrRecCab)

	Local aUF		 := {}
	Local cChaveCont := ""
	Local cDataEmi   := ""
	Local cDigito    := ""
	Local cTPEmis    := ""
	Local cValIcm    := ""
	Local cICMSp     := ""
	Local cICMSs     := "" 
	Local cUF		 := ""
	Local cCNPJCPF	 := ""
	
	Private oDPEC    :=oNfeDPEC
	
	Default cCodAutSef := ""
	Default cCodAutDPEC:= ""
	Default cDtHrRecCab:= ""
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Preenchimento do Array de UF                                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aadd(aUF,{"RO","11"})
	aadd(aUF,{"AC","12"})
	aadd(aUF,{"AM","13"})
	aadd(aUF,{"RR","14"})
	aadd(aUF,{"PA","15"})
	aadd(aUF,{"AP","16"})
	aadd(aUF,{"TO","17"})
	aadd(aUF,{"MA","21"})
	aadd(aUF,{"PI","22"})
	aadd(aUF,{"CE","23"})
	aadd(aUF,{"RN","24"})
	aadd(aUF,{"PB","25"})
	aadd(aUF,{"PE","26"})
	aadd(aUF,{"AL","27"})
	aadd(aUF,{"MG","31"})
	aadd(aUF,{"ES","32"})
	aadd(aUF,{"RJ","33"})
	aadd(aUF,{"SP","35"})
	aadd(aUF,{"PR","41"})
	aadd(aUF,{"SC","42"})
	aadd(aUF,{"RS","43"})
	aadd(aUF,{"MS","50"})
	aadd(aUF,{"MT","51"})
	aadd(aUF,{"GO","52"})
	aadd(aUF,{"DF","53"})
	aadd(aUF,{"SE","28"})
	aadd(aUF,{"BA","29"})
	aadd(aUF,{"EX","99"})
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Quadro 2                                                                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aAdd( aDadImp, oIdent:_TpNf:Text) 							// 0-Entrada / 1-Saida 	// 01
	//aAdd( aDadImp, IIf(oIdent:_TpNf:Text=="1","SAÍDA","ENTRADA"))
	aAdd( aDadImp, StrZero(Val(oIdent:_NNf:Text),9))			// N.                	// 02
	aAdd( aDadImp, oIdent:_Serie:Text)                 			// SERIE                // 03
	aAdd( aDadImp, "")											// COD BARRA  			// 04

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Chave de Acesso                                                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//MSBAR3("CODE128",2.4*(300/PixelY),12.4*(299/PixelX),SubStr(oNF:_InfNfe:_ID:Text,4),oDanfe,/*lCheck*/,/*Color*/,/*lHorz*/,.02960,0.9,/*lBanner*/,/*cFont*/,"C",.F.)
	aDadImp[04] := SubStr(oNF:_InfNfe:_ID:Text,4)
	aAdd( aDadImp, TransForm(SubStr(oNF:_InfNfe:_ID:Text,4),"@r 9999 9999 9999 9999 9999 9999 9999 9999 9999 9999 9999"))	// 05	
	
	If !Empty(cCodAutDPEC) .And. (oNFe:_NFE:_INFNFE:_IDE:_TPEMIS:TEXT)$"4"
		cUF      := aUF[aScan(aUF,{|x| x[1] == oDPEC:_ENVDPEC:_INFDPEC:_RESNFE:_UF:Text})][02]
		cDataEmi := Substr(oNF:_InfNfe:_IDE:_DEMI:Text,9,2)
		cTPEmis  := "4"
		cValIcm  := StrZero(Val(StrTran(oDPEC:_ENVDPEC:_INFDPEC:_RESNFE:_VNF:TEXT,".","")),14)
		cICMSp   := iif(Val(oDPEC:_ENVDPEC:_INFDPEC:_RESNFE:_VICMS:TEXT)>0,"1","2")
		cICMSs   := iif(Val(oDPEC:_ENVDPEC:_INFDPEC:_RESNFE:_VST:TEXT)>0,"1","2")
	ElseIF (oNFe:_NFE:_INFNFE:_IDE:_TPEMIS:TEXT)$"25"
		cUF      := aUF[aScan(aUF,{|x| x[1] == oNFe:_NFE:_INFNFE:_DEST:_ENDERDEST:_UF:Text})][02]
		cDataEmi := Substr(oNFe:_NFE:_INFNFE:_IDE:_DEMI:Text,9,2)
		cTPEmis  := oNFe:_NFE:_INFNFE:_IDE:_TPEMIS:TEXT
		cValIcm  := StrZero(Val(StrTran(oNFe:_NFE:_INFNFE:_TOTAL:_ICMSTOT:_VNF:TEXT,".","")),14)
		cICMSp   := iif(Val(oNFe:_NFE:_INFNFE:_TOTAL:_ICMSTOT:_VICMS:TEXT)>0,"1","2")
		cICMSs   := iif(Val(oNFe:_NFE:_INFNFE:_TOTAL:_ICMSTOT:_VST:TEXT)>0,"1","2")
	EndIf
	
	If !Empty(cUF) .And. !Empty(cDataEmi) .And. !Empty(cTPEmis) .And. !Empty(cValIcm) .And. !Empty(cICMSp) .And. !Empty(cICMSs)
		If Type("oNF:_InfNfe:_DEST:_CNPJ:Text")<>"U"
			cCNPJCPF := oNF:_InfNfe:_DEST:_CNPJ:Text
			If cUf == "99"
				cCNPJCPF := STRZERO(val(cCNPJCPF),14)
			EndIf
		ElseIf Type("oNF:_INFNFE:_DEST:_CPF:Text")<>"U"
			cCNPJCPF := oNF:_INFNFE:_DEST:_CPF:Text
			cCNPJCPF := STRZERO(val(cCNPJCPF),14)
		Else
			cCNPJCPF := ""
		EndIf
		cChaveCont += cUF+cTPEmis+cCNPJCPF+cValIcm+cICMSp+cICMSs+cDataEmi
		cChaveCont := cChaveCont+Modulo11(cChaveCont)
	EndIf	
	
	If !Empty(cChaveCont) .And. Empty(cCodAutDPEC) .And. !(Val(oNF:_INFNFE:_IDE:_SERIE:TEXT) >= 900)
		If !Empty(cChaveCont)
			//MSBAR3("CODE128",4.5*(300/PixelY),12.4*(300/PixelX),cChaveCont,oDanfe,/*lCheck*/,/*Color*/,/*lHorz*/,.02960,0.9,/*lBanner*/,/*cFont*/,"C",.F.)
		    //aDadImp[04] := cChaveCont	
		EndIf
	Else
			aAdd( aDadImp, "Consulta de autenticidade no portal nacional da NF-e")	          	// 06
			aAdd( aDadImp, "www.nfe.fazenda.gov.br/portal ou no site da SEFAZ Autorizada")		// 07		
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Quadro 4                                                                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aAdd( aDadImp, oIdent:_NATOP:TEXT) // NATUREZA DA OPERACAO	// 08
	 
   	aAdd( aDadImp, (IIF(!Empty(cCodAutDPEC),"NUMERO DE REGISTRO DPEC",IIF(((Val(oNF:_INFNFE:_IDE:_SERIE:TEXT) >= 900).And.(oNFe:_NFE:_INFNFE:_IDE:_TPEMIS:TEXT)$"2") .Or. (oNFe:_NFE:_INFNFE:_IDE:_TPEMIS:TEXT)$"1","PROTOCOLO DE AUTORIZACAO DE USO",IIF((oNFe:_NFE:_INFNFE:_IDE:_TPEMIS:TEXT)$"25","DADOS DA NF-E","")))+" "+;
			IIF(!Empty(cCodAutDPEC),cCodAutDPEC+" "+AllTrim(ConvDate(oNF:_InfNfe:_IDE:_DEMI:Text))+" "+AllTrim(cDtHrRecCab),IIF(!Empty(cCodAutSef) .And. ((Val(oNF:_INFNFE:_IDE:_SERIE:TEXT) >= 900).And.(oNFe:_NFE:_INFNFE:_IDE:_TPEMIS:TEXT)$"2") .Or. (oNFe:_NFE:_INFNFE:_IDE:_TPEMIS:TEXT)$"1",cCodAutSef+" "+AllTrim(ConvDate(oNF:_InfNfe:_IDE:_DEMI:Text))+" "+AllTrim(cDtHrRecCab),TransForm(cChaveCont,"@r 9999 9999 9999 9999 9999 9999 9999 9999 9999"))))) // 09

	aAdd( aDadImp, IIf(Type("oEmitente:_IE:TEXT")<>"U",oEmitente:_IE:TEXT,"")) 	// INSCRICAO ESTADUAL                                     	// 10
	aAdd( aDadImp, IIf(Type("oEmitente:_IEST:TEXT")<>"U",oEmitente:_IEST:TEXT,""))	// INSC.ESTADUAL DO SUBST.TRIB.                           	// 11
	aAdd( aDadImp, IIf(Type("oEmitente:_CNPJ:TEXT")<>"U",TransForm(oEmitente:_CNPJ:TEXT,IIf(Len(oEmitente:_CNPJ:TEXT)<>14,"@r 999.999.999-99","@r 99.999.999/9999-99"))," ")) // CNPJ  	// 12
 
Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ GetXML	ºAutor  ³Microsiga           º Data ³  05/25/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function GetXML(cIdEnt,aIdNFe,cModalidade)  

Local aRetorno		:= {}
Local aDados		:= {}

Local cURL			:= PadR(GetNewPar("MV_SPEDURL","http://localhost:8080/sped"),250)
Local cModel		:= "55"


Local nZ			:= 0
Local nCount		:= 0

Local oWS

If Empty(cModalidade)    

	oWS := WsSpedCfgNFe():New()
	oWS:cUSERTOKEN := "TOTVS"
	oWS:cID_ENT    := cIdEnt
	oWS:nModalidade:= 0
	oWS:_URL       := AllTrim(cURL)+"/SPEDCFGNFe.apw"
	oWS:cModelo    := cModel 
	
	If oWS:CFGModalidade()
		cModalidade    := SubStr(oWS:cCfgModalidadeResult,1,1)
	Else
		cModalidade    := ""
	EndIf  
	
EndIf  
         
oWs := nil

For nZ := 1 To len(aIdNfe) 

    nCount++

	aDados := executeRetorna( aIdNfe[nZ], cIdEnt )
	
	if ( nCount == 10 )
		delClassIntF()
		nCount := 0
	endif
	
	aAdd(aRetorno,aDados)
	
Next nZ

Return(aRetorno)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ ConvDate	ºAutor  ³Microsiga           º Data ³  05/25/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function ConvDate(cData)

	Local dData
	cData  := StrTran(cData,"-","")
	dData  := Stod(cData)

Return PadR(StrZero(Day(dData),2)+ "/" + StrZero(Month(dData),2)+ "/" + StrZero(Year(dData),4),15)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³EspacoAt  ºAutor  ³Marcos Taranta      º Data ³  10/01/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Pega uma posição (nTam) na string cString, e retorna o      º±±
±±º          ³caractere de espaço anterior.                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function EspacoAt(cString, nTam)

	Local nRetorno := 0
	Local nX       := 0
	
	/**
	 * Caso a posição (nTam) for maior que o tamanho da string, ou for um valor
	 * inválido, retorna 0.
	 */
	If nTam > Len(cString) .Or. nTam < 1
		nRetorno := 0
		Return nRetorno
	EndIf
	
	/**
	 * Procura pelo caractere de espaço anterior a posição e retorna a posição
	 * dele.
	 */
	nX := nTam
	While nX > 1
		If Substr(cString, nX, 1) == " "
			nRetorno := nX
			Return nRetorno
		EndIf
		
		nX--
	EndDo
	
	/**
	 * Caso não encontre nenhum caractere de espaço, é retornado 0.
	 */
	nRetorno := 0

Return nRetorno

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ ImprimeNF  ºAutor  ³Wilson A. Silva Jr. º Data ³ 05/26/10  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Imprime os Dados da Nota Fiscal.	       		              º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ ELETROMEGA                                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function	ImprimeNF(aDadImp, aItens, aMensagem, aFaturas)

	Local aArea		:= GetArea()
	Local cNumNF    := ""
	Local nX		:= 0 
	Local nY		:= 0
	
	//Private aCol 	:= { 001, 002, 003, 004, 005, 006, 007, 008, 009, 010, 011, 012, 013, 014, 015, 016, 017, 018, 019, 020, 021, 022, 023, 024, 025, 026, 027, 028, 029, 030, 031, 032, 033, 034, 035, 036 }
	Private aCol 	:= { 004, 021, 035, 054, 060, 068, 084, 085, 095, 096, 101, 105, 109, 112, 116, 117, 123, 126, 128, 131, 134, 136, 139, 147, 160, 162, 168, 172, 183, 200, 206, 215, 218, 229, 241, 247 }
	//Private aLin 	:= {  01,  02,  03,  04,  05,  06,  07,  08,  09,  10,  11,  12,  13,  14,  15,  16,  17,  18 } 
	Private aLin 	:= {  02,  04,  05,  07,  08,  11,  13,  15,  17,  19,  21,  23,  25,  27,  29,  31,  34,  56 }

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Blindagem contra erros de Campos Vazios. ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nX:=1 To Len(aDadImp)
		aDadImp[nX] := IIf (!Empty(AllTrim(aDadImp[nX])), aDadImp[nX], " ") 
	Next nX 
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Blindagem contra erros de Campos Vazios. ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nX:=1 To Len(aItens)
		For nY:=1 To Len(aItens[nX])
			aItens[nX,nY] := IIf (!Empty(AllTrim(aItens[nX,nY])), aItens[nX,nY], " ") 
   		Next nY
	Next nX 
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ POSICIONA IMPRESSORA ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	setprc(0,0)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Imprime o cabeçalho da nota fiscal           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	PACabec(aDadImp, aFaturas)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Imprime os itens (produtos) da nota fiscal   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ  
	cNumNF := aDadImp[02]
   	aItens := aSort( aItens,,, { |x, y| x[ 1 ] < y[ 1 ] } )  // Codigo de produto crescente 21/05/2013 war
   	
   	PAItens(aItens, cNumNF) 
 
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Imprime os dados adicionais da Nota Fiscal   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
	PAAdicionais(aMensagem)
	
	RestArea(aArea)

Return	

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ PACabec	  ºAutor  ³Wilson A. Silva Jr. º Data ³ 05/26/10  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Imprime o cabecalho da Nota Fiscal.                        º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ ELETROMEGA                                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function PACabec(aDadImp, aFaturas)
    
	Local aArea     := GetArea()
	Local nX  
	  
    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Codigo de Barra  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
	@ 000, 001 PSAY Chr(15) 
	@ 001, 147 PSAY CHR(27)+CHR(40)+CHR(66)+CHR(51)+CHR(00)+CHR(06)+CHR(01)+CHR(00)+CHR(21)+CHR(00)+CHR(03)+CHR(67)+aDadImp[04]
    //27 40 66 51 00 06 01 00 21 00 03 67
	//27 40 66 43 00 06 01 00 21 00 03 67 

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Compressao da Impressao  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	@ 001, _PCol()+1 PSAY " "+Chr(15) 
	@ 001, _PCol()+1 PSAY CHR(27)+"0" 
	
	@ aLin[01], aCol[01] PSAY aDadImp[02] // N. NF CAMPO 1    	
	
	@ aLin[02], aCol[17] PSAY aDadImp[01] // 0-ENTRADA ou 1-SAIDA
	
	@ aLin[03], aCol[22] PSAY aDadImp[05] // CHAVE DE ACESSO
	
	@ aLin[04], aCol[14] PSAY aDadImp[02] // N. NF CAMPO 2
	@ aLin[04], aCol[22] PSAY aDadImp[06] // INF SITE Parte 1
	
	@ aLin[05], aCol[15] PSAY aDadImp[03] // SERIE
	@ aLin[05], aCol[18] PSAY "01/01"	   // FOLHA
	@ aLin[05], aCol[22] PSAY aDadImp[07] // INF SITE Parte 2
	
	@ aLin[06], aCol[02] PSAY aDadImp[08] // Natureza de Operacao
	@ aLin[06], aCol[22] PSAY aDadImp[09] // DADOS DA NF-e
	
	If !Empty(aDadImp[10])
		@ aLin[07], aCol[02] PSAY aDadImp[10] //Picture "@R 999.999.999.999" // INSCRICAO ESTADUAL
	EndIf
	If !Empty(aDadImp[11])
		@ aLin[07], aCol[10] PSAY aDadImp[11] // INSC.ESTADUAL DO SUBST.TRIB.
	EndIf
	@ aLin[07], aCol[27] PSAY aDadImp[12] // CNPJ
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ DESTINATARIO / REMETENTE  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		    
	@ aLin[08], aCol[02] PSAY aDadImp[13] // NOME/RAZAO SOCIAL
	@ aLin[08], aCol[28] PSAY aDadImp[14] // CNPJ/CPF
	@ aLin[08], aCol[33] PSAY aDadImp[22] // DATA DE EMISSAO
	
	@ aLin[09], aCol[02] PSAY aDadImp[15] // ENDERECO
	@ aLin[09], aCol[18] PSAY aDadImp[16] // BAIRRO/DISTRITO
	If !Empty(aDadImp[17])
		@ aLin[09], aCol[28] PSAY aDadImp[17] Picture "@R 99999-999"// CEP
	EndIf
	@ aLin[09], aCol[33] PSAY aDadImp[23] // DATA ENTRADA/SAIDA 
	
	@ aLin[10], aCol[02] PSAY aDadImp[18] // MUNICIPIO
	@ aLin[10], aCol[12] PSAY aDadImp[19] // FONE/FAX
	@ aLin[10], aCol[26] PSAY aDadImp[20] // UF	
	If !Empty(aDadImp[21])
		@ aLin[10], aCol[28] PSAY aDadImp[21] //Picture "@R 999.999.999.999" // INSCRICAO ESTADUAL
	EndIf
	@ aLin[10], aCol[33] PSAY aDadImp[24] // HORA ENTRADA/SAIDA
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ IMPRESSAO DE DUPLICATAS ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Len(aFaturas) > 0
		@ aLin[11], aCol[02] PSAY aFaturas[1]

		For nX:=2 To Len(aFaturas)
			If _PCol()+3+Len(aFaturas[nX]) <= MAXDUP
				@ aLin[11], _PCol() PSAY " | "+aFaturas[nX] // FATURA DUPLICATA
			Else
				EXIT 
			EndIf
		Next nX
	EndIf
	
	//aFaturas := { {Dup,dtVenc,vDup} , {Dup,dtVenc,vDup} , {Dup,dtVenc,vDup} }
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ CALCULO DOS IMPOSTOS                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	@ aLin[12], aCol[02] PSAY aDadImp[25] // BASE DE CALCULO DO ICMS
	@ aLin[12], aCol[06] PSAY aDadImp[26] // VALOR DO ICMS
	@ aLin[12], aCol[13] PSAY aDadImp[27] // BASE DE CALCULO DO ICMS SUBSTITUICAO
	@ aLin[12], aCol[28] PSAY aDadImp[28] // VALOR DO ICMS SUBSTITUICAO
	@ aLin[12], aCol[32] PSAY aDadImp[29] // VALOR TOTAL DOS PRODUTOS
	
	@ aLin[13], aCol[02] PSAY aDadImp[30] // VALOR DO FRETE 
	@ aLin[13], aCol[05] PSAY aDadImp[31] // VALOR DO SEGURO
	@ aLin[13], aCol[09] PSAY aDadImp[32] // DESCONTO
	@ aLin[13], aCol[19] PSAY aDadImp[33] // OUTRAS DESPESAS ACESSORIAS
	@ aLin[13], aCol[28] PSAY aDadImp[34] // VALOR DO IPI
	@ aLin[13], aCol[32] PSAY aDadImp[35] // VALOR TOTAL DA NOTA	
		
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ TRANSPORTADOR / VOLUMES TRANSPORTADOS  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	@ aLin[14], aCol[02] PSAY aDadImp[36] // RAZAO SOCIAL
	@ aLin[14], aCol[21] PSAY aDadImp[37] // 0-EMITENTE ou 1-DESTINATARIO
	@ aLin[14], aCol[23] PSAY aDadImp[38] // CODIGO ANTT
	@ aLin[14], aCol[25] PSAY aDadImp[39] // PLACA DO VEICULO
	@ aLin[14], aCol[31] PSAY aDadImp[40] // UF
	@ aLin[14], aCol[32] PSAY aDadImp[41] // CNPJ/CPF
		
	@ aLin[15], aCol[02] PSAY aDadImp[42] // ENDERECO
	@ aLin[15], aCol[16] PSAY aDadImp[43] // MUNICIPIO
	@ aLin[15], aCol[31] PSAY aDadImp[44] // UF
	If !Empty(aDadImp[45]) 
		@ aLin[15], aCol[32] PSAY aDadImp[45] //Picture "@R 999.999.999.999" // INSCRICAO ESTADUAL
	EndIf
	
	@ aLin[16], aCol[02] PSAY aDadImp[46] // QUANTIDADE
	@ aLin[16], aCol[04] PSAY aDadImp[47] // ESPECIE
	@ aLin[16], aCol[07] PSAY aDadImp[48] // MARCA
	@ aLin[16], aCol[16] PSAY aDadImp[49] // NUMERACAO
	@ aLin[16], aCol[25] PSAY aDadImp[50] // PESO BRUTO
	@ aLin[16], aCol[32] PSAY aDadImp[51] // PESO LIQUIDO 
	
	//@ aLin[17], aCol[01] PSAY aDadImp[02] // N. NF CAMPO 3	  

	RestArea(aArea)	 

Return .T.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ PAItens	  ºAutor  ³Wilson A. Silva Jr. º Data ³ 05/26/10  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Imprime os Itens da Nota Fiscal.                           º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ ELETROMEGA                                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function PAItens(aItens, cNumNF)

	Local aArea     := GetArea()          
	Local nItem		:= 0
    Local nLin 		:= aLin[17]
	
	For nItem := 1 To MAXITEM  
		If nItem <= Len(aItens)	
			
			@ nLin, aCol[02] PSAY aItens[nItem,01] // CODIGO DO PRODUTO
			@ nLin, aCol[03] PSAY aItens[nItem,02] // DESCRICAO DO PRODUTO/SERVICO
			@ nLin, aCol[08] PSAY aItens[nItem,03] // NCM/SH
			@ nLin, aCol[09] PSAY aItens[nItem,04] // CST
			@ nLin, aCol[11] PSAY aItens[nItem,05] // CFOP
			@ nLin, aCol[13] PSAY aItens[nItem,06] // UN
			@ nLin, aCol[16] PSAY aItens[nItem,07] // QUANTIDADE
			@ nLin, aCol[20] PSAY aItens[nItem,08] // V.UNITARIO
			@ nLin, aCol[24] PSAY aItens[nItem,09] // V.TOTAL
			@ nLin, aCol[27] PSAY aItens[nItem,10] // BC.ICMS
			@ nLin, aCol[32] PSAY aItens[nItem,11] // V.ICMS
			@ nLin, aCol[34] PSAY aItens[nItem,12] // V.IPI
			@ nLin, aCol[35] PSAY aItens[nItem,13] // A.ICM
			@ nLin, aCol[36] PSAY aItens[nItem,14] // A.IPI 
			@ nLin, aCol[29] PSAY aItens[nItem,15] // BC. ICMS ST
			@ nLin, aCol[30] PSAY aItens[nItem,16] // V. ICMS ST
			
			nLin ++
			
			If nLin == (aLin[17]+1)  // Segunda linha de Detalhe
				@ nLin, aCol[01] PSAY cNumNF // N. NF CAMPO 3	
			EndIf
		
		EndIf
	Next nItem
	
	If nLin == 54
		If cFilAnt == "01"
			@ nLin++ , aCol[03] PSAY "NOVA RAZAO SOCIAL: OUROLUX COMERCIAL LTDA - NOVO ENDERECO: AV.HUGO FUMAGALI, 770 / CEP 07222-121 / BAIRRO CID IND SATELITE / MUN GUARULHOS / EST SP"
		Else
			@ nLin++ , aCol[09] PSAY "NOVA RAZAO SOCIAL: OUROLUX COMERCIAL LTDA" 
		EndIf
	Else
		If cFilAnt == "01"
			@ nLin+2 , aCol[03] PSAY "NOVA RAZÃO SOCIAL: OUROLUX COMERCIAL LTDA - NOVO ENDERECO: AV.HUGO FUMAGALI, 770 / CEP 07222-121 / BAIRRO CID IND SATELITE / MUN GUARULHOS / EST SP"	
		Else
			@ nLin+2 , aCol[09] PSAY "NOVA RAZÃO SOCIAL: OUROLUX COMERCIAL LTDA"
	    EndIf
	EndIf
	
	RestArea(aArea)
	
Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PAAdicionaisºAutor  ³Wilson A. Silva Jr. º Data ³ 05/26/10  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Imprime os Dados Adicionais da Nota Fiscal.                º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ ELETROMEGA                                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function PAAdicionais(aMensagem)
    
    Local nX   := 0
    Local cAux := "" 
    Local nLin := aLin[18] 
    Local nConLin := 1
    
    /*
	For nX:=1 To Len(aMensagem)		
		cAux := aMensagem[nX]
		While !Empty(cAux)
		    If MAXMSGL >= Len(aMensagem)
				@ nLin, aCol[02] PSAY (SubStr(cAux,1,IIf(EspacoAt(cAux, MAXMENLIN) > 1, EspacoAt(cAux, MAXMENLIN) - 1, MAXMENLIN)))
			EndIf
			cAux := SubStr(cAux,IIf(EspacoAt(cAux, MAXMENLIN) > 1, EspacoAt(cAux, MAXMENLIN), MAXMENLIN) + 1)
			nLin++
		EndDo				
	Next nX
	*/
	
	For nX:=1 To Len(aMensagem)		
		cAux += aMensagem[nX]+"  "
	Next nX
	While !Empty(cAux)
	    If MAXMSGL >= nConLin
			@ nLin, aCol[02] PSAY (SubStr(cAux,1,IIf(EspacoAt(cAux, MAXMENLIN) > 1, EspacoAt(cAux, MAXMENLIN) - 1, MAXMENLIN)))
		EndIf
		cAux := SubStr(cAux,IIf(EspacoAt(cAux, MAXMENLIN) > 1, EspacoAt(cAux, MAXMENLIN), MAXMENLIN) + 1)
		nLin++
		nConLin++
	EndDo
Return .T.

//-----------------------------------------------------------------------
/*/{Protheus.doc} executeRetorna
Executa o retorna de notas

@author Henrique Brugugnoli
@since 17/01/2013
@version 1.0 

@param  cID ID da nota que sera retornado

@return aRetorno   Array com os dados da nota
/*/
//-----------------------------------------------------------------------
static function executeRetorna( aNfe, cIdEnt )

Local aExecute		:= {}  
Local aFalta		:= {}
Local aResposta		:= {}
Local aRetorno		:= {}
Local aDados		:= {} 
Local aIdNfe		:= {}

Local cAviso		:= "" 
Local cDHRecbto		:= ""
Local cDtHrRec		:= ""
Local cDtHrRec1		:= ""
Local cErro			:= "" 
Local cModTrans		:= ""
Local cProtDPEC		:= ""
Local cProtocolo	:= ""
Local cRetDPEC		:= ""
Local cRetorno		:= ""
Local cURL			:= PadR(GetNewPar("MV_SPEDURL","http://localhost:8080/sped"),250)
Local cModel		:= "55"

Local dDtRecib		:= CToD("")

Local lFlag			:= .T.

Local nDtHrRec1		:= 0
Local nL			:= 0
Local nX			:= 0
Local nY			:= 0
Local nZ			:= 1
Local nCount		:= 0
Local nLenNFe
Local nLenWS

Local oWS

Private oDHRecbto
Private oNFeRet

aAdd(aIdNfe,aNfe)

oWS:= WSNFeSBRA():New()
oWS:cUSERTOKEN        := "TOTVS"
oWS:cID_ENT           := cIdEnt
oWS:nDIASPARAEXCLUSAO := 0
oWS:_URL 			  := AllTrim(cURL)+"/NFeSBRA.apw"
oWS:oWSNFEID          := NFESBRA_NFES2():New()
oWS:oWSNFEID:oWSNotas := NFESBRA_ARRAYOFNFESID2():New()  

aadd(aRetorno,{"","",aIdNfe[nZ][4]+aIdNfe[nZ][5],"","","",CToD(""),""})

aadd(oWS:oWSNFEID:oWSNotas:oWSNFESID2,NFESBRA_NFESID2():New())
Atail(oWS:oWSNFEID:oWSNotas:oWSNFESID2):cID := aIdNfe[nZ][4]+aIdNfe[nZ][5]

If oWS:RETORNANOTASNX()
	If Len(oWs:oWSRETORNANOTASNXRESULT:OWSNOTAS:OWSNFES5) > 0
		For nX := 1 To Len(oWs:oWSRETORNANOTASNXRESULT:OWSNOTAS:OWSNFES5)
			cRetorno        := oWs:oWSRETORNANOTASNXRESULT:OWSNOTAS:OWSNFES5[nX]:oWSNFE:CXML
			cProtocolo      := oWs:oWSRETORNANOTASNXRESULT:OWSNOTAS:OWSNFES5[nX]:oWSNFE:CPROTOCOLO
			cDHRecbto  		:= oWs:oWSRETORNANOTASNXRESULT:OWSNOTAS:OWSNFES5[nX]:oWSNFE:CXMLPROT
			oNFeRet			:= XmlParser(cRetorno,"_",@cAviso,@cErro)
			cModTrans		:= IIf(Type("oNFeRet:_NFE:_INFNFE:_IDE:_TPEMIS:TEXT") <> "U",IIf (!Empty("oNFeRet:_NFE:_INFNFE:_IDE:_TPEMIS:TEXT"),oNFeRet:_NFE:_INFNFE:_IDE:_TPEMIS:TEXT,1),1)
			If ValType(oWs:OWSRETORNANOTASNXRESULT:OWSNOTAS:OWSNFES5[nX]:OWSDPEC)=="O"
				cRetDPEC        := oWs:oWSRETORNANOTASNXRESULT:OWSNOTAS:OWSNFES5[nX]:oWSDPEC:CXML
				cProtDPEC       := oWs:oWSRETORNANOTASNXRESULT:OWSNOTAS:OWSNFES5[nX]:oWSDPEC:CPROTOCOLO
			EndIf
					
			//Tratamento para gravar a hora da transmissao da NFe
			If !Empty(cProtocolo)
				oDHRecbto		:= XmlParser(cDHRecbto,"","","")
				cDtHrRec		:= IIf(Type("oDHRecbto:_ProtNFE:_INFPROT:_DHRECBTO:TEXT")<>"U",oDHRecbto:_ProtNFE:_INFPROT:_DHRECBTO:TEXT,"")
				nDtHrRec1		:= RAT("T",cDtHrRec)
				
				If nDtHrRec1 <> 0
					cDtHrRec1   :=	SubStr(cDtHrRec,nDtHrRec1+1)
					dDtRecib	:=	SToD(StrTran(SubStr(cDtHrRec,1,AT("T",cDtHrRec)-1),"-",""))
				EndIf
				dbSelectArea("SF2")
				dbSetOrder(1)
				If MsSeek(xFilial("SF2")+aIdNFe[nZ][5]+aIdNFe[nZ][4]+aIdNFe[nZ][6]+aIdNFe[nZ][7])
					If SF2->(FieldPos("F2_HORA"))<>0 .And. Empty(SF2->F2_HORA)
						RecLock("SF2")
						SF2->F2_HORA := cDtHrRec1
						MsUnlock()
					EndIf
				EndIf
				dbSelectArea("SF1")
				dbSetOrder(1)
				If MsSeek(xFilial("SF1")+aIdNFe[nZ][5]+aIdNFe[nZ][4]+aIdNFe[nZ][6]+aIdNFe[nZ][7])
					If SF1->(FieldPos("F1_HORA"))<>0 .And. Empty(SF1->F1_HORA)
						RecLock("SF1")
						SF1->F1_HORA := cDtHrRec1
						MsUnlock()
					EndIf
				EndIf
			EndIf
			nY := aScan(aIdNfe,{|x| x[4]+x[5] == SubStr(oWs:oWSRETORNANOTASNXRESULT:OWSNOTAS:OWSNFES5[nX]:CID,1,Len(x[4]+x[5]))})
			If nY > 0
				aRetorno[nY][1] := cProtocolo
				aRetorno[nY][2] := cRetorno
				aRetorno[nY][4] := cRetDPEC
				aRetorno[nY][5] := cProtDPEC
				aRetorno[nY][6] := cDtHrRec1
				aRetorno[nY][7] := dDtRecib
				aRetorno[nY][8] := cModTrans
				
				//aadd(aResposta,aIdNfe[nY])
			EndIf
			cRetDPEC := ""
			cProtDPEC:= ""
		Next nX
		/*For nX := 1 To Len(aIdNfe)
			If aScan(aResposta,{|x| x[4] == aIdNfe[nX,04] .And. x[5] == aIdNfe[nX,05] })==0
			
				conout("Falta")
				conout(aIdNfe[nX][4]+" - "+aIdNfe[nX][5])
				aadd(aFalta,aIdNfe[nX])
			EndIf
		Next nX
		If Len(aFalta)>0
			aExecute := GetXML(cIdEnt,aFalta,@cModalidade)
		Else
			aExecute := {}
		EndIf*/
		/*For nX := 1 To Len(aExecute)
			nY := aScan(aRetorno,{|x| x[3] == aExecute[nX][03]})
			If nY == 0
				aadd(aRetorno,{aExecute[nX][01],aExecute[nX][02],aExecute[nX][03]})
			Else
				aRetorno[nY][01] := aExecute[nX][01]
				aRetorno[nY][02] := aExecute[nX][02]
			EndIf
		Next nX*/
	EndIf
Else
	Aviso("DANFE",IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3)),{"OK"},3)
EndIf 

oWS       := Nil
oDHRecbto := Nil
oNFeRet   := Nil

return aRetorno[len(aRetorno)]