#INCLUDE "RWMAKE.CH"
#include "TbiConn.ch"
#include "TbiCode.ch"
#INCLUDE "AP5MAIL.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FONT.CH"
#include "topconn.ch"

User Function UPDSE5X()

	Processa({|| xUPDSE5()},"Processando Alterações... ")

Return

Static Function xUPDSE5()
    Local cFile     := "C:\TEMP\LogAtualizacao_SE5_"+DTOS(dDataBase)+"_"+Replace(Time(),":","-")+".txt" 
    Local nH        := fCreate(cFile) 
    Local cQuery    := ""

    If nH == -1 
	   MsgStop("Falha ao criar arquivo - erro "+str(ferror())) 
	   Return 
	Endif 

    dbSelectArea("SE5")
    
    cQuery := " SELECT SE5.R_E_C_N_O_ AS RECSE5, SE1.E1_FILORIG, SE5.E5_FILORIG , * "
    cQuery += " FROM "
    cQuery += " ( SELECT * FROM " + RetSqlName("SE1")
    cQuery += "   WHERE D_E_L_E_T_ = '' "
    cQuery += "   AND E1_FILORIG <> '' "
    cQuery += " ) SE1 "
    cQuery += " INNER JOIN " + RetSqlName("SE5") + " SE5 "
    cQuery += " ON SE1.E1_PREFIXO = SE5.E5_PREFIXO "
    cQuery += " AND SE1.E1_NUM = SE5.E5_NUMERO "
    cQuery += " AND SE1.E1_TIPO = SE5.E5_TIPO "
    cQuery += " AND SE1.E1_CLIENTE = SE5.E5_CLIFOR "
    cQuery += " AND SE1.E1_LOJA = SE5.E5_LOJA "
    cQuery += " AND SE1.E1_PARCELA = SE5.E5_PARCELA "
    cQuery += " AND SE5.E5_FILORIG = '' "
    cQuery += " AND SE5.E5_DATA<='20131231' "
    cQuery += " AND SE5.D_E_L_E_T_ = '' "

    If Select("E5X") > 0 
        E5X->(dbCloseArea())
    EndIf
    
    DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery) , 'E5X', .T., .F.)

    While E5X->(!EOF())
        SE5->(dbGoTo(E5X->RECSE5))

        If  SE5->E5_NUMERO == E5X->E5_NUMERO .AND. SE5->E5_PREFIXO == E5X->E5_PREFIXO .AND. SE5->E5_TIPO == E5X->E5_TIPO .AND. SE5->E5_CLIFOR == E5X->E5_CLIFOR .AND. SE5->E5_LOJA == E5X->E5_LOJA .AND. SE5->E5_PARCELA == E5X->E5_PARCELA 

            If RecLock("SE5", .F.)
                fWrite(nH,"TITULO: " + Alltrim(SE5->E5_NUMERO) + " PREFIXO: "+Alltrim(SE5->E5_PREFIXO)+ " TIPO: "+Alltrim(SE5->E5_TIPO)+ " CLIENTE: "+Alltrim(SE5->E5_CLIFOR)+ " LOJA: "+Alltrim(SE5->E5_LOJA)+ " PARCELA: "+Alltrim(SE5->E5_PARCELA)+" - FILIAL ORIGEM DE: " + Alltrim(SE5->E5_FILORIG) + " - FILIAL ORIGEM PARA: " + Alltrim(E5X->E1_FILORIG) + chr(13)+chr(10))    
                SE5->E5_FILORIG := E5X->E1_FILORIG
                SE5->(MsUnlock())   
            EndIF
    
        EndIf    
        
        E5X->(dbSkip())    

    EndDo
                    
    fClose(nH) 
	
	Msginfo("Processamento finalizado - Arquivo de log criado :" + cFile) 

Return


