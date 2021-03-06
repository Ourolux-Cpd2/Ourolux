/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �MEGAXFUN  �Autor  �ELETROMEGA          � Data �  10/07/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Functions used in Faturamento                               ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP8                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

#include "rwmake.ch"  
#include "Protheus.ch"

//�������������������������������������������������������������������Ŀ
//�Function ValidPrc(nCod): Validate pre�o digitado                   �
//� nCod = 1 --> User validation campo C6_PRCVEN                      �
//� nCod = 2 --> Validate pre�o DOS ITENS DO aCols (Browse)           �
//� nCod = 3 --> Validate pre�o dos itens de pedido (SC6)             �
//�                                                                   �
//� Return : True/False                                               �
//���������������������������������������������������������������������
/* Rgras de negocios
User Function ValidPrc(nCod)
Local lRet		:= .T.
Local aAreaSC6	:= ""
Local nI
Local nPProd    := "" 
Local nPosPrc   := ""
Local nPosTes   := ""
Local cVldTes   := SuperGetMv("FS_ELE010")

// Implementacao para tratar as importacoes de Pedidos via SFA
If Type("L410Auto")!="U" .And. L410Auto
	Return (lRet)
EndIf

If !U_IsAdm() .And. M->C5_TIPO == 'N' 
	
	If nCod == 1 .And. (aCols[n,aScan(aHeader,{|x|AllTrim(x[2])=="C6_TES"})] $ cVldTes)
		
		lRet := U_VALIDVAL(M->C5_TABELA,"S",aCols[n,aScan(aHeader,{|x|AllTrim(x[2])=="C6_PRODUTO"})],M->C6_PRCVEN) 
	ElseIf nCod == 3
		aAreaSC6 := SC6->(GetArea())
		DbSelectArea("SC6")
		DbSetOrder(1)
	
		If MsSeek(xFilial("SC6") + SC5->C5_NUM)
  			While (SC6->C6_NUM == SC5->C5_NUM) .And. (xFilial("SC6") == SC6->C6_FILIAL)
               	If SC6->C6_TES $ cVldTes   
               		If !(lRet := U_VALIDVAL(SC5->C5_TABELA,"N",SC6->C6_PRODUTO,SC6->C6_PRCVEN))
      					Exit
      				EndIf
      	   		EndIf
      	   		DbSkip()
        	End		
		EndIf
		RestArea(aAreaSC6)
	ElseIf nCod == 2
		nPProd    := aScan(aHeader,{ |x| Upper(AllTrim(x[2])) == "C6_PRODUTO" }) 
		nPosPrc   := aScan(aHeader,{ |x| Upper(AllTrim(x[2])) == "C6_PRCVEN" })
		nPosTes   := aScan(aHeader,{ |x| Upper(AllTrim(x[2])) == "C6_TES" })

		For nI := 1 to Len(aCols) 
			If !aCols[nI][Len(aHeader)+1]
				If aCols[nI][nPosTes] $ cVldTes
					If !(lRet := U_ValidVal(M->C5_TABELA,"N",aCols[nI][nPProd],aCols[nI][nPosPrc]))
						Exit
					EndIf
				EndIf
			EndIf		
		Next
	EndIf 	
EndIf

Return(lRet)
*/
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �PrcXCom  �Autor  �ELETROMEGA           � Data �  10/08/08   ���
�������������������������������������������������������������������������͹��
���Desc.     � CONSULTA Pre�o X Comissao --> Tecla F2 (Pedidos de venda)  ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP8                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function PrcXCom()
Local lRet := .T.

// Implementacao para tratar as importacoes de Pedidos via SFA
If Type("L410Auto")!="U" .And. L410Auto
	If !U_xAuto410()
		Return (.T.)
	EndIf	
EndIf

If M->C5_TIPO == 'N'
	lRet := U_ELEC001()
EndIf

