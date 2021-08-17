#INCLUDE "PROTHEUS.CH"

****************************************************************
* O ponto de entrada TMKBARLA é chamado na criação da tela do  *
* Atendimento do Call Center, com o objetivo de incluir botões *
* de usuário na toolbar lateral.                               *
****************************************************************

User Function TMKBARLA(aBtnLat,aTitles)

Local _aBtnLat := {}

If FunName() == "TMKA350" // Atendimento Receptivo.
	If INCLUI .OR. ALTERA      
		
		//_aBtnLat := {{"HISTORIC",{ || ELMHistor() },"Histórico da Cobrança"}}
		
		// I1609-048 Telecobrança - Alterar categoria Titulo
		// Roberto Souza - 18/09/2017
		AADD(_aBtnLat ,{"HISTORIC"	,{ || ELMHistor() },"Histórico da Cobrança"} )
		AADD(_aBtnLat ,{"RECALC"	,{ || AltCateg() } ,"Alterar categoria"} )

	Endif
ElseIf FunName() == "TMKA280" // Pré-Atendimento.
	_aBtnLat := {{"HISTORIC",{ || ELMHistor() },"Histórico da Cobrança"}}
Endif

Return _aBtnLat

Static Function ELMHistor()

Local _oDlg
Local _oTexto1
Local _oTMultiGet
Local lWordWrap := .T. // Variavel que faz a quebra de linha no Objeto TMultiGet.
Public _cTexto1 := SPACE(200)

DEFINE MSDIALOG _oDlg TITLE "Histórico da Cobrança" FROM 0,0 To 180,300 OF oMainWnd PIXEL

	_oTMultiGet:=TMultiGet():New()
	_oTMultiGet:EnableVScroll(.T.)
	               		                                  
	_oTexto1:=TMultiGet():New(003,003,{|U|If(Pcount()>0,_cTexto1:=u,_cTexto1)},_oDlg,145,070,,.T.,,,,.T.,,,{||.T.},,,,,,,.F.,.T.)	                
			                   
	DEFINE SBUTTON FROM 078,122 TYPE 1 ENABLE OF _oDlg ACTION (_oDlg:End()) 
	
ACTIVATE MSDIALOG _oDlg CENTERED

If Empty(M->ACF_OBS)
	M->ACF_OBS += _cTexto1  
Else
    M->ACF_OBS += CRLF + _cTexto1 
Endif 

Return    



/*/{Protheus.doc} AltCateg
Possibilita a alteração de cartegoria do campo

@type 		function
@author 	Roberto Souza
@since 		18/09/2017
@version 	P11 
 
@return nil
/*/    
Static Function AltCateg()

	Local aArea		:= GetArea()		
	Local oDlgC	
	Local oPanel	
	Local oButton
	
	Local aTit 		:= aCols[n]
    Local nPosTit   := aScan( aHeader,{ |x| AllTrim(x[02]) == "ACG_TITULO"	} )
    Local nPosPref  := aScan( aHeader,{ |x| AllTrim(x[02]) == "ACG_PREFIX"	} )
    Local nPosParc  := aScan( aHeader,{ |x| AllTrim(x[02]) == "ACG_PARCEL"	} )
    Local nPosTipo  := aScan( aHeader,{ |x| AllTrim(x[02]) == "ACG_TIPO"	} )
    Local nPosvlr	:= aScan( aHeader,{ |x| AllTrim(x[02]) == "ACG_VALOR"	} )	
	Local cCodCli   := M->ACF_CLIENTE
	Local cLoja		:= M->ACF_LOJA

    Local cTit 		:= aTit[nPosTit	]
    Local cPref		:= aTit[nPosPref]
    Local cParc 	:= aTit[nPosParc]
    Local cTipo		:= aTit[nPosTipo]
    Local nValTit	:= aTit[nPosvlr]
    
    Local cKeyF1	:= xFilial("SE1")+	cPref + cTit + cParc + cTipo     
    Local nTela		:= 1  
    Local nOpcao    := 0

	If !Empty(cCodCli) .And. !Empty(cLoja) .And. !Empty(cTit) .And. !Empty(cPref) 

		DbSelectArea("SE1")

		If SE1->(DbSeek( cKeyF1 ))

			aLin := {040,050,065,075}
                         
			oDlgC := MSDialog():New(10,10,220,500,"Alteração de categoria",,,,,CLR_BLACK,CLR_WHITE,,,.T.)   

			DEFINE FONT oBold NAME "Arial" SIZE 0, -13 BOLD

			@ 030,05 MsPanel oPanel Prompt "" Size 242,115 Of oDlgC Centered Lowered
			oPanel:lVisible := .F.      
			
			@ 030,005 To 100,235 Of oDlgC Label "Informações do Titulo" Pixel //"Composicao Sequencial da pesquisa avancada"

			@ aLin[01], 015 Say "Prefixo"	Pixel Of oDlgC FONT oBold
			@ aLin[01], 045 Say "Numero" 	Pixel Of oDlgC FONT oBold
			@ aLin[01], 095 Say "Parcela" 	Pixel Of oDlgC FONT oBold
			@ aLin[01], 125 Say "Tipo" 		Pixel Of oDlgC FONT oBold
			@ aLin[01], 155 Say "Valor" 	Pixel Of oDlgC FONT oBold
	
			@ aLin[02], 015 Get cPref 		Size 20,08	Pixel Of oDlgC WHEN .F.
			@ aLin[02], 045 Get cTit    	Size 40,08	Pixel Of oDlgC WHEN .F.
			@ aLin[02], 095 Get cParc 		Size 10,08	Pixel Of oDlgC WHEN .F.
			@ aLin[02], 125 Get cTipo 		Size 10,08	Pixel Of oDlgC WHEN .F.
			@ aLin[02], 155 Get nValTit 	Size 60,08	Picture "@E 999,999,999.99" Pixel Of oDlgC WHEN .F.
	
			cCombo := GetSx3Cache("E1_XCATCOB","X3_CBOX")
			aCombo := Separa(cCombo,";")			            
			nOpcCombo := SE1->E1_XCATCOB
			nOpcOld   := nOpcCombo
							
			@ aLin[03], 015 Say "Categoria"	Pixel Of oDlgC FONT oBold
			@ aLin[04], 015 MSCOMBOBOX oCombo VAR nOpcCombo ITEMS aCombo SIZE 120, 010 OF oDlgC  PIXEL
					
			oDlgC:Activate(,,,.T.,{|| },,{|| EnchoiceBar(oDlgC, {|| (nOpcao:= 1,oDlgC:End())}, {|| oDlgC:End() },,{} )}) 

		EndIf

	EndIf

	If nOpcao == 1 .And. !Empty( nOpcCombo ) .And. nOpcCombo <> SE1->E1_XCATCOB
		Reclock("SE1",.F.)
		SE1->E1_XCATCOB := nOpcCombo		
		MsUnlock()

		cDescCombo	:= aCombo[aScan( aCombo, {|x| Left(x,1) == nOpcCombo })]
		cDescOld	:= aCombo[aScan( aCombo, {|x| Left(x,1) == nOpcOld })]

		cMsgAvis := "Categoria do título alterada de '"+AllTrim(cDescOld) +"' para '"+AllTrim(cDescCombo)+"'"  
				
		Aviso("Categoria",cMsgAvis ,{"Ok"},1)
			
	EndIf
	
	RestArea( aArea )      
	
Return  