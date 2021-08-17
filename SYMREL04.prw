#Include "PROTHEUS.CH"
#Include "TOPCONN.Ch"

User Function SYMREL04()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Prepara ambiente   para schedulle³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ConOut( "Iniciando workflow FATURAMENTO X VENDEDOR X CLIENTE")
//PREPARE ENVIRONMENT EMPRESA "01" FILIAL "01"

//DbSelectArea("SA3")                        

//While SA3->(!Eof())
//	If Empty(A3_UDTSAID)
  //		If !Empty(A3_CODUSR)
			SYMREL03("000000", "wrahal@ourolux.com.br")
//			//SYMREL03("000000", "wrahal@ourolux.com.br")
//		EndIf
//	EndIf
//	SA3->(dbSkip())
//EndDo

MsgInfo("Fim")
Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ SYMREL03 ³ Autor ³ Desenvolvimento B4B   ³ Data ³ 28/01/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ RELATÓRIO DE FATURAMENTO X VENDEDOR X CLIENTE              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ B4B - R4 	                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function SYMREL03(__xcUserId, cEmail)

Local nFator    := 0
Local nAux      := 0

Private aDados  := {}
Private cPerg    := PADR("SYMREL01",10)
Private cGerente := ""
Private cSupervi := ""
Private cFilVen  := ""
Private cVend    := ""
Private cNoVend  := ""
Private cCliente := ""
Private cNomCli  := ""
Private cPerio1  := 0
Private cPerio2  := 0
Private cPerio3  := 0
Private cPerio4  := 0
Private cPerio5  := 0
Private cPerio6  := 0
Private cMedia   := 0
Private aFiltro  := {}         

MV_PAR01 := dDataBase
MV_PAR02 := 1 
MV_PAR03 := 1
MV_PAR04 := ""
MV_PAR05 := ""
MV_PAR06 := ""
MV_PAR07 := ""

aFiltro := CALCDATA()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Filtra dados    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ConOut( "Filtrando dados!!!")
AbrirQuery(__xcUserId)
                               
cVend   := ""          
cGerente:= "" 
cSupervi:= ""

dbSelectArea("SA3")
dbSetOrder(1)

cTable := ' <table width="98%" align="center" height="0" border="1" cellpadding="0" cellspacing="0" bordercolor="#000000"> '	
	
