#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±º Programa ³ MT110TEL() ³ Autor ³ Claudino P Domingues ³ Data ³ 01/11/13 º±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±º Funcao Padrao ³ MATA110                                                º±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±º Desc.    ³ Ponto de entrada que adiciona campos no cabecalho da SC.    º±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

User Function MT110TEL()
    
	Local _aArea    := GetArea()
	Local _aAreaSC1 := SC1->(GetArea())
	Local _aAreaSRA := SRA->(GetArea())

	Local _oGet1
	Local _oComb1  // Claudino - 12/12/2016 - I1612-573  
	Local _oDtProg // Claudino - 12/12/2016 - I1612-573
	
	Local _oNewDlg := PARAMIXB[1]
	//Local _aPosGet := PARAMIXB[2]
	Local _nOpcx   := PARAMIXB[3]
	//Local _nReg    := PARAMIXB[4]
	
	Local oNewDialog := PARAMIXB[1]
	Local aPosGet    := PARAMIXB[2]
	//Local nOpcx      := PARAMIXB[3]
	//Local nReg       := PARAMIXB[4]
	Local aLinX 	 := {}
	Local cQuery 	 := ""
	
	Public _xoVolCub
	Public _xoPesBru
	Public _nVolCubado	:= 0
	Public _xPesBru		:= 0	 
	Public _cPedPrg   	:= ""                   // Claudino - 12/12/2016 - I1612-573
	Public _dDtProg   	:= CTOD("  /  /    ")   // Claudino - 12/12/2016 - I1612-573
	Public _cDepSC1 	:= Space(9)
	
	aadd(aPosGet,{}) 
/*
	aadd(aPosGet[3],0) 
	aadd(aPosGet[3],0)

	aPosGet[3,1]:=448
	aPosGet[3,2]:=545
*/	
	If _nOpcx == 3
		
		/* war 10-02-2020
		
		PswSeek(__cUserId)
		_aUser := PswRet()
	        	
		If Empty(_aUser[1][22])
	 		_cDepSC1 := Space(9)
	   		ApMsgStop("Por favor solicitar ao TI que cadastre a sua matrícula no seu login!", "MT110TEL" )
		Else
	     	If !Empty(ALLTRIM(SRA->RA_DEPTO))
				_cDepSC1 := SRA->RA_DEPTO
	    	Else
	     		_cDepSC1 := Space(9)
	       		ApMsgStop("Por favor solicitar ao RH que cadastre o seu departamento no cadastro de funcionários!", "MT110TEL" )
	       	EndIf
	   	EndIf
		war 10-02-2020 */ 	
	Else
		_cDepSC1 := SC1->C1_XDEPART
		_cPedPrg := SC1->C1_XPEDPRG
		_dDtProg := SC1->C1_XDTPROG

		cQuery := " SELECT SUM(C1_XCUBAGE) AS CUBAGEM , SUM(C1_XPESBRU) AS PESBRU FROM " + RetSqlName("SC1")
		cQuery += " WHERE C1_FILIAL = '"+SC1->C1_FILIAL+"' "
		cQuery += " AND C1_NUM = '"+SC1->C1_NUM+"' " 
		cQuery += " AND D_E_L_E_T_ = '' "

		If Select("CX1") > 0 
			CX1->(dbCloseArea())
		EndIf
		
		DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery) , 'CX1', .T., .F.)

		If CX1->(!EOF())
			_nVolCubado	:= CX1->CUBAGEM
			_xPesBru	:= CX1->PESBRU
		EndIf
	EndIf

