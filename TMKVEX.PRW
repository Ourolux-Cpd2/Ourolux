/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ ºAutor  ³Eletromega             º Data ³  17/05/12            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Este ponto de entrada é executado antes do cancelamento        º±±
±±º 		  de um atendimento de Televendas e sua finalidade é permitir    º±±
±±º 		  que o usuário faça validações para permitir ou não o           º±±
±±º 		  cancelamento do atendimento.                                   º±±
±±º           Retorno: .T. - Cancela o atendimento	                         º±±
±±º          ³  			                                    	         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³TELEVENDAS                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
#Include "rwmake.ch"

User Function TMKVEX()
Local lRet := .T.

If cFilAnt = "04" .And. !Empty(SUA->UA_XNUMTRF)

	//If Upper(Rtrim(cUserName)) $ 'ADV.ADMINISTRADOR.ASSISTENTE8.ASSISTENTE7'  
	If Upper(Rtrim(cUserName)) $ GETMV("FS_CANCINT") // Claudino - 15/08/16 - I1608-873
    
		ApMsgStop( 'Favor solicitar a alteraçao do pedido de transferencia para a logistica GRU!', 'TMKVEX' )	
	
	Else
		
		lRet := .F.
		ApMsgStop( 'Atendimento nao pode ser alterado. Integraçao filial GRU.', 'TMKVEX' )		
	
	EndIf
	
			
ElseIf cFilAnt == "01" .And. !Empty(SUA->UA_XNUMTRF) 
		
	//If Upper(Rtrim(cUserName)) $ 'ADV.ADMINISTRADOR.ASSISTENTE8.ASSISTENTE7'
	If Upper(Rtrim(cUserName)) $ GETMV("FS_CANCINT") // Claudino - 15/08/16 - I1608-873
    
		ApMsgStop( 'Favor solicitar a alteraçao do pedido de transferencia para a logistica GRU. Favor excluir o pedido na filial Rio!', 'TMKVEX' )	
	
	Else
		
		lRet := .F.
		ApMsgStop( 'Atendimento nao pode ser alterado. Integraçao filial GRU.', 'TMKVEX' )		
	
	EndIf

			
EndIf

Return(lRet)
