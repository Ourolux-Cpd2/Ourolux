#INCLUDE "PROTHEUS.CH"

*----------------------*
User Function MA110BUT() 
*----------------------*
//Local nOpc:= PARAMIXB[1]
Local aBut110:= PARAMIXB[2]
                       
aadd(aBut110,{"S4WB005N",{|| u_OURO007()},"CTN p/ Entrega","CTN p/ Entrega" })
aadd(aBut110,{"S4WB005N",{|| u_OURO09B()},"Fases Calculo","Fases Calculo" })

Return aBut110   

                                                            
