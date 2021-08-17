#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "FWMVCDEF.CH"

Static __oModelCTB := NIL // variavel oModel para substituir msexecauto em MVC

/*/{Protheus.doc} M030PALT
//TODO ALTERACAO CLIENTE ,SE DESBLOQUEIO CRIA CONTA CONTABIL.
@author ISAIAS CHIPOCH 
@since 24/03/2016
@version 1.0
@obs 	ATUALIZAÇÃO PADRÃO MVC - MOA - 17/10/18 
@return lRet True ou False.
@type function

>> Validado em Base Teste 31/07/2020 - Andre Salgado
/*/

User Function M030PALT()

	Local nOpcao	:= PARAMIXB[1]
	Local lRet	 	:= .T.
	Local cContrib	:= ''
	Local cConta	:= ''
	Local cConRedz	:= Trim(SA1->A1_COD)			//Variavel para Busca a Conta CLIENTE "01" para atender Filiais
	Local cCliLoj	:= SA1->A1_COD + SA1->A1_LOJA	//Indice e conteudo no campo COD.REDUZIDO CONTABIL
	Local cNome		:= AllTrim(SA1->A1_NOME) 		//Nome da Conta Contabil a ser criada

	If nOpcao == 1

		RecLock("SA1",.F.)
		SA1->A1_NOME		:= StrTran(SA1->A1_NOME			,chr(9)," ")
		SA1->A1_END			:= StrTran(SA1->A1_END			,chr(9)," ")
		SA1->A1_COMPLEM 	:= StrTran(SA1->A1_COMPLEM		,chr(9)," ")
		SA1->A1_BAIRRO		:= StrTran(SA1->A1_BAIRRO		,chr(9)," ")
		SA1->A1_MUN			:= StrTran(SA1->A1_MUN			,chr(9)," ")
		SA1->A1_OBS			:= StrTran(SA1->A1_OBS			,chr(9)," ")
		SA1->A1_XFBEXP		:= ""
		SA1->(MsUnLock())

		If SA1->A1_TIPO <> 'X'
			If SA1->A1_MSBLQL <> '1' // If SA1->A1_MSBLQL == "2" - MOA 16/10/18
				If ALLTRIM(SA1->A1_CONTA) == '1102010001' .or. Empty(Trim(SA1->A1_CONTA))
					If SA1->A1_LOJA <> '01'

						cConta := Posicione("SA1",1,xFilial("SA1")+cConRedz+"01","A1_CONTA")

						If !Empty(cConta)
							dbselectarea("SA1")
							SA1->(dbsetorder(1))
							If SA1->(dbseek(xFilial("SA1")+cCliLoj))

								//Grava conta contabil no Cliente
								Reclock( "SA1" , .F.)
								SA1->A1_CONTA:= cConta
								MsUnlock()

							EndIf
						EndIf

					Else

						MsAguarde({|| INC_CT1(cCliLoj,cNome,cConRedz) }, 'Conta Contabil...', "Aguarde, criando conta...", .T.)

					EndIf
				EndIf
			EndIf
		EndIf

	EndIf

Return lRet


//Exemplo de rotina automática para inclusão de contas contábeis no ambiente Contabilidade Gerencial (SigaCTB).
/// ROTINA AUTOMATICA - INCLUSAO DE CONTA CONTABIL CTB
//-------------------------------------------------------------------------------------

/*/{Protheus.doc} INC_CT1
Rotina Automática - Inclusão de Conta Contábil

@type 		function
@author 	Maurício Aureliano
@since 		18/10/2018
@version 	P12
@return nil
/*/ 
//-------------------------------------------------------------------------------------

