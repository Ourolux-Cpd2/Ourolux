#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � MEGA27() � Autor �Claudino P Domingues   � Data �13/09/2013���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Relatorio de CTRs Pagos e Nao Pagos.                       ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function MEGA27()

	Local oReport
	
	If TRepInUse()	
		oReport := ReportDef()
		/*����������������������������������Ŀ
		� Imprime os dados na Tela(Preview). �
		������������������������������������*/
		oReport:PrintDialog()
	EndIf
	
Return

/*
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
����������������������������������������������������������������������������Ŀ��
���Funcao    � ReportDef() � Autor �Claudino P Domingues   � Data �13/09/2013���
����������������������������������������������������������������������������Ĵ��
���Descri��o � Montagem do Objetos do TREPORT.                               ���
�����������������������������������������������������������������������������ٱ�
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
*/

Static Function ReportDef()
    
	Private cPerg  := PADR("MEGA27",10) 
	
	/*��������������������������������������������������������������������Ŀ
	� Apresenta a tela de impress�o para o usuario configurar o relatorio. �
	����������������������������������������������������������������������*/
	oReport:=TReport():New(cPerg,"Relat�rio NF Sa�da X CTRs Pagos e N�o Pagos",cPerg,{|oReport| PrintReport(oReport)},"Relat�rio NF Sa�da X CTRs Pagos e N�o Pagos")
	oReport:SetLandscape(.T.)    
	oSection:=TRSection():New(oReport,"Relat�rio NF Sa�da X CTRs Pagos e N�o Pagos",{""})
    
    /*���������Ŀ
	� Pergunte. �
	�����������*/
	AjustaSX1() 
	Pergunte(oReport:uParam,.T.)
	
  	TRCell():New(oSection,"NFVEN"		,/*cAlias*/,"NF.Saida"		,PesqPict("SF2","F2_DOC")		,TamSX3("F2_DOC")[1]		,/*lPixel*/ ,/*{|| code-black de impress�o}*/ , , ,"LEFT")
	TRCell():New(oSection,"SERIEVEN"	,/*cAlias*/,"Ser.NF"		,PesqPict("SF2","F2_SERIE") 	,TamSX3("F2_SERIE")[1]		,/*lPixel*/ ,/*{|| code-black de impress�o}*/ , , ,"LEFT")
	TRCell():New(oSection,"CODLJCLI"	,/*cAlias*/,"Cod/Lj Cli"	,"@!"                        	,10							,/*lPixel*/ ,/*{|| code-black de impress�o}*/ , , ,"LEFT")
	TRCell():New(oSection,"NOMECLI"		,/*cAlias*/,"Nome.Cli"		,PesqPict("SA1","A1_NOME")  	,TamSX3("A1_NOME")[1]		,/*lPixel*/ ,/*{|| code-black de impress�o}*/ , , ,"LEFT")
	TRCell():New(oSection,"DTEMISSAONF"	,/*cAlias*/,"Emissao.NF"	,PesqPict("SF2","F2_EMISSAO")	,TamSX3("F2_EMISSAO")[1]	,/*lPixel*/ ,/*{|| code-black de impress�o}*/ , , ,"LEFT")
	TRCell():New(oSection,"CTRCTE"		,/*cAlias*/,"Num.Conhec"	,PesqPict("SF1","F1_DOC") 		,TamSX3("F1_DOC")[1] 		,/*lPixel*/ ,/*{|| code-black de impress�o}*/ , , ,"LEFT")
	TRCell():New(oSection,"SERCTRCTE"	,/*cAlias*/,"Ser.Conhec"	,PesqPict("SF1","F1_SERIE")		,TamSX3("F1_SERIE")[1]   	,/*lPixel*/ ,/*{|| code-black de impress�o}*/ , , ,"LEFT")
	TRCell():New(oSection,"DTDIGCONH"	,/*cAlias*/,"Dt.Dig.Conhec"	,PesqPict("SF1","F1_DTDIGIT")	,TamSX3("F1_DTDIGIT")[1] 	,/*lPixel*/ ,/*{|| code-black de impress�o}*/ , , ,"LEFT")
	TRCell():New(oSection,"CODLJTRANS"	,/*cAlias*/,"Cod/Lj Trans"	,"@!"							,10                       	,/*lPixel*/ ,/*{|| code-black de impress�o}*/ , , ,"LEFT")	
	TRCell():New(oSection,"NOMETRANS"	,/*cAlias*/,"Nome.Trans"   	,PesqPict("SA2","A2_NOME")		,TamSX3("A2_NOME")[1]    	,/*lPixel*/ ,/*{|| code-black de impress�o}*/ , , ,"LEFT")
	TRCell():New(oSection,"DTVENCP"		,/*cAlias*/,"Dt.Venc.CP"	,PesqPict("SE2","E2_VENCTO")	,TamSX3("E2_VENCTO")[1]		,/*lPixel*/ ,/*{|| code-black de impress�o}*/ , , ,"LEFT")
	TRCell():New(oSection,"DTPAGCP"		,/*cAlias*/,"Dt.Baixa.CP"  	,PesqPict("SE2","E2_BAIXA")		,TamSX3("E2_BAIXA")[1]		,/*lPixel*/ ,/*{|| code-black de impress�o}*/ , , ,"LEFT")
		                                 
