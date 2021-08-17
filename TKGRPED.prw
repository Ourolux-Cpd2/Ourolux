#Include "Protheus.ch"

User Function TKGRPED ( nLiquido, aParcelas,   ;
						cUA_OPER , cUA_NUM ,   ;
						cUA_CODLIG, cCodPagto, ;
						cOpFat , cCodTransp  )

Local aArea	   	 	:=	GetArea()
Local lRet 	   	 	:= .T.
Local nLiq   	 	:= 0
Local nValNFat 	 	:= 0
Local nLimite	 	:= 0
Local nRet		 	:= 0
Local nXa        	:= 0
Local nContaCFOP 	:= 0
Local nPosCFop   	:= 0
Local aCFOP      	:= {}
Local nPProd     	:= aScan(aHeader,{ |x| Upper(AllTrim(x[2])) == "UB_PRODUTO" })
Local nPQtd      	:= aScan(aHeader,{ |x| Upper(AllTrim(x[2])) == "UB_QUANT" })
Local nPosItem   	:= aScan(aHeader,{ |x| Upper(AllTrim(x[2])) == "UB_ITEM" })
Local nPosTes    	:= aScan(aHeader,{ |x| Upper(AllTrim(x[2])) == "UB_TES" })
Local nPosPrc    	:= aScan(aHeader,{ |x| Upper(AllTrim(x[2])) == "UB_VRUNIT" }) 
Local nPPrcTab    	:= aScan(aHeader,{ |x| Upper(AllTrim(x[2])) == "UB_PRCTAB" })
Local nPosCFOP      := ascan(aHeader, {|x| upper(AllTrim(x[2])) == "UB_CF" })
Local nSaldoSB2  	:= 0
Local aAreaSB2   	:= SB2->( GetArea() )
Local cSegmento  	:= GetAdvFVal("SA1","A1_SATIV1",xFilial("SA1")+M->(UA_CLIENTE+UA_LOJA),1,"")
Local nQtdVenSC6 	:= 0
Local cCodGrupo  	:= GetMV("FS_ELE004") // FS_ELE004 contains o codigo do grupo alttes
Local cRisco     	:= GetAdvFVal("SA1","A1_RISCO",xFilial("SA1")+M->(UA_CLIENTE+UA_LOJA),1,"") 
Local cEstado     	:= GetAdvFVal("SA1","A1_EST",xFilial("SA1")+M->(UA_CLIENTE+UA_LOJA),1,"")
Local cAviso     	:= ""
Local cXAviso     	:= ""
Local lMae  	 	:= U_getMae() == "S"//SuperGetMv("FS_MAE") == "S"
Local i				:= 0 // Counter
Local nDescMax      := 0
Local nPrcMin       := 0
Local nDescCP       := 0
Local nDscEsp       := 0
Local nDescTot      := 0
Local nVendNac      := 'N'
Local nLimite       := 0
Local cNumtrf       := ''
Local cNumf01       := ''
Local nVNossoc      := 600  // Valor minimo de pedido de Venda VENDA e de 600 reais para o NOSSO CARO
Local aDscEsp       := {}

If lTK271Auto 
	RestArea(aArea) 
	RestArea(aAreaSB2)
	Return .T.
EndIf

// Claudino - 10/12/15 - Comentei
//If ( lRet .AND. Empty (cCodPagto) )
//	lRet := .F.
//	ApMsgInfo("Favor informar a transportadora!","TKGRVPED")
//EndIf

// Claudino - 10/12/15
**********************************************************
If cFilAnt == '01' // Claudino - I1611-915 - 11/11/16
	If !Empty(cCodTransp)
		If cNivel < 3
			lRet := .F.
			ApMsgInfo("Favor não digitar a transportadora!","TKGRPED")
		Else
			//If Upper(UsrRetName(__cUserId)) $ GetMv("FS_RETIRA") .AND. cCodTransp <> "99    "
			If Upper(cUserName) $ GetMv("FS_RETIRA") .AND. cCodTransp <> "99    "
				lRet := .F. 
				ApMsgStop("O Depto Comercial só pode digitar a transportadora RETIRA!","TKGRPED")
			EndIf
		EndIf
	EndIf
