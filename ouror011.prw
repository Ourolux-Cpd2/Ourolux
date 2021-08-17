#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "SHELL.CH" 

/*/an
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ OUROR011 ³ Autor ³ EDUARDO LOBATO	    ³ Data ³ 01/08/14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Emissao do Relatorio de Cotacao			                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGACOM                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ PROGRAMADOR  ³ DATA   ³ BOPS ³  MOTIVO DA ALTERACAO                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³                                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function OUROR011()
	
	Local   cPerg      		:= "OUROR011  "

	Private nPag			:= 1
	Private aTRB           	:= {}
	Private aTRB2          	:= {}
	Private cDirTmp 		:= GetTempPath()
	Private lCont			:= .F.

	if Pergunte(cPerg,.t.)//CONFIRMACAO DOS PARAMETROS
		Processa( {|| GERADADOS()},"Processando...", "Aguarde") //PROCESSAMENTO DOS CALCULOS
	endif

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GERADADOS ºAutor  ³Microsiga           º Data ³  23/05/19   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function GERADADOS()

	Local X
	Local lIMP			:= .F.
	Local aSC 			:= {}
	Local aCampos 		:= {}
	Local cNomArq		:= ""
	Local cNomArq1		:= ""
	Local nPos			:= 0
	Local cNUM			:= ""
	Local aFOR			:= {}
	Local aValCot		:= {}
	Local nRank			:= 1
	Local nlx			:= 0
	Local aValTot		:= {}
	Local cPos			:= ""
	Local nly			:= 0
	Local aFimCot		:= {}
	Local nPFim			:= 0
	Private aFORNECE 	:= {}
	Private cNumCot		:= ""
    
	//FONTES A SEREM UTILIZADAS
	Private oFont2 := TFont():New( "Times New Roman",,10,,.t.,,,,,.f. )
	Private oFont3 := TFont():New( "Times New Roman",,12,,.t.,,,,,.f. )
	Private oFont4 := TFont():New( "Times New Roman",,14,,.t.,,,,,.f. )

	Private oFont09n	:= TFont():New( "Courier New" 	,,09,,.t.,,,,,.f. )
	Private oFont6nN	:= TFont():New( "Courier New" 	,,06,,.t.,,,,,.f. )

	Private oFont06b	:= TFont():New( "Calibri" 		,,06,,.t.,,,,,.f. )

	Private oFont08b	:= TFont():New( "Calibri" 		,,08,,.t.,,,,,.f. )
	Private oFont08n	:= TFont():New( "Courier New"	,,08,,.t.,,,,,.f. )
	
	
	IF SELECT("TBR") > 0
		TBR->(DbCloseArea())
	ENDIF

	AADD(aCampos,{ "BR_NUM"    ,"C",06,0 } )
	AADD(aCampos,{ "BR_CODIGO" ,"C",15,0 } )
	AADD(aCampos,{ "BR_DESC"   ,"C",30,0 } )
	AADD(aCampos,{ "BR_ITEMCT" ,"C",04,0 } )
	AADD(aCampos,{ "BR_QTDE"   ,"N",12,2 } )
	AADD(aCampos,{ "BR_UM"     ,"C",02,0 } )
	AADD(aCampos,{ "BR_FOR01"  ,"C",08,0 } )
	AADD(aCampos,{ "BR_NOM01"  ,"C",25,0 } )
	AADD(aCampos,{ "BR_UNI01"  ,"N",12,2 } )
	AADD(aCampos,{ "BR_TOT01"  ,"N",14,2 } )
	AADD(aCampos,{ "BR_UNP01"  ,"N",14,2 } ) 
	AADD(aCampos,{ "BR_ULC01"  ,"D",08,0 } )
	AADD(aCampos,{ "BR_DES01"  ,"N",14,2 } )
	AADD(aCampos,{ "BR_CON01"  ,"C",03,0 } )
	AADD(aCampos,{ "BR_ENT01"  ,"D",08,0 } )
	AADD(aCampos,{ "BR_FRE01"  ,"N",14,2 } )
	AADD(aCampos,{ "BR_IPI01"  ,"N",14,2 } )
	AADD(aCampos,{ "BR_ICM01"  ,"N",14,2 } )
	AADD(aCampos,{ "BR_FAT01"  ,"N",12,2 } )
	AADD(aCampos,{ "BR_POS01"  ,"C",2,0 } )
	AADD(aCampos,{ "BR_FOR02"  ,"C",08,0 } )
	AADD(aCampos,{ "BR_NOM02"  ,"C",25,0 } )
	AADD(aCampos,{ "BR_UNI02"  ,"N",12,2 } )
	AADD(aCampos,{ "BR_TOT02"  ,"N",14,2 } )
	AADD(aCampos,{ "BR_DES02"  ,"N",14,2 } )
	AADD(aCampos,{ "BR_CON02"  ,"C",03,0 } )
	AADD(aCampos,{ "BR_ENT02"  ,"D",08,0 } )
	AADD(aCampos,{ "BR_FRE02"  ,"N",14,2 } )
	AADD(aCampos,{ "BR_IPI02"  ,"N",14,2 } )
	AADD(aCampos,{ "BR_ICM02"  ,"N",14,2 } )
	AADD(aCampos,{ "BR_FAT02"  ,"N",12,2 } )
	AADD(aCampos,{ "BR_POS02"  ,"C",2,0 } )
	AADD(aCampos,{ "BR_FOR03"  ,"C",08,0 } )
	AADD(aCampos,{ "BR_NOM03"  ,"C",25,0 } )
	AADD(aCampos,{ "BR_UNI03"  ,"N",12,2 } )
	AADD(aCampos,{ "BR_TOT03"  ,"N",14,2 } )
	AADD(aCampos,{ "BR_DES03"  ,"N",14,2 } )
	AADD(aCampos,{ "BR_CON03"  ,"C",03,0 } )
	AADD(aCampos,{ "BR_ENT03"  ,"D",08,0 } )
	AADD(aCampos,{ "BR_FRE03"  ,"N",14,2 } )
	AADD(aCampos,{ "BR_IPI03"  ,"N",14,2 } )
	AADD(aCampos,{ "BR_ICM03"  ,"N",14,2 } )
	AADD(aCampos,{ "BR_FAT03"  ,"N",12,2 } )
	AADD(aCampos,{ "BR_POS03"  ,"C",2,0 } )
	AADD(aCampos,{ "BR_FOR04"  ,"C",08,0 } )
	AADD(aCampos,{ "BR_NOM04"  ,"C",25,0 } )
	AADD(aCampos,{ "BR_UNI04"  ,"N",12,2 } )
	AADD(aCampos,{ "BR_TOT04"  ,"N",14,2 } )
	AADD(aCampos,{ "BR_DES04"  ,"N",14,2 } )
	AADD(aCampos,{ "BR_CON04"  ,"C",03,0 } )
	AADD(aCampos,{ "BR_ENT04"  ,"D",08,0 } )
	AADD(aCampos,{ "BR_FRE04"  ,"N",14,2 } )
	AADD(aCampos,{ "BR_IPI04"  ,"N",14,2 } )
	AADD(aCampos,{ "BR_ICM04"  ,"N",14,2 } )
	AADD(aCampos,{ "BR_FAT04"  ,"N",12,2 } )
	AADD(aCampos,{ "BR_POS04"  ,"C",2,0 } )
	AADD(aCampos,{ "BR_FOR05"  ,"C",08,0 } )
	AADD(aCampos,{ "BR_NOM05"  ,"C",25,0 } )
	AADD(aCampos,{ "BR_UNI05"  ,"N",12,2 } )
	AADD(aCampos,{ "BR_TOT05"  ,"N",14,2 } )
	AADD(aCampos,{ "BR_DES05"  ,"N",14,2 } )
	AADD(aCampos,{ "BR_CON05"  ,"C",03,0 } )
	AADD(aCampos,{ "BR_ENT05"  ,"D",08,0 } )
	AADD(aCampos,{ "BR_FRE05"  ,"N",14,2 } )
	AADD(aCampos,{ "BR_IPI05"  ,"N",14,2 } )
	AADD(aCampos,{ "BR_ICM05"  ,"N",14,2 } )
	AADD(aCampos,{ "BR_FAT05"  ,"N",12,2 } )
	AADD(aCampos,{ "BR_POS05"  ,"C",2,0 } )
	AADD(aCampos,{ "BR_FOR06"  ,"C",08,0 } )// Fornecedor 06
	AADD(aCampos,{ "BR_NOM06"  ,"C",25,0 } )
	AADD(aCampos,{ "BR_UNI06"  ,"N",12,2 } )
	AADD(aCampos,{ "BR_TOT06"  ,"N",14,2 } )
	AADD(aCampos,{ "BR_DES06"  ,"N",14,2 } )
	AADD(aCampos,{ "BR_CON06"  ,"C",03,0 } )
	AADD(aCampos,{ "BR_ENT06"  ,"D",08,0 } )
	AADD(aCampos,{ "BR_FRE06"  ,"N",14,2 } )
	AADD(aCampos,{ "BR_IPI06"  ,"N",14,2 } )
	AADD(aCampos,{ "BR_ICM06"  ,"N",14,2 } )
	AADD(aCampos,{ "BR_FAT06"  ,"N",12,2 } )
	AADD(aCampos,{ "BR_POS06"  ,"C",2,0 } )
	AADD(aCampos,{ "BR_FOR07"  ,"C",08,0 } )// Fornecedor 07
	AADD(aCampos,{ "BR_NOM07"  ,"C",25,0 } )
	AADD(aCampos,{ "BR_UNI07"  ,"N",12,2 } )
	AADD(aCampos,{ "BR_TOT07"  ,"N",14,2 } )
	AADD(aCampos,{ "BR_DES07"  ,"N",14,2 } )
	AADD(aCampos,{ "BR_CON07"  ,"C",03,0 } )
	AADD(aCampos,{ "BR_ENT07"  ,"D",08,0 } )
	AADD(aCampos,{ "BR_FRE07"  ,"N",14,2 } )
	AADD(aCampos,{ "BR_IPI07"  ,"N",14,2 } )
	AADD(aCampos,{ "BR_ICM07"  ,"N",14,2 } )
	AADD(aCampos,{ "BR_FAT07"  ,"N",12,2 } )
	AADD(aCampos,{ "BR_POS07"  ,"C",2,0 } )
	AADD(aCampos,{ "BR_FOR08"  ,"C",08,0 } )// Fornecedor 08
	AADD(aCampos,{ "BR_NOM08"  ,"C",25,0 } )
	AADD(aCampos,{ "BR_UNI08"  ,"N",12,2 } )
	AADD(aCampos,{ "BR_TOT08"  ,"N",14,2 } )
	AADD(aCampos,{ "BR_DES08"  ,"N",14,2 } )
	AADD(aCampos,{ "BR_CON08"  ,"C",03,0 } )
	AADD(aCampos,{ "BR_ENT08"  ,"D",08,0 } )
	AADD(aCampos,{ "BR_FRE08"  ,"N",14,2 } )
	AADD(aCampos,{ "BR_IPI08"  ,"N",14,2 } )
	AADD(aCampos,{ "BR_ICM08"  ,"N",14,2 } )
	AADD(aCampos,{ "BR_FAT08"  ,"N",12,2 } )
	AADD(aCampos,{ "BR_POS08"  ,"C",2,0 } )
	AADD(aCampos,{ "BR_FOR09"  ,"C",08,0 } )// Fornecedor 09
	AADD(aCampos,{ "BR_NOM09"  ,"C",25,0 } )
	AADD(aCampos,{ "BR_UNI09"  ,"N",12,2 } )
	AADD(aCampos,{ "BR_TOT09"  ,"N",14,2 } )
	AADD(aCampos,{ "BR_DES09"  ,"N",14,2 } )
	AADD(aCampos,{ "BR_CON09"  ,"C",03,0 } )
	AADD(aCampos,{ "BR_ENT09"  ,"D",08,0 } )
	AADD(aCampos,{ "BR_FRE09"  ,"N",14,2 } )
	AADD(aCampos,{ "BR_IPI09"  ,"N",14,2 } )
	AADD(aCampos,{ "BR_ICM09"  ,"N",14,2 } )
	AADD(aCampos,{ "BR_FAT09"  ,"N",12,2 } )
	AADD(aCampos,{ "BR_POS09"  ,"C",2,0 } )
	AADD(aCampos,{ "BR_FOR10"  ,"C",08,0 } )// Fornecedor 10
	AADD(aCampos,{ "BR_NOM10"  ,"C",25,0 } )
	AADD(aCampos,{ "BR_UNI10"  ,"N",12,2 } )
	AADD(aCampos,{ "BR_TOT10"  ,"N",14,2 } )
	AADD(aCampos,{ "BR_DES10"  ,"N",14,2 } )
	AADD(aCampos,{ "BR_CON10"  ,"C",03,0 } )
	AADD(aCampos,{ "BR_ENT10"  ,"D",08,0 } )
	AADD(aCampos,{ "BR_FRE10"  ,"N",14,2 } )
	AADD(aCampos,{ "BR_IPI10"  ,"N",14,2 } )
	AADD(aCampos,{ "BR_ICM10"  ,"N",14,2 } )
	AADD(aCampos,{ "BR_FAT10"  ,"N",12,2 } )
	AADD(aCampos,{ "BR_POS10"  ,"C",2,0 } )

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Cria arquivo de trabalho                                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	cNomArq 	:=  CriaTrab(aCampos)
	DbUseArea( .T.,, cNomArq,"TBR", .F. , .F. )

	cNomArq1 := Subs(cNomArq,1,7)+"A"
	IndRegua("TBR",cNomArq1,"BR_NUM + BR_ITEMCT",,,) 
	DbClearIndex()

	DbSetIndex(cNomArq1 + OrdBagExt())

	TBR->(DbSetOrder(1))

	IF SELECT("TMP") > 0
		TMP->(DBCLOSEAREA())
	ENDIF

	cQuery := " SELECT * " + CHR(13) + CHR(10)
	cQuery += " FROM " + RetSqlName("SC8") + " AS SC8 "	 + CHR(13) + CHR(10)
	cQuery += " INNER JOIN " + RetSqlName("SA2") + " SA2 ON (A2_COD = C8_FORNECE  AND A2_LOJA = C8_LOJA AND SA2.D_E_L_E_T_ <> '*') " + CHR(13) + CHR(10)
	cQuery += " INNER JOIN " + RetSqlName("SB1") + " SB1 ON (B1_COD = C8_PRODUTO  AND SB1.D_E_L_E_T_ <> '*') " + CHR(13) + CHR(10)
	cQuery += " WHERE C8_FILIAL = '"+XFILIAL("SC8")+"' " + CHR(13) + CHR(10)
	cQuery += " AND C8_EMISSAO BETWEEN '" + DtoS(MV_PAR03) +  "' AND '" + DtoS(MV_PAR04) + "' " + CHR(13) + CHR(10)
	cQuery += " AND C8_NUM >= '" + MV_PAR01 + "' "	+ CHR(13) + CHR(10)
	cQuery += " AND C8_NUM <= '" + MV_PAR02 + "' "	+ CHR(13) + CHR(10)
	cQuery += " AND C8_PRODUTO >= '" + MV_PAR05 + "' " + CHR(13) + CHR(10)
	cQuery += " AND C8_PRODUTO <= '" + MV_PAR06 + "' " + CHR(13) + CHR(10)
	cQuery += " AND C8_PRECO > 0 " + CHR(13) + CHR(10)
	cQuery += " AND SC8.D_E_L_E_T_ <> '*' " + CHR(13) + CHR(10)
	cQuery += " ORDER BY C8_NUM, C8_PRODUTO, C8_FORNECE " + CHR(13) + CHR(10)

	TCQUERY cQuery NEW ALIAS "TMP" 

	While TMP->(!Eof())

		lIMP := .t.
		nPos:= ASCAN(aFORNECE, { |x|x[1] + x[2] == TMP->C8_NUM + TMP->A2_COD + TMP->A2_LOJA  })

		If nPos = 0
			AADD(aFORNECE,{TMP->C8_NUM,TMP->A2_COD + TMP->A2_LOJA,TMP->A2_NREDUZ})
		EndIf
		
		nPos:= ASCAN(aSC, { |x|x[2] + x[1] == TMP->C8_NUMSC + TMP->C8_NUM  })

		If nPos = 0
			AADD(aSC,{TMP->C8_NUM,TMP->C8_NUMSC})
		EndIf

		TMP->(DbSkip())

	End

	TMP->(DbGoTop())

	While TMP->(!Eof())
	
		cNUM := TMP->C8_NUM
	
		aFOR := {}       
		                 
		For X:=1 To LEN(aFORNECE)
	
			If aFORNECE[X][1] == cNUM
				AADD(aFOR,{cNUM,aFORNECE[X][2],aFORNECE[X][3]})
			EndIf
			
		End
		
		While TMP->(!Eof()) .And. cNUM == TMP->C8_NUM
		
			nPOS:= 0
			
			For X:=1 To Len(aFOR)
				
				If aFOR[X][2] == TMP->A2_COD + TMP->A2_LOJA  .AND. aFOR[X][1] == cNUM
					nPOS	:= X
				EndIf
				
			Next
		
			IF nPOS == 0
				TMP->(DbSkip())
				Loop
			EndIf
		
			TBR->(DbSetOrder(1))
			TBR->(DbGoTop())
		
			IF TBR->(!DBSEEK(TMP->C8_NUM + TMP->C8_ITEM)) // Claudino - 16/02/16 - Estava IF !TBR->(DBSEEK(TMP->C8_NUM+TMP->C8_PRODUTO+TMP->C8_ITEMSC))

				RECLOCK("TBR",.T.)
				
				TBR->BR_NUM		:= TMP->C8_NUM
				TBR->BR_CODIGO	:= TMP->C8_PRODUTO
				TBR->BR_DESC	:= TMP->B1_DESC
				//TBR->BR_ITEMCT	:= TMP->C8_ITEM    // Claudino - 16/02/16 - Estava TBR->BR_ITEMSC := TMP->C8_ITEMSC
				TBR->BR_ITEMCT	:= TMP->C8_IDENT //Andre Salgado 14/12/2020 - Sol.Solange, quando muda o "C8_ITEM" estava desposicionando, troquei para usar sempre "C8_IDENT" //Antes estava a linha de cima
				TBR->BR_QTDE	:= TMP->C8_QUANT
				TBR->BR_UM		:= TMP->C8_UM
                
				If SELECT("TMX") > 0
					TMX->(DBCLOSEAREA())
				EndIf
				
				cQuery := " SELECT SD1.D1_DTDIGIT, SD1.D1_VUNIT  " + CHR(13) + CHR(10)
				cQuery += " FROM " + RetSqlName("SD1") + " SD1 "	 + CHR(13) + CHR(10)
				cQuery += " WHERE SD1.D1_FILIAL = '"+XFILIAL("SD1") + "' " + CHR(13) + CHR(10)
				cQuery += " AND SD1.D1_COD = '" + AllTrim(TMP->C8_PRODUTO) +  "' " + CHR(13) + CHR(10)
				cQuery += " AND SD1.D1_TIPO = 'N' " + CHR(13) + CHR(10)					
				cQuery += " AND SD1.D1_PEDIDO > '' " + CHR(13) + CHR(10)
				cQuery += " AND SD1.D_E_L_E_T_ <> '*' " + CHR(13) + CHR(10)
				cQuery += " ORDER BY D1_DTDIGIT " + CHR(13) + CHR(10)		
		
				TCQUERY cQuery NEW ALIAS "TMX" 
					
				TMX->(DbGoTop())
					
				While TMX->(!EOF())
				
					If !Empty(TMX->D1_VUNIT)
						TBR->BR_UNP01	:= TMX->D1_VUNIT
						TBR->BR_ULC01 	:= Stod(TMX->D1_DTDIGIT)
					EndIf
						
					TMX->(DbSkip())
						
				End

				IF nPOS == 1
				
					TBR->BR_FOR01		:= TMP->A2_COD + TMP->A2_LOJA
					TBR->BR_NOM01		:= TMP->A2_NREDUZ
					TBR->BR_UNI01		:= TMP->C8_PRECO
					TBR->BR_TOT01		:= TMP->C8_TOTAL
					TBR->BR_DES01		:= TMP->C8_VLDESC
					TBR->BR_CON01		:= TMP->C8_COND
					TBR->BR_ENT01		:= STOD(TMP->C8_DATPRF)
					TBR->BR_FRE01		:= TMP->C8_VALFRE
					TBR->BR_IPI01		:= TMP->C8_VALIPI
					TBR->BR_ICM01     	:= TMP->C8_VALSOL
					TBR->BR_FAT01     	:= TMP->A2_XFATMIN // william Souza - Ethosx Consultoria e Soluções - 08/01/19
                    
					/*---------------------------------------------------------------------------------------
					Autor: William Souza - Ethosx Consultoria e Soluções
					Data.: 02/01/19

					Detalhe:
					Incluindo valores no vetor aTRB que será utilizado para imprimir os itens de menor valor 
					do fornecedor
					-- INCLUIDO --
					----------------------------------------------------------------------------------------*/
					aadd(aTRB,{1,TBR->BR_CODIGO,TBR->BR_FOR01,TBR->BR_UNI01,TBR->BR_TOT01})

				ElseIf nPOS == 2
				
					TBR->BR_FOR02		:= TMP->A2_COD + TMP->A2_LOJA
					TBR->BR_NOM02		:= TMP->A2_NREDUZ
					TBR->BR_UNI02		:= TMP->C8_PRECO
					TBR->BR_TOT02		:= TMP->C8_TOTAL
					TBR->BR_DES02		:= TMP->C8_VLDESC
					TBR->BR_CON02		:= TMP->C8_COND
					TBR->BR_ENT02		:= STOD(TMP->C8_DATPRF)
					TBR->BR_FRE02		:= TMP->C8_VALFRE
					TBR->BR_IPI02		:= TMP->C8_VALIPI
					TBR->BR_ICM02     	:= TMP->C8_VALSOL
					TBR->BR_FAT02     	:= TMP->A2_XFATMIN // william Souza - Ethosx Consultoria e Soluções - 08/01/19

					/*---------------------------------------------------------------------------------------
					Autor: William Souza - Ethosx Consultoria e Soluções
					Data.: 02/01/19

					Detalhe:
					Incluindo valores no vetor aTRB que será utilizado para imprimir os itens de menor valor 
					do fornecedor
					-- INCLUIDO --
					----------------------------------------------------------------------------------------*/
					aadd(aTRB,{2,TBR->BR_CODIGO,TBR->BR_FOR02,TBR->BR_UNI02,TBR->BR_TOT02})
			
				ElseIf nPOS == 3

					TBR->BR_FOR03		:= TMP->A2_COD+TMP->A2_LOJA
					TBR->BR_NOM03		:= TMP->A2_NREDUZ
					TBR->BR_UNI03		:= TMP->C8_PRECO
					TBR->BR_TOT03		:= TMP->C8_TOTAL
					TBR->BR_DES03		:= TMP->C8_VLDESC
					TBR->BR_CON03		:= TMP->C8_COND
					TBR->BR_ENT03		:= STOD(TMP->C8_DATPRF)
					TBR->BR_FRE03		:= TMP->C8_VALFRE
					TBR->BR_IPI03		:= TMP->C8_VALIPI
					TBR->BR_ICM03     	:= TMP->C8_VALSOL
					TBR->BR_FAT03     	:= TMP->A2_XFATMIN // william Souza - Ethosx Consultoria e Soluções - 08/01/19

					/*---------------------------------------------------------------------------------------
					Autor: William Souza - Ethosx Consultoria e Soluções
					Data.: 02/01/19

					Detalhe:
					Incluindo valores no vetor aTRB que será utilizado para imprimir os itens de menor valor 
					do fornecedor
					-- INCLUIDO --
					----------------------------------------------------------------------------------------*/
					aadd(aTRB,{3,TBR->BR_CODIGO,TBR->BR_FOR03,TBR->BR_UNI03,TBR->BR_TOT03})
			
				ElseIf nPOS == 4
				
					TBR->BR_FOR04		:= TMP->A2_COD + TMP->A2_LOJA
					TBR->BR_NOM04		:= TMP->A2_NREDUZ
					TBR->BR_UNI04		:= TMP->C8_PRECO
					TBR->BR_TOT04		:= TMP->C8_TOTAL
					TBR->BR_DES04		:= TMP->C8_VLDESC
					TBR->BR_CON04		:= TMP->C8_COND
					TBR->BR_ENT04		:= STOD(TMP->C8_DATPRF)
					TBR->BR_FRE04		:= TMP->C8_VALFRE
					TBR->BR_IPI04		:= TMP->C8_VALIPI
					TBR->BR_ICM04     	:= TMP->C8_VALSOL
					TBR->BR_FAT04     	:= TMP->A2_XFATMIN // william Souza - Ethosx Consultoria e Soluções - 08/01/19

					/*---------------------------------------------------------------------------------------
					Autor: William Souza - Ethosx Consultoria e Soluções
					Data.: 02/01/19

					Detalhe:
					Incluindo valores no vetor aTRB que será utilizado para imprimir os itens de menor valor 
					do fornecedor
					-- INCLUIDO --
					----------------------------------------------------------------------------------------*/
					aadd(aTRB,{4,TBR->BR_CODIGO,TBR->BR_FOR04,TBR->BR_UNI04,TBR->BR_TOT04})
			
				ElseIf nPOS == 5

					TBR->BR_FOR05		:= TMP->A2_COD + TMP->A2_LOJA
					TBR->BR_NOM05		:= TMP->A2_NREDUZ
					TBR->BR_UNI05		:= TMP->C8_PRECO
					TBR->BR_TOT05		:= TMP->C8_TOTAL
					TBR->BR_DES05		:= TMP->C8_VLDESC
					TBR->BR_CON05		:= TMP->C8_COND
					TBR->BR_ENT05		:= STOD(TMP->C8_DATPRF)
					TBR->BR_FRE05		:= TMP->C8_VALFRE
					TBR->BR_IPI05		:= TMP->C8_VALIPI
					TBR->BR_ICM05     	:= TMP->C8_VALSOL
					TBR->BR_FAT05     	:= TMP->A2_XFATMIN // william Souza - Ethosx Consultoria e Soluções - 08/01/19
					
					/*---------------------------------------------------------------------------------------
					Autor: William Souza - Ethosx Consultoria e Soluções
					Data.: 02/01/19

					Detalhe:
					Incluindo valores no vetor aTRB que será utilizado para imprimir os itens de menor valor 
					do fornecedor
					-- INCLUIDO --
					----------------------------------------------------------------------------------------*/
				
					aadd(aTRB,{5,TBR->BR_CODIGO,TBR->BR_FOR05,TBR->BR_UNI05,TBR->BR_TOT05})
					
				ElseIf nPOS == 6

					TBR->BR_FOR06		:= TMP->A2_COD + TMP->A2_LOJA
					TBR->BR_NOM06		:= TMP->A2_NREDUZ
					TBR->BR_UNI06		:= TMP->C8_PRECO
					TBR->BR_TOT06		:= TMP->C8_TOTAL
					TBR->BR_DES06		:= TMP->C8_VLDESC
					TBR->BR_CON06		:= TMP->C8_COND
					TBR->BR_ENT06		:= STOD(TMP->C8_DATPRF)
					TBR->BR_FRE06		:= TMP->C8_VALFRE
					TBR->BR_IPI06		:= TMP->C8_VALIPI
					TBR->BR_ICM06     	:= TMP->C8_VALSOL
					TBR->BR_FAT06     	:= TMP->A2_XFATMIN // william Souza - Ethosx Consultoria e Soluções - 08/01/19

					/*---------------------------------------------------------------------------------------
					Autor: William Souza - Ethosx Consultoria e Soluções
					Data.: 02/01/19

					Detalhe:
					Incluindo valores no vetor aTRB que será utilizado para imprimir os itens de menor valor 
					do fornecedor
					-- INCLUIDO --
					----------------------------------------------------------------------------------------*/
				
					aadd(aTRB,{6,TBR->BR_CODIGO,TBR->BR_FOR06,TBR->BR_UNI06,TBR->BR_TOT06})

				ElseIf nPOS == 7

					TBR->BR_FOR07		:= TMP->A2_COD + TMP->A2_LOJA
					TBR->BR_NOM07		:= TMP->A2_NREDUZ
					TBR->BR_UNI07		:= TMP->C8_PRECO
					TBR->BR_TOT07		:= TMP->C8_TOTAL
					TBR->BR_DES07		:= TMP->C8_VLDESC
					TBR->BR_CON07		:= TMP->C8_COND
					TBR->BR_ENT07		:= STOD(TMP->C8_DATPRF)
					TBR->BR_FRE07		:= TMP->C8_VALFRE
					TBR->BR_IPI07		:= TMP->C8_VALIPI
					TBR->BR_ICM07    	:= TMP->C8_VALSOL
					TBR->BR_FAT07     	:= TMP->A2_XFATMIN // william Souza - Ethosx Consultoria e Soluções - 08/01/19

					/*---------------------------------------------------------------------------------------
					Autor: William Souza - Ethosx Consultoria e Soluções
					Data.: 02/01/19

					Detalhe:
					Incluindo valores no vetor aTRB que será utilizado para imprimir os itens de menor valor 
					do fornecedor
					-- INCLUIDO --
					----------------------------------------------------------------------------------------*/
				
					aadd(aTRB,{7,TBR->BR_CODIGO,TBR->BR_FOR07,TBR->BR_UNI07,TBR->BR_TOT07})

				ElseIf nPOS == 8

					TBR->BR_FOR08		:= TMP->A2_COD + TMP->A2_LOJA
					TBR->BR_NOM08		:= TMP->A2_NREDUZ
					TBR->BR_UNI08		:= TMP->C8_PRECO
					TBR->BR_TOT08		:= TMP->C8_TOTAL
					TBR->BR_DES08		:= TMP->C8_VLDESC
					TBR->BR_CON08		:= TMP->C8_COND
					TBR->BR_ENT08		:= STOD(TMP->C8_DATPRF)
					TBR->BR_FRE08		:= TMP->C8_VALFRE
					TBR->BR_IPI08		:= TMP->C8_VALIPI
					TBR->BR_ICM08   	:= TMP->C8_VALSOL
					TBR->BR_FAT08     	:= TMP->A2_XFATMIN // william Souza - Ethosx Consultoria e Soluções - 08/01/19

					/*---------------------------------------------------------------------------------------
					Autor: William Souza - Ethosx Consultoria e Soluções
					Data.: 02/01/19

					Detalhe:
					Incluindo valores no vetor aTRB que será utilizado para imprimir os itens de menor valor 
					do fornecedor
					-- INCLUIDO --
					----------------------------------------------------------------------------------------*/
				
					aadd(aTRB,{8,TBR->BR_CODIGO,TBR->BR_FOR08,TBR->BR_UNI08,TBR->BR_TOT08})
			
				ElseIf nPOS == 9

					TBR->BR_FOR09		:= TMP->A2_COD + TMP->A2_LOJA
					TBR->BR_NOM09		:= TMP->A2_NREDUZ
					TBR->BR_UNI09		:= TMP->C8_PRECO
					TBR->BR_TOT09		:= TMP->C8_TOTAL
					TBR->BR_DES09		:= TMP->C8_VLDESC
					TBR->BR_CON09		:= TMP->C8_COND
					TBR->BR_ENT09		:= STOD(TMP->C8_DATPRF)
					TBR->BR_FRE09		:= TMP->C8_VALFRE
					TBR->BR_IPI09		:= TMP->C8_VALIPI
					TBR->BR_ICM09     	:= TMP->C8_VALSOL
					TBR->BR_FAT09     	:= TMP->A2_XFATMIN // william Souza - Ethosx Consultoria e Soluções - 08/01/19

					/*---------------------------------------------------------------------------------------
					Autor: William Souza - Ethosx Consultoria e Soluções
					Data.: 02/01/19

					Detalhe:
					Incluindo valores no vetor aTRB que será utilizado para imprimir os itens de menor valor 
					do fornecedor
					-- INCLUIDO --
					----------------------------------------------------------------------------------------*/
				
					aadd(aTRB,{9,TBR->BR_CODIGO,TBR->BR_FOR09,TBR->BR_UNI09,TBR->BR_TOT09})


				ElseIf nPOS == 10

					TBR->BR_FOR10		:= TMP->A2_COD + TMP->A2_LOJA
					TBR->BR_NOM10		:= TMP->A2_NREDUZ
					TBR->BR_UNI10		:= TMP->C8_PRECO
					TBR->BR_TOT10		:= TMP->C8_TOTAL
					TBR->BR_DES10		:= TMP->C8_VLDESC
					TBR->BR_CON10		:= TMP->C8_COND
					TBR->BR_ENT10		:= STOD(TMP->C8_DATPRF)
					TBR->BR_FRE10		:= TMP->C8_VALFRE
					TBR->BR_IPI10		:= TMP->C8_VALIPI
					TBR->BR_ICM10   	:= TMP->C8_VALSOL
					TBR->BR_FAT10     	:= TMP->A2_XFATMIN // william Souza - Ethosx Consultoria e Soluções - 08/01/19

					/*---------------------------------------------------------------------------------------
					Autor: William Souza - Ethosx Consultoria e Soluções
					Data.: 02/01/19

					Detalhe:
					Incluindo valores no vetor aTRB que será utilizado para imprimir os itens de menor valor 
					do fornecedor
					-- INCLUIDO --
					----------------------------------------------------------------------------------------*/
				
					aadd(aTRB,{10,TBR->BR_CODIGO,TBR->BR_FOR10,TBR->BR_UNI10,TBR->BR_TOT10})					
			
				ENDIF
				
				TBR->(MsUnLock())
				
			Else
			
				RECLOCK("TBR",.F.)
			
				IF nPOS == 1
					TBR->BR_FOR01		:= TMP->A2_COD + TMP->A2_LOJA
					TBR->BR_NOM01		:= TMP->A2_NREDUZ
					TBR->BR_UNI01		:= TMP->C8_PRECO
					TBR->BR_TOT01		:= TMP->C8_TOTAL
					TBR->BR_DES01		:= TMP->C8_VLDESC
					TBR->BR_CON01		:= TMP->C8_COND
					TBR->BR_ENT01		:= STOD(TMP->C8_DATPRF)
					TBR->BR_FRE01		:= TMP->C8_VALFRE
					TBR->BR_IPI01		:= TMP->C8_VALIPI
					TBR->BR_ICM01     	:= TMP->C8_VALSOL
					TBR->BR_FAT01     	:= TMP->A2_XFATMIN // william Souza - Ethosx Consultoria e Soluções - 08/01/19

					/*---------------------------------------------------------------------------------------
					Autor: William Souza - Ethosx Consultoria e Soluções
					Data.: 02/01/19

					Detalhe:
					Incluindo valores no vetor aTRB que será utilizado para imprimir os itens de menor valor 
					do fornecedor
					-- INCLUIDO --
					----------------------------------------------------------------------------------------*/
					aadd(aTRB,{1,TBR->BR_CODIGO,TBR->BR_FOR01,TBR->BR_UNI01,TBR->BR_TOT01})
				
				ElseIf nPOS == 2
		
					TBR->BR_FOR02		:= TMP->A2_COD+TMP->A2_LOJA
					TBR->BR_NOM02		:= TMP->A2_NREDUZ
					TBR->BR_UNI02		:= TMP->C8_PRECO
					TBR->BR_TOT02		:= TMP->C8_TOTAL
					TBR->BR_DES02		:= TMP->C8_VLDESC
					TBR->BR_CON02		:= TMP->C8_COND
					TBR->BR_ENT02		:= STOD(TMP->C8_DATPRF)
					TBR->BR_FRE02		:= TMP->C8_VALFRE
					TBR->BR_IPI02		:= TMP->C8_VALIPI
					TBR->BR_ICM02     	:= TMP->C8_VALSOL
					TBR->BR_FAT02     	:= TMP->A2_XFATMIN // william Souza - Ethosx Consultoria e Soluções - 08/01/19

					/*---------------------------------------------------------------------------------------
					Autor: William Souza - Ethosx Consultoria e Soluções
					Data.: 02/01/19

					Detalhe:
					Incluindo valores no vetor aTRB que será utilizado para imprimir os itens de menor valor 
					do fornecedor
					-- INCLUIDO --
					----------------------------------------------------------------------------------------*/
					aadd(aTRB,{2,TBR->BR_CODIGO,TBR->BR_FOR02,TBR->BR_UNI02,TBR->BR_TOT02})					
			
				ElseIf nPOS == 3

					TBR->BR_FOR03		:= TMP->A2_COD+TMP->A2_LOJA
					TBR->BR_NOM03		:= TMP->A2_NREDUZ
					TBR->BR_UNI03		:= TMP->C8_PRECO
					TBR->BR_TOT03		:= TMP->C8_TOTAL
					TBR->BR_DES03		:= TMP->C8_VLDESC
					TBR->BR_CON03		:= TMP->C8_COND
					TBR->BR_ENT03		:= STOD(TMP->C8_DATPRF)
					TBR->BR_FRE03		:= TMP->C8_VALFRE
					TBR->BR_IPI03		:= TMP->C8_VALIPI
					TBR->BR_ICM03     := TMP->C8_VALSOL
					TBR->BR_FAT03     := TMP->A2_XFATMIN // william Souza - Ethosx Consultoria e Soluções - 08/01/19

					/*---------------------------------------------------------------------------------------
					Autor: William Souza - Ethosx Consultoria e Soluções
					Data.: 02/01/19

					Detalhe:
					Incluindo valores no vetor aTRB que será utilizado para imprimir os itens de menor valor 
					do fornecedor
					-- INCLUIDO --
					----------------------------------------------------------------------------------------*/
					aadd(aTRB,{3,TBR->BR_CODIGO,TBR->BR_FOR03,TBR->BR_UNI03,TBR->BR_TOT03})	
			
				ElseIf nPOS == 4

					TBR->BR_FOR04		:= TMP->A2_COD+TMP->A2_LOJA
					TBR->BR_NOM04		:= TMP->A2_NREDUZ
					TBR->BR_UNI04		:= TMP->C8_PRECO
					TBR->BR_TOT04		:= TMP->C8_TOTAL
					TBR->BR_DES04		:= TMP->C8_VLDESC
					TBR->BR_CON04		:= TMP->C8_COND
					TBR->BR_ENT04		:= STOD(TMP->C8_DATPRF)
					TBR->BR_FRE04		:= TMP->C8_VALFRE
					TBR->BR_IPI04		:= TMP->C8_VALIPI
					TBR->BR_ICM04     := TMP->C8_VALSOL
					TBR->BR_FAT04     := TMP->A2_XFATMIN 

					/*---------------------------------------------------------------------------------------
					Autor: William Souza - Ethosx Consultoria e Soluções
					Data.: 02/01/19

					Detalhe:
					Incluindo valores no vetor aTRB que será utilizado para imprimir os itens de menor valor 
					do fornecedor
					-- INCLUIDO --
					----------------------------------------------------------------------------------------*/
					aadd(aTRB,{4,TBR->BR_CODIGO,TBR->BR_FOR04,TBR->BR_UNI04,TBR->BR_TOT04})
			
				ElseIf nPOS == 5

					TBR->BR_FOR05		:= TMP->A2_COD+TMP->A2_LOJA
					TBR->BR_NOM05		:= TMP->A2_NREDUZ
					TBR->BR_UNI05		:= TMP->C8_PRECO
					TBR->BR_TOT05		:= TMP->C8_TOTAL
					TBR->BR_DES05		:= TMP->C8_VLDESC
					TBR->BR_CON05		:= TMP->C8_COND
					TBR->BR_ENT05		:= STOD(TMP->C8_DATPRF)
					TBR->BR_FRE05		:= TMP->C8_VALFRE
					TBR->BR_IPI05		:= TMP->C8_VALIPI
					TBR->BR_ICM05     := TMP->C8_VALSOL
					TBR->BR_FAT05     := TMP->A2_XFATMIN // william Souza - Ethosx Consultoria e Soluções - 08/01/19

					/*---------------------------------------------------------------------------------------
					Autor: William Souza - Ethosx Consultoria e Soluções
					Data.: 02/01/19

					Detalhe:
					Incluindo valores no vetor aTRB que será utilizado para imprimir os itens de menor valor 
					do fornecedor
					-- INCLUIDO --
					----------------------------------------------------------------------------------------*/
					aadd(aTRB,{5,TBR->BR_CODIGO,TBR->BR_FOR05,TBR->BR_UNI05,TBR->BR_TOT05})
					
				ElseIf nPOS == 6

					TBR->BR_FOR06		:= TMP->A2_COD + TMP->A2_LOJA
					TBR->BR_NOM06		:= TMP->A2_NREDUZ
					TBR->BR_UNI06		:= TMP->C8_PRECO
					TBR->BR_TOT06		:= TMP->C8_TOTAL
					TBR->BR_DES06		:= TMP->C8_VLDESC
					TBR->BR_CON06		:= TMP->C8_COND
					TBR->BR_ENT06		:= STOD(TMP->C8_DATPRF)
					TBR->BR_FRE06		:= TMP->C8_VALFRE
					TBR->BR_IPI06		:= TMP->C8_VALIPI
					TBR->BR_ICM06     	:= TMP->C8_VALSOL
					TBR->BR_FAT06     	:= TMP->A2_XFATMIN // william Souza - Ethosx Consultoria e Soluções - 08/01/19

					/*---------------------------------------------------------------------------------------
					Autor: William Souza - Ethosx Consultoria e Soluções
					Data.: 02/01/19

					Detalhe:
					Incluindo valores no vetor aTRB que será utilizado para imprimir os itens de menor valor 
					do fornecedor
					-- INCLUIDO --
					----------------------------------------------------------------------------------------*/
					aadd(aTRB,{6,TBR->BR_CODIGO,TBR->BR_FOR06,TBR->BR_UNI06,TBR->BR_TOT06})
					
				ElseIf nPOS == 7

					TBR->BR_FOR07		:= TMP->A2_COD + TMP->A2_LOJA
					TBR->BR_NOM07		:= TMP->A2_NREDUZ
					TBR->BR_UNI07		:= TMP->C8_PRECO
					TBR->BR_TOT07		:= TMP->C8_TOTAL
					TBR->BR_DES07		:= TMP->C8_VLDESC
					TBR->BR_CON07		:= TMP->C8_COND
					TBR->BR_ENT07		:= STOD(TMP->C8_DATPRF)
					TBR->BR_FRE07		:= TMP->C8_VALFRE
					TBR->BR_IPI07		:= TMP->C8_VALIPI
					TBR->BR_ICM07     	:= TMP->C8_VALSOL
					TBR->BR_FAT07     	:= TMP->A2_XFATMIN // william Souza - Ethosx Consultoria e Soluções - 08/01/19

					/*---------------------------------------------------------------------------------------
					Autor: William Souza - Ethosx Consultoria e Soluções
					Data.: 02/01/19

					Detalhe:
					Incluindo valores no vetor aTRB que será utilizado para imprimir os itens de menor valor 
					do fornecedor
					-- INCLUIDO --
					----------------------------------------------------------------------------------------*/
					
					aadd(aTRB,{7,TBR->BR_CODIGO,TBR->BR_FOR07,TBR->BR_UNI07,TBR->BR_TOT07})					
			
				ElseIf nPOS == 8

					TBR->BR_FOR08		:= TMP->A2_COD + TMP->A2_LOJA
					TBR->BR_NOM08		:= TMP->A2_NREDUZ
					TBR->BR_UNI08		:= TMP->C8_PRECO
					TBR->BR_TOT08		:= TMP->C8_TOTAL
					TBR->BR_DES08		:= TMP->C8_VLDESC
					TBR->BR_CON08		:= TMP->C8_COND
					TBR->BR_ENT08		:= STOD(TMP->C8_DATPRF)
					TBR->BR_FRE08		:= TMP->C8_VALFRE
					TBR->BR_IPI08		:= TMP->C8_VALIPI
					TBR->BR_ICM08     	:= TMP->C8_VALSOL
					TBR->BR_FAT08     	:= TMP->A2_XFATMIN // william Souza - Ethosx Consultoria e Soluções - 08/01/19

					/*---------------------------------------------------------------------------------------
					Autor: William Souza - Ethosx Consultoria e Soluções
					Data.: 02/01/19

					Detalhe:
					Incluindo valores no vetor aTRB que será utilizado para imprimir os itens de menor valor 
					do fornecedor
					-- INCLUIDO --
					----------------------------------------------------------------------------------------*/
					
					aadd(aTRB,{8,TBR->BR_CODIGO,TBR->BR_FOR08,TBR->BR_UNI08,TBR->BR_TOT08})					
					
				ElseIf nPOS == 9

					TBR->BR_FOR09		:= TMP->A2_COD + TMP->A2_LOJA
					TBR->BR_NOM09		:= TMP->A2_NREDUZ
					TBR->BR_UNI09		:= TMP->C8_PRECO
					TBR->BR_TOT09		:= TMP->C8_TOTAL
					TBR->BR_DES09		:= TMP->C8_VLDESC
					TBR->BR_CON09		:= TMP->C8_COND
					TBR->BR_ENT09		:= STOD(TMP->C8_DATPRF)
					TBR->BR_FRE09		:= TMP->C8_VALFRE
					TBR->BR_IPI09		:= TMP->C8_VALIPI
					TBR->BR_ICM09     	:= TMP->C8_VALSOL
					TBR->BR_FAT09     	:= TMP->A2_XFATMIN // william Souza - Ethosx Consultoria e Soluções - 08/01/19

					/*---------------------------------------------------------------------------------------
					Autor: William Souza - Ethosx Consultoria e Soluções
					Data.: 02/01/19

					Detalhe:
					Incluindo valores no vetor aTRB que será utilizado para imprimir os itens de menor valor 
					do fornecedor
					-- INCLUIDO --
					----------------------------------------------------------------------------------------*/
					
					aadd(aTRB,{9,TBR->BR_CODIGO,TBR->BR_FOR09,TBR->BR_UNI09,TBR->BR_TOT09})										

				ElseIf nPOS == 10

					TBR->BR_FOR10		:= TMP->A2_COD + TMP->A2_LOJA
					TBR->BR_NOM10		:= TMP->A2_NREDUZ
					TBR->BR_UNI10		:= TMP->C8_PRECO
					TBR->BR_TOT10		:= TMP->C8_TOTAL
					TBR->BR_DES10		:= TMP->C8_VLDESC
					TBR->BR_CON10		:= TMP->C8_COND
					TBR->BR_ENT10		:= STOD(TMP->C8_DATPRF)
					TBR->BR_FRE10		:= TMP->C8_VALFRE
					TBR->BR_IPI10		:= TMP->C8_VALIPI
					TBR->BR_ICM10     	:= TMP->C8_VALSOL
					TBR->BR_FAT10     	:= TMP->A2_XFATMIN // william Souza - Ethosx Consultoria e Soluções - 08/01/19

					/*---------------------------------------------------------------------------------------
					Autor: William Souza - Ethosx Consultoria e Soluções
					Data.: 02/01/19

					Detalhe:
					Incluindo valores no vetor aTRB que será utilizado para imprimir os itens de menor valor 
					do fornecedor
					-- INCLUIDO --
					----------------------------------------------------------------------------------------*/
					
					aadd(aTRB,{10,TBR->BR_CODIGO,TBR->BR_FOR10,TBR->BR_UNI10,TBR->BR_TOT10})

				EndIf
				
				TBR->(MsUnlock())
				
			EndIf
			
			TMP->(DBSKIP())
		End
		
	End

	IF !lIMP
		ALERT("Não há dados para imprimir")
		return
	ENDIF

	IF MV_PAR07 == 1 //1 - Impressora
	
		//MONTA INTERFACE COM USUÁRIO
	
		oPrn := tAvPrinter():New( "Protheus" )
		oPrn:Setup()
	
  		// exibir posicionamento para alimanento dos objetos

		TBR->(DbGoTop())

		aValCot := {}

		While TBR->(!EOF())
			AADD(aValCot,{TBR->BR_TOT01,1,""})
			AADD(aValCot,{TBR->BR_TOT02,2,""})
			AADD(aValCot,{TBR->BR_TOT03,3,""})
			AADD(aValCot,{TBR->BR_TOT04,4,""})
			AADD(aValCot,{TBR->BR_TOT05,5,""})
			AADD(aValCot,{TBR->BR_TOT06,6,""})
			AADD(aValCot,{TBR->BR_TOT07,7,""})
			AADD(aValCot,{TBR->BR_TOT08,8,""})
			AADD(aValCot,{TBR->BR_TOT09,9,""})
			AADD(aValCot,{TBR->BR_TOT10,10,""})
			
			ASort(aValCot, , , {|x,y| x[1] < y[1]})

			nRank := 1

			For nlx := 1 to Len(aValCot)
				If aValCot[nlx][1] <> 0
					aValCot[nlx][3] := CValToChar(nRank)
					nRank++
				EndIf
			Next

			RecLock("TBR", .F.)
			TBR->BR_POS01 := aValCot[aScan(aValCot,{|x| x[2] == 1})][3]
			TBR->BR_POS02 := aValCot[aScan(aValCot,{|x| x[2] == 2})][3]
			TBR->BR_POS03 := aValCot[aScan(aValCot,{|x| x[2] == 3})][3]
			TBR->BR_POS04 := aValCot[aScan(aValCot,{|x| x[2] == 4})][3]
			TBR->BR_POS05 := aValCot[aScan(aValCot,{|x| x[2] == 5})][3]
			TBR->BR_POS06 := aValCot[aScan(aValCot,{|x| x[2] == 6})][3]
			TBR->BR_POS07 := aValCot[aScan(aValCot,{|x| x[2] == 7})][3]
			TBR->BR_POS08 := aValCot[aScan(aValCot,{|x| x[2] == 8})][3]
			TBR->BR_POS09 := aValCot[aScan(aValCot,{|x| x[2] == 9})][3]
			TBR->BR_POS10 := aValCot[aScan(aValCot,{|x| x[2] == 10})][3]
			TBR->(MsUnlock())

			aValCot := {}
			nPosF := aScan(aValTot,{|x| Alltrim(x[1]) == Alltrim(TBR->BR_NUM) })

			If nPosF == 0
				AADD(;
					aValTot,{Alltrim(TBR->BR_NUM),{;
							{TBR->BR_TOT01,"1"},;
							{TBR->BR_TOT02,"2"},;
							{TBR->BR_TOT03,"3"},;
							{TBR->BR_TOT04,"4"},;
							{TBR->BR_TOT05,"5"},;
							{TBR->BR_TOT06,"6"},;
							{TBR->BR_TOT07,"7"},;
							{TBR->BR_TOT08,"8"},;
							{TBR->BR_TOT09,"9"},;
							{TBR->BR_TOT10,"10"}};
					};
					)
			Else
				aValTot[nPosF][2][aScan(aValTot[1][2],{|x| x[2] == "1" })][1]  += TBR->BR_TOT01
				aValTot[nPosF][2][aScan(aValTot[1][2],{|x| x[2] == "2" })][1]  += TBR->BR_TOT02
				aValTot[nPosF][2][aScan(aValTot[1][2],{|x| x[2] == "3" })][1]  += TBR->BR_TOT03
				aValTot[nPosF][2][aScan(aValTot[1][2],{|x| x[2] == "4" })][1]  += TBR->BR_TOT04
				aValTot[nPosF][2][aScan(aValTot[1][2],{|x| x[2] == "5" })][1]  += TBR->BR_TOT05
				aValTot[nPosF][2][aScan(aValTot[1][2],{|x| x[2] == "6" })][1]  += TBR->BR_TOT06
				aValTot[nPosF][2][aScan(aValTot[1][2],{|x| x[2] == "7" })][1]  += TBR->BR_TOT07
				aValTot[nPosF][2][aScan(aValTot[1][2],{|x| x[2] == "8" })][1]  += TBR->BR_TOT08
				aValTot[nPosF][2][aScan(aValTot[1][2],{|x| x[2] == "9" })][1]  += TBR->BR_TOT09 
				aValTot[nPosF][2][aScan(aValTot[1][2],{|x| x[2] == "10" })][1] += TBR->BR_TOT10 
			EndIf

			TBR->(dbSkip())

		EndDo		
		
		aFimCot := {}

		For nly := 1 to Len(aValTot)
			
			ASort(aValTot[nly][2], , , {|x,y| x[1] < y[1]})
			
			cPos := ""
			
			For nlx := 1 to Len(aValTot[nly][2])
				If aValTot[nly][2][nlx][1] <> 0
					cPos := aValTot[nly][2][nlx][2]
					AADD(aFimCot,{aValTot[nly][1],cPos})
					Exit
				EndIf
			Next		
		Next
		
		TBR->(DbGoTop())

		WHILE TBR->(!EOF())
		
			cNUM := TBR->BR_NUM
			nLIN := 5000
	
			nTOT01 := nTOT02 := nTOT03 := nTOT04 := nTOT05 := nTOT06 := nTOT07 := nTOT08 := nTOT09 := nTOT10 := 0
			nDES01 := nDES02 := nDES03 := nDES04 := nDES05 := nDES06 := nDES07 := nDES08 := nDES09 := nDES10 := 0
			nFRE01 := nFRE02 := nFRE03 := nFRE04 := nFRE05 := nFRE06 := nFRE07 := nFRE08 := nFRE09 := nFRE10 := 0
			cCON01 := cCON02 := cCON03 := cCON04 := cCON05 := cCON06 := cCON07 := cCON08 := cCON09 := cCON10 := ""
			dENT01 := dENT02 := dENT03 := dENT04 := dENT05 := dENT06 := dENT07 := dENT08 := dENT09 := dENT10 := CTOD(SPACE(8))
			nIPI01 := nIPI02 := nIPI03 := nIPI04 := nIPI05 := nIPI06 := nIPI07 := nIPI08 := nIPI09 := nIPI10 := 0
			nICM01 := nICM02 := nICM03 := nICM04 := nICM05 := nICM06 := nICM07 := nICM08 := nICM09 := nICM10 := 0
			nFAT01 := nFAT02 := nFAT03 := nFAT04 := nFAT05 := nFAT06 := nFAT07 := nFAT08 := nFAT09 := nFAT10 := 0 // William Souza - Ethosx Consultoria e Soluções - 08/01/19
			nCALC01 := nCALC02 := nCALC03 := nCALC04 := nCALC05 := nCALC06 := nCALC07 := nCALC08 := nCALC09 := nCALC10 := 0 // William Souza - Ethosx Consultoria e Soluções - 08/01/19

			//Criar Variavel
			nRecno:= TBR->(RECNO())
		
			WHILE TBR->(!EOF()) .AND. cNUM == TBR->BR_NUM
					
				IF nLIN > 1440
				
					IF nLIN <> 5000
						oPrn:EndPage()
					ENDIF
				    
					If lCont
						cNumCot:= TBR->BR_NUM
					EndIf
					
					CABCOT(cNUM,aSC)
					nPag++  // Maurício Aureliano - 12/04/2018 - Chamado: I1710-2277
				
				ENDIF
			
				oPrn:Say( nLIN, 0065,TBR->BR_CODIGO	,oFont08b,100 )//Codigo
				oPrn:Say( nLIN, 0320,TBR->BR_DESC,oFont08b,100 )//Descricao
				oPrn:Say( nLIN, 0815,TRANSFORM(TBR->BR_QTDE,"@E 9,999.99")	,oFont08n,100 )//Quantidade
				oPrn:Say( nLIN, 0965,TBR->BR_UM	,oFont08b,100 )//Unidade

				oPrn:Say( nLIN, 1020,SubStr(DTOS(TBR->BR_ULC01),5,2) + "/" + SubStr(DTOS(TBR->BR_ULC01),3,2),oFont08n,100  )
				oPrn:Say( nLIN, 1120,TRANSFORM(TBR->BR_UNP01,"@E 999,999.99"),oFont08n,100 )
				

				//SOLICITAÇÃO DO CARLOS PARA GERAR COM COR NA 1, 2, 3 cotacao - 19/10/2020
				//oBrush := Tbrush():New(,CLR_LIGHTGRAY)	//cinza claro
				
				///oBrushX:= Tbrush():New(,CLR_WHITE )		// 1 - branco
				oBrush := Tbrush():New(,CLR_HGREEN )	// 1 - VERDE
				oBrush2:= Tbrush():New(,CLR_YELLOW)		// 2 - AMARELO 
				oBrush3:= Tbrush():New(,CLR_HRED)		// 3 - VERMELHO 
				NPOSCOT:= 0
				//nCALC01 := nCALC02 := nCALC03 := nCALC04 := nCALC05 := 0

				If (len(aTRB) > 5)

				
					If !Empty(TBR->BR_TOT01)//01

						If Alltrim(TBR->BR_POS01) == "1"
							oPrn:FillRect({nLIN-17, 1305, nLIN+39 , 1696},oBrush)//01
						Elseif Alltrim(TBR->BR_POS01) == "2"
							oPrn:FillRect({nLIN-17, 1305, nLIN+39 , 1696},oBrush2)//01
						Elseif Alltrim(TBR->BR_POS01) == "3"
							oPrn:FillRect({nLIN-17, 1305, nLIN+39 , 1696},oBrush3)//01
						EndIf

						if nPosCot=1
							nCALC01 += TBR->BR_TOT01
						endif

					EndIf

					If !Empty(TBR->BR_TOT02) ///02
						
						If Alltrim(TBR->BR_POS02) == "1"
							oPrn:FillRect({nLIN-17, 1698, nLIN+39 , 2077},oBrush)
						ElseIf Alltrim(TBR->BR_POS02) == "2"
							oPrn:FillRect({nLIN-17, 1698, nLIN+39 , 2077},oBrush2)
						ElseIf Alltrim(TBR->BR_POS02) == "3"
							oPrn:FillRect({nLIN-17, 1698, nLIN+39 , 2077},oBrush3)
						EndIf

						if nPosCot=1
							nCALC02 += TBR->BR_TOT02
						endif

					EndIf
					
					If !Empty(TBR->BR_TOT03) //03 
						
						If Alltrim(TBR->BR_POS03) == "1"
							oPrn:FillRect({nLIN-17, 2079, nLIN+39 , 2440},oBrush)
						ElseIf Alltrim(TBR->BR_POS03) == "2"
							oPrn:FillRect({nLIN-17, 2079, nLIN+39 , 2440},oBrush2)
						ElseIf Alltrim(TBR->BR_POS03) == "3"
							oPrn:FillRect({nLIN-17, 2079, nLIN+39 , 2440},oBrush3)
						EndIf

						if nPosCot=1
							nCALC03 += TBR->BR_TOT03
						endif

					EndIf

					If !Empty(TBR->BR_TOT04)//04
						
						If Alltrim(TBR->BR_POS04) == "1"
							oPrn:FillRect({nLIN-17, 2442, nLIN+39 , 2813},oBrush)
						ElseIf Alltrim(TBR->BR_POS04) == "2"
							oPrn:FillRect({nLIN-17, 2442, nLIN+39 , 2813},oBrush2)
						ElseIf Alltrim(TBR->BR_POS04) == "3"
							oPrn:FillRect({nLIN-17, 2442, nLIN+39 , 2813},oBrush3)
						EndIf

						if nPosCot=1
							nCALC04 += TBR->BR_TOT04
						endif
					
					EndIf


					If !Empty(TBR->BR_TOT05)//05
						
						If Alltrim(TBR->BR_POS05) == "1"
							oPrn:FillRect({nLIN-17, 2815, nLIN+39 , 3178},oBrush)
						ElseIf Alltrim(TBR->BR_POS05) == "2"
							oPrn:FillRect({nLIN-17, 2815, nLIN+39 , 3178},oBrush2)
						ElseIf Alltrim(TBR->BR_POS05) == "3"
							oPrn:FillRect({nLIN-17, 2815, nLIN+39 , 3178},oBrush3)
						EndIf

						if nPosCot=1
							nCALC05 += TBR->BR_TOT05
						endif

					EndIf

				Endif 

				If TBR->BR_TOT01 <> 0 .and. TBR->BR_UNI01 <> 0
					If Alltrim(TBR->BR_POS01) == "1"
						oPrn:FillRect({nLIN-17, 1305, nLIN+39 , 1696},oBrush)//01
					Elseif Alltrim(TBR->BR_POS01) == "2"
						oPrn:FillRect({nLIN-17, 1305, nLIN+39 , 1696},oBrush2)//01
					Elseif Alltrim(TBR->BR_POS01) == "3"
						oPrn:FillRect({nLIN-17, 1305, nLIN+39 , 1696},oBrush3)//01
					EndIf

					oPrn:Say( nLIN, 1310,TRANSFORM(TBR->BR_UNI01,"@E 999,999.99"),oFont08n,100 )
					oPrn:Say( nLIN, 1490,TRANSFORM(TBR->BR_TOT01,"@E 9,999,999.99"),oFont08n,100 )
		        EndIf

				If TBR->BR_TOT02 <> 0 .and. TBR->BR_UNI02 <> 0	
					If Alltrim(TBR->BR_POS02) == "1"
						oPrn:FillRect({nLIN-17, 1698, nLIN+39 , 2077},oBrush)
					ElseIf Alltrim(TBR->BR_POS02) == "2"
						oPrn:FillRect({nLIN-17, 1698, nLIN+39 , 2077},oBrush2)
					ElseIf Alltrim(TBR->BR_POS02) == "3"
						oPrn:FillRect({nLIN-17, 1698, nLIN+39 , 2077},oBrush3)
					EndIf

					oPrn:Say( nLIN, 1700,TRANSFORM(TBR->BR_UNI02,"@E 999,999.99"),oFont08n,100 )
					oPrn:Say( nLIN, 1871,TRANSFORM(TBR->BR_TOT02,"@E 9,999,999.99"),oFont08n,100 )
				EndIf
				
				If TBR->BR_TOT03 <> 0 .and. TBR->BR_UNI03 <> 0
					If Alltrim(TBR->BR_POS03) == "1"
						oPrn:FillRect({nLIN-17, 2079, nLIN+39 , 2440},oBrush)
					ElseIf Alltrim(TBR->BR_POS03) == "2"
						oPrn:FillRect({nLIN-17, 2079, nLIN+39 , 2440},oBrush2)
					ElseIf Alltrim(TBR->BR_POS03) == "3"
						oPrn:FillRect({nLIN-17, 2079, nLIN+39 , 2440},oBrush3)
					EndIf

					oPrn:Say( nLIN, 2086,TRANSFORM(TBR->BR_UNI03,"@E 999,999.99"),oFont08n,100 )
					oPrn:Say( nLIN, 2251,TRANSFORM(TBR->BR_TOT03,"@E 9999,999.99"),oFont08n,100 )
				EndIf	
				
				If TBR->BR_TOT04 <> 0 .and. TBR->BR_UNI04 <> 0
					If Alltrim(TBR->BR_POS04) == "1"
						oPrn:FillRect({nLIN-17, 2442, nLIN+39 , 2813},oBrush)
					ElseIf Alltrim(TBR->BR_POS04) == "2"
						oPrn:FillRect({nLIN-17, 2442, nLIN+39 , 2813},oBrush2)
					ElseIf Alltrim(TBR->BR_POS04) == "3"
						oPrn:FillRect({nLIN-17, 2442, nLIN+39 , 2813},oBrush3)
					EndIf

					oPrn:Say( nLIN, 2446,TRANSFORM(TBR->BR_UNI04,"@E 999,999.99"),oFont08n,100 )
					oPrn:Say( nLIN, 2626,TRANSFORM(TBR->BR_TOT04,"@E 9999,999.99"),oFont08n,100 )
				EndIf
				
				If TBR->BR_TOT05 <> 0 .and. TBR->BR_UNI05 <> 0
					If Alltrim(TBR->BR_POS05) == "1"
						oPrn:FillRect({nLIN-17, 2815, nLIN+39 , 3178},oBrush)
					ElseIf Alltrim(TBR->BR_POS05) == "2"
						oPrn:FillRect({nLIN-17, 2815, nLIN+39 , 3178},oBrush2)
					ElseIf Alltrim(TBR->BR_POS05) == "3"
						oPrn:FillRect({nLIN-17, 2815, nLIN+39 , 3178},oBrush3)
					EndIf

					oPrn:Say( nLIN, 2836,TRANSFORM(TBR->BR_UNI05,"@E 999999.99"),oFont08n,100 )
					oPrn:Say( nLIN, 3006,TRANSFORM(TBR->BR_TOT05,"@E 9999999.99"),oFont08n,100 )
				EndIf

				nTOT01 += TBR->BR_TOT01
				nTOT02 += TBR->BR_TOT02
				nTOT03 += TBR->BR_TOT03
				nTOT04 += TBR->BR_TOT04
				nTOT05 += TBR->BR_TOT05

				nDES01 += TBR->BR_DES01
				nDES02 += TBR->BR_DES02
				nDES03 += TBR->BR_DES03
				nDES04 += TBR->BR_DES04
				nDES05 += TBR->BR_DES05

				nFRE01 += TBR->BR_FRE01
				nFRE02 += TBR->BR_FRE02
				nFRE03 += TBR->BR_FRE03
				nFRE04 += TBR->BR_FRE04
				nFRE05 += TBR->BR_FRE05

				nIPI01 += TBR->BR_IPI01
				nIPI02 += TBR->BR_IPI02
				nIPI03 += TBR->BR_IPI03
				nIPI04 += TBR->BR_IPI04
				nIPI05 += TBR->BR_IPI05

				nICM01 += TBR->BR_ICM01
				nICM02 += TBR->BR_ICM02
				nICM03 += TBR->BR_ICM03
				nICM04 += TBR->BR_ICM04
				nICM05 += TBR->BR_ICM05

				cCON01 := IIF(Empty(cCON01),TBR->BR_CON01,cCON01)
				cCON02 := IIF(Empty(cCON02),TBR->BR_CON02,cCON02)
				cCON03 := IIF(Empty(cCON03),TBR->BR_CON03,cCON03)
				cCON04 := IIF(Empty(cCON04),TBR->BR_CON04,cCON04)
				cCON05 := IIF(Empty(cCON05),TBR->BR_CON05,cCON05)

				dENT01 := IIF(Empty(dENT01),TBR->BR_ENT01,dENT01)
				dENT02 := IIF(Empty(dENT02),TBR->BR_ENT02,dENT02)
				dENT03 := IIF(Empty(dENT03),TBR->BR_ENT03,dENT03)
				dENT04 := IIF(Empty(dENT04),TBR->BR_ENT04,dENT04)
				dENT05 := IIF(Empty(dENT05),TBR->BR_ENT05,dENT05)

				nFAT01 := IIF(nFAT01 = 0,TBR->BR_FAT01,nFAT01)
				nFAT02 := IIF(nFAT02 = 0,TBR->BR_FAT02,nFAT02)
				nFAT03 := IIF(nFAT03 = 0,TBR->BR_FAT03,nFAT03)
				nFAT04 := IIF(nFAT04 = 0,TBR->BR_FAT04,nFAT04)
				nFAT05 := IIF(nFAT05 = 0,TBR->BR_FAT05,nFAT05)
				
				DBSELECTAREA("TBR")
				TBR->(DbSkip())
			
				nLIN	:= nLIN+60

			End

			oBrushC := Tbrush():New(,CLR_LIGHTGRAY)
			oPrn:FillRect({1741,0058,1800,3178},oBrushC)

			//oBrush := Tbrush():New(,CLR_HGREEN) //CLR_GRAY)

		
			//////// QUADRO DOS TOTAIS
		
			oPrn:Box (1440, 0056,1980, 3180)	//quadro
			oPrn:Box (1442, 0058,1978, 3178)	//quadro
		
			nLIN := 1500
			
			FOR X:=1 TO 9
				oPrn:Line(nLIN, 0056,nLIN, 3180)
				nLIN := nLIN + 60
			NEXT
			
			oPrn:Box (0350, 1695,1980, 1697)  //Linha vertical dupla - rodape - fim do total 01
			oPrn:Box (0350, 2078,1980, 2080)  //Linha vertical dupla - rodape - fim do total 02
			oPrn:Box (0350, 2441,1980, 2443)  //Linha vertical dupla - rodape - fim do total 03
			oPrn:Box (0350, 2814,1980, 2816)  //Linha vertical dupla - rodape - fim do total 04
			
			nLIN := 1460

			oPrn:Say( nLIN, 0260, "Frete",oFont08b,100 )
			oPrn:Say( nLIN, 1325, "R$ " + TRANSFORM(nFRE01,"@E 999,999,999.99"),oFont09n,100 )
			oPrn:Say( nLIN, 1710, "R$ " + TRANSFORM(nFRE02,"@E 999,999,999.99"),oFont09n,100 )			
			oPrn:Say( nLIN, 2093, "R$ " + TRANSFORM(nFRE03,"@E 999,999,999.99"),oFont09n,100 )
			oPrn:Say( nLIN, 2456, "R$ " + TRANSFORM(nFRE04,"@E 999,999,999.99"),oFont09n,100 )
			oPrn:Say( nLIN, 2829, "R$ " + TRANSFORM(nFRE05,"@E 999,999,999.99"),oFont09n,100 )

			nLIN	:= nLIN + 60
		
			oPrn:Say( nLIN, 0260, "Desconto",oFont08b,100 )
			oPrn:Say( nLIN, 1325, "R$ " + TRANSFORM(nDES01,"@E 999,999,999.99"),oFont09n,100 )
			oPrn:Say( nLIN, 1710, "R$ " + TRANSFORM(nDES02,"@E 999,999,999.99"),oFont09n,100 )
			oPrn:Say( nLIN, 2093, "R$ " + TRANSFORM(nDES03,"@E 999,999,999.99"),oFont09n,100 )
			oPrn:Say( nLIN, 2456, "R$ " + TRANSFORM(nDES04,"@E 999,999,999.99"),oFont09n,100 )
			oPrn:Say( nLIN, 2829, "R$ " + TRANSFORM(nDES05,"@E 999,999,999.99"),oFont09n,100 )

			nLIN	:= nLIN + 60
		
			oPrn:Say( nLIN, 0260, "Valor Líquido",oFont08b,100 )
			oPrn:Say( nLIN, 1325, "R$ " + TRANSFORM(nTOT01-nDES01,"@E 999,999,999.99"),oFont09n,100 )//1050
			oPrn:Say( nLIN, 1710, "R$ " + TRANSFORM(nTOT02-nDES02,"@E 999,999,999.99"),oFont09n,100 )
			oPrn:Say( nLIN, 2093, "R$ " + TRANSFORM(nTOT03-nDES03,"@E 999,999,999.99"),oFont09n,100 )
			oPrn:Say( nLIN, 2456, "R$ " + TRANSFORM(nTOT04-nDES04,"@E 999,999,999.99"),oFont09n,100 )
			oPrn:Say( nLIN, 2829, "R$ " + TRANSFORM(nTOT05-nDES05,"@E 999,999,999.99"),oFont09n,100 )

			nLIN	:= nLIN + 60

			oPrn:Say( nLIN, 0260, "Faturamento Mínimo",oFont08b,100 )
			oPrn:Say( nLIN, 1325, "R$ " + TRANSFORM(nFAT01,"@E 999,999,999.99"),oFont09n,100 )//1050
			oPrn:Say( nLIN, 1710, "R$ " + TRANSFORM(nFAT02,"@E 999,999,999.99"),oFont09n,100 )
			oPrn:Say( nLIN, 2093, "R$ " + TRANSFORM(nFAT03,"@E 999,999,999.99"),oFont09n,100 )
			oPrn:Say( nLIN, 2456, "R$ " + TRANSFORM(nFAT04,"@E 999,999,999.99"),oFont09n,100 )
			oPrn:Say( nLIN, 2829, "R$ " + TRANSFORM(nFAT05,"@E 999,999,999.99"),oFont09n,100 )
			
			nLIN	:= nLIN+60

			//nCALC01 := calcMin(1)
			//nCALC02 := calcMin(2)
			//nCALC03 := calcMin(3)
			//nCALC04 := calcMin(4)
			//nCALC05 := calcMin(5)
			
			oPrn:Say( nLIN, 0260, "Menor Valor p/fornecedor",oFont08b,100 )
			oPrn:Say( nLIN, 1325, "R$ " + TRANSFORM(nCALC01,"@E 999,999,999.99"),oFont09n,100 )//1050
			oPrn:Say( nLIN, 1710, "R$ " + TRANSFORM(nCALC02,"@E 999,999,999.99"),oFont09n,100 )
			oPrn:Say( nLIN, 2093, "R$ " + TRANSFORM(nCALC03,"@E 999,999,999.99"),oFont09n,100 )
			oPrn:Say( nLIN, 2456, "R$ " + TRANSFORM(nCALC04,"@E 999,999,999.99"),oFont09n,100 )
			oPrn:Say( nLIN, 2829, "R$ " + TRANSFORM(nCALC05,"@E 999,999,999.99"),oFont09n,100 )			

			nLIN	:= nLIN+60

			nPFim := aScan(aFimCot,{|x| x[1] == cNUM })

			If nPFim <> 0
				Do Case
					Case aFimCot[nPFim][2] == "1"
						oPrn:FillRect({nLIN-17,1301,nLIN+39,1692},oBrush)//01
					Case aFimCot[nPFim][2] == "2"
						oPrn:FillRect({nLIN-17,1696,nLIN+39,2075},oBrush)//02
					Case aFimCot[nPFim][2] == "3"
						oPrn:FillRect({nLIN-17,2077,nLIN+39,2438},oBrush)//03
					Case aFimCot[nPFim][2] == "4"
						oPrn:FillRect({nLIN-17,2440,nLIN+39,2811},oBrush)//04
					Case aFimCot[nPFim][2] == "5"
						oPrn:FillRect({nLIN-17,2813,nLIN+39,3177},oBrush)//05
				EndCase	
			Endif

			oPrn:Say( nLIN, 0260, "Valor Total",oFont08b,100 )
			oPrn:Say( nLIN, 1325, "R$ " + TRANSFORM(nTOT01 - nDES01 + nFRE01 + nIPI01 + nICM01,"@E 999,999,999.99"),oFont09n,100 )
			oPrn:Say( nLIN, 1710, "R$ " + TRANSFORM(nTOT02 - nDES02 + nFRE02 + nIPI02 + nICM02,"@E 999,999,999.99"),oFont09n,100 )
			oPrn:Say( nLIN, 2093, "R$ " + TRANSFORM(nTOT03 - nDES03 + nFRE03 + nIPI03 + nICM03,"@E 999,999,999.99"),oFont09n,100 )
			oPrn:Say( nLIN, 2456, "R$ " + TRANSFORM(nTOT04 - nDES04 + nFRE04 + nIPI04 + nICM04,"@E 999,999,999.99"),oFont09n,100 )
			oPrn:Say( nLIN, 2829, "R$ " + TRANSFORM(nTOT05 - nDES05 + nFRE05 + nIPI05 + nICM05,"@E 999,999,999.99"),oFont09n,100 )

			nLIN	:= nLIN+60
		
			oPrn:Say( nLIN, 0260, "Prazo de Entrega",oFont08b,100 )
			oPrn:Say( nLIN, 1325,DTOC(dENT01),oFont08b,100 )//1050
			oPrn:Say( nLIN, 1710,DTOC(dENT02),oFont08b,100 )
			oPrn:Say( nLIN, 2093,DTOC(dENT03),oFont08b,100 )
			oPrn:Say( nLIN, 2456,DTOC(dENT04),oFont08b,100 )
			oPrn:Say( nLIN, 2829,DTOC(dENT05),oFont08b,100 )

			nLIN	:= nLIN+60
		
			oPrn:Say( nLIN, 0260, "Condição de Pagamento",oFont08b,100 )
			oPrn:Say( nLIN, 1325,cCON01 + " - " + POSICIONE("SE4",1,XFILIAL("SE4") + cCON01,"E4_DESCRI"),oFont08b,100 )//1050
			oPrn:Say( nLIN, 1710,cCON02 + " - " + POSICIONE("SE4",1,XFILIAL("SE4")+cCON02,"E4_DESCRI"),oFont08b,100 )
			oPrn:Say( nLIN, 2093,cCON03 + " - " + POSICIONE("SE4",1,XFILIAL("SE4")+cCON03,"E4_DESCRI"),oFont08b,100 )
			oPrn:Say( nLIN, 2456,cCON04 + " - " + POSICIONE("SE4",1,XFILIAL("SE4")+cCON04,"E4_DESCRI"),oFont08b,100 )
			oPrn:Say( nLIN, 2829,cCON05 + " - " + POSICIONE("SE4",1,XFILIAL("SE4")+cCON05,"E4_DESCRI"),oFont08b,100 )

			nLIN	:= nLIN + 60
			
			oPrn:Say( nLIN, 0260, "Garantia",oFont08b,100 )

			nLIN	:= nLIN + 60
			
			oPrn:Box (1980,0056,2280,3180)	//quadro
			oPrn:Box (1982,0058,2278,3178)	//quadro

		    oBrushC := Tbrush():New(,CLR_LIGHTGRAY)
			
			nCol := 90
			
			oPrn:FillRect({2140, 100  + nCol , 2200 , 0730+nCol},oBrushC)
			oPrn:FillRect({2140, 780  + nCol , 2200 , 1460+nCol},oBrushC)
			oPrn:FillRect({2140, 1510 + nCol , 2200 , 2180+nCol},oBrushC)
			oPrn:FillRect({2140, 2230 + nCol , 2200 , 2900+nCol},oBrushC)

			oPrn:Line(2115, 100  + nCol , 2115 , 0730+nCol)
			oPrn:Line(2115, 780  + nCol , 2115 , 1460+nCol)
			oPrn:Line(2115, 1510 + nCol , 2115 , 2180+nCol)
			oPrn:Line(2115, 2230 + nCol , 2115 , 2900+nCol)
			
			oPrn:Say( 2160, 110+nCol , "COMPRADOR:  ______/______/________  "        ,oFont08b,100 )
			oPrn:Say( 2160, 790+nCol , "GESTOR SUPRIMENTOS:  ______/______/________" ,oFont08b,100 )
			oPrn:Say( 2160, 1520+nCol, "GESTOR SOLICITANTE:  ______/______/________" ,oFont08b,100 )
			oPrn:Say( 2160, 2240+nCol, "DIRETOR SOLICITANTE:  ______/______/________",oFont08b,100 )
            
			oPrn:Box (1440, 1300,1980, 1302)//Linha vertical dupla - rodape - Inicio - Ult.Pre


			oPrn:EndPage()
			
			If lCont
			
				TBR->(DbGoTo(nRecno))
				
				//CABCONT(cNUM,aSC)
				//nPag++
				
				WHILE TBR->(!EOF()) .AND. cNUM == TBR->BR_NUM
				
					IF nLIN > 1440
				
						IF nLIN <> 5000
							oPrn:EndPage()
						ENDIF
				    
						If lCont
							cNumCot:= TBR->BR_NUM
						EndIf
					
						CABCONT(cNUM,aSC)
						nPag++  // Maurício Aureliano - 12/04/2018 - Chamado: I1710-2277
				
					ENDIF

					oPrn:Say( nLIN, 0065,TBR->BR_CODIGO	,oFont08b,100 )//Codigo
					oPrn:Say( nLIN, 0320,TBR->BR_DESC,oFont08b,100 )//Descricao
					oPrn:Say( nLIN, 0815,TRANSFORM(TBR->BR_QTDE,"@E 9,999.99")	,oFont08n,100 )//Quantidade
					oPrn:Say( nLIN, 0965,TBR->BR_UM	,oFont08b,100 )//Unidade
	
					oPrn:Say( nLIN, 1020,SubStr(DTOS(TBR->BR_ULC01),5,2) + "/" + SubStr(DTOS(TBR->BR_ULC01),3,2),oFont08n,100  )
					oPrn:Say( nLIN, 1120,TRANSFORM(TBR->BR_UNP01,"@E 999,999.99"),oFont08n,100 )
					
					//oBrush := Tbrush():New(,CLR_LIGHTGRAY)

					If (len(aTRB) > 5)

						If !Empty(TBR->BR_TOT06)
							If Alltrim(TBR->BR_POS06) == "1"
								oPrn:FillRect({nLIN-17, 1303, nLIN+39 , 1694},oBrush)
							ElseIf Alltrim(TBR->BR_POS06) == "2"
								oPrn:FillRect({nLIN-17, 1303, nLIN+39 , 1694},oBrush2)
							ElseIf Alltrim(TBR->BR_POS06) == "3"
								oPrn:FillRect({nLIN-17, 1303, nLIN+39 , 1694},oBrush3)
							EndIf
						EndIf

						If !Empty(TBR->BR_TOT07)
							If Alltrim(TBR->BR_POS07) == "1"
								oPrn:FillRect({nLIN-17, 1698, nLIN+39 , 2077},oBrush)
							ElseIf Alltrim(TBR->BR_POS07) == "2"
								oPrn:FillRect({nLIN-17, 1698, nLIN+39 , 2077},oBrush2)
							ElseIf Alltrim(TBR->BR_POS07) == "3"
								oPrn:FillRect({nLIN-17, 1698, nLIN+39 , 2077},oBrush3)
							EndIf
						EndIf
					
						If !Empty(TBR->BR_TOT08)
							If Alltrim(TBR->BR_POS08) == "1"
								oPrn:FillRect({nLIN-17, 2079, nLIN+39 , 2440},oBrush)
							ElseIf Alltrim(TBR->BR_POS08) == "2"
								oPrn:FillRect({nLIN-17, 2079, nLIN+39 , 2440},oBrush2)
							ElseIf Alltrim(TBR->BR_POS08) == "3"
								oPrn:FillRect({nLIN-17, 2079, nLIN+39 , 2440},oBrush3)
							EndIf
						EndIf

						If !Empty(TBR->BR_TOT09)
							If Alltrim(TBR->BR_POS09) == "1"
								oPrn:FillRect({nLIN-17, 2442, nLIN+39 , 2813},oBrush)
							ElseIf Alltrim(TBR->BR_POS09) == "2"
								oPrn:FillRect({nLIN-17, 2442, nLIN+39 , 2813},oBrush2)
							ElseIf Alltrim(TBR->BR_POS09) == "3"
								oPrn:FillRect({nLIN-17, 2442, nLIN+39 , 2813},oBrush3)
							EndIf
						EndIf

						If !Empty(TBR->BR_TOT10)
							If Alltrim(TBR->BR_POS10) == "1"
								oPrn:FillRect({nLIN-17, 2815, nLIN+39 , 3179},oBrush)
							ElseIf Alltrim(TBR->BR_POS10) == "2"
								oPrn:FillRect({nLIN-17, 2815, nLIN+39 , 3179},oBrush2)
							ElseIf Alltrim(TBR->BR_POS10) == "3"
								oPrn:FillRect({nLIN-17, 2815, nLIN+39 , 3179},oBrush3)
							EndIf
						EndIf
					
  					Endif 

					If TBR->BR_TOT06 <> 0 .and. TBR->BR_UNI06 <> 0
						If Alltrim(TBR->BR_POS06) == "1"
							oPrn:FillRect({nLIN-17, 1303, nLIN+39 , 1694},oBrush)
						ElseIf Alltrim(TBR->BR_POS06) == "2"
							oPrn:FillRect({nLIN-17, 1303, nLIN+39 , 1694},oBrush2)
						ElseIf Alltrim(TBR->BR_POS06) == "3"
							oPrn:FillRect({nLIN-17, 1303, nLIN+39 , 1694},oBrush3)
						EndIf

						oPrn:Say( nLIN, 1310,TRANSFORM(TBR->BR_UNI06,"@E 999,999.99"),oFont08n,100 )
						oPrn:Say( nLIN, 1490,TRANSFORM(TBR->BR_TOT06,"@E 9,999,999.99"),oFont08n,100 )
			        EndIf
	
					If TBR->BR_TOT07 <> 0 .and. TBR->BR_UNI07 <> 0	
						If Alltrim(TBR->BR_POS07) == "1"
							oPrn:FillRect({nLIN-17, 1698, nLIN+39 , 2077},oBrush)
						ElseIf Alltrim(TBR->BR_POS07) == "2"
							oPrn:FillRect({nLIN-17, 1698, nLIN+39 , 2077},oBrush2)
						ElseIf Alltrim(TBR->BR_POS07) == "3"
							oPrn:FillRect({nLIN-17, 1698, nLIN+39 , 2077},oBrush3)
						EndIf

						oPrn:Say( nLIN, 1700,TRANSFORM(TBR->BR_UNI07,"@E 999,999.99"),oFont08n,100 )
						oPrn:Say( nLIN, 1871,TRANSFORM(TBR->BR_TOT07,"@E 9,999,999.99"),oFont08n,100 )
					EndIf
					
					If TBR->BR_TOT08 <> 0 .and. TBR->BR_UNI08 <> 0
						If Alltrim(TBR->BR_POS08) == "1"
							oPrn:FillRect({nLIN-17, 2079, nLIN+39 , 2440},oBrush)
						ElseIf Alltrim(TBR->BR_POS08) == "2"
							oPrn:FillRect({nLIN-17, 2079, nLIN+39 , 2440},oBrush2)
						ElseIf Alltrim(TBR->BR_POS08) == "3"
							oPrn:FillRect({nLIN-17, 2079, nLIN+39 , 2440},oBrush3)
						EndIf

						oPrn:Say( nLIN, 2086,TRANSFORM(TBR->BR_UNI08,"@E 999,999.99"),oFont08n,100 )
						oPrn:Say( nLIN, 2251,TRANSFORM(TBR->BR_TOT08,"@E 9999,999.99"),oFont08n,100 )
					EndIf	
					
					If TBR->BR_TOT09 <> 0 .and. TBR->BR_UNI09 <> 0
						If Alltrim(TBR->BR_POS09) == "1"
							oPrn:FillRect({nLIN-17, 2442, nLIN+39 , 2813},oBrush)
						ElseIf Alltrim(TBR->BR_POS09) == "2"
							oPrn:FillRect({nLIN-17, 2442, nLIN+39 , 2813},oBrush2)
						ElseIf Alltrim(TBR->BR_POS09) == "3"
							oPrn:FillRect({nLIN-17, 2442, nLIN+39 , 2813},oBrush3)
						EndIf

						oPrn:Say( nLIN, 2446,TRANSFORM(TBR->BR_UNI09,"@E 999,999.99"),oFont08n,100 )
						oPrn:Say( nLIN, 2626,TRANSFORM(TBR->BR_TOT09,"@E 9999,999.99"),oFont08n,100 )
					EndIf
					
					If TBR->BR_TOT10 <> 0 .and. TBR->BR_UNI10 <> 0
						If Alltrim(TBR->BR_POS10) == "1"
							oPrn:FillRect({nLIN-17, 2815, nLIN+39 , 3179},oBrush)
						ElseIf Alltrim(TBR->BR_POS10) == "2"
							oPrn:FillRect({nLIN-17, 2815, nLIN+39 , 3179},oBrush2)
						ElseIf Alltrim(TBR->BR_POS10) == "3"
							oPrn:FillRect({nLIN-17, 2815, nLIN+39 , 3179},oBrush3)
						EndIf
						
						oPrn:Say( nLIN, 2836,TRANSFORM(TBR->BR_UNI10,"@E 999999.99"),oFont08n,100 )
						oPrn:Say( nLIN, 3006,TRANSFORM(TBR->BR_TOT10,"@E 9999999.99"),oFont08n,100 )
					EndIf
	
					nTOT06 += TBR->BR_TOT06
					nTOT07 += TBR->BR_TOT07
					nTOT08 += TBR->BR_TOT08
					nTOT09 += TBR->BR_TOT09
					nTOT10 += TBR->BR_TOT10
				                       
					nDES06 += TBR->BR_DES06
					nDES07 += TBR->BR_DES07
					nDES08 += TBR->BR_DES08
					nDES09 += TBR->BR_DES09
					nDES10 += TBR->BR_DES10
				
					nFRE06 += TBR->BR_FRE06
					nFRE07 += TBR->BR_FRE07
					nFRE08 += TBR->BR_FRE08
					nFRE09 += TBR->BR_FRE09
					nFRE10 += TBR->BR_FRE10

					nIPI06 += TBR->BR_IPI06
					nIPI07 += TBR->BR_IPI07
					nIPI08 += TBR->BR_IPI08
					nIPI09 += TBR->BR_IPI09
					nIPI10 += TBR->BR_IPI10
						
					nICM06 += TBR->BR_ICM06
					nICM07 += TBR->BR_ICM07
					nICM08 += TBR->BR_ICM08
					nICM09 += TBR->BR_ICM09
					nICM10 += TBR->BR_ICM10
				
					cCON06 := IIF(Empty(cCON06),TBR->BR_CON06,cCON06)
					cCON07 := IIF(Empty(cCON07),TBR->BR_CON07,cCON07)
					cCON08 := IIF(Empty(cCON08),TBR->BR_CON08,cCON08)
					cCON09 := IIF(Empty(cCON09),TBR->BR_CON09,cCON09)
					cCON10 := IIF(Empty(cCON10),TBR->BR_CON10,cCON10)
				
					dENT06 := IIF(Empty(dENT06),TBR->BR_ENT06,dENT06)
					dENT07 := IIF(Empty(dENT07),TBR->BR_ENT07,dENT07)
					dENT08 := IIF(Empty(dENT08),TBR->BR_ENT08,dENT08)
					dENT09 := IIF(Empty(dENT09),TBR->BR_ENT09,dENT09)
					dENT10 := IIF(Empty(dENT10),TBR->BR_ENT10,dENT10)

					nFAT06 := IIF(nFAT06 = 0,TBR->BR_FAT06,nFAT06)
					nFAT07 := IIF(nFAT07 = 0,TBR->BR_FAT07,nFAT07)
					nFAT08 := IIF(nFAT08 = 0,TBR->BR_FAT08,nFAT08)
					nFAT09 := IIF(nFAT09 = 0,TBR->BR_FAT09,nFAT09)
					nFAT10 := IIF(nFAT10 = 0,TBR->BR_FAT10,nFAT10)
	
					DBSELECTAREA("TBR")
					TBR->(DbSkip())
			
					nLIN	:= nLIN+60

				End
		
				oBrush := Tbrush():New(,CLR_LIGHTGRAY)
				oPrn:FillRect({1741,0058,1800,3178},oBrush)

				//oBrush := Tbrush():New(,CLR_GRAY//)

				//////// QUADRO DOS TOTAIS - AQUI
		
				oPrn:Box (1440, 0056,1980, 3180)	//quadro
				oPrn:Box (1442, 0058,1978, 3178)	//quadro
		
				nLIN := 1500
			
				FOR X:=1 TO 9
					oPrn:Line(nLIN, 0056,nLIN, 3180)
					nLIN := nLIN + 60
				NEXT
								
				oPrn:Box (0350, 1695,1980, 1697)  //Linha vertical dupla - rodape - fim do total 01
				oPrn:Box (0350, 2078,1980, 2080)  //Linha vertical dupla - rodape - fim do total 02
				oPrn:Box (0350, 2441,1980, 2443)  //Linha vertical dupla - rodape - fim do total 03
				oPrn:Box (0350, 2814,1980, 2816)  //Linha vertical dupla - rodape - fim do total 04

				nLIN := 1460
		
				oPrn:Say( nLIN, 0260, "Frete",oFont08b,100 )
				oPrn:Say( nLIN, 1325, "R$ " + TRANSFORM(nFRE01,"@E 999,999,999.99"),oFont09n,100 )
				oPrn:Say( nLIN, 1710, "R$ " + TRANSFORM(nFRE02,"@E 999,999,999.99"),oFont09n,100 )			
				oPrn:Say( nLIN, 2093, "R$ " + TRANSFORM(nFRE03,"@E 999,999,999.99"),oFont09n,100 )
				oPrn:Say( nLIN, 2456, "R$ " + TRANSFORM(nFRE04,"@E 999,999,999.99"),oFont09n,100 )
				oPrn:Say( nLIN, 2829, "R$ " + TRANSFORM(nFRE05,"@E 999,999,999.99"),oFont09n,100 )
			
				nLIN	:= nLIN + 60
		
				oPrn:Say( nLIN, 0260, "Desconto",oFont08b,100 )
				oPrn:Say( nLIN, 1325, "R$ " + TRANSFORM(nDES01,"@E 999,999,999.99"),oFont09n,100 )
				oPrn:Say( nLIN, 1710, "R$ " + TRANSFORM(nDES02,"@E 999,999,999.99"),oFont09n,100 )
				oPrn:Say( nLIN, 2093, "R$ " + TRANSFORM(nDES03,"@E 999,999,999.99"),oFont09n,100 )
				oPrn:Say( nLIN, 2456, "R$ " + TRANSFORM(nDES04,"@E 999,999,999.99"),oFont09n,100 )
				oPrn:Say( nLIN, 2829, "R$ " + TRANSFORM(nDES05,"@E 999,999,999.99"),oFont09n,100 )

				nLIN	:= nLIN + 60
		
				oPrn:Say( nLIN, 0260, "Valor Líquido",oFont08b,100 )
				oPrn:Say( nLIN, 1325, "R$ " + TRANSFORM(nTOT01-nDES01,"@E 999,999,999.99"),oFont09n,100 )//1050
				oPrn:Say( nLIN, 1710, "R$ " + TRANSFORM(nTOT02-nDES02,"@E 999,999,999.99"),oFont09n,100 )
				oPrn:Say( nLIN, 2093, "R$ " + TRANSFORM(nTOT03-nDES03,"@E 999,999,999.99"),oFont09n,100 )
				oPrn:Say( nLIN, 2456, "R$ " + TRANSFORM(nTOT04-nDES04,"@E 999,999,999.99"),oFont09n,100 )
				oPrn:Say( nLIN, 2829, "R$ " + TRANSFORM(nTOT05-nDES05,"@E 999,999,999.99"),oFont09n,100 )
			
				nLIN	:= nLIN + 60

				oPrn:Say( nLIN, 0260, "Faturamento Mínimo",oFont08b,100 )
				oPrn:Say( nLIN, 1325, "R$ " + TRANSFORM(nFAT01,"@E 999,999,999.99"),oFont09n,100 )//1050
				oPrn:Say( nLIN, 1710, "R$ " + TRANSFORM(nFAT02,"@E 999,999,999.99"),oFont09n,100 )
				oPrn:Say( nLIN, 2093, "R$ " + TRANSFORM(nFAT03,"@E 999,999,999.99"),oFont09n,100 )
				oPrn:Say( nLIN, 2456, "R$ " + TRANSFORM(nFAT04,"@E 999,999,999.99"),oFont09n,100 )
				oPrn:Say( nLIN, 2829, "R$ " + TRANSFORM(nFAT05,"@E 999,999,999.99"),oFont09n,100 )
	
				nLIN	:= nLIN + 60
	
				nCALC06 := calcMin(6)
				nCALC07 := calcMin(7)
				nCALC08 := calcMin(8)
				nCALC09 := calcMin(9)
				nCALC10 := calcMin(10)
				
				oPrn:Say( nLIN, 0260, "Menor Valor p/fornecedor",oFont08b,100 )
				oPrn:Say( nLIN, 1325, "R$ " + TRANSFORM(nCALC01,"@E 999,999,999.99"),oFont09n,100 )//1050
				oPrn:Say( nLIN, 1710, "R$ " + TRANSFORM(nCALC02,"@E 999,999,999.99"),oFont09n,100 )
				oPrn:Say( nLIN, 2093, "R$ " + TRANSFORM(nCALC03,"@E 999,999,999.99"),oFont09n,100 )
				oPrn:Say( nLIN, 2456, "R$ " + TRANSFORM(nCALC04,"@E 999,999,999.99"),oFont09n,100 )
				oPrn:Say( nLIN, 2829, "R$ " + TRANSFORM(nCALC05,"@E 999,999,999.99"),oFont09n,100 )			
	
				nLIN	:= nLIN + 60

				oBrush := Tbrush():New(,CLR_HGREEN )	// 1 - VERDE
				
				nPFim := aScan(aFimCot,{|x| x[1] == cNUM })

				If nPFim <> 0
					Do Case
						Case aFimCot[nPFim][2] == "6"
							oPrn:FillRect({nLIN-17,1301,nLIN+39,1692},oBrush)//01
						Case aFimCot[nPFim][2] == "7"
							oPrn:FillRect({nLIN-17,1696,nLIN+39,2075},oBrush)//02
						Case aFimCot[nPFim][2] == "8"
							oPrn:FillRect({nLIN-17,2077,nLIN+39,2438},oBrush)//03
						Case aFimCot[nPFim][2] == "9"
							oPrn:FillRect({nLIN-17,2440,nLIN+39,2811},oBrush)//04
						Case aFimCot[nPFim][2] == "10"
							oPrn:FillRect({nLIN-17,2813,nLIN+39,3177},oBrush)//05
					EndCase	
				Endif
					

				oPrn:Say( nLIN, 0260, "Valor Total",oFont08b,100 )
				oPrn:Say( nLIN, 1325, "R$ " + TRANSFORM(nTOT06 - nDES06 + nFRE06 + nIPI06 + nICM06,"@E 999,999,999.99"),oFont09n,100 )
				oPrn:Say( nLIN, 1710, "R$ " + TRANSFORM(nTOT07 - nDES07 + nFRE07 + nIPI07 + nICM07,"@E 999,999,999.99"),oFont09n,100 )
				oPrn:Say( nLIN, 2093, "R$ " + TRANSFORM(nTOT08 - nDES08 + nFRE08 + nIPI08 + nICM08,"@E 999,999,999.99"),oFont09n,100 )
				oPrn:Say( nLIN, 2456, "R$ " + TRANSFORM(nTOT09 - nDES09 + nFRE09 + nIPI09 + nICM09,"@E 999,999,999.99"),oFont09n,100 )
				oPrn:Say( nLIN, 2829, "R$ " + TRANSFORM(nTOT10 - nDES10 + nFRE10 + nIPI10 + nICM10,"@E 999,999,999.99"),oFont09n,100 )
				
				nLIN	:= nLIN + 60
		
				oPrn:Say( nLIN, 0260, "Prazo de Entrega",oFont08b,100 )
				oPrn:Say( nLIN, 1325,DTOC(dENT06),oFont08b,100 )
				oPrn:Say( nLIN, 1710,DTOC(dENT07),oFont08b,100 )
				oPrn:Say( nLIN, 2093,DTOC(dENT08),oFont08b,100 )
				oPrn:Say( nLIN, 2456,DTOC(dENT09),oFont08b,100 )
				oPrn:Say( nLIN, 2829,DTOC(dENT10),oFont08b,100 )

				nLIN	:= nLIN + 60
		
				oPrn:Say( nLIN, 0260, "Condição de Pagamento",oFont08b,100 )
				oPrn:Say( nLIN, 1325,cCON06 + " - " + POSICIONE("SE4",1,XFILIAL("SE4") + cCON06,"E4_DESCRI"),oFont08b,100 )
				oPrn:Say( nLIN, 1710,cCON07 + " - " + POSICIONE("SE4",1,XFILIAL("SE4") + cCON07,"E4_DESCRI"),oFont08b,100 )
				oPrn:Say( nLIN, 2093,cCON08 + " - " + POSICIONE("SE4",1,XFILIAL("SE4") + cCON08,"E4_DESCRI"),oFont08b,100 )
				oPrn:Say( nLIN, 2456,cCON09 + " - " + POSICIONE("SE4",1,XFILIAL("SE4") + cCON09,"E4_DESCRI"),oFont08b,100 )
				oPrn:Say( nLIN, 2829,cCON10 + " - " + POSICIONE("SE4",1,XFILIAL("SE4") + cCON10,"E4_DESCRI"),oFont08b,100 )

				nLIN	:= nLIN+60
		                            
				oPrn:Say( nLIN, 0260, "Garantia",oFont08b,100 )
				
				nLIN	:= nLIN+60
		
				////////////// QUADRO FINAL

				oPrn:Box (1980,0056,2280,3180)	//quadro
				oPrn:Box (1982,0058,2278,3178)	//quadro

			    oBrush := Tbrush():New(,CLR_LIGHTGRAY)

				nCol := 90
				oPrn:FillRect({2140, 100  + nCol , 2200 , 0730+nCol},oBrush)
				oPrn:FillRect({2140, 780  + nCol , 2200 , 1460+nCol},oBrush)
				oPrn:FillRect({2140, 1510 + nCol , 2200 , 2180+nCol},oBrush)
				oPrn:FillRect({2140, 2230 + nCol , 2200 , 2900+nCol},oBrush)

				oPrn:Line(2115, 100  + nCol , 2115 , 0730+nCol)
				oPrn:Line(2115, 780  + nCol , 2115 , 1460+nCol)
				oPrn:Line(2115, 1510 + nCol , 2115 , 2180+nCol)
				oPrn:Line(2115, 2230 + nCol , 2115 , 2900+nCol)

				oPrn:Say( 2160, 110+nCol , "COMPRADOR:  ______/______/________  "        ,oFont08b,100 )
				oPrn:Say( 2160, 790+nCol , "GESTOR SUPRIMENTOS:  ______/______/________" ,oFont08b,100 )
				oPrn:Say( 2160, 1520+nCol, "GESTOR SOLICITANTE:  ______/______/________" ,oFont08b,100 )
				oPrn:Say( 2160, 2240+nCol, "DIRETOR SOLICITANTE:  ______/______/________",oFont08b,100 )

				oPrn:Box (1440, 1300,1980, 1302)//Linha vertical dupla - rodape - Inicio - Ult.Pre
				
				oPrn:EndPage()

			EndIf
		
		END
		
		aValTot   := {}
		oPrn:Preview()
	
	ELSE // Excel
	
		oFwMsEx := FWMsExcel():New()
		
		If ! ApOleClient( 'MsExcel' ) 
			MsgAlert( "MsExcel nao instalado" )
			Return
		EndIf
		
		cAba 	:= "Cotação"
		cTable 	:= "Relatório de Cotações"
		
		oFwMsEx:AddWorkSheet( cAba )
		oFwMsEx:AddTable( cAba, cTable )
		oFwMsEx:SetTitleSizeFont(12)	 //Tamanho da fonte do tï¿½tulo
		oFwMsEx:SetLineBgColor("#FFFFFF")  //Cor de preenchimento das celulas da linha
                                                
		oFwMsEx:AddColumn( cAba, cTable , "COTAÇÃO"			    		, 1,1)
		oFwMsEx:AddColumn( cAba, cTable , "CÓDIGO PRODUTO"	 	    	, 1,1)
		oFwMsEx:AddColumn( cAba, cTable , "DESCRIÇÃO PRODUTO" 	    	, 1,1)
		oFwMsEx:AddColumn( cAba, cTable , "QUANTIDADE" 				    , 2,2)		
		oFwMsEx:AddColumn( cAba, cTable , "UNIDADE"			    		, 1,1)
		oFwMsEx:AddColumn( cAba, cTable , "ÚLTIMA COMPRA"	 	    	, 1,1)
		oFwMsEx:AddColumn( cAba, cTable , "ÚLTIMO VALOR"	    		, 2,3)

		oFwMsEx:AddColumn( cAba, cTable , "CODIGO FORNECEDOR 01"   		, 1,1)		
		oFwMsEx:AddColumn( cAba, cTable , "FORNECEDOR 01"	    		, 1,1)
		oFwMsEx:AddColumn( cAba, cTable , "VALOR UNITÁRIO 01"	    	, 2,3)
		oFwMsEx:AddColumn( cAba, cTable , "VALOR TOTAL 01"		    	, 2,3)

		oFwMsEx:AddColumn( cAba, cTable , "CODIGO FORNECEDOR 02"  		, 1,1)		
		oFwMsEx:AddColumn( cAba, cTable , "FORNECEDOR 02"	    		, 1,1)
		oFwMsEx:AddColumn( cAba, cTable , "VALOR UNITÁRIO 02"	    	, 2,3)
		oFwMsEx:AddColumn( cAba, cTable , "VALOR TOTAL 02"		    	, 2,3)

		oFwMsEx:AddColumn( cAba, cTable , "CODIGO FORNECEDOR 03"   		, 1,1)		
		oFwMsEx:AddColumn( cAba, cTable , "FORNECEDOR 03"	    		, 1,1)
		oFwMsEx:AddColumn( cAba, cTable , "VALOR UNITÁRIO 03"	    	, 2,3)
		oFwMsEx:AddColumn( cAba, cTable , "VALOR TOTAL 03"		    	, 2,3)

		oFwMsEx:AddColumn( cAba, cTable , "CODIGO FORNECEDOR 04"   		, 1,1)		
		oFwMsEx:AddColumn( cAba, cTable , "FORNECEDOR 04"	    		, 1,1)
		oFwMsEx:AddColumn( cAba, cTable , "VALOR UNITÁRIO 04"	    	, 2,3)
		oFwMsEx:AddColumn( cAba, cTable , "VALOR TOTAL 04"		    	, 2,3)

		oFwMsEx:AddColumn( cAba, cTable , "CODIGO FORNECEDOR 05"   		, 1,1)		
		oFwMsEx:AddColumn( cAba, cTable , "FORNECEDOR 05" 	    		, 1,1)
		oFwMsEx:AddColumn( cAba, cTable , "VALOR UNITÁRIO 05"	    	, 2,3)
		oFwMsEx:AddColumn( cAba, cTable , "VALOR TOTAL 05"		    	, 2,3)

		oFwMsEx:AddColumn( cAba, cTable , "CODIGO FORNECEDOR 06"   		, 1,1)		
		oFwMsEx:AddColumn( cAba, cTable , "FORNECEDOR 06"	    		, 1,1)
		oFwMsEx:AddColumn( cAba, cTable , "VALOR UNITÁRIO 06"	    	, 2,3)
		oFwMsEx:AddColumn( cAba, cTable , "VALOR TOTAL 06"		    	, 2,3)

		oFwMsEx:AddColumn( cAba, cTable , "CODIGO FORNECEDOR 07"   		, 1,1)		
		oFwMsEx:AddColumn( cAba, cTable , "FORNECEDOR 07"	    		, 1,1)
		oFwMsEx:AddColumn( cAba, cTable , "VALOR UNITÁRIO 07"	    	, 2,3)
		oFwMsEx:AddColumn( cAba, cTable , "VALOR TOTAL 07"		    	, 2,3)

		oFwMsEx:AddColumn( cAba, cTable , "CODIGO FORNECEDOR 08"   		, 1,1)		
		oFwMsEx:AddColumn( cAba, cTable , "FORNECEDOR 08"	    		, 1,1)
		oFwMsEx:AddColumn( cAba, cTable , "VALOR UNITÁRIO 08"	    	, 2,3)
		oFwMsEx:AddColumn( cAba, cTable , "VALOR TOTAL 08"		    	, 2,3)

		oFwMsEx:AddColumn( cAba, cTable , "CODIGO FORNECEDOR 09"   		, 1,1)		
		oFwMsEx:AddColumn( cAba, cTable , "FORNECEDOR 09"	    		, 1,1)
		oFwMsEx:AddColumn( cAba, cTable , "VALOR UNITÁRIO 09"	    	, 2,3)
		oFwMsEx:AddColumn( cAba, cTable , "VALOR TOTAL 09"		    	, 2,3)

		oFwMsEx:AddColumn( cAba, cTable , "CODIGO FORNECEDOR 10"   		, 1,1)		
		oFwMsEx:AddColumn( cAba, cTable , "FORNECEDOR 10"	    		, 1,1)
		oFwMsEx:AddColumn( cAba, cTable , "VALOR UNITÁRIO 10"	    	, 2,3)
		oFwMsEx:AddColumn( cAba, cTable , "VALOR TOTAL 10"		    	, 2,3)
	
		//aTOTEXC := {}
	    /*
		AADD(aTOTEXC,{"COTACAO",;
			"CODIGO",;
			"PRODUTO",;
			"QUANT",;
			"UNIDADE",;
			"CODFOR",;
			"FORNECEDOR",;
			"V.UNIT.",;
			"V.TOTAL",;
			"CODFOR",;
			"FORNECEDOR",;
			"V.UNIT.",;
			"V.TOTAL",;
			"CODFOR",;
			"FORNECEDOR",;
			"V.UNIT.",;
			"V.TOTAL",;
			"CODFOR",;
			"FORNECEDOR",;
			"V.UNIT.",;
			"V.TOTAL",;
			"CODFOR",;
			"FORNECEDOR",;
			"V.UNIT.",;
			"V.TOTAL"})
			
		*/
		
		TBR->(DbSetOrder(1))
		TBR->(DbGoTop())

		WHILE TBR->(!EOF())
		
			oFwMsEx:AddRow( cAba, cTable, {		TBR->BR_NUM,;  
												TBR->BR_CODIGO,;
												TBR->BR_DESC,;
												Trans(TBR->BR_QTDE,Tm(0, 14, 2)),;
												TBR->BR_UM,;   
												SubStr(DTOS(TBR->BR_ULC01),5,2) + "/" + SubStr(DTOS(TBR->BR_ULC01),3,2),;
												Trans(TBR->BR_UNP01,Tm(0, 14, 2)),;
												TBR->BR_FOR01,;
												TBR->BR_NOM01,;
												Trans(TBR->BR_UNI01,Tm(0, 14, 2)),;
												Trans(TBR->BR_TOT01,Tm(0, 14, 2)),;
												TBR->BR_FOR02,;
												TBR->BR_NOM02,;
												Trans(TBR->BR_UNI02,Tm(0, 14, 2)),;
												Trans(TBR->BR_TOT02,Tm(0, 14, 2)),;
												TBR->BR_FOR03,;
												TBR->BR_NOM03,;
												Trans(TBR->BR_UNI03,Tm(0, 14, 2)),;
												Trans(TBR->BR_TOT03,Tm(0, 14, 2)),;
												TBR->BR_FOR04,;
												TBR->BR_NOM04,;
												Trans(TBR->BR_UNI04,Tm(0, 14, 2)),;
												Trans(TBR->BR_TOT04,Tm(0, 14, 2)),;
												TBR->BR_FOR05,;
												TBR->BR_NOM05,;
												Trans(TBR->BR_UNI05,Tm(0, 14, 2)),;
												Trans(TBR->BR_TOT05,Tm(0, 14, 2)),;
												TBR->BR_FOR06,;
												TBR->BR_NOM06,;
												Trans(TBR->BR_UNI06,Tm(0, 14, 2)),;
												Trans(TBR->BR_TOT06,Tm(0, 14, 2)),;
												TBR->BR_FOR07,;
												TBR->BR_NOM07,;
												Trans(TBR->BR_UNI07,Tm(0, 14, 2)),;
												Trans(TBR->BR_TOT07,Tm(0, 14, 2)),;
												TBR->BR_FOR08,;
												TBR->BR_NOM08,;
												Trans(TBR->BR_UNI08,Tm(0, 14, 2)),;
												Trans(TBR->BR_TOT08,Tm(0, 14, 2)),;
												TBR->BR_FOR09,;
												TBR->BR_NOM09,;
												Trans(TBR->BR_UNI09,Tm(0, 14, 2)),;
												Trans(TBR->BR_TOT09,Tm(0, 14, 2)),;
												TBR->BR_FOR10,;
												TBR->BR_NOM10,;
												Trans(TBR->BR_UNI10,Tm(0, 14, 2)),;
												Trans(TBR->BR_TOT10,Tm(0, 14, 2)) } )
		
			TBR->(DbSkip())
			
		END
	
		/*
		acabexcel := {}
	
		AADD(acabexcel,,{"COTACAO",;
			"CODIGO",;
			"PRODUTO",;
			"QUANT",;
			"UNIDADE",;
			"CODFOR",;
			"FORNECEDOR",;
			"V.UNIT.",;
			"V.TOTAL",;
			"CODFOR",;
			"FORNECEDOR",;
			"V.UNIT.",;
			"V.TOTAL",;
			"CODFOR",;
			"FORNECEDOR",;
			"V.UNIT.",;
			"V.TOTAL",;
			"CODFOR",;
			"FORNECEDOR",;
			"V.UNIT.",;
			"V.TOTAL",;
			"CODFOR",;
			"FORNECEDOR",;
			"V.UNIT.",;
			"V.TOTAL"})
	    */
	    
		//If !apoleclient("MSExcel")
			//MSGALERT("Não foi possivel enviar os dados, Microsoft Excel não instalado!")
		//Else
			//dlgtoexcel({{"ARRAY","Relatorio de Cotações",acabexcel,aTOTEXC }})
		//Endif
		
		oFwMsEx:Activate()
		cTeste := CriaTrab( NIL, .F. ) + ".xml"	
		cArq := CriaTrab( NIL, .F. ) + ".xls"
		oFwMsEx:GetXMLFile( cArq )

		If __CopyFile( cArq, cDirTmp + cArq )

			If ! ApOleClient( 'MsExcel' )
				ShellExecute("open",cDirTmp + cArq,"","", 1 )
				Return
			EndIf	

			oExcelApp := MsExcel():New()
			oExcelApp:WorkBooks:Open( cDirTmp + cArq )
			oExcelApp:SetVisible(.T.)

		Endif    
		
	
	ENDIF

