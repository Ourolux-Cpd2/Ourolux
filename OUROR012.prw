#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

/*--------------------------------------------------------|
| Autor | Claudino Domingues              | Data 24/08/15 | 
|---------------------------------------------------------|
| Função: OUROR012                                        |
|---------------------------------------------------------|
| Relatório que Aglutina os Atendimento digitados no      |
| modulo CallCenter.                                      |
----------------------------------------------------------*/

User Function OUROR012()

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
| Autor | Claudino Domingues              | Data 24/08/15 | 
|---------------------------------------------------------|
| Função: ReportDef                                       |
|---------------------------------------------------------|
| Montagem do Objetos do TREPORT.                         |
----------------------------------------------------------*/


Static Function ReportDef()
    
	Private cPerg  := PADR("OUROR012",10) 
	
	/*---------------------------------------------------------------------|
	| Apresenta a tela de impressão para o usuario configurar o relatorio. |
	----------------------------------------------------------------------*/
	oReport:=TReport():New(cPerg,"Relatório Aglutina Atendimentos CallCenter",cPerg,{|oReport| PrintReport(oReport)},"Relatório Aglutina Atendimentos CallCenter")
	oReport:SetLandscape(.T.)
	oReport:SetLineHeight(50)
	oReport:nFontBody := 10
	oSection:=TRSection():New(oReport,"Relatório Aglutina Atendimentos CallCenter",{""})
    
	/*-----------
	| Pergunte. |
	-----------*/
	AjustaSX1() 
	Pergunte(oReport:uParam,.T.)
	
	TRCell():New(oSection,"CODPROD"		,/*cAlias*/,"Cod.Produto"	,PesqPict("SB1","B1_COD")		,TamSX3("B1_COD")[1]		,/*lPixel*/ ,/*{|| code-black de impressão}*/ , , ,"LEFT")
	TRCell():New(oSection,"DESCPROD"	,/*cAlias*/,"Descr.Produto"	,PesqPict("SB1","B1_DESC") 	    ,TamSX3("B1_DESC")[1]		,/*lPixel*/ ,/*{|| code-black de impressão}*/ , , ,"LEFT")
	TRCell():New(oSection,"QUANT"		,/*cAlias*/,"Quantidade"	,PesqPict("SUB","UB_QUANT")    	,TamSX3("UB_QUANT")[1]		,/*lPixel*/ ,/*{|| code-black de impressão}*/ , , ,"LEFT")
		                                 
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
	Local _cQuery  := ""

    /*    
	SELECT 
		SUB.UB_PRODUTO,
		SB1.B1_DESC,
		SUM(UB_QUANT) 
	FROM 
		SUA010 SUA
	INNER JOIN 
		SUB010 SUB ON 
			SUA.UA_FILIAL = SUB.UB_FILIAL AND SUA.UA_NUM = SUB.UB_NUM 
	INNER JOIN 
		SB1010 SB1 ON 
			SB1.B1_COD = SUB.UB_PRODUTO
 	WHERE 
 		SUA.UA_CANC = ' ' AND SUA.UA_OPER = '2' AND  
		SUA.UA_EMISSAO BETWEEN '20150818' AND '20150824' AND
		SUA.UA_NUM BETWEEN ' ' AND 'ZZZZ' AND
		SUA.UA_FILIAL = '01' AND
		SUA.D_E_L_E_T_ = ' ' AND 
		SUB.D_E_L_E_T_ = ' ' AND 
		SB1.D_E_L_E_T_ = ' '  
	GROUP BY 
		SUB.UB_PRODUTO,
		SB1.B1_DESC 
	ORDER BY 
		SUB.UB_PRODUTO,
		SB1.B1_DESC  
    */
    
    _cQuery := " SELECT "
	_cQuery += "	SUB.UB_PRODUTO PRODUTO, "
	_cQuery += "	SB1.B1_DESC DESCPROD, "
	_cQuery += "	SUM(UB_QUANT) QUANT"
	_cQuery += " FROM "
	_cQuery += 		RetSqlName("SUA") + " SUA "
	_cQuery += " INNER JOIN "
	_cQuery += 		RetSqlName("SUB") + " SUB ON "
	_cQuery += "		SUA.UA_FILIAL = SUB.UB_FILIAL AND SUA.UA_NUM = SUB.UB_NUM "
	_cQuery += " INNER JOIN "
	_cQuery += 		RetSqlName("SB1") + " SB1 ON " 
	_cQuery += "		SB1.B1_COD = SUB.UB_PRODUTO "
 	_cQuery += " WHERE "
 	_cQuery += "	SUA.D_E_L_E_T_ = ' ' AND "
	_cQuery += "	SUB.D_E_L_E_T_ = ' ' AND "
	_cQuery += "	SB1.D_E_L_E_T_ = ' ' AND "
	_cQuery += "	SUA.UA_CANC = ' ' AND SUA.UA_OPER = '2' AND "
	_cQuery += "	SUA.UA_FILIAL = '" + xFilial("SUA") + "' AND "
	_cQuery += "	SUA.UA_NUM BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"' AND "  
	_cQuery += "	SUA.UA_EMISSAO BETWEEN '"+DTOS(MV_PAR03)+"' AND '"+DTOS(MV_PAR04)+"' "
	_cQuery += " GROUP BY "
	_cQuery += "	SUB.UB_PRODUTO, "
	_cQuery += "	SB1.B1_DESC "
	_cQuery += " ORDER BY "
	_cQuery += "	SUB.UB_PRODUTO, "
	_cQuery += "	SB1.B1_DESC "
	
	If Select("TMKAGLUT") <> 0
		dbSelectArea("TMKAGLUT")
		TMKAGLUT->(DbCloseArea())
	EndIf
    
    _cQuery := ChangeQuery(_cQuery)
    
	DbUseArea(.T.,"TOPCONN",TCGenQry( ,, _cQuery ),"TMKAGLUT",.F.,.T.)
        
	dbSelectArea("TMKAGLUT")
    
	While TMKAGLUT->(!Eof()) 
			
  		oSection:Init()
		oReport:IncMeter()
	   
	    oSection:Cell("CODPROD")  :SetValue(TMKAGLUT->PRODUTO)
		oSection:Cell("DESCPROD") :SetValue(Posicione("SB1",1,xFilial("SB1")+TMKAGLUT->PRODUTO,"B1_DESC"))  
		oSection:Cell("QUANT")    :SetValue(TMKAGLUT->QUANT)
		
		/*--------------------------------------
   		| Imprimindo linha com as Informacoes. |
		--------------------------------------*/
		oSection:PrintLine()
	    
		TMKAGLUT->(dbSkip())
	
	EndDo    
	
	oSection:Finish()
	    
	If Select("TMKAGLUT") > 0
		DbSelectArea("TMKAGLUT")
		TMKAGLUT->(DbCloseArea())
	EndIf

