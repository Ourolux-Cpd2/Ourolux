#Include "rwmake.ch"
#Include "Tbiconn.ch" 
#Include "protheus.ch"

///*
//ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
//±±ºPrograma  ³Q215FIM   ºAutor  ³André Bagatini	   º Data ³ 21/09/11    º±±
//±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
//±±ºDesc.     ³Este ponto de entrada envia os dados "Cod.Produto / Revisão º±±
//±±º          ³produto / Cod.Fornecedor / Loja Fornecedor / Data Entrada / º±±
//±±º          ³Lote / Nr Nota / Serie NF / Item NF / Tipo NF e Opção do 	º±±
//±±º          ³Menu" referente à entrada / liberação do resultado após 	º±±
//±±º          ³efetivar a gravação do mesmo.								º±±
//±±º			cProd  := PARAMIXB[1]								        º±±
//±±º			cRevpr := PARAMIXB[2]								        º±±
//±±º			cForn  := PARAMIXB[3]								        º±±
//±±º			cLjFor := PARAMIXB[4]								        º±±
//±±º			cDtent := dtos(PARAMIXB[5])								    º±±
//±±º			cLote  := PARAMIXB[6]									    º±±
//±±º			cNtfis := PARAMIXB[7]								        º±±
//±±º			cSerNF := PARAMIXB[8]								        º±±
//±±º			cItNF  := PARAMIXB[9]								        º±±
//±±º			cTpNF  := PARAMIXB[10]								        º±±
//±±º			cOpc   := PARAMIXB[11]								        º±±
//±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
//±±ºUso       ³ Eletromega					                                º±±
//±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
//*/
User Function Q215FIM()
Local cDesc 		:= ''
Local cMotivo 		:= ''
Local aAreaQEL  	:= QEL->(GetArea())  

//If M->QEL_LAUDO $ 'C.E' 
If QEL->(DBSEEK(QEL->QEL_FILIAL+QEL->QEL_FORNEC+QEL->QEL_LOJFOR+QEL->QEL_PRODUT+QEL->QEL_NISERI+;
		        QEL->QEL_TIPONF+DTOS(QEL->QEL_DTENTR)+QEL->QEL_LOTE+SPACE(6)+SPACE(6))) // Primeiro registro no QEL
	
	If QEL->QEL_LAUDO == "C" 
	
		oProcess:= TWFProcess():New("Aceito","ProdutoAceito")
		oProcess:NewTask("Inicio","\WORKFLOW\Resultados.html")
		oProcess:cSubject := "PRODUTO ACEITO COM DESVIO: " + Alltrim(SM0->M0_NOME) + '/' + Alltrim(SM0->M0_FILIAL)
	
	ElseIf QEL->QEL_LAUDO == "E"
	
		oProcess:= TWFProcess():New("Rejeitado","ProdutoRejeitado")
		oProcess:NewTask("Inicio","\WORKFLOW\Resultados.html")
		oProcess:cSubject := "PRODUTO REJEITADO: " + Alltrim(SM0->M0_NOME) + '/' +Alltrim(SM0->M0_FILIAL)
	
	EndIf
	
	If QEL->QEL_LAUDO $ 'C.E'
	
		oHtml := oProcess:oHTML
	
		oHTML:ValByName('DATA',dDataBase)
   
		aAdd( oHTML:valByName( 'TB.Forn' ), 	PARAMIXB[3]+"/"+PARAMIXB[4] )
		aAdd( oHTML:valByName( 'TB.Data' ),		PARAMIXB[5] )
		aAdd( oHTML:valByName( 'TB.NF' ), 		PARAMIXB[7]+"/"+PARAMIXB[8] )
		
		cDesc := GetAdvFVal("SB1","B1_DESC",xFilial("SB1")+AllTrim(PARAMIXB[1]),1,"")
		
		aAdd( oHTML:valByName( 'P.Cod'  ), 		PARAMIXB[1] ) 
		aAdd( oHTML:valByName( 'P.Desc' ), 		cDesc )
		aAdd( oHTML:valByName( 'P.Lote' ),	 	PARAMIXB[6] )
		aAdd( oHTML:valByName( 'P.TamLote' ), 	M->QEK_TAMLOT )  
	
		cMotivo := QEL->QEL_JUSTLA
		cMotivo += CRLF
	
		If !Empty (QEL->QEL_CHAVEH)
			cMotivo += MSMM(QEL->QEL_CHAVEH)
		EndIf
		
		oHTML:ValByName('JustLab', cMotivo)
	
		oProcess:cBCc := U_GrpEmail('WFWREJIE')
        
        If QEL->QEL_LAUDO $ 'E'
        	oProcess:cBCc += ';ggc@ourolux.com.br' 
        EndIf
		
		oProcess:Start()
		oProcess:Finish()
    EndIf

EndIf

RestArea(aAreaQEL)
Return()