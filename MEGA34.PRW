#include "rwmake.ch" 
#include "PROTHEUS.ch" 
#include "MSGRAPHI.ch"

User Function MEGA34()                     
LOCAL nOpca	:=0
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
LOCAL aSays:={}, aButtons:={}
Private cCadastro := OemToAnsi("Relatorio de Inadimplencia") 
Public cPerg      := "MEGA34"                  
Public cEXPFILTRO := ""


/*
MV_PAR01 - FORMA DE ANALISE: 1 - MENSAL - 2- ACUMULADO
MV_PAR02 - DA DATA
MV_PAR03 - ATE DATA
MV_PAR04 - DA CONTA CLIENTE 
MV_PAR05 - ATE CONTA CLIENTE
MV_PAR06 - DO CLIENTE
MV_PAR07 - ATE CLIENTE          
MV_PAR08 - DA LOJA
MV_PAR09 - ATE LOJA
MV_PAR10 - FONTE DE ANALISE: 1 - FATURAMENTO - 2 - DUPLICATAS 	   
MV_PAR11 - DIAS DE ATRASO                             

*/

Pergunte("MEGA34",.F.)
AADD (aSays, OemToAnsi(" Este programa tem como objetivo emitir o relatorio "))
AADD (aSays, OemToAnsi(" de inadimplencia de cobranca a partir dos parametros"))
AADD (aSays, OemToAnsi(" selecionados pelo Usuario - Ourolux"))
AADD(aButtons, { 1,.T.,{|o| nOpca:= 1,o:oWnd:End()}} )
AADD(aButtons, { 2,.T.,{|o| o:oWnd:End() }} ) 
AADD(aButtons, { 17,.T.,{|| SE1->(cEXPFILTRO := BUILDEXPR("SE1")) }} )
AADD(aButtons, { 5,.T.,{|| Pergunte("MEGA34",.T. ) } } )
FormBatch( cCadastro, aSays, aButtons )
If nOpcA == 1
	#IFDEF TOP
		If TcSrvType() == 'AS/400'	
			Processa({|lEnd| GERAR()},"Processando...")  // Chamada da funcao de reconcilia‡Æo
		Else
			Processa({|lEnd| GERAR()},"Este Processamento levara alguns minutos...")  // Chamada da funcao de reconcilia‡Æo
		Endif
	#ELSE
		Processa({|lEnd| GERAR()},"Este Processamento levara alguns minutos...")  // Chamada da funcao de reconcilia‡Æo
	#ENDIF
Endif

Return

//##########################################################################################

Static Function Gerar()                        

If mv_par28 == 1 .AND. !EMPTY(mv_par40)   // Considera Data Base
	dBaixa := dDataBase := mv_par36
Endif
                     

IF SELECT("TMP") > 0
	DBSELECTAREA("TMP")
	DBCLOSEAREA()
ENDIF
                                                     

IF MV_PAR10 == 1 

  cQuery	:= " SELECT * "
  cQuery	+= " FROM " + RetSqlName("SE1") + " SE1, " + RetSqlName("SA1") + " SA1 "
  cQuery	+= " WHERE SE1.E1_FILIAL = '" + xFilial("SE1") + "'"           
  cQuery	+= " AND   SA1.A1_FILIAL = '" + xFilial("SA1") + "'"            
  cQuery	+= " AND   SE1.E1_EMISSAO BETWEEN '"+DTOS(MV_PAR02)+"' AND '"+DTOS(MV_PAR03)+"'"

  cQuery	+= " AND   SE1.E1_PREFIXO >= '"+MV_PAR12+"'"          
  cQuery	+= " AND   SE1.E1_PREFIXO <= '"+MV_PAR13+"'"            
  cQuery	+= " AND   SE1.E1_NUM >= '"+MV_PAR14+"'"          
  cQuery	+= " AND   SE1.E1_NUM <= '"+MV_PAR15+"'"            
  cQuery	+= " AND   SE1.E1_PORTADO >= '"+MV_PAR16+"'"          
  cQuery	+= " AND   SE1.E1_PORTADO <= '"+MV_PAR17+"'"                                    
  cQuery	+= " AND   SE1.E1_VENCREA BETWEEN '"+DTOS(MV_PAR18)+"' AND '"+DTOS(MV_PAR19)+"'"
  cQuery	+= " AND   SE1.E1_NATUREZ >= '"+MV_PAR20+"'"          
  cQuery	+= " AND   SE1.E1_NATUREZ <= '"+MV_PAR21+"'"            
  IF MV_PAR29 == 1
	  cQuery	+= " AND   SE1.E1_FILIAL >= '"+MV_PAR30+"'"          
	  cQuery	+= " AND   SE1.E1_FILIAL <= '"+MV_PAR31+"'"            
  ENDIF                                
  cQuery += " AND ((E1_EMIS1  Between '"+ DTOS(mv_par33)+"' AND '"+DTOS(mv_par34)+"') OR E1_EMISSAO Between '"+DTOS(mv_par33)+"' AND '"+DTOS(mv_par34)+"')"
  If !Empty(mv_par36) // Deseja imprimir apenas os tipos do parametro 31
	cQuery += " AND E1_TIPO IN "+FormatIn(mv_par31,";")
  ElseIf !Empty(Mv_par37) // Deseja excluir os tipos do parametro 32
	cQuery += " AND E1_TIPO NOT IN "+FormatIn(mv_par32,";")
  EndIf                                                
  If mv_par27 == 2
	cQuery += " AND E1_SITUACA NOT IN ('2','7')"
  Endif                                              
  If mv_par39 == 1
	cQuery += " AND E1_FLUXO <> 'N'"
  Endif   
  If MV_PAR42 == 2 //Nao considerar titulos com emissao futura
	cQuery += " AND E1_EMISSAO <=      '" + DTOS(dDataBase) + "'"
  Endif
  

  cQuery	+= " AND   SE1.E1_ORIGEM = 'MATA460 '" 
  cQuery	+= " AND   SE1.E1_TIPO <> 'NCC'"  
  cQuery	+= " AND   SE1.E1_TIPO <> 'RA '"          
  cQuery	+= " AND   SE1.E1_TIPO <> '-AB'"            
  cQuery	+= " AND   SE1.E1_CLIENTE = SA1.A1_COD "
  cQuery	+= " AND   SE1.E1_LOJA = SA1.A1_LOJA "
  cQuery	+= " AND   SA1.A1_CONTA BETWEEN '"+MV_PAR04+"' AND '"+MV_PAR05+"'"
  cQuery	+= " AND   SE1.D_E_L_E_T_ <> '*' "
  cQuery	+= " AND   SA1.D_E_L_E_T_ <> '*' "
  DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery) , 'TMP', .T., .F.)

