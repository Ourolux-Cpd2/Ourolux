#INCLUDE "PROTHEUS.CH" 

#DEFINE COMP_DATE "20191209"


//-------------------------------------------------------------------------------------
/*/{Protheus.doc} XVLDFAT
Biblioteca de validacoes genericas do FATURAMENTO 

@type 		function
@author 	Roberto Souza
@since 		09/02/2017
@version 	P12 
 
@return nil
/*/    
//-------------------------------------------------------------------------------------
User Function XVLDFAT()
	MsgAlert("XVLDFAT "+COMP_DATE)
Return( .T. )



//-------------------------------------------------------------------------------------
/*/{Protheus.doc} xAuto410
Determina se usa o programa se for chamado por execauto 

@type 		function
@author 	Roberto Souza
@since 		09/02/2017
@version 	P11 
 
@return nil
/*/    
//-------------------------------------------------------------------------------------
User Function xAuto410()
	Local lRet := .T.
    Conout("[xAuto410] " + Procname(1) + " - "+Time())
	If IsInCallStack("U_INTRJ") .Or. IsInCallStack("U_INTPV")
		lRet := .F.		
	EndIf	
Return( lRet )
              


//-------------------------------------------------------------------------------------
/*/{Protheus.doc} Ou410Lin
Função executada pelo gatilho na no campo C6_PRODUTO para preencher informações de digitação.

@type 		function
@author 	Roberto Souza
@since 		19/01/2017
@version 	P11 
 
@return nil
/*/    
//-------------------------------------------------------------------------------------
User Function Ou410Lin()
	Local uRet 	:= &(ReadVar()) 
	Local cCpo  := ReadVar() 
	Local cPar01:= ""      
	Local aArea := GetArea()
	Local nPProd     	:= aScan(aHeader,{ |x| Upper(AllTrim(x[2])) == "C6_PRODUTO" })
	Local nPosLocal  	:= aScan(aHeader,{ |x| Upper(AllTrim(x[2])) == "C6_LOCAL" 	})
	Local nPosEnd 		:= aScan(aHeader,{ |x| Upper(AllTrim(x[2])) == "C6_LOCALIZ" })

	aInfo   := U_RetParAR( "FS_SACSC6","Sac;10;SAC" )// USUARIOS;ARMAZEM;LOCALIZACAO
        
	If !Empty(aInfo) .And. Upper(UsrRetName(__cUserId)) $ Upper(aInfo[01])
	
		If "C6_PRODUTO" $ cCpo
			cArmazem 	:= aInfo[02]                
			cLocaliz 	:= aInfo[03] 
			
			aCols[n][nPosLocal]	:= cArmazem
			aCols[n][nPosEnd]	:= cLocaliz  
		EndIf
   	EndIf

	RestArea( aArea )
	
Return( uRet )     


User Function xSac()
	Local lRet := .F.

	aInfo   := U_RetParAR( "FS_SACSA1","Sac;10;SAC" )// USUARIOS;ARMAZEM;LOCALIZACAO
        
	If !Empty(aInfo) .And. Upper(UsrRetName(__cUserId)) $ Upper(aInfo[01])
   		lRet := .T.
   	EndIf
	
Return( lRet )	   



/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³CLCPDESC  ³ Autor ³ André Bagatini        ³ Data ³10/06/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Calcula o desconto aplicado de acordo com o que está digita ³±±
±±³          ³do no campo valor do item no Call Center					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
//-------------------------------------------------------------------------------------
/*/{Protheus.doc} xSC6Desc
Calcula o desconto aplicado de acordo com o que está digita do no campo valor do item

@type 		function
@author 	Roberto Souza
@since 		31/03/2017
@version 	P11 
 
@return nil
/*/    
//-------------------------------------------------------------------------------------
User Function xSC6Desc()

