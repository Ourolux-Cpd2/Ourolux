
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCNVCONT   บAutor  ณMicrosiga           บ Data ณ  05/03/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Alterado em 03/05/2010 - NFE war                           บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP10                                                       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

#INCLUDE 'rwmake.ch'
User Function CnvCont()
cSer := SPACE(3)

lEnd  := .F.
_dPri := Ctod( Space( 08 ) )
_dUlt := Ctod( Space( 08 ) )

@ 56,42 TO 323,505 DIALOG oDlg6 TITLE "Exporta็ใo para Contabem"
@ 8,10 TO 84,222
@ 33,24 Say 'Data Inicial'
@ 33,60 Say 'Data Final  '
@ 33,96 Say 'Serie'
@ 43,24 Get _dPri Picture '@R 99/99/99' Size 35,8
@ 43,60 Get _dUlt Picture '@R 99/99/99' Size 35,8
@ 43,96 Get cSer valid !Empty(cSer)//Picture '@R 99/99/99' Size 35,8 
@ 91,160 BMPBUTTON TYPE 1 ACTION Processa( {|lEnd| Grava() }, 'Aguarde, exportando....' )
@ 91,190 BMPBUTTON TYPE 2 ACTION Close(oDlg6)
@ 110,44 Say 'Esta rotina tem como finalidade realizar a exporta็ใo das,'
@ 120,44 Say 'Notas Fiscais de Saida e Entrada para o sistema Contimatic'

ACTIVATE DIALOG oDlg6 CENTERED

Return( NIL )

Static Function Grava()

aNotas := {}
_fSA2 := xFilial( "SA2" )
_cPri := DtoS( _dPri )
_cUlt := DtoS( _dUlt )

_sQry := "SELECT SD2010.D2_DOC AS NroDoc, SD2010.D2_SERIE AS Prefixo, SD2010.D2_EMISSAO AS Emissao, SD2010.D2_CLIENTE AS CliFor, SD2010.D2_TIPO AS Tipo, "
_sQry +=        "SD2010.D2_LOJA AS Loja, SD2010.D2_CF AS NatCfo, SD2010.D2_EST AS NotFed, SUM(SD2010.D2_TOTAL + SD2010.D2_ICMSRET) AS VlrTot, SUM(SD2010.D2_BASEICM) "
_sQry +=        "AS BseCalc, SD2010.D2_PICM AS aAliq, SUM(SD2010.D2_VALICM) AS VlrIcms, SUM(SD2010.D2_ICMSRET) AS ImpSbt, SUM(SD2010.D2_BASEIPI) "
_sQry +=        "AS BseIpi, SUM(SD2010.D2_VALIPI) AS VlrIpi, SE4010.E4_COND AS Pagto, SD2010.D2_TES TES, SF2010.F2_EST EST "
_sQry += " FROM  SD2010 INNER JOIN "
_sQry +=        "SF2010 ON SD2010.D2_DOC = SF2010.F2_DOC AND SF2010.F2_SERIE = SD2010.D2_SERIE INNER JOIN "
_sQry +=        "SE4010 ON SF2010.F2_COND = SE4010.E4_CODIGO "
_sQry += " WHERE (SD2010.D2_EMISSAO BETWEEN '" + _cPri + "' AND '" + _cUlt + "') AND (SD2010.D_E_L_E_T_ <> '*') AND (SF2010.D_E_L_E_T_ <> '*') AND (SE4010.D_E_L_E_T_ <> '*') " 

	
_sQry += " AND SD2010.D2_SERIE = '" + cSer  + "' "


_sQry += " AND F2_FILIAL = '" + xFilial("SF2") + "'  AND D2_FILIAL = '" + xFilial("SD2") + "' "  
_sQry += " AND E4_FILIAL = '" + xFilial("SE4") + "' "  

/*--- CURITIBA ---*/

_sQry += " GROUP BY SD2010.D2_DOC, SD2010.D2_SERIE, SD2010.D2_EMISSAO, SD2010.D2_CLIENTE, SD2010.D2_LOJA, SD2010.D2_CF, SD2010.D2_PICM, "
_sQry += "      SD2010.D2_EST, SD2010.D2_TIPO, SE4010.E4_COND, SD2010.D2_TES, SF2010.F2_EST"
_sQry += " ORDER BY SD2010.D2_DOC, SD2010.D2_CF, SD2010.D2_PICM "

