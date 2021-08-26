#INCLUDE "PROTHEUS.CH"
#Include "TOPCONN.CH"

#DEFINE POS_MTC     1
#DEFINE POS_PESOB   2
#DEFINE POS_DATAENT 3
#DEFINE POS_CTN40HC 4
#DEFINE POS_CTN40DR 5
#DEFINE POS_CTN40RF 6
#DEFINE POS_CTN20DR 7
#DEFINE POS_CTN20RF 8
#DEFINE POS_PARTLOT 9
#DEFINE POS_DATA_M  10
#DEFINE POS_DATA_R  11


//--------------------------------------------------------------------
/*/{Protheus.doc} OURO007
Tela com totalizadores de containers.
@author Rodrigo Nunes
@since 23/08/2021
/*/
//--------------------------------------------------------------------
User Function OURO007(lFinal)
    Local oDlg      := NIL
    Local oListPR   := Nil
    Local aHeadSA   := {}
    Local nlx       := 0
    Local nPos      := 0
    Local lRet      := .F.
    Local nPCub     := aScan(aHeader,{|x| AllTrim(x[2]) == 'C1_XCUBAGE'})
    Local nPPesB    := aScan(aHeader,{|x| AllTrim(x[2]) == 'C1_XPESBRU'})
    Local nPDtEnt   := aScan(aHeader,{|x| AllTrim(x[2]) == 'C1_DATPRF'})
    Local cQuery    := ""
    Private aCTNTot := {}
    Default lFinal  := .F.

    Aadd(aHeadSA, {"MT³"                , "MTC"     , "@E 9,999,999,999.9999"   , TamSx3("C1_XCUBAGE")[1]   , TamSx3("C1_XCUBAGE")[2] , "" ,, "N", "",,,,})
    Aadd(aHeadSA, {"PESO"               , "PESOB"   , "@E 999,999,999.999"      , TamSx3("C1_XPESBRU")[1]   , TamSx3("C1_XPESBRU")[2] , "" ,, "N", "",,,,})
    Aadd(aHeadSA, {"DATA ENTREGA"       , "DTENT"   , ""                        , TamSx3("C1_DATPRF")[1]    , TamSx3("C1_DATPRF")[2]  , "" ,, "D", "",,,,})
    Aadd(aHeadSA, {"CTN40'HC"           , "CTN40HC" , "@E 999.99"               , TamSx3("C1_CTN40HC")[1]   , TamSx3("C1_CTN40HC")[2] , "" ,, "N", "",,,,})
    Aadd(aHeadSA, {"CTN40'DR"           , "CTN40DR" , "@E 999.99"               , TamSx3("C1_CTN40DR")[1]   , TamSx3("C1_CTN40DR")[2] , "" ,, "N", "",,,,})
    Aadd(aHeadSA, {"CTN40'RF"           , "CTN40RF" , "@E 999.99"               , TamSx3("C1_CTN40RF")[1]   , TamSx3("C1_CTN40RF")[2] , "" ,, "N", "",,,,})
    Aadd(aHeadSA, {"CTN20'DR"           , "CTN20DR" , "@E 999.99"               , TamSx3("C1_CTN20DR")[1]   , TamSx3("C1_CTN20DR")[2] , "" ,, "N", "",,,,})
    Aadd(aHeadSA, {"CTN20'RF"           , "CTN20RF" , "@E 999.99"               , TamSx3("C1_CTN20RF")[1]   , TamSx3("C1_CTN20RF")[2] , "" ,, "N", "",,,,})
    Aadd(aHeadSA, {"PART LOT"           , "PARTLOT" , "@E 9,999,999,999.9999"   , TamSx3("C1_XCUBAGE")[1]   , TamSx3("C1_XCUBAGE")[2] , "" ,, "N", "",,,,})
    Aadd(aHeadSA, {"Dt.Cot CTN Fechado" , "DTCOTM"  , ""                        , TamSx3("C1_DATPRF")[1]    , TamSx3("C1_DATPRF")[2]  , "" ,, "D", "",,,,})
    Aadd(aHeadSA, {"Dt.Cot Part Lot"    , "DTCOTR"  , ""                        , TamSx3("C1_DATPRF")[1]    , TamSx3("C1_DATPRF")[2]  , "" ,, "D", "",,,,})
    
    //PEGAR POR DATA DE ENTREGA PARA MONTA A TELA
    For nlx := 1 to len(aCols)
        If !aCols[nlx][len(aCols[nlx])]
            If Empty(aCTNTot) 
                AADD(aCTNTot,{aCols[nlx][nPCub],aCols[nlx][nPPesB],aCols[nlx][nPDtEnt],0,0,0,0,0,0,CTOD("  /  /    "),CTOD("  /  /    "),.F.})
            Else
                nPos := aScan(aCTNTot,{|x| x[POS_DATAENT] == aCols[nlx][nPDtEnt]})

                If nPos > 0
                    aCTNTot[nPos][POS_MTC]  += aCols[nlx][nPCub]
                    aCTNTot[nPos][POS_PESOB] += aCols[nlx][nPPesB]
                Else
                    AADD(aCTNTot,{aCols[nlx][nPCub],aCols[nlx][nPPesB],aCols[nlx][nPDtEnt],0,0,0,0,0,0,CTOD("  /  /    "),CTOD("  /  /    "),.F.})
                EndIf
            EndIf
        EndIf
    Next

    If Empty(aCTNTot)
        Return .F.
    EndIf

    If ALTERA .OR. INCLUI .OR. LCOPIA
        //Rotina para busca do melhor container
        OURO07A()
    else
        cQuery := " SELECT ZAE_FILIAL, ZAE_NUMSC, ZAE_DTENTR, ZAE_CT40HC, ZAE_CT40DR, ZAE_CT40RF, ZAE_CT20DR, ZAE_CT20RF, ZAE_DTCOTM, ZAE_DTCOTR, R_E_C_N_O_ "
        cQuery += " FROM " + RetSqlName("ZAE")
        cQuery += " WHERE ZAE_FILIAL = '"+SC1->C1_FILIAL+"' "
        cQuery += " AND ZAE_NUMSC = '"+SC1->C1_NUM+"' "
        cQuery += " AND D_E_L_E_T_ = '' "
        
        If Select("BUSX") > 0
            BUSX->(dbCloseArea())
        EndIf

        DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery) , 'BUSX', .T., .F.)

        While BUSX->(!EOF())
            nPos := aScan(aCTNTot,{|x| x[POS_DATAENT] == STOD(BUSX->ZAE_DTENTR)})
            
            If nPos > 0 
                aCTNTot[nPos][POS_CTN40HC] := BUSX->ZAE_CT40HC
                aCTNTot[nPos][POS_CTN40DR] := BUSX->ZAE_CT40DR
                aCTNTot[nPos][POS_CTN40RF] := BUSX->ZAE_CT40RF
                aCTNTot[nPos][POS_CTN20DR] := BUSX->ZAE_CT20DR
                aCTNTot[nPos][POS_CTN20RF] := BUSX->ZAE_CT20RF
                aCTNTot[nPos][POS_DATA_M]  := STOD(BUSX->ZAE_DTCOTM)
                aCTNTot[nPos][POS_DATA_R]  := STOD(BUSX->ZAE_DTCOTR)
            EndIf        
            BUSX->(dbSkip())
        EndDo

    EndIf

    DEFINE MSDIALOG oDlg TITLE  "Totalizadores de Containers" FROM  10, 10 To 400, 1100 PIXEL

        oListPR := MsNewGetDados():New( 017, 006, 120, 243, ,,,"",{},, 999,,"",, oDlg, aHeadSA, aCTNTot)
        
        oListPR:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

    If lFinal
        ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg, {|| lRet := .T., oDlg:End()}, {|| lRet := .F., oDlg:End() })
    else
        ACTIVATE MSDIALOG oDlg CENTERED 
    EndIf

    If lRet
        DbSelectArea("ZAE")

        If ALTERA
            cQuery := " SELECT ZAE_FILIAL, ZAE_NUMSC, ZAE_DTENTR, ZAE_CT40HC, ZAE_CT40DR, ZAE_CT40RF, ZAE_CT20DR, ZAE_CT20RF, ZAE_DTCOTM, ZAE_DTCOTR, R_E_C_N_O_ "
            cQuery += " FROM " + RetSqlName("ZAE")
            cQuery += " WHERE ZAE_FILIAL = '"+SC1->C1_FILIAL+"' "
            cQuery += " AND ZAE_NUMSC = '"+SC1->C1_NUM+"' "
            cQuery += " AND D_E_L_E_T_ = '' "
            
            If Select("TCSX") > 0
                TCSX->(dbCloseArea())
            EndIf

            DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery) , 'TCSX', .T., .F.)

            If TCSX->(!EOF())
                While TCSX->(!EOF())
                    ZAE->(dbGoTo(TCSX->R_E_C_N_O_))
                    RecLock("ZAE", .F.)
                    ZAE->(dbDelete())
                    ZAE->(MsUnlock())
                    TCSX->(dbSkip())
                EndDo
                For nlx := 1 to len(aCTNTot)
                    RecLock("ZAE", .T.)
                    ZAE->ZAE_FILIAL := SC1->C1_FILIAL
                    ZAE->ZAE_NUMSC  := SC1->C1_NUM
                    ZAE->ZAE_DTENTR := aCTNTot[nlx][POS_DATAENT]
                    ZAE->ZAE_CT40HC := aCTNTot[nlx][POS_CTN40HC]
                    ZAE->ZAE_CT40DR := aCTNTot[nlx][POS_CTN40DR]
                    ZAE->ZAE_CT40RF := aCTNTot[nlx][POS_CTN40RF]
                    ZAE->ZAE_CT20DR := aCTNTot[nlx][POS_CTN20DR]
                    ZAE->ZAE_CT20RF := aCTNTot[nlx][POS_CTN20RF]
                    ZAE->ZAE_DTCOTM := aCTNTot[nlx][POS_DATA_M]
                    ZAE->ZAE_DTCOTR := aCTNTot[nlx][POS_DATA_R]
                    ZAE->(MsUnlock())
                Next
            Else
                For nlx := 1 to len(aCTNTot)
                    RecLock("ZAE", .T.)
                    ZAE->ZAE_FILIAL := SC1->C1_FILIAL
                    ZAE->ZAE_NUMSC  := SC1->C1_NUM
                    ZAE->ZAE_DTENTR := aCTNTot[nlx][POS_DATAENT]
                    ZAE->ZAE_CT40HC := aCTNTot[nlx][POS_CTN40HC]
                    ZAE->ZAE_CT40DR := aCTNTot[nlx][POS_CTN40DR]
                    ZAE->ZAE_CT40RF := aCTNTot[nlx][POS_CTN40RF]
                    ZAE->ZAE_CT20DR := aCTNTot[nlx][POS_CTN20DR]
                    ZAE->ZAE_CT20RF := aCTNTot[nlx][POS_CTN20RF]
                    ZAE->ZAE_DTCOTM := aCTNTot[nlx][POS_DATA_M]
                    ZAE->ZAE_DTCOTR := aCTNTot[nlx][POS_DATA_R]
                    ZAE->(MsUnlock())
                Next
            EndIf
        ElseIf INCLUI .OR. LCOPIA
            For nlx := 1 to len(aCTNTot)
                RecLock("ZAE", .T.)
                ZAE->ZAE_FILIAL := xFilial("SC1")
                ZAE->ZAE_NUMSC  := cA110Num
                ZAE->ZAE_DTENTR := aCTNTot[nlx][POS_DATAENT]
                ZAE->ZAE_CT40HC := aCTNTot[nlx][POS_CTN40HC]
                ZAE->ZAE_CT40DR := aCTNTot[nlx][POS_CTN40DR]
                ZAE->ZAE_CT40RF := aCTNTot[nlx][POS_CTN40RF]
                ZAE->ZAE_CT20DR := aCTNTot[nlx][POS_CTN20DR]
                ZAE->ZAE_CT20RF := aCTNTot[nlx][POS_CTN20RF]
                ZAE->ZAE_DTCOTM := aCTNTot[nlx][POS_DATA_M]
                ZAE->ZAE_DTCOTR := aCTNTot[nlx][POS_DATA_R]
                ZAE->(MsUnlock())
            Next
        EndIf
    EndIf

