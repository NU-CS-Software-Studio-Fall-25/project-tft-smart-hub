Feature: User Authentication
  As a user
  I want to register and login
  So that I can access protected features

  Scenario: Successful user registration
    When I send a POST request to "/api/auth/register" with:
      | email                 | newuser@example.com |
      | password              | Test123!@#          |
      | password_confirmation | Test123!@#          |
    Then the response status should be 201
    And the response should be a valid JSON
    And the JSON response should have "token" field
    And the JSON response should have "user" field

  Scenario: Registration with existing email
    Given there is a user with email "existing@example.com"
    When I send a POST request to "/api/auth/register" with:
      | email                 | existing@example.com |
      | password              | Test123!@#           |
      | password_confirmation | Test123!@#           |
    Then the response status should be 422
    And the JSON response should contain an error message

  Scenario: Registration with mismatched passwords
    When I send a POST request to "/api/auth/register" with:
      | email                 | test@example.com |
      | password              | Test123!@#       |
      | password_confirmation | Different456$%^  |
    Then the response status should be 422
    And the JSON response should contain an error message

  Scenario: Registration with missing required fields
    When I send a POST request to "/api/auth/register" with:
      | email    | test@example.com |
      | password | Test123!@#       |
    Then the response status should be 422
    And the JSON response should contain an error message

  Scenario: Successful login
    Given I am a registered user
    When I send a POST request to "/api/auth/login" with valid credentials
    Then the response status should be 200
    And the JSON response should have "token" field
    And the JSON response should have "user" field

  Scenario: Login with invalid credentials
    Given I am a registered user
    When I send a POST request to "/api/auth/login" with invalid credentials
    Then the response status should be 401
    And the JSON response should contain an error message

  Scenario: Login with missing email
    When I send a POST request to "/api/auth/login" with missing "email"
    Then the response status should be 401
    And the JSON response should contain an error message

  Scenario: Get profile without authentication
    When I send an unauthenticated GET request to "/api/auth/me"
    Then the response status should be 401
    And the JSON response should contain an error message
