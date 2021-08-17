#include "rwmake.ch" 
#Include "PROTHEUS.CH"     
                                           

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³  Ouro032 ³ Autor ³ Eduardo Lobato        ³ Data ³ 19/12/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ACERTO DE ACUMULADOS DE ESTOQUE			                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAEST                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ PROGRAMADOR  ³ DATA   ³ BOPS ³  MOTIVO DA ALTERACAO                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³                                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/  
User Function Ouro002()      

LOCAL nOpca	:=0
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
LOCAL aSays:={}, aButtons:={}
Private cCadastro := OemToAnsi("ACERTO DE ACUMULADOS DE ESTOQUE") 
Public cPerg      := "Ouro002"

Pergunte("GERCTB",.F.)
AADD (aSays, OemToAnsi(" Este programa tem como objetivo processar os arquivos "))
AADD (aSays, OemToAnsi(" de saldos e pedidos de venda para refazer os acumulados"))
AADD (aSays, OemToAnsi(" de saldos de pedidos de venda "))

AADD(aButtons, { 1,.T.,{|o| nOpca:= 1,o:oWnd:End()}} )
AADD(aButtons, { 2,.T.,{|o| o:oWnd:End() }} )
AADD(aButtons, { 5,.T.,{|| Pergunte("OURO02",.T. ) } } )
FormBatch( cCadastro, aSays, aButtons )
If nOpcA == 1
	#IFDEF TOP
		If TcSrvType() == 'AS/400'	
			Processa({|lEnd| PROCGER()},"Processando Querys...")  // Chamada da funcao de reconcilia‡Æo
		Else
			Processa({|lEnd| PROCGER()},"Processando Querys...")  // Chamada da funcao de reconcilia‡Æo
		Endif
	#ELSE
		Processa({|lEnd| PROCGER()},"Processando Querys...")  // Chamada da funcao de reconcilia‡Æo
	#ENDIF
Endif
Return


Static Function PROCGER()      
LOCAL aCampos := {}   
LOCAL bCampos := {}   

//³ mv_par01            // Do Produto
//³ mv_par02            // Ao Produto




///// arquivo nivel 1      

IF SELECT("TBR") >0
	DBSELECTAREA("TBR")
	DBCLOSEAREA()
ENDIF

AADD(aCampos,{ "BR_FILIAL" ,"C",02,0 } )
AADD(aCampos,{ "BR_COD"    ,"C",15,0 } )
AADD(aCampos,{ "BR_LOCAL"  ,"C",02,0 } )
AADD(aCampos,{ "BR_RESEOLD","N",12,2 } )  
AADD(aCampos,{ "BR_QPEDOLD","N",12,2 } ) 
AADD(aCampos,{ "BR_RESERVA","N",12,2 } )  
AADD(aCampos,{ "BR_QPEDVEN","N",12,2 } ) 
                                                                    
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria arquivo de trabalho                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cNomArq 	:=  CriaTrab(aCampos)  
dbUseArea( .T.,, cNomArq,"TBR", .F. , .F. )

cNomArq1 := Subs(cNomArq,1,7)+"A"
IndRegua("TBR",cNomArq1,"BR_FILIAL+BR_COD+BR_LOCAL",,,)		//"Selecionando Registros..."
dbClearIndex()          
              

dbSetIndex(cNomArq1+OrdBagExt())

dbselectarea("TBR")
DBSETORDER(1)

///// arquivo nivel 2

IF SELECT("TCR") >0
	DBSELECTAREA("TCR")
	DBCLOSEAREA()
ENDIF

AADD(bCampos,{ "CR_FILIAL" ,"C",02,0 } )
AADD(bCampos,{ "CR_COD"    ,"C",15,0 } )
AADD(bCampos,{ "CR_LOCAL"  ,"C",02,0 } )  
AADD(bCampos,{ "CR_EMPEOLD","N",12,2 } ) 
AADD(bCampos,{ "CR_EMPENHO","N",12,2 } ) 
AADD(bCampos,{ "CR_LOTECTL","C",10,0 } )
                                                                    
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria arquivo de trabalho                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cNomArqC 	:=  CriaTrab(bCampos)
dbUseArea( .T.,, cNomArqC,"TCR", .F. , .F. )

cNomArqC1 := Subs(cNomArqC,1,7)+"A"
IndRegua("TCR",cNomArqC1,"CR_FILIAL+CR_COD+CR_LOCAL+CR_LOTECTL",,,)		//"Selecionando Registros..."
dbClearIndex()          
              

dbSetIndex(cNomArqC1+OrdBagExt())

dbselectarea("TCR")
DBSETORDER(1)

