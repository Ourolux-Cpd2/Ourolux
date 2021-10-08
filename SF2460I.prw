User Function SF2460I()

    dbSelectArea("PR1")
	PR1->(DbSetOrder(2))

	If !PR1->(MsSeek(SF2->(F2_FILIAL+F2_DOC+F2_SERIE) ) ) .And. PR1->(MsSeek(xFilial("PR1")+"SC5"+SC5->(C5_FILIAL+C5_NUM)))

		RecLock("PR1",.T.)

			PR1->PR1_FILIAL := xFilial("PR1")
			PR1->PR1_ALIAS  := "SF2"
			PR1->PR1_RECNO  := SF2->(Recno())
			PR1->PR1_TIPREQ := "1"
			PR1->PR1_STINT  := "P"
			PR1->PR1_CHAVE  := SF2->(F2_FILIAL+F2_DOC+F2_SERIE)

		PR1->(MsUnlock())

    ElseIf PR1->(MsSeek(xFilial("PR1")+"SC5"+SC5->(C5_FILIAL+C5_NUM)))

        RecLock("PR1",.F.)

			PR1->PR1_FILIAL := xFilial("PR1")
			PR1->PR1_ALIAS  := "SF2"
			PR1->PR1_RECNO  := SF2->(Recno())
			PR1->PR1_TIPREQ := "1"
			PR1->PR1_STINT  := "P"
			PR1->PR1_CHAVE  := SF2->(F2_FILIAL+F2_DOC+F2_SERIE)

		PR1->(MsUnlock())
		
	Endif 

Return()
