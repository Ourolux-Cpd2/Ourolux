#INCLUDE "rwmake.ch"
#INCLUDE "font.ch"

// RELATORIO DE VENDAS ANALITICO, SINTETICO, ESTADO : AUTOR: FELIPE 01/07/2006

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

User Function FATVEN
Private oFont07,oFont09, oFont10, oFont10n, oFont11,oFont15, oFont16,oFont18
Private oPrint
Private cTitulo := " " 
Private cCodusr
Private aTmp := {} // array temporaria para ranking
Private cVnd := ''
Private nlastline := 3000 //define qtd linhas max. folha
Private cCod := ''
Private nRed := ''
Private ntotven := 0
Private ntotger := 0
Private cDet := ''
Private nLin := 0
Private cabec := ''
PRIVATE i := 1
Private cPerg := PadR("FATVEN",10)
Private ultven := ''
Private cEstado := ''

if !Pergunte(cPerg,.T.) // ARQUIVO DE PERGUNTAS FEITOS PARA O RELATORIO
	return
endif
/* MV_PAR01 = DE DATA
	MV_PAR02 = ATE DATA
	MV_PAR03 = DO VENDEDOR
	MV_PAR04 = ATE VENDEDOR
	MV_PAR05 = DO CLIENTE
	MV_PAR06 = ATE CLIENTE
	MV_PAR07 = TIPO RELATORIO: 1 - ANALITICO, 2 - SINTETICO,  3 - POR ESTADO
	MV_PAR08 = TES QTD FATUR.: 1- GERA FINAN, 2- NAO GERA, 3 - CONSIDERA AMBAS
	MV_PAR09 = TES QTD ESTOQ.: 1 - MOVIMENTA, 2 - NAO MOVIMENTA, 3 - CONSIDERA AMBAS 
*/ 
// AJUSTA AS FONTES EM FORMATO WINDOWS USANDO OBJETOS
SA3->( dbSetOrder( 1 ) )
oFont07  := TFont():New("Courier New",10,10,,.T.,,,,,,.T.,.T.)
oFont08  := TFont():New("Courier New",10,10,,.F.,,,,.T.,.F.)
oFont10  := TFont():New("Tahoma",09,09,,.F.,,,,.T.,.F.)
oFont10n := TFont():New("Tahoma",10,10,,.T.,,,,.T.,.F.)
oFont10i := TFont():New("Tahoma",10,10,.T.,.F.,,,,.F.,.T.)		//Normal s/negrito
oFont12  := TFont():New("Tahoma",,12,,.T.,,,,,,)
oFont15  := TFont():New("Tahoma",09,09,,.T.,,,,.T.,.F.)
oFont16  := TFont():New("Tahoma",16,16,,.F.,,,,.T.,.F.)
oFont18  := TFont():New("Tahoma",18,18,,.F.,,,,.T.,.T.)

U_Listavnd(@cCod) //felipe 06-07-06
cCod := STRTRAN(cCod,'/',',',,)
cCodusr := RetCodUsr()

// QUERY USADA PARA SELECIONAR AS NOTAS DO SD2
cSql := ' SELECT SD2010.D2_DOC AS DOC, SD2010.D2_SERIE AS SERIE, SD2010.D2_TES AS TES, '
cSql += "SUBSTRING(SD2010.D2_EMISSAO, 7, 2) + '/' + SUBSTRING(SD2010.D2_EMISSAO, 5, 2) + '/' + SUBSTRING(SD2010.D2_EMISSAO, 1, 4) AS EMISSAO, " 
cSql += "SD2010.D2_CLIENTE AS CLIENTE, " 
cSql += "SD2010.D2_LOJA AS LOJA, SA1010.A1_NREDUZ AS CLINREDUZ, SA1010.A1_EST, SA1010.A1_ATIVIDA, " 
cSql += "SUM(SD2010.D2_TOTAL) AS VALMERC ,SA3010.A3_COD AS VEND,SA3010.A3_NREDUZ AS VENDNREDUZ, SF2010.F2_VEND1 "
cSql += "FROM  SD2010 INNER JOIN SF2010 ON SD2010.D2_DOC = SF2010.F2_DOC AND SF2010.F2_SERIE = SD2010.D2_SERIE "
cSql += "INNER JOIN SA1010 ON SD2010.D2_CLIENTE = SA1010.A1_COD AND SD2010.D2_LOJA = SA1010.A1_LOJA "
cSql += "INNER JOIN SA3010 ON SA3010.A3_COD = SF2010.F2_VEND1 "  
cSql += "WHERE SD2010.D2_EMISSAO BETWEEN '" + DtoS( MV_PAR01 ) + "' AND '" + DtoS( MV_PAR02 ) + "'
if (cCodusr $ '000000' .OR. cNivel >= 7) //felipe 10-07-06  
	cSql += "AND SF2010.F2_VEND1 BETWEEN '" + MV_PAR03 + "' AND '" + MV_PAR04 + "'
