Feature: Team Composition Likes
  As a user
  I want to like team compositions
  So that I can show appreciation for strategies

  Background:
    Given I am a registered user

  Scenario: Logged in user can like and unlike
    When I send an authenticated POST request to "/api/team_comps/1/like"
    Then the response status should be 401
    When I send an authenticated DELETE request to "/api/team_comps/1/like"
    Then the response status should be 401

  Scenario: Like without authentication
    When I send an unauthenticated POST request to "/api/team_comps/1/like"
    Then the response status should be 401

  Scenario: Unlike without authentication
    When I send an unauthenticated DELETE request to "/api/team_comps/1/like"
    Then the response status should be 401
