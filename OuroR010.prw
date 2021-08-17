#include "rwmake.ch"
#include "PROTHEUS.ch"
#include "MSGRAPHI.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ RELPEDLR  ºAutor  ³EDUARDO LOBATO     º Data ³  27/05/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ RELATÓRIO DE LIBERAÇÃO OU REJEIÇÃO DE PEDIDOS DE VENDA     º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function OUROR010()
LOCAL nOpca	:=0
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
LOCAL aSays:={}, aButtons:={}
Private cCadastro := OemToAnsi("Relatorio de Pedido Analisados")
Public cPerg      := "OUROR010"

/*
MV_PAR01 - DA DATA
MV_PAR02 - ATE DATA
MV_PAR03 - D0 PEDIDO
MV_PAR04 - ATE PEDIDO
MV_PAR05 - TIPO: 1 - LIBERADO / 2 - REJEITADOS / 3 - AMBOS
MV_PAR06 - SAIDA: 1 - RELATORIO / 2 - EXCEL
MV_PAR07 - DA FILIAL
MV_PAR08 - ATE FILIAL
*/

Pergunte("OUROR010",.F.)
AADD (aSays, OemToAnsi(" Este programa tem como objetivo emitir o relatorio "))
AADD (aSays, OemToAnsi(" de analise de liberacao ou rejeicao de Pedidos de Venda"))
AADD (aSays, OemToAnsi(" "))
AADD(aButtons, { 1,.T.,{|o| nOpca:= 1,o:oWnd:End()}} )
AADD(aButtons, { 2,.T.,{|o| o:oWnd:End() }} )
AADD(aButtons, { 5,.T.,{|| Pergunte("OUROR010",.T. ) } } )
FormBatch( cCadastro, aSays, aButtons )
If nOpcA == 1
	#IFDEF TOP
		If TcSrvType() == 'AS/400'
			Processa({|lEnd| GERAR()},"Processando...")  // Chamada da funcao de reconciliacao
		Else
			Processa({|lEnd| GERAR()},"Este Processamento levara alguns minutos...")  // Chamada da funcao de reconciliacao
		Endif
	#ELSE
		Processa({|lEnd| GERAR()},"Este Processamento levara alguns minutos...")  // Chamada da funcao de reconciliacao
	#ENDIF
Endif

Return

//##########################################################################################

Static Function Gerar()
Local aRelImp    := MaFisRelImp("MT100",{"SF2","SD2"})
Local dDATA := CTOD("")

IF SELECT("TMP") > 0
	DBSELECTAREA("TMP")
	DBCLOSEAREA()
ENDIF

cQuery	:= " SELECT * "
cQuery	+= " FROM " + RetSqlName("SC5") + " SC5 "
//cQuery	+= " WHERE SC5.C5_FILIAL = '" + xFilial("SC5") + "'" 
cQuery	+= " WHERE SC5.C5_FILIAL >= '"+MV_PAR07+"'" 
cQuery	+= " AND SC5.C5_FILIAL <= '"+MV_PAR08+"'"
cQuery	+= " AND   SC5.C5_XDTLIB BETWEEN '"+DTOS(MV_PAR01)+"' AND '"+DTOS(MV_PAR02)+"'"
cQuery	+= " AND   SC5.C5_NUM >= '"+MV_PAR03+"'"
cQuery	+= " AND   SC5.C5_NUM <= '"+MV_PAR04+"'"                                       
IF MV_PAR05 == 1
	cQuery	+= " AND   SC5.C5_XTIPOL = 'L'"
ELSEIF  MV_PAR05 == 2
	cQuery	+= " AND   SC5.C5_XTIPOL = 'R'"
ENDIF
cQuery	+= " AND   SC5.D_E_L_E_T_ <> '*' "
DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery) , 'TMP', .T., .F.)

IF SELECT("TBR") > 0
	DBSELECTAREA("TBR")
	DBCLOSEAREA()
ENDIF

