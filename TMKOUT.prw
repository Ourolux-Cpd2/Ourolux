#INCLUDE "PROTHEUS.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TMKOUT    ºAutor  ³Norbert Waage Juniorº Data ³  27/04/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Rotina para manter o filtro do SUA ativo apos a saida da    º±±
±±º          ³rotina de atendimento                                       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Eletromega                                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function TMKOUT(lMsg,nOpc)

Local aArea		:= GetArea()
Local aAreaSA1	:=	SA1->(GetArea())
Local cFilSA1	:=	xFilial("SA1")
Local cVends	:=	""
Local lRet := .T.

If lTK271Auto 
	RestArea(aArea)
	Return .T.
EndIf

SetKey(VK_F4,	{ || AllWaysTrue() } ) // Disable a consulta do preço "F4"

SUA->(DbClearFilter())

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Executa filtro no SUA³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !(U_IsAdm() .OR. U_IsFree())

	U_ListaVnd(@cVends)

	SUA->(DbClearFilter())
	SA1->(DbSetOrder(1))
    /*
	SUA->(DbSetFilter({||	Iif(SA1->(DbSeek(cFilSA1+SUA->(UA_CLIENTE+UA_LOJA))),SA1->A1_VEND $ cVends,.F.)},;
					"Iif SA1->(DbSeek("+cFilSA1+"+SUA->(UA_CLIENTE+UA_LOJA))),SA1->A1_VEND $ '"+cVends+"',.F.)"))
    */
    SUA->(DbSetFilter({|| SUA->UA_VEND $ cVends },;
						  "SUA->UA_VEND $ '"+cVends+"'" ))
    
EndIF

RestArea(aAreaSA1)
RestArea(aArea)

Return lRet