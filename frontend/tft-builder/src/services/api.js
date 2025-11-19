import axios from 'axios'
import { fetchCardsMock, fetchRecommendationsMock } from '../mocks'

const DEFAULT_BASE_URL = 'http://localhost:3000/api'
const API_BASE_URL = import.meta.env.VITE_API_BASE_URL || DEFAULT_BASE_URL
const USE_MOCK = String(import.meta.env.VITE_USE_MOCK || 'false').toLowerCase() === 'true'

const http = axios.create({
  baseURL: API_BASE_URL,
  timeout: 15000,
})

http.defaults.headers.common.Accept = 'application/json'
http.defaults.headers.common['X-Requested-With'] = 'XMLHttpRequest'

let authToken = null

http.interceptors.request.use((config) => {
  if (authToken) {
    config.headers = config.headers || {}
    config.headers.Authorization = `Bearer ${authToken}`
  } else if (config.headers?.Authorization) {
    delete config.headers.Authorization
  }
  
  // Force cache busting in development
  if (import.meta.env.DEV) {
    config.params = config.params || {}
    config.params._t = Date.now()
    config.headers['Cache-Control'] = 'no-cache, no-store, must-revalidate'
    config.headers['Pragma'] = 'no-cache'
  }
  
  return config
})

http.interceptors.response.use(
  (response) => response,
  (error) => {
    if (error.response) {
      console.error('[api] request failed', error.response.status, error.response.data)
    } else {
      console.error('[api] request error', error.message)
    }
    throw error
  }
)

export function setAuthToken(token) {
  authToken = token || null
}

export async function registerUser(payload) {
  const { data } = await http.post('/auth/register', { user: payload })
  return data
}

export async function verifyEmailUser(payload) {
  const { data } = await http.post('/auth/verify_email', { user: payload })
  return data
}

export async function resendVerificationUser(payload) {
  const { data } = await http.post('/auth/resend_verification', { user: payload })
  return data
}

export async function requestPasswordReset(payload) {
  const { data } = await http.post('/auth/forgot_password', { user: payload })
  return data
}

export async function resetPasswordRequest(payload) {
  const { data } = await http.post('/auth/reset_password', { user: payload })
  return data
}

export async function loginUser(payload) {
  const { data } = await http.post('/auth/login', { user: payload })
  return data
}

export async function loginWithGoogle(credential) {
  const { data } = await http.post('/auth/google', { credential })
  return data
}

export async function fetchCurrentUser() {
  const { data } = await http.get('/auth/me')
  return data.user
}

export async function updateProfileRequest(updates) {
  const { data } = await http.patch('/profile', { user: updates })
  return data.user
}

export async function fetchCards() {
  if (USE_MOCK) return fetchCardsMock()

  try {
    const { data } = await http.get('/champions')
    return data.map(normalizeChampion)
  } catch (error) {
    if (USE_MOCK) {
      console.warn('[api] /champions failed, using mock data instead')
      return fetchCardsMock()
    }
    throw error
  }
}

export async function fetchRecommendations(includeCards) {
  if (USE_MOCK) return fetchRecommendationsMock(includeCards)

  try {
    const { data } = await http.post('/team_comps/recommendations', {
      include_cards: includeCards,
    })
    return normalizeRecommendationResponse(data)
  } catch (error) {
    if (USE_MOCK) {
      console.warn('[api] recommendations failed, using mock data instead')
      return fetchRecommendationsMock(includeCards)
    }
    throw error
  }
}

export async function fetchTeamComps(params = {}) {
  const searchParams = new URLSearchParams()
  if (params.limit) searchParams.set('limit', params.limit)
  if (params.per) searchParams.set('per', params.per)
  if (params.page) searchParams.set('page', params.page)
  if (params.search) searchParams.set('search', params.search)
  if (params.include_cards === false) searchParams.set('include_cards', 'false')
  if (params.type) searchParams.set('type', params.type)

  const path = `/team_comps${searchParams.toString() ? `?${searchParams.toString()}` : ''}`
  const { data } = await http.get(path)

  if (Array.isArray(data)) {
    return {
      teams: data.map(normalizeTeam),
      meta: {},
    }
  }

  const teams = Array.isArray(data?.teams) ? data.teams : []
  return {
    teams: teams.map(normalizeTeam),
    meta: data?.meta || {},
  }
}

