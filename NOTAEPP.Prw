#IFNDEF WINDOWS
   #DEFINE PSAY SAY
#ENDIF
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³  Nfiscal ³ Autor ³Airton Lira            ³ Data ³03/10/2000³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Nota Fiscal de Saida                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Eletromega                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
#Include "rwmake.ch"

User Function NOTAEPP

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros                         ³
//³ mv_par01             // Da Nota Fiscal                       ³
//³ mv_par02             // Ate a Nota Fiscal                    ³
//³ mv_par03             // Da Serie                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE  CbTxt :=""
PRIVATE CbCont :=""
PRIVATE xCfo   :=""
PRIVATE nOrdem :=0
PRIVATE   Alfa := 0
PRIVATE       Z:=0
PRIVATE       M:=0
PRIVATE tamanho:="M"
PRIVATE limite :=180
PRIVATE titulo :=PADC("MEGA01 - Nota Fiscal ",74)
PRIVATE cDesc1 :=PADC("Este programa ira emitir a Nota Fiscal de Entrada/Saida",74)
PRIVATE cDesc2 :=""
PRIVATE cDesc3 :=PADC("da EletroMega.                                         ",74)
PRIVATE cNatureza:=""
PRIVATE aReturn := { "Especial", 1,"Administracao", 2, 2, 1,"",0 }
PRIVATE nomeprog:="MEGA01"
PRIVATE cPerg:=PadR("NFSIGW",10)
PRIVATE nLastKey  := 0
PRIVATE lContinua := .T.
PRIVATE nLin      :=0
PRIVATE wnrel     := "MEGA01"
PRIVATE xDescRg   := ""

Pergunte(cPerg,.F.)               // Pergunta no SX1

PRIVATE cString:="SF2"

wnrel:=SetPrint(cString,wnrel,cPerg,Titulo,cDesc1,cDesc2,cDesc3,.T.)
If nLastKey == 27
   Return
Endif

SetDefault(aReturn,cString)
If nLastKey == 27
   Return
Endif

VerImp()

RptStatus({|| RptDetail() })

Return

Static Function RptDetail

If mv_par04 == 2
   dbSelectArea("SF2")                // * Cabecalho da Nota Fiscal Saida
   dbSetOrder(1)
   dbSeek(xFilial()+mv_par01+mv_par03,.t.)

   dbSelectArea("SD2")                // * Itens de Venda da Nota Fiscal
   dbSetOrder(3)
   dbSeek(xFilial()+mv_par01+mv_par03)
   cPedant := SD2->D2_PEDIDO

   IF SD2->D2_TES == "900" .Or. SD2->D2_SERIE = 'ORC'
      Set Device To Screen
      Aviso("Aviso","Voce esta tentando imprimir um orcamento como NF",{"OK"})
      Return
   Endif   

Else

   dbSelectArea("SF1")                // * Cabecalho da Nota Fiscal Entrada
   DbSetOrder(1)
   dbSeek(xFilial()+mv_par01+mv_par03,.T.)

   dbSelectArea("SD1")                // * Itens da Nota Fiscal de Entrada
   dbSetOrder(1)
   dbSeek(xFilial()+MV_PAR01+MV_PAR03+SF1->F1_FORNECE+SF1->F1_LOJA, .T.)

   IF SD1->D1_TES == "900"  .Or.;
      SD1->D1_SERIE = 'ORC' .Or.;
      SF1->F1_FORNECE <> SD1->D1_FORNECE
      Set Device To Screen
      Aviso("Aviso","Voce esta tentando imprimir um orcamento como NF",{"OK"})
      Return
   Endif   

Endif


//While !Eof() .And. D2_DOC == mv_par01 .And. D2_SERIE == mv_par03
//   Select SC6
//   Set Order To 1
//   Seek xFilial()+SD2->D2_PEDIDO+SD2->D2_ITEMPV+SD2->D2_COD
//   If C6_PRCVEN <> SD2->D2_PRCVEN
//      Set Device To Screen
//      Aviso("Aviso","Houve um erro na geracao da nf confira o Pedido N." + SD2->D2_PEDIDO,{"OK"})
//      Aviso("Aviso","Verifique o Produto : "+SD2->D2_COD+" Preco Ped. "+AllTrim(Transf(C6_PRCVEN,"@E 9,999.99999"))+" Preco nf. "+AllTrim(Transf(SD2->D2_PRCVEN,"@E 9,999.99999")),{"OK"})
//      Return
//   EndIf
//   Select SD2
//   Skip
//EndDo

SetRegua(( Val(mv_par02)-Val(mv_par01))+ 1)
If mv_par04 <> 1

_fSF2 := xFilial( 'SF2' )

