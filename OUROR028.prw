#Include "Protheus.ch"
#Include "TOTVS.CH"
#Include "TOPCONN.CH"

#DEFINE POS_FILIAL      1
#DEFINE POS_PEDIDO      2
#DEFINE POS_EMISSAO     3
#DEFINE POS_FORNECEDOR  4
#DEFINE POS_PRODUTO     5
#DEFINE POS_DESCRICAO   6
#DEFINE POS_QUANTIDADE  7
#DEFINE POS_PRECO_UNT   8
#DEFINE POS_TOTAL       9
#DEFINE POS_GRUPO       10
#DEFINE POS_NOME_GRUPO  11
#DEFINE POS_DATA_LIB    12
#DEFINE POS_APROVADOR   13
#DEFINE POS_PROCESSO    14
#DEFINE POS_VENCIMENTO  15
#DEFINE POS_DATA_PGTO   16
#DEFINE POS_STATUS      17
#DEFINE POS_DATA_N1     18
#DEFINE POS_APROVA_N1   19
#DEFINE POS_DATA_N2     20
#DEFINE POS_APROVA_N2   21

/*
Rotina: OUROR028
Relatorio de Pedidos de Compra aprovados
Autor: Rodrigo Dias Nunes
Data: 02/09/2021
*/
User Function OUROR028()

    Processa({|| OUROR28()},"Gerando Relatório de Pedidos de Compras Aprovados...")

Return

