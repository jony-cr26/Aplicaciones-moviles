package com.example.practica2.ui.screens

import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import com.example.practica2.data.RetrofitClient
import com.example.practica2.data.UserRequest
import com.example.practica2.data.UserResponse
import kotlinx.coroutines.launch

@Composable
fun AdminScreen(token: String, onLogout: () -> Unit) {
    var users by remember { mutableStateOf<List<UserResponse>>(emptyList()) }
    var errorMessage by remember { mutableStateOf<String?>(null) }
    
    // Estados para crear/editar
    var showDialog by remember { mutableStateOf(false) }
    var editingUser by remember { mutableStateOf<UserResponse?>(null) }
    var inputUsername by remember { mutableStateOf("") }
    var inputEmail by remember { mutableStateOf("") }
    var inputPassword by remember { mutableStateOf("") }
    var inputRole by remember { mutableStateOf("user") }

    val scope = rememberCoroutineScope()

    fun loadUsers() {
        scope.launch {
            try {
                val response = RetrofitClient.apiService.getUsers("Bearer $token")
                if (response.isSuccessful && response.body() != null) {
                    users = response.body()!!
                } else {
                    errorMessage = "No se pudo cargar la lista de usuarios"
                }
            } catch (e: Exception) {
                errorMessage = "Error: ${e.message}"
            }
        }
    }

    LaunchedEffect(Unit) {
        loadUsers()
    }

    Column(modifier = Modifier.fillMaxSize().padding(16.dp)) {
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.SpaceBetween
        ) {
            Text("Panel de Administrador", style = MaterialTheme.typography.headlineSmall)
            Button(onClick = onLogout) { Text("Salir") }
        }

        Spacer(modifier = Modifier.height(16.dp))

        Button(onClick = {
            editingUser = null
            inputUsername = ""
            inputEmail = ""
            inputPassword = ""
            inputRole = "user"
            showDialog = true
        }) {
            Text("Crear Nuevo Usuario")
        }

        Spacer(modifier = Modifier.height(16.dp))

        errorMessage?.let {
            Text(it, color = MaterialTheme.colorScheme.error)
            Spacer(modifier = Modifier.height(8.dp))
        }

        // Tabla / Lista de usuarios
        LazyColumn(modifier = Modifier.fillMaxSize()) {
            items(users) { user ->
                Card(
                    modifier = Modifier.fillMaxWidth().padding(vertical = 4.dp),
                    elevation = CardDefaults.cardElevation(4.dp)
                ) {
                    Column(modifier = Modifier.padding(12.dp)) {
                        Text("ID: ${user.id} | Rol: ${user.role}", style = MaterialTheme.typography.bodySmall)
                        Text("Usuario: ${user.username}", style = MaterialTheme.typography.bodyLarge)
                        Text("Email: ${user.email}", style = MaterialTheme.typography.bodyMedium)
                        
                        Spacer(modifier = Modifier.height(8.dp))
                        
                        Row(modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.End) {
                            TextButton(onClick = {
                                editingUser = user
                                inputUsername = user.username
                                inputEmail = user.email
                                inputPassword = ""
                                inputRole = user.role
                                showDialog = true
                            }) {
                                Text("Editar")
                            }
                            Spacer(modifier = Modifier.width(8.dp))
                            TextButton(onClick = {
                                scope.launch {
                                    val resp = RetrofitClient.apiService.deleteUser("Bearer $token", user.id)
                                    if (resp.isSuccessful) loadUsers()
                                }
                            }) {
                                Text("Eliminar", color = MaterialTheme.colorScheme.error)
                            }
                        }
                    }
                }
            }
        }
    }

    // Diálogo para Crear / Editar Usuario
    if (showDialog) {
        AlertDialog(
            onDismissRequest = { showDialog = false },
            title = { Text(if (editingUser == null) "Crear Usuario" else "Editar Usuario") },
            text = {
                Column {
                    OutlinedTextField(
                        value = inputUsername,
                        onValueChange = { inputUsername = it },
                        label = { Text("Username") },
                        modifier = Modifier.fillMaxWidth()
                    )
                    Spacer(modifier = Modifier.height(8.dp))
                    OutlinedTextField(
                        value = inputEmail,
                        onValueChange = { inputEmail = it },
                        label = { Text("Email") },
                        modifier = Modifier.fillMaxWidth()
                    )
                    Spacer(modifier = Modifier.height(8.dp))
                    OutlinedTextField(
                        value = inputPassword,
                        onValueChange = { inputPassword = it },
                        label = { Text(if (editingUser == null) "Contraseña" else "Nueva contraseña (opcional)") },
                        modifier = Modifier.fillMaxWidth()
                    )
                    Spacer(modifier = Modifier.height(8.dp))
                    OutlinedTextField(
                        value = inputRole,
                        onValueChange = { inputRole = it },
                        label = { Text("Rol (user / admin)") },
                        modifier = Modifier.fillMaxWidth()
                    )
                }
            },
            confirmButton = {
                Button(onClick = {
                    scope.launch {
                        if (editingUser == null) {
                            // Crear
                            val resp = RetrofitClient.apiService.createUser(
                                "Bearer $token",
                                UserRequest(inputUsername, inputEmail, inputPassword, inputRole)
                            )
                            if (resp.isSuccessful) loadUsers()
                        } else {
                            // Editar
                            val resp = RetrofitClient.apiService.updateUser(
                                "Bearer $token",
                                editingUser!!.id,
                                UserRequest(
                                    username = inputUsername,
                                    email = inputEmail,
                                    password = if (inputPassword.isNotBlank()) inputPassword else null,
                                    role = inputRole
                                )
                            )
                            if (resp.isSuccessful) loadUsers()
                        }
                        showDialog = false
                    }
                }) {
                    Text("Guardar")
                }
            },
            dismissButton = {
                TextButton(onClick = { showDialog = false }) { Text("Cancelar") }
            }
        )
    }
}