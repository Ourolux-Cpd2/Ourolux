#include "rwmake.ch"
#Include "PROTHEUS.CH"
#DEFINE COMP_DATE "20191223"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MA030TOK()   ºAutor  ³Eletromega        º Data ³  07/07/09  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ TUDOK DA INCLUSÃO E ALTERAÇÃO 							  º±±
±±º			   Na TudOK (validação da digitação) na inclusão e alteração  º±± 
±±º            de clientes.	  						            		  º±±
±±º                                                                       º±± 
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP8                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function MA030TOK()

	Local lRet 		:= .T.
	Local cInscri   := AllTrim(M->A1_INSCR)
	Local cMsgErro  := ""
	Local cCNPJBase := ""
	Local lValidAll := .F.
	Local cTipoCli  := AllTrim(M->A1_TIPO)
	Local cMsgAvis	:= ""

	
	If Inclui .Or. Altera

		cConta := AllTrim(M->A1_CONTA)

		DbSelectArea("CT1")
		DbSetOrder(1)

		If CT1->(DbSeek(xFilial("CT1")+cConta))
			If CT1->CT1_BLOQ == "1"
				cMsgErro += "A conta contábil cadastrada ["+cConta+"] encontra-se bloqueada."
			EndIf
		Else
			cMsgErro += "A conta contábil cadastrada ["+cConta+"] não existe."
		EndIf

		If !Empty( cMsgErro )
			lRet := .F.
	//		Aviso("MA030TOK",cMsgErro,{"Ok"},2,"Atenção")
		//Amedeo (Ajuste para tratamento Portal de Vendas)
			If !IsInCallStacj( "U_FBBXCLI" )
				U_MyAviso("MA030TOK",cMsgErro,{"Ok"},2,"Atenção")
			Else
				Aviso( "MA030TOK", cMsgErro, {"Ok"}, 2, "Atenção" )
			Endif
		EndIf

	EndIf


	If lRet .And. ( Inclui .Or. Altera )
		aInfo     := U_RetParAR( "FS_SACSA1","Sac;SAC;SAC;B;100;10;;;;;" )
                                                          
	/* Parametro de validacao - FS_SACSA1
		01 - Usuarios 
        02 - Vendedor - A1_VEND
        03 - Segmento - A1_SATIV1
        04 - Risco - A1_RISCO   
        05 - Valor maximo
		06 - Dias de prazo 
		07 - Midia 
		08 - Natureza
		09 - Conta Contabil
		10 - Tabela de preço
		11 - Condição de Pagto 
	*/

		If !Empty(aInfo) .And. Upper(UsrRetName(__cUserId)) $ Upper(aInfo[01])

	//		If !Altera
			M->A1_VLRCMP:= Val(aInfo[05])
			M->A1_LC	:= Val(aInfo[05])
			M->A1_VENCLC:= Ddatabase + Val(aInfo[06])
			M->A1_RISCO	:= aInfo[04]
	
			If AllTrim(M->A1_VEND) <> aInfo[02] //"SAC"
				cMsgErro  += "O Vendedor para este tipo de cliente deve ser "+aInfo[02]+"."+CRLF
			EndIf
			If AllTrim(M->A1_SATIV1) <> aInfo[03] //"SAC"
				cMsgErro  += "O Segmento para este tipo de cliente deve ser "+aInfo[03]+"."+CRLF
			EndIf
			If !Empty(aInfo[04]) .And. !(AllTrim(M->A1_RISCO) $ aInfo[04]) //"B"
				cMsgErro  += "O Risco para este tipo de cliente deve pertencer a '"+aInfo[04]+"'."+CRLF
			EndIf
			If !Empty(aInfo[07]) .And. !(AllTrim(M->A1_MIDIA) $ aInfo[07]) //"000015"
				cMsgErro  += "A Midia para este tipo de cliente deve pertencer a '"+aInfo[07]+"'."+CRLF
			EndIf
			If !Empty(aInfo[08]) .And. !(AllTrim(M->A1_NATUREZ) $ aInfo[08]) //"B"
				cMsgErro  += "A Natureza para este tipo de cliente deve pertencer a '"+aInfo[08]+"'."+CRLF
			EndIf
			If !Empty(aInfo[09]) .And. !(AllTrim(M->A1_CONTA) $ aInfo[09]) //"B"
				cMsgErro  += "A Conta Contábil para este tipo de cliente deve pertencer a '"+aInfo[09]+"'."+CRLF
			EndIf
			If !Empty(aInfo[10]) .And. !(AllTrim(M->A1_TABELA) $ aInfo[10]) //"B"
				cMsgErro  += "A Tabela de preço para este tipo de cliente deve pertencer a '"+aInfo[10]+"'."+CRLF
			EndIf
			If !Empty(aInfo[11]) .And. !(AllTrim(M->A1_COND) $ aInfo[11]) //"B"
				cMsgErro  += "A Condição de Pagamento para este tipo de cliente deve pertencer a '"+aInfo[11]+"'."+CRLF
			EndIf

//		Else
//			cMsgErro  += "O cadastro não pode ser alterado por esse usuário'."+CRLF			    			
//		EndIf		   
	
			If !Empty( cMsgErro )
				lRet := .F.
//			Aviso("MA030TOK",cMsgErro,{"Ok"},3,"Atenção") 
			//Amedeo (Ajuste para tratamento Portal de Vendas)
				If !IsInCallStacj( "U_FBBXCLI" )
					U_MyAviso("[MA030TOK]",cMsgErro,{"Ok"},3)
				Else
					Aviso( "[MA030TOK]", cMsgErro, {"Ok"}, 3 )
				EndIf
			EndIf

		
		EndIf
	EndIf
