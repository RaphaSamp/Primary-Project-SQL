create database Pizzaria2;
use Pizzaria2;

create table cliente(
	id_cliente int auto_increment primary key,
    cliente_nome varchar(100) not null,
    telefone varchar(15) not null,
    email varchar(50)
);

create table endereco(
	id_endereco int auto_increment primary key,
    rua varchar(50) not null,
    numero varchar(10) not null,
    complemento varchar(100),
    bairro varchar(30) not null,
    cidade varchar(30) not null,
    id_cliente_fk int,
    foreign key(id_cliente_fk)
    references cliente(id_cliente)
);

create table pizza(
	id_pizza int auto_increment primary key,
    tamanho enum('Pequena','Media','Grande','Familia'),
    borda boolean,
    descricao_ingrediente text
);

create table sabores(
	id_sabores int auto_increment primary key,
    sabor varchar(50)
);

create table combinacao(
	id_combinacao int auto_increment primary key,
    id_sabores_fk int,
   foreign key(id_sabores_fk)
		references sabores(id_sabores),
	id_pizza_fk int,
    foreign key(id_pizza_fk)
		references pizza(id_pizza)
);

create table pagamentos(
	id_pagamento int auto_increment primary key,
    metodo enum('Dinheiro','Cartao','Pix') not null,
    status_pagamento enum('Pendente','Pago','Cancelado') not null,
    data_pagamento datetime
);

create table pedidos(
    id_pedidos int auto_increment primary key,
    id_cliente_fk int,
    foreign key(id_cliente_fk)
        references cliente(id_cliente),
    id_endereco_fk int,
    foreign key(id_endereco_fk)
        references endereco(id_endereco),
    id_pizza_fk int,
    foreign key(id_pizza_fk)
        references pizza(id_pizza),
    id_pagamento_fk int,
    foreign key(id_pagamento_fk)
        references pagamentos(id_pagamento),
    status_pedido enum('Em Preparação', 'A caminho', 'Entregue'),
    valor decimal(10,2) not null
);


-- ==========================
-- TRIGGER
-- ==========================

create table historico(
	id_historico int auto_increment primary key,
	id_cliente int,
    id_pedido int,
    id_pagamento_fk int,
    valor int
);

DELIMITER //

create trigger historico_cliente
after insert on pedidos
for each row
begin

	insert into historico(id_cliente, id_pedido, valor, id_pagamento_fk)
    values(new.id_cliente_fk, new.id_pedidos, new.valor, new.id_pagamento_fk);
end;
//
DELIMITER ;




-- ==================
-- VIEWS
-- ==================
-- a)
create view pedidos_clientes as
select c.cliente_nome, pa.data_pagamento, p.status_pedido, p.valor
from pedidos p
inner join pagamentos pa on pa.id_pagamento = p.id_pagamento_fk
inner join cliente c on c.id_cliente = p.id_cliente_fk;


-- b)
Create view sabores_mais_vendidos as
select
    s.sabor,
    COUNT(ped.id_pizza_fk) as total_vendas,
    SUM(ped.valor) as valor_total
from sabores s
left join combinacao c on s.id_sabores = c.id_sabores_fk
left join pedidos ped on c.id_pizza_fk = ped.id_pizza_fk
group by s.id_sabores, s.sabor
order by total_vendas desc;


-- c)
Create view pedidos_nao_entregue as
Select 
    p.id_pedidos,
    p.status_pedido,
    pg.data_pagamento
from pedidos p
inner join pagamentos pg on p.id_pagamento_fk = pg.id_pagamento
where p.status_pedido != 'Entregue';


-- d)
create view total_vendas_por_mes as
select 
    month(pg.data_pagamento) as mes,
    SUM(p.valor) as total_vendas
from pedidos p
inner join pagamentos pg on p.id_pagamento_fk = pg.id_pagamento
where pg.status_pagamento = 'Pago'
group by month(pg.data_pagamento)
order by mes asc;

-- =====================
-- PRCEDIMENTOS
-- =====================
-- a)
CREATE PROCEDURE ListarSaboresPedido(IN pedido_id INT)
BEGIN
    SELECT 
        p.tamanho,
        p.borda,
        s.sabor
    FROM pedidos pe
    JOIN pizza p ON pe.id_pizza_fk = p.id_pizza
    JOIN combinacao c ON p.id_pizza = c.id_pizza_fk
    JOIN sabores s ON c.id_sabores_fk = s.id_sabores
    WHERE pe.id_pedidos = pedido_id
END //

DELIMITER ;

call ListarSaboresPedido()

DELIMITER //

-- b)
CREATE PROCEDURE AtualizarStatusPedido(IN pedido_id INT, IN novo_status VARCHAR(20))
BEGIN
    UPDATE pedidos
    SET status_pedido = novo_status
    WHERE id_pedidos = pedido_id;
END //

DELIMITER ;


