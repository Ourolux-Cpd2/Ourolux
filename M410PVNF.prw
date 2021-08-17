#include 'protheus.ch'
#include 'parmtype.ch'

//--------------------------------------------------------------------
/*/{Protheus.doc} M410PVNF
Executado antes da rotina de gera��o de NF's (MA410PVNFS()).
Verifica se existe pendencia de integra��o "sele��o transportadora" com a TranspoFrete
@author Caio
@since 11/02/2020
@version 1.0
@return lRet, .T. - prossegue o processamento para a gera��o da NF
@return lRet, .F. - impede o processamento para a gera��o da NF
@type function
/*/
//--------------------------------------------------------------------

User Function M410PVNF()
	
Local aArea := GetArea()
Local lRet  := .T.
	
	If GetMV("M4_0PVNF01",,.F.) //par�metro para desabilitar customiza��o
		
		If SC5->C5_TPFRETE == "C"
			
			If Empty(SC5->C5_TRANSP)
							
				MsgStop("Transportadora n�o definida no pedido de venda " + SC5->C5_FILIAL+"/"+SC5->C5_NUM + ".")
				        
				lRet := .F.
		        
			Endif
			
			If lRet
				
				If Select("PR1") == 0
					DbSelectArea("PR1")
				Endif
				
				PR1->(dbSetOrder(2)) //PR1_FILIAL + PR1_ALIAS + PR1_CHAVE
				 
				If PR1->(dbSeek(xFilial("PR1")+"SA4"+SC5->C5_FILIAL+SC5->C5_NUM))
				
					If PR1->PR1_STINT == "P" 
							
						MsgStop("N�o ser� poss�vel prosseguir com a gera��o do documento de sa�da, " + ;
						        "pois existem informa��es pendentes de integra��o com a Transpofrete.")
						        
						lRet := .F.
						
					Endif
					
				Endif  
				
				If PR1->(dbSeek(xFilial("PR1")+"SC5"+SC5->C5_FILIAL+SC5->C5_NUM))
				
					If PR1->PR1_STINT == "P"
					
							
						MsgStop("N�o ser� poss�vel prosseguir com a gera��o do documento de sa�da, " + ;
						        "pois existem informa��es pendentes de integra��o com a Transpofrete.")
						        
						lRet := .F.
						
					Endif
					
				Endif  
			
			Endif
			
			If lRet
				
				If Empty(SC5->C5_TRANSP)
					
					MsgStop("N�o ser� poss�vel prosseguir com a gera��o do documento de sa�da, " + ;
					        "pois a transportadora n�o foi informada.")
					        
					lRet := .F.
					
				Endif
				
			Endif
			
		Endif
	
	Endif
	 
	RestArea(aArea)
	
Return(lRet)