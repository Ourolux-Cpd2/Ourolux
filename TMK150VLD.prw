#INCLUDE "PROTHEUS.CH"
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �TMK150VLD     �Autor  �Microsiga       � Data �  11/09/06   ���
�������������������������������������������������������������������������͹��
���Desc.     � Ponto de entrada executado depois da confirma��o de        ���
��� exclus�o da rotina de - Exclus�o de NF/Or�amento-.Observa��o: Quando  ���
��� a 'Opera��o' for de FATURAMENTO, o ponto de entrada ser� executado    ���
��� somente depois das valida��es do sistema.                             ���                              ���
��� somente depois das valida��es do sistema.                             ���                              ���
��� � Se o pedido e no pedido mao, nao deixar excluir - Return .F.        ���
��� � Senao Return  .T.                                                   ���
�������������������������������������������������������������������������͹��
���Uso       � AP8                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function TMK150VLD(cCodAte)
Local lRet  := .T. 
Local lMae  := U_getMae() == "S"//SuperGetMv("FS_MAE") == "S"

If (SUA->UA_OPER == '1' )   // FATURAMENTO
	If ( AllTrim(SC5->C5_OK) == 'S' .And. lMae )
   		lRet := .F.
   		ApMsgStop("O pedido n�o pode ser excluido (Pedido Mae)","Aten��o")
   	EndIf
EndIf




//��������������������������������������Ŀ
//�Integra��o de Pedido Filal 01 com     �
//�filial 04                             �
//����������������������������������������

