#INCLUDE "PROTHEUS.CH"

#DEFINE COMP_DATE	"20191209"

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} M450CMAN
Ponto de entrada na confirmação de liberacao de credito por cliente.
Utilizar o controle de alcadas controlado por RCB e RCC.

@type 		function
@author 	Roberto Souza
@since 		09/02/2017
@version 	P11 
 
@return lRet
/*/    
//-------------------------------------------------------------------------------------
User Function M450CMAN()   
	Local nTipo     := PARAMIXB[01]
	Local lRet 		:= .T.
	Local lNewLib 	:= GetMv("FS_LIBCLI",,"N") == "S"

	If lNewLib	
		If nTipo <>  0
	   		lRet := ProcLibCL( nTipo )   
	    EndIf
	EndIf
	
Return( lRet )
               


//-------------------------------------------------------------------------------------
/*/{Protheus.doc} ProcLibCL
Função de entrada da validacao de credito

@type 		function
@author 	Roberto Souza
@since 		09/02/2017
@version 	P11 
@params     nTipo : 1 = Liberar 
					3 = Rejeitar
@return lRet
/*/    
//-------------------------------------------------------------------------------------
Static Function ProcLibCL( nTipo )
	Local lRet 		:= .F.
	Local aArea 	:= GetArea()
	Local nTotPed 	:= 0
	Local nBonif  	:= 0     
	Local aPV	  	:= {}
	Local aBon	  	:= {}		

	Default nTipo     := PARAMIXB[01]                

	/*
	DbSelectArea("TMP")
	DbGoTop()   
	
    While TMP->(!Eof())
        cCond 		:= Posicione("SC5",1,TMP->C5_FILIAL+TMP->C5_NUM,"C5_CONDPAG")
        cDescCond   := Posicione("SE4",1,xFilial("SE4")+cCond,"E4_DESCRI")
    	         
    	If IsBonif( TMP->C5_FILIAL,TMP->C5_NUM )	                       
	        nBonif	+=  TMP->C5_VALOR		
			AADD( aBon, { TMP->C5_CLIENTE,TMP->C5_LOJACLI,TMP->C5_NUM,TMP->C5_FILIAL,TMP->C5_VALOR,cCond,cDescCond} )
		Else
	        nTotPed	+=  TMP->C5_VALOR              
			AADD( aPv, { TMP->C5_CLIENTE,TMP->C5_LOJACLI,TMP->C5_NUM,TMP->C5_FILIAL,TMP->C5_VALOR,cCond,cDescCond} )
		EndIf
		                      
		TMP->(DbSkip())
	EndDo 
	*/
	
	DbSelectArea("PED")
	DbGoTop()   
	
    While PED->(!Eof())
        cCond 		:= Posicione("SC5",1,PED->C5_FILIAL+PED->C5_NUM,"C5_CONDPAG")
        cDescCond   := Posicione("SE4",1,xFilial("SE4")+cCond,"E4_DESCRI")
    	         
    	If IsBonif( PED->C5_FILIAL,PED->C5_NUM )	                       
	        nBonif	+=  PED->C5_VALOR		
			AADD( aBon, { PED->C5_CLIENTE,PED->C5_LOJACLI,PED->C5_NUM,PED->C5_FILIAL,PED->C5_VALOR,cCond,cDescCond} )
		Else
	        nTotPed	+=  PED->C5_VALOR              
			AADD( aPv, { PED->C5_CLIENTE,PED->C5_LOJACLI,PED->C5_NUM,PED->C5_FILIAL,PED->C5_VALOR,cCond,cDescCond} )
		EndIf
		                      
		PED->(DbSkip())
	EndDo
	
	If Empty(aPv)        
		cMsgSvis := "Nao existem Pedidos de Venda a serem liberados"
		If Empty(aBon)
			cMsgSvis += "."+CRLF		
		Else
			cMsgSvis += ", apenas Pedidos de Bonificacao."+CRLF
		EndIf
		cMsgSvis += "Pedidos de Bonificacao so podem ser liberados junto com Pedidos de Vendas."
		
		Aviso("M450CMAN",cMsgSvis,{"Ok"},3,"Atenção")				

		lRet := VisPV( nTipo, aPv, nTotPed, aBon, nBonif )	
	Else
		lRet := VisPV( nTipo, aPv, nTotPed, aBon, nBonif )	
	EndIf
	
	RestArea( aArea )
