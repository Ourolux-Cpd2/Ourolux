#include "rwmake.ch"
#include "PROTHEUS.ch"
#INCLUDE "REPORT.CH"
#INCLUDE "TOPCONN.CH"


/*/
 ____________________________________________________________________________
|  Programa:            | Autor: Rodrigo Dias Nunes  | Data  02/06/2020      |
|_______________________|____________________________|_______________________|
|  Descricao  | RELATORIO DE CONTATOS X CLIENTES    						 |
|_____________|______________________________________________________________|
|  Parametros | ARRAY[1] - DO CLIENTE                                        |       
|             | ARRAY[2] - ATE CLIENTE                                       |
|             | ARRAY[3] - DA LOJA                                           |
|             | ARRAY[4] - ATE LOJA                                          |
|             | ARRAY[5] - VALIDA ULIMA COMPRA?                              |
|             | ARRAY[6] - DATA ULTIMA COMPRA MAIOR QUE                      |
|             | ARRAY[7] - SAIDA: 1 - RELATORIO / 2 - EXCEL				     |
|_____________|______________________________________________________________|
|  Uso        | OUROLUX.                                                     |
|_____________|______________________________________________________________|
/*/

User Function OUROR019()
Local nOpca	        := 0
Local aSays         := {} 
Local aButtons      := {}
Private cCadastro   := OemToAnsi("Relatorio de Contatos x Clientes")
Private aParam		:= {}
Private cCaminho 	:= ""

AADD (aSays, OemToAnsi(" Este programa tem como objetivo emitir o relatorio "))
AADD (aSays, OemToAnsi(" de contatos por cliente"))
AADD (aSays, OemToAnsi(" "))

AADD(aButtons, { 1,.T.,{|o| nOpca:= 1,o:oWnd:End()}} )
AADD(aButtons, { 2,.T.,{|o| o:oWnd:End() }} )
AADD(aButtons, { 5,.T.,{|| PergPara() } } )
FormBatch( cCadastro, aSays, aButtons )

If nOpcA == 1
	If !Empty(aParam)
		Processa({|lEnd| Gerar()},"Listando relacao de Contatos x Clientes...")
	Else
		PergPara()
		Processa({|lEnd| Gerar()},"Listando relacao de Contatos x Clientes...")
	EndIf
Endif

Return


/*/
 ____________________________________________________________________________
|  Programa:            | Autor: Rodrigo Dias Nunes  | Data  02/06/2020      |
|_______________________|____________________________|_______________________|
|  Descricao  | Cria perguntas para a geracao do relatorio                   |
|_____________|______________________________________________________________|
|  Uso        | OUROLUX.                                                     |
|_____________|______________________________________________________________|
/*/

Static Function PergPara()
Local aRet	 := {}
Local aPergs := {}

aAdd(aPergs, {1, "Cliente De"		,Space(TamSX3("C5_CLIENTE")[1]) ,"@!"  , ".T.", "SA1CLW"		, ".T.", 50, .F.})
aAdd(aPergs, {1, "Cliente Ate"		,"ZZZZZZ" 	             		,"@!"  , ".T.", "SA1CLW"		, ".T.", 50, .T.})
aAdd(aPergs, {1, "Loja De"			,Space(TamSX3("C5_NUM")[1])     ,"@!"  , ".T.", ""		, ".T.", 50, .F.})
aAdd(aPergs, {1, "Loja Ate"			,"ZZ"	     					,"@!"  , ".T.", ""		, ".T.", 50, .T.})

aAdd(aPergs, {2,"Valida Ultima Compra?",2,{"Sim","Nao"},50,"",.T.})

aAdd(aPergs, {1, "Dt.Ult.Compra maior que"	,CTOD("  /  /    ")     ,"@!"  , ".T.", ""		, ".T.", 50, .F.})

aAdd(aPergs, {2, "Tipo de Saida"	,2 , {"Arquivo Texto","Excel"}			, 50, ".T.", .F.})

If ParamBox(aPergs,"Relatorio Contatos x Clientes",@aRet)
	aParam := AjRetParam(aRet,aPergs)
	If aParam[7] == 1
		cCaminho := cGetFile("Arquivos Texto (*.txt) |*.txt|",OemToAnsi("Salvar Como..."),,,.F.,GETF_RETDIRECTORY+GETF_LOCALHARD+GETF_NETWORKDRIVE,.T.)
	EndIf
EndIf

Return

