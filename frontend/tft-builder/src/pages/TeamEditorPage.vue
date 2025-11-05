<template>
  <div class="page-white">
    <div class="container py-5">
      <div class="d-flex justify-content-between align-items-center mb-4">
        <div>
          <h1 class="h3 fw-bold mb-1">{{ pageTitle }}</h1>
          <p class="text-body-secondary mb-0">
            {{ isEdit ? 'Update the team composition details and champion lineup.' : 'Capture a custom comp with notes, win rate, and curated champions.' }}
          </p>
        </div>
        <RouterLink class="btn btn-outline-secondary" :to="{ name: isEdit ? 'team-detail' : 'teams', params: isEdit ? { id } : undefined }">
          <i class="bi bi-chevron-left me-1"></i>
          Back
        </RouterLink>
      </div>

      <div v-if="!authStore.isAuthenticated()" class="alert alert-warning">
        Please sign in to create a new team composition.
      </div>
      <div v-else-if="isEdit && !authStore.isAdmin()" class="alert alert-danger">
        Only administrators can update or delete existing team compositions.
      </div>

      <form class="row g-4" @submit.prevent="submit">
        <div class="col-lg-5">
          <div class="card shadow-sm border-0 mb-4">
            <div class="card-body">
              <div class="mb-3">
                <label class="form-label fw-semibold">Team name</label>
                <input v-model.trim="form.name" type="text" class="form-control" placeholder="e.g. Void Artillery" required />
              </div>

              <div class="mb-3">
                <label class="form-label fw-semibold">Short description</label>
                <textarea
                  v-model.trim="form.description"
                  class="form-control"
                  rows="3"
                  placeholder="What makes this comp work? Core carries, frontline, etc."
                  required
                ></textarea>
              </div>

              <div class="row g-3">
                <div class="col-sm-6">
                  <label class="form-label fw-semibold">Win rate (%)</label>
                  <input
                    v-model.number="form.winRate"
                    type="number"
                    min="0"
                    max="100"
                    step="0.1"
                    class="form-control"
                    placeholder="58.5"
                  />
                </div>
                <div class="col-sm-6">
                  <label class="form-label fw-semibold">Pick rate (%)</label>
                  <input
                    v-model.number="form.playRate"
                    type="number"
                    min="0"
                    max="100"
                    step="0.1"
                    class="form-control"
                    placeholder="12.1"
                  />
                </div>
              </div>

              <div class="mb-3 mt-3">
                <label class="form-label fw-semibold">Source / patch</label>
                <input
                  v-model.trim="form.source"
                  type="text"
                  class="form-control"
                  placeholder="e.g. Patch 14.1, TFT Meta Snapshot"
                />
              </div>

              <div class="mb-3">
                <label class="form-label fw-semibold">Strategy notes</label>
                <textarea
                  v-model.trim="form.notes"
                  class="form-control"
                  rows="4"
                  placeholder="Recommended items, positioning, augments, or pivot options."
                ></textarea>
              </div>
            </div>
          </div>

          <div class="card shadow-sm border-0">
            <div class="card-body">
              <h2 class="h6 fw-semibold mb-3">Summary</h2>
              <ul class="list-unstyled small text-body-secondary mb-0">
                <li>
                  <i class="bi bi-people me-2"></i>
                  {{ selectedCards.length }} champions selected
                </li>
                <li v-if="form.winRate">
                  <i class="bi bi-trophy me-2"></i>
                  Win rate {{ form.winRate }}%
                </li>
                <li v-if="form.playRate">
                  <i class="bi bi-graph-up me-2"></i>
                  Pick rate {{ form.playRate }}%
                </li>
              </ul>
            </div>
          </div>
        </div>

        <div class="col-lg-7">
          <div class="card shadow-sm border-0 mb-3">
            <div class="card-body">
              <div class="d-flex flex-column flex-md-row align-items-md-end gap-3 mb-3">
                <div class="flex-grow-1">
                  <label class="form-label small text-uppercase text-secondary fw-semibold">Filter roster</label>
                  <input
                    v-model="filter"
                    class="form-control"
                    type="search"
                    placeholder="Search by champion or trait"
                  />
                </div>
                <div>
                  <label class="form-label small text-uppercase text-secondary fw-semibold">Tier</label>
                  <select v-model="selectedTier" class="form-select">
                    <option value="">All tiers</option>
                    <option v-for="tier in tiers" :key="tier" :value="tier">
                      Tier {{ tier }}
                    </option>
                  </select>
                </div>
                <button type="button" class="btn btn-outline-secondary" @click="clearSelection">
                  Clear champions
                </button>
              </div>

              <div class="champion-grid-container">
                <div class="d-flex flex-wrap gap-3 pb-3">
                  <CardTile
                    v-for="card in filteredCards"
                    :key="card.id"
                    :card="card"
                    :selected="selectedIds.has(card.id)"
                    @toggle="toggle(card.id)"
                    @remove="toggle(card.id)"
                  />
                </div>
              </div>
            </div>
          </div>

          <div v-if="error" class="alert alert-danger">
            <i class="bi bi-exclamation-triangle me-2"></i>
            {{ error }}
          </div>

          <div class="d-flex justify-content-end gap-3">
            <button class="btn btn-outline-secondary" type="button" @click="resetForm" :disabled="saving">
              Reset
            </button>
            <button class="btn btn-primary" type="submit" :disabled="!canSubmit || saving">
              <span v-if="!saving">
                <i class="bi bi-check2-circle me-1"></i>
                {{ isEdit ? 'Save changes' : 'Create team' }}
              </span>
              <span v-else class="d-flex align-items-center gap-2">
                <span class="spinner-border spinner-border-sm"></span>
                Saving鈥?              </span>
            </button>
          </div>
        </div>
      </form>
    </div>
  </div>
