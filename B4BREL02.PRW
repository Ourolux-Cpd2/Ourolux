#INCLUDE "Protheus.ch" 
#INCLUDE "rwmake.ch" 
#INCLUDE "TOPCONN.CH""

Static aSizeAdv			:= MsAdvSize(.F.)
                                         
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ B4BREL02 ³ Autor ³Fábrica B4B 			³ Data ³23.09.2013³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Relatório de FRETE										  ³±±
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
User Function B4BREL02()
Local aParam     := {}

Private cPerg      := "B4BREL02"
Private aBrowse    := {}

GetSx1Perg()//Carrega as perguntas do relatório

If Pergunte(cPerg)
	oReport := ReportDef(cPerg, aBrowse)
	oReport:PrintDialog()               
EndIf

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ReportDef ³ Autor ³Fábrica   		   	    ³ Data ³23.09.2013³±±
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

oReport:= TReport():New("B4BREL02","Relatório de Frete", If(.F.,Nil,cPerg), {|oReport| ReportPrint(oReport,aBrowse )},"Relatório de Frete",,,,,.F.)//"Relatório de Frete"
oReport:SetLandscape()      //Define a orientação de página do relatório como paisagem.
oReport:SetTotalInLine(.F.)
oReport:lParamReadOnly := .T.

oSec1 := TRSection():New(oReport,"Relatório",{"SD1"},,,,,,.T.)
oSec1:SetTotalInLine(.F.)
oSec1:SetLineStyle(.F.)//Define se imprime as células da seção em linhas

TRCell():New(oSec1,"cNF"  		 ,"","Nota Fiscal"		,"@!",20,/*lPixel*/,,"LEFT",	,"LEFT",)
TRCell():New(oSec1,"cSerie" 	 ,"","Serie"	   		,"@!",20,/*lPixel*/,,"LEFT",	,"LEFT",)
If MV_PAR12 == 1//Liquido
	TRCell():New(oSec1,"nValLiq"  	 ,"","Valor Liquido"	,PesqPict('SF2','F2_VALMERC') 	,14,/*lPixel*/,,"LEFT",		,"LEFT",)
Else
	TRCell():New(oSec1,"nValLiq"  	 ,"","Valor Bruto"		,PesqPict('SF2','F2_VALMERC') 	,14,/*lPixel*/,,"LEFT",		,"LEFT",)
EndIf
TRCell():New(oSec1,"nValFrete" 	 ,"","Valor do Frete"	,PesqPict('SF2','F2_VALMERC')	,14,/*lPixel*/,,"LEFT",		,"LEFT",)
TRCell():New(oSec1,"nPercFrete"  ,"","%Frete"			,PesqPict('SF2','F2_VALMERC')	,14,/*lPixel*/,,"LEFT",		,"LEFT",)

oSec2 := TRSection():New(oReport,"Relatório",{"SD1"},,,,,,.F.)
oSec2:SetTotalInLine(.F.)
oSec2:SetLineStyle(.F.)//Define se imprime as células da seção em linhas

TRCell():New(oSec2,"cNF"  		,"",""						,"@!",20,/*lPixel*/,,"LEFT",	,"LEFT",)
TRCell():New(oSec2,"nCol"	  	,"",""						,"@!",20,/*lPixel*/,,"LEFT",		,"LEFT",)
If MV_PAR12 == 1//Liquido
	TRCell():New(oSec2,"nValLiq"  	,"","Total Liquido"			,PesqPict('SF2','F2_VALMERC') 	,14,/*lPixel*/,,"LEFT",		,"LEFT",)
Else
	TRCell():New(oSec2,"nValLiq"  	,"","Total Bruto"			,PesqPict('SF2','F2_VALMERC') 	,14,/*lPixel*/,,"LEFT",		,"LEFT",)
EndiF
TRCell():New(oSec2,"nValFrete" 	,"","Total Frete" 			,PesqPict('SF2','F2_VALMERC')	,14,/*lPixel*/,,"LEFT",		,"LEFT",)
TRCell():New(oSec2,"nPercFrete" ,"","Total %Frete"			,PesqPict('SF2','F2_VALMERC')	,14,/*lPixel*/,,"LEFT",		,"LEFT",)


oSec3 := TRSection():New(oReport,"Relatório",{"SD1"},,,,,,.T.)
oSec3:SetTotalInLine(.F.)
oSec3:SetLineStyle(.F.)//Define se imprime as células da seção em linhas

TRCell():New(oSec3,"cEmp"  		,"",""						,"@!",50,/*lPixel*/,,"LEFT",	,"LEFT",)

oSec4 := TRSection():New(oReport,"Quebra Fil",{"SD1"},,,,,,.T.)
oSec4:SetTotalInLine(.F.)
oSec4:SetLineStyle(.F.)//Define se imprime as células da seção em linhas

