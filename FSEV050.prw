#INCLUDE "PROTHEUS.CH"
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �FSEV050   �Autor  �Norbert Waage Junior� Data �  24/04/06   ���
�������������������������������������������������������������������������͹��
���Desc.     �Validacao da condicao de pagamento utilizada                ���
�������������������������������������������������������������������������͹��
���Uso       �Valida�o do Usuario no campo UA_CONDPG/C5_CONDPAG           ��� 
���Uso       �Filtro tipo 6 - Consulta padrao SE4                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function FSEV050(cCond)

Local nRet 		:= 1
Local lInMat410 := IsInCallStack("MATA410")
Local lInTMK271 := IsInCallStack("TMKA271")
Local nValor    := 0


//Default cCond := IIf(IsInCallStack("MATA410"),M->C5_CONDPAG,M->UA_CONDPG)
If Type("L410Auto")!="U" .And. L410Auto
	Return(.T.)
EndIf

If lInTMK271 .And. lTK271Auto 
	Return .T.
EndIf

If !(lInMat410 .Or. lInTMK271) .Or. U_IsAdm() .OR. U_IsFreeCondPgt() .Or. (Type("lTk271Auto") <> "U" .AND. lTk271Auto)//lTK271Auto
	Return (.T.)
EndIf  

If lInTMK271
	nValor	:= aValores[6]
	nRet	:= U_VldCPG(nValor,cCond)

ElseIf lInMat410
	If M->C5_TIPO == "N" 
		//nRet := U_VldCPG(U_TotPed(),cCond)	//Na inclusao nunca vamos ter o valor no SC6
		nRet:= U_VldCPG(nValor,cCond)	//Sol.Fernando-26/11/2020 - Andr� - Corre��o na Valida��o do campo 
		nRet:= if(nRet>6,0,nRet)
	Else
		nRet:= 0
	EndIf

Else	//Demais Rotinas
	nRet	:= 0
EndIf

Return (nRet == 0)