Static Function INC_CT1(cCliLoj,cNome,cConRedz)

	Local nOpcAuto		:= 0
	Local nX
	Local oCT1
	Local aLog
	Local cLog			:=""
	Local lRet			:= .T.

	Local cCta			:= ""
	Local cDesc			:= cNome
	Local cNtsped		:= "01"
	Local cNtacta		:= "01"
	Local cIndnat		:= "1"
	Local cClasse		:= "2"
	Local dData			:= ctod("01/01/80")
	Local cNormal		:= "1"
	Local cCtaCli		:= "110201" // Conta Padrão - Clientes Nacionais
	Local cConta		:= ""
	Local cContaCT1		:= ""
	Local cAliasCT1		:= GetNextAlias()
	Local cAliasCT12	:= GetNextAlias()
	Local nCont			:= 0
	
	// -------------------------------------------------------------------- //
	// -- Bloco completo alterado por Bia Ferreira - Ethosx - 15/01/2020 -- //
	// -------------------------------------------------------------------- //
	
	cQuery := " SELECT MAX(CT1_CONTA) CT1CONTA "
	cQuery += " FROM " + RetSqlName("CT1") + " CT1 "
	cQuery += " WHERE CT1_FILIAL = '" + xFilial("CT1") + "' "
	cQuery += " AND CT1_CTASUP = '110201' "
	
	//cQuery += " AND CT1_CONTA NOT IN ('110201ZZZY','110201ZZZZ') "
	//-- Correção André Salgado/Introde - 05/08/2020
	cQuery += " AND LEFT(CT1_CONTA,7)<> '110201Z' "
	cQuery += " AND D_E_L_E_T_ = '' "
	cQuery := ChangeQuery(cQuery)
	
	dbUseArea(.T.,'TOPCONN', TCGenQry(,,cQuery), cAliasCT1,.F.,.T.)	
	
	If Select( cAliasCT1 ) > 0
		cCta := (cAliasCT1)->CT1CONTA
	EndIf

	(cAliasCT1)->(DBCloseArea())

	cConta:= Soma1(Alltrim(cCta),0)

	//Se a conta já existir, soma mais um número
	If CT1->(dbseek(xFilial("CT1") + cConta))
		cConta := Soma1(Alltrim(cConta),0)
	EndIf

	cQry := " SELECT CT1_RES "  
	cQry += " FROM " + RetSqlName("CT1") + " CT1 "
	//cQry += " WHERE CT1_RES = '" + cConRedz + "'"
	//*** Alterado em 05/08/2020 - Sol. Gilmar / Cristiano - Autor - Andre Salgado
	cQry += " WHERE CT1_RES = '" + cCliLoj + "'"
	cQry += " AND D_E_L_E_T_ = '' "
	cQry := ChangeQuery(cQry)
	
	dbUseArea(.T.,'TOPCONN', TCGenQry(,,cQry), cAliasCT12,.F.,.T.)
	
	While (cAliasCT12)->(!Eof())	
		nCont++	
		(cAliasCT12)->(dbskip())		
	EndDo
	
	(cAliasCT12)->(DBCloseArea())
	


	If nCont == 0
		
		//Cria Nova conta na CT1
		dbselectarea("CT1")
		CT1-> (dbsetorder(1))
		//CT1-> (DbGoTop())
		CT1->(dbseek(xFilial("CT1")+cConta))

		IF !FOUND()

			Reclock( "CT1" , .T.)
				CT1->CT1_FILIAL := xFilial('CT1')
				CT1->CT1_CONTA  := cConta
				CT1->CT1_DESC01 := cDesc
				CT1->CT1_CLASSE := cClasse
				CT1->CT1_NORMAL := cNormal
				CT1->CT1_BLOQ	:= "2"			//2= Nao Bloqueado
				//CT1->CT1_RES    := cConRedz
				//*** Alterado em 05/08/2020 - Sol. Gilmar / Cristiano - Autor - Andre Salgado
				CT1->CT1_RES    := cCliLoj
				CT1->CT1_NCUSTO := 0
				CT1->CT1_CTASUP := cCtaCli
				CT1->CT1_DTEXIS := dData
				CT1->CT1_NTSPED := cNtsped
				CT1->CT1_NATCTA := cNtacta
				CT1->CT1_INDNAT := cIndnat
			CT1->(MsUnlock())
		
			//Atualiza conta no cadatro do cliente
			If !Empty(cConta)
				dbselectarea("SA1")
				SA1->(dbsetorder(1))
				If SA1->(dbseek(xFilial("SA1")+cCliLoj))
					//Grava conta contabil no Cliente
					Reclock( "SA1" , .F.)
					SA1->A1_CONTA:= cConta
					SA1->(MsUnlock())
				EndIf
			EndIf	

		else

			//Retorna msg de erro sem alterar os dados
			cLog 		:= "Conta Contabil não pode ser criada, faça o cadastro manual !  Código sugerido já existente para outra conta contábil - "+cConta
			lMsErroAuto := .T. //seta variavel private como erro
			AutoGRLog(cLog)    //grava log para exibir com funcao mostraerro
			mostraerro()
			lRet := .F.

		endif
	
	Else
	
		//Retorna msg de erro sem alterar os dados
		cLog 		:= "Código resumido já existente para outra conta contábil"
		lMsErroAuto := .T. //seta variavel private como erro
		AutoGRLog(cLog)    //grava log para exibir com funcao mostraerro
		mostraerro()
		lRet := .F.
		
	EndIf
	
	// ------------------ //
	// -- Fim do Bloco -- //
	// ------------------ //

Return lRet
