#INCLUDE "PROTHEUS.CH"
#Include "rwmake.ch"

#DEFINE COMP_DATE	"20191209"

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} M460FIM
Este P.E. e' chamado apos a Gravacao da NF de Saida, e fora da transa��o.
Gera arquivo para integra�ao para o sistema de cobranca BRADESCO - BOLETO

@type 		Function
@author 	TOTVS
@since 		03/05/2017
@version 	P12


*** Mehoria Projeto - Automa��o do Faturamento Venda a ORDEM, para cria o Pedido Automaticamente, apos Faturamento
- Autor - Rodrigo Altafini - 16/09/2020

Parametro - ES_M460VO - Tipo "C"	- Informar o Codigo da Mensagem para Remessa de Venda a Ordem 


Campos - Criados nesta Rotina:
Nome - C5_XCLIRCO 
Descri��o - Cli Rem V.O.
Tipo - Caracter
Tamanho - 6
Decimal - 0
Consulta Padr�o  - SA1
Val Usu�rio - existcpo("SA1",M->C5_XCLIRCO) .and. U_validaRisco()

Nome - C5_XLOJRCO
Descri��o - Loja Rem V.O.
Tipo - Caracter
Tamanho - 2
Decimal - 0
Consulta Padr�o - vazio
Val Usu�rio - vazio

Nome - C5_XPVSFVO
Descri��o - PV Venda Ord
Tipo - Caracter
Tamanho - 6
Decimal - 0
Consulta Padr�o - vazio
Val Usu�rio - vazio
Uso - N�o usado (este campo n�o precisa estar na tela)


� necess�rio tamb�m criar no cadastro de tabelas (SX5) no configurador os itens abaixo na tabela DJ
13 � Venda a Ordem
14 � Remessa Conta e Ordem


