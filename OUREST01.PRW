#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

/*--------------------------------------------------------|
| Autor | Claudino Domingues              | Data 20/04/15 | 
|---------------------------------------------------------|
| Função: OUREST01                                          |
|---------------------------------------------------------|
| Relatório de Transferencia Modelo 2.                    |
----------------------------------------------------------*/

User Function OUREST01()

	Local oReport
	
	If TRepInUse()	
		oReport := ReportDef()
		/*------------------------------------
		| Imprime os dados na Tela(Preview). |
		-------------------------------------*/
		oReport:PrintDialog()
	EndIf
	
Return

/*--------------------------------------------------------|
| Autor | Claudino Domingues              | Data 20/04/15 | 
|---------------------------------------------------------|
| Função: ReportDef                                       |
|---------------------------------------------------------|
| Montagem do Objetos do TREPORT.                         |
----------------------------------------------------------*/


Static Function ReportDef()
    
	Private cPerg  := PADR("OUREST01",10) 
	
	/*---------------------------------------------------------------------|
	| Apresenta a tela de impressão para o usuario configurar o relatorio. |
	----------------------------------------------------------------------*/
	oReport:=TReport():New(cPerg,"Relatório de Transferencia Modelo 2",cPerg,{|oReport| PrintReport(oReport)},"Relatório de Transferencia Modelo 2")
	oReport:SetLandscape(.T.)    
	oSection:=TRSection():New(oReport,"Relatório de Transferencia Modelo 2",{""})
    
	/*-----------
	| Pergunte. |
	-----------*/
	AjustaSX1() 
	Pergunte(oReport:uParam,.T.)
	
	TRCell():New(oSection,"FILMOV"		,/*cAlias*/,"Filial"	    ,PesqPict("SD3","D3_FILIAL")	,TamSX3("D3_FILIAL")[1]		,/*lPixel*/ ,/*{|| code-black de impressão}*/ , , ,"LEFT")
  	TRCell():New(oSection,"CODPROD"		,/*cAlias*/,"Cod.Produto"	,PesqPict("SB1","B1_COD")		,TamSX3("B1_COD")[1]		,/*lPixel*/ ,/*{|| code-black de impressão}*/ , , ,"LEFT")
	TRCell():New(oSection,"DESCPROD"	,/*cAlias*/,"Descr.Produto"	,PesqPict("SB1","B1_DESC") 	    ,TamSX3("B1_DESC")[1]		,/*lPixel*/ ,/*{|| code-black de impressão}*/ , , ,"LEFT")
	TRCell():New(oSection,"QUANTMOV"	,/*cAlias*/,"Quant.Mov"		,PesqPict("SD3","D3_QUANT")    	,TamSX3("D3_QUANT")[1]		,/*lPixel*/ ,/*{|| code-black de impressão}*/ , , ,"LEFT")
	TRCell():New(oSection,"DOCMOV"		,/*cAlias*/,"Documento"		,PesqPict("SD3","D3_DOC")    	,TamSX3("D3_DOC")[1]		,/*lPixel*/ ,/*{|| code-black de impressão}*/ , , ,"LEFT")
	TRCell():New(oSection,"ARMORI"		,/*cAlias*/,"Arm de Origem"	,PesqPict("SD3","D3_LOCAL")  	,TamSX3("D3_LOCAL")[1]		,/*lPixel*/ ,/*{|| code-black de impressão}*/ , , ,"LEFT")
	TRCell():New(oSection,"ARMDEST"		,/*cAlias*/,"Arm de Destino",PesqPict("SD3","D3_LOCAL")		,TamSX3("D3_LOCAL")[1]		,/*lPixel*/ ,/*{|| code-black de impressão}*/ , , ,"LEFT")
	TRCell():New(oSection,"DTMOV"		,/*cAlias*/,"Dt.Mov"		,PesqPict("SD3","D3_EMISSAO")	,10 	                    ,/*lPixel*/ ,/*{|| code-black de impressão}*/ , , ,"LEFT")
	TRCell():New(oSection,"USUMOV"		,/*cAlias*/,"Usuario.Resp"	,"@!"                           ,40   	                    ,/*lPixel*/ ,/*{|| code-black de impressão}*/ , , ,"LEFT")
		                                 