dbUseArea( .T., "TOPCONN", TCGENQRY(,,_sQry), 'SZS' )

_eQry := "SELECT SD1010.D1_DOC AS NroDoc, SD1010.D1_SERIE AS Prefixo, SD1010.D1_EMISSAO AS Emissao, SD1010.D1_DTDIGIT AS DtEntr, SD1010.D1_FORNECE AS CliFor, "
_eQry +=        "SD1010.D1_LOJA AS Loja, SD1010.D1_CF AS NatCfo, SF1010.F1_EST AS notfed, SUM(SD1010.D1_TOTAL) AS VlrTot, SUM(SD1010.D1_BASEICM) "
_eQry +=        "AS BseCalc, SD1010.D1_PICM AS aAliq, SUM(SD1010.D1_VALICM) AS VlrIcms, SUM(SD1010.D1_ICMSRET) AS ImpSbt, SUM(SD1010.D1_BASEIPI) "
_eQry +=        "AS BseIpi, SUM(SD1010.D1_VALIPI) AS VlrIpi, SE4010.E4_COND AS Pagto, SF1010.F1_FORMUL As NfEnt, SD1010.D1_TES As TES, SF1010.F1_EST EST "
_eQry += " FROM  SD1010 INNER JOIN "
_eQry +=       "SF1010 ON SD1010.D1_DOC = SF1010.F1_DOC AND SD1010.D1_FORNECE = SF1010.F1_FORNECE LEFT OUTER JOIN "
_eQry +=       "SE4010 ON SF1010.F1_COND = SE4010.E4_CODIGO "
_eQry += " WHERE     (SD1010.D1_DTDIGIT BETWEEN '" + _cPri + "' AND '" + _cUlt + "') AND (SD1010.D_E_L_E_T_ <> '*') AND (SF1010.D_E_L_E_T_ <> '*') AND (SE4010.D_E_L_E_T_ <> '*') AND "
_eQry += " (SD1010.D1_SERIE NOT IN ('OS ', 'TS ', 'TRC', 'ORC', 'ONF', 'EPP')) AND (SD1010.D1_TES <> '156') "

/*--- CURITIBA ---*/

_eQry += " AND F1_FILIAL = '" + xFilial("SF1") + "'  AND D1_FILIAL = '" + xFilial("SD1") + "' "  
_eQry += " AND E4_FILIAL = '" + xFilial("SE4") + "' "


/*--- CURITIBA ---*/

_eQry += " GROUP BY SD1010.D1_DOC, SD1010.D1_SERIE, SD1010.D1_EMISSAO, SD1010.D1_DTDIGIT, SD1010.D1_FORNECE, SD1010.D1_LOJA, SD1010.D1_CF, SD1010.D1_PICM, "
_eQry +=          "SF1010.F1_EST, SE4010.E4_COND, SF1010.F1_FORMUL, SD1010.D1_TES, SF1010.F1_EST "
_eQry += " ORDER BY SD1010.D1_DOC, SD1010.D1_PICM "

dbUseArea( .T., "TOPCONN", TCGENQRY(,,_eQry), 'SZE' )

*[]--------------------------------------------------------------------------[]
*                      Registro Tipo 1 ContMatic Entrada
*[]--------------------------------------------------------------------------[]
vNom  := Space( 04 )
vEmi  := Space( 04 )
vSre  := Space( 03 ) 
vSer  := Space( 03 )
vNro  := 0
fNro  := 0
vCdF  := 0
vTes  := 0
vVlr  := 0
bIcm  := 0
aIcm  := 0
iIcm  := 0
oIcm  := 0
bIcm2 := 0
aIcm2 := 0
vIcm2 := 0
iIcm2 := 0
oIcm2 := 0
bIcm3 := 0
aIcm3 := 0
vIcm3 := 0
iIcm3 := 0
oIcm3 := 0
bIcm4 := 0
aIcm4 := 0
vIcm4 := 0
iIcm4 := 0
oIcm4 := 0
bIcm5 := 0
aIcm5 := 0
vIcm5 := 0
iIcm5 := 0
oIcm5 := 0

