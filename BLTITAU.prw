#include "protheus.ch"
#include "rwmake.ch"

#DEFINE __cCarteira "109"
#DEFINE __cMoeda    "9"
/*
+-----------+----------+-------+--------------------+------+-------------+
| Programa  |BOLITAU   |Autor  |Daniel-SigaConsult  | Data |  15/04/2014 |
+-----------+----------+-------+--------------------+------+-------------+
| Desc.     |Impressao de boleto Itau                                    |
|           |                                                            |
+-----------+------------------------------------------------------------+
| Uso       |Ourolux - Receber                                           |
+-----------+------------------------------------------------------------+
*/
User Function BLTITAU(cNota,cPREFIXO,cCLIENTE,cLOJA)
Local	aPergs := {}
Private lExec    := .F.
Private cIndexName := ''
Private cIndexKey  := ''
Private cFilter    := ''
pRIVATE cNF

DEFAULT cNota := Space(09)

Tamanho  := "M"
titulo   := "Impressao de Boleto com Codigo de Barras"
cDesc1   := "Este programa destina-se a impressao do Boleto com Codigo de Barras."
cDesc2   := ""
cDesc3   := ""
cString  := /*"SEE" */   "SE1"
wnrel    := "BOLETO"
lEnd     := .F.
cPerg     := Padr("BOLTITAU",10)
aReturn  := {"Zebrado", 1,"Administracao", 2, 2, 1, "",1 }
nLastKey := 0

cNf	:= cNota

dbSelectArea("SE1")

PutSx1( cPerg   ,"01","De Prefixo"	           ,"","","mv_ch1","C",3,0,0,"G","","","","","MV_PAR01","","","","","","","","","","","","","","","","",{},{},{})
PutSx1( cPerg   ,"02","Ate Prefixo"	           ,"","","mv_ch2","C",3,0,0,"G","","","","","MV_PAR02","","","","","","","","","","","","","","","","",{},{},{})
PutSx1( cPerg   ,"03","De Numero"		       ,"","","mv_ch3","C",9,0,0,"G","","SE1","","","MV_PAR03","","","","","","","","","","","","","","","","",{},{},{})
PutSx1( cPerg   ,"04","Ate Numero"	           ,"","","mv_ch4","C",9,0,0,"G","","SE1","","","MV_PAR04","","","","","","","","","","","","","","","","",{},{},{})
PutSx1( cPerg   ,"05","De Parcela"	           ,"","","mv_ch5","C",1,0,0,"G","","","","","MV_PAR05","","","","","","","","","","","","","","","","",{},{},{})
PutSx1( cPerg   ,"06","Ate Parcela"	           ,"","","mv_ch6","C",1,0,0,"G","","","","","MV_PAR06","","","","","","","","","","","","","","","","",{},{},{})
PutSx1( cPerg   ,"07","De Portador"	           ,"","","mv_ch7","C",3,0,0,"G","","","","","MV_PAR07","","","","","","","","","","","","","","","","",{},{},{})
PutSx1( cPerg   ,"08","Ate Portador" 	       ,"","","mv_ch8","C",3,0,0,"G","","","","","MV_PAR08","","","","","","","","","","","","","","","","",{},{},{})
PutSx1( cPerg   ,"09","De Cliente"	           ,"","","mv_ch9","C",6,0,0,"G","","SA1","","","MV_PAR09","","","","","","","","","","","","","","","","",{},{},{})
PutSx1( cPerg   ,"10","Ate Cliente"	           ,"","","mv_cha","C",6,0,0,"G","","SA1","","","MV_PAR10","","","","","","","","","","","","","","","","",{},{},{})
PutSx1( cPerg   ,"11","De Loja"		           ,"","","mv_chb","C",2,0,0,"G","","","","","MV_PAR11","","","","","","","","","","","","","","","","",{},{},{})
PutSx1( cPerg   ,"12","Ate Loja"		       ,"","","mv_chc","C",2,0,0,"G","","","","","MV_PAR12","","","","","","","","","","","","","","","","",{},{},{})
PutSx1( cPerg   ,"13","De Emissao"	           ,"","","mv_chd","D",8,0,0,"G","","","","","MV_PAR13","","","","","","","","","","","","","","","","",{},{},{})
PutSx1( cPerg   ,"14","Ate Emissao"	           ,"","","mv_che","D",8,0,0,"G","","","","","MV_PAR14","","","","","","","","","","","","","","","","",{},{},{})
PutSx1( cPerg   ,"15","De Vencimento"	       ,"","","mv_chf","D",8,0,0,"G","","","","","MV_PAR15","","","","","","","","","","","","","","","","",{},{},{})
PutSx1( cPerg   ,"16","Ate Vencimento"         ,"","","mv_chg","D",8,0,0,"G","","","","","MV_PAR16","","","","","","","","","","","","","","","","",{},{},{})
PutSx1( cPerg   ,"17","Do Bordero"	           ,"","","mv_chh","C",6,0,0,"G","","","","","MV_PAR17","","","","","","","","","","","","","","","","",{},{},{})
PutSx1( cPerg   ,"18","Ate Bordero"            ,"","","mv_chi","C",6,0,0,"G","","","","","MV_PAR18","","","","","","","","","","","","","","","","",{},{},{})
PutSx1( cPerg   ,"19","Banco     "             ,"","","mv_chj","C",3,0,0,"G","","SEE","","","MV_PAR19","","","","","","","","","","","","","","","","",{},{},{})
PutSx1( cPerg   ,"20","Agencia    "            ,"","","mv_chl","C",5,0,0,"G","","","","","MV_PAR20","","","","","","","","","","","","","","","","",{},{},{})
PutSx1( cPerg   ,"21","Conta      "            ,"","","mv_chm","C",10,0,0,"G","","","","","MV_PAR21","","","","","","","","","","","","","","","","",{},{},{})

/*For i:=1 to Len(aPergs)
If !dbSeek(cPerg+aPergs[i,2])
RecLock("SX1",.T.)
For j:=1 to Len(aPergs[i]) //FCount()
FieldPut(j,aPergs[i,j])
Next
MsUnlock()
Endif
Next
*/
//AjustaSx1(cPerg,aPergs)
If Empty(cNF)
	If !Pergunte (cPerg,.T.)
		Return
	Endif
endif
If Empty(cNF)
	/*	Wnrel := SetPrint(cString,Wnrel,cPerg,@Titulo,cDesc1,cDesc2,cDesc3,.F.,,,Tamanho,,)
	
	If nLastKey == 27
	Set Filter to
	Return
	Endif
	
	SetDefault(aReturn,cString)
	
	If nLastKey == 27
	Set Filter to
	Return
	Endif
	*/
	cIndexName	:= Criatrab(Nil,.F.)
	cIndexKey	:= "E1_PORTADO+E1_CLIENTE+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO+DTOS(E1_EMISSAO)"
	cFilter		+= "E1_FILIAL=='"+xFilial("SE1")+"'.And.E1_SALDO>0.And."
	cFilter		+= "E1_PREFIXO>='" + MV_PAR01 + "'.And.E1_PREFIXO<='" + MV_PAR02 + "'.And."
	cFilter		+= "E1_NUM>='" + MV_PAR03 + "'.And.E1_NUM<='" + MV_PAR04 + "'.And."
	cFilter		+= "E1_PARCELA>='" + MV_PAR05 + "'.And.E1_PARCELA<='" + MV_PAR06 + "'.And."
	cFilter		+= "E1_CLIENTE>='" + MV_PAR09 + "'.And.E1_CLIENTE<='" + MV_PAR10 + "'.And."
	cFilter		+= "E1_LOJA>='" + MV_PAR11 + "'.And.E1_LOJA<='"+MV_PAR12+"'.And."
	cFilter		+= "DTOS(E1_EMISSAO)>='"+DTOS(mv_par13)+"'.and.DTOS(E1_EMISSAO)<='"+DTOS(mv_par14)+"'.And."
	cFilter		+= "DTOS(E1_VENCREA)>='"+DTOS(mv_par15)+"'.and.DTOS(E1_VENCREA)<='"+DTOS(mv_par16)+"'.And."
	cFilter		+= "E1_NUMBOR>='" + MV_PAR17 + "'.And.E1_NUMBOR<='" + MV_PAR18 + "'.And."
	cFilter		+= "!(E1_TIPO$MVABATIM)"
	If Empty(MV_PAR19)
		cFilter		+= ".And. E1_PORTADO>='" + MV_PAR07 + "'.And.E1_PORTADO<='" + MV_PAR08 + "' "
		cFilter		+= ".And. E1_PORTADO<>'   '"
	Endif