EndIf
**********************************************************
// Claudino - 10/12/15

// Claudino - 18/03/16 - I1603-007
// Limite valor total de mercadoria 
**********************************************************
If M->UA_CLIENTE <> '008360' .And. M->UA_CONDPG <> 'BON' .And. lRet .And. !U_IsAdm()
    If xFilial("SUA") == "01"
	    // 10-08-2018 WAR Chamado I1808-1041
	    If M->UA_TABELA $ 'S56' .And. cEstado == 'SP'
	      	If aValores[1] < 400   
				lRet := .F. 
				ApMsgStop("Valor total de mercadoria menor que o limite do estado!","TKGRPED")
			EndIf
	    ElseIf M->UA_TABELA $ 'S56.F56' 
	       	If aValores[1] < 600   
				lRet := .F. 
				ApMsgStop("Valor total de mercadoria menor que o limite do estado!","TKGRPED")
			EndIf
        // 10-08-2018 WAR Chamado I1808-1041
	    // If M->UA_TABELA $ GetMv("FS_LIMITAB")  // 10-08-2018 WAR Chamado I1808-1041
	    ElseIf M->UA_TABELA $ GetMv("FS_LIMITAB") // Parametro tabelas com limite especial
	    	If aValores[1] < GetMv("FS_LIMPVTB")  // Parametro com limite especial das tabelas (1º LIMITE R$500,00)
		    	lRet := .F. 
				ApMsgStop("Valor total de mercadoria menor que o limite da tabela!","TKGRPED")
			EndIf
		Else	
			If cEstado == 'SP'
				If aValores[1] < GetMv("FS_LIMPVSP") // Parametro limite valor total de mercadoria SP 
					lRet := .F. 
					ApMsgStop("Valor total de mercadoria menor que o limite do estado!","TKGRPED")
				EndIf
			// Claudino - 14/02/17 - I1702-632
			ElseIf cEstado == 'PE'
				If aValores[1] < GetMv("FS_LIMPVPE") // Parametro limite valor total de mercadoria PE 
					lRet := .F. 
					ApMsgStop("Valor total de mercadoria menor que o limite do estado!","TKGRPED")
				EndIf 
			
			ElseIf cEstado == 'RJ' //war 18/12/2019
				
				If aValores[1] < GetMv("FS_LIMPVRJ") // Parametro limite valor total de mercadoria PE 
					lRet := .F. 
					ApMsgStop("Valor total de mercadoria menor que o limite do estado RJ!","TKGRPED")
				EndIf 
				
			Else
				If aValores[1] < GetMv("FS_LIMPVXX") // Parametro limite valor total de mercadoria demais estados
					lRet := .F. 
					ApMsgStop("Valor total de mercadoria menor que o limite do estado!","TKGRPED")
				EndIf
			EndIf
		EndIf
	EndIf
EndIf
**********************************************************
// Claudino - 18/03/16 - I1603-007

If ( lRet .AND. (cCodPagto == 'XXX') )
	lRet := .F.
	ApMsgInfo("Favor informar uma outra Cond de Pag!","TKGRVPED")
EndIf

// Claudino - 10/12/15 - Comentei
//If ( lRet .AND. Empty (cCodTransp) )
//	lRet := .F.
//	ApMsgInfo("Favor informar uma transportadora! ","TKGRVPED")
//EndIf

// Claudino - 10/12/15 - Comentei
//If (lRet  .AND. (cCodTransp == '000000'))
//	lRet := .F.
//	ApMsgInfo("Favor informar uma outra transportadora!","TKGRVPED")
//EndIf

If ALTERA .And. lRet .And. SUA->UA_OPER == '1' // Faturamento 
	
	If SUA->UA_STATUS == "LIB" //NF. = NOTA FATURADA
	
		lRet := .F.
		ApMsgStop("Nao e permitido a alteraçao de pedidos ja liberados!","TKGRVPED")

	EndIf

