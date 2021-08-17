/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MT440VLD  ºAutor  ³Microsiga           º Data ³  10/16/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Ponto de entrada para validação da execução da rotina       º±±
±±º          ³de processamento da liberação automatica de pedido de venda º±±
±±º          ³O ponto de entrada inibe a execução da rotina.              º±± 
±±º          ³SC5 POSICIONADO									          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP8                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function MT440Vld()

Local lRet      := .T.
Local aArea     := GetArea()
Local lMae    	:= U_getMae() == "S"//SuperGetMv("FS_MAE") == "S"
Local aAreaSC6 	:= SC6->(GetArea())
Local nTSitTrb	:= TamSX3("C6_CLASFIS")[1] 

// Implementacao para tratar as importacoes de Pedidos via SFA
If Type("L410Auto")!="U" .And. L410Auto
	Return .T.
EndIf

If lMae  
	lRet := .F.
	ApMsgStop('Liberação de pedidos e bloqueado durante a emissao do pedido mae!', 'MT440VLD' )
EndIf
/* Rgras de negocios
If lRet .And. SC5->C5_TIPO == "N"
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Validate de Preço Minimo                                ³
	//³ Administrador pode liberar pedidos com preço Minimo     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
 	lRet := U_ValidPrc(3) // Administrador pode liberar pedidos com preço < Prc Min
EndIf
*/
If lRet
	DbSelectArea("SC6")
	DbSetOrder(1)
	
	If MsSeek(xFilial("SC6") + SC5->C5_NUM)
  		While (SC6->C6_NUM == SC5->C5_NUM) .And. (xFilial("SC6") == SC6->C6_FILIAL)
        	If Empty(SC6->C6_CLASFIS) .Or. Len(Alltrim(SC6->C6_CLASFIS)) < nTSitTrb 
				ApMsgStop( 'A Situaçao fiscal do produto ' + Alltrim(SC6->C6_PRODUTO)+ 'esta errada!', 'MT440VLD' )
				lRet := .F.
				Exit
			EndIf
      	   	DbSkip()
        EndDo		
	EndIf
EndIf

RestArea(aArea)
RestArea(aAreaSC6)
Return(lRet)