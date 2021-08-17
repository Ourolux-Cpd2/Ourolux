#INCLUDE "PROTHEUS.CH"
#INCLUDE "AVPRINT.CH"

*====================*
User Function SV557()
*====================*
SetPrvt("UVAR>,OPRINT>,OFONT>,ACLOSE,CALIASOLD,NOLDAREA")
SetPrvt("TB_CAMPOS,_PICTPO,_PICTPRTOT,_PICTPRUN,_PICTQTDE,_PICTITEM")
SetPrvt("CCADASTRO,CMARCA,LINVERTE,NUSADO,CARQF3SW2,CARQF3SYT")
SetPrvt("CARQF3SY4,CARQF3SYQ,CCAMPOF3SW2,CCAMPOF3SYT,CCAMPOF3SY4,CCAMPOF3SYQ")
SetPrvt("TPO_NUM,TIMPORT,TCONDPG,TDIASPG,TAGENTE,TTIPO_EMB")
SetPrvt("TNR_PRO,TID_PRO,TDT_PRO,TPAIS,NSPREAD,MTOTAL")
SetPrvt("AMSG,CPOINTS,ACAMPOS,AHEADER,STRUCT1,FILEWORK")
SetPrvt("PAGINA,ODLG,OFNTDLG,NLIN,NCOLS1,NCOLG1")
SetPrvt("NCOLS2,NCOLG2,NCOLS3,NCOLG3,NCOLG4,NCOLS4")
SetPrvt("NCOLS5,MFLAG,V,NOPCAO,BOK,BCANCEL")
SetPrvt("BINIT,CALIAS,NTIPOIMP,ARAD1,OMARK,NNETWEIGHT")
SetPrvt("MDESCRI,I,AVETOR,W,CENDSA2,LCOMISSAORETIDA")
SetPrvt("NVAL_COM,CNOMEBANCO,CPAYMENT,CEXPORTA,CFORN,DDATAATU")
SetPrvt("DDATASHIP,NLI_INI,NLI_FIM,NLI_FIM2,AFONTES,PARTE2")
SetPrvt("NLINHA,LBATEBOX,NLINPAY,")

#COMMAND E_RESET_AREA                      => SA5->(DBSETORDER(1)) ;

#xtranslate :TIMES_NEW_ROMAN_01_10   => \[1\]
#xtranslate :TIMES_NEW_ROMAN_02_16   => \[2\]
#xtranslate :COURIER_NEW_01_30       => \[3\]
#xtranslate :COURIER_NEW_01_10       => \[4\]
#xtranslate :COURIER_NEW_01_08       => \[5\]


#xtranslate   bSETGET(<uVar>)              => {|u| If(PCount() == 0, <uVar>, <uVar> := u) }
#xtranslate   AVPict(<Cpo>)                => AllTrim(X3Picture(<Cpo>))

Private cPONUM:= space(AVSX3("W2_PO_NUM",3))
Private _cPictPO:= AVSX3("W2_PO_NUM",6)
Private cObservacoes:= SPACE(200)

cAliasOld := Alias()
if TelaGets()
   SVPO557()
endif
dbSelectArea( cAliasOld )
Return(.T.)        
             

*========================*
Static Function TelaGets()
*========================*
Local lRet  := .f.
Local nOpc := 0
Local bOk  := {|| nOpc:=1, oDlg:End() }
Local bCancel := {|| oDlg:End() }
Private oDlg, oMemo

Begin Sequence
   
   DEFINE MSDIALOG oDlg TITLE "Selecionar PO" From 9, 0 To 30, 100 OF oMainWnd

      DEFINE FONT oFontAux  NAME "Courier New"        SIZE 05,30  


      //Pedido Inicial
      @ 20,05 SAY "Purchase Order:" PIXEL  of oDlg
      @ 20,55 MSGET cPONUM SIZE 40,8 PIXEL  F3 "SW2"  of oDlg
       
      @ 40,05 SAY "Observações...: " PIXEL of oDlg
      @ 40,55 GET oMemo VAR  cObservacoes MEMO SIZE 160,80 FONT oFontAux   PIXEL OF oDlg 

//      @ 40,55 GET oMemo VAR  cObservacoes MEMO SIZE 160,40 FONT oFontAux   PIXEL OF oDlg 
      
      
    //  @ 066,040 GET OMEMO ; 
    //      VAR CMEMO MEMO ; 
    //      SIZE 231,096 ; 
    //      PIXEL OF ODLG 
 
   ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,bOk,bCancel) CENTERED

   IF nOpc == 2
      return .f.
   ENDIF
   
End Sequence

if alltrim(cPONUM) <> ALLTRIM(SW2->W2_PO_NUM)
   if ! SW2->(DBSEEK(xfilial("SW2")+cPONUM))
      msginfo("PEDIDO POSICIONADO INCORRETO.: " + SW2->W2_PO_NUM)
      return .f.
   endif
endif

Return .t.



