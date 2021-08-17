#IFNDEF WINDOWS
   #DEFINE PSAY SAY
#ENDIF
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³  Mega08  ³ Autor ³Airton Lira            ³ Data ³07/08/2002³±±
alterado santana
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Impressao da "Troca  "   - Uso Exclusivo da Eletromega     ³±±
±±³Acertos no SE1														  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros                         ³
//³ mv_par01             // Da Troca                             ³
//³ mv_par02             // Ate a Troca                          ³
//³ mv_par03             // Da Serie                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
User Function RptTrcMd()

#Include "rwmake.ch"
PRIVATE CbTxt:=""
PRIVATE CbCont:=""
PRIVATE nOrdem :=0
PRIVATE Alfa := 0
PRIVATE Z:=0
PRIVATE M:=0
PRIVATE tamanho:="G"
PRIVATE limite:=220
PRIVATE titulo :=PADC("rptTrcMd -Troca de Mercadoria",74)
PRIVATE cDesc1 :=PADC("Este Programa tem a Finalidade de Emitir a(s) Troca(s)   Gerada(s)  ",74)
PRIVATE cDesc2 :=PADC("pelo Sistema.Desenvolvido para Uso Exclusivo da Empresa EletroMega  ",74)
PRIVATE cDesc3 :=PADC("                                                                    ",74)
PRIVATE cNatureza:=""
PRIVATE aReturn := { "Especial", 1,"Administracao", 1, 2, 1,"",1 }
PRIVATE nomeprog:="rptTrcMd"
PRIVATE cPerg:=PadR("RPTTRC",10)
PRIVATE nLastKey:= 0
PRIVATE lContinua := .T.
PRIVATE nLin:=0
PRIVATE wnrel := "rptTrcMd"

Pergunte(cPerg,.F.)               // Pergunta no SX1

PRIVATE cString:="SF2"

Wnrel:=SetPrint(cString,wnrel,cPerg,Titulo,cDesc1,cDesc2,cDesc3,.T.)

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

Static Function RptDetail()

_nRegua := Val( MV_PAR02 )
_nRegua =- Val( MV_PAR01 )
_nRegua ++

SetRegua( _nRegua )

dbSelectArea("SF2")                // * Cabecalho da Nota Fiscal Saida
dbSetOrder(1)
dbSeek(xFilial()+mv_par01+mv_par03,.t.)
        
dbSelectArea("SD2")                // * Itens de Venda da Nota Fiscal
dbSetOrder(3)
dbSeek(xFilial()+mv_par01+mv_par03)
cPedant := SD2->D2_PEDIDO

IF SD2->D2_TES != "599"
   Set Device To Screen
   Aviso("Aviso","Voce esta tentando imprimir uma nf ou orcamento como troca",{"OK"})
   Return
Endif   

While !Eof() .And. D2_DOC == mv_par01 .And. D2_SERIE == mv_par03 .And.;
	D2_FILIAL == xFilial("SD2") // CURITIBA 
	
   Select SC6
   Set Order To 1
   Seek xFilial()+SD2->D2_PEDIDO+SD2->D2_ITEMPV+SD2->D2_COD
   If C6_PRCVEN <> SD2->D2_PRCVEN
      Set Device To Screen
      Aviso("Aviso","Houve um erro na geracao do Orcamento confira o Pedido N." + SD2->D2_PEDIDO,{"OK"})
      Aviso("Aviso","Verifique o Produto : "+SD2->D2_COD+" Preco Ped. "+AllTrim(Transf(C6_PRCVEN,"@E 9,999.99999"))+" Preco nf. "+AllTrim(Transf(SD2->D2_PRCVEN,"@E 9,999.99999")),{"OK"})
      Return
   EndIf
   Select SD2
   Skip
EndDo

dbSelectArea("SD2")                // * Itens de Venda da Nota Fiscal
dbSetOrder(3)
dbSeek(xFilial()+mv_par01+mv_par03)
cPedant := SD2->D2_PEDIDO

