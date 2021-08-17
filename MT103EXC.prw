//--------------------------------------------------------------------
/*/{Protheus.doc} MT103EXC
Ponto de entrada para validar a exclusão do documento de saida.
@author Henrique Ghidini
@since 30/04/2020
@version 1.0 
@type function
/*/
//--------------------------------------------------------------------

User Function MT103EXC()

Local lRet  := .T.

    If SF1->F1_ORIGEM == "FTOUA008"
        Help(" ",1, 'Help','MT103EXC',"Documento de entrada originado pela integração com o sistema Transpo Frete não pode ser excluído." , 3, 0 )
        lRet := .F.
    EndIf

Return(lRet)