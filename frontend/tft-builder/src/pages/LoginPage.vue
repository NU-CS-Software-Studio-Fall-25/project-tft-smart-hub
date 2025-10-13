<template>
  <div class="page-white">
    <div class="container py-5" style="max-width: 520px;">
      <div class="card shadow-sm border-0">
        <div class="card-body p-4">
          <h1 class="h4 fw-bold mb-3 text-center">{{ mode === 'login' ? 'Sign In' : 'Create Account' }}</h1>
          <p class="text-body-secondary small text-center mb-4">
            {{ mode === 'login' ? 'Access your account to build or manage team compositions.' : 'Register to start saving your favorite team compositions.' }}
          </p>

          <form @submit.prevent="onSubmit" class="needs-validation" novalidate>
            <div class="mb-3">
              <label class="form-label">Email</label>
              <input v-model.trim="form.email" type="email" class="form-control form-control-lg" required autocomplete="email" />
            </div>

            <div class="mb-3">
              <label class="form-label">Password</label>
              <input v-model="form.password" type="password" class="form-control form-control-lg" required minlength="8" autocomplete="current-password" />
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
              {{ mode === 'login' ? 'Sign in' : 'Create account' }}
            </button>
          </form>

          <div class="text-center mt-4 small">
            <span v-if="mode === 'login'">
              Need an account?
              <a href="#" @click.prevent="switchMode('register')">Register now</a>
            </span>
            <span v-else>
              Already have an account?
              <a href="#" @click.prevent="switchMode('login')">Sign in</a>
            </span>
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
    } else {
      await authStore.register({
        email: form.email,
        password: form.password,
        password_confirmation: form.passwordConfirmation,
        display_name: form.displayName || undefined,
      })
    }

    const redirectTo = route.query.redirect || '/'
    router.replace(redirectTo)
  } catch (error) {
    console.warn('[login] submission failed', error)
  }
}
</script>
