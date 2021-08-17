#Include "rwmake.ch"
#Include "Protheus.ch"
#Include "TopConn.ch"

/*

Programa  - RptAcpVd - Author - Sérgio Santana - 08/10/2003
Relatório de acompanhamento de vendas

*/

User Function RptAcpVd()
    
	PRIVATE CbTxt     := ""
	PRIVATE CbCont    := ""
	PRIVATE nOrdem    := 0
	PRIVATE Tamanho   := "G"
	PRIVATE Limite    := 232
	PRIVATE Titulo    := PADC("RptAcpVd - Emissão do Acompanhamento de Vendas            ",75)
	PRIVATE cDesc1    := PADC("Emitir relação dos Pedidos de Vendas, Notas Fiscias e     ",75)
	PRIVATE cDesc2    := PADC("Romaneios.                                                ",75)
	PRIVATE cDesc3    := PADC("Conforme parametro solicitado ao usuário                  ",75)
	PRIVATE aReturn   := { "Especial" , 1, "Diretoria" , 2, 2, 1,"", 0 }
	PRIVATE NomeProg  := "RptAcpVd"
	PRIVATE cPerg     := PadR("RPTACP",10)
	PRIVATE nLastKey  := 0
	PRIVATE nLin      := 61
	PRIVATE wnrel     := "RptAcpVd"
	PRIVATE M_PAG     := 1
	PRIVATE cArqTrb  := CriaTrab(NIL,.F.)
	
	cTitulo := 'Acompanhamento de Vendas'
	
	//         10        20        30        40        50        60        70        80        90       100       110       120       130       140       150       160       170       180       190       200       210       220       230       240
	// 123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
	
	Cabec1  := '                                                                                                                                                                                             PED    PED  PED  NOTA  NOTA   '
	Cabec2  := 'PEDIDO  CODIGO LJ CLIENTE                    MUNICIPIO                     UF  TRANSPORTADORA     STATUS     OBSERVACAO   NOTA          ROMANEIO   PEDIDO    NOTA       ROMANEIO   CANHOTO   NOTA   ROM  CHT  ROM   CHT    '
	
	Pergunte( cPerg,.F. )
	
	PRIVATE cstring:="SC9"
	
	wnrel := SetPrint(cString,wnrel,cPerg,Titulo ,cDesc1,cDesc2,cDesc3,.T.,,.T.)
	
	If nLastKey == 27
		Return
	Endif
	
	SetDefault( aReturn, cString )
	
	If nLastKey == 27
		Return
	Endif
	
	RptStatus({ || RptDetail() })
	
	If mv_par09 = 2
		
		__Eject()
		
		Set Device To Screen
		Set Printer To
		
		If aReturn[ 5 ] == 1
			dbcommitAll()
			OurSpool( wnrel )
		End
	
	EndIf
	
	MS_FLUSH()
	
Return( NIL )