///////////////////// PROCESSAMENTO

DBSELECTAREA("SB2")
DBSETORDER(1)
DBGOTOP()
DBSEEK(XFILIAL("SB2")+MV_PAR01)
WHILE !EOF() .AND. SB2->B2_COD >= MV_PAR01 .AND. SB2->B2_COD <= MV_PAR02 .AND. SB2->B2_FILIAL == XFILIAL("SB2")
	 /// PROCESSA QUERY DO SC6 PARA ACHAR QPEDVEN DE ITENS DE PEDIDOS NÃO LIBERADOS
	 
	IF SELECT("TC6") > 0
		DBSELECTAREA("TC6")
	 	DBCLOSEAREA()
	ENDIF
	
	cQUERY := "	SELECT * "
	cQUERY += " FROM " + RetSqlName("SC6") + " SC6 "
	cQUERY += " WHERE C6_FILIAL = '" + xFilial("SC6") + "' "
	cQUERY += " AND C6_LOCAL = '"+SB2->B2_LOCAL+"' "
	cQUERY += " AND C6_PRODUTO = '"+SB2->B2_COD+"' "
	cQUERY += " AND C6_NOTA = '         ' "
	cQUERY += " AND C6_QTDEMP = 0 "
	cQUERY += " AND	C6_BLQ <> 'R ' "
	cQUERY += " AND C6_BLQ <> 'S ' "
	cQUERY += " AND SC6.D_E_L_E_T_ <> '*'	 "                     
	DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery) , 'TC6', .T., .F.)

	DBSELECTAREA("TC6")
	DBGOTOP()
	WHILE!EOF()
	 
	 	DBSELECTAREA("TBR")
	 	DBSETORDER(1)
	 	DBGOTOP()
	 	IF !DBSEEK(XFILIAL("SB2")+TC6->C6_PRODUTO+TC6->C6_LOCAL)
	 		DBSELECTAREA("TBR")
	 		RECLOCK("TBR",.T.)
	 		FIELD->BR_FILIAL 	:= TC6->C6_FILIAL
	 		FIELD->BR_COD		:= TC6->C6_PRODUTO
	 		FIELD->BR_LOCAL		:= TC6->C6_LOCAL
	 		FIELD->BR_QPEDVEN	:= (TC6->C6_QTDVEN - TC6->C6_QTDENT)
	 		MSUNLOCK()
	 	ELSE
	 		DBSELECTAREA("TBR")
	 		RECLOCK("TBR",.F.)
	 		FIELD->BR_QPEDVEN	:= TBR->BR_QPEDVEN + (TC6->C6_QTDVEN - TC6->C6_QTDENT)
	 		MSUNLOCK()
	 	ENDIF
	 
	 	DBSELECTAREA("TC6")
		DBSKIP()
	END

	
	 /// PROCESSA QUERY DO SC9 PARA ACHAR QPEDVEN DE ITENS DE PEDIDOS LIBERADOS
	 
	IF SELECT("TC9")  > 0
	 	DBSELECTAREA("TC9")
	 	DBCLOSEAREA()
	ENDIF
	
	cQUERY := "	SELECT * "
	cQUERY += " FROM " + RetSqlName("SC9") + " SC9 "
	cQUERY += " WHERE C9_FILIAL = '" + xFilial("SC9") + "' "
	cQUERY += " AND C9_LOCAL = '"+SB2->B2_LOCAL+"' "
	cQUERY += " AND C9_PRODUTO = '"+SB2->B2_COD+"' "
	cQUERY += " AND C9_OK = '    ' "
	cQUERY += " AND C9_NFISCAL = '         ' "
	cQUERY += " AND C9_BLEST <> '  ' "
	cQUERY += " AND SC9.D_E_L_E_T_ <> '*' "
	DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery) , 'TC9', .T., .F.)
	

	DBSELECTAREA("TC9")
	DBGOTOP()
	WHILE!EOF()
	 
	 	DBSELECTAREA("TBR")
	 	DBSETORDER(1)
	 	DBGOTOP()
	 	IF !DBSEEK(XFILIAL("SB2")+TC9->C9_PRODUTO+TC9->C9_LOCAL)
	 		DBSELECTAREA("TBR")
	 		RECLOCK("TBR",.T.)
	 		FIELD->BR_FILIAL 	:= TC9->C9_FILIAL
	 		FIELD->BR_COD		:= TC9->C9_PRODUTO
	 		FIELD->BR_LOCAL		:= TC9->C9_LOCAL  
	 		FIELD->BR_QPEDVEN	:= TC9->C9_QTDLIB
	 		MSUNLOCK()
	 	ELSE
	 		DBSELECTAREA("TBR")
	 		RECLOCK("TBR",.F.)
	 		FIELD->BR_QPEDVEN	:= TBR->BR_QPEDVEN + TC9->C9_QTDLIB
	 		MSUNLOCK()
	 	ENDIF
	 
	 	DBSELECTAREA("TC9")
		DBSKIP()
	END

	
	 /// PROCESSA QUERY DO SC9 PARA ACHAR RESERVADOS DE ITENS DE PEDIDOS LIBERADOS
	 
	 IF SELECT("LC9")  > 0
	 	DBSELECTAREA("LC9")
	 	DBCLOSEAREA()
	 ENDIF
	
	cQUERY := "	SELECT * "
	cQUERY += " FROM " + RetSqlName("SC9") + " SC9 "
	cQUERY += " WHERE C9_FILIAL = '" + xFilial("SC9") + "' "
	cQUERY += " AND C9_LOCAL = '"+SB2->B2_LOCAL+"' "
	cQUERY += " AND C9_PRODUTO = '"+SB2->B2_COD+"' "
	cQUERY += " AND C9_OK = '    ' "
	cQUERY += " AND C9_NFISCAL = '         ' "
	cQUERY += " AND C9_BLEST = '  ' "
	cQUERY += " AND SC9.D_E_L_E_T_ <> '*' "
	DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery) , 'LC9', .T., .F.)

	DBSELECTAREA("LC9")
	DBGOTOP()
	WHILE!EOF()
	 
	 	DBSELECTAREA("TBR")
	 	DBSETORDER(1)
	 	DBGOTOP()
	 	IF !DBSEEK(XFILIAL("SB2")+LC9->C9_PRODUTO+LC9->C9_LOCAL)
	 		DBSELECTAREA("TBR")
	 		RECLOCK("TBR",.T.)
	 		FIELD->BR_FILIAL 	:= LC9->C9_FILIAL
	 		FIELD->BR_COD		:= LC9->C9_PRODUTO
	 		FIELD->BR_LOCAL		:= LC9->C9_LOCAL
	 		FIELD->BR_RESERVA	:= LC9->C9_QTDLIB 
	 		MSUNLOCK()
	 	ELSE
	 		DBSELECTAREA("TBR")
	 		RECLOCK("TBR",.F.)
	 		FIELD->BR_RESERVA	:= TBR->BR_RESERVA + LC9->C9_QTDLIB
	 		MSUNLOCK()
	 	ENDIF


	 	DBSELECTAREA("TCR")
	 	DBSETORDER(1)
	 	DBGOTOP()
	 	IF !DBSEEK(XFILIAL("SB2")+LC9->C9_PRODUTO+LC9->C9_LOCAL+LC9->C9_LOTECTL)
	 		DBSELECTAREA("TCR")
	 		RECLOCK("TCR",.T.)
	 		FIELD->CR_FILIAL	:= LC9->C9_FILIAL
	 		FIELD->CR_COD		:= LC9->C9_PRODUTO
	 		FIELD->CR_LOCAL		:= LC9->C9_LOCAL
	 		FIELD->CR_EMPENHO	:= LC9->C9_QTDLIB 
	 		FIELD->CR_LOTECTL	:= LC9->C9_LOTECTL
	 	ELSE
		 	FIELD->CR_EMPENHO	:= TCR->CR_EMPENHO + LC9->C9_QTDLIB 
        ENDIF

	 	DBSELECTAREA("LC9")
		DBSKIP()
	END
    
    DBSELECTAREA("SB2")       
    DBSKIP()
