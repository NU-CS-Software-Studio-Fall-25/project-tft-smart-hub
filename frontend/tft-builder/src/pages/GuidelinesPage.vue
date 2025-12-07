<template>
  <div class="guidelines-page">
    <div class="guidelines-container">
      <h1>Community Guidelines & Terms of Service</h1>
      
      <div class="guidelines-content">
        <!-- Community Guidelines Section -->
        <section class="guidelines-section">
          <h2>Community Guidelines</h2>
          <p>Welcome to the TFT Smart Hub community. To ensure a positive and respectful environment for all users, we ask that you follow these guidelines:</p>
          
          <h3>1. Be Respectful</h3>
          <ul>
            <li>Treat all community members with respect and dignity</li>
            <li>Avoid personal attacks, harassment, or bullying</li>
            <li>Welcome diverse perspectives and experiences</li>
          </ul>
          
          <h3>2. Keep Content Appropriate</h3>
          <ul>
            <li>No hate speech, discrimination, or offensive content</li>
            <li>No explicit or adult content</li>
            <li>Keep discussions relevant to TFT and team building</li>
          </ul>
          
          <h3>3. No Spam or Abuse</h3>
          <ul>
            <li>Do not spam or flood the platform with repetitive messages</li>
            <li>Do not share malicious links or malware</li>
            <li>Do not engage in phishing or scams</li>
          </ul>
          
          <h3>4. Respect Intellectual Property</h3>
          <ul>
            <li>Do not share copyrighted content without permission</li>
            <li>Respect the work and ideas of other community members</li>
            <li>Properly credit sources when sharing content</li>
          </ul>
          
          <h3>5. Follow Platform Rules</h3>
          <ul>
            <li>Comply with all applicable laws and regulations</li>
            <li>Do not attempt to bypass security measures</li>
            <li>Report violations to moderators</li>
          </ul>
        </section>

        <!-- Terms of Service Section -->
        <section class="guidelines-section">
          <h2>Terms of Service</h2>
          
          <h3>1. Account Responsibility</h3>
          <p>You are responsible for maintaining the confidentiality of your account credentials. You agree to accept responsibility for all activities that occur under your account.</p>
          
          <h3>2. Acceptable Use</h3>
          <p>You agree not to use the TFT Smart Hub for any illegal or unauthorized purpose. You agree to comply with all laws, rules, and regulations applicable to your use of the platform.</p>
          
          <h3>3. Content You Provide</h3>
          <p>You retain all rights to any content you submit. By submitting content, you grant us a worldwide, non-exclusive, royalty-free license to use, modify, and distribute your content for platform purposes.</p>
          
          <h3>4. Limitation of Liability</h3>
          <p>The platform is provided "as is" without warranties. We are not liable for any indirect, incidental, or consequential damages arising from your use of the platform.</p>
          
          <h3>5. Modification of Terms</h3>
          <p>We reserve the right to modify these terms at any time. Your continued use of the platform constitutes your acceptance of any changes.</p>
          
          <h3>6. Termination</h3>
          <p>We reserve the right to terminate or suspend your account at any time for violations of these terms or community guidelines.</p>
        </section>

        <!-- Data Privacy Section -->
        <section class="guidelines-section">
          <h2>Data Privacy</h2>
          <p>We respect your privacy. Your personal information is protected according to our privacy policy. We do not share your data with third parties without your consent, except as required by law.</p>
        </section>

        <!-- Contact Section -->
        <section class="guidelines-section">
          <h2>Questions or Concerns?</h2>
          <p>If you have questions about these guidelines or our terms of service, please contact us at support@tftsmarthub.com</p>
        </section>
      </div>

      <div class="guidelines-actions">
        <button v-if="!isAcceptingTerms" @click="goBack" class="btn-secondary">Go Back</button>
        <button v-if="isAcceptingTerms" @click="acceptTerms" class="btn-primary" :disabled="acceptingTermsLoading">
          <span v-if="acceptingTermsLoading" class="spinner-border spinner-border-sm me-2"></span>
          I Accept & Continue
        </button>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { authStore } from '../stores/authStore'

const router = useRouter()
const route = useRoute()
const acceptingTermsLoading = ref(false)

