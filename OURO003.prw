#Include "Protheus.ch"
#Include "TOTVS.CH"
#Include "FWBROWSE.CH"
#Include "TOPCONN.CH"
#Include "MSGRAPHI.CH"
#Include "FWMVCDef.CH"

/*
Rotina: OURO003
Descrição: Ranking de Pedidos - Aprovação de Credito por cliente
Autor: Rodrigo Dias Nunes
Data: 16/07/2021
*/

User Function OURO003()
    Local aCoors 		:= FWGetDialogSize( oMainWnd )
    Local cQuery        := ""
    Local nPosRK        := ""
    Private oDlg      	:= NIL
    Private _oLayer1   	:= NIL
    private _oTPane1 	:= Nil  
    private _oTPane2 	:= Nil
    private _oTPane3 	:= Nil
    private oListRK  	:= Nil
    private oListPV  	:= Nil
    private aHeadRK     := {}
    private aColsRK     := {}     
    private aHeadPV		:= {}
    private aColsPV		:= {}

    Aadd(aHeadRK, {"Fornecedor"             , "CODFOR"	  , "@!"	                    , TamSx3("A2_COD")[1]	    , 0                     	, "" ,, "C", ""	,,,,})
    Aadd(aHeadRK, {"Nome"                   , "NOMEFOR"   , "@!"	                    , TamSx3("A2_NOME")[1]	    , 0                     	, "" ,, "C", ""	,,,,})
    Aadd(aHeadRK, {"Total dos Pedidos(R$)"  , "TOTPED"    , PesqPict("SC5","C5_XTOTPV")	, TamSx3("C5_XTOTPV")[1]	, TamSx3("C5_XTOTPV")[2]   	, "" ,, "N", ""	,,,,})

    Aadd(aHeadPV, {"Filial"    		, "FILPED"		, "@!"					        , TamSx3("C5_FILIAL")[1]	, 0                         , "",, "C", ""		,,,,})
    Aadd(aHeadPV, {"Pedido"    		, "PEDIDO"		, "@!"					        , TamSx3("C5_NUM")[1]	    , 0                         , "",, "C", ""		,,,,})
    Aadd(aHeadPV, {"Cliente"   		, "CLIENTE"		, "@!"					        , TamSx3("C5_CLIENTE")[1]	, 0                         , "",, "C", ""		,,,,})
    Aadd(aHeadPV, {"Loja"    		, "LOJA"		, "@!"					        , TamSx3("C5_LOJACLI")[1]	, 0                         , "",, "C", ""		,,,,})
    Aadd(aHeadPV, {"Condição Pgto"	, "CONDPGTO"	, "@!"					        , TamSx3("C5_CONDPAG")[1]	, 0                         , "",, "C", ""		,,,,})
    Aadd(aHeadPV, {"Valor Total"	, "VLRTOTAL"	, PesqPict("SC5","C5_XTOTPV")	, TamSx3("C5_XTOTPV")[1]	, TamSx3("C5_XTOTPV")[2]    , "",, "N", ""		,,,,})


    DEFINE FONT _oFont NAME 'Arial Black' SIZE 09, 15

    DEFINE MSDIALOG oDlg TITLE  "RANKING DE PEDIDOS" FROM  aCoors[1], aCoors[2] To aCoors[3], aCoors[4] PIXEL
    oDlg:lMaximized := .T.
    oDlg:lEscClose  := .F.

