#Include "rwmake.ch"

/*
Ponto de entrada executado após a gravação do Pedido de Venda - 
quando a operação for de FATURAMENTO - na rotina do Televendas 
e da Agenda do Operador. Pode ser utilizado apenas como processo 
sem interação do usuário (Tela).
*/

USER FUNCTION TMKVFIM(cNumSUA, cNumSC5)

Local _cBco       	:= ""
Local _Margem     	:= 0
Local _TotVen     	:= 0 
Local _TotCus     	:= 0 
Local _TotComis   	:= 0
Local _ValBall    	:= 0
Local _aAreaSUA   	:= GetArea("SUA")
Local _aAreaSUB   	:= GetArea("SUB")
Local _aAreaSC5   	:= GetArea("SC5")
Local _aAreaSC6   	:= GetArea("SC6")
Local lBonif		:= .F. 
Local _cQuery       := ''
Local _nCPed        := 0
Local _nPesoL       := 0
Local _nPBruto      := 0
Local _MarLiq     	:= 0
Local cFilSC5		:= xFilial("SC5")//B4B.AL07092016
Local nTotPV        := 0
Local nTotIpi   	:= 0
Local nTotSt    	:= 0




// Claudino - 08/12/15
Local _aTotImp      := {}

/* Rgras de negocios

U_FSEA040(cNumSUA, cNumSC5)

*/
//TRATAMENTO PARA LOTES UNICOS - B4B.AL07092016
If SUA->UA_OPER == "1"
	U_B4BAVLOT(cFilSC5,cNumSC5)
EndIf
//--FIM

dbSelectArea("SA1")
dbSetOrder(1)

IF MsSeek(xFilial("SA1")+M->UA_CLIENTE+M->UA_LOJA)
	
	_cBco := SA1->A1_BCO1
	
ENDIF

dbSelectArea("SC5")
dbSetOrder(1)

MsSeek(xFilial("SC5")+SUA->UA_NUMSC5)

dbSelectArea("SC6")
dbSetOrder(1)

IF MsSeek(xFilial("SC6")+SUA->UA_NUMSC5)
	
	While !EOF() .AND. SC6->C6_NUM == SUA->UA_NUMSC5  .AND. SC6->C6_FILIAL == xFilial("SC6") // CURITIBA
		
		dbSelectArea("SB1")
		dbSetOrder(1)
		
		If MsSeek(xFilial("SB1")+SC6->C6_PRODUTO)
			
			RecLock( "SC6", .F. )
			
			SC6->C6_CUSTD := SB1->B1_CUSTD
			
			If ! SC5->C5_TIPO $ [ICP] .And. ! SC6->C6_TES $ [502.503.510.523]
			      _nMargem := SC6->C6_PRCVEN
 			      _nMargem /= SC6->C6_CUSTD
			      _nMargem -= 1
			      _nMargem *= 100
			      _nMargem := Round( _nMargem / 3, 2 )

		    Else

      			_nMargem := 0

		    End
   	
		    _nMargem := IIF(_nMargem > 999.99,999.99,_nMargem) 
   			
   			SC6->C6_MARGEM := _nMargem
   			
   			If SUA->UA_FILIAL $ ("01/06")
   				If Localiza(SC6->C6_PRODUTO) //Se o Produto controla endereço
					//	RecLock('SC6',.F.) //Alterar o registro na tabela de itens.
					// Claudino - 04/04/16 - I1603-1514
					If Empty(SC6->C6_LOCALIZ) 
						SC6->C6_SERVIC := "001"
						SC6->C6_ENDPAD := PADR("DOCA",15)
					Endif
					//SC6->C6_TPESTR := "000001"
			  		//	MsUnlock() 
				EndIf
   			EndIF
   			If Substr( SC6->C6_CF, 2, 3 ) $ '910' // Caso bonificaçao --> zerar a comissao 
   				Replace SC6->C6_COMIS1 With 0  	  
    			Replace SC6->C6_VLCOM1 With 0
    			lBonif := .T. 
   			Else
   				lBonif := .F.
   			EndIf
   			
   			MsUnlock()
		EndIf
		
		nTotPV    += SC6->C6_VALOR  // transpo frete 
		_TotVen   += SC6->C6_VALOR
	   	_TotCus   += ( SC6->C6_CUSTD * SC6->C6_QTDVEN )
	   	_TotComis += SC6->C6_VLCOM1

		dbSelectArea("SC6")
		dbSkip()
	EndDo