/*
If Inclui .Or. Altera
	 	
	If !(M->A1_TIPO == 'X' .Or. ;
		M->A1_EST == 'EX' .Or. ;
		M->A1_COD_MUN == '99999')	 
		        
	    If !(Upper(Rtrim(cUserName)) $ 'COBRANCA3.CREDITO2.CREDITO3.ADV.PLANOVENDAS')
				
			For i:= 1 to LEN(cInscri)
				If !IsDigit(SUBSTR(cInscri,i,1))
					lRet := .F.
					ApMsgStop( 'A inscriçao estadual deve ser numerico!', 'MA030TOK' )
					Exit
				EndIf
			Next

		EndIf
	
	EndIf 

EndIf
*/	                

// Claudino 21/11/16 - I1611-2487
	If Inclui .Or. Altera
		If M->A1_TPJ == "3"
			If M->A1_CONTRIB <> "1"
				lRet := .F.
			
			//Amedeo (Ajuste para tratamento Portal de Vendas)
				If !IsInCallStacj( "U_FBBXCLI" )
					ApMsgStop("Favor preencher o campo Contribuinte igual a Sim, localizado na ABA Fiscais.","MA030TOK")
				Else
					Aviso( "MA030TOK", "Favor preencher o campo Contribuinte igual a Sim, localizado na ABA Fiscais.", {"Ok"}, 2 )
				EndIf

			EndIf
		Else
			If Empty(M->A1_INSCR)
				lRet := .F.
			
			//Amedeo (Ajuste para tratamento Portal de Vendas)
				If !IsInCallStacj( "U_FBBXCLI" )
					ApMsgStop("Favor preencher o campo Inscrição Estadual, localizado na ABA Cadastrais.","MA030TOK")
				Else
					Aviso( "MA030TOK", "Favor preencher o campo Inscrição Estadual, localizado na ABA Cadastrais.", {"Ok"}, 2 )
				EndIf

			EndIf
		EndIf
	EndIf

// Claudino 18/05/16 - I1605-1752
	If lRet .And. Inclui
		If M->A1_PESSOA == "J" .And. Empty(M->A1_CNAE)
			lRet := .F.
//		ApMsgStop("Favor preencher o campo Cod CNAE, localizado na ABA Cadastrais.","MA030TOK")
		
		//Amedeo (Ajuste para tratamento Portal de Vendas)
			If !IsInCallStacj( "U_FBBXCLI" )
				U_MyAviso("[MA030TOK]","Favor preencher o campo Cod CNAE, localizado na ABA Cadastrais.",{"Ok"},3)
			Else
				Aviso( "[MA030TOK]","Favor preencher o campo Cod CNAE, localizado na ABA Cadastrais.", {"Ok"}, 3 )
			EndIf
		
		EndIf
	EndIf

// MOA - I1812-524 - 22/12/2018
	If lRet .And. Inclui
		// Nome / Razão Social		
		If (M->A1_NOME $ ("#|%|*|&|>|<|!|@|$|(|)|_|=|+|{|}|[|]|/|?|\|:|;|°|ª"))
			cMsgAvis  := "Existem caracteres invalidos no campo NOME. Favor verificar!"
			Aviso("[MA030TOK]",cMsgAvis,{"Ok"},3,"Atenção")
			lRet := .F.
		ElseIf M->A1_NOME $ ('"')
			cMsgAvis  := "Aspas duplas ou simples não podem ser utilizadas no campo NOME do cliente!"
			Aviso("[MA030TOK]",cMsgAvis,{"Ok"},3,"Atenção")
			lRet := .F.
			
		// Nome Fantasia
		ElseIf M->A1_NREDUZ $ ("'|#|%|*|&|>|<|!|@|$|(|)|_|=|+|{|}|[|]|/|?|\|:|;|°|ª")
			cMsgAvis  := "Existem caracteres invalidos no campo N FANTASIA. Favor verificar!"
			Aviso("[MA030TOK]",cMsgAvis,{"Ok"},3,"Atenção")
			lRet := .F.
		ElseIf M->A1_NREDUZ $ ('"')
			cMsgAvis  := "Aspas duplas ou simples não podem ser utilizadas no campo N FANTASIA do cliente!"
			Aviso("[MA030TOK]",cMsgAvis,{"Ok"},3,"Atenção")
			lRet := .F.
			
		// Endereço
		ElseIf M->A1_END $ ("'|#|%|*|&|>|<|!|@|$|(|)|_|=|+|{|}|[|]|/|?|\|:|;|°|ª")
			cMsgAvis  := "Existem caracteres invalidos no campo ENDERECO. Favor verificar!"
			Aviso("[MA030TOK]",cMsgAvis,{"Ok"},3,"Atenção")
			lRet := .F.
		ElseIf M->A1_END $ ('"')
			cMsgAvis  := "Aspas duplas ou simples não podem ser utilizadas no campo ENDERECO do cliente!"
			Aviso("[MA030TOK]",cMsgAvis,{"Ok"},3,"Atenção")
			lRet := .F.
			
		// Bairro
		ElseIf M->A1_BAIRRO $ ("'|#|%|*|&|>|<|!|@|$|(|)|_|=|+|{|}|[|]|/|?|\|:|;|°|ª")
			cMsgAvis  := "Existem caracteres invalidos no campo BAIRRO. Favor verificar!"
			Aviso("[MA030TOK]",cMsgAvis,{"Ok"},3,"Atenção")
			lRet := .F.
		ElseIf M->A1_BAIRRO $ ('"')
			cMsgAvis  := "Aspas duplas ou simples não podem ser utilizadas no campo BAIRRO do cliente!"
			Aviso("[MA030TOK]",cMsgAvis,{"Ok"},3,"Atenção")
			lRet := .F.
			
		// Município
		ElseIf M->A1_MUN $ ("'|#|%|*|&|>|<|!|@|$|(|)|_|=|+|{|}|[|]|/|?|\|:|;|°|ª")
			cMsgAvis  := "Existem caracteres invalidos no campo MUNICIPIO. Favor verificar!"
			Aviso("[MA030TOK]",cMsgAvis,{"Ok"},3,"Atenção")
			lRet := .F.
		ElseIf M->A1_MUN $ ('"')
			cMsgAvis  := "Aspas duplas ou simples não podem ser utilizadas no campo MUNICIPIO do cliente!"
			Aviso("[MA030TOK]",cMsgAvis,{"Ok"},3,"Atenção")
			lRet := .F.
		
		// E-mail
		ElseIf M->A1_EMAIL $ ("'|#|%|*|&|>|<|!|$|(|)|=|+|{|}|[|]|/|?|\|:|;|°|ª")
			cMsgAvis  := "Existem caracteres invalidos no campo E-MAIL. Favor verificar!"
			Aviso("[MA030TOK]",cMsgAvis,{"Ok"},3,"Atenção")
			lRet := .F.
		ElseIf M->A1_EMAIL $ ('"')
			cMsgAvis  := "Aspas duplas ou simples não podem ser utilizadas no campo E-MAIL do cliente!"
			Aviso("[MA030TOK]",cMsgAvis,{"Ok"},3,"Atenção")
			lRet := .F.
		EndIf

	EndIf

