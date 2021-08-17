#include "rwmake.ch"     
#INCLUDE "TOPCONN.CH"
      

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSERASA    บAutor  ณMicrosiga           บ Data ณ  29/01/16   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ  Gerar arquivo Serasa Reciprocidade                        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function Serasa2016()

SetPrvt("NOMEPROG,CPERG,CCADASTRO,AREGISTROS,MCCHAVE,MCALIAS")
SetPrvt("MNINDICE,MNIND_SE11,MNIND_SE12,MNIND_SE13,I,J")
SetPrvt("aEstru,CNOMEARQ,CIND1,MLCGC,D101,D102")
SetPrvt("D103,D104,D105,D106,D107,D108")
SetPrvt("D109,D110,D111,D112,DF1,DF2")
SetPrvt("DF3,RESTO1,PRIDIG,DF4,DF5,DF6")
SetPrvt("RESTO2,SEGDIG,CARQ,NHDLARQ,NIDREG01,NIDREG02")
SetPrvt("NIDREG03,NIDREG04,NIDREG07,CLINHA,CCLIENTE,CTIPCL")
SetPrvt("NULTCOMP,")

dDataFim := "14/06/2118"

nomeprog  :="SER001"
cPerg     :="SER001"
cCadastro := OemToAnsi("Geraฦo do arquivo para Serasa")
aRegistros:={}
/*mCchave   := "E1_FILIAL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO"       //2
mCalias   := "SE1"
mNindice  := 0
//EXECBLOCK("URBIND",.F.,.F.)
mNind_se11:= mNindice
mCchave   := "E1_FILIAL+DTOS(E1_EMISSAO)+E1_NOMCLI+E1_PREFIXO+E1_NUM+E1_PARCELA"      //6
mCalias   := "SE1"
mNindice  := 0
//EXECBLOCK("URBIND",.F.,.F.)
mNind_se12:= mNindice
mCchave   := "E1_FILIAL+DTOS(E1_BAIXA)+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO"         //u
mCalias   := "SE1"
mNindice  := 0
//EXECBLOCK("URBIND",.F.,.F.)
mNind_se13:= mNindice                         */
         

AjustaSX1(cPerg)
Pergunte(cPerg,.F.)               // Pergunta no SX1       

//If (CtoD(dDataFim) > dDatabase)

	@ 96,42 TO 323,566 DIALOG oDlg1 TITLE "Gera็ใo do arquivo para Serasa"
	@ 8,01 TO 90,261
	@ 23,18 SAY '               Este procedimento ira gerar o arquivo texto(SERASA.TXT) de clientes para  o  serasa'
	@ 33,18 SAY 'Atencao!! Clientes que nao tiverem CNPJ ou CNPJ errado nao serao enviados.
	@ 95,139 BMPBUTTON TYPE 5 ACTION Pergunte("SER001")
	@ 95,168 BMPBUTTON TYPE 1 ACTION SERASA1()
	@ 95,196 BMPBUTTON TYPE 2 ACTION Close(Odlg1)
	
	ACTIVATE DIALOG oDlg1 CENTER  
//Else
//	MSGAlert("Favor entrar em contato com a Sensus. Este programa expirou!!!")
//EndIf

return
        

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSERASA1    บAutor  ณMicrosiga           บ Data ณ  01/29/16   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function SERASA1()


CLOSE(Odlg1)

aEstru     := array(12,4)
aEstru[01] := { "TR_CLIENTE","C",006,0 }
aEstru[02] := { "TR_PREFIXO","C",003,0 }
aEstru[03] := { "TR_NUMERO" ,"C",009,0 }
aEstru[04] := { "TR_PARCELA","C",001,0 }
aEstru[05] := { "TR_EMISSAO","D",008,0 }
aEstru[06] := { "TR_VENCIDO","N",014,2 }
aEstru[07] := { "TR_VENCER" ,"N",014,2 }
aEstru[08] := { "TR_VALOR"  ,"N",014,2 }
aEstru[09] := { "TR_VENCTO" ,"D",008,0 }
aEstru[10] := { "TR_PAGTO"  ,"D",008,0 }
aEstru[11] := { "TR_TPDADOS","C",002,0 }
aEstru[12] := { "TR_QTPGT"  ,"N",005,0 }

