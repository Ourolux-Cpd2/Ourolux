#INCLUDE "PROTHEUS.CH"

/*����������������������������������������������������������������������������
������������������������������������������������������������������������������
��� Programa � F050MCP() � Autor � Claudino P Domingues � Data � 10/10/14  ���
������������������������������������������������������������������������������
��� Funcao Padrao � FINA050                                                ���
������������������������������������������������������������������������������
��� Desc.    � Este ponto de entrada permite incluir novos campos na op��o ��� 
���          � Alterar da rotina FINA050. Ser� executado ao exibir a tela  ���
���          � ap�s clicar no bot�o Alterar da rotina FINA050. Desta forma,��� 
���          � os campos que forem incluidos por este Ponto de Entrada     ���
���          � tamb�m poder�o ser editados na op�ao Alterar.               ���
������������������������������������������������������������������������������
����������������������������������������������������������������������������*/

User Function F050MCP()

	Local _aCampos := PARAMIXB
	
	AADD(_aCampos,"E2_MULTA")
	AADD(_aCampos,"E2_JUROS")
	AADD(_aCampos,"E2_DATAAGE")		
	
Return _aCampos