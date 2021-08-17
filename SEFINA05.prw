#Include 'Protheus.ch'

//--------------------------------------------------------------------
/*/{Protheus.doc} SEFINA05
Programa de consulta das consultas ao Serasa

@author TOTVS Protheus
@since  02/06/2015
@obs    Sensus Tecnologia - Fabricio Eduardo Reche
@version 1.0
/*/
//--------------------------------------------------------------------
User Function SEFINA05()
	
	Local oSerasa
	Local cCgc			:= RetTitle("A1_CGC")
	Local cTelefone	:= Alltrim(SA1->A1_DDI+" "+SA1->A1_DDD+" "+SA1->A1_TEL)
	
	/* APENAS PARA REALIZAR USO DA BASE HOMOLOGAÇÃO */
	//Local aCnpj	:= {"00000003000125","00002220000154","00002201000128","00002333000150","00002339000127","00002684000160","00002892000160","00002914000191","00002919000114","00003012000170","00003097000196"} 
	//Local aCnpj		:= {"00000000191","00000000272","00000000353","00000000434","00000000515"}
	/* FIM */
	
	Private oLbx
	Private aHeader	:= {"Dt.Consulta", "Hr.Consulta", "Produto"}
	Private aCols		:= {}
	/* HABILITAR QUANDO COLOCAR NO CLIENTE */
	Private _cCgc 	:= A1_CGC
	/* FIM */
	
	dbSelectArea("SA1")
	dbSetOrder(3)
	dbSeek(xFilial('SA1')+_cCgc)
		
//dDataFim := "13/06/2018"

//If (CtoD(dDataFim) > dDatabase)
	
	/* APENAS PARA REALIZAR USO DA BASE HOMOLOGAÇÃO */
	/*
	Private _cCgc 	:= ''
	if alltrim(SA1->A1_COD) == '000001'
		_cCgc := aCnpj[1]
	elseif alltrim(SA1->A1_COD) == '000002'
		_cCgc := aCnpj[2]
	elseif alltrim(SA1->A1_COD) == '000003'
		_cCgc := aCnpj[3]
	elseif alltrim(SA1->A1_COD) == '000004'
		_cCgc := aCnpj[4]
	elseif alltrim(SA1->A1_COD) == '000005'
		_cCgc := aCnpj[5]
	elseif alltrim(SA1->A1_COD) == '000006'
		_cCgc := aCnpj[6]
	elseif alltrim(SA1->A1_COD) == '000007'
		_cCgc := aCnpj[7]
	elseif alltrim(SA1->A1_COD) == '000008'
		_cCgc := aCnpj[8]
	elseif alltrim(SA1->A1_COD) == '000009'
		_cCgc := aCnpj[9]
	elseif alltrim(SA1->A1_COD) == '000010'
		_cCgc := aCnpj[10]
	elseif alltrim(SA1->A1_COD) == '000011'
		_cCgc := aCnpj[11]
		
	endif
	*/
	/* FIM */
	
	_cCgc   := alltrim(_cCgc) + space(14 - len(alltrim(_cCgc)))
	
	/* Consulta ao banco de dados local */
	_cAlias := GetNextAlias()
	BeginSql Alias _cAlias
		column ZAB_DTCONS as Date
	
		SELECT ZAB_TIPO, ZAB_CNPJ, ZAB_DTCONS, ZAB_HRCONS, ZAB_PRODUT
		FROM %Table:ZAB% ZAB
		WHERE ZAB.%NotDel%
		AND ZAB_CNPJ = %exp:_cCgc%
		GROUP BY ZAB_TIPO, ZAB_CNPJ, ZAB_DTCONS, ZAB_HRCONS, ZAB_PRODUT
		ORDER BY ZAB_DTCONS DESC, ZAB_HRCONS DESC
		
	EndSql
	(_cAlias)->(dbGoTop())
	While (_cAlias)->(!eof())
		aadd(aCols, {(_cAlias)->ZAB_DTCONS, (_cAlias)->ZAB_HRCONS, (_cAlias)->ZAB_PRODUT})	
		(_cAlias)->(dbSkip())
	End
	if empty(aCols)
		aadd(aCols,{ctod(''), '', ''})
	endif
	/* Fim */
	
	DEFINE MSDIALOG oSerasa FROM	09,0 TO 30,68 TITLE "Integração SERASA" OF oMainWnd
		
		@ 001,002 TO 043, 267 OF oSerasa	PIXEL
		//@ 130,002 TO 154, 114 OF oSerasa	PIXEL
		//@ 130,121 TO 154, 267 OF oSerasa	PIXEL
		
		@ 004,005 SAY "Codigo" SIZE 025,07          OF oSerasa PIXEL
		@ 012,004 MSGET SA1->A1_COD      SIZE 070,09 WHEN .F. OF oSerasa PIXEL
		
		@ 004,077 SAY "Loja" SIZE 020,07          OF oSerasa PIXEL
		@ 012,077 MSGET SA1->A1_LOJA     SIZE 021,09 WHEN .F. OF oSerasa PIXEL
			
		@ 004,100 SAY "Nome" SIZE 025,07 OF oSerasa PIXEL
		@ 012,100 MSGET SA1->A1_NOME     SIZE 150,09 WHEN .F. OF oSerasa PIXEL
		
		@ 023,005 SAY cCGC    SIZE 025,07 OF oSerasa PIXEL
		@ 030,004 MSGET SA1->A1_CGC      SIZE 070,09 PICTURE StrTran(PicPes(SA1->A1_PESSOA),"%C","") WHEN .F. OF oSerasa PIXEL
		
		@ 023,077 SAY "Telefone" SIZE 025,07 OF oSerasa PIXEL
		@ 030,077 MSGET cTelefone	       SIZE 060,09 WHEN .F. OF oSerasa PIXEL
		
		@ 023,141 SAY RetTitle("A1_VENCLC")  SIZE 035,07 OF oSerasa PIXEL
		@ 030,141 MSGET SA1->A1_VENCLC       SIZE 060,09 WHEN .F. OF oSerasa PIXEL HasButton
		
		@ 023,206 SAY "Vendedor" SIZE 035,07 OF oSerasa PIXEL
		@ 030,206 MSGET SA1->A1_VEND  	 SIZE 053,09 WHEN .F. OF oSerasa PIXEL
		
		oLbx := RDListBox(3.5, .42, 264, 90, aCols, aHeader,{80,80,80})   
		oLbx:bLDblClick := {|| Pocnsdet() }
		
		@ 143,120 BUTTON "Sair" SIZE 60,12 FONT oSerasa:oFont ACTION oSerasa:End() 	OF oSerasa PIXEL
		
	ACTIVATE MSDIALOG oSerasa CENTERED
//Else
//	MSGAlert("Favor entrar em contato com a Sensus. Este programa expirou!!!")
//EndIf
Return()


/* Elabora a tela para apresentar a consulta selecionada */
Static Function Pocnsdet()
	
	Local oSerasaDet
	
	Private nTipo		:= 0	//1 - Credit Bureau, 2 - Crednet, 3 - Relato
	Private aView		:= {}
	Private aTitles	:= {}
	Private cView1, cView2, cView3, cView4, cView5, cView6, cView7, cView8, cView9, cView10, cView11
	Private oSay1, oSay2, oSay3, oSay4, oSay5, oSay6, oSay7, oSay8, oSay9, oSay10, oSay11
	
	if alltrim(aCols[oLbx:nAt][3]) == 'CREDIT BUREAU'
		nTipo		:= 1
		//aTitles	:= {"Identificação", "Partic.Societária", "Reg.Consultas", "Cheques", "Anotações", "End./Fones Alternativos"}
		aTitles	:= {"Identificação", "Reg.Consultas", "Anotações", "End./Fones Alternativos"}
	elseif alltrim(aCols[oLbx:nAt][3]) == 'CREDNET'
		nTipo		:= 2
		aTitles	:= {"Confirmei" , "Pend.Interna/Grupo", "Pend.Financeira", "Protesto Estadual/Nacional", "CH s/Fundos Varejo", "CH s/Fundos BACEN", "End. CEP", "End. Fone", "Ult.Fones", "Reg.Consultas"}
	elseif alltrim(aCols[oLbx:nAt][3]) == 'RELATO'
		nTipo		:= 3
		aTitles	:= {"Dados Cadastrais", "Anotações", "Controle Societário", "Quadro Administrativo", "Participações", "Fornecedores", "Informações de Passagem e Alerta","Cálculo do Riskscoring"}
	else
		return
	endif
	
	//Resolucao de Tela 
	aSize		:= MsAdvSize( .F. )
	aObjects := {} 
	AAdd( aObjects, { 100, 35,  .t., .f., .t. } )
	AAdd( aObjects, { 100, 100 , .t., .t. } )
	AAdd( aObjects, { 100, 50 , .t., .f. } )
	
	aInfo    := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 } 
	aPosObj  := MsObjSize( aInfo, aObjects) 
	
	oFont  := TFont():New('Tahoma',,-16,.T.,.T.)
	oFont0 := TFont():New('monospace',,-12,.T.)
	
	DEFINE MSDIALOG oSerasaDet FROM If( FlatMode(), 0, aSize[7] ),0 TO aSize[6],aSize[5] PIXEL TITLE "" STYLE nOR(WS_VISIBLE,WS_POPUP) //STYLE DS_MODALFRAME
		
		oSay:= TSay():New(08,10,{||'PRODUTO: ' + aCols[oLbx:nAt][3] + '   Consulta realizada em: ' + dtoc(aCols[oLbx:nAt][1]) + ' as ' + aCols[oLbx:nAt][2] + space(10) + alltrim(SA1->A1_NOME)},oSerasaDet,,oFont,,,,.T.,,,,10,,,,,,.F.)
		
		
		oFolder := TFolder():New(020,004,aTitles,{},oSerasaDet,,,, .T., .F.,aPosObj[1,3]+4,aPosObj[3,3]-27)
		oFolder:bChange	:= {|| stCnsFld(oFolder:nOption)} //Mudanca de folder
		
		oSButF := TButton():New(aPosObj[3,3],04,'Sair da Rotina',oSerasaDet,{|| oSerasaDet:End() },60,12,,,,.T.)
		
	ACTIVATE MSDIALOG oSerasaDet CENTER ON INIT (stCreatObj(), stCnsFld( 1 ))
	

Return


