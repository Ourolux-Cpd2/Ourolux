#Include "rwmake.ch"

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥Programa  ≥ MEGA55   ≥ Autor ≥Haroldo Guimaraes      ≥ Data ≥07/02/2002≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÖo ≥ Altera precos de vendas, pela Margem Estabelecida          ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Uso       ≥ Eletromega                                                 ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±≥Alteracoes efetuadas apos a implantacao                                ≥±±
±±≥Autor     ≥ Data     ≥ Descricao                                       ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±≥          ≥          ≥                                                 ≥±±
±±≥          ≥          ≥                                                 ≥±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/

User Function MEGA55

Private cPerg   := "MEGA55"
Private xCodIni := SPACE(15)
Private xCodFim := SPACE(15)
Private xMargemT:= 0
Private xMargemR:= 0
Private xMargem9:= 0
Private xMargemP:= 0
Private xMargemD:= 0
Private iMargem := 0

@ 050,1 To 400,500 Dialog oDlg Title "Altera Tabela de Precos Pela Margem"
@ 003,009 TO 200,300


@20,11 SAY "Produto de...: "
@30,11 SAY "Produto atÇ..: "
@40,11 SAY "Marg. Tabela.: "
@50,11 SAY "Marg.Revenda.: "
@60,11 SAY "Margem 900...: "
@70,11 SAY "Marg.Promocao: "
@80,11 SAY  "Marg.Diretos.: "
@100,11 SAY "% p/Margens..: "

Digmarg()    // DIGITA A MARGEM

@ 140,25 BMPBUTTON TYPE 01 ACTION Gravmarg()     //GRAVA A MARGEM
@ 140,65 BMPBUTTON TYPE 02 ACTION Cancela()
Activate Dialog oDlg Centered
RETURN

