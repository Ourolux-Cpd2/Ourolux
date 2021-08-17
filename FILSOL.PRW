// Filtro usado na consulta padrao SCP (tipo 6) na implementacao da 
// "Solicitaçao ao Armazem" 
// Modulo ESTOQUE 

User Function FILSOL()

Public fil := ''

if cNivel < 9
	// filtra p/ ver somente materiais de consumo e bloqueia a visao 
	// dos produtos de informatica
	fil := B1_GRUPO $ ('ME  ','ML  ','MC  ') .AND. ;
	(SUBSTR(B1_COD, 1, 3)) != 'C03' .AND. (SUBSTR(B1_COD, 1, 3)) != 'C04'  
else
	fil := .T. // cancela filtro para adm
end
       
Return( fil  )