dEnt := Space( 04 )
vFil := Space( 04 )

*[]--------------------------------------------------------------------------[]
*                      Registro Tipo 2 ContMatic Entrada
*[]--------------------------------------------------------------------------[]


bIpi := 0
vIpi := 0
iIpi := 0
oIpi := 0
tNot := 0
cCtb := 0
vObs := Space( 14 )
vUf  := Space( 02 )

*[]--------------------------------------------------------------------------[]
*                      Registro Tipo 3 ContMatic Entrada
*[]--------------------------------------------------------------------------[]

vCgc := Space( 14 )
vIns := Space( 16 )
vRaz := Space( 35 )
vBco := Space( 15 )

*[]--------------------------------------------------------------------------[]
*                        Registro Tipo 1 ContMatic Saida
*[]--------------------------------------------------------------------------[]

sEnt := Space( 04 )
sSre := Space( 03 )
sNrI := Space( 06 )
sNrF := Space( 06 )                                               
sCdF := Space( 03 )
sVlC := 0
sIcB := 0
sAli := Space( 02 )
sIcm := 0
sIcI := 0
sFil := Space( 04 )

*[]--------------------------------------------------------------------------[]
*                       Registro Tipo 2 ContMatic Saida
*[]--------------------------------------------------------------------------[]

sIcO := 0
sIpB := 0
sIpI := 0
sIpO := 0
sTpN := "00"
sCdC := "  "
sObs := Space( 14 )
sUf  := Space( 02 )

vMes := StrZero( Month( _dPri ), 2 )

hSda := fCreate( "L:\ContFat\Mega" + AllTrim(cFilAnt)+ ".S" + vMes, 0 )
hEnt := fCreate( "L:\ContFat\Mega" + AllTrim(cFilAnt)+ ".E" + vMes, 0 )
hDBS := fCreate( "L:\ContFat\Dev"  + AllTrim(cFilAnt)+ vMes + ".Csv", 0 )

_cDBS := 'Nota'
_cDBS += ';'
_cDBS += 'Serie'
_cDBS += ';'
_cDBS += 'Emissใo'
_cDBS += ';'
_cDBS += 'Cfop'
_cDBS += ';'
_cDBS += 'Descri็ใo'
_cDBS += ';'
_cDBS += Chr( 13 )
_cDBS += Chr( 10 )

fWrite( hDBS, _cDBS )

_fSF1 := xFilial( 'SF1' )

ProcRegua( 2 )

dbSelectArea( 'SZS' )

If ( SF2->( dbSeek( xFilial( 'SF2' ) + SZS->NroDoc + SZS->Prefixo + SZS->CliFor + SZS->Loja , .F. ) ) )

   SF2->( dbSkip( -1 ) )
   _nNota := Val( NroDoc )
   _nNota -= Val( SF2->F2_DOC )
   vNro   := SF2->F2_DOC
   cSer   := SF2->F2_SERIE

   If _nNota > 1 .And. SF2->F2_SERIE == SZS->Prefixo
      Canceladas()
   End

End

While ! SZS->( Eof() )
   _cCliFor := SZS->CliFor // wadih 19-05-05
   _cLoja   := SZS->Loja  // wadih 19-05-05
   _cTipo   := SZS->TIPO // wadih 19-05-05
   GravaArqTxt(.T.)
End

// new
DbGoTop()

If ! Empty (aNotas)
	
	_cDBS += "Notas com valor parcial sob Subtitui็ao Tributaria:"
	_cDBS += Chr( 13 )
	_cDBS += Chr( 10 )

	fWrite( hDBS, _cDBS )
	
	While ! SZS->( Eof() )
	
		For i := 1 to len (aNotas) 
	
			If aNotas[i][1] == NroDoc  .And. ;  
			   aNotas[i][2] == Prefixo .And. ;
			   aNotas[i][3] == NatCfo
			
					_cCliFor := SZS->CliFor 
					_cLoja   := SZS->Loja  
					_cTipo   := SZS->TIPO 
				   
					GravaArqTxt(.F.)
				 
				Exit
			
			EndIf		/*  */ 		
		
		NEXT 		/* For Loop */
		
	    DbSkip()
	    
	End				/* While Loop */