While ! SF2->( Eof() )          .And.;
        SF2->F2_DOC <= mv_par02 .And.;
        lContinua               .And.;
        SF2->F2_FILIAL = _fSF2
        
   If SF2->F2_SERIE # mv_par03    // Se a Serie do Arquivo for Diferente
      DbSkip()               // do Parametro Informado !!!
      Loop
   Endif
        
      IF LastKey()==286
         @ 00,01 PSAY "** CANCELADO PELO OPERADOR **"
         lContinua := .F.
         Exit
      Endif
       
   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ Inicio de Levantamento dos Dados da Nota Fiscal              ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
        
   // * Cabecalho da Nota Fiscal
   xNUM_NF     :=SF2->F2_DOC             // Numero
   xSERIE      :=SF2->F2_SERIE           // Serie
   xEMISSAO    :=SF2->F2_EMISSAO         // Data de Emissao
   xTOT_FAT    :=SF2->F2_VALBRUT         // Valor Total da Fatura
   If xTOT_FAT == 0
      xTOT_FAT := SF2->F2_VALMERC+SF2->F2_VALIPI+SF2->F2_SEGURO+SF2->F2_FRETE
   Endif
   xLOJA       :=SF2->F2_LOJA            // Loja do Cliente
   xFRETE      :=SF2->F2_FRETE           // Frete
   xSEGURO     :=SF2->F2_SEGURO          // Seguro
   xBASE_ICMS  :=SF2->F2_BASEICM         // Base   do ICMS
   xBASE_IPI   :=SF2->F2_BASEIPI         // Base   do IPI
   xVALOR_ICMS :=SF2->F2_VALICM          // Valor  do ICMS
   xICMS_RET   :=SF2->F2_ICMSRET         // Valor  do ICMS Retido
   xBSICMRET   :=SF2->F2_BRICMS          // Base de calculo ICMS Retido
   xVALOR_IPI  :=SF2->F2_VALIPI          // Valor  do IPI
   xVALOR_MERC :=SF2->F2_VALMERC         // Valor  da Mercadoria
   xNUM_DUPLIC :=SF2->F2_DUPL            // Numero da Duplicata
   xCOND_PAG   :=SF2->F2_COND            // Condicao de Pagamento
   xPBRUTO     :=SF2->F2_PBRUTO          // Peso Bruto
   xPLIQUI     :=SF2->F2_PLIQUI          // Peso Liquido
   xTIPO       :=SF2->F2_TIPO            // Tipo do Cliente
   xESPECIE    :=SF2->F2_ESPECI1         // Especie 1 no Pedido
   xVOLUME     :=SF2->F2_VOLUME1         // Volume 1 no Pedido
        
   dbSelectArea("SD2")                   // * Itens de Venda da N.F.
   dbSetOrder(3)
   dbSeek(xFilial()+xNUM_NF+xSERIE)
        
   cPedAtu  := SD2->D2_PEDIDO
   cItemAtu := SD2->D2_ITEMPV
        
   xPED_VEND:={}                         // Numero do Pedido de Venda
   xITEM_PED:={}                         // Numero do Item do Pedido de Venda
   xNUM_NFDV:={}                         // nUMERO QUANDO HOUVER DEVOLUCAO
   xPREF_DV :={}                         // Serie  quando houver devolucao
   xICMS    :={}                         // Porcentagem do ICMS
   xCOD_PRO :={}                         // Codigo  do Produto
   xQTD_PRO :={}                         // Peso/Quantidade do Produto
   xPRE_UNI :={}                         // Preco Unitario de Venda
   xPRE_TAB :={}                         // Preco Unitario de Tabela
   xIPI     :={}                         // Porcentagem do IPI
   xVAL_IPI :={}                         // Valor do IPI
   xDESC    :={}                         // Desconto por Item
   xVAL_DESC:={}                         // Valor do Desconto
   xVAL_MERC:={}                         // Valor da Mercadoria
   xTES     :={}                         // TES
   xCF      :={}                         // Classificacao quanto natureza da Operacao
   xICMSOL  :={}                         // Base do ICMS Solidario
   xICM_PROD:={}                         // ICMS do Produto

   While !eof() .and. SD2->D2_DOC==xNUM_NF .and. SD2->D2_SERIE==xSERIE
      If SD2->D2_SERIE # mv_par03        // Se a Serie do Arquivo for Diferente
         dbSkip()                   // do Parametro Informado !!!
         Loop
      Endif

      AADD(xPED_VEND ,SD2->D2_PEDIDO)
      AADD(xITEM_PED ,SD2->D2_ITEMPV)

      If ! Empty( SD2->D2_NFORI )
         If aScan( xNum_NFDV, SD2->D2_NFORI ) = 0
            aAdd( xNum_NFDV , SD2->D2_NFORI )
         End
      End

      AADD(xPREF_DV  ,SD2->D2_SERIORI)
      AADD(xICMS     ,IIf(Empty(SD2->D2_PICM),0,SD2->D2_PICM))
      AADD(xCOD_PRO  ,SD2->D2_COD)
      AADD(xQTD_PRO  ,SD2->D2_QUANT)     // Guarda as quant. da NF
      AADD(xPRE_UNI  ,SD2->D2_PRCVEN)
      AADD(xPRE_TAB  ,SD2->D2_PRUNIT)
      AADD(xIPI      ,IIF(Empty(SD2->D2_IPI),0,SD2->D2_IPI))
      AADD(xVAL_IPI  ,SD2->D2_VALIPI)
      AADD(xDESC     ,SD2->D2_DESC)
      AADD(xVAL_MERC ,SD2->D2_TOTAL)
      AADD(xTES      ,SD2->D2_TES)
      AADD(xCF       ,SD2->D2_CF)
      AADD(xICM_PROD ,IIf(Empty(SD2->D2_PICM),0,SD2->D2_PICM))
      AADD(xVAl_DESC ,SD2->D2_DESCON+SD2->D2_DESCZFR)
      dbskip()
   End
        
   dbSelectArea("SB1")                     // * Desc. Generica do Produto
   dbSetOrder(1)
   xPESO_PRO:={}                           // Peso Liquido
   xPESO_UNIT :={}                         // Peso Unitario do Produto
   xDESCRICAO :={}                         // Descricao do Produto
   xUNIT_PRO:={}                           // Unidade do Produto
   xCOD_TRIB:={}                           // Codigo de Tributacao
   xMEN_TRIB:={}                           // Mensagens de Tributacao
   xCOD_FIS :={}                           // Cogigo Fiscal
   xCLAS_FIS:={}                           // Classificacao Fiscal
   xMEN_POS :={}                           // Mensagem da Posicao IPI
   xISS     :={}                           // Aliquota de ISS
   xTIPO_PRO:={}                           // Tipo do Produto
   xLUCRO   :={}                           // Margem de Lucro p/ ICMS Solidario
   xCLFISCAL   :={}
   PRIVATE xPESO_LIQ := 0
   I:=1
        
   For I:=1 to Len(xCOD_PRO)
      dbSeek(xFilial()+xCOD_PRO[I])
      AADD(xPESO_PRO ,SB1->B1_PESO * xQTD_PRO[I])
      AADD(xPESO_UNIT , SB1->B1_PESO)
      AADD(xUNIT_PRO ,SB1->B1_UM)
      AADD(xDESCRICAO ,SB1->B1_DESC)
      AADD(xCOD_TRIB ,SB1->B1_ORIGEM)
      If Ascan(xMEN_TRIB, SB1->B1_ORIGEM)==0
         AADD(xMEN_TRIB ,SB1->B1_ORIGEM)
      Endif

      npElem := ascan(xCLAS_FIS,SB1->B1_POSIPI)

      if npElem == 0
         AADD(xCLAS_FIS  ,SB1->B1_POSIPI)
      endif

      npElem := ascan(xCLAS_FIS,SB1->B1_POSIPI)

      DO CASE
         CASE npElem == 1
             _CLASFIS := "A"

         CASE npElem == 2
             _CLASFIS := "B"

         CASE npElem == 3
             _CLASFIS := "C"

         CASE npElem == 4
              _CLASFIS := "D"

         CASE npElem == 5
              _CLASFIS := "E"

         CASE npElem == 6
              _CLASFIS := "F"

      ENDCASE
      nPteste := Ascan(xCLFISCAL,_CLASFIS)
      If nPteste == 0
         AADD(xCLFISCAL,_CLASFIS)
      Endif

      AADD(xCOD_FIS ,_CLASFIS)
      If SB1->B1_ALIQISS > 0
         AADD(xISS ,SB1->B1_ALIQISS)
      Endif
      AADD(xTIPO_PRO ,SB1->B1_TIPO)
      AADD(xLUCRO    ,SB1->B1_PICMRET)
      //
      // Calculo do Peso Liquido da Nota Fiscal
      //

      xPESO_LIQUID:=0                                 // Peso Liquido da Nota Fiscal
      For I:=1 to Len(xPESO_PRO)
          xPESO_LIQUID:=xPESO_LIQUID+xPESO_LIQ
      Next

   Next
        
   dbSelectArea("SC5")                            // * Pedidos de Venda
   dbSetOrder(1)
        
   xPED        := {}
   xPESO_BRUTO := 0
   xP_LIQ_PED  := 0
        
   For I:=1 to Len(xPED_VEND)

       dbSeek(xFilial()+xPED_VEND[I])

       If ASCAN(xPED,xPED_VEND[I])==0
          dbSeek(xFilial()+xPED_VEND[I])
          xCLIENTE    :=SC5->C5_CLIENTE            // Codigo do Cliente
          xTIPO_CLI   :=SC5->C5_TIPOCLI            // Tipo de Cliente
          xCOD_MENS   :=SC5->C5_MENPAD             // Codigo da Padrao
          //xMENSAGEM   := AllTrim( SC5->C5_MENNOTA ) // Mensagem para a Nota Fiscal 
          xMENSAGEM   := AllTrim( SC5->C5_MSGNOTA ) // Mensagem para a Nota Fiscal
          xTPFRETE    :=SC5->C5_TPFRETE            // Tipo de Entrega
          xCONDPAG    :=SC5->C5_CONDPAG            // Condicao de Pagamento
          xFORMPG     :=SC5->C5_CDPG               // Forma de Pagamento
          xPESO_BRUTO :=SC5->C5_PBRUTO             // Peso Bruto
          xPESO_LIQ   :=SC5->C5_PESOL              // Peso Liquido
          xCOD_VEND   :=SC5->C5_VEND1              // Codigo do Vendedor 1
          //SC5->C5_VEND2,;             // Codigo do Vendedor 2
          //SC5->C5_VEND3,;             // Codigo do Vendedor 3
          //SC5->C5_VEND4,;             // Codigo do Vendedor 4
          //SC5->C5_VEND5}              // Codigo do Vendedor 5
          xDESC_NF := {SC5->C5_DESC1,;             // Desconto Global 1
          SC5->C5_DESC2,;             // Desconto Global 2
          SC5->C5_DESC3,;             // Desconto Global 3
          SC5->C5_DESC4}              // Desconto Global 4
          AADD(xPED,xPED_VEND[I])
       Endif
                
    Next
        
    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
    //³ Pesquisa da Condicao de Pagto               ³
    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    dbSelectArea("SE4")                    // Condicao de Pagamento
    dbSetOrder(1)
    dbSeek(xFilial("SE4")+xCONDPAG)
    xDESC_PAG := SE4->E4_DESCRI
        
    dbSelectArea("SC6")                    // * Itens de Pedido de Venda
    dbSetOrder(1)
    xPED_CLI :={}                          // Numero de Pedido
    xDESC_PRO:={}                          // Descricao aux do produto
    xUNID_PRO:={}                          // Unidade de Medida do Pedido
    J:=Len(xPED_VEND)
    For I:=1 to J
       dbSeek(xFilial()+xPED_VEND[I]+xITEM_PED[I])
       AADD(xPED_CLI ,SC6->C6_PEDCLI)
       AADD(xDESC_PRO,SC6->C6_DESCRI)
       AADD(xUNID_PRO,SC6->C6_UM)
    Next

    If xTIPO $ [NCPISTO]

       dbSelectArea("SA1")                // * Cadastro de Clientes
       dbSetOrder(1)
       dbSeek(xFilial()+xCLIENTE+xLOJA)
       xCOD_CLI := SA1->A1_COD             // Codigo do Cliente
       xNOME_CLI:= SA1->A1_NOME            // Nome
       xEND_CLI := SA1->A1_END             // Endereco
       xBAIRRO  := SA1->A1_BAIRRO          // Bairro
       xCEP_CLI := SA1->A1_CEP             // CEP
       xCOB_CLI := SA1->A1_ENDCOB          // Endereco de Cobranca
       xCEP_COB := SA1->A1_CEPCOB          // CEP de Cobranca
       xEST_COB := SA1->A1_ESTCOB          // Estado  de Cobranca      
       xMUN_COB := SA1->A1_MUNCOB          // Municipio  de Cobranca 

       If ! Substr( SA1->A1_ENDENT, 1, 1 ) $[. ]

          xREC_CLI := SA1->A1_ENDENT          // Endereco de Entrega

       Else

          xRec_Cli := Alltrim( SA1->A1_END )
          xRec_Cli += ' - '
          xRec_Cli += AllTrim( SA1->A1_BAIRRO )
          xRec_Cli += ' - '          
          xRec_Cli += AllTrim( SA1->A1_MUN )
          xRec_Cli += ' - '          
          xRec_Cli += AllTrim( SA1->A1_EST )
          xRec_Cli += ' - '          
          xRec_Cli += Transform( SA1->A1_CEP, "@R 99999-999" )

       End

       xRec_Cli += SA1->A1_OBSTRAN

       xMUN_CLI := SA1->A1_MUN             // Municipio
       xEST_CLI := SA1->A1_EST             // Estado
       xCGC_CLI := SA1->A1_CGC             // CGC
       xINSC_CLI:= SA1->A1_INSCR           // Inscricao estadual
       xTRAN_CLI:= SA1->A1_TRANSP          // Transportadora
       xTEL_CLI := SA1->A1_TEL             // Telefone
       xFAX_CLI := SA1->A1_FAX             // Fax
       xSUFRAMA := SA1->A1_SUFRAMA            // Codigo Suframa
       xCALCSUF := SA1->A1_CALCSUF            // Calcula Suframa
       xREGIAO  := SA1->A1_REGIAO          // REGIAO DO CLIENTE
       dbSelectArea("SX5")
       dbSetOrder(1)
       dbSeek(xFilial()+"73"+xRegiao)
       If Found()
       		xDescrg:=Alltrim(SX5->X5_DESCRI)
       Else  
       		xDescrg:="*****"
       Endif
  // Alteracao p/ Calculo de Suframa
       if !empty(xSUFRAMA) .and. xCALCSUF =="S"
          IF XTIPO $ [DB]
             zFranca := .F.
          else
             zFranca := .T.
          endif
       Else
          zfranca:= .F.
       endif
              
    Else
      zFranca:=.F.
      dbSelectArea("SA2")                // * Cadastro de Fornecedores
      dbSetOrder(1)
      dbSeek(xFilial()+xCLIENTE+xLOJA)
      xCOD_CLI :=SA2->A2_COD             // Codigo do Fornecedor
      xNOME_CLI:=SA2->A2_NOME            // Nome Fornecedor
      xEND_CLI :=SA2->A2_END             // Endereco
      xBAIRRO  :=SA2->A2_BAIRRO          // Bairro
      xCEP_CLI :=SA2->A2_CEP             // CEP
      xCOB_CLI :=""                      // Endereco de Cobranca
      xCEP_COB :=""                      // CEP de Cobranca
      xEST_COB :=""                      // Estado  de Cobranca      
      xMUN_COB :=""                      // Municipio  de Cobranca                 
      xREC_CLI :=""                      // Endereco de Entrega
      xMUN_CLI :=SA2->A2_MUN             // Municipio
      xEST_CLI :=SA2->A2_EST             // Estado
      xCGC_CLI :=SA2->A2_CGC             // CGC
      xINSC_CLI:=SA2->A2_INSCR           // Inscricao estadual
      xTRAN_CLI:=SA2->A2_TRANSP          // Transportadora
      xTEL_CLI :=SA2->A2_TEL             // Telefone
      xFAX_CLI :=SA2->A2_FAX             // Fax
   Endif

        dbSelectArea("SA4")                   // * Transportadoras
        dbSetOrder(1)
        dbSeek(xFilial()+SF2->F2_TRANSP)
        xNOME_TRANSP :=SA4->A4_NOME           // Nome Transportadora
        xEND_TRANSP  := rTrim( SA4->A4_END )  // Endereco
        xEND_TRANSP  += ' - '
        xEND_TRANSP  += rTrim( SA4->A4_BAIRRO )
        xMUN_TRANSP  :=SA4->A4_MUN            // Municipio
        xEST_TRANSP  :=SA4->A4_EST            // Estado
        xVIA_TRANSP  :=SA4->A4_VIA            // Via de Transporte
        xCGC_TRANSP  :=SA4->A4_CGC            // CGC
        xTEL_TRANSP  :=SA4->A4_TEL            // Fone
        
        dbSelectArea("SE1")                   // * Contas a Receber
        dbSetOrder(1)
        nQTDE_DUP  :=0                        // qtde de duplicatas  
        xPARC_DUP  :={}                       // Parcela
        xVENC_DUP  :={}                       // Vencimento
        xVALOR_DUP :={}                       // Valor
        xDUPLICATAS:=IIF(dbSeek(xFilial()+xSERIE+xNUM_DUPLIC,.T.),.T.,.F.) // Flag p/Impressao de Duplicatas*/

