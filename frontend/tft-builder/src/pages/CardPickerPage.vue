<template>
  <div class="page-dark-hero d-flex flex-column">
    <div class="container py-4 flex-grow-1 d-flex flex-column">
      <div class="row align-items-center g-3 mb-3">
        <div class="col-lg-8">
          <h1 class="text-light fw-bold mb-0">Champion Synergy Search</h1>
        </div>
        <div class="col-lg-4 text-lg-end">
          <button
            class="btn btn-outline-light btn-sm"
            :disabled="selectedCount === 0"
            @click="clearSelection"
          >
            <i class="bi bi-eraser me-1"></i>
            Clear selection
          </button>
        </div>
      </div>

      <div class="glass-search mb-3">
        <div class="d-flex align-items-center justify-content-between mb-2">
          <label class="form-label text-uppercase small text-secondary fw-semibold mb-0">
            Selected champions
          </label>
          <div class="d-flex gap-2">
            <span class="badge bg-secondary-subtle text-secondary-emphasis small">
              {{ selectedCount }} / {{ cards.length }}
            </span>
            <span v-if="recommendationsCount > 0" class="badge bg-warning-subtle text-warning-emphasis small">
              {{ recommendationsCount }} comps
            </span>
          </div>
        </div>
        <div class="selected-champions-container">
          <div v-if="selectedCount === 0" class="empty-selection-placeholder">
            <i class="bi bi-hand-index me-2"></i>
            Click champions below to add them to your search
          </div>
          <div v-else class="d-flex flex-wrap gap-2 align-items-center">
            <span
              v-for="card in selectedCards"
              :key="card.id"
              class="champion-tag"
            >
              <span class="champion-tag-name">{{ card.name }}</span>
              <button
                class="champion-tag-remove"
                @click="remove(card.id)"
                type="button"
                :aria-label="`Remove ${card.name}`"
              >
                <i class="bi bi-x"></i>
              </button>
            </span>
            <button
              class="btn btn-warning text-dark fw-semibold btn-sm ms-auto"
              :disabled="loading"
              @click="onSearch"
            >
              <span v-if="!loading">
                <i class="bi bi-search me-1"></i>
                Find {{ selectedCount }} comps
              </span>
              <span v-else class="d-flex align-items-center gap-2">
                <span class="spinner-border spinner-border-sm"></span>
                Searching…
              </span>
            </button>
          </div>
        </div>
      </div>

      <div class="row g-4 flex-grow-1 overflow-hidden">
        <div class="col-lg-3 d-flex flex-column">
          <div class="card shadow-sm bg-light border-0 filter-sidebar">
            <div class="card-body">
              <h2 class="h6 text-uppercase text-dark fw-semibold mb-3">
                Filter champions
              </h2>
              <div class="mb-3">
                <label class="form-label small text-dark">Search</label>
                <input
                  v-model="filter"
                  class="form-control form-control-sm"
                  type="search"
                  placeholder="Name or trait"
                />
              </div>
              <div class="mb-3">
                <label class="form-label small text-dark">Tier</label>
                <select v-model="selectedTier" class="form-select form-select-sm">
                  <option value="">All tiers</option>
                  <option v-for="tier in tiers" :key="tier" :value="tier">
                    Tier {{ tier }}
                  </option>
                </select>
              </div>
              <div class="text-dark small">
                Click a champion to toggle it in your search query. Use the × badge on a selected card to remove it quickly.
              </div>
            </div>
          </div>
        </div>
        <div class="col-lg-9 d-flex flex-column overflow-hidden">
          <div class="section-title mb-3 text-uppercase">Champion roster</div>
          <div class="champion-grid-container">
            <div class="d-flex flex-wrap gap-3" style="padding: 0.5rem;">
              <CardTile
                v-for="card in filteredCards"
                :key="card.id"
                :card="card"
                :selected="selectedSet.has(card.id)"
                @toggle="toggle(card.id)"
                @remove="remove(card.id)"
              />
            </div>
            <div v-if="filteredCards.length === 0" class="alert alert-secondary mt-4">
              No champions match the current filters. Try adjusting the tier or search query.
            </div>
          </div>
        </div>
      </div>

      <div v-if="error" class="alert alert-danger mt-4 mb-0">
        <i class="bi bi-exclamation-triangle me-2"></i>
        {{ error }}
      </div>
    </div>
  </div>
</template>

<script setup>
import { onMounted, computed, ref } from 'vue'
import { useRouter } from 'vue-router'
import CardTile from '../components/CardTile.vue'
import { store as selectionStore } from '../stores/selectionStore'
import { fetchCards, fetchRecommendations } from '../services/api'