elseif !(MV_PAR03 $ cCod .OR. MV_PAR04 $ cCod)
	MSGBOX("Os vendedores informados nao possuem voce como supervisor")
	return(nil)
	//cSql += "AND SF2010.F2_VEND1 IN (" + cCod + ") "
else
   //	cSql +="AND SF2010.F2_VEND1 BETWEEN '" + MV_PAR03 + "' AND '" + MV_PAR04 + "'   
	cSql += "AND SF2010.F2_VEND1 IN (" + cCod + ") "
end
cSql += "AND SD2010.D2_CLIENTE BETWEEN '" + MV_PAR05 + "' AND '" + MV_PAR06 + "'
cSql += "AND (SD2010.D_E_L_E_T_ <> '*') AND (SF2010.D_E_L_E_T_ <> '*') "
cSql += "AND (SA1010.D_E_L_E_T_ <> '*') AND (SA3010.D_E_L_E_T_ <> '*') "
cSql += "AND (SD2010.D2_SERIE IN ( '1  ','EPP','900')) "
cSql += "AND (SD2010.D2_TIPO = 'N') "
//cSql += "AND (D2_TES IN ('501','900')) "
cSql += "GROUP BY SD2010.D2_DOC, SD2010.D2_SERIE,SD2010.D2_EMISSAO,SD2010.D2_CLIENTE,SD2010.D2_LOJA,SA1010.A1_ATIVIDA, "
cSql += "SA1010.A1_EST, SA1010.A1_NREDUZ, SA3010.A3_COD,SA3010.A3_NREDUZ, SF2010.F2_VEND1,SD2010.D2_TES "
if MV_PAR07=3 
	cSql += "ORDER BY SA1010.A1_EST,SA3010.A3_COD, SD2010.D2_CLIENTE,SD2010.D2_LOJA,EMISSAO,SA1010.A1_ATIVIDA "  
else
	cSql += "ORDER BY SA3010.A3_COD, SD2010.D2_CLIENTE,SD2010.D2_LOJA,EMISSAO,SA1010.A1_ATIVIDA,SA1010.A1_EST "  
end
dbUseArea( .T., "TOPCONN", TCGENQRY(,,cSql), 'Qry' ) //SALVAR A QRY DENTRO DA VARIAVEL cSql 

Private cEstoq := if((MV_PAR09 == 1),"S",if((MV_PAR09 == 2),"N","SN"))
Private cDupli := if((MV_PAR08 == 1),"S",if((MV_PAR08 == 2),"N","SN"))

cVnd := QRY->F2_VEND1
SA3->( dbSeek( xFilial("SA3") + QRY->F2_VEND1, .F. ) )
nRed := SA3->A3_NREDUZ
oPrint := TMSPrinter():New("Vendas")
cEstado := QRY->A1_EST
	  
Set Cent On 

While !( QRY->( Eof() ) )// ENQUANTO NAO É FIM DE ARQUIVO CHAMA FUNÇOES DE ACORDO COM MV_PAR07

  If MV_PAR07 = 1 // analitico
  	RptAnaVend()
  else //relatorio generico sint/estado
  	RptGenVend()
  End   
   
QRY->( dbSkip() ) 
End
Set Cent Off
QRY->( dbCloseArea() )

if MV_PAR07 = 1
	impvendanal()
else// MV_PAR07 = 2
	impvengen()
end
RptStatus({|| (imprimir()) } )

