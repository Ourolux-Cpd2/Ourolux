#INCLUDE "RWMAKE.CH"
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � M530FIM  � Autor � Marcos Gomes - TAGGS  � Data � 10/08/13 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Marca o campo E2_X_TT como S no(s) titulo(s) de imposto(s) ���
���          � de comissao.                                               ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
USER FUNCTION M530FIM()
cUpse2 := " UPDATE SE2010 SET D_E_L_E_T_='*' WHERE "
cUpse2 += " E2_TIPO in('DP','TX') AND E2_PREFIXO='"+cPREFIXO+"' AND 
cUpse2 += " E2_EMISSAO='"+DTOS(DDATABASE)+"' AND "
cUpse2 += " D_E_L_E_T_ = '' " 
TCSQLExec( cUpse2 )

/*

LOCAL aAREA_ATU		:= GETAREA()
LOCAL aAREA_SE2		:= SE2->( GETAREA() )

LOCAL cPREFIXO		:= SE2->E2_PREFIXO
LOCAL cNUMTIT		:= SE2->E2_NUM
LOCAL cPARCELA		:= SE2->E2_PARCELA
LOCAL cTIPO			:= SE2->E2_TIPO
LOCAL cFORNECE		:= SE2->E2_FORNECE
LOCAL cLOJA			:= SE2->E2_LOJA

		//��������������������������������������������������������������Ŀ
		//� (SE2) - Muda o TIPO DO TITULO para PROVISORIO;               �
		//����������������������������������������������������������������
		DBSelectArea("SE2")
		DBSetOrder(1)
		WHILE SE2->(!EOF()) .AND. SE2->E2_FILIAL = xFilial("SE2") .AND. SE2->E2_NUM == cNUMTIT .AND. SE2->E2_PREFIXO = cPREFIXO .AND. SE2->E2_FORNECE == cFORNECE .AND. SE2->E2_LOJA = cLOJA .AND. SE2->E2_TIPO = cTIPO
					
					RECLOCK( "SE2", .f. )
							SE2->E2_X_TT	:= "S"	// Flag para selecao de registros
					MSUNLOCK()
					
					cTITPAI	:= PADR( SE2->( E2_PREFIXO + E2_NUM + E2_PARCELA + E2_TIPO + E2_FORNECE + E2_LOJA ), TAMSX3("E2_TITPAI")[1] )

					//�����������������������������������������������������������������������������Ŀ
					//| Query para gravar o FLAG no(s) titulo(s) de Impostos                        |
					//�������������������������������������������������������������������������������											
					cQryUPD	:= ""
					cQryUPD	+= " UPDATE " + RETSqlName("SE2") + " SET E2_X_TT = 'S' "
					cQryUPD	+= " WHERE 	E2_FILIAL = '" + xFilial("SE2") + "' "
					cQryUPD	+= "		AND E2_TITPAI = '" + cTITPAI + "' "
					cQryUPD	+= " 		AND D_E_L_E_T_ <> '*' "																						
			
				   	TCSQLExec( cQryUPD )

					SE2->(DBSkip())

		ENDDO
		
RESTAREA( aAREA_SE2 )
RESTAREA( aAREA_ATU )
*/
RETURN()