TRCell():New(oSec4,"cQuebra"  		,"",""						,"@!",50,/*lPixel*/,,"LEFT",	,"LEFT",)

oSec5 := TRSection():New(oReport,"Total ",{"SD1"},,,,,,.F.)
oSec5:SetTotalInLine(.F.)
oSec5:SetLineStyle(.F.)//Define se imprime as células da seção em linhas

TRCell():New(oSec5,"cNF"  		,"",""						,"@!",20,/*lPixel*/,,"LEFT",	,"LEFT",)
TRCell():New(oSec5,"nCol"	  	,"",""						,"@!",20,/*lPixel*/,,"LEFT",		,"LEFT",)
If MV_PAR12 == 1//Liquido
	TRCell():New(oSec5,"nValLiq"  	,"","Total Liquido"			,PesqPict('SF2','F2_VALMERC') 	,14,/*lPixel*/,,"LEFT",		,"LEFT",)
Else
	TRCell():New(oSec5,"nValLiq"  	,"","Total Bruto"			,PesqPict('SF2','F2_VALMERC') 	,14,/*lPixel*/,,"LEFT",		,"LEFT",)
EndiF
TRCell():New(oSec5,"nValFrete" 	,"","Total Frete" 			,PesqPict('SF2','F2_VALMERC')	,14,/*lPixel*/,,"LEFT",		,"LEFT",)
TRCell():New(oSec5,"nPercFrete" ,"","Total %Frete"			,PesqPict('SF2','F2_VALMERC')	,14,/*lPixel*/,,"LEFT",		,"LEFT",)


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
Local cQuery     := ""
Local cAgrupFil  := ""
Local cQuebraFil := ""
Local cTransp    := ""
Local cQuebra    := ""
Local cAgrup     := ""
Local nValLiqTot := 0
Local nValFreTot := 0
Local nValLiq    := 0
Local nValFrete  := 0
Local nTotEmpFrete:= 0
Local nTotEmpLiq := 0
Local nFilLiqTot := 0
Local nFilFreTot := 0
Local nTotFilFrete := 0
Local nTotFilLiq  := 0

Local oSec1      := oReport:Section(1)
Local oSec2      := oReport:Section(2)
Local oSec3      := oReport:Section(3)
Local oSec4      := oReport:Section(4)
Local oSec5      := oReport:Section(5) 

Private cAliasTMP  := GetNextAlias() 
Private cString    := ""

