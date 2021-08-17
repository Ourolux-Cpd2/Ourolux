#INCLUDE "ctbr510.ch"
#Include "PROTHEUS.Ch"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ�
���Fun��o	 � Ctbr510	� Autor � Wagner Mobile Costa	 � Data � 15.10.01 ��
��������������������������������������������������������������������������Ĵ�
���Descri��o � Demonstracao de Resultados                 			  	   ��
��������������������������������������������������������������������������Ĵ�
���Retorno	 � Nenhum       											   ��
��������������������������������������������������������������������������Ĵ�
���Parametros� Nenhum													   ��
���������������������������������������������������������������������������ٱ
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
User Function oCtbR510()          

Private dFinalA
Private dFinal
Private nomeprog	:= "oCTBR510"    
Private dPeriodo0
Private cRetSX5SL 	:= ""
Private aSelFil	 	:= {}

oCTBR510R4()

//Limpa os arquivos tempor�rios 
If cVersao >= "12"
	CTBGerClean()
EndIf
 
Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 � CTBR510R4 � Autor� Daniel Sakavicius		� Data � 17/08/06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Demostrativo de balancos patrimoniais - R4		          ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe	 � CTBR115R4												  ���
�������������������������������������������������������������������������Ĵ��
��� Uso		 � SIGACTB                                    				  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function oCTBR510R4()                           

PRIVATE CPERG	   	:= "CTR510"        

//������������������������������������������������������������������������Ŀ
//�Interface de impressao                                                  �
//��������������������������������������������������������������������������            

Pergunte( CPERG, .T. )

// faz a valida��o do livro
if ! VdSetOfBook( mv_par02 , .T. )
   return .F.
endif

oReport := ReportDef()      

If VALTYPE( oReport ) == "O"
	oReport :PrintDialog()      
EndIf

oReport := nil

