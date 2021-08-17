#INCLUDE "PROTHEUS.CH"
#INCLUDE "EICDI154.CH"

/************************************************
| Autor: Claudino Domingues  | Data: 05/12/2016 |
*************************************************
| Função: ICPADDI0                              |
*************************************************
| Descr: Este P.E é executado na rotina de      |
|        recebimento de importação EICDI154.    |
************************************************/
User Function ICPADDI0()

Local cChamada  := ""
	
	If ValType(ParamIXB) = "C"
	   cChamada := PARAMIXB
	EndIf  
	
	If cChamada == "BOTAO" 
		If nTipoNF == 4 //CUSTO_REAL
			@ 000,085 BUTTON "Atu Custo" SIZE 35,13 ACTION (IF(ValEI2(),Processa({|| CustSB1()},"Atualizando Custo Standard!!!"),))
		EndIf
	EndIf
	
Return .T.

/************************************************
| Autor: Claudino Domingues  | Data: 05/12/2016 |
*************************************************
| Função: ValEI2                                |
*************************************************
| Descr: Função que valida se foi gravado o     |
|        Custo Realizado (Tabela EI20.          |
************************************************/
Static Function ValEI2
    
Local aAreaEI2 := EI2->(GetArea())
Local _lRetEI2 := .T.
    
    DbSelectArea("EI2")
	EI2->(DbSetOrder(1))
	
	If !EI2->(MsSeek(xFilial()+SW6->W6_HAWB))
		_lRetEI2 := .F.
		ApMsgStop('Custo Realizado não Gerado, por favor gravar o custo antes de Atualizar!','ICPADDI0')	
	EndIf
	
	RestArea(aAreaEI2)
	
Return _lRetEI2

/************************************************
| Autor: Claudino Domingues  | Data: 05/12/2016 |
*************************************************
| Função: CustSB1                               |
*************************************************
| Descr: Função que grava o Custo Realizado no  |
|        Custo Standard do Produto.             |
************************************************/
Static Function CustSB1

Local aAreaEI2 := EI2->(GetArea())
Local aAreaSB1 := SB1->(GetArea())
    
	DbSelectArea("EI2")
	EI2->(DbSetOrder(1))

	If EI2->(MsSeek(xFilial()+SW6->W6_HAWB))
		While !EI2->(EOF()) .AND. EI2->EI2_FILIAL == xFilial("EI2") .AND. EI2->EI2_HAWB == SW6->W6_HAWB
			
			DbSelectArea("SB1")
			SB1->(DbSetOrder(1))
			
			If SB1->(MsSeek(xFilial()+EI2->EI2_PRODUT))
				If EI2->EI2_PRUNI > 0
					SB1->(RecLock("SB1",.F.))
						SB1->B1_CUSTD := EI2->EI2_PRUNI
					SB1->(MSUnLock())
			    	ApMsgInfo('Custo Standard do Produto: ' + Alltrim(SB1->B1_COD) + ' atualizado!','ICPADDI0')	
			    EndIf                                         
			EndIf
			
			EI2->(DbSkip())
		EndDo
	
	EndIf
                      
	RestArea(aAreaSB1)
	RestArea(aAreaEI2)
		
Return