*-----------------------*
Static Function SVPO557()
*-----------------------*
LOCAL cMoeDolar:=GETMV("MV_SIMB2",,"US$")
PRIVATE oPanel  //LRL 19/03/04
nOldArea := SELECT()
TB_Campos:= {}
_PictPO   :=ALLTRIM(X3Picture("W2_PO_NUM" ))
_PictPrTot:="@E 9,999,999.999"
_PictPrUn :=ALLTRIM(X3Picture("W3_PRECO"  ))
_PictQtde :=ALLTRIM(X3Picture("W3_QTDE"   ))
_PictItem :=ALLTRIM(X3Picture("B1_COD"    ))

cCadastro     := "Emissão da Proforma"
cMarca        := GetMark()
lInverte      := .F.
nUsado        := 0
cArqF3SW2     := "SW2"
cArqF3SYT     := "SYT"
cArqF3SY4     := "SY4"
cArqF3SYQ     := "SYQ"
cCampoF3SW2   := "W2_PO_NUM"
cCampoF3SYT   := "YT_COD"
cCampoF3SY4   := "Y4_COD"
cCampoF3SYQ   := "YQ_VIA"
TImport       := SW2->W2_IMPORT
TCondPg       := SW2->W2_COND_PA
TDiasPg       := SW2->W2_DIAS_PA
TAgente       := SW2->W2_AGENTE
TTipo_Emb     := SW2->W2_TIPO_EM
TId_Pro       := "P"
TDt_Pro       := SW2->W2_DT_PRO
nSpread       := 0
MTotal        := 0
aMsg          := {}
cMsg1         := Space(45)
cMsg2         := Space(45)
cMsg3         := Space(45)
cMsg4         := Space(45)
cMsg5         := Space(45)

TNr_Pro       := SW2->W2_NR_PRO

SA2->(DBSETORDER(1))
SA2->(DBSEEK(xFilial("SA2")+SW2->W2_FORN))
SYA->(DBSETORDER(1))
SYA->(DBSEEK(xFilial("SYA")+SA2->A2_PAIS))
TPais:=ALLTRIM(SYA->YA_DESCR)+SPACE(10)

SA5->(DBSETORDER(3))
Processa({|| SV557_REL()},"Processando relatório") //"Processando Relatorio..."

E_RESET_AREA
RETURN .T.


*--------------------------*
Static FUNCTION SV557_REL()
*--------------------------*
LOCAL cMoeDolar:=GETMV("MV_SIMB2",,"US$"), W, I
LOCAL nProfTot:= 0  
LOCAL nPesoPO:= 0 
LOCAL nFreteProf:= 0 
LOCAL nInlandProf:= 0 
LOCAL nPackingProf:= 0 
LOCAL nDiscount:= 0
nNetWeight := 0
mDescri    := ""
I          := 0
aVetor     := {}
W          := 0
cEndSA2    := ""
lComissaoRetida:=.F.                   
nVal_Com   := SW2->W2_VAL_COM
cNomeBanco := ""
Pagina:=0
nLinha:=0
nTaxaRel:=1//BuscaTaxa(SW2->W2_MOEDA,SW2->W2_DT_PAR)// AWR - 28/06/2006 - A proforma tem que ser na moeda do Pedido e nao em Reais
SY6->(DBSEEK(xFilial("SY6")+TCondPg+STR(TDiasPg,3,0)))

cPayment:=""
cPayment:=MSMM(SY6->Y6_DESC_I ,48 )
STRTRAN(cPayment,CHR(13)+CHR(10)," ")

SYT->(DBSETORDER(1))
SYT->(DBSEEK(xFilial("SYT")+TImport))



SW3->(DBSEEK(xFilial("SW3")+cPONUM))
IF EMPTY(SW2->W2_EXPORTA)
   cEXPORTA:=SW2->W2_FORN + SW2->W2_FORLOJ
ELSE
   cEXPORTA:=SW2->W2_EXPORTA
ENDIF

cFORN    :=SW2->W2_FORN
cLoja    :=SW2->W2_FORLOJ
dDataAtu :=TDt_Pro
dDataShip:=SW3->W3_DT_EMB
nLi_Ini  := 0
nLi_Fim  := 0
nLi_Fim2 := 0

PRINT oPrn NAME " "
 oPrn:SetPortrait()
ENDPRINT

