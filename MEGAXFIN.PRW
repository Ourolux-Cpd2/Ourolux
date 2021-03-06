#Include "rwmake.ch"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �FINXFUNC  �Autor  � WAR                � Data �  02/07/07   ���
�������������������������������������������������������������������������͹��
���Desc.     � User Function usados na arquivo Bradesco.rem               ���
���          � (Contas a receber- envio CNAB)                             ���
�������������������������������������������������������������������������͹��
���Uso       � AP8                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

/*
�������������������������������������������������������������������������͹��
���Desc.     � GravaDesc(): Grava o valor de desconto E1_DESCFIN gerado   ���
���          � pelo de Cond de Pagt no arquivo BRADESCO.REM               ���
�������������������������������������������������������������������������͹��
*/

User Function GravaDesc()

Local nDesc := ROUND ( (SE1->E1_VALOR * SE1->E1_DESCFIN)/100, 2)

nDesc *= 100

nDesc := STRZERO(nDesc,13) 
	
Return(nDesc)

/*
�������������������������������������������������������������������������͹��
���Desc.     � GravaDataDesc() - Grava o campo dias p/ Desc (E1_DIADESC)  ���
���          � gerado pelo Cond de Pagt no arquivo BRADESCO.REM           ���
�������������������������������������������������������������������������͹��
*/

User Function GravaDataDesc()
//Local lRet := If(SE1->E1_DESCFIN <> 0 ,GravaData(SE1->E1_VENCTO - SE1->E1_DIADESC,.F.,1),space(6)) 
Local lRet := If(SE1->E1_DESCFIN <> 0 ,GravaData(SE1->E1_VENCTO - SE1->E1_DIADESC,.F.,1),StrZero(0,6))

Return(lRet)