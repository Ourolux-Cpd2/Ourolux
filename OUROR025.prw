#Include "Protheus.ch"
#Include "TOTVS.CH"
#Include "TOPCONN.CH"

/*
Rotina: OUROR025
Descricao: Relatorio para Cotacao de Frete Internacional
Autor: Rodrigo Dias Nunes
Data: 26/07/2021
*/
User Function OUROR025()

    Processa({|| OUROR25()},"Gerando relatÛrio de Fretes Internacional...")

Return

Static Function OUROR25()
    Local oFWMsExcel
    Local aWorkSheet	:= {}
    Local X             := 1
    Local aLinha        := {}
    Local nlx           := 0
    Local cCor1         := "#F0F8FF"
    Local cCor2         := "#87CEFA"
    Local cCor          := ""
    Local cHora		    := Time()
    Local cNome		    := 'Relatorio_Frete_Internacional'+ DtoS(dDataBase)+ '_' + SubStr(cHora,1,2) + SubStr(cHora,4,2) + '.xls'
    Local lLinha        := .T.
    Local nTotFil       := 0
    Local nTotGer       := 0
    Local lFilSC        := .F.
    Local lFilFor       := .F.
    Local lFilPor       := .F.
    Local cSCAtu        := ""
    Local cForAtu       := ""
    Local cPorOAtu      := ""
    Local cPorDAtu      := ""
    Private cCaminho    := ""
    Private aParam      := {}

    PergPara()

    If Empty(cCaminho) .OR. Empty(aParam)
        Return(.T.)
    EndIf

    cQuery := " SELECT SW0.W0_C1_NUM, "
    cQuery += " 	   SW2.W2_PO_DT, "
    cQuery += "        SW2.W2_PO_NUM, "
    cQuery += "        SW2.W2_FORN, "
    cQuery += "        SW2.W2_FORLOJ, "
    cQuery += "        SW2.W2_ORIGEM, "
    cQuery += " 	   SW2.W2_DEST, "
    cQuery += "        SW2.W2_MT3, "
    cQuery += "        SW2.W2_XDT_ETA "
    cQuery += " FROM " + RetSqlName("SW2") + " SW2 "
    cQuery += " INNER JOIN " + RetSqlName("SW3") + " SW3 "
    cQuery += " ON SW3.W3_FILIAL = SW2.W2_FILIAL "
    cQuery += " AND SW3.W3_PO_NUM = SW2.W2_PO_NUM "
    cQuery += " AND SW3.D_E_L_E_T_ = '' "
    cQuery += " INNER JOIN " + RetSqlName("SW0") + " SW0 "
    cQuery += " ON SW0.W0__NUM = SW3.W3_SI_NUM "
    cQuery += " AND SW0.W0_C1_NUM BETWEEN '"+aParam[1]+"' AND '"+aParam[2]+"' "
    cQuery += " AND SW0.D_E_L_E_T_ = '' "
    cQuery += " WHERE  SW2.W2_XDT_ETA BETWEEN '"+DTOS(aParam[3])+"' AND '"+DTOS(aParam[4])+"' "
    cQuery += "        AND SW2.W2_FORN BETWEEN '"+aParam[5]+"' AND '"+aParam[7]+"' "
    cQuery += "        AND SW2.W2_FORLOJ BETWEEN '"+aParam[6]+"' AND '"+aParam[8]+"' "
    cQuery += "        AND SW2.W2_ORIGEM BETWEEN '"+aParam[9]+"' AND '"+aParam[10]+"' "
    cQuery += "        AND SW2.W2_DEST BETWEEN '"+aParam[11]+"' AND '"+aParam[12]+"' "    
    cQuery += "        AND SW2.D_E_L_E_T_ = '' "
    cQuery += " GROUP BY SW0.W0_C1_NUM, "
    cQuery += " 	   SW2.W2_PO_DT, "
    cQuery += "        SW2.W2_PO_NUM, "
    cQuery += "        SW2.W2_FORN, "
    cQuery += "        SW2.W2_FORLOJ, "
    cQuery += "        SW2.W2_ORIGEM, "
    cQuery += " 	   SW2.W2_DEST, "
    cQuery += "        SW2.W2_MT3, "
    cQuery += "        SW2.W2_XDT_ETA "
    
    If aParam[13] == 1
        cQuery += " ORDER BY SW0.W0_C1_NUM, W2_XDT_ETA
    ElseIf aParam[13] == 2
        cQuery += " ORDER BY SW2.W2_FORN, W2_XDT_ETA
    ElseIf aParam[13] == 3
        cQuery += " ORDER BY SW2.W2_ORIGEM, SW2.W2_DEST, W2_XDT_ETA
    EndIf 
    
    If Select("RELX") > 0
        RELX->(dbCloseArea())
    EndIf

    DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery) , 'RELX', .T., .F.)

        
    While RELX->(!EOF())
        AADD(aLinha,{RELX->W0_C1_NUM, STOD(RELX->W2_PO_DT), RELX->W2_PO_NUM, RELX->W2_FORN, Alltrim(GetAdvFVal("SA2","A2_NOME",xFilial("SA2") + RELX->W2_FORN + RELX->W2_FORLOJ,1 )), Alltrim(GetAdvFVal("SYR","YR_CID_ORI",xFilial("SYR") + "01" + RELX->W2_ORIGEM,1 )) , RELX->W2_DEST , STOD(RELX->W2_XDT_ETA), RELX->W2_MT3})
        RELX->(dbSkip())
    EndDo

    If Empty(aLinha)
        Alert("Nao ha dados a serem impressos!!!")
        Return(.T.)
    EndIf
    
    oFWMsExcel := FWMSExcelEx():New()

    aAdd(aWorkSheet,"Analise para Cotacao Frete Internacional")
    oFWMsExcel:AddworkSheet( aWorkSheet[x] ) 
    oFWMsExcel:AddTable( aWorkSheet[x], aWorkSheet[x] ) 
    oFWMsExcel:AddColumn(aWorkSheet[x], aWorkSheet[x], "Numero SC"      ,1,4,.F.)
    oFWMsExcel:AddColumn(aWorkSheet[x], aWorkSheet[x], "Emissao PO"     ,1,4,.F.)
    oFWMsExcel:AddColumn(aWorkSheet[x], aWorkSheet[x], "Numero PO" 	    ,1,1,.F.)
    oFWMsExcel:AddColumn(aWorkSheet[x], aWorkSheet[x], "Fornecedor"	    ,1,1,.F.)
    oFWMsExcel:AddColumn(aWorkSheet[x], aWorkSheet[x], "Nome" 	        ,1,1,.F.)
    oFWMsExcel:AddColumn(aWorkSheet[x], aWorkSheet[x], "Porto Origem"   ,1,1,.F.)
    oFWMsExcel:AddColumn(aWorkSheet[x], aWorkSheet[x], "Porto Destino"  ,1,1,.F.)
    oFWMsExcel:AddColumn(aWorkSheet[x], aWorkSheet[x], "ETA"            ,1,4,.F.)
    oFWMsExcel:AddColumn(aWorkSheet[x], aWorkSheet[x], "MT Cubico"      ,1,2,.F.)

    If aParam[13] == 1
        lFilSC := .T.
    ElseIf aParam[13] == 2
        lFilFor := .T.
    ElseIf aParam[13] == 3
        lFilPor := .T.
    EndIf

    For nlx := 1 to Len(aLinha)

        If nlx == 1
            If lFilSC
                cSCAtu := aLinha[nlx][1]
            ElseIf lFilFor
                cForAtu := aLinha[nlx][4]
            ElseIf lFilPor
                cPorOAtu := aLinha[nlx][6]
                cPorDAtu := aLinha[nlx][7]
            EndIf
        EndIF

        If lFilSC
            If cSCAtu <> aLinha[nlx][1]
                oFWMsExcel:SetCelBold(.T.)
                oFWMsExcel:AddRow(aWorkSheet[X], aWorkSheet[X], {,,,,,,,,nTotFil},{1,2,3,4,5,6,7,8,9} )
                nTotFil := 0
                lLinha := !lLinha
                cSCAtu := aLinha[nlx][1]
            EndIf
        ElseIf lFilFor
            If cForAtu <> aLinha[nlx][4]
                oFWMsExcel:SetCelBold(.T.)
                oFWMsExcel:AddRow(aWorkSheet[X], aWorkSheet[X], {,,,,,,,,nTotFil},{1,2,3,4,5,6,7,8,9} )
                nTotFil := 0
                lLinha := !lLinha
                cForAtu := aLinha[nlx][4]
            EndIf
        ElseIf lFilPor
            If cPorOAtu <> aLinha[nlx][6] .OR. cPorDAtu <> aLinha[nlx][7]
                oFWMsExcel:SetCelBold(.T.)
                oFWMsExcel:AddRow(aWorkSheet[X], aWorkSheet[X], {,,,,,,,,nTotFil},{1,2,3,4,5,6,7,8,9} )
                nTotFil := 0
                lLinha := !lLinha
                cForAtu := aLinha[nlx][4]
                cPorOAtu := aLinha[nlx][6]
                cPorDAtu := aLinha[nlx][7]
            EndIf
        EndIf

        nTotFil += aLinha[nlx][9]
        nTotGer += aLinha[nlx][9]

        If lLinha
            cCor := cCor1   
        else
            cCor := cCor2
        endIf
        
        oFWMsExcel:SetCelBold(.F.)
        oFWMsExcel:SetCelBgColor(cCor)
        oFWMsExcel:AddRow(aWorkSheet[X], aWorkSheet[X], {aLinha[nlx][1],aLinha[nlx][2],aLinha[nlx][3],aLinha[nlx][4],aLinha[nlx][5],aLinha[nlx][6],aLinha[nlx][7],aLinha[nlx][8],aLinha[nlx][9]},{1,2,3,4,5,6,7,8,9} )
        
        If nlx == Len(aLinha)
            oFWMsExcel:SetCelBold(.T.)
            oFWMsExcel:AddRow(aWorkSheet[X], aWorkSheet[X], {,,,,,,,,nTotFil},{1,2,3,4,5,6,7,8,9} )
            nTotFil := 0
            lLinha := !lLinha
            
            If lLinha
                cCor := cCor1   
            else
                cCor := cCor2
            endIf
            
            oFWMsExcel:SetCelBgColor(cCor)
            oFWMsExcel:AddRow(aWorkSheet[X], aWorkSheet[X], {,,,,"TOTAL GERAL",,,,nTotGer},{1,2,3,4,5,6,7,8,9} )

        EndIf
        
    Next

    oFWMsExcel:Activate()
    oFWMsExcel:GetXMLFile(cCaminho + cNome)
    oExcel := MsExcel():New()
    oExcel:WorkBooks:Open(cCaminho + cNome)
    oExcel:SetVisible(.T.)
    //oExcel:Destroy()
    shellExecute( "Open", cCaminho + cNome, "", "", 1 )
    msgalert("Planilha Gerada em: "+(cCaminho + cNome))  


