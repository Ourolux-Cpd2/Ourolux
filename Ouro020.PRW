#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"

//--------------------------------------------------
/*/{Protheus.doc} Ouro020
Importação de Planilha de Lançamento Contabeis OuroLux

@author André Brito
@since 09/12/2019
@version P12.1.17

@return 
/*/
//--------------------------------------------------       

User Function OURO020()	

	Local aRet		:= {}                                
	Local aArea		:= GetArea()
	Local cArq      := ""
	Local lConv     := .F.

	Private aLog    := {}
	Private cArquivo := Space(150)
	Private lOk      :=.F.
	Private bOk      := { || If(ValidaDir(cArquivo), (lOk:=.T.,oDlg:End()) ,) }
	Private bCancel  := { || lOk:=.F.,oDlg:End() }
	Private lEnd     := .F.

	Define MsDialog oDlg Title "Diretório" From 08,15 To 25,120 Of GetWndDefault()

	@ 45,16  Say 	"Diretorio:" 	Size 050,10 Of oDlg Pixel
	@ 45,40  MsGet 	cArquivo 		Size 230,08 Of oDlg Pixel
	@ 45,275 Button "…" 			Size 010,10 Action Eval({|| cArquivo:= SelectFile() }) Of oDlg Pixel

	Activate MsDialog oDlg Centered On Init (EnchoiceBar(oDlg,bOk,bCancel))

	If lOk

		oProcess:=MsNewProcess():New( { |lEnd| lConv := U_ImpCT2CSV(cArquivo, @lEnd)}, "Importação Lançamentos Contábeis", "Processando registros para CT2", .T. )
		oProcess:Activate()	

		If lConv
			Processa( {|| CRIALOG(aLog, SUBSTR(cArquivo,1,LEN(cArquivo)-4), 4)},"Gerando Log...", "Aguarde")		
		EndIf

	EndIf

	RestArea(aArea)

Return 

//--------------------------------------------------
/*/{Protheus.doc} ImpCT2CSV
Importação de arquivo CSV para a tabela de lançamentos contabeis CT2

@author André Brito
@since 09/12/2019
@version P12.1.17

@return 
/*/
//--------------------------------------------------       