Return (lRet)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �GeraTes  �Autor  �ELETROMEGA           � Data �  10/08/08   ���
�������������������������������������������������������������������������͹��
���Desc.     � Gera Tes no item de pedido de vendas                       ���
���          � Gatilho chamado do campo C6_PRODUTO                        ���
�������������������������������������������������������������������������͹��
���Uso       � AP8                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
/*
User Function GeraTes(cProduto,cTipoPed,cCodCli,cCodLoja,cTes)
// Implementacao para tratar as importacoes de Pedidos via SFA
Local cTpES := ''
Local nPosTes    	:= aScan(aHeader,{ |x| Upper(AllTrim(x[2])) == "C6_TES" })


If Type("L410Auto")!="U" .And. L410Auto
	Return(aCols[n][nPosTes])
EndIf

If C5_TIPO == 'N'
	cTpES := U_MEGAM020(cProduto,cTipoPed,cCodCli,cCodLoja,cTes)
ElseIf C5_TIPO == 'T'
	cTpES := '599'
Else  
	cTpES := aCols[n][nPosTes]
EndIf

Return (cTpES)

*/
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �GeraCF   �Autor  �ELETROMEGA           � Data �  10/08/08   ���
�������������������������������������������������������������������������͹��
���Desc.     � Gera Codigo Fiscal                                         ���
���          � Gatilho do Campo C6_PRODUTO                                ���
�������������������������������������������������������������������������͹��
���Uso       � AP8                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function GeraCF(cCodCli,cCodLoja,cTes)
Local cCF := ''
Local nPosCF    	:= aScan(aHeader,{ |x| Upper(AllTrim(x[2])) == "C6_CF" }) 

If Type("L410Auto")!="U" .And. L410Auto
	Return(aCols[n][nPosCF])
EndIf

If C5_TIPO $ "NT"
	cCF := U_GeraCFO(cCodCli,cCodLoja,cTes)
Else  
	cCF := aCols[n][nPosCF]
EndIf

Return(cCF)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �VldProd   �Autor  �ELETROMEGA          � Data �  10/08/08   ���
�������������������������������������������������������������������������͹��
���Desc.     � Validate produto digitado, User validation campo C6_PRODUTO���
���          � Retorno: .T. caso produto existe na tabela de pre�o        ���
�������������������������������������������������������������������������͹��
���Uso       � AP8                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function VldProd()
Local lRet := .T.

If Type("L410Auto")!="U" .And. L410Auto
	Return(lRet)
EndIf

If (M->C5_TIPO =="N")
	lRet := U_FSEV040()
EndIf

Return(lRet)


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �VerEmb    �Autor  �ELETROMEGA          � Data �  10/08/08   ���
�������������������������������������������������������������������������͹��
���Desc.     � Verifique se pode vender o produto em caixa aberta         ���
���          � Retorno: .T./.F.                                           ��� 
���          � FS_ELE011: Usuarios deste grupo nao tem valida�ao de       ���
���          � Qtd de Embalagem                                           ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP8                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function VerEmb(nRow)
Local nPProd    := ""
Local nPQtd     := ""
Local lRet 		:= .T.

If IsInCallStack("TMKA271")
	nPProd    := aScan(aHeader,{ |x| Upper(AllTrim(x[2])) == "UB_PRODUTO" })
	nPQtd     := aScan(aHeader,{ |x| Upper(AllTrim(x[2])) == "UB_QUANT" })
ElseIf IsInCallStack("MATA410")
	nPProd    := aScan(aHeader,{ |x| Upper(AllTrim(x[2])) == "C6_PRODUTO" })
	nPQtd     := aScan(aHeader,{ |x| Upper(AllTrim(x[2])) == "C6_QTDVEN" })
EndIf 

