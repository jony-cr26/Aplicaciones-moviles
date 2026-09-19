package com.example.practica2.data

data class RegisterRequest(
    val username: String,
    val email: String,
    val password: String
)

data class LoginRequest(
    val email: String,
    val password: String
)

data class LoginResponse(
    val token: String,
    val role: String?, // Añadido para diferenciar si es 'admin' o 'user'
    val id: Int
)

data class UserResponse(
    val id: Int,
    val username: String,
    val email: String,
    val role: String
)

data class UserRequest(
    val username: String? = null,
    val email: String? = null,
    val password: String? = null,
    val role: String? = null
)

data class MessageResponse(
    val message: String
)