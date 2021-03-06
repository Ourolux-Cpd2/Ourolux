#include 'protheus.ch'
#include 'parmtype.ch'

//--------------------------------------------------------------------
/*/{Protheus.doc} M460MKB
Filtro que n�o deixa o usu�rio marcar o item para gera��o documento de sa�da (fonte MATA460)
@author Caio
@since 14/02/2020
@version 1.0
@type function
/*/
//--------------------------------------------------------------------

User Function M460MKB()

Local aArea := GetArea()
Local cCond := ""

	Pergunte('MT461A',.F.)
	
	cCond := 'U_M460MKB2(SC9->(C9_FILIAL+C9_PEDIDO))' //.AND. ' + "SC9->C9_VENDA = '" + If(MV_PAR13 <> 2,'09','05') + "'"
	
	If Select("PR1") == 0
		DbSelectArea("PR1")
	Endif
	
	PR1->(dbSetOrder(2))
	
	RestArea(aArea)

Return(cCond)

//--------------------------------------------------------------------  
/*/{Protheus.doc} M460MKB2
//TODO Descri��o auto-gerada.
@author Caio
@since 14/02/2020
@version 1.0
@type function
/*/
//--------------------------------------------------------------------
User Function M460MKB2(cPedido)

Local aArea     := GetArea()
Local lRet      := .T. 

Default cPedido := ""
	
	If GetMV("M4_60MKB01",,.F.) //par�metro para desabilitar customiza��o

		cChvPR1 := Alltrim(GetAdvFVal("PR1","PR1_STINT",xFilial("PR1")+"SC5"+cPedido))
		
		If SC5->(GetAdvFVal("SC5","C5_TPFRETE",cPedido)) == "C" .And. !Empty(cChvPR1)
			
			If Empty(GetAdvFVal("SC5","C5_TRANSP",cPedido))
				
				If IsInCallStack("DOUBLECLICK") .And. IsInCallStack("GETCOLUMNDATA")
				
					MsgStop("Transportadora n�o definida no pedido de venda " + Substr(cPedido,1,2)+"/"+Substr(cPedido,3,6) + ".")

					lRet := .F.
				Endif
				        
			Elseif Alltrim(cChvPR1) == "P"
			 	
			 	If IsInCallStack("DOUBLECLICK") .And. IsInCallStack("GETCOLUMNDATA")
			 	KJI
			 		MsgStop("O pedido " + Substr(cPedido,1,2) + "/" + Substr(cPedido,2,6) + ;
                            " possui pend�ncia de integra��o com a Transpofrete.","M460MKB")
				
					lRet := .F.
				Endif
				
		 	Elseif Alltrim(GetAdvFVal("PR1","PR1_STINT",xFilial("PR1")+"SA4"+cPedido)) == "P"
			 	
			 	If IsInCallStack("DOUBLECLICK") .And. IsInCallStack("GETCOLUMNDATA")
			 	
			 		MsgStop("O pedido " + Substr(cPedido,1,2) + "/" + Substr(cPedido,2,6) + ;
                            " possui pend�ncia de integra��o com a Transpofrete.","M460MKB")
				
					lRet := .F.
				Endif
				
			Endif
			
		Endif
		
	Endif
	
	RestArea(aArea)
	
Return(lRet)