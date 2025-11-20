# frozen_string_literal: true

# Authentication specific steps
When('I send a POST request to {string} with:') do |path, table|
  data = table.rows_hash
  # Wrap data in 'user' key for auth endpoints
  wrapped_data = { user: data }
  post path, wrapped_data.to_json, json_headers
end

# Specific step for unauthenticated POST to /api/team_comps (wraps in user data)
When('I send an unauthenticated POST request to {string} with wrapped user data') do |path|
  post path, {}.to_json, json_headers
end