return

///

STATIC FUNCTION CABCOT(cNUM,aSC)

	Local X

	oPrn:StartPage()

	cBitMap:="LGRL01.bmp"
	
	oPrn:SayBitmap( 0050, 0050,cBitMap,500,150)
	cSC := ""

	For X:=1 To Len(aSC)

		IF aSC[X][1] == cNUM

			If Empty(cSC)
				cSC := aSC[X][2]
			Else
				cSC += ", " + aSC[X][2]
			EndIf
			
		EndIf
		
	Next

	If !"," $ cSC

		oPrn:Say( 0150, 1000, "Solicitação de Compra Nº: " + cSC ,oFont4,100 )
		oPrn:Say( 0150, 3000, "Pag.: " + STRZERO(nPag,3),oFont3,100 ) // Maurício Aureliano - 12/04/2018 - Chamado: I1710-2277

	Else

		oPrn:Say( 0150, 1000, "Solicitações de Compra Nºs: " + cSC,oFont4,100 )
		oPrn:Say( 0150, 3000, "Pag.: " + STRZERO(nPag,3),oFont3,100 ) // Maurício Aureliano - 12/04/2018 - Chamado: I1710-2277

	EndiF
	
	oPrn:Say( 0250, 0100, "Data " + dToc(DdataBase),oFont3,100)
	oPrn:Say( 0250, 1000, "Cotação de Preços Nº. " + TBR->BR_NUM,oFont4,100)
	oPrn:Say( 0250, 1800, "Unidade " + Alltrim(SM0->M0_FILIAL) + " / Pedido N:___________________ DATA:___________________",oFont2,100 )

	oPrn:Box (0350, 0056,1440, 3180)	//quadro
	oPrn:Box (0352, 0058,1438, 3178)

	oPrn:Line(0420, 1302,0420, 3180)// Linha separadora dos Codigos e Nome fornecedores

	oPrn:Box(0480, 0056,0482, 3180)

	oPrn:Box(0540, 0056,0542, 3180)

	//oBrush := Tbrush():New(,CLR_BLACK)	//1.
	//oPrn:FillRect({0482, 0058,0542, 3178},oBrush)

	// linhas horizontais

	nLIN := 600

	For X:=1 To 14// as 14 linhas do miolo

		oPrn:Line(nLIN, 0056,nLIN, 3180)
		nLIN := nLIN + 60

	Next

	// linhas verticais do cabecalho

	oPrn:Line(0480, 0315,1440, 0315)  //01 Codigo
	oPrn:Line(0480, 0810,1440, 0810)  //02 Descricao
	oPrn:Line(0480, 0960,1440, 0960)  //03 Qtde
	oPrn:Line(0480, 1010,1440, 1010)  //04 UN
	oPrn:Line(0480, 1110,1440, 1110)  //05 Ultima Compra
	oPrn:Box (0350, 1300,1440, 1302)  //06 Ultimo Preco - Linha dupla
	oPrn:Line(0480, 1490,1440, 1490)  //07 Preco Unitario 01
	oPrn:Box (0350, 1695,1440, 1697)  //08 Total 01
	oPrn:Line(0480, 1875,1440, 1875)  //09 Preco Unitario 02
	oPrn:Box (0350, 2078,1440, 2080)  //10 Total 02
    oPrn:Line(0480, 2258,1440, 2258)  //11 Preco Unitario 03
	oPrn:Box (0350, 2441,1440, 2443)  //12 Total 03
	oPrn:Line(0480, 2631,1440, 2631)  //15 Preco Unitario 04
	oPrn:Box (0350, 2814,1440, 2816)  //16 Total 04
	oPrn:Line(0480, 3004,1440, 3004)  //17 Preco Unitario 05
    
	oPrn:Say( 0400, 0600, "PRODUTOS",oFont08b,100 )
        
	aFOR := {}

	For X:=1 To Len(aFORNECE)

		If aFORNECE[X][1] == cNUM
			AADD(aFOR,{cNUM,aFORNECE[X][2],aFORNECE[X][3]})
		EndIf
		
	End

	For X:=1 To Len(aFOR)//Quantidade de Fornecedor por Cotacao
	
		If X == 1
			oPrn:Say( 0380, 1312, SUBS(aFOR[X][2],1,6)+"/"+SUBS(aFOR[X][2],7,2),oFont08b,100 )//1170 //Codigo e loja do Fornecedor 01
			oPrn:Say( 0440, 1312, SUBS(aFOR[X][3],1,15),oFont08b,100 )//1150
		ElseIf X == 2
			oPrn:Say( 0380, 1707, SUBS(aFOR[X][2],1,6)+"/"+SUBS(aFOR[X][2],7,2),oFont08b,100 )//Codigo e loja do Fornecedor 02
			oPrn:Say( 0440, 1707, SUBS(aFOR[X][3],1,15),oFont08b,100 )
		ElseIf X == 3
			oPrn:Say( 0380, 2090, SUBS(aFOR[X][2],1,6)+"/"+SUBS(aFOR[X][2],7,2),oFont08b,100 )//Codigo e loja do Fornecedor 03
			oPrn:Say( 0440, 2090, SUBS(aFOR[X][3],1,15),oFont08b,100 )
		ElseIf X == 4
			oPrn:Say( 0380, 2453, SUBS(aFOR[X][2],1,6)+"/"+SUBS(aFOR[X][2],7,2),oFont08b,100 )//Codigo e loja do Fornecedor 04
			oPrn:Say( 0440, 2453, SUBS(aFOR[X][3],1,15),oFont08b,100 )
		ElseIf X == 5
			oPrn:Say( 0380, 2826, SUBS(aFOR[X][2],1,6)+"/"+SUBS(aFOR[X][2],7,2),oFont08b,100 )//Codigo e loja do Fornecedor 05
			oPrn:Say( 0440, 2826, SUBS(aFOR[X][3],1,15),oFont08b,100 )
		ElseIf X > 5
			lCont:= .T.
		EndIf
	
	Next                            
	
    //Cabecalho colunas                         
	oPrn:Say( 0495, 0065, "Código"		,oFont08b,100,CLR_WHITE )
	oPrn:Say( 0495, 0320, "Descrição"	,oFont08b,100,CLR_WHITE )
	oPrn:Say( 0495, 0860, "Qtde"		,oFont08b,100,CLR_WHITE )
	oPrn:Say( 0495, 0965, "Un."			,oFont08b,100,CLR_WHITE )
	oPrn:Say( 0495, 1020, "Ul.Com"		,oFont08b,100,CLR_WHITE )
	oPrn:Say( 0495, 1170, "Ult.Pre"		,oFont08b,100,CLR_WHITE )

	oPrn:Say( 0495, 1360, "Pr.Unit"		,oFont08b,100,CLR_WHITE )
	oPrn:Say( 0495, 1550, "Total"		,oFont08b,100,CLR_WHITE )

	oPrn:Say( 0495, 1745, "Pr.Unit"		,oFont08b,100,CLR_WHITE )
	oPrn:Say( 0495, 1945, "Total"		,oFont08b,100,CLR_WHITE )

	oPrn:Say( 0495, 2118, "Pr.Unit"		,oFont08b,100,CLR_WHITE )
	oPrn:Say( 0495, 2308, "Total"		,oFont08b,100,CLR_WHITE )

	oPrn:Say( 0495, 2501, "Pr.Unit"		,oFont08b,100,CLR_WHITE )
	oPrn:Say( 0495, 2681, "Total"		,oFont08b,100,CLR_WHITE )

	oPrn:Say( 0495, 2874, "Pr.Unit"		,oFont08b,100,CLR_WHITE )
	oPrn:Say( 0495, 3034, "Total"		,oFont08b,100,CLR_WHITE )

	nLIN := 560