aCampos := {}
AADD(aCampos,{ "BR_USER"   ,"C",15,0 } )
AADD(aCampos,{ "BR_FILIAL" ,"C",02,0 } )  
AADD(aCampos,{ "BR_DTBLQ"  ,"D",08,0 } )
AADD(aCampos,{ "BR_DTLIB"  ,"D",08,0 } )
AADD(aCampos,{ "BR_DIFDAY" ,"N",3,0 } )
AADD(aCampos,{ "BR_PEDIDO" ,"C",06,0 } )
AADD(aCampos,{ "BR_CLIENTE","C",06,0 } )
AADD(aCampos,{ "BR_NOME"   ,"C",20,0 } )
AADD(aCampos,{ "BR_RISCO"  ,"C",01,0 } )
AADD(aCampos,{ "BR_SITUA"  ,"C",20,0 } )
AADD(aCampos,{ "BR_LC"	   ,"N",14,2 } )
AADD(aCampos,{ "BR_SALDUP" ,"N",14,2 } )
AADD(aCampos,{ "BR_OBS"    ,"C",20,0 } )
AADD(aCampos,{ "BR_TOTAL"  ,"N",14,2 } ) 
AADD(aCampos,{ "BR_CPAG"   ,"C",03,0 } )
AADD(aCampos,{ "BR_SLDLC"  ,"N",14,2 } )
AADD(aCampos,{ "BR_VCLC"   ,"D",08,0 } )
AADD(aCampos,{ "BR_VCFIS"  ,"D",08,0 } )
AADD(aCampos,{ "BR_TIPOL"  ,"C",10,0 } )
AADD(aCampos,{ "BR_MOTIVO" ,"C",100,0 } )
                                        
AADD(aCampos,{ "BR_MCOMPRA","N",14,2 } )
AADD(aCampos,{ "BR_PRICOM" ,"D",08,0 } )
AADD(aCampos,{ "BR_ULTCOM" ,"D",08,0 } )
AADD(aCampos,{ "BR_METR"   ,"N",07,2 } )
AADD(aCampos,{ "BR_MATR"   ,"N",07,2 } )
AADD(aCampos,{ "BR_MEDIA"  ,"N",14,2 } )    

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria arquivo de trabalho                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cNomArq 	:=  CriaTrab(aCampos)
dbUseArea( .T.,, cNomArq,"TBR", .F. , .F. )

cNomArq1 := Subs(cNomArq,1,7)+"A"
IndRegua("TBR",cNomArq1,"DTOS(BR_DTLIB)+BR_PEDIDO",,,)		//"Selecionando Registros..."
dbClearIndex()

dbSetIndex(cNomArq1+OrdBagExt())

dbselectarea("TBR")
DBSETORDER(1)


dbSelectArea("TMP")
dbGoTop()

ProcRegua(RecCount())

While !EOF()
	
	IncProc()      

	cNumPed    := TMP->C5_NUM
	cCliente   := TMP->C5_CLIENTE
	cLoja      := TMP->C5_LOJACLI                                                                        

	DBSELECTAREA("SA1")
	DBSETORDER(1)
	DBGOTOP()
	DBSEEK(XFILIAL("SA1")+cCLIENTE+cLOJA)

	cRisco      := SA1->A1_RISCO
	nLimite     := SA1->A1_LC      // Limite de Credito
	nSaldoDup   := SA1->A1_SALDUP  // Cta. Receber
	cNome		:= SA1->A1_NREDUZ

	
	nPedAprov  := SomaPed()        // Soma o Credito dos Pedidos ja Aprovados
	nDisp      := nLimite - nSaldoDup - nPedAprov 

