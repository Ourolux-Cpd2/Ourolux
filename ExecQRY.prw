#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "Tbiconn.ch"
#INCLUDE "Tbicode.ch"

User Function ExecQRY()   
Local cQuery := ""
Local cFile  := "C:\TEMP\LogAtualizacao_SC1_SC7_"+DTOS(dDataBase)+"_"+Replace(Time(),":","-")+".txt" 
Local nH     := fCreate(cFile) 

 If nH == -1 
    MsgStop("Falha ao criar arquivo - erro "+str(ferror())) 
    Return 
Endif 

DbSelectArea("SC1")
DbSelectArea("SC7")

cQuery := " SELECT  "
cQuery += " 'UPDATE SC1010 SET C1_COTACAO = '''',  C1_IMPORT = ''N'', C1_NUM_SI = ''''  WHERE R_E_C_N_O_ = ' + CAST(SC1.R_E_C_N_O_ AS VARCHAR(6)) + CHAR(13) AS QRY, SC1.R_E_C_N_O_  "
cQuery += " FROM SC1010 SC1 "
cQuery += " INNER JOIN SW1010 SW1 "
cQuery += " ON W1_SI_NUM = C1_NUM_SI "
cQuery += " AND C1_PRODUTO = W1_COD_I "
cQuery += " AND C1_QUANT = W1_QTDE "
cQuery += " AND SW1.D_E_L_E_T_ = '' "
cQuery += " WHERE  SC1.D_E_L_E_T_ = '' "
cQuery += " AND C1_FILIAL IN ('01','06') "
cQuery += " AND C1_IMPORT = 'S' "
cQuery += " AND W1_PRECO = 0 "
cQuery += " AND W1_PO_NUM = '' "
cQuery += " ORDER BY C1_FILIAL, C1_NUM "

If Select("EXCQ") > 0
    EXCQ->(DbCloseArea())
EndIf

cQuery := ChangeQuery(cQuery)

dbUseArea(.T.,"TOPCONN",TCGenqry(,,cQuery),"EXCQ",.F.,.T.)


While EXCQ->(!EOF())
    SC1->(dbGoTo(EXCQ->R_E_C_N_O_))

    If TcSqlExec(EXCQ->QRY) < 0
        fWrite(nH,chr(13)+chr(10)+"**********ERRO DE EXECUCAO DE QUERY**********"+chr(13)+chr(10) )
        fWrite(nH,"Filial: " +SC1->C1_FILIAL + " Solicitacao: " + SC1->C1_NUM + chr(13)+chr(10))
        fWrite(nH,EXCQ->QRY + chr(13)+chr(10) + chr(13)+chr(10) )
    else
        fWrite(nH,"ALTEROU VIA UPDATE 1 - Filial: " +SC1->C1_FILIAL + " Solicitacao: " + SC1->C1_NUM +" UPDATE: "+ EXCQ->QRY+ chr(13)+chr(10) ) 
    EndIf
    EXCQ->(dbSkip())
EndDo

cQuery := " SELECT "
cQuery += " ' UPDATE SC7010 SET C7_ORIGEM ='''', C7_NUMIMP='''' WHERE R_E_C_N_O_ = ' + Cast(SC7.R_E_C_N_O_ AS VARCHAR(6))+ Char(13) as QRY, SC7.R_E_C_N_O_ "
cQuery += " FROM( "
cQuery += " SELECT  C1_FILIAL FILIAL, C1_NUM SOLICIT, C1_PEDIDO PEDIDO, C1_EMISSAO, C1_ITEM ITEM , C1_PRODUTO PROD,  C1_QUANT, C1_QUJE,  W1_PO_NUM PO, W1_SI_NUM SI "
cQuery += " FROM SC1010 SC1 "
cQuery += " LEFT OUTER JOIN SW1010 SW1 "
cQuery += " ON W1_PO_NUM = C1_PEDIDO "
cQuery += " AND C1_EMISSAO = W1_DTENTR_ "
cQuery += " AND W1_COD_I = C1_PRODUTO "
cQuery += " AND C1_QUANT = W1_QTDE "
cQuery += " AND SW1.D_E_L_E_T_ = '' "
cQuery += " INNER JOIN SC7010 "
cQuery += " ON C1_PEDIDO = C7_NUM "
cQuery += " AND C1_PRODUTO = C7_PRODUTO "
cQuery += " AND C1_ITEM = C7_ITEM  "
cQuery += " WHERE  SC1.D_E_L_E_T_ = '' "
cQuery += " AND C1_FILIAL IN ('01','06') "
cQuery += " AND C1_IMPORT = 'S' "
cQuery += " AND W1_PRECO = 0 "
cQuery += " AND C1_PEDIDO <> '' "
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
    SC7->(dbGoTo(EXCQ->R_E_C_N_O_))

    If TcSqlExec(EXCQ->QRY) < 0
        fWrite(nH,chr(13)+chr(10)+"**********ERRO DE EXECUCAO DE QUERY**********"+chr(13)+chr(10) )
        fWrite(nH,"Filial: " +SC7->C7_FILIAL + " Pedido: " + SC7->C7_NUM + chr(13)+chr(10))
        fWrite(nH,EXCQ->QRY + chr(13)+chr(10) + chr(13)+chr(10) )
    else
        fWrite(nH,"ALTEROU VIA UPDATE 2 - Filial: " +SC7->C7_FILIAL + " Pedido: " + SC7->C7_NUM +" UPDATE: "+ EXCQ->QRY+ chr(13)+chr(10) ) 
    EndIf
    EXCQ->(dbSkip())
EndDo

cQuery := " SELECT  "
cQuery += " 'UPDATE SC1010 SET C1_COTACAO = '''',  C1_IMPORT = ''N'', C1_NUM_SI = ''''  WHERE C1_NUM = ''' + C1_NUM + ''' AND C1_FILIAL = ''' + C1_FILIAL + '''' + ' AND R_E_C_N_O_ = ' +  Cast(R_E_C_N_O_ AS VARCHAR(6)) + CHAR(13)  as QRY , R_E_C_N_O_ "
cQuery += " FROM SC1010 SC1 "
cQuery += " WHERE  SC1.D_E_L_E_T_ = '' "
cQuery += " AND C1_FILIAL IN ('01','06') "
cQuery += " AND C1_IMPORT = 'S' "
cQuery += " AND C1_NUM_SI = '' "

If Select("EXCQ") > 0
    EXCQ->(DbCloseArea())
EndIf

cQuery := ChangeQuery(cQuery)

dbUseArea(.T.,"TOPCONN",TCGenqry(,,cQuery),"EXCQ",.F.,.T.)

While EXCQ->(!EOF())
    SC1->(dbGoTo(EXCQ->R_E_C_N_O_))

    If TcSqlExec(EXCQ->QRY) < 0
        fWrite(nH,chr(13)+chr(10)+"**********ERRO DE EXECUCAO DE QUERY**********"+chr(13)+chr(10) )
        fWrite(nH,"Filial: " +SC1->C1_FILIAL + " Solicitacao: " + SC1->C1_NUM + chr(13)+chr(10))
        fWrite(nH,EXCQ->QRY + chr(13)+chr(10) + chr(13)+chr(10) )
    else
        fWrite(nH,"ALTEROU VIA UPDATE 3 - Filial: " +SC1->C1_FILIAL + " Solicitacao: " + SC1->C1_NUM +" UPDATE: "+ EXCQ->QRY+ chr(13)+chr(10) ) 
    EndIf
    EXCQ->(dbSkip())
EndDo
    
fClose(nH) 
Msginfo("Processamento finalizado - Arquivo de log criado :" + cFile) 

rETURN
