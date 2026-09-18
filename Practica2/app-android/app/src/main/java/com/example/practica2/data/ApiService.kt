package com.tupaquete.practica2.data

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
        @Path("id") id: Int,
        @Header("Authorization") token: String
    ): Response<UserResponse>

    @PUT("users/{id}")
    suspend fun updateUser(
        @Path("id") id: Int,
        @Body request: UserRequest,
        @Header("Authorization") token: String
    ): Response<UserResponse>

    @DELETE("users/{id}")
    suspend fun deleteUser(
        @Path("id") id: Int,
        @Header("Authorization") token: String
    ): Response<MessageResponse>
}