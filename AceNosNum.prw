#INCLUDE "PROTHEUS.CH"

User Function AceNosNum()   

Local NosNum := 0 
Local nBanco := 0
Local cQuery := ""
Local cPerg  := "NOSSNUM"
Local nCtr   := 0 

CriaSX1(cPerg)
Pergunte(cPerg,.T.)

cQuery := " SELECT "
cQuery += "		E1_VENCREA VECTOREAL, "
cQuery += "		E1_SITUACA SITUACAO, "
cQuery += "		E1_EMISSAO DTEMISSAO, "
cQuery += "		E1_CLIENTE CLIENTE, "
cQuery += "		E1_PREFIXO PREFIXO, "
cQuery += "		E1_NUM NUMERO, "
cQuery += "		E1_PARCELA PARCELA, "
cQuery += "		E1_TIPO TIPO, " 
cQuery += "		E1_NUMBCO, "
cQuery += " 	R_E_C_N_O_ RECNO "
cQuery += " FROM "+	RetSqlName("SE1") + " SE1 "

cQuery += " WHERE SE1.E1_VENCREA BETWEEN '"   +DTOS(MV_PAR01)+ "' AND '" +DTOS(MV_PAR02)+ "' "
cQuery += " 	AND SE1.E1_EMISSAO BETWEEN '" +DTOS(MV_PAR03)+ "' AND '" +DTOS(MV_PAR04)+ "' "
cQuery += "   	AND SE1.E1_CLIENTE BETWEEN '" +MV_PAR05+ "' AND '" +MV_PAR06+ "' "
cQuery += "   	AND SE1.E1_PREFIXO BETWEEN '" +MV_PAR07+ "' AND '" +MV_PAR08+ "' "
cQuery += "   	AND SE1.E1_NUM BETWEEN '"     +MV_PAR09+ "' AND '" +MV_PAR10+ "' "
cQuery += "   	AND SE1.E1_SITUACA = '" +MV_PAR11+ "' "
cQuery += "   	AND SE1.E1_TIPO = '" +MV_PAR12+ "' "
//cQuery += "   	AND ( SE1.E1_SALDO > 0  OR SE1.E1_OCORREN = '02' ) "
cQuery += "   	AND SE1.E1_NUMBCO = ' ' "
cQuery += "   	AND SE1.D_E_L_E_T_ <> '*' "
cQuery += " ORDER BY "+ SqlOrder(SE1->(IndexKey()))
				
cQuery := ChangeQuery(cQuery)

//MEMOWRITE("C:\TESTESQL.SQL",cQuery)
	
dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),'TRB',.F.,.T.)

dbSelectArea("TRB")
TRB->(dbGoTop())
While TRB->(!Eof())
	dbSelectArea("SE1")
	dbGoto(TRB->RECNO)
	If EMPTY(SE1->E1_NUMBCO)
		nCtr++
		NosNum := NumNosso(SE1->E1_PREFIXO,SubStr(SE1->E1_NUM,4,6),SE1->E1_PARCELA,@nBanco) 
		SE1->(RecLock("SE1",.F.))
			SE1->E1_NUMBCO  := NosNum         
		SE1->(MSUnLock())		
		TRB->(dbSkip())
	Else
		TRB->(dbSkip())
	EndIf
EndDo

dbSelectArea("SE1")
dbCloseArea()

dbSelectArea("TRB")
dbCloseArea()

ApMsgStop( 'Nr: ' + Alltrim( Transform(nCtr,'@E 999,999,999') ), 'AceNosNum' )
		
Return

Static Function NumNosso(cPrefixo,cNumero,cParcela,nBanco)   

Local nNNum		:= 0
Local _nParc	:= 0
Local _nDig		:= 0
Local _nRst     := 0
Local _nMlt     := { 2, 7, 6, 5, 4, 3, 2, 7, 6, 5, 4, 3, 2 }
   
