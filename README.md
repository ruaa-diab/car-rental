# Autora: Car Rental Platform

A full car rental system I built end to end: a Spring Boot REST backend and a Flutter mobile client, with separate experiences for customers, field employees, managers and admins.

## Features

- **Role-based access** for four roles: customer, field employee, manager and admin, secured with JWT authentication
- **Booking with availability checks** that prevent overlapping reservations for the same car
- **Automatic pricing** based on rental details
- **Nightly scheduled job** that updates booking statuses
- **Car inspections** handled by field employees, with photo uploads
- **Branches, payments, favorites and notifications**
- **Revenue reports** for managers and admins
- **96 REST endpoints** across 15 modules
- **39-screen Flutter client**

## Tech Stack

| Layer | Technologies |
|---|---|
| Backend | Java 17, Spring Boot 3.2, Spring Security, JWT (jjwt), Spring Data JPA, Hibernate, Bean Validation |
| Database | PostgreSQL |
| Build | Maven |
| Mobile | Flutter, Dart |

## Project Structure

```
car-rental/
├── car-rental-backend/           # Spring Boot REST API
│   └── src/main/java/com/autora/rental/
│       ├── booking/              # bookings, availability, pricing, nightly job
│       ├── car/  branch/  inspection/  payment/
│       ├── user/  employee/  favorite/  notification/
│       ├── report/               # revenue reports
│       ├── jwt/  token/  config/ # authentication and security
│       └── upload/  task/
└── rental_app_customer_UI/       # Flutter mobile client
```

## Getting Started

### Requirements

- Java 17
- Maven
- PostgreSQL
- Flutter SDK

### Backend

1. Create a PostgreSQL database named `autora_rental` and a user for it.
2. Set the database username and password in `car-rental-backend/src/main/resources/application.properties`.
3. Run:

```bash
cd car-rental-backend
mvn spring-boot:run
```

The API runs on `http://localhost:9090`.

### Mobile app

```bash
cd rental_app_customer_UI
flutter pub get
flutter run
```
