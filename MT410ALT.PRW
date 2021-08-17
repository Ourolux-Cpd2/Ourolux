/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �MT410ALT  �Autor  �Microsiga           � Data �  10/17/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Este ponto de entrada pertence � rotina de pedidos de venda ���
���          �Est� localizado na rotina de altera��o do pedidos           ���
���          �� executado ap�s a grava��o das altera��es.                 ��� 
���          �															  ���
���          �Retorno Nenhum                                              ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP8                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
#INCLUDE "PROTHEUS.CH"
User Function MT410ALT()
Local cQuery := ""
//�������������������������������������������������I
//�Disable a consulta de pre�o depois da grava�ao  �
//�da altera�aos de ped de venda                   �
//�������������������������������������������������I
SetKey(VK_F2, { || AllWaysTrue() } ) 

cQuery := " SELECT COUNT(*) TOTAL FROM " + RetSqlName("SC6")
cQuery += " WHERE C6_FILIAL = '"+SC5->C5_FILIAL+"' "
cQuery += " AND C6_NUM = '"+SC5->C5_NUM+"' "
cQuery += " AND C6_CLI = '"+SC5->C5_CLIENTE+"' ""
cQuery += " AND C6_LOJA = '"+SC5->C5_LOJACLI+"' "
cQuery += " AND C6_NOTA <> ' ' "
cQuery += " AND D_E_L_E_T_ <> '*' "

IF Select("C6TMP") > 0
    C6TMP->(dbCloseArea())
ENDIF

DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery) , 'C6TMP', .T., .F.)

If C6TMP->(!EOF())  
    If C6TMP->TOTAL == 0
        RecLock("SC5",.F.)
        SC5->C5_XDTBLQ  := CTOD("  /  /    ")
        SC5->C5_XMOTLIB := "" 
        SC5->C5_XTIPOL  := ""
        SC5->C5_XDTLIB  := CTOD("  /  /    ")
        SC5->C5_XUSRLIB := ""
        SC5->(MsUnlock())
    EndIf
EndIf

Return(Nil)