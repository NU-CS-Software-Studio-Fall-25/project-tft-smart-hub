<template>
  <div class="page-white">
    <div class="container py-5">
      <div class="d-flex flex-column flex-md-row justify-content-between align-items-md-center gap-3 mb-4">
        <div>
          <h1 class="h3 fw-bold mb-1">Team composition library</h1>
          <p class="mb-0 text-body-secondary">
            Review curated comps, compare win rates, and jump straight into the details.
          </p>
        </div>
        <RouterLink class="btn btn-primary" :to="createRoute">
          <i class="bi bi-plus-circle me-1"></i>
          Add a new team
        </RouterLink>
      </div>

      <div class="row align-items-center g-3 mb-4">
        <div class="col-lg-6">
          <div class="input-group shadow-sm">
            <span class="input-group-text bg-white text-secondary">
              <i class="bi bi-search"></i>
            </span>
            <input
              v-model="searchTerm"
              class="form-control"
              type="search"
              placeholder="Search compositions or champion names"
            />
          </div>
        </div>
        <div class="col-lg-6 text-lg-end text-body-secondary small">
          Showing {{ displayedCount }} of {{ totalCount }} team comps
        </div>
      </div>

      <div v-if="loading && !teams.length" class="py-5 text-center">
        <div class="spinner-border"></div>
        <div class="mt-3 text-body-secondary">Loading team compositions...</div>
      </div>

      <div v-else>
        <div v-if="teams.length === 0" class="alert alert-info">
          <template v-if="searchActive">
            No team compositions match "{{ searchTerm }}". Try different keywords or traits.
          </template>
          <template v-else>
            No team compositions saved yet. Create your first comp via the
            <RouterLink to="/teams/new">team builder</RouterLink>.
          </template>
        </div>

        <template v-else>
          <div class="row g-4 row-cols-1 row-cols-lg-2 mb-4">
            <div v-for="team in paginatedTeams" :key="team.id" class="col">
              <div class="team-card card h-100 shadow-sm border-0">
                <div class="card-body d-flex flex-column">
                  <div class="team-card-header d-flex justify-content-between align-items-start mb-3">
                    <div class="pe-3 flex-grow-1">
                      <h2 class="h4 fw-semibold mb-2">{{ team.name }}</h2>
                      <div class="team-card-tags" v-if="team.set || unitCount(team)">
                        <span v-if="team.set" class="meta-pill">{{ formatSet(team.set) }}</span>
                        <span v-if="unitCount(team)" class="meta-pill">{{ unitCount(team) }} units</span>
                      </div>
                      <ul
                        v-if="descriptionSegments(team).length"
                        class="team-description-list text-body-secondary small mb-0"
                      >
                        <li v-for="segment in descriptionSegments(team)" :key="segment.label || segment.value">
                          <span v-if="segment.label" class="team-description-label">{{ segment.label }}</span>
                          <span class="team-description-value">{{ summarize(segment.value, 120) }}</span>
                        </li>
                      </ul>
                      <p v-else class="text-body-secondary small mb-0">
                        {{ summarize(team.description, 140) }}
                      </p>
                    </div>
                    <span class="badge bg-success-subtle text-success-emphasis fs-6 win-pill">
                      Win {{ percentage(team.winRate) }}
                    </span>
                  </div>

                  <div class="team-card-strip horizontal-scroll d-flex gap-3 pb-2">
                    <div
                      v-for="card in team.cards"
                      :key="`${team.id}-${card.id}`"
                      class="mini-card"
                      :title="card.name"
                      @contextmenu.prevent="preview(card)"
                    >
                      <SpriteImage
                        :sprite="card.sprite"
                        :image-url="card.imageUrl"
                        :alt="card.name"
                        :size="72"
                        class-name="mini-card-img"
                      />
                    </div>
                  </div>

                  <div class="team-meta-row d-flex flex-wrap gap-3 align-items-center mt-4 small text-body-secondary">
                    <div class="meta-item">
                      <i class="bi bi-people"></i>
                      <div>
                        <div class="meta-label">Play rate</div>
                        <div class="meta-value">{{ percentage(team.playRate) }}</div>
                      </div>
                    </div>
                    <div class="meta-item">
                      <i class="bi bi-grid-3x3-gap"></i>
                      <div>
                        <div class="meta-label">Board size</div>
                        <div class="meta-value">{{ unitCount(team) }} units</div>
                      </div>
                    </div>
                    <div v-if="avgPlacement(team)" class="meta-item">
                      <i class="bi bi-trophy"></i>
                      <div>
                        <div class="meta-label">Avg placement</div>
                        <div class="meta-value">{{ avgPlacement(team) }}</div>
                      </div>
                    </div>
                    <div v-if="playCount(team)" class="meta-item">
                      <i class="bi bi-controller"></i>
                      <div>
                        <div class="meta-label">Games tracked</div>
                        <div class="meta-value">{{ playCount(team) }}</div>
                      </div>
                    </div>
                    <div class="meta-item meta-source" v-if="team.source">
                      <div class="meta-label text-uppercase">Source</div>
                      <div class="meta-value fw-semibold">{{ team.source }}</div>
                    </div>
                  </div>
                </div>
                <div class="card-footer bg-white d-flex justify-content-between gap-3">
                  <RouterLink
                    class="btn btn-sm btn-outline-primary flex-grow-1"
                    :to="{ name: 'team-detail', params: { id: team.id } }"
                  >
                    View details
                  </RouterLink>
                  <button v-if="isAdmin" class="btn btn-sm btn-outline-danger" @click="removeTeam(team.id)">
                    <i class="bi bi-trash"></i>
                  </button>
                </div>
              </div>
            </div>
          </div>

          <Pagination
            :current-page="currentPage"
            :total-items="teams.length"
            :items-per-page="itemsPerPage"
            @page-changed="handlePageChange"
          />
        </template>
      </div>
    </div>
  </div>