Return


/*
---------------------------------------------------------
Autor.....: William Souza - Ethosx Consultoria e Soluções
Sub Rotina: calcMin()
Data......: 03/01/2019

Descricao:
Static function para calcular o total dos itens de menor
valor do fornecedor 
---------------------------------------------------------
*/

Static function calcMin(nPos)

Local nValor := 0
Local i

for i := 1 to len(aTRB2)
    if aTRB2[i][1] == nPos
        nValor += aTRB2[i][2]
    EndIf
Next

Return nValor

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³OUROR011  ºAutor  ³Microsiga           º Data ³  05/06/19   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

STATIC FUNCTION CABCONT(cNUM,aSC)

	Local X
	
	lCont:=.F.

	oPrn:StartPage()

	cBitMap:="LGRL01.bmp"
	oPrn:SayBitmap( 0050, 0050,cBitMap,500,150)
	cSC := ""

	For X:=1 To Len(aSC)

		IF aSC[X][1] == cNUM

			If Empty(cSC)
				cSC := aSC[X][2]
			Else
				cSC += ", " + aSC[X][2]
			EndIf
			
		EndIf
		
	Next

	If !"," $ cSC

		oPrn:Say( 0150, 1000, "Solicitação de Compra Nº: " + cSC ,oFont4,100 )
		oPrn:Say( 0150, 3000, "Pag.: " + STRZERO(nPag,3),oFont3,100 ) // Maurício Aureliano - 12/04/2018 - Chamado: I1710-2277

	Else

		oPrn:Say( 0150, 1000, "Solicitações de Compra Nºs: " + cSC,oFont4,100 )
		oPrn:Say( 0150, 3000, "Pag.: " + STRZERO(nPag,3),oFont3,100 ) // Maurício Aureliano - 12/04/2018 - Chamado: I1710-2277

	EndiF
	
	oPrn:Say( 0250, 0100, "Data " + dToc(DdataBase),oFont3,100)
	oPrn:Say( 0250, 1000, "Cotação de Preços Nº. " + TBR->BR_NUM,oFont4,100)	
	oPrn:Say( 0250, 1800, "Unidade " + Alltrim(SM0->M0_FILIAL) + " / Pedido N:___________________ DATA:___________________",oFont2,100 )

	oPrn:Box (0350, 0056,1440, 3180)	//quadro
	oPrn:Box (0352, 0058,1438, 3178)

	oPrn:Line(0420, 1302,0420, 3180)// Linha separadora dos Codigos e Nome fornecedores

	oPrn:Box(0480, 0056,0482, 3180)

	oPrn:Box(0540, 0056,0542, 3180)

	//oBrush := Tbrush():New(,CLR_BLACK)	//saldo para mais fornecedores
	//oPrn:FillRect({0482, 0058,0542, 3178},oBrush)
	//oBrush := Tbrush():New(,CLR_WHITE )	//Andre Salgado 16/12/2020 - Correção do BUG da Cor Preta

	// linhas horizontais
	nLIN := 600

	For X:=1 To 14

		oPrn:Line(nLIN, 0056,nLIN, 3180)
		nLIN := nLIN + 60

	Next

	// linhas verticais
	oPrn:Line(0480, 0315,1440, 0315)  //01 Codigo
	oPrn:Line(0480, 0810,1440, 0810)  //02 Descricao
	oPrn:Line(0480, 0960,1440, 0960)  //03 Qtde
	oPrn:Line(0480, 1010,1440, 1010)  //04 UN
	oPrn:Line(0480, 1110,1440, 1110)  //05 Ultima Compra
	oPrn:Box (0350, 1300,1440, 1302)  //06 Ultimo Preco - Linha dupla
	oPrn:Line(0480, 1490,1440, 1490)  //07 Preco Unitario 01
	oPrn:Box (0350, 1695,1440, 1697)  //08 Total 01
	oPrn:Line(0480, 1875,1440, 1875)  //09 Preco Unitario 02
	oPrn:Box (0350, 2078,1440, 2080)  //10 Total 02
    oPrn:Line(0480, 2258,1440, 2258)  //11 Preco Unitario 03
	oPrn:Box (0350, 2441,1440, 2443)  //12 Total 03
	oPrn:Line(0480, 2631,1440, 2631)  //13 Preco Unitario 04
	oPrn:Box (0350, 2814,1440, 2816)  //14 Total 04
	oPrn:Line(0480, 3004,1440, 3004)  //15 Preco Unitario 05
    
	oPrn:Say( 0400, 0600, "PRODUTOS",oFont08b,100 )
        
	aFOR := {}

	For X:=1 To Len(aFORNECE)

		If aFORNECE[X][1] == cNUM
			AADD(aFOR,{cNUM,aFORNECE[X][2],aFORNECE[X][3]})
		EndIf
		
	End

	For X:=1 To Len(aFOR)//Quantidade de Fornecedor por Cotacao
	
		If X == 6
			oPrn:Say( 0380, 1312, SUBS(aFOR[X][2],1,6)+"/"+SUBS(aFOR[X][2],7,2),oFont08b,100 )//1170 //Codigo e loja do Fornecedor 01
			oPrn:Say( 0440, 1312, SUBS(aFOR[X][3],1,15),oFont08b,100 )//1150
		ElseIf X == 7
			oPrn:Say( 0380, 1707, SUBS(aFOR[X][2],1,6)+"/"+SUBS(aFOR[X][2],7,2),oFont08b,100 )//Codigo e loja do Fornecedor 02
			oPrn:Say( 0440, 1707, SUBS(aFOR[X][3],1,15),oFont08b,100 )
		ElseIf X == 8
			oPrn:Say( 0380, 2090, SUBS(aFOR[X][2],1,6)+"/"+SUBS(aFOR[X][2],7,2),oFont08b,100 )//Codigo e loja do Fornecedor 03
			oPrn:Say( 0440, 2090, SUBS(aFOR[X][3],1,15),oFont08b,100 )
		ElseIf X == 9
			oPrn:Say( 0380, 2453, SUBS(aFOR[X][2],1,6)+"/"+SUBS(aFOR[X][2],7,2),oFont08b,100 )//Codigo e loja do Fornecedor 04
			oPrn:Say( 0440, 2453, SUBS(aFOR[X][3],1,15),oFont08b,100 )
		ElseIf X == 10
			oPrn:Say( 0380, 2826, SUBS(aFOR[X][2],1,6)+"/"+SUBS(aFOR[X][2],7,2),oFont08b,100 )//Codigo e loja do Fornecedor 05
			oPrn:Say( 0440, 2826, SUBS(aFOR[X][3],1,15),oFont08b,100 )
		EndIf
	
	Next

    //Cabecalho colunas                         
	oPrn:Say( 0495, 0065, "Código"		,oFont08b,100,CLR_WHITE )
	oPrn:Say( 0495, 0320, "Descrição"	,oFont08b,100,CLR_WHITE )
	oPrn:Say( 0495, 0860, "Qtde"		,oFont08b,100,CLR_WHITE )
	oPrn:Say( 0495, 0965, "Un."			,oFont08b,100,CLR_WHITE )
	oPrn:Say( 0495, 1020, "Ul.Com"		,oFont08b,100,CLR_WHITE )
	oPrn:Say( 0495, 1170, "Ult.Pre"		,oFont08b,100,CLR_WHITE )

	oPrn:Say( 0495, 1360, "Pr.Unit"		,oFont08b,100,CLR_WHITE )
	oPrn:Say( 0495, 1550, "Total"		,oFont08b,100,CLR_WHITE )

	oPrn:Say( 0495, 1745, "Pr.Unit"		,oFont08b,100,CLR_WHITE )
	oPrn:Say( 0495, 1945, "Total"		,oFont08b,100,CLR_WHITE )

	oPrn:Say( 0495, 2118, "Pr.Unit"		,oFont08b,100,CLR_WHITE )
	oPrn:Say( 0495, 2308, "Total"		,oFont08b,100,CLR_WHITE )

	oPrn:Say( 0495, 2501, "Pr.Unit"		,oFont08b,100,CLR_WHITE )
	oPrn:Say( 0495, 2681, "Total"		,oFont08b,100,CLR_WHITE )

	oPrn:Say( 0495, 2874, "Pr.Unit"		,oFont08b,100,CLR_WHITE )
	oPrn:Say( 0495, 3034, "Total"		,oFont08b,100,CLR_WHITE )

	nLIN := 560

Return
