#Include "Protheus.ch"

//Rotina para auto libera��o de titulos de fatura
User Function FA290()

SE2->E2_DATALIB := DDATABASE
SE2->E2_APROVA  := "AUTOMATICO"
SE2->E2_WFALC   := "X"

Return