procregua(01)

cNome := CriaTrab(aEstru,.T.)
If (Select("TRB01") <> 0)
   DbSelectArea("TRB01")
   DbCloseArea("TRB01")
EndIf
   
DbCreate(cNome,aEstru)
DbUseArea(.T.,,cNome,"TRB01",Nil,.F.)
cIndNome := CriaTrab(Nil,.F.)	
indRegua("TRB01",cIndNome,"TR_CLIENTE+TR_TPDADOS",,,"Selecionando registros...")

Processa({|| SERASA2() },"Gerando arquivo auxiliar")
Processa({|| SERASA3() },"Gerando arquivo texto")

RETURN
 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSERASA2   บAutor  ณMicrosiga           บ Data ณ  01/29/16   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function SERASA2()   
Local cQuery    := ""       
Local cCliente := ""

dbSelectArea("SE1")
dbSetOrder(6)
dbSeek(xFilial("SE1")+DTOS(mv_par01),.T.)   
dbGoTop()
Procregua(Reccount())
Incproc("Recebimentos a vista") 

While !EOF() .And. XFILIAL("SE1")==SE1->E1_FILIAL .And. SE1->E1_EMISSAO >= MV_PAR01 .And. SE1->E1_EMISSAO <= MV_PAR02 .And. SE1->E1_TIPO <> 'JR ' 
				
	 // Procregua(Reccount())
      Incproc("Recebimentos a vista") 	  
      dbSelectArea("SA1")
      dbSetOrder(1)
      dbSeek(xFilial("SA1")+se1->e1_cliente,.T.)


      If E1_BAIXA < MV_PAR01 .OR. E1_BAIXA > MV_PAR02 .OR.  (SE1->E1_EMISSAO < YearSub(dDataBase, 5))
         dbSkip()
         LOOP
      EndIf
      
    /*  If sa1->a1_tipo #'R'
         dbSelectArea("SE1")
         dbSkip()
         LOOP
      EndIf    */ 
      
      //Ignora CNPJ da Ourolux, pois dแ erro no validador do Serasa
	  If ( SA1->A1_CGC == "05393234000160")
         dbSelectArea("SE1")
         dbSkip()
         LOOP           
	  EndIf
	       
	  //ignora CNPJ < 14
     If Len(AllTrim(SA1->A1_CGC)) < 14
         dbSelectArea("SE1")
         dbSkip()
         LOOP
      EndIf
      	  
      If EMPTY(Val(SA1->A1_CGC))
         dbSelectArea("SE1")
         dbSkip()
         LOOP
      EndIf

//***** TESTE CGC
      mLcgc := .F.            
      mLcgc := ValidaCNPJ(SA1->A1_CGC)

      If mLcgc == .F.
         dbSelectArea("SE1")
         dbSkip()
         LOOP
      EndIf

      dbSelectArea("SE1")

      If ((SE1->E1_EMISSAO == SE1->E1_BAIXA ) .AND. (SE1->E1_SALDO == 0))
         dbSelectArea("TRB01")
         RECLOCK('TRB01',.T.)
         TRB01->TR_CLIENTE := SE1->E1_CLIENTE
      	 TRB01->TR_NUMERO  := SE1->E1_NUM
      	 TRB01->TR_PARCELA := SE1->E1_PARCELA
         TRB01->TR_QTPGT   := 1
         TRB01->TR_VALOR   := SE1->E1_VALOR
         TRB01->TR_TPDADOS := "03"         
         TRB01->TR_EMISSAO := SE1->E1_EMISSAO
         TRB01->TR_VENCTO  := SE1->E1_VENCTO  
         TRB01->TR_PAGTO   := SE1->E1_BAIXA
         MSUNLOCK('TRB01')
      EndIf

      dbSelectArea("SE1")
      dbSkip()
END


dbSelectArea("SE1")    
// dbSetOrder(T)
DbOrderNickName("BAIXA")
dbSeek(xFilial("SE1")+DTOS(mv_par01),.T.)
Procregua(Reccount())
Incproc("Recebimentos a prazo")
            