/*        aVenc := Condicao(xTOT_FAT,xCOND_PAG,xVALOR_IPI,xEMISSAO)

        For nC := 1 To Len(aVenc)
            AADD(xPARC_DUP,IIf(Len(aVenc)>1,Chr(65+nC),""))
            AADD(xVENC_DUP,aVenc[nC][1])
            AADD(xVALOR_DUP,aVenc[nC][2])
        Next nC


*/
        while !eof() .and. SE1->E1_NUM==xNUM_DUPLIC .and. xDUPLICATAS==.T.
                If !("NF" $ SE1->E1_TIPO)
                        dbSkip()
                        Loop
                Endif
                AADD(xPARC_DUP ,SE1->E1_PARCELA)
                AADD(xVENC_DUP ,SE1->E1_VENCTO)
                AADD(xVALOR_DUP,SE1->E1_VALOR)
                dbSkip()
        EndDo

        nQTDE_DUP := Len(xPARC_DUP)        

        dbSelectArea("SF4")                   // * Tipos de Entrada e Saida
        DbSetOrder(1)
        dbSeek(xFilial()+xTES[1])
        xNATUREZA:=SF4->F4_TEXTO              // Natureza da Operacao
        xCfo     :=SF4->F4_CF
        
        Imprime()

        If MV_PAR05 <> 2

           If File ( 'F:\WSISLSRB\CB' + SF2->F2_DOC + '.Rem' )

              _cRun := 'F:\WSISLSRB\WSisLsr.Exe CB' + SF2->F2_DOC + '.Rem 0'
              WinExec( _cRun )

           End

        End

        //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
        //³ Termino da Impressao da Nota Fiscal                          ³
        //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
        
        dbSelectArea("SF2")
        dbSkip()                      // passa para a proxima Nota Fiscal
        