//CRIACAO DO LAYER	
	_oLayer1 := FWLayer():New()
	_oLayer1:Init(oDlg,.F.,.T.)
	_oLayer1:SetStyle("ROUND")

	//*********************
	//*Criacao das Linhas.*
	//*********************
	_oLayer1:AddLine( 'LIN_1'		, 35, .F.)
	_oLayer1:AddLine( 'LIN_2'		, 50, .F.)
	

	//*********************
	//*Criacao das Colunas.*
	//*********************
	_oLayer1:AddCollumn('COL_1'	,50,.T.,'LIN_1')
	_oLayer1:AddCollumn('COL_2'	,50,.T.,'LIN_1')
	_oLayer1:AddCollumn('COL_1'	,100,.T.,'LIN_2')
	
	//*********************
	//*Criacao das Janelas*
	//*********************
	_oLayer1:AddWindow('COL_1'		, 'JANELA_1'	, 'Ranking'	, 100, .F.,.T.,{||"" },"LIN_1",{||""})
	_oLayer1:AddWindow('COL_2'		, 'JANELA_2'	, 'Ações'	, 100, .F.,.T.,{||"" },"LIN_1",{||""})
	_oLayer1:AddWindow('COL_1'		, 'JANELA_3'	, 'Pedidos'	, 100, .F.,.T.,{||"" },"LIN_2",{||""})
	//*******************************
	//*Atribuindo janela aos objetos*
	//*******************************.
	_oTPane1 := _oLayer1:GetWinPanel("COL_1"	, "JANELA_1"	, "LIN_1")
	_oTPane2 := _oLayer1:GetWinPanel("COL_2"	, "JANELA_2"	, "LIN_1")
	_oTPane3 := _oLayer1:GetWinPanel("COL_1"	, "JANELA_3"	, "LIN_2")