Return( lRet )
    
    
                            
//-------------------------------------------------------------------------------------
/*/{Protheus.doc} VisPV
Ponto de entrada na confirmação de liberacao de credito por cliente.
Utilizar o controle de alcadas controlado por RCB e RCC.

@type 		function
@author 	Roberto Souza
@since 		09/02/2017
@version 	P11 
@params     nTipo 	: 	1 = Liberar 
						3 = Rejeitar 
			aPv   	: Array com os pedidos de venda					
			nTotPed : Total dos pedidos de venda
			aBon   	: Array com os pedidos de bonificação
			nBonif 	: Total dos pedidos de bonificação
						
@return lRet
/*/    
//-------------------------------------------------------------------------------------
Static Function VisPV( nTipo, aPv, nTotPed, aBon, nBonif )	
	Local lRet 	   		:= .F.
	Local oDlgList
	Local oList1
	Local oList2 
	Local aItems   		:= aClone( aPv )
	Local oArea		   	:= FWLayer():New()
	Local aCoord		:= {0,0,520,1050}//FWGetDialogSize(oMainWnd)
	Local aTamObj		:= Array(4)
	Local nOpcA		  	:= 0
	Local cMotRej		:= Space(100)	
	Local bLibera		:= {|| lRet := .T.,oMainDlg:End() }
	Local bRejeita		:= {|| IIf( ProcRej( aPv, aBon, cMotRej ),(lRet := .T.,oMainDlg:End()),Nil )}	
	Local bCancel		:= {|| lRet := .F.,oMainDlg:End() }
	Local oFont		  	:= TFont():New("Arial",08,12,,.T.,,,,.T.)
	
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
	Local cErro         := ""                         
	Local cWarning      := ""                         	
	Local nLimit        := RetUtab( "U002", "Alcadas de Liberacao de Credito", @cErro , @cWarning, 0) 
	Local cAcao         := IIf( nTipo == 1, "Liberar", "Rejeitar" )  
	Local lAction       := .T.
    
    If !Empty( cErro )
		Aviso("M450CMAN",cErro+cWarning,{"Ok"},3,"Atencao")	
	Else
		If Empty(aBon)
	    	AADD(aBon,{"------","--","------","--",0,"---","-----------"})
		EndIf

		If Empty(aPv)
	    	AADD(aPv,{"------","--","------","--",0,"---","-----------"})
	    	lAction := .F.
		EndIf
	
	
		//resoluçao 1280 x 768
		aSize:= {0,0,608.5,270,1217,563,0}
	
		aInfo := {aSize[1],aSize[2],aSize[3],aSize[4],3,3}
	
		AADD(aObjects,{100,30,.T.,.F.})
		AADD(aObjects,{100,100,.T.,.T.})
		aPosObj := MsObjSize(aInfo, aObjects)
	
		aScreen   := GetScreenRes()
		aScreen[1]:= aScreen[1]-20
		aScreen[2]:= aScreen[2]-20
	
		aCoord[3] *= 0.95
		aCoord[4] *= 0.9
	
		oMainDlg := tDialog():New(aCoord[1],aCoord[2],aCoord[3],aCoord[4],"Detalhamento dos pedidos - "+COMP_DATE,,,,,CLR_BLACK,CLR_WHITE,,,.T.)
		oArea:Init(oMainDlg,.F.)
		//Mapeamento da area
		oArea:AddLine("L01",075,.T.)
		oArea:AddLine("L02",025,.T.)
	
		//ÚÄÄÄÄÄÄÄÄÄ¿
		//³Colunas  ³
		//ÀÄÄÄÄÄÄÄÄÄÙ
		oArea:AddCollumn("L01C01",45,.F.,"L01") //dados
		oArea:AddCollumn("L01C02",45,.F.,"L01") //botoes                     
		oArea:AddCollumn("L01C03",10,.F.,"L01") //botoes
		oArea:AddCollumn("L02C01",90,.F.,"L02") //dados
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Paineis - Vendas  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oArea:AddWindow("L01C01","LIST1","Vendas",080,.F.,.F.,/*bAction*/,"L01",/*bGotFocus*/)
		oArea:AddWindow("L01C01","LIST1A","Resumo de Vendas",020,.F.,.F.,/*bAction*/,"L01",/*bGotFocus*/)
		oList1	:= oArea:GetWinPanel("L01C01","LIST1","L01")
		oList1A	:= oArea:GetWinPanel("L01C01","LIST1A","L01")
	
		@ 000,000 LISTBOX oLbx1 FIELDS HEADER  "Cliente","Loja","Pedido","Filial","Valor", "Cond","Descricao";//"Filial","Pedido", "Cliente","Loja", "Valor";
			COLSIZES 25,20,25,20,60,20,60 ;
		   	SIZE 230,095 OF oList1 PIXEL
	
		oLbx1:SetArray( aPv )
		oLbx1:bLine := {|| { aPv[oLbx1:nAt][01] ,;
			  				 aPv[oLbx1:nAt][02] ,;
							 aPv[oLbx1:nAt][03] ,;
							 aPv[oLbx1:nAt][04] ,;
							 Transform(aPv[oLbx1:nAt][05],"@E 999,999,999.99"),;
							 aPv[oLbx1:nAt][06] ,;
							 aPv[oLbx1:nAt][07]}}
		oLbx1:Align    := CONTROL_ALIGN_ALLCLIENT
	
		@ 005,005 SAY "Total : R$ " + Transform(nTotPed,"@E 999,999,999.99") FONT oFont COLOR CLR_BLUE Pixel Of oList1A
	
	
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Paineis - Bonificacoes  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oArea:AddWindow("L01C02","LIST2","Bonificacoes",080,.F.,.F.,/*bAction*/,"L01",/*bGotFocus*/)
		oArea:AddWindow("L01C02","LIST2A","Resumo de Bonificacoes",020,.F.,.F.,/*bAction*/,"L01",/*bGotFocus*/)
		oList2	:= oArea:GetWinPanel("L01C02","LIST2","L01")
		oList2A	:= oArea:GetWinPanel("L01C02","LIST2A","L01")
	
		@ 000,000 LISTBOX oLbx2 FIELDS HEADER  "Cliente","Loja","Pedido","Filial","Valor", "Cond","Descricao";//"Filial","Pedido", "Cliente","Loja", "Valor";
			COLSIZES 25,20,25,20,60,20,60 ;
		   	SIZE 230,095 OF oList2 PIXEL
	
		oLbx2:SetArray( aBon )
		oLbx2:bLine := {|| { aBon[oLbx2:nAt][01] ,;
			  				 aBon[oLbx2:nAt][02] ,;
							 aBon[oLbx2:nAt][03] ,;
							 aBon[oLbx2:nAt][04] ,;
							 Transform(aBon[oLbx2:nAt][05],"@E 999,999,999.99"),;
							 aBon[oLbx2:nAt][06] ,;
							 aBon[oLbx2:nAt][07]}}
							 
		oLbx2:Align    := CONTROL_ALIGN_ALLCLIENT
	
		@ 005,005 SAY "Total : R$ " + Transform(nBonif,"@E 999,999,999.99") FONT oFont COLOR CLR_BLUE Pixel Of oList2A
	
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Painel - Info Alcada        ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oArea:AddWindow("L02C01","INFO","Informacoes/Alcadas",100,.F.,.F.,/*bAction*/,"L02",/*bGotFocus*/)
		oInfo	:= oArea:GetWinPanel("L02C01","INFO","L02")
		@ 005,005 SAY "Limite de alçada : R$ " + Transform(nLimit,"@E 999,999,999.99") FONT oFont COLOR CLR_BLUE Pixel Of oInfo

		If nTipo <> 1 .And. lAction
			@ 017,005 SAY "Motivo da rejeicao :" FONT oFont COLOR CLR_BLUE Pixel Of oInfo
			@ 015,075 MSGET cMotRej SIZE 220,05 Pixel Of oInfo

    	EndIf
	
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Painel 03-Botoes            ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oArea:AddWindow("L01C03","BUTTON","Acoes",100,.F.,.F.,/*bAction*/,"L01",/*bGotFocus*/)
		oAreaBut := oArea:GetWinPanel("L01C03","BUTTON","L01")
	
		If nLimit >= nTotPed .And. lAction 
		    If nTipo == 1 //Liberar 
				oButt1 := tButton():New(000,000, cAcao	   		,oAreaBut,bLibera	,oAreaBut:nClientWidth/2,15,,/*oFont*/,,.T.,,,,/*bWhen*/)
    		Else
				oButt1 := tButton():New(000,000, cAcao	   		,oAreaBut,bRejeita	,oAreaBut:nClientWidth/2,15,,/*oFont*/,,.T.,,,,/*bWhen*/)    		
    		EndIf
			oButt2 := tButton():New(016,000,"&Cancelar"		,oAreaBut,bCancel	,oAreaBut:nClientWidth/2,15,,/*oFont*/,,.T.,,,,/*bWhen*/)
	    Else
			oButt1 := tButton():New(000,000,"&Cancelar"		,oAreaBut,bCancel	,oAreaBut:nClientWidth/2,15,,/*oFont*/,,.T.,,,,/*bWhen*/)		    
	    EndIf       
	    
		oMainDlg:Activate(,,,.T.,/*valid*/,,/*On Init*/)
	EndIf	
	
