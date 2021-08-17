#Include "TopConn.ch"
//*****************************
/*/{Protheus.doc} fMta265I
Sol. Sr.Wadih / Projeto - Automação do Processo Solar
Função - Endereçar automaticamento  - P.E. MATA265 padrão.

@author André Salgado / INTRODE
@since 18/01/2021
@version 1.0
/*/
User Function fMta265I(_Produto,_local, _numseq, _DocSd3, _OP)

Local aCabSDA  := {}
Local aItSDB   := {}
Local aItensSDB:= {}

//Parametros de Processamento
Local cD3_COD  := _Produto //Codigo de produto
Local cD3_LOCAL:= _local   //Local do Produto
Local cD3_NUMSQ:= _numseq  //Sequencial Documento
Local cD3_DOC  := _DocSd3  //Numero Documento
Local cD3_OP   := _OP      //Ordem de Produto

Local cEndParam:= alltrim(GETMV( "ES_MTA265" ))    //Informe o Codigo do Endereço definino no CFG

Private lMsErroAuto := .F.

//Busca os Dados
dbSelectArea("SDA")
SDA->(dbGoTop())        //posiciona o cabeçalho
SDA->(dbSetOrder(1))

if SDA->(dbSeek( xfilial("SDA") + cD3_COD + cD3_LOCAL + cD3_NUMSQ + cD3_DOC ))

   if SDA->DA_SALDO > 0
      lMsErroAuto := .F.

      aCabSDA := {}
      aAdd( aCabSDA, {"DA_PRODUTO"  , SDA->DA_PRODUTO , Nil} )
      aAdd( aCabSDA, {"DA_NUMSEQ"   , SDA->DA_NUMSEQ  , Nil} )

      aItSDB := {}
      aAdd( aItSDB, {"DB_ITEM"      , "0001"          , Nil} )
      aAdd( aItSDB, {"DB_ESTORNO"   , " "             , Nil} )
      aAdd( aItSDB, {"DB_LOCALIZ"   , cEndParam       , Nil} )
      aAdd( aItSDB, {"DB_DATA"      , dDataBase       , Nil} )
      aAdd( aItSDB, {"DB_QUANT"     , SDA->DA_SALDO   , Nil} )

      aItensSDB := {}
      aadd( aItensSDB, aitSDB )
      MATA265( aCabSDA, aItensSDB, 3)

         If lMsErroAuto
            MostraErro()
         Endif
         
// comentar a liberaçao de pedidos war 03/02/2021         
/* 
      //Libera o Estoque do Pedido de Venda (05) Modulo Faturamento
      cUpSC9 := " UPDATE "+RETSqlName("SC9")+" SET C9_BLEST=' ' "
      cUpSC9 += " FROM "+RETSqlName("SC9")+" C9"
      cUpSC9 += " INNER JOIN "+RETSqlName("SC2")+" C2 ON C2_FILIAL=C9_FILIAL AND C9_PEDIDO=C2_PEDIDO AND C2_PRODUTO=C9_PRODUTO"
      cUpSC9 += "       AND  C2_NUM='"+SUBSTR(cD3_OP,1,6)+"' AND C2.D_E_L_E_T_=' ' "
      cUpSC9 += " WHERE C9_NFISCAL='' AND C9_PRODUTO='"+alltrim(cD3_COD)+"' AND C9.D_E_L_E_T_=' ' "
      TCSQLExec( cUpSC9 )  
*/
      //Cria o Produto no Cadastro de Abastecimento - (42) Modulo WMS
      u_WMSA030I(cD3_COD)

   endif
endif

Return