For nElem := 1 To Len(aDados)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³trata nome do vendedor³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Empty(cVend)
		lGerente 	 := .T.
	Else
		If Alltrim(cVend) == Alltrim(aDados[nElem][8])
			lGerente 	 := .F.
		Else
			lGerente 	 := .T.
		EndIf
	EndIf
	
	cGerente := Alltrim(aDados[nElem][11]) +"-"+ GetAdvFval('SA3','A3_NREDUZ',xFilial("SA3")+aDados[nElem][11],1)
	cSupervi := Alltrim(aDados[nElem][12]) +"-"+ GetAdvFval('SA3','A3_NREDUZ',xFilial("SA3")+aDados[nElem][12],1)
	cNoVend  := aDados[nElem][10]
	cVend    := aDados[nElem][8]
	cNomCli  := aDados[nElem][9]
	cCliente := aDados[nElem][7]
	
	nAux	 := 0
	nFator   := 0
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Periodo de faturamento ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cPerio1 := aDados[nElem][1][2]
	cPerio2 := aDados[nElem][2][2]
	cPerio3 := aDados[nElem][3][2]
	cPerio4 := aDados[nElem][4][2]
	cPerio5 := aDados[nElem][5][2]
	cPerio6 := aDados[nElem][6][2]
	
	For nMedia := 1 To 6
		If aDados[nElem][nMedia][2] > 0
			nAux += aDados[nElem][nMedia][2]
			nFator++
		EndIf
	next nMedia
	
	cMedia := Round(nAux/nFator,2)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Alimenta HTML		   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	cTable += ' <tr> '
	If lGerente
		cTable += '		<td class="grid_titulo">'+cGerente+'</td>    '
		cTable += '		<td class="grid_titulo">'+cSupervi+'</td><strong></strong> '
		cTable += '		<td class="grid_titulo">'+cNoVend+'</td><strong></strong> '	
	Else
		cTable += '		<td class="grid_titulo"></td>    '
		cTable += '		<td class="grid_titulo"></td><strong></strong>    '
		cTable += '		<td class="grid_titulo"></td><strong></strong>    '
	EndIf		
	cTable += '		<td class="grid_titulo">'+cCliente +"-"+ cNomCli+'</td><strong></strong> '			
	cTable += '		<td class="grid_titulo">'+Transform(cPerio1,PesqPict("SE1","E1_VALOR"))+'</td><strong></strong> '
	cTable += '		<td class="grid_titulo">'+Transform(cPerio2,PesqPict("SE1","E1_VALOR"))+'</td><strong></strong> '
	cTable += '		<td class="grid_titulo">'+Transform(cPerio3,PesqPict("SE1","E1_VALOR"))+'</td><strong></strong> '
	cTable += '		<td class="grid_titulo">'+Transform(cPerio4,PesqPict("SE1","E1_VALOR"))+'</td><strong></strong> '
	cTable += '		<td class="grid_titulo">'+Transform(cPerio5,PesqPict("SE1","E1_VALOR"))+'</td><strong></strong> '
	cTable += '		<td class="grid_titulo">'+Transform(cPerio6,PesqPict("SE1","E1_VALOR"))+'</td><strong></strong> '					
	cTable += '	</tr> '
	//nTotal += aParcela[nElem][6]
		
	/*cTable += ' <tr> '
	cTable += ' 	<td class="grid_titulo" colspan="2" align="right">Valor Total:&nbsp;</td> '
	cTable += ' 		<td class="grid_titulo" align="right">'+Transform(nTotal,PesqPict("SE1","E1_VALOR"))+'</td> '
	cTable += ' 		</tr> '
	cTable += ' 	</table> '
	cTable += '     </td> '
	cTable += ' </tr> '*/
	
	cTable += ' <br> '
	
Next nElem

cTable += ' </table> '

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Dispara workflow	   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
oProcess := TWFProcess():New("000004","Relatorio de Vendas")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//|Busca o modelo de WF do diretorio workflow |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
oProcess:NewTask("SYMREL04",'\WORKFLOW\SYMREL04.htm')

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//|Inicializa o objeto oHtml para alimentar o seu conteudo|
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
oHtml := oProcess:oHtml
cProcessoWF := oProcess:fProcessID                       	

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//|Preenche as variaveis de acordo com o conteudo 		  |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oHtml:ValByName("cData",DTOC(dDataBase) )
oHtml:ValByName("cItens",cTable)
oHtml:ValByName("cMes1",aFiltro[6][3])
oHtml:ValByName("cMes2",aFiltro[5][3])
oHtml:ValByName("cMes3",aFiltro[4][3])
oHtml:ValByName("cMes4",aFiltro[3][3])
oHtml:ValByName("cMes5",aFiltro[2][3])
oHtml:ValByName("cMes6",aFiltro[1][3])

//ÚÄÄÄÄÄÄÄÄ¿
//|Usuario |
//ÀÄÄÄÄÄÄÄÄÙ								
//oProcess:ClientName(Subs(cUsuario,7,17)) 
oProcess:ClientName(Rtrim(cUserName))
	
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//|Conta de email para envio da aprovacao			|
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oProcess:cTo := cEmail

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿                       
//|Subject do email |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ							
oProcess:cSubject := "Relatório de Vendas -> " + DTOC(dDataBase)
	
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿                       
//|dispara o email	|
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ								
oProcess:Start()      
	
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿                       
//|Libera variaveis da memoria|
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ									
oProcess:Free()

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³AbrirQuery³ Autor ³ Desenvolvimento B4B   ³ Data ³ 28/01/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ RELATÓRIO DE FATURAMENTO X VENDEDOR X CLIENTE              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ B4B - R4 	                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function AbrirQuery(__xcUserId)