dbSelectArea("SF2")
While ! Eof()                 .And.;
      SF2->F2_DOC <= mv_par02 .And.;
      lContinua .And.;
      SF2->F2_FILIAL == xFilial("SF2") // CURITIBA
        
   IncRegua()
   If SF2->F2_SERIE # mv_par03    // Se a Serie do Arquivo for Diferente
      dbSkip()                    // do Parametro Informado !!!
      Loop
   End
        
   IF LastKey()==286
         @ 00,01 PSAY "** CANCELADO PELO OPERADOR **"
         lContinua := .F.
         Exit
   Endif
        
   xNum_Nf     :=SF2->F2_DOC             // Numero
   xSerie      :=SF2->F2_SERIE           // Serie
   xEmissao    :=SF2->F2_EMISSAO         // Data de Emissao
   xTot_Fat    :=SF2->F2_VALFAT          // Valor Total da Fatura
   If xTot_Fat == 0
      xTot_Fat := SF2->F2_Valmerc+SF2->F2_Valipi+SF2->F2_Seguro+SF2->F2_Frete
   Endif

   xLOJA       :=SF2->F2_LOJA            // Loja do Cliente
   xFRETE      :=SF2->F2_FRETE           // Frete
   xSEGURO     :=SF2->F2_SEGURO          // Seguro
   xBASE_ICMS  :=SF2->F2_BASEICM         // Base   do ICMS
   xBASE_IPI   :=SF2->F2_BASEIPI         // Base   do IPI
   xVALOR_ICMS :=SF2->F2_VALICM          // Valor  do ICMS
   xICMS_RET   :=SF2->F2_ICMSRET         // Valor  do ICMS Retido
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
   //dbSeek(xFilial()+xNUM_NF+xSERIE)
   dbSeek(xFilial("SD2")+xNUM_NF+xSERIE)
       
   cPedAtu  := SD2->D2_PEDIDO
   cItemAtu := SD2->D2_ITEMPV
        
   xPED_VEND :={}                         // Numero do Pedido de Venda
   xITEM_PED :={}                         // Numero do Item do Pedido de Venda
   xNUM_NFDV :={}                         // nUMERO QUANDO HOUVER DEVOLUCAO
   xPREF_DV  :={}                         // Serie  quando houver devolucao
   xICMS     :={}                         // Porcentagem do ICMS
   xCOD_PRO  :={}                         // Codigo  do Produto
   xCOD_LOC  :={}                         // local
   xQTD_PRO  :={}                         // Peso/Quantidade do Produto
   xPRE_UNI  :={}                         // Preco Unitario de Venda
   xPRE_TAB  :={}                         // Preco Unitario de Tabela
   xIPI      :={}                         // Porcentagem do IPI
   xVAL_IPI  :={}                         // Valor do IPI
   xDESC     :={}                         // Desconto por Item
   xVAL_DESC :={}                         // Valor do Desconto
   xVAL_MERC :={}                         // Valor da Mercadoria
   xTES      :={}                         // TES
   xCF       :={}                         // Classificacao quanto natureza da Operacao
   xICMSOL   :={}                         // Base do ICMS Solidario
   xICM_PROD :={}                         // ICMS do Produto
   xUNID_PRO :={}                           // Unidade do Produto        
   xNF_ORI   :={}                           // Unidade do Produto        

   While !eof() .and. SD2->D2_DOC==xNUM_NF .and. SD2->D2_SERIE==xSERIE .And.;
   		SD2->D2_FILIAL == xFilial("SD2") // CURITIBA
   		
      If SD2->D2_SERIE # mv_par03        // Se a Serie do Arquivo for Diferente
         dbSkip()                   // do Parametro Informado !!!
         Loop
      Endif
      AADD(xPED_VEND ,SD2->D2_PEDIDO)
      AADD(xITEM_PED ,SD2->D2_ITEMPV)
      AADD(xNUM_NFDV ,IIF(Empty(SD2->D2_NFORI),"",SD2->D2_NFORI))
      AADD(xPREF_DV  ,SD2->D2_SERIORI)
      AADD(xUNID_PRO ,SD2->D2_UM)
      AADD(xICMS     ,IIf(Empty(SD2->D2_PICM),0,SD2->D2_PICM))
      AADD(xCOD_PRO  ,SD2->D2_COD)
      AADD(xCOD_LOC  ,SD2->D2_LOCAL)
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
      AADD(xVAl_DESC ,SD2->D2_DESCON)
      AADD(xNF_ORI   ,If( ! Empty( SD2->D2_NFORI ), SD2->D2_NFORI, SD2->D2_DOC ) )
      dbskip()
   End
        
   dbSelectArea("SB1")                     // * Desc. Generica do Produto
   dbSetOrder(1)
   xPESO_PRO:={}                           // Peso Liquido
   xPESO_UNIT :={}                         // Peso Unitario do Produto
   xCOD_TRIB:={}                           // Codigo de Tributacao
   xMEN_TRIB:={}                           // Mensagens de Tributacao
   xCOD_FIS :={}                           // Cogigo Fiscal
   xCLAS_FIS:={}                           // Classificacao Fiscal
   xMEN_POS :={}                           // Mensagem da Posicao IPI
   xISS     :={}                           // Aliquota de ISS
   xTIPO_PRO:={}                           // Tipo do Produto
   xLUCRO   :={}                           // Margem de Lucro p/ ICMS Solidario
   xCLFISCAL   :={}
   
   I:=1
        
   dbSelectArea("SB1")         
   dbsetOrder(1)
   For I:=1 to Len(xCOD_PRO)
      dbSeek(xFilial()+xCOD_PRO[I])
      AADD(xPESO_PRO ,SB1->B1_PESO * xQTD_PRO[I])
      AADD(xPESO_UNIT , SB1->B1_PESO)
      xPESO_LIQUID:= 0                                 // Peso Liquido da Nota Fiscal
      xPESO_LIQ   := 0
      For I:=1 to Len(xPESO_PRO)
	  xPESO_LIQ   := xPESO_LIQ   + xPESO_PRO[I]
      Next

      For I:=1 to Len(xPESO_PRO)
          xPESO_LIQUID:= xPESO_LIQUID+ xPESO_LIQ
      Next
   Next