Return lRet

//--------------------------------------------------------------------
/*/{Protheus.doc} OURO07A
Calculo de container por item
@author Rodrigo Nunes
@since 20/08/2021
/*/
//--------------------------------------------------------------------
Static Function OURO07A()
    Local cQuery  := ""
    Local nTotCub := 0
    Local nTotPBr := 0
    Local lPorMTC := .F.
    Local lPorPBR := .F.
    Local aCTNVal := {}
    Local aQtdCTN := {}
    Local nResto  := 0
    Local nlx     := 0
    Local nly     := 0
    Local nRestoM := 0
    Local nRestoP := 0
    Local nMTUso  := 0
    Local nPBUso  := 0    
    Default nPos  := 0

    For nly := 1 to len(aCTNTot)
        cQuery := " SELECT TOP(1) ZAC_MTC, ZAC_KG FROM " + RetSqlName("ZAC")
        cQuery += " WHERE ZAC_ATIVO = 'S' "
        cQuery += " AND D_E_L_E_T_ = '' "
        cQuery += " ORDER BY ZAC_MTC DESC "

        If Select("CALX") > 0
            CALX->(dbCloseArea())
        EndIf

        DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery) , 'CALX', .T., .F.)

        If CALX->(!EOF())
            nTotCub := Round(aCTNTot[nly][POS_MTC] / CALX->ZAC_MTC,2)
            nTotPBr := Round(aCTNTot[nly][POS_PESOB] / CALX->ZAC_KG,2)
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
                cQuery += " AND ZAC_MTC >= '"+cValToChar(aCTNTot[nly][POS_MTC])+"' "
            EndIf
        else //lPorPBR
            If nTotPBr <= 1
                cQuery += " AND ZAC_KG >= '"+cValToChar(aCTNTot[nly][POS_PESOB])+"' "
            EndIf
        EndIf
        cQuery += " AND D_E_L_E_T_ = '' "

        If Select("CTNX") > 0
            CTNX->(dbCloseArea())
        EndIf

        DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery) , 'CTNX', .T., .F.)

        While CTNX->(!EOF())
            If lPorMTC
                AADD(aQtdCTN,{CTNX->ZAC_CTN, Round(aCTNTot[nly][POS_MTC] / CTNX->ZAC_MTC,2), CTNX->ZAC_MTC, CTNX->ZAC_KG})
            Else // lPorPBR
                AADD(aQtdCTN,{CTNX->ZAC_CTN, Round(aCTNTot[nly][POS_PESOB] / CTNX->ZAC_KG,2), CTNX->ZAC_MTC, CTNX->ZAC_KG})
            EndIf
            CTNX->(dbSkip())
        EndDo

        //agora varrer todo os containe com a quantidade que cabem a carga para pegar o melhor preços
        If Empty(aQtdCTN)
            Alert("Não existem containers compativeis cadastrado no sistema, entre em contato com a equipe de Suprimentos")
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
                    AADD(aCTNVal,{VLRC->ZAD_CODCTN, Int(aQtdCTN[nlx][2]) * VLRC->ZAD_CUSTO, Int(aQtdCTN[nlx][2]), STOD(VLRC->ZAD_DATA), aQtdCTN[nlx][2]-Int(aQtdCTN[nlx][2]), aQtdCTN[nlx][3], aQtdCTN[nlx][4]})
                Else
                    AADD(aCTNVal,{VLRC->ZAD_CODCTN, VLRC->ZAD_CUSTO, aQtdCTN[nlx][2], STOD(VLRC->ZAD_DATA), 0, aQtdCTN[nlx][3], aQtdCTN[nlx][4]})
                EndIf
            EndIf
        Next
        
        If !Empty(aCTNVal)
            aSort(aCTNVal,,, { |x, y| x[2] < y[2] })
            
            If aCTNVal[1][1] == "CTN20DR"
                aCTNTot[nly][POS_CTN20DR] += aCTNVal[1][3]
                aCTNTot[nly][POS_DATA_M]  := aCTNVal[1][4]
                nResto := aCTNVal[1][5]
                nMTUso := aCTNVal[1][6]
                nPBUso := aCTNVal[1][7]
            ElseIf aCTNVal[1][1] == "CTN20RF"
                aCTNTot[nly][POS_CTN20RF] += aCTNVal[1][3]
                aCTNTot[nly][POS_DATA_M]  := aCTNVal[1][4]
                nResto := aCTNVal[1][5]
                nMTUso := aCTNVal[1][6]
                nPBUso := aCTNVal[1][7]
            ElseIf aCTNVal[1][1] == "CTN40DR"
                aCTNTot[nly][POS_CTN40DR] += aCTNVal[1][3]
                aCTNTot[nly][POS_DATA_M]  := aCTNVal[1][4]
                nResto := aCTNVal[1][5]
                nMTUso := aCTNVal[1][6]
                nPBUso := aCTNVal[1][7]
            ElseIf aCTNVal[1][1] == "CTN40RF"
                aCTNTot[nly][POS_CTN40RF] += aCTNVal[1][3]
                aCTNTot[nly][POS_DATA_M]  := aCTNVal[1][4]
                nResto := aCTNVal[1][5]
                nMTUso := aCTNVal[1][6]
                nPBUso := aCTNVal[1][7]
            ElseIf aCTNVal[1][1] == "CTN40HC"
                aCTNTot[nly][POS_CTN40HC] += aCTNVal[1][3]
                aCTNTot[nly][POS_DATA_M]  := aCTNVal[1][4]
                nResto := aCTNVal[1][5]
                nMTUso := aCTNVal[1][6]
                nPBUso := aCTNVal[1][7]
            EndIf
        EndIf

        If nResto > 0
            If aCTNTot[nly][POS_CTN20DR] > 0
                If lPorMTC
                    nRestoM := (aCTNTot[nly][POS_MTC] - (aCTNTot[nly][POS_CTN40RF] * nMTUso))
                ElseIf lPorPBR
                    nRestoP := (aCTNTot[nly][POS_PESOB] - (aCTNTot[nly][POS_CTN40RF] * nPBUso))
                EndIf
            ElseIf aCTNTot[nly][POS_CTN20RF] > 0
                If lPorMTC
                    nRestoM := (aCTNTot[nly][POS_MTC] - (aCTNTot[nly][POS_CTN40RF] * nMTUso))
                ElseIf lPorPBR
                    nRestoP := (aCTNTot[nly][POS_PESOB] - (aCTNTot[nly][POS_CTN40RF] * nPBUso))
                EndIf
            ElseIf aCTNTot[nly][POS_CTN40DR] > 0
                If lPorMTC
                    nRestoM := (aCTNTot[nly][POS_MTC] - (aCTNTot[nly][POS_CTN40RF] * nMTUso))
                ElseIf lPorPBR
                    nRestoP := (aCTNTot[nly][POS_PESOB] - (aCTNTot[nly][POS_CTN40RF] * nPBUso))
                EndIf
            ElseIf aCTNTot[nly][POS_CTN40RF] > 0
                If lPorMTC
                    nRestoM := (aCTNTot[nly][POS_MTC] - (aCTNTot[nly][POS_CTN40RF] * nMTUso))
                ElseIf lPorPBR
                    nRestoP := (aCTNTot[nly][POS_PESOB] - (aCTNTot[nly][POS_CTN40RF] * nPBUso))
                EndIf
            ElseIf aCTNTot[nly][POS_CTN40HC] > 0
                If lPorMTC
                    nRestoM := (aCTNTot[nly][POS_MTC] - (aCTNTot[nly][POS_CTN40RF] * nMTUso))
                ElseIf lPorPBR
                    nRestoP := (aCTNTot[nly][POS_PESOB] - (aCTNTot[nly][POS_CTN40RF] * nPBUso))
                EndIf
            EndIf

            cQuery := " SELECT TOP(1) ZAD_CODCTN, ZAD_DATA, ZAD_VALMTC, ZAD_CUSTO, ZAD_ATIVO "
            cQuery += " FROM " + RetSqlName("ZAD") + " ZAD "
            cQuery += " INNER JOIN " + RetSqlName("ZAC") + " ZAC "
            cQuery += " ON ZAC.ZAC_CTN = ZAD.ZAD_CODCTN "
            If lPorMTC
                cQuery += " AND ZAC.ZAC_MTC >= '"+cValtoChar(nRestoM)+"' "
            ElseIf lPorPBR
                cQuery += " AND ZAC.ZAC_KG >= '"+cValToChar(nRestoP)+"' "
            EndIf
            cQuery += " WHERE ZAD.ZAD_ATIVO = 'S' "
            cQuery += " AND ZAD.D_E_L_E_T_ = '' "
            cQuery += " AND ZAC.D_E_L_E_T_ = '' "
            cQuery += " ORDER BY ZAD_CUSTO DESC "


            If Select("RESX") > 0
                RESX->(dbCloseArea())
            EndIf
            
            DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery) , 'RESX', .T., .F.)

            If RESX->(!EOF())
                If RESX->ZAD_CODCTN == "CTN20DR"
                    aCTNTot[nly][POS_CTN20DR] += nResto
                    aCTNTot[nly][POS_DATA_R]  := STOD(RESX->ZAD_DATA)
                    If lPorMTC
                        aCTNTot[nly][POS_PARTLOT] := nRestoM
                    ElseIf lPorPBR
                        aCTNTot[nly][POS_PARTLOT] := nRestoP
                    EndIf
                ElseIf RESX->ZAD_CODCTN == "CTN20RF"
                    aCTNTot[nly][POS_CTN20RF] += nResto
                    aCTNTot[nly][POS_DATA_R]  := STOD(RESX->ZAD_DATA)
                    If lPorMTC
                        aCTNTot[nly][POS_PARTLOT] := nRestoM
                    ElseIf lPorPBR
                        aCTNTot[nly][POS_PARTLOT] := nRestoP
                    EndIf
                ElseIf RESX->ZAD_CODCTN == "CTN40DR"
                    aCTNTot[nly][POS_CTN40DR] += nResto
                    aCTNTot[nly][POS_DATA_R]  := STOD(RESX->ZAD_DATA)
                    If lPorMTC
                        aCTNTot[nly][POS_PARTLOT] := nRestoM
                    ElseIf lPorPBR
                        aCTNTot[nly][POS_PARTLOT] := nRestoP
                    EndIf
                ElseIf RESX->ZAD_CODCTN == "CTN40RF"
                    aCTNTot[nly][POS_CTN40RF] += nResto
                    aCTNTot[nly][POS_DATA_R]  := STOD(RESX->ZAD_DATA)
                    If lPorMTC
                        aCTNTot[nly][POS_PARTLOT] := nRestoM
                    ElseIf lPorPBR
                        aCTNTot[nly][POS_PARTLOT] := nRestoP
                    EndIf
                ElseIf RESX->ZAD_CODCTN == "CTN40HC"
                    aCTNTot[nly][POS_CTN40HC] += nResto
                    aCTNTot[nly][POS_DATA_R]  := STOD(RESX->ZAD_DATA)
                    If lPorMTC
                        aCTNTot[nly][POS_PARTLOT] := nRestoM
                    ElseIf lPorPBR
                        aCTNTot[nly][POS_PARTLOT] := nRestoP
                    EndIf
                EndIf
            EndIf
        EndIf

        nRestoP := 0
        nRestoM := 0
        nResto  := 0
        aCTNVal := {}
        aQtdCTN := {}
        lPorMTC := .F.
        lPorPBR := .F.
    Next