ELSE

  cQuery	:= " SELECT * "
  cQuery	+= " FROM " + RetSqlName("SE1") + " SE1, " + RetSqlName("SA1") + " SA1 "
  cQuery	+= " WHERE SE1.E1_FILIAL = '" + xFilial("SE1") + "'"           
  cQuery	+= " AND   SA1.A1_FILIAL = '" + xFilial("SA1") + "'"            
  cQuery	+= " AND   SE1.E1_VENCREA BETWEEN '"+DTOS(MV_PAR02)+"' AND '"+DTOS(MV_PAR03)+"'"
  cQuery	+= " AND   SE1.E1_CLIENTE = SA1.A1_COD "                     
  cQuery	+= " AND   SE1.E1_LOJA = SA1.A1_LOJA "                                          

  cQuery	+= " AND   SE1.E1_PREFIXO >= '"+MV_PAR12+"'"          
  cQuery	+= " AND   SE1.E1_PREFIXO <= '"+MV_PAR13+"'"            
  cQuery	+= " AND   SE1.E1_NUM >= '"+MV_PAR14+"'"          
  cQuery	+= " AND   SE1.E1_NUM <= '"+MV_PAR15+"'"            
  cQuery	+= " AND   SE1.E1_PORTADO >= '"+MV_PAR16+"'"          
  cQuery	+= " AND   SE1.E1_PORTADO <= '"+MV_PAR17+"'"                                    
  cQuery	+= " AND   SE1.E1_EMISSAO BETWEEN '"+DTOS(MV_PAR22)+"' AND '"+DTOS(MV_PAR23)+"'"  
  cQuery	+= " AND   SE1.E1_NATUREZ >= '"+MV_PAR20+"'"          
  cQuery	+= " AND   SE1.E1_NATUREZ <= '"+MV_PAR21+"'"            
  IF MV_PAR29 == 1
	  cQuery	+= " AND   SE1.E1_FILIAL >= '"+MV_PAR30+"'"          
	  cQuery	+= " AND   SE1.E1_FILIAL <= '"+MV_PAR31+"'"            
  ENDIF                                
  cQuery += " AND ((E1_EMIS1  Between '"+ DTOS(mv_par33)+"' AND '"+DTOS(mv_par34)+"') OR E1_EMISSAO Between '"+DTOS(mv_par33)+"' AND '"+DTOS(mv_par34)+"')"
  If !Empty(mv_par36) // Deseja imprimir apenas os tipos do parametro 31
	cQuery += " AND E1_TIPO IN "+FormatIn(mv_par31,";")
  ElseIf !Empty(Mv_par37) // Deseja excluir os tipos do parametro 32
	cQuery += " AND E1_TIPO NOT IN "+FormatIn(mv_par32,";")
  EndIf                                                
  If mv_par27 == 2
	cQuery += " AND E1_SITUACA NOT IN ('2','7')"
  Endif                                              
  If mv_par39 == 1
	cQuery += " AND E1_FLUXO <> 'N'"
  Endif   
  If MV_PAR42 == 2 //Nao considerar titulos com emissao futura
	cQuery += " AND E1_EMISSAO <=      '" + DTOS(dDataBase) + "'"
  Endif

  cQuery	+= " AND   SE1.E1_TIPO <> 'NCC'"  
  cQuery	+= " AND   SE1.E1_TIPO <> 'RA '"          
  cQuery	+= " AND   SE1.E1_TIPO <> '-AB'"            
  cQuery	+= " AND   SA1.A1_CONTA BETWEEN '"+MV_PAR04+"' AND '"+MV_PAR05+"'"
  cQuery	+= " AND   SE1.D_E_L_E_T_ <> '*' "
  cQuery	+= " AND   SA1.D_E_L_E_T_ <> '*' "
  DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery) , 'TMP', .T., .F.)

ENDIF

IF SELECT("TBR") > 0
	DBSELECTAREA("TBR")
	DBCLOSEAREA()
ENDIF
                       
aCampos := {}
AADD(aCampos,{ "BR_CLIENTE","C",06,0 } )
AADD(aCampos,{ "BR_LOJA"   ,"C",02,0 } )  
AADD(aCampos,{ "BR_NOME"   ,"C",40,0 } )   
AADD(aCampos,{ "BR_MES"    ,"C",06,0 } )          
AADD(aCampos,{ "BR_DMES"   ,"C",20,0 } )         
AADD(aCampos,{ "BR_TITULO" ,"N",06,0 } ) 
AADD(aCampos,{ "BR_TOTAL"  ,"N",17,2 } ) 
AADD(aCampos,{ "BR_VENCER" ,"N",17,2 } ) 
AADD(aCampos,{ "BR_VENCIDO","N",17,2 } )  
AADD(aCampos,{ "BR_PAGO"   ,"N",17,2 } )  
AADD(aCampos,{ "BR_PTOTAL" ,"N",10,6 } )  
AADD(aCampos,{ "BR_PVENR"  ,"N",10,6 } )  
AADD(aCampos,{ "BR_PVENC"  ,"N",10,6 } ) 
AADD(aCampos,{ "BR_PPAGO"  ,"N",10,6 } ) 
                                                                    
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria arquivo de trabalho                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cNomArq 	:=  CriaTrab(aCampos)  
dbUseArea( .T.,, cNomArq,"TBR", .F. , .F. )

cNomArq1 := Subs(cNomArq,1,7)+"A"
IndRegua("TBR",cNomArq1,"BR_MES+BR_CLIENTE+BR_LOJA",,,)		//"Selecionando Registros..."
dbClearIndex()          
              

dbSetIndex(cNomArq1+OrdBagExt())

dbselectarea("TBR")
DBSETORDER(1)


IF SELECT("TCR") > 0
	DBSELECTAREA("TCR")
	DBCLOSEAREA()
ENDIF
                       
bCampos := {}
AADD(bCampos,{ "CR_MES"    ,"C",06,0 } )         
AADD(bCampos,{ "CR_DMES"   ,"C",20,0 } )         
AADD(bCampos,{ "CR_TITULO" ,"N",06,0 } ) 
AADD(bCampos,{ "CR_TOTAL"  ,"N",17,2 } ) 
AADD(bCampos,{ "CR_VENCER" ,"N",17,2 } ) 
AADD(bCampos,{ "CR_VENCIDO","N",17,2 } )  
AADD(bCampos,{ "CR_PAGO"   ,"N",17,2 } )  
AADD(bCampos,{ "CR_PVENR"  ,"N",10,6 } )  
AADD(bCampos,{ "CR_PVENC"  ,"N",10,6 } ) 
AADD(bCampos,{ "CR_PPAGO"  ,"N",10,6 } ) 
                                                                    
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria arquivo de trabalho                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cNomArq1 	:=  CriaTrab(bCampos)  
dbUseArea( .T.,, cNomArq1,"TCR", .F. , .F. )

cNomArq11 := Subs(cNomArq1,1,7)+"A"
IndRegua("TCR",cNomArq11,"CR_MES",,,)		//"Selecionando Registros..."
dbClearIndex()          
              

dbSetIndex(cNomArq11+OrdBagExt())

dbselectarea("TCR")
DBSETORDER(1)


dbSelectArea("TMP")
dbGoTop()

ProcRegua(RecCount())

