#Include "Rwmake.ch"
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �MTA105OK  � Autor � ELETROMEGA         � Data �  23/05/12   ���
�������������������������������������������������������������������������͹��
���Descricao � Confirma a grava��o da solicita��o ao almoxarifado         ���
���          � Ao confirmar a solicita��o ao almoxarifado.                ���				
���            Pode ser utilizado para confirmar ou nao a gravacao        ���
���            da Solicitacao ao Almoxarifado.                            ���
�������������������������������������������������������������������������͹��
���Uso       � Estoque/Custos                                             ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
User Function MTA105OK()
Local lRet 		:= .T.
Local aArea     := GetArea()
Local nPProd    := aScan(aHeader,{ |x| Upper(AllTrim(x[2])) == "CP_PRODUTO" })
Local nI        := 0

For nI := 1 to Len(aCols)		
	If !aCols[nI][Len(aHeader)+1] 
		SB1->( dbSeek( xFilial('SB1') + aCols[nI][nPProd]) )	
		If !ALLTRIM(SB1->B1_GRUPO) $ 'MC.TI' 
			lRet := .F.
			ApMsgStop( 'Produto invalido! Somente produtos do grupo MC/TI podem ser inclusos.', 'MTA105OK' )
			Exit
		EndIf
	EndIf                  
Next

Return(lRet)