#INCLUDE "PROTHEUS.CH"

#DEFINE COMP_DATE  "20191209" 

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±± Autor: Claudino Pereira Domingues                  ³ Data 10/11/14 ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±  APCIniciar - Esta funcao é responsavel por iniciar a criacao do   ±±
±±               processo e o envio da mensagem para o destinatario   ±±
±±               dos Workflows de Pedido de Compra..                  ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/

User Function APCIniciar(_cNivel,oObjeto)

	Local oProcess

	Local _cArqHtm  := ""
	Local _cAssunt  := ""
	Local _cCodSts  := ""
	Local _cDesc    := ""
	Local _cGrpApv  := ""
	Local _cHtmlMod := ""

	Local _nAt     	:= 0
	Local _nTotal  	:= 0
	Local _nFrete  	:= 0
	Local _nDesc   	:= 0
	Local _nItens  	:= 0
	Local _nImps   	:= 0
	Local _nImpTot 	:= 0
	Local _nTotLiq 	:= 0

	Local _aListApr	:= {}
	Local _aMailApr := {}
	Local nModo     := 2
	Local x,y,n,i	:= 0

	Local _cHostWF	:= GetMv("FS_WFURL01", .F.,"")	//URL configurado no ini para WF Link.
	Private _cNumPed:= ""
	Private nHist	:= GetMv("FS_NHISTPC", .F., 6 )

    // FONTANELLI
	// Ajuste para não enviar WORKFLOW nivel 2  
	// Não envia email de aprovação modelo antigo para o NIVEL 2 DIRETOR
	// Email de aprovação Modelo Antigo e enviado apenas para o Nivel 1                             
	IF _cNivel == "01"
		
		_cNumPed  	:= SC7->C7_NUM
		_cGrpApv  	:= SC7->C7_APROV
		_dtEmis   	:= SC7->C7_EMISSAO
		_cFORNECE 	:= SC7->C7_FORNECE
		_cLOJA	  	:= SC7->C7_LOJA

		_cNumDep  	:= IIF(Empty(SC7->C7_XDEPART),IIF(IsInCallStack("EICPO400"),SC1->C1_XDEPART,""),SC7->C7_XDEPART)

		_cAssunt 	:= "Aprovacao do Pedido de Compras nº " + SC7->C7_NUM
		_cArqHtm 	:= "\workflow\wfw120p.htm"
           
		CONOUT("1-" + _cAssunt)

		_cCodSts 	:= "100100"
		_cDesc  	:= "Iniciando processo..."
		CONOUT("2-" + _cCodSts + "-" + _cDesc )

		If Pcount() > 1
			CONOUT("3- Objeto Ja Existe")
			oProcess:=oObjeto
		Else

			If ALTERA
				_nAt := At("/",Alltrim(SC7->C7_WFID))
				If _nAt == 0
					For x:= Val(SubStr(Alltrim(SC7->C7_WFID),Len(Alltrim(SC7->C7_WFID)),1)) To 0 Step -1
						CONOUT("4- Alteracao - Finalizando Processo Nivel 01: " + SubStr(Alltrim(SC7->C7_WFID),1,Len(Alltrim(SC7->C7_WFID))-1) + cValToChar(x))
						WFKillProcess(SubStr(Alltrim(SC7->C7_WFID),1,Len(Alltrim(SC7->C7_WFID))-1) + cValToChar(x))
					Next x
				Else
					For x:= Val(SubStr(Alltrim(SC7->C7_WFID),Len(Alltrim(SC7->C7_WFID)),1)) To 0 Step -1
						CONOUT("5- Alteracao - Finalizando Processo Nivel 02: " + SubStr(Alltrim(SC7->C7_WFID),_nAt+1,Len(Alltrim(SC7->C7_WFID))-_nAt-1) + cValToChar(x))
						WFKillProcess(SubStr(Alltrim(SC7->C7_WFID),_nAt+1,Len(Alltrim(SC7->C7_WFID))-_nAt-1) + cValToChar(x))
					Next x
			
					For y:= Val(SubStr(SubStr(Alltrim(SC7->C7_WFID),1,_nAt-1),Len(SubStr(Alltrim(SC7->C7_WFID),1,_nAt-1)),1)) To 0 Step -1
						CONOUT("6- Alteracao - Finalizando Processo Nivel 01: " + SubStr(Alltrim(SC7->C7_WFID),1,_nAt-2) + cValToChar(y))
						WFKillProcess(SubStr(Alltrim(SC7->C7_WFID),1,_nAt-2) + cValToChar(y))
					Next y
				EndIf
			EndIf
	
		EndIf

		SC7->(dbSetOrder(1))
		SC7->(dbSeek(xFilial("SC7") + _cNumPed))

		While SC7->(!Eof()) .AND. (SC7->C7_NUM == _cNumPed)
		// Se for maior que ZERO significa que tem saldo e não foi eliminado Residuo.
			If SC7->C7_QUANT-SC7->C7_QTDACLA-SC7->C7_QUJE > 0 .AND. Empty(SC7->C7_RESIDUO)
				_nItens++
			EndIf
			SC7->(dbSkip())
		EndDo

		If _nItens > 0
			oProcess := TWFProcess():New("LIBPC",_cAssunt)
	
			dbSelectArea("SAL")
			SAL->(dbSetOrder(1))
			SAL->(dbSeek(xFilial("SAL") + _cGrpApv))
			While !SAL->(EOF()) .AND. SAL->AL_FILIAL == xFILIAL("SAL") .AND. _cGrpApv == SAL->AL_COD
				SAK->(dbSetOrder(1))
				SAK->(dbSeek(xFilial("SAK")+SAL->AL_APROV))
				AADD( _aListApr , { SAK->AK_COD , SAK->AK_NOME , UsrRetMail(SAK->AK_USER) , SAK->AK_USER , SAK->AK_XDEPART , SAL->AL_NIVEL })
				SAL->(dbSkip())
			EndDo
	
			For n:= 1 To Len(_aListApr)
				If _cNivel == "01"
					If _cNumDep $ _aListApr[n][5] .AND. _aListApr[n][6] == "01"
						AADD( _aMailApr , { _aListApr[n][3] , _aListApr[n][4] , _aListApr[n][1] } )
						CONOUT("7- Aprovador Nivel 01 - " + _aListApr[n][2])
					EndIf
				EndIf
			Next n
	
			For i:= 1 To Len(_aMailApr)
	
				_cCodSts := "100200"
				_cDesc   := "Gerando solicitacao de aprovacao de pedido de compras..."
				CONOUT("9- "+ _cCodSts + "-" + _cDesc )
		
				oProcess:NewTask(_cAssunt,_cArqHtm)
		
				oProcess:bReturn := "U_APCRetorno"
				oProcess:cSubject := _cAssunt + " - Nivel Aprov: " + _cNivel + " " + oProcess:fProcessID + "." + oProcess:fTaskID
		
				AADD( oProcess:aParams , { oProcess:fTaskID , _aMailApr[i][1] , _aMailApr[i][2] , _aMailApr[i][3] })
		
				SC7->(dbSetOrder(1))
				SC7->(dbSeek(xFilial("SC7") + _cNumPed))
		
				_nTotal  := 0
				_nFrete  := 0
				_nDesc   := 0
				_nImps   := 0
				_nImpTot := 0
				_nTotLiq := 0
		
				While SC7->(!Eof()) .AND. (SC7->C7_NUM == _cNumPed)
				// Se for maior que ZERO significa que tem saldo e não foi eliminado Residuo
					If SC7->C7_QUANT-SC7->C7_QTDACLA-SC7->C7_QUJE > 0 .AND. Empty(SC7->C7_RESIDUO)
					//_nImps := SC7->C7_VALICM+SC7->C7_VALIPI+SC7->C7_VALIR+SC7->C7_VALSOL
						_nImps := SC7->C7_VALIPI+SC7->C7_VALSOL
						AADD((oProcess:oHtml:ValByName("t1.1"))	, SC7->C7_PRODUTO)
						AADD((oProcess:oHtml:ValByName("t1.2"))	, AllTrim(SC7->C7_DESCRI))
						AADD((oProcess:oHtml:ValByName("t1.3"))	, SC7->C7_UM)
						AADD((oProcess:oHtml:ValByName("t1.4"))	, AllTrim(Transform(SC7->C7_QUANT-SC7->C7_QTDACLA-SC7->C7_QUJE,"@E 999,999,999,999.99")))
						AADD((oProcess:oHtml:ValByName("t1.5"))	, AllTrim(Transform(SC7->C7_PRECO,"@E 9,999,999.999999")))
						AADD((oProcess:oHtml:ValByName("t1.6"))	, AllTrim(Transform((SC7->C7_QUANT-SC7->C7_QTDACLA-SC7->C7_QUJE)*SC7->C7_PRECO,"@E 999,999,999,999.99")))
						AADD((oProcess:oHtml:ValByName("t1.7"))	, AllTrim(Posicione("CTT",1,xFilial("CTT") + SC7->C7_CC,"CTT_DESC01")))
						AADD((oProcess:oHtml:ValByName("t1.8"))	, AllTrim(SC7->C7_OBS))
				
						_nTotal	 += SC7->C7_TOTAL - SC7->C7_VLDESC + SC7->C7_VALFRE + _nImps
						_nTotLiq += SC7->C7_TOTAL
						_nFrete	 += SC7->C7_VALFRE
						_nDesc	 += SC7->C7_VLDESC
						_nImpTot += _nImps
				
					EndIf
					SC7->(dbSkip())
				EndDo
		
				SC7->(dbSeek(xFilial("SC7") + _cNumPed))
		
				oProcess:oHtml:ValByName("Pedido"       , SC7->C7_NUM)
				oProcess:oHtml:ValByName("Filial"       , SC7->C7_FILIAL)
				oProcess:oHtml:ValByName("Fornecedor"   , AllTrim(Posicione("SA2",1,xFilial("SA2") + SC7->C7_FORNECE + SC7->C7_LOJA,"A2_NOME")))
				oProcess:oHtml:ValByName("Comprador"    , UsrFullName(SC7->C7_USER))
				oProcess:oHtml:ValByName("Compr"	    , SC7->C7_USER)
				oProcess:oHtml:ValByName("Departamento" , AllTrim(Posicione("SQB",1,xFilial("SQB") + _cNumDep,"QB_DESCRIC")))
				oProcess:oHtml:ValByName("Emissao"      , _dtEmis)
				oProcess:oHtml:ValByName("CondPg"       , AllTrim(Posicione("SE4",1,xFilial("SE4") + AllTrim(SC7->C7_COND),"E4_DESCRI")))
				oProcess:oHtml:ValByName("VlrLiq"       , AllTrim(Transform(_nTotLiq ,"@E 999,999,999,999.99")))
				oProcess:oHtml:ValByName("Impostos"     , AllTrim(Transform(_nImpTot ,"@E 999,999,999,999.99")))
				oProcess:oHtml:ValByName("Frete"        , AllTrim(Transform(_nFrete  ,"@E 999,999,999,999.99")))
				oProcess:oHtml:ValByName("Desconto"     , AllTrim(Transform(_nDesc   ,"@E 999,999,999,999.99")))
				oProcess:oHtml:ValByName("VlrTotal"     , AllTrim(Transform(_nTotal  ,"@E 999,999,999,999.99")))
				oProcess:oHtml:ValByName("NivelAprov"   , _cNivel)
		
		
			//*****************************************************************************************************************************
			/// query do sc7
		
				IF SELECT("TM2") > 0
					DBSELECTAREA("TM2")
					DBCLOSEAREA()
				ENDIF

				If nModo == 1
			
					cQUERY	:= " SELECT C7_NUM, C7_TOTAL, C7_COND, C7_EMISSAO, C7_DATPRF, C7_USER, C7_FRETE, C7_DESPESA, C7_VLDESC"
					cQUERY	+= " FROM "+RetSqlName("SC7") +" SC7 "
					cQUERY	+= " WHERE SC7.C7_FILIAL = '"+XFILIAL("SC7")+"' "
					cQUERY	+= " AND SC7.C7_FORNECE = '"+_cFORNECE+"' "
					cQUERY	+= " AND SC7.C7_LOJA = '"+_cLOJA+"' "
					cQUERY 	+= " AND SC7.D_E_L_E_T_ <> '*'	 "
					cQUERY 	+= " ORDER BY C7_NUM DESC"
			
					DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery) , 'TM2', .T., .F.)
					_nY := 1
					DBSELECTAREA("TM2")
					DBSKIP(1)
				// dbGoBottom()    // !Bof()
			
					If TM2->(!EOF())
						WHILE _nY <= nHist .AND. TM2->(!EOF())
							_nZ := 1
							_cUltNum := TM2->C7_NUM
							dbSelectArea("SC7")
							dbSetOrder(1)
							IF dbSeek(xFilial("SC7")+TM2->C7_NUM)
					
								_cHTNume	:= C7_NUM
								_nHTTMer    := 0
								_nHTTota	:= 0
								_cHTCond	:= C7_COND
								_cHTEmis	:= C7_EMISSAO
								_cHTDEnt	:= C7_DATPRF
								_cHTUser	:= C7_USER
						
								//PswSeek(C7_USER)
								//_aUser := PswRet()
								_cHTUser := UsrRetName(TM2->C7_USER)
						
								While C7_FILIAL == xFilial("SC7") .AND. C7_NUM == _cUltNum
									_nHTTMer += C7_TOTAL
									_nHTTota += C7_TOTAL+C7_FRETE+C7_DESPESA-C7_VLDESC
									dbSkip(1)
									_nZ += 1
								END
								dbSkip(-1)
								_nZ -= 1
								_nY += 1
						
								AADD((oProcess:oHtml:ValByName("ia1.1"))	, _cHTNume)
								AADD((oProcess:oHtml:ValByName("ia1.2"))	, AllTrim(Transform(_nHTTMer,"@E 9,999,999.999999")))
								AADD((oProcess:oHtml:ValByName("ia1.3"))	, AllTrim(Transform(_nHTTota,"@E 9,999,999.999999")))
								AADD((oProcess:oHtml:ValByName("ia1.4"))	, AllTrim(Posicione("SE4",1,xFilial("SE4")+_cHTCond,"E4_DESCRI")))
								AADD((oProcess:oHtml:ValByName("ia1.5"))	, _cHTEmis)
								AADD((oProcess:oHtml:ValByName("ia1.6"))	, _cHTDEnt)
								AADD((oProcess:oHtml:ValByName("ia1.7"))	, _cHTUser)
								DBSELECTAREA("TM2")
								DBSKIP(_nZ)
							Else
								DBSELECTAREA("TM2")
								DBSKIP(_nZ)
								_nY += 1
							ENDIF
						END
					Else
	
						AADD((oProcess:oHtml:ValByName("ia1.1"))	, "-" )
						AADD((oProcess:oHtml:ValByName("ia1.2"))	, "-" )
						AADD((oProcess:oHtml:ValByName("ia1.3"))	, "-" )
						AADD((oProcess:oHtml:ValByName("ia1.4"))	, "-" )
						AADD((oProcess:oHtml:ValByName("ia1.5"))	, "-" )
						AADD((oProcess:oHtml:ValByName("ia1.6"))	, "-" )
						AADD((oProcess:oHtml:ValByName("ia1.7"))	, "-" )
			
					EndIf
				ElseIf nModo == 2
		     
					cQUERY	:= " SELECT TOP "+cValToChar(nHist)+" C7_NUM, SUM(C7_TOTAL) C7_TOTAL, C7_COND, C7_EMISSAO, C7_DATPRF, C7_USER, SUM(C7_FRETE) C7_FRETE, SUM(C7_DESPESA) C7_DESPESA, SUM(C7_VLDESC) C7_VLDESC"
					cQUERY	+= " FROM "+RetSqlName("SC7") +" SC7 "
					cQUERY	+= " WHERE SC7.C7_FILIAL = '"+XFILIAL("SC7")+"' "
					cQUERY	+= " AND SC7.C7_FORNECE = '"+_cFORNECE+"' "
					cQUERY	+= " AND SC7.C7_LOJA = '"+_cLOJA+"' "
					cQUERY	+= " AND SC7.D_E_L_E_T_ <> '*'"
					cQUERY	+= " AND SC7.C7_NUM <> '"+_cNumPed+"' "
					cQUERY	+= " GROUP BY C7_FILIAL,C7_NUM,C7_FORNECE,C7_LOJA,C7_EMISSAO, C7_COND , C7_DATPRF, C7_USER"
					cQUERY	+= " ORDER BY C7_NUM DESC"
				                
					DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery) , 'TM2', .T., .F.)

					DbSelectArea("TM2")
			
					If TM2->(!EOF())
						While TM2->(!EOF())
							cUltNum := TM2->C7_NUM
					
							cHTNume	:= TM2->C7_NUM
							cHTCond	:= TM2->C7_COND
							cHTEmis	:= Stod(TM2->C7_EMISSAO)
							cHTDEnt	:= Stod(TM2->C7_DATPRF)
					
							nHTTMer := TM2->C7_TOTAL
							nHTTota := TM2->C7_TOTAL+TM2->C7_FRETE+TM2->C7_DESPESA-TM2->C7_VLDESC
					
							//PswSeek(TM2->C7_USER)
							//aUser 	:= PswRet()
							cHTUser := UsrRetName(TM2->C7_USER)

							AADD((oProcess:oHtml:ValByName("ia1.1"))	, cHTNume)
							AADD((oProcess:oHtml:ValByName("ia1.2"))	, AllTrim(Transform(nHTTMer,"@E 9,999,999.999999")))
							AADD((oProcess:oHtml:ValByName("ia1.3"))	, AllTrim(Transform(nHTTota,"@E 9,999,999.999999")))
							AADD((oProcess:oHtml:ValByName("ia1.4"))	, AllTrim(Posicione("SE4",1,xFilial("SE4")+cHTCond,"E4_DESCRI")))
							AADD((oProcess:oHtml:ValByName("ia1.5"))	, cHTEmis)
							AADD((oProcess:oHtml:ValByName("ia1.6"))	, cHTDEnt)
							AADD((oProcess:oHtml:ValByName("ia1.7"))	, cHTUser)

							TM2->(DbSkip())

						EndDo
					Else
	
						AADD((oProcess:oHtml:ValByName("ia1.1"))	, "-" )
						AADD((oProcess:oHtml:ValByName("ia1.2"))	, "-" )
						AADD((oProcess:oHtml:ValByName("ia1.3"))	, "-" )
						AADD((oProcess:oHtml:ValByName("ia1.4"))	, "-" )
						AADD((oProcess:oHtml:ValByName("ia1.5"))	, "-" )
						AADD((oProcess:oHtml:ValByName("ia1.6"))	, "-" )
						AADD((oProcess:oHtml:ValByName("ia1.7"))	, "-" )
			
					EndIf
			
				EndIf
		
			//*****************************************************************************************************************************
		
		
				oProcess:cTo := "WFAPROV"
		
				If _cNivel == "01"
			
					oProcess:bTimeOut := {{"U_APCTimeout(1)", 1 , 0 , 0 },{"U_APCTimeout(2)", 2 , 0 , 0 },{"U_APCTimeout(3)", 3 , 0 , 0 }}
			
				EndIf
		
				cMailID := oProcess:Start()
		
				_cCodSts := "100300"
				_cDesc   := "Enviando solicitacao para: "
				CONOUT("10- "+ _cCodSts + "-" + _cDesc )
		
				_cHtmlMod := "\workflow\wflink.htm"
		
				oProcess:NewTask(_cAssunt,_cHtmlMod)
				oProcess:cSubject := _cAssunt + " - Nivel Aprov: " + _cNivel + " " + oProcess:fProcessID + "." + oProcess:fTaskID
		
				oProcess:cTo := _aMailApr[i][1]
				oProcess:bReturn := "U_APCRetorno"
			// oProcess:ohtml:ValByName("proc_link","http://aprovar.ourolux.com.br:8181/wf/" + cMailID + ".htm")
			// oProcess:ohtml:ValByName("proc_link","http://ourolux.totvs.com.br:10510/wf/" + cMailID + ".htm")
			// oProcess:ohtml:ValByName("proc_link","http://ourolux.totvs.com.br:10510/wf/" + cMailID + ".htm")
				oProcess:ohtml:ValByName("proc_link",_cHostWF + cMailID + ".htm")

		
				oProcess:Start()
			Next i
	
			SC7->(dbSetOrder(1))
			If SC7->(dbSeek(xFilial("SC7") + _cNumPed))
				While SC7->(!Eof()) .AND. (SC7->C7_NUM == _cNumPed)
					If _cNivel == "01"
						If RecLock("SC7",.F.)
							If ALTERA
								SC7->C7_WFID := " "
							EndIf
							SC7->C7_WFID := oProcess:fProcessID + "." + oProcess:fTaskID
							SC7->(MsUnLock("SC7"))
						EndIf
					EndIf
					SC7->(dbSkip())
				EndDo
			EndIf
	
		EndIf
		
	Endif