</template>

<script setup>
import { computed, onMounted, ref, watch } from 'vue'
import { RouterLink } from 'vue-router'
import SpriteImage from '../components/SpriteImage.vue'
import Pagination from '../components/Pagination.vue'
import { authStore } from '../stores/authStore'
import { store as selectionStore } from '../stores/selectionStore'
import { fetchTeamComps, deleteTeamComp } from '../services/api'
import { teamStore } from '../stores/teamStore'
import { extractDescriptionSegments } from '../utils/descriptionUtils'

const loading = ref(false)
const searchTerm = ref('')
const currentPage = ref(1)
const itemsPerPage = 5
const hasMounted = ref(false)

const allTeams = computed(() => teamStore.list)

const filteredTeams = computed(() => {
  if (!searchTerm.value.trim()) {
    return allTeams.value
  }
  const query = searchTerm.value.trim().toLowerCase()
  return allTeams.value.filter((team) => {
    const matchesName = team.name?.toLowerCase().includes(query)
    const matchesDescription = team.description?.toLowerCase().includes(query)
    const matchesChampions = team.championNames?.some((name) => name.toLowerCase().includes(query))
    return matchesName || matchesDescription || matchesChampions
  })
})

const teams = computed(() => filteredTeams.value)

const paginatedTeams = computed(() => {
  const start = (currentPage.value - 1) * itemsPerPage
  const end = start + itemsPerPage
  return teams.value.slice(start, end)
})

const totalCount = computed(() => teams.value.length)
const displayedCount = computed(() => paginatedTeams.value.length)
const isAuthenticated = computed(() => authStore.isAuthenticated())
const isAdmin = computed(() => authStore.isAdmin())
const createRoute = computed(() => (
  isAuthenticated.value ? { name: 'team-create' } : { name: 'login', query: { redirect: '/teams/new' } }
))
const searchActive = computed(() => searchTerm.value.trim().length > 0)

const handlePageChange = (page) => {
  currentPage.value = page
  window.scrollTo({ top: 0, behavior: 'smooth' })
}

const numberFormatter = new Intl.NumberFormat()

