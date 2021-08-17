/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ RFATSEM  ºAutor  ³Eletromega          º Data ³  07/01/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Disparado no Schedule de Acordo com o Tipo de Relatório	  º±±
±±º          ³ Estoque 				                                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³P10 														  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
#include 'rwmake.ch'
#include 'TbiConn.ch'

User Function RFATSEM(_Tipo,aDados,aCabec1,_nTotalGer)
//
Local oHTML
Local _Control 	:= ""
Local xDescrg	:= ""
Local cFam		:= ""
Local cFam 		:= ""
Local cMes 		:= ""
Local nMes 		:= 0
Local aDados1   := {}
Local aDados2   := {}
Local d  		:= 0 
Private cArqTrb3  := CriaTrab(NIL,.F.)

oProcess:= TWFProcess():New("Schedule","Fat.Semestral")

oProcess:NewTask("Inicio","\WORKFLOW\SCHFATSEMFAM.htm")

If _Tipo = 1
	oProcess:cSubject := "Faturamento por Categoria X Valor Líquido"
ElseIf _Tipo = 2
	oProcess:cSubject := "Faturamento por Categoria X Quantidade "
ElseIf _Tipo = 3
	/*	oProcess:cSubject := "Impressao Faturamento por Categoria X Média Vlr. Unitario "
ElseIf _Tipo = 4*/
	oProcess:cSubject := "Faturamento por Categoria X Valor Bruto"
EndIf

oHtml := oProcess:oHTML

If _Tipo = 1
	oProcess:oHTML:ValByName('TextPad',"Faturamento por Categoria X Valor Líquido" )
ElseIf _Tipo = 2
	oProcess:oHTML:ValByName('TextPad',"Faturamento por Categoria X Quantidade " )
ElseIf _Tipo = 3
	/*	oProcess:oHTML:ValByName('TextPad',"Impressao Faturamento por Categoria X Média Vlr. Unitario ")
ElseIf _Tipo = 4*/
	oProcess:oHTML:ValByName('TextPad',"Faturamento por Categoria X Valor Bruto")
EndIf
//
oHTML:ValByName('DATA', DDATABASE )
//
For x:=1 to Len(aCabec1)
	//
	If x = 1
		aAdd( ( oHTML:valByName( 'TRB.Familia'  ) ), "Família")
		aAdd( ( oHTML:valByName( 'TRB.Q1'  ) ), aCabec1[x][1])
	ElseIf x = 2
		aAdd( ( oHTML:valByName( 'TRB.Q2'  ) ), aCabec1[x][1])
	ElseIf x = 3
		aAdd( ( oHTML:valByName( 'TRB.Q3'  ) ), aCabec1[x][1])
	ElseIf x = 4
		aAdd( ( oHTML:valByName( 'TRB.Q4'  ) ), aCabec1[x][1])
	ElseIf x = 5
		aAdd( ( oHTML:valByName( 'TRB.Q5'  ) ), aCabec1[x][1])
	ElseIf x = 6
		aAdd( ( oHTML:valByName( 'TRB.Q6'  ) ), aCabec1[x][1])
		aAdd( ( oHTML:valByName( 'TRB.Total'  ) ), "Tot.Fam")
	EndIf
	//
Next x
//

//          
IF SELECT("TMP") > 0
	DBSELECTAREA("TMP")
	DBCLOSEAREA()
ENDIF
                                         
aStru := {}	        
aAdd(aStru,{"GRUPO"		,"C",04,0}) 
aAdd(aStru,{"DESC"		,"C",20,0}) 
aAdd(aStru,{"M01" 		,"N",20,2}) 
aAdd(aStru,{"M02"	 	,"N",20,2}) 
aAdd(aStru,{"M03"	 	,"N",20,2}) 
aAdd(aStru,{"M04"	  	,"N",20,2}) 
aAdd(aStru,{"M05" 		,"N",20,2}) 
aAdd(aStru,{"M06" 		,"N",20,2}) 
aAdd(aStru,{"TOTAL" 	,"N",20,2}) 

dbcreate(cArqTrb3,aStru)
dbUseArea(.T.,,cArqTrb3,"TMP",.F.,.F.)

index on TMP->GRUPO to &(cArqTrb3+"1")
set index to &(cArqTrb3+"1")