// Claudino - I1702-1051 - 24/04/17
	If lRet .And. Inclui
		If !EMPTY(SU7->U7_CODVEN) .Or. lValidAll // SOMENTE SE FOR REPRESENTANTE
			If cTipoCli <> "X" // Valida Somente se nao for Exterior
				cCNPJBase := SubStr(M->A1_CGC,1,8)
				dbSelectArea("SA1")
				SA1->(dbSetOrder(3))
				If DbSeek(xFilial("SA1")+cCNPJBase)
					If SA1->A1_PESSOA == M->A1_PESSOA
						lRet := .F.
						If !EMPTY(SU7->U7_CODVEN)
							cMsgAvis := "Já existe um cadastro com essa Raiz de CNPJ, por favor encaminhar o cadastro para o departamento financeiro."
						Else
							cMsgAvis := "Já existe um cadastro com essa Raiz de CNPJ."+CRLF+"Utilize o código : "+SA1->A1_COD+ " e a próxima sequencia de filial."
						EndIf
		//			ApMsgStop("Já existe um cadastro com essa Raiz de CNPJ, por favor encaminhar o cadastro para o departamento financeiro.","MA030TOK")			
					
					//Amedeo (Ajuste para tratamento Portal de Vendas)
						If !IsInCallStacj( "U_FBBXCLI" )
							U_MyAviso("[MA030TOK]",cMsgAvis,{"Ok"},3)
						Else
							Aviso( "[MA030TOK]", cMsgAvis, {"Ok"}, 3)
						EndIf
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf
    
// Roberto Souza - 28/09/2017
// I1706-2048 - Cadastro de Cliente do Exterior
	If cTipoCli == "X"
		If !Empty(M->A1_CGC)
			cMsgAvis := "O campo 'CNPJ' não deve ser preenchido para clientes do tipo "+cTipoCli+"."
			lRet := .F.
		
		//Amedeo (Ajuste para tratamento Portal de Vendas)
			If !IsInCallStacj( "U_FBBXCLI" )
				U_MyAviso("[MA030TOK]",cMsgAvis,{"Ok"},3)
			Else
				Aviso( "[MA030TOK]", cMsgAvis, {"Ok"}, 3 )
			EndIf

		EndIf
	Else
		If Empty(M->A1_CGC)
			cMsgAvis := "O campo 'CNPJ' é obrigatório para clientes do tipo "+cTipoCli+"."
			lRet := .F.
		
		//Amedeo (Ajuste para tratamento Portal de Vendas)
			If !IsInCallStacj( "U_FBBXCLI" )
				U_MyAviso("[MA030TOK]",cMsgAvis,{"Ok"},3)
			Else
				Aviso( "[MA030TOK]", cMsgAvis, {"Ok"}, 3 )
			EndIf

		EndIf
	EndIf


// LOBATO 13/11/13
// ROTINA DE CADASTRO DE CONTATOS DE CLIENTES SOMENTE PELO MODULO CALL CENTER
// E OPERADORES QUE ESTÃO CADASTRADOS NA TABELA DE VENDEDORES.
                  
	IF lRet .And. Inclui .AND. nMODULO == 13 // INCLUSÃO PELO CALL CENTER
		IF !EMPTY(SU7->U7_CODVEN) // SOMENTE SE FOR REPRESENTANTE
		
		//Amedeo (Ajuste para tratamento Portal de Vendas)
			If !IsInCallStacj( "U_FBBXCLI" )
				U_CConta(M->A1_COD,M->A1_LOJA)
			EndIf

		ENDIF
	ENDIF

// FIM DA ROTINA DE CADASTRO DE CONTATOS PELO CALL CENTER
// LOBATO 13/11/13

Return (lRet)

// LOBATO 19/11/13
// ROTINAS DE CADASTRO DE CONTATOS PELO CALL CENTER