AVPRINT oPrn NAME "Proforma Invoice"
   oPrn:Rebuild()

   DEFINE FONT oFont1  NAME "Times New Roman"    SIZE 1,10          OF oPrn
   DEFINE FONT oFont2  NAME "Times New Roman"    SIZE 2,16          OF oPrn
   DEFINE FONT oFont3  NAME "Courier New"        SIZE 1,30  ITALIC  of oPrn
   DEFINE FONT oFont4  NAME "Courier New"        SIZE 1,10  ITALIC  of oPrn
   DEFINE FONT oFont5  NAME "Courier New"        SIZE 1,08  ITALIC  OF oPrn

   aFontes := { oFont1, oFont2, oFont3, oFont4, oFont5 }

   AVPAGE

        IncProc("Imprimindo...")

        PO557CAB_INI()

        nLi_Ini:=nLinha

        PO557_CAB2()
        nNetWeight  := 0 
        __nNetWeight:=0
        __nXQTDEM1  := 0
        __nXQTDITEMS:= 0
        WHILE !SW3->(EOF()) .AND. SW3->W3_FILIAL==xFilial("SW3") .AND. ;
                                  SW3->W3_PO_NUM==cPONUM
           IF SW3->W3_SEQ <> 0
              SW3->(DBSKIP())
              LOOP
           ENDIF

           nNetWeight :=  (SW3->W3_QTDE*B1Peso(SW3->W3_CC,SW3->W3_SI_NUM,SW3->W3_COD_I,SW3->W3_REG,SW3->W3_FABR,SW3->W3_FORN))
           __nNetWeight += nNetWeight
           __nXQTDEM1 +=  SW3->W3_XQTDEM1
           __nXQTDITEMS += SW3->W3_QTDE
           
           IncProc("Imprimindo...")
           SysRefresh()
           PARTE2:=1
           PO557VERFIM()
           SB1->(DBSEEK(xFilial("SB1")+SW3->W3_COD_I))
           SA5->(DBSEEK(xFilial("SA5")+SW3->W3_COD_I+SW3->W3_FABR+SW3->W3_FORN))
           SYG->(DBSEEK(xFilial("SYG")+SW2->W2_IMPORT+SW3->W3_FABR+SW3->W3_COD_I))

           nPesoPO+= val(trans(SW3->W3_QTDE*B1Peso(SW3->W3_CC,SW3->W3_SI_NUM,SW3->W3_COD_I,SW3->W3_REG,SW3->W3_FABR,SW3->W3_FORN),"99999999999.999"))
           mDescri := ALLTRIM(MSMM( SB1->B1_DESC_I,36))
           STRTRAN(mDescri,CHR(13)+CHR(10)," ")

           nLinha+= 10
           oPrn:Say( nLinha,450  ,TRANS(SW3->W3_COD_I,AVSX3("W3_COD_I",6)),aFontes:COURIER_NEW_01_10,,,,1 )
           oPrn:Say( nLinha,280  ,MEMOLINE(mDescri,27,1),aFontes:COURIER_NEW_01_10)
           oPrn:Say( nLinha,940  ,trans(nNetWeight,  "@E 999,999.999"),aFontes:COURIER_NEW_01_10) 
           oPrn:Say( nLinha,1470 ,trans(SW3->W3_QTDE, AVSX3("W3_QTDE",6)),aFontes:COURIER_NEW_01_10,,,,1)
           oPrn:Say( nLinha,1660 ,trans(SW3->W3_XCUBAGE, AVSX3("W3_XCUBAGE",6)),aFontes:COURIER_NEW_01_10,,,,1)
           oPrn:Say( nLinha,1780 ,trans(SW3->W3_XQTDEM1, AVSX3("W3_XQTDEM1",6)),aFontes:COURIER_NEW_01_10,,,,1)
           oPrn:Say( nLinha,2000 ,trans(SW3->W3_PRECO ,"@E 999.999"),aFontes:COURIER_NEW_01_10,,,,1)
           oPrn:Say( nLinha,2360 ,trans(SW3->W3_PRECO * SW3->W3_QTDE,"@E 999,999.999"  ),aFontes:COURIER_NEW_01_10,,,,1)
           

           FOR W:=2 TO (LEN(mDescri)/27)+1
               SysRefresh()
               IF ! EMPTY(memoline(mDescri,27,W))
                  PARTE2:=2
                  PO557VERFIM()
                  oPrn:Say( nLinha:=nLinha+50,280  ,memoline(mDescri,27,W),aFontes:COURIER_NEW_01_10,,,1)
               ENDIF
           NEXT

           SysRefresh()
           PARTE2:=2
           PO557VERFIM()
           nLinha+=50
           oPrn:Box( nLi_Ini , 110 , nLinha , 110  )
           oPrn:Box( nLi_Ini , 250 , nLinha , 250  )
           oPrn:Box( nLi_Ini , 900, nLinha , 900 )
           oPrn:Box( nLi_Ini , 1200, nLinha , 1200 )
           oPrn:Box( nLi_Ini , 1480, nLinha , 1480 )
           oPrn:Box( nLi_Ini , 1670, nLinha , 1670 )
           oPrn:Box( nLi_Ini , 1810, nLinha , 1810 )
           oPrn:Box( nLi_Ini , 2040, nLinha , 2040 )
           oPrn:Box( nLi_Ini , 2360, nLinha , 2360 )

           SysRefresh()
           IF ASCAN(aVetor,SW3->W3_FABR +SW3->W3_FABLOJ ) == 0
              AADD(aVetor,SW3->W3_FABR+SW3->W3_FABLOJ)
           ENDIF
           SW3->(DBSKIP())
        END

        SysRefresh()
        PARTE2:=2
        lBateBox:=.F.
        IF ! PO557VERFIM()
           oPrn:Line(nLinha            , 110, nLinha  , 2360 )
        ENDIF

        nLinha+= 50
        oPrn:Say( nLinha, 1300  ,"SUB TOTAL" ,aFontes:COURIER_NEW_01_10) //"SUB TOTAL "
        oPrn:Say( nLinha, 2330 ,trans(nProfTot*nTaxaRel,"@E 999,999,999.999"),aFontes:COURIER_NEW_01_10,,,,1)
        
        PARTE2:=2
        lBateBox:=.F.
        PO557VERFIM()         
        oPrn:Say( nLinha+50, 1300,"INTERNATIONAL FREIGHT",aFontes:COURIER_NEW_01_10) //"INTERNATIONAL FREIGHT"
        oPrn:Say( nLinha+50, 2330,trans(SW2->W2_FRETEIN* nTaxaRel,"@E 999,999,999.999"),aFontes:COURIER_NEW_01_10,,,,1)
        
        PARTE2:=2
        lBateBox:=.F.
        PO557VERFIM()   
        oPrn:Say( nLinha+100, 1300 ,"DISCOUNT ",aFontes:COURIER_NEW_01_10) //"DISCOUNT"
        oPrn:Say( nLinha+100, 2330 ,trans(SW2->W2_DESCONT* nTaxaRel,"@E 999,999,999.999"),aFontes:COURIER_NEW_01_10,,,,1)
        
        PARTE2:=2
        lBateBox:=.F.
        PO557VERFIM()          
        oPrn:Say( nLinha+170, 1300,"TOTAL  "+SW2->W2_INCOTER + "(" + SW2->W2_MOEDA + ")" ,aFontes:COURIER_NEW_01_10) //"TOTAL "

        IF AVRETINCO(SW2->W2_INCOTER,"CONTEM_FRETE") 
           If SW2->W2_FREINC == "1" 
              oPrn:Say( nLinha+170,2330,trans((SW2->W2_FOB_TOT - SW2->W2_DESCONT)* nTaxaRel,"@E 999,999,999.999"),aFontes:COURIER_NEW_01_10,,,,1)
           Else
              oPrn:Say( nLinha+170,2330 ,trans((SW2->W2_FOB_TOT+SW2->W2_FRETEIN+SW2->W2_INLAND+SW2->W2_PACKING-SW2->W2_DESCONT)* nTaxaRel,"@E 999,999,999.999"),aFontes:COURIER_NEW_01_10,,,,1)
           EndIf
        ELSE 
           oPrn:Say( nLinha+170,2330,trans((SW2->W2_FOB_TOT - SW2->W2_DESCONT)* nTaxaRel,"@E 999,999,999.999" ),aFontes:COURIER_NEW_01_10,,,,1)
        ENDIF   

        nLi_Fim2:=(nLinha+300)

        SysRefresh()                   
        lBateBox:=.F.
        PO557VERFIM()

        PARTE2:=0
        PO557VERFIM()
        oPrn:Say( nLinha+20 ,110  ,"NET WEIGHT: ",aFontes:COURIER_NEW_01_10) //"NET WEIGHT: "
        oPrn:Say( nLinha+20 ,550  ,trans(__nNetWeight,"@E 99,999,999.999")+" KGS",aFontes:COURIER_NEW_01_10) //"NET WEIGHT: "

        PARTE2:=0
        PO557VERFIM()
        oPrn:Say( nLinha+70 ,110  ,"GROSS WEIGHT: " ,aFontes:COURIER_NEW_01_10) //"NET WEIGHT: "
        oPrn:Say( nLinha+70 ,550  ,trans(SW2->W2_PESO_B,"@E 99,999,999.999")+" KGS",aFontes:COURIER_NEW_01_10) //"NET WEIGHT: "

        PARTE2:=0
        PO557VERFIM()
        oPrn:Say( nLinha+120,110  ,"TOTAL QTY PIECES : " ,aFontes:COURIER_NEW_01_10) //"NET WEIGHT: "
        oPrn:Say( nLinha+120,550  ,trans(__nXQTDITEMS,"@E 99,999,999.999"),aFontes:COURIER_NEW_01_10) //"NET WEIGHT: "

        PARTE2:=0
        PO557VERFIM()
        oPrn:Say( nLinha+170 ,110  ,"TOTAL CBM : " ,aFontes:COURIER_NEW_01_10) //"NET WEIGHT: "
        oPrn:Say( nLinha+170 ,550  ,trans(SW2->W2_MT3,"@E 99,999,999.999"),aFontes:COURIER_NEW_01_10) //"NET WEIGHT: "

        PARTE2:=0
        PO557VERFIM()
        oPrn:Say( nLinha+220 ,110  ,"TOTAL BOXES : " ,aFontes:COURIER_NEW_01_10) //"NET WEIGHT: "
        oPrn:Say( nLinha+220 ,550  ,trans(__nXQTDEM1,"@E 99,999,999.999"),aFontes:COURIER_NEW_01_10) //"NET WEIGHT: "


        nLinha+= 310

        PARTE2:=0
        PO557VERFIM()

        oPrn:Line( nLinha, 110, nLinha, 2400) 
        nLinha+=45
        oPrn:Say( nLinha ,110  ,"PRODUCER(S)/EXPORTER" ,aFontes:COURIER_NEW_01_10) //"PRODUCER(S)"
        nLinha += 20
        FOR I:=1 TO LEN(aVetor)
            SysRefresh()
            SA2->(DBSEEK(xFILIAL("SA2")+aVetor[I]))
			SYA->(DBSETORDER(1))
			if SYA->(DBSEEK(xFilial("SYA")+SA2->A2_PAIS))
			   cPaisForn:= SYA->YA_PAIS_I
		    else
			   cPaisForn:= SPACE(10)
			endif
		
            PARTE2:=0
            PO557VERFIM()
            oPrn:Say( nLinha:=nLinha+70 ,110  ,SA2->A2_NOME ,aFontes:COURIER_NEW_01_10)
            PARTE2:=0
            PO557VERFIM()
            oPrn:Say( nLinha:=nLinha+50 ,110  ,SA2->A2_END,aFontes:COURIER_NEW_01_10 )
            PARTE2:=0
            PO557VERFIM()
            oPrn:Say( nLinha:=nLinha+50 ,110  ,SA2->A2_BAIRRO,aFontes:COURIER_NEW_01_10 )
            PARTE2:=0
            PO557VERFIM()
            oPrn:Say( nLinha:=nLinha+50 ,110  ,ALLTRIM(SA2->A2_MUN)+" / "+SA2->A2_ESTADO ,aFontes:COURIER_NEW_01_10)
			PARTE2:=0
            PO557VERFIM()
            oPrn:Say( nLinha:=nLinha+50 ,110  ,cPaisForn,aFontes:COURIER_NEW_01_10)            
            
            PARTE2:=0
            PO557VERFIM()
        NEXT


        SA2->(DBSEEK(xFilial("SA2")+cFORN+cLoja))
        PARTE2:=0
        PO557VERFIM()

		W:=1 
		cObservacoes:= alltrim(cObservacoes)
		nLinPay := MLCOUNT(cObservacoes,100,1,.t.)
		nLinha+=60
		WHILE nLinPay > 0
            __auxLinha:= memoline(cObservacoes,100,w)
		   IF !EMPTY(__auxLinha)
		      oPrn:Say( nLinha, 110 ,__auxLinha ,aFontes:COURIER_NEW_01_10 )
		      nLinha:=nLinha+50
		   ENDIF
		   W:=W+1 
		   nLinPay -= 1
		END

        PARTE2:=0
        PO557VERFIM()
        oPrn:Say( nLinha:=nLinha+90 ,110 , "THE INDICATED PRICES ARE THE CURRENT PRICES FOR EXPORT.", aFontes:COURIER_NEW_01_10) //"THE INDICATED PRICES ARE THE CURRENT PRICES FOR EXPORT."
        PARTE2:=0
        PO557VERFIM()
        oPrn:Say( nLinha:=nLinha+50 ,110 , "WE STATE ALSO THAT THERE ARE NO CATALOGS OR PRICE LISTS.", aFontes:COURIER_NEW_01_10) //"WE STATE ALSO THAT THERE ARE NO CATALOGS OR PRICE LISTS."
        
        //ISS - 21/05/10 - Inclusão do valor total em "extenso", por exemplo, 100R$ -> Cem reais
        PARTE2:=0
        PO557VERFIM()

        IF nLinha >= 2800
           AVNEWPAGE
           PO557CAB_INI()
        ENDIF
        SA2->(DBSEEK(xFilial("SA2")+cEXPORTA))
        cEndSA2 := ""
        cEndSA2 := cEndSA2+IF( !EMPTY(SA2->A2_END)    , ALLTRIM(SA2->A2_END)+", "+ALLTRIM(SA2->A2_NR_END)+" - ", " " )
        cEndSA2 := cEndSA2+IF( !EMPTY(SA2->A2_BAIRRO) , ALLTRIM(SA2->A2_BAIRRO) +" - ", "" )
        cEndSA2 := cEndSA2+IF( !EMPTY(SA2->A2_MUN)    , ALLTRIM(SA2->A2_MUN)    +" / ", "" )
        cEndSA2 := cEndSA2+IF( !EMPTY(SA2->A2_ESTADO) , ALLTRIM(SA2->A2_ESTADO) +"   ", " " )
        cEndSA2 := LEFT( cEndSA2, LEN(cEndSA2)-2 )

        oPrn:Say( nLinha:=nLinha+120,1120 , ALLTRIM(SA2->A2_NOME) ,aFontes:COURIER_NEW_01_10,,,,2)
        oPrn:Say( nLinha:=nLinha+50 ,1120 , "Correspondence Address",aFontes:COURIER_NEW_01_10,,,,2) //"Correspondence Address"
        oPrn:Say( nLinha:=nLinha+50 ,1120 , cEndSA2,aFontes:COURIER_NEW_01_10,,,,2)

        IncProc("Imprimindo...")
        
                                
   AVENDPAGE

