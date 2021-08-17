#INCLUDE "PROTHEUS.CH"

/*
�����������������������������������������������������������������������������
��  MT160WF  � Autor: Claudino Pereira Domingues           � Data 16/11/14 ��
�����������������������������������������������������������������������������
�� Descricao � Ponto de entrada que sera executado ap�s a grava��o dos     ��
��           � pedidos de compras pela analise da cota��o e antes dos      ��
��           � eventos de contabiliza��o, utilizado para os processos de   ��
��           � workFlow posiciona a tabela SC8 e passa como parametro o    ��
��           � numero da cota��o.                                          ��
�����������������������������������������������������������������������������
*/

User Function MT160WF()

	If SC7->C7_CONAPRO == "B"
		U_APCIniciar("01")
	EndIf

Return