Local cQuery   	  := ""
Local cDescMes 	  := ""
Local dIniMes  	  := ""
Local dFimMes  	  := ""
Local nPos     	  := 0
Local nLinha   	  := 0
Local nPosPeriodo := 0
Local cFiltro     := ""
Local aEmpresa    := {cEmpAnt}
Local nQuant      := 0
Local cUserFil    := GetNewPar("MV_XFILUSR","")
Local cFilFilial  := ""

aFiltro  := CALCDATA()
dDataIni := aFiltro[Len(aFiltro)][1]
dDataFim := aFiltro[1][2] 

If MV_PAR02 == 1 //Sim
	
	aAreaSM0 := SM0->(GetArea())
	
	dbSelectArea("SM0")
	SM0->(DbGotop())
	
	While SM0->(!Eof())
		
		If aScan(aEmpresa, SM0->M0_CODIGO ) == 0
			AADD( aEmpresa, SM0->M0_CODIGO )
		EndIf
		
		SM0->(DbSkip())
	EndDo
	
	RestArea(aAreaSM0)
	
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica o nivel de usuario³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cFiltro := NivelUsr(__xcUserId)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Cria filtro no relatório    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cQuery := " SELECT PERIOD,  "
cQuery += "         CLIENTE, "
cQuery += " 		NOME, "
cQuery += "         SUM( VAL_LIQ ) AS VAL_LIQ,  "
cQuery += "         VEND1, "
cQuery += " 		NOM_VEND, "
cQuery += " 		GERENTE, "
cQuery += " 		SUPERVI "
cQuery += " FROM   ( "

