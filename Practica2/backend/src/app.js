require('dotenv').config();
const express = require('express');
const bcrypt = require('bcryptjs');
const sequelize = require('./config/database');
const User = require('./models/user');
const authRoutes = require('./routes/authRoutes');
const userRoutes = require('./routes/userRoutes');

const app = express();

app.use(express.json());

app.get('/', (req, res) => {
  res.json({ message: 'API funcionando correctamente' });
});

app.use('/', authRoutes);
app.use('/', userRoutes);

const PORT = process.env.PORT || 5000;

async function seedAdmin() {
  const existingAdmin = await User.findOne({ where: { role: 'admin' } });
  if (!existingAdmin) {
    const password_hash = await bcrypt.hash(process.env.ADMIN_PASSWORD, 10);
    await User.create({
      username: 'admin',
      email: process.env.ADMIN_EMAIL,
      password_hash,
      role: 'admin'
    });
    console.log('Usuario admin creado por defecto');
  }
}

sequelize.sync().then(async () => {
  console.log('Base de datos sincronizada');
  await seedAdmin();
  app.listen(PORT, () => {
    console.log(`Servidor corriendo en puerto ${PORT}`);
  });
});