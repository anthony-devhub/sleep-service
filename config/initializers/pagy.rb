require "pagy/extras/array"
require "pagy/extras/metadata"
require "pagy/extras/overflow"

Pagy::DEFAULT[:limit] = 20
Pagy::DEFAULT[:max_items] = 100
Pagy::DEFAULT[:page]  = 1
Pagy::DEFAULT[:overflow] = :empty_page
