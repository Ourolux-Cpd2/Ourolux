#include "protheus.ch"
#DEFINE COMP_DATE  "20191301"

/*/{Protheus.doc} PE01NFESEFAZ
Ponto de Entrada para Manipulação em dados do produto.

@author Maurício O. Aureliano
@since 07/08/2019

@obs	Ponto de entrada localizado na função XmlNfeSef do rdmake NFESEFAZ. 
Através deste ponto é possível realizar manipulações nos dados do produto, 
mensagens adicionais, destinatário, dados da nota, pedido de venda ou compra, 
antes da montagem do XML, no momento da transmissão da NFe.

//O retorno deve ser exatamente nesta ordem e passando o conteúdo completo dos arrays
//pois no rdmake nfesefaz é atribuido o retorno completo para as respectivas variáveis
//Ordem:
//      aRetorno[01] -> aProd
//      aRetorno[02] -> cMensCli
//      aRetorno[03] -> cMensFis
//      aRetorno[04] -> aDest
//      aRetorno[05] -> aNota
//      aRetorno[06] -> aInfoItem
//      aRetorno[07] -> aDupl
//      aRetorno[08] -> aTransp
//      aRetorno[09] -> aEntrega
//      aRetorno[10] -> aRetirada
//      aRetorno[11] -> aVeiculo
//      aRetorno[12] -> aReboque
//      aRetorno[13] -> aNfVincRur
//      aRetorno[14] -> aEspVol
//      aRetorno[15] -> aNfVinc
//      aRetorno[16] -> AdetPag
//      aRetorno[17] -> ObsCont

@return	aRetorno		Array dados NF-e.
/*/

USER FUNCTION PE01NFESEFAZ()

	Local aProd     	:= PARAMIXB[1]
	Local cMensCli  	:= PARAMIXB[2]
	Local cMensFis  	:= PARAMIXB[3]
	Local aDest     	:= PARAMIXB[4]
	Local aNota     	:= PARAMIXB[5]
	Local aInfoItem 	:= PARAMIXB[6]
	Local aDupl     	:= PARAMIXB[7]
	Local aTransp   	:= PARAMIXB[8]
	Local aEntrega  	:= PARAMIXB[9]
	Local aRetirada 	:= PARAMIXB[10]
	Local aVeiculo  	:= PARAMIXB[11]
	Local aReboque  	:= PARAMIXB[12]
	Local aNfVincRur	:= PARAMIXB[13]
	Local aEspVol   	:= PARAMIXB[14]
	Local aNfVinc   	:= PARAMIXB[15]
	Local AdetPag   	:= PARAMIXB[16]
	Local aObsCont   	:= PARAMIXB[17]
	Local aRetorno  	:= {}
	Local cNfeMail		:= Trim(SuperGetMV("FS_NFEMAIL",,""))
	Local cPedMsg		:= ""
	Local cCodMsg		:= ""
	Local cEntSai       := aNota[4]
	//Local nlx			:= 0

	Local aObs 			:= {} 								// Customizado
	Local cObs			:= "" 								// Customizado
	Local nCont			:= 0  								// Customizado
	Local cUAObs  		:= "" 								// Customizado 
	Local cC5Obs  		:= "" 								// Customizado
	Local cEndEnt   	:= "Local da entrega: "	// Customizado

	Local cProds		:= '' // variavel para receber novos dados da estrutura e grupos constantes na solicitacao do Wadih - 22/01/2021
	Local nProds		:= 0 // quantidade de itens no array

	Local aAreaD2 		:= Nil
	Local aAreaF		:= GetArea()
	// Local aAreaTmp	:= SF2->(GetArea())
	// Adição de e-mail para recebimento de arquivo XML

	If !Empty(cNfeMail)
		AFill( aDest, Trim(aDest[16]) + ";" + cNfeMail, 16, 1 )
	EndIf

	//--------------------------------------------------------------------
	// Retirada de customizações do fonte NFESEFAZ.PRW 
	// MOA - 18/09/2019 - 10:37h
	//--------------------------------------------------------------------
	// Mensagens customizadas Ourolux. (Inicio)
	//--------------------------------------------------------------------
	//---------------
	// BLOCO 01
	//---------------
	If cEntSai == "1"
		If SF2->F2_TIPO <> "D"
				SA3->(dbSeek(xFilial("SA3")+SF2->F2_VEND1,.F.))
				cObs := "Vend: "
				cObs += SF2->F2_VEND1 + " "
				cObs += AllTrim(SA3->A3_NREDUZ)
				cObs += " Pedido: "
				SD2->(dbSeek(xFilial("SD2") + SF2->F2_DOC + SF2->F2_SERIE + SF2->F2_CLIENTE + SF2->F2_LOJA ,.F.))
				cPedMsg := SD2->D2_PEDIDO
				cObs += SD2->D2_PEDIDO + " "
				SE4->(dbSeek(xFilial("SE4") + SF2->F2_COND ,.F.))
				cObs += " Cond. Pagto: "
				cObs += SF2->F2_COND + " "
				cObs += AllTrim(SE4->E4_DESCRI)
				cObs += ". "                                                    
				cObs += "Favor enviar NF-e de devoluçao para nfe@ourolux.com.br." 
		EndIf
