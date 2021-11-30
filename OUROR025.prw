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

    Processa({|| OUROR25()},"Gerando relatório de Fretes Internacional...")

Return

Static Function OUROR25()
    Local oFWMsExcel
    Local aWorkSheet	:= {}
    Local X             := 1
    Local aLinha        := {}
    Local nlx           := 0
    Local cCor1         := "#F0F8FF"
    Local cCor2         := "#87CEFA"
    //Local cCor          := ""
    Local cHora		    := Time()
    Local cNome		    := 'Relatorio_Frete_Internacional'+ DtoS(dDataBase)+ '_' + SubStr(cHora,1,2) + SubStr(cHora,4,2) + '.xls'
    //Local lLinha        := .T.
    Local nTotFil       := 0
    Local nTotPes       := 0
    Local nTotGer       := 0
    Local nPesGer       := 0
    Local lFilSC        := .F.
    Local lFilFor       := .F.
    Local lFilPor       := .F.
    Local lFilETA       := .F.
    Local lFilPO        := .F.
    Local cSCAtu        := ""
    Local cForAtu       := ""
    Local cPorOAtu      := ""
    Local cPorDAtu      := ""
    Local cPorETA       := ""
    Local cPorPO        := ""
    Local cCabec        := ""
    Local nContPO       := 0
    Local aPoLista      := {}
    Local lImp          := .T.
    Local nPos          := 0
    Local cPerg		    := "OUROR025  "
    local tmp           := getTempPath()
    Private cCaminho    := ""
    
    PergPara(cPerg)

	If !Pergunte(cPerg,.T.)
		Return(.T.)
    else
        cCaminho := cGetFile( , 'Selecione a pasta de destino', , tmp, .F., GETF_LOCALHARD+GETF_RETDIRECTORY,.F.)
	Endif

    If Empty(cCaminho)
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
    cQuery += "        SW2.W2_XDT_ETA, "
    cQuery += "        SW2.W2_PESO_B, "
    cQuery += "        ZAE.ZAE_CT40HC, "
	cQuery += "        ZAE.ZAE_CT40DR, "
	cQuery += "        ZAE.ZAE_CT40RF, "
	cQuery += "        ZAE.ZAE_CT20DR, "
	cQuery += "        ZAE.ZAE_CT20RF, "
	cQuery += "        ZAE.ZAE_PARTLO, "
	cQuery += "        ZAE.ZAE_CRITER "
    cQuery += " FROM " + RetSqlName("SW2") + " SW2 "
    cQuery += "     INNER JOIN " + RetSqlName("SW3") + " SW3 "
    cQuery += "         ON SW3.W3_FILIAL = SW2.W2_FILIAL "
    cQuery += "         AND SW3.W3_PO_NUM = SW2.W2_PO_NUM "
    cQuery += "         AND SW3.D_E_L_E_T_ = '' "
    cQuery += "     INNER JOIN " + RetSqlName("SW0") + " SW0 "
    cQuery += "         ON SW0.W0__NUM = SW3.W3_SI_NUM "
    cQuery += "         AND SW0.W0_C1_NUM BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"' "
    cQuery += "         AND SW0.D_E_L_E_T_ = '' "
    cQuery += "     LEFT JOIN " + RetSqlName("ZAE") + " ZAE "
    cQuery += "         ON ZAE.ZAE_NUMSC =  SW0.W0_C1_NUM "
    cQuery += "     	AND ZAE.ZAE_DTENTR = (SELECT TOP(1)C1_DATPRF FROM " + RetSqlName("SC1")
    cQuery += "     						  WHERE D_E_L_E_T_ = '' "
    cQuery += "     						  AND C1_FILIAL = (SELECT YT_X_FILIA FROM " + RetSqlName("SYT")
	cQuery += "  											   WHERE YT_COD_IMP = SW2.W2_IMPORT "
	cQuery += "	    										   AND D_E_L_E_T_ = '') "
    cQuery += "     						  AND C1_NUM = SW0.W0_C1_NUM "
    cQuery += "     						  AND C1_PEDIDO = SW2.W2_PO_NUM) "
    cQuery += "     	AND ZAE.D_E_L_E_T_ = '' "
    cQuery += " WHERE  SW2.W2_XDT_ETA BETWEEN '"+DTOS(MV_PAR03)+"' AND '"+DTOS(MV_PAR04)+"' "
    cQuery += "        AND SW2.W2_FORN BETWEEN '"+MV_PAR05+"' AND '"+MV_PAR06+"' "
    cQuery += "        AND SW2.W2_ORIGEM BETWEEN '"+MV_PAR07+"' AND '"+MV_PAR08+"' "
    cQuery += "        AND SW2.W2_DEST BETWEEN '"+MV_PAR09+"' AND '"+MV_PAR10+"' "    
    cQuery += "        AND SW2.D_E_L_E_T_ = '' "
    cQuery += " GROUP BY SW0.W0_C1_NUM, "
    cQuery += " 	   SW2.W2_PO_DT, "
    cQuery += "        SW2.W2_PO_NUM, "
    cQuery += "        SW2.W2_FORN, "
    cQuery += "        SW2.W2_FORLOJ, "
    cQuery += "        SW2.W2_ORIGEM, "
    cQuery += " 	   SW2.W2_DEST, "
    cQuery += "        SW2.W2_MT3, "
    cQuery += "        SW2.W2_XDT_ETA, "
    cQuery += "        SW2.W2_PESO_B, "
    cQuery += "        ZAE.ZAE_CT40HC, "
	cQuery += "        ZAE.ZAE_CT40DR, "
	cQuery += "        ZAE.ZAE_CT40RF, "
	cQuery += "        ZAE.ZAE_CT20DR, "
	cQuery += "        ZAE.ZAE_CT20RF, "
	cQuery += "        ZAE.ZAE_PARTLO, "
	cQuery += "        ZAE.ZAE_CRITER "
    
    If MV_PAR11 == 1
        cQuery += " ORDER BY SW0.W0_C1_NUM, W2_XDT_ETA
    ElseIf MV_PAR11 == 2
        cQuery += " ORDER BY SW2.W2_FORN, W2_XDT_ETA
    ElseIf MV_PAR11 == 3
        cQuery += " ORDER BY SW2.W2_ORIGEM, SW2.W2_DEST, W2_XDT_ETA
    ElseIf MV_PAR11 == 4
        cQuery += " ORDER BY W2_XDT_ETA
    ElseIf MV_PAR11 == 5
        cQuery += " ORDER BY SW2.W2_PO_NUM, W2_XDT_ETA
    EndIf 
    
    If Select("RELX") > 0
        RELX->(dbCloseArea())
    EndIf

    DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery) , 'RELX', .T., .F.)

        
    While RELX->(!EOF())
        AADD(aLinha,{RELX->W0_C1_NUM, STOD(RELX->W2_PO_DT), RELX->W2_PO_NUM, RELX->W2_FORN, Alltrim(GetAdvFVal("SA2","A2_NREDUZ",xFilial("SA2") + RELX->W2_FORN + RELX->W2_FORLOJ,1 )), Alltrim(GetAdvFVal("SYR","YR_CID_ORI",xFilial("SYR") + "01" + RELX->W2_ORIGEM,1 )) , RELX->W2_DEST , STOD(RELX->W2_XDT_ETA), RELX->W2_MT3, RELX->W2_PESO_B, RELX->ZAE_CT40HC, RELX->ZAE_CT40DR, RELX->ZAE_CT40RF, RELX->ZAE_CT20DR, RELX->ZAE_CT20RF, RELX->ZAE_PARTLO, RELX->ZAE_CRITER})
        RELX->(dbSkip())
    EndDo

    If Empty(aLinha)
        Alert("Nao ha dados a serem impressos!!!")
        Return(.T.)
    EndIf
    
    If MV_PAR11 == 1
        lFilSC := .T.
        cCabec := "Ordenacao - Solicitação de Compras"
    ElseIf MV_PAR11 == 2
        lFilFor := .T.
        cCabec := "Ordenacao - Fornecedor"
    ElseIf MV_PAR11 == 3
        lFilPor := .T.
        cCabec := "Ordenacao - Porto Origem / Destino"
    ElseIf MV_PAR11 == 4
        lFilETA := .T.
        cCabec := "Ordenacao - ETA"
    ElseIf MV_PAR11 == 5
        lFilPO := .T.
        cCabec := "Ordenacao - Purchase Order"
    EndIf

    oFWMsExcel := FWMSExcelEx():New()

    aAdd(aWorkSheet,"Analise para Cotacao Frete Internacional - " + cCabec )
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
    oFWMsExcel:AddColumn(aWorkSheet[x], aWorkSheet[x], "Peso Bruto"     ,1,2,.F.)
    oFWMsExcel:AddColumn(aWorkSheet[x], aWorkSheet[x], "CTN 40HC"       ,1,2,.F.)
    oFWMsExcel:AddColumn(aWorkSheet[x], aWorkSheet[x], "CTN 40DR"       ,1,2,.F.)
    oFWMsExcel:AddColumn(aWorkSheet[x], aWorkSheet[x], "CTN 40RF"       ,1,2,.F.)
    oFWMsExcel:AddColumn(aWorkSheet[x], aWorkSheet[x], "CTN 20DR"       ,1,2,.F.)
    oFWMsExcel:AddColumn(aWorkSheet[x], aWorkSheet[x], "CTN 20RF"       ,1,2,.F.)
    oFWMsExcel:AddColumn(aWorkSheet[x], aWorkSheet[x], "PART LOT"       ,1,2,.F.)
    oFWMsExcel:AddColumn(aWorkSheet[x], aWorkSheet[x], "CRITERIO"       ,1,1,.F.)

    For nlx := 1 to Len(aLinha)

        If nlx == 1
            If lFilSC
                cSCAtu := aLinha[nlx][1]
            ElseIf lFilFor
                cForAtu := aLinha[nlx][4]
            ElseIf lFilPor
                cPorOAtu := aLinha[nlx][6]
                cPorDAtu := aLinha[nlx][7]
            ElseIf lFilETA
                cPorETA := aLinha[nlx][8]
            ElseIf lFilPO
                cPorPO := aLinha[nlx][3]
            EndIf
        EndIF

        If lFilSC
            If cSCAtu <> aLinha[nlx][1]
                oFWMsExcel:SetCelBold(.T.)
                oFWMsExcel:SetCelBgColor(cCor2)
                oFWMsExcel:AddRow(aWorkSheet[X], aWorkSheet[X], {,,,,,,"SUB TOTAL",,nTotFil,nTotPes,,,,,,,},{1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17} )
                nTotFil := 0
                nTotPes := 0
                cSCAtu := aLinha[nlx][1]
            EndIf
        ElseIf lFilFor
            If cForAtu <> aLinha[nlx][4]
                oFWMsExcel:SetCelBold(.T.)
                oFWMsExcel:SetCelBgColor(cCor2)
                oFWMsExcel:AddRow(aWorkSheet[X], aWorkSheet[X], {,,,,,,"SUB TOTAL",,nTotFil,nTotPes,,,,,,,},{1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17} )
                nTotFil := 0
                nTotPes := 0
                cForAtu := aLinha[nlx][4]
            EndIf
        ElseIf lFilPor
            If cPorOAtu <> aLinha[nlx][6] .OR. cPorDAtu <> aLinha[nlx][7]
                oFWMsExcel:SetCelBold(.T.)
                oFWMsExcel:SetCelBgColor(cCor2)
                oFWMsExcel:AddRow(aWorkSheet[X], aWorkSheet[X], {,,,,,,"SUB TOTAL",,nTotFil,nTotPes,,,,,,,},{1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17} )
                nTotFil := 0
                nTotPes := 0
                cForAtu := aLinha[nlx][4]
                cPorOAtu := aLinha[nlx][6]
                cPorDAtu := aLinha[nlx][7]
            EndIf
        ElseIf lFilETA
            If cPorETA <> aLinha[nlx][8]
                oFWMsExcel:SetCelBold(.T.)
                oFWMsExcel:SetCelBgColor(cCor2)
                oFWMsExcel:AddRow(aWorkSheet[X], aWorkSheet[X], {,,,,,,"SUB TOTAL",,nTotFil,nTotPes,,,,,,,},{1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17} )
                nTotFil := 0
                nTotPes := 0
                cPorETA := aLinha[nlx][8]
            EndIf
        ElseIf lFilPO
            If cPorPO <> aLinha[nlx][3]
                oFWMsExcel:SetCelBold(.T.)
                oFWMsExcel:SetCelBgColor(cCor2)
                oFWMsExcel:AddRow(aWorkSheet[X], aWorkSheet[X], {,,,,,,"SUB TOTAL",,nTotFil,nTotPes,,,,,,,},{1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17} )
                nTotFil := 0
                nTotPes := 0
                cPorPO := aLinha[nlx][3]
                nContPO := 1 
            Else 
                nContPO++
            EndIf
        EndIf

        oFWMsExcel:SetCelBold(.F.)
        oFWMsExcel:SetCelBgColor(cCor1)

        nPos := aScan(aPoLista ,{|x| AllTrim(x) == Alltrim(aLinha[nlx][3])})

        If nPos > 0
            lImp := .F.
        else
            lImp := .T.
            AADD(aPoLista,Alltrim(aLinha[nlx][3]))
        EndIf

        If !lImp
            oFWMsExcel:AddRow(aWorkSheet[X], aWorkSheet[X], {aLinha[nlx][1],aLinha[nlx][2],aLinha[nlx][3],aLinha[nlx][4],aLinha[nlx][5],aLinha[nlx][6],aLinha[nlx][7],aLinha[nlx][8],aLinha[nlx][9],aLinha[nlx][10],aLinha[nlx][11],aLinha[nlx][12],aLinha[nlx][13],aLinha[nlx][14],aLinha[nlx][15],aLinha[nlx][16],Iif(aLinha[nlx][17]=="V","Volume",Iif(aLinha[nlx][17]=="P","Peso",""))},{1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17} )
        else
            oFWMsExcel:AddRow(aWorkSheet[X], aWorkSheet[X], {aLinha[nlx][1],aLinha[nlx][2],aLinha[nlx][3],aLinha[nlx][4],aLinha[nlx][5],aLinha[nlx][6],aLinha[nlx][7],aLinha[nlx][8],aLinha[nlx][9],aLinha[nlx][10],aLinha[nlx][11],aLinha[nlx][12],aLinha[nlx][13],aLinha[nlx][14],aLinha[nlx][15],aLinha[nlx][16],Iif(aLinha[nlx][17]=="V","Volume",Iif(aLinha[nlx][17]=="P","Peso",""))},{1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17} )
            nTotFil += aLinha[nlx][9]
            nTotPes += aLinha[nlx][10]
            nTotGer += aLinha[nlx][9]
            nPesGer += aLinha[nlx][10]
        EndIf

        
        If nlx == Len(aLinha)
            oFWMsExcel:SetCelBold(.T.)
            oFWMsExcel:SetCelBgColor(cCor2)
            oFWMsExcel:AddRow(aWorkSheet[X], aWorkSheet[X], {,,,,,,"SUB TOTAL",,nTotFil,nTotPes,,,,,,,},{1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17} )
            nTotFil := 0
            nTotPes := 0
            
            oFWMsExcel:SetCelBgColor("#4f81bd") 
            oFWMsExcel:AddRow(aWorkSheet[X], aWorkSheet[X], {,,,,"TOTAL GERAL",,,,nTotGer,nPesGer,,,,,,,},{1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17} )

        EndIf
        
    Next

    oFWMsExcel:Activate()
    oFWMsExcel:GetXMLFile(cCaminho + cNome)
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
/*/
???????????????????????????????????????
???????????????????????????????????????
???????????????????????????????????????
??un??o    ?AjustaSX1?Autor ?Carlos G. Berganton   ?Data ?15/03/04 ??
???????????????????????????????????????
??escri??o ?Verifica as perguntas inclu?do-as caso n?o existam        ??
???????????????????????????????????????
???????????????????????????????????????
???????????????????????????????????????
/*/
Static Function PergPara(cPerg)
Local aArea	    := GetArea()
Local aRegs		:= {}
Local i

