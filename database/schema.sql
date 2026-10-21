CREATE TABLE usuarios (
  id SERIAL PRIMARY KEY,
  nombre VARCHAR(100) NOT NULL,
  email VARCHAR(150) NOT NULL UNIQUE,
  password_hash VARCHAR(255) NOT NULL,
  rol VARCHAR(20) NOT NULL CHECK (rol IN ('cliente', 'admin')),
  creado_en TIMESTAMP DEFAULT NOW()
);

CREATE TABLE negocios (
  id SERIAL PRIMARY KEY,
  duenio_id INTEGER NOT NULL REFERENCES usuarios(id),
  nombre VARCHAR(150) NOT NULL,
  direccion VARCHAR(255),
  telefono VARCHAR(30)
);

CREATE TABLE servicios (
  id SERIAL PRIMARY KEY,
  negocio_id INTEGER NOT NULL REFERENCES negocios(id) ON DELETE CASCADE,
  nombre VARCHAR(100) NOT NULL,
  duracion_min INTEGER NOT NULL CHECK (duracion_min > 0),
  precio NUMERIC(10,2) NOT NULL CHECK (precio >= 0),
  activo BOOLEAN DEFAULT TRUE
);

CREATE TABLE horarios_atencion (
  id SERIAL PRIMARY KEY,
  negocio_id INTEGER NOT NULL REFERENCES negocios(id) ON DELETE CASCADE,
  dia_semana SMALLINT NOT NULL CHECK (dia_semana BETWEEN 0 AND 6),
  hora_apertura TIME NOT NULL,
  hora_cierre TIME NOT NULL,
  CHECK (hora_cierre > hora_apertura)
);

CREATE TABLE turnos (
  id SERIAL PRIMARY KEY,
  cliente_id INTEGER NOT NULL REFERENCES usuarios(id),
  servicio_id INTEGER NOT NULL REFERENCES servicios(id),
  inicio TIMESTAMP NOT NULL,
  fin TIMESTAMP NOT NULL,
  estado VARCHAR(20) NOT NULL DEFAULT 'pendiente'
    CHECK (estado IN ('pendiente', 'confirmado', 'cancelado')),
  creado_en TIMESTAMP DEFAULT NOW(),
  CHECK (fin > inicio)
);

CREATE INDEX idx_turnos_servicio_inicio ON turnos (servicio_id, inicio);

CREATE TABLE pagos (
  id SERIAL PRIMARY KEY,
  turno_id INTEGER NOT NULL UNIQUE REFERENCES turnos(id) ON DELETE CASCADE,
  monto NUMERIC(10,2) NOT NULL CHECK (monto >= 0),
  estado VARCHAR(20) NOT NULL DEFAULT 'pendiente'
    CHECK (estado IN ('pendiente', 'aprobado', 'rechazado')),
  mp_operacion_id VARCHAR(100),
  creado_en TIMESTAMP DEFAULT NOW()
);