Return oReport

/*
������������������������������������������������������������������������������������������������
������������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������Ŀ��
��� Funcao      � PrintReport(<Parametro>) � Autor �Claudino P Domingues   � Data �13/09/2013���
��������������������������������������������������������������������������������������������Ĵ��
��� <Parametro> � oReport - Objeto Principal do TREPORT                                      ���
��������������������������������������������������������������������������������������������Ĵ��
��� Descri��o   � Montagem do Objetos do TREPORT.                                            ���
���������������������������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������������������������
������������������������������������������������������������������������������������������������
*/

Static Function PrintReport(oReport)
    
	Local oSection := oReport:Section(1)   
	
	Private aDados  := {}
	
	Processa( {|| ProcQry() }, "Aguarde...", "Filtrando registros...",.F.)
	
	oSection:Init()
	oReport:IncMeter()
	
	For n:= 1 To Len(aDados)
	    oReport:IncMeter()
	   
	    oSection:Cell("NFVEN")       :SetValue(aDados[n][1])
		oSection:Cell("SERIEVEN")    :SetValue(aDados[n][2])  
		oSection:Cell("CODLJCLI")    :SetValue(aDados[n][3])
		oSection:Cell("NOMECLI")     :SetValue(aDados[n][4])
		oSection:Cell("DTEMISSAONF") :SetValue(aDados[n][5])
		
		If Empty(aDados[n][6]) 
			oSection:Cell("CTRCTE")     :SetValue("")
			oSection:Cell("SERCTRCTE")  :SetValue("")
			oSection:Cell("DTDIGCONH")  :SetValue("")
			oSection:Cell("CODLJTRANS") :SetValue("")
			oSection:Cell("NOMETRANS")  :SetValue("")
			oSection:Cell("DTVENCP")    :SetValue("")
			oSection:Cell("DTPAGCP")    :SetValue("")
		ElseIf !Empty(aDados[n][6])
		    oSection:Cell("CTRCTE")     :SetValue(aDados[n][6])
			oSection:Cell("SERCTRCTE")  :SetValue(aDados[n][7])
			oSection:Cell("DTDIGCONH")  :SetValue(aDados[n][8])
			oSection:Cell("CODLJTRANS") :SetValue(aDados[n][9] + "/" + aDados[n][10])
			oSection:Cell("NOMETRANS")  :SetValue(aDados[n][11])
			oSection:Cell("DTVENCP")    :SetValue(aDados[n][12]) 
			oSection:Cell("DTPAGCP")    :SetValue(aDados[n][13]) 
	    EndIf
		
		/*������������������������������������Ŀ
   		� Imprimindo linha com as Informacoes. �
		��������������������������������������*/
		oSection:PrintLine()
	Next n
	
	oSection:Finish()
	
Return

