#INCLUDE "PROTHEUS.CH"

user function TK062LIS()
LOCAL aRET:= {}   
Local aParams :=  PARAMIXB 
Local cCODINI	:= 000000
Local cCODFIM	:= 999999

IF SELECT("TBR") > 0
	DBSELECTAREA("TBR")
	DBCLOSEAREA()
ENDIF                                   

aCampos := {}
AADD(aCampos,{ "BR_FILIAL" ,"C",02,0 } )
AADD(aCampos,{ "BR_LISTA"  ,"C",06,0 } )
AADD(aCampos,{ "BR_CODIGO" ,"C",06,0 } )
AADD(aCampos,{ "BR_FILENT" ,"C",02,0 } )
AADD(aCampos,{ "BR_ENTIDA" ,"C",03,0 } )
AADD(aCampos,{ "BR_CODENT" ,"C",25,0 } )
AADD(aCampos,{ "BR_ORIGEM" ,"C",01,0 } )
AADD(aCampos,{ "BR_CONTATO","C",06,0 } )
AADD(aCampos,{ "BR_DATA"   ,"D",08,0 } )
AADD(aCampos,{ "BR_HRINI"  ,"C",05,0 } )
AADD(aCampos,{ "BR_HRFIM"  ,"C",05,0 } )
AADD(aCampos,{ "BR_STATUS" ,"C",01,0 } )
AADD(aCampos,{ "BR_TOTAL"  ,"N",14,2 } )
                                                                    
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Cria arquivo de trabalho                                     �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
cNomArq 	:=  CriaTrab(aCampos)  
dbUseArea( .T.,, cNomArq,"TBR", .F. , .F. )

cNomArq1 := Subs(cNomArq,1,7)+"A"
IndRegua("TBR",cNomArq1,"BR_CODIGO",,,)		//"Selecionando Registros..."
dbClearIndex()          

cNomArq2 := Subs(cNomArq,1,7)+"B"
IndRegua("TBR",cNomArq2,"BR_TOTAL",,,)		//"Selecionando Registros..."
dbClearIndex()          


dbSetIndex(cNomArq1+OrdBagExt())
dbSetIndex(cNomArq2+OrdBagExt())

dbselectarea("TBR")
DBSETORDER(1)

IF SELECT("TMP") > 0
	DBSELECTAREA("TMP")
	DBCLOSEAREA()
ENDIF

FOR NX := 1 TO LEN(PARAMIXB[1])       

	IF NX == 1 
		cCODINI	:= PARAMIXB[1][NX][3]
	ELSE
		cCODFIM	:= PARAMIXB[1][NX][3]
	ENDIF

    cFILIAL		:= PARAMIXB[1][NX][1]
    cLISTA		:= PARAMIXB[1][NX][2]
    cFILENT		:= PARAMIXB[1][NX][4]
    cENTIDA		:= PARAMIXB[1][NX][5]
	cCLIENTE	:= SUBS(PARAMIXB[1][NX][6],1,6)
	cLOJA		:= SUBS(PARAMIXB[1][NX][6],7,2)
	cORIGEM		:= PARAMIXB[1][NX][7]
	cCONTATO	:= PARAMIXB[1][NX][8]
	dDATA		:= PARAMIXB[1][NX][9]
	cHRINI		:= PARAMIXB[1][NX][10]
	cHRFIM		:= PARAMIXB[1][NX][11]
	cSTATUS		:= PARAMIXB[1][NX][12]                             
	
	cQUERY	:= "SELECT K1_CLIENTE, K1_LOJA, SUM(K1_SALDO) AS SALDO "
	cQUERY	+= "FROM " + RetSqlName("SK1") + " SK1 "
	cQUERY	+= "WHERE SK1.D_E_L_E_T_ <> '*' "
	cQUERY	+= "AND SK1.K1_VENCREA BETWEEN '"+DTOS(MV_PAR07)+"' AND '"+DTOS(MV_PAR08)+"' " 
	cQUERY	+= "AND SK1.K1_CLIENTE = '"+cCLIENTE+"' "
	cQUERY	+= "AND SK1.K1_LOJA = '"+cLOJA+"' "
	cQUERY	+= "GROUP  BY K1_CLIENTE, K1_LOJA "
	cQUERY	+= "ORDER BY K1_CLIENTE, K1_LOJA " 
	DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery) , 'TMP', .T., .F.)	  
	                                                                  

	DBSELECTAREA("TBR")
	RECLOCK("TBR",.T.)                     
	FIELD->BR_FILIAL	:= cFILIAL
	FIELD->BR_LISTA		:= cLISTA
	FIELD->BR_FILENT	:= cFILENT
	FIELD->BR_ENTIDA	:= cENTIDA
	FIELD->BR_CODENT	:= cCLIENTE+cLOJA
	FIELD->BR_ORIGEM	:= cORIGEM
	FIELD->BR_CONTATO	:= cCONTATO
	FIELD->BR_DATA		:= dDATA
	FIELD->BR_HRINI		:= cHRINI
	FIELD->BR_HRFIM		:= cHRFIM
	FIELD->BR_STATUS	:= cSTATUS
	FIELD->BR_TOTAL		:= TMP->SALDO
	MSUNLOCK()       
	
	DBSELECTAREA("TMP")
	DBCLOSEAREA()
		
END	

    
nCOD := VAL(cCODFIM)

DBSELECTAREA("TBR")
DBSETORDER(2)
DBGOTOP()
WHILE !EOF()        
	RECLOCK("TBR",.F.)
	FIELD->BR_CODIGO	:= STRZERO((nCOD),6)
	MSUNLOCK()                          
	nCOD := nCOD - 1
	DBSKIP()
END


DBSELECTAREA("TBR")
DBSETORDER(1)
DBGOTOP()
WHILE !EOF()
					
	AAdd(aRET,{	TBR->BR_FILIAL,;				// Filial
				TBR->BR_LISTA,;       			// Lista
				TBR->BR_CODIGO,; 				// Codigo
				TBR->BR_FILENT,;				// Chave da Entidade
				TBR->BR_ENTIDA,;				// Filial da Entidade
				TBR->BR_CODENT,;				// Codigo da Entidade
				TBR->BR_ORIGEM,;				// Origem da Interacao
				TBR->BR_CONTATO,;				// Codigo do Contato
				TBR->BR_DATA,;					// Data
				TBR->BR_HRINI,; 				// Hora Inicial
				TBR->BR_HRFIM,; 				// Hora Final
				TBR->BR_STATUS})	
	DBSKIP()
END


RETURN(aRET)