Static Function Poqrydet( _nFolder )


	Local nDigito1
	Local nDigito2, cNum, cNumero1 
	Local cCNPJ
	
	Default _nFolder := 1
	
	lPassou := .F.     
	lEntrou := .T.
	
	aV23000 := {}
	aV23090 := {}
	aV24000 := {}
	aV24001 := {}
	aV24090 := {}
	aV25000 := {}
	aV25001 := {}
	aV25090 := {}
	aV26090 := {}
	aV27090 := {}
	aV41000 := {}
	aV42000 := {}
	aV43000 := {}
	aV44003 := {}
	
	aV37001 := {}
	aV37002 := {}
	
	cPrd := alltrim(aCols[oLbx:nAt][3]) + space(15 - len(alltrim(aCols[oLbx:nAt][3])))
	ZAB->(dbSetOrder(1))
	ZAB->(dbSeek(xFilial('ZAB') + _cCgc + dtos(aCols[oLbx:nAt][1]) + aCols[oLbx:nAt][2] + cPrd, .T.))
	While ZAB->(!eof()) .and. ZAB->ZAB_FILIAL == xFilial('ZAB') .and.;
	                          ZAB->ZAB_CNPJ+dtos(ZAB->ZAB_DTCONS)+ZAB->ZAB_HRCONS+ZAB->ZAB_PRODUT == _cCgc + dtos(aCols[oLbx:nAt][1]) + aCols[oLbx:nAt][2] + cPrd
	
		//Se CREDIT BUREAU e IDENTIFICAÇÃO
		if nTipo == 1 .and. _nFolder == 1
			Do Case
		  /*	Case ZAB->ZAB_CODIGO == 'T999' .and. substr(ZAB->ZAB_TEXTO,1,3) <> '000'
					aadd(aView, 'Mensagem............: ' + substr(ZAB->ZAB_TEXTO,18,50))
					aadd(aView, '')
				Case ZAB->ZAB_CODIGO == 'ERRO'
					aadd(aView, 'Mensagem............: ' + substr(ZAB->ZAB_TEXTO,1,115))
					aadd(aView, '')
				Case ZAB->ZAB_CODIGO == 'A900'
					aadd(aView, 'Mensgem.............: ' + substr(ZAB->ZAB_TEXTO,40,90))   
					aadd(aView, '')                                                   */
				Case ZAB->ZAB_CODIGO == 'B001'
					_cSt := ''				
					if substr(ZAB->ZAB_TEXTO,98,1) == '2'
							_cSt := 'Regular       '
					elseif substr(ZAB->ZAB_TEXTO,98,1) == '6'
							_cSt := 'Suspenso      '
					elseif substr(ZAB->ZAB_TEXTO,98,1) == '9'
							_cSt := 'Cancelado     '
					elseif substr(ZAB->ZAB_TEXTO,98,1) == '8'
							_cSt := 'Novo (Regular)'
					elseif substr(ZAB->ZAB_TEXTO,98,1) == '0'
							_cSt := 'Não confirmado'
					Endif
					_cNSt := ''				
					if substr(ZAB->ZAB_TEXTO,111,1) == '2'
							_cNSt := 'Regular       '
					elseif substr(ZAB->ZAB_TEXTO,98,1) == '3'
							_cNSt := 'Pendente      '
					elseif substr(ZAB->ZAB_TEXTO,98,1) == '6'
							_cNSt := 'Suspensa      '
					elseif substr(ZAB->ZAB_TEXTO,98,1) == '9'
							_cNSt := 'Cancelada     '
					elseif substr(ZAB->ZAB_TEXTO,98,1) == '4'
							_cNSt := 'Nula          '
					elseif substr(ZAB->ZAB_TEXTO,98,1) == '0'
							_cNSt := 'Não confirmado'
					Endif
					if ZAB->ZAB_LINHA == '001' 
						aadd(aView, 'Grafia                                        | CPF         | RG              | Dt.Nasc.   | Cidade | Titular | Situação       | Ult.Alt.   | Situação')
					endif
					//                       grafia                        cpf                               rg                                     dt nasc                                                                 cidade                            titular                           situação                         ult alt                               situação
					aadd(aView, substr(ZAB->ZAB_TEXTO,1,45) + ' | ' + substr(ZAB->ZAB_TEXTO,46,11) + ' | ' + substr(ZAB->ZAB_TEXTO,57,15) + ' | ' + dtoc(stod( substr(ZAB->ZAB_TEXTO,72,8) )) + '   | ' + substr(ZAB->ZAB_TEXTO,80,4) + '   | ' + 	substr(ZAB->ZAB_TEXTO,84,1) + '       | ' + _cSt + ' | ' + dtoc(stod( substr(ZAB->ZAB_TEXTO,99,8) )) + '   | ' + _cNSt)
				Case ZAB->ZAB_CODIGO == 'B002'
					if ZAB->ZAB_LINHA == '001' 
						aadd(aView, '')
						aadd(aView, PadC(' [ DADOS CADASTRAIS ] ', 115, '-'))
						aadd(aView, 'Ult.Alteração | Dt.Nasc.   | Mãe                                           | Sexo | Tipo Ident.     | RG              | Órgão Emissor | Dt.Emissão | UF')
					endif
					aadd(aView, dtoc(stod( substr(ZAB->ZAB_TEXTO,4,8) )) + '      | ' + dtoc(stod( substr(ZAB->ZAB_TEXTO,12,8) )) + '   | ' + substr(ZAB->ZAB_TEXTO,20,45) + ' | ' + substr(ZAB->ZAB_TEXTO,65,1) + '    | ' + substr(ZAB->ZAB_TEXTO,66,15) + ' | ' + substr(ZAB->ZAB_TEXTO,81,15) + ' | ' + substr(ZAB->ZAB_TEXTO,96,5) + '         | ' + dtoc(stod( substr(ZAB->ZAB_TEXTO,101,8) )) + ' | ' + substr(ZAB->ZAB_TEXTO,109,2))
				Case ZAB->ZAB_CODIGO == 'B003'
					if ZAB->ZAB_LINHA == '001' 
						aadd(aView, '')
						aadd(aView, 'Estado Civil | Nr.Dep. | Escolaridade | Cid.Nasc.                 | UF Nasc. | CPF Conj.   | DDD Res | Fone Res | DDD Com | Fone Com | Ramal | Celular')
					endif        
					//estado civil                                        nr dep                                 escolaridade                               cid nasc                                    uf nasc                                       cpf conj                           ddd                                         fone                              ddd com                                          fone com                               ramal                             celu
					aadd(aView, substr(ZAB->ZAB_TEXTO,1,12) + ' | ' + substr(ZAB->ZAB_TEXTO,13,2) + '      | ' + substr(ZAB->ZAB_TEXTO,15,12) + ' | ' + substr(ZAB->ZAB_TEXTO,27,25) + ' | ' + substr(ZAB->ZAB_TEXTO,52,2) + '       | ' + substr(ZAB->ZAB_TEXTO,54,11) + ' | ' + substr(ZAB->ZAB_TEXTO,55,2) + '      | ' + substr(ZAB->ZAB_TEXTO,57,8) + ' | ' + substr(ZAB->ZAB_TEXTO,67,2) + '      | ' + substr(ZAB->ZAB_TEXTO,69,8) + ' | ' + substr(ZAB->ZAB_TEXTO,77,4) + '  | ' + substr(ZAB->ZAB_TEXTO,81,8))
				Case ZAB->ZAB_CODIGO == 'B004'
					aadd(aView, '')
					aadd(aView, 'Logradouro..........: ' + substr(ZAB->ZAB_TEXTO,1,30))
					aadd(aView, 'Número..............: ' + substr(ZAB->ZAB_TEXTO,31,5))
					aadd(aView, 'Complemento.........: ' + substr(ZAB->ZAB_TEXTO,36,10))
					aadd(aView, 'Bairro..............: ' + substr(ZAB->ZAB_TEXTO,46,20))
					aadd(aView, 'Cidade..............: ' + substr(ZAB->ZAB_TEXTO,66,25))
					aadd(aView, 'UF..................: ' + substr(ZAB->ZAB_TEXTO,91,2))
					aadd(aView, 'CEP.................: ' + substr(ZAB->ZAB_TEXTO,93,8))
					aadd(aView, 'Desde de............: ' + substr(ZAB->ZAB_TEXTO,101,6)) 
				 Case ZAB->ZAB_CODIGO == 'B352'			
					if ZAB->ZAB_LINHA == '001' 
						aadd(aView, '')
						aadd(aView, PadC(' [ PARTICIPAÇÃO SOCIETÁRIA ] ', 152, '-'))
						aadd(aView, 'Empresa                                 | CNPJ                 | Participação (%) | UF | Situação do CNPJ em:     | Desde:   | Ultima Atualização:')
					endif

					//Cálculo Digito Verificador CNPJ
					cNum := substr(ZAB->ZAB_TEXTO,41,8)
					cNumero1:= cNum + '0001'   
					
					nDigito1 := ((Val(substr(cNumero1,1,1)) * 6) + ;
					            (Val(substr(cNumero1,2,1)) * 7) + ;
					            (Val(substr(cNumero1,3,1)) * 8) + ;
					            (Val(substr(cNumero1,4,1)) * 9) + ;
					            (Val(substr(cNumero1,5,1)) * 2) + ;
					            (Val(substr(cNumero1,6,1)) * 3) + ;
					            (Val(substr(cNumero1,7,1)) * 4) + ;
					            (Val(substr(cNumero1,8,1)) * 5) + ;
					            (Val(substr(cNumero1,9,1)) * 6) + ;
					            (Val(substr(cNumero1,10,1)) * 7) +;
					            (Val(substr(cNumero1,11,1)) * 8) + ;
					            (Val(substr(cNumero1,12,1)) * 9)) % 11
					
					nDigito2 := ((Val(substr(cNumero1,1,1)) * 5) + ;
					            (Val(substr(cNumero1,2,1)) * 6) + ;
					            (Val(substr(cNumero1,3,1)) * 7) + ;
					            (Val(substr(cNumero1,4,1)) * 8) + ;
					            (Val(substr(cNumero1,5,1)) * 9) + ;
					            (Val(substr(cNumero1,6,1)) * 2) + ;
					            (Val(substr(cNumero1,7,1)) * 3) + ;
					            (Val(substr(cNumero1,8,1)) * 4) + ;
					            (Val(substr(cNumero1,9,1)) * 5) + ;
					            (Val(substr(cNumero1,10,1)) * 6) +;
					            (Val(substr(cNumero1,11,1)) * 7) + ;
					            (Val(substr(cNumero1,12,1)) * 8) + ;                     
					            (nDigito1 * 9)) % 11                                    
					 
					cCNPJ:=	(cNumero1 + cValToChar(nDigito1) +  cValToChar(nDigito2))  

				   	aadd(aView, substr(ZAB->ZAB_TEXTO,1,40) + '| ' + substr(cCNPJ,1,2)  + '.' + substr(cCNPJ,3,3) + '.' + substr(cCNPJ,6,3) +'/' + substr(cCNPJ,9,4) + '-' + substr(cCNPJ,13,2) + '   | ' + substr(ZAB->ZAB_TEXTO,50,3) + '.' + substr(ZAB->ZAB_TEXTO,53,1) + '            | ' + substr(ZAB->ZAB_TEXTO,54,2) + ' | ' + substr(ZAB->ZAB_TEXTO,76,23) + '  | ' + substr(ZAB->ZAB_TEXTO,103,2) +'/' + substr(ZAB->ZAB_TEXTO,99,4)  + '  | ' + substr(ZAB->ZAB_TEXTO,109,2) +'/' + substr(ZAB->ZAB_TEXTO,105,4))			
			EndCase                    
		
		//Se CREDIT BUREAU e REGISTRO DE CONSULTAS
		elseif nTipo == 1 .and. _nFolder == 2
			Do Case
				Case ZAB->ZAB_CODIGO == 'B353'
					aadd(aView, PadC(' [ REGISTRO DE CONSULTAS - RESUMO ] ', 146, '-'))
					aadd(aView, 'Total Consulta Cred.: ' + substr(ZAB->ZAB_TEXTO,1,3))
					aadd(aView, 'Ano/Mês Atual.......: ' + substr(ZAB->ZAB_TEXTO,4,6))
					aadd(aView, 'Qt.Cons.Cred. Atual.: ' + substr(ZAB->ZAB_TEXTO,10,3))
					aadd(aView, 'Qt.Cons.Cred.Mes Ant: ' + substr(ZAB->ZAB_TEXTO,13,3))
					aadd(aView, 'Qt.Cons.Cred.Mes Ant: ' + substr(ZAB->ZAB_TEXTO,16,3))
					aadd(aView, 'Qt.Cons.Cred.Mes Ant: ' + substr(ZAB->ZAB_TEXTO,19,3))
					aadd(aView, 'Total Consulta Cheq.: ' + substr(ZAB->ZAB_TEXTO,22,3))
					aadd(aView, 'Qt.Cons.Cheq. Atual.: ' + substr(ZAB->ZAB_TEXTO,25,3))
					aadd(aView, 'Qt.Cons.Cheq.Mes Ant: ' + substr(ZAB->ZAB_TEXTO,28,3))
					aadd(aView, 'Qt.Cons.Cheq.Mes Ant: ' + substr(ZAB->ZAB_TEXTO,31,3))
					aadd(aView, 'Qt.Cons.Cheq.Mes Ant: ' + substr(ZAB->ZAB_TEXTO,34,3))
					aadd(aView, 'Ult.Atualização.....: ' + substr(ZAB->ZAB_TEXTO,37,8))
					aadd(aView, 'FICAD/PF Sintético..: ' + substr(ZAB->ZAB_TEXTO,45,8))
				Case ZAB->ZAB_CODIGO == 'B354'
					if ZAB->ZAB_LINHA == '001' 
						aadd(aView, '')
						aadd(aView, 'Data Consulta | Instituição                              | Modalidade   | Moeda | Valor')
					endif
					aadd(aView, dtoc(stod( substr(ZAB->ZAB_TEXTO,1,8) )) + '      | ' + substr(ZAB->ZAB_TEXTO,9,40) + ' | ' + substr(ZAB->ZAB_TEXTO,57,12) + ' | ' + substr(ZAB->ZAB_TEXTO,69,3) + '   | ' + 	substr(ZAB->ZAB_TEXTO,72,9))
			EndCase
		
		//Se CREDIT BUREAU e CHEQUES
		//elseif nTipo == 1 .and. _nFolder == 3
		
		//Se CREDIT BUREAU e ANOTAÇÕES
		elseif nTipo == 1 .and. _nFolder == 3
			Do Case          
			
		   		Case ZAB->ZAB_CODIGO == 'T999' .and. substr(ZAB->ZAB_TEXTO,1,3) <> '000'
					aadd(aView, 'Mensagem............: ' + substr(ZAB->ZAB_TEXTO,18,50))
					aadd(aView, '')
				Case ZAB->ZAB_CODIGO == 'ERRO'
					aadd(aView, 'Mensagem............: ' + substr(ZAB->ZAB_TEXTO,1,115))
					aadd(aView, '')
				Case ZAB->ZAB_CODIGO == 'A900'
					aadd(aView, 'Mensagem.............: ' + substr(ZAB->ZAB_TEXTO,40,90))   
					aadd(aView, '')       
			
				Case ZAB->ZAB_CODIGO == 'B357'
					_cPf := ''
					if substr(ZAB->ZAB_TEXTO,82,2) == '01'
						_cPf := '01 - Pendência Financeira do Mercado'
					elseif substr(ZAB->ZAB_TEXTO,82,2) == '02'
						_cPf := '02 - PEFIN Convênio entre empresas/segmento (PEFIN fechado)'
					elseif substr(ZAB->ZAB_TEXTO,82,2) == '03'
						_cPf := '03 - PEFIN INTERNO de acesso exclusivo de um CNPJ (consulta na própria origem)'
					elseif substr(ZAB->ZAB_TEXTO,82,2) == '04'
						_cPf := '04 - REFIN'
					endif
				
					aadd(aView, PadC(' [ PENDÊNCIA DE PAGAMENTO ] ', 115, '-'))
					aadd(aView, 'Qtde de Ocorrências.: ' + substr(ZAB->ZAB_TEXTO,1,5))
					aadd(aView, 'Descrição Ocorrência: ' + substr(ZAB->ZAB_TEXTO,6,28))
					aadd(aView, '1a. Ocorrência......: ' + dtoc(stod( substr(ZAB->ZAB_TEXTO,34,8) )))
					aadd(aView, 'Ult. Ocorrência.....: ' + dtoc(stod( substr(ZAB->ZAB_TEXTO,42,8) )))
					aadd(aView, 'Tipo Moeda..........: ' + substr(ZAB->ZAB_TEXTO,50,3))
					aadd(aView, 'Vlr.Ult.Ocorrência..: ' + substr(ZAB->ZAB_TEXTO,53,5))
					aadd(aView, 'Empresa Ult.Ocorrênc: ' + substr(ZAB->ZAB_TEXTO,58,19))
					aadd(aView, 'Filial..............: ' + substr(ZAB->ZAB_TEXTO,78,4))
					aadd(aView, 'PEFIN...............: ' + _cPf)
				Case ZAB->ZAB_CODIGO == 'B358'                 
					_cPf := ''
					if substr(ZAB->ZAB_TEXTO,1,2) == '01'
						_cPf := '01 - Pendência Financeira do Mercado'
					elseif substr(ZAB->ZAB_TEXTO,1,2) == '02'
						_cPf := '02 - PEFIN Convênio entre empresas/segmento (PEFIN fechado)'
					elseif substr(ZAB->ZAB_TEXTO,1,2) == '03'
						_cPf := '03 - PEFIN INTERNO de acesso exclusivo de um CNPJ (consulta na própria origem)'
					elseif substr(ZAB->ZAB_TEXTO,1,2) == '04'
						_cPf := '04 - REFIN'
					endif
				
					aadd(aView, PadC(' [ PENDÊNCIA DE PAGAMENTO - DETALHE ] ', 115, '-'))
					aadd(aView, 'Tipo do PEFIN.......: ' + _cPf )//substr(ZAB->ZAB_TEXTO,1,2))
					aadd(aView, 'Modalidade..........: ' + substr(ZAB->ZAB_TEXTO,3,12))
					aadd(aView, 'Qtde Ult.Ocorrência.: ' + substr(ZAB->ZAB_TEXTO,16,12))
					//aadd(aView, 'Qtde Ult.Ocorrência.: ' + substr(ZAB->ZAB_TEXTO,25,2))
					aadd(aView, 'Data Ocorrência.....: ' + dtoc(stod( substr(ZAB->ZAB_TEXTO,28,8) )))
					aadd(aView, 'Sigla Modalidade....: ' + substr(ZAB->ZAB_TEXTO,35,2))
					aadd(aView, 'CPF do Avalista.....: ' + iif(substr(ZAB->ZAB_TEXTO,37,1)=='S', 'Sim', 'Nao'))
					aadd(aView, 'Tipo Moeda.idade....: ' + substr(ZAB->ZAB_TEXTO,39,3))
					aadd(aView, 'Valor do Contrato...: ' + substr(ZAB->ZAB_TEXTO,41,9))
					aadd(aView, 'Numero do Contrato..: ' + substr(ZAB->ZAB_TEXTO,50,17))
					aadd(aView, 'Empresa de Origem...: ' + substr(ZAB->ZAB_TEXTO,68,20))
					aadd(aView, 'Praça de Origem.....: ' + substr(ZAB->ZAB_TEXTO,88,4))
					aadd(aView, 'Qtd.Total Ocorrência: ' + substr(ZAB->ZAB_TEXTO,92,5))
					aadd(aView, 'Código Instituição..: ' + substr(ZAB->ZAB_TEXTO,97,4))
					aadd(aView, 'Condição Sub Judice.: ' + substr(ZAB->ZAB_TEXTO,101,1))
					aadd(aView, 'Estado..............: ' + substr(ZAB->ZAB_TEXTO,102,2))
				Case ZAB->ZAB_CODIGO == 'B35B'
					aadd(aView, PadC(' [ PENDÊNCIA DE PAGAMENTO - PEFIN RESUMO ] ', 115, '-'))
					aadd(aView, 'Qtd.Total Ocorrência: ' + substr(ZAB->ZAB_TEXTO,1,5))
					aadd(aView, 'Vlr.Total Ocorrência: ' + substr(ZAB->ZAB_TEXTO,6,13))
				Case ZAB->ZAB_CODIGO == 'B38M'
					aadd(aView, PadC(' [ PENDÊNCIA DE PAGAMENTO - REFIN RESUMO ] ', 115, '-'))
					aadd(aView, 'Qtd.Total Ocorrência: ' + substr(ZAB->ZAB_TEXTO,1,5))
					aadd(aView, 'Vlr.Total Ocorrência: ' + substr(ZAB->ZAB_TEXTO,6,13))
				Case ZAB->ZAB_CODIGO == 'B360'
					_cTp := ''
					if substr(ZAB->ZAB_TEXTO,99,1) == '0' .or. substr(ZAB->ZAB_TEXTO,99,1) == 'I'
							_cTp := 'Individual            '
					elseif substr(ZAB->ZAB_TEXTO,99,1) == '9'
							_cTp := 'Titular Conta Conjunta'
					elseif substr(ZAB->ZAB_TEXTO,99,1) == 'C'
							_cTp := 'Conjunta              '
					Endif
					if ZAB->ZAB_LINHA == '001'
						aadd(aView, PadC(' [ DETALHE DE CHEQUE SEM FUNDOS ] ', 115, '-'))
						aadd(aView, 'Data       | Nr.Cheque | Alínea | Qtd.Cheques | Moeda | Valor     | Banco | Ag.  | Cidade | UF | Qt.Total Ocorr. | Tipo Conta             | Cta')
					endif
					aadd(aView, dtoc(stod( substr(ZAB->ZAB_TEXTO,1,8) )) + ' | ' + substr(ZAB->ZAB_TEXTO,9,6) + '    | ' + substr(ZAB->ZAB_TEXTO,15,2) + '     | ' + substr(ZAB->ZAB_TEXTO,17,4) + '        | ' + substr(ZAB->ZAB_TEXTO,21,3) + '   | ' + substr(ZAB->ZAB_TEXTO,24,9) + ' | ' + substr(ZAB->ZAB_TEXTO,33,3) + '   | ' + substr(ZAB->ZAB_TEXTO,63,4) + ' | ' + substr(ZAB->ZAB_TEXTO,67,4) + '   | ' + substr(ZAB->ZAB_TEXTO,92,2) + ' | ' + substr(ZAB->ZAB_TEXTO,94,5) + '           | ' + 	_cTp + ' | ' + substr(ZAB->ZAB_TEXTO,100,9))
				Case ZAB->ZAB_CODIGO == 'B362'
					if ZAB->ZAB_LINHA == '001'
						aadd(aView, '')
						aadd(aView, PadC(' [ PROTESTO - DETALHE  ] ', 115, '-'))
						aadd(aView, 'Data       | Moeda | Valor     | Cartório | Cidade                     | UF | Qtd.Ocorr. | SubJudice | Dt.Carta Anuência | Nat. | Tipo Anuência')
					endif
					aadd(aView, dtoc(stod( substr(ZAB->ZAB_TEXTO,1,8) )) + '   | ' + substr(ZAB->ZAB_TEXTO,9,3) + '   | ' + substr(ZAB->ZAB_TEXTO,12,9) + ' | ' + substr(ZAB->ZAB_TEXTO,21,4) + '     | ' + substr(ZAB->ZAB_TEXTO,25,24) + '   | ' + substr(ZAB->ZAB_TEXTO,50,2) + ' | ' + substr(ZAB->ZAB_TEXTO,52,5) + '      | ' + substr(ZAB->ZAB_TEXTO,57,1) + '         | ' + dtoc(stod( substr(ZAB->ZAB_TEXTO,58,8) )) + '          | ' + substr(ZAB->ZAB_TEXTO,77,3) + '  | ' + substr(ZAB->ZAB_TEXTO,80,1))
				Case ZAB->ZAB_CODIGO == 'B364'
					_cTp := '          '
					if substr(ZAB->ZAB_TEXTO,29,1) == 'S'
							_cTp := 'Principal '
					elseif substr(ZAB->ZAB_TEXTO,29,1) == 'N'
							_cTp := 'Coobrigado'
					Endif
					if ZAB->ZAB_LINHA == '001'
						aadd(aView, PadC(' [ AÇÃO JUDICIAL - DETALHE  ] ', 115, '-'))
						aadd(aView, 'Data       | Natureza             | CPF        | Moeda | Valor     | Distribuidor | Nr.Vara Cível | Cidade | UF | Qtd.Ocorr. | SubJudice | Nat.')
					endif
					aadd(aView, dtoc(stod( substr(ZAB->ZAB_TEXTO,1,8) )) + ' | ' + substr(ZAB->ZAB_TEXTO,9,20) + ' | ' + _cTp + ' | ' +	substr(ZAB->ZAB_TEXTO,30,3) + '   | ' + substr(ZAB->ZAB_TEXTO,33,9) + ' | ' + substr(ZAB->ZAB_TEXTO,42,4) + '         | ' + substr(ZAB->ZAB_TEXTO,46,4) + '          | ' + substr(ZAB->ZAB_TEXTO,50,4) + '   | ' + substr(ZAB->ZAB_TEXTO,75,2) + ' | ' + substr(ZAB->ZAB_TEXTO,77,5) + '      | ' + substr(ZAB->ZAB_TEXTO,82,1) + '         | ' + substr(ZAB->ZAB_TEXTO,94,3))
				Case ZAB->ZAB_CODIGO == 'B366'
					_cTp := ''
					if substr(ZAB->ZAB_TEXTO,83,3) == 'GER'
							_cTp := 'Gerente'
					elseif substr(ZAB->ZAB_TEXTO,83,3) == 'TIT'
							_cTp := 'Titular'
					elseif substr(ZAB->ZAB_TEXTO,83,3) == 'SOC'
							_cTp := 'Sócio  '
					elseif substr(ZAB->ZAB_TEXTO,83,3) == 'DIR'
							_cTp := 'Diretor'
					Endif
					if ZAB->ZAB_LINHA == '001'
						aadd(aView, PadC(' [ PARTICIPAÇÃO EM FALÊNCIAS - DETALHE  ] ', 115, '-'))
						aadd(aView, 'Data     | Tipo       | CNPJ           | Nome                                          | Qtd.Total no CPF | Qualificação | Vara Cível | Qtd.Ocorr. | Natureza')
					endif
					aadd(aView, dtoc(stod( substr(ZAB->ZAB_TEXTO,1,8) )) + ' | ' + substr(ZAB->ZAB_TEXTO,9,10) + ' | ' + substr(ZAB->ZAB_TEXTO,19,14) + ' | ' + substr(ZAB->ZAB_TEXTO,33,45) + ' | ' + substr(ZAB->ZAB_TEXTO,78,5) + '            | ' + _cTp + '      | ' + substr(ZAB->ZAB_TEXTO,86,4) + '       | ' + substr(ZAB->ZAB_TEXTO,91,9) + '  | ' + substr(ZAB->ZAB_TEXTO,101,3))
				Case ZAB->ZAB_CODIGO == 'B368'
					if ZAB->ZAB_LINHA == '001'
						aadd(aView, PadC(' [ DÍVIDA VENCIDA - DETALHE  ] ', 115, '-'))
						aadd(aView, 'Data     | Tipo | Moeda | Valor     | Título            | Instituição          | Cidade | Qtd.Ocorr. | Modalidade      | Natureza')
					endif
		    		aadd(aView, dtoc(stod( substr(ZAB->ZAB_TEXTO,1,8) )) + ' | ' + substr(ZAB->ZAB_TEXTO,9,2) + '   | ' + substr(ZAB->ZAB_TEXTO,11,3) + '   | ' + substr(ZAB->ZAB_TEXTO,14,9) + ' | ' + substr(ZAB->ZAB_TEXTO,23,17) + ' | ' + substr(ZAB->ZAB_TEXTO,40,20) + ' | ' + substr(ZAB->ZAB_TEXTO,60,4) + '   | ' + substr(ZAB->ZAB_TEXTO,64,5) + '      | ' + substr(ZAB->ZAB_TEXTO,80,15) + ' | ' + substr(ZAB->ZAB_TEXTO,95,3))		
		   	//	Case AllTrim(ZAB->ZAB_CODIGO) == ''
			
			EndCase
		
		//Se CREDIT BUREAU e ENDEREÇOS E TELEFONES ALTERNATIVOS
		elseif nTipo == 1 .and. _nFolder == 4
			Do Case
				Case ZAB->ZAB_CODIGO == 'B370' .and. substr(ZAB->ZAB_TEXTO,1,1) == '1'
				        lPassou := .T.    
						aadd(aView, 'DDD | Telefone  | Endereço                                                               | Bairro               | CEP')                     
					//                           DDD                       Telefone                                      endereco                                 bairro                              cep
						aadd(aView, substr(ZAB->ZAB_TEXTO,2,3) + ' | ' + substr(ZAB->ZAB_TEXTO,5,9) + ' | ' + substr(ZAB->ZAB_TEXTO,14,70) + ' | ' + substr(ZAB->ZAB_TEXTO,84,20) + ' | ' + substr(ZAB->ZAB_TEXTO,104,8))
				Case ZAB->ZAB_CODIGO == 'B370' .and. substr(ZAB->ZAB_TEXTO,1,1) == '2'
					    lPassou := .T.  
					  	aadd(aView, 'Cidade                         | UF | Nome                                               | Dt.Atualização')
						aadd(aView, substr(ZAB->ZAB_TEXTO,2,30) + ' | ' + 	substr(ZAB->ZAB_TEXTO,32,2) + ' | ' + substr(ZAB->ZAB_TEXTO,34,50) + ' | ' + substr(ZAB->ZAB_TEXTO,84,8))
						aadd(aView, '') 
				Case ZAB->ZAB_CODIGO != 'B370' 
				        lEntrou := .F.						   
			EndCase
		 /*	
			 If (!lPassou .And. !lEntrou)
					aadd(aView, 'Mensagem.............: NÃO CONSTAM ENDEREÇOS / FONES ALTERNATIVOS')
					aadd(aView, '')            
			 EndIf   */
			
		//Se CREDNET e CONFIRMEI
		elseif nTipo == 2 .and. _nFolder == 1
			Do Case
				Case ZAB->ZAB_CODIGO == 'T999' .and. substr(ZAB->ZAB_TEXTO,1,3) <> '000'
					aadd(aView, 'Mensagem............: ' + substr(ZAB->ZAB_TEXTO,18,50))
					aadd(aView, '')
				Case ZAB->ZAB_CODIGO == 'ERRO'
					aadd(aView, 'Mensagem............: ' + substr(ZAB->ZAB_TEXTO,1,115))
					aadd(aView, '')
				Case ZAB->ZAB_CODIGO == 'N200' .and. substr(ZAB->ZAB_TEXTO,1,2) == '00'
					aadd(aView, 'Razão Social........: ' + substr(ZAB->ZAB_TEXTO,3,70))
				Case ZAB->ZAB_CODIGO == 'N200' .and. substr(ZAB->ZAB_TEXTO,1,2) == '01'
					aadd(aView, 'Nome da Mãe.........: ' + substr(ZAB->ZAB_TEXTO,3,40))
				Case ZAB->ZAB_CODIGO == 'N210'
					if ZAB->ZAB_LINHA == '001' .and. (substr(ZAB->ZAB_TEXTO,1,2) == '00' .or. substr(ZAB->ZAB_TEXTO,1,2) == '99') 
						aadd(aView, PadC(' [ ALERTA DOC ROUBADOS ] ', 115, '-'))
						aadd(aView, 'Nr.Msg | Total Msg | Tipo Doc | Nr.Documento         | Motivo | Dt.Ocorr.  | DDD 1 | Fone 1   | DDD 2 | Fone 2   | DDD 3 | Fone 3')
					endif
					
					if substr(ZAB->ZAB_TEXTO,1,2) == '00'
						aadd(aView, substr(ZAB->ZAB_TEXTO,3,2) + '     | ' + substr(ZAB->ZAB_TEXTO,5,2) + '        | ' + substr(ZAB->ZAB_TEXTO,7,6) + '   | ' + substr(ZAB->ZAB_TEXTO,13,20) + ' | ' + substr(ZAB->ZAB_TEXTO,33,4) + '   | ' + dtoc(stod( substr(ZAB->ZAB_TEXTO,37,10) )) + ' | ')
	   				elseif substr(ZAB->ZAB_TEXTO,1,2) == '01'
	   					aView[len(aView)] += substr(ZAB->ZAB_TEXTO,3,3) + '   | ' + substr(ZAB->ZAB_TEXTO,6,8) + ' | ' + substr(ZAB->ZAB_TEXTO,14,3) + '   | ' + substr(ZAB->ZAB_TEXTO,17,8) + ' | ' + substr(ZAB->ZAB_TEXTO,25,3) + '   | ' + substr(ZAB->ZAB_TEXTO,28,8)
					elseif substr(ZAB->ZAB_TEXTO,1,2) == '99'
						aadd(aView, substr(ZAB->ZAB_TEXTO,3,115))
					endif 
			EndCase
	
		//Se CREDNET e Pendência Interna / Pefin de Grupo
		elseif nTipo == 2 .and. _nFolder == 2
			Do Case
				Case ZAB->ZAB_CODIGO == 'N230' .and. (substr(ZAB->ZAB_TEXTO,1,2) == '00' .or. substr(ZAB->ZAB_TEXTO,1,2) == '99')
					if ZAB->ZAB_LINHA == '001' 
						aadd(aV23000, 'Data     | Modalidade                     | Aval. | Moeda | Valor            | Contrato         | Origem                         | Embratel')
					endif
					
					if substr(ZAB->ZAB_TEXTO,1,2) == '00'
						aadd(aV23000, dtoc(stod( substr(ZAB->ZAB_TEXTO,3,8) )) + ' | ' + substr(ZAB->ZAB_TEXTO,11,30) + ' | ' + substr(ZAB->ZAB_TEXTO,43,1) + '     | ' + substr(ZAB->ZAB_TEXTO,44,3) + '   | ' + substr(ZAB->ZAB_TEXTO,47,13) + ',' + substr(ZAB->ZAB_TEXTO,60,2) + ' | ' + substr(ZAB->ZAB_TEXTO,62,16) + ' | ' + substr(ZAB->ZAB_TEXTO,78,30) + ' | ' + substr(ZAB->ZAB_TEXTO,108,4))
					elseif substr(ZAB->ZAB_TEXTO,1,2) == '99'
						aadd(aV23000, substr(ZAB->ZAB_TEXTO,3,115))
					endif 
				Case ZAB->ZAB_CODIGO == 'N230' .and. substr(ZAB->ZAB_TEXTO,1,2) == '90'
					if ZAB->ZAB_LINHA == '001' 
						aadd(aV23090, 'Tot.Ocorr. | Dt.Antiga | Dt.Recente | Vlr.Total')
					endif
					aadd(aV23090, substr(ZAB->ZAB_TEXTO,3,5) + '      | ' + substr(ZAB->ZAB_TEXTO,8,6) + '    | ' + substr(ZAB->ZAB_TEXTO,14,6) + '     | ' + substr(ZAB->ZAB_TEXTO,20,13) + ',' + substr(ZAB->ZAB_TEXTO,33,2)) 
			EndCase
	
		//Se CREDNET e Pendência Financeira
		elseif nTipo == 2 .and. _nFolder == 3
			Do Case
				Case ZAB->ZAB_CODIGO == 'N240' .and. (substr(ZAB->ZAB_TEXTO,1,2) == '00' .or. substr(ZAB->ZAB_TEXTO,1,2) == '99')
					if ZAB->ZAB_LINHA == '001' 
						aadd(aV24000, 'Data       | Modalidade                     | Aval. | Moeda | Valor            | Contrato         | Origem                         | Embratel')
					endif
					
					if substr(ZAB->ZAB_TEXTO,1,2) == '00'
						aadd(aV24000, substr(ZAB->ZAB_TEXTO,3,2) + '/' + substr(ZAB->ZAB_TEXTO,5,2) + '/' + substr(ZAB->ZAB_TEXTO,7,4) + ' | ' + substr(ZAB->ZAB_TEXTO,11,30) + ' | ' + substr(ZAB->ZAB_TEXTO,41,1) + '     | ' + substr(ZAB->ZAB_TEXTO,42,3) + '   | ' + substr(ZAB->ZAB_TEXTO,45,13) + ',' + substr(ZAB->ZAB_TEXTO,58,2) + ' | ' + substr(ZAB->ZAB_TEXTO,60,16) + ' | ' + substr(ZAB->ZAB_TEXTO,76,30) + ' | ' + substr(ZAB->ZAB_TEXTO,106,4))
					elseif substr(ZAB->ZAB_TEXTO,1,2) == '99'
						aadd(aV24000, substr(ZAB->ZAB_TEXTO,3,115))
					endif 
				Case ZAB->ZAB_CODIGO == 'N240' .and. substr(ZAB->ZAB_TEXTO,1,2) == '01'
					_cSt := ''				
					if substr(ZAB->ZAB_TEXTO,80,1) == 'V'
							_cSt := 'Pefin         '
					elseif substr(ZAB->ZAB_TEXTO,80,1) == 'I'
							_cSt := 'Refin         '
					elseif substr(ZAB->ZAB_TEXTO,80,1) == '5'
							_cSt := 'Dívida Vencida'
					Endif
					//if ZAB->ZAB_LINHA == '002' 
					if empty(len(aV24001)) 
						aadd(aV24001, '')
						aadd(aV24001, 'Subjudice | Mensagem                                                                     | Tipo           | Cadus')
					endif
					aadd(aV24001, substr(ZAB->ZAB_TEXTO,3,1) + '         | ' + substr(ZAB->ZAB_TEXTO,4,76) + ' | ' + _cSt + ' | ' + substr(ZAB->ZAB_TEXTO,81,10))
				Case ZAB->ZAB_CODIGO == 'N240' .and. substr(ZAB->ZAB_TEXTO,1,2) == '90'
					_cSt := ''				
					if substr(ZAB->ZAB_TEXTO,35,1) == 'V'
							_cSt := 'Pefin         '
					elseif substr(ZAB->ZAB_TEXTO,35,1) == 'I'
							_cSt := 'Refin         '
					elseif substr(ZAB->ZAB_TEXTO,35,1) == '5'
							_cSt := 'Dívida Vencida'
					Endif
					//if ZAB->ZAB_LINHA == '001' 
					if empty(len(aV24090)) 
						aadd(aV24090, '')
						aadd(aV24090, 'Tot.Ocorr. | Dt.Antiga | Dt.Recente | Valor            | Tipo')
					endif
					aadd(aV24090, substr(ZAB->ZAB_TEXTO,3,5) + '      | ' + substr(ZAB->ZAB_TEXTO,8,6) + '    | ' +  substr(ZAB->ZAB_TEXTO,14,6) + '     | ' + substr(ZAB->ZAB_TEXTO,20,13) + ',' + substr(ZAB->ZAB_TEXTO,33,2) + ' | ' + _cSt)
			EndCase
	
		//Se CREDNET e Protesto Estadual / Nacional
		elseif nTipo == 2 .and. _nFolder == 4
			Do Case
				Case ZAB->ZAB_CODIGO == 'N250' .and. (substr(ZAB->ZAB_TEXTO,1,2) == '00' .or. substr(ZAB->ZAB_TEXTO,1,2) == '99')
					if ZAB->ZAB_LINHA == '001' 
						aadd(aV25000, 'Data     | Moeda | Valor            | Cartório | Origem                         | UF')
					endif
					
					if substr(ZAB->ZAB_TEXTO,1,2) == '00'
						aadd(aV25000, dtoc(stod( substr(ZAB->ZAB_TEXTO,3,8) )) + ' | ' + substr(ZAB->ZAB_TEXTO,11,3) + '   | ' + substr(ZAB->ZAB_TEXTO,14,13) + ',' + substr(ZAB->ZAB_TEXTO,27,2) + ' | ' + substr(ZAB->ZAB_TEXTO,29,2) + '       | ' + substr(ZAB->ZAB_TEXTO,31,30) + ' | ' + substr(ZAB->ZAB_TEXTO,61,2))
					elseif substr(ZAB->ZAB_TEXTO,1,2) == '99'
						aadd(aV25000, substr(ZAB->ZAB_TEXTO,3,115))
					endif 
				Case ZAB->ZAB_CODIGO == 'N250' .and. substr(ZAB->ZAB_TEXTO,1,2) == '01'
					_cSt := ''				
					if substr(ZAB->ZAB_TEXTO,80,1) == 'V'
							_cSt := 'Pefin         '
					elseif substr(ZAB->ZAB_TEXTO,80,1) == 'I'
							_cSt := 'Refin         '
					elseif substr(ZAB->ZAB_TEXTO,80,1) == '5'
							_cSt := 'Dívida Vencida'
					Endif
					if empty(len(aV25001))
						aadd(aV25001, '')
						aadd(aV25001, 'Subjudice | Mensagem                                                                     | Tipo           | Cadus')
					endif
					aadd(aV25001, substr(ZAB->ZAB_TEXTO,3,1) + '         | ' + substr(ZAB->ZAB_TEXTO,4,76) + ' | ' + _cSt + ' | ' + substr(ZAB->ZAB_TEXTO,81,10))
				Case ZAB->ZAB_CODIGO == 'N250' .and. substr(ZAB->ZAB_TEXTO,1,2) == '90'
					if empty(len(aV25090)) 
						aadd(aV25090, '')
						aadd(aV25090, 'Tot.Ocorr. | Dt.Antiga | Dt.Recente | Moeda | Valor')
					endif
					aadd(aV25090, substr(ZAB->ZAB_TEXTO,3,5) + '      | ' + substr(ZAB->ZAB_TEXTO,8,6) + '    | ' +  substr(ZAB->ZAB_TEXTO,14,6) + '     | ' + substr(ZAB->ZAB_TEXTO,20,3) + '   | ' + substr(ZAB->ZAB_TEXTO,23,13) + ',' + substr(ZAB->ZAB_TEXTO,36,2))
			EndCase
	
		//Se CREDNET e Cheques sem fundos Varejo
		elseif nTipo == 2 .and. _nFolder == 5
			Do Case
				Case ZAB->ZAB_CODIGO == 'N260' .and. (substr(ZAB->ZAB_TEXTO,1,2) == '90' .or. substr(ZAB->ZAB_TEXTO,1,2) == '99')
					if ZAB->ZAB_LINHA == '001' 
						aadd(aV26090, 'Tot.Ocorr. | Data       | Banco | Nome         | Age  | Origem                         | Embratel | Filial')
					endif
					
					if substr(ZAB->ZAB_TEXTO,1,2) == '90'
						aadd(aV26090, substr(ZAB->ZAB_TEXTO,3,5) + '      | ' + substr(ZAB->ZAB_TEXTO,8,2) + '/' + substr(ZAB->ZAB_TEXTO,10,2) + '/' + substr(ZAB->ZAB_TEXTO,12,4) + ' | ' + substr(ZAB->ZAB_TEXTO,16,3) + '   | ' + substr(ZAB->ZAB_TEXTO,19,12) + ' | ' + substr(ZAB->ZAB_TEXTO,31,4) + ' | ' + substr(ZAB->ZAB_TEXTO,35,30) + ' | ' + substr(ZAB->ZAB_TEXTO,65,4) + '     | ' + substr(ZAB->ZAB_TEXTO,69,4))
					elseif substr(ZAB->ZAB_TEXTO,1,2) == '99'
						aadd(aV26090, substr(ZAB->ZAB_TEXTO,3,115))
					endif 
			EndCase
	
		//Se CREDNET e Cheques sem fundos BACEN
		elseif nTipo == 2 .and. _nFolder == 6
			Do Case
				Case ZAB->ZAB_CODIGO == 'N270' .and. (substr(ZAB->ZAB_TEXTO,1,2) == '90' .or. substr(ZAB->ZAB_TEXTO,1,2) == '99')
					if ZAB->ZAB_LINHA == '001' 
						aadd(aV27090, 'Tot.Ocorr. | Dt.Antiga  | Dt.Recente | Banco | Age  | Nome')
					endif
					
					if substr(ZAB->ZAB_TEXTO,1,2) == '90'
						aadd(aV27090, substr(ZAB->ZAB_TEXTO,3,5) + '      | ' + substr(ZAB->ZAB_TEXTO,8,2) + '/' + substr(ZAB->ZAB_TEXTO,10,2) + '/' + substr(ZAB->ZAB_TEXTO,12,4) + ' | ' + substr(ZAB->ZAB_TEXTO,16,2) + '/' + substr(ZAB->ZAB_TEXTO,18,2) + '/' + substr(ZAB->ZAB_TEXTO,20,4) + ' | ' + substr(ZAB->ZAB_TEXTO,24,3) + '   | ' + substr(ZAB->ZAB_TEXTO,27,4) + ' | ' + substr(ZAB->ZAB_TEXTO,31,12))
					elseif substr(ZAB->ZAB_TEXTO,1,2) == '99'
						aadd(aV27090, substr(ZAB->ZAB_TEXTO,3,115))
					endif 
			EndCase
	
		//Se CREDNET e Endereço do CEP
		elseif nTipo == 2 .and. _nFolder == 7
			Do Case
				Case ZAB->ZAB_CODIGO == 'N410' .and. substr(ZAB->ZAB_TEXTO,1,2) == '00'
					aadd(aV41000, 'Endereço............: ' + substr(ZAB->ZAB_TEXTO,3,70))
					aadd(aV41000, 'Bairro..............: ' + substr(ZAB->ZAB_TEXTO,73,30))
				Case ZAB->ZAB_CODIGO == 'N410' .and. substr(ZAB->ZAB_TEXTO,1,2) == '01'
					aadd(aV41000, 'Cidade..............: ' + substr(ZAB->ZAB_TEXTO,3,30))
					aadd(aV41000, 'UF..................: ' + substr(ZAB->ZAB_TEXTO,33,2))
					aadd(aV41000, 'CEP Genérico........: ' + substr(ZAB->ZAB_TEXTO,35,1))
				Case ZAB->ZAB_CODIGO == 'N410' .and. substr(ZAB->ZAB_TEXTO,1,2) == '99'
					aadd(aV41000, 'Mensagem............: ' + substr(ZAB->ZAB_TEXTO,3,115))
			EndCase
	
		//Se CREDNET e Endereço do Telefone
		elseif nTipo == 2 .and. _nFolder == 8
			Do Case
				Case ZAB->ZAB_CODIGO == 'N420' .and. substr(ZAB->ZAB_TEXTO,1,2) == '00'
					_cSt := ''				
					if substr(ZAB->ZAB_TEXTO,74,1) == 'I'
							_cSt := 'Indefinido'
					elseif substr(ZAB->ZAB_TEXTO,74,1) == 'F'
							_cSt := 'Física'
					elseif substr(ZAB->ZAB_TEXTO,74,1) == 'J'
							_cSt := 'Jurídica'
					Endif
					_cCl := ''				
					if substr(ZAB->ZAB_TEXTO,75,1) == '0'
							_cCl := 'Não definida'
					elseif substr(ZAB->ZAB_TEXTO,75,1) == '1'
							_cCl := 'Residencial'
					elseif substr(ZAB->ZAB_TEXTO,75,1) == '2'
							_cCl := 'Comercial'
					Endif
					aadd(aV42000, 'Documeto Confere....: ' + substr(ZAB->ZAB_TEXTO,3,1))
					aadd(aV42000, 'Nome Assinante......: ' + substr(ZAB->ZAB_TEXTO,4,70))
					aadd(aV42000, 'Tipo Documento......: ' + _cSt)
					aadd(aV42000, 'Classe do Assinante.: ' + _cCl)
					aadd(aV42000, 'Dt. Instalação......: ' + substr(ZAB->ZAB_TEXTO,76,8))
				Case ZAB->ZAB_CODIGO == 'N420' .and. substr(ZAB->ZAB_TEXTO,1,2) == '01'
					aadd(aV42000, 'Logradouro..........: ' + substr(ZAB->ZAB_TEXTO,3,70))
					aadd(aV42000, 'Bairro..............: ' + substr(ZAB->ZAB_TEXTO,73,30))
				Case ZAB->ZAB_CODIGO == 'N420' .and. substr(ZAB->ZAB_TEXTO,1,2) == '02'
					aadd(aV42000, 'Cidade..............: ' + substr(ZAB->ZAB_TEXTO,3,30))
					aadd(aV42000, 'CEP.................: ' + substr(ZAB->ZAB_TEXTO,33,8))
				Case ZAB->ZAB_CODIGO == 'N420' .and. substr(ZAB->ZAB_TEXTO,1,2) == '99'
					aadd(aV42000, 'Mensagem............: ' + substr(ZAB->ZAB_TEXTO,3,115))
			EndCase
	
		//Se CREDNET e Últimos telefones consultados
		elseif nTipo == 2 .and. _nFolder == 9
			Do Case
				Case ZAB->ZAB_CODIGO == 'N430' .and. substr(ZAB->ZAB_TEXTO,1,2) == '00'
					aadd(aV43000, 'DDD 1o. Recente.....: ' + substr(ZAB->ZAB_TEXTO,3,3))
					aadd(aV43000, 'Fone 1o. Recente....: ' + substr(ZAB->ZAB_TEXTO,6,8))
					aadd(aV43000, 'DDD 2o. Recente.....: ' + substr(ZAB->ZAB_TEXTO,14,3))
					aadd(aV43000, 'Fone 2o. Recente....: ' + substr(ZAB->ZAB_TEXTO,17,8))
					aadd(aV43000, 'DDD 3o. Recente.....: ' + substr(ZAB->ZAB_TEXTO,25,3))
					aadd(aV43000, 'Fone 3o. Recente....: ' + substr(ZAB->ZAB_TEXTO,28,8))
					aadd(aV43000, 'DDD 4o. Recente.....: ' + substr(ZAB->ZAB_TEXTO,36,3))
					aadd(aV43000, 'Fone 4o. Recente....: ' + substr(ZAB->ZAB_TEXTO,39,8))
					aadd(aV43000, 'DDD 5o. Recente.....: ' + substr(ZAB->ZAB_TEXTO,47,3))
					aadd(aV43000, 'Fone 5o. Recente....: ' + substr(ZAB->ZAB_TEXTO,50,8))
				Case ZAB->ZAB_CODIGO == 'N430' .and. substr(ZAB->ZAB_TEXTO,1,2) == '99'
					aadd(aV43000, 'Mensagem............: ' + substr(ZAB->ZAB_TEXTO,3,115))
			EndCase
	
		//Se CREDNET e Registro de Consultas
		elseif nTipo == 2 .and. _nFolder == 10
			Do Case
				Case ZAB->ZAB_CODIGO == 'N440' .and. substr(ZAB->ZAB_TEXTO,1,2) == '03'
					aadd(aV44003, 'Consulta Ult.15 dias: ' + substr(ZAB->ZAB_TEXTO,3,3))
					aadd(aV44003, 'Consult. entre 16/30: ' + substr(ZAB->ZAB_TEXTO,6,3))
					aadd(aV44003, 'Consult. entre 31/60: ' + substr(ZAB->ZAB_TEXTO,9,3))
					aadd(aV44003, 'Consult. entre 61/90: ' + substr(ZAB->ZAB_TEXTO,12,3))
				Case ZAB->ZAB_CODIGO == 'N440' .and. substr(ZAB->ZAB_TEXTO,1,2) == '99'
					aadd(aV44003, 'Mensagem............: ' + substr(ZAB->ZAB_TEXTO,3,115))
			EndCase
	
		//Se RELATO e DADOS CADASTRAIS
		elseif nTipo == 3 .and. _nFolder == 1
			Do Case
				Case ZAB->ZAB_CODIGO == 'T999' .and. substr(ZAB->ZAB_TEXTO,1,3) <> '000'
					aadd(aView, 'Mensagem............: ' + substr(ZAB->ZAB_TEXTO,18,50))
					aadd(aView, '')
				Case ZAB->ZAB_CODIGO == 'ERRO'
					aadd(aView, 'Mensagem............: ' + substr(ZAB->ZAB_TEXTO,1,115))
					aadd(aView, '')
				Case ZAB->ZAB_CODIGO == 'B381'
					_cSt := ''				
					if substr(ZAB->ZAB_TEXTO,100,1) == '0'
							_cSt := 'Não Confirmada'
					elseif substr(ZAB->ZAB_TEXTO,100,1) == '2'
							_cSt := 'Ativa'
					elseif substr(ZAB->ZAB_TEXTO,100,1) == '6'
							_cSt := 'Suspenso'
					elseif substr(ZAB->ZAB_TEXTO,100,1) == '9'
							_cSt := 'Cancelado'
					Endif
					if ZAB->ZAB_LINHA == '001'
						aadd(aView, PadC(' [ IDENTIFICAÇÃO ] ', 115, '-'))
						aadd(aView, 'Razão Social                                                           | CNPJ     | Cód.Cidade | Grafia    | Situação na Receita')
					endif
					aadd(aView, substr(ZAB->ZAB_TEXTO,1,70) + ' | ' + substr(ZAB->ZAB_TEXTO,71,8) + ' | ' + substr(ZAB->ZAB_TEXTO,87,4) + '       | ' + substr(ZAB->ZAB_TEXTO,91,9) + ' | ' + _cSt)
				Case ZAB->ZAB_CODIGO == 'B38A'
					aadd(aView, 'Inscr.Reg. Empresas.: ' + substr(ZAB->ZAB_TEXTO,1,11))
					aadd(aView, 'Descr.Situação......: ' + substr(ZAB->ZAB_TEXTO,12,79))
					aadd(aView, 'Tem Ficha...........: ' + substr(ZAB->ZAB_TEXTO,91,1))
					aadd(aView, 'Cód.Msg Reciprocidad: ' + substr(ZAB->ZAB_TEXTO,92,1))
					aadd(aView, 'Últ.Msg Reciprocidad: ' + substr(ZAB->ZAB_TEXTO,93,10))
					aadd(aView, 'Tipo Relato.........: ' + substr(ZAB->ZAB_TEXTO,103,1))
					aadd(aView, 'Tem Reciprocidade?..: ' + substr(ZAB->ZAB_TEXTO,104,1))
					aadd(aView, 'Tipo Relato Cobrado.: ' + substr(ZAB->ZAB_TEXTO,105,1))
				Case ZAB->ZAB_CODIGO == 'B38B'
					aadd(aView, '                      ' + alltrim(substr(ZAB->ZAB_TEXTO,1,115)))
				Case ZAB->ZAB_CODIGO == 'R38C'
					aadd(aView, 'Tipo Sociedade......: ' + substr(ZAB->ZAB_TEXTO,1,60))
					aadd(aView, 'Inscrição Estadual..: ' + substr(ZAB->ZAB_TEXTO,61,15))
					aadd(aView, 'Sefaz...............: ' + substr(ZAB->ZAB_TEXTO,66,2))
				Case ZAB->ZAB_CODIGO == 'R010'
					aadd(aView, '')
					aadd(aView, PadC(' [ CONTABILIZAÇÃO ] ', 115, '-'))
					aadd(aView, 'Confidencial p/.....: ' + substr(ZAB->ZAB_TEXTO,1,60))
					aadd(aView, 'Dt.Contabilização...: ' + dtoc(stod( substr(ZAB->ZAB_TEXTO,61,8)) ))
					aadd(aView, 'Hr.Contabilização...: ' + substr(ZAB->ZAB_TEXTO,69,8))
					aadd(aView, 'Moeda...............: ' + substr(ZAB->ZAB_TEXTO,77,2))
					aadd(aView, 'CNPJ editado........: ' + substr(ZAB->ZAB_TEXTO,79,24))
					aadd(aView, 'Ultima Atualização..: ' + dtoc(stod( substr(ZAB->ZAB_TEXTO,103,8)) ))
					aadd(aView, 'Base Junta Comercial: ' + iif(empty(substr(ZAB->ZAB_TEXTO,111,1)), 'Não', 'Sim'))
				Case ZAB->ZAB_CODIGO == 'R014'
					aadd(aView, 'Ult.Reg.Órgãos Ofic.: ' + substr(ZAB->ZAB_TEXTO,1,11))
					aadd(aView, 'Data Ult.Registro...: ' + dtoc(stod( substr(ZAB->ZAB_TEXTO,12,8)) ))
				Case ZAB->ZAB_CODIGO == 'R102'
					aadd(aView, PadC(' [ ENDEREÇO ] ', 115, '-'))
					aadd(aView, 'Nome Fantasia.......: ' + substr(ZAB->ZAB_TEXTO,61,51))
					aadd(aView, 'Endereço............: ' + substr(ZAB->ZAB_TEXTO,1,60))
				Case ZAB->ZAB_CODIGO == 'R103'
					aadd(aView, PadC(' [ LOCALIZAÇÃO ] ', 115, '-'))
					aadd(aView, 'Cidade..............: ' + alltrim(substr(ZAB->ZAB_TEXTO,1,30)) + '/' + substr(ZAB->ZAB_TEXTO,31,2) + ' - CEP: ' + substr(ZAB->ZAB_TEXTO,33,9))
					//aadd(aView, 'Unidade da Federação: ' + substr(ZAB->ZAB_TEXTO,31,2))
					//aadd(aView, 'CEP da empresa......: ' + substr(ZAB->ZAB_TEXTO,33,9))
					aadd(aView, 'DDD da Localidade...: ' + substr(ZAB->ZAB_TEXTO,42,4))
					aadd(aView, 'Telefone............: ' + substr(ZAB->ZAB_TEXTO,46,9))
					aadd(aView, 'Fax.................: ' + substr(ZAB->ZAB_TEXTO,55,9))
					aadd(aView, 'Código Embratel.....: ' + substr(ZAB->ZAB_TEXTO,64,4))
				Case ZAB->ZAB_CODIGO == 'R104'
					aadd(aView, PadC(' [ ATIVIDADE ] ', 115, '-'))
					aadd(aView, 'Data da Fundação....: ' + dtoc(stod( substr(ZAB->ZAB_TEXTO,1,8)) ))
					aadd(aView, 'Data do CNPJ........: ' + dtoc(stod( substr(ZAB->ZAB_TEXTO,9,8)) ))
					aadd(aView, 'Ramo de Atividade...: ' + substr(ZAB->ZAB_TEXTO,17,54))
					aadd(aView, 'Código SERASA.......: ' + substr(ZAB->ZAB_TEXTO,71,7))
					aadd(aView, 'Qtde Empregados.....: ' + substr(ZAB->ZAB_TEXTO,78,5))
					aadd(aView, '% de Compras........: ' + substr(ZAB->ZAB_TEXTO,83,3))
					aadd(aView, '% de Vendas.........: ' + substr(ZAB->ZAB_TEXTO,86,3))
					aadd(aView, 'Qtde de Filiais.....: ' + substr(ZAB->ZAB_TEXTO,89,6))
					aadd(aView, 'Código CNAE.........: ' + substr(ZAB->ZAB_TEXTO,95,7))
				Case ZAB->ZAB_CODIGO == 'R105'
					if ZAB->ZAB_LINHA == '001'
						aadd(aView, PadC(' [ FILIAIS ] ', 115, '-'))
						aadd(aView, 'Nome                           | Cód.Embratel')
					endif
					aadd(aView, substr(ZAB->ZAB_TEXTO,1,30) + ' | ' + substr(ZAB->ZAB_TEXTO,31,4))
				Case ZAB->ZAB_CODIGO == 'R106'
					aadd(aView, PadC(' [ PRINCIPAIS PRODUTOS ] ', 115, '-'))
					aadd(aView, 'Principais Produtos.: ' + substr(ZAB->ZAB_TEXTO,1,60))
				Case ZAB->ZAB_CODIGO == 'R10A'
					aadd(aView, '')
					aadd(aView, 'Home Page...........: ' + substr(ZAB->ZAB_TEXTO,1,70))
			endCase
			
		//Se RELATO e ANOTAÇÕES
		elseif nTipo == 3 .and. _nFolder == 2
			Do Case
				Case ZAB->ZAB_CODIGO == 'B357'
					_cPf := ''
					if substr(ZAB->ZAB_TEXTO,86,2) == '01'
						_cPf := '01 - Pendência Financeira do Mercado'
					elseif substr(ZAB->ZAB_TEXTO,86,2) == '02'
						_cPf := '02 - PEFIN Convênio entre empresas/segmento (PEFIN fechado)'
					elseif substr(ZAB->ZAB_TEXTO,86,2) == '03'
						_cPf := '03 - PEFIN INTERNO de acesso exclusivo de um CNPJ (consulta na própria origem)'
					elseif substr(ZAB->ZAB_TEXTO,86,2) == '04'
						_cPf := '04 - REFIN'
					endif
				
					aadd(aView, PadC(' [ PENDÊNCIA DE PAGAMENTO ] ', 115, '-'))
					aadd(aView, 'Qtde de Ocorrências.: ' + substr(ZAB->ZAB_TEXTO,1,5))
					aadd(aView, 'Descrição Ocorrência: ' + substr(ZAB->ZAB_TEXTO,6,28))
					aadd(aView, '1a. Ocorrência......: ' + dtoc(stod( substr(ZAB->ZAB_TEXTO,34,8) )))
					aadd(aView, 'Ult. Ocorrência.....: ' + dtoc(stod( substr(ZAB->ZAB_TEXTO,42,8) )))
					aadd(aView, 'Tipo Moeda..........: ' + substr(ZAB->ZAB_TEXTO,50,3))
					aadd(aView, 'Vlr.Ult.Ocorrência..: ' + substr(ZAB->ZAB_TEXTO,53,9))
					aadd(aView, 'Empresa Ult.Ocorrênc: ' + substr(ZAB->ZAB_TEXTO,62,20))
					aadd(aView, 'Filial..............: ' + substr(ZAB->ZAB_TEXTO,82,4))
					aadd(aView, 'PEFIN...............: ' + _cPf)
				Case ZAB->ZAB_CODIGO == 'B358'
					/*
					aadd(aView, PadC(' [ PENDÊNCIA DE PAGAMENTO - DETALHE ] ', 115, '-'))
					aadd(aView, 'Tipo do PEFIN.......: ' + substr(ZAB->ZAB_TEXTO,1,2))
					aadd(aView, 'Modalidade..........: ' + substr(ZAB->ZAB_TEXTO,3,12))
					aadd(aView, 'Qtde Ult.Ocorrência.: ' + substr(ZAB->ZAB_TEXTO,15,9))
					aadd(aView, 'Data Ocorrência.....: ' + dtoc(stod( substr(ZAB->ZAB_TEXTO,27,8) )))
					aadd(aView, 'Sigla Modalidade....: ' + substr(ZAB->ZAB_TEXTO,35,2))
					aadd(aView, 'CPF do Avalista.....: ' + iif(substr(ZAB->ZAB_TEXTO,37,1)=='S', 'Sim', 'Nao'))
					aadd(aView, 'Tipo Moeda.idade....: ' + substr(ZAB->ZAB_TEXTO,38,3))
					aadd(aView, 'Valor do Contrato...: ' + substr(ZAB->ZAB_TEXTO,41,9))
					aadd(aView, 'Numero do Contrato..: ' + substr(ZAB->ZAB_TEXTO,50,17))
					aadd(aView, 'Empresa de Origem...: ' + substr(ZAB->ZAB_TEXTO,67,20))
					aadd(aView, 'Praça de Origem.....: ' + substr(ZAB->ZAB_TEXTO,87,4))
					aadd(aView, 'Qtd.Total Ocorrência: ' + substr(ZAB->ZAB_TEXTO,91,5))
					aadd(aView, 'Código Instituição..: ' + substr(ZAB->ZAB_TEXTO,96,4))
					aadd(aView, 'Condição Sub Judice.: ' + substr(ZAB->ZAB_TEXTO,100,1))
					aadd(aView, 'Estado..............: ' + substr(ZAB->ZAB_TEXTO,101,2))
					*/
					if ZAB->ZAB_LINHA == '001'
						aadd(aView, PadC(' [ PENDÊNCIA DE PAGAMENTO - DETALHE ] ', 115, '-'))
						aadd(aView, 'Modalidade   | Qt.Ult.Ocorr.| Dt.Ocorr.  | Natureza | Avalista | Moeda | Valor     | Contrato          | Origem               | Filial | Tot.Ocorr.| Subjudice')
					endif
					aadd(aView, substr(ZAB->ZAB_TEXTO,3,12) + ' | ' + substr(ZAB->ZAB_TEXTO,16,9) + '    | ' + dtoc(stod( substr(ZAB->ZAB_TEXTO,28,8) )) + ' | ' + substr(ZAB->ZAB_TEXTO,36,2) + '       | ' + iif(substr(ZAB->ZAB_TEXTO,38,1)=='S', 'Sim', 'Nao') + '      | ' + substr(ZAB->ZAB_TEXTO,39,3) + '   | ' + substr(ZAB->ZAB_TEXTO,42,9) + ' | ' + substr(ZAB->ZAB_TEXTO,51,17) + ' | ' + substr(ZAB->ZAB_TEXTO,68,20) + ' | ' + substr(ZAB->ZAB_TEXTO,88,4) + '   | ' + substr(ZAB->ZAB_TEXTO,92,5) + '     | ' + substr(ZAB->ZAB_TEXTO,101,1))
				Case ZAB->ZAB_CODIGO == 'B35A'
					if ZAB->ZAB_LINHA == '001'
						aadd(aView, PadC(' [ PENDÊNCIA DE PAGAMENTO - DETALHE SUBJUDICE ] ', 115, '-'))
						aadd(aView, 'Praça | Distrito | Vara | Data     | Processo')
					endif
					aadd(aView, substr(ZAB->ZAB_TEXTO,1,4) + '  | ' + substr(ZAB->ZAB_TEXTO,5,2) + '       | ' + substr(ZAB->ZAB_TEXTO,7,2) + '   | ' + dtoc(stod( substr(ZAB->ZAB_TEXTO,9,8) )) + ' | ' + substr(ZAB->ZAB_TEXTO,17,16))
				Case ZAB->ZAB_CODIGO == 'B360'
					_cTp := ''
					if substr(ZAB->ZAB_TEXTO,99,1) == '0' .or. substr(ZAB->ZAB_TEXTO,99,1) == 'I'
							_cTp := 'Individual            '
					elseif substr(ZAB->ZAB_TEXTO,99,1) == '9'
							_cTp := 'Titular Conta Conjunta'
					elseif substr(ZAB->ZAB_TEXTO,99,1) == 'C'
							_cTp := 'Conjunta              '
					Endif
					if ZAB->ZAB_LINHA == '001'
						aadd(aView, PadC(' [ DETALHE DE CHEQUE SEM FUNDOS ] ', 115, '-'))
						aadd(aView, 'Data       | Nr.Cheque | Alínea | Qtd.Cheques | Moeda | Valor     | Banco | Ag.  | Cidade | UF | Qt.Total Ocorr. | Tipo Conta             | Cta')
					endif
					aadd(aView, dtoc(stod( substr(ZAB->ZAB_TEXTO,1,8) )) + ' | ' + substr(ZAB->ZAB_TEXTO,9,6) + '    | ' + substr(ZAB->ZAB_TEXTO,15,2) + '     | ' + substr(ZAB->ZAB_TEXTO,17,4) + '        | ' + substr(ZAB->ZAB_TEXTO,21,3) + '   | ' + substr(ZAB->ZAB_TEXTO,24,9) + ' | ' + substr(ZAB->ZAB_TEXTO,33,3) + '   | ' + substr(ZAB->ZAB_TEXTO,63,4) + ' | ' + substr(ZAB->ZAB_TEXTO,67,4) + '   | ' + substr(ZAB->ZAB_TEXTO,92,2) + ' | ' + substr(ZAB->ZAB_TEXTO,94,5) + '           | ' + 	_cTp + ' | ' + substr(ZAB->ZAB_TEXTO,100,9))
				Case ZAB->ZAB_CODIGO == 'B362'
					if ZAB->ZAB_LINHA == '001'
						aadd(aView, '')
						aadd(aView, PadC(' [ PROTESTO - DETALHE  ] ', 115, '-'))
						aadd(aView, 'Data       | Moeda | Valor     | Cartório | Cidade | UF | Qtd.Ocorr. | SubJudice | Dt.Carta Anuência | Nat. | Tipo Anuência')
					endif
					aadd(aView, dtoc(stod( substr(ZAB->ZAB_TEXTO,1,8) )) + ' | ' + substr(ZAB->ZAB_TEXTO,9,3) + '   | ' + substr(ZAB->ZAB_TEXTO,12,9) + ' | ' + substr(ZAB->ZAB_TEXTO,21,4) + '     | ' + substr(ZAB->ZAB_TEXTO,25,4) + '   | ' + substr(ZAB->ZAB_TEXTO,50,2) + ' | ' + substr(ZAB->ZAB_TEXTO,52,5) + '      | ' + substr(ZAB->ZAB_TEXTO,57,1) + '         | ' + dtoc(stod( substr(ZAB->ZAB_TEXTO,58,8) )) + '        | ' + substr(ZAB->ZAB_TEXTO,77,3) + '  | ' + substr(ZAB->ZAB_TEXTO,80,1))
				Case ZAB->ZAB_CODIGO == 'B36A'
					if ZAB->ZAB_LINHA == '001'
						aadd(aView, PadC(' [ PROTESTO - DETALHE SUBJUDICE ] ', 115, '-'))
						aadd(aView, 'Praça | Distrito | Vara | Data     | Processo')
					endif
					aadd(aView, substr(ZAB->ZAB_TEXTO,1,4) + '  | ' + substr(ZAB->ZAB_TEXTO,5,2) + '       | ' + substr(ZAB->ZAB_TEXTO,7,2) + '   | ' + dtoc(stod( substr(ZAB->ZAB_TEXTO,9,8) )) + ' | ' + substr(ZAB->ZAB_TEXTO,17,16))
				Case ZAB->ZAB_CODIGO == 'B364'
					_cTp := '          '
					if substr(ZAB->ZAB_TEXTO,29,1) == 'S'
							_cTp := 'Principal '
					elseif substr(ZAB->ZAB_TEXTO,29,1) == 'N'
							_cTp := 'Coobrigado'
					Endif
					if ZAB->ZAB_LINHA == '001'
						aadd(aView, PadC(' [ AÇÃO JUDICIAL - DETALHE  ] ', 115, '-'))
						aadd(aView, 'Data       | Natureza             | CPF        | Moeda | Valor     | Distribuidor | Nr.Vara Cível | Cidade | UF | Qtd.Ocorr. | SubJudice | Nat.')
					endif
					aadd(aView, dtoc(stod( substr(ZAB->ZAB_TEXTO,1,8) )) + ' | ' + substr(ZAB->ZAB_TEXTO,9,20) + ' | ' + _cTp + ' | ' +	substr(ZAB->ZAB_TEXTO,30,3) + '   | ' + substr(ZAB->ZAB_TEXTO,33,9) + ' | ' + substr(ZAB->ZAB_TEXTO,42,4) + '         | ' + substr(ZAB->ZAB_TEXTO,46,4) + '          | ' + substr(ZAB->ZAB_TEXTO,50,4) + '   | ' + substr(ZAB->ZAB_TEXTO,75,2) + ' | ' + substr(ZAB->ZAB_TEXTO,77,5) + '      | ' + substr(ZAB->ZAB_TEXTO,82,1) + '         | ' + substr(ZAB->ZAB_TEXTO,94,3))
				Case ZAB->ZAB_CODIGO == 'B36B'
					if ZAB->ZAB_LINHA == '001'
						aadd(aView, PadC(' [ AÇÃO JUDICIAL - DETALHE SUBJUDICE ] ', 115, '-'))
						aadd(aView, 'Praça | Distrito | Vara | Data     | Processo')
					endif
					aadd(aView, substr(ZAB->ZAB_TEXTO,1,4) + '  | ' + substr(ZAB->ZAB_TEXTO,5,2) + '       | ' + substr(ZAB->ZAB_TEXTO,7,2) + '   | ' + dtoc(stod( substr(ZAB->ZAB_TEXTO,9,8) )) + ' | ' + substr(ZAB->ZAB_TEXTO,17,16))
				Case ZAB->ZAB_CODIGO == 'B366'
					_cTp := ''
					if substr(ZAB->ZAB_TEXTO,83,3) == 'GER'
							_cTp := 'Gerente'
					elseif substr(ZAB->ZAB_TEXTO,83,3) == 'TIT'
							_cTp := 'Titular'
					elseif substr(ZAB->ZAB_TEXTO,83,3) == 'SOC'
							_cTp := 'Sócio  '
					elseif substr(ZAB->ZAB_TEXTO,83,3) == 'DIR'
							_cTp := 'Diretor'
					Endif
					if ZAB->ZAB_LINHA == '001'
						aadd(aView, PadC(' [ PARTICIPAÇÃO EM FALÊNCIAS - DETALHE  ] ', 115, '-'))
						aadd(aView, 'Data     | Tipo       | CNPJ           | Nome                                          | Qtd.Total no CPF | Qualificação | Vara Cível | Qtd.Ocorr. | Natureza')
					endif
					aadd(aView, dtoc(stod( substr(ZAB->ZAB_TEXTO,1,8) )) + ' | ' + substr(ZAB->ZAB_TEXTO,9,10) + ' | ' + substr(ZAB->ZAB_TEXTO,19,14) + ' | ' + substr(ZAB->ZAB_TEXTO,33,45) + ' | ' + substr(ZAB->ZAB_TEXTO,78,5) + '            | ' + _cTp + '      | ' + substr(ZAB->ZAB_TEXTO,86,4) + '       | ' + substr(ZAB->ZAB_TEXTO,91,9) + '  | ' + substr(ZAB->ZAB_TEXTO,101,3))
				Case ZAB->ZAB_CODIGO == 'B368'
					if ZAB->ZAB_LINHA == '001'
						aadd(aView, '')
						aadd(aView, PadC(' [ DÍVIDA VENCIDA - DETALHE  ] ', 115, '-'))
						aadd(aView, 'Data       | Tipo | Moeda | Valor     | Título            | Instituição          | Cidade | Qtd.Ocorr. | Modalidade      | Natureza')
					endif
					aadd(aView, dtoc(stod( substr(ZAB->ZAB_TEXTO,1,8) )) + ' | ' + substr(ZAB->ZAB_TEXTO,9,2) + '   | ' + substr(ZAB->ZAB_TEXTO,11,3) + '   | ' + substr(ZAB->ZAB_TEXTO,14,9) + ' | ' + substr(ZAB->ZAB_TEXTO,23,17) + ' | ' + substr(ZAB->ZAB_TEXTO,40,20) + ' | ' + substr(ZAB->ZAB_TEXTO,60,4) + '   | ' + substr(ZAB->ZAB_TEXTO,64,5) + '      | ' + substr(ZAB->ZAB_TEXTO,80,15) + ' | ' + substr(ZAB->ZAB_TEXTO,95,3))
				Case ZAB->ZAB_CODIGO == 'B36C'
					if ZAB->ZAB_LINHA == '001'
						aadd(aView, PadC(' [ DÍVIDA VENCIDA - DETALHE SUBJUDICE ] ', 115, '-'))
						aadd(aView, 'Praça | Distrito | Vara | Data     | Processo')
					endif
					aadd(aView, substr(ZAB->ZAB_TEXTO,1,4) + '  | ' + substr(ZAB->ZAB_TEXTO,5,2) + '       | ' + substr(ZAB->ZAB_TEXTO,7,2) + '   | ' + dtoc(stod( substr(ZAB->ZAB_TEXTO,9,8) )) + ' | ' + substr(ZAB->ZAB_TEXTO,17,16))
				Case ZAB->ZAB_CODIGO == 'R410'
					if ZAB->ZAB_LINHA == '001'
						aadd(aView, PadC(' [ INFORMAÇÕES DO RECHEQUE ] ', 115, '-'))
						aadd(aView, 'Qtde Ocorrências | Qtde Última Ocorrência')
					endif
					aadd(aView, substr(ZAB->ZAB_TEXTO,1,9) + '        | ' + substr(ZAB->ZAB_TEXTO,10,9))
				Case ZAB->ZAB_CODIGO == 'R411'
					if ZAB->ZAB_LINHA == '001'
						aadd(aView, PadC(' [ PARTICIPANTES COM ANOTAÇÕES ] ', 115, '-'))
						aadd(aView, 'Nome                                                              | Documento   | Tipo Pessoa')
					endif
					aadd(aView, substr(ZAB->ZAB_TEXTO,1,65) + ' | ' + substr(ZAB->ZAB_TEXTO,66,11) + ' | ' + substr(ZAB->ZAB_TEXTO,77,1))
				Case ZAB->ZAB_CODIGO == 'R412'
					if ZAB->ZAB_LINHA == '001'
						aadd(aView, '')
						aadd(aView, PadC(' [ INFORMAÇÕES DO CONCENTRE - RESUMO ] ', 115, '-'))
						aadd(aView, 'Qtde Ocorrênc.| Grupo Ocorrência            | Mês Ini  | Ano Ini | Mês Fim  | Ano Fim | Moeda | Valor         | Origem               | Agê. | Vlr Protesto  | Nat. ')					
					endif
					aadd(aView, substr(ZAB->ZAB_TEXTO,1,9) + '     | ' + substr(ZAB->ZAB_TEXTO,10,27) + ' | ' + substr(ZAB->ZAB_TEXTO,40,2) + ' - ' + substr(ZAB->ZAB_TEXTO,37,3) + ' | ' + substr(ZAB->ZAB_TEXTO,42,2) + '      | ' + substr(ZAB->ZAB_TEXTO,47,2) + ' - ' + substr(ZAB->ZAB_TEXTO,44,3) + ' | ' + substr(ZAB->ZAB_TEXTO,49,2) + '      | ' + substr(ZAB->ZAB_TEXTO,51,3) + '   | ' + substr(ZAB->ZAB_TEXTO,54,13) + ' | ' + substr(ZAB->ZAB_TEXTO,67,20) + ' | ' + substr(ZAB->ZAB_TEXTO,87,4) + ' | ' + substr(ZAB->ZAB_TEXTO,91,13) + ' | ' + substr(ZAB->ZAB_TEXTO,104,3))
				Case ZAB->ZAB_CODIGO == 'B382'
					aadd(aView, PadC(' [ RESUMO FALÊNCIA / CONCORDATA ] ', 115, '-'))
					aadd(aView, 'Data Inicial........: ' + dtoc(stod( substr(ZAB->ZAB_TEXTO,1,8) )))
					aadd(aView, 'Data Final..........: ' + dtoc(stod( substr(ZAB->ZAB_TEXTO,9,8) )))
					aadd(aView, 'Quantidade..........: ' + substr(ZAB->ZAB_TEXTO,17,9))
				Case ZAB->ZAB_CODIGO == 'B383'
					if ZAB->ZAB_LINHA == '001'
						aadd(aView, '')
						aadd(aView, PadC(' [ FALÊNCIA/CONCORDATA - CONCENTRE - DETALHE ] ', 115, '-'))
						aadd(aView, 'Data       | Tipo | Vara Civil | Município                 | UF | Qtd.Ocorr. | Facon                | Origem Facon')					
					endif
					aadd(aView, dtoc(stod( substr(ZAB->ZAB_TEXTO,1,8) )) + ' | ' + substr(ZAB->ZAB_TEXTO,9,2) + '   | ' + substr(ZAB->ZAB_TEXTO,11,4) + '       | ' + substr(ZAB->ZAB_TEXTO,15,25) + ' | ' + substr(ZAB->ZAB_TEXTO,40,2) + ' | ' + substr(ZAB->ZAB_TEXTO,53,9) + '  | ' + substr(ZAB->ZAB_TEXTO,62,20) + ' | ' + substr(ZAB->ZAB_TEXTO,82,5))
				Case ZAB->ZAB_CODIGO == 'B389'
					aadd(aView, '')
					aadd(aView, PadC(' [ REFIN - DETALHE ] ', 115, '-'))
					aadd(aView, 'Modalidade..........: ' + substr(ZAB->ZAB_TEXTO,3,12))
					aadd(aView, 'Qtd.Ult.Ocorrência..: ' + substr(ZAB->ZAB_TEXTO,16,9))
					aadd(aView, 'Dt.Ocorrência.......: ' + dtoc(stod( substr(ZAB->ZAB_TEXTO,28,8) )))
					aadd(aView, 'Sigla...............: ' + substr(ZAB->ZAB_TEXTO,36,2))
					aadd(aView, 'CPF do Avalista.....: ' + iif(substr(ZAB->ZAB_TEXTO,38,1) == 'S', 'Sim', 'Não'))
					aadd(aView, 'Moeda...............: ' + substr(ZAB->ZAB_TEXTO,39,3))
					aadd(aView, 'Valor...............: ' + substr(ZAB->ZAB_TEXTO,42,9))
					aadd(aView, 'Contrato............: ' + substr(ZAB->ZAB_TEXTO,51,17))
					aadd(aView, 'Instituição.........: ' + substr(ZAB->ZAB_TEXTO,68,20))
					aadd(aView, 'Filial..............: ' + substr(ZAB->ZAB_TEXTO,88,4))
					aadd(aView, 'Qtd.Ocorrência......: ' + substr(ZAB->ZAB_TEXTO,92,5))
					aadd(aView, 'Cód.Instituição.....: ' + substr(ZAB->ZAB_TEXTO,97,4))
					aadd(aView, 'Subjudice...........: ' + substr(ZAB->ZAB_TEXTO,101,1))
					aadd(aView, 'UF..................: ' + substr(ZAB->ZAB_TEXTO,102,2))
				Case ZAB->ZAB_CODIGO == 'B38L'
					if ZAB->ZAB_LINHA == '001'
						aadd(aView, PadC(' [ REFIN - DETALHE SUBJUDICE ] ', 115, '-'))
						aadd(aView, 'Praça | Distrito | Vara | Data     | Processo')
					endif
					aadd(aView, substr(ZAB->ZAB_TEXTO,1,4) + '  | ' + substr(ZAB->ZAB_TEXTO,5,2) + '       | ' + substr(ZAB->ZAB_TEXTO,7,2) + '   | ' + dtoc(stod( substr(ZAB->ZAB_TEXTO,9,8) )) + ' | ' + substr(ZAB->ZAB_TEXTO,17,16))
				Case ZAB->ZAB_CODIGO == 'R999'
					if ZAB->ZAB_LINHA == '001'
						aadd(aView, '')
						aadd(aView, PadC(' [ MENSAGENS ] ', 115, '-'))
					endif
					aadd(aView, substr(ZAB->ZAB_TEXTO,1,115))
			EndCase
	
		//Se RELATO e CONTROLE SOCIETARIO
		elseif nTipo == 3 .and. _nFolder == 3
			Do Case
				Case ZAB->ZAB_CODIGO == 'R107'
					aadd(aView, PadC(' [ CONTROLE SOCIETÁRIO ] ', 115, '-'))
					aadd(aView, 'Última Atualização..: ' + dtoc(stod( substr(ZAB->ZAB_TEXTO,1,8)) ))
					aadd(aView, 'Vlr Capital Social..: ' + substr(ZAB->ZAB_TEXTO,9,13))
					aadd(aView, 'Vlr Capital Realizad: ' + substr(ZAB->ZAB_TEXTO,22,13))
					aadd(aView, 'Vlr Capital Autoriza: ' + substr(ZAB->ZAB_TEXTO,35,13))
					aadd(aView, 'Descr. Nacionalidade: ' + substr(ZAB->ZAB_TEXTO,48,12))
					aadd(aView, 'Descr. Origem.......: ' + substr(ZAB->ZAB_TEXTO,60,12))
					aadd(aView, 'Descr. Natureza.....: ' + substr(ZAB->ZAB_TEXTO,72,12))
					aadd(aView, 'Base Junta Comercial: ' + iif(empty(substr(ZAB->ZAB_TEXTO,84,1)), 'Não', 'Sim'))
				Case ZAB->ZAB_CODIGO == 'R108'
					_cTp := ''
					if val(substr(ZAB->ZAB_TEXTO,13,4)) == 0
							_cTp := 'Oficial  '
					elseif val(substr(ZAB->ZAB_TEXTO,13,4)) == 50
							_cTp := 'Atribuído'
					elseif val(substr(ZAB->ZAB_TEXTO,13,4)) == 99
							_cTp := 'Não Conf.'
					Endif
					_cSt := ''				
					if substr(ZAB->ZAB_TEXTO,110,2) == '00'
							_cSt := 'Inapta'
					elseif substr(ZAB->ZAB_TEXTO,110,2) == '02'
							_cSt := 'Ativa'
					elseif substr(ZAB->ZAB_TEXTO,110,2) == '03'
							_cSt := 'Inativa'
					elseif substr(ZAB->ZAB_TEXTO,110,2) == '04'
							_cSt := 'Não Localizada'
					elseif substr(ZAB->ZAB_TEXTO,110,2) == '05'
							_cSt := 'Em Liquidação'
					elseif substr(ZAB->ZAB_TEXTO,110,2) == '06'
							_cSt := 'Suspenso'
					elseif substr(ZAB->ZAB_TEXTO,110,2) == '07'
							_cSt := 'Não Cadastrada'
					elseif substr(ZAB->ZAB_TEXTO,110,2) == '09'
							_cSt := 'Cancelado'
					Endif
	
					if ZAB->ZAB_LINHA == '001'
						aadd(aView, '')
						aadd(aView, PadC(' [ CONTROLE SOCIETÁRIO - DETALHE DOS SÓCIOS ] ', 152, '-'))
						aadd(aView, 'Pessoa   | CPF ou CNPJ              | Nome                                     | Nacionalidade | %Capital | Dt.Entrada | Ind.Restr.| %Cap.Votante | Situação')					
					endif
					aadd(aView, iif(substr(ZAB->ZAB_TEXTO,1,1) == 'F', 'Física  ', 'Jurídica') + ' | ' + substr(ZAB->ZAB_TEXTO,2,9) + '-' + substr(ZAB->ZAB_TEXTO,11,2) + ' - ' + _cTp + ' | ' + substr(ZAB->ZAB_TEXTO,17,40) + ' | ' + substr(ZAB->ZAB_TEXTO,81,12) + '  | ' + substr(ZAB->ZAB_TEXTO,93,3) + '.' + substr(ZAB->ZAB_TEXTO,96,1) + '    | ' + dtoc(stod( substr(ZAB->ZAB_TEXTO,97,8)) ) + ' | ' + substr(ZAB->ZAB_TEXTO,105,1) + '         | ' + substr(ZAB->ZAB_TEXTO,106,3) + '.' + substr(ZAB->ZAB_TEXTO,109,1) + '        | ' + _cSt)
			EndCase
	
		//Se RELATO e QUADRO ADMINISTRATIVO
		elseif nTipo == 3 .and. _nFolder == 4
			Do Case
				Case ZAB->ZAB_CODIGO == 'R109'
					aadd(aView, PadC(' [ QUADRO ADMINISTRATIVO ] ', 115, '-'))
					aadd(aView, 'Última Atualização..: ' + dtoc(stod( substr(ZAB->ZAB_TEXTO,1,8)) ))
					aadd(aView, 'Base Junta Comercial: ' + iif(empty(substr(ZAB->ZAB_TEXTO,9,1)), 'Não', 'Sim'))
				Case ZAB->ZAB_CODIGO == 'R110'
					if ZAB->ZAB_LINHA == '001'
						aadd(aView, '')
						aadd(aView, PadC(' [ QUADRO ADMINISTRATIVO - DETALHES ] ', 115, '-'))
						aadd(aView, 'Tipo da Pessoa | CPF ou CNPJ    | Nome Administrador                                         | Cargo         | Nacionalidade')					
					endif
					
					aadd(aView, iif(substr(ZAB->ZAB_TEXTO,1,1) == 'F', 'Física         ', 'Jurídica       ') + '| ' + substr(ZAB->ZAB_TEXTO,2,9) + ' - ' + substr(ZAB->ZAB_TEXTO,11,2) + ' | ' + substr(ZAB->ZAB_TEXTO,13,58) + ' | ' + substr(ZAB->ZAB_TEXTO,71,12) + '  | ' + substr(ZAB->ZAB_TEXTO,83,12))
				Case ZAB->ZAB_CODIGO == 'R111'
					_cTp := ''
					if val(substr(ZAB->ZAB_TEXTO,13,4)) == 0
							_cTp := 'Oficial       '
					elseif val(substr(ZAB->ZAB_TEXTO,13,4)) == 50
							_cTp := 'Atribuído     '
					elseif val(substr(ZAB->ZAB_TEXTO,13,4)) == 99
							_cTp := 'Não Confirmado'
					Endif
					_cSt := ''				
					if substr(ZAB->ZAB_TEXTO,46,2) == '00'
							_cSt := 'Inapta'
					elseif substr(ZAB->ZAB_TEXTO,46,2) == '02'
							_cSt := 'Ativa'
					elseif substr(ZAB->ZAB_TEXTO,46,2) == '03'
							_cSt := 'Inativa'
					elseif substr(ZAB->ZAB_TEXTO,46,2) == '04'
							_cSt := 'Não Localizada'
					elseif substr(ZAB->ZAB_TEXTO,46,2) == '05'
							_cSt := 'Em Liquidação'
					elseif substr(ZAB->ZAB_TEXTO,46,2) == '06'
							_cSt := 'Suspenso'
					elseif substr(ZAB->ZAB_TEXTO,46,2) == '07'
							_cSt := 'Não Cadastrada'
					elseif substr(ZAB->ZAB_TEXTO,46,2) == '09'
							_cSt := 'Cancelado'
					Endif
	
					if ZAB->ZAB_LINHA == '001'
						aadd(aView, '')
						aadd(aView, PadC(' [ QUADRO ADMINISTRATIVO (Detalhes Cont.) ] ', 115, '-'))
						aadd(aView, 'Tipo da Pessoa | CPF ou CNPJ                     | Estado Civil | Dt.Entrada | Dt.Final Mandato | Indicador Restrição | Cód.Cargo | Situação')					
					endif
	
					aadd(aView, iif(substr(ZAB->ZAB_TEXTO,1,1) == 'F', 'Física         ', 'Jurídica       ') + '| ' + substr(ZAB->ZAB_TEXTO,2,9) + ' - ' + substr(ZAB->ZAB_TEXTO,11,2) + ' - ' + _cTp + ' | ' + substr(ZAB->ZAB_TEXTO,17,9) + '    | ' + dtoc(stod( substr(ZAB->ZAB_TEXTO,26,8) )) + ' | ' + substr(ZAB->ZAB_TEXTO,34,8) + '         | ' + substr(ZAB->ZAB_TEXTO,42,1) + '                   | ' + substr(ZAB->ZAB_TEXTO,43,3) + '       | ' + _cSt)
			EndCase
	
		//Se RELATO e PARTICIPAÇÕES
		elseif nTipo == 3 .and. _nFolder == 5
			Do Case
				Case ZAB->ZAB_CODIGO == 'R112'
					aadd(aView, PadC(' [ PARTICIPAÇÕES (Atualização) ] ', 115, '-'))
					aadd(aView, 'Última Atualização..: ' + dtoc(stod( substr(ZAB->ZAB_TEXTO,1,8)) ))
					aadd(aView, 'Base Junta Comercial: ' + iif(empty(substr(ZAB->ZAB_TEXTO,9,1)), 'Não', 'Sim'))
				Case ZAB->ZAB_CODIGO == 'R113'
					_cTp := ''
					if val(substr(ZAB->ZAB_TEXTO,13,4)) == 0
							_cTp := 'Oficial         '
					elseif val(substr(ZAB->ZAB_TEXTO,13,4)) == 50
							_cTp := 'Atribuído       '
					elseif val(substr(ZAB->ZAB_TEXTO,13,4)) == 99
							_cTp := 'Não Confirmado  '
					Endif
					_cSt := ''				
					if substr(ZAB->ZAB_TEXTO,78,2) == '00'
							_cSt := 'Inapta'
					elseif substr(ZAB->ZAB_TEXTO,78,2) == '02'
							_cSt := 'Ativa'
					elseif substr(ZAB->ZAB_TEXTO,78,2) == '03'
							_cSt := 'Inativa'
					elseif substr(ZAB->ZAB_TEXTO,78,2) == '04'
							_cSt := 'Não Localizada'
					elseif substr(ZAB->ZAB_TEXTO,78,2) == '05'
							_cSt := 'Em Liquidação'
					elseif substr(ZAB->ZAB_TEXTO,78,2) == '06'
							_cSt := 'Suspenso'
					elseif substr(ZAB->ZAB_TEXTO,78,2) == '07'
							_cSt := 'Não Cadastrada'
					elseif substr(ZAB->ZAB_TEXTO,78,2) == '09'
							_cSt := 'Cancelado'
					Endif
					
					if ZAB->ZAB_LINHA == '001'
						aadd(aView, '')
						aadd(aView, PadC(' [ PARTICIPAÇÕES - DETALHE DA PARTICIPADA ] ', 152, '-'))
						aadd(aView, 'Tipo da Pessoa | CPF ou CNPJ                      | Empresa Ligada                                               | Indicador Restrição | Situação')					
					endif
					aadd(aView, iif(substr(ZAB->ZAB_TEXTO,1,1) == 'F', 'Física         ', 'Jurídica       ') + '| ' + substr(ZAB->ZAB_TEXTO,2,9) + iif(substr(ZAB->ZAB_TEXTO,11,2) <> '00', ' - ' + substr(ZAB->ZAB_TEXTO,11,2), ' -   ') + ' - ' + _cTp + '| ' + substr(ZAB->ZAB_TEXTO,17,60) + ' | ' + substr(ZAB->ZAB_TEXTO,77,1) + '                   | ' + _cSt)
				Case ZAB->ZAB_CODIGO == 'R114'
					if ZAB->ZAB_LINHA == '001'
						aadd(aView, '')
						aadd(aView, PadC(' [ PARTICIPAÇÕES (Detalhes Participantes) ] ', 115, '-'))
						aadd(aView, 'Tipo da Pessoa | CPF ou CNPJ    | Nome Participante')					
					endif
					aadd(aView, iif(substr(ZAB->ZAB_TEXTO,1,1) == 'F', 'Física         ', 'Jurídica       ') + '| ' + substr(ZAB->ZAB_TEXTO,2,9) + ' - ' + substr(ZAB->ZAB_TEXTO,11,2) + ' | ' + substr(ZAB->ZAB_TEXTO,13,67))
				Case ZAB->ZAB_CODIGO == 'R115'
					_cTp := ''
					if val(substr(ZAB->ZAB_TEXTO,13,4)) == 0
							_cTp := 'Oficial         '
					elseif val(substr(ZAB->ZAB_TEXTO,13,4)) == 50
							_cTp := 'Atribuído       '
					elseif val(substr(ZAB->ZAB_TEXTO,13,4)) == 99
							_cTp := 'Não Confirmado  '
					Endif
					_cSt := ''				
					if substr(ZAB->ZAB_TEXTO,68,2) == '00'
							_cSt := 'Inapta'
					elseif substr(ZAB->ZAB_TEXTO,68,2) == '02'
							_cSt := 'Ativa'
					elseif substr(ZAB->ZAB_TEXTO,68,2) == '03'
							_cSt := 'Inativa'
					elseif substr(ZAB->ZAB_TEXTO,68,2) == '04'
							_cSt := 'Não Localizada'
					elseif substr(ZAB->ZAB_TEXTO,68,2) == '05'
							_cSt := 'Em Liquidação'
					elseif substr(ZAB->ZAB_TEXTO,68,2) == '06'
							_cSt := 'Suspenso'
					elseif substr(ZAB->ZAB_TEXTO,68,2) == '07'
							_cSt := 'Não Cadastrada'
					elseif substr(ZAB->ZAB_TEXTO,68,2) == '09'
							_cSt := 'Cancelado'
					Endif
					if ZAB->ZAB_LINHA == '001'
						aadd(aView, '')
						aadd(aView, PadC(' [ PARTICIPAÇÕES (Detalhes Participantes - Cont.) ] ', 157, '-'))
						aadd(aView, 'Tipo da Pessoa | CPF ou CNPJ                      | Vinculo   | Cod.Embratel | Cidade Embratel                | UF | % Part. | Indicador Restrição | Situação')					
					endif
					aadd(aView, iif(substr(ZAB->ZAB_TEXTO,1,1) == 'F', 'Física         ', 'Jurídica       ') + '| ' + substr(ZAB->ZAB_TEXTO,2,9) +  ' - ' + substr(ZAB->ZAB_TEXTO,11,2) + ' - ' + _cTp + '| ' + substr(ZAB->ZAB_TEXTO,17,9) + ' | ' + substr(ZAB->ZAB_TEXTO,26,4) + '         | ' + substr(ZAB->ZAB_TEXTO,30,30) + ' | ' + substr(ZAB->ZAB_TEXTO,60,2) + ' | ' + substr(ZAB->ZAB_TEXTO,62,5) + '   | ' + substr(ZAB->ZAB_TEXTO,67,1) + '                   | ' + _cSt)
				Case ZAB->ZAB_CODIGO == 'R119'
					/*
					aadd(aView, '')
					aadd(aView, PadC(' [ ANTECESSORA ] ', 115, '-'))
					aadd(aView, 'Razão Social........: ' + substr(ZAB->ZAB_TEXTO,1,70))
					aadd(aView, 'Data do Mandato.....: ' + dtoc(stod( substr(ZAB->ZAB_TEXTO,71,9)) ))
					aadd(aView, 'Data da Atualização.: ' + dtoc(stod( substr(ZAB->ZAB_TEXTO,80,9)) ))
					*/
					if ZAB->ZAB_LINHA == '001'
						aadd(aView, '')
						aadd(aView, PadC(' [ ANTECESSORA ] ', 157, '-'))
						aadd(aView, 'Razão Social                                                           | Dt.Mandato | Dt.Atualização')					
					endif
					aadd(aView, substr(ZAB->ZAB_TEXTO,1,70) + ' | ' + dtoc(stod( substr(ZAB->ZAB_TEXTO,71,9)) ) +  ' | ' + dtoc(stod( substr(ZAB->ZAB_TEXTO,80,9)) ))
			EndCase
			
		//Se RELATO e FORNECEDORES
		elseif nTipo == 3 .and. _nFolder == 6
			Do Case
				Case ZAB->ZAB_CODIGO == 'R200'
					aadd(aView, PadC(' [ PRINCIPAIS FONTES ] ', 115, '-'))
					aadd(aView, 'Última Atualização..: ' + dtoc(stod( substr(ZAB->ZAB_TEXTO,1,8)) ))
					aadd(aView, 'Segmento da Origem..: ' + substr(ZAB->ZAB_TEXTO,9,3))
				Case ZAB->ZAB_CODIGO == 'R011'
					aadd(aView, '')
					aadd(aView, PadC(' [ PRINCIPAIS FONTES  - ANALÍTICO ] ', 115, '-'))
					aadd(aView, 'Nome da Fonte.......: ' + substr(ZAB->ZAB_TEXTO,1,70))
					aadd(aView, 'CGC da Fonte........: ' + substr(ZAB->ZAB_TEXTO,71,9))
					aadd(aView, 'Filial..............: ' + substr(ZAB->ZAB_TEXTO,80,4))
					aadd(aView, 'Dígito Controle.....: ' + substr(ZAB->ZAB_TEXTO,84,2))
					aadd(aView, 'Segmento da Fonte...: ' + substr(ZAB->ZAB_TEXTO,86,3))
				Case ZAB->ZAB_CODIGO == 'R012'
					aadd(aView, '')
					aadd(aView, PadC(' [ RELACIONAMENTO COM FORNECEDORES ] ', 115, '-'))
					aadd(aView, 'Qtd.Fontes Informac.: ' + substr(ZAB->ZAB_TEXTO,1,4))
					aadd(aView, 'Perfil Pagamentos...: ' + substr(ZAB->ZAB_TEXTO,5,4))
					aadd(aView, 'Evolução Compromisso: ' + substr(ZAB->ZAB_TEXTO,9,4))
					aadd(aView, 'Potencial Negócios..: ' + substr(ZAB->ZAB_TEXTO,13,4))
					aadd(aView, 'Potenc. Neg. a Vista: ' + substr(ZAB->ZAB_TEXTO,17,4))
					aadd(aView, 'Segmento da Origem..: ' + substr(ZAB->ZAB_TEXTO,21,3))
					aadd(aView, 'Qtd.Fontes-Hist.Pag.: ' + substr(ZAB->ZAB_TEXTO,24,4))
				Case ZAB->ZAB_CODIGO == 'R013'
					aadd(aView, '')
					aadd(aView, PadC(' [ RELACIONAMENTO FORNECEDOR POR PERIODO ] ', 115, '-'))
					aadd(aView, 'Descrição do Período: ' + substr(ZAB->ZAB_TEXTO,1,14))
					aadd(aView, 'Qtd. Fontes.........: ' + substr(ZAB->ZAB_TEXTO,15,4))
					aadd(aView, 'Segmento da Origem..: ' + substr(ZAB->ZAB_TEXTO,19,3))
				Case ZAB->ZAB_CODIGO == 'R201'
					aadd(aView, '')
					aadd(aView, PadC(' [ RELACIONAMENTO FORNECEDOR MAIS ANTIGO ] ', 115, '-'))
					aadd(aView, 'Descrição do Mês....: ' + substr(ZAB->ZAB_TEXTO,1,3))
					aadd(aView, 'Ano.................: ' + substr(ZAB->ZAB_TEXTO,4,2))
					aadd(aView, 'Mês.................: ' + substr(ZAB->ZAB_TEXTO,6,2))
				Case ZAB->ZAB_CODIGO == 'R205'
					if ZAB->ZAB_LINHA == '001'
						aadd(aView, '')
						aadd(aView, PadC(' [ PERFIL DE PAGAMENTOS - ANALÍTICO ] ', 115, '-'))
						aadd(aView, 'Descr. Período | Ano Pagto | Mês Pagto | Descr.Mês | Valor         | % Pagto | Segmento Origem')					
					endif
					aadd(aView, substr(ZAB->ZAB_TEXTO,1,14) + ' | ' + substr(ZAB->ZAB_TEXTO,15,2) + '        | ' + substr(ZAB->ZAB_TEXTO,17,2) + '        | ' + substr(ZAB->ZAB_TEXTO,19,3) + '       | ' + substr(ZAB->ZAB_TEXTO,22,13) + ' | ' + substr(ZAB->ZAB_TEXTO,35,3) + '.' + substr(ZAB->ZAB_TEXTO,38,1) + '   | ' + substr(ZAB->ZAB_TEXTO,39,3))
				Case ZAB->ZAB_CODIGO == 'R206'
					if ZAB->ZAB_LINHA == '001'
						aadd(aView, '')
						aadd(aView, PadC(' [ EVOLUÇÃO COMPROMISSOS - ANALÍTICO ] ', 115, '-'))
						aadd(aView, 'Ano | Mês | Descr.Mês | Vlr Vencido   | Vlr a Vencer  | Segmento Origem')					
					endif
					aadd(aView, substr(ZAB->ZAB_TEXTO,1,2) + '  | ' + substr(ZAB->ZAB_TEXTO,3,2) + '  | ' + substr(ZAB->ZAB_TEXTO,5,3) + '       | ' + substr(ZAB->ZAB_TEXTO,8,13) + ' | ' + substr(ZAB->ZAB_TEXTO,21,13) + ' | ' + substr(ZAB->ZAB_TEXTO,34,3))
				Case ZAB->ZAB_CODIGO == 'R202'
					if ZAB->ZAB_LINHA == '001'
						aadd(aView, '')
						aadd(aView, PadC(' [ POTENCIAL DE NEGÓCIOS ] ', 115, '-'))
						aadd(aView, 'Descrição      | Data       | Valor         | Média         | Segmento')					
					endif
					aadd(aView, substr(ZAB->ZAB_TEXTO,1,14) + ' | ' + dtoc(stod( substr(ZAB->ZAB_TEXTO,15,8) )) + ' | ' + substr(ZAB->ZAB_TEXTO,23,13) + ' | ' + substr(ZAB->ZAB_TEXTO,36,13) + ' | ' + substr(ZAB->ZAB_TEXTO,49,3))
				Case ZAB->ZAB_CODIGO == 'R203'
					if ZAB->ZAB_LINHA == '001'
						aadd(aView, '')
						aadd(aView, PadC(' [ HISTÓRICO DE PAGAMENTOS ] ', 115, '-'))
						aadd(aView, 'Descr. Período | Qtd Período | % Período')					
					endif
					aadd(aView, substr(ZAB->ZAB_TEXTO,1,14) + ' | ' + substr(ZAB->ZAB_TEXTO,15,6) + '      | ' + substr(ZAB->ZAB_TEXTO,21,4))
			EndCase
			
		//Se RELATO e Informações de Passagem e Alerta
		elseif nTipo == 3 .and. _nFolder == 7
			Do Case
				Case ZAB->ZAB_CODIGO == 'R301'
					if ZAB->ZAB_LINHA == '001'
						aadd(aView, PadC(' [ CONTROLE DE CONSULTAS - PASSAGEM ] ', 115, '-'))
						aadd(aView, 'Ano | Mês | Descr.Mês | Qtd Consultas por Empresa | Qtd Consultas por Financeira')					
					endif
					aadd(aView, substr(ZAB->ZAB_TEXTO,1,2) + '  | ' + substr(ZAB->ZAB_TEXTO,3,2) + '  | ' + substr(ZAB->ZAB_TEXTO,5,3) + '       | ' + substr(ZAB->ZAB_TEXTO,8,3) + '                       | ' + substr(ZAB->ZAB_TEXTO,11,3))
				Case ZAB->ZAB_CODIGO == 'R302'
					_cTp := ''
					if substr(ZAB->ZAB_TEXTO,57,1) == '1'
							_cTp := 'Financeira'
					elseif substr(ZAB->ZAB_TEXTO,57,1) == '2'
							_cTp := 'Comercial'
					Endif
					
					if ZAB->ZAB_LINHA == '001'
						aadd(aView, '')
						aadd(aView, PadC(' [ ÚLTIMAS CONSULTAS ] ', 115, '-'))
						aadd(aView, 'Data       | Nome                                | Qtd Consultas no Dia | CNPJ Consultado | Tipo Consultante')					
					endif
					aadd(aView, dtoc(stod( substr(ZAB->ZAB_TEXTO,1,8) )) + ' | ' + substr(ZAB->ZAB_TEXTO,9,35) + ' | ' + substr(ZAB->ZAB_TEXTO,44,4) + '                 | ' + substr(ZAB->ZAB_TEXTO,48,9) + '       | ' + _cTp)
				Case ZAB->ZAB_CODIGO == 'R303'
					if ZAB->ZAB_LINHA == '001'
						aadd(aView, '')
						aadd(aView, PadC(' [ FRASES DE ALERTA ] ', 115, '-'))
					endif
					aadd(aView, substr(ZAB->ZAB_TEXTO,1,111))
				Case ZAB->ZAB_CODIGO == 'R321'
					if ZAB->ZAB_LINHA == '001'
						aadd(aView, '')
						aadd(aView, PadC(' [ PARTICIPANTES COM ALERTA ] ', 115, '-'))
						aadd(aView, 'Nome                                                              | Documento   | Tipo')					
					endif
					aadd(aView, substr(ZAB->ZAB_TEXTO,1,65) + ' | ' + substr(ZAB->ZAB_TEXTO,66,11) + ' | ' + substr(ZAB->ZAB_TEXTO,77,1))
			EndCase
			
		//Se RELATO e CÁLCULO DO RISKSCORING
		elseif nTipo == 3 .and. _nFolder == 8
			Do Case
				Case ZAB->ZAB_CODIGO == 'R401'
					aadd(aView, PadC(' [ RISKSCORING ] ', 115, '-'))
					//aadd(aView, 'Data do Cálculo.....: ' + dtoc(stod( substr(ZAB->ZAB_TEXTO,1,8) )))
					aadd(aView, 'Data do Cálculo.....: ' + substr(ZAB->ZAB_TEXTO,1,2) + '/' + substr(ZAB->ZAB_TEXTO,3,2) + '/' + substr(ZAB->ZAB_TEXTO,5,4))
					aadd(aView, 'Hora do Cálculo.....: ' + substr(ZAB->ZAB_TEXTO,9,8))
					aadd(aView, 'Fator Riskscoring...: ' + substr(ZAB->ZAB_TEXTO,17,4))
					aadd(aView, 'Fator PRINAD........: ' + substr(ZAB->ZAB_TEXTO,21,3) + '.' + substr(ZAB->ZAB_TEXTO,24,2))
				Case ZAB->ZAB_CODIGO == 'R402'
					aadd(aView, PadC(' [ INFORMAÇÕES RISKSCORING / PRINAD ] ', 115, '-'))
					aadd(aView, 'Data................: ' + dtoc(stod( substr(ZAB->ZAB_TEXTO,1,8) )))
					aadd(aView, 'Hora................: ' + substr(ZAB->ZAB_TEXTO,9,8))
					aadd(aView, 'Descritivo..........: ' + substr(ZAB->ZAB_TEXTO,17,80))
				Case ZAB->ZAB_CODIGO == 'R403'
					aadd(aView, '')
					aadd(aView, PadC(' [ MENSAGENS RISKSCORING / PRINAD ] ', 115, '-'))
					//aadd(aView, 'Data................: ' + dtoc(stod( substr(ZAB->ZAB_TEXTO,1,8) )))
					aadd(aView, 'Data................: ' + substr(ZAB->ZAB_TEXTO,1,2) + '/' + substr(ZAB->ZAB_TEXTO,3,2) + '/' + substr(ZAB->ZAB_TEXTO,5,4))
					aadd(aView, 'Hora................: ' + substr(ZAB->ZAB_TEXTO,9,8))
					aadd(aView, 'Descritivo..........: ' + substr(ZAB->ZAB_TEXTO,17,94))
				Case ZAB->ZAB_CODIGO == 'R404'
					aadd(aView, '')
					aadd(aView, PadC(' [ RISKSCORING (6 meses) ] ', 115, '-'))
					aadd(aView, 'Data do Cálculo.....: ' + substr(ZAB->ZAB_TEXTO,1,2) + '/' + substr(ZAB->ZAB_TEXTO,3,2) + '/' + substr(ZAB->ZAB_TEXTO,5,4))
					aadd(aView, 'Hora do Cálculo.....: ' + substr(ZAB->ZAB_TEXTO,9,8))
					aadd(aView, 'Fator Riskscoring...: ' + substr(ZAB->ZAB_TEXTO,17,4))
					aadd(aView, 'Fator PRINAD........: ' + substr(ZAB->ZAB_TEXTO,21,3) + '.' + substr(ZAB->ZAB_TEXTO,24,2))
			EndCase
		endif
	
	
		ZAB->(dbSkip())
	End

	
    If nTipo == 1 .and. _nFolder == 4
	    If (!lPassou .And. !lEntrou)
				aadd(aView, 'Mensagem.............: NÃO CONSTAM ENDEREÇOS / FONES ALTERNATIVOS')
				aadd(aView, '')            
		EndIf  
	EndIf			

	
	//Se CREDNET
	if nTipo == 2
		For _v := 1 to len(aV23000)
			aadd(aView , aV23000[_v] )
		next
		For _v := 1 to len(aV23090)
			aadd(aView , aV23090[_v] )
		next
		For _v := 1 to len(aV24000)
			aadd(aView , aV24000[_v] )
		next
		For _v := 1 to len(aV24001)
			aadd(aView , aV24001[_v] )
		next
		For _v := 1 to len(aV24090)
			aadd(aView , aV24090[_v] )
		next
		For _v := 1 to len(aV25000)
			aadd(aView , aV25000[_v] )
		next
		For _v := 1 to len(aV25001)
			aadd(aView , aV25001[_v] )
		next
		For _v := 1 to len(aV25090)
			aadd(aView , aV25090[_v] )
		next
		For _v := 1 to len(aV26090)
			aadd(aView , aV26090[_v] )
		next
		For _v := 1 to len(aV27090)
			aadd(aView , aV27090[_v] )
		next
		For _v := 1 to len(aV41000)
			aadd(aView , aV41000[_v] )
		next
		For _v := 1 to len(aV42000)
			aadd(aView , aV42000[_v] )
		next
		For _v := 1 to len(aV43000)
			aadd(aView , aV43000[_v] )
		next
		For _v := 1 to len(aV44003)
			aadd(aView , aV44003[_v] )
		next
		For _v := 1 to len(aV37001)
			aadd(aView , aV37001[_v] )
		next
		For _v := 1 to len(aV37002)
			aadd(aView , aV37002[_v] )
		next
	endif

