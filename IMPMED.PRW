#INCLUDE "PROTHEUS.CH"

/*---------------------------------------------------------|
| Autor | Claudino Domingues               | Data 07/02/14 | 
|----------------------------------------------------------|
| Fun��o: IMPMED	                                       |
|----------------------------------------------------------|
| Rotina que faz a leitura das medidas ( Altura , Largura  |
| e Comprimento ) cadastradas na Especifica��o de          |
| Produtos QIEA010 (Tabelas QE6 e QE7) e importa para o    |
| cadastro de Complemento de Produto MATA180 (Tabela SB5). |
----------------------------------------------------------*/

User Function IMPMED()
    
	Local _cPerg := PADR("IMPMED",10) // Grupo de Perguntas.
		
	CriaSX1(_cPerg) // Fun��o que faz a cria��o do Pergunta na SX1 atraves do PUTSX1.
	Pergunte(_cPerg,.T.) // Caso o parametro esteja como .T. o sistema ira apresentar a tela de perguntas antes que abrir a tela configura��o do relat�rio.
    
    Processa( {|lEnd| RunCalc(@lEnd)}, "Aguarde...","Executando rotina.", .T. )
     
Return

*****************************

Static Function RunCalc(lEnd)
 
 	Local _cQuery   := ""
	Local _nLargura := ""
	Local _nAltura  := ""
	Local _nCompri  := ""
	Local _nTemp1   := ""
	Local _nValRest := ""
	Local _nValInt  := ""
	Local _nCnt		:= 0
     
    If Select("TMPMED") > 0
		DbSelectArea("TMPMED")
		TMPMED->(DbCloseArea())
	EndIf 
      
    _cQuery := " SELECT QE6_FILIAL,QE6_PRODUT,MAX(QE6_REVI) REVISAO "
    _cQuery += " FROM " + RetSqlName("QE6") 
	_cQuery += " WHERE QE6_PRODUT >=  '" +MV_PAR01+ "' AND QE6_PRODUT <=  '" +MV_PAR02+ "' "
	_cQuery += " GROUP BY QE6_FILIAL,QE6_PRODUT "
	_cQuery += " ORDER BY QE6_FILIAL,QE6_PRODUT "
   	
	_cQuery := ChangeQuery(_cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQuery),"TMPMED",.T.,.T.)
    
    dbEval( {|x| _nCnt++ },,{||TMPMED->QE6_PRODUT<=MV_PAR02})
    
    ProcRegua(_nCnt)
    
    TMPMED->(dbGoTop())
    
	While TMPMED->(!Eof())
	    	    
		dbSelectArea("QE7")
    	QE7->(dbSetOrder(1))
	 
		If QE7->(dbSeek(xFilial("QE7")+TMPMED->QE6_PRODUT+TMPMED->REVISAO+"EMB_I_L "))
			_nTemp1   := StrTran(Alltrim(QE7->QE7_NOMINA),",",".")
			_nValRest := Val(SubString(_nTemp1,RAt(".",_nTemp1)+1,Len(_nTemp1))) / 10 / 10
			_nValInt  := Val(QE7->QE7_NOMINA) / 10
			_nLargura := cValtoChar(_nValInt + _nValRest)
		EndIf
		
		If QE7->(dbSeek(xFilial("QE7")+TMPMED->QE6_PRODUT+TMPMED->REVISAO+"EMB_I_A "))
			_nTemp1   := StrTran(Alltrim(QE7->QE7_NOMINA),",",".")
			_nValRest := Val(SubString(_nTemp1,RAt(".",_nTemp1)+1,Len(_nTemp1))) / 10 / 10
			_nValInt  := Val(QE7->QE7_NOMINA) / 10
			_nAltura  := cValtoChar(_nValInt + _nValRest)
		EndIf
		
		If QE7->(dbSeek(xFilial("QE7")+TMPMED->QE6_PRODUT+TMPMED->REVISAO+"EMB_I_P "))
			_nTemp1   := StrTran(Alltrim(QE7->QE7_NOMINA),",",".")
			_nValRest := Val(SubString(_nTemp1,RAt(".",_nTemp1)+1,Len(_nTemp1))) / 10 / 10
			_nValInt  := Val(QE7->QE7_NOMINA) / 10
			_nCompri  := cValtoChar(_nValInt + _nValRest)
		EndIf
			  
	    dbSelectArea("SB5")
	    SB5->(dbSetOrder(1))
	    
	    If SB5->(dbSeek(xFilial("SB5")+TMPMED->QE6_PRODUT))
	    	RecLock("SB5",.F.)
	    		SB5->B5_COMPR  := Val(_nCompri)
	    		SB5->B5_LARG   := Val(_nLargura)
	    		SB5->B5_ALTURA := Val(_nAltura)
	    	SB5->(MsUnLock("SB5"))
	    	
	    	_nCompri  := "" 
	    	_nLargura := ""
	    	_nAltura  := ""
	    	
	    	IncProc(" Processando Produto: " + Alltrim(TMPMED->QE6_PRODUT))
	    	
	    Else
	    	RecLock("SB5",.T.)
	    		SB5->B5_COD    := TMPMED->QE6_PRODUT
	    		SB5->B5_CEME   := Posicione("SB1",1,xFilial("SB1")+TMPMED->QE6_PRODUT,"B1_DESC")
	    		SB5->B5_COMPR  := Val(_nCompri)
	    		SB5->B5_LARG   := Val(_nLargura)
	    		SB5->B5_ALTURA := Val(_nAltura)
	    	SB5->(MsUnLock("SB5"))
	        
	    	_nCompri  := "" 
	    	_nLargura := ""
	    	_nAltura  := ""
	    	
	    	IncProc(" Processando Produto: " + Alltrim(TMPMED->QE6_PRODUT))
	    	
	    EndIf
	    
	    If lEnd
	    	MsgInfo(cCancela,"Fim")
	    	Exit
	   	EndIf
	    
		("TMPMED")->(dbSkip())    
	 
	EndDo
	    	
	TMPMED->(DbCloseArea())

