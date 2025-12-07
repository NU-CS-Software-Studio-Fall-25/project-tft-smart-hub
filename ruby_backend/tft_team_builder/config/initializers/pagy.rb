# frozen_string_literal: true

# Pagy initializer file (9.x)
# Customize only what you really need
# See https://ddnexus.github.io/pagy/docs/api/pagy#global-vars

require "pagy/extras/metadata"

# Items per page (default: 20)
Pagy::DEFAULT[:limit] = 10  # Use :limit instead of :items for Pagy 9.x

# Enable ARIA attributes for accessibility (default: false)
# Pagy::DEFAULT[:enable_aria_label] = true
