#INCLUDE "PROTHEUS.CH"

/*--------------------------------------------------------|
| Autor | Claudino Domingues              | Data 12/09/12 | 
|---------------------------------------------------------|
| Fun��o: MT097LOK	                                      |
|---------------------------------------------------------|
| Fun��o Padr�o: MATA097                                  |
|---------------------------------------------------------|
| Ponto de entrada executado ao acionar o bot�o Liberar,  |
| antes de abrir a tela para liberar ou bloquear o docu-  |
| mento. A finalidade � que o departamento de importa��o  |
| quer que n�o deixe liberar um pedido quando ele estiver |
| com algum produto bloqueado para importa��o. No caso    |
| esse ponto de entrada trabalha em conjunto com o campo  |
| customizado B1_XBLQIMP, caso o produto posicionado      |
| esteja com o campo B1_XBLQIMP = SIM o pedido n�o sera   |
| liberado.                                               |
-----------------------------------------------------------*/

User Function MT097LOK()

Local _Area    := GetArea()
Local lRet     := .T.
Local cEstFor  := ""
Local cNumero  := ALLTRIM(SCR->CR_NUM)
Local nTotPed  := 0
Local cUsrName := Upper(Rtrim(cUserName))
Local nValor   := SuperGetMv("FS_VLALCPC") 

SC7->(DbSeek(xFilial("SC7")+cNumero)) 

cEstFor := GetAdvFval('SA2','A2_EST',xFilial("SA2")+SC7->C7_FORNECE+SC7->C7_LOJA,1,"")

If cEstFor == "EX" 
    
	While SC7->C7_NUM == cNumero .And. xFilial("SC7") == SC7->C7_FILIAL     
		
		SB1->(DbSeek(xFilial("SB1")+SC7->C7_PRODUTO)) 
		
		If SB1->B1_XBLQIMP == "S" // Verifico se esta bloqueado para importa��o. Se sim apresenta mensagem e retorna ao browse sem liberar o pedido.   
			ApMsgStop("Produto " + AllTrim(SC7->C7_PRODUTO) + " bloqueado para importa��o!","MT097LOK")
			lRet := .F. 
			Exit
	    EndIF
	     
		SC7->(DbSkip())
	EndDo

EndIF

If lRet
	
	SC7->(DbSeek(xFilial("SC7")+cNumero))
	
	While SC7->C7_NUM == cNumero .And. xFilial("SC7") == SC7->C7_FILIAL     
		
		nTotPed += SC7->C7_TOTAL  
		SC7->(DbSkip())
	
	EndDo

	If cUsrName $ 'ADMINISTRATIVO' 
   		
   		If Empty (nValor)
   		 
   			lRet := .F.
   			ApMsgStop('FS_VLALCPC esta vazio!', 'MT097LOK')

   		Else
   			
   			If nTotPed > nValor
   				
   				lRet := .F.
   				ApMsgStop('Valor do pedido esta acima do valor permitido para o aprovador!', 'MT097LOK')
            
            EndIf
   		
   		EndIf		
    
   	EndIf 

EndIf

RestArea(_Area)

Return(lRet)