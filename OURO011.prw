#INCLUDE "rwmake.ch"
#INCLUDE "TOPCONN.CH"
#include "protheus.ch"
#INCLUDE "Tbiconn.ch"
#INCLUDE "Tbicode.ch"

User Function OURO011()
    Local cQuery   := ""
    Local cFile    := "" 
    Local nH       := Nil
    Local cMsg     := ""
    Private cPerg  := "OURO011"
    Private cNumSI := space(6)

    cPerg := PADR(cPerg,10)
	ValidP1(cPerg)

    Pergunte(cPerg,.T.)
    
    If !Empty(MV_PAR01)
        cQuery := " SELECT SC1.R_E_C_N_O_ "
        cQuery += " FROM SC1010 SC1 "
        cQuery += " INNER JOIN SW1010 SW1 "
        cQuery += " ON W1_SI_NUM = C1_NUM_SI "
        cQuery += " AND C1_PRODUTO = W1_COD_I "
        cQuery += " AND C1_QUANT = W1_QTDE "
        cQuery += " AND SW1.W1_SI_NUM = '"+MV_PAR01+"' "
        cQuery += " AND SW1.D_E_L_E_T_ = '' "
        cQuery += " WHERE  SC1.D_E_L_E_T_ = '' "
        cQuery += " AND C1_FILIAL IN ('01','06') "
        cQuery += " AND C1_IMPORT = 'S' "
        cQuery += " AND W1_PRECO = 0 "
        cQuery += " AND C1_QUANT > 0 "
        cQuery += " AND W1_PO_NUM = '' "
        cQuery += " ORDER BY C1_FILIAL, C1_NUM "

        If Select("EXCQ") > 0
            EXCQ->(DbCloseArea())
        EndIf

        cQuery := ChangeQuery(cQuery)

        dbUseArea(.T.,"TOPCONN",TCGenqry(,,cQuery),"EXCQ",.F.,.T.)

        While EXCQ->(!EOF())
            dbSelectArea("SC1")
            SC1->(dbGoTo(EXCQ->R_E_C_N_O_))
            If SC1->C1_NUM_SI == MV_PAR01
                If Reclock("SC1",.F.)
                    SC1->C1_COTACAO = " "
                    SC1->C1_IMPORT  = " "
                    SC1->C1_NUM_SI  = " "
                    SC1->C1_QUJE    = 0
                    SC1->(MsUnlock())
                    cMsg += "Filial: " +SC1->C1_FILIAL + " Solicitacao: " + SC1->C1_NUM + " Produto: " + SC1->C1_PRODUTO +" Desvinculado. "+ chr(13)+chr(10)
                EndIf
            EndIF
            EXCQ->(dbSkip())
        EndDo

        cQuery := " SELECT SC7.R_E_C_N_O_ "
        cQuery += " FROM( "
        cQuery += " SELECT  C1_FILIAL FILIAL, C1_NUM SOLICIT, C1_PEDIDO PEDIDO, C1_EMISSAO, C1_ITEM ITEM , C1_PRODUTO PROD,  C1_QUANT, C1_QUJE,  W1_PO_NUM PO, W1_SI_NUM SI "
        cQuery += " FROM SC1010 SC1 "
        cQuery += " LEFT OUTER JOIN SW1010 SW1 "
        cQuery += " ON W1_PO_NUM = C1_PEDIDO "
        cQuery += " AND C1_EMISSAO = W1_DTENTR_ "
        cQuery += " AND W1_COD_I = C1_PRODUTO "
        cQuery += " AND C1_QUANT = W1_QTDE "
        cQuery += " AND SW1.W1_SI_NUM = '"+MV_PAR01+"' "
        cQuery += " AND SW1.D_E_L_E_T_ = '' "
        cQuery += " INNER JOIN SC7010 SC7 "
        cQuery += " ON C1_PEDIDO = C7_NUM "
        cQuery += " AND C1_PRODUTO = C7_PRODUTO "
        cQuery += " AND C1_ITEM = C7_ITEM  "
        cQuery += " AND C7_QUANT > 0 "
        cQuery += " WHERE  SC1.D_E_L_E_T_ = '' "
        cQuery += " AND C1_FILIAL IN ('01','06') "
        cQuery += " AND C1_IMPORT = 'S' "
        cQuery += " AND W1_PRECO = 0 "
        cQuery += " AND C1_PEDIDO <> '' "
        cQuery += " AND C1_QUANT > 0 "
        cQuery += " ) "
        cQuery += " PEDIDO "
        cQuery += " INNER JOIN SC7010 SC7 "
        cQuery += " ON C7_FILIAL = FILIAL "
        cQuery += " AND C7_NUM = PEDIDO "
        cQuery += " AND C7_PRODUTO = PROD  "
        cQuery += " AND C7_ITEM = ITEM  "
        cQuery += " ORDER BY C7_NUM, C7_ITEM "

        If Select("EXCQ") > 0
            EXCQ->(DbCloseArea())
        EndIf

        cQuery := ChangeQuery(cQuery)

        dbUseArea(.T.,"TOPCONN",TCGenqry(,,cQuery),"EXCQ",.F.,.T.)

        While EXCQ->(!EOF())
            dbSelectArea("SC7")
            SC7->(dbGoTo(EXCQ->R_E_C_N_O_))
            If SC7->(RECNO()) == EXCQ->R_E_C_N_O_
                If RecLock("SC7",.F.)
                    SC7->C7_ORIGEM := " "
                    SC7->C7_NUMIMP := " "
                    SC7->C7_QUJE    = 0
                    SC7->(MsUnlock())
                    cMsg += "Filial: " +SC7->C7_FILIAL + " Pedido: " + SC7->C7_NUM + " Produto " + SC7->C7_PRODUTO + " Desvinculado. "+ chr(13)+chr(10)
                EndIf
            EndIf
            EXCQ->(dbSkip())
        EndDo
    EndIf

    If !Empty(MV_PAR02)
        cQuery := " SELECT SC1.R_E_C_N_O_ "
        cQuery += " FROM " + RetSqlName("SC1") + " SC1 "
        cQuery += " WHERE SC1.D_E_L_E_T_ = '' "
        cQuery += " AND C1_FILIAL IN ('01','06') "
        cQuery += " AND C1_IMPORT = 'S' "
        cQuery += " AND C1_NUM_SI = '' "
        cQuery += " AND C1_NUM = '"+MV_PAR02+"' "
        cQuery += " AND C1_QUANT > 0 "
        cQuery += " ORDER BY C1_FILIAL, C1_NUM "

        If Select("EXCQ") > 0
            EXCQ->(DbCloseArea())
        EndIf

        cQuery := ChangeQuery(cQuery)

        dbUseArea(.T.,"TOPCONN",TCGenqry(,,cQuery),"EXCQ",.F.,.T.)

        While EXCQ->(!EOF())
            dbSelectArea("SC1")
            SC1->(dbGoTo(EXCQ->R_E_C_N_O_))
            If SC1->C1_NUM == MV_PAR02
                If Reclock("SC1",.F.)
                    SC1->C1_COTACAO = " "
                    SC1->C1_IMPORT  = " "
                    SC1->C1_NUM_SI  = " "
                    SC1->C1_QUJE    = 0
                    SC1->(MsUnlock())
                    cMsg += "Filial: " +SC1->C1_FILIAL + " Solicitacao: " + SC1->C1_NUM + " Produto: " + SC1->C1_PRODUTO +" Desvinculado. "+ chr(13)+chr(10)
                EndIf
            EndIF
            EXCQ->(dbSkip())
        EndDo
    EndIf

    If !Empty(cMsg)
        cFile    := "C:\TEMP\Log_desvinculo_"+DTOS(dDataBase)+"_"+Replace(Time(),":","-")+".txt" 
        nH       := fCreate(cFile)  
        fWrite(nH,cMsg)
        fClose(nH) 
        Msginfo("Processamento finalizado - Arquivo de log criado :" + cFile) 
    else
        Msginfo("Não existem registro aptos a serem desvinculados") 
    Endif
Return



/*
Rotina: ValidP1
Descricao: Parametros da rotina.
Autor: Marcelo - Ethosx 
Data: 29/04/2019
*/

Static Function ValidP1(cPerg)
Local j, i := 0

dbSelectArea("SX1")
dbSetOrder(1)

aRegs:={}              
aAdd(aRegs,{cPerg,"01","Numero SI:","","","mv_ch1" ,"C",6,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","SW0","","","","","","","",""})
aAdd(aRegs,{cPerg,"02","Numero SC:","","","mv_ch2" ,"C",6,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","SC1","","","","","","","",""})

For i:=1 to Len(aRegs)
	If !dbSeek(cPerg + aRegs[i,2])
		RecLock("SX1",.T.)
		For j:=1 to FCount()
			FieldPut(j,aRegs[i,j])
		Next
		MsUnlock()
		dbCommit()
	Endif
Next
                          
Return(.T.)
