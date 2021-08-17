
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �RETSERIEF1�Autor  �Eletromega          � Data �  12/03/07   ���
�������������������������������������������������������������������������͹��
���Desc.     � Filtrar a serie de NF na inclusao de NF de entrada         ���
���          � Chamado no x3_rela�ao do campo F1_SERIE                    ��� 
���          � The Filter is set in GeraNumTrc (SD1)                      ���
�������������������������������������������������������������������������͹��
���Uso       � AP8                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function RetSerieF1()
Local cSerie := ' '

DO CASE
CASE SD1->D1_SERIE $ 'TRC'
	cSerie := 'TRC'
CASE SD1->D1_SERIE $ 'OS '
	cSerie := 'OS '
CASE SD1->D1_SERIE $ 'TS '
	cSerie := 'TS '
CASE SD1->D1_SERIE $ 'RS '
	cSerie := 'RS '
CASE SD1->D1_SERIE $ 'UNP'
	cSerie := 'UNP'
OTHERWISE
cSerie := 'ORC'
ENDCASE

Return(cSerie)