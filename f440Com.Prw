#include "rwmake.ch"
/*/
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
������������������������������������������������������������������������������ͻ��
��� Programa  � F44OCOM    � Autor � MARCOS GOMES (TAGGS) � Data �  23/07/2013 ���
������������������������������������������������������������������������������͹��
��� Descricao � Grava o FLAG E3_X_BLOQ de acordo com o mesmo campo do cadastro ���
���           � de vendedores A3_X_BLOQ se ha bloqueio do vendedor.            ���
������������������������������������������������������������������������������͹��
��� Uso       � Clientes PROTHEUS. OUROLUX                                     ���
������������������������������������������������������������������������������͹��
���   DATA    � Alteracao                                        �   Analista  ���
������������������������������������������������������������������������������͹��
���   /  /    � -                                                �             ���
������������������������������������������������������������������������������ͼ��
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
/*/
User Function f440Com()

Local aAREA_ATU	:= GETAREA()
Local aAREA_SA3	:= SA3->(GETAREA())    
Local aAREA_SE3	:= SE3->(GETAREA())    

//��������������������������������������������������������������Ŀ
//� Busca o(s) codigo(s) do(s) vendedor(es)                      �
//����������������������������������������������������������������
For Uy := 1 to 5
   	cCampo	:= "F2_VEND" + AllTrim( STR(Uy) )
        		
	cCodVend	:= SF2->(&cCampo)
		
	If !EMPTY( cCodVend )
    	//��������������������������������������������������������������Ŀ
		//� (SA3) - Posiciona o cadastro de Vendedores                   �
		//����������������������������������������������������������������
		DBSelectArea("SA3")
		DBSetOrder(1)
		DBSeek( xFiliaL("SA3") + cCodVend, .f. )
		        				
		//��������������������������������������������������������������Ŀ
		//� (SE3) - Posiciona e atualiaza as comissoes geradas           �
		//����������������������������������������������������������������
		DBSelectArea("SE3")
		DBSetOrder(2)
		    
		If DBSeek( xFilial("SE3") + cCodVend + SF2->( F2_SERIE  + F2_DOC ) )
			While SE3->(!EOF()) .AND. SE3->E3_FILIAL = xFilial("SE3") .AND. SE3->E3_VEND = cCodVend .and. SE3->( E3_PREFIXO + E3_NUM ) = SF2->( F2_SERIE + F2_DOC )
				RECLOCK("SE3", .F. )
				SE3->E3_X_BLOQ	:= SA3->A3_X_BLOQ
				SE3->(DBSkip())
			EndDo
		EndIf
                 		
	EndIf
Next Uy

RESTAREA( aAREA_SE3 )
RESTAREA( aAREA_SA3 )
RESTAREA( aAREA_ATU )

Return()