#Include "PROTHEUS.CH"
/*--------------------*/
User Function MA030ROT()
/*--------------------*/
	  Local aRot 		   := {}   
    Local aRotSerasa := {}
    Local aRotCisp   := {}
    Local cUserCCB	 := AllTrim(SuperGetMv("SE_CCBACES", .F., ""))
   
    //Caso tenha sido definido usuários no parâmetro, deverá verificar se o usuário possuirá acesso as rotinas
    If !Empty(cUserCCB) .And. AllTrim(Upper(cUserName)) $ Upper(cUserCCB)
        AADD(aRot, {"Consulta CCB","U_SEFINA03(SA1->A1_COD,SA1->A1_LOJA)",0,4} )
        AADD(aRot, {"Risk Rating", "U_VERISK(SA1->A1_COD)",0,3} )
            AADD(aRotSerasa, {'Consulta*'          ,'U_SEFINA05() ',0,2,0,}) 
            AADD(aRotSerasa, {'Buscar Cred.BUREAU*','U_FINA05AT(1)',0,2,0,}) 
            AADD(aRotSerasa, {'Buscar CREDNET*'    ,'U_FINA05AT(2)',0,2,0,})
            AADD(aRotSerasa, {'Buscar RELATO*'     ,'U_FINA05AT(3)',0,2,0,})
        AADD(aRot,{"SERASA*", aRotSerasa, 0, Len(aRot)+1})		
            Aadd(aRotCisp,{OemToAnsi("Avalia��o Cr�dito"),"u_dfsM450Cli", 0 , 4})
            Aadd(aRotCisp,{OemToAnsi("Consulta Cadastro"),"u_dfsMtcCnpj", 0 , 4})
        AADD(aRot,{"CISP*", aRotCisp, 0, Len(aRot)+1})		
    EndIf
    
    AADD(aRot, {"Incluir Contato","AxInclui('SU5',,3,,,,'U_AssCC()',,,,,,.T.)",0,3} )
Return aRot


/*---------------------*/
User Function VeRisk(COD)
/*---------------------*/ 
Posicione("SA1",1,xFilial("SA1")+COD,"A1_COD")

SZU->(DbSetOrder(1))
If ! SZU->(DbSeek(substr(sa1->a1_cgc,1,8)))
   MsgAlert("Cnpj não localizado.","Atenção")
   Return
Endif
Private oButton1
Private oFont1 := TFont():New("MS Sans Serif",,017,,.F.,,,,,.F.,.F.)
Private oFont2 := TFont():New("MS Sans Serif",,017,,.F.,,,,,.F.,.F.)
Private oGet1
Private cGet1 := SA1->A1_COD
Private oGet2
Private cGet2 := SA1->A1_NOME
Private oGet3
Private cGet3 := SZU->ZU_RISCO
Private oGet4
Private cGet4 := SZU->ZU_RISPON
Private oGet5
Private cGet5 := SZU->ZU_RISRMER
Private oGet6
Private cGet6 := SZU->ZU_RISCOC
Private oGet7
Private cGet7 := SZU->ZU_RISCPR
Private oGet8
Private cGet8 := SZU->ZU_RISDEN
Private oGet9
Private cGet9 := SZU->ZU_CNPJ
Private oGet10
Private cGet10 := SA1->A1_PRICOM
Private oGet11
Private cGet11 := SZU->ZU_RECFED
Private oGet12
Private cGet12 := SA1->A1_ULTCOM
Private oGet13
Private cGet13 := Transform(SA1->A1_MCOMPRA,"@E 9,999,999,999.99")
Private oGet14
Private cGet14 := SZU->ZU_DTSITU
Private oGet15
Private cGet15 := SA1->A1_INSCR
Private oGet16
Private cGet16 := SZU->ZU_DTSINT
Private oGet17
Private cGet17 := Transform(SZU->ZU_DEBITO,"@E 999,999,999.99")
Private oGet18
Private cGet18 := Transform(SZU->ZU_QTDDEB,"@e 999,999")
Private oGet19
Private cGet19 := Transform(SZU->ZU_QTDASSO,"@E 999,999")
Private oGet20
Private cGet20 := Transform(SZU->ZU_TOTDV,"@e 999,999,999.99")
Private oGet21
Private cGet21 := Transform(SZU->ZU_QTVENC,"@e 999,999")
Private oGet22
Private cGet22 := Transform(SZU->ZU_TOTDEB,"@E 999,999,999.99")
Private oGet23
Private cGet23 := Transform(SZU->ZU_QTDEBIT,"@E 999,999")
Private oGet24
Private cGet24 := Transform(SZU->ZU_TODEBTR,"@E 999,999,999.99")
Private oGet25
Private cGet25 := Transform(SZU->ZU_QADEBV,"@E 999,999")
Private oGet26
Private cGet26 := Transform(SZU->ZU_ULTMES,"@e 999,999")
Private oGet27
Private cGet27 := Transform(SZU->ZU_CHEQUE,"@e 999,999")
Private oGet28
Private cGet28 := SZU->ZU_DATACH
Private oGet29
Private cGet29 := SZU->ZU_DATAGER
Private oGet30
Private cGet30 := SZU->ZU_HORA
Private oGet31
Private cGet31 := SZU->ZU_CADSINT
Private oGet32
Private cGet32 := "0.0"
Private oGet33
Private cGet33 := "0.0"

