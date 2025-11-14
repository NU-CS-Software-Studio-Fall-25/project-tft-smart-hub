<template>
  <div class="page-white">
    <a href="#main-content" class="skip-link">Skip to main content</a>

    <!-- Main Layout -->
    <main id="main-content" class="builder-layout">
      <div class="container-fluid px-3 py-3">
        <div class="row g-3">
          
          <!-- LEFT SIDE: Champion Selection Region -->
          <aside class="col-lg-5 col-xl-4">
            <div class="champion-selection-region">
              
              <!-- Filter Controls -->
              <div class="filter-controls mb-2">
                <div class="mb-2">
                  <input
                    v-model="filter"
                    class="form-control form-control-sm"
                    type="search"
                    placeholder="🔍 Search..."
                    aria-label="Search champions"
                  />
                </div>
                <div class="d-flex gap-2">
                  <select v-model="selectedTier" class="form-select form-select-sm flex-grow-1" aria-label="Filter by tier">
                    <option value="">All tiers</option>
                    <option v-for="tier in tiers" :key="tier" :value="tier">
                      Tier {{ tier }}
                    </option>
                  </select>
                  <button 
                    type="button" 
                    class="btn btn-sm btn-outline-secondary" 
                    @click="clearSelection" 
                    :disabled="selectedCount === 0"
                    title="Clear all"
                    aria-label="Clear all selections"
                  >
                    <i class="bi bi-x-circle"></i>
                  </button>
                </div>
              </div>

              <!-- Champion Grid with Scrollbar -->
              <div class="champion-grid-scroll">
                <div class="champion-grid">
                  <CardTile
                    v-for="card in filteredCards"
                    :key="card.id"
                    :card="card"
                    :selected="selectedSet.has(card.id)"
                    :size="70"
                    @toggle="toggle(card.id)"
                    @remove="remove(card.id)"
                  />
                </div>
                <div v-if="filteredCards.length === 0" class="empty-state">
                  <i class="bi bi-search"></i>
                  <p class="small mb-0">No matches</p>
                </div>
              </div>

              <!-- Selection Counter -->
              <div class="selection-counter mt-2">
                <strong>{{ selectedCount }}</strong> / {{ cards.length }} selected
              </div>
            </div>
          </aside>

          <!-- RIGHT SIDE: Selected Champions + Results -->
          <div class="col-lg-7 col-xl-8">
            
            <!-- Show selection and control buttons region -->
            <section class="control-region mb-3" aria-labelledby="selected-heading">
              <div class="card border-0 shadow-sm">
                <div class="card-body py-2">
                  <!-- Empty State -->
                  <div v-if="selectedCount === 0" class="text-center text-muted small py-2">
                    <i class="bi bi-arrow-left me-1"></i>
                    Select champions to start
                  </div>

                  <!-- Selected Champions Display -->
                  <div v-else class="d-flex align-items-center justify-content-between gap-3">
                    <div class="d-flex flex-wrap gap-2 flex-grow-1">
                      <div 
                        v-for="card in selectedCards" 
                        :key="card.id"
                        class="champion-icon-badge-small"
                        :title="card.name"
                        @click="remove(card.id)"
                      >
                        <SpriteImage
                          v-if="card.sprite"
                          :sprite="card.sprite"
                          :image-url="card.imageUrl"
                          :alt="card.name"
                          :size="60"
                        />
                        <span v-else class="champion-icon-text-small">{{ card.name.charAt(0) }}</span>
                        <span class="champion-icon-remove-small">
                          <i class="bi bi-x"></i>
                        </span>
                      </div>
                    </div>

                    <!-- Search Button -->
                    <div class="d-flex gap-2">
                      <button
                        type="button"
                        class="btn btn-sm btn-outline-secondary"
                        @click="clearSelection"
                        :disabled="loading"
                      >
                        Clear
                      </button>
                      <button
                        type="button"
                        class="btn btn-primary btn-sm"
                        @click="onSearch"
                        :disabled="loading || selectedCount === 0"
                      >
                        <span v-if="!loading">
                          <i class="bi bi-search me-1"></i>
                          Search ({{ selectedCount }})
                        </span>
                        <span v-else>
                          <span class="spinner-border spinner-border-sm me-1"></span>
                          Searching...
                        </span>
                      </button>
                    </div>
                  </div>
                </div>
              </div>
            </section>

            <!-- Show result region -->
            <section class="result-region">
              <!-- Loading State -->
              <div v-if="loading" class="text-center py-4">
                <div class="spinner-border text-primary mb-2" role="status">
                  <span class="visually-hidden">Loading...</span>
                </div>
                <p class="text-muted small mb-0">Searching...</p>
              </div>

              <!-- Empty State (No Search Yet) -->
              <div v-else-if="!hasSearched" class="text-center py-4 text-muted">
                <i class="bi bi-arrow-up fs-3 mb-2"></i>
                <p class="small mb-0">Search to see results</p>
              </div>

              <!-- No Results -->
              <div v-else-if="teams.length === 0" class="text-center py-4">
                <i class="bi bi-emoji-frown fs-3 text-muted mb-2"></i>
                <p class="text-muted small mb-0">No teams found</p>
              </div>

              <!-- Results List -->
              <div v-else>

                <article
                  v-for="team in paginatedTeams"
                  :key="team.id"
                  class="card mb-2 shadow-sm border-0 team-result-card"
                >
                  <div class="card-header d-flex align-items-center justify-content-between bg-light py-2">
                    <h3 class="h6 fw-bold mb-0">{{ team.name }}</h3>
                    <div class="d-flex gap-2">
                      <span class="badge bg-success small" v-if="team.winRate">
                        {{ percentage(team.winRate) }} WR
                      </span>
                      <span class="badge bg-primary small" v-if="team.playRate">
                        {{ percentage(team.playRate) }} PR
                      </span>
                      <span class="badge bg-info small">
                        {{ team.meta?.matchCount || 0 }} games
                      </span>
                    </div>
                  </div>

                  <div class="card-body py-2">
                    <!-- Champions -->
                    <div class="d-flex flex-wrap gap-2">
                      <div
                        v-for="card in team.cards"
                        :key="`${team.id}-${card.id}`"
                        class="team-champion-tile-compact"
                        :class="{ 'highlight': selectedSet.has(card.id) }"
                        :title="card.name"
                      >
                        <SpriteImage
                          :sprite="card.sprite"
                          :image-url="card.imageUrl"
                          :alt="card.name"
                          :size="44"
                        />
                      </div>
                    </div>
                  </div>

                  <div class="card-footer bg-white d-flex justify-content-between align-items-center py-2">
                    <RouterLink 
                      class="btn btn-sm btn-outline-primary" 
                      :to="{ name: 'team-detail', params: { id: team.id } }"
                    >
                      <i class="bi bi-eye me-1"></i>
                      Details
                    </RouterLink>
                    <button
                      class="btn btn-sm" 
                      :class="team.isFavorited ? 'btn-warning' : 'btn-outline-warning'"
                      @click="toggleFavorite(team)"
                      :title="team.isFavorited ? 'Remove from favorites' : 'Add to favorites'"
                    >
                      <i :class="team.isFavorited ? 'bi bi-star-fill' : 'bi bi-star'"></i>
                      {{ team.isFavorited ? 'Favorited' : 'Favorite' }}
                    </button>
                  </div>
                </article>

                <!-- Pagination -->
                <Pagination
                  v-if="teams.length > itemsPerPage"
                  :current-page="currentPage"
                  :total-items="teams.length"
                  :items-per-page="itemsPerPage"
                  @page-changed="handlePageChange"
                />
              </div>

              <!-- Error Message -->
              <div v-if="error" class="alert alert-danger mt-3">
                <i class="bi bi-exclamation-triangle me-2"></i>
                {{ error }}
              </div>
            </section>

          </div>
        </div>
      </div>
    </main>
  </div>