Return oReport

/*--------------------------------------------------------|
| Autor | Claudino Domingues              | Data 20/04/15 | 
|---------------------------------------------------------|
| Função: PrintReport                                     |
|---------------------------------------------------------|
| Montagem do Objetos do TREPORT.                         |
| oReport - Objeto Principal do TREPORT.                  |
| Monta Query de acordo com o filtro informado.           |
----------------------------------------------------------*/

Static Function PrintReport(oReport)
    
	Local oSection := oReport:Section(1)   

	Local _nQuant  := 0 
	Local _cQuery  := ""
	Local _aAllUsr := AllUsers()

	
    /*    
	SELECT 
		GERAL.FILIAL, 
		GERAL.DOC, 
		GERAL.PRODUTO, 
		GERAL.QUANTMOV,  
		GERAL.DATAMOV, 
		GERAL.USUARIO, 
		GERAL.NUMSEQ, 
		GERAL.ARMSAI, 
		GERAL.ARMENT
	FROM 	
		(SELECT 
			SD3.D3_FILIAL FILIAL,
   			SD3.D3_DOC DOC,
	     	SD3.D3_COD PRODUTO, 
	      	SD3.D3_QUANT QUANTMOV, 
	       	SD3.D3_EMISSAO DATAMOV, 
	        SD3.D3_USUARIO USUARIO,
	        SD3.D3_NUMSEQ NUMSEQ,
	        MAX(CASE WHEN SD3.D3_TM = '999' THEN SD3.D3_LOCAL END) ARMSAI,
	        MAX(CASE WHEN SD3.D3_TM = '499' THEN SD3.D3_LOCAL END) ARMENT
		FROM 
			SD3010 SD3
		WHERE 
			SD3.D_E_L_E_T_ = ' '
			AND SD3.D3_FILIAL BETWEEN '01' AND '01'
			AND SD3.D3_ESTORNO <> 'S'
			AND SD3.D3_TM IN ('499','999')
			AND SD3.D3_CF IN ('DE4','RE4')
			AND SD3.D3_EMISSAO BETWEEN '20150310' AND '20150312'
   			AND SD3.D3_COD BETWEEN ' ' AND 'ZZZZ'
		GROUP BY 
			SD3.D3_FILIAL, 
			SD3.D3_DOC, 
			SD3.D3_COD, 
			SD3.D3_QUANT, 
			SD3.D3_EMISSAO, 
			SD3.D3_USUARIO, 
			SD3.D3_NUMSEQ) GERAL
		WHERE 
			GERAL.ARMSAI = '01' 
			AND GERAL.ARMENT = '70'
		ORDER BY 
			GERAL.PRODUTO, 
			GERAL.DATAMOV  
    */
    
	_cQuery := " SELECT "
	_cQuery += "		GERAL.FILIAL, "
	_cQuery += "		GERAL.DOC, " 
	_cQuery += "		GERAL.PRODUTO, " 
	_cQuery += "		GERAL.QUANTMOV, "  
	_cQuery += "		GERAL.DATAMOV, " 
	_cQuery += "		GERAL.USUARIO, " 
	_cQuery += "		GERAL.NUMSEQ, " 
	_cQuery += "		GERAL.ARMSAI, " 
	_cQuery += "		GERAL.ARMENT "
	_cQuery += " FROM " 	
	_cQuery += "		(SELECT " 
	_cQuery += "			SD3.D3_FILIAL FILIAL, "
   	_cQuery += "			SD3.D3_DOC DOC, "
	_cQuery += "     	SD3.D3_COD PRODUTO, "
	_cQuery += "      	SD3.D3_QUANT QUANTMOV, " 
	_cQuery += "       	SD3.D3_EMISSAO DATAMOV, "
	_cQuery += "         SD3.D3_USUARIO USUARIO, "
	_cQuery += "         SD3.D3_NUMSEQ NUMSEQ, "
	_cQuery += "         MAX(CASE WHEN SD3.D3_TM = '999' THEN SD3.D3_LOCAL END) ARMSAI, "
	_cQuery += "         MAX(CASE WHEN SD3.D3_TM = '499' THEN SD3.D3_LOCAL END) ARMENT "
	_cQuery += "		FROM "
	_cQuery += 			RetSqlName("SD3") + " SD3 "
	_cQuery += "		WHERE "
	_cQuery += "			SD3.D_E_L_E_T_ = ' ' "
	_cQuery += "			AND SD3.D3_FILIAL BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"' "
	_cQuery += "			AND SD3.D3_ESTORNO <> 'S' "
	_cQuery += "			AND SD3.D3_TM IN ('499','999') "
	_cQuery += "			AND SD3.D3_CF IN ('DE4','RE4') "	
	_cQuery += "			AND SD3.D3_EMISSAO BETWEEN '"+DTOS(MV_PAR07)+"' AND '"+DTOS(MV_PAR08)+"' "
   	_cQuery += "			AND SD3.D3_COD BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"' "
	_cQuery += "		GROUP BY " 
	_cQuery += "			SD3.D3_FILIAL, "
	_cQuery += "			SD3.D3_DOC, "
	_cQuery += "			SD3.D3_COD, "
	_cQuery += "			SD3.D3_QUANT, " 
	_cQuery += "			SD3.D3_EMISSAO, " 
	_cQuery += "			SD3.D3_USUARIO, "
	_cQuery += "			SD3.D3_NUMSEQ) GERAL "
	_cQuery += " WHERE "
	_cQuery += "		GERAL.ARMSAI = '"+MV_PAR05+"' " 
	_cQuery += "		AND GERAL.ARMENT = '"+MV_PAR06+"' "  
    _cQuery += " ORDER BY " 
	_cQuery += "		GERAL.PRODUTO, "
	_cQuery += "		GERAL.DATAMOV "
    
	If Select("TRANSFSD3") <> 0
		dbSelectArea("TRANSFSD3")
		TRANSFSD3->(DbCloseArea())
	EndIf
    
    _cQuery := ChangeQuery(_cQuery)
    
	DbUseArea(.T.,"TOPCONN",TCGenQry( ,, _cQuery ),"TRANSFSD3",.F.,.T.)
        
	dbSelectArea("TRANSFSD3")
    
	While TRANSFSD3->(!Eof()) 
			
  		oSection:Init()
		oReport:IncMeter()
	   
	    oSection:Cell("FILMOV")   :SetValue(TRANSFSD3->FILIAL)
	    oSection:Cell("CODPROD")  :SetValue(TRANSFSD3->PRODUTO)
		oSection:Cell("DESCPROD") :SetValue(Posicione("SB1",1,xFilial("SB1")+TRANSFSD3->PRODUTO,"B1_DESC"))  
		oSection:Cell("QUANTMOV") :SetValue(TRANSFSD3->QUANTMOV)
		oSection:Cell("DOCMOV")   :SetValue(TRANSFSD3->DOC)
		oSection:Cell("ARMORI")   :SetValue(TRANSFSD3->ARMSAI)
		oSection:Cell("ARMDEST")  :SetValue(TRANSFSD3->ARMENT)
		oSection:Cell("DTMOV")    :SetValue(STOD(TRANSFSD3->DATAMOV))
		oSection:Cell("USUMOV")   :SetValue(TRANSFSD3->USUARIO)
		
		/*--------------------------------------
   		| Imprimindo linha com as Informacoes. |
		--------------------------------------*/
		oSection:PrintLine()
	    
		TRANSFSD3->(dbSkip())
	
	EndDo    
	
	oSection:Finish()
	    
	If Select("TRANSFSD3") > 0
		DbSelectArea("TRANSFSD3")
		TRANSFSD3->(DbCloseArea())
	EndIf

