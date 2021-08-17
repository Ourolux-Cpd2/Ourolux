#Include "rwmake.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ MTA410T  ³ 						        ³ Data ³14/11/2008³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ponto de entrada PARA TODOS OS ITENS DO PEDIDO DE VENDA                ³±±
±±³ Chamado na Inclusao/Alteraçao/liberaço manual/liberaçao auto          ³±±
±±³	de pedido de venda      											  ³±±
±±³																		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ AP8                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±³Alteracoes efetuadas apos a implantacao                                ³±±
±±³Autor     ³ Data     ³ Descricao                                       ³±±
±±³																		  ³±±
±±³          ³SC5 POSOCIONADOS                                            ³±± 
±±³          ³SC6 POSOCIONADOS no ultimo item do pedido                   ³±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function MTA410T()

Local i,n,cProc
Local aArea		:= GetArea()
Local aAreaSC6	:= SC6->(GetArea())
Local aAreaSB1  := SB1->(GetArea())
Local nDecs		:= TamSx3("C6_VLCOM1")[2]
Local nComis	:= 0
Local cTes      := SuperGetMv("FS_ELE009")
Local nRecnoC6  := SC6->(RecNo())
Local _cQuery   := ''
Local _nCPed	:= 0
Local _nPesoL   := 0
Local _nPBruto  := 0

// Claudino - 09/12/15
Local _aTotImp  := {}

If INCLUI //Gravacao do campo MEMO Virtual - C5_XMSGNF - INCLUIR - Marcelo Ethosx

	_nTam := TamSX3("C5_XMSGNF") //Campo Memo
	_nTam1 := _nTam[1]
	MSMM(,_nTam1,,M->C5_XMSGNF,1,,,"SC5","C5_XCODMNF") 

ElseIf ALTERA //Gravacao do campo MEMO Virtual - C5_XMSGNF - ALTERAR - Marcelo Ethosx

	_nTam := TamSX3("C5_XMSGNF") //Campo Memo
	_nTam1 := _nTam[1]
	
	If Empty(SC5->C5_XCODMNF) // Inclusao
		MSMM(,_nTam1,,M->C5_XMSGNF,1,,,"SC5","C5_XCODMNF") 
	Else // Alteracao
		MSMM(SC5->C5_XCODMNF,_nTam1,,M->C5_XMSGNF,1,,,"SC5","C5_XCODMNF")
	Endif

EndIF

MaFisIni(SC5->C5_CLIENTE,SC5->C5_LOJACLI,"C","N",SC5->C5_TIPOCLI,MaFisRelImp("MTR700",{"SC5","SC6"}),,,"SB1","MTR700") // Claudino - 09/12/15

// Implementacao para tratar as importacoes de Pedidos via SFA
If Type("L410Auto")!="U" .And. L410Auto
	Return (.T.)
EndIf

For n := 1 To 8
	cProc := ProcName( n )
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄI
	//³Liberaçao de pedidos: Rotina manual/automatica  ³
	//³WAR 14-11-2008                                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄI
	If cProc $ 'A440LIBERA.A440AUTOMA'
		RecLock( 'SC5', .F. )
        SC5->C5_LIBCP := 'S'
       	SC5->C5_REIMP := 0 
	    SC5->( MSUnLock() )
        
        //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄI
		//³Bloquei o pedido caso bonificaço                ³
		//³WAR 14-11-2008                                  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄI
        
        If U_IsPedBonif(SC5->C5_NUM) .Or. At( 'vale', SC5->C5_AVISO ) <> 0 
        	If cFilAnt <> "04"
           		U_TrataTabSC9(1,SC5->C5_NUM)
           	EndIf 
		End
        
       Return( NIL )
    EndIf   
Next

