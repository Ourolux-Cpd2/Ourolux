#include "Protheus.ch"
#include "Totvs.ch"
#include "Topconn.ch"
#include "TbiConn.ch"
#include "TbiCode.ch"
#include "rwmake.ch"

User Function WFRELEST()

Local cReg
Local cAliasQuery := GetNextAlias()
Local oProc
Local nCount := 0  

PREPARE ENVIRONMENT EMPRESA "01" FILIAL "01"  TABLES "SB1","SD3" MODULO "EST"

If Select("TRB") > 0
	DbSelectArea("TRB")
	TRB->(DbCloseArea())
EndIf

cReg := ChangeQuery(Query())
DbUseArea(.T.,"TOPCONN",TCGenQry(NIL,NIL,cReg),"TRB",.T.,.F.)

DbSelectArea("TRB")
TRB->(DbGoTop())

While TRB->(!EOF())
	TRB->( dbSkip() )
   	nCount++
EndDo

If nCount > 0
	
	CONOUT("nCount > 0")

	cSubject := "Relação de Transferência entre Armazéns"

	oProc:= TWFProcess():New( "WFRELEST", "Relação de Transferência entre Armazéns" )
	oProc:NewTask("Relação de Transferência entre Armazéns", "\workflow\WFRELEST.html")  // Html da mensagem

	oProc:oHtml:ValByName("DATA", DDATABASE) 
    
	TRB->(DbGoTop())
	
	While TRB->(!EOF())
		
			AAdd((oProc:oHtml:valbyname( "it.1" )), TRB->FILIAL)
			AAdd((oProc:oHtml:valbyname( "it.2" )), TRB->PRODUTO)
			AAdd((oProc:oHtml:valbyname( "it.3" )), Posicione("SB1",1,xFilial("SB1")+TRB->PRODUTO,"B1_DESC"))
			AAdd((oProc:oHtml:valbyname( "it.4" )), TRB->QUANTMOV)
			AAdd((oProc:oHtml:valbyname( "it.5" )), TRB->DOC)
			AAdd((oProc:oHtml:valbyname( "it.6" )), TRB->ARMSAI)		
			AAdd((oProc:oHtml:valbyname( "it.7" )), TRB->ARMENT)
			AAdd((oProc:oHtml:valbyname( "it.8" )), SToD(TRB->DATAMOV))
			AAdd((oProc:oHtml:valbyname( "it.9" )), TRB->USUARIO)
			AAdd((oProc:oHtml:valbyname( "it.10" )), TRB->HIST)

		TRB->(DbSkip())
		
	EndDo

	oProc:cBCC  := U_GrpEmail('WFTRANSF')

	oProc:csubject := cSubject

	oProc:start()      

	TRB->(DbCloseArea()) 
Else
	CONOUT("nCount == 0")
		
EndIf	

RESET ENVIRONMENT

Return    

Static Function Query()

Local aArea       := GetArea()
Local cQuery      := ""
Local cAliasQuery := GetNextAlias()

    cQuery := " SELECT "
	cQuery += "		GERAL.FILIAL, "
	cQuery += "		GERAL.DOC, " 
	cQuery += "		GERAL.PRODUTO, " 
	cQuery += "		GERAL.QUANTMOV, "  
	cQuery += "		GERAL.DATAMOV, " 
	cQuery += "		GERAL.USUARIO, " 
	cQuery += "		GERAL.NUMSEQ, " 
	cQuery += "		GERAL.ARMSAI, " 
	cQuery += "		GERAL.ARMENT, "
    cQuery += "		GERAL.HIST "
	cQuery += " FROM " 	
	cQuery += "		(SELECT " 
	cQuery += "			SD3.D3_FILIAL FILIAL, "
   	cQuery += "			SD3.D3_DOC DOC, "
	cQuery += "     	SD3.D3_COD PRODUTO, "
	cQuery += "      	SD3.D3_QUANT QUANTMOV, " 
	cQuery += "       	SD3.D3_EMISSAO DATAMOV, "
	cQuery += "         SD3.D3_USUARIO USUARIO, "
	cQuery += "         SD3.D3_NUMSEQ NUMSEQ, "
    cQuery += "         SD3.D3_HISTORI HIST, "
	cQuery += "         MAX(CASE WHEN SD3.D3_TM = '999' THEN SD3.D3_LOCAL END) ARMSAI, "
	cQuery += "         MAX(CASE WHEN SD3.D3_TM = '499' THEN SD3.D3_LOCAL END) ARMENT "
	cQuery += "		FROM "
	cQuery += 			RetSqlName("SD3") + " SD3 "
	cQuery += "		WHERE "
	cQuery += "			SD3.D_E_L_E_T_ = ' ' "
	cQuery += "			AND SD3.D3_ESTORNO <> 'S' "
	cQuery += "			AND SD3.D3_TM IN ('499','999') "
	cQuery += "			AND SD3.D3_CF IN ('DE4','RE4') "	
	cQuery += "			AND SD3.D3_EMISSAO ='"+DTOS(dDatabase)+"'
    //cQuery += "			AND SD3.D3_EMISSAO ='20190428'
	cQuery += "		GROUP BY " 
	cQuery += "			SD3.D3_FILIAL, "
	cQuery += "			SD3.D3_DOC, "
	cQuery += "			SD3.D3_COD, "
	cQuery += "			SD3.D3_QUANT, " 
	cQuery += "			SD3.D3_EMISSAO, " 
	cQuery += "			SD3.D3_USUARIO, "
    cQuery += "			SD3.D3_HISTORI,"
	cQuery += "			SD3.D3_NUMSEQ) GERAL "
	cQuery += " WHERE "
	cQuery += "		GERAL.ARMSAI = '01' AND" 
    cQuery += "		GERAL.ARMENT <> '01'"
    cQuery += " ORDER BY " 
	cQuery += "		GERAL.PRODUTO, "
	cQuery += "		GERAL.DATAMOV "

RestArea(aArea)

Return cQuery