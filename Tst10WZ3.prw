#Include "Protheus.ch"
#Include "ApWizard.ch"         
/*

+===========================================================================+
|Consultoria:                Q S   d o   B R A S I L                        |
+---------------------------------------------------------------------------+
|Programa   | Tst10WZ3	|Autor  | Vitor Lopes        | Data |  00/07/14     |
+---------------------------------------------------------------------------+
|Descricao  | Rotina de impressão de etiquetas para identificação de  		|
|           | produto, lote e quantidade.									|
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

 
                                                                         
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
User Function Tst10WZ3()                                                                                                                        
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
U_ACDIWZ3()
Return                          

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
User Function ACDIWZ3(nOrigem,aParIni)                                                                                                            
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
Local oWizard
Local oPanel
Local nTam
Local oOrigem
Local aOrigem	:= {}

Local aparNF	:= {	{1,"Nota Fiscal" 		,Space(9)  ,"","","CBW"	,If(aParIni==NIL,".T.",".F."),0,.F.},; //"Nota Fiscal"
						{1,"Serie" 	   			,Space(3)  ,"","",		,If(aParIni==NIL,".T.",".F."),0,.F.},; //"Serie"
						{1,"Fornecedor"	  		,Space(6)  ,"","","SA2"	,If(aParIni==NIL,".T.",".F."),0,.F.},; //"Fornecedor"
						{1,"Loja"	   			,Space(2)  ,"","",		,If(aParIni==NIL,".T.",".F."),0,.F.} } //} //"Loja"
Local aRetNF	:= {Space(9),Space(3),Space(6),Space(2),Space(30)}

Local aParPR	:= {	{1,"Produto" 			,Space(15),"","","SB1"	,If(aParIni==NIL,".T.",".F."),0,.F.} } //"Produto"                            
Local aRetPR	:= {Space(15),Space(30)}

//Local aParOP	:= {	{1,"OP" 				,Space(13),"","","SC2"	,If(aParIni==NIL,".T.",".F."),0,.F.} }
//Local aRetOP	:= {Space(13)}

Local aParImp	:= {{1,"Local de Impressão"	,Space(6),"","","CB5"	,".T.",0,.F.}} //"Local de Impressão"
Local aRetImp	:= {Space(6)}

Local aParam	:= {} 
Local aRetPE	:= {}

Local nx:= 1

Private cCondSF1:= ' 1234567890'  // variavel utilizada na consulta sxb CBW, favor nao remover esta linha
Private oLbx
Private aLbx	:= {{.f., Space(15),Space(20),Space(10),Space(10),Space(10)}}
Private aSvPar	:= {}
Private cOpcSel	:= ""  // variavel disponivel para infomar a opcao de origem selecionada 

Private cNota	:= ""
Private cSerie	:= ""
Private cForn	:= ""
Private cLoja	:= ""  
Private cOp		:= ""  
//Private cProje	:= ""

DEFAULT nOrigem := 1

aParam:={	{"Nota Fiscal" 			,aParNF,aRetNF,{|| AWzVNF()}} }//,;  	//"Nota Fiscal"
		  //	{"Produto"		  		,aParPR,aRetPR,{|| AWzVPR()}} }//,;  	//"Produto"
		   //	{"Ordem de Producao"	,aParOP,aRetOP,{|| AWzVOP()}} } //"Ordem de Producao"	

// carrega parametros vindo da funcao pai
If aParIni <> NIL  
	For nX := 1 to len(aParIni)              
		nTam := len( aParam[nOrigem,3,nX ] )
		aParam[nOrigem,3,nX ] := Padr(aParIni[nX],nTam )
	Next             
EndIf 

For nx:= 1 to len(aParam)                       
	aadd(aOrigem,aParam[nX,1])
Next

DEFINE WIZARD oWizard TITLE "Etiqueta de Produto WMS" ; //"Etiqueta de Produto ACD"
       HEADER "Rotina de Impressão de etiquetas termica." ; //"Rotina de Impressão de etiquetas termica."
       MESSAGE "";
       TEXT "Esta rotina tem por objetivo realizar a impressao das etiquetas termicas de identificação de produto no padrão codigo natural/EAN conforme as opcoes disponives a seguir." ; //"Esta rotina tem por objetivo realizar a impressao das etiquetas termicas de identificação de produto no padrão codigo natural/EAN conforme as opcoes disponives a seguir."
       NEXT {|| .T.} ;
		 FINISH {|| .T. } ;
       PANEL

   // Primeira etapa
   CREATE PANEL oWizard ;
          HEADER "Informe a origem das informações para impressão" ; //"Informe a origem das informações para impressão"
          MESSAGE "" ;
          BACK {|| .T. } ;
 	       NEXT {|| nc:= 0,aeval(aParam,{|| &("oP"+str(++nc,1)):Hide()} ),&("oP"+str(nOrigem,1)+":Show()"),cOpcSel:= aParam[nOrigem,1],A11WZIniPar(nOrigem,aParIni,aParam) ,.T. } ;
          FINISH {|| .F. } ;
          PANEL
   
   oPanel := oWizard:GetPanel(2)  
   
   oOrigem := TRadMenu():New(30,10,aOrigem,BSetGet(nOrigem),oPanel,,,,,,,,100,8,,,,.T.)
   If aParIni <> NIL
	   oOrigem:Disable()
	EndIf	   
	
   // Segunda etapa
   CREATE PANEL oWizard ;
          HEADER "Preencha as solicitações abaixo para a seleção do produto" ; //"Preencha as solicitações abaixo para a seleção do produto"
          MESSAGE "" ;
          BACK {|| .T. } ;
          NEXT {|| Eval(aParam[nOrigem,4]) } ;
          FINISH {|| .F. } ;
          PANEL                                  

   oPanel := oWizard:GetPanel(3)                                     
   
	For nx:= 1 to len(aParam)
  		&("oP"+str(nx,1)) := TPanel():New( 028, 072, ,oPanel, , , , , , 120, 20, .F.,.T. )
		&("oP"+str(nx,1)):align:= CONTROL_ALIGN_ALLCLIENT       
		ParamBox(aParam[nX,2],"Parâmetros...",aParam[nX,3],,,,,,&("oP"+str(nx,1)))		 //"Parâmetros..."
		&("oP"+str(nx,1)):Hide()
	Next		

   CREATE PANEL oWizard ;
          HEADER "Parametrização por produto" ; //"Parametrização por produto"
          MESSAGE "Marque os produtos que deseja imprimir" ; //"Marque os produtos que deseja imprimir"
          BACK {|| .T. } ;
          NEXT {|| aRetImp  := {Space(6)},VldaLbx()} ;
          FINISH {|| .T. } ;
          PANEL
   oPanel := oWizard:GetPanel(4)       
   ListBoxMar(oPanel)
                        
   CREATE PANEL oWizard ;
          HEADER "Parametrização da impressora" ; //"Parametrização da impressora"
          MESSAGE "Informe o Local de Impressão" ; //"Informe o Local de Impressão"
          BACK {|| .T. } ;
          NEXT {|| Imprime(aParam[nOrigem,1]) } ;
          FINISH {|| .T.  } ;
          PANEL
   oPanel := oWizard:GetPanel(5)       
   ParamBox(aParImp,"Parâmetros...",aRetImp,,,,,,oPanel)	 //"Parâmetros..."
   
     CREATE PANEL oWizard ;
          HEADER "Impressão Finalizada" ; //"Impressão Finalizada"
          MESSAGE "" ;
          BACK {|| .T. } ;
          NEXT {|| .T. } ;
          FINISH {|| .T.  } ;
          PANEL

ACTIVATE WIZARD oWizard CENTERED

Return                                           

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
Static Function A11WZIniPar(nOrigem, aParIni,aParam)                                                                                              
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
Local nX
If aParIni <> NIL
	For nx:= 1 to len(aParIni)
		&( "MV_PAR" + StrZero( nX, 2, 0 ) ) := aParIni[ nX ]
	Next
EndIf
         
For nx:= 1 to len(aParam[nOrigem,3])                                    
	&( "MV_PAR" + StrZero( nX, 2, 0 ) ) := aParam[nOrigem,3,nX ]
Next                       

Return .t.                                     

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
Static Function AWzVNF()                                                                                                                          
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

Local nQE
Local nQVol
Local nResto               
Local oOk	:= LoadBitmap( GetResources(), "LBOK" )   //CHECKED    //LBOK  //LBTIK
Local oNo	:= LoadBitmap( GetResources(), "LBNO" )   //UNCHECKED  //LBNO   
Local nT	:= TamSx3("D3_QUANT")[1]
Local nD	:= TamSx3("D3_QUANT")[2] 
Local nNorma           
Local nLastro  := 0
Local nCamada  := 0  
Local nCalc    := 0 
Local cCod     := "" 
Local nConv    := 0 
Local nPeca    := 0

cNota := Padr(MV_PAR01,9)
cSerie:= Padr(MV_PAR02,3)
cForn := Padr(MV_PAR03,6)
cLoja := Padr(MV_PAR04,2) 
//cProje:= Padr(MV_PAR05,30) 

If Empty(cNota+cSerie+cForn+cLoja)
  	MsgAlert(" Necessario informar a nota e o fornecedor. ") //" Necessario informar a nota e o fornecedor. "
 	Return .F.
EndIf
SF1->(DbSetOrder(1))
If ! SF1->(DbSeek(xFilial('SF1')+cNota+cSerie+cForn+cLoja))
  	MsgAlert(" Nota fiscal não encontrada. ") //" Nota fiscal não encontrada. "
  	Return .F.
EndIf       

aLbx:={}
SD1->(DbSetOrder(1))
SD1->(dbSeek(xFilial('SD1')+cNota+cSerie+cForn+cLoja)	)    

While SD1->(!EOF()  .and. D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA == xFilial('SD1')+cNota+cSerie+cForn+cLoja)
            
	SB1->(dbSeek(xFilial('SB1')+SD1->D1_COD))  
		nConv := SB1->B1_QE //Caixas por embalagem.

	If ! CBImpEti(SB1->B1_COD)
		SD1->(dbSkip()	)
		Loop
	EndIf 
	nQE	    := SD1->D1_QUANT //Quantidade total de peças na nota.	
	
	nQVol   := Int(nQE/nConv)//Quantidade de volumes e quantidade de caixas na nota.
	nResto  := 0	
	                            
		cCod := SD1->D1_COD
		DC3-> (DbSeek(xFilial("DC3")+cCod))
		nNorma := DC3->DC3_CODNOR

		DC3->(DbCloseArea())

		DC2-> (DbSeek(xFilial("DC2")+nNorma))
		nLastro := DC2->DC2_LASTRO //Lastro
		nCamada := DC2->DC2_CAMADA //Camada

		DC2->(DBCLOSEAREA())
  
		nCalc := nLastro * nCamada //Calcular a paletização do produto.
		nPeca := nLastro * nCamada
		nCalc := int(nQe/nCalc)
	   //	nCalc := ROUND(nCalc,0)
           //          1   2               3              4               5                    6                     
	SD1->(aadd(aLbx,{.f.,D1_COD,Str(nCalc,nT,nD),Str(nQVol,nT,nD),Str(nPeca,nT,nD),SD1->D1_LOTECTL,"SD1",Recno()})) 
	SD1->(dbSkip()	)

EndDo   
  
oLbx:SetArray( aLbx )
oLbx:bLine := {|| {Iif(aLbx[oLbx:nAt,1],oOk,oNo),aLbx[oLbx:nAt,2],aLbx[oLbx:nAt,3],aLbx[oLbx:nAt,4],aLbx[oLbx:nAt,5],aLbx[oLbx:nAt,6]}}
oLbx:Refresh()

Return .t.
 
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
Static Function AWzVPR()                                                                                                                          
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
Local cProduto	:= Padr(MV_PAR01,15)  
Local oOk		:= LoadBitmap( GetResources(), "LBOK" )   //CHECKED    //LBOK  //LBTIK
Local oNo		:= LoadBitmap( GetResources(), "LBNO" ) //UNCHECKED  //LBNO      
Local nT		:= TamSx3("D3_QUANT")[1]
Local nD		:= TamSx3("D3_QUANT")[2]  


//cProje	:= Padr(MV_PAR02,30) 

If Empty(cProduto)
  	MsgAlert(" Necessario informar o codigo do produto. ") //" Necessario informar o codigo do produto. "
  	Return .F.
EndIf

DbSelectArea("SB1")
SB1->(DbSetOrder(1))
If ! SB1->(DbSeek(xFilial('SB1')+cProduto))
  	MsgAlert(" Produto não encontrado ") //" Produto não encontrado "
  	Return .F.
EndIf    

If ! CBImpEti(SB1->B1_COD)
  	MsgAlert(" Este Produto está configurado para nao imprimir etiqueta ") //" Este Produto está configurado para nao imprimir etiqueta "
  	Return .F.
EndIf       //1            2         3                                  4            5           6          7         8      9            10        11    



aLbx:={{	.f., SB1->B1_COD,Space(10),Str(SB1->B1_QE,nT,nD),Str(0,nT,nD),Str(0,nT,nD),Space(10),Space(20),"SB1",SB1->(Recno()),SPACE(08)}}
oLbx:SetArray( aLbx )
oLbx:bLine := {|| {Iif(aLbx[oLbx:nAt,1],oOk,oNo),aLbx[oLbx:nAt,2],aLbx[oLbx:nAt,3],aLbx[oLbx:nAt,4],aLbx[oLbx:nAt,5],aLbx[oLbx:nAt,6]}}
oLbx:Refresh()
Return .t.


//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
Static Function ListBoxMar(oDlg)                                                                                                                  
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
Local oChk1
Local oChk2
Local lChk1 := .F.
Local lChk2 := .F.
Local oOk	:= LoadBitmap( GetResources(), "LBOK" )   //CHECKED    //LBOK  //LBTIK
Local oNo	:= LoadBitmap( GetResources(), "LBNO" ) //UNCHECKED  //LBNO
Local oP
  
@ 10,10 LISTBOX oLbx FIELDS HEADER " ", "Produto", "Qtde Etiquetas","Qtde. Caixas","Qtde. Peças Palete", "Lote" SIZE 230,095 OF oDlg PIXEL ; 
        ON  dblClick(VerLoteId()) //dblClick(aLbx[oLbx:nAt,1] := !aLbx[oLbx:nAt,1])

oLbx:SetArray( aLbx )
oLbx:bLine	:= {|| {Iif(aLbx[oLbx:nAt,1],oOk,oNo),aLbx[oLbx:nAt,2],aLbx[oLbx:nAt,3],aLbx[oLbx:nAt,4],aLbx[oLbx:nAt,5],aLbx[oLbx:nAt,6]}}
oLbx:align	:= CONTROL_ALIGN_ALLCLIENT

oP := TPanel():New( 028, 072, ,oDlg, , , , , , 120, 20, .F.,.T. )
oP:align:= CONTROL_ALIGN_BOTTOM

@ 5,010  BUTTON "Alterar"	 SIZE 55,11 ACTION FormProd(1) OF oP PIXEL //"Alterar"
@ 5,080  BUTTON "Copiar"	 SIZE 55,11 ACTION FormProd(2) OF oP PIXEL //"Copiar"
@ 5,160 CHECKBOX oChk1 VAR lChk1 PROMPT "Marca/Desmarca Todos"  SIZE 70,7 	PIXEL OF oP ON CLICK( aEval( aLbx, {|x| x[1] := lChk1 } ),oLbx:Refresh() ) //"Marca/Desmarca Todos"
@ 5,230 CHECKBOX oChk2 VAR lChk2 PROMPT "Inverter a seleção" 	SIZE 70,7 	PIXEL OF oP ON CLICK( aEval( aLbx, {|x| x[1] := !x[1] } ), oLbx:Refresh() ) //"Inverter a seleção"

Return
 
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////            
Static Function FormProd(nopcao)                                                                                                                  
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
Local oOk		:= LoadBitmap( GetResources(), "LBOK" ) //CHECKED    //LBOK  //LBTIK
Local oNo		:= LoadBitmap( GetResources(), "LBNO" ) //UNCHECKED  //LBNO
Local aRet		:= {}
Local aParamBox := {}  
Local cProduto	:= aLbx[oLbx:nAt,2] //Produto
Local nQtde		:= Val(aLbx[oLbx:nAt,3]) //Qtd. Etiquetas
Local nQEmb		:= Val(aLbx[oLbx:nAt,4]) //Qtde. Caixas 

Local cQtde		:= aLbx[oLbx:nAt,3]//Qtd. Etiquetas
Local cQEmb		:= aLbx[oLbx:nAt,4]//Qtde. Caixas 

Local nPeca     := aLbx[oLbx:nAt,5]//Quantida de peças por palete.

Local nQVol		:= 0
Local nResto	:= 0
Local cLote	   	:= aLbx[oLbx:nAt,6] //Lote
Local cID  	   	:= (aLbx[oLbx:nAt,3]) //Qtde. Etiquetas
Local nId		:= Val(aLbx[oLbx:nAt,3])
Local nAt		:= oLbx:nAt  

Local nMv
Local aMvPar	:={}
Local lRastro 	:=.T. //Rastro(cProduto)
Local lEndere 	:=.F. //Localiza(cProduto) 
Local nT		:= TamSx3("D3_QUANT")[1]
Local nD		:= TamSx3("D3_QUANT")[2] 

For nMv := 1 To 40
     aAdd( aMvPar, &( "MV_PAR" + StrZero( nMv, 2, 0 ) ) )
Next nMv                     
                       
aParamBox :={	{1,"Produto"			,cProduto	,"","",""	,".F.",0,.F.},; 						//"Produto"   
  				{1,"Peças Por Palete"	,nPeca 		,"",'PesqPict("SD3","D3_QUANT")',""	,".T.",0,.T.},; //"Qtd por Embalagem"
				{1,"Total de caixas"	,cQEmb 		,"",'PesqPict("SD3","D3_QUANT")',""	,".T.",0,.T.},; //"Quantidade"
			 	{1,"Lote"				,cLote 		,"","",""	,.F.,0,.F.},;//} 							//"Lote" //If(lRastro,".T.",".F.")
			   	{1,"Qtd. Etiquetas"		,cID 		,"",'PesqPict("SD3","D3_QUANT")',""	,".T.",0,.T.}} 		//Quantidade de caixas.     
			   

If ! ParamBox(aParamBox,If(nopcao == 1,"Alterar","Copiar"),@aRet,,,,,,,,.f.)//"Alterar","Copiar" 
	For nMv := 1 To Len( aMvPar )
  	  &( "MV_PAR" + StrZero( nMv, 2, 0 ) ) := aMvPar[ nMv ]
	Next nMv
	oLbx:SetArray( aLbx )
	oLbx:bLine := {|| {Iif(aLbx[oLbx:nAt,1],oOk,oNo),aLbx[oLbx:nAt,2],aLbx[oLbx:nAt,3],aLbx[oLbx:nAt,4],aLbx[oLbx:nAt,5],aLbx[oLbx:nAt,6]}}
	oLbx:Refresh()
	Return
EndIf

nQtde 	:= val(aRet[2])  
If Empty(nQtde)  
	If nOpcao == 2
		MsgAlert("Para a copia a quantidade não pode estar em branco!") //"Para a copia a quantidade não pode estar em branco!"
	EndIf
	If MsgYesNo("Quantidade informada igual a zero, deseja excluir esta linha?") //"Quantidade informada igual a zero, deseja excluir esta linha?"
	   aDel(aLbx,nAt)
	   aSize(aLbx,len(albx)-1)
   EndIf
Else
	
	nQEmb	:= val(aRet[3])
	cLote 	:= aRet[4]
   	nPeca	:= Val(aRet[2])
	nId		:=	Val(aRet[5])   
	
	If nOpcao == 2
		aadd(aLbx,aClone(aLbx[nAt]))
		nAt := Len(aLbx)
	EndIf  
	aLbx[nAt,3] := str(nId,nT,nD)
	aLbx[nAt,4] := str(nQEmb,nT,nD) 
	aLbx[nAt,5] := str(nPeca,nT,nD) 
	aLbx[nAt,6] := cLote

EndIf

oLbx:SetArray( aLbx )
oLbx:bLine := {|| {Iif(aLbx[oLbx:nAt,1],oOk,oNo),aLbx[oLbx:nAt,2],aLbx[oLbx:nAt,3],aLbx[oLbx:nAt,4],aLbx[oLbx:nAt,5],aLbx[oLbx:nAt,6]}}
oLbx:Refresh()

For nMv := 1 To Len( aMvPar )
    &( "MV_PAR" + StrZero( nMv, 2, 0 ) ) := aMvPar[ nMv ]
Next nMv
Return .t.          
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
Static Function VldaLbx()
Local nx
Local nMv
SB1->(DbSetOrder(1))
For nX := 1 to Len(aLbx)   
	If aLbx[nx,1] .and. ! Empty(aLbx[nX,3])
		exit
	EndIf	
Next
If nX > len(aLbx)
	MsgAlert("Necessario marcar pelo menos um item com quantidade para imprimir!") //"Necessario marcar pelo menos um item com quantidade para imprimir!"
	Return .f.
EndIf      
aSvPar := {}
For nMv := 1 To 40
     aAdd( aSvPar, &( "MV_PAR" + StrZero( nMv, 2, 0 ) ) )
Next nMv                     

Return .t.

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
Static Function Imprime(cOrigem)                                          
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

Local nX 
Local cProduto
Local nQtde
Local nQE   
Local nQVol 
local Nid2
Local nResto
Local cAliasOri
Local nRecno    
Local cLote
Local cNumId 
Local nMv
Local cData		:= ""
Local cData1	:= ""      
Local nPeca
Private cLocImp := MV_PAR01

If ! CBYesNo("Confirma a Impressao de Etiquetas","Aviso")  //"Confirma a Impressao de Etiquetas"###"Aviso"
	Return .f.
EndIf

If ! CB5SetImp(cLocImp)  
	MsgAlert("Local de Impressão "+cLocImp+" nao Encontrado!") //"Local de Impressão "###" nao Encontrado!"
	Return .f.
Endif	

For nMv := 1 To Len( aSvPar )
    &( "MV_PAR" + StrZero( nMv, 2, 0 ) ) := aSvPar[ nMv ]
Next nMv

SB1->(DbSetOrder(1))
For nX := 1 to Len(aLbx)   
	If ! aLbx[nx,1]
		Loop
	EndIf	
	cProduto:= aLbx[nx,2]
	nQtde	:= val(aLbx[nx,3])
	If Empty(nQtde)
		Loop
	EndIf	
	nQE		:= val(aLbx[nx,4])
	nPeca	:= val(aLbx[nx,5])
	nQVol 	:= val(aLbx[nx,6])
                 
	cLote	 	:= aLbx[nx,6] 
	cNumId		:= aLbx[nx,8]
  	cAliasOri	:= aLbx[nx,7] 
 	nRecno		:= aLbx[nx,8]  
	cData		:= dtos(Posicione("SD1",1,xFilial("SD1")+cNota+cSerie,"D1_EMISSAO"))  //D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_COD+D1_ITEM
	cData1      := (substr(cData,7,2)+"/"+substr(cData,5,2)+"/"+substr(cData,1,4))
		
  //	(cAliasOri)->(DbGoto(nRecno)) //posiciona na tabela de origem da informação

 	U_GERAETIQ(cProduto,nQtde,nQE,nPeca,nQVol,cNota,cOP,cNumId,cLote,cData1) //cNota+cSerie+cForn+cLoja
	                                                    	
Next
MSCBCLOSEPRINTER()                 

Return .t.                             

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
User Function GERAETIQ(cProdr,nQtdee,nQee,nIdd,nQVoll,cNota2,cOP2,cNumId,cLote,cData1)
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////     

Local cDesc		:= ''  
Local cCodBarra := ''    
Local cCodCliePr:= ''  
local cUnidade	:= ''
Local cLotee	:= PADR(cLote,10)
Local cCaix		:= ''

SB1->(DBSETORDER(1))	
SB1->(DBSEEK(xFilial('SB1')+cProdr)) 
cDesc 		:= SUBSTR(SB1->B1_DESC,1,23)
cCodBarra	:= PADR(SB1->B1_COD,15)   
cUnidade 	:= SB1->B1_UM

If EMPTY(cDesc)
	MsgAlert("A Descrição auxiliar para o produto "+cProdr+" não foi informada, impressao cancelada do item !")
	Return
EndIf


MSCBCHKSTATUS(.F.)

CB5->(DBSELECTAREA("CB5"))
CB5->(DBSETORDER(1))
CB5->(DBSEEK(xFilial("CB5")+ALLTRIM(cLocImp)))


If ALLTRIM(CB5->CB5_MODELO) == "ZEBRA"

   //	MSCBLOADGRF("OK.grf")
	
	For n := 1 to nQtdee
	
		cCaix := CVALTOCHAR(nIdd)
	
		MSCBBEGIN(1,6) 	   
		    
				MSCBBOX(2,2,98,20,5)//box Produto
			   //	MSCBGRAFIC(9,6,"OK.grf")
			   MSCBSAY(6,4, "Produto"		        ,"N","0","34,51") 
			   MSCBSAY(08,10, cDesc		        ,"N","0","70,50")
	
				
			  	MSCBBOX(2,20,98,45,5)//box Produto
			  	MSCBSAY(6,22, "Codigo"		        ,"N","0","34,51")
			 	MSCBSAY(08,28, cProdr		        ,"N","0","140,100")
			 
			 	MSCBSAY(63 ,28,"Nota Fiscal"       ,"N","0","34,51")
				MSCBSAY(63 ,33,cNota2				,"N","0","34,51")
				MSCBSAY(63 ,40,cData1               ,"N","0","34,51")
			
			 	MSCBBOX(2,45,98,65,5)//box Código de barra
		        MSCBSAYBAR(10,48,cCodBarra + cLotee,"MB07","C",10.00,.F.,.T.,.F.,,2,1)  //Produto + Lote
			
			  	MSCBBOX(2,65,98,82,5)//box Lote 
			  	MSCBSAY(6,67, "Lote"		        ,"N","0","34,51")
				MSCBSAY(25,67, cLotee		        ,"N","0","100,80") 

				
				MSCBBOX(2,82,98,98,5)//box Quantida de caixas.                                                                           
				MSCBSAY(6,84, "Pecas"		        ,"N","0","34,51")
				MSCBSAYBAR(40,84,cCaix,"MB07","C",10.00,.F.,.T.,.F.,,2,1)  //Produto + Lote


		   	
		MSCBInfoEti("PRODUTO","PRODUTO")       	      
		MSCBEND()    
		
	Next
	

	
EndIf

Return   


///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
Static Function VerLoteId()                                                  
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

If Empty(aLbx[oLbx:nAt,4]) //Se Lote for zerado não deixa imprimir
	MsgAlert("É necessário informar o Lote para impressão.") 
Else
	aLbx[oLbx:nAt,1] := !aLbx[oLbx:nAt,1]
EndIf

Return