#INCLUDE "PROTHEUS.CH"
#INCLUDE "REPORT.CH"
#INCLUDE "TOPCONN.CH"

User Function MT112IT()

    Reclock("SW1",.F.)
    SW1->W1_XFILORI := SC1->C1_FILIAL
    SW1->(MsUnlock())
    
Return .T.
