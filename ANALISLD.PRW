#INCLUDE "PROTHEUS.CH"
#Include "topconn.ch"

User Function ANALISLD()
	Local oReport := ReportDef()

	If oReport == Nil
		MsgInfo("*** CANCELADO PELO OPERADOR ***")
	Else
		oReport:PrintDialog()
		Return Nil
	Endif


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Descri��o � Definicao dos Parametros do Relatorio                      ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �  			                                          ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function ReportDef()
	Local oReport	:= NIL
	Local oLinha	:= NIL
	Local cAliasRep := "QRY"//GetNextAlias()
	Local cPerg		:= "U_ANALISLD"
	Local cAviso	:= "Este programa ira imprimir relat�rio para anaise de saldos "
	Local cPar      := ""
	Local cPicture	:= "@E 999,999,999.9999"

	//Ajusta as Perguntas
	CriaPer2(cPerg)

	//������������������������������������������������������������������������Ŀ
	//�Criacao do componente de impressao                                      �
	//�                                                                        �
	//�TReport():New                                                           �
	//�ExpC1 : Nome do relatorio                                               �
	//�ExpC2 : Titulo                                                          �
	//�ExpC3 : Pergunte                                                        �
	//�ExpB4 : Bloco de codigo que sera executado na confirmacao da impressao  �
	//�ExpC5 : Descricao                                                       �
	//�                                                                        �
	//��������������������������������������������������������������������������
	oReport := TReport():New(cPerg,"ANALISE DE SALDOS", cPerg, {|oReport| ReportPrint(oReport,@cAliasRep,cPar)}, cAviso)

	oReport:SetLandscape()
	//��������������������������������������������������������������Ŀ
	//� Verifica as perguntas selecionadas                           �
	//����������������������������������������������������������������



	Pergunte(oReport:uParam,.F.)
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
	//��������������������������������������������������������������������������

	//��������������������������������������������������������������Ŀ
	//� Sessao 1 (oLinha)                                            �
	//����������������������������������������������������������������
	iF MV_PAR05 == 1
		_cRelTp:= "ATUAIS"
	ElseIf MV_PAR05 == 2
		_cRelTp:= "INICIAIS"
	Endif

	oLinha := TRSection():New(oReport,"ANALISE DE SALDOS", {cAliasRep})
	oLinha:SetTotalInLine(.F.)

	//TRCell():New(oParent,cName,cAlias,cTitle,cPicture,nSize,lPixel,bBlock,cAlign,lLineBreak,cHeaderAlign,lCellBreak,nColSpace,lAutoSize,nClrBack,nClrFore,lBold)
	TRCell():New(oLinha	,'COD'										         			,cAliasRep,'C�digo'			,       /*Picture*/	,20,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oLinha	,'ARM'			         ,cAliasRep,'Armaz�m'		,      /*Picture*/	,02,/*lPixel*/,/*{|| code-block de impressao }*/)

	iF MV_PAR05 == 1
		TRCell():New(oLinha	,'SALDO_B2'		    ,cAliasRep,'Sld.F�sico'		,   cPicture	,13,/*lPixel*/,/*{|| code-block de impressao }*/)
		TRCell():New(oLinha	,'SALDO_B8'		    ,cAliasRep,'Sld.Lote'		  ,   cPicture	,13,/*lPixel*/,/*{|| code-block de impressao }*/)
		TRCell():New(oLinha	,'SALDO_BF'		    ,cAliasRep,'Sld.Endere�o'	, cPicture	,13,/*lPixel*/,/*{|| code-block de impressao }*/)

	ElseIf MV_PAR05 == 2
		TRCell():New(oLinha	,'SALDO_B9'		    ,cAliasRep,'Sld.F�sico'		,   cPicture	,13,/*lPixel*/,/*{|| code-block de impressao }*/)
		TRCell():New(oLinha	,'SALDO_BJ'		    ,cAliasRep,'Sld.Lote'		  ,   cPicture	,13,/*lPixel*/,/*{|| code-block de impressao }*/)
		TRCell():New(oLinha	,'SALDO_BK'		    ,cAliasRep,'Sld.Endere�o'	, cPicture	,13,/*lPixel*/,/*{|| code-block de impressao }*/)
	Endif
	TRCell():New(oLinha	,'ENDERECAR'	   ,cAliasRep,'� Endere�ar'	,  cPicture	,13,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oLinha	,'RASTRO'		      ,cAliasRep,'Rastro por'		,  	/*Picture*/,07,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oLinha	,'ENDERECAMENTO' ,cAliasRep,'Contr.End.'		, 	/*Picture*/,03,/*lPixel*/,/*{|| code-block de impressao }*/)

	oLinha:SetHeaderPage()

