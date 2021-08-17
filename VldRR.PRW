/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³VLDRR     ºAutor  ³Gilson Belini       º Data ³  08/04/2017 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Validação Analise de Crédito com base nas regras CISP      º±±
±±º          ³ Arquivos importados: Risk Rating - Plus e Master           º±±
±±º          ³ Chamado do Call Center/ Faturamento                        º±±
±±º          ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Específico Ourolux                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function VldRR(cCliente,cLoja,cXAviso)

Local cRisco	:= SA1->A1_RISCO
Local cRiscoRR	:= ""
Local cAnalise	:= ""
Local cCNPJ		:= ""
Local cCNPJTOT	:= ""
Local cTipo		:= SA1->A1_PESSOA
Local nIdx    	:= 0
Local aArea     := GetArea()
Local aAreaSZU	:= SZU->(GetArea())
Local aAreaSZV	:= SZV->(GetArea())
Local aAreaSZR	:= SZR->(GetArea())
Local aAreaSZS	:= SZS->(GetArea())

SA1->( dbSeek( xFilial( 'SA1' ) + cCliente + cLoja, .F. ) )

If SA1->A1_PESSOA=='J'
	cCNPJ := Substr(SA1->A1_CGC,1,8)
Else
	cCNPJ := '00000000'
Endif

cCNPJTOT	:= cCNPJ+SPACE(12)

nIdx := SZU->( IndexOrd() )
SZU->( dbSetOrder( 1 ) )
SZU->( dbSeek( cCNPJTOT, .T. ) )

If cTipo == "F"
	cXAviso := 'Cliente - Cons.Final'
	Return (Nil)
Endif

While cCNPJ == SubStr(SZU->ZU_CNPJ,1,8)
	// Cadastro de Regras Risk Rating
	nIdx := SZV->( IndexOrd() )
	SZV->( dbSetOrder( 2 ) )
	SZV->( dbSeek( SZU->ZU_RISCO+SZU->ZU_RISDEN, .T. ) )
	While SZV->ZV_RISCO == SZU->ZU_RISCO .and. SZV->ZV_DENSCOM == SZU->ZU_RISDEN
		// Status Receita Federal
		nIdx := SZR->( IndexOrd() )
		SZR->( dbSetOrder( 2 ) )
		SZR->( dbSeek( SZU->ZU_CSTATRF, .T. ) )
		If SZR->ZR_ACAO == "L"
			If SZV->ZV_CALCDIA == "A"
				cXAviso	:= AllTrim(SZV->ZV_MSGRET)
			ElseIf SZV->ZV_CALCDIA == "S"
				cXAviso	:= AllTrim(SZV->ZV_MSGRET)
			ElseIf SZV->ZV_CALCDIA == "N"
				cXAviso	:= AllTrim(SZV->ZV_MSGRET)
			Endif
		Elseif SZR->ZR_ACAO == "B"
			If SZV->ZV_CALCDIA == "N"
				cXAviso	:= AllTrim(SZV->ZV_MSGRET)
			ElseIf SZV->ZV_CALCDIA <> "N"
				cXAviso	:= AllTrim(SZR->ZR_DESC)
			Endif
		Endif
		// Status Sintegra
		nIdx := SZS->( IndexOrd() )
		SZS->( dbSetOrder( 2 ) )
		SZS->( dbSeek( SZU->ZU_CSTATSI, .T. ) )
		If SZS->ZS_ACAO == "L"
			If SZV->ZV_CALCDIA == "A"
				cXAviso	:= AllTrim(SZV->ZV_MSGRET)
			ElseIf SZV->ZV_CALCDIA == "S"
				cXAviso	:= AllTrim(SZV->ZV_MSGRET)
			ElseIf SZV->ZV_CALCDIA == "N"
				cXAviso	:= AllTrim(SZV->ZV_MSGRET)
			Endif
		Elseif SZS->ZS_ACAO == "B"
			If SZV->ZV_CALCDIA == "N"
				cXAviso	:= AllTrim(SZV->ZV_MSGRET)
			Elseif SZV->ZV_CALCDIA <> "N" 
				cXAviso	:= AllTrim(SZR->ZR_DESC)
			Endif
		Endif
		SZV->( dbSkip() )
	End
	SZU->( dbSkip() )
End

// Para clientes que constam na tabela SZU como não cadastrados na CISP ou clientes que não constam na SZU.
If Empty(cXAviso)
	cXAviso := "Cliente não Cad. na CISP"
Endif

RestArea(aAreaSZU)
RestArea(aAreaSZV)
RestArea(aAreaSZR)
RestArea(aAreaSZS)
RestArea(aArea)

Return (Nil)
