<template>
  <div class="page-white">
    <div class="container py-5">
      <RouterLink class="btn btn-outline-secondary btn-sm mb-3" :to="{ name: 'teams' }">
        <i class="bi bi-chevron-left me-1"></i>
        Back to library
      </RouterLink>

      <div v-if="loading" class="py-5 text-center">
        <div class="spinner-border"></div>
        <div class="mt-3 text-body-secondary">Loading team composition...</div>
      </div>

      <div v-else-if="!team" class="alert alert-danger">
        Team composition not found. It may have been deleted.
      </div>

      <div v-else class="card shadow-sm border-0">
        <div class="card-body p-4 p-lg-5">
          <div class="d-flex flex-column flex-lg-row justify-content-between align-items-lg-start gap-4 mb-4">
            <div class="team-detail-heading">
              <h1 class="display-6 fw-bold mb-2">{{ team.name }}</h1>
              <div class="team-detail-tags">
                <span v-if="team.set" class="detail-pill">{{ formatSet(team.set) }}</span>
                <span v-if="team.size" class="detail-pill">{{ team.size }} units</span>
              </div>
              <div v-if="descriptionSegments.length" class="team-detail-description">
                <div
                  v-for="(segment, index) in descriptionSegments"
                  :key="segment.label || index"
                  class="detail-description-row"
                >
                  <span v-if="segment.label" class="detail-description-label">{{ segment.label }}</span>
                  <span class="detail-description-value">{{ segment.value }}</span>
                </div>
              </div>
              <p v-else class="lead text-body-secondary mb-0">{{ team.description }}</p>
            </div>
            <div class="d-flex flex-wrap gap-3">
              <div class="stat-pill bg-success-subtle text-success-emphasis">
                <span class="label">Win rate</span>
                <span class="value">{{ percentage(team.winRate) }}</span>
              </div>
              <div class="stat-pill bg-primary-subtle text-primary-emphasis">
                <span class="label">Play rate</span>
                <span class="value">{{ percentage(team.playRate) }}</span>
              </div>
              <div class="stat-pill bg-warning-subtle text-warning-emphasis" v-if="avgPlacement(team)">
                <span class="label">Avg place</span>
                <span class="value">{{ avgPlacement(team) }}</span>
              </div>
              <div class="stat-pill bg-info-subtle text-info-emphasis" v-if="team.meta?.playCount">
                <span class="label">Games</span>
                <span class="value">{{ playCount(team.meta.playCount) }}</span>
              </div>
              <div class="stat-pill bg-secondary-subtle text-secondary-emphasis" v-if="team.meta?.matchCount !== undefined">
                <span class="label">Match score</span>
                <span class="value">{{ team.meta.matchCount }}</span>
              </div>
            </div>
          </div>

          <div class="row g-4">
            <div class="col-xl-8">
              <h2 class="h5 fw-semibold mb-3">Champion lineup</h2>
              <div class="row g-3">
                <div v-for="card in team.cards" :key="card.id" class="col-6 col-sm-4 col-lg-3">
                  <div class="champion-card" @contextmenu.prevent="preview(card)">
                    <SpriteImage
                      :sprite="card.sprite"
                      :image-url="card.imageUrl"
                      :alt="card.name"
                      :size="128"
                      class-name="detail-card-img"
                    />
                    <div class="info">
                      <div class="name">{{ card.name }}</div>
                      <div class="traits">
                        <span v-for="trait in card.traits" :key="trait" class="badge bg-dark-subtle text-dark-emphasis">
                          {{ trait }}
                        </span>
                      </div>
                    </div>
                  </div>
                </div>
              </div>
            </div>
            <div class="col-xl-4">
              <div class="card border-0 bg-body-secondary">
                <div class="card-body">
                  <h2 class="h6 text-uppercase text-secondary fw-semibold mb-3">Strategy notes</h2>
                  <p v-if="team.notes" class="text-body-secondary">
                    {{ team.notes }}
                  </p>
                  <p v-else class="text-body-secondary">
                    No notes recorded. Add notes when editing the team to highlight itemization or positioning tips.
                  </p>
                  <ul class="list-unstyled small text-body-secondary meta-list">
                    <li>
                      <span class="meta-label">Set</span>
                      <span class="meta-value">{{ formatSet(team.set) }}</span>
                    </li>
                    <li>
                      <span class="meta-label">Units</span>
                      <span class="meta-value">{{ unitCount(team) }}</span>
                    </li>
                    <li v-if="team.meta?.playCount">
                      <span class="meta-label">Games tracked</span>
                      <span class="meta-value">{{ playCount(team.meta.playCount) }}</span>
                    </li>
                    <li v-if="avgPlacement(team)">
                      <span class="meta-label">Avg placement</span>
                      <span class="meta-value">{{ avgPlacement(team) }}</span>
                    </li>
                    <li v-if="team.meta?.top4Rate">
                      <span class="meta-label">Top 4 rate</span>
                      <span class="meta-value">{{ percentage(team.meta.top4Rate) }}</span>
                    </li>
                    <li v-if="team.source">
                      <span class="meta-label">Source</span>
                      <span class="meta-value">{{ team.source }}</span>
                    </li>
                    <li>
                      <span class="meta-label">Created</span>
                      <span class="meta-value">{{ formatDate(team.createdAt) }}</span>
                    </li>
                    <li v-if="team.updatedAt">
                      <span class="meta-label">Updated</span>
                      <span class="meta-value">{{ formatDate(team.updatedAt) }}</span>
                    </li>
                  </ul>
                </div>
              </div>

              <div class="d-flex flex-wrap gap-2 mt-3">
                <RouterLink
                  v-if="isAdmin"
                  class="btn btn-outline-primary flex-grow-1"
                  :to="{ name: 'team-edit', params: { id } }"
                >
                  <i class="bi bi-pencil me-1"></i>
                  Edit team
                </RouterLink>
                <button v-if="isAdmin" class="btn btn-outline-danger flex-grow-1" @click="removeTeam">
                  <i class="bi bi-trash me-1"></i>
                  Delete
                </button>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { computed, onMounted, ref, watch } from 'vue'
