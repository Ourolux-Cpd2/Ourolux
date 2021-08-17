#include "Protheus.ch"
/*/
_____________________________________________________________________________
|  Programa:            | Autor: Rodrigo Dias Nunes  | Data ³  22/05/2020    |
|_______________________|____________________________|_______________________|
|  Descricao | Rotina para alteração de contatos do fornecedor               |
|____________|_______________________________________________________________|
|  Uso       | OUROLUX..                                                     |
|____________|_______________________________________________________________|
/*/

User Function ALTCTO(cCodCTO,cCampo,cInfNova)
Local aArea := GetArea()

DBSelectArea("SU5")
SU5->(dbSetOrder(1))

If SU5->(dbSeek(xFilial("SU5") + cCodCTO))
    If cCampo == "AC8_CONTAT"
        If Alltrim(SU5->U5_CONTAT) <> cInfNova
            RecLock("SU5",.F.)
            SU5->U5_CONTAT := cInfNova
            SU5->(MsUnlock())
        EndIf
    ElseIf cCampo == "AC8_FONE"
        If Alltrim(SU5->U5_FONE) <> cInfNova
            RecLock("SU5",.F.)
            SU5->U5_FONE := cInfNova
            SU5->(MsUnlock())
        EndIf
    ElseIf cCampo == "AC8_FCOM1"
        If Alltrim(SU5->U5_FCOM1) <> cInfNova
            RecLock("SU5",.F.)
            SU5->U5_FCOM1 := cInfNova
            SU5->(MsUnlock())
        EndIf
    ElseIf cCampo == "AC8_DDD"
        If Alltrim(SU5->U5_DDD) <> cInfNova
            RecLock("SU5",.F.)
            SU5->U5_DDD := cInfNova
            SU5->(MsUnlock())
        EndIf
    ElseIf cCampo == "AC8_EMAIL"
        If Alltrim(SU5->U5_EMAIL) <> cInfNova
            RecLock("SU5",.F.)
            SU5->U5_EMAIL := cInfNova
            SU5->(MsUnlock())
        EndIf
    ElseIf cCampo == "AC8_CEL"
        If Alltrim(SU5->U5_CELULAR) <> cInfNova
            RecLock("SU5",.F.)
            SU5->U5_CELULAR := cInfNova
            SU5->(MsUnlock())
        EndIf
    ElseIf cCampo == "AC8_FAX"
        If Alltrim(SU5->U5_FAX) <> cInfNova
            RecLock("SU5",.F.)
            SU5->U5_FAX := cInfNova
            SU5->(MsUnlock())
        EndIf
    ElseIf cCampo == "AC8_FCOM2"
        If Alltrim(SU5->U5_FCOM2) <> cInfNova
            RecLock("SU5",.F.)
            SU5->U5_FCOM2 := cInfNova
            SU5->(MsUnlock())
        EndIf
    EndIf
EndIf

RestArea(aArea)

Return .T.  