#IFDEF TOP
	For nX := 1 To Len(aBrowse)
		If aBrowse[nX][1]             
			If nX <> Len(aBrowse)
				cString += "'"+Alltrim(aBrowse[nX][2])+"',"	
			Else
				cString += "'"+Alltrim(aBrowse[nX][2])+"'"				
			EndIf
		EndIF
	Next nX
		
	If !Empty(cString) .And. Len(cString) == RAT(",",cString)
		
		cString := SubStr(cString,1,RAT(",",cString)-1)
				
	Else 		
		cString := cString
	                                                                   
	EndIf
	
	/*cQuery := "SELECT D1_FILIAL, F4_XTPOPER, F2_DOC, F2_SERIE, SUM(D1_TOTAL) AS TOTAL"+CRLF
	cQuery += "FROM "+RetSqlName('SF2')+" SF2"+CRLF
	
	cQuery += "INNER JOIN "+RetSqlName('SD2')+" SD2"+CRLF
	cQuery += "ON SD2.D2_DOC = SF2.F2_DOC"+CRLF
	cQuery += "AND SD2.D2_SERIE = SF2.F2_SERIE"+CRLF
	cQuery += "AND SD2.D2_FILIAL = SF2.F2_FILIAL"+CRLF	
	cQuery += "AND SD2.D2_EMISSAO BETWEEN '"+DTOS(MV_PAR01)+"' AND '"+DTOS(MV_PAR02)+"'"+CRLF
	cQuery += "AND SD2.D_E_L_E_T_ <> '*'"+CRLF

	If MV_PAR03 == 1//Nao
		cQuery += "AND SD2.D2_FILIAL ='"+xFilial("SD2")+"'"+CRLF	
	EndIf

	cQuery += "INNER JOIN "+RetSqlName('SF4')+" SF4"+CRLF
	cQuery += "ON SF4.F4_CODIGO = SD2.D2_TES"+CRLF
	cQuery += "AND SF4.F4_MSBLQL <> '1'"+CRLF		

	If MV_PAR04 <> 5
		cQuery += "AND SF4.F4_XTPOPER ='"+cValToChar(MV_PAR04)+"' "+CRLF
	Else
		cQuery += "AND SF4.F4_XTPOPER IN ('1','2','3') "+CRLF	
	EndIf

	cQuery += "INNER JOIN "+RetSqlName('SD1')+" SD1"+CRLF
	cQuery += "ON SD1.D1_NFORI = SF2.F2_DOC"+CRLF
	cQuery += "AND SD1.D1_SERIORI = SF2.F2_SERIE"+CRLF
	cQuery += "AND SD1.D1_FILIAL = SF2.F2_FILIAL"+CRLF	
	cQuery += "AND SD1.D1_COD IN ('RDESPACHO', 'DEVOLUCAO', 'FRETE')"+CRLF
	cQuery += "AND SD1.D_E_L_E_T_ <> '*'"+CRLF

	If MV_PAR03 == 1//Nao
		cQuery += "AND SD1.D1_FILIAL ='"+xFilial("SD1")+"'"+CRLF	
	EndIf

	cQuery += "INNER JOIN "+RetSqlName('SF1')+" SF1"+CRLF
	cQuery += "ON SF1.F1_DOC = SD1.D1_DOC"+CRLF
	cQuery += "AND SF1.F1_SERIE = SD1.D1_SERIE"+CRLF
	cQuery += "AND SF1.F1_FILIAL = SD1.D1_FILIAL"+CRLF	
	cQuery += "AND SF1.D_E_L_E_T_ <> '*'"+CRLF

	cQuery += "AND (SF1.F1_ESPECIE = 'CTR' OR SF1.F1_ESPECIE = 'CTE')"+CRLF	
	cQuery += "AND SF1.F1_TRANSP BETWEEN '"+MV_PAR06+"' AND '"+MV_PAR07+"'"+CRLF
	cQuery += "AND SF1.F1_FORNECE BETWEEN '"+MV_PAR08+"' AND '"+MV_PAR09+"'"+CRLF
	cQuery += "AND SF1.F1_LOJA BETWEEN '"+MV_PAR10+"' AND '"+MV_PAR11+"'"+CRLF		

	cQuery += "INNER JOIN "+RetSqlName('SA1')+" SA1"+CRLF
	cQuery += "ON SA1.A1_COD = SF1.F1_FORNECE"+CRLF
	cQuery += "AND SA1.A1_LOJA = SF1.F1_LOJA"+CRLF
	cQuery += "AND SA1.A1_EST IN ("+cString+")"+CRLF
	cQuery += "AND SA1.A1_FILIAL ='"+xFilial("SA1")+"'"+CRLF
	cQuery += "AND SA1.D_E_L_E_T_ <> '*'"+CRLF   

	cQuery += "GROUP BY D1_FILIAL, F4_XTPOPER, F2_DOC, F2_SERIE"+CRLF
	
	cQuery += "ORDER BY D1_FILIAL, F4_XTPOPER"+CRLF
	

	IF SELECT("TRA") > 0
		TRA->(DBCLOSEAREA())
	ENDIF
	
	cQuery := ChangeQuery(cQuery) 
	DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasTMP,.F.,.T. )*/

	//Filtra dados e cria tabela temporaria	
	Processa({|| RetTrb()})
	
	dbSelectArea(cAliasTMP)
	(cAliasTMP)->(dbGotop())

	If MV_PAR03 == 1
		oSec1:Init()
	EndIf                    	

	cAgrupFil := (cAliasTMP)->F4_XTPOPER
	cAgrup 	:= (cAliasTMP)->D1_FILIAL
	While (cAliasTMP)->(!EOF())
	
		If MV_PAR03 == 2
			/*If cQuebra <> cAgrup
				cAgrup 	:= (cAliasTMP)->D1_FILIAL
	
				oSec3:Init()
				oSec3:Cell(	"cEmp"				):SetValue("Filial: "+FWEmpName(cAgrup))
				oSec3:PrintLine()
				oSec3:Finish()	
			EndIF*/
		EndIf


		If cAgrupFil <> cQuebraFil
			cAgrupFil := (cAliasTMP)->F4_XTPOPER

			oSec4:Init()
			If cAgrupFil == "1"
				oSec4:Cell(	"cQuebra"				):SetValue("NF VENDAS")			
			ElseIf cAgrupFil == "2"                                            
				oSec4:Cell(	"cQuebra"				):SetValue("NF BONIFICAÇÃO")
			ElseIf cAgrupFil == "3"
				oSec4:Cell(	"cQuebra"				):SetValue("NF TRANSFERêNCIA")				                      
			ElseIf cAgrupFil == "4"
				oSec4:Cell(	"cQuebra"				):SetValue("NF DEVOLUÇÃO")
			Else
				oSec4:Cell(	"cQuebra"				):SetValue("Quebra")
			EndIf
			oSec4:PrintLine()
			oSec4:Finish()	
		EndIf		
		
		cQuebra := cAgrup
		cQuebraFil := cAgrupFil
		oSec1:Init()

		While (cAliasTMP)->(!EOF()) .And. /*cQuebra == cAgrup  .And.*/ cQuebraFil == cAgrupFil 
		
			oSec1:Cell(	"cNF"			):SetValue((cAliasTMP)->F2_DOC)
			oSec1:Cell(	"cSerie"		):SetValue((cAliasTMP)->F2_SERIE)
                                            
			nValLiq := 0
			            
			If !Empty((cAliasTMP)->FORNECE)
				SF1->(DbSelectArea("SF1"))
				SF1->(DbSetOrder(1))
				IF SF1->(DbSeek((cAliasTMP)->D1_FILIAL+(cAliasTMP)->(F2_DOC+F2_SERIE)+(cAliasTMP)->FORNECE ))
					If MV_PAR12 == 1//Liquido
						nValLiq := SF1->F1_VALMERC
					Else
						nValLiq := SF1->F1_VALBRUT
					EndIf
					oSec1:Cell(	"nValLiq"		):SetValue(nValLiq)
				EndIf                           
			Else
				SF2->(DbSelectArea("SF2"))
				SF2->(DbSetOrder(1))
				IF SF2->(DbSeek((cAliasTMP)->D1_FILIAL+(cAliasTMP)->(F2_DOC+F2_SERIE)))
					If MV_PAR12 == 1//Liquido
						nValLiq := SF2->F2_VALMERC
					Else
						nValLiq := SF2->F2_VALBRUT
					EndIf
					oSec1:Cell(	"nValLiq"		):SetValue(nValLiq)
				EndIf                           
			EndIf				                   
			
			nValFrete := (cAliasTMP)->TOTAL
       
	   		oSec1:Cell(	"nValFrete"			):SetValue(nValFrete)			
	   		oSec1:Cell(	"nPercFrete"		):SetValue((nValFrete/nValLiq)*100)
		
			oSec1:PrintLine()
						
					
			If nValFrete == 0  .and. MV_PAR13 == 2 //considera o valor de notas sem frete no total geral
			
				nValLiqTot += nValLiq
				nFilLiqTot += nValLiq
		   	Elseif nValFrete == 0  .and. MV_PAR13 == 1 
		   		
		   		nValLiqTot += 0
		   		nFilLiqTot += 0
		   	Else                     
		   	
		   		nValLiqTot += nValLiq
		   		nFilLiqTot += nValLiq		   		
		   		
            EndIf
            
            nValFreTot += nValFrete
			
			
			//nFilLiqTot += nValLiq
			nFilFreTot += nValFrete
			
			nValLiq   := 0
			nValFrete := 0

			(cAliasTMP)->(DbSkip())
			
			cAgrup 	  := (cAliasTMP)->D1_FILIAL
			cAgrupFil := (cAliasTMP)->F4_XTPOPER			
		
		EndDO

		If cAgrupFil <> cQuebraFil

			//Imprime Total	
			oSec5:Init()
			If cQuebraFil == "1"
				oSec5:Cell(	"cNF"				):SetValue("TOTAL NF VENDAS")			
			ElseIf cQuebraFil == "2"   
				oSec5:Cell(	"cNF"				):SetValue("TOTAL NF BONIFICAÇÃO")	
			ElseIf cQuebraFil == "3"
				oSec5:Cell(	"cNF"				):SetValue("TOTAL NF TRANSFERêNCIA")		                      	
			ElseIf cQuebraFil == "4"
				oSec5:Cell(	"cNF"				):SetValue("TOTAL NF DEVOLUÇÃO")
			Else
				oSec5:Cell(	"cNF"				):SetValue("Quebra")
			EndIf

			oSec5:Cell(	"nValLiq"			):SetValue(nFilLiqTot)
			oSec5:Cell(	"nValFrete"			):SetValue(nFilFreTot)			
		   	oSec5:Cell(	"nPercFrete"		):SetValue((nFilFreTot/nFilLiqTot)*100)
		   	
	  		nTotFilFrete += nFilFreTot
			nTotFilLiq   += nFilFreTot 
			
			nFilLiqTot := 0 
			nFilFreTot := 0

			oSec5:PrintLine()
			oSec5:Finish()	
		EndIf
	
		If MV_PAR03 == 2
			If cQuebra <> cAgrup		
				//Imprime Total	
				//oSec2:Init()
			    
				//oSec2:Cell(	"cNF"				):SetValue("Total: "+FWEmpName(cQuebra))
				//oSec2:Cell(	"nValLiq"			):SetValue(nValLiqTot)
				//oSec2:Cell(	"nValFrete"			):SetValue(nValFreTot)			
			   	//oSec2:Cell(	"nPercFrete"		):SetValue((nValFreTot/nValLiqTot)*100)
			   	
			   	nTotEmpFrete += 0
				nTotEmpLiq   += 0
				
				//oSec2:PrintLine()
				//oSec2:Finish()	
		
				//nValLiqTot := 0
				//nValFreTot := 0
	
			EndIf
		EndIf
		oSec1:Finish()		

	EndDo	
	If MV_PAR03 == 1
		oSec1:Finish()		
	EndIf
	
	//Imprime Total	
	oSec2:Init()
	oSec2:Cell(	"cNF"				):SetValue("Total Geral")
	oSec2:Cell(	"nValLiq"			):SetValue(nValLiqTot)
	oSec2:Cell(	"nValFrete"			):SetValue(nValFreTot)			
   	oSec2:Cell(	"nPercFrete"		):SetValue((nValFreTot/nValLiqTot)*100)
	oSec2:PrintLine()
	oSec2:Finish()

