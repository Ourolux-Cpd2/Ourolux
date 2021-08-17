#include "rwmake.ch"
#include "PROTHEUS.ch"
#INCLUDE "REPORT.CH"
#INCLUDE "TOPCONN.CH"
//--------------------------------------------------------------------
/*/{Protheus.doc} OUROR024
Funçao para geracao do relatorio

Query de busca fornecida pelo Wadih no dia 08/07/2021

@author Rodrigo Nunes.
@since 08/07/2020
/*/
//--------------------------------------------------------------------
User Function OUROR024()

	Processa({|| ImpR024()},"Gerando relatorio... ")

Return

//--------------------------------------------------------------------
/*/{Protheus.doc} ImpR024
Funçao para geracao do relatorio

Query de busca fornecida pelo Wadih no dia 08/07/2021

@author Rodrigo Nunes.
@since 08/07/2020
/*/
//--------------------------------------------------------------------
Static Function ImpR024()
Local cQuery        := ""
Local aCabec        := {'CONTA_CONTABIL','DESCRICAO_CONTA','SOLICITACAO_COMPRA','PEDIDO','DESCRICAO','CODPRODUTO','UN_MEDIDA','QUANTIDADE','COD_FORNECEDOR','NOME_FORNECEDOR','LOJA_FORNECEDOR','VALOR_UNITARIO','VALOR_TOTAL','FILIAL','CENTRO_CUSTO','DESCRICAO_CENTRO_CUSTO','NOTA_FISCAL','EMISSAO_PEDIDO','ENTRADA_NOTA'}
Local aItens        := {}
Local aRet	        := {}
Local aPergs        := {}
local tmp    		:= getTempPath()
Private cCaminho    := ""
Private aParam		:= {}

aAdd(aPergs, {1, "Entrada NF de: "  ,CTOD("  /  /    ") ,"", ".T.", "", ".T.", 50, .T.})
aAdd(aPergs, {1, "Entrada NF ate: " ,CTOD("  /  /    ") ,"", ".T.", "", ".T.", 50, .T.})
aAdd(aPergs, {2, "Tipo de Saida" ,1 , {"Excel","Arquivo Texto"}, 50, ".T.", .F.})

If ParamBox(aPergs,"Impressão",@aRet)
	aParam   := AjRetParam(aRet,aPergs)
    cCaminho := cGetFile( , 'Selecione a pasta de destino', , tmp, .F., GETF_LOCALHARD+GETF_RETDIRECTORY,.F.)
else
    Return
EndIf

If Empty(cCaminho)
    Return
EndIf

cQuery := " SELECT DISTINCT C7_CONTA              'CONTA_CONTABIL', "
cQuery += " 				CT1_DESC01			  'NOME_CONTA', "
cQuery += "                 C7_NUMSC              'SOLICITACAO_COMPRA', "
cQuery += "                 C7_NUM                'PEDIDO', "
cQuery += "                 C7_DESCRI             'DESCRICAO', "
cQuery += "                 C7_PRODUTO            'CODPRODUTO', "
cQuery += "                 C7_UM                 'UN_MEDIDA', "
cQuery += "                 C7_QUANT              'QUANTIDADE', "
cQuery += "                 A2_COD                'COD_FORNECEDOR', "
cQuery += "                 A2_NOME               'NOME_FORNECEDOR', "
cQuery += "                 A2_LOJA               'LOJA_FORNECEDOR', "
cQuery += "                 C7_PRECO              'VALOR_UNITARIO', "
cQuery += "                 C7_TOTAL              'VALOR_TOTAL', "
cQuery += "                 C7_FILIAL             'FILIAL', "
cQuery += "                 C7_CC                 'CENTRO_CUSTO', "
cQuery += "                 CTT_DESC01            'DESCRICAO_CENTRO_CUSTO', "
cQuery += "                 D1_DOC                'NOTA_FISCAL', "
cQuery += "                 RIGHT(C7_EMISSAO, 2) + '/' "
cQuery += "                 + Substring(C7_EMISSAO, 5, 2) + '/' "
cQuery += "                 + LEFT(C7_EMISSAO, 4) 'EMISSAO_PEDIDO', "
cQuery += "                 RIGHT(D1_DTDIGIT, 2) + '/' "
cQuery += "                 + Substring(D1_DTDIGIT, 5, 2) + '/' "
cQuery += "                 + LEFT(D1_DTDIGIT, 4) 'ENTRADA_NOTA' "
cQuery += " FROM   " + RetSqlName("SC7")
cQuery += "        LEFT JOIN (SELECT DISTINCT A2_COD, "
cQuery += "                                   A2_LOJA, "
cQuery += "                                   A2_NOME "
cQuery += "                   FROM   " + RetSqlName("SA2")
cQuery += "                   WHERE  D_E_L_E_T_ = '') A2 "
cQuery += "               ON A2_COD = C7_FORNECE "
cQuery += "                  AND A2_LOJA = C7_LOJA "
cQuery += "        LEFT JOIN (SELECT DISTINCT CTT_CUSTO, "
cQuery += "                                   CTT_DESC01 "
cQuery += "                   FROM   " + RetSqlName("CTT")
cQuery += "                   WHERE  D_E_L_E_T_ = '') CT "
cQuery += "               ON CTT_CUSTO = C7_CC "
cQuery += "		   LEFT JOIN (SELECT DISTINCT CT1_CONTA, CT1_DESC01 "
cQuery += "        		FROM " + RetSqlName("CT1")
cQuery += "        		WHERE D_E_L_E_T_ = '') CT1 "
cQuery += "        		ON CT1_CONTA = C7_CONTA "
cQuery += "        LEFT JOIN (SELECT DISTINCT D1_FILIAL, "
cQuery += "                                   D1_DOC, "
cQuery += "                                   D1_FORNECE, "
cQuery += "                                   D1_PEDIDO, "
cQuery += "                                   D1_COD, "
cQuery += "                                   D1_DTDIGIT "
cQuery += "                   FROM   " + RetSqlName("SD1")
cQuery += "                   WHERE  D_E_L_E_T_ = '') D1 "
cQuery += "               ON D1_FILIAL = C7_FILIAL "
cQuery += "                  AND D1_PEDIDO = C7_NUM "
cQuery += "                  AND D1_COD = C7_PRODUTO "
cQuery += "                  AND D1_FORNECE = C7_FORNECE "
cQuery += " WHERE  D_E_L_E_T_ = '' "
cQuery += "        AND D1_DTDIGIT BETWEEN '"+DTOS(aParam[1])+"' AND '"+DTOS(aParam[2])+"' "
cQuery += "        AND C7_CONTA IN ( '4201010019', '4201010022', '4201010032', '4201010034', "
cQuery += "                          '4201020001', '4201020002', '4201020005', '4201020006', "
cQuery += "                          '4201020007', '4201020008', '4201020009', '4201020010', "
cQuery += "                          '4201020011', '4201020012', '4201020015', '4201020016', "
cQuery += "                          '4201020018', '4201020019', '4201020020', '4201020021', "
cQuery += "                          '4201020023', '4201020024', '4201020025', '4201020026', "
cQuery += "                          '4201020027', '4201020029', '4201020030', '4201020031', "
cQuery += "                          '4201020032', '4201020034', '4201020036', '4201020037', "
cQuery += "                          '4201020040', '4201020043', '4201020044', '4201020045', "
cQuery += "                          '4201020046', '4201020047', '4201020049', '4201020051', "
cQuery += "                          '4201020053', '4201020056', '4201020057', '4201020062', "
cQuery += "                          '4201020065', '4201020067', '4201020068', '4202010001', "
cQuery += "                          '4202010005', '4202010006', '4202010007', '4202010010', "
cQuery += "                          '4202010012', '4202010015', '4202010032', '4202010034', "
cQuery += "                       	 '4201010038', '4201020038', '4201020039', '4201020047', "
cQuery += "							 '4201020048', '4201020068', '4201020999' ) "

