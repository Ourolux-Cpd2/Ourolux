#INCLUDE "RWMAKE.CH"
#include "TbiConn.ch"
#include "TbiCode.ch"
#INCLUDE "AP5MAIL.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FONT.CH"
#include "topconn.ch"


User Function UPFSFM()
    Local cFile  := "C:\TEMP\LogAtualizacao_SFM_"+DTOS(dDataBase)+"_"+Replace(Time(),":","-")+".txt" 
    Local nH     := fCreate(cFile) 
    Local cQuery := ""

    If nH == -1 
	   MsgStop("Falha ao criar arquivo - erro "+str(ferror())) 
	   Return 
	Endif 

    dbSelectArea("SFM")

    cQuery := " SELECT R_E_C_N_O_ FROM " + RetSqlName("SFM")
    cQuery += " WHERE FM_PRODUTO <> '' "
    cQuery += " AND FM_POSIPI <> '' "
    cQuery += " AND D_E_L_E_T_ = '' "

    If Select("FMX") > 0 
        FMX->(dbCloseArea())
    EndIf
    
    DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery) , 'FMX', .T., .F.)

    While FMX->(!EOF())
        SFM->(dbGoTo(FMX->R_E_C_N_O_))
        If RecLock("SFM",.F.)
            SFM->FM_POSIPI := ""
            SFM->(MsUnLock())
            fWrite(nH,"RECNO: " + cValToChar(FMX->R_E_C_N_O_) + " - Descricao: " + Alltrim(SFM->FM_DESCR)+ chr(13)+chr(10) )         
        EndIf
        FMX->(dbSkip())
    EndDo

    fClose(nH) 
	
	Msginfo("Processamento finalizado - Arquivo de log criado :" + cFile) 
Return
