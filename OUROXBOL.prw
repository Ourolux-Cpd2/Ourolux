#INCLUDE "TBICONN.CH"
#INCLUDE "FONT.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"

#INCLUDE "Colors.ch"
#INCLUDE "FWPrintSetup.ch"
#INCLUDE "ParmType.ch"
#INCLUDE "RPTDEF.CH"

#DEFINE COMP_DATE       "20191209"

#DEFINE IMP_SPOOL 		2
#DEFINE IMP_EMAIL 		3
#DEFINE IMP_PDF   		6
//Referencia de Bancos - Nosso Numero
#DEFINE BCO_BB			1	//Banco do Brasil
#DEFINE BCO_BRAD		2	//Bradesco
#DEFINE BCO_ITAU		3	//Itau
#DEFINE BCO_SAFRA		4	//Safra
#DEFINE BCO_CITI		5	//Citibank
#DEFINE BCO_CEF			6	//Caixa Economica Federal
#DEFINE BCO_SANTA		7	//Santander
//Estrutura do SACADO
#DEFINE POS_SC_NOM		1	//Razão Social
#DEFINE POS_SC_NRD		2	//Nome Reduzido
#DEFINE POS_SC_COD		3	//Codigo
#DEFINE POS_SC_END		4	//Endereco
#DEFINE POS_SC_MUN		5	//Municipio
#DEFINE POS_SC_UF		6	//UF
#DEFINE POS_SC_CEP		7	//CEP
#DEFINE POS_SC_BAI		8	//Bairro
#DEFINE POS_SC_CGC		9	//CNPJ
#DEFINE POS_SC_TIP		10	//Tipo de pessoa
//Estrutura do BANCO
#DEFINE POS_BC_COD		1	//Numero do Banco
#DEFINE POS_BC_NOM		2	//Nome do Banco
#DEFINE POS_BC_AGE		3	//Agencia
#DEFINE POS_BC_CC		4	//Conta Corrente
#DEFINE POS_BC_DV		5	//Digito CC
#DEFINE POS_BC_CRT		6	//Codigo carteira
#DEFINE POS_BC_TXM		7	//Taxa mora diaria
#DEFINE POS_BC_CCO		8	//Codigo Convenio OPUS (BB)
//Estrutura do TITULO FINANCEIRO
#DEFINE POS_TF_NUM		1	//Numero titulo
#DEFINE POS_TF_EMI		2	//Emissao titulo
#DEFINE POS_TF_EMB		3	//Emissao do boleto
#DEFINE POS_TF_VCT		4	//Vencimento
#DEFINE POS_TF_VAL		5	//Valor
#DEFINE POS_TF_NNR		6	//Nosso numero (ver formula para calculo)
#DEFINE POS_TF_PRX		7	//Prefixo da NF
#DEFINE POS_TF_TIP		8	//Tipo do titulo
#DEFINE POS_TF_DES		9	//Desconto financeiro

#DEFINE __cCarteira "109"
#DEFINE __cMoeda    "9"

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} OUROXBOL
Impressão de Boleto em PDF usando TotvsPrinter (FwMsPrinter)

@type 		function
@author 	Roberto Souza
@since 		12/01/2017
@version 	P11 
 
@return nil
/*/    
//-------------------------------------------------------------------------------------
User Function OUROXBOL()
	Local oArea		   		:= FWLayer():New()
	Local aCoord			:= {0,0,550,1300}//FWGetDialogSize(oMainWnd)
	//.Local lMDI				:= oAPP:lMDI
	//.Local aTamObj			:= Array(4)
	//.Local oOk 				:= LoadBitmap(GetResources(),"LBOK")
	//.Local oNo 				:= LoadBitmap(GetResources(),"LBNO")
	
	Local cCodCart          := ""
	//.Local nOpcA		  		:= 0
	Local bOk				:= {|| U_BolPdfPt(oMark, cMark, cCodCart ),(cAliasB)->(DbGoTop())}
	Local bGeraBol			:= {|| U_BolSetB( oMainBol, oMark ),(cAliasB)->(DbGoTop())}
	Local bCancel			:= {|| oMainBol:End() }
	//.Local bLegenda			:= {|| U_BolPdfLg() }
	//.Local aButtons			:= {}
	//.Local aTamCpo			:= {}
	//.Local nA				:= 0
	//.Local nI				:= 0
	Local nW				:= 0
	//.Local cNomDep			:= ""
	//.Local oFont		  		:= TFont():New("Arial",08,10,,.T.,,,,.T.)
	
	Local oButt1,oButt2
	Local aSize     	:= {}
	Local aArea     	:= GetArea()
	Local aInfo     	:= {}
	Local aObjects  	:= {}
	Local aPosObj 		:= {}
	//.Local bChange   	:= {|| }
	//.Local aCols1    	:= {}
	//.Local aFields   	:= {}
	//.Local aField    	:= {}
	//.Local aFieldEdit	:= {}
	//.Local aCpoEnch  	:= {}
	//.Local aPos 	    	:= {012,005,200,600}
	//.Local aCpoH     	:= {}
	//.Local cDescView 	:= ""
	//.Local aCombo    	:= {}
	Local aPerg     	:= {}
	Local aParam    	:= Array(1)
	//.Local aView     	:= {}
	//.Local nLimit    	:= 9999
	//.Local oEnt1,oEnt2
	
	//.Local aStru			:= {}
	Local aCpoBro 		:= {}
	//.Local oDlg
	Local aCores 		:= {}
	Local cPerg     	:="BOLPDF"
	Local cWhere        := ""
	Local lPendentes    := .F.
	Local lQuery        := .F.
	Local cFldFlag      := "E1_XBOLETO"
	Local lFlagBol      := SE1->(FieldPos(cFldFlag)) > 0 
	Local lGeraBol		:= .F.
	Local nX			:= 0
	
	Private aBcoBol		:= BcoByFil() // Retorna Parametros para Boleto
	Private oMainBol
	Private lInverte 	:= .F.
	Private cMark   	:= GetMark()
	Private oMark
	Private cAliasB   	:= "SE1"//GetNextAlias()
	Private aHeader 	:= {}
	Private aCols		:= {}
	Private nView     	:= 1
	Private cCadastro   := "Impressão de Boleto"
	Private aMarked     := {}
	Private cIndexName 	:= ''
	Private cIndexKey  	:= ''
	Private cFilter    	:= ''
	Private lParBox    	:= .T.          
	Private lContinua 	:= .F.
	Private cParBol     := "BOLETOPDF"
	
	
	If !lFlagBol    
		MsgAlert("Campo de flag de impressão não encontrado : '"+cFldFlag+"'."+CRLF)
		Return( Nil )	
	EndIf
	
	lPendentes    := .F.  
	
/*	
	If Aviso("Impressão de boleto","Deseja imprimir os boletos pendentes ou selecionar os parâmetros para impressão?",{"Pendentes","Selecionar"},2) == 2
		lPendentes := .F.
	Else
		lPendentes := .T.
	EndIf
*/


	If lPendentes // Imprime somente os boletos faturados não impressos
		aLabel := {}
	
		cWhere	+= 	"%"
		cWhere	+= 	"E1_XBOLETO = '1' "
		cWhere	+= 	"AND E1_FILIAL ='"+xFilial("SE1")+"'"
		cWhere	+= 	"AND E1_PORTADO <> '' "
	//	cWhere	+= 	"AND E1_AGEDEP <>'' AND E1_CONTA <> '' "
		cWhere	+= 	"%"
	
		cAliasBol := GetNextAlias()
	
		BeginSql ALIAS cAliasBol
			SELECT 	E1_NUM, 
					E1_PREFIXO,
					E1_PARCELA,
					E1_CLIENTE,
					E1_LOJA
				FROM %table:SE1% SE1
				WHERE SE1.%notdel% AND %Exp:cWhere%
			ORDER BY E1_NUM, E1_PREFIXO, E1_PARCELA, E1_CLIENTE, E1_LOJA
		EndSql
	
		While (cAliasBol)->(!Eof())
	
			Aadd(aLabel,{	(cAliasBol)->E1_NUM		,;
							(cAliasBol)->E1_PREFIXO	,;
							(cAliasBol)->E1_PREFIXO	,;
							(cAliasBol)->E1_PARCELA	,;
							(cAliasBol)->E1_CLIENTE	,;
							(cAliasBol)->E1_LOJA	,;
							aBcoBol[06]})
			(cAliasBol)->(DbSkip())
		Enddo
		If !Empty(aLabel)
			U_MYBOLPDF(aLabel)
		Else
			MsgInfo("Nenhum boleto pendente de impressão.")	
		EndIf
	
	Else
	
		If lParBox
		              
			aParam := Array(15)	
			aParam[01]	:= Space(03) 
			aParam[02]	:= Space(03)
			aParam[03]	:= Space(09)
			aParam[04]	:= Space(09)
			aParam[05]	:= Space(01)
			aParam[06]	:= Space(01)
			aParam[07]	:= Space(03)
			aParam[08]	:= Space(03)
			aParam[09]	:= Space(06)
			aParam[10]	:= Space(02)
			aParam[11]	:= Space(06)
			aParam[12]	:= Space(02)
			aParam[13]	:= Stod(Space(08))
			aParam[14]	:= Stod(Space(08))
			aParam[15]	:= PadR("",Len("02-Sem Registro"))
		
			Aadd(aPerg,{1,"De Prefixo"	,aParam[01]	,"",".T.",,".T.",020,.F.})
			Aadd(aPerg,{1,"Ate Prefixo"	,aParam[02]	,"",".T.",,".T.",020,.T.})
			Aadd(aPerg,{1,"De Numero"	,aParam[03]	,"",".T.",,".T.",040,.F.})
			Aadd(aPerg,{1,"Ate Numero"	,aParam[04]	,"",".T.",,".T.",040,.T.})
			Aadd(aPerg,{1,"De Parcela"	,aParam[05]	,"",".T.",,".T.",010,.F.})
			Aadd(aPerg,{1,"Ate Parcela"	,aParam[06]	,"",".T.",,".T.",010,.T.})
			Aadd(aPerg,{1,"De Portador"	,aParam[07]	,"",".T.",,".T.",020,.F.})//"SA6","","","",""})
			Aadd(aPerg,{1,"Ate Portador",aParam[08]	,"",".T.",,".T.",020,.T.})//"SA6","","","",""})
			Aadd(aPerg,{1,"De Cliente"	,aParam[09]	,"",".T.","SA1",".T.",030,.F.})//"SA1","","","",""})
			Aadd(aPerg,{1,"De Loja"		,aParam[10]	,"",".T.",,".T.",010,.F.})
			Aadd(aPerg,{1,"Ate Cliente"	,aParam[11]	,"",".T.","SA1",".T.",030,.T.})//"SA1","","","",""})
			Aadd(aPerg,{1,"Ate Loja"	,aParam[12]	,"",".T.",,".T.",010,.T.})
			Aadd(aPerg,{1,"De Emissao"	,aParam[13]	,"",".T.",,".T.",040,.F.})
			Aadd(aPerg,{1,"Ate Emissao"	,aParam[14]	,"",".T.",,".T.",040,.T.})
//			Aadd(aPerg,{2,"Carteira"	,PadR("",Len("02-Sem Registro")),{"02-Sem Registro","09-Registrada"},060,".T.",.T.,".T."})
		
			For Nx := 1 To Len(aParam)
				aParam[Nx] := ParamLoad(cParBol,aPerg,Nx,aParam[Nx])
			Next
			
			If ParamBox(aPerg,"Parâmetros",,,,,,,,cParBol,.T.,.T.)
		    	lContinua := .T.
//				cCodCart := Substr(MV_PAR15,1,2)
			EndIf
		Else
			AjustaSX1( cPerg )
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica as perguntas selecionadas                           ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If Pergunte(cPerg,.T.)  
		    	lContinua := .T.
/*		
				If MV_PAR15 == 1
					cCodCart := "02" // MV_?? Carteira
				ElseIf MV_PAR15 == 2
					cCodCart := "09" // MV_?? Carteira
				Else
					cCodCart := "02" // MV_?? Carteira
				EndIf	                              
*/
			EndIf
			   	
		EndIf
		
		If lContinua
			
			If lQuery
				cFilter  := "%" +;
							"E1_PREFIXO>= '" + MV_PAR01 + "' And E1_PREFIXO <= '" + MV_PAR02 + "' And " + ;
							"E1_NUM     >= '" + MV_PAR03 + "' And E1_NUM     <= '" + MV_PAR04 + "' And " + ;
							"E1_PARCELA >= '" + MV_PAR05 + "' And E1_PARCELA <= '" + MV_PAR06 + "' And " + ;
							"E1_PORTADO >= '" + MV_PAR07 + "' And E1_PORTADO <= '" + MV_PAR08 + "' And " + ;
							"E1_CLIENTE >= '" + MV_PAR09 + "' And E1_CLIENTE <= '" + MV_PAR11 + "' And " + ;
							"E1_LOJA    >= '" + MV_PAR10 + "' And E1_LOJA <= '" + MV_PAR12 + "' And "+;
							"E1_EMISSAO >= '" + DTOS(MV_PAR13) + "' And E1_EMISSAO <= '" + DTOS(MV_PAR14) + "' And " + ;
							"E1_FILIAL   = '" + xFilial("SE1") + "' And E1_SALDO > 0 And " + ;
							"E1_XBOLETO <> ' ' " +;
							"%"
//							"E1_PORTADO <> ' ' And " +;
//							"E1_NUMBCO  <> ' ' And " +;
//							"E1_XBOLETO <> ' ' " +;
//							"%"

				cAliasB := GetNextAlias()
                                      
				BeginSql ALIAS cAliasB
					SELECT 	E1_OK,
							E1_PREFIXO,
							E1_NUM,
							E1_PARCELA,
							E1_TIPO,
							E1_CLIENTE,
							E1_LOJA,
							E1_PORTADO,
							E1_NUMBCO,
							E1_EMISSAO,
							E1_VALOR,
							E1_SALDO,
							E1_VENCTO,
							E1_VENCREA,
							E1_XBOLETO
							
						FROM %table:SE1% SE1
						WHERE SE1.%notdel% AND %Exp:cFilter%
					ORDER BY E1_NUM, E1_PREFIXO, E1_PARCELA, E1_CLIENTE, E1_LOJA
				EndSql
				
				TCSetField( cAliasB, "E1_EMISSAO"	, "D" )		
				TCSetField( cAliasB, "E1_VENCTO"	, "D" )		
				TCSetField( cAliasB, "E1_VENCREA"	, "D" )		
			Else
				cIndexName := Criatrab(Nil,.F.)
				cIndexKey  := 	"E1_NUM+E1_PARCELA+E1_TIPO+DTOS(E1_EMISSAO)"
/*				
				cFilter  := "E1_PREFIXO >= '" + MV_PAR01 + "' .And. E1_PREFIXO <= '" + MV_PAR02 + "' .And. " + ;
							"E1_NUM     >= '" + MV_PAR03 + "' .And. E1_NUM     <= '" + MV_PAR04 + "' .And. " + ;
							"E1_PARCELA >= '" + MV_PAR05 + "' .And. E1_PARCELA <= '" + MV_PAR06 + "' .And. " + ;
							"E1_PORTADO >= '" + MV_PAR07 + "' .And. E1_PORTADO <= '" + MV_PAR08 + "' .And. " + ;
							"E1_CLIENTE >= '" + MV_PAR09 + "' .And. E1_CLIENTE <= '" + MV_PAR11 + "' .And. " + ;
							"E1_LOJA    >= '"+MV_PAR10+"' .And. E1_LOJA <= '"+MV_PAR12+"' .And. "+;
							"DTOS(E1_EMISSAO) >= '" + DTOS(MV_PAR13) + "' .And. DTOS(E1_EMISSAO) <= '" + DTOS(MV_PAR14) + "' .And. " + ;
							"E1_FILIAL   = '"+xFilial("SE1")+"' .And. E1_SALDO > 0 .And. " + ;
							"E1_PORTADO != ' ' .And. "+;
							"!Empty(E1_NUMBCO) .And. "+;
							"E1_XBOLETO <> ' '" 
*/
				cFilter  := "E1_PREFIXO >= '" + MV_PAR01 + "' .And. E1_PREFIXO <= '" + MV_PAR02 + "' .And. " + ;
							"E1_NUM     >= '" + MV_PAR03 + "' .And. E1_NUM     <= '" + MV_PAR04 + "' .And. " + ;
							"E1_PARCELA >= '" + MV_PAR05 + "' .And. E1_PARCELA <= '" + MV_PAR06 + "' .And. " + ;
							"E1_PORTADO >= '" + MV_PAR07 + "' .And. E1_PORTADO <= '" + MV_PAR08 + "' .And. " + ;
							"E1_CLIENTE >= '" + MV_PAR09 + "' .And. E1_CLIENTE <= '" + MV_PAR11 + "' .And. " + ;
							"E1_LOJA    >= '"+MV_PAR10+"' .And. E1_LOJA <= '"+MV_PAR12+"' .And. "+;
							"DTOS(E1_EMISSAO) >= '" + DTOS(MV_PAR13) + "' .And. DTOS(E1_EMISSAO) <= '" + DTOS(MV_PAR14) + "' .And. " + ;
							"E1_FILIAL   = '"+xFilial("SE1")+"' .And. E1_SALDO > 0 .And. " + ;
							"E1_XBOLETO <> ' '" 
							
				DbSelectArea("SE1")
				DbSetOrder(7)
				IndRegua("SE1", cIndexName, cIndexKey,, cFilter, "Aguarde selecionando registros....")
				
				DbGoTop()
	
			EndIf
			
			If (cAliasB)->(!Eof())
			
				aAdd(aCores,{"E1_XBOLETO == '2'","BR_VERDE"	})
				aAdd(aCores,{"E1_XBOLETO <> '2'","BR_AMARELO"})
					                
				aCpoBro	:= {{ "E1_OK"		,, "  "            	,"@!"},;
							{ "E1_PREFIXO"	,, "Pref."       	,"@!"},;
							{ "E1_NUM"		,, "Titulo"        	,"@!"},;
							{ "E1_PARCELA"	,, "Parcela"       	,"@!"},;
							{ "E1_TIPO"		,, "Tipo"      	    ,"@!"},;
							{ "E1_CLIENTE"	,, "Cliente"       	,"@!"},;
							{ "E1_LOJA"		,, "Loja"          	,"@!"},;
							{ "E1_PORTADO"	,, "Banco"         	,"@!"},;
							{ "E1_NUMBCO"	,, "Num. Banco"     ,"@!"},;
							{ "E1_EMISSAO"	,, "Emissão" 		,"@D" },;
							{ "E1_VALOR"	,, "Valor"			,"@E 999,999.99"},;
							{ "E1_SALDO"	,, "Saldo" 			,"@E 999,999.99"},;
							{ "E1_VENCTO"	,, "Vencto" 		,"@D" },;
							{ "E1_VENCREA"	,, "Venc. Real"		,"@D" },;
							{ "E1_DESCFIN"	,, "Desc. Fin."		,"@E 999.99" }}
			
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
		
				oMainBol := tDialog():New(aCoord[1],aCoord[2],aCoord[3],aCoord[4],OemToAnsi(cCadastro)+"-"+COMP_DATE,,,,,CLR_BLACK,CLR_WHITE,,,.T.)
				oArea:Init(oMainBol,.F.)
				//Mapeamento da area
				oArea:AddLine("L01",100,.T.)

				//ÚÄÄÄÄÄÄÄÄÄ¿
				//³Colunas  ³
				//ÀÄÄÄÄÄÄÄÄÄÙ
				oArea:AddCollumn("L01C01",90,.F.,"L01") //dados
				oArea:AddCollumn("L01C02",10,.F.,"L01") //botoes

				//ÚÄÄÄÄÄÄÄÄÄ¿
				//³Paineis  ³
				//ÀÄÄÄÄÄÄÄÄÄÙ
				oArea:AddWindow("L01C01","LIST","Selecione os boletos à serem impressos",100,.F.,.F.,/*bAction*/,"L01",/*bGotFocus*/)
				oList	:= oArea:GetWinPanel("L01C01","LIST","L01")
		
				oArea:AddWindow("L01C02","L01C02P01","Funções",100,.F.,.F.,/*bAction*/,"L01",/*bGotFocus*/)
				oAreaBut := oArea:GetWinPanel("L01C02","L01C02P01","L01")
		
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Painel 02-Registros         ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				oMark := MsSelect():New(cAliasB,"E1_OK","",aCpoBro,@lInverte,@cMark,{002,002,(oList:nClientHeight)*0.7,(oList:nClientWidth)*0.7},,,oList,,aCores)
				oMark:oBrowse:align := CONTROL_ALIGN_ALLCLIENT
				oMark:oBrowse:lhasMark    := .T.
				oMark:oBrowse:lCanAllmark := .T.						//Indica se pode marcar todos de uma vez
				oMark:oBrowse:bAllMark := {|| U_MyBolMkA()}
				oMark:bMark := {|| U_MyBolMkP()}
				For Nw := 1 To Len(oMark:oBrowse:ACOLSIZES)
					oMark:oBrowse:ACOLSIZES[Nw] := oMark:oBrowse:ACOLSIZES[Nw] * 0.8
				Next
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Painel 03-Botoes            ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				
				If lGeraBol
					oButt1 := tButton():New(000,000,"&Imprimir"			,oAreaBut,bOk 			,oAreaBut:nClientWidth/2,15,,/*oFont*/,,.T.,,,,/*bWhen*/)
					oButt2 := tButton():New(016,000,"&Habilitar Boleto"	,oAreaBut,bGeraBol		,oAreaBut:nClientWidth/2,15,,/*oFont*/,,.T.,,,,/*bWhen*/)
					oButt3 := tButton():New(032,000,"&Fechar"			,oAreaBut,bCancel		,oAreaBut:nClientWidth/2,15,,/*oFont*/,,.T.,,,,/*bWhen*/)

				Else
					oButt1 := tButton():New(000,000,"&Imprimir"	,oAreaBut,bOk		,oAreaBut:nClientWidth/2,15,,/*oFont*/,,.T.,,,,/*bWhen*/)
					oButt2 := tButton():New(016,000,"&Fechar"	,oAreaBut,bCancel	,oAreaBut:nClientWidth/2,15,,/*oFont*/,,.T.,,,,/*bWhen*/)
				EndIf		

				oLeg01 := TBitmap():New((oAreaBut:NCLIENTHEIGHT/2) - 30,000,110,010,,"BR_VERDE"		,.T.,oAreaBut,{||},,.F.,.F.,,,.F.,,.T.,,.F.)
				oLeg02 := TBitmap():New((oAreaBut:NCLIENTHEIGHT/2) - 20,000,120,010,,"BR_AMARELO"	,.T.,oAreaBut,{||},,.F.,.F.,,,.F.,,.T.,,.F.)
//				oLeg03 := TBitmap():New((oAreaBut:NCLIENTHEIGHT/2) - 10,000,120,010,,"BR_BLUE"		,.T.,oAreaBut,{||},,.F.,.F.,,,.F.,,.T.,,.F.)

                
				oSay01:= TSay():New((oAreaBut:NCLIENTHEIGHT/2) - 30,010,{||'Impresso'}		,oAreaBut,,/*oFont*/,,,,.T.,CLR_BLUE,CLR_WHITE,,)
				oSay02:= TSay():New((oAreaBut:NCLIENTHEIGHT/2) - 20,010,{||'Não Impresso'}	,oAreaBut,,/*oFont*/,,,,.T.,CLR_BLUE,CLR_WHITE,,)				
//				oSay03:= TSay():New((oAreaBut:NCLIENTHEIGHT/2) - 10,010,{||'E-mail Enviado'},oAreaBut,,/*oFont*/,,,,.T.,CLR_BLUE,CLR_WHITE,,)				

		
				oMainBol:Activate(,,,.T.,/*valid*/,,/*On Init*/)
			
			Else
				Aviso("Aviso de impressão Boleto", "Nenhum boleto foi encontrado nos parametros selecionados.",{"Ok"})
			EndIf
			
			DelClassIntF()
			
			RETINDEX("SE1")
			fErase(cIndexName+OrdBagExt())
			
		EndIf
	EndIf
		
	RestArea(aArea)
Return

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} MyBolMkA
Marca/Desmarca todos os registros      

@type 		function
@author 	Roberto Souza
@since 		12/01/2017
@version 	P11 
 
@return nil
/*/    
//-------------------------------------------------------------------------------------
User Function MyBolMkA()
	Local cOk  := ""
	DbSelectArea(cAliasB)
	DbGoTop()
	
	cOk := IIf( (cAliasB)->E1_OK == cMark , "  ", cMark)
	
	While (cAliasB)->(!Eof())
		RecLock(cAliasB,.F.)
		(cAliasB)->E1_OK := cOk
		MsUnlock()
		(cAliasB)->(DbSkip())
	EndDo
	
	DbGoTop()
	
	oMark:oBrowse:Refresh()
	oMainBol:Refresh()
Return(.T.)


//-------------------------------------------------------------------------------------
/*/{Protheus.doc} MyBolMkP
Marca/Desmarca um registro      

@type 		function
@author 	Roberto Souza
@since 		12/01/2017
@version 	P11 
 
@return nil
/*/    
//-------------------------------------------------------------------------------------	
User Function MyBolMkP()
	DbSelectArea(cAliasB)
	
	RecLock(cAliasB,.F.)
	If (cAliasB)->E1_OK == cMark
		(cAliasB)->E1_OK := cMark
	Else
		(cAliasB)->E1_OK := "  "
	Endif
	MsUnlock()
	
	oMark:oBrowse:Refresh()
	oMainBol:Refresh()
Return(.T.)
                                            


//-------------------------------------------------------------------------------------
/*/{Protheus.doc} BolPdfPt
Prepara os registros marcados para impressão      