For nEmp := 1 To Len(aEmpresa)  
	
	cQuery += " 		SELECT Substring(F2_EMISSAO, 1, 6)             AS PERIOD, "
	cQuery += "                F2_CLIENTE    		                   AS CLIENTE, "
	cQuery += " 			   A1_NOME								   AS NOME, "
	cQuery += "                F2_LOJA                                 AS LOJA, "
	cQuery += "                D2_TOTAL                                AS VAL_LIQ, "
	cQuery += "                F2_VEND1                                AS VEND1, "
	cQuery += "  			   ISNULL(A3_NREDUZ,'')  					   AS NOM_VEND, "
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Gerente 					   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cQuery += "  			   ISNULL( (SELECT A3_COD  "
	cQuery += "  			   			 FROM "+RetSqlName("SA3")+" GER "
	cQuery += "  			   			 WHERE GER.A3_COD = SA3.A3_GEREN ),'')     AS GERENTE, "
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Supervidor 				   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cQuery += "  			   ISNULL( (SELECT A3_COD
	cQuery += "  			   FROM "+RetSqlName("SA3")+" SUP
	cQuery += "  			   WHERE SUP.A3_COD = SA3.A3_SUPER ),'')     AS SUPERVI
	
	/*cQuery += "                Isnull((SELECT SUM(D1_CUSTO) "
	cQuery += "                        FROM   SD1"+aEmpresa[nEmp]+"0 SD1 "
	cQuery += "                               LEFT JOIN "+RetSqlName("SF4")+" DEV "
	cQuery += "                                 ON ( F4_CODIGO = D1_TES " 
	cQuery += "                                      AND SF4.D_E_L_E_T_ <> '*' ) "
	
	cQuery += "                        WHERE  SD1.D_E_L_E_T_ <> '*' "
	cQuery += "                               AND D1_DTDIGIT BETWEEN '"+DTOS(dDataIni)+"' AND '"+DTOS(dDataFim)+"' "
	cQuery += "                               AND D1_NFORI = D2_DOC "
	cQuery += "                               AND D1_SERIORI = D2_SERIE "
	cQuery += "                               AND D1_ITEMORI = D2_ITEM  "
	cQuery += "                               AND D1_FILIAL  = D2_FILIAL "	
	cQuery += "                               AND D1_TIPO = 'D' "
	cQuery += "                               AND F4_DUPLIC = 'S'), 0) AS DEVOL "*/
	cQuery += "         FROM   SF2"+aEmpresa[nEmp]+"0 SF2 "
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Link com as tabelas 		   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cQuery += "                LEFT JOIN SD2"+aEmpresa[nEmp]+"0 SD2 "
	cQuery += "                  ON ( D2_DOC = F2_DOC "
	cQuery += "                       AND D2_SERIE = F2_SERIE "
	cQuery += "                       AND D2_FILIAL = F2_FILIAL "
	cQuery += "                       AND SD2.D_E_L_E_T_ <> '*' ) "
	cQuery += "                LEFT JOIN "+RetSqlName("SF4")+" SF4 "
	cQuery += "                  ON ( F4_CODIGO = D2_TES "
	cQuery += "                       AND SF4.D_E_L_E_T_ <> '*' ) "
	cQuery += "             	LEFT JOIN "+RetSqlName("SA3")+" SA3  "
	cQuery += "                  ON ( A3_COD = F2_VEND1 "
	cQuery += "                       AND SA3.D_E_L_E_T_ <> '*' )  "
	cQuery += "             	LEFT JOIN "+RetSqlName("SA1")+" SA1 "
	cQuery += "                  ON ( A1_COD+A1_LOJA = F2_CLIENTE+F2_LOJA "
	cQuery += "                       AND SA1.D_E_L_E_T_ <> '*' )  "
	
	cQuery += "         WHERE  "
	cQuery += "                SF2.F2_EMISSAO BETWEEN '"+DTOS(dDataIni)+"' AND '"+DTOS(dDataFim)+"' "
	cQuery += "                AND SF2.F2_TIPO = 'N' "
	cQuery += "                AND SF2.D_E_L_E_T_ <> '*' "
	                
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Filtra clientes   		   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !Empty(MV_PAR04)
		If "-" $ Alltrim(MV_PAR04)
			cQuery += " 		   AND F2_CLIENTE BETWEEN '"+Substr(MV_PAR04,1,6)+"' AND '"+Substr(MV_PAR04,8,6)+"' "
		Else
			cQuery += " 		   AND F2_CLIENTE IN " + FormatIn(Alltrim(MV_PAR04),";")
		EndIf
	EndIf
	                                                    
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Se for administrador tudo					   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !__xcUserId $ cUserFil//.And. !UPPER(cUserName) $ UPPER(cUserFil)
		cQuery += " 		   	   AND F2_VEND1 IN " + FormatIn(Alltrim(cFiltro),";")
	EndIf	
	
	If MV_PAR03 == 1 //Sim
		cQuery += "                AND F4_DUPLIC = 'S' "
	ElseIf MV_PAR03 == 2//Nao
		cQuery += "                AND F4_DUPLIC = 'N'  "
	EndIf
	
	If nEmp < Len(aEmpresa)
		cQuery += " UNION ALL "
	EndIf
	
Next nEmp

cQuery += "                ) AS TRB "
cQuery += " GROUP  BY PERIOD, "
cQuery += "  		  CLIENTE, "
cQuery += " 		  NOME, "
cQuery += "  		  VEND1, "
cQuery += " 		  NOM_VEND, "
cQuery += "           GERENTE, "
cQuery += " 		  SUPERVI "
cQuery += "ORDER BY PERIOD, GERENTE, SUPERVI, VEND1, CLIENTE " 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Executa a query para obter os dados                                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Select("TSQL") <> 0
	dbSelectArea("TSQL")
	TSQL->(DbCloseArea())
Endif

DbUseArea( .T., "TOPCONN", TCGenQry( ,,cQuery ), "TSQL", .F., .T. )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria arquivo de trabalho                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aCampos := {}
AADD(aCampos,{ "PERIOD"   ,"C",6,0 } )