/*
If cFilAnt == "04"


	



	cNUMF04		:= SUA->UA_NUM
	cNUMF01		:= SUA->UA_XNUMF01
	
	dbSelectArea("SUA")
	dbGoTop()
	dbSetOrder(1)
	If dbSeek("01"+cNumF01)
		
		cNUMSC5	:= SUA->UA_NUMSC5
		
		Do Case
			
			Case SUA->UA_STATUS == "LIB"
				
				Alert("Exclusao do Atendimento "+cNumF04+" n�o permitida. J� foi realizada libera�a� do pedido na filial Guarulhos.")
				lRet	:= .F.
				
			Case SUA->UA_STATUS == "NF."
				
				Alert("Exclus�o do Atendimento "+cNumF04+" n�o permitida. J� possui nota fiscal faturada na filial Guarulhos.")
				lRet	:= .F.
				
			Case SUA->UA_STATUS == "CAN"
				
				Alert("Exclus�o do Atendimento "+cNumF04+" n�o permitida. O atendimento j� est� exlu�do na filial Guarulhos.")
				lRet	:= .F.
				
			Case SUA->UA_STATUS == "SUP"
				
				aCab := {}
				aItem:= {}
				
				lMSHelpAuto := .T.
				lMsErroAuto := .F.
				
				cTMKRJCL	:= SubStr(AllTrim(GetMV("FS_TMKRJCL")),1,6)	//Cliente Padr�o
				cTMKRJLJ	:= SubStr(AllTrim(GetMV("FS_TMKRJCL")),8,2)	//Loja Padr�o
				cTMKRJCP	:= SubStr(AllTrim(GetMV("FS_TMKRJCP")),1,3)	//Condi��o de Pagamento Padr�o
				cTMKRJTB	:= SubStr(AllTrim(GetMV("FS_TMKRJTB")),1,3)	//Tabela de Pre�os Padr�o
				cTMKRJTS	:= SubStr(AllTrim(GetMV("FS_TMKRJTS")),1,3)	//Tes de Sa�da Padr�o
				cTMKRJFP	:= SubStr(AllTrim(GetMV("FS_TMKRJFP")),1,6)	//Forma de Pagamento Padr�o
				cTMKRJTE	:= SubStr(AllTrim(GetMV("FS_TMKRJTE")),1,1)	//Tipo de entrada Padr�o
				cTMKRJTR	:= SubStr(AllTrim(GetMV("FS_TMKRJTR")),1,6)	//Transportadora Padr�o
				cTMKRJTF	:= SubStr(AllTrim(GetMV("FS_TMKRJTF")),1,1)	//Tipo de Frete Padr�o
				cTMKRJLC	:= SubStr(AllTrim(GetMV("FS_TMKRJLC")),1,2)	//Local Padr�o
				cTMKRJOP	:= SubStr(AllTrim(GetMV("FS_TMKRJOP")),1,6)	//Operador Padr�o (vendedor padr�o a pardir do operador)
				cVend		:= Posicione("SU7",1,xFilial("SU7")+cTMKRJOP,"U7_CODVEN")
				
				xFilAnt	:= cFilAnt
				cFilAnt	:= "01"
				cNumEmp	:= cEmpAnt+cFilAnt
				
				dbCloseAll()
				OpenFile(cEmpAnt)
				
				dbSelectArea("SM0")
				dbCloseArea()
				OpenSM0(cEmpAnt+cFilAnt)
				
				
				aCab	:=	{	{"C5_NUM"		,cNumSC5			,NIL}}
				
				dbSelectArea("SC6")
				dbGoTop()
				dbSetOrder(1)
				dbSeek(xFilial("SC6")+cNumSC5)
				While !Eof() .And. SC6->C6_FILIAL+SC6->C6_NUM == xFilial("SC6")+cNumSC5
						
						aAdd(aItem, {	{"C6_ITEM"		,C6_ITEM			,NIL},;
										{"C6_PRODUTO"	,C6_PRODUTO			,NIL}})
						
						dbSelectArea("SC6")
						dbSkip()
						
				EndDo
					
				If Len(aItem) > 0
			
					dbSelectArea("SC5")
					dbGoTop()
					dbSetOrder(1)
					dbSeek(xFilial("SC5")+cNumSC5)
					
					
					MSExecAuto({|x,y,z| tmka150(x,y,z)},aCab,aItem,5) //Exclus�o
//					MSExecAuto({|x,y,z,w| tmka271(x,y,z,w)},aCab,aItem,5,"2") //Exclus�o
					
					If lMsErroAuto
						MostraErro()
						lRet	:= .F.
						//						DisarmTransaction()
						//						Break
					Else
						lRet	:= .T.
						Alert("Atendimento integrado na filial Guarulhos exclu�do com sucesso.")
					Endif
					
					cFilAnt	:= xFilAnt
					cNumEmp	:= cEmpAnt+cFilAnt
					
					dbCloseAll()
					OpenFile(cEmpAnt)
					
					dbSelectArea("SM0")
					dbCloseArea()
					OpenSM0(cEmpAnt+cFilAnt)
					
				EndIf

		EndCase
		
	EndIf
	
	dbSelectArea("SUA")
	dbGoTop()
	dbSetOrder(1)
	dbSeek(xFilial("SUA")+cNumF04)
	
EndIf


lRet	:= .F.
*/

Return (lRet)

Static Function GetInfo()
	
	Local oDlg,oButton,oMemo,cMemo := space(50)
	
	oDlg := MSDialog():New(10,10,180,400,"Motivo",,,,,CLR_BLACK,CLR_WHITE,,,.T.)

	cBlKVld := "{|| .not. empty(cMemo)}"
	
	oMemo := TMultiget():New(10,8,bSetGet(cMemo), oDlg,;
    180,50,,,,,,.T.,,,,,,,&(cBlkVld),,,,.F.) 

	oButtonOk := tButton():New(65,150,"OK",oDlg,{||oDlg:End()},40,15,,,,.T.)
	oButtonCancel := tButton():New(65,150,"Cancel",oDlg,{||oDlg:End()},40,15,,,,.T.)

	// ativa di�logo centralizado
	oDlg:Activate(,,,.T.,&(cBlkVld),,)

Return ()