Else
	cFilter		+= "E1_NUM = '" + cNF + "' .And."
	cFilter		+= "E1_PREFIXO ='" + cPREFIXO+ "'.And."
	cFilter		+= "E1_CLIENTE ='" + cCLIENTE + "'.And."
	cFilter		+= "E1_LOJA ='" + cLOJA + "'"
	
Endif
IndRegua("SE1", cIndexName, cIndexKey,, cFilter, "Aguarde selecionando registros....")
DbSelectArea("SE1")
#IFNDEF TOP
	DbSetIndex(cIndexName + OrdBagExt())
#ENDIF
dbGoTop()

If Empty(cNF)
	
	@ 001,001 TO 400,700 DIALOG oDlg TITLE "Seleção de Titulos"
	@ 001,001 TO 170,350 BROWSE "SE1" MARK "E1_OK"
	@ 180,310 BMPBUTTON TYPE 01 ACTION (lExec := .T.,Close(oDlg))
	@ 180,280 BMPBUTTON TYPE 02 ACTION (lExec := .F.,Close(oDlg))
	ACTIVATE DIALOG oDlg CENTERED
	
	dbGoTop()
Else
	lExec := .t.
Endif

If lExec
	Processa({|lEnd|MontaRel()})
Endif
RetIndex("SE1")
Ferase(cIndexName+OrdBagExt())
Return

/*
+-----------+----------+-------+--------------------+------+-------------+
| Programa  |BOLITAU   |Autor  |Microsiga           | Data |  11/21/05   |
+-----------+----------+-------+--------------------+------+-------------+
| Desc.     |                                                            |
|           |                                                            |
+-----------+------------------------------------------------------------+
| Uso       | AP                                                         |
+-----------+------------------------------------------------------------+
*/
Static Function MontaRel()
Local oPrint
Local nX		:= 0
Local cNroDoc 	:= " "
Local aDadosEmp    := {	SM0->M0_NOMECOM                                    ,;                                //[1]Nome da Empresa
SM0->M0_ENDCOB                                     ,;                        //[2]Endereço
AllTrim(SM0->M0_BAIRCOB)+", "+AllTrim(SM0->M0_CIDCOB)+", "+SM0->M0_ESTCOB ,; //[3]Complemento
"CEP: "+Subs(SM0->M0_CEPCOB,1,5)+"-"+Subs(SM0->M0_CEPCOB,6,3)             ,; //[4]CEP
"PABX/FAX: "+SM0->M0_TEL                                                  ,; //[5]Telefones
"CNPJ: "+Subs(SM0->M0_CGC,1,2)+"."+Subs(SM0->M0_CGC,3,3)+"."+          ;     //[6]
Subs(SM0->M0_CGC,6,3)+"/"+Subs(SM0->M0_CGC,9,4)+"-"+                       ; //[6]
Subs(SM0->M0_CGC,13,2)                                                    ,; //[6]CGC
"I.E.: "+Subs(SM0->M0_INSC,1,3)+"."+Subs(SM0->M0_INSC,4,3)+"."+            ; //[7]
Subs(SM0->M0_INSC,7,3)+"."+Subs(SM0->M0_INSC,10,3)                        }  //[7]I.E

Local aDadosTit   := {}
Local aDadosBanco := {}
Local aDatSacado  := {}
Local aBolText    := {"APOS O VENCIMENTO COBRAR MORA DE R$....... ",;
"PROTESTAR APOS 10 DIAS CORRIDOS DO VENCIMENTO ","AO DIA"}

Local nI          := 1
Local aCB_RN_NN   := {}
Local nVlrAbat	  := 0


Private cStartPath       := GetSrvProfString("Startpath","")

oPrint:= TMSPrinter():New( "Boleto Laser" )
oPrint:SetPortrait() // ou SetLandscape()
oPrint:Setup()   // Inicia uma nova página