While !EOF()

	IncProc()                              
	
	IF !EMPTY(cEXPFILTRO)
	   IF !(&cEXPFILTRO)
	   		DBSKIP()
	   		LOOP
	   ENDIF
	ENDIF

	IF E1_TIPO $ MVPROVIS .and. mv_par25 == 2
		dbSkip()
		Loop
	Endif

	IF SE1->E1_TIPO $ MVRECANT+"/"+MV_CRNEG .and. mv_par32 == 2
		dbSkip()
		Loop
	Endif

	IF SE1->E1_TIPO $ MVABATIM .And. mv_par38 == 2
		dbSkip()
		Loop
	Endif	
	                 
	dDATA := STOD(TMP->E1_VENCREA)
                                                                      
	IF MV_PAR01 == 1             // 1 = MENSAL   2 = ACUMULADO    
		IF MV_PAR10 == 1 		 // 1 = FATURAMENTO  2 = DUPLICATAS
			cMES  := STRZERO(YEAR(STOD(TMP->E1_EMISSAO)),4)+STRZERO(MONTH(STOD(TMP->E1_EMISSAO)),2)
		ELSE
			cMES  := STRZERO(YEAR(STOD(TMP->E1_VENCREA)),4)+STRZERO(MONTH(STOD(TMP->E1_VENCREA)),2)	
		ENDIF    
		dMES := PESQMES(cMES)
	ELSE
		cMES := "999999"	
		dMES := PESQMES(cMES)
	ENDIF                                        
	
	cCODCLI := TMP->A1_COD
	cLOJA	:= TMP->A1_LOJA
	cNOME	:= TMP->A1_NOME
	                                                    	
	DBSELECTAREA("TBR")
	DBSETORDER(1)
	DBGOTOP()
	IF !DBSEEK(cMES+cCODCLI+cLOJA)
		RecLock("TBR",.T.)
		FIELD->BR_CLIENTE 	:= cCODCLI
		FIELD->BR_LOJA		:= cLOJA
		FIELD->BR_NOME		:= cNOME
		FIELD->BR_MES		:= cMES      
		FIELD->BR_DMES		:= dMES
		FIELD->BR_TOTAL		:= TMP->E1_VALOR
		FIELD->BR_TITULO	:= 1
		IF TMP->E1_SALDO > 0 .AND. (dDATA + MV_PAR11) >= dDATAbASE
			IF SE1->E1_TIPO $ MVABATIM
				FIELD->BR_VENCER	:= TMP->E1_SALDO*-1
			ELSE
				FIELD->BR_VENCER	:= TMP->E1_SALDO
			ENDIF
		ENDIF       
		IF TMP->E1_SALDO > 0 .AND. (dDATA + MV_PAR11) < dDATAbASE
			IF SE1->E1_TIPO $ MVABATIM		
				FIELD->BR_VENCIDO	:= TMP->E1_SALDO*-1   	
			ELSE
				FIELD->BR_VENCIDO	:= TMP->E1_SALDO   
			ENDIF
		ENDIF
		IF TMP->E1_SALDO <> TMP->E1_VALOR 
			FIELD->BR_PAGO		:= TMP->E1_VALOR- TMP->E1_SALDO
		ENDIF
		MsUnLock()
	ELSE
		RecLock("TBR",.F.)                 
		FIELD->BR_TITULO	:= TBR->BR_TITULO + 1
		FIELD->BR_TOTAL		:= TBR->BR_TOTAL + TMP->E1_VALOR
		IF TMP->E1_SALDO > 0 .AND. (dDATA + MV_PAR11) >= dDATAbASE
			IF SE1->E1_TIPO $ MVABATIM
				FIELD->BR_VENCER	:= TBR->BR_VENCER - TMP->E1_SALDO
			ELSE
				FIELD->BR_VENCER	:= TBR->BR_VENCER + TMP->E1_SALDO
			ENDIF
		ENDIF       
		IF TMP->E1_SALDO > 0 .AND. (dDATA + MV_PAR11) < dDATAbASE
			IF SE1->E1_TIPO $ MVABATIM
				FIELD->BR_VENCIDO	:= TBR->BR_VENCIDO - TMP->E1_SALDO   
			ELSE
				FIELD->BR_VENCIDO	:= TBR->BR_VENCIDO + TMP->E1_SALDO   
			ENDIF
		ENDIF
		IF TMP->E1_SALDO <> TMP->E1_VALOR 
			FIELD->BR_PAGO		:= TBR->BR_PAGO + TMP->E1_VALOR- TMP->E1_SALDO
		ENDIF
		MsUnLock()	
	ENDIF
    
	DBSELECTAREA("TCR")
	DBSETORDER(1)
	DBGOTOP()
	IF !DBSEEK(cMES)
		RecLock("TCR",.T.)
		FIELD->CR_MES		:= cMES
		FIELD->CR_DMES		:= dMES      
		FIELD->CR_TOTAL		:= TMP->E1_VALOR
		FIELD->CR_TITULO	:= 1
		IF TMP->E1_SALDO > 0 .AND. (dDATA + MV_PAR11) >= dDATAbASE
			IF SE1->E1_TIPO $ MVABATIM
				FIELD->CR_VENCER	:= TMP->E1_SALDO*-1
			ELSE
				FIELD->CR_VENCER	:= TMP->E1_SALDO
			ENDIF
		ENDIF       
		IF TMP->E1_SALDO > 0 .AND. (dDATA + MV_PAR11) < dDATAbASE
			IF SE1->E1_TIPO $ MVABATIM		
				FIELD->CR_VENCIDO	:= TMP->E1_SALDO *-1
			ELSE
				FIELD->CR_VENCIDO	:= TMP->E1_SALDO   
			ENDIF
		ENDIF
		IF TMP->E1_SALDO <> TMP->E1_VALOR 
			FIELD->CR_PAGO		:= TMP->E1_VALOR- TMP->E1_SALDO
		ENDIF
		MsUnLock()
	ELSE
		RecLock("TCR",.F.)                 
		FIELD->CR_TITULO	:= TCR->CR_TITULO + 1
		FIELD->CR_TOTAL		:= TCR->CR_TOTAL + TMP->E1_VALOR
		IF TMP->E1_SALDO > 0 .AND. (dDATA + MV_PAR11) >= dDATAbASE
			IF SE1->E1_TIPO $ MVABATIM				
				FIELD->CR_VENCER	:= TCR->CR_VENCER - TMP->E1_SALDO
			ELSE
				FIELD->CR_VENCER	:= TCR->CR_VENCER + TMP->E1_SALDO
			ENDIF
		ENDIF       
		IF TMP->E1_SALDO > 0 .AND. (dDATA + MV_PAR11) < dDATAbASE
			IF SE1->E1_TIPO $ MVABATIM				
				FIELD->CR_VENCIDO	:= TCR->CR_VENCIDO - TMP->E1_SALDO   
			ELSE
				FIELD->CR_VENCIDO	:= TCR->CR_VENCIDO + TMP->E1_SALDO   
			ENDIF
		ENDIF
		IF TMP->E1_SALDO <> TMP->E1_VALOR 
			FIELD->CR_PAGO		:= TCR->CR_PAGO + TMP->E1_VALOR- TMP->E1_SALDO
		ENDIF
		MsUnLock()	
	ENDIF
	dbSelectArea("TMP")
	dbSkip()

