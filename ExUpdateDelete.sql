use nome;

create table usuarios (
    id int auto_increment primary key,
    nome varchar(100),
    email varchar(100) unique not null
);

create table movimentacoes (
    id int auto_increment primary key,
    usuario_id int,
    tipo enum('Entrada', 'Saida'),
    descricao varchar(100),
    valor dec(10, 2),
    data_movimentacao datetime,
    foreign key (usuario_id) references usuarios(id)
);

insert into usuarios (nome, email) values
('Lucas Silva', 'lucas.silva@email.com'),
('Mariana Rocha', 'mariana.rocha@email.com');

insert into movimentacoes (usuario_id, tipo, descricao, valor, data_movimentacao) values
(1, 'Entrada', 'Salário mensal', 2850.00, '2026-11-05 08:30:00'),
(1, 'Saida', 'Mercado', 184.75, '2026-11-08 19:15:00'),
(1, 'Saida', 'Farmácia', 52.30, '2026-11-12 14:40:00'),
(2, 'Entrada', 'Freelance design', 640.50, '2026-11-14 11:00:00');

-- exercício 1: carga inicial de dados para testes
-- demanda: precisamos popular a base de homologação com pelo menos 2 usuários e 4 movimentações financeiras
-- detalhe: misture entradas e saídas, inclua valores com centavos e datas variadas para simular cenários reais

insert into usuarios (nome, email) values
('Beatriz', 'bia@gmail.com'),
('Pedro', 'pedro@gmail.com');

insert into movimentacoes (usuario_id, tipo, descricao, valor, data_movimentacao) values
(3, 'Entrada', 'Bonus empresa', 300.00, '2026-09-02 18:53:00'),
(2, 'Saida', 'Compras', 450.30, '2026-11-19 10:10:00'),
(3, 'Saida', 'Internet', 60.56, '2026-11-20 10:20:00'),
(4, 'Entrada', 'Salario', 2000.00, '2026-11-12 20:12:00');

-- exercício 2: correção cadastral de lançamento
-- demanda: o suporte recebeu um chamado pedindo para ajustar a descrição
-- da movimentação de id = 2 de 'Mercado' para 'Supermercado do Bairro'
-- detalhe: aplique a alteração apenas nesse registro usando o filtro adequado

start transaction;

update movimentacoes
set descricao = 'Supermercado do Bairro'
where id = 2;

select * from movimentacoes;

commit;

-- exercício 3: ajuste de valor em lançamento existente
-- demanda: foi identificado que o lançamento de id = 3 ficou com o valor abaixo do correto em 15.50
-- detalhe: atualize o campo valor somando 15.50 ao valor que já está gravado no registro

update movimentacoes
set valor = valor + 15.50
where id = 3
limit 1;

select * from movimentacoes;

-- exercício 4: saneamento de movimentações antigas por lote
-- demanda: a equipe financeira pediu para marcar com o prefixo
-- '[revisado] ' as descrições das saídas do usuario_id = 1 anteriores a '2026-11-10 00:00:00'
-- detalhe: valide primeiro com um select usando os mesmos critérios antes de rodar o update

start transaction;
select * from movimentacoes
where usuario_id = 1;

update movimentacoes
set descricao = concat('[revisado] ', descricao)
where usuario_id = 1
  and tipo = 'Saida'
  and data_movimentacao < '2026-11-10 00:00:00';
  
commit;

-- exercício 5: alteração segura com controle de transação
-- demanda: antes de aplicar um ajuste em produção, precisamos validar o comportamento de uma alteração em uma movimentação de teste
-- detalhe: abra uma transação, altere o valor, confira com select, teste desfazer com rollback e depois repita o processo confirmando com commit

start transaction;
select * from movimentacoes;

update movimentacoes
set valor = 3000.20
where id = 1
limit 1;

select * from movimentacoes;

rollback;

commit;

-- exercício 6: exclusão pontual de registro indevido
-- demanda: foi solicitado remover o lançamento de id = 4 que entrou por engano no sistema
-- detalhe: confira o registro antes com um select e só então remova filtrando pelo id

select * from movimentacoes;

start transaction;

delete from movimentacoes
where id = 4;

commit;

-- exercício 7: validação de regra de integridade referencial
-- demanda: precisamos garantir que o banco impeça a exclusão de usuários que já possuem movimentações financeiras vinculadas
-- detalhe: tente excluir o usuario de id = 1, analise o bloqueio retornado pelo banco e registre sua conclusão sobre como o sistema deve tratar esse cenário

select * from movimentacoes
where id = 1;

start transaction;

delete from usuarios
where id = 1;

rollback;