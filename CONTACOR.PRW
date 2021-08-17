#INCLUDE "Topconn.ch"
#INCLUDE "Protheus.ch"

User Function CONTACOR(nOp)

Local cRet := ""

If nOp == 1

cRet:=Posicione("SA6",1,xFilial("SA6")+"237"+SUBS(SRA->RA_BCDEPSA,4,5),"A6_DVAGE")

Else
cRet:=StrZero(Val(Subs(StrTran(SRA->RA_CTDEPSA,"",""),1,Len(alltrim(StrTran(SRA->RA_CTDEPSA,"-","")))-1)),12)

EndIf  

Return cRet