Return                                

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �ReportDef � Autor � Daniel Sakavicius		� Data � 17/08/06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Esta funcao tem como objetivo definir as secoes, celulas,   ���
���          �totalizadores do relatorio que poderao ser configurados     ���
���          �pelo relatorio.                                             ���
�������������������������������������������������������������������������Ĵ��
��� Uso		 � SIGACTB                                    				  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������    
/*/          
Static Function ReportDef()     

Local aSetOfBook	:= CTBSetOf(mv_par02)
Local aCtbMoeda		:= {}
Local cDescMoeda 	:= ""
local aArea	   		:= GetArea()   
Local CREPORT		:= "oCTBR510"
Local CTITULO		:= OemToAnsi("DEMONSTRACAO DE RESULTADOS")				// DEMONSTRACAO DE RESULTADOS
Local CDESC			:= OemToAnsi("Este programa ir� imprimir a Demonstra��o de Resultados, ") + ; 			//"Este programa ir� imprimir a Demonstra��o de Resultados, "
	   					OemToAnsi("de acordo com os par�metros informados pelo usu�rio.") 				//"de acordo com os par�metros informados pelo usu�rio."
Local aTamDesc		:= TAMSX3("CTS_DETHCG") // TAMSX3("CTS_DESCCG")
Local aTamVal		:= TAMSX3("CT2_VALOR")                       
Local aTamCompl     := TAMSX3("CTS_DETHCG")
                 
aCtbMoeda := CtbMoeda(mv_par03, aSetOfBook[9])
cDescMoeda 	:= AllTrim(aCtbMoeda[3])

If Empty(aCtbMoeda[1])                       
	Help(" ",1,"NOMOEDA")
    Return .F.
Endif


//Filtra Filiais
If mv_par19 == 1 .And. Len( aSelFil ) <= 0
	aSelFil := AdmGetFil()
EndIf 

//��������������������������������������������������������������Ŀ
//� Verifica se usa Set Of Books + Plano Gerencial (Se usar Plano�
//� Gerencial -> montagem especifica para impressao)				  �
//����������������������������������������������������������������
If !ct040Valid(mv_par02)
	Return
EndIf	
             
lMovPeriodo	:= (mv_par13 == 1)

If mv_par09 == 1												/// SE DEVE CONSIDERAR TODO O CALENDARIO
	CTG->(DbSeek(xFilial() + mv_par01))
	
	If Empty(mv_par08)
		While CTG->CTG_FILIAL = xFilial("CTG") .And. CTG->CTG_CALEND = mv_par01
			dFinal	:= CTG->CTG_DTFIM
			CTG->(DbSkip())
		EndDo
	Else
		dFinal	:= mv_par08
	EndIf
	
	//Data do periodo anterior
	If !Empty(MV_PAR20)
		If CTG->(DbSeek(xFilial() + mv_par01))
			dFinalA		:= MV_PAR20
		EndIf         
	Else	
		dFinalA   	:= Ctod(Left(Dtoc(dFinal), 6) + Str(Year(dFinal) - 1, 4))
		If Empty ( dFinalA )
			If MONTH(dFinal) == 2
				If Day(dFinal) > 28 .and. Day(dFinal) == 29
					dFinalA := Ctod(Left( STRTRAN ( Dtoc(dFinal) , "29" , "28" ), 6) + Str(Year(dFinal) - 1, 4))
				EndIf
			EndIf
		EndIf	
	EndIf
	
	mv_par01    := dFinal
	If lMovPeriodo
		dPeriodo0 	:= Ctod(Left(Dtoc(dFinal), 6) + Str(Year(dFinal) - 2, 4)) + 1
	EndIf
Else															/// SE DEVE CONSIDERAR O PERIODO CONTABIL
	If Empty(mv_par08)
		MsgInfo("� necess�rio informar a data de refer�ncia !","Parametro Considera igual a Periodo.")
		Return
	Endif
    
	dFinal		:= mv_par08
	dFinalA		:= CTOD("  /  /  ")
	dbSelectArea("CTG")
	dbSetOrder(1)

	//Data do periodo anterior
	If !Empty(MV_PAR20)
		If MsSeek(xFilial("CTG")+mv_par01)
			dFinalA		:= MV_PAR20
		EndIf         
	Else	
		MsSeek(xFilial("CTG")+mv_par01,.T.)
		While CTG->CTG_FILIAL == xFilial("CTG") .And. CTG->CTG_CALEND == mv_par01
			//dFinalA		:= CTG->CTG_DTINI		
			If dFinal >= CTG->CTG_DTINI .and. dFinal <= CTG->CTG_DTFIM
				dFinalA		:= CTG->CTG_DTINI	
				If lMovPeriodo
					nMes			:= Month(dFinalA)
					nAno			:= Year(dFinalA)
					dPeriodo0	:= CtoD(	StrZero(Day(dFinalA),2)							+ "/" +;
												StrZero( If(nMes==1,12		,nMes-1	),2 )	+ "/" +;
												StrZero( If(nMes==1,nAno-1,nAno		),4 ) )
					dFinalA		:= dFinalA - 1
				EndIf
				Exit
			Endif
			CTG->(DbSkip())
		EndDo
	EndIf
    
	If Empty(dFinalA)
		MsgInfo("Data fora do calend�rio !","Data de refer�ncia.")
		Return
	Endif
Endif

CTITULO		:= If(! Empty(aSetOfBook[10]), aSetOfBook[10], CTITULO)		// Titulo definido SetOfBook
If Valtype(mv_par16)=="N" .And. (mv_par16 == 1)
	cTitulo := CTBNomeVis( aSetOfBook[5] )
EndIf
//������������������������������������������������������������������������Ŀ
//�Criacao do componente de impressao                                      �
//�                                                                        �
//�TReport():New                                                           �
//�ExpC1 : Nome do relatorio                                               �
//�ExpC2 : Titulo                                                          �
//�ExpC3 : Pergunte                                                        �
//�ExpB4 : Bloco de codigo que sera executado na confirmacao da impressao  �
//�ExpC5 : Descricao                                                       �
//��������������������������������������������������������������������������
oReport	:= TReport():New( CREPORT,CTITULO,CPERG, { |oReport| ReportPrint( oReport ) }, CDESC ) 
oReport:SetCustomText( {|| CtCGCCabTR(,,,,,dDataBase,ctitulo,,,,,oReport,,,,,,,,,,mv_par08) } )                                        
oReport:ParamReadOnly()

IF GETNEWPAR("MV_CTBPOFF",.T.)
	oReport:SetEdit(.F.)
ENDIF	

oReport:nFontBody := 6
//������������������������������������������������������������������������Ŀ
//�Criacao da secao utilizada pelo relatorio                               �
//�                                                                        �
//�TRSection():New                                                         �
//�ExpO1 : Objeto TReport que a secao pertence                             �
//�ExpC2 : Descricao da se�ao                                              �
//�ExpA3 : Array com as tabelas utilizadas pela secao. A primeira tabela   �
//�        sera considerada como principal para a se��o.                   �
//�ExpA4 : Array com as Ordens do relat�rio                                �
//�ExpL5 : Carrega campos do SX3 como celulas                              �
//�        Default : False                                                 �
//�ExpL6 : Carrega ordens do Sindex                                        �
//�        Default : False                                                 �
//�                                                                        �
//��������������������������������������������������������������������������           
If cPaisLoc == "COS"
	aTamDesc[1] += aTamCompl[1]
EndIf
	
oSection1  := TRSection():New( oReport, "Contas/Saldos", {"cArqTmp"},, .F., .F. )        //"Contas/Saldos"

TRCell():New( oSection1, "ATIVO"	,"","(Em "+cDescMoeda+")"	/*Titulo*/,/*Picture*/,aTamDesc[1]+50	/*Tamanho*/,/*lPixel*/,/*CodeBlock*//*,,,,,,.T.*/)	//"(Em "
TRCell():New( oSection1, "SALDOATU"	,"",						/*Titulo*/,/*Picture*/,aTamVal[1]+25	/*Tamanho*/,/*lPixel*/,/*CodeBlock*/,"RIGHT",,"RIGHT"/*,,,.T.*/)
TRCell():New( oSection1, "SALDOANT"	,"",						/*Titulo*/,/*Picture*/,aTamVal[1]+25   /*Tamanho*/,/*lPixel*/,/*CodeBlock*/,"RIGHT",,"RIGHT"/*,,,.T.*/)

