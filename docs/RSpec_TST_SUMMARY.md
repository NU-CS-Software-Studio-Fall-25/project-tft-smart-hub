## RSpec Test Coverage Summary

### RSpec Model Tests (Unit Tests)
A total of 29 tests have been implemented across two models, and all tests passed successfully.

#### 1. ser Model (`spec/models/user_spec.rb`) – 9 tests
- Email validations (presence, uniqueness)
- Password validations
- Association validations (comments, likes, favorites, team_comps)
- Authentication tests (correct/incorrect password)
- Admin role checks
- Password encryption and comparison behavior

#### 2. TeamComp Model (`spec/models/team_comp_spec.rb`) – 20 tests
- **Validations:**
    - name (required, max length 50)
    - champions (required)
    - set_identifier
    - description
    - notes

- **Associations:**
    - `belongs_to :user`
    - `has_many :likes`, `:favorites`, `:commentscomments`

- **Scopes:**
    - `for_set`
    - `system_teams`
    - `user_teams`

- **Instance Methods:**
    - `champion_names` (parses comma-separated string)
    - `champion_records` (retrieves champion objects from DB)

- **Callbacks:**
    - `apply_default_set_identifier` (sets default set to TFT15)

