#Include "RWMAKE.CH"

User Function RptRomEnt()

PRIVATE CbTxt     := ""
PRIVATE CbCont    := ""
PRIVATE nOrdem    := 0
PRIVATE Alfa      := 0
PRIVATE Z         := 0
PRIVATE M         := 0
PRIVATE tamanho   := "M"
PRIVATE limite    := 136
PRIVATE ctitulo   := PADC("rptRelRom -Relação de Entregas",74)
PRIVATE cDesc1    := PADC("Este Programa tem  a  Finalidade de Emitir a(s) Relação(ões) de Ro- ",74)
PRIVATE cDesc2    := PADC("maneio(s). Desenvolvido para Uso Exclusivo da Empresa EletroMega    ",74)
PRIVATE cDesc3    := PADC("                                                                    ",74)
PRIVATE aReturn   := { "Especial", 1,"Administracao", 2, 2, 1,"",1 }
PRIVATE nomeprog  := "rptRomEnt"
PRIVATE cPerg     := PadR("RPTENT",10)
PRIVATE nLastKey  := 0
PRIVATE lContinua := .T.
PRIVATE _nLin     := 0
PRIVATE Li        := 0
PRIVATE wnrel     := "rptRelRom"
PRIVATE ntotnf := 0 //26-05-06
PRIVATE ntotgeral := 0 //26-05-06
PRIVATE _cQuery   := ""
PRIVATE _nCubagem := 0 
PRIVATE _nCubReg  := 0
PRIVATE _nCubTot  := 0
PRIVATE _nCubFim  := 0
PRIVATE _nCubCaix := 0

_aMes := { 'Janeiro'  ,;
           'Fevereiro',;
           'Marco'    ,;
           'Abril'    ,;
           'Maio'     ,;
           'Junho'    ,;
           'Julho'    ,;
           'Agosto'   ,;
           'Setembro' ,;
           'Outubro'  ,;
           'Novembro' ,;
           'Dezembro'  ;
         }


Pergunte(cPerg,.F.)               // Pergunta no SX1

PRIVATE cString:="SF2"

Wnrel := SetPrint(cString,wnRel,cPerg,cTitulo,cDesc1,cDesc2,cDesc3,.T.,,.T.,Tamanho)

If nLastKey == 27
   Return(.T.)
Endif

SetDefault(aReturn,cString)

If nLastKey == 27
   Return(.T.)
Endif

_cQry := 'SELECT Count(*) As Rec_No '
_cQRY += 'FROM ' + RetSqlName("SD1") + ' SD1 '
_cQry += "WHERE     (SD1.D1_COD IN ('FRETE', 'REDESPACHO')) AND (SD1.D_E_L_E_T_ <> '*') AND (SD1.D1_DOC BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "') "
_cQry += "AND (SD1.D1_SERIE BETWEEN '" + MV_PAR03 + "' AND '" + MV_PAR04 + "') "
_cQry += "AND SD1.D1_FILIAL = '" + xFilial("SD1") + "' "  

//MEMOWRITE("E:\TESTESQL1.SQL",_cQry)

dbUseArea( .T., "TOPCONN", TCGENQRY(,,_cQry), 'ROM' )

_nRegua := ROM->REC_NO

ROM->( dbCloseArea() )

/* Antiga, data do comentario 25/10/12, Claudino.
_sQry := 'SELECT SD1.D1_DOC AS Doc, SD1.D1_NFORI AS NotaFiscal, SD1.D1_SERIORI AS Serie, SD1.D1_QUANT AS Qtde, '
_sQry += '       SD1.D1_TIPO AS Tipo, SD1.D1_EMISSAO AS dEmis, SD1.D1_FORNECE AS Transp, SD1.D1_LOJA AS Loja, SD1.D1_COD AS Produto '
_sQry += 'FROM ' + RetSqlName("SD1") + ' SD1 INNER JOIN ' + RetSqlName("SF1") + ' SF1 '
_sQry += "       ON SD1.D1_DOC = SF1.F1_DOC AND SD1.D1_FORNECE = SF1.F1_FORNECE AND SF1.D_E_L_E_T_ <> '*' "
_sQry += "WHERE (SD1.D1_COD IN ('FRETE', 'REDESPACHO')) AND (SD1.D_E_L_E_T_ <> '*') AND (SD1.D1_DOC BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "') "
_SQry += "AND (SD1.D1_SERIE BETWEEN '" + MV_PAR03 + "' AND '" + MV_PAR04 + "') "
_sQry += "AND SD1.D1_FILIAL = '" + xFilial("SD1") + "' AND SF1.F1_FILIAL = '" + xFilial("SF1") + "' "  // CURITIBA
_sQry += 'ORDER BY SD1.D1_NFORI'
*/