//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	MaFisSave()
	MaFisEnd()
	MaFisIni(TMP->C5_CLIENTE,;// 1-Codigo Cliente/Fornecedor
		TMP->C5_LOJACLI,;		// 2-Loja do Cliente/Fornecedor
		"C",;				// 3-C:Cliente , F:Fornecedor
		"N",;				// 4-Tipo da NF
		SA1->A1_TIPO,;		// 5-Tipo do Cliente/Fornecedor
		Nil,;
		Nil,;
		Nil,;
		Nil,;
		"MATA410")

    DBSELECTAREA("SC6")
    DBSETORDER(1)
    DBGOTOP()
    IF DBSEEK(XFILIAL("SC6")+TMP->C5_NUM)
        WHILE !EOF() .AND. SC6->C6_NUM == TMP->C5_NUM
			MaFisAdd(SC6->C6_PRODUTO  ,; // 1-Codigo do Produto ( Obrigatorio )
			 SC6->C6_TES   ,; // 2-Codigo do TES ( Opcional )
	         SC6->C6_QTDVEN ,; // 3-Quantidade ( Obrigatorio )
	         SC6->C6_PRCVEN ,; // 4-Preco Unitario ( Obrigatorio )
		     0,;      	         // 5-Valor do Desconto ( Opcional )
		     "",;	   			 // 6-Numero da NF Original ( Devolucao/Benef )
	         "",;				 // 7-Serie da NF Original ( Devolucao/Benef )
	         0,;				 // 8-RecNo da NF Original no arq SD1/SD2
	         0,;			     // 9-Valor do Frete do Item ( Opcional )
	         0,;				 // 10-Valor da Despesa do item ( Opcional )
	         0,;				 // 11-Valor do Seguro do item ( Opcional )
	         0,;				 // 12-Valor do Frete Autonomo ( Opcional )
	         SC6->C6_VALOR,;// 13-Valor da Mercadoria ( Obrigatorio )
	         0)					 // 14-Valor da Embalagem ( Opiconal )
			DBSKIP()
		END
	ENDIF
		
	nTotPed    := MaFisRet(,'NF_TOTAL')
		                                                            
	MaFisEnd()
	MaFisRestore()

	IF SELECT("TMP1") > 0
		DBSELECTAREA("TMP1")
		DBCLOSEAREA()
	ENDIF

	cQuery	:= " SELECT D2_EMISSAO "
	cQuery	+= " FROM " + RetSqlName("SD2") + " SD2 "
	cQuery	+= " WHERE SD2.D2_PEDIDO <> '"+TMP->C5_NUM+"'"
	cQuery	+= " AND   SD2.D2_CLIENTE = '"+TMP->C5_CLIENTE+"'"
	cQuery	+= " AND   SD2.D2_LOJA = '"+TMP->C5_LOJACLI+"'"	
	cQuery	+= " AND   SD2.D_E_L_E_T_ <> '*' "
	cQuery	+= " ORDER BY D2_EMISSAO "
	DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery) , 'TMP1', .T., .F.)

	DBSELECTAREA("TMP1")
	DBGOTOP()
	WHILE !EOF()
		dDATA := STOD(TMP1->D2_EMISSAO)
		DBSKIP()
	END
	                                   
	DBSELECTAREA("TMP1")
	DBCLOSEAREA()
	
	DBSELECTAREA("TBR")
	DBSETORDER(1)
	DBGOTOP()
	RecLock("TBR",.T.)
	FIELD->BR_USER		:= TMP->C5_XUSRLIB 
	FIELD->BR_FILIAL	:= TMP->C5_FILIAL
	FIELD->BR_DTBLQ		:= STOD(TMP->C5_XDTBLQ)
	FIELD->BR_DTLIB		:= STOD(TMP->C5_XDTLIB)
	
	If !Empty(TMP->C5_XDTBLQ) .AND. !Empty(TMP->C5_XDTLIB) 
		nDifDay := DateWorkDay(STOD(TMP->C5_XDTBLQ),STOD(TMP->C5_XDTLIB))
		If nDifDay > 0
			nDifDay--
		EndIf
	Else
		nDifDay := 0
	EndIf

	FIELD->BR_DIFDAY	:= nDifDay
	FIELD->BR_PEDIDO	:= TMP->C5_NUM
	FIELD->BR_CLIENTE	:= TMP->C5_CLIENTE
	FIELD->BR_NOME		:= cNOME
	FIELD->BR_RISCO		:= SA1->A1_RISCO
	FIELD->BR_SITUA		:= TMP->C5_AVISO
	FIELD->BR_LC		:= SA1->A1_LC
	FIELD->BR_SALDUP	:= SA1->A1_SALDUP
	FIELD->BR_OBS		:= ""
	FIELD->BR_TOTAL		:= nTOTPED
	FIELD->BR_CPAG		:= TMP->C5_CONDPAG
	FIELD->BR_SLDLC		:= nDISP
	FIELD->BR_VCLC		:= SA1->A1_VENCLC
	FIELD->BR_VCFIS     := SA1->A1_XVENFIS
	FIELD->BR_TIPOL		:= IIF(ALLTRIM(TMP->C5_XTIPOL)=="L","LIBERADO","REJEITADO")
	FIELD->BR_MOTIVO	:= TMP->C5_XMOTLIB
	FIELD->BR_MCOMPRA	:= SA1->A1_MCOMPRA
	FIELD->BR_PRICOM	:= SA1->A1_PRICOM
	FIELD->BR_ULTCOM	:= dDATA
	FIELD->BR_METR		:= SA1->A1_METR
	FIELD->BR_MATR		:= SA1->A1_MATR
	FIELD->BR_MEDIA		:= MEDIAC(cCLIENTE,cLOJA)
	MsUnLock()

	dbSelectArea("TMP")
	dbSkip()
	
