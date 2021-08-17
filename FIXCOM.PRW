#Include "rwmake.ch"

USER FUNCTION FIXCOM()

cCodVend := space (6)
DtPag    := Ctod( Space( 08 ) )

@ 56,42 TO 323,505 DIALOG oDlgComis TITLE "Acerta comissao"
@ 8,10 TO 84,222
@ 15,24 Say 'Codigo de vendedor'
@ 25,24 Get cCodVend Picture "@!" Valid .T. F3 "SA3" Size 35,8
@ 40,24 Say 'Data de Pag. da comis'
@ 50,24 Get DtPag Picture '@R 99/99/99' Size 35,8
@ 91,160 BMPBUTTON TYPE 1 ACTION Processa( {|lEnd| Grava() }, 'Aguarde...' )
@ 91,190 BMPBUTTON TYPE 2 ACTION Close(oDlgComis)
@ 110,20 Say 'Acertar as comissoes dos vendedores cadastrados para nao pagar comissao '
@ 120,20 Say 'sobre o Valor de ICMS!'

ACTIVATE DIALOG oDlgComis CENTERED

Return(NIL)

Static Function Grava()

Local aAreaSE3   	:= GetArea("SE3")
Local aAreaSE1   	:= GetArea("SE1") 
Local aAreaSF2   	:= GetArea("SF2")
Local cVend 	    := cCodVend
Local dDtPag    	:= DtPag 
Local nParcela  	:= 0
Local nCount 		:= 0
Local nDesconto 	:= 0  
Local nValLiq   	:= 0
Local nValor    	:= 0
Local nValE5    	:= 0
Local nBase         := 0
Local dDtEmiss      := ""
Local cBaiEmi       := ""

Local cCliente,cLoja,cDoc,cSerie,cTipo,cParcela, cCodCli, cLoja
 

If Empty (cCodVend) .OR. Empty (DtPag)
   
	RestArea(aAreaSE3) 
	RestArea(aAreaSE1)
	RestArea(aAreaSF2)
	
	Return (NIL)

EndIf

dbSelectArea("SE3")
dbSetOrder(2)  // 2 E3_FILIAL, E3_VEND, E3_PREFIXO, E3_NUM, E3_PARCELA, E3_SEQ
dbGotop()      // 1 E3_FILIAL, E3_PREFIXO, E3_NUM, E3_PARCELA, E3_SEQ, E3_VEND

MsSeek(xFilial("SE3")+ cVend )

While ( !EOF().AND. cVend == SE3->E3_VEND )  
	
	If ( SE3->E3_DATA == dDtPag .AND. SE3->E3_SERIE == '1  ' )
		
		cCliente	:= SE3->E3_CODCLI 
		cLoja   	:= SE3->E3_LOJA
		cDoc    	:= SE3->E3_NUM
		cSerie  	:= SE3->E3_SERIE
		cTipo   	:= SE3->E3_TIPO
		cParcela    := SE3->E3_PARCELA
		cCodCli     := SE3->E3_CODCLI
		dDtComiss   := SE3->E3_EMISSAO // DATA EMISSAO DA COMISSAO
		cBaiEmi     := SE3->E3_BAIEMI
			
			
        //1  E1_FILIAL, E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO

		dbSelectArea("SE1")
		dbSetOrder(1)
			
		MsSeek(xFilial("SE1")+ cSerie + cDoc + cParcela + cTipo)
			
		nValor := SE1->E1_VALOR
		
		dbGoTop()
		MsSeek(xFilial("SE1")+ cSerie + cDoc )
		
		nParcela := 0
				
		While !EOF() .AND. ( E1_PREFIXO == cSerie .AND. ;
                             E1_NUM     == cDoc )       
			
			If ( cTipo == E1_TIPO)    
				
				nParcela++
			
			EndIf
			
			dbskip()
		 
		EndDo    			    		        
					
		// 7 E5_FILIAL, E5_PREFIXO, E5_NUMERO, E5_PARCELA, E5_TIPO, E5_CLIFOR, E5_LOJA, E5_SEQ

		nValE5 := 0
		nBase  := 0
		
		If (cBaiEmi =='B')
		
		
		dbSelectArea("SE5")
		dbSetOrder(7)
		
		MsSeek(xFilial("SE5")+ cSerie + cDoc + cParcela + cTipo + cCodCli + cLoja )
		
		While !EOF() .AND. (E5_PREFIXO == cSerie .AND. ;
                E5_NUMERO     == cDoc   .AND.  E5_TIPO    == cTipo  .AND. ;
                E5_PARCELA == cParcela .AND.  E5_CLIFOR  == cCodCli  .AND. E5_LOJA == cLoja)       
			    
			//If E5_RECPAG == 'R'
		    	
				If (E5_TIPODOC $ 'BA.CH.VL')
		    	
		    		If (E5_MOTBX $ 'NOR.CHQ.COB.DEP.DIN.CHK.CHD')
		    		
		    			If (E5_DATA <= dDtComiss)
		    				
		    				nValE5 += E5_VALOR - E5_VLJUROS
		    				    			    		
		    				nSeq := E5_SEQ
		    			
		    			EndIf
		    		
		    		EndIf
		    			
		    	ElseIf (E5_TIPODOC $ 'ES') .AND. (nSeq == E5_SEQ)
		    		
		    	  	 If (E5_MOTBX $ 'NOR.CHQ.COB.DEP.DIN.CHK.CHD')
		    	  		
		    	  		If (E5_DATA <= dDtComiss) 
		    	  		
		    	  			nValE5 -= E5_VALOR - E5_VLJUROS
		    	  		
		    	  		EndIf
		    	  	 
		    	  	 EndIf
		    	
		    	EndIf	
		   		    	
			//EndIf
		    			    		        
		    dbSkip()   
			    
		EndDo
		
		EndIf
		
		dbSelectArea("SF2")
		dbSetOrder(2)//2 F2_FILIAL, F2_CLIENTE, F2_LOJA, F2_DOC, F2_SERIE
		dbGotop()
				
		If MsSeek(xFilial("SF2")+ cCliente + cLoja + cDoc + cSerie)
			
			// Calculate BASE de Comissao	
			If cBaiEmi == 'B'
				
				nBase := (SF2->F2_VALMERC/nParcela) *(nValE5/nValor) 
			
			ElseIf cBaiEmi == 'E'	
		    
		    	nBase := SF2->F2_VALMERC
		    
		    EndIf
		
		EndIf
		
		dbSelectArea("SE3")
		
		RecLock( "SE3", .F. )
		
		SE3->E3_BASE := nBase
		
		SE3->E3_COMIS := ROUND( ( SE3->E3_BASE * SE3->E3_PORC ) /100,2 )
		
		MsUnlock()
		
		nCount++
		
		nParcela := 0 
		
	EndIf // E3_DATA
		
dbSkip()
		
EndDo  // SE3  

ApMsgStop( 'Registros processados: ' +  Transform(nCount,'@E 999,999,999'), 'Vend. ' + cVend )	
	
RestArea(aAreaSE3) 
RestArea(aAreaSE1)
RestArea(aAreaSF2)

Return(NIL)
	
	