Static Function OUROR28()
    Local oFWMsExcel
    Local aWorkSheet	:= {}
    Local X             := 1
    Local aLinha        := {}
    Local nlx           := 0
    Local cHora		    := Time()
    Local lLinha        := .T.
    Local cNome		    := 'Pedido_Compra_Aprovado_e_Reprovado'+ DtoS(dDataBase)+ '_' + SubStr(cHora,1,2) + SubStr(cHora,4,2) + ".xls"
    Local cCor1         := "#F0F8FF"
    Local cCor2         := "#87CEFA"
    Local nTotPed       := 0
    Local cPedVez       := ""
    Local cQryFull      := ""
    Local nLin          := 0
    Local cPerg         := "OUROR028  "
    local tmp           := getTempPath()
    Private cCaminho    := ""
    Private aParam      := {}

    PergPara(cPerg)

    If !Pergunte(cPerg,.T.)
		Return(.T.)
    else
        cCaminho := cGetFile( , 'Selecione a pasta de destino', , tmp, .F., GETF_LOCALHARD+GETF_RETDIRECTORY,.F.)
	Endif

    If Empty(cCaminho) 
        Return(.T.)
    EndIf

    cQuery := " SELECT SC7.C7_FILIAL, "
    cQuery += " 	   SC7.C7_NUM, "
    cQuery += " 	   SC7.C7_ITEM, "
    cQuery += " 	   SC7.C7_EMISSAO, "
    cQuery += " 	   SC7.C7_FORNECE, "
    cQuery += "        SC7.C7_LOJA, "
    cQuery += "        SA2.A2_NREDUZ, "
    cQuery += " 	   SC7.C7_PRODUTO, "
    cQuery += " 	   SC7.C7_DESCRI, "
    cQuery += " 	   SC7.C7_QUANT, "
    cQuery += " 	   SC7.C7_PRECO, "
    cQuery += " 	   SC7.C7_TOTAL, "
    cQuery += " 	   SC7.C7_XHAWB, "
    cQuery += "         SCR.CR_GRUPO, "
    cQuery += " 		(SELECT TOP(1)SAL.AL_DESC "
    cQuery += " 		 FROM " + RetSqlName("SAL") + " SAL "
    cQuery += " 		 WHERE SAL.AL_COD = SCR.CR_GRUPO "
    cQuery += " 		 AND D_E_L_E_T_ = '' "
    cQuery += " 		) AS NOME_GRUPO, "
    cQuery += " 		SCR.CR_DATALIB, "
    cQuery += " 		SCR.CR_LIBAPRO, "
    cQuery += " 		SC7.C7_CONAPRO "
    cQuery += " FROM " + RetSqlName("SC7") + " SC7 "
    cQuery += " INNER JOIN " + RetSqlName("SA2") + " SA2 " 
    cQuery += " ON SA2.A2_COD = SC7.C7_FORNECE "
    cQuery += " AND SA2.A2_LOJA = SC7.C7_LOJA "
    cQuery += " INNER JOIN " + RetSqlName("SCR")  + " SCR "
    cQuery += " ON SCR.CR_FILIAL = SC7.C7_FILIAL "
    cQuery += " AND SCR.CR_NUM = SC7.C7_NUM "
    cQuery += " AND SCR.CR_NIVEL = '02' "
    cQuery += " AND SCR.CR_LIBAPRO <> '' "
    cQuery += " AND SCR.CR_VALLIB > 0 "
    cQuery += " AND SCR.CR_GRUPO BETWEEN '"+MV_PAR11+"' AND '"+MV_PAR12+"' "
    cQuery += " AND SCR.CR_DATALIB BETWEEN '"+DTOS(MV_PAR03)+"' AND '"+DTOS(MV_PAR04)+"' "
    cQuery += " AND SCR.D_E_L_E_T_ = '' " 
    cQuery += " WHERE SC7.D_E_L_E_T_ = '' "
    cQuery += " AND SC7.C7_FILIAL BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"' "
    cQuery += " AND SC7.C7_NUM BETWEEN '"+MV_PAR07+"' AND '"+MV_PAR08+"' "
    cQuery += " AND SC7.C7_XHAWB BETWEEN '"+MV_PAR05+"' AND '"+MV_PAR06+"' "
    cQuery += " AND SC7.C7_EMISSAO BETWEEN '"+DTOS(MV_PAR09)+"' AND '"+DTOS(MV_PAR10)+"' "
    cQuery += " AND SC7.C7_CONAPRO = 'L' "
    
    cQryPe := " SELECT SC7.C7_FILIAL, "
    cQryPe += " 	   SC7.C7_NUM, "
    cQryPe += " 	   SC7.C7_ITEM, "
    cQryPe += " 	   SC7.C7_EMISSAO, "
    cQryPe += " 	   SC7.C7_FORNECE, "
    cQryPe += "        SC7.C7_LOJA, "
    cQryPe += "        SA2.A2_NREDUZ, "
    cQryPe += " 	   SC7.C7_PRODUTO, "
    cQryPe += " 	   SC7.C7_DESCRI, "
    cQryPe += " 	   SC7.C7_QUANT, "
    cQryPe += " 	   SC7.C7_PRECO, "
    cQryPe += " 	   SC7.C7_TOTAL, "
    cQryPe += " 	   SC7.C7_XHAWB, "
    cQryPe += "         SCR.CR_GRUPO, "
    cQryPe += " 		(SELECT TOP(1)SAL.AL_DESC "
    cQryPe += " 		 FROM " + RetSqlName("SAL") + " SAL "
    cQryPe += " 		 WHERE SAL.AL_COD = SCR.CR_GRUPO "
    cQryPe += " 		 AND D_E_L_E_T_ = '' "
    cQryPe += " 		) AS NOME_GRUPO, "
    cQryPe += " 		SCR.CR_DATALIB, "
    cQryPe += " 		SCR.CR_LIBAPRO, "
    cQryPe += " 		SC7.C7_CONAPRO "
    cQryPe += " FROM " + RetSqlName("SC7") + " SC7 "
    cQryPe += " INNER JOIN " + RetSqlName("SA2") + " SA2 " 
    cQryPe += " ON SA2.A2_COD = SC7.C7_FORNECE "
    cQryPe += " AND SA2.A2_LOJA = SC7.C7_LOJA "
    cQryPe += " INNER JOIN " + RetSqlName("SCR") + " SCR "
    cQryPe += "                ON SCR.CR_FILIAL = SC7.C7_FILIAL "
    cQryPe += "                   AND SCR.CR_NUM = SC7.C7_NUM "
    cQryPe += "                   AND SCR.CR_NIVEL = '01' "
    cQryPe += "                   AND SCR.CR_LIBAPRO <> '' "
    cQryPe += "                   AND SCR.CR_VALLIB > 0 "
    cQryPe += "                   AND SCR.CR_GRUPO BETWEEN '"+MV_PAR11+"' AND '"+MV_PAR12+"' "
    cQryPe += "                   AND SCR.D_E_L_E_T_ = '' "
    cQryPe += " WHERE  SC7.D_E_L_E_T_ = '' "
    cQryPe += "        AND SC7.C7_FILIAL BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"' "
    cQryPe += "        AND SC7.C7_NUM BETWEEN '"+MV_PAR07+"' AND '"+MV_PAR08+"' "
    cQryPe += "        AND SC7.C7_XHAWB BETWEEN '"+MV_PAR05+"' AND '"+MV_PAR06+"' "
    cQryPe += "        AND SC7.C7_EMISSAO BETWEEN '"+DTOS(MV_PAR09)+"' AND '"+DTOS(MV_PAR10)+"' "
    cQryPe += "        AND SC7.C7_CONAPRO = 'B' "
    
    If MV_PAR14 == 1
        cQryFull := cQuery
        cQryFull += " UNION ALL "
        cQryFull += cQryPe
    ElseIf MV_PAR14 == 2
        cQryFull := cQuery
    ElseIf MV_PAR14 == 3
        cQryFull := cQryPe
    EndIf

    If !Empty(MV_PAR05)
        cQryFull += " ORDER BY C7_FILIAL, C7_XHAWB, C7_NUM, C7_ITEM "
    ElseIf !Empty(MV_PAR07)
        cQryFull += " ORDER BY C7_FILIAL, C7_NUM, C7_ITEM, C7_XHAWB "
    Else
        cQryFull += " ORDER BY C7_FILIAL, C7_XHAWB, C7_NUM, C7_ITEM "
    EndIF

    If Select("PEDAPR") > 0
        PEDAPR->(dbCloseArea())
    EndIf

    DbUseArea(.T., "TOPCONN", TCGenQry(,,cQryFull) , 'PEDAPR', .T., .F.)

    nLin := 0

    While PEDAPR->(!EOF())
        cQuery := " SELECT TOP(1) E2_VENCREA, E2_BAIXA FROM " + RetSqlName("SE2")
        cQuery += " WHERE E2_NUM = (SELECT TOP(1) D1_DOC FROM " + RetSqlName("SD1")
        cQuery += "     		 WHERE D1_FILIAL = '"+PEDAPR->C7_FILIAL+"' "
        cQuery += "     		 AND D1_PEDIDO = '"+PEDAPR->C7_NUM+"' "
        cQuery += "     		 AND D_E_L_E_T_ = '') "
        cQuery += " AND E2_PREFIXO = (SELECT TOP(1) D1_SERIE FROM " + RetSqlName("SD1")
        cQuery += "    		          WHERE D1_FILIAL = '"+PEDAPR->C7_FILIAL+"' "
        cQuery += "    		          AND D1_PEDIDO = '"+PEDAPR->C7_NUM+"' "
        cQuery += "    		          AND D_E_L_E_T_ = '') "
        cQuery += " AND E2_FORNECE = '"+PEDAPR->C7_FORNECE+"' "
        cQuery += " AND E2_LOJA = '"+PEDAPR->C7_LOJA+"' "
        cQuery += " AND E2_BAIXA <> '' "
        cQuery += " AND D_E_L_E_T_ = '' "
        cQuery += " ORDER BY E2_PARCELA DESC "

        If Select("PGTOX") > 0
            PGTOX->(dbCloseArea())
        EndIf

        DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery) , 'PGTOX', .T., .F.)
        
        nLin++

        AADD(aLinha,{PEDAPR->C7_FILIAL,;
                    PEDAPR->C7_NUM,; 
                    DTOC(STOD(PEDAPR->C7_EMISSAO)),; 
                    PEDAPR->A2_NREDUZ,; 
                    PEDAPR->C7_PRODUTO,; 
                    Alltrim(PEDAPR->C7_DESCRI),; 
                    PEDAPR->C7_QUANT,; 
                    PEDAPR->C7_PRECO,; 
                    PEDAPR->C7_TOTAL,; 
                    PEDAPR->CR_GRUPO,; 
                    PEDAPR->NOME_GRUPO,; 
                    DTOC(STOD(PEDAPR->CR_DATALIB)),; 
                    Alltrim(GetAdvFVal("SAK","AK_NOME",xFilial("SAK")+PEDAPR->CR_LIBAPRO,1,"")),;
                    PEDAPR->C7_XHAWB,;
                    Iif(!Empty(PGTOX->E2_VENCREA),STOD(PGTOX->E2_VENCREA),""),;
                    Iif(!Empty(PGTOX->E2_BAIXA),STOD(PGTOX->E2_BAIXA),""),;
                    PEDAPR->C7_CONAPRO,;
                    DTOC(CTOD("  /  /  ")),; //DATA APROVAÇÃO N1
                    "",;               //APROVADOR N1
                    DTOC(CTOD("  /  /  ")),; //DATA APROVACAO N2
                    ""})               //APROVADOR N2
                     
        If PEDAPR->C7_CONAPRO == "L"
            cQuery := " SELECT TOP(1) CR_DATALIB, CR_LIBAPRO FROM " + RetSqlName("SCR") 
            cQuery += " WHERE CR_FILIAL = '"+PEDAPR->C7_FILIAL+"' "
            cQuery += " AND CR_NUM = '"+PEDAPR->C7_NUM+"' "
            cQuery += " AND CR_VALLIB > 0 "
            cQuery += " AND CR_DATALIB <> ''
            cQuery += " AND CR_NIVEL = '01' "
            cQuery += " AND D_E_L_E_T_ = '' "

            If Select("LIBN1") > 0
                LIBN1->(dbCloseArea())
            EndIf

            DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery) , 'LIBN1', .T., .F.)

            If LIBN1->(!EOF())
                aLinha[nLin][POS_DATA_N1] := DTOC(STOD(LIBN1->CR_DATALIB))
                aLinha[nLin][POS_APROVA_N1] := Alltrim(GetAdvFVal("SAK","AK_NOME",xFilial("SAK")+LIBN1->CR_LIBAPRO,1,""))
                aLinha[nLin][POS_DATA_N2] := DTOC(STOD(PEDAPR->CR_DATALIB))
                aLinha[nLin][POS_APROVA_N2] := Alltrim(GetAdvFVal("SAK","AK_NOME",xFilial("SAK")+PEDAPR->CR_LIBAPRO,1,""))
            EndIf
        ElseIf PEDAPR->C7_CONAPRO == "B"
            aLinha[nLin][POS_DATA_N1] := DTOC(STOD(PEDAPR->CR_DATALIB))
            aLinha[nLin][POS_APROVA_N1] := Alltrim(GetAdvFVal("SAK","AK_NOME",xFilial("SAK")+PEDAPR->CR_LIBAPRO,1,""))
        EndIf

       PEDAPR->(dbSkip())
    EndDo

    If Empty(aLinha)
        Alert("Nao a dados a serem impressos!!!")
        Return(.T.)
    EndIf
    
    oFWMsExcel := FWMSExcelEx():New()

    aAdd(aWorkSheet,"PEDIDOS DE COMPRAS APROVADOS")
    oFWMsExcel:AddworkSheet( aWorkSheet[x] ) 
    oFWMsExcel:AddTable( aWorkSheet[x], aWorkSheet[x] ) 
    oFWMsExcel:AddColumn(aWorkSheet[x], aWorkSheet[x], "STATUS"         ,1,1,.F.)
    oFWMsExcel:AddColumn(aWorkSheet[x], aWorkSheet[x], "FILIAL"         ,1,1,.F.)
    oFWMsExcel:AddColumn(aWorkSheet[x], aWorkSheet[x], "PEDIDO" 	    ,1,1,.F.)
    oFWMsExcel:AddColumn(aWorkSheet[x], aWorkSheet[x], "PROCESSO" 	    ,1,1,.F.)
    oFWMsExcel:AddColumn(aWorkSheet[x], aWorkSheet[x], "EMISSAO"   	    ,1,4,.F.)
    oFWMsExcel:AddColumn(aWorkSheet[x], aWorkSheet[x], "FORNECEDOR"	    ,1,1,.F.)
    oFWMsExcel:AddColumn(aWorkSheet[x], aWorkSheet[x], "PRODUTO"        ,1,1,.F.)
    oFWMsExcel:AddColumn(aWorkSheet[x], aWorkSheet[x], "DESCRICAO"      ,1,1,.F.)
    oFWMsExcel:AddColumn(aWorkSheet[x], aWorkSheet[x], "QUANTIDADE"     ,1,2,.F.)
    oFWMsExcel:AddColumn(aWorkSheet[x], aWorkSheet[x], "PREÇO UNIT."    ,1,3,.F.)
    oFWMsExcel:AddColumn(aWorkSheet[x], aWorkSheet[x], "VALOR TOTAL"    ,1,3,.F.)
    oFWMsExcel:AddColumn(aWorkSheet[x], aWorkSheet[x], "DATA VENCIMENTO",1,1,.F.)
    oFWMsExcel:AddColumn(aWorkSheet[x], aWorkSheet[x], "DATA PAGAMENTO" ,1,4,.F.)
    oFWMsExcel:AddColumn(aWorkSheet[x], aWorkSheet[x], "GRUPO"          ,1,1,.F.)
    oFWMsExcel:AddColumn(aWorkSheet[x], aWorkSheet[x], "NOME GRUPO"     ,1,1,.F.)
    oFWMsExcel:AddColumn(aWorkSheet[x], aWorkSheet[x], "DT.LIBERACAO N1",1,4,.F.)
    oFWMsExcel:AddColumn(aWorkSheet[x], aWorkSheet[x], "APROVADOR N1"   ,1,1,.F.)
    oFWMsExcel:AddColumn(aWorkSheet[x], aWorkSheet[x], "DT.LIBERACAO N2",1,4,.F.)
    oFWMsExcel:AddColumn(aWorkSheet[x], aWorkSheet[x], "APROVADOR N2"   ,1,1,.F.)
        
    For nlx := 1 to Len(aLinha)
        If MV_PAR13 == 1 .AND. Empty(aLinha[nlx][POS_DATA_PGTO])
            Loop
        ElseIf MV_PAR13 == 2 .AND. !Empty(aLinha[nlx][POS_DATA_PGTO])
            Loop
        EndIf

        If Empty(cPedVez)
            cPedVez := aLinha[nlx][POS_PEDIDO]
        EndIF

        If cPedVez <> aLinha[nlx][POS_PEDIDO]
            lLinha := !lLinha
            cPedVez := aLinha[nlx][POS_PEDIDO]

            oFWMsExcel:SetCelBold(.T.)
            oFWMsExcel:SetCelBgColor(cCor2)
            oFWMsExcel:AddRow(aWorkSheet[X], aWorkSheet[X], {,,,,,,,"TOTAL DO PEDIDO",,,nTotPed,,,,,,,,},{1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19} )
            
            nTotPed := 0
        EndIf

        oFWMsExcel:SetCelBold(.F.)
        oFWMsExcel:SetCelBgColor(cCor1)
        oFWMsExcel:AddRow(aWorkSheet[X], aWorkSheet[X], { Iif(aLinha[nlx][POS_STATUS] == "L","APROVADO","PENDENTE"),;
                                                          aLinha[nlx][POS_FILIAL],;
                                                          aLinha[nlx][POS_PEDIDO],;
                                                          aLinha[nlx][POS_PROCESSO],;
                                                          aLinha[nlx][POS_EMISSAO],;
                                                          aLinha[nlx][POS_FORNECEDOR],;
                                                          aLinha[nlx][POS_PRODUTO],;
                                                          aLinha[nlx][POS_DESCRICAO],;
                                                          /*Transform(*/aLinha[nlx][POS_QUANTIDADE]/*,PesqPict("SC7","C7_QUANT"))*/,;
                                                          /*Transform(*/aLinha[nlx][POS_PRECO_UNT]/*,PesqPict("SC7","C7_PRECO"))*/,;
                                                          /*Transform(*/aLinha[nlx][POS_TOTAL]/*,PesqPict("SC7","C7_TOTAL"))*/,;
                                                          aLinha[nlx][POS_VENCIMENTO],;
                                                          aLinha[nlx][POS_DATA_PGTO],;
                                                          aLinha[nlx][POS_GRUPO],;
                                                          aLinha[nlx][POS_NOME_GRUPO],;
                                                          aLinha[nlx][POS_DATA_N1],;
                                                          aLinha[nlx][POS_APROVA_N1],;
                                                          aLinha[nlx][POS_DATA_N2],;
                                                          aLinha[nlx][POS_APROVA_N2]},;
                                                          {1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19})
        
        nTotPed += aLinha[nlx][POS_TOTAL]

        If nlx == Len(alinha)
            oFWMsExcel:SetCelBold(.T.)
            oFWMsExcel:SetCelBgColor(cCor2)
            oFWMsExcel:AddRow(aWorkSheet[X], aWorkSheet[X], {,,,,,,,"TOTAL DO PEDIDO",,,nTotPed,,,,,,,,},{1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19} )
        EndIf
    Next

    oFWMsExcel:Activate()
    oFWMsExcel:GetXMLFile(cCaminho + cNome)
    //oExcel := MsExcel():New()
    //oExcel:WorkBooks:Open(cCaminho + cNome)
    //oExcel:SetVisible(.T.)
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
Static Function PergPara(cPerg)
Local aArea	    := GetArea()
Local aRegs		:= {}
Local i