oSection1:SetTotalInLine(.F.) 

Return(oReport)

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �ReportPrint� Autor � Daniel Sakavicius	� Data � 17/08/06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Imprime o relatorio definido pelo usuario de acordo com as  ���
���          �secoes/celulas criadas na funcao ReportDef definida acima.  ���
���          �Nesta funcao deve ser criada a query das secoes se SQL ou   ���
���          �definido o relacionamento e filtros das tabelas em CodeBase.���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � ReportPrint(oReport)                                       ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �EXPO1: Objeto do relat�rio                                  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function ReportPrint( oReport )  

Local oSection1 	:= oReport:Section(1) 
Local aSetOfBook	:= CTBSetOf(mv_par02)
Local aCtbMoeda	:= {}
Local lin 			:= 3001
Local cArqTmp
Local cTpValor		:= GetMV("MV_TPVALOR")
Local cPicture
Local cDescMoeda
Local lFirstPage	:= .T.               
Local nTraco		:= 0
Local nSaldo
Local nTamLin		:= 2350
Local aPosCol		:= { 1740, 2045 }
Local nPosCol		:= 0
Local lImpTrmAux	:= Iif(mv_par10 == 1,.T.,.F.)
Local cArqTrm		:= ""
Local lVlrZerado	:= Iif(mv_par12==1,.T.,.F.)
Local lMovPeriodo
Local aTamVal		:= TAMSX3("CT2_VALOR")
Local cMoedaDesc	:= iif( empty( mv_par14 ) , mv_par03 , mv_par14 )
Local lPeriodoAnt 	:= (mv_par06 == 1)
Local cSaldos     	:= CT510TRTSL() 

aCtbMoeda := CtbMoeda(mv_par03, aSetOfBook[9])
If Empty(aCtbMoeda[1])                       
	Help(" ",1,"NOMOEDA")
    Return .F.
Endif

cDescMoeda 	:= AllTrim(aCtbMoeda[3])
nDecimais 	:= DecimalCTB(aSetOfBook,mv_par03)
cPicture 	:= aSetOfBook[4]

If ! Empty(cPicture) .And. Len(Trans(0, cPicture)) > 17
	cPicture := ""
Endif

lMovPeriodo	:= (mv_par13 == 1)

//��������������������������������������������������������������Ŀ
//� Monta Arquivo Temporario para Impressao					     �
//����������������������������������������������������������������
MsgMeter({|	oMeter, oText, oDlg, lEnd | ;
			CTGerPlan(	oMeter, oText, oDlg, @lEnd, @cArqTmp, dFinalA+1, dFinal;
					  , "", "", "", Repl( "Z", Len( CT1->CT1_CONTA )), ""; 
					  , Repl( "Z", Len(CTT->CTT_CUSTO)), "", Repl("Z", Len(CTD->CTD_ITEM));
					  , "", Repl("Z", Len(CTH->CTH_CLVL)), mv_par03, /*MV_PAR15*/cSaldos, aSetOfBook, Space(2);
					  , Space(20), Repl("Z", 20), Space(30),,,,, mv_par04=1, mv_par05;
					  , ,lVlrZerado,,,,,,,,,,,,,,,,,,,,,,,,,cMoedaDesc,lMovPeriodo,aSelFil,,.T.,MV_PAR17==1,,,,,,,,,,!Empty(MV_PAR20),dFinalA)};
			,STR0006, STR0001) //"Criando Arquivo Temporario..."

