//
#INCLUDE "PROTHEUS.CH"

User Function GeraTESCF()

Local lRet		:= .T.
Local cProduto  := ""
Local cTipoPed  := ""
Local cCodCli   := ""
Local cCodLoja  := ""
Local cTes      := ""
Local nPosProd  := ""
Local nPosTES	:= ""
Local nPosCF	:= ""

If IsInCallStack("MATA410")
	cTipoPed     := M->C5_TIPOCLI
	cCodCli      := M->C5_CLIENTE
	cCodLoja     := M->C5_LOJACLI
	cTes         := M->C5_TABELA
	nPosProd     := aScan(aHeader,{ |x| Upper(AllTrim(x[2])) == "C6_PRODUTO" })
	nPosTES      := aScan(aHeader,{ |x| Upper(AllTrim(x[2])) == "C6_TES" })
	nPosCF       := aScan(aHeader,{ |x| Upper(AllTrim(x[2])) == "C6_CF" })
ElseIf IsInCallStack("TMKA271")
	cTipoPed     := M->UA_TIPOCLI
	cCodCli      := M->UA_CLIENTE
	cCodLoja     := M->UA_LOJA
	cTes         := M->UA_TABELA
	nPosProd     := aScan(aHeader,{ |x| Upper(AllTrim(x[2])) == "UB_PRODUTO" })
	nPosTES      := aScan(aHeader,{ |x| Upper(AllTrim(x[2])) == "UB_TES" })
	nPosCF       := aScan(aHeader,{ |x| Upper(AllTrim(x[2])) == "UB_CF" })
EndIf

For nI := 1 to len(aCols)
	If !aCols[nI][len(aHeader)+1]
		aCols[nI][nPosTES]	:= U_MEGAM020(aCols[nI][nPosProd],cTipoPed,cCodCli,cCodLoja,cTes)
		aCols[nI][nPosCF]   := U_GeraCFO(cCodCli, cCodLoja, aCols[nI][nPosTES])
	EndIf
Next nI

Return (lRet)

//M->UB_CF := TK273CFO(M->UA_CLIENTE, M->UA_LOJA, M->UB_TES)
//Tk273Calcula("UB_PRODUTO")


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MEGAM020  ºAutor  ³Microsiga           º Data ³  07/26/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Avalia se tem icms solidario                               º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
/*
User Function AvalSolid(cProduto,cTipoPed,cCodCli,cCodLoja)
Local lRet		    := .F. 
Local cTipCli   	:= ""
Local cGrpCli   	:= ""    // Grupo Trib do Cliente
Local cEstDst		:= "" 
Local _cEstado  	:= SuperGetMv("MV_ESTADO")
Local cIcmSol   	:= 0 
Local cGrpTrib		:= ""

If (cTipoPed $ SuperGetMV("MV_TPSOLCF"))

	dbSelectArea("SA1")
	dbsetorder(1)
	If dbSeek(xFilial("SA1")+cCodCli+cCodLoja)
		
		cTipCli    := SA1->A1_TIPO
		cGrpCli    := SA1->A1_GRPTRIB
		cEstDst	   := SA1->A1_EST
	
	EndIf
	
	dbSelectArea("SB1")
	dbsetorder(1)
	If dbSeek(xFilial("SB1")+cProduto)
		cIcmSol  := SB1->B1_PICMRET // Se o campo não estiver vazio e o grupo no cliente também não, então o icms pode ser Sol.
		cGrpTrib := SB1->B1_GRTRIB
	EndIf
	
	If Upper(Alltrim(cEstDst)) <> _cEstado
	
		If !Empty(cIcmSol)   // tem Percentual Margem de lucro
		  
			lRet:=.T.
		
		Else		
				
			If  ( !Empty(cGrpTrib) )   // Tem GrpTrib no Cadastro de Produto 
					
				dbSelectArea("SF7")
				dbSetOrder(1)
				dbSeek(xFilial("SF7")+ cGrpTrib + cGrpCli)
					
				While ( !Eof() .And.SF7->F7_FILIAL == xFilial("SF7") .And.;
						SF7->F7_GRTRIB == cGrpTrib .And. ;
						SF7->F7_GRPCLI == cGrpCli )
					If ( SF7->F7_EST == cEstDst .Or. SF7->F7_EST == "**") .AND. ;
						( cTipCli == SF7->F7_TIPOCLI .Or. SF7->F7_TIPOCLI == "*")		
                       	If ( !Empty(SF7->F7_MARGEM) )  // Tem margem de Lucro
                        		lret := .T.
                        EndIf	
                        Exit
      				EndIf
					dbSkip()
				EndDo
				
			EndIf	
		EndIf// Else
	EndIf// Fora do estado
EndIf // MV_TPSOLCF
Return(lRet)
*/

