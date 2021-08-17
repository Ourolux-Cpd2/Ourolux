#INCLUDE "Protheus.ch"
#INCLUDE "rwmake.ch"
#INCLUDE "TOPCONN.CH""

Static aSizeAdv			:= MsAdvSize(.F.)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  B4BREL01 ³ Autor ³Fábrica B4B 			    ³ Data ³23.09.2013³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Relatório de Prazo por Estado/Cidades e Outros			  ³±±
±±³          ³											 				  ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpO1: Objeto do relatorio                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function B4BREL01()
Local aParam     := {}

Private cPerg      := "B4BREL01"
Private aBrowse    := {}
Private PAR05      := 0

GetSx1Perg()//Carrega as perguntas do relatório

If Pergunte(cPerg)
	
	If MV_PAR05 <> 1
		If (MV_PAR02 - MV_PAR01) <= 30
			oReport := ReportDef(cPerg, aBrowse)
			oReport:PrintDialog()
		Else
			MsgInfo("O Período solicitado é superior a 30 dias(Mensal), favor solicitar outro envio de relatório!", "Período")
		EndIf
	Else
		MsgInfo("Favor escolher um filtro válido!", "Filtrar por?")
	EndIF
EndIf

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ReportDef ³ Autor ³Fábrica   				 ³ Data ³23.09.2013³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³A funcao estatica ReportDef devera ser criada para todos os ³±±
±±³          ³relatorios que poderao ser agendados pelo usuario.          ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpO1: Objeto do relatorio                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ReportDef(cPerg, aBrowse)
Local oReport
Local oSec1

oReport:= TReport():New("B4BREL01","Relatório de Prazo", If(.F.,Nil,cPerg), {|oReport| ReportPrint(oReport,aBrowse )},"Relatório de Prazo",,,,,.F.)//"Relatório de Prazo"
oReport:SetLandscape()      //Define a orientação de página do relatório como paisagem.
oReport:SetTotalInLine(.F.)
oReport:lParamReadOnly := .T.

oSec1 := TRSection():New(oReport,"Relatório",{"SF2"},,,,,,.F.)
oSec1:SetTotalInLine(.F.)
oSec1:SetLineStyle(.T.)//Define se imprime as células da seção em linhas

TRCell():New(oSec1,"cTransp"  		,"","Transportadora"	,PesqPict('SA4','A4_COD')						,10,/*lPixel*/,,"LEFT",		,"LEFT",)
TRCell():New(oSec1,"cDesc"  		,"","Nome"				,PesqPict('SA4','A4_NREDUZ') 				 	,60,/*lPixel*/,,"LEFT",		,"LEFT",)

oSec2 := TRSection():New(oReport,"Relatório",{"SF2"},,,,,,.T.)
oSec2:SetTotalInLine(.F.)
oSec2:SetLineStyle(.F.)//Define se imprime as células da seção em linhas
If MV_PAR05 == 2 //ESTADOS
	TRCell():New(oSec2,"cTitulo"  		,"","Estados"			,"@!",30,/*lPixel*/,,"LEFT",	,"LEFT",)
ElseIf MV_PAR05 == 3 //Cidades
	TRCell():New(oSec2,"cTitulo"  		,"","Cidades"			,"@!",30,/*lPixel*/,,"LEFT",	,"LEFT",)
ElseIf MV_PAR05 == 4 //Capitais
	TRCell():New(oSec2,"cTitulo"  		,"","Capitais"			,"@!",30,/*lPixel*/,,"LEFT",	,"LEFT",)
ElseIf MV_PAR05 == 5 //Outros
	TRCell():New(oSec2,"cTitulo"  		,"","Outros"			,"@!",30,/*lPixel*/,,"LEFT",	,"LEFT",)
EndIF

TRCell():New(oSec2,"nQuant"  		,"","Quantidade NF"		,"@E 9999999"				 	,14,/*lPixel*/,,"RIGTH",		,"RIGTH",)
TRCell():New(oSec2,"nPrazoMedio" 	,"","Prazo médio"		,"@E 99999.99"					,14,/*lPixel*/,,"RIGTH",		,"RIGTH",)