If !(U_IsAdm() .Or. U_InGroup(GetMV("FS_ELE011")))
    If ( !aCols[nRow][Len(aHeader)+1] )
    	If SB1->( dbSeek( xFilial( 'SB1' ) + aCols[nRow][nPProd] ) )
        	If SB1->B1_CXFECH == "1"  // 1 -> CAIXA FECHADA PARA TODOS
				If !( mod(aCols[nRow][nPQtd],SB1->B1_QE ) == 0 )
					lRet := .F.
					//Amedeo (Tratamento de mensagem para o Portal de Vendas)
					//ApMsgStop( 'Produto ' + Alltrim( aCols[nRow][nPProd] ) + ' s� pode ser vendido com multiplos de ' + AllTrim ( Str ( SB1->B1_QE ) ), 'Embalagem' )
					Aviso( "Embalagem", 'Produto ' + Alltrim( aCols[nRow][nPProd] ) + ' s� pode ser vendido com multiplos de ' + AllTrim ( Str ( SB1->B1_QE ) ), { "Ok" } )
				EndIf
		    // 2 -> PRODUTOS COM CAIXA FECHADA PARA REVENDEDOR  
		    ElseIf (SB1->B1_CXFECH == "2") .AND. (SA1->A1_TIPO $ "R#S")
		       	If !( mod(aCols[nRow][nPQtd],SB1->B1_QE ) == 0 )
					lRet := .F.
					//Amedeo (Tratamento de mensagem para o Portal de Vendas)
					//ApMsgStop( 'Produto ' + Alltrim( aCols[nRow][nPProd] ) + ' s� pode ser vendido com multiplos de ' + AllTrim ( Str ( SB1->B1_QE ) ), 'Embalagem' )
					Aviso( "Embalagem", 'Produto ' + Alltrim( aCols[nRow][nPProd] ) + ' s� pode ser vendido com multiplos de ' + AllTrim ( Str ( SB1->B1_QE ) ), { "Ok" } )
				EndIf
		    // 3 -> PRODUTOS COM multiplos de 10 PARA REVENDEDOR
		    ElseIf (SB1->B1_CXFECH == "3") .AND. (SA1->A1_TIPO $ "R#S")
		       	If !( mod(aCols[nRow][nPQtd],10 ) == 0 )
					lRet := .F.
					//Amedeo (Tratamento de mensagem para o Portal de Vendas)
					//ApMsgStop( 'Produto ' + Alltrim( aCols[nRow][nPProd] ) + ' s� pode ser vendido com multiplos de 10', 'Embalagem' )
					Aviso( "Embalagem", 'Produto ' + Alltrim( aCols[nRow][nPProd] ) + ' s� pode ser vendido com multiplos de 10', { "Ok" } )
				EndIf
		    // 4 -> PRODUTOS COM multiplos de 10 PARA REVENDEDOR
		    ElseIf (SB1->B1_CXFECH == "4") .AND. (SA1->A1_TIPO $ "R#S")
		       	If !( mod(aCols[nRow][nPQtd],30 ) == 0 )
					lRet := .F.
					//Amedeo (Tratamento de mensagem para o Portal de Vendas)
					//ApMsgStop( 'Produto ' + Alltrim( aCols[nRow][nPProd] ) + ' s� pode ser vendido com multiplos de 30', 'Embalagem' )
					Aviso( "Embalagem", 'Produto ' + Alltrim( aCols[nRow][nPProd] ) + ' s� pode ser vendido com multiplos de 30', { "Ok" } )
				EndIf
		    EndIf
		EndIf  // dbSeek()  	
    EndIf
EndIf

Return(lRet)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �getQuant    �Autor  �ELETROMEGA        � Data �  10/08/08   ���
�������������������������������������������������������������������������͹��
���Desc.     � Return Qtd a ser vendidas respeitando as regras de vendas  ���
���          � Retorno: Qtd  que pode ser vendida                         ��� 
���          � 														      ���
���          �                                         					  ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP8                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function getQuant(cProduto,nSldDisp,cTipoCli)
Local nRet 		:= nSldDisp
Local aArea		:= GetArea()
Local aAreaSB1  := SB1->( GetArea() )

