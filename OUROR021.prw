#INCLUDE "PROTHEUS.CH"  
//--------------------------------------------------------------------
/*/{Protheus.doc} OUROR021
Relatorio TReport

@author Rodrigo Nunes
@since 08/07/2020
/*/
//--------------------------------------------------------------------
User Function OUROR021()

//Local clPerg	:= "RELFLX"
Local oReport

//If Pergunte(clPerg)
    oReport := ReportDef()
    oReport:PrintDialog()
//EndIf

Return

//--------------------------------------------------------------------
/*/{Protheus.doc} ReportDef
Relatorio TReport

@author Rodrigo Nunes
@since 08/07/2020
/*/
//--------------------------------------------------------------------
Static Function ReportDef(clPerg)   

Local oReport
Local oSection	

oReport := TReport():New("Relatorio fluxo de caixa","Relatorio fluxo de caixa","OUROR021",{|oReport| PrintReport(oReport)},"Relatorio fluxo de caixa")
//oReport:SetLandscape() - Orientacao da folha - Paisagem 	
oSection := TRSection():New(oReport ,"",{"QRYFLX"})
		
Return oReport
   
//--------------------------------------------------------------------
/*/{Protheus.doc} PrintReport
Relatorio TReport

@author Rodrigo Nunes
@since 08/07/2020
/*/
//--------------------------------------------------------------------
Static Function PrintReport(oReport)
                                        
Local oSection 			:= oReport:Section(1) 
Local clQuery  			:= "" 

clQuery := " SELECT E1_FILIAL  FILIAL, "
clQuery += "        'R'        TP, "
clQuery += "       E1_NATUREZ NATUREZ, "
clQuery += "       ED_DESCRIC DESC_NAT, "
clQuery += "       E1_PREFIXO PREFIXO, "
clQuery += "       E1_NUM     TITULO, "
clQuery += "       E1_PARCELA PARC, "
clQuery += "       E1_TIPO    TIPO, "
clQuery += "       E1_CLIENTE CODIGO, " 
clQuery += "       E1_LOJA    LOJA, "
clQuery += "       E1_NOMCLI  NOME, "
clQuery += "       E1_EMISSAO EMISSAO, " 
clQuery += "       E1_VENCTO  VENCIMENTO, "
clQuery += "       E1_VENCREA VENC_REAL, "
clQuery += "       E1_MOEDA   MOEDA, "
clQuery += "       E1_VALOR   VALOR_ORIGINAL, "
clQuery += "       E1_SALDO   SALDO_RECEBER, "
clQuery += "       0          SALDO_PAGAR, "
clQuery += "       E1_HIST    HIST "
clQuery += " FROM " + RetSqlName("SE1") + " E1 "
clQuery += "       LEFT JOIN SED010 ED "
clQuery += "              ON E1_NATUREZ = ED_CODIGO "
clQuery += "                 AND ED.D_E_L_E_T_ = ' ' "
clQuery += "WHERE  E1.D_E_L_E_T_ = ' ' "
clQuery += "       AND E1_VENCREA BETWEEN '"+DTOS(MV_PAR01)+"' AND '"+DTOS(MV_PAR02)+"' "
clQuery += "       AND E1_SALDO >= 0 "
clQuery += "UNION ALL "
clQuery += "SELECT E2_FILIAL  FILIAL, "
clQuery += "       'P'        TP, "
clQuery += "       E2_NATUREZ NATUREZ, "
clQuery += "       ED_DESCRIC DESC_NAT, "
clQuery += "       E2_PREFIXO PREFIXO, "
clQuery += "       E2_NUM     TITULO, "
clQuery += "       E2_PARCELA PARC, "
clQuery += "       E2_TIPO    TIPO, "
clQuery += "       E2_FORNECE CODIGO, " 
clQuery += "       E2_LOJA    LOJA, "
clQuery += "       E2_NOMFOR  NOME, "
clQuery += "       E2_EMISSAO EMISSAO, "
clQuery += "       E2_VENCTO  VENCIMENTO, "
clQuery += "       E2_VENCREA VENC_REAL, "
clQuery += "       E2_MOEDA   MOEDA, "
clQuery += "       E2_VALOR   VALOR_ORIGINAL, "
clQuery += "       0          SALDO_RECEBER, "
clQuery += "       E2_SALDO   SALDO_PAGAR, "
clQuery += "       E2_HIST    HIST "
clQuery += "FROM " + RetSqlName("SE2") + " E2 "
clQuery += "       LEFT JOIN " + RetSqlName("SED") + " ED "
clQuery += "              ON E2_NATUREZ = ED_CODIGO "
clQuery += "                 AND ED.D_E_L_E_T_ = ' ' "
clQuery += "WHERE  E2.D_E_L_E_T_ = ' ' "
clQuery += "       AND E2_VENCREA BETWEEN '"+DTOS(MV_PAR01)+"' AND '"+DTOS(MV_PAR02)+"' "
clQuery += "       AND E2_SALDO >= 0 "
clQuery += "ORDER  BY 1, "
clQuery += "          2 DESC, "
clQuery += "          3, "
clQuery += "          14 "