EndDo
else

   While ! SF1->( eof() ) .and. SF1->F1_DOC <= mv_par02 .and. SF1->F1_SERIE == mv_par03 .and. lContinua

      If SF1->F1_SERIE #mv_par03    // Se a Serie do Arquivo for Diferente
         DbSkip()                    // do Parametro Informado !!!
         Loop
      Endif
      //+-----------------------------------------------------------+
      //¦ Inicializa  regua de impressao                            ¦
      //+-----------------------------------------------------------+

	#IFNDEF WINDOWS
	      IF LastKey()==286
	         @ 00,01 PSAY "** CANCELADO PELO OPERADOR **"
	         lContinua := .F.
	         Exit
	      Endif
	#ELSE
	      IF lAbortPrint
	         @ 00,01 PSAY "** CANCELADO PELO OPERADOR **"
	         lContinua := .F.
	         Exit
	      Endif
	#ENDIF

      nLinIni:=nLin                         // Linha Inicial da Impressao

      //+--------------------------------------------------------------+
      //¦ Inicio de Levantamento dos Dados da Nota Fiscal              ¦
      //+--------------------------------------------------------------+

      ZFRANCA     := .F.
      xVENc_DUP   := {' '}
      xIcms_Ret   := 0
      xRec_Cli    := ' '
      xSuframa    := ' '
      xMensagem   := ' '
      xDesc_Pag   := ' '
      xFormPg     := ' '
      xNUM_NF     :=SF1->F1_DOC             // Numero
      xSERIE      :=SF1->F1_SERIE           // Serie
      xFORNECE    :=SF1->F1_FORNECE         // Cliente/Fornecedor
      XCLIENTE    :=SF1->F1_FORNECE
      xEMISSAO    :=SF1->F1_EMISSAO         // Data de Emissao
      xTOT_FAT    :=SF1->F1_VALBRUT         // Valor Bruto da Compra
      xLOJA       :=SF1->F1_LOJA            // Loja do Cliente
      xFRETE      :=SF1->F1_FRETE           // Frete
      xSEGURO     :=SF1->F1_DESPESA         // Despesa
      xBASE_ICMS  :=SF1->F1_BASEICM         // Base   do ICMS
      xBASE_IPI   :=SF1->F1_BASEIPI         // Base   do IPI
      xBSICMRET   :=SF1->F1_BRICMS          // Base do ICMS Retido
      xVALOR_ICMS :=SF1->F1_VALICM          // Valor  do ICMS
      xICMS_RET   :=SF1->F1_ICMSRET         // Valor  do ICMS Retido
      xVALOR_IPI  :=SF1->F1_VALIPI          // Valor  do IPI
      xVALOR_MERC :=SF1->F1_VALMERC         // Valor  da Mercadoria
      xNUM_DUPLIC :=SF1->F1_DUPL            // Numero da Duplicata
      xCOND_PAG   :=SF1->F1_COND            // Condicao de Pagamento
      xTIPO       :=SF1->F1_TIPO            // Tipo do Cliente
      xNFORI      :=SF1->F1_NFORI           // NF Original
      xPREF_DV    :=SF1->F1_SERIORI         // Serie Original
      xFORMPG     :='  '                    // Forma de Pagamento

      dbSelectArea("SD1")                   // * Itens da N.F. de Compra
      dbSetOrder(1)
      dbSeek(xFilial()+xNUM_NF+xSERIE+xFORNECE+xLOJA)

      cPedAtu := SD1->D1_PEDIDO
      cItemAtu:= SD1->D1_ITEMPC

      xPEDIDO  :={}                         // Numero do Pedido de Compra
      xITEM_PED:={}                         // Numero do Item do Pedido de Compra
      xNUM_NFDV:={}                         // Numero quando houver devolucao
      xPREF_DV :={}                         // Serie  quando houver devolucao
      xICMS    :={}                         // Porcentagem do ICMS
      xCOD_PRO :={}                         // Codigo  do Produto
      xQTD_PRO :={}                         // Peso/Quantidade do Produto
      xPRE_UNI :={}                         // Preco Unitario de Compra
      xIPI     :={}                         // Porcentagem do IPI
      xPESOPROD:={}                         // Peso do Produto
      xVAL_IPI :={}                         // Valor do IPI
      xDESC    :={}                         // Desconto por Item
      xVAL_DESC:={}                         // Valor do Desconto
      xVAL_MERC:={}                         // Valor da Mercadoria
      xTES     :={}                         // TES
      xCF      :={}                         // Classificacao quanto natureza da Operacao
      xICMSOL  :={}                         // Base do ICMS Solidario
      xICM_PROD:={}                         // ICMS do Produto

      xCOB_CLI :=""                      // Endereco de Cobranca
      xCEP_COB :=""                      // CEP de Cobranca
      xEST_COB :=""                      // Estado  de Cobranca      
      xMUN_COB :=""                      // Municipio  de Cobranca                 
      xREC_CLI :=""                      // Endereco de Entrega

      while !eof() .and. SD1->D1_DOC==xNUM_NF
         If SD1->D1_SERIE #mv_par03        // Se a Serie do Arquivo for Diferente
              DbSkip()                      // do Parametro Informado !!!
              Loop
         Endif

         AADD(xPEDIDO ,SD1->D1_PEDIDO)           // Ordem de Compra
         AADD(xITEM_PED ,SD1->D1_ITEMPC)         // Item da O.C.

         If ! Empty( SD1->D1_NFORI )
            If aScan( xNum_NFDV, SD1->D1_NFORI ) = 0
               aAdd( xNum_NFDV , SD1->D1_NFORI )
            End
         End

         AADD(xPREF_DV  ,SD1->D1_SERIORI)        // Serie Original
         AADD(xICMS     ,IIf(Empty(SD1->D1_PICM),0,SD1->D1_PICM))
         AADD(xCOD_PRO  ,SD1->D1_COD)            // Produto
         AADD(xQTD_PRO  ,SD1->D1_QUANT)          // Guarda as quant. da NF
         AADD(xPRE_UNI  ,SD1->D1_VUNIT - (SD1->D1_VALDESC / SD1->D1_QUANT))          // Valor Unitario
         AADD(xIPI      ,SD1->D1_IPI)            // % IPI
         AADD(xVAL_IPI  ,SD1->D1_VALIPI)         // Valor do IPI
         AADD(xPESOPROD ,SD1->D1_PESO)           // Peso do Produto
         AADD(xDESC     ,SD1->D1_DESC)           // % Desconto
         AADD(xVAL_MERC ,SD1->D1_TOTAL)          // Valor Total
         AADD(xTES      ,SD1->D1_TES)            // Tipo de Entrada/Saida
         AADD(xCF       ,SD1->D1_CF)             // Codigo Fiscal
         AADD(xICM_PROD ,IIf(Empty(SD1->D1_PICM),0,SD1->D1_PICM))
         dbskip()
      End

      dbSelectArea("SB1")                     // * Desc. Generica do Produto
      dbSetOrder(1)
      xUNID_PRO:={}                           // Unidade do Produto
      xDESC_PRO:={}                           // Descricao do Produto
      xMEN_POS :={}                           // Mensagem da Posicao IPI
      xDESCRICAO :={}                         // Descricao do Produto
      xCOD_TRIB:={}                           // Codigo de Tributacao
      xMEN_TRIB:={}                           // Mensagens de Tributacao
      xCOD_FIS :={}                           // Cogigo Fiscal
      xCLAS_FIS:={}                           // Classificacao Fiscal
      xISS     :={}                           // Aliquota de ISS
      xTIPO_PRO:={}                           // Tipo do Produto
      xLUCRO   :={}                           // Margem de Lucro p/ ICMS Solidario
      xCLFISCAL   :={}
      xSUFRAMA :=""
      xCALCSUF :=""
      xPED_VEND := {' '}
      xPED_CLI := {' ' }
      I:=1

      For I:=1 to Len(xCOD_PRO)

         dbSeek(xFilial()+xCOD_PRO[I])
         dbSelectArea("SB1")

         AADD(xDESC_PRO ,SB1->B1_DESC)
         AADD(xUNID_PRO ,SB1->B1_UM)
         AADD(xCOD_TRIB ,SB1->B1_ORIGEM)
         If Ascan(xMEN_TRIB, SB1->B1_ORIGEM)==0
            AADD(xMEN_TRIB ,SB1->B1_ORIGEM)
         Endif
         AADD(xDESCRICAO ,SB1->B1_DESC)
         AADD(xMEN_POS  ,SB1->B1_POSIPI)
         If SB1->B1_ALIQISS > 0
            AADD(xISS,SB1->B1_ALIQISS)
         Endif
         AADD(xTIPO_PRO ,SB1->B1_TIPO)
         AADD(xLUCRO    ,SB1->B1_PICMRET)

         npElem := ascan(xCLAS_FIS,SB1->B1_POSIPI)

         if npElem == 0
            AADD(xCLAS_FIS  ,SB1->B1_POSIPI)
         endif
         npElem := ascan(xCLAS_FIS,SB1->B1_POSIPI)

         DO CASE
            CASE npElem == 1
               _CLASFIS := "A"

            CASE npElem == 2
               _CLASFIS := "B"

            CASE npElem == 3
               _CLASFIS := "C"

            CASE npElem == 4
               _CLASFIS := "D"

            CASE npElem == 5
               _CLASFIS := "E"

            CASE npElem == 6
               _CLASFIS := "F"

         EndCase
         nPteste := Ascan(xCLFISCAL,_CLASFIS)
         If nPteste == 0
            AADD(xCLFISCAL,_CLASFIS)
         Endif
         AADD(xCOD_FIS ,_CLASFIS)

      Next

      //+---------------------------------------------+
      //¦ Pesquisa da Condicao de Pagto               ¦
      //+---------------------------------------------+

      dbSelectArea("SE4")                    // Condicao de Pagamento
      dbSetOrder(1)
      dbSeek(xFilial("SE4")+xCOND_PAG)
      xDESC_PAG := SE4->E4_DESCRI

      If xTIPO == "D"

         dbSelectArea("SA1")                // * Cadastro de Clientes
         dbSetOrder(1)
         dbSeek(xFilial()+xFORNECE)
         xCOD_CLI :=SA1->A1_COD             // Codigo do Cliente
         xNOME_CLI:=SA1->A1_NOME            // Nome
         xEND_CLI :=SA1->A1_END             // Endereco
         xBAIRRO  :=SA1->A1_BAIRRO          // Bairro
         xCEP_CLI :=SA1->A1_CEP             // CEP
         xCOB_CLI :=SA1->A1_ENDCOB          // Endereco de Cobranca
         xREC_CLI :=SA1->A1_ENDENT          // Endereco de Entrega
         xMUN_CLI :=SA1->A1_MUN             // Municipio
         xEST_CLI :=SA1->A1_EST             // Estado
         xCGC_CLI :=SA1->A1_CGC             // CGC
         xINSC_CLI:=SA1->A1_INSCR           // Inscricao estadual
         xTRAN_CLI:=SA1->A1_TRANSP          // Transportadora
         xTEL_CLI :=SA1->A1_TEL             // Telefone
         xFAX_CLI :=SA1->A1_FAX             // Fax
         xCOD_VEND:=SA1->A1_VEND           // Codigo do Vendedor 1

      Else

         dbSelectArea("SA2")                // * Cadastro de Fornecedores
         dbSetOrder(1)
         dbSeek(xFilial()+xFORNECE+xLOJA)
         xCOD_CLI :=SA2->A2_COD                // Codigo do Cliente
         xNOME_CLI:=SA2->A2_NOME               // Nome
         xEND_CLI :=SA2->A2_END                // Endereco
         xBAIRRO  :=SA2->A2_BAIRRO             // Bairro
         xCEP_CLI :=SA2->A2_CEP                // CEP
         xCOB_CLI :=""                      // Endereco de Cobranca
         xCEP_COB :=""                      // CEP de Cobranca
         xEST_COB :=""                      // Estado  de Cobranca      
         xMUN_COB :=""                      // Municipio  de Cobranca                 
         xREC_CLI :=""                      // Endereco de Entrega
         xREC_CLI :=""                         // Endereco de Entrega
         xMUN_CLI :=SA2->A2_MUN                // Municipio
         xEST_CLI :=SA2->A2_EST                // Estado
         xCGC_CLI :=SA2->A2_CGC                // CGC
         xINSC_CLI:=SA2->A2_INSCR              // Inscricao estadual
         xTRAN_CLI:=SA2->A2_TRANSP             // Transportadora
         xTEL_CLI :=SA2->A2_TEL                // Telefone
         xFAX     :=SA2->A2_FAX                // Fax
         xCOD_VEND:='       '              // Codigo do Vendedor 1
      EndIf

      dbSelectArea("SE1")                   // * Contas a Receber
      dbSetOrder(1)
      xPARC_DUP  :={}                       // Parcela
      xVENC_DUP  :={}                       // Vencimento
      xVALOR_DUP :={}                       // Valor
      xDUPLICATAS:=IIF(dbSeek(xFilial()+xSERIE+xNUM_DUPLIC,.T.),.T.,.F.) // Flag p/Impressao de Duplicatas

      while !eof() .and. SE1->E1_NUM==xNUM_DUPLIC .and. xDUPLICATAS==.T.
         AADD(xPARC_DUP ,SE1->E1_PARCELA)
         AADD(xVENC_DUP ,SE1->E1_VENCTO)
         AADD(xVALOR_DUP,SE1->E1_VALOR)
         dbSkip()
      EndDo

      dbSelectArea("SF4")          // * Tipos de Entrada e Saida
      dbSetOrder(1)
      dbSeek(xFilial()+xTES[1])
      xNATUREZA := SF4->F4_TEXTO   // Natureza da Operacao

      xNOME_TRANSP :=" "           // Nome Transportadora
      xEND_TRANSP  :=" "           // Endereco
      xMUN_TRANSP  :=" "           // Municipio
      xEST_TRANSP  :=" "           // Estado
      xVIA_TRANSP  :=" "           // Via de Transporte
      xCGC_TRANSP  :=" "           // CGC
      xTEL_TRANSP  :=" "           // Fone
      xTPFRETE     :=" "           // Tipo de Frete
      xVOLUME      := 0            // Volume
      xESPECIE     :=" "           // Especie
      xPESO_LIQ    := 0            // Peso Liquido
      xPESO_BRUTO  := 0            // Peso Bruto
      xCOD_MENS    :=" "           // Codigo da Mensagem
      xMENSAGEM    :=" "           // Mensagem da Nota
      xPESO_LIQUID :=" "


      Imprime()

      //+--------------------------------------------------------------+
      //¦ Termino da Impressao da Nota Fiscal                          ¦
      //+--------------------------------------------------------------+

      IncRegua()                    // Termometro de Impressao

      nLin:=0
      dbSelectArea("SF1")           
      dbSkip()                     // e passa para a proxima Nota Fiscal

   EndDo