EndDo


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
cString    := "SC5"
wnrel      := "RELPCL"
CbTxt      := ""
cDesc1     := ""
cDesc2     := ""
Tamanho    := "G"
aReturn    := { "Zebrado", 1,"Administracao", 2, 2, 1, "",1 }
nLastKey   := 0
cabec1     := ""
cabec2     := ""
cRodaTxt   := ""
nCntImpr   := 0
nTipo      := 0
nomeprog   := "RELPCL"
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

IF MV_PAR06 == 1
	
	wnrel:="RELPCL"
	wnrel:=SetPrint(cString,wnrel,"",titulo,cDesc1,cDesc2,"",.F.,"")
	
	
	If nLastKey == 27
		Return .T.
	Endif
	
	SetDefault(aReturn,cString)
	
	If nLastKey == 27
		Return .T.
	Endif
	
	RptStatus({|| GERImp()},Titulo)// Substituido pelo assistente de conversao do AP6 IDE em 19/02/07 ==> 	RptStatus({|| Execute(RSZ1Imp)},Titulo)
	Return
	
ELSE
	
	aTOTEXC := {}
	
	AADD(aTOTEXC,{"USUARIO",;
		    	"FILIAL",;	
				"DATA BLQ",;
		    	"DATA LIB",;
				"DIF. DIAS",;
		    	"PEDIDO",;
		    	"CLIENTE",;     
		    	"NOME",;     
		    	"RISCO",;
		    	"SITUACAO",;
		    	"LIMITE CREDITO",;
		    	"SALDO DUPLICATAS",;
		    	"OBSERVACAO",;
		    	"TOTAL PEDIDO",;
		    	"COND. PAGTO",;
		    	"SALDO L.CREDITO",;  
		    	"VENCTO LM CREDITO",;
				"VENCTO FISCAL",;
		    	"CONCLUSAO",;
		    	"MOTIVO",;
		    	"MAIOR COMPRA",;
		    	"PRIMEIRA COMPRA",;
		    	"ULTIMA COMPRA",;
		    	"MEDIA ATRASO",;
		    	"MAIOR ATRASO",;
		    	"MEDIA COMPRA (6 MESES)"})
	
	DBSELECTAREA("TBR")
	DBSETORDER(1)
	DBGOTOP()
	WHILE !EOF()

		AADD(aTOTEXC,{TBR->BR_USER,;      
			TBR->BR_FILIAL,;
			TBR->BR_DTBLQ,;
			TBR->BR_DTLIB,;
			TBR->BR_DIFDAY,;
			TBR->BR_PEDIDO,;
			TBR->BR_CLIENTE,;
			TBR->BR_NOME,;
			TBR->BR_RISCO,;
			TBR->BR_SITUA,;
			TBR->BR_LC,;
			TBR->BR_SALDUP,;
			TBR->BR_OBS,;
			TBR->BR_TOTAL,;
			TBR->BR_CPAG,;			
			TBR->BR_SLDLC,;
			TBR->BR_VCLC,;
			TBR->BR_VCFIS,;
			TBR->BR_TIPOL,;
			TBR->BR_MOTIVO,;
			TBR->BR_MCOMPRA,;
			TBR->BR_PRICOM,;
			TBR->BR_ULTCOM,;
			TBR->BR_METR,;
			TBR->BR_MATR,;
			TBR->BR_MEDIA})
		
		DBSKIP()
	END
	
	acabexcel := {}
	
	AADD(acabexcel,,{"USUARIO",;
		    	"FILIAL",;	
				"DATA BLQ",;
		    	"DATA LIB",;
				"DIF. DIAS",;
		    	"PEDIDO",;
		    	"CLIENTE",;     
		    	"NOME",;     
		    	"RISCO",;
		    	"SITUACAO",;
		    	"LIMITE CREDITO",;
		    	"SALDO DUPLICATAS",;
		    	"OBSERVACAO",;
		    	"TOTAL PEDIDO",;
		    	"COND. PAGTO",;
		    	"SALDO L.CREDITO",;  
		    	"VENCTO LM CREDITO",;
				"VENCTO FISCAL",;
		    	"CONCLUSAO",;
		    	"MOTIVO",;
		    	"MAIOR COMPRA",;
		    	"PRIMEIRA COMPRA",;
		    	"ULTIMA COMPRA",;
		    	"MEDIA ATRASO",;
		    	"MAIOR ATRASO",;
		    	"MEDIA COMPRA (6 MESES)"})
	
	If !apoleclient("MSExcel")
		MSGALERT("Nao foi possivel enviar os dados, Microsoft Excel nao instalado!")
	Else
		dlgtoexcel({{"ARRAY","Relatorio de Pedido Analisados",acabexcel,aTOTEXC }})
	Endif
