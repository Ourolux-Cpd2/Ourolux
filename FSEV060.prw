#INCLUDE "PROTHEUS.CH"
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � FSEV060  �Autor  � Ernani Forastieri  � Data �  30/05/06   ���
�������������������������������������������������������������������������͹��
���Desc.     � Validacao do X3_VLDUSER do Campo SUS->US_VEND              ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       �Eletromega                                                  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function FSEV060(cVendAt)
Local lRet   := .T.
Local cVends := '' 
Default cVendAt	:= &(ReadVar())


If (!IsBlind()) // COM INTERFACE GR�FICA


	If (IsInCallStack( 'TMKA260' ) .Or. IsInCallStack( 'MATA030' ) .Or. IsInCallStack( 'FSEA050' ) ) ;
		.AND. !(U_IsAdm() .OR. U_IsFree() )
	
		// cVends � STATIC para monta apenas uma vez a string
		U_ListaVnd(@cVends)
	
		If !( cVendAt $ cVends )
			lRet := .F.
			ApMsgStop('C�digo de Vendedor N�o Permitido.', 'ATEN��O' )
		EndIf
	
	EndIf

EndIf

Return lRet