import { RouterLink, useRouter } from 'vue-router'
import SpriteImage from '../components/SpriteImage.vue'
import { fetchTeamComp, deleteTeamComp } from '../services/api'
import { store as selectionStore } from '../stores/selectionStore'
import { teamStore } from '../stores/teamStore'
import { authStore } from '../stores/authStore'
import { extractDescriptionSegments } from '../utils/descriptionUtils'

const props = defineProps({
  id: {
    type: String,
    required: true,
  },
})

const router = useRouter()
const loading = ref(false)
const id = computed(() => props.id)
const team = computed(() => teamStore.getById(Number(id.value)))
const isAdmin = computed(() => authStore.isAdmin())
const descriptionSegments = computed(() => extractDescriptionSegments(team.value?.description))

const numberFormatter = new Intl.NumberFormat()

const percentage = (value) => {
  if (value === null || value === undefined) return 'N/A'
  return (value * 100).toFixed(1) + '%'
}

const avgPlacement = (team) => {
  const value = team?.meta?.avgPlacement
  if (value === undefined || value === null) return null
  const numeric = Number(value)
  if (Number.isNaN(numeric)) return null
  return numeric.toFixed(2)
}

const playCount = (value) => {
  if (!value) return null
  return numberFormatter.format(value)
}

const unitCount = (team) => {
  if (!team) return 0
  return team.size || team.championNames?.length || team.cards?.length || 0
}

const formatSet = (set) => {
  if (!set) return 'Unspecified'
  const match = String(set).match(/TFT(\d+)/i)
  return match ? `Set ${match[1]}` : set
}

const formatDate = (value) => {
  if (!value) return 'unknown'
  const date = new Date(value)
  return date.toLocaleDateString()
}

const loadTeam = async () => {
  loading.value = true
  try {
    const data = await fetchTeamComp(id.value)
    teamStore.upsert(data)
  } finally {
    loading.value = false
  }
}

const removeTeam = async () => {
  if (!authStore.isAdmin()) return
  const confirmed = window.confirm('Delete this team permanently?')
  if (!confirmed) return
  await deleteTeamComp(id.value)
  teamStore.remove(Number(id.value))
  router.push({ name: 'teams' })
}

const preview = (card) => {
  selectionStore.focusChampion?.(card)
}

onMounted(async () => {
  if (!team.value) {
    await loadTeam()
  }
})

watch(
  () => props.id,
  async () => {
    if (!team.value) await loadTeam()
  }
)
</script>

<style scoped>
.stat-pill {
  border-radius: 18px;
  padding: 0.75rem 1.25rem;
  text-align: center;
  min-width: 120px;
}

.stat-pill .label {
  display: block;
  font-size: 0.75rem;
  letter-spacing: 0.08em;
  text-transform: uppercase;
}

.stat-pill .value {
  font-weight: 600;
  font-size: 1.125rem;
}

.champion-card {
  display: flex;
  flex-direction: column;
  align-items: center;
  border-radius: 16px;
  background: #f8f9fa;
  overflow: hidden;
  border: 1px solid rgba(0, 0, 0, 0.05);
  box-shadow: 0 1px 4px rgba(15, 23, 42, 0.12);
}

.detail-card-img {
  width: 128px;
  height: 128px;
  border-radius: 16px;
  border: 2px solid rgba(184, 155, 94, 0.8);
  box-shadow: 0 4px 12px rgba(15, 23, 42, 0.25);
}

.champion-card .info {
  width: 100%;
  padding: 0.75rem;
}

.champion-card .name {
  font-weight: 600;
  margin-bottom: 0.5rem;
}

.champion-card .traits {
  display: flex;
  flex-wrap: wrap;
  gap: 0.25rem;
}

.team-detail-heading {
  flex: 1;
}

.team-detail-tags {
  display: flex;
  flex-wrap: wrap;
  gap: 0.5rem;
  margin-bottom: 0.75rem;
}

.detail-pill {
  background: rgba(13, 110, 253, 0.12);
  color: #0d3b66;
  border-radius: 999px;
  padding: 0.2rem 0.8rem;
  font-weight: 600;
}

.team-detail-description {
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
  color: #4b5563;
}

.detail-description-row {
  display: flex;
  flex-wrap: wrap;
  gap: 0.4rem;
}

.detail-description-label {
  font-size: 0.75rem;
  text-transform: uppercase;
  letter-spacing: 0.08em;
  font-weight: 700;
  color: #6b7280;
}

.detail-description-value {
  font-size: 1rem;
}

.meta-list {
  margin: 0;
  padding: 0;
  display: flex;
  flex-direction: column;
  gap: 0.4rem;
}

.meta-list li {
  display: flex;
  justify-content: space-between;
  gap: 1rem;
}

.meta-label {
  font-size: 0.75rem;
  text-transform: uppercase;
  letter-spacing: 0.08em;
  color: #6c7280;
}

.meta-value {
  font-weight: 600;
  color: #1f2933;
}
</style>