//-----------------------------------------

   dbSelectArea("SD1")                   // * Itens de Venda da N.F.
   dbSetOrder(1)
   dbSeek(xFilial()+xNUM_NF+xSERIE)
       
   cPedAtu  := SD1->D1_PEDIDO
   cItemAtu := SD1->D1_ITEMPV

   ePED_VEND :={}                         // Numero do Pedido de Venda
   eITEM_PED :={}                         // Numero do Item do Pedido de Venda
   eNUM_NFDV :={}                         // nUMERO QUANDO HOUVER DEVOLUCAO
   ePREF_DV  :={}                         // Serie  quando houver devolucao
   eICMS     :={}                         // Porcentagem do ICMS
   eCOD_PRO  :={}                         // Codigo  do Produto
   eCOD_LOC  :={}                         // Local
   eQTD_PRO  :={}                         // Peso/Quantidade do Produto
   ePRE_UNI  :={}                         // Preco Unitario de Venda
   ePRE_TAB  :={}                         // Preco Unitario de Tabela
   eIPI      :={}                         // Porcentagem do IPI
   eVAL_IPI  :={}                         // Valor do IPI
   eDESC_PRO :={}                         // Desconto por Item
   eVAL_DESC :={}                         // Valor do Desconto
   eVAL_MERC :={}                         // Valor da Mercadoria
   eTES      :={}                         // TES
   eCF       :={}                         // Classificacao quanto natureza da Operacao
   eICMSOL   :={}                         // Base do ICMS Solidario
   eICM_PROD :={}                         // ICMS do Produto
   eUNID_PRO :={}                         // Unidade do Produto        
   eNF_ORI   :={}                         // Nota Fiscal Origem

   If Eof()
      AADD(ePED_VEND ,SD1->D1_PEDIDO)
      AADD(eITEM_PED ,SD1->D1_ITEMPC)
      AADD(eNUM_NFDV ,IIF(Empty(SD1->D1_NFORI),"",SD1->D1_NFORI))
      AADD(ePREF_DV  ,SD1->D1_SERIORI)
      AADD(eUNID_PRO ,SD1->D1_UM)
      AADD(eICMS     ,IIf(Empty(SD1->D1_PICM),0,SD1->D1_PICM))
      AADD(eCOD_PRO  ,SD1->D1_COD)
      AADD(eCOD_LOC  ,SD1->D1_LOCAL)
      AADD(eQTD_PRO  ,SD1->D1_QUANT)     // Guarda as quant. da NF
      AADD(ePRE_UNI  ,SD1->D1_VUNIT - ( SD1->D1_VALDESC / SD1->D1_QUANT ) )
      AADD(ePRE_TAB  ,SD1->D1_VUNIT - ( SD1->D1_VALDESC / SD1->D1_QUANT ) )
      AADD(eIPI      ,IIF(Empty(SD1->D1_IPI),0,SD1->D1_IPI))
      AADD(eVAL_IPI  ,SD1->D1_VALIPI)
      AADD(eDESC_PRO ,RetField( 'SB1',1,xFilial('SB1')+SD1->D1_COD,'SB1->B1_DESC'))
      AADD(eVAL_MERC ,SD1->D1_TOTAL - SD1->D1_VALDESC )
      AADD(eTES      ,SD1->D1_TES)
      AADD(eCF       ,SD1->D1_CF)
      AADD(eICM_PROD ,IIf(Empty(SD1->D1_PICM),0,SD1->D1_PICM))
      AADD(eVAl_DESC ,SD1->D1_VALDESC )
      AADD(eNF_ORI   ,SD1->D1_NFORI   )
   Else
      While !eof() .and. SD1->D1_DOC==xNUM_NF .and. SD1->D1_SERIE==xSERIE .And.;
      		SD1->D1_FILIAL == xFilial("SD1") // CURITIBA

         If SD1->D1_SERIE # mv_par03        // Se a Serie do Arquivo for Diferente
           dbSkip()                   // do Parametro Informado !!!
            Loop
         Endif

        AADD(ePED_VEND ,SD1->D1_PEDIDO)
        AADD(eITEM_PED ,SD1->D1_ITEMPC)
        AADD(eNUM_NFDV ,IIF(Empty(SD1->D1_NFORI),"",SD1->D1_NFORI))
        AADD(ePREF_DV  ,SD1->D1_SERIORI)
        AADD(eUNID_PRO ,SD1->D1_UM)
        AADD(eICMS     ,IIf(Empty(SD1->D1_PICM),0,SD1->D1_PICM))
        AADD(eCOD_PRO  ,SD1->D1_COD)
        AADD(eCOD_LOC  ,SD1->D1_LOCAL)
        AADD(eQTD_PRO  ,SD1->D1_QUANT)     // Guarda as quant. da NF
        AADD(ePRE_UNI  ,SD1->D1_VUNIT - ( SD1->D1_VALDESC / SD1->D1_QUANT ) )
        AADD(ePRE_TAB  ,SD1->D1_VUNIT - ( SD1->D1_VALDESC / SD1->D1_QUANT ) )
        AADD(eIPI      ,IIF(Empty(SD1->D1_IPI),0,SD1->D1_IPI))
        AADD(eVAL_IPI  ,SD1->D1_VALIPI)
        AADD(eDESC_PRO ,RetField( 'SB1',1,xFilial('SB1')+SD1->D1_COD,'SB1->B1_DESC'))
        AADD(eVAL_MERC ,SD1->D1_TOTAL - SD1->D1_VALDESC )
        AADD(eTES      ,SD1->D1_TES)
        AADD(eCF       ,SD1->D1_CF)
        AADD(eICM_PROD ,IIf(Empty(SD1->D1_PICM),0,SD1->D1_PICM))
        AADD(eVAl_DESC ,SD1->D1_VALDESC )
        AADD(eNF_ORI   ,SD1->D1_NFORI   )
        dbskip()
      End
   End
        
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
         xCOD_MENS   :=SC5->C5_MENPAD             // Codigo da Mensagem Padrao
         //xMENSAGEM   :=SC5->C5_MENNOTA            // Mensagem para a Nota Fiscal
         xMENSAGEM   :=SC5->C5_MSGNOTA
         xTPFRETE    :=SC5->C5_TPFRETE            // Tipo de Entrega
         xCONDPAG    :=SC5->C5_CONDPAG            // Condicao de Pagamento
         xPESO_BRUTO :=SC5->C5_PBRUTO             // Peso Bruto
         xPESO_LIQ   :=SC5->C5_PESOL              // Peso Liquido
         xCOD_VEND   := SC5->C5_VEND1             // Codigo do Vendedor 1
         xTipoPed    := SC5->C5_Orcam             // Verifica se ‚ Vale !
         xAVISOCRED  := SC5->C5_AVISO             // Aviso Sobre o Credito
         xDESC_NF    := { SC5->C5_DESC1,;         // Desconto Global 1
                          SC5->C5_DESC2,;         // Desconto Global 2
                          SC5->C5_DESC3,;         // Desconto Global 3
                          SC5->C5_DESC4 }         // Desconto Global 4

         AADD(xPED,xPED_VEND[I])
      Endif
                
   Next
        
   dbSelectArea("SE4")                    // Condicao de Pagamento
   dbSetOrder(1)
   dbSeek(xFilial("SE4")+xCONDPAG)
   xDESC_PAG := SE4->E4_DESCRI
        
   dbSelectArea("SC6")                    // * Itens de Pedido de Venda
   dbSetOrder(1)
   xPED_CLI :={}                          // Numero de Pedido
   xDESC_PRO:={}                          // Descricao aux do produto
   J:=Len(xPED_VEND)
   For I:=1 to J
      dbSeek(xFilial()+xPED_VEND[I]+xITEM_PED[I])
      AADD(xPED_CLI ,SC6->C6_PEDCLI)
      AADD(xDESC_PRO,SC6->C6_DESCRI)
   Next
        
   If xTIPO=='N' .OR. xTIPO=='C' .OR. xTIPO=='P' .OR. xTIPO=='I' .OR. xTIPO=='S' .OR. xTIPO=='T' .OR. xTIPO=='O'
      dbSelectArea("SA1")                // * Cadastro de Clientes
      dbSetOrder(1)
      dbSeek(xFilial()+xCLIENTE+xLOJA)
      xCOD_CLI :=SA1->A1_COD             // Codigo do Cliente
      xNOME_CLI:=SA1->A1_NOME            // Nome
      xEND_CLI :=SA1->A1_END             // Endereco
      xBAIRRO  :=SA1->A1_BAIRRO          // Bairro
      xCEP_CLI :=SA1->A1_CEP             // CEP
      xCOB_CLI :=SA1->A1_ENDCOB          // Endereco de Cobranca
      xCEP_COB :=SA1->A1_CEPC          // CEP de Cobranca
      xEST_COB :=SA1->A1_ESTC          // Estado  de Cobranca      
      xMUN_COB :=SA1->A1_MUNC          // Municipio  de Cobranca 
      xREC_CLI :=SA1->A1_ENDENT          // Endereco de Entrega
      xMUN_CLI :=SA1->A1_MUN             // Municipio
      xEST_CLI :=SA1->A1_EST             // Estado
      xCGC_CLI :=SA1->A1_CGC             // CGC
      xINSC_CLI:=SA1->A1_INSCR           // Inscricao estadual
      xTRAN_CLI:=SA1->A1_TRANSP          // Transportadora
      xTEL_CLI :=SA1->A1_TEL             // Telefone
      xFAX_CLI :=SA1->A1_FAX             // Fax
      xREGIAO  :=SA1->A1_REGIAO          // REGIAO DO CLIENTE
   Else
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
      xREGIAO  := " "
   Endif

   dbSelectArea("SA3")                   // * Cadastro de Vendedores
   dbSetOrder(1)
   xVENDEDOR:={}                         // Nome do Vendedor
   I:=1
   dbSeek(xFilial()+xCOD_VEND)
   xNome_Vend := xCOD_VEND + ' ' + SA3->A3_NREDUZ
        
   dbSelectArea("SA4")                   // * Transportadoras
   dbSetOrder(1)
   dbSeek(xFilial()+SF2->F2_TRANSP)
   xNOME_TRANSP :=SA4->A4_NOME           // Nome Transportadora
   xEND_TRANSP  :=SA4->A4_END            // Endereco
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

   If ( SE1->( dbSeek( xFilial( 'SE1' )+xSERIE+xNUM_DUPLIC+'ANCC', .F. ) ) )

      _nReg := SE1->( RecNo() )
      _nDct := SE1->E1_VALOR

   Else

      _nReg := 0
      _nDct := 0

   End

   xDUPLICATAS:=IIF(dbSeek(xFilial()+xSERIE+xNUM_DUPLIC,.T.),.T.,.F.) // Flag p/Impressao de Duplicatas
        
   while !eof() .and. SE1->E1_NUM==xNUM_DUPLIC .AND. SE1->E1_PREFIXO == XSERIE .and. xDUPLICATAS==.T.

      If !("NF" $ SE1->E1_TIPO)
         dbSkip()
         Loop
      Endif

      AADD(xPARC_DUP ,SE1->E1_PARCELA)
      AADD(xVENC_DUP ,SE1->E1_VENCTO)
      AADD(xVALOR_DUP,SE1->E1_VALOR)
      nQTDE_DUP ++

      _nDct -= SE1->E1_SALDO