</template>

<script setup>
import { onMounted, computed, ref } from 'vue'
import { RouterLink, useRouter } from 'vue-router'
import CardTile from '../components/CardTile.vue'
import SpriteImage from '../components/SpriteImage.vue'
import Pagination from '../components/Pagination.vue'
import { store as selectionStore } from '../stores/selectionStore'
import { teamStore } from '../stores/teamStore'
import { authStore } from '../stores/authStore'
import { fetchCards, fetchRecommendations, favoriteTeam, unfavoriteTeam } from '../services/api'

const router = useRouter()
const loading = ref(false)
const error = ref(null)
const filter = ref('')
const selectedTier = ref('')
const hasSearched = ref(false)
const currentPage = ref(1)
const itemsPerPage = 5

const isAuthenticated = computed(() => authStore.isAuthenticated())
const cards = computed(() => selectionStore.allCards)
const selectedSet = computed(() => selectionStore.selectedIds)
const selectedCards = computed(() =>
  cards.value.filter((card) => selectedSet.value.has(card.id))
)
const selectedCount = computed(() => selectedSet.value.size)
const tiers = computed(() =>
  [...new Set(cards.value.map((card) => card.tier))].sort((a, b) => a - b)
)
const teams = computed(() => selectionStore.recommendations?.teams || [])

