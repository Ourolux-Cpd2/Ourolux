/*

    Ponto de entrada para tratamento da exclus�o da nota fiscal saida
    Produtos com bloqueio de invent�rio n�o ser� excluido alterado por
    S�rgio Santana em 18/09/2002 

�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  � MS520VLD � Autor � Rodrigo de A. Sartorio� Data � Out/98   ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Exclui cupom fiscal para BEMATECH (DOS/WINDOWS)            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Verifica se � possivel excluir cupom e NF atraves do       ���
���          � programa MATA520 (SIGAFAT PADRAO)                          ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������

*/

User Function MS520Vld()

lRet:=.T.

//�����������������������������������������������������������������Ŀ
//� Caso a serie NAO SEJA DO CUPOM FISCAL, processa nota normalmente�
//�������������������������������������������������������������������

If Alltrim(SF2->F2_SERIE) != Alltrim(GETMV("MV_SERCUP"))

   _cSF2 := SF2->F2_FILIAL
   _cSF2 += SF2->F2_DOC
   _cSF2 += SF2->F2_CLIENTE
   _cSF2 += SF2->F2_LOJA

   SD2->( dbSeek( SF2->F2_FILIAL +;
                       SF2->F2_DOC    +;
                       SF2->F2_CLIENTE+;
                       SF2->F2_LOJA   ,;
                       .T.             ;
        )       )

   _cSD2 := SD2->D2_FILIAL
   _cSD2 += SD2->D2_DOC
   _cSD2 += SD2->D2_CLIENTE
   _cSD2 += SD2->D2_LOJA

   If _cSF2 = _cSD2

      While .T.

         If _cSF2 <> _cSD2

            Exit

         Else

            If ( SB2->( dbSeek( xFilial( 'SB2' ) + SD2->D2_COD + SD2->D2_LOCAL, .F. ) ) )

               If DtoS( SB2->B2_DTINV ) <> Space( 8 )

                  _cMsg := 'Este item ' + SD2->D2_DOC + '/' + SD2->D2_ITEM
                  _cMsg += ' n�o pode ser excluido, h� um bloqueio no estoque,' + Chr( 13 )
                  _cMsg += 'por  favor,  informe-se  com  o responsavel pelo bloqueio de estoque ' + Chr( 13 )
                  MsgInfo( _cMsg )
                  lRet := .F.

               End

            End

            SD2->( dbSkip() )

            _cSD2 := SD2->D2_FILIAL
            _cSD2 += SD2->D2_DOC
            _cSD2 += SD2->D2_CLIENTE
            _cSD2 += SD2->D2_LOJA

         End

      End

   End

Else

   // Numero do PDV que efetuou a venda
   If SF2->(FieldPos(F2_PDV)) > 0
      cNumPdv:=SF2->F2_PDV
      #IFNDEF WINDOWS
          cNumPdvAtu:= Substr(LjEnviaBm("35|14"),4,4)
      #ELSE
          cNumPdvAtu := CallMp20Fi("|35|14|")
      #ENDIF 

      If AllTrim(cNumPdv) != AllTrim(cNumPdvAtu)
         Tone(3000,1)
         Aviso("Aten��o","Esta venda foi efetuada por outro caixa .O Pdv que efetuou a venda foi: "+cNumPdv,{"Ok"})
         lRet:=.F.
      EndIf
   EndIf

   If lRet

      //�������������������������������������������������������������Ŀ
      //� Obtem o numero do cupom para gravar no SF2 para identificar �
      //� o numero da venda na impressora                             �
      //���������������������������������������������������������������

      #IFNDEF WINDOWS
          cNumAnt := SubStr(ljEnviaBm("30|"),4,6)
      #ELSE
          cNumAnt := CallMp20Fi("|30|")
      #ENDIF

      If !(SF2->F2_DOC == cNumAnt)
         Help(" ",1,"ULTCUP")
         lRet:=.F.
      EndIF
	
      #IFNDEF WINDOWS
          nError := 1
          While lRet
             If ljEnviaBm("19|")
                ljEnviaBm("14|")
                Exit
             EndIf
             nError:=nError+1

             If nError > 2
                lRet:=.F.
             EndIf
          EndDo
      #ELSE
          If lRet
             CallMp20Fi( "|14|" )
          EndIf
      #ENDIF
   EndIf
EndIf

Return( lRet )  
