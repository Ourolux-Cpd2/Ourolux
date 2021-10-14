#include 'protheus.ch'
#include 'parmtype.ch'

//--------------------------------------------------------------------
/*/{Protheus.doc} FTOUA018
Integração de carga combinada
@author Ghidini Consulting
@since 07/02/2020
@version 1.0
/*/
//--------------------------------------------------------------------

User Function TESTE018()

	U_FTOUA018(.F.,.F.,"","","01","01")
	
Return(Nil)

User function FTOUA018(lReprocess, lLote, cIdReg, cIdPZC, cEmpPrep, cFilPrep)

Local aHeader       := {"Content-Type: application/json"}
Local cToken 		:= ""
Local aRegs         := {}
Local aPedidos		:= {}
Local nX
Local nY
Local oEmbarque     := Nil
Local aEmpSm0     	:= {}
Local nPosSM0		:= 0
Local lErro			:= .F.

Default lLote		:= .F.
Default lReprocess	:= .F.
Default cIdReg		:= ""
Default cIdPZC		:= ""	

Private cIdEnt      := ""
Private cError      := ""

	RpcSetEnv(cEmpPrep, cFilPrep)
       
	//Requisicao do acesso
	oREST := FTOUA003():New()
	oREST:RESTConn() 
	lReturn := oRest:lRetorno
	cToken  := oREST:cToken	
	
	If !lReturn
        
        Conout("Falha na autenticação Transpofrete")
        
    Else
		
		aRequest := U_ResInteg("000017", "", aHeader, , .T.,cToken )

        aRegs := aRequest[2]:Embarques

		aEmpSm0	:= FwLoadSM0()

		aCriaServ := U_MonitRes("000017", 1, len(aRegs))
		cIdPZB 	  := aCriaServ[2]

        For nX := 1 to len(aRegs)

            cJson := '{'
            cJson += '"embarque": "' + cValToChar(aRegs[nX]) + '"'
            cJson += '}'
            
            aRequest := U_ResInteg("000018", cJson, aHeader, , .T., cToken )

            oEmbarque := aRequest[2]:Embarque

			aPedidos	:= {}
			lErro 		:= .F.

			//Guarda os pedidos
			For nY := 1 to len(oEmbarque:Documentos)

				lCancelado := IIF(oEmbarque:SITUACAO == 3, .T., .F.)

				//Localiza codigo da filial.
				nPosSM0 := aScan(aEmpSm0, {|x| Alltrim(x[18]) == oEmbarque:Documentos[nY]:cnpjunidade })

				If AttIsMemberOf(oEmbarque, "Tabela")
					AADD(aPedidos, {aEmpSm0[nPosSm0][2] + StrZero(oEmbarque:Documentos[nY]:numero,6), oEmbarque:CNPJTRANSPORTADORAFILIAL, oEmbarque:Tabela, aRegs[nX], oEmbarque:OIDEMBARQUE, lCancelado} )
				Else
					AADD(aPedidos, {aEmpSm0[nPosSm0][2] + StrZero(oEmbarque:Documentos[nY]:numero,6), oEmbarque:CNPJTRANSPORTADORAFILIAL, "Sem tabela", aRegs[nX], oEmbarque:OIDEMBARQUE, lCancelado} )
				EndIf
				
			Next nY

			DBSelectArea("SC5")
			SC5->(DBSetOrder(1))

			DBSelectArea("PR1")
			PR1->(DBSetOrder(2))

			DbSelectArea("SA4")
			SA4->(DBSetOrder(3))
						
			//Atualiza transportadora nos pedidos e libera eles para faturamento
			For nY := 1 to len(aPedidos)

				//Localiza transportadora
				If !SA4->(DbSeek(xFilial("SA4") + aPedidos[nY][2]))

					lErro := .T.
					U_MonitRes("000017", 2, , cIdPZB, "Transportadora não cadastrada.", .F., aPedidos[nY][2], "", aRequest[3], "Transportadora não cadastada.", lReprocess, lLote, cIdPZC)
					Loop

				EndIf
				
				If SC5->(DBSeek(aPedidos[nY][1]))

					SC5->(RecLock("SC5",.F.))

						SC5->C5_TRANSP 		:= SA4->A4_COD
						SC5->C5_XTFEMBQ		:= IIf(aPedidos[nY][6], 0, aPedidos[nY][5])

					SC5->(MSUnlock())

				EndIf

				If PR1->(DBSeek(xFilial("PR1") + "SC5" + aPedidos[nY][1]))

					PR1->(RecLock("PR1",.F.))

						PR1->PR1_STINT	:= "I"
						PR1->PR1_TIPREQ	:= "3"

					PR1->(MSUnlock())

				EndIf

				U_MonitRes("000017", 2, , cIdPZB, "Pedido atualizado com sucesso.", .T., aPedidos[nY][2], "", aRequest[3], aPedidos[nY][3], lReprocess, lLote, cIdPZC)

				//Se acabou os dados e não tem erro
				If !lErro .And. nY == len(aPedidos)
					
					cJson := '{
					cJson += '"oid": "' + cValToChar(aPedidos[nY][5]) + '",'
					cJson += '"statusIntegracao":0,'
					cJson += '"codigoMensagem":102,'
					
					If aPedidos[nY][6]
						cJson += '"mensagem":"Embarque cancelado com sucesso"'
					Else
						cJson += '"mensagem":"Embarque integrado com sucesso"'
					EndIf
					
					cJson += '}'

					aRequest := U_ResInteg("000019", cJson, aHeader, , .T., cToken )

				EndIf

			Next nY
        
        Next nX

		//Finaliza o processo na PZB
		U_MonitRes("000017", 3, , cIdPZB, , .T.) 
        
	Endif 
	
Return(Nil)
