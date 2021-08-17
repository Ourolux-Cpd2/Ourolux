#INCLUDE "PROTHEUS.CH"

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±  WFW120P  ³ Autor: Claudino Pereira Domingues           ³ Data 05/05/14 ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±± Descricao ³ Ponto de entrada que sera executado tanto na inclusao como  ±±
±±           ³ alteracao do pedido de compras a partir do botao "OK".      ±±
±±           ³ Apos a gravacao dos itens do pedido de compras, no final da ±±
±±           ³ condicao que gera o Bloqueio do PC na tabela SCR, pode ser  ±±
±±           ³ usado para manipular os dados gravados do pedido de compras ±±
±±           ³ na tabela SC7, como tambem o seu bloqueio tabela SCR.       ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/

User Function WFW120p()

	Local _cNumPed  := ""
	Local cDeptoEIC	:= SuperGetMV("ES_DPTOEIC",.F.,"000000027")
	Local cDptoImp	:= SuperGetMV("ES_DPTOIMP",.F.,"") //000000035
	Local cDespImp	:= SuperGetMV("ES_DESPIMP",.F.,"") //201/202/203/204/205/405/415
	
	// Salva todas as alteracoes realizadas nas areas de trabalho abertas no momento.
	dbCommitAll()
	
	_cNumPed := SC7->C7_NUM
	
	SC7->(dbSetOrder(1))
	SC7->(dbSeek( xFilial("SC7") + _cNumPed ))
	
	// Se a origem for o modulo de gestao de contrato o pedido nao deve 
	// gerar workflow e deve entrar no sistema como liberado.
	If FunName() == "CNTA120"
		While SC7->(!Eof()) .AND. SC7->C7_NUM == _cNumPed
			RecLock("SC7",.F.)
				SC7->C7_APROV	:= ""
				SC7->C7_CONAPRO	:= "L"
			SC7->(MsUnLock("SC7"))
			SC7->(dbSkip())
		EndDo
	EndIf
	
	If FunName() <> "EICDI502"
		If SC7->C7_CONAPRO == "B"
			RecLock("SC7",.F.)
			SC7->C7_XDEPART := _cDepSC7
			SC7->(MsUnlock())
			U_APCIniciar("01")
		EndIf
	Else
		If SC7->C7_CONAPRO == "B"
			RecLock("SC7",.F.)
			If SubStr(SC7->C7_PRODUTO,1,3) == "EIC" .AND. (SubStr(SC7->C7_PRODUTO,4,3) $ cDespImp)
				SC7->C7_XDEPART := cDptoImp
			Else
				SC7->C7_XDEPART := cDeptoEIC
			EndIf
			SC7->(MsUnlock())
			U_APCIniciar("01")
		EndIf
	EndIf
Return