#ENDIF

RestArea(aArea)

Return

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
Local cPerg := "B4BREL02"

Local aHelpPor01 := {"Considera valor da NF sem conhecimento de frete lancado.","Se 'sim' o valor será somado ao Total Geral"}

PutSx1(cPerg	,"01"   ,"Dt.Faturamento De?	    ","" ,"" ,"mv_ch1"	,"D"   	,01      	,0       	,0      		, "G"		,"" 						,""  		,""      ,""   	,"mv_par01"	,""     		,""     ,""     ,""    	,""        		      ,""     		,""      ,""    				,""     ,""    	,""    							,""      ,""     ,""    		,""      	,""      ,""      ,""      ,""      ,"")
PutSx1(cPerg	,"02"   ,"Dt.Faturamento Ate?		","" ,"" ,"mv_ch2"	,"D"   	,01      	,0       	,0      		, "G"		,""    						,""  		,""      ,""   	,"mv_par02"	,""	 			,""     ,""     ,""    	,""	      		      ,""     		,""      ,""    				,""     ,""    	,""    							,""      ,""     ,""    		,""      	,""      ,""      ,""      ,""      ,"")
PutSx1(cPerg	,"03"   ,"Consolida filiais?	    ","" ,"" ,"mv_ch3"	,"C"   	,01      	,0       	,0      		, "C"		,""  						,""   		,""      ,""   	,"mv_par03"	,"Nao"			,"" 	,""		,""		,"Sim"			      ,""     		,""      ,""   			   		,""		,""    	,""    							,""      ,"" 	 ,""    		,""      	,""      ,""      ,""      ,""      ,"")
PutSx1(cPerg	,"04"   ,"Filtro por?				","" ,"" ,"mv_ch4"	,"C"   	,01      	,0       	,0      		, "C"		,""  					    ,""   	 	,""      ,""   	,"mv_par04"	,"Venda"		,"" 	,""		,""		,"Bonificacao"	      ,""     		,""      ,"Transferencia"	  	,""		,""    	,"Devolucao"   					,""      ,""     ,"Todos"       ,""      	,""      ,""      ,""      ,""      ,"")
PutSx1(cPerg	,"05"   ,"Estados?					","" ,"" ,"mv_ch5"	,"C"   	,01      	,0       	,0      		, "C"		,"U_GetEstado(MV_PAR05)"  	,""    		,""      ,""   	,"mv_par05"	,"-Escolher-"	,"" 	,""		,""		,"Estados"		      ,""     		,""      ,""			   		,""		,""   	,""    							,""      ,"" 	 ,""    		,""      	,""      ,""      ,""      ,""      ,"")
PutSx1(cPerg	,"06"   ,"Transp. De?				","" ,"" ,"mv_ch6"	,"C"   	,06      	,0       	,0      		, "G"		,""  						,"SA4"    	,""      ,""   	,"mv_par06"	,""				,"" 	,""		,""		,""				      ,""     		,""      ,""   			   		,""		,""    	,""    							,""      ,"" 	 ,""    		,""      	,""      ,""      ,""      ,""      ,"")
PutSx1(cPerg	,"07"   ,"Transp. Ate?				","" ,"" ,"mv_ch7"	,"C"   	,06      	,0       	,0      		, "G"		,""  						,"SA4"      ,""      ,""   	,"mv_par07"	,""	   			,"" 	,""		,""		,""	   			      ,""     		,""      ,""			   		,""		,""    	,""    							,""      ,"" 	 ,""    		,""      	,""      ,""      ,""      ,""      ,"")
PutSx1(cPerg	,"08"   ,"Cliente De?				","" ,"" ,"mv_ch8"	,"C"   	,06      	,0       	,0      		, "G"		,""  						,"SA1CLI"   ,""      ,""   	,"mv_par08"	,""				,"" 	,""		,""		,""				      ,""     		,""      ,""					,""		,""    	,""    							,""      ,"" 	 ,""    		,""      	,""      ,""      ,""      ,""      ,"")
PutSx1(cPerg	,"09"   ,"Cliente Ate?				","" ,"" ,"mv_ch9"	,"C"   	,06      	,0       	,0      		, "G"		,""  						,"SA1CLI"   ,""      ,""   	,"mv_par09"	,""				,"" 	,""		,""		,""				      ,""     		,""      ,""   			   		,""		,""    	,""    							,""      ,"" 	 ,""    		,""      	,""      ,""      ,""      ,""      ,"")
PutSx1(cPerg	,"10"   ,"Loja De?  				","" ,"" ,"mv_cha"	,"C"   	,02      	,0       	,0      		, "G"		,""  						,""   		,""      ,""   	,"mv_par10"	,""				,"" 	,""		,""		,""				      ,""     		,""      ,""					,""		,""    	,""    							,""      ,"" 	 ,""    		,""      	,""      ,""      ,""      ,""      ,"")
PutSx1(cPerg	,"11"   ,"Loja Ate?	  			    ","" ,"" ,"mv_chb"	,"C"   	,02      	,0       	,0      		, "G"		,""  						,""   		,""      ,""   	,"mv_par11"	,""				,"" 	,""		,""		,""				      ,""     		,""      ,""   			   		,""		,""    	,""    							,""      ,"" 	 ,""    		,""      	,""      ,""      ,""      ,""      ,"")
PutSx1(cPerg	,"12"   ,"Considera valor?	        ","" ,"" ,"mv_chc"	,"C"   	,01      	,0       	,0      		, "C"		,""  						,""   		,""      ,""   	,"mv_par12"	,"Liquido"		,"" 	,""		,""		,"Bruto"		      ,""     		,""      ,""   			   		,""		,""    	,""    							,""      ,"" 	 ,""    		,""      	,""      ,""      ,""      ,""      ,"")
PutSx1(cPerg	,"13"   ,"Consid. NF s/frete?	    ","" ,"" ,"mv_chd"	,"C"   	,01      	,0       	,0      		, "C"		,""  						,""   		,""      ,""   	,"mv_par13"	,"Nao"		    ,"" 	,""		,""		,"Sim"		          ,""     		,""      ,""   			   		,""		,""    	,""    							,""      ,"" 	 ,""    		,""      	,""      ,""      ,""      ,""      ,"")



Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³GETESTADO³ Autor ³Fabrica 			    ³ Data ³23.09.2013³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Tela generica de acordo com o parametro informado			  ³±±
±±³          ³															  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
User Function GETESTADO(MV_PAR05)

