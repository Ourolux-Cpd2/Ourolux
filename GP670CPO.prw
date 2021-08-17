#INCLUDE "PROTHEUS.CH"

/*------------------------------------------------------------------------------*\
| Função:	 |	GP670CPO                                                         |
| Autor:	 |	Claudino Domingues                                               |
| Data:		 |	24/04/2017                                                       |                                       
| Descrição: |	Essa implementação permite atualizar informações dos campos      |
|            |  personalizados da tabela SR1 - Valores Extras, na gravação dos   |
|            |  títulos para a tabela SE2 - Contas a Pagar.                      |
\*------------------------------------------------------------------------------*/

User Function GP670CPO() 
 
	Local aArea := GetArea()
	 
	DbSelectArea("SE2") 
	RecLock("SE2",.F.) 
		SE2->E2_CCD     := RC1->RC1_CC 
		SE2->E2_HIST    := RC1->RC1_DESCRI 
	SE2->(MsUnlock())
	
	RestArea(aArea)
 
Return