Private oGet40
Private cGet40 := SZU->ZU_DTFUNCL // Data da Fundação do Cliente
Private oGet41
Private cGet41 := SZU->ZU_DTCONRF // Data da Consulta no site da Receita Federal
Private oGet42
Private cGet42 := SZU->ZU_DTCONSI // Data da Consulta no site do Sintegra (SEFAZ do Estado)
Private oGet43
Private cGet43 := SZU->ZU_SEGASS // Segmento do Associado Solicitante
Private oGet44
Private cGet44 := Transform(SZU->ZU_VLLIMCR,"@E 999,999,999,999.99") // Valor Limite de Credito (NO GRUPO DE ASSOCIADOS)
Private oGet45
Private cGet45 := SZU->ZU_QTDASLC // Quantidade de associado com Limite de Credito (NO GRUPO DE ASSOCIADOS)
Private oGet46
Private cGet46 := SZU->ZU_QCHSCLI // Quantidade de Cheques sem Fundos de Sócios do Cliente (NO GRUPO DE ASSOCIADOS)
Private oGet47
Private cGet47 := Transform(SZU->ZU_VLMACU,"@E 999,999,999,999.99") // Total Valor Maior Acumulo (NO GRUPO DE ASSOCIADOS)
Private oGet48
Private cGet48 := SZU->ZU_QASVLAC // Quantidade de associado com Valor Maior Acumulo (NO GRUPO DE ASSOCIADOS)
Private oGet49
Private cGet49 := SZU->ZU_MSGRISK // Mensagem de CLIENTE NÃO CADASTRA NA CISP
Private oGet50
Private cGet50 := Iif(SZU->ZU_ARQATUL == "1","R.RATING PLUS","R.RATING MASTER") // Arquivo atualizado por: (Plus ou Master)

Private   oSay1
Private   oSay10
Private   oSay11
Private   oSay12
Private   oSay13
Private   oSay14
Private   oSay15
Private   oSay16
Private   oSay17
Private   oSay18
Private   oSay19
Private   oSay2
Private   oSay20
Private   oSay21
Private   oSay22
Private   oSay23
Private   oSay24
Private   oSay25
Private   oSay26
Private   oSay27
Private   oSay28
Private   oSay29
Private   oSay3
Private   oSay30
Private   oSay31
Private   oSay32
Private   oSay33
Private   oSay34
Private   oSay35
Private   oSay4
Private   oSay40
Private   oSay41
Private   oSay42
Private   oSay43
Private   oSay44
Private   oSay45
Private   oSay46
Private   oSay47
Private   oSay48
Private   oSay49
Private   oSay5
Private   oSay50
Private   oSay6
Private   oSay7
Private   oSay8
Private   oSay9
Static oDlg
Private oPanel1
Private oPanel2
Private oPanel3
Private oPanel4
Private oWBrowse1
Private aWBrowse1 := {}
Private PCQPAG := 0
Private PCQDAP := 0


