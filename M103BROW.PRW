/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �M103BROW()  �Autor  �Eletromega        � Data �  17/07/09   ���
�������������������������������������������������������������������������͹��
���Desc.     � Executado antes da execucao do browse, serve para          ��� 
���			   dos dados no browse (filtro, por exemplo).  			      ���
���																		  ���
���			   LOCALIZA��O:Function MATA103 - Notas Fiscais de Entrada.   ���
���			   EM QUE PONTO: PRE-VALIDACAO DE DADOS P/ BROWSE             ���
���                                                                       ���
�������������������������������������������������������������������������͹��
���Uso       � AP8                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function M103BROW() 
Local cFil 		:= ''
Local cNomeUsr  := Upper(Rtrim(cUserName))

If cNomeUsr $ 'DEVOLUCAO'  
	cFil := " F1_TIPO $ 'D' .And. AllTrim(F1_SERIE) $ 'UNP' "
	SF1->(dbSetFilter( { || &cFil }, cFil ))
ElseIf cNomeUsr $ 'LOGISTICA'   
	cFil := " F1_TIPO $ 'C' .And. AllTrim(F1_ESPECIE) $ 'NFST.CTR' "
	SF1->(dbSetFilter( { || &cFil }, cFil ))
ElseIf cNomeUsr $ 'COBRANCA1.COBRANCA.FINANCEIRO' 
	cFil := "  F1_TIPO $ 'D' "
	SF1->(dbSetFilter( { || &cFil }, cFil ))
EndIf

/*
If cNomeUsr $ 'DEVOLUCAO'  
	cFil := "@ F1_TIPO IN ('D') AND F1_SERIE IN ('UNP') AND (D_E_L_E_T_ <> '*')"
	SF1->(dbSetFilter( { || &cFil }, cFil ))
ElseIf cNomeUsr $ 'LOGISTICA'   
	cFil := "@ F1_TIPO IN ('C') AND F1_ESPECIE IN ('NFST ','CTR   ') "
	SF1->(dbSetFilter( { || &cFil }, cFil ))
ElseIf cNomeUsr $ 'COBRANCA1.COBRANCA.FINANCEIRO' 
	cFil := "@ F1_TIPO IN ('D') "
	SF1->(dbSetFilter( { || &cFil }, cFil ))
EndIf
*/
Return( NIL )