Static Function RptDetail()
    
	Local aStru	 := {} 
    Local _nCont := 0
    
	_fSC9    := xFilial( 'SC9' )
	_iPer    := DtoS( MV_PAR03 )
	_fPer    := DtoS( MV_PAR04 )
	_iTransp := MV_PAR05
	_fTransp := MV_PAR06
	_iNum	 := MV_PAR01
	_fNum	 := MV_PAR02
	
	If Select("SZZ") > 0
		DbSelectArea("SZZ")
		SZZ->(DbCloseArea())
	EndIf 
	
	If MV_PAR08 <> 2
		
		_cSql := "SELECT SC5.C5_NUM AS Pedido, SA1.A1_NREDUZ AS Cliente, SA3.A3_NREDUZ AS Vendedor, SC5.C5_NOTA AS Nota, "
		_cSql += "        SC5.C5_SERIE AS Serie, CASE SC5.C5_NOTA WHEN ' ' THEN '        ' ELSE SD1.D1_DOC END AS Romaneio, "
		_cSql += "        CASE SC5.C5_NOTA WHEN ' ' THEN '        ' ELSE SD1.D1_EMISSAO END AS DtRomaneio, SC5.C5_EMISSAO AS Dt_Pedido, "
		_cSql += "        SC5.C5_CANHOTO AS Dt_Canhoto, SF2.F2_EMISSAO AS Dt_Nota, SC5.C5_TIPENT As TipEnt, "
		_cSql += "        SA1.A1_COD AS CodCli, SA1.A1_LOJA AS Loja, SA1.A1_MUN AS Municipio, SA1.A1_EST AS UF, SA1.A1_COD_MUN AS IBGE, "
		_cSql += "        SA4.A4_NREDUZ AS Transp, SC5.C5_TIPO AS Tipo, "
		_cSql += "        CASE SC5.C5_DESPACH WHEN ' ' THEN 'N' ELSE 'S' END AS DtDespacho "
		_cSql += "FROM " + RetSqlName("SC5") +  " SC5 LEFT OUTER JOIN " + RetSqlName("SA1") + " SA1 ON "
		_cSql += "        SC5.C5_CLIENTE = SA1.A1_COD AND SC5.C5_LOJACLI = SA1.A1_LOJA "
		_cSql += "        LEFT OUTER JOIN " + RetSqlName("SA4") + " SA4 ON SC5.C5_TRANSP = SA4.A4_COD AND (SA4.D_E_L_E_T_ <> '*') "
		_cSql += "        LEFT OUTER JOIN " + RetSqlName("SD1") + " SD1 ON SD1.D1_NFORI = SC5.C5_NOTA AND SD1.D1_SERIORI = SC5.C5_SERIE AND (SD1.D1_COD IN ('FRETE', "
		_cSql += "        'REDESPACHO')) AND (SD1.D_E_L_E_T_ <> '*') "
		_cSql += "        AND SD1.D1_TIPO <> 'C' "
		_cSql += "        AND SC5.C5_FILIAL = SD1.D1_FILIAL AND SC5.C5_NOTA <> '  ' "
		_cSql += "        LEFT OUTER JOIN " + RetSqlName("SF2") + " SF2 ON SC5.C5_NOTA = SF2.F2_DOC AND SC5.C5_SERIE = SF2.F2_SERIE AND SF2.D_E_L_E_T_ <> '*' "
		_cSql += "        AND SF2.F2_SERIE NOT IN ('ETP') "
		_cSql += "        LEFT OUTER JOIN " + RetSqlName("SA3") + " SA3 ON SC5.C5_VEND1 = SA3.A3_COD "
		_cSql += "        AND C5_FILIAL = '" + xFilial("SC5") + "'  "  // CURITIBA
		_cSql += "WHERE  (SC5.C5_EMISSAO BETWEEN '" + _iPer + "' AND '" + _fPer + "')  AND "
		_cSql += " 		 (SC5.C5_NUM BETWEEN '" + _iNum + "' AND '" + _fNum + "') AND "
		_cSql += "       (SC5.C5_TRANSP BETWEEN '" + _iTransp + "' AND '" + _fTransp + "') AND " 
		
	Else
		
		_cSql := "SELECT SC5.C5_NUM AS Pedido, SA1.A1_NREDUZ AS Cliente, SA3.A3_NREDUZ AS Vendedor, SC5.C5_NOTA AS Nota, "
		_cSql += "        SC5.C5_SERIE AS Serie, CASE SC5.C5_NOTA WHEN ' ' THEN '        ' ELSE SD1.D1_DOC END AS Romaneio, "
		_cSql += "        SA1.A1_COD AS CodCli, SA1.A1_LOJA AS Loja, SA1.A1_MUN AS Municipio, SA1.A1_EST AS UF, SA1.A1_COD_MUN AS IBGE, "
		_cSql += "        CASE SC5.C5_NOTA WHEN ' ' THEN '        ' ELSE SD1.D1_EMISSAO END AS DtRomaneio, SC5.C5_EMISSAO AS Dt_Pedido, "
		_cSql += "        SC5.C5_CANHOTO AS Dt_Canhoto, SF2.F2_EMISSAO AS Dt_Nota, SC5.C5_TIPO AS Tipo, SC5.C5_TIPENT As TipEnt, "
		_cSql += "        CASE WHEN SC5.C5_DESPACH <> ' ' THEN SA2.A2_NREDUZ ELSE 'SEM ROMANEIO' END As Transp, "
		_cSql += "        CASE SC5.C5_DESPACH WHEN ' ' THEN 'N' ELSE 'S' END AS DtDespacho "
		_cSql += "FROM " + RetSqlName("SC5") + " SC5 LEFT OUTER JOIN " + RetSqlName("SA1")
		_cSql += "        SA1 ON SC5.C5_CLIENTE = SA1.A1_COD AND SC5.C5_LOJACLI = SA1.A1_LOJA "
		_cSql += "        LEFT OUTER JOIN " + RetSqlName("SD1") + " SD1 ON SD1.D1_NFORI = SC5.C5_NOTA AND SD1.D1_SERIORI = SC5.C5_SERIE AND (SD1.D1_COD IN ('FRETE', "
		_cSql += "        'REDESPACHO')) AND (SD1.D_E_L_E_T_ <> '*') "
		_cSql += "        AND SD1.D1_TIPO <> 'C' "
		_cSql += "        AND SC5.C5_FILIAL = SD1.D1_FILIAL AND SC5.C5_NOTA <> '  ' "
		_cSql += "        LEFT OUTER JOIN " + RetSqlName("SA2") + " SA2 ON SD1.D1_FORNECE = SA2.A2_COD AND SD1.D1_LOJA = SA2.A2_LOJA AND (SA2.D_E_L_E_T_ <> '*') "
		_cSql += "        LEFT OUTER JOIN " + RetSqlName("SF2") + " SF2 ON SC5.C5_NOTA = SF2.F2_DOC AND SC5.C5_SERIE = SF2.F2_SERIE AND SF2.D_E_L_E_T_ <> '*' "
		_cSql += "        AND C5_FILIAL = F2_FILIAL "
		_cSql += "        AND SF2.F2_SERIE NOT IN ('ETP') "
		_cSql += "        LEFT OUTER JOIN " + RetSqlName("SA3") + " SA3 ON SC5.C5_VEND1 = SA3.A3_COD "
		_cSql += "WHERE  (SC5.C5_EMISSAO BETWEEN '" + _iPer + "' AND '" + _fPer + "')  AND "
		_cSql += "       (SC5.C5_NUM BETWEEN '" + _iNum + "' AND '" + _fNum + "') AND "
		_cSql += "       (SC5.C5_TRANSP BETWEEN '" + _iTransp + "' AND '" + _fTransp + "') AND " 
		
	End
	
	_cSql += " (SC5.C5_SERIE NOT IN ('TRC','ORC')) AND (SC5.D_E_L_E_T_ <> '*') "
	
	If MV_PAR07 = 1
		_cSql += " AND (SC5.C5_CANHOTO <> '        ') "
	ElseIf MV_PAR07 = 2
		_cSql += " AND (SC5.C5_CANHOTO = '        ') AND (SC5.C5_NOTA <> '      ') "
	ElseIf MV_PAR07 = 3
	    _cSql += " AND (SC5.C5_NOTA <> '        ') " 
    ElseIf MV_PAR07 = 4
		//_cSql += "AND (SC5.C5_NOTA = '      ') "
	ElseIf MV_PAR07 = 5
		
	EndIf
	
	_cSql += " AND C5_FILIAL = '" + xFilial("SC5") + "' "  // CURITIBA
	
	_cSql += " ORDER BY Dt_Pedido, Transp, Pedido "
	//_cSql += " ORDER BY Pedido "
	
	//MEMOWRITE("E:\TESTESQL.SQL",_cSql)
	
	If Select("XXX") > 0
		DbSelectArea("XXX")
		XXX->(DbCloseArea())
	EndIf
		
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,_cSql), 'XXX' , .F. )
	
	//__SetCentury( "On" )
	
	_nProc := 0
	_nCont := 0
	
	If Select("SZZ") > 0
		DbSelectArea("SZZ")
		SZZ->(DbCloseArea())
	EndIf
	
	aAdd(aStru,{"Pedido"	  ,"C",06,0})
	aAdd(aStru,{"Cliente"	  ,"C",20,0})
	aAdd(aStru,{"Vendedor"	  ,"C",15,0}) 
	aAdd(aStru,{"Nota"  	  ,"C",09,0}) 
	aAdd(aStru,{"Serie"		  ,"C",03,0}) 
	aAdd(aStru,{"Romaneio"	  ,"C",09,0}) 
	aAdd(aStru,{"CodCli"  	  ,"C",06,0}) 
	aAdd(aStru,{"Loja"  	  ,"C",02,0}) 
	aAdd(aStru,{"Municipio"   ,"C",60,0}) 
	aAdd(aStru,{"UF" 	      ,"C",02,0}) 
	aAdd(aStru,{"IBGE" 	      ,"C",05,0}) 
	aAdd(aStru,{"DtRomaneio"  ,"C",08,0}) 
	aAdd(aStru,{"Dt_Pedido"   ,"C",08,0}) 
	aAdd(aStru,{"Dt_Canhoto"  ,"C",08,0}) 
	aAdd(aStru,{"Dt_Nota"     ,"C",08,0}) 
	aAdd(aStru,{"Tipo" 	      ,"C",01,0})
	aAdd(aStru,{"TipEnt" 	  ,"C",01,0})
	aAdd(aStru,{"Transp"  	  ,"C",20,0})
	aAdd(aStru,{"DtDespacho"  ,"C",01,0})
	
	dbcreate(cArqTrb,aStru)
	dbUseArea(.T.,,cArqTrb,"SZZ",.F.,.F.)
	
	dbSelectArea('XXX')
	XXX->(dbGoTop())
	While XXX->(!EOF())
	    
	    If _nCont == 0
			DbSelectArea("SZZ")
			SZZ->(RecLock("SZZ",.T.))
				SZZ->Pedido      := XXX->Pedido
		        SZZ->Cliente     := XXX->Cliente
		        SZZ->Vendedor    := XXX->Vendedor
		        SZZ->Nota        := XXX->Nota
		        SZZ->Serie       := XXX->Serie
		        SZZ->Romaneio    := XXX->Romaneio
		        SZZ->CodCli      := XXX->CodCli
		        SZZ->Loja        := XXX->Loja
		        SZZ->Municipio   := XXX->Municipio 
		        SZZ->UF          := XXX->UF
		        SZZ->IBGE        := XXX->IBGE
		        SZZ->DtRomaneio  := XXX->DtRomaneio 
		        SZZ->Dt_Pedido   := XXX->Dt_Pedido
		        SZZ->Dt_Canhoto  := XXX->Dt_Canhoto
		        SZZ->Dt_Nota     := XXX->Dt_Nota
		        SZZ->Tipo        := XXX->Tipo
		        SZZ->TipEnt      := XXX->TipEnt
		        SZZ->Transp      := XXX->Transp
		        SZZ->DtDespacho  := XXX->DtDespacho
			SZZ->(MsUnlock("SZZ"))
			_nCont++
			DbSelectArea("XXX")
			XXX->(DbSkip())
		Else
	    	If SZZ->Pedido == XXX->Pedido .AND. SZZ->Nota == XXX->Nota .AND. SZZ->Romaneio < XXX->Romaneio
	        	DbSelectArea("SZZ")
				SZZ->(RecLock("SZZ",.F.))
					SZZ->Pedido      := XXX->Pedido
			        SZZ->Cliente     := XXX->Cliente
			        SZZ->Vendedor    := XXX->Vendedor
			        SZZ->Nota        := XXX->Nota
			        SZZ->Serie       := XXX->Serie
			        SZZ->Romaneio    := XXX->Romaneio
			        SZZ->CodCli      := XXX->CodCli
			        SZZ->Loja        := XXX->Loja
			        SZZ->Municipio   := XXX->Municipio 
			        SZZ->UF          := XXX->UF
			        SZZ->IBGE        := XXX->IBGE
			        SZZ->DtRomaneio  := XXX->DtRomaneio 
			        SZZ->Dt_Pedido   := XXX->Dt_Pedido
			        SZZ->Dt_Canhoto  := XXX->Dt_Canhoto
			        SZZ->Dt_Nota     := XXX->Dt_Nota
			        SZZ->Tipo        := XXX->Tipo
			        SZZ->TipEnt      := XXX->TipEnt
			        SZZ->Transp      := XXX->Transp
			        SZZ->DtDespacho  := XXX->DtDespacho
				SZZ->(MsUnlock("SZZ"))
				DbSelectArea("XXX")
				XXX->(DbSkip())
			Elseif SZZ->Pedido == XXX->Pedido .AND. SZZ->Nota == XXX->Nota .AND. SZZ->Romaneio > XXX->Romaneio
				DbSelectArea("XXX")
				XXX->(DbSkip())
			Else 
				DbSelectArea("SZZ")
				SZZ->(RecLock("SZZ",.T.))
					SZZ->Pedido      := XXX->Pedido
			        SZZ->Cliente     := XXX->Cliente
			        SZZ->Vendedor    := XXX->Vendedor
			        SZZ->Nota        := XXX->Nota
			        SZZ->Serie       := XXX->Serie
			        SZZ->Romaneio    := XXX->Romaneio
			        SZZ->CodCli      := XXX->CodCli
			        SZZ->Loja        := XXX->Loja
			        SZZ->Municipio   := XXX->Municipio 
			        SZZ->UF          := XXX->UF
			        SZZ->IBGE        := XXX->IBGE
			        SZZ->DtRomaneio  := XXX->DtRomaneio 
			        SZZ->Dt_Pedido   := XXX->Dt_Pedido
			        SZZ->Dt_Canhoto  := XXX->Dt_Canhoto
			        SZZ->Dt_Nota     := XXX->Dt_Nota
			        SZZ->Tipo        := XXX->Tipo
			        SZZ->TipEnt      := XXX->TipEnt
			        SZZ->Transp      := XXX->Transp
			        SZZ->DtDespacho  := XXX->DtDespacho
				SZZ->(MsUnlock("SZZ"))
				DbSelectArea("XXX")
				XXX->(DbSkip())
			EndIf
		EndIf
	Enddo
	
	DbSelectArea("SZZ")
	SZZ->(DbGoTop())
	
	While !SZZ->(Eof())
	   _nProc++
	   SZZ->(DbSkip())
	Enddo
	
	SetRegua( _nProc )
	
	_cTransp := SZZ->Transp
	_oTransp := SZZ->Transp
	_oDta    := SZZ->Dt_Pedido
	_cStatus := ' '
	_cObs    := ' '
	
	_mPedNot := 0
	_mPedRom := 0
	_mPedCan := 0
	_mNotRom := 0
	_mNotCan := 0
	
	_tPedNot := 0
	_tPedRom := 0
	_tPedCan := 0
	_tNotRom := 0
	_tNotCan := 0
	
	_qPedNot := 0
	
	aDados1 := {}
	
	SZZ->(dbGoTop())
	
	While !SZZ->(Eof())
		
		IncRegua()
		
		SC9->( dbSeek( _fSC9 + SZZ->Pedido, .T. ) )
		
		If SZZ->Pedido <> SC9->C9_PEDIDO
			_lLib := .F.
		Else
			If ( SC9->C9_BLEST  = '  ' .And. SC9->C9_BLCRED = '  ' )
				_lLib := .T.
			Else
				_lLib := .F.
			End
		End
		
		If ( MV_PAR07 =  5  .And. _lLib ) .Or. ( MV_PAR07 <> 5 )
			aDados1 := ImpPedDet(aDados1)
		End
		
		SZZ->( dbSkip() )
		
		If _oTransp <> SZZ->Transp
			_cTransp := SZZ->Transp
			_oTransp := SZZ->Transp
		End
		
		If _oDta <> SZZ->Dt_Pedido
			_oDta := SZZ->Dt_Pedido
		End
	
	End
	
	If MV_PAR09 = 1
		U_ExcelIO(aDados1)
	EndIf
	
	_tPedNot /= _qPedNot
	_tPedRom /= _qPedNot
	_tPedCan /= _qPedNot
	_tNotRom /= _qPedNot
	_tNotCan /= _qPedNot
	
	nLin ++
	
	@ nLin,190 PSAY '---'
	@ nLin,195 PSAY '---'
	@ nLin,202 PSAY '---'
	@ nLin,207 PSAY '---'
	@ nLin,214 PSAY '---'
	
	nLin += 2
	
	@ nLin,180 PSAY 'MEDIA'
	@ nLin,190 PSAY _tPedNot Picture '999'
	@ nLin,195 PSAY _tPedRom Picture '999'
	@ nLin,202 PSAY _tPedCan Picture '999'
	@ nLin,207 PSAY _tNotRom Picture '999'
	@ nLin,214 PSAY _tNotCan Picture '999'
	
	nLin ++
	
	@ nLin,180 PSAY 'MAX'
	@ nLin,190 PSAY _mPedNot Picture '999'
	@ nLin,195 PSAY _mPedRom Picture '999'
	@ nLin,202 PSAY _mPedCan Picture '999'
	@ nLin,207 PSAY _mNotRom Picture '999'
	@ nLin,214 PSAY _mNotCan Picture '999'
	
	//__SetCentury( "Off" )
	
	SZZ->( dbCloseArea() )
	
