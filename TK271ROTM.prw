#INCLUDE "PROTHEUS.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TK271ROTM ºAutor  ³Norbert Waage Juniorº Data ³  16/03/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Ponto de entrada na definicao da mBrowse do CallCenter uti- º±±
±±º          ³lizada para definir o filtro de exibicao da tabela SUA      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Eletromega                                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function TK271ROTM()

Local aRet		:=	{}
Local aArea		:=	GetArea()
Local aAreaSA1	:=	SA1->(GetArea())
Local cFilSA1	:=	xFilial("SA1")
Local cVends	:=	""
Local cSql      :=  ""

If lTK271Auto 
	RestArea(aArea)
	Return .T.
EndIf

If !(U_IsAdm() .OR. U_IsFree())   

	U_ListaVnd(@cVends)

	SUA->(DbClearFilter())
	SA1->(DbSetOrder(1))
		
	//If ! empty (SUA->(UA_CLIENTE+UA_LOJA))
	
	SUA->(DbSetFilter({|| SUA->UA_VEND $ cVends },;
						  "SUA->UA_VEND $ '"+cVends+"'" ))
    /*
    SUA->(DbSetFilter({||	Iif(SA1->(DbSeek(cFilSA1+SUA->(UA_CLIENTE+UA_LOJA))),SA1->A1_VEND $ cVends,.F.)},;
							"Iif SA1->(DbSeek("+cFilSA1+"+SUA->(UA_CLIENTE+UA_LOJA))),SA1->A1_VEND $ '"+cVends+"',.F.)"))

    */
    //EndIf
EndIF

RestArea(aAreaSA1)
RestArea(aArea)

Return aRet 