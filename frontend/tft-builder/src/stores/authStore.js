import { reactive } from 'vue'
import {
  setAuthToken,
  loginUser,
  registerUser,
  fetchCurrentUser,
  updateProfileRequest,
  extractErrorMessage,
} from '../services/api'

const TOKEN_KEY = 'tft_auth_token'
const USER_KEY = 'tft_auth_user'

// Read from localStorage synchronously on module load
const persistedToken = localStorage.getItem(TOKEN_KEY)
const persistedUser = (() => {
  try {
    const userStr = localStorage.getItem(USER_KEY)
    return userStr ? JSON.parse(userStr) : null
  } catch (e) {
    console.warn('[auth] failed to parse stored user, clearing', e)
    localStorage.removeItem(USER_KEY)
    return null
  }
})()

if (persistedToken) {
  setAuthToken(persistedToken)
}

export const authStore = reactive({
  token: persistedToken,
  user: persistedUser,
  loading: false,
  error: null,

  async login(credentials) {
    this.loading = true
    this.error = null
    try {
      const { token, user } = await loginUser(credentials)
      this.setSession(token, user)
      return user
    } catch (error) {
      this.error = extractErrorMessage(error)
      throw error
    } finally {
      this.loading = false
    }
  },

  async register(payload) {
    this.loading = true
    this.error = null
    try {
      const { token, user } = await registerUser(payload)
      this.setSession(token, user)
      return user
    } catch (error) {
      this.error = extractErrorMessage(error)
      throw error
    } finally {
      this.loading = false
    }
  },

  async refreshProfile() {
    if (!this.isAuthenticated()) return null
    this.loading = true
    try {
      const user = await fetchCurrentUser()
      this.setSession(this.token, user)
      return user
    } catch (error) {
      console.error('[auth] refresh profile failed', error)
      this.clearSession()
      throw error
    } finally {
      this.loading = false
    }
  },

  async updateProfile(updates) {
    if (!this.isAuthenticated()) {
      throw new Error('Not authenticated')
    }
    this.loading = true
    this.error = null
    try {
      const user = await updateProfileRequest(updates)
      this.setSession(this.token, user)
      return user
    } catch (error) {
      this.error = extractErrorMessage(error)
      throw error
    } finally {
      this.loading = false
    }
  },

  logout() {
    this.clearSession()
  },

  setSession(token, user) {
    this.token = token || null
    this.user = user || null
    if (this.token) {
      localStorage.setItem(TOKEN_KEY, this.token)
      localStorage.setItem(USER_KEY, JSON.stringify(this.user))
    } else {
      localStorage.removeItem(TOKEN_KEY)
      localStorage.removeItem(USER_KEY)
    }
    setAuthToken(this.token)
  },

  clearSession() {
    this.token = null
    this.user = null
    this.error = null
    localStorage.removeItem(TOKEN_KEY)
    localStorage.removeItem(USER_KEY)
    setAuthToken(null)
  },

  isAuthenticated() {
    return Boolean(this.token && this.user)
  },

  isAdmin() {
    return this.user?.role === 'admin'
  },
})
