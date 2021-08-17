#INCLUDE 'protheus.ch'
#INCLUDE 'parmtype.ch'

#DEFINE CRLF chr(13)+chr(10)

//--------------------------------------------------------------------
/*/{Protheus.doc} GeraPR1
Geração da tabela PR1 na liberação do pedido de venda
Somente quando não há bloqueio de crédito cliente e estoque
PR1 = Integração Transpofrete
Chamado pelo P.E. MAAVSC5  -> MATA440*MATA450A*MATA410
Chamado pelo P.E. MTA440C9 -> MATA455*MATA456
@author Caio Menezes
@since 04/02/2020
@version 1.0
@type function
/*/
//--------------------------------------------------------------------

User Function GeraPR1(cAcao)

Local aArea    := GetArea()
Local cFuncao  := Alltrim(Upper(FunName()))
Local lRot1    := cFuncao $ "MATA455*MATA456"           .And. IsInCallStack("U_MTA440C9")
Local lRot2    := cFuncao $ "MATA450A*MATA410*MATA521A" .And. IsInCallStack("U_MAAVSC5")
Local lRot3    := cFuncao $ "MATA440"                   .And. IsInCallStack("U_M440STTS")
Local cQuery   := ""
Local cWa      := ""

Default cAcao := "LIBERACAO"

	cQuery += CRLF + RTrim(" SELECT MAX(C9_BLEST)                                       AS BLEST  ")
	cQuery += CRLF + RTrim("      , MAX(C9_BLCRED)                                      AS BLCRED ")
	cQuery += CRLF + RTrim("      , COUNT(*)                                            AS QTD_C9 ")
    cQuery += CRLF + RTrim("      , (SELECT COUNT(*)                                              ")
    cQuery += CRLF + RTrim("           FROM " + RETSQLNAME("SC6") + " SC6                         ")
    cQuery += CRLF + RTrim("          WHERE SC6.D_E_L_E_T_ = ' '                                  ")
    cQuery += CRLF + RTrim("            AND C6_FILIAL      = '" + SC5->C5_FILIAL + "'             ")
    cQuery += CRLF + RTrim("            AND C6_NUM         = '" + SC5->C5_NUM    + "' ) AS QTD_C6 ")
    cQuery += CRLF + RTrim("   FROM " + RETSQLNAME("SC9") + " SC9                                 ")
    cQuery += CRLF + RTrim("  WHERE SC9.D_E_L_E_T_ = ' '                                          ")
    cQuery += CRLF + RTrim("    AND C9_FILIAL  = '" + SC5->C5_FILIAL  + "'                        ")
    cQuery += CRLF + RTrim("    AND C9_PEDIDO  = '" + SC5->C5_NUM     + "'                        ")
    cQuery += CRLF + RTrim("    AND C9_CLIENTE = '" + SC5->C5_CLIENTE + "'                        ")
    cQuery += CRLF + RTrim("    AND C9_LOJA    = '" + SC5->C5_LOJACLI + "'                        ")
    
    cQuery := ChangeQuery(cQuery)
    
    dbUseArea(.T.,"TOPCONN",TCGenQry(,,(cQuery := /*ChangeQuery(*/cQuery/*)*/)),(cWa := GetNextAlias()),.T.,.T.)
     
    nQtdC6 := (cWa)->QTD_C6
    nQtdC9 := (cWa)->QTD_C9 
              
    If lRot1 .Or. lRot2 .Or. lRot3 
       
       If cAcao $ "ESTORNO*CANCELA" .Or. (Empty((cWa)->BLEST) .And. Empty((cWa)->BLCRED) .And. cAcao == "LIBERACAO") 
		    
			If Select("PR1") == 0
				DbSelectArea("PR1")
			Endif
			
			PR1->(dbSetOrder(2)) //PR1_FILIAL + PR1_ALIAS + PR1_CHAVE
			
			If PR1->(dbSeek(xFilial("PR1")+"SC5"+SC5->C5_FILIAL+SC5->C5_NUM))
				 
				If cAcao == "ESTORNO"
					
					RecLock("PR1",.F.)
					
						PR1->(dbDelete())
						
					PR1->(MsUnlock())
						
				Elseif cAcao == "CANCELA"
				
					If Select("SF3") == 0
						dbSelectArea("SF3")
					Endif
					
					SF3->(dbSetOrder(1)) //F3_FILIAL+DTOS(F3_ENTRADA)+F3_NFISCAL+F3_SERIE+F3_CLIEFOR+F3_LOJA+F3_CFO+STR(F3_ALIQICM,5,2)
					
					lGrvPR1 := .T.
					
					If SF3->(dbSeek(SF2->(F2_FILIAL+DTOS(F2_EMISSAO)+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA)))
						
						If Empty(SF3->F3_CODRET) //se transmitiu para Sefaz = "T"
							
							lGrvPR1 := .F.
							
						Endif
						
					Endif
					
					If lGrvPR1
						
						RecLock("PR1",.F.)
						
							PR1->(dbDelete())
							
						PR1->(MsUnlock())
						
				        lLockPR1 := !PR1->(dbSeek(xFilial("PR1")+"SF2"+SF2->(F2_FILIAL+DTOS(F2_EMISSAO)+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA)))
				        
						RecLock("PR1",lLockPR1)
						
							PR1->PR1_FILIAL := xFilial("PR1")
							PR1->PR1_ALIAS  := "SF2"
							PR1->PR1_RECNO  := SF2->(Recno())
							PR1->PR1_TIPREQ := "5"
							PR1->PR1_DATINT := Date()
							PR1->PR1_HRINT	:= Time()		
							PR1->PR1_STINT  := "P"
							PR1->PR1_OBSERV := SF2->F2_CHVNFE
							PR1->PR1_CHAVE  := SF2->(F2_FILIAL+DTOS(F2_EMISSAO)+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA)
							
						PR1->(MsUnlock())
					
					Endif
					
				Elseif cAcao == "LIBERACAO"
					
					If SC5->C5_TPFRETE == "C" //C=CIF
					
						RecLock("PR1",.F.)
							
							PR1->PR1_DATINT := Date()
							PR1->PR1_HRINT	:= Time()	
							PR1->PR1_TIPREQ := "1"
							PR1->PR1_STINT  := "P"
							PR1->PR1_OBSERV := "" 
							
						PR1->(MsUnlock())
					
					Endif
					
				Endif
		
			Else
				
				If cAcao == "LIBERACAO" 
					
					If SC5->C5_TPFRETE == "C" //C=CIF
					
						RecLock("PR1",.T.)
						
							PR1->PR1_FILIAL := xFilial("PR1")
							PR1->PR1_ALIAS  := "SC5"
							PR1->PR1_RECNO  := SC5->(Recno())
							PR1->PR1_TIPREQ := "1"
							PR1->PR1_DATINT := Date()
							PR1->PR1_HRINT	:= Time()		
							PR1->PR1_STINT  := "P"
							PR1->PR1_CHAVE  := SC5->(C5_FILIAL+C5_NUM)
							
						PR1->(MsUnlock())
						
					Endif
					
				Endif
		
			Endif
		
		Endif
		
	Endif
	
	dbSelectArea(cWa)
	dbCloseArea()
	
	RestArea(aArea)
	
Return(Nil)