//  DEFINE MSDIALOG oDlg TITLE "Risk Rating" FROM 000, 000  TO 750, 1000 COLORS 0, 14342874 PIXEL
  DEFINE MSDIALOG oDlg TITLE "Risk Rating" FROM 000, 000  TO 1000, 1000 COLORS 0, 14342874 PIXEL

	// Painel 1 - Título da Tela
    @ 001, 003 MSPANEL oPanel1 SIZE 495, 025 OF oDlg COLORS 0, 14803425 RAISED
    @ 009, 179 SAY oSay1 PROMPT "Risk Rating - Fonte CISP" SIZE 125, 012 OF oPanel1 FONT oFont1 COLORS 16711680, 14803425 PIXEL
    
	// Painel 2 - Dados CISP - Risk Rating
//    @ 027, 002 MSPANEL oPanel2 SIZE 495, 307 OF oDlg COLORS 0, 16777215 RAISED
    @ 027, 002 MSPANEL oPanel2 SIZE 495, 550 OF oDlg COLORS 0, 16777215 RAISED

    @ 010, 016 SAY oSay2 PROMPT "Codigo Cliente :" SIZE 046, 007 OF oPanel2 COLORS 0, 16777215 PIXEL
    @ 008, 057 MSGET oGet1 VAR cGet1 SIZE 060, 010 OF oPanel2 COLORS 16711680, 16777215  READONLY PIXEL
    @ 010, 122 SAY oSay3 PROMPT "Razão Social :" SIZE 041, 007 OF oPanel2 COLORS 0, 16777215 PIXEL
    @ 008, 161 MSGET oGet2 VAR cGet2 SIZE 303, 010 OF oPanel2 COLORS 16711680, 16777215  READONLY PIXEL

    @ 022, 122 SAY oSay10 PROMPT "CNPJ :" SIZE 060, 007 OF oPanel2 COLORS 0, 16777215 PIXEL
    @ 020, 161 MSGET oGet9 VAR cGet9 SIZE 089, 010 OF oPanel2 COLORS 16711680, 16777215  PIXEL

    @ 023, 016 SAY oSay4 PROMPT "Risco Atual :" SIZE 075, 007 OF oPanel2 COLORS 0, 16777215 PIXEL
    @ 021, 094 MSGET oGet3 VAR cGet3 SIZE 022, 010 OF oPanel2 COLORS 255, 16777215  PIXEL

    @ 035, 016 SAY oSay5 PROMPT "Risco Pontualidade :" SIZE 075, 007 OF oPanel2 COLORS 0, 16777215 PIXEL
    @ 033, 094 MSGET oGet4 VAR cGet4 SIZE 022, 010 OF oPanel2 COLORS 255, 16777215 PIXEL
    @ 035, 122 SAY oSay11 PROMPT "Data de Cadastro :" SIZE 053, 007 OF oPanel2 COLORS 0, 16777215 PIXEL
    @ 032, 174 MSGET oGet10 VAR cGet10 SIZE 060, 010 OF oPanel2 COLORS 16711680, 16777215 PIXEL
    @ 035, 237 SAY oSay13 PROMPT "Ultima Compra :" SIZE 052, 007 OF oPanel2 COLORS 0, 16777215 PIXEL
    @ 032, 277 MSGET oGet12 VAR cGet12 SIZE 060, 010 OF oPanel2 COLORS 16711680, 16777215  PIXEL
    @ 035, 340 SAY oSay14 PROMPT "Vlr Maior Compra :" SIZE 050, 007 OF oPanel2 COLORS 0, 16777215 PIXEL
    @ 032, 387 MSGET oGet13 VAR cGet13 SIZE 077, 010 OF oPanel2 COLORS 16711680, 16777215  PIXEL
    
    @ 046, 122 SAY oSay12 PROMPT "Status - Sit. Cadastral Rec. Federal :" SIZE 091, 007 OF oPanel2 COLORS 0, 16777215 PIXEL
    @ 045, 211 MSGET oGet11 VAR cGet11 SIZE 167, 010 OF oPanel2 COLORS 255, 16777215  PIXEL
    @ 046, 383 SAY oSay15 PROMPT " Data Sit. Cad. :" SIZE 048, 007 OF oPanel2 COLORS 0, 16777215 PIXEL
    @ 045, 425 MSGET oGet14 VAR cGet14 SIZE 039, 010 OF oPanel2 COLORS 255, 16777215  PIXEL
    
    @ 048, 016 SAY oSay6 PROMPT "Risco Relacionam. Merc.:" SIZE 075, 007 OF oPanel2 COLORS 0, 16777215 PIXEL
    @ 046, 094 MSGET oGet5 VAR cGet5 SIZE 022, 010 OF oPanel2 COLORS 255, 16777215  PIXEL

    @ 057, 122 SAY oSay16 PROMPT "Insc. Estadual :" SIZE 050, 007 OF oPanel2 COLORS 0, 16777215 PIXEL
    @ 057, 197 MSGET oGet15 VAR cGet15 SIZE 066, 010 OF oPanel2 COLORS 255, 16777215  PIXEL

    @ 060, 016 SAY oSay7 PROMPT "Risco Ocorrências Negativas:" SIZE 076, 007 OF oPanel2 COLORS 0, 16777215 PIXEL
    @ 058, 094 MSGET oGet6 VAR cGet6 SIZE 022, 010 OF oPanel2 COLORS 255, 16777215  PIXEL

    @ 072, 016 SAY oSay8 PROMPT "Crédito na Praça :" SIZE 075, 007 OF oPanel2 COLORS 0, 16777215 PIXEL
    @ 070, 094 MSGET oGet7 VAR cGet7 SIZE 022, 010 OF oPanel2 COLORS 255, 16777215  PIXEL
    @ 072, 122 SAY oSay33 PROMPT "Status - Sit. Cad. Sintegra :" SIZE 075, 007 OF oPanel2 COLORS 0, 16777215 PIXEL
    @ 070, 197 MSGET oGet31 VAR cGet31 SIZE 265, 010 OF oPanel2 COLORS 255, 16777215 PIXEL

    @ 084, 016 SAY oSay9 PROMPT "Risco Densidade Comercial :" SIZE 075, 007 OF oPanel2 COLORS 0, 16777215 PIXEL
    @ 082, 094 MSGET oGet8 VAR cGet8 SIZE 022, 010 OF oPanel2 COLORS 255, 16777215 PIXEL
    @ 084, 122 SAY oSay17 PROMPT "Data Sit. Cad. SINTEGRA :" SIZE 075, 007 OF oPanel2 COLORS 0, 16777215 PIXEL
    @ 082, 197 MSGET oGet16 VAR cGet16 SIZE 048, 010 OF oPanel2 COLORS 255, 16777215  PIXEL

    @ 099, 200 SAY oSay30 PROMPT "Data do Arquivo CISP :" SIZE 075, 007 OF oPanel2 COLORS 128, 16777215 PIXEL
    @ 094, 285 MSGET oGet29 VAR cGet29 SIZE 060, 010 OF oPanel2 COLORS 255, 16777215  PIXEL

    @ 100, 015 SAY oSay18 PROMPT "Debito Atual do Cliente no Grupo :" SIZE 113, 007 OF oPanel2 COLORS 0, 16777215 PIXEL
    @ 098, 128 MSGET oGet17 VAR cGet17 SIZE 060, 010 OF oPanel2 COLORS 255, 16777215  PIXEL

    @ 111, 201 SAY oSay31 PROMPT "Hora de Geração do Arq. Cisp :" SIZE 075, 007 OF oPanel2 COLORS 128, 16777215 PIXEL
    @ 108, 285 MSGET oGet30 VAR cGet30 SIZE 030, 010 OF oPanel2 COLORS 255, 16777215  PIXEL

    @ 113, 015 SAY oSay19 PROMPT "Qtde. De Associados com Débito :" SIZE 114, 007 OF oPanel2 COLORS 0, 16777215 PIXEL
    @ 111, 128 MSGET oGet18 VAR cGet18 SIZE 060, 010 OF oPanel2 COLORS 255, 16777215 PIXEL

    @ 126, 015 SAY oSay20 PROMPT "Qtde. de Associados no Grupo :" SIZE 114, 007 OF oPanel2 COLORS 0, 16777215 PIXEL
    @ 125, 128 MSGET oGet19 VAR cGet19 SIZE 060, 010 OF oPanel2 COLORS 255, 16777215 PIXEL
    @ 126, 200 SAY oSay40 PROMPT "Dt. Fundação Cliente :" SIZE 075, 007 OF oPanel2 COLORS 0, 16777215 PIXEL
    @ 125, 285 MSGET oGet40 VAR cGet40 SIZE 060, 010 OF oPanel2 COLORS 255, 16777215 PIXEL
    @ 126, 350 SAY oSay50 PROMPT "Arquivo Atualizado Por:" SIZE 075, 007 OF oPanel2 COLORS 0, 16777215 PIXEL
    @ 125, 430 MSGET oGet50 VAR cGet50 SIZE 060, 010 OF oPanel2 COLORS 255, 16777215 PIXEL
    
    @ 140, 015 SAY oSay21 PROMPT "Total de Débitos com + 5 dias" SIZE 113, 007 OF oPanel2 COLORS 0, 16777215 PIXEL
    @ 138, 128 MSGET oGet20 VAR cGet20 SIZE 060, 010 OF oPanel2 COLORS 255, 16777215 PIXEL
    @ 140, 200 SAY oSay41 PROMPT "Dt. Cons.Site Rec.Fed.:" SIZE 075, 007 OF oPanel2 COLORS 0, 16777215 PIXEL
    @ 138, 285 MSGET oGet41 VAR cGet41 SIZE 060, 010 OF oPanel2 COLORS 255, 16777215 PIXEL    
    @ 140, 350 SAY oSay42 PROMPT "Dt. Cons.Site Sintegra:" SIZE 075, 007 OF oPanel2 COLORS 0, 16777215 PIXEL
    @ 138, 430 MSGET oGet42 VAR cGet42 SIZE 060, 010 OF oPanel2 COLORS 255, 16777215 PIXEL    

    @ 152, 015 SAY oSay22 PROMPT "Qtde de Assoc. c/ Déb. Vencidos a + 5 Dias :" SIZE 114, 007 OF oPanel2 COLORS 0, 16777215 PIXEL
    @ 151, 128 MSGET oGet21 VAR cGet21 SIZE 060, 010 OF oPanel2 COLORS 255, 16777215  PIXEL
    @ 152, 200 SAY oSay43 PROMPT "Seg. Ass. Solicitante:" SIZE 075, 007 OF oPanel2 COLORS 0, 16777215 PIXEL
    @ 151, 285 MSGET oGet43 VAR cGet43 SIZE 020, 010 OF oPanel2 COLORS 255, 16777215 PIXEL    
    @ 152, 350 SAY oSay44 PROMPT "Vl.Lim.Credito (NO GRUPO):" SIZE 080, 007 OF oPanel2 COLORS 0, 16777215 PIXEL
    @ 151, 430 MSGET oGet44 VAR cGet44 SIZE 030, 010 OF oPanel2 COLORS 255, 16777215 PIXEL    

    @ 165, 015 SAY oSay23 PROMPT "Total de Débitos com + 15 Dias" SIZE 116, 007 OF oPanel2 COLORS 0, 16777215 PIXEL
    @ 163, 128 MSGET oGet22 VAR cGet22 SIZE 060, 010 OF oPanel2 COLORS 255, 16777215  PIXEL
    @ 165, 200 SAY oSay45 PROMPT "Qtd. Ass. c/Lim. Crédito:" SIZE 080, 007 OF oPanel2 COLORS 0, 16777215 PIXEL
    @ 163, 285 MSGET oGet45 VAR cGet45 SIZE 030, 010 OF oPanel2 COLORS 255, 16777215 PIXEL
    @ 165, 350 SAY oSay46 PROMPT "Qtd.Ch.s/fundos Sócios Cliente:" SIZE 080, 007 OF oPanel2 COLORS 0, 16777215 PIXEL
    @ 163, 430 MSGET oGet46 VAR cGet46 SIZE 030, 010 OF oPanel2 COLORS 255, 16777215 PIXEL

    @ 178, 015 SAY oSay24 PROMPT "Qtde. Ass. c/ Débito Vencido + 15 Dias :" SIZE 113, 007 OF oPanel2 COLORS 0, 16777215 PIXEL
    @ 177, 128 MSGET oGet23 VAR cGet23 SIZE 060, 010 OF oPanel2 COLORS 255, 16777215  PIXEL
    @ 178, 200 SAY oSay47 PROMPT "Total Vl. M.Acumulo (NO GRUPO):" SIZE 100, 007 OF oPanel2 COLORS 0, 16777215 PIXEL
    @ 177, 285 MSGET oGet47 VAR cGet47 SIZE 030, 010 OF oPanel2 COLORS 255, 16777215 PIXEL
    @ 178, 350 SAY oSay48 PROMPT "Qtd. Ass. c/ Vl.M.Acumulo:" SIZE 100, 007 OF oPanel2 COLORS 0, 16777215 PIXEL
    @ 177, 430 MSGET oGet48 VAR cGet48 SIZE 030, 010 OF oPanel2 COLORS 255, 16777215 PIXEL

    @ 191, 015 SAY oSay25 PROMPT "Total de Débito com + 30 Dias :" SIZE 113, 007 OF oPanel2 COLORS 0, 16777215 PIXEL
    @ 189, 128 MSGET oGet24 VAR cGet24 SIZE 060, 010 OF oPanel2 COLORS 255, 16777215  PIXEL
    @ 191, 200 SAY oSay49 PROMPT "Msg. Cli. Não Cad. na CISP:" SIZE 100, 007 OF oPanel2 COLORS 0, 16777215 PIXEL
    @ 189, 285 MSGET oGet49 VAR cGet49 SIZE 200, 010 OF oPanel2 COLORS 255, 16777215 PIXEL

    @ 206, 015 SAY oSay26 PROMPT "Qtde. Associ. c/ Déb. Vencido + 30 Dias :" SIZE 115, 007 OF oPanel2 COLORS 0, 16777215 PIXEL
    @ 204, 128 MSGET oGet25 VAR cGet25 SIZE 060, 010 OF oPanel2 COLORS 255, 16777215  PIXEL

    @ 220, 015 SAY oSay27 PROMPT "Qtde. Assoc. c/ Vendas Últimos 2 Meses :" SIZE 114, 007 OF oPanel2 COLORS 0, 16777215 PIXEL
    @ 218, 128 MSGET oGet26 VAR cGet26 SIZE 060, 010 OF oPanel2 COLORS 255, 16777215  PIXEL

    @ 233, 015 SAY oSay28 PROMPT "Qtde Cheques S/ Fundos :" SIZE 114, 007 OF oPanel2 COLORS 0, 16777215 PIXEL
    @ 232, 128 MSGET oGet27 VAR cGet27 SIZE 060, 010 OF oPanel2 COLORS 255, 16777215  PIXEL

    @ 245, 015 SAY oSay29 PROMPT "Data Atualização do Mov. de Cheques :" SIZE 116, 007 OF oPanel2 COLORS 0, 16777215 PIXEL
    @ 244, 128 MSGET oGet28 VAR cGet28 SIZE 060, 010 OF oPanel2 COLORS 255, 16777215  PIXEL

	// Painel 3 - Dados dos títulos nos últimos 12 meses