EndIf

If ALTERA .And. lRet .And. SUA->UA_OPER == '1' .And. lRet// Nao pode alterar pedidos ja separados -- mae 
	
	If MsSeek(xFilial("SC5")+SUA->UA_NUMSC5)
		If (AllTrim(SC5->C5_OK) == 'S') .And. lMae 
			lRet := .F.
			ApMsgInfo("Pedido aguardando faturamento: PEDIDO MAE!","TKGRVPED")
    	EndIf
	EndIf

EndIf

If (INCLUI .Or. ALTERA) .And. lRet
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Cliente com risco E e bloqueado    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If cRisco == 'E'
		lRet := .F.
		ApMsgStop("Cliente com risco E","TKGRPED")
	EndIf
EndIf

If (INCLUI .Or. ALTERA) .And. lRet
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Recalcula as parcelas³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nLiq    	:= aValores[6] 		  // Total da venda, definido no TMKDEF.CH
	//nLiq    	:= aValores[1]        // Valor Mercadoria
	//nValNFat	:= Tk273NFatura()     // Calcula o Valor Nao Faturado
	//nLiq    	-= nValNFat
	
	If !IsBonif()  
		
		//If !(U_IsAdm() .OR. U_IsFreeCondPgt())
		
			//nLimite := GetAdvFVal("SE4","E4_INFER",xFilial("SE4")+M->UA_CONDPG,1,-1)
		    
		    // Claudino - 10/12/15 - Comentei
		    /*
		    If cCodTransp == '900000' .And. cNumEmp == '0101'
		    
		    	If nLiquido < nVNossoc
		    	
		    		lRet := .F.
					ApMsgInfo("O valor da venda é inferior ao limite imposto para o NOSSO CARRO (R$ " +;
					AllTrim(Transform(nVNossoc,"@E 999.99"))+ ").","Nosso Carro")
		    	
		    	EndIf
		    
		    ElseIf cCodTransp == '001717' .And. cNumEmp == '0102'
		    
		    	If nLiquido < nVNossoc
		    	
		    		lRet := .F.
					ApMsgInfo("O valor da venda é inferior ao limite imposto para a transportadora (R$ " +;
					AllTrim(Transform(nVNossoc,"@E 999.99"))+ ").","Transportadora")
		    	
		    	EndIf

		    ElseIf nLiquido < nLimite  
		    */
		    /*
		    If nLiquido < nLimite  
		    	
		    	If nLimite < 0
		    		lRet := .F.
					ApMsgInfo("Condição de pagamento não permitida!","Cond. de Pagamento")
		    	Else 
		        	lRet := .F.
					ApMsgInfo("O valor da venda é inferior ao limite imposto pela condição de pagamento selecionada(R$ " +;
					AllTrim(Transform(nLimite,"@E 999,999,999.99"))+ ")." + CRLF +	"Utilize outra condição","Cond. de Pagamento")			
		        EndIf
		    
		    EndIf
		    */
		//EndIf	
   	  	
   		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Validate Cliente p/ Bloqueio       ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
 		U_VldCli(M->UA_CLIENTE,M->UA_LOJA,@cAviso)
		M->UA_AVISO := cAviso

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄI
		//³Gerar o Campo C5_XAVISO - Analise Risk Rating   ³
		//³Gilson Belini - 08/04/2017                      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄI
 		U_VldRR(M->UA_CLIENTE,M->UA_LOJA,@cXAviso)
		M->UA_XAVISO := cXAviso // Corrigido por Gilson Belini em 19/04/2018.

	EndIf

EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄI
//³Gera TES e CFOP PARA TODOS OS ITEMS DO PEDIDO   ³
//³ WAR 10-11-2006                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄI
// Chamado: I1803-3178 - Atendimento realizado pelo Claudino em 27/03/2018
// Maurício Aureliano - 27/03/2018 - U_ValidCFO()
// Verificacao de CFO com relação ao TES informado.