_sQry := "SELECT SA1.A1_NOME AS NomeCli, SA1.A1_ENDCOB AS EndCob, SA1.A1_CEPC AS CepCob, SA1.A1_BAIRROC AS BairroCob, "
_sQry += "       SA1.A1_MUNC AS MunCob, SA1.A1_ESTC AS EstCob, SA1.A1_CGC AS Cnpj, SA1.A1_INSCR AS Insc, "
_sQry += "       SD1.D1_DOC AS Doc, SD1.D1_NFORI AS NotaFiscal, SD1.D1_SERIORI AS Serie, SD1.D1_QUANT AS Qtde, SD1.D1_TIPO AS Tipo, "
//_sQry += "       SD1.D1_EMISSAO AS dEmis, SD1.D1_FORNECE AS Transp, SD1.D1_LOJA AS Loja, SD1.D1_COD AS Produto " Claudino 31/01/13
_sQry += "       SD1.D1_EMISSAO AS dEmis, SD1.D1_FORNECE AS Transp, SD1.D1_LOJA AS Loja, SD1.D1_COD AS Produto, F2_PBRUTO AS PesoBruto "
_sQry += "FROM " + RetSqlName("SD1") + " AS SD1 " 
_sQry += "INNER JOIN " + RetSqlName("SF1") + " AS SF1 ON SD1.D1_DOC = SF1.F1_DOC AND SD1.D1_FORNECE = SF1.F1_FORNECE " 
_sQry += "INNER JOIN " + RetSqlName("SF2") + " AS SF2 ON SD1.D1_NFORI = SF2.F2_DOC AND SD1.D1_SERIORI = SF2.F2_SERIE "
_sQry += "INNER JOIN " + RetSqlName("SA1") + " AS SA1 ON SF2.F2_CLIENTE = SA1.A1_COD AND SF2.F2_LOJA = SA1.A1_LOJA "
_sQry += "WHERE (SD1.D1_COD IN ('FRETE', 'REDESPACHO')) AND (SD1.D_E_L_E_T_ <> '*') AND (SF1.D_E_L_E_T_ <> '*') AND (SF2.D_E_L_E_T_ <> '*') "
_sQry += "		AND (SA1.D_E_L_E_T_ <> '*') AND (SD1.D1_DOC BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "') "
_sQry += "		AND (SD1.D1_SERIE BETWEEN '" + MV_PAR03 + "' AND '" + MV_PAR04 + "') " 
_sQry += "		AND SD1.D1_FILIAL = '" + xFilial("SD1") + "' AND SF1.F1_FILIAL = '" + xFilial("SF1") + "' AND SF2.F2_FILIAL = '" + xFilial("SF2") + "' "
_sQry += "ORDER BY SD1.D1_NFORI "

MEMOWRITE("E:\TESTESQL.SQL",_sQry)

dbUseArea( .T., "TOPCONN", TCGENQRY(,,_sQRY), 'ROM' )

RptStatus({|| RptDetail() })

Return

//----------------------------------------------------------------------------------------------------------
Static Function RptDetail

SetRegua( _nRegua )

Set Device To Print
SetPrc( 0,0 )

_nLin   := 55
_nPag   := 0
_cDoc   := ROM->DOC
_nNot   := 0
_nVol   := 0

_fSA1   := xFilial( 'SA1' )
_fSA2   := xFilial( 'SA2' ) 

SA2->( dbSeek( _fSA2 + ROM->Transp + ROM->Loja, .F. ) )
_cMotorista := rTrim( SA2->A2_NREDUZ )
_cTransport := SA2->A2_NOME