//    @ 129, 197 MSPANEL oPanel3 SIZE 292, 171 OF oPanel2 COLORS 14342874, 12632256 RAISED
//    @ 002, 005 SAY oSay32 PROMPT "                                                      Movimentação dos Últimos 12 Meses" SIZE 281, 007 OF oPanel3 COLORS 8388608, 16767152 PIXEL
    @ 199, 197 MSPANEL oPanel3 SIZE 292, 171 OF oPanel2 COLORS 14342874, 12632256 RAISED
    @ 002, 005 SAY oSay32 PROMPT "                                                      Movimentação dos Últimos 12 Meses" SIZE 281, 007 OF oPanel3 COLORS 8388608, 16767152 PIXEL
 
	// Painel 4 - Médias.
    @ 090, 354 MSPANEL oPanel4 SIZE 130, 032 OF oPanel2 COLORS 0, 14671839 RAISED
    @ 006, 008 SAY oSay34 PROMPT "Média Ponderada de Atrasos :" SIZE 080, 007 OF oPanel4 COLORS 16711680, 14671839 PIXEL
    @ 019, 007 SAY oSay35 PROMPT " Média Aritmética de Atrasos :" SIZE 071, 007 OF oPanel4 COLORS 16711680, 14671839 PIXEL
    @ 003, 086 MSGET oGet32 VAR cGet32 SIZE 025, 010 OF oPanel4 COLORS 0, 16777215 PIXEL
    @ 018, 086 MSGET oGet33 VAR cGet33 SIZE 025, 010 OF oPanel4 COLORS 0, 16777215 PIXEL
    
