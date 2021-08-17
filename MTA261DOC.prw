#INCLUDE "PROTHEUS.CH"

/*---------------------------------------------------------|
| Autor | Claudino Domingues               | Data 31/05/12 | 
|----------------------------------------------------------|
| Função: MTA261DOC	                                       |
|----------------------------------------------------------|
| Ponto de entrada utilizado para habilitar a digitação ou |
| não a digitação do Numero do Documento na rotina Trans-  |
| ferencia Mod2. Caso retorno .T. habilita digitação caso  |
| .F. bloqueia digitação.                                  |
-----------------------------------------------------------*/

User Function MTA261DOC()

Return(u_IsAdm()) // Função IsAdm verifica se é administrador.
