/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³M410ALOK  ºAutor  ³Microsiga           º Data ³  10/06/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Executado antes de iniciar a alteracao do pedido de venda  º±±
±±º          ³ Retorno -  Variavel logica, sendo:                         º±±
±±º          ³ .T. Prossegue alteracao do Pedido de Venda                 º±±
±±º          ³ .F. Impede alteracao no pedido de venda                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP8                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function M410ALOK()

Local aArea := GetArea()
Local lRet  := .T.
Local lMae  := U_getMae() == "S"//SuperGetMv("FS_MAE") == "S"
Local lTmk  := U_VerPedCli(SC5->C5_NUM,"TMK")

// Implementacao para tratar as importacoes de Pedidos via SFA
If Type("L410Auto")!="U" .And. L410Auto
	If !U_xAuto410()
		Return (.T.)
	EndIf
EndIf
If lTmk .And. !U_IsAdm() .And. !UPPER(cUserName) $ "ADV|COORDVENDAS" .And. !IsInCallStack("U_INTRJ")
	lRet := .F.
   	ApMsgStop('Pedido so pode ser alterado no modulo Call Center.','M410ALOK')
EndIf 
If lRet .And. AllTrim(SC5->C5_OK) == "S" .And. lMae 
	lRet := .F.
	ApMsgStop('Pedido não pode ser alterado pois encontra-se aguardando faturamento.','M410ALOK')
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄI
//³FS_ELE004 = Codigode grupo ALTTES, FS_ELE010 = Codigo de grupo ALTTESPED     ³
//³Usuaros que pertence aos grupos ALTTES, E ALTTESPED so pode aletrar          ³ 
//³pedidos de vendedor '000000'                                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄI
/*
If lRet .And. !U_IsAdm() 
	If U_VLDUSGRP(GetMV("FS_ELE004")) .And. U_InGroup(GetMV("FS_ELE010"))
		If SC5->C5_VEND1 != '000000'
			lRet := .F.
			ApMsgStop('Pedido não pode ser alterado!','M410ALOK')
		EndIf
	EndIf
EndIf
*/      

RestArea(aArea)
Return(lRet)