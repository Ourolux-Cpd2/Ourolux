#INCLUDE "PROTHEUS.CH"
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �FSEV030   �Autor  �Norbert Waage Junior� Data �  20/03/06   ���
�������������������������������������������������������������������������͹��
���Desc.     �Validacao do cliente selecionado pelo vendedor              ���
�������������������������������������������������������������������������͹��
���Uso       �Eletromega                                                  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function FSEV030()

Local aArea	  	:= GetArea()
Local lAdm	  	:= U_IsAdm() 
Local lRet	  	:= .T.
Local aVndA1	:= ""
Local lCond 	:= .F.
Local cVend		:= ""
Local cSegCli 	:= ""  // Segmento do Cliente

// Rotina Automatica SFA
If (Type("L410Auto")!="U" .And. L410Auto) 
	Return .T.
EndIf

If IsInCallStack("MATA410") .And. M->C5_TIPO <> 'N'
	Return .T.
EndIf

If IsInCallStack("TMKA271") .And. lTK271Auto 
	Return .T.
EndIf



//����������������������������������������������������������Ŀ
//�Verifica se o usuario pertence ao grupo de administradores�
//������������������������������������������������������������
If IsInCallStack("MATA410")
	cCli := M->C5_CLIENTE
	cLoj := M->C5_LOJACLI
	aVndA1 := GetAdvFVal("SA1",{"A1_VEND","A1_SATIV1","A1_EST"},xFilial("SA1")+M->(C5_CLIENTE+C5_LOJACLI),1,{"",""})
ElseIf IsInCallStack("TMKA271")
	cCli := M->UA_CLIENTE
	cLoj := M->UA_LOJA 
	aVndA1 := GetAdvFVal("SA1",{"A1_VEND","A1_SATIV1","A1_EST"},xFilial("SA1")+M->(UA_CLIENTE+UA_LOJA),1,{"",""})
EndIf

If !(U_IsAdm() .OR. U_IsFree()) 

	U_ListaVnd(@cVend)
	
	//��������������������������������������Ŀ
	//�Excecao para cliente direto ou inativo�
	//����������������������������������������
	If U_IsDireto()   // 
		//lCond := ( 'DIRET' $ aVndA1[2] ) war 10-05-06
		lCond := ( '999999' $ aVndA1[1] )
	EndIf
	
	//������������Ŀ
	//�Valida regra�
	//��������������
	
	If !(aVndA1[1] $ cVend)  
		If (aVndA1[1] == '000000')
	    	ApMsgStop("Cliente " + cCli + "/" + cLoj + " encontra-se inativo, solicite a libera��o do mesmo com seu gerente.","N�o permitido.")
	    	lRet := .F.
		ElseIf (aVndA1[1] == '999999') .AND. !lCond
			ApMsgStop("Cliente " + cCli + "/" + cLoj + " n�o permitido para o vendedor atual.")
			lRet := .F.
		ElseIf (aVndA1[1] == '999999') .AND. lCond 
			lRet := .T.
		ElseIf (aVndA1[1] == '888888') 
			lRet := .T.
		Else
			ApMsgStop("Cliente " + cCli + "/" + cLoj + " n�o permitido!")
			lRet := .F. 		
		EndIf
	Else  
	   If Substr(cNumEmp,1,2) == '02' .And. aVndA1[3] <> 'SP' 
	   		ApMsgStop("Cliente " + cCli + "/" + cLoj + " n�o permitido para essa empresa!")
			lRet := .F. 		
	   EndIf 
	EndIf 
EndIf

If ( U_IsFree() )
	 
	If Substr(cNumEmp,1,2) == '02' .And. aVndA1[3] <> 'SP' 
	   	ApMsgStop("Cliente " + cCli + "/" + cLoj + " n�o permitido para essa empresa!")
		lRet := .F. 		
	ElseIf (aVndA1[1] == '000000')
		ApMsgStop("Cliente " + cCli + "/" + cLoj + " encontra-se inativo, solicite a libera��o do mesmo com seu gerente.","N�o permitido..")
	    lRet := .F.
	ElseIf (aVndA1[1] == '888888') 
		lRet := .T.
    ElseIf (aVndA1[1] == '999999') 
		ApMsgStop("Cliente " + cCli + "/" + cLoj + " n�o permitido para o vendedor atual.")
		lRet := .F.
    EndIf
    
EndIf

RestArea(aArea)
Return lRet