@type 		function
@author 	Roberto Souza
@since 		12/01/2017
@version 	P11 
 
@return nil
/*/    
//-------------------------------------------------------------------------------------
User Function BolPdfPt(oMark, cMark, cCodCart )
Local aLabel 	:= {}
Local cBcoBol   := "237|341"
//Local lRet 		:= .T.
Local lImprime 	:= .T.
Local cMsgErro  := ""
Default cCodCart := "02"

lImprime := VldImp()    

If lImprime

	DbSelectArea("SE1")
	DbGoTop()
	While !EOF()
		If Marked("E1_OK")
	                         
			If !Empty(SE1->E1_PORTADO) .And. !SE1->E1_PORTADO $ cBcoBol
				cMsgErro += "Impressão do banco "+AllTrim(SE1->E1_PORTADO)+" não foi homologada."+CRLF
				lImprime := .F.
			EndIf
			
			If lImprime .And. SE1->E1_SALDO <> SE1->E1_VALOR
				If !MSGYESNO( "Título "+AllTrim(SE1->E1_NUM) +" com baixa parcial."+CRLF+"Continua Impressão?", "Atenção" )
					cMsgErro += "Título "+AllTrim(SE1->E1_NUM) +" com baixa parcial."+CRLF
					lImprime := .F.
				EndIf
			EndIf


			If lImprime
									
				If Empty(SE1->E1_NUMBCO)
					nBanco := 0
					RecLock( "SE1", .F. )
					SE1->E1_NUMBCO  := U_xGetNNum( aBcoBol[01], SE1->E1_PREFIXO,SubStr(SE1->E1_NUM,4,6),SE1->E1_PARCELA, aBcoBol[06], @nBanco )
					SE1->E1_PORTADO := aBcoBol[01]
					SE1->E1_AGEDEP  := aBcoBol[03]
					SE1->E1_CONTA   := aBcoBol[04]
					SE1->( MSUnLock() )
					
					// [1]Numero do Banco
					// [2]Nome do Banco
					// [3]Agência
					// [4]Conta Corrente
					// [5]Dígito da conta corrente
					// [6]Codigo da Carteira
					// [7]Tx de Mora Diaria
		
				EndIf			
	
				Aadd(aLabel,{SE1->E1_NUM,SE1->E1_PREFIXO,SE1->E1_PREFIXO,SE1->E1_PARCELA,SE1->E1_CLIENTE,SE1->E1_LOJA, aBcoBol[06] })
			EndIf
		EndIf
		DbSkip()
	EndDo
	
	If !Empty(aLabel)
		U_MYBOLPDF(aLabel)
		If !Empty(cMsgErro)
			Aviso("Aviso de impressão Boleto", cMsgErro+"Os Boletos não serão impressos.",{"Ok"})
		EndIf
	Else
		Aviso("Aviso de impressão Boleto", cMsgErro+"Os Boletos não serão impressos.",{"Ok"})
	EndIf
EndIf
	
Return()

                                     


//-------------------------------------------------------------------------------------
/*/{Protheus.doc} BolPdfPt
Prepara os registros marcados para impressão      

@type 		function
@author 	Roberto Souza
@since 		12/01/2017
@version 	P11 
 
@return nil
/*/    
//-------------------------------------------------------------------------------------
Static Function VldImp()
	Local lRet 		:= .F.
	Local cMsgAvis 	:= ""	

    If Empty( aBcoBol )                                                                          
    	cMsgAvis += "Não existe banco configurado para geração de novos boletos nesta filial." + CRLF
    	cMsgAvis += "Apenas boletos com dados bancarios já gravados poderão ser impressos." + CRLF
    	cMsgAvis += "Deseja continuar com a impressão ou cancelar?" + CRLF
    Else
    	cMsgAvis += "Os boletos sem dados bancários serão vinculados ao seguinte banco:" + CRLF
    	cMsgAvis += CRLF
    	cMsgAvis += "Banco : "+aBcoBol[01] +" - "+aBcoBol[02] + CRLF
    	cMsgAvis += "Agencia/Conta : "+aBcoBol[03] +" - "+aBcoBol[04] + CRLF
    	cMsgAvis += "Carteira : "+aBcoBol[06] + CRLF
    	cMsgAvis += CRLF
    	cMsgAvis += "Deseja continuar com a impressão ou cancelar?"+CRLF
					// [1]Numero do Banco
			 		// [2]Nome do Banco
					// [3]Agência
			 		// [4]Conta Corrente
					// [5]Dígito da conta corrente
				  	// [6]Codigo da Carteira
					// [7]Tx de Mora Diaria

    EndIf      
		
    lRet := ( Aviso("Atenção",cMsgAvis,{"Continuar","Cancelar"} ,3 ) == 1 )
    
Return( lRet )

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} MYBOLPDF
Rotina para impressao de boletos bancarios em PDF para multiplos bancos

@type 		function
@author 	Roberto Souza
@since 		12/01/2017
@version 	P11 
@param	 	aLabel 	1-Numero do documento                               
 					2-Serie do documento                                
					3-Prefixo do titulo                                 
					4-Parcela do Titulo                                 
					5-Codigo do cliente                                 
					6-Loja do cliente                                   
			lTela  - Mostra tela de setup 		
@return nil
/*/    
//-------------------------------------------------------------------------------------
User Function MYBOLPDF( aLabel , lTela )
	Local aArea         := GetArea()
	Local oLabelPDF
	//.Local nHRes  		:= 0
	//.Local nVRes  		:= 0
	//.Local nDevice
	Local cFilePrint	:= ""
	Local oSetupPDF
	Local aDevice  		:= {}
	Local cSession     	:= GetPrinterSession()
	//.Local cPrinter	  	:= GetProfString( cSession,"DEFAULT","",.T. )
	//.Local nRet 			:= 0
	//.Local Nx 			:= 0
	//.Local aTipos 		:= {}
	Local nTipo  		:= 1
	Local lGoPrint 		:= .F. 
	Local cPrefFile     := ""//aLabel[01][05]+"-"+aLabel[01][06]+"-"		

	Default lTela := .T.
	
	If Empty(aLabel)
		Aviso("Boleto","Nenhum Boleto a ser impresso nos parametros utilizados.",{"OK"},2)
	Else
		cFilePrint := cPrefFile+"Boleto_"+StrZero(nTipo,3)+"_"+Dtos(MSDate())+StrTran(Time(),":","")
		
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
	
		oSetupPDF := FWPrintSetup():New(nFlags, "Boleto")
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Define saida                                                 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oSetupPDF:SetPropert(PD_PRINTTYPE   , nPrintType)
		oSetupPDF:SetPropert(PD_ORIENTATION , nOrientation)
		oSetupPDF:SetPropert(PD_DESTINATION , nLocal)
		oSetupPDF:SetPropert(PD_MARGIN      , {0,0,0,0})
		oSetupPDF:SetPropert(PD_PAPERSIZE   , DMPAPER_A4)
		oSetupPDF:aOptions[6] := cPathDest                    
		
		If lTela // Chamada da impressão com tela
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Pressionado botão OK na tela de Setup                        ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			lGoPrint := oSetupPDF:Activate() == PD_OK // PD_OK =1
		Else
			lGoPrint := .T.	
		
		EndIf

		If lGoPrint
			oLabelPDF := FWMSPrinter():New(cFilePrint, IMP_PDF, lAdjustToLegacy, /*cPathInServer*/, .T.)
		
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Define saida de impressão                                    ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If oSetupPDF:GetProperty(PD_PRINTTYPE) == IMP_SPOOL
				oLabelPDF:nDevice := IMP_SPOOL
				oLabelPDF:cPrinter := oSetupPDF:aOptions[PD_VALUETYPE]
				If Len(oSetupPDF:APRINTER) > 0
					oLabelPDF:cPrinter := oSetupPDF:APRINTER[01]
				EndIf
			ElseIf oSetupPDF:GetProperty(PD_PRINTTYPE) == IMP_PDF
				oLabelPDF:nDevice := IMP_PDF
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Define para salvar o PDF                                     ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				oLabelPDF:cPathPDF := oSetupPDF:aOptions[PD_VALUETYPE]
			Endif
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Salva os Parametros no Profile             ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	        //.WriteProfString( cSession, "Local"      , If(oSetupPDF:GetProperty(PD_DESTINATION)==1 ,"SERVER"    ,"CLIENT"    ), .T. )
	        //.WriteProfString( cSession, "PRINTTYPE"  , If(oSetupPDF:GetProperty(PD_PRINTTYPE)==1   ,"SPOOL"     ,"PDF"       ), .T. )
	        //.WriteProfString( cSession, "ORIENTATION", If(oSetupPDF:GetProperty(PD_ORIENTATION)==1 ,"PORTRAIT"  ,"LANDSCAPE" ), .T. )
			//.WriteProfString( cSession, "DEFAULT"    , oSetupPDF:aOptions[PD_VALUETYPE], .T.)
			//.WriteProfString( cSession, "PATHDEST"   , oSetupPDF:aOptions[6], .T.)
	
	        If lTela
				MsgRun( "Imprimindo...", "Boleto", {|| OUBOLPDFA(aLabel,oLabelPDF) } )
			Else
				OUBOLPDFA(aLabel,oLabelPDF)
			EndIf	
		Else
			MsgInfo("Relatório cancelado pelo usuário.")
		Endif
	EndIf
	
	If !lTela
		oLabelPDF := Nil
		oSetupPDF := Nil   
//		DelClassIntf()
	EndIf
	
	RestArea( aArea )	
Return( Nil )

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} OUBOLPDFA
Rotina auxiliar para impressao de boletos bancarios em PDF para multiplos bancos

@type 		function
@author 	Roberto Souza
@since 		12/01/2017
@version 	P11 
@param	 	aDados 	1-Numero do documento                               
 					2-Serie do documento                                
					3-Prefixo do titulo                                 
					4-Parcela do Titulo                                 
					5-Codigo do cliente                                 
					6-Loja do cliente                                   
			oLabel  - Objeto de impressão (FwMsPrinter) 		
@return nil
/*/    
//-------------------------------------------------------------------------------------
Static Function OUBOLPDFA( aDados, oLabel )
Local oFont07, oFont08, oFont10, oFont09, oFont09n, oFont10n
Local oFont11n, oFont11, oFont14, oFont14n, oFont16n, oFont18
Local oFont20

Local aSavAre    := SaveArea1({"SF2", "SF4", "SD2", "SB1", "SE1", "SE4", "SEE", "SA6", "SA1", "SA3", "SA4", "DAK", "DA3", "DA4"})
Local aDatSacado := Nil
Local cMsgMulta  := ""
//.Local cMsgDesc	 := ""
Local cMsg		 := ""
Local nItemNota  := 0
//.Local bWhileD2   := Nil
Local lContD2    := .F.
Local nTotUnid1  := 0
Local nTotUnid2  := 0
//.Local cTotUnid1  := ""
//.Local cTotUnid2  := ""
Local lBoleto    := .T.
Local aCB_RN_NN  	:= Nil
Local cNossoNum  	:= Nil
//.Local cAgenCeden 	:= Nil
Local cAgCed	 	:= ""
Local cPagavel		:= "PAGÁVEL EM QUALQUER BANCO ATÉ O VENCIMENTO"
Local Nx			:= 0
Local Nw			:= 0
Local aBolText 		:= {"","","","","","",""}
Local cNoImp    	:= ""
Local aRecImp   	:= {}
Local cCedente 		:= AllTrim(SM0->M0_NOMECOM) 
Local xcParcela		:= ""	
Private nHori				:= 3.5 //3.9 //096774
Private nVert				:= 3.60// 3.85
Private oPrint              := oLabel  

Private nModel				:= 1 // Modelo de impressão com 2 partes padrao FEBRABAN

nBoletos := Len(aDados)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define as fontes usadas naimpressao                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//oFather, cNameFont, nWidth, nHeight, lBold, lItalic, lUnderline
oFont07    := TFontEx():New(oPrint,"Arial"      , 9,  7,.F.,.F.,.F.)
oFont08    := TFontEx():New(oPrint,"Arial"      , 9,  8,.T.,.F.,.F.)
oFont08n   := TFontEx():New(oPrint,"Arial"      , 9,  8,.T.,.T.,.F.)
oFont10    := TFontEx():New(oPrint,"Arial"      , 8, 10,.T.,.F.,.F.)
oFont09    := TFontEx():New(oPrint,"Arial"      , 8, 09,.F.,.F.,.F.)
oFont09n   := TFontEx():New(oPrint,"Arial"      , 8, 09,.T.,.T.,.F.)
oFont10n   := TFontEx():New(oPrint,"Arial"      , 9, 10,.T.,.T.,.F.)
oFont11n   := TFontEx():New(oPrint,"Arial"		,10, 10,.T.,.T.,.F.)
oFont11b   := TFontEx():New(oPrint,"Courier New",10, 10,.T.,.T.,.F.)
oFont11    := TFontEx():New(oPrint,"Arial"      , 9, 11,.T.,.F.,.F.)
oFont14    := TFontEx():New(oPrint,"Arial"      , 9, 14,.T.,.F.,.F.)
oFont14n   := TFontEx():New(oPrint,"Arial"      , 9, 14,.T.,.T.,.F.)
oFont16n   := TFontEx():New(oPrint,"Arial"      , 9, 16,.T.,.T.,.F.)
oFont18    := TFontEx():New(oPrint,"Arial"      , 9, 18,.T.,.T.,.F.)
oFont20    := TFontEx():New(oPrint,"Arial"      , 9, 20,.T.,.T.,.F.)
oFont22    := TFontEx():New(oPrint,"Arial"      , 9, 24,.T.,.T.,.F.)
    
// Objeto box cinza        
oBrush              := TBrush():New( , CLR_HGRAY )


For Nx := 1 To nBoletos

	cDoc     := aDados[Nx][01]
	cSerie   := aDados[Nx][02]
	cPrefixo := aDados[Nx][03]
	cParc    := aDados[Nx][04]
	cCliente := aDados[Nx][05]
	cLoja    := aDados[Nx][06]
	cCodCart := aDados[Nx][07]     

	If cDoc == Nil
		cDoc     := SF2->F2_DOC
		cSerie   := SF2->F2_SERIE
		cPrefixo := SF2->F2_PREFIXO
		cCliente := SF2->F2_CLIENTE
		cLoja    := SF2->F2_LOJA
	Endif
	/*
	SF2 - Cabeçalho das NF de Saída
	SF4 - Tipos de Entrada e Saida
	SD2 - Itens de Venda da NF
	SB1 - Descrição Genérica do Produto
	SE1 - Contas a Receber
	SE4 - Condições de Pagamento
	SEE - Comunicação Remota
	SA6 - Bancos
	SA1 - Clientes
	SA3 - Vendedores
	SA4 - Transportadoras
	DAK - Cargas
	DA3 - Veículos
	DA4 - Motoristas
	*/
	SE1->(dbSetOrder(2)) // E1_FILIAL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
	SF2->(dbSetOrder(1)) // F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA+F2_FORMUL
	SF4->(dbSetOrder(1)) // F4_FILIAL+F4_CODIGO
	SD2->(dbSetOrder(3)) // D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD+D2_ITEM
	SB1->(dbSetOrder(1)) // B1_FILIAL+B1_COD

	SE4->(dbSetOrder(1)) // E4_FILIAL+E4_CODIGO
	SA3->(dbSetOrder(1)) // A3_FILIAL+A3_CODIGO
	SEE->(dbSetOrder(1)) // EE_FILIAL+EE_CODIGO+EE_AGENCIA+EE_CONTA+EE_SUBCTA
	SA6->(dbSetOrder(1)) // A6_FILIAL+A6_COD+A6_AGENCIA+A6_NUMCON
	SA1->(dbSetOrder(1)) // A1_FILIAL+A1_COD+A1_LOJA
	SA3->(dbSetOrder(1)) // A3_FILIAL+A3_COD
	SA4->(dbSetOrder(1)) // A4_FILIAL+A4_COD
	DAK->(dbSetOrder(1)) // DAK_FILIAL+DAK_COD+DAK_SEQCAR
	DA3->(dbSetOrder(1)) // DA3_FILIAL+DA3_COD
	DA4->(dbSetOrder(1)) // DA4_FILIAL+DA4_COD


	lSE1 := SE1->(dbSeek(xFilial("SE1") + cCliente + cLoja + cPrefixo + cDoc + cParc ))
	lSF2 := SF2->(dbSeek(SE1->E1_FILORIG + cDoc + cSerie + cCliente + cLoja))
	lSD2 := SD2->(dbSeek(SE1->E1_FILORIG + cDoc + cSerie + cCliente + cLoja))
	lSE4 := SE4->(dbSeek(xFilial("SE4") + SF2->F2_COND))
	lSA3 := SA3->(dbSeek(xFilial("SA3") + SF2->F2_VEND1))
	lSA1 := SA1->(dbSeek(xFilial("SA1") + cCliente + cLoja))
	lSA4 := SA4->(dbSeek(xFilial("SA4") + SF2->F2_TRANSP))
	lSA6 := SA6->(dbSeek(xFilial("SA6") + SE1->(E1_PORTADO + E1_AGEDEP + E1_CONTA)))
	lSEE := SEE->(dbSeek(xFilial("SEE") + SE1->(E1_PORTADO + E1_AGEDEP + E1_CONTA)))
	lDAK := DAK->(dbSeek(xFilial("DAK") + SF2->(F2_CARGA+F2_SEQCAR)))
	lDA3 := DA3->(dbSeek(xFilial("DA3") + DAK->DAK_CAMINH))
	lDA4 := DA4->(dbSeek(xFilial("DA4") + DAK->DAK_MOTORI))

	If !lSA6
		cNoImp += "Banco/conta gerado no título não existe. Cliente :" +SA1->A1_COD + "-" + SA1->A1_LOJA +" NF: " + cDoc +"-"+ cSerie + "."+CRLF
		Loop
	EndIf
	
	If !lSEE
		cNoImp += "Problema na configuração dos parametros bancários. Cliente :" +SA1->A1_COD + "-" + SA1->A1_LOJA +" NF: " + cDoc +"-"+ cSerie +"."+CRLF
		Loop
	EndIf

	If SE1->E1_PORTADO == "341"
		//U_BLTITAU(SE1->E1_NUM,SE1->E1_PREFIXO,SE1->E1_CLIENTE,SE1->E1_LOJA,SE1->E1_PARCELA)
		//Loop
	EndIf

	If Empty(SA1->A1_ENDCOB)
		aDatSacado   := {	Capital(AllTrim(SA1->A1_NOME))   ,;  // [ 1]Razão Social
		Capital(Alltrim(SA1->A1_NREDUZ))                     ,;  // [ 2]Nome Reduzido
		AllTrim(SA1->A1_COD )+"-"+SA1->A1_LOJA               ,;  // [ 3]Código
		Capital(AllTrim(SA1->A1_END ))                       ,;  // [ 4]Endereço
		Capital(AllTrim(SA1->A1_MUN ))                       ,;  // [ 5]Cidade
		SA1->A1_EST                                          ,;  // [ 6]Estado
		SA1->A1_CEP                                          ,;  // [ 7]CEP
		Capital(Alltrim(SA1->A1_BAIRRO))                     ,;  // [ 8]Bairro
		SA1->A1_CGC                                          ,;  // [ 9]CGC
		SA1->A1_PESSOA                                       }   // [10]PESSOA
	Else
		aDatSacado   := {	Capital(AllTrim(SA1->A1_NOME))   ,;  // [ 1]Razão Social
		Capital(Alltrim(SA1->A1_NREDUZ))                     ,;  // [ 2]Nome Reduzido
		AllTrim(SA1->A1_COD )+"-"+SA1->A1_LOJA               ,;  // [ 3]Código
		Capital(AllTrim(SA1->A1_ENDCOB))                     ,;  // [ 4]Endereço
		Capital(AllTrim(SA1->A1_MUNC))                       ,;  // [ 5]Cidade
		SA1->A1_ESTC                                         ,;  // [ 6]Estado
		SA1->A1_CEPC                                         ,;  // [ 7]CEP
		Capital(Alltrim(SA1->A1_BAIRROC))                    ,;  // [ 8]Bairro
		SA1->A1_CGC                                          ,;  // [ 9]CGC
		SA1->A1_PESSOA                                       }   // [10]PESSOA
	Endif
  
	DbSelectArea("SE1")
	While SE1->(!Eof()) .And. SE1->(E1_FILIAL + E1_CLIENTE + E1_LOJA + E1_PREFIXO + E1_NUM + E1_PARCELA) == xFilial("SE1") + cCliente + cLoja + cPrefixo + cDoc + cParc

		/*
		Caso campo SE1->E1_NUMBCO esteja vazio
		cria novo sequencial baseado no SEE
		*/
		If !lContD2
			nItemNota  := 0
			nTotUnid1  := 0
			nTotUnid2  := 0
		EndIf

		If lBoleto
			DbSelectArea("SEE")
			DbSetOrder(1)
			aDadosBanco  := {SEE->EE_CODIGO                    		,;	// [1]Numero do Banco
			"BANCO"      			            	                ,; 	// [2]Nome do Banco
			SUBSTR(SEE->EE_AGENCIA, 1, 5)                       	,;	// [3]Agência
			SUBSTR(SEE->EE_CONTA,1,5)								,; 	// [4]Conta Corrente
			SUBSTR(SEE->EE_CONTA,Len(AllTrim(SEE->EE_CONTA)),1) 	,; 	// [5]Dígito da conta corrente
	  		cCodCart /*SEE->EE_X_CART*/								,;  // [6]Codigo da Carteira
			0/*SEE->EE_TXMORBL*/ 									,;	// [7]Tx de Mora Diaria
			SUBSTR(SEE->EE_CODEMP,6,7)								}	// [8]Codigo do Convenio da Opus no BB

			aDadosTit	:= {AllTrim(SE1->E1_NUM)+AllTrim(SE1->E1_PARCELA)		,;  // [1] Número do título
			SE1->E1_EMISSAO                      			,;  // [2] Data da emissão do título
			dDataBase                    	     			,;  // [3] Data da emissão do boleto
			SE1->E1_VENCREA                       			,;  // [4] Data do vencimento
			SE1->E1_VALOR                          			,;  // [5] Valor do título - Alterado por César Moura em 20/03/2007
			SE1->E1_IDCNAB /*SE1->E1_XNBCO XXX*/   			,;  // [6] Nosso número (Ver fórmula para calculo)
			SE1->E1_PREFIXO                      			,;  // [7] Prefixo da NF
			SE1->E1_TIPO	                     			,;	// [8] Tipo do Titulo
			SE1->E1_DESCFIN									,;	// [9] Desconto Financeiro
			SE1->E1_VALOR-SE1->E1_SALDO                     }   // [10] Abatimentos
	        cBanco 		:= SA6->A6_COD
			cNumDocto 	:= ""
			cUsoBco     := ""//"8670"
			cQtBco		:= ""//"001"             

			If cBanco == "001"
				cNossoNum := NNumBB(cBanco,SA6->A6_AGENCIA,SA6->A6_NUMCON)
				SE1->(RecLock("SE1",.F.))
				SE1->E1_IDCNAB := Substr(cNossoNum,8,10)
				//				SE1->E1_NUMBCO := Substr(cNossoNum,8,10)
				SE1->(MsUnlock())
			ElseIf cBanco == "237"
				nNomBCO := "Bradesco"
				cNossoNum := SE1->E1_NUMBCO //NNumBRA(cBanco,SA6->A6_AGENCIA,SA6->A6_NUMCON,ALLTRIM(SEE->EE_SUBCTA) , .F. , @cNumDocto)
				cNumDocto := cNossoNum
	
			ElseIf cBanco $ "341|630"	//ITAU + INTERCAP
				//cNossoNum := NNumItau( cBanco,SA6->A6_AGENCIA,SA6->A6_NUMCON,ALLTRIM(SEE->EE_SUBCTA), !Empty(AllTrim(cCedente)) )
				//cNossoNum := AvalNNum(cNossoNum)
				
				If Empty(SE1->E1_NUMBCO)
					NossoNum()
				Endif

				xcParcela 	:= NumParcela(Alltrim(SE1->E1_PARCELA))
				cNroDoc		:= PADL(Alltrim(SE1->E1_NUM),9,"0") + xcParcela
				//cDvNN 		:= Str(modulo10(Alltrim(SEE->EE_AGENCIA)+Alltrim(SEE->EE_CONTA)+aBcoBol[06]+Right(AllTrim(SE1->E1_NUMBCO),8)),1)  //Alltrim(Str(Modulo10(cNossoNum)))
				//cNossoNum   := aBcoBol[06] + cNroDoc + cDvNN

				cNossoNum := SE1->E1_NUMBCO

				//If RecLock("SE1",.F.)
				//	SE1->E1_NUMBCO := cNossoNum
				//	SE1->(MsUnlock())
				//EndIf
		
				nNomBCO   := "Itau"
				cNumDocto := cNroDoc
				
			ElseIf cBanco == "422" // SAFRA
				cNossoNum := NNumSafra( cBanco,SA6->A6_AGENCIA,SA6->A6_NUMCON,ALLTRIM(SEE->EE_SUBCTA) )
				SE1->(RecLock("SE1",.F.))
				SE1->E1_IDCNAB := cNossoNum
				//				SE1->E1_NUMBCO := cNossoNum+U_md11Safra(cNossoNum)
				SE1->(MsUnlock())

			ElseIf cBanco == "745" // CITIBANK
				cNossoNum := NNumCiti( cBanco,SA6->A6_AGENCIA,SA6->A6_NUMCON,ALLTRIM(SEE->EE_SUBCTA) )
				SE1->(RecLock("SE1",.F.))
				SE1->E1_IDCNAB := cNossoNum
				SE1->(MsUnlock())

			ElseIf cBanco == "104" // CEF
				cNossoNum := NNumCEF( cBanco,SA6->A6_AGENCIA,SA6->A6_NUMCON,ALLTRIM(SEE->EE_SUBCTA) )
				SE1->(RecLock("SE1",.F.))
				SE1->E1_IDCNAB := cNossoNum
				SE1->(MsUnlock())
			ElseIf cBanco $ "|353|033|" // SANTANDER
				cNossoNum := NNumSant(cBanco,SA6->A6_AGENCIA,SA6->A6_NUMCON,ALLTRIM(SEE->EE_SUBCTA) )
				SE1->(RecLock("SE1",.F.))
				SE1->E1_IDCNAB := cNossoNum
				SE1->(MsUnlock())
			Else
				NossoNum()
			EndIf



			If ValType(cNossoNum) # "C"
				cNossoNum := AllTrim(AllToChar(cNossoNum))
			Endif

			If cBanco == "001" // BANCO DO BRASIL
				cPagavel	:= "PAGÁVEL EM QUALQUER BANCO ATÉ O VENCIMENTO"
				cAgCed		:= Alltrim(SA6->A6_AGENCIA)+"-"+alltrim(SA6->A6_DVAGE)+"/"+Substr(Right(Alltrim(SA6->A6_NUMCON),5),1,4)+"-"+alltrim(SA6->A6_DVCTA)
				nNrBancario := ALLTRIM(SE1->E1_IDCNAB)
				nNrConvenio := SUBSTR(SEE->EE_CODEMP,1,7)
				nNrBanc		:= Alltrim(nNrConvenio) + Alltrim(nNrBancario)
				nDVNrBanc	:= modulo11A(nNrBanc) //
				//cNossoNum	:= Transform(Right(cNossoNum,9),"@R 99999999-9")        alterado em 2001 por solicitacao do vicente
				aCB_RN_NN    := CBarBB(Subs(aDadosBanco[1],1,3)+"9",aDadosBanco[8],nNrBancario,aDadosTit[5],SE1->E1_VENCREA,nDVNrBanc,aDadosBanco[6])

			ElseIf cBanco $ "237" // BRADESCO
				cPagavel	:= "Pagável preferencialmente nas Agências do Bradesco."
				cAgCed		:= AllTrim(SA6->A6_AGENCIA)+Iif(Empty(SA6->A6_DVAGE),"","-"+alltrim(SA6->A6_DVAGE))  +"/"+Alltrim(SA6->A6_NUMCON)+Iif(Empty(SA6->A6_DVCTA),"","-"+alltrim(SA6->A6_DVCTA))

				nNrBancario := SUBSTR(SE1->E1_NUMBCO,1,11)
				nNrCart 	:= cCodCart //"03"//StrZero(Val(SEE->EE_X_CART),2) // SUBSTR(SEE->EE_X_CART,2,2)
				nDVNrBanc	:= SUBSTR(SE1->E1_NUMBCO,12,1) // Div verifacador do Nosso Num
				cNossoNum	:= nNrCart + "/" + nNrBancario + "-" +nDVNrBanc
				cConta      := Iif(Empty(SA6->A6_DVCTA), StrZero(Val(SUBSTR(SEE->EE_CONTA,1,(Len(AllTrim(SEE->EE_CONTA))-1))),7)  ,StrZero(Val(SEE->EE_CONTA),7) )
				cDvConta    := Iif(Empty(SA6->A6_DVCTA),Right(Alltrim(SEE->EE_CONTA),1),SA6->A6_DVCTA)

				cAgCed		:= AllTrim(SA6->A6_AGENCIA)+Iif(Empty(SA6->A6_DVAGE),"","-"+alltrim(SA6->A6_DVAGE))  +"/"+Alltrim(cConta)+Iif(Empty(cDvConta),"","-"+alltrim(cDvConta))

				cDescCart    := StrZero(Val(cCodCart),3)
				aCB_RN_NN    :=	CBarBra2(cBanco+"9",SUBSTR(SEE->EE_AGENCIA, 1, 5),cConta,aDadosTit[5],SE1->E1_VENCTO,nDVNrBanc,nNrCart,SUBSTR(SEE->EE_AGENCIA, 1, 5),cConta,cDvConta,nNrBancario)
				aAltCode	 :=	CBarBra3(cBanco+"9",SUBSTR(SEE->EE_AGENCIA, 1, 5),cConta,aDadosTit[5],SE1->E1_VENCTO,nDVNrBanc,nNrCart,SUBSTR(SEE->EE_AGENCIA, 1, 5),cConta,cDvConta,nNrBancario)		  
	
			ElseIf cBanco $ "341|630" // ITAU E INTERCAP
				cPagavel	:= "Até o Vencimento, Preferencialmente no "+Alltrim(SA6->A6_NREDUZ)+". Após somente no " + Alltrim(SA6->A6_NREDUZ) +"."
				cAgCed		:= Alltrim(SA6->A6_AGENCIA)+"/"+Alltrim(SA6->A6_NUMCON)+"-"+alltrim(SA6->A6_DVCTA)
				nNrBancario := Substr(SE1->E1_IDCNAB,1,8)
				nNrCart 	:= cCodCart //"03"//SUBSTR(SEE->EE_X_CART,1,3)
				nNrBanc		:= Alltrim(nNrCart) + Alltrim(nNrBancario)
				nDVNrBanc	:= Substr(SE1->E1_IDCNAB,9,1)
				//cNossoNum	:= nNrCart + "/" + nNrBancario + "-" +nDVNrBanc
				cDescCart := StrZero(Val(cCodCart),3)
				//aCB_RN_NN    := CBarItau(Subs(aDadosBanco[1],1,3)+"9",Alltrim(SA6->A6_AGENCIA),Alltrim(SA6->A6_NUMCON),alltrim(SA6->A6_DVCTA),nNrBancario+nDVNrBanc,aDadosTit[5],SE1->E1_VENCTO)
				//aCB_RN_NN    := CBarItau(Alltrim(SA6->A6_AGENCIA),Alltrim(SA6->A6_NUMCON),alltrim(SA6->A6_DVCTA),nNrBancario+nDVNrBanc,aDadosTit[5],SE1->E1_VENCTO)
				aCB_RN_NN    := fLinhaDig(aBcoBol[1]   ,; // Numero do Banco
										  __cMoeda     ,; // Codigo da Moeda
										  aBcoBol[6]   ,; // Codigo da Carteira
										  aBcoBol[3]   ,; // Codigo da Agencia
										  aBcoBol[4]   ,; // Codigo da Conta
										  aBcoBol[5]   ,; // DV da Conta
										  aDadosTit[5] ,; // Valor do Titulo
										  SE1->E1_VENCTO           ,; // Data de Vencimento do Titulo
										  StrZero(Val(Alltrim(SE1->E1_NUM)+Alltrim(SE1->E1_PARCELA)),8)) // Numero do Documento no Contas a Receber
			ElseIf cBanco $ "|353|033|" // SANTANDER
				aDadosBanco[06] := "203"
				cDescCart := aDadosBanco[06] //+ " - "
				cNossoNum   := StrZero(Val(SE1->E1_NUMBCO),13)
				cPagavel	:= "Até o Vencimento, Preferencialmente no "+Alltrim(SA6->A6_NREDUZ)+". Após somente no " + Alltrim(SA6->A6_NREDUZ) +"."
				cAgCed		:= Alltrim(SA6->A6_AGENCIA)+"/"+Alltrim(SEE->EE_CODEMP) //"/ 4635329" //+Alltrim(SA6->A6_NUMCON)
	//			cNossoNum	:= Transform(Right(cNossoNum,13), '@R 999999999999-9' )//"@R 99999999999-9")
				aCB_RN_NN   := RetBarSant(	Substr(cBanco, 1, 3),;
				SE1->E1_VALOR,;
				SE1->E1_VENCTO,;
				cNossoNum,;
				'9',;
				Alltrim(SEE->EE_CODEMP),; //'02059851',;
				aDadosBanco[06])//AllTrim(SEE->EE_X_CART))

			ElseIf cBanco == "104" // CEF
				cPagavel	:= "Pagável preferencialmente nas Lotéricas, Agencia Caixa e Rede Bancaria até o vencimento"
				cAgCed		:= Substr(SA6->A6_AGENCIA,2,4)+"-"+alltrim(SA6->A6_DVAGE)+"/"+Alltrim(SA6->A6_NUMCON)+"-"+alltrim(SA6->A6_DVCTA)
				cMsg 		+= ". Apos o vencimento somente CEF."
				cAgCed		:=	_cCodCed
				nNrBancario := SUBSTR(SE1->E1_IDCNAB,1,10) // o faixa de numero no SEE possue 10 posicoes com + 1 do div
				nDVNrBanc	:= SUBSTR(SE1->E1_IDCNAB,11,1) // Div verificador do Nosso Num
				nNrCart 	:= SA6->A6_CARTEIR //"03"//SUBSTR(SEE->EE_X_CART,1,2)
				cNrAg		:= SA6->A6_AGENCIA
				cOP			:= "870"
				cCod		:= "000003762"
				// o campo do convenio possui 12 posicoes como o convenio da CEF tem 16 os 4 ultimos foram colocados no lote na tabela SEE
				nNrConvenio := SEE->(EE_CODEMP+EE_LOTE)
				cNossoNum	:= nNrBancario + nDVNrBanc
				aCB_RN_NN    := CBarCEF(cBanco,"9",SE1->E1_VENCTO,SE1->E1_VALOR,nNrCart,cNossoNum,alltrim(cNrAg),cOP,cCod)
				//cBanco,cMoeda,dVencto,nValor,cCartôeira,nNrConvenio,cNossso,cAg,cOP,cCod
			ElseIf cBanco == "745"
				cPagavel	:= "PAGÁVEL NA REDE BANCÁRIA ATÉ O VENCIMENTO"
				cAgCed		:= Alltrim(SA6->A6_AGENCIA)+"/"+Alltrim(SA6->A6_NUMCON)
				cNossoNum	:= Transform(Right(cNossoNum,12),"@R 99999999999-9")
				aCB_RN_NN   := RetBarCiti(	Substr(cBanco, 1, 3),;
				SE1->E1_VALOR,;
				SE1->E1_VENCTO,;
				AllTrim(SE1->E1_IDCNAB),;
				'9',;
				'0078387017',;
				'3',;
				'314')
				cMsgCiti := 'Após Vencto. Acesse WWW.CITIBANK.COM.BR/BOLETOS ou ligue 0800-7018701/(11) 2135-9510 e obtenha boleto pagável em qualquer banco, se preferir pague no CITIBANK, HSBC, BMB, RURAL e BIC até 4 dias'
			Else
				cPagavel	:= "Até o Vencimento, Preferencialmente no "+Alltrim(SA6->A6_NREDUZ)+". Após o venc. somente no " + Alltrim(SA6->A6_NREDUZ) +"."
				cAgCed		:= Alltrim(SA6->A6_AGENCIA)+"/"+Alltrim(SA6->A6_NUMCON)+"-"+alltrim(SA6->A6_DVCTA)
				cNossoNum	:= Transform(Right(cNossoNum,9),"@R 99999999-9")
				aCB_RN_NN    := Ret_cBarra(Substr(cBanco, 1, 3) + "9"      ,; //Banco
				Substr(SA6->A6_AGENCIA, 1, 5)         ,;//Agencia
				Substr(SA6->A6_NUMCON , 1, 8)         ,;//Conta
				alltrim(SA6->A6_DVCTA)     ,;//Digito da Conta
				cCodCart /*SEE->EE_X_CART*/                       ,;//Carteira
				Alltrim(SE1->E1_NUM)                  ,;//Documento
				SE1->E1_VALOR                         ,;//Valor do Titulo
				SE1->E1_VENCTO                        ,;//Vencimento
				SEE->EE_CODEMP						,;//Convenio
				SE1->E1_IDCNAB                       ,;//Nosso Numero
				.F.									,;//Se tem desconto
				Space(Len(SE1->E1_PARCELA))           ,;//Parcela
				SA6->A6_AGENCIA)                      //Agencia Completa
			Endif
		Else
			aCB_RN_NN := {"", "", ""}
			cMsgMulta := ""
			cNossoNum:= ""
		Endif
	aBolText 		:= {"","","","","","",""}
	aBolText[1] := "*** VALORES EXPRESSOS EM REAIS ***"

	nTxPer	:= SE1->E1_PORCJUR
	nTxDesc	:= SE1->E1_DESCFIN
                        