AVENDPRINT

oFont1:End()
oFont2:End()

RETURN NIL

*----------------------------*
Static FUNCTION PO557CAB_INI()
*----------------------------*
nLinha:=100
Pagina:=Pagina+1
cLogo:= " "
cBankNome:= space(10)   
cBankAge := space(10)
cBankEnd := space(10)
cBankCity:= space(10)  
cBankSWIFT:= space(10)
cBankCONTA:= space(10)
cPaisForn:= space(10)
cPaisImp:= space(10)

SYA->(DBSETORDER(1))
if SYA->(DBSEEK(xFilial("SYA")+SYT->YT_PAIS))
   cPaisImp:= SYA->YA_PAIS_I
endif

SA2->(DBSETORDER(1))      
lRetangulo:= .f.
IF SA2->(DBSEEK(xFilial("SA2")+cFORN+cLoja))
   cLogo:= "\LOGOSFORN\"+ALLTRIM(SA2->A2_XLOGO)
   if SUBST(ALLTRIM(SA2->A2_XLOGO),1,1) == "R"
      lRetangulo:= .t. 
   endif   
   cBankNome:= SA2->A2_XBANCO 
   cBankAge := SA2->A2_XAGENC
   cBankEnd := SA2->A2_XENDBAN
   cBankCity:= SA2->A2_XCIDBAN
   cBankSWIFT:= SA2->A2_SWIFT   
   cBankCONTA:= SA2->A2_XCTABAN
	SYA->(DBSETORDER(1))
	if SYA->(DBSEEK(xFilial("SYA")+SA2->A2_PAIS))
	   cPaisForn:= SYA->YA_PAIS_I
    endif