For x:= 1 To Len(aDados)
     
	
	IF aDADOS[X][1] <> "TotFam"
		DBSELECTAREA("SBM")
		DBSETORDER(1)
		DBGOTOP()
		IF DBSEEK(XFILIAL("SMB")+aDADOS[X][1])
			xDescrg:=Alltrim(SBM->BM_DESC)
		Else
			xDescrg:=""
		Endif

		DBSELECTAREA("TMP")
		DBSETORDER(1)
		DBGOTOP()
		IF !DBSEEK(aDADOS[X][1])
			RECLOCK("TMP",.T.)
			FIELD->GRUPO	:= aDADOS[X][1]
			FIELD->DESC		:= xDescrg         
			IF aDADOS[X][2] == aCABEC1[1][1]
				FIELD->M01	:= aDADOS[X][3]
			ELSEIF aDADOS[X][2] == aCABEC1[2][1]
				FIELD->M02	:= aDADOS[X][3]
			ELSEIF aDADOS[X][2] == aCABEC1[3][1]
				FIELD->M03	:= aDADOS[X][3]
			ELSEIF aDADOS[X][2] == aCABEC1[4][1]
				FIELD->M04	:= aDADOS[X][3]
			ELSEIF aDADOS[X][2] == aCABEC1[5][1]
				FIELD->M05	:= aDADOS[X][3]
			ELSEIF aDADOS[X][2] == aCABEC1[6][1]
				FIELD->M06	:= aDADOS[X][3]
			ELSEIF aDADOS[X][2] == "TOTAL"
				FIELD->TOTAL	:= aDADOS[X][3]
			ENDIF			
			MSUNLOCK()			
		ELSE

			RECLOCK("TMP",.F.)
			IF aDADOS[X][2] == aCABEC1[1][1]
				FIELD->M01	:= TMP->M01 + aDADOS[X][3]
			ELSEIF aDADOS[X][2] == aCABEC1[2][1]
				FIELD->M02	:= TMP->M02 + aDADOS[X][3]
			ELSEIF aDADOS[X][2] == aCABEC1[3][1]
				FIELD->M03	:= TMP->M03 + aDADOS[X][3]
			ELSEIF aDADOS[X][2] == aCABEC1[4][1]
				FIELD->M04	:= TMP->M04 + aDADOS[X][3]
			ELSEIF aDADOS[X][2] == aCABEC1[5][1]
				FIELD->M05	:= TMP->M05 + aDADOS[X][3]
			ELSEIF aDADOS[X][2] == aCABEC1[6][1]
				FIELD->M06	:= TMP->M06 + aDADOS[X][3]
			ELSEIF aDADOS[X][2] == "Total"
				FIELD->TOTAL	:= TMP->TOTAL + aDADOS[X][3]
			ENDIF			
			MSUNLOCK()			
		
		ENDIF		
		
	ELSEIF aDADOS[X][1] == "TotFam"

		DBSELECTAREA("TMP")
		DBSETORDER(1)
		DBGOTOP()
		IF !DBSEEK(aDADOS[X][1])

			RECLOCK("TMP",.T.)
			FIELD->GRUPO	:= aDADOS[X][1]
			FIELD->DESC		:= "TOTAIS"
			IF aDADOS[X][2] == aCABEC1[1][1]
				FIELD->M01	:= aDADOS[X][3]
			ELSEIF aDADOS[X][2] == aCABEC1[2][1]
				FIELD->M02	:= aDADOS[X][3]
			ELSEIF aDADOS[X][2] == aCABEC1[3][1]
				FIELD->M03	:= aDADOS[X][3]
			ELSEIF aDADOS[X][2] == aCABEC1[4][1]
				FIELD->M04	:= aDADOS[X][3]
			ELSEIF aDADOS[X][2] == aCABEC1[5][1]
				FIELD->M05	:= aDADOS[X][3]
			ELSEIF aDADOS[X][2] == aCABEC1[6][1]
				FIELD->M06	:= aDADOS[X][3]
			ELSEIF aDADOS[X][2] == "TOTAL"
				FIELD->TOTAL	:= aDADOS[X][3]
			ENDIF			
			MSUNLOCK()			
		ELSE
			RECLOCK("TMP",.F.)
			IF aDADOS[X][2] == aCABEC1[1][1]
				FIELD->M01	:= TMP->M01 + aDADOS[X][3]
			ELSEIF aDADOS[X][2] == aCABEC1[2][1]
				FIELD->M02	:= TMP->M02 + aDADOS[X][3]
			ELSEIF aDADOS[X][2] == aCABEC1[3][1]
				FIELD->M03	:= TMP->M03 + aDADOS[X][3]
			ELSEIF aDADOS[X][2] == aCABEC1[4][1]
				FIELD->M04	:= TMP->M04 + aDADOS[X][3]
			ELSEIF aDADOS[X][2] == aCABEC1[5][1]
				FIELD->M05	:= TMP->M05 + aDADOS[X][3]
			ELSEIF aDADOS[X][2] == aCABEC1[6][1]
				FIELD->M06	:= TMP->M06 + aDADOS[X][3]
			ELSEIF aDADOS[X][2] == "TOTAL"
				FIELD->TOTAL	:= TMP->TOTAL + aDADOS[X][3]
			ENDIF			
			MSUNLOCK()			
		ENDIF	
	

	ENDIF
	    /* war
	if x > 100
		exit
	endif
	      */
