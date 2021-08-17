User Function TipoLib()

If SC5->C5_NOTA <> '      '

   _cMsg := 'Faturado'

ElseIf SC5->C5_LIBEROK <> ' ' 

   SC9->( dbSeek(  SC5->C5_FILIAL + SC5->C5_NUM, .T. ) )    

   If SC9->C9_PEDIDO <> SC5->C5_NUM

      _cMsg := 'Nao liberado'

   Else
     	
      If SC9->C9_BLCRED = '01'  

         _cMsg := 'Bloqueio de Credito por Valor'

      ElseIf SC9->C9_BLCRED = '04'

         _cMsg := 'Data de Credito Vencida'
      
      ElseIf SC9->C9_BLCRED = '05'

         _cMsg := 'Bloqueio de Credito por Estorno'
	
	  ElseIf SC9->C9_BLCRED = '06'

         _cMsg := 'Bloqueio de Credito por Risco'

	  ElseIf SC9->C9_BLCRED = '09'

         _cMsg := 'Rejeição manual de Credito'

      ElseIf SC9->C9_BLEST = '02'

         _cMsg := 'Bloqueio de Estoque'

      ElseIf SC9->C9_BLEST = '03'

         _cMsg := 'Bloqueio Manual de Estoque'

      ElseIf SC9->C9_BLEST <> ' '
      
      	_cMsg := 'Faturamento parcial'
      	
      Else

         _cMsg := 'Liberado'

      End
     
   End

Else

  _cMsg := 'Nao Liberado'

End

Return( _cMsg )