#INCLUDE "PROTHEUS.CH"
#Include "TOPCONN.CH"

//--------------------------------------------------------------------
/*/{Protheus.doc} OURO009
Calculo da Data Limite de Produção e Data de Entrega
@author Rodrigo Nunes
@since 01/11/2021
/*/
//--------------------------------------------------------------------
User Function OURO009()

    Local dDataLP   := aScan(aHeader,{|x| AllTrim(x[2]) == 'C1_XDTLPRD'})
    Local dDataLC   := aScan(aHeader,{|x| AllTrim(x[2]) == 'C1_XDTPROG'})
    Local cDeptoSC  := SuperGetMv("FS_VLSCIMP",.F.,"")
    Local cCalLimP  := SuperGetMv("ES_DTLPRD",.F.,"")
    Local cCalLimC  := SuperGetMv("ES_DTENTR",.F.,"")
    Local aCalLP    := StrTokArr(cCalLimP,"/")
    Local aCalLC    := StrTokArr(cCalLimC,"/")
    Local nTotLP    := 0
    Local nTotLC    := 0
    Local nlx       := 0

    If _cDepSC1 $ cDeptoSC
        For nlx := 1 to len(aCalLP)
            nTotLP += Val(aCalLP[nlx])
        Next    

        For nlx := 1 to len(aCalLC)
            nTotLC += Val(aCalLC[nlx])
        Next    
            
        aCols[n][dDataLP] := M->C1_DATPRF - nTotLP
        aCols[n][dDataLC] := M->C1_DATPRF - nTotLC
    EndIf

Return .T.

//--------------------------------------------------------------------
/*/{Protheus.doc} OURO09A
Valida se usuario é permitido alteração
@author Rodrigo Nunes
@since 01/11/2021
/*/
//--------------------------------------------------------------------
User Function OURO09A()
    Local cUsrAlt := SuperGetMV("ES_SOPUSR",.F.,"001857/002259/002307")
    Local lRet    := .F.

    If __cUserID $ cUsrAlt
        lRet := .T.
    EndIf

Return lRet

//--------------------------------------------------------------------
/*/{Protheus.doc} OURO09A
Valida se usuario é permitido alteração
@author Rodrigo Nunes
@since 01/11/2021
/*/
//--------------------------------------------------------------------
User Function OURO09B()
    Local cUsrAlt := SuperGetMV("ES_SOPUSR",.F.,"001857/002259/002307")
    Local cCalcs  := SuperGetMv("ES_DTENTR",.F.,"")
    Local aCalcs  := StrTokArr(cCalcs,"/")
    Local cMsgCal := ""
    
    If __cUserID $ cUsrAlt
        
        If Len(aCalcs) == 7
            cMsgCal := "TEMPO EM DIAS DAS FASES DO PROCESSO" + CRLF + CRLF
            cMsgCal += " - Aprovacao Nivel 2.......= " + aCalcs[1] + CRLF
            cMsgCal += " - Pagamento Sinal..........= " + aCalcs[2] + CRLF
            cMsgCal += " - Fase de Producao.......= " + aCalcs[3] + CRLF
            cMsgCal += " - Fase de PSI.................= " + aCalcs[4] + CRLF
            cMsgCal += " - Fase de Embarque......= " + aCalcs[5] + CRLF
            cMsgCal += " - Fase de Transito.........= " + aCalcs[6] + CRLF
            cMsgCal += " - Fase Porto/CD.............= " + aCalcs[7] + CRLF + CRLF
            cMsgCal += "PARA QUALQUER ALTERAÇÃO NOS VALORES APRESENTADOS, " + CRLF
            cMsgCal += "SOLICITAR AO TIME DE TI A MANUTENÇÃO NOS PARAMERTOS: " +CRLF
            cMsgCal += " - ES_DTLPRD - Calculo Limite Producao" + CRLF 
            cMsgCal += " - ES_DTENTR - Calculo para Data de Entrega" + CRLF

            Aviso("FASES DO PROCESSO",cMsgCal,{"&OK"},3)
        else
            Alert("Favor verificar com o TI o parametro ES_DTENTR esta apresentando " + CValToChar(Len(aCalcs) + " valores para calculo, corretão são 7" ))
        EndIf        
    EndIf

Return 
