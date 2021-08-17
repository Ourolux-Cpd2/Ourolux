#include "Protheus.ch"
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �MT120GRV  �Autor  �Eletromega          � Data �  11/23/13   ���
�������������������������������������������������������������������������͹��
���Desc.     � Ponto de Entrada: MT120GRV                                 ���
���          � PROGRAMA: MATA103                                          ���
��� Rotina de Inclus�o, Altera��o, Exclus�o e Consulta                    ���
��� dos Pedidos de Compras e Autoriza��es de Entrega                      ���
��� O ponto de entrada MT120GRV utilizado para continuar                  ���
��� ou n�o a Inclus�o, altera��o ou exclus�o do Pedido                    ���
��� de Compra ou Autoriza��o de Entrega.                                  ���
��� MT120GRV - Continuar ou n�o a inclus�o, altera��o                     ���
��� ou exclus�o                                                           ���
���                                                                       ���
���ParamIxb[1]			Caracter			N�mero do pedido		      ���							
���ParamIxb[2]			Array of Record		Controla a inclus�o  		  ���								
���ParamIxb[3]			Array of Record		Controla a altera��o    	  ���									
���ParamIxb[4]			Array of Record		Controla a exclus�o           ���
���                                                                       ���
���Retorno                                                                ���
���lRet(logico)                                                           ���
���T. Continuar a inclus�o, altera��o ou exclus�o .F.                     ��� 
N�o continuar a inclus�o, altera��o ou exclus�o                           ���
���                                                                       ���
�������������������������������������������������������������������������͹��
���Uso       � MP11                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
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
				ApMsgStop( 'Opera�ao proibida. Pedido com adiantamento relacionado!', 'MT120GRV' )
				
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