USER FUNCTION CConta(cCODCLI,cLOJA)
	PRIVATE oSAY
	PRIVATE oFONT	:= TFONT():NEW("Courier New",,-12,.T.,.T.)
	PRIVATE aFONT	:= TFONT():NEW("Arial",,-12,.T.,.T.)
	PRIVATE bFONT	:= TFONT():NEW("Arial",,-11,.T.,.T.)
	PRIVATE cFONT	:= TFONT():NEW("Arial",,-11,.T.,)
	PRIVATE eFONT	:= TFONT():NEW("Arial",,-16,.T.,.T.)
	PRIVATE nOPC1	:= 0
	PRIVATE oBUTTON
	PRIVATE oDLG
                   
	WHILE .T.

	//variáveis de cadastro                        
		cNome1 	:= cNome2  := cNome3  := SPACE(50)
		cEmail1	:= cEmail2 := cEmail3 := SPACE(80)
		cDDD1	:= cDDD2   := cDDD3   := SPACE(3)
		cFone1	:= cFone2  := cFone3  := SPACE(15)
		cCodCG1	:= cCodCG2 := cCodCG3 := SPACE(20)
		cDESCF1	:= cDESCF2 := cDESCF3 := SPACE(40)
		cFRES1	:= cFRES2  := cFRES3  := SPACE(15)
		cCEL1	:= cCEL2   := cCEL3	  := SPACE(15)
		cEND1	:= cEND2   := cEND3	  := SPACE(30)
		cBAIR1	:= cBAIR2  := cBAIR3  := SPACE(30)
		cMUN1	:= cMUN2   := cMUN3	  := SPACE(20)
		cEST1	:= cEST2   := cEST3	  := SPACE(2)
		cCEP1	:= cCEP2   := cCEP3	  := SPACE(8)

                        
	//inicialização da tela de cadastros
	
	//DEFINE MSDIALOG oDLG FROM 0,0 TO 500,900 PIXEL TITLE "Cadastro de Contatos" // Claudino - 11/04/17
		DEFINE MSDIALOG oDLG FROM 0,0 TO 210,900 PIXEL TITLE "Cadastro de Contatos"   // Claudino - 11/04/17
	
	// item 1 - Vendas
		@ 001,001 TO 005,055
		@ 005,007 SAY OEMTOANSI("Responsável por Vendas") FONT aFONT COLOR CLR_BLACK,CLR_RED OF oDLG PIXEL

		@ 018,010 SAY OEMTOANSI("Nome do Contato: ") FONT bFONT COLOR CLR_BLACK,CLR_RED OF oDLG PIXEL
		@ 018,060 SAY OEMTOANSI("*") FONT eFONT COLOR CLR_HRED,CLR_BLACK OF oDLG PIXEL
		@ 018,070 MSGET oGET VAR cNome1  SIZE 107,08 PICTURE "@!" OF oDLG PIXEL

		@ 031,010 SAY OEMTOANSI("E-mail do Contato: ") FONT bFONT COLOR CLR_BLACK,CLR_RED OF oDLG PIXEL
		@ 031,060 SAY OEMTOANSI("*") FONT eFONT COLOR CLR_HRED,CLR_BLACK OF oDLG PIXEL
		@ 031,070 MSGET oGET VAR cEmail1  SIZE 157,08 OF oDLG PIXEL

		@ 044,010 SAY OEMTOANSI("DDD: ") FONT bFONT COLOR CLR_BLACK,CLR_RED OF oDLG PIXEL
		@ 044,023 SAY OEMTOANSI("*") FONT eFONT COLOR CLR_HRED,CLR_BLACK OF oDLG PIXEL
		@ 044,070 MSGET oGET VAR cDDD1  SIZE 27,08 PICTURE "@E 999" OF oDLG PIXEL
        
		@ 044,135 SAY OEMTOANSI("Fone Coml: ") FONT bFONT COLOR CLR_BLACK,CLR_RED OF oDLG PIXEL
		@ 044,166 SAY OEMTOANSI("*") FONT eFONT COLOR CLR_HRED,CLR_BLACK OF oDLG PIXEL
		@ 044,170 MSGET oGET VAR cFone1  SIZE 57,08 Picture "@E 99999999" OF oDLG PIXEL
	
		@ 057,010 SAY OEMTOANSI("Cargo: ") FONT bFONT COLOR CLR_BLACK,CLR_RED OF oDLG PIXEL
		@ 057,029 SAY OEMTOANSI("*") FONT eFONT COLOR CLR_HRED,CLR_BLACK OF oDLG PIXEL
		@ 057,070 MSGET oGET VAR cCodCG1  SIZE 57,08 Picture "@E 999999" OF oDLG PIXEL F3 "SUM" VALID(PGDESC(cCodCG1,1))
		@ 059,130 SAY OEMTOANSI("- "+cDESCF1) FONT cFONT COLOR CLR_BLACK,CLR_RED OF oDLG PIXEL

		@ 018,249 SAY OEMTOANSI("Endereço: ") FONT cFONT COLOR CLR_BLACK,CLR_RED OF oDLG PIXEL
		@ 018,280 MSGET oGET VAR cEnd1  SIZE 87,08 PICTURE "@!" OF oDLG PIXEL

		@ 031,249 SAY OEMTOANSI("Bairro: ") FONT cFONT COLOR CLR_BLACK,CLR_RED OF oDLG PIXEL
		@ 031,280 MSGET oGET VAR cBair1  SIZE 87,08 PICTURE "@!" OF oDLG PIXEL

		@ 031,379 SAY OEMTOANSI("CEP: ") FONT cFONT COLOR CLR_BLACK,CLR_RED OF oDLG PIXEL
		@ 031,395 MSGET oGET VAR cCEP1  SIZE 27,08 Picture "@E 99999999" OF oDLG PIXEL

		@ 044,249 SAY OEMTOANSI("Municipio: ") FONT cFONT COLOR CLR_BLACK,CLR_RED OF oDLG PIXEL
		@ 044,280 MSGET oGET VAR cMun1  SIZE 87,08 PICTURE "@!" OF oDLG PIXEL
        
		@ 044,379 SAY OEMTOANSI("UF: ") FONT cFONT COLOR CLR_BLACK,CLR_RED OF oDLG PIXEL
		@ 044,395 MSGET oGET VAR cEst1  SIZE 17,08 PICTURE "@!" OF oDLG PIXEL F3 "12" VALID(TPUF(cEst1))

		@ 057,249 SAY OEMTOANSI("Fone Res: ") FONT bFONT COLOR CLR_BLACK,CLR_RED OF oDLG PIXEL
		@ 057,276 SAY OEMTOANSI("*") FONT eFONT COLOR CLR_HRED,CLR_BLACK OF oDLG PIXEL
		@ 057,280 MSGET oGET VAR cFres1  SIZE 57,08 Picture "@E 99999999" OF oDLG PIXEL

		@ 057,349 SAY OEMTOANSI("Celular: ") FONT cFONT COLOR CLR_BLACK,CLR_RED OF oDLG PIXEL
		@ 057,373 MSGET oGET VAR cCel1  SIZE 57,08 Picture "@E 999999999" OF oDLG PIXEL

	// item 2 - Compras
    // Claudino - 11/04/17
    /*                   
	@ 006,001 TO 010,055

	@ 073,007 SAY OEMTOANSI("Responsável por Compras") FONT aFONT COLOR CLR_BLACK,CLR_RED OF oDLG PIXEL

	@ 088,010 SAY OEMTOANSI("Nome do Contato: ") FONT bFONT COLOR CLR_BLACK,CLR_RED OF oDLG PIXEL
	@ 088,060 SAY OEMTOANSI("*") FONT eFONT COLOR CLR_HRED,CLR_BLACK OF oDLG PIXEL 		
	@ 088,070 MSGET oGET VAR cNome2  SIZE 107,08 PICTURE "@!" OF oDLG PIXEL

	@ 101,010 SAY OEMTOANSI("E-mail do Contato: ") FONT bFONT COLOR CLR_BLACK,CLR_RED OF oDLG PIXEL
	@ 101,060 SAY OEMTOANSI("*") FONT eFONT COLOR CLR_HRED,CLR_BLACK OF oDLG PIXEL 	
	@ 101,070 MSGET oGET VAR cEmail2  SIZE 157,08 OF oDLG PIXEL

	@ 114,010 SAY OEMTOANSI("DDD: ") FONT bFONT COLOR CLR_BLACK,CLR_RED OF oDLG PIXEL
	@ 114,023 SAY OEMTOANSI("*") FONT eFONT COLOR CLR_HRED,CLR_BLACK OF oDLG PIXEL 	
	@ 114,070 MSGET oGET VAR cDDD2  SIZE 27,08 Picture "@E 999" OF oDLG PIXEL
        
	@ 114,135 SAY OEMTOANSI("Fone Coml: ") FONT bFONT COLOR CLR_BLACK,CLR_RED OF oDLG PIXEL
	@ 114,166 SAY OEMTOANSI("*") FONT eFONT COLOR CLR_HRED,CLR_BLACK OF oDLG PIXEL 		
	@ 114,170 MSGET oGET VAR cFone2  SIZE 57,08 Picture "@E 9999-9999" OF oDLG PIXEL 
	
	@ 127,010 SAY OEMTOANSI("Cargo: ") FONT bFONT COLOR CLR_BLACK,CLR_RED OF oDLG PIXEL 
	@ 127,029 SAY OEMTOANSI("*") FONT eFONT COLOR CLR_HRED,CLR_BLACK OF oDLG PIXEL 		
	@ 127,070 MSGET oGET VAR cCodCG2  SIZE 57,08 Picture "@E 999999" OF oDLG PIXEL F3 "SUM" VALID(PGDESC(cCodCG2,2))
	@ 129,130 SAY OEMTOANSI("- "+cDESCF2) FONT cFONT COLOR CLR_BLACK,CLR_RED OF oDLG PIXEL

	@ 088,249 SAY OEMTOANSI("Endereço: ") FONT cFONT COLOR CLR_BLACK,CLR_RED OF oDLG PIXEL
	@ 088,280 MSGET oGET VAR cEnd2  SIZE 87,08 PICTURE "@!" OF oDLG PIXEL

	@ 101,249 SAY OEMTOANSI("Bairro: ") FONT cFONT COLOR CLR_BLACK,CLR_RED OF oDLG PIXEL
	@ 101,280 MSGET oGET VAR cBair2  SIZE 87,08 PICTURE "@!" OF oDLG PIXEL

	@ 101,379 SAY OEMTOANSI("CEP: ") FONT cFONT COLOR CLR_BLACK,CLR_RED OF oDLG PIXEL
	@ 101,395 MSGET oGET VAR cCEP2  SIZE 27,08 Picture "@E 99999-999" OF oDLG PIXEL

	@ 114,249 SAY OEMTOANSI("Municipio: ") FONT cFONT COLOR CLR_BLACK,CLR_RED OF oDLG PIXEL
	@ 114,280 MSGET oGET VAR cMun2  SIZE 87,08 PICTURE "@!" OF oDLG PIXEL
        
	@ 114,379 SAY OEMTOANSI("UF: ") FONT cFONT COLOR CLR_BLACK,CLR_RED OF oDLG PIXEL
	@ 114,395 MSGET oGET VAR cEst2  SIZE 17,08 PICTURE "@!" OF oDLG PIXEL F3 "12" VALID(TPUF(cEst2))

	@ 127,249 SAY OEMTOANSI("Fone Res: ") FONT bFONT COLOR CLR_BLACK,CLR_RED OF oDLG PIXEL
	@ 127,276 SAY OEMTOANSI("*") FONT eFONT COLOR CLR_HRED,CLR_BLACK OF oDLG PIXEL 			
	@ 127,280 MSGET oGET VAR cFres2  SIZE 57,08 Picture "@E 9999-9999" OF oDLG PIXEL 

	@ 127,350 SAY OEMTOANSI("Celular: ") FONT cFONT COLOR CLR_BLACK,CLR_RED OF oDLG PIXEL
	@ 127,373 MSGET oGET VAR cCel2  SIZE 57,08 Picture "@E 99999-9999" OF oDLG PIXEL 

    // item 3 - Marketing

	@ 011,001 TO 015,055

	@ 143,007 SAY OEMTOANSI("Responsável por Marketing") FONT aFONT COLOR CLR_BLACK,CLR_RED OF oDLG PIXEL

	@ 158,010 SAY OEMTOANSI("Nome do Contato: ") FONT bFONT COLOR CLR_BLACK,CLR_RED OF oDLG PIXEL
	@ 158,060 SAY OEMTOANSI("*") FONT eFONT COLOR CLR_HRED,CLR_BLACK OF oDLG PIXEL 		
	@ 158,070 MSGET oGET VAR cNome3  SIZE 107,08 PICTURE "@!" OF oDLG PIXEL

	@ 171,010 SAY OEMTOANSI("E-mail do Contato: ") FONT bFONT COLOR CLR_BLACK,CLR_RED OF oDLG PIXEL
	@ 171,060 SAY OEMTOANSI("*") FONT eFONT COLOR CLR_HRED,CLR_BLACK OF oDLG PIXEL 	
	@ 171,070 MSGET oGET VAR cEmail3  SIZE 157,08 OF oDLG PIXEL

	@ 184,010 SAY OEMTOANSI("DDD: ") FONT bFONT COLOR CLR_BLACK,CLR_RED OF oDLG PIXEL
	@ 184,023 SAY OEMTOANSI("*") FONT eFONT COLOR CLR_HRED,CLR_BLACK OF oDLG PIXEL 	
	@ 184,070 MSGET oGET VAR cDDD3  SIZE 27,08 Picture "@E 999" OF oDLG PIXEL
        
	@ 184,135 SAY OEMTOANSI("Fone Coml: ") FONT bFONT COLOR CLR_BLACK,CLR_RED OF oDLG PIXEL
	@ 184,166 SAY OEMTOANSI("*") FONT eFONT COLOR CLR_HRED,CLR_BLACK OF oDLG PIXEL 		
	@ 184,170 MSGET oGET VAR cFone3  SIZE 57,08 Picture "@E 9999-9999" OF oDLG PIXEL 
	
	@ 197,010 SAY OEMTOANSI("Cargo: ") FONT bFONT COLOR CLR_BLACK,CLR_RED OF oDLG PIXEL
	@ 197,029 SAY OEMTOANSI("*") FONT eFONT COLOR CLR_HRED,CLR_BLACK OF oDLG PIXEL 		
	@ 197,070 MSGET oGET VAR cCodCG3  SIZE 57,08 Picture "@E 999999" OF oDLG PIXEL F3 "SUM" VALID(PGDESC(cCodCG3,3))
	@ 199,130 SAY OEMTOANSI("- "+cDESCF3) FONT cFONT COLOR CLR_BLACK,CLR_RED OF oDLG PIXEL

	@ 158,249 SAY OEMTOANSI("Endereço: ") FONT cFONT COLOR CLR_BLACK,CLR_RED OF oDLG PIXEL
	@ 158,280 MSGET oGET VAR cEnd3  SIZE 87,08 PICTURE "@!" OF oDLG PIXEL

	@ 171,249 SAY OEMTOANSI("Bairro: ") FONT cFONT COLOR CLR_BLACK,CLR_RED OF oDLG PIXEL
	@ 171,280 MSGET oGET VAR cBair3  SIZE 87,08 PICTURE "@!" OF oDLG PIXEL

	@ 171,379 SAY OEMTOANSI("CEP: ") FONT cFONT COLOR CLR_BLACK,CLR_RED OF oDLG PIXEL
	@ 171,395 MSGET oGET VAR cCEP3  SIZE 27,08 Picture "@E 99999-999" OF oDLG PIXEL

	@ 184,249 SAY OEMTOANSI("Municipio: ") FONT cFONT COLOR CLR_BLACK,CLR_RED OF oDLG PIXEL
	@ 184,280 MSGET oGET VAR cMun3  SIZE 87,08 PICTURE "@!" OF oDLG PIXEL
        
	@ 184,379 SAY OEMTOANSI("UF: ") FONT cFONT COLOR CLR_BLACK,CLR_RED OF oDLG PIXEL
	@ 184,395 MSGET oGET VAR cEst3  SIZE 17,08 PICTURE "@!" OF oDLG PIXEL F3 "12" VALID(TPUF(cEst3))

	@ 197,249 SAY OEMTOANSI("Fone Res: ") FONT bFONT COLOR CLR_BLACK,CLR_RED OF oDLG PIXEL 
	@ 197,276 SAY OEMTOANSI("*") FONT eFONT COLOR CLR_HRED,CLR_BLACK OF oDLG PIXEL 			
	@ 197,280 MSGET oGET VAR cFres3  SIZE 57,08 Picture "@E 9999-9999" OF oDLG PIXEL 

	@ 197,349 SAY OEMTOANSI("Celular: ") FONT cFONT COLOR CLR_BLACK,CLR_RED OF oDLG PIXEL
	@ 197,373 MSGET oGET VAR cCel3  SIZE 57,08 Picture "@E 99999-9999" OF oDLG PIXEL 
	*/
	
	// botõesde confirma ou cancela

	//@ 230,355 BMPBUTTON TYPE 1 ACTION(nOPC1 := 1, GRAVA(cCODCLI,cLOJA))
	//@ 230,385 BMPBUTTON TYPE 2 ACTION(nOPC1 := 3, CLOSE(oDLG))
		@ 075,385 BMPBUTTON TYPE 1 ACTION(nOPC1 := 1, GRAVA(cCODCLI,cLOJA)) // Claudino - 11/04/17
		@ 075,415 BMPBUTTON TYPE 2 ACTION(nOPC1 := 3, CLOSE(oDLG))          // Claudino - 11/04/17
    
		ACTIVATE MSDIALOG oDLG CENTERED

		EXIT

	END