/*/    
//-------------------------------------------------------------------------------------
User Function M460FIM()

	Local aArea     	:= ""
	Local nRecSE1       := 0
	Local lGeraBol      := !(SC5->C5_BANCO $ 'LIC.CAR') // BANCO LIC/CAR : Nao Gera arquivo texto para a impressao do boleto

	Private cCODMsgVO	:= GetMv("ES_M460VO")	//Parametro Mensagem FISCAL para Gerar na REMESSA A ORDEM
		
	PesoBru() // Grava o peso bruto no F2_PBRUTO
	PesoLiq() // Grava o peso LIQUIDO no F2_PLIQUI
	
	// Campo especifico para a digit. da base de ICMS RET para a NF complementar de ICMS ST
	If !Empty(SC5->C5_BICMST)
		SF2->(RecLock('SF2', .F.))
		SF2->F2_BICMST := SC5->C5_BICMST // 08-04-2009 BASE DE ICMS ST PARA NF COMPLEMENTAR DE ICMS ST
		SF2->(MSUnLock())
	EndIf
	

	// NF-e XML
	If !Empty(SC5->C5_TPFRETE)
		SF2->( RecLock('SF2', .F.))
		SF2->F2_TPFRETE := SC5->C5_TPFRETE // NF-e XML
		SF2->( MSUnLock() )
	EndIf
	
	// Especie/Volumes
	If Empty(SC5->C5_ESPECI1) .And. (SC5->C5_VOLUME1 == 0) .And. SC5->C5_TIPO == 'N'
		EspVol()
	EndIf
	
	// Para bonifica�o nao geramos boletos
	If U_IsBonif(SF2->F2_DOC,SF2->F2_SERIE)
		Return (NIL)
	EndIf
	
	If SF2->F2_TIPO    <> 'D' .And.;
			SF2->F2_SERIE <> 'TRC'
		
		/* GERA Boleto NO FORMATO WSISLASER P/ BRADESCO */
		SA1->( RecLock( 'SA1', .F. ) )
		SA1->A1_ULTCOM := dDataBase
		SA1->( MSUnLock() )
		
		nRecSE1 := SE1->( RecNo() )
		
		While SF2->F2_DOC = SE1->E1_NUM .And.;
			SF2->F2_SERIE == SE1->E1_PREFIXO
			
			RecLock( "SE1", .F. )
			SA3->( dbSeek( xFilial( "SA3" ) + SE1->E1_VEND1, .F.  ) )
			SE1->E1_SUPERVI := SA3->A3_SUPER
			SE1->( MSUnLock() )
			SE1->( dbSkip( -1 ) )
		EndDo
		SE1->( dbGoTo( nRecSE1 ) )
	EndIf
	
	If !Empty( SC5->C5_DATA1  )
		SE1->( RecLock( 'SE1', .F. ) )
		SE1->E1_VENCTO  := SC5->C5_DATA1
		SE1->E1_VENCREA := Datavalida(SC5->C5_DATA1)
		SE1->E1_VENCORI := SC5->C5_DATA1
		SE1->( MSUnLock() )
	EndIf
	
	aArea := GetArea()

	If lGeraBol

		While SF2->F2_DOC == SE1->E1_NUM .And.;
			SF2->F2_SERIE == SE1->E1_PREFIXO
		                      
			RecLock( "SE1", .F. )
			SE1->E1_SUPERVI := SA3->A3_SUPER
			SE1->E1_XCATCOB := "5" 
			If SE1->(FieldPos("E1_XBOLETO")) > 0
				SE1->E1_XBOLETO := "1"
			EndIf
			SE1->( MSUnLock() )
	                   
			SE1->( dbSkip( -1 ) )
		EndDo
	EndIf

	// Maur�cio Aureliano - Chamado: I1805-1114 - Comiss�o - Complemento de ST
	If SF2->F2_TIPO == "I"
	
		SE1->(dbSetOrder(2))
		SE1->(dbSeek(xFilial("SE1")+E1_FILIAL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO))

		While !Eof() .and. SE1->E1_FILIAL == xFilial("SE1") .and. SE1->E1_CLIENTE == SF2->F2_CLIENTE .and. SE1->E1_PREFIXO == SF2->F2_SERIE .and. SE1->E1_NUM == SF2->F2_DOC
			SE1->(RecLock("SE1", .F. ))
			SE1->E1_VEND1 := ""
			SE1->E1_VEND2 := ""
			SE1->E1_VEND3 := ""
			SE1->E1_VEND4 := ""
			SE1->E1_VEND5 := ""
			SE1->(MsUnLock())
		EndDo

	EndIf

	/* 
	Altera��o 10-09-2020 
	tratativa para o processo de venda a ordem 
	cria��o de pedido de venda de remessa por conta e ordem de terceiros 
	*/

	GeraPvRemCtaOrdem()

Return( Nil )

// Check to see if Bonifica�ao
User Function IsBonif(cDoc,cSer)
Local lRet 		:= .F.
Local cQuery 	:= ""
Local _aArea    := GetArea()

cQuery := 	" SELECT D2_DOC, D2_SERIE, D2_CF ,D2_TES " +;
        	" FROM " + RetSqlName("SD2") + " SD2" +;
		    " WHERE	SD2.D2_FILIAL = '" + xFilial("SD2") + "' AND" +;
		    " SD2.D2_DOC   = '" + cDoc + "' AND" +;
		    " SD2.D2_SERIE = '" + cSer + "' AND" +;
		    " SD2.D_E_L_E_T_ = ' ' "

cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TMP",.F.,.T.)

DbSelectArea("TMP")
DbGoTop()

While !TMP->(Eof())
	
	If Substr( TMP->D2_CF, 2, 3 ) == "910"  // Codigo fiscal para Bonifica�ao
		lRet := .T.
		Exit
	EndIf
	
	TMP->(DbSkip())
	
End

//����������������������������Ŀ
//�Finalize ambiente temporario�
//������������������������������
TMP->(DbCloseArea())
RestArea(_aArea)

Return (lRet)


