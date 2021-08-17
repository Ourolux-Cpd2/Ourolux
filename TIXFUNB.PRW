#define Confirma 1
#define Redigita 2
#define Abandona 3

#INCLUDE 'FIVEWIN.CH'
#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'HEADERGD.CH'

Static lIncluir := .F.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao      ³GPEA320 ³ Autor         ³ RH - Natie    ³ Data ³ 19/06/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao   ³Manutencao de Parametros                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe     ³GPEA320()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso         ³Generico ( DOS e Windows )                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ FNC           ³  Motivo da Alteracao            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±± 
±±³Leandro Dr. ³27/09/12|M12RH01        |Req.RHU210- Unificacao das folhas³±± 
±±³Raquel Hager³01/11/12|M12RH01 RQ002  |Unificacao das folhas.           ³±± 
±±³Raquel Hager³18/01/12³M12RH01 RQ003  ³Remocao de filtro para Gestao    ³±±
±±³            ³        ³               ³Publica e inclusao da funcao     ³±±  
±±³            ³        ³               ³AjustaSxb.                       ³±±    
±±³Raquel Hager³25/09/13³M12RH01 RQ003  ³Compatibilizavao Ver. 11.80 =>   ³±±
±±³            ³        ³               ³Tratamento no gp320LinOk p/ BRA. ³±±
±±³Christiane V³08/05/14³ TPMJR2        ³Alteração da função Gp320aCols p/³±±  
±±³            ³        ³               ³tratamento especifico de data em ³±±  
±±³            ³        ³               ³branco só na ultima coluna.      ³±±  
±±³Cecilia Car.³12/05/14³M_RH003 002974 ³Retirada da funcao fFiltrAsMed.  ³±±
±±³M. Silveira ³23/07/14³TPYGOZ         ³Ajuste para impedir a gravacao de³±±
±±³            ³        ³               ³codigo de Filial invalido.       ³±±
±±³Gustavo M.  ³18/09/14³TQPJB9         ³Ajuste na tela da importacao de  ³±±
±±³            ³        ³               ³tabelas.					      ³±±
±±³Luis Artuso ³19/01/15³		  TRHZRV³Alteracao p/ nao remontar todas  ³±±
±±³            ³        ³		   	    ³sequencias ao realizar o tudOk() ³±±
±±³            ³        ³				³pois esse processo e' desnecessa-³±±
±±³            ³        ³				³rio uma vez que ja e' realizado  ³±±
±±³            ³        ³				³no linOk() da alteracao da linha.³±±
±±³Allyson M.  ³20/01/15³TRJOUU         ³Ajuste p/ montagem correta das   ³±±
±±³            ³        ³               ³sequencias.				      ³±±
±±³Cícero Alves³04/03/15³		        ³ Retirada da função AjustaSXB    ³±±
±±³            ³        ³               ³				  				  ³±±
±±³Henrique V. ³09/03/15³TRSYNL         ³Correção para sistema validar as ³±±  
±±³            ³        ³               ³Filiais de todos os grupos de emp³±±  
±±³            ³        ³               ³resas cadastrados, quando usuário³±±
±±³            ³        ³               ³inclui registros de grupos de emp³±±
±±³            ³        ³               ³resas diferentes do grupo logado.³±± 
±±³Henrique V. ³10/03/15³TRTGQH         ³Correção para sistema não mudar a³±±  
±±³            ³        ³               ³ordem dos registros de tabelas   ³±±  
±±³            ³        ³               ³auxiliares quando o usuário entra³±±
±±³            ³        ³               ³Alterando a tabela.              ³±±
±±³L.Trombini  ³30/03/15³TRVEDP         ³ajustado para o sistema acertar a³±±  
±±³            ³        ³               ³sequencia das tabelas Auxliares  ³±±  
±±³            ³        ³               ³quando a tabela não utiliza chave³±±
±±³            ³        ³               ³ano mes fixo (retornado Sort)    ³±±
±±³Marcos Perei³03/09/2015³PCREQ-5342   ³Produtiz. Gestão Pública na 12.  ³±±
±±³Mariana M   ³08/10/15³TTIOCY         ³Alteracao na ordenacao da SX3 na ³±±
±±³            ³        ³		   	    ³montagem do aCols da inclusao    ³±±
±±³Marcos Perei³11/11/2015³PCREQ-5342   ³Tratamento provisorio ColumnPos  ³±±
±±³            ³        ³               ³que devera ser retirado quando   ³±±
±±³            ³        ³               ³liberar o dicionario da 12.1.8   ³±±
±±³Allyson M   ³08/12/15³TTXAW6         ³Validacao especifica p/ tabela   ³±±
±±³            ³        ³		   	    ³S043.    						  ³±±
±±³Claudinei S.³26/02/16³TUCD45         ³Alterada a S043 para permitir    ³±±
±±³            ³        ³		   	    ³Aviso Trab. e Saldo de Salario.  ³±±
±±³Leandro Dr. ³29/02/16³TULL47         ³Retirado validacao anterior.     ³±±
±±³Esther V.   ³29/06/16³   TVMNZA      ³Ajuste na variavel lGestPubl.    ³±±
±±³Victor A.   ³28/07/16³TVLQOD         ³Ajuste para verificar se período ³±±
±±³            ³        ³		   	    ³informado é menor que 201001,    ³±±
±±³            ³        ³		   	    ³pois anterior a essa data não era³±±
±±³            ³        ³		   	    ³obrigat. mais de 3 faixas IR-S002³±±
±±³Gustavo M.  ³27/12/16³MRH-3404       ³Ajuste declaração da variavel.   ³±±
±±³Allyson M   ³28/12/16³MRH-1357       ³Ajuste p/ validar preenchimento  ³±±
±±³            ³        ³		   	    ³de filial e período da S033.	  ³±±
±±³Marcos Cout ³06/04/17³DRHESOCP-78    ³Realizar ajustes para que não    ³±±
±±³            ³        ³		   	    ³seja gerado Error.Log quando se é³±±
±±³            ³        ³		   	    ³apagado todos os registros da ta_³±±
±±³            ³        ³		   	    ³bela S119.                       ³±±
±±³Oswaldo L   ³27/06/17³DRHESOCP-516   ³Remover coluna CTRDEF           ³±±
±±³Oswaldo L   ³28/06/17³DRHESOCP-516   ³Tratar contrato aprendiz zerado ³±±
±±³Oswaldo L   ³03/07/17³DRHESOCP-516   ³Deixar não editavel -coluna Cod.³±±
±±³Oswaldo L   ³04/07/17³DRHESOCP-516   ³Alteracao efetuada para S119 120³±±
±±³Oswaldo L   ³13/07/17³DRHESOCP-588   ³Acerto Verificação linha não    ³±±
±±³            ³        ³               ³deletada antes de exibir msg    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß */
 
//-------------------------------------------------------------------------------------
/*/{Protheus.doc} xTIxBRW
Manutencao de tabelas baseada na funcao padrao GPEA320

@type 		function
@author 	Roberto Souza
@since 		24/04/2017
@version 	P12 
 
@return nil
/*/    
//-------------------------------------------------------------------------------------
User Function xTIxBRW
Local   aArea		 := GetArea()
Local   aAreaRCB	 := RCB->(GetArea())
Local   aAreaRCC	 := RCC->(GetArea())	
Local 	lManutence 	 := .F.
Local 	lGPERM		 := GetNewPar("MV_CLASSIS", .F.) //Verifica se a integracao entre os sistemas Protheus x RM Classis Net (RM) esta ativa
Private cGSPubl		 := ""
Private cCodigo 	 := CriaVar("RCB_CODIGO")
Private cDescri		 := CriaVar("RCB_DESC")
Private cFiltraRCC					// Variavel para filtro
Private aIndexRCB	 := {}			// Variavel para filtro
Private nP := 0  
Private aButtons     := {}
Private lGpea320Inc  := .F.
Private lAnoMes		 := .T.
Public  Desabilitado := .F.   
Public 	lGestPubl 	 := if(ExistFunc("fUsaGFP"),fUsaGFP(),.f.)	//Verifica se utiliza o modulo de Gestao de Folha Publica - SIGAGFP
Private oTmpTable	 := Nil

	//Executa um pack na RCC
	Chk_Pack("RCC",10)
	
	lManutence := ( FunName() == "GPEA320M" )
	
	If Gp310ModComp("RCB")
		Private bFiltraBrw 	:= {|| Nil}		     // Variavel para Filtro	
		Private aRotina := MenuDef()            // Ajuste para versao 9.12 - chamada da funcao MenuDef() que contem aRotina 								
		Private cCadastro := OemToAnsi("Cadastro de Tabelas ["+__cUserID+"]"	) //"Cadastro de Tabelas"	
		
		GpIniCRG()
		
		If lManutence .Or. .T.
			aAdd(aRotina, { "Gerar Fonte Tabelas" , "GPE320GER" , 0 , 8 } ) // "Gerar Fonte Tabelas"
			aAdd(aRotina, { "Importacao" , "GPE320IMP" , 0 , 8 } ) // "Importacao"
		EndIf
		
		dbSelectArea("RCB")
		dbSeek(xFilial("RCB"))
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Inicializa o filtro utilizando a funcao FilBrowse                      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cFiltraRCB	:=	'RCB_ORDEM == "01" '
		cFiltraRh	:= CHKRH("GPEA320","RCC","1") 
		cFiltraUsr  := ChkFilUser( __cUserId )
		If !Empty(cFiltraRh)
			cFiltraRCB := cFiltraRCB + ".And." + cFiltraRh
		EndIf   
		
		If __cUserId <> "000000"
			If Empty(cFiltraUsr) 
				cFiltraRCB := cFiltraRCB + ".And. RCB_CODIGO =='XXXX'"	
			Else
				If "*" $ cFiltraUsr
					cFiltraRCB := cFiltraRCB + ".And. Left(RCB_CODIGO,1) == 'U' " 				
				Else
					cFiltraRCB := cFiltraRCB + ".And. RCB_CODIGO $ '" + cFiltraUsr+"'"
				EndIf
			EndIf
		EndIf
		
		If !lGPERM
			cFiltraRCB := cFiltraRCB + " .And. " + "RCB_CODIGO <> 'S071'"
		EndIf	
		cFiltraRh	:= CHKRH("GPEA320","RCB","1")  
		If !Empty(cFiltraRh)
			cFiltraRCB := cFiltraRCB + " .And. " + cFiltraRh 
		EndIf
		
		bFiltraBrw 	:= {|| FilBrowse("RCB",@aIndexRCB,@cFiltraRCB) }
		Eval(bFiltraBrw)
	
	   	SetBrwCHGAll( .T. ) //Nao apresentar a tela para selecionar a Filial            
		
		// Endereca a funcao de BROWSE      
		MBrowse(06,01,22,75,'RCB',, , , , , fUseCor(), , , ,)                            
		
		// Deleta o filtro utilizando a funcao FilBrowse                     	   
		EndFilBrw("RCB",aIndexRCB)
	Endif	
	
	// Restaura Area e Ordem de Entrada                             
	RestArea( aArea )
	RestArea( aAreaRCC)      
	RestArea( aAreaRCB)       
	