While !EOF() .And. XFILIAL("SE1")==SE1->E1_FILIAL .And. SE1->E1_BAIXA >= MV_PAR01 .And. SE1->E1_BAIXA <= MV_PAR02 .And. SE1->E1_TIPO <> 'JR '

	 // Procregua(Reccount())
      Incproc()
         
     /* IF E1_NUM == '000025355'
           Alert ("teste")
      EndIf  */
      
      If E1_BAIXA < MV_PAR01 .OR. E1_BAIXA > MV_PAR02 .OR.  (SE1->E1_EMISSAO < YearSub(dDataBase, 5))
         dbSkip()
         LOOP
      EndIf

      dbSelectArea("SA1") 
      dbSetOrder(1)
      dbSeek(xFilial("SA1")+SE1->E1_CLIENTE,.T.)
                                                  
      //Ignora CNPJ da Ourolux, pois dแ erro no validador do Serasa
	  If ( SA1->A1_CGC == "05393234000160")
         dbSelectArea("SE1")
         dbSkip()
         LOOP           
	  EndIf
	  
      If EMPTY(Val(sa1->a1_cgc))
         dbSelectArea("SE1")
         dbSkip()
         LOOP
      EndIf

	  //ignora CNPJ < 14
     If Len(AllTrim(SA1->A1_CGC)) < 14
         dbSelectArea("SE1")
         dbSkip()
         LOOP
      EndIf
      
//**** TESTE CGC  
      mLcgc := .F.
      mLcgc := ValidaCNPJ(SA1->A1_CGC)

      If mLcgc == .F.
         dbSelectArea("SE1")
         dbSkip()
         LOOP
      EndIf

      dbSelectArea("SE1")

      dbSelectArea("TRB01")
      RECLOCK('TRB01',.T.)
      TRB01->TR_CLIENTE := SE1->E1_CLIENTE
      TRB01->TR_PREFIXO := SE1->E1_PREFIXO
      TRB01->TR_NUMERO  := SE1->E1_NUM
      TRB01->TR_PARCELA := SE1->E1_PARCELA
      TRB01->TR_EMISSAO := SE1->E1_EMISSAO
      TRB01->TR_VALOR   := SE1->E1_VALOR
      TRB01->TR_VENCTO  := SE1->E1_VENCTO  
         //caso a baixa estแ com data inferior a data de emissใo, dแ erro no validador
      If !Empty(SE1->E1_BAIXA) .And. (SE1->E1_BAIXA < SE1->E1_EMISSAO)
      	TRB01->TR_PAGTO   := SE1->E1_EMISSAO
      Else
      	TRB01->TR_PAGTO   := SE1->E1_BAIXA  
      EndIf      
       
      //se for um adiantamento RA a parcela serแ 'Z'
      If (TRB01->TR_PREFIXO) == "RA "
      		TRB01->TR_PARCELA := "Z"      
      EndIf
                         
      
      TRB01->TR_TPDADOS := "04"
      MSUNLOCK('TRB01')

      dbSelectArea("SE1")
      dbSkip()
END
   


dbSelectArea("SA1")
dbSetOrder(1)
dbSeek(xFilial("SA1"),.T.)
Procregua(Reccount())      
Incproc("Compromissos a vencer")

While !EOF() .And. XFILIAL("SA1")==SA1->A1_FILIAL

	  //Procregua(Reccount())
	  Incproc()
	  
      //Ignora CNPJ da Ourolux, pois dแ erro no validador do Serasa
	  If ( SA1->A1_CGC == "05393234000160")
	     dbSkip()
         LOOP           
	  EndIf
	  
      If EMPTY(Val(sa1->a1_cgc)) 
         dbSkip()
         LOOP
      EndIf

	  //ignora CNPJ < 14
     If Len(AllTrim(SA1->A1_CGC)) < 14
        // dbSelectArea("SE1")
         dbSkip()
         LOOP
      EndIf
      