//PAINEL RANKING
	
    cQuery := " SELECT SC9.C9_CLIENTE,SC9.C9_LOJA,SC5.C5_MOEDA, SC5.C5_XTOTPV "
    cQuery += " FROM SC9010 SC9, SA1010 SA1, SC5010 SC5 "
    cQuery += " WHERE "
    cQuery += " SC9.C9_BLCRED<>'  ' AND "
    cQuery += " SC9.C9_BLCRED<>'10' AND "
    cQuery += " SC9.C9_BLCRED<>'ZZ' AND "
    cQuery += " SC9.C9_BLCRED<>'09' AND "
    cQuery += " SC9.D_E_L_E_T_=' ' AND "
    cQuery += " SA1.A1_FILIAL='  ' AND "
    cQuery += " SA1.A1_COD = SC9.C9_CLIENTE AND "
    cQuery += " SA1.A1_LOJA = SC9.C9_LOJA AND "
    cQuery += " SA1.D_E_L_E_T_=' ' AND "
    cQuery += " SC5.C5_FILIAL=SC9.C9_FILIAL AND "
    cQuery += " SC5.C5_NUM=SC9.C9_PEDIDO AND "
    cQuery += " SC5.D_E_L_E_T_=' ' "
    cQuery += " GROUP BY SC9.C9_CLIENTE,SC9.C9_LOJA,SC5.C5_MOEDA, SC5.C5_XTOTPV "
    cQuery += " ORDER BY SC9.C9_CLIENTE,SC9.C9_LOJA "
    
    If Select("RANK") > 0
        RANK->(dbCloseArea())
    EndIf

    DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery) , 'RANK', .T., .F.)

    While RANK->(!EOF())
        If Empty(aColsRK)
            AADD(aColsRK,{Alltrim(RANK->C9_CLIENTE),Alltrim(GetAdvFVal( "SA1","A1_NOME",xFilial("SA1") + RANK->C9_CLIENTE,1 )),RANK->C5_XTOTPV,Alltrim(RANK->C9_LOJA)})
        Else
            nPosRK := aScan(aColsRK, {|x| Alltrim(x[1]) == Alltrim(RANK->C9_CLIENTE)})

            If nPosRK <> 0
                aColsRK[nPosRK][3] += RANK->C5_XTOTPV
            else
                AADD(aColsRK,{Alltrim(RANK->C9_CLIENTE),Alltrim(GetAdvFVal( "SA1","A1_NOME",xFilial("SA1") + RANK->C9_CLIENTE,1 )),RANK->C5_XTOTPV,Alltrim(RANK->C9_LOJA)})
            EndIf
        EndIf
            		
        RANK->(dbSkip())
	EndDo

    ASORT(aColsRK, , , { | x,y | y[3] < x[3] } )
    
    oListRK := TCBrowse():New( 01,0,650,135,,{"Cliente","Nome","Total dos Pedidos(R$)"},;
		{TamSx3("A1_COD")[1],TamSx3("A1_NOME")[1],15},_oTPane1,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, ) 
		
    oListRK:SetArray(aColsRK)		
      
	oListRK:bLine := {||{aColsRK[oListRK:nAt, 1],;
                        aColsRK[oListRK:nAt, 2]				,;
                        TRANSFORM(aColsRK[oListRK:nAt, 3],"@E 999,999,999.99")}}
   
	
    oListRK:Align := CONTROL_ALIGN_ALLCLIENT

    oListRK:bLDblClick := {|| Processa({||ChangeRK()},"Listando pedidos do cliente " + aColsRK[oListRK:nAt, 1] )}      

    
    //--------PEDIDOS
    oListPV := TCBrowse():New( 01,0,650,135,,{"Filial","Pedido","Cliente","Loja","Condição Pgto","Valor Total"},;
		{30,30,30,30,30,30},_oTPane3,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, ) 
    
    AADD(aColsPV,{"","","","","",0,""})
    
    oListPV:SetArray(aColsPV)		
 
    oListPV:bLine := {||{aColsPV[oListPV:nAt, 1],;
	                  	 aColsPV[oListPV:nAt, 2],;
                         aColsPV[oListPV:nAt, 3],;
                         aColsPV[oListPV:nAt, 4],;
                         aColsPV[oListPV:nAt, 5],;
		                 TRANSFORM  (aColsPV[oListPV:nAt, 6],"@E 999,999,999.99")}}
   
	oListPV:Align := CONTROL_ALIGN_ALLCLIENT


    //----------ACOES
    @ 010, 010 BUTTON oButton1 PROMPT "Visualiza Pedido" SIZE 080, 012 ACTION  Processa({|| BuscaPed()},"Buscando pedido " + aColsPV[oListPV:nAt, 2] ) OF _oTPane2 PIXEL
    @ 030, 010 BUTTON oButton1 PROMPT "Visualiza Cliente" SIZE 080, 012 ACTION  Processa({|| BuscaCli()},"Buscando cliente " + aColsRK[oListRK:nAt, 1] ) OF _oTPane2 PIXEL
    @ 050, 010 BUTTON oButton1 PROMPT "Extrair Relatorio" SIZE 080, 012 ACTION  Processa({|| ExtraiRel()},"Extraindo Relatorio de Pedidos x Clientes ") OF _oTPane2 PIXEL
    
    ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg, {|| oDlg:End()}, {|| oDlg:End() })

Return Nil

/*
Rotina: ChangeRK
Descrição: Lista pedidos do cliente
Autor: Rodrigo Dias Nunes
Data: 20/07/2021
*/