While ! Eof()

   If _nLin >= 55

      _dEmis := Substr( dEmis, 7, 2 )
      _dEmis += '/'
      _dEmis += Substr( dEmis, 5, 2 )
      _dEmis += '/'
      _dEmis += Substr( dEmis, 1, 4 )
      
      _nPag ++
      @ 00,00 PSay Replicate("-",130)
      @ 01,00 PSay ALLTRIM(SM0->M0_NOMECOM) 
      
      @ 02,00 PSay ALLTRIM(SM0->M0_ENDENT) + " - CEP " + TRANSFORM(ALLTRIM(SM0->M0_CEPENT),"@R 99999-999") 
      @ 03,00 PSay ALLTRIM(SM0->M0_BAIRENT) + " - " + ALLTRIM(SM0->M0_CIDENT) + " - " + ALLTRIM(SM0->M0_ESTENT)
      @ 04,00 PSay "CNPJ " + TRANSFORM(ALLTRIM(SM0->M0_CGC),"@R 99.999.999/9999-99") + " - INSC " + ALLTRIM(SM0->M0_INSC)
      
      @ 05,00 PSay Replicate("-",130)
      @ 06,00 PSay "ROMANEIO DE TRANSPORTADORA   N " + _cDoc + "/" + Str(_nPag,1) + "        Data: " + _dEmis + " " + Substr(Time(),1,5) + Chr(18)
      @ 07,00 PSay Chr(15) + "TRANSPORTADORA: " /*+ Chr(18) +*/ + _cTransport +/*+ Chr(15) +*/ " " + ;
                             "MOTORISTA: " + /*+ Chr(18) +*/ _cMotorista
                        
      @ 08,00 PSay Replicate("-",130)
      @ 10,00 PSay 'NOTA        SERIE VOLUMES  CUBAGEM     PESO BRUTO     OBSERVACOES                                                          TOTAL' //26-05-06

//       REDESPACHO           1         2         3         4         5         6         7         8         9         10        11        12        13
//                  0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789
//                  999.999.999 123   123456     ___________________________ 9,999,999.99

      @ 11,00 PSay Replicate("-",130)

      _nLin := 13

   End

   If _cDoc != ROM->DOC

      _nPag   := 0
      _cDoc := ROM->DOC
      _nLin := 55
      SA2->( dbSeek( _fSA2 + ROM->Transp + ROM->Loja, .F. ) )
      _cMotorista := rTrim( SA2->A2_NREDUZ )
      _cTransport := SA2->A2_NOME
      Loop
      
   Else

      If rTrim( Produto ) <> 'FRETE'

//                                  1
//                        012345678901
         @ _nLin,00 PSay 'REDESPACHO'
//         _nLin++

      EndIf
 
