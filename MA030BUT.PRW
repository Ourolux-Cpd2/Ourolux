#Include "Protheus.ch"

//Ponto de entrada para adicionar op��es no "A��es Relacionadas" do cadastro de clientes
User Function MA030BUT()

    Local lAcesso := .T.
    Local aButtons:= {}
    Local cUserCCB:= AllTrim(SuperGetMv("SE_CCBACES", .F., ""))
    
    //Caso tenha sido definido usu�rios no par�metro, dever� verificar se o usu�rio possuir� acesso as rotinas
    If .Not. Empty(cUserCCB)
    	lAcesso := AllTrim(Upper(cUserName)) $ Upper(cUserCCB)
    EndIf

    If PARAMIXB[1] == 2 .And. lAcesso

        //AADD(aButtons, {"POSCLI", {|| U_SEFINA02(SA1->A1_COD, SA1->A1_LOJA) }, "Atualiza��o CCB"})
        AADD(aButtons, {"POSCLI", {|| U_SEFINA03(SA1->A1_COD, SA1->A1_LOJA) }	, "Consulta CCB"})
        AADD(aButtons, {"POSCLI", {|| U_VERISK(SA1->A1_COD) }					, "Risk Rating"})
        AADD(aButtons, {"POSCLI", {|| U_SEFINA05() }					        , "Consulta Serasa"})		
        AADD(aButtons, {"POSCLI", {|| U_FINA05AT(1) }					        , "Buscar Cred.BUREAU"})		
        AADD(aButtons, {"POSCLI", {|| U_FINA05AT(2) }					        , "Buscar CREDNET"})		
        AADD(aButtons, {"POSCLI", {|| U_FINA05AT(3) }				        	, "Buscar RELATO"})				
    
    EndIf
    
    IF ALTERA
        AADD(aButtons, {"POSCLI", {|| AxInclui('SU5',,3,,,,'U_AssCC()',,,,,,.T.) }	, "Incluir Contato"})	
		AADD(aButtons,{"POSCLI", { || u_dfsCnpjBut() } ,"Consulta CISP"})
    EndIf

Return aButtons

//REVISAO 000 - FABRICIO EDUARDO RECHE - 06/10/2014
//REVISAO 001 - FABRICIO EDUARDO RECHE - 31/10/2014 - Removido op��o manual de atualiza��o do CCB, dever� ser feita automaticamente, conforme instru��o do Genival (suporte CCB)