clQuery := ChangeQuery(clQuery)

If Select("QRYFLX") > 0
    QRYFLX->(dbCloseArea())
EndIf 	

dbUseArea( .T., "TopConn", TCGenQry(,,clQuery), "QRYFLX", .F., .F. ) 

oReport:SetMeter( QRYFLX->(LastRec() )) 
   	
     
TRCell():New(oSection,	"FILIAL"	   		,"QRYFLX"   ,OEMTOANSI("FILIAL")            ,		                ,TamSX3("E2_FILIAL")[1]     ,/*lPixel*/,/*{||  }*/,"CENTER",/*lLineBreak*/,"CENTER"	)	
TRCell():New(oSection,	"TP"			    ,"QRYFLX"   ,OEMTOANSI("TP")                ,		                ,5	                        ,/*lPixel*/,/*{||  }*/,"CENTER",/*lLineBreak*/,"CENTER"	)	
TRCell():New(oSection,	"NATUREZ"			,"QRYFLX"   ,OEMTOANSI("NATUREZ")           ,		                ,TamSX3("E2_NATUREZ")[1]    ,/*lPixel*/,/*{||  }*/,"CENTER",/*lLineBreak*/,"CENTER"	)	
TRCell():New(oSection,	"DESC_NAT"			,"QRYFLX"   ,OEMTOANSI("DESC_NAT")          ,		                ,TamSX3("ED_DESCRIC")[1]    ,/*lPixel*/,/*{||  }*/,"CENTER",/*lLineBreak*/,"CENTER"	)	
TRCell():New(oSection,	"PREFIXO"			,"QRYFLX"   ,OEMTOANSI("PREFIXO")           ,		   	            ,TamSX3("E2_PREFIXO")[1]	,/*lPixel*/,/*{||  }*/,"CENTER",/*lLineBreak*/,"CENTER"	)
TRCell():New(oSection,	"TITULO"		    ,"QRYFLX"   ,OEMTOANSI("TITULO")            ,	   	                ,TamSX3("E2_NUM")[1]	    ,/*lPixel*/,/*{||  }*/,"CENTER",/*lLineBreak*/,"CENTER"	)	
TRCell():New(oSection,	"PARC"		   		,"QRYFLX"   ,OEMTOANSI("PARC")			    ,					    ,TamSX3("E2_PARCELA")[1]	,/*lPixel*/,/*{||  }*/,"CENTER",/*lLineBreak*/,"CENTER"	)	
TRCell():New(oSection,	"TIPO"			    ,"QRYFLX"   ,OEMTOANSI("TIPO")		        ,					    ,TamSX3("E2_TIPO")[1]	    ,/*lPixel*/,/*{||  }*/,"CENTER",/*lLineBreak*/,"CENTER"	)	
TRCell():New(oSection,	"CODIGO"	   		,"QRYFLX"   ,OEMTOANSI("CODIGO")		    ,			            ,TamSX3("E2_FORNECE")[1]	,/*lPixel*/,/*{||  }*/,"CENTER",/*lLineBreak*/,"CENTER"	)	
TRCell():New(oSection,	"LOJA"		        ,"QRYFLX"   ,OEMTOANSI("LOJA")	            ,			            ,TamSX3("E2_LOJA")[1]	    ,/*lPixel*/,/*{||  }*/,"CENTER",/*lLineBreak*/,"CENTER"	)	
TRCell():New(oSection,	"NOME"			    ,"QRYFLX"   ,OEMTOANSI("NOME")		        ,						,TamSX3("E2_NOMFOR")[1]     ,/*lPixel*/,/*{||  }*/,"CENTER",/*lLineBreak*/,"CENTER"	)	  
TRCell():New(oSection,	"EMISSAO"			,"QRYFLX"   ,OEMTOANSI("EMISSAO")			,						,TamSX3("E2_EMISSAO")[1]    ,/*lPixel*/,/*{||  }*/,"CENTER",/*lLineBreak*/,"CENTER"	)	  
TRCell():New(oSection,	"VENCIMENTO"		,"QRYFLX"   ,OEMTOANSI("VENCIMENTO")		,						,TamSX3("E2_VENCTO")[1]     ,/*lPixel*/,/*{||  }*/,"CENTER",/*lLineBreak*/,"CENTER"	)	  
TRCell():New(oSection,	"VENC_REAL"			,"QRYFLX"   ,OEMTOANSI("VENC_REAL")			,						,TamSX3("E2_VENCREA")[1]    ,/*lPixel*/,/*{||  }*/,"CENTER",/*lLineBreak*/,"CENTER"	)	  
TRCell():New(oSection,	"MOEDA"				,"QRYFLX"   ,OEMTOANSI("MOEDA")				,						,TamSX3("E2_MOEDA")[1]      ,/*lPixel*/,/*{||  }*/,"CENTER",/*lLineBreak*/,"CENTER"	)	  
TRCell():New(oSection,	"VALOR_ORIGINAL"    ,"QRYFLX"   ,OEMTOANSI("VALOR_ORIGINAL")    ,	,TamSX3("E2_VALOR")[1]      ,/*lPixel*/,/*{||  }*/,"CENTER",/*lLineBreak*/,"CENTER"	)	  
TRCell():New(oSection,	"SALDO_RECEBER"		,"QRYFLX"   ,OEMTOANSI("SALDO_RECEBER")		,    ,TamSX3("E2_VALOR")[1]      ,/*lPixel*/,/*{||  }*/,"CENTER",/*lLineBreak*/,"CENTER"	)	  
TRCell():New(oSection,	"SALDO_PAGAR"		,"QRYFLX"   ,OEMTOANSI("SALDO_PAGAR")		,	,TamSX3("E2_SALDO")[1]      ,/*lPixel*/,/*{||  }*/,"CENTER",/*lLineBreak*/,"CENTER"	)	  
TRCell():New(oSection,	"HIST"				,"QRYFLX"   ,OEMTOANSI("HIST")				,						,TamSX3("E2_HIST")[1]       ,/*lPixel*/,/*{||  }*/,"CENTER",/*lLineBreak*/,"CENTER"	)	  

