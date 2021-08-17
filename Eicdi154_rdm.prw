#INCLUDE "RWMAKE.CH"
#INCLUDE "EICDI154.CH" 
#INCLUDE "AVERAGE.CH"

/*
Luiz Augusto Mota Filho - LAM - 27/01/10
Objetivo: Validação da Numeração da NFE
Cliente: Eletromega
Versão: MP8.11
*/

*--------------------------------------------------------------------------------------
User function EICDI154()           
*--------------------------------------------------------------------------------------
Local cChamada := ""
Local lRetValid := .T. 

If ValType(ParamIXB) = "C"
   cChamada := PARAMIXB
Endif   

Do Case

   case cChamada == "VALID_NFE"
      If cPE_Qual = "SERIE"
         
         SF3->(DBSETORDER(5))
         
         If SF3->(DbSeek(xFilial("SF3")+cSerieNFE+cNumNFE))
            Help("",1,"AVG0000810") //Numero da N.F. e da Serie ja cadastrados no sistema
            lRetValid := .F.
         EndIf
      
      EndIF
      
EndCase

Return lRetValid