**********************

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � ProcQry() � Autor �Claudino P Domingues  � Data �13/09/2013���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Filtro Relatorio.                                          ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Static Function ProcQry()

	Local nQuant      := 0 
	Local cQuery      := ""
	
	Local cNfVen      := "" 
	Local cSerieVen   := ""
	Local cCodLjCli   := ""	
	Local cNomeCli    := ""
	Local dDtEmissNf  := CTOD("")
	Local cCTRCTE     := ""	
	Local cSerCTRCTE  := ""
	Local dDtDigConh  := CTOD("")
	Local cCodTrans   := ""
    Local cLjTrans    := ""
	Local cNomeTrans  := ""	
	Local dDtVenCP    := CTOD("")
	Local dDtPagCP    := CTOD("")	
	Local cPrefFat    := ""
	Local cNumFat     := ""
	Local cCodForFat  := ""
	Local cLjForFat   := ""
    
    /*
    SELECT 
        F2_DOC AS SAIDA,
        F2_EMISSAO AS EMISS,
        ISNULL(D1_DOC,' ') AS CONHE,
        ISNULL(D1_SERIE,' ') AS SERCONH,
        ISNULL(D1_TES,' ') AS TESCONH,
        ISNULL(D1_FORNECE,' ') AS CODTRANS,
        ISNULL(D1_LOJA,' ') AS LJTRANS,
        ISNULL(D1_DTDIGIT,' ') AS DTDIGCONH
    FROM 
    	SF2010 SF2 
    LEFT JOIN 
 		SD1010 SD1 
   	ON 
    	SD1.D_E_L_E_T_ <> '*' AND
     	F2_FILIAL = D1_FILIAL AND 
      	F2_DOC+F2_SERIE = D1_NFORI+D1_SERIORI AND
       	D1_TES = '163'
	WHERE  
 		SF2.D_E_L_E_T_ <> '*' AND 
        F2_FILIAL = '01' AND
        (F2_EMISSAO BETWEEN '20130801' AND '20130831') AND 
        (F2_DOC BETWEEN '         ' AND 'ZZZZZZZZZ') AND 
        (F2_SERIE BETWEEN '   ' AND 'ZZ ') 
   ORDER BY 
   		F2_DOC,
     	F2_EMISSAO  
    */
    
    cQuery := " SELECT "
    
    cQuery += "		F2_DOC AS SAIDA, "
    cQuery += "		F2_EMISSAO AS EMISS, "
    cQuery += "		ISNULL(D1_DOC,' ') AS CONHE, "
    cQuery += "		ISNULL(D1_SERIE,' ') AS SERCONH, "
    cQuery += "		ISNULL(D1_TES,' ') AS TESCONH, "
    cQuery += "		ISNULL(D1_FORNECE,' ') AS CODTRANS, "
    cQuery += "		ISNULL(D1_LOJA,' ') AS LJTRANS, "
    cQuery += " 	ISNULL(( "
    cQuery += "				SELECT "
    cQuery += " 				A2_NREDUZ "
    cQuery += " 			FROM  "
    cQuery += 					RetSqlName("SA2") + " SA2 " 
    cQuery += " 			WHERE "
    cQuery += " 				SA2.A2_COD+SA2.A2_LOJA = SD1.D1_FORNECE+SD1.D1_LOJA),'') AS NOMTRANS, "
    cQuery += "		ISNULL(D1_DTDIGIT,' ') AS DTDIGCONH "
	
	cQuery += " FROM " 
	cQuery += 		RetSqlName("SF2") + " SF2 " 
    
    cQuery += "	LEFT JOIN " 
	cQuery += 		RetSqlName("SD1") + " SD1 "
   	cQuery += "	ON "
    cQuery += "		SD1.D_E_L_E_T_ <> '*' AND "
    cQuery += " 	F2_FILIAL = D1_FILIAL AND "
    cQuery += "  	F2_DOC+F2_SERIE = D1_NFORI+D1_SERIORI AND "
    cQuery += "   	D1_TES = '163' "
	
	cQuery += "	WHERE " 
 	cQuery += "		SF2.D_E_L_E_T_ = ' ' AND "  
	cQuery += "     F2_FILIAL = '" + xFilial("SF2") + "' AND "
	cQuery += "		(F2_EMISSAO BETWEEN '" + DTOS(MV_PAR01) + "' AND '" + DTOS(MV_PAR02) + "') AND "
	cQuery += "		(F2_DOC BETWEEN '" + MV_PAR03 + "' AND '" + MV_PAR04 + "')  AND "	
	cQuery += "		(F2_SERIE BETWEEN '" + MV_PAR05 + "' AND '" + MV_PAR06 + "') " 
    
    cQuery += " ORDER BY " 
    cQuery += "		F2_DOC, "
    cQuery += "		F2_EMISSAO "
   
	If Select("NFCTR") <> 0
		dbSelectArea("NFCTR")
		NFCTR->(DbCloseArea())
	EndIf
    
    cQuery := ChangeQuery(cQuery)
    
	DbUseArea(.T.,"TOPCONN",TCGenQry( ,,cQuery ),"NFCTR",.F.,.T.)
        
	dbSelectArea("NFCTR")
	NFCTR->(dbGotop())
    ProcRegua(nQuant)
    
	While NFCTR->(!Eof()) 
		
		IncProc("Filtrando Registros, aguarde... "  + StrZero(nQuant,6))
  		
  		cNfVen := NFCTR->SAIDA
			
		/*�����������������������������������������������������������������������������������Ŀ
		� Fazer Tratamento Filial RIO. Imprimindo Serie da Venda de acordo com Filial Logada. �
		�������������������������������������������������������������������������������������*/
		If cFilAnt == "01"
			cSerieVen := "5  "
		ElseIf cFilAnt == "02"
			cSerieVen := "4  "
		EndIf
			
		DbSelectArea("SF2")
		SF2->(DbSetOrder(4))
		
		/*����������������������������������������������������Ŀ
		� Posiciona venda e pega o codigo e a loja do cliente. �
		������������������������������������������������������*/	
		If SF2->(DbSeek(xFilial("SF2")+cSerieVen+NFCTR->EMISS+NFCTR->SAIDA))
			cCodLjCli := SF2->F2_CLIENTE+"/"+SF2->F2_LOJA	
		EndIf
		
		/*�����������������������������������Ŀ
		� Posiciona no cliente e pega o nome. �
		�������������������������������������*/	
		DbSelectArea("SA1")
		cNomeCli  := POSICIONE("SA1",1,xFilial("SA1")+SF2->F2_CLIENTE+SF2->F2_LOJA,"A1_NOME")
			
		dDtEmissNf  := STOD(NFCTR->EMISS)
		
		If !Empty(NFCTR->CONHE)
			cCTRCTE     := NFCTR->CONHE	  
			cSerCTRCTE  := NFCTR->SERCONH
			dDtDigConh  := STOD(NFCTR->DTDIGCONH)
			cCodTrans   := NFCTR->CODTRANS
        	cLjTrans    := NFCTR->LJTRANS
			cNomeTrans  := NFCTR->NOMTRANS
		
			DbSelectArea("SE2")
			SE2->(DbSetOrder(6))
			
			If SE2->(DbSeek(xFilial("SE2")+NFCTR->CODTRANS+NFCTR->LJTRANS+NFCTR->SERCONH+NFCTR->CONHE))
				If Empty(SE2->E2_FATURA)
	  				dDtVenCP := SE2->E2_VENCTO
					dDtPagCP := SE2->E2_BAIXA
				Else
					cPrefFat   := SE2->E2_FATPREF
					cNumFat    := SE2->E2_FATURA
					cCodForFat := SE2->E2_FATFOR
					cLjForFat  := SE2->E2_FATLOJ
					           			
					DbSelectArea("SE2")
					SE2->(DbSetOrder(6))
				
					If SE2->(DbSeek(xFilial("SE2")+cCodForFat+cLjForFat+cPrefFat+cNumFat))
			    		dDtVenCP    := SE2->E2_VENCTO
						dDtPagCP    := SE2->E2_BAIXA
		    		EndIf
				EndIf
			EndIf
		EndIf		
		
		/*�������������������������������������Ŀ
		� Todas NF Saida(Com Conhec/Sem Conhec) �
		���������������������������������������*/
		If MV_PAR11 == 3 
		    
		    /*�����������������Ŀ
			� Valida Com Conhec �
			�������������������*/
			If !Empty(cCTRCTE)
		        
		        /*�����������������������������Ŀ
				� Todos Conhec(Pagos/Nao Pagos) �
				�������������������������������*/
		        If MV_PAR12 == 3 
		            
		            /*���������������������Ŀ
			   		� Filtra Transportadora �
			   		�����������������������*/
					If (cCodTrans >= MV_PAR07 .And. cCodTrans <= MV_PAR09) .And. ;
		 	           (cLjTrans >= MV_PAR08 .And. cLjTrans <= MV_PAR10)
		
  						AADD(aDados,{	cNfVen,;
        								cSerieVen,;
        								cCodLjCli,;
        								cNomeCli,;
        								dDtEmissNf,;
        								cCTRCTE,;
        								cSerCTRCTE,;
        								dDtDigConh,;
        								cCodTrans,;
        								cLjTrans,;
        								cNomeTrans,;
        								dDtVenCP,;
        								dDtPagCP	})
        	 
       					nQuant++				    
      		
					EndIf
                
                Else
                    
                	/*�����������������Ŀ
					� Conhec(Nao Pagos) �
					�������������������*/
                	If MV_PAR12 == 2
                        
                    	/*������������������������Ŀ
						� Valida Conhec(Nao Pagos) �
						��������������������������*/
                		If Empty(dDtPagCP)
                            
                            /*���������������������Ŀ
			   				� Filtra Transportadora �
			   				�����������������������*/
                    		If (cCodTrans >= MV_PAR07 .And. cCodTrans <= MV_PAR09) .And. ;
		 	           		   (cLjTrans >= MV_PAR08 .And. cLjTrans <= MV_PAR10)
                    			
                    			AADD(aDados,{	cNfVen,;
        										cSerieVen,;
        										cCodLjCli,;
        										cNomeCli,;
        										dDtEmissNf,;
        										cCTRCTE,;
        										cSerCTRCTE,;
        										dDtDigConh,;
        										cCodTrans,;
        										cLjTrans,;
        										cNomeTrans,;
        										dDtVenCP,;
        										dDtPagCP	})
        	 
        						nQuant++
             		     	
             		     	EndIf
             			
             			EndIf
             		
             		/*�������������Ŀ
					� Conhec(Pagos) �
					���������������*/
             		ElseIf MV_PAR12 == 1
                    	
                    	/*��������������������Ŀ
						� Valida Conhec(Pagos) �
						����������������������*/
                    	If !Empty(dDtPagCP)
                        	
                        	/*���������������������Ŀ
			   				� Filtra Transportadora �
			   				�����������������������*/
                        	If (cCodTrans >= MV_PAR07 .And. cCodTrans <= MV_PAR09) .And. ;
		 	           		   (cLjTrans >= MV_PAR08 .And. cLjTrans <= MV_PAR10)
                        	
                        		AADD(aDados,{	cNfVen,;
        										cSerieVen,;
        										cCodLjCli,;
        										cNomeCli,;
        										dDtEmissNf,;
        										cCTRCTE,;
        										cSerCTRCTE,;
        										dDtDigConh,;
        										cCodTrans,;
        										cLjTrans,;
        										cNomeTrans,;
        										dDtVenCP,;
        										dDtPagCP	})
        	 
        						nQuant++
                     
                        	EndIf   
                    
                    	EndIf
                    	
                    EndIf
                
                EndIf
            
        	/*����������Ŀ
			� Sem Conhec �
			������������*/
        	Else
        
        		AADD(aDados,{	cNfVen,;
        						cSerieVen,;
        						cCodLjCli,;
        						cNomeCli,;
        						dDtEmissNf,;
        						cCTRCTE,;
        						cSerCTRCTE,;
        						dDtDigConh,;
        						cCodTrans,;
        						cLjTrans,;
        						cNomeTrans,;
        						dDtVenCP,;
        						dDtPagCP	})
                
        		nQuant++
        
        	EndIf
        
        Else 
        
		    /*��������������������Ŀ
			� NF Saida(Sem Conhec) �
			����������������������*/
		    If MV_PAR11 == 2
				
				/*�����������������Ŀ
				� Valida Sem Conhec �
				�������������������*/
				If Empty(cCTRCTE)
         			
   					AADD(aDados,{	cNfVen,;
        							cSerieVen,;
        							cCodLjCli,;
        							cNomeCli,;
        							dDtEmissNf,;
        							cCTRCTE,;
        							cSerCTRCTE,;
        							dDtDigConh,;
        							cCodTrans,;
        							cLjTrans,;
        							cNomeTrans,;
        							dDtVenCP,;
        							dDtPagCP	})
        		
        			nQuant++
        							
         		EndIf
            
            /*��������������������Ŀ
			� NF Saida(Com Conhec) �
			����������������������*/
            ElseIf MV_PAR11 == 1
                
                /*�����������������Ŀ
				� Valida Com Conhec �
				�������������������*/
            	If !Empty(cCTRCTE)
                    
            		/*�����������������������������Ŀ
					� Todos Conhec(Pagos/Nao Pagos) �
					�������������������������������*/
            		If MV_PAR12 == 3
		                
		            	/*���������������������Ŀ
			   			� Filtra Transportadora �
			   			�����������������������*/
						If (cCodTrans >= MV_PAR07 .And. cCodTrans <= MV_PAR09) .And. ;
		 	               (cLjTrans >= MV_PAR08 .And. cLjTrans <= MV_PAR10)
		
  							AADD(aDados,{	cNfVen,;
        									cSerieVen,;
        									cCodLjCli,;
        									cNomeCli,;
        									dDtEmissNf,;
        									cCTRCTE,;
        									cSerCTRCTE,;
        									dDtDigConh,;
        									cCodTrans,;
        									cLjTrans,;
        									cNomeTrans,;
        									dDtVenCP,;
        									dDtPagCP	})
        	 
        					nQuant++				    
      		
						EndIf
                
                	/*�����������������Ŀ
					� Conhec(Nao Pagos) �
					�������������������*/
                	ElseIf MV_PAR12 == 2
                        
                    	/*������������������������Ŀ
						� Valida Conhec(Nao Pagos) �
						��������������������������*/
                		If Empty(dDtPagCP)
                            
                            /*���������������������Ŀ
			   				� Filtra Transportadora �
			   				�����������������������*/
                  			If (cCodTrans >= MV_PAR07 .And. cCodTrans <= MV_PAR09) .And. ;
		 	             	   (cLjTrans >= MV_PAR08 .And. cLjTrans <= MV_PAR10)
                    
                    			AADD(aDados,{	cNfVen,;
        										cSerieVen,;
        										cCodLjCli,;
        										cNomeCli,;
        										dDtEmissNf,;
        										cCTRCTE,;
        										cSerCTRCTE,;
        										dDtDigConh,;
        										cCodTrans,;
        										cLjTrans,;
        										cNomeTrans,;
        										dDtVenCP,;
        										dDtPagCP	})
        	 
        						nQuant++
                           
                           	EndIf
                    
                    	EndIf
                    
                    /*�������������Ŀ
					� Conhec(Pagos) �
					���������������*/	
                    ElseIf MV_PAR12 == 1
                        
                        /*��������������������Ŀ
						� Valida Conhec(Pagos) �
						����������������������*/
                		If !Empty(dDtPagCP)
                			
                			/*���������������������Ŀ
			   				� Filtra Transportadora �
			   				�����������������������*/
                			If (cCodTrans >= MV_PAR07 .And. cCodTrans <= MV_PAR09) .And. ;
		 	             	   (cLjTrans >= MV_PAR08 .And. cLjTrans <= MV_PAR10)
                    
                    			AADD(aDados,{	cNfVen,;
        										cSerieVen,;
        										cCodLjCli,;
        										cNomeCli,;
        										dDtEmissNf,;
        										cCTRCTE,;
        										cSerCTRCTE,;
        										dDtDigConh,;
        										cCodTrans,;
        										cLjTrans,;
        										cNomeTrans,;
        										dDtVenCP,;
        										dDtPagCP	})
        	 
        						nQuant++
                           
                           	EndIf
                		
                		EndIf
                
                	EndIf
            
            	EndIf
            
        	EndIf
        
        EndIf
    
		cNfVen      := "" 
		cSerieVen   := ""
		cCodLjCli   := ""	
		cNomeCli    := ""
		dDtEmissNf  := CTOD("")
		cCTRCTE     := ""	
		cSerCTRCTE  := ""
		dDtDigConh  := CTOD("")
		cCodTrans   := ""
		cLjTrans    := ""
		cNomeTrans  := ""	
		dDtVenCP    := CTOD("")
		dDtPagCP    := CTOD("")
		cPrefFat    := ""
	 	cNumFat     := ""
	 	cCodForFat  := ""
		cLjForFat   := ""
    
		If !Empty(NFCTR->CONHE)
			If Select("SE2") <> 0
   				dbSelectArea("SE2")
   				SE2->(DbCloseArea())
			EndIf
		EndIf
			
		If Select("SA1") <> 0
	   		dbSelectArea("SA1")
	   		SA1->(DbCloseArea())
		EndIf
		
		If Select("SF2") <> 0
	   		dbSelectArea("SF2")
	   		SF2->(DbCloseArea())
		EndIf
		
  		NFCTR->(dbSkip())
       
	EndDo
    
	If Select("NFCTR") > 0
		DbSelectArea("NFCTR")
		NFCTR->(DbCloseArea())
	EndIf