//    @ 274, 071 BUTTON oButton1 PROMPT "Sair" SIZE 037, 012 ACTION oDlg:End() OF oPanel2 PIXEL
    @ 344, 071 BUTTON oButton1 PROMPT "Sair" SIZE 037, 012 ACTION oDlg:End() OF oPanel2 PIXEL

    fWBrowse1()

  ACTIVATE MSDIALOG oDlg CENTERED

Return

//------------------------------------------------ 
Static Function fWBrowse1()
//------------------------------------------------ 
Local cQuery :=''
DDataAte := DDataBase
DDataDe := YearSub(DDataBase,1)
cquery := " SELECT E1_FILIAL,E1_NUM,E1_PARCELA,E1_TIPO,E1_EMISSAO,E1_VENCTO,E1_VENCREA,"
cQuery += " E1_VALOR,E1_BAIXA, "
cQuery += " CASE WHEN DATEDIFF(DAY,E1_VENCREA,E1_BAIXA) >= 0  THEN DATEDIFF(DAY,E1_VENCREA,E1_BAIXA) "
cQuery += "      WHEN E1_BAIXA <> ' ' AND E1_BAIXA > E1_VENCREA THEN DATEDIFF(DAY,E1_VENCREA,"+VALTOSQL(DDATABASE)+") "
cQuery += "      WHEN E1_BAIXA = ' ' AND E1_VENCREA < '20141029' THEN  DATEDIFF(DAY,E1_VENCREA,"+VALTOSQL(DDATABASE)+") "
cQuery += "      ELSE 0 END AS DIATRA ,"
cQuery += "CASE WHEN DATEDIFF(DAY,E1_VENCREA,E1_BAIXA) >= 0  THEN (E1_VALOR*DATEDIFF(DAY,E1_VENCREA,E1_BAIXA)) 
cQuery += "       WHEN E1_BAIXA <> ' ' AND E1_BAIXA > E1_VENCREA THEN (E1_VALOR*DATEDIFF(DAY,E1_VENCREA,"+VALTOSQL(DDATABASE)+"))
cQuery += "       WHEN E1_BAIXA = ' '  AND E1_VENCREA < "+VALTOSQL(DDATABASE)+"  THEN (E1_VALOR*DATEDIFF(DAY,E1_VENCREA,"+VALTOSQL(DDATABASE)+"))
cQuery += "       ELSE 0 END AS VLRCALC  
cQuery += " FROM SE1010 WHERE E1_CLIENTE = '"+SA1->A1_COD+"' AND SE1010.D_E_L_E_T_ = ' ' AND E1_EMISSAO BETWEEN "+VALTOSQL(DDataDe)+" AND "+VALTOSQL(DDataAte)
cQuery += " ORDER BY E1_FILIAL,E1_EMISSAO,E1_NUM,E1_PARCELA "

dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), "TRB1", .T., .F. )
dbSelectArea("TRB1")
TRB1->(DbGotop())  
_Z := 0
_y := 0 
_x := 0  
_NT := 0
If TRB1->(Eof())
    Aadd(aWBrowse1,{" "," "," "," "," "," "," "," "," "," ",})
Else
  While ! TRB1->(Eof())
    Aadd(aWBrowse1,{TRB1->E1_FILIAL,TRB1->E1_NUM,TRB1->E1_PARCELA,TRB1->E1_TIPO,SUBSTR(TRB1->E1_EMISSAO,7,2)+'/'+SUBSTR(TRB1->E1_EMISSAO,5,2)+'/'+SUBSTR(TRB1->E1_EMISSAO,1,4),;
               SUBSTR(TRB1->E1_VENCTO,7,2)+'/'+SUBSTR(TRB1->E1_VENCTO,5,2)+'/'+SUBSTR(TRB1->E1_VENCTO,1,4),;
               SUBSTR(TRB1->E1_VENCREA,7,2)+'/'+SUBSTR(TRB1->E1_VENCREA,5,2)+'/'+SUBSTR(TRB1->E1_VENCREA,1,4),TRANSFORM(TRB1->E1_VALOR,"@e 999,999,999.99"),;
               SUBSTR(TRB1->E1_BAIXA,7,2)+'/'+SUBSTR(TRB1->E1_BAIXA,5,2)+'/'+SUBSTR(TRB1->E1_BAIXA,1,4),TRANSFORM(TRB1->DIATRA,"@E 999")})

    If TRB1->DIATRA > 0 .AND. ALLTRIM(TRB1->E1_TIPO) == 'NF'
			_Z     += TRB1->VLRCALC
			_Y     += TRB1->DIATRA  
            _X  += iif(TRB1->E1_VALOR > 0, TRB1->E1_VALOR,0)
            _NT += 1
    Endif			 
    Trb1->(DbSkip())
  End
