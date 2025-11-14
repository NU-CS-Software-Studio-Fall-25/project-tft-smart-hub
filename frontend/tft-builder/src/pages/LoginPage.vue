<template>
  <div class="page-white">
    <div class="container py-5" style="max-width: 520px;">
      <div class="card shadow-sm border-0">
        <div class="card-body p-4">
          <h1 class="h4 fw-bold mb-3 text-center">{{ mode === 'login' ? 'Sign In' : mode === 'verify' ? 'Verify Email' : 'Create Account' }}</h1>
          <p class="text-body-secondary small text-center mb-4">
            {{ mode === 'login' ? 'Access your account to build or manage team compositions.' : 
               mode === 'verify' ? 'Enter the verification code sent to your email.' :
               'Register to start saving your favorite team compositions.' }}
          </p>

          <form @submit.prevent="onSubmit" class="needs-validation" novalidate>
            <div v-if="mode === 'verify'" class="mb-3">
              <label class="form-label">Email</label>
              <input v-model.trim="form.email" type="email" class="form-control form-control-lg" required readonly />
            </div>

            <div v-if="mode !== 'verify'" class="mb-3">
              <label class="form-label">Email</label>
              <input v-model.trim="form.email" type="email" class="form-control form-control-lg" required autocomplete="email" />
            </div>

            <div v-if="mode === 'verify'" class="mb-3">
              <label class="form-label">Verification Code</label>
              <input v-model.trim="form.verificationCode" type="text" class="form-control form-control-lg" required placeholder="Enter 6-character code" maxlength="6" style="text-transform: uppercase; letter-spacing: 2px; font-size: 18px;" />
              <div class="form-text">Check your email for the verification code</div>
            </div>

            <div v-if="mode === 'login'" class="mb-3">
              <label class="form-label">Password</label>
              <input v-model="form.password" type="password" class="form-control form-control-lg" required autocomplete="current-password" />
            </div>

            <div v-if="mode === 'register'" class="mb-3">
              <label class="form-label">Confirm Password</label>
              <input v-model="form.passwordConfirmation" type="password" class="form-control form-control-lg" required minlength="8" autocomplete="new-password" />
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
              {{ mode === 'login' ? 'Sign in' : mode === 'verify' ? 'Verify Email' : 'Create account' }}
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
import { reactive, ref } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { authStore } from '../stores/authStore'

const router = useRouter()
const route = useRoute()

const mode = ref('login')
const form = reactive({
  email: '',
  password: '',
  passwordConfirmation: '',
  displayName: '',
  verificationCode: '',
})

function switchMode(nextMode) {
  mode.value = nextMode
  authStore.error = null
}

async function onSubmit() {
  try {
    if (mode.value === 'login') {
      await authStore.login({
        email: form.email,
        password: form.password,
      })
    } else if (mode.value === 'verify') {
      await authStore.verifyEmail({
        email: form.email,
        token: form.verificationCode,
      })
    } else {
      const result = await authStore.register({
        email: form.email,
        password: form.password,
        password_confirmation: form.passwordConfirmation,
        display_name: form.displayName || undefined,
      })
      
      // If registration successful, switch to verification mode
      if (result && !result.errors) {
        mode.value = 'verify'
        form.verificationCode = ''
      }
    }

    const redirectTo = route.query.redirect || '/'
    router.replace(redirectTo)
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
    // Could show a success message here
  } catch (error) {
    console.warn('[login] resend verification failed', error)
  }
}
</script>