TRFunction():New(oSec2:Cell("nQuant")	    ,/* cID */,"SUM",,"","@E 9999999",/*uFormula*/,.F./*lEndSection*/,.F./*lEndReport*/,.F./*lEndPage*/)
TRFunction():New(oSec2:Cell("nPrazoMedio")  ,/* cID */,"SUM",,"","@E 99999.99",/*uFormula*/,.F./*lEndSection*/,.F./*lEndReport*/,.F./*lEndPage*/)

TRFunction():New(oSec2:Cell("nQuant")	    ,/* cID */,"SUM",,"","@E 9999999",/*uFormula*/,.T./*lEndSection*/,.F./*lEndReport*/,.F./*lEndPage*/)
oTotalMedia := TRFunction():New(oSec2:Cell("nPrazoMedio")  ,/* cID */,"AVERAGE",,"","@E 99999.99",/*uFormula*/,.T./*lEndSection*/,.F./*lEndReport*/,.F./*lEndPage*/)


oSec3 := TRSection():New(oReport,"Periodo",{""},,,,,,.F.)
oSec3:SetTotalInLine(.F.)
oSec3:SetLineStyle(.T.)//Define se imprime as células da seção em linhas

TRCell():New(oSec3,"cPeriodo"  		,"","Período"			,"@!",100,/*lPixel*/,,"LEFT",		,"LEFT",)


Return oReport

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ReportPrin³ Autor ³Fabrica 			    ³ Data ³24.09.2013³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³A funcao estatica ReportDef devera ser criada para todos os ³±±
±±³          ³relatorios que poderao ser agendados pelo usuario.          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function ReportPrint(oReport, aBrowse)
Local aArea      := GetArea()
Local cAliasTMP  := GetNextAlias()
Local cQuery     := ""
Local cQuebra    := ""
Local cTransp    := ""
Local cString    := ""
Local lImprime   := .T.
Local nPosicao   := 0
Local oSec1      := oReport:Section(1)
Local oSec2      := oReport:Section(2)
Local oSec3      := oReport:Section(3)
Local nCountAux  := 0
Local nMediaAux  := 0

