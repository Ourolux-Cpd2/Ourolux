#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � TRIBUTOS � Autor �			         �Data  �  06/04/11   ���
�������������������������������������������������������������������������͹��
���Descricao � Rotina para criar a string com dados para pagamento de     ���
���          � tributos sem c�digo de barras                              ���
�������������������������������������������������������������������������͹��
���Uso       � KDL		                                                  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
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
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � DADOSGPS � Autor �                    �Data  �  06/04/11   ���
�������������������������������������������������������������������������͹��
���Descricao � Rotina para criar a string com dados para pagamento de GPS ���
���          � sem c�digo de barras                                       ���
�������������������������������������������������������������������������͹��
���Uso       � KDL		                                                  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
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
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � DADOSDARF � Autor �                   �Data  �  06/04/11   ���
�������������������������������������������������������������������������͹��
���Descricao � Rotina para criar a string com dados para pagamento de DARF���
���          � sem c�digo de barras                                       ���
�������������������������������������������������������������������������͹��
���Uso       � KDL		                                                  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
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
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � DADOSGARE � Autor �                   �Data  �  06/04/11   ���
�������������������������������������������������������������������������͹��
���Descricao � Rotina para criar a string com dados para pagamento de GARE���
���          � sem c�digo de barras                                       ���
�������������������������������������������������������������������������͹��
���Uso       � KDL		                                                  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
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
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � DADOSFGTS � Autor �                   �Data  �  22/08/11   ���
�������������������������������������������������������������������������͹��
���Descricao � Rotina para criar a string com dados para pagamento de FGTS���
���          � sem c�digo de barras                                       ���
�������������������������������������������������������������������������͹��
���Uso       � KDL		                                                  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

USER FUNCTION DADOSFGTS()
             
Local  cRetFGST :=""                 	

	cRetFGST := SE2->E2_IDTTRIB								// IDENTIFICACAO DO TRIBUTO (02)"11"            	                            
	cRetFGST += SE2->E2_CODRECE								// C�digo da Receita
	cRetFGST += "2"											// TIPO DE INSCRI��O DO CONTRIBUINTE (1-CPF / 2-CNPJ) 
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
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � SOMAJM    � Autor �                   �Data  �  22/08/11   ���
�������������������������������������������������������������������������͹��
���Descricao � Rotina para criar a string com dados de juros e multa      ���
���          �  					                                      ���
�������������������������������������������������������������������������͹��
���Uso       � KDL		                                                  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
USER FUNCTION SOMAJM()

Local cReturn2  := "" 
Local nValcamp  := 0

nValcamp := (SE2->E2_MULTA + SE2->E2_JUROS + SE2->E2_SDACRES) 

cReturn2 += STRZERO(nValCamp*100,14) 

Return(cReturn2)

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � SOMATOTAL � Autor �                   �Data  �  22/08/11   ���
�������������������������������������������������������������������������͹��
���Descricao � Rotina para criar a string com dados de valor total        ���
���          �  					                                      ���
�������������������������������������������������������������������������͹��
���Uso       � KDL		                                                  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
USER FUNCTION SOMATOTAL()

Local cReturn1  := "" 

cReturn1 := STRZERO(((SE2->E2_VALOR + SE2->E2_MULTA + SE2->E2_JUROS + SE2->E2_SDACRES )-(SE2->E2_DESCONT + SE2->E2_SDDECRE))*100,14)  

Return(cReturn1)  	           


USER FUNCTION VALDUP()

// MOA - 17/10/2019 - 15:50hs 
// Acrescentar demais campos de desconto, acrescimo e decrescimo na totaliza��o do t�tulo
//Local cRET := STRZERO((SE2->E2_VALOR+SE2->E2_ACRESC-SE2->E2_DECRESC)*100,15)
Local cRET := STRZERO(((SE2->E2_VALOR + SE2->E2_MULTA + SE2->E2_JUROS + SE2->E2_SDACRES )-(SE2->E2_DESCONT + SE2->E2_SDDECRE))*100,15) 

RETURN(cRET)