const paginatedTeams = computed(() => {
  const start = (currentPage.value - 1) * itemsPerPage
  const end = start + itemsPerPage
  return teams.value.slice(start, end)
})

const sortedCards = computed(() =>
  [...cards.value].sort((a, b) => {
    if (a.tier === b.tier) return a.name.localeCompare(b.name)
    return a.tier - b.tier
  })
)

const filteredCards = computed(() => {
  const term = filter.value.trim().toLowerCase()
  const tierFilter = selectedTier.value === '' ? null : Number(selectedTier.value)

  return sortedCards.value.filter((card) => {
    const matchesTier = tierFilter === null || card.tier === tierFilter
    const matchesTerm =
      !term ||
      card.name.toLowerCase().includes(term) ||
      (Array.isArray(card.traits) && card.traits.some((trait) => trait.toLowerCase().includes(term)))
    return matchesTier && matchesTerm
  })
})

const percentage = (value) => {
  if (value === null || value === undefined) return 'N/A'
  return `${(value * 100).toFixed(1)}%`
}

const toggle = (id) => {
  selectionStore.toggle(id)
}

const remove = (id) => {
  selectionStore.remove(id)
}

const clearSelection = () => {
  selectionStore.clearSelection()
}

const handlePageChange = (page) => {
  currentPage.value = page
  window.scrollTo({ top: 0, behavior: 'smooth' })
}

const saveToLibrary = (team) => {
  if (!isAuthenticated.value) {
    router.push({ name: 'login', query: { redirect: router.currentRoute.value.fullPath } })
    return
  }
  teamStore.upsert(team)
  // Could add a toast notification here
}

const toggleFavorite = async (team) => {
  if (!isAuthenticated.value) {
    router.push({ name: 'login', query: { redirect: router.currentRoute.value.fullPath } })
    return
  }

  try {
    if (team.isFavorited) {
      const result = await unfavoriteTeam(team.id)
      team.isFavorited = result.favorited
      team.favoritesCount = result.favoritesCount
    } else {
      const result = await favoriteTeam(team.id)
      team.isFavorited = result.favorited
      team.favoritesCount = result.favoritesCount
    }
  } catch (error) {
    console.error('[CardPickerPage] Failed to toggle favorite:', error)
    alert('Failed to update favorite status')
  }
}

const onSearch = async () => {
  if (selectedSet.value.size === 0) return
  
  loading.value = true
  error.value = null
  currentPage.value = 1
  
  try {
    const include = Array.from(selectedSet.value)
    const data = await fetchRecommendations(include)
    selectionStore.setRecommendations(data)
    hasSearched.value = true
    
    // Store teams in teamStore for later use
    data.teams?.forEach((team) => teamStore.upsert(team))
  } catch (err) {
    error.value = 'Failed to fetch recommendations. Please try again.'
    console.error(err)
  } finally {
    loading.value = false
  }
}

onMounted(async () => {
  if (!selectionStore.allCards.length) {
    const all = await fetchCards()
    selectionStore.setAllCards(all)
  }
})
</script>

<style scoped>
/* Skip Link for Accessibility */
.skip-link {
  position: absolute;
  top: -40px;
  left: 0;
  background: #000;
  color: #fff;
  padding: 8px 16px;
  text-decoration: none;
  z-index: 9999;
  border-radius: 0 0 4px 0;
}

.skip-link:focus {
  top: 0;
}