#IFDEF TOP
	If MV_PAR05 == 2//Estados
		nPosicao := 2
	ElseIf MV_PAR05 == 3//Cidades
		nPosicao := 3
	ElseIf MV_PAR05 == 4//Capitais
		nPosicao := 2
	EndIf
	
	If MV_PAR05 <> 5
		For nX := 1 To Len(aBrowse)
			If aBrowse[nX][1]
				If nX <> Len(aBrowse)
					cString += "'"+Alltrim(aBrowse[nX][nPosicao])+"',"
				Else
					cString += "'"+Alltrim(aBrowse[nX][nPosicao])+"'"
				EndIf
			EndIF
		Next nX
		
		If !Empty(cString) .And. Len(cString) == RAT(",",cString)
			
			cString := SubStr(cString,1,RAT(",",cString)-1)
			
		Else
			cString := cString
			
		EndIf
		If Empty(cString)
			MsgInfo("O parâmetro 'Filtrar por?' não foi informado, favor selecinar uma opção de filtro!", "Parâmetro")
			
			lImprime := .F.
		EndIf
	Else
		lImprime := .T.
	EndIf
	
	If lImprime
		
		If MV_PAR06 == 2//Quebra por transportadora?
			
			cQuery := "SELECT DISTINCT(F2_DOC),F2_EMISSAO, F2_XDTCANH, A1_EST, A1_COD_MUN"+CRLF
			
		Else
			
			cQuery := "SELECT DISTINCT(F2_DOC),F2_EMISSAO, F2_XDTCANH,  F2_TRANSP,A1_EST, A1_COD_MUN"+CRLF
			
		EndIF
		
		If MV_PAR07 == 1 //Consolida filiais
			
			cQuery += "FROM "+RetSqlName('SF2')+" SF2"+CRLF
			
			cQuery += "INNER JOIN "+RetSqlName('SD2')+" SD2"+CRLF
			cQuery += "ON SD2.D2_DOC = SF2.F2_DOC"+CRLF
			cQuery += "AND SD2.D2_SERIE = SF2.F2_SERIE"+CRLF
			cQuery += "AND SD2.D2_CLIENTE = SF2.F2_CLIENTE"+CRLF
			cQuery += "AND SD2.D2_LOJA = SF2.F2_LOJA"+CRLF
			cQuery += "AND SD2.D_E_L_E_T_ <> '*'"+CRLF
			
			cQuery += "INNER JOIN "+RetSqlName('SF4')+" SF4"+CRLF
			cQuery += "ON SF4.F4_CODIGO = SD2.D2_TES"+CRLF
			cQuery += "AND SF4.F4_XTPOPER = '1'"+CRLF
			cQuery += "AND SF4.D_E_L_E_T_ <> '*'"+CRLF
			
			cQuery += "INNER JOIN "+RetSqlName('SA1')+" SA1"+CRLF
			cQuery += "ON SA1.A1_COD = SF2.F2_CLIENTE"+CRLF
			cQuery += "AND SA1.A1_LOJA = SF2.F2_LOJA"+CRLF
			
			If MV_PAR05 == 2//Estados
				cQuery += "AND SA1.A1_EST IN ("+cString+")"+CRLF
				cQuery += "AND SA1.A1_EST <> 'EX'"+CRLF
			ElseIf MV_PAR05 == 3 .Or. MV_PAR05 == 4//Municipios e Capitais
				cQuery += "AND SA1.A1_COD_MUN IN ("+cString+")"+CRLF
			EndIf
			If MV_PAR05 == 3 //Municipios e Capitais
				cQuery += "AND SA1.A1_EST = '"+aBrowse[1][2]+"'"+CRLF //PEGA O ESTADO PARA FILTRAR APENAS AS CIDADES DO ESTADO
			EndIf
			
			
			cQuery += "AND SA1.D_E_L_E_T_ <> '*'"+CRLF
			cQuery += "WHERE SF2.F2_EMISSAO BETWEEN '"+DTOS(MV_PAR01)+"' AND '"+DTOS(MV_PAR02)+"'"+CRLF
			cQuery += "AND SF2.F2_VALBRUT > 0"+CRLF
			cQuery += "AND SF2.F2_XDTCANH <>'20010101'"+CRLF
			
			
		Else
			cQuery += "FROM "+RetSqlName('SF2')+" SF2"+CRLF
			
			cQuery += "INNER JOIN "+RetSqlName('SD2')+" SD2"+CRLF
			cQuery += "ON SD2.D2_DOC = SF2.F2_DOC"+CRLF
			cQuery += "AND SD2.D2_SERIE = SF2.F2_SERIE"+CRLF
			cQuery += "AND SD2.D2_CLIENTE = SF2.F2_CLIENTE"+CRLF
			cQuery += "AND SD2.D2_LOJA = SF2.F2_LOJA"+CRLF
			cQuery += "AND SD2.D2_FILIAL ='"+xFilial("SD2")+"'"+CRLF
			cQuery += "AND SD2.D_E_L_E_T_ <> '*'"+CRLF
			
			cQuery += "INNER JOIN "+RetSqlName('SF4')+" SF4"+CRLF
			cQuery += "ON SF4.F4_CODIGO = SD2.D2_TES"+CRLF
			cQuery += "AND SF4.F4_FILIAL ='"+xFilial("SF4")+"'"+CRLF
			cQuery += "AND SF4.F4_XTPOPER = '1'"+CRLF
			cQuery += "AND SF4.D_E_L_E_T_ <> '*'"+CRLF
			
			cQuery += "INNER JOIN "+RetSqlName('SA1')+" SA1"+CRLF
			cQuery += "ON SA1.A1_COD = SF2.F2_CLIENTE"+CRLF
			cQuery += "AND SA1.A1_LOJA = SF2.F2_LOJA"+CRLF
			
			If MV_PAR05 == 2//Estados
				cQuery += "AND SA1.A1_EST IN ("+cString+")"+CRLF
				cQuery += "AND SA1.A1_EST <> 'EX'"+CRLF
			ElseIf MV_PAR05 == 3 .Or. MV_PAR05 == 4//Municipios e Capitais
				cQuery += "AND SA1.A1_COD_MUN IN ("+cString+")"+CRLF
			EndIf
			If MV_PAR05 == 3 //Municipios e Capitais
				cQuery += "AND SA1.A1_EST = '"+aBrowse[1][2]+"'"+CRLF //PEGA O ESTADO PARA FILTRAR APENAS AS CIDADES DO ESTADO
			EndIf
			
			cQuery += "AND SA1.A1_FILIAL ='"+xFilial("SA1")+"'"+CRLF
			cQuery += "AND SA1.D_E_L_E_T_ <> '*'"+CRLF
			cQuery += "WHERE SF2.F2_EMISSAO BETWEEN '"+DTOS(MV_PAR01)+"' AND '"+DTOS(MV_PAR02)+"'"+CRLF
			cQuery += "AND SF2.F2_VALBRUT > 0"+CRLF
			cQuery += "AND SF2.F2_XDTCANH <>'20010101'"+CRLF
			cQuery += "AND SF2.F2_FILIAL ='"+xFilial("SF2")+"'"+CRLF
			
		EndIf
		
		
		If MV_PAR03 == 1//Nosso Carro - SIM
			cQuery += "AND (SF2.F2_FILIAL IN ('01','03') AND SA1.A1_EST = 'PR'"+CRLF //SE A FILIAL FOR SP DEVERA CONTEMPLAR PARANA
			cQuery += "OR SF2.F2_FILIAL = '02' AND SA1.A1_EST = 'SP')"+CRLF //SE A FILIAL FOR PR DEVERA CONTEMPLAR SP
		EndIf
		
		//		If MV_PAR05 == 2//Estados
		//			cQuery += "AND SF2.F2_EST IN ("+cString+")"+CRLF
		//		EndIf
		
		
		If MV_PAR04 == 1//Cliente com Agendamento - Sim
			cQuery += "AND SF2.F2_XDTAGEN <> ''"+CRLF
		EndIf
		cQuery += "AND SF2.D_E_L_E_T_ <> '*'"+CRLF
		
		If MV_PAR06 == 2//Quebra por transportadora?
			
			If MV_PAR05 == 2//Estados
				cQuery += "ORDER BY A1_EST"+CRLF
			ElseIF  MV_PAR05 == 3 .OR. MV_PAR05 == 4//Municipios, Capitais
				cQuery += "ORDER BY A1_EST, A1_COD_MUN"+CRLF
			ElseIF MV_PAR05 == 5//Outros
				cQuery += "ORDER BY A1_EST"+CRLF
			EndIf
			
		Else
			If MV_PAR05 == 2//Estados
				cQuery += "ORDER BY F2_TRANSP, A1_EST"+CRLF
			ElseIF  MV_PAR05 == 3 .OR. MV_PAR05 == 4//Municipios, Capitais
				cQuery += "ORDER BY F2_TRANSP,A1_EST, A1_COD_MUN"+CRLF
			ElseIF MV_PAR05 == 5//Outros
				cQuery += "ORDER BY F2_TRANSP, A1_EST"+CRLF
			EndIf
			
		EndIf
		
		IF SELECT("TRA") > 0
			TRA->(DBCLOSEAREA())
		ENDIF
		//	Aviso("query",cQuery,{'&Ok'},03)
		cQuery := ChangeQuery(cQuery)
		DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasTMP,.F.,.T. )
		
		If MV_PAR05 == 2 //ESTADOS
			cAgrup := (cAliasTMP)->A1_EST
		ElseIf  MV_PAR05 == 3 //MUNICIPIOS
			cAgrup := (cAliasTMP)->A1_COD_MUN
		ElseIf  MV_PAR05 == 4 //Capitais
			cAgrup := (cAliasTMP)->A1_COD_MUN
		Else//Outros
			cAgrup := (cAliasTMP)->A1_EST
		EndIF
		cImprime := ""
		nMedia	 := 0
		nCount   := 0
		nTotalNf := 0
		lExec    := .F.
		cQuebra   := (cAliasTMP)->A1_EST
		cTranspOld := ""
		If MV_PAR06 == 1//Quebra por transportadora
			cTransp    := (cAliasTMP)->F2_TRANSP
		EndIf
		
		oSec3:Init()
		oSec3:Cell("cPeriodo"):SetValue(DTOC(MV_PAR01) +" À "+ DTOC(MV_PAR02))
		oSec3:PrintLine()
		oSec3:Finish()
		
		While (cAliasTMP)->(!EOF())
			oSec2:Init()
			If MV_PAR06 == 1//Quebra por transportadora
				If cTransp <> cTranspOld
					If lExec
						oSec2:Finish()
					Else
						lExec := .T.
					EndIF
					
					oSec1:Init()
					oSec1:Cell("cTransp"			):SetValue((cAliasTMP)->F2_TRANSP)
					oSec1:Cell("cDesc"				):SetValue(POSICIONE("SA4",1,xFilial("SA4")+(cAliasTMP)->F2_TRANSP,"A4_NREDUZ") )
					oSec1:PrintLine()
					oSec1:Finish()
					
					cTranspOld := cTransp
				EndIf
			EndIf
			
			cQuebra := cAgrup
			While (cAliasTMP)->(!EOF()) .And. cQuebra == cAgrup
				If MV_PAR05 == 2 //ESTADOS
					
					If cQuebra <> cImprime
						cTitulo := (cAliasTMP)->A1_EST
						
						cImprime := cAgrup
					EndIf
				ElseIf MV_PAR05 == 3 //Municipios
					
					If cQuebra <> cImprime
						cTitulo := (cAliasTMP)->(A1_EST+A1_COD_MUN)
						cImprime := cAgrup
					EndIf
				ElseIf MV_PAR05 == 4 //Capitais
					If cQuebra <> cImprime
						cTitulo := (cAliasTMP)->A1_COD_MUN
						cImprime := cAgrup
					EndIf
				ElseIf MV_PAR05 == 5 //Outros
					
					If cQuebra <> cImprime
						cTitulo := (cAliasTMP)->A1_EST
						cImprime := cAgrup
					EndIf
					
				EndIf
				
				If !Empty((cAliasTMP)->F2_XDTCANH)
					nMedia +=  STOD((cAliasTMP)->F2_XDTCANH) - STOD( (cAliasTMP)->F2_EMISSAO)
				Else
					nMedia += 30
				EndIf
				
				nCount++
				
				(cAliasTMP)->(DbSkip())
				If MV_PAR05 == 2 //ESTADOS
					cAgrup := (cAliasTMP)->A1_EST
				ElseIf  MV_PAR05 == 3 //MUNICIPIOS
					cAgrup := (cAliasTMP)->A1_COD_MUN
				ElseIf  MV_PAR05 == 4 //Capitais
					cAgrup := (cAliasTMP)->A1_COD_MUN
				Else//Outros
					cAgrup := (cAliasTMP)->A1_EST
				EndIF
			EndDo
			
			If MV_PAR05 == 2 //ESTADOS
				oSec2:Cell(	"cTitulo"		):SetValue(POSICIONE("SX5",1,xFilial("SX5")+"12"+cTitulo,"X5_DESCRI"))
				oSec2:Cell(	"nQuant"		):SetValue(nCount)
				oSec2:Cell(	"nPrazoMedio"	):SetValue(nMedia/nCount)
				//nCountAux +=nCount  //utilizar caso necessario
				//nMediaAux +=nMedia  //utilizar caso necessario
				nCount := 0
				nMedia := 0
				cTitulo:= ""
			ElseIf MV_PAR05 == 3 //Cidades
				oSec2:Cell(	"cTitulo"		):SetValue(POSICIONE("CC2",1,xFilial("CC2")+cTitulo,"CC2_MUN"))
				oSec2:Cell(	"nQuant"		):SetValue(nCount)
				oSec2:Cell(	"nPrazoMedio"	):SetValue(nMedia/nCount)
				
				nCount := 0
				nMedia := 0
				cTitulo:= ""
			ElseIf MV_PAR05 == 4 //Capitais
				oSec2:Cell(	"cTitulo"		):SetValue(POSICIONE("SX5",1,xFilial("SX5")+"ZS"+cTitulo,"X5_DESCRI"))
				oSec2:Cell(	"nQuant"		):SetValue(nCount)
				oSec2:Cell(	"nPrazoMedio"	):SetValue(nMedia/nCount)
				
				nCount := 0
				nMedia := 0
				cTitulo:= ""
			ElseIf MV_PAR05 == 5 //Outros
				oSec2:Cell(	"cTitulo"		):SetValue(POSICIONE("SX5",1,xFilial("SX5")+"12"+cTitulo,"X5_DESCRI"))
				oSec2:Cell(	"nQuant"		):SetValue(nCount)
				oSec2:Cell(	"nPrazoMedio"	):SetValue(nMedia/nCount)
				
				nCount := 0
				nMedia := 0
				cTitulo:= ""
			EndIf
			
			oSec2:PrintLine()
			If MV_PAR06 == 1//Quebra por transportadora
				cTransp    := (cAliasTMP)->F2_TRANSP
			EndIf
			
			
			
			
		EndDO
		oSec2:Finish()
		
	EndIf