RETURN


STATIC FUNCTION GRAVA(cCODCLI,cLOJA)
	LOCAL lVEND := lCOMP := lMKT := .T.

	IF !MSGYESNO("Confirma dados de Contatos?","Cadastro de Contatos")
		CLOSE(oDLG)
		RETURN
	endif

// VALIDAÇÕES DE CAMPOS OBRIGATÓRIOS

	IF EMPTY(cNome1) //.OR. EMPTY(cNome2) .OR. EMPTY(cNome3)
		MSGALERT("Nome do Contato não pode estar em branco!")
		RETURN
	ENDIF
	IF EMPTY(cEmail1) //.OR. EMPTY(cEmail2) .OR. EMPTY(cEmail3)
		MSGALERT("Email do Contato não pode estar em branco!")
		RETURN
	ENDIF
	IF EMPTY(cDDD1) //.OR. EMPTY(cDDD2) .OR. EMPTY(cDDD3)
		MSGALERT("DDD do Contato não pode estar em branco!")
		RETURN
	ENDIF
	IF EMPTY(cFone1) //.OR. EMPTY(cFone2) .OR. EMPTY(cFone3)
		MSGALERT("Fone Comercial do Contato não pode estar em branco!")
		RETURN
	ENDIF
	IF EMPTY(cCodCG1) //.OR. EMPTY(cCodCG2) .OR. EMPTY(cCodCG3)
		MSGALERT("Cargo do Contato não pode estar em branco!")
		RETURN
	ENDIF
	IF EMPTY(cFres1) //.OR. EMPTY(cFres2) .OR. EMPTY(cFres3)
		MSGALERT("Fone Residencial do Contato não pode estar em branco!")
		RETURN
	ENDIF

