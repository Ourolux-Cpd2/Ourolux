/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �VLDCLI    �Autor  �Eltromega           � Data �  11/17/08   ���
�������������������������������������������������������������������������͹��
���Desc.     � Valida�oa Eletromega para bloqeuio                         ���
���          � Chamado do Call Center/ Faturamento                        ���
���          �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP8                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
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
	
	// Alterado por Gilson Belini em 21/03/2017 - Inclus�o dos t�tulos do tipo RA - In�cio
	//	If ! SE1->E1_TIPO $ [JR .NCC]
	If ! SE1->E1_TIPO $ [JR .NCC.RA ]
		// Alterado por Gilson Belini em 21/03/2017 - Inclus�o dos t�tulos do tipo RA - Fim
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
	cAviso := "Cr�dito bloqueado"
	/*
	ElseIf cRisco == "C"
	cAviso := "Pagto em cartorio, pedido sujeito a analise de cr�dito"
	*/
ElseIf cRisco == "D"
	cAviso := "Analisar SCI"
ElseIf (dDatabase - 180) > SA1->A1_ULTCOM .And. !Empty( SA1->A1_ULTCOM )
	cAviso := "Analisar SCI"
ElseIf SA1->A1_SalDup > SA1->A1_LC
	If cAviso <> ""
		cAviso += '/CE'
	Else
		cAviso := "Cr�dito excedido"
	End
	// Inclu�do por Gilson Belini em 21/03/2017 - Regra de valida��o para Pedidos de Vendas liberados (consome limite de cr�dito) - In�cio
Elseif SA1->A1_SALDUP <= 0
	If SA1->A1_SALPEDL > SA1->A1_LC
		cAviso := "PV N�o Fat.> que LC"
	ElseIf SA1->A1_SALPEDL < SA1->A1_LC
		cAviso := "Pr�-Cr�dito Aprovado"
	Endif
Elseif SA1->A1_SALDUP > 0 .and. SA1->A1_SALDUP < SA1->A1_LC
	If (SA1->A1_SALDUP + SA1->A1_SALPEDL) > SA1->A1_LC
		cAviso := "PV N/Fat+Sl.Dup.> LC"
	Endif
	// Inclu�do por Gilson Belini em 21/03/2017 - Regra de valida��o para Pedidos de Vendas liberados (consome limite de cr�dito) - Fim
ElseIf SA1->A1_Cod == "999999" .And. cNivel < 4
	cAviso := "Cons.Final Bloq."
ElseIf cAviso == ""
	cAviso   := "Pr�-Cr�dito Aprovado"
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
