# frozen_string_literal: true

# User setup steps
Given('I am a registered user') do
  @user = create(:user, email: 'test@example.com', password: 'Test123!@#')
  @token = generate_token(@user)
end

Given('I am an admin user') do
  @user = create(:user, :admin, email: 'admin@example.com', password: 'Test123!@#')
  @token = generate_token(@user)
end

Given('there is a user with email {string}') do |email|
  @other_user = create(:user, email: email)
end

# Authentication steps
When('I send a POST request to {string} with valid credentials') do |path|
  post path, { user: { email: @user.email, password: 'Test123!@#' } }.to_json, json_headers
end

When('I send a POST request to {string} with invalid credentials') do |path|
  post path, { user: { email: 'wrong@example.com', password: 'wrongpassword' } }.to_json, json_headers
end

When('I send a POST request to {string} with missing {string}') do |path, field|
  data = { email: 'test@example.com', password: 'Test123!@#' }
  data.delete(field.to_sym)
  post path, { user: data }.to_json, json_headers
end

# Authenticated requests
When('I send an authenticated GET request to {string}') do |path|
  get path, nil, auth_headers(@token)
end

When('I send an authenticated POST request to {string}') do |path|
  post path, {}.to_json, auth_headers(@token)
end

When('I send an authenticated POST request to {string} with:') do |path, table|
  data = table.rows_hash
  post path, data.to_json, auth_headers(@token)
end

When('I send an authenticated PUT request to {string} with:') do |path, table|
  data = table.rows_hash
  put path, data.to_json, auth_headers(@token)
end

When('I send an authenticated DELETE request to {string}') do |path|
  delete path, nil, auth_headers(@token)
end

When('I send an unauthenticated GET request to {string}') do |path|
  get path, nil, json_headers
end

When('I send an unauthenticated POST request to {string}') do |path|
  post path, {}.to_json, json_headers
end

When('I send an unauthenticated DELETE request to {string}') do |path|
  delete path, nil, json_headers
end

# Response assertions
Then('the response status should be {int}') do |status|
  expect(last_response.status).to eq(status)
end

Then('the response should contain {string}') do |content|
  expect(last_response.body).to include(content)
end

Then('the response should be a valid JSON') do
  expect { JSON.parse(last_response.body) }.not_to raise_error
end

Then('the JSON response should have {string} field') do |field|
  expect(json_response).to have_key(field)
end

Then('the JSON response {string} should be {string}') do |key, value|
  expect(json_response[key].to_s).to eq(value)
end

Then('the JSON response should have {int} items') do |count|
  response_data = json_response.is_a?(Array) ? json_response : json_response['teams'] || json_response['data']
  expect(response_data.length).to eq(count)
end

Then('the JSON response should contain an error message') do
  expect(json_response).to have_key('error').or have_key('errors')
end
