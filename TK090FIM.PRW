#INCLUDE "PROTHEUS.CH"

/*
--O ponto de entrada TK090FIM é executado depois de incluir
--ou fazer alterações no Cadastro de Operadores.
*/


User Function TK090FIM()

If Inclui .And. SU7->U7_CODVEN <> ' '

	RecLock( "SU7", .F. )
		REPLACE SU7->U7_CFGBTN WITH '111111010000111110000111101100000'
	MsUnlock()

EndIf

Return()