DbGoTop()
ProcRegua(RecCount())
Do While !EOF()
	
	
	IF EMPTY(cNF)
		If Marked("E1_OK")
			
			If Empty(MV_PAR19)
				//Posiciona o SA6 (Bancos)
				DbSelectArea("SA6")
				DbSetOrder(1)
				DbSeek(xFilial("SA6")+SE1->E1_PORTADO+SE1->E1_AGEDEP+SE1->E1_CONTA,.T.)
				
				
				//Posiciona na Arq de Parametros CNAB
				DbSelectArea("SEE")
				DbSetOrder(1)
				DbSeek(xFilial("SEE")+SE1->(E1_PORTADO+E1_AGEDEP+E1_CONTA),.T.)
			Else
				//Posiciona o SA6 (Bancos)
				
				DbSelectArea("SA6")
				DbSetOrder(1)
				DbSeek(xFilial("SA6")+MV_PAR19+MV_PAR20+MV_PAR21,.T.)
				
				
				//Posiciona na Arq de Parametros CNAB
				DbSelectArea("SEE")
				DbSetOrder(1)
				//DbSeek("01"+"341"+"6083 "+"62525     "+"000")
				DbSeek(xFilial("SEE")+MV_PAR19+MV_PAR20+MV_PAR21,.T.)
			Endif
			/*
			//inserido por raul em 28/08/12
			//posiciona no pedido
			DbSelectArea("SC5")
			DbSetOrder(1)
			DbSeek(xFilial("SC5")+SE1->E1_PEDIDO,.T.)
			
			If !empty(SC5->C5_CLIENTC+SC5->C5_LOJACOB).and.(SC5->C5_FILIAL+SC5->C5_NUM==SE1->E1_FILIAL+SE1->E1_PEDIDO)
			DbSelectArea("SA1")
			DbSetOrder(1)
			DbSeek(xFilial()+SC5->C5_CLIENTC+SC5->C5_LOJACOB,.T.)
			Else
			*/
			//Posiciona o SA1 (Cliente)
			DbSelectArea("SA1")
			DbSetOrder(1)
			DbSeek(xFilial()+SE1->E1_CLIENTE+SE1->E1_LOJA,.T.)
			//Endif
			
			// Luiz Alberto - 06-02-2012 - Athena
			// Efetua o Preenchimento do Campo E1_NUMBCO com
			// o Numero Sequencial da Tabela EE_FAXATU.
			
			DbSelectArea("SE1")
			
			If Empty(SE1->E1_NUMBCO)
				
				NossoNum()
				
			Endif
			
			//DbSelectArea("SE1")
			//RecLock("SE1",.F.)
			//SE1->E1_NUMBCO 	:=	NossoNum() //aCB_RN_NN[3]   // Nosso número (Ver fórmula para calculo)
			//MsUnlock()
			
			
			
			//aAdd(aDadosBanco, Alltrim(SA6->A6_COD))             // [1]Numero do Banco
			aAdd(aDadosBanco, Alltrim(SEE->EE_CODIGO))            // [1]Numero do Banco
			aAdd(aDadosBanco, Alltrim(SA6->A6_NOME))              // [2]Nome do Banco
			//aAdd(aDadosBanco, Left(Alltrim(SA6->A6_AGENCIA),4)) // [3]Agência
			aAdd(aDadosBanco, Left(Alltrim(SEE->EE_AGENCIA),4))   // [3]Agência
			aAdd(aDadosBanco, Left(Alltrim(SEE->EE_CONTA),5))     // [4]Conta Corrente
			//aAdd(aDadosBanco, Alltrim(SA6->A6_NUMCON))          // [4]Conta Corrente
			//aAdd(aDadosBanco, Right(Alltrim(SA6->A6_DVCTA),1))  // [5]Dígito da conta corrente
			aAdd(aDadosBanco, Right(Alltrim(SEE->EE_DVCTA),1))    // [5]Dígito da conta corrente
			aAdd(aDadosBanco, Alltrim(__cCarteira))               // [6]Codigo da Carteira
			
			If Empty(SA1->A1_ENDCOB)
				aDatSacado   := {AllTrim(SA1->A1_NOME)           ,;      	// [1]Razão Social
				AllTrim(SA1->A1_COD )+"-"+SA1->A1_LOJA           ,;      	// [2]Código
				AllTrim(SA1->A1_END )+"-"+AllTrim(SA1->A1_BAIRRO),;      	// [3]Endereço
				AllTrim(SA1->A1_MUN )                            ,;  		// [4]Cidade
				SA1->A1_EST                                      ,;     	// [5]Estado
				SA1->A1_CEP                                      ,;      	// [6]CEP
				SA1->A1_CGC										 ,;         // [7]CGC
				SA1->A1_PESSOA									  }         // [8]PESSOA
			Else
				aDatSacado   := {AllTrim(SA1->A1_NOME)            	,;   	// [1]Razão Social
				AllTrim(SA1->A1_COD )+"-"+SA1->A1_LOJA              ,;   	// [2]Código
				AllTrim(SA1->A1_ENDCOB)+"-"+AllTrim(SA1->A1_BAIRROC),;   	// [3]Endereço
				AllTrim(SA1->A1_MUNC)	                            ,;   	// [4]Cidade
				SA1->A1_ESTC	                                    ,;   	// [5]Estado
				SA1->A1_CEPC                                        ,;   	// [6]CEP
				SA1->A1_CGC											,;		// [7]CGC
				SA1->A1_PESSOA										 }		// [8]PESSOA
			Endif
			
			nVlrAbat   :=  SomaAbat(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,"R",1,,SE1->E1_CLIENTE,SE1->E1_LOJA)
			/*
			--------------------------------------------------------------
			Parte do Nosso Numero. Sao 8 digitos para identificar o titulo
			--------------------------------------------------------------
			*/
			cNroDoc	:= StrZero(	Val(Alltrim(SE1->E1_NUM)+Alltrim(SE1->E1_PARCELA)),8)
			/*
			----------------------
			Monta codigo de barras
			----------------------
			*/
			//DbSelectArea("SE1")
			aCB_RN_NN := fLinhaDig(aDadosBanco[1]      ,; // Numero do Banco
			__cMoeda            ,; // Codigo da Moeda
			aDadosBanco[6]      ,; // Codigo da Carteira
			aDadosBanco[3]      ,; // Codigo da Agencia
			aDadosBanco[4]      ,; // Codigo da Conta
			aDadosBanco[5]      ,; // DV da Conta
			(E1_VALOR-nVlrAbat) ,; // Valor do Titulo
			E1_VENCTO           ,; // Data de Vencimento do Titulo
			cNroDoc              ) // Numero do Documento no Contas a Receber
			
			
			aDadosTit	:= {AllTrim(E1_NUM)+AllTrim(E1_PARCELA)	,;  // [1] Número do título
			E1_EMISSAO                          ,;  // [2] Data da emissão do título
			dDataBase                    		,;  // [3] Data da emissão do boleto
			E1_VENCTO                           ,;  // [4] Data do vencimento
			(E1_SALDO - nVlrAbat)               ,;  // [5] Valor do título
			aCB_RN_NN[3]                        ,;  // [6] Nosso número (Ver fórmula para calculo)
			E1_PREFIXO                          ,;  // [7] Prefixo da NF
			E1_TIPO	                           	}   // [8] Tipo do Titulo
			
			Impress(oPrint,aDadosEmp,aDadosTit,aDadosBanco,aDatSacado,aBolText,aCB_RN_NN)
			nX := nX + 1
		endif
	ELSE         

		// POSICIONA NOS TITULOS DO SE1
		
		cPORTADO := "341"
		cAGEDEP  := "0190 "
		cCONTA	 := "65267     "
	
		//Posiciona o SA6 (Bancos)
		DbSelectArea("SA6")
		DbSetOrder(1)
		DbSeek(xFilial("SA6")+cPORTADO+cAGEDEP+cCONTA)
			
			
		//Posiciona na Arq de Parametros CNAB
		DbSelectArea("SEE")
		DbSetOrder(1)
		DbSeek(xFilial("SEE")+cPORTADO+cAGEDEP+cCONTA)
		/*
		//inserido por raul em 28/08/12
		//posiciona no pedido
		DbSelectArea("SC5")
		DbSetOrder(1)
		DbSeek(xFilial("SC5")+SE1->E1_PEDIDO,.T.)
		
		If !empty(SC5->C5_CLIENTC+SC5->C5_LOJACOB).and.(SC5->C5_FILIAL+SC5->C5_NUM==SE1->E1_FILIAL+SE1->E1_PEDIDO)
		DbSelectArea("SA1")
		DbSetOrder(1)
		DbSeek(xFilial()+SC5->C5_CLIENTC+SC5->C5_LOJACOB,.T.)
		Else
		*/
		//Posiciona o SA1 (Cliente)
		DbSelectArea("SA1")
		DbSetOrder(1)
		DbSeek(xFilial()+SE1->E1_CLIENTE+SE1->E1_LOJA,.T.)
		//Endif
		
		// Luiz Alberto - 06-02-2012 - Athena
		// Efetua o Preenchimento do Campo E1_NUMBCO com
		// o Numero Sequencial da Tabela EE_FAXATU.
		
		DbSelectArea("SE1")
		
		If Empty(SE1->E1_NUMBCO)
			
			NossoNum()
			
		Endif
		
		//DbSelectArea("SE1")
		//RecLock("SE1",.F.)
		//SE1->E1_NUMBCO 	:=	NossoNum() //aCB_RN_NN[3]   // Nosso número (Ver fórmula para calculo)
		//MsUnlock()
		
	
		//aAdd(aDadosBanco, Alltrim(SA6->A6_COD))             // [1]Numero do Banco
		aAdd(aDadosBanco, Alltrim(SEE->EE_CODIGO))            // [1]Numero do Banco
		aAdd(aDadosBanco, Alltrim(SA6->A6_NOME))              // [2]Nome do Banco
		//aAdd(aDadosBanco, Left(Alltrim(SA6->A6_AGENCIA),4)) // [3]Agência
		aAdd(aDadosBanco, Left(Alltrim(SEE->EE_AGENCIA),4))   // [3]Agência
		aAdd(aDadosBanco, Left(Alltrim(SEE->EE_CONTA),5))     // [4]Conta Corrente
		//aAdd(aDadosBanco, Alltrim(SA6->A6_NUMCON))          // [4]Conta Corrente
		//aAdd(aDadosBanco, Right(Alltrim(SA6->A6_DVCTA),1))  // [5]Dígito da conta corrente
		aAdd(aDadosBanco, Right(Alltrim(SEE->EE_DVCTA),1))    // [5]Dígito da conta corrente
		aAdd(aDadosBanco, Alltrim(__cCarteira))               // [6]Codigo da Carteira
		
		If Empty(SA1->A1_ENDCOB)
			aDatSacado   := {AllTrim(SA1->A1_NOME)           ,;      	// [1]Razão Social
			AllTrim(SA1->A1_COD )+"-"+SA1->A1_LOJA           ,;      	// [2]Código
			AllTrim(SA1->A1_END )+"-"+AllTrim(SA1->A1_BAIRRO),;      	// [3]Endereço
			AllTrim(SA1->A1_MUN )                            ,;  		// [4]Cidade
			SA1->A1_EST                                      ,;     	// [5]Estado
			SA1->A1_CEP                                      ,;      	// [6]CEP
			SA1->A1_CGC										 ,;         // [7]CGC
			SA1->A1_PESSOA									  }         // [8]PESSOA
		Else
			aDatSacado   := {AllTrim(SA1->A1_NOME)            	,;   	// [1]Razão Social
			AllTrim(SA1->A1_COD )+"-"+SA1->A1_LOJA              ,;   	// [2]Código
			AllTrim(SA1->A1_ENDCOB)+"-"+AllTrim(SA1->A1_BAIRROC),;   	// [3]Endereço
			AllTrim(SA1->A1_MUNC)	                            ,;   	// [4]Cidade
			SA1->A1_ESTC	                                    ,;   	// [5]Estado
			SA1->A1_CEPC                                        ,;   	// [6]CEP
			SA1->A1_CGC											,;		// [7]CGC
			SA1->A1_PESSOA										 }		// [8]PESSOA
		Endif
		
		nVlrAbat   :=  SomaAbat(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,"R",1,,SE1->E1_CLIENTE,SE1->E1_LOJA)
		/*
		--------------------------------------------------------------
		Parte do Nosso Numero. Sao 8 digitos para identificar o titulo
		--------------------------------------------------------------
		*/
		cNroDoc	:= StrZero(	Val(Alltrim(SE1->E1_NUM)+Alltrim(SE1->E1_PARCELA)),8)
		/*
		----------------------
		Monta codigo de barras
		----------------------
		*/
		//DbSelectArea("SE1")
		aCB_RN_NN := fLinhaDig(aDadosBanco[1]      ,; // Numero do Banco
		__cMoeda            ,; // Codigo da Moeda
		aDadosBanco[6]      ,; // Codigo da Carteira
		aDadosBanco[3]      ,; // Codigo da Agencia
		aDadosBanco[4]      ,; // Codigo da Conta
		aDadosBanco[5]      ,; // DV da Conta
		(E1_VALOR-nVlrAbat) ,; // Valor do Titulo
		E1_VENCTO           ,; // Data de Vencimento do Titulo
		cNroDoc              ) // Numero do Documento no Contas a Receber
		
		
		aDadosTit	:= {AllTrim(E1_NUM)+AllTrim(E1_PARCELA)	,;  // [1] Número do título
		E1_EMISSAO                          ,;  // [2] Data da emissão do título
		dDataBase                    		,;  // [3] Data da emissão do boleto
		E1_VENCTO                           ,;  // [4] Data do vencimento
		(E1_SALDO - nVlrAbat)               ,;  // [5] Valor do título
		aCB_RN_NN[3]                        ,;  // [6] Nosso número (Ver fórmula para calculo)
		E1_PREFIXO                          ,;  // [7] Prefixo da NF
		E1_TIPO	                           	}   // [8] Tipo do Titulo
		
		Impress(oPrint,aDadosEmp,aDadosTit,aDadosBanco,aDatSacado,aBolText,aCB_RN_NN)
		nX := nX + 1
		
		
	EndIf
	
	
	DbSkip()
	IncProc()
	nI++