dbSelectArea("cArqTmp")           
dbGoTop()

oReport:SetPageNumber(mv_par07) //mv_par07 - Pagina Inicial

oSection1:Cell("ATIVO"   ):lHeaderSize := .F.
oSection1:Cell("SALDOANT"):lHeaderSize := .F.
oSection1:Cell("SALDOATU"):lHeaderSize := .F.
 		
oSection1:Init()
While ! Eof()

	//������������������������������������������������������������Ŀ
	//�indica se a entidade gerencial sera impressa/visualizada em �
	//�um relatorio ou consulta apos o processamento da visao      �
	//��������������������������������������������������������������
	If cArqTmp->VISENT == "2"
		cArqTmp->( DbSkip() )
		Loop
	EndIf

    //Imprime cabe�alho saldo atual e anterior
	oSection1:Cell("SALDOATU"     ):SetTitle(Dtoc(dFinal)) 
	If lPeriodoAnt
		oSection1:Cell("SALDOANT" ):SetTitle(Dtoc(dFinalA))
	Else
		oSection1:Cell("SALDOANT" ):Disable()
	EndIf

//	oSection1:Cell("ATIVO"):SetBlock( { || Iif(cArqTmp->COLUNA<2,Iif(cArqTmp->TIPOCONTA=="2",cArqTmp->DESCCTA,cArqTmp->DESCCTA),AllTrim(cArqTmp->DESCCTA)+AllTrim(Posicione("CTS",1,xFilial("CTS")+aSetOfBook[5]+cArqTmp->ORDEM,"CTS_DETHCG")))} )		
	oSection1:Cell("ATIVO"):SetBlock( { || AllTrim(Posicione("CTS",1,xFilial("CTS")+aSetOfBook[5]+cArqTmp->ORDEM,"CTS_DETHCG")) } )		
  	//Imprime Saldo para as contas diferentes de Linha sem Valor
  	If cArqTmp->IDENTIFI < "5"
		oSection1:Cell("SALDOATU"     ):SetBlock( { || ValorCTB( If(lMovPeriodo,cArqTmp->(SALDOATU-SALDOANT),cArqTmp->SALDOATU),,,aTamVal[1],nDecimais,.T.,cPicture,;
    	                                                 cArqTmp->NORMAL,cArqTmp->CONTA,,,cTpValor,,,.F. ) } )

		If lPeriodoAnt
			oSection1:Cell("SALDOANT" ):SetBlock( { || ValorCTB( If(lMovPeriodo,cArqTmp->MOVPERANT,cArqTmp->SALDOANT),,,aTamVal[1],nDecimais,.T.,cPicture,;
														 cArqTmp->NORMAL,cArqTmp->CONTA,,,cTpValor,,,.F. ) } )
		EndIf
	//Somente para Linha Sem Valor
	ElseIf cArqTmp->IDENTIFI == "5"
		oSection1:Cell("SALDOATU"     ):SetBlock( { || " " } )

		If lPeriodoAnt
			oSection1:Cell("SALDOANT" ):SetBlock( { || " " } )
		EndIf	
	EndIf    
    
	oSection1:PrintLine()
	dbSkip()
EndDo             
     
If cPaisloc == "PER" 
	If MV_PAR21 == 1 
		If MV_PAR06 == 2 .and. MV_PAR13 == 1
			If MSGYESNO("STR0016") 
				Processa({|| GerArq(AllTrim(MV_PAR22))},,"STR0017")
			EndIf	
		Else
			If MSGYESNO("STR0016") 
				Alert("STR0018")
			EndIf	
		EndIf	
	EndIf				
EndIf   
oSection1:Finish()

If lImpTrmAux
	cArqTRM 	:= mv_par11
    aVariaveis  := {}
	
    // Buscando os par�metros do relatorio (a partir do SX1) para serem impressaos do Termo (arquivos *.TRM)
	SX1->( dbSeek("CTR510"+"01") )
	SX1->( dbSeek( padr( "CTR510" , Len( X1_GRUPO ) , ' ' ) + "01" ) )
	While SX1->X1_GRUPO == padr( "CTR510" , Len( SX1->X1_GRUPO ) , ' ' )
		AADD(aVariaveis,{Rtrim(Upper(SX1->X1_VAR01)),&(SX1->X1_VAR01)})
		SX1->( dbSkip() )
	End

	If !File(cArqTRM)
		aSavSet:=__SetSets()
		cArqTRM := CFGX024(cArqTRM,STR0007) // "Respons�veis..."
		__SetSets(aSavSet)
		Set(24,Set(24),.t.)
	Endif

	If cArqTRM#NIL
		ImpTerm2(cArqTRM,aVariaveis,,,,oReport)
	Endif	 

