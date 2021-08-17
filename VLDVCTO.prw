#include 'protheus.ch'
#include 'parmtype.ch'

//--------------------------------------------------------------------
/*/{Protheus.doc} VldVcto
Rotina para validar data de vencimento preenchida na despesa
@author Rodrigo Nunes
@since 02/06/2021
@version 1.0 
@type function
/*/
//--------------------------------------------------------------------
User Function VldVcto(dVencto)
    Local lRet := .T.
    
    If dVencto < dDataBase
        Alert("N�o � permitido vencimento inferior a data atual")
        lRet := .F.
    ElseIf dVencto == dDataBase
        MsgInfo("A T E N � � O" +CRLF+CRLF+ "Vencimento esta com a data atual, pedido precisa ser aprovado e classificado hoje para n�o ocorrer divergencias financeiras")
        lRet := .T.
    EndIf

Return lRet
