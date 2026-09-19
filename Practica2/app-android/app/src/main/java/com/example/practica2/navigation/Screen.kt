package com.example.practica2.navigation

sealed class Screen(val route: String) {
    object Login : Screen("login")
    object Register : Screen("register")
    object Profile : Screen("profile")
    object AdminDashboard : Screen("admin_dashboard")
}