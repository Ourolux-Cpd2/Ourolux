#INCLUDE "PROTHEUS.CH"
#Include "TOPCONN.CH"
//--------------------------------------------------------------------
/*/{Protheus.doc} OURO006
Calculo de container por item
@author Rodrigo Nunes
@since 20/08/2021
/*/
//--------------------------------------------------------------------
User Function OURO006(nVolCub,nPesBru,nPos)
    Local cQuery  := ""
    Local nTotCub := 0
    Local nTotPBr := 0
    Local lPorMTC := .F.
    Local lPorPBR := .F.
    Local aCTNVal := {}
    Local aQtdCTN := {}
    Local nResto  := 0
    Local nlx     := 0
    Local nP20DR  := aScan(aHeader,{|x| AllTrim(x[2]) == 'C1_CTN20DR'})
    Local nP20RF  := aScan(aHeader,{|x| AllTrim(x[2]) == 'C1_CTN20RF'})
    Local nP40DR  := aScan(aHeader,{|x| AllTrim(x[2]) == 'C1_CTN40DR'})
    Local nP40RF  := aScan(aHeader,{|x| AllTrim(x[2]) == 'C1_CTN40RF'})
    Local nP40HC  := aScan(aHeader,{|x| AllTrim(x[2]) == 'C1_CTN40HC'})
    Default nPos  := 0

    cQuery := " SELECT TOP(1) ZAC_MTC, ZAC_KG FROM " + RetSqlName("ZAC")
    cQuery += " WHERE ZAC_ATIVO = 'S' "
    cQuery += " AND D_E_L_E_T_ = '' "
    cQuery += " ORDER BY ZAC_MTC DESC "

    If Select("CALX") > 0
        CALX->(dbCloseArea())
    EndIf

    DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery) , 'CALX', .T., .F.)

    If CALX->(!EOF())
        If !aCols[nPos][len(aCols[nPos])]
            nTotCub := Round(nVolCub / CALX->ZAC_MTC,2)
            nTotPBr := Round(nPesBru / CALX->ZAC_KG,2)
        else
            return
        EndIf
    EndIf

    If nTotCub > nTotPBr
        lPorMTC := .T.
    Else
        lPorPBR := .T.
    EndIf
    
    //varer todos os tipos de ctn para ver quantos precisa de cada unidade
    cQuery := " SELECT ZAC_CTN, ZAC_MTC, ZAC_KG FROM " + RetSqlName("ZAC")
    cQuery += " WHERE ZAC_ATIVO = 'S' "
    If lPorMTC   
        If nTotCub <= 1
            cQuery += " AND ZAC_MTC >= '"+cValToChar(nVolCub)+"' "
        EndIf
    else //lPorPBR
        If nTotPBr <= 1
            cQuery += " AND ZAC_KG >= '"+cValToChar(nPesBru)+"' "
        EndIf
    EndIf
    cQuery += " AND D_E_L_E_T_ = '' "

    If Select("CTNX") > 0
        CTNX->(dbCloseArea())
    EndIf

    DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery) , 'CTNX', .T., .F.)

    While CTNX->(!EOF())
        If lPorMTC
            AADD(aQtdCTN,{CTNX->ZAC_CTN, Round(nVolCub / CTNX->ZAC_MTC,2)})
        Else // lPorPBR
            AADD(aQtdCTN,{CTNX->ZAC_CTN, Round(nPesBru / CALX->ZAC_KG,2)})
        EndIf
        CTNX->(dbSkip())
    EndDo

    //agora varrer todo os containe com a quantidade que cabem a carga para pegar o melhor pre�os
    If Empty(aQtdCTN)
        Alert("N�o existem containers compativeis cadastrado no sistema, entre em contato com a equipe de Suprimentos")
        Return
    EndIf

    For nlx := 1 to len(aQtdCTN)
        cQuery := " SELECT ZAD_CODCTN, ZAD_DATA, ZAD_VALMTC, ZAD_CUSTO, ZAD_ATIVO FROM " + RetSqlName("ZAD")
        cQuery += " WHERE ZAD_CODCTN = '"+aQtdCTN[nlx][1]+"' "
        cQuery += " AND ZAD_ATIVO = 'S' "
        cQuery += " AND D_E_L_E_T_ = '' "

        If Select("VLRC") > 0
            VLRC->(dbCloseArea())
        EndIf
        
        DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery) , 'VLRC', .T., .F.)

        If VLRC->(!EOF())
            If aQtdCTN[nlx][2] > 1
                AADD(aCTNVal,{VLRC->ZAD_CODCTN,Int(aQtdCTN[nlx][2]) * VLRC->ZAD_CUSTO,Int(aQtdCTN[nlx][2])})
                nResto := aQtdCTN[nlx][2]-Int(aQtdCTN[nlx][2])
            Else
                AADD(aCTNVal,{VLRC->ZAD_CODCTN,VLRC->ZAD_CUSTO,aQtdCTN[nlx][2],aQtdCTN[nlx][2]-Int(aQtdCTN[nlx][2])})
            EndIf
        EndIf
    Next
    
    If !Empty(aCTNVal)
        aSort(aCTNVal,,, { |x, y| x[2] < y[2] })

        aCols[nPos][nP20DR] := 0
        aCols[nPos][nP20RF] := 0
        aCols[nPos][nP40DR] := 0
        aCols[nPos][nP40RF] := 0
        aCols[nPos][nP40HC] := 0

        If aCTNVal[1][1] == "CTN20DR"
            aCols[nPos][nP20DR] := aCTNVal[1][3]
        ElseIf aCTNVal[1][1] == "CTN20RF"
            aCols[nPos][nP20RF] := aCTNVal[1][3]
        ElseIf aCTNVal[1][1] == "CTN40DR"
            aCols[nPos][nP40DR] := aCTNVal[1][3]
        ElseIf aCTNVal[1][1] == "CTN40RF"
            aCols[nPos][nP40RF] := aCTNVal[1][3]
        ElseIf aCTNVal[1][1] == "CTN40HC"
            aCols[nPos][nP40HC] := aCTNVal[1][3]
        EndIf
    EndIf

    If nResto > 0
        cQuery := " SELECT TOP(1) ZAD_CODCTN, ZAD_DATA, ZAD_VALMTC, ZAD_CUSTO, ZAD_ATIVO FROM " + RetSqlName("ZAD")
        cQuery += " WHERE ZAD_ATIVO = 'S' "
        cQuery += " AND D_E_L_E_T_ = '' "
        cQuery += " ORDER BY ZAD_CUSTO DESC"

        If Select("RESX") > 0
            RESX->(dbCloseArea())
        EndIf
        
        DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery) , 'RESX', .T., .F.)

        If RESX->(!EOF())
             If RESX->ZAD_CODCTN == "CTN20DR"
                aCols[nPos][nP20DR] += nResto
            ElseIf RESX->ZAD_CODCTN == "CTN20RF"
                aCols[nPos][nP20RF] += nResto
            ElseIf RESX->ZAD_CODCTN == "CTN40DR"
                aCols[nPos][nP40DR] += nResto
            ElseIf RESX->ZAD_CODCTN == "CTN40RF"
                aCols[nPos][nP40RF] += nResto
            ElseIf RESX->ZAD_CODCTN == "CTN40HC"
                aCols[nPos][nP40HC] += nResto
            EndIf
        EndIf
    EndIf
Return