If lRet
	lRet := U_ValidCFO()
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄI
//³Gera TES e CFOP PARA TODOS OS ITEMS DO PEDIDO   ³
//³ WAR 10-11-2006                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄI
/* nfe 27-05-2010
If lRet .AND.  !U_VLDUSGRP(cCodGrupo)    
	U_GeraTESCF()
EndIf


// Verificacao de CFO se existe mais de 2 diferente, retorna falso.
If lRet
	lRet := U_VerQtdCFO()
EndIf
*/
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica o saldo do item se for um faturamento          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lRet	.AND. M->UA_OPER == '1' // Faturamento

	SB2->( dbSetOrder( 1 ) )

	For i := 1 to Len(aCols) 
	
		If !aCols[i][Len(aHeader)+1]
			
			If (SB2->( dbSeek( xFilial( 'SB2' ) + aCols[i][nPProd] + GetMV('EX_ALXPDB',,'01') ) )) 
			 
				nSaldoSB2 := SaldoSB2(.F.,.T.,,.F.,.F.,,,,.T.) - ABS( SB2->B2_QPEDVEN )
				
				If (ALTERA)
					
					If SUB->( dbSeek( xFilial( 'SUB' ) + cUA_NUM + aCols[i][nPosItem] + aCols[i][nPProd]))
						
						If ! Empty (SUB->UB_NUMPV)	  
							nQtdVenSC6 := GetAdvFVal("SC6","C6_QTDVEN",xFilial("SC6")+SUB->UB_PRODUTO+SUB->UB_NUMPV,2,0)
							nSaldoSB2 += nQtdVenSC6  
						EndIf
					
					EndIf		
				
				EndIf
    			
				If aCols[i][nPQtd] > nSaldoSB2  .And. !U_IsAdm()// Nao tem Saldo
				
					If AvalTes(aCols[ i ][ nPosTes ],"S","SN") // If TES movimenta o estoque "S"		
						
						lRet := .F.
						ApMsgStop( 'Não existe saldo suficiente para este produto ' + Alltrim( aCols[i][nPProd] )+ ' ( ' +  Alltrim( Transform(nSaldoSB2,'@E 999,999,999.99') ) + ' )', 'TKGRPED' )
						Exit
					
					EndIf
				
				EndIf
			Else
				
				lRet := .F.
				ApMsgStop( 'Produto ' + Alltrim( aCols[i][nPProd] )+ ' sem saldo!', 'TKGRPED' )
				Exit

			EndIf 
			
		EndIf
	Next
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Nao deixa tirar pedido para o cliente padrao para orçamento    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If (lRet	.AND. M->UA_OPER == '1' .AND. M->UA_CLIENTE == '000000')
	lRet := .F.
	ApMsgStop( 'Não pode cadastrar pedidos para o cliente ' + Alltrim( M->UA_CLIENTE ), 'ATENÇÃO' )
EndIf 

If lRet .AND. Empty(cSegmento)
	lRet := .F.
	ApMsgInfo("Cliente sem Segmento.","Segmento Vazio")
EndIf

/*  Validate os preços digitados */
/*  Removido : Rgras de negocios   
If lRet .And. !U_IsAdm() 
	For i := 1 to Len(aCols) 
		If !aCols[i][Len(aHeader)+1]
			If !(lRet := U_ValidVal(M->UA_TABELA,"N",aCols[i][nPProd],aCols[i][nPosPrc]))
				Exit
			EndIf
		EndIf		
	Next
EndIf
*/
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Validate se produto pode ser vendido fora da embalagem  ³
//³ WAR                                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If lRet
    For i := 1 to Len(aCols)
    	If !(lRet := U_VerEmb(i))
    		Exit
    	EndIf
    Next
EndIf  

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifque se o produto digitado        ³
//³ pertence a tabela de preço            ³
//³ WAR 04-01-2009                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If (INCLUI .Or. ALTERA) .And. lRet

	For i := 1 to Len(aCols) 
		If !aCols[i][Len(aHeader)+1]
			If !(lRet := U_PrdInTab(aCols[i][nPProd],M->UA_TABELA))
				Exit
			EndIf
		EndIf		
	Next

EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Tratamento do UB_PRCTAB               ³
//³ 							          ³
//³ WAR 08-07-2009                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
/* Rgras de negocios
If (INCLUI .Or. ALTERA) .And. lRet

	For i := 1 to Len(aCols) 
		If !aCols[i][Len(aHeader)+1]
			aCols[i][nPPrcTab] := aCols[i][nPosPrc]
		EndIf		
	Next

EndIf
*/

// Claudino - 10/12/15 - Comentei
//If lRet //.And. (!U_IsAdm())
//	lRet := !(cCodTransp $ '99     ')
//	If !lRet
//		ApMsgStop( 'Nao pode usar transportadora ' + cCodTransp , 'TKGRPED' )
//	EndIf
//EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifque se o preco digitado e menor  ³
//³ do preco minimo - B1_PR500X           ³
//³ WAR 05-11-2012                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If (INCLUI .Or. ALTERA) .And. lRet
	
	nDescMax := GetAdvFVal("DA0","DA0_XDESC",xFilial("DA0")+AllTrim(M->UA_TABELA),1,0)
	nDescCP  := GetAdvFVal("SE4","E4_XDESC",xFilial("SE4")+AllTrim(M->UA_CONDPG),1,0)
	aDscEsp  := GetAdvFVal("SA1",{"A1_XDSCESP","A1_XDTDSCE"},xFilial("SA1")+M->(UA_CLIENTE+UA_LOJA),1,{"",""}) 
	
	If aDscEsp[1] > 0 .And. Dtos(aDscEsp[2]) == Dtos(dDataBase) .And. !Empty(Dtos(aDscEsp[2])) 
	
		nDescTot := aDscEsp[1] 	
	
	EndIf
	
	nDescTot += nDescMax + nDescCP  
		
	For i := 1 to Len(aCols)
 
 		If !aCols[i][Len(aHeader)+1]
	
			nPrcMin := IIf(nDescTot > 0, Round(aCols[i][nPPrcTab] - aCols[i][nPPrcTab] * (nDescTot/100),2), aCols[i][nPosPrc])	    
			
			If Round(aCols[i][nPosPrc],2) < nPrcMin //Round(nPrcMin,2) 
				lRet := .F.
				ApMsgStop("Preço informado para o produto " + Alltrim(aCols[i][nPProd])+ " é menor que o valor mínimo: (R$ " + ALLTRIM (STR(Round(nPrcMin,2 ))) + ").")
				Exit
			EndIf

        EndIf
	
	Next

EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifque se o preco digitado e menor  ³
//³ do preco minimo - B1_PR500X           ³
//³ WAR 05-11-2012                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
/*
If (INCLUI .Or. ALTERA) .And. lRet
	
	For i := 1 to Len(aCols)
 
 		If !aCols[i][Len(aHeader)+1]
	
			nPrcMin := GetAdvFVal("SB1","B1_PR500X",xFilial("SB1")+AllTrim(aCols[i][nPProd]),1,0)
    
			If aCols[i][nPosPrc] < nPrcMin
				lRet := .F.
				ApMsgStop("Preço informado para o produto " + Alltrim(aCols[i][nPProd])+ " é menor que o valor mínimo: (R$ " + ALLTRIM (STR(NoRound(nPrcMin,4 ))) + ").")
				Exit
			EndIf

        EndIf
	
	Next

EndIf
*/

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Vendas de Filial 1 nao e probida      ³
//³  ua_vend                              ³
//³ WAR 03-12-2012                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

nVendNac := GetAdvFVal("SA3","A3_XVNDNAC",xFilial("SA3")+AllTrim(M->UA_VEND),1,'N')

