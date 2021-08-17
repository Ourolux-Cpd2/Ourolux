#Include "Protheus.ch"
#Include "RwMake.ch"
#Include "TopConn.ch"
#Include "TbiConn.ch"
#Include "TbiCode.ch"
#Include "ParmType.ch"

#Define STR_PULA    Chr(13) + Chr(10)
#Define COMP_DATE	"20191209"

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} xAprCnab
Rotina para confirmação de liberacao de cnab.
Utilizar o controle de alcadas controlado por RCB e RCC.

@type 		Function
@author 	Maurício Aureliano
@since 		16/05/2018
@version 	P12

@obs		I1705-895 - Segurança do sistema urgente
 
@return lRet
/*/    
//-------------------------------------------------------------------------------------
User Function xAprCnab()

	Local lRet 	:= .T.
	Local nTipo	:= 1

	lRet := Processa({ || ProcLibCN(nTipo) })
	
Return( lRet )
               
//-------------------------------------------------------------------------------------
/*/{Protheus.doc} ProcLibCN
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
Static Function ProcLibCN(nTipo)

	Local lRet 		:= .F.
	Local lVazio	:= .F.
	Local aArea 	:= GetArea()
	Local aCN	  	:= {}
	Local aBan  	:= {}
	Local cQuery	:= ""
	Local cQryUpd	:= ""
	Local cFornece	:= ""
	Local cNomFor	:= ""
	Local Ny		:= 0
	Local nTotCN	:= 0
	Local nCount	:= 0
	
	Private aCN	  	:= {}
	Private aBan  	:= {}
		
	ProcRegua(0)
	
	// Pegando os dados
	cQuery := " SELECT" 	 + STR_PULA
	cQuery += " E2_FORNECE"  + STR_PULA
	cQuery += " ,E2_LOJA" 	 + STR_PULA
	cQuery += " ,E2_NUM" 	 + STR_PULA
	cQuery += " ,E2_FILIAL"	 + STR_PULA
	cQuery += " ,E2_VALOR" 	 + STR_PULA
	cQuery += " ,E2_NATUREZ" + STR_PULA
	cQuery += " ,E2_PREFIXO" + STR_PULA
	cQuery += " ,E2_PARCELA" + STR_PULA
	cQuery += " ,E2_TIPO"    + STR_PULA
	
	// Dados Bancários
	cQuery += " ,E2_XPORTA"  + STR_PULA
	cQuery += " ,E2_XBLQAGE" + STR_PULA
	cQuery += " ,E2_XBLQDAG" + STR_PULA
	cQuery += " ,E2_XBLQCON" + STR_PULA
	cQuery += " ,E2_XBLQDCO" + STR_PULA
	cQuery += " ,E2_XUSRID"  + STR_PULA
	cQuery += " FROM " + RetSqlName("SE2") + " SE2" + STR_PULA
	cQuery += " WHERE" 								+ STR_PULA
	cQuery += " E2_XBLQPOR = 'S'" 					+ STR_PULA // Somente títulos bloqueados!
	cQuery += " AND SE2.D_E_L_E_T_ = ''" 			+ STR_PULA
	cQuery += " ORDER BY E2_FILIAL,E2_NUM"			+ STR_PULA
	
	If !Empty(Select("QRYTIT"))
		dbSelectArea("QRYTIT")
		dbCloseArea()
	Endif

	// MemoWrit("C:\SIGA\xaprcnab.sql",cQuery)
	TCQuery cQuery New Alias "QRYTIT"
		
	While !(QRYTIT->(EoF()))
        
		nCount++
        
		IncProc("Titulos Encontrados...: " + str(nCount))

		cFornece	:= Trim(QRYTIT->E2_FORNECE) + Trim(QRYTIT->E2_LOJA)
		cPortador	:= Trim(QRYTIT->E2_XPORTA) + Trim(QRYTIT->E2_XBLQAGE) + Trim(QRYTIT->E2_XBLQCON)
		cDescBan	:= Posicione("SA6",1,xFilial("SA6")+cPortador,"A6_NOME")
		cNomFor		:= Posicione("SA2",1,xFilial("SA2")+cFornece ,"A2_NOME")
    	         
		nTotCN	+=  QRYTIT->E2_VALOR
		AADD( aCN,  { QRYTIT->E2_FILIAL,QRYTIT->E2_PREFIXO,QRYTIT->E2_NUM,QRYTIT->E2_PARCELA,QRYTIT->E2_VALOR,QRYTIT->E2_FORNECE,QRYTIT->E2_LOJA,QRYTIT->E2_TIPO,cNomFor} )
		AADD( aBan, { QRYTIT->E2_NUM,QRYTIT->E2_XPORTA,QRYTIT->E2_XBLQAGE,QRYTIT->E2_XBLQCON,QRYTIT->E2_XUSRID} )

		QRYTIT->(DbSkip())

	EndDo
	
	If Empty(aCN)
		cMsgSvis := "Não existem Títulos a serem liberados"
		Aviso("XAPRCNAB",cMsgSvis,{"Ok"},3,"Atenção")
		//lRet := VisCN( nTipo, aCN, nTotCN, aBan)
		lRet 	:= .F.
		lVazio	:= .T.
	Else
		lRet := VisCN( nTipo, aCN, nTotCN, aBan)
	EndIf
	
	If lRet
		
		For Ny := 1 To Len( aCN )
				cQryUpd := " UPDATE " + RetSqlName("SE2")
				cQryUpd += " SET E2_XBLQPOR = '',E2_XPORTA = '',E2_XBLQAGE = '',E2_XBLQCON = ''"
				cQryUpd += " WHERE"
				cQryUpd += " E2_PREFIXO =     '" + aCN[Ny][02]  + "'"
				cQryUpd += " AND E2_NUM =     '" + aCN[Ny][03]  + "'"
				cQryUpd += " AND E2_PARCELA = '" + aCN[Ny][04]  + "'"
				cQryUpd += " AND E2_TIPO =    '" + aCN[Ny][08]  + "'"
				cQryUpd += " AND E2_FORNECE = '" + aCN[Ny][06]  + "'"
				cQryUpd += " AND E2_LOJA =    '" + aCN[Ny][07]	+ "'"
				MemoWrit("C:\SIGA\F240TDOK01.sql",cQryUpd)
				TcSqlExec(cQryUpd)

				If TcSqlExec(cQryUpd) < 0
					Hs_MsgInf(TcSqlError(),"Erro Query","F240TDOK")
					Exit
				EndIf
			alert("Titulo " + AllTrim( aCN[Ny][03] ) + " foi liberado!")
		Next
		lRet := .F.
	Else
		If !lVazio
			Alert("Título não foi liberado")
		Endif
	EndIf
	
	RestArea( aArea )
	