/* Navigation Tabs Region */
.navigation-tabs-region {
  background: linear-gradient(135deg, #1a1a2e 0%, #16213e 100%);
  color: white;
  border-bottom: 3px solid #ffc107;
}

.navigation-tabs-region h1 {
  color: white;
}

.navigation-tabs-region .text-body-secondary {
  color: rgba(255, 255, 255, 0.7) !important;
}

/* Builder Layout */
.builder-layout {
  min-height: calc(100vh - 200px);
}

/* Region Titles */
.region-title {
  font-size: 1.1rem;
  font-weight: 600;
  color: #1a1a2e;
  margin-bottom: 1rem;
  padding-bottom: 0.5rem;
  border-bottom: 2px solid #ffc107;
}

/* Champion Selection Region */
.champion-selection-region {
  background: #f8f9fa;
  border-radius: 8px;
  padding: 1.5rem;
  height: 100%;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
}

.filter-controls {
  background: white;
  padding: 1rem;
  border-radius: 6px;
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
}

.champion-grid-scroll {
  max-height: 650px;
  overflow-y: auto;
  overflow-x: hidden;
  background: white;
  border-radius: 6px;
  padding: 1.5rem 2rem 0.75rem 0.25rem;
  box-shadow: inset 0 1px 3px rgba(0, 0, 0, 0.1);
}

.champion-grid-scroll::-webkit-scrollbar {
  width: 8px;
}

.champion-grid-scroll::-webkit-scrollbar-track {
  background: #f1f1f1;
  border-radius: 4px;
}

.champion-grid-scroll::-webkit-scrollbar-thumb {
  background: #ffc107;
  border-radius: 4px;
}

.champion-grid-scroll::-webkit-scrollbar-thumb:hover {
  background: #ffb300;
}

.champion-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(60px, 1fr));
  gap: 0.4rem;
}

.empty-state {
  text-align: center;
  padding: 2rem 1rem;
  color: #6c757d;
}

.empty-state i {
  font-size: 2rem;
  margin-bottom: 0.5rem;
  display: block;
}

.empty-state p {
  font-size: 0.875rem;
}

.selection-counter {
  background: white;
  padding: 0.75rem 1rem;
  border-radius: 6px;
  text-align: center;
  font-size: 0.95rem;
  color: #495057;
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
}

/* Control Region */
.control-region .card {
  background: #f8f9fa;
}

.control-region .card-body {
  padding: 0.75rem;
}

.champion-icon-badge-small {
  position: relative;
  width: 60px;
  height: 60px;
  border-radius: 6px;
  overflow: hidden;
  border: 2px solid #ffc107;
  background: #1a1a2e;
  cursor: pointer;
  transition: all 0.2s;
  flex-shrink: 0;
}

.champion-icon-badge-small:hover {
  transform: scale(1.1);
  box-shadow: 0 2px 8px rgba(255, 193, 7, 0.4);
}

.champion-icon-badge-small:hover .champion-icon-remove-small {
  opacity: 1;
}

.champion-icon-text-small {
  width: 100%;
  height: 100%;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 1.2rem;
  font-weight: bold;
  color: #ffc107;
}

.champion-icon-remove-small {
  position: absolute;
  top: 0;
  right: 0;
  bottom: 0;
  left: 0;
  background: rgba(220, 53, 69, 0.9);
  display: flex;
  align-items: center;
  justify-content: center;
  color: white;
  font-size: 1rem;
  opacity: 0;
  transition: opacity 0.2s;
}

/* Result Region */
.result-region {
  background: #f8f9fa;
  border-radius: 8px;
  padding: 1rem;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
}

.team-result-card {
  transition: all 0.2s;
}

.team-result-card:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15) !important;
}

.team-champion-tile-compact {
  position: relative;
  width: 44px;
  height: 44px;
  border-radius: 6px;
  overflow: hidden;
  border: 2px solid #dee2e6;
  transition: all 0.2s;
  flex-shrink: 0;
}

.team-champion-tile-compact.highlight {
  border-color: #ffc107;
  box-shadow: 0 0 8px rgba(255, 193, 7, 0.5);
}

.team-champion-tile-compact:hover {
  transform: scale(1.05);
}

/* Responsive adjustments */
@media (max-width: 991.98px) {
  .champion-grid-scroll {
    max-height: 500px;
  }
  
  .champion-grid {
    grid-template-columns: repeat(auto-fill, minmax(55px, 1fr));
    gap: 0.3rem;
  }
}

@media (max-width: 575.98px) {
  .champion-grid {
    grid-template-columns: repeat(auto-fill, minmax(50px, 1fr));
    gap: 0.2rem;
  }
  
  .champion-icon-badge-small {
    width: 60px;
    height: 60px;
  }
  
  .team-champion-tile-compact {
    width: 40px;
    height: 40px;
  }
  
  .result-region {
    padding: 0.75rem;
  }
}

/* Remove default CardTile styles */
.champion-grid :deep(.tft-card-name) {
  background: none !important;
  box-shadow: none !important;
  padding: 0 !important;
  color: #1f2638 !important;
  font-size: 0.75rem !important;
  margin-top: 0.25rem;
}
</style>