EndIf

// new

IncProc()
SZS->( dbCloseArea() )
fClose( hSda )

dbSelectArea( 'SZE' )

While ! SZE->( Eof() )
   
   _cCliFor := SZE->CliFor
   _cLoja   := SZE->Loja
   
   GravaArqTxt(.T.)
End

IncProc()
fClose( hEnt )
fClose( hDBS )
SZE->( dbCloseArea() )

MsgInfo("Exporta็ใo realizada com sucesso")

//_cRun := 'C:\Arquivos de Programas\Microsoft Office\Office11\Excel.Exe "L:\ContFat\DevBonST.Csv"'
//WinExec( _cRun )

Return( NIL )

/*

                                              Gera registro texto

*/

Static Function GravaArqTxt(lCancel)

vEmi  := Substr( Emissao, 7, 2 ) + Substr( Emissao, 5, 2 )

If Substr( NatCfo, 1, 1 ) < '5'

   vDtE := Substr( DtEntr, 7, 2 )
   vDtE += Substr( DtEntr, 5, 2 )

Else

  vDtE := vEmi

End

vSre  := Prefixo
vNro  := NroDoc
fNro  := NroDoc 

vCdF := NatCfo   /* 29-03-2007 */  
vTes := TES

vVlr  := 0
dEnt  := vEmi
vFil  := Space( 04 )
bIpi  := 0
vIpi  := 0
vObs  := Space( 14 )
vUf   := NotFed
iSbt  := 0
iIpi  := 0
oIpi  := 0
vIcm  := 0
bIcm  := 0 
aIcm  := 0
vIcm  := 0
oIcm  := 0
iIcm  := 0
vAvs  := 0
vPrz  := 0

CalcVlrIst( @bIcm, @aIcm, @vIcm, @oIcm, @iIcm )

bIcm2 := 0
aIcm2 := 0
vIcm2 := 0
iIcm2 := 0
oIcm2 := 0
bIcm3 := 0
aIcm3 := 0
vIcm3 := 0
iIcm3 := 0
oIcm3 := 0
bIcm4 := 0
aIcm4 := 0
vIcm4 := 0
iIcm4 := 0
oIcm4 := 0
bIcm5 := 0
aIcm5 := 0
vIcm5 := 0
iIcm5 := 0
oIcm5 := 0

Aliquotas()

ConvNro( @vVlr )
ConvNro( @bIcm )
ConvAliq( @aIcm )
ConvNro( @vIcm )
ConvNro( @bIpi )
ConvNro( @vIpi )
ConvNro( @iIcm )
ConvNro( @iIpi )
ConvNro( @oIcm )
ConvNro( @oIpi )

ConvNro( @bIcm2 )
ConvAliq( @aIcm2 )
ConvNro( @vIcm2 )
ConvNro( @iIcm2 )
ConvNro( @oIcm2 )

ConvNro( @bIcm3 )
ConvAliq( @aIcm3 )
ConvNro( @vIcm3 )
ConvNro( @iIcm3 )
ConvNro( @oIcm3 )

ConvNro( @bIcm4 )
ConvAliq( @aIcm4 )
ConvNro( @vIcm4 )
ConvNro( @iIcm4 )
ConvNro( @oIcm4 )

ConvNro( @bIcm5 )
ConvAliq( @aIcm5 )
ConvNro( @vIcm5 )
ConvNro( @iIcm5 )
ConvNro( @oIcm5 )

ConvNro( @iSbt )
ConvNro( @vAvs )
ConvNro( @vPrz )

vTxt := "R1"
vTxt += vEmi
vTxt += vDtE
vTxt += Substr( vDtE, 1, 2 )
vTxt += "NFE"
vTxt += vSre
vTxt += RIGHT(ALLTRIM(vNro),6) //vNro - NFE
vTxt += '000000'
vTxt += vCdF   // Codigo Fiscal
vTxt += vVlr   // Valor Contabil
vTxt += bIcm   // Base1 ICMS
vTxt += aIcm   // Aliq1 ICMS
vTxt += vIcm   // Imposto1 ICMS (Valor)
vTxt += iIcm   // Isento1 ICMS
vTxt += oIcm   // Outras1 ICMS

