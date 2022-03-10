#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE 'FWMVCDEF.CH'
#DEFINE COMP_DATE  "20200112"
/*
{Protheus.doc} MT094END
Validação no final do pedido de compra igual 

@author Roberto Souza
@since 21/09/2017
@version 1    
*/

User Function MT094END() 

	Local _cDocto   := PARAMIXB[1] 
	Local _cTipDoc  := PARAMIXB[2]
	Local _nOpcao   := PARAMIXB[3]
	Local _cFilDoc  := PARAMIXB[4]
	Local _cMailCom := ""
	Local _cMailApr := ""  
	Local _cEmpPC   := ""
	Local _cFilPC   := ""
	Local _cFindKey := ""
	Local _nAt      := 0
	Local _nVlrTot  := 0
	Local _nTaxDol  := 0
	Local _lLibera  := .F.
	Local aArea     := GetArea()                     
	Local cGrupo	:= ""
	Local cAprov	:= __cUserId 
	Local nRecSC7   := 0 
	Local x			:= 0
	Local y			:= 0
	Local aFonte	:= {}
	Local cQuery 	:= ""  
	Local cDespNFa  := SuperGetMV("ES_DESNFA",.F.,"")
	Local cDespNNF	:= SuperGetMV("ES_DESNNF",.F.,"402/102")
	Local lAtvEIC   := SuperGetMV("ES_ATVEICD",.T.,.F.)
	Private cSRC	:= ""
	PRIVATE lGerPrDI := IF(GetNewPar("MV_EASYFDI","S")="S",.T.,.F.)//ASR - 28/09/2005 - Integração EIC x FIN
	

	// PROJETO_P12    
	// Roberto Souza

	// Força o posicionamento na P12	
	If cVersao >= "12"     
		If PADR(_cDocto,6) <> SC7->C7_NUM 
			dbSelectArea("SC7")
			SC7->(dbSeek(_cFilDoc+PADR(_cDocto,6)))
			cGrupo	:= SC7->C7_APROV
		else
			cGrupo	:= SC7->C7_APROV
		EndIf

		DbSelectArea("SAL")
		SAL->(DbSetOrder(4))//	AL_FILIAL+AL_COD+AL_USER                                                                                                                                  
		lSAL := SAL->(DbSeek(xFilial("SAL")+cGrupo+cAprov))

		nRecSC7 := U_xRetSCR( @cSRC, _cFilDoc, cAprov, _cDocto  )
		DbSelectArea("SCR")

		SCR->(DbGoTo(nRecSC7))

		If !lSAL
			lSAL := SAL->(DbSeek(xFilial("SAL")+SCR->CR_GRUPO+cAprov))
		EndIf
	EndIf

	If _nOpcao <> 0 
		If _cTipDoc == "PC"
			If Alltrim(_cFilDoc)+Alltrim(_cDocto)+Alltrim(__cUserID) == Alltrim(SC7->C7_FILIAL)+Alltrim(SC7->C7_NUM)+Alltrim(SAL->AL_USER) 
			//If lPassa
				If _nOpcao == 1 .Or. _nOpcao == 2
					If SAL->AL_NIVEL == "01"
						// Claudino 21/01/16
						If SCR->CR_MOEDA == 1
							_nVlrTot := SCR->CR_TOTAL
						Else
							If Empty(SCR->CR_TXMOEDA)
								_nTaxDol := RecMoeda(dDataBase,SCR->CR_MOEDA)
								If Empty(_nTaxDol)
									SM2->(dbSetOrder(1)) // M2_DATA
									SM2->(dbGoBottom())
									While !SM2->(Bof())
										If !Empty(SM2->M2_MOEDA2)
											_nVlrTot := SCR->CR_TOTAL * SM2->M2_MOEDA2
											Exit
										EndIf
										SM2->(DbSkip(-1))
									EndDo
								Else
									_nVlrTot := SCR->CR_TOTAL * _nTaxDol								
								EndIf									
							Else
								_nVlrTot := SCR->CR_TOTAL * SCR->CR_TXMOEDA
							EndIf
						EndIf

						// Claudino 06/08/15
						If _nVlrTot <= GETMV("FS_LIBWFPC") // Limite do primeiro aprovador
							CONOUT("Liberação Sistema ( <= que 5000 ) - Nivel 01")
							SAL->(dbSetOrder(2))
							SAL->(dbSeek(xFilial("SAL")+SC7->C7_APROV+"02"))
							_cFindKey := xFilial("SC7")+SC7->C7_NUM                    

							While !SAL->(EOF()) .AND. SAL->AL_FILIAL == xFILIAL("SAL") .AND. SAL->AL_COD == SC7->C7_APROV .AND. SAL->AL_NIVEL == "02"
								SAK->(dbSetOrder(1))
								SAK->(dbSeek(xFilial("SAK")+SAL->AL_APROV))
								If Alltrim(SC7->C7_XDEPART) $ Alltrim(SAK->AK_XDEPART) 
									SCR->(dbSetorder(1))
									SCR->(MsSeek(SC7->C7_FILIAL+"PC"+Padr(SC7->C7_NUM,Len(SCR->CR_NUM))+"02"))
									//Usar MaAlcDoc para liberação de pedidos
									_lLibera :=  MaAlcDoc({SCR->CR_NUM,SCR->CR_TIPO,SCR->CR_TOTAL,SAK->AK_COD,,SC7->C7_APROV,,,,,},dDataBase,4) // Funcao do protheus
									//O trecho abaixo foi comentado pois não estava atualizando a tabela de saldos, apenas atualiza SCR
									//_lLibera := U_xSetSCR( SC7->C7_FILIAL, cAprov, "PC", Padr(SC7->C7_NUM,Len(SCR->CR_NUM)), "02", "05" )
									Exit
								EndIf
								SAL->(dbSkip())
							EndDo

							If _lLibera
								dbSelectArea("SC7")
								SC7->(dbSetOrder(1))		
								SC7->(dbSeek(xFilial("SC7")+SC7->C7_NUM))

								If !Empty(Alltrim(SC7->C7_WFID))
									_nAt := At("/",Alltrim(SC7->C7_WFID))
									If _nAt == 0
										For x:= Val(SubStr(Alltrim(SC7->C7_WFID),Len(Alltrim(SC7->C7_WFID)),1)) To 0 Step -1					
											CONOUT("Liberação Sistema ( <= que 5000 ) - Finalizando Processo Nivel 01: " + SubStr(Alltrim(SC7->C7_WFID),1,Len(Alltrim(SC7->C7_WFID))-1) + cValToChar(x))		        	
											WFKillProcess(SubStr(Alltrim(SC7->C7_WFID),1,Len(Alltrim(SC7->C7_WFID))-1) + cValToChar(x))
										Next x
									Else
										For x:= Val(SubStr(Alltrim(SC7->C7_WFID),Len(Alltrim(SC7->C7_WFID)),1)) To 0 Step -1					
											CONOUT("Liberação Sistema ( <= que 5000 ) - Finalizando Processo Nivel 02: " + SubStr(Alltrim(SC7->C7_WFID),_nAt+1,Len(Alltrim(SC7->C7_WFID))-_nAt-1) + cValToChar(x))
											WFKillProcess(SubStr(Alltrim(SC7->C7_WFID),_nAt+1,Len(Alltrim(SC7->C7_WFID))-_nAt-1) + cValToChar(x))
										Next x

										For y:= Val(SubStr(SubStr(Alltrim(SC7->C7_WFID),1,_nAt-1),Len(SubStr(Alltrim(SC7->C7_WFID),1,_nAt-1)),1)) To 0 Step -1					
											CONOUT("Liberação Sistema ( <= que 5000 ) - Finalizando Processo Nivel 01: " + SubStr(Alltrim(SC7->C7_WFID),1,_nAt-2) + cValToChar(y))		        	
											WFKillProcess(SubStr(Alltrim(SC7->C7_WFID),1,_nAt-2) + cValToChar(y))
										Next y
									EndIf
								EndIf

								_cMailCom := UsrRetMail(SC7->C7_USER)
								_cEmpPC   := Posicione("SM0",1,cEmpAnt+cFilAnt,"M0_NOME")
								_cFilPC   := Posicione("SM0",1,cEmpAnt+cFilAnt,"M0_FILIAL")

								//U_MsgWFPC(_cMailCom,"PC nº " + SC7->C7_NUM + " Aprovado - " + Alltrim(_cEmpPC) + "/" + Alltrim(_cFilPC),(""))

								_cMailApr := UsrRetMail(SAK->AK_USER)
								//U_MsgWFPC(_cMailApr,"PC nº " + SC7->C7_NUM + " Aprovado Automaticamente - " + Alltrim(_cEmpPC) + "/" + Alltrim(_cFilPC),("")) // Claudino - I1605-400 - Comentei

								If SuperGetMv("MV_EASY")=="S" .And. SC7->(FieldPos("C7_PO_EIC")) <> 0 .And. !Empty(SC7->C7_PO_EIC)
									dbSelectArea("SW2")
									SW2->(dbSetOrder(1))	

									If SW2->(MsSeek(xFilial("SW2")+SC7->C7_PO_EIC)) .And. SW2->(FieldPos("W2_CONAPRO")) <> 0 .And. !Empty(SW2->W2_CONAPRO)

										Reclock("SW2",.F.)
										SW2->W2_CONAPRO := "L"
										SW2->(MsUnlock("SW2"))
										CONOUT("Retorno - Aprovado SW2 Automaticamente - Num.Ped : " + cValToChar(SC7->C7_NUM) + " - Filial: " + _cFilPC)
									EndIf
								EndIf

								While SC7->(!Eof()) .AND. (SC7->C7_FILIAL+SC7->C7_NUM == _cFindKey )
									RecLock("SC7",.F.)
									SC7->C7_CONAPRO := "L"
									SC7->(MsUnLock("SC7"))
									SC7->(dbSkip())
								EndDo	
							EndIf
						Else
							CONOUT("Liberação Sistema (Liberar) - Nivel 01")
							U_APCIniciar("02") // Passo para o segundo nivel de aprovacao
						EndIf
					ElseIf SAL->AL_NIVEL == "02"
						If !Empty(Alltrim(SC7->C7_WFID))
							_nAt := At("/",Alltrim(SC7->C7_WFID))
							For x:= Val(SubStr(Alltrim(SC7->C7_WFID),Len(Alltrim(SC7->C7_WFID)),1)) To 0 Step -1					
								CONOUT("Aprovado - Finalizando Processo Nivel 02: " + SubStr(Alltrim(SC7->C7_WFID),_nAt+1,Len(Alltrim(SC7->C7_WFID))-_nAt-1) + cValToChar(x))
								WFKillProcess(SubStr(Alltrim(SC7->C7_WFID),_nAt+1,Len(Alltrim(SC7->C7_WFID))-_nAt-1) + cValToChar(x))
							Next x

							_cMailCom := UsrRetMail(SC7->C7_USER)
							_cEmpPC   := Posicione("SM0",1,cEmpAnt+cFilAnt,"M0_NOME")
							_cFilPC   := Posicione("SM0",1,cEmpAnt+cFilAnt,"M0_FILIAL")

							_cMailApr := UsrRetMail(SAK->AK_USER) 
							//U_MsgWFPC(_cMailCom + ";" + _cMailApr,"PC nº " + SC7->C7_NUM + " Aprovado - " + Alltrim(_cEmpPC) + "/" + Alltrim(_cFilPC),(""))
						EndIf
					EndIf
				ElseIf _nOpcao == 3
					If !Empty(Alltrim(SC7->C7_WFID))
						_nAt := At("/",Alltrim(SC7->C7_WFID))
						If _nAt == 0
							For x:= Val(SubStr(Alltrim(SC7->C7_WFID),Len(Alltrim(SC7->C7_WFID)),1)) To 0 Step -1					
								CONOUT("Liberação Sistema (Bloquear) - Finalizando Processo Nivel 01: " + SubStr(Alltrim(SC7->C7_WFID),1,Len(Alltrim(SC7->C7_WFID))-1) + cValToChar(x))		        	
								WFKillProcess(SubStr(Alltrim(SC7->C7_WFID),1,Len(Alltrim(SC7->C7_WFID))-1) + cValToChar(x))
							Next x
						Else
							For x:= Val(SubStr(Alltrim(SC7->C7_WFID),Len(Alltrim(SC7->C7_WFID)),1)) To 0 Step -1					
								CONOUT("Liberação Sistema (Bloquear) - Finalizando Processo Nivel 02: " + SubStr(Alltrim(SC7->C7_WFID),_nAt+1,Len(Alltrim(SC7->C7_WFID))-_nAt-1) + cValToChar(x))
								WFKillProcess(SubStr(Alltrim(SC7->C7_WFID),_nAt+1,Len(Alltrim(SC7->C7_WFID))-_nAt-1) + cValToChar(x))
							Next x

							For y:= Val(SubStr(SubStr(Alltrim(SC7->C7_WFID),1,_nAt-1),Len(SubStr(Alltrim(SC7->C7_WFID),1,_nAt-1)),1)) To 0 Step -1					
								CONOUT("Liberação Sistema (Bloquear) - Finalizando Processo Nivel 01: " + SubStr(Alltrim(SC7->C7_WFID),1,_nAt-2) + cValToChar(y))		        	
								WFKillProcess(SubStr(Alltrim(SC7->C7_WFID),1,_nAt-2) + cValToChar(y))
							Next y
						EndIf
					EndIf

					_cMailCom := UsrRetMail(SC7->C7_USER)
					_cEmpPC   := Posicione("SM0",1,cEmpAnt+cFilAnt,"M0_NOME")
					_cFilPC   := Posicione("SM0",1,cEmpAnt+cFilAnt,"M0_FILIAL")

					_cMailApr := UsrRetMail(SAK->AK_USER)	
					U_MsgWFPC(_cMailCom + ";" + _cMailApr,"PC nº " + SC7->C7_NUM + " - Bloqueado pelo Aprovador!!! " + Alltrim(_cEmpPC) + "/" + Alltrim(_cFilPC),(""))					
				EndIf
			EndIf
		EndIf
	EndIf
	
	If lAtvEIC
		aFonte := GetSrcArray("NFDESAUT.PRW")
		If Empty(aFonte)
			conout("MT094END - Rotina NFDESAUT nao compilada")	
			ProcLogAtu("ERRO","MT094END - Rotina NFDESAUT nao compilada", "" , "EICDESPESA" )
			RestArea( aArea )
			Return
		EndIf
		conout("MT094END - Rotina EIC - Ativada")
		conout("MT094END - _nOpcao: " + cValToChar(_nOpcao))
		conout("MT094END - SAL->AL_NIVEL: " + SAL->AL_NIVEL)
		If _nOpcao == 1 .and. SAL->AL_NIVEL == "02"
			//cQuery := " SELECT C7_PRODUTO FROM " + RetSqlName("SC7")
			cQuery := " SELECT C7_PRODUTO, C7_XHAWB FROM " + RetSqlName("SC7")
			cQuery += " WHERE C7_FILIAL = '" +_cFilDoc+ "' "
			cQuery += " AND C7_NUM = '" +_cDocto+ "' "
			cQuery += " AND D_E_L_E_T_ = '' "
			
			If Select("C7XX") > 0 
				C7XX->(dbCloseArea())
			EndIf
			
			conout("MT094END - Query para buscar produto que esta sendo liberado")
			conout(cQuery)

			DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery) , 'C7XX', .T., .F.)

			If C7XX->(!EOF())
				conout("MT094END - Produto: " + Alltrim(C7XX->C7_PRODUTO))
				conout("MT094END - Despesa: " + SubStr(Alltrim(C7XX->C7_PRODUTO),4,3))
				conout("MT094END - Origem: " + SubStr(Alltrim(C7XX->C7_PRODUTO),1,3))
				conout("MT094END - ES_DESNFA: " + cDespNFa)
				If SubStr(Alltrim(C7XX->C7_PRODUTO),4,3) $ cDespNFa .AND. SubStr(Alltrim(C7XX->C7_PRODUTO),1,3) == "EIC"
					If !(SubStr(Alltrim(C7XX->C7_PRODUTO),4,3) $ cDespNNF)
						conout("MT094END - Chamando rotina NFDESAUT")
						U_NFDESAUT(_cFilDoc,_cDocto)

						EICFI400("POS_GRV_DESP")
						axFl2DelWork:={}
						
						conout("MT094END - Inclusão dos PRE")
						cControle := "Inclusao"
						Processa({|| AVPOS_DI(C7XX->C7_XHAWB,lGerPrDI,,.T.) })

						U_xdelPRE(C7XX->C7_XHAWB)
					
					Else
						conout("MT094END - Despesa esta no parametro para nao gerar NF automaticamente")
						conout("MT094END - ES_DESNNF: " + cDespNNF)
					EndIf
				Else
					conout("MT094END - IF para chamada do NFDESAUT retornou .F.")
					ProcLogAtu("ALERTA","MT094END - Produto não esta na regra para gerar NF", "Filial: " +_cFilDoc+ " Pedido: " +_cDocto+ " Produto: " + C7XX->C7_PRODUTO , "EICDESPESA" )
				EndIf
			Else
				conout("MT094END - Query não trouxe resultado NF nao sera gerada")
				ProcLogAtu("ERRO","MT094END - Query não trouxe resultado NF nao sera gerada", "Filial: " + _cFilDoc + " Pedido: " + _cDocto, "EICDESPESA" )
			EndIf
			
			aFonte := GetSrcArray("NFFRTAUT.PRW")
			If Empty(aFonte)
				conout("MT094END - Rotina NFFRTAUT nao compilada")	
				ProcLogAtu("ERRO","MT094END - Rotina NFFRTAUT nao compilada", "" , "EICDESPESA" )
				RestArea( aArea )
				Return
			EndIf

			conout("MT094END - Chamando rotina NFFRTAUT")
			U_NFFRTAUT(_cFilDoc,_cDocto)
			conout("MT094END - Final chamado rotina NFFRTAUT")
		EndIf
	EndIf

	RestArea( aArea )