END                


DBSELECTAREA("TBR")
DBGOTOP()
WHILE !EOF()
	DBSELECTAREA("SB2")
	DBSETORDER(1)
	DBGOTOP()
	DBSEEK(XFILIAL("SB2")+TBR->BR_COD+TBR->BR_LOCAL)
	nRESERVA	:= SB2->B2_RESERVA
	nQPEDVEN	:= SB2->B2_QPEDVEN

	RECLOCK("SB2",.F.)
	FIELD->B2_RESERVA := TBR->BR_RESERVA
	FIELD->B2_QPEDVEN := TBR->BR_QPEDVEN
	MSUNLOCK()

	DBSELECTAREA("TBR")
	RECLOCK("TBR",.F.)
	FIELD->BR_RESEOLD	:= nRESERVA
	FIELD->BR_QPEDOLD	:= nQPEDVEN
	MSUNLOCK()

	DBSKIP()
END	

DBSELECTAREA("TCR")
DBGOTOP()
WHILE !EOF()
	
	DBSELECTAREA("SB8")
	DBSETORDER(3)
	DBGOTOP()
	DBSEEK(XFILIAL("SB2")+TCR->CR_COD+TCR->CR_LOCAL+TCR->CR_LOTECTL)
	nEMPENHO := SB8->B8_EMPENHO

	RECLOCK("SB8",.F.)
	FIELD->B8_EMPENHO := TCR->CR_EMPENHO
	MSUNLOCK()                               
	
	DBSELECTAREA("TCR")         
	RECLOCK("TCR",.F.)
	FIELD->CR_EMPEOLD := nEMPENHO
	MSUNLOCK()
	
	DBSKIP()
