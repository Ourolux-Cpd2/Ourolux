/*

     Grava arquivo de Romaneios

*/

User Function SD1140I()

If cSerie = 'TRC'

   ConfirmSX8()

ElseIf cEspecie = 'NFST'

   _fSC5    := xFilial( 'SC5' )
   _fSF1    := xFilial( 'SF1' )
   _fSF2    := xFilial( 'SF2' )
   _fSA1    := xFilial( 'SA1' )
   _fSZA    := xFilial( 'SZA' )
   _nOrd    := SC5->( IndexOrd() )

   SC5->( dbSetOrder( 5 ) )
   SZA->( dbSetOrder( 1 ) )
   SF2->( dbSetOrder( 1 ) )
   SF1->( dbSetOrder( 1 ) )

   GrvRomaneio()

End

Return( NIL )


Static Function GrvRomaneio()

If ( SC5->( dbSeek( _fSC5           +;
                    SD1->D1_NFORI   +;
                    SD1->D1_SERIORI ,;
                    .F.              ;
   )      )      )

   SC5->( rLock() )
   SC5->C5_DESPACH := dDemissao
   SC5->( MSUnLock() )

Else

   SC6->( dbSetOrder( 4 ) )

   If ( SC6->( dbSeek( _fSC5            +;
                        SD1->D1_NFORI   +;
                        SD1->D1_SERIORI ,;
                        .F.              ;
       )      )      )   

      SC5->( dbSetOrder( 1 ) )
      SC5->( dbSeek( _fSC5       +;
                     SC6->C6_NUM ,;
                     .F.          ;
           )      )
    
      SC5->( rLock() )
      SC5->C5_DESPACH := dDemissao
      SC5->( MSUnLock() )   
      SC5->( dbSetOrder( 5 ) )   

   End

   SC6->( dbSetOrder( 1 ) )

End

SF2->( dbSeek( _fSF2           +;
               SD1->D1_NFORI   +;
               SD1->D1_SERIORI +;
               SC5->C5_CLIENTE +;
               SC5->C5_LOJACLI ,;
               .F.              ;
             )                  ;
     )

If SF2->F2_DOC <> SD1->D1_NFORI

   SF1->( dbSeek( _fSF1           +;
                  SD1->D1_NFORI   +;
                  SD1->D1_SERIORI +;
                  SC5->C5_CLIENTE +;
                  SC5->C5_LOJACLI +;
                  'N'             ,;
                  .F.              ;
                );
        )

   SF1->(  RecLock( 'SF1', .F. ) )
   SF1->F1_HAWB   := cNFiscal
   SF1->( MSUnLock() )
          
Else

   SF2->(  RecLock( 'SF2', .F. ) )
   SF2->F2_CONHECI := Val( cNFiscal )

   If SD1->D1_COD <> 'FRETE          '

      SF2->F2_REDESP  := CA100FOR

   Else

      SF2->F2_TRANSP  := CA100FOR
 
   End

   SF2->( MSUnLock() )
       
End

If ( SZA->( dbSeek( _fSZA + SC5->C5_NUM, .F. ) ) )

   RecLock( 'SZA', .F. )

   If SD1->D1_COD <> 'FRETE          '

      SZA->ZA_REDESPA := dDemissao
      SZA->( MSUnLock() )
      SZA->( RecLock('SZA', .T. ) )

   Else

       SZA->ZA_DATA := dDemissao
       SZA->( MSUnLock() )

   End

Else

   If !(SZA->( RecLock('SZA', .T. ) ))
   	ApMsgInfo("Error ")
   EndIf

End

SZA->ZA_FILIAL  := _fSZA
SZA->ZA_SERIE   := SD1->D1_SERIORI
SZA->ZA_NOTA    := SD1->D1_NFORI

If SD1->D1_COD <> 'FRETE          '

   SZA->ZA_REDESPA := dDemissao

Else

   SZA->ZA_DATA := dDemissao

End

SZA->ZA_CLIENTE := SF2->F2_CLIENTE

If SC5->C5_TIPO == 'N'     // war 08-05-2013 
	
	IF ( SA1->( dbSeek( _FSA1 + SF2->F2_CLIENTE + SF2->F2_LOJA, .F. ) ) )
	
		SZA->ZA_NOMCLI  := SA1->A1_NREDUZ
		SZA->ZA_TRANSP  := CA100FOR
		SZA->ZA_NOMETRA := Substr( SA2->A2_NOME, 1, 20 )
		SZA->ZA_EMISNF  := SF2->F2_EMISSAO
		SZA->ZA_PEDIDO  := SC5->C5_NUM
		SZA->ZA_MOTORIS := SA2->A2_NREDUZ
		SZA->ZA_NUMBCO  := SC5->C5_CDPG
		SZA->ZA_NUMERO  := cNFiscal
		SZA->( MSUnLock() )
	
	EndIf
	
EndIf

Return( NIL )