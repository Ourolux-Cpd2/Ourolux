#INCLUDE "PROTHEUS.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TKEVALI   ºAutor  ³ Ernani Forasteiri  º Data ³  30/05/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Ponto de entrada utilizado para validar a linha do acols    º±±
±±º          ³ no atendimento do televendas.                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Eletromega                                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function TKEVALI()
Local aArea     := GetArea()
Local aAreaSB2  := SB2->( GetArea() )
Local lRet      := .T.
Local nI        := 0
Local nPProd    := aScan(aHeader,{ |x| Upper(AllTrim(x[2])) == "UB_PRODUTO" })
Local nPQtd     := aScan(aHeader,{ |x| Upper(AllTrim(x[2])) == "UB_QUANT" })
Local nPosItem  := aScan(aHeader,{ |x| Upper(AllTrim(x[2])) == "UB_ITEM" }) 
Local nPosTes   := aScan(aHeader,{ |x| Upper(AllTrim(x[2])) == "UB_TES" })
Local nPosCF    := aScan(aHeader,{ |x| Upper(AllTrim(x[2])) == "UB_CF" }) 
Local nPosPrc   := aScan(aHeader,{ |x| Upper(AllTrim(x[2])) == "UB_VRUNIT" })
Local nPPrcTab  := aScan(aHeader,{ |x| Upper(AllTrim(x[2])) == "UB_PRCTAB" })

Local nSaldoSB2		:= 0 
Local cCFOP     	:= '' 
Local nQtdVenSC6	:= 0
Local nPrcMin       := 0
Local nDescMax      := 0
Local nDescCP       := 0
Local nDescTot      := 0
Local aDscEsp       := {}

If lTK271Auto 
	RestArea(aArea) 
	RestArea(aAreaSB2)
	Return .T.
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Nao permite e digitacao de produtos duplicados no aCols ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !aCols[n][Len(aHeader)+1]
	For nI := 1 to Len( aCols )		
		If !aCols[nI][Len(aHeader)+1] .AND. n <> nI
			If aCols[n][nPProd] == aCols[nI][nPProd]
				ApMsgStop( 'Produto já selecionado.', 'TKEVALI' )
				lRet := .F.
				Exit
			EndIf
		EndIf                  
	Next
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica o saldo do item se for um faturamento          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lRet	.AND. M->UA_OPER == '1' // Faturamento
	
	If !aCols[n][Len(aHeader)+1]
	
		SB2->( dbSetOrder( 1 ) )
	
		If (SB2->( dbSeek( xFilial( 'SB2' ) + aCols[n][nPProd] + GetMV('EX_ALXPDB',,'01') ))) 
		   		    
			nSaldoSB2 := SaldoSB2(.F.,.T.,,.F.,.F.,,,,.T.) - ABS(SB2->B2_QPEDVEN)
			
			If ABS(SB2->B2_QPEDVEN) + ABS(SB2->B2_RESERVA) > SB2->B2_QATU   //SB2->B2_QPEDVEN < 0 .Or. SB2->B2_RESERVA < 0
							
				lRet := .F.
				ApMsgStop( 'Produto c/ divergencia de saldo. Favor entrar em contato com o seu assistante comercial! ' + Alltrim( aCols[n][nPProd] )+ ' ( ' +  Alltrim( Transform(nSaldoSB2,'@E 999,999,999.99') ) + ' )', 'TKEVALI' )			
			
			Else
			
				If (ALTERA)
					If SUB->( dbSeek( xFilial( 'SUB' ) + M->UA_NUM + aCols[n][nPosItem] + aCols[n][nPProd]))
						If ! Empty (SUB->UB_NUMPV)
							nQtdVenSC6 := GetAdvFVal("SC6","C6_QTDVEN",xFilial("SC6")+SUB->UB_PRODUTO+SUB->UB_NUMPV,2,0)
							nSaldoSB2 += nQtdVenSC6  
				    	EndIf
					EndIf		
				EndIf
			
				If aCols[n][nPQtd] > nSaldoSB2  
					If AvalTes(aCols[ n ][ nPosTES ],"S","SN")	// If TES movimento o estoque "S"	
						lRet := .F.
						ApMsgStop( 'Não existe saldo suficiente para este produto ' + Alltrim( aCols[n][nPProd] )+ ' ( ' +  Alltrim( Transform(nSaldoSB2,'@E 999,999,999.99') ) + ' )', 'TKEVALI' )
					EndIf
				
				EndIf
			
			EndIf
				
		Else
			lRet := .F.
			ApMsgStop( 'Produto ' + Alltrim( aCols[n][nPProd] )+ ' sem saldo!', 'TKEVALI' )
		EndIf 
	
	EndIf  // Deleted
	
