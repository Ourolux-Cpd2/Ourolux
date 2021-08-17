/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³A175GRV   ºAutor  ³Microsiga           º Data ³  05/06/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Dispara o workflow depois da liberaçao do CQ               º±±
±±º          ³ Mata175													  º±±
±±º          ³ É chamado após a gravação de todos os dados                º±±
±±º          ³ (funcao FGRAVACQ), inclusive apos gerar a requisicao no    º±±
±±º          ³ arquivo de movimentos internos (SD3)                       º±±                         
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP10                                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function A175GRV()
/*
//Claudino - 08/11/17 - A diretoria solicitou para não enviar esse workflow.
Local nPosCod  		:= aScan(aHeader,{ |x| Upper(AllTrim(x[2])) == "D7_PRODUTO" }) // Produto
Local nPosLocal 	:= aScan(aHeader,{ |x| Upper(AllTrim(x[2])) == "D7_LOCAL" })   // Local atual
Local nPosNum 		:= aScan(aHeader,{ |x| Upper(AllTrim(x[2])) == "D7_NUMERO" })  // Numero Trans
Local nPosTipo 		:= aScan(aHeader,{ |x| Upper(AllTrim(x[2])) == "D7_TIPO" })    // Tipo de movimento
Local nPosLocDest	:= aScan(aHeader,{ |x| Upper(AllTrim(x[2])) == "D7_LOCDEST" }) // Local de destino 
Local nPosQtd	    := aScan(aHeader,{ |x| Upper(AllTrim(x[2])) == "D7_QTDE" }) 	 // Quantidade 
Local oHTML,cLista  := space(10),cGeren := "",cSuper:= ""
Local nCounter    	:= 0
Local cDesc 		:= ""
Local i				:= 0
Local _cEmails		:= GetMv("FS_WFRECEB")
//Local aNomeGrupo    := {'WFENTRADA','Vendas','Contas','Repres','Clientes'} 

oProcess:= TWFProcess():New("ENTREG","Chegaram os Produtos")
oProcess:NewTask("Inicio","\WORKFLOW\cq.htm")
oProcess:cSubject := "Recebimento de Materiais: "  + Alltrim(SM0->M0_NOME) + '/' +Alltrim(SM0->M0_FILIAL)

oHtml := oProcess:oHTML
oHTML:ValByName('DATA',dDataBase)

For i := 1 To Len(aCols)
	If (!aCols[i,len(aheader)+1]) .And. cA175OrigL == 'CP'   
		
		If Empty(aCols[i,nPosCod]) .And. Empty(aCols[i,nPosLocal])  .And.;
			aCols[i,nPosTipo] == 1 .And. aCols[i,nPosLocDest] == '01' 	 
			
			aAdd((oHTML:valByName('TB.Cod')), AllTrim(cA175Prod))
			cDesc := GetAdvFVal("SB1","B1_DESC",xFilial("SB1")+AllTrim(cA175Prod),1,"")
			aAdd( ( oHTML:valByName('TB.Desc')), cDesc)  
			aAdd( ( oHTML:valByName('TB.Doc')), SD7->D7_DOC)
			
			nCounter++
		EndIf
		
	EndIf
Next  

If nCounter != 0
   
   	oProcess:cBCc := U_gEmlVds()   
	If !Empty(oProcess:cBCc)
		oProcess:Start()
		oProcess:Finish()
	EndIf

EndIf

//Envio de WorkFlow para Diretoria

oProcess:= TWFProcess():New("ENTREG","Chegaram os Produtos")
oProcess:NewTask("Inicio","\WORKFLOW\cqGer.htm")
oProcess:cSubject := "Recebimento de Materiais: "  + Alltrim(SM0->M0_NOME) + '/' + Alltrim(SM0->M0_FILIAL)

oHtml := oProcess:oHTML
oHTML:ValByName('DATA',dDataBase)

For i := 1 To Len(aCols)

	If (!aCols[i,len(aheader)+1]) .And. cA175OrigL == 'CP'   
		
		If Empty(aCols[i,nPosCod]) .And. Empty(aCols[i,nPosLocal])  .And.;
			aCols[i,nPosTipo] == 1 .And. aCols[i,nPosLocDest] == '01' 

			DbSelectArea("SD1")
			DbSetOrder(1)
			DbSeek(xFilial("SD1")+SD7->D7_DOC+SD7->D7_SERIE)
          	
			DbSelectArea("SWV")
			DbSetOrder(1)
			DbSeek(xFilial("SWV")+SD1->D1_CONHEC)
			
			aAdd((oHTML:valByName('TB.Cod')), AllTrim(cA175Prod))
			cDesc := GetAdvFVal("SB1","B1_DESC",xFilial("SB1")+AllTrim(cA175Prod),1,"")
			aAdd( ( oHTML:valByName('TB.Desc')), cDesc )  
			aAdd( ( oHTML:valByName('TB.Doc')), SD7->D7_DOC )
			aAdd( ( oHTML:valByName('TB.Almox')), SD7->D7_LOCAL )			
			aAdd( ( oHTML:valByName('TB.Qtd')), aCols[i,nPosQtd] )
			aAdd( ( oHTML:valByName('TB.Lote')), SWV->WV_LOTE )				
			
			nCounter++

		EndIf
	EndIf
Next

If nCounter != 0
	oProcess:cBCc := 'roberto@ourolux.com.br;carlos@ourolux.com.br' + _cEmails 
	If !Empty(oProcess:cBCc)
		oProcess:Start()
		oProcess:Finish()
	EndIf
EndIf

DbCloseArea("SWV")
DbCloseArea("SD1")
*/
Return(Nil)