/**** TESTE CGC   */
      mLcgc := .F.
      mLcgc := ValidaCNPJ(SA1->A1_CGC)

      If mLcgc == .F.
         dbSkip()
         LOOP
      EndIf

      dbSelectArea("SE1")
      dbSetOrder(2)
      dbSeek(xFilial("SE1")+sa1->a1_cod+sa1->a1_loja,.T.)
      While !EOF() .And. XFILIAL("SE1")==SE1->E1_FILIAL .AND. SA1->A1_COD == E1_CLIENTE .AND. ;
      					SA1->A1_LOJA == E1_LOJA .AND. SE1->E1_EMISSAO >= MV_PAR01 .AND. SE1->E1_EMISSAO <= MV_PAR02 .And. SE1->E1_TIPO <> 'JR ' ;
      		 			.And. DateDiffYear(YearSub(dDataBase, 5),SE1->E1_EMISSAO ) <= 5

            If se1->e1_saldo > 0.00
               dbSelectArea("TRB01")
               dbSetOrder(1)
               dbSeek(se1->e1_cliente,.F.)
                  RECLOCK('TRB01',.T.)                                    
                  TRB01->TR_CLIENTE := SE1->E1_CLIENTE
  				  TRB01->TR_PREFIXO := SE1->E1_PREFIXO
      		      TRB01->TR_NUMERO  := SE1->E1_NUM
      			  TRB01->TR_PARCELA := SE1->E1_PARCELA
                  TRB01->TR_TPDADOS := "07"   
                  TRB01->TR_EMISSAO := SE1->E1_EMISSAO
      		      TRB01->TR_VENCTO  := SE1->E1_VENCTO
                  If SE1->E1_VENCTO > MV_PAR02
                     TRB01->TR_VENCER  := SE1->E1_SALDO
                  ELSE
                     TRB01->TR_VENCIDO := SE1->E1_SALDO
                  EndIf
                  MSUNLOCK('TRB01')
            EndIf
            dbSelectArea("SE1")
            dbSkip()
      END
      dbSelectArea("SA1")
      dbSkip()
END    

//registros que foram excluํdos


dbSelectArea("SE1")
dbSetOrder(1)

If Select("QRY1") <> 0
	DBSelectArea("QRY1")
	DBCloseArea()
EndIf

cQuery := ""
cQuery += " SELECT "
cQuery += " E1_CLIENTE, E1_PREFIXO, E1_NUM, E1_PARCELA, E1_EMISSAO, E1_VALOR, E1_VENCTO, E1_BAIXA   "
cQuery += " FROM "            
cQuery += RetSqlName("SE1") + " E1 "
cQuery += " WHERE "
cQuery += " E1_EMISSAO >=  '" + DTOS(MV_PAR01) +"' AND E1_EMISSAO <= '" + DTOS(MV_PAR02) + "'"
cQuery += " AND E1.E1_FILIAL = '"+xFilial('SE1')+"' 
cQuery += " AND E1.D_E_L_E_T_ = '*' AND E1.E1_TIPO <> 'JR '"

//memowrite("c:\temp\grarqsrs.txt", cQuery)

TCQuery cQuery NEW ALIAS "QRY1"

DbSelectArea ("QRY1")

dbGotop()
Procregua(Reccount())
Incproc("Recebimentos excluํdos")
    
