import { createRouter, createWebHistory } from 'vue-router'
import HomePage from '../pages/HomePage.vue'
import CardPickerPage from '../pages/CardPickerPage.vue'
import RecommendationsPage from '../pages/RecommendationsPage.vue'
import TeamListPage from '../pages/TeamListPage.vue'
import TeamDetailPage from '../pages/TeamDetailPage.vue'
import TeamEditorPage from '../pages/TeamEditorPage.vue'
import LoginPage from '../pages/LoginPage.vue'
import ProfilePage from '../pages/ProfilePage.vue'
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
    { path: '/profile', name: 'profile', component: ProfilePage, meta: { requiresAuth: true } },
    { path: '/login', name: 'login', component: LoginPage },
    { path: '/:pathMatch(.*)*', redirect: '/' },
  ],
})

router.beforeEach((to, from, next) => {
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