/*		
	@ 035, _aPosGet[1,1] SAY "Departamento" PIXEL SIZE 035,009 Of _oNewDlg
	@ 034, _aPosGet[1,2] MSGET _oGet1 VAR _cDepSC1 SIZE 040,010 F3 CpoRetF3("QB_DEPTO","SQB") ;
	Picture PesqPict("SQB","QB_DEPTO") VALID EXISTCPO("SQB",_cDepSC1) OF _oNewDlg PIXEL HASBUTTON
	
	// Inicio - Claudino 12/12/2016 - I1612-573
	@ 035, _aPosGet[1,3] SAY "Pedido Programado" PIXEL SIZE 050,050 Of _oNewDlg
	@ 034, _aPosGet[1,4] MSCOMBOBOX _oComb1 VAR _cPedPrg ITEMS{"S=Sim","N=Não"} SIZE 030,010 OF _oNewDlg COLORS 0, 16777215 PIXEL
	
	@ 035, _aPosGet[1,5] SAY "Dt Programada" PIXEL SIZE 050,050 Of _oNewDlg
	@ 034, _aPosGet[1,6] MSGET _oDtProg VAR _dDtProg SIZE 040,010 Of _oNewDlg PIXEL HASBUTTON
	// Fim - Claudino 12/12/2016 - I1612-573

	@ 035,aPosGet[3,1] SAY 'Tot. Vol. Cubado' PIXEL SIZE 60,9 Of oNewDialog
	@ 034,aPosGet[3,2] SAY _nVolCubado PICTURE '@E 999,999,999.99999' PIXEL SIZE 60,08 Of oNewDialog    
*/
    // PROJETO_12
	// Compatibilização para Protheus 12
	// Roberto Souza - 09/08/2017


	
    If cVersao == "12"

		aadd(aLinX, {37,35})		             
		aadd(aLinX, {51,49})		             
		             
		aadd(aPosGet[3],aPosGet[1][1] +105)
		aadd(aPosGet[3],aPosGet[1][2] +085)
		aadd(aPosGet[3],160)
		aadd(aPosGet[3],200)	
		aadd(aPosGet[3],360)
		aadd(aPosGet[3],400)			
		aadd(aPosGet[3],aPosGet[1][5])//480)
		aadd(aPosGet[3],aPosGet[1][6] +60)//540)
	
		@ 64, aPosGet[1][1]  SAY "Dpto." PIXEL SIZE 035,010 Of _oNewDlg                                   
	    @ 63, aPosGet[1][2] MSGET _oGet1 VAR _cDepSC1 SIZE 040,010 F3 CpoRetF3("QB_DEPTO","SQB") ;
		Picture PesqPict("SQB","QB_DEPTO") VALID EXISTCPO("SQB",_cDepSC1) OF _oNewDlg PIXEL HASBUTTON
	                     
		@ 64, aPosGet[1][3] SAY 'Cub. Total' PIXEL SIZE 60,10 Of oNewDialog
		@ 63, aPosGet[1][4] MSGET _xoVolCub VAR _nVolCubado PICTURE '@E 999,999,999.99999' PIXEL SIZE 50,10 Of oNewDialog WHEN .F.   

		@ 64, aPosGet[1][5] SAY 'Peso Bruto Total' PIXEL SIZE 60,10 Of oNewDialog
		@ 63, aPosGet[1][6] MSGET _xoPesBru VAR _xPesBru PICTURE '@E 999,999,999.999' PIXEL SIZE 50,10 Of oNewDialog WHEN .F.   

		//@ 78, aPosGet[1][1] SAY "Programado" PIXEL SIZE 050,050 Of _oNewDlg
		//@ 77, aPosGet[1][2] MSCOMBOBOX _oComb1 VAR _cPedPrg ITEMS{"S=Sim","N=Não"} SIZE 040,010 OF _oNewDlg COLORS 0, 16777215 PIXEL
		
		//@ 78, aPosGet[1][3] SAY "Dt Programada" PIXEL SIZE 050,050 Of _oNewDlg
		//@ 77, aPosGet[1][4] MSGET _oDtProg VAR _dDtProg SIZE 050,010 Of _oNewDlg PIXEL HASBUTTON
    Else
	    
		aadd(aPosGet[3],aPosGet[1][1])
		aadd(aPosGet[3],aPosGet[1][2])
		aadd(aPosGet[3],160)
		aadd(aPosGet[3],200)
		aadd(aPosGet[3],270)
		aadd(aPosGet[3],320)			
		aadd(aPosGet[3],aPosGet[1][5])//480)
		aadd(aPosGet[3],aPosGet[1][6])//540)
	
		@ 035, aPosGet[3][1] SAY "Departamento" PIXEL SIZE 035,009 Of _oNewDlg                                   
		@ 033, aPosGet[3][2] MSGET _oGet1 VAR _cDepSC1 SIZE 040,010 F3 CpoRetF3("QB_DEPTO","SQB") ;
		Picture PesqPict("SQB","QB_DEPTO") VALID EXISTCPO("SQB",_cDepSC1) OF _oNewDlg PIXEL HASBUTTON
		
		// Inicio - Claudino 12/12/2016 - I1612-573
		@ 035, aPosGet[3][3] SAY "Programado" PIXEL SIZE 050,050 Of _oNewDlg
		@ 033, aPosGet[3][4] MSCOMBOBOX _oComb1 VAR _cPedPrg ITEMS{"S=Sim","N=Não"} SIZE 030,010 OF _oNewDlg COLORS 0, 16777215 PIXEL
		
		@ 035, aPosGet[3][5] SAY "Dt Programada" PIXEL SIZE 050,050 Of _oNewDlg
		@ 033, aPosGet[3][6] MSGET _oDtProg VAR _dDtProg SIZE 050,010 Of _oNewDlg PIXEL HASBUTTON
		// Fim - Claudino 12/12/2016 - I1612-573
	
		@ 035,aPosGet[3][7] SAY 'Tot. Vol. Cubado' PIXEL SIZE 60,9 Of oNewDialog
	//	@ 035,aPosGet[3][8] SAY _nVolCubado PICTURE '@E 999,999,999.99999' PIXEL SIZE 60,08 Of oNewDialog    
		@ 035,aPosGet[3][8] MSGET _xoVolCub VAR _nVolCubado PICTURE '@E 999,999,999.99999' PIXEL SIZE 60,08 Of oNewDialog WHEN .F.   
	
	EndIf	

	RestArea(_aAreaSRA)
	RestArea(_aAreaSC1)    
	RestArea(_aArea)
	
Return