vTxt += bIcm2
vTxt += aIcm2
vTxt += vIcm2
vTxt += iIcm2
vTxt += oIcm2

vTxt += bIcm3
vTxt += aIcm3
vTxt += vIcm3
vTxt += iIcm3
vTxt += oIcm3

vTxt += bIcm4
vTxt += aIcm4
vTxt += vIcm4
vTxt += iIcm4
vTxt += oIcm4

vTxt += bIcm5
vTxt += aIcm5
vTxt += vIcm5
vTxt += iIcm5
vTxt += oIcm5

vTxt += bIpi   //BASE IPI -- VALOR DA MERCADORIA
vTxt += vIpi   //VALOR DO IPI 
vTxt += iIpi   // MERCADORIA ISENTA DE IPI
vTxt += oIpi   // MERCAD. NAO TRIBUTADA NEM ISENTA DE IPI
vTxt += "000000000000"
vTxt += iSbt   // ICMS ST
vTxt += "000000000000"
vTxt += vAvs
vTxt += vPrz
vTxt += "000000000000"
vTxt += "0"
vTxt += IIf (AllTrim(vCdF) $ '5403',"22","01")   // Tipo da nota: Posicao 439  vTxt += "01"
vTxt += "00"
vTxt += vObs

If vCdF > "5    "   // NF SAIDA

	IF _cTipo == 'N'
   		IF	( SA1->( dbSeek( _fSA2 + _cCliFor + _cLoja, .F. ) )) 
    		vCgc := SA1->A1_CGC
    		vNom := Substr( SA1->A1_NOME, 1, 35 )
        	vIns := SA1->A1_INSCR  
        	
		END
    ELSE
    	IF  ( SA2->( dbSeek( _fSA2 + _cCliFor + _cLoja, .F. ) ) )
	    	vCgc := SA2->A2_CGC
      		vNom := Substr( SA2->A2_NOME, 1, 35 )   
      		vIns := SA2->A2_INSCR  
		END
	END			

Else // NF ENTRADA

   If ( SA2->( dbSeek( _fSA2 + _cCliFor + _cLoja, .F. ) ) )

      vCgc := SA2->A2_CGC
      vNom := Substr( SA2->A2_NOME, 1, 35 )
      vIns := SA2->A2_INSCR  

   Else

      SA1->( dbSeek( _fSA2 + _cCliFor + _cLoja, .F. ) ) 
      vCgc := SA1->A1_CGC
      vNom := Substr( SA1->A1_NOME, 1, 35 )
      vIns := SA1->A1_INSCR  

   End

   
   
End

vTxt += ToDigits(@vCgc, 14)  // CGC
vTxt += ToDigits(@vIns, 16)  // Inscr. Estadual
vTxt += vNom
vTxt += Space(18)
vTxt += vUf
vTxt += "0000"
vTxt += Space( 50 )
vTxt += Chr( 13 )
vTxt += Chr( 10 )

If vCdF > "5    " 
	
	GeraDBS( vNro, vSre, vEmi, vCdf, vTes, _cTipo)
	
	_nNota := Val( NroDoc )
    _nNota -= Val( vNro )
    cSer   := vSre

   If _nNota > 1 //.And.;
     // _nNota < 20

      If (lCancel)
      	Canceladas()
      EndIf
   End
   
   fWrite( hSda, vTxt )

Else

   If SZE->NFEnt <> ' '

      GeraDBS( vNro, vSre, vEmi, vCdf, vTes, ' ')
      
   End

   fWrite( hEnt, vTxt )

End

Return( NIL )

/*
                              Conversao de numerico para caracter
*/

Static Function ConvNro( vParm )

vParm := StrZero( vParm, 13, 2 )
vParm := Substr( vParm, 1, 10 ) +;
         Substr( vParm, 12, 2 )

Return( vParm )

Static Function ConvAliq( vParm )

vParm := StrZero( vParm, 7, 4 )
vParm := Substr( vParm, 1, 2 ) +;
         Substr( vParm, 4, 4 )

Return( vParm )


Static Function Aliquotas()

Local cCFOPAnt	:= NatCfo
Local cSerieAnt := Prefixo

dbSkip()

