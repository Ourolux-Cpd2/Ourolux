/*

  Esta função tem por finalidade retornar o nome reduzido cliente/fornecedor para o browse pedido vendas

*/

User Function RetBrowCli()

If SC5->C5_TIPO <> 'D'

   _cNome := RetField('SA1',1,'  '+SC5->C5_CLIENTE+SC5->C5_LOJACLI,'SA1->A1_NREDUZ')

Else

   _cNome := RetField('SA2',1,'  '+SC5->C5_CLIENTE+SC5->C5_LOJACLI,'SA2->A2_NREDUZ')

End

Return( _cNome )