AAdd(aRegs,{"01","Filial de............?","mv_ch1","C",02,0,0,"G","mv_par01",""          ,""   ,""      ,""         ,""         })
AAdd(aRegs,{"02","Filial ate...........?","mv_ch2","C",02,0,0,"G","mv_par02","NaoVazio()",""   ,""      ,""         ,""         })
AAdd(aRegs,{"03","Data Liberacao de....?","mv_ch3","D",08,0,0,"G","mv_par03","NaoVazio()",""   ,""      ,""         ,""         })
AAdd(aRegs,{"04","Data Liberacao ate...?","mv_ch4","D",08,0,0,"G","mv_par04","NaoVazio()",""   ,""      ,""         ,""         })
AAdd(aRegs,{"05","Processo de..........?","mv_ch5","C",17,0,0,"G","mv_par05",""          ,"SW6",""      ,""         ,""         })
AAdd(aRegs,{"06","Processo ate.........?","mv_ch6","C",17,0,0,"G","mv_par06","NaoVazio()","SW6",""      ,""         ,""         })
AAdd(aRegs,{"07","Pedido de............?","mv_ch7","C",06,0,0,"G","mv_par07",""          ,"SC7",""      ,""         ,""         })
AAdd(aRegs,{"08","Pedido ate...........?","mv_ch8","C",06,0,0,"G","mv_par08","NaoVazio()","SC7",""      ,""         ,""         })
AAdd(aRegs,{"09","Data Emissao de......?","mv_ch9","D",08,0,0,"G","mv_par09","NaoVazio()",""   ,""      ,""         ,""         })
AAdd(aRegs,{"10","Data Emissao ate.....?","mv_cha","D",08,0,0,"G","mv_par10","NaoVazio()",""   ,""      ,""         ,""         })
AAdd(aRegs,{"11","Grupo de.............?","mv_chb","C",06,0,4,"G","mv_par11",""          ,"SAK",""      ,""         ,""         })
AAdd(aRegs,{"12","Grupo ate............?","mv_chc","C",06,0,4,"G","mv_par12","NaoVazio()","SAK",""      ,""         ,""         })
AAdd(aRegs,{"13","Considera Pagamentos.?","mv_chd","C",01,0,3,"C","mv_par13",""          ,""   ,"Pagos" ,"Em aberto","Ambos"    })
AAdd(aRegs,{"14","Considera Pedidos....?","mv_che","C",01,0,1,"C","mv_par14",""          ,""   ,"Ambos" ,"Aprovados","Pendentes"})

dbSelectArea("SX1")
dbSetOrder(1)
For i:=1 to Len(aRegs)
	dbSeek(cPerg+aRegs[i][1])
	If !Found() .or. aRegs[i][2]<>X1_PERGUNT
		RecLock("SX1",!Found())
           SX1->X1_GRUPO   := cPerg
           SX1->X1_ORDEM   := aRegs[i][01]
           SX1->X1_PERGUNT := aRegs[i][02]
           SX1->X1_VARIAVL := aRegs[i][03]
           SX1->X1_TIPO    := aRegs[i][04]
           SX1->X1_TAMANHO := aRegs[i][05]
           SX1->X1_DECIMAL := aRegs[i][06]
           SX1->X1_PRESEL  := aRegs[i][07]
           SX1->X1_GSC     := aRegs[i][08]
           SX1->X1_VAR01   := aRegs[i][09]
           SX1->X1_VALID   := aRegs[i][10]
           SX1->X1_F3      := aRegs[i][11]
           SX1->X1_DEF01   := aRegs[i][12]
           SX1->X1_DEF02   := aRegs[i][13]
           SX1->X1_DEF03   := aRegs[i][14]
		MsUnlock()
	Endif
Next
RestArea(aArea)
Return
