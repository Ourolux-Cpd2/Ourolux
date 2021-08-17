#INCLUDE "RWMAKE.CH"
#include "TbiConn.ch"
#include "TbiCode.ch"
#INCLUDE "AP5MAIL.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FONT.CH"
#include "topconn.ch"


User Function SB5EE5()
    Local cFile  := "C:\TEMP\LogAtualizacao_"+DTOS(dDataBase)+"_"+Replace(Time(),":","-")+".txt" 
    Local nH     := fCreate(cFile) 
    Local cQuery := ""

    If nH == -1 
	   MsgStop("Falha ao criar arquivo - erro "+str(ferror())) 
	   Return 
	Endif 

    dbSelectArea("SB5")

    cQuery := " SELECT B5_COD, B5_EMB1, R_E_C_N_O_ FROM " + RetSqlName("SB5")
    cQuery += " WHERE D_E_L_E_T_ = '' "
    cQuery += " AND B5_EMB1 <> '' "

    If Select("B5X") > 0 
        B5X->(dbCloseArea())
    EndIf
    
    DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery) , 'B5X', .T., .F.)

    While B5X->(!EOF())
        cQuery := " SELECT EE5_CODEMB FROM " + RetSqlName("EE5")
        cQuery += " WHERE D_E_L_E_T_ = '' "
        cQuery += " AND EE5_CODEMB LIKE '"+Alltrim(B5X->B5_COD)+"%' "
        cQuery += " AND EE5_DESC LIKE '%"+Alltrim(B5X->B5_COD)+"' "

        If Select("E5X") > 0 
            E5X->(dbCloseArea())
        EndIf
        
        DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery) , 'E5X', .T., .F.)

        If E5X->(!EOF())
            If Alltrim(B5X->B5_EMB1) <> Alltrim(E5X->EE5_CODEMB)
                SB5->(dbGoTo(B5X->R_E_C_N_O_))
                RecLock("SB5",.F.)
                SB5->B5_EMB1 := E5X->EE5_CODEMB
                SB5->(MsUnLock())

                fWrite(nH,"Produto: " + Alltrim(B5X->B5_COD) + " Embalagem alterada de (" +Alltrim(B5X->B5_EMB1)+") para (" + Alltrim(SB5->B5_EMB1) +")" + chr(13)+chr(10) ) 
            EndIf
        EndIf
        
        B5X->(dbSkip())
    EndDo

    fClose(nH) 
	
	Msginfo("Processamento finalizado - Arquivo de log criado :" + cFile) 
Return