Return( NIL )     


//////////////////////////////////////IMPRESSAO/////////////////////////////////////////////////////////
STATIC FUNCTION imprimir()

if !oPrint:Preview()
	return
endif        // Visualiza impressao grafica antes de imprimir
oPrint:Print()
If !oPrint:Setup() .or. !oPrint:IsPrinterActive()
     return
Endif
oPrint:StartPage()		// Inicia uma nova pagina
oPrint:SetPortrait()    //Define que a impressao deve ser RETRATO//

Return (NIL)
////////////////////////FUNÇOES////////////////////////////////////////////
Static Function RptAnaVend(cpar1,cpar2,cpar3,cpar4,cpar5)
if (nLin == 0)
	cTitulo := "RELATORIO FATURAMENTO ANALITICO DOS VENDEDORES                               pag." +alltrim(str(i))
	cabec :=' CODIGO/VENDEDOR         NUMERO SER   CLIENTE    NOME                 EMISSAO    UF  ATIV.         VALOR'
	cabec()
	detalhesanalit()
elseif (nLin >= nlastline) 
	newpage()
else
	detalhesanalit()
end
return(nil) 

Static Function RptGenVend()
if (nLin == 0)
	if MV_PAR07 = 2
	cTitulo := "RELATORIO FATURAMENTO SINTETICO DOS VENDEDORES                               pag." +alltrim(str(i))
	cabec :='CODIGO          NOME                          VALOR DAS VENDAS          RANKING'
	else
	cTitulo := "RELATORIO FATURAMENTO TOTAL POR ESTADO                                         pag." +alltrim(str(i))
	cabec :='ESTADO          TOTAL VENDAS                         RANKING'
	end
	cabec()
	detalhesgen()
else
	detalhesgen()
end
return(nil)

static function cabec()
oPrint:Line(80,030,80,2300) // DESENHA A LINHA
oPrint:say(110,500,cTitulo,oFont12) // ESCREVE O TITULO
oPrint:Line(160,030,160,2300) // DESENHA A LINHA
oPrint:say(190,040,cabec,oFont07) // ESCREVE O cabec
nLin := 230
return (nil)

static function detalhesanalit()
If (QRY->F2_VEND1 == cVnd)
	cDet := QRY->F2_VEND1+'/'+nRed
	cDet += Space( 3 )
	cDet += QRY->DOC 
	cDet += ' '
	cDet += QRY->SERIE
	cDet += Space( 3 )
	cDet += QRY->CLIENTE
	cDet += '/'
	cDet += QRY->LOJA
	cDet += '  '
	cDet += QRY->CLINREDUZ
	cDet += ' '
	cDet += QRY->Emissao
	cDet += ' '
	cDet += QRY->A1_EST
	cDet += '  '
	cDet += QRY->A1_ATIVIDA
	cDet += ' '
	cDet += Transform( QRY->ValMerc, "@E 999,999,999.99" )  
	if AvalTes(QRY->TES,cEstoq,cDupli)
	endif
	ntotven += QRY->ValMerc
	oPrint:Say(nLin,040,cDet,oFont08 )
	nLin += 35
Else
	cDet := Space( 50 )
	cDet += 'TOTAL VENDEDOR(A) '
	cDet += cVnd+'/'+nRed
	cDet += Space( 1 )
	cDet += Transform( ntotven, "@E 999,999,999.99" )        
	ntotger += ntotven
	ntotven := 0
	oPrint:Say(nLin,040,cDet,oFont07 )
	cVnd := QRY->F2_VEND1
	SA3->( dbSeek( xFilial("SA3") + QRY->F2_VEND1, .F. ) )
	nRed := SA3->A3_NREDUZ
	nLin += 90
end
return(nil)

static function newpage()
i++
oPrint:EndPage()
nLin := 0
return(nil)  