Return


/*
+--------------------+-----------------------------------------------------------+
!Descricao				! Funcao para direcionar qual folder mostrar					! 
+--------------------+-----------------------------------------------------------+
!Autor             	! 																	!
+--------------------+-----------------------------------------------------------+
!Data de Criacao   	! 11/10/2014														!
+--------------------+-----------------------------------------------------------+
*/
Static Function stCnsFld( _folder )
	
	&('cView'+alltrim(str(_folder,2))) := ''
	aView := {}
	Poqrydet( _folder )	//Busca a consulta
	for _x:= 1 to len(aView)
		&('cView'+alltrim(str(_folder,2))) += aView[_x] + chr(13) + chr(10)
	next
	
	if len(aView)*10 <= 400
		&('oSay'+alltrim(str(_folder,2))):nHeight := 500
	else
		&('oSay'+alltrim(str(_folder,2))):nHeight := len(aView)*10
	endif
	
	&('oSay'+alltrim(str(_folder,2))):Refresh()
	
Return


//Criar objetos, conforme produto consultado
Static Function stCreatObj()
	
	Do Case
		Case nTipo == 1	//Credit Bureau
			@ 000,000 SCROLLBOX oScroll1 VERTICAL SIZE aPosObj[3,3]-40,aPosObj[1,3]+4 OF oFolder:aDialogs[1] BORDER
			@ 002,002 GET oSay1 VAR cView1 MEMO FONT oFont0 SIZE aPosObj[1,3]+7,10 OF oScroll1 PIXEL
			oSay1:bRClicked := {||AllwaysTrue()}
	
			@ 000,000 SCROLLBOX oScroll2 VERTICAL SIZE aPosObj[3,3]-40,aPosObj[1,3]+4 OF oFolder:aDialogs[2] BORDER
			@ 002,002 GET oSay2 VAR cView2 MEMO FONT oFont0 SIZE aPosObj[1,3]+7,10 OF oScroll2 PIXEL
			oSay2:bRClicked := {||AllwaysTrue()}
	
			@ 000,000 SCROLLBOX oScroll3 VERTICAL SIZE aPosObj[3,3]-40,aPosObj[1,3]+4 OF oFolder:aDialogs[3] BORDER
			@ 002,002 GET oSay3 VAR cView3 MEMO FONT oFont0 SIZE aPosObj[1,3]+7,10 OF oScroll3 PIXEL
			oSay3:bRClicked := {||AllwaysTrue()}
	
			@ 000,000 SCROLLBOX oScroll4 VERTICAL SIZE aPosObj[3,3]-40,aPosObj[1,3]+4 OF oFolder:aDialogs[4] BORDER
			@ 002,002 GET oSay4 VAR cView4 MEMO FONT oFont0 SIZE aPosObj[1,3]+7,10 OF oScroll4 PIXEL
			oSay4:bRClicked := {||AllwaysTrue()}
	
		Case nTipo == 2	//Crednet
			@ 000,000 SCROLLBOX oScroll1 VERTICAL SIZE aPosObj[3,3]-40,aPosObj[1,3]+4 OF oFolder:aDialogs[1] BORDER
			@ 002,002 GET oSay1 VAR cView1 MEMO FONT oFont0 SIZE aPosObj[1,3]+7,10 OF oScroll1 PIXEL
			oSay1:bRClicked := {||AllwaysTrue()}
	
			@ 000,000 SCROLLBOX oScroll2 VERTICAL SIZE aPosObj[3,3]-40,aPosObj[1,3]+4 OF oFolder:aDialogs[2] BORDER
			@ 002,002 GET oSay2 VAR cView2 MEMO FONT oFont0 SIZE aPosObj[1,3]+7,10 OF oScroll2 PIXEL
			oSay2:bRClicked := {||AllwaysTrue()}
	
			@ 000,000 SCROLLBOX oScroll3 VERTICAL SIZE aPosObj[3,3]-40,aPosObj[1,3]+4 OF oFolder:aDialogs[3] BORDER
			@ 002,002 GET oSay3 VAR cView3 MEMO FONT oFont0 SIZE aPosObj[1,3]+7,10 OF oScroll3 PIXEL
			oSay3:bRClicked := {||AllwaysTrue()}
	
			@ 000,000 SCROLLBOX oScroll4 VERTICAL SIZE aPosObj[3,3]-40,aPosObj[1,3]+4 OF oFolder:aDialogs[4] BORDER
			@ 002,002 GET oSay4 VAR cView4 MEMO FONT oFont0 SIZE aPosObj[1,3]+7,10 OF oScroll4 PIXEL
			oSay4:bRClicked := {||AllwaysTrue()}
	
			@ 000,000 SCROLLBOX oScroll5 VERTICAL SIZE aPosObj[3,3]-40,aPosObj[1,3]+4 OF oFolder:aDialogs[5] BORDER
			@ 002,002 GET oSay5 VAR cView5 MEMO FONT oFont0 SIZE aPosObj[1,3]+7,10 OF oScroll5 PIXEL
			oSay5:bRClicked := {||AllwaysTrue()}
	
			@ 000,000 SCROLLBOX oScroll6 VERTICAL SIZE aPosObj[3,3]-40,aPosObj[1,3]+4 OF oFolder:aDialogs[6] BORDER
			@ 002,002 GET oSay6 VAR cView6 MEMO FONT oFont0 SIZE aPosObj[1,3]+7,10 OF oScroll6 PIXEL
			oSay6:bRClicked := {||AllwaysTrue()}
	
			@ 000,000 SCROLLBOX oScroll7 VERTICAL SIZE aPosObj[3,3]-40,aPosObj[1,3]+4 OF oFolder:aDialogs[7] BORDER
			@ 002,002 GET oSay7 VAR cView7 MEMO FONT oFont0 SIZE aPosObj[1,3]+7,10 OF oScroll7 PIXEL
			oSay7:bRClicked := {||AllwaysTrue()}
	
			@ 000,000 SCROLLBOX oScroll8 VERTICAL SIZE aPosObj[3,3]-40,aPosObj[1,3]+4 OF oFolder:aDialogs[8] BORDER
			@ 002,002 GET oSay8 VAR cView8 MEMO FONT oFont0 SIZE aPosObj[1,3]+7,10 OF oScroll8 PIXEL
			oSay8:bRClicked := {||AllwaysTrue()}
	
			@ 000,000 SCROLLBOX oScroll9 VERTICAL SIZE aPosObj[3,3]-40,aPosObj[1,3]+4 OF oFolder:aDialogs[9] BORDER
			@ 002,002 GET oSay9 VAR cView9 MEMO FONT oFont0 SIZE aPosObj[1,3]+7,10 OF oScroll9 PIXEL
			oSay9:bRClicked := {||AllwaysTrue()}
	
			@ 000,000 SCROLLBOX oScroll10 VERTICAL SIZE aPosObj[3,3]-40,aPosObj[1,3]+4 OF oFolder:aDialogs[10] BORDER
			@ 002,002 GET oSay10 VAR cView10 MEMO FONT oFont0 SIZE aPosObj[1,3]+7,10 OF oScroll10 PIXEL
			oSay10:bRClicked := {||AllwaysTrue()}
	
		Case nTipo == 3	//Relato
			@ 000,000 SCROLLBOX oScroll1 VERTICAL SIZE aPosObj[3,3]-40,aPosObj[1,3]+4 OF oFolder:aDialogs[1] BORDER
			@ 002,002 GET oSay1 VAR cView1 MEMO FONT oFont0 SIZE aPosObj[1,3]+7,10 OF oScroll1 PIXEL
			oSay1:bRClicked := {||AllwaysTrue()}
	
			@ 000,000 SCROLLBOX oScroll2 VERTICAL SIZE aPosObj[3,3]-40,aPosObj[1,3]+4 OF oFolder:aDialogs[2] BORDER
			@ 002,002 GET oSay2 VAR cView2 MEMO FONT oFont0 SIZE aPosObj[1,3]+7,10 OF oScroll2 PIXEL
			oSay2:bRClicked := {||AllwaysTrue()}
	
			@ 000,000 SCROLLBOX oScroll3 VERTICAL SIZE aPosObj[3,3]-40,aPosObj[1,3]+4 OF oFolder:aDialogs[3] BORDER
			@ 002,002 GET oSay3 VAR cView3 MEMO FONT oFont0 SIZE aPosObj[1,3]+7,10 OF oScroll3 PIXEL
			oSay3:bRClicked := {||AllwaysTrue()}
	
			@ 000,000 SCROLLBOX oScroll4 VERTICAL SIZE aPosObj[3,3]-40,aPosObj[1,3]+4 OF oFolder:aDialogs[4] BORDER
			@ 002,002 GET oSay4 VAR cView4 MEMO FONT oFont0 SIZE aPosObj[1,3]+7,10 OF oScroll4 PIXEL
			oSay4:bRClicked := {||AllwaysTrue()}
	
			@ 000,000 SCROLLBOX oScroll5 VERTICAL SIZE aPosObj[3,3]-40,aPosObj[1,3]+4 OF oFolder:aDialogs[5] BORDER
			@ 002,002 GET oSay5 VAR cView5 MEMO FONT oFont0 SIZE aPosObj[1,3]+7,10 OF oScroll5 PIXEL
			oSay5:bRClicked := {||AllwaysTrue()}
	
			@ 000,000 SCROLLBOX oScroll6 VERTICAL SIZE aPosObj[3,3]-40,aPosObj[1,3]+4 OF oFolder:aDialogs[6] BORDER
			@ 002,002 GET oSay6 VAR cView6 MEMO FONT oFont0 SIZE aPosObj[1,3]+7,10 OF oScroll6 PIXEL
			oSay6:bRClicked := {||AllwaysTrue()}
	
			@ 000,000 SCROLLBOX oScroll7 VERTICAL SIZE aPosObj[3,3]-40,aPosObj[1,3]+4 OF oFolder:aDialogs[7] BORDER
			@ 002,002 GET oSay7 VAR cView7 MEMO FONT oFont0 SIZE aPosObj[1,3]+7,10 OF oScroll7 PIXEL
			oSay7:bRClicked := {||AllwaysTrue()}
	
			@ 000,000 SCROLLBOX oScroll8 VERTICAL SIZE aPosObj[3,3]-40,aPosObj[1,3]+4 OF oFolder:aDialogs[8] BORDER
			@ 002,002 GET oSay8 VAR cView8 MEMO FONT oFont0 SIZE aPosObj[1,3]+7,10 OF oScroll8 PIXEL
			oSay8:bRClicked := {||AllwaysTrue()}
	EndCase
	

