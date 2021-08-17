#Include "PROTHEUS.CH"
#Include "TOPCONN.Ch"


#DEFINE COMP_DATE "20191209"

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} OUROR016
Relatorio  

@type 		function
@author 	Roberto Souza
@since 		12/03/2017
@version 	P11 
 
@return nil
/*/    
//-------------------------------------------------------------------------------------
User Function OUROR016()

	Local oReport
	
	Private cSubDir1 := "\INTRJ\"
	Private cLogDir  := cSubDir1 //StrTran(cRootPath+ cSubDir1  ,"\\","\")            
	Private cFileLog := cLogDir  +"s_OUROR016_"+Dtos(dDataBase)+".log"
	Private lGeraLog := .T.
	Private cNomRel  := "NF-e x Transportadora x CT-e : "+COMP_DATE
	Private nDecPC   := 4 // Casas decimais percentual        
	
	MemoWrite(cFileLog,"LOG - "+cNomRel )
	PutLog( Time()+" Inicio." )
	
//	If TRepInUse()
		//-- Interface de impressao
		oReport := ReportDef()
		oReport:PrintDialog()
//	EndIf
	
	PutLog( Time()+" Fim." )
			
Return


//-------------------------------------------------------------------------------------
/*/{Protheus.doc} ReportDef
Definições da estrutura do Relatorio.

@type 		function
@author 	Roberto Souza
@since 		12/03/2017
@version 	P11 
 
@return nil
/*/    
//-------------------------------------------------------------------------------------
Static Function ReportDef()

Local Nx 		:= 0
Local nFiltro   := 0
Private cPerg    := PADR("OUROR016",10)
Private cGerente := ""
Private cSupervi := ""
Private cFilVen  := ""
 
Private cVend    := ""
Private cNoVend  := ""
Private cCliente := ""
Private cNomCli  := ""
Private cPerio1  := 0
Private cPerio2  := 0
Private cPerio3  := 0
Private cPerio4  := 0
Private cPerio5  := 0
Private cPerio6  := 0
Private cMedia   := 0
Private aFiltro  := {} 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Criacao do componente de impressao                                      ³
//³                                                                        ³
//³TReport():New                                                           ³
//³ExpC1 : Nome do relatorio                                               ³
//³ExpC2 : Titulo                                                          ³
//³ExpC3 : Pergunte                                                        ³
//³ExpB4 : Bloco de codigo que sera executado na confirmacao da impressao  ³
//³ExpC5 : Descricao                                                       ³
//³                                                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
PutLog( Time()+" Inicio ReportPrint." )
oReport := TReport():New(cPerg,cNomRel+" - 20/07/2017-001",cPerg, {|oReport| ReportPrint(oReport)},cNomRel)
oReport:SetLandscape(.T.)
oSection1 := TRSection():New(oReport,OemToAnsi(cNomRel),)

//ÚÄÄÄÄÄÄÄÄÄ¿
//³Perguntas³
//ÀÄÄÄÄÄÄÄÄÄÙ
AjustaSx1()
Pergunte(oReport:uParam,.T.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Estrutura          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
TRCell():New(oSection1,"FILIAL" 		,/*Tabela*/,"Filial"				,"@!"								,20	,/*lPixel*/,{|| })
TRCell():New(oSection1,"DACTE" 			,/*Tabela*/,"DACT-e"				,"@!"								,20	,/*lPixel*/,{|| })
TRCell():New(oSection1,"DT_EMISSAO"		,/*Tabela*/,"DT de missao"			,"@D"								,20	,/*lPixel*/,{|| })
TRCell():New(oSection1,"DT_ENTRADA"		,/*Tabela*/,"DT de entrada"			,"@D"								,20	,/*lPixel*/,{|| })
TRCell():New(oSection1,"FAT_TRANSP"		,/*Tabela*/,"Fatura Transportadora"	,"@!"								,20	,/*lPixel*/,{|| })
TRCell():New(oSection1,"NFISCAL"		,/*Tabela*/,"NF Ourolux"			,"@!"								,20	,/*lPixel*/,{|| })
TRCell():New(oSection1,"EMISSAO"		,/*Tabela*/,"Emissão NF"			,"@D"								,20	,/*lPixel*/,{|| })
TRCell():New(oSection1,"TRANSPORTADORA"	,/*Tabela*/,"Transportador"			,"@!"								,20	,/*lPixel*/,{|| })
TRCell():New(oSection1,"NOM_TRANSP"		,/*Tabela*/,"Nome do transportador"	,"@!"								,20	,/*lPixel*/,{|| })
TRCell():New(oSection1,"CFOP"			,/*Tabela*/,"CFOP"					,"@!"								,20	,/*lPixel*/,{|| })
TRCell():New(oSection1,"CLIENTE"		,/*Tabela*/,"Cliente"				,"@!"								,20	,/*lPixel*/,{|| })
TRCell():New(oSection1,"NOM_CLI"		,/*Tabela*/,"Nome do cliente"		,"@!"								,20	,/*lPixel*/,{|| })
TRCell():New(oSection1,"CIDADE"			,/*Tabela*/,"Cidade"				,"@!"								,20	,/*lPixel*/,{|| })
TRCell():New(oSection1,"REGIAO"			,/*Tabela*/,"Região"				,"@!"								,20	,/*lPixel*/,{|| })
TRCell():New(oSection1,"UF"				,/*Tabela*/,"UF"					,"@!"								,20	,/*lPixel*/,{|| })
TRCell():New(oSection1,"VALOR_CARGA"	,/*Tabela*/,"Valor da carga"		,"@E 999,999,999,999.99"			,20	,/*lPixel*/,{|| })
TRCell():New(oSection1,"FRETE_CALC"		,/*Tabela*/,"Frete Calculado"		,"@E 999,999,999,999.99"			,20	,/*lPixel*/,{|| })
TRCell():New(oSection1,"FRETE_PAGO"		,/*Tabela*/,"Frete Pago"			,"@E 999,999,999,999.99"			,20	,/*lPixel*/,{|| })
TRCell():New(oSection1,"PERC_CALC"		,/*Tabela*/,"% FTR Cal x Merc"		,"@E 999."+Replicate("9",nDecPC)	,20	,/*lPixel*/,{|| })
TRCell():New(oSection1,"PERC_PAGO"		,/*Tabela*/,"% FTR pago x Merc"		,"@E 999."+Replicate("9",nDecPC)	,20	,/*lPixel*/,{|| })

