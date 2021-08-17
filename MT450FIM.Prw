/*
//   Está localizado na liberação manual do crédito por pedido A450LIBMAN()
*/

#include 'Ap5Mail.ch'
#include 'rwmake.ch'

User Function MT450FIM()
Local aArea  	:= GETAREA()   
Local cNum		:= SC9->C9_PEDIDO     

DBSELECTAREA("SC5")
DBSETORDER(1)
DBGOTOP()
IF DBSEEK(XFILIAL("SC5")+cNUM)
	RECLOCK("SC5",.F.)
	FIELD->C5_XUSRLIB	:= cUsername
	FIELD->C5_XDTLIB    := dDATAbASE
	FIELD->C5_XMOTLIB   := "Pedido Liberado"
	FIELD->C5_XTIPOL    := "L"
	MSUNLOCK()
ENDIF

RestArea(aArea)	

Return( NIL )