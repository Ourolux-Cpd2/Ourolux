#INCLUDE "Eictp253.ch"
#include "Average.ch"
//#include "FiveWin.ch"
                             
#define  Tit253       STR0001 //"DESEMBOLSO REALIZADO"
#define  MsgProc      STR0002 //"EM PROCESSAMENTO - AGUARDE..."
#define  MsgPesq      STR0003 //"PESQUISANDO DADOS - AGUARDE..."

#xtranslate :TIMES_NEW_ROMAN_00_11   => \[1\]
#xtranslate :TIMES_NEW_ROMAN_02_11   => \[2\]
#xtranslate :COURIER_NEW_01_40       => \[3\]
#xtranslate :COURIER_NEW_01_15       => \[4\]


*---------------------*
USER Function SvTP253()          
*---------------------*
LOCAL cDespSelo:=GetNewPar("MV_SELO"," ")
LOCAL WorkFile, WorkNTX2, WorkNTX3, nOldArea:=Select(),;
      MMes, MAno, TMes:=MONTH(dDataBase),;
      TAno:=YEAR(dDataBase), ind_dt, MMsg,lProcessa:=.T.


Private aStruct:={ { "WKFORN_N"   , "C" , 30 , 0 }  ,;   // fornecedor
                   { "WKVL_MOEDA" , "N" , 15 , 2 }  ,;   // valor na moeda
                   { "WKDT_VECTO" , "D" ,  8 , 0 }  ,;   // vencimento
                   { "WKTX_DI"    , "N" , 12 , 8 }  ,;   // taxa da DI
                   { "WKVLREALDI" , "N"  , 15 , 2 }  ,;  // valor em reais na data da DI
                   { "WKTX_HAWB"  , "N" , 12 , 8 }  ,;   // taxa de cambio
                   { "WKVLREALCA" , "N"  , 15 , 2 }  ,;  // valor em reais no cambio
                   { "WKBANCO_NO" , "C"  , 30 , 2 }  ,;  // nome do banco de fechamento
                   { "WKBANCO_AG" , "C"  , 20 , 2 }  ,;  // nome da agencia
                   { "WKDT_PAGTO" , "D" ,  8 , 0 }  ,;   // data pagamento
                   { "WKDESPESA"  , "C" ,  3 , 0 }  ,;
                   { "WKMOEDA"    , "C" ,  3 , 0 }  ,;
                   { "WKPO_NUM"   , "C" , 15 , 0 }  ,;
                   { "WKDESPDESC" , "C" , 30 , 0 } }

PRIVATE aHeader[0],nUsado:=0
PRIVATE TDT_I, TDT_F, MTipo:=1, MOrdem
PRIVATE cPONUM:= SPACE(LEN(SW2->W2_PO_NUM))
PRIVATE cHAWB:= SPACE(LEN(SW6->W6_HAWB))


WorkFile:=E_Create(aStruct,.T.)
DBUSEAREA(.T.,,WorkFile,"Work", .F.)

IndRegua("Work",WorkFile+OrdBagExt(),"WKFORN_N+WKDESPESA")

//WorkNTX2:=E_Create(aStruct,.F.)
//IndRegua("Work",WorkNTX2+OrdBagExt(),"WKDESPESA+DTOS(WKDT_PAGTO)+WK_HAWB")

SET INDEX TO (WorkFile+OrdBagExt())

SW7->(DBSETORDER(1))
SWD->(DBSETORDER(1))
SYT->(DBSETORDER(1))
SA2->(DBSETORDER(1))

DO WHILE .T.

  TImport:=""
  MTipo  :=1
  MOrdem :=1

  if ! TelaGets()
     Work->(E_EraseArq(WorkFile,WorkNTX2))     
     return
  endif

  Work->(__DBZAP())
  Work->(DBSETORDER(1))

  Sv253Grv(cHAWB)
  IF Work->(BOF()) .AND. Work->(EOF())                           
     HELP("",1,"AVG0000585") //"NÇO EXISTEM REGISTROS PARA CONSULTA"

     LOOP
  ENDIF

  DBSELECTAREA("Work")
  cTit:= "Relatório de Desembolso Realizado"
  
  U_SVTP253A()
  


ENDDO   
                                                         
*========================*
Static Function TelaGets()
*========================*
Local lRet  := .f.
Local nOpc := 0
Local bOk  := {|| nOpc:=1, oDlg:End() }
Local bCancel := {|| nOpc:=2, oDlg:End() }
Private oDlg

Begin Sequence
   
   DEFINE MSDIALOG oDlg TITLE "Selecionar PO" From 9, 0 To 30, 50 OF oMainWnd

      @ 20,05 SAY "Processo:" PIXEL  of oDlg
      @ 20,55 MSGET cHAWB SIZE 50,8 PICTURE AVSX3("W6_HAWB",6) PIXEL  F3 "SW6"  of oDlg
      
   ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,bOk,bCancel) CENTERED

   IF nOpc == 2
      return .f.
   ENDIF

	if alltrim(cHAWB) <> ALLTRIM(SW6->W6_HAWB)
	   if ! SW6->(DBSEEK(xfilial("SW6")+cHAWB))
	      msginfo("PROCESSO POSICIONADO INCORRETO.: " + SW6->W6_HAWB)
	      return .f.
	   endif
	endif
	


   
End Sequence

Return .t.

           
*---------------------------------*
STATIC FUNCTION Sv253Grv(cProcesso)
*---------------------------------*
LOCAL MSOMA:=0,MSELO:=0, MFOBREPRES:=0,cFilSB1 := xFilial("SB1"), I
LOCAL lTemSelo:= .F.
Local cForn_Cod2:= "" // TDF - 25/02/2011
Local cForn_Cod:= "" //SA2->A2_COD + " - " + Alltrim(SA2->A2_NREDUZ) // TDF - 13/08/2010 nopado por WFS

