#include 'protheus.ch'
#include 'parmtype.ch'

//--------------------------------------------------------------------
/*/{Protheus.doc} FTOUT006
Mostrar Faturas x CTEs
@author Caio
@since 10/02/2020
@version 1.0
@type function
/*/
//--------------------------------------------------------------------

user function FTOUT006()
 
Local aArea     := GetArea()
Local oAbrir    := Nil
Local oFechar   := Nil
Local oGroup1   := Nil
Local oGroup2   := Nil
Local oPanSE2   := Nil
Local oPanSF1   := Nil
Local cQuery    := ""
Local cWa       := ""
Local oListSE2  := Nil
Local aColsSE2  := {'Filial'      ;
                   ,'Prefixo'     ;
                   ,'Número'      ;
                   ,'Parcela'     ;
                   ,'Tipo'        ;
                   ,'Fornecedor'  ;
                   ,'Loja'        ;
                   ,'Emissão'     ;
                   ,'Vencto.'     ;
                   ,'Vencto. Real';
                   ,'Valor'       ;
                   ,'Saldo'       ;
                   ,'Data Baixa'  }
                   
Local aColsSF1  := {'Filial'      ;
                   ,'Documento'   ;
                   ,'Série'       ;
                   ,'Fornecedor'  ;
                   ,'Loja'        ;
                   ,'Emissão'     ;
                   ,'Digitação'   ;
                   ,'Estado'      ;
                   ,'Espécie'     ;
                   ,'Chave NFE'   ;
                   ,'Id. Fatura'  ;
                   ,'Recno'       }
                   
Private oListSF1  := Nil
Private aBrowSF1  := {}
Private aBrowSE2  := {{Alltrim(SE2->E2_FILIAL)  ;
                      ,Alltrim(SE2->E2_PREFIXO) ;
                      ,Alltrim(SE2->E2_NUM)     ;
                      ,Alltrim(SE2->E2_PARCELA) ;
                      ,Alltrim(SE2->E2_TIPO)    ;
                      ,Alltrim(SE2->E2_FORNECE) ;
                      ,Alltrim(SE2->E2_LOJA)    ;
                      ,DToC(SE2->E2_EMISSAO)    ;
                      ,DToC(SE2->E2_VENCTO)     ;
                      ,DToC(SE2->E2_VENCREA)    ;
                      ,SE2->E2_VALOR            ;
                      ,SE2->E2_SALDO            ;
                      ,DToC(SE2->E2_BAIXA)      }}