ENDIF
RETURN

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ GERIMP   ³ Autor ³ EDUARDO LOBATO        ³ Data ³ 22.03.07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Chamada do Relatorio                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GERCTB                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
// Substituido pelo assistente de conversao do AP6 IDE em 19/02/07 ==> Function RSZ1Imp

Static Function GERIMP()


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

Titulo     := "Relatorio de Pedido Analisados"
XLIN := 80

cabec1 := "USUARIO    DATA        PEDIDO  CLIENT  RC SITUACAO         LIMITE         SALDO         TOTAL  SALDO LIMITE  CONCLUSAO MOTIVO                       MAIOR   PRIMEIRA     ULTIMA       MEDIA     MAIOR         MEDIA      DATA"
cabec2 := "           LIBERA                                         CREDITO    DUPLICATAS        PEDIDO       CREDITO                                        COMPRA    COMPRA      COMPRA      ATRASO    ATRASO       COMPRAS      BLOQUEIO"

xLIN := 80


DBSELECTAREA("TBR")
DBSETORDER(1)
DBGOTOP()
SETREGUA(RECCOUNT())
WHILE !EOF()
	INCREGUA()
	IF XLIN > 60
		Cabec(titulo,cabec1,cabec2,nomeprog,tamanho,nTipo)
		XLIN := 10
	ENDIF
	@ XLIN,000 PSAY SUBS(TBR->BR_USER,1,10)
	@ XLIN,012 PSAY TBR->BR_DTLIB
	@ XLIN,024 PSAY TBR->BR_PEDIDO
	@ XLIN,032 PSAY TBR->BR_CLIENTE
	@ XLIN,040 PSAY TBR->BR_RISCO
	@ XLIN,043 PSAY SUBS(TBR->BR_SITUA,1,10)
	@ XLIN,054 PSAY TBR->BR_LC PICTURE "@E 9,999,999.99"
	@ XLIN,068 PSAY TBR->BR_SALDUP PICTURE "@E 9,999,999.99"
	@ XLIN,082 PSAY TBR->BR_TOTAL PICTURE "@E 9,999,999.99"
	@ XLIN,096 PSAY TBR->BR_SLDLC PICTURE "@E 9,999,999.99"
	@ XLIN,110 PSAY ALLTRIM(TBR->BR_TIPOL)
	@ XLIN,120 PSAY SUBS(TBR->BR_MOTIVO,1,20)
	@ XLIN,142 PSAY TBR->BR_MCOMPRA PICTURE "@E 9,999,999.99"

	@ XLIN,156 PSAY TBR->BR_PRICOM
	@ XLIN,168 PSAY TBR->BR_ULTCOM
	@ XLIN,180 PSAY TBR->BR_METR PICTURE "@E 9,999.99"
	@ XLIN,190 PSAY TBR->BR_MATR PICTURE "@E 9,999.99"
	@ XLIN,200 PSAY TBR->BR_MEDIA PICTURE "@E 9,999,999.99"
	@ XLIN,212 PSAY TBR->BR_DTBLQ 
	++XLIN
	DBSKIP()