__cNomeBanco:= " "  
__cNomeAgen := " "
__cNomeFor:= " "

SWB->(DBSETORDER(1))
SWB->(DBSEEK(xfilial("SWB")+AVKey(cProcesso,"WB_HAWB")+"D"))
DO WHILE !SWB->(EOF()) .AND. ALLTRIM(SWB->WB_HAWB) == ALLTRIM(cProcesso) .AND. SWB->WB_PO_DI == "D"
   
   IF SWB->WB_TIPOTIT <> "INV"
      SWB->(DBSKIP())
      LOOP
   ENDIF
   __cNomeFor:= BusForn(SWB->WB_INVOICE)
   
   IF SA6->(DBSEEK(xfilial("SA6")+SWB->WB_BANCO+SWB->WB_AGENCIA))
      __cNomeBanco:= SA6->A6_NOME
      __cNomeAgen := SA6->A6_AGENCIA
   ELSE
      __cNomeBanco:= " "  
      __cNomeAgen := " "
   ENDIF

   nValorMoeda:= 0
   lVlCompensado:= .f.
   IF !EMPTY( SWB->WB_FOBMOE )
      nValorMoeda:= SWB->WB_FOBMOE
   ELSEIF ! EMPTY(SWB->WB_PGTANT)
      nValorMoeda:= SWB->WB_PGTANT
      lVlCompensado:= .t.      
   ENDIF

   SW9->(DBSETORDER(1))
   if SW9->(DBSEEK(xfilial("SW9") + SWB->WB_INVOICE))
      //  if SW9->W9_MOE_FOB $ "US$/USD"
      nTaxanaDI:= SW9->W9_TX_FOB
   else 
      nTaxanaDI:= 0
   endif                                                                                                           

   Work->( DBAPPEND() )
   Work->WKFORN_N   := __cNomeFor        // Nome do Fornecedor
   Work->WKVL_MOEDA := nValorMoeda  
   Work->WKDT_VECTO := SWB->WB_DT_VEN   // Data de Vencimento
   Work->WKTX_DI    := nTaxanaDI        // Taxa da DI
   Work->WKVLREALDI := nValorMoeda * nTaxanaDI   // Valor real na DI
   Work->WKTX_HAWB  := SWB->WB_CA_TX    // Taxa de Cambio
   Work->WKVLREALCA := nValorMoeda * SWB->WB_CA_TX     // Valor     
   Work->WKBANCO_NO := __cNomeBanco
   Work->WKBANCO_AG := __cNomeAgen
   Work->WKDT_PAGTO := SWB->WB_CA_DT   // data pagamento
   Work->WKDESPESA  := "101"           // FOB
   Work->WKMOEDA    := SWB->WB_MOEDA
   Work->WKDESPDESC := "FOB "
   
   SWB->(DBSKIP())
ENDDO


SWD->(DBSETORDER(1))
SWD->(DBSEEK(xfilial("SWD")+AVKEY(cProcesso,"WD_HAWB")))
DO WHILE !SWD->(EOF()) .AND. alltrim(SWD->WD_HAWB) == alltrim(cProcesso)
   
   IF SWD->WD_DESPESA == "101"
      SWD->(DBSKIP())
      LOOP
   ENDIF

   __cNomeFor:= " "
   SA2->(DBSETORDER(1))
   IF SA2->(DBSEEK(xfilial("SA2") + SWD->WD_FORN + SWD->WD_LOJA)) 
       __cNomeFor:= SA2->A2_NOME
   ENDIF

   __cMoeda:= SWD->WD_MOEDA
   if empty(SWD->WD_MOEDA) .and. subs(SWD->WD_DESPESA,1,1) <> "1"
      __cMoeda:= "R$"
   endif               
   
   __despdesc:= " "
   SYB->(DBSETORDER(1))
   if SYB->(DBSEEK(xfilial("SYB")+SWD->WD_DESPESA))
      __despdesc:= SYB->YB_DESCR
   endif
   
   Work->( DBAPPEND() )
   Work->WKFORN_N   := __cNomeFor        // Nome do Fornecedor
   Work->WKVL_MOEDA := SWD->WD_VALOR_R   // Valor em Real
   Work->WKDT_VECTO := SWD->WD_EMISSAO   // Data de Emissão
   Work->WKDESPESA  := SWD->WD_DESPESA   // Codigo da Despesa
   Work->WKMOEDA    := "R$"
   Work->WKDESPDESC := __despdesc                      
   SWD->(DBSKIP())
   
ENDDO   


RETURN

*-------------------------------*
STATIC FUNCTION BusForn(cInvoice)
*-------------------------------*
LOCAL cNomFor:=" "
SW9->(DBSETORDER(3)) // FILIAL + HAWB
SW9->(DBSEEK(xfilial("SW9")+cHAWB))

do while !SW9->(EOF()) .and. alltrim(SW9->W9_HAWB) == alltrim(cHAWB)
   if alltrim(SW9->W9_INVOICE) <> alltrim(cInvoice)
      SW9->(DBSKIP())
      LOOP
   endif  
   SA2->(DBSETORDER(1))
   if SA2->(DBSEEK(xfilial("SA2")+SW9->W9_FORN+SW9->W9_FORLOJ))
      cNomFor:= SA2->A2_NOME
   else
      cNomFor:= SW9->W9_NOM_FOR
   endif
   EXIT
enddo
   
RETURN cNomFor



