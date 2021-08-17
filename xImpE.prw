#Include "Protheus.ch"
 /*
+===========================================================================+
|Consultoria:                Q S   d o   B R A S I L                        |
+---------------------------------------------------------------------------+
|Programa   | xImpE		|Autor  | Vitor Lopes        | Data |  22/07/14     |
+---------------------------------------------------------------------------+
|Descricao  | Rotina de impressão de etiquetas para identificação de  		|
|           | endereço.													    |
|           |															    |
+---------------------------------------------------------------------------+
|Uso        | MP11 - Cliente: OuroLux									    |
+---------------------------------------------------------------------------+
|Solicitante| 							       						        |
+---------------------------------------------------------------------------+
|Alteracoes | Descrição....:    											|
|           | Solicitante..:    	      									|
|           | Data.........: 			   							        |
|           | Consultor....:											    |
+===========================================================================+
*/ 
*********************
User Function xImpE()
*********************

Local oGroup1
Local oGroup2
Local oGroup3

Private cLocal
Private cEndIni
Private cEndFin
Private aEndCol
Private oDlg
Private nOpca
Private oFont15
Private aCombo := {}
Private cImp
Private aItemsPos
Private aItemsEst
Private cComboPos
Private cComboEst
Private cEndUp
Private cEndDown
Private aImpres  := {""}  
Private cMensagem := ""  
Private cGet0 := Space(02) //Armazem
Private cGet1 := Space(15) //Endereço Inicial
Private cGet2 := Space(15) //Endereço Final
Private cGet3 := Space(06) //Impressora
Private cEnde := Space(15) 

// Claudino
Private cQtEtiq := Space(4)

Private cRua 	:= ""
Private cPredio := ""
Private cNivel  := ""  
Private cPos	:= ""
Private nCont    := 0  

Private nSoma   := 0
Private aTeste  := {} 

Private nImp	:= 0


oFont15  	:= TFont():New("Arial",9,13,.T.,.F.,5,.T.,5,.T.,.F.)
cLocal		:=	SPACE(2)
cEndIni		:=	SPACE(15)
cEndFin		:=	SPACE(15)
cImp		:=	SPACE(6)
nOpca		:=	2
aItemsPos	:=	{"0-S/SETA","1-DIREITA","2-ESQUERDA"}  
aItemsEst	:=	{"1-SIMPLES","2-DUPLA"} 
aItensL		:=  {"1-IMPAR","2-PAR"}
cComboPos	:=	"0-S/SETA" 
cComboEst   :=  "1-SIMPLES"            
cCombol		:=  "1-IMPAR"
cEndUp		:= 	""
cEndDown	:= 	""
/*

@ C(01),C(02)	SAY "Armazém / Local"	SIZE C(80),C(10)	FONT oFont15 COLOR CLR_BLUE	PIXEL OF oDlg
@ C(1.3),C(01)	MSGET cLocal  SIZE C(30),C(10)

@ 024,5	SAY "Endereço Inicial"			SIZE 080,010	FONT oFont15 COLOR CLR_BLUE	PIXEL OF oDlg  
@ 035,5 MSGET cGet1 VAR cEndIni         SIZE 090,010 	PIXEL  OF oDlg //F3 "SBE"

@ C(48),C(1.3) SAY "Endereço Final"		SIZE C(80),C(10)	FONT oFont15 COLOR CLR_BLUE	PIXEL OF oDlg
@ C(5),C(1.5) MSGET cEndFin 			SIZE C(80),C(10)

@ C(70),C(1.3) SAY "Impressão"			SIZE C(80),C(10)	FONT oFont15 COLOR CLR_BLUE	PIXEL OF oDlg
@ C(6.5),C(1.5) MSGET cImp 				SIZE C(80),C(10)  //F3 "SB1"   
 
@ C(1.3),C(100) SAY "Lado"				SIZE C(80),C(10)    FONT oFont15 COLOR CLR_BLUE PIXEL OF oDlg
@ C(12.3),C(100)Combobox cCombol	     Items aItensL Size c(055), c(007)				PIXEL OF oDlg

@ C(26.3),C(100) SAY "1º Posição"		SIZE C(80),C(10)	FONT oFont15 COLOR CLR_BLUE	PIXEL OF oDlg
@ C(36),C(100) ComboBox cComboPos 		Items aItemsPos Size C(055),C(007)            	PIXEL OF oDlg

// Claudino
@ C(55),C(100) SAY "Quant Etiquetas"	SIZE C(080),C(010) FONT oFont15 COLOR CLR_BLUE PIXEL OF oDlg  
@ 75,115 MSGET cQtEtiq SIZE 040,10 PIXEL  OF oDlg

@ C(80),C(100) SAY "Estrutura"		    SIZE C(80),C(10)	FONT oFont15 COLOR CLR_BLUE	PIXEL OF oDlg
@ C(90),C(100) ComboBox cComboEst 		Items aItemsEst Size C(055),C(007)            	PIXEL OF oDlg

DEFINE SBUTTON FROM C(100),C(60)	TYPE 1 ACTION (nOpca := 1,oDlg:End()) ENABLE OF oDlg
DEFINE SBUTTON FROM C(100),C(93)	TYPE 2 ACTION (nOpca := 2,oDlg:End()) ENABLE OF oDlg


*/
DEFINE MSDIALOG oDlg TITLE "ETIQUETA ENDERECO" FROM 000, 000  TO 450, 500 COLORS 0, 16777215 PIXEL