nNNum := '09'
nNNum += StrZero( Val( cPrefixo ), 3 )   // Converter um numérico em uma string com zeros a esquerda.
nNNum += cNumero

If cParcela <> ' '
	_nParc := Asc( cParcela )
 	_nParc -= 64
  	_nParc := StrZero( _nParc, 2 )
   	nNNum  += _nParc
Else
	nNNum += '00' 
EndIf

nBanco := Substr( nNNum,  3, 9 )
nBanco += Substr( nNNum, 13, 1 )
   
_nDig := 0

For n := 1 To 13
	_nRst := Val( Substr( nNNum, n, 1 ) )
 	_nRst *= _nMlt[ n ]
  	_nDig += _nRst
Next

_nRst := Mod( _nDig, 11 )

If _nRst <> 0
	_nDig := 11
	_nDig -= _nRst
	
	If _nDig <> 10
		_nDig := StrZero( _nDig, 1 )
  	Else
   		_nDig := 'P'
   	EndIf
Else
	_nDig := '0'
EndIf

nNNum += _nDig
nNNum := Substr( nNNum, 3 )
   
Return(nNNum)   

Static Function CriaSX1(cPerg)  

PutSx1(cPerg,"01","Vencto Real de ?"   ,"","","mv_ch1","D",08,00,00,"G","","","","","mv_par01","","","","","","","","","","","","","","","","","","","","")
PutSx1(cPerg,"02","Vencto Real ate ?"  ,"","","mv_ch2","D",08,00,00,"G","","","","","mv_par02","","","","","","","","","","","","","","","","","","","","")
PutSx1(cPerg,"03","Data Emissão de ?"  ,"","","mv_ch3","D",08,00,00,"G","","","","","mv_par03","","","","","","","","","","","","","","","","","","","","")
PutSx1(cPerg,"04","Data Emissão ate ?" ,"","","mv_ch4","D",08,00,00,"G","","","","","mv_par04","","","","","","","","","","","","","","","","","","","","")
PutSx1(cPerg,"05","Cliente de ?"       ,"","","mv_ch5","C",06,00,00,"C","","","","","mv_par05","","","","","","","","","","","","","","","","","","","","")
PutSx1(cPerg,"06","Cliente ate ?"      ,"","","mv_ch6","C",06,00,00,"C","","","","","mv_par06","","","","","","","","","","","","","","","","","","","","")
PutSx1(cPerg,"07","Prefixo de ?"       ,"","","mv_ch7","C",03,00,00,"C","","","","","mv_par07","","","","","","","","","","","","","","","","","","","","")
PutSx1(cPerg,"08","Prefixo ate ?"      ,"","","mv_ch8","C",03,00,00,"C","","","","","mv_par08","","","","","","","","","","","","","","","","","","","","")
PutSx1(cPerg,"09","Numero de ?"        ,"","","mv_ch9","C",09,00,00,"C","","","","","mv_par09","","","","","","","","","","","","","","","","","","","","")
PutSx1(cPerg,"10","Numero ate ?"       ,"","","mv_cha","C",09,00,00,"C","","","","","mv_par10","","","","","","","","","","","","","","","","","","","","")
PutSx1(cPerg,"11","Situação ?"         ,"","","mv_chb","C",02,00,00,"C","","","","","mv_par11","","","","","","","","","","","","","","","","","","","","")
PutSx1(cPerg,"12","Tipo ?"             ,"","","mv_chc","C",02,00,00,"C","","","","","mv_par12","","","","","","","","","","","","","","","","","","","","")
    
Return

