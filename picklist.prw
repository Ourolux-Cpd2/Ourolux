#INCLUDE "RWMAKE.CH"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ picklist ³ Autor ³ Marco Bianchi         ³ Data ³ 19/07/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Pick-List (Expedicao)                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGAFAT                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
User Function picklist()

Local oReport
Private lPyme      := Iif(Type("__lPyme") <> "U",__lPyme,.F.)	
Private lAglutGrad := .F.

If FindFunction("TRepInUse") .And. TRepInUse()
	//-- Interface de impressao
	oReport := ReportDef()
	oReport:PrintDialog()
Else
	U_MATR7753()
EndIf

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ReportDef ³ Autor ³ Marco Bianchi         ³ Data ³ 19/07/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³A funcao estatica ReportDef devera ser criada para todos os ³±±
±±³          ³relatorios que poderao ser agendados pelo usuario.          ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpO1: Objeto do relatório                                  ³±±
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
Static Function ReportDef()

Local oReport
Local cCodProd 	 := ""
Local cDescProd	 := ""
Local cLote		 := ""
Local cSubLote	 := ""
Local nTotQuant	 := 0
Local dDtValid   := dDatabase
Local cNFiscal	 := ""
Local cLocal	 := ""
Local nPotenci	 := 0
Local nTamData   := Len(DTOC(MsDate()))
Local cLocaliz   := ""

#IFDEF TOP
	Local cAliasSD2 := GetNextAlias()
#ELSE
	Local cAliasSD2 := "SD2"