EndIf

// TranpoFrete 25/05/2020

nTotIpi 		:= MaFisRet(,"NF_VALIPI") 
nTotSt  		:= MaFisRet(,"NF_VALSOL")

/*
Claudino - 08/12/15
MaFisNFCab - Retorna um array contendo todos os impostos calculados na MATXFIS no 
             momento da chamada da função com quebra por impostos + alíquotas
*/
_aTotImp := MaFisNFCab()

_TotVen  := _TotVen - IIF(ASCAN(_aTotImp,{|x|x[1] == "ICM" }) == 0, 0,_aTotImp[ASCAN(_aTotImp,{|x|x[1] == "ICM" })][5]) - ;
                      IIF(ASCAN(_aTotImp,{|x|x[1] == "PS2" }) == 0, 0,_aTotImp[ASCAN(_aTotImp,{|x|x[1] == "PS2" })][5]) - ;
                      IIF(ASCAN(_aTotImp,{|x|x[1] == "CF2" }) == 0, 0,_aTotImp[ASCAN(_aTotImp,{|x|x[1] == "CF2" })][5])

//_Margem := Round( ( ( _TotVen  / ( _TotCus + _ValBall ) ) -1 ) * 100, 0 )
_Margem := Round( ( ( _TotCus  / _TotVen ) -1 ) * 100, 2)
_Margem *= -1
_Margem /= 4
_MarLiq := Round (( _TotCus / _TotVen ) * 100, 2)

dbSelectArea("SC5")
dbSetOrder(1)

If MsSeek(xFilial("SC5")+SUA->UA_NUMSC5)

/*BEGINDOC
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Gera Cubagem do pedido                ³
//³Campo especifico C5_XCUBPED           ³
//³ WAR 23/05/2013                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ENDDOC*/
    
	If Select("CUB") > 0
		DbSelectArea("CUB")
		CUB->(DbCloseArea())
	EndIf

	_cQuery := " SELECT SUM((SB5.B5_COMPR * SB5.B5_ALTURA * SB5.B5_LARG)* (C6_QTDVEN)) As CubPed "
	_cQuery += " FROM " + RetSqlName("SC6") + " SC6 "
	_cQuery += " INNER JOIN " + RetSqlName("SB1") + " SB1 ON SC6.C6_PRODUTO = SB1.B1_COD "
	_cQuery += " INNER JOIN " + RetSqlName("SB5") + " SB5 ON SC6.C6_PRODUTO = SB5.B5_COD "
	_cQuery += " WHERE SC6.D_E_L_E_T_ <> '*' AND " 
	_cQuery += " SB5.D_E_L_E_T_ <> '*' AND "
	_cQuery += " SB1.D_E_L_E_T_ <> '*' AND " 
	_cQuery += " SC6.C6_FILIAL  = '" + SUA->UA_FILIAL  + "' AND "
	_cQuery += " SC6.C6_CLI     = '" + SUA->UA_CLIENTE + "' AND "
	_cQuery += " SC6.C6_LOJA    = '" + SUA->UA_LOJA    + "' AND " 
	_cQuery += " SC6.C6_NUM     = '" + SUA->UA_NUMSC5  + "' AND " 
	_cQuery += " SC6.C6_FILIAL  = '" + xFilial("SC6")  + "' AND "
	_cQuery += " SB5.B5_FILIAL  = '" + xFilial("SB5")  + "' AND "
	_cQuery += " SB1.B1_FILIAL  = '" + xFilial("SB1")  + "' AND "
	_cQuery += " SB5.B5_FILIAL  = '" + xFilial("SB5")  + "' AND "
	_cQuery += " SB1.B1_FILIAL  = '" + xFilial("SB1") + "' "
	
	//MEMOWRITE("E:\TESTESQL3.SQL",_cQuery)
      
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,_cQuery), 'CUB' )
    
    _nCPed := CUB->CubPed
    
    CUB->(DbCloseArea())
    