static function detalhesgen()
if MV_PAR07 == 2 //sintetico
	If (QRY->F2_VEND1 == cVnd)
 		ntotven := ntotven + QRY->ValMerc
		if AvalTes(QRY->TES,cEstoq,cDupli)
		endif
	Else				
		if( QRY->( Eof() ) )
			return (nil)
		end
		ntotger := ntotven + ntotger
		AADD(aTmp,{ cVnd, nRed, Transform( ntotven, "@E 999,999,999.99" )} )
		SA3->( dbSeek( xFilial("SA3") + QRY->F2_VEND1, .F. ) )
		ntotven := 0
		nRed := SA3->A3_NREDUZ
		cVnd := QRY->F2_VEND1
	end
else //estado
    If (QRY->A1_EST == cEstado)
 		ntotven := ntotven + QRY->ValMerc
 		if AvalTes(QRY->TES,cEstoq,cDupli)
		endif   	   
	Else				
		if( QRY->( Eof() ) )
			return (nil)
		end
		ntotger := ntotven + ntotger
		AADD(aTmp,{ cEstado, Transform( ntotven, "@E 999,999,999.99" )} )
		SA1->( dbSeek( xFilial("SA1") + QRY->A1_EST, .F. ) )
		cEstado := QRY->A1_EST
		ntotven := 0
	end
end
Return( NIL )

static function impvendanal()
cDet := Space( 50 )
cDet += 'TOTAL VENDEDOR(A) '
cDet += cVnd+'/'+nRed
cDet += Space( 1 )
cDet += Transform(ntotven, "@E 999,999,999.99" )        
ntotger += ntotven
ntotven := 0
oPrint:Say(nLin,040,cDet,oFont07 )
oPrint:say(nLin+50,1510,"TOTAL GERAL: "+Transform(ntotger, "@E 999,999,999.99" )+"",oFont07)
return(nil)

static function impvengen()
Local k := 0
if MV_PAR07 = 2
	AADD(aTmp,{cVnd, nRed, Transform( ntotven, "@E 999,999,999.99" )} )
	aTmp := aSORT( aTmp,,,{|X,Y| X[3] > Y[3] } )
	ntotger := ntotven + ntotger
	ntotven := 0
	FOR k := 1 TO LEN(aTmp)
   		cDet := aTmp[k,1] //codigo vendedor
		cDet += Space ( 10 )
		cDet += aTmp[k,2] // nome reduzido
		cDet += Space( 15 )    
		cDet += aTmp[k,3] // total vendas	
		cDet += Space ( 15 )
		cDet += Alltrim(Str(k))	
		oPrint:Say(nLin,040,cDet,oFont08 )
		nLin += 35
		if (nLin >= nlastline) 
			newpage()
			cabec()
			cDet := cpar1[k,1] //codigo vendedor
			cDet += Space ( 10 )
			cDet += cpar1[k,2] // nome reduzido
			cDet += Space( 15 ) 
			cDet += cpar1[k,3] // total vendas	
			cDet += Space ( 15 )
			cDet += Alltrim(Str(k))	
			oPrint:Say(nLin,040,cDet,oFont08 )
			nLin += 35
		end
	NEXT
oPrint:say(nLin+50,700,"TOTAL GERAL: "+Transform( ntotger, "@E 999,999,999.99" )+"",oFont07)
else
	AADD(aTmp,{cEstado, Transform( ntotven, "@E 999,999,999.99" )} )
	aTmp := aSORT( aTmp,,,{|X,Y| X[2] > Y[2] } )
	ntotger := ntotven + ntotger
	ntotven := 0
	FOR k := 1 TO LEN(aTmp)
   		cDet := aTmp[k,1] //estado
		cDet += Space ( 10 )
		cDet += aTmp[k,2] // total vendas
		cDet += Space( 30 )    
		cDet += Alltrim(Str(k))//ranking	
		oPrint:Say(nLin,040,cDet,oFont08 )
		nLin += 35
		if (nLin >= nlastline) 
			newpage()
			cabec()
			cDet := aTmp[k,1] //estado
			cDet += Space ( 10 )
			cDet += aTmp[k,2] // total vendas
			cDet += Space( 30 ) 
			cDet += Alltrim(Str(k))//ranking	
			oPrint:Say(nLin,040,cDet,oFont08 )
			nLin += 35
		end
	NEXT
oPrint:say(nLin+50,700,"TOTAL GERAL: "+Transform( ntotger, "@E 999,999,999.99" )+"",oFont07)
end	
return(nil)
