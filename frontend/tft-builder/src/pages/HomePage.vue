<template>
  <div>
    <section class="home-hero text-light">
      <div class="container py-5">
        <div class="row align-items-center g-5">
          <div class="col-lg-6">
            <div class="badge bg-warning text-dark mb-3 px-3 py-2 fw-semibold">
              <i class="bi bi-lightning-charge me-2"></i>
              TFT Team Builder &amp; Library
            </div>
            <h1 class="display-5 fw-bold mb-3">
              Plan your next top 4 with curated comps and live synergy search.
            </h1>
            <p class="lead text-white-50 mb-4">
              Browse the champion pool, build synergy-driven comps, and keep your own drafts inside a single polished workspace.
            </p>
            <div class="d-flex flex-wrap gap-3">
              <RouterLink class="btn btn-warning text-dark fw-semibold btn-lg" to="/builder">
                Start Searching
              </RouterLink>
              <RouterLink class="btn btn-outline-light btn-lg" to="/teams">
                Explore Team Library
              </RouterLink>
            </div>
          </div>
          <div class="col-lg-6">
            <div class="glass-panel mx-auto">
              <div class="panel-header text-uppercase text-secondary small fw-semibold">
                Recently highlighted comps
              </div>
              <div class="panel-body">
                <div v-if="featuredTeams.length === 0" class="text-white-50 small">
                  Loading popular team comps...
                </div>
                <div
                  v-for="team in featuredTeams"
                  :key="team.id"
                  class="d-flex align-items-center justify-content-between py-2 border-bottom border-secondary-subtle"
                >
                  <div class="me-3">
                    <div class="fw-semibold text-light">{{ team.name }}</div>
                    <div class="small text-white-50">{{ team.description }}</div>
                  </div>
                  <div class="text-end">
                    <div class="badge bg-success-subtle text-success-emphasis mb-1">
                      Win {{ percentage(team.winRate) }}
                    </div>
                    <div class="small text-white-50">
                      {{ (team.meta?.matchCount || 0) }} synergies matched
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </section>

    <section class="py-5 bg-body-secondary">
      <div class="container">
        <h2 class="h3 fw-bold mb-4 section-heading">Why use TFT Team Lab?</h2>
        <div class="row g-4">
          <div v-for="feature in features" :key="feature.title" class="col-md-4">
            <div class="card h-100 shadow-sm border-0">
              <div class="card-body p-4">
                <div class="icon-circle mb-3">
                  <i :class="`bi ${feature.icon}`"></i>
                </div>
                <h3 class="h5 fw-semibold">{{ feature.title }}</h3>
                <p class="text-body-secondary small mb-3">
                  {{ feature.description }}
                </p>
                <RouterLink :to="feature.path" class="stretched-link text-decoration-none">
                  <span class="fw-semibold">Go to {{ feature.cta }}</span>
                  <i class="bi bi-arrow-right-short"></i>
                </RouterLink>
              </div>
            </div>
          </div>
        </div>
      </div>
    </section>
  </div>
</template>

<script setup>
import { computed, onMounted } from 'vue'
import { RouterLink } from 'vue-router'
import { fetchCards, fetchTeamComps } from '../services/api'
import { store as selectionStore } from '../stores/selectionStore'
import { teamStore } from '../stores/teamStore'

const features = [
  {
    title: 'Champion Synergy Search',
    description: 'Select multiple champions and instantly discover curated comps that contain your picks.',
    icon: 'bi-diagram-3',
    path: '/builder',
    cta: 'search',
  },
  {
    title: 'Team Library & Analytics',
    description: 'Review curated comps with win/play rates, notes, and quick previews before locking your board.',
    icon: 'bi-journal-richtext',
    path: '/teams',
    cta: 'library',
  },
  {
    title: 'Custom Team Drafts',
    description: 'Save your own builds directly into the shared database with sources and strategy notes.',
    icon: 'bi-pen',
    path: '/teams/new',
    cta: 'builder',
  },
]

const featuredTeams = computed(() => teamStore.list.slice(0, 3))

const percentage = (value) => {
  if (value === null || value === undefined) return 'N/A'
  return `${(value * 100).toFixed(1)}%`
}

onMounted(async () => {
  if (!selectionStore.allCards.length) {
    const cards = await fetchCards()
    selectionStore.setAllCards(cards)
  }
  if (!teamStore.list.length) {
    const teams = await fetchTeamComps({ limit: 6 })
    teamStore.setTeams(teams)
  }
})
</script>

<style scoped>
.home-hero {
  background:
    radial-gradient(40% 50% at 20% 20%, rgba(60, 110, 200, 0.35), transparent 70%),
    radial-gradient(30% 40% at 80% 20%, rgba(210, 110, 220, 0.25), transparent 70%),
    linear-gradient(160deg, #0b1020 0%, #10172a 45%, #151c30 100%);
}

.glass-panel {
  max-width: 420px;
  background: rgba(17, 24, 39, 0.7);
  border-radius: 16px;
  border: 1px solid rgba(255, 255, 255, 0.1);
  backdrop-filter: blur(12px);
  padding: 1.5rem;
}

.panel-header {
  letter-spacing: 0.08em;
}

.panel-body {
  max-height: 260px;
  overflow-y: auto;
}

.icon-circle {
  width: 48px;
  height: 48px;
  border-radius: 50%;
  background: rgba(13, 110, 253, 0.12);
  color: #0d6efd;
  display: grid;
  place-items: center;
  font-size: 1.25rem;
}

.section-heading {
  color: #0b2255;
  letter-spacing: 0.08em;
  text-transform: uppercase;
  position: relative;
}

.section-heading::after {
  content: '';
  position: absolute;
  left: 0;
  bottom: -0.3rem;
  width: 72px;
  height: 4px;
  border-radius: 999px;
  background: linear-gradient(90deg, #f39c12, #ffdd57);
}
</style>