Static Function EspVol()
	Local cQuery    := ''
	Local nQtdVol 	:= 0
	Local cAliasQry := "TMP"
	Local _aArea1   := GetArea()

	If Select(cAliasQry) != 0
		(cAliasQry)->(DbCloseArea())
	EndIf

	cQuery := "SELECT SD2.D2_COD AS Produto,SUM (SD2.D2_QUANT) as Quant,  "
	cQuery += "SB1.B1_QE As QE, SB1.B1_UM As UM "
	cQuery += "FROM " + RetSqlName("SD2") + " SD2 "
	cQuery += "INNER JOIN " + RetSqlName("SB1") + " SB1 ON "
	cQuery += "SD2.D2_COD = SB1.B1_COD "
	cQuery += "INNER JOIN " + RetSqlName("SF4") + " SF4 ON "
	cQuery += "SD2.D2_TES = SF4.F4_CODIGO "
	cQuery += "WHERE "
	cQuery += "SD2.D_E_L_E_T_ = ' ' AND SB1.D_E_L_E_T_ = ' ' AND "
	cQuery += "SF4.D_E_L_E_T_ = ' ' AND "
	cQuery += "SD2.D2_FILIAL  = '" + SF2->F2_FILIAL  + "' AND "
	cQuery += "SD2.D2_CLIENTE = '" + SF2->F2_CLIENTE + "' AND "
	cQuery += "SD2.D2_LOJA    = '" + SF2->F2_LOJA    + "' AND "
	cQuery += "SD2.D2_SERIE   = '" + SF2->F2_SERIE   + "' AND "
	cQuery += "SD2.D2_DOC     = '" + SF2->F2_DOC     + "' AND "
	cQuery += "SD2.D2_TIPO    = '" + SF2->F2_TIPO    + "' AND "
	cQuery += "SF4.F4_ESTOQUE = 'S' "
	cQuery += "GROUP BY SD2.D2_COD, SB1.B1_QE, SB1.B1_UM "
	cQuery += "ORDER BY SD2.D2_COD "

	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery), cAliasQry)

	While (cAliasQry)->(!Eof())
		If !Empty((cAliasQry)->QE)
			If Alltrim((cAliasQry)->UM) <> "CX"
				nQtdVol	+= Int((cAliasQry)->Quant / (cAliasQry)->QE)
				If Mod((cAliasQry)->Quant, (cAliasQry)->QE) > 0
					nQtdVol++
				EndIf
			Else
				nQtdVol += (cAliasQry)->Quant
			EndIf
		EndIf
		(cAliasQry)->(dbSkip())
	EndDo
	
	If nQtdVol > 0
		SF2->(RecLock('SF2', .F.))	
		Replace SF2->F2_ESPECI1 With 'Caixa(s)'
		Replace SF2->F2_VOLUME1 With nQtdVol
		SF2->(MSUnLock())
	EndIf

	(cAliasQry)->(DbCloseArea())
	RestArea(_aArea1)

Return()

Static Function PesoLiq()

	Local _cQuery    := ''
	Local _aArea1   := GetArea()

	If Select("PESO") > 0
		DbSelectArea("PESO")
		PESO->(DbCloseArea())
	EndIf

	_cQuery := " SELECT SUM(SB1.B1_PESO * D2_QUANT) As PESOL "
	_cQuery += " FROM " + RetSqlName("SD2") + " SD2 "
	_cQuery += " INNER JOIN " + RetSqlName("SB1") + " SB1 "
	_cQuery += " ON SD2.D2_COD = SB1.B1_COD "
	_cQuery += " WHERE SD2.D_E_L_E_T_ <> '*' AND "
	_cQuery += " SB1.D_E_L_E_T_ <> '*' AND "
	_cQuery += " SD2.D2_FILIAL  = '" + SF2->F2_FILIAL  + "' AND "
	_cQuery += " SD2.D2_CLIENTE = '" + SF2->F2_CLIENTE + "' AND "
	_cQuery += " SD2.D2_LOJA    = '" + SF2->F2_LOJA    + "' AND "
	_cQuery += " SD2.D2_SERIE   = '" + SF2->F2_SERIE   + "' AND "
	_cQuery += " SD2.D2_DOC     = '" + SF2->F2_DOC     + "' AND "
	_cQuery += " SD2.D2_TIPO    = '" + SF2->F2_TIPO    + "' AND "
	_cQuery += " SB1.B1_FILIAL  = '" + xFilial("SB1") + "' "
	_cQuery += " GROUP BY SD2.D2_DOC "

