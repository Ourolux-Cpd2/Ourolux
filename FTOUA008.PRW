#include 'protheus.ch'
#include 'parmtype.ch'

//--------------------------------------------------------------------
/*/{Protheus.doc} FTOUA008
Geração de documento de CTE (documento de entrada SF1/SD1)
@author Caio
@since 18/02/2020
@version 1.0 
@type function
/*/
//--------------------------------------------------------------------

User Function TESTE008()

	U_FTOUA008(.F.,.F.,"","","01","01")
	
Return(Nil)

User Function FTOUA008(lReprocess, lLote, cIdReg, cIdPZC, cEmpPrep, cFilPrep)

Local cRotina          := "FTOUA008"
Local nQtdReg          := 0
Local cMenssagem	   := ""
Local cPastaXML	       := ""
Local cPastaIMP	       := "" 
Local cError   	       := ""
Local cWarning 	       := ""
Local oXml 		       := NIL
Local cQuery 		   := ""
Local cAlsPR1		   := ""
Local cChave	       := ""
Local cToken           := ""
Local lRetF            := .T.
Local cFunName         := ProcName(0)
Local cJson            := ""
Local cJsoRec          := ""
Local _cFil            := ""
Local cPrdFrete        := ""
Local lToma3Dest       := .F.
Local nX		       := 0
Local nPesoBruto       := 0
Local nPesoLiqui       := 0    
Local cFornCTe         := ""
Local cLojaCTe         := ""
Local cNomeCTe         := ""
Local cCPag_CT 	       := ""
Local cTipoFrete       := ""
Local aAux		       := {}
Local aEspecVol        := {}
Local cTpCte 		   := ""
Local cDoc	   		   := ""
Local cSerie   		   := ""
Local lVlrFrtZero	   := .F.
Local nVlrFrt		   := 0
Local cCFBN			   := ""
Local lRateiaDev	   := .F.
Local aLinha		   := {}
Local aCabec		   := {}
Local lPreNota	       := .F.
Local oICMS
Local oICMSTipo
Local oICMSNode
Local nZ		       := 0
Local nBaseICMS        := 0
Local nValICMS	       := 0
Local nAliqICMS	       := 0
Local lBaseICMS        := .F.
Local lValICMS	       := .F.
Local lAliqICMS	       := .F.
Local oRest		       := Nil
Local lReturn          := .F.
Local aArea            := GetArea()
Local aItens	       := {} 
Local cArqXML		   := ""
Private lMsHelpAuto    := .T.
Private lMsErroAuto    := .F.
Private dDATABASE      := DATE()
Private aGXG           := Array(40)
Default lLote		   := .F.
Default lReprocess	   := .F.
Default cIdReg		   := ""
Default cIdPZC		   := ""
Default cEmpPrep       := ""
Default cFilPrep       := "" 
	
	If !RpcSetEnv(cEmpPrep, cFilPrep)
		Conout("Falha na abertura de empresa " + cEmpPrep + cFilPrep)
	Endif
       
    aGXG[2] :=  "CTE" //GetMv("MV_ESPDF3") //GXG->GXG_CDESP - (Especie de Documento)
                     
    cCFBN		:= SuperGetMv("MV_XMLCFBN",.F.,"")
    lRateiaDev	:= SuperGetMv("MV_XMLRATD",.F.,.T.)
    lPreNota	:= SuperGetMV("MV_CTECLAS",.F.,.F.)

    //Requisicao do acesso
    oREST   := FTOUA003():New()
    oREST:RESTConn() 
    lReturn := oRest:lRetorno
    cToken  := oREST:cToken
    
    If !ChkFile("PR3")
        
        Conout("Falha na abertura da tabela PR3")
    
    //Elseif !lReturn
        
      //  Conout("Falha na autenticação Transpofrete")
    	
    
    Else
    	
    	cPastaXML := GetMv("FT_OUA008C",,"\TRANSPO\XML\")
    	cPastaIMP := GetMv("FT_OUA008C",,"\TRANSPO\XML\IMPORTADOS\")   

    	dDATABASE := DATE() 
        cAlsPR1	  := CriaTrab(Nil,.F.)
        
        //Verifica se existe dados a processar
         
	    cQuery := CRLF + RTrim(" SELECT PR1_FILIAL                    ")                       	
        cQuery += CRLF + RTrim("      , PR1_ALIAS                     ")                                                  	
        cQuery += CRLF + RTrim("      , PR1_RECNO                     ")                                                  	
        cQuery += CRLF + RTrim("      , PR1_CHAVE                     ")                                                  	
        cQuery += CRLF + RTrim("      , PR1_OBSERV                    ")  
        cQuery += CRLF + RTrim("      , R_E_C_N_O_ AS RECNOPR1        ")                                                     	
        cQuery += CRLF + RTrim("   FROM " + RetSqlName("PR1") + " PR1 ")
        cQuery += CRLF + RTrim("  WHERE PR1_ALIAS  = 'SF1'            ")
        cQuery += CRLF + RTrim("    AND PR1_STINT  = 'P'              ")
        cQuery += CRLF + RTrim("    AND D_E_L_E_T_ = ' '              ")
    
        If Select(cAlsPR1) > 0; (cAlsPR1)->(dbCloseArea()); Endif  
        dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlsPR1,.T.,.T.)
        
        Count to nQtdReg
        
        (cAlsPR1)->(DbGoTop())
        
        If (cAlsPR1)->(Eof())
        	
        	If GetMV("FT_CONOUTX",,.T.)
        		
        		Conout(ProcName(0) + " - " + DToC(Date()) + " - " + Time() + " - Não há dados para processamento.")
        		
        	Endif
        	
        Else
        
	        aCriaServ := U_MonitRes("000007", 1, nQtdReg)
			cIdPZB 	  := aCriaServ[2]

			nCount := 1
		
	        While !(cAlsPR1)->(Eof()) 
	    
	            cChave := AllTrim((cAlsPR1)->PR1_OBSERV)
	            
	            //PEGAR XML DA CTE
	            //aRequest := U_ResInteg("000005", , aHeader, , .F.,cChave+'?token='+cToken,3 )
	            
	            //PEGAR XML DA CTE
	            //aRequest := U_ResInteg("000010", , aHeader, , .F.,cChave+'?token='+cToken)	
	            //
	            //If aRequest[1] == .T.
				//	
				//	cMenssagem := "Integrado Protocolo: " + cValToChar(aRequest[2]:protocolo)
				//
	            //    //Retorno em forma de objeto
	            //    oRet    := aRequest[2]
	            //    //Retorno em forma de string
	            //    cJsoRec := aRequest[3]                                   
	            //GRAVANDO O LOG DA CONFIRMAÇÃO 
	            
	            lSemArq := .F.
				
				If !File(cPastaXML+cChave+".XML")
					
					If !File(cPastaXML+cChave+"-cte.XML")
						lSemArq := .T.
					Else
						cArqXML := cPastaXML+cChave+"-cte.XML"
					EndIf

				Else

					cArqXML := cPastaXML+cChave+".XML"
				
				EndIf
				
				If lSemArq
	            	
	            	U_MonitRes("000007", 2, , cIdPZB, "Arquivo não encontrado.", .F.,cChave,"","",cChave,lReprocess,lLote,cIdPZC)
	                
	        	Elseif Empty((cJsoRec := MemoRead(cArqXML)))
	        		
	        		U_MonitRes("000007", 2, , cIdPZB, "Falha na leitura do arquivo " + cArqXML + ".", .F.,cChave,"","",cChave,lReprocess,lLote,cIdPZC)
	        		
	        	Else
	        	
	                oXml := XmlParser( cJsoRec, "_", @cError, @cWarning ) 
	                                
	                if oXML == Nil
	                
	                	U_MonitRes("000007", 2, , cIdPZB, "Conteúdo do arquivo " + cArqXML + " inválido.", .F.,cChave,"","",cChave,lReprocess,lLote,cIdPZC)
	        		
	                Else
	                
	                    //_cte:_infcte:_REM:_CNPJ:TEXT       //oXml:_CTEPROC:_CTE:_INFCTE:_IDE:_CCT:TEXT
	                    _CTE 	 := oXml:_CTEPROC:_CTE:_INFCTE:_IDE:_CCT:TEXT
	                   
	                    _CNPJEmi := oXml:_CTEPROC:_CTE:_INFCTE:_EMIT:_CNPJ:TEXT
	                    
						If ATTISMEMBEROF(oXml:_CTEPROC:_CTE:_INFCTE:_REM,"_CNPJ") 
						
							If Left(oXml:_CTEPROC:_CTE:_INFCTE:_REM:_CNPJ:TEXT, 8) == "05393234" .Or. oXml:_CTEPROC:_CTE:_INFCTE:_REM:_CNPJ:TEXT == "68931419000109"
								_CNPJTom := oXml:_CTEPROC:_CTE:_INFCTE:_REM:_CNPJ:TEXT
							Else
								_CNPJTom := oXml:_CTEPROC:_CTE:_INFCTE:_DEST:_CNPJ:TEXT
							EndIf

						ElseIf ATTISMEMBEROF(oXml:_CTEPROC:_CTE:_INFCTE:_DEST,"_CNPJ") 

							_CNPJTom := oXml:_CTEPROC:_CTE:_INFCTE:_DEST:_CNPJ:TEXT

						EndIf

	                    _cFil  := fuFilial(_CNPJTom) 

						If _cFil <> cFilAnt
							cFilGuard := cFilAnt
							cFilAnt := _cFil
						EndIf

						If Empty(cFilAnt)
							
							cFilAnt := cFilGuard
							
							U_MonitRes("000007", 2, , cIdPZB, "Filial do tomador não encontrada no sigamat " + cArqXML + ".", .F.,cChave,"","",cChave,lReprocess,lLote,cIdPZC)

							(cAlsPR1)->(DbSkip()) 
							Loop

						EndIf			
	
	                    DbSelectArea("SA2")
	                    SA2->(DbSetOrder(3))
	                    If SA2->(MsSeek(xFilial("SA2") + _CNPJEmi))
	                        cFornCTe := SA2->A2_COD
	                        cLojaCTe := SA2->A2_LOJA
	                        cNomeCTe := SA2->A2_NOME
	                        IF SA2->A2_MSBLQL=='1'
	                            vMsgE := "Fornecedor bloqueado. Realize o desbloqueio "
	                            lRetF := .F.
	                        Else
	                            lRetF := .T.
	                        Endif
	                            
	                    Else 
	                    
	                        vMsgE := "Fornecedor inexistente na base. Gere cadastro para este fornecedor."
	                        lRetF	:= .F.
	
	                    Endif                    
	                    
	
	                    
	                    IF lRetF == .T.
	                        
	                        //cTagRem := If(ValType(oXml:_CTEPROC:_CTE:_INFCTE:_REM) == "O",If(ValType(oXml:_CTEPROC:_CTE:_INFCTE:_REM:_CNPJ) == "O","_CNPJ","_CPF"),"")
	                        
	                        cEmissao := SubStr(Strtran(oXml:_CTEPROC:_CTE:_INFCTE:_IDE:_DHEMI:TEXT,"-",""),1,8)
	                         
	                        // PRODUTO FRETE CTE PADRAO
	                        cPrdFrete := SuperGetMV("MV_XMLPFCT",.F.,"")
	                        cDoc	:= PadL(oXml:_CTEPROC:_CTE:_INFCTE:_IDE:_NCT:TEXT,TamSx3("F1_DOC")[1],"0")
	                        cSerie	:= PadR(oXml:_CTEPROC:_CTE:_INFCTE:_IDE:_SERIE:TEXT,SerieNfId("SF1",6,"F1_SERIE")) 
	                        cTpCTE	:= TIPOCTE116(oXml:_CTEPROC:_CTE:_INFCTE:_IDE:_TPCTE:TEXT)				// Tipo do CT-e.
	                        
							If ATTISMEMBEROF(oXml:_CTEPROC:_CTE:_INFCTE:_IDE,"_TOMA3") 
								cTagToma3	:= AllTrim(oXml:_CTEPROC:_CTE:_INFCTE:_IDE:_TOMA3:_TOMA:TEXT)
							EndIf
	                        
							If cTagToma3 == "3" //Destinatario
	                            lToma3Dest := .T.	// Destinatario da nota no processo de transferencia entre filiais
	                        Endif
	                        If lToma3Dest
	                            cTipoFrete := "F"
	                        Else
	                            cTipoFrete := "C"
	                        EndIf
	                        
	                        //Valor do frete
	                        If ValType(oXml:_CTEPROC:_CTE:_INFCTE:_VPREST) <> "U"
	                            If ValType(oXml:_CTEPROC:_CTE:_INFCTE:_VPREST:_VREC) <> "U" .And. ValType(oXml:_CTEPROC:_CTE:_INFCTE:_VPREST) <> "U"
	                                If Val(oXML:_CTEPROC:_CTE:_InfCte:_VPrest:_VRec:Text) == 0 .And. Val(oXML:_CTEPROC:_CTE:_InfCte:_VPrest:_vTPrest:Text) == 0
	                                    lVlrFrtZero := .T.
	                                Elseif Val(oXML:_CTEPROC:_CTE:_InfCte:_VPrest:_VRec:Text) == 0 .And. Val(oXML:_CTEPROC:_CTE:_InfCte:_VPrest:_vTPrest:Text) > 0
	                                    nVlrFrt := Val(oXML:_CTEPROC:_CTE:_InfCte:_VPrest:_vTPrest:Text)
	                                    lVlrFrtZero := .T.
	                                Else
	                                    nVlrFrt := Val(oXML:_CTEPROC:_CTE:_InfCte:_VPrest:_VRec:Text)
	                                Endif
	                            Endif
	                        Endif
	                        
	                        aAux       := Array(0)
	                        nPesoBruto := 0
	                        nPesoLiqui := 0
	                        nVolume    := 0
	                        
	                        If ATTISMEMBEROF(oXML:_CTEPROC:_CTE:_InfCte,"_INFCTENORM") 
	                        //-- Separa secao que contem as notas do conhecimento para laco
		                        If ValType(oXML:_CTEPROC:_CTE:_InfCte:_INFCTENORM) <> "U"
		                            aAux := If(ValType(oXML:_CTEPROC:_CTE:_InfCte:_InfCteNorm:_InfCarga:_InfQ) == "O",{oXML:_CTEPROC:_CTE:_InfCte:_InfCteNorm:_InfCarga:_InfQ},oXML:_CTEPROC:_CTE:_InfCte:_InfCteNorm:_InfCarga:_InfQ)
		                        Endif

								If ValType(oXML:_CTEPROC:_CTE:_InfCte:_InfCteNorm:_InfCarga:_InfQ) == "A"

							
									For nX := 1 To Len(oXML:_CTEPROC:_CTE:_InfCte:_InfCteNorm:_InfCarga:_InfQ)
										cDesc := Upper(AllTrim(oXml:_CTEPROC:_CTE:_INFCTE:_INFCTENORM:_INFCARGA:_INFQ[nX]:_TPMED:TEXT))
										If ("PESO" $ cDesc .And. "BRUTO" $ cDesc) .Or. ;
										("PESO" $ cDesc .And. "REAL" $ cDesc) 
											nPesoBruto := Val(oXml:_CTEPROC:_CTE:_INFCTE:_INFCTENORM:_INFCARGA:_INFQ[nX]:_QCARGA:TEXT)
										EndIf
										If ("PESO" $ cDesc .And. "LIQUI" $ cDesc)
											nPesoLiqui := Val(oXml:_CTEPROC:_CTE:_INFCTE:_INFCTENORM:_INFCARGA:_INFQ[nX]:_QCARGA:TEXT)
										EndIf
										If ("VOLUME" $ cDesc)
											nVolume := Val(oXml:_CTEPROC:_CTE:_INFCTE:_INFCTENORM:_INFCARGA:_INFQ[nX]:_QCARGA:TEXT)
										EndIf
										If !("PESO" $ Upper(oXml:_CTEPROC:_CTE:_INFCTE:_INFCTENORM:_INFCARGA:_INFQ[nX]:_TPMED:TEXT)) .And. Len(aEspecVol) < 5
											aAdd(aEspecVol,{AllTrim(oXml:_CTEPROC:_CTE:_INFCTE:_INFCTENORM:_INFCARGA:_INFQ[nX]:_TPMED:TEXT),Val(oXml:_CTEPROC:_CTE:_INFCTE:_INFCTENORM:_INFCARGA:_INFQ[nX]:_QCARGA:TEXT)})
										EndIf
									Next nX 

								Else

									cDesc := Upper(AllTrim(oXml:_CTEPROC:_CTE:_INFCTE:_INFCTENORM:_INFCARGA:_INFQ:_TPMED:TEXT))
									
									If ("PESO" $ cDesc .And. "BRUTO" $ cDesc) .Or. ;
									("PESO" $ cDesc .And. "REAL" $ cDesc) 
										nPesoBruto := Val(oXml:_CTEPROC:_CTE:_INFCTE:_INFCTENORM:_INFCARGA:_INFQ:_QCARGA:TEXT)
									EndIf
									If ("PESO" $ cDesc .And. "LIQUI" $ cDesc)
										nPesoLiqui := Val(oXml:_CTEPROC:_CTE:_INFCTE:_INFCTENORM:_INFCARGA:_INFQ:_QCARGA:TEXT)
									EndIf
									If ("VOLUME" $ cDesc)
										nVolume := Val(oXml:_CTEPROC:_CTE:_INFCTE:_INFCTENORM:_INFCARGA:_INFQ:_QCARGA:TEXT)
									EndIf
									If !("PESO" $ Upper(oXml:_CTEPROC:_CTE:_INFCTE:_INFCTENORM:_INFCARGA:_INFQ:_TPMED:TEXT)) .And. Len(aEspecVol) < 5
										aAdd(aEspecVol,{AllTrim(oXml:_CTEPROC:_CTE:_INFCTE:_INFCTENORM:_INFCARGA:_INFQ:_TPMED:TEXT),Val(oXml:_CTEPROC:_CTE:_INFCTE:_INFCTENORM:_INFCARGA:_INFQ:_QCARGA:TEXT)})
									EndIf

								EndIf

	                        Endif
	                        
	                        //RPCCLEARENV() //RETIRA CAIO
		                    //RETURN(NIL)   //RETIRA CAIO
		                    
	                        oCte := oXml:_CTEPROC:_CTE
		                    // Apuracao do ICMS para as diversas situacoes tributarias
		                    //If ValType(oXML:_CTEPROC:_CTE:_InfCte:_imp:_ICMS) <> "U"
		                    //    If ( oICMS := oXml:_CTEPROC:_CTE:_INFCTE:_IMP:_ICMS ) != Nil
		                    //        If ( oICMSTipo := XmlGetChild( oICMS, 1 )) != Nil
		                    //            For nZ := 1 To 5	// O nivel maximo para descer dentro da tag que define o tipo do ICMS para obter tanto base quanto valor é 5, conforme manual de orientacao do CTe
		                    //                If ( oICMSNode := XmlGetChild( oICMSTipo, nZ )) != Nil
		                    //                    If "vBC" $ oICMSNode:REALNAME
		                    //                        nBaseICMS := Val(oICMSNode:TEXT)
		                    //                        lBaseICMS := .T.
		                    //                    ElseIf "vICMS" $ oICMSNode:REALNAME
		                    //                        nValICMS := Val(oICMSNode:TEXT)
		                    //                        lValICMS := .T.
		                    //                    ElseIf "pICMS" $ oICMSNode:REALNAME
		                    //                        nAliqICMS := Val(oICMSNode:TEXT)
		                    //                        lAliqICMS := .T.
		                    //                    EndIf
		                    //                    If lBaseICMS .And. lValICMS .And. lAliqICMS
		                    //                        Exit
		                    //                    EndIf
		                    //                EndIf
		                    //            Next nZ
		                    //        EndIf
		                    //    EndIf
		                    //
		                    //EndIf
		                
		                    //RPCCLEARENV() //RETIRA CAIO
		                    //RETURN(NIL)   //RETIRA CAIO
		                    
	                        DbSelectArea("SF1")
	                        SF1->(dbSetOrder(1))                            
							
	                        _dEmissao := STOD(cEmissao)
	                        cTes      := "" 
	
	                        //Cabeçalho
	                        aCabec	:= {}
	                        aItens	:= {}
	                        aLinha	:= {} 
							 
							oCte     := oXml:_CTEPROC:_CTE
							cRetTip  := ""
							cRetOper := ""
							
							nPICMS    := 0
		                	nBaseICMS := 0
		                	nValICMS  := 0	
		                	
							//Trasferencia entre filiais
							If Left(_CNPJEmi,8) == Left(_CNPJTom,8)
								lTrfFil := .T.
							Else
								lTrfFil := .F.
							EndIf
							
							RetTpCte(oCte,@cRetTip,@cRetOper,cJsoRec,@nPICMS,@nBaseICMS,@nValICMS, SA2->A2_SIMPNAC, lTrfFil)
	 
							dbSelectArea("SFM")
							SFM->(dbSetOrder(1))
							
							If SFM->(dbSeek(xFilial("SFM")+cRetOper))
								If !Empty(SFM->FM_TE)
									cTes := SFM->FM_TE
								Else
									cTes := GetMv("FT_OUA008Z",,"")
								Endif
							Else
								cTes := GetMv("FT_OUA008Z",,"")
							Endif 
							
							DBSELECTAREA("SFM")
							DBCLOSEAREA()
	                        
	                        oCte    := oXml:_CTEPROC:_CTE:_infCte
	                        aGrvPR3 := Array(0)
	                        
	                        RetArrPR3(oCte,@aGrvPR3,cChave)   
						
							aadd(aCabec,{"F1_FILIAL"  ,	_cFil												,Nil})
							aadd(aCabec,{"F1_TIPO"    , cRetTip  	            							,Nil})
							aadd(aCabec,{"F1_FORMUL"  , "N"													,Nil})
	                        aadd(aCabec,{"F1_DOC"     , cDoc												,Nil})
	                        aadd(aCabec,{"F1_SERIE"   , cSerie												,Nil})
	                        aadd(aCabec,{"F1_EMISSAO" , _dEmissao											,Nil})
	                        aadd(aCabec,{"F1_DTDIGIT" , dDATABASE											,Nil})
	                        aadd(aCabec,{"F1_FORNECE" , cFornCTe											,Nil})
	                        aadd(aCabec,{"F1_LOJA"    , cLojaCTe											,Nil})
	                        aadd(aCabec,{"F1_ESPECIE" , "CTE"												,Nil}) //cEspecie
	                        aadd(aCabec,{"F1_CHVNFE"  , cChave												,Nil})
	                        aadd(aCabec,{"F1_HORA"    , TIME()       										,Nil})
	                        aadd(aCabec,{"F1_COND" 	  , cCPag_CT 											,Nil})
	                        aadd(aCabec,{"F1_MOEDA"	  , 1 													,Nil})
	                        aadd(aCabec,{"F1_TXMOEDA" , 1 													,Nil})
	                        aadd(aCabec,{"F1_STATUS"  , "A" 												,Nil})
	                        aAdd(aCabec,{"F1_BASERET" , nBaseICMS											,Nil})												// Valor da base de calculo do ICMS retido
	                        aAdd(aCabec,{"F1_ICMRET"  , nValICMS											,Nil})
	                        
	                        aAdd(aCabec,{"F1_UFORITR" , oXml:_CTEPROC:_CTE:_INFCTE:_rem:_enderReme:_UF:text					,Nil})												// Valor da base de calculo do ICMS retido
	                        aAdd(aCabec,{"F1_UFDESTR" , oXml:_CTEPROC:_CTE:_INFCTE:_dest:_enderDest:_UF:text				,Nil})
	                        aAdd(aCabec,{"F1_MUORITR" , SUBSTR(oXml:_CTEPROC:_CTE:_INFCTE:_rem:_enderReme:_cMun:text ,3,5)	,Nil}) //corrigir											// Valor da base de calculo do ICMS retido
	                        aAdd(aCabec,{"F1_MUDESTR" , SUBSTR(oXml:_CTEPROC:_CTE:_INFCTE:_dest:_enderDest:_cMun:text,3,5)	,Nil}) //corrigir
	                        
	                        aAdd(aCabec,{"F1_TPCTE"   , TIPOCTE116(oXml:_CTEPROC:_CTE:_INFCTE:_IDE:_TPCTE:TEXT)	,Nil})
	                        
	                        //aAdd(aCabec,{"F1_PBRUTO"   , nVolume	,Nil})
	                        //aAdd(aCabec,{"F1_PLIQUI"   , nPesoLiqui	,Nil})
	                        //aAdd(aCabec,{"F1_VOLUME1"  , nPesoBruto	,Nil})
	                        
	                        aAdd(aCabec,{"F1_ORIGEM"  , cRotina 												,Nil})
	                        
	                        //ITENS DA NF
	                                                
	                        dbSelectArea("SB1")
	                        dbSetOrder(1)
	                        dbSeek( xFilial("SB1")+cPrdFrete )
	                        
	                        aItens	:= {}
	                        aLinha	:= {}
	                        					
	                        aadd( aLinha, { "D1_COD" 	,cPrdFrete 	,Nil})
	                        aadd( aLinha, { "D1_UM" 	,"UN" 		,NIL})
	                        aadd( aLinha, { "D1_LOCAL"  ,"01" 		,NIL})
	                        
	                        If cRetTip $ "I/C"
	                        	
	                        	If Len(aGrvPR3) > 0
			                        
			                        DBSelectArea("SF1")
			                        SF1->(DBSetOrder(8)) 
			                        
			                        If SF1->(dbSeek(xfilial("SF1")+aGrvPR3[1,3]))

										If cRetTip == "C"

											aadd(aCabec,{"F1_TPCOMPL"	,"3"	,Nil})
											aadd(aCabec,{"F1_MODAL"		,"01"	,NIL})
											aadd(aCabec,{"F1_TPFRETE"	,"C" 	,NIL})
											aadd(aCabec,{"F1_TPCTE"		,"C" 	,NIL})

										EndIf
			                        	
			                        	aadd( aLinha, { "D1_FILORI" ,SF1->F1_FILIAL	,NIL}) 
			                        	aadd( aLinha, { "D1_NFORI"  ,SF1->F1_DOC   	,NIL})
			                        	aadd( aLinha, { "D1_SERIORI",SF1->F1_SERIE 	,NIL})
			                        	
			                        Endif	
	                        		
	                        	Endif
	                        	
	                        Else
	                        	aadd( aLinha, { "D1_QUANT"	,1,Nil})
	                        
	                        Endif
	                        
	                        nTotal := Val(oXML:_CTEPROC:_CTE:_InfCte:_VPrest:_VRec:Text)
	                        
	                        aadd( aLinha, { "D1_VUNIT"	,nTotal	,Nil})
	                        aadd( aLinha, { "D1_TOTAL"	,nTotal	,Nil}) 
	                        aadd( aLinha, { "D1_TES"	,CTES 												,Nil})
	                        aadd( aLinha, { "D1_BASEICM",nBaseICMS											,Nil})
	                        aadd( aLinha, { "D1_PICM"	,nPICMS												,Nil})
	                        //aadd( aLinha, { "D1_VALICM"	,nValICMS											,Nil})
	                        aadd( aLinha, { "AUTDELETA" ,"N" 												,Nil})
	                                        
							//nPICMS    := 0
		                	//nBaseICMS := 0
		                	//nValICMS  := 0	
		                	
	                        AADD(aItens,aLinha) 
	                        
	                        lMsErroAuto := .F.
	                        lMsHelpAuto := .F.
	                        
	                       //RPCCLEARENV() //RETIRA CAIO
	                       //RETURN(NIL)   //RETIRA CAIO
	                        
	                        DBSelectArea("SF1")
	                        SF1->(DBSetOrder(8)) 
	                          
	                        If !SF1->(dbSeek(xfilial("SF1")+cChave))
	                        	 
		                        MSExecAuto({|x,y,z| mata103(x,y,z)},aCabec,aItens,3) 
		                         
		                        If lMsErroAuto
		                        	
		                     		cDirArq := GetMv("FT_OUA008D",,"\transpo\erros\") 
									If !fwmakedir(cDirArq) 
										cDirArq := "\SYSTEM\"
									Endif
									If !ExistDir(cDirArq)
										cDirArq := "\SYSTEM\"
									Endif
									cNomArq := cFunName+"-"+DToS(Date())+"-"+StrTran(Time(),":","")+".log"
									
									cErro := VerErro(MostraErro(cDirArq,cNomArq),cDirArq,cNomArq)
									 
									If GetMv("FT_OUA008E",,!"DES" $ GETENVSERVER()) 
										FErase(cDirArq+cNomArq)
									Endif
									
		                            cMenssagem  := cErro
		                            U_MonitRes("000007",2,,cIdPZB,cMenssagem,.F., cChave,cJson, cJsoRec,cChave, lReprocess, lLote, cIdPZC)
		                              									
	                        	Else
		                        	
		                            PR1->(DBGOTO((cAlsPR1)->RECNOPR1))
		                            
		                            RecLock("PR1",.F.)
		                            
		                                PR1->PR1_DATINT := Date()
		                                PR1->PR1_HRINT	:= Time()		
		                                PR1->PR1_STINT  := "I"
		                                
		                            PR1->(MsUnlock())
		                            
		                            cHora := Substr(Time(),1,5) 
		                            
		                            For nX := 1 To Len(aGrvPR3)
		                            	
		                            	If PR3->(Reclock("PR3",.T.))
		                            	 	
		                            	 	PR3->PR3_FILIAL := SF1->F1_FILIAL
		                            	 	PR3->PR3_DOC    := SF1->F1_DOC
		                            	 	PR3->PR3_SERIE  := SF1->F1_SERIE
		                            	 	PR3->PR3_FORNEC := SF1->F1_FORNECE
		                            	 	PR3->PR3_LOJA   := SF1->F1_LOJA
		                            	 	PR3->PR3_CHVCTE := aGrvPR3[NX,2]
		                            	 	PR3->PR3_TIPO   := aGrvPR3[NX,1]
		                            	 	PR3->PR3_CHVPAR := aGrvPR3[NX,3]
		                            	 	PR3->PR3_HORA   := cHora
		                            	 	PR3->PR3_DATA   := DDATABASE 
		                            	 	PR3->PR3_RECNOO := SF1->(Recno())
		                            		
		                            		PR3->(MsUnlock())
		                            		
		                            	Endif
		                            	
		                            Next
		                            
		                            cMenssagem := "Importação de CTE realizado com sucesso."
		                            U_MonitRes("000007",2,,cIdPZB,cMenssagem,.T., cChave,cJson, cJsoRec,cChave, lReprocess, lLote, cIdPZC)
		                            
		                            If ExistDir(cPastaIMP) .Or. FwMakeDir(cPastaIMP)
		                            	
		                            	CORIGEM  := cArqXML
		                            	CDESTINO := cPastaIMP + RetFileName(cArqXML) + ".XML"
		                            	 
		                            	If __CopyFile(CORIGEM,CDESTINO)
		                            		
		                            		ferase(CORIGEM)
		                            		
		                            	Endif
		                            	
		                            Endif 
		                             
		                        EndIf
		                        
		                    Else
	                            
	                    		//ENCERRANDO PROCESSO DE ENVIO DO PEDIDO
	                            //DBSelectArea("PR1")
	                            //PR1->(DBSetOrder(2))
	                            //If PR1->(dbSeek((cAlsPR1)->PR1_FILIAL+(cAlsPR1)->PR1_ALIAS+(cAlsPR1)->PR1_CHAVE))
	                            
	                            PR1->(DBGOTO((cAlsPR1)->RECNOPR1))
	                                RecLock("PR1",.F.)
	                                PR1->PR1_DATINT := Date()
	                                PR1->PR1_HRINT	:= Time()		
	                                PR1->PR1_STINT  := "F"
	                            PR1->(MsUnlock())
	                            
	                            cMenssagem := "CTE " + CCHAVE + " importada anteriormente. SF1->(Recno()) = " + cValToChar(SF1->(Recno()))
	                            U_MonitRes("000007",2,,cIdPZB,cMenssagem,.F., cChave,cJson, cJsoRec,cChave, lReprocess, lLote, cIdPZC)
	                            
	                            //ferase(cArqXML)
	                             
							Endif 
							
	                        RestArea(aArea)
		                    
	                    Endif					
	                    
	                Endif   
	
	            Endif

				//If nCount == 10
				//	Exit
				//EndIf
	            	    
	            (cAlsPR1)->(DBSkip())

				nCount++
	                
			EndDo
			    
			//Finaliza o processo na PZB
			U_MonitRes("000007", 3, , cIdPZB, , .T.)
			
		Endif
	
		If !Empty(cAlsPR1)
			If Select(cAlsPR1) > 0
				dbSelectArea(cAlsPR1)
				dbCloseArea()
			Endif
		Endif
		
	Endif

Return(Nil)

//--------------------------------------------------------------------
/*/{Protheus.doc} fuFilial
//TODO Descrição auto-gerada.
@author Caio
@since 20/02/2020
@version 1.0 
@type function
/*/
//--------------------------------------------------------------------

Static Function fuFilial(cCNPJ)

Local _cFil		:= ""
Local aLoadSm0	:= {}
Local nPosEmp	:= 0

	aLoadSm0 := FWLoadSM0()

	nPosEmp := Ascan(aLoadSm0, {|x| Alltrim(x[18]) == Alltrim(cCNPJ) })	
	
	If nPosEmp > 0
		_cFil := aLoadSm0[nPosEmp][2]
	EndIf

Return _cFil

//-------------------------------------------------------------------
/*/{Protheus.doc} VerErro
Formata log obtido do retorno de ExecAuto
@since 08/01/2020
@version 1.0
@return cErrRet, characters, erro ExecAuto formatado
@param cErroAuto, characters, erro ExecAuto não formatado
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

//------------------------------------------------------------------
/*/{Protheus.doc} XmlValid
Valida tag do XML
@version 1.0
/*/
//------------------------------------------------------------------

Static Function XmlValid(oPar,aNode,cTag,lREALNAME)

Local nCont
Private oObj := oPar
Default lREALNAME := .F.

For nCont := 1 to Len(aNode)

	If ValType( XmlChildEx( oObj,aNode[nCont]  ) ) == 'O'
	oObj :=  XmlChildEx( oObj,aNode[nCont]  )
Else
	Return
Endif

If nCont == Len(aNode)
	If !lREALNAME
		cRet := &("oObj:"+cTag+':TEXT')
	Return cRet
Else
	cRet := &("oObj:REALNAME")
			Return cRet
		Endif
	EndIf

Next nCont

FreeObj(oObj)
FreeObj(xRet)
FreeObj(xRet1)

Return('')

//--------------------------------------------------------------------
/*/{Protheus.doc} RetTpCte
Retorna tipo do CTE e tipo operação (tipo FM_TIPO da TES inteligente)
@author Caio
@since 19/02/2020
@version 1.0 
/*/
//--------------------------------------------------------------------

Static Function RetTpCte(oCte,cRetTip,cRetOper,cJsoRec,nPICMS,nBaseICMS,nValICMS, cSimpNac, lTransf)

Local cCodCST  := ""
Local cCrdIcm  := ""	
Local cTpCte   := IIF(!EMPTY(Alltrim(XmlValid(oCTe,{"_INFCTE","_IDE","_TPCTE"},'',.T.))),oCTe:_INFCTE:_IDE:_TPCTE:TEXT,"")

Default cRetTip  := ""
Default cRetOper := ""
 	 
 	If ValType(oCte) != "U"

		If Alltrim(XmlValid(oCTe,{"_INFCTE","_IMP","_ICMS","_ICMS00"},'',.T.)) == 'ICMS00'
		
		  cCodCST := "00"
		  
		  nPICMS    := val(oCTe:_INFCTE:_IMP:_ICMS:_ICMS00:_pICMS:TEXT)
		  nBaseICMS := val(oCTe:_INFCTE:_IMP:_ICMS:_ICMS00:_vBC:TEXT)
		  nValICMS  := val(oCTe:_INFCTE:_IMP:_ICMS:_ICMS00:_vICMS:TEXT)
		  
		Elseif Alltrim(XmlValid(oCTe,{"_INFCTE","_IMP","_ICMS","_ICMS40"},'',.T.)) == 'ICMS40'
		
		  cCodCST := "40"
		  
		  nBaseICMS := val(oCTe:_INFCTE:_IMP:_ICMS:_ICMS40:_pICMS:TEXT)
		  nValICMS  := val(oCTe:_INFCTE:_IMP:_ICMS:_ICMS40:_vICMS:TEXT)
		  
		Elseif Alltrim(XmlValid(oCTe,{"_INFCTE","_IMP","_ICMS","_ICMS90"},'',.T.)) == 'ICMS60'
		
		  cCodCST := "60"
		  
		  nBaseICMS := val(oCTe:_INFCTE:_IMP:_ICMS:_ICMS60:_pICMS:TEXT)
		  nValICMS  := val(oCTe:_INFCTE:_IMP:_ICMS:_ICMS60:_vICMS:TEXT)
		  
		Elseif Alltrim(XmlValid(oCTe,{"_INFCTE","_IMP","_ICMS","_ICMS90"},'',.T.)) == 'ICMS90'
		
		  cCodCST := "90"
		  
		  nBaseICMS := val(oCTe:_INFCTE:_IMP:_ICMS:_ICMS90:_pICMS:TEXT)
		  nValICMS  := val(oCTe:_INFCTE:_IMP:_ICMS:_ICMS90:_vICMS:TEXT)
		  
		Elseif Alltrim(XmlValid(oCTe,{"_INFCTE","_IMP","_ICMS","_ICMSSN"},'',.T.)) == 'ICMSSN'
		
		  cCodCST := oCTe:_INFCTE:_IMP:_ICMS:_ICMSSN:_CST:TEXT
		  
		  nBaseICMS := 0
		  nValICMS  := 0
		  
		Endif

	 	If Empty(cCodCST)
	 	
		 	If !Empty(cJsoRec)
		 		
		 		If (nAt := At("<CST>",cJsoRec)) > 0
		 		
		 			cCodCST := Substr(cJsoRec,nAt+5,2)
		 		
		 		Endif
		 		
		 	Endif
	 	
	 	Endif
	 	
		If !Empty(cCodCST)
			
			cCrdIcm := Iif(cCodCST == "90", "N", "S")
			
			//****************************************************************
			//** ABAIXO VERIFICA O TIPO DA OPERAÇÃO - TES INTELIGENTE
			//****************************************************************
			
		    Do Case
				    
				Case (cCodCST == "00" .And. cCrdIcm == "S" .And. cSimpNac == "1") .Or. lTransf
					
					cRetOper := "T7"
				                
				Case cCodCST == "00" .And. cCrdIcm == "N"
				
				    cRetOper := "T8"
				                
				Case cCodCST == "40" .And. cSimpNac == "1"
				
				    cRetOper := "T6"
				                
				Case cCodCST == "60" .And. cCrdIcm == "S"
				
				    cRetOper := "T3"
				                
				Case cCodCST == "60" .And. cCrdIcm == "N"
				
				    cRetOper := "T5"
				                
				Case cCodCST == "90" .And. cCrdIcm == "S"
				
				    cRetOper := "T8"
				                
				OtherWise
				
				    cRetOper := "T1"
				                                   
		    EndCase 
			
			//****************************************************************
			//** ABAIXO VERIFICA O TIPO DA CTE
			//****************************************************************
			
			If !Empty(cTpCte)
				
			    Do Case
					    
					Case cTpCte == "0"
					
						cRetTip := "N"
						
					/*Case cTpCte == "1" .And. cCodCST == "00"
					
						cRetTip := "I"*/
						
					Case cTpCte == "1" //.And. cCodCST != "00" 
					
						cRetTip := "C" 
					                
					OtherWise
					
					    cRetTip := ""
					                                   
			    EndCase 
			    
		    Endif
		    
	   Endif
	   
   Endif

Return({cRetOper,cRetTip,cCodCST})

//--------------------------------------------------------------------
/*/{Protheus.doc} RetArrPR3
Retorna array com 3 posicoes sendo
[1] alias
[2] chave cte
[3] chave cte ou nfe origem
Para inclusao na tabela PR3
@author Caio
@since 19/02/2020
@version 1.0 
/*/
//--------------------------------------------------------------------

Static Function RetArrPR3(oCte,aGrvPR3,cChave)

Default oCte    := Nil
Default aGrvPR3 := {}
Default cChave  := ""
	
	If ValType(oCte) == "O"
		
	    If ATTISMEMBEROF(oCte,"_infCteComp") 
	    	
	    	oCte := oCte:_infCteComp
	    	
	    	If ValType(oCte) == "O"
	    		
	    		If ATTISMEMBEROF(oCte,"_chCTe")
	            		
					aAdd(aGrvPR3,{"SF1"   ;
					             ,cChave  ;
					             ,oCte:_chCTe:Text})
					             
	    		Endif
	    	
	    	Elseif ValType(oCte) = "A"
	    		
	    		For nX := 1 To Len(oCte) 
	        			
	        		If ATTISMEMBEROF(oCte[nX],"_chCTe")
	                		
	    				aAdd(aGrvPR3,{"SF1"   ;
	    				             ,cChave  ;
	    				             ,oCte[nX]:_chCTe:Text})
	    				             
	        		Endif
	        		
	    		Next
	    		
	    	Endif
	    	
	    Elseif ATTISMEMBEROF(oCte,"_infCTeNorm")
	    	
	    	oCte := oCte:_infCTeNorm
	    	
	    	If ATTISMEMBEROF(oCte,"_infDoc")
	        	
	        	oCte := oCte:_infDoc
	        	
	            If ATTISMEMBEROF(oCte,"_infNFE")
	            	
	            	oCte := oCte:_infNFE
	            	
	            	If ValType(oCte) == "O"
	            		
	            		If ATTISMEMBEROF(oCte,"_CHAVE")
	                    		
	        				aAdd(aGrvPR3,{"SF2"   ;
	        				             ,cChave  ;
	        				             ,oCte:_chave:Text})
	        				             
	            		Endif
	            	
	            	Elseif ValType(oCte) = "A"
	            		
	            		For nX := 1 To Len(oCte) 
	                			
	                		If ATTISMEMBEROF(oCte[nX],"_CHAVE")
	                        		
	            				aAdd(aGrvPR3,{"SF2"   ;
	            				             ,cChave  ;
	            				             ,oCte[nX]:_chave:Text})
	            				             
	                		Endif
	                		
	            		Next
	            		
	            	Endif
	            	
	            Endif 
	            
	    	Endif
	        
		Endif
		
	Endif
	
Return(aGrvPR3)