@ 003, 002 GROUP oGroup1 TO 100, 243 PROMPT "Localização" OF oDlg COLOR 0, 16777215 PIXEL
@ 105, 003 GROUP oGroup2 TO 145, 243 PROMPT "Layout" 	  OF oDlg COLOR 0, 16777215 PIXEL
@ 150, 004 GROUP oGroup3 TO 195, 242 PROMPT "Impressão"   OF oDlg COLOR 0, 16777215 PIXEL

@ 016, 008	SAY "Armazém / Local"			SIZE 068,008	FONT oFont15 COLOR CLR_BLACK	PIXEL OF oDlg
@ 026, 008	MSGET cGet0 VAR cLocal			SIZE 023,010	PIXEL   OF oDlg //F3 "NNR"

@ 045, 008	SAY "Endereço Inicial"			SIZE 080,008	FONT oFont15 COLOR CLR_BLACK	PIXEL OF oDlg 
@ 055, 008 	MSGET cGet1 VAR cEndIni         SIZE 060,010 	PIXEL   OF oDlg //F3 "SBE"

@ 045,084 SAY "Endereço Final"				SIZE 080,008	FONT oFont15 COLOR CLR_BLACK 	PIXEL OF oDlg
@ 055,084 MSGET cGet2 VAR cEndFin			SIZE 060,010	PIXEL   OF oDlg //F3 "SBE"

@ 074,008 SAY "Lado da Rua"					SIZE 080,008    FONT oFont15 COLOR CLR_BLACK 	PIXEL OF oDlg
@ 084,008 Combobox cCombol	 Items aItensL 	SIZE 060, 010	PIXEL OF oDlg

@ 074,084 SAY "1º Prédio"		   			SIZE 080,008	FONT oFont15 COLOR CLR_BLACK 	PIXEL OF oDlg
@ 084,084 ComboBox cComboPos Items aItemsPos SIZE 060,010   PIXEL OF oDlg

@ 118,008 SAY "Estrutura"		    		SIZE 080,008	FONT oFont15 COLOR CLR_BLACK	PIXEL OF oDlg
@ 128,008 ComboBox cComboEst Items aItemsEst SIZE 060,010    PIXEL OF oDlg

// Claudino
@ 163,008 SAY "Qtd Etiquetas"					SIZE 080,008 FONT oFont15 COLOR CLR_BLACK PIXEL OF oDlg  
@ 173,008 MSGET cQtEtiq 						SIZE 040,10 							  PIXEL  OF oDlg

@ 163,084 SAY "Impressora"						SIZE 080,008	FONT oFont15 COLOR CLR_BLACK	PIXEL OF oDlg
@ 173,084 MSGET cImp 							SIZE 060,010  	PIXEL  OF oDlg //F3 "CB5"