EndDo
//oPrint:EndPage()     // Finaliza a página
//oPrint:Preview()     // Visualiza antes de imprimir
oPrint:Print()  
//cJPEG := Iif(Empty(AllTrim(SE1->E1_NUM)),CriaTrab(,.f.),AllTrim(SE1->E1_NUM))
//oPrint:SaveAllAsJPEG(cStartPath+cJPEG,1000,1400,140)
Return Nil


/*
+-----------+----------+-------+--------------------+------+-------------+
| Programa  |Impress   |Autor  |Microsiga           | Data |  21/11/05   |
+-----------+----------+-------+--------------------+------+-------------+
| Desc.     |Impressao dos dados do boleto em modo grafico               |
|           |                                                            |
+-----------+------------------------------------------------------------+
| Uso       | AP                                                         |
+-----------+------------------------------------------------------------+
*/
Static Function Impress(oPrint,aDadosEmp,aDadosTit,aDadosBanco,aDatSacado,aBolText,aCB_RN_NN)
Local oFont8
Local oFont11c
Local oFont10
Local oFont14
Local oFont16n
Local oFont15
Local oFont14n
Local oFont24
Local nI := 0
Local cStartPath := GetSrvProfString("StartPath","")
Local cBmp := 030

cBmp := cStartPath + "ITAU.jpg" //Logo do Banco Itau


//Parametros de TFont.New()
//1.Nome da Fonte (Windows)
//3.Tamanho em Pixels
//5.Bold (T/F)
oFont8   := TFont():New("Arial",9,8,.T.,.F.,5,.T.,5,.T.,.F.)
oFont11c := TFont():New("Courier New",9,11,.T.,.T.,5,.T.,5,.T.,.F.)
oFont11  := TFont():New("Arial",9,11,.T.,.T.,5,.T.,5,.T.,.F.)
oFont9  := TFont():New("Arial",9,8,.T.,.T.,5,.T.,5,.T.,.F.)
oFont10  := TFont():New("Arial",9,10,.T.,.T.,5,.T.,5,.T.,.F.)
oFont14  := TFont():New("Arial",9,14,.T.,.T.,5,.T.,5,.T.,.F.)
oFont20  := TFont():New("Arial",9,20,.T.,.T.,5,.T.,5,.T.,.F.)
oFont21  := TFont():New("Arial",9,21,.T.,.T.,5,.T.,5,.T.,.F.)
oFont16n := TFont():New("Arial",9,16,.T.,.F.,5,.T.,5,.T.,.F.)
oFont15  := TFont():New("Arial",9,15,.T.,.T.,5,.T.,5,.T.,.F.)
oFont15n := TFont():New("Arial",9,14,.T.,.F.,5,.T.,5,.T.,.F.)
oFont14n := TFont():New("Arial",9,14,.T.,.F.,5,.T.,5,.T.,.F.)
oFont24  := TFont():New("Arial",9,24,.T.,.T.,5,.T.,5,.T.,.F.)

oPrint:StartPage()   // Inicia uma nova página

/******************/
/* PRIMEIRA PARTE */
/******************/

nRow1 := 0

oPrint:Line (nRow1+0150,500,nRow1+0070, 500)
oPrint:Line (nRow1+0150,710,nRow1+0070, 710)

If File(cBmp)
	oPrint:SayBitmap(nRow1+0080,100,cBmp,215,65)
Endif

//oPrint:Say  (nRow1+0084,100,aDadosBanco[2],oFont11 )	        // [2]Nome do Banco
oPrint:Say  (nRow1+0075,513,aDadosBanco[1]+"-7",oFont21 )		// [1]Numero do Banco

oPrint:Say  (nRow1+0084,1900,"Comprovante de Entrega",oFont10)
oPrint:Line (nRow1+0150,100,nRow1+0150,2300)

oPrint:Say  (nRow1+0150,100 ,"Beneficiário",oFont8)
oPrint:Say  (nRow1+0200,100 ,aDadosEmp[1],oFont10)				//Nome + CNPJ

oPrint:Say  (nRow1+0150,1060,"Agência/Código Beneficiário",oFont8)
oPrint:Say  (nRow1+0200,1060,aDadosBanco[3]+"/"+aDadosBanco[4]+"-"+aDadosBanco[5],oFont10)
//oPrint:Say  (nRow1+0200,1060,aDadosBanco[3]+"/"+aDadosBanco[4],oFont10) //+"-"+aDadosBanco[5]

oPrint:Say  (nRow1+0150,1510,"Nro.Documento",oFont8)
oPrint:Say  (nRow1+0200,1510,aDadosTit[7]+aDadosTit[1],oFont10) //Prefixo +Numero+Parcela

oPrint:Say  (nRow1+0250,100 ,"Pagador",oFont8)
oPrint:Say  (nRow1+0300,100 ,aDatSacado[1],oFont9)				//Nome

oPrint:Say  (nRow1+0250,1060,"Vencimento",oFont8)
oPrint:Say  (nRow1+0300,1080,StrZero(Day(aDadosTit[4]),2) +"/"+ StrZero(Month(aDadosTit[4]),2) +"/"+ Right(Str(Year(aDadosTit[4])),4),oFont10)

oPrint:Say  (nRow1+0250,1510,"Valor do Documento",oFont8)
oPrint:Say  (nRow1+0300,1550,AllTrim(Transform(aDadosTit[5],"@E 999,999,999.99")),oFont10)

oPrint:Say  (nRow1+0400,0100,"Recebi(emos) o bloqueto/título",oFont10)
oPrint:Say  (nRow1+0450,0100,"com as características acima.",oFont10)
oPrint:Say  (nRow1+0350,1060,"Data",oFont8)
oPrint:Say  (nRow1+0350,1410,"Assinatura",oFont8)
oPrint:Say  (nRow1+0450,1060,"Data",oFont8)
oPrint:Say  (nRow1+0450,1410,"Entregador",oFont8)

oPrint:Line (nRow1+0250, 100,nRow1+0250,1900 )
oPrint:Line (nRow1+0350, 100,nRow1+0350,1900 )
oPrint:Line (nRow1+0450,1050,nRow1+0450,1900 ) //---
oPrint:Line (nRow1+0550, 100,nRow1+0550,2300 )

oPrint:Line (nRow1+0550,1050,nRow1+0150,1050 )
oPrint:Line (nRow1+0550,1400,nRow1+0350,1400 )
oPrint:Line (nRow1+0350,1500,nRow1+0150,1500 ) //--
oPrint:Line (nRow1+0550,1900,nRow1+0150,1900 )

oPrint:Say  (nRow1+0165,1910,"(  )Mudou-se"                                	,oFont8)
oPrint:Say  (nRow1+0205,1910,"(  )Ausente"                                    ,oFont8)
oPrint:Say  (nRow1+0245,1910,"(  )Não existe nº indicado"                  	,oFont8)
oPrint:Say  (nRow1+0285,1910,"(  )Recusado"                                	,oFont8)
oPrint:Say  (nRow1+0325,1910,"(  )Não procurado"                              ,oFont8)
oPrint:Say  (nRow1+0365,1910,"(  )Endereço insuficiente"                  	,oFont8)
oPrint:Say  (nRow1+0405,1910,"(  )Desconhecido"                            	,oFont8)
oPrint:Say  (nRow1+0445,1910,"(  )Falecido"                                   ,oFont8)
oPrint:Say  (nRow1+0485,1910,"(  )Outros(anotar no verso)"                  	,oFont8)

