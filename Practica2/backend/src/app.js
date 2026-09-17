require('dotenv').config();
const express = require('express');
const sequelize = require('./config/database');
const authRoutes = require('./routes/authRoutes');
const userRoutes = require('./routes/userRoutes');

const app = express();

// Middleware para parsear JSON en el body de las peticiones
app.use(express.json());

// Ruta raíz de verificación (GET a la raíz, como menciona tu documento)
app.get('/', (req, res) => {
  res.json({ message: 'API funcionando correctamente' });
});

// Conectar las rutas de autenticación
app.use('/', authRoutes); // esto expone POST /register y POST /login
app.use('/', userRoutes); // esto expone GET /users, GET /users/:id, PUT /users/:id, DELETE /users/:id

const PORT = process.env.PORT || 5000;

sequelize.sync().then(() => {
  console.log('Base de datos sincronizada');
  app.listen(PORT, () => {
    console.log(`Servidor corriendo en puerto ${PORT}`);
  });
});