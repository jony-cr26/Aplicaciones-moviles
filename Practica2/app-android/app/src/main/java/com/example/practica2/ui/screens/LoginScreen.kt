package com.example.practica2.ui.screens

import androidx.compose.foundation.layout.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import com.example.practica2.data.LoginRequest
import com.example.practica2.data.RetrofitClient
import kotlinx.coroutines.launch

@Composable
fun LoginScreen(
    onLoginSuccess: (String, String, Int) -> Unit, // Modificado para recibir token y rol
    onNavigateToRegister: () -> Unit
) {
    var email by remember { mutableStateOf("") }
    var password by remember { mutableStateOf("") }
    var errorMessage by remember { mutableStateOf<String?>(null) }
    var isLoading by remember { mutableStateOf(false) }
    val scope = rememberCoroutineScope()

    Column(
        modifier = Modifier.fillMaxSize().padding(24.dp),
        verticalArrangement = Arrangement.Center
    ) {
        Text("Iniciar Sesión", style = MaterialTheme.typography.headlineMedium)
        Spacer(modifier = Modifier.height(16.dp))

        OutlinedTextField(
            value = email,
            onValueChange = { email = it },
            label = { Text("Email") },
            modifier = Modifier.fillMaxWidth()
        )
        Spacer(modifier = Modifier.height(8.dp))

        OutlinedTextField(
            value = password,
            onValueChange = { password = it },
            label = { Text("Contraseña") },
            modifier = Modifier.fillMaxWidth()
        )
        Spacer(modifier = Modifier.height(16.dp))

        errorMessage?.let {
            Text(it, color = MaterialTheme.colorScheme.error)
            Spacer(modifier = Modifier.height(8.dp))
        }

        Button(
            onClick = {
                isLoading = true
                errorMessage = null

                scope.launch {
                    try {
                        val response = RetrofitClient.apiService.login(LoginRequest(email, password))
                        if (response.isSuccessful && response.body() != null) {
                            val body = response.body()!!
                            val token = body.token
                            val role = body.role ?: "user"
                            val id = body.id // <-- Obtenemos el id del backend
                            
                            if (token != null) {
                                onLoginSuccess(token, role, id) // <-- Mandamos los 3 valores
                            } else {
                                errorMessage = "Error: token no recibido"
                            }
                        } else {
                            errorMessage = "Credenciales inválidas"
                        }
                    } catch (e: Exception) {
                        errorMessage = "Error de red: ${e.message}"
                    } finally {
                        isLoading = false
                    }
                }
            },
            enabled = !isLoading,
            modifier = Modifier.fillMaxWidth()
        ) {
            Text(if (isLoading) "Cargando..." else "Iniciar Sesión")
        }

        Spacer(modifier = Modifier.height(8.dp))

        // Botón para ir al Registro
        TextButton(
            onClick = onNavigateToRegister,
            modifier = Modifier.fillMaxWidth()
        ) {
            Text("¿Aún no tienes cuenta? Regístrate")
        }
    }
}