Local aArea	   	 	:=	GetArea()
Local nDesc 	 	:= 0
Local aCFOP      	:= {}
Local nPosPrc    	:= aScan(aHeader,{ |x| Upper(AllTrim(x[2])) == "C6_PRCVEN" })
Local nPPrcTab    	:= aScan(aHeader,{ |x| Upper(AllTrim(x[2])) == "C6_PRUNIT" })
Local nPDesc    	:= aScan(aHeader,{ |x| Upper(AllTrim(x[2])) == "C6_UDESC" })
Local nPItem    	:= aScan(aHeader,{ |x| Upper(AllTrim(x[2])) == "C6_ITEM" })
Local nRetorno		:= 0


If aCols[n][nPosPrc] <> aCols[n][nPPrcTab] .And. aCols[n][nPosPrc] < aCols[n][nPPrcTab]
	nDesc := 100 - (( aCols[n][nPosPrc] / aCols[n][nPPrcTab] ) * 100)
	nRetorno :=  Round(nDesc,2)
	aCols [n][nPDesc] := Round(nDesc,2)
Endif
	
RestArea(aArea)

Return(nRetorno)


//-------------------------------------------------------------------------------------
/*/{Protheus.doc} xMFLoad
Executa o Load das funcoes MaFis(MATXFIS)

@type 		function
@author 	Roberto Souza
@since 		09/02/2017
@version 	P11 
 
@return nil
/*/    
//-------------------------------------------------------------------------------------
User Function xMFisIni( cNumPed )
	Local lRet 	:= .F.
 	Local aArea := GetArea()

 	Conout("[xMFisIni] "+cNumPed+" In : "+Time())

 	DbSelectArea("SC5")
 	SC5->(DbSetOrder(1))
 	If SC5->(DbSeek( xFilial("SC5") + cNumPed ))

		MaFisIni(SC5->C5_CLIENTE,;	// 1-Codigo Cliente/Fornecedor
			 	SC5->C5_LOJACLI,;	// 2-Loja do Cliente/Fornecedor
				"C",;				// 3-C:Cliente , F:Fornecedor
		 		"N",;				// 4-Tipo da NF
		 		SC5->C5_TIPOCLI,;   // 5-Tipo do Cliente/Fornecedor
		 		MaFisRelImp("MTR700",{"SC5","SC6"}),;				// 6-Relacao de Impostos que suportados no arquivo
		 		Nil,;				// 7-Tipo de complemento
		 		Nil,;				// 8-Permite Incluir Impostos no Rodape .T./.F.
		 		"SB1",;				// 9-Alias do Cadastro de Produtos - ("SBI" P/ Front Loja)
		 		Nil)				// 10-Nome da rotina que esta utilizando a funcao

		DbSelectArea("SC6")
		SC5->(DbSelectArea(1))

		If SC6->(DbSeek(xFilial("SC6")+SC5->C5_NUM))
            While SC6->(!Eof()) .And. SC6->C6_FILIAL == SC5->C5_FILIAL .And. SC6->C6_NUM == SC5->C5_NUM
		
				MaFisAdd( 	SC6->C6_PRODUTO,;
							SC6->C6_TES,;
							SC6->C6_QTDVEN,;
							SC6->C6_PRUNIT,;
							SC6->C6_VALDESC,;
							"",;
							"",;
							0,;
							0,;
							0,;
							0,;
							0,;
							(SC6->C6_QTDVEN*SC6->C6_PRUNIT),;
							0,;
							0,;
							0)  
			        
				SC6->(DbSkip())
			EndDo				
		    lRet := .T.                 
		EndIf

    EndIf
    
    RestArea( aArea )
 	Conout("[xMFisIni] "+cNumPed+" Out: "+Time())
Return( lRet )