//      If _nDct SE1->E1_SALDO := 0


      dbSkip()

   EndDo
        
   dbSelectArea("SF4")                   // * Tipos de Entrada e Saida
   dbSetOrder(1)
   dbSeek(xFilial()+xTES[1])
   xNATUREZA:=SF4->F4_TEXTO              // Natureza da Operacao

   IncRegua()        
   Imprime()
   nLin := 0

   BaixaTit()
        
   dbSelectArea("SF2")
   dbSkip()                      // passa para a proxima Nota Fiscal
       
EndDo

dbSelectArea("SF2")
Retindex("SF2")
dbSelectArea("SD2")
Retindex("SD2")
dbSelectArea("SD1")
Retindex("SD1")

@ 0,0 PSAY Chr( 27 ) + '@'

If aReturn[5] == 1

   dbcommitAll()
   Ourspool(wnrel)

Endif

Ms_Flush()
Set Device To Screen
Set Printer TO

Return

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

Static Function VerImp

nLin:= 0                // Contador de Linhas
nLinIni:=0
If aReturn[5]==2
   nOpc       := 1
   #IFNDEF WINDOWS
   cCor       := "B/BG"
   #ENDIF
   While .T.
      SetPrc(0,0)
      dbCommitAll()
                
      @ nLin ,000 PSAY " "
      @ nLin ,004 PSAY "."
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