DEFINE SBUTTON FROM 200,90	TYPE 1 ACTION (nOpca := 1,oDlg:End()) ENABLE OF oDlg
DEFINE SBUTTON FROM 200,123	TYPE 2 ACTION (nOpca := 2,oDlg:End()) ENABLE OF oDlg


ACTIVATE MSDIALOG oDlg CENTERED

If nOpca == 1 //Se clicar no botão ok.

cEndIni	:= AllTrim(cEndIni)//Guarda a informação do endereço inicial.
cEndFin	:= AllTrim(cEndFin)//Guarda a informação do endereço final. 

	//Estrutura Dupla.
	If SubStr(cComboEst,1,1) == "2"
	
		If cEndIni = cEndFin //Se o endereço inicial e o endereço final forem iguais.
		
					DbSelectArea("CB5")
					DbSetOrder(1)                                                                     
					
					If DbSeek(xFilial("CB5")+cImp)
						
						If CB5->CB5_TIPO == "3" 		//SPOOL
							
							MSCBPRINTER(AllTrim(CB5->CB5_MODELO),"LPT1",,,.f.,,,,,AllTrim(CB5->CB5_FILA))
							
						Else
							MSCBPRINTER(AllTrim(CB5->CB5_MODELO),"LPT1",,,.f.)
							
						EndIf
						
						MSCBCHKSTATUS(.F.)
						 
						Do Case
							Case (SubStr(cComboPos,1,1)) == "0"		//Sem Seta.
							        
							        If Val(cQtEtiq) > 1
								   		
								   		For n := 1 To Val(cQtEtiq)
											
											MSCBBEGIN(1,6)
					                        MSCBBOX(04,04,87,40,5)
										   	MSCBSAY(19,07,AllTrim(cEndIni),"N","0","120,080") 
										   	MSCBSAYBAR(19,20,AllTrim(cEndIni),"MB07","C",15.00,.F.,.T.,.F.,,3,2)
										   	MSCBInfoEti("ENDERECO","ENDERECO")				      
											MSCBEND()
										
										Next n
			                        	
			                        	
			                        Else
									
											MSCBBEGIN(1,6)
					                        MSCBBOX(04,04,87,40,5)
										   	MSCBSAY(19,07,AllTrim(cEndIni),"N","0","120,080") 
										   	MSCBSAYBAR(19,20,AllTrim(cEndIni),"MB07","C",15.00,.F.,.T.,.F.,,3,2)
										   	MSCBInfoEti("ENDERECO","ENDERECO")				      
											MSCBEND()
							   		
							   		EndIf    
							   	
							Case (SubStr(cComboPos,1,1)) == "1"		// Seta para o lado direito.
							
									MSCBLOADGRF("tst4.grf")
							
									MSCBBEGIN(1,6)
			                        MSCBBOX(04,04,87,40,5)
								   	MSCBSAY(06,07,AllTrim(cEndIni),"N","0","120,080") 
								   	MSCBGRAFIC(50,07,"tst4",.T.) 
								   	MSCBSAYBAR(19,20,AllTrim(cEndIni),"MB07","C",15.00,.F.,.T.,.F.,,3,2)
								   	MSCBInfoEti("ENDERECO","ENDERECO")				      
									MSCBEND()
								 
							Case (SubStr(cComboPos,1,1)) == "2"		//Seta para o lado esquerdo.
							
								   MSCBLOADGRF("tst5.grf")
							
								   MSCBBEGIN(1,6)
			                       MSCBBOX(04,04,87,40,5)
			                       MSCBGRAFIC(06,07,"tst5",.T.) 
								   MSCBSAY(41,07,AllTrim(cEndIni),"N","0","120,080")
								   MSCBSAYBAR(19,20,AllTrim(cEndIni),"MB07","C",15.00,.F.,.T.,.F.,,3,2)
								   MSCBInfoEti("ENDERECO","ENDERECO")				      
								   MSCBEND()
			
						EndCase  
						   		
							
					EndIf                                              
					
						MSCBCLOSEPRINTER()
						
			Else//Se o endereço inicial e o endereço final for diferente. 
			
						DbSelectArea("CB5")
						DbSetOrder(1) 
			     
		    			If DbSeek(xFilial("CB5")+cImp)
						
									If CB5->CB5_TIPO == "3" 		//SPOOL
													
											MSCBPRINTER(AllTrim(CB5->CB5_MODELO),"LPT1",,,.f.,,,,,AllTrim(CB5->CB5_FILA))
													
									Else
											MSCBPRINTER(AllTrim(CB5->CB5_MODELO),"LPT1",,,.f.)
													
									EndIf  
									
									MSCBCHKSTATUS(.F.) 
				
									cPos := SubStr(cComboPos,1,1) 
		    
									cQuery := " SELECT BE_LOCALIZ " 
									cQuery += " FROM "+RETSQLNAME("SBE")+" SBE "
									cQuery += " WHERE BE_FILIAL = '"+cFilAnt+"' AND BE_LOCAL = '"+cLocal+"' " 
									cQuery += " AND BE_LOCALIZ >= '"+cEndIni+"' AND BE_LOCALIZ <= '"+cEndFin+"' " 
									If (SubStr(cCombol,1,1)) == "2" 
								   		cQuery += "	AND (SUBSTRING(BE_LOCALIZ,3,3)%2) = 0 " //--PAR  
								 	ElseIf (SubStr(cCombol,1,1)) == "1" 
										cQuery += "	AND (SUBSTRING(BE_LOCALIZ,3,3)%2) <> 0 " // --IMPAR 
									EndIf
									cQuery += " AND SBE.D_E_L_E_T_ = '' "
									//cQuery += " ORDER BY BE_LOCAL, BE_LOCALIZ "   
									cQuery += " ORDER BY SUBSTRING(BE_LOCALIZ,1,2),SUBSTRING(BE_LOCALIZ,3,3),SUBSTRING(BE_LOCALIZ,6,2),SUBSTRING(BE_LOCALIZ,8,2)"
									
									cQuery 	:= ChangeQuery(cQuery)
									dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"QryBE",.T.,.T.) 
									
									QryBE->(DBgoTOP()) 
									
									While !Eof("QryBE")  
										
										cRua := SubStr(QryBE->BE_LOCALIZ,1,2)
									   
										nNivel  := Val(SubStr(QryBE->BE_LOCALIZ,6,2))
										
										
		                                If cPredio <> SubStr(QryBE->BE_LOCALIZ,3,3) .And. nCont <> 0
		   
										 
									   			If cPos == "1"
												
													cPos := "2"
												
												ElseIf cPos == "2"
												
													cPos := "1"
												
												EndIf  
									   		 
									 	EndIf   
									 			
									 			cPredio := SubStr(QryBE->BE_LOCALIZ,3,3) 
									 			
									 	
									   		
									   	         nCont++ 
									   	         nImp++
									   			 If cPos == "1"// Direita
												   	If nNivel%2 > 0   	// SE IMPAR nX%2 > 0
														   	  
														MSCBLOADGRF("tst4.grf")
												
														MSCBBEGIN(1,6)
								                        MSCBBOX(04,04,87,40,5)
													   	MSCBSAY(06,07,AllTrim(QryBE->BE_LOCALIZ),"N","0","120,080") 
													   	MSCBGRAFIC(50,07,"tst4",.T.) 
													   	MSCBSAYBAR(19,20,AllTrim(QryBE->BE_LOCALIZ),"MB07","C",15.00,.F.,.T.,.F.,,3,2)
													   	MSCBInfoEti("ENDERECO","ENDERECO")				      
														MSCBEND()
												   	   
												    Else
														MSCBLOADGRF("tst4.grf")
												
														MSCBBEGIN(1,6)
								                        MSCBBOX(04,04,87,40,5)
													   	MSCBSAY(06,07,AllTrim(QryBE->BE_LOCALIZ),"N","0","120,080") 
													   	MSCBGRAFIC(50,07,"tst4",.T.) 
													   	MSCBSAYBAR(19,20,AllTrim(QryBE->BE_LOCALIZ),"MB07","C",15.00,.F.,.T.,.F.,,3,2)
													   	MSCBInfoEti("ENDERECO","ENDERECO")				      
														MSCBEND()
			 
												    EndIf
												    
												 ElseIf cPos == "2"//Esquerda
												 	If nNivel%2 > 0   	// SE IMPAR                         
														   MSCBLOADGRF("tst5.grf")
													
														   MSCBBEGIN(1,6)
									                       MSCBBOX(04,04,87,40,5)
									                       MSCBGRAFIC(06,07,"tst5",.T.) 
														   MSCBSAY(41,07,AllTrim(QryBE->BE_LOCALIZ),"N","0","120,080")
														   MSCBSAYBAR(19,20,AllTrim(QryBE->BE_LOCALIZ),"MB07","C",15.00,.F.,.T.,.F.,,3,2)
														   MSCBInfoEti("ENDERECO","ENDERECO")				      
														   MSCBEND()
		
													Else
														   MSCBLOADGRF("tst5.grf")
													
														   MSCBBEGIN(1,6)
									                       MSCBBOX(04,04,87,40,5)
									                       MSCBGRAFIC(06,07,"tst5",.T.) 
														   MSCBSAY(41,07,AllTrim(QryBE->BE_LOCALIZ),"N","0","120,080")
														   MSCBSAYBAR(19,20,AllTrim(QryBE->BE_LOCALIZ),"MB07","C",15.00,.F.,.T.,.F.,,3,2)
														   MSCBInfoEti("ENDERECO","ENDERECO")				      
														   MSCBEND()
		
													EndIf 
												 Else 
															MSCBBEGIN(1,6)
									                        MSCBBOX(04,04,87,40,5)
														   	MSCBSAY(19,07,AllTrim(QryBE->BE_LOCALIZ),"N","0","120,080") 
														   	MSCBSAYBAR(19,20,AllTrim(QryBE->BE_LOCALIZ),"MB07","C",15.00,.F.,.T.,.F.,,3,2)
														   	MSCBInfoEti("ENDERECO","ENDERECO")				      
															MSCBEND()
												 EndIf
		
		   							QryBE->(DbSkip()) 
		   							
		   								
									EndDo 
													
		    	
		    		                QryBE->(DbCloseArea())
		
			                 EndIf
		    EndIf 
	
	
	//Estrutura Simples.
	Else

		If cEndIni = cEndFin //Se o endereço inicial e o endereço final forem iguais.
	
				DbSelectArea("CB5")
				DbSetOrder(1)                                                                     
				
				If DbSeek(xFilial("CB5")+cImp)
					
					If CB5->CB5_TIPO == "3" 		//SPOOL
						
						MSCBPRINTER(AllTrim(CB5->CB5_MODELO),"LPT1",,,.f.,,,,,AllTrim(CB5->CB5_FILA))
						
					Else
						MSCBPRINTER(AllTrim(CB5->CB5_MODELO),"LPT1",,,.f.)
						
					EndIf
					
					MSCBCHKSTATUS(.F.)
					 
					Do Case
						Case (SubStr(cComboPos,1,1)) == "0"		//Sem Seta.
						        
						        If Val(cQtEtiq) > 1
							   		
							   		For n := 1 To Val(cQtEtiq)
										
										MSCBBEGIN(1,6)
				                        MSCBBOX(04,04,87,50,5)
									   	MSCBSAY(19,09,AllTrim(cEndIni),"N","0","120,080") 
									   	MSCBSAYBAR(19,30,AllTrim(cEndIni),"MB07","C",15.00,.F.,.T.,.F.,,3,2)
									   	MSCBInfoEti("ENDERECO","ENDERECO")				      
										MSCBEND()
									
									Next n
		                        	
		                        	
		                        Else
								
										MSCBBEGIN(1,6)
				                        MSCBBOX(04,04,87,50,5)
									   	MSCBSAY(19,09,AllTrim(cEndIni),"N","0","120,080") 
									   	MSCBSAYBAR(19,30,AllTrim(cEndIni),"MB07","C",15.00,.F.,.T.,.F.,,3,2)
									   	MSCBInfoEti("ENDERECO","ENDERECO")				      
										MSCBEND()
						   		
						   		EndIf    
						   	
						Case (SubStr(cComboPos,1,1)) == "1"		// Seta para o lado direito.
						
								MSCBLOADGRF("tst4.grf")
						
								MSCBBEGIN(1,6)
		                        MSCBBOX(04,04,87,50,5)
							   	MSCBSAY(06,09,AllTrim(cEndIni),"N","0","120,080") 
							   	MSCBGRAFIC(50,09,"tst4",.T.) 
							   	MSCBSAYBAR(19,30,AllTrim(cEndIni),"MB07","C",15.00,.F.,.T.,.F.,,3,2)
							   	MSCBInfoEti("ENDERECO","ENDERECO")				      
								MSCBEND()
							 
						Case (SubStr(cComboPos,1,1)) == "2"		//Seta para o lado esquerdo.
						
							   MSCBLOADGRF("tst5.grf")
						
							   MSCBBEGIN(1,6)
		                       MSCBBOX(04,04,87,50,5)
		                       MSCBGRAFIC(06,09,"tst5",.T.) 
							   MSCBSAY(41,09,AllTrim(cEndIni),"N","0","120,080")
							   MSCBSAYBAR(19,30,AllTrim(cEndIni),"MB07","C",15.00,.F.,.T.,.F.,,3,2)
							   MSCBInfoEti("ENDERECO","ENDERECO")				      
							   MSCBEND()
		
					EndCase  
					   		
						
				EndIf                                              
				
					MSCBCLOSEPRINTER()
					
		Else//Se o endereço inicial e o endereço final for diferente. 
		
					DbSelectArea("CB5")
					DbSetOrder(1) 
		     
	    			If DbSeek(xFilial("CB5")+cImp)
					
								If CB5->CB5_TIPO == "3" 		//SPOOL
												
										MSCBPRINTER(AllTrim(CB5->CB5_MODELO),"LPT1",,,.f.,,,,,AllTrim(CB5->CB5_FILA))
												
								Else
										MSCBPRINTER(AllTrim(CB5->CB5_MODELO),"LPT1",,,.f.)
												
								EndIf  
								
								MSCBCHKSTATUS(.F.) 
			
								cPos := SubStr(cComboPos,1,1) 
	    
								cQuery := " SELECT BE_LOCALIZ " 
								cQuery += " FROM "+RETSQLNAME("SBE")+" SBE "
								cQuery += " WHERE BE_FILIAL = '"+cFilAnt+"' AND BE_LOCAL = '"+cLocal+"' " 
								cQuery += " AND BE_LOCALIZ >= '"+cEndIni+"' AND BE_LOCALIZ <= '"+cEndFin+"' " 
								If (SubStr(cCombol,1,1)) == "2" 
							   		cQuery += "	AND (SUBSTRING(BE_LOCALIZ,3,3)%2) = 0 " //--PAR  
							 	ElseIf (SubStr(cCombol,1,1)) == "1" 
									cQuery += "	AND (SUBSTRING(BE_LOCALIZ,3,3)%2) <> 0 " // --IMPAR 
								EndIf
								cQuery += " AND SBE.D_E_L_E_T_ = '' "
								//cQuery += " ORDER BY BE_LOCAL, BE_LOCALIZ "   
								cQuery += " ORDER BY SUBSTRING(BE_LOCALIZ,1,2),SUBSTRING(BE_LOCALIZ,3,3),SUBSTRING(BE_LOCALIZ,6,2),SUBSTRING(BE_LOCALIZ,8,2)"
								
								cQuery 	:= ChangeQuery(cQuery)
								dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"QryBE",.T.,.T.) 
								
								QryBE->(DBgoTOP()) 
								
								While !Eof("QryBE")  
									
									cRua := SubStr(QryBE->BE_LOCALIZ,1,2)
								   
									nNivel  := Val(SubStr(QryBE->BE_LOCALIZ,6,2))
									
									
	                                If cPredio <> SubStr(QryBE->BE_LOCALIZ,3,3) .And. nCont <> 0
	   
									 
								   			If cPos == "1"
											
												cPos := "2"
											
											ElseIf cPos == "2"
											
												cPos := "1"
											
											EndIf  
								   		 
								 	EndIf   
								 			
								 			cPredio := SubStr(QryBE->BE_LOCALIZ,3,3) 
								 			
								 	
								   		
								   	         nCont++ 
								   	         nImp++
								   			 If cPos == "1"// Direita
											   	If nNivel%2 > 0   	// SE IMPAR nX%2 > 0
													   	  
													MSCBLOADGRF("tst4.grf")
											
													MSCBBEGIN(1,6)
							                        MSCBBOX(04,04,87,50,5)
												   	MSCBSAY(06,09,AllTrim(QryBE->BE_LOCALIZ),"N","0","120,080") 
												   	MSCBGRAFIC(50,09,"tst4",.T.) 
												   	MSCBSAYBAR(19,30,AllTrim(QryBE->BE_LOCALIZ),"MB07","C",15.00,.F.,.T.,.F.,,3,2)
												   	MSCBInfoEti("ENDERECO","ENDERECO")				      
													MSCBEND()
											   	   
											    Else
													MSCBLOADGRF("tst4.grf")
											
													MSCBBEGIN(1,6)
							                        MSCBBOX(04,04,87,50,5)
												   	MSCBSAY(06,09,AllTrim(QryBE->BE_LOCALIZ),"N","0","120,080") 
												   	MSCBGRAFIC(50,09,"tst4",.T.) 
												   	MSCBSAYBAR(19,30,AllTrim(QryBE->BE_LOCALIZ),"MB07","C",15.00,.F.,.T.,.F.,,3,2)
												   	MSCBInfoEti("ENDERECO","ENDERECO")				      
													MSCBEND()
		 
											    EndIf
											    
											 ElseIf cPos == "2"//Esquerda
											 	If nNivel%2 > 0   	// SE IMPAR                         
													   MSCBLOADGRF("tst5.grf")
												
													   MSCBBEGIN(1,6)
								                       MSCBBOX(04,04,87,50,5)
								                       MSCBGRAFIC(06,09,"tst5",.T.) 
													   MSCBSAY(41,09,AllTrim(QryBE->BE_LOCALIZ),"N","0","120,080")
													   MSCBSAYBAR(19,30,AllTrim(QryBE->BE_LOCALIZ),"MB07","C",15.00,.F.,.T.,.F.,,3,2)
													   MSCBInfoEti("ENDERECO","ENDERECO")				      
													   MSCBEND()
	
												Else
													   MSCBLOADGRF("tst5.grf")
												
													   MSCBBEGIN(1,6)
								                       MSCBBOX(04,04,87,50,5)
								                       MSCBGRAFIC(06,09,"tst5",.T.) 
													   MSCBSAY(41,09,AllTrim(QryBE->BE_LOCALIZ),"N","0","120,080")
													   MSCBSAYBAR(19,30,AllTrim(QryBE->BE_LOCALIZ),"MB07","C",15.00,.F.,.T.,.F.,,3,2)
													   MSCBInfoEti("ENDERECO","ENDERECO")				      
													   MSCBEND()
	
												EndIf 
											 Else 
														MSCBBEGIN(1,6)
								                        MSCBBOX(04,04,87,50,5)
													   	MSCBSAY(19,09,AllTrim(QryBE->BE_LOCALIZ),"N","0","120,080") 
													   	MSCBSAYBAR(19,30,AllTrim(QryBE->BE_LOCALIZ),"MB07","C",15.00,.F.,.T.,.F.,,3,2)
													   	MSCBInfoEti("ENDERECO","ENDERECO")				      
														MSCBEND()
											 EndIf
	
	   							QryBE->(DbSkip()) 
	   							
	   								
								EndDo 
												
	    	
	    		                QryBE->(DbCloseArea())
	
		                 EndIf
	    EndIf 
    EndIf	            
EndIf


Return()

