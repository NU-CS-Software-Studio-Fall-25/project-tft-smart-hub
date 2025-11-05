<template>
  <div class="page-white">
    <div class="container py-4">
      <header class="d-flex justify-content-between align-items-center mb-3">
        <div>
          <h1 class="h4 fw-bold mb-1">Recommended team compositions</h1>
          <p class="text-body-secondary mb-0">
            Based on your selected champions, we found {{ teams.length }} curated team comp suggestions.
          </p>
        </div>
        <RouterLink class="btn btn-outline-secondary" :to="{ name: 'builder' }" aria-label="Return to champion search">
          <i class="bi bi-chevron-left me-1" aria-hidden="true"></i>
          Back to search
        </RouterLink>
      </header>

      <div class="row g-4">
        <aside class="col-lg-4" aria-labelledby="selected-champions-heading">
          <div class="card shadow-sm border-0 sticky-sidebar">
            <h2 id="selected-champions-heading" class="card-header bg-dark text-light fw-semibold">
              Selected champions
            </h2>
            <div class="card-body">
              <div v-if="selectedCards.length === 0" class="text-body-secondary small">
                No champions selected. Go back and choose at least one champion to receive recommendations.
              </div>
              <div v-else class="d-flex flex-wrap gap-3">
                <CardTile
                  v-for="card in selectedCards"
                  :key="card.id"
                  :card="card"
                  :selected="true"
                  @remove="remove(card.id)"
                />
              </div>
            </div>
            <div class="card-footer bg-light d-flex justify-content-between align-items-center">
              <span class="small text-body-secondary">
                {{ selectedCards.length }} champions selected
              </span>
              <button
                class="btn btn-sm btn-outline-dark"
                :disabled="selectedCards.length === 0 || refreshing"
                @click="refreshRecommendations"
              >
                <span v-if="!refreshing">
                  <i class="bi bi-arrow-repeat me-1"></i>
                  Refresh
                </span>
                <span v-else class="d-flex align-items-center gap-2">
                  <span class="spinner-border spinner-border-sm"></span>
                  Updating...
                </span>
              </button>
            </div>
          </div>
        </aside>

        <main class="col-lg-8">
          <div v-if="loading" class="py-5 text-center" role="status">
            <div class="spinner-border"></div>
            <div class="mt-3 text-body-secondary">Fetching updated recommendations...</div>
          </div>

          <div v-else>
            <div v-if="teams.length === 0" class="alert alert-info" role="alert">
              We do not have a curated comp that matches the selected champions yet. Try removing a champion or explore
              the <RouterLink to="/teams">team library</RouterLink> instead.
            </div>

            <div v-else>
              <div class="d-flex justify-content-between align-items-center mb-3" role="status" aria-live="polite">
                <div class="text-body-secondary small">
                  Showing {{ paginatedTeams.length }} of {{ teams.length }} team comps
                </div>
              </div>

              <article
                v-for="team in paginatedTeams"
                :key="team.id"
                class="card mb-3 shadow-sm border-0 recommendation-card"
                :aria-labelledby="`team-${team.id}-name`"
              >
                <header class="card-header d-flex align-items-center justify-content-between bg-body-secondary py-2">
                  <div>
                    <h2 :id="`team-${team.id}-name`" class="fw-bold h5 mb-1">{{ team.name }}</h2>
                    <p class="small text-body-secondary mb-0">{{ team.description }}</p>
                  </div>
                  <div class="text-end small text-body-secondary">
                    <div>
                      <i class="bi bi-trophy text-warning me-1" aria-hidden="true"></i>
                      Win {{ percentage(team.winRate) }}
                    </div>
                    <div v-if="team.playRate">
                      <i class="bi bi-people text-primary me-1" aria-hidden="true"></i>
                      Pick {{ percentage(team.playRate) }}
                    </div>
                  </div>
                </header>
                <div class="card-body py-3">
                  <section :aria-labelledby="`team-${team.id}-champions`">
                    <h3 :id="`team-${team.id}-champions`" class="visually-hidden">
                      Champions in {{ team.name }}
                    </h3>
                    <div class="d-flex flex-wrap gap-2 recommendation-champions">
                    <div
                      v-for="card in team.cards"
                      :key="`${team.id}-${card.id}`"
                      class="recommendation-card-tile"
                      @contextmenu.prevent="preview(card)"
                    >
                      <div class="recommendation-card-img">
                        <SpriteImage
                          :sprite="card.sprite"
                          :image-url="card.imageUrl"
                          :alt="card.name"
                          :size="64"
                        />
                      </div>
                      <div class="recommendation-card-name">{{ card.name }}</div>
                    </div>
                  </div>
                  </section>

                  <div class="row mt-2 small text-body-secondary">
                    <div class="col-sm-6">
                      <span class="badge bg-success-subtle text-success-emphasis me-2">
                        Matches {{ team.meta?.matchCount || 0 }}
                      </span>
                      <span class="badge bg-secondary-subtle text-secondary-emphasis">
                        Missing {{ team.meta?.missingChampionNames?.length || 0 }}
                      </span>
                    </div>
                    <div class="col-sm-6 text-sm-end">
                      <span v-if="team.meta?.matchedChampionNames?.length">
                        Matched:
                        {{ team.meta.matchedChampionNames.join(', ') }}
                      </span>
                    </div>
                  </div>

                  <div v-if="team.notes" class="alert alert-secondary mt-2 mb-0 small py-2">
                    {{ team.notes }}
                  </div>
                </div>
                <div class="card-footer bg-white d-flex justify-content-between align-items-center py-2">
                  <RouterLink class="btn btn-sm btn-outline-primary" :to="{ name: 'team-detail', params: { id: team.id } }" :aria-label="`View details for ${team.name}`">
                    <i class="bi bi-box-arrow-up-right me-1" aria-hidden="true"></i>
                    View details
                  </RouterLink>
                  <button
                    class="btn btn-sm btn-outline-secondary"
                    @click="saveToLibrary(team)"
                    :disabled="!isAuthenticated"
                    :title="!isAuthenticated ? 'Sign in to save teams to your library' : ''"
                    :aria-label="`Save ${team.name} to library`"
                  >
                    <i class="bi bi-journal-plus me-1" aria-hidden="true"></i>
                    Save in library
                  </button>
                </div>
              </article>

              <Pagination
                :current-page="currentPage"
                :total-items="teams.length"
                :items-per-page="itemsPerPage"
                @page-changed="handlePageChange"
              />
            </div>
          </div>
        </main>
      </div>
    </div>
  </div>
