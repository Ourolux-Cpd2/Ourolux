#INCLUDE "PROTHEUS.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FA070TIT  ºAutor  ³Eletromega          º Data ³  05/16/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Ponto de entrada FA070TIT chamado logo apos a confirmaçao  º±±
±±º          ³ da Baixa.                                                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP10                                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

/*
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Somente o usuario Administrador pode digitar data de baixa³
//³ou data de credito maior do que a data base.              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/

User Function FA070TIT()

Local lRet     := .F.
Local nNumDias := 10
//Local cUser    := Upper(Rtrim(cUserName))
//Local lDtOk    := .F.  // Claudino 08/07/16

/*
Claudino 10/05/16 - Chamado I1604-2235
Regra:
- A liderança (Denise, Margareth, Fábio e Paulo) tem acesso para baixar em todas as contas, inclusive NCC e RA;
- A analista do contas a receber (Alessandra e agora a Luciane) tem acesso somente para baixas no Bradesco e não tem acesso para baixar NCC e RA.
*/
// Função UsrRetName esta retornando o nome completo na P12, foi substituida pela variavel cUserName - Claudino 26/07/2017
//If !(Upper(UsrRetName(__cUserId)) $ GetMv("FS_DIRETOR")) 
If !(Upper(Alltrim(cUserName)) $ GetMv("FS_DIRETOR"))
	
	/*
	Claudino 08/07/16
	If (DBAIXA  >= dDataBase - nNumDias .And. DBAIXA  <= dDataBase) .And.;  
		(DDTCREDITO >= dDataBase - nNumDias .And. DDTCREDITO <= dDataBase) 
		lDtOk := .T.
	EndIf
	*/
	
	// Função UsrRetName esta retornando o nome completo na P12, foi substituida pela variavel cUserName - Claudino 26/07/2017
	//If (Upper(UsrRetName(__cUserId)) $ GetMv("FS_NOVLDBX"))
	If (Upper(Alltrim(cUserName)) $ GetMv("FS_NOVLDBX"))
		lRet := .T.
	Else	
		// Função UsrRetName esta retornando o nome completo na P12, foi substituida pela variavel cUserName - Claudino 26/07/2017
		//If (Upper(UsrRetName(__cUserId)) $ GetMv("FS_ANALICR"))
		If (Upper(Alltrim(cUserName)) $ GetMv("FS_ANALICR"))
			If CBANCO == '237' .And. !(SE1->E1_TIPO $ "NCC|RA")
				If CMOTBX <> 'CHEQUE'	
					lRet := .T.				
			    Else
			    	ApMsgStop("Usuario sem permissão para baixar Motivo CHEQUE! Favor verificar com o seu gestor.","FA070TIT")	
			    EndIf
			Else
				// Função UsrRetName esta retornando o nome completo na P12, foi substituida pela variavel cUserName - Claudino 26/07/2017
				//If CBANCO == 'MER' .And. (Upper(UsrRetName(__cUserId)) $ GetMv("FS_MERCHAN")) 
				If CBANCO == 'MER' .And. (Upper(Alltrim(cUserName)) $ GetMv("FS_MERCHAN"))
					If !(SE1->E1_TIPO $ "NCC|RA") .And. CMOTBX <> 'CHEQUE'
						lRet := .T.
				    Else
				    	ApMsgStop("Usuario sem permissão para baixar NCC/RA ou Motivo CHEQUE! Favor verificar com o seu gestor.","FA070TIT")
				    EndIf
				Else
					// Claudino - 29/08/16 - I1608-1524
					// Função UsrRetName esta retornando o nome completo na P12, foi substituida pela variavel cUserName - Claudino 26/07/2017
					//If CBANCO == '237' .And. SE1->E1_TIPO $ 'NCC|RA' .And. CMOTBX $ 'DESC COMER|RAPPEL' .And. (Upper(UsrRetName(__cUserId)) $ GetMv("FS_BXRPDEC"))
					If CBANCO == '237' .And. SE1->E1_TIPO $ 'NCC|RA' .And. CMOTBX $ 'DESC COMER|RAPPEL' .And. (Upper(Alltrim(cUserName)) $ GetMv("FS_BXRPDEC"))
						lRet := .T.
					Else
						ApMsgStop("Usuario sem permissão para baixar NCC/RA ou Banco/Motivo não permitido! Favor verificar com o seu gestor.","FA070TIT")
					EndIf
				EndIf
			EndIf
		Else
			ApMsgStop("Usuario sem permissão para executar essa operação! Favor verificar com o seu gestor.","FA070TIT")
		EndIf		
	EndIf		