end
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³                                                              ³
//³                      FIM DA IMPRESSAO                        ³
//³                                                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fechamento do Programa da Nota Fiscal                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

dbSelectArea("SF2")
Retindex("SF2")
dbSelectArea("SD2")
Retindex("SD2")
dbSelectArea("SD1")
Retindex("SD1")

@ 0,0 PSAY Chr( 27 )+'@'

If aReturn[5] == 1
   dbcommitAll()
   ourspool(wnrel)
Endif

MS_FLUSH()

Set Device  To Screen
Set Printer TO

Return

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fim do Programa                                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ VERIMP   ³ Autor ³   Marcos Simidu       ³ Data ³ 20/12/95 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Verifica posicionamento de papel na Impressora             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Nfiscal                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicio da Funcao    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Static Function VerImp

nLin    := 1                // Contador de Linhas
nLinIni :=0

If aReturn[5]==2

   nOpc       := 1

   While .T.

      dbCommitAll()
                
      @ nLin ,000 PSAY " "
      @ nLin ,004 PSAY "*"
      @ nLin ,022 PSAY "."
      IF MsgYesNo("Fomulario esta posicionado ? ")
            nOpc := 1
      ElseIF MsgYesNo("Tenta Novamente ? ")
            nOpc := 2
      Else
            nOpc := 3
      Endif

      Do Case
         Case nOpc==1
            lContinua:=.T.
            Exit
         Case nOpc==2
            Loop
         Case nOpc==3
            lContinua:=.F.
         Return
      EndCase
   End
