#Include "rwmake.ch"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �TITICMST  �Autor  �                    � Data �   27/09/11  ���
�������������������������������������������������������������������������͹��
���Desc.     �PE Gera��o de guia ICMS-ST	 					          ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function TITICMST

Local cOrigem 	:= PARAMIXB[1]
Local cTipoImp	:= PARAMIXB[2]
Local cPrefixo  := SE2->E2_PREFIXO

If AllTrim(cOrigem) == 'MATA460A'   
	SE2->(RecLock("SE2", .F.))
	SE2->E2_HIST 	:= SF2->F2_SERIE+SF2->F2_DOC
	SE2->E2_VENCTO  := DataValida(dDataBase+1,.T.)  
	SE2->E2_VENCREA := DataValida(dDataBase+1,.T.) 
   	SE2->(MSUnLock())	
EndIF

//���������������������������������������������������������������������Ŀ
//�Dados referente a Guia de recolhimento gerado no Contas a Pagar      �
//�����������������������������������������������������������������������
If cPaisLoc == "BRA" .And. cOrigem == "MATA460A" .And. cPrefixo == "ICM"
	If SF2->(FieldPos("F2_NFICMST"))>0
		RecLock("SF2",.F.)
		SF2->F2_NFICMST := cPrefixo+SE2->E2_NUM
		SF2->(MsUnlock())
	Endif
Endif
Return        