//	cEndBenef := AllTrim(SM0->M0_ENDCOB) + " - " +AllTrim(SM0->M0_BAIRCOB) +" - "+ AllTrim(SM0->M0_CIDCOB)+"/"+SM0->M0_ESTCOB
	
	cEndBenef := GetEndFil( "01" )     
	
	cStr	:= AllTrim(Transform((SE1->E1_VALOR *(10/100)),"@E 9,999,999.99"))
	aBolText[2] := "Multa de R$ "+cStr+" após o vencimento"

	IF nTxPer > 0
		cStr	:= AllTrim(Transform((SE1->E1_VALOR *(nTxper/100)),"@E 9,999,999.99"))  //
		aBolText[3] := "Após o vencimento mora dia: R$ " + cStr
	EndIf

	nVlrJuros := 0.00

	aBolText[4] := "Sujeito a Protesto após 06 (Seis) dias do vencimento."
/*
	If nTxDesc > 0
		aBolText[2] := "   "
		cStr1	:= AllTrim(Transform((SE1->E1_VALOR * nTxDesc/100),"@E 9,999,999.99"))
		aBolText[4] := "ATE O VENCIMENTO DESCONTO DE R$ " + cStr1
	Endif*/
	nVlrDesc := 0
	If (SE1->E1_DESCFIN <> 0)
		nVlrDesc := Round((SE1->E1_VALOR * SE1->E1_DESCFIN)/100,2)
		cData := SE1->E1_VENCTO - SE1->E1_DIADESC
		cData := DtoS( cData )
		cData = Substr( cData, 7, 2 ) + '/' + Substr( cData, 5, 2 ) + '/' + Substr( cData, 1, 4 )
		aBolText[5] := "Até " + cData + " conceder desconto de R$ " + AllTrim(TRANSFORM(nVlrDesc,"@E 999,999.99")) +"."
	Else
		aBolText[5] := ""
	EndIf


		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Inicio do desenho do boleto                                    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oPrint:StartPage()   // Inicia uma nova página

		nParc := GetParcela(SE4->E4_CODIGO)

		cTamGrid := "-4"
	    nSalto  := 20
	    nTamLin := 20

	    nCol  := 020
	    nColA := 270
	    nColB := 370
	    nCOlC := 410
		nColD := 455
		nColE := 540
		nSpacT:= 4
		nLinT := 6
		nLinC := 16
		nLinW := 20
		nLinAlign := 6
        nSubl := 0.5
        
		nPadL := 17
                          
		If nModel == 1
           
			// Inicio do Boleto
		    nLine := 010
		    
			// Parte 1
			oPrint:SayBitmap(nLine+18, nCol, "banco"+SE1->E1_PORTADO+".png",100,20)
	
			nLine += nSalto
			//  Agencia - Linha Digitável
			oPrint:Box(nLine  ,  nCol + 150 ,  nLine+nTamLin, nCol + 150 , cTamGrid)
			oPrint:Box(nLine  ,  nCol + 190 ,  nLine+nTamLin, nCol + 190 , cTamGrid)
	

			oPrint:Say(nLine + nLinC ,nCol + 150 + nSpacT, cBanco + "-" + DefineBanco(cBanco)           , oFont14N:oFont)
			oPrint:Say(nLine + nLinC ,nCol + nColD-4 + nSpacT,"Recibo do Pagador", oFont11n:oFont,,1)
		

			//  Local de Pagamento # Vencimento
			nLine += nSalto
			oPrint:Box(nLine  ,  nCol         ,  nLine+nTamLin, nCol + nColC , cTamGrid)
			// Linha Extra
			// oPrint:Box(nLine  ,  nCol         ,  nLine+nTamLin-nSubl-1, nCol + nColC , cTamGrid)
			
			// Box Logo Banco
			oPrint:Box(nLine  ,  nCol + nColC ,  nLine+(nTamLin*8), nCol + nColE , cTamGrid)
			oPrint:SayBitmap(nLine+30, nColC + 35, "banco"+SE1->E1_PORTADO+"_g.png",100,75)

			oPrint:Say(nLine + nLinT ,nCol + nSpacT	 	   , "Local de Pagamento"     , oFont09:oFont)
			oPrint:Say(nLine + nLinC ,nCol + nSpacT	 	   , cPagavel			     , oFont11N:oFont)

			// Cedente # Agencia Cedente
			nLine += nSalto
			oPrint:Box(nLine  ,  nCol         ,  nLine+nTamLin, nCol + nColC , cTamGrid)

			oPrint:Say(nLine + nLinT ,nCol + nSpacT	 	   , "Beneficiário"	      , oFont09:oFont)
			oPrint:Say(nLine + nLinT ,nCol + (nColC/4*3) -20 + nSpacT	, "CNPJ"			      , oFont09:oFont)
			oPrint:Say(nLine + nLinC ,nCol + nSpacT	 	   , cCedente   , oFont11N:oFont)
			oPrint:Say(nLine + nLinC ,nCol + (nColC/4*3) -20 + nSpacT	, TransForm(SM0->M0_CGC, "@R 99.999.999/9999-99")  				      , oFont11N:oFont) 

			// End Cedente 
			nLine += nSalto
			oPrint:Box(nLine  ,  nCol         ,  nLine+nTamLin, nCol + nColC , cTamGrid)
			oPrint:Say(nLine + nLinT ,nCol + nSpacT	 	   , "Endereço do Beneficiário"	      , oFont09:oFont)
			oPrint:Say(nLine + nLinC ,nCol + nSpacT	 	   , cEndBenef     , oFont11N:oFont)

			// Data Docto # Num Docto # Especie # Aceite # Data Processam # Nosso Numero
			nLine += nSalto
			oPrint:Box(nLine  ,  nCol         ,  nLine+nTamLin, nCol + (nColC/4) , cTamGrid)
			oPrint:Box(nLine  ,  nCol + (nColC/4) ,  nLine+nTamLin, nCol + (nColC/4*2)+20 , cTamGrid)
			oPrint:Box(nLine  ,  nCol + (nColC/4*2) +20,  nLine+nTamLin, nCol + (nColC/4*3)-20 , cTamGrid)
			oPrint:Box(nLine  ,  nCol + (nColC/4*3) -20,  nLine+nTamLin, nCol + nColC - 80 , cTamGrid)
			oPrint:Box(nLine  ,  nCol + nColC - 80 ,  nLine+nTamLin, nCol + nColC , cTamGrid)
	
			oPrint:Say(nLine + nLinT ,nCol + nSpacT	 	   				, "Data do documento"     , oFont09:oFont)
			oPrint:Say(nLine + nLinT ,nCol + (nColC/4) + nSpacT	 	   	, "Nº documento"	      , oFont09:oFont)
			oPrint:Say(nLine + nLinT ,nCol + (nColC/4*2) +20 + nSpacT	, "Espécie doc."		  , oFont09:oFont)
			oPrint:Say(nLine + nLinT ,nCol + (nColC/4*3) -20 + nSpacT	, "Aceite"			      , oFont09:oFont)
			oPrint:Say(nLine + nLinT ,nCol + nColC - 80 + nSpacT	 	, "Data processamento"	  , oFont09:oFont)
	
			oPrint:Say(nLine + nLinC ,nCol + nSpacT	 	   				, Ano4Dig(SE1->E1_EMISSAO), oFont11N:oFont)
			oPrint:Say(nLine + nLinC ,nCol + (nColC/4) + nSpacT	 	   	, cNumDocto /*aDadosTit[6]*/  		  , oFont11N:oFont)
			oPrint:Say(nLine + nLinC ,nCol + (nColC/4*2) +20 + nSpacT	, "DM"					  , oFont11N:oFont)
			oPrint:Say(nLine + nLinC ,nCol + (nColC/4*3) -20 + nSpacT	, "N"				      , oFont11N:oFont)
			oPrint:Say(nLine + nLinC ,nCol + nColC - 80 + nSpacT	 	, Ano4Dig(dDataBase)	  , oFont11N:oFont)
	
			// Uso Banco # Carteira # Especie #Quant # Valor # Valor
			nLine += nSalto
	
			If cBanco $ "033"
				oPrint:Box(nLine  ,  nCol         ,  nLine+nTamLin, nCol + (nColC/4)+70 , cTamGrid)
				oPrint:Box(nLine  ,  nCol + (nColC/4) +70,  nLine+nTamLin, nCol + (nColC/4*3)-50 , cTamGrid)
				oPrint:Box(nLine  ,  nCol + (nColC/4*3)-50 ,  nLine+nTamLin, nCol + (nColC/4*3)+20 , cTamGrid)
				oPrint:Box(nLine  ,  nCol + (nColC/4*3)+20 ,  nLine+nTamLin, nCol + nColC , cTamGrid)
	
				oPrint:Say(nLine + nLinT ,nCol + nSpacT	 	   					, "Carteira"		, oFont09:oFont)
				oPrint:Say(nLine + nLinT ,nCol + (nColC/4) +70 + nSpacT	   		, "Espécie"   		  	, oFont09:oFont)
				oPrint:Say(nLine + nLinT ,nCol + (nColC/4*3)-50 + nSpacT		, "Quantidade"	    	, oFont09:oFont)
				oPrint:Say(nLine + nLinT ,nCol + (nColC/4*3)+20 + nSpacT		, "Valor documento"     , oFont09:oFont)
	
				oPrint:Say(nLine + nLinC ,nCol + nSpacT	 	   				, cDescCart					, oFont11N:oFont)
				oPrint:Say(nLine + nLinC ,nCol + (nColC/4) +70 + nSpacT	 	, "R$"		   		  	, oFont11N:oFont)
				oPrint:Say(nLine + nLinC ,nCol + (nColC/4*3)-50 + nSpacT	, "001"			    	, oFont11N:oFont)
				oPrint:Say(nLine + nLinC ,nCol + (nColC/4*3)+20 + nSpacT	, Alltrim(Transform(SE1->E1_VALOR, "@E 999,999,999.99"))     , oFont11N:oFont)
			Else
				oPrint:Box(nLine  ,  nCol         			,  nLine+nTamLin, nCol + (nColC/4) - 30 , cTamGrid)
				oPrint:Box(nLine  ,  nCol + (nColC/4) - 30  ,  nLine+nTamLin, nCol + (nColC/4) , cTamGrid)
				oPrint:Box(nLine  ,  nCol + (nColC/4) 		,  nLine+nTamLin, nCol + (nColC/4)+70 , cTamGrid)
				oPrint:Box(nLine  ,  nCol + (nColC/4) +70	,  nLine+nTamLin, nCol + (nColC/4*3)-50 , cTamGrid)
				oPrint:Box(nLine  ,  nCol + (nColC/4*3)-50	,  nLine+nTamLin, nCol + nColC - 80 , cTamGrid)
				oPrint:Box(nLine  ,  nCol + nColC - 80 		,  nLine+nTamLin, nCol + nColC , cTamGrid)
	
				oPrint:Say(nLine + nLinT ,nCol + nSpacT	 	   					, "Uso do banco"		, oFont09:oFont)
				oPrint:Say(nLine + nLinT ,nCol + (nColC/4) - 30 + nSpacT		, "Cip"					, oFont09:oFont)
				oPrint:Say(nLine + nLinT ,nCol + (nColC/4) + nSpacT	 	  	 	, "Carteira"	    	, oFont09:oFont)
				oPrint:Say(nLine + nLinT ,nCol + (nColC/4) +70 + nSpacT	   		, "Espécie"   		  	, oFont09:oFont)
				oPrint:Say(nLine + nLinT ,nCol + (nColC/4*3)-50 + nSpacT		, "Quantidade"	    	, oFont09:oFont)
				oPrint:Say(nLine + nLinT ,nCol + (nColC/4*3)+20 + nSpacT		, "Valor documento"     , oFont09:oFont)
	
				oPrint:Say(nLine + nLinC ,nCol + nSpacT	 	   				, cUsoBco				, oFont11N:oFont)
				oPrint:Say(nLine + nLinC ,nCol + (nColC/4) - 30 + nSpacT	, "000"					, oFont11N:oFont)
				oPrint:Say(nLine + nLinC ,nCol + (nColC/4) + nSpacT	 	   	, cDescCart		    	, oFont11N:oFont)
				oPrint:Say(nLine + nLinC ,nCol + (nColC/4) +70 + nSpacT	 	, "R$"		   		  	, oFont11N:oFont)
				oPrint:Say(nLine + nLinC ,nCol + (nColC/4*3)-50 + nSpacT	, cQtBco			    	, oFont11N:oFont)
				oPrint:Say(nLine + nLinC ,nCol + (nColC/4*3)+20 + nSpacT	, Alltrim(Transform(SE1->E1_VALOR, "@E 999,999,999.99"))     , oFont11N:oFont)
			EndIf

			// Instruções
			nLine += nSalto
			oPrint:Box(nLine  ,  nCol         ,  nLine+(nTamLin*13), nCol + nColC , cTamGrid)
	
			oPrint:Say(nLine + nLinT ,nCol + nSpacT	 	, "Instruções: (Texto de responsabilidade do Beneficiário)"		, oFont09:oFont)

			oPrint:Say(nLine + nLinW 	  			,nCol + nSpacT  , aBolText[01]		, oFont11N:oFont)
			oPrint:Say(nLine + nLinW+(nLinW/2)     	,nCol + nSpacT	, aBolText[02]		, oFont11N:oFont)
			oPrint:Say(nLine + (nLinW*2)           	,nCol + nSpacT	, aBolText[03]		, oFont11N:oFont)
			oPrint:Say(nLine + (nLinW*2)+(nLinW/2) 	,nCol + nSpacT	, aBolText[04]		, oFont11N:oFont)
			oPrint:Say(nLine + (nLinW*2)+(nLinW)   	,nCol + nSpacT	, aBolText[05]		, oFont11N:oFont)
			oPrint:Say(nLine + (nLinW*3)+(nLinW/2) 	,nCol + nSpacT	, aBolText[06]		, oFont11N:oFont)
		
			nLine += nSalto
			nLine += nSalto