Return	
	
/*--------------------------------------------------------|
| Autor | Claudino Domingues              | Data 24/08/15 | 
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
	AADD(aHelp, "Informar o Atendimento que deseja " )
	AADD(aHelp, "consultar (Ex:004567 ou " )
	AADD(aHelp, "deixar em branco)." )
	//     1Grup 2Ordem 3TituloPergPortugu       4TituloPergEspanho 5TituloPergIngles 6NomeVaria  7  8Tam  9dec 10  11  12  13F3 14 15      16    17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32  33HelpPort   34HelpIngl   35HelpEsp   36
	PutSX1(cPerg,"01"  ,"Do Atendimento ?"      ,""                ,""               ,"MV_CH1"  ,"C", 06  ,00  ,00,"G" ,"" ,""  ,"","","MV_PAR01","","","","","","","","","","","","","","","","" ,aHelp     , aHelp       , aHelp      ,"")
	
	aHelp := {}
	AADD(aHelp, "Informar o Atendimento que deseja " )
	AADD(aHelp, "consultar (Ex:004567 ou " )
	AADD(aHelp, "informar ZZZZZZ)." )
	PutSX1(cPerg,"02"  ,"Ate Atendimento ?"     ,""                ,""               ,"MV_CH2"  ,"C", 06  ,00  ,00,"G" ,"" ,""  ,"","","MV_PAR02","","","","","","","","","","","","","","","","" ,aHelp     , aHelp       , aHelp      ,"")
    
    aHelp := {}
	AADD(aHelp, "Informar a data (de) emissão que " )
	AADD(aHelp, "deseja consultar " )
	AADD(aHelp, "os atendimentos." )
	PutSx1(cPerg,"03"  ,"Da Data ?"             ,""                ,""               ,"MV_CH3"  ,"D", 08  ,00  ,00,"G" ,"" ,""  ,"","","MV_PAR03","","","","","","","","","","","","","","","","" ,aHelp     , aHelp       , aHelp      ,"")
	
	aHelp := {}
	AADD(aHelp, "Informar a data (ate) emissão que " )
	AADD(aHelp, "deseja consultar " )
	AADD(aHelp, "os atendimentos." )
	PutSx1(cPerg,"04"  ,"Ate a Data ?"          ,""                ,""               ,"MV_CH4"  ,"D", 08  ,00  ,00,"G" ,"" ,""  ,"","","MV_PAR04","","","","","","","","","","","","","","","","" ,aHelp     ,aHelp        ,aHelp       ,"")
	   
Return