END	

/////////////////////////////////////////////////  
 

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
wnrel      := "OURO002"
CbTxt      := ""
cDesc1     := ""
cDesc2     := ""
Tamanho    := "P"
aReturn    := { "Zebrado", 1,"Administra‡„o", 2, 2, 1, "",1 }
nLastKey   := 0
cabec1     := ""
cabec2     := ""
cRodaTxt   := ""
nCntImpr   := 0
nTipo      := 0
nomeprog   := "OURO002"
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
wnrel:="OURO002"
wnrel:=SetPrint(cString,wnrel,cPerg,titulo,cDesc1,cDesc2,"",.F.,"")


If nLastKey == 27
   Return .T.
Endif

SetDefault(aReturn,cString)

If nLastKey == 27
   Return .T.
Endif


#IFDEF WINDOWS
	RptStatus({|| GERImp()},Titulo)// Substituido pelo assistente de conversao do AP6 IDE em 19/02/07 ==> 	RptStatus({|| Execute(RSZ1Imp)},Titulo)
	Return   

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

Static Function GERIMP() 
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
cabec1 := "    CODIGO              ALM            RESERVA         PEDIDO DE VENDA"
cabec2 := "                                  ANTIGA     ATUAL    ANTIGO      ATUAL"

//                                                           999,999,999,999.99 DD                  999,999,999,999.99            999,999,999,999.99           999,999,999,999.99 DD
//12345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
//         1         2         3         4         5         6         7         8         9         0         1         2         3         4         5         6         7         8         9         0         1         2        
                 
 

Titulo     := "Acerto de Quantidades Acumuladas nas Tabelas de Saldos - SB2"
XLIN := 80

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
     @ XLIN,005 PSAY TBR->BR_COD
     @ XLIN,025 PSAY TBR->BR_LOCAL
     @ XLIN,030 PSAY TBR->BR_RESEOLD PICTURE "@E 999,999.99"
     @ XLIN,040 PSAY TBR->BR_RESERVA PICTURE "@E 999,999.99"
     @ XLIN,050 PSAY TBR->BR_QPEDOLD PICTURE "@E 999,999.99"
     @ XLIN,060 PSAY TBR->BR_QPEDVEN PICTURE "@E 999,999.99"
     ++XLIN
     DBSKIP()
END             


Titulo     := "Acerto de Quantidades Acumuladas nas Tabelas de Saldos - SB8"
cabec1 := "    CODIGO              ALM                  EMPENHO            NUM. LOTE"
cabec2 := "                                       ANTIGO         ATUAL "

XLIN := 80


DBSELECTAREA("TCR")
DBGOTOP()
SETREGUA(RECCOUNT())  
WHILE !EOF() 
     INCREGUA()
     IF XLIN > 60
        Cabec(titulo,cabec1,cabec2,nomeprog,tamanho,nTipo)      
        XLIN := 10
     ENDIF    
     @ XLIN,005 PSAY TCR->CR_COD
     @ XLIN,025 PSAY TCR->CR_LOCAL
     @ XLIN,035 PSAY TCR->CR_EMPEOLD PICTURE "@E 999,999.99" 
     @ XLIN,050 PSAY TCR->CR_EMPENHO PICTURE "@E 999,999.99"     
     @ XLIN,065 PSAY TCR->CR_LOTECTL
     ++XLIN 

     DBSELECTAREA("TCR")    
     DBSKIP()
END 

Set device to Screen        


dbSelectArea( "TBR" )
dbCloseArea()
fErase(cNomArq+GetDBExtension())
fErase(cNomArq1+OrdBagExt()) 

dbSelectArea( "TCR" )
dbCloseArea()
fErase(cNomArqC+GetDBExtension())
fErase(cNomArqC1+OrdBagExt()) 
               
dbSelectArea( "TC6" )
dbCloseArea()

dbSelectArea( "TC9" )
dbCloseArea()

dbSelectArea( "LC9" )
dbCloseArea()

If aReturn[5] == 1
	Set Printer To 
	dbCommitAll()
	OurSpool(wnrel)
Endif

MS_FLUSH()

RETURN .T.

  