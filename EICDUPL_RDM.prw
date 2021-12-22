#Include 'Protheus.ch'

User Function EICDUPL()
    Local cParam

    If ValType(ParamIXB) == "A"
        cParam:= ParamIXB[1]
    Else
        cParam:= ParamIXB
    EndIf

    Do Case
        Case cParam == "GERADUPEIC"
            /*
            Permite Avaliar se a grava��o dos t�tulos a pagar deve prosseguir */
            If PARAMIXB[8] == "PRE" .AND. ("-FRETE" $ PARAMIXB[13])
                lAborta:= .T.
            EndIf

        Case cParam == "GRAVA_SE2_1"
            /*
            Permite complementar dados na grava��o da tabela SE2, na inclus�o de t�tulos povis�rios e de despesas*/
            //MsgInfo("Ponto de entrada EICDUPL, GRAVA_SE2_1", "GRAVA_SE2_1")

        Case cParam == "GRAVA_SE2_2"
            /*
            Permite complementar dados na grava��o da tabela SE2, na altera��o de t�tulos povis�rios e de despesas*/
            //MsgInfo("Ponto de entrada EICDUPL, GRAVA_SE2_2", "GRAVA_SE2_2")
    EndCase

Return