If (nSldDisp > 0 .And. !Empty(cProduto) .And. !Empty(cTipoCli) )
	
	If SB1->( dbSeek( xFilial( 'SB1' ) + cProduto  ) )
        	        	
        	If SB1->B1_CXFECH == "1"  // 1 -> CAIXA FECHADA PARA TODOS
				If  (nSldDisp % SB1->B1_QE <> 0)
					nRet := nSldDisp - (nSldDisp % SB1->B1_QE)
				EndIf 
		    ElseIf (SB1->B1_CXFECH == "2") .And. (cTipoCli $ "R#S") // 2 -> PRODUTOS COM CAIXA FECHADA PARA REVENDEDOR  
		       	If (nSldDisp % SB1->B1_QE <> 0)
					nRet := nSldDisp - (nSldDisp % SB1->B1_QE)
				EndIf
		    ElseIf (SB1->B1_CXFECH == "3") .And. (cTipoCli $ "R#S") // 3 -> PRODUTOS COM multiplos de 10 PARA REVENDEDOR
		       	If (nSldDisp % SB1->B1_QE <> 0)
					nRet := nSldDisp - (nSldDisp % 10)	
				EndIf
		    EndIf

	EndIf  // dbSeek  	
EndIf // Function Validation

RestArea(aAreaSB1)
RestArea(aArea)

Return(nRet)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �TotPed    �Autor  �ELETROMEGA          � Data �  10/08/08   ���
�������������������������������������������������������������������������͹��
���Desc.     � Total de pedido de venda                                   ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP8                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function TotPed()

Local aArea		:= GetArea()        		// Guarda a area anterior
Local nI		:= 0                 		// Controle de loop       
Local nValor  	:= 0                     	// Valor Nao Faturado
Local nPTes		:= aScan(aHeader,{ |x| Upper(AllTrim(x[2])) == "C6_TES" }) 
Local nPVlrItem	:= aScan(aHeader,{ |x| Upper(AllTrim(x[2])) == "C6_VALOR" })
Local nPProd    := aScan(aHeader,{ |x| Upper(AllTrim(x[2])) == "C6_PRODUTO" })
Local nValIpi	:= 0                       	// Valor do IPI para o Item

If INCLUI .Or. ALTERA // Inclusao/Altera�ao do pedido
	For nI:=1 TO Len(aCols)

		If !aCols[nI][Len(aHeader)+1] .And. !Empty(aCols[nI][nPTes])
			Dbselectarea("SB1")
			DbsetOrder(1)
			If MsSeek(xFilial("SB1")+aCols[nI][nPProd])	
				nValIpi := (SB1->B1_IPI * aCols[nI][nPVlrItem])/100
			EndIf
		
			nValor  += aCols[nI][nPVlrItem]+nValIpi
		/*		
		Dbselectarea("SF4")
		DbsetOrder(1)
		If MsSeek(xFilial("SF4")+aCols[nI][nPTes])
			If SF4->F4_DUPLIC == "S" //Nao Gera Duplicata
				//Considera o valor de IPI pois faz parte do valor total da nota.
				nValor  += aCols[nI][nPVlrItem]+nValIpi
			EndIf
		EndIf */
		EndIf
	Next nI

Else  // Visaliza�ao do pedido
	For nI:=1 TO Len(aCols)
		If !Empty(aCols[nI][nPTes])
			Dbselectarea("SB1")
			DbsetOrder(1)
	
			If MsSeek(xFilial("SB1")+aCols[nI][nPProd])	
				nValIpi := (SB1->B1_IPI * aCols[nI][nPVlrItem])/100
			EndIf
		
			nValor  += aCols[nI][nPVlrItem]+nValIpi
		EndIf
	Next nI
EndIf

RestArea(aArea)
Return(nValor) 

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �VldTabC5    �Autor  �ELETROMEGA          � Data �  10/08/08   ���
�������������������������������������������������������������������������͹��
���Desc.     � Validate Tabela de pre�o, User validation campo C5_TABELA  ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP8                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function VldTabC5()
Local lRet := .T.

If Type("L410Auto")!="U" .And. L410Auto
	Return(lRet)
EndIf

If (M->C5_TIPO =="N")
	lRet := U_VLDTAB()
EndIf

