#include "Protheus.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณMT100LOK  บAutor  ณEletromega          บ Data ณ  11/23/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Ponto de Entrada: MT100LOK                                 บฑฑ
ฑฑบ          ณ PROGRAMA: MATA103                                          บฑฑ
ฑฑบ          ณ VALIDACAO ADICIONAL PARA ITEM NF ENTRADA                   บฑฑ
ฑฑบ  executa este ponto de entrada para uma validacao 					  บฑฑ
ฑฑบ  adicional da linha toda do aCols									  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function MT100LOK()

Local nPosCod		:= aScan(aHeader,{ |x| Upper(AllTrim(x[2])) == "D1_COD" })
Local nPosQuant		:= aScan(aHeader,{ |x| Upper(AllTrim(x[2])) == "D1_QUANT" })
Local nPosPed		:= aScan(aHeader,{ |x| Upper(AllTrim(x[2])) == "D1_PEDIDO" }) 
Local nPosItemPC	:= aScan(aHeader,{ |x| Upper(AllTrim(x[2])) == "D1_ITEMPC" })
Local nPNFOri		:= aScan(aHeader,{ |x| Upper(AllTrim(x[2])) == "D1_NFORI" }) 
Local nPSerOri   	:= aScan(aHeader,{ |x| Upper(AllTrim(x[2])) == "D1_SERIORI" })
Local nPLoteCtl     := aScan(aHeader,{ |x| Upper(AllTrim(x[2])) == "D1_LOTECTL" })
Local nPLoteFor     := aScan(aHeader,{ |x| Upper(AllTrim(x[2])) == "D1_LOTEFOR" }) 
Local nPLocal       := aScan(aHeader,{ |x| Upper(AllTrim(x[2])) == "D1_LOCAL" }) 
Local nPTes         := aScan(aHeader,{ |x| Upper(AllTrim(x[2])) == "D1_TES" })
Local nPosTot       := aScan(aHeader,{ |x| Upper(AllTrim(x[2])) == "D1_TOTAL" })
Local lRet          := .T. 
Local aAreaSC7 		
Local nRet          := 0
Local cXpcnfe       := ''
Local nLen,nDel

//Conout("Modulo: " + cmodulo +'    '+ " FunName()" + FunName() ) 

If FunName() <> 'MATA116'

	If !l103Auto 

		cXpcnfe  := GetAdvFVal("SA2","A2_XPCNFE",xFilial("SA2")+cA100For+cLoja,1,"S")
		aAreaSC7 := SC7->(GetArea())
	
		If !acols[N,len(aheader)+1]  

			If CTIPO == "N" .Or. (CTIPO =="C" .And. AllTrim(cEspecie) $ "NFST|CTE")  // wadih 22-02-2015
	 					
				If cA100For <> '001049' // ELETROMEGA

					SC7->(DBSETORDER(4)) // FILIAL+PRODUTO+PEDIDO+ITEM
	
					If !( SC7->(DBSEEK ( xFilial("SC7") + aCols[ n ][ nPosCod ] + ;
	 					aCols[ n ][ nPosPed ] + aCols[ n ][ nPosItemPC ] ) )) 
	 		            
	 		            	lRet := .F.
	 						ApMsgStop("Informe o numero de PC e item!", 'MT100LOK')
	 					
						
	 		            
	 				ElseIf (aCols[ n ][ nPosQuant ] > (SC7->C7_QUANT - SC7->C7_QUJE))  
		    
		 				//lRet := .F.
						//MsgInfo("Nao pode alterar a Quantidade!")
		
					EndIf
		
				EndIf
		
				If lRet .AND. SB1->B1_RASTRO == 'L' .And. Empty(aCols[n][nPLoteCtl]) .And. CTIPO == "N"
			
					lRet := .F.
					ApMsgStop('Favor informar o campo Lote.', 'MT100LOK')
		
				EndIf
		
				If lRet .AND. SB1->B1_RASTRO == 'L' .And. Empty(aCols[n][nPLoteFor]) .And. CUFORIG = 'EX' 
			
					lRet := .F.
					ApMsgStop('Favor informar o campo Lote Fornece.', 'MT100LOK')
		
				EndIf
	
			ElseIf CTIPO == 'D' .And. cFormul == "S"
		
				If AvalTes(aCols[ n ][ nPTes ],"S","SN")	// If TES movimento o estoque "S"	
					
						If aCols[n][nPLocal] == '01' 
							lRet := .F.
							ApMsgStop( 'Favor utilizar um outro almoxarifado. Apos a autoriza็ao da Sefaz, favor transferir o saldo para o almoxarifao 01', 'MT100LOK' )
						EndIf
	        
	        	EndIf
		
			EndIf  	
	
		EndIf

		RestArea(aAreaSC7)
	
	EndIf