/*****************/
/* SEGUNDA PARTE */
/*****************/

nRow2   := 0

//Pontilhado separador
/*
For nI := 100 to 2300 step 50
oPrint:Line(nRow2+0580, nI,nRow2+0580, nI+30)
Next nI
*/


oPrint:Line (nRow2+0710,100,nRow2+0710,2300)
oPrint:Line (nRow2+0710,500,nRow2+0630, 500)
oPrint:Line (nRow2+0710,710,nRow2+0630, 710)

If File(cBmp)
	oPrint:SayBitmap(nRow2+0644,100,cBmp,215,65)
Endif

//oPrint:Say  (nRow2+0644,100,aDadosBanco[2],oFont14 )		// [2]Nome do Banco
oPrint:Say  (nRow2+0635,513,aDadosBanco[1]+"-7",oFont21 )	// [1]Numero do Banco
oPrint:Say  (nRow2+0644,1800,"Recibo do Pagador",oFont10)

oPrint:Line (nRow2+0810,100,nRow2+0810,2300 )
oPrint:Line (nRow2+0910,100,nRow2+0910,2300 )
oPrint:Line (nRow2+0980,100,nRow2+0980,2300 )
oPrint:Line (nRow2+1050,100,nRow2+1050,2300 )

oPrint:Line (nRow2+0910,500,nRow2+1050,500)
oPrint:Line (nRow2+0980,750,nRow2+1050,750)
oPrint:Line (nRow2+0910,1000,nRow2+1050,1000)
oPrint:Line (nRow2+0910,1300,nRow2+0980,1300)
oPrint:Line (nRow2+0910,1480,nRow2+1050,1480)

oPrint:Say  (nRow2+0710,100 ,"Local de Pagamento",oFont8)
oPrint:Say  (nRow2+0725,400 ,"ATE O VENCIMENTO PAGUE PREFERENCIALMENTE NO ITAU",oFont10)
oPrint:Say  (nRow2+0765,400 ,"APOS O VENCIMENTO PAGUE SOMENTE NO ITAU",oFont10)

oPrint:Say  (nRow2+0710,1810,"Vencimento"                                     ,oFont8)
cString	:= StrZero(Day(aDadosTit[4]),2) +"/"+ StrZero(Month(aDadosTit[4]),2) +"/"+ Right(Str(Year(aDadosTit[4])),4)
nCol := 1810+(374-(len(cString)*22))
oPrint:Say  (nRow2+0750,nCol,cString,oFont11c)

oPrint:Say  (nRow2+0810,100 ,"Beneficiário"                                        ,oFont8)
oPrint:Say  (nRow2+0850,100 ,aDadosEmp[1]+"                  - "+aDadosEmp[6]	,oFont10) //Nome + CNPJ

oPrint:Say  (nRow2+0810,1810,"Agência/Código Beneficiário",oFont8)
cString := Alltrim(aDadosBanco[3]+"/"+aDadosBanco[4]+"-"+aDadosBanco[5])
//cString := Alltrim(aDadosBanco[3]+"/"+aDadosBanco[4]) //+"-"+aDadosBanco[5]
nCol := 1810+(374-(len(cString)*22))
oPrint:Say  (nRow2+0850,nCol,cString,oFont11c)

oPrint:Say  (nRow2+0910,100 ,"Data do Documento"                              ,oFont8)
oPrint:Say  (nRow2+0940,100, StrZero(Day(dDataBase),2) +"/"+ StrZero(Month(dDataBase),2) +"/"+ Right(Str(Year(dDataBase)),4),oFont10)
//oPrint:Say  (nRow2+0940,100, StrZero(Day(aDadosTit[2]),2) +"/"+ StrZero(Month(aDadosTit[2]),2) +"/"+ Right(Str(Year(aDadosTit[2])),4),oFont10)

oPrint:Say  (nRow2+0910,505 ,"Nro.Documento"                                  ,oFont8)
oPrint:Say  (nRow2+0940,605 ,aDadosTit[7]+aDadosTit[1]						,oFont10) //Prefixo +Numero+Parcela

oPrint:Say  (nRow2+0910,1005,"Espécie Doc."                                   ,oFont8)
oPrint:Say  (nRow2+0940,1050,aDadosTit[8]										,oFont10) //Tipo do Titulo

oPrint:Say  (nRow2+0910,1305,"Aceite"                                         ,oFont8)
oPrint:Say  (nRow2+0940,1400,"N"                                             ,oFont10)

oPrint:Say  (nRow2+0910,1485,"Data do Processamento"                          ,oFont8)
oPrint:Say  (nRow2+0940,1550,StrZero(Day(aDadosTit[3]),2) +"/"+ StrZero(Month(aDadosTit[3]),2) +"/"+ Right(Str(Year(aDadosTit[3])),4),oFont10) // Data impressao


//alert(Alltrim(SEE->EE_AGENCIA)+Alltrim(SEE->EE_CONTA)+__cCarteira+Right(AllTrim(SE1->E1_NUMBCO),8))
//alert(modulo10(Alltrim(SEE->EE_AGENCIA)+Alltrim(SEE->EE_CONTA)+__cCarteira+Right(AllTrim(SE1->E1_NUMBCO),8)))

oPrint:Say  (nRow2+0910,1810,"Nosso Número"                                   ,oFont8)
cString :=  Alltrim(Substr(aDadosTit[6],1,3)+"/"+ Right(AllTrim(SE1->E1_NUMBCO),8))+"-"+ Str(modulo10(Alltrim(SEE->EE_AGENCIA)+Alltrim(SEE->EE_CONTA)+__cCarteira+Right(AllTrim(SE1->E1_NUMBCO),8)),1)// nosso numero com DV
nCol 	:=  1810+(374-(len(cString)*22))
oPrint:Say  (nRow2+0940,nCol,cString,oFont11c)

oPrint:Say  (nRow2+0980,100 ,"Uso do Banco"                                   ,oFont8)

oPrint:Say  (nRow2+0980,505 ,"Carteira"                                       ,oFont8)
oPrint:Say  (nRow2+1010,555 ,aDadosBanco[6]                                   ,oFont10)

oPrint:Say  (nRow2+0980,755 ,"Espécie"                                        ,oFont8)
oPrint:Say  (nRow2+1010,805 ,"R$"                                             ,oFont10)

oPrint:Say  (nRow2+0980,1005,"Quantidade"                                     ,oFont8)
oPrint:Say  (nRow2+0980,1485,"Valor"                                          ,oFont8)

oPrint:Say  (nRow2+0980,1810,"Valor do Documento"                          	,oFont8)
cString := Alltrim(Transform(aDadosTit[5],"@E 99,999,999.99"))
nCol := 1830+(374-(len(cString)*22))   // nCol := 1810+(374-(len(cString)*22))
oPrint:Say  (nRow2+1010,nCol,cString ,oFont11c)  // alinhando com nosso numero - susgetao do banco Itau.

oPrint:Say  (nRow2+1050,100 ,"Instruções de responsabilidade do BENEFICIÁRIO. Qualquer dúvida sobre esse boleto, contate o BENEFICIÁRIO.",oFont8)
//oPrint:Say  (nRow2+1150,100 ,aBolText[1]+" "+AllTrim(Transform((aDadosTit[5]*0.02),"@E 99,999.99"))       ,oFont10)
oPrint:Say  (nRow2+1150,100 ,aBolText[1]+" "+AllTrim(Transform(((aDadosTit[5]*(10/30))/100),"@E 99,999.99"))+" AO DIA"  ,oFont10)
oPrint:Say  (nRow2+1200,100 ,aBolText[2]   ,oFont10)
//oPrint:Say  (nRow2+1250,100 ,aBolText[3]                                        ,oFont10)

oPrint:Say  (nRow2+1050,1810,"(-)Desconto/Abatimento"                         ,oFont8)
oPrint:Say  (nRow2+1120,1810,"(-)Outras Deduções"                             ,oFont8)
oPrint:Say  (nRow2+1190,1810,"(+)Mora/Multa"                                  ,oFont8)
oPrint:Say  (nRow2+1260,1810,"(+)Outros Acréscimos"                           ,oFont8)
oPrint:Say  (nRow2+1330,1810,"(=)Valor Cobrado"                               ,oFont8)

//Temp
oPrint:Say  (nRow2+1350,100,"APOS VCTO ACESSE WWW.ITAU.COM.BR/BOLETOS PARA ATUALIZAR SEU BOLETO"                               ,oFont10)


