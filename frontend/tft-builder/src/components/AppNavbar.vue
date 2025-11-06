<template>
  <nav class="navbar navbar-expand-lg navbar-dark bg-dark border-bottom border-primary sticky-top shadow-sm">
    <div class="container">
      <RouterLink class="navbar-brand fw-bold d-flex align-items-center" to="/" @click="closeNavbar">
        <img src="/logo.svg" alt="TFT Team Lab Logo" width="32" height="32" class="me-2">
        TFT Team Lab
      </RouterLink>

      <button
        ref="navbarToggler"
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

      <div ref="navbarCollapse" class="collapse navbar-collapse" id="primaryNav">
        <ul class="navbar-nav me-auto mb-2 mb-lg-0">
          <li v-for="link in links" :key="link.to" class="nav-item">
            <RouterLink
              class="nav-link"
              :class="{ active: isActive(link) }"
              :to="link.to"
              @click="closeNavbar"
            >
              <i :class="`bi ${link.icon} me-2`"></i>
              {{ link.label }}
            </RouterLink>
          </li>
        </ul>

        <div class="d-flex align-items-center gap-2">
          <RouterLink class="btn btn-warning text-dark fw-semibold" :to="createTeamDestination" @click="closeNavbar">
            <i class="bi bi-plus-circle me-1"></i>
            Create Team
          </RouterLink>

          <template v-if="authStore.token && authStore.user">
            <RouterLink
              class="btn btn-outline-light"
              to="/profile"
              @click="closeNavbar"
            >
              <i class="bi bi-person-circle me-1"></i>
              {{ authStore.user.displayName || authStore.user.email }}
            </RouterLink>

            <button
              class="btn btn-outline-danger"
              type="button"
              @click="handleLogout"
            >
              <i class="bi bi-box-arrow-right me-1"></i>
              Logout
            </button>
          </template>

          <template v-else>
            <RouterLink
              class="btn btn-outline-light"
              :to="{ name: 'login' }"
              @click="closeNavbar"
            >
              <i class="bi bi-box-arrow-in-right me-1"></i>
              Sign in
            </RouterLink>
          </template>
        </div>
      </div>
    </div>
  </nav>
</template>

<script setup>
import { computed, onMounted, ref } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { authStore } from '../stores/authStore'

const router = useRouter()
const route = useRoute()
const navbarCollapse = ref(null)
const navbarToggler = ref(null)

const links = [
  { to: '/', label: 'Home', icon: 'bi-house', match: '/' },
  { to: '/builder', label: 'Search Builder', icon: 'bi-search', match: '/builder' },
  { to: '/teams', label: 'Team Library', icon: 'bi-collection', match: '/teams' },
]

const createTeamDestination = computed(() => (
  (authStore.token && authStore.user) ? { name: 'team-create' } : { name: 'login', query: { redirect: '/teams/new' } }
))

const isActive = (link) => {
  if (link.to === '/') return route.path === '/'
  return route.path.startsWith(link.match || link.to)
}

// Close navbar when clicking on links (mobile)
const closeNavbar = () => {
  if (navbarCollapse.value && window.innerWidth < 992) {
    // Use Bootstrap's Collapse API
    const bsCollapse = window.bootstrap?.Collapse?.getInstance(navbarCollapse.value)
    if (bsCollapse) {
      bsCollapse.hide()
    } else {
      // Fallback: manually remove show class
      navbarCollapse.value.classList.remove('show')
    }
  }
}

const handleLogout = () => {
  closeNavbar()
  authStore.logout()
  router.push({ name: 'home' })
}

const logout = () => {
  authStore.logout()
  router.push({ name: 'home' })
}

onMounted(() => {
  console.debug('[AppNavbar] Mounted, auth state:', {
    token: !!authStore.token,
    user: !!authStore.user
  })
})
</script>