#ENDIF

RestArea(aArea)

Return

User FUNCTION MediaData(dData1, dData2)
Local nret := 0

Return nret

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³GetSx1Perg³ Autor ³Fabrica 			    ³ Data ³24.09.2013³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³															  ³±±
±±³          ³															  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function GetSx1Perg()
Local cPerg := "B4BREL01"

PutSx1(cPerg	,"01"   ,"Faturamento De?				",""                    ,""                    ,"mv_ch1"	,"D"   	,01      	,0       	,0      		, "G"		,"" 	,""  		,""      ,""   	,"mv_par01"	,""     		,""     ,""     ,""    	,""        		,""     		,""      ,""    ,""      		,""      	,""    	,""      ,""     ,""    		,""      	,""      ,""      ,""      ,""      ,"")
PutSx1(cPerg	,"02"   ,"Faturamento Até?				",""                    ,""                    ,"mv_ch2"	,"D"   	,01      	,0       	,0      		, "G"		,"" 	,""  		,""      ,""   	,"mv_par02"	,""	 			,""     ,""     ,""    	,""	      		,""     		,""      ,""    ,""      		,""      	,""    	,""      ,""     ,""    		,""      	,""      ,""      ,""      ,""      ,"")
PutSx1(cPerg	,"03"   ,"Nosso Carro?					",""                    ,""                    ,"mv_ch3"	,"C"   	,01      	,0       	,0      		, "C"		,""  	,""   	 	,""      ,""   	,"mv_par03"	,"Sim"			,"" 	,""		,""		,"Não"			,""     		,""      ,""	,""				,""      	,""    	,""      ,""     ,""    		,""      	,""      ,""      ,""      ,""      ,"")
PutSx1(cPerg	,"04"   ,"Cliente C/ Agendamento?		",""                    ,""                    ,"mv_ch4"	,"C"   	,01      	,0       	,0      		, "C"		,""  	,""    		,""      ,""   	,"mv_par04"	,"Sim"			,"" 	,""		,""		,"Não"			,""     		,""      ,""	,""				,""      	,""    	,""      ,""     ,""    		,""      	,""      ,""      ,""      ,""      ,"")
PutSx1(cPerg	,"05"   ,"Filtrar por?					",""                    ,""                    ,"mv_ch5"	,"C"   	,01      	,0       	,1      		, "C"		,"U_GetFiltro(MV_PAR05)"  	,""    		,""      ,""   	,"MV_MV_PAR05"	,"-Escolher-"		,"" 	,""		,""		,"Estados"		,""     		,""      ,"Cidades"	,""		,""      	,"Capitais"    	,""      ,"" 		    ,"Outros"    		,""      	,""      ,""      ,""      ,""      ,"")
PutSx1(cPerg	,"06"   ,"Quebra por Transportadora?	",""                    ,""                    ,"mv_ch6"	,"C"   	,01      	,0       	,0      		, "C"		,""  	,""    		,""      ,""   	,"mv_par06"	,"Sim"			,"" 	,""		,""		,"Não"			,""     		,""      ,""	,""				,""      	,""    	,""      ,""     ,""    		,""      	,""      ,""      ,""      ,""      ,"")
PutSx1(cPerg	,"07"   ,"Consolida Filiais?	        ",""                    ,""                    ,"mv_ch7"	,"C"   	,01      	,0       	,0      		, "C"		,""  	,""    		,""      ,""   	,"mv_par07"	,"Sim"			,"" 	,""		,""		,"Não"			,""     		,""      ,""	,""				,""      	,""    	,""      ,""     ,""    		,""      	,""      ,""      ,""      ,""      ,"")

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³GetFiltro³ Autor ³Fabrica 			    ³ Data ³23.09.2013³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Tela generica de acordo com o parametro informado			  ³±±
±±³          ³															  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
User Function GetFiltro(MV_PAR05)

