#INCLUDE "PROTHEUS.CH"
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � FSEF002  �Autor  � Ernani Forastieri  � Data �  30/05/06   ���
�������������������������������������������������������������������������͹��
���Desc.     � Filtro para a Consulta padrao SU7, Acrescentado registro de���
���          � tipo 6 no SXB                                              ���
�������������������������������������������������������������������������͹��
���Uso       �Eletromega                                                  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function FSEF002()
Local lRet   := .T.
Static cVends := ''

If lTK271Auto 
	Return lRet
EndIf

If (IsInCallStack( 'TMKA271' ) .OR. IsInCallStack( 'TMKA150' )) ;
.AND. !(U_IsAdm() .OR. U_IsFree()) 
	
	// cVends � STATIC para monta apenas uma vez a string
	If Empty( cVends )
		U_ListaVnd(@cVends,,.F.,.T.)
	EndIf
	
	If !( SU7->U7_CODVEN $ cVends )
		lRet := .F.
	EndIf
	
EndIf

Return lRet
