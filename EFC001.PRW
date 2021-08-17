
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³EFC001    ºAutor  ³Microsiga           º Data ³  06/04/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Consulta CR com opcao de consulta de cheques               º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function EFC001

Private lFi040MnCp:= ExistBlock("FI040MNCP")
Private lFi040TpCp:= ExistBlock("FI040TPCP")
Private lFi040GrCp:= ExistBlock("FI040GRCP")
Private lFi040Cmpo:= .F.
Private cFilName  := ""
Private cCadastro := "Consulta - Titulos CR"
Private aRotina	:= {	{"Pesquisar", "AxPesqui",0,1},; // "Pesquisar"
						{"Consulta ", "Fc040Con",0,2},; // "Consulta "
						{"Cheques"  , "U_C001Chq" ,0,2},; // "Cheques"
						{"Legenda"  , "FA040Legenda", 0 , 6}} // "Legenda"

If ExistBlock("FI040CMPO")
  cFieldPE:= ExecBlock("FI040CMPO",.F.,.F.)

  dbSelectArea("SX3")
  SX3->(dbSetOrder(2))
  If dbSeek(cFieldPE)
    cFilName:= X3DESCRIC()
    lFi040Cmpo:= .T.
  EndIf

EndIf

mBrowse(06, 01, 22, 75, "SE1",,,,,, Fa040Legenda("SE1"))

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³C001CHQ   ºAutor  ³Microsiga           º Data ³  06/04/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Consulta de Cheques do Titulo                              º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function C001CHQ(cAlias,nReg,nOpc)
Local oDlg
Local oGetChq
Local nOpcA    := 0
Local aSize	   := {}
Local aObjects := {}
Local aInfo	   := {}
Local aPosObj  := {}
Private aTELA[0][0],aGETS[0],aHeader[0],aCols[0]

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Faz o calculo automatico de dimensoes de objetos     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aSize := MsAdvSize(,.F.,370)
aObjects := {} 

AAdd( aObjects, { 100, 100, .T., .T. } )
AAdd( aObjects, { 100, 100, .T., .T. } )

aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 }
aPosObj := MsObjSize( aInfo, aObjects )  

RegToMemory("SE1",.F.)
EF001ACOLS("SZ1","Z1_FILIAL",.F.)

DEFINE MSDIALOG oDlg TITLE cCadastro From aSize[7],0 to aSize[6],aSize[5] of oMainWnd PIXEL

	Zero()
	EnChoice( cAlias, nReg, nOpc, , , , , aPosObj[1],, 3 )

	oGetChq:= MsGetDados():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,3],aPosObj[2,4],nOpc,"AllwaysTrue","AllwaysTrue","",.T.)
	oGetChq:oBrowse:bDelete:={ || aCols[n,Len(Acols[n])]:=!aCols[n,Len(Acols[n])],AlwaysTrue(),oGetChq:oBrowse:Refresh(.F.)}
	oGetChq:oBrowse:Refresh(.T.)
ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||oDlg:End()},{||oDlg:End()})

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³EF001ACols º Autor ³ AP6 IDE           º Data ³  11/04/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Codigo gerado pelo AP6 IDE.                                º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP6 IDE                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function EF001ACols(cAlias,cCampo,lInclui)
Local nUsado:= 0
Local nI    := 0
Local nReg  := 0
Local lCampo:= .F.

aCols  := {}
aHeader:= {}

dbSelectArea("SX3")
SX3->(dbSetOrder(1))
If dbSeek( cAlias )
	While !Eof() .And. (X3_ARQUIVO == cAlias)
		If (cAlias == "SZ4")
	    	lCampo:= ((Trim(X3_CAMPO) $ cCampo) .Or. (cCampo == "*")) .And. (cNivel >= SX3->X3_NIVEL)
		Else
	        lCampo:= X3USO(X3_USADO) .And. (cNivel >= SX3->X3_NIVEL) .And. !(Trim(X3_CAMPO) $ cCampo) 
		EndIf		
		
		If lCampo
			nUsado++
			AADD(aHeader,{ 	TRIM(X3TITULO()),;
							X3_CAMPO,;
							X3_PICTURE,;
							X3_TAMANHO,;
							X3_DECIMAL,;
							X3_VALID,;
							X3_USADO,;
							X3_TIPO,;
							X3_ARQUIVO,;
							X3_CONTEXT } )
		EndIf
		dbSkip()
	End
EndIf

SX3->(dbSetOrder(2))
	
aAdd(aCols,Array(Len(aHeader)+1))
For nI := 1 To Len(aHeader)
	aCols[Len(aCols),nI] := CriaVar(aHeader[nI,2],IIf(aHeader[nI,10] == "V",.T.,.F.))
Next nI
aCols[Len(aCols),Len(aHeader)+1] := .F.
nX  := 1                 
nReg:= 1

If !lInclui
	If (cAlias == "SZ1") //Cheques
		dbSelectArea("SZ3")
		dbSetOrder(2)
		dbSeek(xFilial("SZ3")+SE1->(E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO),.T.)

		While !Eof() .And. (xFilial("SZ3")+SE1->(E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO) == SZ3->(Z3_FILIAL+Z3_PREFIXO+Z3_NUM+Z3_PARCELA+Z3_TIPO))
			dbSelectArea("SZ1")
			dbSetOrder(1)
			dbSeek(xFilial("SZ1")+SZ3->(Z3_BANCO+Z3_AGENCIA+Z3_CONTA+Z3_CHEQUE),.T.)

			If (nReg > 1)
				aAdd(aCols,Array(Len(aHeader)+1))
            EndIf

			For nI := 1 To Len(aHeader)
				If (aHeader[nI,10] == "V")
					aCols[Len(aCols),nI] := CriaVar(aHeader[nI,2])
				Else
					aCols[Len(aCols),nI] := FieldGet(FieldPos(aHeader[nI,2]))
				EndIf
			Next nI
			aCols[Len(aCols),Len(aHeader)+1] := .F.
			nReg++
			
			dbSelectArea("SZ3")
			dbSkip()
		End
	EndIf
EndIf
	
Return