Local oOk        := LoadBitmap( GetResources(), "LBOK")
Local oNo        := LoadBitmap( GetResources(), "LBNO")
Local oBrowse 
Local cTitulo    := ''
Local lTodas     := .F.

cTitulo := 'Estados'
aCampo  := {'','Codigo','Descrição'}
bLine   := {||{If(aBrowse[oBrowse:nAt,01],oOK,oNO),aBrowse[oBrowse:nAt,02], aBrowse[oBrowse:nAt,03]} }    	

aBrowse := QueryParam(MV_PAR05)

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
Static Function QueryParam(cPar)
Local aArea      := GetArea()
Local cAliasTMP  := GetNextAlias()
Local cQuery     := ""
Local cAlias     := ""
Local aRet       := {}

If MV_PAR05 == 1
	Alert("Favor escolher uma opção de filtro!")
	Return
EndIf

cQuery := "SELECT"+CRLF
cQuery += "X5_CHAVE, X5_DESCRI"+CRLF
cQuery += "FROM "+RetSqlName('SX5')+CRLF
cQuery += "WHERE"+CRLF 
cQuery += "X5_TABELA = '12' AND"+CRLF
cQuery += "X5_CHAVE <> 'EX' AND"+CRLF

cQuery += "D_E_L_E_T_ <> '*' "+CRLF
cQuery += "ORDER BY X5_CHAVE, X5_DESCRI"+CRLF

