package com.example.practica2.navigation

sealed class Screen(val route: String) {
    object Login : Screen("login")
    object Register : Screen("register")
    object UserList : Screen("user_list")
}