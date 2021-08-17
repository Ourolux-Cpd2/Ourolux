#INCLUDE "PROTHEUS.CH"
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � FSEF001  �Autor  � Ernani Forastieri  � Data �  30/05/06   ���
�������������������������������������������������������������������������͹��
���Desc.     � Filtro para a Consulta padrao SA3, Acrescentado registro de���
���          � tipo 6 no SXB                                              ���
�������������������������������������������������������������������������͹��
���Uso       �Eletromega                                                  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function FSEF001()
Local lRet   := .T.
Static cVends := ''

If lTK271Auto 
	Return lRet
EndIf

If (IsInCallStack('TMKA271') .OR. IsInCallStack('TMKA150'); 
	.OR. IsInCallStack('MATA410');
	.OR. IsInCallStack('TMKA260') .OR. IsInCallStack('MATA030')); 
	.AND. !(U_IsAdm() .OR. U_IsFree()) 	
	// cVends � STATIC para monta apenas uma vez a string
	If Empty( cVends )
		U_ListaVnd(@cVends,,.T.)
	EndIf
	
	If !( SA3->A3_COD $ cVends )
		lRet := .F.
	EndIf
	
EndIf

Return lRet
