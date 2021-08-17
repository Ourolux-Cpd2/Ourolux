/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � HtmTrans �Autor  �Eletromega         � Data �  07/01/05    ���
�������������������������������������������������������������������������͹��
���Desc.     �  Dispara o Workflow naTransfer�ncia do  �				   ��
���          � Estoque 				                                      ���
�������������������������������������������������������������������������͹��
���Uso       � AP6 														  ���
���Esse ponto de entrada est� localizado na fun��o A520Dele(). 			  ���
���� chamado Ap�s a grava��o dos Dados									  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
#include 'rwmake.ch'
#include "TbiConn.ch"   

User Function HtmTrans(_Tipo)

Local oHTML

	// Claudino - 20/05/16 - Tratamento para n�o enviar workflow de transferencia, quando for Ordem de Produ��o.
	If FUNNAME() <> "MATA250"
	
		oProcess:= TWFProcess():New("Estoque","Transf Mod2")
	
		oProcess:NewTask("Inicio","\WORKFLOW\TransMod2.htm")
	
		If _Tipo = 1
			oProcess:cSubject := "Transfer�ncia de Estoque: " + AllTrim(SM0->M0_NOME)+ " / " + Alltrim(SM0->M0_FILIAL) 
		Else
			oProcess:cSubject := "Estorno Transf. de Estoque: " + AllTrim(SM0->M0_NOME)+ " / " + Alltrim(SM0->M0_FILIAL) 	
		EndIf
	
	  	oHtml := oProcess:oHTML   
	  	
	  	oProcess:oHTML:ValByName('NomEmp',AllTrim(SM0->M0_NOME))
	  	
	  	oProcess:oHTML:ValByName('FilName',Alltrim(SM0->M0_FILIAL))
		
		oProcess:oHTML:ValByName('DOC',SD3->D3_DOC)
		
		oHTML:ValByName('DATA',DA261DATA)
		
		dBSelectArea("SD3")
		dbSetOrder(2)
		DbSeek(xFilial("SD3")+CDOCUMENTO)
			
			While xFilial("SD3")+CDOCUMENTO = xFilial("SD3")+SD3->D3_DOC           
				aAdd( ( oHTML:valByName( 'D3.Cod'  ) ), AllTrim(SD3->D3_COD))
				cDesc := GetAdvFVal("SB1","B1_DESC",xFilial("SB1")+SD3->D3_COD,1," ")
				aAdd( ( oHTML:valByName( 'D3.Desc' ) ), Rtrim(cDesc) )
				aAdd( ( oHTML:valByName( 'D3.UN' ) ), SD3->D3_UM)
				aAdd( ( oHTML:valByName( 'D3.Local' ) ), AllTrim(SD3->D3_LOCAL))	
				aAdd( ( oHTML:valByName( 'D3.Quant' ) ),SD3->D3_QUANT)
				aAdd( ( oHTML:valByName( 'D3.Lote'  ) ), AllTrim(SD3->D3_LOTECTL))											
				aAdd( ( oHTML:valByName( 'D3.End'   ) ), AllTrim(SD3->D3_LOCALIZ)) // Claudino 26/05/15 - Linha adicionada											
				SD3->(dbSkip())
			EndDo
	
		oProcess:cTo := U_GrpEmail('Transf2')
		oProcess:Start()
		oProcess:Finish()             
		
	EndIf
	
Return