Private oDlg
                   
   dbSelectArea("SF1")
   SF1->(dbSetOrder(8)) //F1_FILIAL+F1_CHVNFE
   
  DEFINE MSDIALOG oDlg TITLE "Faturas x CTEs" FROM 000, 000  TO 540, 900 COLORS 0, 16777215 PIXEL

    @ 001, 002 GROUP oGroup1 TO 060, 402 PROMPT "Faturas " OF oDlg COLOR 0, 16777215 PIXEL
    @ 003, 407 BUTTON oFechar PROMPT "Fechar" SIZE 037, 012 OF oDlg PIXEL ACTION {|x| oDlg:End() }
    @ 020, 407 BUTTON oAbrir PROMPT "Abrir CTE" SIZE 037, 012 OF oDlg PIXEL ACTION {|x| AbrirCTE() }
    @ 063, 002 GROUP oGroup2 TO 265, 446 PROMPT "CTE's " OF oDlg COLOR 0, 16777215 PIXEL
    @ 006, 004 MSPANEL oPanSE2 PROMPT "" SIZE 395, 051 OF oDlg COLORS 0, 14215660 //RAISED
    @ 067, 004 MSPANEL oPanSF1 PROMPT "" SIZE 438, 194 OF oDlg COLORS 0, 14215660 //RAISED
    
    cQuery := " SELECT SF1.* FROM " + RetSqlName("SF1") + " SF1 "
    cQuery += " INNER JOIN " + RetSqlName("SA2") + " SA2 "
    cQuery += " ON A2_COD = F1_FORNECE AND A2_LOJA = F1_LOJA "
    cQuery += " WHERE  SF1.F1_CTEFAT = '" + SE2->E2_NUM + "' AND LEFT(SA2.A2_CGC,8) = (
    cQuery += " SELECT LEFT(AUX.A2_CGC,8) FROM " + RetSqlName("SE2") + " SE2 "
    cQuery += " INNER JOIN " + RetSqlName("SA2") + " AUX "
    cQuery += " ON E2_FORNECE = AUX.A2_COD AND E2_LOJA = AUX.A2_LOJA "
    cQuery += " WHERE E2_FILIAL = '" + xFilial("SE2") + "' AND E2_PREFIXO = '" + SE2->E2_PREFIXO + "' AND E2_NUM = F1_CTEFAT AND AUX.D_E_L_E_T_ = ' ' AND SE2.D_E_L_E_T_ = ' ' ) "
    cQuery += " AND SF1.D_E_L_E_T_ = ' '  AND SA2.D_E_L_E_T_ = ' ' "
    
    cQuery := ChangeQuery(cQuery)
    
    dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),(cWa := GetNextAlias()),.T.,.T.)
    
    If (cWa)->(Eof())
    	
    	oAbrir:bWhen := {|| .F. }
	
    	aAdd(aBrowSF1,{""             ;
                      ,""             ;
                      ,""             ;
                      ,""             ;
                      ,""             ;
                      ,DToC(SToD("")) ;
                      ,DToC(SToD("")) ;
                      ,""             ;
                      ,""             ;
                      ,""             ;
                      ,""             ;
                      ,""             })
    	
    Else
	    	
	    While (cWa)->(!Eof())
	    	
	    	aAdd(aBrowSF1,{Alltrim((cWa)->F1_FILIAL)      ;
	                      ,Alltrim((cWa)->F1_DOC)         ;
	                      ,Alltrim((cWa)->F1_SERIE)       ;
	                      ,Alltrim((cWa)->F1_FORNECE)     ;
	                      ,Alltrim((cWa)->F1_LOJA)        ;
	                      ,DToC(SToD((cWa)->F1_EMISSAO))  ;
	                      ,DToC(SToD((cWa)->F1_DTDIGIT))  ;
	                      ,Alltrim((cWa)->F1_EST)         ;
	                      ,Alltrim((cWa)->F1_ESPECIE)     ;
	                      ,Alltrim((cWa)->F1_CHVNFE)      ;
	                      ,Alltrim((cWa)->F1_CTEFAT)      ;
	                      ,(cWa)->R_E_C_N_O_              })
	                      
	    	(cWa)->(dbSkip())
	    	
	    EndDo
	    
    Endif
    
    dbCloseArea()
	
	oListSE2 := TWBrowse():New(0,0,0,0,,aColsSE2,{20,30,30},oPanSE2,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )
	              
	oListSE2:SetArray(aBrowSE2)
	      
	oListSE2:Align := CONTROL_ALIGN_ALLCLIENT
	    
	oListSE2:bLine := {||{ aBrowSE2[oListSE2:nAt,01] ,;
	                       aBrowSE2[oListSE2:nAt,02] ,;
	                       aBrowSE2[oListSE2:nAt,03] ,;
	                       aBrowSE2[oListSE2:nAt,04] ,;
	                       aBrowSE2[oListSE2:nAt,05] ,;
	                       aBrowSE2[oListSE2:nAt,06] ,;
	                       aBrowSE2[oListSE2:nAt,07] ,;
	                       aBrowSE2[oListSE2:nAt,08] ,;
	                       aBrowSE2[oListSE2:nAt,09] ,;
	                       aBrowSE2[oListSE2:nAt,10] ,;
	                       aBrowSE2[oListSE2:nAt,11] ,;
	                       aBrowSE2[oListSE2:nAt,12] ,;
	                       aBrowSE2[oListSE2:nAt,13] }}
	                           
    oListSF1 := TWBrowse():New(0,0,0,0,,aColsSF1,{20,30,30},oPanSF1,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )
	      
	oListSF1:SetArray(aBrowSF1)
	      
	oListSF1:Align := CONTROL_ALIGN_ALLCLIENT
	                
	oListSF1:bLine := {||{ aBrowSF1[oListSF1:nAt,01] ,;
	                       aBrowSF1[oListSF1:nAt,02] ,;
	                       aBrowSF1[oListSF1:nAt,03] ,;
	                       aBrowSF1[oListSF1:nAt,04] ,;
	                       aBrowSF1[oListSF1:nAt,05] ,;
	                       aBrowSF1[oListSF1:nAt,06] ,;
	                       aBrowSF1[oListSF1:nAt,07] ,;
	                       aBrowSF1[oListSF1:nAt,08] ,;
	                       aBrowSF1[oListSF1:nAt,09] ,;
	                       aBrowSF1[oListSF1:nAt,10] ,;
	                       aBrowSF1[oListSF1:nAt,11] ,;
	                       aBrowSF1[oListSF1:nAt,12] }} 
	
	//Troca a imagem no duplo click do mouse    
	
	oListSF1:bLDblClick := {|| AbrirCTE() }   
	
  ACTIVATE MSDIALOG oDlg CENTERED
  
  RestArea(aArea)
  
Return(Nil)

//--------------------------------------------------------------------
/*/{Protheus.doc} AbrirCTE
Abre documento de entrada
@author Caio
@since 10/02/2020
@version 1.0 
/*/
//--------------------------------------------------------------------

Static Function AbrirCTE()

Local cFuncao := FunName()

	SF1->(dbGoTo(aBrowSF1[oListSF1:nAt,12]))
	
	SetFunName("MATA103")
	
	A103NFiscal("SF1",SF1->(Recno()),2) 
	
	SetFunName(cFuncao) 
	
Return(Nil)