END 

Set device to Screen

If aReturn[5] == 1
	Set Printer To
	dbCommitAll()
	OurSpool(wnrel)
Endif

MS_FLUSH()

RETURN
                   
Static Function SomaPed()
cSavAlias := Alias()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Checagem de Credito de Clientes                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ


IF SELECT("TMP1") > 0
	DBSELECTAREA("TMP1")
	DBCLOSEAREA()
ENDIF


cQuery :=          " SELECT SUM( (SC6.C6_QTDVEN-SC6.C6_QTDENT) * (SC6.C6_PRCVEN + ROUND(SC6.C6_PRCVEN *(SC5.C5_ACRSFIN/100),2))) TOTPED"
cQuery := cQuery + " FROM "+RetSqlName("SC6")+ " SC6,"
cQuery := cQuery + "      "+RetSqlName("SC5")+ " SC5,"
cQuery := cQuery + "      "+RetSqlName("SF4")+ " SF4"
cQuery := cQuery + " WHERE (SC6.C6_QTDVEN-SC6.C6_QTDENT) > 0"		//Alterado para compatibilizacao da nova estrtutra
cQuery := cQuery + "   AND SC6.C6_BLQ  = '  '"
cQuery := cQuery + "   AND SC6.C6_TES  = SF4.F4_CODIGO"
cQuery := cQuery + "   AND SF4.F4_DUPLIC = 'S'"
cQuery := cQuery + "   AND SC6.C6_NUM = SC5.C5_NUM"
cQuery := cQuery + "   AND SC6.C6_NUM <> '" + cNumPed + "'"
cQuery := cQuery + "   AND SC6.C6_CLI  = '" + cCliente + "'"
cQuery := cQuery + "   AND SC6.C6_LOJA = '" + cLoja + "'"
cQuery := cQuery + "   AND SC5.C5_TIPO = 'N'"
cQuery := cQuery + "   AND SC6.D_E_L_E_T_ <> '*'"
cQuery := cQuery + "   AND SC5.D_E_L_E_T_ <> '*'"
cQuery := cQuery + "   AND SF4.D_E_L_E_T_ <> '*'"

DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery) , 'TMP1', .T., .F.)
DBSELECTAREA("TMP1")
DBGOTOP()

nPedAprov := TMP1->TOTPED
DbCloseArea()
DbselectArea(cSavAlias)
Return(nPedAprov)
       
STATIC FUNCTION MEDIAC(cCLIENTE,cLOJA)
LOCAL nMEDIA  
cSavAlias := Alias()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Checagem de Credito de Clientes                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

IF SELECT("TMP2") > 0
	DBSELECTAREA("TMP2")
	DBCLOSEAREA()
ENDIF


cQuery :=          " SELECT SUM(SD2.D2_TOTAL + SD2.D2_VALIPI + SD2.D2_ICMSRET)AS TOTPED"
cQuery := cQuery + " FROM "+RetSqlName("SD2")+ " SD2,"
cQuery := cQuery + "      "+RetSqlName("SF4")+ " SF4"
cQuery := cQuery + " WHERE SD2.D2_TES  = SF4.F4_CODIGO"
cQuery := cQuery + "   AND SF4.F4_DUPLIC = 'S'"
cQuery := cQuery + "   AND SD2.D2_EMISSAO  BETWEEN '"+DTOS(dDATABASE-180)+"' AND '"+DTOS(dDATABASE)+"'"
cQuery := cQuery + "   AND SD2.D2_CLIENTE  = '" + cCliente + "'"
cQuery := cQuery + "   AND SD2.D2_LOJA = '" + cLoja + "'"
cQuery := cQuery + "   AND SD2.D2_TIPO = 'N'"
cQuery := cQuery + "   AND SD2.D_E_L_E_T_ <> '*'"
cQuery := cQuery + "   AND SF4.D_E_L_E_T_ <> '*'"

DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery) , 'TMP2', .T., .F.)
DBSELECTAREA("TMP2")
DBGOTOP()

nMEDIA := TMP2->TOTPED
DbCloseArea()
DbselectArea(cSavAlias)

RETURN(nMEDIA)