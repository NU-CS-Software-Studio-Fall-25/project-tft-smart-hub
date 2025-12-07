<template>
  <div class="page-white">
    <div class="container py-5" style="max-width: 520px;">
      <div class="card shadow-sm border-0">
        <div class="card-body p-4">
          <h1 class="h4 fw-bold mb-3 text-center">{{ modeTitle }}</h1>
          <p class="text-body-secondary small text-center mb-4">
            {{ modeDescription }}
          </p>

          <div v-if="successMessage" class="alert alert-success py-2">
            {{ successMessage }}
          </div>

          <form @submit.prevent="onSubmit" class="needs-validation" novalidate>
            <div class="mb-3">
              <label class="form-label">Email</label>
              <input v-model.trim="form.email" type="email" class="form-control form-control-lg" required autocomplete="email" />
            </div>

            <div v-if="mode === 'login'" class="mb-3">
              <label class="form-label">Password</label>
              <input v-model="form.password" type="password" class="form-control form-control-lg" required autocomplete="current-password" />
            </div>

            <div v-else-if="mode === 'register'" class="mb-3">
              <label class="form-label">Password</label>
              <input
                v-model="form.password"
                type="password"
                class="form-control form-control-lg"
                required
                minlength="8"
                autocomplete="new-password"
              />
            </div>

            <div v-if="mode === 'register'" class="mb-3">
              <label class="form-label">Confirm password</label>
              <input
                v-model="form.passwordConfirmation"
                type="password"
                class="form-control form-control-lg"
                required
                minlength="8"
                autocomplete="new-password"
              />
            </div>

            <div v-if="mode === 'register'" class="mb-3">
              <label class="form-label">Display name (optional)</label>
              <input v-model.trim="form.displayName" type="text" class="form-control" placeholder="Your in-game alias" />
            </div>

            <div v-if="mode === 'register'" class="form-check mb-3">
              <input
                v-model="form.termsAccepted"
                type="checkbox"
                class="form-check-input"
                id="termsCheckbox"
                required
              />
              <label class="form-check-label small" for="termsCheckbox">
                I agree to the
                <a href="#" @click.prevent="goToGuidelines" class="text-decoration-none">Community Guidelines and Terms of Service</a>
              </label>
            </div>

            <div v-if="googleCredential" class="form-check mb-3">
              <input
                v-model="form.termsAccepted"
                type="checkbox"
                class="form-check-input"
                id="googleTermsCheckbox"
                required
              />
              <label class="form-check-label small" for="googleTermsCheckbox">
                I agree to the
                <a href="#" @click.prevent="goToGuidelines" class="text-decoration-none">Community Guidelines and Terms of Service</a>
              </label>
            </div>

            <div v-if="authStore.error" class="alert alert-danger py-2">
              {{ authStore.error }}
            </div>

            <button class="btn btn-primary w-100 btn-lg" type="submit" :disabled="authStore.loading">
              <span v-if="authStore.loading" class="spinner-border spinner-border-sm me-2"></span>
              {{ submitButtonLabel }}
            </button>
          </form>

          <!-- Google Sign In Button (only show on login and register modes) -->
          <div v-if="mode === 'login' || mode === 'register'" class="text-center my-3">
            <div class="position-relative">
              <hr class="my-3" />
              <span class="position-absolute top-50 start-50 translate-middle bg-white px-2 text-muted small">
                OR
              </span>
            </div>
            <div id="google-signin-button" class="d-flex justify-content-center mt-3"></div>
          </div>

          <div class="text-center mt-4 small">
            <div v-if="mode === 'login'">
              Need an account?
              <a href="#" @click.prevent="switchMode('register')">Register now</a>
            </div>
            <div v-else>
              Already have an account?
              <a href="#" @click.prevent="switchMode('login')">Sign in</a>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { reactive, ref, computed, watch, onMounted } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { authStore } from '../stores/authStore'

const router = useRouter()
const route = useRoute()

const mode = ref('login')
const successMessage = ref('')
const googleCredential = ref(null)
const form = reactive({
  email: '',
  password: '',
  passwordConfirmation: '',
  displayName: '',
  termsAccepted: false,
  verificationCode: '',
  resetToken: '',
})

const supportedModes = ['login', 'register', 'verify']

const modeTitle = computed(() => {
  switch (mode.value) {
    case 'register':
      return 'Create Account'
    default:
      return 'Sign In'
  }
})

