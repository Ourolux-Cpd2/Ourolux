#include 'protheus.ch'
#include 'parmtype.ch'

/*/{Protheus.doc} OS200EST
//TODO Descrição auto-gerada.
@author Caio
@since 04/03/2020
@version 1.0
@type function
/*/

user function OS200EST()

Local lRet     := .T.	
Local aArea    := GetArea() 
 
	If Select("DAI") == 0
		DbSelectArea("DAI")
	Endif 
	
	DAI->(DbSetOrder(1)) //--DAI_FILIAL+DAI_COD+DAI_SEQCAR+DAI_SEQUEN+DAI_PEDIDO
	
	If DAI->(MsSeek(xFilial("DAI")+DAK->DAK_COD+DAK->DAK_SEQCAR))
		
		While DAI->(!Eof()) .And. DAI->DAI_FILIAL == xFilial("DAI") .And. ;
			                      DAI->DAI_COD    == DAK->DAK_COD   .And. ;
			                      DAI->DAI_SEQCAR == DAK->DAK_SEQCAR
			                      
	        cChave := DAI->(DAI_FILIAL+DAI_PEDIDO)
	        
		    lLockPR1 := !PR1->(dbSeek(xFilial("PR1")+"DAI"+cChave))
		    
			RecLock("PR1",lLockPR1)
			
				PR1->PR1_FILIAL := xFilial("PR1")
				PR1->PR1_ALIAS  := "DAI"
				PR1->PR1_RECNO  := DAI->(Recno())
				PR1->PR1_TIPREQ := "1"
				PR1->PR1_DATINT := Date()
				PR1->PR1_HRINT	:= Time()		
				PR1->PR1_STINT  := "P"
				PR1->PR1_OBSERV := ""
				PR1->PR1_CHAVE  := cChave
				
			PR1->(MsUnlock())
			
			DAI->(DbSkip())
			
		EndDo 
		
	Endif

	RestArea(aArea)
	
return(lRet)