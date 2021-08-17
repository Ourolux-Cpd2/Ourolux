#Include "Totvs.Ch"
#Include "topconn.Ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} TFINJ005
Função para ficar no onstart verificando os processo do reserve.

@author By Wise

@since 21/10/2018
/*/
//-------------------------------------------------------------------

User Function TFINJ005()

Local cQuery    := ""
Local cAlsInt   := ""
Local cHoraMax  := ""
Local cDataExec := ""
Local cAlsVerif := ""
Local cAlsVld   := ""
Local cHoraExec := ""
Local nHoraMax  := 0
Local nHora     := 0
Local nQtdExec  := 0
Local nX        := 0
Local nCount    := 0
Local nDifExec  := 0
Local nInterval := 0
Local aExec     := {}
Local cParam    := ""
Local cLogMsg   := ""
Local aParam    := Nil
Local lVerbose  := .F. 
Local lGeraTxt  := .F.
	
	conout(REPLICATE("=",80))
	conout("======> (A) " + dtoc(date()) + " " + time() + " - Rodou U_TFINJ005 - Ambiente: " + GetEnvServer())
	conout(REPLICATE("=",80))
	
    RpcSetEnv("01","01")
    RpcSetType(3)

    cHoraMax    := Substr(Time(),1,5)
    nHoraMax    := U_Hor2HrDec(cHoraMax)
    cDataExec   := DTOS(dDataBase)
    cAlsInt     := CriaTrab(Nil,.F.)
    cAlsVerif   := CriaTrab(Nil,.F.)
    cAlsVld     := CriaTrab(Nil,.F.)
    lVerbose    := GetMv("TI_FNJ5LOG",,.F.)
    lGeraTxt    := GetMv("TI_FNJ5TXT",,.F.)

    If lGeraTxt
        U_FNJ05SETLOG()
    EndIf

    //Busca serviços ativos
    cQuery := " SELECT " + CRLF
    cQuery += "     PZA_ID, " + CRLF
    cQuery += "     PZA_PROG, " + CRLF
    cQuery += "     PZA_HORA, " + CRLF
    cQuery += "     PZA_QUANT, " + CRLF
    cQuery += "     PZA_INTERV, " + CRLF
    cQuery += "     PZA_PERIOD " + CRLF
    cQuery += " FROM " + CRLF
    cQuery += "     " + RetSqlName("PZA") + " PZA " + CRLF
    cQuery += " WHERE " + CRLF
    cQuery += "     PZA_FILIAL = '" + xFilial("PZA") + "' " + CRLF
    cQuery += "     AND PZA_STATUS = 'A' " + CRLF
    cQuery += "     AND PZA_PERIOD <> ' ' " + CRLF
    cQuery += "     AND PZA.D_E_L_E_T_ = ' ' " + CRLF
    //cQuery += " 	ORDER BY PZA_ORDEM" + CRLF
    cQuery += " ORDER BY PZA_ID" + CRLF
    //CONOUT(cQuery)
    If Select(cAlsInt) > 0
        (cAlsInt)->(dbCloseArea())
    Endif
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlsInt,.T.,.T.)

    While !(cAlsInt)->(Eof())

        If U_Hor2HrDec((cAlsInt)->PZA_HORA) > nHoraMax
            (cAlsInt)->(DbSkip())
            Loop
        EndIf

        cProgram := Alltrim( (cAlsInt)->PZA_PROG )

        //Se for uma execução por dia e for execução diaria.
        If (cAlsInt)->PZA_PERIOD == "1"

            //Só traz na query se a quantidade de execuções for menor que a quantidade total
            cQuery := " SELECT PZA_QUANT, SUBSTRING(MAX(PZB_HORA),1,5) PZB_HORA, PZA_INTERV, COUNT(*) AS QTDEXEC FROM " + RetSqlName("PZA") + " PZA "
            cQuery += " LEFT JOIN " + RetSqlName("PZB") + " PZB " 
            cQuery += " ON PZB_IDURL = PZA_ID AND PZB.D_E_L_E_T_ = ' ' AND PZB_DATA = '" + cDataExec + "'"
            cQuery += " WHERE PZA_ID = '" + (cAlsInt)->PZA_ID + "' AND PZA.D_E_L_E_T_ = ' ' "
            cQuery += " GROUP BY PZA_QUANT, PZA_INTERV "
            // cQuery += " HAVING COUNT(*) < PZA_QUANT "

            If Select(cAlsVerif) > 0
                (cAlsVerif)->(dbCloseArea())
            Endif

	        dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlsVerif,.T.,.T.)

            cLogMsg := CRLF+"==============================="
            cLogMsg += CRLF+"Id............: " + (cAlsInt)->PZA_ID
            cLogMsg += CRLF+"Hora início...: " + (cAlsInt)->PZA_HORA
            cLogMsg += CRLF+"Qtd. Execuções: " + Alltrim(Alltochar((cAlsInt)->PZA_QUANT))
            cLogMsg += CRLF+"Intervalo.....: " + (cAlsInt)->PZA_INTERV
            cLogMsg += CRLF+"-------------------------------"

            //Se ja tiver execução no dia pula o serviço, caso contrario chama a execução.
            If !(cAlsVerif)->(Eof())

                nDifExec  := nHoraMax - U_Hor2HrDec(Alltrim((cAlsVerif)->PZB_HORA))
                nInterval := U_Hor2HrDec(Alltrim((cAlsVerif)->PZA_INTERV))

                cLogMsg += CRLF+"Hora Exec. Schedule..: " + cHoraMax 
                cLogMsg += CRLF+"Hora Última Exec.....: " + (cAlsVerif)->PZB_HORA
                cLogMsg += CRLF+"Qtd. já Executada....: " + Alltrim(Alltochar((cAlsVerif)->QTDEXEC))
                cLogMsg += CRLF+"Tempo da última Exec.: " + U_HrDec2Hor(nDifExec)
                cLogMsg += CRLF+"-------------------------------"

                //Se PZB_HORA estiver em branco, o job ainda não foi executado no dia corrente
                If ( (cAlsVerif)->QTDEXEC < (cAlsVerif)->PZA_QUANT ) .Or. Empty( (cAlsVerif)->PZB_HORA )

                    //Só pode executar se a diferença entre a hora atual - ultima execução da PZB for maior que o intervalo calculado
                    If ( nDifExec > nInterval ) .Or. Empty( (cAlsVerif)->PZB_HORA )

                        cLockName := "PZA-" + (cAlsInt)->PZA_ID + "_EMP-" + cEmpAnt

                        If LockByName(cLockName,.T.)

                            cProgram := Alltrim( (cAlsInt)->PZA_PROG )

                            cLogMsg += CRLF+"Iniciando Job: " + (cAlsInt)->PZA_ID
                            cLogMsg += CRLF+"Função.......: " + cProgram 
                            cLogMsg += CRLF+"==============================="+CRLF

                            // aParam := Nil

                            // If "(" $ cProgram
                            //     cParam := SubStr(cProgram, At("(", cProgram)+1)
                            //     cParam := SubStr(cParam, 1, At(")", cParam)-1)
                            //     // Obtem os parâmetros
                            //     If !Empty(cParam)
                            //         aParam := Strtokarr2( cParam, ",", .T.)
                            //         // Obtem os valores absolutos dos parâmetros para enviar ao StarJob
                            //         aEval(aParam, {|e, nX| aParam[nX] := &(e)})
                            //     EndIf
                    
                            //     cProgram := SubStr(cProgram, 1, At("(", cProgram)-1)
                            // EndIf
                            
                            // StartJob(cProgram, GetEnvServer(), .F., .F., , , , , aParam)

                            StartJob("u_FN5JobHelper", GetEnvServer(), .F., cLockName, cProgram)

                        Else
                            cLogMsg += CRLF+"Job não iniciado: " + (cAlsInt)->PZA_ID
                            cLogMsg += CRLF+"Lock ativo......: " + cLockName
                            cLogMsg += CRLF+"==============================="+CRLF
                        EndIf
                    Else
                        cLogMsg += CRLF+"Job não iniciado: " + (cAlsInt)->PZA_ID
                        cLogMsg += CRLF+"Fora do intervalo de execução"
                        cLogMsg += CRLF+"==============================="+CRLF
                    EndIf
                Else

                    cLogMsg += CRLF+"Job não iniciado: " + (cAlsInt)->PZA_ID
                    cLogMsg += CRLF+"Quantidade de execução excedida"
                    cLogMsg += CRLF+"==============================="+CRLF

                EndIf

            EndIf

            If lGeraTxt
                U_FNJ05Log(cLogMsg)
            EndIf

            If lVerbose
                Conout(cLogMsg)
            EndIf

            (cAlsVerif)->(dbCloseArea())

        EndIf

        (cAlsInt)->(DbSkip())
    
    End

    (cAlsInt)->(dbCloseArea())

Return()

//-------------------------------------------------------------------
/*/{Protheus.doc} FN5JobHelper
Função para monitorar o lock do job.