aTam:=TamSX3("A1_COD")
AADD(aCampos,{ "CLIENTE"   ,"C",aTam[1],aTam[2] } )

aTam:=TamSX3("A1_NOME")
AADD(aCampos,{ "NOME"   ,"C",aTam[1],aTam[2] } )

aTam:=TamSX3("A3_COD")
AADD(aCampos,{ "VEND1"    ,"C",aTam[1],aTam[2] } )
AADD(aCampos,{ "GERENTE"  ,"C",15,aTam[2] } )
AADD(aCampos,{ "SUPERVI"  ,"C",15,aTam[2] } )

aTam:=TamSX3("A3_NREDUZ")
AADD(aCampos,{ "NOM_VEND" ,"C",aTam[1],aTam[2] } )

aTam:=TamSX3("F2_VALFAT")
AADD(aCampos,{ "VAL_LIQ" ,"N",aTam[1],aTam[2] } )

cNomArq 	:= CriaTrab(aCampos,.T.)
dbUseArea( .T.,, cNomArq,"TRB", .T. , .F. )
cNomArq1 := Subs(cNomArq,1,7)+"A"                                                                                            

IndRegua("TRB",cNomArq1,"PERIOD+CLIENTE",,,"Selecionando Registros...")

dbClearIndex()        
dbSetIndex(cNomArq1+OrdBagExt())

dbSelectArea("TSQL")
TSQL->(dbGotop())
         
While TSQL->(!Eof())

	dbSelectArea("TRB")
	dbSetOrder(1)
	
	TRB->(RecLock("TRB",.T.))
	TRB->PERIOD   := TSQL->PERIOD
	TRB->CLIENTE  := TSQL->CLIENTE
	TRB->NOME     := TSQL->NOME
	TRB->VEND1    := TSQL->VEND1
	TRB->NOM_VEND := TSQL->NOM_VEND
	TRB->GERENTE  := TSQL->GERENTE
	TRB->SUPERVI  := TSQL->SUPERVI
	TRB->VAL_LIQ  := TSQL->VAL_LIQ
	
	TRB->(MsUnLock())

	TSQL->(dbSkip())
EndDo

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ considera devolução				                                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cQuery := " SELECT PERIOD,  "
cQuery += "        FORNECE, "
cQuery += "        FILIAL, "
cQuery += "        NFORI, "
cQuery += "        SERIORI, "
cQuery += "        SUM( VAL_LIQ ) AS VAL_LIQ  "
cQuery += " FROM   ( "

For nEmp := 1 To Len(aEmpresa)  
	
	cQuery += " 		SELECT Substring(D1_DTDIGIT, 1, 6)         AS PERIOD, "
	cQuery += "                D1_FORNECE		   		           AS FORNECE, "
	cQuery += "                D1_TOTAL                            AS VAL_LIQ, "		
	cQuery += "                D1_FILIAL		   		           AS FILIAL, "
	cQuery += "                D1_NFORI			   		           AS NFORI, "
	cQuery += "                D1_SERIORI			   		       AS SERIORI "
	cQuery += "         FROM   SD1"+aEmpresa[nEmp]+"0 SD1 "
	cQuery += "                LEFT JOIN "+RetSqlName("SF4")+" SF4 "
	cQuery += "                  ON ( F4_CODIGO = D1_TES "
	cQuery += "                       AND SF4.D_E_L_E_T_ <> '*' ) "	
	cQuery += "         WHERE  "
	cQuery += "                SD1.D1_DTDIGIT BETWEEN '"+DTOS(dDataIni)+"' AND '"+DTOS(dDataFim)+"' "
	cQuery += "                AND SD1.D1_TIPO = 'D' "
	cQuery += "                AND SD1.D_E_L_E_T_ <> '*' "	                                            	
	//cQuery += "                AND F4_DUPLIC = 'S' "
	                          	
	If nEmp < Len(aEmpresa)
		cQuery += " UNION ALL "
	EndIf
	
