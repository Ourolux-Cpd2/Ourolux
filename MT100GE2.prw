#include 'protheus.ch'
#include 'parmtype.ch'

//--------------------------------------------------------------------
/*/{Protheus.doc} MT100GE2
Ponto de entrada para manipular data de vencimento do Titulo
@author Rodrigo Nunes
@since 24/05/2021
@version 1.0 
@type function
/*/
//--------------------------------------------------------------------
User Function MT100GE2()
Local nOpc      := PARAMIXB[2]
Local cHawb     := ""
Local lAtvEIC   := SuperGetMV("ES_ATVEICD",.T.,.F.) 
Local dDataVen  

If lAtvEIC

    dbSelectArea("SC7")

    cHawb := Alltrim(GetAdvFVal("SC7","C7_XHAWB",SD1->D1_FILIAL + SD1->D1_PEDIDO,1))

    If !Empty(cHawb)
        If nOpc == 1 //inclusao.
            dbSelectArea("SWD")
            SWD->(DbOrderNickName("DESPESA"))
            cIndice := SWD->(INDEXORD())

            dDataVen := GetAdvFVal("SWD","WD_XVENCTO",xFilial("SWD") + PADR(cHawb,TamSx3("WD_HAWB")[1]) + SubStr(Alltrim(SD1->D1_COD),4,3) + SD1->D1_FILIAL + SD1->D1_PEDIDO ,cIndice)
            If !Empty(dDataVen)
                If dDataVen >= dDataBase 
                    SE2->E2_VENCTO := dDataVen
                    SE2->E2_VENCREA:= dDataVen
                Else
                    SE2->E2_VENCTO := dDataBase
                    SE2->E2_VENCREA:= dDataBase
                EndIf
            Else
                ProcLogAtu("ALERTA","MT100GE2 - Data de Vencimento vazia", "Filial: " +SD1->D1_FILIAL+ " Pedido: " +SD1->D1_PEDIDO , "EICDESPESA" )
            EndIf
            
            SE2->E2_HIST := "PROC."+Alltrim(cHawb)
            
        Endif
    EndIf
EndIf

Return(Nil)
