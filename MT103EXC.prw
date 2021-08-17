//--------------------------------------------------------------------
/*/{Protheus.doc} MT103EXC
Ponto de entrada para validar a exclus�o do documento de saida.
@author Henrique Ghidini
@since 30/04/2020
@version 1.0 
@type function
/*/
//--------------------------------------------------------------------

User Function MT103EXC()

Local lRet  := .T.

    If SF1->F1_ORIGEM == "FTOUA008"
        Help(" ",1, 'Help','MT103EXC',"Documento de entrada originado pela integra��o com o sistema Transpo Frete n�o pode ser exclu�do." , 3, 0 )
        lRet := .F.
    EndIf

Return(lRet)