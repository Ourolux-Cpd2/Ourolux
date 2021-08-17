#INCLUDE "PROTHEUS.CH"

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±± AutMT240  ³ Autor: Claudino Pereira Domingues           ³ Data 29/10/14 ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±± Descricao ³ Rotina de acerto diferenças SB2 X SB8.                      ±±
±±           ³ Para consultor o saldo utilize o relatorio MATR282.         ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/

User Function AutMT240()

	Local _aAutoSai  := {}
	Local _aAutoEnt  := {}
	
	Local _lLote     := .F.
	Local _lSldSB2   := .F.
	
	Local _dVlLot    := Ctod("")
	
	Local _cLog      := "FILIAL    PRODUTO             TIPO MOVIMENTO   ARMAZEM     LOTE                  QUANT"
	Local _cLog1     := ""
	Local _cLog2     := "Saldo SB2 menor que diferença entre SB2 X SB8"
	Local _cPula     := CHR (13) + CHR (10)
	Local _cStrPatch := ""
	Local _cArqLog   := ""
	Local _cNome     := ""
	Local _cArqLog   := ""
	Local _cLogName  := ""
	Local _cLote     := ""
	Local _cQryDIF   := ""
	Local _cQrySB8   := ""
	Local _cQrySB1   := ""
	Local _cQrySB2   := ""
	Local _cFilial   := ""
	Local _cArmaze   := ""
	Local _cPerg     := "AUTMT240"
	
	Private lMSHelpAuto := .T. // Se .T. direciona as mensagens de help para o arq. de log
	Private lMSErroAuto := .F. // Sera atualizado quando houver alguma inconsistencia nos parametros
	
	CriaSX1(_cPerg)
	Pergunte(_cPerg,.T.)
	
	_cQryDIF := " SELECT * "
	_cQryDIF += " FROM ( "
	_cQryDIF += " 		SELECT "
	_cQryDIF += "			SB2.B2_FILIAL Filial, "
	_cQryDIF += "			SB2.B2_COD CodProd, "
	_cQryDIF += "			SB1.B1_CUSTD CustStand, "
	_cQryDIF += "			SB1.B1_UM UniMed, "
	_cQryDIF += "			SB1.B1_GRUPO GrpProd, "
	_cQryDIF += "           SB2.B2_LOCAL Armazem, "
	_cQryDIF += "           SB2.B2_QATU SldAtu, "
	
	_cQryDIF += "			(SELECT "
	_cQryDIF += "				 SUM(SB8.B8_SALDO) " 
	_cQryDIF += "           FROM "
	_cQryDIF += 				 RetSqlName("SB8") + " SB8 "
	_cQryDIF += "           WHERE "
	_cQryDIF += "				 SB8.B8_FILIAL = SB2.B2_FILIAL AND "
	_cQryDIF += "				 SB8.B8_LOCAL = SB2.B2_LOCAL AND "
	_cQryDIF += "				 SB8.B8_PRODUTO = SB2.B2_COD AND "
	_cQryDIF +=	"                SB8.D_E_L_E_T_ = ' ' "
	_cQryDIF += "			GROUP BY "
	_cQryDIF += " 				 SB8.B8_PRODUTO) AS QtdLote, "
	 
	_cQryDIF +=	"			SB2.B2_QATU - ( "
	_cQryDIF += "					SELECT "
	_cQryDIF += "						SUM(SB8.B8_SALDO) "
	_cQryDIF += "					FROM "
	_cQryDIF += 				 		RetSqlName("SB8") + " SB8 "
	_cQryDIF += "					WHERE "
	_cQryDIF += "						SB8.B8_FILIAL = SB2.B2_FILIAL AND "
	_cQryDIF += "						SB8.B8_LOCAL = SB2.B2_LOCAL AND "
	_cQryDIF += "						SB8.B8_PRODUTO = SB2.B2_COD AND "
	_cQryDIF += "						SB8.D_E_L_E_T_ = ' ' "
	_cQryDIF += " 					GROUP BY "
	_cQryDIF += "						SB8.B8_PRODUTO) AS Diferenca "
	
	_cQryDIF += " 		FROM "
	_cQryDIF += 			RetSqlName("SB2") + " SB2 "
	_cQryDIF += "		INNER JOIN "
	_cQryDIF += 			RetSqlName("SB1") + " SB1 "
	_cQryDIF += "			ON SB1.B1_COD = SB2.B2_COD "
	
	_cQryDIF += "		WHERE " 
	_cQryDIF += "			SB2.B2_COD BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "' AND "
	_cQryDIF += "			SB1.D_E_L_E_T_ = ' ' AND "
	_cQryDIF += " 			SB2.D_E_L_E_T_ = ' ' AND "
	_cQryDIF += "			SB2.B2_FILIAL = '" + MV_PAR03 + "' AND "
	_cQryDIF += "			SB2.B2_LOCAL = '" + MV_PAR04 + "' AND "
	_cQryDIF += "           SB1.B1_RASTRO = 'L' AND "
	_cQryDIF += "           SB1.B1_MSBLQL <> '1' "
	_cQryDIF += "	   ) QRYGERAL "
	
	_cQryDIF += " WHERE "
	_cQryDIF += " 	   QRYGERAL.DIFERENCA < 0 "
	
	_cQryDIF += " ORDER BY "
	_cQryDIF += " 	   QRYGERAL.CODPROD "

	_cQryDIF := ChangeQuery(_cQryDIF)
	
	If Select("DIFLOTE") > 0
		DbSelectArea("DIFLOTE")
		DIFLOTE->(DbCloseArea())
	EndIf
	
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQryDIF),"DIFLOTE",.F.,.T.)
    
    _cLog2 += _cPula
    
	While DIFLOTE->(!Eof())
		
		_cFilial := DIFLOTE->FILIAL
		_cArmaze := DIFLOTE->ARMAZEM
		
		If (DIFLOTE->DIFERENCA * -1) > DIFLOTE->SLDATU
			
			_lLote   := .F.
			_lSldSB2 := .F.
			
			_cQrySB8 := " SELECT "
			_cQrySB8 += " 		SB8.B8_FILIAL Filial, "
			_cQrySB8 += " 		SB8.B8_PRODUTO CodProd, "
			_cQrySB8 += "		SB8.B8_LOCAL Armazem, "
			_cQrySB8 += "		SB8.B8_SALDO SldLote, "
			_cQrySB8 += "		SB8.B8_EMPENHO EmpLote, "
			_cQrySB8 += "		SB8.B8_LOTECTL Lote, "
			_cQrySB8 += "		SB8.B8_DTVALID DtVlLote "
			_cQrySB8 += " FROM " 
			_cQrySB8 += 		RetSqlName("SB8") + " SB8 "
			_cQrySB8 += " WHERE "
			_cQrySB8 += " 		SB8.D_E_L_E_T_ = ' ' AND "
			_cQrySB8 += " 		SB8.B8_FILIAL = '" + DIFLOTE->FILIAL + "' AND "
			_cQrySB8 += " 		SB8.B8_PRODUTO = '" + DIFLOTE->CODPROD + "' AND "
			_cQrySB8 += " 		SB8.B8_LOCAL = '" + DIFLOTE->ARMAZEM + "' AND "
			_cQrySB8 += " 		SB8.B8_DTVALID >= '" + Dtos(dDataBase) + "' "				
			
			_cQrySB8 := ChangeQuery(_cQrySB8)
			
			If Select("LOTEVALID") > 0
				DbSelectArea("LOTEVALID")
				LOTEVALID->(DbCloseArea())
			EndIf
			
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQrySB8),"LOTEVALID",.F.,.T.)
			
			While LOTEVALID->(!Eof())
				If (LOTEVALID->SLDLOTE - LOTEVALID->EMPLOTE) >= (DIFLOTE->DIFERENCA * -1)
					_cLote  := LOTEVALID->LOTE
					_dVlLot := LOTEVALID->DTVLLOTE
					_lLote  := .T.
					Exit
				EndIf		
		    	LOTEVALID->(DbSkip())
		    EndDo
		    
		    If Select("LOTEVALID") > 0
				DbSelectArea("LOTEVALID")
				LOTEVALID->(DbCloseArea())
			EndIf
		    
		    If _lLote
				
				_cQrySB1 := " UPDATE "
				_cQrySB1 += 		RetSqlName("SB1")
				_cQrySB1 += " SET "
				_cQrySB1 += "		B1_RASTRO = 'N' "
				_cQrySB1 += " WHERE "
				_cQrySB1 += "		B1_COD = '" + DIFLOTE->CODPROD + "' "
				
				TCSQLExec(_cQrySB1)
				
				_cQrySB1 := ""    
			   
				_aAutoEnt:={{"D3_TM"      ,"001"                                  ,Nil},;
					 	    {"D3_COD"     ,DIFLOTE->CODPROD                       ,Nil},;
					 	    {"D3_UM"      ,DIFLOTE->UNIMED                        ,Nil},;
							{"D3_QUANT"   ,(DIFLOTE->DIFERENCA * -1)              ,Nil},;
					 	    {"D3_LOCAL"   ,DIFLOTE->ARMAZEM                       ,Nil},;
						 	{"D3_HISTORI" ,"Acerto de Lote Automatico (AUTMT240)" ,Nil},;
						 	{"D3_EMISSAO" ,dDataBase                              ,Nil},;
						 	{"D3_CUSTO1"  ,DIFLOTE->CUSTSTAND                     ,Nil},;
						 	{"D3_GRUPO"   ,DIFLOTE->GRPPROD                       ,Nil}}
				
				MSExecAuto({|x,y| MATA240(x,y)},_aAutoEnt,3) 	    
				
				If lMsErroAuto
					_cStrPath := GetSrvProfString("Startpath","")
					_cArqLog  := CriaTrab(,.F.)+".LOG"
					_cNome    := _cArqLog
					_cLog     += _cPula + _cLog1 + _cLog2
					
					MemoWrite(_cNome,_cLog)
					
					_cLogName := "DIF"+_cFilial+_cArmaze;
								+StrZero(Day(dDataBase),2);
								+StrZero(Month(dDataBase),2);
								+SubStr(StrZero(Year(dDataBase),4),3,2);
								+SubStr(TIME(),1,2);
								+SubStr(TIME(),4,2);
								+SubStr(TIME(),7,2)+".LOG"
							
					Copy File (_cStrPath + _cArqLog) To ("\INTRJ\" + _cLogName)
					
					MostraErro()
					DisarmTransaction()
					break
				Else
					_cLog2 += DIFLOTE->FILIAL
					_cLog2 += SPACE(08)+DIFLOTE->CODPROD
					_cLog2 += SPACE(05)+"001"
					_cLog2 += SPACE(14)+DIFLOTE->ARMAZEM
					_cLog2 += SPACE(20)
					_cLog2 += SPACE(10)+TRANSFORM((DIFLOTE->DIFERENCA * -1),"@E 999,999.99")
					_cLog2 += _cPula	
				EndIf
			    
				_cQrySB1 := " UPDATE "
				_cQrySB1 += 		RetSqlName("SB1")
				_cQrySB1 += " SET "
				_cQrySB1 += "		B1_RASTRO = 'L' "
				_cQrySB1 += " WHERE "
				_cQrySB1 += "		B1_COD = '" + DIFLOTE->CODPROD + "' "
				
				TCSQLExec(_cQrySB1)
				
				_cQrySB1 := ""    
			   
			    _aAutoSai:={{"D3_TM"      ,"501"                                  ,Nil},;
					 	    {"D3_COD"     ,DIFLOTE->CODPROD                       ,Nil},;
					 	    {"D3_UM"      ,DIFLOTE->UNIMED                        ,Nil},;
			   		 	    {"D3_QUANT"   ,(DIFLOTE->DIFERENCA * -1)              ,Nil},;
					 	    {"D3_LOCAL"   ,DIFLOTE->ARMAZEM                       ,Nil},;
					 	    {"D3_HISTORI" ,"Acerto de Lote Automatico (AUTMT240)" ,Nil},;
					 	    {"D3_EMISSAO" ,dDataBase                              ,Nil},;
					 	    {"D3_CUSTO1"  ,DIFLOTE->CUSTSTAND                     ,Nil},;
					 	    {"D3_GRUPO"   ,DIFLOTE->GRPPROD                       ,Nil},;
					 	    {"D3_LOTECTL" ,_cLote                                 ,Nil},;
					 	    {"D3_DTVALID" ,STOD(_dVlLot)                          ,Nil}}
			
				MSExecAuto({|x,y| MATA240(x,y)},_aAutoSai,3)      	    
			
				If lMsErroAuto
					_cStrPath := GetSrvProfString("Startpath","")
					_cArqLog  := CriaTrab(,.F.)+".LOG"
					_cNome    := _cArqLog
					_cLog     += _cPula + _cLog1 + _cLog2
					
					MemoWrite(_cNome,_cLog)
					
					_cLogName := "DIF"+_cFilial+_cArmaze;
								+StrZero(Day(dDataBase),2);
								+StrZero(Month(dDataBase),2);
								+SubStr(StrZero(Year(dDataBase),4),3,2);
								+SubStr(TIME(),1,2);
								+SubStr(TIME(),4,2);
								+SubStr(TIME(),7,2)+".LOG"
							
					Copy File (_cStrPath + _cArqLog) To ("\INTRJ\" + _cLogName)
					
					MostraErro()
					DisarmTransaction()
					break
				Else
					_cLog2 += DIFLOTE->FILIAL
					_cLog2 += SPACE(08)+DIFLOTE->CODPROD
					_cLog2 += SPACE(05)+"501"
					_cLog2 += SPACE(14)+DIFLOTE->ARMAZEM
					_cLog2 += SPACE(10)+_cLote 
					_cLog2 += SPACE(10)+TRANSFORM((DIFLOTE->DIFERENCA * -1),"@E 999,999.99")
					_cLog2 += _cPula
				EndIf
			Else
				_cLog2 += "Filial: " + DIFLOTE->FILIAL + " Produto: " + DIFLOTE->CODPROD + " Armazem: " + DIFLOTE->ARMAZEM + " não possui quant.lote suficiente." 
				_cLog2 += _cPula
	            
	            // new wadih 19-02-2015
				_cQrySB1 := " UPDATE "
				_cQrySB1 += 		RetSqlName("SB1")
				_cQrySB1 += " SET "
				_cQrySB1 += "		B1_RASTRO = 'N' "
				_cQrySB1 += " WHERE "
				_cQrySB1 += "		B1_COD = '" + DIFLOTE->CODPROD + "' "
				
				TCSQLExec(_cQrySB1)

				_cQrySB1 := ""    
			   
			    _aAutoSai:={{"D3_TM"      ,"001"                                  ,Nil},;
					 	    {"D3_COD"     ,DIFLOTE->CODPROD                       ,Nil},;
					 	    {"D3_UM"      ,DIFLOTE->UNIMED                        ,Nil},;
			   		 	    {"D3_QUANT"   ,(DIFLOTE->DIFERENCA * -1)              ,Nil},;
					 	    {"D3_LOCAL"   ,DIFLOTE->ARMAZEM                       ,Nil},;
					 	    {"D3_HISTORI" ,"Acerto de Saldo SB2 Automatico (AUTMT240)" ,Nil},;
					 	    {"D3_EMISSAO" ,dDataBase                              ,Nil},;
					 	    {"D3_CUSTO1"  ,DIFLOTE->CUSTSTAND                     ,Nil},;
					 	    {"D3_GRUPO"   ,DIFLOTE->GRPPROD                       ,Nil}}
					 	    
				MSExecAuto({|x,y| MATA240(x,y)},_aAutoSai,3) 
				
				If lMsErroAuto
					_cStrPath := GetSrvProfString("Startpath","")
					_cArqLog  := CriaTrab(,.F.)+".LOG"
					_cNome    := _cArqLog
					_cLog     += _cPula + _cLog1 + _cLog2
					
					MemoWrite(_cNome,_cLog)
					
					_cLogName := "DIF"+_cFilial+_cArmaze;
								+StrZero(Day(dDataBase),2);
								+StrZero(Month(dDataBase),2);
								+SubStr(StrZero(Year(dDataBase),4),3,2);
								+SubStr(TIME(),1,2);
								+SubStr(TIME(),4,2);
								+SubStr(TIME(),7,2)+".LOG"
							
					Copy File (_cStrPath + _cArqLog) To ("\INTRJ\" + _cLogName)
					
					MostraErro()				
					DisarmTransaction()
					break
				Else
					_cLog1 += DIFLOTE->FILIAL
					_cLog1 += SPACE(08)+DIFLOTE->CODPROD
					_cLog1 += SPACE(05)+"001"
					_cLog1 += SPACE(14)+DIFLOTE->ARMAZEM 
					_cLog1 += SPACE(20)
					_cLog1 += SPACE(10)+TRANSFORM((DIFLOTE->DIFERENCA * -1),"@E 999,999.99")
					_cLog1 += _cPula
				EndIf
			    
				_cQrySB1 := " UPDATE "
				_cQrySB1 += 		RetSqlName("SB1")
				_cQrySB1 += " SET "
				_cQrySB1 += "		B1_RASTRO = 'L' "
				_cQrySB1 += " WHERE "
				_cQrySB1 += "		B1_COD = '" + DIFLOTE->CODPROD + "' "
				
				TCSQLExec(_cQrySB1)
				
				_cQrySB1 := ""
     	    	// new wadih 19-02-2015
			EndIf	
		
		Else
			
			_lLote   := .F.
			_lSldSB2 := .F.
			
			_cQrySB8 := " SELECT "
			_cQrySB8 += " 		SB8.B8_FILIAL Filial, "
			_cQrySB8 += " 		SB8.B8_PRODUTO CodProd, "
			_cQrySB8 += "		SB8.B8_LOCAL Armazem, "
			_cQrySB8 += "		SB8.B8_SALDO SldLote, "
			_cQrySB8 += "		SB8.B8_EMPENHO EmpLote, "
			_cQrySB8 += "		SB8.B8_LOTECTL Lote, "
			_cQrySB8 += "		SB8.B8_DTVALID DtVlLote "
			_cQrySB8 += " FROM " 
			_cQrySB8 += 		RetSqlName("SB8") + " SB8 "
			_cQrySB8 += " WHERE "
			_cQrySB8 += " 		SB8.D_E_L_E_T_ = ' ' AND "
			_cQrySB8 += " 		SB8.B8_FILIAL = '" + DIFLOTE->FILIAL + "' AND "
			_cQrySB8 += " 		SB8.B8_PRODUTO = '" + DIFLOTE->CODPROD + "' AND "
			_cQrySB8 += " 		SB8.B8_LOCAL = '" + DIFLOTE->ARMAZEM + "' AND "
			_cQrySB8 += " 		SB8.B8_DTVALID >= '" + Dtos(dDataBase) + "' "				
			
			_cQrySB8 := ChangeQuery(_cQrySB8)
			
			If Select("LOTEVALID") > 0
				DbSelectArea("LOTEVALID")
				LOTEVALID->(DbCloseArea())
			EndIf
			
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQrySB8),"LOTEVALID",.F.,.T.)
			
			While LOTEVALID->(!Eof())
				If (LOTEVALID->SLDLOTE - LOTEVALID->EMPLOTE) >= (DIFLOTE->DIFERENCA * -1)
					_cLote  := LOTEVALID->LOTE
					_dVlLot := LOTEVALID->DTVLLOTE
					_lLote  := .T.
					Exit
				EndIf		
		    	LOTEVALID->(DbSkip())
		    EndDo
		    
		    If Select("LOTEVALID") > 0
				DbSelectArea("LOTEVALID")
				LOTEVALID->(DbCloseArea())
			EndIf
		    
		    _cQrySB2 := " SELECT "
		    _cQrySB2 += "		SB2.B2_FILIAL Filial, "
		    _cQrySB2 += "		SB2.B2_COD CodProd, "
		    _cQrySB2 += "		SB2.B2_LOCAL Armazem, "
		    _cQrySB2 += "		SB2.B2_QATU Saldo, "
		    _cQrySB2 += "		SB2.B2_RESERVA Reserva "
		    _cQrySB2 += " FROM "
		    _cQrySB2 += 		RetSqlName("SB2") + " SB2 "
			_cQrySB2 += " WHERE "
			_cQrySB2 += "		SB2.B2_FILIAL = '" + DIFLOTE->FILIAL + "' AND "
			_cQrySB2 += " 		SB2.B2_COD = '" + DIFLOTE->CODPROD + "' AND "
			_cQrySB2 += "		SB2.B2_LOCAL = '" + DIFLOTE->ARMAZEM + "' "
            
            _cQrySB2 := ChangeQuery(_cQrySB2)
            
            If Select("SLDRESERV") > 0
				DbSelectArea("SLDRESERV")
				SLDRESERV->(DbCloseArea())
			EndIf
            
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQrySB2),"SLDRESERV",.F.,.T.)
			
			While SLDRESERV->(!Eof())
				If (SLDRESERV->SALDO - SLDRESERV->RESERVA) > (DIFLOTE->DIFERENCA * -1)
		    		_lSldSB2 := .T.
		    	EndIf		
		    	SLDRESERV->(DbSkip())
		    EndDo
		    
			If Select("SLDRESERV") > 0
				DbSelectArea("SLDRESERV")
				SLDRESERV->(DbCloseArea())
			EndIf
		    
		    If _lLote .And. _lSldSB2
			    _aAutoSai:={{"D3_TM"      ,"501"                                  ,Nil},;
					 	    {"D3_COD"     ,DIFLOTE->CODPROD                       ,Nil},;
					 	    {"D3_UM"      ,DIFLOTE->UNIMED                        ,Nil},;
			   		 	    {"D3_QUANT"   ,(DIFLOTE->DIFERENCA * -1)              ,Nil},;
					 	    {"D3_LOCAL"   ,DIFLOTE->ARMAZEM                       ,Nil},;
					 	    {"D3_HISTORI" ,"Acerto de Lote Automatico (AUTMT240)" ,Nil},;
					 	    {"D3_EMISSAO" ,dDataBase                              ,Nil},;
					 	    {"D3_CUSTO1"  ,DIFLOTE->CUSTSTAND                     ,Nil},;
					 	    {"D3_GRUPO"   ,DIFLOTE->GRPPROD                       ,Nil},;
					 	    {"D3_LOTECTL" ,_cLote                                 ,Nil},;
					 	    {"D3_DTVALID" ,STOD(_dVlLot)                          ,Nil}}
			
				MSExecAuto({|x,y| MATA240(x,y)},_aAutoSai,3)      	    
			
				If lMsErroAuto
					_cStrPath := GetSrvProfString("Startpath","")
					_cArqLog  := CriaTrab(,.F.)+".LOG"
					_cNome    := _cArqLog
					_cLog     += _cPula + _cLog1 + _cLog2
					
					MemoWrite(_cNome,_cLog)
					
					_cLogName := "DIF"+_cFilial+_cArmaze;
								+StrZero(Day(dDataBase),2);
								+StrZero(Month(dDataBase),2);
								+SubStr(StrZero(Year(dDataBase),4),3,2);
								+SubStr(TIME(),1,2);
								+SubStr(TIME(),4,2);
								+SubStr(TIME(),7,2)+".LOG"
							
					Copy File (_cStrPath + _cArqLog) To ("\INTRJ\" + _cLogName)
					
					MostraErro()
					DisarmTransaction()
					break
				Else
					_cLog1 += DIFLOTE->FILIAL
					_cLog1 += SPACE(08)+DIFLOTE->CODPROD
					_cLog1 += SPACE(05)+"501"
					_cLog1 += SPACE(14)+DIFLOTE->ARMAZEM
					_cLog1 += SPACE(10)+_cLote 
					_cLog1 += SPACE(10)+TRANSFORM((DIFLOTE->DIFERENCA * -1),"@E 999,999.99")
					_cLog1 += _cPula
				EndIf
			    
				_cQrySB1 := " UPDATE "
				_cQrySB1 += 		RetSqlName("SB1")
				_cQrySB1 += " SET "
				_cQrySB1 += "		B1_RASTRO = 'N' "
				_cQrySB1 += " WHERE "
				_cQrySB1 += "		B1_COD = '" + DIFLOTE->CODPROD + "' "
				
				TCSQLExec(_cQrySB1)
				
				_cQrySB1 := ""
			    
				_aAutoEnt:={{"D3_TM"      ,"001"                                  ,Nil},;
					 	    {"D3_COD"     ,DIFLOTE->CODPROD                       ,Nil},;
					 	    {"D3_UM"      ,DIFLOTE->UNIMED                        ,Nil},;
			   		 	    {"D3_QUANT"   ,(DIFLOTE->DIFERENCA * -1)              ,Nil},;
					 	    {"D3_LOCAL"   ,DIFLOTE->ARMAZEM                       ,Nil},;
					 	    {"D3_HISTORI" ,"Acerto de Lote Automatico (AUTMT240)" ,Nil},;
					 	    {"D3_EMISSAO" ,dDataBase                              ,Nil},;
					 	    {"D3_CUSTO1"  ,DIFLOTE->CUSTSTAND                     ,Nil},;
					 	    {"D3_GRUPO"   ,DIFLOTE->GRPPROD                       ,Nil}}
			
				MSExecAuto({|x,y| MATA240(x,y)},_aAutoEnt,3) 	    
			
				If lMsErroAuto
					_cStrPath := GetSrvProfString("Startpath","")
					_cArqLog  := CriaTrab(,.F.)+".LOG"
					_cNome    := _cArqLog
					_cLog     += _cPula + _cLog1 + _cLog2
					
					MemoWrite(_cNome,_cLog)
					
					_cLogName := "DIF"+_cFilial+_cArmaze;
								+StrZero(Day(dDataBase),2);
								+StrZero(Month(dDataBase),2);
								+SubStr(StrZero(Year(dDataBase),4),3,2);
								+SubStr(TIME(),1,2);
								+SubStr(TIME(),4,2);
								+SubStr(TIME(),7,2)+".LOG"
							
					Copy File (_cStrPath + _cArqLog) To ("\INTRJ\" + _cLogName)
					
					MostraErro()				
					DisarmTransaction()
					break
				Else
					_cLog1 += DIFLOTE->FILIAL
					_cLog1 += SPACE(08)+DIFLOTE->CODPROD
					_cLog1 += SPACE(05)+"001"
					_cLog1 += SPACE(14)+DIFLOTE->ARMAZEM 
					_cLog1 += SPACE(20)
					_cLog1 += SPACE(10)+TRANSFORM((DIFLOTE->DIFERENCA * -1),"@E 999,999.99")
					_cLog1 += _cPula
				EndIf
			    
				_cQrySB1 := " UPDATE "
				_cQrySB1 += 		RetSqlName("SB1")
				_cQrySB1 += " SET "
				_cQrySB1 += "		B1_RASTRO = 'L' "
				_cQrySB1 += " WHERE "
				_cQrySB1 += "		B1_COD = '" + DIFLOTE->CODPROD + "' "
				
				TCSQLExec(_cQrySB1)
				
				_cQrySB1 := ""
			Else		
				If !(_lLote)
					_cLog1 += "Filial: " + DIFLOTE->FILIAL + " Produto: " + DIFLOTE->CODPROD + " Armazem: " + DIFLOTE->ARMAZEM + " não possui quant.lote suficiente." 
					_cLog1 += _cPula
				ElseIf !(_lSldSB2)
					_cLog1 += "Filial: " + DIFLOTE->FILIAL + " Produto: " + DIFLOTE->CODPROD + " Armazem: " + DIFLOTE->ARMAZEM + " não possui quant suficiente no SB2 (B2_QATU - B2_RESERVA)." 
					_cLog1 += _cPula
				EndIf
			EndIf
	
		EndIf
		    
	    DIFLOTE->(DbSkip())	    
	EndDo
    
    If Select("DIFLOTE") > 0
		DbSelectArea("DIFLOTE")
		DIFLOTE->(DbCloseArea())
	EndIf
	
	_cStrPath := GetSrvProfString("Startpath","")
	_cArqLog  := CriaTrab(,.F.)+".LOG"
	_cNome    := _cArqLog
	_cLog     += _cPula + _cLog1 + _cLog2
	
	MemoWrite(_cNome,_cLog)
	
	_cLogName := "DIF"+_cFilial+_cArmaze;
				+StrZero(Day(dDataBase),2);
				+StrZero(Month(dDataBase),2);
				+SubStr(StrZero(Year(dDataBase),4),3,2);
				+SubStr(TIME(),1,2);
				+SubStr(TIME(),4,2);
				+SubStr(TIME(),7,2)+".LOG"
			
	Copy File (_cStrPath + _cArqLog) To ("\INTRJ\" + _cLogName)

Return

//----------------------------------------------//

Static Function CriaSX1(_cPerg)

	Local _aHelp := {}
	
	// Texto do help em    portugues                          , ingles, espanhol
	AADD(_aHelp,{{ "Informe um produto inicial."             },  {""} ,  {""}  })
	AADD(_aHelp,{{ "Informe um produto final."               },  {""} ,  {""}  })
	AADD(_aHelp,{{ "Informe a filial que deseja processar."  },  {""} ,  {""}  })
	AADD(_aHelp,{{ "Informe o armazem que deseja processar." },  {""} ,  {""}  })
	
	//      1Grup   2Ordem   3TituloPergPortugu      4TituloPergEspanho        5TituloPergIngles       6NomeVaria     7     8Tam   9dec  10    11    12   13F3    14   15        16       17   18   19   20   21   22   23   24   25   26   27   28   29   30   31   32   33HelpPort     34HelpIngl    35HelpEsp    36
	PutSX1( _cPerg ,  "01"  ,  "Do Produto ? "      ,  "De Producto ? "       ,  "From Product ? "    ,  "MV_CH1"  ,  "C"  ,  15  ,  0  ,  0  , "G" , "" , "SB1" , "" , "S" , "MV_PAR01" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , _aHelp[1,1] , _aHelp[1,2] , _aHelp[1,3] , "" )
	PutSX1( _cPerg ,  "02"  ,  "Ate Produto ? "     ,  "A Producto ? "        ,  "To Product ? "      ,  "MV_CH2"  ,  "C"  ,  15  ,  0  ,  0  , "G" , "" , "SB1" , "" , "S" , "MV_PAR02" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , _aHelp[2,1] , _aHelp[2,2] , _aHelp[2,3] , "" )
	PutSX1( _cPerg ,  "03"  ,  "Processa Filial ? " ,  "Processa Sucursal ? " ,  "Processa Branch ? " ,  "MV_CH3"  ,  "C"  ,  02  ,  0  ,  0  , "G" , "" , "SM0" , "" , "S" , "MV_PAR03" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , _aHelp[3,1] , _aHelp[3,2] , _aHelp[3,3] , "" )
	PutSX1( _cPerg ,  "04"  ,  "Armazem ? "         ,  "Deposito ? "          ,  "Warehouse ? "       ,  "MV_CH4"  ,  "C"  ,  02  ,  0  ,  0  , "G" , "" , ""    , "" , "S" , "MV_PAR04" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , _aHelp[4,1] , _aHelp[4,2] , _aHelp[4,3] , "" )
	
Return 