@author By Wise

@since 14/05/2019
/*/
//-------------------------------------------------------------------
User Function FN5JobHelper(cLockName, cProgram)

Local aParam
Local cTimeIni := Time()
Local cTimeEnd := ""

Default cLockName := ""
Default cProgram  := ""

RpcSetEnv("01","01")
RpcSetType(3)

Conout("FN5JobHelper - " + cTimeIni + ". cLockName: " + cLockName + " cProgram: " + cProgram)

If !Empty(cLockName) .And. !Empty(cProgram)

    If "(" $ cProgram
        cParam := SubStr(cProgram, At("(", cProgram)+1)
        cParam := SubStr(cParam, 1, At(")", cParam)-1)
        // Obtem os parâmetros
        If !Empty(cParam)
            aParam := Strtokarr2( cParam, ",", .T.)
            // Obtem os valores absolutos dos parâmetros para enviar ao StarJob
            aEval(aParam, {|e, nX| aParam[nX] := &(e)})
        EndIf

        cProgram := SubStr(cProgram, 1, At("(", cProgram)-1)
    EndIf

    StartJob(cProgram, GetEnvServer(), .T.,.F.,.F.,"","","01","01")

    UnlockByName(cLockName)
    
EndIf

cTimeEnd := Time()
Conout( "FN5JobHelper - " + cTimeEnd + ". cLockName: " + cLockName + " ElapTime: " + ElapTime(cTimeIni, cTimeEnd ) )

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} ResCalInt
Função para calcular intervalo de execuções.

@author By Wise

@since 21/10/2018
/*/
//-------------------------------------------------------------------

