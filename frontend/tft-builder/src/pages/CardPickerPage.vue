<template>
  <div class="page-dark-hero d-flex flex-column">
    <div class="container py-5 flex-grow-1 d-flex flex-column">
      <div class="row align-items-center g-3 mb-4">
        <div class="col-lg-8">
          <h1 class="text-light fw-bold mb-1">Champion Synergy Search</h1>
          <p class="text-white-50 mb-0">
            Choose any combination of champions and discover curated team comps that include them.
          </p>
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

      <div class="glass-search mb-4">
        <label class="form-label text-uppercase small text-secondary fw-semibold mb-2">
          Selected champions
        </label>
        <div class="input-group input-group-lg">
          <span class="input-group-text bg-transparent text-secondary">
            <i class="bi bi-people"></i>
          </span>
          <input
            class="form-control"
            :value="selectedNames.join(', ')"
            placeholder="Select champions below to build your search query"
            readonly
          />
          <button
            class="btn btn-warning text-dark fw-semibold"
            :disabled="loading || selectedCount === 0"
            @click="onSearch"
          >
            <span v-if="!loading">
              <i class="bi bi-search me-1"></i>
              Find comps
            </span>
            <span v-else class="d-flex align-items-center gap-2">
              <span class="spinner-border spinner-border-sm"></span>
              Searching…
            </span>
          </button>
        </div>
        <div class="d-flex flex-wrap gap-2 mt-3">
          <span class="badge bg-secondary-subtle text-secondary-emphasis">
            Selected {{ selectedCount }} / {{ cards.length }}
          </span>
          <span class="badge bg-secondary-subtle text-secondary-emphasis">
            Matching comps cached: {{ recommendationsCount }}
          </span>
        </div>
      </div>

      <div class="row g-4 flex-grow-1">
        <div class="col-lg-3">
          <div class="card h-100 shadow-sm bg-dark-subtle border-0">
            <div class="card-body">
              <h2 class="h6 text-uppercase text-secondary fw-semibold mb-3">
                Filter champions
              </h2>
              <div class="mb-3">
                <label class="form-label small text-secondary">Search</label>
                <input
                  v-model="filter"
                  class="form-control form-control-sm"
                  type="search"
                  placeholder="Name or trait"
                />
              </div>
              <div class="mb-3">
                <label class="form-label small text-secondary">Tier</label>
                <select v-model="selectedTier" class="form-select form-select-sm">
                  <option value="">All tiers</option>
                  <option v-for="tier in tiers" :key="tier" :value="tier">
                    Tier {{ tier }}
                  </option>
                </select>
              </div>
              <div class="text-white-50 small">
                Click a champion to toggle it in your search query. Use the × badge on a selected card to remove it quickly.
              </div>
            </div>
          </div>
        </div>
        <div class="col-lg-9">
          <div class="section-title mb-3 text-uppercase">Champion roster</div>
          <div class="d-flex flex-wrap gap-3">
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
const selectedNames = computed(() =>
  cards.value.filter((card) => selectedSet.value.has(card.id)).map((card) => card.name)
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
</style>