/* ElseIf (FunName() == 'MATA116')
	
	If Empty( aCols[ n ][ nPosPed ] ) .And. !aCols[n,Len(aheader)+1]
		lRet := .F.
		ApMsgStop( 'Favor Informar o n๚mero do pedido de compras', 'MT100LOK' )
	Else
		If Select( "XMT100" ) > 0
			XMT100->( dbCloseArea() )
		EndIf

		BEGINSQL ALIAS "XMT100"
			SELECT SUM(C7_TOTAL) TOTAL
			 FROM %table:SC7% SC7
			WHERE C7_FILIAL = %exp:xFilial("SC7")%
			  AND C7_NUM = %exp:aCols[ n ][ nPosPed ]%
			  AND C7_PRODUTO = %exp:aCols[ n ][ nPosCod ]%
			  AND C7_FORNECE = %exp:cA100For%
			  AND C7_LOJA = %exp:cLoja%
			  AND C7_CONAPRO = 'L'
			  AND C7_ENCER <> 'E'
			  AND SC7.%NotDel%
		ENDSQL

		If !aCols[n,Len(aheader)+1]
			If XMT100->TOTAL == 0
				lRet := .F.
				Aviso( "Aten็ใo", "Nใo hแ pedido de compras com saldo liberado para este fornecedor/produto", {"Ok"}, 2, "MT100LOK" )
			ElseIf aCols[ n ][ nPosTot ] > XMT100->TOTAL
				lRet := .F.
				Aviso( "Aten็ใo", "O valor mแximo para este produto ้: " + cValToChar( XMT100->TOTAL ), {"Ok"}, 2, "MT100LOK" )
			EndIf
		EndIf

		XMT100->( dbCloseArea() )
	EndIf     */

EndIf

Return(lRet)


User Function VldFrete(cProduto,cNotaOri,cSeriOri)
Local lRet 		:= .T.
Local cMsg 		:= ''
Local cConheci 	:= '' 
    
nRet := U_Despacho(cProduto,cNotaOri,cSeriOri,@cConheci)	

If nRet == 1
	lRet := .F.
	cMsg := 'Nota Fiscal ' + cNotaOri + '/' + cSeriOri + ', nใo existe!'
   	ApMsgStop(cMsg, 'Frete')
ElseIf nRet == 2
	lRet := .F.
	cMsg := 'Nota Fiscal ' + cNotaOri + '/' + cSeriOri + ', ja foi despachada no: ' + cConheci
   	ApMsgStop(cMsg, 'Frete')
ElseIf nRet == 3	
	lRet := .F.
	cMsg := "Nota Fiscal " + cNotaOri + '/' + cSeriOri + ', ja foi redespachada no: ' + cConheci 
	ApMsgStop(cMsg, 'Frete')
ElseIf nRet == 4	
	lRet := .F.
	cMsg := "Sem NF/serie original!" 
	ApMsgStop(cMsg, 'Frete')
ElseIf nRet == 5	
	lRet := .F.
	cMsg := "Produto errado!" 
	ApMsgStop(cMsg, 'Frete')
ElseIf nRet == 6	
	lRet := .F.
	cMsg := "Nota Fiscal " + cNotaOri + '/' + cSeriOri + ', ja foi devolvida no: ' + cConheci
	ApMsgStop(cMsg, 'Frete')
