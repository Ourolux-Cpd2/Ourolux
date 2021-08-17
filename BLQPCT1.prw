#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ BLQPCT1    ºAutor  ³Isaias Chipoch    º Data ³  05/05/16   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Programa visa pegar um range de contas e bloquea-las        ±±
±±º          ³ usando os campos CT1->CT1_DTBLIN  / CT1->CT1_DTBLFI        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function BLQPCT1

Local dGetData := Date() 
Local dGetData2 := Date()+30
Local cGetConta := space(40)
Local cGetConta2 := space(40)
Local oData
Local oData2
Local oConta
Local oConta2
Local oGetData
Local oGetConta
Local oBtnGravar
Local oBtnFechar

PRIVATE oDlg 


  DEFINE MSDIALOG oDlg TITLE "Manutenção Plano de Contas" FROM 000, 000  TO 300, 400 PIXEL  
   	
    @ 010, 007 SAY oData PROMPT "Data Inicial" SIZE 029, 007 OF oDlg PIXEL
    @ 010, 037 MSGET oGetData VAR dGetData SIZE 040, 010 OF oDlg PIXEL
    
    @ 010, 107 SAY oData2 PROMPT "Data Final" SIZE 029, 007 OF oDlg PIXEL
    @ 010, 137 MSGET oGetData  VAR dGetData2 SIZE 040, 010 OF oDlg PIXEL valid dGetData2 >= dGetData
    
    
    @ 050, 007 SAY oConta PROMPT "Conta Inicial" SIZE 029, 007 OF oDlg PIXEL
    @ 050, 040 MSGET oGetConta VAR cGetConta SIZE 040, 010 OF oDlg F3 "CT1" PIXEL valid existcpo ("CT1",cGetConta,1) 
                                                                   
    @ 050, 107 SAY oConta2 PROMPT "Conta Final" SIZE 029, 007 OF oDlg PIXEL
    @ 050, 137 MSGET oGetConta  VAR cGetConta2 SIZE 040, 010 OF oDlg F3 "CT1" PIXEL valid existcpo ("CT1",cGetConta2,1) .and. cGetConta2 >= cGetConta
    
          
    @ 110, 067 BUTTON oBtnGravar PROMPT "Confirma" SIZE 037, 012 OF oDlg ACTION Processa( {|| AtuaCT1(@dGetData,@dGetData2,@cGetConta,@cGetConta2) }, "Aguarde...", "Realizando o processamento das contas ...",.F.) PIXEL
    @ 110, 107 BUTTON oBtnFechar PROMPT "Fecha" SIZE 037, 012 OF oDlg ACTION oDlg:End() PIXEL
  
  	
                               
  ACTIVATE MSDIALOG oDlg CENTERED

                                                                                    
Return(.T.)

  
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AtuaCT1    ºAutor  ³Isaias Chipoch     º Data ³  05/05/16   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Processa o bloqueio/atualizacao do range de contas          º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
static function AtuaCT1(dGetData,dGetData2,cGetConta,cGetConta2)

Local _cQuery	:= ""
Local nCountB	:= 0
Local nCountD	:= 0


_cQuery:= " SELECT CT1_CONTA AS CONTA,CT1_DESC01 AS DESC01  "
_cQuery+= " FROM "
_cQuery+= 		RetSqlName("CT1") "
_cQuery+= " WHERE "
_cQuery+= "	D_E_L_E_T_ = '' AND "
_cQuery+= " CT1_CONTA BETWEEN "+"'"+cGetConta+"'"+" AND "+"'"+cGetConta2+"'" 
_cQuery+= " ORDER BY "
_cQuery+= "		CT1_CONTA"


_cQuery:= ChangeQuery(_cQuery )

If Select("TMPCT1") > 0
	DbSelectArea("TMPCT1")
	TMPCT1->(DbCloseArea())
EndIf

dbUseArea(.T.,"TOPCONN",TCGenQry(,,_cQuery ),"TMPCT1",.F.,.T.)  

TMPCT1->(dbgotop())
ProcRegua(RecCount())

TMPCT1->(dbgotop())
While TMPCT1->(!Eof())
	
	incproc("Processando conta: "+TMPCT1->DESC01)
	
	dbselectarea("CT1")
	CT1->(dbsetorder(1))
	
	IF CT1->(dbseek(xFilial("CT1")+TMPCT1->CONTA))
		if !empty(dGetData) .and. !empty(dGetData2)
		
			Reclock("CT1",.F.)
			
			CT1->CT1_DTBLIN:=dGetData
			CT1->CT1_DTBLFI:=dGetData2
			
			MSUNLOCK()
			
			nCountB++
			
		elseif empty(dGetData) .and. empty(dGetData2) 
		
			Reclock("CT1",.F.)
			
			CT1->CT1_DTBLIN:=CTOD("")
			CT1->CT1_DTBLFI:=CTOD("")
		
			MSUNLOCK() 
			
			nCountD++
				
		endif
	ENDIF 

	TMPCT1->( DbSkip() )
	
Enddo

if nCountB > 0
	msginfo("Processamento Concluido"+CHR(13)+CHR(10)+"Nº de contas bloqueadas: "+str(nCountB))
elseif nCountD > 0
	msginfo("Processamento Concluido"+CHR(13)+CHR(10)+"Nº de contas desloqueadas: "+str(nCountD))
else
	msginfo("Processamento Concluido"+CHR(13)+CHR(10)+"nenhuma alteração efetuada, revise os parametros. !")
endif		
	

Return