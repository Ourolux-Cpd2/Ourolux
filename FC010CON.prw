#Include 'Protheus.ch'

//--------------------------------------------------------------------
/*/{Protheus.doc} FC010CON
Ponto de entrada para incluir consulta especifica na posicao de clientes

@author TOTVS Protheus
@since  02/06/2015
@obs    Sensus Tecnologia - Fabricio Eduardo Reche
@version 1.0
/*/
//--------------------------------------------------------------------
User Function FC010CON()

	Local oWinSer

	DEFINE MSDIALOG oWinSer TITLE OemToAnsi("SERASA") FROM 10,0 TO 100,500 OF oMainWnd PIXEL

		@ 5,010 Say OemToAnsi("Escolha a opção desejada:") SIZE 90,10 OF oWinSer PIXEL

		@ 15,017 BUTTON "Consulta"           SIZE 30,15 ACTION U_SEFINA05()  OF oWinSer PIXEL
		@ 15,060 BUTTON "Buscar CRED.BUREAU" SIZE 70,15 ACTION U_FINA05AT(1) OF oWinSer PIXEL
		@ 15,130 BUTTON "Buscar CREDNET"     SIZE 50,15 ACTION U_FINA05AT(2) OF oWinSer PIXEL
		@ 15,180 BUTTON "Buscar RELATO"      SIZE 50,15 ACTION U_FINA05AT(3) OF oWinSer PIXEL

	ACTIVATE MSDIALOG oWinSer CENTERED

Return