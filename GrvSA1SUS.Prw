User Function GrvSA1SUS() 

// war 30-05-05 Limit prospect P/ usr Cobranca
cCodUsr = RetCodUsr()   

If (( cCodUsr == '000066') .AND. (M->US_VLRCMP > 2000))
    M->US_STATUS := '4'
    MsgInfo( ' Usuario sem permissao!' )
    Return( M->US_STATUS )
End 
// war 30-05-05 Limit prospect P/ usr Cobranca

   M->US_DTAFIM  := dDataBase
   M->US_HORAFIM := Substr( Time(), 1, 5 )

   _iTime := Substr( M->US_HORAINI, 1, 2 )
   _iTime := Val( _iTime )
   _iTime *= 60
   _iTime += Val( Substr( M->US_HORAINI, 4, 2 ) )

   _fTime := Substr( M->US_HORAFIM, 1, 2 )
   _fTime := Val( _fTime )
   _fTime *= 60
   _fTime += Val( Substr( M->US_HORAFIM, 4, 2 ) )
   _fTime += 1
   _fTime -= _iTime
   _nDias := dDataBase - M->US_DTAINI
 
   If _nDias <> 0

      _nIni  := M->US_DTAINI

      For n := 1 To _nDias
       
          _nDow := Dow( _nIni )

          If _nDow = 7 .Or.;
             _nDow = 1

             _nDias -= 1

          End

          _nIni += 1

      Next

   End   

   _nHrUteis := 12
   _nHrUteis *= _nDias
   _nDias    *= 24
   _nDias    -= _nHrUteis
   _nDias    *= 60
   _nDias    += _fTime
   _nHoras   := _nDias
   _nHoras   /= 60
   _nHoras   := Int( _nHoras )
   _nDias    -= ( _nHoras * 60 )
   _nDias    /= 100
   _nHoras   += _nDias

   _nDias := StrZero( _nHoras, 3, 0 )
   _nDias += ':'
   _nDias += Substr( Str( _nHoras, 6, 2 ), 5, 6 )
 
   SA1->( RecLock( 'SA1', .T. ) )

   SA1->A1_FILIAL  := M->US_FILIAL
   SA1->A1_COD     := GETSXENUM("SA1","A1_COD") //M->US_COD
   SA1->A1_LOJA    := '01' //M->US_LOJA
   SA1->A1_CODHIST := M->US_CODHIST
   SA1->A1_END     := M->US_END
   SA1->A1_EST     := M->US_EST
   SA1->A1_CEP     := M->US_CEP
   SA1->A1_MUN     := M->US_MUN
   SA1->A1_NOME    := M->US_NOME
   SA1->A1_NREDUZ  := M->US_NREDUZ
   SA1->A1_TEL     := M->US_TEL
   SA1->A1_TIPO    := M->US_TIPO
   SA1->A1_CGC     := M->US_CGC
   SA1->A1_EMAIL   := M->US_EMAIL
   SA1->A1_FAX     := M->US_FAX 
   SA1->A1_NATUREZ := '110'
   SA1->A1_SATIV1  := M->US_SATIV
   SA1->A1_SATIV2  := M->US_SATIV2
   SA1->A1_SATIV3  := M->US_SATIV3
   SA1->A1_SATIV4  := M->US_SATIV4
   SA1->A1_SATIV5  := M->US_SATIV5
   SA1->A1_SATIV6  := M->US_SATIV6
   SA1->A1_SATIV7  := M->US_SATIV7
   SA1->A1_SATIV8  := M->US_SATIV8
   SA1->A1_ULTVIS  := M->US_ULTVIS
   SA1->A1_HPAGE   := M->US_URL
   SA1->A1_VEND    := M->US_VEND
   SA1->A1_BAIRRO  := M->US_BAIRRO
   SA1->A1_DDD     := M->US_DDD
   SA1->A1_BCO1    := '237'
   SA1->A1_CONTATO := M->US_CONTATO
   SA1->A1_INSCR   := M->US_INSCEST
   SA1->A1_ENDCOB  := M->US_ENDCOB
   SA1->A1_BAIRROC := M->US_BROCOB
   SA1->A1_MUNC    := M->US_MUNCOB
   SA1->A1_CEPC    := M->US_CEPCOB
   SA1->A1_ESTC    := M->US_ESTCOB
   SA1->A1_ENDENT  := M->US_ENDENT
   SA1->A1_MUNE    := M->US_MUNE
   SA1->A1_CEPE    := M->US_REGIAO
   SA1->A1_ESTE    := M->US_ESTE
   SA1->A1_BAIRROE := M->US_BAIRROE
   
   SA1->A1_TRANSP  := M->US_TRANSP
   SA1->A1_TPFRET  := 'F'
   SA1->A1_RISCO   := If( M->US_STATUS <> '1', 'E', 'B' )
   //SA1->A1_ATIVIDA := If( SA1->A1_TIPO <> 'F','REVEN','FINAL')
   SA1->A1_OBSFIN  := Substr( M->US_OBS, 1, 80 )
   SA1->A1_LC      := M->US_LIMITCR
   SA1->A1_TABELA  := '100'
   //SA1->A1_CMPPROS := M->US_VLRCMP 

   SA3->( dbSeek( xFilial( 'SA3' ) + SUS->US_VEND, .F. ) )
   SA1->A1_SUPER   := SA3->A3_SUPER

   SA1->A1_CADASTR := _nDias
   SA1->( MSUnLock() )
   Referencia()
   GrvContato()

