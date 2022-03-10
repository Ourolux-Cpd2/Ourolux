#include 'protheus.ch'
#include 'parmtype.ch'

//--------------------------------------------------------------------
/*/{Protheus.doc} FTOUA021
Integração de notas de saida.
@author Ghidini Consulting
@since 05/05/2021
@version 1.0
/*/
//--------------------------------------------------------------------

User Function TESTE021()

	U_FTOUA021(.F.,.F.,"","","01","06")
	
Return(Nil)

User Function FTOUA021(lReprocess, lLote, cIdReg, cIdPZC, cEmpPrep, cFilPrep)

Local nX
Local cXml      := ""
Local cJson     := ""
Local aGrupos   := {}
Local aHeader   := {"Content-Type: application/json"}
Local cQuery    := ""
Local cAlsQry   := CriaTrab(Nil,.F.)
Local aEmpTss   := {}

Default lLote		:= .F.
Default lReprocess	:= .F.
Default cIdReg		:= ""
Default cIdPZC		:= ""	

    RpcClearEnv()
    RpcSetEnv(cEmpPrep,cFilPrep)

    aEmpTss := hgstst()
    
    cQuery := " SELECT F2_FILIAL, F2_DOC, F2_SERIE, F2_CLIENTE, F2_LOJA, F2_EMISSAO, F3_CHVNFE, PR1.R_E_C_N_O_ RECPR1 "
    cQuery += " FROM " + RetSqlName("SF2") + " SF2 "
    cQuery += " INNER JOIN " + RetSqlName("PR1") + " PR1 "
    cQuery += " ON PR1_CHAVE = F2_FILIAL+F2_DOC+F2_SERIE "
    cQuery += " INNER JOIN " + RetSqlName("SF3") + " SF3 "
    cQuery += " ON F3_FILIAL = F2_FILIAL AND F3_NFISCAL = F2_DOC AND F3_SERIE = F2_SERIE "
    cQuery += " WHERE PR1_ALIAS = 'SF2' AND PR1_STINT = 'P' AND PR1_TIPREQ = '1' AND SF2.D_E_L_E_T_ = ' ' AND PR1.D_E_L_E_T_ = ' ' AND SF2.D_E_L_E_T_ = ' ' "

    If Select(cAlsQry) > 0; (cAlsQry)->(dbCloseArea()); Endif
    dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlsQry,.T.,.T.)
    
    If !(cAlsQry)->(Eof())
    
        //Requisição do acesso
	    cToken := U_ChkToken("1")

        DbSelectArea("PR1")
        
        If Empty(cToken)
            
            Conout("Falha na autenticação Transpofrete")

            aCriaServ := U_MonitRes("000020", 1, 0)
            cIdPZB 	  := aCriaServ[2]

            //Finaliza o processo na PZB
            U_MonitRes("000020", 3, , cIdPZB, , .F.)
            
        Else

            nTot := Contar(cAlsQry,"!Eof()") 
            
            aCriaServ := U_MonitRes("000020", 1, nTot)
            cIdPZB 	  := aCriaServ[2]

            (cAlsQry)->(DbGoTop())

            While !(cAlsQry)->(Eof())    

                If cFilAnt <> (cAlsQry)->F2_FILIAL
                    cFilAnt := (cAlsQry)->F2_FILIAL
                EndIf
                
                cXml := BuscaXML((cAlsQry)->F2_DOC, (cAlsQry)->F2_SERIE, (cAlsQry)->F2_CLIENTE, (cAlsQry)->F2_LOJA, StoD((cAlsQry)->F2_EMISSAO), aEmpTss)

                If !Empty(cXml)

                    //se não tiver chave aborta o processo
                    If Empty( (cAlsQry)->F3_CHVNFE )

                        U_MonitRes("000020",2,,cIdPZB,"Documento não transmitido, não possui chave de autorização ainda.",.F., (cAlsQry)->F2_DOC, cJson, "",(cAlsQry)->F2_DOC, lReprocess, lLote, cIdPZC)

                        (cAlsQry)->(DbSkip())
                        Loop
                    
                    EndIf

                    oXml := XmlParser(cXml, "_", "!!", "!")

                    //Posiciona filial
                    aEmpSm0   := FwLoadSM0()

                    nPosEmp := aScan(aEmpSm0,{|x| Alltrim(x[18]) == oXml:_nfe:_infNFe:_emit:_cnpj:text})

                    //Verifica se a NF ja existe no transpo
                    cJsAux := '{'
                    cJsAux += '"notas": ['
                    cJsAux += '{'
                    cJsAux += '"numeroNota":"' + cValToChar(Val((cAlsQry)->F2_DOC)) + '",' 
                    cJsAux += '"serieNota":"' + Alltrim((cAlsQry)->F2_SERIE) + '",'
                    cJsAux += '"cnpjEmissor":"' + aEmpSm0[nPosEmp][18] + '"'
                    cJsAux += '}]}'
                    
                    aRequest := U_ResInteg("000021", cJsAux, aHeader, , .T.,cToken )

                    If aRequest[2]:STATUS == "ERRO"

                         U_MonitRes("000020",2,,cIdPZB,"Documento não foi importado no transpo ainda.",.F., (cAlsQry)->F2_DOC, "", "",(cAlsQry)->F2_DOC, lReprocess, lLote, cIdPZC)

                        (cAlsQry)->(DbSkip())
                        Loop
                    
                    EndIf

                    If nPosEmp == 0
                        cTeste := ""
                    ElseIf cFilAnt <> aEmpSm0[nPosEmp][2]
                        cFilAnt := aEmpSm0[nPosEmp][2]
                    EndIf
                        
                    cJson := '{'
                    cJson += '"numero":"' + oXml:_nfe:_infNFe:_ide:_nNF:text + '",'
                    cJson += '"cnpjUnidade":"'+ oXml:_nfe:_infNFe:_emit:_cnpj:text + '",'
                    cJson += '"serie": "'+ oXml:_nfe:_infNFe:_ide:_serie:text + '",'
                    cJson += '"chaveAcesso": "'+ (cAlsQry)->F3_CHVNFE + '",'
                    cJson += '"emitente": {
                    cJson += '"cnpj": "'+ oXml:_nfe:_infNFe:_emit:_cnpj:text + '",'
                    cJson += '"nome": "'+ oXml:_nfe:_infNFe:_emit:_xNome:text + '",'
                    cJson += '"fantasia": "'+ oXml:_nfe:_infNFe:_emit:_xFant:text + '",'
                    cJson += '"inscricaoEstadual": "'+ oXml:_nfe:_infNFe:_emit:_ie:text + '",'
                    cJson += '"logradouro": "'+ oXml:_nfe:_infNFe:_emit:_enderEmit:_xlgr:text + '",'
                    cJson += '"numero": "'+ oXml:_nfe:_infNFe:_emit:_enderEmit:_nro:text + '",'
                    cJson += '"bairro": "'+ oXml:_nfe:_infNFe:_emit:_enderEmit:_xBairro:text + '",'
                    cJson += '"codigoMunicipio": '+ oXml:_nfe:_infNFe:_emit:_enderEmit:_cmun:text + ','
                    cJson += '"cep":"'+ oXml:_nfe:_infNFe:_emit:_enderEmit:_cep:text + '",'
                    cJson += '"fone": "'+ oXml:_nfe:_infNFe:_emit:_enderEmit:_fone:text + '"'
                    cJson += '},
                    cJson += '"destinatario": {
                    
                    If AttIsMemberOf(oXml:_nfe:_infNFe:_dest,"_cnpj")
                        cJson += '"cnpj": "'+ oXml:_nfe:_infNFe:_dest:_cnpj:text + '",'
                        lCnpj := .T.
                    Else
                        cJson += '"cnpj": "'+ oXml:_nfe:_infNFe:_dest:_cpf:text + '",'
                        lCnpj := .F.
                    EndIf
                    
                    cJson += '"nome": "'+ oXml:_nfe:_infNFe:_dest:_xNome:text + '",'
                    
                    If lCnpj .and. AttIsMemberOf(oXml:_nfe:_infNFe:_dest,"_ie") == .T.
                        cJson += '"inscricaoEstadual": "' + oXml:_nfe:_infNFe:_dest:_ie:text + '",'
                    EndIf
                    
                    If AttIsMemberOf(oXml:_nfe:_infNFe:_dest,"_email")
                        cJson += '"email": "'+ oXml:_nfe:_infNFe:_dest:_email:text + '",'
                    endif
                    //cJson += '    "idEstrangeiro": "",
                    cJson += '"logradouro": "'+ oXml:_nfe:_infNFe:_dest:_enderDest:_xlgr:text + '",'
                    cJson += '"numero": "'+ oXml:_nfe:_infNFe:_dest:_enderDest:_nro:text + '",'
                    cJson += '"bairro": "'+ oXml:_nfe:_infNFe:_dest:_enderDest:_xBairro:text + '",'
                    //cJson += '    "codigoMunicipio": ' + oXml:_nfe:_infNFe:_emit:_enderDest:_xlgr:text + ','
                    cJson += '"cep":"' + oXml:_nfe:_infNFe:_dest:_enderDest:_cep:text + '"'
                    //cJson += '    "fone": "4040404040"
                    cJson += '},
                    
                    cJson += '"itens": ['
                    
                    If ValType(oXml:_nfe:_infNFe:_det) == "A"
                    
                        For nX := 1 to len(oXml:_nfe:_infNFe:_det)
                        
                            cJson += '{'
                            cJson += '"cfop": "' + oXml:_nfe:_infNFe:_det[nX]:_Prod:_cfop:text + '", '
                            cJson += '"produto": "' + oXml:_nfe:_infNFe:_det[nX]:_Prod:_cProd:text + '", '
                            cJson += '"quantidade":' + oXml:_nfe:_infNFe:_det[nX]:_Prod:_qCom:text + ', '
                            cJson += '"peso": 0.0,'
                            cJson += '"pesoCubado": 0.0,'
                            cJson += '"cubagem": 0.0,'
                            cJson += '"volumes": 0,'
                            cJson += '"valor": ' + oXml:_nfe:_infNFe:_det[nX]:_Prod:_vProd:text
                            cJson += '},'
                            
                        Next nX

                    Else

                        cJson += '{'
                        cJson += '"cfop": "' + oXml:_nfe:_infNFe:_det:_Prod:_cfop:text + '", '
                        cJson += '"produto": "' + oXml:_nfe:_infNFe:_det:_Prod:_cProd:text + '", '
                        cJson += '"quantidade":' + oXml:_nfe:_infNFe:_det:_Prod:_qCom:text + ', '
                        cJson += '"peso": 0.0,'
                        cJson += '"pesoCubado": 0.0,'
                        cJson += '"cubagem": 0.0,'
                        cJson += '"volumes": 0,'
                        cJson += '"valor": ' + oXml:_nfe:_infNFe:_det:_Prod:_vProd:text
                        cJson += '},'

                    EndIf

                    cJson := Left(cJson, Rat(",", cJson) - 1)

                    cJson += '],'

                    //Numero do documento
                    cDoc := StrZero(Val(oXml:_nfe:_infNFe:_ide:_nNF:text),9)

                    //Alias para query dos gruops
                    cAlsGrp := CriaTrab(Nil,.F.)
                    
                    //Query para montar os grupos
                    cQuery := " SELECT SUM(D2_TOTAL) TOTAL, SUM(D2_PESO) PESO, B1_GRUPO, C5_NUM "
                    cQuery += " FROM " + RetSqlName("SD2") + " SD2 "
                    cQuery += " INNER JOIN " + RetSqlName("SC5") + " SC5 "
                    cQuery += " ON C5_FILIAL = D2_FILIAL AND C5_NUM = D2_PEDIDO "
                    cQuery += " INNER JOIN " + RetSqlName("SB1") + " SB1 "
                    cQuery += " ON B1_FILIAL= '" + xFilial("SB1") + "' AND B1_COD = D2_COD "
                    cQuery += " WHERE D2_FILIAL = '" + cFilAnt + "' AND D2_DOC = '" + cDoc + "' AND "
                    cQuery += " D2_SERIE = '" + oXml:_nfe:_infNFe:_ide:_serie:text + "' AND SD2.D_E_L_E_T_ = ' ' AND SB1.D_E_L_E_T_ = ' ' AND SC5.D_E_L_E_T_ = ' ' "
                    cQuery += " GROUP BY B1_GRUPO, C5_NUM "

                    If Select(cAlsGrp) > 0; (cAlsGrp)->(dbCloseArea()); Endif  
                    dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlsGrp,.T.,.T.) 

                    //Emissao
                    cEmissao    := Left( oXml:_nfe:_infNFe:_ide:_dhEmi:text,10)
                    cHora       := Substr( oXml:_nfe:_infNFe:_ide:_dhEmi:text, 12,5) + ":00"

                    //Pedido para cubagem
                    cJson += '"preNotaFiscal": {
                    cJson += '"numero": "' + (cAlsGrp)->C5_NUM + '",'
                    cJson += '"serie": "2" '
                    cJson += '},
                    //cJson += '    "cfop": ' + oXml:_nfe:_infNFe:_det[nX]:_Prod:_cfop:text + '", '
                    //cJson += '"observacao": "Atualização documento de saída.",
                    cJson += '"observacao":"' + oXml:_nfe:_infNFe:_infAdic:_infCpl:text + '",'
                    cJson += '"dataEmissao":"' + cEmissao + " " + cHora + '",'
                    cJson += '"modalidadeFrete": ' + oXml:_nfe:_infNFe:_transp:_modFrete:text + ','
                    
                    If ValType(oXml:_nfe:_infNFe:_det) == "A"
                        cJson += '"cfop": ' + oXml:_nfe:_infNFe:_det[1]:_Prod:_cfop:text + ', '
                    Else
                        cJson += '"cfop": ' + oXml:_nfe:_infNFe:_det:_Prod:_cfop:text + ', '
                    EndIf

                    cJson += '"naturezaOperacao": "' + oXml:_nfe:_infNFe:_ide:_natOp:text + '",'
                    cJson += '"tipoOperacao": "1", '

                    cJson += '"enderecoRetirada": {
                    cJson += '"logradouro": "'+ oXml:_nfe:_infNFe:_emit:_enderEmit:_xlgr:text + '",'
                    cJson += '"numero": "'+ oXml:_nfe:_infNFe:_emit:_enderEmit:_nro:text + '",'
                    cJson += '"bairro": "'+ oXml:_nfe:_infNFe:_emit:_enderEmit:_xBairro:text + '",'
                    cJson += '"ibge": '+ oXml:_nfe:_infNFe:_emit:_enderEmit:_cmun:text + ','
                    cJson += '"cep":"'+ oXml:_nfe:_infNFe:_emit:_enderEmit:_cep:text + '",'
                    cJson += '"uf": "'+ oXml:_nfe:_infNFe:_emit:_enderEmit:_uf:text + '",'
                    cJson += '"complemento": ""'
                    
                    cJson += '},
                    cJson += '"enderecoEntrega": {
                    cJson += '"logradouro": "'+ oXml:_nfe:_infNFe:_dest:_enderDest:_xlgr:text + '",'
                    cJson += '"numero": "'+ oXml:_nfe:_infNFe:_dest:_enderDest:_nro:text + '",'
                    cJson += '"bairro": "'+ oXml:_nfe:_infNFe:_dest:_enderDest:_xBairro:text + '",'
                    cJson += '"ibge": ' + oXml:_nfe:_infNFe:_dest:_enderDest:_cMun:text + ','
                    cJson += '"cep":"' + oXml:_nfe:_infNFe:_dest:_enderDest:_cep:text + '",'
                    cJson += '"uf":"' + oXml:_nfe:_infNFe:_dest:_enderDest:_uf:text + '"'
                    
                    If AttIsMemberOf(oXml:_nfe:_infNFe:_dest:_enderDest,"_xCpl")
                        cJson += ',"complemento":"' + oXml:_nfe:_infNFe:_dest:_enderDest:_xCpl:text + '"'
                    EndIf

                    cJson += '},'

                    
                    //Tratativa para os grupos
                    cGrupos := ""
                    nCount  := 1
                    nTamMax := 4000
                    nPeso   := 0

                    While !(cAlsGrp)->(Eof())

                        cGrupos += (cAlsGrp)->B1_GRUPO + "-" + cValToChar((cAlsGrp)->TOTAL) + "-" + cValToChar((cAlsGrp)->PESO) + "|"

                        nPeso += (cAlsGrp)->PESO
                        
                        (cAlsGrp)->(DbSkip())

                        //Verifica o tamanho da string para quebra
                        If Len(cGrupos) > nTamMax .Or. (cAlsGrp)->(Eof())
                            AADD(aGrupos, {"GRUPO" + cValToChar(nCount), cGrupos})
                            nCount++
                            nTamMax += 4000
                        EndIf

                    End

                    (cAlsGrp)->(dbCloseArea())

                    cJson += '"volumes": ' + oXml:_nfe:_infNFe:_TRANSP:_vol:_qVol:text + ','
                    
                    If AttIsMemberOf(oXml:_nfe:_infNFe:_TRANSP:_vol, "_pesoL")
                        cJson += '"pesoLiquido": ' + oXml:_nfe:_infNFe:_TRANSP:_vol:_pesoL:text + ','
                    Else
                        cJson += '"pesoLiquido": 0,'
                    EndIf                    
                    
                    cJson += '"valor": ' + oXml:_nfe:_infNFe:_total:_icmstot:_vnf:text + ','
                    cJson += '"valorICMSSt": ' + oXml:_nfe:_infNFe:_total:_icmstot:_vst:text + ','
                    
                    If AttIsMemberOf(oXml:_nfe:_infNFe:_TRANSP:_vol, "_pesoB")
                        cJson += '"peso": ' + oXml:_nfe:_infNFe:_TRANSP:_vol:_pesoB:text + ','
                    else
                        cJson += '"peso": 0,'
                    endif
                    cJson += '"informacoesContribuinte": ['

                    //Estrutura os grupos
                    For nX := 1 to len(aGrupos)

                        cJson += '{'
                        cJson += '"' + aGrupos[nX,1] + '":"'+ aGrupos[nX,2] + '" '
                        cJson += '},'
                        
                    Next nX

                    cJson := Left(cJson, Rat(",", cJson) - 1)

                    cJson += ']'    

                    cJson += '}'

                    aRequest := U_ResInteg("000020", cJson, aHeader, , .T.,cToken )

                    If aRequest[1]

                        If aRequest[2]:STATUS == "ERRO"
                            U_MonitRes("000020",2,,cIdPZB,"Erro ao incluir.",.F., (cAlsQry)->F2_DOC, cJson, aRequest[3],(cAlsQry)->F2_DOC, lReprocess, lLote, cIdPZC)
                        Else
                            U_MonitRes("000020",2,,cIdPZB,"Incluso com sucesso,",.T., (cAlsQry)->F2_DOC ,cJson, aRequest[3],(cAlsQry)->F2_DOC, lReprocess, lLote, cIdPZC)

                            PR1->(DbGoTo((cAlsQry)->RECPR1))

                            PR1->(RecLock("PR1",.F.))

                                PR1->PR1_STINT  := "I"
                                PR1->PR1_DATINT := Date()
                                PR1->PR1_HRINT	:= Time()		 
                                PR1->PR1_OBSERV	:= (cAlsQry)->F3_CHVNFE

                            PR1->(MsUnlock())

                        EndIf

                    Else
                        U_MonitRes("000020",2,,cIdPZB,"Erro ao incluir.",.F., (cAlsQry)->F2_DOC, cJson, aRequest[3],(cAlsQry)->F2_DOC, lReprocess, lLote, cIdPZC)
                    EndIf

                Else
                    U_MonitRes("000020",2,,cIdPZB,"Erro ao abrir XML.",.F., (cAlsQry)->F2_DOC,cJson, "",(cAlsQry)->F2_DOC, lReprocess, lLote, cIdPZC)
                EndIf
                
                (cAlsQry)->(DbSkip())
            
            End

            //Finaliza o processo na PZB
            U_MonitRes("000020", 3, , cIdPZB, , .T.)

        EndIf

    EndIf

    (cAlsQry)->(dbCloseArea())