//			nLine += nSalto
	
	
			nLine += nSalto
			oPrint:Box(nLine  ,  nCol + nColC ,  nLine+nTamLin, nCol + nColE , cTamGrid)
			// Box Cinza
			oPrint:FillRect({nLine,nCol + nColC,nLine+nTamLin, nCol + nColE},oBrush)
			
			oPrint:Say(nLine + nLinT ,nCol + nColC + nSpacT, "Vencimento"             , oFont09:oFont)
//			oPrint:SayAlign(nLine + nLinT ,nCol + nColC + nSpacT	, Ano4Dig(SE1->E1_VENCTO)       , oFont11b:oFont,120,0,2,1)
			oPrint:Say(nLine + nLinC ,nCol + nColC + nSpacT	, PadL(Ano4Dig(SE1->E1_VENCTO),nPadL)       , oFont11b:oFont)
	
			nLine += nSalto
			oPrint:Box(nLine  ,  nCol + nColC ,  nLine+nTamLin, nCol + nColE , cTamGrid)
			oPrint:Say(nLine + nLinT ,nCol + nColC + nSpacT, "Agência/Código Beneficiário" , oFont09:oFont)
//			oPrint:SayAlign(nLine + nLinT ,nCol + nColC + nSpacT	, cAgCed        , oFont11b:oFont,120,0,2,1)
			oPrint:Say(nLine + nLinC ,nCol + nColC + nSpacT	, PadL(cAgCed,nPadL)        , oFont11b:oFont)
	
			nLine += nSalto
			oPrint:Box(nLine  ,  nCol + nColC ,  nLine+nTamLin, nCol + nColE , cTamGrid)
			oPrint:Say(nLine + nLinT ,nCol + nColC+ nSpacT	 	   		, "Nosso número"		  , oFont09:oFont)
//			oPrint:SayAlign(nLine + nLinT ,nCol + nColC + nSpacT  		, cNossoNum      		  , oFont11b:oFont,120,0,2,1)
			oPrint:Say(nLine + nLinC ,nCol + nColC + nSpacT  		, PadL(cNossoNum,nPadL)      		  , oFont11b:oFont)

	
			nLine += nSalto
			oPrint:Box(nLine  ,  nCol + nColC ,  nLine+nTamLin, nCol + nColE , cTamGrid) 
			// Box Cinza
			oPrint:FillRect({nLine,nCol + nColC,nLine+nTamLin, nCol + nColE},oBrush)
						
			oPrint:Say(nLine + nLinT ,nCol + nColC + nSpacT	 	   	  		, "1 (=) Valor documento" , oFont09:oFont)
//			oPrint:SayAlign(nLine + nLinT ,nCol + nColC + nSpacT	, Alltrim(Transform(SE1->E1_VALOR, "@E 999,999,999.99"))       , oFont11b:oFont,120,0,2,1)
			oPrint:Say(nLine + nLinC ,nCol + nColC + nSpacT	, PadL(Alltrim(Transform(SE1->E1_VALOR, "@E 999,999,999.99")),nPadL)       , oFont11b:oFont)
	
			nLine += nSalto
			oPrint:Box(nLine  ,  nCol + nColC ,  nLine+nTamLin, nCol + nColE , cTamGrid)
			oPrint:Say(nLine + nLinT ,nCol + nColC + nSpacT	 	   		, "2 (-) Desconto / Abatimentos" , oFont09:oFont)
	
			nLine += nSalto
			oPrint:Box(nLine  ,  nCol + nColC ,  nLine+nTamLin, nCol + nColE , cTamGrid)
			oPrint:Say(nLine + nLinT ,nCol + nColC + nSpacT	 	   		, "3 (-) Outras Deduções" , oFont09:oFont)
	
			nLine += nSalto
			oPrint:Box(nLine  ,  nCol + nColC ,  nLine+nTamLin, nCol + nColE , cTamGrid)
			oPrint:Say(nLine + nLinT ,nCol + nColC + nSpacT	 	   		, "4 (+) Mora / Multa" , oFont09:oFont)
	
			nLine += nSalto
			oPrint:Box(nLine  ,  nCol + nColC ,  nLine+nTamLin, nCol + nColE , cTamGrid)
			oPrint:Say(nLine + nLinT ,nCol + nColC + nSpacT	 	   		, "5 (+) Outros Acréscimos" , oFont09:oFont)
	
			nLine += nSalto
			oPrint:Box(nLine  ,  nCol + nColC ,  nLine+nTamLin, nCol + nColE , cTamGrid)
			oPrint:Say(nLine + nLinT ,nCol + nColC + nSpacT	 	   		, "6 (=) Valor Cobrado" , oFont09:oFont)
	
	
			// Rodape
			nLine += nSalto
			oPrint:Box(nLine  ,  nCol         ,  nLine+(nTamLin*2), nCol + nColE , cTamGrid)
			// Linha Extra
			// oPrint:Box(nLine  + nSubl ,  nCol         ,  nLine+(nTamLin*2), nCol + nColE , cTamGrid)

			oPrint:Say(nLine + nLinT+ nSubl,nCol + nSpacT	 	 		, "Pagador:"    , oFont09:oFont)
	
			oPrint:Say(nLine + nLinC ,nCol + nSpacT + 26	 	 	, AllTrim(aDatSacado[1]) +" - CNPJ : " + TransForm(AllTrim(aDatSacado[9]),"@R 99.999.999/9999-99")      , oFont11N:oFont)
			oPrint:Say(nLine + (nLinC+(nLinC/2)) ,nCol + nSpacT	+ 26, AllTrim(aDatSacado[4])  +" - " + AllTrim(aDatSacado[8])    , oFont11N:oFont)
			oPrint:Say(nLine + (nLinC*2) ,nCol + nSpacT	 + 26  		, "CEP " +TransForm(AllTrim(aDatSacado[7]),"@R 99999-999") + " - " + AllTrim(aDatSacado[5])  +" / " + AllTrim(aDatSacado[6]) , oFont11N:oFont)
	
	
			oPrint:SayBitmap(nLine+10, nCol + nColD + 18, "iso9001.png",65,20)
	
			nLine += nSalto
			nLine += nSalto
	
			oPrint:Say(nLine - 2 ,nCol + nColC - 50 + nSpacT, "Papeleta processada e impressa pelo Beneficiário."   , oFont09:oFont)
	
			oPrint:Say(nLine + nLinT + nSubl,nCol + nSpacT				, "Sacador/Avalista"    , oFont09:oFont)
			oPrint:Say(nLine + nLinT + nSubl,nCol + nColC - 50 + nSpacT	, "Autenticação mecânica"   , oFont09:oFont)
	


		ElseIf nModel == 2
			// Inicio do Recibo
		    nLine := 020
	
			cMsgCab1 := "> Imprima em impressora jato de tinta (inkjet) ou laser em qualidade normal ou alta (Não use modo econômico)."
			cMsgCab2 := "> Utilize folha A4 (210 x 279 mm) e margens mínimas à esquerda e à direita do formulário."
			cMsgCab3 := "> Corte na linha indicada. Não rasure, rique, fure ou dobre a região onde se encontra o código de barras."
			cMsgCab4 := "> Caso tenha problema para imprimir, copie a linha digitável acima e utilize para pagamento no caixa eletrônico ou internet banking."
	
			oPrint:SayBitmap(nLine+18, nCol, "ourolux_bol.png",130,25)
			nLine += nSalto
	
			oPrint:SayAlign( nLine,nCol,"Agência / Código Beneficiário",oFont11n:oFont,600, 200, CLR_HRED, 2, 0 )
			nLine += nSalto/2
			oPrint:SayAlign( nLine,nCol,cAgCed,oFont11n:oFont,600, 200, CLR_HRED, 2, 0 )
	
			nLine += nSalto
	
			oPrint:Box(nLine  ,  nCol         ,  nLine+nTamLin, nCol + nColB , cTamGrid)
			oPrint:Box(nLine  ,  nCol + nColB ,  nLine+nTamLin, nCol + nColD , cTamGrid)
			oPrint:Box(nLine  ,  nCol + nColD ,  nLine+nTamLin, nCol + nColE , cTamGrid)
	
			// Cabeçalho
			oPrint:Say(nLine + nLinT ,nCol + nSpacT	 	   , "Pagador:"               , oFont09:oFont)
			oPrint:Say(nLine + nLinT ,nCol + nColB + nSpacT, "Número do Documento"  , oFont09:oFont)
			oPrint:Say(nLine + nLinT ,nCol + nColD + nSpacT, "Vencimento"           , oFont09:oFont)
			// Dados
			oPrint:Say(nLine + nLinC ,nCol + nSpacT		   , aDatSacado[1] 	   				, oFont11N:oFont)
			oPrint:Say(nLine + nLinC ,nCol + nColB + nSpacT, cNumDocto/*aDadosTit[6]*/				 	, oFont11N:oFont)
			oPrint:SayAlign(nLine + nLinT ,nCol + nColD + nSpacT, Ano4Dig(SE1->E1_VENCTO)   , oFont11N:oFont,070,0,2,1)
	
			nLine += nSalto + 1
	
			oPrint:Box(nLine  ,  nCol         ,  nLine+nTamLin, nCol + nColB , cTamGrid)
			oPrint:Box(nLine  ,  nCol + nColB ,  nLine+nTamLin, nCol + nColD , cTamGrid)
			oPrint:Box(nLine  ,  nCol + nColD ,  nLine+nTamLin, nCol + nColE , cTamGrid)
	
			oPrint:Say(nLine + nLinT ,nCol + nSpacT	 	   , "Linha Digitável"		           , oFont09:oFont)
			oPrint:Say(nLine + nLinT ,nCol + nColB + nSpacT, "Nosso número"         , oFont09:oFont)
			oPrint:Say(nLine + nLinT ,nCol + nColD + nSpacT, "Valor do Documento"   , oFont09:oFont)
			// Dados
			oPrint:Say(nLine + nLinC ,nCol + nSpacT		   , aCB_RN_NN[2]    	   				, oFont11N:oFont)
			oPrint:Say(nLine + nLinC ,nCol + nColB + nSpacT, cNossoNum     		        	, oFont11N:oFont)
			oPrint:SayAlign(nLine + nLinT ,nCol + nColD + nSpacT, Alltrim(Transform(SE1->E1_VALOR, "@E 999,999,999.99"))   , oFont11N:oFont,070,0,2,1)
	
	
	
	
			nLine += nSalto + 2
			oPrint:Box(nLine  ,  nCol         ,  nLine+(nTamLin*3), nCol + nColE , cTamGrid)
	
			oPrint:Say(nLine + nLinC ,nCol + nSpacT		   	,  "Cliente:"   	   				, oFont11N:oFont)
			oPrint:Say(nLine + nLinC ,nCol + 240 + nSpacT	,  "Telefone:"  	   				, oFont11N:oFont)
			oPrint:Say(nLine + nLinC ,nCol + 440 + nSpacT	,  "Código:"   	   				, oFont11N:oFont)
	
			oPrint:Say(nLine + nLinC ,nCol + nSpacT		   + 55	,  SA1->A1_NOME   				, oFont09:oFont)
			oPrint:Say(nLine + nLinC ,nCol + 240 + nSpacT + 55	,  SA1->A1_TEL	   				, oFont09:oFont)
			oPrint:Say(nLine + nLinC ,nCol + 440 + nSpacT + 55	,  SA1->A1_COD+"-"+SA1->A1_LOJA , oFont09:oFont)
	

			nLine += nSalto/2
			oPrint:Say(nLine + nLinC ,nCol + nSpacT		   	,  "Unidade:"   	   				, oFont11N:oFont)
			oPrint:Say(nLine + nLinC ,nCol + 240 + nSpacT	,  "Pagamento:"  	   				, oFont11N:oFont)
			oPrint:Say(nLine + nLinC ,nCol + 440 + nSpacT	,  "Emissão:"  	   				, oFont11N:oFont)
	
			oPrint:Say(nLine + nLinC ,nCol + nSpacT			+ 55   	,  SA1->A1_NREDUZ  				, oFont09:oFont)
			oPrint:Say(nLine + nLinC ,nCol + 240 + nSpacT	+ 55,  SE4->E4_COND     				, oFont09:oFont)
			oPrint:Say(nLine + nLinC ,nCol + 440 + nSpacT	+ 55	,  Ano4Dig(SE1->E1_EMISSAO)		, oFont09:oFont)
	
	
	
			nLine += nSalto/2
			oPrint:Say(nLine + nLinC ,nCol + nSpacT		   	,  "Entrega:"   	   				, oFont11N:oFont)
			oPrint:Say(nLine + nLinC ,nCol + 240 + nSpacT	,  "Vendedor:"   	   				, oFont11N:oFont)
			oPrint:Say(nLine + nLinC ,nCol + 440 + nSpacT	,  "CEP:"   	   						, oFont11N:oFont)
	
			oPrint:Say(nLine + nLinC ,nCol + nSpacT		  + 55 	,  SA1->A1_ENDENT   	   			, oFont09:oFont)
			oPrint:Say(nLine + nLinC ,nCol + 240 + nSpacT + 55	,  SA3->A3_NREDUZ 	   				, oFont09:oFont)
			oPrint:Say(nLine + nLinC ,nCol + 440 + nSpacT + 55	, TransForm(AllTrim(SA1->A1_CEPE),"@R 99999-999") 	   	 		 	, oFont09:oFont)
	
	
			nLine += nSalto/2
			oPrint:Say(nLine + nLinC ,nCol + nSpacT		  	,  "Bairro:"   	   				, oFont11N:oFont)
			oPrint:Say(nLine + nLinC ,nCol + 240 + nSpacT	,  "Cidade:"   	   				, oFont11N:oFont)
			oPrint:Say(nLine + nLinC ,nCol + 440 + nSpacT	,  "Estado:"   	   				, oFont11N:oFont)
	
			oPrint:Say(nLine + nLinC ,nCol + nSpacT		  + 55	,  SA1->A1_BAIRROE   				, oFont09:oFont)
			oPrint:Say(nLine + nLinC ,nCol + 240 + nSpacT + 55	,  SA1->A1_MUNE   	   				, oFont09:oFont)
			oPrint:Say(nLine + nLinC ,nCol + 440 + nSpacT + 55	,  SA1->A1_ESTE   	   				, oFont09:oFont)
	
	
			nLine += nSalto/2
			oPrint:Say(nLine + nLinC ,nCol + nSpacT		  	,  "Serie/Docto:"  		   				, oFont11N:oFont)
			oPrint:Say(nLine + nLinC ,nCol + 240 + nSpacT	,  ""			   	 					, oFont11N:oFont)
			oPrint:Say(nLine + nLinC ,nCol + 440 + nSpacT	,  "Parcela:"			   				, oFont11N:oFont)
		//	nLine += nSalto/2
	
			oPrint:Say(nLine + nLinC ,nCol + nSpacT		  + 55	, AllTrim(SE1->E1_SERIE)+"/"+Alltrim(SE1->E1_NUM) 	, oFont09:oFont)
			oPrint:Say(nLine + nLinC ,nCol + 240 + nSpacT + 55	,  ""			   	 					, oFont09:oFont)
			oPrint:Say(nLine + nLinC ,nCol + 440 + nSpacT + 55	,  StrZero(Max(Val(SE1->E1_PARCELA),1),2)+"/"+StrZero(nParc,2)	, oFont09:oFont)
	
	
			nLine += nSalto +2
			oPrint:Box(nLine  ,  nCol         ,  nLine+(nTamLin*2), nCol + nColE , cTamGrid)
	
	
			nLine += 2
			oPrint:Say(nLine + nLinT ,nCol + nSpacT		  	,  cMsgCab1   				, oFont09N:oFont)
			nLine += nSalto/2
			oPrint:Say(nLine + nLinT ,nCol + nSpacT		  	,  cMsgCab2   				, oFont09N:oFont)
			nLine += nSalto/2
			oPrint:Say(nLine + nLinT ,nCol + nSpacT		  	,  cMsgCab3   				, oFont09N:oFont)
			nLine += nSalto/2
			oPrint:Say(nLine + nLinT ,nCol + nSpacT		  	,  cMsgCab4   				, oFont09N:oFont)
			nLine += nSalto/2
	
	
			nLine += nSalto
	
		//  Pontilhado
			oPrint:Say(nLine + nLinC,nCol + nColC + nSpacT,"Assinatura Autorizada", oFont11n:oFont,,1)
			nLine += nSalto
		 	oPrint:Line(nLine, nCol, nLine, nCol + nColE, 0, cTamGrid )
	
			nLine += nSalto
	
	
			oPrint:Say(nLine + nLinT ,nCol + nColD-4 + nSpacT	 	, "Corte na linha pontilhada"   , oFont07:oFont)
			nLine += (nSalto / 2)
		   	oPrint:Say(nLine,nCol,Replicate("_ ",76), oFont11n:oFont,,1)
	
	
	
	
			// Inicio do Boleto
		    nLine := 320
			// Parte 1
		 	oPrint:Line(nLine, nCol, nLine, nCol + nColE, 0, cTamGrid )
			oPrint:Say(nLine+ nLinT + 4,nCol + nColD-4 + nSpacT,"Recibo do Pagador", oFont11n:oFont,,1)
	
			oPrint:SayBitmap(nLine+18, nCol, "banco"+SE1->E1_PORTADO+".png",100,20)

	
			nLine += nSalto
		//  Agencia - Linha Digitável
			oPrint:Box(nLine  ,  nCol + 150 ,  nLine+nTamLin, nCol + 150 , cTamGrid)
			oPrint:Box(nLine  ,  nCol + 190 ,  nLine+nTamLin, nCol + 190 , cTamGrid)
	
			oPrint:Say(nLine + nLinC ,nCol + 150 + nSpacT, cBanco + "-" + DefineBanco(cBanco)           , oFont14N:oFont)
			oPrint:Say(nLine + nLinC ,nCol + 190 + nSpacT + 10, aCB_RN_NN[2]  , oFont14N:oFont)
	
		// Cedente # Agencia Cedente # Especie # Quantidade # Nosso Numero
			nLine += nSalto
			oPrint:Box(nLine  ,  nCol         ,  nLine+nTamLin, nCol + nColA , cTamGrid)
			oPrint:Box(nLine  ,  nCol + nColA ,  nLine+nTamLin, nCol + nColB , cTamGrid)
			oPrint:Box(nLine  ,  nCol + nColB ,  nLine+nTamLin, nCol + nColC , cTamGrid)
			oPrint:Box(nLine  ,  nCol + nColC ,  nLine+nTamLin, nCol + nColD , cTamGrid)
			oPrint:Box(nLine  ,  nCol + nColD ,  nLine+nTamLin, nCol + nColE , cTamGrid)
	
			// Cabeçalho
			oPrint:Say(nLine + nLinT ,nCol + nSpacT	 	   , "Beneficiário"                , oFont09:oFont)
			oPrint:Say(nLine + nLinT ,nCol + nColA + nSpacT, "Agência/Código Beneficiário" , oFont09:oFont)
			oPrint:Say(nLine + nLinT ,nCol + nColB + nSpacT, "Espécie"                , oFont09:oFont)
			oPrint:Say(nLine + nLinT ,nCol + nColC + nSpacT, "Quantidade"             , oFont09:oFont)
			oPrint:Say(nLine + nLinT ,nCol + nColD + nSpacT, "Nosso número"           , oFont09:oFont)
			// Dados
			oPrint:Say(nLine + nLinC ,nCol + nSpacT		   , cCedente    	   		, oFont11N:oFont)
			oPrint:Say(nLine + nLinC ,nCol + nColA + nSpacT, cAgCed         	   	, oFont11N:oFont)
			oPrint:Say(nLine + nLinC ,nCol + nColB + nSpacT, "R$"                	, oFont11N:oFont)
			oPrint:Say(nLine + nLinC ,nCol + nColC + nSpacT, "001"          		, oFont11N:oFont)
			//	oPrint:Say(nLine + nLinC ,nCol + nColD + nSpacT, cNossoNum           	, oFont11N:oFont)
			oPrint:SayAlign(nLine + nLinT ,nCol + nColD + nSpacT	, cNossoNum     , oFont11N:oFont,075,0,2,1)
	
	
			//	oPrint:Say(oPrint,nLine + nSpacT ,nCol + nColB + nSpacT, 1960, "Vencimento"                , oFont10:oFont)
	
			// Numero Docto # CNPJ  # Vencimento # Valor
			nLine += nSalto
			oPrint:Box(nLine  ,  nCol 		  ,  nLine+nTamLin, nCol + nColA - 90, cTamGrid)
			oPrint:Box(nLine  ,  nCol + nColA - 90 ,  nLine+nTamLin, nCol + nColA +30 , cTamGrid)
			oPrint:Box(nLine  ,  nCol + nColA + 30 ,  nLine+nTamLin, nCol + nColC , cTamGrid)
			oPrint:Box(nLine  ,  nCol + nColC ,  nLine+nTamLin, nCol + nColE , cTamGrid)
			// Box Cinza
			oPrint:FillRect({nLine,nCol + nColC,nLine+nTamLin, nCol + nColE},oBrush)
	
			oPrint:Say(nLine + nLinT ,nCol + nSpacT	 	 		, "Numero do Documento"    , oFont09:oFont)
			oPrint:Say(nLine + nLinT ,nCol + nColA - 90 + nSpacT, "CPF/CNPJ"               , oFont09:oFont)
			oPrint:Say(nLine + nLinT ,nCol + nColA + 30 + nSpacT, "Vencimento"             , oFont09:oFont)
			oPrint:Say(nLine + nLinT ,nCol + nColC + nSpacT		, "Valor Documento"        , oFont09:oFont)
	
			oPrint:Say(nLine + nLinC ,nCol + nSpacT	 	  		, cNumDocto/*aDadosTit[6]*/			    , oFont11N:oFont)
			oPrint:Say(nLine + nLinC ,nCol + nColA - 90 + nSpacT, TransForm(SM0->M0_CGC, "@R 99.999.999/9999-99")               , oFont11N:oFont)
			oPrint:Say(nLine + nLinC ,nCol + nColA + 30 + nSpacT, Ano4Dig(SE1->E1_VENCTO)             , oFont11N:oFont)
			oPrint:SayAlign(nLine + nLinT ,nCol + nColC + nSpacT	, Alltrim(Transform(SE1->E1_VALOR, "@E 999,999,999.99"))       , oFont11N:oFont,120,0,2,1)
	
	
			// Desconto # Deduções # Multa # Acrescimos # Valor cobrado
			nLine += nSalto
			oPrint:Box(nLine  ,  nCol         ,  nLine+nTamLin, nCol + (nColC/4) , cTamGrid)
			oPrint:Box(nLine  ,  nCol + (nColC/4) ,  nLine+nTamLin, nCol + (nColC/4*2) , cTamGrid)
			oPrint:Box(nLine  ,  nCol + (nColC/4*2) ,  nLine+nTamLin, nCol + (nColC/4*3) , cTamGrid)
			oPrint:Box(nLine  ,  nCol + (nColC/4*3) ,  nLine+nTamLin, nCol + nColC , cTamGrid)
			oPrint:Box(nLine  ,  nCol + nColC ,  nLine+nTamLin, nCol + nColE , cTamGrid)
	
			oPrint:Say(nLine + nLinT ,nCol + nSpacT	 	 		, "(-) Desconto / Abatimentos"    , oFont09:oFont)
			oPrint:Say(nLine + nLinT ,nCol + (nColC/4) + nSpacT, "(-) Outras Deduções"               , oFont09:oFont)
			oPrint:Say(nLine + nLinT ,nCol + (nColC/4*2) + nSpacT, "(+) Mora / Multa"             , oFont09:oFont)
			oPrint:Say(nLine + nLinT ,nCol + (nColC/4*3) + nSpacT     , "(+) Outros Acréscimos"        , oFont09:oFont)
			oPrint:Say(nLine + nLinT ,nCol + nColC + nSpacT     , "(=) Valor Cobrado"        , oFont09:oFont)
	
			// Sacado
			nLine += nSalto
			oPrint:Box(nLine  ,  nCol         ,  nLine+nTamLin, nCol + nColE , cTamGrid)
			oPrint:Say(nLine + nLinT ,nCol + nSpacT	 	 		, "Pagador:"    , oFont09:oFont)
			oPrint:Say(nLine + nLinC ,nCol + nSpacT	 	 		, AllTrim(aDatSacado[1]) +" - " + TransForm(AllTrim(aDatSacado[9]),"@R 99.999.999/9999-99")    , oFont11N:oFont)
	
			nLine += nSalto
			oPrint:Say(nLine + nLinT ,nCol + nSpacT	 	 		, "Demonstrativo"    		, oFont09:oFont)
			oPrint:Say(nLine + nLinT ,nCol + nColD + nSpacT	 	, "Autenticação mecânica"   , oFont09:oFont)
	                                                                            
			nLine += nSalto
			nLine += nSalto
			nLine += nSalto
	
        EndIf


		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Parte 2                     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
		nLine := 500 //500

	    // Linha Pontilhada
		oPrint:Say(nLine + nLinT ,nCol + nColD-4 + nSpacT	 	, "Corte na linha pontilhada"   , oFont07:oFont)
		nLine += (nSalto / 2)
	   	oPrint:Say(nLine,nCol,Replicate("_ ",86), oFont11n:oFont,,1)

		//  Logo	
		oPrint:SayBitmap(nLine+18, nCol, "banco"+SE1->E1_PORTADO+".png",100,20)


		//  Agencia - Linha Digitável
		nLine += nSalto
		oPrint:Box(nLine  ,  nCol + 150 ,  nLine+nTamLin, nCol + 150 , cTamGrid)
		oPrint:Box(nLine  ,  nCol + 190 ,  nLine+nTamLin, nCol + 190 , cTamGrid)

		oPrint:Say(nLine + nLinC ,nCol + 150 + nSpacT, cBanco + "-" + DefineBanco(cBanco)          , oFont14N:oFont)
		oPrint:Say(nLine + nLinC ,nCol + 190 + nSpacT + 10,aCB_RN_NN[2] , oFont14N:oFont)

		//  Local de Pagamento # Vencimento
		nLine += nSalto
		oPrint:Box(nLine  ,  nCol         ,  nLine+nTamLin, nCol + nColC , cTamGrid)
		oPrint:Box(nLine  ,  nCol + nColC ,  nLine+nTamLin, nCol + nColE , cTamGrid)
		// Box Cinza
		oPrint:FillRect({nLine,nCol + nColC,nLine+nTamLin, nCol + nColE},oBrush)

		oPrint:Say(nLine + nLinT ,nCol + nSpacT	 	   , "Local de Pagamento"     , oFont09:oFont)
		oPrint:Say(nLine + nLinT ,nCol + nColC + nSpacT, "Vencimento"             , oFont09:oFont)

		oPrint:Say(nLine + nLinC ,nCol + nSpacT	 	   , cPagavel			     , oFont11N:oFont)
		oPrint:Say(nLine + nLinC ,nCol + nColC + nSpacT	, PadL(Ano4Dig(SE1->E1_VENCTO),nPadL)       , oFont11b:oFont)


		// Cedente # Agencia Cedente
		nLine += nSalto
		oPrint:Box(nLine  ,  nCol         ,  nLine+nTamLin, nCol + nColC , cTamGrid)
		oPrint:Box(nLine  ,  nCol + nColC ,  nLine+nTamLin, nCol + nColE , cTamGrid)


		oPrint:Say(nLine + nLinT ,nCol + nSpacT	 	   , "Beneficiário"	      , oFont09:oFont)
		oPrint:Say(nLine + nLinT ,nCol + (nColC/4*3) -20 + nSpacT	, "CNPJ"			      , oFont09:oFont)


		oPrint:Say(nLine + nLinT ,nCol + nColC + nSpacT, "Agência/Código Beneficiário" , oFont09:oFont)

		oPrint:Say(nLine + nLinC ,nCol + nSpacT	 	   , cCedente   , oFont11N:oFont)
		oPrint:Say(nLine + nLinC ,nCol + (nColC/4*3) -20 + nSpacT	, TransForm(SM0->M0_CGC, "@R 99.999.999/9999-99")  				      , oFont11N:oFont) 

		oPrint:Say(nLine + nLinC ,nCol + nColC + nSpacT	, PadL(cAgCed,nPadL)        , oFont11b:oFont)



		// End Cedente 
		nLine += nSalto
		oPrint:Box(nLine  ,  nCol         ,  nLine+nTamLin, nCol + nColC , cTamGrid)
		oPrint:Say(nLine + nLinT ,nCol + nSpacT	 	   , "Endereço do Beneficiário"	      , oFont09:oFont)
		oPrint:Say(nLine + nLinC ,nCol + nSpacT	 	   , cEndBenef     , oFont11N:oFont)

		oPrint:Box(nLine  ,  nCol + nColC ,  nLine+nTamLin, nCol + nColE , cTamGrid)
		oPrint:Say(nLine + nLinT ,nCol + nColC+ nSpacT	 	   		, "Nosso número"		  , oFont09:oFont)
		oPrint:Say(nLine + nLinC ,nCol + nColC + nSpacT  		, PadL(cNossoNum,nPadL)      		  , oFont11b:oFont)