Return( lRet )
                           
//-------------------------------------------------------------------------------------
/*/{Protheus.doc} VisCN
Ponto de entrada na confirmação de liberacao de titulo para envio CNAB.
Utilizar o controle de alcadas controlado por RCB e RCC.

@type 		Function
@author 	Roberto Souza
@since 		09/02/2017
@version 	P11 
@params     nTipo 	: 	1 = Liberar 
						3 = Rejeitar 
			aCN   	: Array com os títulos					
			nTotCN : Total dos Títulos
						
@return lRet
/*/    
//-------------------------------------------------------------------------------------
Static Function VisCN( nTipo, aCN, nTotCN ,aBan )
	Local lRet 	   		:= .F.
	Local oDlgList
	Local oList1
	Local oList2
	Local aItems   		:= aClone( aCN )
	Local oArea		   	:= FWLayer():New()
	Local aCoord		:= {0,0,520,1050}//FWGetDialogSize(oMainWnd)
	Local aTamObj		:= Array(4)
	Local nOpcA		  	:= 0
	Local cMotRej		:= Space(100)
	Local bLibera		:= {|| lRet := .T.,oMainDlg:End() }
	Local bRejeita		:= {|| IIf( ProcRej( aCN, cMotRej ),(lRet := .T.,oMainDlg:End()),Nil )}
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
	Local nNivel        := RetUtab( "U003", "Alçadas de Liberação de Crédito", @cErro, @cWarning, 0)
	Local cAcao         := IIf( nTipo == 1, "Liberar", "Rejeitar" )
	Local lAction       := .T.
    
	cErro	:= ""
	
	If !Empty( cErro )
		Aviso("XAPRCNAB",cErro+cWarning,{"Ok"},3,"Atenção")
	Else
		If Empty(aCN)
			AADD(aCN,{"------","--","------","--",0,"---","-----------"})
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
	
		oMainDlg := tDialog():New(aCoord[1],aCoord[2],aCoord[3],aCoord[4],"Detalhamento dos Títulos - ",,,,,CLR_BLACK,CLR_WHITE,,,.T.)
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
		oArea:AddWindow("L01C01","LIST1","Financeiro",080,.F.,.F.,/*bAction*/,"L01",/*bGotFocus*/)
		oArea:AddWindow("L01C01","LIST1A","Relação de títulos",020,.F.,.F.,/*bAction*/,"L01",/*bGotFocus*/)
		oList1	:= oArea:GetWinPanel("L01C01","LIST1","L01")
		oList1A	:= oArea:GetWinPanel("L01C01","LIST1A","L01")
	
		@ 000,000 LISTBOX oLbx1 FIELDS HEADER  "Filial","Prefixo","Título","Parcela","Valor R$","Cod.Forn","Loja","Nome Fornecedor";
			COLSIZES 20,25,25,25,50,30,20,100 ;
			SIZE 230,095 OF oList1 PIXEL
	
		oLbx1:SetArray( aCN )
		oLbx1:bLine := {|| { aCN[oLbx1:nAt][01] ,;
			aCN[oLbx1:nAt][02] ,;
			aCN[oLbx1:nAt][03] ,;
			aCN[oLbx1:nAt][04] ,;
			Transform(aCN[oLbx1:nAt][05],"@E 999,999,999.99"),;
			aCN[oLbx1:nAt][06] ,;
			aCN[oLbx1:nAt][07] ,;
			aCN[oLbx1:nAt][08] }}
		oLbx1:Align    := CONTROL_ALIGN_ALLCLIENT
	
		@ 005,005 SAY "Total : R$ " + Transform(nTotCN,"@E 999,999,999.99") FONT oFont COLOR CLR_BLUE Pixel Of oList1A
			
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Paineis - Dados Banco   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		
		oArea:AddWindow("L01C02","LIST2","Banco",080,.F.,.F.,/*bAction*/,"L01",/*bGotFocus*/)
		oArea:AddWindow("L01C02","LIST2A","Dados Bancarios",020,.F.,.F.,/*bAction*/,"L01",/*bGotFocus*/)
		oList2	:= oArea:GetWinPanel("L01C02","LIST2","L01")
		oList2A	:= oArea:GetWinPanel("L01C02","LIST2A","L01")
		
		@ 000,000 LISTBOX oLbx2 FIELDS HEADER  "Titulo","Banco","Agencia","Conta","Solicitante";
			COLSIZES 20,25,25,100 ;
			SIZE 230,095 OF oList2 PIXEL
	
		oLbx2:SetArray( aBan )
		oLbx2:bLine := {|| { aBan[oLbx2:nAt][01] ,;
							 aBan[oLbx2:nAt][02] ,;
							 aBan[oLbx2:nAt][03] ,;
							 aBan[oLbx2:nAt][04] ,;
							 UsrFullName(aBan[oLbx2:nAt][05]) }}

		oLbx2:Align    := CONTROL_ALIGN_ALLCLIENT
	
		//@ 005,005 SAY "Total : R$ " + Transform(nBonif,"@E 999,999,999.99") FONT oFont COLOR CLR_BLUE Pixel Of oList2A
		//@ 005,005 SAY "Solicitante: " + "Usuário" FONT oFont COLOR CLR_BLUE Pixel Of oList2A
		//UsrRetName(RetCodUsr())
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Painel - Info Alcada        ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oArea:AddWindow("L02C01","INFO","Nivel de Aprovação",100,.F.,.F.,/*bAction*/,"L02",/*bGotFocus*/)
		oInfo	:= oArea:GetWinPanel("L02C01","INFO","L02")
		@ 005,005 SAY "Nivel de Aprovação :  " + nNivel FONT oFont COLOR CLR_BLUE Pixel Of oInfo
		
		//If nTipo <> 1 .And. lAction
		//	@ 017,005 SAY "Motivo da rejeição :" FONT oFont COLOR CLR_BLUE Pixel Of oInfo
		//	@ 015,075 MSGET cMotRej SIZE 220,05 Pixel Of oInfo
		//EndIf
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Painel 03-Botoes            ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oArea:AddWindow("L01C03","BUTTON","Ações",100,.F.,.F.,/*bAction*/,"L01",/*bGotFocus*/)
		oAreaBut := oArea:GetWinPanel("L01C03","BUTTON","L01")
	
		If nNivel >= "5" .And. lAction
			If nTipo == 1 //Liberar
				oButt1 := tButton():New(000,000, cAcao	,oAreaBut,bLibera	,oAreaBut:nClientWidth/2,15,,/*oFont*/,,.T.,,,,/*bWhen*/)
			EndIf
		EndIf

		oButt2 := tButton():New(016,000,"&Cancelar"	,oAreaBut,bCancel	,oAreaBut:nClientWidth/2,15,,/*oFont*/,,.T.,,,,/*bWhen*/)
    
		oMainDlg:Activate(,,,.T.,/*valid*/,,/*On Init*/)
	EndIf
	
