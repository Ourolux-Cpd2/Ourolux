#include "Protheus.ch"
#INCLUDE "TBICONN.CH"
#INCLUDE "TOPCONN.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ImpArq    ºAutor  ³DENNIS              º Data ³  20/05/15   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ CORREÇÃO DE REGISTROS DA SA2                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function ImpArq()
Local _aStru1:={}
Local _aStru2:={}
Local _nInd:=0
local nCount := 0          

USE ("\system\sa2_tipox.dbf") VIA 'DBFCDX' ALIAS IMPTMP
_aStru2 := IMPTMP->(dbStruct())
DbSelectArea('IMPTMP')

While IMPTMP->( !Eof() )
	                
	If IMPTMP->( Eof() )
		Exit
	Endif
	             	        
	DbSelectArea('SA2')
	DbSetOrder(1)
	                
	If SA2->( dbSeek( xFilial('SA2')+ IMPTMP->A2_COD + IMPTMP->A2_LOJA)) 
					
		RecLock("SA2",.F.)
					
		SA2->A2_XCONDPG := IMPTMP->A2_XCONDPG
		SA2->A2_XBANCO  := IMPTMP->A2_XBANCO
		SA2->A2_XAGENC  := IMPTMP->A2_XAGENC
		SA2->A2_XENDBAN := IMPTMP->A2_XENDBAN
		SA2->A2_XCIDBAN := IMPTMP->A2_XCIDBAN
		SA2->A2_XPAISBA := IMPTMP->A2_XPAISBA
		SA2->A2_XCTABAN := IMPTMP->A2_XCTABAN
		SA2->A2_XPCNFE  := IMPTMP->A2_XPCNFE
					
		SA2->(MsUnLock())

	Endif
	IMPTMP->( dbSkip() )
Enddo   
IMPTMP->( dbCloseArea() )
MsgAlert("Fim do Processamento !")		
RETURN