Return( Nil )

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} ChkFilUser
Retorna lista de distribuição de e-mail.

@type 		function
@author 	Roberto Souza
@since 		24/04/2017
@version 	P11 
 
@return nil
/*/    
//-------------------------------------------------------------------------------------
Static Function ChkFilUser( cCodUser )
	Local cRet 	:= ""             
	Local cTab 	:= "U000"
	Local aInfo := {}		
	Local Nx    := 0                   
	Local aStru := {}

	U_xRByTab( @aInfo , cTab , , @aStru )
	nPosI := 7
	nPosU := 5
	For Nx := 1 To Len( aInfo )
		If AllTrim(aInfo[Nx][nPosU]) == cCodUser
			cRet += AllTrim(aInfo[Nx][nPosI])+"|" 				
		EndIf
	Next

Return( cRet )

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ xTIxBRWA ³ Autor ³ R.H - Natie           ³ Data ³ 13/06/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Alteracao de Estrutura do Parametro                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ExpN1 := AxAltera(ExpC1,ExpN2,ExpN3,ExpA1,ExpA2)           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 = Opcao devolvida pela funcao                        ³±±
±±³          ³ ExpC1 = Alias do arquivo                                   ³±±
±±³          ³ ExpN2 = Numero do registro                                 ³±±
±±³          ³ ExpN3 = Numero da opcao selecionada                        ³±±
±±³          ³ ExpA1 = Array contendo campos a serem mostrados            ³±±
±±³          ³ ExpA2 = Array limitando campos a serem aceitos com Get     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
User Function xTIxBRWA(cAlias,nReg,nOpcx)
Local	nOpca		:= 0
Local 	nCnt		:= 0 
Local	aKeys		:= Getkeys()
Local   aArea		:= GetArea()
Local   aAreaRCC	:= RCC->( GetArea() )
Local   aAreaRCB	:= RCB->( GetArea() )
// Private da Getdados
Local   a320nField	:= {}
Local 	aColsRec	:= {}  		    	

Local 	cCond		:= "", cChave:= ""
Local   cPict		:= "99"
Local 	oFont
Local 	oDlgMain
// Variaveis dimensoes do objeto tela 
Local aAdvSize		:= {}
Local aInfoAdvSize	:= {}
Local aObjSize		:= {}
Local aObjCoords	:= {}
Local aAdv1Size		:= {}
Local aInfo1AdvSize	:= {}
Local aObj1Size		:= {}
Local aObj1Coords	:= {}
Local bSet15        := { || }
Local bSet24        := { || }
Private cCodigo 	:= CriaVar("RCB_CODIGO")
Private cDescri		:= CriaVar("RCB_DESC")
Private cFilTab 	:= CriaVar("RCC_FIL")  
Private cChavRCC	:= CriaVar("RCC_CHAVE")
Private nOpcao 		:= nOpcx
Private oGeT
Private oCodigo, oDescri, oFil, oChave
Private oGroup1, oGroup2
Private oFont1, oFont2
Private aVisual     := {}
Private aAntes      := {}   
Private aColsBkp    := {} 
Private aCargFil 	:= FwLoadSm0() 
Private nBkp        := 0
Private lMsg   		:= .F.
Private aAlter119 	:= {}
Private	aColsAnt	:= {}

	cCodigo		        := RCB->RCB_CODIGO
	cDescri		        := RCB->RCB_DESC  

	lAnoMes := If(RCB->RCB_SHOWMA == "S", .T., .F.) // O CAMPO RCB_SHOWMA INDICA SE A COLUNA MES/ANO SERA EXIBIDA OU NAO

	// Verifica a existencia da estrutura do parametro
	dbSelectArea(cAlias)
	dbSeek( xFilial(cAlias) )
	If (Eof() .And. Bof())
		Help(" ",1,"A320SPAR") // "Nao existe tabela."-"Para cadastramento de tabelas, acesse 'Definicoes de Tabela'"
		Return 
	EndIf	

	// Deleta o filtro utilizando a funcao FilBrowse                     	   
	EndFilBrw("RCB",aIndexRCB)
	aIndexRCB := {}

	cAlias		:= "RCC"
	dbSetOrder(1)
	dbSeek( xFilial(cAlias)+ cCodigo )
	Do While .T.   
		// Campos Nao editaveis no aCols                                          
		a320nField	:= {"RCC_FILIAL","RCC_CODIGO","RCC_CONTEU"}
		cFilRCC		:= xFilial(cAlias)
	
	   // Verifica existencia de registro 
		dbSelectArea(cAlias)
		dbSetOrder(1)
		dbSeek( cFilRCC + cCodigo )
		While !Eof() .and. cFilRCC + cCodigo = RCC->RCC_FILIAL+RCC->RCC_CODIGO
			nCnt++
			dbSkip()
		Enddo 
		
	    If nCnt > 0  .And. nOpcx == 3      // Quando Inclusao e existir Registro
			If lGpea320Inc 		
				lGpea320Inc := .F.	
				Exit
			EndIf
			Help(" ",1,"A310REG")         // "Ja existe registro para esta tabela", "Utilize a opcao Alterar."
			Exit
		ElseIf nCnt == 0 .And. nOpcx # 3   // Quando nao for Inclusao e nao existir Registro
			Aviso("Atencao","Nao existem registros cadastrados para esta tabela. Utilize a opcao 'Incluir'.",{'OK'}) // "Atencao"###"Nao existem registros cadastrados para esta tabela. Utilize a opcao 'Incluir'."
			Exit
		Endif
	
		// Monta a entrada de dados do arquivo                          
		cCond	:= "RCC_FILIAL + RCC_CODIGO"
		cChave	:= xFilial("RCC")+ cCodigo
		cFilTab	:= RCC->RCC_FIL
		cChavRCC:= RCC->RCC_CHAVE
		aHeader	:= gp320aHead(a320nField,cAlias)  								          
		aCols	:= gp320aCols(a320nField,cAlias,cCond,cChave,nOpcx,@aColsRec,@aColsAnt)  
		
		If nOpcx==3 .And.  ( Type("n") != "U" )
			n := 1
		EndIf
		
	    // Monta as Dimensoes dos Objetos         					     
		aAdvSize		:= MsAdvSize()
		aInfoAdvSize	:= { aAdvSize[1] , aAdvSize[2] , aAdvSize[3] , aAdvSize[4] , 5 , 5 }
		aAdd( aObjCoords , { 000 , 028 , .T. , .F. } )
		aAdd( aObjCoords , { 000 , 000 , .T. , .T. } )
		aObjSize		:= MsObjSize( aInfoAdvSize , aObjCoords )
			
		aAdv1Size		:= aClone(aObjSize[1])
		aInfo1AdvSize	:= { aAdv1Size[2] , aAdv1Size[1] , aAdv1Size[4] , aAdv1Size[3] , 1 , 1 }
		aAdd( aObj1Coords , { 070 , 000 , .F. , .T. } )
		aAdd( aObj1Coords , { 000 , 000 , .T. , .T. } )
		aObj1Size		:= MsObjSize( aInfo1AdvSize , aObj1Coords,,.T. )
	
		DEFINE FONT oFont  NAME "Arial" SIZE 0,-11 BOLD
		
		SetaPilha()						
	
		Help := .T.
	
		DEFINE MSDIALOG oDlgMain TITLE OemToAnsi( cCadastro ) FROM aAdvSize[7],0 TO aAdvSize[6],aAdvSize[5] OF oMainWnd PIXEL 
	
			@ aObj1Size[1,1] , aObj1Size[1,2] GROUP oGroup1 TO aObj1Size[1,3] ,aObj1Size[1,4] LABEL OemToAnsi("Codigo da Tabela:") OF oDlgMain PIXEL // "Codigo da Tabela:"
			oGroup1:oFont:= oFont
			@ aObj1Size[2,1] , aObj1Size[2,2] GROUP oGroup2 TO aObj1Size[2,3] ,aObj1Size[2,4] LABEL OemToAnsi("Descricao") OF oDlgMain PIXEL // "Descricao"			
			oGroup2:oFont:= oFont
	
			@ aObj1Size[1,1]+12 , aObj1Size[1,2]+10 SAY cCodigo SIZE 050,10 OF oDlgMain PIXEL FONT oFont
		 	@ aObj1Size[2,1]+12 , aObj1Size[2,2]+10 SAY cDescri SIZE 120,10 OF oDlgMain PIXEL FONT oFont 
			

			If cCodigo == "S119" .or. cCodigo == "S120"
				oGet := MSGetDados():New(aObjSize[2,1],aObjSize[2,2],aObjSize[2,3],aObjSize[2,4], nOpcx,"U_xTIxBLiO","U_xTIxBTOK",,If(nOpcx=2 .Or. nOpcx=5,Nil,.T.),aAlter119,,,999999)
			Else
				oGet := MSGetDados():New(aObjSize[2,1],aObjSize[2,2],aObjSize[2,3],aObjSize[2,4], nOpcx,"U_xTIxBLiO","U_xTIxBTOK",,If(nOpcx=2 .Or. nOpcx=5,Nil,.T.),,,,999999)
			EndIf

			oGet:lf3Header := .T.   //Habilita o uso da Consulta F3 na GetDados
			
			bSet15 := { ||  nOpca := 1, If(gp320TudOk(oGet),oDlgMain:End(),nOpca:=0)}		
			bSet24 := { || 	RestKeys(aKeys,.T.), oDlgMain:End()}
			fChoBar320(oDlgMain,,,nOpcx) 	// Carrega opcoes em Acoes Relacionadas																																	
	
		ACTIVATE MSDIALOG oDlgMain ON INIT EnchoiceBar(oDlgMain, bSet15, bSet24, NIL, aButtons) CENTERED		
		SetaPilha()
	            
		Help := .F.
	
		If nOpcA == Redigita
			Exit
		ElseIf nOpcA == Confirma .And. nOpcx # 2
			Begin Transaction                             
				// Gravacao
			U_xTIxBRWG(cAlias,nOpcx,if(nOpcx = 4,aColsRec,""),if(nOpcx = 4,aColsAnt,""),aCols)
				If nOpcx = 3
					lGpea320Inc	:= .T. 		
				EndIf
				//--Processa Gatilhos
				EvalTrigger()
			End Transaction
		EndIf
		Exit
	EndDo
	
	//-- Restaura o filtro RCB utilizando a funcao FilBrowse       
	Eval(bFiltraBrw)
	
	//-- Restaura Area e Ordem de Entrada                           
	RestArea( aArea )
	RestArea( aAreaRCC)           
	RestArea( aAreaRCB)

Return( Nil )

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³Gpe320Exc ³ Autor ³ R.H. -  Natie         ³ Data ³ 23/05/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Exclusao                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ Gpe300Excl(cAlias,nReg,nOpca)                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cAlias= Alias do arquivo                                   ³±±
±±³          ³ nREg  = Numero do registro                                 ³±±
±±³          ³ nOpca = Numero da opcao selecionada                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ Gen‚rico 												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
User Function xTIxBRWE(cAlias,nReg,nOpcx,aAcho,aCpos,nColMens,cMensagem,cTudoOk)
Local nOpca			:= 0
Local nCnt			:= 0
Local aArea			:= GetArea()
Local aKeys			:=GetKeys() 
Local aAreaRCC		:= RCC->( GetArea() )
Local aAreaRCB		:= RCB->( GetArea() )
Local a320nField 	:= {}
Local aColsRec		:= {}  		    	
Local aColsAnt		:= {}
Local cCond			:= ""
Local cChave        := ""
Local cPict		    := "99"
Local oFont
Local oDlgMain
// Variaveis dimensoes do objeto tela 
Local aAdvSize		:= {}
Local aInfoAdvSize	:= {}
Local aObjSize		:= {}
Local aObjCoords	:= {}
Local aAdv1Size		:= {}
Local aInfo1AdvSize	:= {}
Local aObj1Size		:= {}
Local aObj1Coords	:= {}

Private cCodigo 	:= CriaVar("RCB_CODIGO")
Private cDescri		:= CriaVar("RCB_DESC")
Private cFilTab    	:= CriaVar("RCC_FIL")  
Private cChavRCC	:= CriaVar("RCC_CHAVE")
Private nOpcao 		:= nOpcx
Private oGet
Private oCodigo
Private oDescri
Private oFil
Private oChave
Private oGroup1
Private oGroup2
	
	// Monta as Dimensoes dos Objetos         				
	aAdvSize		:= MsAdvSize()
	aInfoAdvSize	:= { aAdvSize[1] , aAdvSize[2] , aAdvSize[3] , aAdvSize[4] , 5 , 5 }
	aAdd( aObjCoords , { 000 , 028 , .T. , .F. } )
	aAdd( aObjCoords , { 000 , 000 , .T. , .T. } )
	aObjSize		:= MsObjSize( aInfoAdvSize , aObjCoords )
		
	aAdv1Size		:= aClone(aObjSize[1])
	aInfo1AdvSize	:= { aAdv1Size[2] , aAdv1Size[1] , aAdv1Size[4] , aAdv1Size[3] , 1 , 1 }
	aAdd( aObj1Coords , { 070 , 000 , .F. , .T. } )
	aAdd( aObj1Coords , { 000 , 000 , .T. , .T. } )
	aObj1Size		:= MsObjSize( aInfo1AdvSize , aObj1Coords,,.T. )
	
	// Campos Nao editaveis                                
	a320nField	    := {"RCC_FILIAL","RCC_CODIGO","RCC_CONTEU"}
	
	cFilRCB		    := RCB->RCB_FILIAL
	cCodigo		    := RCB->RCB_CODIGO
	cDescri		    := RCB->RCB_DESC
	
	cAlias		:= "RCC"               
	DbSelectArea(cAlias)
	dbSetOrder(1)
	dbSeek( xFilial(cAlias)+ cCodigo )
	If RCC->( Eof() )
		Help(" ",1,"A320NPAR")	// "Nao existem lancamentos para esta tabela."
		Return 
	EndIf
	
	If cPaisLoc == "BRA" .and. cCodigo == "S046"
		MsgAlert(OemToAnsi("Não é possível efetuar a exclusão da tabela de códigos de movimentação"), OemToAnsi("Atencao"))	// "Não é possível efetuar a exclusão da tabela de códigos de movimentação"###"Atencao"
		Return
	EndIf   
	
	// Deleta o filtro utilizando a funcao FilBrowse       
	EndFilBrw("RCB",aIndexRCB)
	aIndexRcb := {} 
	
	// Monta a entrada de dados do arquivo                 
	cCond	:= "RCC_FILIAL+ RCC_CODIGO"
	cChave	:= xFilial("RCC")+ cCodigo
	aHeader	:= gp320aHead(a320nField,cAlias) 							        	    
	aCols	:= gp320aCols(a320nField,cAlias,cCond,cChave,nOpcx,@aColsRec,@aColsAnt)   
	
	DEFINE FONT oFont  NAME "Arial" SIZE 0,-11 BOLD
	
	SetaPilha()
	
		DEFINE MSDIALOG oDlgMain TITLE OemToAnsi( cCadastro ) FROM aAdvSize[7],0 TO aAdvSize[6],aAdvSize[5] OF oMainWnd PIXEL
			
			@ aObj1Size[1,1] , aObj1Size[1,2] GROUP oGroup1 TO aObj1Size[1,3] ,aObj1Size[1,4]  LABEL OemToAnsi("Codigo da Tabela") OF oDlgMain PIXEL  // "Codigo da Tabela"
			oGroup1:oFont:= oFont
			@ aObj1Size[2,1] , aObj1Size[2,2] GROUP oGroup2 TO aObj1Size[2,3] ,aObj1Size[2,4] LABEL OemToAnsi("Descricao"	) OF oDlgMain PIXEL   // "Descricao"	
			oGroup2:oFont:= oFont
	
			@ aObj1Size[1,1]+12 , aObj1Size[1,2]+10      SAY cCodigo SIZE 050,10 OF oDlgMain PIXEL FONT oFont
		 	@ aObj1Size[2,1]+12 , aObj1Size[2,2]+10 SAY cDescri SIZE 120,10 OF oDlgMain PIXEL FONT oFont 
			
			oGet := MSGetDados():New(aObjSize[2,1],aObjSize[2,2],aObjSize[2,3],aObjSize[2,4],nOpcx,"",,,,,,,999999 ) 
	
		ACTIVATE MSDIALOG oDlgMain ON INIT EnchoiceBar(oDlgMain,{|| nOpca := 1,oDlgMain:End(),.F. },{||oDlgMain:End()},,,nOpcx ) CENTERED
	
	SetaPilha()
	
	If nOpcA == Confirma  .and. nOpcx = 5  //-- Confirma Exclusao 
		Begin Transaction
		// Exclusao na RCC
			dbSelectArea( "RCC" )
			dbSetOrder(1)   
			If dbSeek( cFilRCB + cCodigo )
				While cFilRCB + cCodigo == RCC->RCC_FILIAL+RCC->RCC_CODIGO .And. !Eof()
					RecLock("RCC",.F.,.T.)
					dbDelete()
					MsUnlock()
					DbSkip()
				EndDo
			EndIf
		End Transaction
	Endif
	
	// Restaura o filtro RCB utilizando a funcao FilBrowse       
	Eval(bFiltraBrw)
	
	// Restaura Area e Ordem de Entrada                           
	RestArea( aArea )
	RestArea( aAreaRCC)                      
	RestArea( aAreaRCB)

Return( Nil )


/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³gp320Grava³ Autor ³ Natie                 ³ Data ³ 27/06/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Grava no arquivo de Parametros                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ gp320Grava                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
User Function xTIxBRWG(cAlias,nOpcx,aColsRec,aColsAnt,aCols)
Local nPosCha 	:= 	GdFieldPos("RCC_CHAVE")        
Local nPosFil	:= 	GdFieldPos("RCC_FIL")     
Local nPosSeq	:= 	GdFieldPos("RCC_SEQUEN")
Local nMaxArray	:=	Len(aHeader) 
Local nX 		:= 	0
Local nY 		:= 	0
Local nCntDel   :=  0 
Local nRecno	:=  0.00
Local aChaves   := {}
Local xConteudo	:= 	""  
Local cChave 	:=  "" 
Local nSeq      := 0     
Local nTam      := TAMSX3("RCC_SEQUEN")[1] 
	
	nUsado 	:= Len(aHeader) 
	
	dbSelectArea(cAlias)         
	
	If Len(aColsRec) <> 0 .Or. !Empty(aCols)
	
	 	If !fCompArray( aCols , aColsAnt )    
			
		   	// Apaga a tabela que esta na memoria - sempre trata como inclusao
		   	For nRecno := 1 To Len(	aColsAnt )
				RCC->( dbGoto( aColsRec[ nRecno ] ) )
				RecLock( "RCC" , .F. , .F. )
				RCC->( dbDelete() )
				RCC->( MsUnLock() )	
			Next nRecno
				
			// Quantidade de Linhas Deletadas
			For nX := 1 to Len(aCols) 
				If aCols[nX][Len(aCols[nX])] 
					If lAnoMes
						cChave := aCols[ nX,nPosFil]+aCols[nX,nPosCha]
					Else
						cChave := aCols[ nX,nPosFil]					
					EndIf
					If aScan(aChaves,{|x|x == cChave}) == 0
						nCntDel++  
						Aadd(aChaves,cChave)
					End
				EndIf
			Next nX					
			// Reordena sequencia da tabela quando houver linhas deletadas
			If nCntDel > 0 
				For nX := 1 to Len(aChaves)    
					nSeq := 0 
					For nY := 1 to Len(aCols)
					    If  aChaves[nX] == aCols[ nY,nPosFil]+ If(lAnoMes,aCols[nY,nPosCha],"")  .And.  !( aCols[nY][Len(aCols[nY])] )
							nSeq++
							aCols[nY,nPosSeq] := PADL(cValtoChar(nSeq), nTam, "0")
						EndIf				 
					Next nY
				Next nX			
			EndIf   
			
			// Efetua Gravacao		
			For nX	:=	1 to Len(aCols)
				If aCols[nX,nUsado+1]  = .F.
					RCC->( RecLock(cAlias,.T.,.T.) )			// Inclusao
					RCC->RCC_FILIAL 	:= xFilial(cAlias)
					RCC->RCC_CODIGO 	:= cCodigo
				   If lAnoMes
						RCC->RCC_CHAVE		:= Substr(aCols[nX,nPosCha],3,4) + Substr(aCols[nX,nPosCha],1,2)
					EndIf
					RCC->RCC_FIL  		:= aCols[nX,nPosFil]
					RCC->RCC_SEQUEN		:= aCols[nX,nPosSeq]
					// Grava  os Campos definidos no RCB no campo RCC_CONTEU
						For nY := If(lAnoMes,4,3) To nMaxArray
							cCampo    := Trim(aHeader[nY][2])
							xConteudo += a320Transf(aCols[nX,nY],aHeader[nY][8],aHeader[nY][4],aHeader[nY][5])
						Next ny 
					RCC->RCC_CONTEU := xConteudo
					// Reinicia variavel
					xConteudo	:= ""
					RCC->( MsUnlock() )
				EndIf	
	   		Next nX
		EndIf    		
	EndIf
Return  

/*
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ a320Transf ³ Autor ³ Natie               ³ Data ³ 27/06/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Retorna tipo de conteudo.                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ GPEA320                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function a320Transf(xCampo,cTipo,nTam,nDecima)

	If cTipo = "C"
		//cCampo := Upper(xCampo) 
		cCampo := Padr(Upper(xCampo),nTam)		
	ElseIf cTipo = "N"
		cCampo := Str(xCampo,nTam,nDecima)
	ElseIf cTipo = "D"
		cCampo := DTOS(xCampo)
	EndIf    

Return ( cCampo )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³gp320aHeadºAutor  ³Ricardo             º Data ³  17/05/01   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funcao gp320aHead() - Monta o array de header - SRB        º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP6                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function gp320aHead(aFields,cAlias)
Local aRetorno 	:= {}											
Local aExclRCB  := { 'RCB_FILIAL','RCB_CODIGO','RCB_DESC'} 		
Local aExclRCC	:= { 'RCC_FILIAL','RCC_CODIGO','RCC_CONTEU'}
Local aArea		:= GetArea()
Local aSX3Area	:= SX3->(GetArea()) 
Local cValid
	
Private aHeader := {}
Private nUsado	:= 0
	
	// Aadd(aFields, "RCC_CHAVE"	      
	// Monta array dos campos do arquivo de pesquisa.	  
	dbSelectArea( 'SX3' )
	SX3->( dbSetOrder(1) )
	dbSeek( 'RCC' )
	Do While !Eof() .and. ( x3_arquivo == 'RCC' )
		If x3uso(x3_usado) .AND. cNivel >= x3_nivel .and.;
			ASCAN(aExclRCC,{ |x| x == Trim(x3_campo) } ) == 0
			If !lAnoMes .AND. AllTrim(x3_campo) == "RCC_CHAVE"
				dbSkip()
			EndIf
			nUsado ++
			Aadd(aHeader,{ Trim(x3_titulo), x3_campo  , x3_picture,;
								x3_tamanho , x3_decimal, x3_valid  ,;
								x3_usado   , x3_tipo   , x3_F3,;
								x3_context } )
			If AllTrim(X3_Campo) == "RCC_CHAVE" .And. cPaisLoc == "BRA" .And. cCodigo == "S033"
				cValid := 'iIf( !Empty(Substr(M->RCC_CHAVE,1,2) ) , ENTRE( "01","13",Substr(M->RCC_CHAVE,1,2) ) ,.t.)'
				aHeader[len(aHeader),6] := if(!empty(cValid),cValid+" .and. ",cValid)+ "Gp320Mov( .T. )"			
			ElseIf AllTrim(x3_campo) == "RCC_CHAVE"
				cValid := AllTrim(aHeader[Len(aHeader),6])
				aHeader[Len(aHeader),6] := If(!Empty(cValid),cValid+" .and. ",cValid)+ "Gp320Mov( .T. )"
			EndIf	
		EndIf		
		dbSkip()
	EndDo
	
	dbSelectArea("RCB")
	RCB->( dbSetOrder(1) )
	If !dbSeek( xFilial(cAlias) + cCodigo ,.F.)
		MsgAlert(OemToAnsi("Nao existe esta tabela para a Empresa/Un.Negocio/Filial selecionada !"), OemToAnsi("Atencao"))	// "Nao existe esta tabela para a Empresa/Un.Negocio/Filial selecionada !"###"Atencao"
		aHeader := {}
	EndIf
	Do While !Eof() .and. xFilial("RCB")+ cCodigo  = ( RCB->RCB_FILIAL + RCB->RCB_CODIGO )
			nUsado ++                                               
							
			Aadd(aHeader,{  Trim(RCB_DESCPO),RCB_CAMPOS ,RCB_PICTUR,;
						    RCB_TAMAN        ,RCB_DECIMA ,RCB_VALID ,;
							'X'              ,RCB_TIPO   ,RCB_PADRAO,;
							' '} )
					
		dbSkip()
	EndDo
	
	// Restaura Area e Ordem de Entrada        
	RestArea( aSX3Area )
	RestArea( aArea ) 
	
Return ( aHeader )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Gp320aCols³ Autor ³ Natie                 ³ Data ³ 21/06/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Criar os Arrays do aCols dos arquivos                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Gpea320                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Gp320aCols(aFields,cAlias,cCond,cChave,nOpcx,aColsRec,aColsAnt)
Local cAnoMes	:= ""
Local nCntFor 	:= 0
Local nAcols  	:= 0
Local nusar 	:= 0          
Local nTamCpo	:= 0
Local nPosicao  := 0
Local aArea		:= GetArea()
Local aConteu	:= {"RCC_FILIAL","RCC_CODIGO","RCC_FIL","RCC_CHAVE","RCC_SEQUEN"}   // Array com  os campos que estao fora do conteudo 
Local nPosDum   := 0
Local nCnt      := 0
Private nUsado	:= Len(aheader)
Private aCols   := {}
	
	// Quando for Inclusao criar com 1 elemento
	If nOpcx == 3
		nCnt  := 1
		aCols := Array( nCnt , nUsado+1 )
	EndIf
	If !lAnoMes // SE COLUNA MES/ANO NÃO FOR EXIBIDA ADICIONA RCC_CHAVE COMO CAMPO NAO EDITAVEL
		Aadd(aFields,"RCC_CHAVE")
	EndIf
	dbSelectArea(cAlias)
	If dbSeek(cChave) .and. nOpcx # 3
		While !Eof() .And. &cCond == cChave
			Aadd(aCols,Array(nUsado+If(nOpcx#1,1,0)))
			nAcols 		:= Len(aCols)     
			nPosicao	:= 1
			cConteu	:= FieldGet(FieldPos( "RCC_CONTEU" ) )
			cAnoMes	:= FieldGet(FieldPos( "RCC_CHAVE" ) )
			For nCntFor := 1 To Len(aHeader)
				nTamCpo	:= aHeader[nCntFor][4]  		// Tamanho do Campo
				cCampo  := Trim(aHeader[nCntFor][2])
							
				If	ASCAN(aConteu,{ |x| x == cCampo } ) > 0                          
				   	If cCampo == "RCC_CHAVE"
				   		// Carrega como Mes/Ano 
						aCols[nAcols][nCntFor] := Substr(cAnoMes,5,2) + substr(cAnoMes,1,4)
	 				Else
						aCols[nAcols][nCntFor] := FieldGet(FieldPos(aHeader[nCntFor][2]))
					EndIf	
				Else
					If nCntFor == 9
						nCntFor := 9
					EndIf		
					// Carrega o conteudo do RCC_CONTEU na aCols
					If aHeader[nCntFor,8] = "C"						// Tipo Caracter
						aCols[nAcols][nCntFor] := Substr(cConteu,nPosicao,nTamCpo)
					ElseIf  aHeader[nCntFor,8] = "N"				// Tipo Numerico
						aCols[nAcols][nCntFor] := VAL( Substr(cConteu,nPosicao,nTamCpo) )
					ElseIf aHeader[nCntFor,8] = "D"					// Tipo Data
						aCols[nAcols][nCntFor] := Stod(Substr(cConteu,nPosicao,nTamCpo) )
						If Empty(Stod(Substr(cConteu,nPosicao,nTamCpo) )) .And. nCntFor == Len(aHeader)
							nTamCpo := nTamCpo + 2 // CONSIDERA AS DUAS "/" CASO TENHA GRAVADO EM BRANCO
						EndIf
					EndIf                                                                
					nPosicao	+= nTamCpo
				EndIf
			Next nCntFor
			If nOpcx # 1
				aCols[nAcols][nUsado+1] := .F.
			EndIf
			dbSelectArea(cAlias)
			Aadd(aColsRec,Recno())
			dbSkip()
		EndDo
	ElseIf nOpcx == 3
		// Posiciona ponteiro do arquivo cabeca e inicializa variaveis  
		dbSelectArea("SX3")
		dbSetOrder(1)
		dbSeek(cAlias) //-- RCC
		nUsado:= 0
		// aFields:= {"RCC_FILIAL","RCC_CODIGO","RCC_CONTEU"} campos nao editaveis no aCols
		While !Eof() .And. (x3_arquivo == cAlias)
			If x3uso(x3_usado) .AND. cNivel >= x3_nivel .and. AScan(aFields,{|x| x == Trim(x3_campo)}) == 0
				nUsado++
				// Monta Array do 1§ Elemento Vazio. Se Inclusao                
				If x3_tipo == "C"
					aCols[1][nUsado] := Space(x3_tamanho)
				ElseIf x3_tipo == "N"
					aCols[1][nUsado] := 0
				ElseIf x3_tipo == "D"
					aCols[1][nUsado] := CTOD("  /  /  ")
				EndIf
			Endif                 
			dbSkip()
		EndDo
		dbSelectArea("RCB")
		dbSetOrder(1)
		dbSeek( cChave )
		While !EoF() .and.  cChave = xFilial("RCB") + RCB->RCB_CODIGO
		    nUsado ++ 
			//-- Monta Array do 1§ Elemento Vazio utilizando RCB              
			If RCB_TIPO = "C"
				aCols[1][nUsado] := Space(RCB_TAMAN)
			ElseIf RCB_TIPO = "N"
				aCols[1][nUsado] := 0
			ElseIf RCB_TIPO = "D"
				aCols[1][nUsado] := CTOD("  /  /  ")
			Else
				aCols[1][nUsado] := .F.
			EndIf
			RCB->( dbSkip() )
		Enddo
		aCols[1,nUsado+1] := .F.
	Endif
	
	If cCodigo == "S119"
	    //a remoção desta coluna so foi possivel por se tratar da "ultima" coluna do browse.
	    //caso contrario, devido ao sistema gravar todos os dados concatenados em um unico campo da RCC
	    //seria preciso rodar uma re-estruturação dos dados da S119 gravados na RCC!
		nPosDum	:=	Ascan(aHeader,{|x| AllTrim(x[2]) == "CTRDEF"})
		If nPosDum > 0 .And. Len(aHeader) == nPosDum //confirmo se é ultima coluna mesmo
			aDel(aHeader,nPosDum)
			aSize(aHeader,Len(aHeader)-1)
			
			For nCnt := 1 to Len(aCols)	
				aDel(aCols[nCnt],nPosDum)
				aSize(aCols[nCnt],Len(aCols[nCnt])-1)
			Next
		Endif

		If IsInCallStack("Gpe320Alt")
			For nCnt := 1 to Len(aHeader)	
				If Alltrim(aHeader[nCnt][2]) != "COD" .And. Alltrim(aHeader[nCnt][2]) != "RCC_SEQUEN" 
					Aadd(aAlter119,aHeader[nCnt][2])
				EndIf
			Next
		EndIf
	EndIf
	
	If cCodigo == "S120"
		If IsInCallStack("Gpe320Alt")
			For nCnt := 1 to Len(aHeader)	
				If Alltrim(aHeader[nCnt][2]) != "COD" .And. Alltrim(aHeader[nCnt][2]) != "RCC_SEQUEN" 
					Aadd(aAlter119,aHeader[nCnt][2])
				EndIf
			Next
		EndIf
	EndIf
	
	aCols[1][GdFieldPos("RCC_SEQUEN")] := '001' // Inicia Ordem com 1
	
	// Quando for Alteracao copia o vetor aCols
	If nOpcx == 4
		aColsAnt := aClone(aCols)
	EndIf
	
	aColsBkp := aClone(aCols)
	nBkp     := Len(aColsBkp)
	RestArea( aArea )

Return ( aCols )
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³gp320LinOk³ Autor ³ Natie                 ³ Data ³ 01/07/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Critica linha digitada                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
User Function xTIxBLio(o)
			              
Local lTudoOk  	:= .T.
Local nX		:= 0
Local nPosSeq	:= GdFieldPos("RCC_SEQUEN")
Local nPosCha 	:= GdFieldPos("RCC_CHAVE")
Local nPosFil	:= GdFieldPos("RCC_FIL")   // Posicao Campo Filial da tabela no Acols
Local nPosAux	:= 0
Local nUsado	:= Len(aHeader)
Local nUsaCols  := 0
Local cChaveGet	:= ""
Local aCopyCols	:= aClone(aCols)			
Local lEmpty	:= .T.
Local lCriticar := .F.
Local nIndice   :=  0
Local nY        :=  0
	
	nUsaCols  := Len(aCols)                                                        
	If lAnoMes
		cChaveGet := cFilRCC+ cCodigo + aCopyCols[ n,nPosFil]+ aCopyCols[n,nPosCha]+ aCopyCols[n,nPosSeq]
	Else
		cChaveGet := cFilRCC+ cCodigo + aCopyCols[ n,nPosFil]+ aCopyCols[n,nPosSeq]
	EndIf	
	// Verifica se tem alguma coluna preenchida alem da chave
	For nX := 1 to Len(aCopyCols[n])
	    If nX == nPosFil .or. nX == nPosCha .or. nX == nPosSeq .or.;
	      (nX ==(nUsado+1) .and. aCopyCols[n,nX]==.F.)  
	    	Loop
	    EndIf
	    
	    lEmpty := Empty(aCopyCols[n,nX])
	    If !lEmpty	
	    	Exit
	    EndIf	 	
	Next

	If lEmpty
	Aviso("Atencao","Preencha os dados da tabela.",{'OK'}) //"Atencao" ##"Preencha os dados da tabela."
		lTudoOk := .F.
	Else     
		If cCodigo == "S033" .And. !aCopyCols[n,Len(aCopyCols[n])]  
			If Empty(aCopyCols[n,1])
				Aviso("Atençäo !","Campo 'Filial' não pode estar vazio",{"OK"}) //Atençäo ! ## "Campo 'Filial' não pode estar vazio"
				Return(.F.)
			EndIf
			If Empty(aCopyCols[n,2])
				Aviso("Atençäo !","Campo 'Mês/Ano' não pode estar vazio",{"OK"}) //Atençäo ! ## "Campo 'Mês/Ano' não pode estar vazio"
				Return(.F.)
			EndIf
		EndIf
		If aCopyCols[n,nUsado+1]  = .F.  // Linha Incluida/Alterada
			If lAnoMes
				aSort( aCopyCols,,,{ |x,y,z| x[nPosFil] + x[nPosCha ] + x[nPosSeq] < y[nPosFil] + y[nPosCha] + y[nPosSeq]} )		//-- Ordena para acertar a sequencia
			Else
				aSort( aCopyCols,,,{ |x,y| x[nPosFil] + x[nPosSeq] < y[nPosFil] + y[nPosSeq]} )		//-- Ordena para acertar a sequencia
			EndIf
			
			If !IsInCallStack("gp320tudOk") .Or. Empty(aCopyCols[n,nPosSeq])
				// Muda a Sequencia da Tabela de acordo com  a chave            
				fPlusSeq(@aCopyCols,cChaveGet,nUsado) 
			EndIf
			
			RCB->(dbSetOrder(1))
			RCB->(dbSeek(xFilial("RCB")+cCodigo))
			While RCB->RCB_CODIGO == cCodigo .and. lTudoOk
				If !aCopyCols[n,Len(aCopyCols[n])]       
				
					If cPaisLoc == "BRA"  .And. cCodigo == "S119" 
						If !(Alltrim(RCB->RCB_CAMPOS) $ "REND3|ALIQ3|DED3|REND4|ALIQ4|DED4" .And. fDtIR34(aCopyCols[n]) )
							If Empty(aCopyCols[n,Val(RCB->RCB_ORDEM)+If(lAnoMes,3,2)])//coluna esta vazia
								
								lCriticar := .F.
								
								If Len(aHeader) >= ( Val(RCB->RCB_ORDEM)+If(lAnoMes,3,2) )
									
									If AllTrim( aHeader[Val(RCB->RCB_ORDEM)+If(lAnoMes,3,2)][2] ) == "TPAPD"
										lCriticar := .T.
									EndIf
									
									If lCriticar == .F. .And. AllTrim( aHeader[Val(RCB->RCB_ORDEM)+If(lAnoMes,3,2)][2] ) == "TPCTAPD"
										nIndice := Ascan(aHeader,{|x| AllTrim(x[2]) == "TPAPD"})
										
										If nIndice > 0
											If Alltrim(aCopyCols[n,nIndice]) != "0"
												lCriticar := .T.
											EndIf
										EndIf
									EndIf
									
								EndIf
								
								If lCriticar
									lTudoOk := .F.
									Aviso("Atencao","O campo "+ AllTrim(RCB->RCB_DESCPO) +"nao pode estar vazio.",{ "OK" })// "Atencao"###"O campo "###""nao pode estar vazio."
								EndIf
								
							EndIf
						EndIf
					EndIf

					If "NAOVAZIO" $ UPPER(RCB->RCB_VALID) // Se o campo estiver vazio e tiver validacao NAOVAZIO, exibe mensagem com descricao do campo
						If !(Alltrim(RCB->RCB_CAMPOS) $ "REND3|ALIQ3|DED3|REND4|ALIQ4|DED4" .And. fDtIR34(aCopyCols[n]) )
							If Empty(aCopyCols[n,Val(RCB->RCB_ORDEM)+If(lAnoMes,3,2)])
								lTudoOk := .F.
								Aviso("Atencao","O campo "+ AllTrim(RCB->RCB_DESCPO) +"nao pode estar vazio.",{ "OK" })// "Atencao"###"O campo "###""nao pode estar vazio."
							EndIf
						EndIf
					EndIf
					If "FMSGFORM" $ UPPER(RCB->RCB_VALID) .AND. "1=1" $ UPPER(RCB->RCB_VALID) //--HAVER
						If Empty(aCopyCols[n,Val(RCB->RCB_ORDEM)+If(lAnoMes,3,2)])
							lTudoOk := &(RCB->RCB_VALID)
						EndIf
					EndIf
					If !Empty( aCopyCols[n,nPosFil] )
						If !ExistCpo("SM0", cEmpAnt + aCopyCols[n,nPosFil] )
							If aScan( aCargFil, {|aCargFil| aCargFil[2] == aCopyCols[n,nPosFil] } ) == 0
								lTudoOk := .F.
								Aviso("Atençäo !","Filial inválida. Verifique o código informado.",{"OK"}) //Atençäo ! ## "Filial inválida. Verifique o código informado."
								Exit
							EndIf
						EndIf
					EndIf
				EndIf
				
				If cPaisLoc == "BRA"  .And. cCodigo == "S119" 
					If empty(aCols[n,06]) .and. !empty(aCols[n,07])       
						lTudoOk := .F.
						Aviso("Campo Tipo de Ponto", "O Tipo de Registro de ponto deve ser informado apenas para os tomadores", {"OK"}) //Campo Tipo de Ponto //O Tipo de Registro de ponto deve ser informado apenas para os tomadores 
						Exit      
					EndIf
				EndIf
							
				RCB->(DbSkip())		
			EndDo	

			If Empty(aCopyCols) 
				aCols := {}
				Eval(oGet:oBrowse:badd)
			Else	
				aCols	:= aClone(aCopyCols)
			EndIf	                  	
	
			oGet:oBrowse:nAt 	:= n
			oGet:oBrowse:Refresh(.T.)
	
		Else  // Linha deletada
			//Validacao especial pro Brasil (Beneficios) - Apenas para a Tabela S018
			If  aCopyCols[n,nUsado+1]  == .T. .And. cPaisLoc == "BRA"  .And. cCodigo == "S018" .And. aCopyCols[n,4] <= "004"
				Aviso("Atencao", "Nao e possivel eliminar os fornecedores padroes.", {"OK"}) // "Atencao"###""Nao e possivel eliminar os fornecedores padroes."
				Return(.F.)
			EndIf
			If cCodigo == "S046"
				//Nao permite que codigos gerados sejam excluidos
				nPosAux := GdFieldPos("BRA_S04601")
				If aCopyCols[n,nPosAux] $ "01|02|03|04|05|06|07|08|09|10|11|12|13|14|15|16|17|18|19|20|21|22|23|24|25|26|27|28|29|30|31|32|33"
					Alert("Não é possível efetuar a exclusão dos códigos de movimentação padrões")  // ###"Não é possível efetuar a exclusão dos códigos de movimentação padrões"
					Return(.F.)
				EndIf				
			EndIf
			
			If cPaisLoc == "BRA"  .And. cCodigo $ "S017|S016" .And. Empty(aCopyCols[n,6])
				If !lMsg
					Aviso("Atencao","O campo 'CNPJ Fornecedor' nao pode estar vazio.",{ "OK" }) // "O campo 'CNPJ Fornecedor' nao pode estar vazio."
					lMsg := .T.
				EndIf
				Return(.F.)
			EndIf
			
			If cPaisLoc == "BRA"  .And. cCodigo == "S018" .And. (Empty(aCopyCols[n,6]) .Or. Empty(aCopyCols[n,7]))
				If !lMsg
					Aviso("Atenção!", "Os campos Código do Cliente e Empresa Resp. não podem ficar em branco!",{ "OK" }) // "Os campos Código do Cliente e Empresa Resp. não podem ficar em branco!"
					lMsg := .T.
				EndIf
				Return(.F.)
			EndIf

			If lAnoMes
				aSort( aCopyCols,,,{ |x,y,z| x[nPosFil] + x[nPosCha ] + x[nPosSeq] < y[nPosFil] + y[nPosCha] + y[nPosSeq]} )		//-- Ordena para acertar a sequencia
			Else
				aSort( aCopyCols,,,{ |x,y| x[nPosFil] + x[nPosSeq] < y[nPosFil] + y[nPosSeq]} )		//-- Ordena para acertar a sequencia
			EndIf
			//Muda a Sequencia da Tabela de acordo com  a chave            
	   	  	fPlusSeq(@aCopyCols,cChaveGet,nUsado)
	
			If Empty(AcopyCols)
				aCols := {}
				Eval(oGet:oBrowse:badd)
			Else	
				aCols	:= aClone(aCopyCols)
			EndIf	                  	
	
			oGet:oBrowse:nAt 	:= n
			oGet:oBrowse:Refresh(.T.)
			fAtualizaBkp2()
	
			SX3->( DbSelectArea("SX3") )
			SX3->( DbSetOrder(1) )
			If SX3->( DbSeek("RG1") )
	
	   			If !fExcluirOk2()
					aCols[n,nUsado+1] := .F.
					lTudoOk := .F.
					Alert("Exclusao negada. Existe um ou mais lancamentos fixos para esta Tabela, Linha e Coluna.")  // ###"Exclusao negada. Existe um ou mais lancamentos fixos para esta Tabela, Linha e Coluna."
				EndIf		
	
			EndIf
		EndIf
	
		oGet:oBrowse:nAt 	:= n
		oGet:oBrowse:Refresh(.T.)
		
	EndIf              
	

	If cPaisLoc == "BRA"  .And. cCodigo == "S119"  .And. Type("lFimTdOk") == "L"
	
		If  lTudoOk .And. lFimTdOk 
			nIndice := Ascan(aHeader,{|x| AllTrim(x[2]) == "TPCON"})
			
			If nIndice > 0			
				For nX := 1 to Len(aCopyCols)
					If aCopyCols[nX,nUsado+1]  = .F.  // Linha Incluida/Alterada
						If !Empty (aCopyCols[nX, nIndice ] ) 
							nY += 1
			
							If nY > 1
								Aviso("Atençäo !","Filial inválida. Verifique o código informado.",{"OK"}) //Atençäo ! ## "Filial inválida. Verifique o código informado."
								lTudoOk := .F.
								Exit
							EndIf
						EndIf
					EndIf
				Next
			EndIf
			
		EndIf
	EndIf

	If lTudoOk == .T.
		lGpea320Inc := .T.
	EndIf

Return ( lTudoOk )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ 
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³gp320TudoOk³ Autor ³ Natie                ³ Data ³ 25/06/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Monta as getdados dos arquivos                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 : Alias                                              ³±±
±±³          ³ ExpN1 : Registro                                           ³±±
±±³          ³ ExpN2 : Opcao                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³GPEA160                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
User Function xTIxBTOK(o)
                   
Local lTudoOk  := .T.

lTudoOk := U_xTIxBLio()
Return lTudoOk

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ fUseCor  | Autor ³                       ³ Data ³          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ gpea320                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Static Function fUsecor()
	Local aMarks :=	{;
				{ "Substr(RCB->RCB_CODIGO,1,1)=='U'" , "BR_VERDE"	},;
				{ "Substr(RCB->RCB_CODIGO,1,1)=='S'" , "BR_AZUL"	},;
				{ "Substr(RCB->RCB_CODIGO,1,1)=='A'" , "BR_PRETO"	};				
					 }
					 
Return aMarks

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ Gpe320Lg | Autor ³                       ³ Data ³          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Legenda de Cores                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ gpea260                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
User Function xTIxBRWL ()
	Local aLegenda := {;
				{ "BR_AZUL"  , OemToAnsi( "Tabela da Totvs" ) } ,; //"Tabela Definida Pela Microsiga"
				{ "BR_VERDE" , OemToAnsi( "Tabela de Usuario"  ) } ,; //"Tabela Definida Pelo Usuario" 
				{ "BR_PRETO" , OemToAnsi( "Tabela comum a todos os países" ) }  ; //"Tabela comum a todos os países"
						}

	BrwLegenda(	cCadastro ,	oEmToAnsi("Legenda do Cadastro de Paramentros") , aLegenda )			 //Legenda do Cadastro de Paramentros
Return NIL

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³fCopia    | Autor ³                       ³ Data ³          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³efetua copia do registro atual                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ gpea320                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
User Function fCopia()

Local aCopyTab	:= {}

//Copia Linha inteira 
Return aCopyTab	:= ( aClone( aCols[ n ] ) )

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³fColar    | Autor ³                       ³ Data ³          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Cola registro na posicao atual                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ gpea320                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
User Function fColar(aCopyTab,lLinha)
DEFAULT lLinha 	:= .t.

IF !Empty( aCopyTab )
	If  lLinha 
		aCols[n] := aClone( aCopyTab )
	Else	
		aCols[n,2] := aCopytab[2]
		aCols[n,3] := aCopytab[3]
		aCols[n,4] := aCopytab[4]
		aCols[n,5] := aCopytab[5]
		aCols[n,6] := aCopytab[6]
		aCols[n,7] := aCopytab[7]
		aCols[n,8] := aCopytab[8]
		aCols[n,9] := aCopytab[9]
		aCols[n,10]:= aCopytab[10] 
    Endif
    oGet:oBrowse:Refresh(.T.)
EndIF


Return (nil)
/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³fPlusSeq  | Autor ³Natie                  ³ Data ³ 30/08/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Controla a Sequencia de acordo com  a Chave digitada        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ gpea320                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
User Function  fPlusSeq(aAux,cChaveAux,nUsado)

Local cSeq		:= ""  			//-- Variavel sequencia
Local cSeqIni	:= "001"
Local nLin 		:= 0
Local nPosCha 	:= GdFieldPos("RCC_CHAVE") //-- Posicao Campo chave no Acols
Local nPosFil	:= GdFieldPos("RCC_FIL")   //-- Posicao Campo Filial da tabela no Acols
Local nPosSeq	:= GdFieldPos("RCC_SEQUEN")//-- Posicao Campo Sequencia no aCols 
Local nTamChave	:= 0
Local nIniChave := 0 
Local nFimChave := 0

Local aString	:= {}
Local nX

//cChaveGet	:= cFilRCC+ cCodigo + aCopyCols[ n,nPosFil]+ aCopyCols[n,nPosCha]+ aCopyCols[n,nPosSeq]

nTamChave 		:= GetSx3Cache("RCC_FILIAL", "X3_TAMANHO") + GetSx3Cache("RCC_CODIGO", "X3_TAMANHO") + GetSx3Cache("RCC_FIL", "X3_TAMANHO") + GetSx3Cache("RCC_CHAVE", "X3_TAMANHO")
For nLin := 1 To Len(aAux)
	cString :=  cFilRCC+cCodigo + aAux[nLin,nPosFil] + aAux[nLin,nPosCha]
	If Len(cString) > 0 .and. substr(cChaveAux,1,nTamChave) == cString
		Aadd(aString,{cString,aAux[nLin,nPosSeq]})
	Endif
Next          

nIniChave := GetSx3Cache("RCC_FILIAL", "X3_TAMANHO") + GetSx3Cache("RCC_CODIGO", "X3_TAMANHO") +1
nFimChave := GetSx3Cache("RCC_FIL", "X3_TAMANHO") + GetSx3Cache("RCC_CHAVE", "X3_TAMANHO")
If (nPos:=(Ascan(aAux,{|x| x[1]+x[2]= substr(cChaveAux,nIniChave,nFimChave)}))) >0
	//-- procura a ultima sequencia da chave
	For nLin := nPos to len(aString)
		If aAux[nLin,nPosFil]+ aAux[nLin,nPosCha]==substr(cChaveAux,nIniChave,nFimChave) .and. aAux[nLin,nUsado+1] == .F.
			cSeq	:= aString[nLin,2]
		Endif
	Next nLin
EndIF

nFimChave := GetSx3Cache("RCC_FIL", "X3_TAMANHO") + GetSx3Cache("RCC_CHAVE", "X3_TAMANHO") + GetSx3Cache("RCC_SEQUEN", "X3_TAMANHO")
If (nPos:=(Ascan(aAux,{|x| x[1]+x[2]+x[3]= substr(cChaveAux,nIniChave,nFimChave)}))) >0
	If Empty( aAux[nPos][nPosSeq] )
		aAux[nPos][nPosSeq]	:= Soma1(cSeq)
		aSort( aAux,,,{ |x,y,z| x[nPosFil] +x[nPosCha ]+x[nPosSeq] < y[nPosFil]+y[nPosCha]+y[nPosSeq]} )		//-- Ordena para acertar a sequencia
   	EndIF
EndIF
cSeq 	:= "000"	


nFimChave := GetSx3Cache("RCC_FIL", "X3_TAMANHO") + GetSx3Cache("RCC_CHAVE", "X3_TAMANHO")
//-- Implementa 001 na sequencia, caso nao tenha Sequencia registrada 
If (  nPos :=(Ascan(aAux,{|x| x[1]+x[2]= substr(cChaveAux,nIniChave,nFimChave).and. x[nUsado+1] = .F.}))  ) > 0 			//procura o registro a ser sequenciada
	For nX := nPos to Len(aAux)
		If aAux[nX,nPosFil]+ aAux[nX,nPosCha]==substr(cChaveAux,nIniChave,nFimChave) .and. aAux[nX,nUsado+1] ==.F.
			cSeq				:= Soma1(cSeq)
			aAux[nX][nPosSeq]	:= cSeq
		EndIF	
	Next	
Endif

aSort( aAux,,,{ |x,y,z| x[nPosFil] +x[nPosCha ]+x[nPosSeq] < y[nPosFil]+y[nPosCha]+y[nPosSeq]} )		//-- Ordena para acertar a sequencia
oGet:oBrowse:nAt := n
oGet:oBrowse:Refresh(.T.)
	  
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³GPEA320MovºAutor  ³Andreia dos Santos  º Data ³  13/11/02   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Movimenta o cursor para nao parar na coluna sequencia       º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP7                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function Gp320Mov( lMov )
         
Local ni		:= 0.00
Local nPosicao	:= 0.00
Local nPosTip	:= 0.00
Local nStep		:= 0.00
Local nPulos	:= 0.00
Local cCampo	:= cCampo := &(ReadVar())

DEFAULT lMov := .F.

If !lMov
	Return( .T. )
Endif

nPosTip		:= GdFieldPos( "RCC_CHAVE" )
nPosicao	:= GdFieldPos( "RCC_SEQUEN" )
nPosicao ++

nStep  := IF(nPosTip > nPosicao , -1 , 1)
nPulos := Abs( nPosicao - nPosTip )

If nStep > 0
	nPulos --
Else
	If nPostip != Len(aHeader)
		nPulos ++
	Endif
Endif

IF Alltrim(Substr(readvar(),4)) == "RCC_CHAVE"

	/*
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³Garante o Posicionamento na Coluna Chamadora da Funcao.       ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	While oGet:oBrowse:nColPos <> nPosTip
   		  IF oGet:oBrowse:nColPos > nPosTip
			  	oGet:oBrowse:GoLeft()
		  ElseIF oGet:oBrowse:nColPos < nPosTip
				oGet:oBrowse:GoRight()
		  EndIF
	End While

EndIF

For ni := 1 to nPulos
	If nStep > 0
		oGet:oBrowse:GoRight()
	Else
		oGet:oBrowse:GoLeft()
	Endif
Next

IF nPulos <= 0
	oGet:oBrowse:bEditCol:= { || Alwaystrue() }		
EndIF	

Return( .T. )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ fFiltroAsMed   ³ Autor: Kelly Soares     ³ Data ³ 02.12.05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna o filtro para a consulta "S008" de acordo com o    ³±±
±±³          ³ conteudo do campo TIPO ASS. MEDICA                         ³±±
±±³          ³ 1 = Faixa Salarial ...... Tabela S008                      ³±±
±±³          ³ 2 = Faixa Etaria   ...... Tabela S009	                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SXB = grupo "S008"                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
User Function fFiltroAsMed()

Local cTabela := If ( Empty(AllTrim(M->RA_TIPAMED)) , ;
				      "XXXX" , ;
 	                  If ( M->RA_TIPAMED == "1" , "S008" , "S009" ) )

Local cFiltro :=  &( "RCC->RCC_CODIGO="+CHR(34)+cTabela+CHR(34) )
    	    	             	             
Return cFiltro

/*                                	
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡„o    ³ MenuDef		³Autor³  Luiz Gustavo     ³ Data ³07/12/2006³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡„o ³Isola opcoes de menu para que as opcoes da rotina possam    ³
³          ³ser lidas pelas bibliotecas Framework da Versao 9.12 .      ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Sintaxe   ³< Vide Parametros Formais >									³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Uso      ³GPEA320                                                     ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Retorno  ³aRotina														³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³< Vide Parametros Formais >									³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/   
Static Function MenuDef()

Local aRotina := {}

  	aAdd( aRotina , { 'Pesquisar' , 'PesqBrw'     , 0 , 1})   			//'Pesquisar' 
  	aAdd( aRotina , { 'Visualizar', 'U_xTIxBRWA'  , 0 , 2})  			//'Visualizar'
  	aAdd( aRotina , { 'Incluir'   , 'U_xTIxBRWA'  , 0 , 3, , , .T.})  	//'Incluir'
  	aAdd( aRotina , { 'Alterar'   , 'U_xTIxBRWA'  , 0 , 4})   			//'Alterar' 
  	aAdd( aRotina , { 'Excluir'   , 'U_xTIxBRWE'  , 0 , 5})  	    	//'Excluir'
  	aAdd( aRotina , { 'Legenda'   , 'U_xTIxBRWL'  , 0 , 6, ,.F.})		//'Legenda'  

Return aRotina                                 

/*                                	
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡„o    ³ FilterExpr		³Autor³  Tiago Malta      ³ Data ³04/01/2007³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡„o ³     														³
³          ³ 														    ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Sintaxe   ³< Vide Parametros Formais >									³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Uso      ³GPEA320                                                     ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Retorno  ³aRotina														³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³< Vide Parametros Formais >									³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/   
User Function TabFilExpr(Alias,Campo)

Local lValid := .T.

IF !FunName() == "GPEA310M"
	IF MsgYesNo("Deseja Alterar o Filtro?", "Atenção")
		&(Campo) := ALLTRIM(&(Campo))
		&(Campo) := BUILDEXPR(Alias,,&(Campo),,,,,,,,,,) 
	ENDIF
	
	IF SUBSTR(Alias,1,1)='S'
		 IF   AT(Alias, &(Campo) ) >0
				&(Campo) := STRTRAN( &(Campo) , Alias + "->", "")
				&(Campo) := STRTRAN( &(Campo) , SUBSTR(Alias,2,2), ALIAS+"->"+SUBSTR(Alias,2,2) )
		 ELSE
				&(Campo) :=	STRTRAN( &(Campo) , SUBSTR(Alias,2,2) , ALIAS+"->"+SUBSTR(Alias,2,2) )		
		 ENDIF
	ELSE
	     IF   AT(Alias, &(Campo) ) >0
 				&(Campo) := STRTRAN( &(Campo) , Alias + "->", "")
				&(Campo) := STRTRAN( &(Campo) , Alias, ALIAS+"->"+Alias )
	     ENDIF )
 	ENDIF

ENDIF

Return lValid

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AjustaSX  ºAutor  ³Marcelo Silveira    º Data ³  23/12/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Ajustes nos dicionarios de dados.                          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function AjustaSXB()
	Local aCampos 	:= {}
	Local nX
	
	SXB->( DbSetorder(1) )
	
	If SXB->( ! dbSeek( "SX3SRA" ) )	
		aAdd( aCampos, {"SX3SRA", "1", "01", "DB", "Campos do Funcionario",	"Campos del Empleado",	"Employee Fields",	"SX3",						""})
		aAdd( aCampos, {"SX3SRA", "2", "01", "01", "C¾digo",				"Codigo",				"Code",				"",							""})
		aAdd( aCampos, {"SX3SRA", "4", "01", "01", "Campo",					"Campo",				"Field",			"X3_CAMPO",					""})
		aAdd( aCampos, {"SX3SRA", "4", "01", "02", "Descricao",				"Descripción",			"File",				"X3Descric()",				""})
		aAdd( aCampos, {"SX3SRA", "5", "01", "",   "",						"",						"",					"SX3->X3_CAMPO", 			""})
		aAdd( aCampos, {"SX3SRA", "6", "01", "01", "",						"",						"",					"SX3->X3_ARQUIVO == 'SRA'",	""})
			
		For nX := 1 To Len( aCampos )
			SXB->( Reclock("SXB", .T.) )
			SXB->XB_ALIAS   := aCampos[nX, 1]
			SXB->XB_TIPO    := aCampos[nX, 2]
			SXB->XB_SEQ     := aCampos[nX, 3]
			SXB->XB_COLUNA  := aCampos[nX, 4]
			SXB->XB_DESCRI  := aCampos[nX, 5]
			SXB->XB_DESCSPA := aCampos[nX, 6]
			SXB->XB_DESCENG := aCampos[nX, 7]
			SXB->XB_CONTEM  := aCampos[nX, 8]
			SXB->XB_WCONTEM := aCampos[nX, 9]
			SXB->( MsUnlock() )
		Next nX	
	Endif	
Return


/*/
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡„o    ³fPosTab()		 ³Autor³Mauro Sergio       ³Data ³21/07/2002³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡„o ³Retorna a Linha ou o Conteudo de uma coluna da tabela       ³
³          ³por comparacao do conteudo,operador e coluna de comparacao. ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Sintaxe   ³fPosTab(cCodTab,nColuna,cCond)   		       				³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Uso      ³Calculo Formulas			                                ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Retorno  ³       														³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³cCodTab 	= Codigo da tabela                         	    ³
³          ³uCOnt1  	= Conteudo1 para comparacao			            ³
³          ³cOper1    	= Operador 1 para comparacao                    ³
³          ³nColTab1 	= Numero da Coluna1 para comparacao             ³
³          ³uCOnt2  	= Conteudo2 para comparacao			            ³
³          ³cOper2    	= Operador 2 para comparacao                    ³
³          ³nColTab2 	= Numero da Coluna2 para comparacao             ³
³          ³nColRet     = Numero da Coluna para retorno do Conteudo     ³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
User Function XfPosTab( cCodTab,uCont1,cOper1,nColTab1,uCont2,cOper2,nColTab2,nColRet,nLinRet)
Local cTab1Type
Local cTab2Type
Local cCnt1Type
Local cCnt2Type
                  
