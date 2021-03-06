/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �F050BROW()  �Autor  �Eletromega        � Data �  4/12/12    ���
�������������������������������������������������������������������������͹��
���Desc.     � Executado antes da execucao do browse, serve para          ��� 
���			   dos dados no browse (filtro, por exemplo).  			      ���
���																		  ���
���			   EM QUE PONTO: PRE-VALIDACAO DE DADOS P/ BROWSE             ���
���                                                                       ���
�������������������������������������������������������������������������͹��
���Uso       � AP10                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function F050BROW() 
Local cFil	:= ''
Local cName := Upper(Rtrim(cUserName))

SE2->(DbClearFilter())

If cName $ 'FATURAMENTO.FATURAMENTO2' 
	cFil := " E2_TIPO == 'TX ' .And. E2_FORNECE $ 'ESTADO' .And. E2_PREFIXO == 'ICM' "
	SE2->(dbSetFilter( { || &cFil }, cFil ))
EndIf

Return( NIL )