IF SELECT(cAliasTMP) > 0
	(cAliasTMP)->(DBCLOSEAREA())
ENDIF

cQuery := ChangeQuery(cQuery) 

TcQuery cQuery New Alias (cAliasTMP)
	
While (cAliasTMP)->(!EOF())

	AADD(aRet,  {	.F.,;
					(cAliasTMP)->X5_CHAVE,;				//01 - Codigo
					(cAliasTMP)->X5_DESCRI})			//02 --Descricao

	(cAliasTMP)->(DbSkip())
EndDo  

RestArea(aArea)

Return aRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³RetTrb    ºAutor  ³Microsiga           º Data ³  10/28/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Cria tabela temporaria                                     º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ B4B                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function RetTrb() 

_aStru	:= {}

AADD(_aStru,{"D1_FILIAL"     ,"C",02,0})
AADD(_aStru,{"F4_XTPOPER"    ,"C",01,0})
AADD(_aStru,{"F2_DOC"        ,"C",09,0})
AADD(_aStru,{"F2_SERIE"      ,"C",03,0})
AADD(_aStru,{"TOTAL"     ,"N",14,2})
AADD(_aStru,{"FORNECE"    ,"C",8,0})

_cArq     := CriaTrab(_aStru,.T.)
_cIndice  := CriaTrab(Nil,.F.)

