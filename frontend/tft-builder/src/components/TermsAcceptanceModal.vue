<template>
  <div v-if="isOpen" class="modal-overlay">
    <div class="modal-content">
      <div class="modal-header">
        <h2>Accept Community Guidelines & Terms of Service</h2>
      </div>

      <div class="modal-body">
        <p class="warning-text">
          ⚠️ You must accept our Community Guidelines and Terms of Service to continue using the platform.
        </p>

        <div class="guidelines-preview">
          <h3>Community Guidelines & Terms of Service</h3>
          
          <section class="guideline-section">
            <h4>Community Guidelines</h4>
            <p>Welcome to the TFT Smart Hub community. To ensure a positive and respectful environment for all users, we ask that you follow these guidelines:</p>
            
            <ul>
              <li><strong>Be Respectful:</strong> Treat all community members with respect and dignity</li>
              <li><strong>Keep Content Appropriate:</strong> No hate speech, discrimination, or offensive content</li>
              <li><strong>No Spam or Abuse:</strong> Do not spam, share malicious links, or engage in phishing</li>
              <li><strong>Respect Intellectual Property:</strong> Do not share copyrighted content without permission</li>
              <li><strong>Follow Platform Rules:</strong> Comply with all applicable laws and regulations</li>
            </ul>
          </section>

          <section class="guideline-section">
            <h4>Terms of Service</h4>
            <p>By using this platform, you agree to:</p>
            
            <ul>
              <li>Accept responsibility for your account and all activities under it</li>
              <li>Use the platform only for legal and authorized purposes</li>
              <li>Retain rights to your content, but grant us license to use it</li>
              <li>Accept our limitation of liability</li>
              <li>Accept that we may modify terms at any time</li>
              <li>Accept that we may terminate your account for violations</li>
            </ul>
          </section>

          <section class="guideline-section">
            <h4>Data Privacy</h4>
            <p>We respect your privacy and protect your personal information according to our privacy policy. We do not share your data with third parties without your consent, except as required by law.</p>
          </section>

          <p class="full-link">
            <a href="#" @click.prevent="goToFullGuidelines" class="link">View full guidelines →</a>
          </p>
        </div>

        <div class="acceptance-section">
          <div class="form-check">
            <input
              v-model="termsAccepted"
              type="checkbox"
              class="form-check-input"
              id="termsAcceptCheckbox"
            />
            <label class="form-check-label" for="termsAcceptCheckbox">
              I have read and agree to the Community Guidelines and Terms of Service
            </label>
          </div>
        </div>

        <div v-if="error" class="alert alert-danger mt-3">
          {{ error }}
        </div>
      </div>

      <div class="modal-footer">
        <button
          @click="handleLogout"
          class="btn btn-secondary"
          :disabled="isSubmitting"
        >
          Exit & Sign Out
        </button>
        <button
          @click="handleAccept"
          class="btn btn-primary"
          :disabled="!termsAccepted || isSubmitting"
        >
          <span v-if="isSubmitting" class="spinner-border spinner-border-sm me-2"></span>
          {{ isSubmitting ? 'Accepting...' : 'Accept & Continue' }}
        </button>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import { useRouter } from 'vue-router'
import { authStore } from '../stores/authStore'
import { acceptTermsRequest } from '../services/api'

const router = useRouter()

const termsAccepted = ref(false)
const isSubmitting = ref(false)
const error = ref(null)

const isOpen = ref(false)

// Expose methods to open/close modal
const openModal = () => {
  isOpen.value = true
  termsAccepted.value = false
  error.value = null
}

const closeModal = () => {
  isOpen.value = false
}

const goToFullGuidelines = () => {
  router.push('/guidelines')
}

const handleAccept = async () => {
  if (!termsAccepted.value) return

  isSubmitting.value = true
  error.value = null

  try {
    const updatedUser = await acceptTermsRequest()
    // Update the store with the new user data that has termsAccepted: true
    authStore.setSession(authStore.token, updatedUser)
    closeModal()
    // Modal has been accepted, user can continue
  } catch (err) {
    error.value = 'Failed to accept terms. Please try again.'
    console.error('[TermsModal] Error accepting terms:', err)
  } finally {
    isSubmitting.value = false
  }
}

const handleLogout = async () => {
  isSubmitting.value = true
  try {
    authStore.logout()
    await router.push('/login')
    closeModal()
  } catch (err) {
    console.error('[TermsModal] Error logging out:', err)
  } finally {
    isSubmitting.value = false
  }
}

defineExpose({
  openModal,
  closeModal,
})
</script>

<style scoped>
.modal-overlay {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background-color: rgba(0, 0, 0, 0.7);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 2000;
  backdrop-filter: blur(4px);
}

.modal-content {
  background: #0f3460;
  border-radius: 12px;
  max-width: 600px;
  width: 90%;
  max-height: 90vh;
  display: flex;
  flex-direction: column;
  box-shadow: 0 20px 60px rgba(0, 0, 0, 0.5);
  border: 2px solid #00d4ff;
}