WHILE !QRY1->(EOF())
           
      cCliente := QRY1->E1_CLIENTE
  
	 // Procregua(Reccount())   
      Incproc()
      dbSelectArea("SA1")
      dbSetOrder(1)
      dbSeek(xFilial("SA1")+cCliente,.T.)
 
	
     //SE O CLIENTE FOR DO EXTERIOR DESCONSIDERAR
      If EMPTY(Val(sa1->a1_cgc))
      	dbSelectArea("QRY1")
      	dbSkip()                        
      	Loop
      EndIf
      
      If Len(AllTrim(SA1->A1_CGC)) < 14
         dbSelectArea("QRY1")
         dbSkip()
         LOOP
      EndIf
      	  
      dbSelectArea("TRB01")
      RECLOCK('TRB01',.T.)
      TRB01->TR_CLIENTE := QRY1->E1_CLIENTE
      TRB01->TR_PREFIXO := QRY1->E1_PREFIXO
      TRB01->TR_NUMERO  := QRY1->E1_NUM
      TRB01->TR_PARCELA := QRY1->E1_PARCELA
      TRB01->TR_EMISSAO := StoD(QRY1->E1_EMISSAO)
      TRB01->TR_VALOR   := Val("99999999999.99") 
      TRB01->TR_VENCTO  := Stod(QRY1->E1_VENCTO)  
         //caso a baixa estแ com data inferior a data de emissใo, dแ erro no validador
      If !Empty(QRY1->E1_BAIXA) .And. (QRY1->E1_BAIXA < QRY1->E1_EMISSAO)
      	TRB01->TR_PAGTO   := StoD(QRY1->E1_EMISSAO)
      Else
      	TRB01->TR_PAGTO   := StoD(QRY1->E1_BAIXA)  
      EndIf                         
	
	  MSUNLOCK()
	  dbSelectArea("QRY1")     
      dbSkip()	  
EndDo




Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSERASA3   บAutor  ณMicrosiga           บ Data ณ  01/29/16   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function SERASA3()

Local nValor := 0   
Local bOk                    
Local cTitulo :=''   
Local cTipo   :=''            
Local dCliDesde :=''

/*If empty(MV_PAR03)           

	cIniFile := GetADV97()
  	cPath := GetPvProfString(GetEnvServer(),"RootPath","ERROR", cIniFile )+'\Backup\'	

	cArq	:= cPath +"SERASA1.TXT"          */
	cArq := '\Backup\SERASA.TXT'	
  /*
ELSE
	cArq	:= MV_PAR03
EndIf	*/
	

If File(cArq)
   fErase(cArq)
EndIf
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Criacao do arquivo texto informado.                          ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
nHdlArq  := MSFCREATE(cArq)
nIdreg01 := 0
nIdreg02 := 0
nIdreg03 := 0
nIdreg05 := 0
nIdreg07 := 0
                                           
If (mv_par03) == 1
   cTipo ='S'
ElseIf (mv_par03) == 2
   cTipo ='D'  
ElseIf (mv_par03) == 3
   cTipo ='M' 
EndIf                                

cLinha := '00RELATO COMP NEGOCIOS'+AllTrim(sm0->m0_cgc)+DTOS(mv_par01)+DTOS(mv_par02)+cTipo+Space(47)+'V.01'+Space(26)+CHR(13)+CHR(10)
fWrite(nHdlArq,cLinha)

