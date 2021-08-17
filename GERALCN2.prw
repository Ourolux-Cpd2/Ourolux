#INCLUDE "RWMAKE.CH"
#Include "AP5MAIL.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "Tbiconn.ch"
#INCLUDE "Tbicode.ch"

/*/
_____________________________________________________________________________
|  Programa:            | Autor: Rodrigo Dias Nunes  | Data ³  08/05/2020    |
|_______________________|____________________________|_______________________|
|  Descricao | schedule para geração de alçada de aprovaçao de Contas a pagar|
|____________|_______________________________________________________________|
|  Uso       | OUROLUX.                                                      |
|____________|_______________________________________________________________|
/*/
                                  
User Function GERALCN2()   
Local cGrpApr  := ""
Local cLogName := ""
        
conout(" ")
conout("Iniciado processo GERALCN2 " + DtoC(Date()) + " - " + Time())
conout(" ")   

PREPARE ENVIRONMENT EMPRESA "01" FILIAL "01" MODULO "COM"
   
aArea    := GetArea()

cLogName   := "GERALCN2"+STRZERO(DAY(dDATAbASE),2)+STRZERO(MONTH(DDATABASE),2)+STRZERO(YEAR(dDATAbASE),4)+".QRY"

cQuery := " SELECT SE2.E2_NUM, SE2.E2_PREFIXO, SE2.E2_FORNECE, SE2.E2_LOJA, SE2.E2_VALOR, SE2.E2_EMISSAO, SE2.USUARIO ,SE2.R_E_C_N_O_, SY1.Y1_GRUPCOM "
cQuery += " FROM ( SELECT E2_NUM, E2_PREFIXO, E2_FORNECE, E2_LOJA, E2_VALOR, E2_EMISSAO, "
cQuery += "        substring(E2_userlgi, 11, 1) || substring(E2_userlgi, 15, 1) || " 
cQuery += "        substring(E2_userlgi, 2, 1) || substring(E2_userlgi, 6, 1) || "
cQuery += "        substring(E2_userlgi, 10, 1) || substring(E2_userlgi, 14, 1) || " 
cQuery += "        substring(E2_userlgi, 1, 1) || substring(E2_userlgi, 5, 1) || "
cQuery += "        substring(E2_userlgi, 9, 1) || substring(E2_userlgi, 13, 1) || "
cQuery += "        substring(E2_userlgi, 17, 1) || substring(E2_userlgi, 4, 1) || " 
cQuery += "        substring(E2_userlgi, 8, 1) USUARIO ,R_E_C_N_O_ FROM SE2010 "
cQuery += " 		WHERE E2_WFALC <> 'X' "
cQuery += " 		AND D_E_L_E_T_ <> '*') SE2 "
cQuery += " LEFT JOIN SY1010 SY1 "
cQuery += " ON SY1.Y1_USER = SE2.USUARIO "
cQuery += " AND SY1.D_E_L_E_T_ <> '*' " 
cQuery := ChangeQuery(cQuery)

MemoWrite("\INTRJ\" + cLOGNAME,cQuery)

If Select("N2A") > 0
	N2A->(dbCloseArea())
EndIf

TcQuery cQuery New Alias "N2A"

dbSelectArea("SE2")

While N2A->(!EOF())
    
    If Empty(N2A->Y1_GRUPCOM)
        cGrpApr := SuperGetMV("MV_GRPADRA",.F.,"000001")
    Else
        cGrpApr := Alltrim(N2A->Y1_GRUPCOM)
    EndIf

    cQuery := " SELECT AL_COD, AL_APROV, AL_NIVEL FROM " + RetSqlName("SAL")
    cQuery += " WHERE D_E_L_E_T_ <> '*' "
    cQuery += " AND AL_COD = '"+cGrpApr+"' "
    cQuery += " AND AL_NIVEL = '02' "

    MemoWrite("\INTRJ\" + cLOGNAME,cQuery)

    If Select("N2B") > 0
        N2B->(dbCloseArea())
    EndIf

    TcQuery cQuery New Alias "N2B"

    While N2B->(!EOF())
        RecLock("SZX",.T.)
        SZX->ZX_FILIAL  := xFilial("SZX") 
        SZX->ZX_NUMTIT  := N2A->E2_NUM
        SZX->ZX_PREFIXO := N2A->E2_PREFIXO
        SZX->ZX_FORNECE := N2A->E2_FORNECE
        SZX->ZX_LOJA    := N2A->E2_LOJA
        SZX->ZX_VALOR   := N2A->E2_VALOR
        SZX->ZX_EMISSAO := STOD(N2A->E2_EMISSAO)
        SZX->ZX_NIVEL   := N2B->AL_NIVEL
        SZX->ZX_USUARIO := N2B->AL_APROV
        SZX->ZX_GRPAPRO := N2B->AL_COD
        SZX->ZX_RECSE2  := cValToChar(N2A->R_E_C_N_O_)
        SZX->ZX_STATUS  := "P"
        SZX->(MsUnlock())    
        SE2->(dbGoTo(N2A->R_E_C_N_O_))
            RecLock("SE2",.F.)
            SE2->E2_WFALC := "X"
            SE2->(MsUnlock())

        N2B->(dbSkip())
    EndDO
    N2A->(dbSkip())
EndDo

SE2->(dbCloseArea())

RESET ENVIRONMENT
         
conout(" ")
conout("Finalizado processo GERALCN2 " + DtoC(Date()) + " - " + Time())
conout(" ")   

RestArea(aArea)

U_WFN2CP() //Chamada da função para geração do WF

Return()