Endif

DbSelectArea("cArqTmp")
Set Filter To
dbCloseArea()
 
If Select("cArqTmp") == 0
	FErase(cArqTmp+GetDBExtension())
	FErase(cArqTmp+OrdBagExt())
EndIF	

Return

/*/
���������������������������������������������������������������������������������
�����������������������������������������������������������������������������Ŀ��
���Fun��o    � CTR510SX5    � Autor � Elton da Cunha Santana� Data � 13.10.09 ���
�����������������������������������������������������������������������������Ĵ��
���Descri��o � Cria lista de opcoes para escolha em parametro                 ���
�����������������������������������������������������������������������������Ĵ��
���Uso       � Siga                                                           ���
������������������������������������������������������������������������������ٱ�
���������������������������������������������������������������������������������
����������������������������������������������������������������������������������
/*/
Static Function CTR510SX5(nModelo)

Local i := 0
Private nTam      := 0
Private aCat      := {}
Private MvRet     := Alltrim(ReadVar())
Private MvPar     := ""
Private cTitulo   := ""
Private MvParDef  := ""

#IFDEF WINDOWS
	oWnd := GetWndDefault()
#ENDIF

//Tratamento para carregar variaveis da lista de opcoes
Do Case 
	Case nModelo = 1
		nTam:=1
		cTitulo := STR0013
		SX5->(DbSetOrder(1))
		SX5->(DbSeek(XFilial("SX5")+"SL"))
		While SX5->(!Eof()) .And. AllTrim(SX5->X5_TABELA) == "SL"
			MvParDef += AllTrim(SX5->X5_CHAVE)
			aAdd(aCat,AllTrim(SX5->X5_CHAVE)+" - "+AllTrim(SX5->X5_DESCRI))
			SX5->(DbSkip())
		End
		 MvPar:= PadR(AllTrim(StrTran(&MvRet,";","")),Len(aCat))
		&MvRet:= PadR(AllTrim(StrTran(&MvRet,";","")),Len(aCat))
EndCase

//Executa funcao que monta tela de opcoes
f_Opcoes(@MvPar,cTitulo,aCat,MvParDef,12,49,.F.,nTam)

//Tratamento para separar retorno com barra "/"
&MvRet := ""
For i:=1 to Len(MvPar)
	If !(SubStr(MvPar,i,1) $ " |*")
		&MvRet  += SubStr(MvPar,i,1) + ";"
	EndIf
Next	

//Trata para tirar o ultimo caracter
&MvRet := SubStr(&MvRet,1,Len(&MvRet)-1)

//Guarda numa variavel private o retorno da fun��o
cRetSX5SL := &MvRet

Return(.T.)  

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 � fTrataSlds� Autor �Elton da Cunha Santana       � 13.10.09 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Tratamento do retorno do parametro                         ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe	 � CT510TRTSL                                                 ���
�������������������������������������������������������������������������Ĵ��
��� Uso		 � SIGACTB                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function CT510TRTSL()

Local cRet := ""

If MV_PAR17 == 1
	cRet := MV_PAR18
Else
	cRet := MV_PAR15
EndIf

Return(cRet)



/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �Ctr510Det � Autor � Simone Mie Sato       � Data � 28.06.01 ���
�������������������������������������������������������������������������Ĵ��
���Descricao �Detalhe do Relatorio                                        ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �Ctr510Det(ExpO1,ExpN1)                                      ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpO1 = Objeto oPrint                                      ���
���          � ExpN1 = Contador de paginas                                ���
���          � ParC1 = Titulo do relatorio                                ���
���          � ParC2 = Titulo da caixa do processo                        ���
���          � ParL1 = Indica se imprime em Paisagem (.T.) ou Retrato .F. ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � SIGACTB                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function Ctr510Det(oPrint,i,titulo,cProcesso,lLandScape)