Endif

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ IMPDET   ³ Autor ³   Marcos Simidu       ³ Data ³ 20/12/95 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Impressao de Linhas de Detalhe da Nota Fiscal              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Nfiscal                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function IMPDET
LOCAL nTamDet := 20            // Tamanho da Area de Detalhe

I:=1
J:=1

xB_ICMS_SOL:=0          // Base  do ICMS Solidario
xV_ICMS_SOL:=0          // Valor do ICMS Solidario

For I:=1 to nTamDet
   If I<= Len(xCOD_PRO)
      @ Li,  05  PSAY xCOD_PRO[I]
      @ Li,  20  PSAY xDESC_PRO[I]     //    xDESCRICAO
      @ Li, 082  PSAY "000"            //MODIFICADO EM 290102 - HAROLDO         // xCOD_TRIB[I]
      @ Li, 90  PSAY xUNID_PRO[I]
      @ Li, 98  PSAY xQTD_PRO[I]               Picture"@E 999,999.99"
      If zFRANCA
         @ Li, 110  PSAY  xPRE_UNI[I]+(xVAL_DESC[I]/xQTD_PRO[I])   Picture"@E 99,999,999.99999"
         @ Li, 142  PSAY (xPRE_UNI[I]+(xVAL_DESC[I]/xQTD_PRO[I]))*xQTD_PRO[I]  Picture"@E 99,999,999.99"
      Else 
         @ Li, 110  PSAY xPRE_UNI[I]               Picture"@E 99,999,999.99999"
         @ Li, 142  PSAY xVAL_MERC[I]              Picture"@E 99,999,999.99"
      Endif
      @ Li, 158  PSAY xICM_PROD[I]              Picture"99"
      J := J + 1
   Endif
   Li ++