/*BEGINDOC
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Gera Peso Liquido e Bruto             ³
//³Campos C5_PBRUTO/C5_PESOL             ³
//³WAR 16/07/2013                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ENDDOC*/

	If Select("PESO") > 0
		DbSelectArea("PESO")
		PESO->(DbCloseArea())
	EndIf

	_cQuery := " SELECT SUM(SB1.B1_PESBRU * C6_QTDVEN) As PBRUTO "
	_cQuery += " FROM " + RetSqlName("SC6") + " SC6 "
	_cQuery += " INNER JOIN " + RetSqlName("SB1") + " SB1 ON SC6.C6_PRODUTO = SB1.B1_COD "
	_cQuery += " WHERE SC6.D_E_L_E_T_ <> '*' AND SB1.D_E_L_E_T_ <> '*' AND " 
	_cQuery += " SC6.C6_FILIAL  = '" + SUA->UA_FILIAL  + "' AND "
	_cQuery += " SC6.C6_CLI     = '" + SUA->UA_CLIENTE + "' AND "
	_cQuery += " SC6.C6_LOJA    = '" + SUA->UA_LOJA    + "' AND " 
	_cQuery += " SC6.C6_NUM     = '" + SUA->UA_NUMSC5  + "' AND " 
	_cQuery += " SB1.B1_FILIAL  = '" + xFilial("SB1")  + "' "
	_cQuery += " GROUP BY SC6.C6_NUM "

	//MEMOWRITE("E:\TESTESQL3.SQL",_cQuery)
      
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,_cQuery), 'PESO' )
    
    _nPBruto := PESO->PBRUTO
    
    PESO->(DbCloseArea())   
	  
	_cQuery := " SELECT SUM(SB1.B1_PESO * C6_QTDVEN) As PESOL "
	_cQuery += " FROM " + RetSqlName("SC6") + " SC6 "
	_cQuery += " INNER JOIN " + RetSqlName("SB1") + " SB1 ON SC6.C6_PRODUTO = SB1.B1_COD "
	_cQuery += " WHERE SC6.D_E_L_E_T_ <> '*' AND SB1.D_E_L_E_T_ <> '*' AND " 
	_cQuery += " SC6.C6_FILIAL  = '" + SUA->UA_FILIAL  + "' AND "
	_cQuery += " SC6.C6_CLI     = '" + SUA->UA_CLIENTE + "' AND "
	_cQuery += " SC6.C6_LOJA    = '" + SUA->UA_LOJA    + "' AND " 
	_cQuery += " SC6.C6_NUM     = '" + SUA->UA_NUMSC5  + "' AND " 
	_cQuery += " SB1.B1_FILIAL  = '" + xFilial("SB1")  + "' "
	_cQuery += " GROUP BY SC6.C6_NUM "

	//MEMOWRITE("E:\TESTESQL3.SQL",_cQuery)
      
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,_cQuery), 'PESO' )
    
    _nPesoL := PESO->PESOL
	
	PESO->(DbCloseArea())
    
    RecLock( "SC5", .F. )
	
	Replace SC5->C5_XCUBAGM With _nCPed
	Replace SC5->C5_PESOL   With _nPesoL 
	Replace SC5->C5_PBRUTO  With _nPBruto

	SC5->C5_BANCO		:=  _cBco
	
	If SUA->UA_TABELA = "900"
		SC5->C5_ORCAM		:=  "O"
	Else
		SC5->C5_ORCAM		:=  "P"
	EndIf
	
	SC5->C5_TOTVEN  := _TotVen
	SC5->C5_TOTCUS  := IIF(_TotCus > 999999.99999,999999.99999,_TotCus) // Claudino 16/05/16 - I1604-2102
	SC5->C5_VALBALL := _ValBall
	//SC5->C5_TOTMAR  := Round( _Margem / 3, 2 ) 
	SC5->C5_TOTMAR  := _Margem 
	SC5->C5_MARLIQ  := _MarLiq
	
	SC5->C5_TOTCOM  := _TotComis
	
	SC5->C5_TIPENT  := SUA->UA_TIPOENT
	SC5->C5_CDPG    := SUA->UA_FORMPAG
	SC5->C5_TIPOCLI := SUA->UA_TIPOCLI 
	SC5->C5_PEDREP  := USRRETNAME( RETCODUSR() )
	SC5->C5_AVISO   := SUA->UA_AVISO
	SC5->C5_XAVISO   := SUA->UA_XAVISO // Incluído por Gilson Belini em 19/04/2018 --- Conhecimento da utilização da rotina nesta data.
	SC5->C5_TIPLIB  := "2"
	SC5->C5_XPEDCOM := SUA->UA_XPEDCOM
	SC5->C5_TESINT  := SUA->UA_TESINT
	
	// Reset C5_REIMP caso Nosso Carro (C5_TIPOENT = 2) 
	SC5->C5_REIMP := IIF (SC5->C5_TIPENT == "2",0,SC5->C5_REIMP) 	
	
	If SUA->UA_FILIAL $ ("01/06") 
		dbSelectarea("SC6")
		SC6->(dbSetOrder(1))
		// Claudino - 04/04/16 - I1603-1514
		If MsSeek(xFilial("SC6")+SUA->UA_NUMSC5)
			If Empty(SC6->C6_LOCALIZ)  
				SC5->C5_TPCARGA := "1"
   				SC5->C5_GERAWMS := "2"
	        EndIf
	    EndIf
	EndIf
	If lBonif
		Replace SC5->C5_COMIS1 with 0 // Caso bonificaçao --> Zerar a comissao	
	EndIf
	
	SC5->C5_XASSIST := GetAdvFVal("SA3","A3_XASSIST",xFilial("SA3")+SUA->UA_VEND,1,"")  // Claudino - 29/02/16
	
	SC5->C5_XTOTPV 	:= nTotPV + nTotIpi + nTotSt  //Transpofrete 25/05/2020
	
	MsUnlock()
	
	// Claudino - 29/02/16
	RecLock( "SUA", .F. )
		SUA->UA_XASSIST := GetAdvFVal("SA3","A3_XASSIST",xFilial("SA3")+SUA->UA_VEND,1,"")
	MsUnlock()
	
	// Enviar WORKFLOW caso retira -- UA_TIPOENT == "1" 
	If (SUA->UA_TIPOENT == "1")
		
		oProcess:= TWFProcess():New("Retira","Pedido de Retira")
		oProcess:NewTask("Inicio","\WORKFLOW\Retira.htm")
		oProcess:cSubject := "PEDIDO DE RETIRA" + Alltrim(SM0->M0_NOME) + '/' +Alltrim(SM0->M0_FILIAL) 
    	
    	oHTML := oProcess:oHTML
    	oHTML:ValByName('DATA',dDataBase)
    	oHTML:ValByName('PEDIDO',SC5->C5_NUM)
		oHTML:ValByName('CLIENTE',SC5->C5_CLIENTE +'/'+ SC5->C5_LOJACLI + ' ' + SA1->A1_NOME) 
    	oHTML:ValByName('TOTAL',_TotVen)
    	
    	oProcess:cTo := U_GrpEmail('Retira') 
		
		If ! Empty(oProcess:cTo) 
			oProcess:Start()
			oProcess:Finish()
	    EndIf
	
	EndIf  
	