Local aSetOfBook	:= CTBSetOf(mv_par02)
Local aCtbMoeda		:= {}
Local lin 			:= 3001
Local cArqTmp
Local cTpValor		:= GetMV("MV_TPVALOR")
Local cPicture
Local cDescMoeda
Local lFirstPage	:= .T.               
Local nTraco		:= 0
Local nSaldo
Local nTamLin		:= 2350
Local aPosCol		:= { 1740, 2045 }
Local nPosCol		:= 0
Local lImpTrmAux	:= Iif(mv_par10 == 1,.T.,.F.)
Local cArqTrm		:= ""
Local lVlrZerado	:= Iif(mv_par12==1,.T.,.F.)
Local lMovPeriodo
Local cMoedaDesc	:= iif( empty( mv_par14 ) , mv_par03 , mv_par14 ) 
Local cSaldos     	:= CT510TRTSL() 

aCtbMoeda := CtbMoeda(mv_par03, aSetOfBook[9])
If Empty(aCtbMoeda[1])                       
	Help(" ",1,"NOMOEDA")
    Return .F.
Endif

Titulo		:= If(! Empty(aSetOfBook[10]), aSetOfBook[10], Titulo)		// Titulo definido SetOfBook
If (mv_par16 == 1)
	titulo := CTBNomeVis( aSetOfBook[5] )
EndIf
cDescMoeda 	:= AllTrim(aCtbMoeda[3])
nDecimais 	:= DecimalCTB(aSetOfBook,mv_par03)

cPicture 	:= aSetOfBook[4]
If ! Empty(cPicture) .And. Len(Trans(0, cPicture)) > 17
	cPicture := ""
Endif

lMovPeriodo	:= (mv_par13 == 1)

m_pag := mv_par07
//��������������������������������������������������������������Ŀ
//� Monta Arquivo Temporario para Impressao					     �
//����������������������������������������������������������������
MsgMeter({|	oMeter, oText, oDlg, lEnd | ;
			CTGerPlan(	oMeter, oText, oDlg, @lEnd, @cArqTmp, ;
						dFinalA+1, dFinal, "", "", "", Repl("Z", Len(CT1->CT1_CONTA)),;
						"", Repl("Z", Len(CTT->CTT_CUSTO)), "", Repl("Z", Len(CTD->CTD_ITEM)), ;
						"",Repl("Z", Len(CTH->CTH_CLVL)),mv_par03,;
						/*MV_PAR15*/cSaldos, aSetOfBook, Space(2), Space(20), Repl("Z", 20), Space(30) ,,,,,;
						mv_par04 = 1, mv_par05,,lVlrZerado,,,,,,,,,,,,,,,,,,,,,,,,,;
						cMoedaDesc,lMovPeriodo,aSelFil,,.T.,MV_PAR17==1,,,,,,,,,,!Empty(MV_PAR20),dFinalA)};
			,STR0006, cProcesso) //"Criando Arquivo Temporario..."

dbSelectArea("cArqTmp")           
dbGoTop()

While ! Eof()

	If lin > 3000
		If !lFirstPage
			oPrint:Line( ntraco,150,ntraco,nTamLin )   	// horizontal
		EndIf	
		i++                                                
		oPrint:EndPage() 	 								// Finaliza a pagina
		CtbCbcDem(oPrint,titulo,lLandScape)					// Funcao que monta o cabecalho padrao 
		If mv_par06 == 2									// Demonstra periodo anterior = Nao
			Ctr510Atu(oPrint, cDescMoeda,aPosCol,nTamLin)	// Cabecalho de impress�o do Saldo atual.
		Else
			Ctr510Esp(oPrint, cDescMoeda,aPosCol,nTamLin)
		EndIf
		lin := 304        
		lFirstPage := .F.		
	End
    
	//������������������������������������������������������������Ŀ
	//�indica se a entidade gerencial sera impressa/visualizada em �
	//�um relatorio ou consulta apos o processamento da visao      �
	//��������������������������������������������������������������
	If cArqTmp->VISENT == "2"
		cArqTmp->( DbSkip() )
		Loop
	EndIf
    
	If DESCCTA = "-"
		oPrint:Line(lin,150,lin,nTamLin)   	// horizontal
	Else

		oPrint:Line( lin,150,lin+50, 150 )   	// vertical