// CONTATO DE VENDAS
	aTMP := {}
	aadd(aTMP,{"U5_CONTAT" 	,cNome1,Nil})
	aadd(aTMP,{"U5_END" 	,cEND1,Nil})
	aadd(aTMP,{"U5_BAIRRO" 	,cBAIR1,Nil})
	aadd(aTMP,{"U5_MUN" 	,cMUN1,Nil})
	aadd(aTMP,{"U5_EST"	 	,cEST1,Nil})
	aadd(aTMP,{"U5_CEP" 	,cCEP1,Nil})
	aadd(aTMP,{"U5_DDD" 	,cDDD1,Nil})
	aadd(aTMP,{"U5_FONE" 	,cFRES1,Nil})
	aadd(aTMP,{"U5_CELULAR" ,cCEL1,Nil})
	aadd(aTMP,{"U5_FCOM1" 	,cFone1,Nil})
	aadd(aTMP,{"U5_EMAIL" 	,cEmail1,Nil})
	aadd(aTMP,{"U5_ATIVO" 	,"1",Nil})
	aadd(aTMP,{"U5_TIPO" 	,"2",Nil})
	aadd(aTMP,{"U5_FUNCAO" 	,cCodCG1,Nil})
	aadd(aTMP,{"U5_DFUNCAO" ,cDESCF1,Nil})
	aadd(aTMP,{"U5_DEPTO" 	,"000000010",Nil})
	aadd(aTMP,{"U5_DDEPTO" 	,"VENDAS",Nil})

	
	Private lMsErroAuto := .f.
	Private lMsHelpAuto := .T.

	MSExecAuto({|x,y| TMKA070(x,y)},aTMP,3)
			
	IF lMsErroAuto
		lRotina1 := .F.
		lMsErroAuto := .f.
		MSGALERT("ERRO NO PROCESSO")
		MostraErro()
		lVEND := .F.
	Else
		ConfirmSX8()
	
		DBSELECTAREA("AC8")
		RECLOCK("AC8",.T.)
		FIELD->AC8_FILIAL	:=	XFILIAL("AC8")
		FIELD->AC8_ENTIDA	:=	"SA1"
		FIELD->AC8_CODENT	:= 	cCODCLI+cLOJA
		FIELD->AC8_CODCON	:= 	SU5->U5_CODCONT
		MSUNLOCK()
	
		cCODAGB := GETSX8NUM("AGB","AGB_CODIGO")
	
		DBSELECTAREA("AGB")
		RECLOCK("AGB",.T.)
		FIELD->AGB_FILIAL 	:= XFILIAL("AGB")
		FIELD->AGB_CODIGO	:= cCODAGB
		FIELD->AGB_ENTIDA	:= "SU5"
		FIELD->AGB_CODENT	:= SU5->U5_CODCONT
		FIELD->AGB_TIPO		:= "4"
		FIELD->AGB_PADRAO	:= "1"
		FIELD->AGB_DDD		:= cDDD1
		FIELD->AGB_TELEFO	:= cFRES1
		MSUNLOCK("AGB")
		CONFIRMSX8()
	                        
		RECLOCK("SU5",.F.)
		FIELD->U5_AGBFAX	:= cCODAGB
		MSUNLOCK()
	
	EndIf

