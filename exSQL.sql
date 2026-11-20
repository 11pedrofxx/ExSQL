use treino;

create table clientes (
id int auto_increment primary key,
nome varchar(30),
cidade varchar(30)
);

create table produtos (
id int auto_increment primary key,
descricao varchar (300),
preco dec(10,2),
estoque int 
);

create table pedidos (
id int auto_increment primary key, 
cliente_id int,
data_pedido datetime,
valor_total dec(10,2),
foreign key (cliente_id) references clientes(id)
);

create table itens_pedido (
    id int auto_increment primary key,
    pedido_id int,
    produto_id int,
    quantidade int,
    preco_unitario dec(10, 2),
    foreign key (pedido_id) references pedidos(id),
    foreign key (produto_id) references produtos(id)
);

USE treino;

-- 1. Inserindo Clientes
INSERT INTO clientes (nome, cidade) VALUES 
('Ana Souza', 'São Paulo'),
('Carlos Lima', 'Campinas'),
('Mariana Costa', 'São Paulo'),
('Roberto Alves', 'Santos'),
('Fernanda Dias', 'Guarulhos'); -- Note que a Fernanda não fará nenhum pedido (bom para testar LEFT JOIN!)

-- 2. Inserindo Produtos
INSERT INTO produtos (descricao, preco, estoque) VALUES 
('Armação Ray-Ban Classic', 450.00, 15),
('Lente Antirreflexo Premium', 320.00, 8),
('Óculos de Sol Polarizado', 280.00, 20),
('Kit Limpeza de Lentes', 35.00, 50),
('Lente Multifocal Digital', 890.00, 3); -- Estoque baixo!

-- 3. Inserindo Pedidos (ligados aos IDs dos clientes 1 a 4)
INSERT INTO pedidos (cliente_id, data_pedido, valor_total) VALUES 
(1, '2026-11-10 10:30:00', 770.00),  -- Pedido 1 (Ana)
(2, '2026-11-12 14:15:00', 280.00),  -- Pedido 2 (Carlos)
(1, '2026-11-15 16:45:00', 925.00),  -- Pedido 3 (Ana comprou de novo!)
(3, '2026-11-18 09:20:00', 485.00);  -- Pedido 4 (Mariana)

-- 4. Inserindo Itens dos Pedidos (ligando pedidos e produtos)
INSERT INTO itens_pedido (pedido_id, produto_id, quantidade, preco_unitario) VALUES 
(1, 1, 1, 450.00), -- Pedido 1: 1 Armação Ray-Ban
(1, 2, 1, 320.00), -- Pedido 1: 1 Lente Antirreflexo
(2, 3, 1, 280.00), -- Pedido 2: 1 Óculos de Sol
(3, 5, 1, 890.00), -- Pedido 3: 1 Lente Multifocal
(3, 4, 1, 35.00),  -- Pedido 3: 1 Kit Limpeza
(4, 1, 1, 450.00), -- Pedido 4: 1 Armação Ray-Ban
(4, 4, 1, 35.00);  -- Pedido 4: 1 Kit Limpeza

-- ex 1 -- 

select produtos.descricao, produtos.estoque from produtos
where produtos.estoque <10 order by estoque asc;

-- ex 2 -- 

select pedidos.id, clientes.nome, clientes.cidade, pedidos.valor_total from clientes
	inner join pedidos
    on clientes.id = pedidos.cliente_id;
    
    -- ex 3 -- 
SELECT clientes.nome, pedidos.id
FROM clientes
LEFT JOIN pedidos ON clientes.id = pedidos.cliente_id;


-- ex 4 -- 

select 
	pedidos.id,
    produtos.descricao,
    itens_pedido.quantidade,
    itens_pedido.preco_unitario from pedidos
    inner join itens_pedido
    on pedidos.id = itens_pedido.pedido_id
    inner join produtos
    on itens_pedido.produto_id = produtos.id
where pedidos.id = 1;

-- ex 5 -- 

select clientes.nome, SUM(pedidos.valor_total) as valor_pedidos from clientes
	inner join pedidos
    on clientes.id = pedidos.cliente_id
    group by clientes.id, clientes.nome
    order by valor_pedidos desc;
    
    start transaction;
    
update produtos 
set preco = preco * 1.10
where preco < 100;

select * from produtos;

COMMIT;



rollback;

-- ex 1: Busca por termo (LIKE + %)
-- Liste id, descricao e preco dos produtos que contenham a palavra "Lente" na descricao.

select produtos.id, produtos.descricao, produtos.preco from produtos
where descricao like "%Lente%";


-- ex 2: Faixa de preço (BETWEEN e ORDER BY DESC)
-- Liste descricao e preco dos produtos com preco entre 250.00 e 500.00, do maior para o menor preco.

select descricao, preco from produtos
where preco between 250 and 500 order by preco desc;