If (INCLUI .Or. ALTERA) .And. lRet .And. nVendNac == 'N' .And. !U_IsAdm() 
	
	/*
	If cNumEmp == '0101' .And. cEstado == 'MG' // Empresa = 01 e Filial = 01
		lRet := .F. 
		ApMsgStop( 'Venda para ' + cEstado + ' e probibida!', 'TKGRPED' )
	EndIf
	*/
	
	/*  28/98/2018 I1809-2085
	
	If cNumEmp <> '0101' .And. cEstado == 'MA' // Empresa = 01 e Filial = 01
		lRet := .F. 
		ApMsgStop( 'Venda para ' + cEstado + ' e probibida!', 'TKGRPED' )
	EndIf
	
	*/ 
	// 28/98/2018 I1809-2085
	
	If cNumEmp == '0102' .And. cEstado == 'PI'  // Empresa = 01 e Filial = 02
		lRet := .F. 
		ApMsgStop( 'Venda para ' + cEstado + ' e probibida!', 'TKGRPED' )
	EndIf

EndIf

If (ALTERA) .And. lRet 

	cNumtrf := GetAdvFVal("SUA","UA_XNUMTRF",xFilial("SUA")+cUA_NUM,1,'') 
	cNumf01 := GetAdvFVal("SUA","UA_XNUMF01",xFilial("SUA")+cUA_NUM,1,'')

EndIf

/*

If (ALTERA) .And. lRet .And. !Empty(cNumtrf) .And. cFilAnt == "01"

	If !U_IsAdm()
		lRet := .F.
		ApMsgStop( 'Atendimento nao pode ser alterado. Integraçao filial RJ.', 'TKGRPED' )
	EndIf

EndIf

*/

If (ALTERA) .And. lRet .And. !Empty(cNumf01) .And. cFilAnt == "04"

	//If !(Upper(Rtrim(cUserName)) $ 'ADV.ADMINISTRADOR.ASSISTENTE8')
	If !(AllTrim(__cUserId) $ GetMv("FS_FATRJ")) // Maurício Aureliano - 14/06/2018
		
		lRet := .F.
		ApMsgStop( 'Atendimento nao pode ser alterado. Integraçao filial GRU.', 'TKGRPED' )
	
	//Else
	
	//	ApMsgStop( 'Favor solicitar a alteraçao de pedido de transferencia para a logistica GRU no caso de alteraçao de QTD!', 'TKGRPED' )
	
	EndIf

EndIf

If (INCLUI .Or. ALTERA) .And. lRet
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Valor de frete                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If aValores[4] <> 0
		lRet := .F.
		ApMsgStop('Favor limpar o valor do frete!','TKGRPED')
	EndIf

EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica o saldo do item se for um faturamento          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lRet	.AND. M->UA_OPER == '1' // Faturamento

	If ALTERA .Or. INCLUI
	
		If IsBonif() .And. cCodPagto != 'BON'   
			
			lRet := .F.
			ApMsgStop('Favor utilizar a condicao BON para pedidos de bonificaçoes', 'TKGRPED')
							
		EndIf 
	
	EndIf

EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Bloquear vendas SC -> SC              ³
//³ Regime Novo                           ³
//³ WAR 31-05-2019                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If (INCLUI .Or. ALTERA) .And. lRet

    If cNumEmp == '0106' .And. cEstado == 'SC'  
		lRet := .F. 
		ApMsgStop( 'Venda para ' + cEstado + ' e probibida!', 'TKGRPED' )
	EndIf
	
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Tratar UA_OBS                         ³
//³ SEFAZ                                 ³
//³ WAR 21-06-2019                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If lRet
	M->UA_OBS := Tk03Obs(UA_OBS)
EndIf

RestArea(aArea)       
RestArea(aAreaSB2)