/* Claudino - 11/04/17	
// CONTATO DE COMPRAS
aTMP := {}
aadd(aTMP,{"U5_CONTAT" 	,cNome2,Nil})    
aadd(aTMP,{"U5_END" 	,cEND2,Nil})    	    
aadd(aTMP,{"U5_BAIRRO" 	,cBAIR2,Nil})    
aadd(aTMP,{"U5_MUN" 	,cMUN2,Nil}) 
aadd(aTMP,{"U5_EST"	 	,cEST2,Nil})    
aadd(aTMP,{"U5_CEP" 	,cCEP2,Nil})    
aadd(aTMP,{"U5_DDD" 	,cDDD2,Nil})    
aadd(aTMP,{"U5_FONE" 	,cFRES2,Nil})    
aadd(aTMP,{"U5_CELULAR" ,cCEL2,Nil})    
aadd(aTMP,{"U5_FCOM1" 	,cFone2,Nil})    
aadd(aTMP,{"U5_EMAIL" 	,cEmail2,Nil})    
aadd(aTMP,{"U5_ATIVO" 	,"1",Nil})    
aadd(aTMP,{"U5_TIPO" 	,"2",Nil})    
aadd(aTMP,{"U5_FUNCAO" 	,cCodCG2,Nil})    
aadd(aTMP,{"U5_DFUNCAO" ,cDESCF2,Nil})    
aadd(aTMP,{"U5_DEPTO" 	,"000000001",Nil})    
aadd(aTMP,{"U5_DDEPTO" 	,"COMPRAS",Nil})       
	
Private lMsErroAuto := .f.
Private lMsHelpAuto := .T.

MSExecAuto({|x,y| TMKA070(x,y)},aTMP,3)
			
IF lMsErroAuto
	lRotina1 := .F.
	lMsErroAuto := .f.
	MSGALERT("ERRO NO PROCESSO")
	MostraErro()
	lCOMP := .F.
Else
	ConfirmSX8()               

	DBSELECTAREA("AC8")
	RECLOCK("AC8",.T.)
	FIELD->AC8_FILIAL	:=	XFILIAL("AC8")
	FIELD->AC8_ENTIDA	:=	"SA1"
	FIELD->AC8_CODENT	:= 	cCODCLI+cLOJA
	FIELD->AC8_CODCON	:= 	SU5->U5_CODCONT
	MSUNLOCK()        
	
	cCODAGB := GETSX8NUM("AGB","AGB_CODIGO")
	
	DBSELECTAREA("AGB")
	RECLOCK("AGB",.T.)
	FIELD->AGB_FILIAL 	:= XFILIAL("AGB")
	FIELD->AGB_CODIGO	:= cCODAGB
	FIELD->AGB_ENTIDA	:= "SU5"
	FIELD->AGB_CODENT	:= SU5->U5_CODCONT
	FIELD->AGB_TIPO		:= "4"
	FIELD->AGB_PADRAO	:= "1"
	FIELD->AGB_DDD		:= cDDD2
	FIELD->AGB_TELEFO	:= cFRES2
	MSUNLOCK("AGB")
	CONFIRMSX8()

	RECLOCK("SU5",.F.)
	FIELD->U5_AGBFAX	:= cCODAGB
	MSUNLOCK()
EndIf


// CONTATO DE MARKETING
aTMP := {}
aadd(aTMP,{"U5_CONTAT" 	,cNome3,Nil})    
aadd(aTMP,{"U5_END" 	,cEND3,Nil})    	    
aadd(aTMP,{"U5_BAIRRO" 	,cBAIR3,Nil})    
aadd(aTMP,{"U5_MUN" 	,cMUN3,Nil}) 
aadd(aTMP,{"U5_EST"	 	,cEST3,Nil})    
aadd(aTMP,{"U5_CEP" 	,cCEP3,Nil})    
aadd(aTMP,{"U5_DDD" 	,cDDD3,Nil})    
aadd(aTMP,{"U5_FONE" 	,cFRES3,Nil})    
aadd(aTMP,{"U5_CELULAR" ,cCEL3,Nil})    
aadd(aTMP,{"U5_FCOM1" 	,cFone3,Nil})    
aadd(aTMP,{"U5_EMAIL" 	,cEmail3,Nil})    
aadd(aTMP,{"U5_ATIVO" 	,"1",Nil})    
aadd(aTMP,{"U5_TIPO" 	,"2",Nil})    
aadd(aTMP,{"U5_FUNCAO" 	,cCodCG3,Nil})    
aadd(aTMP,{"U5_DFUNCAO" ,cDESCF3,Nil})    
aadd(aTMP,{"U5_DEPTO" 	,"000000002",Nil})    
aadd(aTMP,{"U5_DDEPTO" 	,"MARKETING",Nil})       
	
Private lMsErroAuto := .f.
Private lMsHelpAuto := .T.

MSExecAuto({|x,y| TMKA070(x,y)},aTMP,3)
			
IF lMsErroAuto
	lRotina1 := .F.
	lMsErroAuto := .f.
	MSGALERT("ERRO NO PROCESSO")
	MostraErro()
	lMKT := .F.
Else
	ConfirmSX8()

	DBSELECTAREA("AC8")
	RECLOCK("AC8",.T.)
	FIELD->AC8_FILIAL	:=	XFILIAL("AC8")
	FIELD->AC8_ENTIDA	:=	"SA1"
	FIELD->AC8_CODENT	:= 	cCODCLI+cLOJA
	FIELD->AC8_CODCON	:= 	SU5->U5_CODCONT
	MSUNLOCK()                   
	
	cCODAGB := GETSX8NUM("AGB","AGB_CODIGO")
	
	DBSELECTAREA("AGB")
	RECLOCK("AGB",.T.)
	FIELD->AGB_FILIAL 	:= XFILIAL("AGB")
	FIELD->AGB_CODIGO	:= cCODAGB
	FIELD->AGB_ENTIDA	:= "SU5"
	FIELD->AGB_CODENT	:= SU5->U5_CODCONT
	FIELD->AGB_TIPO		:= "4"
	FIELD->AGB_PADRAO	:= "1"
	FIELD->AGB_DDD		:= cDDD3
	FIELD->AGB_TELEFO	:= cFRES3
	MSUNLOCK("AGB")
	CONFIRMSX8()
	
	RECLOCK("SU5",.F.)
	FIELD->U5_AGBFAX	:= cCODAGB
	MSUNLOCK()

EndIf
*/

	IF lVEND //.AND. lCOMP .AND. lMKT
		MSGALERT("Contatos e Relacionamento Gravados Com Sucesso!")
	endif
             
	CLOSE(oDLG)