Return()

/*

         Grava dados complementar no cadastro do cliente

*/
Static Function Referencia()

_aBco := { { US_BCO1, US_AGE1, US_CTA1, US_BCODTA1, US_FONBCO1, US_BCOOBS1 },;
           { US_BCO2, US_AGE2, US_CTA2, US_BCODTA2, US_FONBCO2, US_BCOOBS2 } ;
         }
_fSAO := xFilial( "SAO" )         

For i := 1 To 2

    If _aBco[ i ][ 1 ] <> '   '

       SAO->( RecLock( "SAO", .T. ) )
       SAO->AO_FILIAL  := xFilial( "SAO" )
       SAO->AO_CLIENTE := SUS->US_COD
       SAO->AO_LOJA    := SUS->US_LOJA
       SAO->AO_TIPO    := '3'
       SX5->( dbSeek( xFilial( 'SX5' ) + 'ZB' + _aBco[ i ][ 1 ] + '   ', .F. ) )
       SAO->AO_NOMINS  := Substr( SX5->X5_DESCRI, 1, 30 )
       SAO->AO_TELEFON := _aBco[ i ][ 5 ]
       SAO->AO_DESDE   := _aBco[ i ][ 4 ]
       SAO->AO_OUTOPE  := _aBco[ i ][ 1 ] + '/' + _aBco[ i ][ 2 ]
       SAO->AO_OBSERV  := _aBco[ i ][ 2 ]
       SAO->( MSUnLock() )

    End

Next
    
_aRef := { { US_REF1, US_FONREF1, US_CONTAT1, US_REFDTA1, US_MAIORC1, US_COMPDT1, US_ACULUM1, US_ULTCOM1, US_REFOBS1 },;
		   { US_REF2, US_FONREF2, US_CONTAT2, US_REFDTA2, US_MAIORC2, US_COMPDT2, US_ACULUM2, US_ULTCOM2, US_REFOBS2 },;
		   { US_REF3, US_FONREF3, US_CONTAT3, US_REFDTA3, US_MAIORC3, US_COMPDT3, US_ACULUM3, US_ULTCOM3, US_REFOBS3 } ;
         }

For i := 1 To 3

    If ! Empty( _aRef[ i ][ 1 ] )

       SAO->( RecLock( "SAO", .T. ) )
       SAO->AO_FILIAL  := _fSAO
       SAO->AO_CLIENTE := M->US_COD
       SAO->AO_LOJA    := M->US_LOJA
       SAO->AO_TIPO    := '2'
       SAO->AO_NOMINS  := Substr( _aRef[ i ][ 1 ], 1, 30 )
       SAO->AO_TELEFON := _aRef[ i ][ 2 ]
       SAO->AO_CONTATO := _aRef[ i ][ 3 ]
       SAO->AO_DESDE   := _aRef[ i ][ 4 ]
       SAO->AO_VLRMAI  := _aRef[ i ][ 5 ]
       SAO->AO_MAICOM  := _aRef[ i ][ 6 ]
       SAO->AO_LIMCRE  := _aRef[ i ][ 7 ]
       SAO->AO_ULTCOM  := _aRef[ i ][ 8 ]
       SAO->AO_OBSERV  := _aRef[ i ][ 9 ]
       SAO->( MSUnLock() )

    End

Next

Return( NIL )

//SA1->A1_ US_CODCLI  C         6
//SA1->A1_ US_LOJACLI C         2

Static Function GrvContato()

_fAC8 = xFilial("AC8") // WAR 30-05-05
SU5->( RecLock( 'SU5', .T. ) )

SU5->U5_CLIENTE := M->US_COD 
SU5->U5_CODCONT := M->US_COD 
SU5->U5_LOJA    := M->US_LOJA
SU5->U5_LOJAPRO := M->US_LOJA
SU5->U5_CONTAT  := M->US_CONTATO
SU5->U5_FONE    := M->US_TEL
SU5->U5_END     := M->US_END
SU5->U5_BAIRRO  := M->US_BAIRRO
SU5->U5_CEP     := M->US_CEP
SU5->U5_MUN     := M->US_MUN
SU5->U5_EST     := M->US_EST
SU5->U5_FCOM1   := M->US_TEL
SU5->U5_FCOM2   := M->US_FAX
SU5->U5_OPERADO := M->US_VEND
SU5->U5_EMAIL   := M->US_EMAIL
SU5->U5_URL     := M->US_URL
SU5->U5_DDD     := M->US_DDD
SU5->U5_STATUS  := '1'

SU5->( MSUnLock() )

If ! ( AC8->( dbSeek( xFilial("AC8")         +;
                      SA1->A1_COD   +;
                      'SA1'         +;
                      SA1->A1_FILIAL+;
                      SA1->A1_COD   +;
                      SA1->A1_LOJA   ;
                      , .F.;
      )     )       )
   
   AC8->( RecLock( 'AC8', .T. ) )

Else

   AC8->( RecLock( 'AC8', .F. ) )

End

AC8->AC8_FILIAL := _fAC8
AC8->AC8_FILENT := SA1->A1_FILIAL
AC8->AC8_ENTIDA := 'SA1'
AC8->AC8_CODENT := SA1->A1_COD + SA1->A1_LOJA
AC8->AC8_CODCON := SA1->A1_COD

AC8->( MSUnlock() )

Return( NIL )