//-------------------------------------------------------------------------------------
/*/{Protheus.doc} xChgCli
Função executada para fazer consistencia quando se altera cliente.

@type 		function
@author 	Roberto Souza
@since 		24/04/2017
@version 	P11 
 
@return nil
/*/    
//-------------------------------------------------------------------------------------
User Function xChgCli()
	Local lRet 	:= .T.
	Local nx	:= 0	                
	Local cCpo	:= ""
	Local lFat 	:= IsInCallStack("MATA410")	
	Local lTmk 	:= IsInCallStack("TMKA271")	

	If lFat
		cCpo 		:= "C6_PRODUTO"                                       
		cCpoTes		:= "C6_TES"                                       		
		nPosProd	:= aScan(aHeader,{ |x| Upper(AllTrim(x[2])) == cCpo })
		nPosTes		:= aScan(aHeader,{ |x| Upper(AllTrim(x[2])) == cCpoTes })
        cTab 		:= "SC6"
	ElseIf lTmk
		cCpo 		:= "UB_PRODUTO"     
		cCpoTes		:= "UB_TES"                                       				
		nPosProd	:= aScan(aHeader,{ |x| Upper(AllTrim(x[2])) == cCpo })
		nPosTes		:= aScan(aHeader,{ |x| Upper(AllTrim(x[2])) == cCpoTes })
        cTab 		:= "SUB"
	EndIf	

	For Nx := 1 To Len( aCols ) 
		N := Nx 
		cRetTes := xCalcSZT( cTab, aCols[Nx][nPosProd]  )
		If !Empty(cRetTes)
			aCols[Nx][nPosTes]	:= cRetTes
		EndIf
	Next

	N := 1
Return( lRet )     


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ CALCSZT º Autor ³ EDUARDO LOBATO     º Data ³  09/05/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ CALCULO DA TES INTELIGENTE BBASEADA NA OPERAÇÃO            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ OUROLUX                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function xCalcSZT( cMOD, cProd )
Local cTES	:= ""
Local aArea	:= GetArea()

IF cMOD == "SC6" 

	nPOSTES	:= ASCAN(aHEADER,{ |X| UPPER(ALLTRIM(X[2])) == "C6_TES" })
	nPOSCF	:= ASCAN(aHEADER,{ |X| UPPER(ALLTRIM(X[2])) == "C6_CF" })
	nPOSOP	:= ASCAN(aHEADER,{ |X| UPPER(ALLTRIM(X[2])) == "C6_OPER" })
	cTES	:= aCOLS[N][nPOSTES]
	
	IF EMPTY(M->C5_TESINT) .OR. M->C5_TIPO <> "N"
		RestArea(aArea) // por Icaro Queiroz em 11 Fev 2015
		RETURN(cTES)
	ENDIF
	
	DBSELECTAREA("SZT")
	DBSETORDER(1)
	DBGOTOP()
	IF !DBSEEK(XFILIAL("SZT")+M->C5_TESINT)
		RestArea(aArea) // por Icaro Queiroz em 11 Fev 2015
		RETURN(cTES)
	ENDIF
	lACHOU := .F.
	WHILE !EOF() .AND. SZT->ZT_OPERA == M->C5_TESINT
		IF SA1->A1_TIPO == SZT->ZT_TIPOCLI
			cOPER	:= SZT->ZT_TESINT
			lACHOU	:= .T.
			EXIT
		ENDIF
		DBSKIP()
	END
	IF !lACHOU
		RestArea(aArea) // por Icaro Queiroz em 11 Fev 2015
		RETURN(cTES)
	ENDIF
	
//	cTES	:= MaTesInt(2,cOPER,M->C5_CLIENT,M->C5_LOJAENT,If(M->C5_TIPO$'DB',"F","C"),cProd,"C6_TES")
	cTES	:= MaTesInt(2,cOPER,M->C5_CLIENTE,M->C5_LOJACLI,If(M->C5_TIPO$'DB',"F","C"),cProd,"C6_TES")
	aCOLS[N][nPOSOP] := cOPER
	aCOLS[N][nPOSCF] := U_GeraCF(M->C5_CLIENTE,M->C5_LOJACLI,cTES)
	