@ 0,0  PSAY Chr( 27 ) + 'C' + Chr( 66 ) + Chr( 20 )
@ 1,1 PSAY Chr( 14 ) + 'T R O C A   D E   M E R C A D O R I A'
Li := 002
@ Li,000 PSAY Chr(18)+"  "
@ Li,004 PSAY "Dados Cadastrais."
Li := Li + 1
@ Li,003 PSAY "Cliente   : "+xCliente+"/"+xLoja+" "+xNome_Cli
@ Li,067 PSAY xNum_NF
Li := Li + 1
@ Li,003 PSAY "Endereco  : "+xEnd_Cli 
Li := Li + 1
@ Li,003 PSAY "Bairro    : "+xBairro
Li := Li + 1
@ Li,003 PSAY "Municipio : "+xMun_Cli+"      Estado  : "+xEst_Cli
If xTipoPed == "V"
   @ Li,066 PSAY "V A L E"
Endif
Li := Li + 1
@ Li,003 PSAY "Cep       : "+xCep_Cli + "             Tel.    : "+xTel_Cli+"         "+xREGIAO
Li := Li + 1
@ Li,003 PSAY "CGC / CPF : "+xCgc_Cli 
@ Li,036 PSAY "IE / RG : "+xInsc_Cli
Li := Li + 1
@ Li,003 PSAY "Transp.   : "+xNome_Transp+" Emissao : "+Dtoc(xEmissao)
Li := Li + 1
@ Li,003 PSAY "Cond.Pagto: "+xCond_Pag+"  "+SC5->C5_CDPG
@ Li,065 PSAY "HORA: " + Substr( Time(), 1, 5 )

