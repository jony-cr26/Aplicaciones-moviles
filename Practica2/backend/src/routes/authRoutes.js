const express = require('express');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const User = require('../models/user');

const router = express.Router();

// REGISTRO
router.post('/register', async (req, res) => {
  try {
    const { username, email, password } = req.body;

    // 1. Validar que vengan los campos obligatorios
    if (!username || !email || !password) {
      return res.status(400).json({ error: 'Faltan campos obligatorios' });
    }
                           
    // 2. Verificar si el email ya existe
    const existingUser = await User.findOne({ where: { email } });
    if (existingUser) {
      return res.status(400).json({ error: 'El email ya está registrado' });
    }

    // 3. Hashear la contraseña
    const password_hash = await bcrypt.hash(password, 10);

    // 4. Crear el usuario
    const newUser = await User.create({
      username,
      email,
      password_hash,
      role: 'user' 
    });

    // 5. Responder con los datos del usuario creado
    res.status(201).json({
      id: newUser.id,
      username: newUser.username,
      email: newUser.email,
      role: newUser.role
    });

  } catch (error) {
    res.status(500).json({ error: 'Error interno del servidor' });
  }
});

// LOGIN
  router.post('/login', async (req, res) => {
    try {
      const { email, password } = req.body;
      
      if (!email || !password) {
        return res.status(400).json({ error: 'Faltan campos obligatorios' });
      }

      const user = await User.findOne({ where: { email } });
      if (!user) {
        return res.status(401).json({ error: 'Credenciales inválidas' });
      }

      const isMatch = await bcrypt.compare(password, user.password_hash);
      if (!isMatch) {
        return res.status(401).json({ error: 'Credenciales inválidas' });
      }

      const token = jwt.sign(
        { id: user.id, role: user.role },
        process.env.JWT_SECRET,
        { expiresIn: '1h' }
      );

      res.status(200).json({ 
        token: token,
        role: user.role,
        id: user.id 
      });

    } catch (error) {
      res.status(500).json({ error: 'Error interno del servidor' });
    }
  });

  module.exports = router;