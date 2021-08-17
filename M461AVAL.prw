#include 'protheus.ch'
#include 'parmtype.ch'

//--------------------------------------------------------------------
/*/{Protheus.doc} M461AVAL
Ponto de entrada para nova condição, com o objetivo de manipular a 
disponibilidade da carga para fatura. Manipula Carga para Fatura.
Retorno: .T. = faturamento da carga
         .F. = não faturamento na carga
Eventos
@author Caio
@since 17/02/2020
@version 1.0
@type function
/*/
//--------------------------------------------------------------------

User function M461AVAL()
	
Local aArea    := GetArea()
Local aParam   := PARAMIXB
Local lRet     := aParam[1]
Local cQuery   := ""
Local cWa      := ""
Local cAlert   := "" 
	
	If GetMV("M4_61AVAL1",,.F.) //parâmetro para desabilitar customização
		
		cQuery += CRLF + RTrim(" SELECT DISTINCT C9_FILIAL AS FILIAL, C9_PEDIDO AS PEDIDO                             ")
		cQuery += CRLF + RTrim("   FROM " + RetSqlName("SC9") + " SC9                                                 ")
		cQuery += CRLF + RTrim("  INNER JOIN " + RetSqlName("PR1") + " PR1 ON PR1.D_E_L_E_T_ = ' '                    ")
		cQuery += CRLF + RTrim("                                          AND PR1_ALIAS     IN ('SA4','SC5')          ")
		cQuery += CRLF + RTrim("                                          AND PR1_CHAVE      = C9_FILIAL || C9_PEDIDO ")
		cQuery += CRLF + RTrim("                                          AND PR1_STINT      = 'P'                    ")
		cQuery += CRLF + RTrim("  WHERE SC9.D_E_L_E_T_ = ' '                                                          ")
		cQuery += CRLF + RTrim("    AND SC9.C9_FILIAL  = '" + DAK->DAK_FILIAL + "'                                    ")
		cQuery += CRLF + RTrim("    AND SC9.C9_CARGA   = '" + DAK->DAK_COD    + "'                                    ")
		
		cQuery := ChangeQuery(cQuery)
		
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),(cWa := GetNextAlias()),.T.,.T.)
		
		While (cWa)->(!Eof())
			
			If Select("SC5") == 0
				dbSelectArea("SC5")
			Endif
			
			SC5->(dbSetOrder(1))
			
			cSeek := (cWa)->FILIAL + (cWa)->PEDIDO
			
			If SC5->(GetAdvFVal("SC5","C5_TPFRETE",cSeek)) == "C"
			
				cAlert += CRLF + (cWa)->FILIAL + "/" + (cWa)->PEDIDO
				
			Endif
			
			(cWa)->(DbSkip())
			
		EndDo
		
		dbCloseArea()
		
		If !Empty(cAlert)
			
			lRet := .F.
			
			cAlert := "Não é possível prosseguir com a geração da carga " + DAK->DAK_FILIAL + "/" + DAK->DAK_COD + "," + CRLF + ;
			          "pois os pedidos abaixo possuem pendência de integração com a Transpofrete." + CRLF +  cAlert
			        
			If IsInCallStack("DOUBLECLICK") .And. IsInCallStack("GETCOLUMNDATA") .And. IsInCallStack("BDATAMARK") 
			
				MsgStop(cAlert,"M461AVAL")
				
			Endif
			 
		Endif  
		
	Endif
	
	RestArea(aArea)
	
Return(lRet)