</template>

<script setup>
import { computed, onMounted, ref } from 'vue'
import { RouterLink, useRouter } from 'vue-router'
import CardTile from '../components/CardTile.vue'
import SpriteImage from '../components/SpriteImage.vue'
import Pagination from '../components/Pagination.vue'
import { store as selectionStore } from '../stores/selectionStore'
import { teamStore } from '../stores/teamStore'
import { authStore } from '../stores/authStore'
import { fetchRecommendations } from '../services/api'

const router = useRouter()
const loading = ref(false)
const refreshing = ref(false)
const currentPage = ref(1)
const itemsPerPage = 5

const isAuthenticated = computed(() => authStore.isAuthenticated())

const selectedCards = computed(() => {
  const selected = selectionStore.selectedIds
  return selectionStore.allCards.filter((card) => selected.has(card.id))
})

const teams = computed(() => selectionStore.recommendations?.teams || [])

const paginatedTeams = computed(() => {
  const start = (currentPage.value - 1) * itemsPerPage
  const end = start + itemsPerPage
  return teams.value.slice(start, end)
})

const percentage = (value) => {
  if (value === null || value === undefined) return 'N/A'
  return `${(value * 100).toFixed(1)}%`
}

const handlePageChange = (page) => {
  currentPage.value = page
  window.scrollTo({ top: 0, behavior: 'smooth' })
}

const remove = (id) => {
  selectionStore.remove(id)
}

const refreshRecommendations = async () => {
  if (!selectionStore.selectedIds.size) {
    router.push({ name: 'builder' })
    return
  }
  currentPage.value = 1
  refreshing.value = true
  try {
    const include = Array.from(selectionStore.selectedIds)
    const data = await fetchRecommendations(include)
    selectionStore.setRecommendations(data)
    data.teams?.forEach((team) => teamStore.upsert(team))
  } finally {
    refreshing.value = false
  }
}

const saveToLibrary = (team) => {
  if (!isAuthenticated.value) {
    router.push({ name: 'login', query: { redirect: router.currentRoute.value.fullPath } })
    return
  }
  teamStore.upsert(team)
}

const preview = (card) => {
  selectionStore.focusChampion(card)
}

onMounted(async () => {
  if (!selectionStore.recommendations) {
    if (!selectionStore.selectedIds.size) return
    loading.value = true
    try {
      const include = Array.from(selectionStore.selectedIds)
      const data = await fetchRecommendations(include)
      selectionStore.setRecommendations(data)
      data.teams?.forEach((team) => teamStore.upsert(team))
    } finally {
      loading.value = false
    }
  } else {
    teams.value.forEach((team) => teamStore.upsert(team))
  }
})
</script>

<style scoped>
.sticky-sidebar {
  position: sticky;
  top: 1rem;
  align-self: flex-start;
}
</style>
