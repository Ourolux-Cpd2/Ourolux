#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "RWMAKE.CH"

#DEFINE POS_SKU         1

#DEFINE POS_COBERTURA   1
#DEFINE POS_PRODUTO_DE  2
#DEFINE POS_PRODUTO_ATE 3
#DEFINE POS_FAMILIA_DE  4
#DEFINE POS_FAMILIA_ATE 5
#DEFINE POS_FILIAL_DE   6
#DEFINE POS_FILIAL_ATE  7

#DEFINE POS_EX_COD      1
#DEFINE POS_EX_DES      2
#DEFINE POS_EX_UM       3
#DEFINE POS_EX_PAS1     4 
#DEFINE POS_EX_PAS2     5 
#DEFINE POS_EX_PAS3     6
#DEFINE POS_EX_MED      7
#DEFINE POS_EX_FOR1     8
#DEFINE POS_EX_FOR2     9
#DEFINE POS_EX_FOR3     10
#DEFINE POS_EX_SALDO    11
#DEFINE POS_EX_PREV     12
#DEFINE POS_EX_PEDCOM   13
#DEFINE POS_EX_ESTFIM   14
#DEFINE POS_EX_COB      15


//--------------------------------------------------------------------
/*/{Protheus.doc} OURO008
Rotina para subida do arquivo Forecast
@author Rodrigo Nunes
@since 31/08/2021
/*/
//--------------------------------------------------------------------
User Function OURO008()
    Local aArrSay  := {}    
    Local aArrBut  := {}
    Local nOpc     := 0
    Local cArquivo := ""
    Local cQuery   := ""    
    Private aArquivo := {}
    Private aParam   := {}
    Private cCaminho := ""
    
    AADD(aArrSay, 'INCLUIR:')
    AADD(aArrSay, '     Importação de arquivo de dados no formato CSV delimitado por ";".')
    AADD(aArrSay, '     Layout: Codigo do Produto; Mes1; Mes2; MesN...')
    AADD(aArrSay, 'OK:')
    AADD(aArrSay, '     Impressão de relatório de OverStock')
    
    AADD(aArrBut, {1, .T., {|| nOpc := 1, FechaBatch()}}) //OK
    AADD(aArrBut, {2, .T., {|| nOpc := 2, FechaBatch()}}) //CANCELAR
    AADD(aArrBut, {4, .T., {|| nOpc := 4, FechaBatch()}}) //INCLUIR
    
    FormBatch('Overstock - Forecast', aArrSay, aArrBut)
    
    If nOpc == 4
        If cFilAnt <> "01"
            Alert("Rotina liberada apenas para filial 01-Guarulhos")
            Return
        EndIF
        
        cArquivo := cGetFile('*.csv|*.csv')

        If Empty(cArquivo)
            Alert("Arquivo não selecionado!")
        else
            aArquivo := Separa( cArquivo,"\",.T.)

            cQuery := " SELECT TOP(1) C4_XNOMEA FROM " + RetSqlName("SC4")
            cQuery += " WHERE C4_FILIAL = '"+xFilial("SC4")+"' "
            cQuery += " AND C4_XNOMEA = '"+UPPER(Alltrim(aArquivo[len(aArquivo)]))+"' "
            cQuery += " AND D_E_L_E_T_ = '' "
            
            If Select("C4ARQ") > 0
                C4ARQ->(DbCloseArea())
            EndIf

            dbUseArea(.T.,"TOPCONN",TCGenqry(,,cQuery),"C4ARQ",.F.,.T.)

            If C4ARQ->(!EOF())
                Alert("Arquivo " + Alltrim(aArquivo[len(aArquivo)]) + " já importado")
            Else
                Processa({|| OURO08A(cArquivo)})
            EndIf
        EndIf
    ElseIf nOpc == 1
        Processa({|| U_OUROR031()})
    EndIf

Return(Nil)

//--------------------------------------------------------------------
/*/{Protheus.doc} OURO08A
Inclusão dos itens na tabela SC4
@author Rodrigo Nunes
@since 20/08/2021
/*/
//--------------------------------------------------------------------
Static Function OURO08A(cArquivo)
    Local aLinha        := {}
    Local aConteudo     := {}
    Local aCabeca       := {}
    Local nLinha        := 0
    Local i, x, y, nx   := 0
    Local cQuery        := ""
    Private lMsErroAuto	:= .F.

    DbSelectArea("SC4")

    FT_FUse(cArquivo)
    ProcRegua(FT_FLastRec())
    FT_FGoTop()

    While !FT_FEof()
        IncProc("Lendo arquivo de forecast...")
        nLinha++
        aLinha    := {}
        
        aLinha:=Separa( FT_FReadLn(),";",.T.)
        
        If nLinha == 1
            AAdd(aCabeca,AClone(aLinha))
        Else
            AAdd(aConteudo,AClone(aLinha))
        EndIf
        
        FT_FSkip()
    Enddo

    For y := 1 to Len(aCabeca[1])
        If UPPER(SubStr(aCabeca[1][y],1,3)) == "JAN"
            aCabeca[1][y] := "01/01/"+SubStr(aCabeca[1][y],5,2)
        ElseIf UPPER(SubStr(aCabeca[1][y],1,3)) == "FEV"
            aCabeca[1][y] := "01/02/"+SubStr(aCabeca[1][y],5,2)
        ElseIf UPPER(SubStr(aCabeca[1][y],1,3)) == "MAR"
            aCabeca[1][y] := "01/03/"+SubStr(aCabeca[1][y],5,2)
        ElseIf UPPER(SubStr(aCabeca[1][y],1,3)) == "ABR"
            aCabeca[1][y] := "01/04/"+SubStr(aCabeca[1][y],5,2)
        ElseIf UPPER(SubStr(aCabeca[1][y],1,3)) == "MAI"
            aCabeca[1][y] := "01/05/"+SubStr(aCabeca[1][y],5,2)
        ElseIf UPPER(SubStr(aCabeca[1][y],1,3)) == "JUN"
            aCabeca[1][y] := "01/06/"+SubStr(aCabeca[1][y],5,2)
        ElseIf UPPER(SubStr(aCabeca[1][y],1,3)) == "JUL"
            aCabeca[1][y] := "01/07/"+SubStr(aCabeca[1][y],5,2)
        ElseIf UPPER(SubStr(aCabeca[1][y],1,3)) == "AGO"
            aCabeca[1][y] := "01/08/"+SubStr(aCabeca[1][y],5,2)
        ElseIf UPPER(SubStr(aCabeca[1][y],1,3)) == "SET"
            aCabeca[1][y] := "01/09/"+SubStr(aCabeca[1][y],5,2)
        ElseIf UPPER(SubStr(aCabeca[1][y],1,3)) == "OUT"
            aCabeca[1][y] := "01/10/"+SubStr(aCabeca[1][y],5,2)
        ElseIf UPPER(SubStr(aCabeca[1][y],1,3)) == "NOV"
            aCabeca[1][y] := "01/11/"+SubStr(aCabeca[1][y],5,2)
        ElseIf UPPER(SubStr(aCabeca[1][y],1,3)) == "DEZ"
            aCabeca[1][y] := "01/12/"+SubStr(aCabeca[1][y],5,2)
        EndIf

    Next

    ProcRegua(Len(aConteudo))

    For i := 1 To Len(aConteudo)
        IncProc("Inserindo dados no Sistema...")
        If !Empty(aConteudo[i][POS_SKU])
            For x := 2 to Len(aCabeca[1])
                cQuery := " SELECT TOP(1) C4_PRODUTO, C4_LOCAL, C4_QUANT, C4_DATA, C4_XNOMEA, C4_REVISAO, R_E_C_N_O_ FROM " + RetSqlName("SC4")
                cQuery += " WHERE C4_PRODUTO = '"+aConteudo[i][POS_SKU]+"' "
                cQuery += " AND C4_FILIAL = '"+xFilial("SC4")+"' "
                cQuery += " AND C4_DATA BETWEEN '"+DTOS(FirstDate(CTOD(aCabeca[1][x])))+"' AND '"+DTOS(LastDate(CTOD(aCabeca[1][x])))+"' "
                cQuery += " AND D_E_L_E_T_ = '' "
                cQuery += " ORDER BY C4_REVISAO DESC"

                If Select("C4X") > 0
                    C4X->(DbCloseArea())
                EndIf

                dbUseArea(.T.,"TOPCONN",TCGenqry(,,cQuery),"C4X",.F.,.T.)

                If C4X->(!EOF())
                    aDados := {}
                    aadd(aDados,{"C4_PRODUTO",aConteudo[i][POS_SKU],Nil})
                    aadd(aDados,{"C4_LOCAL","01",Nil})
                    aadd(aDados,{"C4_QUANT",Val(aConteudo[i][x]),Nil})
                    aadd(aDados,{"C4_DATA",CTOD(aCabeca[1][x]),Nil})
                    aadd(aDados,{"C4_XNOMEA",UPPER(Alltrim(aArquivo[len(aArquivo)])),Nil})
                    aadd(aDados,{"C4_REVISAO",SOMA1(C4X->C4_REVISAO),Nil})

                    MATA700(aDados,3)

                    If !lMsErroAuto
                        ConOut("Inclusao com sucesso! ")
                    Else
                        aErro := GetAutoGRLog()
                        cErro := ""
                        
                        For nX := 1 To Len(aErro)
                            cErro += aErronX + Chr(13)+Chr(10)
                        Next nX
                        
                        If !Empty(cErro)
                            Alert(cErro)
                        EndIf
                    EndIf
                Else
                    aDados := {}
                    aadd(aDados,{"C4_PRODUTO",aConteudo[i][POS_SKU],Nil})
                    aadd(aDados,{"C4_LOCAL","01",Nil})
                    aadd(aDados,{"C4_QUANT",Val(aConteudo[i][x]),Nil})
                    aadd(aDados,{"C4_DATA",CTOD(aCabeca[1][x]),Nil})
                    aadd(aDados,{"C4_XNOMEA",UPPER(Alltrim(aArquivo[len(aArquivo)])),Nil})
                    aadd(aDados,{"C4_REVISAO","001",Nil})

                    MATA700(aDados,3)

                    If !lMsErroAuto
                        ConOut("Inclusao com sucesso! ")
                    Else
                        aErro := GetAutoGRLog()
                        cErro := ""
                        
                        For nX := 1 To Len(aErro)
                            cErro += aErronX + Chr(13)+Chr(10)
                        Next nX
                        
                        If !Empty(cErro)
                            Alert(cErro)
                        EndIf
                    EndIf
                EndIf
            Next
        EndIf
    Next
Return