const router = useRouter()
const loading = ref(false)
const error = ref(null)
const filter = ref('')
const selectedTier = ref('')

const cards = computed(() => selectionStore.allCards)
const selectedSet = computed(() => selectionStore.selectedIds)
const selectedCards = computed(() =>
  cards.value.filter((card) => selectedSet.value.has(card.id))
)
const selectedNames = computed(() =>
  selectedCards.value.map((card) => card.name)
)
const selectedCount = computed(() => selectedSet.value.size)
const tiers = computed(() =>
  [...new Set(cards.value.map((card) => card.tier))].sort((a, b) => a - b)
)
const recommendationsCount = computed(() => selectionStore.recommendations?.teams?.length || 0)

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

const toggle = (id) => {
  selectionStore.toggle(id)
}

const remove = (id) => {
  selectionStore.remove(id)
}

const clearSelection = () => {
  selectionStore.clearSelection()
}

const onSearch = async () => {
  if (selectedSet.value.size === 0) return
  loading.value = true
  error.value = null
  try {
    const include = Array.from(selectedSet.value)
    const data = await fetchRecommendations(include)
    selectionStore.setRecommendations(data)
    router.push({ name: 'recommendations' })
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
.glass-search {
  background: rgba(12, 16, 30, 0.6);
  border-radius: 18px;
  padding: 2rem;
  border: 1px solid rgba(255, 255, 255, 0.08);
  backdrop-filter: blur(12px);
}

.selected-champions-container {
  min-height: 60px;
  padding: 0.75rem;
  background: rgba(255, 255, 255, 0.05);
  border: 2px dashed rgba(255, 193, 7, 0.3);
  border-radius: 12px;
  transition: all 0.3s ease;
}

.selected-champions-container:has(.champion-tag) {
  background: rgba(255, 193, 7, 0.08);
  border-color: rgba(255, 193, 7, 0.5);
  border-style: solid;
}

.empty-selection-placeholder {
  color: rgba(255, 255, 255, 0.4);
  font-size: 0.95rem;
  text-align: center;
  padding: 0.5rem;
}

.champion-tag {
  display: inline-flex;
  align-items: center;
  gap: 0.5rem;
  background: linear-gradient(135deg, #ffc107 0%, #ffb300 100%);
  color: #1a1a2e;
  padding: 0.4rem 0.4rem 0.4rem 0.75rem;
  border-radius: 20px;
  font-size: 0.9rem;
  font-weight: 600;
  box-shadow: 0 2px 8px rgba(255, 193, 7, 0.3);
  transition: all 0.2s ease;
  animation: slideIn 0.3s ease;
}

@keyframes slideIn {
  from {
    opacity: 0;
    transform: scale(0.8);
  }
  to {
    opacity: 1;
    transform: scale(1);
  }
}

.champion-tag:hover {
  box-shadow: 0 4px 12px rgba(255, 193, 7, 0.5);
  transform: translateY(-1px);
}

.champion-tag-name {
  line-height: 1;
}

.champion-tag-remove {
  background: rgba(0, 0, 0, 0.2);
  border: none;
  border-radius: 50%;
  width: 22px;
  height: 22px;
  display: flex;
  align-items: center;
  justify-content: center;
  cursor: pointer;
  transition: all 0.2s ease;
  color: #1a1a2e;
  padding: 0;
}

.champion-tag-remove:hover {
  background: rgba(220, 53, 69, 0.9);
  color: white;
  transform: rotate(90deg);
}

.champion-tag-remove i {
  font-size: 1.1rem;
  line-height: 1;
}

.filter-sidebar {
  height: fit-content;
  position: sticky;
  top: 1rem;
}

.champion-grid-container {
  overflow-y: auto;
  overflow-x: hidden;
  flex: 1;
  padding-right: 0.5rem;
  padding-top: 1rem;
  padding-bottom: 1rem;
  max-height: calc(100vh - 280px);
  min-height: 500px;
}

.champion-grid-container::-webkit-scrollbar {
  width: 8px;
}

.champion-grid-container::-webkit-scrollbar-track {
  background: rgba(255, 255, 255, 0.1);
  border-radius: 4px;
}

.champion-grid-container::-webkit-scrollbar-thumb {
  background: rgba(255, 193, 7, 0.5);
  border-radius: 4px;
}

.champion-grid-container::-webkit-scrollbar-thumb:hover {
  background: rgba(255, 193, 7, 0.7);
}
</style>
