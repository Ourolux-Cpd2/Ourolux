#INCLUDE "PROTHEUS.CH"

/*---------------------------------------------------------|
| Autor | Claudino Domingues               | Data 31/05/12 | 
|----------------------------------------------------------|
| Fun��o: MTA261DOC	                                       |
|----------------------------------------------------------|
| Ponto de entrada utilizado para habilitar a digita��o ou |
| n�o a digita��o do Numero do Documento na rotina Trans-  |
| ferencia Mod2. Caso retorno .T. habilita digita��o caso  |
| .F. bloqueia digita��o.                                  |
-----------------------------------------------------------*/

User Function MTA261DOC()

Return(u_IsAdm()) // Fun��o IsAdm verifica se � administrador.