EndDo                                

DBSELECTAREA("TCR")
DBGOTOP()
WHILE !EOF()
	cMES 		:= TCR->CR_MES           
	nTOTAL		:= TCR->CR_TOTAL
	nVENCER 	:= TCR->CR_VENCER
	nVENCIDO	:= TCR->CR_VENCIDO
	nPAGO		:= TCR->CR_PAGO
	
	DBSELECTAREA("TBR")
	DBSETORDER(1)
	DBGOTOP()
	DBSEEK(cMES)
	WHILE !EOF() .AND. cMES == TBR->BR_MES
//		IF MV_PAR01 == 1
			nPTOTAL	:= (TBR->BR_TOTAL/nTOTAL)*100
			nPVENR	:= (TBR->BR_VENCER/TBR->BR_TOTAL)*100
			nPVENC	:= (TBR->BR_VENCIDO/TBR->BR_TOTAL)*100
			nPPAGO	:= (TBR->BR_PAGO/TBR->BR_TOTAL)*100
//		ELSE
//			nPTOTAL	:= (TBR->BR_TOTAL/nTOTAL)*100
//			nPVENR	:= (TBR->BR_VENCER/nVENCER)*100
//			nPVENC	:= (TBR->BR_VENCIDO/nVENCIDO)*100
//			nPPAGO	:= (TBR->BR_PAGO/nPAGO)*100
//		ENDIF
		RecLock("TBR",.F.)                 
		FIELD->BR_PTOTAL	:= nPTOTAL
		FIELD->BR_PVENR		:= nPVENR
		FIELD->BR_PVENC		:= nPVENC
		FIELD->BR_PPAGO		:= nPPAGO
		MSUNLOCK()
		DBSKIP()
	END
	nPVENR	:= (TCR->CR_VENCER/nTOTAL)*100
	nPVENC	:= (TCR->CR_VENCIDO/nTOTAL)*100
	nPPAGO	:= (TCR->CR_PAGO/nTOTAL)*100
	
	DBSELECTAREA("TCR")
	RECLOCK("TCR")
	FIELD->CR_PVENR		:= nPVENR
	FIELD->CR_PVENC		:= nPVENC
	FIELD->CR_PPAGO		:= nPPAGO
	MSUNLOCK()
	
	DBSKIP()				
END	   
    
/*

DbselectArea("TBR")
_cArqXLS := CriaTrab( Nil, .f. ) + ".XLS"
COPY TO &_cArqXLS

__CopyFile(_cArqXLS,"D:/TESTES/TESTE.XLS")
	                                   
Ferase(_cArqXLS)

DbCloseArea()



DbselectArea("TCR")
_cArqXLS := CriaTrab( Nil, .f. ) + ".XLS"
COPY TO &_cArqXLS

__CopyFile(_cArqXLS,"D:/TESTES/TESTE1.XLS")
	                                   
Ferase(_cArqXLS)

DbCloseArea()
*/

//ALERT("PROCESSAMENTO ENCERRADO")                                    

GRAF34()
              
RETURN     


STATIC FUNCTION GRAF34()
                  


PRIVATE oSAY
PRIVATE oDLG1
PRIVATE oFONT := tFONT():NEW("ARIAL",,-12,.T.,.T.)
PRIVATE nOPC1 := 0
PRIVATE oBUTTON
PRIVATE aFLUXO := {}
//                       1    2    3    5    6     7    8    9

DBSELECTAREA("TCR")
DBSETORDER(1)
DBGOTOP()
WHILE !EOF()
	IF MV_PAR01 == 2
		cdMES := STRZERO(MONTH(MV_PAR02),2)+"/"+STRZERO(YEAR(MV_PAR02),4)+" A "+STRZERO(MONTH(MV_PAR03),2)+"/"+STRZERO(YEAR(MV_PAR03),4)
	ELSE
		cDMES := TCR->CR_DMES
	ENDIF
	AADD(aFLUXO,{cDMES,TCR->CR_PVENR,TCR->CR_PVENC,TCR->CR_PPAGO}) 
	DBSKIP()
END


nMOEDA 	:= 1
cTIT	:= "POSICAO DE INADIMPLENCIA - "+IIF(MV_PAR01 == 1,"MENSAL","ACUMULADO")+" - "+IIF(MV_PAR10 == 1,"FATURAMENTO","DUPLICATAS")

Grafico(oDlg1,aFluxo,nMoeda,cTit)

/*
DEFINE MSDIALOG oDLG1 FROM 0,0 TO 500,300 PIXEL TITLE "GRAFICO DE INADIMPLECIA"




@ 228,095 BUTTON "GRAFICO" SIZE 32, 13 OF oDlg1 PIXEL ACTION Grafico(oDlg1,aFluxo,nMoeda,cTit)

ACTIVATE MSDIALOG oDLG1 CENTERED

*/

RETURN


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³Grafico   ºAutor  ³Claudio D. de Souza º Data ³  30/08/01   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Selecionar o tipo da serie de dados e o tipo de grafico    º±±
±±º          ³ Parametros:                                                º±±
±±º          ³ oDlg   -> Objeto dialog onde sera exibido a tela do graficoº±±
±±º          ³ cAlias -> Alias do arquivo temporario que sera processado  º±±
±±º          ³ nMoeda -> Codigo da moeda                                  º±±
±±º          ³ cTit   -> Titulo do eixo X                                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ ateFinc021                                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Grafico(oDlg,aFluxo,nMoeda,cTit)
Local oDlgSer
Local oSer
Local oVisual
Local cCbx := "Linha"
Local cVisual := "Projeção do Saldo"
Local nCbx := 4
Local aCbx := { "Linha", "Área", "Pontos", "Barras", "Piramid", "Cilindro",; 
					 "Barras Horizontal", "Piramid Horizontal", "Cilindro Horizontal",;
					 "Pizza", "Forma", "Linha rápida", "Flexas", "GANTT", "Bolha" }      //  1 - 4 - 10
Local aVisual := { "Visão 1", "Visão 2" } 
Local nVisual := 1                                                                                         


MontaGrafico(aFluxo,nCbx,nVisual,nMoeda,cTit)
/*

DEFINE MSDIALOG oDlgSer TITLE "Tipo do gráfico" FROM 0,0 TO 100,280 PIXEL OF oDlg //

@ 008, 005 SAY "Escolha o tipo de série:" PIXEL OF oDlgSer //
@ 008, 063 MSCOMBOBOX oSer VAR cCbx ITEMS aCbx SIZE 077, 120 OF oDlgSer PIXEL ON CHANGE nCbx := oSer:nAt
@ 022, 005 SAY "Tipo de Visualização   :" PIXEL OF oDlgSer //
@ 022, 063 MSCOMBOBOX oVisual VAR cVisual ITEMS aVisual SIZE 077, 120 OF oDlgSer PIXEL ON CHANGE nVisual := oVisual:nAt
@ 035, 045 BUTTON "&Ok"  SIZE 30,12 OF oDlgSer PIXEL ACTION (MontaGrafico(aFluxo,nCbx,nVisual,nMoeda,cTit),oDlgSer:End())
@ 035, 075 BUTTON "&Sair" SIZE 30,12 OF oDlgSer PIXEL ACTION oDlgSer:End() //

ACTIVATE MSDIALOG oDlgSer CENTER
*/
Return Nil