// inicio rogerio
// informacoes adicionais conforme solicitqacao wadih 28/01/2021 
// em 04/02/2021 - excluida a estrutura para notas fiscais que nao controlam estoque
// inclui a informacao do grupo de produtos, mensagem para conferencia de carga e estrutura dos itens solares

            // rogerio 18/02/2021
			cProds := '' // variavel auxiliar para os novos campos de estruturas da nota fiscal
            //cGrupos:= '' // Grupos participantes da NF
			cObsm  := ''  // mensagem de conferencia de carga para estrutura

			for nProds  := 1 to Len(aprod)
				cProds += GetAdvFVal("SF4","F4_ESTOQUE",(XFILIAL('SF4')+aprod[nProds][27]),1) // carrega estoque da TES para a variavel
			next nProds
/*
			if 'N' $ cProds
				// se houver algum produto com N no Estoque nao pode imprimir mensagem 
				// nenhuma
			else

				aAreaD2 := GetArea()

				//cGrupos := "|" // inicia com pipe
				for nProds  := 1 to Len(aprod) 
					SB1->(dbseek(xfilial("SB1") + aprod[nProds][2]))
					SD2->(dbSeek(xFilial("SD2") + SF2->F2_DOC + SF2->F2_SERIE + SF2->F2_CLIENTE + SF2->F2_LOJA + aprod[nProds][2] ,.F.))
					//cGrupos += SD2->D2_ITEM + '-' + Alltrim(SB1->B1_COD) + '-' + Alltrim(SB1->B1_GRUPO) + "|"
					//cGrupos += SD2->D2_ITEM+'-'+alltrim(sb1->b1_grupo)+'-'+alltrim(sb1->b1_cod)+"|"
				next nProds

				cProds := " " // reinicia a variavel de mensagens

				for nProds  := 1 to Len(aprod) 
					SB1->(dbseek(xfilial("SB1") + aprod[nProds][2]))
					dbSelectArea("SBM")
					SBM->(dbseek(xfilial("SBM") + SB1->B1_GRUPO))
					If SBM->BM_XESTR == "S"
						dbselectarea('SG1')
						IF  dbseek(xfilial("SG1")+aprod[nProds][2]) 
							
							cProds := "GERADOR CONTEM: "
							//cProds := "Estruturas: "
							
							cObsm := ' E obrigatoria a conferencia do material no ato do recebimento, na presenca da transportadora.'
							cObsm += ' Nao aceitaremos reclamacoes posteriores. '
							//cObsm += ' inversor, suporte para telhado, cabo solar, conectores e stringbox. Isencao de ICMS nas'
							//cObsm += ' operacoes de equipamentos e componentes para aproveitamento da energia solar e eólica,'
							//cObsm += ' conforme convenio icms 101/97. '

							dbskip()
						ENDIF
					EndIf
				next nProds 

				RestArea(aAreaD2)

				cObs += cObsm // alimenta a variavel padrao para receber o complemento de mensagem

				for nProds  := 1 to Len(aprod)
					dbselectarea('SG1') 
					IF  dbseek(xfilial("SG1")+aprod[nProds][2])
						while aprod[nProds][2] = sg1->G1_COD
							cProds += ' '+alltrim(str( (aprod[nProds][9] * sg1->g1_quant),14,2))+" "+alltrim(GetAdvFVal("SB1","B1_DESC",xfilial('SG1')+sg1->g1_comp,1)) +'  ' 
							// carrega a estrutura para a variavel de mensagens
							dbskip()
						end 
					ENDIF 
				next nProds 

				cObs += cProds // adiciona as mensagens ao campo padrao de observação
	
				cProds := " "
			endif
// final
*/ 
			aAdd(aObs,cObs)


			//---------------
			// BLOCO 02
			//---------------
			If SF2->F2_ICMSRET <> 0 .And. SF2->F2_TIPO == 'N' .And. cFilAnt <> "06" 
				aAdd(aObs, "RECOLHIMENTO DO ICMS CONF. PROTOCOLO No 17 DE 25.07.85 DOU 29.07.85" )  // 67 Chars
			EndIf
		
			// Chamado I1906-091 Fórmula - Clientes Paraná // MOA - 05/06/2019 - 10:07hs 
			If SF2->F2_EST == 'PR' .And. SF2->F2_VALICM <> 0 .And. cFilAnt == "06"
				aAdd(aObs, FORMULA("205")) 
			EndIf					
			
			// Chamado I1906-1848 Fórmula - Clientes Rio Grande do Sul // MOA - 27/06/2019 - 18:00hs
			If SF2->F2_EST == 'RS' .And. SF2->F2_VALICM <> 0 .And. cFilAnt == "06"
				aAdd(aObs, FORMULA("209"))
			EndIf		

			// inicio Sr Wadih 11/02/2021 - ajustes de mensagems
			If SF2->F2_EST == 'MG' .And. SF2->F2_VALICM <> 0 .And. cFilAnt == "06"
				aAdd(aObs, FORMULA("211"))
			EndIf

			If SF2->F2_EST == 'SP' .And. SF2->F2_VALICM <> 0 .And. cFilAnt == "06"
				aAdd(aObs, FORMULA("225"))
			EndIf

			If SF2->F2_EST == 'PR' .And. SF2->F2_VALICM <> 0 .And. cFilAnt == "06" 
				aAdd(aObs, FORMULA("206"))
			EndIf
			
			If SF2->F2_EST == 'SC' .And. SF2->F2_VALICM <> 0 .And. cFilAnt == "06" 
				aAdd(aObs, FORMULA("265"))
			EndIf

