/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³SF2520E   ºAutor  ³Eletromega          º Data ³  07/01/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Ponto de Entrada :  Dispara o Workflow na exclusao         º±±
±±º          ³ de documento de saida                                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP6 														  º±±
±±ºEsse ponto de entrada está localizado na função A520Dele(). 			  º±±
±±ºÉ chamado antes da exclusão dos dados nos arquivos                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

#include 'rwmake.ch'
#include "TbiConn.ch"

user function SF2520E()
    
Local oHTML
Local _cLista 	 := '' 
Local _cMotivo   := Space(109)
Local _lOK       := ''
Local cCodVend   := ''
Local cNomVend   := ''
Local cCodSup    := ''
Local cNomSup    := ''
Local cCodGer    := ''
Local cNomGer    := ''
Local aAreaSC5   := SC5->(GetArea())    
		
@ 96,42 TO 323,505 DIALOG oDlg TITLE "Motivo De Exclusao De Documento"
@ 8,10 TO 84,222    // 8,10 TO 84,222
@ 91,139 BUTTON "Envia" Size 70,20  ACTION Close(oDlg)
@ 33,14 SAY "Favor, digite o motivo da exclusao: " 
@ 43,14 GET  _cMotivo     //43,14 GET _cMotivo
ACTIVATE DIALOG oDlg CENTERED
    
_cLista := U_getEmls(SF2->F2_VEND1)
_cLista += IIf(Empty(_cLista),U_GrpEmail('Exclusao'),';'+U_GrpEmail('Exclusao'))
                      
oProcess:= TWFProcess():New("DocSaida","Excluir")
oProcess:NewTask("Inicio","\WORKFLOW\Exclusao.htm")
oProcess:cSubject := "Exclusao De Documento de Saida: " + Alltrim(SM0->M0_NOME) + '/' +Alltrim(SM0->M0_FILIAL) 
oHtml := oProcess:oHTML	
oProcess:oHTML:ValByName('DATA',dDataBase)
oHTML:ValByName('MOTIVO', _cMotivo)
oHTML:ValByName('EMISSAO',SF2->F2_EMISSAO)
oHTML:ValByName('SERIE',SF2->F2_SERIE)
oHTML:ValByName('DOC',SF2->F2_DOC)	
oHTML:ValByName('VALOR',SF2->F2_VALMERC)
		
Dbselectarea("SC5")

//Claudino Domingues - I1802-451 - 22/02/2018
//Na SC5 após a virada de versão apagou o indice que tinha referente a Nota+Serie, foi criado um novo indice. 
//SC5->( Dbsetorder(5) ) -> Indice antigo
dbOrderNickname("XNFSERIE") // C5_FILIAL + C5_NOTA + C5_SERIE
//If  SC5->( dbSeek( xFilial('SC5') + SF2->F2_DOC + SF2->F2_SERIE) )
If  SC5->(dbSeek(xFilial('SC5') + SF2->F2_DOC))
	oHTML:ValByName('PEDIDO',SC5->C5_NUM)
	// Tratamento para pedido mae
	SC5->(RecLock( "SC5", .F. ))
	SC5->C5_OK := ' ' 
	SC5->C5_REIMP := 0
	SC5->(MsUnLock())
EndIf

cCodVend := RTrim(GetAdvFVal("SA3","A3_COD",xFilial("SA3")+SF2->F2_VEND1,1,""))
cNomVend := RTrim(GetAdvFVal("SA3","A3_NOME",xFilial("SA3")+SF2->F2_VEND1,1,""))
oHTML:ValByName('VEND',cCodVend +" / "+ cNomVend) 
		
cCodSup := RTrim(GetAdvFVal("SA3","A3_SUPER",xFilial("SA3")+SF2->F2_VEND1,1,""))
If !Empty(cCodSup)
	cNomSup := RTrim(GetAdvFVal("SA3","A3_NOME",xFilial("SA3")+cCodSup,1,""))
	oHTML:ValByName('SUPERV',cCodSup +" / "+ cNomSup)
EndIf
		
cCodGer := RTrim(GetAdvFVal("SA3","A3_GEREN",xFilial("SA3")+SF2->F2_VEND1,1,""))
If !Empty(cCodGer)
	cNomGer := RTrim(GetAdvFVal("SA3","A3_NOME",xFilial("SA3")+cCodGer,1,""))
	oHTML:ValByName('GEREN',cCodGer +" / "+ cNomGer)
EndIf
			
If !Empty(_cLista)
	oProcess:cBCc := _cLista                     
	oProcess:Start()
	oProcess:Finish()
EndIf 

RestArea(aAreaSC5) 

return