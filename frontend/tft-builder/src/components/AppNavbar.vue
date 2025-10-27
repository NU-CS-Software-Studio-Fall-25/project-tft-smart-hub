<template>
  <nav class="navbar navbar-expand-lg navbar-dark bg-dark border-bottom border-primary sticky-top shadow-sm">
    <div class="container">
      <RouterLink class="navbar-brand fw-bold" to="/">
        <i class="bi bi-gem me-2 text-warning"></i>
        TFT Team Lab
      </RouterLink>

      <button
        class="navbar-toggler"
        type="button"
        data-bs-toggle="collapse"
        data-bs-target="#primaryNav"
        aria-controls="primaryNav"
        aria-expanded="false"
        aria-label="Toggle navigation"
      >
        <span class="navbar-toggler-icon"></span>
      </button>

      <div class="collapse navbar-collapse" id="primaryNav">
        <ul class="navbar-nav me-auto mb-2 mb-lg-0">
          <li v-for="link in links" :key="link.to" class="nav-item">
            <RouterLink
              class="nav-link"
              :class="{ active: isActive(link) }"
              :to="link.to"
            >
              <i :class="`bi ${link.icon} me-2`"></i>
              {{ link.label }}
            </RouterLink>
          </li>
        </ul>

        <div class="d-flex align-items-center gap-2">
          <RouterLink class="btn btn-warning text-dark fw-semibold" :to="createTeamDestination">
            <i class="bi bi-plus-circle me-1"></i>
            Create Team
          </RouterLink>

          <RouterLink
            v-if="isAuthenticated"
            class="btn btn-outline-light"
            to="/profile"
          >
            <i class="bi bi-person-circle me-1"></i>
            {{ displayName }}
          </RouterLink>

          <button
            v-if="isAuthenticated"
            class="btn btn-outline-danger"
            type="button"
            @click="logout"
          >
            <i class="bi bi-box-arrow-right me-1"></i>
            Logout
          </button>

          <RouterLink
            v-else
            class="btn btn-outline-light"
            :to="{ name: 'login' }"
          >
            <i class="bi bi-box-arrow-in-right me-1"></i>
            Sign in
          </RouterLink>
        </div>
      </div>
    </div>
  </nav>
</template>

<script setup>
import { computed, onMounted, ref, watchEffect } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { authStore } from '../stores/authStore'

const router = useRouter()
const route = useRoute()

const links = [
  { to: '/', label: 'Home', icon: 'bi-house', match: '/' },
  { to: '/builder', label: 'Search Builder', icon: 'bi-search', match: '/builder' },
  { to: '/teams', label: 'Team Library', icon: 'bi-collection', match: '/teams' },
]

// Force reactivity with multiple triggers
const authTrigger = ref(0)
const forceUpdate = ref(0)

const isAuthenticated = computed(() => {
  // Access both triggers to ensure reactivity
  authTrigger.value
  forceUpdate.value
  const result = authStore.isAuthenticated()
  console.log('[AppNavbar] isAuthenticated computed:', result, {
    token: !!authStore.token,
    user: !!authStore.user
  })
  return result
})

const displayName = computed(() => {
  authTrigger.value
  forceUpdate.value
  return authStore.user?.displayName || authStore.user?.email
})

const createTeamDestination = computed(() => (
  isAuthenticated.value ? { name: 'team-create' } : { name: 'login', query: { redirect: '/teams/new' } }
))

const isActive = (link) => {
  if (link.to === '/') return route.path === '/'
  return route.path.startsWith(link.match || link.to)
}

const logout = () => {
  authStore.logout()
  authTrigger.value++
  forceUpdate.value++
  router.push({ name: 'home' })
}

// Watch for auth store changes
watchEffect(() => {
  console.log('[AppNavbar] Auth state changed:', {
    token: !!authStore.token,
    user: !!authStore.user,
    initialized: authStore.initialized
  })
  forceUpdate.value++
})

// Ensure auth state is loaded on mount
onMounted(() => {
  console.log('[AppNavbar] Mounted, checking auth state...')
  // Force multiple checks
  authTrigger.value++
  setTimeout(() => {
    forceUpdate.value++
    console.log('[AppNavbar] Delayed auth check:', {
      token: !!authStore.token,
      user: !!authStore.user
    })
  }, 100)
  setTimeout(() => {
    forceUpdate.value++
  }, 500)
})
</script>