oPrint:Say  (nRow2+1400,100 ,"Pagador"                                         ,oFont8)
oPrint:Say  (nRow2+1430,400 ,aDatSacado[1]+" ("+aDatSacado[2]+")"             ,oFont10)
oPrint:Say  (nRow2+1483,400 ,aDatSacado[3]                                    ,oFont10)
oPrint:Say  (nRow2+1536,400 ,aDatSacado[6]+"    "+aDatSacado[4]+" - "+aDatSacado[5],oFont10) // CEP+Cidade+Estado

if aDatSacado[8] = "J"
	oPrint:Say  (nRow2+1589,400 ,"CNPJ: "+TRANSFORM(aDatSacado[7],"@R 99.999.999/9999-99"),oFont10) // CGC
Else
	oPrint:Say  (nRow2+1589,400 ,"CPF: "+TRANSFORM(aDatSacado[7],"@R 999.999.999-99"),oFont10) 	// CPF
EndIf

//oPrint:Say  (nRow2+1589,1850,Substr(aDadosTit[6],1,3)+Substr(aDadosTit[6],4)  ,oFont10)

oPrint:Say  (nRow2+1605,100 ,"Pagador/Avalista",oFont8)
oPrint:Say  (nRow2+1645,1500,"Autenticação Mecânica",oFont8)

oPrint:Line (nRow2+0710,1800,nRow2+1400,1800 )
oPrint:Line (nRow2+1120,1800,nRow2+1120,2300 )
oPrint:Line (nRow2+1190,1800,nRow2+1190,2300 )
oPrint:Line (nRow2+1260,1800,nRow2+1260,2300 )
oPrint:Line (nRow2+1330,1800,nRow2+1330,2300 )
oPrint:Line (nRow2+1400,100 ,nRow2+1400,2300 )
oPrint:Line (nRow2+1640,100 ,nRow2+1640,2300 )

/******************/
/* TERCEIRA PARTE */
/******************/

nRow3 := 0

For nI := 100 to 2300 step 50
	oPrint:Line(nRow3+1880, nI, nRow3+1880, nI+30)
Next nI

oPrint:Line (nRow3+2000,100,nRow3+2000,2300)
oPrint:Line (nRow3+2000,500,nRow3+1920, 500)
oPrint:Line (nRow3+2000,710,nRow3+1920, 710)

// Nao é obrigatorio a logo marca na ficha de compensacao somente o nome do banco.
//If File(cBmp)
//   oPrint:SayBitmap(nRow3+1934,100,cBmp,215,65)
//Endif

oPrint:Say  (nRow3+1934,100,"Banco Itaú S.A.",oFont14 )		// 	[2]Nome do Banco
//oPrint:Say  (nRow3+1934,100,aDadosBanco[2],oFont14 )		// 	[2]Nome do Banco
oPrint:Say  (nRow3+1925,513,aDadosBanco[1]+"-7",oFont21 )	// 	[1]Numero do Banco
oPrint:Say  (nRow3+1934,755,aCB_RN_NN[2],oFont15n)			//	Linha Digitavel do Codigo de Barras

oPrint:Line (nRow3+2100,100,nRow3+2100,2300 )
oPrint:Line (nRow3+2200,100,nRow3+2200,2300 )
oPrint:Line (nRow3+2270,100,nRow3+2270,2300 )
oPrint:Line (nRow3+2340,100,nRow3+2340,2300 )

oPrint:Line (nRow3+2200,500 ,nRow3+2340,500 )
oPrint:Line (nRow3+2270,750 ,nRow3+2340,750 )
oPrint:Line (nRow3+2200,1000,nRow3+2340,1000)
oPrint:Line (nRow3+2200,1300,nRow3+2270,1300)
oPrint:Line (nRow3+2200,1480,nRow3+2340,1480)

oPrint:Say  (nRow3+2000,100 ,"Local de Pagamento",oFont8)
oPrint:Say  (nRow3+2015,400 ,"ATE O VENCIMENTO PAGUE PREFERENCIALMENTE NO ITAU",oFont10)
oPrint:Say  (nRow3+2055,400 ,"APOS O VENCIMENTO PAGUE SOMENTE NO ITAU",oFont10)

oPrint:Say  (nRow3+2000,1810,"Vencimento",oFont8)
cString := StrZero(Day(aDadosTit[4]),2) +"/"+ StrZero(Month(aDadosTit[4]),2) +"/"+ Right(Str(Year(aDadosTit[4])),4)
nCol	 	 := 1810+(374-(len(cString)*22))
oPrint:Say  (nRow3+2040,nCol,cString,oFont11c)

oPrint:Say  (nRow3+2100,100 ,"Beneficiário",oFont8)
oPrint:Say  (nRow3+2140,100 ,aDadosEmp[1]+"                  - "+aDadosEmp[6]	,oFont10) //Nome + CNPJ

oPrint:Say  (nRow3+2100,1810,"Agência/Código Beneficiário",oFont8)
cString := Alltrim(aDadosBanco[3]+"/"+aDadosBanco[4]+"-"+aDadosBanco[5])
//cString := Alltrim(aDadosBanco[3]+"/"+aDadosBanco[4]) //+"-"+aDadosBanco[5]
nCol 	 := 1810+(374-(len(cString)*22))
oPrint:Say  (nRow3+2140,nCol,cString ,oFont11c)

oPrint:Say (nRow3+2200,100 ,"Data do Documento"                             ,oFont8)
oPrint:Say (nRow3+2230,100, StrZero(Day(dDataBase),2) +"/"+ StrZero(Month(dDataBase),2) +"/"+ Right(Str(Year(dDataBase)),4), oFont10)

oPrint:Say (nRow3+2200,505 ,"Nro.Documento"                                 ,oFont8)
oPrint:Say (nRow3+2230,605 ,aDadosTit[7]+aDadosTit[1]						,oFont10) //Prefixo +Numero+Parcela

oPrint:Say (nRow3+2200,1005,"Espécie Doc."                                  ,oFont8)
oPrint:Say (nRow3+2230,1050,aDadosTit[8]									,oFont10) //Tipo do Titulo

oPrint:Say (nRow3+2200,1305,"Aceite"                                        ,oFont8)
oPrint:Say (nRow3+2230,1400,"N"                                             ,oFont10)

oPrint:Say  (nRow3+2200,1485,"Data do Processamento"                        ,oFont8)
oPrint:Say  (nRow3+2230,1550,StrZero(Day(aDadosTit[3]),2) +"/"+ StrZero(Month(aDadosTit[3]),2) +"/"+ Right(Str(Year(aDadosTit[3])),4)                               ,oFont10) // Data impressao


oPrint:Say  (nRow3+2200,1810,"Nosso Número"                                 ,oFont8)
cString :=  Alltrim(Substr(aDadosTit[6],1,3)+"/"+ Right(AllTrim(SE1->E1_NUMBCO),8))+"-"+ Str(modulo10(Alltrim(SEE->EE_AGENCIA)+Alltrim(SEE->EE_CONTA)+__cCarteira+Right(AllTrim(SE1->E1_NUMBCO),8)),1)// nosso numero com DV
//cString := Alltrim(Substr(aDadosTit[6],1,3)+"/"+ Right(AllTrim(SE1->E1_NUMBCO),8))+"-"+ Right(Substr(aDadosTit[6],4),1)
nCol := 1810+(374-(len(cString)*22))
oPrint:Say  (nRow3+2230,nCol,cString,oFont11c)


oPrint:Say  (nRow3+2270,100 ,"Uso do Banco"                                 ,oFont8)

oPrint:Say  (nRow3+2270,505 ,"Carteira"                                     ,oFont8)
oPrint:Say  (nRow3+2300,555 ,aDadosBanco[6]                                 ,oFont10)

oPrint:Say  (nRow3+2270,755 ,"Espécie"                                      ,oFont8)
oPrint:Say  (nRow3+2300,805 ,"R$"                                           ,oFont10)

oPrint:Say  (nRow3+2270,1005,"Quantidade"                                   ,oFont8)
oPrint:Say  (nRow3+2270,1485,"Valor"                                        ,oFont8)

oPrint:Say  (nRow3+2270,1810,"Valor do Documento"                          	,oFont8)
cString := Alltrim(Transform(aDadosTit[5],"@E 99,999,999.99"))
nCol 	 := 1830+(374-(len(cString)*22))    // alinhamento com nosso numero - susgestao do banco Itau.
oPrint:Say  (nRow3+2300,nCol,cString,oFont11c)

