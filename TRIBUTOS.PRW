#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ TRIBUTOS º Autor ³			         ºData  ³  06/04/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Rotina para criar a string com dados para pagamento de     º±±
±±º          ³ tributos sem código de barras                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ KDL		                                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

USER FUNCTION TRIBUTOS()

LOCAL cString1	:=""
LOCAL cString2	:=""
LOCAL cString3	:=""
LOCAL cString4	:=""
LOCAL cString5	:=""
LOCAL cTributo := AllTrim( SE2->E2_IDTTRIB )


IF 	   !Empty(cTributo) .AND. cTributo =='01'
	
		cString1 :=  U_DADOSGPS()
		return(cString1)
	
ELSEIF !Empty(cTributo) .AND. cTributo =='02'
	
		cString2 := U_DADOSDARF()
		return(cString2)	
	
ELSEIF !Empty(cTributo) .AND. cTributo =='05'
	
		cString3 := U_DADOSGARE()
		return(cString3) 
		
ELSEIF !Empty(cTributo) .AND. cTributo =='11'	
					
		cString5 := U_DADOSFGTS()
		return(cString5)
	
ENDIF


Return()

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ DADOSGPS º Autor ³                    ºData  ³  06/04/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Rotina para criar a string com dados para pagamento de GPS º±±
±±º          ³ sem código de barras                                       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ KDL		                                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

USER FUNCTION DADOSGPS()

Local cRetGPS  := ""


cRetGPS := SE2->E2_IDTTRIB															// "01"	IDENTIFICACAO DO TRIBUTO (2) 
cRetGPS += SE2->E2_CODRECE															// "2100" CODIGO DE PAGTO (4)
cRetGPS += STRZERO(MONTH(SE2->E2_DTCOMPT),2)+STRZERO(YEAR(SE2->E2_DTCOMPT),4)		// "MMAAA" COMPETENCIA (6)
cRetGPS += SUBSTR(SM0->M0_CGC,1,14)											   		//INSCRICAO NUMERO - CNPJ OU CPF (14)
cRetGPS += STRZERO((SE2->E2_VALOR)*100,14)											//VALOR PRINCIPAL (14)
cRetGPS += STRZERO((SE2->E2_ACRESC )*100,14)											//VALOR ENTIDADES (14)
cRetGPS += STRZERO((SE2->E2_MULTA + SE2->E2_JUROS )*100,14)						//VALOR DA MULTA + JUROS + ATM(14)
cRetGPS += STRZERO(((SE2->E2_VALOR + SE2->E2_MULTA + SE2->E2_JUROS + SE2->E2_ACRESC  )-(SE2->E2_DESCONT + SE2->E2_DECRESC))*100,14)  //VALOR TOTAL (14)
cRetGPS += GRAVADATA(SE2->E2_VENCREA,.F.,5)										//DATA PAGAMENTO (8)
cRetGPS += SPACE(50)																//BRANCOS (50)
cRetGPS += SUBSTR(SM0->M0_NOME,1,30	)												//NOME DO CONTRIBUINTE (30)


Return(cRetGPS)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ DADOSDARF º Autor ³                   ºData  ³  06/04/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Rotina para criar a string com dados para pagamento de DARFº±±
±±º          ³ sem código de barras                                       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ KDL		                                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

USER FUNCTION DADOSDARF()

Local cRetDARF  := ""


cRetDARF := SE2->E2_IDTTRIB								// IDENTIFICACAO DO TRIBUTO (02)
cRetDARF += SE2->E2_CODRECE								// CODIGO DA RECEITA (04)
cRetDARF += "2"											//TIPO DE INSCRICAO DO CONTRIBUINTE 1=CPF, 2=CNPJ  (1)
cRetDARF += SUBSTR(SM0->M0_CGC,1,14)					//INSCRICAO NUMERO - CNPJ OU CPF (14)
cRetDARF += GRAVADATA(SE2->E2_DTCOMPT,.F.,5)			//PERIODO DE APURACAO (8)       
cRetDARF += IIF(Empty(SE2->E2_REFDARF),SPACE(17),(SUBST(Alltrim(SE2->E2_REFDARF),1,17)))//NUMERO DE REFERENCIA (17)
cRetDARF += STRZERO((SE2->E2_VALOR)*100,14)				//VALOR PRINCIPAL (14)
cRetDARF += STRZERO((SE2->E2_MULTA)*100,14)				//VALOR DA MULTA (14)
cRetDARF += STRZERO((SE2->E2_JUROS + SE2->E2_SDACRES)*100,14)//VALOR DOS JUROS/ENCARGOS (14)
cRetDARF += STRZERO(((SE2->E2_VALOR + SE2->E2_MULTA + SE2->E2_JUROS + SE2->E2_SDACRES )-(SE2->E2_DESCONT + SE2->E2_SDDECRE))*100,14)//VALOR TOTAL (14)
cRetDARF += GRAVADATA(SE2->E2_VENCTO,.F.,5)				//DATA VENCIMENTO (8)
cRetDARF += GRAVADATA(SE2->E2_VENCREA,.F.,5)		    //DATA PAGAMENTO (8)
cRetDARF += SPACE(30)									//BRANCOS (30)
cRetDARF += SUBSTR(SM0->M0_NOME,1,30)					//NOME DO CONTRIBUINTE (30)

Return(cRetDARF)




/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ DADOSGARE º Autor ³                   ºData  ³  06/04/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Rotina para criar a string com dados para pagamento de GAREº±±
±±º          ³ sem código de barras                                       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ KDL		                                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

USER FUNCTION DADOSGARE()