Return

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±  APCRetorno - Esta funcao é responsavel por atualizar o pedido de  ±±
±±               compras com as respostas vindas do aprovador..       ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/

User Function APCRetorno(oProcess)

	Local _cFindKey := ""
	Local _cAssunt  := ""
	Local _cNumPed  := ""
	Local _cCodApr  := ""
	Local _cCodUse  := ""
	Local _cCodSts  := ""
	Local _cDesc    := ""
	Local _cMotivo  := ""
	Local _cCompr	:= ""
	Local _cMailCom := ""
	Local _cMailApr := ""
	Local _cNivel   := ""
	Local _cFil     := ""
	Local _cEmpPC   := ""
	Local _cFilPC   := ""

	Local _nAt      := 0
	Local _nSaldo   := 0
	Local _nTotal   := 0
	Local _nSalDif  := 0
	//Local _nVlrTot  := 0
	//Local _nTaxDol  := 0
	Local x, y 		:= 0
	Local _lLibera  := .F.

	Local _aRetSald := {}

	_cFil := PADR(oProcess:oHtml:RetByName("Filial") ,Len(SC7->C7_FILIAL))
	CONOUT("R1- Retorno - Filial: " + _cFil)

	_cNumPed := PADR(oProcess:oHtml:RetByName("Pedido") ,Len(SC7->C7_NUM))
	CONOUT("R2- Retorno - Numero do Pedido: " + _cNumPed)

	_cCompr   := PADR(oProcess:oHtml:RetByName("Compr") ,Len(SC7->C7_USER))
	_cMailCom := Alltrim(UsrRetMail(_cCompr))
	CONOUT("R3- Retorno - Comprador: " + _cCompr + " - E-mail Compr: " + _cMailCom)

	_cMotivo := oProcess:oHtml:RetByName("LBMOTIVO")

	CONOUT("R4- Retorno - Resposta - " + Upper(oProcess:oHtml:RetByName("RBAPROVA")) + " APROVADO!!!")

	_cCodApr  := oProcess:aParams[ASCAN(oProcess:aParams,{|x| x[1] == oProcess:fTaskID})][4]
	_cCodUse  := oProcess:aParams[ASCAN(oProcess:aParams,{|x| x[1] == oProcess:fTaskID})][3]
	_cMailApr := oProcess:aParams[ASCAN(oProcess:aParams,{|x| x[1] == oProcess:fTaskID})][2]
	CONOUT("R5- Retorno - Cod User Aprovador: " + _cCodUse + " Cod Aprov: " + _cCodApr + " - E-mail Aprov: " + _cMailApr)

	_cNivel  := oProcess:oHtml:RetByName("NivelAprov")
	CONOUT("R6- Retorno - Nivel: " + _cNivel)

	SC7->(dbSetOrder(1))
	SC7->(dbSeek(Alltrim(_cFil) + _cNumPed))

	CONOUT("R7- Retorno - Dbseek - Procurando SC7 - " + _cFil + _cNumPed + " = " + IIF(SC7->(Found()),"Encontrou","Nao Encontrou"))

	_cAssunt := "Pedido de compras nº " + _cNumPed
	_cCodSts := "100400"
	_cDesc   := "Recebendo resultado aprovacao..."
	CONOUT( "R8- Retorno - " + _cCodSts + "-" + _cDesc )

	// Verifico se a resposta é diferente de "SIM", ou seja, Reprovado.
	If Upper(oProcess:oHtml:RetByName("RBAPROVA")) <> "SIM"
		_nAt := At("/",Alltrim(SC7->C7_WFID))
		If _nAt == 0
			For x:= Val(SubStr(Alltrim(SC7->C7_WFID),Len(Alltrim(SC7->C7_WFID)),1)) To 0 Step -1
				CONOUT("R9- Reprovado - Finalizando Processo Nivel 01: " + SubStr(Alltrim(SC7->C7_WFID),1,Len(Alltrim(SC7->C7_WFID))-1) + cValToChar(x))
				WFKillProcess(SubStr(Alltrim(SC7->C7_WFID),1,Len(Alltrim(SC7->C7_WFID))-1) + cValToChar(x))
			Next x
		Else
			For x:= Val(SubStr(Alltrim(SC7->C7_WFID),Len(Alltrim(SC7->C7_WFID)),1)) To 0 Step -1
				CONOUT("R10- Reprovado - Finalizando Processo Nivel 02: " + SubStr(Alltrim(SC7->C7_WFID),_nAt+1,Len(Alltrim(SC7->C7_WFID))-_nAt-1) + cValToChar(x))
				WFKillProcess(SubStr(Alltrim(SC7->C7_WFID),_nAt+1,Len(Alltrim(SC7->C7_WFID))-_nAt-1) + cValToChar(x))
			Next x
		
			For y:= Val(SubStr(SubStr(Alltrim(SC7->C7_WFID),1,_nAt-1),Len(SubStr(Alltrim(SC7->C7_WFID),1,_nAt-1)),1)) To 0 Step -1
				CONOUT("R11- Reprovado - Finalizando Processo Nivel 01: " + SubStr(Alltrim(SC7->C7_WFID),1,_nAt-2) + cValToChar(y))
				WFKillProcess(SubStr(Alltrim(SC7->C7_WFID),1,_nAt-2) + cValToChar(y))
			Next y
		EndIf
	
		SCR->(dbSetorder(2))
		SCR->(MsSeek(Alltrim(_cFil) + "PC" + Padr(_cNumPed,Len(SCR->CR_NUM)) + _cCodUse))
	
		_lLibera  := MaAlcDoc({SCR->CR_NUM,SCR->CR_TIPO,SCR->CR_TOTAL,_cCodApr,,SC7->C7_APROV,,,,,Alltrim(_cMotivo)},dDataBase,6) // Funcao do protheus
	
		CONOUT("R12- Reprovado - Num.Ped : " + cValToChar(SC7->C7_NUM) + " - Cod Aprov: " + _cCodApr + " - Grup Aprov: " + SC7->C7_APROV + " - Motivo: " + Alltrim(_cMotivo))
	
		SCR->(dbSetorder(1))
		SCR->(MsSeek(Alltrim(_cFil) + "PC" + Padr(_cNumPed,Len(SCR->CR_NUM)) + _cNivel))
		While !Eof() .And. Alltrim(_cFil)+"PC"+Padr(_cNumPed,Len(SCR->CR_NUM))+_cNivel == SCR->CR_FILIAL+SCR->CR_TIPO+SCR->CR_NUM+SCR->CR_NIVEL
			If SCR->CR_STATUS != "04"
				Reclock("SCR",.F.)
				SCR->CR_STATUS	:= "05"
				SCR->CR_OBS	    := "Doc.Bloq.Usuario: " + _cCodApr
				SCR->CR_DATALIB	:= dDataBase
				SCR->CR_USERLIB	:= _cCodUse
				SCR->CR_LIBAPRO	:= _cCodApr
				SCR->(MsUnLock("SCR"))
			EndIf
			SCR->(dbSkip())
		EndDo
	
		dbSelectArea("SC7")
		SC7->(MsSeek(Alltrim(_cFil) + _cNumPed))
		If SuperGetMv("MV_EASY")=="S" .And. SC7->(FieldPos("C7_PO_EIC")) <> 0 .And. !EMPTY(SC7->C7_PO_EIC)
			If SW2->(MsSeek(xFilial("SW2")+SC7->C7_PO_EIC)) .And. SW2->(FieldPos("W2_CONAPRO")) <> 0 .And. !Empty(SW2->W2_CONAPRO)
				Reclock("SW2",.F.)
				SW2->W2_CONAPRO := "B"
				SW2->(MsUnLock("SW2"))
				CONOUT("R13- Reprovado - Bloqueio SW2 - Num.Ped : " + cValToChar(SC7->C7_NUM) + " - Filial: " + _cFil)
			EndIf
		EndIf
	
		While !Eof() .And. SC7->C7_FILIAL+SubStr(SC7->C7_NUM,1,Len(SC7->C7_NUM)) == Alltrim(_cFil)+_cNumPed
			Reclock("SC7",.F.)
			SC7->C7_CONAPRO := "B"
			SC7->(MsUnLock("SC7"))
			CONOUT("R14- Reprovado - Bloqueio SC7 - Num.Ped : " + cValToChar(SC7->C7_NUM) + " - Filial: " + _cFil)
			SC7->(dbSkip())
		EndDo
	
		_cEmpPC := Posicione("SM0",1,cEmpAnt+_cFil,"M0_NOME")
		_cFilPC := Posicione("SM0",1,cEmpAnt+_cFil,"M0_FILIAL")
	
		U_MsgWFPC(_cMailCom + ";" + _cMailApr,"PC nº " + _cNumPed + " Reprovado - " + Alltrim(_cEmpPC) + "/" + Alltrim(_cFilPC),("Motivo:" + _cMotivo))
	Else
		CONOUT("R15- Retorno - Verifica se o aprovador possui saldo - PC: " + _cNumPed + " - Cod Aprov: " + _cCodApr)
	
		SAL->(dbSetOrder(3))
		SCR->(dbSetorder(2))
	
		If SCR->(MsSeek(Alltrim(_cFil) + "PC" + Padr(_cNumPed,Len(SCR->CR_NUM)) + _cCodUse)) .And. ;
				SAL->(MsSeek(xFilial("SAL") + Padr(SC7->C7_APROV,Len(SAL->AL_COD)) + Padr(SCR->CR_APROV,Len(SAL->AL_APROV))))
		
			If SAL->AL_LIBAPR == "A" .AND. MaAlcLim(SCR->CR_APROV,SCR->CR_TOTAL,SCR->CR_MOEDA,SCR->CR_TXMOEDA) // Funcao do protheus
				_aRetSald := MaSalAlc(SCR->CR_APROV,dDataBase) // Funcao do protheus
				_nSaldo   := _aRetSald[1]
				_nTotal   := xMoeda(SCR->CR_TOTAL,SCR->CR_MOEDA,_aRetSald[2],SCR->CR_EMISSAO,,SCR->CR_TXMOEDA) // Funcao do protheus
				_nSalDif  := _nSaldo - _nTotal
			
				CONOUT("R16- Retorno - Saldo - " + Str(_nSaldo))
				CONOUT("R17- Retorno - Total - " + Str(_nTotal))
				CONOUT("R18- Retorno - Diferenca - " + Str(_nSalDif))
			
				If (_nSalDif) < 0
					CONOUT("R19- Retorno - Insuficiencia de Saldo 01 -" + _cAssunt + _cCompr)
				
					_nAt := At("/",Alltrim(SC7->C7_WFID))
					If _nAt == 0
						For x:= Val(SubStr(Alltrim(SC7->C7_WFID),Len(Alltrim(SC7->C7_WFID)),1)) To 0 Step -1
							CONOUT("R20- Saldo Insuficiente - Finalizando Processo Nivel 01: " + SubStr(Alltrim(SC7->C7_WFID),1,Len(Alltrim(SC7->C7_WFID))-1) + cValToChar(x))
							WFKillProcess(SubStr(Alltrim(SC7->C7_WFID),1,Len(Alltrim(SC7->C7_WFID))-1) + cValToChar(x))
						Next x
					Else
						For x:= Val(SubStr(Alltrim(SC7->C7_WFID),Len(Alltrim(SC7->C7_WFID)),1)) To 0 Step -1
							CONOUT("R21- Saldo Insuficiente - Finalizando Processo Nivel 02: " + SubStr(Alltrim(SC7->C7_WFID),_nAt+1,Len(Alltrim(SC7->C7_WFID))-_nAt-1) + cValToChar(x))
							WFKillProcess(SubStr(Alltrim(SC7->C7_WFID),_nAt+1,Len(Alltrim(SC7->C7_WFID))-_nAt-1) + cValToChar(x))
						Next x
					
						For y:= Val(SubStr(SubStr(Alltrim(SC7->C7_WFID),1,_nAt-1),Len(SubStr(Alltrim(SC7->C7_WFID),1,_nAt-1)),1)) To 0 Step -1
							CONOUT("R22- Saldo Insuficiente - Finalizando Processo Nivel 01: " + SubStr(Alltrim(SC7->C7_WFID),1,_nAt-2) + cValToChar(y))
							WFKillProcess(SubStr(Alltrim(SC7->C7_WFID),1,_nAt-2) + cValToChar(y))
						Next y
					EndIf
				
					_cEmpPC := Posicione("SM0",1,cEmpAnt+_cFil,"M0_NOME")
					_cFilPC := Posicione("SM0",1,cEmpAnt+_cFil,"M0_FILIAL")
				
					U_MsgWFPC(_cMailCom + ";" + _cMailApr,"PC nº " + _cNumPed + " - Não Aprovado - Saldo Aprovador Insuficiente - " + Alltrim(_cEmpPC) + "/" + Alltrim(_cFilPC),(""))
				Else // Se possui saldo libero o pedido
					CONOUT("R23- Retorno - Tem Saldo!")
					Begin Transaction
					If _cNivel == "01"
						_lLibera :=  MaAlcDoc({SCR->CR_NUM,SCR->CR_TIPO,_nTotal,SCR->CR_APROV,,SC7->C7_APROV,,,,,Alltrim(_cMotivo)},dDataBase,4) // Funcao do protheus
						If _lLibera
							CONOUT("R30- Liberação WorkFlow ( <= que 10000 ) - Nivel 01")
							SAL->(dbSetOrder(2))
							SAL->(dbSeek(xFilial("SAL")+SC7->C7_APROV+"02"))
							_cFindKey := xFilial("SC7")+SC7->C7_NUM
					
							dbSelectArea("SC7")
							SC7->(dbSetOrder(1))
							SC7->(dbSeek(xFilial("SC7")+SC7->C7_NUM))
					
							If !Empty(Alltrim(SC7->C7_WFID))
								_nAt := At("/",Alltrim(SC7->C7_WFID))
								If _nAt == 0
									For x:= Val(SubStr(Alltrim(SC7->C7_WFID),Len(Alltrim(SC7->C7_WFID)),1)) To 0 Step -1
										CONOUT("R31- Liberação WorkFlow ( <= que 10000 ) - Finalizando Processo Nivel 01: " + SubStr(Alltrim(SC7->C7_WFID),1,Len(Alltrim(SC7->C7_WFID))-1) + cValToChar(x))
										WFKillProcess(SubStr(Alltrim(SC7->C7_WFID),1,Len(Alltrim(SC7->C7_WFID))-1) + cValToChar(x))
									Next x
								Else
									For x:= Val(SubStr(Alltrim(SC7->C7_WFID),Len(Alltrim(SC7->C7_WFID)),1)) To 0 Step -1
										CONOUT("R32- Liberação WorkFlow ( <= que 10000 ) - Finalizando Processo Nivel 02: " + SubStr(Alltrim(SC7->C7_WFID),_nAt+1,Len(Alltrim(SC7->C7_WFID))-_nAt-1) + cValToChar(x))
										WFKillProcess(SubStr(Alltrim(SC7->C7_WFID),_nAt+1,Len(Alltrim(SC7->C7_WFID))-_nAt-1) + cValToChar(x))
									Next x
							
									For y:= Val(SubStr(SubStr(Alltrim(SC7->C7_WFID),1,_nAt-1),Len(SubStr(Alltrim(SC7->C7_WFID),1,_nAt-1)),1)) To 0 Step -1
										CONOUT("R33- Liberação WorkFlow ( <= que 10000 ) - Finalizando Processo Nivel 01: " + SubStr(Alltrim(SC7->C7_WFID),1,_nAt-2) + cValToChar(y))
										WFKillProcess(SubStr(Alltrim(SC7->C7_WFID),1,_nAt-2) + cValToChar(y))
									Next y
								EndIf
							EndIf
					
							_cMailCom := UsrRetMail(SC7->C7_USER)
							_cFilPC   := Posicione("SM0",1,cEmpAnt+cFilAnt,"M0_FILIAL")
					
							//U_MsgWFPC(_cMailCom,"PC nº " + SC7->C7_NUM + " Aprovado - " + Alltrim(_cEmpPC) + "/" + Alltrim(_cFilPC),(""))
					
							_cMailApr := UsrRetMail(SAK->AK_USER)
							//U_MsgWFPC(_cMailApr,"PC nº " + SC7->C7_NUM + " Aprovado Automaticamente - " + Alltrim(_cEmpPC) + "/" + Alltrim(_cFilPC),("")) // Claudino - I1605-400 - Comentei
					
							If SuperGetMv("MV_EASY")=="S" .And. SC7->(FieldPos("C7_PO_EIC")) <> 0 .And. !Empty(SC7->C7_PO_EIC)
								dbSelectArea("SW2")
								SW2->(dbSetOrder(1))
						
								If SW2->(MsSeek(xFilial("SW2")+SC7->C7_PO_EIC)) .And. SW2->(FieldPos("W2_CONAPRO")) <> 0 .And. !Empty(SW2->W2_CONAPRO)
							
									Reclock("SW2",.F.)
									SW2->W2_CONAPRO := "L"
									SW2->(MsUnlock("SW2"))
									CONOUT("R34- Retorno - Aprovado SW2 Automaticamente - Num.Ped : " + cValToChar(SC7->C7_NUM) + " - Filial: " + _cFilPC)
								EndIf
							EndIf
					
							While SC7->(!Eof()) .AND. (SC7->C7_FILIAL+SC7->C7_NUM == _cFindKey )
								RecLock("SC7",.F.)
								SC7->C7_CONAPRO := "L"
								SC7->(MsUnLock("SC7"))
								SC7->(dbSkip())
							EndDo
						EndIf
					EndIf
					End Transaction
				EndIf
			Else
				CONOUT("R36- Retorno - Insuficiencia de Saldo 02 - " + _cAssunt + _cCompr)
			
				_nAt := At("/",Alltrim(SC7->C7_WFID))
				If _nAt == 0
					For x:= Val(SubStr(Alltrim(SC7->C7_WFID),Len(Alltrim(SC7->C7_WFID)),1)) To 0 Step -1
						CONOUT("R37- Saldo Insuficiente - Finalizando Processo Nivel 01: " + SubStr(Alltrim(SC7->C7_WFID),1,Len(Alltrim(SC7->C7_WFID))-1) + cValToChar(x))
						WFKillProcess(SubStr(Alltrim(SC7->C7_WFID),1,Len(Alltrim(SC7->C7_WFID))-1) + cValToChar(x))
					Next x
				Else
					For x:= Val(SubStr(Alltrim(SC7->C7_WFID),Len(Alltrim(SC7->C7_WFID)),1)) To 0 Step -1
						CONOUT("R38- Saldo Insuficiente - Finalizando Processo Nivel 02: " + SubStr(Alltrim(SC7->C7_WFID),_nAt+1,Len(Alltrim(SC7->C7_WFID))-_nAt-1) + cValToChar(x))
						WFKillProcess(SubStr(Alltrim(SC7->C7_WFID),_nAt+1,Len(Alltrim(SC7->C7_WFID))-_nAt-1) + cValToChar(x))
					Next x
				
					For y:= Val(SubStr(SubStr(Alltrim(SC7->C7_WFID),1,_nAt-1),Len(SubStr(Alltrim(SC7->C7_WFID),1,_nAt-1)),1)) To 0 Step -1
						CONOUT("R39- Saldo Insuficiente - Finalizando Processo Nivel 01: " + SubStr(Alltrim(SC7->C7_WFID),1,_nAt-2) + cValToChar(y))
						WFKillProcess(SubStr(Alltrim(SC7->C7_WFID),1,_nAt-2) + cValToChar(y))
					Next y
				EndIf
			
				_cEmpPC := Posicione("SM0",1,cEmpAnt+_cFil,"M0_NOME")
				_cFilPC := Posicione("SM0",1,cEmpAnt+_cFil,"M0_FILIAL")
			
				U_MsgWFPC(_cMailCom + ";" + _cMailApr,"PC nº " + _cNumPed + " - Não Aprovado - Saldo Aprovador Insuficiente - " + Alltrim(_cEmpPC) + "/" + Alltrim(_cFilPC),(""))
			EndIf
		EndIf
	EndIf