Return( NIL )

Static Function CalcDifDt( _nIni, _nFim, _nRst )

	If _nIni <> ' '
		_cDta := Substr( _nIni, 7, 2 )
		_cDta += '/'
		_cDta += Substr( _nIni, 5, 2 )
		_cDta += '/'
		_cDta += Substr( _nIni, 1, 4 )
		_nIni := CtoD( _cDta )
	Else
	    _nIni := dDataBase
	End
	
	If _nFim <> ' '
		_cDta := Substr( _nFim, 7, 2 )
		_cDta += '/'
		_cDta += Substr( _nFim, 5, 2 )
		_cDta += '/'
		_cDta += Substr( _nFim, 1, 4 )
		_nFim := CtoD( _cDta )
	Else
		_nFim := dDataBase
	End
	
	_nDias := _nFim - _nIni
	
	If _nDias <> 0
		For n := 1 To _nDias
			
			_nDow := Dow( _nIni )
			
			If _nDow = 7 .Or.;
				_nDow = 1
				_nDias -= 1
			End
			
			_nIni += 1
			
		Next
	End
	
Return( _nIni, _nFim, _nDias )

Static Function CnvDt( _cCnv )

		_cDta := Substr( _cCnv, 7, 2 )
		_cDta += '/'
		_cDta += Substr( _cCnv, 5, 2 )
		_cDta += '/'
		_cDta += Substr( _cCnv, 1, 4 )
		_cCnv := CtoD( _cDta )
		
