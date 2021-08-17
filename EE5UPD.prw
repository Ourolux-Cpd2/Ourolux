#INCLUDE "RWMAKE.CH"
#include "TbiConn.ch"
#include "TbiCode.ch"
#INCLUDE "AP5MAIL.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FONT.CH"
#include "topconn.ch"


User Function EE5UPD()
    Local cFile  := "C:\TEMP\LogAtualizacao_"+DTOS(dDataBase)+"_"+Replace(Time(),":","-")+".txt" 
    Local nH     := fCreate(cFile) 
    Local cQuery := ""

    If nH == -1 
	   MsgStop("Falha ao criar arquivo - erro "+str(ferror())) 
	   Return 
	Endif 

    dbSelectArea("EE5")

    cQuery := " SELECT EE5_CODEMB, EE5_DESC, R_E_C_N_O_ FROM " + RetSqlName("EE5")
    cQuery += " WHERE EE5_CODEMB LIKE '%MASTE' "
    cQuery += " AND D_E_L_E_T_ = '' "

    If Select("B5X") > 0 
        B5X->(dbCloseArea())
    EndIf
    
    DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery) , 'B5X', .T., .F.)

    While B5X->(!EOF())
        EE5->(dbGoTo(B5X->R_E_C_N_O_))
        RecLock("EE5",.F.)
        EE5->EE5_CODEMB := Alltrim(B5X->EE5_CODEMB) + "R"
        EE5->(MsUnLock())
        fWrite(nH,"Embalagem: " + Alltrim(B5X->EE5_CODEMB) + " - Embalagem alterada de (" +Alltrim(B5X->EE5_CODEMB)+") para (" + Alltrim(EE5->EE5_CODEMB) +")" + chr(13)+chr(10) )         
        B5X->(dbSkip())
    EndDo

    fClose(nH) 
	
	Msginfo("Processamento finalizado - Arquivo de log criado :" + cFile) 

    UpdV2()
Return

Static function UpdV2()
   Local cFile  := "C:\TEMP\LogAtualizacao_"+DTOS(dDataBase)+"_"+Replace(Time(),":","-")+".txt" 
    Local nH     := fCreate(cFile) 
    Local cQuery := ""

    If nH == -1 
	   MsgStop("Falha ao criar arquivo - erro "+str(ferror())) 
	   Return 
	Endif 

    dbSelectArea("EE5")

    cQuery := " SELECT EE5_CODEMB, EE5_DESC, R_E_C_N_O_ FROM " + RetSqlName("EE5")
    cQuery += " WHERE EE5_CODEMB LIKE '%MAST' "
    cQuery += " AND D_E_L_E_T_ = '' "

    If Select("B5X") > 0 
        B5X->(dbCloseArea())
    EndIf
    
    DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery) , 'B5X', .T., .F.)

    While B5X->(!EOF())
        EE5->(dbGoTo(B5X->R_E_C_N_O_))
        RecLock("EE5",.F.)
        EE5->EE5_CODEMB := Alltrim(B5X->EE5_CODEMB) + "ER"
        EE5->(MsUnLock())
        fWrite(nH,"Produto: " + Alltrim(B5X->EE5_CODEMB) + " Embalagem alterada de (" +Alltrim(B5X->EE5_CODEMB)+") para (" + Alltrim(EE5->EE5_CODEMB) +")" + chr(13)+chr(10) )         
        B5X->(dbSkip())
    EndDo

    fClose(nH) 
	
	Msginfo("Processamento finalizado - Arquivo de log criado :" + cFile) 

Return