//MEMOWRITE("E:\TESTESQL3.SQL",_cQuery)

	dbUseArea( .T., "TOPCONN", TCGENQRY(,,_cQuery), 'PESO' )

	_nPesoL := PESO->PESOL

	If SF2->( RecLock( 'SF2', .F. ) ) .And. PESO->(!Eof())
	
		SF2->F2_PLIQUI := PESO->PESOL
		SF2->( MSUnLock() )
	
	EndIf

	RestArea(_aArea1)
	PESO->(DbCloseArea())

Return()

Static Function PesoBru()

	Local _cQuery    := ''
	Local _aArea1   := GetArea()

	If Select("PESO") > 0
		DbSelectArea("PESO")
		PESO->(DbCloseArea())
	EndIf

	_cQuery := " SELECT SUM(SB1.B1_PESBRU * D2_QUANT) As PESOB "
	_cQuery += " FROM " + RetSqlName("SD2") + " SD2 "
	_cQuery += " INNER JOIN " + RetSqlName("SB1") + " SB1 "
	_cQuery += " ON SD2.D2_COD = SB1.B1_COD "
	_cQuery += " WHERE SD2.D_E_L_E_T_ <> '*' AND "
	_cQuery += " SB1.D_E_L_E_T_ <> '*' AND "
	_cQuery += " SD2.D2_FILIAL  = '" + SF2->F2_FILIAL  + "' AND "
	_cQuery += " SD2.D2_CLIENTE = '" + SF2->F2_CLIENTE + "' AND "
	_cQuery += " SD2.D2_LOJA    = '" + SF2->F2_LOJA    + "' AND "
	_cQuery += " SD2.D2_SERIE   = '" + SF2->F2_SERIE   + "' AND "
	_cQuery += " SD2.D2_DOC     = '" + SF2->F2_DOC     + "' AND "
	_cQuery += " SD2.D2_TIPO    = '" + SF2->F2_TIPO    + "' AND "
	_cQuery += " SB1.B1_FILIAL  = '" + xFilial("SB1") + "' "
	_cQuery += " GROUP BY SD2.D2_DOC "

	dbUseArea( .T., "TOPCONN", TCGENQRY(,,_cQuery), 'PESO' )

	If SF2->( RecLock( 'SF2', .F. ) ) .And. PESO->(!Eof())
	
		SF2->F2_PBRUTO := PESO->PESOB
		SF2->( MSUnLock() )
	
	EndIf

	RestArea(_aArea1)
	PESO->(DbCloseArea())

Return()

Static Function GeraPvRemCtaOrdem()

Local   aSavArea := GetArea()
Private BRefresh := {|| .T.}	//variavel utilizada n Gatilho - CADSZT fun��o Totvs MaTesInt(...)


dbselectarea("SD2")
dbsetorder(3)
dbseek(xFilial("SD2")+SF2->(F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA))

