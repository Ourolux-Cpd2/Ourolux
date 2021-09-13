#Include "Protheus.ch"
#Include "TOTVS.CH"
#Include "TOPCONN.CH"
/*
Rotina: OUROR026
Relatorio de Estrutura x Custo 
Autor: Rodrigo Dias Nunes
Data: 02/09/2021
*/
User Function OUROR026()

    Processa({|| OUROR26()},"Gerando relat�rio de Estrutura x Custo...")

Return

Static Function OUROR26()
    Local oFWMsExcel
    Local aWorkSheet	:= {}
    Local X             := 1
    Local aLinha        := {}
    Local nlx           := 0
    Local cHora		    := Time()
    Local cNome		    := 'Estrutura_x_Custo_'+ DtoS(dDataBase)+ '_' + SubStr(cHora,1,2) + SubStr(cHora,4,2) + ".xls"
    Local cProdVez      := ""
    Local nCusto        := 0
    Private cCaminho    := ""
    Private aParam      := {}

    PergPara()

    If Empty(cCaminho) .OR. Empty(aParam)
        Return(.T.)
    EndIf

    cQuery := " SELECT 	SG1.G1_COD AS PRODUTO, "
    cQuery += " 		SG1.G1_COMP AS COMPONENTE, "
    cQuery += " 		SG1.G1_QUANT AS QUANTIDADE, "
    cQuery += "         SB2.B2_CM1 AS CUSTO_UNIT, "
    cQuery += " 		(SG1.G1_QUANT * SB2.B2_CM1) AS CUSTO "
    cQuery += " FROM "
    cQuery += " 	( "
    cQuery += " 		SELECT * FROM " + RetSqlName("SG1")
    cQuery += " 		WHERE G1_COD BETWEEN '"+aParam[1]+"' AND '"+aParam[2]+"' "
    cQuery += " 		AND G1_INI <= '"+DTOS(dDataBase)+"' "
    cQuery += " 		AND G1_FIM >= '"+DTOS(dDataBase)+"' "
    cQuery += " 		AND D_E_L_E_T_ = '' "
    cQuery += " 	) SG1 "
    cQuery += " LEFT JOIN " + RetSqlName("SB2") + " SB2 "
    cQuery += " 	ON SB2.B2_COD = SG1.G1_COMP "
    cQuery += " 	AND SB2.B2_FILIAL = '"+xFilial("SB2")+"' "
    cQuery += " 	AND SB2.B2_LOCAL = '01' "
    cQuery += " 	AND SB2.D_E_L_E_T_ = '' "
    cQuery += " ORDER BY G1_COD, G1_COMP "
    
    If Select("RELX") > 0
        RELX->(dbCloseArea())
    EndIf

    DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery) , 'RELX', .T., .F.)

    
    While RELX->(!EOF())
        AADD(aLinha,{Alltrim(RELX->PRODUTO),Alltrim(RELX->COMPONENTE),RELX->QUANTIDADE,Round(RELX->CUSTO,4),Round(RELX->CUSTO_UNIT,4)})
        RELX->(dbSkip())
    EndDo

    If Empty(aLinha)
        Alert("Nao a dados a serem impressos!!!")
        Return(.T.)
    EndIf
    
    oFWMsExcel := FWMSExcelEx():New()

    aAdd(aWorkSheet,"Estrutura x Custo")
    oFWMsExcel:AddworkSheet( aWorkSheet[x] ) 
    oFWMsExcel:AddTable( aWorkSheet[x], aWorkSheet[x] ) 
    oFWMsExcel:AddColumn(aWorkSheet[x], aWorkSheet[x], "PRODUTO"         ,1,4,.F.)
    oFWMsExcel:AddColumn(aWorkSheet[x], aWorkSheet[x], "COMPONENTE" 	 ,1,1,.F.)
    oFWMsExcel:AddColumn(aWorkSheet[x], aWorkSheet[x], "DESCRICAO"   	 ,1,1,.F.)
    oFWMsExcel:AddColumn(aWorkSheet[x], aWorkSheet[x], "QTD"	         ,1,1,.F.)
    oFWMsExcel:AddColumn(aWorkSheet[x], aWorkSheet[x], "CUSTO UNIT."     ,1,1,.F.)
    oFWMsExcel:AddColumn(aWorkSheet[x], aWorkSheet[x], "CUSTO TOT. ITEM" ,1,1,.F.)
        
    For nlx := 1 to Len(aLinha)

        If Empty(cProdVez)
            cProdVez := aLinha[nlx][1]
            oFWMsExcel:AddRow(aWorkSheet[X], aWorkSheet[X], {aLinha[nlx][1] + " - " + Alltrim(GetAdvFVal("SB1","B1_DESC",xFilial("SB1")+aLinha[nlx][1],1,"")),/*componente*/,/*descricao*/,/*quantidade*/,/*custo unit*/,/*custo tot*/} )
            oFWMsExcel:AddRow(aWorkSheet[X], aWorkSheet[X], {/*produto*/,aLinha[nlx][2],Alltrim(GetAdvFVal("SB1","B1_DESC",xFilial("SB1")+aLinha[nlx][2],1,"")),aLinha[nlx][3],aLinha[nlx][5],aLinha[nlx][4]} )
            nCusto += aLinha[nlx][4]
            If Len(aLinha) == nlx
                oFWMsExcel:SetCelBgColor("#4f81bd")
                oFWMsExcel:SetCelBold(.T.)
                oFWMsExcel:AddRow(aWorkSheet[X], aWorkSheet[X], {/*produto*/,/*componente*/,"TOTAL DO CUSTO",/*quantidade*/,,Transform(nCusto,PesqPict("SC6","C6_VALOR"))},{1,2,3,4,5,6})
                nCusto   := 0
            EndIf
            Loop
        EndIf

        If cProdVez == aLinha[nlx][1]
            oFWMsExcel:AddRow(aWorkSheet[X], aWorkSheet[X], {/*produto*/,aLinha[nlx][2],Alltrim(GetAdvFVal("SB1","B1_DESC",xFilial("SB1")+aLinha[nlx][2],1,"")),aLinha[nlx][3],aLinha[nlx][5],aLinha[nlx][4]} )
            nCusto += aLinha[nlx][4]
            If Len(aLinha) == nlx
                oFWMsExcel:SetCelBgColor("#4f81bd")
                oFWMsExcel:SetCelBold(.T.)
                oFWMsExcel:AddRow(aWorkSheet[X], aWorkSheet[X], {/*produto*/,/*componente*/,"TOTAL DO CUSTO",/*quantidade*/,,Transform(nCusto,PesqPict("SC6","C6_VALOR"))},{1,2,3,4,5,6})
                nCusto   := 0
            EndIf
        Else
            oFWMsExcel:SetCelBgColor("#4f81bd")
            oFWMsExcel:SetCelBold(.T.)
            oFWMsExcel:AddRow(aWorkSheet[X], aWorkSheet[X], {/*produto*/,/*componente*/,"TOTAL DO CUSTO",/*quantidade*/,,Transform(nCusto,PesqPict("SC6","C6_VALOR"))},{1,2,3,4,5,6})
            nCusto   := 0
            cProdVez := aLinha[nlx][1]
            oFWMsExcel:AddRow(aWorkSheet[X], aWorkSheet[X], {aLinha[nlx][1] + " - " + Alltrim(GetAdvFVal("SB1","B1_DESC",xFilial("SB1")+aLinha[nlx][1],1,"")),/*componente*/,/*descricao*/,/*quantidade*/,/*custo*/,} )
            oFWMsExcel:AddRow(aWorkSheet[X], aWorkSheet[X], {/*produto*/,aLinha[nlx][2],Alltrim(GetAdvFVal("SB1","B1_DESC",xFilial("SB1")+aLinha[nlx][2],1,"")),aLinha[nlx][3],aLinha[nlx][5],aLinha[nlx][4]} )
            nCusto += aLinha[nlx][4]
            If Len(aLinha) == nlx
                oFWMsExcel:SetCelBgColor("#4f81bd")
                oFWMsExcel:SetCelBold(.T.)
                oFWMsExcel:AddRow(aWorkSheet[X], aWorkSheet[X], {/*produto*/,/*componente*/,"TOTAL DO CUSTO",/*quantidade*/,,Transform(nCusto,PesqPict("SC6","C6_VALOR"))},{1,2,3,4,5,6})
                nCusto   := 0
            EndIf
        EndIF
        
    Next

    oFWMsExcel:Activate()
    oFWMsExcel:GetXMLFile(cCaminho + cNome)
    oExcel := MsExcel():New()
    oExcel:WorkBooks:Open(cCaminho + cNome)
    oExcel:SetVisible(.T.)
    shellExecute( "Open", cCaminho + cNome, "", "", 1 )
    msgalert("Planilha Gerada em: "+(cCaminho + cNome))  