-- -------------------------------
-- 20 CLIENTES
-- -------------------------------
INSERT INTO cliente (cliente_nome, telefone, email) VALUES
('João Silva', '11999990001', 'joao@email.com'),
('Maria Souza', '11999990002', 'maria@email.com'),
('Carlos Lima', '11999990003', 'carlos@email.com'),
('Ana Pereira', '11999990004', 'ana@email.com'),
('Paulo Santos', '11999990005', 'paulo@email.com'),
('Fernanda Alves', '11999990006', 'fernanda@email.com'),
('Ricardo Gomes', '11999990007', 'ricardo@email.com'),
('Patricia Rocha', '11999990008', 'patricia@email.com'),
('Marcos Dias', '11999990009', 'marcos@email.com'),
('Juliana Costa', '11999990010', 'juliana@email.com'),
('Bruno Martins', '11999990011', 'bruno@email.com'),
('Carla Lima', '11999990012', 'carla@email.com'),
('Leandro Souza', '11999990013', 'leandro@email.com'),
('Sofia Ramos', '11999990014', 'sofia@email.com'),
('Felipe Nunes', '11999990015', 'felipe@email.com'),
('Aline Moreira', '11999990016', 'aline@email.com'),
('Gustavo Pinto', '11999990017', 'gustavo@email.com'),
('Renata Barros', '11999990018', 'renata@email.com'),
('Diego Castro', '11999990019', 'diego@email.com'),
('Camila Fernandes', '11999990020', 'camila@email.com');

-- -------------------------------
-- 20 ENDEREÇOS
-- -------------------------------
INSERT INTO endereco (rua, numero, complemento, bairro, cidade, id_cliente_fk) VALUES
('Rua A', '100', 'Apto 1', 'Centro', 'São Paulo', 1),
('Rua B', '200', NULL, 'Jardins', 'São Paulo', 2),
('Rua C', '300', 'Casa', 'Moema', 'São Paulo', 3),
('Rua D', '400', 'Apto 21', 'Vila Mariana', 'São Paulo', 4),
('Rua E', '500', NULL, 'Pinheiros', 'São Paulo', 5),
('Rua F', '600', 'Apto 5', 'Brooklin', 'São Paulo', 6),
('Rua G', '700', NULL, 'Liberdade', 'São Paulo', 7),
('Rua H', '800', 'Casa', 'Itaim', 'São Paulo', 8),
('Rua I', '900', NULL, 'Vila Olímpia', 'São Paulo', 9),
('Rua J', '1000', 'Apto 101', 'Mooca', 'São Paulo', 10),
('Rua K', '1100', NULL, 'Santana', 'São Paulo', 11),
('Rua L', '1200', 'Casa', 'Tatuapé', 'São Paulo', 12),
('Rua M', '1300', NULL, 'Perdizes', 'São Paulo', 13),
('Rua N', '1400', 'Apto 2', 'Vila Prudente', 'São Paulo', 14),
('Rua O', '1500', NULL, 'Butantã', 'São Paulo', 15),
('Rua P', '1600', 'Casa', 'Jabaquara', 'São Paulo', 16),
('Rua Q', '1700', NULL, 'Pinheiros', 'São Paulo', 17),
('Rua R', '1800', 'Apto 7', 'Moema', 'São Paulo', 18),
('Rua S', '1900', NULL, 'Vila Mariana', 'São Paulo', 19),
('Rua T', '2000', 'Casa', 'Jardins', 'São Paulo', 20);

-- -------------------------------
-- 20 PIZZAS
-- -------------------------------
INSERT INTO pizza (tamanho, borda, descricao_ingrediente) VALUES
('Pequena', FALSE, 'Mussarela, tomate, oregano'),
('Media', FALSE, 'Mussarela, tomate, oregano, calabresa'),
('Grande', TRUE, 'Mussarela, tomate, oregano, frango'),
('Familia', TRUE, 'Mussarela, tomate, oregano, bacon'),
('Pequena', TRUE, 'Mussarela, tomate, oregano, milho'),
('Media', TRUE, 'Mussarela, tomate, oregano, calabresa e cebola'),
('Grande', FALSE, 'Mussarela, tomate, oregano, frango e catupiry'),
('Familia', TRUE, 'Mussarela, tomate, oregano, presunto e ovos'),
('Pequena', FALSE, 'Mussarela, tomate, oregano, azeitona'),
('Media', FALSE, 'Mussarela, tomate, oregano, calabresa e bacon'),
('Grande', TRUE, 'Mussarela, tomate, oregano, frango e bacon'),
('Familia', TRUE, 'Mussarela, tomate, oregano, calabresa e catupiry'),
('Pequena', FALSE, 'Mussarela, tomate, oregano, palmito'),
('Media', TRUE, 'Mussarela, tomate, oregano, frango e milho'),
('Grande', TRUE, 'Mussarela, tomate, oregano, calabresa e catupiry'),
('Familia', TRUE, 'Mussarela, tomate, oregano, portuguesa'),
('Pequena', FALSE, 'Mussarela, tomate, oregano, marguerita'),
('Media', FALSE, 'Mussarela, tomate, oregano, frango e bacon'),
('Grande', TRUE, 'Mussarela, tomate, oregano, calabresa e milho'),
('Familia', TRUE, 'Mussarela, tomate, oregano, quatro queijos');