const percentage = (value) => {
  if (value === null || value === undefined) return 'N/A'
  return (value * 100).toFixed(1) + '%'
}

const summarize = (text, limit = 160) => {
  if (!text) return ''
  return text.length > limit ? `${text.slice(0, limit)}...` : text
}

const formatSet = (set) => {
  if (!set) return ''
  const match = String(set).match(/TFT(\d+)/i)
  return match ? `Set ${match[1]}` : set
}

const unitCount = (team) => {
  if (!team) return 0
  return team.size || team.championNames?.length || team.cards?.length || 0
}

const avgPlacement = (team) => {
  const value = team?.meta?.avgPlacement
  if (value === undefined || value === null) return null
  const numeric = Number(value)
  if (Number.isNaN(numeric)) return null
  return numeric.toFixed(2)
}

const playCount = (team) => {
  const value = team?.meta?.playCount
  if (!value) return null
  return numberFormatter.format(value)
}

const descriptionSegments = (team) => {
  if (!team) return []
  return extractDescriptionSegments(team.description).slice(0, 2)
}

const loadInitial = async () => {
  loading.value = true
  try {
    const { teams: newTeams, meta } = await fetchTeamComps({ page: 1, per: 100 })
    teamStore.setTeams(newTeams, meta)
  } catch (error) {
    console.error('Failed to load teams:', error)
  } finally {
    loading.value = false
    hasMounted.value = true
  }
}

const removeTeam = async (id) => {
  if (!isAdmin.value) return
  const confirmed = window.confirm('Remove this team from your library?')
  if (!confirmed) return
  await deleteTeamComp(id)
  teamStore.remove(id)
}

const preview = (card) => {
  selectionStore.focusChampion(card)
}

watch(
  () => searchTerm.value,
  () => {
    if (!hasMounted.value) return
    currentPage.value = 1
  }
)

onMounted(async () => {
  await loadInitial()
})
</script>

<style scoped>
.team-card {
  min-height: 360px;
  padding-bottom: 1.5rem;
}

.team-card-strip {
  min-height: 110px;
}

.mini-card {
  width: 72px;
  height: 72px;
  border-radius: 14px;
  overflow: hidden;
  flex: 0 0 auto;
}

.mini-card-img {
  width: 72px;
  height: 72px;
  border-radius: 14px;
  border: 3px solid rgba(184, 155, 94, 0.65);
  box-shadow: 0 4px 10px rgba(15, 23, 42, 0.35);
}

.team-meta-row {
  border-top: 1px solid rgba(15, 23, 42, 0.08);
  padding-top: 0.75rem;
}

.team-card-tags {
  display: flex;
  flex-wrap: wrap;
  gap: 0.4rem;
  margin-bottom: 0.4rem;
}

.meta-pill {
  background: rgba(13, 110, 253, 0.08);
  color: #0d6efd;
  border-radius: 999px;
  padding: 0.15rem 0.6rem;
  font-size: 0.75rem;
  font-weight: 600;
}

.team-description-list {
  list-style: none;
  padding: 0;
  margin: 0;
  display: flex;
  flex-direction: column;
  gap: 0.35rem;
}

.team-description-label {
  font-size: 0.65rem;
  text-transform: uppercase;
  letter-spacing: 0.08em;
  color: #5f6b81;
  margin-right: 0.35rem;
  font-weight: 700;
}

.team-description-value {
  color: #4d5768;
}

.win-pill {
  white-space: nowrap;
}

.meta-item {
  display: flex;
  align-items: flex-start;
  gap: 0.5rem;
}

.meta-item i {
  font-size: 1.1rem;
  color: #6c7385;
  margin-top: 0.1rem;
}

.meta-source {
  margin-left: auto;
  text-align: right;
  align-items: flex-end;
}

.meta-label {
  font-size: 0.65rem;
  text-transform: uppercase;
  letter-spacing: 0.08em;
  color: #9aa3b8;
}

.meta-value {
  font-weight: 600;
  color: #212529;
}
</style>