if found()

    dbselectarea("SC5")
    dbsetorder(1)
    dbseek(xFilial("SC5")+SD2->D2_PEDIDO)
    
    if found()


		if SC5->C5_TESINT = '03' .and. !empty(SC5->C5_XCLIRCO) .and. !empty(SC5->C5_XLOJRCO) 

			aItens          := {}
			lMsErroAuto     := .F.
			cPedVen         := SD2->D2_PEDIDO
			cMsgNF 			:= formula(cCODMsgVO) + " " + SD2->D2_DOC + " - Serie " + SD2->D2_SERIE + " - Emissao " + DTOC(SD2->D2_EMISSAO) 
			nTamMsg 		:= TamSX3("C5_XMSGNF")[1]
			aCab := {;
					{"C5_TIPO"   ,SC5->C5_TIPO    , Nil},; 
					{"C5_CLIENTE",SC5->C5_XCLIRCO , Nil},;
					{"C5_LOJACLI",SC5->C5_XLOJRCO , Nil},;
					{"C5_CLIENT" ,SC5->C5_XCLIRCO , NiL},;
					{"C5_LOJAENT",SC5->C5_XLOJRCO, Nil},;
					{"C5_EMISSAO",dDatabase      , Nil},;
					{"C5_TIPOCLI",POSICIONE("SA1",1,xFilial("SA1")+SC5->C5_XCLIRCO+SC5->C5_XLOJRCO,"A1_TIPO"), Nil},;
					{"C5_TRANSP" ,SC5->C5_TRANSP , Nil},;
					{"C5_TESINT" ,'04'           , Nil},;
					{"C5_COMIS1" ,0.00           , Nil},;
					{"C5_VEND1"  ,SC5->C5_VEND1  , Nil},;
					{"C5_CONDPAG",'000'          , Nil},;
					{"C5_FRETE"  ,SC5->C5_FRETE  , Nil},;
					{"C5_VLFRETE",SC5->C5_VLFRETE, Nil},;
					{"C5_TPFRETE",'C'			 , Nil},;
					{"C5_TPCARGA",'1'            , Nil},;
					{"C5_MOEDA"  ,SC5->C5_MOEDA  , Nil},;
					{"C5_PESOL"  ,SC5->C5_PESOL  , Nil},; 
					{"C5_PBRUTO" ,SC5->C5_PBRUTO , Nil},; 
					{"C5_VOLUME1",SC5->C5_VOLUME1, Nil},;
					{"C5_ESPECI1",SC5->C5_ESPECI1, Nil},;
					{"C5_VOLUME2",SC5->C5_VOLUME2, Nil},;
					{"C5_ESPECI2",SC5->C5_ESPECI2, Nil},;
					{"C5_VOLUME3",SC5->C5_VOLUME3, Nil},;
					{"C5_ESPECI3",SC5->C5_ESPECI3, Nil},;
					{"C5_VOLUME4",SC5->C5_VOLUME4, Nil},;
					{"C5_ESPECI4",SC5->C5_ESPECI4, Nil},;
					{"C5_MSGNOTA",cMsgNF		 , Nil},;
					{"C5_XPVSFVO",SC5->C5_NUM    , Nil}}


					nVolum1 := SC5->C5_VOLUME1      
					nVolum2 := SC5->C5_VOLUME2      
					nVolum3 := SC5->C5_VOLUME3      
					nVolum4 := SC5->C5_VOLUME4
					
					
            while SD2->(!eof()) .and. SD2->(D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA)==SF2->(F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA)

				aadd( aItens,   {;
								{"C6_ITEM"   , SD2->D2_ITEMPV, Nil},; 
								{"C6_PRODUTO", SD2->D2_COD   , Nil},;
								{"C6_QTDVEN" , SD2->D2_QUANT , Nil},;
								{"C6_QTDLIB" , 0			 , Nil},;
								{"C6_PRCVEN" , SD2->D2_PRCVEN, Nil},;
								{"C6_VALOR"  , ROUND(SD2->(D2_PRCVEN * D2_QUANT),2), Nil},;
								{"C6_TES"    , '958'        , Nil},;
								{"C6_LOCAL"  , SD2->D2_LOCAL, Nil},;
								{"C6_ENTREG" , dDATABASE    , Nil},;
								{"C6_NFORI"  , SD2->D2_DOC  , Nil},;
								{"C6_SERIORI", SD2->D2_SERIE ,Nil},;
								{"C6_ITEMORI", SD2->D2_ITEM , Nil};
					};
					)

					SD2->(dbskip())

			enddo

			MSExecAuto({|x,y,z| MATA410(x,y,z) }, aCab, aItens,3)

			if lMSErroAuto
                    
				MostraErro()
                    
			else
                    
				Reclock("SC5",.f.)
				SC5->C5_VOLUME1     := nVolum1
				SC5->C5_VOLUME2     := nVolum2
				SC5->C5_VOLUME3     := nVolum3
				SC5->C5_VOLUME4     := nVolum4
				SC5->C5_GERAWMS		:= "2"
				MSMM(,nTamMsg,,cMsgNF,1,,,"SC5","C5_XCODMNF")

				MsUnlock()

				//MsgInfo("Pedido de Venda nr. " + SC5->C5_NUM + " gerado automaticamente - Remessa de mercadoria por conta e ordem de terceiros.")
                    
			endif

		endif

	endif

endif

RestArea(aSavArea)

return