/* // MOA - 10/10/2018  -  TESTE HOMOLOGAÇÃO
If ! M->C5_TIPO $[TN]
	Return( NIL )
EndIf
*/
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄI
//³Gera comissao por item                          ³
//³WAR 14-11-2008                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄI
/* Rgras de negocios
If (M->C5_TIPO == 'N')

	While (SC6->C6_NUM == SC5->C5_NUM) .And. !(SubString(SC6->C6_PEDCLI,1,3) == 'TMK' ) .And.;
  	      (xFilial("SC6") == SC6->C6_FILIAL) .And. !SC6->(BOF()) 
    
        // Verifica se existe uma tabela de valores x comissoes e 
       	// calcula o percentual de comissao do vendedor para o produto.
      
    	If U_GetComis(SC5->C5_VEND1, SC5->C5_TABELA, SC6->C6_PRODUTO, SC6->C6_PRCVEN, @nComis) .And.;
    	   SC6->C6_TES $ cTes 
    		Reclock("SC6",.F.)
    		Replace SC6->C6_COMIS1 With nComis  	  
    		Replace SC6->C6_VLCOM1 With Round( ((nComis/100) * SC6->C6_VALOR ) ,nDecs)
       		MsUnlock()
    	EndIf
    	DbSkip(-1)
      
    End		

EndIf
*/

_Pedido   := SC5->C5_NUM
_TotVen   := 0
_TotCus   := 0
_Margem   := 0
_Comissao := 0
_Vend2    := SC5->C5_Vend2
_ValBalL  := 0
_TotComis := 0
_MarLiq   := 0

SB1->(dbSetOrder(1))
SC6->(dbGoTo(nRecnoC6))

While SC6->C6_NUM    == _Pedido .And.;
	  SC6->C6_FILIAL == xFilial("SC6") .And.;
	  !SC6->(BOF()) 
      
	SB1->( dbSeek( xfilial("SB1") + SC6->C6_PRODUTO, .F. ) )
 	RecLock( "SC6", .F. )
   	SC6->C6_CUSTD := SB1->B1_CUSTD 

	If !M->C5_TIPO $ [ICP] .And. !SC6->C6_TES $ [502.503.510.523]
 		_nMargem := SC6->C6_PRCVEN
      	_nMargem /= SC6->C6_CUSTD
      	_nMargem -= 1
      	_nMargem *= 100
    	_nMargem := Round( _nMargem / 3, 2 )
   	Else
		_nMargem := 0
   	EndIf

	_nMargem := If(_nMargem > 999.99,999.99,_nMargem)
   	SC6->C6_MARGEM := _nMargem
   	SC6->( MsUnlock() )
   	_TotVen   += SC6->C6_VALOR
   	_TotCus   += ( SC6->C6_CUSTD * SC6->C6_QTDVEN )
   	_TotComis += SC6->C6_VLCOM1
   
	// Todo Bloco Abaixo - Claudino - 09/12/15
	******************************************  
	MaFisAdd( SC6->C6_PRODUTO,;
	SC6->C6_TES,;
	SC6->C6_QTDVEN,;
	SC6->C6_PRUNIT,;
	SC6->C6_VALDESC,;
	"",;
	"",;
	0,;
	0,;
	0,;
	0,;
	0,;
	(SC6->C6_QTDVEN*SC6->C6_PRUNIT),;
	0,;
	0,;
	0)                                                     
	*******************************************

	SC6->(dbSkip(-1))

End

/*
Claudino - 09/12/15
MaFisNFCab - Retorna um array contendo todos os impostos calculados na MATXFIS no 
             momento da chamada da funcao com quebra por impostos + aliquotas
*/
_aTotImp := MaFisNFCab()

_TotVen  := _TotVen - IIF(ASCAN(_aTotImp,{|x|x[1] == "ICM" }) == 0, 0,_aTotImp[ASCAN(_aTotImp,{|x|x[1] == "ICM" })][5]) - ;
                      IIF(ASCAN(_aTotImp,{|x|x[1] == "PS2" }) == 0, 0,_aTotImp[ASCAN(_aTotImp,{|x|x[1] == "PS2" })][5]) - ;
                      IIF(ASCAN(_aTotImp,{|x|x[1] == "CF2" }) == 0, 0,_aTotImp[ASCAN(_aTotImp,{|x|x[1] == "CF2" })][5])

//_Margem := Round( ( ( _TotVen  / ( _TotCus + _ValBall ) ) -1 ) * 100, 0 )
_Margem := Round( ( ( _TotCus / _TotVen  ) -1 ) * 100, 2 ) 
_Margem *= -1
_Margem /= 4
_MarLiq := Round( ( _TotCus / _TotVen ) * 100, 2 ) 
 
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

