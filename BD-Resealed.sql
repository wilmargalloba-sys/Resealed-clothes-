create data base if not exists `bd-resealed` default character set utf8mb4 collate utf8mb4_general_ci;
use `bd-resealed`; 
CREATE TABLE categorias (
    id iNT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(255) NOT NULL unique ,
    descripcion TEXT 
    creado_en   TIMESTAMP DEFAULT CURRENT_TIMESTAMP
   );
CREATE TABLE tallas (
    id INT AUTO_INCREMENT PRIMARY KEY, 
    nombre VARCHAR(10)  NOT NULL UNIQUE,
    tipo  ENUM('calzado', 'ropa', 'unico') NOT NULL DEFAULT 'ropa'
);
 
CREATE TABLE usuarios (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(255) NOT NULL,
    apellido VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    telefono VARCHAR(20),
    ciudad varchar(50),
    rol ENUM('cliente', 'admin') NOT NULL DEFAULT 'cliente',
    estado ENUM('activo', 'inactivo', 'bloqueado') NOT NULL DEFAULT 'activo',
    contraseña VARCHAR(255) NOT NULL,
    creado_en TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
CREATE TABLE productos (
  id           INT AUTO_INCREMENT PRIMARY KEY,
  categoria_id INT NOT NULL,
  nombre       VARCHAR(200) NOT NULL,
  marca        VARCHAR(100) NOT NULL,
  referencia   VARCHAR(50)  NOT NULL UNIQUE,
  color        VARCHAR(80),
  precio       DECIMAL(12, 2) NOT NULL CHECK (precio >= 0),
  stock        INT NOT NULL DEFAULT 0 CHECK (stock >= 0),
  descripcion  TEXT,
  imagen_url   VARCHAR(500),
  estado       ENUM('disponible', 'agotado', 'descontinuado') NOT NULL DEFAULT 'disponible',
  creado_en    TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
 
  FOREIGN KEY (categoria_id) REFERENCES categorias(id)
    ON UPDATE CASCADE
    ON DELETE RESTRICT
);
CREATE TABLE producto_talla (
    id INT AUTO_INCREMENT PRIMARY KEY,
    producto_id INT NOT NULL,   
    talla_id INT NOT NULL,
    stock_tallas INT NOT NULL DEFAULT 0 CHECK (stock_tallas >= 0),

    UNIQUE KEY Uq_producto_talla (producto_id, talla_id),


    FOREIGN KEY (producto_id) REFERENCES productos(id)
    ON UPDATE CASCADE
    ON DELETE CASCADE,

    FOREIGN KEY (talla_id) REFERENCES tallas(id)
    ON UPDATE CASCADE
    ON DELETE RESTRICT
);
CREATE TABLE ventas (
    id INT AUTO_INCREMENT PRIMARY KEY,
    usuario_id INT NOT NULL,
    producto_id INT NOT NULL,
    talla_id INT NOT NULL,
    cantidad INT NOT NULL CHECK (cantidad > 0),
    total DECIMAL(12, 2) NOT NULL CHECK (total >= 0),
    fecha TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (usuario_id) REFERENCES usuarios(id)
    ON UPDATE CASCADE
    ON DELETE RESTRICT,

    FOREIGN KEY (producto_id) REFERENCES productos(id)
    ON UPDATE CASCADE
    ON DELETE RESTRICT,

    FOREIGN KEY (talla_id) REFERENCES tallas(id)
    ON UPDATE CASCADE
    ON DELETE RESTRICT
);
CREATE TABLE pedidos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    usuario_id INT NOT NULL,
    total DECIMAL ( 12, 3) NOT NULL DEFAULT 0 CHECK (total >= 0),
    estado ENUM('pendiente', 'procesando', 'enviado', 'entregado', 'cancelado') NOT NULL DEFAULT 'pendiente',
    fecha TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (usuario_id) REFERENCES usuarios(id)
    ON UPDATE CASCADE
    ON DELETE RESTRICT

);
CREATE TABLE detalle_pedidos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    pedido_id INT NOT NULL,
    producto_id INT NOT NULL,
    talla_id INT NOT NULL,
    cantidad INT NOT NULL CHECK (cantidad > 0),
    precio_unitario DECIMAL(12,2) NOT NULL CHECK (precio_unitario >= 0),
    subtotal DECIMAL(12,2) GENERATED ALWAYS AS (cantidad * precio_unitario) STORED,

    FOREIGN KEY (pedido_id) REFERENCES pedidos(id)
    ON UPDATE CASCADE 
    ON DELETE CASCADE,

    FOREIGN KEY (producto_id) REFERENCES productos(id)
    ON UPDATE CASCADE
    ON DELETE RESTRICT,

    FOREIGN KEY (talla_id) REFERENCES tallas(id)
    ON UPDATE CASCADE
    ON DELETE RESTRICT
);
CREATE TABLE facturas (
    id INT AUTO_INCREMENT PRIMARY KEY,
    pedido_id INT NOT NULL UNIQUE, 
    numero VARCHAR(50) NOT NULL UNIQUE,
    subtotal DECIMAL (12,2) NOT NULL CHECK (subtotal >= 0),
    impuestos DECIMAL (12,2) NOT NULL CHECK (impuestos >= 0),
    total DECIMAL (12,2) NOT NULL CHECK (total >= 0),
    fecha TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (pedido_id) REFERENCES pedidos(id)
    ON UPDATE CASCADE
    ON DELETE RESTRICT
);
CREATE TABLE metodos_pago (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL UNIQUE,
    metodo ENUM('tarjeta_credito', 'tarjeta_debito', 'paypal', 'transferencia_bancaria', 'efectivo') 
    NOT NULL DEFAULT 'tarjeta_credito',
    monto DECIMAL (12,2) NOT NULL CHECK (monto >= 0),
    fecha TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (factura_id) REFERENCES facturas(id)
    ON UPDATE CASCADE
    ON DELETE CASCADE

);
CREATE TABLE proveedores (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(255) NOT NULL UNIQUE,
    contacto VARCHAR(255),
    telefono VARCHAR(20),
    email VARCHAR(255) UNIQUE,
    ciudad varchar(50),
    creado_en TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO categorias (nombre, descripcion) VALUES 
('calzado', 'Tenis zaptillas y Sneakers' ),
('ropa', 'camisas, pantalones, chaquetas' ),
('accesorios', 'gorras, mochilas, cinturones y otros complementos' );

INSERT INTO tallas (nombre, tipo) VALUES
('35' , 'calzado'), ('36' , 'calzado'), ('37' , 'calzado'),
('38' , 'calzado'),('39' , 'calzado'),('40' , 'calzado'),
('41' , 'calzado'),('42' , 'calzado'),('43' , 'calzado'),
('XS' , 'ropa'),('S'  , 'ropa'),('M'  , 'ropa'),
('L'  , 'ropa'),('XL' , 'ropa'),('XXL', 'ropa'),
('unico', 'unico');

INSERT INTO usuarios (nombre, apellido, email, telefono, ciudad, rol) VALUES
  ('Ana',    'Pérez',  'ana@correo.com',    '3001111111', 'Medellín', 'cliente'),
  ('Carlos', 'Ruiz',   'carlos@correo.com', '3002222222', 'Bogotá',   'cliente'),
  ('Luisa',  'Gómez',  'luisa@correo.com',  '3003333333', 'Cali',     'cliente'),
  ('Admin',  'Release','admin@release.com', '3009999999', 'Medellín', 'admin');

INSERT INTO productos (categoria_id, nombre, marca, referencia, color, precio, stock, descripcion, estado) VALUES
  (1, 'Adidas Samba OG',    'Adidas', 'AD-SB-001', 'Blanco/Negro', 380000, 22, 'Clásico de Adidas en su versión OG.',       'disponible'),
  (1, 'Air Jordan Retro 4', 'Jordan', 'NI-J4-002', 'Negro/Rojo',   620000,  8, 'Silueta icónica de Jordan.',                'disponible'),
  (1, 'Forum 2000 BZRP',    'Adidas', 'AD-FR-003', 'Blanco/Azul',  450000,  0, 'Colaboración exclusiva con Bizarrap.',      'agotado'),
  (1, 'Air Jordan Retro 1', 'Jordan', 'NI-J1-004', 'Rojo/Negro',   550000, 15, 'El primer tenis de Michael Jordan con Nike.','disponible');  

INSERT INTO producto_talla (producto_id, talla_id, stock_talla) VALUES
  (1, 7, 5),   -- talla 41
  (1, 8, 10),  -- talla 42
  (1, 9, 7);   -- talla 43

INSERT INTO producto_talla (producto_id, talla_id, stock_talla) VALUES
  (2, 7, 3),   -- talla 41
  (2, 8, 5);   -- talla 42

INSERT INTO pedidos (usuario_id, total, estado) VALUES (1, 380000, 'en_proceso');
INSERT INTO detalle_pedido (pedido_id, producto_id, talla_id, cantidad, precio_unit) VALUES (1, 1, 8, 1, 380000);
INSERT INTO facturas (pedido_id, numero, subtotal, iva, total) VALUES (1, 'FAC-001', 319328, 60672, 380000);
INSERT INTO metodos_pago (factura_id, metodo, monto) VALUES (1, 'nequi', 380000);
  