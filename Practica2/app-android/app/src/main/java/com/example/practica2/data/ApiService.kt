package com.example.practica2.data

import retrofit2.Response
import retrofit2.http.*

interface ApiService {
    @POST("register")
    suspend fun register(@Body request: RegisterRequest): Response<UserResponse>

    @POST("login")
    suspend fun login(@Body request: LoginRequest): Response<LoginResponse>

    @GET("users")
    suspend fun getUsers(@Header("Authorization") token: String): Response<List<UserResponse>>

    @GET("users/{id}")
    suspend fun getUser(
        @Header("Authorization") token: String,
        @Path("id") id: Int
    ): Response<UserResponse>

    @POST("users") // Endpoint para crear por el Admin
    suspend fun createUser(
        @Header("Authorization") token: String,
        @Body request: UserRequest
    ): Response<UserResponse>

    @PUT("users/{id}")
    suspend fun updateUser(
        @Header("Authorization") token: String,
        @Path("id") id: Int,
        @Body request: UserRequest
    ): Response<UserResponse>

    @DELETE("users/{id}")
    suspend fun deleteUser(
        @Header("Authorization") token: String,
        @Path("id") id: Int
    ): Response<MessageResponse>
}