/*BEGINDOC
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Tratamento da Classificaçao Fiscal SUB³
//³Campo especifico UB_CLASFIS           ³
//³Caso a o campo UB_CLSFIS tem conteudo,³
//³copia o mesmo para o campo C6_CLASFIS ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ENDDOC*/
	
	DbSelectarea("SC6")
	DbSetorder(1)

	If DbSeek(xFilial("SC6")+SUA->UA_NUMSC5,.T.)
		While !Eof() .And. (xFilial("SC6")+SUA->UA_NUMSC5 == SC6->C6_FILIAL+SC6->C6_NUM) 
			If SUB->(DbSeek(xFilial("SC6")+SUA->UA_NUM+SC6->C6_ITEM+SC6->C6_PRODUTO,.T.))
				If (SUB->UB_ITEM+SUB->UB_PRODUTO == SC6->C6_ITEM+SC6->C6_PRODUTO) 	
					Reclock( "SC6" ,.F.,.T.)
	    			If !Empty(SUB->UB_CLASFIS) 
	    				REPLACE SC6->C6_CLASFIS WITH SUB->UB_CLASFIS
	    			EndIf 
	    			REPLACE SC6->C6_UDESC   WITH SUB->UB_UDESC 
	    			REPLACE SC6->C6_ITEMPC  WITH SUB->UB_ITEMPC
	    			REPLACE SC6->C6_NUMPCOM WITH SUB->UB_NUMPCOM
					SC6->(MsUnLock())
				EndIf
            EndIf
			SC6->(DbSkip())
		EndDo			
	EndIf