Static Function ChangeRK()
    Local cQuery := ""

    cQuery := " SELECT SC9.C9_FILIAL, SC9.C9_PEDIDO, SC9.C9_CLIENTE, SC9.C9_LOJA "
    cQuery += " FROM " + RetSqlName("SC9") + " SC9, "
    cQuery += RetSqlName("SA1") + " SA1, "
    cQuery += RetSqlName("SC5") + " SC5  "
    cQuery += " WHERE "
    cQuery += " SC9.C9_BLCRED<>'  ' AND "
    cQuery += " SC9.C9_BLCRED<>'10' AND "
    cQuery += " SC9.C9_BLCRED<>'ZZ' AND "
    cQuery += " SC9.C9_BLCRED<>'09' AND "
    cQuery += " SC9.D_E_L_E_T_=' ' AND "
    cQuery += " SA1.A1_FILIAL='  ' AND "
    cQuery += " SA1.A1_COD = SC9.C9_CLIENTE AND "
    cQuery += " SA1.A1_LOJA = SC9.C9_LOJA AND "
    cQuery += " SA1.D_E_L_E_T_=' ' AND "
    cQuery += " SC5.C5_FILIAL=SC9.C9_FILIAL AND "
    cQuery += " SC5.C5_NUM=SC9.C9_PEDIDO AND "
    cQuery += " SC5.D_E_L_E_T_=' '  AND "
    cQuery += " SC9.C9_CLIENTE = '"+aColsRK[oListRK:nAt, 1]+"' "
    cQuery += " GROUP BY  SC9.C9_FILIAL, SC9.C9_PEDIDO, SC9.C9_CLIENTE, SC9.C9_LOJA "
    cQuery += " ORDER BY SC9.C9_PEDIDO "
    
    If Select("PVRA") > 0
        PVRA->(dbCloseArea())
    EndIf

    DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery) , 'PVRA', .T., .F.)

    aColsPV := {}

    While PVRA->(!EOF())
        cQuery := " SELECT C5_FILIAL, C5_NUM, C5_CLIENTE, C5_LOJACLI, C5_CONDPAG, C5_XTOTPV, R_E_C_N_O_ "
        cQuery += " FROM " + RetSqlName("SC5")
        cQuery += " WHERE C5_FILIAL = '"+PVRA->C9_FILIAL+"' "
        cQuery += " AND C5_NUM = '"+PVRA->C9_PEDIDO+"' "
        cQuery += " AND C5_CLIENTE = '"+PVRA->C9_CLIENTE+"' "
        cQuery += " AND C5_LOJACLI = '"+PVRA->C9_LOJA+"' "
        cQuery += " AND D_E_L_E_T_ = ' ' " 

        If Select("PVX") > 0
            PVX->(dbCloseArea())
        EndIf

        DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery) , 'PVX', .T., .F.)

        If PVX->(!EOF())
            AADD(aColsPV,{Alltrim(PVX->C5_FILIAL),Alltrim(PVX->C5_NUM),Alltrim(PVX->C5_CLIENTE),Alltrim(PVX->C5_LOJACLI),Alltrim(PVX->C5_CONDPAG),PVX->C5_XTOTPV, PVX->R_E_C_N_O_})
        EndIf

        PVRA->(dbSkip())
	EndDo

    ASORT(aColsPV, , , { | x,y | y[2] > x[2] } )
    
    If Empty(aColsPV)
        AADD(aColsPV,{"","","","","",0,0})
    EndIf
    
    oListPV:SetArray(aColsPV)		
 
    oListPV:bLine := {||{aColsPV[oListPV:nAt, 1]+"         ",;
	                  	 aColsPV[oListPV:nAt, 2]+"         ",;
                         aColsPV[oListPV:nAt, 3]+"         ",;
                         aColsPV[oListPV:nAt, 4]+"         ",;
                         aColsPV[oListPV:nAt, 5]+"                  ",;
		                 TRANSFORM(aColsPV[oListPV:nAt, 6],"@E 999,999,999.99")}}
   
	
    oListPV:Align := CONTROL_ALIGN_ALLCLIENT

    oListPV:bLDblClick := {|| Processa({|| BuscaPed()},"Buscando pedido " + aColsPV[oListPV:nAt, 2] )}      

    
	oListPV:Refresh(.T.)
	_oTPane3:Refresh()
	oDlg:Refresh()

Return

/*
Rotina: BuscaPed
Descrição: Visualiza Pedido
Autor: Rodrigo Dias Nunes
Data: 20/07/2021
*/
Static Function BuscaPed()
    Local aASC5 := GetArea("SC5")
    Local aASC6 := GetArea("SC6")

    If !Empty(aColsPV)
        If !Empty(aColsPV[oListPV:nAt, 7])
            DbSelectArea("SC5")
            SC5->(dbGoTo(aColsPV[oListPV:nAt, 7]))
            A410Visual("SC5", aColsPV[oListPV:nAt, 7],1)
        EndIf
    EndIf

    RestArea(aASC5)
    RestArea(aASC6)

