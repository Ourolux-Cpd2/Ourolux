
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MT460EST  ºAutor  ³Eletromega          º Data ³  09/26/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ O ponto de Entrada e  chamado antes do estorno do SC9      º±±
±±º          ³ O unico arquivo posicionado no momento e o SC9.            º±±
±±º          ³ Se retornar .T., indica que continua com                   º±±
±±º          ³ o estorno da liberacao dos itens do Pedido de Vendas.      º±±
±±º          ³ Se retornar .F., indica que nao continua com o estorno.    º±±
±±º          ³                                                            º±±                                                       
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP8                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function MT460EST()

Local lRet 	   := .T.
Local aArea	   := GetArea()
Local aAreaSC5 := SC5->(GetArea())
Local lMae     := U_getMae() == "S"//SuperGetMv("FS_MAE") == "S"

DbSelectArea("SC5")
DbSetOrder(1)             // C5_FILIAL, C5_NUM, R_E_C_N_O_ 

If DbSeek(xFilial("SC5") + SC9->C9_PEDIDO ) // Procure no SC5, o número do Pedido
	
	If AllTrim(C5_OK) == "S" .And. lMae 
		lRet := .F.
		ApMsgStop("Estorno proibido. Pedido aguardando faturamento!","MT460EST")
	EndIf
	
EndIf

RestArea(aAreaSC5)
RestArea(aArea)	

Return (lRet)