/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³MontaGraf ºAutor  ³Claudio D. de Souza º Data ³  30/08/01   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Processa os dados necessarios para montagem do grafico e   º±±
±±º          ³ exibe o grafico.                                           º±±
±±º          ³ cAlias  -> Alias do arquivo temporario que sera processado º±±
±±º          ³ nCbx    -> Codigo da serie de dados que sera utilizada peloº±±
±±º          ³            objeto grafico                                  º±±
±±º          ³ nVisual -> Tipo de visualizacao 1-Contas a pagar x Ctas Recº±±
±±º          ³                                 2-Projecao do saldo        º±±
±±º          ³ nMoeda  -> Codigo da moeda                                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ ateFinc021                                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function MontaGrafico(aFluxo,nCbx,nVisual,nMoeda,cTit)
Local oDlg
Local obmp
Local oBold
Local oGraphic
Local nSerie      := 0
Local nSerie2     := 0
Local aArea       := GetArea()
Local aTabela
Local nX := 0
Local aTIPOREL := { "Sintetico", "Analitico" } 
local Ntiporel := 1
Local oTIPOREL
Local cTIPOREL := "TIPO DO RELATORIO"



aTabela		:= {{	cTit   ,; 
		 			   "Entradas",; //
		 				"Variação"}}
For nX := 1 To Len(aFluxo)
	Aadd(aTabela,{	Pad(Transform(aFluxo[nX,1],""),17),;
						Transform(aFluxo[nX,2]	,"@r 99.99%")})
Next		 				


//DEFINE MSDIALOG oDlg FROM 0,0 TO 450,700 PIXEL TITLE "Representação gráfica"
DEFINE MSDIALOG oDlg FROM 0,0 TO 450,1200 PIXEL TITLE "Representação gráfica"
DEFINE FONT oBold NAME "Arial" SIZE 0, -13 BOLD

// Layout da janela
@ 000, 000 BITMAP oBmp RESNAME "ProjetoAP" oF oDlg SIZE 50, 250 NOBORDER WHEN .F. PIXEL
@ 003, 060 SAY "POSICAO DE INADIMPLECIA" FONT oBold PIXEL //######

@ 014, 050 TO 16 ,600 LABEL '' OF oDlg  PIXEL

@ 014, 050 TO 16 ,600 LABEL '' OF oDlg  PIXEL

@ 020, 055 MSGRAPHIC oGraphic SIZE 285, 158 OF oDlg PIXEL
oGraphic:SetMargins( 2, 6, 6, 6 )
oGraphic:bRClicked := {|o,x,y| oMenu:Activate(x,y,oGraphic) } // Posição x,y em relação a Dialog 
MENU oMenu POPUP
	MENUITEM "Consulta dados do grafico" Action ConsDadGraf(aTabela) //
ENDMENU

// Habilita a legenda, apenas se houver mais de uma serie de dados.
oGraphic:SetLegenProp( GRP_SCRTOP, CLR_YELLOW, GRP_SERIES, .F.)
nSerie  := oGraphic:CreateSerie(nCbx)
// Adiciona mais uma série de dados, conforme o tipo do grafico       
If nVisual == 1 // Contas a Pagar x Contas a Receber
   nSerie2 := oGraphic:CreateSerie(nCbx)                  
   nSerie3 := oGraphic:CreateSerie(nCbx)                          
   @ 175, 57 SAY "Titulos a Vencer" OF oDlg COLOR CLR_HBLUE FONT oBold PIXEL //
   @ 185, 57 SAY "Titulos Vencidos" OF oDlg COLOR CLR_HRED FONT oBold PIXEL //
   @ 195, 57 SAY "Titulos Pagos" OF oDlg COLOR CLR_HGREEN  FONT oBold PIXEL //
Endif   
   
If nSerie != GRP_CREATE_ERR .And. nSerie2 != GRP_CREATE_ERR 
//	aEval(aFluxo,{|e|I	f(nVisual==1,(oGraphic:Add(nSerie ,e[6],Transform(e[1],""),CLR_HBLUE),;
//										  	   oGraphic:Add(nSerie2,e[7]  ,Transform(e[1],""),CLR_HRED)),;
//										  		oGraphic:Add(nSerie ,e[2]    ,Transform(e[1],""),If(e[7]<0,CLR_HRED,CLR_HBLUE)))})

aEval(aFluxo,{|e| If(nVisual==1,;
					(oGraphic:Add(nSerie ,e[2],Transform(e[1],""),CLR_HBLUE),;
					 oGraphic:Add(nSerie2,e[3]  ,Transform(e[1],""),CLR_HRED),;
					 oGraphic:Add(nSerie3,e[4]  ,Transform(e[1],""),CLR_HGREEN)),; 				 
						oGraphic:Add(nSerie ,e[2],Transform(e[1],""),If(e[2]<0, CLR_HRED, CLR_HBLUE)))})





Else
	IW_MSGBOX("Não foi possível criar a série.","E","STOP") //
Endif

BROWTCR()
                             
oGraphic:SetGradient( GDBOTTOMTOP, CLR_HGRAY, CLR_WHITE )
oGraphic:SetTitle( "Percentual","", CLR_HRED , A_LEFTJUST , GRP_TITLE )
oGraphic:SetTitle( "", cTit, CLR_GREEN, A_RIGHTJUS , GRP_FOOT  ) //

@ 190, 212 BUTTON o3D PROMPT "&2D" SIZE 40,14 OF oDlg PIXEL ACTION (oGraphic:l3D := !oGraphic:l3D, o3d:cCaption := If(oGraphic:l3D, "&2D", "&3D"))
@ 190, 254 BUTTON "&Salva BMP"   SIZE 40,14 OF oDlg PIXEL ACTION GrafSavBmp( oGraphic ) //

@ 207, 050 TO 209 ,600 LABEL '' OF oDlg  PIXEL

@ 025, 350 TO 174 ,600 LABEL '' OF oDlg  PIXEL

//If !__lPyme
//	@ 190, 254 BUTTON "E-Mail" SIZE 40,14 OF oDlg PIXEL ACTION PmsGrafMail(oGraphic,"Representação gráfica da Inadimplecia",{"POSICAO DE INADIMPLECIA - "+IIF(MV_PAR01 == 1,"MENSAL","ACUMULADO")},aTabela,1) // 
//Endif
@ 190, 295 BUTTON "&Sair" SIZE 40,14 OF oDlg PIXEL ACTION oDlg:End() //                  
@ 190, 560 BUTTON "&Relatorio"   SIZE 40,14 OF oDlg PIXEL ACTION RELINA(1,nTIPOREL) // 
@ 190, 518 BUTTON "&Excel"   SIZE 40,14 OF oDlg PIXEL ACTION RELINA(2,nTIPOREL) //                                             