If Sele("TRB") <> 0
	TRB->(DbCloseArea())
Endif

dbUseArea(.T.,,_cArq,cAliasTMP,.F.,.F.)

IndRegua(cAliasTMP,_cIndice,"F4_XTPOPER+D1_FILIAL+F2_DOC+F2_SERIE",,,"Selecionando Registros...")

//Filtra notas fiscais
cQuery := "SELECT D2_FILIAL, F4_XTPOPER, D2_DOC, D2_SERIE "+CRLF
cQuery += "FROM "+RetSqlName('SD2')+" SD2"+CRLF

cQuery += "INNER JOIN "+RetSqlName('SF4')+" SF4"+CRLF
cQuery += "ON SF4.F4_CODIGO = SD2.D2_TES"+CRLF
cQuery += "AND SF4.F4_MSBLQL <> '1'"+CRLF		

If MV_PAR04 <> 5
	cQuery += "AND SF4.F4_XTPOPER ='"+cValToChar(MV_PAR04)+"' "+CRLF
Else
	cQuery += "AND SF4.F4_XTPOPER IN ('1','2','3') "+CRLF	
EndIf

cQuery += "INNER JOIN "+RetSqlName('SA1')+" SA1"+CRLF
cQuery += "ON SA1.A1_COD = SD2.D2_CLIENTE"+CRLF
cQuery += "AND SA1.A1_LOJA = SD2.D2_LOJA"+CRLF
If !Empty(cString)
	cQuery += "AND SA1.A1_EST IN ("+cString+")"+CRLF
EndIf	
cQuery += "AND SA1.A1_FILIAL ='"+xFilial("SA1")+"'"+CRLF
cQuery += "AND SA1.D_E_L_E_T_ <> '*'"+CRLF   

cQuery += "WHERE SD2.D2_EMISSAO BETWEEN '"+DTOS(MV_PAR01)+"' AND '"+DTOS(MV_PAR02)+"'"+CRLF
cQuery += "AND SD2.D_E_L_E_T_ <> '*'"+CRLF
cQuery += "AND D2_CLIENTE BETWEEN '"+MV_PAR08+"' AND '"+MV_PAR09+"' "+CRLF
cQuery += "AND D2_LOJA BETWEEN '"+MV_PAR10+"' AND '"+MV_PAR11+"'"+CRLF

If MV_PAR03 == 1//Nao
	cQuery += "AND SD2.D2_FILIAL ='"+xFilial("SD2")+"'"+CRLF	
EndIf

cQuery += "GROUP BY D2_FILIAL, F4_XTPOPER, D2_DOC, D2_SERIE"+CRLF
cQuery += "ORDER BY D2_FILIAL, F4_XTPOPER"+CRLF


IF SELECT("TRA") > 0
	TRA->(DBCLOSEAREA())
ENDIF

cQuery := ChangeQuery(cQuery) 

// Claudino - 30/10/13
If Select("TSQL") > 0
	DbSelectArea("TSQL")
	TSQL->(DbCloseArea())
EndIf

DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),"TSQL",.F.,.T. )

//Alimenta tabela temporaria
dbSelectArea("TSQL")
TSQL->(dbGotop())
                 
ProcRegua(0)

While TSQL->(!Eof())

	IncProc("Filtrando registros, aguarde...")      
	

	dbSelectArea("SF2")
	dbSetOrder(1)
	If MsSeek(TSQL->D2_FILIAL+TSQL->D2_DOC+TSQL->D2_SERIE)	
		 
		If SF2->F2_TRANSP >= MV_PAR06 .And. SF2->F2_TRANSP <= MV_PAR07
		                           
		 	nVlFrete := RetDevol(TSQL->D2_DOC, TSQL->D2_SERIE, TSQL->D2_FILIAL)
		 	           
		 	//If nVlFrete >  0 //considara apenas nota com frete 
				dbSelectArea(cAliasTMP)
				(cAliasTMP)->(RecLock(cAliasTMP,.T.))
				(cAliasTMP)->D1_FILIAL   := TSQL->D2_FILIAL
				(cAliasTMP)->F4_XTPOPER  := TSQL->F4_XTPOPER
				(cAliasTMP)->F2_DOC  	  := TSQL->D2_DOC
				(cAliasTMP)->F2_SERIE    := TSQL->D2_SERIE
				(cAliasTMP)->TOTAL       := nVlFrete
				(cAliasTMP)->(MsUnLock())
			//EndIf				
				
		EndIf			
	
	EndIf
	     
	TSQL->(dbSkip())
EndDo


