#include "rwmake.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณUSUARIOS  บAutor  ณ                    บ Data ณ  01/17/02   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณCarrega os usuarios existentes no SIGAADV.PSS em uma lista  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบElementos do array de usuarios ณ aUsu[A][B][C]                         บฑฑ
ฑฑฬอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ[C]                                                                    บฑฑ
ฑฑบ[01] ID                                     C     06                   บฑฑ
ฑฑบ[02] nome                                   C     15                   บฑฑ
ฑฑบ[03] senha                                  C     06                   บฑฑ
ฑฑบ[04] nome completo                          C     30                   บฑฑ
ฑฑบ[05] vetor com n ๚ltimas senhas             A                          บฑฑ
ฑฑบ[06] data de validade                       D     08                   บฑฑ
ฑฑบ[07] quantas vezes para expirar             N     04                   บฑฑ
ฑฑบ[08] autorizado a alterar a senha           L     01                   บฑฑ
ฑฑบ[09] alterar senha no pr๓ximo logon         L     01                   บฑฑ
ฑฑบ[10] vetor com os grupos                    A                          บฑฑ
ฑฑบ[11] ID do superior                         C     06                   บฑฑ
ฑฑบ[12] departamento                           C     30                   บฑฑ
ฑฑบ[13] cargo                                  C     30                   บฑฑ
ฑฑบ[14] e-mail                                 C     120                  บฑฑ
ฑฑบ[15] n๚mero de acessos simultโneos          N     04                   บฑฑ
ฑฑบ[16] data da ๚ltima altera็ใo               D     08                   บฑฑ
ฑฑบ[17] usuแrio bloqueado                      L     01                   บฑฑ
ฑฑบ[18] numero de digitos para o ano           N     01                   บฑฑ
ฑฑบ[19] listner de liga็๕es                    L     01                   บฑฑ
ฑฑบ[20] ramal                                  C     04                   บฑฑ
ฑฑศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function Usuarios()

Local aUsu :={}
Local aNomUsu :={}
Local x
Local _cNivelUsu,_cModulo,cBloq 
_aRet := {}


//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
//ณArray para guardar TODAS as informacoes dos usuarios ณ
//ณexistentes no SIGAADV.PSS                            ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
aUsu := AllUsers(.T.)

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณAlimenta um array somente com o nome dos usuariosณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
For x :=1 to Len(aUsu)
	//Aadd(aNomUsu,aUsu[x][1][2])
	PSWOrder(2)
	If PSWSeek(aUsu[x][1][2],.T.)    // 
	   _aRet := PSWRet(3)
   		
   
   		FOR _nCont      := 1 TO Len(_aRet[1])  
       		_cModulo    := ALLTRIM (SUBSTR(_aRet[1,_nCont],13)) //Obter Nํvel apenas do m๓dulo 
       	    _cNivelUsu  := SUBSTR(_aRet[1,_nCont],3,1)
       		If !(_cNivelUsu $ 'X' ) 
        		   		      		
        		cBloq := IIf (aUsu[x][1][17],"SIM","NAO") 
        		Aadd(aNomUsu,_cNivelUsu + ' | ' + cBloq + ' | ' + PadR(aUsu[x][1][2], 20) + ' | ' + _cModulo)
           
         	EndIf
    	NEXT _nCont
    EndIf
Next x

aSort(aNomUsu,,,{|x,y| x < y})

@ 00,00 to 300,400 Dialog oDlg Title "Listagem dos Usuarios"
@ 10,10 LISTBOX x ITEMS aNomUsu SIZE 150,100
@ 10,(oDlg:nRight/2)-40 BUTTON "_Fechar" SIZE 30,10 ACTION Close(oDlg)
Activate Dialog oDlg Center
	
Return















/*







User Function Grupo1()

//Obtendo o nํvel do Usuแrio
_aRet := {}
_nomeuser:=substr(cusuario,7,15)
PSWOrder(2)
If PSWSeek(_nomeuser,.T.)
   _aRet := PSWRet(3)
   FOR _nCont   := 1 TO Len(_aRet[1])  
       If _cModulo := SUBSTR(_aRet[1,_nCont],18,3) == cModulo   //Obter Nํvel apenas do m๓dulo ativo
          _cNivelUsu  := SUBSTR(_aRet[1,_nCont],3,1)
       EndIf    
   NEXT _nCont
EndIf

//Obtendo o nํvel do Campo
DbSelectArea("SX3")
DbSetOrder(2)                
_cCampo:="A1_NOME"
If DbSeek(_cCampo)
   _cNivelCpo:=X3_NIVEL
Endif   

ALERT("Nivel do Usuแrio: " + AllTrim(_nomeuser) + " ้ " + _cNivelUsu)
ALERT("Nivel do Campo  : " + AllTrim(_cCampo) + " ้ " + Str(_cNivelCpo,1))

If Val(_cNivelUsu) >= _cNivelCpo
   ALERT("O campo deverแ ser considerado no processamento")
EndIf          
Return
*/