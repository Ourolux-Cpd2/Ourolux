#INCLUDE "PROTHEUS.CH"

/*苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
北? Programa ? F050MCP() ? Autor ? Claudino P Domingues ? Data ? 10/10/14  罕?
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
北? Funcao Padrao ? FINA050                                                罕?
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
北? Desc.    ? Este ponto de entrada permite incluir novos campos na op玢o 罕? 
北?          ? Alterar da rotina FINA050. Ser? executado ao exibir a tela  罕?
北?          ? ap髎 clicar no bot鉶 Alterar da rotina FINA050. Desta forma,罕? 
北?          ? os campos que forem incluidos por este Ponto de Entrada     罕?
北?          ? tamb閙 poder鉶 ser editados na op鏰o Alterar.               罕?
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌*/

User Function F050MCP()

	Local _aCampos := PARAMIXB
	
	AADD(_aCampos,"E2_MULTA")
	AADD(_aCampos,"E2_JUROS")
	AADD(_aCampos,"E2_DATAAGE")		
	
Return _aCampos