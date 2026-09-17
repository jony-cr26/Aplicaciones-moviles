const express = require('express');
const bcrypt = require('bcryptjs');
const User = require('../models/user');
const { verifyToken, requireAdmin } = require('../middleware/auth');

const router = express.Router();

// READ - listar todos los usuarios (solo admin)
router.get('/users', verifyToken, requireAdmin, async (req, res) => {
  try {
    const users = await User.findAll({
      attributes: { exclude: ['password_hash'] }
    });
    res.status(200).json(users);
  } catch (error) {
    res.status(500).json({ error: 'Error interno del servidor' });
  }
});

// READ - obtener un usuario (dueño o admin)
router.get('/users/:id', verifyToken, async (req, res) => {
  try {
    const isOwner = req.user.id === parseInt(req.params.id);
    const isAdmin = req.user.role === 'admin';

    if (!isOwner && !isAdmin) {
      return res.status(403).json({ error: 'No tienes permiso sobre este recurso' });
    }

    const user = await User.findByPk(req.params.id, {
      attributes: { exclude: ['password_hash'] }
    });

    if (!user) {
      return res.status(404).json({ error: 'Usuario no encontrado' });
    }

    res.status(200).json(user);
  } catch (error) {
    res.status(500).json({ error: 'Error interno del servidor' });
  }
});

// UPDATE - actualizar datos del usuario (dueño o admin)
router.put('/users/:id', verifyToken, async (req, res) => {
  try {
    const isOwner = req.user.id === parseInt(req.params.id);
    const isAdmin = req.user.role === 'admin';

    if (!isOwner && !isAdmin) {
      return res.status(403).json({ error: 'No tienes permiso sobre este recurso' });
    }

    const user = await User.findByPk(req.params.id);
    if (!user) {
      return res.status(404).json({ error: 'Usuario no encontrado' });
    }

    const { username, email, password, role } = req.body;
    const updates = {};

    if (username) updates.username = username;
    if (email) updates.email = email;
    if (password) {
      updates.password_hash = await bcrypt.hash(password, 10);
    }

    // Solo un admin puede cambiar el rol de un usuario
    if (role && isAdmin) {
      updates.role = role;
    }

    await user.update(updates);

    res.status(200).json({
      id: user.id,
      username: user.username,
      email: user.email,
      role: user.role
    });
  } catch (error) {
    res.status(500).json({ error: 'Error interno del servidor' });
  }
});

// DELETE - eliminar cuenta (dueño o admin)
router.delete('/users/:id', verifyToken, async (req, res) => {
  try {
    const isOwner = req.user.id === parseInt(req.params.id);
    const isAdmin = req.user.role === 'admin';

    if (!isOwner && !isAdmin) {
      return res.status(403).json({ error: 'No tienes permiso sobre este recurso' });
    }

    const user = await User.findByPk(req.params.id);
    if (!user) {
      return res.status(404).json({ error: 'Usuario no encontrado' });
    }

    await user.destroy();

    res.status(200).json({ message: 'Usuario eliminado correctamente' });
  } catch (error) {
    res.status(500).json({ error: 'Error interno del servidor' });
  }
});

module.exports = router;