Next
   
IF Zfranca
   xVLDescTot := SF2->F2_DESCONT
//   For xi:=1 To Len(xVAL_DESC) ALTERADO POR SANTANA
//      xVlDescTot := xVlDescTot + xVAL_DESC[xi]   
//   Next
   @ Li,12 PSAY "*** I.C.M.S. Art. 8. Anexo I Tabela I Item 3 do Decreto 33.118/91 - Desconto de 7% no Total da Nota Fiscal - R$ "+Alltrim(STR(xVlDescTot,15,2))+" ***"
   Li ++
ElseIf xCLIENTE+xLOJA $ "00020002*00020003"
   @ Li,17 PSAY "Em Transito p/Estab.SWIFT ARMOUR S/A IND.COM.R.Irineu J.Bordon,215-V.Taquara CGC60718823/0168-66 IE107573007118-Reg.Esp.Proc.DRTCII018252/96"
   Li ++
   @ Li,14 PSAY "                        ** Entrega SAO PAULO **"
ElseIf xCLIENTE+xLOJA $ "00030003"
   @ Li,10 PSAY "Em Transito p/Estab. C A Modas Ltda. Av.Piracema,1231 Barueri SP CGC 45.242.914/0045-18 IE 206.029.759.110 Reg.Esp.Proc.DRT 1-18564/79"
   Li ++
Else
   Li ++
Endif

Li += 2
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ CLASFIS  ³ Autor ³   Marcos Simidu       ³ Data ³ 16/11/95 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Impressao de Array com as Classificacoes Fiscais           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Nfiscal                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicio da Funcao    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Static Function CLASFIS

@ nLin,006 PSAY "Classificacao Fiscal"
nLin := nLin + 1
For nCont := 1 to Len(xCLFISCAL) .And. nCont <= 12
   nCol := If(Mod(nCont,2) != 0, 06, 33)
   @ nLin, nCol   PSAY xCLFISCAL[nCont] + "-"
   @ nLin, nCol+ 05 PSAY Transform(xCLAS_FIS[nCont],"@r 99.99.99.99.99")
   nLin := nLin + If(Mod(nCont,2) != 0, 0, 1)
Next

Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ IMPMENP  ³ Autor ³   Marcos Simidu       ³ Data ³ 20/12/95 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Impressao Mensagem Padrao da Nota Fiscal                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Nfiscal                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicio da Funcao    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Static Function IMPMENP

nCol:= 10

If !Empty(xCOD_MENS)
   @ nLin, NCol PSAY FORMULA(xCOD_MENS)
Endif

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ DUPLIC   ³ Autor ³   Marcos Simidu       ³ Data ³ 20/12/95 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Impressao do Parcelamento das Duplicatas                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Nfiscal                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function DUPLIC
nCol:= 055
I:=1
@ Li, 017        PSAY xNUM_DUPLIC
For I:=1 to Len(xVENC_DUP)
   @ Li, nCol PSAY xVENC_DUP[I]  
   nCol := nCol+26
Next

Li := Li + 1
nCol:= 051
I:=1
For I:=1 to Len(xVALOR_DUP)
   @ Li, nCol PSAY xVALOR_DUP[I] Picture("@E 9,999,999.99")
   nCol := nCol+26
Next        
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ IMPRIME  ³ Autor ³   Marcos Simidu       ³ Data ³ 20/12/95 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Imprime a Nota Fiscal de Entrada e de Saida                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico RDMAKE                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function Imprime

@ 0,0 PSAY Chr( 27 )+'@'+Chr( 27 ) + 'C' + Chr( 72 )+Chr( 18 )
@ 1,0 PSAY Chr( 27 )+'M'
Li := 2

If mv_par04 <> 1
   @ Li,63 PSAY Chr(14)+Chr(15)+"X"
Else
   @ Li,114 PSAY Chr(14)+Chr(15)+"X"
End

Li ++

@ Li,146 PSAY Chr(14)+xNUM_NF                          // Numero da Nota Fiscal
Li := Li + 1                           
@ Li,125 PSAY "REGIAO: "
@ Li,133 PSAY xDescrg
Li := Li + 4

If xICMS_RET  > 0     .And.;
   xTES[ 1 ] <> '504'
   @ Li,017 PSAY 'VENDA MERC. REGIME SUBST. TRIB.' // Texto da Natureza de Operacao   
Else                                               
   @ Li,017 PSAY xNATUREZA                         // Texto da Natureza de Operacao
End

If Substr( xTES[1], 1, 1)  <> '5'

   If SA2->A2_EST != 'SP'

      _cCfop := '2.'

   Else

      _cCfop := '1.'
   End

Else

   If xTES[ 1 ] <> '505'

      If SA1->A1_EST != 'SP'

         _cCfop := '6.'

      Else

         _cCfop := '5.'

      End

   Else

      If SA2->A2_EST != 'SP'

         _cCfop := '6.'

      Else

         _cCfop := '5.'

      End

   End

End

If xICMS_RET  > 0    .And.;
   xTES[ 1 ] <> '504'

   _cCfop += '404'

ElseIf xTES[ 1 ] <> '504'

   _cCfop += Substr( xCF[ 1 ], 2 )

Else

   _cCfop += '910'

End

@ Li, 057 PSAY _cCfop

Li += 3
@ Li,017 PSAY xCLIENTE+"-"+xLOJA+" "+xNOME_CLI     //Nome do Cliente

If !EMPTY(xCGC_CLI)                   // Se o C.G.C. do Cli/Forn nao for Vazio
   @ Li, 107 PSAY xCGC_CLI Picture"@R 99.999.999/9999-99"
Else
   @ Li, 105 PSAY " "             // Caso seja vazio
Endif
@ Li, 145 PSAY xEMISSAO              // Data da Emissao do Documento
Li := Li + 2
@ Li, 017 PSAY xEND_CLI                                 // Endereco
@ Li,  92 PSAY xBAIRRO                                  // Bairro
@ Li, 116 PSAY xCEP_CLI Picture"@R 99999-999"           // CEP
@ Li, 128 PSAY " "                                      // Reservado  p/Data Saida/Entrada
Li := Li + 2
@ Li, 017 PSAY xMUN_CLI                               // Municipio
@ Li, 073 PSAY xTEL_CLI                               // Telefone/FAX
@ Li, 97 PSAY xEST_CLI                               // U.F.
@ Li, 110 PSAY xINSC_CLI                              // Insc. Estadual
@ LI, 145 PSAY Alltrim(Subs(Time(),1,5))
//@ Li, 143 PSAY " "                                    // Reservado p/Hora da Saida
Li := Li + 3

DUPLIC()                 // Duplicatas

Li := Li + 2
@ Li,023 PSAY xMUN_COB + " " + xEST_COB
@ Li,066 PSAY xCOB_CLI + " CEP: " + xCEP_COB
Li := Li + 3

