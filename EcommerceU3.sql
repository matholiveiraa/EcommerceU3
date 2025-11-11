create database EcommerceU3;  -- cria o banco EcommerceU3
use EcommerceU3;               -- seleciona ele para usar

create table cliente
(
    idcliente int identity primary key not null,  -- id do cliente, auto increment, chave primária
    nome varchar(50) not null,                    -- nome do cliente, obrigatório
    email varchar(70) not null                    -- email do cliente, obrigatório
);

create table produto
(
    idproduto int identity primary key not null,  -- id do produto, auto increment, chave primária
    nome varchar(50) not null,                    -- nome do produto, obrigatório
    preco money not null                          -- preço do produto, obrigatório
);

create table pedido
(
    idpedido int identity primary key not null,   -- id do pedido, auto increment, chave primária
    idcliente int not null references cliente(idcliente), -- FK para saber qual cliente fez o pedido
    datapedido date not null,                     -- data do pedido
    status varchar(30) not null                   -- status do pedido (ex: concluído, em andamento)
);

create table itempedido
(
    iditem int identity primary key not null,     -- id do item do pedido
    idpedido int not null references pedido(idpedido), -- FK do pedido
    idproduto int not null references produto(idproduto), -- FK do produto
    precounit money not null,                     -- preço unitário do produto na venda
    quantidade int not null default 1            -- quantidade comprada, padrão 1
);

insert into cliente (nome, email)
values 
('Matheus Alves Oliveira', 'alvesmatheus2005.ma@gmail.com'),
('Isabela Dias Oliveira', 'isadiasoli375@gmail.com'),
('Joel Lira', 'joellira@gmail.com'),
('Janaina Silva' , 'janasilva@gmail.com'),
('Nathan Castelo', 'natcastelo@gmail.com');

insert into produto (nome, preco)
values
('Computador Gamer', 3699),
('Monitor', 799),
('Mouse', 250),
('Teclado', 150),
('Gabinete', 299);

insert into pedido (idcliente, datapedido, status)
values 
(1 , '2025/07/16', 'aguardando pagamento'),  -- pedido do Matheus
(2 , '2025/09/17', 'concluido'),             -- pedido da Isabela
(3 , '2025/10/20', 'concluido');             -- pedido do Joel

insert into itempedido (idpedido, idproduto, precounit, quantidade)
values
(1 , 1 , 3699, 1),   -- Matheus comprou 1 Computador Gamer
(2, 2, 799, 1),      -- Isabela comprou 1 Monitor
(2, 3, 250, 1),      -- Isabela comprou 1 Mouse
(3, 5 , 299, 1);     -- Joel comprou 1 Gabinete

create function fn_AplicaDesconto(@valor DECIMAL(18,2), @percent INT)
returns money
as 
begin 
    return @valor * (@percent / 100.0)  -- divide por 100.0 para ter decimal, retorna só o desconto
end;

create function fn_AplicaDescontohalf(@valor DECIMAL(18,2), @percent INT)
returns money
as 
begin
    return @valor - dbo.fn_AplicaDesconto(@valor, @percent) -- valor total menos desconto
end;

create view vw_PedidosDetalhados as
select
    c.nome as nomecliente,                                -- pega o nome do cliente
    p.datapedido as datapedido,                           -- pega a data do pedido
    pr.nome as nomeproduto,                               -- pega o nome do produto
    i.quantidade,                                        -- pega a quantidade comprada
    i.precounit,                                         -- pega o preço unitário
    i.precounit * i.quantidade as valortotal,           -- calcula preço total do item (preço * quantidade)
    dbo.fn_AplicaDescontohalf(i.precounit * i.quantidade, 10) as valortotalComDesconto, -- aplica 10% de desconto
    p.status                                             -- status do pedido
from itempedido i
join pedido p on i.idpedido = p.idpedido                -- junta itempedido com pedido
join cliente c on p.idcliente = c.idcliente            -- junta pedido com cliente
join produto pr on i.idproduto = pr.idproduto;         -- junta itempedido com produto

select * from vw_PedidosDetalhados;

BEGIN TRAN;  

DECLARE @newPedidoId INT;

INSERT INTO pedido (idcliente, datapedido, status)
VALUES (1, GETDATE(), 'Em andamento...');

SET @newPedidoId = SCOPE_IDENTITY();

INSERT INTO itempedido (idpedido, idproduto, precounit, quantidade)
VALUES 
(@newPedidoId, 2, 799, 1),
(@newPedidoId, 1, 3699, 1);

SELECT * FROM pedido WHERE idpedido = @newPedidoId;
SELECT * FROM itempedido WHERE idpedido = @newPedidoId;



COMMIT;
rollback;

BEGIN TRAN;

-- insere o pedido
INSERT INTO pedido (idcliente, datapedido, status)
VALUES (1, GETDATE(), 'Em andamento...');

-- insere os itens
DECLARE @newPedidoId INT;
SET @newPedidoId = SCOPE_IDENTITY();

INSERT INTO itempedido (idpedido, idproduto, precounit, quantidade)
VALUES 
(@newPedidoId, 2, 799, 1),
(@newPedidoId, 1, 3699, 1);

-- vê os dados antes de desfazer
SELECT * FROM pedido WHERE idpedido = @newPedidoId;
SELECT * FROM itempedido WHERE idpedido = @newPedidoId;

-- desfaz tudo
ROLLBACK;

-- vê os dados depois do rollback 
SELECT * FROM pedido WHERE idpedido = @newPedidoId;
SELECT * FROM itempedido WHERE idpedido = @newPedidoId;


-- total por cliente com desconto de 10%
SELECT
    nomecliente,
    SUM(valortotalComDesconto) AS TotalCom10Desconto
FROM vw_PedidosDetalhados
GROUP BY nomecliente
ORDER BY TotalCom10Desconto DESC;

-- faturamento total (sem desconto)
SELECT SUM(valortotal) AS TotalFaturamento
FROM vw_PedidosDetalhados;

-- produtos mais vendidos
SELECT 
    nomeproduto,
    SUM(quantidade) AS QuantidadeVendida
FROM vw_PedidosDetalhados
GROUP BY nomeproduto
ORDER BY QuantidadeVendida DESC;