/*
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥Programa  ≥ DIGMARG  ≥ Autor ≥Haroldo Guimaraes      ≥ Data ≥07/02/2002≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÖo ≥ Digitacao das margens                                      ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Uso       ≥ Eletromega                                                 ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±≥Alteracoes efetuadas apos a implantacao                                ≥±±
±±≥Autor     ≥ Data     ≥ Descricao                                       ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±≥          ≥          ≥                                                 ≥±±
±±≥          ≥          ≥                                                 ≥±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/

Static Function Digmarg

@20,55 GET xCodIni Picture "@!" Valid .T. F3 "SB1"     
@30,55 GET xCodFim Picture "@!" Valid .T. F3 "SB1"            
@40,55 GET xMargemT Picture "@E 99.99"
@50,55 GET xMargemR Picture "@E 99.99"
@60,55 GET xMargem9 Picture "@E 99.99"
@70,55 GET xMargemP Picture "@E 99.99"
@80,55 GET xMargemD Picture "@E 99.99"
@100,55 GET iMargem  Picture "@E 99.99"
Return

/*
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥Programa  ≥ GRAVMARG ≥ Autor ≥Haroldo Guimaraes      ≥ Data ≥07/02/2002≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÖo ≥ Gravacao das margens  e dos precos                         ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Uso       ≥ Eletromega                                                 ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±≥Alteracoes efetuadas apos a implantacao                                ≥±±
±±≥Autor     ≥ Data     ≥ Descricao                                       ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±≥          ≥          ≥                                                 ≥±±
±±≥          ≥          ≥                                                 ≥±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/


Static Function Gravmarg

dbSelectArea("SB1")
dbSetOrder(1)
dbSeek(xFilial("SB1")+xCodIni, .F. )
_fDA1 := xFilial( "DA1" )

If Found()

   While SB1->B1_COD <= xCodFim .And. !Eof()

     If !Empty(xMargemT)

         RecLock("SB1",.F.)
         If SB1->B1_UM <> 'MT'
            SB1->B1_PRSUP  := SB1->B1_CUSTD + Round((SB1->B1_CUSTD*xMargemT/100),2)
         Else
            SB1->B1_PRSUP  := SB1->B1_CUSTD + Round((SB1->B1_CUSTD*xMargemT/100),4)
         End
         SB1->B1_MGMSUPE:= xMargemT
         MsUnlock()

         DA1->( dbSeek( _fDA1 + SB1->B1_COD + '6  ', .T. ) ) 

         If SB1->B1_COD = DA1->DA1_CODPRO

            DA1->( RecLock( 'DA1', .F. ) )
            DA1->DA1_PRCVEN := SB1->B1_PRSUP
            DA1->( MSUnLock() )

         End

     ElseIf iMargem != 0

         RecLock("SB1",.F.)      
         _nCustD := iMargem
         _nCustD += SB1->B1_MARGMIN
         SB1->B1_MGMSUPE := _nCustD
         _nCustD /= 100
         _nCustD += 1
         _nCustD *= SB1->B1_CUSTD
         _nCustD *= 1.112
         If SB1->B1_UM <> 'MT'
            SB1->B1_PRSUP := Round( _nCustD, 2 )
         Else
            SB1->B1_PRSUP := Round( _nCustD, 4 )
         End
         MsUnlock()

         DA1->( dbSeek( _fDA1 + SB1->B1_COD + '6  ', .T. ) ) 

         If SB1->B1_COD = DA1->DA1_CODPRO

            DA1->( RecLock( 'DA1', .F. ) )
            DA1->DA1_PRCVEN := SB1->B1_PRSUP
            DA1->( MSUnLock() )

         End
         
     End

     If !Empty(xMargemR)

        RecLock("SB1",.F.)
        If SB1->B1_UM <> 'MT'   
           SB1->B1_PRMN501:= SB1->B1_CUSTD + Round((SB1->B1_CUSTD*xMargemR/100),2)
        Else
           SB1->B1_PRMN501:= SB1->B1_CUSTD + Round((SB1->B1_CUSTD*xMargemR/100),4)
        End
        SB1->B1_MARGMIN:= xMargemR
        SB1->B1_PRV1 := SB1->B1_PRMN501
        MsUnlock()

        DA1->( dbSeek( _fDA1 + SB1->B1_COD + '1  ', .T. ) ) 

        If SB1->B1_COD = DA1->DA1_CODPRO

           DA1->( RecLock( 'DA1', .F. ) )
           DA1->DA1_PRCVEN := SB1->B1_PRMN501
           DA1->( MSUnLock() )

        End

     ElseIf iMargem != 0

         RecLock("SB1",.F.)
         _nCustD := iMargem  
         _nCustD += SB1->B1_MARGMIN
         SB1->B1_MARGMIN := _nCustD
         _nCustD /= 100
         _nCustD += 1
         _nCustD *= SB1->B1_CUSTD
         If SB1->B1_UM <> 'MT'   
            SB1->B1_PRMN501 := Round( _nCustD, 2 )
         Else
            SB1->B1_PRMN501 := Round( _nCustD, 4 )
         End
         SB1->B1_PRV1 := SB1->B1_PRMN501
         MsUnlock()

         DA1->( dbSeek( _fDA1 + SB1->B1_COD + '1  ', .T. ) ) 

         If SB1->B1_COD = DA1->DA1_CODPRO

            DA1->( RecLock( 'DA1', .F. ) )
            DA1->DA1_PRCVEN := SB1->B1_PRMN501
            DA1->( MSUnLock() )

         End


     End

     If !Empty(xMargem9)

        RecLock("SB1",.F.)
        If SB1->B1_UM <> 'MT'   
           SB1->B1_PRMN900 := SB1->B1_CUSTD + Round((SB1->B1_CUSTD*xMargem9/100),2)
        Else
           SB1->B1_PRMN900 := SB1->B1_CUSTD + Round((SB1->B1_CUSTD*xMargem9/100),4)
        End
        SB1->B1_MARG900 := xMargem9
        MsUnlock()

        DA1->( dbSeek( _fDA1 + SB1->B1_COD + '2  ', .T. ) ) 

        If SB1->B1_COD = DA1->DA1_CODPRO

           DA1->( RecLock( 'DA1', .F. ) )
           DA1->DA1_PRCVEN := SB1->B1_PRMN900
           DA1->( MSUnLock() )

        End

     ElseIf iMargem != 0

         RecLock("SB1",.F.)
         _nCustD := iMargem
         _nCustD += SB1->B1_MARG900
         SB1->B1_MARG900 := _nCustD
         _nCustD /= 100
         _nCustD += 1
         _nCustD *= SB1->B1_CUSTD
         If SB1->B1_UM <> 'MT'   
            SB1->B1_PRMN900 := Round( _nCustD, 2 )
         Else
            SB1->B1_PRMN900 := Round( _nCustD, 4 )
         End
         MsUnlock()

         DA1->( dbSeek( _fDA1 + SB1->B1_COD + '2  ', .T. ) ) 

         If SB1->B1_COD = DA1->DA1_CODPRO

            DA1->( RecLock( 'DA1', .F. ) )
            DA1->DA1_PRCVEN := SB1->B1_PRMN900
            DA1->( MSUnLock() )

         End


      Endif



      If !Empty(xMargemP)

         RecLock("SB1",.F.)
         If SB1->B1_UM <> 'MT'   
            SB1->B1_PR500M := SB1->B1_CUSTD + Round((SB1->B1_CUSTD*xMargemP/100),2)
         Else
            SB1->B1_PR500M := SB1->B1_CUSTD + Round((SB1->B1_CUSTD*xMargemP/100),4)
         End
         SB1->B1_MGM50M := xMargemP
         MsUnlock()


     ElseIf iMargem != 0

         RecLock("SB1",.F.)
         _nCustD := iMargem
         _nCustD += SB1->B1_MGM50M
         SB1->B1_MGM50M := _nCustD
         _nCustD /= 100
         _nCustD += 1
         _nCustD *= SB1->B1_CUSTD
         If SB1->B1_UM <> 'MT'   
            SB1->B1_PR500M := Round( _nCustD, 2 )
         Else
            SB1->B1_PR500M := Round( _nCustD, 4 )
         End
         MsUnlock()
      Endif

      If !Empty(xMargemD)

         RecLock("SB1",.F.)
         If SB1->B1_UM <> 'MT'   
            SB1->B1_PRDIRE := SB1->B1_CUSTD + Round((SB1->B1_CUSTD*xMargemD/100),2)
         Else
            SB1->B1_PRDIRE := SB1->B1_CUSTD + Round((SB1->B1_CUSTD*xMargemD/100),4)
         End
         SB1->B1_MGDIRET:= xMargemD
         MsUnlock()

         DA1->( dbSeek( _fDA1 + SB1->B1_COD + '3  ', .T. ) ) 

         If SB1->B1_COD = DA1->DA1_CODPRO

            DA1->( RecLock( 'DA1', .F. ) )
            DA1->DA1_PRCVEN := SB1->B1_PRDIRE
            DA1->( MSUnLock() )
      
         End

     ElseIf iMargem != 0

         RecLock("SB1",.F.)
         _nCustD := iMargem
         _nCustD += SB1->B1_MGDIRET
         SB1->B1_MGDIRET := _nCustD
         _nCustD /= 100
         _nCustD += 1
         _nCustD *= SB1->B1_CUSTD
         If SB1->B1_UM <> 'MT'   
            SB1->B1_PRDIRE := Round( _nCustD, 2 )
         Else
            SB1->B1_PRDIRE := Round( _nCustD, 4 )
         End
         MsUnlock()

         DA1->( dbSeek( _fDA1 + SB1->B1_COD + '3  ', .T. ) ) 

         If SB1->B1_COD = DA1->DA1_CODPRO

            DA1->( RecLock( 'DA1', .F. ) )
            DA1->DA1_PRCVEN := SB1->B1_PRDIRE
            DA1->( MSUnLock() )
      
         End

      Endif

      dbSkip()
   Enddo

   MSGSTOP("FIM DO PROCESSAMENTO !!!")

Else

   Aviso("Aviso","O Produto Inicial Selecionado n∆o Existe",{"OK"})
   Return

Endif

Cancela()

Static Function Cancela
iMargem := 0
Close(oDlg)
Return (.T.)   