If (INCLUI .OR. ALTERA) .And. SC5->C5_XCUBAGM == 0  

	_cQuery := " SELECT SUM((SB5.B5_COMPR * SB5.B5_ALTURA * SB5.B5_LARG)* (C6_QTDVEN)) As CubPed "
	_cQuery += " FROM " + RetSqlName("SC6") + " SC6 "
	_cQuery += " INNER JOIN " + RetSqlName("SB1") + " SB1 ON SC6.C6_PRODUTO = SB1.B1_COD "
	_cQuery += " INNER JOIN " + RetSqlName("SB5") + " SB5 ON SC6.C6_PRODUTO = SB5.B5_COD "
	_cQuery += " WHERE SC6.D_E_L_E_T_ <> '*' AND SB5.D_E_L_E_T_ <> '*' AND SB1.D_E_L_E_T_ <> '*' AND "
	_cQuery += " SC6.C6_FILIAL  = '" + SC5->C5_FILIAL  + "' AND "
	_cQuery += " SC6.C6_CLI     = '" + SC5->C5_CLIENTE + "' AND "
	_cQuery += " SC6.C6_LOJA    = '" + SC5->C5_LOJACLI + "' AND " 
	_cQuery += " SC6.C6_NUM     = '" + SC5->C5_NUM     + "' AND " 
	_cQuery += " SC6.C6_FILIAL  = '" + xFilial("SC6")  + "' AND "
	_cQuery += " SB5.B5_FILIAL  = '" + xFilial("SB5") + "'  AND "
	_cQuery += " SB1.B1_FILIAL = '" + xFilial("SB1") + "' "
	
	//MEMOWRITE("E:\TESTESQL3.SQL",_cQuery)
      
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,_cQuery), 'CUB' )
    
	_nCPed := CUB->CubPed
    
	CUB->(DbCloseArea())

EndIf	

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
    
If (INCLUI .OR. ALTERA) .And. SC5->C5_PBRUTO == 0
	
	_cQuery := " SELECT SUM(SB1.B1_PESBRU * C6_QTDVEN) As PBRUTO "
	_cQuery += " FROM " + RetSqlName("SC6") + " SC6 "
	_cQuery += " INNER JOIN " + RetSqlName("SB1") + " SB1 ON SC6.C6_PRODUTO = SB1.B1_COD "
	_cQuery += " WHERE SC6.D_E_L_E_T_ <> '*' AND SB1.D_E_L_E_T_ <> '*' AND " 
	_cQuery += " SC6.C6_FILIAL  = '" + SC5->C5_FILIAL  + "' AND "
	_cQuery += " SC6.C6_CLI     = '" + SC5->C5_CLIENTE + "' AND "
	_cQuery += " SC6.C6_LOJA    = '" + SC5->C5_LOJACLI + "' AND " 
	_cQuery += " SC6.C6_NUM     = '" + SC5->C5_NUM     + "' AND " 
	_cQuery += " SB1.B1_FILIAL  = '" + xFilial("SB1")  + "' "
	_cQuery += " GROUP BY SC6.C6_NUM "

	//MEMOWRITE("E:\TESTESQL3.SQL",_cQuery)
      
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,_cQuery), 'PESO' )
    
    _nPBruto := PESO->PBRUTO
    
    PESO->(DbCloseArea())   

EndIf	  

If (INCLUI .OR. ALTERA) .And. SC5->C5_PESOL == 0
	
	_cQuery := " SELECT SUM(SB1.B1_PESO * C6_QTDVEN) As PESOL "
	_cQuery += " FROM " + RetSqlName("SC6") + " SC6 "
	_cQuery += " INNER JOIN " + RetSqlName("SB1") + " SB1 ON SC6.C6_PRODUTO = SB1.B1_COD "
	_cQuery += " WHERE SC6.D_E_L_E_T_ <> '*' AND SB1.D_E_L_E_T_ <> '*' AND " 
	_cQuery += " SC6.C6_FILIAL  = '" + SC5->C5_FILIAL  + "' AND "
	_cQuery += " SC6.C6_CLI     = '" + SC5->C5_CLIENTE + "' AND "
	_cQuery += " SC6.C6_LOJA    = '" + SC5->C5_LOJACLI + "' AND " 
	_cQuery += " SC6.C6_NUM     = '" + SC5->C5_NUM     + "' AND " 
	_cQuery += " SB1.B1_FILIAL  = '" + xFilial("SB1")  + "' "
	_cQuery += " AND SB1.B1_FILIAL = '" + xFilial("SB1") + "' "
	_cQuery += " GROUP BY SC6.C6_NUM "

	//MEMOWRITE("E:\TESTESQL3.SQL",_cQuery)
      
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,_cQuery), 'PESO' )
    
    _nPesoL := PESO->PESOL
	
	PESO->(DbCloseArea())
	