-- -------------------------------
-- 20 SABORES
-- -------------------------------
INSERT INTO sabores (sabor) VALUES
('Calabresa'), ('Mussarela'), ('Frango com Catupiry'), ('Portuguesa'), ('Marguerita'),
('Quatro Queijos'), ('Palmito'), ('Milho com Bacon'), ('Atum'), ('Brócolis com Bacon'),
('Napolitana'), ('Pepperoni'), ('Chocolate'), ('Banana com Canela'), ('Frango BBQ'),
('Carne Seca'), ('Bacon com Catupiry'), ('Tomate Seco'), ('Rúcula com Queijo'), ('Cogumelos');

-- -------------------------------
-- 20 COMBINAÇÕES
-- -------------------------------
INSERT INTO combinacao (id_sabores_fk, id_pizza_fk) VALUES
(1,1),(2,2),(3,3),(4,4),(5,5),(6,6),(7,7),(8,8),(9,9),(10,10),
(11,11),(12,12),(13,13),(14,14),(15,15),(16,16),(17,17),(18,18),(19,19),(20,20);

-- -------------------------------
-- 20 PAGAMENTOS
-- -------------------------------
INSERT INTO pagamentos (metodo, status_pagamento, data_pagamento) VALUES
('Dinheiro','Pago','2025-01-05 12:30:00'),
('Cartao','Pago','2025-01-10 13:00:00'),
('Pix','Pendente','2025-01-15 14:00:00'),
('Dinheiro','Pago','2025-02-05 15:30:00'),
('Cartao','Cancelado','2025-02-10 16:00:00'),
('Pix','Pago','2025-02-15 17:00:00'),
('Dinheiro','Pago','2025-03-05 12:45:00'),
('Cartao','Pago','2025-03-10 13:15:00'),
('Pix','Pendente','2025-03-15 14:30:00'),
('Dinheiro','Pago','2025-01-20 15:45:00'),
('Cartao','Pago','2025-01-25 16:15:00'),
('Pix','Pago','2025-02-20 17:45:00'),
('Dinheiro','Pago','2025-02-25 12:00:00'),
('Cartao','Cancelado','2025-03-20 13:30:00'),
('Pix','Pago','2025-03-25 14:00:00'),
('Dinheiro','Pago','2025-01-07 15:00:00'),
('Cartao','Pago','2025-02-07 16:30:00'),
('Pix','Pago','2025-03-07 17:00:00'),
('Dinheiro','Pago','2025-01-17 18:00:00'),
('Cartao','Pago','2025-02-17 19:00:00');

-- -------------------------------
-- 20 PEDIDOS
-- -------------------------------
INSERT INTO pedidos (id_cliente_fk, id_endereco_fk, id_pizza_fk, id_pagamento_fk, status_pedido, valor) VALUES
(1,1,1,1,'Entregue',25.00),
(2,2,2,2,'A caminho',35.00),
(3,3,3,3,'Em Preparação',45.00),
(4,4,4,4,'Entregue',55.00),
(5,5,5,5,'Entregue',28.00),
(6,6,6,6,'A caminho',38.00),
(7,7,7,7,'Em Preparação',48.00),
(8,8,8,8,'Entregue',58.00),
(9,9,9,9,'Entregue',30.00),
(10,10,10,10,'A caminho',40.00),
(11,11,11,11,'Em Preparação',50.00),
(12,12,12,12,'Entregue',60.00),
(13,13,13,13,'Entregue',33.00),
(14,14,14,14,'A caminho',43.00),
(15,15,15,15,'Em Preparação',53.00),
(16,16,16,16,'Entregue',63.00),
(17,17,17,17,'Entregue',36.00),
(18,18,18,18,'A caminho',46.00),
(19,19,19,19,'Em Preparação',56.00),
(20,20,20,20,'Entregue',66.00);


-- -------------------------------
-- Novos pagamentos para os pedidos adicionais
-- -------------------------------
INSERT INTO pagamentos (metodo, status_pagamento, data_pagamento) VALUES
('Dinheiro', 'Pago', '2025-03-28 12:00:00'),  -- id_pagamento = 21
('Cartao', 'Pago', '2025-03-28 13:00:00'),    -- id_pagamento = 22
('Pix', 'Pago', '2025-03-28 14:00:00');       -- id_pagamento = 23

-- -------------------------------
-- Novos pedidos para clientes repetidos
-- -------------------------------
INSERT INTO pedidos (id_cliente_fk, id_endereco_fk, id_pizza_fk, id_pagamento_fk, status_pedido, valor) VALUES
-- Cliente 1 comprando mais 2 pizzas
(1, 1, 2, 21, 'Entregue', 35.00),
(1, 1, 3, 22, 'Entregue', 45.00),

-- Cliente 2 comprando mais 1 pizza
(2, 2, 3, 23, 'Entregue', 45.00);