//    @ _nLin,6 PSay NotaFiscal Picture "@R 999.999.999"
      @ _nLin,00 PSay NotaFiscal Picture "@r 999.999.999" 
      @ _nLin,12 PSay Serie
      @ _nLin,17 PSay Qtde       Picture "999"
      @ _nLin,54 PSay Replicate("_",60)

      //add by felipe para colocar o valor da nf no rel em 26-05-06
    
      _cQuery := " SELECT DISTINCT(SB5.B5_COD) AS Prod, SB5.B5_COMPR AS Compri, SB5.B5_ALTURA AS ALTURA, SB5.B5_LARG AS Larg, "
      _cQuery += " SB1.B1_QE AS QuantEmb, SD2.D2_QUANT AS Quant "
      _cQuery += " FROM " + RetSqlName("SD2") + " SD2 "
      _cQuery += " INNER JOIN " + RetSqlName("SB5") + " SB5 ON SD2.D2_COD = SB5.B5_COD "
      _cQuery += " INNER JOIN " + RetSqlName("SB1") + " SB1 ON SB5.B5_COD = SB1.B1_COD "
      _cQuery += " WHERE SD2.D_E_L_E_T_ <> '*' AND SB5.D_E_L_E_T_ <> '*' AND SB1.D_E_L_E_T_ <> '*' AND (SD2.D2_DOC = '" + ROM->NotaFiscal + "') "
	  _cQuery += " AND (SD2.D2_SERIE = '" + ROM->Serie + "') "
	  _cQuery += " AND SD2.D2_FILIAL = '" + xFilial("SD2") + "' AND SB5.B5_FILIAL = '" + xFilial("SB5") + "' AND SB1.B1_FILIAL = '" + xFilial("SB1") + "' "
	  _cQuery += " ORDER BY Prod "

      //MEMOWRITE("E:\TESTESQL3.SQL",_cQuery)
      
      dbUseArea( .T., "TOPCONN", TCGENQRY(,,_cQuery), 'CUBA' )
      
      While CUBA->(!Eof())
         _nCubagem := CUBA->COMPRI * CUBA->ALTURA * CUBA->LARG
         _nCubCaix := (CUBA->QUANT / CUBA->QUANTEMB)
         _nCubReg := _nCubCaix * _nCubagem
         _nCubFim := _nCubFim + _nCubReg
         CUBA->(dBSkip())
      EndDo
              
      @ _nLin,28 PSay ROUND(_nCubFim,3) // Picture "999,999.999"
    //@ _nLin,28 PSay _nCubFim
      
      _nCubTot := _nCubTot + ROUND(_nCubFim,3)
    //_nCubTot := _nCubTot + _nCubFim
      
      _nCubFim := 0
      
      dbclosearea("CUBA")
      DbSelectArea("SF2")
      If SF2->( dbSeek( xFilial("SF2") + ROM->NotaFiscal + ROM->Serie, .F. ) )
 		
 		ntotnf := SF2->F2_VALMERC + SF2->F2_ICMSRET + SF2->F2_VALIPI  //SF2->F2_VALBRUT 17-04-08

      EndIf

      dbclosearea("SF2")
      dbselectarea("ROM")
      @ _nLin,38 PSay ROM->PesoBruto  Picture "@e 9,999,999.99"
      @ _nLin,117 PSay ntotnf Picture "@e 9,999,999.99"
      _nLin += 1
      
      @ _nLin,05 PSay ALLTRIM(ROM->NomeCli)
      _nLin += 1
      @ _nLin,05 PSay ALLTRIM(ROM->EndCob) + " - CEP " + TRANSFORM(ALLTRIM(ROM->CepCob),"@R 99999-999")
      _nLin += 1
      @ _nLin,05 PSay ALLTRIM(ROM->BairroCob) + " - " + ALLTRIM(ROM->MunCob) + " - " + ALLTRIM(ROM->EstCob)
      _nLin += 1
      @ _nLin,05 PSay "CNPJ " + TRANSFORM(ALLTRIM(ROM->Cnpj),"@R 99.999.999/9999-99") + " - INSC " + ALLTRIM(ROM->Insc)
      
      _nLin += 2
   
   End

   ntotgeral += ntotnf   //26-05-06
   _nNot ++
   _nVol += Qtde
   ROM->( dbSkip() )
   IncRegua()

   If _cDoc != ROM->DOC

      _nNot := Str( _nNot, 5 )
      _nNot := lTrim( _nNot )

      _nVol := Str( _nVol, 5 )
      _nVol := lTrim( _nVol )

      _nLin ++
      @ _nLin,00 PSay 'Sao Paulo, ' + Str( Day( MV_PAR05 ), 2 ) + ' de ' + _aMes[ Month( MV_PAR05 ) ] + ' de ' + Str( Year( MV_PAR05 ), 4 ) + '.'

      _nLin += 3
      @ _nLin,00 PSay '_____________________________________        __________________________________'
      _nLin ++
      //@ _nLin,00 PSay '             MOTORISTA                       ELETROMEGA COM. MATS. ELETRICOS LTDA.'
      @ _nLin,00 PSay '             MOTORISTA                            ' + AllTrim(SM0->M0_NOMECOM)
      _nLin += 2

      @ _nLin,00 PSay 'QUANTIDADE DE NOTA(S): ' + _nNot
      _nLin ++
      @ _nLin,00 PSay 'TOTA(L)(IS) DE VOLUME(S): ' + _nVol
      _nLin ++  
      @ _nLin,00 PSay 'TOTA(L)(IS) DE CUBAGEM(S): ' + cValtoChar(ROUND(_nCubTot,3))
    //@ _nLin,00 PSay 'TOTA(L)(IS) DE CUBAGEM(S): ' + cValtoChar(_nCubTot)
      _nLin ++
      @ _nLin,00 PSay 'TOTAL GERAL: '+TRANSFORM(ntotgeral,"@E 9999,999.99")
      
      ntotgeral := 0 //26-05-06
      _nVol := 0
      _nNot := 0

   End

End

__Eject()

Set Device To Screen

If aReturn[ 5 ] == 1
   dbCommitAll()
   OurSpool( wnrel )
End

MS_Flush()
Set Printer To

ROM->( dbCloseArea() )

Return
