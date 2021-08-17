#Include "Protheus.ch"
#Include "RwMake.ch"
#Include "TopConn.ch"
#Include "TbiConn.ch"
#Include "TbiCode.ch"
#Include "ParmType.ch"

#Define STR_PULA    Chr(13) + Chr(10)
#Define COMP_DATE	"20191209"

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} F240TDOK
Rotina para confirmação de liberacao de cnab.
Utilizar o controle de alcadas controlado por RCB e RCC.

@type 		Function
@author 	Maurício Aureliano
@since 		16/05/2018
@version 	P12

@obs		I1705-895 - Segurança do sistema urgente
 
@return lRet
/*/    
//-------------------------------------------------------------------------------------
User Function F240TDOK

	Local peAliasSE2:= paramixb[2]
	Local aTit 		:= {}
	Local lAltera	:= .F.
	Local lRetorno	:= .T.
	Local i
		
	If .Not. Empty( paramixb[1] )

		While !(peAliasSE2)->(Eof())
		
			// Atualiza Portador - 1ª vez
			If Empty( e2_xporta )
							
				cQryUpd := " UPDATE " + RetSqlName("SE2")
				cQryUpd += " SET E2_XPORTA = '" + sa6->a6_cod   + "'"
				cQryUpd += " ,E2_XBLQAGE = '" + sa6->a6_agencia + "'"
				cQryUpd += " ,E2_XBLQDAG = '" + sa6->a6_dvage   + "'"
				cQryUpd += " ,E2_XBLQCON = '" + sa6->a6_numcon  + "'"
				cQryUpd += " ,E2_XBLQDCO = '" + sa6->a6_dvcta   + "'"
				cQryUpd += " ,E2_XUSRID =    '" + __cUserId     + "'"
				cQryUpd += " WHERE"
				cQryUpd += " E2_PREFIXO =     '" + e2_prefixo   + "'"
				cQryUpd += " AND E2_NUM =     '" + e2_num       + "'"
				cQryUpd += " AND E2_PARCELA = '" + e2_parcela   + "'"
				cQryUpd += " AND E2_TIPO =    '" + e2_tipo      + "'"
				cQryUpd += " AND E2_FORNECE = '" + e2_fornece   + "'"
				cQryUpd += " AND E2_LOJA =    '" + e2_loja      + "'"
					
				TcSqlExec(cQryUpd)

				If TcSqlExec(cQryUpd) < 0
					Hs_MsgInf(TcSqlError(),"Erro Query","F240TDOK")
					Exit
				EndIf

				lRetorno := .T.
		
			Else
		
				// Bloqueio - Portador
				If lRetorno
					If Trim(e2_xporta) <> Trim(sa6->a6_cod)
						// Cria array com títulos de diferentes portadores
						Aadd( aTit,e2_prefixo,e2_num,e2_parcela,e2_tipo,e2_fornece,e2_loja)
						lAltera := .T.
					Endif 		// Portador diferente?
				EndIf		// If lRetorno
			EndIf 		// Titulo Liberado
			(peAliasSE2)->(dbSkip())
		End
	EndIf

	// Maurício Aureliano - 12/07/2018
	// Nova tratativa solicitada pelo operacional
	If lAltera
		If MsgYesNo( 'Atenção! Houve alteração de portador em alguns títulos. Deseja continuar?', 'F240TDOK' )
			lRetorno := .T.
		Else
			lRetorno := .F.
			For i := 1 To Len(aVet)
			
				cQryUpd := " UPDATE " + RetSqlName("SE2")
				cQryUpd += " SET E2_XBLQPOR = 'S'" // Bloqueio = SIM
				cQryUpd += " WHERE"
				cQryUpd += " E2_PREFIXO = '" + e2_prefixo + "'"
				cQryUpd += " AND E2_NUM = '" + e2_num + "'"
				cQryUpd += " AND E2_PARCELA = '" + e2_parcela + "'"
				cQryUpd += " AND E2_TIPO = '" + e2_tipo + "'"
				cQryUpd += " AND E2_FORNECE = '" + e2_fornece + "'"
				cQryUpd += " AND E2_LOJA = '" + e2_loja + "'"
				TcSqlExec(cQryUpd)
					
				If TcSqlExec(cQryUpd) < 0
					Hs_MsgInf(TcSqlError(),"Erro Query","F240TDOK")
					Exit
				EndIf
												
			Next i
			/*
			If MsgYesNo( 'Deseja bloquear os títulos com portadores diferentes?', 'F240TDOK' )				
			
					
			ApMsgStop("Título " + Trim(e2_Num) + " será bloqueado por regra de negócio. Favor solicitar liberação!","F240TDOK")
			*/					
		Endif 		// Titulo sofre alteração
	EndIf

Return lRetorno