END	
                                                                                                                    
nTOTAL := nM01 := nM02 := nM03 := nM04 := nM05 := nM06 := 0
    
DBSELECTAREA("TMP")
DBGOTOP()
WHILE !EOF()

	aAdd( ( oHTML:valByName( 'TRB.Familia' ) ), TMP->DESC)
	aAdd( ( oHTML:valByName( 'TRB.Q1' ) ), IIF(_Tipo=2,Transform(TMP->M01,"@E 9,999,999,999"),Transform(TMP->M01,"@E 99,999,999,999.99")))
	aAdd( ( oHTML:valByName( 'TRB.Q2' ) ), IIF(_Tipo=2,Transform(TMP->M02,"@E 9,999,999,999"),Transform(TMP->M02,"@E 99,999,999,999.99")))
	aAdd( ( oHTML:valByName( 'TRB.Q3' ) ), IIF(_Tipo=2,Transform(TMP->M03,"@E 9,999,999,999"),Transform(TMP->M03,"@E 99,999,999,999.99")))
	aAdd( ( oHTML:valByName( 'TRB.Q4' ) ), IIF(_Tipo=2,Transform(TMP->M04,"@E 9,999,999,999"),Transform(TMP->M04,"@E 99,999,999,999.99")))
	aAdd( ( oHTML:valByName( 'TRB.Q5' ) ), IIF(_Tipo=2,Transform(TMP->M05,"@E 9,999,999,999"),Transform(TMP->M05,"@E 99,999,999,999.99")))
	aAdd( ( oHTML:valByName( 'TRB.Q6' ) ), IIF(_Tipo=2,Transform(TMP->M06,"@E 9,999,999,999"),Transform(TMP->M06,"@E 99,999,999,999.99")))
	aAdd( ( oHTML:valByName( 'TRB.Total' ) ), IIF(_Tipo=2,Transform(TMP->TOTAL,"@E 99,999,999,999"),Transform(TMP->TOTAL,"@E 99,999,999,999.99")))
	
	nM01 += TMP->M01
	nM02 += TMP->M02
	nM03 += TMP->M03
	nM04 += TMP->M04
	nM05 += TMP->M05
	nM06 += TMP->M06
	nTOTAL += TMP->TOTAL
	
	DBSKIP()
END
aAdd( ( oHTML:valByName( 'TRB.Familia' ) ), "TOTAL GERAL")
aAdd( ( oHTML:valByName( 'TRB.Q1' ) ), IIF(_Tipo=2,Transform(nM01,"@E 9,999,999,999"),Transform(nM01,"@E 99,999,999,999.99")))
aAdd( ( oHTML:valByName( 'TRB.Q2' ) ), IIF(_Tipo=2,Transform(nM02,"@E 9,999,999,999"),Transform(nM02,"@E 99,999,999,999.99")))
aAdd( ( oHTML:valByName( 'TRB.Q3' ) ), IIF(_Tipo=2,Transform(nM03,"@E 9,999,999,999"),Transform(nM03,"@E 99,999,999,999.99")))
aAdd( ( oHTML:valByName( 'TRB.Q4' ) ), IIF(_Tipo=2,Transform(nM04,"@E 9,999,999,999"),Transform(nM04,"@E 99,999,999,999.99")))
aAdd( ( oHTML:valByName( 'TRB.Q5' ) ), IIF(_Tipo=2,Transform(nM05,"@E 9,999,999,999"),Transform(nM05,"@E 99,999,999,999.99")))
aAdd( ( oHTML:valByName( 'TRB.Q6' ) ), IIF(_Tipo=2,Transform(nM06,"@E 9,999,999,999"),Transform(nM06,"@E 99,999,999,999.99")))
aAdd( ( oHTML:valByName( 'TRB.Total' ) ), IIF(_Tipo=2,Transform(nTOTAL,"@E 99,999,999,999"),Transform(nTOTAL,"@E 99,999,999,999.99")))
	                    
	
	
//
oProcess:cBCc := U_GrpEmail('RFATSCH') //Retemails('RFATSCH') 

//
oProcess:Start()
oProcess:Finish()
//
Return