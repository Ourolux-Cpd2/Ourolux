#INCLUDE "PROTHEUS.CH"

/*
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北?
北  MT160WF  ? Autor: Claudino Pereira Domingues           ? Data 16/11/14 北
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北?
北 Descricao ? Ponto de entrada que sera executado ap髎 a grava玢o dos     北
北           ? pedidos de compras pela analise da cota玢o e antes dos      北
北           ? eventos de contabiliza玢o, utilizado para os processos de   北
北           ? workFlow posiciona a tabela SC8 e passa como parametro o    北
北           ? numero da cota玢o.                                          北
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北?
*/

User Function MT160WF()

	If SC7->C7_CONAPRO == "B"
		U_APCIniciar("01")
	EndIf

Return