#INCLUDE 'rwmake.ch'
User Function FixIE()

dbSelectArea("SA1")
dbSetorder(1)
dbGotop()

While !EOF() 
	
	RecLock('SA1')
	A1_INSCR := ToDig(A1_INSCR, 14)
	
	MSUnLock()
	
	dbSkip()
EndDo

dbSelectArea("SA4")
dbSetorder(1)
dbGotop()

While !EOF() 
	
	RecLock( 'SA4')
	A4_INSEST := ToDig(A4_INSEST, 14)
	
	MSUnLock()
	
	dbSkip()
EndDo

Return()

Static Function ToDig(c_Str, n_Dig)     
Local i

c_Tmp := space(0)

n_Len = len (c_Str)

For i:= 1 to n_Len
	If  ! (substr(c_Str,i,1) $ '.-/\')
	//ISDIGIT(substr(c_Str,i,1))
		c_Tmp += substr(c_Str,i,1)
	End 
NEXT

c_Tmp := ALLTRIM( c_Tmp )	
n_Len = len (c_Tmp)

If n_Len > n_Dig  
	c_Tmp = substr(c_Tmp,1,n_Dig)
ElseIf n_Len < n_Dig
	c_Tmp += SPACE(n_Dig - n_Len)
End	

c_Str = c_Tmp	

Return( c_Tmp )


