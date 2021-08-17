#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'TOPCONN.CH'

//----Method GO HORSE...................


USER FUNCTION AJUSTAF2()
  
Processa( {|| ProcC5() }, "Aguarde...", "Ajustando campos do cadastro de clientes.....",.F.)


Static Function ProcC5()

   
	cQuery := "SELECT DISTINCT(F2_DOC),F2_SERIE, F2_CLIENTE, F2_LOJA, F2_EMISSAO, F2_XDTCANH, D2_PEDIDO, C5_NUM, C5_CANHOTO" +CRLF
	cQuery += "FROM "+RetSqlName('SF2')+" SF2"+CRLF
    cQuery += "INNER JOIN "+RetSqlName('SD2')+" SD2"+CRLF
	cQuery += "ON SD2.D2_DOC = SF2.F2_DOC"+CRLF
	cQuery += "AND SD2.D2_SERIE = SF2.F2_SERIE"+CRLF		
	cQuery += "AND SD2.D2_CLIENTE = SF2.F2_CLIENTE"+CRLF		
	cQuery += "AND SD2.D2_LOJA = SF2.F2_LOJA"+CRLF		
	cQuery += "AND SD2.D2_FILIAL ='"+xFilial("SD2")+"'"+CRLF	
	cQuery += "AND SD2.D_E_L_E_T_ <> '*'"+CRLF
	cQuery += "INNER JOIN "+RetSqlName('SC5')+" SC5"+CRLF
	cQuery += "ON SC5.C5_NUM = SD2.D2_PEDIDO"+CRLF
	cQuery += "AND SC5.D_E_L_E_T_ <> '*'"+CRLF	    
   	cQuery += "WHERE SF2.F2_EMISSAO BETWEEN '20131001' AND '20131031'"+CRLF  //MUDAR A DATA AQUI...
	cQuery += "AND SF2.F2_VALBRUT > 0"+CRLF
	cQuery += "AND SF2.F2_FILIAL ='"+xFilial("SF2")+"'"+CRLF        
	cQuery += "AND SF2.D_E_L_E_T_ <> '*'"+CRLF
	AVISO("TESTE",cQuery,{"&OK"},3)
	
If Select("TSQL")	<> 0
	TSQL->(DbCloseArea())
Endif

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TSQL",.T.,.F.)

////////////////////////////////////////////////////////
//AJUSTA O CADASTRO DE CLIENTE
////////////////////////////////////////////////////////
dbSelectArea("TSQL")
ProcRegua(RecCount())

Do While TSQL->(!Eof())
            
		DbSelectArea("SF2")
		DbSetOrder(1) //F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA+F2_FORMUL+F2_TIPO
		IF DbSeek(xFilial("SF2")+TSQL->F2_DOC+TSQL->F2_SERIE+TSQL->F2_CLIENTE+TSQL->F2_LOJA)

   		Reclock("SF2",.F.)
	
   	   SF2->F2_XDTCANH 	:= STOD(TSQL->C5_CANHOTO)
	    
	    EndIf
   		 IncProc()
   		MsUnlock() 

TSQL->(dbSkip())
	      
End
    Alert("Acabou !!!")
Return()