Next nEmp

cQuery += "                ) AS TRB "  
cQuery += " GROUP  BY FILIAL, "
cQuery += "			  PERIOD, "        
cQuery += "  		  FORNECE, "
cQuery += "  		  NFORI, "
cQuery += "  		  SERIORI "
cQuery += "ORDER BY PERIOD, FORNECE "

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Executa a query para obter os dados                                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Select("TDEV") <> 0
	dbSelectArea("TDEV")
	TDEV->(DbCloseArea())
Endif

DbUseArea( .T., "TOPCONN", TCGenQry( ,,cQuery ), "TDEV", .F., .T. )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Faz o abatimneto das devoluções		                                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("TDEV")
TDEV->(dbGotop())                                                                           

While TDEV->(!Eof())
		
	dbSelectArea("SF2")
	dbSetOrder(1)
	If MsSeek(TDEV->FILIAL+TDEV->NFORI+TDEV->SERIORI)

		dbSelectArea("SA1")
		dbSetorder(1)
		MsSeek(xFilial("SA1")+SF2->(F2_CLIENTE+F2_LOJA))
	
		dbSelectArea("SA3")
		dbSetorder(1)
		MsSeek(xFilial("SA3")+SF2->F2_VEND1)
					
		TRB->(RecLock("TRB",.T.))
		TRB->PERIOD   := TDEV->PERIOD
		TRB->CLIENTE  := TDEV->FORNECE
		TRB->NOME     := SA1->A1_NOME
		TRB->VEND1    := SA3->A3_COD
		TRB->NOM_VEND := SA3->A3_NOME
		TRB->GERENTE  := SA3->A3_GEREN
		TRB->SUPERVI  := SA3->A3_SUPER
		TRB->VAL_LIQ  := ( TDEV->VAL_LIQ *-1 )
		TRB->(MsUnLock())			
	EndIf
	
	TDEV->(dbSkip())
EndDo

dbSelectArea("TRB")
TRB->(dbGotop())
dbSetOrder(1)