Return

//--------------------------------------------------------------------
/*/{Protheus.doc} OURO07B
Tela de container da SC
@author Rodrigo Nunes
@since 24/08/2021
/*/
//--------------------------------------------------------------------
User Function OURO07B()
    Local oDlg      := NIL
    Local oListPR   := Nil
    Local aHeadSA   := {}
    Local cQuery    := ""
    Private aCTNTot := {}
    Default lFinal  := .F.

    Aadd(aHeadSA, {"FILIAL"             , "FILIAL"  , ""                        , TamSx3("C1_FILIAL")[1]    , TamSx3("C1_FILIAL")[2]  , "" ,, "C", "",,,,})
    Aadd(aHeadSA, {"NUMERO SC"          , "NUMSC"   , ""                        , TamSx3("C1_NUM")[1]       , TamSx3("C1_NUM")[2]     , "" ,, "C", "",,,,})
    Aadd(aHeadSA, {"DATA ENTREGA"       , "DTENT"   , ""                        , TamSx3("C1_DATPRF")[1]    , TamSx3("C1_DATPRF")[2]  , "" ,, "D", "",,,,})
    Aadd(aHeadSA, {"CTN40'HC"           , "CTN40HC" , "@E 999.99"               , TamSx3("C1_CTN40HC")[1]   , TamSx3("C1_CTN40HC")[2] , "" ,, "N", "",,,,})
    Aadd(aHeadSA, {"CTN40'DR"           , "CTN40DR" , "@E 999.99"               , TamSx3("C1_CTN40DR")[1]   , TamSx3("C1_CTN40DR")[2] , "" ,, "N", "",,,,})
    Aadd(aHeadSA, {"CTN40'RF"           , "CTN40RF" , "@E 999.99"               , TamSx3("C1_CTN40RF")[1]   , TamSx3("C1_CTN40RF")[2] , "" ,, "N", "",,,,})
    Aadd(aHeadSA, {"CTN20'DR"           , "CTN20DR" , "@E 999.99"               , TamSx3("C1_CTN20DR")[1]   , TamSx3("C1_CTN20DR")[2] , "" ,, "N", "",,,,})
    Aadd(aHeadSA, {"CTN20'RF"           , "CTN20RF" , "@E 999.99"               , TamSx3("C1_CTN20RF")[1]   , TamSx3("C1_CTN20RF")[2] , "" ,, "N", "",,,,})
    Aadd(aHeadSA, {"Dt.Cot CTN Fechado" , "DTCOTM"  , ""                        , TamSx3("C1_DATPRF")[1]    , TamSx3("C1_DATPRF")[2]  , "" ,, "D", "",,,,})
    Aadd(aHeadSA, {"Dt.Cot Part Lot"    , "DTCOTR"  , ""                        , TamSx3("C1_DATPRF")[1]    , TamSx3("C1_DATPRF")[2]  , "" ,, "D", "",,,,})
    
    cQuery := " SELECT ZAE_FILIAL, ZAE_NUMSC, ZAE_DTENTR, ZAE_CT40HC, ZAE_CT40DR, ZAE_CT40RF, ZAE_CT20DR, ZAE_CT20RF, ZAE_DTCOTM, ZAE_DTCOTR, R_E_C_N_O_ "
    cQuery += " FROM " + RetSqlName("ZAE")
    cQuery += " WHERE ZAE_FILIAL = '"+SC1->C1_FILIAL+"' "
    cQuery += " AND ZAE_NUMSC = '"+SC1->C1_NUM+"' "
    cQuery += " AND D_E_L_E_T_ = '' "
    
    If Select("BUSX") > 0
        BUSX->(dbCloseArea())
    EndIf

    DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery) , 'BUSX', .T., .F.)

    While BUSX->(!EOF())
        AADD(aCTNTot,{BUSX->ZAE_FILIAL, BUSX->ZAE_NUMSC, STOD(BUSX->ZAE_DTENTR), BUSX->ZAE_CT40HC, BUSX->ZAE_CT40DR, BUSX->ZAE_CT40RF, BUSX->ZAE_CT20DR, BUSX->ZAE_CT20RF, STOD(BUSX->ZAE_DTCOTM), STOD(BUSX->ZAE_DTCOTR),.F.})
        BUSX->(dbSkip())
    EndDo

    If Empty(aCTNTot)
        Alert("Não existem conteiners calculados pata esta SC.")
        Return
    EndIf

    DEFINE MSDIALOG oDlg TITLE  "Totalizadores de Containers" FROM  10, 10 To 400, 1000 PIXEL

        oListPR := MsNewGetDados():New( 017, 006, 120, 243, ,,,"",{},, 999,,"",, oDlg, aHeadSA, aCTNTot)
        
        oListPR:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

    ACTIVATE MSDIALOG oDlg CENTERED 
        
Return
