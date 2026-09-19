package com.example.practica2.ui.screens

import androidx.compose.foundation.layout.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import com.example.practica2.data.RetrofitClient
import com.example.practica2.data.UserRequest
import kotlinx.coroutines.launch

@Composable
fun ProfileScreen(token: String, userId: Int, onLogout: () -> Unit) {
    var newUsername by remember { mutableStateOf("") }
    var newPassword by remember { mutableStateOf("") }
    var statusMessage by remember { mutableStateOf<String?>(null) }
    var isLoading by remember { mutableStateOf(false) }
    val scope = rememberCoroutineScope()

    Column(
        modifier = Modifier.fillMaxSize().padding(24.dp),
        verticalArrangement = Arrangement.Center
    ) {
        Text("¡Sesión iniciada con éxito!", style = MaterialTheme.typography.headlineMedium, color = MaterialTheme.colorScheme.primary)
        Spacer(modifier = Modifier.height(8.dp))
        Text("Modifica tus datos si lo deseas:", style = MaterialTheme.typography.bodyMedium)
        Spacer(modifier = Modifier.height(16.dp))

        OutlinedTextField(
            value = newUsername,
            onValueChange = { newUsername = it },
            label = { Text("Nuevo nombre de usuario") },
            modifier = Modifier.fillMaxWidth()
        )
        Spacer(modifier = Modifier.height(8.dp))

        OutlinedTextField(
            value = newPassword,
            onValueChange = { newPassword = it },
            label = { Text("Nueva contraseña") },
            modifier = Modifier.fillMaxWidth()
        )
        Spacer(modifier = Modifier.height(16.dp))

        statusMessage?.let {
            Text(it, color = MaterialTheme.colorScheme.secondary)
            Spacer(modifier = Modifier.height(8.dp))
        }

        Button(
            onClick = {
                isLoading = true
                statusMessage = null
                scope.launch {
                    try {
                        // Usamos updateUser con el ID del usuario logueado
                        val response = RetrofitClient.apiService.updateUser(
                            id = userId,
                            request = UserRequest(
                                username = if (newUsername.isNotBlank()) newUsername else null,
                                password = if (newPassword.isNotBlank()) newPassword else null
                            ),
                            token = "Bearer $token"
                        )
                        if (response.isSuccessful) {
                            statusMessage = "Datos actualizados correctamente"
                        } else {
                            statusMessage = "Error al actualizar los datos"
                        }
                    } catch (e: Exception) {
                        statusMessage = "Error de red: ${e.message}"
                    } finally {
                        isLoading = false
                    }
                }
            },
            enabled = !isLoading,
            modifier = Modifier.fillMaxWidth()
        ) {
            Text("Guardar Cambios")
        }

        Spacer(modifier = Modifier.height(16.dp))

        OutlinedButton(
            onClick = onLogout,
            modifier = Modifier.fillMaxWidth()
        ) {
            Text("Cerrar Sesión")
        }
    }
}