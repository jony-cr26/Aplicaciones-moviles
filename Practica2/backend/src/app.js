require('dotenv').config();
const express = require('express');
const sequelize = require('./config/database');
const authRoutes = require('./routes/authRoutes');

const app = express();

// Middleware para parsear JSON en el body de las peticiones
app.use(express.json());

// Ruta raíz de verificación (GET a la raíz, como menciona tu documento)
app.get('/', (req, res) => {
  res.json({ message: 'API funcionando correctamente' });
});

// Conectar las rutas de autenticación
app.use('/', authRoutes); // esto expone POST /register y POST /login

const PORT = process.env.PORT || 5000;

sequelize.sync().then(() => {
  console.log('Base de datos sincronizada');
  app.listen(PORT, () => {
    console.log(`Servidor corriendo en puerto ${PORT}`);
  });
});