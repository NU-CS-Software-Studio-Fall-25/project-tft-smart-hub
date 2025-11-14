<template>
  <div>
    <section class="home-hero text-light py-5 pb-0">
      <div class="container py-5 pt-3">
        <div class="row align-items-center g-5">
          <div class="col-12 text-center">
            <h1 class="display-5 fw-bold mb-3">
              Plan your next top 4 with curated comps and live synergy search.
            </h1>
            <div class="d-flex flex-wrap gap-3 justify-content-center">
              <RouterLink class="btn btn-warning text-dark fw-semibold btn-lg" to="/builder">
                Start Searching
              </RouterLink>
              <RouterLink class="btn btn-outline-light btn-lg" to="/teams">
                Explore Team Library
              </RouterLink>
            </div>
          </div>
        </div>
      </div>
    </section>

    <section class="py-5 bg-body-secondary mt-10">
      <div class="container">
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
    const { teams, meta } = await fetchTeamComps({ limit: 6 })
    teamStore.setTeams(teams, meta)
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