EndIf

Return(lRet)

/*
0- ok
1- Nota de saida not found 
2- Nota depachada
3- Nota redepachada
4- parametros errados
*/

User Function Despacho(cProduto,cNotaOri,cSeriOri,cConheci) 
Local nRet			:= 0
Local aArea 		:= GetArea()
Local areaSF2       := SF2->(GetArea())
Local cQuery  		:= ''
Local cAliasQry		:= "TMP"
Local cFsFrete  	:= SuperGetMv("FS_FRETE")

If Select(cAliasQry) != 0
	(cAliasQry)->(DbCloseArea())
EndIf

If !Empty(cNotaOri) .And. !Empty(cSeriOri) .And. !Empty(cProduto) 

	SF2->( dbSeek( xFilial('SF2')+ cNotaOri + cSeriOri + Space(8), .T.)) 
	
	If SF2->F2_DOC <> cNotaOri .Or. SF2->F2_SERIE <> cSeriOri
       	nRet := 1
    ElseIf !(AllTrim(cProduto) $ cFsFrete)  
    	nRet := 5
    Else
		cQuery := "SELECT SD1.D1_NFORI ,SD1.D1_SERIORI, SD1.D1_COD, "
		cQuery += "RTRIM(SD1.D1_DOC) + '/' + SD1.D1_SERIE AS CONHECI, SF1.F1_STATUS "
		cQuery += "FROM " + RetSqlName("SD1") + " SD1 INNER JOIN "
		cQuery += " " + RetSqlName("SF1") + " SF1 "
		cQuery += "ON SD1.D1_FILIAL = SF1.F1_FILIAL AND " 
		cQuery += "SD1.D1_FORNECE = SF1.F1_FORNECE AND " 
		cQuery += "SD1.D1_LOJA = SF1.F1_LOJA  AND " 
		cQuery += "SD1.D1_SERIE = SF1.F1_SERIE AND " 
		cQuery += "SD1.D1_DOC = SF1.F1_DOC  " 
		cQuery += "WHERE "
	    cQuery += "SD1.D_E_L_E_T_ = ' ' AND SF1.D_E_L_E_T_ = ' ' AND "
		cQuery += "SD1.D1_FILIAL = '" + xFilial("SD1") + "' AND "
		cQuery += "SF1.F1_FILIAL = '" + xFilial("SF1") + "' AND "
		//cQuery += "SD1.D1_COD IN " + FormatIn(cFsFrete,"/") + " AND "
		cQuery += "SD1.D1_COD =  '" + cProduto + "' AND "
		cQuery += "SD1.D1_NFORI = '" + cNotaOri + "' AND " 
		cQuery += "SD1.D1_SERIORI = '" + cSeriOri + "' "
		cQuery += "ORDER BY D1_COD"

	   	dbUseArea(.T., "TOPCONN", TCGENQRY(,,cQuery), cAliasQry)

   		While (cAliasQry)->(!Eof())
        	If !Empty((cAliasQry)->F1_STATUS) 
        		If	AllTrim((cAliasQry)->D1_COD) $ 'FRETE'
        			cConheci	:= AllTrim((cAliasQry)->CONHECI)  
        			nRet 		:= 2
        		ElseIf AllTrim((cAliasQry)->D1_COD) $ 'REDESPACHO' 
        			cConheci	:= AllTrim((cAliasQry)->CONHECI)
        			nRet 		:= 3
        		ElseIf	AllTrim((cAliasQry)->D1_COD) $ 'DEVOLUCAO'
        			cConheci	:= AllTrim((cAliasQry)->CONHECI)
        			nRet 		:= 6
        		EndIf
       		EndIf
       		(cAliasQry)->(dbSkip())
    	EndDo
        
    	(cAliasQry)->(DbCloseArea())
	
	EndIf
Else
	nRet := 4
EndIf	

RestArea(aArea)
RestArea(areaSF2)
Return(nRet)