User Function ImpCT2CSV(cArq, lEnd)

	Local aDados    := {}
	Local aArea		:= GetArea()
	Local cLinha
	Local nTot      := 0
	Local nCont     := 1
	Local nDoc      := 1
	Local nTimeIni  := 0
	Local nLinTit   := 1  // Total de linhas do Cabeçalho
	Local aCampos 	:= {} 
	Local aCab      := {}
	Local aItens    := {}
	Local cCodTab	:= ""
	Local cItem		:= ""
	Local cCodProd	:= ""
	Local nValAnt	:= 0
	Local cVldData  := ""
	Local cFilAtu	:= ""
	Local cCustoDeb := ""
	Local cCustoCre := ""
	Local cFilGuard	:= ""

	Private lMsErroAuto := .F.

	If (nHandle := FT_FUse(AllTrim(cArq)))== -1
		Help(" ",1,"NOFILEIMPOR")
		RestInter()
		Return .F.
	EndIf

	nTot := FT_FLASTREC()

	FT_FGOTOP()

	// Tratamento do cabeçalho
	While nLinTit > 0 .AND. !Ft_FEof()
		cLinha := FT_FREADLN()
		If LEN(cLinha) == 1023
			FT_FSKIP()
			cConLinha := FT_FREADLN()
			While LEN(cConLinha) == 1023
				cLinha += cConLinha
				FT_FSKIP()
				cConLinha := FT_FREADLN()
			EndDo
			cLinha += cConLinha
		EndIf

		If nLinTit == 1
			cLinha := "CT2_DATA;CT2_LOTE;CT2_SBLOTE;CT2_DOC;CT2_LINHA;CT2_MOEDLC;CT2_DC;CT2_DEBITO;CT2_CREDIT;CT2_VALOR;CT2_HIST;CT2_TPSALD;CT2_CCD;CT2_CCC;CT2_ITEMD;CT2_ITEMC;CT2_CLVLDB;CT2_CLVLCR;CT2_FILIAL;CT2_VLR01;CT2_MOEDAS;CT2_DTLP"
			aCampos := SEPARA(cLinha,";",.T.)
		EndIf

		cLinha := ""
		Ft_FSkip()
		nLinTit--
	EndDo

	// Processa os dados do template

	Do While !FT_FEOF()

		cLinha := FT_FREADLN()

		If lEnd
			MsgInfo("Importação cancelada!","Fim")
			Return .F.
		Endif

		If LEN(cLinha) == 1023
			FT_FSKIP()
			cConLinha := FT_FREADLN()
			While LEN(cConLinha) == 1023
				cLinha += cConLinha
				FT_FSKIP()
				cConLinha := FT_FREADLN()
			EndDo
			cLinha += cConLinha
		EndIf

		If !Empty(STOD(Left(cLinha,8)))	
			AAdd( aDados, SEPARA(cLinha,";",.T.) )
		EndIf

		FT_FSKIP()

	EndDo

	//Guarda filial logada para voltar ela
	cFilGuard := cFilAnt

	//Ordena array por filial
	ASORT(aDados, , , { | x,y | y[19] > x[19] } )

	FT_FUSE()

	oProcess:SetRegua1( Len(aDados) )

	For W:=1 To Len(aDados)

		oProcess:IncRegua1("Incluindo lançamento " + cValToChar(W) + " de " + cValToChar(Len(aDados)) + "... Filial: " + aDados[W][19] )

		If Empty(aCab)
			
			aCab := {   {'DDATALANC'           ,dDataBase                                ,NIL},;
						{'CLOTE'               ,StrZero(Val(aDados[W][2]),6)/*"000001"*/ ,NIL},;
						{'CSUBLOTE'            ,StrZero(Val(aDados[W][3]),3)/*"001"*/    ,NIL},;
						{'CDOC'                ,StrZero(Val(aDados[W][4]),6)/*"000003"*/ ,NIL},;
						{'CPADRAO'             ,''                                       ,NIL},;
						{'NTOTINF'             ,0                                        ,NIL},;
						{'NTOTINFLOT'          ,0                                        ,NIL} }

		EndIf

		//Se mudou a filial faz a inserção dos itens
		If aDados[W][19] <> cFilAtu .And. nCont > 1 .And. W < Len(aDados)

			cFilAnt := cFilAtu
			
			MSExecAuto( {|X,Y,Z| CTBA102(X,Y,Z)} ,aCab ,aItens, 3)

			If lMsErroAuto

				MostraErro()

				lMsErroAuto := .F.

				MsgAlert("Erro no lançamento!" , "Não foi possível carregar planilha")

				lRet := .F.

			Endif

			aItens := {}

		EndIf
		
		If Empty(aDados[W][13])
			cCustoDeb := ""
		Else
			cCustoDeb := StrZero(Val(aDados[W][13]),8)
		EndIf

		If Empty(aDados[W][14])
			cCustoCre:= ""
		Else
			cCustoCre := StrZero(Val(aDados[W][14]),8)
		EndIf

		aAdd(aItens,   {{'CT2_FILIAL'  ,aDados[W][19]              , NIL},;
						{'CT2_LINHA'    ,aDados[W][5]                              , NIL},;
						{'CT2_MOEDLC'   ,StrZero(Val(aDados[W][6]),2)              , NIL},;
						{'CT2_DC'       ,aDados[W][7]                              , NIL},;
						{'CT2_DEBITO'   ,aDados[W][8]                              , NIL},;
						{'CT2_CREDIT'   ,aDados[W][9]                              , NIL},;
						{'CT2_CCD'      ,cCustoDeb                                 , NIL},;
						{'CT2_CCC'      ,cCustoCre                                 , NIL},;
						{'CT2_VALOR'    ,Val(aDados[W][10])                        , NIL},;
						{'CT2_ORIGEM'   ,'ORIS'          						   , NIL},;
						{'CT2_HP'       ,''                                        , NIL},;
						{'CT2_HIST'     ,aDados[W][11]                             , NIL} }  )

		//Seta filial atual para controlar mudança de filial
		cFilAtu := aDados[W][19]

		//Se acabou o arquivo faz a inserção
		If W == Len(aDados)

			cFilAnt := cFilAtu
			
			MSExecAuto( {|X,Y,Z| CTBA102(X,Y,Z)} ,aCab ,aItens, 3)

			If lMsErroAuto

				MostraErro()

				lMsErroAuto := .F.

				MsgAlert("Erro no lançamento!" , "Não foi possível carregar planilha")

				lRet := .F.

			Endif

		EndIf

		nCont++

	Next W

	cFilAnt := cFilGuard

	RestArea(aArea)

	Aviso("Finalizado","Importacao finalizada - Iniciar Geração do arquivo de Log",{"Iniciar"})

Return .T.


//--------------------------------------------------
/*/{Protheus.doc} SelectFile
Rotina para selecao de arquivos CSV para importacao 

@author André Brito
@since 09/12/2019
@version P12.1.17

@return 
/*/
//--------------------------------------------------  


Static Function SelectFile()

	Local cMaskDir := ""
	Local cTitTela := "Arquivo para a integracao"
	Local lInfoOpen := .T.
	Local lDirServidor := .T.
	Local cOldFile := cArquivo

	cArquivo := cGetFile(cMaskDir,cTitTela,,cArquivo,lInfoOpen, (GETF_LOCALHARD + GETF_NETWORKDRIVE) ,lDirServidor)

	If !File(cArquivo)
		MsgStop("Arquivo não selecionado!")
		cArquivo := cOldFile
		Return .F.
	EndIf

Return cArquivo

//--------------------------------------------------
/*/{Protheus.doc} ValidaDir
Rotina para validacao do diretorio do arquivos CSV a ser importado.

@author André Brito
@since 09/12/2019
@version P12.1.17

@return 
/*/
//--------------------------------------------------  