User Function CalcInt()

Local cInterval     := ""
Local nHrsRest      := 0
Local nInterval     := 0
// Local lQtdMaior     := .F.

    If !Empty(M->PZA_HORA) .And. !Empty(M->PZA_QUANT)

        nHrsRest := U_Hor2HrDec("24:00") - U_Hor2HrDec(M->PZA_HORA) //SubHoras("24:00", M->PZA_HORA)

        nInterval := nHrsRest / M->PZA_QUANT

        cInterval := U_HrDec2Hor(nInterval)

        //Se quantidade de execução maior que quantidade de horas transforma horas em minutos
        // If M->PZA_QUANT > nQtdHrs
        //     lQtdMaior   := .T.
        //     nQtdHrs     := nQtdHrs * 60
        // EndIf

        // If lQtdMaior
        //     cIntervalo := StrTran( cValToChar( Round( M->PZA_QUANT / nQtdHrs,2 ) ), ".", ":" )
        // Else
        //     cIntervalo := StrTran( cValToChar( Round( nQtdHrs / M->PZA_QUANT,2 ) ), ".", ":" )
        // EndIf

        //Trata a formatação da string
        // If Rat(":", cIntervalo) == 0
        //     cIntervalo := StrZero( Val(cIntervalo), 2 ) + ":00"
        // Else
        //     cHora       := StrZero(Val( Substr(cIntervalo, 1, Rat(":", cIntervalo) ) ),2)
        //     cMinutos    := StrZero(Val( Substr(cIntervalo, Rat(":", cIntervalo) + 1, 2 ) ),2)
        //     cIntervalo  := cHora + ":" + cMinutos
        // EndIf

    EndIf
