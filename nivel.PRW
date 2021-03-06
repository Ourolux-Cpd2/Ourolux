#include "rwmake.ch"
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �USUARIOS  �Autor  �                    � Data �  01/17/02   ���
�������������������������������������������������������������������������͹��
���Desc.     �Carrega os usuarios existentes no SIGAADV.PSS em uma lista  ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Elementos do array de usuarios � aUsu[A][B][C]                         ���
�������������������������������������������������������������������������͹��
���[C]                                                                    ���
���[01] ID                                     C     06                   ���
���[02] nome                                   C     15                   ���
���[03] senha                                  C     06                   ���
���[04] nome completo                          C     30                   ���
���[05] vetor com n �ltimas senhas             A                          ���
���[06] data de validade                       D     08                   ���
���[07] quantas vezes para expirar             N     04                   ���
���[08] autorizado a alterar a senha           L     01                   ���
���[09] alterar senha no pr�ximo logon         L     01                   ���
���[10] vetor com os grupos                    A                          ���
���[11] ID do superior                         C     06                   ���
���[12] departamento                           C     30                   ���
���[13] cargo                                  C     30                   ���
���[14] e-mail                                 C     120                  ���
���[15] n�mero de acessos simult�neos          N     04                   ���
���[16] data da �ltima altera��o               D     08                   ���
���[17] usu�rio bloqueado                      L     01                   ���
���[18] numero de digitos para o ano           N     01                   ���
���[19] listner de liga��es                    L     01                   ���
���[20] ramal                                  C     04                   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function Usuarios()

Local aUsu :={}
Local aNomUsu :={}
Local x
Local _cNivelUsu,_cModulo,cBloq 
_aRet := {}


//������������������������������������������������������
//�Array para guardar TODAS as informacoes dos usuarios �
//�existentes no SIGAADV.PSS                            �
//�������������������������������������������������������
aUsu := AllUsers(.T.)

//���������������������������������������������������
//�Alimenta um array somente com o nome dos usuarios�
//���������������������������������������������������
For x :=1 to Len(aUsu)
	//Aadd(aNomUsu,aUsu[x][1][2])
	PSWOrder(2)
	If PSWSeek(aUsu[x][1][2],.T.)    // 
	   _aRet := PSWRet(3)
   		
   
   		FOR _nCont      := 1 TO Len(_aRet[1])  
       		_cModulo    := ALLTRIM (SUBSTR(_aRet[1,_nCont],13)) //Obter N�vel apenas do m�dulo 
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

//Obtendo o n�vel do Usu�rio
_aRet := {}
_nomeuser:=substr(cusuario,7,15)
PSWOrder(2)
If PSWSeek(_nomeuser,.T.)
   _aRet := PSWRet(3)
   FOR _nCont   := 1 TO Len(_aRet[1])  
       If _cModulo := SUBSTR(_aRet[1,_nCont],18,3) == cModulo   //Obter N�vel apenas do m�dulo ativo
          _cNivelUsu  := SUBSTR(_aRet[1,_nCont],3,1)
       EndIf    
   NEXT _nCont
EndIf

//Obtendo o n�vel do Campo
DbSelectArea("SX3")
DbSetOrder(2)                
_cCampo:="A1_NOME"
If DbSeek(_cCampo)
   _cNivelCpo:=X3_NIVEL
Endif   

ALERT("Nivel do Usu�rio: " + AllTrim(_nomeuser) + " � " + _cNivelUsu)
ALERT("Nivel do Campo  : " + AllTrim(_cCampo) + " � " + Str(_cNivelCpo,1))

If Val(_cNivelUsu) >= _cNivelCpo
   ALERT("O campo dever� ser considerado no processamento")
EndIf          
Return
*/