dbSelectArea("TRB01")
dbSetOrder(1)
dbGoTop()
Procregua(Reccount())
While !EOF()

      Incproc()

      dbSelectArea("SA1")
      dbSetOrder(1)
      dbSeek(xFilial("SA1")+TRB01->TR_CLIENTE,.T.)
     
     //SE O CLIENTE FOR DO EXTERIOR DESCONSIDERAR
      If (Empty(AllTrim(SA1->A1_CGC)))  
      	dbSelectArea("TRB01")
      	dbSkip()                        
      	Loop
      EndIf
       
      //Ignora CNPJ da Ourolux, pois dแ erro no validador do Serasa
	  If ( AllTrim(SA1->A1_CGC) == "05393234000160")
         dbSelectArea("TRB01")
         dbSkip()
         LOOP           
	  EndIf   
	  
	  dCliDesde := SA1->A1_PRICOM
       
      If (Empty(SA1->A1_PRICOM))
      	dCliDesde := SA1->A1_XVENFIS
      EndIf

      cTipcl   := '1'
      If SA1->A1_MSBLQL=="1"
         cTipcl := '3'
      EndIf
     // If (dDatabase-SA1->A1_XLIBERA) <= 365
      If (dDatabase - dCliDesde) <= 365
         cTipcl := '2'
      EndIf
      nIdreg01:= nIdreg01 + 1      
      
     // cLinha  := '01'+AllTrim(SA1->A1_CGC)+'01'+DTOS(SA1->A1_XLIBERA)+cTipcl+Space(103)+CHR(13)+CHR(10)
      cLinha  := '01'+AllTrim(SA1->A1_CGC)+'01'+DTOS(dCliDesde)+cTipcl+Space(103)+CHR(13)+CHR(10)
      FWRITE(nHdlArq,cLinha)

 //     nIdreg02:= 0    
 
      dbSelectArea("TRB01")   

      cCliente := TRB01->TR_CLIENTE 
       
      While !EOF() .And. TRB01->TR_CLIENTE == cCliente       
                 
      		If ((TRB01->TR_VENCER) > 0)
      	   		nValor:= TRB01->TR_VENCER 
			ElseIf ((TRB01->TR_VENCIDO) > 0)  
      			nValor:= TRB01->TR_VENCIDO 
   			ElseIf ((TRB01->TR_VALOR) > 0)  
      			nValor:= TRB01->TR_VALOR 
      		EndIf
            
			If Len(AllTrim(TR_PARCELA)) > 0
				cTitulo := StrZero(Val(tr_numero),9)+TR_PARCELA  
			Else
				cTitulo := StrZero(Val(tr_numero),10) 			
			EndIf
			
      		
            nIdreg05:= nIdreg05 + 1
            cLinha  := '01'+AllTrim(SA1->A1_CGC)+'05'+cTitulo+DTOS(TR_EMISSAO)+;
            			StrZero(Val(SubStr(STR(nValor,14,2),1,11)),11)+StrZero(Val(SubStr(STR(nValor,14,2),13,2)),2)+;
                       DTOS(TR_VENCTO)+DTOS(TR_PAGTO)+;
                       Space(34)+Space(31)+CHR(13)+CHR(10)
            FWRITE(nHdlArq,cLinha)
            dbSelectArea("TRB01")
            dbSkip()
      END
END

cLinha := '99'+StrZero(nIdreg01,11)+Space(44)+StrZero(nIdreg05,11)+Space(62)+CHR(13)+CHR(10)
FWRITE(nHdlArq,cLinha)

dbSelectArea("SE1")
dbSetOrder(1)

FClose(nHdlArq)
SET CENTURY OFF   