Return	
	
/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Funcao    � AjustaSX1() � Autor �Claudino P Domingues  � Data �13/09/2013���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Acerta o arquivo de perguntas.                               ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/

Static Function AjustaSX1()
    
    /*----------------------------------------------------------------------------------------------------------------------
	� Parametros que devem ser passados para a funcao de criacao das perguntas no arquivo SX1.                              �
	�-----------------------------------------------------------------------------------------------------------------------�
	�  7 � Parametro -> Tipo do dado C=caractere, D=Data, N=Numerico                                                        �
	� 10 � Parametro -> Numero da pre-selecao                                                                               �
	� 11 � Parametro -> O tipo do dado sera G=Get, S=Scroll, C=Choice, R=Range                                              �
	� 12 � Parametro -> Sintaxe em advpl, ou funcao para validacao                                                          �
	� 14 � Parametro -> Nome do grupo �ra SXG                                                                               �
	� 15 � Parametro -> Pyme                                                                                                �
	� 16 � Parametro -> Nome da variavel que sera utilizada no programa                                                     �
	� 17 � Parametro -> Primeira definicao do texto em portugues se caso o tipo do dado for choice, exemplo: SIM ou NAO     �
	� 18 � Parametro -> Primeira definicao do texto em espanhol se caso o tipo do dado for choice, exemplo: SI ou NO        �
	� 19 � Parametro -> Primeira definicao do texto em ingles se caso o tipo do dado for choice, exemplo: YES ou NO         �
	� 20 � Parametro -> Conteudo da ultima resposta informada no parametro se caso o tipo do dados for get                  �
	� 21 � Parametro -> Segunda definicao do texto em portugues se caso o tipo do dado for choice, exemplo: SIM ou NAO      �
	� 22 � Parametro -> Segunda definicao do texto em espanhol se caso o tipo do dado for choice, exemplo: SI ou NO         �
	� 23 � Parametro -> Segunda definicao do texto em ingles se caso o tipo do dado for choice, exemplo: YES ou NO          �
	� 24 � Parametro -> Terceira definicao do texto em portugues se caso o tipo do dado for choice, exemplo: SIM ou NAO     �
	� 25 � Parametro -> Terceira definicao do texto em espanhol se caso o tipo do dado for choice, exemplo: SI ou NO        �
	� 26 � Parametro -> Terceira definicao do texto em ingles se caso o tipo do dado for choice, exemplo: YES ou NO         �
	� 27 � Parametro -> Quarta definicao do texto em portugues se caso o tipo do dado for choice, exemplo: SIM ou NAO       �
	� 28 � Parametro -> Quarta definicao do texto em espanhol se caso o tipo do dado for choice, exemplo: SI ou NO          �
	� 29 � Parametro -> Quarta definicao do texto em ingles se caso o tipo do dado for choice, exemplo: YES ou NO           �
	� 30 � Parametro -> Quinta definicao do texto em portugues se caso o tipo do dado for choice, exemplo: SIM ou NAO       �
	� 31 � Parametro -> Quinta definicao do texto em espanhol se caso o tipo do dado for choice, exemplo: SI ou NO          �
	� 32 � Parametro -> Quinta definicao do texto em ingles se caso o tipo do dado for choice, exemplo: YES ou NO           �
	� 36 � Parametro -> Nome do grupo do help                                                                               �
	-----------------------------------------------------------------------------------------------------------------------*/
	
	Local aHelp := {}
	
	// Texto do help em    portugues                           , ingles, espanhol
	
	AADD(aHelp,{{"Data de Emiss�o da NF Sa�da (de)"}          ,{""}   ,{""}})
	AADD(aHelp,{{"Data de Emiss�o da NF Sa�da (ate)"}         ,{""}   ,{""}})
	AADD(aHelp,{{"NF Sa�da (de)"}                             ,{""}   ,{""}})
	AADD(aHelp,{{"NF Sa�da (ate)"}                            ,{""}   ,{""}})
	AADD(aHelp,{{"S�rie NF Sa�da (de)"}                       ,{""}   ,{""}})
	AADD(aHelp,{{"S�rie NF Sa�da (ate)"}                      ,{""}   ,{""}})
	AADD(aHelp,{{"Transportadora NF Sa�da (de)"}              ,{""}   ,{""}})
	AADD(aHelp,{{"Loja Transportadora (de)"}                  ,{""}   ,{""}})
	AADD(aHelp,{{"Transportadora NF Sa�da (ate)"}             ,{""}   ,{""}})
	AADD(aHelp,{{"Loja Transportadora (ate)"}                 ,{""}   ,{""}})
	AADD(aHelp,{{"NF Sa�da Com Conhec, Sem Conhec ou Todas."} ,{""}   ,{""}})    
	AADD(aHelp,{{"Conhec Pagos, N�o Pagos ou Todos."}         ,{""}   ,{""}}) 
	        
	//     1Grup 2Ordem 3TituloPergPortugu      4TituloPergEspanho 5TituloPergIngles 6NomeVaria   7  8Tam  9dec 10  11  12   13F3  14 15  16        17             18 19  20 21             22 23 24        25 26 27  28 29 30 31 32 33HelpPort    34HelpIngl   35HelpEsp     36
	
	PutSx1(cPerg,"01"  ,"Data de ?"            ,""                ,""               ,"mv_ch1"  ,"D", 08  ,00  ,00,"G" ,"" ,""   ,"","","MV_PAR01",""            ,"","","",""            ,"","",""       ,"","","","","","","","",aHelp[1,1]  ,aHelp[1,2]  ,aHelp[1,3]  ,"" )
	PutSx1(cPerg,"02"  ,"Data ate ?"           ,""                ,""               ,"mv_ch2"  ,"D", 08  ,00  ,00,"G" ,"" ,""   ,"","","MV_PAR02",""            ,"","","",""            ,"","",""       ,"","","","","","","","",aHelp[2,1]  ,aHelp[2,2]  ,aHelp[2,3]  ,"" )
	PutSx1(cPerg,"03"  ,"Nota de ?"            ,""                ,""               ,"mv_ch3"  ,"C", 09  ,00  ,00,"C" ,"" ,"SF2","","","MV_PAR03",""            ,"","","",""            ,"","",""       ,"","","","","","","","",aHelp[3,1]  ,aHelp[3,2]  ,aHelp[3,3]  ,"" )
	PutSx1(cPerg,"04"  ,"Nota ate ?"           ,""                ,""               ,"mv_ch4"  ,"C", 09  ,00  ,00,"C" ,"" ,"SF2","","","MV_PAR04",""            ,"","","",""            ,"","",""       ,"","","","","","","","",aHelp[4,1]  ,aHelp[4,2]  ,aHelp[4,3]  ,"" )
	PutSX1(cPerg,"05"  ,"Serie de ?"           ,""                ,""               ,"mv_ch5"  ,"C", 03  ,00  ,00,"G" ,"" ,""   ,"","","MV_PAR05",""            ,"","","",""            ,"","",""       ,"","","","","","","","",aHelp[5,1]  ,aHelp[5,2]  ,aHelp[5,3]  ,"" )
	PutSX1(cPerg,"06"  ,"Serie ate ?"          ,""                ,""               ,"mv_ch6"  ,"C", 03  ,00  ,00,"G" ,"" ,""   ,"","","MV_PAR06",""            ,"","","",""            ,"","",""       ,"","","","","","","","",aHelp[6,1]  ,aHelp[6,2]  ,aHelp[6,3]  ,"" )
	PutSx1(cPerg,"07"  ,"Transportadora de ?"  ,""                ,""               ,"mv_ch7"  ,"C", 06  ,00  ,00,"C" ,"" ,"SA2","","","MV_PAR07",""            ,"","","",""            ,"","",""       ,"","","","","","","","",aHelp[7,1]  ,aHelp[7,2]  ,aHelp[7,3]  ,"" )
	PutSx1(cPerg,"08"  ,"Loja de ?"            ,""                ,""               ,"mv_ch8"  ,"C", 02  ,00  ,00,"G" ,"" ,""   ,"","","MV_PAR08",""            ,"","","",""            ,"","",""       ,"","","","","","","","",aHelp[8,1]  ,aHelp[8,2]  ,aHelp[8,3]  ,"" )
	PutSx1(cPerg,"09"  ,"Transportadora ate ?" ,""                ,""               ,"mv_ch9"  ,"C", 06  ,00  ,00,"C" ,"" ,"SA2","","","MV_PAR09",""            ,"","","",""            ,"","",""       ,"","","","","","","","",aHelp[9,1]  ,aHelp[9,2]  ,aHelp[9,3]  ,"" )
	PutSx1(cPerg,"10"  ,"Loja ate ?"           ,""                ,""               ,"mv_cha"  ,"C", 02  ,00  ,00,"G" ,"" ,""   ,"","","MV_PAR10",""            ,"","","",""            ,"","",""       ,"","","","","","","","",aHelp[10,1] ,aHelp[10,2] ,aHelp[10,3] ,"" )
	PutSx1(cPerg,"11"  ,"Imprime NF Sa�da ?"   ,""                ,""               ,"mv_chb"  ,"N", 01  ,00  ,00,"C" ,"" ,""   ,"","","MV_PAR11","1-Com Conhec","","","","2-Sem Conhec","","","3-Todas","","","","","","","","",aHelp[11,1] ,aHelp[11,2] ,aHelp[11,3] ,"" )	
	PutSx1(cPerg,"12"  ,"Imprime Conhec ?"     ,""                ,""               ,"mv_chc"  ,"N", 01  ,00  ,00,"C" ,"" ,""   ,"","","MV_PAR12","1-Pagos"     ,"","","","2-N�o Pagos" ,"","","3-Todos","","","","","","","","",aHelp[12,1] ,aHelp[12,2] ,aHelp[12,3] ,"" )	
    
Return