Return( _cCnv )
	
Static Function ImpPedDet(aDados)
	
	If nLin > 60
		nLin := Cabec(cTitulo,Cabec1,Cabec2,NomeProg,Tamanho,15)
		nLin ++
	End
	
	_dPedNot := 0
	_dPedRom := 0
	_dPedCan := 0
	_dNotRom := 0
	_dNotCan := 0
	_cPedNot := "X"
	_cPedRom := "X"
	_cNotRom := "X"
	_dPedNot := CalcDifDt( SZZ->Dt_Pedido, SZZ->Dt_Nota    , @_dPedNot )
	_dPedRom := CalcDifDt( SZZ->Dt_Pedido, SZZ->DtRomaneio, @_dPedRom )
	            
	If AllTrim(SZZ->Dt_Nota) == ""
		_cPedNot := ""
	Else              
		_cPedNot := "X"
	EndIf
	
	If AllTrim(SZZ->DtRomaneio) == ""
		_cPedRom := ""
	Else              
		_cPedRom := "X"
	EndIf
	
	If AllTrim(SZZ->Dt_Canhoto) == ""
		_cNotRom := ""
	Else              
		_cNotRom := "X"
	EndIf
	
	If SZZ->Serie <> 'ORC'
		_dPedCan := CalcDifDt( SZZ->Dt_Pedido, SZZ->Dt_Canhoto , @_dPedCan )
	Else
		CalcDifDt( SZZ->Dt_Pedido, SZZ->Dt_Canhoto , @_dPedCan )
	End
	
	If SZZ->Serie <> 'ORC'
		_dNotRom := CalcDifDt( SZZ->Dt_Nota  , SZZ->DtRomaneio, @_dNotRom )
	Else
		CalcDifDt( SZZ->Dt_Nota  , SZZ->DtRomaneio, @_dNotRom )
	End
	
	If SZZ->Serie <> 'ORC'
		_dNotCan := CalcDifDt( SZZ->Dt_Nota  , SZZ->Dt_Canhoto , @_dNotCan )
	Else
		CalcDifDt( SZZ->Dt_Nota  , SZZ->Dt_Canhoto , @_dNotCan )
	End
	
	_dPed := CnvDt( SZZ->Dt_Pedido   )
	_dNot := CnvDt( SZZ->Dt_Nota     )
	
	If SZZ->Dt_Nota <> ' '
		_dRom := CnvDt( SZZ->DtRomaneio )
	Else
		_dRom := CnvDt( '        ' )
	End
	
	_dCan := CnvDt( SZZ->Dt_Canhoto  )
	
	@ nLin,00 PSAY SZZ->Pedido Picture '@R 999.999'
	
	If SZZ->Tipo <> 'D'
		@ nLin,08 PSAY SZZ->CodCli
	    @ nLin,15 PSAY SZZ->Loja
	    @ nLin,18 PSAY SZZ->Cliente
	Else
		SC5->( dbSeek( _fSC9 + SZZ->Pedido, .F. ) )
		SA2->( dbSeek( xFilial( 'SA2' ) + SC5->C5_CLIENTE + SC5->C5_LOJACLI, .F. ) )
		
		@ nLin,08 PSAY SA2->A2_COD
		@ nLin,15 PSAY SA2->A2_LOJA
		@ nLin,18 PSAY SA2->A2_NREDUZ
	End
	@ nLin,46 PSAY SUBSTR(SZZ->Municipio,1,34)
	@ nLin,76 PSAY SZZ->UF
	//@ nLin,29  PSAY SZZ->Vendedor
	
	If SZZ->Nota <> '      '
		_cStatus := 'FATURADO'
	Else
		If SC9->C9_PEDIDO <> SZZ->Pedido
			_cStatus := 'NAO LIB'
		ElseIf SC9->C9_BLEST <> '  ' .And.;
			SC9->C9_BLCRED <> '  '
			_cStatus := 'BLQ EST/CRD'
		ElseIf SC9->C9_BLEST <> '  '
			_cStatus := 'BLQ. EST'
		ElseIf SC9->C9_BLCRED <> '  '
			_cStatus := 'BLQ. CRD'
		Else
			_cStatus := 'NAO FAT'
		End
	End
	
	If SZZ->Tipo <> 'D'
		If DtDespacho <> 'N' .And.;
			Nota = ' '
			_cObs := 'NF CANC'
		ElseIf SC9->C9_BLCRED = '01'
			_cObs    := 'CRD RECUS'
			_cStatus := 'NAO FAT'
		Else
			_cObs := ' '
		End
	Else
		_cObs := 'DEV FORNEC'
	End
	
	If Empty( _cObs )
		If ! SZZ->Transp $[900000.99    ] .And. ;
			SZZ->TipEnt <> ' '
			If SZZ->TipEnt <> '2'
				_cObs := 'RETIRA'
			Else
				_cObs := 'ENTREGAR'
			End
		End
	End
	
	@ nLin,80 PSAY Alltrim(SZZ->Transp)
	@ nLin,99 PSAY Alltrim(_cStatus)
	@ nLin,110 PSAY _cObs
	
	@ nLin,123  PSAY SZZ->Nota        Picture '@R 999.999.999'
	@ nLin,137  PSAY SZZ->Romaneio    Picture '@R 999.999'
	@ nLin,148  PSAY _dPed Picture '@E 99/99/9999'
	@ nLin,158  PSAY _dNot Picture '@E 99/99/9999'
	@ nLin,169  PSAY _dRom Picture '@E 99/99/9999'
	@ nLin,180  PSAY _dCan Picture '@E 99/99/9999'
	
	If _cPedNot == "X"
		@ nLin,188 PSAY _dPedNot Picture '999'
		If _cPedRom == "X"
			@ nLin,195 PSAY _dPedRom Picture '999'
			If _cNotRom == "X"
				@ nLin,205 PSAY _dNotRom Picture '999'
			EndIf
		EndIf
		If _cNotRom =="X"
			@ nLin,200 PSAY _dPedCan Picture '999'
			@ nLin,211 PSAY _dNotCan Picture '999'	
		EndIf
	EndIf
	
	//AADD(aDados,{SZZ->Pedido, SZZ->CodCli , SZZ->Loja , SZZ->Cliente , SZZ->IBGE , SZZ->UF , SZZ->Transp , _cStatus , _cObs , SZZ->Nota , SZZ->Romaneio,;
	AADD(aDados,{SZZ->Pedido, SZZ->CodCli , SZZ->Loja , SZZ->Cliente , SZZ->MUNICIPIO , SZZ->UF , SZZ->Transp , _cStatus , _cObs , SZZ->Nota , SZZ->Romaneio,;
	_dPed , _dNot , _dRom , _dCan , _dPedNot , _dPedRom , _dPedCan , _dNotRom , _dNotCan})
	
	_cTransp := ' '
	nLin ++
	
	If SZZ->Serie <> 'ORC'
		_qPedNot ++
		If _cPedNot <> "X"
			_tPedNot += _dPedNot
			_cPedNot := "X"
		EndIf
		
		If _mPedNot < _dPedNot
			_mPedNot := _dPedNot
		End
		
		If _cPedNot <> "X"	
			_tPedRom += _dPedRom
			_cPedRom := "X"
		EndIf
		
		If _mPedRom < _dPedRom
			_mPedRom := _dPedRom
		End
		
		_tPedCan += _dPedCan
		
		If _mPedCan < _dPedCan
			_mPedCan := _dPedCan
		End
		
		_tNotRom += _dNotRom
		
		If _mNotRom < _dNotRom
			_mNotRom := _dNotRom
		End
		
		_tNotCan += _dNotCan
		
		If _mNotCan < _dNotCan
			_mNotCan := _dNotCan
		End      
		
		_cPedRom := ""
		_cPedNot := ""
		_cNotRom := ""
	End
	
Return( aDados )