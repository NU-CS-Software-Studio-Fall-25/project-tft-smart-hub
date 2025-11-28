Feature: Team Composition Management
  As a user
  I want to manage team compositions
  So that I can organize my TFT strategies

  Background:
    Given I am a registered user

  Scenario: View all team compositions
    When I send an authenticated GET request to "/api/team_comps"
    Then the response status should be 200

  Scenario: Create team without authentication
    When I send an unauthenticated POST request to "/api/team_comps"
    Then the response status should be 401