//--------------------------------------------------------------------
/*/{Protheus.doc} AjRetParam
Função de ajuste do conteúdo da ParamBox.

@author Rodrigo Nunes
@since 02/06/2020
/*/
//--------------------------------------------------------------------
Static Function AjRetParam(aRet,aParamBox)
	Local nX		:= 0
	
	If ValType(aRet) == "A" .And. Len(aRet) == Len(aParamBox)
		For nX := 1 to Len(aParamBox)
			If aParamBox[nX][1] == 1
				aRet[nX] := aRet[nX]
			ElseIf aParamBox[nX][1] == 2 .And. ValType(aRet[nX]) == "C"
				aRet[nX] := aScan(aParamBox[nX][4],{|x| AllTrim(x) == aRet[nX]})
			ElseIf aParamBox[nX][1] == 2 .And. ValType(aRet[nX]) == "N"
				aRet[nX] := aRet[nX]
			EndIf
		Next nX
	EndIf
	
Return aRet

//--------------------------------------------------------------------
/*/{Protheus.doc} Gerar
Função para geracao do relatorio

@author Rodrigo Nunes.
@since 03/06/2020
/*/
//--------------------------------------------------------------------
Static Function Gerar()
Local cQuery  := ""
Local aCabec  := {"CONTATO","EMAIL","DDD","RESIDENCIAL","CELULAR","COMERCIAL 1","COMERCIAL 2","COD.CLIENTE","LOJA","RAZAO SOCIAL","CNPJ/CPF","DT.PRIMEIRA COMP.","DT.ULTIMA COMP.","RISCO","LIMITE CREDITO","TABELA PRECO","SEGMENTO","VENDEDOR","NOME VENDEDOR"}
Local aItens  := {}

cQuery := " SELECT 	SU5.U5_CONTAT, "
cquery += " 		SU5.U5_EMAIL, "
cQuery += " 		SU5.U5_DDD, "
cquery += " 		SU5.U5_FONE, "
cquery += " 		SU5.U5_CELULAR, "
cquery += " 		SU5.U5_FCOM1, "
cquery += " 		SU5.U5_FCOM2, "
cquery += " 		SA1.A1_COD, "
cquery += " 		SA1.A1_LOJA, "
cquery += " 		SA1.A1_NOME, "
cquery += " 		SA1.A1_CGC, "
cquery += " 		SA1.A1_PRICOM, "
cquery += " 		SA1.A1_ULTCOM, "
cquery += " 		SA1.A1_RISCO, "
cquery += " 		SA1.A1_LC, "
cquery += " 		SA1.A1_TABELA, "
cquery += " 		SA1.A1_SATIV1, "
cquery += " 		SA1.A1_VEND, "
cquery += " 		SA3.A3_NOME "
cquery += " FROM( "
cquery += " 	SELECT * FROM " + RetSqlName("SA1")
cquery += " 	WHERE A1_COD BETWEEN '"+aParam[1]+"' AND '"+aParam[2]+"' "
cquery += " 	AND A1_LOJA BETWEEN '"+aParam[3]+"' AND '"+aParam[4]+"' "
If aParam[5] == 1
	cQuery += " AND A1_ULTCOM >= '"+DTOS(aParam[6])+"' "
EndIf	
cquery += " 	AND D_E_L_E_T_ <> '*') SA1 "
cquery += " INNER JOIN " +RetSqlName("AC8")+ " AC8 "
cquery += " 	ON AC8.AC8_CODENT = SA1.A1_COD + SA1.A1_LOJA "
cquery += " 	AND AC8.AC8_ENTIDA = 'SA1' "
cquery += " 	AND AC8.D_E_L_E_T_ <> '*' "
cquery += " INNER JOIN " +RetSqlName("SU5")+ " SU5 "
cquery += " 	ON SU5.U5_CODCONT = AC8.AC8_CODCON "
cquery += " 	AND SU5.U5_ATIVO = '1' "
cquery += " 	AND SU5.D_E_L_E_T_ <> '*' "
cquery += " LEFT JOIN " +RetSqlName("SA3")+ " SA3 "
cquery += " 	ON SA3.A3_COD = SA1.A1_VEND "
cquery += " 	AND SA3.D_E_L_E_T_ <> '*' "
cquery += " ORDER BY SA1.A1_COD, SA1.A1_LOJA, SA1.A1_ULTCOM "

IF Select("CTOTMP") > 0
	CTOTMP->(dbCloseArea())
ENDIF

DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery) , 'CTOTMP', .T., .F.)

