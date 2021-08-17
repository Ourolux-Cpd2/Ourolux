#INCLUDE "RWMAKE.CH"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ M530FIM  ³ Autor ³ Marcos Gomes - TAGGS  ³ Data ³ 10/08/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Marca o campo E2_X_TT como S no(s) titulo(s) de imposto(s) ³±±
±±³          ³ de comissao.                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
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

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ (SE2) - Muda o TIPO DO TITULO para PROVISORIO;               ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		DBSelectArea("SE2")
		DBSetOrder(1)
		WHILE SE2->(!EOF()) .AND. SE2->E2_FILIAL = xFilial("SE2") .AND. SE2->E2_NUM == cNUMTIT .AND. SE2->E2_PREFIXO = cPREFIXO .AND. SE2->E2_FORNECE == cFORNECE .AND. SE2->E2_LOJA = cLOJA .AND. SE2->E2_TIPO = cTIPO
					
					RECLOCK( "SE2", .f. )
							SE2->E2_X_TT	:= "S"	// Flag para selecao de registros
					MSUNLOCK()
					
					cTITPAI	:= PADR( SE2->( E2_PREFIXO + E2_NUM + E2_PARCELA + E2_TIPO + E2_FORNECE + E2_LOJA ), TAMSX3("E2_TITPAI")[1] )

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//| Query para gravar o FLAG no(s) titulo(s) de Impostos                        |
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ											
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