export async function fetchTeamComp(id) {
  const { data } = await http.get(`/team_comps/${id}`)
  return normalizeTeam(data)
}

export async function createTeamComp(payload) {
  const { data } = await http.post('/team_comps', {
    team_comp: buildTeamPayload(payload),
  })
  return normalizeTeam(data)
}

export async function updateTeamComp(id, payload) {
  const { data } = await http.put(`/team_comps/${id}`, {
    team_comp: buildTeamPayload(payload),
  })
  return normalizeTeam(data)
}

export async function deleteTeamComp(id) {
  await http.delete(`/team_comps/${id}`)
}

// Likes
export async function likeTeam(id) {
  const { data } = await http.post(`/team_comps/${id}/like`)
  return data
}

export async function unlikeTeam(id) {
  const { data } = await http.delete(`/team_comps/${id}/like`)
  return data
}

export async function checkLikeStatus(id) {
  const { data } = await http.get(`/team_comps/${id}/like`)
  return data
}

// Favorites
export async function favoriteTeam(id) {
  const { data } = await http.post(`/team_comps/${id}/favorite`)
  return data
}

export async function unfavoriteTeam(id) {
  const { data } = await http.delete(`/team_comps/${id}/favorite`)
  return data
}

export async function checkFavoriteStatus(id) {
  const { data } = await http.get(`/team_comps/${id}/favorite`)
  return data
}

export async function fetchFavorites() {
  const { data } = await http.get('/favorites')
  return data
}

// Comments
export async function fetchComments(teamId) {
  const { data } = await http.get(`/team_comps/${teamId}/comments`)
  return data
}

export async function createComment(teamId, content) {
  const { data } = await http.post(`/team_comps/${teamId}/comments`, { content })
  return data
}

export async function deleteComment(teamId, commentId) {
  await http.delete(`/team_comps/${teamId}/comments/${commentId}`)
}

export function extractErrorMessage(error) {
  if (!error) return 'Unknown error'
  const response = error.response?.data
  if (response?.errors) return [].concat(response.errors).join(', ')
  if (response?.error) return response.error
  return error.message || 'Unknown error'
}

function normalizeRecommendationResponse(payload = {}) {
  return {
    ...payload,
    teams: (payload.teams || []).map(normalizeTeam),
  }
}

function buildTeamPayload(payload = {}) {
  const {
    name,
    description,
    notes,
    source,
    winRate,
    playRate,
    championIds = [],
  } = payload

  return {
    name,
    description,
    notes,
    source,
    win_rate: coerceRate(winRate),
    play_rate: coerceRate(playRate),
    champion_ids: championIds,
  }
}

function coerceRate(value) {
  if (value === undefined || value === null || value === '') return undefined
  const numeric = Number(value)
  if (Number.isNaN(numeric) || numeric <= 0) return undefined
  return numeric > 1 ? numeric / 100 : numeric
}

function normalizeTeam(team) {
  const createdAt = team.createdAt || team.created_at
  const updatedAt = team.updatedAt || team.updated_at

  return {
    ...team,
    createdAt,
    updatedAt,
    winRate: team.winRate ?? null,
    playRate: team.playRate ?? null,
    cards: (team.cards || []).map(normalizeChampion),
    meta: team.meta || {},
    championNames: team.championNames || [],
  }
}

function normalizeChampion(champion) {
  if (!champion) return champion
  return {
    ...champion,
    imageUrl: champion.imageUrl || champion.image_url,
    traits: champion.traits || [],
  }
}
