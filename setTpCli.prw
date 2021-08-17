
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �SetTpCli     �Autor  �Eletromega          � Data �  04/01/08���
�������������������������������������������������������������������������͹��
���Desc.     � Gatilho to set UA_TIPOCLI                                  ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP8                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

#Include "Rwmake.ch"

User Function setTpCli(cCodCli,cCodLoja)
Local aAreaSA1		:= SA1->(GetArea())
Local aArea	   		:= GetArea()
Local cTpCli 		:= "" 
Local cInscricao    := ""
Local lIE 	        // True caso o cliente tem Inscri�ao Estadual

DbSelectArea( "SA1" )
DbSetOrder( 1 )

If 	MsSeek( xFilial( "SA1" ) + cCodCli + cCodLoja )
   	cTpCli 	 	:= SA1->A1_TIPO
   	cEstCli  	:= SA1->A1_EST
   	cInscricao 	:= SA1->A1_INSCR 
   	lIE 	 	:= IIf(Empty(cInscricao).Or."ISENT"$Upper(cInscricao).Or."RG"$cInscricao,.F.,.T.)

	If cTpCli == "F" .And. lIE .And.; 
		cEstCli $ "AC/AL/AP/AM/BA/CE/DF/ES/GO/MA/MG/MS/MT/PA/PB/PE/PI/RJ/RN/RO/RR/RS/SE/TO" //Except SP/SC/PR
    	
    	
    	If Empty (SA1->A1_GRPTRIB) .Or. SA1->A1_GRPTRIB == "002"   
    		
    		cTpCli := "S"  
    
    	EndIf
   
   
   EndIf

EndIf                                                 
     
RestArea(aAreaSA1) 
RestArea(aArea)

Return (cTpCli)
