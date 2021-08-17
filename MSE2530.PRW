#INCLUDE "PROTHEUS.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MSE2530  ºAutor  ³Andre Salgado/Introde º Data ³ 26/08/2020 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Ponto de entrada CHAMADO APOS DE ATUALIZAR SE2            º±±
±±º          ³ Retorno : Nenhum                                           º±± 
±±º          ³ Tratamento comissoes: Contas a Pagar / Pedidos de Compras  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ 		                                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function MSE2530()

	Local aITEMPC  := {}
	Local aCABPC   := {}   
	Local aAREA	   := GETAREA()
	Local aAreaSE2 := SE2->( GETAREA() )
	Local _CndPgt  := "C99"	//Criar Cond.Pagto - TIPO = "3", com Regra 1,1,15,28 (Pagto até dia 15 e depois dia 28)
	Private lMSERROAUTO	:= .F.      
	
	cOBS     := SE2->E2_FORNECE+"/"+SE2->E2_NUM+"/"+ALLTRIM(SE2->E2_NOMFOR) //"900809 - J. M. PRIMUS 2005 REP"
	nPRECO   := SE2->E2_VALOR + (SE2->E2_IRRF+SE2->E2_ISS+SE2->E2_INSS)
	dDATPRF  := SE2->E2_VENCREA
	cFORNECE := SE2->E2_FORNECE
	cLOJA    := SE2->E2_LOJA
	cTITPAI  := SE2->E2_PREFIXO + SE2->E2_NUM + SE2->E2_PARCELA + SE2->E2_TIPO + SE2->E2_FORNECE + SE2->E2_LOJA

	_cDepSC7 := "000000010"		//Campos Customizado - Pedido de Compra Conforme Qual o Depto FERNANDO/SUMAIA
	
	DBSelectArea("SE2")
	SE2->(DBSetOrder(1))

	//cUpse2 := " UPDATE SE2010 SET D_E_L_E_T_='*' WHERE "
	//cUpse2 += " E2_FILIAL = '"+SE2->E2_FILIAL+"' AND "
	//cUpse2 += " E2_PREFIXO ='"+SE2->E2_PREFIXO+"' AND "
	//cUpse2 += " E2_NUM='"+SE2->E2_NUM+"' AND "
	//cUpse2 += " E2_TIPO in('DP','TX')  AND "
	//cUpse2 += " E2_FORNECE IN('UNIAO','"+SE2->E2_FORNECE+"') AND "
	//cUpse2 += " E2_EMISSAO='"+DTOS(DDATABASE)+"' " 

	//TCSQLExec( cUpse2 )
	
	aITEMPC	:=	{{"C7_ITEM"		,"0001"			,NIL},;
				{"C7_PRODUTO"	,"COMISSAO"     ,NIL},;
				{"C7_UM"		,"UN"		    ,NIL},;   
				{"C7_SEGUM"		,"UN"		    ,NIL},;   
				{"C7_QUANT"		,1 			    ,NIL},;
				{"C7_PRECO"		,nPRECO		    ,NIL},;
				{"C7_OBS"		,cOBS		    ,NIL},;
				{"C7_TES"		,"051"			,NIL},;                     
				{"C7_FLUXO"		,"S"			,NIL},;
				{"C7_LOCAL"		,"01"			,NIL},;
				{"C7_DATPRF"	,dDATPRF		,NIL},;
				{"C7_XTITPAI"	,cTITPAI		,NIL}}       

				//{"C7_APROV"		,"000491"		,NIL},;
	                                                                        
	cPEDIDO	:= GETSX8NUM("SC7","C7_NUM")
			
	aCABPC	:=	{{"C7_NUM"		,cPEDIDO		,NIL},;
				{"C7_EMISSAO"	,dDATABASE		,NIL},; 
				{"C7_FORNECE"	,cFORNECE		,NIL},;
				{"C7_LOJA"		,cLOJA			,NIL},;
				{"C7_CC"		,"01010200"		,NIL},;     
				{"C7_COND"		,_CndPgt		,NIL},; 
				{"C7_CONTATO"	,""				,NIL},;
				{"C7_FILENT"	,"01"			,NIL}}
	                   
	                                                  
	MsEXECAUTO( {|v,x,y,z| MATA120(v,x,y,z)},1,aCABPC,{aITEMPC},3)  

	                                                                
	IF lMSERROAUTO
		MOSTRAERRO()
		ROLLBACKSX8()
	ELSE
		CONFIRMSX8()
	ENDIF
	
	PERGUNTE("MTA530",.F.)
	
	RESTAREA(aAreaSE2)
	RESTAREA(aAREA)
	
Return .T.

/*
USER FUNCTION MTA120G3()

	LOCAL cRET := .T.
	IF l120AUTO .And. !IsInCallStack("EICPO400") 
		cRET := .F.
	ENDIF

RETURN(cRET)
*/

