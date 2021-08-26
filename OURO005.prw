#Include "Protheus.ch"
#INCLUDE "rwmake.ch"
#Include "TOTVS.CH"
#Include "FWBROWSE.CH"
#Include "TOPCONN.CH"
#Include "MSGRAPHI.CH"
#Include "FWMVCDef.CH"

#DEFINE POS_DATA	1
#DEFINE POS_CUSTO	2
#DEFINE POS_VLR_MTC	3
#DEFINE RECNO		4

/*
Rotina: OURO005
Descrição: Rotina para manutenção de valores por container
Autor: Rodrigo Dias Nunes
Data: 19/08/2021
*/
User Function OURO005()
Local aCoors 		:= FWGetDialogSize( oMainWnd )
Local nOpc			:= 0
Local cQuery        := ""
Local lGeraDia		:= .T.
Local nlx			:= 0
Private cCTN      	:= ZAC->ZAC_CTN //TRANSFORM(1234.54, “@E 999.999,99”) 
Private cMTC        := TRANSFORM(ZAC->ZAC_MTC,"@E 999.999")
Private cKG         := TRANSFORM(ZAC->ZAC_KG,"@E 999,999.999")
Private oDlg      	:= NIL
Private _oLayer1   	:= NIL
private _oTPane1 	:= Nil  
private _oTPane2 	:= Nil
private oListPR  	:= Nil
private aHeadSA     := {}
private aColsSa     := {}     
Private oFontA      := TFont():New("Arial",,20,,.F.,,,,.F.,.F.) 
Private oFontAB     := TFont():New("Arial",,20,,.T.,,,,.F.,.F.) 
Private aAlterCo	:= {"CUSTO"}

Aadd(aHeadSA, {"Data"       , "DATA"	    , ""				, TamSx3("C6_PRODUTO")[1]   , 0                       , "" ,, "D", ""		,,,,})
Aadd(aHeadSA, {"Custo Total", "CUSTO"       , "@E 9,999,999.99" , TamSx3("ZAD_CUSTO")[1]    , TamSx3("ZAD_VALMTC")[2] , "" ,, "N", ""		,,,,})
Aadd(aHeadSA, {"Valor MT³"  , "VALORMTC"    , "@E 9,999,999.99"	, TamSx3("ZAD_VALMTC")[1]   , TamSx3("ZAD_VALMTC")[2] , "" ,, "N", ""		,,,,})

DEFINE FONT _oFont NAME 'Arial Black' SIZE 09, 15

DEFINE MSDIALOG oDlg TITLE  "Historico de Valores" FROM  aCoors[1], aCoors[2] To aCoors[3], aCoors[4] PIXEL
oDlg:lMaximized := .T.
oDlg:lEscClose  := .F.

//CRIACAO DO LAYER	
	_oLayer1 := FWLayer():New()
	_oLayer1:Init(oDlg,.F.,.T.)
	_oLayer1:SetStyle("ROUND")

	//*********************
	//*Criacao das Linhas. *
	//*********************
	_oLayer1:AddLine( 'LIN_1'		, 40, .F.)
	_oLayer1:AddLine( 'LIN_2'		, 45, .F.)
	
	//*********************
	//*Criacao das Colunas.*
	//*********************
	_oLayer1:AddCollumn('COL_1'	,100,.T.,'LIN_1')
	_oLayer1:AddCollumn('COL_1'	,100,.T.,'LIN_2')
		
	//*********************
	//*Criacao das Janelas*
	//*********************
	_oLayer1:AddWindow('COL_1'		, 'JANELA_1'	, 'Container'	, 100, .F.,.T.,{||"" },"LIN_1",{||""})
	_oLayer1:AddWindow('COL_1'		, 'JANELA_2'	, 'Valores'		, 100, .F.,.T.,{||"" },"LIN_2",{||""})
		

    //*******************************
	//*Atribuindo janela aos objetos*
	//*******************************.
	_oTPane1 := _oLayer1:GetWinPanel("COL_1"	, "JANELA_1"	, "LIN_1")
	_oTPane2 := _oLayer1:GetWinPanel("COL_1"	, "JANELA_2"	, "LIN_2")
	
	@ 05,05 SAY "Container:" FONT oFontAB OF _oTPane1 Pixel
	@ 04,75 SAY Alltrim(cCTN) FONT oFontA OF _oTPane1  Pixel
	
	@ 25,05 SAY "Metros Cubicos:" FONT oFontAB OF _oTPane1  Pixel 
	@ 24,75 SAY Alltrim(cMTC) FONT oFontA OF _oTPane1  Pixel
    
	@ 45,05 SAY "Kilos(KG):" FONT oFontAB OF _oTPane1  Pixel
    @ 44,75 SAY Alltrim(cKG) FONT oFontA OF _oTPane1  Pixel
	
    dbSelectArea("ZAD")
    
    cQuery := " SELECT ZAD_CODCTN, ZAD_DATA, ZAD_VALMTC, ZAD_CUSTO, R_E_C_N_O_ FROM " + RetSqlName("ZAD")
    cQuery += " WHERE D_E_L_E_T_ = '' "
    cQuery += " AND ZAD_CODCTN = '" +ZAC->ZAC_CTN+ "' "
    cQuery += " ORDER BY ZAD_DATA "

    If Select("VALX") > 0
        VALX->(dbCloseArea())
    EndIf

    DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery) , 'VALX', .T., .F.)

    If VALX->(EOF())
        AADD(aColsSA,{dDataBase, 0, 0, 0,.F.})
    EndIf

    While VALX->(!EOF())
		AADD(aColsSA,{STOD(VALX->ZAD_DATA), VALX->ZAD_CUSTO, VALX->ZAD_VALMTC, VALX->R_E_C_N_O_,.F.})
		VALX->(dbSkip())
    EndDo
    
	For nlx := 1 to len(aColsSA)
		If aColsSA[nlx][POS_DATA] == dDataBase
			lGeraDia := .F.
			Exit
		EndIf
	Next

	If lGeraDia
		AADD(aColsSA,{dDataBase, 0, 0, 0,.F.})
	EndIf

	ASORT(aColsSA,,, { |x, y| x[1] > y[1] } )

    oListPR := MsNewGetDados():New( 017, 006, 120, 243, GD_UPDATE, /*"U_AtuToT2()"*/, /*"U_YTudoOk()"*/, "",aAlterCo,, 999, ;
			"U_vldCam2()", "", /*"U_YTudoOk()"*/, _oTPane2, aHeadSA, aColsSa)
	
    oListPR:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