EndIf

//Rotina Triyo pra gravação do total do pedido
//fTotPed()

RestArea(_aAreaSUA)
RestArea(_aAreaSUB)
RestArea(_aAreaSC5)
RestArea(_aAreaSC6)

RETURN()

//----------------------------------------------------------------
/*/{Protheus.doc} fTotPed
Gravação do total do pedido de venda.

@author Henrique Ghidini
@since 12/05/2020
@version 1.0
/*/
//----------------------------------------------------------------
/*
Static Function fTotPed()

Local nTotVen   := 0
Local nValIpi   := 0
Local nValST    := 0
Local nItem     := 1
Local nTotIpi   := 0
Local nTotSt    := 0

    DbSelectArea("SC5")
	SC5->(DbSetOrder(1))
	
	DbSelectArea("SC6")
    SC6->(DbSetOrder(1))

	If SC5->(DbSeek(xFilial("SC5") + SUA->UA_NUMSC5))
    
		If SC6->(DbSeek(xFilial("SC6")+SC5->C5_NUM))
			
			While !SC6->(EOF()) .AND. SC6->(C6_FILIAL+C6_NUM) == SC5->(C5_FILIAL+C5_NUM)

				nTotVen += SC6->C6_VALOR

				MaFisIni(SC5->C5_CLIENTE,SC5->C5_LOJACLI,"C","N",SC5->C5_TIPOCLI,MaFisRelImp("MTR700",{"SC5","SC6"}),,,"SB1","MTR700")
				MaFisAdd(SC6->C6_PRODUTO,SC6->C6_TES,SC6->C6_QTDVEN,SC6->C6_PRCVEN,SC6->C6_VALDESC,"","",0,0,0,0,0,(SC6->C6_QTDVEN*SC6->C6_PRCVEN),0,0,0)
				
				nValIpi := MaFisRet(nItem,"IT_VALIPI")
				nValST  := MaFisRet(nItem,"IT_VALSOL")
				
				MaFisLoad("IT_VALIPI"	, nValIpi	, nItem)
				MaFisLoad("IT_VALSOL"	, nValST	, nItem)

				nTotIpi += nValIpi
				nTotSt  += nValST

				nItem++
				
				SC6->(DbSkip())

			End

			MaFisEnd()

			SC5->(RecLock("SC5",.F.))

				SC5->C5_XTOTPV := nTotVen + nTotIpi + nTotSt

			SC5->(MsUnlock())

		EndIf

	EndIf
    
Return()

*/