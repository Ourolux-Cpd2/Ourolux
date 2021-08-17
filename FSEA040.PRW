#INCLUDE "PROTHEUS.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FSEA040   ºAutor  ³Wilson Jorge Tedokonº Data ³  20/03/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Atualiza o percentual de comissao conforme  tabela         º±±
±±º          ³ valores x comissoes . Chamado pelo PE TMKVFIM.             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Eletromega                                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
/* Rgras de negocios
User Function FSEA040(cNumSUA, cNumSC5)   
       
Local aArea		:= GetArea()
Local aAreaSC5	:= SC5->(GetArea())
Local aAreaSC6	:= SC6->(GetArea())
Local nDecs		:= TamSx3("C6_VLCOM1")[2]
Local cVend		:= ""
Local cTabela	:= ""
Local nComis	:= 0

If !Empty(cNumSC5)
  DbSelectArea("SC5")
  DbSetOrder(1)
  
  If MsSeek(xFilial("SC5")+cNumSC5)
     cVend   := SC5->C5_VEND1
     cTabela := SC5->C5_TABELA
  EndIf 
  
  DbSelectArea("SC6")
  DbSetOrder(1)
  If MsSeek(xFilial("SC6") + cNumSC5)
    While (SC6->C6_NUM == cNumSC5) .And. (SubString(SC6->C6_PEDCLI,4,6) == cNumSUA) .And.;
    (xFilial("SC6") == SC6->C6_FILIAL) 
    
      // Verifica se existe uma tabela de valores x comissoes e 
      // calcula o percentual de comissao do vendedor para o produto.
      
      If U_GetComis(cVend, cTabela, SC6->C6_PRODUTO, SC6->C6_PRCVEN, @nComis) 
        Reclock("SC6",.F.)
    	Replace SC6->C6_COMIS1 With nComis  	  
    	Replace SC6->C6_VLCOM1 With Round( ((nComis/100) * SC6->C6_VALOR ) ,nDecs)
        MsUnlock()
      EndIf
      DbSkip()
      
    End		
  EndIf
EndIf

RestArea(aAreaSC6)
RestArea(aAreaSC5)
RestArea(aArea)

Return nil
*/