return


/* Executa a atualizacao junto ao SERASA */
User Function FINA05AT( _nProduto )
	
	Local xTxt := ''
	
	/* APENAS PARA REALIZAR USO DA BASE HOMOLOGAÇÃO */
	//Local aCnpj	:= {"00000003000125","00002220000154","00002201000128","00002333000150","00002339000127","00002684000160","00002892000160","00002914000191","00002919000114","00003012000170","00003097000196"}
	//Local aCnpj		:= {"00000000191","00000000272","00000000353","00000000434","00000000515"}
	
	/* 
	Private _cCgc 	:= ''
	if alltrim(SA1->A1_COD) == '000001'
		_cCgc := aCnpj[1]
	elseif alltrim(SA1->A1_COD) == '000002'
		_cCgc := aCnpj[2]
	elseif alltrim(SA1->A1_COD) == '000003'
		_cCgc := aCnpj[3]
	elseif alltrim(SA1->A1_COD) == '000004'
		_cCgc := aCnpj[4]
	elseif alltrim(SA1->A1_COD) == '000005'
		_cCgc := aCnpj[5]
	elseif alltrim(SA1->A1_COD) == '000006'
		_cCgc := aCnpj[6]
	elseif alltrim(SA1->A1_COD) == '000007'
		_cCgc := aCnpj[7]
	elseif alltrim(SA1->A1_COD) == '000008'
		_cCgc := aCnpj[8]
	elseif alltrim(SA1->A1_COD) == '000009'
		_cCgc := aCnpj[9]
	elseif alltrim(SA1->A1_COD) == '000010'
		_cCgc := aCnpj[10]
	elseif alltrim(SA1->A1_COD) == '000011'
		_cCgc := aCnpj[11]
	endif
	*/
	/* FIM */
	
	Private _cCgc 	:= SA1->A1_CGC
	
	
	if _nProduto == 1
		xTxt := 'A ATUALIZAÇÃO DO PRODUTO ..: CREDIT BUREAU :.. IRÁ GERAR CUSTO PARA A EMPRESA.' + chr(13) + chr(10) + chr(13) + chr(10) + 'DESEJA CONTINUAR?'
	elseif _nProduto == 2
		xTxt := 'A ATUALIZAÇÃO DO PRODUTO ..: CREDNET :.. IRÁ GERAR CUSTO PARA A EMPRESA.' + chr(13) + chr(10) + chr(13) + chr(10) + 'DESEJA CONTINUAR?'
	elseif _nProduto == 3
		xTxt := 'A ATUALIZAÇÃO DO PRODUTO ..: RELATO :.. IRÁ GERAR CUSTO PARA A EMPRESA.' + chr(13) + chr(10) + chr(13) + chr(10) + 'DESEJA CONTINUAR?'
	endif
	
	
	//Realizar a integração com o Serasa
	if MSGYESNO( xTxt, "Integração com o SERASA" )
	
		MsAguarde({|lEnd| POINTSERASA(_nProduto) },"Aguarde...","Enviando solicitação de consulta ao SERASA!",.T.)
	
		alert('Busca dos dados finalizada!')
	
	endif