Return()

//--------------------------------------------------------------------
/*/{Protheus.doc} BuscaXML
Função para gerar o arquivo xml
@author Ghidini Consulting
@since 05/05/2021
@version 1.0
/*/
//--------------------------------------------------------------------

Static Function BuscaXML(cDocumento, cSerie, cCliente, cLoja, dEmissao, aEntid)

Local cXML	    := ""
Local aNota	    := {}
Local aXml	    := {}
Local cAviso    := ""
Local cErro	    := ""
Local cAnexo    := ""
Local cIdEnt    := ""
Local cModalidade
Local oNFe

    nPosEnt := aScan(aEntid, {|x| Alltrim(x[1] + x[2]) == cEmpAnt + cFilAnt})

    If nPosEnt == 0
        Return("")
    EndIf

    cIdEnt := aEntid[nPosEnt][3]

	aadd(aNota,{})
	aadd(Atail(aNota),.F.)
	aadd(Atail(aNota),"S")
	aadd(Atail(aNota),dEmissao)
	aadd(Atail(aNota),cSerie)
	aadd(Atail(aNota),cDocumento)
	aadd(Atail(aNota),cCliente)
	aadd(Atail(aNota),cLoja)

	aXml := StaticCall(DanfeII,GetXml, cIdEnt,aNota,@cModalidade)

	If Len(aXML) <= 0
		Return
	Endif

	cXML := aXML[1][2]

	oNFe := XmlParser(cXML,"_",@cErro,@cAviso)

	nHdlXml   := FCreate(cAnexo,0)

	If nHdlXml > 0
		FWrite(nHdlXml,cXML)
		FClose(nHdlXml)
	Endif	