oSection:Cell("FILIAL"):SetHeaderAlign("CENTER")
oSection:Cell("TP"):SetHeaderAlign("CENTER")
oSection:Cell("NATUREZ"):SetHeaderAlign("CENTER") 
oSection:Cell("DESC_NAT"):SetHeaderAlign("CENTER") 
oSection:Cell("PREFIXO"):SetHeaderAlign("CENTER")
oSection:Cell("TITULO"):SetHeaderAlign("CENTER")
oSection:Cell("PARC"):SetHeaderAlign("CENTER")  
oSection:Cell("TIPO"):SetHeaderAlign("CENTER") 
oSection:Cell("CODIGO"):SetHeaderAlign("CENTER")
oSection:Cell("LOJA"):SetHeaderAlign("CENTER")
oSection:Cell("NOME"):SetHeaderAlign("CENTER") 
oSection:Cell("EMISSAO"):SetHeaderAlign("CENTER") 
oSection:Cell("VENCIMENTO"):SetHeaderAlign("CENTER")
oSection:Cell("VENC_REAL"):SetHeaderAlign("CENTER")
oSection:Cell("MOEDA"):SetHeaderAlign("CENTER") 
oSection:Cell("VALOR_ORIGINAL"):SetHeaderAlign("CENTER") 
oSection:Cell("SALDO_RECEBER"):SetHeaderAlign("CENTER")
oSection:Cell("SALDO_PAGAR"):SetHeaderAlign("CENTER")
oSection:Cell("HIST"):SetHeaderAlign("CENTER") 

oSection:PrintLine()
    
oSection:Init()     

//Preenchimento do relatorio
While QRYFLX->(!EOF())
    
    oSection:Cell("FILIAL"):SetValue(QRYFLX->FILIAL) 
    oSection:Cell("TP"):SetValue(QRYFLX->TP)	
    oSection:Cell("NATUREZ"):SetValue(QRYFLX->NATUREZ)
    oSection:Cell("DESC_NAT"):SetValue(QRYFLX->DESC_NAT)  
    oSection:Cell("PREFIXO"):SetValue(QRYFLX->PREFIXO)
    oSection:Cell("TITULO"):SetValue(QRYFLX->TITULO)
    oSection:Cell("PARC"):SetValue(QRYFLX->PARC) 
    oSection:Cell("TIPO"):SetValue(QRYFLX->TIPO)
    oSection:Cell("CODIGO"):SetValue(QRYFLX->CODIGO)
    oSection:Cell("LOJA"):SetValue(QRYFLX->LOJA)			
    oSection:Cell("NOME"):SetValue(QRYFLX->NOME)			
    oSection:Cell("EMISSAO"):SetValue(STOD(QRYFLX->EMISSAO))
    oSection:Cell("VENCIMENTO"):SetValue(STOD(QRYFLX->VENCIMENTO))  			                                                   			
    oSection:Cell("VENC_REAL"):SetValue(STOD(QRYFLX->VENC_REAL))  			                                                   			
    oSection:Cell("MOEDA"):SetValue(cValToChar(QRYFLX->MOEDA))  			                                                   			
    oSection:Cell("VALOR_ORIGINAL"):SetValue(TRANSFORM(QRYFLX->VALOR_ORIGINAL, "@E 999,999,999.99"))
    oSection:Cell("SALDO_RECEBER"):SetValue(TRANSFORM(QRYFLX->SALDO_RECEBER, "@E 999,999,999.99"))  			                                                   			
    oSection:Cell("SALDO_PAGAR"):SetValue(TRANSFORM(QRYFLX->SALDO_PAGAR, "@E 999,999,999.99"))  			                                                   			
    oSection:Cell("HIST"):SetValue(QRYFLX->HIST)
    
    oSection:PrintLine()
    
    QRYFLX->(dbSkip()) 				
    
End Do 

oSection:PrintLine()		

oSection:Finish() 
Return  
