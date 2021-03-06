/*
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
����������������������������������������������������������������������������ͻ��
���Programa  � �Autor  �Eletromega             � Data �  17/05/12            ���
����������������������������������������������������������������������������͹��
���Desc.     �Este ponto de entrada � executado antes do cancelamento        ���
��� 		  de um atendimento de Televendas e sua finalidade � permitir    ���
��� 		  que o usu�rio fa�a valida��es para permitir ou n�o o           ���
��� 		  cancelamento do atendimento.                                   ���
���           Retorno: .T. - Cancela o atendimento	                         ���
���          �  			                                    	         ���
����������������������������������������������������������������������������͹��
���Uso       �TELEVENDAS                                                     ���
����������������������������������������������������������������������������ͼ��
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
*/
#Include "rwmake.ch"

User Function TMKVEX()
Local lRet := .T.

If cFilAnt = "04" .And. !Empty(SUA->UA_XNUMTRF)

	//If Upper(Rtrim(cUserName)) $ 'ADV.ADMINISTRADOR.ASSISTENTE8.ASSISTENTE7'  
	If Upper(Rtrim(cUserName)) $ GETMV("FS_CANCINT") // Claudino - 15/08/16 - I1608-873
    
		ApMsgStop( 'Favor solicitar a altera�ao do pedido de transferencia para a logistica GRU!', 'TMKVEX' )	
	
	Else
		
		lRet := .F.
		ApMsgStop( 'Atendimento nao pode ser alterado. Integra�ao filial GRU.', 'TMKVEX' )		
	
	EndIf
	
			
ElseIf cFilAnt == "01" .And. !Empty(SUA->UA_XNUMTRF) 
		
	//If Upper(Rtrim(cUserName)) $ 'ADV.ADMINISTRADOR.ASSISTENTE8.ASSISTENTE7'
	If Upper(Rtrim(cUserName)) $ GETMV("FS_CANCINT") // Claudino - 15/08/16 - I1608-873
    
		ApMsgStop( 'Favor solicitar a altera�ao do pedido de transferencia para a logistica GRU. Favor excluir o pedido na filial Rio!', 'TMKVEX' )	
	
	Else
		
		lRet := .F.
		ApMsgStop( 'Atendimento nao pode ser alterado. Integra�ao filial GRU.', 'TMKVEX' )		
	
	EndIf

			
EndIf

Return(lRet)