@ 190, 380 SAY "Tipo de Relatorio   :" PIXEL OF oDlg //
@ 190, 433 MSCOMBOBOX oTIPOREL VAR cTIPOREL ITEMS aTIPOREL SIZE 077, 120 OF oDlg PIXEL ON CHANGE nTIPOREL := oTIPOREL:nAt
                                                                      

ACTIVATE MSDIALOG oDlg CENTER
RestArea(aArea)



Return Nil
                                                                        

STATIC FUNCTION RELINA(nOPCREL,nTIPOREL)
#IFNDEF WINDOWS
// Movido para o inicio do arquivo pelo assistente de conversao do AP5 IDE em 19/02/07 ==> 	#DEFINE PSAY SAY
#ENDIF	                               


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de variaveis utilizadas no programa atraves da funcao    ³
//³ SetPrvt, que criara somente as variaveis definidas pelo usuario,    ³
//³ identificando as variaveis publicas do sistema utilizadas no codigo ³
//³ Incluido pelo assistente de conversao do AP6 IDE                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

SetPrvt("TITULO,CSTRING,WNREL,CBTXT,CDESC1,CDESC2")                
SetPrvt("TAMANHO,ARETURN,NLASTKEY,CPERG,CABEC1,CABEC2")
SetPrvt("CRODATXT,NCNTIMPR,NTIPO,NOMEPROG,CCONDICAO,NTOTREGS")
SetPrvt("NMULT,NPOSANT,NPOSATU,NPOSCNT,CPED,CITEM")
SetPrvt("VTOTFAT,VTOTTAB,VTOTLUC,PTOTPER,VPEDFAT,VPEDTAB")
SetPrvt("VPEDLUC,TPEDLUC,PPEDPER,LCONTINUA,LI,M_PAG")
SetPrvt("CNOMARQ,DNOMARQ,NTOTREQ,NTOTPROD,NTOTDEV,NTOTREQMOD,NTOTDEVMOD")
SetPrvt("XPED,XTOTCOMIS,XPEDCOMIS,XTAB,XPERC,XCOMIS")
SetPrvt("XVAL,XVEND,XNOMVEND,XTOTLUC,WTOTLUC,XCPAG")


aCampos := {} 
cString    := "SB2"
wnrel      := "MEGA34"
CbTxt      := ""
cDesc1     := ""
cDesc2     := ""
IF Ntiporel == 1
	Tamanho    := "M"
ELSE
	Tamanho    := "G"
ENDIF
aReturn    := { "Zebrado", 1,"Administra‡„o", 2, 2, 1, "",1 }
nLastKey   := 0
cabec1     := ""
cabec2     := ""
cRodaTxt   := ""
nCntImpr   := 0
nTipo      := 0
nomeprog   := "MEGA34"
cCondicao  := ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica as perguntas selecionadas                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros                         ³
//³ mv_par01     // Data do Relatorio                            ³        
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//pergunte(cPerg,.F.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Envia controle para a funcao SETPRINT                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ


IF nOPCREL == 1                                                 

	wnrel:="MEGA34"
	wnrel:=SetPrint(cString,wnrel,"",titulo,cDesc1,cDesc2,"",.F.,"")


	If nLastKey == 27
	   Return .T.
	Endif

	SetDefault(aReturn,cString)

	If nLastKey == 27
	   Return .T.
	Endif


	#IFDEF WINDOWS
		RptStatus({|| GERImp(Ntiporel)},Titulo)// Substituido pelo assistente de conversao do AP6 IDE em 19/02/07 ==> 	RptStatus({|| Execute(RSZ1Imp)},Titulo)
		Return   

ELSE

	IF Ntiporel == 2  // ANALITICO                                                                               

		aTOTEXC := {}
		
		IF MV_PAR01 == 1
			cTIPORE := "MENSAL"
		ELSE
			cTIPORE := "ACUMULADO"
		ENDIF
		
		AADD(aTOTEXC,{"CLIENTE",;
				"LOJA",;
				"RAZAO SOCIAL",;
				"FORMA DE ANALISE",;
				"PERÍODO",;				
				"NUM. TITULOS",;
				"VALOR TOTAL",;								
				"VALOR A VENCER",;
				"VALOR VENCIDO",;
				"VALOR PAGO",;
				"DISTRIBUIÇÃO",; 
				"PERC. A VENCER",;
				"PERC. VENCIDO",;
				"PERC. PAGO"})
		
		
		
		DBSELECTAREA("TBR")
		DBSETORDER(1)
		DBGOTOP()                           
		WHILE !EOF() 
	
			AADD(aTOTEXC,{TBR->BR_CLIENTE,;
							TBR->BR_LOJA,;
							TBR->BR_NOME,;
							cTIPORE,;
							TBR->BR_DMES,;
							TBR->BR_TITULO,;
							TBR->BR_TOTAL,;
							TBR->BR_VENCER,;
							TBR->BR_VENCIDO,;
							TBR->BR_PAGO,;
							TBR->BR_PTOTAL,;
							TBR->BR_PVENR,;
							TBR->BR_PVENC,;
							TBR->BR_PPAGO}) 
		
	        DBSKIP()
		END
	
		acabexcel := {}
                                                                                                               
		AADD(acabexcel,{"CLIENTE",;
				"LOJA",;
				"RAZAO SOCIAL",;
				"FORMA DE ANALISE",;
				"PERÍODO",;				
				"NUM. TITULOS",;
				"VALOR TOTAL",;								
				"VALOR A VENCER",;
				"VALOR VENCIDO",;
				"VALOR PAGO",;
				"DISTRIBUIÇÃO",; 
				"PERC. A VENCER",;
				"PERC. VENCIDO",;
				"PERC. PAGO"})

		If !apoleclient("MSExcel")
			MSGALERT("Não foi possivel enviar os dados, Microsoft Excel não instalado!")
		Else
			dlgtoexcel({{"ARRAY","POSICAO DE INADIMPLENCIA - "+IIF(MV_PAR01 == 1,"MENSAL","ACUMULADO")+" - "+IIF(MV_PAR10 == 1,"FATURAMENTO","DUPLICATAS"),acabexcel,aTOTEXC }})
		Endif
	ELSE
		aTOTEXC := {}

		AADD(aTOTEXC,{"PERÍODO",;				
				"NUM. TITULOS",;
				"VALOR TOTAL",;								
				"VALOR A VENCER",;
				"VALOR VENCIDO",;
				"VALOR PAGO",;
				"PERC. A VENCER",;
				"PERC. VENCIDO",;
				"PERC. PAGO"})


		DBSELECTAREA("TCR")
		DBSETORDER(1)
		DBGOTOP()                           
		WHILE !EOF() 
	
		AADD(aTOTEXC,{TCR->CR_DMES,;
							TCR->CR_TITULO,;
							TCR->CR_TOTAL,;
							TCR->CR_VENCER,;
							TCR->CR_VENCIDO,;
							TCR->CR_PAGO,;
							TCR->CR_PVENR,;
							TCR->CR_PVENC,;
							TCR->CR_PPAGO}) 
		
	        DBSKIP()
		END
	
		acabexcel := {}
                                                                                                               
		AADD(acabexcel,{"PERIODO",;				
				"NUM. TITULOS",;
				"VALOR TOTAL",;								
				"VALOR A VENCER",;
				"VALOR VENCIDO",;
				"VALOR PAGO",;
				"PERC. A VENCER",;
				"PERC. VENCIDO",;
				"PERC. PAGO"})

		If !apoleclient("MSExcel")
			MSGALERT("Não foi possivel enviar os dados, Microsoft Excel não instalado!")
		Else
			dlgtoexcel({{"ARRAY","POSICAO DE INADIMPLENCIA - "+IIF(MV_PAR01 == 1,"MENSAL","ACUMULADO")+" - "+IIF(MV_PAR10 == 1,"FATURAMENTO","DUPLICATAS"),acabexcel,aTOTEXC }})
		Endif
		DBSELECTAREA("TCR")
		DBGOTOP()
                        
	ENDIF