AAdd(aRegs,{"01","Numero SC de.......?","mv_ch1","C",06,0,0,"G","mv_par01",""          ,"SC1",""                     ,""          ,""                    ,""   ,""              })
AAdd(aRegs,{"02","Numero SC ate......?","mv_ch2","C",06,0,0,"G","mv_par02","NaoVazio()","SC1",""                     ,""          ,""                    ,""   ,""              })
AAdd(aRegs,{"03","ETA de.............?","mv_ch3","D",08,0,0,"G","mv_par03","NaoVazio()",""   ,""                     ,""          ,""                    ,""   ,""              })
AAdd(aRegs,{"04","ETA ate............?","mv_ch4","D",08,0,0,"G","mv_par04","NaoVazio()",""   ,""                     ,""          ,""                    ,""   ,""              })
AAdd(aRegs,{"05","Fornecedor de......?","mv_ch5","C",06,0,0,"G","mv_par05",""          ,"SA2",""                     ,""          ,""                    ,""   ,""              })
AAdd(aRegs,{"06","Fornecedor ate.....?","mv_ch6","C",06,0,0,"G","mv_par06","NaoVazio()","SA2",""                     ,""          ,""                    ,""   ,""              })
AAdd(aRegs,{"07","Porto Origem de....?","mv_ch7","C",03,0,0,"G","mv_par07",""          ,"SYR",""                     ,""          ,""                    ,""   ,""              })
AAdd(aRegs,{"08","Porto Origem ate...?","mv_ch8","C",03,0,0,"G","mv_par08","NaoVazio()","SYR",""                     ,""          ,""                    ,""   ,""              })
AAdd(aRegs,{"09","Porto Destino de...?","mv_ch9","C",03,0,0,"G","mv_par09",""          ,"SYR",""                     ,""          ,""                    ,""   ,""              })
AAdd(aRegs,{"10","Porto Destino ate..?","mv_cha","C",03,0,0,"G","mv_par10","NaoVazio()","SYR",""                     ,""          ,""                    ,""   ,""              })
AAdd(aRegs,{"11","Ordenação..........?","mv_chb","C",01,0,4,"C","mv_par11",""          ,""   ,"Solicitacao de Compra","Fornecedor","Porto Origem/Destino","ETA","Purchase Order"})

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
           SX1->X1_DEF04   := aRegs[i][15]
           SX1->X1_DEF05   := aRegs[i][16]
		MsUnlock()
	Endif
Next
RestArea(aArea)
Return