Return oReport

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} ReportPrint
Montagem da massa de dados do Relatorio.

@type 		function
@author 	Roberto Souza
@since 		12/03/2017
@version 	P11 
 
@return nil
/*/    
//-------------------------------------------------------------------------------------
Static Function ReportPrint(oReport)

Local oSection1 := oReport:Section(1)       
Local nFator    := 0
Local nAux      := 0
Local cQuery 	:= ""
Local lAglutina := .T.

Private aDados  := {}  
Private nPer    := 6

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicia SECAO 1  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oSection1:Init()    
oReport:SetMeter(-1)
oReport:IncMeter()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Cria filtro no relatório    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cAliasGW1 := GetNextAlias()       

cQuery += " 	SELECT DISTINCT GW1_FILIAL, A1_COD, A1_LOJA, A1_NOME, A1_MUN, A1_EST, GW1_NRDC, GW1_SERDC, GW1_DTEMIS, GWM_FILIAL, GWM_DTEMIS ,GWM_SERDOC , GWM_NRDOC, GWM_SERDC , GWM_NRDC, GWM_VLFRET,GWM_VLFRE1, GWM_PCRAT,"
cQuery += " 	GWU_CDTRP , GWM_TPDOC,GWM_CDESP, GWM_SEQGW8, F2_EMISSAO, F2_VALBRUT, D2_CF,A4_COD, A4_NOME,"
cQuery += " 	GW3_SERFAT, GW3_NRFAT, GWG_CDEMIT, GWG_NRTAB, GWG_NRNEG, GWG_NRROTA "
//cQuery += " 	GW3_DTENT, GW3_DTEMIS " +CRLF
cQuery += " 	FROM "+RetSQLName("GW1")+" GW1  " +CRLF
cQuery += " 		INNER JOIN "+RetSQLName("GWM")+" GWM ON GWM_FILIAL = GW1_FILIAL AND GWM_SERDC = GW1_SERDC AND GWM_NRDC = GW1_NRDC AND GWM.D_E_L_E_T_ = ' '" +CRLF
cQuery += " 		INNER JOIN "+RetSQLName("GWU")+" GWU ON GWU_FILIAL = GW1_FILIAL " +CRLF
cQuery += "						  	 AND GWU_CDTPDC = GW1_CDTPDC " +CRLF
cQuery += "						  	 AND GWU_EMISDC = GW1_EMISDC " +CRLF
cQuery += "						  	 AND GWU_SERDC = GW1_SERDC   " +CRLF
cQuery += "						  	 AND GWU_NRDC = GW1_NRDC     " +CRLF
cQuery += "					     	 AND GWU.D_E_L_E_T_ = ' '    " +CRLF
cQuery += " 		INNER JOIN "+RetSQLName("SA4")+" SA4 ON A4_CGC = GWU_CDTRP  AND SA4.D_E_L_E_T_ = ' '" +CRLF
cQuery += " 		INNER JOIN "+RetSQLName("SF2")+" SF2 ON F2_SERIE = GWM_SERDC AND GWM_NRDC = F2_DOC AND SF2.D_E_L_E_T_ = ' '"	 +CRLF
cQuery += " 		INNER JOIN "+RetSQLName("SD2")+" SD2 ON D2_SERIE = GWM_SERDC AND GWM_NRDC = D2_DOC AND GWM_SEQGW8 = D2_ITEM AND SD2.D_E_L_E_T_ = ' '"	 +CRLF
cQuery += " 		INNER JOIN "+RetSQLName("SA1")+" SA1 ON A1_CGC = GW1_CDDEST AND A1_COD = F2_CLIENTE AND A1_LOJA=F2_LOJA AND SA1.D_E_L_E_T_ = ' '" +CRLF
cQuery += " 		INNER JOIN "+RetSQLName("GW4")+"  GW4 ON GW4_FILIAL = GW1_FILIAL  AND GW4_EMISDC = GW1_EMISDC AND GW4_SERDC = GW1_SERDC " +CRLF
cQuery += "   			AND GW4_NRDC = GW1_NRDC AND GW4_TPDC = GW1_CDTPDC AND GW4_EMISDF = A4_CGC AND GW4.D_E_L_E_T_ = ' '  " +CRLF
cQuery += " 		INNER JOIN "+RetSQLName("GW3")+" GW3 ON GW3_FILIAL = GW1_FILIAL AND GW3_CDESP = GW4_CDESP AND GW3_EMISDF =  GW4_EMISDF AND GW3_SERDF = GW4_SERDF " +CRLF
cQuery += " 			AND GW3_NRDF= GW4_NRDF AND GW3_EMISDF = A4_CGC AND GW3_DTEMIS = GW4_DTEMIS AND GW3_NRFAT <> '' AND GW3.D_E_L_E_T_ = ' '  " +CRLF
cQuery += " 		INNER JOIN "+RetSQLName("GWF")+" GWF ON GWF_FILIAL = GW1_FILIAL AND GWF_NRROM = GW1.GW1_NRROM AND GWF_EMIDES = GW1.GW1_CDDEST AND GWF_TRANSP = A4_CGC " +CRLF
cQuery += "     		AND GWF.D_E_L_E_T_ = ' ' " +CRLF
cQuery += " 		INNER JOIN "+RetSQLName("GWG")+" GWG ON GWF_FILIAL = GWG_FILIAL AND GWF_NRCALC = GWG_NRCALC " +CRLF
cQuery += "     		AND GWG.D_E_L_E_T_ = ' ' " +CRLF
cQuery += " 	WHERE "      
cQuery += " 	GW1.GW1_FILIAL  	BETWEEN '" + MV_PAR01      		+ "' AND '" + MV_PAR02       + "'" +CRLF
cQuery += " 	AND SF2.F2_EMISSAO  BETWEEN '" + DTOS(MV_PAR03)     + "' AND '" + DTOS(MV_PAR04) + "'" +CRLF
cQuery += "  	AND A4_COD			BETWEEN '" + MV_PAR05      		+ "' AND '" + MV_PAR06 + "'" +CRLF
cQuery += "  	AND A1_EST 			BETWEEN '" + MV_PAR15	  		+ "' AND '" + MV_PAR16 + "'" +CRLF
cQuery += "  	AND A1_COD 			BETWEEN '" + MV_PAR07  	  		+ "' AND '" + MV_PAR09 + "'" +CRLF
cQuery += "  	AND A1_LOJA			BETWEEN '" + MV_PAR08  	  		+ "' AND '" + MV_PAR10 + "'" +CRLF
cQuery += "  	AND GW1_SERDC		BETWEEN '" + MV_PAR11  	  		+ "' AND '" + MV_PAR13 + "'" +CRLF
cQuery += "  	AND GW1_NRDC		BETWEEN '" + MV_PAR12  	  		+ "' AND '" + MV_PAR14 + "'" +CRLF
cQuery += "		AND GW1.D_E_L_E_T_ = ' '  " +CRLF
cQuery += "		ORDER BY GW1_FILIAL, GW1_NRDC, GW1_SERDC,GW3_NRFAT,GWM_TPDOC, GWM_SEQGW8"

PutLog( "[QUERY]" + CRLF + cQuery )
	Aviso("[QUERY]",cQuery,{"Ok"},3)
dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasGW1, .F., .T.)
 
DbSelectArea(cAliasGW1)
                 
nRecs := (cAliasGW1)->(LastRec())

oReport:SetMeter(nRecs)
  
If lAglutina 

	While (cAliasGW1)->(!Eof())
		
		cTipoDoc := (cAliasGW1)->GWM_TPDOC  
		cDoc     := (cAliasGW1)->GW1_SERDC+"/"+(cAliasGW1)->GW1_NRDC 
		
		cFRETE_CALC := 0
		cFRETE_PAGO := 0 
		cPERC_CALC 	:= 0
		cPERC_PAGO 	:= 0 
		cVALOR_CARGA:= 0
		
		aDoc := {}

		cRota := GFEAINFROT((cAliasGW1)->GWG_CDEMIT,(cAliasGW1)->GWG_NRTAB,(cAliasGW1)->GWG_NRNEG,(cAliasGW1)->GWG_NRROTA)    

		cDocRat := IsRedesp((cAliasGW1)->GWM_FILIAL, (cAliasGW1)->GWM_SERDC, (cAliasGW1)->GWM_NRDC)
								
		While (cAliasGW1)->(!Eof())	.And. cDoc == (cAliasGW1)->GW1_SERDC+"/"+(cAliasGW1)->GW1_NRDC 
			oReport:IncMeter()

			cFILIAL := (cAliasGW1)->GW1_FILIAL 

			cDACTE 		:= (cAliasGW1)->GWM_SERDC +"/"+(cAliasGW1)->GWM_NRDOC 
			cDT_EMISSAO := STod((cAliasGW1)->GWM_DTEMIS) //STod((cAliasGW1)->GW3_DTEMIS)
			cDT_ENTRADA := STod((cAliasGW1)->GWM_DTEMIS) //STod((cAliasGW1)->GW3_DTENT) 

			cFAT_TRANSP := (cAliasGW1)->GW3_SERFAT +"/"+(cAliasGW1)->GW3_NRFAT 
	
			cRota := GFEAINFROT((cAliasGW1)->GWG_CDEMIT,(cAliasGW1)->GWG_NRTAB,(cAliasGW1)->GWG_NRNEG,(cAliasGW1)->GWG_NRROTA)    
	
			cNFISCAL 		:= (cAliasGW1)->GW1_SERDC+"/"+(cAliasGW1)->GW1_NRDC 
			cEMISSAO 		:= Stod((cAliasGW1)->F2_EMISSAO) 
			cTRANSPORTADORA := (cAliasGW1)->A4_COD 
			cNOM_TRANSP		:= (cAliasGW1)->A4_NOME 
			cCFOP 			:= (cAliasGW1)->D2_CF
			cCLIENTE 		:= (cAliasGW1)->A1_COD+"-"+(cAliasGW1)->A1_LOJA 
			cNOM_CLI 		:= (cAliasGW1)->A1_NOME 
			cCIDADE 		:= (cAliasGW1)->A1_MUN 
			cREGIAO 		:= cRota 
			cUF 			:= (cAliasGW1)->A1_EST 
			cVALOR_CARGA 	:= (cAliasGW1)->F2_VALBRUT
		    

			
			If (cAliasGW1)->GWM_TPDOC == "1"    
			    // WorkAround para verificar se existe redespacho
				If AllTrim(cDocRat)  == AllTrim((cAliasGW1)->GWM_NRDOC)
					cFRETE_CALC += (cAliasGW1)->GWM_VLFRET//(cAliasGW1)->GWM_VLFRE1 
					cFRETE_PAGO +=  0 
					cPERC_CALC 	:= (cAliasGW1)->GWM_PCRAT 
					cPERC_PAGO 	+=  0 
		    	EndIf
		    Else
				cFRETE_CALC += 0 
				cFRETE_PAGO += (cAliasGW1)->GWM_VLFRET 
				cPERC_CALC 	+= 0 
				cPERC_PAGO 	:= (cAliasGW1)->GWM_PCRAT 
		    EndIf      
		
			oSection1:Cell("FILIAL"):SetValue( (cAliasGW1)->GW1_FILIAL )
			If Alltrim((cAliasGW1)->GWM_CDESP)  == "CTE"
				oSection1:Cell("DACTE"):SetValue( (cAliasGW1)->GWM_SERDC +"/"+(cAliasGW1)->GWM_NRDOC ) 
				oSection1:Cell("DT_EMISSAO"):SetValue( cDT_EMISSAO )
				oSection1:Cell("DT_ENTRADA"):SetValue( cDT_ENTRADA )
				oSection1:Cell("FAT_TRANSP"):SetValue( (cAliasGW1)->GW3_SERFAT +"/"+(cAliasGW1)->GW3_NRFAT )
			Else
				oSection1:Cell("DACTE"):SetValue( "" )	
				oSection1:Cell("DT_EMISSAO"):SetValue( Stod("") )
				oSection1:Cell("DT_ENTRADA"):SetValue( Stod("") )
				oSection1:Cell("FAT_TRANSP"):SetValue( "" )
			EndIf
		
			oSection1:Cell("NFISCAL"):SetValue( (cAliasGW1)->GW1_SERDC+"/"+(cAliasGW1)->GW1_NRDC )
			oSection1:Cell("EMISSAO"):SetValue( Stod((cAliasGW1)->F2_EMISSAO) )
			oSection1:Cell("TRANSPORTADORA"):SetValue( (cAliasGW1)->A4_COD )
			oSection1:Cell("NOM_TRANSP"):SetValue( (cAliasGW1)->A4_NOME )
			oSection1:Cell("CFOP"):SetValue( (cAliasGW1)->D2_CF)
			oSection1:Cell("CLIENTE"):SetValue( (cAliasGW1)->A1_COD+"-"+(cAliasGW1)->A1_LOJA )
			oSection1:Cell("NOM_CLI"):SetValue( (cAliasGW1)->A1_NOME )
			oSection1:Cell("CIDADE"):SetValue( (cAliasGW1)->A1_MUN )
			oSection1:Cell("REGIAO"):SetValue( cRota )
			oSection1:Cell("UF"):SetValue( (cAliasGW1)->A1_EST )

			(cAliasGW1)->(DbSkip())
		
		EndDo 
		
		cPERC_CALC := cFRETE_CALC / cVALOR_CARGA * 100 
		cPERC_PAGO := cFRETE_PAGO / cVALOR_CARGA * 100 
		
		oSection1:Cell("VALOR_CARGA"):SetValue( cVALOR_CARGA )             
		oSection1:Cell("FRETE_CALC"):SetValue( cFRETE_CALC )
		oSection1:Cell("FRETE_PAGO"):SetValue( cFRETE_PAGO  )
		oSection1:Cell("PERC_CALC"):SetValue( Round(cPERC_CALC,nDecPC) )
		oSection1:Cell("PERC_PAGO"):SetValue( Round(cPERC_PAGO,nDecPC) )
				
		oSection1:PrintLine()

	EndDo


Else
	
	While (cAliasGW1)->(!Eof())
	
		oReport:IncMeter()
	
		oSection1:Cell("FILIAL"):SetValue( (cAliasGW1)->GW1_FILIAL )
		If Alltrim((cAliasGW1)->GWM_CDESP)  == "CTE"
			oSection1:Cell("DACTE"):SetValue( (cAliasGW1)->GWM_SERDC +"/"+(cAliasGW1)->GWM_NRDOC )
			oSection1:Cell("DT_ENTRADA"):SetValue( STod((cAliasGW1)->GWM_DTEMIS) )
			oSection1:Cell("FAT_TRANSP"):SetValue( (cAliasGW1)->GW3_SERFAT +"/"+(cAliasGW1)->GW3_NRFAT )
		Else
			oSection1:Cell("DACTE"):SetValue( "" )	
			oSection1:Cell("DT_ENTRADA"):SetValue( Stod("") )
			oSection1:Cell("FAT_TRANSP"):SetValue( "" )
		EndIf
	
		cRota := GFEAINFROT((cAliasGW1)->GWG_CDEMIT,(cAliasGW1)->GWG_NRTAB,(cAliasGW1)->GWG_NRNEG,(cAliasGW1)->GWG_NRROTA)    
	
		oSection1:Cell("NFISCAL"):SetValue( (cAliasGW1)->GW1_SERDC+"/"+(cAliasGW1)->GW1_NRDC )
		oSection1:Cell("EMISSAO"):SetValue( Stod((cAliasGW1)->F2_EMISSAO) )
		oSection1:Cell("TRANSPORTADORA"):SetValue( (cAliasGW1)->A4_COD )
		oSection1:Cell("NOM_TRANSP"):SetValue( (cAliasGW1)->A4_NOME )
		oSection1:Cell("CFOP"):SetValue( (cAliasGW1)->D2_CF)
		oSection1:Cell("CLIENTE"):SetValue( (cAliasGW1)->A1_COD+"-"+(cAliasGW1)->A1_LOJA )
		oSection1:Cell("NOM_CLI"):SetValue( (cAliasGW1)->A1_NOME )
		oSection1:Cell("CIDADE"):SetValue( (cAliasGW1)->A1_MUN )
		oSection1:Cell("REGIAO"):SetValue( cRota )
		oSection1:Cell("UF"):SetValue( (cAliasGW1)->A1_EST )
		oSection1:Cell("VALOR_CARGA"):SetValue( (cAliasGW1)->D2_TOTAL )             
	
		If (cAliasGW1)->GWM_TPDOC == "1" 
			oSection1:Cell("FRETE_CALC"):SetValue( (cAliasGW1)->GWM_VLFRE1 )
			oSection1:Cell("FRETE_PAGO"):SetValue( 0 )
			oSection1:Cell("PERC_CALC"):SetValue( (cAliasGW1)->GWM_PCRAT )
			oSection1:Cell("PERC_PAGO"):SetValue( 0 )
	    Else
			oSection1:Cell("FRETE_CALC"):SetValue( 0 )
			oSection1:Cell("FRETE_PAGO"):SetValue( (cAliasGW1)->GWM_VLFRET )
			oSection1:Cell("PERC_CALC"):SetValue( 0 )
			oSection1:Cell("PERC_PAGO"):SetValue( (cAliasGW1)->GWM_PCRAT )
	    EndIf      
	                                        
		oSection1:PrintLine()
			
		(cAliasGW1)->(DbSkip())
	EndDo
EndIf

PutLog( Time()+" Fim da geração do arquivo final." )

oSection1:Finish()

Return
    


Static Function IsRedesp( cFil , cSerDC, cNrDc)
	Local cRet := ""	
	Local cGWM := GetNextAlias()
	Local cGW3 := GetNextAlias()

	BeginSql ALIAS cGWM

		SELECT MAX(GWM_NRDOC) GWM_NRDOC FROM %Table:GWM% 
			WHERE GWM_SERDC =%Exp:cSerDc% 
			AND GWM_NRDC=%Exp:cNrDc% 
			AND GWM_TPDOC = "1"  
			AND %notdel% 
    EndSql

	If (cGWM)->(!Eof())
		cRet := (cGWM)->GWM_NRDOC
	EndIf
	(cGWM)->(DbCloseArea())

Return( cRet )




//-------------------------------------------------------------------------------------
/*/{Protheus.doc} AjustaSx1
Montagem da massa de dados do Relatorio.

