# EcommerceU3

Banco de dados relacional desenvolvido em SQL Server para um sistema de pedidos online.

## Conteúdo
- Criação do banco de dados `EcommerceU3`
- Tabelas:
  - Cliente
  - Produto
  - Pedido
  - ItemPedido
- View `vw_PedidosDetalhados` para exibir pedidos com informações completas
- Função escalar `fn_AplicaDesconto` para cálculo de valor com desconto
- Transação demonstrando registro de pedido e itens (COMMIT / ROLLBACK)
- Consultas de análise de vendas (produtos mais vendidos, faturamento total, etc.)

## Como usar
1. Abra o arquivo `.sql` no SQL Server Management Studio.
2. Execute o script para criar o banco e as tabelas.
3. Execute os inserts de exemplo.
4. Rode as consultas conforme desejado.

## Tecnologias
- SQL Server
- T-SQL