// Negrito caso Sub-Total/Total/Separador (caso tenha descricao) e Igual (Totalizador)

		oPrint:Say(lin+15,195,DESCCTA, If(IDENTIFI $ "3469", oCouNew08N, oFont08))

		
		For nPosCol := 1 To Len(aPosCol)
			If mv_par06 == 2 .And. nPosCol == 1
				aPosCol := {1940}
			Else
				aPosCol	:= { 1540, 1940 }	           
			EndIf
   			oPrint:Line(lin,aPosCol[nPosCol],lin+55,aPosCol[nPosCol] )	// Separador vertical    			
    	  
    		If IDENTIFI < "5"
    			If mv_par06 == 1 .Or. (mv_par06 == 2 .And. nPosCol == 1)
					If !lMovPeriodo
						nSaldo := If(nPosCol = 1, SALDOATU, SALDOANT)
					Else
						nSaldo := If(nPosCol = 1, SALDOATU-SALDOANT,MOVPERANT)
					EndIf
				       
		            ValorCTB(nSaldo,lin+15,aPosCol[nPosCol],15,nDecimais,.T.,cPicture,;
					NORMAL,CONTA,.T.,oPrint,cTpValor,IIf(IDENTIFI $ "4","1",IDENTIFI))
				EndIf					 
			Endif 
			
		Next

		oPrint:Line(lin,nTamLin,lin+50,nTamLin)   	// Separador vertical
		lin +=47

	Endif

	nTraco := lin + 1
	DbSkip()
EndDo
oPrint:Line(lin,150,lin,nTamLin)   	// horizontal

lin += 10             

If lImpTrmAux
	If lin > 3000
		If !lFirstPage
			oPrint:Line( ntraco,150,ntraco,nTamLin )   	// horizontal
		EndIf	
		i++                                                
		oPrint:EndPage() 	 								// Finaliza a pagina
		CtbCbcDem(oPrint,titulo,lLandScape)					// Funcao que monta o cabecalho padrao 
		If mv_par06 == 2									// Demonstra periodo anterior = Nao
			Ctr510Atu(oPrint, cDescMoeda,aPosCol,nTamLin)	// Cabecalho de impress�o do Saldo atual.
		Else
			Ctr510Esp(oPrint, cDescMoeda,aPosCol,nTamLin)
		EndIf
		lin := 304        
		lFirstPage := .F.		
	Endif
	cArqTRM 	:= mv_par11
    aVariaveis  := {}
	
    // Buscando os par�metros do relatorio (a partir do SX1) para serem impressaos do Termo (arquivos *.TRM)
	SX1->( dbSeek( padr( "CTR510" , Len( X1_GRUPO ) , ' ' ) + "01" ) )

	While SX1->X1_GRUPO == padr( "CTR510" , Len( SX1->X1_GRUPO ) , ' ' )
		AADD(aVariaveis,{Rtrim(Upper(SX1->X1_VAR01)),&(SX1->X1_VAR01)})
		SX1->( dbSkip() )
	End

	If !File(cArqTRM)
		aSavSet:=__SetSets()
		cArqTRM := CFGX024(cArqTRM,STR0007) // "Respons�veis..."
		__SetSets(aSavSet)
		Set(24,Set(24),.t.)
	Endif

	If cArqTRM#NIL
		ImpTerm(cArqTRM,aVariaveis,"",.T.,{oPrint,oFont08,Lin})
	Endif	 
Endif


DbSelectArea("cArqTmp")
Set Filter To
dbCloseArea() 
If Select("cArqTmp") == 0
	FErase(cArqTmp+GetDBExtension())
	FErase(cArqTmp+OrdBagExt())
EndIF	
dbselectArea("CT2")

Return lin


/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �CTR500ESP � Autor � Simone Mie Sato       � Data � 27.06.01 ���
�������������������������������������������������������������������������Ĵ��
���Descricao �Cabecalho Especifico do relatorio CTBR041.                  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �CTR500ESP(ParO1,ParC1)			                          ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpO1 = Objeto oPrint                                      ���
���          � ExpC1 = Descricao da moeda sendo impressa                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � SIGACTB                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function CTR510Esp(oPrint,cDescMoeda,aPosCol,nTamLin)

Local cColuna  		:= "(Em " + cDescMoeda + ")"
Local aCabecalho    := { Dtoc(dFinal, "ddmmyyyy"), Dtoc(dFinalA, "ddmmyyyy") }
Local nPosCol

oPrint:Line(250,150,300,150)   	// vertical

oPrint:Say(260,195,cColuna,oArial10)

For nPosCol := 1 To Len(aCabecalho)
	If nPosCol < Len(aCabecalho)
		oPrint:Say(260,aPosCol[nPosCol] - 60,aCabecalho[nPosCol],oArial10)
	Else
		oPrint:Say(260,aPosCol[nPosCol] + 30,aCabecalho[nPosCol],oArial10)
	EndIf
Next