// Check if user needs to accept terms (came from Google login)
const isAcceptingTerms = computed(() => {
  return !!route.query.return && authStore.user && !authStore.user.terms_accepted
})

async function acceptTerms() {
  try {
    acceptingTermsLoading.value = true
    const response = await fetch('/api/auth/accept_terms', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${authStore.token}`
      }
    })
    
    if (response.ok) {
      const data = await response.json()
      // Update user in store and persist to localStorage
      if (data.user) {
        authStore.setSession(authStore.token, data.user)
      }
      // Redirect to return path or home
      const redirectTo = route.query.return || '/'
      router.replace(redirectTo)
    } else {
      console.error('Failed to accept terms')
    }
  } catch (error) {
    console.error('Error accepting terms:', error)
  } finally {
    acceptingTermsLoading.value = false
  }
}

function goBack() {
  router.go(-1)
}
</script>

<style scoped>
.guidelines-page {
  min-height: 100vh;
  background: linear-gradient(135deg, #1a1a2e 0%, #16213e 100%);
  padding: 40px 20px;
}

.guidelines-container {
  max-width: 900px;
  margin: 0 auto;
  background: #0f3460;
  border-radius: 8px;
  padding: 40px;
  color: #ecf0f1;
  box-shadow: 0 8px 32px rgba(0, 0, 0, 0.3);
}

h1 {
  text-align: center;
  color: #00d4ff;
  margin-bottom: 40px;
  font-size: 2.5em;
  text-shadow: 0 2px 10px rgba(0, 212, 255, 0.3);
}

.guidelines-content {
  margin-bottom: 40px;
}

.guidelines-section {
  margin-bottom: 40px;
  padding-bottom: 30px;
  border-bottom: 1px solid #1a3a52;
}

.guidelines-section:last-child {
  border-bottom: none;
}

h2 {
  color: #00d4ff;
  font-size: 1.8em;
  margin-bottom: 20px;
  text-shadow: 0 2px 8px rgba(0, 212, 255, 0.2);
}

h3 {
  color: #ffd700;
  font-size: 1.2em;
  margin-top: 20px;
  margin-bottom: 12px;
}

p {
  line-height: 1.6;
  margin-bottom: 15px;
  color: #d1d5db;
}

ul {
  list-style: none;
  padding-left: 0;
  margin-bottom: 15px;
}

li {
  padding-left: 25px;
  margin-bottom: 10px;
  position: relative;
  color: #d1d5db;
  line-height: 1.6;
}

li:before {
  content: "→";
  position: absolute;
  left: 0;
  color: #00d4ff;
  font-weight: bold;
}

.guidelines-actions {
  display: flex;
  justify-content: center;
  gap: 15px;
  margin-top: 40px;
  padding-top: 30px;
  border-top: 1px solid #1a3a52;
}

.btn-secondary {
  padding: 12px 30px;
  background-color: #1a3a52;
  color: #00d4ff;
  border: 2px solid #00d4ff;
  border-radius: 6px;
  cursor: pointer;
  font-size: 1em;
  transition: all 0.3s ease;
}

.btn-secondary:hover {
  background-color: #00d4ff;
  color: #0f3460;
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(0, 212, 255, 0.3);
}

.btn-secondary:active {
  transform: translateY(0);
}

.btn-primary {
  padding: 12px 30px;
  background-color: #00d4ff;
  color: #0f3460;
  border: 2px solid #00d4ff;
  border-radius: 6px;
  cursor: pointer;
  font-size: 1em;
  font-weight: 600;
  transition: all 0.3s ease;
}

.btn-primary:hover:not(:disabled) {
  background-color: #00a8cc;
  border-color: #00a8cc;
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(0, 212, 255, 0.4);
}

.btn-primary:active:not(:disabled) {
  transform: translateY(0);
}

.btn-primary:disabled {
  opacity: 0.6;
  cursor: not-allowed;
}

@media (max-width: 768px) {
  .guidelines-container {
    padding: 20px;
  }

  h1 {
    font-size: 1.8em;
    margin-bottom: 25px;
  }

  h2 {
    font-size: 1.4em;
  }

  h3 {
    font-size: 1.1em;
  }

  .guidelines-section {
    margin-bottom: 25px;
    padding-bottom: 20px;
  }
}
</style>
