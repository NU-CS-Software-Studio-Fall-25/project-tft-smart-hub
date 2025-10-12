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

        <RouterLink class="btn btn-warning text-dark fw-semibold" to="/teams/new">
          <i class="bi bi-plus-circle me-1"></i>
          Create Team
        </RouterLink>
      </div>
    </div>
  </nav>
</template>

<script setup>
import { useRoute } from 'vue-router'

const route = useRoute()
const links = [
  { to: '/', label: 'Home', icon: 'bi-house', match: '/' },
  { to: '/builder', label: 'Search Builder', icon: 'bi-search', match: '/builder' },
  { to: '/teams', label: 'Team Library', icon: 'bi-collection', match: '/teams' },
]

const isActive = (link) => {
  if (link.to === '/') return route.path === '/'
  return route.path.startsWith(link.match || link.to)
}
</script>
