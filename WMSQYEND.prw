#include 'protheus.ch'
#include 'parmtype.ch'
/*
+===========================================================================+
|Consultoria:                Q S   d o   B R A S I L                        |
+---------------------------------------------------------------------------+
|Programa   | WMSQYEND	|Autor  | Vitor Lopes        | Data |  09/05/17     |
+---------------------------------------------------------------------------+
|Descricao  | Ponto de entrada para selecionar o armazem de destino.		|
|           | 																|
|           |															    |
+---------------------------------------------------------------------------+
|Uso        | MP11 - Cliente: OuroLux									    |
+---------------------------------------------------------------------------+
|Solicitante| 												       			|
+---------------------------------------------------------------------------+
|Alteracoes | Descrição....:    											|
|           | Solicitante..:    	      									|
|           | Data.........: 			   							        |
|           | Consultor....:											    |
+===========================================================================+
*/ 
*************************
User function WMSQYEND()
*************************
Local aAreaAnt  := GetArea()
Local cProduto  := PARAMIXB[1]
Local cLocDest  := PARAMIXB[2]
Local cEstDest  := PARAMIXB[3]
Local cQuery    := ""
Local cAliasSBE := GetNextAlias()
Local aTamSX3   := TamSx3('BF_QUANT')
Private oArm,oArm1, oBtnOK
Private aOpc  := {'Ambos', 'Armazém 01','Armazém 02'}
Private cConta := aOpc[1]
Private cTela := "Endereçamento" 

	//Para estrutura de Pulmão e Filial Guarulhos.
	If cEstDest == "000003" .And. cFilant == "01"

		 DEFINE MSDIALOG oDlg2 TITLE cTela FROM 0,0 TO 125,250 PIXEL Style DS_MODALFRAME //Tela Principal 
			
			oArm       := TSay():New( 013,030,{||'Local:'},oDlg2,,,,,,.T.,CLR_BLACK,CLR_WHITE,100,20)
			oArm1      := TComboBox():New(010,050,{|u|if(PCount()>0,cConta:=u,cConta)},aOpc,056,20,oDlg2,,{||},,,,.T.,,,,,,,,,'cConta') 
			
			oBtnOK		:= TButton():New( 035 , 030, "&Avançar",oDlg2,{|| oDlg2:End() },76,12,,,.F.,.T.,.F.,,.F.,,,.F. ) 
		
			oDlg2:lEscClose     := .F.				
																				
		ACTIVATE MSDIALOG oDlg2 CENTER 
			
			
		 
		   cQuery := "SELECT"
		    cQuery += " '00' ZON_ORDEM,"
		    cQuery += "  99  SLD_ORDEM,"
		    cQuery += "  99  MOV_ORDEM,"
		    cQuery += "  0   DCP_PEROCP,"
		    
		    //Se foi informado o produto no endereço ele tem prioridade
		    cQuery += " CASE WHEN SBE.BE_CODPRO = '"+Space(TamSx3("BE_CODPRO")[1])+"' THEN 2 ELSE 1 END PRD_ORDEM,"
		    cQuery += " (SELECT SUM(BF_QUANT)"
		    cQuery +=   " FROM "+RetSqlName("SBF")
		    cQuery +=  " WHERE BF_FILIAL  = '"+xFilial("SBF")+"'"
		    cQuery +=    " AND BF_LOCAL   = '"+cLocDest+"'"
		    cQuery +=    " AND BF_ESTFIS  = '"+cEstDest+"'"
		    cQuery +=    " AND BF_PRODUTO = '"+cProduto+"'"
		    cQuery +=    " AND BF_QUANT   > 0"
		    cQuery +=    " AND BF_LOCAL   = SBE.BE_LOCAL"
		    cQuery +=    " AND BF_LOCALIZ = SBE.BE_LOCALIZ"
		    cQuery +=    " AND D_E_L_E_T_ = ' ') SLD_PRODUT, BF_QUANT,"
		        
		    //Pegando as informações do endereço
		    cQuery += " SBE.BE_LOCALIZ, SBE.BE_CODCFG, SBE.R_E_C_N_O_ RECNOSBE"
		    cQuery +=  " FROM "+RetSqlName("SBE")+" SBE"
		    
		    cQuery += " LEFT JOIN "+RetSqlName("SBF")+" BFX ON (BF_FILIAL = BE_FILIAL AND BE_LOCAL = BF_LOCAL "
		    cQuery += " AND BE_LOCALIZ = BF_LOCALIZ AND BFX.D_E_L_E_T_ = '') "
		    
		    //Filtros em cima da SBE - Endereços
		    cQuery += " WHERE SBE.BE_FILIAL  = '"+xFilial("SBE")+"'"
		    cQuery +=   " AND SBE.BE_LOCAL   = '"+cLocDest+"'"
		    cQuery +=   " AND (SBE.BE_CODPRO = ' ' OR SBE.BE_CODPRO = '"+cProduto+"')"
		    cQuery +=   " AND SBE.BE_ESTFIS  = '"+cEstDest+"'"
		    
		    //EStrutura de Pulmão.
		    If cEstDest == "000003"
		    	cQuery += " AND SBE.BE_STATUS = '1' AND BF_QUANT IS NULL "
		    Else
		    	cQuery +=   " AND SBE.BE_STATUS  IN ('1','2') "
		    EndIf
		    
		    cQuery +=   " AND SBE.D_E_L_E_T_ = ' '"
		    If "01" $ cConta
		    	cQuery +=   " AND SUBSTRING(SBE.BE_LOCALIZ,1,2) < '22'  "
		    ElseIf "02" $ cConta
		    	cQuery +=   " AND SUBSTRING(SBE.BE_LOCALIZ,1,2) > '21'  "
		    EndIf
		    
		    cQuery +=   " AND BE_LOCALIZ NOT IN (SELECT DB_ENDDES FROM "+RetSqlName("SDB")+" SDB "
			cQuery +=   "		WHERE SDB.DB_FILIAL  = '"+xFilial("SDB")+"'"
			cQuery +=   "		AND SDB.DB_ESTORNO = ' '"
			cQuery +=   "		AND SDB.DB_ATUEST  = 'N'"
			cQuery +=   "		AND SDB.DB_LOCAL   = BE_LOCAL"
			cQuery +=   "		AND SDB.DB_ENDDES  = BE_LOCALIZ"
			cQuery +=   "		AND SDB.DB_ESTDES  = BE_ESTFIS"
			cQuery +=   "		AND SDB.DB_STATUS IN ('-','2','3','4')"
			cQuery +=   "		AND SDB.D_E_L_E_T_ = ' ')"         
		    
		    //Gerando a ordenação dos endereços    
		    cQuery += " ORDER BY ZON_ORDEM, PRD_ORDEM, SLD_ORDEM, MOV_ORDEM, BE_LOCALIZ"
		    cQuery := ChangeQuery(cQuery)
		    DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasSBE,.F.,.T.)
		    
		    //-- Ajustando o tamanho dos campos da query
		    TcSetField(cAliasSBE,'PRD_ORDEM','N',5,0)
		    TcSetField(cAliasSBE,'SLD_ORDEM','N',5,0)
		    TcSetField(cAliasSBE,'MOV_ORDEM','N',5,0)
		    TcSetField(cAliasSBE,'DCP_PEROCP','N',5,0)
		    TcSetField(cAliasSBE,'SLD_PRODUT','N',aTamSX3[1],aTamSX3[2])
		    
	Else
			cAliasSBE := Nil
    EndIf
RestArea(aAreaAnt)
Return cAliasSBE