ELSEIF cMOD == "SUB"
	
	nPOSTES	:= ASCAN(aHEADER,{ |X| UPPER(ALLTRIM(X[2])) == "UB_TES" })
	nPOSCF	:= ASCAN(aHEADER,{ |X| UPPER(ALLTRIM(X[2])) == "UB_CF" })
	nPOSOP	:= ASCAN(aHEADER,{ |X| UPPER(ALLTRIM(X[2])) == "UB_OPER" })
	cTES	:= aCOLS[N][nPOSTES]
	
	IF EMPTY(M->UA_TESINT)
		RestArea(aArea) // por Icaro Queiroz em 11 Fev 2015
		RETURN(cTES)
	ENDIF                                  
	
	If !SUA->UA_PROSPEC
		cTIPO	:= SA1->A1_TIPO
	ELSE
		cTIPO	:= SUS->US_TIPO
	ENDIF
	
	DBSELECTAREA("SZT")
	DBSETORDER(1)
	DBGOTOP()
	IF !DBSEEK(XFILIAL("SZT")+M->UA_TESINT)
		RestArea(aArea) // por Icaro Queiroz em 11 Fev 2015
		RETURN(cTES)
	ENDIF
	lACHOU := .F.
	WHILE !EOF() .AND. SZT->ZT_OPERA == M->UA_TESINT
		IF cTIPO == SZT->ZT_TIPOCLI
			cOPER	:= SZT->ZT_TESINT
			lACHOU	:= .T.
			EXIT
		ENDIF
		DBSKIP()
	END
	IF !lACHOU
		RestArea(aArea) // por Icaro Queiroz em 11 Fev 2015
		RETURN(cTES)
	ENDIF
	
	cTES	:= MaTesInt(2,cOPER,M->UA_CLIENTE,M->UA_LOJA,"C",cProd,"UB_TES")
	aCOLS[N][nPOSOP] := cOPER
	aCOLS[N][nPOSCF] := TK273CFO(M->UA_CLIENTE,M->UA_LOJA,cTES)
	
ElseIf cMOD == "AUT" 
	//nPOSTES	:= ASCAN(aHEADER,{ |X| UPPER(ALLTRIM(X[2])) == "C6_TES" })
	//nPOSCF	:= ASCAN(aHEADER,{ |X| UPPER(ALLTRIM(X[2])) == "C6_CF" })
	//nPOSOP	:= ASCAN(aHEADER,{ |X| UPPER(ALLTRIM(X[2])) == "C6_OPER" })
	//cTES	:= aCOLS[N][nPOSTES]
	
	//IF EMPTY(M->C5_TESINT) .OR. M->C5_TIPO <> "N"
	//	RETURN(cTES)
	//ENDIF
	
	cTipo	:= GetAdvFVal("SA1","A1_TIPO",xFilial("SA1")+(cCliente+cLoja),1,"")
	
	DBSELECTAREA("SZT")
	DBSETORDER(1)
	DBGOTOP()
	IF !DBSEEK(XFILIAL("SZT")+cOperSZT)
		RestArea(aArea) // por Icaro Queiroz em 11 Fev 2015
		RETURN(cTES)
	ENDIF
	lACHOU := .F.
	WHILE !EOF() .AND. SZT->ZT_OPERA == cOperSZT
		IF cTipo == SZT->ZT_TIPOCLI
			cOPER	:= SZT->ZT_TESINT
			lACHOU	:= .T.
			EXIT
		ENDIF
		DBSKIP()
	END
	IF !lACHOU
		RestArea(aArea) // por Icaro Queiroz em 11 Fev 2015
		RETURN(cTES)
	ENDIF
	
//	cTES	:= MaTesInt(2,cOPER,cCLiente,cLoja,"C",cProduto,"C6_TES")
	cTES	:= MaTesInt(2,cOPER,cCLiente,cLoja,"C",cProduto)
//	aCOLS[N][nPOSCF] := U_GeraCF(M->C5_CLIENTE,M->C5_LOJACLI,cTES)



ENDIF

RestArea(aArea)
RETURN(cTES)