Static Function ValidaDir(cArquivo)
	Local lRet := .T.

	If Empty(cArquivo)
		MsgStop("Selecione um arquivo","Atenção")
		lRet := .F.
	ElseIf !File(cArquivo)
		MsgStop("Selecione um arquivo válido!","Atenção")
		lRet := .F.
	EndIf

Return lRet


//--------------------------------------------------
/*/{Protheus.doc} EstTime

Estima tempo para terminar o processamento

@author André Brito
@since 09/12/2019
@version P12.1.17

@return 
/*/
//--------------------------------------------------  

Static Function EstTime(nTotal,nAtual,nIni,nTimeIni,nTimeZero)

	Local cRet := ""
	Local nTimeAtu := Seconds()
	Local nHora , nMinutos, nSegundos

	If (nAtual-nIni)>0
		nSegundos := (nTotal-nAtual)*(nTimeAtu-nTimeIni)/(nAtual-nIni)
	Else
		nSegundos := 0
	EndIf

	nHora 		:= Int(nSegundos/(60*60))
	nSegundos 	:= Mod(nSegundos,(60*60))
	nMinutos 	:= Int(nSegundos/(60))
	nSegundos 	:= Mod(nSegundos,(60))

	If nTotal > 0
		cRet := Str(nAtual/nTotal*100,3) + " % - "
	Else
		cRet := Str(100,3) + " % - "
	EndIf


	cRet += ""+If(nHora>0,Str(nHora,3,0)+" horas, ","")+If(nMinutos>0,Str(nMinutos,3,0)+" minutos e ","")+If(nSegundos>0,Str(nSegundos,3,0)+" segundos ","")

Return cRet

//--------------------------------------------------
/*/{Protheus.doc} EstTime

Rotina para criar o arquivo de log de erros. 

@author André Brito
@since 09/12/2019
@version P12.1.17

@return 
/*/
//--------------------------------------------------  

Static Function CRIALOG(aLog, cArq, nQbrLin)

	Local cFile := cArq + "_" + StrZero(Day(Date()),2,0) + "_" + StrZero(Month(Date()),2,0) + "_" + ALLTRIM(Str(Year(Date()))) + "_" + SubStr(Time(),1,2) + "_" + SubStr(Time(),4,2) + "_" + SubStr(Time(),7,2) + ".LOG"
	Local nH
	Local nCont := 1
	Local nIntrj

	nH := fCreate(cFile)

	nIntrj:= FCREATE("\INTRJ\OURO020_" + StrZero(Day(Date()),2,0) + "_" + StrZero(Month(Date()),2,0) + "_" + ALLTRIM(Str(Year(Date()))) + "_" + SubStr(Time(),1,2) + "_" + SubStr(Time(),4,2) + "_" + SubStr(Time(),7,2) + ".log",0)

	If nH == -1
		MsgStop("Falha ao criar arquivo - erro "+str(ferror()))
		Return
	Endif

	fWrite(nH,"DATA DA IMPORTACAO : "+StrZero(Day(Date()),2,0)+"/"+StrZero(Month(Date()),2,0)+"/"+ALLTRIM(Str(Year(Date())))+chr(13)+chr(10))
	fWrite(nIntrj,"DATA DA IMPORTACAO : "+StrZero(Day(Date()),2,0)+"/"+StrZero(Month(Date()),2,0)+"/"+ALLTRIM(Str(Year(Date())))+chr(13)+chr(10))

	fWrite(nH,REPLICATE("-",100) + chr(13)+chr(10))
	fWrite(nIntrj,REPLICATE("-",100) + chr(13)+chr(10))


	fWrite(nH,"Nome do Arquivo:  " + AllTrim(cArq) + " - Usuario: " + __cUserId + " - " + UsrRetName(__cUserId) +chr(13)+chr(10))
	fWrite(nH,REPLICATE("-",100) + chr(13)+chr(10))

	fWrite(nIntrj,"Nome do Arquivo:  " + AllTrim(cArq) + " - Usuario: " + __cUserId + " - " + UsrRetName(__cUserId) +chr(13)+chr(10))
	fWrite(nIntrj,REPLICATE("-",100) + chr(13)+chr(10))

	ProcRegua(LEN(aLog))

	For X:=1 To LEN(aLog)
		IncProc("Geração do Log : " + AllTrim(Str(x)) + " de " + AllTrim(Str(LEN(aLog)))   )
		fWrite(nIntrj,PADR(aLog[X][1],8)+" : "+aLog[X][2]+chr(13)+chr(10) )
		fWrite(nH,PADR(aLog[X][1],8)+" : "+aLog[X][2]+chr(13)+chr(10) )
		If nCont = nQbrLin
			fWrite(nH,		REPLICATE("-",100) + chr(13)+chr(10))
			fWrite(nIntrj,	REPLICATE("-",100) + chr(13)+chr(10))
			nCont := 0
		EndIf
		nCont++
	Next X

	fClose(nH)

Return