Local lCarTab 	:= .F.
Local nPosTab 	:= 0
Local cResult	
Local lRet		:= .T.               
Local lAchou 	:= .F.
Local cFilTab 	:= SRA->RA_FILIAL
Local nFor
Local nTab
Local uRet		:= ""
Local aLogCalc
Local cMsg
Local nTamFil
Local aTab_Fol := {} // war 12/11/2019
DEFAULT nLinRet := 0

If Type( "dDataref" ) == "U"
	dDataRef := dDataBase
EndIf

//--Verifica a existencia do array das tabelas caso nao exista define e carrega
/*If ValType(aTab_Fol) # "A" .Or. Empty(aTab_Fol) // war 12/11/2019
	aTab_Fol := {}     
	lCarTab	 := .T. 
Endif*/	          // war 12/11/2019 

//--Verifica se Existe a Tabela Indicada no Array se nao existir 
//--Seta variavel para carregar
If Ascan(aTab_Fol,{ |x| x[1] == cCodTab}) == 0
	lCarTab := .T.
Endif

//--Carrega Tabela quando variavel lCarTab == .T.
If lCarTab
	fCarrTab( @aTab_Fol,cCodTab,dDataRef )
Endif

nTamFil := FWGETTAMFILIAL
//--Verifica se Existe a Tabela Cadastrada
If ( nPosTab := Ascan(aTab_Fol,{ |x| x[1] == cCodTab .And.x[2] == cFilTab .And. x[3] == MesAno(dDataRef) })) > 0
	lAchou := .T.	
