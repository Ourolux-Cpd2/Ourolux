#Include "Protheus.ch"

//Programa para ser utilizado por schedulle, para atualização das tabelas do CCB
User Function SEFINA04(_cEmp, _cFil)

	Local _cAlias    := GetNextAlias()
	Local _cQuery    := ""
	Local cCNPJ 	 := ""
	
	Default _cFil := "01"   
	Default _cEmp := "01"

	RpcSetEnv(_cEmp, _cFil)
	
	cCNPJ := SuperGetMv("SE_CNPJCLI", .F.)
	
	_cQuery += " Select A1_COD, A1_LOJA, A1_CGC From " + RetSqlTab("SA1")
	_cQuery += " Where " + RetSqlCond("SA1")
	_cQuery += " And NVL((Select Max(ZA1_DATA) From " + RetSqlTab("ZA1") + " Where " 
	_cQuery += RetSqlCond("ZA1") + " AND ZA1_CLIENT = A1_COD And ZA1_LOJA = A1_LOJA), '') <= '" + dToS(DATE()-7) + "' "
	_cQuery += " And A1_PESSOA = 'J' " 						  //Apenas pessoas jurídicas
	_cQuery += " And A1_MSBLQL = '2' " 						 //Apenas clientes liberados
	_cQuery += " And A1_VEND Not In ('001004', '001005') " //Cliente não pode estar com vendedor inativo
	_cQuery += " And A1_CGC Not In (" + cCNPJ + ") " //Cliente não pode ser interno
	_cQuery += " And ROWNUM <= 3500 " //Pega apenas os primeiros 3000 registros, para não dar estouro na memória
	
	If SA1->(FieldPos("A1_CCCB")) > 0
		_cQuery += " And A1_CCCB <> 'N'  " //Apenas clientes que consideram CCB
	EndIf
	
	If SA1->(FieldPos("A1_DTCCB")) > 0
		_cQuery += " And A1_DTCCB < '" + dToS(DATE()) + "' " //Apenas clientes que não tiveram atualização no dia
	EndIf
	
	_cQuery := ChangeQuery(_cQuery)
	
	DbUseArea(.T., "TOPCONN", TCGenQry(,,_cQuery),_cAlias, .T., .F.)
	
	While (_cAlias)->(!EoF())
	
		DbSelectArea("SA1")
		DbSetOrder(1)
		DbGoTop()
		DbSeek(xFilial("SA1")+(_cAlias)->(A1_COD+A1_LOJA))
		
		StartJob("U_SEFIN01",GetEnvServer(), .F., (_cAlias)->A1_COD, (_cAlias)->A1_LOJA, .T., _cEmp, _cFil)
	
		(_cAlias)->(DbSkip())
	
	EndDo
	
	(_cAlias)->(DbCloseArea())
	
	RpcClearEnv()

Return

//REVISAO 000 - FABRICIO EDUARDO RECHE - 06/10/2014 - Cricao