Local oOk        := LoadBitmap( GetResources(), "LBOK")
Local oNo        := LoadBitmap( GetResources(), "LBNO")
Local oBrowse
Local cTitulo    := ''
Local lTodas     := .F.
Local cEstado    := CRIAVAR('A1_EST'	,.F.)

If MV_PAR05 == 2//Estados
	cTitulo := 'Estados'
	aCampo  := {'','Codigo','Descrição'}
	bLine   := {||{If(aBrowse[oBrowse:nAt,01],oOK,oNO),aBrowse[oBrowse:nAt,02], aBrowse[oBrowse:nAt,03]} }
Elseif MV_PAR05 == 3//Cidades
	cTitulo := 'Cidades'
	aCampo  := {'','Estado','Código do IBGE', 'Municipio'}
	bLine   := {||{If(aBrowse[oBrowse:nAt,01],oOK,oNO),aBrowse[oBrowse:nAt,02],aBrowse[oBrowse:nAt,03],aBrowse[oBrowse:nAt,04]} }
Elseif MV_PAR05 == 4//Capitais
	cTitulo := 'Capitais'
	aCampo  := {'','Codigo','Descrição'}
	bLine   := {||{If(aBrowse[oBrowse:nAt,01],oOK,oNO),aBrowse[oBrowse:nAt,02], aBrowse[oBrowse:nAt,03]} }