Return

//--------------------------------------------------------------------
/*/{Protheus.doc} PergPara
Rotina de Perguntas
@author Rodrigo Nunes
@since 02/09/2021
@version 1.0 
@type function
/*/
//--------------------------------------------------------------------
Static Function PergPara()
Local aRet	 := {}
Local aPergs := {}
local tmp    := getTempPath()

aAdd(aPergs, {1, "Estutura Produdo de"  ,Space(15) ,"","","SG1","",85,.F.})
aAdd(aPergs, {1, "Estutura Produdo ate" ,Space(15) ,"","","SG1","",85,.T.})

If ParamBox(aPergs,"Impressao",@aRet)
	aParam   := AjRetParam(aRet,aPergs)
    cCaminho := cGetFile( , 'Selecione a pasta de destino', , tmp, .F., GETF_LOCALHARD+GETF_RETDIRECTORY,.F.)
EndIf

Return

//--------------------------------------------------------------------
/*/{Protheus.doc} AjRetParam
Funcão de ajuste do conteúdo da ParamBox.

@author Rodrigo Nunes
@since 26/07/2021
/*/
//--------------------------------------------------------------------
Static Function AjRetParam(aRet,aParamBox)
	Local nX		:= 0
	
	If ValType(aRet) == "A" .And. Len(aRet) == Len(aParamBox)
		For nX := 1 to Len(aParamBox)
			If aParamBox[nX][1] == 1
				aRet[nX] := aRet[nX]
			ElseIf aParamBox[nX][1] == 2 .And. ValType(aRet[nX]) == "C"
				aRet[nX] := aScan(aParamBox[nX][4],{|x| AllTrim(x) == aRet[nX]})
			ElseIf aParamBox[nX][1] == 2 .And. ValType(aRet[nX]) == "N"
				aRet[nX] := aRet[nX]
			EndIf
		Next nX
	EndIf
	
Return aRet
