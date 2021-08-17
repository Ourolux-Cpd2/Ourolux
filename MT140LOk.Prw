#include "Protheus.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MT140LOK  ºAutor  ³Eletromega          º Data ³  09/11/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Ponto de Entrada: MT140LOK                                 º±±
±±º          ³ PROGRAMA: Ma140LinOk()                                     º±±
±±º          ³ validar as informações preenchidas no aCols de cada        º±±
±±º            item do pré-documento de entrada      					  º±±
±±º                                 									  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function MT140LOK()

Local aTotais 		:= ParamIXB[2]
Local aDesp   		:= ParamIXB[3]

Local nPosCod		:= aScan(aHeader,{ |x| Upper(AllTrim(x[2])) == "D1_COD" })
Local nPosQuant		:= aScan(aHeader,{ |x| Upper(AllTrim(x[2])) == "D1_QUANT" })
Local nPosPed		:= aScan(aHeader,{ |x| Upper(AllTrim(x[2])) == "D1_PEDIDO" }) 
Local nPosItemPC	:= aScan(aHeader,{ |x| Upper(AllTrim(x[2])) == "D1_ITEMPC" })
Local nPNFOri		:= aScan(aHeader,{ |x| Upper(AllTrim(x[2])) == "D1_NFORI" }) 
Local nPSerOri   	:= aScan(aHeader,{ |x| Upper(AllTrim(x[2])) == "D1_SERIORI" })

Local lRet          := .T. 
Local aArea 		:= GetArea()
Local aAreaSC7 		:= SC7->(GetArea())
Local nRet          := 0
Local cXpcnfe       := '' 

Local nLen,nDel,cInd

If !l140Auto .And. cA100For <> '001049' 

	cXpcnfe := GetAdvFVal("SA2","A2_XPCNFE",xFilial("SA2")+cA100For+cLoja,1,"S")
	
	If CTIPO == 'N'
	
		If !acols[N,len(aheader)+1]
	
			SC7->(DBSETORDER(4)) // FILIAL+PRODUTO+PEDIDO+ITEM
	
			// Tratmento para deixar o numero e o item de 
			// pedido de compras obrigatorios na pre nota 

			If !( SC7->(DBSEEK ( xFilial("SC7") + aCols[ n ][ nPosCod ] + ;
					aCols[ n ][ nPosPed ] + aCols[ n ][ nPosItemPC ] ) )) 
	 			
	 			If cXpcnfe == 'S'
	 				
	 				lRet := .F.
	 				ApMsgStop("Informe o numero de PC e item usando as teclas F5/F6", 'MT140LOK')
	 			
	 			EndIf  
	
			EndIf

		EndIf
	
	EndIf

	RestArea(aAreaSC7)
	RestArea(aArea)

EndIf

Return (lRet)

/*
If !acols[N,len(aheader)+1] //.And. !U_IsAdm() 

	If CTIPO == 'N' .And. ALLTRIM(CESPECIE) # 'NFST' .And.;
	 					  ALLTRIM(CESPECIE) # 'CTR'
	   	cInd	:= Indexord()
		SC7->(DBSETORDER(4)) // FILIAL+PRODUTO+PEDIDO+ITEM
	
		If ! ( SC7->(DBSEEK ( xFilial("SC7") + aCols[ n ][ nPosCod ] + ;
	 		aCols[ n ][ nPosPed ] + aCols[ n ][ nPosItemPC ] ) )) 
	 		lRet := .F.
	 		MsgInfo("Informe o numero de pedido e item usando F5/F6")  
		End 
	
		If lRet .And. (aCols[ n ][ nPosQuant ] > (SC7->C7_QUANT - SC7->C7_QUJE))
			lRet := .F.
			MsgInfo("Nao pode alterar a Quantidade!")
		End
	
		Dbsetorder(cInd)

	ElseIf ALLTRIM(CESPECIE) == 'NFST' .Or. ALLTRIM(CESPECIE) == 'CTR'
		If !ISINCALLSTACK("A116INCLUI")
			lRet := U_VldFrete(aCols[N][nPosCod],aCols[N][nPNFOri],aCols[N][nPSerOri])
		EndIf
	
	EndIf
	
EndIf
*/