.modal-header {
  padding: 24px;
  border-bottom: 2px solid #1a3a52;
  background: linear-gradient(135deg, #0f3460 0%, #1a3a52 100%);
}

.modal-header h2 {
  margin: 0;
  color: #00d4ff;
  font-size: 1.5em;
  text-shadow: 0 2px 8px rgba(0, 212, 255, 0.2);
}

.modal-body {
  flex: 1;
  overflow-y: auto;
  padding: 24px;
}

.warning-text {
  background-color: rgba(255, 193, 7, 0.1);
  border-left: 4px solid #ffc107;
  padding: 12px 16px;
  border-radius: 4px;
  color: #ffd700;
  margin-bottom: 20px;
  font-weight: 500;
}

.guidelines-preview {
  background-color: rgba(26, 58, 82, 0.5);
  padding: 16px;
  border-radius: 8px;
  margin-bottom: 20px;
  border: 1px solid #1a3a52;
}

.guidelines-preview h3 {
  color: #00d4ff;
  font-size: 1.2em;
  margin-top: 0;
  margin-bottom: 16px;
}

.guideline-section {
  margin-bottom: 16px;
  padding-bottom: 16px;
  border-bottom: 1px solid #1a3a52;
}

.guideline-section:last-child {
  border-bottom: none;
  margin-bottom: 0;
  padding-bottom: 0;
}

.guideline-section h4 {
  color: #ffd700;
  margin-top: 0;
  margin-bottom: 8px;
  font-size: 1.1em;
}

.guideline-section p {
  color: #d1d5db;
  font-size: 0.95em;
  line-height: 1.5;
  margin: 0 0 8px 0;
}

.guideline-section ul {
  list-style: none;
  padding-left: 0;
  margin: 0;
  color: #d1d5db;
  font-size: 0.95em;
}

.guideline-section li {
  padding-left: 20px;
  margin-bottom: 6px;
  position: relative;
}

.guideline-section li:before {
  content: "→";
  position: absolute;
  left: 0;
  color: #00d4ff;
}

.full-link {
  text-align: center;
  margin-top: 12px;
  margin-bottom: 0;
}

.link {
  color: #00d4ff;
  text-decoration: none;
  font-weight: 500;
  transition: all 0.2s ease;
}

.link:hover {
  text-decoration: underline;
  color: #ffd700;
}

.acceptance-section {
  background-color: rgba(26, 58, 82, 0.3);
  padding: 16px;
  border-radius: 8px;
  margin-top: 20px;
  border: 1px solid #1a3a52;
}

.form-check {
  margin: 0;
}

.form-check-input {
  width: 1.25em;
  height: 1.25em;
  margin-top: 0.3em;
  margin-right: 0.5em;
  cursor: pointer;
  accent-color: #00d4ff;
  border: 2px solid #1a3a52;
  border-radius: 4px;
}

.form-check-input:checked {
  background-color: #00d4ff;
  border-color: #00d4ff;
}

.form-check-input:focus {
  border-color: #00d4ff;
  box-shadow: 0 0 0 0.2rem rgba(0, 212, 255, 0.25);
}

.form-check-label {
  margin: 0;
  color: #ecf0f1;
  font-weight: 500;
  cursor: pointer;
  user-select: none;
}

.alert {
  margin: 0;
}

.modal-footer {
  padding: 16px 24px;
  border-top: 1px solid #1a3a52;
  background: #0a1f2e;
  display: flex;
  gap: 12px;
  justify-content: flex-end;
}

.btn {
  padding: 10px 24px;
  border-radius: 6px;
  font-weight: 500;
  cursor: pointer;
  transition: all 0.2s ease;
  border: none;
  font-size: 0.95em;
}

.btn:disabled {
  opacity: 0.6;
  cursor: not-allowed;
}

.btn-secondary {
  background-color: #1a3a52;
  color: #ecf0f1;
  border: 1px solid #3a5a72;
}

.btn-secondary:hover:not(:disabled) {
  background-color: #2a4a62;
  border-color: #4a6a82;
}

.btn-primary {
  background-color: #00d4ff;
  color: #0f3460;
  border: 2px solid #00d4ff;
}

.btn-primary:hover:not(:disabled) {
  background-color: #00b8d4;
  border-color: #00b8d4;
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(0, 212, 255, 0.3);
}

.spinner-border {
  display: inline-block;
  width: 1em;
  height: 1em;
  vertical-align: -0.25em;
  border: 0.25em solid currentColor;
  border-right-color: transparent;
  border-radius: 50%;
  animation: spinner-border 0.75s linear infinite;
}

@keyframes spinner-border {
  to {
    transform: rotate(360deg);
  }
}

.spinner-border-sm {
  width: 0.8em;
  height: 0.8em;
  border-width: 0.2em;
}

/* Scrollbar styling */
.modal-body::-webkit-scrollbar {
  width: 8px;
}

.modal-body::-webkit-scrollbar-track {
  background: transparent;
}

.modal-body::-webkit-scrollbar-thumb {
  background: #1a3a52;
  border-radius: 4px;
}

.modal-body::-webkit-scrollbar-thumb:hover {
  background: #2a5a72;
}

@media (max-width: 600px) {
  .modal-content {
    width: 95%;
    max-height: 95vh;
  }

  .modal-header {
    padding: 16px;
  }

  .modal-header h2 {
    font-size: 1.25em;
  }

  .modal-body {
    padding: 16px;
  }

  .modal-footer {
    flex-direction: column;
    padding: 12px 16px;
  }

  .btn {
    width: 100%;
  }
}
</style>
