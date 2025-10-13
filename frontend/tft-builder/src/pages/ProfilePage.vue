<template>
  <div class="page-white">
    <div class="container py-5" style="max-width: 720px;">
      <div class="d-flex justify-content-between align-items-center mb-4">
        <div>
          <h1 class="h3 fw-bold mb-1">Account Profile</h1>
          <p class="text-body-secondary mb-0">Update your public information and account details.</p>
        </div>
      </div>

      <div class="card shadow-sm border-0">
        <div class="card-body p-4">
          <form @submit.prevent="onSubmit">
            <div class="row g-4">
              <div class="col-md-6">
                <label class="form-label">Email (read-only)</label>
                <input :value="authStore.user?.email" class="form-control" disabled />
              </div>
              <div class="col-md-6">
                <label class="form-label">Display name</label>
                <input v-model.trim="form.displayName" class="form-control" placeholder="Visible to other users" />
              </div>

              <div class="col-md-6">
                <label class="form-label">Location</label>
                <input v-model.trim="form.location" class="form-control" placeholder="Where you're strategizing from" />
              </div>
              <div class="col-md-6">
                <label class="form-label">Avatar URL</label>
                <input v-model.trim="form.avatarUrl" class="form-control" placeholder="Link to your avatar image" />
              </div>

              <div class="col-12">
                <label class="form-label">Bio</label>
                <textarea v-model.trim="form.bio" class="form-control" rows="4" placeholder="Share your TFT experience"></textarea>
              </div>

              <div class="col-12">
                <hr />
                <h2 class="h6 fw-semibold">Update password</h2>
                <p class="text-body-secondary small">Leave blank to keep the current password.</p>
              </div>

              <div class="col-md-6">
                <label class="form-label">New password</label>
                <input v-model="form.password" type="password" class="form-control" minlength="8" autocomplete="new-password" />
              </div>
              <div class="col-md-6">
                <label class="form-label">Confirm password</label>
                <input v-model="form.passwordConfirmation" type="password" class="form-control" minlength="8" autocomplete="new-password" />
              </div>
            </div>

            <div v-if="authStore.error" class="alert alert-danger mt-3 py-2">
              {{ authStore.error }}
            </div>

            <div class="d-flex justify-content-end gap-3 mt-4">
              <button class="btn btn-outline-secondary" type="button" @click="resetForm" :disabled="authStore.loading">Reset</button>
              <button class="btn btn-primary" type="submit" :disabled="authStore.loading">
                <span v-if="authStore.loading" class="spinner-border spinner-border-sm me-2"></span>
                Save changes
              </button>
            </div>
          </form>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { reactive, watch } from 'vue'
import { useRouter } from 'vue-router'
import { authStore } from '../stores/authStore'

const router = useRouter()

if (!authStore.isAuthenticated()) {
  router.replace({ name: 'login', query: { redirect: '/profile' } })
}

const form = reactive({
  displayName: authStore.user?.displayName || '',
  bio: authStore.user?.bio || '',
  location: authStore.user?.location || '',
  avatarUrl: authStore.user?.avatarUrl || '',
  password: '',
  passwordConfirmation: '',
})

watch(
  () => authStore.user,
  (user) => {
    form.displayName = user?.displayName || ''
    form.bio = user?.bio || ''
    form.location = user?.location || ''
    form.avatarUrl = user?.avatarUrl || ''
  }
)

function resetForm() {
  form.displayName = authStore.user?.displayName || ''
  form.bio = authStore.user?.bio || ''
  form.location = authStore.user?.location || ''
  form.avatarUrl = authStore.user?.avatarUrl || ''
  form.password = ''
  form.passwordConfirmation = ''
  authStore.error = null
}

async function onSubmit() {
  const payload = {
    display_name: form.displayName,
    bio: form.bio,
    location: form.location,
    avatar_url: form.avatarUrl,
  }

  if (form.password) {
    payload.password = form.password
    payload.password_confirmation = form.passwordConfirmation
  }

  try {
    await authStore.updateProfile(payload)
    form.password = ''
    form.passwordConfirmation = ''
    authStore.error = null
  } catch (error) {
    console.warn('[profile] update failed', error)
  }
}
</script>