//		oPrint:Box(nLine  ,  nCol + nColC ,  nLine+nTamLin, nCol + nColE , cTamGrid)
//		oPrint:Say(nLine + nLinT ,nCol + nColC + nSpacT	 	   		, "2 (-) Desconto / Abatimentos" , oFont09:oFont)
                                                                         


		// Data Docto # Num Docto # Especie # Aceite # Data Processam # Nosso Numero
		nLine += nSalto
		oPrint:Box(nLine  ,  nCol         ,  nLine+nTamLin, nCol + (nColC/4) , cTamGrid)
		oPrint:Box(nLine  ,  nCol + (nColC/4) ,  nLine+nTamLin, nCol + (nColC/4*2)+20 , cTamGrid)
		oPrint:Box(nLine  ,  nCol + (nColC/4*2) +20,  nLine+nTamLin, nCol + (nColC/4*3)-20 , cTamGrid)
		oPrint:Box(nLine  ,  nCol + (nColC/4*3) -20,  nLine+nTamLin, nCol + nColC - 80 , cTamGrid)
		oPrint:Box(nLine  ,  nCol + nColC - 80 ,  nLine+nTamLin, nCol + nColC , cTamGrid)
//		oPrint:Box(nLine  ,  nCol + nColC ,  nLine+nTamLin, nCol + nColE , cTamGrid)
		oPrint:FillRect({nLine,nCol + nColC,nLine+nTamLin, nCol + nColE},oBrush)
  

		oPrint:Say(nLine + nLinT ,nCol + nSpacT	 	   				, "Data do documento"     , oFont09:oFont)
		oPrint:Say(nLine + nLinT ,nCol + (nColC/4) + nSpacT	 	   	, "Nº documento"	      , oFont09:oFont)
		oPrint:Say(nLine + nLinT ,nCol + (nColC/4*2) +20 + nSpacT	, "Espécie doc."		  , oFont09:oFont)
		oPrint:Say(nLine + nLinT ,nCol + (nColC/4*3) -20 + nSpacT	, "Aceite"			      , oFont09:oFont)
		oPrint:Say(nLine + nLinT ,nCol + nColC - 80 + nSpacT	 	, "Data processamento"	  , oFont09:oFont)
//		oPrint:Say(nLine + nLinT ,nCol + nColC+ nSpacT	 	   		, "Nosso número"		  , oFont09:oFont)
		oPrint:Say(nLine + nLinT ,nCol + nColC + nSpacT	 	   	   		, "1 (=) Valor documento" , oFont09:oFont)

		oPrint:Say(nLine + nLinC ,nCol + nSpacT	 	   				, Ano4Dig(SE1->E1_EMISSAO), oFont11N:oFont)
		oPrint:Say(nLine + nLinC ,nCol + (nColC/4) + nSpacT	 	   	, cNumDocto/*aDadosTit[6]*/, oFont11N:oFont)
		oPrint:Say(nLine + nLinC ,nCol + (nColC/4*2) +20 + nSpacT	, "DM"					  , oFont11N:oFont)
		oPrint:Say(nLine + nLinC ,nCol + (nColC/4*3) -20 + nSpacT	, "N"				      , oFont11N:oFont)
		oPrint:Say(nLine + nLinC ,nCol + nColC - 80 + nSpacT	 	, Ano4Dig(dDataBase)	  , oFont11N:oFont)
 //		oPrint:Say(nLine + nLinC ,nCol + nColC + nSpacT  		, PadL(cNossoNum,nPadL)      		  , oFont11b:oFont)
		oPrint:Say(nLine + nLinC ,nCol + nColC + nSpacT	, Padl(Alltrim(Transform(SE1->E1_VALOR, "@E 999,999,999.99")),nPadL)       , oFont11b:oFont)


		// Uso Banco # Carteira # Especie #Quant # Valor # Valor
		nLine += nSalto

		If cBanco $ "033"
			oPrint:Box(nLine  ,  nCol         ,  nLine+nTamLin, nCol + (nColC/4)+70 , cTamGrid)
			oPrint:Box(nLine  ,  nCol + (nColC/4) +70,  nLine+nTamLin, nCol + (nColC/4*3)-50 , cTamGrid)
			oPrint:Box(nLine  ,  nCol + (nColC/4*3)-50 ,  nLine+nTamLin, nCol + (nColC/4*3)+20 , cTamGrid)
			oPrint:Box(nLine  ,  nCol + (nColC/4*3)+20 ,  nLine+nTamLin, nCol + nColC , cTamGrid)
			oPrint:Box(nLine  ,  nCol + nColC ,  nLine+nTamLin, nCol + nColE , cTamGrid)


			oPrint:Say(nLine + nLinT ,nCol + nSpacT	 	   					, "Carteira"		, oFont09:oFont)
			oPrint:Say(nLine + nLinT ,nCol + (nColC/4) +70 + nSpacT	   		, "Espécie"   		  	, oFont09:oFont)
			oPrint:Say(nLine + nLinT ,nCol + (nColC/4*3)-50 + nSpacT		, "Quantidade"	    	, oFont09:oFont)
			oPrint:Say(nLine + nLinT ,nCol + (nColC/4*3)+20 + nSpacT		, "Valor documento"     , oFont09:oFont)
			oPrint:Say(nLine + nLinT ,nCol + nColC + nSpacT	 	   	  		, "(=) Valor documento" , oFont09:oFont)


			oPrint:Say(nLine + nLinC ,nCol + nSpacT	 	   				, cDescCart					, oFont11N:oFont)
			oPrint:Say(nLine + nLinC ,nCol + (nColC/4) +70 + nSpacT	 	, "R$"		   		  	, oFont11N:oFont)
			oPrint:Say(nLine + nLinC ,nCol + (nColC/4*3)-50 + nSpacT	, "001"			    	, oFont11N:oFont)
			oPrint:Say(nLine + nLinC ,nCol + (nColC/4*3)+20 + nSpacT	, Alltrim(Transform(SE1->E1_VALOR, "@E 999,999,999.99"))     , oFont11N:oFont)
			oPrint:SayAlign(nLine + nLinT ,nCol + nColC + nSpacT	, Alltrim(Transform(SE1->E1_VALOR, "@E 999,999,999.99"))       , oFont11N:oFont,120,0,2,1)
		Else

			oPrint:Box(nLine  ,  nCol         			,  nLine+nTamLin, nCol + (nColC/4) - 30 , cTamGrid)
			oPrint:Box(nLine  ,  nCol + (nColC/4) - 30  ,  nLine+nTamLin, nCol + (nColC/4) , cTamGrid)
			oPrint:Box(nLine  ,  nCol + (nColC/4) +70	,  nLine+nTamLin, nCol + (nColC/4*3)-50 , cTamGrid)
			oPrint:Box(nLine  ,  nCol + (nColC/4*3)-50 	,  nLine+nTamLin, nCol + (nColC/4*3)+20 , cTamGrid)
			oPrint:Box(nLine  ,  nCol + (nColC/4*3)+20 	,  nLine+nTamLin, nCol + nColC , cTamGrid)
			oPrint:Box(nLine  ,  nCol + nColC 			,  nLine+nTamLin, nCol + nColE , cTamGrid)
			// Box Cinza
//			oPrint:FillRect({nLine,nCol + nColC,nLine+nTamLin, nCol + nColE},oBrush)
			oPrint:Box(nLine  ,  nCol + nColC ,  nLine+nTamLin, nCol + nColE , cTamGrid)
		
			oPrint:Say(nLine + nLinT ,nCol + nSpacT	 	   					, "Uso do banco"		, oFont09:oFont)
			oPrint:Say(nLine + nLinT ,nCol + (nColC/4) - 30 + nSpacT		, "Cip"					, oFont09:oFont)
			oPrint:Say(nLine + nLinT ,nCol + (nColC/4) + nSpacT	 	  	 	, "Carteira"	    	, oFont09:oFont)
			oPrint:Say(nLine + nLinT ,nCol + (nColC/4) +70 + nSpacT	   		, "Espécie"   		  	, oFont09:oFont)
			oPrint:Say(nLine + nLinT ,nCol + (nColC/4*3)-50 + nSpacT		, "Quantidade"	    	, oFont09:oFont)
			oPrint:Say(nLine + nLinT ,nCol + (nColC/4*3)+20 + nSpacT		, "Valor documento"     , oFont09:oFont)
//			oPrint:Say(nLine + nLinT ,nCol + nColC + nSpacT	 	   	   		, "1 (=) Valor documento" , oFont09:oFont)
			oPrint:Say(nLine + nLinT ,nCol + nColC + nSpacT	 	   			, "2 (-) Desconto / Abatimentos" , oFont09:oFont)

			oPrint:Say(nLine + nLinC ,nCol + nSpacT	 	   				, cUsoBco				, oFont11N:oFont)
			oPrint:Say(nLine + nLinC ,nCol + (nColC/4) - 30 + nSpacT	, "000"					, oFont11N:oFont)
			oPrint:Say(nLine + nLinC ,nCol + (nColC/4) + nSpacT	 	   	, cDescCart		    	, oFont11N:oFont)
			oPrint:Say(nLine + nLinC ,nCol + (nColC/4) +70 + nSpacT	 	, "R$"		   		  	, oFont11N:oFont)
			oPrint:Say(nLine + nLinC ,nCol + (nColC/4*3)-50 + nSpacT	, cQTBco		    	, oFont11N:oFont)
//			oPrint:Say(nLine + nLinC ,nCol + (nColC/4*3)+20 + nSpacT	, Alltrim(Transform(SE1->E1_VALOR, "@E 999,999,999.99"))     , oFont11N:oFont)
//			oPrint:Say(nLine + nLinC ,nCol + nColC + nSpacT	, Padl(Alltrim(Transform(SE1->E1_VALOR, "@E 999,999,999.99")),nPadL)       , oFont11b:oFont)

		EndIf
		
		// Instruções
		nLine += nSalto
		oPrint:Box(nLine  ,  nCol         ,  nLine+(nTamLin*5), nCol + nColC , cTamGrid)

		oPrint:Say(nLine + nLinT ,nCol + nSpacT	 	, "Instruções: (Texto de responsabilidade do Beneficiário)"		, oFont09:oFont)

		oPrint:Say(nLine + nLinW 	  ,nCol + nSpacT	 	    , aBolText[01]		, oFont11N:oFont)
		oPrint:Say(nLine + nLinW+(nLinW/2)     ,nCol + nSpacT	, aBolText[02]		, oFont11N:oFont)
		oPrint:Say(nLine + (nLinW*2)            ,nCol + nSpacT	, aBolText[03]		, oFont11N:oFont)
		oPrint:Say(nLine + (nLinW*2)+(nLinW/2) ,nCol + nSpacT	, aBolText[04]		, oFont11N:oFont)
		oPrint:Say(nLine + (nLinW*2)+(nLinW)   ,nCol + nSpacT	, aBolText[05]		, oFont11N:oFont)
		oPrint:Say(nLine + (nLinW*3)+(nLinW/2) ,nCol + nSpacT	, aBolText[06]		, oFont11N:oFont)

/*
		oPrint:Box(nLine  ,  nCol + nColC ,  nLine+nTamLin, nCol + nColE , cTamGrid)
		oPrint:Say(nLine + nLinT ,nCol + nColC + nSpacT	 	   		, "2 (-) Desconto / Abatimentos" , oFont09:oFont)

		nLine += nSalto     
*/		
		
		oPrint:Box(nLine  ,  nCol + nColC ,  nLine+nTamLin, nCol + nColE , cTamGrid)
		oPrint:Say(nLine + nLinT ,nCol + nColC + nSpacT	 	   		, "3 (-) Outras Deduções" , oFont09:oFont)

		nLine += nSalto
		oPrint:Box(nLine  ,  nCol + nColC ,  nLine+nTamLin, nCol + nColE , cTamGrid)
		oPrint:Say(nLine + nLinT ,nCol + nColC + nSpacT	 	   		, "4 (+) Mora / Multa" , oFont09:oFont)

		nLine += nSalto
		oPrint:Box(nLine  ,  nCol + nColC ,  nLine+nTamLin, nCol + nColE , cTamGrid)
		oPrint:Say(nLine + nLinT ,nCol + nColC + nSpacT	 	   		, "5 (+) Outros Acréscimos" , oFont09:oFont)

		nLine += nSalto
		oPrint:Box(nLine  ,  nCol + nColC ,  nLine+nTamLin, nCol + nColE , cTamGrid)
		oPrint:Say(nLine + nLinT ,nCol + nColC + nSpacT	 	   		, "6 (=) Valor Cobrado" , oFont09:oFont)

		nLine += nSalto
		oPrint:Box(nLine  ,  nCol         ,  nLine+(nTamLin*2), nCol + nColE , cTamGrid)
		oPrint:Say(nLine + nLinT ,nCol + nSpacT	 	 		, "Pagador:"    , oFont09:oFont)

		oPrint:Say(nLine + nLinC ,nCol + nSpacT + 26	 	 	, AllTrim(aDatSacado[1]) +" - CNPJ : " + TransForm(AllTrim(aDatSacado[9]),"@R 99.999.999/9999-99")      , oFont11N:oFont)
		oPrint:Say(nLine + (nLinC+(nLinC/2)) ,nCol + nSpacT	+ 26, AllTrim(aDatSacado[4])  +" - " + AllTrim(aDatSacado[8])    , oFont11N:oFont)
		oPrint:Say(nLine + (nLinC*2) ,nCol + nSpacT	 + 26  		, "CEP " +TransForm(AllTrim(aDatSacado[7]),"@R 99999-999") + " - " + AllTrim(aDatSacado[5])  +" / " + AllTrim(aDatSacado[6]) , oFont11N:oFont)


		nLine += nSalto
		oPrint:Box(nLine + (nTamLin/2) ,  nCol + nColC         ,  nLine + nTamLin, nCol + nColC  , cTamGrid)
		oPrint:Say(nLine + (nSalto/2)+ nLinT ,nCol + nColC  + nSpacT, "Cód. baixa"   , oFont07:oFont)

		nLine += nSalto

		oPrint:Say(nLine + nLinT ,nCol + nSpacT	 	 		, "Sacador/Avalista"    , oFont09:oFont)
		oPrint:Say(nLine + nLinT ,nCol + nColC - 50 + nSpacT, "Autenticação mecânica -"   , oFont09:oFont)
		oPrint:Say(nLine + nLinT ,nCol + nColD + nSpacT	 	, "Ficha de Compensação"    , oFont09N:oFont)

		nLine += nSalto
		nLine -= nSalto
		nLine -= nSalto

		cFontBar := "Times New Roman"
		cTypeBar := "INT25"

	//	oPrint:FWMSBAR("INT25" /*cTypeBar*/,64/*nRow*/ ,3/*nCol*/, AllTrim(aCB_RN_NN[1]) /*cCode*/,oPrint/*oPrint*/,.T./*lCheck*/,/*Color*/,.T./*lHorz*/,0.0165/*nWidth*/,0.8/*nHeigth*/,.F./*lBanner*/,"Arial"/*cFont*/,NIL/*cMode*/,.F./*lPrint*/,1.5/*nPFWidth*/,2/*nPFHeigth*/,.F./*lCmtr2Pix*/)
	//	oPrint:MSBAR("INT25" /*cTypeBar*/,64/*nRow*/ ,3/*nCol*/, AllTrim(aCB_RN_NN[1]) /*cCode*/,oPrint/*oPrint*/,.T./*lCheck*/,/*Color*/,.T./*lHorz*/,0.0165/*nWidth*/,0.8/*nHeigth*/,.F./*lBanner*/,cFontBar/*cFont*/,NIL/*cMode*/,.F./*lPrint*/,1.5/*nPFWidth*/,2/*nPFHeigth*/,.F./*lCmtr2Pix*/)
	//	MSBAR3("INT25",6.5,0.3, AllTrim(aCB_RN_NN[1]),oPrint,/*lCheck*/,/*Color*/,/*lHorz*/,.00500,0.13,/*lBanner*/,/*cFont*/,"",.F.)
	//	oPrint:Code128C(nLine+(nSalto*3),nCol+10,AllTrim(aCB_RN_NN[1]), 35 )

		oBar:= CBBAR():New(cTypeBar,(nLine / 113) /*6.2*/,/*(nCol/60)*/0.2,AllTrim(aCB_RN_NN[1]) ,oPrint,.F.,/*Color*/,.T.,0.0165,1.2,.F.,cFontBar/*cFont*/,"A",.F.,0.1/*nPFWidth*/,0.5/*nPFHeigth*/,/*lCmtr2Pix*/)
		oBar:nVertRes		:= 25 //3437 //3437 //nVert
		oBar:nHorzRes		:= 25 //2410 //nHori
		oBar:nVertSize		:= 08 //291  //nVert
		oBar:nHorzSize		:= 08 //204  //nHori
		oBar:Draw()

		oPrint:SayBitmap(nLine+52, nCol + nColD + 18, "iso9001.png",65,20)

		nLine += nSalto
		nLine += nSalto
		nLine += nSalto
		nLine += nSalto

		oPrint:EndPage()     // Finaliza a página
		
		DbSelectArea("SE1")
                                   
		// Salva os registros que foram impressos
		AADD(aRecImp,SE1->(Recno()))

		dbSkip()
		lContD2:=.F.
	Enddo
	oPrint:EndPage()     // Finaliza a página

Next

If Len(aRecImp) > 0
	DbSelectArea("SE1")
	
	// Atualiza o Flag de impressão
	If SE1->(FieldPos("E1_XBOLETO")) > 0
		For Nw := 1 To Len(aRecImp)
			DbGoTo(aRecImp[Nw])
			RecLock("SE1",.F.)
			SE1->E1_XBOLETO := "2" // Impresso
			MsUnlock()
		Next 
	EndIf            
	
	DbGoTo(aRecImp[01])
	
	oPrint:Print()
//	oPrint:Preview()
Else
	oPrint:Cancel()	
EndIf	
    
If !Empty(cNoImp)
	Aviso("Atenção",cNoImp,{"Ok"},3,"Alguns boletos não foram impressos.")
EndIf


RestArea1(aSavAre)       

Return


//-------------------------------------------------------------------------------------
/*/{Protheus.doc} Ano4Dig
Retorna data no formato caracter com 4 digitos para o ano

@type 		function
@author 	Roberto Souza
@since 		12/01/2017
@version 	P11 
@param	 	dData 	- Data                               

@return nil
/*/    
//-------------------------------------------------------------------------------------
Static Function Ano4Dig( dData )

Return(StrZero(Day(dData), 2) + "/" + StrZero(Month(dData), 2) + "/" + StrZero(Year(dData), 4))



//-------------------------------------------------------------------------------------
/*/{Protheus.doc} DefineBanco
Retorna o digito de controle do banco informado

@type 		function
@author 	Roberto Souza
@since 		12/01/2017
@version 	P11 
@param	 	cBanco 	- Codigo do Banco                               

@return nil
/*/    
//-------------------------------------------------------------------------------------
Static Function DefineBanco( cBanco )
	Local cDvBco := ""

	cBanco := AllTrim(cBanco)

	Do Case
		Case cBanco == "001"
			cDvBco := "9"
			cNomeBco := "Banco do Brasil"
		Case cBanco == "008"
			cDvBco := "6"
			cNomeBco := "Santander Meridional"
		Case cBanco == "033"
			cDvBco := "7"
			cNomeBco := "Santander"
		Case cBanco == "104"
			cDvBco := "0"
			cNomeBco := "Caixa"
		Case cBanco == "237"
			cDvBco := "2"
			cNomeBco := "Bradesco"
		Case cBanco == "244"
			cDvBco := "5"
			cNomeBco := "Cidade"
		Case cBanco == "341"
			cDvBco   := "7"
			cNomeBco := "Itaú" //+ __ANSI
		Case cBanco == "353"
			cDvBco   := "0"
			cNomeBco := "Santander"
		Case cBanco == "356"
			cDvBco   := "5"
			cNomeBco := "Santander"
		Case cBanco == "399"
			cDvBco   := "9"
			cNomeBco := "HSBC"
		Case cBanco == "409"
			cDvBco   := "0"
			cNomeBco := "Unibanco"
		Case cBanco == "422"
			cDvBco   := "7"
			cNomeBco := "Safra"
			EspecieTit:="DS"
		Case cBanco == "739"
			cDvBco   := "7"
			cNomeBco := "Banco BGN"
		Case cBanco == "745"
			cDvBco   := "5"
			cNomeBco := "CITIBANK"
		Case cBanco == "630"
			cDvBco   := "7"
			cNomeBco := "Intercap"
	EndCase

Return( cDvBco )


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³Ret_cBarra³ Autor ³ Microsiga             ³ Data ³ 29/11/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ IMPRESSAO DO BOLETO LASER                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Ret_cBarra(cBanco,cAgencia,cConta,cDacCC,cCarteira,cNroDoc,nValor,dvencimento,cConvenio,cSequencial,_lTemDesc,_cParcela,_cAgCompleta)
Local cCodEmp := StrZero(Val(SubStr(cConvenio,1,7)),7)
Local cNumSeq := strzero(val(cSequencial),13)
Local bldocnufinal := strzero(val(cNroDoc),9)
Local blvalorfinal := strzero(int(nValor*100),10)
Local cNNumSDig := cCpoLivre := cCBSemDig := cCodBarra := cNNum := cFatVenc := ''
Local cNossoNum
Local _cDigito := ""
Local _cSuperDig := ""

_cParcela := NumParcela(_cParcela)

//Fator Vencimento - POSICAO DE 06 A 09
cFatVenc := STRZERO(dvencimento - CtoD("07/10/1997"),4)


//Campo Livre (Definir campo livre com cada banco)