//FIM PAINEL PRODUTOS
 ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg, {|| nOpc := u_2TudoOk(),Iif(nOpc == 1,oDlg:End(),)}, {|| oDlg:End() })

If nOpc == 1
	GrvCTN()	
EndIf

Return Nil

//--------------------------------------------------------------------
/*/{Protheus.doc} XTudoOk
Geração automatica do PO.

@author Rodrigo Nunes
@since 05/02/2021
/*/
//--------------------------------------------------------------------
User Function 2TudoOk()
	Local nOPRet  := 0
	Local nlx	  := 0
		
	For nlx := 1 to len(oListPR:aCols)
		If oListPR:aCols[nlx][POS_DATA] == dDataBase
			If oListPR:aCols[nlx][POS_CUSTO] <= 0
				Alert("Por favor preencha o Valor do Custo Total")
				Return nOPRet
			ElseIf oListPR:aCols[nlx][POS_VLR_MTC] <= 0
				Alert("Custo do MT³ zerado, favor verificar o cadastro do container!")
				Return nOPRet
			EndIf
			Exit
		EndIf
	Next

	nOPRet := 1

Return nOPRet

//--------------------------------------------------------------------
/*/{Protheus.doc} vldCam2
Validação por Celula

@author Rodrigo Nunes
@since 05/02/2021
/*/
//--------------------------------------------------------------------
User Function vldCam2()
	Local cCampAux 	:= ReadVar()
	Local lRet		:= .T.
    
	If cCampAux == "M->CUSTO" 
		If aColsSA[n][POS_DATA] <> dDatabase
            Alert("Não é permitido alterar um valor com a data difente de " + DTOC(dDatabase))
            lRet := .F.
        EndIf
        If lRet
            If &cCampAux < 0 
                Alert("Não é permitido valores negativos!!!")
                lRet := .F.
            Else
				oListPR:aCols[n][POS_VLR_MTC] := &cCampAux / ZAC->ZAC_MTC
            EndIf
        EndIf
	EndIf
	
	oListPR:SetArray(oListPR:aCols)
	oListPR:Refresh(.T.)
	oListPR:ForceRefresh()
	oListPR:oBrowse:Refresh() 
	_oTPane2:Refresh()
	oDlg:Refresh()

Return lRet

//--------------------------------------------------------------------
/*/{Protheus.doc} ExAutoPO
Geração automatica do PO

@author Rodrigo Nunes
@since 05/02/2021
/*/
//--------------------------------------------------------------------
Static Function GrvCTN() 	 
	Local nlx		:= 0
	Local nStatus	:= 0
    
	For nlx := 1 to len(oListPR:aCols)
		If oListPR:aCols[nlx][POS_DATA] == dDataBase
			If oListPR:aCols[nlx][RECNO] == 0 
				If RecLock("ZAD", .T.)
					ZAD->ZAD_FILIAL := xFilial("ZAC")
					ZAD->ZAD_CODCTN	:= cCTN
					ZAD->ZAD_DATA	:= oListPR:aCols[nlx][POS_DATA]
					ZAD->ZAD_VALMTC	:= oListPR:aCols[nlx][POS_VLR_MTC]
					ZAD->ZAD_CUSTO	:= oListPR:aCols[nlx][POS_CUSTO]
					ZAD->ZAD_ATIVO	:= "S"
					ZAD->(MsUnlock())

					nStatus := TcSqlExec("UPDATE ZAD010 SET ZAD_ATIVO = 'N' WHERE ZAD_FILIAL = '" +xFilial("ZAD")+ "' AND ZAD_CODCTN = '"+cCTN+"' AND ZAD_DATA <> '"+DTOS(dDataBase)+"' AND ZAD_ATIVO = 'S' AND  D_E_L_E_T_ = ' ' ")

					If (nStatus < 0)
						Alert("Rotina apresentou uma falha na gravaçao do registro de historico, o novo valor não sera salvo!")
						conout("TCSQLError() " + TCSQLError())
						
						RecLock("ZAD",.F.)
						ZAD->(dbDelete())
						ZAD->(MsUnlock())
					EndIf
				EndIf
			Else
				ZAD->(dbGoTo(oListPR:aCols[nlx][RECNO]))

				If ZAD->(Recno()) == oListPR:aCols[nlx][RECNO]
					If ZAD->ZAD_VALMTC == oListPR:aCols[nlx][POS_VLR_MTC] .AND. ZAD->ZAD_CUSTO == oListPR:aCols[nlx][POS_CUSTO]
						MsgInfo("Os valores não foram alterados, formulario não sera salvo", "Historico de Valores")
					Else
						RecLock("ZAD", .F.)
						ZAD->ZAD_VALMTC := oListPR:aCols[nlx][POS_VLR_MTC]
						ZAD->ZAD_CUSTO	:= oListPR:aCols[nlx][POS_CUSTO]
						ZAD->(MsUnlock())
					EndIf
				EndIf
			EndIf
			Exit
		EndIf
	Next

Return