Endif

PCQPAG := IIf( (_Z/_X ) < 0.01 .and. (_Z/_X ) > 0, 0.01,(_Z/_X) )
PCQDAP := Iif( (_Y/_NT) < 0.01 .and. (_Y/_NT) > 0, 0.01,(_Y/_NT) )
cGet32 := Transform(PCQPAG,"@e 99.99")
cGet33 := Transform(PCQDAP,"@e 99.99")
//@ 099, 370 SAY "Média Ponderada de Atrasos  : "+Transform(PCQPAG,"@e 99.99") SIZE 300, 007 OF oPanel2  COLORS 16711680, 16777215 PIXEL   
//@ 111, 370 SAY "Média Aritmética de Atrasos : "+Transform(PCQDAP,"@e 99.99") SIZE 300, 007 OF oPanel2  COLORS 16711680, 16777215 PIXEL   
trb1->(DbCloseArea())
//    @ 140, 202 LISTBOX oWBrowse1 Fields HEADER "Fil","Titulo","Parc","Tipo","Emissao","Vencto","Vecto Real","Valor","Baixa","Atraso" SIZE 281, 156 OF oPanel2 PIXEL;
//                                       ColSizes 5   ,15      , 4    , 4    ,  15     , 15     , 15         , 25    , 15    , 5
    @ 210, 202 LISTBOX oWBrowse1 Fields HEADER "Fil","Titulo","Parc","Tipo","Emissao","Vencto","Vecto Real","Valor","Baixa","Atraso" SIZE 281, 156 OF oPanel2 PIXEL;
                                       ColSizes 5   ,15      , 4    , 4    ,  15     , 15     , 15         , 25    , 15    , 5
    oWBrowse1:SetArray(aWBrowse1)
    oWBrowse1:bLine := {|| {;
      aWBrowse1[oWBrowse1:nAt,1],;
      aWBrowse1[oWBrowse1:nAt,2],;
      aWBrowse1[oWBrowse1:nAt,3],;
      aWBrowse1[oWBrowse1:nAt,4],;
      aWBrowse1[oWBrowse1:nAt,5],;
      aWBrowse1[oWBrowse1:nAt,6],;
      aWBrowse1[oWBrowse1:nAt,7],;
      aWBrowse1[oWBrowse1:nAt,8],;
      aWBrowse1[oWBrowse1:nAt,9],;
      aWBrowse1[oWBrowse1:nAt,10];
    }}
    // DoubleClick event
    oWBrowse1:bLDblClick := {|| aWBrowse1[oWBrowse1:nAt,1] := aWBrowse1[oWBrowse1:nAt,1],;
      oWBrowse1:DrawSelect()}

Return

//--------------------------------------------------------------------
/*/{Protheus.doc} AssCC
Função para Associacao do contato ao Cliente

@author Rodrigo Nunes
@since 02/06/2020
/*/
//--------------------------------------------------------------------
User Function AssCC()

RecLock("AC8",.T.)
AC8->AC8_FILIAL := xFilial("AC8")
AC8->AC8_FILENT := xFilial("AC8")
AC8->AC8_ENTIDA := "SA1"
AC8->AC8_CODENT := SA1->A1_COD + SA1->A1_LOJA
AC8->AC8_CODCON := M->U5_CODCONT
AC8->(MsUnlock())
Return .T.