Return(.T.)

/*
Rotina: BuscaCli
Descrição: Visualiza Cliente
Autor: Rodrigo Dias Nunes
Data: 20/07/2021
*/
Static Function BuscaCli()
    Local aASA1 := GetArea("SA1")

    If !Empty(aColsRK)
        If !Empty(aColsRK[oListRK:nAt, 1]) .AND. !Empty(aColsRK[oListRK:nAt, 4])
            DbSelectArea("SA1")
            If SA1->(dbSeek(xFilial("SA1") + Alltrim(aColsRK[oListRK:nAt, 1]) + (aColsRK[oListRK:nAt, 4])))
                A030Visual("SA1", SA1->(Recno()),1)
            EndIf
        EndIf
    EndIf

    RestArea(aASA1)

Return(.T.)

/*
Rotina: ExtraiRel
Descrição: Extração de Relatorio
Autor: Rodrigo Dias Nunes
Data: 20/07/2021
*/
Static Function ExtraiRel()
    Local oExcel
    Local oFWMsExcel
    local tmp    		:= getTempPath()
    Local aWorkSheet	:= {}
    Local cHora		    := Time()
    Local cNome		    := 'Ranking_Pedidos_'+ DtoS(dDataBase)+ '_' + SubStr(cHora,1,2) + SubStr(cHora,4,2) + '.xls'
    Local cFilePath		:= cGetFile( , 'Selecione a pasta de destino', , tmp, .F., GETF_LOCALHARD+GETF_RETDIRECTORY,.F.)
    Local X             := 1
    Local aLinha        := {}
    Local nlx           := 0
    Local cCor1         := "#FFF5EE" //Seashell
    Local cCor2         := "#FFA500" //Laranja Mais Escuro
    Local cCor          := ""
    Local nCor          := 1

    If !Empty(cFilePath)
        cFilePath := cFilePath + cNome
    else
        Alert("Não foi possivel gravar o arquivo na pasta de destino!!!")
        Return(.T.)
    EndIf

    For nlx := 1 to Len(aColsRK)
        If nCor == 0
            nCor := 1
        ElseIf nCor == 1
            nCor := 0
        EndIf

        cQuery := " SELECT SC9.C9_FILIAL, SC9.C9_PEDIDO, SC9.C9_CLIENTE, SC9.C9_LOJA "
        cQuery += " FROM " + RetSqlName("SC9") + " SC9, "
        cQuery += RetSqlName("SA1") + " SA1, "
        cQuery += RetSqlName("SC5") + " SC5  "
        cQuery += " WHERE "
        cQuery += " SC9.C9_BLCRED<>'  ' AND "
        cQuery += " SC9.C9_BLCRED<>'10' AND "
        cQuery += " SC9.C9_BLCRED<>'ZZ' AND "
        cQuery += " SC9.C9_BLCRED<>'09' AND "
        cQuery += " SC9.D_E_L_E_T_=' ' AND "
        cQuery += " SA1.A1_FILIAL='  ' AND "
        cQuery += " SA1.A1_COD = SC9.C9_CLIENTE AND "
        cQuery += " SA1.A1_LOJA = SC9.C9_LOJA AND "
        cQuery += " SA1.D_E_L_E_T_=' ' AND "
        cQuery += " SC5.C5_FILIAL=SC9.C9_FILIAL AND "
        cQuery += " SC5.C5_NUM=SC9.C9_PEDIDO AND "
        cQuery += " SC5.D_E_L_E_T_=' '  AND "
        cQuery += " SC9.C9_CLIENTE = '"+aColsRK[nlx, 1]+"' "
        cQuery += " GROUP BY  SC9.C9_FILIAL, SC9.C9_PEDIDO, SC9.C9_CLIENTE, SC9.C9_LOJA "
        cQuery += " ORDER BY SC9.C9_PEDIDO "
    
        If Select("RELX") > 0
            RELX->(dbCloseArea())
        EndIf

        DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery) , 'RELX', .T., .F.)

        
        While RELX->(!EOF())
            cQuery := " SELECT C5_FILIAL, C5_NUM, C5_CLIENTE, C5_LOJACLI, C5_CONDPAG, C5_XTOTPV, R_E_C_N_O_ "
            cQuery += " FROM " + RetSqlName("SC5")
            cQuery += " WHERE C5_FILIAL = '"+RELX->C9_FILIAL+"' "
            cQuery += " AND C5_NUM = '"+RELX->C9_PEDIDO+"' "
            cQuery += " AND C5_CLIENTE = '"+RELX->C9_CLIENTE+"' "
            cQuery += " AND C5_LOJACLI = '"+RELX->C9_LOJA+"' "
            cQuery += " AND D_E_L_E_T_ = ' ' " 

            If Select("PXX") > 0
                PXX->(dbCloseArea())
            EndIf

            DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery) , 'PXX', .T., .F.)

            While PXX->(!EOF())
                AADD(aLinha,{Alltrim(PXX->C5_FILIAL),Alltrim(PXX->C5_NUM),Alltrim(PXX->C5_CLIENTE),Alltrim(GetAdvFVal( "SA1","A1_NOME",xFilial("SA1") + PXX->C5_CLIENTE,1 )),Alltrim(PXX->C5_LOJACLI),Alltrim(PXX->C5_CONDPAG),PXX->C5_XTOTPV,nCor})
                PXX->(dbSkip())    
            EndDo
            RELX->(dbSkip())
        EndDo
    Next
    
    oFWMsExcel := FWMSExcelEx():New()

    aAdd(aWorkSheet,"Ranking de Pedidos")
    oFWMsExcel:AddworkSheet( aWorkSheet[x] ) 
    oFWMsExcel:AddTable( aWorkSheet[x], aWorkSheet[x] ) 
    oFWMsExcel:AddColumn(aWorkSheet[x], aWorkSheet[x], "Filial"	    ,1,1,.F.)
    oFWMsExcel:AddColumn(aWorkSheet[x], aWorkSheet[x], "Pedido" 	,1,1,.F.)
    oFWMsExcel:AddColumn(aWorkSheet[x], aWorkSheet[x], "Cliente" 	,1,1,.F.)
    oFWMsExcel:AddColumn(aWorkSheet[x], aWorkSheet[x], "Nome" 	    ,1,1,.F.)
    oFWMsExcel:AddColumn(aWorkSheet[x], aWorkSheet[x], "Loja"       ,1,1,.F.)
    oFWMsExcel:AddColumn(aWorkSheet[x], aWorkSheet[x], "Cond.Pgto." ,1,1,.F.)
    oFWMsExcel:AddColumn(aWorkSheet[x], aWorkSheet[x], "Valor Total",3,3,.F.)

    For nlx := 1 to Len(aLinha)
        If aLinha[nlx][8] == 0
            cCor := cCor1
        ElseIf aLinha[nlx][8] == 1
            cCor := cCor2
        Endif
        
        oFWMsExcel:SetCelBgColor(cCor)
        oFWMsExcel:AddRow(aWorkSheet[X], aWorkSheet[X], {aLinha[nlx][1],aLinha[nlx][2],aLinha[nlx][3],aLinha[nlx][4],aLinha[nlx][5],aLinha[nlx][6],aLinha[nlx][7]},{1,2,3,4,5,6,7} )
        
    Next

    oFWMsExcel:Activate()
    oFWMsExcel:GetXMLFile(cFilePath)
    oExcel := MsExcel():New()
    oExcel:WorkBooks:Open(cFilePath) 
    oExcel:SetVisible(.T.)
    oExcel:Destroy()
    shellExecute( "Open", cFilePath, "", "", 1 )
    msgalert("Planilha Gerada em: "+(cFilePath))  


Return
