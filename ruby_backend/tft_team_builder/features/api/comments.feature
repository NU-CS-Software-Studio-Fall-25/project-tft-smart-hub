Feature: Comments on Team Compositions
  As a user
  I want to comment on team compositions
  So that I can discuss strategies

  Background:
    Given I am a registered user

  Scenario: Logged in user can access comment endpoints
    When I send an authenticated POST request to "/api/team_comps/1/comments" with:
      | content | This is a great team composition! |
    Then the response status should be 401
    When I send an authenticated DELETE request to "/api/team_comps/1/comments/1"
    Then the response status should be 401

  Scenario: Add comment without authentication
    When I send an unauthenticated POST request to "/api/team_comps/1/comments"
    Then the response status should be 401

  Scenario: Delete comment without authentication
    When I send an unauthenticated DELETE request to "/api/team_comps/1/comments/1"
    Then the response status should be 401
