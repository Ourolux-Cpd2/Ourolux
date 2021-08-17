#Include 'Protheus.ch'
#Include 'Parmtype.ch'

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} SSCOM001
Responsável pelo preenchimento da TES e chamada de outras funções.

@type 		Function
@author 	Maurício Aureliano
@since 		16/03/2018
@version 	P12
@obs 		https://www.smartsiga.com.br/preenchimento-automatico-de-tes-classificacao-documento-de-entrada/

@obs		Chamado: I1505-1148 - Customização de TES Inteligente Entradas	 
 
@return nil
/*/    
//-------------------------------------------------------------------------------------

User Function SSCOM001()

	  //Variaveis Locias
	Local aPerg  := {}
	Local aRet  := {}
	Local cCodTES   := Space(TamSX3("D1_TES")[1])
  	
  	//Adiciona as informacoes necessarias no Array aPerg, para montagem de tela atraves da funcao Parambox
	AADD( aPerg ,{1,"Código da TES:", cCodTES, "@!", "StaticCall(SSCOM001, VdFillTES)", "SF4", '.T.', 40, .T.})
  	
  	//Verifica se apos selecionar a TES, foi clicado no botao OK ou Cancelar
	If ParamBox(aPerg ,"Atualizar TES", aRet)
    
    	//Opcao escolhida OK
    	//Recupera a TES selecionada e associa a variavel cCodTES
		cCodTES := aRet[1]
    	
    	//Executa a funcao responsavel por alimentar a TES de todos os produtos existentes no Documento de Entrada    
		FWMsgRun(, {|| ProcTES(cCodTES) }, "Processando", "Atualizando TES, Aguarde")
    
    	//Atualiza o GetDados dos Itens do Documento de Entrada
		oGetDados:oBrowse:Refresh()
	EndIf
Return
//*****************************************************************************************************************
//Funcao VdFillTES - Verifica se foi selecionada alguma TES, e se a TES eh de Entrada para preenchimento do D1_TES
//*****************************************************************************************************************
Static Function VdFillTES()

	//Variavel Local
	Local lReturn := .T.
  	
  	//Verifica se foi preenchido o campo de selecao de TES
	If (AllTrim(Mv_Par01) == "")
  
    	//Caso não tenha, exibe uma mensagem de alerta
		MsgAlert("Favor selecionar uma TES de Entrada, para correta classificação do Documento de Entrada.", "Smart Siga")
    	
    	//Retorna False a funcao, mantendo o focu no campo de selecao de TES
		lReturn  := .F.
	Else
    	//Se foi preenchida alguma TES, verifica se a mema eh de Entrada
		If (Val(Mv_Par01) > 500)
      		
      		//Se nao for, exibe mensagem de alerta
			MsgAlert("TES de Entrada selecionada é inválida. Favor selecionar uma TES menor ou igual a 500.", "Smart Siga")
      
      		//Retorna False a funcao, mantendo o focu no campo de selecao de TES
			lReturn := .F.
		EndIf
	EndIf
	
Return (lReturn)

//*********************************************************************************************************
//Funcao ProcTES - Responsavel por alimentar a TES de todos os produtos existentes no Documento de Entrada
//*********************************************************************************************************
Static Function ProcTES(cCodTES)
  
  	//Variaves Locais
	Local nToTLhs   := Len(aCols)
	Local nLhAtual  := 0
	Local nPosTES   := aScan(aHeader,{|x| Alltrim(x[2]) == "D1_TES"})
	Local bValid    := {|| M->D1_TES := cCodTES, CheckSx3("D1_TES")}
	For nLhAtual := 1 To nToTLhs
    	//Ajusta a variavel de posicao de linha do GetDados
		n := nLhAtual
    	
    	//Associa a TES ao Campo D1_TES
		aCols[nLhAtual][nPosTES] := cCodTES
    	
    	//Ajusta a variavel do campo posicionado para o D1_TES
		__ReadVar := "M->D1_TES"
    	
    	//Executa bloco de codigo atualizando a variavel de memoria e do GetDados D1_TES
		Eval( bValid )
    	
    	//Verifica se existe Gatilhos para o campo D1_TES
		If ExistTrigger("D1_TES")
      		//Executa os Gatilhos do campo D1_TES
			RunTrigger(2, n,,,"D1_TES")
		Endif
	Next nLhAtual
Return