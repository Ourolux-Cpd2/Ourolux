#Include "rwmake.ch"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ExcelIO() � Autor � Andre Bagatini     � Data �  15/06/11   ���
�������������������������������������������������������������������������͹��
���Descricao �Fun��o com o objetivo de receber um array com dados ,outro  ���
���          �com itens e exportar direto para o Excell sem salvar no C:/ ���
�������������������������������������������������������������������������͹��
���Uso       � Eletromega                                                 ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

User Function ExcelIO(aDados)

	If !ApOleClient("MSExcel") // testa a intera��o com o excel.
	   MsgAlert("Microsoft Excel n�o instalado!")
	   Return Nil
	EndIf   
	
	aCabec  := {"PEDIDO","CODIGO","LJ","CLIENTE","MUNICIPIO","UF","TRANSPORTADORA","STATUS","OBSERVACAO","NOTA","ROMANEIO","PEDIDO","NOTA","ROMANEIO",;
	"CANHOTO","PED X NOTA","PED X ROM","PED X CHT","NOTA X ROM","NOTA X CHT"}
	
	
	DlgToExcel({ {"ARRAY", "Emiss�o do Acompanhamento de Vendas", aCabec, aDados} }) // utiliza a fun��o
	
Return Nil