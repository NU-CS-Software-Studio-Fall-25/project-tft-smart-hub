import { createRouter, createWebHistory } from 'vue-router'
import HomePage from '../pages/HomePage.vue'
import CardPickerPage from '../pages/CardPickerPage.vue'
import RecommendationsPage from '../pages/RecommendationsPage.vue'
import TeamListPage from '../pages/TeamListPage.vue'
import TeamDetailPage from '../pages/TeamDetailPage.vue'
import TeamEditorPage from '../pages/TeamEditorPage.vue'

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
    { path: '/teams/new', name: 'team-create', component: TeamEditorPage },
    { path: '/teams/:id', name: 'team-detail', component: TeamDetailPage, props: true },
    { path: '/teams/:id/edit', name: 'team-edit', component: TeamEditorPage, props: true },
    { path: '/:pathMatch(.*)*', redirect: '/' },
  ],
})

export default router
