#Include "rwmake.ch"
#Include "Tbiconn.ch" 
#Include "protheus.ch"

///*
//�����������������������������������������������������������������������������
//�����������������������������������������������������������������������������
//�������������������������������������������������������������������������ͻ��
//���Programa  �Q215FIM   �Autor  �Andr� Bagatini	   � Data � 21/09/11    ���
//�������������������������������������������������������������������������͹��
//���Desc.     �Este ponto de entrada envia os dados "Cod.Produto / Revis�o ���
//���          �produto / Cod.Fornecedor / Loja Fornecedor / Data Entrada / ���
//���          �Lote / Nr Nota / Serie NF / Item NF / Tipo NF e Op��o do 	���
//���          �Menu" referente � entrada / libera��o do resultado ap�s 	���
//���          �efetivar a grava��o do mesmo.								���
//���			cProd  := PARAMIXB[1]								        ���
//���			cRevpr := PARAMIXB[2]								        ���
//���			cForn  := PARAMIXB[3]								        ���
//���			cLjFor := PARAMIXB[4]								        ���
//���			cDtent := dtos(PARAMIXB[5])								    ���
//���			cLote  := PARAMIXB[6]									    ���
//���			cNtfis := PARAMIXB[7]								        ���
//���			cSerNF := PARAMIXB[8]								        ���
//���			cItNF  := PARAMIXB[9]								        ���
//���			cTpNF  := PARAMIXB[10]								        ���
//���			cOpc   := PARAMIXB[11]								        ���
//�������������������������������������������������������������������������͹��
//���Uso       � Eletromega					                                ���
//�������������������������������������������������������������������������ͼ��
//�����������������������������������������������������������������������������
//�����������������������������������������������������������������������������
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