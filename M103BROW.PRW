/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³M103BROW()  ºAutor  ³Eletromega        º Data ³  17/07/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Executado antes da execucao do browse, serve para          º±± 
±±º			   dos dados no browse (filtro, por exemplo).  			      º±±
±±º																		  º±±
±±º			   LOCALIZAÇÃO:Function MATA103 - Notas Fiscais de Entrada.   º±±
±±º			   EM QUE PONTO: PRE-VALIDACAO DE DADOS P/ BROWSE             º±±
±±º                                                                       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP8                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function M103BROW() 
Local cFil 		:= ''
Local cNomeUsr  := Upper(Rtrim(cUserName))

If cNomeUsr $ 'DEVOLUCAO'  
	cFil := " F1_TIPO $ 'D' .And. AllTrim(F1_SERIE) $ 'UNP' "
	SF1->(dbSetFilter( { || &cFil }, cFil ))
ElseIf cNomeUsr $ 'LOGISTICA'   
	cFil := " F1_TIPO $ 'C' .And. AllTrim(F1_ESPECIE) $ 'NFST.CTR' "
	SF1->(dbSetFilter( { || &cFil }, cFil ))
ElseIf cNomeUsr $ 'COBRANCA1.COBRANCA.FINANCEIRO' 
	cFil := "  F1_TIPO $ 'D' "
	SF1->(dbSetFilter( { || &cFil }, cFil ))
EndIf

/*
If cNomeUsr $ 'DEVOLUCAO'  
	cFil := "@ F1_TIPO IN ('D') AND F1_SERIE IN ('UNP') AND (D_E_L_E_T_ <> '*')"
	SF1->(dbSetFilter( { || &cFil }, cFil ))
ElseIf cNomeUsr $ 'LOGISTICA'   
	cFil := "@ F1_TIPO IN ('C') AND F1_ESPECIE IN ('NFST ','CTR   ') "
	SF1->(dbSetFilter( { || &cFil }, cFil ))
ElseIf cNomeUsr $ 'COBRANCA1.COBRANCA.FINANCEIRO' 
	cFil := "@ F1_TIPO IN ('D') "
	SF1->(dbSetFilter( { || &cFil }, cFil ))
EndIf
*/
Return( NIL )