endif   

if lRetangulo
   oPrn:SayBitmap(nLinha-30,0100,cLogo,0550,0300)       
else 
   oPrn:SayBitmap(nLinha-40,0100,cLogo,0280,0280)       
endif
oPrn:Say( nLinha+020, 0900,"PROFORMA INVOICE", aFontes:COURIER_NEW_01_30 ) //"PROFORMA INVOICE"

oPrn:Say( nLinha+250 , 250  , "SHIPPER" , aFontes:COURIER_NEW_01_10 )
oPrn:Say( nLinha+300 , 125  , alltrim(SA2->A2_NOME) , aFontes:COURIER_NEW_01_08 )
oPrn:Say( nLinha+350 , 130  , alltrim(SA2->A2_END) + "-" + alltrim(SA2->A2_NR_END) + " ",aFontes:COURIER_NEW_01_08 )
oPrn:Say( nLinha+400 , 130  , alltrim(SA2->A2_BAIRRO),aFontes:COURIER_NEW_01_08 )
oPrn:Say( nLinha+400 , 450  , ALLTRIM(SA2->A2_ESTADO),aFontes:COURIER_NEW_01_08 ) 
oPrn:Say( nLinha+450 , 130  , cPaisForn,aFontes:COURIER_NEW_01_08 ) 
oPrn:Say( nLinha+450 , 450  , SA2->A2_DDI + " " + SA2->A2_DDD + " " + SA2->A2_TEL,aFontes:COURIER_NEW_01_08 ) 