@type 		function
@author 	Roberto Souza
@since 		12/03/2017
@version 	P11 
 
@return nil
/*/    
//-------------------------------------------------------------------------------------

Static Function AjustaSx1()

Local aArea := GetArea()
Local aHelp	:= {}

PutSx1(cPerg,"01","Filial de"			,"","","mv_ch1","C",2	,00,0,"G","","SM0"	,"","","mv_par01","","","","","", "","","","","","","","","","","",aHelp,aHelp,aHelp)
PutSx1(cPerg,"02","Até Filial"			,"","","mv_ch2","C",2	,00,0,"G","","SM0"	,"","","mv_par02","","","","","", "","","","","","","","","","","",aHelp,aHelp,aHelp)
PutSx1(cPerg,"03","Emissão de" 			,"","","mv_ch3","D",8	,00,0,"G","",""		,"","","mv_par03","","","","","", "","","","","","","","","","","",aHelp,aHelp,aHelp)
PutSx1(cPerg,"04","Até Emissão"			,"","","mv_ch4","D",8	,00,0,"G","",""		,"","","mv_par04","","","","","", "","","","","","","","","","","",aHelp,aHelp,aHelp)
PutSx1(cPerg,"05","Transportadora de"	,"","","mv_ch5","C",6	,00,0,"G","","SA3"	,"","","mv_par05","","","","","", "","","","","","","","","","","",aHelp,aHelp,aHelp)
PutSx1(cPerg,"06","Até Transportadora"	,"","","mv_ch6","C",6	,00,0,"G","","SA3"	,"","","mv_par06","","","","","", "","","","","","","","","","","",aHelp,aHelp,aHelp)
PutSx1(cPerg,"07","Cliente de"			,"","","mv_ch7","C",6	,00,0,"G","","SA1"	,"","","mv_par07","","","","","", "","","","","","","","","","","",aHelp,aHelp,aHelp)
PutSx1(cPerg,"08","Loja de"				,"","","mv_ch8","C",2	,00,0,"G","",""		,"","","mv_par08","","","","","", "","","","","","","","","","","",aHelp,aHelp,aHelp)
PutSx1(cPerg,"09","Até Cliente"			,"","","mv_ch9","C",6	,00,0,"G","","SA1"	,"","","mv_par09","","","","","", "","","","","","","","","","","",aHelp,aHelp,aHelp)
PutSx1(cPerg,"10","Até Loja"			,"","","mv_cha","C",2	,00,0,"G","",""		,"","","mv_par10","","","","","", "","","","","","","","","","","",aHelp,aHelp,aHelp)
PutSx1(cPerg,"11","Serie de"			,"","","mv_chb","C",3	,00,0,"G","",""		,"","","mv_par11","","","","","", "","","","","","","","","","","",aHelp,aHelp,aHelp)
PutSx1(cPerg,"12","Nota Fiscal de"		,"","","mv_chc","C",9	,00,0,"G","",""		,"","","mv_par12","","","","","", "","","","","","","","","","","",aHelp,aHelp,aHelp)
PutSx1(cPerg,"13","Até Serie"			,"","","mv_chd","C",3	,00,0,"G","",""		,"","","mv_par13","","","","","", "","","","","","","","","","","",aHelp,aHelp,aHelp)
PutSx1(cPerg,"14","Até Nota Fiscal"		,"","","mv_che","C",9	,00,0,"G","",""		,"","","mv_par14","","","","","", "","","","","","","","","","","",aHelp,aHelp,aHelp)
PutSx1(cPerg,"15","De Estado"			,"","","mv_chf","C",2	,00,0,"G","",""		,"","","mv_par15","","","","","", "","","","","","","","","","","",aHelp,aHelp,aHelp)
PutSx1(cPerg,"16","Até Estado"			,"","","mv_chg","C",2	,00,0,"G","",""		,"","","mv_par16","","","","","", "","","","","","","","","","","",aHelp,aHelp,aHelp)


RestArea(aArea)

Return                               


//-------------------------------------------------------------------------------------
/*/{Protheus.doc} PutLog
Geracao de log

@type 		function
@author 	Roberto Souza
@since 		12/01/2017
@version 	P11 
 
@return nil
/*/    
//-------------------------------------------------------------------------------------
Static Function PutLog( cMsg )
	Local cLogx := ""
	If lGeraLog
		cLogx := Memoread(cFileLog)	
		MemoWrite(cFileLog,cLogx + CRLF + cMsg )
    EndIf
Return