Return(lRet)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �VerPedCli(nPedido,cStr)                  Data �  10/08/08   ���
�������������������������������������������������������������������������͹��
���Desc.     � Verifique se o campo C6_PEDCLI == cStr                     ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP8                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function VerPedCli(nPedido,cStr)
Local lret := .F.
Local aArea		:= GetArea()
Local aAreaSC6	:= SC6->(GetArea())

DbSelectArea("SC6")
DbSetOrder(1)

If !Empty(nPedido) .And. !Empty(cStr)
	If MsSeek(xFilial("SC6") + nPedido) 
    	While (SC6->C6_NUM == nPedido) .And. (xFilial("SC6") == SC6->C6_FILIAL) 
       		If (SubString(SC6->C6_PEDCLI,1,3) == cStr)
    			lRet := .T. 
    	    	Exit
    		EndIf
    		DbSkip()
    	End
	EndIf    
EndIf

RestArea(aAreaSC6)
RestArea(aArea)

Return(lRet)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �MgSetMV   �Autor  �Eletromega          � Data �  10/20/08   ���
�������������������������������������������������������������������������͹��
���Desc.     � Set MV_ se existe, otherwise create it                     ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP8                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
/*
User Function MegaSetMV(cParam, uValue, cFil)
Local aAreaSX6	:= SX6->(GetArea())
Local aArea	    := GetArea()

dbSelectArea("SX6")
dbSetOrder(1)

If SX6->( dbseek( cFil + cParam ) )
	RecLock("SX6",.F.)
Else
	RecLock( "SX6", .T. )
	SX6->X6_FIL := xFilial("SX6")
	SX6->X6_VAR := cParam
	SX6->X6_TIPO := ValType( uValue )
EndIf
If ValType( uValue ) == "L"
	uValue := If( uValue, "T", "F" )
EndIf
SX6->X6_CONTEUD := AsString( uValue )
If SX6->( FieldPos( "X6_CONTSPA" ) ) > 0
	SX6->X6_CONTSPA := AsString( uValue )
EndIf
If SX6->( FieldPos( "X6_CONTENG" ) ) > 0
	SX6->X6_CONTENG := AsString( uValue )
EndIf
MsUnLock()

RestArea(aAreaSX6)	
RestArea(aArea)

Return uValue
*/

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �SetMae   �Autor  �Eletromega          � Data �   01/06/09   ���
�������������������������������������������������������������������������͹��
���Desc.     � Set status do pedido mae : S - Ativo, N - Nao ativo        ���
���          � O status e gravado no arquivo SZB                          ���
�������������������������������������������������������������������������͹��
���Uso       � AP8                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function setMae(cStatus)
Local lRet 	:= .T. 
Local aArea	:= GetArea()

DbSelectArea("SZB")

If MsSeek(xFilial("SZB"))  
	RecLock( "SZB", .F. )
	Replace SZB->ZB_STATUS WITH cStatus
	MsUnlock()
EndIf    

SZB->(DbCloseArea())
RestArea(aArea)
Return(lRet)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �getMae   �Autor  �Eletromega          � Data �   01/06/09   ���
�������������������������������������������������������������������������͹��
���Desc.     � Get status do pedido mae : S - Ativo, N - Nao ativo        ���
���          � O status e gravado no arquivo SZB                          ���
�������������������������������������������������������������������������͹��
���Uso       � AP8                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function getMae()
Local cRet 	:= 'N' 
Local aArea	:= GetArea()

DbSelectArea("SZB")

If MsSeek(xFilial("SZB"))  
	cRet := SZB->ZB_STATUS 
EndIf    

