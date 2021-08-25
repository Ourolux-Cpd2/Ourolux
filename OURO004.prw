#INCLUDE "PROTHEUS.CH"
//--------------------------------------------------------------------
/*/{Protheus.doc} OURO004
Rotina para cadastro de containers
@author Rodrigo Nunes
@since 19/08/2021
/*/
//--------------------------------------------------------------------
User Function OURO004()
 
    Private cCadastro	:= "Cadastro de containers"
    Private aParam      := {}
    Private aParAlt      := {}
    Private aAltCTN     := {"ZAC_CTN","ZAC_MTC","ZAC_KG","ZAC_ATIVO"}
    Private aCTN        := {"ZAC_MTC","ZAC_KG","ZAC_ATIVO"}
    Private aRotina		:= {}
    
    aAdd( aParam, {|| VAZIO()})	//antes da abertura
    aAdd( aParam, {|| U_VlOu04I()}) //ao clicar no botao ok
    aAdd( aParam, {|| VAZIO()})	//durante a transacao
    aAdd( aParam, {|| VAZIO()}) //termino da transacao

    aAdd( aParAlt, {|| VAZIO()})	//antes da abertura
    aAdd( aParAlt, {|| U_VlOu04A()}) //ao clicar no botao ok
    aAdd( aParAlt, {|| VAZIO()})	//durante a transacao
    aAdd( aParAlt, {|| VAZIO()}) //termino da transacao


    aRotina	:= {{"Pesquisar","AxPesqui",0,1}	,;
                {"Visualizar","AxVisual",0,2}	,;
                {"Incluir","AxInclui('ZAC',,3,,,aAltCTN,,,,,aParam)",0,3}	    ,;
                {"Atualiza Valores","U_OURO005()",0,4}	    ,;
                {"Alterar","AxAltera",0,4}}	    //,;
                //{"Excluir","AxDeleta",0,5}}

    dbSelectArea("ZAC")
    dbSetOrder(1)
    mBrowse( 6,1,22,75,"ZAC")

Return Nil

//--------------------------------------------------------------------
/*/{Protheus.doc} VlOu04I
Rotina para validar inclusão de containers
@author Rodrigo Nunes
@since 19/08/2021
/*/
//--------------------------------------------------------------------
User Function VlOu04I()
    Local lret   := .T.
    Local cQuery := ""
    
    cQuery := " SELECT ZAC_CTN FROM " + RetSqlName("ZAC")
    cQuery += " WHERE D_E_L_E_T_ = '' "
    cQuery += " AND ZAC_CTN = '" +M->ZAC_CTN+ "' "

    If Select("CTNX") > 0
        CTNX->(dbCloseArea())
    EndIf

    DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery) , 'CTNX', .T., .F.)

    If CTNX->(!EOF())
        Alert("Container já cadastrado.")
        lRet := .F.
    EndIf
    
    If !(M->ZAC_CTN $ "CTN20DR|CTN20RF|CTN40HC|CTN40DR|CTN40RF")
        Alert("Não é permitido container com o codigo diferente de: " +CRLF+ "-CTN20DR" +CRLF+ "-CTN20RF" +CRLF+ "-CTN40HC" +CRLF+ "-CTN40DR" +CRLF+"-CTN40RF")
        lRet := .F.
    EndIf
    
Return lRet