oPrint:Say  (nRow3+2340,100 ,"Instruções de responsabilidade do BENEFICIÁRIO. Qualquer dúvida sobre esse boleto, contate o BENEFICIÁRIO.",oFont8)
//oPrint:Say  (nRow3+2440,100 ,aBolText[1]+" "+AllTrim(Transform((aDadosTit[5]*0.02),"@E 99,999.99"))      ,oFont10)
//oPrint:Say  (nRow3+2490,100 ,aBolText[2]+" "+AllTrim(Transform(((aDadosTit[5]*0.01)/30),"@E 99,999.99"))  ,oFont10)
//oPrint:Say  (nRow3+2540,100 ,aBolText[3]                                    ,oFont10)
oPrint:Say  (nRow3+2440,100 ,aBolText[1]+" "+AllTrim(Transform(((aDadosTit[5]*(10/30))/100),"@E 99,999.99"))+" AO DIA"  ,oFont10)
oPrint:Say  (nRow3+2490,100 ,aBolText[2]   ,oFont10)

oPrint:Say  (nRow3+2340,1810,"(-)Desconto/Abatimento"                       ,oFont8)
oPrint:Say  (nRow3+2410,1810,"(-)Outras Deduções"                           ,oFont8)
oPrint:Say  (nRow3+2480,1810,"(+)Mora/Multa"                                ,oFont8)
oPrint:Say  (nRow3+2550,1810,"(+)Outros Acréscimos"                         ,oFont8)
oPrint:Say  (nRow3+2620,1810,"(=)Valor Cobrado"                             ,oFont8)

// TEMP
oPrint:Say  (nRow2+2640,100,"APOS VCTO ACESSE WWW.ITAU.COM.BR/BOLETOS PARA ATUALIZAR SEU BOLETO"                               ,oFont10)

oPrint:Say  (nRow3+2690,100 ,"Pagador"                                       ,oFont8)
oPrint:Say  (nRow3+2700,400 ,aDatSacado[1]+" ("+aDatSacado[2]+")"           ,oFont10)

if aDatSacado[8] = "J"
	oPrint:Say  (nRow3+2700,1750,"CNPJ: "+TRANSFORM(aDatSacado[7],"@R 99.999.999/9999-99"),oFont10) // CGC
Else
	oPrint:Say  (nRow3+2700,1750,"CPF: "+TRANSFORM(aDatSacado[7],"@R 999.999.999-99"),oFont10) 	// CPF
EndIf

oPrint:Say  (nRow3+2753,400 ,aDatSacado[3]                                  ,oFont10)
oPrint:Say  (nRow3+2806,400 ,aDatSacado[6]+"    "+aDatSacado[4]+" - "+aDatSacado[5],oFont10) // CEP+Cidade+Estado
//oPrint:Say  (nRow3+2806,1750,Substr(aDadosTit[6],1,3)+Substr(aDadosTit[6],4)  ,oFont10)

oPrint:Say  (nRow3+2815,100 ,"Pagador/Avalista"                             ,oFont8)
oPrint:Say  (nRow3+2855,1500,"Autenticação Mecânica - Ficha de Compensação" ,oFont8)

oPrint:Line (nRow3+2000,1800,nRow3+2690,1800 )
oPrint:Line (nRow3+2410,1800,nRow3+2410,2300 )
oPrint:Line (nRow3+2480,1800,nRow3+2480,2300 )
oPrint:Line (nRow3+2550,1800,nRow3+2550,2300 )
oPrint:Line (nRow3+2620,1800,nRow3+2620,2300 )
oPrint:Line (nRow3+2690,100 ,nRow3+2690,2300 )

oPrint:Line (nRow3+2850,100,nRow3+2850,2300  )

//MSBAR("INT25",25.5,1,aCB_RN_NN[1],oPrint,.F.,Nil,Nil,0.025,1.5,Nil,Nil,"A",.F.) //modali
MSBAR("INT25",24.5,1,aCB_RN_NN[1],oPrint,.F.,Nil,Nil,0.022,1.5,Nil,Nil,"A",.F.) //datasupri


//DbSelectArea("SE1")
//RecLock("SE1",.f.)
//SE1->E1_NUMBCO 	:=	aCB_RN_NN[3]   // Nosso número (Ver fórmula para calculo)
//MsUnlock()

oPrint:EndPage() // Finaliza a página
Return Nil

/*
+-----------+----------+-------+--------------------+------+-------------+
| Programa  |BOLITAU   |Autor  |Microsiga           | Data |  11/21/05   |
+-----------+----------+-------+--------------------+------+-------------+
| Desc.     |Obtenção da linha digitavel/codigo de barras                |
|           |                                                            |
+-----------+------------------------------------------------------------+
| Uso       | AP                                                         |
+-----------+------------------------------------------------------------+
*/
Static Function fLinhaDig (cCodBanco, ; // Codigo do Banco (341)
cCodMoeda, ; // Codigo da Moeda (9)
cCarteira, ; // Codigo da Carteira
cAgencia , ; // Codigo da Agencia
cConta   , ; // Codigo da Conta
cDvConta , ; // Digito verificador da Conta
nValor   , ; // Valor do Titulo
dVencto  , ; // Data de vencimento do titulo
cNroDoc   )  // Numero do Documento Ref ao Contas a Receber

Local cValorFinal   := StrZero(int(nValor*100),10)
Local cFator        := StrZero(dVencto - CtoD("07/10/97"),4)   // Local cFator        := StrZero(dVencto - CtoD("07/10/97"),4)
Local cCodBar   	:= Replicate("0",43)
Local cCampo1   	:= Replicate("0",05)+"."+Replicate("0",05)
Local cCampo2   	:= Replicate("0",05)+"."+Replicate("0",06)
Local cCampo3   	:= Replicate("0",05)+"."+Replicate("0",06)
Local cCampo4   	:= Replicate("0",01)
Local cCampo5   	:= Replicate("0",14)
Local cTemp     	:= ""
Local cNossoNum 	:= Right(AllTrim(SE1->E1_NUMBCO),8) // Nosso numero
Local cDV			:= "" // Digito verificador dos campos
Local cLinDig		:= ""
/*
-------------------------
Definicao do NOSSO NUMERO
-------------------------
*/
If At("-",cConta) > 0
	cDig   := Right(AllTrim(cConta),1)
	cConta := AllTrim(Str(Val(Left(cConta,At('-',cConta)-1) + cDig)))
Else
	cConta := AllTrim(Str(Val(cConta)))
Endif
cNossoNum   := Alltrim(cAgencia) + Left(Alltrim(cConta),5) + Right(alltrim(cConta),1) + cCarteira + Right(AllTrim(SE1->E1_NUMBCO),8) //cNroDoc
cDvNN 		:= Str(modulo10(Alltrim(SEE->EE_AGENCIA)+Alltrim(SEE->EE_CONTA)+__cCarteira+Right(AllTrim(SE1->E1_NUMBCO),8)),1)  //Alltrim(Str(Modulo10(cNossoNum)))
cNossoNum   := cCarteira + cNroDoc + cDvNN
//cNossoNum   := cCarteira + cNroDoc + '-' + cDvNN
/*
-----------------------------
Definicao do CODIGO DE BARRAS
-----------------------------
*/
//Alltrim(cNroDoc)              + ; // 23 a 30

cTemp := Alltrim(cCodBanco)            + ; // 01 a 03
Alltrim(cCodMoeda)            + ; // 04 a 04
Alltrim(cFator)               + ; // 06 a 09
Alltrim(cValorFinal)          + ; // 10 a 19
Alltrim(cCarteira)            + ; // 20 a 22
Right(AllTrim(SE1->E1_NUMBCO),8) +; // 23 A 30
Alltrim(cDvNN)                + ; // 31 a 31
Alltrim(cAgencia)             + ; // 32 a 35
Alltrim(Left(cConta,5))               + ; // 36 a 40
Alltrim(cDvConta)             + ; // 41 a 41
"000"                             // 42 a 44
cDvCB  := Alltrim(Str(modulo11(cTemp)))	// Digito Verificador CodBarras
cCodBar:= SubStr(cTemp,1,4) + cDvCB + SubStr(cTemp,5)// + cDvNN + SubStr(cTemp,31)