Return( lRet )	
             


//-------------------------------------------------------------------------------------
/*/{Protheus.doc} IsBonif
Verifica se um pedido e de bonificacao

@type 		function
@author 	Roberto Souza
@since 		09/02/2017
@version 	P11 
@params     cFilPed : Filial do Pedido
			cNum   	: Numero do Pedido
						
@return lRet
/*/    
//-------------------------------------------------------------------------------------
Static Function IsBonif( cFilPed, cNum )
	Local lRet 	:= .F.
	Local aArea	:= GetArea()             
	
	DbSelectArea("SC6")
	DbSetOrder(1)

	If DbSeek( cFilPed + cNum )
		While SC6->(!Eof()) .And. (SC6->C6_FILIAL + SC6->C6_NUM == cFilPed + cNum )
			If (Substr(SC6->C6_CF, 2, 3 ) $ '910')
				lRet := .T.
			EndIf		   
			SC6->(DbSkip())
		EndDo
	EndIf                    
                
	RestArea( aArea )
Return( lRet )  
             
            
 
//-------------------------------------------------------------------------------------
/*/{Protheus.doc} IsBonif
Verifica se um pedido e de bonificacao

@type 		function
@author 	Roberto Souza
@since 		09/02/2017
@version 	P11 
@params     cFilPed : Filial do Pedido
			cNum   	: Numero do Pedido
						
@return lRet
/*/    
//-------------------------------------------------------------------------------------                  
Static Function ProcRej( aPv, aBon, cMotRej )
    Local lRet := .F.
	MsgRun("Atualizando informacoes de rejeicao...","Rejeicao",{|| lRet := GoProc( aPv, aBon, cMotRej ) })