oPrn:Say( nLinha+250 , 1100  , "CONSIGNEE" , aFontes:COURIER_NEW_01_10 )
oPrn:Say( nLinha+300 , 1025  , alltrim(SYT->YT_NOME) , aFontes:COURIER_NEW_01_08 )
oPrn:Say( nLinha+350 , 1025  , TRANS(alltrim(SYT->YT_CGC),AVSX3("YT_CGC",6))  , aFontes:COURIER_NEW_01_08 )
oPrn:Say( nLinha+400 , 1025  , alltrim(SYT->YT_ENDE) + " - " + alltrim(SYT->YT_NR_END) + " " + SYT->YT_CEP,aFontes:COURIER_NEW_01_08 )
oPrn:Say( nLinha+450 , 1025  , alltrim(SYT->YT_BAIRRO) + "-" + ALLTRIM(SYT->YT_ESTADO)+ " - " + cPaisImp  ,aFontes:COURIER_NEW_01_08 )
oPrn:Say( nLinha+500 , 1025  , alltrim(SYT->YT_TEL_IMP)  ,aFontes:COURIER_NEW_01_08 )

oPrn:Say( nLinha+300 , 2050 , "Prof.: "                     ,aFontes:COURIER_NEW_01_08 ) //"Nro. Prof."
oPrn:Say( nLinha+300 , 2150 , TNr_Pro                       ,aFontes:COURIER_NEW_01_08 ) //"Nro. Prof."
oPrn:Say( nLinha+360 , 2050 , "REF.: "+SW2->W2_PO_NUM       ,aFontes:COURIER_NEW_01_08 ) //"REF.: "
oPrn:Say( nLinha+420 , 2050 , "DATE: "+ DTOC(SW2->W2_PO_DT) ,aFontes:COURIER_NEW_01_08) //"DATE: "