If Substr(cBanco,1,3) == "001"  // Banco do brasil
	If Len(AllTrim(cConvenio)) == 7
		//Nosso Numero sem digito
		cNNumSDig := AllTrim(cConvenio)+strzero(val(cSequencial),10)
		//Nosso Numero com digito
		cNNum := cNNumSDig

		//Nosso Numero para impressao
		cNossoNum := cNNumSDig

		//		cCpoLivre := "000000"+cNNumSDig+AllTrim(cConvenio)+strzero(val(cSequencial),10)+ cCarteira
		cCpoLivre := "000000"+cNNumSDig+cCarteira
	Else
		//Nosso Numero sem digito
		cNNumSDig := cCodEmp+cNumSeq
		//Nosso Numero com digito
		cNNum := cNNumSDig + modulo11(cNNumSDig,Val(SubStr(cBanco,1,3)))

		//Nosso Numero para impressao
		cNossoNum := cNNumSDig +"-"+ modulo11(cNNumSDig,Val(SubStr(cBanco,1,3)))

		cCpoLivre := cNNumSDig+cAgencia + StrZero(Val(cConta),8) + cCarteira
	Endif
Elseif Substr(cBanco,1,3) == "389" // Banco mercantil
	//Nosso Numero sem digito
	cNNumSDig := "09"+cCarteira+ strzero(val(cSequencial),6)
	//Nosso Numero
	cNNum := "09"+cCarteira+ strzero(val(cSequencial),6) + modulo11(cAgencia+cNNumSDig,Val(SubStr(cBanco,1,3)))
	//Nosso Numero para impressao
	cNossoNum := "09"+cCarteira+ strzero(val(cSequencial),6) +"-"+ modulo11(cAgencia+cNNumSDig,Val(SubStr(cBanco,1,3)))

	cCpoLivre := cAgencia + cNNum + StrZero(Val(SubStr(cConvenio,1,9)),9)+Iif(_lTemDesc,"0","2")

Elseif Substr(cBanco,1,3) == "237" // Banco bradesco
	//Nosso Numero sem digito
	cNNumSDig := cCarteira + bldocnufinal
	//Nosso Numero
	cNNum := cCarteira + '/' + bldocnufinal + '-' + AllTrim( Str( modulo10( cNNumSDig ) ) )
	//Nosso Numero para impressao
	cNossoNum := cCarteira + '/' + bldocnufinal + '-' + AllTrim( Str( modulo10( cNNumSDig ) ) )

	cCpoLivre := cAgencia + cCarteira + cNNumSDig + StrZero(Val(cConta),7) + "0"

Elseif Substr(cBanco,1,3) == "453"  // Banco rural
	//Nosso Numero sem digito
	cNNumSDig := strzero(val(cSequencial),7)
	//Nosso Numero
	cNNum := cNNumSDig + AllTrim( Str( modulo10( cNNumSDig ) ) )
	//Nosso Numero para impressao
	cNossoNum := cNNumSDig +"-"+ AllTrim( Str( modulo10( cNNumSDig ) ) )

	cCpoLivre := "0"+StrZero(Val(cAgencia),3) + StrZero(Val(cConta),10)+cNNum+"000"

Elseif Substr(cBanco,1,3) $ "341|630"  // Banco Itau + Intercap
	//Nosso Numero sem digito
	cNNumSDig := cCarteira+strzero(val(cNroDoc),6)+ _cParcela
	//Nosso Numero
	cNNum := cCarteira+strzero(val(cNroDoc),6) + _cParcela + AllTrim( Str( modulo10( StrZero(Val(cAgencia),4) + StrZero(Val(cConta),5)+cNNumSDig ) ) )
	//Nosso Numero para impressao
	cNossoNum := cCarteira+"/"+strzero(val(cNroDoc),6)+ _cParcela +'-' + AllTrim( Str( modulo10( StrZero(Val(cAgencia),4) + StrZero(Val(cConta),5) + cNNumSDig ) ) )

	cCpoLivre := cNNumSDig+AllTrim( Str( modulo10( StrZero(Val(cAgencia),4) + StrZero(Val(cConta),5)+cNNumSDig ) ) )+StrZero(Val(cAgencia),4) + StrZero(Val(cConta),5)+AllTrim( Str( modulo10( StrZero(Val(cAgencia),4) + StrZero(Val(cConta),5) ) ) )+"000"

Elseif Substr(cBanco,1,3) == "399"  // Banco HSBC
	//Nosso Numero
	cNNumSDig := strzero(val(cSequencial),8)

	cNNumSDig := strzero(val(cSequencial),8) + modulo11(cNNumSDig,Val(SubStr(cBanco,1,3))) + "5"
	cNNum := Val(cNNumSDig) + Val(cConvenio)
	cNNum := modulo11(strzero(cNNum,13),Val(SubStr(cBanco,1,3)))

	//Nosso Numero para impressao
	cNossoNum := cNNumSDig + cNNum

	//	cCpoLivre := cNNum+StrZero(Val(cAgencia),4) + StrZero(Val(cConta),7)+"001"
	cCpoLivre := StrZero(Val(SubStr(cConvenio,1,7)),7)+strzero(val(cSequencial),13)+"00002"

Elseif Substr(cBanco,1,3) == "422"  // Banco Safra
	//Nosso Numero sem digito
	cNNumSDig := strzero(val(cSequencial),8)
	//Nosso Numero
	cNNum := cNNumSDig + MD11SAFRA(cNNumSDig)
	//Nosso Numero para impressao
	cNossoNum := cNNumSDig +"-"+ MD11SAFRA(cNNumSDig)

	cCpoLivre := "7"+cAgencia+cConta+cDacCC+cNNum+"2"

Elseif Substr(cBanco,1,3) == "479" // Banco Boston
	cNumSeq := strzero(val(cSequencial),8)
	cCodEmp := StrZero(Val(SubStr(cConvenio,1,9)),9)
	//Nosso Numero sem digito
	cNNumSDig := strzero(val(cSequencial),8)
	//Nosso Numero
	cNNum := cNNumSDig + modulo11(cNNumSDig,Val(SubStr(cBanco,1,3)))
	//Nosso Numero para impressao
	cNossoNum := cNNumSDig +"-"+ modulo11(cNNumSDig,Val(SubStr(cBanco,1,3)))

	cCpoLivre := cCodEmp+"000000"+cNNum+"8"

Elseif Substr(cBanco,1,3) == "409" // Banco UNIBANCO
	cNumSeq := strzero(val(cSequencial),10)
	cCodEmp := StrZero(Val(SubStr(cConvenio,1,9)),9)
	//Nosso Numero sem digito
	cNNumSDig := strzero(val(cSequencial),10)
	//Nosso Numero
	_cDigito := modulo11(cNNumSDig,Val(SubStr(cBanco,1,3)))
	//Calculo do super digito
	_cSuperDig := modulo11("1"+cNNumSDig + _cDigito,Val(SubStr(cBanco,1,3)))
	cNNum := "1"+cNNumSDig + _cDigito + _cSuperDig
	//Nosso Numero para impressao
	cNossoNum := "1/" + cNNumSDig + "-" + _cDigito + "/" + _cSuperDig
	// O codigo fixo "04" e para a combranco som registro
	cCpoLivre := "04" + SubStr(DtoS(dvencimento),3,6) + StrZero(Val(StrTran(_cAgCompleta,"-","")),5) + cNNumSDig + _cDigito + _cSuperDig

Elseif Substr(cBanco,1,3) $ "|353|033|" // Banco Santander
	cNumSeq := strzero(val(cNumSeq),13)
	//Nosso Numero sem digito
	cNNumSDig := cNumSeq
	//Nosso Numero
	cNNum := cNumSeq
	//Nosso Numero para impressao
	cNossoNum := cNNum
	cCpoLivre := StrZero(Val(cAgencia),4) + StrZero(Val(cConta),7) + AllTrim(Str( modulo10( StrZero(Val(cAgencia),4) + StrZero(Val(cConta),7)+cNNumSDig ) ) ) + cNNumSDig

Elseif Substr(cBanco,1,3) == "745" // Banco CITIBANK
	//Nosso Numero sem digito
	cNNumSDig := SubStr(cNossoNum,1,Len(cNossoNum)-1)
	//Nosso Numero
	cCpoLivre := "3"+StrZero(Val(cAgencia),4) + StrZero(Val(cConta),7) + AllTrim(Str( modulo10( StrZero(Val(cAgencia),4) + StrZero(Val(cConta),7)+cNNumSDig ) ) ) + cNNumSDig

Endif

//Dados para Calcular o Dig Verificador Geral
cCBSemDig := cBanco + cFatVenc + blvalorfinal + cCpoLivre
//Codigo de Barras Completo
If SubStr( cBanco, 1, 3) == '422'
	cCodBarra := cBanco + Md11Safra(cCBSemDig,.T.) + cFatVenc + blvalorfinal + cCpoLivre
Else
	cCodBarra := cBanco + Modulo11(cCBSemDig) + cFatVenc + blvalorfinal + cCpoLivre
EndIf

//Digito Verificador do Primeiro Campo
cPrCpo := cBanco + SubStr(cCodBarra,20,5)
cDvPrCpo := AllTrim(Str(Modulo10(cPrCpo)))

//Digito Verificador do Segundo Campo
cSgCpo := SubStr(cCodBarra,25,10)
cDvSgCpo := AllTrim(Str(Modulo10(cSgCpo)))

//Digito Verificador do Terceiro Campo
cTrCpo := SubStr(cCodBarra,35,10)
cDvTrCpo := AllTrim(Str(Modulo10(cTrCpo)))

//Digito Verificador Geral
cDvGeral := SubStr(cCodBarra,5,1)

//Linha Digitavel
cLindig := SubStr(cPrCpo,1,5) + "." + SubStr(cPrCpo,6,4) + cDvPrCpo + " "   //primeiro campo
cLinDig += SubStr(cSgCpo,1,5) + "." + SubStr(cSgCpo,6,5) + cDvSgCpo + " "   //segundo campo
cLinDig += SubStr(cTrCpo,1,5) + "." + SubStr(cTrCpo,6,5) + cDvTrCpo + " "   //terceiro campo
cLinDig += " " + cDvGeral              //dig verificador geral
cLinDig += "  " + SubStr(cCodBarra,6,4)+SubStr(cCodBarra,10,10)  // fator de vencimento e valor nominal do titulo
//cLinDig += "  " + cFatVenc +blvalorfinal  // fator de vencimento e valor nominal do titulo

Return({cCodBarra,cLinDig,cNossoNum})


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFun‡„o    ³NumParcelaº Autor ³ Microsiga          º Data ³  30/11/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescri‡„o ³ Ajusta a parcela.                                          º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Generico                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function NumParcela( cParcela )
	Local cRet := ""
	If ASC(cParcela) >= 65 .or. ASC(cParcela) <= 90
		cRet := StrZero(Val(Chr(ASC(cParcela)-16)),2)
	Else
		cRet := StrZero(Val(cParcela),2)
	Endif
Return( cRet )

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ Modulo10 ³ Autor ³ Microsiga             ³ Data ³ 13/10/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ IMPRESSAO DO BOLETO LASE DO HSBC COM CODIGO DE BARRAS      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Especifico para Clientes Microsiga                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Modulo10(cData)
	Local L,D,P := 0
	Local B     := .F.

	L := Len(cData)
	B := .T.
	D := 0

	While L > 0
		P := Val(SubStr(cData, L, 1))
		If (B)
			P := P * 2
			If P > 9
				P := P - 9
			EndIf
		EndIf
		D := D + P
		L := L - 1
		B := !B
	EndDo
	D := 10 - (Mod(D,10))
	If D = 10
		D := 0
	EndIf
Return(D)




/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³NNumBB 				 ºAutor  ³ Microsiga          º Data ³  10/11/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcao que gera o nosso numero de um titulo conforme regra do banco do   º±±
±±º          ³brasil                                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function NNumBB(cBanco,cAgencia,cConta)
	Local cRetorno := ""
	
	//Busca as informacoes da tabela de Parametros Banco
	DbSelectArea("SEE")
	SEE->(dbSetOrder(1))
	If SEE->(dbSeek(xFilial("SEE")+cBanco+cAgencia+cConta ))
		cRetorno := Padl(Alltrim(Substr(SEE->EE_CODEMP, 6)),  7, "0")//SubStr(AllTrim(SEE->EE_CODEMP),1,6) //Convenio do banco
		cRetorno += StrZero(Val(SEE->EE_FAXATU),10) //Numero sequencial controlado pelo cliente
		cRetorno += AllTrim(Modulo11B(cRetorno)) //Digito de controle do nosso numero (modulo 11)
	
		//Atualiza o sequencial da tabela de parametros bancarios
		SEE->(RecLock("SEE",.F.))
		SEE->EE_FAXATU := StrZero(Val(SEE->EE_FAXATU)+1,10)
		SEE->(MsUnlock())
	EndIf
	
Return(cRetorno)




/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ Modulo11A³ Autor ³ Microsiga             ³ Data ³ 13/10/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Calculo Modulo 11  										  ³±±
±±³          ³ especifico para Nosso Numero do Banco do Brasil            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Especifico para Clientes Microsiga                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Modulo11A(cData)
	Local L, D, P := 0
	L := Len(cdata)
	D := 0
	P := 1
	While L > 0
		P := P + 1
		D := D + (Val(SubStr(cData, L, 1)) * P)
		If P = 9
			P := 1
		EndIf
		L := L - 1
	EndDo
	D := 11 - (mod(D,11))
	
	If (D == 10)
		D := "X"
	ElseIf (D == 11)
		D := 0
	EndIf
	
Return(D)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³    CBarBB³ Autor ³ Microsiga             ³ Data ³ 13/10/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Prepara os dados do Codigo de Barras e Linha Digitavel     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Especifico para Clientes Microsiga                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function CBarBB(cBanco,nNrConvenio,nNrBancario,nValor,dVencto,nDVNrBanc,nCarteira)

Local cValorFinal := strzero(nValor*100,10)
//Local nDvnn			:= 0
Local nDvcb			:= 0
//Local nDv			:= 0
//Local cNN			:= ''
//Local cRN			:= ''
Local cCB			:= ''
Local cS			:= ''
Local cFator      	:= strzero(dVencto - ctod("07/10/97"),4)
Local cCmpltoNsNr	:= '000000'


//----------------------------------
//	 Definicao do CODIGO DE BARRAS
//----------------------------------
cS:= cBanco + cFator +  cValorFinal + cCmpltoNsNr + nNrConvenio + nNrBancario + nCarteira
nDvcb := modulo11B(Substr(cS,1,43))
cCB   := SubStr(cS, 1, 4) + Alltrim(str(nDvcb)) + SubStr(cS,5,39)

//-------- Definicao da LINHA DIGITAVEL (Representacao Numerica)
//	Campo 1			Campo 2			Campo 3			Campo 4		Campo 5
//	AAABC.CCDDX		DDDDD.DDFFFY	FGGGG.GGHHHZ	K			UUUUVVVVVVVVVV

// 	CAMPO 1:
//	AAA	= Codigo do banco na Camara de Compensacao
//	  B = Codigo da moeda, sempre 9
//	CCC = Codigo da Carteira de Cobranca
//	 DD = Dois primeiros digitos no nosso numero
//	  X = DAC que amarra o campo, calculado pelo Modulo 10 da String do campo

cS1   := cBanco + SubStr(cCmpltoNsNr,1,5)
nDv1  := modulo10(cS1)
cLD1  := SubStr(cS1, 1, 5) + '.' + SubStr(cS1, 6, 4) + AllTrim(Str(nDv1)) + '  '

// 	CAMPO 2:
//	DDDDDD = Restante do Nosso Numero
//	     E = DAC do campo Agencia/Conta/Carteira/Nosso Numero
//	   FFF = Tres primeiros numeros que identificam a agencia
//	     Y = DAC que amarra o campo, calculado pelo Modulo 10 da String do campo

cS2	:= SubStr(cCmpltoNsNr,6,1) + Alltrim(nNrConvenio)+ SubStr(nNrBancario,1,2)
nDv2:= modulo10(cS2)
cLD2:= SubStr(cS2, 1, 5) + '.' + SubStr(cS2, 6, 5) + AllTrim(Str(nDv2)) + '  '

// 	CAMPO 3:
//	     F = Restante do numero que identifica a agencia
//	GGGGGG = Numero da Conta + DAC da mesma
//	   HHH = Zeros (Nao utilizado)
//	     Z = DAC que amarra o campo, calculado pelo Modulo 10 da String do campo
cS3   := SubStr(nNrBancario,3,8) + SubStr(nCarteira,1,2)
nDv3  := modulo10(cS3)
cLD3  := SubStr(cS3, 1, 5) + '.' + SubStr(cS3, 6, 5) + AllTrim(Str(nDv3)) + '   '

//	CAMPO 4:
//	     K = DAC do Codigo de Barras
cLD4  := AllTrim(Str(nDvcb)) + '   '

// 	CAMPO 5:
//	      UUUU = Fator de Vencimento
//	VVVVVVVVVV = Valor do Titulo
cLD5  := cFator + cValorFinal

cLD	  := cLD1 + cLD2 + cLD3 + cLD4 + cLD5

Return({cCB,cLD})

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³CBarCEF   ³ Autor ³ Microsiga             ³ Data ³ 10/09/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Prepara os dados do Codigo de Barras e Linha Digitavel     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Especifico para Clientes Microsiga                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function CBarCEF(cBanco,cMoeda,dVencto,nValor,cCarteira,cNossso,cAg,cOP,cCodX)

Local cValorFinal := strzero(nValor*100,10)
Local cFator      	:= strzero(dVencto - ctod("07/10/97"),4)
Local nDvcb			:= 0
Local cCB			:= ''
Local cS			:= ''
//Local cCmpltoNsNr	:= '000000'
/*
	Posição Tamanho Picture Conteúdo
01 - 03 	3 		9 		(3) Identificação do banco
04 - 04 	1 		9 		Código da moeda (9 - real)
05 - 05 	1 		9 		Dígito Verificador Geral do Código de Barras
06 - 09 	4 		9 		Fator de Vencimento
10 - 19 	10 		9 		(8) V99 Valor do Documento
20 - 44 	25 		9 		(25) Campo Livre
*/

//----------------------------------
//	 Definicao do CODIGO DE BARRAS
//----------------------------------
cS:= cBanco + cMoeda + cFator +  cValorFinal + left(cNossso,10) + cAg+cOP+cCodX
nDvcb := modulo11B(Substr(cS,1,43))
cCB   := SubStr(cS, 1, 4) + Alltrim(str(nDvcb)) + SubStr(cS,5,39)

//-------- Definicao da LINHA DIGITAVEL (Representacao Numerica)
//	Campo 1			Campo 2			Campo 3			Campo 4		Campo 5
//	AAABC.CCDDX		DDDDD.DDFFFY	FGGGG.GGHHHZ	K			UUUUVVVVVVVVVV

// 	CAMPO 1:
//1 Campo - Composto por: codigo banco (posicoes 1 a 3 do codigo de barras)
//codigo da moeda (posição 4 do codigo de barras),
//as cinco primeiras posicoes do campo livre (posicoes 20 a 24 do codigo de barras)
// e digito verificador deste campo
//	AAA	= Codigo do banco na Camara de Compensacao
//	  B = Codigo da moeda, sempre 9
//	CCC = Codigo da Carteira de Cobranca
//	 DD = Dois primeiros digitos no nosso numero
//	  X = DAC que amarra o campo, calculado pelo Modulo 10 da String do campo

cS1   := cBanco + cMoeda + SubStr(cCB,20,5)
nDv1  := modulo10(cS1)
cLD1  := SubStr(cS1, 1, 5) + '.' + SubStr(cS1, 6, 4) + AllTrim(Str(nDv1)) + '  '

// 	CAMPO 2:
//2 Campo - Composto pelas posicoes 6 a 15 do campo livre (posicoes 25 a 34 do código de barras)
// e digito verificador deste campo
//	DDDDDD = Restante do Nosso Numero
//	     E = DAC do campo Agencia/Conta/Carteira/Nosso Numero
//	   FFF = Tres primeiros numeros que identificam a agencia
//	     Y = DAC que amarra o campo, calculado pelo Modulo 10 da String do campo

cS2	:= SubStr(cCB,25,10)
nDv2:= modulo10(cS2)
cLD2:= SubStr(cS2, 1, 5) + '.' + SubStr(cS2, 6, 5) + AllTrim(Str(nDv2)) + '  '
//10499.00002 00001.028588 70000.003767 7 51060000010000
// 	CAMPO 3:
// 3 Campo - Composto pelas posicoes 16 a 25 do campo livre (posicoes 35 a 44 do codigo de barras) e digito verificador deste campo
//	     F = Restante do numero que identifica a agencia
//	GGGGGG = Numero da Conta + DAC da mesma
//	   HHH = Zeros (Nao utilizado)
//	     Z = DAC que amarra o campo, calculado pelo Modulo 10 da String do campo
ôcS3   := SubStr(cCB,35,10)
nDv3  := modulo10(cS3)
cLD3  := SubStr(cS3, 1, 5) + '.' + SubStr(cS3, 6, 5) + AllTrim(Str(nDv3)) + '   '

//	CAMPO 4:
//	     K = DAC do Codigo de Barras
cLD4  := AllTrim(Str(nDvcb)) + '   '

// 	CAMPO 5:
//Composto pelo "fator de vencimento" (posicoes 6 a 9 do codigo de barras) e pelo valor nominal do documento
//(posicoes 10 a 19 do codigo de barras), com a inclusão de zeros entre eles ate compor as 14 posicoes do
//campo e sem edicao (sem ponto e sem vírgula).
//	      UUUU = Fator de Vencimento
//	VVVVVVVVVV = Valor do Titulo
cLD5  := cFator + cValorFinal

cLD	  := cLD1 + cLD2 + cLD3 + cLD4 + cLD5

Return({cCB,cLD})


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ Modulo11 ³ Autor ³ Microsiga             ³ Data ³ 12/06/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Calculo do Modulo 11                                       ³±±
±±³          ³ para calcular o Dig Verificador do Codigo de Barras BB     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Especifico para Clientes Microsiga                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Modulo11B(cData)
Local L, D, P := 0
L := Len(cdata)
D := 0
P := 1
While L > 0
	P := P + 1
	D := D + (Val(SubStr(cData, L, 1)) * P)
	If P = 9
		P := 1
	End
	L := L - 1
End
D := 11 - (mod(D,11))
If (D == 0 .Or. D == 1 .Or. D == 10 .Or. D == 11)
	D := 1
End
Return(D)

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} CBarBra2
Gera o codigo de barras para o bradesco

@type 		function
@author 	Roberto Souza
@since 		12/01/2017
@version 	P11 
 
@return nil
/*/    
//-------------------------------------------------------------------------------------
Static Function CBarBra2(cBanco,nNrConvenio,nNrBancario,nValor,dVencto,nDVNrBanc,nNrCart,cAgencia,cConta,cDacCC,cNroDoc)

Local cValorFinal 	:= StrTran( StrZero(nValor,11,2) ,".","") //strzero(int(nValor*100),10)
Local nDvnn			:= 0
Local nDvcb			:= 0
Local nDv			:= 0
Local cNN			:= ''
Local cRN			:= ''
Local cCB			:= ''
Local cS			:= ''
Local cFator      	:= strzero(dVencto - ctod("07/10/97"),4)
Local cCart			:= Right(nNrCart,2) //"19"
//-----------------------------
// Definicao do NOSSO NUMERO
// ----------------------------
cS    :=  cCart + cNroDoc //19 001000012
nDvnn := modulo11(cS) // digito verifacador 
cNNSD := cS //Nosso Numero sem digito
cNN   := cCart + cNroDoc + '-' + AllTrim(cValToChar(nDvnn))
//----------------------------------
//	 Definicao do CODIGO DE BARRAS
//----------------------------------
cLivre := Strzero(Val(cAgencia),4)+ /*cCart+*/ cNNSD + Strzero(Val(cConta),7) + "0"

cS:= cBanco + cFator +  cValorFinal + cLivre // + Subs(cNN,1,11) + Subs(cNN,13,1) + cAgencia + cConta + cDacCC + '000'

nDvcb	:= U_MyMod11( cS , 9 )
//nDvcb 	:= modulo11(cS,9)

cCB   := SubStr(cS, 1, 4) + AllTrim(cValToChar(nDvcb)) + SubStr(cS,5)// + SubStr(cS,31)

//-------- Definicao da LINHA DIGITAVEL (Representacao Numerica)
//	Campo 1			Campo 2			Campo 3			Campo 4		Campo 5
//	AAABC.CCCCX		DDDDD.DDDDDY	FFFFF.FFFFFZ	K			UUUUVVVVVVVVVV

// 	CAMPO 1:
//	AAA	= Codigo do banco na Camara de Compensacao
//	B     = Codigo da moeda, sempre 9                          		
//	CCCCC = 5 primeiros digidos do cLivre
//	X     = DAC que amarra o campo, calculado pelo Modulo 10 da String do campo

cS    := cBanco + Substr(cLivre,1,5)
nDv   := modulo10(cS)  //DAC
cRN   := SubStr(cS, 1, 5) + '.' + SubStr(cS, 6, 4) + AllTrim(cValToChar(nDv)) + '  '      

// 	CAMPO 2:
//	DDDDDDDDDD = Posição 6 a 15 do Nosso Numero 
//	Y          = DAC que amarra o campo, calculado pelo Modulo 10 da String do campo

cS :=Subs(cLivre,6,10)
nDv:= modulo10(cS)
cRN += Subs(cS,1,5) +'.'+ Subs(cS,6,5) + Alltrim(cValToChar(nDv)) + ' ' 

// 	CAMPO 3:
//	FFFFFFFFFF = Posição 16 a 25 do Nosso Numero 
//	Z          = DAC que amarra o campo, calculado pelo Modulo 10 da String do campo
cS :=Subs(cLivre,16,10)
nDv:= modulo10(cS)
cRN += Subs(cS,1,5) +'.'+ Subs(cS,6,5) + Alltrim(cValToChar(nDv)) + ' ' 

//	CAMPO 4:
//	     K = DAC do Codigo de Barras
cRN   += AllTrim(cValToChar(nDvcb)) + '  '

