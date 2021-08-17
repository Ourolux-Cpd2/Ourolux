#include "rwmake.ch" 
#Include "PROTHEUS.CH"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณTESINTC    บ Autor ณ EDUARDO LOBATO     บ Data ณ  09/05/14  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ TES INTELIGENTE                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ OUROLUX                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/                                               

User Function TESINTC()
Local aArea := GetArea()                                    
Local aItens := {"03 Compras","04 Devolu็ใo"}

nPOSOP	:= ASCAN(aHEADER,{ |X| UPPER(ALLTRIM(X[2])) == "D1_OPER" })

IF alltrim(ACOLS[1][nPOSOP]) <> ""   
	CATATES(ACOLS[1][nPOSOP])
	
	RestArea(aArea)
	RETURN(ACOLS[1][nPOSOP])
ENDIF

PRIVATE oSAY
PRIVATE oFONT	:= TFONT():NEW("Courier New",,-12,.T.,.T.)
PRIVATE aFONT	:= TFONT():NEW("Arial",,-12,.T.,.T.)
PRIVATE bFONT	:= TFONT():NEW("Arial",,-11,.T.,.T.) 
PRIVATE cFONT	:= TFONT():NEW("Arial",,-11,.T.,)
PRIVATE eFONT	:= TFONT():NEW("Arial",,-16,.T.,.T.)
PRIVATE nOPC1	:= 0
PRIVATE oBUTTON 
PRIVATE oDLG                                   
PRIVATE oCOMBO, cCOMBO 
             
                 
WHILE .T.     

	//variแveis de cadastro                                 
	
	cCod	:= space(2)

                        
	//inicializa็ใo da tela de cadastros
	
	DEFINE MSDIALOG oDLG FROM 0,0 TO 200,300 PIXEL TITLE "Tes Inteligente"
	
	
	// item 1 - Vendas

	@ 020,010 SAY OEMTOANSI("Tipo de Opera็ใo: ") FONT bFONT COLOR CLR_BLACK,CLR_RED OF oDLG PIXEL 
//	@ 020,070 MSGET oGET VAR cCod  SIZE 57,08 OF oDLG PIXEL 
	oCOMBO := TCOMBOBOX():NEW(020,070,{|u|IF(PCOUNT()>0,cCOMBO:=U,cCOMBO)},aITENS,60,20,oDLG,,,,,,.T.,,,,,,,,,"cCOMBO")

	@ 060,100 BMPBUTTON TYPE 1 ACTION(nOPC1 := 1, CLOSE(oDLG))
//	@ 060,100 BMPBUTTON TYPE 2 ACTION(nOPC1 := 3, CLOSE(oDLG))

	ACTIVATE MSDIALOG oDLG CENTERED   
	
	IF EMPTY(ALLTRIM(cCOMBO))
		MSGBOX("Tipo de Opera็ใo deve ser informada")
		LOOP
	ENDIF
	
	EXIT
END       

cCOD := SUBS(cCOMBO,1,2)            

CATATES(cCOD)
RestArea(aArea)
Return(cCOD)             
                       

STATIC FUNCTION CATATES(cCOD)

nPOSTES	 := ASCAN(aHEADER,{ |X| UPPER(ALLTRIM(X[2])) == "D1_TES" })
nPOSCF	 := ASCAN(aHEADER,{ |X| UPPER(ALLTRIM(X[2])) == "D1_CF" })
nPOSPROD := ASCAN(aHEADER,{ |X| UPPER(ALLTRIM(X[2])) == "D1_COD" })
cTES	 := aCOLS[N][nPOSTES]     
cPROD	 := aCOLS[N][nPOSPROD]     
	
IF cTIPO <> "N"


	aCOLS[N][nPOSTES]	:= cTES
	aCOLS[N][nPOSCF] 	:= PEGACF(cA100FOR,cLOJA,cTES)
	RETURN .T.


ENDIF
	
DBSELECTAREA("SZT")
DBSETORDER(1)
DBGOTOP()
IF !DBSEEK(XFILIAL("SZT")+cCOD)
          
	FOR X:= 1 TO LEN(aCOLS)
		aCOLS[X][nPOSTES]	:= cTES
		aCOLS[X][nPOSCF] 	:= PEGACF(cA100FOR,cLOJA,cTES)
	NEXT
	RETURN .T.

ENDIF
lACHOU := .F.
WHILE !EOF() .AND. SZT->ZT_OPERA == CCOD
	cOPER	:= SZT->ZT_TESINT
	lACHOU	:= .T.
	DBSKIP()
END
IF !lACHOU


	FOR X:= 1 TO LEN(aCOLS)
		aCOLS[X][nPOSTES]	:= cTES
		aCOLS[X][nPOSCF] 	:= PEGACF(cA100FOR,cLOJA,cTES)
	NEXT


	RETURN .T.
ENDIF
	
cTES				:= MaTesInt(2,cOPER,cA100FOR,cLOJA,"F",cPROD,"C6_TES")
FOR X:= 1 TO LEN(aCOLS)
	aCOLS[X][nPOSTES]	:= cTES
	aCOLS[X][nPOSCF] 	:= PEGACF(cA100FOR,cLOJA,cTES)
NEXT

RETURN .T.


                              
STATIC FUNCTION PEGACF(cA100FOR,cLOJA,cTES)
LOCAL cRET

DbSelectArea("SA2")
DbSetOrder( 1 )
If MsSeek( xFilial("SA2") + cA100FOR + cLOJA )

   cTipoFor := SA2->A2_TIPO
   cEstFor  := SA2->A2_EST
   
EndIf                                                 


DbSelectarea("SF4")
DbSetorder(1)
If MsSeek( xFilial( "SF4" ) + cTes )
	
	If SF4->F4_DUPLIC == "S"
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณSe a TES nao estiver bloqueada valida se a quantidade pode ser igual a 0,00  ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
        If MaTesSel(cTes)
        
			_lTesTit := .F.				
			
		Else
		
			_lTesTit := .T.	
			
		EndIf
		
	Else
		
		_lTesTit := .F.
			
	EndIf
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณPreenche o CFO                                        ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If cPaisLoc!="BRA"
		
		cRet := Alltrim( SF4->F4_CF )
			
	Else
		
		If (cTipoFor!="X")
			
			If (cEstFor == _cEstado)
				
				cRet := SF4->F4_CF
					
			Else
				
				cRet := "6" + Subs( SF4->F4_CF,2,Len( SF4->F4_CF ) - 1 ) 
			
			EndIf
				
		Else
				
			cRet := "7" + Subs( SF4->F4_CF,2,Len( SF4->F4_CF ) - 1 ) 	
			
		EndIf	

		Aadd(_aDadosCfo,{"OPERNF"	,"S" } )
		Aadd(_aDadosCfo,{"TPCLIFOR"	,cTipoFor } ) //_cTipoCli
		Aadd(_aDadosCfo,{"UFDEST"	,cEstFor } )
		cRet :=  MaFisCfo(,SF4->F4_CF,_aDadosCfo)
            
		
	EndIf
	
EndIf
	
RETURN(cRET)