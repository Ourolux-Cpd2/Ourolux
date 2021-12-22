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
            Permite Avaliar se a gravação dos títulos a pagar deve prosseguir */
            If PARAMIXB[8] == "PRE" .AND. ("-FRETE" $ PARAMIXB[13])
                lAborta:= .T.
            EndIf

        Case cParam == "GRAVA_SE2_1"
            /*
            Permite complementar dados na gravação da tabela SE2, na inclusão de títulos povisórios e de despesas*/
            //MsgInfo("Ponto de entrada EICDUPL, GRAVA_SE2_1", "GRAVA_SE2_1")

        Case cParam == "GRAVA_SE2_2"
            /*
            Permite complementar dados na gravação da tabela SE2, na alteração de títulos povisórios e de despesas*/
            //MsgInfo("Ponto de entrada EICDUPL, GRAVA_SE2_2", "GRAVA_SE2_2")
    EndCase

Return