bOk := CpyS2T( "\Backup\Serasa.txt", "c:\temp\", .F. )  
//bOk := CpyS2T( "\Backup\SA1.DBF", "d:\", .F. )  
//bOk := CpyS2T( "\Backup\SX3SE1.DBF", "d:\", .F. )  

 
MsgInfo("Arquivo c:\temp\Serasa.txt gerado com sucesso!","[SERASA] - SUCESSO")
RETURN


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAjustaSX1 บAutor  ณMicrosiga           บ Data ณ  29/01/16   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/


Static Function AjustaSX1( cPerg )

Local aHelpPor :={}
Local aHelpEng :={}
Local aHelpSpa :={}

aHelpPor := { 'Informe o Perํodo Inicial',;
			   'para Filtro.',;
			   '' }
				
aHelpSpa := aHelpPor
aHelpEng := aHelpPor
				
PutSx1( cPerg,; 		            //-- 01 - X1_GRUPO
	    '01',;                      //-- 02 - X1_ORDEM
	    'Perํodo De ?',;          //-- 03 - X1_PERGUNT
	    '',; 						//-- 04 - X1_PERSPA
	    '',;  						//-- 05 - X1_PERENG
	    'mv_ch1',;                  //-- 06 - X1_VARIAVL
	    'D',;                       //-- 07 - X1_TIPO
	    8,; 						//-- 08 - X1_TAMANHO
	    0,;                         //-- 09 - X1_DECIMAL
	    0,;                         //-- 10 - X1_PRESEL
	    'G',;                       //-- 11 - X1_GSC
	    '',;                        //-- 12 - X1_VALID
	    '',;		                //-- 13 - X1_F3
	    '',;                        //-- 14 - X1_GRPSXG
	    '',;                        //-- 15 - X1_PYME
	    'mv_par01',;                //-- 16 - X1_VAR01
	    'Sim',;                     //-- 17 - X1_DEF01
	    'Si',;                      //-- 18 - X1_DEFSPA1
	    'Yes',;                     //-- 19 - X1_DEFENG1
	    '',;                        //-- 20 - X1_CNT01
	    'Nao',;                     //-- 21 - X1_DEF02
	    'No',;                      //-- 22 - X1_DEFSPA2
	    'No',;                      //-- 23 - X1_DEFENG2
	    '',;                        //-- 24 - X1_DEF03
	    '',;                        //-- 25 - X1_DEFSPA3
	    '',;                        //-- 26 - X1_DEFENG3
	    '',;                        //-- 27 - X1_DEF04
	    '',;                        //-- 28 - X1_DEFSPA4
	    '',;                        //-- 29 - X1_DEFENG4
	    '',;                        //-- 30 - X1_DEF05
	    '',;                        //-- 31 - X1_DEFSPA5
	    '',;                        //-- 32 - X1_DEFENG5
	    aHelpPor,;                  //-- 33 - HelpPor
	    aHelpSpa,;                  //-- 34 - HelpSpa
	    aHelpEng,;                  //-- 35 - HelpEng
	    '')                         //-- 36 - X1_HELP 
	    
aHelpPor := { 'Informe o Perํodo Final',;
			   'para Filtro.',;
			   '' }
				
aHelpSpa := aHelpPor
aHelpEng := aHelpPor
				
PutSx1( cPerg,; 		            //-- 01 - X1_GRUPO
	    '02',;                      //-- 02 - X1_ORDEM
	    'Perํodo At้ ?',;          //-- 03 - X1_PERGUNT
	    '',; 						//-- 04 - X1_PERSPA
	    '',;  						//-- 05 - X1_PERENG
	    'mv_ch2',;                  //-- 06 - X1_VARIAVL
	    'D',;                       //-- 07 - X1_TIPO
	    8,; 						//-- 08 - X1_TAMANHO
	    0,;                         //-- 09 - X1_DECIMAL
	    0,;                         //-- 10 - X1_PRESEL
	    'G',;                       //-- 11 - X1_GSC
	    '',;                        //-- 12 - X1_VALID
	    '',;		                //-- 13 - X1_F3
	    '',;                        //-- 14 - X1_GRPSXG
	    '',;                        //-- 15 - X1_PYME
	    'mv_par02',;                //-- 16 - X1_VAR01
	    'Sim',;                     //-- 17 - X1_DEF01
	    'Si',;                      //-- 18 - X1_DEFSPA1
	    'Yes',;                     //-- 19 - X1_DEFENG1
	    '',;                        //-- 20 - X1_CNT01
	    'Nao',;                     //-- 21 - X1_DEF02
	    'No',;                      //-- 22 - X1_DEFSPA2
	    'No',;                      //-- 23 - X1_DEFENG2
	    '',;                        //-- 24 - X1_DEF03
	    '',;                        //-- 25 - X1_DEFSPA3
	    '',;                        //-- 26 - X1_DEFENG3
	    '',;                        //-- 27 - X1_DEF04
	    '',;                        //-- 28 - X1_DEFSPA4
	    '',;                        //-- 29 - X1_DEFENG4
	    '',;                        //-- 30 - X1_DEF05
	    '',;                        //-- 31 - X1_DEFSPA5
	    '',;                        //-- 32 - X1_DEFENG5
	    aHelpPor,;                  //-- 33 - HelpPor
	    aHelpSpa,;                  //-- 34 - HelpSpa
	    aHelpEng,;                  //-- 35 - HelpEng
	    '')                         //-- 36 - X1_HELP	       	    	       	    	    	       	    	       	    
	          
aHelpPor := { 'Informe o Tipo ',;
			   'do arquivo.',;
			   '' }
				
aHelpSpa := aHelpPor
aHelpEng := aHelpPor

PutSx1( cPerg,; 		            //-- 01 - X1_GRUPO
	    '03',;                      //-- 02 - X1_ORDEM
	    'Tipo Arquivo?',;         //-- 03 - X1_PERGUNT
	    'Tipo Arquivo?',; 			//-- 04 - X1_PERSPA
	    'Tipo Arquivo?',;  			//-- 05 - X1_PERENG
	    'mv_ch3',;                  //-- 06 - X1_VARIAVL
	    'N',;                       //-- 07 - X1_TIPO
	    1,; 						//-- 08 - X1_TAMANHO
	    0,;                         //-- 09 - X1_DECIMAL
	    0,;                         //-- 10 - X1_PRESEL
	    'C',;                       //-- 11 - X1_GSC
	    '',;                        //-- 12 - X1_VALID
	    '',;		                //-- 13 - X1_F3
	    '',;                        //-- 14 - X1_GRPSXG
	    '',;                        //-- 15 - X1_PYME
	    'mv_par03',;                //-- 16 - X1_VAR01
	    '1-Semanal',;               //-- 17 - X1_DEF01
	    '1-Semanal',;               //-- 18 - X1_DEFSPA1
	    '1-Semanal',;               //-- 19 - X1_DEFENG1
	    '',;                        //-- 20 - X1_CNT01
	    '2-Diaria',;                //-- 21 - X1_DEF02
	    '2-Diaria',;                //-- 22 - X1_DEFSPA2
	    '2-Diaria',;                //-- 23 - X1_DEFENG2
	    '3-Mensal',;                //-- 24 - X1_DEF03
	    '3-Mensal',;                //-- 25 - X1_DEFSPA3
	    '3-Mensal',;                //-- 26 - X1_DEFENG3
	    '',;                        //-- 27 - X1_DEF04
	    '',;                        //-- 28 - X1_DEFSPA4
	    '',;                        //-- 29 - X1_DEFENG4
	    '',;                        //-- 30 - X1_DEF05
	    '',;                        //-- 31 - X1_DEFSPA5
	    '',;                        //-- 32 - X1_DEFENG5
	    aHelpPor,;                  //-- 33 - HelpPor
	    aHelpSpa,;                  //-- 34 - HelpSpa
	    aHelpEng,;                  //-- 35 - HelpEng
	    '')                         //-- 36 - X1_HELP	 
					       	    	    	       	    	       	    
	          
	    	    	    
Return ( Nil )                          

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณValidaCNPJบAutor  ณMicrosiga           บ Data ณ  01/02/16   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ValidaCNPJ(cCNPJ)
Local lCNPJ := .F.

If SubStr(cCNPJ,13,2) #'  '
	d101   := Val(SubStr(cCNPJ,1,1))
	d102   := Val(SubStr(cCNPJ,2,1))
	d103   := Val(SubStr(cCNPJ,3,1))
	d104   := Val(SubStr(cCNPJ,4,1))
	d105   := Val(SubStr(cCNPJ,5,1))
	d106   := Val(SubStr(cCNPJ,6,1))
	d107   := Val(SubStr(cCNPJ,7,1))
	d108   := Val(SubStr(cCNPJ,8,1))
	d109   := Val(SubStr(cCNPJ,9,1))
	d110   := Val(SubStr(cCNPJ,10,1))
	d111   := Val(SubStr(cCNPJ,11,1))
	d112   := Val(SubStr(cCNPJ,12,1))
	df1    := 5*d101+4*d102+3*d103+2*d104+9*d105+8*d106+7*d107+6*d108+5*d109+4*d110+3*d111+2*d112
	df2    := df1/11
	df3    := INT(df2)*11
	resto1 := df1-df3
	If resto1 == 0 .OR. resto1 == 1
		pridig := 0
	ELSE
		pridig := 11-resto1
	EndIf
	df4    := 6*d101+5*d102+4*d103+3*d104+2*d105+9*d106+8*d107+7*d108+6*d109+5*d110+4*d111+3*d112+2*pridig
	df5    := df4/11
	df6    := INT(df5)*11
	resto2 := df4-df6
	If resto2 == 0 .OR. resto2 == 1
		segdig := 0
	ELSE
		segdig := 11-resto2
	EndIf
	If pridig==Val(SubStr(cCNPJ,13,1)) .And. segdig==Val(SubStr(cCNPJ,14,1))
		lCNPJ := .T.
	EndIf
EndIf

Return (lCNPJ)