Return

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±  APCTimeout - Esta funcao e responsavel pela execucao do timeout   ±±
±±               do processo.                                         ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/

User Function APCTimeOut(nVezes,oProcess)

	Local _cNumPed  := ""
	Local _cCodSts  := ""
	Local _cDesc    := ""
	Local _cArqHtm  := ""
	Local _cCodApr  := ""
	Local _cMailApr := ""
	Local _cQrySCR  := ""
	Local x			:= 0
	Local _nAt      := 0
	//Local _nRegSCR  := 0

	Local _lLibSis  := .F.

	Local _cMailID := SubString(oProcess:oHtml:ValByName("WFMAILID"),3,Len(oProcess:oHtml:ValByName("WFMAILID")))
	Local _cNivel  := oProcess:oHtml:ValByName("NivelAprov")
	Local _cFilial := oProcess:oHtml:ValByName("Filial")

	_cArqHtm := "\workflow\wflink.htm"
	_cNumPed := oProcess:oHtml:ValByName("Pedido")

	_cQrySCR := " SELECT "
	_cQrySCR += " 		SCR.CR_FILIAL Filial, "
	_cQrySCR += " 		SCR.CR_NUM NumPed, "
	_cQrySCR += "		SCR.CR_TIPO Tipo, "
	_cQrySCR += "		SCR.CR_NIVEL Nivel, "
	_cQrySCR += "		SCR.CR_STATUS Status "
	_cQrySCR += " FROM "
	_cQrySCR += 		RetSqlName("SCR") + " SCR "
	_cQrySCR += " WHERE "
	_cQrySCR += "		SCR.D_E_L_E_T_ = ' ' AND "
	_cQrySCR += "		SCR.CR_FILIAL = '" + _cFilial + "' AND "
	_cQrySCR += "		SCR.CR_NUM = '" + _cNumPed + "' AND "
	_cQrySCR += "		SCR.CR_TIPO = 'PC' AND "
	_cQrySCR += "		SCR.CR_NIVEL = '" + _cNivel + "' AND "
	_cQrySCR += "		SCR.CR_STATUS = '03' "
	_cQrySCR += " ORDER BY "
	_cQrySCR += "		SCR.CR_FILIAL, "
	_cQrySCR += "		SCR.CR_NUM "

	_cQrySCR := ChangeQuery(_cQrySCR)

	CONOUT("Query SCR: " + _cQrySCR )

	If Select("QRYSCR") > 0
		dbSelectArea("QRYSCR")
		QRYSCR->(dbCloseArea())
	EndIf

	DbUseArea(.T.,"TOPCONN",TCGenQry(,,_cQrySCR),"QRYSCR",.F.,.T.)

	While QRYSCR->(!Eof())
		CONOUT("O pedido " + _cNumPed + " da filial " + _cFilial + " teve liberação pelo sistema.")
		_lLibSis := .T.
		QRYSCR->(dbSkip())
	EndDo

	If Select("QRYSCR") > 0
		dbSelectArea("QRYSCR")
		QRYSCR->(dbCloseArea())
	EndIf

	If _lLibSis
		If _cNivel == "01"
			dbSelectArea("SC7")
			SC7->(dbSetOrder(1))
			SC7->(dbSeek(_cFilial + _cNumPed))
			For x:= Val(SubStr(Alltrim(SC7->C7_WFID),Len(Alltrim(SC7->C7_WFID)),1)) To 0 Step -1
				CONOUT("Aprovado Pelo Sistema - Finalizando Processo Nivel 01: " + SubStr(Alltrim(SC7->C7_WFID),1,Len(Alltrim(SC7->C7_WFID))-1) + cValToChar(x))
				WFKillProcess(SubStr(Alltrim(SC7->C7_WFID),1,Len(Alltrim(SC7->C7_WFID))-1) + cValToChar(x))
			Next x
		
			CONOUT("Aprovado Pelo Sistema - Nivel 01")
		
			If SC7->C7_CONAPRO == "B"
				_nAt := At("/",Alltrim(SC7->C7_WFID))
				If _nAt == 0
				//	U_APCIniciar("02",oProcess) // Passo para o segundo nivel de aprovacao
				EndIf
			EndIf
		EndIf
	Else
		// Verifique o número de vezes que o timeout foi executado para este processo.
		If ( nVezes == 1 )
			_cCodApr  := oProcess:aParams[ASCAN(oProcess:aParams,{|x| x[1] == oProcess:fTaskID})][4]
			_cMailApr := oProcess:aParams[ASCAN(oProcess:aParams,{|x| x[1] == oProcess:fTaskID})][2]
			CONOUT("Timeout1 - Cod Aprov: " + _cCodApr + " - E-mail Aprov: " + _cMailApr + " - Nivel Aprov: " + _cNivel)
		
			_cCodSts := "100600"
			_cDesc := "Reenviando aprovacao do pedido de compras no. " + _cNumPed
			CONOUT( "Timeout1 - " + _cCodSts + "-" + _cDesc )
		
			oProcess:NewTask(_cDesc,_cArqHtm)
			oProcess:cSubject := "(Timeout1)" + oProcess:cSubject
			// oProcess:ohtml:ValByName("proc_link","http://ourolux.totvs.com.br:10510/wf/" + _cMailID + ".htm") 
			oProcess:ohtml:ValByName("proc_link",_cHostWF + _cMailID + ".htm")
		
			oProcess:cTo := _cMailApr
			oProcess:bReturn := "U_APCRetorno"
		
			oProcess:Start()
		ElseIf ( nVezes == 2 )
			_cCodApr  := oProcess:aParams[ASCAN(oProcess:aParams,{|x| x[1] == oProcess:fTaskID})][4]
			_cMailApr := oProcess:aParams[ASCAN(oProcess:aParams,{|x| x[1] == oProcess:fTaskID})][2]
			CONOUT("Timeout2 - Cod Aprov: " + _cCodApr + " - E-mail Aprov: " + _cMailApr + " - Nivel Aprov: " + _cNivel)
		
			_cCodSts := "100700"
			_cDesc := "Reenviando aprovacao do pedido de compras no. " + _cNumPed
			CONOUT( "Timeout2 - " + _cCodSts + "-" + _cDesc )
		
			oProcess:NewTask(_cDesc,_cArqHtm)
			oProcess:cSubject := "(Timeout2)" + oProcess:cSubject
			// oProcess:ohtml:ValByName("proc_link","http://ourolux.totvs.com.br:10510/wf/" + _cMailID + ".htm") 
			oProcess:ohtml:ValByName("proc_link",_cHostWF + _cMailID + ".htm")

			oProcess:cTo := _cMailApr
			oProcess:bReturn := "U_APCRetorno"
		
			oProcess:Start()
		ElseIf ( nVezes == 3 )
			_cCodApr  := oProcess:aParams[ASCAN(oProcess:aParams,{|x| x[1] == oProcess:fTaskID})][4]
			_cMailApr := oProcess:aParams[ASCAN(oProcess:aParams,{|x| x[1] == oProcess:fTaskID})][2]
			CONOUT("Timeout3 - Cod Aprov: " + _cCodApr + " - E-mail Aprov: " + _cMailApr + " - Nivel Aprov: " + _cNivel)
		
			_cCodSts := "100800"
			_cDesc := "Reenviando aprovacao do pedido de compras no. " + _cNumPed
			CONOUT( "Timeout3 - " + _cCodSts + "-" + _cDesc )
		
			oProcess:NewTask(_cDesc,_cArqHtm)
			oProcess:cSubject := "(Timeout3)" + oProcess:cSubject
			// oProcess:ohtml:ValByName("proc_link","http://ourolux.totvs.com.br:10510/wf/" + _cMailID + ".htm") 
			oProcess:ohtml:ValByName("proc_link",_cHostWF + _cMailID + ".htm")

			oProcess:cTo := _cMailApr
			oProcess:bReturn := "U_APCRetorno"
		
			oProcess:Start()
		EndIf
	EndIf

Return

//**************************************************//
// MsgWFPC - Envia mensagem de aprovacao/reprovacao //
//**************************************************//
User Function MsgWFPC(_cTo,_cTit,_cCorpo)

	Local oProcess := NIL
	Local oHtml	   := NIL
	Local _cHtmMod := "\workflow\avisowf.htm"

	oProcess := TWFProcess():New( "MSGWFPC" , "Aviso WorkFlow PC" )
	oProcess:NewVersion(.T.)
	oProcess:NewTask( "WF Aviso ao Solicitante" , _cHtmMod )
	oProcess:cTo := _cTo
	oProcess:NewVersion(.T.)
	oProcess:cSubject := _cTit
	oHtml := oProcess:oHTML
	oHtml:ValByName( "MENSAGEM" , _cCorpo )

	oProcess:Start()

	oProcess:Finish()
	oProcess:Free()
	oProcess:=Nil

Return
