
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �OM010LOK  �Autor  �Microsiga           � Data �  07/14/06   ���
�������������������������������������������������������������������������͹��
���Desc.     �  Ponto de entrada para validadar itens das lista de pre�os ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP8                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function OM010LOK()

SetPrvt('lRet','nPosCodPro')

lRet := .T.

/*BEGINDOC
//�������������������������������������������������������������H�
//�Nao deixa o usuario repetir os codigos de produtos na tabela �
//�de pre�o                                                     �
//�������������������������������������������������������������H�
ENDDOC*/

If (ALTERA .AND. MV_PAR01 == 2)

	ApMsgStop( 'Opera�ao nao permitida.', 'ATEN��O' )
	lRet := .F.
	
Else

	nPosCodPro		:= aScan(aHeader,{ |x| Upper(AllTrim(x[2])) == "DA1_CODPRO"   })
	If !aCols[n][Len(aHeader)+1]
		For nI := 1 to Len( aCols )		
			If !aCols[nI][Len(aHeader)+1] .AND. n <> nI
				If aCols[n][nPosCodPro] == aCols[nI][nPosCodPro]
					ApMsgStop( 'Produto j� cadastrado.', 'ATEN��O' )
					lRet := .F.
					Exit
				EndIf
			EndIf                  
		Next
	EndIf

EndIf

Return(lRet)