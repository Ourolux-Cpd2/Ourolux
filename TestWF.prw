#INCLUDE 'RWMAKE.CH'
#INCLUDE "TBICONN.CH"   

User Function TestWF()

Local oHTML,cID
Local aNomegrupo := {'ADMINISTRADORES','WFTST'}

//PREPARE ENVIRONMENT EMPRESA "01" FILIAL "01"

oProcess:= TWFProcess():New("TESTE","TESTE")
oProcess:NewTask("Inicio","\WORKFLOW\TransMod2.htm")
oProcess:cSubject := "TESTE WORKFLOW"
	
oHtml := oProcess:oHTML   
  	
oProcess:oHTML:ValByName('NomEmp',"TESTE")
  	
oProcess:oHTML:ValByName('FilName',"TESTE")
	
oProcess:oHTML:ValByName('DOC',"TESTE")
	 
aAdd( ( oHTML:valByName( 'D3.Cod'  ) ),"TESTE")
aAdd( ( oHTML:valByName( 'D3.Desc' ) ),"TESTE")
aAdd( ( oHTML:valByName( 'D3.UN' ) ),"TESTE")
aAdd( ( oHTML:valByName( 'D3.Local' ) ),"TESTE")	
aAdd( ( oHTML:valByName( 'D3.Quant' ) ),"TESTE")											
	
oProcess:cTo := 'WRAHAL@OUROLUX.COM.BR' //U_GrpEmail(aNomegrupo) Retemails('WFTST')

cID := oProcess:Start()
conout(cID)
oProcess:Finish()             
	
Return