//Calcula devolucao 
If MV_PAR04 == 4 .Or. MV_PAR04 == 5

	cQuery := " SELECT F8_FILIAL, F4_XTPOPER,  F8_NFORIG, F8_SERORIG, SUM(SD1.D1_TOTAL) AS TOTAL, F8_FORNECE+F8_LOJA as FORNECE "
	cQuery += " FROM "+RetSqlName("SF8")+" SF8 "
	cQuery += " LEFT JOIN "+RetSqlName("SF1")+" SF1 ON (F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA =
	cQuery += " 	                                              F8_FILIAL+F8_NFORIG+F8_SERORIG+F8_FORNECE+F8_LOJA )	
	cQuery += " LEFT JOIN "+RetSqlName("SD1")+" SD1 ON (SD1.D1_FILIAL+SD1.D1_DOC+SD1.D1_SERIE+SD1.D1_FORNECE+SD1.D1_LOJA =
	cQuery += " 	                                              F8_FILIAL+F8_NFDIFRE+F8_SEDIFRE+F8_TRANSP+F8_LOJTRAN )
	cQuery += " LEFT JOIN "+RetSqlName("SD1")+" D1A ON (D1A.D1_FILIAL+D1A.D1_DOC+D1A.D1_SERIE+D1A.D1_FORNECE+D1A.D1_LOJA+D1A.D1_COD+D1A.D1_ITEM =
	cQuery += " 	                                              F8_FILIAL+F8_NFORIG+F8_SERORIG+F8_FORNECE+F8_LOJA+SD1.D1_COD+SD1.D1_ITEM )	
	cQuery += " LEFT JOIN "+RetSqlName("SF4")+" SF4 ON (SD1.D1_TES = F4_CODIGO AND SF4.D_E_L_E_T_ = '') "
	cQuery += " WHERE F8_FORNECE BETWEEN '"+MV_PAR08+"' AND '"+MV_PAR09+"' "+CRLF
	cQuery += " AND F8_LOJA BETWEEN '"+MV_PAR10+"' AND '"+MV_PAR11+"'"+CRLF		
	cQuery += " AND F8_DTDIGIT BETWEEN '"+DTOS(MV_PAR01)+"' AND '"+DTOS(MV_PAR02)+"'"+CRLF			
	cQuery += " AND F4_XTPOPER = '4' "
	cQuery += " AND F1_TIPO = 'D' "	
	cQuery += " AND SF1.D_E_L_E_T_ = '' "	
	cQuery += " AND SD1.D_E_L_E_T_ = '' "	
	cQuery += " AND D1A.D_E_L_E_T_ = '' "			
	
	If MV_PAR03 == 1//Nao
		cQuery += "AND F8_FILIAL ='"+xFilial("SD2")+"'"+CRLF	
	EndIf
	cQuery += " GROUP BY F8_FILIAL, F4_XTPOPER,  F8_NFORIG, F8_SERORIG,F8_FORNECE,F8_LOJA "
	
	If Select("DEVOL") > 0
		DEVOL->(dbCloseArea())
	EndIf
			
	cQuery := ChangeQuery(cQuery) 
	DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),"DEVOL",.F.,.T. )
	
	dbSelectArea("DEVOL")
	DEVOL->(dbGotop())            
	
	While DEVOL->(!Eof())  
	
		dbSelectArea(cAliasTMP)
		(cAliasTMP)->(RecLock(cAliasTMP,.T.))
		(cAliasTMP)->D1_FILIAL  := DEVOL->F8_FILIAL
		(cAliasTMP)->F4_XTPOPER := DEVOL->F4_XTPOPER
		(cAliasTMP)->F2_DOC  	 := DEVOL->F8_NFORIG
		(cAliasTMP)->F2_SERIE   := DEVOL->F8_SERORIG
		(cAliasTMP)->TOTAL    	 := DEVOL->TOTAL
		(cAliasTMP)->FORNECE     := DEVOL->FORNECE
		(cAliasTMP)->(MsUnLock())
				
		DEVOL->(dbSkip())  	
	EndDo
	
EndIf	

Return


Static Function RetDevol(cNota,cSerie,_cFilial)

Local cQuery := ""
Local nDevol := 0

dbSelectArea("SD1")
dbOrderNickName("NFORI")

If SD1->(MsSeek(_cFilial+cNota+cSerie))
	
	While SD1->(!Eof()) .And. SD1->(D1_FILIAL+D1_NFORI+D1_SERIORI) == _cFilial+cNota+cSerie
        
		If Alltrim(GetAdvFVal("SF1","F1_ESPECIE",SD1->(D1_FILIAL+D1_DOC+D1_SERIE),1,"")) $ "CTR.CTE" // Claudino 30/10/13 - Somente CTR e CTE.
		
			If Alltrim(SD1->D1_COD) $ "REDESPACHO/DEVOLUCAO/FRETE"
				nDevol += SD1->D1_TOTAL
			EndIf
		
		EndIf
		
		SD1->(dbSkip())
	EndDo
				
EndIf
                    
Return nDevol