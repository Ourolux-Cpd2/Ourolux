#INCLUDE "PROTHEUS.CH"

User function updCP1()

PutMv("MV_CTLIPAG",.T.)

TcSqlExec( "UPDATE SE2010 SET E2_WFALC = 'X', E2_DATALIB = '20200511', E2_APROVA = 'LEGADO' WHERE D_E_L_E_T_ = ' '")

Return