#Include "Protheus.ch"
#Include "TOTVS.CH"
#Include "TOPCONN.CH"

#DEFINE PAR_FIL_DE      1
#DEFINE PAR_FIL_ATE     2
#DEFINE PAR_DTLIB_DE    3
#DEFINE PAR_DTLIB_ATE   4
#DEFINE PAR_PEDIDO_DE   5
#DEFINE PAR_PEDIDO_ATE  6
#DEFINE PAR_GRUPO_DE    7
#DEFINE PAR_GRUPO_ATE   8
#DEFINE PAR_BAIXADO     9

#DEFINE POS_FILIAL      1
#DEFINE POS_PEDIDO      2
#DEFINE POS_EMISSAO     3
#DEFINE POS_FORNECEDOR  4
#DEFINE POS_PRODUTO     5
#DEFINE POS_DESCRICAO   6
#DEFINE POS_QUANTIDADE  7
#DEFINE POS_PRECO_UNT   8
#DEFINE POS_TOTAL       9
#DEFINE POS_ULT_COMPRA  10
#DEFINE POS_ULT_PRECO   11
#DEFINE POS_GRUPO       12
#DEFINE POS_NOME_GRUPO  13
#DEFINE POS_DATA_LIB    14
#DEFINE POS_APROVADOR   15
#DEFINE POS_PROCESSO    16
#DEFINE POS_COND_PGTO   17
#DEFINE POS_DATA_PGTO   18

/*
Rotina: OUROR028
Relatorio de Pedidos de Compra aprovados
Autor: Rodrigo Dias Nunes
Data: 02/09/2021
*/
User Function OUROR028()

    Processa({|| OUROR28()},"Gerando relatÛrio de Pedidos de Comoras aprovados...")

Return