RETURN

                                                                             
STATIC FUNCTION PGDESC(cCOD,nITEM)
	LOCAL lMRET := .T.
                             
	DBSELECTAREA("SUM")
	DBSETORDER(1)
	DBGOTOP()
	IF!DBSEEK(XFILIAL("SUM")+cCOD)
		lMRET := .F.
		MSGALERT("Código do Cargo não Localizado")
		RETURN(lMRET)
	ENDIF
      
	IF nITEM == 1
		cDESCF1 := SUM->UM_DESC
	ELSEIF nITEM == 2
		cDESCF2 := SUM->UM_DESC
	ELSEIF nITEM == 3
		cDESCF3 := SUM->UM_DESC
	ENDIF
	
	oDLG:REFRESH()

RETURN(lMRET)

                                                                                                  
STATIC FUNCTION TPUF(cEst)
	LOCAL lERET := .T.

	IF !EMPTY(cEST)
		DBSELECTAREA("SX5")
		DBSETORDER(1)
		DBGOTOP()
		IF !DBSEEK(XFILIAL("SX5")+"12"+cEST)
			lERET := .F.
			MSGALERT("UF não localizada")
		ENDIF
	ENDIF
                               
RETURN(lERET)

// FIM ROTINAS DE CADASTRO DE CONTATOS PELO CALL CENTER
// LOBATO 19/11/13