Return

User Function xRetSCR( cSRC, cFilSCR, cUsrSCR, cDocSCR )
	Local nRet      := 0   
	Local aArea     := GetArea()     
	cSRC := GetNextAlias()

	BeginSQL Alias cSRC
		SELECT R_E_C_N_O_ SCRRECNO FROM %Table:SCR%
		WHERE CR_FILIAL = %Exp:cFilSCR%            
		AND CR_USER = %Exp:cUsrSCR%
		AND CR_NUM = %Exp:cDocSCR%    
		AND %notdel%
	EndSql                      

	If (cSRC)->(!Eof())
		nRet := (cSRC)->SCRRECNO
	EndIf    

	RestArea( aArea )

Return( nRet )

User Function xSetSCR( cFilSCR, cUsrSCR, cTipoDoc, cDocSCR, cNivSCR, cStatSCR )
	Local aArea     := GetArea()     
	Local cUser		:= cUsrSCR
	Local cAprov    := cUser
	Local lRet 		:= .T.                    

	DbSelectArea("SCR")     

	SCR->( DbClearFilter() )

	SCR->( DbSetOrder(1) )

	SCR->( MsSeek(cFilSCR+cTipoDoc+cDocSCR) )

	nRec := SCR->(RecNo())

	While SCR->(!Eof()) .And. SCR->(CR_FILIAL+CR_TIPO+CR_NUM) == cFilSCR + cTipoDoc + cDocSCR
		If SCR->CR_STATUS <> cStatSCR .And. SCR->CR_NIVEL == cNivSCR
			Reclock("SCR",.F.)
			SCR->CR_STATUS	:= cStatSCR
			SCR->CR_DATALIB	:= dDataBase
			SCR->CR_USERLIB	:= cUsrSCR
			SCR->CR_APROV	:= cAprov
			SCR->CR_OBS		:= ""
			SCR->(MsUnlock())

		EndIf			
		SCR->(!DbSkip())
	EndDo	

	//DbSelectArea("SCR")     
	//set filter to  &(cXFiltraSCR)

	RestArea( aArea )

Return( lRet )	