Li := Li + 1
nColDup := 3
For nDup := 1 To Len(xVenc_Dup)
   If nDup == 3
       nColDup := 000
       Li := Li + 1
   Endif
   @ Li,nColDup PSAY AllTrim(Str(nDup))+"o. Vencto: "+Dtoc(xVenc_Dup[nDup]) 
   nColDup := nColDup + 21
   @ Li,nColDup PSAY "Valor : "
   @ Li,nColDup+6 PSAY xValor_Dup[nDup] Picture "999999.99"
   nColDup := nColDup + 16
Next

Li := Li + 1
@ Li,079 PSAY Chr(15)+" "
Li := Li + 1
@ Li,005 PSAY Repl("-",125)
Li := Li + 1
@ Li,005 PSAY "It Codigo    Local Descricao do Material                      UM          Qtde.         R$ Unit.        R$ Total  Origem"
Li := Li + 1
@ Li,005 PSAY Repl("-",125)
Li := Li + 1

eAc_Total := 0
_nLen := Len( eCod_Pro )

For eNum := 1 To _nLen
   @ Li,005 PSAY StrZero(eNum,2) Picture "99"
   @ Li,008 PSAY Substr( eCod_Pro[ eNum ], 1, 6 )
   @ Li,021 PSAY eCod_Loc[ eNum ]
   @ Li,024 PSAY Substr( eDESC_PRO[ eNum ], 1, 42 )
   @ Li,067 PSAY eUNID_PRO[ eNum ]
   @ Li,074 PSAY eQtd_Pro[ eNum ] Picture "@E 99,999.99999"
   @ Li,090 PSAY ePre_Uni[ eNum ] Picture "@E 9,999.99999"
   @ Li,107 PSAY eVal_Merc[ eNum ] Picture "@E 999,999.99"
   @ Li,119 PSAY eNF_ORI[ eNum ] Picture "@R 999.999"
   eAc_Total += eVal_Merc[ eNum ]
   Li ++
