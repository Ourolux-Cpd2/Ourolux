User Function admin	
Local t1 := Time(), t2 := 0, t3:= 0
Local aUsers  := AllUsers(.F.,.F.),i,j,cReturn := '' 	
 
//Usuarios que pertencam ao grupo 
For i:=1 to Len(aUsers)
  If aUsers[i][1][17]  // Bloqueado
  	cReturn := cReturn + Alltrim(aUsers[i][1][1]) + ';'
  endif
Next i 
   
if cReturn <> '' 
	cReturn := Subs(cReturn,1,Len(cReturn)-1)
endif
//t3 := Time()	   
Return cReturn

User Function tstwf()
Local aNomeGrupo := {'WFENTRADA','Vendas','Contas','Repres','Clientes'} 

U_GrpEmail(aNomeGrupo) 

return
