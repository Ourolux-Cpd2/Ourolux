#Include "rwmake.ch"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �Excell()  � Autor � Andre Bagatini     � Data �  08/07/11   ���
�������������������������������������������������������������������������͹��
���Descricao �Fun��o com o objetivo de receber um array com dados ,outro  ���
���          �com itens e exportar direto para o Excell sem salvar no C:/ ���
�������������������������������������������������������������������������͹��
���Uso       � Eletromega                                                 ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
User Function Excmg21n(cTexto,aCabec,aDados,mvpar)

	Local aCabec1:= {}
	Local aDados2:= {}
	Local aTemp	 := {}

	If !ApOleClient("MSExcel") // testa a intera��o com o excel.
		MsgAlert("Microsoft Excel n�o instalado!")
		Return Nil
	EndIf

	For x:= 1 to Len(aCabec)

		AADD(aCabec1,aCabec[x][1])

	Next x

	y:= 1

	If mvpar = 2
		For x:= 1 to Len(aDados)

			While  x <= (18 * y)
				AADD(aTemp,aDados[x])
				x++
			End
			If x > (18 * y)
				AADD(aDados2,aTemp)
				aTemp := {}
				y++
			EndIf
    		// 
			x--
		Next x
	Else
		For x:= 1 to Len(aDados)-1

			While  x <= (18 * y) .And. x <= Len(aDados)
				AADD(aTemp,aDados[x])
				x++
			End
			If x > (18 * y)
				AADD(aDados2,aTemp)
				aTemp := {}
				y++
			EndIf
    		// 
			x--
		Next x
	Endif
                                     
	DlgToExcel({ {"ARRAY", cTexto, aCabec1,aDados2} }) // utiliza a fun��o

Return Nil