SZB->(DbCloseArea())
RestArea(aArea)
Return(cRet)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �GeraClas  �Autor  �ELETROMEGA          � Data �  10/08/08   ���
�������������������������������������������������������������������������͹��
���Desc.     � Gera a classifica�ao fiscal do item de pedido de venda     ���
���          � Retorno: classifica�ao fiscal                              ���
�������������������������������������������������������������������������͹��
���Uso       � AP8                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function GeraClas() 
Local aArea		:= GetArea()        		// Guarda a area anterior
Local aAreaSB1  := SB1->(GetArea()) 
Local aAreaSF4  := SF4->(GetArea())
Local nI		:= 0                 		// Controle de loop       
Local nValor  	:= 0                     	// Valor Nao Faturado
Local nPTes		:= aScan(aHeader,{ |x| Upper(AllTrim(x[2])) == "C6_TES" }) 
Local nPClass	:= aScan(aHeader,{ |x| Upper(AllTrim(x[2])) == "C6_CLASFIS" })
Local nPProd    := aScan(aHeader,{ |x| Upper(AllTrim(x[2])) == "C6_PRODUTO" })
Local nPPedCli	:= aScan(aHeader,{ |x| Upper(AllTrim(x[2])) == "C6_PEDCLI" })
Local nTSitTrb	:= TamSX3("C6_CLASFIS")[1]
Local cClass    := ""

For nI:=1 TO Len(aCols)
	If !aCols[nI][Len(aHeader)+1] .And. !Empty(aCols[nI][nPTes]) .And.;
	Substr (aCols[nI][nPPedCli],1,3) <> "TMK" 
	    		
		Dbselectarea("SB1")
		DbsetOrder(1)
		If MsSeek(xFilial("SB1")+aCols[nI][nPProd])	
			cClass := Substr(SB1->B1_ORIGEM,1,1)
		EndIf
		
		Dbselectarea("SF4")
		DbsetOrder(1)
		If MsSeek(xFilial("SF4")+aCols[nI][nPTes])
			cClass += SubStr(SF4->F4_SITTRIB,1,2) 
		EndIf
	
		// Caso a class fis foi digitado a mao
		If Empty(aCols[nI][nPClass]) .Or. Len(Alltrim(aCols[nI][nPClass])) < nTSitTrb
			aCols[nI][nPClass] := cClass
		EndIf 
		  
	EndIf
Next nI

RestArea(aArea)
RestArea(aAreaSB1)
RestArea(aAreaSF4)
Return()

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �VldClas  �Autor  �ELETROMEGA           � Data �  10/08/08   ���
�������������������������������������������������������������������������͹��
���Desc.     � Validate se a classificacao fiscal esta preinchida         ���
���          � Retorno: T/F                                               ���
�������������������������������������������������������������������������͹��
���Uso       � AP8                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function VldClas()
Local lRet 			:= .T.
Local nPClsFis  	:= aScan(aHeader,{ |x| Upper(AllTrim(x[2])) == "C6_CLASFIS" }) 
Local nPProd 	 	:= aScan(aHeader,{ |x| Upper(AllTrim(x[2])) == "C6_PRODUTO" })
Local nTSitTrb		:= TamSX3("C6_CLASFIS")[1]

For nI := 1 to Len( aCols )		
	If !aCols[nI][Len(aHeader)+1]
		If Empty(aCols[nI][nPClsFis]) .Or. Len(AllTrim(aCols[nI][nPClsFis])) < nTSitTrb 
				ApMsgStop( 'A Situa�ao fiscal do produto ' + Alltrim(aCols[nI][nPProd])+ ' esta errada!', 'VldClas' )
				lRet := .F.
				Exit
		EndIf
	EndIf           
Next

Return (lRet)


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �vldNFE  �Autor  �Eletromega            � Data �  05/17/10   ���
�������������������������������������������������������������������������͹��
���Desc.     � Valida�aoes de NFE antes da libera�ao do pedido            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP10                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function vldNFE()
Local lRet 		:= .T.
Local aArea		:= GetArea()        		// Guarda a area anterior
Local aAreaSF4  := SF4->(GetArea())
Local nI		:= 0                 		// Controle de loop
Local aNfeSA1	:= ""       
Local nPTes		:= aScan(aHeader,{ |x| Upper(AllTrim(x[2])) == "C6_TES" }) 

If M->C5_TIPO $ 'D.B' 
	aNfeSA1 := GetAdvFVal("SA2",{"A2_COD_MUN","A2_EMAIL","A2_MUN"},xFilial("SA2")+M->(C5_CLIENTE+C5_LOJACLI),1,{"",""})
