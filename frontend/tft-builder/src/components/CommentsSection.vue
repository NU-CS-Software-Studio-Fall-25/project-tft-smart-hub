<template>
  <div class="comments-section">
    <div class="comments-header d-flex justify-content-between align-items-center mb-4">
      <h2 class="h5 fw-semibold mb-0">
        <i class="bi bi-chat-left-text me-2"></i>
        Comments ({{ comments.length }})
      </h2>
    </div>

    <!-- Add comment form (only for logged-in users) -->
    <div v-if="authStore.isAuthenticated" class="comment-form card border-0 bg-body-secondary mb-4">
      <div class="card-body">
        <form @submit.prevent="submitComment">
          <div class="mb-3">
            <textarea
              v-model="newCommentContent"
              class="form-control"
              rows="3"
              placeholder="Share your thoughts about this team composition..."
              maxlength="500"
              :disabled="submitting"
            ></textarea>
            <div class="form-text text-end">
              {{ newCommentContent.length }}/500
            </div>
          </div>
          <div class="d-flex justify-content-between align-items-center">
            <div class="text-muted small">
              <i class="bi bi-info-circle me-1"></i>
              Be respectful and constructive
            </div>
            <button 
              type="submit" 
              class="btn btn-primary"
              :disabled="!newCommentContent.trim() || submitting"
            >
              <span v-if="submitting" class="spinner-border spinner-border-sm me-2"></span>
              <i v-else class="bi bi-send me-1"></i>
              Post comment
            </button>
          </div>
        </form>
        <div v-if="error" class="alert alert-danger mt-3 mb-0">
          {{ error }}
        </div>
      </div>
    </div>

    <!-- Login prompt for non-authenticated users -->
    <div v-else class="alert alert-info mb-4">
      <i class="bi bi-info-circle me-2"></i>
      <RouterLink to="/login">Sign in</RouterLink> to leave a comment
    </div>

    <!-- Comments list -->
    <div v-if="loading && comments.length === 0" class="text-center py-4">
      <div class="spinner-border spinner-border-sm"></div>
      <div class="mt-2 text-muted small">Loading comments...</div>
    </div>

    <div v-else-if="comments.length === 0" class="text-center py-5 text-muted">
      <i class="bi bi-chat-left text-muted" style="font-size: 3rem;"></i>
      <p class="mt-3">No comments yet. Be the first to share your thoughts!</p>
    </div>

    <div v-else class="comments-list">
      <div
        v-for="comment in comments"
        :key="comment.id"
        class="comment-item card border-0 mb-3"
      >
        <div class="card-body">
          <div class="d-flex justify-content-between align-items-start mb-2">
            <div class="comment-author d-flex align-items-center gap-2">
              <div class="avatar-circle">
                {{ getInitials(comment.user.displayName || comment.user.email) }}
              </div>
              <div>
                <div class="fw-semibold">{{ comment.user.displayName || comment.user.email }}</div>
                <div class="text-muted small">{{ formatDate(comment.createdAt) }}</div>
              </div>
            </div>
            <button
              v-if="comment.canDelete"
              class="btn btn-sm btn-outline-danger"
              @click="deleteComment(comment.id)"
              :disabled="deletingCommentId === comment.id"
              title="Delete comment"
            >
              <span v-if="deletingCommentId === comment.id" class="spinner-border spinner-border-sm"></span>
              <i v-else class="bi bi-trash"></i>
            </button>
          </div>
          <div class="comment-content">
            {{ comment.content }}
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, computed } from 'vue'
import { RouterLink } from 'vue-router'
import { authStore } from '../stores/authStore'
import { fetchComments, createComment, deleteComment as apiDeleteComment } from '../services/api'

const props = defineProps({
  teamCompId: {
    type: [Number, String],
    required: true,
  },
})

const comments = ref([])
const loading = ref(false)
const submitting = ref(false)
const deletingCommentId = ref(null)
const newCommentContent = ref('')
const error = ref(null)

const getInitials = (name) => {
  if (!name) return '?'
  const parts = name.split(/[\s@]/)
  if (parts.length >= 2) {
    return (parts[0][0] + parts[1][0]).toUpperCase()
  }
  return name.substring(0, 2).toUpperCase()
}

const formatDate = (dateString) => {
  const date = new Date(dateString)
  const now = new Date()
  const diff = now - date
  const seconds = Math.floor(diff / 1000)
  const minutes = Math.floor(seconds / 60)
  const hours = Math.floor(minutes / 60)
  const days = Math.floor(hours / 24)

  if (seconds < 60) return 'just now'
  if (minutes < 60) return `${minutes}m ago`
  if (hours < 24) return `${hours}h ago`
  if (days < 7) return `${days}d ago`
  
  return date.toLocaleDateString()
}

const loadComments = async () => {
  loading.value = true
  error.value = null
  try {
    const data = await fetchComments(props.teamCompId)
    comments.value = data.comments || []
  } catch (err) {
    console.error('Failed to load comments:', err)
    error.value = 'Failed to load comments'
  } finally {
    loading.value = false
  }
}

const submitComment = async () => {
  if (!newCommentContent.value.trim()) return
  
  submitting.value = true
  error.value = null
  
  try {
    const newComment = await createComment(props.teamCompId, {
      content: newCommentContent.value.trim(),
    })
    comments.value.unshift(newComment)
    newCommentContent.value = ''
  } catch (err) {
    console.error('Failed to post comment:', err)
    error.value = err.message || 'Failed to post comment. Please try again.'
  } finally {
    submitting.value = false
  }
}

const deleteComment = async (commentId) => {
  if (!confirm('Are you sure you want to delete this comment?')) return
  
  deletingCommentId.value = commentId
  error.value = null
  
  try {
    await apiDeleteComment(props.teamCompId, commentId)
    comments.value = comments.value.filter(c => c.id !== commentId)
  } catch (err) {
    console.error('Failed to delete comment:', err)
    error.value = 'Failed to delete comment. Please try again.'
  } finally {
    deletingCommentId.value = null
  }
}

onMounted(() => {
  loadComments()
})
</script>

<style scoped>
.comments-section {
  margin-top: 2rem;
}

.comment-form {
  background: #f8f9fa;
}

.comment-item {
  background: #ffffff;
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
}

.avatar-circle {
  width: 40px;
  height: 40px;
  border-radius: 50%;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  display: flex;
  align-items: center;
  justify-content: center;
  font-weight: 600;
  font-size: 0.875rem;
}

.comment-content {
  color: #374151;
  line-height: 1.6;
  white-space: pre-wrap;
  word-wrap: break-word;
}

.comments-list {
  max-height: 600px;
  overflow-y: auto;
}

.comments-list::-webkit-scrollbar {
  width: 8px;
}

.comments-list::-webkit-scrollbar-track {
  background: #f1f1f1;
  border-radius: 4px;
}

.comments-list::-webkit-scrollbar-thumb {
  background: #888;
  border-radius: 4px;
}

.comments-list::-webkit-scrollbar-thumb:hover {
  background: #555;
}
</style>
