#INCLUDE "PROTHEUS.CH"

User Function AtuAcolsTmk(cProduto)

Local cCfo	:= ""
Local cTes	:= U_MEGAM020(cProduto)

uRet := MaAvalTes("S",cTes) .AND. MAFISREF("IT_TES","TK273",cTes) .AND. TK273Calcula()                                                                            

cCfo := TK273CFO(Nil,Nil,cTes)

Return cCfo