/* este processo esta repetindo na linha 166 - chamado 1848
			If SF2->F2_EST == 'RS' .And. SF2->F2_VALICM <> 0 .And. cFilAnt == "06"
				aAdd(aObs, FORMULA("209"))
			EndIf
*/
			// final 



			//---------------
			// BLOCO 03
			//---------------
			If !Empty(SA1->A1_MENSAGE)
				aadd(aObs,AllTrim(FORMULA(SA1->A1_MENSAGE))) // LEROY
			EndIf
		

			//---------------
			// BLOCO 04
			//---------------
		
			//--------------------------------------------------
			// Retorno de Campo Customizado TMK. 
			//--------------------------------------------------
			If SF2->F2_TIPO <> "D"
				Dbselectarea("SUA")
				dbSetOrder(2)
				If Dbseek(xFilial("SUA")+SF2->F2_SERIE+SF2->F2_DOC)
		
					//-----------------------------------
					// Local da entrega TMK.
					//-----------------------------------
					cEndEnt += Alltrim (SUA->UA_ENDENT)
					cEndEnt += ' - '
					cEndEnt += AllTrim (SUA->UA_BAIRROE)
					cEndEnt += ' - '
					cEndEnt += AllTrim (SUA->UA_MUNE)
					cEndEnt += ' - '
					cEndEnt += AllTrim (SUA->UA_ESTE)
					cEndEnt += ' - '
					cEndEnt += Transform (SUA->UA_CEPE, "@R 99999-999")
		
					aadd(aObs,cEndEnt)
		
					//---------------
					// Obs TMK                           
					//---------------  
					If !Empty (SUA->UA_CODOBS)
						cUAObs := MSMM(SUA->UA_CODOBS)
						aadd(aObs,cUAObs)
					EndIf
		
				EndIf						
			EndIf
		
			//---------------
			// BLOCO 05
			//---------------
		
			//-----------------------------------------------------------------------
			// Obs Faturamento
			//-----------------------------------------------------------------------
			//cUAObs := SC5->C5_MSGNOTA 
			// Marcelo Ethosx - Substituido por campo memo virtual
			//-----------------------------------------------------------------------
			// MOA - 02/10/2019 - Variaveis para consulta de codigo
			//                                 da mensagem do portal de venda.
			//-----------------------------------------------------------------------
			DbSelectArea("SC5")
			cCodMsg := Posicione("SC5",1,xFilial("SC5")+cPedMsg,"C5_XCODMNF")

			If !Empty (cCodMsg)
				cC5Obs := MSMM(cCodMsg)
				aadd(aObs,cC5Obs)
			EndIf

	EndIf
	//---------------
	// BLOCO 06
	//---------------

	//--------------------------------------------------------------------
	//³ Tratamento de mensagens de Nota de Entrada ³
	//³ Customizado Eletromega. (Inicio)           ³
	//--------------------------------------------------------------------
	If cEntSai == "0"

		If !Empty(SF1->F1_HAWB) // Nota Fiscal de Importaçao ---> SIGAEIC
	
			cObs := "DI : "
			cObs += Transform(GetAdvFVal("SW6","W6_DI_NUM",xFilial("SW6")+SF1->F1_HAWB,1,""),;
			PesqPict("SW6","W6_DI_NUM"))
			aAdd(aObs,cObs)
	
			cObs := "PIS: " + Alltrim(STR(SF1->F1_VALIMP6,,2))
			aAdd(aObs,cObs)
			cObs := "COFINS: " + Alltrim(STR(SF1->F1_VALIMP5,,2))
			aAdd(aObs,cObs)
			cObs := "II: " + Alltrim(STR(SF1->F1_II,,2))
			aAdd(aObs,cObs)
	
			If !Empty( SF1->F1_OBSNFE )  // importacao : Dados Adicionais Nota Fiscal de Entrada c/ Nosso Formulario
				cObs := SF1->F1_OBSNFE
				aAdd(aObs,cObs)
			EndIf
		EndIf
		
		// Preenchimento da variável de Mensagem do Cliente com o array de observação
		For nCont:=1 To Len(aObs)
			cMensCli += aObs[nCont]+" "
		Next nCont

	EndIf

	//--------------------------------------------------------------------
	// Mensagens customizadas Ourolux. (Fim)
	//--------------------------------------------------------------------

	//----------------------------------------------------------------------------
	//Adicição de dados para tag ObsCont necessárias para integração TranspoFrete
	//----------------------------------------------------------------------------
	
	//[1] = xcampo [2] = xTexto	//Variavel criada na NFeSefaz

	If cEntSai == "1"
		AADD(aObsCont, {"CATEGORIA"			, "Nota Fiscal saida"} )
		AADD(aObsCont, {"TF_NUM_PNF_REF"	, SD2->D2_PEDIDO} )
		AADD(aObsCont, {"TF_SER_PNF_REF"	, "2"} )
		
	// rogerio - 18/02/2021 - inicio
		/* IF !EMPTY(cGrupos)
			nValIni := 0
			nValFim := 0
			cGrpAux := ""
			nGrpAut := 0
			for nlx := 1 to Len(cGrupos)
				
				If nValFim > 40
					nGrpAut++
					AADD(aObsCont, {"GRUPO"+cValtoChar(nGrpAut)	, cGrpAux} ) 
					nValIni := 0
					nValFim := 0
					cGrpAux := "|"
					nlx--
					Loop
				EndIf

				If SubStr(cGrupos,nlx,1) == "|"  .AND. nValIni == 0
					nValIni := nlx 
					cGrpAux += SubStr(cGrupos,nlx,1)
					Loop
				EndIf
				
				If SubStr(cGrupos,nlx,1) <> "|"
					cGrpAux += SubStr(cGrupos,nlx,1)
					Loop
				EndIf 

				If SubStr(cGrupos,nlx,1) == "|"
					cGrpAux += SubStr(cGrupos,nlx,1)
					nValFim := Len(cGrpAux)
					If nlx == Len(cGrupos) .AND. nValIni == 1
						AADD(aObsCont, {"GRUPO"	, cGrpAux} ) 
					EndIf
					Loop
				EndIf
			Next
		Endif */
	// final
	EndIf

	// Preenchimento da variável de Mensagem do Cliente com o array de observação
	For nCont:=1 To Len(aObs)
		cMensCli += aObs[nCont]+" "
	Next nCont
	//----------------------------------------------------------------------------
	//Fim da trativa Transpofrete
	//----------------------------------------------------------------------------