While CTOTMP->(!EOF())
	AADD(aItens,{Alltrim(CTOTMP->U5_CONTAT),;
				Alltrim(CTOTMP->U5_EMAIL),;
				CTOTMP->U5_DDD,;
				CTOTMP->U5_FONE,;
				CTOTMP->U5_CELULAR,;
				CTOTMP->U5_FCOM1,;
				CTOTMP->U5_FCOM2,;
				CTOTMP->A1_COD,;
				CTOTMP->A1_LOJA,;
				Alltrim(CTOTMP->A1_NOME),;
				If(Len(Alltrim(CTOTMP->A1_CGC)) == 11,Transform(CTOTMP->A1_CGC,"@R 999.999.999-99"),Transform(CTOTMP->A1_CGC,"@R 99.999.999/9999-99")), ;
				DTOC(STOD(CTOTMP->A1_PRICOM)),;
				DTOC(STOD(CTOTMP->A1_ULTCOM)),;
				CTOTMP->A1_RISCO,;
				Transform(CTOTMP->A1_LC,"@E 99,999,999,999.99"),;
				CTOTMP->A1_TABELA,;
				Alltrim(Posicione("SX5",1,xFilial("SX5")+ "T3" + CTOTMP->A1_SATIV1,"X5DESCRI()")),;
				CTOTMP->A1_VEND,;
				Alltrim(CTOTMP->A3_NOME)})

	CTOTMP->(dbSkip())
EndDo

If aParam[7] == 1
	GeraArq(aCabec,aItens)
Else
	If !apoleclient("MSExcel")
		MSGALERT("Nao foi possivel enviar os dados, Microsoft Excel nao instalado!")
		If MSGYESNO("Deseja gerar o mesmo em arquivo de texto delimitado por ; ?")
			cCaminho := cGetFile("Arquivos Texto (*.txt) |*.txt|",OemToAnsi("Salvar Como..."),,,.F.,GETF_RETDIRECTORY+GETF_LOCALHARD+GETF_NETWORKDRIVE,.T.)
			GeraArq(aCabec,aItens)
		EndIf
	Else
		dlgtoexcel({{"ARRAY","",aCabec,aItens}})
	Endif
EndIf

Return

//--------------------------------------------------------------------
/*/{Protheus.doc} GeraArq
Função para geracao do arquivo TXT delimitado por ;

@author Rodrigo Nunes
@since 03/06/2020
/*/
//--------------------------------------------------------------------
Static Function GeraArq(aCabec,aItens)
Local cFile 	:= cCaminho + "OUROR019_" + SubStr(DTOS(dDatabase),7,2) + "_" + SubStr(DTOS(dDatabase),5,2) + "_" + SubStr(DTOS(dDatabase),1,4) + "_" + StrTran(Time(),":","") + ".txt"
Local nH 		:= fCreate(cFile)
Local nlX 		:= 0

If nH == -1 
	MsgStop("Falha ao criar arquivo - erro "+str(ferror())) 
	Return 
Endif 

fWrite(nH,	aCabec[1] + "|" +;
			aCabec[2] + "|" +;
			aCabec[3] + "|" +;
			aCabec[4] + "|" +;
			aCabec[5] + "|" +;
			aCabec[6] + "|" +;
			aCabec[7] + "|" +;
			aCabec[8] + "|" +;
			aCabec[9] + "|" +;
			aCabec[10] + "|" +;
			aCabec[11] + "|" +;
			aCabec[12] + "|" +;
			aCabec[13] + "|" +;
			aCabec[14] + "|" +;
			aCabec[15] + "|" +;
			aCabec[16] + "|" +;
			aCabec[17] + "|" +;
			aCabec[18] + "|" +;
			aCabec[19] +;
			chr(13)+chr(10) ) 

For nlx := 1 to Len(aItens)
	fWrite(nH,	aItens[nlX][1] + "|" +; 
				aItens[nlX][2] + "|" +; 
				aItens[nlX][3] + "|" +; 
				aItens[nlX][4] + "|" +;
				aItens[nlX][5] + "|" +;
				aItens[nlX][6] + "|" +;
				aItens[nlX][7] + "|" +;
				aItens[nlX][8] + "|" +; 
				aItens[nlX][9] + "|" +;
				aItens[nlX][10] + "|" +;
				aItens[nlX][11] + "|" +;
				aItens[nlX][12] + "|" +;
				aItens[nlX][13] + "|" +;
				aItens[nlX][14] + "|" +;
				aItens[nlX][15] + "|" +;
				aItens[nlX][16] + "|" +;
				aItens[nlX][17] + "|" +;
				aItens[nlX][18] + "|" +;
				aItens[nlX][19] + "|" +;
				chr(13)+chr(10) ) 
Next

fClose(nH) 

MSGALERT("Arquivo gerado com sucesso!!!")

Return