// 	CAMPO 5:
//	      UUUU = Fator de Vencimento
//	VVVVVVVVVV = Valor do Titulo
cRN   += cFator + cValorFinal //StrZero(Int(nValor * 100),14-Len(cFator))

Return({ cCB, cRN, cNN })




//-------------------------------------------------------------------------------------
/*/{Protheus.doc} CBarBra3
Gera o codigo de barras para o bradesco

@type 		function
@author 	Roberto Souza
@since 		12/01/2017
@version 	P11 
 
@return nil
/*/    
//-------------------------------------------------------------------------------------
Static Function CBarBra3(cBanco,nNrConvenio,nNrBancario,nValor,dVencto,nDVNrBanc,nNrCart,cAgencia,cConta,cDacCC,cNroDoc)

Local cValorFinal 	:= strzero(int(nValor*100),10)
Local nDvnn			:= 0
Local nDvcb			:= 0
Local nDv			:= 0
Local cNN			:= ''
Local cRN			:= ''
Local cCB			:= ''
Local cS			:= ''
Local cFator      	:= strzero(dVencto - ctod("07/10/97"),4)
Local cCart			:= Right(nNrCart,2) //"19"  
//-----------------------------
// Definicao do NOSSO NUMERO
// ----------------------------
cS    :=  cCart + cNroDoc //19 001000012
nDvnn := modulo11(cS) // digito verifacador 
cNNSD := cS //Nosso Numero sem digito
cNN   := cCart + cNroDoc + '-' + AllTrim(cValToChar(nDvnn))
//----------------------------------
//	 Definicao do CODIGO DE BARRAS
//----------------------------------
cLivre := Strzero(Val(cAgencia),4)+ /*cCart+*/ cNNSD + Strzero(Val(cConta),7) + "0"

cS:= cBanco + cFator +  cValorFinal + cLivre // + Subs(cNN,1,11) + Subs(cNN,13,1) + cAgencia + cConta + cDacCC + '000'
nDvcb := modulo11(cS)
cCB   := SubStr(cS, 1, 4) + AllTrim(cValToChar(nDvcb)) + SubStr(cS,5)// + SubStr(cS,31)

//-------- Definicao da LINHA DIGITAVEL (Representacao Numerica)
//	Campo 1			Campo 2			Campo 3			Campo 4		Campo 5
//	AAABC.CCCCX		DDDDD.DDDDDY	FFFFF.FFFFFZ	K			UUUUVVVVVVVVVV

// 	CAMPO 1:
//	AAA	= Codigo do banco na Camara de Compensacao
//	B     = Codigo da moeda, sempre 9                          		
//	CCCCC = 5 primeiros digidos do cLivre
//	X     = DAC que amarra o campo, calculado pelo Modulo 10 da String do campo

cS    := cBanco + Substr(cLivre,1,5)
nDv   := modulo10(cS)  //DAC
cRN   := SubStr(cS, 1, 5) + '.' + SubStr(cS, 6, 4) + AllTrim(cValToChar(nDv)) + '  '      

// 	CAMPO 2:
//	DDDDDDDDDD = Posição 6 a 15 do Nosso Numero 
//	Y          = DAC que amarra o campo, calculado pelo Modulo 10 da String do campo

cS :=Subs(cLivre,6,10)
nDv:= modulo10(cS)
cRN += Subs(cS,1,5) +'.'+ Subs(cS,6,5) + Alltrim(cValToChar(nDv)) + ' ' 

// 	CAMPO 3:
//	FFFFFFFFFF = Posição 16 a 25 do Nosso Numero 
//	Z          = DAC que amarra o campo, calculado pelo Modulo 10 da String do campo
cS :=Subs(cLivre,16,10)
nDv:= modulo10(cS)
cRN += Subs(cS,1,5) +'.'+ Subs(cS,6,5) + Alltrim(cValToChar(nDv)) + ' ' 

//	CAMPO 4:
//	     K = DAC do Codigo de Barras
cRN   += AllTrim(cValToChar(nDvcb)) + '  '

// 	CAMPO 5:
//	      UUUU = Fator de Vencimento
//	VVVVVVVVVV = Valor do Titulo
cRN   += cFator + StrZero(Int(nValor * 100),14-Len(cFator))

Return({cCB,cRN,cNN})


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ NNumSafra  º Autor ³ Microsiga          ³ Data ³ 10/06/10    ³±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Funcao que gera o Nosso Número de Acordo com o Banco         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ Banco , Agencia e Conta Corrente                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³ lGerou    - .T. Gerou o Nosso Numero Correto .F. - Nao Gerou º±±
±±º          ³ cNossoNum - Nosso Numero Gerado                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ G & P                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function NNumSafra( cBco , cAge , cCC , cSubcon )

Local aArea     := GetArea()
Local aAreaSEE  := SEE->( GetArea() )
//Local lGerou    := .T.
Local cNossoNum := ""

DbSelectArea("SEE")
DbSetOrder(1)

If DbSeek ( xFilial("SEE") + cBco + cAge + cCC + cSubcon)

	cNossoNum := Soma1 ( StrZero( Val( SEE->EE_FAXATU ) , 8 ) )

	RecLock( "SEE" , .F. )
	SEE->EE_FAXATU := SubStr(cNossoNum, 1, 8)
	MsUnlock()

Endif

RestArea(aAreaSEE)
RestArea(aArea)

Return ( cNossoNum )
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FAT002    ºAutor  ³Microsiga           º Data ³  10/06/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Md11Safra( cData, lBarra )
Local cRet 		:= ""
Local nSoma		:= 0
Local nFor		:= 0
Local nResto 	:= 0
Local nMult 	:= 2

Default lBarra := .F.

For nFor:= Len( cData ) To 1 Step -1
	nSoma += Val( Substr(cData,nFor,1) ) * nMult
	nMult+=1
	If nMult == 10
		nMult := 2
	EndIf
Next nFor

nResto := nSoma%11

If !lBarra
	If nResto == 0
		cRet := '1'
	ElseIf nResto == 1
		cRet := '0'
	Else
		cRet := Str(11-nResto,1)
	EndIf
Else
	If nResto == 0 .or. nResto == 10 .or. nResto = 1
		cRet := '1'
	Else
		cRet := Str(11-nResto,1)
	EndIf
EndIf
Return( cRet )


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ NNumCITI   º Autor ³ Microsiga          º Data ³ 17/03/2011  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Funcao que gera o Nosso Numero de Acordo com o Banco         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ Banco , Agencia, Conta Corrente e Sub Conta                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³ cNossoNum - Nosso Numero Gerado + Digito Verificador         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³                                                              º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function NNumCiti( cBco , cAge , cCC , cSubcon )
Local aArea     := GetArea()
Local aAreaSEE  := SEE->( GetArea() )
Local cNossoNum := ""

SEE->( DbSetOrder(1) ) //EE_FILIAL+EE_CODIGO+EE_AGENCIA+EE_CONTA+EE_SUBCTA
If SEE->( DbSeek ( xFilial("SEE") + cBco + cAge + cCC + cSubcon) )

	cNossoNum := Soma1( StrZero( Val(SEE->EE_FAXATU), 11 ) )
	cNossoNum += Md11Citi(cNossoNum)

	RecLock( "SEE" , .F. )
	SEE->EE_FAXATU := SubStr(cNossoNum, 1, 11)
	SEE->( MsUnlock() )

Endif

RestArea(aAreaSEE)
RestArea(aArea)

Return ( cNossoNum )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ NNumCEF    º Autor ³Microsiga           º Data ³ 10/09/2011  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Funcao que gera o Nosso Numero de Acordo com o Banco CEF     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ Banco , Agencia, Conta Corrente e Sub Conta                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³ cNossoNum - Nosso Numero Gerado + Digito Verificador         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³                                                              º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function NNumCEF( cBco , cAge , cCC , cSubcon )
Local aArea     := GetArea()
Local aAreaSEE  := SEE->( GetArea() )
Local cNossoNum := ""

SEE->( DbSetOrder(1) ) //EE_FILIAL+EE_CODIGO+EE_AGENCIA+EE_CONTA+EE_SUBCTA
If SEE->( DbSeek ( xFilial("SEE") + cBco + cAge + cCC + cSubcon) )

	cNossoNum := Soma1( StrZero( Val(SEE->EE_FAXATU), 10 ) )
	cNossoNum += Md11Citi(cNossoNum)  // usa o mesmo modulo 11 do citi

	RecLock( "SEE" , .F. )
	SEE->EE_FAXATU := SubStr(cNossoNum, 1, 10)
	SEE->( MsUnlock() )

Endif

RestArea(aAreaSEE)
RestArea(aArea)

Return ( cNossoNum )


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ NNumSant   º Autor ³ Microsiga          º Data ³ 25/04/2011  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Funcao que gera o Nosso Numero de Acordo com o Banco         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ Banco , Agencia, Conta Corrente e Sub Conta                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³ cNossoNum - Nosso Numero Gerado + Digito Verificador         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³                                                              º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function NNumSant( cBco , cAge , cCC , cSubcon )
Local aArea     := GetArea()
Local aAreaSEE  := SEE->( GetArea() )
Local cNossoNum := ""
Local nTamNNum	:= 13
//NNNNNNNNNNNND
//1234567890123

SEE->( DbSetOrder(1) ) //EE_FILIAL+EE_CODIGO+EE_AGENCIA+EE_CONTA+EE_SUBCTA
If SEE->( DbSeek ( xFilial("SEE") + cBco + cAge + cCC + cSubcon) )

	cNossoNum := Soma1( StrZero( Val(SEE->EE_FAXATU), nTamnNum-1 ) )
	cNossoNum += Md11Sant(cNossoNum)

	RecLock( "SEE" , .F. )
	SEE->EE_FAXATU := SubStr(cNossoNum, 1, nTamnNum-1)
	SEE->( MsUnlock() )

Endif

RestArea(aAreaSEE)
RestArea(aArea)

Return ( cNossoNum )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Md11Citi  ºAutor  ³Microsiga           º Data ³  10/06/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Calculo de digito verificar de modulo 11 para o banco      º±±
±±º          ³ CITIBANK                                                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Md11Citi( cData, lBarra )
Local cRet 		:= ""
Local nSoma		:= 0
Local nFor		:= 0
Local nResto 	:= 0
Local nMult 	:= 2
Default lBarra := .F.

For nFor:= Len( cData ) To 1 Step -1
	nSoma += Val( Substr(cData,nFor,1) ) * nMult
	nMult+=1
	If nMult == 10
		nMult := 2
	EndIf
Next nFor

nResto := nSoma%11

If nResto == 0 .or. nResto = 1
	If lBarra
		cRet := '1'
	Else
		cRet := '0'
	EndIf
Else
	cRet := AllTrim(Str(11-nResto,1))
EndIf

Return( cRet )


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Md11Sant  ºAutor  ³Microsiga           º Data ³ 25/04/2011  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Calculo de digito verificar de modulo 11 para o banco      º±±
±±º          ³ CITIBANK                                                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Md11Sant( cData, lBarra )
Local cRet 		:= ""
Local nSoma		:= 0
Local nFor		:= 0
Local nResto 	:= 0
Local nMult 	:= 2
Default lBarra := .F.

For nFor:= Len( cData ) To 1 Step -1
	nSoma += Val( Substr(cData,nFor,1) ) * nMult
	nMult+=1
	If nMult == 10
		nMult := 2
	EndIf
Next nFor

nSoma		:= nSoma*10
nResto	:= nSoma%11

If nResto == 10 .or. nResto == 0 .or. nResto == 1
	cRet := "1"
Else
	cRet := AllTrim(Str(nResto,1))
EndIf

Return( cRet )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³RetBarCiti³ Autor ³ Microsiga             ³ Data ³ 29/11/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ IMPRESSAO DO BOLETO LASER                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function RetBarCiti(cBanco, nValor, dVencimento, cNossoNum, cMoeda, cCosmos, cProduto, cPortfolio)
//Calculos dos demais valores
Local cFatVenc	:= StrZero(dVencimento - CtoD("07/10/1997"),4)
Local cValTit	:= StrZero(nValor*100,10,0)
Local cCampo1	:= ""
Local cCampo2	:= ""
Local cCampo3	:= SubStr(cNossoNum,3)
Local cCampo5	:= cFatVenc+cValTit
Local cBase		:= ""
Local cSequenc	:= ""
Local cDigCosmos:= ""
Local cCodBarra	:= ""
Local cDigCdBar	:= ""
Local cLinDig	:= ""

//Estes valores sao fixos de acordo com o cadastro da empresa no CITIBANK
Default cMoeda 		:= '9'
Default cCosmos		:= '0078387017' //0.078387.01.7
Default cProduto		:= '3'
Default cPortfolio	:= '314'

//Obtem os dados da conta COSMOS
cBase		:= SubStr(cCosmos,2,6)
cSequenc	:= SubStr(cCosmos,8,2)
cDigCosmos	:= Right(cCosmos,1)

//Calculo do codigo de barras
cCodBarra	:= cBanco+cMoeda+cFatVenc+cValTit+cProduto+cPortfolio+cBase+cSequenc+cDigCosmos+cNossoNum
cDigCdBar	:= Md11Citi(cCodBarra, .T. )
cCodBarra := SubStr(cCodBarra,1,4)+cDigCdBar+SubStr(cCodBarra,5)

//Montando a linha digitavel
cCampo1		:= cBanco+cMoeda+cProduto+cPortfolio+SubStr(cBase,1,1)
cCampo2		:= SubStr(cBase,2,5)+cSequenc+cDigCosmos+SubStr(cNossoNum,1,2)
cLinDig		:= Transform(cCampo1+Str(Modulo10(cCampo1),1),'@R 99999.99999')+Space(2)
cLinDig		+= Transform(cCampo2+Str(Modulo10(cCampo2),1),'@R 99999.999999')+Space(2)
cLinDig		+= Transform(cCampo3+Str(Modulo10(cCampo3),1),'@R 99999.999999')+Space(3)
cLinDig		+= cDigCdBar+Space(3)
cLinDig		+= cCampo5

Return({cCodBarra,cLinDig,cNossoNum})

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³RetBarSant³ Autor ³ Microsiga             ³ Data ³ 25/04/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ IMPRESSAO DO BOLETO LASER                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function RetBarSant(cBanco, nValor, dVencimento, cNossoNum, cMoeda, cCodCedente, cCarteira)
//Calculos dos demais valores
Local cFatVenc	:= StrZero(dVencimento - CtoD("07/10/1997"),4)
Local cValTit	:= StrZero(nValor*100,10,0)
Local cCampo1	:= ""
Local cCampo2	:= ""
Local cCampo3	:= SubStr(cNossoNum,8,6)
Local cIOS		:= "0"
Local cCampo5	:= cFatVenc+cValTit
Local cCodBarra	:= ""
Local cDigCdBar	:= ""
Local cLinDig	:= ""

//Estes valores sao fixos de acordo com o cadastro da empresa no CITIBANK
Default cMoeda 		:= '9'
Default cCodCedente	:= '4635329' //'02059851'
Default cCarteira		:= '101'

/*
Posição Tamanho Picture 	Conteudo
01-03 		3 	9 (03) 		Identificação do Banco = 033
04-04 		1 	9 (01) 		Código da moeda = 9 (real)
05-05  		1 	9 (01) 		DV do código de barras (cálculo abaixo)
06-09 		4 	9 (04) 		Fator de vencimento
10-19 		10 	9 (08)V99 	Valor nominal
20-20 		1 	9 (01) 		Fixo “9”
21-27 		7 	9 (07) 		Código do cedente padrão Santander Banespa
28-40 		13 	9 (13) 		Nosso Número
41-41 		1 	9 (01) 		IOS – Seguradoras (Se 7% informar 7. Limitado a 9%) Demais clientes usar 0 (zero)
42-44 		3 	9 (03) 		Tipo de Modalidade Carteira
				101-Cobrança Simples Rápida COM Registro
				102- Cobrança simples – SEM Registro
				201- Penhor Rápida com Registro
*/

//Calculo do codigo de barras
cCodBarra	:= cBanco+cMoeda+cFatVenc+cValTit+cMoeda+SubStr(cCodCedente,1,7)+cNossoNum+cIOS+cCarteira
cDigCdBar	:= Md11Sant(cCodBarra, .T. )
cCodBarra 	:= SubStr(cCodBarra,1,4)+cDigCdBar+SubStr(cCodBarra,5)

//Montando a linha digitavel
cCampo1		:= cBanco+cMoeda+'9'+SubStr(cCodCedente,1,4)
//cCampo1		+= Str(Modulo10(cCampo1),1)

cCampo2		:= SubStr(cCodCedente,5,3)+SubStr(cNossoNum,1,7)
//cCampo2		+= Str(Modulo10(cCampo2),1)

cCampo3 		:= SubStr(cNossoNum,8,6)+cIOS+SubStr(cCarteira,1,3)
//cCampo3		+= Str(Modulo10(cCampo3),1)

cCampo4		:= cDigCdBar

cLinDig		:= Transform(cCampo1+Str(Modulo10(cCampo1),1),'@R 99999.99999')		+	Space(2)
cLinDig		+= Transform(cCampo2+Str(Modulo10(cCampo2),1),'@R 99999.999999')	+	Space(2)
cLinDig		+= Transform(cCampo3+Str(Modulo10(cCampo3),1),'@R 99999.999999')	+	Space(3)
cLinDig		+= cDigCdBar+Space(3)
cLinDig		+= cCampo5

Return({cCodBarra,cLinDig,cNossoNum})


Static Function GetParcela(cCond)
Local nRet := 0
Local aRet := Condicao(1000,cCond)
nRet := Max(Len(aRet),1)

Return(nRet)
                