Return(cInterval)

//-------------------------------------------------------------------
/*/{Protheus.doc} Hor2HrDec
Converte hora comum para hora decimal
@author  By Wise
@since   11/04/2019
@version V12
/*/
//-------------------------------------------------------------------
User Function Hor2HrDec( cHoraMin, cUnConv )

Local nHrCent := 0.00

Default cHoraMin := "00:00"
Default cUnConv  := "H" //"H - Horas; M - Minutos"

cHoraMin := Alltrim(cHoraMin)

if cUnConv == "H"

	nHrCent := Round(Val(Left(cHoraMin,2)) + (Val(Right(cHoraMin,2))/60),2)
	
else
     
	nHrCent := Val(cHoraMin)/60

endif

Return nHrCent


//-------------------------------------------------------------------
/*/{Protheus.doc} HrDec2Hor
Converte hora decimal para hora comum
@author  By Wise
@since   11/04/2019
@version V12
/*/
//-------------------------------------------------------------------
User Function HrDec2Hor( nHrCent, lSepara, cUnConv )
Local cHoraMin   := ""

Default nHrCent  := 0
Default lSepara  := .T.
Default cUnConv  := "H" //"H - Horas; M - Minutos"

nHrCent := Round(nHrCent,2)

If cUnConv == "H"

	cHoraMin := StrZero( Int( nHrCent ), 2 , 0 ) + IIf( lSepara, ":" , "" ) + ;
					StrZero( ((nHrCent - Int( nHrCent) ) * 0.6) * 100 , 2 , 0 )

Else

	cHoraMin := StrZero( nHrCent * 60 , 4 , 0 )

Endif

Return cHoraMin

//-----------------------------------------------------
/*/{Protheus.doc} FNJ05Log
//Grava o arquivo de log
/*/
//-----------------------------------------------------
Static cFNJ051Log := ""

User Function FNJ05Log(cMensagem)
Local cMsgAux := ""
Local nLine   := 0

Default cMensagem := ""

If !Empty(cFNJ051Log)
	nLine   := ProcLine(1)
	cMsgAux := "[" + Upper(GetEnvServer()) + " " + ProcName(1) + "(" + Alltrim(AllToChar(nLine)) + ") " + DtoC(Date()) + "-" + Time() + "] "
	cMsgAux := cMsgAux + Alltrim(cMensagem)
	u_xAcaLog(cFNJ051Log,cMsgAux)
EndIf

Return 

//-----------------------------------------------------
/*/{Protheus.doc} FNJ05SETLOG
//Seta o nome do arquivo de log
/*/
//-----------------------------------------------------
User Function FNJ05SETLOG(cLogNome) 

Default cLogNome := ""

If Empty(cFNJ051Log)
	Makedir("\logreserve\")
	if !empty(cLogNome)
		cFNJ051Log := "\logreserve\" + cLogNome+"_" + DtoS(Date()) + "_" + StrTran(Time(),":","-") + ".log"
	Else
		cFNJ051Log := "\logreserve\" + "tfinj005_" + DtoS(Date()) + "_" + StrTran(Time(),":","-") + ".log"
	
	Endif	
EndIf
	
Return Nil 	