-- ex 3: Filtro por lista (IN e ORDER BY ASC)
-- Liste nome e cidade dos clientes de 'São Paulo' ou 'Campinas', em ordem alfabetica pelo nome.

select clientes.nome, clientes.cidade from clientes
	where clientes.cidade in ('São Paulo', 'Campinas')
	order by nome asc;

-- ex 4: Top 2 mais caros (ORDER BY + LIMIT)
-- Mostre apenas os 2 produtos mais caros (descricao e preco).

select * from produtos
	order by preco asc
    limit 2;

-- ex 5: Coluna calculada (expressao matematica + alias)
-- Mostre descricao, estoque, preco e uma coluna calculada valor_estoque (preco * estoque).

select produtos.descricao,
		produtos.estoque,
        produtos.preco,
        (produtos.preco * produtos.estoque) as valor_estoque
        from produtos;

-- ex 6: Pedidos por data (INNER JOIN + WHERE em data)
-- Liste id do pedido, nome do cliente e data_pedido dos pedidos a partir de '2026-11-12'.

select pedidos.id, clientes.nome, pedidos.data_pedido from clientes
	inner join pedidos
    on clientes.id = pedidos.cliente_id
where data_pedido >= '2026-11-12';

-- ex 7: Primeiro LEFT JOIN (bem tranquilo para pegar a pratica)
-- Liste o nome de TODOS os clientes e o id do pedido (se tiver).
-- Dica: coloque clientes no FROM e use LEFT JOIN pedidos ON clientes.id = pedidos.cliente_id.

select clientes.nome, pedidos.id from clientes
	left join pedidos
    on clientes.id = pedidos.cliente_id;

-- ex 8: Filtro apos JOIN (INNER JOIN + WHERE)
-- Liste nome do cliente, id do pedido e valor_total apenas de clientes de 'São Paulo' que tenham pedido.

select clientes.nome, clientes.cidade, pedidos.id, pedidos.valor_total from clientes
	inner join pedidos
    on clientes.id = pedidos.cliente_id
    where clientes.cidade = 'São Paulo';

-- ex 9: Multiplos JOINs (4 tabelas ligadas)
-- Liste nome do cliente, id do pedido, descricao do produto, quantidade e subtotal (quantidade * preco_unitario).

select  clientes.nome,
		pedidos.id,
        produtos.descricao,
        itens_pedido.quantidade,
        (itens_pedido.quantidade * itens_pedido.preco_unitario) as subtotal from clientes
inner join pedidos
on clientes.id = pedidos.cliente_id
inner join itens_pedido
on pedidos.id = itens_pedido.pedido_id
inner join produtos
on itens_pedido.produto_id = produtos.id;

-- ex 10: Soma por pedido (INNER JOIN + GROUP BY + SUM)
-- Mostre o id do pedido e o total de unidades compradas (SUM(itens_pedido.quantidade)) em cada pedido.

select pedidos.id, sum(itens_pedido.quantidade) as unidades_compradas from pedidos
	inner join itens_pedido
	on pedidos.id = itens_pedido.pedido_id
    group by pedidos.id;


-- ex 11: Media por cliente (INNER JOIN + GROUP BY + AVG)
-- Calcule a media (AVG) do valor_total dos pedidos por cliente, exibindo nome e media.

select clientes.nome, round(avg(pedidos.valor_total)) as media from clientes
	inner join pedidos
    on clientes.id = pedidos.cliente_id
    group by clientes.nome;

-- ex 12: Filtro em grupo (GROUP BY + HAVING + COUNT)
-- Liste nome do cliente e quantidade de pedidos (COUNT) apenas de quem tem mais de 1 pedido.

select clientes.nome, count(pedidos.id) as total_pedidos from clientes 
inner join pedidos
    on clientes.id = pedidos.cliente_id
    group by clientes.nome
    having total_pedidos > 1;

-- ex 13: Produtos mais vendidos (JOIN + GROUP BY + SUM + ORDER BY DESC)
-- Liste descricao do produto e total de unidades vendidas (SUM(quantidade)), do maior para o menor.

select produtos.descricao, sum(itens_pedido.quantidade) as unidades_vendidas from produtos
	inner join itens_pedido
    on produtos.id = itens_pedido.produto_id
    group by produtos.descricao
    order by produtos.descricao asc;

-- ex 14: Transacao com UPDATE (START TRANSACTION + SELECT + COMMIT/ROLLBACK)
-- Abra uma transacao, some +10 no estoque do produto id = 5, confira com SELECT e finalize com ROLLBACK ou COMMIT.

start transaction;

update produtos
set estoque = estoque + 10
where id = 5;

select * from produtos;

commit;

-- ex 15: DELETE seguro (SELECT de conferencia antes do DELETE)
-- Consulte com SELECT um item específico de itens_pedido pelo id
-- e depois remova esse registro usando o mesmo id no WHERE.

start transaction;

select * from itens_pedido
where id = 2;

delete from itens_pedido
where id = 2;

rollback;