Next

@ Li,107 PSAY "----------"
Li ++

@ Li,075 PSAY "Totais Entrada ---- >"
@ Li,107 PSAY eAc_Total Picture "@E 999,999.99"
Li ++
@ Li,005 PSAY Repl("-",125)
Li += 2

nAc_Total := 0
_nLen := Len( xCod_Pro )    

For xNum:=1 to Len(xCod_Pro)
   @ Li,005 PSAY StrZero( xNum, 2 ) Picture "99"
   @ Li,008 PSAY Substr( xCod_Pro[ xNum ], 1, 6 )
   @ Li,021 PSAY xCod_Loc[ xNum ]
   @ Li,024 PSAY xDESC_PRO[ xNum ]
   @ Li,067 PSAY xUNID_PRO[ xNum ]
   @ Li,073 PSAY xQtd_Pro[ xNum ]  Picture "@E 99,999.99999"
   @ Li,090 PSAY xPre_Uni[ xNum ]  picture "@E 9,999.99999"
   @ Li,107 PSAY xVal_Merc[ xNum ] Picture "@E 999,999.99"
   @ Li,119 PSAY xNF_ORI[ xNum ]   Picture "@R 999.999"
   nAc_Total += xVal_Merc[ xNum ]
   Li ++
Next

@ Li,107 PSAY "----------"
Li ++

@ Li,075 PSAY "Totais Saidas ----- >"
@ Li,107 PSAY nAc_Total Picture "@E 999,999.99"

Li ++
@ Li,107 PSAY "----------"
Li ++

_nTotal := nAc_Total
_nTotal -= eAc_Total

If _nTotal > 0

   @ Li,075 PSAY Chr( 27 )+'E'+Chr( 27 )+'4'+Chr( 27 )+'-1Cliente Deve'+Chr( 27 )+'F'+Chr( 27 )+'5'+Chr( 27 )+'-0  ----- >'
   @ Li,000 PSAY ' '

Else

   @ Li,075 PSAY "Total Geral   ----- >"

End

@ Li,107 PSAY _nTotal Picture "@E( 999,999.99"

Li ++
@ Li,005 PSAY Repl("-",120)

Li := 53