ElseIf MV_PAR05 == 5//Outros
	Return
EndIf

If MV_PAR05 <> 3//Cidades
	aBrowse := QueryParam(MV_PAR05)
Else
	DEFINE DIALOG oDlg TITLE cTitulo FROM 0,0 TO 100, 200 PIXEL
	
	@ 10,15 SAY   "Estado" OF ODlg PIXEL SIZE 030,010             //   "Estado"
	@ 10,40 MSGET cEstado ;
	PICTURE PesqPict('SA1','A1_EST') F3 CpoRetF3('A1_EST') ;
	WHEN VisualSX3('A1_EST') VALID !Empty(cEstado) OF oDlg PIXEL SIZE 030,006
	
	@ 30, 20 BUTTON OemToAnsi("Confirmar") SIZE 40, 11 FONT oDlg:oFont VALID !Empty(cEstado) ACTION (nOpc := 1, oDlg:End()) OF oDlg PIXEL
	
	ACTIVATE DIALOG oDlg CENTERED
	aBrowse := QueryParam(cEstado)
EndIf

If !Empty(aBrowse)
	//aSizeAdv[3]-100,aSizeAdv[4]-100
	DEFINE DIALOG oDlg TITLE cTitulo FROM 0,0 TO 320, 500 PIXEL
	
	oBrowse := TWBrowse():New( 20 , 01, 250,120,,aCampo,{20,30,30},oDlg,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )
	
	
	@ 10,190 CHECKBOX oTodos VAR lTodas PROMPT "Selecionar Todos" SIZE 53,8 PIXEL ;
	ON CHANGE  {|| nCount := 0 ,aEval(aBrowse,{|x| nCount++, Marca(aBrowse,nCount,oBrowse ) }), oBrowse:Refresh()}//"Selecionar Todas"
	
	oBrowse:SetArray(aBrowse)
	oBrowse:bLine := bLine
	// Troca a imagem no duplo click do mouse
	oBrowse:bLDblClick := {|| aBrowse[oBrowse:nAt][1] := !aBrowse[oBrowse:nAt][1]}
	
	@ 143, 200 BUTTON OemToAnsi("Confirmar") SIZE 40, 11 FONT oDlg:oFont ACTION (nOpc := 1, oDlg:End()) OF oDlg PIXEL
	
	ACTIVATE DIALOG oDlg CENTERED
	