oPrint:Line(250,nTamLin,300,nTamLin)   	// vertical

oPrint:Line(300,150,300,nTamLin)   	// horizontal

Return Nil

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �CTR510ATU � Autor � Lucimara Soares       � Data � 03.02.03 ���
�������������������������������������������������������������������������Ĵ��
���Descricao �Cabecalho para impressao apenas da coluna de Saldo Atual.   ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �CTR510ESP(ParO1,ParC1)			                          ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpO1 = Objeto oPrint                                      ���
���          � ExpC1 = Descricao da moeda sendo impressa                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � SIGACTB                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function CTR510ATU(oPrint,cDescMoeda,aPosCol,nTamLin)

Local cColuna  		:= "(Em " + cDescMoeda + ")"
Local aCabecalho    := { Dtoc(dFinal, "ddmmyyyy") }
Local nPosCol       := 1

oPrint:Line(250,150,300,150)   	// vertical

oPrint:Say(260,195,cColuna,oArial10)

oPrint:Say(260,aPosCol[nPosCol+1] + 30,aCabecalho[nPosCol],oArial10)


oPrint:Line(250,nTamLin,300,nTamLin)   	// vertical

oPrint:Line(300,150,300,nTamLin)   	// horizontal

Return Nil  
/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
��� Funcao     � GerArq                                 � Data � 26.04.2016 ���
���������������������������������������������������������������������������Ĵ��
��� Descricao  � Gera o arquivo magn�tico                                   ���
���������������������������������������������������������������������������Ĵ��
��� Parametros � cDir - Diretorio de criacao do arquivo.                    ���
���            � cArq - Nome do arquivo com extensao do arquivo.            ���
���������������������������������������������������������������������������Ĵ��
��� Retorno    � Nulo                                                       ���
���������������������������������������������������������������������������Ĵ��
��� Uso        � 10.1 REGISTRO DE COSTOS - ESTADO DE COSTO DE VENTAS ANUAL   ��
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/
Static Function GerArq(cDir)

Local nHdl    := 0
Local cLin    := ""
Local cSep    := "|"
Local cArq    := ""
Local nCont   := 0

cArq += "LE"                          // Fixo 'LE'
cArq +=  AllTrim(SM0->M0_CGC)         // Ruc
If MV_PAR09 == 1
	cArq +=  AllTrim(Str(Year(MV_PAR01))) // Ano
Else
	cArq +=  AllTrim(Str(Year(MV_PAR08))) // Ano
EndIf	
cArq +=  "00"                         // Mes Fixo '00'
cArq +=  "00"                         // Dia Fixo '00'
cArq += "100100"                      // Fixo '100100'
cArq += "00"                          // Fixo '00'
cArq += "1"
cArq += "1"
cArq += "1"
cArq += "1"
cArq += ".TXT" // Extensao

FOR nCont:=LEN(ALLTRIM(cDir)) TO 1 STEP -1
   IF SUBSTR(cDir,nCont,1)=='\' 
      cDir:=Substr(cDir,1,nCont)
      EXIT
   ENDIF   
NEXT 

nHdl := fCreate(cDir+cArq)
If nHdl <= 0
	ApMsgStop("STR0019")
Else
		//10.1 REGISTRO DE COSTOS - ESTADO DE COSTO DE VENTAS ANUAL. Colunas impressas do arquivo tempor�rio "cArqTmp"
		// 01 - Costo del inventario inicial de productos terminados contable
		// 02 - Costo de producci�n de productos terminados contable
		// 03 - Costos del inventario final de productos terminados disponibles para la venta contable
		// 04 - Ajustes diversos contables
		// 05 - Indica el estado de la operaci�n
			
		dbSelectArea("cArqTmp")
		cArqTmp ->(dbGoTop())
		If MV_PAR09 == 1
			cLin += SubStr(DTOS(mv_par01),1,4)+"0000" // Data final informada no exerc�cio(CTG_DTFIM)
		Else
			cLin += SubStr(DTOS(mv_par08),1,4)+"0000"
		EndIF	
		cLin += cSep
		
		Do While cArqTmp->(!EOF())
				
			cLin += AllTrim(StrTran(Transform(SALDOATU,"@E 999999999.99"),",","."))
		    cLin += cSep
		    																			
			cArqTmp->(dbSkip())
		EndDo
			cLin += "1" // [1][8] - Indica el estado de la operaci�n
			cLin += cSep
			
	fWrite(nHdl,cLin)				
	fClose(nHdl)
	
MsgAlert("STR0020")
EndIf
Return Nil