EndIf      // Faturamento

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Validate se produto pode ser vendido fora da embalagem  ³
//³ WAR                                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If lRet
	lRet := U_VerEmb(N)
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Tratamento Desconto max DA0_XDESC                       ³
//³ WAR                                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If lRet .And. !aCols[n][Len(aHeader)+1]
	
	nDescMax := GetAdvFVal("DA0","DA0_XDESC",xFilial("DA0")+AllTrim(M->UA_TABELA),1,0)
	nDescCP  := GetAdvFVal("SE4","E4_XDESC",xFilial("SE4")+AllTrim(M->UA_CONDPG),1,0)
	aDscEsp  := GetAdvFVal("SA1",{"A1_XDSCESP","A1_XDTDSCE"},xFilial("SA1")+M->(UA_CLIENTE+UA_LOJA),1,{"",""}) 
	
	If aDscEsp[1] > 0 .And. Dtos(aDscEsp[2]) == Dtos(dDataBase) .And. !Empty(Dtos(aDscEsp[2])) 
	
		nDescTot := aDscEsp[1] 	
	
	EndIf
	
	nDescTot += nDescMax + nDescCP
	
	nPrcMin  := IIf(nDescTot > 0, Round(aCols[n][nPPrcTab] - aCols[n][nPPrcTab] * (nDescTot/100),2), aCols[n][nPPrcTab])			 
    
	If Round(aCols[n][nPosPrc],2) < nPrcMin  //NoRound(nPrcMin,2)
		lRet := .F.
		ApMsgStop("Preço informado para o produto " + Alltrim(aCols[n][nPProd])+ " é menor que o valor mínimo: (R$ " + ALLTRIM (STR(Round(nPrcMin,2 ))) + ").")
	EndIf

EndIf 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Calculate o desconto no item                            ³
//³ WAR                                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If lRet
	U_CLCPDESC()
EndIf

/*

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Tratamento valor minimo SB1-> 1_PR500X                  ³
//³ WAR                                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If lRet .And. !aCols[n][Len(aHeader)+1]
	
	nPrcMin := GetAdvFVal("SB1","B1_PR500X",xFilial("SB1")+AllTrim(aCols[n][nPProd]),1,0)
    
	If aCols[n][nPosPrc] < nPrcMin
		lRet := .F.
		ApMsgStop("Preço informado para o produto " + Alltrim(aCols[n][nPProd])+ " é menor que o valor mínimo: (R$ " + ALLTRIM (STR(NoRound(nPrcMin,4 ))) + ").")
	EndIf

EndIf

*/

RestArea( aAreaSB2 )
RestArea( aArea )

Return lRet

User Function SldError(cProduto)

Local cQuery    := ''
Local nSaldo    := 0
Local _aArea1   := GetArea()
Local lRet		:= .F.

If Select("Saldo") > 0
	DbSelectArea("Saldo")
	Saldo->(DbCloseArea())
EndIf

_cQuery := " SELECT SUM(C6_QTDVEN) As QtdVen  "
_cQuery += " FROM " + RetSqlName("SC6") + " SC6 "
_cQuery += " WHERE SC6.D_E_L_E_T_ <> '*' AND " 
_cQuery += " SC6.C6_FILIAL  = '" + xFilial("SC6")  + "' AND "
_cQuery := cQuery + "   AND SC6.C6_CLI  = '" + cCliente + "'"
_cQuery += " SD2.D2_FILIAL  = '" + SF2->F2_FILIAL  + "' AND "
_cQuery += " SD2.D2_CLIENTE = '" + SF2->F2_CLIENTE + "' AND "
_cQuery += " SD2.D2_LOJA    = '" + SF2->F2_LOJA    + "' AND "
_cQuery += " SD2.D2_SERIE   = '" + SF2->F2_SERIE   + "' AND "
_cQuery += " SD2.D2_DOC     = '" + SF2->F2_DOC     + "' AND "
_cQuery += " SD2.D2_TIPO    = '" + SF2->F2_TIPO    + "' AND "
_cQuery += " SB1.B1_FILIAL  = '" + xFilial("SB1") + "' "
_cQuery += " GROUP BY SD2.D2_DOC "

dbUseArea( .T., "TOPCONN", TCGENQRY(,,_cQuery), 'Saldo' )

If Saldo->(!Eof())
	
	nSaldo := Saldo->QtdVen

EndIf

RestArea(_aArea1)
Saldo->(DbCloseArea())

Return()