/*
-----------------------------------------------------
Definicao da LINHA DIGITAVEL (Representacao Numerica)
-----------------------------------------------------

Campo 1			Campo 2			Campo 3			Campo 4		Campo 5
AAABC.CCDDX		DDDDD.DDFFFY	FGGGG.GGHHHZ	K			UUUUVVVVVVVVVV

CAMPO 1:
AAA = Codigo do banco na Camara de Compensacao
B = Codigo da moeda, sempre 9
CCC = Codigo da Carteira de Cobranca
DD = Dois primeiros digitos no nosso numero
X = DAC que amarra o campo, calculado pelo Modulo 10 da String do campo
*/
cTemp   := cCodBanco + cCodMoeda + cCarteira + Substr(Right(AllTrim(SE1->E1_NUMBCO),8),1,2)
cDV		:= Alltrim(Str(Modulo10(cTemp)))
cCampo1 := SubStr(cTemp,1,5) + '.' + Alltrim(SubStr(cTemp,6)) + cDV + Space(2)
/*
CAMPO 2:
DDDDDD = Restante do Nosso Numero
E = DAC do campo Agencia/Conta/Carteira/Nosso Numero
FFF = Tres primeiros numeros que identificam a agencia
Y = DAC que amarra o campo, calculado pelo Modulo 10 da String do campo
*/
cTemp	:= Substr(Right(AllTrim(SE1->E1_NUMBCO),8),3) + cDvNN + Substr(cAgencia,1,3)
//cDV		:= Str(modulo10(Alltrim(SEE->EE_AGENCIA)+Alltrim(SEE->EE_CONTA)+__cCarteira+Right(AllTrim(SE1->E1_NUMBCO),8)),1)
cDV		:= Alltrim(Str(Modulo10(cTemp)))
cCampo2 := Substr(cTemp,1,5) + '.' + Substr(cTemp,6) + cDV + Space(3)
/*
CAMPO 3:
F = Restante do numero que identifica a agencia
GGGGGG = Numero da Conta + DAC da mesma
HHH = Zeros (Nao utilizado)
Z = DAC que amarra o campo, calculado pelo Modulo 10 da String do campo
*/
cTemp   := Substr(cAgencia,4,1) + Left(cConta,5) + Alltrim(cDvConta) + "000"
cDV		:= Alltrim(Str(Modulo10(cTemp)))
cCampo3 := Substr(cTemp,1,5) + '.' + Substr(cTemp,6) + cDV + Space(2)
/*
CAMPO 4:
K = DAC do Codigo de Barras
*/
cCampo4 := cDvCB + Space(2)
/*
CAMPO 5:
UUUU = Fator de Vencimento
VVVVVVVVVV = Valor do Titulo
*/
cCampo5 := cFator + StrZero(int(nValor * 100),14 - Len(cFator))
cLinDig := cCampo1 + cCampo2 + cCampo3 + cCampo4 + cCampo5
Return {cCodBar, cLinDig, cNossoNum}

/*
+-----------+----------+-------+--------------------+------+-------------+
| Programa  |AJUSTASX1 |Autor  |Microsiga           | Data |  21/11/05   |
+-----------+----------+-------+--------------------+------+-------------+
| Desc.     |Ajuste das perguntas no SX1                                 |
|           |                                                            |
+-----------+------------------------------------------------------------+
| Uso       | Financeiro Transilva LOG                                   |
+-----------+------------------------------------------------------------+
*/
Static Function AjustaSX1(cPerg, aPergs)
Local _sAlias	:= Alias()
Local aCposSX1	:= {}
Local nX 		:= 0
Local lAltera	:= .F.
Local nCondicao
Local cKey		:= ""
Local nJ			:= 0

aCposSX1:={"X1_PERGUNT","X1_PERSPA","X1_PERENG","X1_VARIAVL","X1_TIPO","X1_TAMANHO",;
"X1_DECIMAL","X1_PRESEL","X1_GSC","X1_VALID",;
"X1_VAR01","X1_DEF01","X1_DEFSPA1","X1_DEFENG1","X1_CNT01",;
"X1_VAR02","X1_DEF02","X1_DEFSPA2","X1_DEFENG2","X1_CNT02",;
"X1_VAR03","X1_DEF03","X1_DEFSPA3","X1_DEFENG3","X1_CNT03",;
"X1_VAR04","X1_DEF04","X1_DEFSPA4","X1_DEFENG4","X1_CNT04",;
"X1_VAR05","X1_DEF05","X1_DEFSPA5","X1_DEFENG5","X1_CNT05",;
"X1_F3", "X1_GRPSXG", "X1_PYME","X1_HELP" }

dbSelectArea("SX1")
dbSetOrder(1)
For nX:=1 to Len(aPergs)
	lAltera := .F.
	If MsSeek(cPerg+Right(aPergs[nX][11], 2))
		If (ValType(aPergs[nX][Len(aPergs[nx])]) = "B" .And.;
			Eval(aPergs[nX][Len(aPergs[nx])], aPergs[nX] ))
			aPergs[nX] := ASize(aPergs[nX], Len(aPergs[nX]) - 1)
			lAltera := .T.
		Endif
	Endif
	
	If ! lAltera .And. Found() .And. X1_TIPO <> aPergs[nX][5]
		lAltera := .T.		// Garanto que o tipo da pergunta esteja correto
	Endif
	
	If ! Found() .Or. lAltera
		RecLock("SX1",If(lAltera, .F., .T.))
		Replace X1_GRUPO with cPerg
		Replace X1_ORDEM with Right(aPergs[nX][11], 2)
		For nj:=1 to Len(aCposSX1)
			If 	Len(aPergs[nX]) >= nJ .And. aPergs[nX][nJ] <> Nil .And.;
				FieldPos(AllTrim(aCposSX1[nJ])) > 0
				Replace &(AllTrim(aCposSX1[nJ])) With aPergs[nx][nj]
			Endif
		Next nj
		MsUnlock()
		cKey := "P."+AllTrim(X1_GRUPO)+AllTrim(X1_ORDEM)+"."
		
		If ValType(aPergs[nx][Len(aPergs[nx])]) = "A"
			aHelpSpa := aPergs[nx][Len(aPergs[nx])]
		Else
			aHelpSpa := {}
		Endif
		
		If ValType(aPergs[nx][Len(aPergs[nx])-1]) = "A"
			aHelpEng := aPergs[nx][Len(aPergs[nx])-1]
		Else
			aHelpEng := {}
		Endif
		
		If ValType(aPergs[nx][Len(aPergs[nx])-2]) = "A"
			aHelpPor := aPergs[nx][Len(aPergs[nx])-2]
		Else
			aHelpPor := {}
		Endif
		
		PutSX1Help(cKey,aHelpPor,aHelpEng,aHelpSpa)
	Endif
Next
Return

/*
+-----------+----------+-------+--------------------+------+-------------+
| Programa  |MODULO10  |Autor  |Microsiga           | Data |  21/11/05   |
+-----------+----------+-------+--------------------+------+-------------+
| Desc.     |Cálculo do Modulo 10 para obtenção do DV dos campos do      |
|           |Codigo de Barras                                            |
+-----------+------------------------------------------------------------+
| Uso       | Financeiro Transilva LOG                                   |
+-----------+------------------------------------------------------------+
*/

Static Function Modulo10(cData)
Local  L,D,P := 0
Local B     := .F.
L := Len(cData)
B := .T.
D := 0
While L > 0
	P := Val(SubStr(cData, L, 1))
	If (B)
		P := P * 2
		If P > 9
			P := P - 9
		End
	End
	D := D + P
	L := L - 1
	B := !B
End
D := 10 - (Mod(D,10))
If D = 10
	D := 0
End
Return D

/*
+-----------+----------+-------+--------------------+------+-------------+
| Programa  |MODULO11  |Autor  |Microsiga           | Data |  21/11/05   |
+-----------+----------+-------+--------------------+------+-------------+
| Desc.     |Calculo do Modulo 11 para obtencao do DV do Codigo de Barras|
|           |                                                            |
+-----------+------------------------------------------------------------+
| Uso       | Financeiro Transilva LOG                                   |
+-----------+------------------------------------------------------------+
*/
Static Function Modulo11(cData)
Local L, D, P := 0
L := Len(cdata)
D := 0
P := 1
// Some o resultado de cada produto efetuado e determine o total como (D);
While L > 0
	P := P + 1
	D := D + (Val(SubStr(cData, L, 1)) * P)
	If P = 9
		P := 1
	End
	L := L - 1
End
// DAC = 11 - Mod 11(D)
D := 11 - (mod(D,11))
// OBS: Se o resultado desta for igual a 0, 1, 10 ou 11, considere DAC = 1.
If (D == 0 .Or. D == 1 .Or. D == 10 .Or. D == 11)
	D := 1
End
Return D