IF Select("CTOTMP") > 0
	CTOTMP->(dbCloseArea())
ENDIF

DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery) , 'CTOTMP', .T., .F.)

    While CTOTMP->(!EOF())
    AADD(aItens,{Alltrim(CTOTMP->CONTA_CONTABIL),;
		Alltrim(CTOTMP->NOME_CONTA),;
        Alltrim(CTOTMP->SOLICITACAO_COMPRA),;
        Alltrim(CTOTMP->PEDIDO),;
        Alltrim(CTOTMP->DESCRICAO),; 
        Alltrim(CTOTMP->CODPRODUTO),;
        Alltrim(CTOTMP->UN_MEDIDA),;
        Transform(CTOTMP->QUANTIDADE,PesqPict("SC7","C7_QUANT")),;
        Alltrim(CTOTMP->COD_FORNECEDOR),;
        Alltrim(CTOTMP->NOME_FORNECEDOR),;
        Alltrim(CTOTMP->LOJA_FORNECEDOR),;
        Transform(CTOTMP->VALOR_UNITARIO,PesqPict("SC7","C7_PRECO")),;
        Transform(CTOTMP->VALOR_TOTAL,PesqPict("SC7","C7_TOTAL")),;
        Alltrim(CTOTMP->FILIAL),;
        Alltrim(CTOTMP->CENTRO_CUSTO),;
        Alltrim(CTOTMP->DESCRICAO_CENTRO_CUSTO),;
        Alltrim(CTOTMP->NOTA_FISCAL),;
        CTOTMP->EMISSAO_PEDIDO,;
        CTOTMP->ENTRADA_NOTA})
    
	CTOTMP->(dbSkip())
EndDo

If aParam[3] == 2
	GeraArq(aCabec,aItens)
Else
	If !apoleclient("MSExcel")
		MSGALERT("Nao foi possivel enviar os dados, Microsoft Excel nao instalado!")
		If MSGYESNO("Deseja gerar o mesmo em arquivo de texto delimitado por | ?")
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
FunÃ§Ã£o para geracao do arquivo TXT delimitado por ;

@author Rodrigo Nunes
@since 12/07/2021
/*/
//--------------------------------------------------------------------
Static Function GeraArq(aCabec,aItens)
Local cFile 	:= cCaminho + "OUROR024_" + SubStr(DTOS(dDatabase),7,2) + "_" + SubStr(DTOS(dDatabase),5,2) + "_" + SubStr(DTOS(dDatabase),1,4) + "_" + StrTran(Time(),":","") + ".txt"
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

//--------------------------------------------------------------------
/*/{Protheus.doc} AjRetParam
Funcão de ajuste do conteúdo da ParamBox.

@author Rodrigo Nunes
@since 17/02/2021
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