Static Function OUROR28()
    Local oFWMsExcel
    Local aWorkSheet	:= {}
    Local X             := 1
    Local aLinha        := {}
    Local nlx           := 0
    Local cHora		    := Time()
    Local lLinha        := .T.
    Local cNome		    := 'Pedido_Compra_Aprovado_'+ DtoS(dDataBase)+ '_' + SubStr(cHora,1,2) + SubStr(cHora,4,2) + ".xls"
    Local cCor1         := "#F0F8FF"
    Local cCor2         := "#87CEFA"
    Local nTotPed       := 0
    Local cPedVez       := ""
    Private cCaminho    := ""
    Private aParam      := {}

    PergPara()

    If Empty(cCaminho) .OR. Empty(aParam)
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
    cQuery += " 	   (SELECT TOP(1) E4_DESCRI FROM " + RetSqlName("SE4")
    cQuery += " 	     WHERE E4_CODIGO = SC7.C7_COND "
    cQuery += " 	     AND D_E_L_E_T_ = '' "
    cQuery += "        ) AS COND_PGTO, "
    cQuery += " 	   (SELECT TOP(1)SD1.D1_VUNIT "
    cQuery += " 		 FROM " + RetSqlName("SD1") + " SD1 "
    cQuery += " 		 WHERE SD1.D1_FILIAL = SC7.C7_FILIAL "
    cQuery += " 		 AND SD1.D1_COD = SC7.C7_PRODUTO "
    cQuery += " 		 AND SD1.D1_TIPO = 'N' "
    cQuery += " 		 AND SD1.D1_PEDIDO > '' "
    cQuery += " 		 AND SD1.D_E_L_E_T_ = '' " 
    cQuery += " 		 ORDER BY D1_DTDIGIT DESC "
    cQuery += " 		) AS ULTIMO_PRECO, "
    cQuery += " 		(SELECT TOP(1)SD1.D1_DTDIGIT "
    cQuery += " 		 FROM " + RetSqlName("SD1") + " SD1 "
    cQuery += " 		 WHERE SD1.D1_FILIAL = SC7.C7_FILIAL "
    cQuery += " 		 AND SD1.D1_COD = SC7.C7_PRODUTO "
    cQuery += " 		 AND SD1.D1_TIPO = 'N' "
    cQuery += " 		 AND SD1.D1_PEDIDO > '' "
    cQuery += " 		 AND SD1.D_E_L_E_T_ = '' " 
    cQuery += " 		 ORDER BY D1_DTDIGIT DESC "
    cQuery += " 		) AS ULTIMA_COMPRA, "
    cQuery += "         SCR.CR_GRUPO, "
    cQuery += " 		(SELECT TOP(1)SAL.AL_DESC "
    cQuery += " 		 FROM " + RetSqlName("SAL") + " SAL "
    cQuery += " 		 WHERE SAL.AL_COD = SCR.CR_GRUPO "
    cQuery += " 		 AND D_E_L_E_T_ = '' "
    cQuery += " 		) AS NOME_GRUPO, "
    cQuery += " 		SCR.CR_DATALIB, "
    cQuery += " 		SCR.CR_LIBAPRO "	
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
    cQuery += " AND SCR.CR_GRUPO BETWEEN '"+aParam[PAR_GRUPO_DE]+"' AND '"+aParam[PAR_GRUPO_ATE]+"' "
    cQuery += " AND SCR.CR_DATALIB BETWEEN '"+DTOS(aParam[PAR_DTLIB_DE])+"' AND '"+DTOS(aParam[PAR_DTLIB_ATE])+"' "
    cQuery += " AND SCR.D_E_L_E_T_ = '' " 
    cQuery += " WHERE SC7.D_E_L_E_T_ = '' "
    cQuery += " AND SC7.C7_FILIAL BETWEEN '"+aParam[PAR_FIL_DE]+"' AND '"+aParam[PAR_FIL_ATE]+"'
    cQuery += " AND SC7.C7_NUM BETWEEN '"+aParam[PAR_PEDIDO_DE]+"' AND '"+aParam[PAR_PEDIDO_ATE]+"'
    cQuery += " AND SC7.C7_CONAPRO = 'L' "
    cQuery += " ORDER BY SC7.C7_FILIAL, SC7.C7_NUM, SC7.C7_ITEM "

    If Select("PEDAPR") > 0
        PEDAPR->(dbCloseArea())
    EndIf

    DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery) , 'PEDAPR', .T., .F.)

    While PEDAPR->(!EOF())
        cQuery := " SELECT TOP(1) E2_BAIXA FROM " + RetSqlName("SE2")
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
        
        AADD(aLinha,{PEDAPR->C7_FILIAL,;
                    PEDAPR->C7_NUM,; 
                    DTOC(STOD(PEDAPR->C7_EMISSAO)),; 
                    PEDAPR->A2_NREDUZ,; 
                    PEDAPR->C7_PRODUTO,; 
                    Alltrim(PEDAPR->C7_DESCRI),; 
                    PEDAPR->C7_QUANT,; 
                    PEDAPR->C7_PRECO,; 
                    PEDAPR->C7_TOTAL,; 
                    DTOC(STOD(PEDAPR->ULTIMA_COMPRA)),; 
                    PEDAPR->ULTIMO_PRECO,; 
                    PEDAPR->CR_GRUPO,; 
                    PEDAPR->NOME_GRUPO,; 
                    DTOC(STOD(PEDAPR->CR_DATALIB)),; 
                    Alltrim(GetAdvFVal("SAK","AK_NOME",xFilial("SAK")+PEDAPR->CR_LIBAPRO,1,"")),;
                    PEDAPR->C7_XHAWB,;
                    PEDAPR->COND_PGTO,;
                    Iif(!Empty(PGTOX->E2_BAIXA),STOD(PGTOX->E2_BAIXA),"") })
        
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
    oFWMsExcel:AddColumn(aWorkSheet[x], aWorkSheet[x], "FILIAL"         ,1,1,.F.)
    oFWMsExcel:AddColumn(aWorkSheet[x], aWorkSheet[x], "PEDIDO" 	    ,1,1,.F.)
    oFWMsExcel:AddColumn(aWorkSheet[x], aWorkSheet[x], "PROCESSO" 	    ,1,1,.F.)
    oFWMsExcel:AddColumn(aWorkSheet[x], aWorkSheet[x], "EMISSAO"   	    ,1,4,.F.)
    oFWMsExcel:AddColumn(aWorkSheet[x], aWorkSheet[x], "FORNECEDOR"	    ,1,1,.F.)
    oFWMsExcel:AddColumn(aWorkSheet[x], aWorkSheet[x], "PRODUTO"        ,1,1,.F.)
    oFWMsExcel:AddColumn(aWorkSheet[x], aWorkSheet[x], "DESCRICAO"      ,1,1,.F.)
    oFWMsExcel:AddColumn(aWorkSheet[x], aWorkSheet[x], "QUANTIDADE"     ,1,2,.F.)
    oFWMsExcel:AddColumn(aWorkSheet[x], aWorkSheet[x], "PRE«O UNIT."    ,1,3,.F.)
    oFWMsExcel:AddColumn(aWorkSheet[x], aWorkSheet[x], "VALOR TOTAL"    ,1,3,.F.)
    oFWMsExcel:AddColumn(aWorkSheet[x], aWorkSheet[x], "CONDICAO PGTO"  ,1,1,.F.)
    oFWMsExcel:AddColumn(aWorkSheet[x], aWorkSheet[x], "DATA PAGAMENTO" ,1,4,.F.)
    oFWMsExcel:AddColumn(aWorkSheet[x], aWorkSheet[x], "DT.ULT.COMPRA"  ,1,4,.F.)
    oFWMsExcel:AddColumn(aWorkSheet[x], aWorkSheet[x], "ULT.PRECO"      ,1,3,.F.)
    oFWMsExcel:AddColumn(aWorkSheet[x], aWorkSheet[x], "GRUPO"          ,1,1,.F.)
    oFWMsExcel:AddColumn(aWorkSheet[x], aWorkSheet[x], "NOME GRUPO"     ,1,1,.F.)
    oFWMsExcel:AddColumn(aWorkSheet[x], aWorkSheet[x], "DT.LIBERACAO"   ,1,4,.F.)
    oFWMsExcel:AddColumn(aWorkSheet[x], aWorkSheet[x], "APROVADOR"      ,1,1,.F.)
        
    For nlx := 1 to Len(aLinha)
        If aParam[PAR_BAIXADO] == 1 .AND. Empty(aLinha[nlx][POS_DATA_PGTO])
            Loop
        ElseIf aParam[PAR_BAIXADO] == 2 .AND. !Empty(aLinha[nlx][POS_DATA_PGTO])
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
            oFWMsExcel:AddRow(aWorkSheet[X], aWorkSheet[X], {,,,,,,"TOTAL DO PEDIDO",,,nTotPed,,,,,,,,},{1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18} )
            
            nTotPed := 0
        EndIf

        oFWMsExcel:SetCelBold(.F.)
        oFWMsExcel:SetCelBgColor(cCor1)
        oFWMsExcel:AddRow(aWorkSheet[X], aWorkSheet[X], { aLinha[nlx][POS_FILIAL],;
                                                          aLinha[nlx][POS_PEDIDO],;
                                                          aLinha[nlx][POS_PROCESSO],;
                                                          aLinha[nlx][POS_EMISSAO],;
                                                          aLinha[nlx][POS_FORNECEDOR],;
                                                          aLinha[nlx][POS_PRODUTO],;
                                                          aLinha[nlx][POS_DESCRICAO],;
                                                          /*Transform(*/aLinha[nlx][POS_QUANTIDADE]/*,PesqPict("SC7","C7_QUANT"))*/,;
                                                          /*Transform(*/aLinha[nlx][POS_PRECO_UNT]/*,PesqPict("SC7","C7_PRECO"))*/,;
                                                          /*Transform(*/aLinha[nlx][POS_TOTAL]/*,PesqPict("SC7","C7_TOTAL"))*/,;
                                                          aLinha[nlx][POS_COND_PGTO],;
                                                          aLinha[nlx][POS_DATA_PGTO],;
                                                          aLinha[nlx][POS_ULT_COMPRA],;
                                                          /*Transform(*/aLinha[nlx][POS_ULT_PRECO]/*,PesqPict("SD1","D1_VUNIT"))*/,;
                                                          aLinha[nlx][POS_GRUPO],;
                                                          aLinha[nlx][POS_NOME_GRUPO],;
                                                          aLinha[nlx][POS_DATA_LIB],;
                                                          aLinha[nlx][POS_APROVADOR]},;
                                                          {1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18})
        
        nTotPed += aLinha[nlx][POS_TOTAL]

        If nlx == Len(alinha)
            oFWMsExcel:SetCelBold(.T.)
            oFWMsExcel:SetCelBgColor(cCor2)
            oFWMsExcel:AddRow(aWorkSheet[X], aWorkSheet[X], {,,,,,,"TOTAL DO PEDIDO",,,nTotPed,,,,,,,,},{1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18} )
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
@since 02/09/2021
@version 1.0 
@type function
/*/
//--------------------------------------------------------------------
Static Function PergPara()
Local aRet	 := {}
Local aPergs := {}
local tmp    := getTempPath()
Local aCombo := {"Baixados","Em aberto","Ambos"}

aAdd(aPergs, {1, "Filial de"  ,Space(2) ,"","","SM0","",20,.F.})
aAdd(aPergs, {1, "Filial ate" ,"ZZ"     ,"","","SM0","",20,.T.})

aAdd(aPergs, {1, "Data Liberacao de"  ,CTOD("  /  /    ") ,"","","","",50,.T.})
aAdd(aPergs, {1, "Data Liberacao ate" ,CTOD("  /  /    ") ,"","","","",50,.T.})

aAdd(aPergs, {1, "Pedido de"  ,Space(6) ,"","","SC5","",50,.F.})
aAdd(aPergs, {1, "Pedido ate" ,"ZZZZZZ" ,"","","SC5","",50,.T.})

aAdd(aPergs, {1, "Grupo de"  ,Space(6) ,"","","SAL","",50,.F.})
aAdd(aPergs, {1, "Grupo ate" ,"ZZZZZZ" ,"","","SAL","",50,.T.})

aAdd(aPergs, {2, "Considera Pedidos" ,3 ,aCombo ,100,""   ,.T.})

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