While TRB->(!Eof())     
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Se for administrador tudo					   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If __xcUserId $ cUserFil   //UPPER(cUserName) $ UPPER(cUserFil)
	
		dbSelectArea("SA3")
		dbSetorder(1)
		MsSeek(xFilial("SA3")+TRB->VEND1)
	              
		If !Empty(MV_PAR05) //Filtro por gerente
			If "-" $ Alltrim(MV_PAR05)
				If !(SA3->A3_GEREN  >= Substr(MV_PAR05,1,6) .And.  SA3->A3_GEREN <= Substr(MV_PAR05,8,6))
					TRB->(dbSkip())
					Loop
				EndIf
			Else
				If !Alltrim(SA3->A3_GEREN) $ Alltrim(MV_PAR05)
					TRB->(dbSkip())
					Loop
				EndIf
				
			EndIf
		EndIf	
		
		If !Empty(MV_PAR06) //Filtro por supervidor
			If "-" $ Alltrim(MV_PAR06)
				If !(SA3->A3_SUPER >= Substr(MV_PAR06,1,6) .And.  SA3->A3_SUPER <= Substr(MV_PAR06,8,6))
					TRB->(dbSkip())
					Loop
				EndIf
			Else
				If !Alltrim(SA3->A3_SUPER) $ Alltrim(MV_PAR06)
					TRB->(dbSkip())
					Loop
				EndIf
				
			EndIf
		EndIf	 
								
		If !Empty(MV_PAR07) //Filtro por vendedor
			If "-" $ Alltrim(MV_PAR07)
				If !(TRB->VEND1 >= Substr(MV_PAR07,1,6) .And.  TRB->VEND1 <= Substr(MV_PAR07,8,6))
					TRB->(dbSkip())
					Loop
				EndIf
			Else
				If !Alltrim(TRB->VEND1) $ Alltrim(MV_PAR07)
					TRB->(dbSkip())
					Loop
				EndIf
				
			EndIf
		EndIf
	
	EndIf
		
	nPos := aScan(aDados, { |x| x[8]+x[7] == TRB->(VEND1+CLIENTE) } )
	
	If nPos == 0
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Inicia saldo dos peridos zerados 									 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		AADD( aDados, {	{SUBSTR(DTOS(aFiltro[1][1]),1,6), 0 } ,;
		{ SUBSTR(DTOS(aFiltro[2][1]),1,6), 0 },;
		{ SUBSTR(DTOS(aFiltro[3][1]),1,6), 0 },;
		{ SUBSTR(DTOS(aFiltro[4][1]),1,6), 0 },;
		{ SUBSTR(DTOS(aFiltro[5][1]),1,6), 0 },;
		{ SUBSTR(DTOS(aFiltro[6][1]),1,6), 0 },;
		TRB->CLIENTE,;
		TRB->VEND1,;
		TRB->NOME,;
		TRB->NOM_VEND,;
		TRB->GERENTE,;
		TRB->SUPERVI } )
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica qual periodo da temporaria, para encontrar a posição do array³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nPosPeriodo := 0
		For nElem := 1 To 6
			If SUBSTR(DTOS(aFiltro[nElem][1]),1,6) == TRB->PERIOD
				nPosPeriodo := nElem
				Exit
			EndIf
		Next nElem
		
		If nPosPeriodo > 0
			aDados[Len(aDados)][nPosPeriodo][2] += TRB->VAL_LIQ 			      										
		EndIf
		
	Else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica qual periodo da temporaria, para encontrar a posição do array³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nPosPeriodo := 0
		For nElem := 1 To 6
			If SUBSTR(DTOS(aFiltro[nElem][1]),1,6) == TRB->PERIOD
				nPosPeriodo := nElem
				Exit
			EndIf
		Next nElem
		
		If nPosPeriodo > 0
			aDados[nPos][nPosPeriodo][2] += TRB->VAL_LIQ  								
		EndIf
		
	EndIf
	
	TRB->(dbSkip())
EndDo

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Ordena Matriz    		   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//ASort(aDados,,,{|x,y| x[10]+x[11]+x[8]+x[7] < y[10]+y[11]+y[8]+y[7] })
ASort(aDados,,,{|x,y| x[11]+x[12]+x[8] < y[11]+y[12]+y[8] })

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Exclui tabela temporaria	   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea( "TRB" )
dbCloseArea()
fErase(cNomArq+GetDBExtension())
fErase(cNomArq1+OrdBagExt())

Return
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³CALCDATA  ³ Autor ³ Desenvolvimento B4B   ³ Data ³ 28/01/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ RELATÓRIO DE FATURAMENTO X VENDEDOR X CLIENTE              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ B4B - R4 	                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function CALCDATA()

Local aFiltro  := {}
Local aMeses   := {"JAN","FEV","MAR","ABR","MAI","JUN","JUL","AGO","SET","OUT","NOV","DEZ"}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Calcula dos meses anteriores³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dIniMes := FirstDay(FirstDay(MV_PAR01) )
dFimMes := LastDay(dIniMes)
nCodMes   := Val(Substr(Dtos(dIniMes),5,2))
cDescMes   := aMeses[nCodMes] +"/"+Alltrim(Str(Year(dIniMes)))

AADD( aFiltro, {dIniMes, dFimMes, cDescMes} )

For nElem := 1 To 5
	
	dIniMes   := FirstDay(FirstDay(dIniMes) - nElem )
	dFimMes   := LastDay(dIniMes)
	nCodMes   := Val(Substr(Dtos(dIniMes),5,2))
	cDescMes  := aMeses[nCodMes] +"/"+ Alltrim(Str(Year(dIniMes)))
	
	AADD( aFiltro, {dIniMes, dFimMes, cDescMes} )
	