Return oReport
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �ReportPrint � Autor �Marcos V. Ferreira   � Data �08/06/06  ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �A funcao estatica ReportPrint devera ser criada para todos  ���
���          �os relatorios que poderao ser agendados pelo usuario.       ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �Nenhum                                                      ���
�������������������������������������������������������������������������Ĵ��
���Parametros�ExpO1: Objeto Report do Relatorio                           ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � MATR850			                                          ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function ReportPrint(oReport, cAliasRep,cPar)

	Local oLinha	:= oReport:Section(1)
	Local oBreak1	:= NIL
	Local nOrdem	:= oLinha:GetOrder()

	//��������������������������������������������������������������Ŀ
	//� Acerta o titulo do relatorio                                 �
	//����������������������������������������������������������������
	oReport:SetTitle(oReport:Title())


	//������������������������������������������������������������������������Ŀ
	//�Transforma parametros Range em expressao SQL                            �
	//��������������������������������������������������������������������������
	MakeSqlExpr(oReport:uParam)

	//������������������������������������������������������������������������Ŀ
	//�Inicio do Embedded SQL                                                  �
	//��������������������������������������������������������������������������
	IF MV_PAR05 == 1

		cQuery:= "%TAB.* FROM ("
		cQuery+= " (SELECT B2_COD COD, B2_LOCAL ARM, B2_QATU AS SALDO_B2,"

		cQuery+= " ISNULL((SELECT SUM(B8_SALDO)"
		cQuery+= " FROM "+ retsqlname("SB8") +" SB8 "
		cQuery+= " WHERE B8_FILIAL = "+ XFilial("SB8") +" "
		cQuery+= " AND B8_PRODUTO = B2_COD"
		cQuery+= " AND B8_LOCAL = B2_LOCAL"
		cQuery+= " AND SB8.D_E_L_E_T_ = ''"
		cQuery+= " GROUP BY B8_PRODUTO, B8_LOCAL),0) SALDO_B8,"

		cQuery+= " ISNULL((SELECT SUM(BF_QUANT) "
		cQuery+= " FROM "+ retsqlname("SBF") +" SBF "
		cQuery+= " WHERE BF_FILIAL = "+XFilial("SBF")+" "
		cQuery+= " AND BF_PRODUTO = B2_COD"
		cQuery+= " AND BF_LOCAL = B2_LOCAL"
		cQuery+= " AND SBF.D_E_L_E_T_ = ''"
		cQuery+= " GROUP BY BF_PRODUTO, BF_LOCAL),0) SALDO_BF,"

		cQuery+= " ISNULL((SELECT SUM(DA_SALDO) "
		cQuery+= " FROM "+ retsqlname("SDA") +" SDA "
		cQuery+= " WHERE DA_FILIAL = "+ XFilial("SDA") +" "
		cQuery+= " AND DA_PRODUTO = B2_COD"
		cQuery+= " AND DA_LOCAL = B2_LOCAL"
		cQuery+= " AND SDA.D_E_L_E_T_ = ''"
		cQuery+= " GROUP BY DA_PRODUTO, DA_LOCAL),0) ENDERECAR,"

		cQuery+= " CASE WHEN B1_RASTRO = 'L' THEN 'LOTE' "
		cQuery+= " WHEN B1_RASTRO = 'S' THEN 'SUBLOTE'"
		cQuery+= " ELSE ''"
		cQuery+= " END RASTRO," 
		cQuery+= " CASE WHEN B1_LOCALIZ = 'S' THEN 'SIM'"
		cQuery+= " ELSE 'N�O'"
		cQuery+= " END ENDERECAMENTO%"

		cFrom:= "% "+ retsqlname("SB2") +" SB2 "
		cFrom+= " INNER JOIN "+retsqlname("SB1")+" SB1  ON B1_COD = B2_COD AND SB1.D_E_L_E_T_ = '' AND (B1_RASTRO <> 'N' OR B1_LOCALIZ <> 'N')"

		cFrom+= " WHERE B2_FILIAL = "+ XFilial("SB2") +" "
		cFrom+= " AND SB2.D_E_L_E_T_ = ''"
		cFrom+= " AND B2_LOCAL BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"' "
		cFrom+= " AND B2_COD BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"' "

		cFrom+= " )) AS TAB"
		cFrom+= " WHERE	(	(TAB.SALDO_B2 <> TAB.SALDO_B8) OR" 
		cFrom+= " (TAB.SALDO_B2 <> TAB.SALDO_BF) OR "
		cFrom+= " (TAB.SALDO_B8 <> TAB.SALDO_BF ))%"	


		BeginSql Alias cAliasRep
			Column SALDO_B2 AS NUMERIC(09, 4)
			Column SALDO_B8 AS NUMERIC(09, 4)
			Column SALDO_BF AS NUMERIC(09, 4)
			Column ENDERECAR AS NUMERIC(09, 4)

			SELECT %Exp:cQuery%
			FROM %Exp:cFrom%
			ORDER BY 2,3

		EndSql


	ElseIf MV_PAR05 == 2
		cQuery:= "%TAB.* FROM ("
		cQuery+= " (SELECT B9_COD COD, B9_LOCAL ARM, B9_QINI AS SALDO_B9,"

		cQuery+= " ISNULL((SELECT SUM(BJ_QINI)"
		cQuery+= " FROM "+ retsqlname("SBJ") +" SBJ "
		cQuery+= " WHERE BJ_FILIAL = "+XFilial("SBJ")+" "
		cQuery+= " AND BJ_PRODUTO = B9_COD"
		cQuery+= " AND BJ_LOCAL = B9_LOCAL"
		cQuery+= " AND SBJ.D_E_L_E_T_ = ''"
		cQuery+= " GROUP BY BJ_PRODUTO, BJ_LOCAL),0) SALDO_BJ,"

		cQuery+= " ISNULL((SELECT SUM(BK_QINI) "
		cQuery+= " FROM "+ retsqlname("SBK") +" SBK "
		cQuery+= " WHERE BK_FILIAL = "+ XFilial("SBK") +" "
		cQuery+= " AND BK_PRODUTO = B9_COD"
		cQuery+= " AND BK_LOCAL = B9_LOCAL"
		cQuery+= " AND SBK.D_E_L_E_T_ = ''"
		cQuery+= " GROUP BY BK_PRODUTO, BK_LOCAL),0) SALDO_BK,"

		cQuery+= " ISNULL((SELECT SUM(DA_SALDO) "
		cQuery+= " FROM "+ retsqlname("SDA") +" SDA "
		cQuery+= " WHERE DA_FILIAL = "+ XFilial("SDA") +" "
		cQuery+= " AND DA_PRODUTO = B9_COD"
		cQuery+= " AND DA_LOCAL = B9_LOCAL"
		cQuery+= " AND SDA.D_E_L_E_T_ = ''"
		cQuery+= " GROUP BY DA_PRODUTO, DA_LOCAL),0) ENDERECAR,"

		cQuery+= " CASE WHEN B1_RASTRO = 'L' THEN 'LOTE' "
		cQuery+= " WHEN B1_RASTRO = 'S' THEN 'SUBLOTE'"
		cQuery+= " ELSE ''"
		cQuery+= " END RASTRO," 
		cQuery+= " CASE WHEN B1_LOCALIZ = 'S' THEN 'SIM'"
		cQuery+= " ELSE 'N�O'"
		cQuery+= " END ENDERECAMENTO%"

		cFrom:= "% "+ retsqlname("SB9") +" SB9 "
		cFrom+= " INNER JOIN "+retsqlname("SB1")+" SB1  ON B1_COD = B9_COD AND SB1.D_E_L_E_T_ = '' AND (B1_RASTRO <> 'N' OR B1_LOCALIZ <> 'N')"

		cFrom+= " WHERE B9_FILIAL = "+ XFilial("SB9") +" "
		cFrom+= " AND SB9.D_E_L_E_T_ = ''"
		cFrom+= " AND B9_LOCAL BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"' "
		cFrom+= " AND B9_COD BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"' "
		cFrom+= " AND B9_COD BETWEEN '"+DtoS(MV_PAR06)+"'"

		cFrom+= " )) AS TAB"
		cFrom+= " WHERE	(	(TAB.SALDO_B9 <> TAB.SALDO_BJ) OR" 
		cFrom+= " (TAB.SALDO_B9 <> TAB.SALDO_BK) OR "
		cFrom+= " (TAB.SALDO_BJ <> TAB.SALDO_BK ))%"	


		BeginSql Alias cAliasRep
			Column SALDO_B9 AS NUMERIC(09, 4)
			Column SALDO_BJ AS NUMERIC(09, 4)
			Column SALDO_BK AS NUMERIC(09, 4)
			Column ENDERECAR AS NUMERIC(09, 4)

			SELECT %Exp:cQuery%
			FROM %Exp:cFrom%
			ORDER BY 2,3

		EndSql

	Endif

	oReport:Section(1):EndQuery()

	//��������������������������������������������������������������Ŀ
	//� Abertura do arquivo de trabalho                              |
	//����������������������������������������������������������������
	dbSelectArea(cAliasRep)

	oLinha:SetLineCondition({|| .T.})

	//�����������������������Ŀ
	//�Impressao do Relatorio �
	//�������������������������
	oLinha:Print()