nLinha+= 550

SYA->(DBSETORDER(1))
if SYA->(DBSEEK(xFilial("SYA")+SA2->A2_PAIS))
   __cYA_NOIDIOM:= SYA->YA_NOIDIOM
else
   __cYA_NOIDIOM:= "No Information"
endif

SY9->(DBSETORDER(2))         
IF SY9->(DBSEEK(xFilial("SY9")+ SW2->W2_ORIGEM))
   __cOrign:= SY9->Y9_DESCR
ELSE
   __cOrign:= "NO Information"
ENDIF

IF SY9->(DBSEEK(xFilial("SY9")+ SW2->W2_DEST))
   __cDischarge:= SY9->Y9_DESCR
ELSE                        
   __cDischarge:= "NO Information"
ENDIF
SY9->(DBSETORDER(1))

SYQ->(DBSETORDER(1))
if SYQ->(DBSEEK(xfilial("SYQ")+SW2->W2_TIPO_EM))
   __cModal:= SYQ->YQ_DESCR
else
   __cModal:= SPACE(10)
endif  


oPrn:Line( nLinha, 110, nLinha, 2500)

nLinha+= 50  
oPrn:Say( nLinha   , 110 , "PORT OF ORIGIN: " ,aFontes:COURIER_NEW_01_10 ) //"SHIPPING DATE: "
oPrn:Say( nLinha   , 500 ,  __cOrign,aFontes:COURIER_NEW_01_10 ) //"SHIPPING DATE: "

oPrn:Say( nLinha+40, 110 , "PORT OF DISCHARGE: ",aFontes:COURIER_NEW_01_10 ) //"DISCHARGE PORT.: "
oPrn:Say( nLinha+40, 500 ,  __cDischarge,aFontes:COURIER_NEW_01_10 ) //"DISCHARGE PORT.: "

oPrn:Say( nLinha+80, 110 , "MODAL: " ,aFontes:COURIER_NEW_01_10 ) //"DISCHARGE PORT.: "
oPrn:Say( nLinha+80, 500 ,  __cModal,aFontes:COURIER_NEW_01_10 ) //"DISCHARGE PORT.: "

oPrn:Say( nLinha, 1000 , "SHIPPING DATE: "   + dtoc(dDataShip),aFontes:COURIER_NEW_01_10 ) //"SHIPPING DATE: "
oPrn:Say( nLinha, 1600 , "DT ETD.:  " + DTOC(SW2->W2_XDT_ETD) ,aFontes:COURIER_NEW_01_10 ) 
oPrn:Say( nLinha, 2000 , "DT ETA.:  " + DTOC(SW2->W2_XDT_ETA) ,aFontes:COURIER_NEW_01_10 ) 

nLinha+= 150
oPrn:Say( nLinha    , 110, "BANK NAME.:   " ,aFontes:COURIER_NEW_01_10 ) 
oPrn:Say( nLinha    , 360,  cBankNome,aFontes:COURIER_NEW_01_10 ) 

oPrn:Say( nLinha+40 , 110, "AGENCY.:   " ,aFontes:COURIER_NEW_01_10 ) 
oPrn:Say( nLinha+40 , 360,  cBankAge,aFontes:COURIER_NEW_01_10 ) 

oPrn:Say( nLinha+80 , 110, "ADRESS.:   " ,aFontes:COURIER_NEW_01_10 ) 
oPrn:Say( nLinha+80 , 360,  cBankEnd,aFontes:COURIER_NEW_01_10 ) 

oPrn:Say( nLinha+120, 110, "CITY.:   " ,aFontes:COURIER_NEW_01_10 ) 
oPrn:Say( nLinha+120, 360,  cBankCity,aFontes:COURIER_NEW_01_10 ) 

oPrn:Say( nLinha+160, 110, "SWIFT.:   " ,aFontes:COURIER_NEW_01_10 ) 
oPrn:Say( nLinha+160, 360,  cBankSWIFT,aFontes:COURIER_NEW_01_10 ) 

oPrn:Say( nLinha+200, 110, "ACCOUNT:   " ,aFontes:COURIER_NEW_01_10 ) 
oPrn:Say( nLinha+200, 360, cBankCONTA,aFontes:COURIER_NEW_01_10 ) 

oPrn:Say( nLinha, 1450 , "PAYMENT: ",aFontes:COURIER_NEW_01_10 ) //"PAYMENT:"
W:=1
nLinPay := 0
WHILE nLinPay <= 6 .AND. W <= MLCOUNT(cPayment,30)
   IF !EMPTY(memoline(cPayment,30,W))
      oPrn:Say( nLinha, 1700 , memoline(cPayment,30,W),aFontes:COURIER_NEW_01_10 )
      nLinPay:=nLinPay+1
      nLinha:=nLinha+50
   ENDIF
   W:=W+1
