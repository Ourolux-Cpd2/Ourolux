#INCLUDE "PROTHEUS.CH"

*----------------------*
User Function MA110BUT() 
*----------------------*
Local nOpc:= PARAMIXB[1]
Local aBut110:= PARAMIXB[2]
                       

aadd(aBut110,{"S4WB005N",{|| u_SvCalCub("SC1") },"str0055","Calc.Cubagem" })  //Historico de Produtos

Return aBut110   

                                                            