Return 

******************************

Static Function CriaSX1(cPerg)

	//----------------------------------------------------------------------------------------------------------------------//
	// Parametros que devem ser passados para a fun��o de cria��o das perguntas no arquivo SX1.                             //
	//----------------------------------------------------------------------------------------------------------------------//
	//  7� Parametro -> Tipo do dado C=caractere, D=Data, N=Numerico                                                        //
	// 10� Parametro -> Numero da pre-selecao                                                                               //
	// 11� Parametro -> O tipo do dado sera G=Get, S=Scroll, C=Choice, R=Range                                              //
	// 12� Parametro -> Sintaxe em advpl, ou funcao para validacao                                                          //
	// 14� Parametro -> Nome do grupo �ra SXG                                                                               //
	// 15� Parametro -> Pyme                                                                                                //
	// 16� Parametro -> Nome da variavel que sera utilizada no programa                                                     //
	// 17� Parametro -> Primeira definicao do texto em portugues se caso o tipo do dado for choice, exemplo: SIM ou NAO     //
	// 18� Parametro -> Primeira definicao do texto em espanhol se caso o tipo do dado for choice, exemplo: SI ou NO        //
	// 19� Parametro -> Primeira definicao do texto em ingles se caso o tipo do dado for choice, exemplo: YES ou NO         //
	// 20� Parametro -> Conteudo da ultima resposta informada no parametro se caso o tipo do dados for get                  //
	// 21� Parametro -> Segunda definicao do texto em portugues se caso o tipo do dado for choice, exemplo: SIM ou NAO      //
	// 22� Parametro -> Segunda definicao do texto em espanhol se caso o tipo do dado for choice, exemplo: SI ou NO         //
	// 23� Parametro -> Segunda definicao do texto em ingles se caso o tipo do dado for choice, exemplo: YES ou NO          //
	// 24� Parametro -> Terceira definicao do texto em portugues se caso o tipo do dado for choice, exemplo: SIM ou NAO     //
	// 25� Parametro -> Terceira definicao do texto em espanhol se caso o tipo do dado for choice, exemplo: SI ou NO        //
	// 26� Parametro -> Terceira definicao do texto em ingles se caso o tipo do dado for choice, exemplo: YES ou NO         //
	// 27� Parametro -> Quarta definicao do texto em portugues se caso o tipo do dado for choice, exemplo: SIM ou NAO       //
	// 28� Parametro -> Quarta definicao do texto em espanhol se caso o tipo do dado for choice, exemplo: SI ou NO          //
	// 29� Parametro -> Quarta definicao do texto em ingles se caso o tipo do dado for choice, exemplo: YES ou NO           //
	// 30� Parametro -> Quinta definicao do texto em portugues se caso o tipo do dado for choice, exemplo: SIM ou NAO       //
	// 31� Parametro -> Quinta definicao do texto em espanhol se caso o tipo do dado for choice, exemplo: SI ou NO          //
	// 32� Parametro -> Quinta definicao do texto em ingles se caso o tipo do dado for choice, exemplo: YES ou NO           //
	// 36� Parametro -> Nome do grupo do help                                                                               //
	//----------------------------------------------------------------------------------------------------------------------//
	
	Local aHelp := {}
	
	// Texto do help em    portugues         , ingles, espanhol
	AADD(aHelp,{{ "Informe Produto Inicial" },  {""} ,  {""}  })
	AADD(aHelp,{{ "Informe Produto Final"   },  {""} ,  {""}  })
	
	//      1Grup   2Ordem   3TituloPergPortugu   4TituloPergEspanho   5TituloPergIngles     6NomeVaria     7     8Tam   9dec   10    11    12   13F3    14   15        16            17          18            19      20     21          22          23          24          25          26      27   28   29   30   31   32   33HelpPort   34HelpIngl   35HelpEsp    36
	
	PutSX1( cPerg ,  "01"  ,  "Do Produto ?   "  ,  "De Producto ? "  ,  "From Product ? "  ,  "MV_CH1"  ,  "C"  ,  15  ,  0  ,  0  , "G" , "" , "SB1" , "" , "S" , "MV_PAR01" , ""        , ""         , ""          , "" ,""       , ""         , ""       , ""        , ""        , ""        , "" , "" , "" , "" , "" , "" , aHelp[1,1] , aHelp[1,2] , aHelp[1,3] , "" )
	PutSX1( cPerg ,  "02"  ,  "Ate Produto ?  "  ,  "A Producto ?  "  ,  "To Product ?   "  ,  "MV_CH2"  ,  "C"  ,  15  ,  0  ,  0  , "G" , "" , "SB1" , "" , "S" , "MV_PAR02" , ""        , ""         , ""          , "" ,""       , ""         , ""       , ""        , ""        , ""        , "" , "" , "" , "" , "" , "" , aHelp[2,1] , aHelp[2,2] , aHelp[2,3] , "" )
	
Return(Nil)