#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "RWMAKE.CH"

#DEFINE POS_SKU         1

#DEFINE POS_COBERTURA   1
#DEFINE POS_PRODUTO_DE  2
#DEFINE POS_PRODUTO_ATE 3
#DEFINE POS_FAMILIA_DE  4
#DEFINE POS_FAMILIA_ATE 5
#DEFINE POS_FILIAL_DE   6
#DEFINE POS_FILIAL_ATE  7

#DEFINE POS_EX_COD      1
#DEFINE POS_EX_DES      2
#DEFINE POS_EX_UM       3
#DEFINE POS_EX_PAS1     4 
#DEFINE POS_EX_PAS2     5 
#DEFINE POS_EX_PAS3     6
#DEFINE POS_EX_MED      7
#DEFINE POS_EX_FOR1     8
#DEFINE POS_EX_FOR2     9
#DEFINE POS_EX_FOR3     10
#DEFINE POS_EX_SALDO    11
#DEFINE POS_EX_PREV     12
#DEFINE POS_EX_PEDCOM   13
#DEFINE POS_EX_ESTFIM   14
#DEFINE POS_EX_COB      15


//--------------------------------------------------------------------
/*/{Protheus.doc} OUROR031
Relatorio OverStock
@author Rodrigo Nunes
@since 31/08/2021
/*/
//--------------------------------------------------------------------
User Function OUROR031()
    Private aArquivo := {}
    Private aParam   := {}
    Private cCaminho := ""
    
    PergPara()
        
    If !Empty(aParam)
        Processa({|| OURO08B()})
    EndIf
Return(Nil)

//--------------------------------------------------------------------
/*/{Protheus.doc} PergPara
Rotina de Perguntas
@author Rodrigo Nunes
@since 01/09/2021
@version 1.0 
@type function
/*/
//--------------------------------------------------------------------
Static Function PergPara()
    Local aRet	 := {}
    Local aPergs := {}
    local tmp    := getTempPath()

    aAdd(aPergs, {1, "Limite Estoque"       ,0                              ,"@E 99.9"  ,"",""      ,"",30,.T.}) 
    aAdd(aPergs, {1, "Produto de"           ,Space(TAMSX3("B1_COD")[1])     ,""         ,"","SB1"   ,"",85,.F.}) 
    aAdd(aPergs, {1, "Produto ate"          ,Space(TAMSX3("B1_COD")[1])     ,""         ,"","SB1"   ,"",85,.T.}) 
    aAdd(aPergs, {1, "Familia de"           ,Space(TAMSX3("BM_GRUPO")[1])   ,""         ,"","SBM"   ,"",40,.F.}) 
    aAdd(aPergs, {1, "Familia ate"          ,Space(TAMSX3("BM_GRUPO")[1])   ,""         ,"","SBM"   ,"",40,.T.}) 
    aAdd(aPergs, {1, "Filial de"            ,Space(2)                       ,""         ,"","FWSM0" ,"",30,.F.}) 
    aAdd(aPergs, {1, "Filial ate"           ,Space(2)                       ,""         ,"","FWSM0" ,"",30,.T.}) 

    If ParamBox(aPergs,"Impressao",@aRet)
        aParam   := AjRetParam(aRet,aPergs)
        cCaminho := cGetFile( , 'Selecione a pasta de destino', , tmp, .F., GETF_LOCALHARD+GETF_RETDIRECTORY,.F.)
    EndIf

Return