Return cXML


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³GetIdEnt   ³Autor ³ Felipi Marques         |Data ³ 14/08/14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Obtem o codigo da entidade apos enviar o post para o Totvs  ³±±
±±³          ³Service                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpC1: Codigo da entidade no Totvs Services                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function hgstst()

Local aArea     := GetArea()
Local cIdEnt    := ""
Local cURL      := PadR(GetNewPar("MV_SPEDURL","http://"),250)
Local oWs
Local aEntid    := {}

    SM0->(DbGoTop())

    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
    //³Obtem o codigo da entidade                                              ³
    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    oWS := WsSPEDAdm():New()
    oWS:cUSERTOKEN := "TOTVS"

    While !SM0->(Eof())
	
        oWS:oWSEMPRESA:cCNPJ       := IIF(SM0->M0_TPINSC==2 .Or. Empty(SM0->M0_TPINSC),SM0->M0_CGC,"")	
        oWS:oWSEMPRESA:cCPF        := IIF(SM0->M0_TPINSC==3,SM0->M0_CGC,"")
        oWS:oWSEMPRESA:cIE         := SM0->M0_INSC
        oWS:oWSEMPRESA:cIM         := SM0->M0_INSCM		
        oWS:oWSEMPRESA:cNOME       := SM0->M0_NOMECOM
        oWS:oWSEMPRESA:cFANTASIA   := SM0->M0_NOME
        oWS:oWSEMPRESA:cENDERECO   := FisGetEnd(SM0->M0_ENDENT)[1]
        oWS:oWSEMPRESA:cNUM        := FisGetEnd(SM0->M0_ENDENT)[3]
        oWS:oWSEMPRESA:cCOMPL      := FisGetEnd(SM0->M0_ENDENT)[4]
        oWS:oWSEMPRESA:cUF         := SM0->M0_ESTENT
        oWS:oWSEMPRESA:cCEP        := SM0->M0_CEPENT
        oWS:oWSEMPRESA:cCOD_MUN    := SM0->M0_CODMUN
        oWS:oWSEMPRESA:cCOD_PAIS   := "1058"
        oWS:oWSEMPRESA:cBAIRRO     := SM0->M0_BAIRENT
        oWS:oWSEMPRESA:cMUN        := SM0->M0_CIDENT
        oWS:oWSEMPRESA:cCEP_CP     := Nil
        oWS:oWSEMPRESA:cCP         := Nil
        oWS:oWSEMPRESA:cDDD        := Str(FisGetTel(SM0->M0_TEL)[2],3)
        oWS:oWSEMPRESA:cFONE       := AllTrim(Str(FisGetTel(SM0->M0_TEL)[3],15))
        oWS:oWSEMPRESA:cFAX        := AllTrim(Str(FisGetTel(SM0->M0_FAX)[3],15))
        oWS:oWSEMPRESA:cEMAIL      := UsrRetMail(RetCodUsr())
        oWS:oWSEMPRESA:cNIRE       := SM0->M0_NIRE
        oWS:oWSEMPRESA:dDTRE       := SM0->M0_DTRE
        oWS:oWSEMPRESA:cNIT        := IIF(SM0->M0_TPINSC==1,SM0->M0_CGC,"")
        oWS:oWSEMPRESA:cINDSITESP  := ""
        oWS:oWSEMPRESA:cID_MATRIZ  := ""
        oWS:oWSOUTRASINSCRICOES:oWSInscricao := SPEDADM_ARRAYOFSPED_GENERICSTRUCT():New()
        oWS:_URL := AllTrim(cURL)+"/SPEDADM.apw"

        If oWs:ADMEMPRESAS()
            cIdEnt  := oWs:cADMEMPRESASRESULT

            AADD(aEntid, {SM0->M0_CODIGO, SM0->M0_CODFIL, cIdEnt})
        EndIf

        SM0->(DbSkip())

    End

RestArea(aArea)

Return(aEntid)