Elseif( nPosTab := Ascan(aTab_Fol,{ |x| x[1] == cCodTab .And.x[2] == Space(nTamFil).And. x[3] == MesAno(dDataRef) })) > 0
	lAchou := .T.	
Elseif 	( nPosTab := Ascan(aTab_Fol,{ |x| x[1] == cCodTab .And.x[2] == cFilTab .And. x[3] == Space(6) })) > 0
	lAchou := .T.	
Elseif( nPosTab := Ascan(aTab_Fol,{ |x| x[1] == cCodTab .And.x[2] == Space(nTamFil) .And. x[3] == Space(6) })) > 0
	lAchou := .T.		
Endif	

If nLinRet > 0
	nPosTab := nLinRet
EndIf
If lAchou 

	//--Montagem dos Blocos de comparacao
	If uCont1 # Nil .And. uCont2 # Nil .And. cOper1 # Nil .And. cOper2 # Nil
	    cbloco2:='({|x,y|uCont1' + cOper1 + 'x .And. uCont2' + cOper2 + 'y})'  //({|x| nArea>=x})
	Endif
	If uCont1 # Nil .And. cOper1 # Nil 
	    cBloco1:='({|x,y|uCont1' + cOper1 + 'x })'
	Endif    
	
	//--Verifica se Pasou a coluna de busca inicial
	nFor := Len(aTab_fol)
	If nPosTab > nFor
		nPosTab := nFor
	EndIf
	For nTab := nPosTab To nFor
	
		If !(aTab_Fol[nTab,1] == cCodTab)
			Exit
		EndIf

		//-- Verificar o tipo da campo e do conteudo das variaveis
		If uCont1 # Nil
			cTab1Type := ValType(aTab_Fol[nTab,nColTab1+1])
			cCnt1Type := ValType(uCOnt1)
		EndIf	
		If uCont2 # Nil
			cTab2Type := ValType(aTab_Fol[nTab,nColTab2+1])
			cCnt2Type := ValType(uCOnt2)
		EndIf
		
		//--Verifica se Passou a coluna de Busca final se passou analisa a coluna 
		//--Inicial e final para ver se o valor passado se encaixa nesta condicao
		If uCont1 # Nil .And. uCont2 # Nil
			If cCnt1Type = cTab1Type .And. ;
			   cCnt2Type = cTab2Type

				If Eval(&cBloco2, aTab_Fol[nTab,nColTab1+1],aTab_Fol[nTab,nColTab2+1])                    
					nLinRet := Val(aTab_Fol[nTab][4])
					If nColRet # Nil .And. ! Empty(nColRet)
						uRet 	:= aTab_Fol[nTab,nColRet+1]
					Endif	
					Exit
				Endif	
			Endif	
		//Verifica se Passoua coluna Inicial e verifica se o valor passado 
		// e menor ou igual ao conteudo da coluna informada
		Elseif 	uCont1 # Nil
			If cCnt1Type = cTab1Type

				If Eval(&cBloco1, aTab_Fol[nTab,nColTab1+1])
					nLinRet := Val(aTab_Fol[nTab][4])    //nTab
					If nColRet # Nil .ANd. ! Empty(nColRet)
						uRet 	:= aTab_Fol[nTab,nColRet+1]
					Endif
					Exit
				Endif
			Endif
		Endif
	Next nTab
Else
	lRet := .F.
Endif

Return( If (nColret # Nil , uRet, nLinRet))