//--------------------------------------------------------------------
/*/{Protheus.doc} AjRetParam
Funcao de ajuste do conteudo da ParamBox.

@author Rodrigo Nunes
@since 01/09/2021
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

//--------------------------------------------------------------------
/*/{Protheus.doc} OURO08B
Relatorio de Over Stock
@author Rodrigo Nunes
@since 20/08/2021
/*/
//--------------------------------------------------------------------
Static Function OURO08B()
    Local oFWMsExcel
    Local aWorkSheet	:= {}
    Local X             := 1
    Local aLinha        := {}
    Local nlx           := 0
    Local cCor1         := "#F0F8FF" 
    Local cCor2         := "#87CEFA" 
    Local cCor          := ""
    Local cHora		    := Time()
    Local cNome		    := 'OverStock_'+ DtoS(dDataBase)+ '_' + SubStr(cHora,1,2) + SubStr(cHora,4,2) + '.xls'
    Local lLinha        := .T.
    Local cDataDe       := ""
    Local cDataAte      := ""
    Local aDataCab      := {}
    Local aDataFor      := {}
    Local aMovPas       := {}
    Local cDataAux      := ""
    Local cDtAux        := ""
    Local nLin          := 0
    Local nPosD         := 0
    Local nPosF         := 0
    Local nMedia        := 0
    
    If Empty(cCaminho) .OR. Empty(aParam)
        Return(.T.)
    EndIf

    cQuery := " SELECT DISTINCT(SC4.C4_PRODUTO) as PRODUTO "
    cQuery += " FROM " + RetSqlName("SC4") + " SC4 "
    cQuery += " INNER JOIN " + RetSqlName("SB1") + " SB1 "
    cQuery += " 	ON SB1.B1_COD = SC4.C4_PRODUTO "
    cQuery += " 	AND SB1.D_E_L_E_T_ = '' "
    cQuery += " INNER JOIN " + RetSqlName("SBM") + " SBM "
    cQuery += " 	ON SBM.BM_GRUPO = SB1.B1_GRUPO "
    cQuery += "     AND SBM.BM_GRUPO BETWEEN '" +aParam[POS_FAMILIA_DE]+ "' AND '" +aParam[POS_FAMILIA_ATE]+ "' ""
    cQuery += " 	AND SBM.D_E_L_E_T_ = '' "
    cQuery += " WHERE SC4.C4_PRODUTO BETWEEN '" +aParam[POS_PRODUTO_DE]+ "' AND '" +aParam[POS_PRODUTO_ATE]+ "' "
    cQuery += " AND SC4.D_E_L_E_T_ = '' "
    cQuery += " ORDER BY C4_PRODUTO "
    
    If Select("PROD") > 0
        PROD->(dbCloseArea())
    EndIf

    DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery) , 'PROD', .T., .F.)

    cDataDe  := DTOS(FirstDate(FirstDate(dDataBase) - 90))
    cDataAte := DTOS(LastDate(FirstDate(dDataBase) - 1))
    
    //montando cabe?alho dos passado
    cDtAux := dDataBase

    While .T.
        cDataAux := DTOS(FirstDate(cDtAux) - 1)
        
        If Len(aDataCab) == 3
            Exit
        else
            AADD(aDataCab,SubStr(cDataAux,1,6))
        EndIf

        cDtAux := STOD(cDataAux)
    EndDo

    ASORT(aDataCab,,, { |x| x > x } ) 

    //montando cabe?alho do futuro
    cDtAux := dDataBase

    While .T.

        If Empty(aDataFor)
            AADD(aDataFor,SubStr(DTOS(dDataBase),1,6))
        EndIf

        cDataAux := DTOS(LastDate(cDtAux) + 1)
        
        If Len(aDataFor) == 3
            Exit
        else
            AADD(aDataFor,SubStr(cDataAux,1,6))
        EndIf

        cDtAux := STOD(cDataAux)
    EndDo

    While PROD->(!EOF())
        
        nLin++
        AADD(aLinha,{Alltrim(PROD->PRODUTO),;
        GetAdvFVal("SB1","B1_DESC",xFilial("SB1")+Alltrim(PROD->PRODUTO),1,""),;
        GetAdvFVal("SB1","B1_UM",xFilial("SB1")+Alltrim(PROD->PRODUTO),1,""),;
        "","","","","","","","","","","",""})

        //Seleciona as movimenta??es
        cQuery := " SELECT	SD2.D2_COD AS Codigo, "
        cQuery += " 		  	SUBSTRING(SD2.D2_EMISSAO, 1, 6) AS Periodo, "
        cQuery += " 		  	SUM(SD2.D2_QUANT) AS Qde "
        cQuery += " FROM " + RetSqlName("SD2") +" SD2 "
        cQuery += " 		INNER JOIN SB1010 SB1 "
        cQuery += " 			ON SB1.B1_FILIAL = '' "
        cQuery += " 			AND SB1.B1_COD = SD2.D2_COD "
        cQuery += " 		INNER JOIN " + RetSqlName("SF2") +" SF2 "
        cQuery += " 			ON SF2.F2_FILIAL = SD2.D2_FILIAL "
        cQuery += " 			AND SF2.F2_SERIE = SD2.D2_SERIE "
        cQuery += " 			AND SF2.F2_DOC = SD2.D2_DOC "
        cQuery += " 			AND SF2.F2_CLIENTE = SD2.D2_CLIENTE "
        cQuery += " 			AND SF2.F2_LOJA = SD2.D2_LOJA "
        cQuery += " 		INNER JOIN " + RetSqlName("SF4") +" SF4 "
        cQuery += " 			ON SF4.F4_CODIGO = SD2.D2_TES "
        cQuery += " WHERE SD2.D2_EMISSAO BETWEEN '"+cDataDe+"' AND '"+cDataAte+"' "
        cQuery += " AND SD2.D_E_L_E_T_ <> '*' "
        cQuery += " AND SD2.D2_TIPO = 'N' "
        cQuery += " AND SD2.D2_COD = '" +Alltrim(PROD->PRODUTO)+ "' "
        cQuery += " AND SF2.F2_FILIAL BETWEEN '" + aParam[POS_FILIAL_DE] + "' AND '" + aParam[POS_FILIAL_ATE] + "' "
        cQuery += " AND SD2.D2_TIPO = SF2.F2_TIPO "
        cQuery += " AND SB1.D_E_L_E_T_ <> '*' "
        cQuery += " AND SF2.D_E_L_E_T_ <> '*' "
        cQuery += " AND B1_MSBLQL <> '1' "
        cQuery += " AND SF2.F2_CLIENTE NOT IN ('008360','020793') "
        cQuery += " AND SF4.D_E_L_E_T_ <> '*' "
        cQuery += " AND F4_ESTOQUE = 'S' "
        cQuery += " GROUP  BY SD2.D2_COD, SUBSTRING(SD2.D2_EMISSAO, 1, 6) "
        cQuery += " ORDER BY PERIODO "

        cQuery := ChangeQuery(cQuery)
        
        If Select("PASX") > 0
            PASX->(dbCloseArea())
        EndIf

        DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery) , 'PASX', .T., .F.)

        While PASX->(!EOF())
            AADD(aMovPas,{PASX->CODIGO, PASX->PERIODO, PASX->QDE})
            PASX->(dbSkip())
        EndDo

        cXDataDe  := DTOS(FirstDate(dDataBase))
        cXDataAte := DTOS(LastDate(FirstDate(dDataBase) + 90))

        For nlx := 1 to len(aMovPas)
            
            nPosD := aScan(aDataCab,{|x| AllTrim(x) == aMovPas[nlx][2]})
            
            If nPosD == 1
                aLinha[nLin][POS_EX_PAS1] := aMovPas[nlx][3]
            ElseIf nPosD == 2
                aLinha[nLin][POS_EX_PAS2] := aMovPas[nlx][3]
            ElseIf nPosD == 3
                aLinha[nLin][POS_EX_PAS3] := aMovPas[nlx][3]
            EndIf
        Next

        nMedia := 0
        nMedia := Iif(!Empty(aLinha[nLin][POS_EX_PAS1]),aLinha[nLin][POS_EX_PAS1],0) + Iif(!Empty(aLinha[nLin][POS_EX_PAS2]),aLinha[nLin][POS_EX_PAS2],0) + Iif(!Empty(aLinha[nLin][POS_EX_PAS3]),aLinha[nLin][POS_EX_PAS3],0)
        nMedia := nMedia / 3
        
        aLinha[nLin][POS_EX_MED] := nMedia

        aMovPas := {}

        cQuery := " SELECT C4_QUANT AS QUANTIDADE, SUBSTRING(C4_DATA, 1, 6) AS PERIODO "
        cQuery += " FROM " + RetSqlName("SC4") + " SC4 "
        cQuery += " INNER JOIN " + RetSqlName("SB1") + " SB1 "
        cQuery += " 	ON SB1.B1_COD = SC4.C4_PRODUTO "
        cQuery += " 	AND SB1.D_E_L_E_T_ = '' "
        cQuery += " INNER JOIN " + RetSqlName("SBM") + " SBM "
        cQuery += " 	ON SBM.BM_GRUPO = SB1.B1_GRUPO "
        cQuery += "     AND SBM.BM_GRUPO BETWEEN '" +aParam[POS_FAMILIA_DE]+ "' AND '" +aParam[POS_FAMILIA_ATE]+ "' ""
        cQuery += " 	AND SBM.D_E_L_E_T_ = '' "
        cQuery += " WHERE SC4.C4_PRODUTO BETWEEN '" +aParam[POS_PRODUTO_DE]+ "' AND '" +aParam[POS_PRODUTO_ATE]+ "' "
        cQuery += " AND SC4.C4_DATA BETWEEN '"+cXDataDe+"' AND '"+cXDataAte+"' "
        cQuery += " AND SC4.C4_PRODUTO = '"+Alltrim(PROD->PRODUTO)+"' "
        cQuery += " AND SC4.D_E_L_E_T_ = '' "
        cQuery += " ORDER BY C4_PRODUTO "
    
        cQuery := ChangeQuery(cQuery)
        
        If Select("FORX") > 0
            FORX->(dbCloseArea())
        EndIf

        DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery) , 'FORX', .T., .F.)

        While FORX->(!EOF())
            
            nPosF := aScan(aDataFor,{|x| AllTrim(x) == FORX->PERIODO})
            
            If nPosF == 1
                aLinha[nLin][POS_EX_FOR1] := FORX->QUANTIDADE
            ElseIf nPosF == 2
                aLinha[nLin][POS_EX_FOR2] := FORX->QUANTIDADE
            ElseIf nPosF == 3
                aLinha[nLin][POS_EX_FOR3] := FORX->QUANTIDADE
            EndIf
            
            FORX->(dbSkip())
        
        EndDo

        cQuery := " SELECT SUM(B2_QATU) AS TOTAL FROM " + RetSqlName("SB2")
        cQuery += " WHERE B2_COD = '"+Alltrim(PROD->PRODUTO)+"' "
        cQuery += " AND B2_FILIAL BETWEEN '" + aParam[POS_FILIAL_DE] + "' AND '" + aParam[POS_FILIAL_ATE] + "' "
        cQuery += " AND D_E_L_E_T_ = '' "
        
        If Select("ESTX") > 0
            ESTX->(dbCloseArea())
        EndIf

        DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery) , 'ESTX', .T., .F.)

        If ESTX->(!EOF())
            aLinha[nLin][POS_EX_SALDO] := ESTX->TOTAL
        EndIf

        cQuery := " SELECT SUM(SC6.C6_QTDVEN) AS TOTAL"
        cQuery += " FROM " + RetSqlName("SC6") + " SC6 "
        cQuery += " INNER JOIN " + RetSqlName("SC5") + " SC5 "
        cQuery += " ON SC5.C5_NUM = SC6.C6_NUM "
        cQuery += " AND SC5.C5_FILIAL = SC6.C6_FILIAL "
        cQuery += " AND SC5.C5_EMISSAO BETWEEN '"+DTOS(FirstDate(dDataBase))+"' AND '"+DTOS(LastDate(dDataBase))+"' "
        cQuery += " AND SC5.D_E_L_E_T_ = '' "
        cQuery += " WHERE SC6.C6_FILIAL BETWEEN '" + aParam[POS_FILIAL_DE] + "' AND '" + aParam[POS_FILIAL_ATE] + "' "
        cQuery += " AND SC6.C6_PRODUTO = '"+Alltrim(PROD->PRODUTO)+"' "
        cQuery += " AND SC6.D_E_L_E_T_ = '' "
        
        If Select("PVX") > 0
            PVX->(dbCloseArea())
        EndIf

        DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery) , 'PVX', .T., .F.)

        If PVX->(!EOF())
            aLinha[nLin][POS_EX_PREV] := PVX->TOTAL
        EndIf
        
        cQuery := " SELECT SUM(C7_QUANT) AS TOTAL  FROM " + RetSqlName("SC7")
        cQuery += " WHERE C7_FILIAL BETWEEN '" + aParam[POS_FILIAL_DE] + "' AND '" + aParam[POS_FILIAL_ATE] + "' "
        cQuery += " AND C7_PRODUTO = '"+Alltrim(PROD->PRODUTO)+"' "
        cQuery += " AND C7_DATPRF BETWEEN '"+DTOS(FirstDate(dDataBase))+"' AND '"+DTOS(LastDate(dDataBase))+"' "
        cQuery += " AND D_E_L_E_T_ = '' "

        If Select("PCX") > 0
            PCX->(dbCloseArea())
        EndIf

        DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery) , 'PCX', .T., .F.)

        If PCX->(!EOF())
            aLinha[nLin][POS_EX_PEDCOM] := PCX->TOTAL
        EndIf

        If Empty(aLinha[nLin][POS_EX_FOR1])
            aLinha[nLin][POS_EX_FOR1] := 0
        EndIf

        aLinha[nLin][POS_EX_ESTFIM] := ((aLinha[nLin][POS_EX_SALDO] + aLinha[nLin][POS_EX_PEDCOM]) - Iif(aLinha[nLin][POS_EX_FOR1] - aLinha[nLin][POS_EX_PREV] <= 0, 0,aLinha[nLin][POS_EX_FOR1] - aLinha[nLin][POS_EX_PREV]))
        
        CONOUT("RODRIGO-" )
        CONOUT(aLinha[nLin][POS_EX_COD])
        CONOUT(aLinha[nLin][POS_EX_FOR1])
        CONOUT(aLinha[nLin][POS_EX_FOR2])
        CONOUT(aLinha[nLin][POS_EX_FOR3])

        nValAux := ((Iif(ValType(aLinha[nLin][POS_EX_FOR1]) == "C", Val(aLinha[nLin][POS_EX_FOR1]), aLinha[nLin][POS_EX_FOR1]) +;
                     Iif(ValType(aLinha[nLin][POS_EX_FOR2]) == "C", Val(aLinha[nLin][POS_EX_FOR2]), aLinha[nLin][POS_EX_FOR2]) +;
                     Iif(ValType(aLinha[nLin][POS_EX_FOR3]) == "C", Val(aLinha[nLin][POS_EX_FOR3]), aLinha[nLin][POS_EX_FOR3])) / 3)

        aLinha[nLin][POS_EX_COB] :=  Round((aLinha[nLin][POS_EX_ESTFIM] / nValAux),2)
        
        PROD->(dbSkip())
    EndDo

//POS_EX_COD      1
//POS_EX_DES      2
//POS_EX_UM       3
//POS_EX_PAS1     4 
//POS_EX_PAS2     5 
//POS_EX_PAS3     6
//POS_EX_MED      7
//POS_EX_FOR1     8
//POS_EX_FOR2     9
//POS_EX_FOR3     10
//POS_EX_SALDO    11
//POS_EX_PREV     12
//POS_EX_PEDCOM   13
//POS_EX_ESTFIM   14
//POS_EX_COB      15


    If Empty(aLinha)
        Alert("Nao a dados a serem impressos!!!")
        Return(.T.)
    EndIf

    For nlx := 1 to Len(aDataCab)
        If SubStr(aDataCab[nlx],5,2) == "01"
            aDataCab[nlx] := "jan/" + SubStr(aDataCab[nlx],1,4) 
        ElseIf SubStr(aDataCab[nlx],5,2) == "02"
            aDataCab[nlx] := "fev/" + SubStr(aDataCab[nlx],1,4) 
        ElseIf SubStr(aDataCab[nlx],5,2) == "03"
            aDataCab[nlx] := "mar/" + SubStr(aDataCab[nlx],1,4) 
        ElseIf SubStr(aDataCab[nlx],5,2) == "04"
            aDataCab[nlx] := "abr/" + SubStr(aDataCab[nlx],1,4) 
        ElseIf SubStr(aDataCab[nlx],5,2) == "05"
            aDataCab[nlx] := "mai/" + SubStr(aDataCab[nlx],1,4) 
        ElseIf SubStr(aDataCab[nlx],5,2) == "06"
            aDataCab[nlx] := "jun/" + SubStr(aDataCab[nlx],1,4) 
        ElseIf SubStr(aDataCab[nlx],5,2) == "07"
            aDataCab[nlx] := "jul/" + SubStr(aDataCab[nlx],1,4) 
        ElseIf SubStr(aDataCab[nlx],5,2) == "08"
            aDataCab[nlx] := "ago/" + SubStr(aDataCab[nlx],1,4) 
        ElseIf SubStr(aDataCab[nlx],5,2) == "09"
            aDataCab[nlx] := "set/" + SubStr(aDataCab[nlx],1,4) 
        ElseIf SubStr(aDataCab[nlx],5,2) == "10"
            aDataCab[nlx] := "out/" + SubStr(aDataCab[nlx],1,4) 
        ElseIf SubStr(aDataCab[nlx],5,2) == "11"
            aDataCab[nlx] := "nov/" + SubStr(aDataCab[nlx],1,4) 
        ElseIf SubStr(aDataCab[nlx],5,2) == "12"
            aDataCab[nlx] := "dez/" + SubStr(aDataCab[nlx],1,4) 
        EndIf
    Next

    For nlx := 1 to Len(aDataFor)
        If SubStr(aDataFor[nlx],5,2) == "01"
            aDataFor[nlx] := "jan/" + SubStr(aDataFor[nlx],1,4) 
        ElseIf SubStr(aDataFor[nlx],5,2) == "02"
            aDataFor[nlx] := "fev/" + SubStr(aDataFor[nlx],1,4) 
        ElseIf SubStr(aDataFor[nlx],5,2) == "03"
            aDataFor[nlx] := "mar/" + SubStr(aDataFor[nlx],1,4) 
        ElseIf SubStr(aDataFor[nlx],5,2) == "04"
            aDataFor[nlx] := "abr/" + SubStr(aDataFor[nlx],1,4) 
        ElseIf SubStr(aDataFor[nlx],5,2) == "05"
            aDataFor[nlx] := "mai/" + SubStr(aDataFor[nlx],1,4) 
        ElseIf SubStr(aDataFor[nlx],5,2) == "06"
            aDataFor[nlx] := "jun/" + SubStr(aDataFor[nlx],1,4) 
        ElseIf SubStr(aDataFor[nlx],5,2) == "07"
            aDataFor[nlx] := "jul/" + SubStr(aDataFor[nlx],1,4) 
        ElseIf SubStr(aDataFor[nlx],5,2) == "08"
            aDataFor[nlx] := "ago/" + SubStr(aDataFor[nlx],1,4) 
        ElseIf SubStr(aDataFor[nlx],5,2) == "09"
            aDataFor[nlx] := "set/" + SubStr(aDataFor[nlx],1,4) 
        ElseIf SubStr(aDataFor[nlx],5,2) == "10"
            aDataFor[nlx] := "out/" + SubStr(aDataFor[nlx],1,4) 
        ElseIf SubStr(aDataFor[nlx],5,2) == "11"
            aDataFor[nlx] := "nov/" + SubStr(aDataFor[nlx],1,4) 
        ElseIf SubStr(aDataFor[nlx],5,2) == "12"
            aDataFor[nlx] := "dez/" + SubStr(aDataFor[nlx],1,4) 
        EndIf
    Next
    
    oFWMsExcel := FWMSExcelEx():New()
    // ( 1-General,2-Number,3-Monet?rio,4-DateTime )
    aAdd(aWorkSheet,"OverStock")
    oFWMsExcel:AddworkSheet( aWorkSheet[x] ) 
    oFWMsExcel:AddTable( aWorkSheet[x], aWorkSheet[x] ) 
    oFWMsExcel:AddColumn(aWorkSheet[x], aWorkSheet[x], "Codigo"             ,1,1,.F.)
    oFWMsExcel:AddColumn(aWorkSheet[x], aWorkSheet[x], "Descricao" 	        ,1,1,.F.)
    oFWMsExcel:AddColumn(aWorkSheet[x], aWorkSheet[x], "UM"      	        ,1,1,.F.)
    oFWMsExcel:AddColumn(aWorkSheet[x], aWorkSheet[x], aDataCab[1]          ,1,2,.F.)
    oFWMsExcel:AddColumn(aWorkSheet[x], aWorkSheet[x], aDataCab[2]          ,1,2,.F.)
    oFWMsExcel:AddColumn(aWorkSheet[x], aWorkSheet[x], aDataCab[3]          ,1,2,.F.)
    oFWMsExcel:AddColumn(aWorkSheet[x], aWorkSheet[x], "Media"              ,1,2,.F.)
    oFWMsExcel:AddColumn(aWorkSheet[x], aWorkSheet[x], aDataFor[1]          ,1,2,.F.)
    oFWMsExcel:AddColumn(aWorkSheet[x], aWorkSheet[x], aDataFor[2]          ,1,2,.F.)
    oFWMsExcel:AddColumn(aWorkSheet[x], aWorkSheet[x], aDataFor[3]          ,1,2,.F.)
    oFWMsExcel:AddColumn(aWorkSheet[x], aWorkSheet[x], "Saldo Atual"        ,1,2,.F.)
    oFWMsExcel:AddColumn(aWorkSheet[x], aWorkSheet[x], "Venda Acumulada m?s",1,2,.F.)
    oFWMsExcel:AddColumn(aWorkSheet[x], aWorkSheet[x], "Pedidos compra m?s" ,1,2,.F.)
    oFWMsExcel:AddColumn(aWorkSheet[x], aWorkSheet[x], "Estoque final m?s"  ,1,2,.F.)
    oFWMsExcel:AddColumn(aWorkSheet[x], aWorkSheet[x], "Cobertura prevista" ,1,2,.F.)

    For nlx := 1 to Len(aLinha)
        If aLinha[nlx][POS_EX_COB] >= aParam[POS_COBERTURA]
            If lLinha
                cCor := cCor1   
            else
                cCor := cCor2
            endIf
            
            oFWMsExcel:SetCelBgColor(cCor)
            oFWMsExcel:AddRow(aWorkSheet[X], aWorkSheet[X], {aLinha[nlx][POS_EX_COD],aLinha[nlx][POS_EX_DES],aLinha[nlx][POS_EX_UM],aLinha[nlx][POS_EX_PAS1],aLinha[nlx][POS_EX_PAS2],aLinha[nlx][POS_EX_PAS3],aLinha[nlx][POS_EX_MED],aLinha[nlx][POS_EX_FOR1],aLinha[nlx][POS_EX_FOR2],aLinha[nlx][POS_EX_FOR3],aLinha[nlx][POS_EX_SALDO],aLinha[nlx][POS_EX_PREV],aLinha[nlx][POS_EX_PEDCOM],aLinha[nlx][POS_EX_ESTFIM],aLinha[nlx][POS_EX_COB]},{1,2,3,4,5,6,7,8,9,10,11,12,13,14,15} )
                                                                                                                                                                                                        
            lLinha := !lLinha
        EndIf
    Next

    oFWMsExcel:Activate()
    oFWMsExcel:GetXMLFile(cCaminho + cNome)

    shellExecute( "Open", cCaminho + cNome, "", "", 1 )
    msgalert("Planilha Gerada em: "+(cCaminho + cNome))  
Return