EndIf

RecLock( "SC5", .F. )

	SC5->C5_XCUBAGM := IIF(SC5->C5_XCUBAGM     == 0,_nCPed,SC5->C5_XCUBAGM) 
	SC5->C5_PESOL  	:= IIF(SC5->C5_PESOL  == 0,_nPesoL,SC5->C5_PESOL)
	SC5->C5_PBRUTO  := IIF(SC5->C5_PBRUTO == 0,_nPBruto,SC5->C5_PBRUTO)
	
	SC5->C5_TOTVEN  := _TotVen
	SC5->C5_TOTCUS  := _TotCus
	SC5->C5_VALBALL := _ValBall
	SC5->C5_TOTMAR  := _Margem 
	SC5->C5_MARLIQ  := _MarLiq
	SC5->C5_TOTCOM  := _TotComis

SC5->( MsUnlock() )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄI
//³Bloquei o pedido caso bonificaçao               ³
//³Liberaçao automatico de pedido (F12)            ³
//³WAR 14-11-2008                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄI

If U_IsPedBonif(SC5->C5_NUM) .Or. At('vale', SC5->C5_AVISO ) <> 0
   
   If cFilAnt <> "04"
		U_TrataTabSC9(1,SC5->C5_NUM)
    EndIf 

End

MaFisEnd() // Claudino - 09/12/15

RestArea(aAreaSB1) 
RestArea(aAreaSC6)
RestArea(aArea)

Return( Nil )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ TrataTabSC9(cOper,cNumPed)  ³ 			³ Data ³14/11/2008³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Usado para bloquear/liberar arquivo SC9                                ³±±
±±³cOper = '1' -> bloquear, cOper = '2' -> liberar                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ AP8                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±³Alteracoes efetuadas apos a implantacao                                ³±±
±±³Autor     ³ Data     ³ Descricao                                       ³±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function TrataTabSC9(cOper,cNumPed)
/*
Local aArea     := GetArea()
Local aAreaSC9  := SC9->(GetArea())

DbSelectArea("SC9")
DbSetOrder(1)
  	
If MsSeek(xFilial("SC9") + cNumPed)
  	
	While (SC9->C9_PEDIDO == cNumPed) .And.;
		  (xFilial("SC9") == SC9->C9_FILIAL)
    
    	RecLock('SC9', .F.)
   		
   		If cOper == 1
   			C9_BLCRED := '01'
        	C9_BLEST  := '02'
   		ElseIf cOper == 2 
   			C9_BLCRED := ' '
	        C9_BLEST  := ' '
   		EndIf
   		
   		MSUnLock()
   		DbSkip()
    
    End

EndIf

RestArea(aAreaSC9) 
RestArea(aArea)
*/
Return (NIL)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ IsPedBonif()  ³ 					        ³ Data ³14/11/2008³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Verifique se o pedido e de bonificaçao (cfop = 910)                    ³±±
±±³ Retrono: .T./.F.                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ AP8                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±³Alteracoes efetuadas apos a implantacao                                ³±±
±±³Autor     ³ Data     ³ Descricao                                       ³±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function IsPedBonif(cNumPed)
Local lRet 		:= .F.
Local aArea     := GetArea()
Local aAreaSC6  := SC6->(GetArea())

DbSelectArea("SC6")
DbSetOrder(1)
  	
If MsSeek(xFilial("SC6") + cNumPed)
  	
	While (SC6->C6_NUM == cNumPed) .And. (xFilial("SC6") == SC6->C6_FILIAL)
    
    	If (Substr( SC6->C6_CF, 2, 3 ) $ '910')
        	lRet := .T.
        	Exit
        EndIf
        DbSkip()
    
    End

EndIf

RestArea(aAreaSC6) 
RestArea(aArea)
Return(lRet)