User Function M460Ser()

//dbSelectArea("sc9")
//dbsetorder(1)
//dbgotop()
//msseek(xFilial("SC9")+MV_PAR05)

If SC9->C9_VENDA = 'P'
	
	SX5->( dbSeek( '  011  ', .F. ) )
	//_aNotas := { SX5->X5_CHAVE }
	_aNotas := {}
	aAdd( _aNotas, { SX5->X5_CHAVE, Val( SX5->X5_DESCRI ) } )
ElseIf SC9->C9_VENDA = 'O'
	
	SX5->( dbSeek( '  01ORC', .F. ) )
	_aNotas := { SX5->X5_CHAVE }
	
Else
	
	_aNotas := {}
	SX5->( dbSeek( '  01   ', .T. ) )
	
	While SX5->X5_TABELA = '01'
		/*if SC9->C9_VENDA = 'P'
		if SX5->X5_CHAVE == "1     " .or. SX5->X5_CHAVE == "EPP   "
		aAdd( _aNotas, { SX5->X5_CHAVE, Val( SX5->X5_DESCRI ) } )
		ENDIF
		ELSEIF SC9->C9_VENDA = 'O'
		if SX5->X5_CHAVE == "ORC   "
		aAdd( _aNotas, { SX5->X5_CHAVE, Val( SX5->X5_DESCRI ) } )
		ENDIF
		ELSE
		aAdd( _aNotas, { SX5->X5_CHAVE, Val( SX5->X5_DESCRI ) } )
		ENDIF
		*/
		aAdd( _aNotas, { SX5->X5_CHAVE, Val( SX5->X5_DESCRI ) } )
		SX5->( dbSkip() )
		
	End
	
End

Return ( 'ORC' )