Return Nil
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � CriaPer2 �Autor  �                    � Data �  25/03/09   ���
�������������������������������������������������������������������������͹��
���Desc.     � Cria as Perguntas no SX1                                   ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � WMSR011                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function CriaPer2(cPerg)
	Local nXX	:= 0
	Local aPerg	:= {}
	Local lLock	:= .F.

	aAdd( aPerg, {"Local Inicial?"		, "C", 02, 00, "G", "", "", "", "", "", "" } )
	aAdd( aPerg, {"Local Final?"		, "C", 02, 00, "G", "", "", "", "", "", "" } ) 

	aAdd( aPerg, {"Produto Inicial?"	, "C", 15, 00, "G", "", "", "", "", "", "" } )
	aAdd( aPerg, {"Produto Final?"		, "C", 15, 00, "G", "", "", "", "", "", "" } )

	aAdd( aPerg, {"Saldo a Considerar?"	, "N", 01, 00,  "C", "Atual", "Inicial", "", "", "", "" } )
	aAdd( aPerg, {"Ultimo Fechamento ?"	, "D", 08, 00,  "G", "", "", "", "", "", "" } )

	//aAdd( aPerg, {"Ordenar por?" 			, "N", 01, 00, "C", "C�digo", "Estrutura F�sica", " Qtd.Reabastecimentos", "", "", "" } )		//09

	For nXX := 1 To Len(aPerg)
		lLock := !SX1->(Dbseek( cPerg + StrZero(nXX, 2)))

		Reclock("SX1", lLock)
		SX1->X1_GRUPO 		:= cPerg
		SX1->X1_ORDEM		:= StrZero(nXX, 2)
		SX1->X1_VARIAVL		:= "mv_ch" + Chr( nXX +96 )
		SX1->X1_VAR01		:= "mv_par" + StrZero(nXX,2)
		SX1->X1_PRESEL		:= 1
		SX1->X1_PERGUNT		:= aPerg[ nXX , 01 ]
		SX1->X1_TIPO 		:= aPerg[ nXX , 02 ]
		SX1->X1_TAMANHO		:= aPerg[ nXX , 03 ]
		SX1->X1_DECIMAL		:= aPerg[ nXX , 04 ]
		SX1->X1_GSC  		:= aPerg[ nXX , 05 ]
		SX1->X1_DEF01		:= aPerg[ nXX , 06 ]
		SX1->X1_DEF02		:= aPerg[ nXX , 07 ]
		SX1->X1_DEF03		:= aPerg[ nXX , 08 ]
		SX1->X1_DEF04		:= aPerg[ nXX , 09 ]
		SX1->X1_DEF05		:= aPerg[ nXX , 10 ]
		SX1->X1_F3   		:= aPerg[ nXX , 11 ]
		MsUnlock()
	Next nXX

Return Nil