Local cRetGARE  := ""

cRetGARE := SE2->E2_IDTTRIB							//IDENTIFICACAO DO TRIBUTO (02)
cRetGARE += SE2->E2_CODRECE							//CODIGO DA RECEITA (04)
cRetGARE += "2"					   					//TIPO DE INSCRICAO DO CONTRIBUINTE 1=CPF, 2=CNPJ  (01)
cRetGARE += SUBSTR(SM0->M0_CGC,1,14)				//INSCRICAO NUMERO - CNPJ OU CPF (14)
cRetGARE += SUBSTR(SM0->M0_INSC,1,12)				//INSCRICAO ESTADUAL - CNPJ OU CPF (12)
cRetGARE += SPACE(13)								//BRANCOS (13)
cRetGARE += STRZERO(MONTH(SE2->E2_DTCOMPT),2)+STRZERO(YEAR(SE2->E2_DTCOMPT),4)	//REFERENCIA (06) MMAAAA
cRetGARE += SPACE(13)								//BRANCOS (13)
cRetGARE += STRZERO((SE2->E2_VALOR)*100,14)			//VALOR RECEITA (14)
cRetGARE += STRZERO((SE2->E2_JUROS + SE2->E2_SDACRES)*100,14)//VALOR DOS JUROS/ENCARGOS (14)
cRetGARE += STRZERO((SE2->E2_MULTA)*100,14)			//VALOR DA MULTA (14)
cRetGARE += STRZERO(((SE2->E2_VALOR + SE2->E2_MULTA + SE2->E2_JUROS + SE2->E2_SDACRES )-(SE2->E2_DESCONT + SE2->E2_SDDECRE))*100,14)//VALOR DO PAGAMENTO (14)
cRetGARE += GRAVADATA(SE2->E2_VENCTO,.F.,5)			//DATA VENCIMENTO (8)
cRetGARE += GRAVADATA(SE2->E2_VENCREA,.F.,5)		//DATA PAGAMENTO (8)
cRetGARE += SPACE(11)								//BRANCOS (11)
cRetGARE += SUBSTR(SM0->M0_NOME,1,30)				//NOME DO CONTRIBUINTE (30)

Return(cRetGARE)      



/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ DADOSFGTS º Autor ³                   ºData  ³  22/08/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Rotina para criar a string com dados para pagamento de FGTSº±±
±±º          ³ sem código de barras                                       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ KDL		                                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

USER FUNCTION DADOSFGTS()
             
Local  cRetFGST :=""                 	

	cRetFGST := SE2->E2_IDTTRIB								// IDENTIFICACAO DO TRIBUTO (02)"11"            	                            
	cRetFGST += SE2->E2_CODRECE								// Código da Receita
	cRetFGST += "2"											// TIPO DE INSCRIÇÃO DO CONTRIBUINTE (1-CPF / 2-CNPJ) 
	cRetFGST += StrZero(Val(SM0->M0_CGC),14)            	// CPF OU CNPJ DO CONTRIBUINTE 
	cRetFGST += AllTrim(SE2->E2_CODBAR)                   	// CODIGO DE BARRAS (LINHA DIGITAVEL)	(*criar campo*) 
	cRetFGST += StrZero(Val(SE2->E2_IDTFGST),16) 			// Identificador FGTS 
	cRetFGST += StrZero(Val(SE2->E2_LACFGTS),9)   			// Lacre de Conectividade Social 
	cRetFGST += StrZero(Val(SE2->E2_DGLACRE),2)  			// Digito do Lacre  
	cRetFGST += SubStr(SM0->M0_NOMECOM,1,30)                // NOME DO CONTRIBUINTE
	cRetFGST += GravaData(SE2->E2_VENCREA,.F.,5)           	// DATA DO PAGAMENTO 
	cRetFGST += StrZero(SE2->E2_SALDO*100,14)             	// VALOR DO PAGAMENTO 
	cRetFGST += Space(30)                                  	// COMPLEMENTO DE REGISTRO 
	


Return(cRetFGST)
                  

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ SOMAJM    º Autor ³                   ºData  ³  22/08/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Rotina para criar a string com dados de juros e multa      º±±
±±º          ³  					                                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ KDL		                                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
USER FUNCTION SOMAJM()

Local cReturn2  := "" 
Local nValcamp  := 0

nValcamp := (SE2->E2_MULTA + SE2->E2_JUROS + SE2->E2_SDACRES) 

cReturn2 += STRZERO(nValCamp*100,14) 

Return(cReturn2)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ SOMATOTAL º Autor ³                   ºData  ³  22/08/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Rotina para criar a string com dados de valor total        º±±
±±º          ³  					                                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ KDL		                                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
USER FUNCTION SOMATOTAL()

Local cReturn1  := "" 

cReturn1 := STRZERO(((SE2->E2_VALOR + SE2->E2_MULTA + SE2->E2_JUROS + SE2->E2_SDACRES )-(SE2->E2_DESCONT + SE2->E2_SDDECRE))*100,14)  

Return(cReturn1)  	           


USER FUNCTION VALDUP()

// MOA - 17/10/2019 - 15:50hs 
// Acrescentar demais campos de desconto, acrescimo e decrescimo na totalização do título
//Local cRET := STRZERO((SE2->E2_VALOR+SE2->E2_ACRESC-SE2->E2_DECRESC)*100,15)
Local cRET := STRZERO(((SE2->E2_VALOR + SE2->E2_MULTA + SE2->E2_JUROS + SE2->E2_SDACRES )-(SE2->E2_DESCONT + SE2->E2_SDDECRE))*100,15) 

RETURN(cRET)
