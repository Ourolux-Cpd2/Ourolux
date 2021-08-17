#Include "Protheus.ch"
#Include "RwMake.ch"
#Include "TbiConn.ch"

//--------------------------------------------------------------------
/*/{Protheus.doc} EXCNFAUT
Execauto para geraÁ„o automatica da NF
@author Rodrigo Nunes
@since 31/03/2021
/*/
//--------------------------------------------------------------------

User Function NFDESAUT(ws_filial,ws_pedido,lWFJob)
	Local aCab := {}
	Local aItem := {}
	Local aItens := {}
	Local aItensRat := {}
	Local aCodRet := {}
	Local aParamAux := {}
	Local nOpc := 3
	Local cNum := ""
	Local nX := 0
	Local cQuery := ""
	Local cFunName    := ProcName(0)

	Conout("NFDESAUT - Inicio: " + Time())

	Private lMsErroAuto := .F.
	Private lMsHelpAuto := .T.

	Default lWFJob := .F.
	
    dbSelectArea("SC7")
	SC7->(dbSetOrder(1))
	SC7->(dbSeek(alltrim(ws_filial)+alltrim(ws_pedido)))

	While SC7->(!EOF()) .AND. Alltrim(SC7->C7_NUM) == Alltrim(ws_pedido)
		cQuery := " SELECT TOP(1) F1_DOC AS NUMERO FROM " + RetSqlName("SF1") 
		cQuery += " WHERE F1_SERIE = 'EIC' "
		cQuery += " AND D_E_L_E_T_ = '' "
		cQuery += " ORDER BY F1_DOC DESC "

		If Select("F1XX") > 0 
			F1XX->(dbCloseArea())
		EndIf
		
		Conout("NFDESAUT - Query busca NUMERO da NF (soma 1)")
		Conout(cQuery)
		

		DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery) , 'F1XX', .T., .F.)
		
		If F1XX->(!EOF())
			cNum := Alltrim(F1XX->NUMERO)
		EndIf

		If Empty(cNum)
			cNum := "000000001"
		Else
			cNum := SOMA1(cNum)
		EndIf
		//CabeÁalho
		aadd(aCab,{"F1_TIPO" 	,"N" 				,NIL})
		aadd(aCab,{"F1_FORMUL" 	,"N" 				,NIL})
		aadd(aCab,{"F1_DOC" 	,cNum 				,NIL})
		aadd(aCab,{"F1_SERIE" 	,"EIC" 				,NIL})
		aadd(aCab,{"F1_EMISSAO" ,DDATABASE 			,NIL})
		aadd(aCab,{"F1_DTDIGIT" ,DDATABASE 			,NIL})
		aadd(aCab,{"F1_FORNECE" ,SC7->C7_FORNECE 	,NIL})
		aadd(aCab,{"F1_LOJA" 	,SC7->C7_LOJA 		,NIL})
		aadd(aCab,{"F1_ESPECIE" ,"NF " 				,NIL})  
		aadd(aCab,{"F1_COND" 	,SC7->C7_COND		,NIL})
		aadd(aCab,{"F1_DESPESA" , 0 				,NIL})
		aadd(aCab,{"F1_DESCONT" , 0 				,Nil})
		aadd(aCab,{"F1_SEGURO" 	, 0 				,Nil})
		aadd(aCab,{"F1_FRETE" 	, 0 				,Nil})
		aadd(aCab,{"F1_MOEDA" 	, 1 				,Nil})
		aadd(aCab,{"F1_TXMOEDA" , 1 				,Nil})
		aadd(aCab,{"F1_STATUS" 	, "A" 				,Nil})

		//Itens
		//While SC7->(!EOF()) .AND. Alltrim(SC7->C7_NUM) == Alltrim(ws_pedido)
        aItem := {}
        nX++
        aadd(aItem,{"D1_ITEM" 	,StrZero(nX,4) ,NIL})
        aadd(aItem,{"D1_COD" 	,PadR(SC7->C7_PRODUTO,TamSx3("D1_COD")[1]) ,NIL})
        aadd(aItem,{"D1_UM" 	,SC7->C7_UM ,NIL})
        aadd(aItem,{"D1_LOCAL" 	,SC7->C7_LOCAL ,NIL})
        aadd(aItem,{"D1_QUANT" 	,SC7->C7_QUANT ,NIL})
        aadd(aItem,{"D1_VUNIT" 	,SC7->C7_PRECO ,NIL})
        aadd(aItem,{"D1_TOTAL" 	,SC7->C7_TOTAL ,NIL})
        aadd(aItem,{"D1_TES"   	,"059" ,NIL}) //TES INFORMADA PELO GILMAR NO DIA 25/03/2021 VIA E-MAIL
        aadd(aItens,aItem)
        aadd(aItens[Len(aItens)], {'D1_PEDIDO ', SC7->C7_NUM ,}) // N˙mero do Pedido de Compras
        aadd(aItens[Len(aItens)], {'D1_ITEMPC ', SC7->C7_ITEM ,}) // Item do Pedido de Compras

        //if(nOpc == 4)//Se for classificaÁ„o deve informar a vari·vel LINPOS
		//		aAdd(aItem, {"LINPOS" , "D1_ITEM",  StrZero(nX,4)}) //ou SD1->D1_ITEM  se estiver posicionado.
		//	endIf

		MSExecAuto({|x,y,z,k,a,b| MATA103(x,y,z,,,,k,a,,,b)},aCab,aItens,nOpc,aParamAux,aItensRat,aCodRet)

		If !lMsErroAuto
			ConOut("NFDESAUT - Incluido NF: " + cNum)
		Else
			If !lWFJob
				cDirArq := "\"
				cNomArq := "\"+cFunName+"-"+DToS(Date())+"-"+StrTran(Time(),":","")+".log"
				cErro := VerErro(MostraErro(cDirArq,cNomArq),cDirArq,cNomArq)
										
				FErase(cDirArq+cNomArq) 
                        
				ProcLogAtu("ERRO","NFDESAUT - Nota fiscal n„o incluida - Filial " + Alltrim(ws_filial) + "-" + Alltrim(ws_pedido), cErro, "EICDESPESA" )

				Alert(cErro)
			Else
				cDirArq := "\"
				cNomArq := "\"+cFunName+"-"+DToS(Date())+"-"+StrTran(Time(),":","")+".log"
				cErro := VerErro(MostraErro(cDirArq,cNomArq),cDirArq,cNomArq)
										
				FErase(cDirArq+cNomArq) 
			                            
				ProcLogAtu("ERRO","NFDESAUT - Nota fiscal n„o incluida - Filial " + Alltrim(ws_filial) + "-" + Alltrim(ws_pedido), cErro, "EICDESPESA" )
			EndIf
			ConOut("NFDESAUT - Erro na inclusao!")
		EndIf

		aItens := {}
		aCab   := {}
		nX     := 0
		
		SC7->(dbSkip())

	EndDo

	ConOut("NFDESAUT - Fim: " + Time())

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} VerErro
Formata log obtido do retorno de ExecAuto
@author Rodrigo Nunes
@since 12/05/2021
@version 1.0
@return cErrRet, characters, erro ExecAuto formatado
@param cErroAuto, characters, erro ExecAuto n√£o formatado
@type function
/*/
//-------------------------------------------------------------------

Static Function VerErro(cErroAuto,cDirArq,cNomArq)

Local nLines      := MLCount(cErroAuto)
Local nErr        := 0
Local cErrRet     := ""
Local cConteudo   := "" 

Default cErroAuto := ""
Default cDirArq   := ""
Default cNomArq   := ""

	For nErr := 1 To nLines
	
		cConteudo := MemoLine(cErroAuto,,nErr)
		
		cErrRet += " " + cConteudo
		
		If Empty(cConteudo)
		
			Exit
			
		Endif
		
	Next 
	
	For nErr := 1 To nLines
		
		cConteudo := MemoLine(cErroAuto,,nErr)
		
		If At("< --",cConteudo) > 0
			
			cErrRet += " " + cConteudo
			
			Exit
			
		Endif
	
	Next
	
	While At("  ",cErrRet) > 0
	
		cErrRet := StrTran(cErrRet,"  "," ")
		
	EndDo
	
Return(AllTrim(cErrRet)) 
