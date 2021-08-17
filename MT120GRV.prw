#include "Protheus.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MT120GRV  ºAutor  ³Eletromega          º Data ³  11/23/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Ponto de Entrada: MT120GRV                                 º±±
±±º          ³ PROGRAMA: MATA103                                          º±±
±±º Rotina de Inclusão, Alteração, Exclusão e Consulta                    º±±
±±º dos Pedidos de Compras e Autorizações de Entrega                      º±±
±±º O ponto de entrada MT120GRV utilizado para continuar                  º±±
±±º ou não a Inclusão, alteração ou exclusão do Pedido                    º±±
±±º de Compra ou Autorização de Entrega.                                  º±±
±±º MT120GRV - Continuar ou não a inclusão, alteração                     º±±
±±º ou exclusão                                                           º±±
±±º                                                                       º±±
±±ºParamIxb[1]			Caracter			Número do pedido		      º±±							
±±ºParamIxb[2]			Array of Record		Controla a inclusão  		  º±±								
±±ºParamIxb[3]			Array of Record		Controla a alteração    	  º±±									
±±ºParamIxb[4]			Array of Record		Controla a exclusão           º±±
±±º                                                                       º±±
±±ºRetorno                                                                º±±
±±ºlRet(logico)                                                           º±±
±±ºT. Continuar a inclusão, alteração ou exclusão .F.                     º±± 
Não continuar a inclusão, alteração ou exclusão                           º±±
±±º                                                                       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MP11                                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function MT120GRV()

Local cNum     := PARAMIXB[1]
//Local lInclui  := PARAMIXB[2]
Local lAltera  := PARAMIXB[3]
Local lExclui  := PARAMIXB[4]
Local lRet     := .T.
Local cUsrName := Upper(Rtrim(cUserName))
Local aAreaFIE := FIE->(GetArea()) 

If lAltera .Or. lExclui 

	FIE->(dbSetOrder(1)) // FIE_FILIAL, FIE_CART, FIE_PEDIDO, R_E_C_N_O_, D_E_L_E_T_

	If FIE->(dbSeek(xFilial("FIE")+'P'+cNum, .T.))

		If AllTrim(FIE->FIE_TIPO) == 'PA'
			
			If cUsrName $ 'ADMINISTRADOR.ROBERTO.CARLOS.SUMAIA' 
			
				ApMsgStop( 'Pedido com adiantamento relacionado!', 'MT120GRV' )
			
			Else
			
				lRet := .F.
				ApMsgStop( 'Operaçao proibida. Pedido com adiantamento relacionado!', 'MT120GRV' )
				
			EndIf	
		    
		EndIf

	EndIf

EndIf

If lRet .And. lExclui
	cQuery := " SELECT R_E_C_N_O_ FROM " + RetSqlName("SWD")
	cQuery += " WHERE WD_FILIAL = '"+xFilial("SWD")+"' "
	cQuery += " AND WD_XPEDCOM = '"+cNum+"' "
	cQuery += " AND WD_XFILPC = '"+xFilial("SC7")+"' "
	cQuery += " AND D_E_L_E_T_ = '' "

	If Select("WXD") > 0
		WXD->(dbCloseArea())
	EndIf

	DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery) , 'WXD', .T., .F.)

	dbSelectArea("SWD")

	While WXD->(!EOF())
		SWD->(dbGoTo(WXD->R_E_C_N_O_))	
			If Reclock("SWD",.F.)	
				SWD->WD_XPEDCOM	:= ""
				SWD->WD_XFILPC 	:= ""
				SWD->(MsUnLock())
			EndIf
		WXD->(dbSkip())
	EndDo
EndIf

RestArea(aAreaFIE)

Return (lRet)