ENDIF		

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ GERIMP   ³ Autor ³ EDUARDO LOBATO        ³ Data ³ 22.03.07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Chamada do Relatorio                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GERCTB                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
// Substituido pelo assistente de conversao do AP6 IDE em 19/02/07 ==> Function RSZ1Imp

Static Function GERIMP(Ntiporel) 
#ENDIF

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis para controle do cursor de progressao do relatorio ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ       

nTotRegs := 0 
nMult    := 1
nPosAnt  := 4
nPosAtu  := 4
nPosCnt  := 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis locais exclusivas deste programa                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cPed    := " "
cItem   := 0
vTotFat := 0
vTotTab := 0
vTotLuc := 0
pTotPer := 0
vPedFat := 0
vPedTab := 0
vPedLuc := 0
tPedLuc := 0
pPedPer := 0
           
lContinua   := .T. 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis tipo Private padrao de todos os relatorios         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Contadores de linha e pagina                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Li    := 80
m_pag := 1

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis locais exclusivas deste programa                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cNomArq := ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se deve comprimir ou nao                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nTipo := IIF(aReturn[4]==1,15,18)


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta os Cabecalhos                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

//                                                           999,999,999,999.99 DD                  999,999,999,999.99            999,999,999,999.99           999,999,999,999.99 DD
//12345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
//         1         2         3         4         5         6         7         8         9         0         1         2         3         4         5         6         7         8         9         0         1         2        
                 
 

Titulo     := "POSICAO DE INADIMPLENCIA - "+IIF(MV_PAR01 == 1,"MENSAL","ACUMULADO")+" - "+IIF(MV_PAR10 == 1,"FATURAMENTO","DUPLICATAS")
XLIN := 80      

IF Ntiporel == 2  // ANALITICO

	cabec1 := "CLIENTE                                             N.TITULOS      VALOR TOTAL  DISTRIB  VALOR A VENCER % PERC.   VALOR VENCIDOS  % PERC.       VALOR PAGO  % PERC."
	cabec2 := "                                                                                                         VENCER                  VENCIDOS                    PAGO"
	
	tTOTAL := tVENCER := tVENCIDO := tPAGO := 0
                  
	DBSELECTAREA("TBR") 
	DBSETORDER(1)
	DBGOTOP()    
	SETREGUA(RECCOUNT())  
	WHILE !EOF() 
	    INCREGUA()
   		XLIN := 80
	    IF XLIN > 60
	        Cabec(titulo,cabec1,cabec2,nomeprog,tamanho,nTipo)      
	        XLIN := 10
	    ENDIF           
	    cMES := TBR->BR_MES                    
	    dMES := TBR->BR_DMES
	    @ XLIN,001 PSAY "Mes...: "+TBR->BR_DMES
	    ++XLIN
	    ++XLIN
	    stTOTAL := stVENCER := stVENCIDO := stPAGO := 0
	    WHILE !EOF() .AND. cMES == TBR->BR_MES        
		     IF XLIN > 60
		        Cabec(titulo,cabec1,cabec2,nomeprog,tamanho,nTipo)      
		        XLIN := 10
		     ENDIF           
		     @ XLIN,000 PSAY TBR->BR_CLIENTE+" "+TBR->BR_LOJA+" "+TBR->BR_NOME
		     @ XLIN,056 PSAY TBR->BR_TITULO
		     @ XLIN,065 PSAY TBR->BR_TOTAL 	  PICTURE "@E 999,999,999.99"
		     @ XLIN,081 PSAY ROUND(TBR->BR_PTOTAL,2) PICTURE "@E 999.99"
		     @ XLIN,090 PSAY TBR->BR_VENCER PICTURE "@E 999,999,999.99"
		     @ XLIN,106 PSAY ROUND(TBR->BR_PVENR,2) PICTURE "@E 999.99"
		     @ XLIN,115 PSAY TBR->BR_VENCIDO PICTURE "@E 999,999,999.99"
		     @ XLIN,132 PSAY ROUND(TBR->BR_PVENC,2) PICTURE "@E 999.99"
		     @ XLIN,141 PSAY TBR->BR_PAGO PICTURE "@E 999,999,999.99"
		     @ XLIN,157 PSAY ROUND(TBR->BR_PPAGO,2) PICTURE "@E 999.99"
		     ++XLIN
		     
			stTOTAL 	+= TBR->BR_TOTAL
			stVENCER 	+= TBR->BR_VENCER
			stVENCIDO 	+= TBR->BR_VENCIDO
			stPAGO 		+= TBR->BR_PAGO
			
			tTOTAL 		+= TBR->BR_TOTAL
			tVENCER 	+= TBR->BR_VENCER
			tVENCIDO 	+= TBR->BR_VENCIDO
			tPAGO 		+= TBR->BR_PAGO
		     
		     DBSKIP()
		END             
		++XLIN                                                                 
		@ XLIN,000 PSAY "SUBTOTAL DO MES "+dMES
        @ XLIN,065 PSAY stTOTAL 	  PICTURE "@E 999,999,999.99"
		@ XLIN,090 PSAY stVENCER PICTURE "@E 999,999,999.99"
		@ XLIN,115 PSAY stVENCIDO PICTURE "@E 999,999,999.99"
		@ XLIN,141 PSAY stPAGO PICTURE "@E 999,999,999.99"
		++XLIN                                                                 
	END       
	++XLIN                                                                 
	@ XLIN,000 PSAY "TOTAL GERAL "+dMES
    @ XLIN,065 PSAY tTOTAL 	  PICTURE "@E 999,999,999.99"
	@ XLIN,090 PSAY tVENCER PICTURE "@E 999,999,999.99"
	@ XLIN,115 PSAY tVENCIDO PICTURE "@E 999,999,999.99"
	@ XLIN,141 PSAY tPAGO PICTURE "@E 999,999,999.99"
