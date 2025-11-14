import { createRouter, createWebHistory } from 'vue-router'
import HomePage from '../pages/HomePage.vue'
import CardPickerPage from '../pages/CardPickerPage.vue'
import RecommendationsPage from '../pages/RecommendationsPage.vue'
import TeamListPage from '../pages/TeamListPage.vue'
import TeamDetailPage from '../pages/TeamDetailPage.vue'
import TeamEditorPage from '../pages/TeamEditorPage.vue'
import LoginPage from '../pages/LoginPage.vue'
import ProfilePage from '../pages/ProfilePage.vue'
import FavoritesPage from '../pages/FavoritesPage.vue'
import NotFoundPage from '../pages/NotFoundPage.vue'
import { authStore } from '../stores/authStore'

const router = createRouter({
  history: createWebHistory(),
  scrollBehavior() {
    return { top: 0 }
  },
  routes: [
    { path: '/', name: 'home', component: HomePage },
    { path: '/builder', name: 'builder', component: CardPickerPage },
    { path: '/recommendations', name: 'recommendations', component: RecommendationsPage },
    { path: '/teams', name: 'teams', component: TeamListPage },
    { path: '/teams/new', name: 'team-create', component: TeamEditorPage, meta: { requiresAuth: true } },
    { path: '/teams/:id', name: 'team-detail', component: TeamDetailPage, props: true },
    { path: '/teams/:id/edit', name: 'team-edit', component: TeamEditorPage, props: true, meta: { requiresAdmin: true } },
    { path: '/favorites', name: 'favorites', component: FavoritesPage, meta: { requiresAuth: true } },
    { path: '/profile', name: 'profile', component: ProfilePage, meta: { requiresAuth: true } },
    { path: '/login', name: 'login', component: LoginPage },
    { path: '/:pathMatch(.*)*', name: 'not-found', component: NotFoundPage },
  ],
})

router.beforeEach((to, from, next) => {
  // Cache busting for development
  if (import.meta.env.DEV) {
    // Force a small delay to ensure DOM is ready
    setTimeout(() => {
      // Check if we need to force reload due to cache issues
      const currentVersion = '1.0.0-dev'
      const storedVersion = localStorage.getItem('tft-app-version')

      if (storedVersion !== currentVersion) {
        console.log('🔄 App version changed, clearing cache...')
        localStorage.setItem('tft-app-version', currentVersion)
        // Clear any cached data that might cause issues
        Object.keys(localStorage).forEach(key => {
          if (key.startsWith('tft-') && key !== 'tft-app-version') {
            localStorage.removeItem(key)
          }
        })
      }
    }, 100)
  }

  if (to.meta.requiresAuth && !authStore.isAuthenticated()) {
    return next({ name: 'login', query: { redirect: to.fullPath } })
  }

  if (to.meta.requiresAdmin && !authStore.isAdmin()) {
    return next({ name: 'home' })
  }

  if (to.name === 'login' && authStore.isAuthenticated()) {
    return next({ name: 'home' })
  }

  return next()
})

export default router