Return( lRet )
             
 
//-------------------------------------------------------------------------------------
/*/{Protheus.doc} ProcRej
Atualiza informações de rejeição

@type 		function
@author 	Roberto Souza
@since 		09/02/2017
@version 	P11 
@params     cFilPed : Filial do Pedido
			cNum   	: Numero do Pedido
						
@return lRet
/*/    
//-------------------------------------------------------------------------------------                  
Static Function ProcRej( aCN, cMotRej )
	Local lRet := .F.
	MsgRun("Atualizando informações de rejeição...","Rejeição",{|| lRet := GoProc( aCN, cMotRej ) })
Return( lRet )

Static Function GoProc( aCN, cMotRej )

	Local lRet := .F.
	Local Nx   := 0
	Local nPosFor := 1
	Local nPosLoj := 2
	Local nPosTit := 3
	Local aArea   := GetArea()
	
	If Empty( cMotRej ) .Or. Len( cMotRej ) < 10
		Aviso("Rejeição","Informe um motivo da rejeição de liberação válido.",{"Ok"},2)
	Else
		cNumTits := ""
		For Nx := 1 To Len( aCN )
			If aCN[Nx][nPosTit] <> "------"
				cNumTits += aCN[Nx][nPosTit] + "/"
			EndIf
		Next
	EndIf

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
		cErro 	+= "Usuario Não possui nivel suficiente."+CRLF
		cWarning+= "Solicite ao gestor da àrea a revisao do cadastro."+CRLF
		uRet 	:= uDefault
	EndIf

Return( uRet )