Return( lRet )     

Static Function GoProc( aPv, aBon, cMotRej )
	Local lRet := .F.              
	Local Nx   := 0
	Local nPosCli := 1
	Local nPosLoj := 2
	Local nPosPed := 3
	Local nPosFil := 4
	Local aArea   := GetArea()	
	
	If Empty( cMotRej ) .Or. Len( cMotRej ) < 10
		Aviso("Rejeicao","Informe um motivo da rejeicao de credito valido.",{"Ok"},2)
	Else                  
		cNumPeds := ""
     	For Nx := 1 To Len( aPv )   
     		If aPv[Nx][nPosPed] <> "------"        	
				cNumPeds += aPv[Nx][nPosPed] + "/"
				DbSelectArea("SC5")
				DbSetOrder(1)
			
				If DbSeek(aPv[Nx][nPosFil] + aPv[Nx][nPosPed] )
					RecLock("SC5",.F.)
					SC5->C5_XUSRLIB		:= cUsername
					SC5->C5_XDTLIB    	:= dDATAbASE
					SC5->C5_XMOTLIB   	:= cMotRej
					SC5->C5_XTIPOL    	:= "R"
					MsUnlock()
				EndIf
			EndIf
		Next		

     	For Nx := 1 To Len( aBon )
     		If aBon[Nx][nPosPed] <> "------"   
				cNumPeds += aBon[Nx][nPosPed] + "/"
				DbSelectArea("SC5")
				DbSetOrder(1)
			
				If DbSeek(aBon[Nx][nPosFil] + aBon[Nx][nPosPed] )
					RecLock("SC5",.F.)
					SC5->C5_XUSRLIB		:= cUsername
					SC5->C5_XDTLIB    	:= dDATAbASE
					SC5->C5_XMOTLIB   	:= cMotRej
					SC5->C5_XTIPOL    	:= "R"
					MsUnlock()
				// Claudino - 04/04/17 - I1704-145
				Else
					DbSeek(xFilial("SC5") + Substr(cNumPeds,1,6))
				EndIf
			EndIf	
		Next		

		cNumPeds := Substr(cNumPeds,1,Len(cNumPeds)-1)
		
		oProcess:= TWFProcess():New("Recusado","CreditoRecusado")
		oProcess:NewTask("Inicio","\WORKFLOW\rejeitado.htm")
		oProcess:cSubject := "Credito Recusado!" + Alltrim(SM0->M0_NOME) + '/' +Alltrim(SM0->M0_FILIAL) 
		oHtml := oProcess:oHTML
		
		oHTML:ValByName('DATA',dDataBase)
		oHTML:ValByName('PEDIDO',cNumPeds)
		oHTML:ValByName('CLIENTE',SC5->C5_CLIENTE +'/'+ SC5->C5_LOJACLI + ' ' + SA1->A1_NOME)
		oHTML:ValByName('MOTIVO', cMotRej)
	                
	    cCodVend := RTrim(GetAdvFVal("SA3","A3_COD",xFilial("SA3")+SC5->C5_VEND1,1,""))
		cNomVend := RTrim(GetAdvFVal("SA3","A3_NOME",xFilial("SA3")+SC5->C5_VEND1,1,""))
		oHTML:ValByName('VEND',cCodVend +" / "+ cNomVend) 
		
		cCodSup := RTrim(GetAdvFVal("SA3","A3_SUPER",xFilial("SA3")+SC5->C5_VEND1,1,""))
		If !Empty(cCodSup)
			cNomSup := RTrim(GetAdvFVal("SA3","A3_NOME",xFilial("SA3")+cCodSup,1,""))
			oHTML:ValByName('SUPERV',cCodSup +" / "+ cNomSup)
		EndIf
		
		cCodGer := RTrim(GetAdvFVal("SA3","A3_GEREN",xFilial("SA3")+SC5->C5_VEND1,1,""))
		If !Empty(cCodGer)
			cNomGer := RTrim(GetAdvFVal("SA3","A3_NOME",xFilial("SA3")+cCodGer,1,""))
			oHTML:ValByName('GEREN',cCodGer +" / "+ cNomGer)
		EndIf
			    
		cLista := U_getEmls(SC5->C5_VEND1)
		cLista += IIf(Empty(cLista),U_GrpEmail('Rejeitado'),';'+U_GrpEmail('Rejeitado'))
	
		If !Empty(cLista) 
			conout("Envio de email para - " + cLista)
			oProcess:cBCc := cLista 
			oProcess:Start()
			oProcess:Finish() 
		End
		lRet := .T.
	EndIf	                  
	RestArea( aArea )
Return( lRet )


//-------------------------------------------------------------------------------------
/*/{Protheus.doc} RetUtab
Verifica o uso das tabelas de alcadas customizadas

@type 		function
@author 	Roberto Souza
@since 		09/02/2017
@version 	P11 
@params     cTab	: Tabela
			cNomTab	: Nome da tabela
			cErro   : Erro 
			cWarning: Aviso
			uDefault: Retorno Default 
						
@return uRet
/*/    
//-------------------------------------------------------------------------------------
Static Function RetUtab( cTab, cNomTab, cErro, cWarning, uDefault )
	Local uRet 
	Local nLinTab := 0 
	
	Default cErro 		:= ""
	Default cWarning 	:= "" 
	Default uDefault    := ""

	nLinTab := U_XfPosTab(cTab, __cUserId, "==", 4)
	
	If nLinTab > 0
		uInfo 	:= fTabela( cTab,nLinTab, 6 )
		uRet 	:= uInfo //10 // Pega do Usuario
	Else
		cErro 	+= "Usuario Nao possui alcada."+CRLF
		cWarning+= "Solicite ao gestor da àrea o cadastro na tabela "+cNomTab+" ("+cTab+") ."+CRLF			
		uRet 	:= uDefault
	EndIf

Return( uRet )     