Else
	//lRet := lDtOk := .T.  // Claudino 08/07/16
	lRet := .T.
EndIf

/*
Claudino 08/07/16
If !lDtOk
	ApMsgStop('Data nao permitida!', 'FA070TIT')
EndIf
*/

/*
//Regra Antiga - Claudino 10/05/16

Local lRet  := .F.
Local lDtOk := .F.
Local nNumDias := 10
Local cUser    := Upper(Rtrim(cUserName))

If !(cUser $ 'ROBERTO.CARLOS.SUMAIA.ADMINISTRADOR')
	
	If (DBAIXA  >= dDataBase - nNumDias .And. DBAIXA  <= dDataBase) .And.;  
		(DDTCREDITO >= dDataBase - nNumDias .And. DDTCREDITO <= dDataBase) 
		lDtOk := .T.
	EndIf
     
   	If SM0->M0_CODIGO = '01' .And. SM0->M0_CODFIL = '01' .And. ;
		(CBANCO = '237' .And. CAGENCIA = '3381' .And. CCONTA $ '0000310360.00001353098') 
 		lRet := .T.
	ElseIf SM0->M0_CODIGO = '01' .And. SM0->M0_CODFIL = '02' .And. ;
		(CBANCO = '237' .And. CAGENCIA = '3381' .And. CCONTA = '0001353209')  
		lRet := .T.                    
	ElseIf SM0->M0_CODIGO = '02' .And. SM0->M0_CODFIL = '00' .And. ;
		(CBANCO = '237' .And. CAGENCIA = '3381' .And. CCONTA = '0000016055')  
		lRet := .T.		
	EndIf
	
	// Alteração Claudino, liberação para Lourdes e Denise(Financeiro) 20-03-2012 //
    If cUser $ 'COBRANCA3.GERENCIAFIN.COBRANCA2.CREDITO1.CREDITO2.COBRANCA4.FINANCEIRO1.SUPERVISAOFIN.COBRANCA1.COORDFIN1.COORDFIN2'                               
		If CBANCO $ 'CX1.000.DES'                                   
			lRet := .T.                                                
		//Liberação realizada atraves do chamado I1511-1615 - Claudino 26/11/15
		ElseIf (CBANCO == '017' .And. Alltrim(CAGENCIA) == '11894' .And. Alltrim(CCONTA) == '259071') .Or. ;
				(CBANCO == '237' .And. Alltrim(CAGENCIA) == '3381' .And. CCONTA $ '0000310360.00001353098.0001353209') .Or. ;
				(CBANCO == '341' .And. Alltrim(CAGENCIA) == '0190' .And. Alltrim(CCONTA) == '65267') .And. ;
				CMOTBX == 'CHEQUE' .And. cUser $ 'COORDFIN1.COBRANCA3.SUPERVISAOFIN.GERENCIAFIN'
				lRet := .T.
		Endif                                                          
    Endif
    
    // Alteração Claudino, liberação para Lourdes e Denise(Financeiro) 20-03-2012 //
    If cUser $ 'COBRANCA3.COBRANCA.FINANCEIRO.CREDITO2.CREDITO1.SUPERVISAOFIN.FINANCEIRO1.COORDFIN1.COORDFIN2'                               
		If CBANCO $ '237' .And. ;
			CCONTA $ '0001353101.0000002149.0001616056.0000021490'                                    
			lRet := .T.                                                
		Endif                                                          
    Endif
    
    // Alteração COBRANCA 1//
    If cUser $ 'COBRANCA1' .And.;                               
		CCONTA $ '0001353101.0000002149.0000000000'                                    
		lRet := .T.                                                		                                                          
    Endif
    
    //Liberação realizada atraves do chamado I1505-1693 - DENNIS 27/05/15
    If cUser $ 'COBRANCA2' .And.;                               
		CCONTA $ '0001353101.00000021490'
		lRet := .T.                                                                                                          
    Endif 

Else

	lRet := lDtOk := .T.

EndIf

If !lRet 
	ApMsgStop('Banco nao permitido!', 'FA070TIT')
ElseIf !lDtOk
	ApMsgStop('Data nao permitida!', 'FA070TIT')
EndIf 
*/

//Return (lRet .And. lDtOk )  // Claudino 08/07/16
Return (lRet)