#ENDIF	

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
oReport := TReport():New("PICKLIST","PICKLIST","MTR775", {|oReport| ReportPrint(oReport,cAliasSD2)},"Emissao de produtos a serem separados pela expedicao, para" + " " + "determinada faixa de notas fiscais.")	// "PICK-LIST"###"Emissao de produtos a serem separados pela expedicao, para"###"determinada faixa de notas fiscais."
oReport:SetPortrait() 
oReport:SetTotalInLine(.F.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica as perguntas selecionadas                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
AjustaSX1("MTR775")
Pergunte(oReport:uParam,.F.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Criacao da secao utilizada pelo relatorio                               ³
//³                                                                        ³
//³TRSection():New                                                         ³
//³ExpO1 : Objeto TReport que a secao pertence                             ³
//³ExpC2 : Descricao da seçao                                              ³
//³ExpA3 : Array com as tabelas utilizadas pela secao. A primeira tabela   ³
//³        sera considerada como principal para a seção.                   ³
//³ExpA4 : Array com as Ordens do relatório                                ³
//³ExpL5 : Carrega campos do SX3 como celulas                              ³
//³        Default : False                                                 ³
//³ExpL6 : Carrega ordens do Sindex                                        ³
//³        Default : False                                                 ³
//³                                                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Criacao da celulas da secao do relatorio                                ³
//³                                                                        ³
//³TRCell():New                                                            ³
//³ExpO1 : Objeto TSection que a secao pertence                            ³
//³ExpC2 : Nome da celula do relatório. O SX3 será consultado              ³
//³ExpC3 : Nome da tabela de referencia da celula                          ³
//³ExpC4 : Titulo da celula                                                ³
//³        Default : X3Titulo()                                            ³
//³ExpC5 : Picture                                                         ³
//³        Default : X3_PICTURE                                            ³
//³ExpC6 : Tamanho                                                         ³
//³        Default : X3_TAMANHO                                            ³
//³ExpL7 : Informe se o tamanho esta em pixel                              ³
//³        Default : False                                                 ³
//³ExpB8 : Bloco de código para impressao.                                 ³
//³        Default : ExpC2                                                 ³
//³                                                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oPickList := TRSection():New(oReport,"PICK-LIST",{"SD2","SB1","SB4"},/*{Array com as ordens do relatório}*/,/*Campos do SX3*/,/*Campos do SIX*/)	// "PICK-LIST"
oPickList:SetTotalInLine(.F.)

TRCell():New(oPickList,"CCODPROD"	,/*Tabela*/	,RetTitle("D2_COD"	),PesqPict("SD2","D2_COD"	),TamSx3("D2_COD"	)[1],/*lPixel*/,{|| IIF(lAglutGrad ,Substr(cCodProd,1,ntamref),cCodProd)	})
TRCell():New(oPickList,"CDESCPROD"	,/*Tabela*/	,RetTitle("B1_DESC"	),PesqPict("SB1","B1_DESC"	),TamSx3("B1_DESC"	)[1],/*lPixel*/,{|| cDescProd 												})
TRCell():New(oPickList,"B1_UM"		,"SB1"		,RetTitle("B1_UM"	),PesqPict("SB1","B1_UM"	),TamSx3("B1_UM"	)[1],/*lPixel*/,{|| SB1->B1_UM												})
TRCell():New(oPickList,"NTOTQUANT"	,/*Tabela*/	,RetTitle("D2_QUANT"),PesqPict("SD2","D2_QUANT"	),TamSx3("D2_QUANT"	)[1],/*lPixel*/,{|| nTotQuant 												},,,"RIGHT")
TRCell():New(oPickList,"CLOCAL"		,/*Tabela*/	,RetTitle("D2_LOCAL"),PesqPict("SD2","D2_LOCAL"	),TamSx3("D2_LOCAL"	)[1],/*lPixel*/,{|| cLocal													})
If !lPyme
	TRCell():New(oPickList,"CLOCALIZ"	,/*Tabela*/	,RetTitle("C6_LOCALIZ"),PesqPict("SC6","C6_LOCALIZ"),TamSx3("C6_LOCALIZ")[1],/*lPixel*/,{|| cLocaliz 			})
EndIf
TRCell():New(oPickList,"CLOTE"		,/*Tabela*/	,RetTitle("D2_LOTECTL"),PesqPict("SD2","D2_LOTECTL"),TamSx3("D2_LOTECTL")[1],/*lPixel*/,{|| cLote				})
TRCell():New(oPickList,"CSUBLOTE"	,/*Tabela*/	,RetTitle("D2_NUMLOTE"),PesqPict("SD2","D2_NUMLOTE"),TamSx3("D2_NUMLOTE")[1],/*lPixel*/,{|| cSubLote			})
TRCell():New(oPickList,"DDTVALID"	,/*Tabela*/	,RetTitle("D2_DTVALID"),PesqPict("SD2","D2_DTVALID"),nTamdata				,/*lPixel*/,{|| dDtValid			})
TRCell():New(oPickList,"NPOTENCI"	,"SD2"		,RetTitle("D2_POTENCI"),PesqPict("SD2","D2_POTENCI"),TamSx3("D2_POTENCI")[1],/*lPixel*/,{|| nPotenci			},,,"RIGHT")
//TRCell():New(oPickList,"CNFISCAL",/*Tabela*/,RetTitle("D2_DOC"),PesqPict("SD2","D2_DOC"),TamSx3("D2_DOC")[1],/*lPixel*/,{|| cNFiscal })

oReport:Section(1):SetUseQuery(.F.) // Novo compomente tReport para adcionar campos de usuario no relatorio qdo utiliza query
Return(oReport)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ReportPrin³ Autor ³ Marco Bianchi         ³ Data ³ 19/07/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³A funcao estatica ReportDef devera ser criada para todos os ³±±
±±³          ³relatorios que poderao ser agendados pelo usuario.          ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpO1: Objeto Report do Relatório                           ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ReportPrint(oReport,cAliasSD2)

Local nTamRef  	 := Val(Substr(GetMv("MV_MASCGRD"),1,2))
Local lRet       := .F.
Local cProdRef	 := ""
Local lSkip		 := .F.    
Local cSerie	 := ""
Local lQuery     := .F.

#IFNDEF TOP
	Local cCondicao := ""
	Local cKey 		:= ""
	Local cIndexSD2 := ""
#ELSE	
	Local cWhere := ""
#ENDIF               

oReport:Section(1):Cell("CCODPROD" 	):SetBlock({|| cCodProd		})
oReport:Section(1):Cell("CDESCPROD"	):SetBlock({|| cDescProd	})
If !lPyme
	oReport:Section(1):Cell("CLOCALIZ"  ):SetBlock({|| cLocaliz		})
EndIf
oReport:Section(1):Cell("CLOTE"		):SetBlock({|| cLote   		})
oReport:Section(1):Cell("CSUBLOTE"	):SetBlock({|| cSubLote		})
oReport:Section(1):Cell("DDTVALID"	):SetBlock({|| dDtValid		})
oReport:Section(1):Cell("NPOTENCI"	):SetBlock({|| nPotenci		})

oReport:Section(1):Cell("NTOTQUANT"	):SetBlock({|| nTotQuant	})
oReport:Section(1):Cell("CLOCAL"	):SetBlock({|| cLocal		})
//oReport:Section(1):Cell("CNFISCAL"	):SetBlock({|| cNFiscal		})

nTotQuant := 0


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Transforma parametros Range em expressao SQL                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
MakeSqlExpr(oReport:uParam)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Filtragem do relatório                                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
#IFDEF TOP
	If TcSrvType() <> "AS/400"
		lQuery := .T.
		cWhere := "%"		
		cWhere += IIf(!Empty(mv_par03),"SD2.D2_SERIE = '"+mv_par03+"' AND ","SD2.D2_QUANT > 0 AND ")
		cWhere += "SD2.D2_DOC >= '"+mv_par01+"' AND "
		cWhere += "SD2.D2_DOC <= '"+mv_par02+"' AND "
		cWhere += "SD2.D2_FILIAL = '"+xFilial("SD2")+"' AND "
		cWhere += "NOT ("+IsRemito(3,'SD2.D2_TIPODOC')+ ")"		
		cWhere += "%"
		
		oReport:Section(1):BeginQuery()
		BeginSql Alias cALiasSD2
		SELECT SD2.R_E_C_N_O_ SD2REC,
		SD2.D2_DOC,SD2.D2_FILIAL,SD2.D2_SERIE,SD2.D2_QUANT,SD2.D2_COD,
		SD2.D2_LOCAL,SD2.D2_GRADE,SD2.D2_LOTECTL,SD2.D2_POTENCI,
		SD2.D2_NUMLOTE,SD2.D2_DTVALID,SD2.D2_CLIENTE,SD2.D2_LOJA,SD2.D2_ITEM,SD2.D2_PEDIDO,SD2.D2_ITEMPV
		FROM %Table:SD2% SD2
		WHERE %Exp:cWhere% AND SD2.%Notdel%
			ORDER BY SD2.D2_FILIAL,SD2.D2_COD,SD2.D2_LOTECTL,SD2.D2_NUMLOTE,SD2.D2_DTVALID//,SD2.D2_DOC,SD2.D2_SERIE,SD2.D2_CLIENTE,SD2.D2_LOJA
		EndSql
		oReport:Section(1):EndQuery()		
				
	Else
#ENDIF	         
		dbSelectArea(cAliasSD2)
		cIndexSD2  := CriaTrab(nil,.f.)
		cKey :="D2_FILIAL+D2_COD+D2_LOTECTL+D2_NUMLOTE+DTOS(D2_DTVALID)" //+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA"		
		cCondicao := "D2_FILIAL = '" + xFilial("SD2") + "' .And. "
		cCondicao += IIf(!Empty(mv_par03),"D2_SERIE = '"+mv_par03+"' .And. ","D2_QUANT > 0 .And. ")
		cCondicao += "D2_DOC >= '"+mv_par01+"' .And. " 
		cCondicao += "D2_DOC <= '"+mv_par02+"'" 
		cCondicao += '.And. !('+IsRemito(2,'SD2->D2_TIPODOC')+')'		

		IndRegua(cAliasSD2,cIndexSD2,cKey,,cCondicao,"Selecionando Registros...")//"Selecionando Registros..."	   
		#IFNDEF TOP
			DbSetIndex(cIndexSD2+OrdBagExt())
		#ENDIF                           
		
#IFDEF TOP
	Endif
#ENDIF	

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Metodo TrPosition()                                                     ³
//³                                                                        ³
//³Posiciona em um registro de uma outra tabela. O posicionamento será     ³
//³realizado antes da impressao de cada linha do relatório.                ³
//³                                                                        ³
//³                                                                        ³
//³ExpO1 : Objeto Report da Secao                                          ³
//³ExpC2 : Alias da Tabela                                                 ³
//³ExpX3 : Ordem ou NickName de pesquisa                                   ³
//³ExpX4 : String ou Bloco de código para pesquisa. A string será macroexe-³
//³        cutada.                                                         ³
//³                                                                        ³				
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
TRPosition():New(oReport:Section(1),"SB2",1,{|| xFilial("SB1")+cCodProd+cLocal})


dbSelectArea(cAliasSD2)
dbGoTop()
oReport:SetMeter(RecCount())
oReport:Section(1):Init()
While !oReport:Cancel() .And. (cAliasSD2)->(!Eof()) .And. (cALiasSD2)->D2_FILIAL = xFilial("SD2")

	//	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//	³ Valida o produto conforme a mascara         ³
	//	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	lRet:=ValidMasc((cAliasSD2)->D2_COD,MV_PAR04)
	
	If lRet

		cCodProd := (cAliasSD2)->D2_COD
		cLote	 := (cAliasSD2)->D2_LOTECTL
		cSubLote := (cAliasSD2)->D2_NUMLOTE              
		dDtValid := (cAliasSD2)->D2_DTVALID
		cNFiscal := (cAliasSD2)->D2_DOC
		cSerie   := (cAliasSD2)->D2_SERIE
		cLocal   := (cAliasSD2)->D2_LOCAL
		nPotenci := (cAliasSD2)->D2_POTENCI
		
		SC6->(dbSeek(xFilial("SC6")+(cAliasSD2)->D2_PEDIDO+(cAliasSD2)->D2_ITEMPV+(cAliasSD2)->D2_COD ))
        cLocaliz := SC6->C6_LOCALIZ
		lSkip := .F.
		lAglutGrad := ((cAliasSD2)->D2_GRADE == "S" .and. MV_PAR05 == 1) 
		If lAglutGrad
			cProdRef 	:=Substr(cCodProd,1,nTamRef)
			SB4->(DbSeek(xFilial("SB4") + cProdRef))
			cDescProd:= SB4->B4_DESC
		Else
			SB1->(DbSeek(xFilial("SB1") + (cAliasSD2)->D2_COD))
			cDescProd:= SB1->B1_DESC
		Endif  
		
		If lQuery
			dbSelectArea("SD2")	
			dbSetOrder(3)		//D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD+D2_ITEM		
			dbSeek(xFilial("SD2")+(cAliasSD2)->D2_DOC+(cAliasSD2)->D2_SERIE+(cAliasSD2)->D2_CLIENTE+(cAliasSD2)->D2_LOJA+(cAliasSD2)->D2_COD+(cAliasSD2)->D2_ITEM)
		EndIf	
		
		dbSelectArea(cAliasSD2)
		If MV_PAR06 == 1
			nTotQuant := 0
			While (cAliasSD2)->(!Eof()) .And.;
				If(lAglutGrad,(cProdRef == Substr((cAliasSD2)->D2_COD,1,nTamRef)),cCodProd == (cAliasSD2)->D2_COD) .And.;
				(cLote == (cAliasSD2)->D2_LOTECTL .And. cSubLote == (cAliasSD2)->D2_NUMLOTE) //.And. ;
//				(cAliasSD2)->D2_DOC == cNFiscal .And. (cAliasSD2)->D2_SERIE == cSerie  RETIRADO PARA AGLUTINAR OS PRODUTOS POR LOTE
				
				nTotQuant += (cAliasSD2)->D2_QUANT
				(cAliasSD2)->(dbSkip())
				lSkip := .T.
			Enddo
		Else
			IF (cAliasSD2)->D2_GRADE == "S" .and. MV_PAR05 == 1
				cProdRef 	:=Substr(cCodProd,1,nTamRef)
				nTotQuant	:=0
				While (cAliasSD2)->(!Eof()) .And. cProdRef == Substr((cAliasSD2)->D2_COD,1,nTamRef) .And. (cAliasSD2)->D2_GRADE == "S" .And.;
					(cLote == (cAliasSD2)->D2_LOTECTL .And. cSubLote == (cAliasSD2)->D2_NUMLOTE) //.And. ;
					//(cAliasSD2)->D2_DOC == cNFiscal .And. (cAliasSD2)->D2_SERIE == cSerie RETIRADO PARA AGLUTINAR OS PRODUTOS POR LOTE
					nTotQuant += (cAliasSD2)->D2_QUANT
					(cAliasSD2)->(dbSkip())
					lSkip := .T.
				End
			Endif
		Endif
		
		If !(lAglutGrad .Or. MV_PAR06 == 1)
			nTotQuant :=(cAliasSD2)->D2_QUANT
		EndIf
		
		oReport:Section(1):PrintLine()
		
	EndIf

	dbSelectArea(cAliasSD2)
	If !lSkip	
		dbSkip()
	EndIf	
	
End
oReport:Section(1):Finish()


Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ MATR7753 ³ Autor ³ Claudinei M. Benzi    ³ Data ³ 23.05.94 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Pick-List (Expedicao)                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ MATR775(void)                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ PROGRAMADOR  ³ DATA   ³ BOPS ³  MOTIVO DA ALTERACAO                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Edson   M.   ³30/03/99³XXXXXX³Passar o tamanho na SetPrint.           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function MatR7753
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
LOCAL wnrel		:= "PICKLIST"
LOCAL tamanho	:= "G"
LOCAL titulo	:= OemToAnsi("Pick-List  (Expedicao)")	//"Pick-List  (Expedicao)"
LOCAL cDesc1	:= OemToAnsi("Emiss„o de produtos a serem separados pela expedicao, para")	//"Emiss„o de produtos a serem separados pela expedicao, para"
LOCAL cDesc2	:= OemToAnsi("determinada faixa de notas fiscais.")	//"determinada faixa de notas fiscais."
LOCAL cDesc3	:= ""
LOCAL cString	:= "SD2"
LOCAL cPerg  	:= "MTR775"

PRIVATE aReturn		:= {"Zebrado", 1,"Administracao", 2, 2, 1, "",0 }			//"Zebrado"###"Administracao"
PRIVATE nomeprog	:= "MATR775"
PRIVATE nLastKey 	:= 0
PRIVATE nBegin		:= 0
PRIVATE aLinha		:= {}
PRIVATE li			:= 80
PRIVATE limite		:= Iif(cPaisloc == "BRA",132,220)
PRIVATE lRodape		:= .F.
PRIVATE m_pag       :=1

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica as perguntas selecionadas                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
AjustaSX1(cPerg)
pergunte(cPerg,.F.)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros                      ³
//³ mv_par01	     	  Da Nota
//³ mv_par02	     	  Ate a Nota                             ³
//³ mv_par03	     	  Serie	                                ³
//³ mv_par04	     	  Mascara                                ³
//³ mv_par05	     	  Aglutina itens grade                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
wnrel:=SetPrint(cString,wnrel,cPerg,@Titulo,cDesc1,cDesc2,cDesc3,.F.,,,Tamanho,,.T.)

If nLastKey == 27
	dbClearFilter()
	Return
Endif

SetDefault(aReturn,cString)

If nLastKey == 27
	dbClearFilter()
	Return
Endif

RptStatus({|lEnd| C775Imp(@lEnd,wnRel,cString,cPerg,tamanho,@titulo,@cDesc1,;
			@cDesc2,@cDesc3)},Titulo)
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ C775IMP  ³ Autor ³ Rosane Luciane Chene  ³ Data ³ 09.11.95 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Chamada do Relatorio                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATR775			                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function C775Imp(lEnd,WnRel,cString,cPerg,tamanho,titulo,cDesc1,cDesc2,;
						cDesc3)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

LOCAL cabec1 	 := OemToAnsi("Codigo          Desc. do Material              UM Quantidade                     Lote      SubLote  Validade   Potencia    Nota") //"Codigo          Desc. do Material              UM Quantidade  Amz Endereco       Lote      SubLote  Validade   Potencia    Nota"
LOCAL cabec2	 := ""
LOCAL lContinua  := .T.
LOCAL lFirst 	 := .T.
LOCAL cPedAnt	 := ""
LOCAL nI		 := 0
LOCAL aTam    	 := {}
LOCAL cMascara 	 := GetMv("MV_MASCGRD")
LOCAL nTamRef  	 := Val(Substr(cMascara,1,2))
LOCAL cbtxt      := SPACE(10)
LOCAL cbcont	 := 0
LOCAL nTotQuant	 := 0
LOCAL aStruSD2   := {}
LOCAL nSD2       := 0
LOCAL cFilter    := ""
LOCAL cAliasSD2  := "SD2"
LOCAL cIndexSD2  := "" 
LOCAL cKey 	     := ""
LOCAL lQuery     := .F.
LOCAL lRet       := .F.
LOCAL cProdRef	 := ""
LOCAL lSkip		 := .F.    
LOCAL cCodProd 	 := ""
LOCAL nQtdIt   	 := 0
LOCAL cDescProd	 := ""
LOCAL cGrade   	 := ""
LOCAL cUnidade 	 := ""
LOCAL cLocaliza	 := ""
LOCAL cLote	 	 := ""
LOCAL cLocal 	 := ""                
LOCAL cSubLote   := ""
LOCAL dDtValid   := dDatabase
LOCAL nPotencia  := 0
Local lPyme      := Iif(Type("__lPyme") <> "U",__lPyme,.F.)
Local nX         := 0
Local cName      := ""
Local cQryAd     := ""
Local cNFiscal	 := ""
Local cSerie	 := ""
Local lAglutGrad := .F.

If lPyme
	cabec1 	 := OemToAnsi("Codigo          Desc. do Material              UM Quantidade                     Lote      SubLote  Validade   Potencia    Nota") //"Codigo          Desc. do Material              UM Quantidade                     Lote      SubLote  Validade   Potencia    Nota"
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para Impressao do Cabecalho e Rodape    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
li := 80
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Definicao dos cabecalhos                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
titulo := OemToAnsi("PICK-LIST")	// "PICK-LIST"
// "Codigo          Desc. do Material              UM Quantidade  Amz Endereco       Lote      SubLote  Dat.de Validade Potencia"
//            1         2         3         4         5         6         7         8         9        10        11        12        13      
//  0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012
#IFDEF TOP
	If TcSrvType() <> "AS/400"
	    cAliasSD2:= "C775Imp"
	    aStruSD2  := SD2->(dbStruct())		
		lQuery    := .T.
		cQuery := "SELECT SD2.R_E_C_N_O_ SD2REC,"
		cQuery += "SD2.D2_DOC,SD2.D2_FILIAL,SD2.D2_SERIE,SD2.D2_QUANT,SD2.D2_COD, "
		cQuery += "SD2.D2_LOCAL,SD2.D2_GRADE,SD2.D2_LOTECTL,SD2.D2_POTENCI,"
		cQuery += "SD2.D2_NUMLOTE,SD2.D2_DTVALID,SD2.D2_PEDIDO,SD2.D2_ITEMPV"

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Esta rotina foi escrita para adicionar no select os campos do SD2 usados no filtro do usuario ³
		//³quando houver, a rotina acrecenta somente os campos que forem adicionados ao filtro testando  ³
	    //³se os mesmo ja existem no selec ou se forem definidos novamente pelo o usuario no filtro.     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !Empty(aReturn[7])
			For nX := 1 To SD2->(FCount())
		 		cName := SD2->(FieldName(nX))
				If AllTrim( cName ) $ aReturn[7]
					If aStruSD2[nX,2] <> "M"
						If !cName $ cQuery .And. !cName $ cQryAd
							cQryAd += ",SD2."+ cName
						EndIf
					EndIf
				EndIf
			Next nX
		EndIf
		cQuery += cQryAd
		
		cQuery += " FROM "
		cQuery += RetSqlName("SD2") + " SD2 "
		cQuery += "WHERE "                   
		cQuery += IIf(!Empty(mv_par03),"SD2.D2_SERIE = '"+mv_par03+"' AND ","SD2.D2_QUANT > 0 AND ")		
		cQuery += "SD2.D2_DOC >= '"+mv_par01+"' AND " 
		cQuery += "SD2.D2_DOC <= '"+mv_par02+"' AND " 
		cQuery += "NOT ("+IsRemito(3,'SD2.D2_TIPODOC')+ ") AND "
		cQuery += "SD2.D2_FILIAL = '"+xFilial("SD2")+"' AND "
		cQuery += "SD2.D_E_L_E_T_ = ' ' "
		cQuery += "ORDER BY SD2.D2_FILIAL,SD2.D2_DOC,SD2.D2_SERIE,SD2.D2_CLIENTE,SD2.D2_LOJA,SD2.D2_COD,SD2.D2_LOTECTL,"
		cQuery += "SD2.D2_NUMLOTE,SD2.D2_DTVALID"
				
		cQuery := ChangeQuery(cQuery)
    	
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSD2,.T.,.T.)

		For nSD2 := 1 To Len(aStruSD2)
			If aStruSD2[nSD2][2] <> "C" .and.  FieldPos(aStruSD2[nSD2][1]) > 0
				TcSetField(cAliasSD2,aStruSD2[nSD2][1],aStruSD2[nSD2][2],aStruSD2[nSD2][3],aStruSD2[nSD2][4])
			EndIf
		Next nSD2
	Else
#ENDIF	         
		dbSelectArea(cString)
		cIndexSD2  := CriaTrab(nil,.f.)
		cKey :="D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD+D2_LOTECTL+D2_NUMLOTE+DTOS(D2_DTVALID)"		
		cFilter := "D2_FILIAL = '" + xFilial("SD2") + "' .And. "
		cFilter += IIf(!Empty(mv_par03),"D2_SERIE = '"+mv_par03+"' .And. ","D2_QUANT > 0 .And. ")		
		cFilter += "D2_DOC >= '"+mv_par01+"' .And. " 
		cFilter += "D2_DOC <= '"+mv_par02+"'" 
		cFilter += '.And. !('+IsRemito(2,'SD2->D2_TIPODOC')+')'		

		IndRegua(cAliasSD2,cIndexSD2,cKey,,cFilter,"Selecionando Registros...")//"Selecionando Registros..."	   
		#IFNDEF TOP
			DbSetIndex(cIndexSD2+OrdBagExt())
		#ENDIF                           
		SetRegua(RecCount())		// Total de Elementos da regua
		DbGoTop()
		
#IFDEF TOP
	Endif
#ENDIF	

While (cAliasSD2)->(!Eof())
	//	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//	³ Valida o produto conforme a mascara         ³
	//	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	lRet:=ValidMasc((cAliasSD2)->D2_COD,MV_PAR04)
	If lRet .and. !Empty(aReturn[7])    
		lRet := &(aReturn[7])
	Endif
	If lRet
		IF lEnd
			@PROW()+1,001 Psay "CANCELADO PELO OPERADOR"	//"CANCELADO PELO OPERADOR"
			lContinua := .F.
			Exit
		Endif 
		If !lQuery
			IncRegua()
		EndIf	
		IF li > 55 .or. lFirst
			lFirst  := .f.
			cabec(titulo,cabec1,cabec2,nomeprog,tamanho,15)
			lRodape := .T.
		Endif
		dbSelectArea("SB1")
		dbSeek(xFilial("SB1") + (cAliasSD2)->D2_COD)
		dbSelectArea("SC6")
		dbSeek(xFilial("SC6") + (cAliasSD2)->D2_PEDIDO + (cAliasSD2)->D2_ITEMPV + (cAliasSD2)->D2_COD )
		cCodProd := (cAliasSD2)->D2_COD
		nQtdIt   := (cAliasSD2)->D2_QUANT
		cDescProd:= Subs(SB1->B1_DESC,1,30)
		cGrade   := (cAliasSD2)->D2_GRADE
		cUnidade := SB1->B1_UM		             
		cLocaliza:= SC6->C6_LOCALIZ
		cLote	 := (cAliasSD2)->D2_LOTECTL
		cLocal 	 := (cAliasSD2)->D2_LOCAL                
		cSubLote := (cAliasSD2)->D2_NUMLOTE              
		dDtValid := (cAliasSD2)->D2_DTVALID
		nPotencia:= (cAliasSD2)->D2_POTENCI
		cNFiscal := (cAliasSD2)->D2_DOC
		cSerie   := (cAliasSD2)->D2_SERIE
		lSkip := .F.
		lAglutGrad := (cGrade == "S" .and. MV_PAR05 == 1) 
		If lAglutGrad
			cProdRef 	:=Substr(cCodProd,1,nTamRef)
			SB4->(DbSeek(xFilial("SB4") + cProdRef))
			cDescProd:= Subs(SB4->B4_DESC,1,30)
		Endif
		If MV_PAR06 == 1
			nTotQuant := 0
			While (cAliasSD2)->(!Eof()) .And.;
				If(lAglutGrad,(cProdRef == Substr((cAliasSD2)->D2_COD,1,nTamRef)),cCodProd == (cAliasSD2)->D2_COD) .And.;
				(cLote == (cAliasSD2)->D2_LOTECTL .And. cSubLote == (cAliasSD2)->D2_NUMLOTE) .And. ;
				(cAliasSD2)->D2_DOC == cNFiscal .And. (cAliasSD2)->D2_SERIE == cSerie
				
				nTotQuant += (cAliasSD2)->D2_QUANT
				(cAliasSD2)->(dbSkip())
				lSkip := .T.
			Enddo
		Else
			IF cGrade == "S" .and. MV_PAR05 == 1
				cProdRef 	:=Substr(cCodProd,1,nTamRef)
				nTotQuant	:=0
				While (cAliasSD2)->(!Eof()) .And. cProdRef == Substr((cAliasSD2)->D2_COD,1,nTamRef) .And. (cAliasSD2)->D2_GRADE == "S" .And.;
					(cLote == (cAliasSD2)->D2_LOTECTL .And. cSubLote == (cAliasSD2)->D2_NUMLOTE) .And. ;
					(cAliasSD2)->D2_DOC == cNFiscal .And. (cAliasSD2)->D2_SERIE == cSerie
					nTotQuant += (cAliasSD2)->D2_QUANT
					(cAliasSD2)->(dbSkip())
					lSkip := .T.
				End
			Endif
		Endif
		@ li, 00 Psay IIF(lAglutGrad ,Substr(cCodProd,1,ntamref),cCodProd)  Picture "@!"
		@ li, 31 Psay cDescProd	Picture "@!"
		@ li, 62 Psay cUnidade Picture "@!"
		@ li, 65 Psay IIF(lAglutGrad .Or. MV_PAR06 == 1,nTotQuant,nQtdIt) Picture "@E 999,999.99"
		@ li, 77 Psay cLocal
		If !lPyme
			@ li, 81 Psay cLocaliza
		EndIf	
		@ li, 96 Psay cLote	Picture "@!"
		@ li,106 Psay cSubLote	Picture "@!"
		@ li,116 Psay dDtValid	Picture PesqPict("SD2","D2_DTVALID")
		@ li,131 PSay nPotencia Picture PesqPict("SD2","D2_POTENCI")
		@ li,Iif(cPaisloc == "BRA",138,140) Psay cNFiscal Picture "@!"
		
		li++
	EndIf

	dbSelectArea(cAliasSD2)
	If !lSkip	
		dbSkip()
	EndIf	
	
End

IF lRodape
	roda(cbcont,cbtxt,"M")
Endif

If lQuery   
    dbSelectArea(cAliasSD2)
	dbCloseArea()  
	dbSelectArea("SD2")
Else
	RetIndex("SD2")   
	Ferase(cIndexSD2+OrdBagExt())
	dbSelectArea("SD2")
	dbClearFilter()
	dbSetOrder(1)
	dbGotop()
Endif	

If aReturn[5] = 1
	Set Printer TO
	dbCommitAll()
	OurSpool(wnrel)
Endif

MS_FLUSH()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AjustaSX1 ºAutor  ³                    º Data ³             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MATR775 AP7                                                º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function AjustaSX1(cPerg)

Local aHelpPor	:= {}
Local aHelpEng	:= {}
Local aHelpSpa	:= {}
Local cKey := ""

aHelpPor := {}
aHelpEng := {}
aHelpSpa := {}     
Aadd(aHelpPor,"Informe se os produtos iguais serao ")
Aadd(aHelpPor,"aglutinados.                        ")  
//
Aadd(aHelpSpa,"Informe si los productos iguales seran")
Aadd(aHelpSpa,"agrupados.                            ") 
//
Aadd(aHelpEng,"Indicate if similar products will be ")
Aadd(aHelpEng,"grouped.                             ") 
//
PutSX1(cPerg,"06","Aglutinar produtos ?","¿Agrupar productos ?","Group products ?","mv_ch6","N",1,0,2,"C","","","","S","mv_par06","Sim","Si","Yes","","Nao","No","No" 	)
ckey := "P." + cPerg + "06."
PutSX1Help(cKey,aHelpPor,aHelpEng,aHelpSpa)
Return