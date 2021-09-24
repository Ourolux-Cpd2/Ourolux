/*
+===========================================================================+
|Consultoria:                Q S   d o   B R A S I L                        |
+---------------------------------------------------------------------------+
|Programa   | XVOLPED	|Autor  | Vitor Lopes        | Data |  10/08/21     |
+---------------------------------------------------------------------------+
|Descricao  | Informar número de volume no pedido de venda.       	   		|
|           | 															    |
|           |															    |
+---------------------------------------------------------------------------+
|Uso        | MP11 - Cliente: OuroLux									    |
+---------------------------------------------------------------------------+
|Solicitante| 							       						        |
+---------------------------------------------------------------------------+
|Alteracoes | Descrição....:    											|
|           | Solicitante..:    	      									|
|           | Data.........: 			   							        |
|           | Consultor....:											    |
+===========================================================================+
*/

#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH" 

***********************
User Function XVOLPED()
***********************

Local cTitulo   := "Informar número de volume"
Local cQry      := ""
Local cGrpSol   := SuperGetMV("ES_GRPSOL",.F.,"2501|2506|2044|2508|2520|2530|2510")
Private oDlg         
Private oLbx    := {}
Private aVetor  := {} 
Private cCarga  := DAK->DAK_COD

If !(DAK->DAK_FEZNF == '2' .And. DAK->DAK_ACECAR == '2'.And.(DAK->DAK_BLQCAR == '2' .Or. DAK->DAK_BLQCAR == ' ') .And. (DAK->DAK_JUNTOU=='MANUAL'.Or. DAK->DAK_JUNTOU=='ASSOCI'.Or.DAK->DAK_JUNTOU=='JUNTOU'))
    Alert("Só é possivel alterar cargas que estejam totalmente em aberto")
    Return
EndIf

cQry := " SELECT DISTINCT( DAI_PEDIDO ) DAI_PEDIDO "
cQry += " FROM  "+RetSQlName("DAI")+" DAI"
cQry += "        INNER JOIN " + RetSqlName("SC5") + " SC5 "
cQry += "                ON ( C5_FILIAL = DAI_FILIAL "
cQry += "                     AND C5_NUM = DAI_PEDIDO "
cQry += "                     AND SC5.D_E_L_E_T_ = '' ) "
cQry += " 		INNER JOIN " + RetSqlName("SC6") + " SC6 "
cQry += " 			ON SC6.C6_FILIAL = SC5.C5_FILIAL " 
cQry += " 				AND SC6.C6_NUM = SC5.C5_NUM "
cQry += " 				AND SC6.C6_CLI = SC5.C5_CLIENTE "
cQry += " 				AND SC6.C6_LOJA = SC5.C5_LOJACLI "
cQry += " 				AND SC6.D_E_L_E_T_ = '' "
cQry += " 		INNER JOIN " + RetSqlName("SB1") + " SB1 "
cQry += " 			ON SB1.B1_COD = SC6.C6_PRODUTO "
cQry += " 			AND SB1.B1_GRUPO IN " +Formatin(cGrpSol,"|")
cQry += " 			AND SB1.D_E_L_E_T_ = '' "
cQry += " WHERE  DAI_FILIAL = '"+xFilial("DAI")+"' "
cQry += "        AND DAI_COD = '"+cCarga+"' "
cQry += "        AND DAI.D_E_L_E_T_ = '' "

TCQUERY cQry ALIAS "TMPDAI" NEW

DbSelectArea("SC5")
DbSetOrder(1)
    
While TMPDAI->(!Eof())
    
    If MsSeek(xFilial("SC5")+Padr(TMPDAI->DAI_PEDIDO,6))
        aadd(aVetor,{TMPDAI->DAI_PEDIDO,SC5->C5_VOLUME1})
    Else
        aadd(aVetor,{TMPDAI->DAI_PEDIDO,0})
    EndIf

TMPDAI->(DbSkip())
EndDo
TMPDAI->(DbCloseArea())

If Len(aVetor) == 0

    FwAlertInfo("Carga "+cCarga+" não possui pedido de venda Solar.")
    Return

EndIf

DEFINE MSDIALOG oDlg TITLE cTitulo FROM 0,0 TO 550,550 PIXEL //Tela Principal

@ 240,190 BUTTON "&Gravar"  SIZE 036,12 PIXEL ACTION Processa({||fGrava(@aVetor,@oLbx,oLbx:nAt,oLbx:ColPos)},"Aguarde Gravando...") 
@ 240,235 BUTTON "&Sair"    SIZE 036,12 PIXEL ACTION Processa({||oDlg:End()},"Saindo...") 

@ 05,05 LISTBOX oLbx FIELDS HEADER "Pedido de Venda ","Nº de Volume" SIZE 270,220 Of oDlg Pixel ColSizes 70,70


oLbx:bLDblClick := {|| ValidA(@aVetor,@oLbx,oLbx:nAt,oLbx:ColPos)}  
oLbx:SetArray(aVetor) 
                                                                                                                          

//Adiciona espaço em branco caso vetor esteja vazio.
If ( Len(aVetor) == 0 )
	aAdd( aVetor, {"",0} )
EndIf


oLbx:SetArray( aVetor ) 
oLbx:bLine := {||  { aVetor[oLbx:nAT,1],;  
                    aVetor[oLbx:nAt,2]}} 


ACTIVATE MSDIALOG oDlg CENTER 


Return

**********************************************
Static Function ValidA(aList, oBrw,nLin, nCol)
**********************************************    

Local lok  := .F.
Local nDig := 0

While .T. .And. nCol == 2 
        lEditCell(@aList,oBrw,"@E 999999",nCol)  
        nDig := aList[nLin,nCol]
               
        If nDig <= 0 
            MsgAlert("Quantidade inválida!")
            lOk := .F.
        Else
            lOk := .T.
        EndIf          
        	                
        If lOk == .T.
           Exit
        EndIf
                      
     EndDo     

Return  

**************************************************
Static Function fGrava(aVetor, oLbx, nLin2, nCol2)
************************************************** 
Local xp := 0

For xp := 1 To Len(aVetor)

    DbSelectArea("SC5")
    DbSetOrder(1)
    If MsSeek(xFilial("SC5")+Padr(aVetor[xp][1],6) )

        RecLock("SC5",.F.)
            SC5->C5_VOLUME1 := aVetor[xp][2]
            SC5->C5_ESPECI1 := "Caixa(s)"
        SC5->(MsUnLock())

    EndIf

Next xp

FwAlertSuccess("Ajuste de pedido finalizado.")
oDlg:End()

Return
