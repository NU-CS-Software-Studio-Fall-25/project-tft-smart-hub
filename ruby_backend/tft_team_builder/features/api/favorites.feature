Feature: Team Composition Favorites
  As a user
  I want to favorite team compositions
  So that I can save my preferred strategies

  Background:
    Given I am a registered user

  Scenario: Logged in user can favorite and unfavorite
    When I send an authenticated POST request to "/api/team_comps/1/favorite"
    Then the response status should be 401
    When I send an authenticated DELETE request to "/api/team_comps/1/favorite"
    Then the response status should be 401

  Scenario: Favorite without authentication
    When I send an unauthenticated POST request to "/api/team_comps/1/favorite"
    Then the response status should be 401

  Scenario: Unfavorite without authentication
    When I send an unauthenticated DELETE request to "/api/team_comps/1/favorite"
    Then the response status should be 401