Next nElem

Return aFiltro
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³NivelUsr  ³ Autor ³ Desenvolvimento B4B   ³ Data ³ 28/01/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Atualiza variaveis private com nivel de usuario            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ B4B - R4 	                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function NivelUsr(__xcUserId)

Local cUsrRel := ""
Local cFiltro := ""
Local cReturn := ""

dbSelectArea("SA3")
dbSetOrder(7)
If MsSeek(xFilial("SA3")+__xcUserId)
	cUsrRel := SA3->A3_COD
EndIf

cFiltro := " SELECT A3_COD FROM "+RetSqlName("SA3")+" WHERE A3_GEREN = '"+cUsrRel+"' AND D_E_L_E_T_ <> '*' "

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Executa a query para obter os dados                                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Select("TFIL") > 0
	TFIL->(dbCloseArea())
EndIf

DbUseArea( .T., "TOPCONN", TCGenQry( ,,cFiltro ), "TFIL", .F., .T. )

If TFIL->(!Eof())

	While TFIL->(!Eof())
		
		If !Empty(MV_PAR06) //Filtro por supervidor
			If "-" $ Alltrim(MV_PAR06)
				If !(TFIL->A3_COD >= Substr(MV_PAR06,1,6) .And.  TFIL->A3_COD <= Substr(MV_PAR06,8,6))
					TFIL->(dbSkip())
					Loop
				EndIf
			Else
				If !Alltrim(TFIL->A3_COD) $ Alltrim(MV_PAR06)
					TFIL->(dbSkip())
					Loop
				EndIf
				
			EndIf
		EndIf
		
		If !Empty(MV_PAR07) //Filtro por vendedor
			If "-" $ Alltrim(MV_PAR07)
				If !(TFIL->A3_COD >= Substr(MV_PAR07,1,6) .And.  TFIL->A3_COD <= Substr(MV_PAR07,8,6))
					TFIL->(dbSkip())
					Loop
				EndIf
			Else
				If !Alltrim(TFIL->A3_COD) $ Alltrim(MV_PAR07)
					TFIL->(dbSkip())
					Loop
				EndIf
				
			EndIf
		EndIf
		
		If Empty(cReturn)
			cReturn := TFIL->A3_COD + ";"
		Else
			cReturn += TFIL->A3_COD + ";"
		EndIf
		
		TFIL->(dbSkip())
	EndDo
Else
	
	cFiltro := " SELECT A3_COD FROM "+RetSqlName("SA3")+" WHERE A3_SUPER = '"+cUsrRel+"' AND D_E_L_E_T_ <> '*' "
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Executa a query para obter os dados                                                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Select("TFIL") > 0
		TFIL->(dbCloseArea())
	EndIf
	
	DbUseArea( .T., "TOPCONN", TCGenQry( ,,cFiltro ), "TFIL", .F., .T. )
	
	If TFIL->(!Eof())

		While TFIL->(!Eof())
			
			If !Empty(MV_PAR07) //Filtro por vendedor
				If "-" $ Alltrim(MV_PAR07)
					If !(TFIL->A3_COD >= Substr(MV_PAR07,1,6) .And.  TFIL->A3_COD <= Substr(MV_PAR07,8,6))
						TFIL->(dbSkip())
						Loop
					EndIf
				Else
					If !Alltrim(TFIL->A3_COD) $ Alltrim(MV_PAR07)
						TFIL->(dbSkip())
						Loop
					EndIf
					
				EndIf
			EndIf
			
			If Empty(cReturn)
				cReturn := TFIL->A3_COD + ";"
			Else
				cReturn += TFIL->A3_COD + ";"
			EndIf
			
			TFIL->(dbSkip())
		EndDo
	Else
		lVendedor := .T.
		cReturn   := SA3->A3_COD //Classificado como vendedor
	EndIf
	
EndIf

Return cReturn