const modeDescription = computed(() => {
  switch (mode.value) {
    case 'register':
      return 'Create your account and start building team compositions.'
    default:
      return 'Access your account to build or manage team compositions.'
  }
})

const submitButtonLabel = computed(() => {
  if (googleCredential.value) {
    return 'Accept & Sign In'
  }
  switch (mode.value) {
    case 'register':
      return 'Create account'
    default:
      return 'Sign in'
  }
})

function switchMode(nextMode, options = {}) {
  const { preserveEmail = true, preserveSuccess = false } = options
  mode.value = nextMode
  authStore.error = null
  if (!preserveSuccess) {
    successMessage.value = ''
  }
  if (!preserveEmail && nextMode !== 'verify') {
    form.email = ''
  }
  if (nextMode !== 'verify') {
    form.verificationCode = ''
  }
  if (!['login', 'register'].includes(nextMode)) {
    form.password = ''
    form.passwordConfirmation = ''
  }
}

function applyRouteState() {
  const queryMode = typeof route.query.mode === 'string' ? route.query.mode : null
  if (queryMode && supportedModes.includes(queryMode) && queryMode !== mode.value) {
    switchMode(queryMode, { preserveSuccess: true })
  }
  if (typeof route.query.email === 'string' && route.query.email.length) {
    form.email = route.query.email
  }
  if (typeof route.query.token === 'string' && route.query.token.length) {
    if (mode.value === 'verify') {
      form.verificationCode = route.query.token.toUpperCase().slice(0, 6)
    }
  }
}

onMounted(() => applyRouteState())
watch(() => route.fullPath, applyRouteState)

async function onSubmit() {
  try {
    let redirectAfter = false
    if (googleCredential.value && form.termsAccepted) {
      // Completing Google sign-in with terms acceptance
      await authStore.googleLogin(googleCredential.value, true)
      googleCredential.value = null
      redirectAfter = true
    } else if (mode.value === 'login') {
      await authStore.login({
        email: form.email,
        password: form.password,
      })
      redirectAfter = true
    } else if (mode.value === 'register') {
      await authStore.register({
        email: form.email,
        password: form.password,
        password_confirmation: form.passwordConfirmation,
        display_name: form.displayName || undefined,
        terms_accepted: form.termsAccepted,
      })
      // 注册成功后直接跳转
      redirectAfter = true
    }

    if (redirectAfter) {
      const redirectTo = route.query.redirect || '/'
      router.replace(redirectTo)
    }
  } catch (error) {
    console.warn('[login] submission failed', error)
  }
}

function initializeGoogleSignIn() {
  const clientId = import.meta.env.VITE_GOOGLE_CLIENT_ID
  if (!clientId) {
    console.warn('[Google Sign-In] VITE_GOOGLE_CLIENT_ID not configured')
    return
  }

  if (typeof google === 'undefined') {
    console.warn('[Google Sign-In] Google Identity Services not loaded')
    return
  }

  // Only show on login and register modes
  if (mode.value !== 'login' && mode.value !== 'register') {
    return
  }

  // Wait for next tick to ensure DOM is ready
  setTimeout(() => {
    const buttonContainer = document.getElementById('google-signin-button')
    if (!buttonContainer) return

    google.accounts.id.initialize({
      client_id: clientId,
      callback: handleGoogleCallback,
    })

    google.accounts.id.renderButton(
      buttonContainer,
      {
        theme: 'outline',
        size: 'large',
        text: mode.value === 'register' ? 'signup_with' : 'signin_with',
      }
    )
  }, 100)
}

async function handleGoogleCallback(response) {
  try {
    authStore.loading = true
    authStore.error = null
    await authStore.googleLogin(response.credential, form.termsAccepted)
    const redirectTo = route.query.redirect || '/'
    router.replace(redirectTo)
  } catch (error) {
    console.error('[Google Sign-In] Authentication failed', error)
    // Check if error requires terms acceptance
    if (error.response?.status === 422 && error.response?.data?.requires_terms) {
      // Store credential and show terms checkbox
      googleCredential.value = response.credential
      authStore.error = null
      // Mode stays as 'login' but we show the terms checkbox
    } else {
      authStore.error = 'Google sign-in failed. Please try again.'
    }
  } finally {
    authStore.loading = false
  }
}

watch(mode, () => {
  initializeGoogleSignIn()
})

function goToGuidelines() {
  router.push('/guidelines')
}

onMounted(() => {
  initializeGoogleSignIn()
})
</script>
