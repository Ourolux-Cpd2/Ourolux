#include "rwmake.ch"
#include "tbiconn.ch"
#include "tbicode.ch"
#include "colors.ch"
#include "font.ch"
#include "ap5mail.ch"  

User Function DBFUSU()

	Local cPerg := PadR("XNU001",10)
	
	ValidPerg(cPerg)
	
	Pergunte(cPerg,.F.)

	@ 000,000 To 160,350 Dialog _WndMain TITLE "Auditoria de Usu�rios MWL"
	@ 005,005 To 040,165
	@ 015,010 Say OemToAnsi("Este programa ira gerar dois Arquivos DBF�s para ")
	@ 025,010 say OemToAnsi("Abertura no Excel, MENUS.DBF e ACESSOS.DBF" )
	@ 055,080 Bmpbutton Type 1 Action ProcMenus()
	@ 055,110 Bmpbutton Type 2 Action Close(_WndMain)
	@ 055,140 Bmpbutton Type 5 Action Pergunte(cPerg,.T.)
	Activate Dialog _WndMain Centered
	
Return

Static Function ProcMenus()
      
	Close(_WndMain)
	Processa({|| RunReport()},"Processando ..." )
	
Return

Static Function RunReport()
	
	Local cNomeArq	:= "MENUS.DBF"
	Local cNomeAce	:= "ACESSOS.DBF"
	Local cNomeRel	:= "MENUS.CSV"	
	Local cNomeRAc	:= "ACESSOS.CSV"	
	Local aUsuario	:= AllUsers()
	Local aMenuAll	:= {}
	Local aAdminXnu	:= { "SIGALOJA","SIGAFIS","SIGACOM","SIGACON","SIGAGPE","SIGAEST","SIGAFAT","SIGAFIN","SIGAPON" }
	
	Local aCampos	:= {{"COD","C",6,0},{"MENU","C",50,0},{"GRUPO","C",35,0},{"DESCRI","C",35,0},{"MODO","C",1,0},{"TIPO","C",15,0},;
	                    {"FUNCAO","C",12,0},{"ACS","C",10,0},{"MODULO","C",40,0},{"ARQS","C",255,0},{"PESQ","C",1,0},{"VISU","C",1,0},;
	                    {"INCLUIR","C",1,0},{"ALTERAR","C",1,0},{"EXCLUIR","C",1,0},{"A6","C",1,0},{"A7","C",1,0},{"A8","C",1,0},;
	                    {"A9","C",1,0},{"A0","C",1,0},{"LOGIN","C",20,0},{"NOME","C",35,0},{"DEPTO","C",30,0},{"CARGO","C",30,0},;
	                    {"EMAIL","C",35,0}}
	
	Local cRelTrb	:= CriaTrab(aCampos,.T.)
	Local aAcessos  := {}                   
	Local aModulos  := fModulos()
	Local aCampos	:= {{"COD","C",6,0},{"ACESSO","C",40,0},{"LOGIN","C",20,0},{"NOME","C",35,0},{"DEPTO","C",30,0},{"CARGO","C",30,0},{"EMAIL","C",35,0}}
	Local cAceTrb	:= CriaTrab(aCampos,.T.)
	
	AADD(aAcessos,'Excluir Produtos')
	AADD(aAcessos,'Alterar Produtos')
	AADD(aAcessos,'Excluir Cadastros')
	AADD(aAcessos,'Aletar Solicit.Compras')
	AADD(aAcessos,'Excluir Solicit.Compras')
	AADD(aAcessos,'Alterar Pedidos Compras')
	AADD(aAcessos,'Excluir Pedidos Compras')
	AADD(aAcessos,'Analisar Cota��es')
	AADD(aAcessos,'Relat.Ficha Cadastral')
	AADD(aAcessos,'Relat Bancos')
	AADD(aAcessos,'Relacao Solicit.Compras')
	AADD(aAcessos,'Relacao de Pedidos Compra')
	AADD(aAcessos,'Alterar Estruturas')
	AADD(aAcessos,'Excluir Estruturas')
	AADD(aAcessos,'Alterar TES')
	AADD(aAcessos,'Excluir TES')
	AADD(aAcessos,'Inventario')
	AADD(aAcessos,'Fechamento Mensal')
	AADD(aAcessos,'Proc Diferenca Inventario')
	AADD(aAcessos,'Alterar Pedidos de Venda')
	AADD(aAcessos,'Excluir Pedidos de Venda')
	AADD(aAcessos,'Alterar Help�s')
	AADD(aAcessos,'Substitui��o de TItulos')
	AADD(aAcessos,'Inclus�o do Dados Via F3')
	AADD(aAcessos,'Rotina de Atendimento')
	AADD(aAcessos,'Proc. Troco')
	AADD(aAcessos,'Proc. Sangria')
	AADD(aAcessos,'Border� Chques Pr�-Dat.')
	AADD(aAcessos,'Rotina de Pagamento')
	AADD(aAcessos,'Rotina de Recebimento')
	AADD(aAcessos,'Troca de Mercadorias')
	AADD(aAcessos,'Acesso Tabela de Pre�os')
	AADD(aAcessos,'N�o Utilizado')
	AADD(aAcessos,'N�o Utilizado')
	AADD(aAcessos,'Acesso COndicao Negociada')
	AADD(aAcessos,'Alterar Database do Sist.')
	AADD(aAcessos,'Alterar Empenhos de OPs.')
	AADD(aAcessos,'N�o Utilizado')
	AADD(aAcessos,'Form.Pre�os Todos Niveis')
	AADD(aAcessos,'Configura Venda Rapida')
	AADD(aAcessos,'Abrir/Fechar Caixa')
	AADD(aAcessos,'Excluir Nota/Or� Loja')
	AADD(aAcessos,'Alterar Bem Ativo Fixo')
	AADD(aAcessos,'Excluir Bem Ativo Fixo')
	AADD(aAcessos,'Incluir Bem Via Copia')
	AADD(aAcessos,'Tx Juros Condic Negociada')
	AADD(aAcessos,'Liberacao Venda Forcad TEF')
	AADD(aAcessos,'Cancelamento Venda TEF')
	AADD(aAcessos,'Cadastra Moeda na Abertura')
	AADD(aAcessos,'Alterar Num. da NF')
	AADD(aAcessos,'Emitir NF Retorativa')
	AADD(aAcessos,'Excluir Baixa - Receber')
	AADD(aAcessos,'Excluir Baixa - Pagar')
	AADD(aAcessos,'Incluir Tabelas')
	AADD(aAcessos,'Alterar Tabelas')
	AADD(aAcessos,'Excluir Tabelas')
	AADD(aAcessos,'Incluir Contratos')
	AADD(aAcessos,'Alterar Contratos')
	AADD(aAcessos,'Excluir Contratos')
	AADD(aAcessos,'Uso Integra��o SIGAEIC')
	AADD(aAcessos,'Incluir Emprestimo')
	AADD(aAcessos,'Alterar Emprestimo')
	AADD(aAcessos,'Excluir Emprestimo')
	AADD(aAcessos,'Incluir Leasing')
	AADD(aAcessos,'Alterar Leasing')
	AADD(aAcessos,'Excluir Leasing')
	AADD(aAcessos,'Incluir Imp.Nao Financ.')
	AADD(aAcessos,'Alterar Imp.Nao Financ.')
	AADD(aAcessos,'Excluir Imp.Nao Financ.')
	AADD(aAcessos,'Incluir Imp.Financiada')
	AADD(aAcessos,'Alterar Imp.Financiada')
	AADD(aAcessos,'Excluir Imp.Financiada')
	AADD(aAcessos,'Incluir Imp.Fin.Export.')
	AADD(aAcessos,'ALterar Imp.Fin.Export.')
	AADD(aAcessos,'Excluir Imp.Fin.Export.')
	AADD(aAcessos,'Incluir Contrato')
	AADD(aAcessos,'Alterar Contrato')
	AADD(aAcessos,'Excluir Contrato')
	AADD(aAcessos,'Lancar Taxa Libor')
	AADD(aAcessos,'Consolidar Empresas')
	AADD(aAcessos,'Incluir Cadastros')
	AADD(aAcessos,'Alterar Cadastros')
	AADD(aAcessos,'Incluir Cotacao Moedas')
	AADD(aAcessos,'Alterar Cotacao Moedas')
	AADD(aAcessos,'Excluir Cotacao Moedas')
	AADD(aAcessos,'Incluir Corretoras')
	AADD(aAcessos,'Alterar Corretoras')
	AADD(aAcessos,'Excluir Corretoras')
	AADD(aAcessos,'Incluir Imp./Exp./Cons')
	AADD(aAcessos,'Alterar Imp./Exp./Cons')
	AADD(aAcessos,'Excluir Imp./Exp./Cons')
	AADD(aAcessos,'Baixar Solicitacoes')
	AADD(aAcessos,'Visualiza Arquivo Limite')
	AADD(aAcessos,'Imprime Doctos.Cancelados')
	AADD(aAcessos,'Reativa Doctos.Cancelados')
	AADD(aAcessos,'Consulta Doctos.Obsoletos')
	AADD(aAcessos,'Imprime Doctos.Obsoletos')
	AADD(aAcessos,'Consulta Doctos.Vencidos')
	AADD(aAcessos,'Imprime Doctos.Vencidos')
	AADD(aAcessos,'Def.Laudo Final Entrega')
	AADD(aAcessos,'Imprime Param Relatorios')
	AADD(aAcessos,'Transfere Pendencias')
	AADD(aAcessos,'Usa relatorio por e-mail')
	AADD(aAcessos,'Consulta posicao cliente')
	AADD(aAcessos,'Manuten. Aus Temp. Todos')
	AADD(aAcessos,'Manuten. Aus. Temp Usuario')
	AADD(aAcessos,'Forma��o de Pre�o')
	AADD(aAcessos,'Gravar Resposta Parametros')
	AADD(aAcessos,'Configurar Consulta F3')
	AADD(aAcessos,'Permite Alterar Configura��o de Impres.')
	AADD(aAcessos,'Gerar Rel. em Disco Local')
	AADD(aAcessos,'Gerar Rel. no Servidor')
	AADD(aAcessos,'Incluir Solic. Compras')
	AADD(aAcessos,'MBrowse - Visualiza outras filiais')
	AADD(aAcessos,'MBrowse - Edita registros de outras filiais')
	AADD(aAcessos,'MBrowse - Permite o uso de filtro')
	AADD(aAcessos,'F3 - Permite o uso de filtro')
	AADD(aAcessos,'MBrowse - Permite a Configura��o de Colunas')
	AADD(aAcessos,'Altera Or�amento Aprovado')
	AADD(aAcessos,'Revisa Or�amento Aprovado')
	AADD(aAcessos,'Usa Impressora no Server')
	AADD(aAcessos,'Usa Impressora no Client')
	AADD(aAcessos,'Agendar Processos/Relat�rios')
	AADD(aAcessos,'Processos Identicos na MDI')
	AADD(aAcessos,'Datas diferentes na MDI')
	AADD(aAcessos,'Cad.Cli. no Catalogo E-mail')
	AADD(aAcessos,'Cad.For. no Catalogo E-mail')
	AADD(aAcessos,'Cad.Ven. no Catalogo E-mail')
	AADD(aAcessos,'Impr.informa��es personalizadas')
	AADD(aAcessos,'Respeita Parametro MV_WFMESSE')
	AADD(aAcessos,'Aprovar/Rejeitar Pre Estrutura')
	AADD(aAcessos,'Criar Estrutura com base em Pr� Estrut')
	AADD(aAcessos,'Gerir Etapas')
	AADD(aAcessos,'Gerir Despesas')
	AADD(aAcessos,'Liberar Despesa para Faturamento')
	AADD(aAcessos,'Lib. Ped. Venda(Credito)')
	AADD(aAcessos,'LIb. Ped. Venda(Estoque)')
	AADD(aAcessos,'Habilitar op��o Executar(Ctrl+R)')
	AADD(aAcessos,'Permite incluir Ordem de Produ��o')
	AADD(aAcessos,'Acesso via ActiveX')
	AADD(aAcessos,'Excluir Bens')
	AADD(aAcessos,'Rateio do item por centro de custo')
	AADD(aAcessos,'Alterar o cadastro de clientes')
	AADD(aAcessos,'Excluir Cadastro de clientes')
	AADD(aAcessos,'Habilitar Filtros nos relat�rios')
	AADD(aAcessos,'Contatos no Catalogo E-mail')
	AADD(aAcessos,'Criar formulas nos relatorios')
	AADD(aAcessos,'Personalizar relatorios')
	AADD(aAcessos,'Acesso ao cadastro de lotes')
	AADD(aAcessos,'Gravar Resposta Parametros por Empresa')
	AADD(aAcessos,'Manuten��o no Reposit�rio de Imagens')
	AADD(aAcessos,'Criar Relat�rios Personaliz�veis')
	AADD(aAcessos,'Permiss�o para utilizar o TOII')
	AADD(aAcessos,'Acesso ao SigaRPM')
	AADD(aAcessos,'Mai�scula/Min�sculo na consulta padr�o')
	AADD(aAcessos,'Valida acesso do grupo por Emp/Filial')
	AADD(aAcessos,'Acessa Base Instalada no Cad. T�cnico')
	AADD(aAcessos,'Desabilita op��o usu�rios do menu')
	AADD(aAcessos,'Impress�o local p/ componente gr�fico')
	AADD(aAcessos,'Impress�o em planilha')
	AADD(aAcessos,'Acesso a scripts confidenciais')
	AADD(aAcessos,'Qualifica��o de Suspects')
	AADD(aAcessos,'Execu��o de scripts din�micos')
	AADD(aAcessos,'MDI - Permite encerrar ambiente pelo X')
	AADD(aAcessos,'Permite utilizar o WalkThru')
	AADD(aAcessos,'Gera��o de Forecast')
	AADD(aAcessos,'Execu��o de Mashups')
	AADD(aAcessos,'Permite Exportar Planilha PMS para Excel')
	AADD(aAcessos,'Gravar Filtro do Browse com Empresa/Filial')
	AADD(aAcessos,'Exportar telas para Excel (Mod1 e 3)')
	AADD(aAcessos,'Se Administrador, pode utilizar o SIGACFG')
	AADD(aAcessos,'Se Administrador, pode utilizar o APSDU')
	AADD(aAcessos,'Se acessa APSDU, � Read-Write')
	AADD(aAcessos,'Acesso a inscri��o nos eventos do Eve')
	AADD(aAcessos,'MBrowse - Permite utiliza��o do localiza')
	AADD(aAcessos,'Visualiza��o via F3')
	AADD(aAcessos,'Excluir Purchase Order')
	AADD(aAcessos,'Alterar Purchase Order')
	AADD(aAcessos,'Excluir Solicita��o de Importa��o')
	AADD(aAcessos,'Alterar Solicita��o de Importa��o')
	AADD(aAcessos,'Excluir Desembara�o')
	AADD(aAcessos,'Alterar Desembara�o')
	AADD(aAcessos,'Incluir Agenda M�dica')
	AADD(aAcessos,'Alterar Agenda M�dica')
	AADD(aAcessos,'Excluir Agenda M�dica')
	AADD(aAcessos,'Acesso a F�rmulas')

                                                                                                                  
	//������������������������������������������������������������Ŀ
	//� Abre arquivo de trabalho para gravar os dados do relatorio �
	//��������������������������������������������������������������
	DbUseArea(.T.,"DBFCDX",cAceTrb,"TAC",.T.,.F.)
	DbUseArea(.T.,"DBFCDX",cRelTrb,"TRB",.T.,.F.)


	//���������������������������������������������������Ŀ
	//� Verifica se o relatorio ja existe gerado em disco �
	//�����������������������������������������������������	
	If File(cNomeRel)
		Delete File &(cNomeRel)
	Endif
	If File(cNomeRAc)
		Delete File &(cNomeRAc)
	Endif
	

	//���������������������������������������������������������Ŀ
	//� Obter lista de todos os menus utilizados pelos usuarios �
	//�����������������������������������������������������������
	IF MV_PAR01 == 1
		ProcRegua(Len(aUsuario))
		For x := 1 To Len(aUsuario)
			IncProc( "Analisando cadastro de usuarios" )
			aDados1 := aUsuario[x,1]
			aDados2 := aUsuario[x,2]
			aDados3 := aUsuario[x,3] // Menus
   	
			cCod		:= aDados1[1]
			cLogin	:= aDados1[2]
			cNome		:= AllTrim(aDados1[4])
			cDepto	:= AllTrim(aDados1[12])
			cCargo	:= AllTrim(aDados1[13])
			cEMail	:= AllTrim(aDados1[14])

         cAcessos := aUsuario[x,2,5]

			// Monta tabela de Acessos Por Usuario

			For s := 1 To Len(aAcessos)
				If SubStr(cAcessos,s,1) == 'S'
				   RecLock("TAC",.t.)
				   TAC->COD 	:= cCod
				   TAC->ACESSO := '|[S] '+Rtrim(aAcessos[s])
					TAC->LOGIN	:= cLogin
					TAC->NOME	:= RTrim(Capital(cNome))
					TAC->DEPTO	:= RTrim(Capital(cDepto))
					TAC->CARGO	:= RTrim(Capital(cCargo))
					TAC->EMAIL	:= RTrim(lower(cEMail))
				   TAC->(MsUnlock())
				Endif
			Next

			For s := 1 To Len(aDados3)
				cMenu	:= AllTrim(Capital(AllTrim(Substr(aDados3[s],4,Len(aDados3[s])))))
				lUsado	:= IIF(Substr(aDados3[s],3,1)=="X",.F.,.T.)
				If lUsado
					If File(cMenu)
						aAdd( aMenuAll,{ cMenu,cLogin,cNome,cDepto,cCargo,cEMail,cCod } )
					Endif
				Endif
			Next
		Next
	Elseif MV_PAR01 == 2
		For x := 1 To Len(aAdminXnu)
			aAdd( aMenuAll,{ "\SIGAADV\" + aAdminXnu[x] + ".XNU" ,"Administrador","Administrador","Tecnologia","","",'' } )
		Next
	Else
		aAdd( aMenuAll,{ UPPER(AllTrim(MV_PAR02)) ,"Menu","Menu","Configurador","","",'' } )
	Endif
	

	//�������������������������������������������Ŀ
	//� A funcao XNULoad ira retornar para o      �
	//� vetor aEstrutura 4 elementos referente a: �
	//� aEstrutura[1] = Atualizacoes              �
	//� aEstrutura[2] = Consultas                 �
	//� aEstrutura[3] = Relatorios                �
	//� aEstrutura[4] = Miscelaneas               �		
	//���������������������������������������������		
	ProcRegua(Len(aMenuAll))
    For z := 1 To Len(aMenuAll)
    
		IncProc( "Lendo " + Lower(AllTrim(aMenuAll[z,1])) )
		aEstrutura := XNULoad(aMenuAll[z,1])
	
		For a := 1 To Len(aEstrutura)
	
			If a == 1
				cTipo := "Atualizacoes"
			Elseif a == 2
				cTipo := "Consultas"
			Elseif a == 3
				cTipo := "Relatorios"
			Elseif a == 4
				cTipo := "Miscelaneas"
			Endif
		
			aParte    := aEstrutura[a]
			aGrupos   := aParte[3]
		
			For b := 1 To Len(aGrupos)
					
				If ValType(aGrupos[b][3]) == "A"
			
					aFuncoes  := aGrupos[b][3]
					cGrupo    := aGrupos[b][1][1]
			
					If ValType(aFuncoes) == "A"	
						For c := 1 To Len(aFuncoes)
							IF Len(aFuncoes[c]) >= 7
								aAlias		:= aFuncoes[c][4]
								cArquivo	:= ""
								aEval( aAlias,{ |h| cArquivo += h + " " },,)
								
								nModulo := aScan(aModulos,{|x| AllTrim(x[1]) == RTrim(aFuncoes[c][6])})
								If nModulo > 0
									cModulo := aModulos[nModulo,2]+' - '+aModulos[nModulo,3]
								Else                                                                 
									cModulo := RTrim(aFuncoes[c][6])
								Endif									
						
								DbSelectArea("TRB")
								RecLock("TRB",.T.)
									TRB->MENU	:= aMenuAll[z,1]
									TRB->DESCRI	:= RTrim(aFuncoes[c][1][1])
									TRB->MODO	:= aFuncoes[c][2]
									TRB->TIPO	:= cTipo
									TRB->FUNCAO	:= Upper(RTrim(aFuncoes[c][3]))
									TRB->ACS	:= Upper(aFuncoes[c][5])
									TRB->MODULO	:= cModulo
									TRB->ARQS	:= RTrim(cArquivo)
									TRB->GRUPO	:= RTrim(cGrupo)
									TRB->PESQ	:= Substr(Upper(aFuncoes[c][5]) ,1,1)
									TRB->VISU	:= Substr(Upper(aFuncoes[c][5]) ,2,1)						
									TRB->INCLUIR:= Substr(Upper(aFuncoes[c][5]) ,3,1)						
									TRB->ALTERAR:= Substr(Upper(aFuncoes[c][5]) ,4,1)
									TRB->EXCLUIR:= Substr(Upper(aFuncoes[c][5]) ,5,1)
									TRB->A6		:= Substr(Upper(aFuncoes[c][5]) ,6,1)												
									TRB->A7		:= Substr(Upper(aFuncoes[c][5]) ,7,1)
									TRB->A8		:= Substr(Upper(aFuncoes[c][5]) ,8,1)
									TRB->A9		:= Substr(Upper(aFuncoes[c][5]) ,9,1)
									TRB->A0		:= Substr(Upper(aFuncoes[c][5]) ,10,1)						
									TRB->LOGIN	:= RTrim(aMenuAll[z,2])
									TRB->NOME	:= RTrim(Capital(aMenuAll[z,3]))
									TRB->DEPTO	:= RTrim(Capital(aMenuAll[z,4]))
									TRB->CARGO	:= RTrim(Capital(aMenuAll[z,5]))
									TRB->EMAIL	:= RTrim(lower(aMenuAll[z,6]))
									TRB->COD	:= RTrim(aMenuAll[z,7])
								MsUnLock()								

							Endif
						Next
				    Endif
				Else
			    
					nModulo := aScan(aModulos,{|x| AllTrim(x[1]) == RTrim(aGrupos[b][6])})
					If nModulo > 0
						cModulo := aModulos[nModulo,2]+' - '+aModulos[nModulo,3]
					Else                                                                 
						cModulo := RTrim(aGrupos[b][6])
					Endif									

					DbSelectArea("TRB")
					RecLock("TRB",.T.)
						TRB->MENU	:= aMenuAll[z,1]
						TRB->DESCRI	:= RTrim(aGrupos[b][1][1])
						TRB->MODO	:= RTrim(aGrupos[b][2])
						TRB->TIPO	:= cTipo					
						TRB->FUNCAO	:= RTrim(Upper(RTrim(aGrupos[b][3])))
						TRB->ACS	:= RTrim(Upper(aGrupos[b][5]))
						TRB->MODULO	:= cModulo
						TRB->ARQS	:= RTrim(cArquivo)
						TRB->GRUPO	:= RTrim(cGrupo)
						TRB->PESQ	:= Substr(Upper(aGrupos[b][5]) ,1,1)
						TRB->VISU	:= Substr(Upper(aGrupos[b][5]) ,2,1)						
						TRB->INCLUIR:= Substr(Upper(aGrupos[b][5]) ,3,1)						
						TRB->ALTERAR:= Substr(Upper(aGrupos[b][5]) ,4,1)
						TRB->EXCLUIR:= Substr(Upper(aGrupos[b][5]) ,5,1)
						TRB->A6		:= Substr(Upper(aGrupos[b][5]) ,6,1)												
						TRB->A7		:= Substr(Upper(aGrupos[b][5]) ,7,1)
						TRB->A8		:= Substr(Upper(aGrupos[b][5]) ,8,1)
						TRB->A9		:= Substr(Upper(aGrupos[b][5]) ,9,1)
						TRB->A0		:= Substr(Upper(aGrupos[b][5]) ,10,1)
						TRB->LOGIN	:= RTrim(aMenuAll[z,2])
						TRB->NOME	:= RTrim(Capital(aMenuAll[z,3]))
						TRB->DEPTO	:= RTrim(Capital(aMenuAll[z,4]))
						TRB->CARGO	:= RTrim(Capital(aMenuAll[z,5]))
						TRB->EMAIL	:= RTrim(lower(aMenuAll[z,6]))
						TRB->COD	:= RTrim(aMenuAll[z,7])
 					   MsUnLock()
				Endif    
		
			Next	
	
		Next
	
	Next
	
	DbSelectArea("TRB")
	DbGoTop()
	Copy To &cNomeArq
	DbCloseArea()
		                
	DbSelectArea("TAC")
	DbGoTop()
	Copy To &cNomeAce
	DbCloseArea()

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ValidPerg �Autor  �Microsiga           � Data �  02/23/04   ���
�������������������������������������������������������������������������͹��
���Desc.     �Cria as perguntas do programa no dicionario de perguntas    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Static Function ValidPerg( cPerg )

	Local aArea := GetArea()
	Local aPerg:= {}

	aAdd(aPerg,{cPerg,"01","Analisar quais menus ?","mv_ch1","N",01,0,1,"C","","mv_par01","Todos","","","Padrao","","","Especifico","","","","","","","","  ",})
	aAdd(aPerg,{cPerg,"02","Menu espec�ico       ?","mv_ch2","C",40,0,0,"G","","mv_par02","","","","","","","","","","","","","","","",})

	DbSelectArea("SX1")	                                                
	For _nLaco:=1 to LEN(aPerg)                                   
		If !dbSeek(aPerg[_nLaco,1]+aPerg[_nLaco,2])
	    	RecLock("SX1",.T.)
				SX1->X1_Grupo     := aPerg[_nLaco,01]
				SX1->X1_Ordem     := aPerg[_nLaco,02]
				SX1->X1_Pergunt   := aPerg[_nLaco,03]
				SX1->X1_PerSpa    := aPerg[_nLaco,03]
				SX1->X1_PerEng    := aPerg[_nLaco,03]				
				SX1->X1_Variavl   := aPerg[_nLaco,04]
				SX1->X1_Tipo      := aPerg[_nLaco,05]
				SX1->X1_Tamanho   := aPerg[_nLaco,06]
				SX1->X1_Decimal   := aPerg[_nLaco,07]
				SX1->X1_Presel    := aPerg[_nLaco,08]
				SX1->X1_Gsc       := aPerg[_nLaco,09]
				SX1->X1_Valid     := aPerg[_nLaco,10]
				SX1->X1_Var01     := aPerg[_nLaco,11]
				SX1->X1_Def01     := aPerg[_nLaco,12]
				SX1->X1_Cnt01     := aPerg[_nLaco,13]
				SX1->X1_Var02     := aPerg[_nLaco,14]
				SX1->X1_Def02     := aPerg[_nLaco,15]
				SX1->X1_Cnt02     := aPerg[_nLaco,16]
				SX1->X1_Var03     := aPerg[_nLaco,17]
				SX1->X1_Def03     := aPerg[_nLaco,18]
				SX1->X1_Cnt03     := aPerg[_nLaco,19]
				SX1->X1_Var04     := aPerg[_nLaco,20]
				SX1->X1_Def04     := aPerg[_nLaco,21]
				SX1->X1_Cnt04     := aPerg[_nLaco,22]
				SX1->X1_Var05     := aPerg[_nLaco,23]
				SX1->X1_Def05     := aPerg[_nLaco,24]
				SX1->X1_Cnt05     := aPerg[_nLaco,25]
				SX1->X1_F3        := aPerg[_nLaco,26]
			MsUnLock()
		EndIf
	Next
	RestArea( aArea )

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
�������������������������������������������������������������������������͹��
���Desc.     � Retorna Array com Codigos e Nomes dos Modulos              ���
���          �                                                            ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Static Function fModulos()

Local aReturn

aReturn := {{"01","SIGAATF ","Ativo Fixo                       "},;
            {"02","SIGACOM ","Compras                           "},;
            {"03","SIGACON ","Contabilidade                     "},;
            {"04","SIGAEST ","Estoque/Custos                    "},;
            {"05","SIGAFAT ","Faturamento                       "},;
            {"06","SIGAFIN ","Financeiro                        "},;
            {"07","SIGAGPE ","Gestao de Pessoal                 "},;
            {"08","SIGAFAS ","Faturamento Servico               "},;
            {"09","SIGAFIS ","Livros Fiscais                    "},;
            {"10","SIGAPCP ","Planej.Contr.Producao             "},;
            {"11","SIGAVEI ","Veiculos                          "},;
            {"12","SIGALOJA","Controle de Lojas                 "},;
            {"13","SIGATMK ","Call Center                       "},;
            {"14","SIGAOFI ","Oficina                           "},;
            {"15","SIGARPM ","Gerador de Relatorios Beta1       "},;
            {"16","SIGAPON ","Ponto Eletronico                  "},;
            {"17","SIGAEIC ","Easy Import Control               "},;
            {"18","SIGAGRH ","Gestao de R.Humanos               "},;
            {"19","SIGAMNT ","Manutencao de Ativos              "},;
            {"20","SIGARSP ","Recrutamento e Selecao Pessoal    "},;
            {"21","SIGAQIE ","Inspecao de Entrada               "},;
            {"22","SIGAQMT ","Metrologia                        "},;
            {"23","SIGAFRT ","Front Loja                        "},;
            {"24","SIGAQDO ","Controle de Documentos            "},;
            {"25","SIGAQIP ","Inspecao de Projetos              "},;
            {"26","SIGATRM ","Treinamento                       "},;
            {"27","SIGAEIF ","Importacao - Financeiro           "},;
            {"28","SIGATEC ","Field Service                     "},;
            {"29","SIGAEEC ","Easy Export Control               "},;
            {"30","SIGAEFF ","Easy Financing                    "},;
            {"31","SIGAECO ","Easy Accounting                   "},;
            {"32","SIGAAFV ","Administracao de Forca de Vendas  "},;
            {"33","SIGAPLS ","Plano de Saude                    "},;
            {"34","SIGACTB ","Contabilidade Gerencial           "},;
            {"35","SIGAMDT ","Medicina e Seguranca no Trabalho  "},;
            {"36","SIGAQNC ","Controle de Nao-Conformidades     "},;
            {"37","SIGAQAD ","Controle de Auditoria             "},;
            {"38","SIGAQCP ","Controle Estatistico de Processos "},;
            {"39","SIGAOMS ","Gestao de Distribuicao            "},;
            {"40","SIGACSA ","Cargos e Salarios                 "},;
            {"41","SIGAPEC ","Auto Pecas                        "},;
            {"42","SIGAWMS ","Gestao de Armazenagem             "},;
            {"43","SIGATMS ","Gestao de Transporte              "},;
            {"44","SIGAPMS ","Gestao de Projetos                "},;
            {"45","SIGACDA ","Controle de Direitos Autorais     "},;
            {"46","SIGAACD ","Automacao Coleta de Dados         "},;
            {"47","SIGAPPAP","PPAP                              "},;
            {"48","SIGAREP ","Replica                           "},;
            {"49","SIGAGAC ","Gerenciamento Academico           "},;
            {"50","SIGAEDC ","Easy DrawBack Control             "},;
            {"97","SIGAESP ","Especificos                       "},;
            {"98","SIGAESP1","Especificos I                     "}}
               
Return(aReturn)