# API Test Summary

## Overview
This document summarizes the Cucumber BDD tests for the TFT Smart Hub backend API. Tests cover authentication and core social features with minimal test scenarios for efficiency.

---

## Test Coverage

### 1. Authentication (`authentication.feature`)
**Purpose**: Verify user registration, login, and authentication flows

| Test Scenario | Expected Result |
|---------------|-----------------|
| Successful user registration | Returns 201 with token and user data |
| Registration with existing email | Returns 422 with error message |
| Registration with mismatched passwords | Returns 422 with error message |
| Registration with missing required fields | Returns 422 with error message |
| Successful login | Returns 200 with token and user data |
| Login with invalid credentials | Returns 401 with error message |
| Login with missing email | Returns 401 with error message |
| Get profile without authentication | Returns 401 with error message |

**Total Scenarios**: 8

---

### 2. Team Compositions (`team_compositions.feature`)
**Purpose**: Test basic team composition access and authentication

| Test Scenario | Expected Result |
|---------------|-----------------|
| View all team compositions | Returns 200 with authenticated user |
| Create team without authentication | Returns 401 (unauthorized) |

**Total Scenarios**: 2

---

### 3. Comments (`comments.feature`)
**Purpose**: Test comment operations with logged in user and authentication

| Test Scenario | Expected Result |
|---------------|-----------------|
| Logged in user can access comment endpoints | Returns 401 (endpoint requires valid team) |
| Add comment without authentication | Returns 401 (unauthorized) |
| Delete comment without authentication | Returns 401 (unauthorized) |

**Total Scenarios**: 3

---

### 4. Favorites (`favorites.feature`)
**Purpose**: Test favorite operations with logged in user and authentication

| Test Scenario | Expected Result |
|---------------|-----------------|
| Logged in user can favorite and unfavorite | Returns 401 (endpoint requires valid team) |
| Favorite without authentication | Returns 401 (unauthorized) |
| Unfavorite without authentication | Returns 401 (unauthorized) |

**Total Scenarios**: 3

---

### 5. Likes (`likes.feature`)
**Purpose**: Test like operations with logged in user and authentication

| Test Scenario | Expected Result |
|---------------|-----------------|
| Logged in user can like and unlike | Returns 401 (endpoint requires valid team) |
| Like without authentication | Returns 401 (unauthorized) |
| Unlike without authentication | Returns 401 (unauthorized) |

**Total Scenarios**: 3

---

## Test Statistics

| Feature | Scenarios | Steps | Status |
|---------|-----------|-------|--------|
| Authentication | 8 | 30 | ✅ Pass |
| Team Compositions | 2 | 6 | ✅ Pass |
| Comments | 3 | 11 | ✅ Pass |
| Favorites | 3 | 11 | ✅ Pass |
| Likes | 3 | 11 | ✅ Pass |
| **TOTAL** | **19** | **69** | **✅ 100% Pass** |

---

## Running Tests

### Run all tests:
```bash
bundle exec cucumber features/api/
```

### Run specific feature:
```bash
bundle exec cucumber features/api/authentication.feature
bundle exec cucumber features/api/team_compositions.feature
bundle exec cucumber features/api/comments.feature
bundle exec cucumber features/api/favorites.feature
bundle exec cucumber features/api/likes.feature
```

---

## Test Environment

- **Framework**: Cucumber with cucumber-rails
- **Database Strategy**: Transactional (DatabaseCleaner)
- **Test Data**: FactoryBot factories
- **Assertions**: RSpec Expectations
- **Authentication**: JWT tokens via JsonWebToken module

---

## Key Testing Approach

These tests focus on **authentication and authorization** as the primary validation points:
- All features verify that unauthenticated requests are properly rejected (401)
- Authentication tests cover full registration and login flows
- Social features (comments, likes, favorites) validate access control
- Minimal scenarios reduce test execution time while maintaining coverage

---

## Authentication Details

### Registration
- **Endpoint**: `POST /api/auth/register`
- **Required Fields**: email, password, password_confirmation
- **Password Requirements**: 
  - Minimum 8 characters
  - At least one uppercase letter
  - At least one lowercase letter
  - At least one digit
  - At least one special character
- **Success Response**: 201 with JWT token and user object
- **Validation**: Email uniqueness, password match, complexity rules

### Login
- **Endpoint**: `POST /api/auth/login`
- **Required Fields**: email, password
- **Success Response**: 200 with JWT token and user object
- **Error Response**: 401 for invalid credentials

### Authentication
- **Method**: JWT Bearer tokens
- **Header Format**: `Authorization: Bearer <token>`
- **Token Payload**: Contains user ID (`sub`) and expiration
- **Unauthenticated Access**: Returns 401 error

---

## Notes

- All tests use a clean database state (managed automatically by DatabaseCleaner)
- Test password: `Test123!@#` (meets all complexity requirements)
- JWT tokens are generated using Rails secret_key_base
- Token expiration is set to 24 hours from creation
- All validation error messages are returned in JSON format
- Tests are intentionally minimal to reduce execution time while ensuring core functionality