Else
	aNfeSA1 := GetAdvFVal("SA1",{"A1_COD_MUN","A1_EMAIL","A1_MUN"},xFilial("SA1")+M->(C5_CLIENTE+C5_LOJACLI),1,{"",""})
EndIf
If Empty(aNfeSA1[1]) 
	ApMsgStop('Favor corrigir o Cod. do Municipio do cliente: ';
          + M->C5_CLIENTE + '/' + C5_LOJACLI, 'VldNFE')
 	lRet := .F. 
ElseIf Empty(aNfeSA1[2]) .Or. !('@' $ aNfeSA1[2]) 
	ApMsgStop('Favor corrigir o email do cliente: ';
          + M->C5_CLIENTE + '/' + C5_LOJACLI, 'VldNFE')
 	lRet := .F.
ElseIf Empty(aNfeSA1[3])
	ApMsgStop('Favor corrigir o nome do Municipio: ';
          + M->C5_CLIENTE + '/' + C5_LOJACLI, 'VldNFE')
 	lRet := .F.
EndIf  

If lRet
	Dbselectarea("SF4")
	DbsetOrder(1)
 	For nI:=1 TO Len(aCols)
		If !aCols[nI][Len(aHeader)+1] .And. !Empty(aCols[nI][nPTes]) 
	    	If MsSeek(xFilial("SF4")+aCols[nI][nPTes])
				If Empty(SF4->F4_SITTRIB) .Or. Empty(SF4->F4_CTIPI) .Or.;
					Empty(SF4->F4_CSTPIS) .Or. Empty(SF4->F4_CSTCOF)
					lRet := .F.
					ApMsgStop( 'Verifique os codigos de impostos no cadastro de Tipos de Entrada e Sa�da (SF4) ';
					+ Alltrim(aCols[nI][nPTes])+ ' esta incompleto!', 'VldNFE' )
			    	Exit
				EndIf   
			EndIf
		EndIf
	Next nI
EndIf

RestArea(aArea)
RestArea(aAreaSF4)
Return (lRet)


//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// 
/*
User Function nGetValPed() 
IF SELECT("TMP1") > 0
	DBSELECTAREA("TMP1")
	DBCLOSEAREA()
ENDIF


cQuery := " SELECT SUM( (SC6.C6_QTDVEN-SC6.C6_QTDENT) * (SC6.C6_PRCVEN + ROUND(SC6.C6_PRCVEN *(SC5.C5_ACRSFIN/100),2))) TOTPED"
cQuery += " FROM "+RetSqlName("SC6")+ " SC6,"
cQuery += "      "+RetSqlName("SC5")+ " SC5,"
cQuery += "      "+RetSqlName("SF4")+ " SF4,"  
cQuery += "      "+RetSqlName("SF4")+ " SF4,"  
cQuery += " WHERE (SC6.C6_QTDVEN-SC6.C6_QTDENT) > 0"		//Alterado para compatibiliza��o da nova estrtutra
cQuery += "   AND SC6.C6_BLQ  = '  '"
cQuery += "   AND SC6.C6_TES  = SF4.F4_CODIGO"
cQuery += "   AND SF4.F4_DUPLIC = 'S'"
cQuery += "   AND SC6.C6_NUM = SC5.C5_NUM"
cQuery += "   AND SC6.C6_NUM <> '" + cNumPed + "'"
cQuery += "   AND SC6.C6_CLI  = '" + cCliente + "'"
cQuery += "   AND SC6.C6_LOJA = '" + cLoja + "'"
cQuery += "   AND SC5.C5_TIPO = 'N'"
cQuery += "   AND SC6.D_E_L_E_T_ <> '*'"
cQuery += "   AND SC5.D_E_L_E_T_ <> '*'"
cQuery += "   AND SF4.D_E_L_E_T_ <> '*'"

DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery) , 'TMP1', .T., .F.)
DBSELECTAREA("TMP1")
DBGOTOP()

nPedAprov := TMP1->TOTPED
DbCloseArea()
*/








 