@ Li,005 PSAY "Mensagem  : "+xMensagem
LI := LI + 1
@ Li,005 PSAY "N/ Pedido : "+xPed_Vend[1]+"       Vendedor : "+xNome_Vend
LI := LI + 1
@ Li,005 PSAY "Hora : "+Alltrim(Subs(Time(),0)) 
li := Li + 1
@ Li,005 PSAY " "
// Cod.Barra : "+Alltrim(STR((Day(SC5->C5_EMISSAO)*Month(SC5->C5_EMISSAO))+Year(SC5->C5_EMISSAO),0)+"9"+Subs(SC5->C5_Num,1,2)+Subs(SC5->C5_Num,5,2)+Subs(SC5->C5_Num,3,2)+Alltrim(StrZero(SC5->C5_TOTMAR,3)+"909"))
LI := LI + 1
@ Li,005 PSAY "Credito   : "+xAvisoCred
LI := LI + 1
@ lI,005 PSAY "ATENCAO   : DEVOLUCOES Somente Serao Aceitas Ate 48hs do Recebimento do Material, Apos Previa Consulta ao Nosso Depto.Vendas"
Li := Li + 2
nColDup := 5
For nDup := 1 To Len(xVenc_Dup)
   @ Li,nColDup PSAY Dtoc(xVenc_Dup[nDup]) 
   nColDup := nColDup + 12
Next

LI := LI + 1

@ Li,000 PSAY Chr(18)+" "
@ Li,005 PSAY "Valor Total : "+Alltrim(Str(nAc_Total))

If xTipoPed == "V"
   @ Li,066 PSAY "V A L E"
Endif

Return (.T.)

Static Function BaixaTit()

_fSE1 := xFilial( 'SE1' )
_fSE5 := xFilial( 'SE5' )

SE1->( dbSeek( _fSE1        +;
               'TRC'        +;
               SC5->C5_NOTA +;
               'A'          +;
               'NCC'        ,;
               .F.           ;
             );
     )

_nValor := SE1->E1_Valor
_nRec   := SE1->( RecNo() )

SE1->( dbSeek( _fSE1        +;
               'TRC'        +;
               SC5->C5_NOTA +;
               ' '          +;
               'NF '        ,;
               .F.           ;
             );
     )

_nBaixa := SE1->E1_VALOR 
_nBaixa -= _nValor

ReplSE1()

SE1->( dbGoTo( _nRec ) )
         
ReplSE1()

Return(NIL)


Static Function ReplSE1()

SE1->( rLock() )

If _nBaixa <= 1

   SE1->E1_SALDO := 0
   _nBaixa       *= -1

Else

   SE1->E1_SALDO := _nBaixa
   _nBaixa       *= -1

End

SE1->E1_BAIXA   := SE1->E1_VENCORI
SE1->E1_MOVIMEN := dDataBase
SE1->E1_STATUS  := 'B'
SE1->E1_VEND1   := '      '
SE1->E1_HIST    := 'Baixa automatica troca'
SE1->E1_COMIS1  := 0
SE1->E1_BASCOM1 := 0
SE1->E1_VALCOM1 := 0
SE1->E1_VALLIQ  := SE1->E1_VALOR - SE1->E1_SALDO

TCRefresh( 'SE5' )
RecLock( 'SE5', .T. )

SE5->E5_FILIAL  := _fSE5
SE5->E5_DATA    := dDataBase
SE5->E5_TIPO    := SE1->E1_TIPO
SE5->E5_VALOR   := SE1->E1_VALLIQ
SE5->E5_NATUREZ := SE1->E1_NATUREZ
SE5->E5_DOCUMEN := SE1->E1_PREFIXO +;
                   SE1->E1_NUM     +;
                   if( SE1->E1_TIPO <> 'NF ', ' NF ', 'ANCC' ) +;
                   SE1->E1_MSFIL
SE5->E5_RECPAG  := 'R'
SE5->E5_SEQ     := '01'
SE5->E5_BENEF   := SE1->E1_NOMCLI
SE5->E5_HISTOR  := 'Compesação automatica de titulo'
SE5->E5_TIPODOC := if( SE1->E1_TIPO <> 'NF ', 'BA', 'CP' )
SE5->E5_VLMOED2 := SE1->E1_VALLIQ
SE5->E5_LA      := 'N'
SE5->E5_LOTE    := '8850'
SE5->E5_PREFIXO := SE1->E1_PREFIXO
SE5->E5_NUMERO  := SE1->E1_NUM
SE5->E5_PARCELA := SE1->E1_PARCELA
SE5->E5_CLIFOR  := SE1->E1_CLIENTE
SE5->E5_LOJA    := SE1->E1_LOJA
SE5->E5_DTDIGIT := dDataBase
SE5->E5_MOTBX   := 'CMP'
SE5->E5_DTDISPO := dDataBase

SE5->( MsUnLock() )

Return(NIL)
