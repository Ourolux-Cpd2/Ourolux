#INCLUDE "PROTHEUS.CH" 

#DEFINE COMP_DATE "20191209"


//-------------------------------------------------------------------------------------
/*/{Protheus.doc} XVLDTMK
Biblioteca de validacoes genericas do CALLCENTER

@type 		function
@author 	Roberto Souza
@since 		09/02/2017
@version 	P12 
 
@return nil
/*/    
//-------------------------------------------------------------------------------------
User Function XVLDTMK()
	Local cInfo := "XVLDTMK "+COMP_DATE
//	MsgAlert( cInfo )
Return( cInfo )              





//--------------------------------------------------------------------
/*/{Protheus.doc} VldItSUB
Funcao chamada do gatilho do campo UB_PRODUTO para replicar o 
pedido de compra do cliente quando informado no primeiro item.

@author Roberto Souza
@since 21/09/2017
@version 1    

@Gatilho
	CAMPO 		: UB_PRODUTO
	REGRA 		: IIf(Existblock("VldItSUB"),Execblock("VldItSUB"),M->UB_PRODUTO)
	C DOMINIO 	: UB_PRODUTO
/*/
//--------------------------------------------------------------------
User Function VldItSUB()
	Local cRet 		:= M->UB_PRODUTO
	Local nPProd    := aScan(aHeader,{ |x| Upper(AllTrim(x[2])) == "UB_PRODUTO" })
	Local nPosItem  := aScan(aHeader,{ |x| Upper(AllTrim(x[2])) == "UB_ITEM" }) 
	                                     
	Local nPItPC	:= aScan(aHeader,{ |x| Upper(AllTrim(x[2])) == "UB_ITEMPC" })
	Local nPNumPC   := aScan(aHeader,{ |x| Upper(AllTrim(x[2])) == "UB_NUMPCOM" })
	
	Local lRepLin   := .T.
	
	If !aCols[n][Len(aHeader)+1] .And. lRepLin
		
		If !Empty(aCols[01][nPItPC]) .And. !Empty(aCols[01][nPNumPC]) 
			nLenIt := Len( AllTrim(aCols[01][nPItPC]))

			If nLenIt > 1
				cSeq	:= StrZero(n,nLenIt)			 
			Else
				cSeq	:= cValToChar(n)
			EndIf
						
			aCols[n][nPItPC]    := cSeq
			aCols[n][nPNumPC] 	:= aCols[01][nPNumPC] 	
		EndIf
	
	EndIf
			
Return( cRet )