/*
Local _NosNum := 0 
Local nBanco  := 0
Local cPerg := "NOSSNUM"

CriaSX1(cPerg)
Pergunte(cPerg,.T.)

DbSelectArea("SE1")
DbSetOrder(1)

If dbSeek(xFilial("SE1")+MV_PAR01+MV_PAR02+MV_PAR03+MV_PAR04)
	While SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA+SE1->E1_TIPO <= MV_PAR05+MV_PAR06+MV_PAR07+MV_PAR08 
	    
	    If EMPTY(SE1->E1_NUMBCO)
			_NosNum := NumNosso(SE1->E1_PREFIXO,SubStr(SE1->E1_NUM,4,6),SE1->E1_PARCELA,@nBanco) 
			SE1->(RecLock("SE1",.F.))
				SE1->E1_NUMBCO  := _NosNum         
			SE1->(MSUnLock())		
			SE1->(dbSkip())
		Else
			SE1->(dbSkip())
	    EndIf
			
	EndDo  
EndIf

Return

Static Function NumNosso(cPrefixo,cNumero,cParcela,nBanco)   

Local nNNum		:= 0
Local _nParc	:= 0
Local _nDig		:= 0
Local _nRst     := 0
Local _nMlt     := { 2, 7, 6, 5, 4, 3, 2, 7, 6, 5, 4, 3, 2 }
   
nNNum := '09'
nNNum += StrZero( Val( cPrefixo ), 3 )   // Converter um numérico em uma string com zeros a esquerda.
nNNum += cNumero

If cParcela <> ' '
	_nParc := Asc( cParcela )
 	_nParc -= 64
  	_nParc := StrZero( _nParc, 2 )
   	nNNum  += _nParc
Else
	nNNum += '00' 
EndIf

nBanco := Substr( nNNum,  3, 9 )
nBanco += Substr( nNNum, 13, 1 )
   
_nDig := 0

For n := 1 To 13
	_nRst := Val( Substr( nNNum, n, 1 ) )
 	_nRst *= _nMlt[ n ]
  	_nDig += _nRst
Next

_nRst := Mod( _nDig, 11 )

If _nRst <> 0
	_nDig := 11
	_nDig -= _nRst
	
	If _nDig <> 10
		_nDig := StrZero( _nDig, 1 )
  	Else
   		_nDig := 'P'
   	EndIf
Else
	_nDig := '0'
EndIf

nNNum += _nDig
nNNum := Substr( nNNum, 3 )
   
Return(nNNum)   

Static Function CriaSX1(cPerg)  

PutSx1(cPerg,"01","Prefixo de  ?" ,"","","mv_ch1","C",03,00,00,"C","","SE1","","","mv_par01","","","","","","","","","","","","","","","","","","","","")
PutSx1(cPerg,"02","Numero  de  ?" ,"","","mv_ch2","C",09,00,00,"C","",""   ,"","","mv_par02","","","","","","","","","","","","","","","","","","","","")
PutSx1(cPerg,"03","Parcela de  ?" ,"","","mv_ch3","C",01,00,00,"C","",""   ,"","","mv_par03","","","","","","","","","","","","","","","","","","","","")
PutSx1(cPerg,"04","Tipo    de  ?" ,"","","mv_ch4","C",03,00,00,"C","",""   ,"","","mv_par04","","","","","","","","","","","","","","","","","","","","")
PutSx1(cPerg,"05","Prefixo ate ?" ,"","","mv_ch5","C",03,00,00,"C","","SE1","","","mv_par05","","","","","","","","","","","","","","","","","","","","")
PutSx1(cPerg,"06","Numero  ate ?" ,"","","mv_ch6","C",09,00,00,"C","",""   ,"","","mv_par06","","","","","","","","","","","","","","","","","","","","")
PutSx1(cPerg,"07","Parcela ate ?" ,"","","mv_ch7","C",01,00,00,"C","",""   ,"","","mv_par07","","","","","","","","","","","","","","","","","","","","")
PutSx1(cPerg,"08","Tipo    ate ?" ,"","","mv_ch8","C",03,00,00,"C","",""   ,"","","mv_par08","","","","","","","","","","","","","","","","","","","","")
    
Return
*/