Static Function AjustaSX1( cPerg )

	Local aCposSX1	:= {}
	Local nX 		:= 0
	Local lAltera	:= .F.
	//.Local nCondicao
	Local cKey		:= ""
	Local nJ		:= 0 
	Local aPergs    := {}
	
	aCposSX1:={"X1_PERGUNT","X1_PERSPA","X1_PERENG","X1_VARIAVL","X1_TIPO","X1_TAMANHO",;
				"X1_DECIMAL","X1_PRESEL","X1_GSC","X1_VALID",;
				"X1_VAR01","X1_DEF01","X1_DEFSPA1","X1_DEFENG1","X1_CNT01",;
				"X1_VAR02","X1_DEF02","X1_DEFSPA2","X1_DEFENG2","X1_CNT02",;
				"X1_VAR03","X1_DEF03","X1_DEFSPA3","X1_DEFENG3","X1_CNT03",;
				"X1_VAR04","X1_DEF04","X1_DEFSPA4","X1_DEFENG4","X1_CNT04",;
				"X1_VAR05","X1_DEF05","X1_DEFSPA5","X1_DEFENG5","X1_CNT05",;
				"X1_F3", "X1_GRPSXG", "X1_PYME","X1_HELP" }
	
	Aadd(aPergs,{"De Prefixo"		,"","","mv_ch1","C",3,0,0,"G","","MV_PAR01","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	Aadd(aPergs,{"Ate Prefixo"		,"","","mv_ch2","C",3,0,0,"G","","MV_PAR02","","","","ZZZ","","","","","","","","","","","","","","","","","","","","","","","","",""})
	Aadd(aPergs,{"De Numero"		,"","","mv_ch3","C",9,0,0,"G","","MV_PAR03","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	Aadd(aPergs,{"Ate Numero"		,"","","mv_ch4","C",9,0,0,"G","","MV_PAR04","","","","ZZZZZZ","","","","","","","","","","","","","","","","","","","","","","","","",""})
	Aadd(aPergs,{"De Parcela"		,"","","mv_ch5","C",2,0,0,"G","","MV_PAR05","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	Aadd(aPergs,{"Ate Parcela"		,"","","mv_ch6","C",2,0,0,"G","","MV_PAR06","","","","Z","","","","","","","","","","","","","","","","","","","","","","","","",""})
	Aadd(aPergs,{"De Portador"		,"","","mv_ch7","C",3,0,0,"G","","MV_PAR07","","","","","","","","","","","","","","","","","","","","","","","","","SA6","","","",""})
	Aadd(aPergs,{"Ate Portador"		,"","","mv_ch8","C",3,0,0,"G","","MV_PAR08","","","","ZZZ","","","","","","","","","","","","","","","","","","","","","SA6","","","",""})
	Aadd(aPergs,{"De Cliente"		,"","","mv_ch9","C",6,0,0,"G","","MV_PAR09","","","","","","","","","","","","","","","","","","","","","","","","","SE1","","","",""})
	Aadd(aPergs,{"De Loja"			,"","","mv_cha","C",2,0,0,"G","","MV_PAR10","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	Aadd(aPergs,{"Ate Cliente"		,"","","mv_chb","C",6,0,0,"G","","MV_PAR11","","","","ZZZZZZ","","","","","","","","","","","","","","","","","","","","","SE1","","","",""})
	Aadd(aPergs,{"Ate Loja"			,"","","mv_chc","C",2,0,0,"G","","MV_PAR12","","","","ZZ","","","","","","","","","","","","","","","","","","","","","","","","",""})
	Aadd(aPergs,{"De Emissao"		,"","","mv_chd","D",8,0,0,"G","","MV_PAR13","","","","01/01/80","","","","","","","","","","","","","","","","","","","","","","","","",""})
	Aadd(aPergs,{"Ate Emissao"		,"","","mv_che","D",8,0,0,"G","","MV_PAR14","","","","31/12/03","","","","","","","","","","","","","","","","","","","","","","","","",""})
	Aadd(aPergs,{"Carteira"			,"","","mv_chf","C",2,0,0,"C","","MV_PAR15","02=Sem Registro","","","","","09=Registrada","","","","","","","","","","","","","","","","","","","","","","",""})

	cPerg := Padr( cPerg, 10 )   
	
	DbSelectArea("SX1")
	DbSetOrder(1)
	For nX:=1 to Len(aPergs)
		lAltera := .F.
		If MsSeek(cPerg+Right(aPergs[nX][11], 2))
			If (ValType(aPergs[nX][Len(aPergs[nx])]) = "B" .And.;
				 Eval(aPergs[nX][Len(aPergs[nx])], aPergs[nX] ))
				aPergs[nX] := ASize(aPergs[nX], Len(aPergs[nX]) - 1)
				lAltera := .T.
			Endif
		Endif
		
		If ! lAltera .And. Found() .And. X1_TIPO <> aPergs[nX][5]	
	 		lAltera := .T.		// Garanto que o tipo da pergunta esteja correto
	 	Endif	
		
		If ! Found() .Or. lAltera
			RecLock("SX1",If(lAltera, .F., .T.))
			Replace X1_GRUPO with cPerg
			Replace X1_ORDEM with Right(aPergs[nX][11], 2)
			For nj:=1 to Len(aCposSX1)
				If 	Len(aPergs[nX]) >= nJ .And. aPergs[nX][nJ] <> Nil .And.;
					FieldPos(AllTrim(aCposSX1[nJ])) > 0
					Replace &(AllTrim(aCposSX1[nJ])) With aPergs[nx][nj]
				Endif
			Next nj
			MsUnlock()
			cKey := "P."+AllTrim(X1_GRUPO)+AllTrim(X1_ORDEM)+"."
	
			If ValType(aPergs[nx][Len(aPergs[nx])]) = "A"
				aHelpSpa := aPergs[nx][Len(aPergs[nx])]
			Else
				aHelpSpa := {}
			Endif
			
			If ValType(aPergs[nx][Len(aPergs[nx])-1]) = "A"
				aHelpEng := aPergs[nx][Len(aPergs[nx])-1]
			Else
				aHelpEng := {}
			Endif
	
			If ValType(aPergs[nx][Len(aPergs[nx])-2]) = "A"
				aHelpPor := aPergs[nx][Len(aPergs[nx])-2]
			Else
				aHelpPor := {}
			Endif
	
			PutSX1Help(cKey,aHelpPor,aHelpEng,aHelpSpa)
		Endif
	Next

Return()
                


User Function BolPdfLg()

	Local aLegenda := {}
	Local aArea    := GetArea()

	AADD(aLegenda,{"BR_VERDE" 	,"Impresso" })
	AADD(aLegenda,{"BR_AMARELO" ,"Não Impresso" })

	BrwLegenda(cCadastro, "Legenda", aLegenda)

	RestArea( aArea )	
Return(.T. )

                
Static Function BcoByFil()
	Local aRet	:= {}
    Local cTbA6 := GetNextAlias()               
    
	BeginSql ALIAS cTbA6            
		SELECT * FROM %table:SA6%
        	WHERE A6_FILIAL = %exp:xFilial("SA6")%
        	AND A6_XBOLETO = 'S'           
			AND %notdel%	
	EndSql

	While (cTbA6)->(!Eof())
		If cFilAnt $ (cTbA6)->A6_XFILBOL
			aRet := {	(cTbA6)->A6_COD				   	                		,;		// [1]Numero do Banco
						(cTbA6)->A6_NOME	       				                ,; 		// [2]Nome do Banco
						Substr((cTbA6)->A6_AGENCIA, 1, 5)                    	,;		// [3]Agência
						AllTrim((cTbA6)->A6_NUMCON)								,; 		// [4]Conta Corrente
						Substr((cTbA6)->A6_NUMCON,Len(AllTrim((cTbA6)->A6_NUMCON)),1),; // [5]Dígito da conta corrente
				  		(cTbA6)->A6_CARTEIR										,;  	// [6]Codigo da Carteira
						0					 									}		// [7]Tx de Mora Diaria

		EndIf	     
		(cTbA6)->(DbSkip())		
	EndDo

Return( aRet )


                
User Function xGetNNum( cBco, cPrefixo, cNumero, cParcela, cCart, nBanco )

	Local nNNum		:= ""
	Local nParc		:= 0
	Local nDig		:= 0
	Local nRst     	:= 0
	Local nMlt     	:= { 2, 7, 6, 5, 4, 3, 2, 7, 6, 5, 4, 3, 2 }
	Local n			:= 0

	If cBco == "237"
		
		cCart := Right(AllTrim(cCart),2)
	
		nNNum := cCart
			// Carteira
		If Val( cPrefixo ) == 0  
			cPrefixo := Asc(cPrefixo)
			cPrefixo -= 64
			cPrefixo := "1"+StrZero(cPrefixo,2)
			nNNum += cPrefixo	
		Else
			nNNum += StrZero( Val( cPrefixo ), 3 )   // Converter um numérico em uma string com zeros a esquerda.
		EndIf
		nNNum += cNumero 
		
		If !Empty(cParcela)
			nParc := Asc( cParcela )
			nParc -= 64
			nParc := StrZero( nParc, 2 )
			nNNum  += nParc
		Else
			nNNum += '00'   /* Parcela Unica */
		EndIf
		
		nBanco := Substr( nNNum,  3, 9 )
		nBanco += Substr( nNNum, 13, 1 )
		
		nDig := 0
		
		For n := 1 To 13
			nRst := Val( Substr( nNNum, n, 1 ) )
			nRst *= nMlt[ n ]
			nDig += nRst
		Next
		
		nRst := Mod( nDig, 11 )
		
		If nRst <> 0
			nDig := 11
			nDig -= nRst
			
			If nDig <> 10
				nDig := StrZero( nDig, 1 )
			Else
				nDig := 'P'
			EndIf
		Else
			nDig := '0'
		End
		
		nNNum += nDig
		nNNum := Substr( nNNum, 3 )

	Elseif cBco == "341"
		cCart := Right(AllTrim(cCart),2)
	
		nNNum := cCart
			// Carteira
		If Val( cPrefixo ) == 0  
			cPrefixo := Asc(cPrefixo)
			cPrefixo -= 64
			cPrefixo := "1"+StrZero(cPrefixo,2)
			nNNum += cPrefixo	
		Else
			nNNum += StrZero( Val( cPrefixo ), 3 )   // Converter um numérico em uma string com zeros a esquerda.
		EndIf
		nNNum += cNumero 
		
		If !Empty(cParcela)
			nParc := Asc( cParcela )
			nParc -= 64
			nParc := StrZero( nParc, 2 )
			nNNum  += nParc
		Else
			nNNum += '00'   /* Parcela Unica */
		EndIf
		
		nBanco := Substr( nNNum,  3, 9 )
		nBanco += Substr( nNNum, 13, 1 )
		
		nDig := 0
		
		For n := 1 To 13
			nRst := Val( Substr( nNNum, n, 1 ) )
			nRst *= nMlt[ n ]
			nDig += nRst
		Next
		
		nRst := Mod( nDig, 11 )
		
		If nRst <> 0
			nDig := 11
			nDig -= nRst
			
			If nDig <> 10
				nDig := StrZero( nDig, 1 )
			Else
				nDig := 'P'
			EndIf
		Else
			nDig := '0'
		End
		
		nNNum += nDig
		nNNum := Substr( nNNum, 3 )
	EndIf
	
Return(nNNum)


User Function xxbol()
	Local aLabel := {}

	RpcSetEnv("01","01")
	RpcSetType(3)
	
	DbSelectArea("SE1")
	DbSetOrder(1)
	DbGoTo(686532)

//	U_OUROXBOL()


	aLabel := {}
	Aadd(aLabel,{SE1->E1_NUM,SE1->E1_PREFIXO,SE1->E1_PREFIXO,SE1->E1_PARCELA,SE1->E1_CLIENTE,SE1->E1_LOJA, "02"})
	U_MYBOLPDF(aLabel,.T.)
  
/*
	SE1->(DbSkip())
	aLabel := {}	
	Aadd(aLabel,{SE1->E1_NUM,SE1->E1_PREFIXO,SE1->E1_PREFIXO,SE1->E1_PARCELA,SE1->E1_CLIENTE,SE1->E1_LOJA, "02"})
	U_MYBOLPDF(aLabel,.F.)
	
	SE1->(DbSkip())
	aLabel := {}
	Aadd(aLabel,{SE1->E1_NUM,SE1->E1_PREFIXO,SE1->E1_PREFIXO,SE1->E1_PARCELA,SE1->E1_CLIENTE,SE1->E1_LOJA, "02"})
	U_MYBOLPDF(aLabel,.F.)
*/		
Return( nil )	


User Function MyMod11( cCod , nInd )
	Local cRet 		:= ""             
	Local Nx 		:= 0
	//.Local Ny 		:= 0
	Local nRes1		:= 0
	Local nRes2		:= 0
	Local cRegua	:= "4329876543298765432987654329876543298765432"
	
	Default cCod	:= "0000000000000000000000000000000000000000000"
	
	For Nx := 1 To Len(cRegua)	
		nRes1	+= Val(Substr(cRegua,Nx,1)) * Val(Substr(cCod,Nx,1))

	Next
	nRes2 := Mod( nRes1, 11 )
	nRes2 := 11 - nRes2
	
	If nRes2 == 0 .Or. nRes2 > 9
		cRet  := "1"	
	Else
		cRet  := cValToChar( nRes2 )	
	EndIf
	
Return( cRet )



/*/{Protheus.doc} GetEndFil
Rotina que busca o endereço do beneficiario para impressão no boleto

@type 		function
@author 	Roberto Souza
@since 		25/09/2017
@version 	P12 
 
@return nil
/*/ 
Static Function GetEndFil( cCodFil ) 
	Local aArea := SM0->(GetArea())
	Local cRet 	:= ""

	DbSelectArea("SM0")
	If DbSeek(cEmpAnt+cCodFil)
//		cRet := AllTrim(SM0->M0_ENDENT) + " - "+ AllTrim(SM0->M0_BAIRENT) +" - "+ AllTrim(SM0->M0_CIDENT)+"/"+AllTrim(SM0->M0_ESTENT)
		cRet := AllTrim(SM0->M0_ENDCOB) + " - " +AllTrim(SM0->M0_BAIRCOB) +" - "+ AllTrim(SM0->M0_CIDCOB)+"/"+SM0->M0_ESTCOB
	EndIf  

	DbSeek(cEmpAnt+cFilAnt)
	RestArea(aArea)

Return( cRet )	
                


/*/{Protheus.doc} xSetBol
Rotina principal que habilita os titulos para impressão de boleto baseado no campo E1_XBOLETO

@type 		function
@author 	Roberto Souza
@since 		25/09/2017
@version 	P12 
 
@return nil
/*/    
User Function xSetBol( oMainBol, oMark )
	Local lRet 		:= .T.             
	Local oArea		:= FWLayer():New()
	Local aCoord	:= {0,0,550,1300}
	//.Local lMDI		:= oAPP:lMDI
	Local oSubBol
	
	//.Local cCodCart  := ""
	//.Local nOpcA		:= 0
	//.Local bOk		:= {|| Alert("Ok")}
	Local bGeraBol	:= {|| U_xSetBolW( oLbx, @aTit ), oLbx:Refresh() }
	Local bBusca	:= {|| U_xSetBolX( oLbx, @aTit ), oLbx:Refresh() }
	Local bCancel	:= {|| oSubBol:End() }
	//.Local aButtons	:= {}
	//.Local aTamCpo	:= {}
	Local aLin		:= {}
	Local nLin      := 0
	//.Local nTamLin	:= 15	    
    
	Local aTit		:= {}
	Local oFont		:= TFont():New("Arial",08,12,,.T.,,,,.T.)

	Private oOk 	:= LoadBitmap(GetResources(),"ENABLE")
	Private oNo 	:= LoadBitmap(GetResources(),"DISABLE")

	Private cPref 	:= Space(TamSx3("E1_PREFIXO")[01])
	Private cTit  	:= Space(TamSx3("E1_NUM")[01])
	Private cCodCli	:= Space(TamSx3("E1_CLIENTE")[01])
	Private cLojCli	:= Space(TamSx3("E1_LOJA")[01])

	aCoord[3] *= 0.75
	aCoord[4] *= 0.7

	oSubBol := tDialog():New(aCoord[1],aCoord[2],aCoord[3],aCoord[4],OemToAnsi("Habilitar Boleto")+"-"+COMP_DATE,,,,,CLR_BLACK,CLR_WHITE,,,.T.)
	oArea:Init(oSubBol,.F.)
	//Mapeamento da area
	oArea:AddLine("L01",100,.T.)

	//ÚÄÄÄÄÄÄÄÄÄ¿
	//³Colunas  ³
	//ÀÄÄÄÄÄÄÄÄÄÙ
	oArea:AddCollumn("L01C01A",20,.F.,"L01") //dados
	oArea:AddCollumn("L01C01B",70,.F.,"L01") //dados
	oArea:AddCollumn("L01C02" ,10,.F.,"L01") //botoes

	//ÚÄÄÄÄÄÄÄÄÄ¿
	//³Paineis  ³
	//ÀÄÄÄÄÄÄÄÄÄÙ
	oArea:AddWindow("L01C01A","PARAM","Parametros",100,.F.,.F.,/*bAction*/,"L01",/*bGotFocus*/)
	oParam	:= oArea:GetWinPanel("L01C01A","PARAM","L01")

	oArea:AddWindow("L01C01B","LIST","Lista",100,.F.,.F.,/*bAction*/,"L01",/*bGotFocus*/)
	oList	:= oArea:GetWinPanel("L01C01B","LIST","L01")

	oArea:AddWindow("L01C02","L01C02P01","Funções",100,.F.,.F.,/*bAction*/,"L01",/*bGotFocus*/)
	oAreaBut := oArea:GetWinPanel("L01C02","L01C02P01","L01")

	aLin  := {}    
	nTamL := 15
	nIniL := 2
	nDif  := 4
	nCpo  := 8	
	
	aCol := {000,030}
	
	AADD( aLin , 000 )

	For nLin := 1  To 10
		AADD( aLin , (nTamL * nLin) + nIniL )		
	Next
       
	aTit		:= {{.F.,;
					Space(3),;
					Space(9),;
					Space(3),;
					Space(6),;
					Space(2),;
					Stod(Space(8)),;
					0,;
					Stod(Space(8)),;
					}}


	aTitCampos	:= {"  "		,;
					"Pref."		,;
					"Titulo"	,;
					"Tipo"		,;
					"Cliente"	,;
					"Loja"		,;
					"Emissão"	,;
					"Valor"		,;
					"Venc. Real"}
 
	@ aLin[01]+nDif	,aCol[01]  SAY "Prefixo"	FONT oFont COLOR CLR_BLUE Of oParam PIXEL
	@ aLin[01]  	,aCol[02]  MSGET cPref 		PICTURE PesqPict( "SE1", "E1_PREFIXO" ) SIZE 015,nCpo Of oParam PIXEL 

	@ aLin[02]+nDif	,aCol[01]  SAY "Numero" 	FONT oFont COLOR CLR_BLUE Of oParam PIXEL
	@ aLin[02]  	,aCol[02]  MSGET cTit 		PICTURE PesqPict( "SE1", "E1_NUM" )  	SIZE 040,nCpo Of oParam PIXEL

	@ aLin[03]+nDif	,aCol[01]  SAY "Cliente" 	FONT oFont COLOR CLR_BLUE Of oParam PIXEL
	@ aLin[03]  	,aCol[02]  MSGET cCodCli	PICTURE PesqPict( "SE1", "E1_CLIENTE" )	F3 "SA1" SIZE 020,nCpo Of oParam PIXEL

	@ aLin[04]+nDif	,aCol[01]  SAY "Loja" 		FONT oFont COLOR CLR_BLUE Of oParam PIXEL
	@ aLin[04]  	,aCol[02]  MSGET cLojCli	PICTURE PesqPict( "SE1", "E1_LOJA" )  	SIZE 010,nCpo Of oParam PIXEL

	oButtB := tButton():New(aLin[05],000,"&Buscar"			,oParam,bBusca		,oParam:nClientWidth/2,15,,/*oFont*/,,.T.,,,,/*bWhen*/)

	oButtB:Align	:= CONTROL_ALIGN_BOTTOM
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Painel 02-Registros         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oLbx := TWBrowse():New( 000, 000, 400, 600,,aTitCampos,,oList,,,,,,,,,,,,.F.,,.T.,,.F.,,,)

	oLbx:SetArray( aTit )
	oLbx:bLine 	:= {|| {Iif(aTit[oLbx:nAt][01],oOk,oNo),;
					   	aTit[oLbx:nAt][02],;
					   	aTit[oLbx:nAt][03],;
					   	aTit[oLbx:nAt][04],;
					   	aTit[oLbx:nAt][05],;
					   	aTit[oLbx:nAt][06],;
					   	aTit[oLbx:nAt][07],;					   							   							   		
					   	aTit[oLbx:nAt][08],;
			   		   	aTit[oLbx:nAt][09]}}

	oLbx:Align	:= CONTROL_ALIGN_ALLCLIENT

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Painel 03-Botoes            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oButt1 := tButton():New(000,000,"&Habilitar"		,oAreaBut,bGeraBol		,oAreaBut:nClientWidth/2,15,,/*oFont*/,,.T.,,,,/*bWhen*/)
	oButt2 := tButton():New(016,000,"&Fechar"			,oAreaBut,bCancel		,oAreaBut:nClientWidth/2,15,,/*oFont*/,,.T.,,,,/*bWhen*/)

	oSubBol:Activate(,,,.T.,/*valid*/,,/*On Init*/)

Return( lRet )

   



/*/{Protheus.doc} xSetBolX
Rotina que busca os titulos conforme os parametros e atualiza o grid lateral.
Necessário estar alimentadas as variaveis cPref,cTit,cCodCli,cLojCli
Chamada pela função xSetBol

@type 		function
@author 	Roberto Souza
@since 		25/09/2017
@version 	P12 
 
@return nil
/*/ 
User Function xSetBolX( oLbx, aTit ) 
	Local aArea 	:= GetArea()                       
	Local cKeyE1    := ""

	If !Empty(cPref) .And. !Empty(cTit) .And. !Empty(cCodCli) .And. !Empty(cLojCli)
		
		cKeyE1 := xFilial("SE1")+ cCodCli + cLojCli + cPref + cTit
		
		DbSelectArea("SE1")
		DbSetOrder(2) // E1_FILIAL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM          
		
		If SE1->( DbSeek( cKeyE1 ))
			aTit := {}	    	
	    	While SE1->(E1_FILIAL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM) == cKeyE1 .And. SE1->(!Eof())
				AADD(aTit, {Empty(SE1->E1_XBOLETO) ,;
							SE1->E1_PREFIXO	,;
							SE1->E1_NUM		,;
							SE1->E1_TIPO	,;
							SE1->E1_CLIENTE	,;
							SE1->E1_LOJA	,;
							SE1->E1_EMISSAO	,;
							SE1->E1_VALOR	,;
							SE1->E1_VENCREA	,;
							SE1->(Recno())})
				SE1->( DbSkip() )						
			EndDo
		Else
			aTit := {}
			AADD(aTit, {.F.,;
						Space(3),;
						Space(9),;
						Space(3),;
						Space(6),;
						Space(2),;
						Stod(Space(8)),;
						0,;
						Stod(Space(8)),;
						})		
		EndIf					   		   	

		oLbx:SetArray( aTit )

		oLbx:bLine 	:= {|| {Iif(aTit[oLbx:nAt][01],oOk,oNo),;
						   	aTit[oLbx:nAt][02],;
						   	aTit[oLbx:nAt][03],;
						   	aTit[oLbx:nAt][04],;
						   	aTit[oLbx:nAt][05],;
						   	aTit[oLbx:nAt][06],;
						   	aTit[oLbx:nAt][07],;					   							   							   		
						   	aTit[oLbx:nAt][08],;
				   		   	aTit[oLbx:nAt][09]}}
		oLbx:Refresh()
	Else
		Aviso("Boleto","preencha todos os parametros",{"Ok"})
	EndIf
	
	RestArea( aArea )
Return()
 

/*/{Protheus.doc} xSetBolW
Rotina confirma a gravação e chama a impressão do boleto.
Chamada pela função xSetBol

@type 		function
@author 	Roberto Souza
@since 		25/09/2017
@version 	P12 
 
@return nil
/*/ 
User Function xSetBolW( oLbx, aTit ) 
	Local aArea 	:= GetArea()                       
	//.Local cKeyE1    := ""
	Local Nx 		:= 0       
	Local nPosRec	:= Len( aTit[01] )
	Local aLabel	:= {}                      
	Local lOk 		:= .F.
	
	Private aBcoBol	:= BcoByFil() // Retorna Parametros para Boleto	

	For Nx := 1 To Len( aTit )
		If aTit[Nx][01]   
			lOk := .T.
		EndIf
	Next	
	
	If lOk
	    lImprime := VldImp()                
	EndIf    


	For Nx := 1 To Len( aTit )
		If aTit[Nx][01]
	 		DbSelectArea("SE1")                             
			SE1->(DbGoTo( aTit[Nx][nPosRec] ))
	
			If lImprime
			
				If Empty(SE1->E1_NUMBCO)
					aTit[Nx][01] := .F. 
					lUpd := .T.

					nBanco := 0
					RecLock( "SE1", .F. ) 
					
					SE1->E1_XBOLETO := "1"
					SE1->E1_NUMBCO  := U_xGetNNum( aBcoBol[01], SE1->E1_PREFIXO,SubStr(SE1->E1_NUM,4,6),SE1->E1_PARCELA, aBcoBol[06], @nBanco )
					SE1->E1_PORTADO := aBcoBol[01]
					SE1->E1_AGEDEP  := aBcoBol[03]
					SE1->E1_CONTA   := aBcoBol[04]
					
					SE1->( MSUnLock() )

	
					Aadd(aLabel,{	SE1->E1_NUM		,;
									SE1->E1_PREFIXO	,;
									SE1->E1_PREFIXO	,;
									SE1->E1_PARCELA	,;
									SE1->E1_CLIENTE	,;
									SE1->E1_LOJA	,;
									aBcoBol[06]})	
				EndIf			
			Else

				RecLock("SE1",.F.)		
				SE1->E1_XBOLETO := "1"
				MsUnlock()
				aTit[Nx][01] := .F. 
				lUpd := .T.
												
			EndIf
		EndIf			
	Next	   		   	

	oLbx:SetArray( aTit )

	oLbx:bLine 	:= {|| {Iif(aTit[oLbx:nAt][01],oOk,oNo),;
					   	aTit[oLbx:nAt][02],;
					   	aTit[oLbx:nAt][03],;
					   	aTit[oLbx:nAt][04],;
					   	aTit[oLbx:nAt][05],;
					   	aTit[oLbx:nAt][06],;
					   	aTit[oLbx:nAt][07],;					   							   							   		
					   	aTit[oLbx:nAt][08],;
			   		   	aTit[oLbx:nAt][09]}}
	oLbx:Refresh()

	If !Empty(aLabel) .And. Aviso("Impressão","Impressão de boleto habilitada."+CRLF+"Deseja imprimir agora?",{"Sim","Não"},1) == 1
		U_MYBOLPDF( aLabel )
	EndIf
        
	RestArea( aArea )
Return()

/*
+-----------+----------+-------+--------------------+------+-------------+
| Programa  |BOLITAU   |Autor  |Microsiga           | Data |  11/21/05   |
+-----------+----------+-------+--------------------+------+-------------+
| Desc.     |Obtenção da linha digitavel/codigo de barras                |
|           |                                                            |
+-----------+------------------------------------------------------------+
| Uso       | AP                                                         |
+-----------+------------------------------------------------------------+
*/
Static Function fLinhaDig (cCodBanco, ; // Codigo do Banco (341)
cCodMoeda, ; // Codigo da Moeda (9)
cCarteira, ; // Codigo da Carteira
cAgencia , ; // Codigo da Agencia
cConta   , ; // Codigo da Conta
cDvConta , ; // Digito verificador da Conta
nValor   , ; // Valor do Titulo
dVencto  , ; // Data de vencimento do titulo
cNroDoc   )  // Numero do Documento Ref ao Contas a Receber

Local cValorFinal   := StrZero(int(nValor*100),10)
Local cFator        := StrZero(dVencto - CtoD("07/10/97"),4)   // Local cFator        := StrZero(dVencto - CtoD("07/10/97"),4)
Local cCodBar   	:= Replicate("0",43)
Local cCampo1   	:= Replicate("0",05)+"."+Replicate("0",05)
Local cCampo2   	:= Replicate("0",05)+"."+Replicate("0",06)
Local cCampo3   	:= Replicate("0",05)+"."+Replicate("0",06)
Local cCampo4   	:= Replicate("0",01)
Local cCampo5   	:= Replicate("0",14)
Local cTemp     	:= ""
Local cNossoNum 	:= LEFT(AllTrim(SE1->E1_NUMBCO),8) // Nosso numero
Local cDV			:= "" // Digito verificador dos campos
Local cLinDig		:= ""
/*
-------------------------
Definicao do NOSSO NUMERO
-------------------------
*/
If At("-",cConta) > 0
	cDig   := Right(AllTrim(cConta),1)
	cConta := AllTrim(Str(Val(Left(cConta,At('-',cConta)-1) + cDig)))
Else
	cConta := AllTrim(Str(Val(cConta)))
Endif
cNossoNum   := Alltrim(cAgencia) + Left(Alltrim(cConta),5) + Right(alltrim(cConta),1) + cCarteira + LEFT(AllTrim(SE1->E1_NUMBCO),8) //cNroDoc
cDvNN 		:= Str(modulo10(Alltrim(SEE->EE_AGENCIA)+Alltrim(SEE->EE_CONTA)+cCarteira+LEFT(AllTrim(SE1->E1_NUMBCO),8)),1)  //Alltrim(Str(Modulo10(cNossoNum)))
cNossoNum   := cCarteira + cNroDoc + cDvNN
//cNossoNum   := cCarteira + cNroDoc + '-' + cDvNN
/*
-----------------------------
Definicao do CODIGO DE BARRAS
-----------------------------
*/
//Alltrim(cNroDoc)              + ; // 23 a 30

cTemp := Alltrim(cCodBanco)            	+ ; // 01 a 03
Alltrim(cCodMoeda)            			+ ; // 04 a 04	
Alltrim(cFator)               			+ ; // 06 a 09
Alltrim(cValorFinal)          			+ ; // 10 a 19
Alltrim(cCarteira)            			+ ; // 20 a 22
LEFT(AllTrim(SE1->E1_NUMBCO),8) 		+ ; // 23 A 30
Alltrim(cDvNN)                			+ ; // 31 a 31
Alltrim(cAgencia)             			+ ; // 32 a 35
Alltrim(Left(cConta,5))               	+ ; // 36 a 40
Alltrim(cDvConta)             			+ ; // 41 a 41
"000"                             			// 42 a 44

cDvCB  := Alltrim(modulo11(cTemp))	// Digito Verificador CodBarras
cCodBar:= SubStr(cTemp,1,4) + cDvCB + SubStr(cTemp,5)// + cDvNN + SubStr(cTemp,31)

/*
-----------------------------------------------------
Definicao da LINHA DIGITAVEL (Representacao Numerica)
-----------------------------------------------------

Campo 1			Campo 2			Campo 3			Campo 4		Campo 5
AAABC.CCDDX		DDDDD.DDFFFY	FGGGG.GGHHHZ	K			UUUUVVVVVVVVVV

CAMPO 1:
AAA = Codigo do banco na Camara de Compensacao
B = Codigo da moeda, sempre 9
CCC = Codigo da Carteira de Cobranca
DD = Dois primeiros digitos no nosso numero
X = DAC que amarra o campo, calculado pelo Modulo 10 da String do campo
*/
cTemp   := cCodBanco + cCodMoeda + cCarteira + Substr(LEFT(AllTrim(SE1->E1_NUMBCO),8),1,2)
cDV		:= Alltrim(Str(Modulo10(cTemp)))
cCampo1 := SubStr(cTemp,1,5) + '.' + Alltrim(SubStr(cTemp,6)) + cDV + Space(2)
/*
CAMPO 2:
DDDDDD = Restante do Nosso Numero
E = DAC do campo Agencia/Conta/Carteira/Nosso Numero
FFF = Tres primeiros numeros que identificam a agencia
Y = DAC que amarra o campo, calculado pelo Modulo 10 da String do campo
*/
cTemp	:= Substr(LEFT(AllTrim(SE1->E1_NUMBCO),8),3) + cDvNN + Substr(cAgencia,1,3)
//cDV		:= Str(modulo10(Alltrim(SEE->EE_AGENCIA)+Alltrim(SEE->EE_CONTA)+__cCarteira+Right(AllTrim(SE1->E1_NUMBCO),8)),1)
cDV		:= Alltrim(Str(Modulo10(cTemp)))
cCampo2 := Substr(cTemp,1,5) + '.' + Substr(cTemp,6) + cDV + Space(3)
/*
CAMPO 3:
F = Restante do numero que identifica a agencia
GGGGGG = Numero da Conta + DAC da mesma
HHH = Zeros (Nao utilizado)
Z = DAC que amarra o campo, calculado pelo Modulo 10 da String do campo
*/
cTemp   := Substr(cAgencia,4,1) + Left(cConta,5) + Alltrim(cDvConta) + "000"
cDV		:= Alltrim(Str(Modulo10(cTemp)))
cCampo3 := Substr(cTemp,1,5) + '.' + Substr(cTemp,6) + cDV + Space(2)
/*
CAMPO 4:
K = DAC do Codigo de Barras
*/
cCampo4 := cDvCB + Space(2)
/*
CAMPO 5:
UUUU = Fator de Vencimento
VVVVVVVVVV = Valor do Titulo
*/
cCampo5 := cFator + StrZero(int(nValor * 100),14 - Len(cFator))
cLinDig := cCampo1 + cCampo2 + cCampo3 + cCampo4 + cCampo5
Return {cCodBar, cLinDig, cNossoNum}
