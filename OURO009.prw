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