EndIf

Return .T.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ValidItens³ Autor ³Fabrica 			    ³ Data ³23.09.2013³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Verifica o tamanho dos itens				  				  ³±±
±±³          ³															  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function ValidItens(aItens)
Local lRet   := .F.

If Len(aItens) > 100
	If MsgYesNo('Está opção possui muitos registros, pode demorar alguns minutos, Deseja Continuar?', 'Registro')
		lRet   := .T.
	EndIf
EndIf

Return lRet

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Marca         ³Fabrica				    ³ Data ³ 23/09/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Função para marcar e atualizar o flag de seleção           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³		     ³                                                            ³±±
±±³			 ³							                                  ³±±
±±³          ³             												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SM2M040                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static function Marca(aItens,nAt,oBrowse)

aItens[nAt,1] := !aItens[nAt,1]

oBrowse:Refresh()

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³QueryParam³ Autor ³Fabrica 			    ³ Data ³23.09.2013³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Efetua a query de acordo com o parametro  				  ³±±
±±³          ³															  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function QueryParam(cFil)
Local aArea      := GetArea()
Local cAliasTMP  := GetNextAlias()
Local cQuery     := ""
Local cAlias     := ""
Local aRet       := {}

If MV_PAR05 == 1
	Alert("Favor escolher uma opção de filtro!")
	Return