</template>

<script setup>
import { computed, onMounted, reactive, ref, watch } from 'vue'
import { RouterLink, useRouter, useRoute } from 'vue-router'
import CardTile from '../components/CardTile.vue'
import { store as selectionStore } from '../stores/selectionStore'
import { teamStore } from '../stores/teamStore'
import { authStore } from '../stores/authStore'
import { fetchCards, fetchTeamComp, createTeamComp, updateTeamComp, extractErrorMessage } from '../services/api'

const props = defineProps({
  id: {
    type: String,
    default: null,
  },
})

const router = useRouter()
const route = useRoute()
const isEdit = computed(() => Boolean(props.id))
const id = computed(() => props.id)

const form = reactive({
  name: '',
  description: '',
  notes: '',
  source: '',
  winRate: null,
  playRate: null,
})

const filter = ref('')
const selectedTier = ref('')
const selectedIds = ref(new Set())
const saving = ref(false)
const error = ref(null)

const pageTitle = computed(() => (isEdit.value ? 'Edit team composition' : 'Create team composition'))

const cards = computed(() => selectionStore.allCards)
const tiers = computed(() =>
  [...new Set(cards.value.map((card) => card.tier))].sort((a, b) => a - b)
)

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

const selectedCards = computed(() =>
  cards.value.filter((card) => selectedIds.value.has(card.id))
)

const canSubmit = computed(() => {
  if (!authStore.isAuthenticated()) return false
  if (isEdit.value && !authStore.isAdmin()) return false
  return Boolean(form.name && form.description && selectedIds.value.size > 0)
})

const toggle = (championId) => {
  const clone = new Set(selectedIds.value)
  if (clone.has(championId)) clone.delete(championId)
  else clone.add(championId)
  selectedIds.value = clone
}

const clearSelection = () => {
  selectedIds.value = new Set()
}

const resetForm = () => {
  if (isEdit.value && teamStore.getById(Number(id.value))) {
    hydrate(teamStore.getById(Number(id.value)))
  } else {
    form.name = ''
    form.description = ''
    form.notes = ''
    form.source = ''
    form.winRate = null
    form.playRate = null
    clearSelection()
  }
}

const hydrate = (team) => {
  if (!team) return
  form.name = team.name || ''
  form.description = team.description || ''
  form.notes = team.notes || ''
  form.source = team.source || ''
  form.winRate = team.winRate ? Number((team.winRate * 100).toFixed(1)) : null
  form.playRate = team.playRate ? Number((team.playRate * 100).toFixed(1)) : null
  selectedIds.value = new Set(team.cards?.map((card) => card.id))
}

const submit = async () => {
  if (!authStore.isAuthenticated()) {
    error.value = "Please sign in to continue."
    router.push({ name: "login", query: { redirect: route.fullPath } })
    return
  }

  if (isEdit.value && !authStore.isAdmin()) {
    error.value = "Administrator privileges are required to modify existing team compositions."
    return
  }

  if (!canSubmit.value) {
    error.value = "Please complete all required fields and select at least one champion."
    return
  }

  saving.value = true
  error.value = null
  const payload = {
    ...form,
    championIds: Array.from(selectedIds.value),
  }
  try {
    const data = isEdit.value
      ? await updateTeamComp(id.value, payload)
      : await createTeamComp(payload)
    teamStore.upsert(data)
    router.push({ name: "team-detail", params: { id: data.id } })
  } catch (err) {
    error.value = extractErrorMessage(err)
    console.error(err)
  } finally {
    saving.value = false
  }
}


const ensureCardsLoaded = async () => {
  if (!selectionStore.allCards.length) {
    const all = await fetchCards()
    selectionStore.setAllCards(all)
  }
}

const ensureTeamLoaded = async () => {
  if (!isEdit.value) return
  let team = teamStore.getById(Number(id.value))
  if (!team) {
    team = await fetchTeamComp(id.value)
    teamStore.upsert(team)
  }
  hydrate(team)
}

onMounted(async () => {
  await ensureCardsLoaded()
  await ensureTeamLoaded()
})

watch(
  () => props.id,
  async () => {
    await ensureTeamLoaded()
  }
)
</script>

<style scoped>
.champion-grid-container {
  max-height: 500px;
  overflow-y: auto;
  overflow-x: hidden;
  padding: 0.5rem 0.25rem;
  margin: -0.5rem -0.25rem 0;
}

.champion-grid-container::-webkit-scrollbar {
  width: 8px;
}

.champion-grid-container::-webkit-scrollbar-track {
  background: rgba(0, 0, 0, 0.05);
  border-radius: 4px;
}

.champion-grid-container::-webkit-scrollbar-thumb {
  background: #ffc107;
  border-radius: 4px;
}

.champion-grid-container::-webkit-scrollbar-thumb:hover {
  background: #ffb300;
}

/* Remove box background from champion names */
.champion-grid-container :deep(.tft-card-name) {
  background: none !important;
  box-shadow: none !important;
  padding: 0 !important;
  color: #1f2638 !important;
  font-size: 0.85rem !important;
}
</style>

