#INCLUDE "protheus.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณTMKCND     บAutor  ณEletromega         บ Data ณ  09/06/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณExecu็ใo	Na abertura da tela de condi็ใo de pagamento      บฑฑ
ฑฑบ          ณ Parโmetros	1- C๓digo do Atendimento,2- C๓digo do Cliente บฑฑ 
ฑฑบ          ณ 3- C๓digo da Loja,4- C๓digo do Contato,					  บฑฑ
ฑฑบ			 ณ  5- C๓digo do Operador									  บฑฑ
ฑฑบ          ณ 6- Array contendo 4 posi็๕es:							  บฑฑ
ฑฑบ			 ณ		1- Forma de Pagamento                                 บฑฑ 	
ฑฑบ			 ณ		2- Data												  บฑฑ
ฑฑบ			 ณ		3- Valor da Parcela em Moeda 						  บฑฑ
ฑฑบ			 ณ		4- Valor da Parcela em % 							  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP8                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function TMKCND (cCodAtend, cCodCli, cCodLoja, ;
					  cCodCont, cCodOper, aParcelas)
Local lRet := .T.
Local nlen  := 0
/*
nlen := len(aParcelas)

If ! Empty (aParcelas) .AND. INCLUI

	FOR i := 1 TO nlen
		aParcelas[i][3] := 'BOL'
	NEXT

EndIf
 */
Return(lRet)