ElseIf MV_PAR05 == 2//Estados
	cAlias   := 'SX5'
	cCampos  := 'X5_CHAVE, X5_DESCRI'
	cOrder   := 'X5_CHAVE, X5_DESCRI'
Elseif MV_PAR05 == 3//Cidades
	cAlias   := 'CC2'
	cCampos  := 'CC2_EST, CC2_CODMUN, CC2_MUN'
	cOrder   := 'CC2_EST, CC2_MUN'
Elseif MV_PAR05 == 4//Capitais
	cAlias   := 'SX5'
	cCampos  := 'X5_CHAVE, X5_DESCRI'
	cOrder   := 'X5_CHAVE, X5_DESCRI'
Else //Outros
	cAlias   := ''
	cCampos  := ''
	cOrder   := ''
EndIf

cQuery := "SELECT"+CRLF
cQuery += cCampos+CRLF
cQuery += "FROM "+RetSqlName(cAlias)+CRLF
cQuery += "WHERE"+CRLF

If MV_PAR05 == 2 //Estados
	cQuery += "X5_TABELA = '12' AND"+CRLF
Elseif MV_PAR05 == 3 //Municipios
	cQuery += "CC2_EST = '"+cFil+"' AND"+CRLF
Elseif MV_PAR05 == 4 //Capitais
	cQuery += "X5_TABELA = 'ZS' AND"+CRLF
EndIf

cQuery += "D_E_L_E_T_ <> '*' "+CRLF
cQuery += "ORDER BY "+cOrder

IF SELECT(cAliasTMP) > 0
	(cAliasTMP)->(DBCLOSEAREA())
ENDIF

cQuery := ChangeQuery(cQuery)

TcQuery cQuery New Alias (cAliasTMP)

While (cAliasTMP)->(!EOF())
	cCampos  := 'X5_CHAVE, X5_DESCRI'
	
	If MV_PAR05 == 2//Estados
		AADD(aRet,  {	.F.,;
		(cAliasTMP)->X5_CHAVE,;				//01 - Codigo
		(cAliasTMP)->X5_DESCRI})			//02 --Descricao
		
	Elseif MV_PAR05 == 3//Cidades
		AADD(aRet,  {	.F.,;
		(cAliasTMP)->CC2_EST,;				//01 -- Estado
		(cAliasTMP)->CC2_CODMUN,;			//02 -- Codigo do IBGE
		(cAliasTMP)->CC2_MUN})				//03 -- Descricao do municipio
		
	Elseif MV_PAR05 == 4//Capitais
		AADD(aRet,  {	.F.,;
		(cAliasTMP)->X5_CHAVE,;				//01 - Codigo
		(cAliasTMP)->X5_DESCRI})			//02 --Descricao
	EndIf
	
	(cAliasTMP)->(DbSkip())
EndDo

RestArea(aArea)

Return aRet