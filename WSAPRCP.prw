#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
#include "TOPCONN.CH"
#include "TBICONN.CH"
#Include "RESTFUL.CH"

#DEFINE COMP_DATE  "20200428" 

/*

ZX_STATUS == "A"  //Aprovado
ZX_STATUS == "R"  //Reprovado
ZX_STATUS == "E"  //Enviado
ZX_STATUS == "P"  //Pendente de envio


ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ WSAPRCP  ºAutor  ³ Rodrigo Nunes	     º Data ³  28/04/20   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Programa roda pelo WebService para aprovar Titulos a Pagar º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Ourolux                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß

// http://187.94.63.180:10611/rest/WSAPRCP/SIM/01/000001/000001
*/        

WSRESTFUL WSAPRCP DESCRIPTION "Aprovacao de Titulos a Pagar"

WSMETHOD GET  DESCRIPTION "WSAPRCP" WSSYNTAX "Parametro || /aprovador/recnose2/aprovado"

END WSRESTFUL
                                                 
WSMETHOD GET WSRECEIVE cCodigo WSSERVICE WSAPRCP

::SetContentType("application/cJson")

If Len(::aURLParms) > 1

    ws_aprov     := ::aURLParms[1]
    ws_recnose2  := ::aURLParms[2]
    ws_recnoszx  := ::aURLParms[3]
    ws_aprovado  := ::aURLParms[4]

    cData := dtoc(ddatabase)
    cHora := TIME()
    cQryUPD	:= ""

    conout("")
    conout("")
    conout("---------------------------------------------------------------------------")
    conout("Data: "+cData)
    conout("Hora: "+cHora)
    conout("---------------------------------------------------------------------------")
    conout("Aprovado: "+ws_aprovado)
    conout("Recno SE2: "+ws_recnose2)
    conout("Recno SE2: "+ws_recnoszx)
    conout("Aprovador: "+ws_aprov)
    conout("Versão: 1.2")
    conout("---------------------------------------------------------------------------")

    dbSelectArea("SE2")
    SE2->(dbGoTo(Val(ws_recnose2)))

    dbSelectArea("SZX")
    SZX->(dbGoTo(Val(ws_recnoszx)))

    cMENSAGEM:= ""

    dbSelectArea("SAK")
	If SAK->(dbSeek(xFilial("SAK")+ws_aprov))
		cUsrApr := AK_USER
	EndIf

	PswOrder(1)
	PswSeek(cUsrApr,.T.)
	aUsuario := PswRet(1)

    If aUsuario[1,17]
        cMENSAGEM := "Usuario bloqueado no sistema"
        cRETORNO := '{"status":"ok","msg":"'+cMENSAGEM+'","pedido":"'+SE2->E2_NUM+'"}'
        ::SetResponse( cRETORNO )
        Return .T.
    EndIf

    If SZX->ZX_STATUS == "A"
        
        dbSelectArea("SAK")
	    If SAK->(dbSeek(xFilial("SAK")+ws_aprov))
		    cNomeApr := AK_NOME
	    EndIf
        
        cMENSAGEM := "Titulo ja Liberado anteriormente pelo usuario: " + Alltrim(cNomeApr)
        cRETORNO := '{"status":"ok","msg":"'+cMENSAGEM+'","pedido":"'+SE2->E2_NUM+'"}'
        ::SetResponse( cRETORNO )
        Return .T.
    ElseIf SZX->ZX_STATUS == "R"
        
        dbSelectArea("SAK")
        If SAK->(dbSeek(xFilial("SAK")+ws_aprov))
		    cNomeApr := AK_NOME
	    EndIf
        
        cMENSAGEM := "Titulo ja Reprovado anteriormente pelo usuario: " + Alltrim(cNomeApr)
        cRETORNO := '{"status":"ok","msg":"'+cMENSAGEM+'","pedido":"'+SE2->E2_NUM+'"}'
        ::SetResponse( cRETORNO )
        Return .T.
    EndIf

    If alltrim(ws_aprovado) == 'SIM'
        cQryUPD	:= " UPDATE " + RETSqlName("SZX") + " SET ZX_STATUS = 'A' "
        cQryUPD	+= " ,ZX_DATALIB =  " + DTOS(dDataBase)
        cQryUPD	+= " ,ZX_LIBAPRO =  '" + alltrim(ws_aprov)     + "' "
        cQryUPD	+= " WHERE 	ZX_RECSE2    = '" + alltrim(ws_recnose2) + "' "
        cQryUPD	+= " AND D_E_L_E_T_ <> '*' "

        conout("Query Update SIM SZX->" + cQryUPD)

        IF TCSQLExec(cQryUPD) >= 0
            Reclock("SE2",.F.)
            SE2->E2_APROVA := ws_aprov
            SE2->E2_DATALIB := dDataBase
            SE2->(MsUnlock())
            cMENSAGEM := "Titulo Liberado pelo usuario"
        Else
            cMENSAGEM := "Titulo nao liberado(erro update)"
        EndIf
    ElseIf alltrim(ws_aprovado) == 'NAO'
        cQryUPD	:= " UPDATE " + RETSqlName("SZX") + " SET ZX_STATUS = 'R' "
        cQryUPD	+= " ,ZX_DATALIB =  " + DTOS(dDataBase)
        cQryUPD	+= " ,ZX_LIBAPRO =  '" + alltrim(ws_aprov)     + "' "
        cQryUPD	+= " WHERE 	ZX_RECSE2    = '" + alltrim(ws_recnose2) + "' "
        cQryUPD	+= " AND D_E_L_E_T_ <> '*' "

        conout("Query Update NAO SZX->" + cQryUPD)
                        
        If TCSQLExec(cQryUPD) >= 0
            cMENSAGEM := "Titulo Reprovado pelo usuario"
        Else
            cMENSAGEM := "Titulo nao Reprovado(erro update)"
        EndIf
    EndIF

    cRETORNO := '{"status":"ok","msg":"'+cMENSAGEM+'","pedido":"'+SE2->E2_NUM+'"}'
    ::SetResponse( cRETORNO )

else

    conout("Mensagem: Chamada sem parametros para processamento")
    conout("--------------------------------------------------------------------------")

    cRETORNO := '{"status":"sem parametros","msg":"","pedido":""}'
    ::SetResponse( cRETORNO )
                    
endif

Return .T.
                    



