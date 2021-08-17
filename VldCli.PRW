/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³VLDCLI    ºAutor  ³Eltromega           º Data ³  11/17/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Validaçoa Eletromega para bloqeuio                         º±±
±±º          ³ Chamado do Call Center/ Faturamento                        º±±
±±º          ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP8                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function VldCli(cCliente,cLoja,cAviso)

Local cRisco	:= SA1->A1_RISCO
Local nIdx    	:= 0
Local cQryVle   := ""
Local aArea     := GetArea()
Local aAreaSE1	:= SE1->(GetArea())

SA1->( dbSeek( xFilial( 'SA1' ) + cCliente + cLoja, .F. ) )

nIdx := SE1->( IndexOrd() )
SE1->( dbSetOrder( 8 ) )
SE1->( dbSeek( xFilial( 'SE1' ) + cCliente + cLoja + 'A        ', .T. ) )


While cCliente == SE1->E1_CLIENTE .And.;
	cLoja    == SE1->E1_LOJA    .And.;
	SE1->E1_STATUS  = 'A'
	
	// Alterado por Gilson Belini em 21/03/2017 - Inclusão dos títulos do tipo RA - Início
	//	If ! SE1->E1_TIPO $ [JR .NCC]
	If ! SE1->E1_TIPO $ [JR .NCC.RA ]
		// Alterado por Gilson Belini em 21/03/2017 - Inclusão dos títulos do tipo RA - Fim
		If SE1->E1_VENCREA < dDataBase
			cAviso := 'Titulos em aberto'
		ElseIf SE1->E1_VENCREA = dDataBase
			cAviso := 'Tit. vencendo hoje'
		EndIf
		
		Exit
		
	EndIf
	
	SE1->( dbSkip() )
End

SE1->( dbSetOrder( nIdx ) )

If cRisco == "E"
	cAviso := "Crédito bloqueado"
	/*
	ElseIf cRisco == "C"
	cAviso := "Pagto em cartorio, pedido sujeito a analise de crédito"
	*/
ElseIf cRisco == "D"
	cAviso := "Analisar SCI"
ElseIf (dDatabase - 180) > SA1->A1_ULTCOM .And. !Empty( SA1->A1_ULTCOM )
	cAviso := "Analisar SCI"
ElseIf SA1->A1_SalDup > SA1->A1_LC
	If cAviso <> ""
		cAviso += '/CE'
	Else
		cAviso := "Crédito excedido"
	End
	// Incluído por Gilson Belini em 21/03/2017 - Regra de validação para Pedidos de Vendas liberados (consome limite de crédito) - Início
Elseif SA1->A1_SALDUP <= 0
	If SA1->A1_SALPEDL > SA1->A1_LC
		cAviso := "PV Não Fat.> que LC"
	ElseIf SA1->A1_SALPEDL < SA1->A1_LC
		cAviso := "Pré-Crédito Aprovado"
	Endif
Elseif SA1->A1_SALDUP > 0 .and. SA1->A1_SALDUP < SA1->A1_LC
	If (SA1->A1_SALDUP + SA1->A1_SALPEDL) > SA1->A1_LC
		cAviso := "PV N/Fat+Sl.Dup.> LC"
	Endif
	// Incluído por Gilson Belini em 21/03/2017 - Regra de validação para Pedidos de Vendas liberados (consome limite de crédito) - Fim
ElseIf SA1->A1_Cod == "999999" .And. cNivel < 4
	cAviso := "Cons.Final Bloq."
ElseIf cAviso == ""
	cAviso   := "Pré-Crédito Aprovado"
EndIf

If !(cCliente $[008455.006273])
	
	cQryVle := "SELECT    COUNT( * ) AS Vales "
	cQryVle += " FROM " + RetSqlName("SE1") + " SE1 "
	cQryVle += "WHERE     ( E1_BAIXA = '      ' ) AND ( E1_CLIENTE = '"
	cQryVle += cCliente + "') AND (D_E_L_E_T_ <> '*') AND ( E1_PORTADO = 'VLE' )"
	
	dbUseArea(.T., "TOPCONN", TCGENQRY(,,cQryVle), 'VLS',.F.,.T.)
	
	If VLS->Vales != 0
		cAviso := Alltrim( Str( VLS->Vales, 3 ) ) + " vale(s) em aberto"
	End
	
	VLS->(DbCloseArea())
	
EndIf

RestArea(aAreaSE1)
RestArea(aArea)
Return (Nil)