ImpDet()                 // Itens dos Materiais

Li := Li + 1
@ Li, 020  PSAY xBASE_ICMS  Picture"@EZ 999,999,999.99"  // Base do ICMS
@ Li, 050  PSAY xVALOR_ICMS Picture"@EZ 999,999,999.99"  // Valor do ICMS
@ Li, 076  PSAY xBSICMRET   Picture"@EZ 999,999,999.99"  // Base ICMS Ret.
@ Li, 98  PSAY xICMS_RET   Picture"@EZ 999,999,999.99"  // Valor  ICMS Ret.
@ Li, 142  PSAY xVALOR_MERC Picture"@EZ 999,999,999.99"  // Valor Tot. Prod.
Li := Li + 2
@ Li, 020  PSAY xFRETE      Picture"@E 999,999,999.99"  // Valor do Frete
@ Li, 050  PSAY xSEGURO     Picture"@E 999,999,999.99"  // Valor Seguro
@ Li, 98  PSAY xVALOR_IPI  Picture"@EZ 999,999,999.99"  // Valor do IPI
@ Li, 142  PSAY xTOT_FAT    Picture"@EZ 999,999,999.99"  // Valor Total NF
Li := Li + 3
@ Li, 010  PSAY xNOME_TRANSP                       // Nome da Transport.

IF xTPFRETE=='C'                                   // Frete por conta do
   @ Li, 99 PSAY "1"                              // Emitente (1)
Else                                               //     ou
   @ Li, 99 PSAY "2"                              // Destinatario (2)
Endif

//@ Li, 102 PSAY " "                                  // Res. p/Placa do Veiculo
//@ Li, 122 PSAY " "                                  // Res. p/xEST_TRANSP                          // U.F.

If !EMPTY(xCGC_TRANSP)                              // Se C.G.C. Transportador nao for Vazio
   @ Li, 134 PSAY xCGC_TRANSP Picture "@R 99.999.999/9999-99"
End
Li += 2

@ Li, 010 PSAY xEND_TRANSP                          // Endereco Transp.
@ Li, 85 PSAY Alltrim(xMUN_TRANSP)                 // Municipio
@ Li, 125 PSAY xEST_TRANSP                          // U.F.

Li +=2
@ Li, 010 PSAY xVOLUME  Picture"@EZ 999,999.99"             // Quant. Volumes
@ Li, 026 PSAY xESPECIE Picture"@!"                          // Especie
@ Li, 052 PSAY ""+If(Empty(xTel_Transp),"","  Tel:"+xTel_TRANSP) // Telefone --> Res para Marca
@ Li, 075 PSAY " "                                           // Res para Numero
@ Li, 119 PSAY xPESO_BRUTO     Picture"@EZ 999,999.99"      // Res para Peso Bruto
@ Li, 135 PSAY xPESO_LIQ       Picture"@EZ 999,999.99"      // Res para Peso Liquido
Li := 59

    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
    //³ Pesquisa nome do Vendedor                   ³
    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    dbSelectArea("SA3")                    
    dbSetOrder(1)
    dbSeek(xFilial("SA3")+xCOD_VEND)
    xNREDUZ_VEND := SA3->A3_NREDUZ
        

@ li, 05 PSAY "Vend: "+xCOD_VEND + " " + rTrim( xNREDUZ_VEND ) + " N/Pedido : "+rTrim( xPED_VEND[1] )+" Ped. Cliente: "+rTrim( xPED_CLI[1] )

Li ++

If xTes[ 1 ] <> '504'
   @ Li, 05 PSAY "Cond.Pg-> "+xDESC_PAG+" "+xFORMPG
   Li ++
End

If ! Empty( xMENSAGEM )

   _nLen := Len( xMensagem )
   _vMsg := ''
   
   For n := 1 To _nLen
   
       If Substr( xMensagem, n, 1 ) = Chr( 13 )

          n ++ 
          If ! Empty( _vMsg )
             @ Li,5 PSAY _vMsg
             Li ++
          End
          _vMsg := ''

       Else

          _vMsg += Substr( xMensagem, n, 1 )

       End
   
   Next

   @ Li,5 PSAY _vMsg

End

If ! SC5->C5_Transp $[900000.99    ] .And. ;
   SC5->C5_TIPENT <> ' '

   If SC5->C5_TIPENT <> '2'

      _cObs := 'T R A N S P O R T A D O R A    R E T I R A'

   Else

      _cObs := 'E N T R E G A R   N A   T R A N S P O R T A D O R A'

   End

   @ Li,05 PSAY _cObs
   Li ++

End

IF ! zFRANCA

   IF ! Ascan(xCod_Pro,"38")==0
      @ Li,5 PSAY "Red. ICMS Para 12% Conforme Resolucao S.F. 40 de 13/11/1995"
      Li ++
   Endif

Else

   @ Li,5 PSAY "SUFRAMA : "+xSuframa
   Li ++

EndIf

If !Empty(xCOD_MENS)

   @ Li,5 PSAY FORMULA(xCOD_MENS)
   Li ++

Endif

_nLen := Len( xNum_NFDV )
If _nLen > 0

   _cNota := 'CONFORME SUA(S) NOTA(S) FISCAL(IS) DE No. '

   For i := 1 To _nLen

       _cNota += Transform( xNum_NFDV[ i ], '@R 999.999' )

       If i <> _nLen

          _cNota += ', '

          If Len( _cNota ) >= 69

             Li ++
             @ Li,5 PSAY _cNota
             _cNota := ''

          End

       End

   Next

   Li ++
   @ Li,5 PSAY _cNota

End

Li ++

If xICMS_RET >0

   Set Device To Screen
   _cMsg := 'Atenção, a Nota Fiscal nº ' + SF2->F2_DOC + ' contem ICMS a recolher (substituição tribut-' + Chr( 13 )
   _cMsg += 'aria), por favor, informe o Sr Marcos para que seja emitida  a  GNRE - Guia Na-' + Chr( 13 )
   _cMsg += 'cional de Recolhimento de Tributo Estadual,a mesma deverá ser recolhida na' + Chr( 13 )
   _cMsg += 'rede bancaria e anexada a Nota Fiscal'
   MsgInfo( _cMsg )    
   Set Device To Print

   @ Li, 5 PSAY 'RECONHIMENTO DO ICMS CONF. PROTOCOLO N§ 17'
   Li ++
   @ Li, 5 PSAY 'DE 25.07.85 DOU DE 29.07.85'

Else   

   @ Li,5 PSAY " "

End

nCol:= 115
I:=1
Li := 67
For I:=1 To Len(xVENC_DUP)

   @ Li, nCol PSAY xVENC_DUP[ I ]
   nCol += 12

Next

@ 68,101 PSAY "Valor Total :"
@ 68,115 PSAY xTOT_FAT    Picture"@E@Z 99,999,999.99"
@ 68,136 PSAY Chr(18)+Chr(14)+xNUM_NF+Chr(15)+Chr( 18 )

Return (.T.)
