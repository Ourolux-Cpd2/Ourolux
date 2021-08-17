/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ VldPrdVd ³ Autor ³Eletromega             ³ Data ³26/07/2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Atualizacao de campos Pedido de Venda                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function VldPrdVd()

If Type( '_nPosUni' ) = 'U'  // wadih

   U_M410Get()

End

If cNivel > 7   

   aCols[ n ][ _nPosCst ] := SB1->B1_CUSTD 

End

If M->C5_TIPO = 'T'  

   SD1->( dbSetOrder( 1 ) )
   SD1->( dbSeek( xFilial( 'SD1' )  +;
                  M->C5_NUM         +;
                  'TRC'             +;
                  M->C5_CLIENTE     +;
                  M->C5_LOJACLI     +;
                  aCols[ n ][ 2 ]   +;
                  '  '              ,;
                   .T.               ;
                );
        )

   If aCols[ n ][ 2 ] = SD1->D1_COD .And.;
      M->C5_NUM       = SD1->D1_DOC

      aCols[ n ][ _nPosPrc ] := SD1->D1_VUNIT
      aCols[ n ][ _nPosPrc ] -= ( SD1->D1_VALDESC / SD1->D1_QUANT )

   Else

      SD1->( dbSeek( xFilial( 'SD1' ) +;
                     M->C5_NUM        +;
                     'TRC'            +;
                     M->C5_CLIENTE    +;
                     M->C5_LOJACLI    +;
                     Space( 17 )      ,;
                     .T.               ;
                 );
           )


      DA1->( dbSetOrder( 1 ) )
      DA1->( dbSeek( xFilial( 'DA1' ) + M->C5_TABELA +  aCols[ n ][ 2 ]) )

	  aCols[ n ][ _nPosPrc ] := DA1->DA1_PRCVEND

   End
      
End

Return( aCols[ n ][ 2 ] )