Return

Static Function POINTSERASA( _nProduto )
	//DADOS DO LINK
		
	//OUROLUX
	Local cLogSerasa	:= SUPERGETMV("SE_LOGSERA" ,.F., "93771518")//"56416302") 
	Local cPasSerasa	:= SUPERGETMV("SE_PASSERA", .F., "ouro2018")
	Local nTamSenha 	:= ''  
	Local nSenha 		:= ''  
	
	/* HOMOLOGAÇÃO
	   URL......: https://mqlinuxext.serasa.com.br            
	   PARAMETRO: /Homologa/consultahttps?p=
	
	   PRODUÇÃO
	   URL......: https://sitenet43.serasa.com.br
	   PARAMETRO: /Prod/consultahttps?p=
	*/
 //   Local cUrl			:= SUPERGETMV("SE_URLSERA", .f., "https://mqlinuxext.serasa.com.br")
 //	Local cParms		:= SUPERGETMV("SE_PARSERA", .f., "/Homologa/consultahttps?p=")
	Local cUrl			:= SUPERGETMV("SE_URLSERA", .f., "https://sitenet43.serasa.com.br")
 	Local cParms		:= SUPERGETMV("SE_PARSERA", .f., "/Prod/consultahttps?p=")
	
	Local _cStr := ""
	
	If Empty(cUrl) .Or. Empty(cParms) .Or. Empty(cLogSerasa) .Or. Empty(cPasSerasa)
		MsgInfo("Configuração SERASA inválida!", "Atenção")
		Return
	EndIf
	
	//Montagem do PROTOCOLO
	_cStr += "B49C" + space(6)

	//CNPJ - deve ser 15 caracteres, preenchendo com zeros na frente
	if len(alltrim(_cCgc)) < 14
		_cStr += "0000" + alltrim(_cCgc) + "FC     "
	else
		_cStr += "0" + alltrim(_cCgc) + "JC     "
	endif

	if _nProduto == 1 .or. _nProduto == 3
		_cStr += "FI"
	elseif _nProduto == 2 
		_cStr += "CH"
	endif
 
	//CREDIT BUREAU
	If _nProduto == 1	
		_cStr += "0000000" + space(12) + "N" + "99" + "S" + "INI" + "A" + "N" + space(42) + "00" + "P"  /*END + TEL */
		_cStr += space(8) + "000000000000000" + "S"  + space(9) + '1' +space(259)  
 
	//CREDNET
	ElseIf _nProduto == 2	      
		_cStr += "0001000" + "000000000000"/*space(12)*/ + "N" + "99" + "S" + "INI" + "A"/*tipo consulta*/ + "N" + space(30) +  "D" + space(13)                
    	_cStr += "N" + space(44)+  "06217362000180" +  space(235)
       //	_cStr +=  space(20) + "000000000000" + space(64)+ "0000000000000000"+ space(16) + "0" + space(35) + "00" + space(41)    
       
    ElseIf _nProduto == 3	
		_cStr += "0001000" + "000000000000"/*space(12)*/ + "N" + "99" + "S" + "INI" + "A" + "N" + space(42) + "00" + "S"  /*END + TEL */
	//	_cStr += "S" + space(7) + "000000000000000" + "N" + space(9) + '1'
		_cStr += space(7) + "S" + "000000000000000" + "N" + cLogSerasa + space(1) + '1'
		                                                                   /*00                    00000000*/
		_cStr += "99" /*PERIODO COMPRO. + PERIODO ENDERECO   */+ space(48) + "00" + space(20) + "00000000" + space(179)      /*000  */   
    
    EndIf   
    
	_cPrd := ''                                                                           
	//Montagem do Registro de Consulta
		//CREDIT BUREAU
	if _nProduto == 1
		_cPrd := 'CREDIT BUREAU  '

		_cStr += "P006" + "SSSSS" + space(2) 
		
		//pode ser '05' ou '99'
		_cStr += "05"
		
		_cStr += "SSSSSSSS SSSNNS" + space(87)

		//CREDNET
	elseif _nProduto == 2
		_cPrd := 'CREDNET        '
	
		_cStr += "P002" + "RE02"
		_cStr += space(107) 
		
  		//N001 Pendencias financeiras + Protesto Estadual
		_cStr += "N001" + "00" + "PP" + "X21P" + " " + "0" + space(101)      
		
		//N002
		 
 		       
		//RELATO
	elseif _nProduto == 3
		_cPrd := 'RELATO         '
		
		_cStr += "P002" + "IP20"
		_cStr += "QPR"	//Q=Quadro Social, P=Participacoes, R=Riskcoring
		//_cStr += "D"
		_cStr += " "
		_cStr += space(103)       
		
		//N
	endif                         
	
	
	//Registro Finalizador
	_cStr += "T999" //+ space(111)	


	//memowrite('protocolo.txt', cParms + cLogSerasa + cPasSerasa + space(8) + _cStr)
	MemoWrite('C:\Siga\protocolo.txt', cParms + cLogSerasa + cPasSerasa + space(8) + _cStr)

	_dData	:= dDataBase
	_cTime := time()
	cCpf   := alltrim(_cCgc) + space(14 - len(alltrim(_cCgc)))
	                                                               
	//ENVIAR SOLICITACAO
	oRestClient := FWRest():New(cUrl)
	aHeader := {} 
	
 	aAdd(aHeader, 'Content-type: text/x-json' )
	 	 
	lContinua := .F.                    
	
	If len(alltrim(cPasSerasa)) < 9
	    nSenha := 8 - len(alltrim(cPasSerasa)) 
	  	cPasSerasa := cPasSerasa + space(nSenha)
	Endif
   
	cLinha := escape(cLogSerasa + cPasSerasa + space(8) + (_cStr) )  
	
	// chamada da classe exemplo de REST com retorno de lista

	oRestClient:setPath(cParms + cLinha)
	If oRestClient:Get(aHeader)
	   //ConOut("GET", oRestClient:GetResult())
	 //  memowrite('R'+alltrim(_cCgc)+'.txt', oRestClient:GetResult())     
	 	   
	   cString := oRestClient:GetResult()
	 	   
	   //Gravar em tabela temporaria
		nTam := 515
		 
		nQtd := 515
		cBuffCon := ""
		
		nCol := 1
		
		While nQtd <= len(cString)
	
			cBuffer := substr(cString, nCol, nTam)
			nCol += nTam
			
			//Verificar se tem continuacao
			if substr(cBuffer, 58 ,3) == "CON"
				lContinua := .T.
				cBuffCon := substr(cBuffer, 1, nTam)
			endif
			
			if nTam == 515
				nTam := 115
			else
				
				cLinha := '000'
				ZAB->(dbSetOrder(1))
				
				ZAB->(dbSeek(xFilial('ZAB') + cCpf + dtos(_dData) + _cTime + '  ' + _cPrd + substr(cBuffer ,1 ,4), .T.))
				While ZAB->(!eof()) .and. ZAB->ZAB_FILIAL == xFilial('ZAB') .and.;
				                          ZAB->ZAB_CNPJ+dtos(ZAB->ZAB_DTCONS)+ZAB->ZAB_HRCONS+ZAB->ZAB_PRODUT+ZAB->ZAB_CODIGO == cCpf + dtos(_dData) + _cTime + '  ' + _cPrd + substr(cBuffer ,1 ,4)
					cLinha := soma1(cLinha)
					ZAB->(dbSkip())
				End
				cLinha := soma1(cLinha)
				
				ZAB->(recLock('ZAB', .T.))
				ZAB->ZAB_FILIAL	:= xFilial('ZAB')
				ZAB->ZAB_CNPJ		:= cCpf
				ZAB->ZAB_TIPO		:= iif(len(alltrim(cCpf)) < 14, 'F', 'J' )
				ZAB->ZAB_DTCONS	:= _dData
				ZAB->ZAB_HRCONS	:= _cTime
				ZAB->ZAB_PRODUT	:= _cPrd
				ZAB->ZAB_CODIGO	:= substr(cBuffer ,1 ,4)
				ZAB->ZAB_LINHA	:= cLinha
				ZAB->ZAB_TEXTO	:= substr(cBuffer ,5 ,111)
				ZAB->ZAB_CODUSR	:= __CUSERID
				ZAB->(msUnlock('ZAB'))
				
			endif
			nQtd += nTam
			loop
		
		End
		//aadd(aCols, {_dData, _cTime, _cPrd})	
		//aadd(oLbx:aArray, {_dData, _cTime, _cPrd})
	   
	Else
	   //ConOut("GET", oRestClient:GetLastError())
		
		ZAB->(recLock('ZAB', .T.))
		ZAB->ZAB_FILIAL	:= xFilial('ZAB')
		ZAB->ZAB_CNPJ		:= cCpf
		ZAB->ZAB_TIPO		:= iif(len(alltrim(cCpf)) < 14, 'F', 'J' )
		ZAB->ZAB_DTCONS	:= _dData
		ZAB->ZAB_HRCONS	:= _cTime
		ZAB->ZAB_PRODUT	:= _cPrd
		ZAB->ZAB_CODIGO	:= 'ERRO'
		ZAB->ZAB_LINHA	:= '001'
		ZAB->ZAB_TEXTO	:= oRestClient:GetLastError()
		ZAB->ZAB_CODUSR	:= __CUSERID
		ZAB->(msUnlock('ZAB'))
	EndIf

	if lContinua

		//ENVIAR SOLICITACAO DE CONTINUACAO
		oRestClient := FWRest():New(cUrl)
		aHeader := {} 
	 
		// chamada da classe exemplo de REST com retorno de lista
		oRestClient:setPath(cParms + cLogSerasa + cPasSerasa + escape(space(8) + cBuffCon + 'T999'))
		If oRestClient:Get(aHeader)
		
		   cString := oRestClient:GetResult()
		   
		   //Gravar em tabela temporaria
			nTam := 515
			nQtd := 515
			lContinua := .F.
			cBuffCon := ""
			
			nCol := 1
			
			While nQtd <= len(cString)
		
				cBuffer := substr(cString, nCol, nTam)
				nCol += nTam
				
				if nTam == 515
					nTam := 115
				else
					
					cLinha := '000'
					ZAB->(dbSetOrder(1))
					
					ZAB->(dbSeek(xFilial('ZAB') + cCpf + dtos(_dData) + _cTime + '  ' + _cPrd + substr(cBuffer ,1 ,4), .T.))
					While ZAB->(!eof()) .and. ZAB->ZAB_FILIAL == xFilial('ZAB') .and.;
					                          ZAB->ZAB_CNPJ+dtos(ZAB->ZAB_DTCONS)+ZAB->ZAB_HRCONS+ZAB->ZAB_PRODUT+ZAB->ZAB_CODIGO == cCpf + dtos(_dData) + _cTime + '  ' + _cPrd + substr(cBuffer ,1 ,4)
						cLinha := soma1(cLinha)
						ZAB->(dbSkip())
					End
					cLinha := soma1(cLinha)
					
					ZAB->(recLock('ZAB', .T.))
					ZAB->ZAB_FILIAL	:= xFilial('ZAB')
					ZAB->ZAB_CNPJ		:= cCpf
					ZAB->ZAB_TIPO		:= iif(len(alltrim(cCpf)) < 14, 'F', 'J' )
					ZAB->ZAB_DTCONS	:= _dData
					ZAB->ZAB_HRCONS	:= _cTime
					ZAB->ZAB_PRODUT	:= _cPrd
					ZAB->ZAB_CODIGO	:= substr(cBuffer ,1 ,4)
					ZAB->ZAB_LINHA	:= cLinha
					ZAB->ZAB_TEXTO	:= substr(cBuffer ,5 ,111)
					ZAB->ZAB_CODUSR	:= __CUSERID
					ZAB->(msUnlock('ZAB'))
					
				endif
				nQtd += nTam
				loop
			
			End
	
		Else
		   //ConOut("GET", oRestClient:GetLastError())
		
			ZAB->(recLock('ZAB', .T.))
			ZAB->ZAB_FILIAL	:= xFilial('ZAB')
			ZAB->ZAB_CNPJ		:= cCpf
			ZAB->ZAB_TIPO		:= iif(len(alltrim(cCpf)) < 14, 'F', 'J' )
			ZAB->ZAB_DTCONS	:= _dData
			ZAB->ZAB_HRCONS	:= _cTime
			ZAB->ZAB_PRODUT	:= _cPrd
			ZAB->ZAB_CODIGO	:= 'ERRO'
			ZAB->ZAB_LINHA	:= '001'
			ZAB->ZAB_TEXTO	:= oRestClient:GetLastError()
			ZAB->ZAB_CODUSR	:= __CUSERID
			ZAB->(msUnlock('ZAB'))
			
		endif
		
	endif
	
Return

//REVISAO 000 - FABRICIO EDUARDO RECHE - 02/06/2015 - 'Criação'