/*
// rogerio 24/02/2021 - ajuste para ignorar a rejeição 436 - falta de informacoes de pagamento
if cAmbiente == '2'
	AdetPag  := {}
	aadd(aDetPag,;
	{"03",; // Forma de pagamento
	0.00,; // Valor do Pagamento
	0.00,; //Troco
	"1",; // Tipo de Integração para pagamento //Opcional se levar deverá preecher os items abaixo com valor ou "".
	"32331472001195",; //CNPJ da Credenciadora de cartão de crédito e/ou débito // Opcional
	"01",; //Bandeira da operadora de cartão de crédito e/ou débito //opcional
	"123456",; //Bandeira da operadora de cartão de crédito e/ou débito //opcional
	"1"}) //Número de autorização da operação cartão de crédito e/ou débito //opcional
endIf
*/ 
	aadd(aRetorno,aProd) 
	aadd(aRetorno,cMensCli)
	aadd(aRetorno,cMensFis)
	aadd(aRetorno,aDest)
	aadd(aRetorno,aNota)
	aadd(aRetorno,aInfoItem)
	aadd(aRetorno,aDupl)
	aadd(aRetorno,aTransp)
	aadd(aRetorno,aEntrega)
	aadd(aRetorno,aRetirada)
	aadd(aRetorno,aVeiculo)
	aadd(aRetorno,aReboque)
	aadd(aRetorno,aNfVincRur)
	aadd(aRetorno,aEspVol)
	aadd(aRetorno,aNfVinc)
	aadd(aRetorno,AdetPag)
	aadd(aRetorno,aObsCont)

	// Habilitar linhas abaixo para testes!
	/*
	if alltrim(!upper(GetEnvServer()))  == "UN08F1_PRD"  // Exibe somente se não for ambiente de produção

	cMsg := '[ PE01NFESEFAZ ] '					+ CRLF
	cMsg += 'Numero da nota: '	+ aNota[2] 		+ CRLF
	cMsg += 'Destinatario: '	+ aDest[2] 		+ CRLF
	cMsg += 'Email: '			+ aDest[16] 	+ CRLF
	cMsg += 'Mensagem da nota: '+ cMensCli 		+ CRLF
	cMsg += 'Mensagem padrao: '	+ cMensFis 		+ CRLF

	Alert(cMsg)
	endif
	*/
	
RestArea(aAreaF)

RETURN aRetorno