END
oPrn:Say( nLinha, 1450 , "INCOTERM:  "  + SW2->W2_INCOTER  ,aFontes:COURIER_NEW_01_10 ) //"PAYMENT:"
nLinha+=200

oSend( oPrn, "Say",  3100 ,1600,alltrim(SYT->YT_NOME),aFontes:COURIER_NEW_01_10 ) //"Page.:"
oSend( oPrn, "Say",  3300 ,1900, "Page.: "+STR(PAGINA,8),aFontes:COURIER_NEW_01_10 ) //"Page.:"


RETURN NIL


*----------------------------*
Static FUNCTION PO557_CAB2()
*----------------------------*
SysRefresh()
//oPrn:Line(nLinha            , 110, nLinha  , 3500 )
//oPrn:Line( nLinha+1,  110, nLinha+1, 2240 )
//oPrn:Box( nLinha            , 110  , nLinha+60 , 111 )
//oPrn:Box( nLinha            , 370  , nLinha+60 , 371  )
//oPrn:Box( nLinha            , 1400 , nLinha+60 , 1401 )
//oPrn:Box( nLinha            , 1750 , nLinha+60 , 1751 )
//oPrn:Box( nLinha            , 2240 , nLinha+60 , 2241 )

oPrn:Box( nLinha            , 110  , nLinha+105 , 2360 )
nLinha+=10
oPrn:Say( nLinha, 150  ,"CODE"        ,aFontes:COURIER_NEW_01_10 ) 
oPrn:Say( nLinha, 500  ,"DESCRIPTION" ,aFontes:COURIER_NEW_01_10 ) 
oPrn:Say( nLinha, 1000 ,"NET"         ,aFontes:COURIER_NEW_01_10 ) 
oPrn:Say( nLinha, 1260 ,"QTY "        ,aFontes:COURIER_NEW_01_10 ) 
oPrn:Say( nLinha, 1530 ,"CBM"         ,aFontes:COURIER_NEW_01_10 ) 
oPrn:Say( nLinha, 1680 ,"BOXES"       ,aFontes:COURIER_NEW_01_10 ) 
oPrn:Say( nLinha, 1830 ,"UNIT "       ,aFontes:COURIER_NEW_01_10 ) 
oPrn:Say( nLinha, 2160 ,"TOTAL"       ,aFontes:COURIER_NEW_01_10 ) 

oPrn:Say( nLinha+50, 1000 ,"WEIGHT"      ,aFontes:COURIER_NEW_01_10 ) 
oPrn:Say( nLinha+50, 1260 ,"PIECES"      ,aFontes:COURIER_NEW_01_10 ) 
oPrn:Say( nLinha+50, 1830 ,"PRICE " + SW2->W2_MOEDA      ,aFontes:COURIER_NEW_01_10 ) 
oPrn:Say( nLinha+50, 2160 ,"PRICE " + SW2->W2_MOEDA      ,aFontes:COURIER_NEW_01_10 ) 

nLinha+=105
SysRefresh()
RETURN NIL

*------------------------------*
Static FUNCTION PO557VERFIM()
*------------------------------*
lBateBox:=IF(lBateBox=NIL,.T.,.F.)
SysRefresh()
IF nLinha >= 2900
   IF PARTE2 > 0
      IF PARTE2 == 1
         nLi_Fim2:=nLinha
      ELSE
         nLi_Fim2:=(nLinha+50)
         nLi_Fim:=0
      ENDIF
      PO557FIM()
   ENDIF

   SysRefresh()
   AVNEWPAGE

   PO557CAB_INI()

   IF PARTE2 > 0
      nLi_Fim:=nLi_Fim2:=nLi_Ini:=nLinha
      PO557_CAB2()
   ENDIF
   RETURN .T.
ENDIF
RETURN .F.



*--------------------------*
Static FUNCTION PO557FIM()
*--------------------------*
lBateBox:=IF(lBateBox==NIL,.T.,lBateBox)
IF lBateBox
   oPrn:Box( nLi_Ini , 370 , IF(nLi_Fim==0,nLi_Fim2,nLi_Fim) , 373  )
   oPrn:Box( nLi_Ini , 1400, IF(nLi_Fim==0,nLi_Fim2,nLi_Fim) , 1403 )
ENDIF
nLinha+=50
oPrn:Box( nLi_Ini , 110 , nLinha , 110  )
oPrn:Box( nLi_Ini , 250 , nLinha , 250  )
oPrn:Box( nLi_Ini , 900, nLinha ,  900 )
oPrn:Box( nLi_Ini , 1200, nLinha , 1200 )
oPrn:Box( nLi_Ini , 1480, nLinha , 1480 )
oPrn:Box( nLi_Ini , 1670, nLinha , 1670 )
oPrn:Box( nLi_Ini , 1810, nLinha , 1810 )
oPrn:Box( nLi_Ini , 2040, nLinha , 2040 )      
oPrn:Box( nLi_Ini , 2360, nLinha , 2360 )      

oPrn:Line(nLinha, 110, nLinha  , 2500 )

RETURN NIL