Return

//--------------------------------------------------------------------
/*/{Protheus.doc} PergPara
Rotina de Perguntas
@author Rodrigo Nunes
@since 26/07/2021
@version 1.0 
@type function
/*/
//--------------------------------------------------------------------
Static Function PergPara()
Local aRet	 := {}
Local aPergs := {}
local tmp    := getTempPath()
Local aCombo := {"Solicitacao de Compra","Fornecedor","Porto Origem/Destino"}

aAdd(aPergs, {1, "Numero SC de"         ,Space(6)           ,"","","SC1","",50,.F.}) 
aAdd(aPergs, {1, "Numero SC ate"        ,"ZZZZZZ"           ,"","","SC1","",50,.T.}) 
aAdd(aPergs, {1, "ETA de"               ,Ctod(Space(8))     ,"","",""   ,"",50,.T.})
aAdd(aPergs, {1, "ETA ate"              ,Ctod(Space(8))     ,"","",""   ,"",50,.T.})
aAdd(aPergs, {1, "Fornecedor de"        ,Space(6)           ,"","","SA2","",50,.F.}) 
aAdd(aPergs, {1, "Loja de"              ,Space(2)           ,"","",""   ,"",50,.F.}) 
aAdd(aPergs, {1, "Fornecedor ate"       ,"ZZZZZZ"           ,"","","SA2","",50,.T.}) 
aAdd(aPergs, {1, "Loja ate"             ,"ZZ"               ,"","",""   ,"",50,.T.}) 
aAdd(aPergs, {1, "Porto Origem de"      ,Space(3)           ,"","","SYR","",50,.F.}) 
aAdd(aPergs, {1, "Porto Origem ate"     ,"ZZZ"              ,"","","SYR","",50,.T.}) 
aAdd(aPergs, {1, "Porto Destino de"     ,Space(3)           ,"","","SYR","",50,.F.}) 
aAdd(aPergs, {1, "Porto Destino ate"    ,"ZZZ"              ,"","","SYR","",50,.T.}) 
aAdd(aPergs, {2, "OrdenaÁ„o"            ,3                  ,aCombo ,100,""   ,.T.})

If ParamBox(aPergs,"Impressao",@aRet)
	aParam   := AjRetParam(aRet,aPergs)
    cCaminho := cGetFile( , 'Selecione a pasta de destino', , tmp, .F., GETF_LOCALHARD+GETF_RETDIRECTORY,.F.)
EndIf

Return

//--------------------------------------------------------------------
/*/{Protheus.doc} AjRetParam
Func√£o de ajuste do conte√∫do da ParamBox.

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
