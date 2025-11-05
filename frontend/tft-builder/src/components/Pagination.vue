<template>
  <nav v-if="totalPages > 1" aria-label="Pagination" class="d-flex justify-content-center">
    <ul class="pagination pagination-sm mb-0">
      <li class="page-item" :class="{ disabled: currentPage === 1 }">
        <button
          class="page-link"
          @click="changePage(currentPage - 1)"
          :disabled="currentPage === 1"
          aria-label="Previous"
        >
          <span aria-hidden="true">&laquo;</span>
        </button>
      </li>

      <li
        v-for="page in visiblePages"
        :key="page"
        class="page-item"
        :class="{ active: page === currentPage, disabled: page === '...' }"
      >
        <button
          v-if="page !== '...'"
          class="page-link"
          @click="changePage(page)"
        >
          {{ page }}
        </button>
        <span v-else class="page-link">...</span>
      </li>

      <li class="page-item" :class="{ disabled: currentPage === totalPages }">
        <button
          class="page-link"
          @click="changePage(currentPage + 1)"
          :disabled="currentPage === totalPages"
          aria-label="Next"
        >
          <span aria-hidden="true">&raquo;</span>
        </button>
      </li>
    </ul>
  </nav>
</template>

<script setup>
import { computed } from 'vue'

const props = defineProps({
  currentPage: {
    type: Number,
    required: true,
    default: 1,
  },
  totalItems: {
    type: Number,
    required: true,
  },
  itemsPerPage: {
    type: Number,
    default: 5,
  },
  maxVisiblePages: {
    type: Number,
    default: 5,
  },
})

const emit = defineEmits(['page-changed'])

const totalPages = computed(() => Math.ceil(props.totalItems / props.itemsPerPage))

const visiblePages = computed(() => {
  const pages = []
  const total = totalPages.value
  const current = props.currentPage
  const max = props.maxVisiblePages

  if (total <= max) {
    // Show all pages
    for (let i = 1; i <= total; i++) {
      pages.push(i)
    }
  } else {
    // Always show first page
    pages.push(1)

    let start = Math.max(2, current - 1)
    let end = Math.min(total - 1, current + 1)

    // Adjust if near start
    if (current <= 3) {
      end = Math.min(max - 1, total - 1)
    }

    // Adjust if near end
    if (current >= total - 2) {
      start = Math.max(2, total - max + 2)
    }

    // Add ellipsis after first page if needed
    if (start > 2) {
      pages.push('...')
    }

    // Add middle pages
    for (let i = start; i <= end; i++) {
      pages.push(i)
    }

    // Add ellipsis before last page if needed
    if (end < total - 1) {
      pages.push('...')
    }

    // Always show last page
    pages.push(total)
  }

  return pages
})

const changePage = (page) => {
  if (page >= 1 && page <= totalPages.value && page !== props.currentPage) {
    emit('page-changed', page)
  }
}
</script>

<style scoped>
.pagination {
  --bs-pagination-padding-x: 0.75rem;
  --bs-pagination-padding-y: 0.375rem;
  --bs-pagination-font-size: 0.875rem;
}

.page-link {
  border-radius: 6px;
  margin: 0 2px;
  transition: all 0.2s ease;
}

.page-item.active .page-link {
  background: linear-gradient(135deg, #ffc107 0%, #ffb300 100%);
  border-color: #ffc107;
  color: #1a1a2e;
  font-weight: 600;
}

.page-link:hover:not(.disabled) {
  background-color: rgba(255, 193, 7, 0.1);
  border-color: #ffc107;
  color: #ffc107;
}

.page-item.disabled .page-link {
  opacity: 0.5;
  cursor: not-allowed;
}
</style>