Return (lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Tk273NFatura ºAutor  ³Andrea Farias       º Data ³  05/05/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Retorna o total do Valor Nao Faturado desse atendimento        º±±
±±º          ³baseado nas linhas validas e com o TES preenchido              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³TELEVENDAS                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function Tk273NFatura()

Local aArea		:= GetArea()        		// Guarda a area anterior
Local nI		:= 0                 		// Controle de loop       
Local nValor  	:= 0                     	// Valor Nao Faturado
Local nPTes		:= aScan(aHeader,{ |x| Upper(AllTrim(x[2])) == "UB_TES" }) 
Local nPVlrItem	:= aScan(aHeader,{ |x| Upper(AllTrim(x[2])) == "UB_VLRITEM" })
Local nValIpi	:= 0                       	// Valor do IPI para o Item

For nI:=1 TO Len(aCols)
	If !aCols[nI][Len(aHeader)+1] .And. !Empty(aCols[nI][nPTes])
		Dbselectarea("SF4")
		DbsetOrder(1)
		If MsSeek(xFilial("SF4")+aCols[nI][nPTes])
			If SF4->F4_DUPLIC == "N" //Nao Gera Duplicata
				//Considera o valor de IPI pois faz parte do valor total da nota.
				nValIpi := MaFisRet(nI,'IT_VALIPI')
				nValor  += aCols[nI][nPVlrItem]+nValIpi
			EndIf
		EndIf
	EndIf
Next nI

RestArea(aArea)
Return(nValor) 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³VerQtdCFO ºAutor  ³Eletromega             º Data ³  05/05/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Nao pode ter mais de dois codigos fiscais num pedido de venda  º±±
±±º          ³baseado nas linhas validas e com o TES preenchido              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³TELEVENDAS/Faturamento                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/                                                                             
User Function VerQtdCFO()
Local lRet 		:= .T.
Local nPosCFOP  := 0 
Local aCFOP     := {}  	 

If IsInCallStack("TMKA271") 
	nPosCFOP := ascan(aHeader, {|x| upper(AllTrim(x[2])) == "UB_CF" })
ElseIf IsInCallStack("MATA410") 
	nPosCFOP := ascan(aHeader, {|x| upper(AllTrim(x[2])) == "C6_CF" })
EndIf 

If !Empty(nPosCFOP)
	For nXa := 1 to len(aCols)
		If ascan(aCFOP, {|x| Alltrim(upper(aCols[nXa][nPosCFOP])) == x }) == 0 .and. !aCols[nXa][len(aHeader)+1]
			aadd(aCFOP, Alltrim(upper(aCols[nXa][nPosCFOP])))
		EndIf
		next nXa
		nContaCFOP := len(aCFOP)
		If nContaCFOP > 2
			lRet := .F.
			APMsgAlert("Foram utilizados mais do que dois Codigos de Operações Fiscais distintos neste pedido, o maximo permitido são dois. Divida em dois pedidos respeitando o limite de no maximo dois codigos de operaçoes fiscais por pedido!","TKGRPED")
		EndIf
EndIf

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ ºAutor  ³Eletromega             º Data ³  05/05/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Mostra os avisos da Condiçao de pagamento                      º±±
±±º          ³                                                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³TELEVENDAS/Faturamento                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function AvisoCP(nLimite,nRet)
Local lRet := .T.

If  nRet == 1 
    lRet := .F.
	ApMsgInfo("Condição de pagamento não permitida! Utilize a condiçao da Tabela do preço.","Cond. de Pagamento")
ElseIf nRet == 2
	lRet := .F.
	ApMsgInfo("Condição de pagamento não permitida! Utilize a condiçao do cliente.","Cond. de Pagamento")
ElseIf nRet == 3
	lRet := .F.
	ApMsgInfo("O valor da venda é inferior ao limite imposto pela condição de pagamento selecionada(R$" +;
	AllTrim(Transform(nLimite,"@E 999,999,999.99"))+ ")." + CRLF +	"Utilize outra condição","Cond. de Pagamento")			
ElseIf nRet == 4
	lRet := .F.
	ApMsgInfo("O valor de venda é inferior ao limite imposto para este cliente(R$" +;
	AllTrim(Transform(nLimite,"@E 999,999,999.99"))+ ").", "Cond. de Pagamento")
ElseIf nRet == 5
	lRet := .F.
	ApMsgInfo("O valor de venda é inferior ao limite imposto pela condição de pagamento selecionada(R$" +;
	AllTrim(Transform(nLimite,"@E 999,999,999.99"))+ ").", "Cond. de Pagamento")
ElseIf nRet == 6
	lRet := .F.
	ApMsgInfo("Condição de pagamento não permitida para este usuario!","Cond. de Pagamento")
Else
	lRet := .F.
	ApMsgInfo("Condição de pagamento não permitida!","Cond. de Pagamento")
EndIf

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ ºAutor  ³Eletromega             º Data ³  17/05/12            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Verifique se o pedido e de bonificaçao                         º±±
±±º          ³                                                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³TELEVENDAS                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function IsBonif()

Local aArea		:= GetArea()        		// Guarda a area anterior
Local nPCfop	:= aScan(aHeader,{ |x| Upper(AllTrim(x[2])) == "UB_CF" })
Local nItens    := 0 // total dos itens no pedido 
Local nCF910    := 0 // total dos itens c/ CF 910

For nI:=1 TO Len(aCols)
	If !aCols[nI][Len(aHeader)+1] 
		++nItens
		If (Substr(aCols[nI][nPCfop], 2, 3 ) $ '910')
        	++nCF910	
        EndIf
    EndIf     
Next nI

RestArea(aArea)

Return(nItens == nCF910)                                                    	


/*/{Protheus.doc} ValidCfo
Valida inconsistência gerada pelo sistema para TES de Saída que
gera CFOP de entrada.                                          

@author Maurício O. Aureliano
@since 27/03/2018

@obs	Chamado: I1712-1338

@return	Nil		Sem Retorno.
/*/                                                                           
User Function ValidCFO()

Local lRet 		:= .T.
Local nPosTes	:= 0 
Local nPosCf  	:= 0
Local aCFOP     := {}  	 

If IsInCallStack("TMKA271") 
	nPosTes	:= ascan(aHeader, {|x| upper(AllTrim(x[2])) == "UB_TES" })
	nPosCf	:= ascan(aHeader, {|x| upper(AllTrim(x[2])) == "UB_CF"  })
ElseIf IsInCallStack("MATA410") 
	nPosTes	:= ascan(aHeader, {|x| upper(AllTrim(x[2])) == "C6_TES" })
	nPosCf	:= ascan(aHeader, {|x| upper(AllTrim(x[2])) == "C6_CF"  })
EndIf 

If !Empty(nPosCf)
	If Substr(AllTrim(aCols[N][nPosTes]),1,1) >= "5"
		If Substr(AllTrim(aCols[N][nPosCf]),1,1) < "5"
			MsgAlert("CFOP gerado não condiz com operação de Saída. Favor verificar!")
			lRet := .F.
		EndIf
	Else
		If Substr(AllTrim(aCols[N][nPosCf]),1,1) >= "5"
			MsgAlert("CFOP gerado não condiz com operação de Entrada. Favor verificar!")
			lRet := .F.
		EndIf		
	EndIf
EndIf

Return(lRet)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Tk03Obs   ºAutor  ³Armando M. Tessaroliº Data ³  04/06/2019 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Monta o texto conforme foi digitado pelo operador e quebra  º±±
±±º          ³as linhas no tamanho especificado sem cortar palavras e     º±±
±±º          ³devolve um array com os textos a serem impressos.           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ cCodigo - Codigo de referencia da gravacao do memo         º±±
±±º          ³ nTaM    - Tamanho maximo de colunas do texto               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Call Center                                                º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Tk03Obs(cString)

Local nI		:= 0    					// Contador dos caracteres	
Local cTmpStr	:= ""						// Campo memo

For nI := 1 TO Len(cString)
	
	//If (MsAscii(SubStr(cString,nI,1)) <> 13)  
	If !AllTrim(Str(MsAscii(SubStr(cString,nI,1)) ) ) $ "10/13/62/60/38/34/39" //10 e 13 (ENTER) 38(&) 34(") 39(') 62(>) 60(<) 
	
		cTmpStr+=SubStr(cString,nI,1)
		
	EndIf
	
	If MsAscii(SubStr(cString,nI,1)) = 10 //Substituir o ENTER por espaco em branco
	
		cTmpStr+= Space(01)
		
	EndIf

Next nI

Return(cTmpStr)