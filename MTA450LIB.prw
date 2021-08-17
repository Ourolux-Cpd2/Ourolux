
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

User Function MTA450LIB()
Local aArea     := GetArea()
Local cPedido   := PARAMIXB[1]
Local cItem     := PARAMIXB[2]
Local cTpLib    := PARAMIXB[3]
Local cQuery    := ""
Local lRet      := .T.

If cTpLib == 1
    If MsgNoYes("Voce clicou em liberacao por item, e recomendado que voce utilize a opcao Liberar Todos, deseja continuar mesmo assim?","Liberacao de Pedido por ITEM")
        cQuery := " SELECT COUNT(*) TOTAL FROM " + RetSqlName("SC9")
        cQuery += " WHERE C9_FILIAL = '"+SC9->C9_FILIAL+"' " 
        cQuery += " AND C9_PEDIDO = '"+cPedido+"' "
        cQuery += " AND C9_ITEM <> '"+cItem+"' "
        cQuery += " AND C9_CLIENTE = '"+SC9->C9_CLIENTE+"' "
        cQuery += " AND C9_LOJA = '"+SC9->C9_LOJA+"' "
        cQuery += " AND (C9_BLCRED <> ' '  or  C9_BLEST <> ' ' ) "
        cQuery += " AND D_E_L_E_T_ <> '*' "

        If Select("C9TMP") > 0
            C9TMP->(dbCloseArea())
        EndIf

        DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery) , 'C9TMP', .T., .F.)

        If C9TMP->(!EOF())
            If C9TMP->TOTAL == 0
                RecLock("SC5",.F.)
                SC5->C5_XUSRLIB := cUsername
                SC5->C5_XDTLIB  := dDataBase
                SC5->C5_XMOTLIB := "Pedido Liberado"
                SC5->C5_XTIPOL  := "L"
                SC5->(MsUnlock())
            EndIf
        EndIf
    Else
        lRet := .F.
    EndIf
EndIf

RestArea(aArea)

Return lRet