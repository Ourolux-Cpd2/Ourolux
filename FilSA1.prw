#INCLUDE 'PROTHEUS.CH'
User Function FilSA1()

Local cVends := ""
Local CFil := "" 
Local lRet := .T.
Local aCabec 
Local aItens 
Local nAux 

aCabec := { "CODIGO", "LOJA" , "NOME" } 
aItens := {} 


If !(U_IsAdm() .OR. U_IsFree())  

	U_ListaVnd(@cVends)

	//SA1->(DbClearFilter())
			
	//SA1->(DbSetFilter({|| SA1->A1_VEND $ cVends },;
	  //					  "SA1->A1_VEND $ '"+cVends+"'" ))

 

	DbSelectArea( "SA1" ) 
	DbSetOrder( 1 ) 
	DbGoTop() 
	Do While !EoF() 
		If SA1->A1_COD $ cVends 
			AAdd( aItens, {SA1->A1_COD, SA1->A1_LOJA, SA1->A1_NOME, RecNo() } ) 
		EndIf
	SA1->( DbSkip() )
	EndDo 


	DEFINE MSDIALOG oDlg TITLE 'CONSULTA PADRAO - SA1' FROM 000, 000 TO 500, 600 PIXEL 
	oBrw := TWBrowse():New( NIL,NIL,NIL,NIL,, aCabec,,oDlg,,,,,,,,,,,,.T. ) 
	oBrw:Align := CONTROL_ALIGN_ALLCLIENT 
	oBrw:SetArray( aItens ) 
	oBrw:bLine := { || aItens[ oBrw:nAT ] } 
	oBrw:bLDblClick := { || RetVAR_IXB(aItens, oBrw:nAt), oDlg:End() } 
	ACTIVATE MSDIALOG oDlg CENTERED 
EndIf
Return(.T.) 


Static Function RetVAR_IXB(aItens, nLinhaItem) 

DbSelectArea( "SA1" ) 
DbGoTo( aItens[nLinhaItem][4] ) 
VAR_IXB := SA1->A1_COD+SA1->A1_LOJA //VAR_IXB variável pública de uso livre 
Return VAR_IXB 
