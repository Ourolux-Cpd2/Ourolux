#INCLUDE "PROTHEUS.CH"

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±  MT160WF  ³ Autor: Claudino Pereira Domingues           ³ Data 16/11/14 ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±± Descricao ³ Ponto de entrada que sera executado após a gravação dos     ±±
±±           ³ pedidos de compras pela analise da cotação e antes dos      ±±
±±           ³ eventos de contabilização, utilizado para os processos de   ±±
±±           ³ workFlow posiciona a tabela SC8 e passa como parametro o    ±±
±±           ³ numero da cotação.                                          ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/

User Function MT160WF()

	If SC7->C7_CONAPRO == "B"
		U_APCIniciar("01")
	EndIf

Return