Return	
	
/*--------------------------------------------------------|
| Autor | Claudino Domingues              | Data 23/04/15 | 
|---------------------------------------------------------|
| Função: AjustaSX1	                                      |
|---------------------------------------------------------|
| Função responsavel por montar o grupo de perguntas no   |
| dicionario SX1.                                         |
----------------------------------------------------------*/

Static Function AjustaSX1()
    
    /*----------------------------------------------------------------------------------------------------------------------
	º Parametros que devem ser passados para a funcao de criacao das perguntas no arquivo SX1.                              º
	º-----------------------------------------------------------------------------------------------------------------------º
	º  7 º Parametro -> Tipo do dado C=caractere, D=Data, N=Numerico                                                        º
	º 10 º Parametro -> Numero da pre-selecao                                                                               º
	º 11 º Parametro -> O tipo do dado sera G=Get, S=Scroll, C=Choice, R=Range                                              º
	º 12 º Parametro -> Sintaxe em advpl, ou funcao para validacao                                                          º
	º 14 º Parametro -> Nome do grupo ára SXG                                                                               º
	º 15 º Parametro -> Pyme                                                                                                º
	º 16 º Parametro -> Nome da variavel que sera utilizada no programa                                                     º
	º 17 º Parametro -> Primeira definicao do texto em portugues se caso o tipo do dado for choice, exemplo: SIM ou NAO     º
	º 18 º Parametro -> Primeira definicao do texto em espanhol se caso o tipo do dado for choice, exemplo: SI ou NO        º
	º 19 º Parametro -> Primeira definicao do texto em ingles se caso o tipo do dado for choice, exemplo: YES ou NO         º
	º 20 º Parametro -> Conteudo da ultima resposta informada no parametro se caso o tipo do dados for get                  º
	º 21 º Parametro -> Segunda definicao do texto em portugues se caso o tipo do dado for choice, exemplo: SIM ou NAO      º
	º 22 º Parametro -> Segunda definicao do texto em espanhol se caso o tipo do dado for choice, exemplo: SI ou NO         º
	º 23 º Parametro -> Segunda definicao do texto em ingles se caso o tipo do dado for choice, exemplo: YES ou NO          º
	º 24 º Parametro -> Terceira definicao do texto em portugues se caso o tipo do dado for choice, exemplo: SIM ou NAO     º
	º 25 º Parametro -> Terceira definicao do texto em espanhol se caso o tipo do dado for choice, exemplo: SI ou NO        º
	º 26 º Parametro -> Terceira definicao do texto em ingles se caso o tipo do dado for choice, exemplo: YES ou NO         º
	º 27 º Parametro -> Quarta definicao do texto em portugues se caso o tipo do dado for choice, exemplo: SIM ou NAO       º
	º 28 º Parametro -> Quarta definicao do texto em espanhol se caso o tipo do dado for choice, exemplo: SI ou NO          º
	º 29 º Parametro -> Quarta definicao do texto em ingles se caso o tipo do dado for choice, exemplo: YES ou NO           º
	º 30 º Parametro -> Quinta definicao do texto em portugues se caso o tipo do dado for choice, exemplo: SIM ou NAO       º
	º 31 º Parametro -> Quinta definicao do texto em espanhol se caso o tipo do dado for choice, exemplo: SI ou NO          º
	º 32 º Parametro -> Quinta definicao do texto em ingles se caso o tipo do dado for choice, exemplo: YES ou NO           º
	º 36 º Parametro -> Nome do grupo do help                                                                               º
	-----------------------------------------------------------------------------------------------------------------------*/
	
	Local aHelp := {}
	
	// Texto do help em    portugues                                                          
	AADD(aHelp, "Informar a filial que deseja " )
	AADD(aHelp, "consultar (Ex:01 ou deixar " )
	AADD(aHelp, "em branco)." )
	//     1Grup 2Ordem 3TituloPergPortugu      4TituloPergEspanho 5TituloPergIngles 6NomeVaria   7  8Tam 9dec 10  11  12  13F3  14 15      16     17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33HelpPort   34HelpIngl   35HelpEsp   36
	PutSX1(cPerg,"01"  ,"Da Filial ?"          ,""                ,""               ,"MV_CH1"  ,"C", 02  ,00  ,00,"G" ,"" ,"SM0","","","MV_PAR01","","","","","","","","","","","","","","","","" ,aHelp     , aHelp       , aHelp      ,"")
	
	aHelp := {}
	AADD(aHelp, "Informar a filial que deseja " )
	AADD(aHelp, "consultar (Ex:01 ou informar ZZ)." )
	PutSX1(cPerg,"02"  ,"Ate a Filial ?"       ,""                ,""               ,"MV_CH2"  ,"C", 02  ,00  ,00,"G" ,"" ,"SM0","","","MV_PAR02","","","","","","","","","","","","","","","","" ,aHelp     , aHelp       , aHelp      ,"")
	
	aHelp := {}
	AADD(aHelp, "Informar o produto que deseja " )
	AADD(aHelp, "consultar (Ex:04030 ou " )
	AADD(aHelp, "deixar em branco)." )
	PutSX1(cPerg,"03"  ,"Do Produto ?"         ,""                ,""               ,"MV_CH3"  ,"C", 15  ,00  ,00,"G" ,"" ,"SB1","","","MV_PAR03","","","","","","","","","","","","","","","","" ,aHelp     , aHelp       , aHelp      ,"")
	
	aHelp := {}
	AADD(aHelp, "Informar o produto que deseja " )
	AADD(aHelp, "consultar (Ex:04030 ou " )
	AADD(aHelp, "informar ZZZZZ)." )
	PutSX1(cPerg,"04"  ,"Ate Produto ?"        ,""                ,""               ,"MV_CH4"  ,"C", 15  ,00  ,00,"G" ,"" ,"SB1","","","MV_PAR04","","","","","","","","","","","","","","","","" ,aHelp     , aHelp       , aHelp      ,"")
	
	aHelp := {}
	AADD(aHelp, "Informar o armazem de origem " )
	AADD(aHelp, "que deseja consultar (Ex:01)." )
	PutSX1(cPerg,"05"  ,"Armazem de Origem ?"  ,""                ,""               ,"MV_CH5"  ,"C", 02  ,00  ,00,"G" ,"" ,""   ,"","","MV_PAR05","","","","","","","","","","","","","","","","" ,aHelp     , aHelp       , aHelp      ,"")
	
	aHelp := {}
	AADD(aHelp, "Informar o armazem de destino " )
	AADD(aHelp, "que deseja consultar (Ex:40)." )
	PutSX1(cPerg,"06"  ,"Armazem de Destino ?" ,""                ,""               ,"MV_CH6"  ,"C", 02  ,00  ,00,"G" ,"" ,""   ,"","","MV_PAR06","","","","","","","","","","","","","","","","" ,aHelp     , aHelp       , aHelp      ,"")
	
	aHelp := {}
	AADD(aHelp, "Informar a data (de) que " )
	AADD(aHelp, "deseja consultar as " )
	AADD(aHelp, "movimentações." )
	PutSx1(cPerg,"07"  ,"Da Data ?"            ,""                ,""               ,"MV_CH7"  ,"D", 08  ,00  ,00,"G" ,"" ,""   ,"","","MV_PAR07","","","","","","","","","","","","","","","","" ,aHelp     , aHelp       , aHelp      ,"")
	
	aHelp := {}
	AADD(aHelp, "Informar a data (ate) que " )
	AADD(aHelp, "deseja consultar as " )
	AADD(aHelp, "movimentações." )
	PutSx1(cPerg,"08"  ,"Ate a Data ?"         ,""                ,""               ,"MV_CH8"  ,"D", 08  ,00  ,00,"G" ,"" ,""   ,"","","MV_PAR08","","","","","","","","","","","","","","","","" ,aHelp     ,aHelp        ,aHelp       ,"")
	   
Return