# Project TODO & Roadmap

## 🎯 Current Milestone
- [x] Core CRUD functionality for team compositions
- [x] User authentication (JWT + OAuth)
- [x] Comprehensive test coverage (RSpec + Cucumber)
- [x] Automated CI/CD pipeline (GitHub Actions)
- [x] API documentation (RDoc)
- [x] Branch protection rules

---

## 📋 TODO (Next Sprint)

### 1. **End-to-End (E2E) Testing with Playwright**
**Story:** Add automated E2E tests to validate complete user workflows

**Description:**
- Set up Playwright testing framework
- Create test scenarios for:
  - User registration and login flows
  - Team composition CRUD operations
  - Champion search and filtering
  - Recommendation engine interactions
  - User profile management
- Integrate E2E tests into GitHub Actions CI/CD pipeline
- Configure test reports and artifacts

**Acceptance Criteria:**
- Playwright tests run in CI/CD on every PR
- Minimum 80% feature coverage with E2E tests
- Tests complete in under 2 minutes
- All critical user workflows validated

**Estimated Effort:** 3-5 days

---

### 2. **Frontend Unit Tests with Vitest**
**Story:** Implement comprehensive unit tests for Vue components

**Description:**
- Set up Vitest as test runner for frontend
- Add unit tests for:
  - Vue components (props, events, rendering)
  - Composition API hooks
  - Store/state management
  - Service layer (API calls)
  - Utility functions
- Configure code coverage reporting
- Integrate into CI/CD pipeline

**Acceptance Criteria:**
- Minimum 70% code coverage
- All main components have tests
- Tests run in CI/CD
- Coverage reports available in repository

**Estimated Effort:** 3-4 days

---

### 3. **User Favorites and Comments Features**
**Story:** Implement favorites/bookmarks and comments for team compositions

**Description:**
- Backend:
  - Create Favorite model and associations
  - Create Comment model with timestamps
  - API endpoints for favorites (POST/DELETE)
  - API endpoints for comments (CRUD)
  - Add tests for new endpoints
  
- Frontend:
  - Add favorite/heart button to team composition cards
  - Add comments section to composition detail view
  - Implement comment creation/deletion UI
  - Show favorite count and comment count
  - Real-time comment updates (WebSocket optional)

**Acceptance Criteria:**
- Users can favorite/unfavorite compositions
- Users can add/edit/delete comments
- Favorite count persists and displays correctly
- Comments are visible to all users
- All operations require authentication

**Estimated Effort:** 5-7 days

---

### 4. **Admin Dashboard for Data Management**
**Story:** Build an admin panel for managing champions, traits, and system compositions

**Description:**
- Backend:
  - Add admin authorization middleware
  - Create admin API endpoints for CRUD operations
  - Implement bulk import for champion/trait data
  - Add data validation and error handling

- Frontend:
  - Create admin-only routes and layout
  - Champion management interface:
    - List/search/filter champions
    - Add/edit/delete champions
    - Manage sprite coordinates
  - Trait management interface
  - System composition management
  - User management (view, suspend, admin roles)
  - Analytics dashboard (user count, composition popularity, etc.)

**Acceptance Criteria:**
- Admin-only dashboard accessible via `/admin`
- Full CRUD capabilities for data
- Bulk import functionality
- Role-based access control enforced
- Audit logs for admin actions

**Estimated Effort:** 6-8 days

---

### 5. **Persistent User Drafts and History**
**Story:** Allow users to save draft compositions and track modification history

**Description:**
- Backend:
  - Create Draft model for unsaved compositions
  - Implement auto-save mechanism (save on interval)
  - Add composition edit history/versions
  - Create API endpoints for draft management
  - Implement soft-delete for composition history

- Frontend:
  - Auto-save drafts while user is editing
  - Show draft indicator and last saved timestamp
  - Implement undo/redo functionality
  - Display composition change history with diffs
  - Allow restoring previous versions
  - Show "Recently Edited" section in dashboard

