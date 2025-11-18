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
            <div v-if="mode === 'verify'" class="mb-3">
              <label class="form-label">Email</label>
              <input v-model.trim="form.email" type="email" class="form-control form-control-lg" required readonly />
            </div>

            <div v-else class="mb-3">
              <label class="form-label">Email</label>
              <input v-model.trim="form.email" type="email" class="form-control form-control-lg" required autocomplete="email" />
            </div>

            <div v-if="mode === 'verify'" class="mb-3">
              <label class="form-label">Verification Code</label>
              <input
                v-model.trim="form.verificationCode"
                type="text"
                class="form-control form-control-lg"
                required
                placeholder="Enter 6-digit code"
                maxlength="6"
                style="text-transform: uppercase; letter-spacing: 2px; font-size: 18px;"
              />
              <div class="form-text">Check your email for the verification code</div>
            </div>

            <div v-if="mode === 'reset'" class="mb-3">
              <label class="form-label">Reset token</label>
              <input
                v-model.trim="form.resetToken"
                type="text"
                class="form-control form-control-lg"
                required
                placeholder="Paste the token from your email or use the reset link"
              />
              <div class="form-text">The token is automatically filled when you open the email link.</div>
            </div>

            <div v-if="mode === 'login'" class="mb-3">
              <label class="form-label">Password</label>
              <input v-model="form.password" type="password" class="form-control form-control-lg" required autocomplete="current-password" />
            </div>

            <div v-else-if="mode === 'register' || mode === 'reset'" class="mb-3">
              <label class="form-label">{{ mode === 'reset' ? 'New password' : 'Password' }}</label>
              <input
                v-model="form.password"
                type="password"
                class="form-control form-control-lg"
                required
                minlength="8"
                :autocomplete="mode === 'reset' ? 'new-password' : 'new-password'"
              />
            </div>

            <div v-if="mode === 'register' || mode === 'reset'" class="mb-3">
              <label class="form-label">{{ mode === 'reset' ? 'Confirm new password' : 'Confirm password' }}</label>
              <input
                v-model="form.passwordConfirmation"
                type="password"
                class="form-control form-control-lg"
                required
                minlength="8"
                :autocomplete="mode === 'reset' ? 'new-password' : 'new-password'"
              />
            </div>

            <div v-if="mode === 'register'" class="mb-3">
              <label class="form-label">Display name (optional)</label>
              <input v-model.trim="form.displayName" type="text" class="form-control" placeholder="Your in-game alias" />
            </div>

            <div v-if="authStore.error" class="alert alert-danger py-2">
              {{ authStore.error }}
            </div>

            <button class="btn btn-primary w-100 btn-lg" type="submit" :disabled="authStore.loading">
              <span v-if="authStore.loading" class="spinner-border spinner-border-sm me-2"></span>
              {{ submitButtonLabel }}
            </button>
          </form>

          <div class="text-center mt-4 small">
            <div v-if="mode === 'verify'">
              <p>Didn't receive the code?</p>
              <a href="#" @click.prevent="resendVerification">Resend verification email</a>
              <br><br>
              <a href="#" @click.prevent="switchMode('login')">Back to sign in</a>
            </div>
            <div v-else-if="mode === 'login'">
              <div>
                Need an account?
                <a href="#" @click.prevent="switchMode('register')">Register now</a>
              </div>
              <div class="mt-2">
                Forgot your password?
                <a href="#" @click.prevent="switchMode('forgot')">Reset it</a>
              </div>
            </div>
            <div v-else-if="mode === 'forgot'">
              Remembered your password?
              <a href="#" @click.prevent="switchMode('login')">Back to sign in</a>
            </div>
            <div v-else-if="mode === 'reset'">
              <a href="#" @click.prevent="switchMode('login')">Back to sign in</a>
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
const form = reactive({
  email: '',
  password: '',
  passwordConfirmation: '',
  displayName: '',
  verificationCode: '',
  resetToken: '',
})

const supportedModes = ['login', 'register', 'verify', 'forgot', 'reset']

const modeTitle = computed(() => {
  switch (mode.value) {
    case 'register':
      return 'Create Account'
    case 'verify':
      return 'Verify Email'
    case 'forgot':
      return 'Forgot Password'
    case 'reset':
      return 'Set a New Password'
    default:
      return 'Sign In'
  }
})

const modeDescription = computed(() => {
  switch (mode.value) {
    case 'register':
      return 'Register to start saving your favorite team compositions.'
    case 'verify':
      return 'Enter the 6-digit verification code we sent to your email.'
    case 'forgot':
      return 'Enter your email and we will send you password reset instructions.'
    case 'reset':
      return 'Choose a new password. You can paste the token from your email or open the secure link.'
    default:
      return 'Access your account to build or manage team compositions.'
  }
})

const submitButtonLabel = computed(() => {
  switch (mode.value) {
    case 'register':
      return 'Create account'
    case 'verify':
      return 'Verify email'
    case 'forgot':
      return 'Send reset email'
    case 'reset':
      return 'Update password'
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
  if (nextMode !== 'reset') {
    form.resetToken = ''
  }
  if (!['login', 'register', 'reset'].includes(nextMode)) {
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
    } else if (mode.value === 'reset') {
      form.resetToken = route.query.token
    }
  }
}

onMounted(() => applyRouteState())
watch(() => route.fullPath, applyRouteState)

async function onSubmit() {
  try {
    let redirectAfter = false
    if (mode.value === 'login') {
      try {
        await authStore.login({
          email: form.email,
          password: form.password,
        })
        redirectAfter = true
      } catch (error) {
        // Check if error is due to unverified email
        if (error?.response?.data?.email_not_verified) {
          successMessage.value = 'Your email is not verified yet. Please enter the verification code sent to your inbox.'
          switchMode('verify', { preserveEmail: true, preserveSuccess: true })
          form.verificationCode = ''
          return
        }
        throw error
      }
    } else if (mode.value === 'verify') {
      await authStore.verifyEmail({
        email: form.email,
        token: form.verificationCode,
      })
      redirectAfter = true
    } else if (mode.value === 'register') {
      const result = await authStore.register({
        email: form.email,
        password: form.password,
        password_confirmation: form.passwordConfirmation,
        display_name: form.displayName || undefined,
      })
      if (result && !result.errors) {
        successMessage.value = 'We sent a verification code to your inbox. Enter it below to finish creating your account.'
        switchMode('verify', { preserveEmail: true, preserveSuccess: true })
        form.verificationCode = ''
      }
    } else if (mode.value === 'forgot') {
      await authStore.requestPasswordReset({ email: form.email })
      successMessage.value = 'If the email exists in our system, you will receive password reset instructions shortly.'
    } else if (mode.value === 'reset') {
      await authStore.resetPassword({
        email: form.email,
        token: form.resetToken,
        password: form.password,
        password_confirmation: form.passwordConfirmation,
      })
      successMessage.value = 'Password updated! You can now sign in with your new password.'
      switchMode('login', { preserveEmail: true, preserveSuccess: true })
      return
    }

    if (redirectAfter) {
      const redirectTo = route.query.redirect || '/'
      router.replace(redirectTo)
    }
  } catch (error) {
    console.warn('[login] submission failed', error)
  }
}

async function resendVerification() {
  try {
    await authStore.resendVerification({
      email: form.email,
    })
    authStore.error = null
    successMessage.value = 'A new verification email is on the way.'
  } catch (error) {
    console.warn('[login] resend verification failed', error)
  }
}
</script>
