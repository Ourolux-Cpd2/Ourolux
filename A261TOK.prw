#Include "Rwmake.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณA261TOK   บ Autor ณ Andre Bagatini     บ Data ณ  28/03/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Programa para validar se o produto de origem ้ igual ao de บฑฑ
ฑฑบ          ณ destino, se nใo for... lRet := .F.                         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Estoque/Custos                                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

User Function A261TOK( )

Local lRet 			:= .T.
Local aArea	   	    := GetArea()
Local _PosProdOri   := aScan(aHeader,{ |x| Upper(AllTrim(x[1])) == "PROD.ORIG." }) 
Local _PosProdDest  := aScan(aHeader,{ |x| Upper(AllTrim(x[1])) == "PROD.DESTINO" })
Local _PosAlmxDest  := aScan(aHeader,{ |x| Upper(AllTrim(x[1])) == "ARMAZEM DESTINO" })
Local _PosAlmxOri   := aScan(aHeader,{ |x| Upper(AllTrim(x[1])) == "ARMAZEM ORIG." }) 
Local _PosQuant     := aScan(aHeader,{ |x| Upper(AllTrim(x[1])) == "QUANTIDADE" }) 
//Local _PosEndOri    := aScan(aHeader,{ |x| Upper(AllTrim(x[1])) == "ENDERECO ORIG." })

Local _mvcq         := GetNewPar("MV_CQ","")
Local nI            := 0
Local _lRastro      := .F.
Local aTamSB8       := TamSX3('B8_SALDO')
Local nSldSB2       := 0
Local cQuery        := ""
Local cAliasSB8     := ""
Local cNomeUsr  	:= Upper(Rtrim(cUserName)) 
Local nSldSB2 		:= 0

If !(cNomeUsr $ 'LOGISTICA.GERENCIAGRU.ADMINISTRADOR.ROBERTO')
	For nI:=1 TO Len(aCols)
		If !aCols[nI][Len(aHeader)+1]  
			If AllTrim(aCols[nI][_PosProdOri]) <> AllTrim(aCols[nI][_PosProdDest])
				lRet := .F.
				ApMsgStop('Produto de Origem nใo Pode ser Diferente do Destino !','A261TOK')
				Exit			
			EndIf
		EndIf
	Next nI
EndIf    
    
If lRet
	For nI:=1 TO Len(aCols)
		If !aCols[nI][Len(aHeader)+1]  
			If AllTrim(aCols[nI][_PosAlmxDest]) == _mvcq 
				lRet := .F.
				ApMsgStop('Operea็ao nao permitida: Almoxarifado utilizado para o Controle de Qualidade !','A261TOK')
				Exit			
			EndIf
		EndIf
	Next nI
EndIf

If lRet
   	For nI:=1 TO Len(aCols)
		If !aCols[nI][Len(aHeader)+1]  
			lRastro   := Rastro(aCols[nI][_PosProdOri])
			If lRastro
					
				If Select('cAliasSB8') > 0
					DbSelectArea('cAliasSB8')
					cAliasSB8->(DbCloseArea())
				EndIf
				   
				cQuery := "SELECT SUM (B8_SALDO) B8_SALDO  "
				cQuery +=   "FROM " + RetSqlName("SB8") + " SB8 "
				cQuery +=  "WHERE SB8.B8_FILIAL = '"      + xFilial('SD3') + "' AND "
				cQuery +=       " SB8.B8_PRODUTO = '"     + aCols[nI][_PosProdOri]    + "' AND "
				cQuery +=       " SB8.B8_LOCAL = '"       + aCols[nI][_PosAlmxOri]  + "' AND "
				cQuery +=       " SB8.D_E_L_E_T_ = ' ' "	
				cQuery:=ChangeQuery(cQuery)
				dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),'cAliasSB8')
				TcSetField( 'cAliasSB8', "B8_SALDO","N", aTamSB8[1],aTamSB8[2] )	
				
				dbSelectArea('cAliasSB8')
				
				nSldSB2 := GetAdvFVal("SB2","B2_QATU",xFilial("SB2")+aCols[nI][_PosProdOri]+aCols[nI][_PosAlmxOri],1,0)
				
				If nSldSB2 < cAliasSB8->(B8_SALDO)
					lRet := .F.
					ApMsgStop('Operea็ao nao permitida: Saldo Fisico X Saldo por Lote esta divergente!','A261TOK')
					Exit			
				EndIf
			EndIf
		EndIf
	Next nI
EndIf

If lRet .And. !U_IsAdm()
	
	For nI:=1 TO Len(aCols)
			
		If !aCols[nI][Len(aHeader)+1] 
			
			If SB2->( dbSeek( xFilial( 'SB2' ) + aCols[nI][_PosProdOri] + aCols[nI][_PosAlmxOri] )) 
					
					nSldSB2 := SaldoSB2(.F.,.T.,,.F.,.F.,,,,.T.) - ABS(SB2->B2_QPEDVEN) 
						
					If ABS(SB2->B2_QPEDVEN) + ABS(SB2->B2_RESERVA) > SB2->B2_QATU   //SB2->B2_QPEDVEN < 0 .Or. SB2->B2_RESERVA < 0
							
						lRet := .F.
						ApMsgStop( 'Produto c/ divergencia de saldo. Favor entrar em contato com TI! ' + Alltrim( aCols[nI][_PosProdOri] )+ ' ( ' +  Alltrim( Transform(nSldSB2,'@E 999,999,999.99') ) + ' )', 'A261TOK' )			
						Exit
						
					ElseIf aCols[nI][_PosQuant] > nSldSB2 
						
						If Localiza(aCols[nI,_PosProdOri]) 
							
							If AllTrim(aCols[nI][_PosAlmxDest]) <> AllTrim(aCols[nI][_PosAlmxOri])
									
								lRet := .F.
								ApMsgStop('Operea็ao nao permitida: Saldo reservado pelos pedidos de vendas!','A261TOK')
					   			Exit 
					   		
					   		EndIf			
					
						Else
						
							lRet := .F.
							ApMsgStop('Operea็ao nao permitida: Saldo reservado pelos pedidos de vendas!','A261TOK')
					   		Exit 
						
						EndIf
					
					EndIf
				
			EndIf
			
		EndIf
		
	Next
	
EndIf
	
RestArea(aArea)

If Select('cAliasSB8') > 0
	DbSelectArea('cAliasSB8')
	cAliasSB8->(DbCloseArea())
EndIf

Return(lRet)