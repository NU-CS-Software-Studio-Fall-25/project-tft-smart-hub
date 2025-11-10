<template>
  <nav class="navbar navbar-expand-lg navbar-dark bg-dark border-bottom border-primary sticky-top shadow-sm">
    <div class="container">
      <RouterLink class="navbar-brand fw-bold d-flex align-items-center" to="/" @click="handleNavClick">
        <img src="/logo.svg" alt="TFT Team Lab Logo" width="32" height="32" class="me-2">
        TFT Team Lab
      </RouterLink>

      <button
        ref="navbarToggler"
        class="navbar-toggler"
        type="button"
        aria-controls="primaryNav"
        aria-expanded="false"
        aria-label="Toggle navigation"
        @click="toggleNavbar"
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
              @click="handleNavClick"
            >
              <i :class="`bi ${link.icon} me-2`"></i>
              {{ link.label }}
            </RouterLink>
          </li>
        </ul>

        <div class="d-flex align-items-center gap-2">
          <RouterLink class="btn btn-warning text-dark fw-semibold" :to="createTeamDestination" @click="handleNavClick">
            <i class="bi bi-plus-circle me-1"></i>
            Create Team
          </RouterLink>

          <template v-if="authStore.token && authStore.user">
            <RouterLink
              class="btn btn-outline-light"
              to="/profile"
              @click="handleNavClick"
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
              @click="handleNavClick"
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
import { computed, onMounted, ref, nextTick } from 'vue'
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
  if (!route || !route.path) return false
  if (link.to === '/') return route.path === '/'
  return route.path.startsWith(link.match || link.to)
}

// Toggle navbar collapse manually
const toggleNavbar = () => {
  if (!navbarCollapse.value) return
  
  const isExpanded = navbarCollapse.value.classList.contains('show')
  
  if (isExpanded) {
    // Close the navbar
    navbarCollapse.value.classList.remove('show')
    if (navbarToggler.value) {
      navbarToggler.value.setAttribute('aria-expanded', 'false')
    }
  } else {
    // Open the navbar
    navbarCollapse.value.classList.add('show')
    if (navbarToggler.value) {
      navbarToggler.value.setAttribute('aria-expanded', 'true')
    }
  }
  
  console.debug('[AppNavbar] Toggled navbar, now:', isExpanded ? 'closed' : 'open')
}

// Handle navigation link clicks - close menu on mobile
const handleNavClick = () => {
  // Only on mobile/tablet (< 992px bootstrap lg breakpoint)
  if (window.innerWidth < 992 && navbarCollapse.value) {
    // Check if menu is open
    if (navbarCollapse.value.classList.contains('show')) {
      toggleNavbar()
    }
  }
}

const handleLogout = () => {
  handleNavClick()
  setTimeout(() => {
    authStore.logout()
    router.push({ name: 'home' })
  }, 150)
}

const logout = () => {
  authStore.logout()
  router.push({ name: 'home' })
}

onMounted(() => {
  console.debug('[AppNavbar] Mounted, auth state:', {
    token: !!authStore.token,
    user: !!authStore.user,
    bootstrapAvailable: !!window.bootstrap
  })
})
</script>