ELSE

	cabec1 := "MES	       N.TITULOS         VALOR TOTAL     VALOR A VENCER % PERC.   VALOR VENCIDOS  % PERC.       VALOR PAGO  % PERC."
	cabec2 := "                                                                    VENCER                  VENCIDOS                    PAGO"

	DBSELECTAREA("TCR") 
	DBSETORDER(1)
	DBGOTOP()    
	SETREGUA(RECCOUNT())                       
	tTOTAL := tVENCER := tVENCIDO := tPAGO := 0
	WHILE !EOF() 
	    IF XLIN > 60
	       Cabec(titulo,cabec1,cabec2,nomeprog,tamanho,nTipo)      
	       XLIN := 10
	    ENDIF           
		@ XLIN,000 PSAY TCR->CR_DMES	     
	    @ XLIN,021 PSAY TCR->CR_TITULO
	    @ XLIN,030 PSAY TCR->CR_TOTAL 	  PICTURE "@E 999,999,999.99"
	    @ XLIN,055 PSAY TCR->CR_VENCER PICTURE "@E 999,999,999.99"
	    @ XLIN,071 PSAY ROUND(TCR->CR_PVENR,2) PICTURE "@E 999.99"
	    @ XLIN,080 PSAY TCR->CR_VENCIDO PICTURE "@E 999,999,999.99"
	    @ XLIN,097 PSAY ROUND(TCR->CR_PVENC,2) PICTURE "@E 999.99"
	    @ XLIN,106 PSAY TCR->CR_PAGO PICTURE "@E 999,999,999.99"
	    @ XLIN,122 PSAY ROUND(TCR->CR_PPAGO,2) PICTURE "@E 999.99"
	    ++XLIN
		tTOTAL 		+= TCR->CR_TOTAL
		tVENCER 	+= TCR->CR_VENCER
		tVENCIDO 	+= TCR->CR_VENCIDO
		tPAGO 		+= TCR->CR_PAGO
	    DBSKIP()
	END             
    ++XLIN
	@ XLIN,000 PSAY "TOTAL GERAL "+dMES
    @ XLIN,030 PSAY tTOTAL 	  PICTURE "@E 999,999,999.99"
	@ XLIN,055 PSAY tVENCER PICTURE "@E 999,999,999.99"
	@ XLIN,080 PSAY tVENCIDO PICTURE "@E 999,999,999.99"
	@ XLIN,106 PSAY tPAGO PICTURE "@E 999,999,999.99"
	XLIN := 80
	
	DBSELECTAREA("TCR")
	dbgotop()
	
ENDIF
Set device to Screen        

If aReturn[5] == 1
	Set Printer To 
	dbCommitAll()
	OurSpool(wnrel)
Endif

MS_FLUSH()
                        

RETURN  







/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Browse    ³ Autor ³ Ary Medeiros          ³ Data ³ 15.02.96 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Objeto para manipulacao de Browses                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

STATIC FUNCTION BROWTCR()
//@ 000,000 TO 400,700 DIALOG oDlg TITLE "SALDO POR ATRIBUTO " + STRIMUNE

// Para Utilizacao de um arquivo qualquer sem o SX3 em um browse padrao
dbSelectArea("TCR")
DbGoTop()
aCampoTr:= {}                                                      
AADD(aCampoTr,{"CR_DMES"	," MES " })
AADD(aCampoTr,{"CR_TITULO"  ," N. Titulos"    })
AADD(aCampoTr,{"CR_TOTAL"   ,"Valor Total","@E 999,999,999.99"    })
AADD(aCampoTr,{"CR_VENCER" ,"Tit. a Vencer","@E 999,999,999.99"    })
AADD(aCampoTr,{"CR_VENCIDO"  ,"Tit. Vencidos","@E 999,999,999.99"    })
AADD(aCampoTr,{"CR_PAGO" ,"Tit. Pagos","@E 999,999,999.99"    }) 
AADD(aCampoTr,{"CR_PVENR" ,"Perc. a Vencer","@E 999.99"    })
AADD(aCampoTr,{"CR_PVENC" ,"Perc. Vencidos","@E 999.99"    })
AADD(aCampoTr,{"CR_PPAGO" ,"Perc. Pagos","@E 999.99"    })

//@ 025, 350 TO 174 ,600 LABEL '' OF oDlg  PIXEL

//@ 005,020 SAY "ATRIBUTO: "  + MV_PAR01
//@ 005,070 SAY "GRAMATURA: "
//@ 005,110 SAY Trim(Str(MV_PAR02))
@ 030,355 TO 170,590 BROWSE "TCR" FIELDS aCampoTr

//@ 170,100 BUTTON "Itens" SIZE 40,15 ACTION nNewCon()// Substituido pelo assistente de conversao do AP6 IDE em 11/01/02 ==>         @ 170,100 BUTTON "Itens" SIZE 40,15 ACTION Execute(nNewCon)
//@ 170,180 BUTTON "Fecha" SIZE 40,15 ACTION Close(oDlg)
//ACTIVATE DIALOG oDlg CENTERED

Return


STATIC FUNCTION PESQMES(cMES)

IF cMES == "999999"
	dMES := STRZERO(MONTH(MV_PAR02),2)+"/"+STRZERO(YEAR(MV_PAR02),4)+" A "+STRZERO(MONTH(MV_PAR03),2)+"/"+STRZERO(YEAR(MV_PAR03),4)
	//dMES := "Acumulado"
ELSE
	IF SUBS(cMES,5,2) == "01"
		dMES := "Janeiro/"+SUBS(cMES,1,4)
	ELSEIF SUBS(cMES,5,2) == "02"
		dMES := "Fevereiro/"+SUBS(cMES,1,4)
	ELSEIF SUBS(cMES,5,2) == "03"
		dMES := "Marco/"+SUBS(cMES,1,4)
	ELSEIF SUBS(cMES,5,2) == "04"
		dMES := "Abril/"+SUBS(cMES,1,4)
	ELSEIF SUBS(cMES,5,2) == "05"
		dMES := "Maio/"+SUBS(cMES,1,4)
	ELSEIF SUBS(cMES,5,2) == "06"
		dMES := "Junho/"+SUBS(cMES,1,4)
	ELSEIF SUBS(cMES,5,2) == "07"
		dMES := "Julho/"+SUBS(cMES,1,4)
	ELSEIF SUBS(cMES,5,2) == "08"
		dMES := "Agosto/"+SUBS(cMES,1,4)
	ELSEIF SUBS(cMES,5,2) == "09"
		dMES := "Setembro/"+SUBS(cMES,1,4)
	ELSEIF SUBS(cMES,5,2) == "10"
		dMES := "Outubro/"+SUBS(cMES,1,4)
	ELSEIF SUBS(cMES,5,2) == "11"
		dMES := "Novembro/"+SUBS(cMES,1,4)
	ELSEIF SUBS(cMES,5,2) == "12"
		dMES := "Dezembro/"+SUBS(cMES,1,4)
	endif
ENDIF

return(dMES)                                       