If (NroDoc = vNro) .And. (cSerieAnt == Prefixo)  

	If (cCFOPAnt == NatCfo)  // Mesmo CFOP mas % ICMS diferente
   		
   		CalcVlrIst( @bIcm2, @aIcm2, @vIcm2, @oIcm2, @iIcm2 )
	
	Else                     // CFOP diferente - incluir no array aNotas
	
		AADD (aNotas,{NroDoc,Prefixo,NatCfo})

	EndIf

Else

  Return( NIL )

End   


cCFOPAnt	:= NatCfo
cSerieAnt := Prefixo

dbSkip()

If (NroDoc = vNro) .And. (cSerieAnt == Prefixo)

	If (cCFOPAnt == NatCfo)  // Mesmo CFOP mas % ICMS diferente
   		
   		CalcVlrIst( @bIcm3, @aIcm3, @vIcm3, @oIcm3, @iIcm3 )
	
	Else                     // CFOP diferente - incluir un novo registro
	
		AADD (aNotas,{NroDoc,Prefixo,NatCfo})

	EndIf

Else

   Return( NIL )

End   

cCFOPAnt	:= NatCfo
cSerieAnt := Prefixo

dbSkip()

If (NroDoc = vNro) .And. (cSerieAnt == Prefixo)
	
	If (cCFOPAnt == NatCfo)  // Mesmo CFOP mas % ICMS diferente
   		
   		CalcVlrIst( @bIcm4, @aIcm4, @vIcm4, @oIcm4, @iIcm4 )
	
	Else                     // CFOP diferente - incluir un novo registro
	
		AADD (aNotas,{NroDoc,Prefixo,NatCfo})

	EndIf
	
Else   

   Return( NIL )

End   

cCFOPAnt	:= NatCfo
cSerieAnt := Prefixo

dbSkip()

If (NroDoc = vNro) .And. (cSerieAnt == Prefixo)
	
	If (cCFOPAnt == NatCfo)  // Mesmo CFOP mas % ICMS diferente
   		
   		CalcVlrIst( @bIcm5, @aIcm5, @vIcm5, @oIcm5, @iIcm5 )
	
	Else                     // CFOP diferente - incluir un novo registro
	
		AADD (aNotas,{NroDoc,Prefixo,NatCfo})

	EndIf

Else   

   Return( NIL )

End   

Return( NIL )

// 				CalcVlrIst( @bIcm, @aIcm, @vIcm2, @oIcm, @iIcm) 
Static Function CalcVlrIst( vParm1, vParm2, vParm3, vParm4, vParm5 )

vVlr   += VlrTot
vVlr   += VlrIpi

vParm1 := BseCalc
vParm2 := aAliq
vParm3 := VlrIcms

If Substr( Pagto, 1, 2 ) = "00"

   vAvs := vVlr

Else

   vPrz := vVlr

End   

If VlrIpi <> 0

	bIpi   += BseIpi
    vIpi   += VlrIpi
  //  vParm4 += VlrIpi

Else 
	
	iIpi += VlrTot

EndIf

If Substr( NatCfo, 2, 1 ) = "9"

   If VlrIcms <> 0 //.Or. NatCfo $ '5405 '  // 5404 gera ICMS no campo Outros

      vParm4 := 0

   Else

      vParm4 := VlrTot

   End

   vParm5 := 0

   If VlrIpi = 0

      oIpi  += BseIpi

   End

Else

   If VlrIcms <> 0 //Tem ICMS --> nao e isento
      
      	vParm5 := 0
      	vParm4 := 0
   
   Else
   
   		vParm5 := IIf (NatCfo $ '5405 ',0,VlrTot) 
   		vParm4 := IIf (NatCfo $ '5405 ',VlrTot,0)
   		
      
   End

   

   If VlrIpi = 0

      iIpi  += BseIpi

   End

End

If ImpSbt <> 0 .And. EST <> 'SP' .And. cFilAnt == '01'

   vParm1 := 0
   vParm2 := 0
   vParm3 := 0
   vParm5 := 0
   vParm4 := BseCalc

End   

iSbt   += ImpSbt

Return( vParm1, vParm2, vParm3, vParm4, vParm5 )

Static Function Canceladas()

_nNota --
_oNota := Val( vNro )

