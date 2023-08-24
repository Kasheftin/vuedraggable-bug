<template>
  <div class="columns">
    <draggable
      v-for="i in 3"
      :key="i"
      :model-value="itemsByColumn[i] || []"
      item-key="id"
      class="column"
      group="shared"
      v-bind="draggableSettings"
      @change="applyDrag($event, i)"
    >
      <template #item="{ element }">
        <div class="element">
          Item {{ element.id }}
        </div>
      </template>
    </draggable>
  </div>
  <button @click="blink">
    Blink
  </button>
</template>

<script setup lang="ts">
import { computed, ref } from 'vue'
import draggable from 'vuedraggable'
import type { SortableOptions } from 'sortablejs'

const draggableSettings: SortableOptions = {
  forceFallback: true,
  fallbackOnBody: true
}

type Item = {
  id: number
  columnId: number
  rank: number
}

const items = ref<Item[]>([
  { id: 1, columnId: 1, rank: 1 },
  { id: 2, columnId: 1, rank: 2 },
  { id: 3, columnId: 1, rank: 3 }
])

const itemsByColumn = computed(() => {
  const out = items.value.reduce((out: Record<number, Item[]>, item) => {
    out[item.columnId] = out[item.columnId] || []
    out[item.columnId].push(item)
    return out
  }, {})
  Object.values(out).forEach((items) => {
    items.sort((i1, i2) => i1.rank - i2.rank)
  })
  return out
})

const applyDrag = (event: any, columnId: number) => {
  const currentItems = [...(itemsByColumn.value[columnId] || [])]
  const addedId = event.added?.element?.id
  const movedId = event.moved?.element?.id
  if (addedId || movedId) {
    const item = items.value.find(item => item.id === (addedId || movedId))
    if (!item) {
      return
    }
    if (addedId) {
      currentItems.splice(event.added.newIndex, 0, item)
    } else if (movedId) {
      currentItems.splice(event.moved.newIndex, 0, currentItems.splice(event.moved.oldIndex, 1)[0])
    }
    const newRanks = currentItems.reduce((out: Record<number, number>, item, index) => {
      out[item.id] = index + 1
      return out
    }, {})
    items.value.forEach((item) => {
      if (newRanks[item.id]) {
        item.rank = newRanks[item.id]
      }
      if (item.id === addedId || movedId) {
        item.columnId = columnId
      }
    })
  }
}

const blink = () => {
  items.value.push({
    id: 4,
    columnId: 1,
    rank: 4
  })
  console.log('4-th item added')
  setTimeout(() => {
    items.value = items.value.filter(item => item.id !== 4)
    console.log('4-th item removed')
  }, 5000)
}
</script>

<style lang="css">
.columns {
  width: 100%;
  display: flex;
  align-items: center;
  justify-content: center;
}
.column {
  flex: 0 0 200px;
  display: flex;
  flex-direction: column;
  border: 1px solid gray;
  min-height: 500px;
  padding: 16px;
  margin: 16px;
  gap: 16px;
}
.element {
  border: 1px solid gray;
  padding: 16px;
}
</style>