**Acceptance Criteria:**
- Drafts auto-save every 30 seconds
- Users can see all their draft compositions
- Users can restore previous versions
- Change history is visible with timestamps
- Unsaved changes are not lost on page refresh

**Estimated Effort:** 4-5 days

---

## 🧊 Icebox (Future Considerations)

### Performance & Infrastructure
- [ ] Implement Redis caching for frequently accessed data
- [ ] Add database query optimization and indexing analysis
- [ ] Set up monitoring and error tracking (Sentry)
- [ ] Implement API rate limiting
- [ ] Add CDN for static assets and sprite sheets

### Advanced Features
- [ ] Real-time multiplayer team building session
- [ ] Team composition sharing and collaborative editing
- [ ] Recommendation engine improvements (ML-based)
- [ ] Patch notes integration and version tracking
- [ ] Team composition export to various formats (JSON, image, etc.)

### Data & Analytics
- [ ] Advanced filtering by traits, cost, synergies
- [ ] User recommendation history and patterns
- [ ] Popular compositions by rank/ELO
- [ ] Tier list builder based on user votes
- [ ] Composition statistics and win rate tracking

### DevOps & Deployment
- [ ] Implement automated deployment to production
- [ ] Set up staging environment
- [ ] Database backup and restore procedures
- [ ] Load testing and performance benchmarks
- [ ] Automatic database migrations on deploy

### Frontend Enhancements
- [ ] Dark mode support
- [ ] Mobile app (React Native or Flutter)
- [ ] Progressive Web App (PWA) improvements
- [ ] Accessibility enhancements (WCAG compliance)
- [ ] Internationalization (i18n) - Chinese, Korean, etc.

### Backend Enhancements
- [ ] GraphQL API alongside REST API
- [ ] WebSocket support for real-time features
- [ ] Email notifications for favorites and comments
- [ ] Two-factor authentication (2FA)
- [ ] Social login providers (Discord, Twitch)

### Testing & Quality
- [ ] Performance testing with k6
- [ ] Load testing suite
- [ ] Accessibility testing (axe-core)
- [ ] Visual regression testing
- [ ] API contract testing

---

## 📊 Success Metrics

### For TODO Items
- ✅ All TODO stories completed within 2 weeks
- ✅ CI/CD pipeline runs successfully for new tests
- ✅ Code coverage remains above 80%
- ✅ Zero regressions in existing functionality

### For Overall Project
- 📈 User engagement: Comments and favorites per composition
- 📈 Performance: API response times < 200ms
- 📈 Quality: Test coverage > 80%, zero critical bugs
- 📈 Reliability: 99.9% uptime

---

## 📝 Notes

### Priority Guidelines
**HIGH**: Critical for user experience, blocks other features
**MEDIUM**: Important improvements that enhance functionality
**LOW**: Nice-to-have features that don't impact core functionality

### Development Process
1. Select story from TODO
2. Create feature branch: `git checkout -b feature/story-name`
3. Implement with tests
4. Create PR with description
5. Ensure CI/CD passes
6. Request code review
7. Merge to main
8. Move story to Done

### Dependency Notes
- **Frontend unit tests** should be completed before E2E tests
- **User favorites/comments** features can be developed in parallel
- **Admin dashboard** depends on proper role-based access control
- **Drafts/history** requires database migration planning

---

## 🚀 Implementation Timeline

```
Week 1:
  - E2E Testing framework setup
  - Frontend unit test setup
  → Both teams can work in parallel

Week 2:
  - User favorites/comments development
  - Admin dashboard initial setup
  → Can work in parallel

Week 3:
  - User drafts/history feature
  - Final testing and bug fixes
  → Polish and prepare for release
```

---

Last Updated: December 6, 2025
Status: Active Development
Team: Backend (Ruitao) + Frontend (Youran)
