
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �MTA450T   �Autor  �Microsiga           � Data �  04/11/07   ���
�������������������������������������������������������������������������͹��
���Desc.     �Ponto de Entrada : APOS ATUALIZACAO DO SC9 NA LIB. PEDIDO   ���
���Executado apos atualizacao do SC9 na liberacao do pedido.              ���
���                                                                       ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � mp8                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function MTA450T

/*
If SC5->C5_TIPO == 'N'  // WAR 08-05-2013

	If SA1->A1_RISCO = [D] .And.;
   		SC9->C9_BLCRED = '  '

   		SA1->A1_RISCO := 'B'

	ElseIf SA1->A1_RISCO $ [CDE]          .Or.;
   		(dDatabase - 120) > SA1->A1_ULTCOM .Or.;
   		SA1->A1_SalDup > SA1->A1_LC        .Or.;
   		SA1->A1_Cod == "999999"
      
		If cFilAnt <> "04"
        	_cSql := "UPDATE " + RetSqlName("SC9") + " SC9 SET C9_BLCRED = '01' WHERE D_E_L_E_T_ <> '*' AND C9_PEDIDO = '" + SC9->C9_PEDIDO + "' " 
   			_cSql += "AND C9_FILIAL = '" + xFilial("SC9") + "' "  
		EndIf   
    EndIf
EndIf
*/

Return( NIL )