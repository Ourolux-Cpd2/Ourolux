#INCLUDE "PROTHEUS.CH"

User Function FA280GRV()
	Local aFat := {SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_CLIENTE,SE1->E1_LOJA}

	If FindFunction("U_xSetBol") .And. ;
		Aviso("Boleto","Deseja habilitar a impress�o do boleto?",{"Sim","N�o"},1) == 1
		U_xSetBol(,,aFat)
	EndIf
    
Return