For i := 1 To _nNota

    _oNota ++
    _cNot := StrZero( _oNota, 6 )
    _lDev := .T.

    SF1->( dbSeek( _fSF1 + _cNot + '00000000', .T. ) )

    While SF1->F1_DOC == _cNot  .And. SF1->F1_FILIAL == xFilial("SF1")

       If SF1->F1_TIPO  <> 'D'

          SF1->( dbSkip() )

       Else

          If SF1->F1_SERIE == cSer  .And. cFilAnt == '01' 
          
             _lDev := .F.
             Exit

          ElseIf SF1->F1_SERIE == cSer  .And. cFilAnt == '02' 
          
          	_lDev := .F.
             Exit

          Else

             SF1->( dbSkip() )

          End

       End

    End

    If _lDev

       vCan := 'R1'

       If vEmi <> '    '

          vCan += vEmi
          vCan += vEmi
          vCan += Substr( vEmi, 1, 2 )

       Else

          vCan += '0101'
          vCan += '0101'
          vCan += '01'

       End
       
       vCan += 'NFE'
       vCan +=  cSer// Serie
       vCan += RIGHT(ALLTRIM(_cNot),6) //_cNot - NFE 
       vCan += '0000005102 '
       vCan += Replicate( '0', 403 )
       vCan += '9900              00000000000000C A N C E L A D A                                  '
       vCan += '000000000000000000SP0000                                                  '
       vCan += Chr( 13 )
       vCan += Chr( 10 )

       fWrite( hSda, vCan )
       GeraDBS( _cNot,cSer,vEmi,'    ','   ',' ' )
       
    End

Next

Return()


Static Function GeraDBS( cNota, cSerie, cEmissao, cCfop, cTes, cTpNota )

Local cText := GetAdvFVal("SF4","F4_TEXTO",xFilial("SF4")+cTES,1,"")

_cDBS := RIGHT(ALLTRIM(cNota),6) // cNota - NFE
_cDBS += ';'
_cDBS += cSerie
_cDBS += ';'
_cDBS += Substr( cEmissao, 1, 2 )
_cDBS += '/'
_cDBS += Substr( cEmissao, 3, 2 )
_cDBS += '/'
_cDBS += Substr( DtoS( _dUlt ), 1, 4 )
_cDBS += ';'
_cDBS += cCfop
_cDBS += ';'


If Empty (cTes)

	_cDBS += 'CANCELADA' 

ElseIf cTes >= '501'  // Saida

	If cTpNota == 'N'
		
		_cDBS += Rtrim (cText) 	
				
	ElseIf cTpNota == 'D'
		
		_cDBS += 'DEVOLUวAO P/ FORNECEDOR' 
	
	ElseIf cTpNota == 'C'
		
		_cDBS += 'COMPLEMETO DE PREวO' 
	
	ElseIf cTpNota == 'I'
	
		_cDBS += 'COMPLEMETO DE ICMS'
	
	ElseIf cTpNota == 'P' 
	
		_cDBS += 'COMPLEMETO IPI'
	
	EndIf 

//ElseIf cTes <= '500'            // Entrada

EndIf

_cDBS += Chr( 13 )
_cDBS += Chr( 10 )

If cCfop > "5    "  .AND. !(cCfop $ "5102 #6102 ") .OR. ;// Do not include CFOP 5102/6102 e entradas
	Empty (cTes)   
	
	fWrite( hDBS, _cDBS )
	
EndIf

Return( NIL )

/* ToDigits
Strip everything rom string except digits and make it equal to 
specified length stuffing spaces if needed
*/
Static Function ToDigits(c_Str, n_Dig)
Local i 

c_Tmp := space(0)

n_Len = len (c_Str)

For i:= 1 to n_Len
	If  ! (substr(c_Str,i,1) $ '.-/\')
	//ISDIGIT(substr(c_Str,i,1))
		c_Tmp += substr(c_Str,i,1)
	End 
NEXT

c_Tmp := ALLTRIM( c_Tmp )	
n_Len = len (c_Tmp)

If n_Len > n_Dig  
	c_Tmp = substr(c_Tmp,1,n_Dig)
ElseIf n_Len < n_Dig
	c_Tmp += SPACE(n_Dig - n_Len)
End	

c_Str = c_Tmp	

Return( c_Tmp )
