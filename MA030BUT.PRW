#Include "Protheus.ch"

//Ponto de entrada para adicionar opções no "Ações Relacionadas" do cadastro de clientes
User Function MA030BUT()

    Local lAcesso := .T.
    Local aButtons:= {}
    Local cUserCCB:= AllTrim(SuperGetMv("SE_CCBACES", .F., ""))
    
    //Caso tenha sido definido usuários no parâmetro, deverá verificar se o usuário possuirá acesso as rotinas
    If .Not. Empty(cUserCCB)
    	lAcesso := AllTrim(Upper(cUserName)) $ Upper(cUserCCB)
    EndIf

    If PARAMIXB[1] == 2 .And. lAcesso

        //AADD(aButtons, {"POSCLI", {|| U_SEFINA02(SA1->A1_COD, SA1->A1_LOJA) }, "Atualização CCB"})
        AADD(aButtons, {"POSCLI", {|| U_SEFINA03(SA1->A1_COD, SA1->A1_LOJA) }	, "Consulta CCB"})
        AADD(aButtons, {"POSCLI", {|| U_VERISK(SA1->A1_COD) }					, "Risk Rating"})
        AADD(aButtons, {"POSCLI", {|| U_SEFINA05() }					        , "Consulta Serasa"})		
        AADD(aButtons, {"POSCLI", {|| U_FINA05AT(1) }					        , "Buscar Cred.BUREAU"})		
        AADD(aButtons, {"POSCLI", {|| U_FINA05AT(2) }					        , "Buscar CREDNET"})		
        AADD(aButtons, {"POSCLI", {|| U_FINA05AT(3) }				        	, "Buscar RELATO"})				
    
    EndIf
    
    IF ALTERA
        AADD(aButtons, {"POSCLI", {|| AxInclui('SU5',,3,,,,'U_AssCC()',,,,,,.T.) }	, "Incluir Contato"})				               
    EndIf

Return aButtons

//REVISAO 000 - FABRICIO EDUARDO RECHE - 06/10/2014
//REVISAO 001 - FABRICIO EDUARDO RECHE - 31/10/2014 - Removido opção manual de atualização do CCB, deverá ser feita automaticamente, conforme instrução do Genival (suporte CCB)